;;;; Auto-generated from MIB:SNMPV2-MIB

(IN-PACKAGE :ASN.1)
(SETF *CURRENT-MODULE* '|SNMPv2-MIB|)
(DEFOID |snmpMIB| (|snmpModules| 1))
(DEFOID |snmpMIBObjects| (|snmpMIB| 1))
(DEFOID |system| (|mib-2| 1))
(DEFOID |sysDescr| (|system| 1))
(DEFOID |sysObjectID| (|system| 2))
(DEFOID |sysUpTime| (|system| 3))
(DEFOID |sysContact| (|system| 4))
(DEFOID |sysName| (|system| 5))
(DEFOID |sysLocation| (|system| 6))
(DEFOID |sysServices| (|system| 7))
(DEFOID |sysORLastChange| (|system| 8))
(DEFOID |sysORTable| (|system| 9))
(DEFOID |sysOREntry| (|sysORTable| 1))
(DEFUNKNOWN :TYPE-ASSIGNMENT)
(DEFOID |sysORIndex| (|sysOREntry| 1))
(DEFOID |sysORID| (|sysOREntry| 2))
(DEFOID |sysORDescr| (|sysOREntry| 3))
(DEFOID |sysORUpTime| (|sysOREntry| 4))
(DEFOID |snmp| (|mib-2| 11))
(DEFOID |snmpInPkts| (|snmp| 1))
(DEFOID |snmpInBadVersions| (|snmp| 3))
(DEFOID |snmpInBadCommunityNames| (|snmp| 4))
(DEFOID |snmpInBadCommunityUses| (|snmp| 5))
(DEFOID |snmpInASNParseErrs| (|snmp| 6))
(DEFOID |snmpEnableAuthenTraps| (|snmp| 30))
(DEFOID |snmpSilentDrops| (|snmp| 31))
(DEFOID |snmpProxyDrops| (|snmp| 32))
(DEFOID |snmpTrap| (|snmpMIBObjects| 4))
(DEFOID |snmpTrapOID| (|snmpTrap| 1))
(DEFOID |snmpTrapEnterprise| (|snmpTrap| 3))
(DEFOID |snmpTraps| (|snmpMIBObjects| 5))
(DEFOID |coldStart| (|snmpTraps| 1))
(DEFOID |warmStart| (|snmpTraps| 2))
(DEFOID |authenticationFailure| (|snmpTraps| 5))
(DEFOID |snmpSet| (|snmpMIBObjects| 6))
(DEFOID |snmpSetSerialNo| (|snmpSet| 1))
(DEFOID |snmpMIBConformance| (|snmpMIB| 2))
(DEFOID |snmpMIBCompliances| (|snmpMIBConformance| 1))
(DEFOID |snmpMIBGroups| (|snmpMIBConformance| 2))
(DEFUNKNOWN 'MODULE-COMPLIANCE)
(DEFUNKNOWN 'MODULE-COMPLIANCE)
(DEFOID |snmpGroup| (|snmpMIBGroups| 8))
(DEFOID |snmpCommunityGroup| (|snmpMIBGroups| 9))
(DEFOID |snmpSetGroup| (|snmpMIBGroups| 5))
(DEFOID |systemGroup| (|snmpMIBGroups| 6))
(DEFOID |snmpBasicNotificationsGroup| (|snmpMIBGroups| 7))
(DEFOID |snmpWarmStartNotificationGroup| (|snmpMIBGroups| 11))
(DEFOID |snmpNotificationGroup| (|snmpMIBGroups| 12))
(DEFOID |snmpOutPkts| (|snmp| 2))
(DEFOID |snmpInTooBigs| (|snmp| 8))
(DEFOID |snmpInNoSuchNames| (|snmp| 9))
(DEFOID |snmpInBadValues| (|snmp| 10))
(DEFOID |snmpInReadOnlys| (|snmp| 11))
(DEFOID |snmpInGenErrs| (|snmp| 12))
(DEFOID |snmpInTotalReqVars| (|snmp| 13))
(DEFOID |snmpInTotalSetVars| (|snmp| 14))
(DEFOID |snmpInGetRequests| (|snmp| 15))
(DEFOID |snmpInGetNexts| (|snmp| 16))
(DEFOID |snmpInSetRequests| (|snmp| 17))
(DEFOID |snmpInGetResponses| (|snmp| 18))
(DEFOID |snmpInTraps| (|snmp| 19))
(DEFOID |snmpOutTooBigs| (|snmp| 20))
(DEFOID |snmpOutNoSuchNames| (|snmp| 21))
(DEFOID |snmpOutBadValues| (|snmp| 22))
(DEFOID |snmpOutGenErrs| (|snmp| 24))
(DEFOID |snmpOutGetRequests| (|snmp| 25))
(DEFOID |snmpOutGetNexts| (|snmp| 26))
(DEFOID |snmpOutSetRequests| (|snmp| 27))
(DEFOID |snmpOutGetResponses| (|snmp| 28))
(DEFOID |snmpOutTraps| (|snmp| 29))
(DEFOID |snmpObsoleteGroup| (|snmpMIBGroups| 10))