unit lmat;

interface

uses lmglobal;

const
  JOB_RUN_PERIODICALLY = $01;    //  set if EVERY

//
//  Was there an error last time we tried to exec a program on behalf of
//  this job.
//  This flag is meaningfull on output only!
//
  JOB_EXEC_ERROR          =       $02;    //  set if error

//
//  Will this job run today or tomorrow.
//  This flag is meaningfull on output only!
//
  JOB_RUNS_TODAY          =       $04;    //  set if today

//
//  Add current day of the month to DaysOfMonth input.
//  This flag is meaningfull on input only!
//
  JOB_ADD_CURRENT_DATE   =        $08;    // set if to add current date


//
//  Will this job be run interactively or not.  Windows NT 3.1 do not
//  know about this bit, i.e. they submit interactive jobs only.
//
  JOB_NONINTERACTIVE    =         $10;    // set for noninteractive


  JOB_INPUT_FLAGS       = JOB_RUN_PERIODICALLY or JOB_ADD_CURRENT_DATE or JOB_NONINTERACTIVE;
  JOB_OUTPUT_FLAGS      = JOB_RUN_PERIODICALLY or JOB_EXEC_ERROR or JOB_RUNS_TODAY or JOB_NONINTERACTIVE;

type
  AT_INFO = record
    JobTime : Integer;
    DaysOfMonth : Integer;
    DaysOfWeek : byte;
    flags : byte;
    Command : PWideChar;
  end;
  PAT_INFO = ^AT_INFO;

  AT_ENUM = record
    JobID : Integer;
    JobTime : Integer;
    DaysOfMonth : Integer;
    DaysOfWeek : byte;
    Flags : byte;
    Command : PWideChar;
  end;

function NetScheduleJobAdd (ServerName : PWideChar; Buffer : pointer; var JobID : Integer) : NetAPIStatus; stdcall;
function NetScheduleJobDel (ServerName : PWideChar; MinJobID, MaxJobID : Integer) : NetAPIStatus; stdcall;
function NetScheduleJobEnum (ServerName : PWideChar; var buffer : pointer; PrefMaximumLength : Integer; var EntriesRead, TotalEntries, resumeHandle : Integer) : NetAPIStatus; stdcall;
function NetScheduleJobGetInfo(ServerName : PWideChar; JobId : Integer; var buffer : pointer) : NetAPIStatus; stdcall;

implementation

function NetScheduleJobAdd;      external 'NETAPI32.DLL';
function NetScheduleJobDel;      external 'NETAPI32.DLL';
function NetScheduleJobEnum;     external 'NETAPI32.DLL';
function NetScheduleJobGetInfo;  external 'NETAPI32.DLL';

end.
