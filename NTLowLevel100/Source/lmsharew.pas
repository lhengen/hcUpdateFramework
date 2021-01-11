//------------------------------------------------------------------------
// lmsharew units
//
// Lan Manager share function interfaces
//
// Translated to Delphi by Colin Wilson.  Translation copyright (c) Colin
// Wilson 2002.  All rights reserved.

unit lmsharew;

interface

uses lmglobal, windows;

const
  SHARE_NETNAME_PARMNUM         = 1;
  SHARE_TYPE_PARMNUM            = 3;
  SHARE_REMARK_PARMNUM          = 4;
  SHARE_PERMISSIONS_PARMNUM     = 5;
  SHARE_MAX_USES_PARMNUM        = 6;
  SHARE_CURRENT_USES_PARMNUM    = 7;
  SHARE_PATH_PARMNUM            = 8;
  SHARE_PASSWD_PARMNUM          = 9;
  SHARE_FILE_SD_PARMNUM       = 501;

//
// Single-field infolevels for NetShareSetInfo.
//

  SHARE_REMARK_INFOLEVEL   = PARMNUM_BASE_INFOLEVEL + SHARE_REMARK_PARMNUM;
  SHARE_MAX_USES_INFOLEVEL = PARMNUM_BASE_INFOLEVEL + SHARE_MAX_USES_PARMNUM;
  SHARE_FILE_SD_INFOLEVEL  = PARMNUM_BASE_INFOLEVEL + SHARE_FILE_SD_PARMNUM;

  SHI1_NUM_ELEMENTS       = 4;
  SHI2_NUM_ELEMENTS       = 10;

//
// Share types (shi1_type and shi2_type fields).
//

  STYPE_DISKTREE          =0;
  STYPE_PRINTQ            =1;
  STYPE_DEVICE            =2;
  STYPE_IPC               =3;

  STYPE_SPECIAL           = $80000000;

  SHI_USES_UNLIMITED      = -1;

//
// Flags values for the 1005 infolevel
//
  SHI1005_FLAGS_DFS  = $01;        // Share is in the DFS

//
// Special Values and Constants - Session
//


//
// Bits defined in sesi1_user_flags.
//

  SESS_GUEST          = $00000001;  // session is logged on as a guest
  SESS_NOENCRYPTION   = $00000002;  // session is not using encryption

  SESI1_NUM_ELEMENTS  = 8;
  SESI2_NUM_ELEMENTS  = 9;

//
// Special Values and Constants - File
//

//
// bit values for permissions
//

  PERM_FILE_READ      = $1; // user has read access
  PERM_FILE_WRITE     = $2; // user has write access
  PERM_FILE_CREATE    = $4; // user has create access

//
// Data Structures - Share
//

type

SHARE_INFO_0 = record
  shi0_netname : PWideChar;
end;
PSHARE_INFO_0= ^SHARE_INFO_0;

SHARE_INFO_1 = record
  shi1_netname : PWideChar;
  shi1_type : Integer;
  shi1_remark : PWideChar;
end;
PSHARE_INFO_1= ^SHARE_INFO_1;

SHARE_INFO_2 = record
  shi2_netname : PWideChar;
  shi2_type : Integer;
  shi2_remark : PWideChar;
  shi2_permissions : Integer;
  shi2_max_uses : Integer;
  shi2_current_uses : Integer;
  shi2_path : PWideChar;
  shi2_passwd : PWideChar;
end;
PSHARE_INFO_2= ^SHARE_INFO_2;

SHARE_INFO_502 = record
  shi502_netname : PWideChar;
  shi502_type : Integer;
  shi502_remark : PWideChar;
  shi502_permissions : Integer;
  shi502_max_uses : Integer;
  shi502_current_uses : Integer;
  shi502_path : PWideChar;
  shi502_passwd : PWideChar;
  shi502_reserved : Integer;
  shi502_security_descriptor : PSECURITY_DESCRIPTOR;
end;
PSHARE_INFO_502= ^SHARE_INFO_502;

SHARE_INFO_1004 = record
  shi1004_remark : PWideChar;
end;
PSHARE_INFO_1004= ^SHARE_INFO_1004;

SHARE_INFO_1005 = record
  shi1005_flags : Integer;
end;
PSHARE_INFO_1005= ^SHARE_INFO_1005;


SHARE_INFO_1006 = record
  shi1006_max_uses : Integer;
end;
PSHARE_INFO_1006 = ^SHARE_INFO_1006;

SHARE_INFO_1501 = record
  shi1501_reserved : Integer;
  shi1501_security_descriptor : PSECURITY_DESCRIPTOR;
end;
PSHARE_INFO_1501= ^SHARE_INFO_1501;


//
// Data Structures - Session
//

SESSION_INFO_0 = record
  sesi0_cname : PWideChar;              // client name (no backslashes)
end;
PSESSION_INFO_0 = ^SESSION_INFO_0;

SESSION_INFO_1 = record
  sesi1_cname : PWideChar;              // client name (no backslashes)
  sesi1_username : PWideChar;
  sesi1_num_opens : Integer;
  sesi1_time : Integer;
  sesi1_idle_time : Integer;
  sesi1_user_flags : Integer;
end;
PSESSION_INFO_1 = ^SESSION_INFO_1;

SESSION_INFO_2 = record
  sesi2_cname : PWideChar;              // client name (no backslashes)
  sesi2_username : PWideChar;
  sesi2_num_opens : Integer;
  sesi2_time : Integer;
  sesi2_idle_time : Integer;
  sesi2_user_flags : Integer;
  sesi2_cltype_name : PWideChar;
end;
PSESSION_INFO_2 = ^SESSION_INFO_2;

SESSION_INFO_10 = record
  sesi10_cname : PWideChar;             // client name (no backslashes)
  sesi10_username : PWideChar;
  sesi10_time : Integer;
  sesi10_idle_time : Integer;
end;
PSESSION_INFO_10 = ^SESSION_INFO_10;

SESSION_INFO_502 = record
  sesi502_cname : PWideChar;             // client name (no backslashes)
  sesi502_username : PWideChar;
  sesi502_num_opens : Integer;
  sesi502_time : Integer;
  sesi502_idle_time : Integer;
  sesi502_user_flags : Integer;
  sesi502_cltype_name : PWideChar;
  sesi502_transport : PWideChar;
end;
PSESSION_INFO_502= ^SESSION_INFO_502;


//
// Data Structures - CONNECTION
//

CONNECTION_INFO_0 = record
  coni0_id : Integer;
end;
PCONNECTION_INFO_0 = ^CONNECTION_INFO_0;

CONNECTION_INFO_1 = record
  coni1_id : Integer;
  coni1_type : Integer;
  coni1_num_opens : Integer;
  coni1_num_users : Integer;
  coni1_time : Integer;
  coni1_username : PWideChar;
  coni1_netname : PWideChar;
end;
PCONNECTION_INFO_1 = ^CONNECTION_INFO_1;

//
// Data Structures - File
//

//  File APIs are available at information levels 2 & 3 only. Levels 0 &
//  1 are not supported.
//

FILE_INFO_2 = record
  fi2_id : Integer;
end;
PFILE_INFO_2 = ^FILE_INFO_2;

FILE_INFO_3 = record
  fi3_id : Integer;
  fi3_permissions : Integer;
  fi3_num_locks : Integer;
  fi3_pathname : PWideChar;
  fi3_username : PWideChar;
end;
PFILE_INFO_3 = ^FILE_INFO_3;

//
// Function Prototypes - Share
//

function NetShareAdd (
  serverName : PWideChar;
  level : Integer;
  buf : PWideChar;
  var parm_err : Integer
) : NetAPIStatus; stdcall;

function NetShareEnum (
  serverName : PWideChar;
  level : Integer;
  var bufptr : Pointer;
  prefmaxlen : Integer;
  var  entriesRead, totalEntries : DWORD; resumeHandle : PDWORD
) : NetAPIStatus; stdcall;

function NetShareEnumSticky (
  serverName : PWideChar;
  level : Integer;
  var bufPtr : PWideChar;
  prefmaxlen : Integer;
  var entriesRead, totalEntries, resumeHandle : Integer
) : NetAPIStatus; stdcall;

function NetShareGetInfo (
  serverName, netName : PWideChar;
  level : Integer;
  var buf : PWideChar
) : NetAPIStatus; stdcall;

function NetShareSetInfo (
  serverName, netName : PWideChar;
  level : Integer;
  buf : PWideChar;
  var parm_err : Integer
) : NetAPIStatus; stdcall;

function NetShareDel     (
  serverName, netName : PWideChar;
  reserved : Integer
) : NetAPIStatus; stdcall;

function NetShareDelSticky (
  serverName, netName : PWideChar;
  reserved : Integer
) : NetAPIStatus; stdcall;

function NetShareCheck   (
  serverName, device : PWideChar;
  var tp : Integer
) : NetAPIStatus; stdcall;

//
// Function Prototypes Session
//

function NetSessionEnum (
  serverName, UncClientName, username : PWideChar;
  level : Integer;
  var bufPtr : PWideChar;
  prefmaxlen : Integer;
  var entriesread, totalEntries, resumeHandle : Integer
) : NetAPIStatus; stdcall;

function NetSessionDel (
  serverName, UncClientName, username : PWideChar
) : NetAPIStatus; stdcall;

function NetSessionGetInfo (
  serverName, UncClientName, username : PWideChar;
  level : Integer;
  var buf : PWideChar
) : NetAPIStatus; stdcall;

function NetConnectionEnum (
  serverName, qualifier : PWideChar;
  level : Integer;
  var bufPtr : PWideChar;
  prefmaxlen : Integer;
  var entriesread, totalentries, resumehandle : Integer
) : NetAPIStatus; stdcall;

//
// Function Prototypes - FILE
//

function NetFileClose (
  serverName : PWideChar;
  fileid : Integer
) : NetAPIStatus; stdcall;

function NetFileEnum (
  serverName, basePath, userName : PWideChar;
  level : Integer;
  var bufPtr : PWideChar;
  prefmaxlen : Integer;
  var entriesread, totalentries, resumeHandle : Integer
) : NetAPIStatus; stdcall;

function NetFileGetInfo (
  serverName : PWideChar;
  fileid : Integer;
  level : Integer;
  var bufPtr : PWideChar
) : NetAPIStatus; stdcall;

implementation

function NetShareAdd;        external 'NETAPI32.DLL';
function NetShareEnum;       external 'NETAPI32.DLL';
function NetShareEnumSticky; external 'NETAPI32.DLL';
function NetShareGetInfo;    external 'NETAPI32.DLL';
function NetShareSetInfo;    external 'NETAPI32.DLL';
function NetShareDel;        external 'NETAPI32.DLL';
function NetShareDelSticky;  external 'NETAPI32.DLL';
function NetShareCheck;      external 'NETAPI32.DLL';
function NetSessionEnum;     external 'NETAPI32.DLL';
function NetSessionDel;      external 'NETAPI32.DLL';
function NetSessionGetInfo;  external 'NETAPI32.DLL';
function NetConnectionEnum;  external 'NETAPI32.DLL';
function NetFileClose;       external 'NETAPI32.DLL';
function NetFileEnum;        external 'NETAPI32.DLL';
function NetFileGetInfo;     external 'NETAPI32.DLL';
end.

