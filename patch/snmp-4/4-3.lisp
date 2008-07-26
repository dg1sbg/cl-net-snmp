(in-package :snmp)

;;; package.lisp
(use-package :portable-threads)

;;; update-mib.lisp

(defvar *mib-dependency-file* #p"SNMP:MIB-DEPEND.LISP")

(defun update-mib ()
  (let ((mib.lisp-expr '())
        (mib-depend.lisp '()))
    (dolist (i *mib-list*)
      (format t "; Compiling ~A~%" i)
      (compile-asn.1 i :to (lisp-file i))
      (let ((depends (with-open-file (s (expr-file i) :direction :input)
                       (read s)))
            (name (string-downcase (pathname-name (lisp-file i)))))
        (push (if (cdr depends)
                  `(:file ,name
                    :depends-on ,(mapcar #'(lambda (x) (string-downcase (symbol-name x)))
                                         (cdr depends)))
                `(:file ,name))
              mib.lisp-expr)
        (if (cdr depends)
            (push depends mib-depend.lisp))))
    ;;; Update MIB Dependency, it's for ASDF
    (with-open-file (s *mib-list-file*
                       :direction :output
                       :if-exists :supersede)
      (format s ";;;; -*- Mode: Lisp -*-~%;;;; Auto-generated by SNMP:UPDATE-MIB.LISP~%")
      (pprint (setf mib.lisp-expr (nreverse mib.lisp-expr)) s)
      (terpri s))
    ;;; Update MIB Dependency, it's for MIB Browser
    (with-open-file (s *mib-dependency-file*
                       :direction :output
                       :if-exists :supersede)
      (format s ";;;; -*- Mode: Lisp -*-~%;;;; Auto-generated by SNMP:UPDATE-MIB.LISP~%")
      (dolist (i `((in-package :asn.1)
                   (eval-when (:load-toplevel :execute)
                     (mapcar #'(lambda (asn.1::x)
                                 (setf (gethash (car asn.1::x)
                                                asn.1::*mib-module-dependency*) (cdr asn.1::x)))
                             ',mib-depend.lisp))))
        (pprint i s))
      (terpri s))
    (load #p"SNMP:SNMP.ASD")
    (pprint mib.lisp-expr)))

;;; network.lisp

(defvar *default-socket* (socket-connect/udp nil nil :stream nil))
(defvar *current-socket* *default-socket*)

(defmethod send-snmp-message ((session session) (message message)
                              &key (receive t) (report nil) socket)
  (let ((socket (or socket
                    (and (slot-boundp session 'socket)
                         (socket-of session))
                    *current-socket*))
        (data (coerce (ber-encode message) '(simple-array (unsigned-byte 8) (*)))))
    (labels ((send ()
	       (let ((result
		      (socket-send socket data (length data)
				   :address (host-of session)
				   :port (port-of session))))
                 (declare (ignorable result))
                 #+ignore
		 (format t "socket-send result: ~A~%" result)))
             (recv ()
               (decode-message session (socket-receive socket nil
                                                       +max-snmp-packet-size+))))
      (if receive
        ;; receive = t
        (if (send-until #'send socket)
	    (recv-until #'recv #'(lambda (x) (= (request-id-of (pdu-of message))
						(request-id-of (pdu-of x)))))
	    (error "cannot got a reply"))
        ;; receive = nil
        (if report
          (unless (send-until #'send socket)
            (error "cannot got a reply when report"))
          (send))))))

(defclass rtt-info ()
  ((rtt    :accessor rtt-of
           :type short-float
           :initform 0.0
           :documentation "most recent measured RTT, seconds")
   (srtt   :accessor srtt-of
           :type short-float
           :initform 0.0
           :documentation "smoothed RTT estimator, seconds")
   (rttvar :accessor rttvar-of
           :type short-float
           :initform 0.75
           :documentation "smoothed mean deviation, seconds")
   (rto    :accessor rto-of
           :type short-float
           :documentation "current RTO to use, seconds")
   (nrexmt :accessor nrexmt-of
           :type fixnum
           :documentation "#times retransmitted: 0, 1, 2, ...")
   (base   :accessor base-of
           :type integer
           :documentation "#sec since 1/1/1970 at start, but we use Lisp time here"))
  (:documentation "RTT Info Class"))

(defvar *rtt-rxtmin*   2 "min retransmit timeout value, seconds")
(defvar *rtt-rxtmax*  60 "max retransmit timeout value, seconds")
(defvar *rtt-maxrexmt* 3 "max #times to retransmit")

(defmethod rtt-rtocalc ((instance rtt-info))
  "Calculate the RTO value based on current estimators:
        smoothed RTT plus four times the deviation."
  (with-slots (srtt rttvar) instance
    (+ srtt (* 4.0 rttvar))))

(defun rtt-minmax (rto)
  "rtt-minmax makes certain that the RTO is between the upper and lower limits."
  (declare (type short-float rto))
  (cond ((< rto *rtt-rxtmin*) *rtt-rxtmin*)
        ((> rto *rtt-rxtmax*) *rtt-rxtmax*)
        (t rto)))

(defmethod initialize-instance :after ((instance rtt-info) &rest initargs
                                       &key &allow-other-keys)
  (declare (ignore initargs))
  (with-slots (base rto) instance
    (setf base (get-internal-real-time)
          rto (rtt-minmax (rtt-rtocalc instance)))))

(defmethod rtt-ts ((instance rtt-info))
  (* (- (get-internal-real-time) (base-of instance))
     #.(/ 1000 internal-time-units-per-second)))

(defmethod rtt-start ((instance rtt-info))
  "return value can be used as: alarm(rtt_start(&foo))"
  (round (rto-of instance)))

(defmethod rtt-stop ((instance rtt-info) (ms integer))
  (with-slots (rtt srtt rttvar rto) instance
    (setf rtt (/ ms 1000.0))
    (let ((delta (- rtt srtt)))
      (incf srtt (/ delta 8.0))
      (setf delta (abs delta))
      (incf rttvar (/ (- delta rttvar) 4.0)))
    (setf rto (rtt-minmax (rtt-rtocalc instance)))))

(defmethod rtt-timeout ((instance rtt-info))
  (with-slots (rto nrexmt) instance
    (setf rto (* rto 2))
    (<= (incf nrexmt) *rtt-maxrexmt*)))

(defmethod rtt-newpack ((instance rtt-info))
  (setf (nrexmt-of instance) 0))

;;; mib-depend.lisp

(IN-PACKAGE :ASN.1)
(EVAL-WHEN (:LOAD-TOPLEVEL :EXECUTE)
  (MAPCAR #'(LAMBDA (ASN.1::X)
              (SETF (GETHASH (CAR ASN.1::X)
                             ASN.1::*MIB-MODULE-DEPENDENCY*)
                    (CDR ASN.1::X)))
          '((LINUX-HA-MIB |SNMPv2-SMI| |SNMPv2-TC| |SNMPv2-CONF|)
            (SQUID-MIB |SNMPv2-SMI| |SNMPv2-TC|)
            (RFC1213-MIB RFC1155-SMI)
            (UDP-MIB |SNMPv2-SMI| |SNMPv2-CONF| INET-ADDRESS-MIB)
            (UCD-SNMP-MIB |SNMPv2-SMI| |SNMPv2-TC|)
            (UCD-IPFWACC-MIB |SNMPv2-SMI| |SNMPv2-TC| UCD-SNMP-MIB)
            (UCD-DLMOD-MIB |SNMPv2-SMI| |SNMPv2-TC| UCD-SNMP-MIB)
            (UCD-DISKIO-MIB |SNMPv2-SMI| |SNMPv2-TC| UCD-SNMP-MIB)
            (UCD-DEMO-MIB |SNMPv2-SMI| UCD-SNMP-MIB)
            (TRANSPORT-ADDRESS-MIB |SNMPv2-SMI| |SNMPv2-TC|)
            (TCP-MIB |SNMPv2-SMI| |SNMPv2-CONF| INET-ADDRESS-MIB)
            (SOURCE-ROUTING-MIB RFC1155-SMI BRIDGE-MIB)
            (SMUX-MIB RFC1155-SMI)
            (RMON-MIB |SNMPv2-SMI| |SNMPv2-TC| |SNMPv2-CONF|)
            (|RIPv2-MIB|
             |SNMPv2-SMI|
             |SNMPv2-TC|
             |SNMPv2-CONF|
             RFC1213-MIB)
            (OSPF-TRAP-MIB |SNMPv2-SMI| |SNMPv2-CONF| OSPF-MIB)
            (OSPF-MIB
             |SNMPv2-SMI|
             |SNMPv2-TC|
             |SNMPv2-CONF|
             RFC1213-MIB)
            (NOTIFICATION-LOG-MIB
             |SNMPv2-SMI|
             |SNMPv2-TC|
             SNMP-FRAMEWORK-MIB
             |SNMPv2-CONF|)
            (NET-SNMP-VACM-MIB
             SNMP-FRAMEWORK-MIB
             NET-SNMP-MIB
             SNMP-VIEW-BASED-ACM-MIB
             |SNMPv2-SMI|
             |SNMPv2-CONF|
             |SNMPv2-TC|)
            (NET-SNMP-TC NET-SNMP-MIB |SNMPv2-SMI| |SNMPv2-TC|)
            (NET-SNMP-MIB |SNMPv2-SMI|)
            (NET-SNMP-EXTEND-MIB
             NET-SNMP-AGENT-MIB
             |SNMPv2-SMI|
             |SNMPv2-CONF|
             |SNMPv2-TC|)
            (NET-SNMP-EXAMPLES-MIB
             |SNMPv2-SMI|
             SNMP-FRAMEWORK-MIB
             NET-SNMP-MIB
             |SNMPv2-TC|
             INET-ADDRESS-MIB)
            (NET-SNMP-AGENT-MIB
             SNMP-FRAMEWORK-MIB
             NET-SNMP-MIB
             |SNMPv2-SMI|
             |SNMPv2-CONF|
             |SNMPv2-TC|)
            (LM-SENSORS-MIB |SNMPv2-SMI| |SNMPv2-TC| UCD-SNMP-MIB)
            (IPV6-UDP-MIB |SNMPv2-CONF| |SNMPv2-SMI| IPV6-TC)
            (IPV6-TCP-MIB |SNMPv2-CONF| |SNMPv2-SMI| IPV6-TC)
            (IPV6-TC |SNMPv2-SMI| |SNMPv2-TC|)
            (IPV6-MIB |SNMPv2-SMI| |SNMPv2-TC| |SNMPv2-CONF| IPV6-TC)
            (IPV6-ICMP-MIB |SNMPv2-SMI| |SNMPv2-CONF| IPV6-MIB)
            (IP-MIB
             |SNMPv2-SMI|
             |SNMPv2-TC|
             |SNMPv2-CONF|
             INET-ADDRESS-MIB
             IF-MIB)
            (IP-FORWARD-MIB
             |SNMPv2-SMI|
             |SNMPv2-TC|
             |SNMPv2-CONF|
             IF-MIB
             IP-MIB
             IANA-RTPROTO-MIB
             INET-ADDRESS-MIB)
            (INET-ADDRESS-MIB |SNMPv2-SMI| |SNMPv2-TC|)
            (IF-MIB
             |SNMPv2-SMI|
             |SNMPv2-TC|
             |SNMPv2-CONF|
             |SNMPv2-MIB|
             |IANAifType-MIB|)
            (IF-INVERTED-STACK-MIB
             |SNMPv2-SMI|
             |SNMPv2-TC|
             |SNMPv2-CONF|
             IF-MIB)
            (|IANAifType-MIB| |SNMPv2-SMI| |SNMPv2-TC|)
            (IANA-RTPROTO-MIB |SNMPv2-SMI| |SNMPv2-TC|)
            (IANA-LANGUAGE-MIB |SNMPv2-SMI|)
            (IANA-ADDRESS-FAMILY-NUMBERS-MIB |SNMPv2-SMI| |SNMPv2-TC|)
            (HOST-RESOURCES-TYPES |SNMPv2-SMI| HOST-RESOURCES-MIB)
            (HOST-RESOURCES-MIB
             |SNMPv2-SMI|
             |SNMPv2-TC|
             |SNMPv2-CONF|
             IF-MIB)
            (HCNUM-TC |SNMPv2-SMI| |SNMPv2-TC|)
            (GNOME-SMI |SNMPv2-SMI|)
            (|EtherLike-MIB|
             |SNMPv2-SMI|
             |SNMPv2-CONF|
             |SNMPv2-TC|
             IF-MIB)
            (DISMAN-SCRIPT-MIB
             |SNMPv2-SMI|
             |SNMPv2-TC|
             |SNMPv2-CONF|
             SNMP-FRAMEWORK-MIB)
            (DISMAN-SCHEDULE-MIB
             |SNMPv2-SMI|
             |SNMPv2-TC|
             |SNMPv2-CONF|
             SNMP-FRAMEWORK-MIB)
            (DISMAN-EVENT-MIB
             |SNMPv2-SMI|
             |SNMPv2-TC|
             |SNMPv2-CONF|
             |SNMPv2-MIB|
             SNMP-TARGET-MIB
             SNMP-FRAMEWORK-MIB)
            (BRIDGE-MIB RFC1155-SMI RFC1213-MIB RFC-1215)
            (BGP4-MIB |SNMPv2-SMI| |SNMPv2-CONF|)
            (AGENTX-MIB
             |SNMPv2-SMI|
             SNMP-FRAMEWORK-MIB
             |SNMPv2-CONF|
             |SNMPv2-TC|)
            (|SNMPv2-TM| |SNMPv2-SMI| |SNMPv2-TC|)
            (|SNMPv2-TC| |SNMPv2-SMI|)
            (|SNMPv2-MIB| |SNMPv2-SMI| |SNMPv2-TC| |SNMPv2-CONF|)
            (|SNMPv2-CONF| |SNMPv2-SMI|)
            (SNMP-VIEW-BASED-ACM-MIB
             |SNMPv2-CONF|
             |SNMPv2-SMI|
             |SNMPv2-TC|
             SNMP-FRAMEWORK-MIB)
            (SNMP-USM-DH-OBJECTS-MIB
             |SNMPv2-SMI|
             |SNMPv2-TC|
             |SNMPv2-CONF|
             SNMP-USER-BASED-SM-MIB
             SNMP-FRAMEWORK-MIB)
            (SNMP-USM-AES-MIB |SNMPv2-SMI| SNMP-FRAMEWORK-MIB)
            (SNMP-USER-BASED-SM-MIB
             |SNMPv2-SMI|
             |SNMPv2-TC|
             |SNMPv2-CONF|
             SNMP-FRAMEWORK-MIB)
            (SNMP-TARGET-MIB
             |SNMPv2-SMI|
             |SNMPv2-TC|
             SNMP-FRAMEWORK-MIB
             |SNMPv2-CONF|)
            (SNMP-PROXY-MIB
             |SNMPv2-SMI|
             |SNMPv2-TC|
             SNMP-FRAMEWORK-MIB
             SNMP-TARGET-MIB
             |SNMPv2-CONF|)
            (SNMP-NOTIFICATION-MIB
             |SNMPv2-SMI|
             |SNMPv2-TC|
             SNMP-FRAMEWORK-MIB
             SNMP-TARGET-MIB
             |SNMPv2-CONF|)
            (SNMP-MPD-MIB |SNMPv2-CONF| |SNMPv2-SMI|)
            (SNMP-FRAMEWORK-MIB |SNMPv2-SMI| |SNMPv2-TC| |SNMPv2-CONF|)
            (SNMP-COMMUNITY-MIB
             |SNMPv2-SMI|
             |SNMPv2-TC|
             SNMP-FRAMEWORK-MIB
             SNMP-TARGET-MIB
             |SNMPv2-CONF|))))

;;; worker.lisp
(defvar *send-worker-cv* (make-condition-variable))
(defvar *recv-worker-cv* (make-condition-variable))

(defun send-worker ()
  (loop (thread-yield)
        (sleep 1)))

(defun recv-worker ()
  (loop (thread-yield)
        (sleep 1)))

;;; constants.lisp
(defconstant +max-snmp-packet-size+ 65507)

;;; session.lisp

(defun open-session (host &key (port *default-snmp-port*)
                               (version *default-snmp-version*)
                               (community *default-snmp-community*)
                               user auth priv
                               (create-socket t))
  ;; first, what version we are talking about if version not been set?
  (let* ((real-version (or (gethash version *snmp-version-table* version)
                           (if user +snmp-version-3+ *default-snmp-version*)))
         (args (list (gethash real-version *snmp-class-table*)
                     :host host :port port)))
    (when create-socket
      (nconc args (list :socket (socket-connect/udp nil nil
                                                    :element-type '(unsigned-byte 8)
                                                    :stream nil))))
    (if (/= real-version +snmp-version-3+)
      ;; for SNMPv1 and v2c, only set the community
      (nconc args (list :community (or community *default-snmp-community*)))
      ;; for SNMPv3, we detect the auth and priv parameters
      (progn
        (nconc args (list :security-name user))
        (when auth
          (if (atom auth)
            (nconc args (list :auth-protocol *default-auth-protocol*)
                   (if (stringp auth)
                     (list :auth-key (generate-ku auth :hash-type *default-auth-protocol*))
                     (list :auth-local-key
                           (coerce auth '(simple-array (unsigned-byte 8) (*))))))
            (destructuring-bind (auth-protocol . auth-key) auth
              (nconc args (list :auth-protocol auth-protocol)
                     (let ((key (if (atom auth-key) auth-key (car auth-key))))
                       (if (stringp key)
                         (list :auth-key (generate-ku key :hash-type auth-protocol))
                         (list :auth-local-key
                               (coerce key '(simple-array (unsigned-byte 8) (*))))))))))
        (when priv
          (if (atom priv)
            (nconc args (list :priv-protocol *default-priv-protocol*)
                   (if (stringp auth)
                     (list :priv-key (generate-ku priv :hash-type :md5))
                     (list :priv-local-key
                           (coerce priv '(simple-array (unsigned-byte 8) (*))))))
            (destructuring-bind (priv-protocol . priv-key) priv
              (nconc args (list :priv-protocol priv-protocol)
                     (let ((key (if (atom priv-key) priv-key (car priv-key))))
                       (if (stringp key)
                         (list :priv-key (generate-ku key :hash-type :md5))
                         (list :priv-local-key
                               (coerce key '(simple-array (unsigned-byte 8) (*))))))))))))
    (apply #'make-instance args)))

(defmethod close-session ((session session))
  (when (slot-boundp session 'socket)
    (socket-close (socket-of session))))