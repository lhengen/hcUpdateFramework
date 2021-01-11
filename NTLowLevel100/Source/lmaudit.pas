unit lmaudit;

interface

uses lmglobal;

const
  LOGFLAGS_FORWARD	= $0;
  LOGFLAGS_BACKWARD	= $1;
  LOGFLAGS_SEEK		= $2;

//
// 	Audit entry types (field ae_type in audit_entry).
//

  AE_SRVSTATUSX	    = 0;
  AE_SESSLOGONX	    = 1;
  AE_SESSLOGOFFX    = 2;
  AE_SESSPWERRX	    = 3;
  AE_CONNSTARTX	    = 4;
  AE_CONNSTOPX	    = 5;
  AE_CONNREJX	    = 6;
  AE_RESACCESSX	    = 7;
  AE_RESACCESSREJX  = 8;
  AE_CLOSEFILEX	    = 9;
  AE_SERVICESTATX   = 11;
  AE_ACLMODX	    = 12;
  AE_UASMODX	    = 13;
  AE_NETLOGONX	    = 14;
  AE_NETLOGOFFX	    = 15;
  AE_NETLOGDENIED   = 16;
  AE_ACCLIMITEXCD   = 17;
  AE_RESACCESS2	    = 18;
  AE_ACLMODFAIL	    = 19;
  AE_LOCKOUTX       = 20;
  AE_GENERIC_TYPE   = 21;

//
//	Values for ae_ss_status field of ae_srvstatus.
//

  AE_SRVSTART	= 0;
  AE_SRVPAUSED	= 1;
  AE_SRVCONT	= 2;
  AE_SRVSTOP	= 3;

//
// 	Values for ae_so_privilege field of ae_sesslogon.
//

  AE_GUEST	= 0;
  AE_USER	= 1;
  AE_ADMIN	= 2;

//
//	Values for various ae_XX_reason fields.
//

  AE_NORMAL	   = 0;
  AE_USERLIMIT	   = 0;
  AE_GENERAL	   = 0;
  AE_ERROR	   = 1;
  AE_SESSDIS	   = 1;
  AE_BADPW	   = 1;
  AE_AUTODIS	   = 2;
  AE_UNSHARE	   = 2;
  AE_ADMINPRIVREQD = 2;
  AE_ADMINDIS	   = 3;
  AE_NOACCESSPERM  = 3;
  AE_ACCRESTRICT   = 4;

  AE_NORMAL_CLOSE  = 0;
  AE_SES_CLOSE	   = 1;
  AE_ADMIN_CLOSE   = 2;

//
// Values for xx_subreason fields.
//

  AE_LIM_UNKNOWN      = 0;
  AE_LIM_LOGONHOURS   = 1;
  AE_LIM_EXPIRED      = 2;
  AE_LIM_INVAL_WKSTA  = 3;
  AE_LIM_DISABLED     = 4;
  AE_LIM_DELETED      = 5;

//
// Values for xx_action fields
//

  AE_MOD	      = 0;
  AE_DELETE	      = 1;
  AE_ADD	      = 2;

//
// Types of UAS record for um_rectype field
//

  AE_UAS_USER	      = 0;
  AE_UAS_GROUP	      = 1;
  AE_UAS_MODALS	      = 2;

//
// Bitmasks for auditing events
//
// The parentheses around the hex constants broke h_to_inc
// and have been purged from the face of the earth.
//

  SVAUD_SERVICE           = $1;
  SVAUD_GOODSESSLOGON     = $6;
  SVAUD_BADSESSLOGON      = $18;
  SVAUD_SESSLOGON         = SVAUD_GOODSESSLOGON or SVAUD_BADSESSLOGON;
  SVAUD_GOODNETLOGON      = $60;
  SVAUD_BADNETLOGON       = $180;
  SVAUD_NETLOGON          = SVAUD_GOODNETLOGON or SVAUD_BADNETLOGON;
  SVAUD_LOGON             = SVAUD_NETLOGON or SVAUD_SESSLOGON;
  SVAUD_GOODUSE           = $600;
  SVAUD_BADUSE            = $1800;
  SVAUD_USE               = SVAUD_GOODUSE or SVAUD_BADUSE;
  SVAUD_USERLIST          = $2000;
  SVAUD_PERMISSIONS       = $4000;
  SVAUD_RESOURCE          = $8000;
  SVAUD_LOGONLIM	  = $00010000;

//
// Resource access audit bitmasks.
//

  AA_AUDIT_ALL	    = $0001;
  AA_A_OWNER	    = $0004;
  AA_CLOSE	    = $0008;
  AA_S_OPEN	    = $0010;
  AA_S_WRITE	    = $0020;
  AA_S_CREATE	    = $0020;
  AA_S_DELETE	    = $0040;
  AA_S_ACL	    = $0080;
  AA_S_ALL	    = AA_S_OPEN or AA_S_WRITE or AA_S_DELETE or AA_S_ACL;
  AA_F_OPEN	    = $0100;
  AA_F_WRITE	    = $0200;
  AA_F_CREATE	    = $0200;
  AA_F_DELETE	    = $0400;
  AA_F_ACL	    = $0800;
  AA_F_ALL	    = AA_F_OPEN or AA_F_WRITE or AA_F_DELETE or AA_F_ACL;

// Pinball-specific
  AA_A_OPEN	    = $1000;
  AA_A_WRITE	    = $2000;
  AA_A_CREATE	    = $2000;
  AA_A_DELETE	    = $4000;
  AA_A_ACL	    = $8000;
  AA_A_ALL	    = AA_F_OPEN or AA_F_WRITE or AA_F_DELETE or AA_F_ACL;

  ACTION_LOCKOUT         = 00;
  ACTION_ADMINUNLOCK     = 01;


type
  HLOG = record
    time,
    last_flags,
    offset,
    rec_offset : Integer;
  end;
  PHLOG = ^HLOG;


//
// Data Structures - Audit
//

  AUDIT_ENTRY = record
    ae_len : Integer;
    ae_reserved : Integer;
    ae_time : Integer;
    ae_type : Integer;
    ae_data_offset : Integer;  (* Offset from beginning address of audit_entry *)
    ae_data_size : Integer;   // byte count of ae_data area (not incl pad).
  end;
  PAUDIT_ENTRY = ^AUDIT_ENTRY;

  AE_SRVSTATUS = record
    ae_sv_status : Integer;
  end;
  PAE_SRVSTATUS = ^AE_SRVSTATUS;

  AE_SESSLOGON = record
    ae_so_compname : Integer;
    ae_so_username : Integer;
    ae_so_privilege : Integer;
  end;
  PAE_SESSLOGON = ^AE_SESSLOGON;

  AE_SESSLOGOFF = record
    ae_sf_compname : Integer;
    ae_sf_username : Integer;
    ae_sf_reason : Integer;
  end;
  PAE_SESSLOGOFF = ^AE_SESSLOGOFF;

  AE_SESSPWERR = record
    ae_sp_compname : Integer;
    ae_sp_username : Integer;
  end;
  PAE_SESSPWERR = ^AE_SESSPWERR;

  AE_CONNSTART = record
    ae_ct_compname : Integer;
    ae_ct_username : Integer;
    ae_ct_netname : Integer;
    ae_ct_connid : Integer;
  end;
  PAE_CONNSTART = ^AE_CONNSTART;

  AE_CONNSTOP = record
    ae_cp_compname : Integer;
    ae_cp_username : Integer;
    ae_cp_netname : Integer;
    ae_cp_connid : Integer;
    ae_cp_reason : Integer;
  end;
  PAE_CONNSTOP = ^AE_CONNSTOP;

  AE_CONNREJ = record
    ae_cr_compname : Integer;
    ae_cr_username : Integer;
    ae_cr_netname : Integer;
    ae_cr_reason : Integer;
  end;
  PAE_CONNREJ = ^AE_CONNREJ;

  AE_RESACCESS = record
    ae_ra_compname : Integer;
    ae_ra_username : Integer;
    ae_ra_resname : Integer;
    ae_ra_operation : Integer;
    ae_ra_returncode : Integer;
    ae_ra_restype : Integer;
    ae_ra_fileid : Integer;
  end;
  PAE_RESACCESS = ^AE_RESACCESS;

  AE_RESACCESSREJ = record
    ae_rr_compname : Integer;
    ae_rr_username : Integer;
    ae_rr_resname : Integer;
    ae_rr_operation : Integer;
  end;
  PAE_RESACCESSREJ = ^AE_RESACCESSREJ;

  AE_CLOSEFILE = record
    ae_cf_compname : Integer;
    ae_cf_username : Integer;
    ae_cf_resname : Integer;
    ae_cf_fileid : Integer;
    ae_cf_duration : Integer;
    ae_cf_reason : Integer;
  end;
  PAE_CLOSEFILE = ^AE_CLOSEFILE;

  AE_SERVICESTAT = record
    ae_ss_compname : Integer;
    ae_ss_username : Integer;
    ae_ss_svcname : Integer;
    ae_ss_status : Integer;
    ae_ss_code : Integer;
    ae_ss_text : Integer;
    ae_ss_returnval : Integer;
  end;
  PAE_SERVICESTAT = ^AE_SERVICESTAT;

  AE_ACLMOD = record
    ae_am_compname : Integer;
    ae_am_username : Integer;
    ae_am_resname : Integer;
    ae_am_action : Integer;
    ae_am_datalen : Integer;
  end;
  PAE_ACLMOD = ^AE_ACLMOD;

  AE_UASMOD = record
    ae_um_compname : Integer;
    ae_um_username : Integer;
    ae_um_resname : Integer;
    ae_um_rectype : Integer;
    ae_um_action : Integer;
    ae_um_datalen : Integer;
  end;
  PAE_UASMOD = ^AE_UASMOD;

  AE_NETLOGON = record
    ae_no_compname : Integer;
    ae_no_username : Integer;
    ae_no_privilege : Integer;
    ae_no_authflags : Integer;
  end;
  PAE_NETLOGON = ^AE_NETLOGON;

  AE_NETLOGOFF = record
    ae_nf_compname : Integer;
    ae_nf_username : Integer;
    ae_nf_reserved1 : Integer;
    ae_nf_reserved2 : Integer;
  end;
  PAE_NETLOGOFF = ^AE_NETLOGOFF;

  AE_ACCLIM = record
    ae_al_compname : Integer;
    ae_al_username : Integer;
    ae_al_resname : Integer;
    ae_al_limit : Integer;
  end;
  PAE_ACCLIM = ^AE_ACCLIM;

  AE_LOCKOUT = record
    ae_lk_compname : Integer;     // Ptr to computername of client.
    ae_lk_username : Integer;     // Ptr to username of client (NULL
                                        //  if same as computername).
    ae_lk_action : Integer;       // Action taken on account:
                                        // 0 means locked out, 1 means not.
    ae_lk_bad_pw_count : Integer; // Bad password count at the time
                                        // of lockout.
  end;
  PAE_LOCKOUT = ^AE_LOCKOUT;

  AE_GENERIC = record
    ae_ge_msgfile : Integer;
    ae_ge_msgnum : Integer;
    ae_ge_params : Integer;
    ae_ge_param1 : Integer;
    ae_ge_param2 : Integer;
    ae_ge_param3 : Integer;
    ae_ge_param4 : Integer;
    ae_ge_param5 : Integer;
    ae_ge_param6 : Integer;
    ae_ge_param7 : Integer;
    ae_ge_param8 : Integer;
    ae_ge_param9 : Integer;
  end;
  PAE_GENERIC = ^AE_GENERIC;

function NetAuditClear (server : PWideChar; backupFile : PWideChar; service : PWideChar) : NetAPIStatus; stdcall;
function NetAuditRead (server : PWideChar; service : PWideChar; const auditloghandle : HLog; offset : Integer;
                       var reserved : Integer; reserved2 : Integer;
                       var buffer : pointer; prefMaxLen : Integer; var bytesRead, totalAvail : Integer) : NetAPIStatus; stdcall;

function NetAuditWrite (tp : Integer; buffer : pointer; numBytes : Integer; service : PWideChar; reserved : pointer) : NetAPIStatus; stdcall;


implementation

function NetAuditClear; external 'NETAPI32.DLL';
function NetAuditRead;  external 'NETAPI32.DLL';
function NetAuditWrite; external 'NETAPI32.DLL';

end.
