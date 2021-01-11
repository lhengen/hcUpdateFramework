unit lmbrowsr;

interface

uses Windows, lmglobal;

const
  BROWSER_ROLE_PDC = $1;
  BROWSER_ROLE_BDC = $2;

type

  BROWSER_STATISTICS = record
    StatisticsStartTime : TLargeInteger;
    NumberOfServerAnnouncements : TLargeInteger;
    NumberOfDomainAnnouncements : TLargeInteger;
    NumberOfElectionPackets : Integer;
    NumberOfMailslotWrites : Integer;
    NumberOfGetBrowserServerListRequests : Integer;
    NumberOfServerEnumerations : Integer;
    NumberOfDomainEnumerations : Integer;
    NumberOfOtherEnumerations : Integer;
    NumberOfMissedServerAnnouncements : Integer;
    NumberOfMissedMailslotDatagrams : Integer;
    NumberOfMissedGetBrowserServerListRequests : Integer;
    NumberOfFailedServerAnnounceAllocations : Integer;
    NumberOfFailedMailslotAllocations : Integer;
    NumberOfFailedMailslotReceives : Integer;
    NumberOfFailedMailslotWrites : Integer;
    NumberOfFailedMailslotOpens : Integer;
    NumberOfDuplicateMasterAnnouncements : Integer;
    NumberOfIllegalDatagrams : TLargeInteger;
  end;
  PBROWSER_STATISTICS = ^BROWSER_STATISTICS;

  BROWSER_STATISTICS_100 = record
    StartTime : TLargeInteger;
    NumberOfServerAnnouncements : TLargeInteger;
    NumberOfDomainAnnouncements : TLargeInteger;
    NumberOfElectionPackets : Integer;
    NumberOfMailslotWrites : Integer;
    NumberOfGetBrowserServerListRequests : Integer;
    NumberOfIllegalDatagrams : TLargeInteger;
  end;
  PBROWSER_STATISTICS_100 = ^BROWSER_STATISTICS_100;

  BROWSER_STATISTICS_101 = record
    StartTime : TLargeInteger;
    NumberOfServerAnnouncements : TlargeInteger;
    NumberOfDomainAnnouncements : TLargeInteger;
    NumberOfElectionPackets : Integer;
    NumberOfMailslotWrites : Integer;
    NumberOfGetBrowserServerListRequests : Integer;
    NumberOfIllegalDatagrams : TLargeInteger;

    NumberOfMissedServerAnnouncements : Integer;
    NumberOfMissedMailslotDatagrams : Integer;
    NumberOfMissedGetBrowserServerListRequests : Integer;
    NumberOfFailedServerAnnounceAllocations : Integer;
    NumberOfFailedMailslotAllocations : Integer;
    NumberOfFailedMailslotReceives : Integer;
    NumberOfFailedMailslotWrites : Integer;
    NumberOfFailedMailslotOpens : Integer;
    NumberOfDuplicateMasterAnnouncements : Integer;
  end;
  PBROWSER_STATISTICS_101 = ^BROWSER_STATISTICS_101;


  BROWSER_EMULATED_DOMAIN = record
    DomainName : PWideChar;
    EmulatedServerName : PWideChar;
    Role : Integer;
  end;
  PBROWSER_EMULATED_DOMAIN = ^BROWSER_EMULATED_DOMAIN;

//
// Function Prototypes - BROWSER
//

function I_BrowserServerEnum (
  serverName, transport, clientName : PWideChar;
  level : Integer;
  var buffer : pointer;
  prefMaxLen : Integer;
  var entriesRead, totalEntries : Integer;
  serverType : Integer;
  domain : PWideChar;
  var resumeHandle : Integer) : NetAPIStatus; stdcall;

function I_BrowserServerEnumEx (
  serverName, transport, clientName : PWideChar;
  level : Integer;
  var buffer : pointer;
  prefMaxLen : Integer;
  var entriesRead, totalEntries : Integer;
  serverType : Integer;
  domain : PWideChar;
  FirstNameToReturn : PWideChar
) : NetAPIStatus; stdcall;

function I_BrowserQueryOtherDomains (
  serverName : PWideChar;
  var buffer : pointer;
  var entriesRead, tgotalEntries : Integer
) : NetAPIStatus; cdecl;

function I_BrowserResetNetlogonState (
  serverName : PWideChar
) : NetAPIStatus; cdecl;

function I_BrowserSetNetlogonState (
  serverName, DomainName, EmulatedServerName : PWideChar;
  role : Integer
) : NetAPIStatus; cdecl;

function I_BrowserQueryEmulatedDomains (
  serverName : PWideChar;
  var EmulatedDomains : PBROWSER_EMULATED_DOMAIN;
  var EbtriesRead : Integer) : NetAPIStatus; cdecl;

function I_BrowserQueryStatistics (
  serverName : PWideChar;
  var statistics : PBROWSER_STATISTICS
) : NetAPIStatus; cdecl;

function I_BrowserResetStatistics (
  serverName : PWideChar
) : NetAPIStatus; cdecl;

function I_BrowserServerEnumForXactsrv (
  TransportName, clientName : PWideChar;
  NtLevel : Integer;
  ClientLevel : word;
  Buffer : pointer;
  BufferLength : Integer;
  PreferedMaximumLength : Integer;

  var EntriesRead, TotalEntries : Integer;

  ServerType : Integer;
  Domain : PWideChar;
  FirstNameToReturn : PWideChar;
  var Converter : word
) : word; cdecl;

function I_BrowserDebugTrace(
  server : PWideChar;
  buffer : pointer
) : NetAPIStatus; cdecl;

implementation

function I_BrowserServerEnum;             external 'NETAPI32.DLL';
function I_BrowserServerEnumEx;           external 'NETAPI32.DLL';
function I_BrowserQueryOtherDomains;      external 'NETAPI32.DLL';
function I_BrowserResetNetlogonState;     external 'NETAPI32.DLL';
function I_BrowserSetNetlogonState;       external 'NETAPI32.DLL';
function I_BrowserQueryEmulatedDomains;   external 'NETAPI32.DLL';
function I_BrowserQueryStatistics;        external 'NETAPI32.DLL';
function I_BrowserResetStatistics;        external 'NETAPI32.DLL';
function I_BrowserServerEnumForXactsrv;   external 'NETAPI32.DLL';
function I_BrowserDebugTrace;             external 'NETAPI32.DLL';


end.
