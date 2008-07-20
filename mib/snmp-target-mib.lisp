;;;; Auto-generated from MIB:SNMP-TARGET-MIB

(IN-PACKAGE :ASN.1)
(SETF *CURRENT-MODULE* 'SNMP-TARGET-MIB)
(DEFOID |snmpTargetMIB| (|snmpModules| 12))
(DEFOID |snmpTargetObjects| (|snmpTargetMIB| 1))
(DEFOID |snmpTargetConformance| (|snmpTargetMIB| 3))
(DEFUNKNOWN :TYPE-ASSIGNMENT)
(DEFUNKNOWN :TYPE-ASSIGNMENT)
(DEFOID |snmpTargetSpinLock| (|snmpTargetObjects| 1))
(DEFOID |snmpTargetAddrTable| (|snmpTargetObjects| 2))
(DEFOID |snmpTargetAddrEntry| (|snmpTargetAddrTable| 1))
(DEFUNKNOWN :TYPE-ASSIGNMENT)
(DEFOID |snmpTargetAddrName| (|snmpTargetAddrEntry| 1))
(DEFOID |snmpTargetAddrTDomain| (|snmpTargetAddrEntry| 2))
(DEFOID |snmpTargetAddrTAddress| (|snmpTargetAddrEntry| 3))
(DEFOID |snmpTargetAddrTimeout| (|snmpTargetAddrEntry| 4))
(DEFOID |snmpTargetAddrRetryCount| (|snmpTargetAddrEntry| 5))
(DEFOID |snmpTargetAddrTagList| (|snmpTargetAddrEntry| 6))
(DEFOID |snmpTargetAddrParams| (|snmpTargetAddrEntry| 7))
(DEFOID |snmpTargetAddrStorageType| (|snmpTargetAddrEntry| 8))
(DEFOID |snmpTargetAddrRowStatus| (|snmpTargetAddrEntry| 9))
(DEFOID |snmpTargetParamsTable| (|snmpTargetObjects| 3))
(DEFOID |snmpTargetParamsEntry| (|snmpTargetParamsTable| 1))
(DEFUNKNOWN :TYPE-ASSIGNMENT)
(DEFOID |snmpTargetParamsName| (|snmpTargetParamsEntry| 1))
(DEFOID |snmpTargetParamsMPModel| (|snmpTargetParamsEntry| 2))
(DEFOID |snmpTargetParamsSecurityModel| (|snmpTargetParamsEntry| 3))
(DEFOID |snmpTargetParamsSecurityName| (|snmpTargetParamsEntry| 4))
(DEFOID |snmpTargetParamsSecurityLevel| (|snmpTargetParamsEntry| 5))
(DEFOID |snmpTargetParamsStorageType| (|snmpTargetParamsEntry| 6))
(DEFOID |snmpTargetParamsRowStatus| (|snmpTargetParamsEntry| 7))
(DEFOID |snmpUnavailableContexts| (|snmpTargetObjects| 4))
(DEFOID |snmpUnknownContexts| (|snmpTargetObjects| 5))
(DEFOID |snmpTargetCompliances| (|snmpTargetConformance| 1))
(DEFOID |snmpTargetGroups| (|snmpTargetConformance| 2))
(DEFUNKNOWN 'MODULE-COMPLIANCE)
(DEFOID |snmpTargetBasicGroup| (|snmpTargetGroups| 1))
(DEFOID |snmpTargetResponseGroup| (|snmpTargetGroups| 2))
(DEFOID |snmpTargetCommandResponderGroup| (|snmpTargetGroups| 3))