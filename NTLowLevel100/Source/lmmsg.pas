unit lmmsg;

interface

uses lmglobal;

const
//
// Values for msgi1_forward_flag.
//

   MSGNAME_NOT_FORWARDED   = 0;      // Name not forwarded
   MSGNAME_FORWARDED_TO    = $04;    // Name forward to remote station
   MSGNAME_FORWARDED_FROM  = $10;    // Name forwarded from remote station

type

  MSG_INFO_0 = record
    msgi0_name : PWideChar;
  end;
  PMSG_INFO_0 = ^MSG_INFO_0;

  MSG_INFO_1 = record
    msgi1_name : PWideChar;
    msgi1_forward_flag : Integer;
    msgi1_forward : PWideChar;
  end;
  PMSG_INFO_1 = ^MSG_INFO_1;


function NetMessageNameAdd (
  serverName, msgName : PWideChar) : NetAPIStatus; stdcall;

function NetMessageNameEnum (
  serverName : PWideChar;
  level : Integer;
  var buffer : Pointer;
  prefMaxLen : Integer;
  var entriesRead, totalEntries, resumeHandle : Integer) : NetAPIStatus; stdcall;

function NetMessageNameGetInfo (
  servername, msgname : PWideChar;
  level : Integer;
  var buffer : Pointer) : NetAPIStatus; stdcall;

function NetMessageNameDel (
  serverName, msgName : PWideChar) : NetAPIStatus; stdcall;

function NetMessageBufferSend (
  serverName, msgName, fromName : PWideChar;
  buf : Pointer;
  bufLen : Integer) : NetAPIStatus; stdcall;

implementation

function NetMessageNameAdd;         external 'NETAPI32.DLL';
function NetMessageNameEnum;        external 'NETAPI32.DLL';
function NetMessageNameGetInfo;     external 'NETAPI32.DLL';
function NetMessageNameDel;         external 'NETAPI32.DLL';
function NetMessageBufferSend;      external 'NETAPI32.DLL';
end.
