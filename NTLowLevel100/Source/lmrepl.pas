unit lmrepl;

interface

uses lmglobal;

//
// Replicator Configuration APIs
//
const

 REPL_ROLE_EXPORT        = 1;
 REPL_ROLE_IMPORT        = 2;
 REPL_ROLE_BOTH          = 3;


 REPL_INTERVAL_INFOLEVEL  = PARMNUM_BASE_INFOLEVEL + 0;
 REPL_PULSE_INFOLEVEL     = PARMNUM_BASE_INFOLEVEL + 1;
 REPL_GUARDTIME_INFOLEVEL = PARMNUM_BASE_INFOLEVEL + 2;
 REPL_RANDOM_INFOLEVEL    = PARMNUM_BASE_INFOLEVEL + 3;

 REPL_STATE_OK               = 0;
 REPL_STATE_NO_MASTER        = 1;
 REPL_STATE_NO_SYNC          = 2;
 REPL_STATE_NEVER_REPLICATED = 3;

//
// Replicator Export Directory APIs
//

 REPL_INTEGRITY_FILE     = 1;
 REPL_INTEGRITY_TREE     = 2;


 REPL_EXTENT_FILE        = 1;
 REPL_EXTENT_TREE        = 2;


 REPL_EXPORT_INTEGRITY_INFOLEVEL = PARMNUM_BASE_INFOLEVEL + 0;
 REPL_EXPORT_EXTENT_INFOLEVEL    = PARMNUM_BASE_INFOLEVEL + 1;

 REPL_UNLOCK_NOFORCE     = 0;
 REPL_UNLOCK_FORCE       = 1;

type
REPL_INFO_0  = record
  rp0_role : Integer;
  rp0_exportpath : PWideChar;
  rp0_exportlist : PWideChar;
  rp0_importpath : PWideChar;
  rp0_importlist : PWideChar;
  rp0_logonusername : PWideChar;
  rp0_interval : Integer;
  rp0_pulse : Integer;
  rp0_guardtime : Integer;
  rp0_random : Integer;
end;
PREPL_INFO_0 = ^REPL_INFO_0;

REPL_INFO_1000 = record
  rp1000_interval : Integer;
end;
PREPL_INFO_1000 = ^REPL_INFO_1000;

REPL_INFO_1001 = record
  rp1001_pulse : Integer;
end;
PREPL_INFO_1001 = ^REPL_INFO_1001;

REPL_INFO_1002 = record
  rp1002_guardtime : Integer;
end;
PREPL_INFO_1002 = ^REPL_INFO_1002;

REPL_INFO_1003 = record
  rp1003_random : Integer;
end;
PREPL_INFO_1003= ^REPL_INFO_1003;

REPL_EDIR_INFO_0 = record
  rped0_dirname : PWideChar;
end;
PREPL_EDIR_INFO_0 = ^REPL_EDIR_INFO_0;

REPL_EDIR_INFO_1 = record
  rped1_dirname : PWideChar;
  rped1_integrity : Integer;
  rped1_extent : Integer;
end;
PREPL_EDIR_INFO_1 = ^REPL_EDIR_INFO_1;

REPL_EDIR_INFO_2 = record
  rped2_dirname : PWideChar;
  rped2_integrity : Integer;
  rped2_extent : Integer;
  rped2_lockcount : Integer;
  rped2_locktime : Integer;
end;
PREPL_EDIR_INFO_2 = REPL_EDIR_INFO_2;

REPL_EDIR_INFO_1000 = record
  rped1000_integrity : Integer;
end;
PREPL_EDIR_INFO_1000 = ^REPL_EDIR_INFO_1000;

REPL_EDIR_INFO_1001 = record
  rped1001_extent : Integer;
end;
PREPL_EDIR_INFO_1001 = ^REPL_EDIR_INFO_1001;

REPL_IDIR_INFO_0 = record
  rpid0_dirname : PWideChar;
end;
PREPL_IDIR_INFO_0 = ^REPL_IDIR_INFO_0;

REPL_IDIR_INFO_1 = record
  rpid1_dirname : PWideChar;
  rpid1_state : Integer;
  rpid1_mastername : PWideChar;
  rpid1_last_update_time : Integer;
  rpid1_lockcount : Integer;
  rpid1_locktime : Integer;
end;
PREPL_IDIR_INFO_1 = ^REPL_IDIR_INFO_1;

function NetReplGetInfo (
  serverName : PWideChar;
  level : Integer;
  var bufPtr : Pointer
) : NetAPIStatus; stdcall;

function NetReplSetInfo (
  serverName : PWideChar;
  level : Integer;
  buf : Pointer;
  var parm_err : Integer
) : NetAPIStatus; stdcall;

function NetReplExportDirAdd (
  serverName : PWideChar;
  level : Integer;
  buf : Pointer;
  var parm_err : Integer
) : NetAPIStatus; stdcall;

function NetReplExportDirDel (
  serverName : PWideChar;
  dirName : PWideChar
) : NetAPIStatus; stdcall;

function NetReplExportDirEnum (
  servername : PWideChar;
  level : Integer;
  var bufPtr : Pointer;
  prefmaxlen : Integer;
  var entriesread, totalentries, resumeHandle : Integer
) : NetAPIStatus; stdcall;

function NetReplExportDirGetInfo (
  servername : PWideChar;
  dirName : PWideChar;
  level : Integer;
  var bufPtr : Pointer
) : NetAPIStatus; stdcall;

function NetReplExportDirSetInfo (
  serverName, dirName : PWideChar;
  level : Integer;
  buf : Pointer;
  var parm_err : Integer
) : NetAPIStatus; stdcall;

function NetReplExportDirLock (
  serverName, dirName : PWideChar
) : NetAPIStatus; stdcall;

function NetReplExportDirUnlock (
  serverName, dirName : PWideChar;
  unlockforce : Integer
) : NetAPIStatus; stdcall;


function NetReplImportDirAdd (
  servername : PWideChar;
  level : Integer;
  buf : Pointer;
  var parm_err : Integer
) : NetAPIStatus; stdcall;

function NetReplImportDirDel (
  servername : PWideChar;
  dirName : PWideChar
) : NetAPIStatus; stdcall;

function NetReplImportDirEnum (
  serverName : PWideChar;
  level : Integer;
  var bufPtr : Pointer;
  prefMaxLen : Integer;
  var entriesRead, totalEntries, resumeHandle : Integer
) : NetAPIStatus; stdcall;

function NetReplImportDirGetInfo (
  serverName : PWideChar;
  dirName : PWideChar;
  level : Integer;
  var bufPtr : Pointer
) : NetAPIStatus; stdcall;

function NetReplImportDirLock (
  serverName : PWideChar;
  dirName : PWideChar
) : NetAPIStatus; stdcall;


function NetReplImportDirUnlock (
  serverName : PWideChar;
  dirName : PWideChar;
  unlockForce : Integer
) : NetAPIStatus; stdcall;

implementation
function NetReplGetInfo;           external 'NETAPI32.DLL';
function NetReplSetInfo;           external 'NETAPI32.DLL';
function NetReplExportDirAdd;      external 'NETAPI32.DLL';
function NetReplExportDirDel;      external 'NETAPI32.DLL';
function NetReplExportDirEnum;     external 'NETAPI32.DLL';
function NetReplExportDirGetInfo;  external 'NETAPI32.DLL';
function NetReplExportDirSetInfo;  external 'NETAPI32.DLL';
function NetReplExportDirLock;     external 'NETAPI32.DLL';
function NetReplExportDirUnlock;   external 'NETAPI32.DLL';
function NetReplImportDirAdd;      external 'NETAPI32.DLL';
function NetReplImportDirDel;      external 'NETAPI32.DLL';
function NetReplImportDirEnum;     external 'NETAPI32.DLL';
function NetReplImportDirGetInfo;  external 'NETAPI32.DLL';
function NetReplImportDirLock;     external 'NETAPI32.DLL';
function NetReplImportDirUnlock;   external 'NETAPI32.DLL';

end.
