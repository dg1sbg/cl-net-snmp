;;;; -*- Mode: Lisp -*-
;;;; Auto-generated from MIB:BASE;NET-SNMP-MIB.TXT by ASN.1 5.0

(in-package :asn.1)

(eval-when (:load-toplevel :execute)
  (setf *current-module* 'net-snmp-mib))

(defpackage :asn.1/net-snmp-mib
  (:nicknames :net-snmp-mib)
  (:use :common-lisp :asn.1)
  (:import-from :|ASN.1/SNMPv2-SMI| module-identity |enterprises|))

(in-package :net-snmp-mib)

(defoid |netSnmp| (|enterprises| 8072)
  (:type 'module-identity)
  (:description
   "Top-level infrastructure of the Net-SNMP project enterprise MIB tree"))

(defoid |netSnmpObjects| (|netSnmp| 1) (:type 'object-identity))

(defoid |netSnmpEnumerations| (|netSnmp| 3) (:type 'object-identity))

(defoid |netSnmpModuleIDs| (|netSnmpEnumerations| 1)
  (:type 'object-identity))

(defoid |netSnmpAgentOIDs| (|netSnmpEnumerations| 2)
  (:type 'object-identity))

(defoid |netSnmpDomains| (|netSnmpEnumerations| 3)
  (:type 'object-identity))

(defoid |netSnmpExperimental| (|netSnmp| 9999) (:type 'object-identity))

(defoid |netSnmpPlaypen| (|netSnmpExperimental| 9999)
  (:type 'object-identity))

(defoid |netSnmpNotificationPrefix| (|netSnmp| 4)
  (:type 'object-identity))

(defoid |netSnmpNotifications| (|netSnmpNotificationPrefix| 0)
  (:type 'object-identity))

(defoid |netSnmpNotificationObjects| (|netSnmpNotificationPrefix| 1)
  (:type 'object-identity))

(defoid |netSnmpConformance| (|netSnmp| 5) (:type 'object-identity))

(defoid |netSnmpCompliances| (|netSnmpConformance| 1)
  (:type 'object-identity))

(defoid |netSnmpGroups| (|netSnmpConformance| 2)
  (:type 'object-identity))

(in-package :asn.1)

(eval-when (:load-toplevel :execute)
  (pushnew 'net-snmp-mib *mib-modules*)
  (setf *current-module* nil))

