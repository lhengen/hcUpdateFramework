unit mgmtapi;

{$WEAKPACKAGEUNIT}

interface

uses Windows, snmp;

const
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// MGMT API error code definitions                                           //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

  SNMP_MGMTAPI_TIMEOUT                = 40;
  SNMP_MGMTAPI_SELECT_FDERRORS        = 41;
  SNMP_MGMTAPI_TRAP_ERRORS            = 42;
  SNMP_MGMTAPI_TRAP_DUPINIT           = 43;
  SNMP_MGMTAPI_NOTRAPS                = 44;
  SNMP_MGMTAPI_AGAIN                  = 45;

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// MGMT API type definitions                                                 //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

type
  LPSNMP_MGR_SESSION = pointer;

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// MGMT API prototypes                                                       //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

function SnmpMgrOpen(
    lpAgentAddress : PChar;               // Name/address of target agent
    lpAgentCommunity : PChar;             // Community for target agent
    nTimeOut : Integer;                   // Comm time-out in milliseconds
    nRetries : Integer                    // Comm time-out/retry count
    ) : LPSNMP_MGR_SESSION; stdcall;

function SnmpMgrClose(
    session : LPSNMP_MGR_SESSION          // SNMP session pointer
    ) : BOOL; stdcall;

function  SnmpMgrRequest(
    session : LPSNMP_MGR_SESSION;           // SNMP session pointer
    resuestType : BYTE;                     // Get, GetNext, or Set
    var variableBindings : SnmpVarBindList; // Varible bindings
    var errorStatus : AsnInteger;           // Result error status
    var errorIndex : AsnInteger             // Result error index
    ) : SNMPAPI; stdcall;

function SnmpMgrStrToOid(
    st : PChar;         // OID string to be converted
    var oid : AsnObjectIdentifier
    ) : BOOL; stdcall;

function SnmpMgrOidToStr(
    var oid : AsnObjectIdentifier;          // OID to be converted
    var st : PChar                          // OID string representation
    ) : BOOL; stdcall;

function SnmpMgrTrapListen(
    var phTrapAvailable : THandle             // Event indicating trap available
    ) : BOOL; stdcall;

function SnmpMgrGetTrap(
    var enterprise : AsnObjectIdentifier;        // Generating enterprise
    var IPAddress : AsnNetworkAddress;           // Generating IP address
    var genericTrap : AsnInteger;                // Generic trap type
    var specificTrap : AsnInteger;               // Enterprise specific type
    var timeStamp : AsnTimeticks;                // Time stamp
    var varibleBindings : SnmpVarBindList        // Variable bindings
    ) : BOOL; stdcall;

function SnmpMgrGetTrapEx(
    var enterprise : AsnObjectIdentifier;        // Generating enterprise
    var agentAddress : AsnNetworkAddress;        // Generating agent addr
    var sourceAddress : AsnNetworkAddress;       // Generating network addr
    var genericTrap : AsnInteger;                // Generic trap type
    var specificTrap : AsnInteger;               // Enterprise specific type
    var community : AsnOctetString;              // Generating community
    var timeStamp : AsnTimeticks;                // Time stamp
    var varibleBindings : SnmpVarBindList        // Variable bindings
    ) : BOOL; stdcall;

implementation

const mgmtapidll = 'mgmtapi.dll';

function SnmpMgrOpen; external mgmtapidll;
function SnmpMgrClose; external mgmtapidll;
function SnmpMgrRequest; external mgmtapidll;
function SnmpMgrStrToOid; external mgmtapidll;
function SnmpMgrOidToStr; external mgmtapidll;
function SnmpMgrTrapListen; external mgmtapidll;
function SnmpMgrGetTrap; external mgmtapidll;
function SnmpMgrGetTrapEx; external mgmtapidll;

end.
