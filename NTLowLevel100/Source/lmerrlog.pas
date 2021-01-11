unit lmerrlog;

interface

uses lmglobal;

const

  LOGFLAGS_FORWARD    = 0;
  LOGFLAGS_BACKWARD   = $1;
  LOGFLAGS_SEEK       = $2;

//
//  Generic (could be used by more than one service)
//   error log messages from 0 to 25
//
// Do not change the comments following the manifest constants without
// understanding how mapmsg works.
//

   ERRLOG_BASE = 3100;        (* NELOG errors start here *)

   NELOG_Internal_Error        = ERRLOG_BASE + 0;
    (*
    * The operation failed because a network software error occurred.
    *)

   NELOG_Resource_Shortage     = ERRLOG_BASE + 1;
    (*
    * The system ran out of a resource controlled by the %1 option.
    *)

   NELOG_Unable_To_Lock_Segment    = ERRLOG_BASE + 2;
    (*
    * The service failed to obtain a long-term lock on the
    *  segment for network control blocks (NCBs). The error code is the data.
    *)

   NELOG_Unable_To_Unlock_Segment  = ERRLOG_BASE + 3;
    (*
    * The service failed to release the long-term lock on the
    *  segment for network control blocks (NCBs). The error code is the data.
    *)

   NELOG_Uninstall_Service     = ERRLOG_BASE + 4;
    (*
    * There was an error stopping service %1.
    *  The error code from NetServiceControl is the data.
    *)

   NELOG_Init_Exec_Fail        = ERRLOG_BASE + 5;
    (*
    * Initialization failed because of a system execution failure on
    *  path %1. The system error code is the data.
    *)

   NELOG_Ncb_Error         = ERRLOG_BASE + 6;
    (*
    * An unexpected network control block (NCB) was received. The NCB is the data.
    *)

   NELOG_Net_Not_Started       = ERRLOG_BASE + 7;
    (*
    * The network is not started.
    *)

   NELOG_Ioctl_Error       = ERRLOG_BASE + 8;
    (*
    * A DosDevIoctl or DosFsCtl to NETWKSTA.SYS failed.
    * The data shown is in this format:
    *     DWORD  approx CS:IP of call to ioctl or fsctl
    *     WORD   error code
    *     WORD   ioctl or fsctl number
    *)

   NELOG_System_Semaphore      = ERRLOG_BASE + 9;
    (*
    * Unable to create or open system semaphore %1.
    *  The error code is the data.
    *)

   NELOG_Init_OpenCreate_Err   = ERRLOG_BASE + 10;
    (*
    * Initialization failed because of an open/create error on the
    *  file %1. The system error code is the data.
    *)

   NELOG_NetBios           = ERRLOG_BASE + 11;
    (*
    * An unexpected NetBIOS error occurred.
    *  The error code is the data.
    *)

   NELOG_SMB_Illegal       = ERRLOG_BASE + 12;
    (*
    * An illegal server message block (SMB) was received.
    *  The SMB is the data.
    *)

   NELOG_Service_Fail      = ERRLOG_BASE + 13;
    (*
    * Initialization failed because the requested service %1
    *  could not be started.
   *)

   NELOG_Entries_Lost      = ERRLOG_BASE + 14;
    (*
    * Some entries in the error log were lost because of a buffer
    * overflow.
    *)


//
//  Server specific error log messages from 20 to 40
//

   NELOG_Init_Seg_Overflow     = ERRLOG_BASE + 20;
    (*
    * Initialization parameters controlling resource usage other
    *  than net buffers are sized so that too much memory is needed.
    *)

   NELOG_Srv_No_Mem_Grow       = ERRLOG_BASE + 21;
    (*
    * The server cannot increase the size of a memory segment.
    *)

   NELOG_Access_File_Bad       = ERRLOG_BASE + 22;
    (*
    * Initialization failed because account file %1 is either incorrect
    * or not present.
    *)

   NELOG_Srvnet_Not_Started    = ERRLOG_BASE + 23;
    (*
    * Initialization failed because network %1 was not started.
    *)

   NELOG_Init_Chardev_Err      = ERRLOG_BASE + 24;
    (*
    * The server failed to start. Either all three chdev
    *  parameters must be zero or all three must be nonzero.
    *)

   NELOG_Remote_API        = ERRLOG_BASE + 25;
    (* A remote API request was halted due to the following
    * invalid description string: %1.
    *)

   NELOG_Ncb_TooManyErr        = ERRLOG_BASE + 26;
    (* The network %1 ran out of network control blocks (NCBs).  You may need to increase NCBs
    * for this network.  The following information includes the
    * number of NCBs submitted by the server when this error occurred:
    *)

   NELOG_Mailslot_err      = ERRLOG_BASE + 27;
    (* The server cannot create the %1 mailslot needed to send
    * the ReleaseMemory alert message.  The error received is:
    *)

   NELOG_ReleaseMem_Alert      = ERRLOG_BASE + 28;
    (* The server failed to register for the ReleaseMemory alert,
    * with recipient %1. The error code from
    * NetAlertStart is the data.
    *)

   NELOG_AT_cannot_write       = ERRLOG_BASE + 29;
    (* The server cannot update the AT schedule file. The file
    * is corrupted.
    *)

   NELOG_Cant_Make_Msg_File    = ERRLOG_BASE + 30;
    (* The server encountered an error when calling
    * NetIMakeLMFileName. The error code is the data.
    *)

   NELOG_Exec_Netservr_NoMem   = ERRLOG_BASE + 31;
    (* Initialization failed because of a system execution failure on
    * path %1. There is not enough memory to start the process.
    * The system error code is the data.
    *)

   NELOG_Server_Lock_Failure   = ERRLOG_BASE + 32;
    (* Longterm lock of the server buffers failed.
    * Check swap disk's free space and restart the system to start the server.
    *)

//
//  Message service and POPUP specific error log messages from 40 to 55
//

   NELOG_Msg_Shutdown      = ERRLOG_BASE + 40;
    (*
    * The service has stopped due to repeated consecutive
    *  occurrences of a network control block (NCB) error.  The last bad NCB follows
    *  in raw data.
    *)

   NELOG_Msg_Sem_Shutdown      = ERRLOG_BASE + 41;
    (*
    * The Message server has stopped due to a lock on the
    *  Message server shared data segment.
    *)

   NELOG_Msg_Log_Err       = ERRLOG_BASE + 50;
    (*
    * A file system error occurred while opening or writing to the
    *  system message log file %1. Message logging has been
    *  switched off due to the error. The error code is the data.
    *)



   NELOG_VIO_POPUP_ERR     = ERRLOG_BASE + 51;
    (*
    * Unable to display message POPUP due to system VIO call error.
    *  The error code is the data.
    *)

   NELOG_Msg_Unexpected_SMB_Type   = ERRLOG_BASE + 52;
    (*
    * An illegal server message block (SMB) was received.  The SMB is the data.
    *)

//
//  Workstation specific error log messages from 60 to 75
//


   NELOG_Wksta_Infoseg     = ERRLOG_BASE + 60;
    (*
    * The workstation information segment is bigger than 64K.
    *  The size follows, in DWORD format:
    *)

   NELOG_Wksta_Compname        = ERRLOG_BASE + 61;
    (*
    * The workstation was unable to get the name-number of the computer.
    *)

   NELOG_Wksta_BiosThreadFailure   = ERRLOG_BASE + 62;
    (*
    * The workstation could not initialize the Async NetBIOS Thread.
    *  The error code is the data.
    *)

   NELOG_Wksta_IniSeg      = ERRLOG_BASE + 63;
    (*
    * The workstation could not open the initial shared segment.
    *  The error code is the data.
    *)

   NELOG_Wksta_HostTab_Full    = ERRLOG_BASE + 64;
    (*
    * The workstation host table is full.
    *)

   NELOG_Wksta_Bad_Mailslot_SMB    = ERRLOG_BASE + 65;
    (*
    * A bad mailslot server message block (SMB) was received.  The SMB is the data.
    *)

   NELOG_Wksta_UASInit     = ERRLOG_BASE + 66;
    (*
    * The workstation encountered an error while trying to start the user accounts database.
    *  The error code is the data.
    *)

   NELOG_Wksta_SSIRelogon      = ERRLOG_BASE + 67;
    (*
    * The workstation encountered an error while responding to an SSI revalidation request.
    *  The function code and the error codes are the data.
    *)

//
//  Alerter service specific error log messages from 70 to 79
//


   NELOG_Build_Name        = ERRLOG_BASE + 70;
    (*
    * The Alerter service had a problem creating the list of
    * alert recipients.  The error code is %1.
    *)

   NELOG_Name_Expansion        = ERRLOG_BASE + 71;
    (*
    * There was an error expanding %1 as a group name. Try
    *  splitting the group into two or more smaller groups.
    *)

   NELOG_Message_Send      = ERRLOG_BASE + 72;
    (*
    * There was an error sending %2 the alert message -
    *  (
    *  %3 )
    *  The error code is %1.
    *)

   NELOG_Mail_Slt_Err      = ERRLOG_BASE + 73;
    (*
    * There was an error in creating or reading the alerter mailslot.
    *  The error code is %1.
    *)

   NELOG_AT_cannot_read        = ERRLOG_BASE + 74;
    (*
    * The server could not read the AT schedule file.
    *)

   NELOG_AT_sched_err      = ERRLOG_BASE + 75;
    (*
    * The server found an invalid AT schedule record.
    *)

   NELOG_AT_schedule_file_created  = ERRLOG_BASE + 76;
    (*
    * The server could not find an AT schedule file so it created one.
    *)

   NELOG_Srvnet_NB_Open        = ERRLOG_BASE + 77;
    (*
    * The server could not access the %1 network with NetBiosOpen.
    *)

   NELOG_AT_Exec_Err       = ERRLOG_BASE + 78;
    (*
    * The AT command processor could not run %1.
   *)

//
//      Cache Lazy Write and HPFS386 specific error log messages from 80 to 89
//

   NELOG_Lazy_Write_Err            = ERRLOG_BASE + 80;
        (*
        * WARNING:  Because of a lazy-write error, drive %1 now
        *  contains some corrupted data.  The cache is stopped.
        *)

   NELOG_HotFix            = ERRLOG_BASE + 81;
    (*
    * A defective sector on drive %1 has been replaced (hotfixed).
    * No data was lost.  You should run CHKDSK soon to restore full
    * performance and replenish the volume's spare sector pool.
    *
    * The hotfix occurred while processing a remote request.
    *)

   NELOG_HardErr_From_Server   = ERRLOG_BASE + 82;
    (*
    * A disk error occurred on the HPFS volume in drive %1.
    * The error occurred while processing a remote request.
    *)

   NELOG_LocalSecFail1 = ERRLOG_BASE + 83;
    (*
    * The user accounts database (NET.ACC) is corrupted.  The local security
    * system is replacing the corrupted NET.ACC with the backup
    * made at %1.
    * Any updates made to the database after this time are lost.
    *
    *)

   NELOG_LocalSecFail2 = ERRLOG_BASE + 84;
    (*
    * The user accounts database (NET.ACC) is missing.  The local
    * security system is restoring the backup database
    * made at %1.
    * Any updates made to the database made after this time are lost.
    *
    *)

   NELOG_LocalSecFail3 = ERRLOG_BASE + 85;
    (*
    * Local security could not be started because the user accounts database
    * (NET.ACC) was missing or corrupted, and no usable backup
    * database was present.
    *
    * THE SYSTEM IS NOT SECURE.
    *)

   NELOG_LocalSecGeneralFail   = ERRLOG_BASE + 86;
    (*
    * Local security could not be started because an error
    * occurred during initialization. The error code returned is %1.
    *
    * THE SYSTEM IS NOT SECURE.
    *
    *)

//
//  NETWKSTA.SYS specific error log messages from 90 to 99
//

   NELOG_NetWkSta_Internal_Error   = ERRLOG_BASE + 90;
    (*
    * A NetWksta internal error has occurred:
    *  %1
    *)

   NELOG_NetWkSta_No_Resource  = ERRLOG_BASE + 91;
    (*
    * The redirector is out of a resource: %1.
    *)

   NELOG_NetWkSta_SMB_Err      = ERRLOG_BASE + 92;
    (*
    * A server message block (SMB) error occurred on the connection to %1.
    *  The SMB header is the data.
    *)

   NELOG_NetWkSta_VC_Err       = ERRLOG_BASE + 93;
    (*
    * A virtual circuit error occurred on the session to %1.
    *  The network control block (NCB) command and return code is the data.
    *)

   NELOG_NetWkSta_Stuck_VC_Err = ERRLOG_BASE + 94;
    (*
    * Hanging up a stuck session to %1.
    *)

   NELOG_NetWkSta_NCB_Err      = ERRLOG_BASE + 95;
    (*
    * A network control block (NCB) error occurred (%1).
    *  The NCB is the data.
    *)

   NELOG_NetWkSta_Write_Behind_Err = ERRLOG_BASE + 96;
    (*
    * A write operation to %1 failed.
    *  Data may have been lost.
    *)

   NELOG_NetWkSta_Reset_Err    = ERRLOG_BASE + 97;
    (*
    * Reset of driver %1 failed to complete the network control block (NCB).
    *  The NCB is the data.
    *)

   NELOG_NetWkSta_Too_Many     = ERRLOG_BASE + 98;
    (*
    * The amount of resource %1 requested was more
    *  than the maximum. The maximum amount was allocated.
    *)

//
//  Spooler specific error log messages from 100 to 103
//

   NELOG_Srv_Thread_Failure        = ERRLOG_BASE + 104;
    (*
    * The server could not create a thread.
    *  The THREADS parameter in the CONFIG.SYS file should be increased.
    *)

   NELOG_Srv_Close_Failure         = ERRLOG_BASE + 105;
    (*
    * The server could not close %1.
    *  The file is probably corrupted.
    *)

   NELOG_ReplUserCurDir               = ERRLOG_BASE + 106;
    (*
    *The replicator cannot update directory %1. It has tree integrity
    * and is the current directory for some process.
    *)

   NELOG_ReplCannotMasterDir       = ERRLOG_BASE + 107;
    (*
    *The server cannot export directory %1 to client %2.
    * It is exported from another server.
    *)

   NELOG_ReplUpdateError           = ERRLOG_BASE + 108;
    (*
    *The replication server could not update directory %2 from the source
    * on %3 due to error %1.
    *)

   NELOG_ReplLostMaster            = ERRLOG_BASE + 109;
    (*
    *Master %1 did not send an update notice for directory %2 at the expected
    * time.
    *)

   NELOG_NetlogonAuthDCFail        = ERRLOG_BASE + 110;
    (*
    *Failed to authenticate with %2, a Windows NT domain controller for domain %1.
    *)

   NELOG_ReplLogonFailed           = ERRLOG_BASE + 111;
    (*
    *The replicator attempted to log on at %2 as %1 and failed.
    *)

   NELOG_ReplNetErr            = ERRLOG_BASE + 112;
    (*
    *  Network error %1 occurred.
    *)

   NELOG_ReplMaxFiles            = ERRLOG_BASE + 113;
    (*
    *  Replicator limit for files in a directory has been exceeded.
    *)


   NELOG_ReplMaxTreeDepth            = ERRLOG_BASE + 114;
    (*
    *  Replicator limit for tree depth has been exceeded.
    *)

   NELOG_ReplBadMsg             = ERRLOG_BASE + 115;
    (*
    *  Unrecognized message received in mailslot.
    *)

   NELOG_ReplSysErr            = ERRLOG_BASE + 116;
    (*
    *  System error %1 occurred.
    *)

   NELOG_ReplUserLoged          = ERRLOG_BASE + 117;
    (*
    *  Cannot log on. User is currently logged on and argument TRYUSER
    *  is set to NO.
    *)

   NELOG_ReplBadImport           = ERRLOG_BASE + 118;
    (*
    *  IMPORT path %1 cannot be found.
    *)

   NELOG_ReplBadExport           = ERRLOG_BASE + 119;
    (*
    *  EXPORT path %1 cannot be found.
    *)

   NELOG_ReplSignalFileErr           = ERRLOG_BASE + 120;
    (*
    *  Replicator failed to update signal file in directory %2 due to
    *  %1 system error.
    *)

   NELOG_DiskFT                = ERRLOG_BASE+121;
    (*
    * Disk Fault Tolerance Error
    *
    * %1
    *)

   NELOG_ReplAccessDenied           = ERRLOG_BASE + 122;
    (*
    *  Replicator could not access %2
    *  on %3 due to system error %1.
    *)

   NELOG_NetlogonFailedPrimary      = ERRLOG_BASE + 123;
    (*
    *The primary domain controller for domain %1 has apparently failed.
    *)

   NELOG_NetlogonPasswdSetFailed = ERRLOG_BASE + 124;
    (*
    * Changing machine account password for account %1 failed with
    * the following error: %n%2
    *)

   NELOG_NetlogonTrackingError      = ERRLOG_BASE + 125;
    (*
    *An error occurred while updating the logon or logoff information for %1.
    *)

   NELOG_NetlogonSyncError          = ERRLOG_BASE + 126;
    (*
    *An error occurred while synchronizing with primary domain controller %1
    *)

//
//  UPS service specific error log messages from 130 to 135
//

   NELOG_UPS_PowerOut      = ERRLOG_BASE + 130;
    (*
    * A power failure was detected at the server.
    *)

   NELOG_UPS_Shutdown      = ERRLOG_BASE + 131;
    (*
    * The UPS service performed server shut down.
    *)

   NELOG_UPS_CmdFileError      = ERRLOG_BASE + 132;
    (*
    * The UPS service did not complete execution of the
    * user specified shut down command file.
    *)

   NELOG_UPS_CannotOpenDriver  = ERRLOG_BASE+133;
    (*
    * The UPS driver could not be opened.  The error code is
    * the data.
    *)

   NELOG_UPS_PowerBack     = ERRLOG_BASE + 134;
    (*
    * Power has been restored.
    *)

   NELOG_UPS_CmdFileConfig     = ERRLOG_BASE + 135;
    (*
    * There is a problem with a configuration of user specified
    * shut down command file.
    *)

   NELOG_UPS_CmdFileExec       = ERRLOG_BASE + 136;
    (*
    * The UPS service failed to execute a user specified shutdown
    * command file %1.  The error code is the data.
    *)

//
//  Remoteboot server specific error log messages are from 150 to 157
//

   NELOG_Missing_Parameter     = ERRLOG_BASE + 150;
    (*
    * Initialization failed because of an invalid or missing
    *  parameter in the configuration file %1.
    *)

   NELOG_Invalid_Config_Line   = ERRLOG_BASE + 151;
    (*
    * Initialization failed because of an invalid line in the
    *  configuration file %1. The invalid line is the data.
    *)

   NELOG_Invalid_Config_File   = ERRLOG_BASE + 152;
    (*
    * Initialization failed because of an error in the configuration
    *  file %1.
    *)

   NELOG_File_Changed      = ERRLOG_BASE + 153;
    (*
    * The file %1 has been changed after initialization.
    *  The boot-block loading was temporarily terminated.
    *)

   NELOG_Files_Dont_Fit        = ERRLOG_BASE + 154;
    (*
    * The files do not fit to the boot-block configuration
    * file %1. Change the BASE and ORG definitions or the order
    * of the files.
    *)

   NELOG_Wrong_DLL_Version     = ERRLOG_BASE + 155;
    (*
    * Initialization failed because the dynamic-link
    *  library %1 returned an incorrect version number.
    *)

   NELOG_Error_in_DLL      = ERRLOG_BASE + 156;
    (*
    * There was an unrecoverable error in the dynamic-
    *  link library of the service.
    *)

   NELOG_System_Error      = ERRLOG_BASE + 157;
    (*
    * The system returned an unexpected error code.
    *  The error code is the data.
    *)

   NELOG_FT_ErrLog_Too_Large = ERRLOG_BASE + 158;
    (*
    * The fault-tolerance error log file, LANROOT\LOGS\FT.LOG,
    *  is more than 64K.
    *)

   NELOG_FT_Update_In_Progress = ERRLOG_BASE + 159;
    (*
    * The fault-tolerance error-log file, LANROOT\LOGS\FT.LOG, had the
    * update in progress bit set upon opening, which means that the
    * system crashed while working on the error log.
    *)


//
// another error log range defined for NT Lanman.
//

   ERRLOG2_BASE  = 5700;        (* New NT NELOG errors start here *)

   NELOG_NetlogonSSIInitError              = ERRLOG2_BASE + 0;
    (*
     * The Netlogon service could not initialize the replication data
     * structures successfully. The service was terminated.  The following
     * error occurred: %n%1
     *)

   NELOG_NetlogonFailedToUpdateTrustList   = ERRLOG2_BASE + 1;
    (*
     * The Netlogon service failed to update the domain trust list.  The
     * following error occurred: %n%1
     *)

   NELOG_NetlogonFailedToAddRpcInterface   = ERRLOG2_BASE + 2;
    (*
     * The Netlogon service could not add the RPC interface.  The
     * service was terminated. The following error occurred: %n%1
     *)

   NELOG_NetlogonFailedToReadMailslot      = ERRLOG2_BASE + 3;
    (*
     * The Netlogon service could not read a mailslot message from %1 due
     * to the following error: %n%2
     *)

   NELOG_NetlogonFailedToRegisterSC        = ERRLOG2_BASE + 4;
    (*
     * The Netlogon service failed to register the service with the
     * service controller. The service was terminated. The following
     * error occurred: %n%1
     *)

   NELOG_NetlogonChangeLogCorrupt          = ERRLOG2_BASE + 5;
    (*
     * The change log cache maintained by the Netlogon service for
     * database changes is corrupted. The Netlogon service is resetting
     * the change log.
     *)

   NELOG_NetlogonFailedToCreateShare       = ERRLOG2_BASE + 6;
    (*
     * The Netlogon service could not create server share %1.  The following
     * error occurred: %n%2
     *)

   NELOG_NetlogonDownLevelLogonFailed      = ERRLOG2_BASE + 7;
    (*
     * The down-level logon request for the user %1 from %2 failed.
     *)

   NELOG_NetlogonDownLevelLogoffFailed     = ERRLOG2_BASE + 8;
    (*
     * The down-level logoff request for the user %1 from %2 failed.
     *)

   NELOG_NetlogonNTLogonFailed             = ERRLOG2_BASE + 9;
    (*
     * The Windows NT %1 logon request for the user %2\%3 from %4 (via %5;
     * failed.
     *)

   NELOG_NetlogonNTLogoffFailed            = ERRLOG2_BASE + 10;
    (*
     * The Windows NT %1 logoff request for the user %2\%3 from %4
     * failed.
     *)

   NELOG_NetlogonPartialSyncCallSuccess    = ERRLOG2_BASE + 11;
    (*
     * The partial synchronization request from the server %1 completed
     * successfully. %2 changes(s; has(have; been returned to the
     * caller.
     *)

   NELOG_NetlogonPartialSyncCallFailed     = ERRLOG2_BASE + 12;
    (*
     * The partial synchronization request from the server %1 failed with
     * the following error: %n%2
     *)

   NELOG_NetlogonFullSyncCallSuccess       = ERRLOG2_BASE + 13;
    (*
     * The full synchronization request from the server %1 completed
     * successfully. %2 object(s; has(have; been returned to
     * the caller.
     *)

   NELOG_NetlogonFullSyncCallFailed        = ERRLOG2_BASE + 14;
    (*
     * The full synchronization request from the server %1 failed with
     * the following error: %n%2
     *)

   NELOG_NetlogonPartialSyncSuccess        = ERRLOG2_BASE + 15;
    (*
     * The partial synchronization replication of the %1 database from the
     * primary domain controller %2 completed successfully. %3 change(s; is(are;
     * applied to the database.
     *)


   NELOG_NetlogonPartialSyncFailed         = ERRLOG2_BASE + 16;
    (*
     * The partial synchronization replication of the %1 database from the
     * primary domain controller %2 failed with the following error: %n%3
     *)

   NELOG_NetlogonFullSyncSuccess           = ERRLOG2_BASE + 17;
    (*
     * The full synchronization replication of the %1 database from the
     * primary domain controller %2 completed successfully.
     *)


   NELOG_NetlogonFullSyncFailed            = ERRLOG2_BASE + 18;
    (*
     * The full synchronization replication of the %1 database from the
     * primary domain controller %2 failed with the following error: %n%3
     *)

   NELOG_NetlogonAuthNoDomainController    = ERRLOG2_BASE + 19;
    (*
     *  No Windows NT Domain Controller is available for domain %1 for
     *  the following reason: %n%2
     *)

   NELOG_NetlogonAuthNoTrustLsaSecret      = ERRLOG2_BASE + 20;
    (*
     * The session setup to the Windows NT Domain Controller %1 for the domain %2
     * failed because the computer %3 does not have a local security database account.
     *)

   NELOG_NetlogonAuthNoTrustSamAccount     = ERRLOG2_BASE + 21;
    (*
     * The session setup to the Windows NT Domain Controller %1 for the domain %2
     * failed because the Windows NT Domain Controller does not have an account
     * for the computer %3.
     *)

   NELOG_NetlogonServerAuthFailed          = ERRLOG2_BASE + 22;
    (*
     * The session setup from the computer %1 failed to authenticate.
     * The name of the account referenced in the security database is
     * %2.  The following error occurred: %n%3
     *)

   NELOG_NetlogonServerAuthNoTrustSamAccount = ERRLOG2_BASE + 23;
    (*
     * The session setup from the computer %1 failed because there is
     * no trust account in the security database for this computer. The name of
     * the account referenced in the security database is %2.
     *)

//
// General log messages for NT services.
//

   NELOG_FailedToRegisterSC                  = ERRLOG2_BASE + 24;
    (*
     * Could not register control handler with service controller %1.
     *)

   NELOG_FailedToSetServiceStatus            = ERRLOG2_BASE + 25;
    (*
     * Could not set service status with service controller %1.
     *)

   NELOG_FailedToGetComputerName             = ERRLOG2_BASE + 26;
    (*
     * Could not find the computer name %1.
     *)

   NELOG_DriverNotLoaded                     = ERRLOG2_BASE + 27;
    (*
     * Could not load %1 device driver.
     *)

   NELOG_NoTranportLoaded                    = ERRLOG2_BASE + 28;
    (*
     * Could not load any transport.
     *)

//
// More Netlogon service events
//

   NELOG_NetlogonFailedDomainDelta           = ERRLOG2_BASE + 29;
    (*
     * Replication of the %1 Domain Object "%2" from primary domain controller
     * %3 failed with the following error: %n%4
     *)

   NELOG_NetlogonFailedGlobalGroupDelta      = ERRLOG2_BASE + 30;
    (*
     * Replication of the %1 Global Group "%2" from primary domain controller
     * %3 failed with the following error: %n%4
     *)

   NELOG_NetlogonFailedLocalGroupDelta       = ERRLOG2_BASE + 31;
    (*
     * Replication of the %1 Local Group "%2" from primary domain controller
     * %3 failed with the following error: %n%4
     *)

   NELOG_NetlogonFailedUserDelta             = ERRLOG2_BASE + 32;
    (*
     * Replication of the %1 User "%2" from primary domain controller
     * %3 failed with the following error: %n%4
     *)

   NELOG_NetlogonFailedPolicyDelta           = ERRLOG2_BASE + 33;
    (*
     * Replication of the %1 Policy Object "%2" from primary domain controller
     * %3 failed with the following error: %n%4
     *)

   NELOG_NetlogonFailedTrustedDomainDelta    = ERRLOG2_BASE + 34;
    (*
     * Replication of the %1 Trusted Domain Object "%2" from primary domain controller
     * %3 failed with the following error: %n%4
     *)

   NELOG_NetlogonFailedAccountDelta          = ERRLOG2_BASE + 35;
    (*
     * Replication of the %1 Account Object "%2" from primary domain controller
     * %3 failed with the following error: %n%4
     *)

   NELOG_NetlogonFailedSecretDelta           = ERRLOG2_BASE + 36;
    (*
     * Replication of the %1 Secret "%2" from primary domain controller
     * %3 failed with the following error: %n%4
     *)

   NELOG_NetlogonSystemError                 = ERRLOG2_BASE + 37;
    (*
    * The system returned the following unexpected error code: %n%1
    *)

   NELOG_NetlogonDuplicateMachineAccounts    = ERRLOG2_BASE + 38;
    (*
    * Netlogon has detected two machine accounts for server "%1".
    * The server can be either a Windows NT Server that is a member of the
    * domain or the server can be a LAN Manager server with an account in the
    * SERVERS global group.  It cannot be both.
    *)

   NELOG_NetlogonTooManyGlobalGroups         = ERRLOG2_BASE + 39;
    (*
    * This domain has more global groups than can be replicated to a LanMan
    * BDC.  Either delete some of your global groups or remove the LanMan
    * BDCs from the domain.
    *)

   NELOG_NetlogonBrowserDriver               = ERRLOG2_BASE + 40;
    (*
    * The Browser driver returned the following error to Netlogon: %n%1
    *)

   NELOG_NetlogonAddNameFailure              = ERRLOG2_BASE + 41;
    (*
    * Netlogon could not register the %1<1B> name for the following reason: %n%2
    *)

//
//  More Remoteboot service events.
//
   NELOG_RplMessages                         = ERRLOG2_BASE + 42;
    (*
    * Service failed to retrieve messages needed to boot remote boot clients.
    *)

   NELOG_RplXnsBoot                          = ERRLOG2_BASE + 43;
    (*
    * Service experienced a severe error and can no longer provide remote boot
    * for 3Com 3Start remote boot clients.
    *)

   NELOG_RplSystem                           = ERRLOG2_BASE + 44;
    (*
    * Service experienced a severe system error and will shut itself down.
    *)

   NELOG_RplWkstaTimeout                     = ERRLOG2_BASE + 45;
    (*
    * Client with computer name %1 failed to acknowledge receipt of the
    * boot data.  Remote boot of this client was not completed.
    *)

   NELOG_RplWkstaFileOpen                    = ERRLOG2_BASE + 46;
    (*
    * Client with computer name %1 was not booted due to an error in opening
    * file %2.
    *)

   NELOG_RplWkstaFileRead                    = ERRLOG2_BASE + 47;
    (*
    * Client with computer name %1 was not booted due to an error in reading
    * file %2.
    *)

   NELOG_RplWkstaMemory                      = ERRLOG2_BASE + 48;
    (*
    * Client with computer name %1 was not booted due to insufficent memory
    * at the remote boot server.
    *)

   NELOG_RplWkstaFileChecksum                = ERRLOG2_BASE + 49;
    (*
    * Client with computer name %1 will be booted without using checksums
    * because checksum for file %2 could not be calculated.
    *)

   NELOG_RplWkstaFileLineCount               = ERRLOG2_BASE + 50;
    (*
    * Client with computer name %1 was not booted due to too many lines in
    * file %2.
    *)

   NELOG_RplWkstaBbcFile                     = ERRLOG2_BASE + 51;
    (*
    * Client with computer name %1 was not booted because the boot block
    * configuration file %2 for this client does not contain boot block
    * line and/or loader line.
    *)

   NELOG_RplWkstaFileSize                    = ERRLOG2_BASE + 52;
    (*
    * Client with computer name %1 was not booted due to a bad size of
    * file %2.
    *)

   NELOG_RplWkstaInternal                    = ERRLOG2_BASE + 53;
    (*
    * Client with computer name %1 was not booted due to remote boot
    * service internal error.
    *)

   NELOG_RplWkstaWrongVersion                = ERRLOG2_BASE + 54;
    (*
    * Client with computer name %1 was not booted because file %2 has an
    * invalid boot header.
    *)

   NELOG_RplWkstaNetwork                     = ERRLOG2_BASE + 55;
    (*
    * Client with computer name %1 was not booted due to network error.
    *)

   NELOG_RplAdapterResource                  = ERRLOG2_BASE + 56;
    (*
    * Client with adapter id %1 was not booted due to lack of resources.
    *)

   NELOG_RplFileCopy                         = ERRLOG2_BASE + 57;
    (*
    * Service experienced error copying file or directory %1.
    *)

   NELOG_RplFileDelete                       = ERRLOG2_BASE + 58;
    (*
    * Service experienced error deleting file or directory %1.
    *)

   NELOG_RplFilePerms                        = ERRLOG2_BASE + 59;
    (*
    * Service experienced error setting permissions on file or directory %1.
    *)
   NELOG_RplCheckConfigs                     = ERRLOG2_BASE + 60;
    (*
    * Service experienced error evaluating RPL configurations.
    *)
   NELOG_RplCreateProfiles                   = ERRLOG2_BASE + 61;
    (*
    * Service experienced error creating RPL profiles for all configurations.
    *)
   NELOG_RplRegistry                         = ERRLOG2_BASE + 62;
    (*
    * Service experienced error accessing registry.
    *)
   NELOG_RplReplaceRPLDISK                   = ERRLOG2_BASE + 63;
    (*
    * Service experienced error replacing possibly outdated RPLDISK.SYS.
    *)
   NELOG_RplCheckSecurity                    = ERRLOG2_BASE + 64;
    (*
    * Service experienced error adding security accounts or setting
    * file permissions.  These accounts are the RPLUSER local group
    * and the user accounts for the individual RPL workstations.
    *)
   NELOG_RplBackupDatabase                   = ERRLOG2_BASE + 65;
    (*
    * Service failed to back up its database.
    *)
   NELOG_RplInitDatabase                     = ERRLOG2_BASE + 66;
    (*
    * Service failed to initialize from its database.  The database may be
    * missing or corrupted.  Service will attempt restoring the database
    * from the backup.
    *)
   NELOG_RplRestoreDatabaseFailure           = ERRLOG2_BASE + 67;
    (*
    * Service failed to restore its database from the backup.  Service
    * will not start.
    *)
   NELOG_RplRestoreDatabaseSuccess           = ERRLOG2_BASE + 68;
    (*
    * Service sucessfully restored its database from the backup.
    *)
   NELOG_RplInitRestoredDatabase             = ERRLOG2_BASE + 69;
    (*
    * Service failed to initialize from its restored database.  Service
    * will not start.
    *)

//
// More Netlogon and RPL service events
//
   NELOG_NetlogonSessionTypeWrong            = ERRLOG2_BASE + 70;
    (*
     * The session setup to the Windows NT Domain Controller %1 from computer
     * %2 using account %4 failed.  %2 is declared to be a BDC in domain %3.
     * However, %2 tried to connect as either a DC in a trusted domain,
     * a member workstation in domain %3, or as a server in domain %3.
     * Use the Server Manager to remove the BDC account for %2.
     *)
   NELOG_RplUpgradeDBTo40                    = ERRLOG2_BASE + 71;
    (*
    * The remoteboot database was in NT 3.5 / NT 3.51 format and NT is
    * attempting to convert it to NT 4.0 format. The JETCONV converter
    * will write to the Application event log when it is finished.
    *)

type
  ERROR_LOG = record
    el_len : Integer;
    el_reserved : Integer;
    el_time : Integer;
    el_error : Integer;
    el_name : PWideChar;           // pointer to service name
    el_text : PWideChar;           // pointer to string array
    el_data : Pointer;             // pointer to BYTE array
    el_data_size : Integer;        // byte count of el_data area
    el_nstrings : Integer;         // number of strings in el_text.
  end;
  PERROR_LOG = ^ERROR_LOG;


  HLOG = record
    time : Integer;
    last_flags : Integer;
    offset : Integer;
    rec_offset : Integer;
  end;
  PHLOG = ^HLOG;

function NetErrorLogClear (
  server : PWideChar;
  backupfile : PWideChar;
  reserved : pointer) : NetAPIStatus; stdcall;

function NetErrorLogRead (
  server, reserved1 : PWideChar;
  errloghandle : PHLOG;
  offset : Integer;
  var reserved2 : Integer;
  reserved3 : Integer;
  offsetflag : Integer;
  var buffer : Pointer;
  prefMaxLen : Integer;
  var bytesRead, totalBytes : Integer) : NetAPIStatus; stdcall;

function NetErrorLogWrite (
  reserved : Pointer;
  code : Integer;
  component : PWideChar;
  buffer : Pointer;
  numbytes : Integer;
  msgbuf : Pointer;
  strcount : Integer;
  reserved2 : Pointer) : NetAPIStatus; stdcall;

implementation

function NetErrorLogClear; external 'NETAPI32.DLL';
function NetErrorLogRead;  external 'NETAPI32.DLL';
function NetErrorLogWrite; external 'NETAPI32.DLL';

end.
