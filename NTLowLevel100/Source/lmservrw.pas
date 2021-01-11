unit lmservrw;

interface

uses lmglobal, windows;

//
// Constants - SERVER
//

//
// The platform ID indicates the levels to use for platform-specific
// information.
//

const

  SV_PLATFORM_ID_OS2 = 400;
  SV_PLATFORM_ID_NT  = 500;

//
//      Mask to be applied to svX_version_major in order to obtain
//      the major version number.
//

  MAJOR_VERSION_MASK  = $0F;

//
//      Bit-mapped values for svX_type fields. X = 1, 2 or 3.
//

  SV_TYPE_WORKSTATION         = $00000001;
  SV_TYPE_SERVER              = $00000002;
  SV_TYPE_SQLSERVER           = $00000004;
  SV_TYPE_DOMAIN_CTRL         = $00000008;
  SV_TYPE_DOMAIN_BAKCTRL      = $00000010;
  SV_TYPE_TIME_SOURCE         = $00000020;
  SV_TYPE_AFP                 = $00000040;
  SV_TYPE_NOVELL              = $00000080;
  SV_TYPE_DOMAIN_MEMBER       = $00000100;
  SV_TYPE_PRINTQ_SERVER       = $00000200;
  SV_TYPE_DIALIN_SERVER       = $00000400;
  SV_TYPE_XENIX_SERVER        = $00000800;
  SV_TYPE_SERVER_UNIX         = SV_TYPE_XENIX_SERVER;
  SV_TYPE_NT                  = $00001000;
  SV_TYPE_WFW                 = $00002000;
  SV_TYPE_SERVER_MFPN         = $00004000;
  SV_TYPE_SERVER_NT           = $00008000;
  SV_TYPE_POTENTIAL_BROWSER   = $00010000;
  SV_TYPE_BACKUP_BROWSER      = $00020000;
  SV_TYPE_MASTER_BROWSER      = $00040000;
  SV_TYPE_DOMAIN_MASTER       = $00080000;
  SV_TYPE_SERVER_OSF          = $00100000;
  SV_TYPE_SERVER_VMS          = $00200000;
  SV_TYPE_WINDOWS             = $00400000;  (* Windows95 and above *)
  SV_TYPE_DFS                 = $00800000;  (* Root of a DFS tree *)
  SV_TYPE_ALTERNATE_XPORT     = $20000000;  (* return list for alternate transport *)
  SV_TYPE_LOCAL_LIST_ONLY     = $40000000;  (* Return local list only *)
  SV_TYPE_DOMAIN_ENUM         = $80000000;
  SV_TYPE_ALL                 = $FFFFFFFF;  (* handy for NetServerEnum2 *)

//
//      Special value for sv102_disc that specifies infinite disconnect
//      time.
//

  SV_NODISC           = -1;  (* No autodisconnect timeout enforced *)

//
//      Values of svX_security field. X = 2 or 3.
//

  SV_USERSECURITY     = 1;
  SV_SHARESECURITY    = 0;

//
//      Values of svX_hidden field. X = 2 or 3.
//

  SV_HIDDEN       = 1;
  SV_VISIBLE      = 0;

//
//      Values for ParmError parameter to NetServerSetInfo.
//

  SV_PLATFORM_ID_PARMNUM          = 101;
  SV_NAME_PARMNUM                 = 102;
  SV_VERSION_MAJOR_PARMNUM        = 103;
  SV_VERSION_MINOR_PARMNUM        = 104;
  SV_TYPE_PARMNUM                 = 105;
  SV_COMMENT_PARMNUM              = 5;
  SV_USERS_PARMNUM                = 107;
  SV_DISC_PARMNUM                 = 10;
  SV_HIDDEN_PARMNUM               = 16;
  SV_ANNOUNCE_PARMNUM             = 17;
  SV_ANNDELTA_PARMNUM             = 18;
  SV_USERPATH_PARMNUM             = 112;

  SV_ULIST_MTIME_PARMNUM          = 401;
  SV_GLIST_MTIME_PARMNUM          = 402;
  SV_ALIST_MTIME_PARMNUM          = 403;
  SV_ALERTS_PARMNUM               = 11;
  SV_SECURITY_PARMNUM             = 405;
  SV_NUMADMIN_PARMNUM             = 406;
  SV_LANMASK_PARMNUM              = 407;
  SV_GUESTACC_PARMNUM             = 408;
  SV_CHDEVQ_PARMNUM               = 410;
  SV_CHDEVJOBS_PARMNUM            = 411;
  SV_CONNECTIONS_PARMNUM          = 412;
  SV_SHARES_PARMNUM               = 413;
  SV_OPENFILES_PARMNUM            = 414;
  SV_SESSREQS_PARMNUM             = 417;
  SV_ACTIVELOCKS_PARMNUM          = 419;
  SV_NUMREQBUF_PARMNUM            = 420;
  SV_NUMBIGBUF_PARMNUM            = 422;
  SV_NUMFILETASKS_PARMNUM         = 423;
  SV_ALERTSCHED_PARMNUM           = 37;
  SV_ERRORALERT_PARMNUM           = 38;
  SV_LOGONALERT_PARMNUM           = 39;
  SV_ACCESSALERT_PARMNUM          = 40;
  SV_DISKALERT_PARMNUM            = 41;
  SV_NETIOALERT_PARMNUM           = 42;
  SV_MAXAUDITSZ_PARMNUM           = 43;
  SV_SRVHEURISTICS_PARMNUM        = 431;

  SV_SESSOPENS_PARMNUM                = 501;
  SV_SESSVCS_PARMNUM                  = 502;
  SV_OPENSEARCH_PARMNUM               = 503;
  SV_SIZREQBUF_PARMNUM                = 504;
  SV_INITWORKITEMS_PARMNUM            = 505;
  SV_MAXWORKITEMS_PARMNUM             = 506;
  SV_RAWWORKITEMS_PARMNUM             = 507;
  SV_IRPSTACKSIZE_PARMNUM             = 508;
  SV_MAXRAWBUFLEN_PARMNUM             = 509;
  SV_SESSUSERS_PARMNUM                = 510;
  SV_SESSCONNS_PARMNUM                = 511;
  SV_MAXNONPAGEDMEMORYUSAGE_PARMNUM   = 512;
  SV_MAXPAGEDMEMORYUSAGE_PARMNUM      = 513;
  SV_ENABLESOFTCOMPAT_PARMNUM         = 514;
  SV_ENABLEFORCEDLOGOFF_PARMNUM       = 515;
  SV_TIMESOURCE_PARMNUM               = 516;
  SV_ACCEPTDOWNLEVELAPIS_PARMNUM      = 517;
  SV_LMANNOUNCE_PARMNUM               = 518;
  SV_DOMAIN_PARMNUM                   = 519;
  SV_MAXCOPYREADLEN_PARMNUM           = 520;
  SV_MAXCOPYWRITELEN_PARMNUM          = 521;
  SV_MINKEEPSEARCH_PARMNUM            = 522;
  SV_MAXKEEPSEARCH_PARMNUM            = 523;
  SV_MINKEEPCOMPLSEARCH_PARMNUM       = 524;
  SV_MAXKEEPCOMPLSEARCH_PARMNUM       = 525;
  SV_THREADCOUNTADD_PARMNUM           = 526;
  SV_NUMBLOCKTHREADS_PARMNUM          = 527;
  SV_SCAVTIMEOUT_PARMNUM              = 528;
  SV_MINRCVQUEUE_PARMNUM              = 529;
  SV_MINFREEWORKITEMS_PARMNUM         = 530;
  SV_XACTMEMSIZE_PARMNUM              = 531;
  SV_THREADPRIORITY_PARMNUM           = 532;
  SV_MAXMPXCT_PARMNUM                 = 533;
  SV_OPLOCKBREAKWAIT_PARMNUM          = 534;
  SV_OPLOCKBREAKRESPONSEWAIT_PARMNUM  = 535;
  SV_ENABLEOPLOCKS_PARMNUM            = 536;
  SV_ENABLEOPLOCKFORCECLOSE_PARMNUM   = 537;
  SV_ENABLEFCBOPENS_PARMNUM           = 538;
  SV_ENABLERAW_PARMNUM                = 539;
  SV_ENABLESHAREDNETDRIVES_PARMNUM    = 540;
  SV_MINFREECONNECTIONS_PARMNUM       = 541;
  SV_MAXFREECONNECTIONS_PARMNUM       = 542;
  SV_INITSESSTABLE_PARMNUM            = 543;
  SV_INITCONNTABLE_PARMNUM            = 544;
  SV_INITFILETABLE_PARMNUM            = 545;
  SV_INITSEARCHTABLE_PARMNUM          = 546;
  SV_ALERTSCHEDULE_PARMNUM            = 547;
  SV_ERRORTHRESHOLD_PARMNUM           = 548;
  SV_NETWORKERRORTHRESHOLD_PARMNUM    = 549;
  SV_DISKSPACETHRESHOLD_PARMNUM       = 550;
  SV_MAXLINKDELAY_PARMNUM             = 552;
  SV_MINLINKTHROUGHPUT_PARMNUM        = 553;
  SV_LINKINFOVALIDTIME_PARMNUM        = 554;
  SV_SCAVQOSINFOUPDATETIME_PARMNUM    = 555;
  SV_MAXWORKITEMIDLETIME_PARMNUM      = 556;
  SV_MAXRAWWORKITEMS_PARMNUM          = 557;
  SV_PRODUCTTYPE_PARMNUM              = 560;
  SV_SERVERSIZE_PARMNUM               = 561;
  SV_CONNECTIONLESSAUTODISC_PARMNUM   = 562;
  SV_SHARINGVIOLATIONRETRIES_PARMNUM  = 563;
  SV_SHARINGVIOLATIONDELAY_PARMNUM    = 564;
  SV_MAXGLOBALOPENSEARCH_PARMNUM      = 565;
  SV_REMOVEDUPLICATESEARCHES_PARMNUM  = 566;
  SV_LOCKVIOLATIONRETRIES_PARMNUM     = 567;
  SV_LOCKVIOLATIONOFFSET_PARMNUM      = 568;
  SV_LOCKVIOLATIONDELAY_PARMNUM       = 569;
  SV_MDLREADSWITCHOVER_PARMNUM        = 570;
  SV_CACHEDOPENLIMIT_PARMNUM          = 571;
  SV_CRITICALTHREADS_PARMNUM          = 572;
  SV_RESTRICTNULLSESSACCESS_PARMNUM   = 573;
  SV_ENABLEWFW311DIRECTIPX_PARMNUM    = 574;
  SV_OTHERQUEUEAFFINITY_PARMNUM       = 575;
  SV_QUEUESAMPLESECS_PARMNUM          = 576;
  SV_BALANCECOUNT_PARMNUM             = 577;
  SV_PREFERREDAFFINITY_PARMNUM        = 578;
  SV_MAXFREERFCBS_PARMNUM             = 579;
  SV_MAXFREEMFCBS_PARMNUM             = 580;
  SV_MAXFREELFCBS_PARMNUM             = 581;
  SV_MAXFREEPAGEDPOOLCHUNKS_PARMNUM   = 582;
  SV_MINPAGEDPOOLCHUNKSIZE_PARMNUM    = 583;
  SV_MAXPAGEDPOOLCHUNKSIZE_PARMNUM    = 584;
  SV_SENDSFROMPREFERREDPROCESSOR_PARMNUM    = 585;
  SV_MAXTHREADSPERQUEUE_PARMNUM       = 586;
  SV_CACHEDDIRECTORYLIMIT_PARMNUM     = 587;
  SV_MAXCOPYLENGTH_PARMNUM            = 588;
  SV_ENABLEBULKTRANSFER_PARMNUM       = 589;
  SV_ENABLECOMPRESSION_PARMNUM        = 590;
  SV_AUTOSHAREWKS_PARMNUM             = 591;
  SV_AUTOSHARESERVER_PARMNUM          = 592;

//
// Single-field infolevels for NetServerSetInfo.
//

  SV_COMMENT_INFOLEVEL           = (PARMNUM_BASE_INFOLEVEL + SV_COMMENT_PARMNUM);
  SV_USERS_INFOLEVEL             = (PARMNUM_BASE_INFOLEVEL + SV_USERS_PARMNUM);
  SV_DISC_INFOLEVEL              = (PARMNUM_BASE_INFOLEVEL + SV_DISC_PARMNUM);
  SV_HIDDEN_INFOLEVEL            = (PARMNUM_BASE_INFOLEVEL + SV_HIDDEN_PARMNUM);
  SV_ANNOUNCE_INFOLEVEL          = (PARMNUM_BASE_INFOLEVEL + SV_ANNOUNCE_PARMNUM);
  SV_ANNDELTA_INFOLEVEL          = (PARMNUM_BASE_INFOLEVEL + SV_ANNDELTA_PARMNUM);
  SV_SESSOPENS_INFOLEVEL         = (PARMNUM_BASE_INFOLEVEL + SV_SESSOPENS_PARMNUM);
  SV_SESSVCS_INFOLEVEL           = (PARMNUM_BASE_INFOLEVEL + SV_SESSVCS_PARMNUM);
  SV_OPENSEARCH_INFOLEVEL        = (PARMNUM_BASE_INFOLEVEL + SV_OPENSEARCH_PARMNUM);
  SV_MAXWORKITEMS_INFOLEVEL      = (PARMNUM_BASE_INFOLEVEL + SV_MAXWORKITEMS_PARMNUM);
  SV_MAXRAWBUFLEN_INFOLEVEL      = (PARMNUM_BASE_INFOLEVEL + SV_MAXRAWBUFLEN_PARMNUM);
  SV_SESSUSERS_INFOLEVEL         = (PARMNUM_BASE_INFOLEVEL + SV_SESSUSERS_PARMNUM);
  SV_SESSCONNS_INFOLEVEL         = (PARMNUM_BASE_INFOLEVEL + SV_SESSCONNS_PARMNUM);
  SV_MAXNONPAGEDMEMORYUSAGE_INFOLEVEL = (PARMNUM_BASE_INFOLEVEL + SV_MAXNONPAGEDMEMORYUSAGE_PARMNUM);
  SV_MAXPAGEDMEMORYUSAGE_INFOLEVEL    = (PARMNUM_BASE_INFOLEVEL + SV_MAXPAGEDMEMORYUSAGE_PARMNUM);
  SV_ENABLESOFTCOMPAT_INFOLEVEL  = (PARMNUM_BASE_INFOLEVEL + SV_ENABLESOFTCOMPAT_PARMNUM);
  SV_ENABLEFORCEDLOGOFF_INFOLEVEL= (PARMNUM_BASE_INFOLEVEL + SV_ENABLEFORCEDLOGOFF_PARMNUM);
  SV_TIMESOURCE_INFOLEVEL        = (PARMNUM_BASE_INFOLEVEL + SV_TIMESOURCE_PARMNUM);
  SV_LMANNOUNCE_INFOLEVEL        = (PARMNUM_BASE_INFOLEVEL + SV_LMANNOUNCE_PARMNUM);
  SV_MAXCOPYREADLEN_INFOLEVEL    = (PARMNUM_BASE_INFOLEVEL + SV_MAXCOPYREADLEN_PARMNUM);
  SV_MAXCOPYWRITELEN_INFOLEVEL   = (PARMNUM_BASE_INFOLEVEL + SV_MAXCOPYWRITELEN_PARMNUM);
  SV_MINKEEPSEARCH_INFOLEVEL     = (PARMNUM_BASE_INFOLEVEL + SV_MINKEEPSEARCH_PARMNUM);
  SV_MAXKEEPSEARCH_INFOLEVEL     = (PARMNUM_BASE_INFOLEVEL + SV_MAXKEEPSEARCH_PARMNUM);
  SV_MINKEEPCOMPLSEARCH_INFOLEVEL= (PARMNUM_BASE_INFOLEVEL + SV_MINKEEPCOMPLSEARCH_PARMNUM);
  SV_MAXKEEPCOMPLSEARCH_INFOLEVEL= (PARMNUM_BASE_INFOLEVEL + SV_MAXKEEPCOMPLSEARCH_PARMNUM);
  SV_SCAVTIMEOUT_INFOLEVEL       = (PARMNUM_BASE_INFOLEVEL + SV_SCAVTIMEOUT_PARMNUM);
  SV_MINRCVQUEUE_INFOLEVEL       = (PARMNUM_BASE_INFOLEVEL + SV_MINRCVQUEUE_PARMNUM);
  SV_MINFREEWORKITEMS_INFOLEVEL  = (PARMNUM_BASE_INFOLEVEL + SV_MINFREEWORKITEMS_PARMNUM);
  SV_MAXMPXCT_INFOLEVEL          = (PARMNUM_BASE_INFOLEVEL + SV_MAXMPXCT_PARMNUM);
  SV_OPLOCKBREAKWAIT_INFOLEVEL   = (PARMNUM_BASE_INFOLEVEL + SV_OPLOCKBREAKWAIT_PARMNUM);
  SV_OPLOCKBREAKRESPONSEWAIT_INFOLEVEL    = (PARMNUM_BASE_INFOLEVEL + SV_OPLOCKBREAKRESPONSEWAIT_PARMNUM);
  SV_ENABLEOPLOCKS_INFOLEVEL              = (PARMNUM_BASE_INFOLEVEL + SV_ENABLEOPLOCKS_PARMNUM);
  SV_ENABLEOPLOCKFORCECLOSE_INFOLEVEL     = (PARMNUM_BASE_INFOLEVEL + SV_ENABLEOPLOCKFORCECLOSE_PARMNUM);
  SV_ENABLEFCBOPENS_INFOLEVEL   = (PARMNUM_BASE_INFOLEVEL + SV_ENABLEFCBOPENS_PARMNUM);
  SV_ENABLERAW_INFOLEVEL        = (PARMNUM_BASE_INFOLEVEL + SV_ENABLERAW_PARMNUM);
  SV_ENABLESHAREDNETDRIVES_INFOLEVEL      = (PARMNUM_BASE_INFOLEVEL + SV_ENABLESHAREDNETDRIVES_PARMNUM);
  SV_MINFREECONNECTIONS_INFOLEVEL         = (PARMNUM_BASE_INFOLEVEL + SV_MINFREECONNECTIONS_PARMNUM);
  SV_MAXFREECONNECTIONS_INFOLEVEL         = (PARMNUM_BASE_INFOLEVEL + SV_MAXFREECONNECTIONS_PARMNUM);
  SV_INITSESSTABLE_INFOLEVEL    = (PARMNUM_BASE_INFOLEVEL + SV_INITSESSTABLE_PARMNUM);
  SV_INITCONNTABLE_INFOLEVEL    = (PARMNUM_BASE_INFOLEVEL + SV_INITCONNTABLE_PARMNUM);
  SV_INITFILETABLE_INFOLEVEL    = (PARMNUM_BASE_INFOLEVEL + SV_INITFILETABLE_PARMNUM);
  SV_INITSEARCHTABLE_INFOLEVEL  = (PARMNUM_BASE_INFOLEVEL + SV_INITSEARCHTABLE_PARMNUM);
  SV_ALERTSCHEDULE_INFOLEVEL    = (PARMNUM_BASE_INFOLEVEL + SV_ALERTSCHEDULE_PARMNUM);
  SV_ERRORTHRESHOLD_INFOLEVEL   = (PARMNUM_BASE_INFOLEVEL + SV_ERRORTHRESHOLD_PARMNUM);
  SV_NETWORKERRORTHRESHOLD_INFOLEVEL      = (PARMNUM_BASE_INFOLEVEL + SV_NETWORKERRORTHRESHOLD_PARMNUM);
  SV_DISKSPACETHRESHOLD_INFOLEVEL         = (PARMNUM_BASE_INFOLEVEL + SV_DISKSPACETHRESHOLD_PARMNUM);
  SV_MAXLINKDELAY_INFOLEVEL     = (PARMNUM_BASE_INFOLEVEL + SV_MAXLINKDELAY_PARMNUM);
  SV_MINLINKTHROUGHPUT_INFOLEVEL= (PARMNUM_BASE_INFOLEVEL + SV_MINLINKTHROUGHPUT_PARMNUM);
  SV_LINKINFOVALIDTIME_INFOLEVEL= (PARMNUM_BASE_INFOLEVEL + SV_LINKINFOVALIDTIME_PARMNUM);
  SV_SCAVQOSINFOUPDATETIME_INFOLEVEL      = (PARMNUM_BASE_INFOLEVEL + SV_SCAVQOSINFOUPDATETIME_PARMNUM);
  SV_MAXWORKITEMIDLETIME_INFOLEVEL        = (PARMNUM_BASE_INFOLEVEL + SV_MAXWORKITEMIDLETIME_PARMNUM);
  SV_MAXRAWWORKITEMS_INFOLOEVEL = (PARMNUM_BASE_INFOLEVEL + SV_MAXRAWWORKITEMS_PARMNUM);
  SV_PRODUCTTYPE_INFOLOEVEL     = (PARMNUM_BASE_INFOLEVEL + SV_PRODUCTTYPE_PARMNUM);
  SV_SERVERSIZE_INFOLOEVEL      = (PARMNUM_BASE_INFOLEVEL + SV_SERVERSIZE_PARMNUM);
  SV_CONNECTIONLESSAUTODISC_INFOLOEVEL    = (PARMNUM_BASE_INFOLEVEL + SV_CONNECTIONLESSAUTODISC_PARMNUM);
  SV_SHARINGVIOLATIONRETRIES_INFOLOEVEL   = (PARMNUM_BASE_INFOLEVEL + SV_SHARINGVIOLATIONRETRIES_PARMNUM);
  SV_SHARINGVIOLATIONDELAY_INFOLOEVEL     = (PARMNUM_BASE_INFOLEVEL + SV_SHARINGVIOLATIONDELAY_PARMNUM);
  SV_MAXGLOBALOPENSEARCH_INFOLOEVEL       = (PARMNUM_BASE_INFOLEVEL + SV_MAXGLOBALOPENSEARCH_PARMNUM);
  SV_REMOVEDUPLICATESEARCHES_INFOLOEVEL   = (PARMNUM_BASE_INFOLEVEL + SV_REMOVEDUPLICATESEARCHES_PARMNUM);
  SV_LOCKVIOLATIONRETRIES_INFOLOEVEL   = (PARMNUM_BASE_INFOLEVEL + SV_LOCKVIOLATIONRETRIES_PARMNUM);
  SV_LOCKVIOLATIONOFFSET_INFOLOEVEL    = (PARMNUM_BASE_INFOLEVEL + SV_LOCKVIOLATIONOFFSET_PARMNUM);
  SV_LOCKVIOLATIONDELAY_INFOLOEVEL     = (PARMNUM_BASE_INFOLEVEL + SV_LOCKVIOLATIONDELAY_PARMNUM);
  SV_MDLREADSWITCHOVER_INFOLOEVEL      = (PARMNUM_BASE_INFOLEVEL + SV_MDLREADSWITCHOVER_PARMNUM);
  SV_CACHEDOPENLIMIT_INFOLOEVEL = (PARMNUM_BASE_INFOLEVEL + SV_CACHEDOPENLIMIT_PARMNUM);
  SV_CRITICALTHREADS_INFOLOEVEL = (PARMNUM_BASE_INFOLEVEL + SV_CRITICALTHREADS_PARMNUM);
  SV_RESTRICTNULLSESSACCESS_INFOLOEVEL      = (PARMNUM_BASE_INFOLEVEL + SV_RESTRICTNULLSESSACCESS_PARMNUM);
  SV_ENABLEWFW311DIRECTIPX_INFOLOEVEL       = (PARMNUM_BASE_INFOLEVEL + SV_ENABLEWFW311DIRECTIPX_PARMNUM);
  SV_OTHERQUEUEAFFINITY_INFOLEVEL      = (PARMNUM_BASE_INFOLEVEL + SV_OTHERQUEUEAFFINITY_PARMNUM);
  SV_QUEUESAMPLESECS_INFOLEVEL         = (PARMNUM_BASE_INFOLEVEL + SV_QUEUESAMPLESECS_PARMNUM);
  SV_BALANCECOUNT_INFOLEVEL            = (PARMNUM_BASE_INFOLEVEL + SV_BALANCECOUNT_PARMNUM);
  SV_PREFERREDAFFINITY_INFOLEVEL     = (PARMNUM_BASE_INFOLEVEL + SV_PREFERREDAFFINITY_PARMNUM);
  SV_MAXFREERFCBS_INFOLEVEL     = (PARMNUM_BASE_INFOLEVEL + SV_MAXFREERFCBS_PARMNUM);
  SV_MAXFREEMFCBS_INFOLEVEL     = (PARMNUM_BASE_INFOLEVEL + SV_MAXFREEMFCBS_PARMNUM);
  SV_MAXFREELFCBS_INFOLEVEL     = (PARMNUM_BASE_INFOLEVEL + SV_MAXFREELFCBS_PARMNUM);
  SV_MAXFREEPAGEDPOOLCHUNKS_INFOLEVEL    = (PARMNUM_BASE_INFOLEVEL + SV_MAXFREEPAGEDPOOLCHUNKS_PARMNUM);
  SV_MINPAGEDPOOLCHUNKSIZE_INFOLEVEL     = (PARMNUM_BASE_INFOLEVEL + SV_MINPAGEDPOOLCHUNKSIZE_PARMNUM);
  SV_MAXPAGEDPOOLCHUNKSIZE_INFOLEVEL     = (PARMNUM_BASE_INFOLEVEL + SV_MAXPAGEDPOOLCHUNKSIZE_PARMNUM);
  SV_SENDSFROMPREFERREDPROCESSOR_INFOLEVEL     = (PARMNUM_BASE_INFOLEVEL + SV_SENDSFROMPREFERREDPROCESSOR_PARMNUM);
  SV_MAXTHREADSPERQUEUE_INFOLEVEL     = (PARMNUM_BASE_INFOLEVEL + SV_MAXTHREADSPERQUEUE_PARMNUM);
  SV_CACHEDDIRECTORYLIMIT_INFOLEVEL   = (PARMNUM_BASE_INFOLEVEL + SV_CACHEDDIRECTORYLIMIT_PARMNUM);
  SV_MAXCOPYLENGTH_INFOLEVEL    = (PARMNUM_BASE_INFOLEVEL + SV_MAXCOPYLENGTH_PARMNUM);
  SV_ENABLEBULKTRANSFER_INFOLEVEL = (PARMNUM_BASE_INFOLEVEL + SV_ENABLEBULKTRANSFER_PARMNUM);
  SV_ENABLECOMPRESSION_INFOLEVEL= (PARMNUM_BASE_INFOLEVEL + SV_ENABLECOMPRESSION_PARMNUM);
  SV_AUTOSHAREWKS_INFOLEVEL     = (PARMNUM_BASE_INFOLEVEL + SV_AUTOSHAREWKS_PARMNUM);
  SV_AUTOSHARESERVER_INFOLEVEL  = (PARMNUM_BASE_INFOLEVEL + SV_AUTOSHARESERVER_PARMNUM);

  SVI1_NUM_ELEMENTS       = 5;
  SVI2_NUM_ELEMENTS       = 40;
  SVI3_NUM_ELEMENTS       = 44;

//
//      Maxmimum length for command string to NetServerAdminCommand.
//

  SV_MAX_CMD_LEN          = PATHLEN;

//
//      Masks describing AUTOPROFILE parameters
//

  SW_AUTOPROF_LOAD_MASK   = $1;
  SW_AUTOPROF_SAVE_MASK   = $2;

//
//      Max size of svX_srvheuristics.
//

  SV_MAX_SRV_HEUR_LEN     = 32;      // Max heuristics info string length.

//
//      Equate for use with sv102_licenses.
//

  SV_USERS_PER_LICENSE    = 5;
//
// Data Structures - SERVER
//

type

SERVER_INFO_100 = record
  sv100_platform_id : Integer;
  sv100_name : PWideChar;
end;
PSERVER_INFO_100 = ^SERVER_INFO_100;

SERVER_INFO_101 = record
  sv101_platform_id : Integer;
  sv101_name : PWideChar;
  sv101_version_major : Integer;
  sv101_version_minor : Integer;
  sv101_type : Integer;
  sv101_comment : PWideChar;
end;
PSERVER_INFO_101 = ^SERVER_INFO_101;

SERVER_INFO_102 = record
  sv102_platform_id : Integer;
  sv102_name : PWideChar;
  sv102_version_major : Integer;
  sv102_version_minor : Integer;
  sv102_type : Integer;
  sv102_comment: PWideChar;
  sv102_users : Integer;
  sv102_disc : Integer;
  sv102_hidden : BOOL;
  sv102_announce : Integer;
  sv102_anndelta : Integer;
  sv102_licenses : Integer;
  sv102_userpath : PWideChar;
end;
PSERVER_INFO_102 = ^SERVER_INFO_102;

SERVER_INFO_402 = record
  sv402_ulist_mtime : Integer;
  sv402_glist_mtime : Integer;
  sv402_alist_mtime : Integer;
  sv402_alerts : PWideChar;
  sv402_security : Integer;
  sv402_numadmin : Integer;
  sv402_lanmask : Integer;
  sv402_guestacct : PWideChar;
  sv402_chdevs : Integer;
  sv402_chdevq : Integer;
  sv402_chdevjobs : Integer;
  sv402_connections : Integer;
  sv402_shares : Integer;
  sv402_openfiles : Integer;
  sv402_sessopens : Integer;
  sv402_sessvcs : Integer;
  sv402_sessreqs : Integer;
  sv402_opensearch : Integer;
  sv402_activelocks : Integer;
  sv402_numreqbuf : Integer;
  sv402_sizreqbuf : Integer;
  sv402_numbigbuf : Integer;
  sv402_numfiletasks : Integer;
  sv402_alertsched : Integer;
  sv402_erroralert : Integer;
  sv402_logonalert : Integer;
  sv402_accessalert : Integer;
  sv402_diskalert : Integer;
  sv402_netioalert : Integer;
  sv402_maxauditsz : Integer;
  sv402_srvheuristics : PWideChar;
end;
PSERVER_INFO_402 = ^SERVER_INFO_402;

SERVER_INFO_403 = record
  sv403_ulist_mtime : Integer;
  sv403_glist_mtime : Integer;
  sv403_alist_mtime : Integer;
  sv403_alerts : PWideChar;
  sv403_security : Integer;
  sv403_numadmin : Integer;
  sv403_lanmask : Integer;
  sv403_guestacct : PWideChar;
  sv403_chdevs : Integer;
  sv403_chdevq : Integer;
  sv403_chdevjobs : Integer;
  sv403_connections : Integer;
  sv403_shares : Integer;
  sv403_openfiles : Integer;
  sv403_sessopens : Integer;
  sv403_sessvcs : Integer;
  sv403_sessreqs : Integer;
  sv403_opensearch : Integer;
  sv403_activelocks : Integer;
  sv403_numreqbuf : Integer;
  sv403_sizreqbuf : Integer;
  sv403_numbigbuf : Integer;
  sv403_numfiletasks : Integer;
  sv403_alertsched : Integer;
  sv403_erroralert : Integer;
  sv403_logonalert : Integer;
  sv403_accessalert : Integer;
  sv403_diskalert : Integer;
  sv403_netioalert : Integer;
  sv403_maxauditsz : Integer;
  sv403_srvheuristics : PWideChar;
  sv403_auditedevents : Integer;
  sv403_autoprofile : Integer;
  sv403_autopath : PWideChar;
end;
PSERVER_INFO_403 = ^SERVER_INFO_403;

SERVER_INFO_502 = record
  sv502_sessopens : Integer;
  sv502_sessvcs : Integer;
  sv502_opensearch : Integer;
  sv502_sizreqbuf : Integer;
  sv502_initworkitems : Integer;
  sv502_maxworkitems : Integer;
  sv502_rawworkitems : Integer;
  sv502_irpstacksize : Integer;
  sv502_maxrawbuflen : Integer;
  sv502_sessusers : Integer;
  sv502_sessconns : Integer;
  sv502_maxpagedmemoryusage : Integer;
  sv502_maxnonpagedmemoryusage : Integer;
  sv502_enablesoftcompat : BOOL;
  sv502_enableforcedlogoff : BOOL;
  sv502_timesource : BOOL;
  sv502_acceptdownlevelapis : BOOL;
  sv502_lmannounce : BOOL;
end;
PSERVER_INFO_502 = ^SERVER_INFO_502;

SERVER_INFO_503 = record
  sv503_sessopens : Integer;
  sv503_sessvcs : Integer;
  sv503_opensearch : Integer;
  sv503_sizreqbuf : Integer;
  sv503_initworkitems : Integer;
  sv503_maxworkitems : Integer;
  sv503_rawworkitems : Integer;
  sv503_irpstacksize : Integer;
  sv503_maxrawbuflen : Integer;
  sv503_sessusers : Integer;
  sv503_sessconns : Integer;
  sv503_maxpagedmemoryusage : Integer;
  sv503_maxnonpagedmemoryusage : Integer;
  sv503_enablesoftcompat :BOOL;
  sv503_enableforcedlogoff :BOOL;
  sv503_timesource :BOOL;
  sv503_acceptdownlevelapis :BOOL;
  sv503_lmannounce :BOOL;
  sv503_domain : PWideChar;
  sv503_maxcopyreadlen : Integer;
  sv503_maxcopywritelen : Integer;
  sv503_minkeepsearch : Integer;
  sv503_maxkeepsearch : Integer;
  sv503_minkeepcomplsearch : Integer;
  sv503_maxkeepcomplsearch : Integer;
  sv503_threadcountadd : Integer;
  sv503_numblockthreads : Integer;
  sv503_scavtimeout : Integer;
  sv503_minrcvqueue : Integer;
  sv503_minfreeworkitems : Integer;
  sv503_xactmemsize : Integer;
  sv503_threadpriority : Integer;
  sv503_maxmpxct : Integer;
  sv503_oplockbreakwait : Integer;
  sv503_oplockbreakresponsewait : Integer;
  sv503_enableoplocks : BOOL;
  sv503_enableoplockforceclose : BOOL;
  sv503_enablefcbopens : BOOL;
  sv503_enableraw : BOOL;
  sv503_enablesharednetdrives : BOOL;
  sv503_minfreeconnections : Integer;
  sv503_maxfreeconnections : Integer;
end;
PSERVER_INFO_503 = ^SERVER_INFO_503;

SERVER_INFO_599 = record
  sv599_sessopens : Integer;
  sv599_sessvcs : Integer;
  sv599_opensearch : Integer;
  sv599_sizreqbuf : Integer;
  sv599_initworkitems : Integer;
  sv599_maxworkitems : Integer;
  sv599_rawworkitems : Integer;
  sv599_irpstacksize : Integer;
  sv599_maxrawbuflen : Integer;
  sv599_sessusers : Integer;
  sv599_sessconns : Integer;
  sv599_maxpagedmemoryusage : Integer;
  sv599_maxnonpagedmemoryusage : Integer;
  sv599_enablesoftcompat : BOOL;
  sv599_enableforcedlogoff : BOOL;
  sv599_timesource : BOOL;
  sv599_acceptdownlevelapis : BOOL;
  sv599_lmannounce : BOOL;
  sv599_domain : PWideChar;
  sv599_maxcopyreadlen : Integer;
  sv599_maxcopywritelen : Integer;
  sv599_minkeepsearch : Integer;
  sv599_maxkeepsearch : Integer;
  sv599_minkeepcomplsearch : Integer;
  sv599_maxkeepcomplsearch : Integer;
  sv599_threadcountadd : Integer;
  sv599_numblockthreads : Integer;
  sv599_scavtimeout : Integer;
  sv599_minrcvqueue : Integer;
  sv599_minfreeworkitems : Integer;
  sv599_xactmemsize : Integer;
  sv599_threadpriority : Integer;
  sv599_maxmpxct : Integer;
  sv599_oplockbreakwait : Integer;
  sv599_oplockbreakresponsewait : Integer;
  sv599_enableoplocks : BOOL;
  sv599_enableoplockforceclose : BOOL;
  sv599_enablefcbopens : BOOL;
  sv599_enableraw : BOOL;
  sv599_enablesharednetdrives : BOOL;
  sv599_minfreeconnections : Integer;
  sv599_maxfreeconnections : Integer;
  sv599_initsesstable : Integer;
  sv599_initconntable : Integer;
  sv599_initfiletable : Integer;
  sv599_initsearchtable : Integer;
  sv599_alertschedule : Integer;
  sv599_errorthreshold : Integer;
  sv599_networkerrorthreshold : Integer;
  sv599_diskspacethreshold : Integer;
  sv599_reserved : Integer;
  sv599_maxlinkdelay : Integer;
  sv599_minlinkthroughput : Integer;
  sv599_linkinfovalidtime : Integer;
  sv599_scavqosinfoupdatetime : Integer;
  sv599_maxworkitemidletime : Integer;
end;
PSERVER_INFO_599 = ^SERVER_INFO_599;

SERVER_INFO_598 = record
  sv598_maxrawworkitems : Integer;
  sv598_maxthreadsperqueue : Integer;
  sv598_producttype : Integer;
  sv598_serversize : Integer;
  sv598_connectionlessautodisc : Integer;
  sv598_sharingviolationretries : Integer;
  sv598_sharingviolationdelay : Integer;
  sv598_maxglobalopensearch : Integer;
  sv598_removeduplicatesearches : Integer;
  sv598_lockviolationoffset : Integer;
  sv598_lockviolationdelay : Integer;
  sv598_mdlreadswitchover : Integer;
  sv598_cachedopenlimit : Integer;
  sv598_otherqueueaffinity : Integer;
  sv598_restrictnullsessaccess : BOOL;
  sv598_enablewfw311directipx : BOOL;
  sv598_queuesamplesecs : Integer;
  sv598_balancecount : Integer;
  sv598_preferredaffinity : Integer;
  sv598_maxfreerfcbs : Integer;
  sv598_maxfreemfcbs : Integer;
  sv598_maxfreelfcbs : Integer;
  sv598_maxfreepagedpoolchunks : Integer;
  sv598_minpagedpoolchunksize : Integer;
  sv598_maxpagedpoolchunksize : Integer;
  sv598_sendsfrompreferredprocessor : BOOL;
  sv598_cacheddirectorylimit : Integer;
  sv598_maxcopylength : Integer;
  sv598_enablebulktransfer : BOOL;
  sv598_enablecompression : BOOL;
  sv598_autosharewks : BOOL;
  sv598_autoshareserver : BOOL;
end;
PSERVER_INFO_598 = ^SERVER_INFO_598;

SERVER_INFO_1005 = record
  sv1005_comment : PWideChar;
end;
PSERVER_INFO_1005 = ^SERVER_INFO_1005;

SERVER_INFO_1107 = record
  sv1107_users : Integer;
end;
PSERVER_INFO_1107 = ^SERVER_INFO_1107;

SERVER_INFO_1010 = record
  sv1010_disc : Integer;
end;
PSERVER_INFO_1010 = ^SERVER_INFO_1010;

SERVER_INFO_1016 = record
  sv1016_hidden : BOOL;
end;
PSERVER_INFO_1016 = ^SERVER_INFO_1016;

SERVER_INFO_1017 = record
  sv1017_announce : Integer;
end;
PSERVER_INFO_1017 = ^SERVER_INFO_1017;

SERVER_INFO_1018 = record
  sv1018_anndelta : Integer;
end;
PSERVER_INFO_1018 = ^SERVER_INFO_1018;

SERVER_INFO_1501 = record
  sv1501_sessopens : Integer;
end;
PSERVER_INFO_1501 = ^SERVER_INFO_1501;

SERVER_INFO_1502 = record
  sv1502_sessvcs : Integer;
end;
PSERVER_INFO_1502 = ^SERVER_INFO_1502;

SERVER_INFO_1503 = record
  sv1503_opensearch : Integer;
end;
PSERVER_INFO_1503 = ^SERVER_INFO_1503;

SERVER_INFO_1506 = record
  sv1506_maxworkitems : Integer;
end;
PSERVER_INFO_1506 = ^SERVER_INFO_1506;

SERVER_INFO_1509 = record
  sv1509_maxrawbuflen : Integer;
end;
PSERVER_INFO_1509 = ^SERVER_INFO_1509;

SERVER_INFO_1510 = record
  sv1510_sessusers : Integer;
end;
PSERVER_INFO_1510 = ^SERVER_INFO_1510;

SERVER_INFO_1511 = record
  sv1511_sessconns : Integer;
end;
PSERVER_INFO_1511 = ^SERVER_INFO_1511;

SERVER_INFO_1512 = record
  sv1512_maxnonpagedmemoryusage : Integer;
end;
PSERVER_INFO_1512 = ^SERVER_INFO_1512;

SERVER_INFO_1513 = record
  sv1513_maxpagedmemoryusage : Integer;
end;
PSERVER_INFO_1513 = ^SERVER_INFO_1513;

SERVER_INFO_1514 = record
  sv1514_enablesoftcompat : BOOL;
end;
PSERVER_INFO_1514 = ^SERVER_INFO_1514;

SERVER_INFO_1515 = record
  sv1515_enableforcedlogoff : BOOL;
end;
PSERVER_INFO_1515 = ^SERVER_INFO_1515;

SERVER_INFO_1516 = record
  sv1516_timesource : BOOL;
end;
PSERVER_INFO_1516 = ^SERVER_INFO_1516;

SERVER_INFO_1518 = record
  sv1518_lmannounce : BOOL;
end;
PSERVER_INFO_1518 = ^SERVER_INFO_1518;

SERVER_INFO_1520 = record
  sv1520_maxcopyreadlen : Integer;
end;
PSERVER_INFO_1520 = ^SERVER_INFO_1520;

SERVER_INFO_1521 = record
  sv1521_maxcopywritelen : Integer;
end;
PSERVER_INFO_1521 = ^SERVER_INFO_1521;

SERVER_INFO_1522 = record
  sv1522_minkeepsearch : Integer;
end;
PSERVER_INFO_1522 = ^SERVER_INFO_1522;

SERVER_INFO_1523 = record
  sv1523_maxkeepsearch : Integer;
end;
PSERVER_INFO_1523 = ^SERVER_INFO_1523;

SERVER_INFO_1524 = record
  sv1524_minkeepcomplsearch : Integer;
end;
PSERVER_INFO_1524 = ^SERVER_INFO_1524;

SERVER_INFO_1525 = record
  sv1525_maxkeepcomplsearch : Integer;
end;
PSERVER_INFO_1525 = ^SERVER_INFO_1525;

SERVER_INFO_1528 = record
  sv1528_scavtimeout : Integer;
end;
PSERVER_INFO_1528 = ^SERVER_INFO_1528;

SERVER_INFO_1529 = record
  sv1529_minrcvqueue : Integer;
end;
PSERVER_INFO_1529 = ^SERVER_INFO_1529;

SERVER_INFO_1530 = record
  sv1530_minfreeworkitems : Integer;
end;
PSERVER_INFO_1530 = ^SERVER_INFO_1530;

SERVER_INFO_1533 = record
  sv1533_maxmpxct : Integer;
end;
PSERVER_INFO_1533 = ^SERVER_INFO_1533;

SERVER_INFO_1534 = record
  sv1534_oplockbreakwait : Integer;
end;
PSERVER_INFO_1534 = ^SERVER_INFO_1534;

SERVER_INFO_1535 = record
  sv1535_oplockbreakresponsewait : Integer;
end;
PSERVER_INFO_1535 = ^SERVER_INFO_1535;

SERVER_INFO_1536 = record
  sv1536_enableoplocks : BOOL;
end;
PSERVER_INFO_1536 = ^SERVER_INFO_1536;

SERVER_INFO_1537 = record
  sv1537_enableoplockforceclose : BOOL;
end;
PSERVER_INFO_1537 = ^SERVER_INFO_1537;

SERVER_INFO_1538 = record
  sv1538_enablefcbopens : BOOL;
end;
PSERVER_INFO_1538 = ^SERVER_INFO_1538;

SERVER_INFO_1539 = record
  sv1539_enableraw : BOOL;
end;
PSERVER_INFO_1539 = ^SERVER_INFO_1539;

SERVER_INFO_1540 = record
  sv1540_enablesharednetdrives : BOOL;
end;
PSERVER_INFO_1540 = ^SERVER_INFO_1540;

SERVER_INFO_1541 = record
  sv1541_minfreeconnections : BOOL;
end;
PSERVER_INFO_1541 = ^SERVER_INFO_1541;

SERVER_INFO_1542 = record
  sv1542_maxfreeconnections : BOOL;
end;
PSERVER_INFO_1542 = ^SERVER_INFO_1542;

SERVER_INFO_1543 = record
  sv1543_initsesstable : Integer;
end;
PSERVER_INFO_1543 = ^SERVER_INFO_1543;

SERVER_INFO_1544 = record
  sv1544_initconntable : Integer;
end;
PSERVER_INFO_1544 = ^SERVER_INFO_1544;

SERVER_INFO_1545 = record
  sv1545_initfiletable : Integer;
end;
PSERVER_INFO_1545 = ^SERVER_INFO_1545;

SERVER_INFO_1546 = record
  sv1546_initsearchtable : Integer;
end;
PSERVER_INFO_1546 = ^SERVER_INFO_1546;

SERVER_INFO_1547 = record
  sv1547_alertschedule : Integer;
end;
PSERVER_INFO_1547 = ^SERVER_INFO_1547;

SERVER_INFO_1548 = record
  sv1548_errorthreshold : Integer;
end;
PSERVER_INFO_1548 = ^SERVER_INFO_1548;

SERVER_INFO_1549 = record
  sv1549_networkerrorthreshold : Integer;
end;
PSERVER_INFO_1549 = ^SERVER_INFO_1549;

SERVER_INFO_1550 = record
  sv1550_diskspacethreshold : Integer;
end;
PSERVER_INFO_1550 = ^SERVER_INFO_1550;

SERVER_INFO_1552 = record
  sv1552_maxlinkdelay : Integer;
end;
PSERVER_INFO_1552 = ^SERVER_INFO_1552;

SERVER_INFO_1553 = record
  sv1553_minlinkthroughput : Integer;
end;
PSERVER_INFO_1553 = ^SERVER_INFO_1553;

SERVER_INFO_1554 = record
  sv1554_linkinfovalidtime : Integer;
end;
PSERVER_INFO_1554 = ^SERVER_INFO_1554;

SERVER_INFO_1555 = record
  sv1555_scavqosinfoupdatetime : Integer;
end;
PSERVER_INFO_1555 = ^SERVER_INFO_1555;

SERVER_INFO_1556 = record
  sv1556_maxworkitemidletime : Integer;
end;
PSERVER_INFO_1556 = ^SERVER_INFO_1556;

SERVER_INFO_1557 = record
  sv1557_maxrawworkitems : Integer;
end;
PSERVER_INFO_1557 = ^SERVER_INFO_1557;

SERVER_INFO_1560 = record
  sv1560_producttype : Integer;
end;
PSERVER_INFO_1560 = ^SERVER_INFO_1560;

SERVER_INFO_1561 = record
  sv1561_serversize : Integer;
end;
PSERVER_INFO_1561 = ^SERVER_INFO_1561;

SERVER_INFO_1562 = record
  sv1562_connectionlessautodisc : Integer;
end;
PSERVER_INFO_1562 = ^SERVER_INFO_1562;

SERVER_INFO_1563 = record
  sv1563_sharingviolationretries : Integer;
end;
PSERVER_INFO_1563 = ^SERVER_INFO_1563;

SERVER_INFO_1564 = record
  sv1564_sharingviolationdelay : Integer;
end;
PSERVER_INFO_1564 = ^SERVER_INFO_1564;

SERVER_INFO_1565 = record
  sv1565_maxglobalopensearch : Integer;
end;
PSERVER_INFO_1565 = ^SERVER_INFO_1565;

SERVER_INFO_1566 = record
  sv1566_removeduplicatesearches : BOOL;
end;
PSERVER_INFO_1566 = ^SERVER_INFO_1566;

SERVER_INFO_1567 = record
  sv1567_lockviolationretries : Integer;
end;
PSERVER_INFO_1567 = ^SERVER_INFO_1567;

SERVER_INFO_1568 = record
  sv1568_lockviolationoffset : Integer;
end;
PSERVER_INFO_1568 = ^SERVER_INFO_1568;

SERVER_INFO_1569 = record
  sv1569_lockviolationdelay : Integer;
end;
PSERVER_INFO_1569 = ^SERVER_INFO_1569;

SERVER_INFO_1570 = record
  sv1570_mdlreadswitchover : Integer;
end;
PSERVER_INFO_1570 = ^SERVER_INFO_1570;

SERVER_INFO_1571 = record
  sv1571_cachedopenlimit : Integer;
end;
PSERVER_INFO_1571 = ^SERVER_INFO_1571;

SERVER_INFO_1572 = record
  sv1572_criticalthreads : Integer;
end;
PSERVER_INFO_1572 = ^SERVER_INFO_1572;

SERVER_INFO_1573 = record
  sv1573_restrictnullsessaccess : Integer;
end;
PSERVER_INFO_1573 = ^SERVER_INFO_1573;

SERVER_INFO_1574 = record
  sv1574_enablewfw311directipx : Integer;
end;
PSERVER_INFO_1574 = ^SERVER_INFO_1574;

SERVER_INFO_1575 = record
  sv1575_otherqueueaffinity : Integer;
end;
PSERVER_INFO_1575 = ^SERVER_INFO_1575;

SERVER_INFO_1576 = record
  sv1576_queuesamplesecs : Integer;
end;
PSERVER_INFO_1576 = ^SERVER_INFO_1576;

SERVER_INFO_1577 = record
  sv1577_balancecount : Integer;
end;
PSERVER_INFO_1577 = ^SERVER_INFO_1577;

SERVER_INFO_1578 = record
  sv1578_preferredaffinity : Integer;
end;
PSERVER_INFO_1578 = ^SERVER_INFO_1578;

SERVER_INFO_1579 = record
  sv1579_maxfreerfcbs : Integer;
end;
PSERVER_INFO_1579 = ^SERVER_INFO_1579;

SERVER_INFO_1580 = record
  sv1580_maxfreemfcbs : Integer;
end;
PSERVER_INFO_1580 = ^SERVER_INFO_1580;

SERVER_INFO_1581 = record
  sv1581_maxfreemlcbs : Integer;
end;
PSERVER_INFO_1581 = ^SERVER_INFO_1581;

SERVER_INFO_1582 = record
  sv1582_maxfreepagedpoolchunks : Integer;
end;
PSERVER_INFO_1582 = ^SERVER_INFO_1582;

SERVER_INFO_1583 = record
  sv1583_minpagedpoolchunksize : Integer;
end;
PSERVER_INFO_1583 = ^SERVER_INFO_1583;

SERVER_INFO_1584 = record
  sv1584_maxpagedpoolchunksize : Integer;
end;
PSERVER_INFO_1584 = ^SERVER_INFO_1584;

SERVER_INFO_1585 = record
  sv1585_sendsfrompreferredprocessor : BOOL;
end;
PSERVER_INFO_1585 = ^SERVER_INFO_1585;

SERVER_INFO_1586 = record
  sv1586_maxthreadsperqueue : Integer;
end;
PSERVER_INFO_1586 = ^SERVER_INFO_1586;

SERVER_INFO_1587 = record
  sv1587_cacheddirectorylimit : Integer;
end;
PSERVER_INFO_1587 = ^SERVER_INFO_1587;

SERVER_INFO_1588 = record
  sv1588_maxcopylength : Integer;
end;
PSERVER_INFO_1588 = ^SERVER_INFO_1588;

SERVER_INFO_1589 = record
  sv1589_enablebulktransfer : Integer;
end;
PSERVER_INFO_1589 = ^SERVER_INFO_1589;

SERVER_INFO_1590 = record
  sv1590_enablecompression : Integer;
end;
PSERVER_INFO_1590 = ^SERVER_INFO_1590;

SERVER_INFO_1591 = record
  sv1591_autosharewks : Integer;
end;
PSERVER_INFO_1591 = ^SERVER_INFO_1591;

SERVER_INFO_1592 = record
  sv1592_autosharewks : Integer;
end;
PSERVER_INFO_1592 = ^SERVER_INFO_1592;

//
// A special structure definition is required in order for this
// structure to work with RPC.  The problem is that having addresslength
// indicate the number of bytes in address means that RPC must know the
// link between the two.
//
(*
SERVER_TRANSPORT_INFO_0 = record
    svti0_numberofvcs : Integer;
    svti0_transportname : PWideChar;
    svti0_transportaddress : array [1..svti0_transportaddresslength] of byte;
    svti0_transportaddresslength : Integer;
    svti0_networkaddress : PWideChar;
end;
PSERVER_TRANSPORT_INFO_0 = ^SERVER_TRANSPORT_INFO_0;

SERVER_TRANSPORT_INFO_1 = record
    svti1_numberofvcs : Integer;
    svti1_transportname : PWideChar;
    svti1_transportaddress : array [1..svti1_transportaddresslength] of byte;
    svti1_transportaddresslength : Integer;
    svti1_networkaddress : PWideChar;
    svti1_domain : PWideChar;
end;
PSERVER_TRANSPORT_INFO_1 = ^SERVER_TRANSPORT_INFO_1;
*)
//
// Function Prototypes - SERVER
//

function NetServerEnum (
  serverName : PWideChar;
  level : Integer;
  var BufPtr : Pointer;
  prefMaxLen : Integer;
  var entriesRead, totalEntries : Integer;
  servertype : Integer;
  domain : PWideChar;
  var resume_handle : Integer
) : NetAPIStatus; stdcall;

function NetServerEnumEx (
  serverName : PWideChar;
  level : Integer;
  var BufPtr : Pointer;
  prefMaxLen : Integer;
  var entriesRead, totalEntries : Integer;
  serverType : PWideChar;
  domain : PWideChar;
  FirstNameToReturn : PWideChar
) : NetAPIStatus; stdcall;

function NetServerGetInfo (
  serverName : PWideChar;
  level : Integer;
  var bufptr : Pointer
) : NetAPIStatus; stdcall;

function NetServerSetInfo (
  serverName : PWideChar;
  level : Integer;
  buf : Pointer;
  var ParmError : Integer
) : NetAPIStatus; stdcall;

//
// Temporary hack function.
//

function NetServerSetInfoCommandLine (
  argc : word;
  var argv
) : NetAPIStatus; cdecl;

function NetServerDiskEnum (
  serverName : PWideChar;
  level : Integer;
  var BufPtr : Pointer;
  prefMaxLen : Integer;
  var entriesRead, totalEntries, resumeHandle : Integer
) : NetAPIStatus; stdcall;

function NetServerComputerNameAdd (
  ServerName : PWideChar;
  EmulatedDomainName, EnulatedServerName : PWideChar
) : NetAPIStatus; stdcall;

function NetServerComputerNameDel (
  ServerName : PWideChar;
  EmulatedServerName : PWideChar
) : NetAPIStatus; stdcall;

function NetServerTransportAdd (
  servername : PWideChar;        // NB the is LPTSTR in 'C'. It's probably a typo
  level : Integer;
  bufptr : Pointer
) : NetAPIStatus; stdcall;

function NetServerTransportAddEx (
  servername : PWideChar;       //           ""                  ""
  level : Integer;
  bufptr : Pointer
) : NetAPIStatus; stdcall;

function NetServerTransportDel (
  servername : PWideChar;      //            ""                  ""
  level : Integer;
  bufptr : Pointer
) : NetAPIStatus; stdcall;

function NetServerTransportEnum (
  servername : PWideChar;     //             ""                  ""
  level : Integer;
  var BufPtr : Pointer;
  prefMaxLen : Integer;
  var entriesRead, totalEntries, resumeHandle : Integer
) : NetAPIStatus; stdcall;

//
// The following function can be called by Win NT services to register
// their service type.  This function is exported from advapi32.dll.
// Therefore, if this is the only function called by that service, then
// it is not necessary to link to netapi32.lib.
//
function SetServiceBits(
  hServiceStatus : Integer; // SERVICE_STATUS_HANDLE = DWORD;
  dwServiceBits : Integer;
  bSetBitsOn : BOOL;
  bUpdateImmediately : BOOL
) : BOOL; cdecl;

implementation

function SetServiceBits;               external 'ADVAPI32.DLL';
function NetServerEnum;                external 'NETAPI32.DLL';
function NetServerEnumEx;              external 'NETAPI32.DLL';
function NetServerGetInfo;             external 'NETAPI32.DLL';
function NetServerSetInfo;             external 'NETAPI32.DLL';
function NetServerSetInfoCommandLine;  external 'NETAPI32.DLL';
function NetServerDiskEnum;            external 'NETAPI32.DLL';
function NetServerComputerNameAdd;     external 'NETAPI32.DLL';
function NetServerComputerNameDel;     external 'NETAPI32.DLL';
function NetServerTransportAdd;        external 'NETAPI32.DLL';
function NetServerTransportAddEx;      external 'NETAPI32.DLL';
function NetServerTransportDel;        external 'NETAPI32.DLL';
function NetServerTransportEnum;       external 'NETAPI32.DLL';

end.

