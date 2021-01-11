unit lmchdev;

interface

uses Windows, lmglobal;

const
//
//      Bits for chardev_info_1 field ch1_status.
//

  CHARDEV_STAT_OPENED             = $02;
  CHARDEV_STAT_ERROR              = $04;

//
//      Opcodes for NetCharDevControl
//

  CHARDEV_CLOSE                   = 0;

//
// Values for parm_err parameter.
//

  CHARDEVQ_DEV_PARMNUM        = 1;
  CHARDEVQ_PRIORITY_PARMNUM   = 2;
  CHARDEVQ_DEVS_PARMNUM       = 3;
  CHARDEVQ_NUMUSERS_PARMNUM   = 4;
  CHARDEVQ_NUMAHEAD_PARMNUM   = 5;

//
// Single-field infolevels for NetCharDevQSetInfo.
//

  CHARDEVQ_PRIORITY_INFOLEVEL = PARMNUM_BASE_INFOLEVEL + CHARDEVQ_PRIORITY_PARMNUM;
  CHARDEVQ_DEVS_INFOLEVEL     = PARMNUM_BASE_INFOLEVEL + CHARDEVQ_DEVS_PARMNUM;

//
//      Minimum, maximum, and recommended default for priority.
//

  CHARDEVQ_MAX_PRIORITY           = 1;
  CHARDEVQ_MIN_PRIORITY           = 9;
  CHARDEVQ_DEF_PRIORITY           = 5;

//
//      Value indicating no requests in the queue.
//

  CHARDEVQ_NO_REQUESTS            = -1;

//
//      Handle Get Info Levels
//

  HANDLE_INFO_LEVEL_1             = 1;

//
//      Handle Set Info parm numbers
//

  HANDLE_CHARTIME_PARMNUM         = 1;
  HANDLE_CHARCOUNT_PARMNUM        = 2;


type

//
// Data Structures - CharDev
//

  CHARDEV_INFO_0 = record
    ch0_dev : PWideChar;
  end;
  PCHARDEV_INFO_0 = ^CHARDEV_INFO_0;

  CHARDEV_INFO_1 = record
    ch1_dev : PWideChar;
    ch1_status : Integer;
    ch1_username : PWideChar;
    ch1_time : Integer;
  end;
  PCHARDEV_INFO_1 = ^CHARDEV_INFO_1;

//
// Data Structures - CharDevQ
//

  CHARDEVQ_INFO_0 = record
    cq0_dev : PWideChar;
  end;
  PCHARDEVQ_INFO_0 = ^CHARDEVQ_INFO_0;

  CHARDEVQ_INFO_1 = record
    cq1_dev : PWideChar;
    cq1_priority : Integer;
    cq1_devs : PWideChar;
    cq1_numusers : Integer;
    cq1_numahead : Integer;
  end;
  PCHARDEVQ_INFO_1 = ^CHARDEVQ_INFO_1;

  CHARDEVQ_INFO_1002 = record
    cq1002_priority : Integer;
  end;
  PCHARDEVQ_INFO_1002 = ^CHARDEVQ_INFO_1002;

  CHARDEVQ_INFO_1003 = record
    cq1003_devs : PWideChar;
  end;
  PCHARDEVQ_INFO_1003 = ^CHARDEVQ_INFO_1003;

  HANDLE_INFO_1 = record
    hdli1_chartime : Integer;
    hdli1_charcount : Integer;
  end;
  PHANDLE_INFO_1 = ^HANDLE_INFO_1;


function NetCharDevEnum (
  servername : PWideChar;
  level : Integer;
  var buffer : Pointer;
  prefMaxLen : Integer;
  var entriesRead, totalEntries, resumeHandle : Integer) : NetAPIStatus; stdcall;

function NetCharDevGetInfo (
  serverName : PWideChar;
  devname : PWideChar;
  level : Integer;
  var buffer : Pointer) : NetAPIStatus; stdcall;

function NetCharDevControl (
  serverName : PWideChar;
  devname : PWideChar;
  opcode : Integer) : NetAPIStatus; stdcall;


//
// Function Prototypes - CharDevQ
//

function NetCharDevQEnum (
  servername : PWideChar;
  username : PWideChar;
  level : Integer;
  var buffer : Pointer;
  prefMaxLen : Integer;
  var entriesread, totalEntries, resumeHandle : Integer) : NetAPIStatus; stdcall;

function NetCharDevQGetInfo (
  serverName : PWideChar;
  queueName : PWideChar;
  username : PWideChar;
  level : Integer;
  var buffer : Pointer) : NetAPIStatus; stdcall;

function NetCharDevQSetInfo (
  serverName : PWideChar;
  queueName : PWideChar;
  level : Integer;
  buffer : Pointer;
  var parm_err : Integer) : NetAPIStatus; stdcall;

function NetCharDevQPurge (
  serverName : PWideChar;
  queuename : PWideChar) : NetAPIStatus; stdcall;

function NetCharDevQPurgeSelf (
  serverName : PWideChar;
  queuename : PWideChar;
  computername : PWideChar) : NetAPIStatus; stdcall;

function NetHandleGetInfo (
  handle : THandle;
  level : Integer;
  var buffer : Pointer) : NetAPIStatus; stdcall;

function NetHandleSetInfo (
  handle : THandle;
  level : Integer;
  buffer : Pointer;
  parmnum : Integer;
  var parmerr : Integer) : NetAPIStatus; stdcall;

implementation

function NetCharDevEnum;        external 'NETAPI32.DLL';
function NetCharDevGetInfo;     external 'NETAPI32.DLL';
function NetCharDevControl;     external 'NETAPI32.DLL';
function NetCharDevQEnum;       external 'NETAPI32.DLL';
function NetCharDevQGetInfo;    external 'NETAPI32.DLL';
function NetCharDevQSetInfo;    external 'NETAPI32.DLL';
function NetCharDevQPurge;      external 'NETAPI32.DLL';
function NetCharDevQPurgeSelf;  external 'NETAPI32.DLL';
function NetHandleGetInfo;      external 'NETAPI32.DLL';
function NetHandleSetInfo;      external 'NETAPI32.DLL';
end.
