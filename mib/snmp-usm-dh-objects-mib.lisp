;;;; -*- Mode: Lisp -*-
;;;; Auto-generated from MIB:NET-SNMP;SNMP-USM-DH-OBJECTS-MIB.TXT

(in-package :asn.1)
(setf *current-module* 'snmp-usm-dh-objects-mib)
(eval-when (:load-toplevel :execute)
  (pushnew 'snmp-usm-dh-objects-mib *mib-modules*))
(defoid |snmpUsmDHObjectsMIB| (|experimental| 101)
  (:type 'module-identity)
  (:description
   "The management information definitions for providing forward
    secrecy for key changes for the usmUserTable, and for providing a
    method for 'kickstarting' access to the agent via a Diffie-Helman
    key agreement."))
(defoid |usmDHKeyObjects| (|snmpUsmDHObjectsMIB| 1)
  (:type 'object-identity))
(defoid |usmDHKeyConformance| (|snmpUsmDHObjectsMIB| 2)
  (:type 'object-identity))
(deftype |DHKeyChange| () 't)
(defoid |usmDHPublicObjects| (|usmDHKeyObjects| 1)
  (:type 'object-identity))
(defoid |usmDHParameters| (|usmDHPublicObjects| 1)
  (:type 'object-type)
  (:syntax 't)
  (:max-access '|read-write|)
  (:status '|current|)
  (:description
   "The public Diffie-Hellman parameters for doing a Diffie-Hellman
    key agreement for this device.  This is encoded as an ASN.1
    DHParameter per PKCS #3, section 9.  E.g.

        DHParameter ::= SEQUENCE {
           prime   INTEGER,   -- p
           base    INTEGER,   -- g
           privateValueLength  INTEGER OPTIONAL }


    Implementors are encouraged to use either the values from
    Oakley Group 1  or the values of from Oakley Group 2 as specified
    in RFC-2409, The Internet Key Exchange, Section 6.1, 6.2 as the
    default for this object.  Other values may be used, but the
    security properties of those values MUST be well understood and
    MUST meet the requirements of PKCS #3 for the selection of
    Diffie-Hellman primes.

        In addition, any time usmDHParameters changes, all values of
    type DHKeyChange will change and new random numbers MUST be
    generated by the agent for each DHKeyChange object."))
(defoid |usmDHUserKeyTable| (|usmDHPublicObjects| 2)
  (:type 'object-type)
  (:syntax 't)
  (:max-access '|not-accessible|)
  (:status '|current|)
  (:description
   "This table augments and extends the usmUserTable and provides
    4 objects which exactly mirror the objects in that table with the
    textual convention of 'KeyChange'.  This extension allows key
    changes to be done in a manner where the knowledge of the current
    secret plus knowledge of the key change data exchanges (e.g. via
    wiretapping)  will not reveal the new key."))
(defoid |usmDHUserKeyEntry| (|usmDHUserKeyTable| 1)
  (:type 'object-type)
  (:syntax '|UsmDHUserKeyEntry|)
  (:max-access '|not-accessible|)
  (:status '|current|)
  (:description
   "A row of DHKeyChange objects which augment or replace the
    functionality of the KeyChange objects in the base table row."))
(deftype |UsmDHUserKeyEntry| () 't)
(defoid |usmDHUserAuthKeyChange| (|usmDHUserKeyEntry| 1)
  (:type 'object-type)
  (:syntax '|DHKeyChange|)
  (:max-access '|read-create|)
  (:status '|current|)
  (:description
   "The object used to change any given user's Authentication Key
    using a Diffie-Hellman key exchange.

    The right-most n bits of the shared secret 'sk', where 'n' is the
    number of bits required for the protocol defined by
    usmUserAuthProtocol, are installed as the operational
    authentication key for this row after a successful SET."))
(defoid |usmDHUserOwnAuthKeyChange| (|usmDHUserKeyEntry| 2)
  (:type 'object-type)
  (:syntax '|DHKeyChange|)
  (:max-access '|read-create|)
  (:status '|current|)
  (:description
   "The object used to change the agents own Authentication Key
    using a Diffie-Hellman key exchange.

    The right-most n bits of the shared secret 'sk', where 'n' is the
    number of bits required for the protocol defined by
    usmUserAuthProtocol, are installed as the operational
    authentication key for this row after a successful SET."))
(defoid |usmDHUserPrivKeyChange| (|usmDHUserKeyEntry| 3)
  (:type 'object-type)
  (:syntax '|DHKeyChange|)
  (:max-access '|read-create|)
  (:status '|current|)
  (:description
   "The object used to change any given user's Privacy Key using
    a Diffie-Hellman key exchange.

    The right-most n bits of the shared secret 'sk', where 'n' is the
    number of bits required for the protocol defined by
    usmUserPrivProtocol, are installed as the operational privacy key
    for this row after a successful SET."))
(defoid |usmDHUserOwnPrivKeyChange| (|usmDHUserKeyEntry| 4)
  (:type 'object-type)
  (:syntax '|DHKeyChange|)
  (:max-access '|read-create|)
  (:status '|current|)
  (:description
   "The object used to change the agent's own Privacy Key using a
    Diffie-Hellman key exchange.

    The right-most n bits of the shared secret 'sk', where 'n' is the
    number of bits required for the protocol defined by
    usmUserPrivProtocol, are installed as the operational privacy key
    for this row after a successful SET."))
(defoid |usmDHKickstartGroup| (|usmDHKeyObjects| 2)
  (:type 'object-identity))
(defoid |usmDHKickstartTable| (|usmDHKickstartGroup| 1)
  (:type 'object-type)
  (:syntax 't)
  (:max-access '|not-accessible|)
  (:status '|current|)
  (:description
   "A table of mappings between zero or more Diffie-Helman key
    agreement values and entries in the usmUserTable.  Entries in this
    table are created by providing the associated device with a
    Diffie-Helman public value and a usmUserName/usmUserSecurityName
    pair during initialization. How these values are provided is
    outside the scope of this MIB, but could be provided manually, or
    through a configuration file.  Valid public value/name pairs
    result in the creation of a row in this table as well as the
    creation of an associated row (with keys derived as indicated) in
    the usmUserTable.  The actual access the related usmSecurityName
    has is dependent on the entries in the VACM tables.  In general,
    an implementor will specify one or more standard security names
    and will provide entries in the VACM tables granting various
    levels of access to those names.  The actual content of the VACM
    table is beyond the scope of this MIB.

    Note: This table is expected to be readable without authentication
    using the usmUserSecurityName 'dhKickstart'.  See the conformance
    statements for details."))
(defoid |usmDHKickstartEntry| (|usmDHKickstartTable| 1)
  (:type 'object-type)
  (:syntax '|UsmDHKickstartEntry|)
  (:max-access '|not-accessible|)
  (:status '|current|)
  (:description
   "An entry in the usmDHKickstartTable.  The agent SHOULD either
    delete this entry or mark it as inactive upon a successful SET of
    any of the KeyChange-typed objects in the usmUserEntry or upon a
    successful SET of any of the DHKeyChange-typed objects in the
    usmDhKeyChangeEntry where the related usmSecurityName (e.g. row of
    usmUserTable or row of ushDhKeyChangeTable) equals this entry's
    usmDhKickstartSecurityName.  In otherwords, once you've changed
    one or more of the keys for a row in usmUserTable with a
    particular security name, the row in this table with that same
    security name is no longer useful or meaningful."))
(deftype |UsmDHKickstartEntry| () 't)
(defoid |usmDHKickstartIndex| (|usmDHKickstartEntry| 1)
  (:type 'object-type)
  (:syntax 't)
  (:max-access '|not-accessible|)
  (:status '|current|)
  (:description "Index value for this row."))
(defoid |usmDHKickstartMyPublic| (|usmDHKickstartEntry| 2)
  (:type 'object-type)
  (:syntax 't)
  (:max-access '|read-only|)
  (:status '|current|)
  (:description
   "The agent's Diffie-Hellman public value for this row.  At
    initialization, the agent generates a random number and derives
    its public value from that number.  This public value is published
    here.  This public value 'y' equals g^r MOD p where g is the from
    the set of Diffie-Hellman parameters, p is the prime from those
    parameters, and r is a random integer selected by the agent in the
    interval 2^(l-1) <= r < p-1 < 2^l.  If l is unspecified, then r is
    a random integer selected in the interval 0 <= r < p-1

    The public value is expressed as an OCTET STRING 'PV' of length
    'k' which satisfies

              k
        y =  SUM   2^(8(k-i)) PV'i
             i = 1

        where PV1,...,PVk are the octets of PV from first to last, and
        where PV1 != 0.


    The following DH parameters (Oakley group #2, RFC 2409, sec 6.1,
    6.2) are used for this object:

    g = 2
    p = FFFFFFFF FFFFFFFF C90FDAA2 2168C234 C4C6628B 80DC1CD1
        29024E08 8A67CC74 020BBEA6 3B139B22 514A0879 8E3404DD
        EF9519B3 CD3A431B 302B0A6D F25F1437 4FE1356D 6D51C245
        E485B576 625E7EC6 F44C42E9 A637ED6B 0BFF5CB6 F406B7ED
        EE386BFB 5A899FA5 AE9F2411 7C4B1FE6 49286651 ECE65381
        FFFFFFFF FFFFFFFF
    l=1024
    "))
(defoid |usmDHKickstartMgrPublic| (|usmDHKickstartEntry| 3)
  (:type 'object-type)
  (:syntax 't)
  (:max-access '|read-only|)
  (:status '|current|)
  (:description
   "The manager's Diffie-Hellman public value for this row.  Note
    that this value is not set via the SNMP agent, but may be set via
    some out of band method, such as the device's configuration file.
    The manager calculates this value in the same manner and using the
    same parameter set as the agent does.  E.g. it selects a random
    number 'r', calculates y = g^r mod p and provides 'y' as the
    public number expressed as an OCTET STRING.  See
    usmDHKickstartMyPublic for details.

    When this object is set with a valid value during initialization,
    a row is created in the usmUserTable with the following values:

    usmUserEngineID             localEngineID
    usmUserName                 [value of usmDHKickstartSecurityName]
    usmUserSecurityName         [value of usmDHKickstartSecurityName]
    usmUserCloneFrom            ZeroDotZero
    usmUserAuthProtocol         usmHMACMD5AuthProtocol
    usmUserAuthKeyChange        -- derived from set value
    usmUserOwnAuthKeyChange     -- derived from set value
    usmUserPrivProtocol         usmDESPrivProtocol
    usmUserPrivKeyChange        -- derived from set value
    usmUserOwnPrivKeyChange     -- derived from set value
    usmUserPublic               ''
    usmUserStorageType          permanent
    usmUserStatus               active

    A shared secret 'sk' is calculated at the agent as sk =
    mgrPublic^r mod p where r is the agents random number and p is the
    DH prime from the common parameters.  The underlying privacy key
    for this row is derived from sk by applying the key derivation
    function PBKDF2 defined in PKCS#5v2.0 with a salt of 0xd1310ba6,
    and iterationCount of 500, a keyLength of 16 (for
    usmDESPrivProtocol), and a prf (pseudo random function) of
    'id-hmacWithSHA1'.  The underlying authentication key for this row
    is derived from sk by applying the key derivation function PBKDF2
    with a salt of 0x98dfb5ac , an interation count of 500, a
    keyLength of 16 (for usmHMAC5AuthProtocol), and a prf of
    'id-hmacWithSHA1'.  Note: The salts are the first two words in the
    ks0 [key schedule 0] of the BLOWFISH cipher from 'Applied
    Cryptography' by Bruce Schnier - they could be any relatively
    random string of bits.

    The manager can use its knowledge of its own random number and the
    agent's public value to kickstart its access to the agent in a
    secure manner.  Note that the security of this approach is
    directly related to the strength of the authorization security of
    the out of band provisioning of the managers public value
    (e.g. the configuration file), but is not dependent at all on the
    strength of the confidentiality of the out of band provisioning
    data."))
(defoid |usmDHKickstartSecurityName| (|usmDHKickstartEntry| 4)
  (:type 'object-type)
  (:syntax '|SnmpAdminString|)
  (:max-access '|read-only|)
  (:status '|current|)
  (:description
   "The usmUserName and usmUserSecurityName in the usmUserTable
    associated with this row.  This is provided in the same manner and
    at the same time as the usmDHKickstartMgrPublic value -
    e.g. possibly manually, or via the device's configuration file."))
(defoid |usmDHKeyMIBCompliances| (|usmDHKeyConformance| 1)
  (:type 'object-identity))
(defoid |usmDHKeyMIBGroups| (|usmDHKeyConformance| 2)
  (:type 'object-identity))
(defoid |usmDHKeyMIBCompliance| (|usmDHKeyMIBCompliances| 1)
  (:type 'module-compliance)
  (:status '|current|)
  (:description "The compliance statement for this module."))
(defoid |usmDHKeyMIBBasicGroup| (|usmDHKeyMIBGroups| 1)
  (:type 'object-group)
  (:status '|current|)
  (:description ""))
(defoid |usmDHKeyParamGroup| (|usmDHKeyMIBGroups| 2)
  (:type 'object-group)
  (:status '|current|)
  (:description
   "The mandatory object for all MIBs which use the DHKeyChange
    textual convention."))
(defoid |usmDHKeyKickstartGroup| (|usmDHKeyMIBGroups| 3)
  (:type 'object-group)
  (:status '|current|)
  (:description
   "The objects used for kickstarting one or more SNMPv3 USM
    associations via a configuration file or other out of band,
    non-confidential access."))
