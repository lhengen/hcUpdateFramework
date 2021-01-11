unit SNMP;

{$WEAKPACKAGEUNIT}

interface

uses Windows;

const
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// ASN/BER Base Types                                                        //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

  ASN_UNIVERSAL                   = $00;
  ASN_APPLICATION                 = $40;
  ASN_CONTEXT                     = $80;
  ASN_PRIVATE                     = $C0;

  ASN_PRIMITIVE                   = $00;
  ASN_CONSTRUCTOR                 = $20;

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// PDU Type Values                                                           //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

  SNMP_PDU_GET                = (ASN_CONTEXT or ASN_CONSTRUCTOR or $0);
  SNMP_PDU_GETNEXT            = (ASN_CONTEXT or ASN_CONSTRUCTOR or $1);
  SNMP_PDU_RESPONSE           = (ASN_CONTEXT or ASN_CONSTRUCTOR or $2);
  SNMP_PDU_SET                = (ASN_CONTEXT or ASN_CONSTRUCTOR or $3);
  SNMP_PDU_V1TRAP             = (ASN_CONTEXT or ASN_CONSTRUCTOR or $4);
  SNMP_PDU_GETBULK            = (ASN_CONTEXT or ASN_CONSTRUCTOR or $5);
  SNMP_PDU_INFORM             = (ASN_CONTEXT or ASN_CONSTRUCTOR or $6);
  SNMP_PDU_TRAP               = (ASN_CONTEXT or ASN_CONSTRUCTOR or $7);

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// SNMP Simple Syntax Values                                                 //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

  ASN_INTEGER                 = (ASN_UNIVERSAL or ASN_PRIMITIVE or $02);
  ASN_BITS                    = (ASN_UNIVERSAL or ASN_PRIMITIVE or $03);
  ASN_OCTETSTRING             = (ASN_UNIVERSAL or ASN_PRIMITIVE or $04);
  ASN_NULL                    = (ASN_UNIVERSAL or ASN_PRIMITIVE or $05);
  ASN_OBJECTIDENTIFIER        = (ASN_UNIVERSAL or ASN_PRIMITIVE or $06);
  ASN_INTEGER32               = ASN_INTEGER;

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// SNMP Constructor Syntax Values                                            //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
                                
  ASN_SEQUENCE                = (ASN_UNIVERSAL or ASN_CONSTRUCTOR or $10);
  ASN_SEQUENCEOF              = ASN_SEQUENCE;

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// SNMP Application Syntax Values                                            //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

  ASN_IPADDRESS               = (ASN_APPLICATION or ASN_PRIMITIVE or $00);
  ASN_COUNTER32               = (ASN_APPLICATION or ASN_PRIMITIVE or $01);
  ASN_GAUGE32                 = (ASN_APPLICATION or ASN_PRIMITIVE or $02);
  ASN_TIMETICKS               = (ASN_APPLICATION or ASN_PRIMITIVE or $03);
  ASN_OPAQUE                  = (ASN_APPLICATION or ASN_PRIMITIVE or $04);
  ASN_COUNTER64               = (ASN_APPLICATION or ASN_PRIMITIVE or $06);
  ASN_UNSIGNED32              = (ASN_APPLICATION or ASN_PRIMITIVE or $07);

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// SNMP Exception Conditions                                                 //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

  SNMP_EXCEPTION_NOSUCHOBJECT     = (ASN_CONTEXT or ASN_PRIMITIVE or $00);
  SNMP_EXCEPTION_NOSUCHINSTANCE   = (ASN_CONTEXT or ASN_PRIMITIVE or $01);
  SNMP_EXCEPTION_ENDOFMIBVIEW     = (ASN_CONTEXT or ASN_PRIMITIVE or $02);

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// SNMP Request Types (used in SnmpExtensionQueryEx)                         //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

  SNMP_EXTENSION_GET          = SNMP_PDU_GET;
  SNMP_EXTENSION_GET_NEXT     = SNMP_PDU_GETNEXT;
  SNMP_EXTENSION_GET_BULK     = SNMP_PDU_GETBULK;
  SNMP_EXTENSION_SET_TEST     = (ASN_PRIVATE or ASN_CONSTRUCTOR or $0);
  SNMP_EXTENSION_SET_COMMIT   = SNMP_PDU_SET;
  SNMP_EXTENSION_SET_UNDO     = (ASN_PRIVATE or ASN_CONSTRUCTOR or $1);
  SNMP_EXTENSION_SET_CLEANUP  = (ASN_PRIVATE or ASN_CONSTRUCTOR or $2);

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// SNMP Error Codes                                                          //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

  SNMP_ERRORSTATUS_NOERROR                = 0;
  SNMP_ERRORSTATUS_TOOBIG                 = 1;
  SNMP_ERRORSTATUS_NOSUCHNAME             = 2;
  SNMP_ERRORSTATUS_BADVALUE               = 3;
  SNMP_ERRORSTATUS_READONLY               = 4;
  SNMP_ERRORSTATUS_GENERR                 = 5;
  SNMP_ERRORSTATUS_NOACCESS               = 6;
  SNMP_ERRORSTATUS_WRONGTYPE              = 7;
  SNMP_ERRORSTATUS_WRONGLENGTH            = 8;
  SNMP_ERRORSTATUS_WRONGENCODING          = 9;
  SNMP_ERRORSTATUS_WRONGVALUE             = 10;
  SNMP_ERRORSTATUS_NOCREATION             = 11;
  SNMP_ERRORSTATUS_INCONSISTENTVALUE      = 12;
  SNMP_ERRORSTATUS_RESOURCEUNAVAILABLE    = 13;
  SNMP_ERRORSTATUS_COMMITFAILED           = 14;
  SNMP_ERRORSTATUS_UNDOFAILED             = 15;
  SNMP_ERRORSTATUS_AUTHORIZATIONERROR     = 16;
  SNMP_ERRORSTATUS_NOTWRITABLE            = 17;
  SNMP_ERRORSTATUS_INCONSISTENTNAME       = 18;

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// SNMPv1 Trap Types                                                         //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

  SNMP_GENERICTRAP_COLDSTART              = 0;
  SNMP_GENERICTRAP_WARMSTART              = 1;
  SNMP_GENERICTRAP_LINKDOWN               = 2;
  SNMP_GENERICTRAP_LINKUP                 = 3;
  SNMP_GENERICTRAP_AUTHFAILURE            = 4;
  SNMP_GENERICTRAP_EGPNEIGHLOSS           = 5;
  SNMP_GENERICTRAP_ENTERSPECIFIC          = 6;

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// SNMP Access Types                                                         //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

  SNMP_ACCESS_NONE                        = 0;
  SNMP_ACCESS_NOTIFY                      = 1;
  SNMP_ACCESS_READ_ONLY                   = 2;
  SNMP_ACCESS_READ_WRITE                  = 3;
  SNMP_ACCESS_READ_CREATE                 = 4;

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// SNMP API Return Code Definitions                                          //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////


  SNMPAPI_NOERROR                         = TRUE;
  SNMPAPI_ERROR                           = FALSE;

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// SNMP Debugging Definitions                                                //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

  SNMP_LOG_SILENT                 = $0;
  SNMP_LOG_FATAL                  = $1;
  SNMP_LOG_ERROR                  = $2;
  SNMP_LOG_WARNING                = $3;
  SNMP_LOG_TRACE                  = $4;
  SNMP_LOG_VERBOSE                = $5;

  SNMP_OUTPUT_TO_CONSOLE          = $1;
  SNMP_OUTPUT_TO_LOGFILE          = $2;
  SNMP_OUTPUT_TO_EVENTLOG         = $4;  // no longer supported
  SNMP_OUTPUT_TO_DEBUGGER         = $8;

type
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// SNMP Type Definitions                                                     //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

// #pragma pack (4)

  SNMPAPI = Integer;

AsnOctetString = record
  stream : PBYTE;
  length : UINT;
  dynamic : BOOL;
end;
PAsnOctetString = ^AsnOctetString;


AsnObjectIdentifier = record
  idLength : UINT;
  ids : PUINT;
end;
PAsnObjectIdentifier = ^AsnObjectIdentifier;

AsnInteger32 = LongInt;
AsnUnsigned32 = ULONG;
AsnCounter64 = ULARGE_INTEGER;
AsnCounter32 = AsnUnsigned32;
AsnGauge32 = AsnUnsigned32;
AsnTimeticks = AsnUnsigned32;
AsnBits = AsnOctetString;
AsnSequence = AsnOctetString;
AsnImplicitSequence = AsnOctetString;
AsnIPAddress = AsnOctetString;
AsnNetworkAddress = AsnOctetString;
AsnDisplayString = AsnOctetString;
AsnOpaque = AsnOctetString;
AsnInteger = AsnInteger32;

AsnAny = record case asnType : BYTE of
  0 : (number : AsnInteger32);
  1 : (unsigned32 : AsnUnsigned32);
  2 : (counter64 : AsnCounter64);
  3 : (_string : AsnOctetString);
  4 : (bits : AsnBits);
  5 : (_object : AsnObjectIdentifier);
  6 : (sequence : AsnSequence);
  7 : (address : AsnIPAddress);
  8 : (counter : AsnCounter32);
  9 : (guage : AsnGauge32);
  10: (ticks : AsnTimeticks);
  11: (arbitrary : AsnOpaque)
end;
PAsnAny = ^AsnAny;

AsnObjectName = AsnObjectIdentifier;
AsnObjectSyntax = AsnAny;

SnmpVarBind = record
  name : AsnObjectName;
  value : AsnObjectSyntax;
end;
PSnmpVarBind = ^SnmpVarBind;

SnmpVarBindList = record
  list : PSnmpVarBind;
  len : UINT;
end;
PSnmpVarBindList = ^SnmpVarBindList;

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// SNMP Extension API Type Definitions                                       //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

PFNSNMPEXTENSIONINIT = function (
    dwUpTimeReference : DWORD;
    var phSubagentTrapEvent : THandle;
    var pFirstSupportedRegion : AsnObjectIdentifier) : BOOL; stdcall;

PFNSNMPEXTENSIONINITEX = function (
    var pNextSupportedRegion : AsnObjectIdentifier) : BOOL; stdcall;

PFNSNMPEXTENSIONQUERY = function (
    bPduType : BYTE;
    var pVarBindList : SnmpVarBindList;
    var pErrorStatus : AsnInteger32;
    var pErrorIndex : AsnInteger32) : BOOL; stdcall;

PFNSNMPEXTENSIONQUERYEX = function (
    nRequestType : UINT;
    nTransactionId : UINT;
    var pVarBindList : SnmpVarBindList;
    var pContextInfo : AsnOctetString;
    var pErrorStatus : AsnInteger32;
    var pErrorIndex : AsnInteger32) : BOOL; stdcall;

PFNSNMPEXTENSIONTRAP = function (
    var pEnterpriseOld : AsnObjectIdentifier;
    var pGenerticTrapId : AsnInteger32;
    var pSpecificTrapId : AsnInteger32;
    var pTimeStamp : AsnTimeticks;
    var pVarBindList : SnmpVarBindList) : BOOL; stdcall;

PFNSNMPEXTENSIONCLOSE = procedure; stdcall;

const
///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// Miscellaneous definitions                                                 //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

  DEFAULT_SNMP_PORT_UDP       = 161;
  DEFAULT_SNMP_PORT_IPX       = 36879;
  DEFAULT_SNMPTRAP_PORT_UDP   = 162;
  DEFAULT_SNMPTRAP_PORT_IPX   = 36880;

  SNMP_MAX_OID_LEN            = 128;

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// API Error Code Definitions                                                //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

  SNMP_MEM_ALLOC_ERROR            = 1;
  SNMP_BERAPI_INVALID_LENGTH      = 10;
  SNMP_BERAPI_INVALID_TAG         = 11;
  SNMP_BERAPI_OVERFLOW            = 12;
  SNMP_BERAPI_SHORT_BUFFER        = 13;
  SNMP_BERAPI_INVALID_OBJELEM     = 14;
  SNMP_PDUAPI_UNRECOGNIZED_PDU    = 20;
  SNMP_PDUAPI_INVALID_ES          = 21;
  SNMP_PDUAPI_INVALID_GT          = 22;
  SNMP_AUTHAPI_INVALID_VERSION    = 30;
  SNMP_AUTHAPI_INVALID_MSG_TYPE   = 31;
  SNMP_AUTHAPI_TRIV_AUTH_FAILED   = 32;

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// SNMP Extension API Prototypes                                             //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

function SnmpExtensionInit(
    dwUptimeReference : DWORD;
    var phSubagentTrapEvent : THandle;
    var pFirstSupportedRegion : AsnObjectIdentifier) : BOOL; stdcall;

function SnmpExtensionInitEx(
    var pNextSupportedRegion : AsnObjectIdentifier) : BOOL; stdcall;

function SnmpExtensionQuery(
    bPduType : BYTE;
    var pVarBindList : SnmpVarBindList;
    var pErrorStatus : AsnInteger32;
    var pErrorIndex : AsnInteger32) : BOOL; stdcall;

function SnmpExtensionQueryEx(
    nRequestType : UINT;
    nTransactionId : UINT;
    var pVarBindList : SnmpVarBindList;
    var pContextInfo : AsnOctetString;
    var pErrorStatus : AsnInteger32;
    var pErrorIndex : AsnInteger32) : BOOL; stdcall;

function SnmpExtensionTrap(
    var pEnterpriseOid : AsnObjectIdentifier;
    var pGenericTrapId : AsnInteger32;
    var pSpecificTrapId : AsnInteger32;
    var pTimestamp : AsnTimeticks;
    var pVarBindList : SnmpVarBindList) : BOOL; stdcall;

procedure SnmpExtensionClose; stdcall;

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// SNMP API Prototypes                                                       //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

function SnmpUtilOidCpy(
    var pOidDst : AsnObjectIdentifier;
    var pOidSrc : AsnObjectIdentifier) : SNMPAPI; stdcall;

function SnmpUtilOidAppend(
    var pOidDst : AsnObjectIdentifier;
    var pOidSrc : AsnObjectIdentifier) : SNMPAPI; stdcall;

function SnmpUtilOidNCmp(
    var pOid1 : AsnObjectIdentifier;
    var pOid2 : AsnObjectIdentifier;
    nSubIds : UINT) : SNMPAPI; stdcall;

function SnmpUtilOidCmp(
    var pOid1 : AsnObjectIdentifier;
    var pOid2 : AsnObjectIdentifier) : SNMPAPI; stdcall;

procedure SnmpUtilOidFree(var pOid : AsnObjectIdentifier); stdcall;

function SnmpUtilOctetsCmp(
    var pOctets1 : AsnOctetString;
    var pOctets2 : AsnOctetString) : SNMPAPI; stdcall;

function SnmpUtilOctetsNCmp(
    var pOctets1 : AsnOctetString;
    var pOctets2 : AsnOctetString;
    nChars : UINT) : SNMPAPI; stdcall;

function SnmpUtilOctetsCpy(
    var pOctetsDst : AsnOctetString;
    var pOctetsSrc : AsnOctetString) : SNMPAPI; stdcall;

procedure SnmpUtilOctetsFree(
    var pOctets : AsnOctetString
    ); stdcall;

function SnmpUtilAsnAnyCpy(
    var pAnyDst : AsnAny;
    var pAnySrc : AsnAny) : SNMPAPI; stdcall;

procedure SnmpUtilAsnAnyFree(
    var pAny : AsnAny); stdcall;

function SnmpUtilVarBindCpy(
    var pVbDst : SnmpVarBind;
    var pVbSrc : SnmpVarBind) : SNMPAPI; stdcall;

procedure SnmpUtilVarBindFree(
    var pVb : SnmpVarBind
    ); stdcall;

function SnmpUtilVarBindListCpy(
    var pVblDst : SnmpVarBindList;
    var pVblSrc : SnmpVarBindList) : SNMPAPI; stdcall;

procedure SnmpUtilVarBindListFree(
    var pVbl : SnmpVarBindList); stdcall;

procedure SnmpUtilMemFree(pMem : pointer); stdcall;

function SnmpUtilMemAlloc(nBytes : UINT) : pointer; stdcall;

function SnmpUtilMemReAlloc(pMem : pointer; nBytes : UINT) : pointer; stdcall;

function SnmpUtilOidToA(var Oid : AsnObjectIdentifier) : PChar; stdcall;

function SnmpUtilIdsToA(Ids : PUINT; idLength : UINT) : PChar; stdcall;

procedure SnmpUtilPrintOid(var Oid : AsnObjectIdentifier); stdcall;

procedure SnmpUtilPrintAsnAny(var pAny : AsnAny); stdcall;

function SnmpSvcGetUptime : DWORD; stdcall;

procedure SnmpSvcSetLogLevel (nLogLevel : Integer); stdcall;

procedure SnmpSvcSetLogType (nLogType : Integer); stdcall;

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// SNMP Debugging Prototypes                                                 //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

procedure SnmpUtilDbgPrint(
    LogLevel : Integer;
    szFormat : PChar); stdcall;       // Matches the docs, but not snmp.h


implementation

const snmpapidll = 'snmpapi.dll';

function SnmpExtensionInit; external snmpapidll;
function SnmpExtensionInitEx; external snmpapidll;
function SnmpExtensionQuery; external snmpapidll;
function SnmpExtensionQueryEx; external snmpapidll;
function SnmpExtensionTrap; external snmpapidll;
procedure SnmpExtensionClose; external snmpapidll;
function SnmpUtilOidCpy; external snmpapidll;
function SnmpUtilOidAppend; external snmpapidll;
function SnmpUtilOidNCmp; external snmpapidll;
function SnmpUtilOidCmp; external snmpapidll;
procedure SnmpUtilOidFree; external snmpapidll;
function SnmpUtilOctetsCmp; external snmpapidll;
function SnmpUtilOctetsNCmp; external snmpapidll;
function SnmpUtilOctetsCpy; external snmpapidll;
procedure SnmpUtilOctetsFree; external snmpapidll;
function SnmpUtilAsnAnyCpy; external snmpapidll;
procedure SnmpUtilAsnAnyFree; external snmpapidll;
function SnmpUtilVarBindCpy; external snmpapidll;
procedure SnmpUtilVarBindFree; external snmpapidll;
function SnmpUtilVarBindListCpy; external snmpapidll;
procedure SnmpUtilVarBindListFree; external snmpapidll;
procedure SnmpUtilMemFree; external snmpapidll;
function SnmpUtilMemAlloc; external snmpapidll;
function SnmpUtilMemReAlloc; external snmpapidll;
function SnmpUtilOidToA; external snmpapidll;
function SnmpUtilIdsToA; external snmpapidll;
procedure SnmpUtilPrintOid; external snmpapidll;
procedure SnmpUtilPrintAsnAny; external snmpapidll;
function SnmpSvcGetUptime; external snmpapidll;
procedure SnmpSvcSetLogLevel; external snmpapidll;
procedure SnmpSvcSetLogType; external snmpapidll;
procedure SnmpUtilDbgPrint; external snmpapidll;
end.
