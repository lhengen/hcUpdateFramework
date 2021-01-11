unit LMWksta;

{$WEAKPACKAGEUNIT}

interface

uses Windows, lmglobal;

//
// Special Values and Constants
//

//
//  Identifiers for use as NetWkstaSetInfo parmnum parameter
//

//
// One of these values indicates the parameter within an information
// structure that is invalid when ERROR_INVALID_PARAMETER is returned by
// NetWkstaSetInfo.
//

const
  WKSTA_PLATFORM_ID_PARMNUM               = 100;
  WKSTA_COMPUTERNAME_PARMNUM              = 1;
  WKSTA_LANGROUP_PARMNUM                  = 2;
  WKSTA_VER_MAJOR_PARMNUM                 = 4;
  WKSTA_VER_MINOR_PARMNUM                 = 5;
  WKSTA_LOGGED_ON_USERS_PARMNUM           = 6;
  WKSTA_LANROOT_PARMNUM                   = 7;
  WKSTA_LOGON_DOMAIN_PARMNUM              = 8;
  WKSTA_LOGON_SERVER_PARMNUM              = 9;
  WKSTA_CHARWAIT_PARMNUM                  = 10;  // Supported by down-level.
  WKSTA_CHARTIME_PARMNUM                  = 11;  // Supported by down-level.
  WKSTA_CHARCOUNT_PARMNUM                 = 12;  // Supported by down-level.
  WKSTA_KEEPCONN_PARMNUM                  = 13;
  WKSTA_KEEPSEARCH_PARMNUM                = 14;
  WKSTA_MAXCMDS_PARMNUM                   = 15;
  WKSTA_NUMWORKBUF_PARMNUM                = 16;
  WKSTA_MAXWRKCACHE_PARMNUM               = 17;
  WKSTA_SESSTIMEOUT_PARMNUM               = 18;
  WKSTA_SIZERROR_PARMNUM                  = 19;
  WKSTA_NUMALERTS_PARMNUM                 = 20;
  WKSTA_NUMSERVICES_PARMNUM               = 21;
  WKSTA_NUMCHARBUF_PARMNUM                = 22;
  WKSTA_SIZCHARBUF_PARMNUM                = 23;
  WKSTA_ERRLOGSZ_PARMNUM                  = 27;  // Supported by down-level.
  WKSTA_PRINTBUFTIME_PARMNUM              = 28;  // Supported by down-level.
  WKSTA_SIZWORKBUF_PARMNUM                = 29;
  WKSTA_MAILSLOTS_PARMNUM                 = 30;
  WKSTA_NUMDGRAMBUF_PARMNUM               = 31;
  WKSTA_WRKHEURISTICS_PARMNUM             = 32;  // Supported by down-level.
  WKSTA_MAXTHREADS_PARMNUM                = 33;

  WKSTA_LOCKQUOTA_PARMNUM                 = 41;
  WKSTA_LOCKINCREMENT_PARMNUM             = 42;
  WKSTA_LOCKMAXIMUM_PARMNUM               = 43;
  WKSTA_PIPEINCREMENT_PARMNUM             = 44;
  WKSTA_PIPEMAXIMUM_PARMNUM               = 45;
  WKSTA_DORMANTFILELIMIT_PARMNUM          = 46;
  WKSTA_CACHEFILETIMEOUT_PARMNUM          = 47;
  WKSTA_USEOPPORTUNISTICLOCKING_PARMNUM   = 48;
  WKSTA_USEUNLOCKBEHIND_PARMNUM           = 49;
  WKSTA_USECLOSEBEHIND_PARMNUM            = 50;
  WKSTA_BUFFERNAMEDPIPES_PARMNUM          = 51;
  WKSTA_USELOCKANDREADANDUNLOCK_PARMNUM   = 52;
  WKSTA_UTILIZENTCACHING_PARMNUM          = 53;
  WKSTA_USERAWREAD_PARMNUM                = 54;
  WKSTA_USERAWWRITE_PARMNUM               = 55;
  WKSTA_USEWRITERAWWITHDATA_PARMNUM       = 56;
  WKSTA_USEENCRYPTION_PARMNUM             = 57;
  WKSTA_BUFFILESWITHDENYWRITE_PARMNUM     = 58;
  WKSTA_BUFFERREADONLYFILES_PARMNUM       = 59;
  WKSTA_FORCECORECREATEMODE_PARMNUM       = 60;
  WKSTA_USE512BYTESMAXTRANSFER_PARMNUM    = 61;
  WKSTA_READAHEADTHRUPUT_PARMNUM          = 62;


//
// One of these values indicates the parameter within an information
// structure that is invalid when ERROR_INVALID_PARAMETER is returned by
// NetWkstaUserSetInfo.
//

  WKSTA_OTH_DOMAINS_PARMNUM              = 101;


//
// One of these values indicates the parameter within an information
// structure that is invalid when ERROR_INVALID_PARAMETER is returned by
// NetWkstaTransportAdd.
//

  TRANSPORT_QUALITYOFSERVICE_PARMNUM     = 201;
  TRANSPORT_NAME_PARMNUM                 = 202;

//
//  Data Structures
//

//
// NetWkstaGetInfo and NetWkstaSetInfo
//


type

{$IFDEF WIN32}
  LPTSTR = LPWSTR;
{$ELSE}
  LPTSTR = LPSTR;
{$ENDIF}

//
// NetWkstaGetInfo only.  System information - guest access
//

  WKSTA_INFO_100 = packed record
    wki100_platform_id : DWORD;
    wki100_computername : LPTSTR;
    wki100_langroup : LPTSTR;
    wki100_ver_major : DWORD;
    wki100_ver_minor : DWORD;
  end;
  PWKSTA_INFO_100 = ^WKSTA_INFO_100;

//
// NetWkstaGetInfo only.  System information - user access
//
  WKSTA_INFO_101 = packed record
    wki101_platform_id : DWORD;
    wki101_computername : LPTSTR;
    wki101_langroup : LPTSTR;
    wki101_ver_major : DWORD;
    wki101_ver_minor : DWORD;
    wki101_lanroot : LPTSTR;
  end;
  PWKSTA_INFO_101 = ^WKSTA_INFO_101;

//
// NetWkstaGetInfo only.  System information - admin or operator access
//
  WKSTA_INFO_102 = packed record
    wki102_platform_id : DWORD;
    wki102_computername : LPTSTR;
    wki102_langroup : LPTSTR;
    wki102_ver_major : DWORD;
    wki102_ver_minor : DWORD;
    wki102_lanroot : LPTSTR;
    wki102_logged_on_users : DWORD;
  end;
  PWKSTA_INFO_102 = ^WKSTA_INFO_102;

//
// Down-level NetWkstaGetInfo and NetWkstaSetInfo.
//
// DOS specific workstation information -
//    admin or domain operator access
//
  WKSTA_INFO_302 = packed record
    wki302_char_wait : DWORD;
    wki302_collection_time : DWORD;
    wki302_maximum_collection_count : DWORD;
    wki302_keep_conn : DWORD;
    wki302_keep_search : DWORD;
    wki302_max_cmds : DWORD;
    wki302_num_work_buf : DWORD;
    wki302_siz_work_buf : DWORD;
    wki302_max_wrk_cache : DWORD;
    wki302_sess_timeout : DWORD;
    wki302_siz_error : DWORD;
    wki302_num_alerts : DWORD;
    wki302_num_services : DWORD;
    wki302_errlog_sz : DWORD;
    wki302_print_buf_time : DWORD;
    wki302_num_char_buf : DWORD;
    wki302_siz_char_buf : DWORD;
    wki302_wrk_heuristics : LPTSTR;
    wki302_mailslots : DWORD;
    wki302_num_dgram_buf : DWORD;
  end;
  PWKSTA_INFO_302 = ^WKSTA_INFO_302;

//
// Down-level NetWkstaGetInfo and NetWkstaSetInfo
//
// OS/2 specific workstation information -
//    admin or domain operator access
//
  WKSTA_INFO_402 = packed record
    wki402_char_wait : DWORD;
    wki402_collection_time : DWORD;
    wki402_maximum_collection_count : DWORD;
    wki402_keep_conn : DWORD;
    wki402_keep_search : DWORD;
    wki402_max_cmds : DWORD;
    wki402_num_work_buf : DWORD;
    wki402_siz_work_buf : DWORD;
    wki402_max_wrk_cache : DWORD;
    wki402_sess_timeout : DWORD;
    wki402_siz_error : DWORD;
    wki402_num_alerts : DWORD;
    wki402_num_services : DWORD;
    wki402_errlog_sz : DWORD;
    wki402_print_buf_time : DWORD;
    wki402_num_char_buf : DWORD;
    wki402_siz_char_buf : DWORD;
    wki402_wrk_heuristics : LPTSTR;
    wki402_mailslots : DWORD;
    wki402_num_dgram_buf : DWORD;
    wki402_max_threads : DWORD;
  end;
  PWKSTA_INFO_402 = ^WKSTA_INFO_402;

//
// Same-level NetWkstaGetInfo and NetWkstaSetInfo.
//
// NT specific workstation information -
//    admin or domain operator access
//
  WKSTA_INFO_502 = packed record
    wki502_char_wait : DWORD;
    wki502_collection_time : DWORD;
    wki502_maximum_collection_count : DWORD;
    wki502_keep_conn : DWORD;
    wki502_max_cmds : DWORD;
    wki502_sess_timeout : DWORD;
    wki502_siz_char_buf : DWORD;
    wki502_max_threads : DWORD;

    wki502_lock_quota : DWORD;
    wki502_lock_increment : DWORD;
    wki502_lock_maximum : DWORD;
    wki502_pipe_increment : DWORD;
    wki502_pipe_maximum : DWORD;
    wki502_cache_file_timeout : DWORD;
    wki502_dormant_file_limit : DWORD;
    wki502_read_ahead_throughput : DWORD;

    wki502_num_mailslot_buffers : DWORD;
    wki502_num_srv_announce_buffers : DWORD;
    wki502_max_illegal_datagram_events : DWORD;
    wki502_illegal_datagram_event_reset_frequency : DWORD;
    wki502_log_election_packets : BOOL;

    wki502_use_opportunistic_locking : BOOL;
    wki502_use_unlock_behind : BOOL;
    wki502_use_close_behind : BOOL;
    wki502_buf_named_pipes : BOOL;
    wki502_use_lock_read_unlock : BOOL;
    wki502_utilize_nt_caching : BOOL;
    wki502_use_raw_read : BOOL;
    wki502_use_raw_write : BOOL;
    wki502_use_write_raw_data : BOOL;
    wki502_use_encryption : BOOL;
    wki502_buf_files_deny_write : BOOL;
    wki502_buf_read_only_files : BOOL;
    wki502_force_core_create_mode : BOOL;
    wki502_use_512_byte_max_transfer : BOOL;
  end;
  PWKSTA_INFO_502 = ^WKSTA_INFO_502;


//
// The following info-levels are only valid for NetWkstaSetInfo
//

//
// The following levels are supported on down-level systems (LAN Man 2.x)
// as well as NT systems:
//
  WKSTA_INFO_1010 = packed record
    wki1010_char_wait : DWORD;
  end;
  PWKSTA_INFO_1010 = ^WKSTA_INFO_1010 ;

  WKSTA_INFO_1011 = packed record
    wki1011_collection_time : DWORD;
  end;
  PWKSTA_INFO_1011 = ^WKSTA_INFO_1011;

  WKSTA_INFO_1012 = packed record
    wki1012_maximum_collection_count : DWORD;
  end;
  PWKSTA_INFO_1012 = ^WKSTA_INFO_1012;

//
// The following level are supported on down-level systems (LAN Man 2.x)
// only:
//
  WKSTA_INFO_1027  = packed record
    wki1027_errlog_sz : DWORD;
  end;
  PWKSTA_INFO_1027  = ^WKSTA_INFO_1027;

  WKSTA_INFO_1028 = packed record
    wki1028_print_buf_time : DWORD;
  end;
  PWKSTA_INFO_1028 = ^WKSTA_INFO_1028;

  WKSTA_INFO_1032 = packed record
    wki1032_wrk_heuristics  : DWORD;
  end;
  PWKSTA_INFO_1032 = ^WKSTA_INFO_1032;

//
// The following levels are settable on NT systems, and have no
// effect on down-level systems (i.e. LANMan 2.x) since these
// fields cannot be set on them:
//
  WKSTA_INFO_1013 = packed record
    wki1013_keep_conn : DWORD;
  end;
  PWKSTA_INFO_1013 = ^WKSTA_INFO_1013;

  WKSTA_INFO_1018 = packed record
    wki1018_sess_timeout : DWORD;
  end;
  PWKSTA_INFO_1018 = ^WKSTA_INFO_1018;

  WKSTA_INFO_1023 = packed record
    wki1023_siz_char_buf : DWORD;
  end;
  PWKSTA_INFO_1023 = ^WKSTA_INFO_1023;

  WKSTA_INFO_1033 = packed record
    wki1033_max_threads : DWORD;
  end;
  PWKSTA_INFO_1033 = ^WKSTA_INFO_1033;

//
// The following levels are only supported on NT systems:
//
  WKSTA_INFO_1041 = packed record
    wki1041_lock_quota : DWORD;
  end;
  PWKSTA_INFO_1041 = ^WKSTA_INFO_1041;

  WKSTA_INFO_1042 = packed record
    wki1042_lock_increment : DWORD;
  end;
  PWKSTA_INFO_1042 = ^WKSTA_INFO_1042;

  WKSTA_INFO_1043 = packed record
    wki1043_lock_maximum : DWORD;
  end;
  PWKSTA_INFO_1043 = ^WKSTA_INFO_1043;

  WKSTA_INFO_1044 = packed record
    wki1044_pipe_increment : DWORD;
  end;
  PWKSTA_INFO_1044 = ^WKSTA_INFO_1044;

  WKSTA_INFO_1045 = packed record
    wki1045_pipe_maximum : DWORD;
  end;
  PWKSTA_INFO_1045 = ^WKSTA_INFO_1045;

  WKSTA_INFO_1046 = packed record
    wki1046_dormant_file_limit : DWORD;
  end;
  PWKSTA_INFO_1046 = ^WKSTA_INFO_1046;

  WKSTA_INFO_1047 = packed record
    wki1047_cache_file_timeout : DWORD;
  end;
  PWKSTA_INFO_1047 = ^WKSTA_INFO_1047;

  WKSTA_INFO_1048 = packed record
    wki1048_use_opportunistic_locking : BOOL;
  end;
  PWKSTA_INFO_1048 = ^WKSTA_INFO_1048;

  WKSTA_INFO_1049 = packed record
    wki1049_use_unlock_behind : BOOL;
  end;
  PWKSTA_INFO_1049 = ^WKSTA_INFO_1049;

  WKSTA_INFO_1050 = packed record
    wki1050_use_close_behind : BOOL;
  end;
  PWKSTA_INFO_1050 = ^WKSTA_INFO_1050;

  WKSTA_INFO_1051 = packed record
    wki1051_buf_named_pipes : BOOL;
  end;
  PWKSTA_INFO_1051 = ^WKSTA_INFO_1051;

  WKSTA_INFO_1052 = packed record
    wki1052_use_lock_read_unlock : BOOL;
  end;
  PWKSTA_INFO_1052 = ^WKSTA_INFO_1052;

  WKSTA_INFO_1053 = packed record
    wki1053_utilize_nt_caching : BOOL;
  end;
  PWKSTA_INFO_1053 = ^WKSTA_INFO_1053;

  WKSTA_INFO_1054 = packed record
    wki1054_use_raw_read : BOOL;
  end;
  PWKSTA_INFO_1054 = ^WKSTA_INFO_1054;

  WKSTA_INFO_1055 = packed record
    wki1055_use_raw_write : BOOL;
  end;
  PWKSTA_INFO_1055 = ^WKSTA_INFO_1055;

  WKSTA_INFO_1056 = packed record
    wki1056_use_write_raw_data : BOOL;
  end;
  PWKSTA_INFO_1056 = ^WKSTA_INFO_1056;

  WKSTA_INFO_1057 = packed record
    wki1057_use_encryption : BOOL;
  end;
  PWKSTA_INFO_1057 = ^WKSTA_INFO_1057;

  WKSTA_INFO_1058 = packed record
    wki1058_buf_files_deny_write : BOOL;
  end;
  PWKSTA_INFO_1058 = ^WKSTA_INFO_1058;

  WKSTA_INFO_1059 = packed record
    wki1059_buf_read_only_files : BOOL;
  end;
  PWKSTA_INFO_1059 = ^WKSTA_INFO_1059;

  WKSTA_INFO_1060 = packed record
    wki1060_force_core_create_mode : BOOL;
  end;
  PWKSTA_INFO_1060 = ^WKSTA_INFO_1060;

  WKSTA_INFO_1061 = packed record
    wki1061_use_512_byte_max_transfer : BOOL;
  end;
  PWKSTA_INFO_1061 = ^WKSTA_INFO_1061;

  WKSTA_INFO_1062 = packed record
    wki1062_read_ahead_throughput : DWORD;
  end;
  PWKSTA_INFO_1062 = ^WKSTA_INFO_1062;


//
// NetWkstaUserGetInfo (local only) and NetWkstaUserEnum -
//     no access restrictions.
//
  WKSTA_USER_INFO_0 = packed record
    wkui0_username : LPTSTR;
  end;
  PWKSTA_USER_INFO_0 = ^WKSTA_USER_INFO_0 ;

//
// NetWkstaUserGetInfo (local only) and NetWkstaUserEnum -
//     no access restrictions.
//
  WKSTA_USER_INFO_1 = packed record
    wkui1_username : LPTSTR;
    wkui1_logon_domain : LPTSTR;
    wkui1_oth_domains : LPTSTR;
    wkui1_logon_server : LPTSTR;
  end;
  PWKSTA_USER_INFO_1 = ^WKSTA_USER_INFO_1;

//
// NetWkstaUserSetInfo - local access.
//
  WKSTA_USER_INFO_1101 = packed record
     wkui1101_oth_domains : LPTSTR;
  end;
  PWKSTA_USER_INFO_1101 = ^WKSTA_USER_INFO_1101;

//
// NetWkstaTransportAdd - admin access
//
  WKSTA_TRANSPORT_INFO_0 = packed record
    wkti0_quality_of_service : DWORD;
    wkti0_number_of_vcs : DWORD;
    wkti0_transport_name : LPTSTR;
    wkti0_transport_address : LPTSTR;
    wkti0_wan_ish : BOOL;
  end;
  PWKSTA_TRANSPORT_INFO_0 = ^WKSTA_TRANSPORT_INFO_0;


//
// Function Prototypes
//

function NetWkstaGetInfo (servername : LPTSTR; level : DWORD; var buffer : pointer) : NetAPIStatus; stdcall;
function NetWkstaSetInfo (servername : LPTSTR; level : DWORD; buffer : pointer; var parm_err : DWORD) : NetAPIStatus; stdcall;
function NetWkstaUserGetInfo (reserved : LPTSTR; level : DWORD; var buffer : pointer) : NetAPIStatus; stdcall;
function NetWkstaUserSetInfo (reserved : LPTSTR; level : DWORD; buffer : pointer; var parm_error : DWORD) : NetAPIStatus; stdcall;
function NetWkstaUserEnum (servername : LPTSTR; level : DWORD; var buffer : pointer; prefMaxLen : DWORD; var entriesRead, totalEntries, resumeHandle : DWORD) : NetAPIStatus; stdcall;
function NetWkstaTransportAdd (servername : LPTSTR; level : DWORD; buffer : pointer; var parm_err : DWORD) : NetAPIStatus; stdcall;
function NetWkstaTransportDel (servername, transportname : LPTSTR; ucond : DWORD) : NetAPIStatus; stdcall;
function NetWkstaTransportEnum (servername : LPTSTR; level : DWORD; var puffer : pointer; prefmaxlen : DWORD; var entriesRead, totalEntries, resumeHandle : DWORD) : NetAPIStatus; stdcall;

implementation

const
  NetAPIDLL = 'netapi32.dll';

function NetWkstaGetInfo; external NetAPIDLL;
function NetWkstaSetInfo; external NetAPIDLL;
function NetWkstaUserGetInfo; external NetAPIDLL;
function NetWkstaUserSetInfo; external NetAPIDLL;
function NetWkstaUserEnum; external NetAPIDLL;
function NetWkstaTransportAdd; external NetAPIDLL;
function NetWkstaTransportDel; external NetAPIDLL;
function NetWkstaTransportEnum; external NetAPIDLL;
end.
