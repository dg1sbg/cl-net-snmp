(in-package :snmp)

(defparameter *mib-list*
  '("SNMPv2-SMI"
    "SNMPv2-TC"
    "SNMPv2-CONF"
    "SNMPv2-MIB"
    "SNMPv2-TM"
    "SNMP-TARGET-MIB"
    "SNMP-FRAMEWORK-MIB"
    "SNMP-COMMUNITY-MIB"
    "SNMP-MPD-MIB"
    "SNMP-NOTIFICATION-MIB"
    "SNMP-PROXY-MIB"
    "SNMP-VIEW-BASED-ACM-MIB"
    "SNMP-USER-BASED-SM-MIB"
    "SNMP-USM-AES-MIB"
    "SNMP-USM-DH-OBJECTS-MIB"
    #|
    "IF-MIB"
    "INET-ADDRESS-MIB"
    "TRANSPORT-ADDRESS-MIB"
    "IP-MIB"
    "TCP-MIB"
    "UDP-MIB"
    "IPV6-MIB"
    "IPV6-ICMP-MIB"
    "IPV6-TCP-MIB"
    "IPV6-UDP-MIB"
    "IP-FORWARD-MIB"
    "AGENTX-MIB"
    "BGP4-MIB"
    "DISMAN-EVENT-MIB"
    "DISMAN-SCHEDULE-MIB"
    "DISMAN-SCRIPT-MIB"
    "EtherLike-MIB"
    "HCNUM-TC"
    "HOST-RESOURCES-MIB"
    "HOST-RESOURCES-TYPES"
    "IANA-ADDRESS-FAMILY-NUMBERS-MIB"
    "IANAifType-MIB"
    "IANA-LANGUAGE-MIB"
    "IANA-RTPROTO-MIB"
    "IF-INVERTED-STACK-MIB"
    "NET-SNMP-MIB"
    "NET-SNMP-TC"
    "NET-SNMP-AGENT-MIB"
    "NET-SNMP-EXTEND-MIB"
    "NET-SNMP-EXAMPLES-MIB"
    "UCD-SNMP-MIB"
    "UCD-DISKIO-MIB"
    "UCD-IPFWACC-MIB"
    "UCD-DLMOD-MIB"
    "UCD-DEMO-MIB"
    "LM-SENSORS-MIB"
    "RMON-MIB"
    "NOTIFICATION-LOG-MIB"
    "SMUX-MIB" |#))

(defvar *mib-list-file* #p"SNMP:MIB.LISP-EXPR")

(defun mib-file (name)
  (merge-pathnames (make-pathname :name name)
                   #p"MIB:"))

(defun lisp-file (name)
  (merge-pathnames (make-pathname :name name
                                  :type "LISP"
                                  :directory '(:relative "MIB"))
                   #p"SNMP:"))

(defun expr-file (name)
  (merge-pathnames (make-pathname :name name
                                  :type "LISP-EXPR"
                                  :directory '(:relative "MIB"))
                   #p"SNMP:"))

(defun update-mib ()
  (let ((mib.lisp-expr '()))
    (dolist (i *mib-list*)
      (compile-asn.1 (mib-file i) :to (lisp-file i))
      (let ((depends (with-open-file (s (expr-file i) :direction :input)
                       (read s))))
        (push `(:file ,(string-downcase
                        (pathname-name (lisp-file i)))
                :depends-on ,depends)
              mib.lisp-expr)))
    (with-open-file (s *mib-list-file*
                       :direction :output
                       :if-exists :supersede)
      (format s ";;;; -*- Mode: Lisp -*-~%;;;; Auto-generated by SNMP:UPDATE-MIB.LISP~%")
      (pprint (setf mib.lisp-expr (nreverse mib.lisp-expr)) s)
      (format s "~%"))
    (pprint mib.lisp-expr)))
