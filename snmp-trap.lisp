;;;; -*- Mode: Lisp -*-
;;;; $Id$

(in-package :snmp)

(defvar *default-trap-enterprise* nil)

(defun initialize-default-trap ()
  (setq *default-trap-enterprise* (oid "enterprises")))

(defgeneric snmp-trap (session vars &key &allow-other-keys)
  (:documentation "SNMP Trap"))

(defmethod snmp-trap ((session v1-session) (vars list) &key
                      (enterprise *default-trap-enterprise*)
                      (agent-addr "0.0.0.0")
                      (generic-trap +enterprise-specific+)
                      (specific-trap 0)
                      (uptime (truncate (* (get-internal-run-time)
                                           #.(/ 100 internal-time-units-per-second))))
                      &allow-other-keys)
  "SNMPv1 Trap PDU is different from v2c and v3, no request id"
  (declare (type integer generic-trap specific-trap)
           (type string agent-addr))
  (unless enterprise
    (initialize-default-trap))
  (let ((vb (if (null vars) #()
              (mapcar #'(lambda (x) (list (oid (car x)) (cdr x))) vars))))
    (let ((message (make-instance 'v1-message :session session
                                  :pdu (make-instance 'trap-pdu
                                                      :variable-bindings vb
                                                      :enterprise enterprise
                                                      :agent-addr (ipaddress agent-addr)
                                                      :generic-trap generic-trap
                                                      :specific-trap specific-trap
                                                      :timestamp (timeticks uptime)))))
      (send-snmp-message session message :receive nil))))

(defun snmp-trap-internal (session vars uptime trap-oid inform &optional context)
  (let ((vb (list* (list (oid "sysUpTime.0")
                         (timeticks uptime))
                   (list (oid "snmpTrapOID.0")
                         trap-oid)
                   (mapcar #'(lambda (x) (list (oid (car x)) (cdr x))) vars))))
    (let ((message (make-instance (gethash (type-of session) *session->message*)
                                  :session session
                                  :context (or context *default-context*)
                                  :pdu (make-instance (if inform
                                                        'inform-request-pdu
                                                        'snmpv2-trap-pdu)
                                                      :variable-bindings vb))))
      (send-snmp-message session message :receive inform))))

(defmethod snmp-trap ((session v2c-session) (vars list) &key
                      (uptime (truncate (* (get-internal-run-time)
                                           #.(/ 100 internal-time-units-per-second))))
                      (trap-oid *default-trap-enterprise*)
                      (inform nil)
                      &allow-other-keys)
  (snmp-trap-internal session vars uptime trap-oid inform))

(defmethod snmp-trap ((session v3-session) (vars list) &key
                      (uptime (truncate (* (get-internal-run-time)
                                           #.(/ 100 internal-time-units-per-second))))
                      (trap-oid *default-trap-enterprise*)
                      (inform nil)
                      (context *default-context*)
                      &allow-other-keys)
  (when (need-report-p session)
    (snmp-report session))
  (snmp-trap-internal session vars uptime trap-oid inform context))

(defgeneric snmp-inform (session vars &key &allow-other-keys)
  (:documentation "SNMP Inform, only support v2c and v3 session"))

(defmethod snmp-inform ((session v2c-session) (vars list) &key
                        (uptime (truncate (* (get-internal-run-time)
                                             #.(/ 100 internal-time-units-per-second))))
                        (trap-oid *default-trap-enterprise*)
                        &allow-other-keys)
  "SNMPv2 Inform"
  (snmp-trap session vars :uptime uptime :trap-oid trap-oid :inform t))

(defmethod snmp-inform ((session v3-session) (vars list) &key
                        (uptime (truncate (* (get-internal-run-time)
                                             #.(/ 100 internal-time-units-per-second))))
                        (trap-oid *default-trap-enterprise*)
                        (context *default-context*)
                        &allow-other-keys)
  "SNMPv3 Inform"
  (snmp-trap session vars :uptime uptime :trap-oid trap-oid :inform t :context context))
