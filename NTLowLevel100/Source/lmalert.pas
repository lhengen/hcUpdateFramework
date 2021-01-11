unit lmalert;

interface

uses lmglobal;

const
  ALERTER_MAILSLOT     = '\\.\MAILSLOT\Alerter';
  ALERT_PRINT_EVENT    = 'PRINTING';
  ALERT_MESSAGE_EVENT  = 'MESSAGE';
  ALERT_ERRORLOG_EVENT = 'ERRORLOG';
  ALERT_ADMIN_EVENT    = 'ADMIN';
  ALERT_USER_EVENT     = 'USER';

//
//      Bitmap masks for prjob_status field of PRINTJOB.
//

// 2-7 bits also used in device status

  PRJOB_QSTATUS       = $3;         // Bits 0,1
  PRJOB_DEVSTATUS     = $1fc;       // 2-8 bits
  PRJOB_COMPLETE      = $4;         // Bit 2
  PRJOB_INTERV        = $8;         // Bit 3
  PRJOB_ERROR         = $10;        // Bit 4
  PRJOB_DESTOFFLINE   = $20;        // Bit 5
  PRJOB_DESTPAUSED    = $40;        // Bit 6
  PRJOB_NOTIFY        = $80;        // BIT 7
  PRJOB_DESTNOPAPER   = $100;       // BIT 8
  PRJOB_DELETED       = $8000;      // BIT 15

//
//      Values of PRJOB_QSTATUS bits in prjob_status field of PRINTJOB.
//

  PRJOB_QS_QUEUED     = 0;
  PRJOB_QS_PAUSED     = 1;
  PRJOB_QS_SPOOLING   = 2;
  PRJOB_QS_PRINTING   = 3;

type
  STD_ALERT = record
    alrt_timestamp : Integer;
    alrt_eventname : array [0..EVLEN] of WideChar;
    alrt_servicename : array [0..SNLEN] of WideChar;
  end;
  PSTD_ALERT = ^STD_ALERT;

  ADMIN_OTHER_INFO = record
    alrtad_errcode : Integer;
    alrtad_numstrings : Integer;
  end;
  PADMIN_OTHER_INFO = ^ADMIN_OTHER_INFO;

  ERRLOG_OTHER_INFO = record
    alrter_errcode : Integer;
    alrter_offset : Integer;
  end;
  PERRLOG_OTHER_INFO = ^ERRLOG_OTHER_INFO;

  PRINT_OTHER_INFO = record
    alrtpr_jobid : Integer;
    alrtpr_status : Integer;
    alrtpr_submitted : Integer;
    alrtpr_size : Integer;
  end;
  PPRINT_OTHER_INFO = ^PRINT_OTHER_INFO;

  USER_OTHER_INFO = record
    alrtus_errcode : Integer;
    alrtus_numstrings : Integer;
  end;
  PUSER_OTHER_INFO = ^USER_OTHER_INFO;

function NetAlertRaise(AlertEventName : PWideChar; buffer : PChar; BufferSize : Integer) : NetAPIStatus; stdcall;
function NetAlertRaiseEx(AlertEventName : PWideChar; VariableInfo : Pointer; VariableInfoSize : Integer; ServiceName : PWideChar) : NetAPIStatus; stdcall;

function ALERT_OTHER_INFO (x : pointer) : pointer;
function ALERT_VAR_DATA (p : pointer; size : Integer) : pointer;


implementation

function ALERT_OTHER_INFO (x : pointer) : pointer;
begin
  result := PChar (x) + sizeof (STD_ALERT)
end;

function ALERT_VAR_DATA (p : pointer; size : Integer) : pointer;
begin
  result := PChar (p) + size
end;

function NetAlertRaise;      external 'NETAPI32.DLL';
function NetAlertRaiseEx;    external 'NETAPI32.DLL';

end.
