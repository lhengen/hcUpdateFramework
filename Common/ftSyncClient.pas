unit ftSyncClient;

interface

uses
  unNamedPipe
  ,Classes
  ,ftTypes
  ,ExtCtrls
  ,hcQueryIntf
  ,CodeSiteLogging
  ,ftCodeSiteHelper
  ,Contnrs
  ,ADODB
  ;

type
  TftStatusUpdateMethod = procedure of object;
  TftSyncMonitorStatus = (smsStarted = 1, smsSucceeded = 2, smsInProgress = 3, smsIdle = 4, smsRetrying = 5, smsFailed = 6);
  TftSyncStatus = (ssIdle,ssDataSyncing,ssProgrammabilitySyncing,ssError,ssTimeOut,ssGetStatus,ssNone);

const
  SyncStatusNames :array[TftSyncstatus] of string = ('Idle','Data Syncing','Programmability Syncing','Error','TimeOut','Get Status','None');
  SyncMonitorStatusNames :array[TftSyncMonitorStatus] of string = ('Sync Started','Sync Finished','Syncing','Idle','Retrying','Failed');

type
  TftSyncClient = class(TComponent)
  private
    FDataSyncTimeOut :Cardinal;
    FThread :TThread;  //used to indicate if SyncClient needs to use Synchronize() when triggering status events
    FPercentComplete :TftPercentRange;
    FOnPercentageUpdate :TNotifyEvent;
    FOnRequestSent :TNotifyEvent;
    FOnStatusUpdate :TNotifyEvent;
    FOnSyncFinished :TNotifyEvent;
    FOnSyncStarted :TNotifyEvent;
    FOnSyncFailed :TNotifyEvent;
    FPendingStatus :TftSyncStatus;  //request sent that is pending an OK from the service to acknowledge it  ssIdle used to determine when next command can be sent
    FStatus :TftSyncStatus;


    procedure RequestDataSyncStatusUpdate;
    function RequestDataSync :Boolean;
    function RequestProgrammabilitySync :Boolean;
    procedure PipeError(Sender: TObject; Pipe: THandle; PipeContext: TPipeContext; ErrorCode: Integer);
    function WaitforFinish(const StatusUpdateMethod :TftStatusUpdateMethod; TimeOutInSeconds :Cardinal): Boolean;
    procedure RequestProgSyncStatusUpdate;
    function ParsePercentage(const Value: AnsiString): TftPercentRange;
    procedure ShowPercentage;
    procedure SetPercentageComplete(Value: TftPercentRange);
    function GetPipeDisconnect :TOnPipeDisconnect;
    function GetPipeError: TOnPipeError;
    function GetPipeMessage: TOnPipeMessage;
    function GetPipeSent: TOnPipeSent;
  protected
    FLastSyncAttempt :TDateTime;  //when last sync request was made
    FSyncRequired :Boolean;
    FSyncMonitorStatus :TftSyncMonitorStatus;
    FFactoryPool :TObject;
    FPipeClient :TPipeClient;
    FCodeSite :TCodeSiteLogger;
    FLastStatusMessage :AnsiString;  //last message returned from the FabwareService
    procedure DoSyncStarted;
    procedure DoSyncFinished;
    procedure DoSyncFailed;
    procedure PerformDataSync;
    function SendMessage(aMessage :AnsiString) :boolean; virtual;
    procedure PipeMessage(Sender: TObject; Pipe: THandle; Stream: TStream); virtual;
    procedure SetStatus(Value :TftSyncStatus);
  public
    constructor Create(aOwner :TComponent); override;

    procedure DisableTimer;
    function SyncData(TimeOutInSeconds :Cardinal) :Boolean;
    function SyncProgrammability(TimeOutInSeconds :Cardinal) :Boolean;

    //settings
    property DataSyncTimeOut :cardinal read FDataSyncTimeOut write FDataSyncTimeOut;

    //status info
    property Status :TftSyncStatus read FStatus;
    property SyncMonitorStatus :TftSyncMonitorStatus read FSyncMonitorStatus;
    property LastStatusMessage :AnsiString read FLastStatusMessage;
    property Percentage :TftPercentRange read FPercentComplete;
    property Thread :TThread read FThread write FThread;

    //events
    property OnStatusUpdate :TNotifyEvent read FOnStatusUpdate write FOnStatusUpdate;
    property OnRequestSent :TNotifyEvent read FOnRequestSent write FOnRequestSent;
    property OnPercentageUpdate :TNotifyEvent read FOnPercentageUpdate write FOnPercentageUpdate;
    property OnSyncFinished :TNotifyEvent read FOnSyncFinished write FOnSyncFinished;
    property OnSyncStarted :TNotifyEvent read FOnSyncStarted write FOnSyncStarted;
    property OnSyncFailed :TNotifyEvent read FOnSyncFailed write FOnSyncFailed;

    property OnPipeDisconnect: TOnPipeDisconnect read GetPipeDisconnect;
    property OnPipeMessage: TOnPipeMessage read GetPipeMessage;
    property OnPipeSent: TOnPipeSent read GetPipeSent;
    property OnPipeError: TOnPipeError read GetPipeError;
  end;


implementation

uses
  SysUtils
  ,StrUtils
  ,Forms
  ;

constructor TftSyncClient.Create(aOwner: TComponent);
begin
  inherited;
  FCodeSite := TCodeSiteLogger.Create(Self);
  FCodeSite.Category := 'SyncClient';
  FPipeClient := TPipeClient.Create(Self);
  FPipeClient.OnPipeMessage := PipeMessage;
  FPipeClient.OnPipeError := PipeError;
  FPipeClient.ServerName := '.';
  FPipeClient.PipeName := 'FabwareServicePipe';
  FPipeClient.Name := 'pcFabware';
  FDataSyncTimeOut := 60000;
  FSyncMonitorStatus := smsIdle;
end;

procedure TftSyncClient.PipeError(Sender: TObject; Pipe: THandle;
  PipeContext: TPipeContext; ErrorCode: Integer);
const
  INT_PipeDisconnected = 233;
begin
  //if the error code is anything other than a 233 Pipe Disconnect then update the status
  if ErrorCode <> INT_PipeDisconnected then
  begin
    FLastStatusMessage := AnsiString(Format('Error :%d was returned.',[ErrorCode]));
    SetStatus(ssError);
  end;
end;

function TftSyncClient.SendMessage(aMessage: AnsiString) :boolean;
{
  Routine to send a message to the server application.  Result
  indicates whether the message was successfully sent.
}
var
  GotReply :boolean;
begin
  if (FPipeClient.Connected) or (FPipeClient.Connect()) then
  begin
    FPipeClient.Write(aMessage[1],Length(aMessage));
    FPipeClient.FlushPipeBuffers;
    GotReply := FPipeClient.WaitForReply(30 * MSecsPerSec);  //WaitForReply on XPSP3 is returning False quite often so always return True
    FPipeClient.Disconnect;
    Result := True;
    FCodeSite.SendFmtMsg('Sending: %s',[aMessage]);
    FCodeSite.SendFmtMsg('WaitForReply returned: %s',[ifthen(GotReply,'True','False')]);
  end
  else  //must not be able to connect
  begin
    FLastStatusMessage := 'Could not connect to FabwareService';
    SetStatus(ssError);
    Result := False;
  end;
end;

procedure TftSyncClient.SetStatus(Value: TftSyncStatus);
begin
  FStatus := Value;
  if Assigned(FOnStatusUpdate) then
    FOnStatusUpdate(Self);
end;

procedure TftSyncClient.PerformDataSync;
begin
  SyncData(FDataSyncTimeOut);
end;

procedure TftSyncClient.DisableTimer;
const STR_DisableTimer :AnsiString = 'pause timer'#13#10;
begin
  FCodeSite.EnterMethod( Self, 'DisableTimer' );
  SendMessage(STR_DisableTimer);
  FCodeSite.ExitMethod( Self, 'DisableTimer' );
end;

function TftSyncClient.SyncData(TimeOutInSeconds: Cardinal) :Boolean;
begin
  if (FThread <> nil) then
    TThread.Synchronize(FThread,DoSyncStarted)
  else
    DoSyncStarted;

  FDataSyncTimeOut := TimeOutInSeconds;
  Result := RequestDataSync;
  if Result then
    FSyncRequired := False;
end;

procedure TftSyncClient.DoSyncStarted;
begin
  if assigned(FOnSyncStarted) then
    FOnSyncStarted(Self);
end;


function TftSyncClient.GetPipeDisconnect: TOnPipeDisconnect;
begin
  Result := FPipeClient.OnPipeDisconnect;
end;

function TftSyncClient.GetPipeError: TOnPipeError;
begin
  Result := FPipeClient.OnPipeError;
end;

function TftSyncClient.GetPipeMessage: TOnPipeMessage;
begin
  Result := FPipeClient.OnPipeMessage;
end;

function TftSyncClient.GetPipeSent: TOnPipeSent;
begin
  Result := FPipeClient.OnPipeSent;
end;

procedure TftSyncClient.DoSyncFailed;
begin
  if assigned(FOnSyncFailed) then
    FOnSyncFailed(Self);
end;

procedure TftSyncClient.DoSyncFinished;
begin
  if assigned(FOnSyncFinished) then
    FOnSyncFinished(Self);
end;

function TftSyncClient.SyncProgrammability(TimeOutInSeconds: Cardinal) :Boolean;
begin
  Result := (RequestProgrammabilitySync) and WaitForFinish(RequestProgSyncStatusUpdate,TimeOutInSeconds);
end;

function TftSyncClient.WaitforFinish(const StatusUpdateMethod :TftStatusUpdateMethod; TimeOutInSeconds :Cardinal) :Boolean;
{
  Routine to parse the status buffer returned by the service to determine if the
  current operation is completed successfully or with an error.
}
var
  Done :Boolean;
begin
  FCodeSite.EnterMethod( Self, 'WaitforFinish' );
  Result := False;
  Done := False;
  while not Done do
  begin
    FCodeSite.SendFmtMsg('PendingStatus: %s',[SyncStatusNames[FPendingStatus]]);
    FCodeSite.SendFmtMsg('CurrentStatus: %s',[SyncStatusNames[FStatus]]);
    if FPendingStatus = ssNone then
      StatusUpdateMethod;
    Application.ProcessMessages;
    Done := (FStatus = ssIdle) or (FStatus = ssError);
    FCodeSite.SendFmtMsg( 'Done is %s',[IfThen(Done,'True','False')] );
    if not(Done) and (TimeOutInSeconds = 0) then
    begin
      Done := True;
      SetStatus(ssTimeOut);
    end
    else
    if not Done then
    begin
      Sleep(1000);  //sleep for 1 second
      Dec(TimeOutInSeconds,1);
      //if we haven't got a response within a 5 second window, perform another status request.
      if (TimeOutInSeconds mod 5 = 0) and (FStatus = ssDataSyncing) then
        RequestDataSyncStatusUpdate;
    end
    else
      Result := True;
  end;
  FCodeSite.SendFmtMsg( 'Result is %s',[IfThen(Result,'True','False')] );
  FCodeSite.ExitMethod( Self, 'WaitforFinish' );
end;

function TftSyncClient.ParsePercentage(const Value :AnsiString) :TftPercentRange;
var
  J,
  I: Integer;
begin
  //count the number of numeric digits
  J := 0;
  for I := 1 to 3 do
  begin
    if CharInSet(Value[I],['0'..'9']) then
      Inc(J);
  end;

  if J = 0 then
    Result := 0
  else
    Result := TftPercentRange(StrToInt(Copy(Value,1,J)));
end;

procedure TftSyncClient.PipeMessage(Sender: TObject; Pipe: THandle; Stream: TStream);
{
  After each command the SyncServer returns an OK.  We key on this to perform our
  state transitions.  ssNone is used as a pseudo state to allow our WaitForFinish
  routine to know when to request additional Status Updates from the server.

  The status update messages from the server contain a percentage value at the
  start of each line, but I don't use this as it does not appear to be accurate.
}
const
  STR_Idle :AnsiString = 'Not Currently Running';
  STR_OK :AnsiString = 'OK'#13#10;
var
  aStringStream :TStringStream;
begin
  FCodeSite.EnterMethod( Self, 'PipeMessage' );
  aStringStream := TStringStream.Create;
  try
    aStringStream.CopyFrom(Stream,Stream.Size);
    FLastStatusMessage := AnsiString(aStringStream.DataString);
    FCodeSite.SendFmtMsg('Received : %s',[FLastStatusMessage] );
//    Logger.FactoryPool := FFactoryPool;
//    Logger.LogEvent(ecSynchronization,s0,v2,'',Format('Received : %s',[FLastStatusMessage]));

    if (STR_OK = FLastStatusMessage) then
    begin
      case FPendingStatus of
        ssIdle: ;
        ssGetStatus:
          FLastStatusMessage := 'Status Requested';
        ssDataSyncing:
          FLastStatusMessage := 'Data Sync Has Started';
        ssProgrammabilitySyncing:
          FLastStatusMessage := 'Programmability Sync has Started';
        ssError: ;
        ssTimeOut: ;
      end;
      SetStatus(FPendingStatus);
      FPendingStatus := ssNone;  //allow next request
    end
    else
    if (copy(FLastStatusMessage,1,4) = '100%') then
    begin
      SetStatus(FStatus);
      FPendingStatus := ssNone;  //allow next request
      ShowPercentage;
    end
    else
    if (Pos(STR_Idle,FLastStatusMessage) <> 0)  then
      SetStatus(ssIdle)
    else //just make sure the event is triggered with the current status
    begin
      SetStatus(FStatus);
      FPendingStatus := ssNone;  //allow next request
      ShowPercentage;
    end;
  finally
    aStringStream.Free;
  end;
  FCodeSite.SendFmtMsg('PendingStatus: %s',[SyncStatusNames[FPendingStatus]]);
  FCodeSite.SendFmtMsg('CurrentStatus: %s',[SyncStatusNames[FStatus]]);
  FCodeSite.ExitMethod( Self, 'PipeMessage' );
end;

procedure TftSyncClient.ShowPercentage;
var
  CurrentPercentComplete :TftPercentRange;
begin
  //get the percentage complete
  CurrentPercentComplete := ParsePercentage(FLastStatusMessage);
  FCodeSite.SendFmtMsg('Percentage Complete: %d',[CurrentPercentComplete]);
  if (CurrentPercentComplete > FPercentComplete) then
    SetPercentageComplete(CurrentPercentComplete);
end;

procedure TftSyncClient.SetPercentageComplete(Value :TftPercentRange);
begin
  FPercentComplete := Value;
  if Assigned(FOnPercentageUpdate) then
    FOnPercentageUpdate(Self);
end;

function TftSyncClient.RequestDataSync :Boolean;
const
  STR_SyncDataCommand :AnsiString = 'synchronize'#13#10;
begin
  FCodeSite.EnterMethod( Self, 'RequestDataSync' );
  FPendingStatus := ssDataSyncing;
  SetPercentageComplete(0);
  Result := SendMessage(STR_SyncDataCommand);
  FCodeSite.SendFmtMsg('PendingStatus: %s',[SyncStatusNames[FPendingStatus]]);
  FCodeSite.SendFmtMsg('CurrentStatus: %s',[SyncStatusNames[FStatus]]);
  FCodeSite.ExitMethod( Self, 'RequestDataSync' );
  FLastSyncAttempt := Now;
end;

function TftSyncClient.RequestProgrammabilitySync :Boolean;
const
  STR_SyncProgrammabilityCommand :AnsiString = 'synchronize programmability'#13#10;
begin
  FCodeSite.EnterMethod( Self, 'RequestProgrammabilitySync' );
  FPendingStatus := ssProgrammabilitySyncing;
  SetPercentageComplete(0);
  Result := SendMessage(STR_SyncProgrammabilityCommand);
  FCodeSite.SendFmtMsg('PendingStatus: %s',[SyncStatusNames[FPendingStatus]]);
  FCodeSite.SendFmtMsg('CurrentStatus: %s',[SyncStatusNames[FStatus]]);
  FCodeSite.ExitMethod( Self, 'RequestProgrammabilitySync' );
end;

procedure TftSyncClient.RequestProgSyncStatusUpdate;
const
  STR_GetProgrammabilitySyncStatus :AnsiString = 'get status buffer programmability'#13#10;
begin
  FCodeSite.EnterMethod( Self, 'RequestProgSyncStatusUpdate' );
  FPendingStatus := ssGetStatus;
  SendMessage(STR_GetProgrammabilitySyncStatus);
  FCodeSite.SendFmtMsg('PendingStatus: %s',[SyncStatusNames[FPendingStatus]]);
  FCodeSite.SendFmtMsg('CurrentStatus: %s',[SyncStatusNames[FStatus]]);
  FCodeSite.ExitMethod( Self, 'RequestProgSyncStatusUpdate' );
end;

procedure TftSyncClient.RequestDataSyncStatusUpdate;
const
  STR_GetDataSyncStatus :AnsiString = 'get status buffer'#13#10;
begin
  FCodeSite.EnterMethod( Self, 'RequestDataSyncStatusUpdate' );
  FPendingStatus := ssGetStatus;
  SendMessage(STR_GetDataSyncStatus);
  FCodeSite.SendFmtMsg('PendingStatus: %s',[SyncStatusNames[FPendingStatus]]);
  FCodeSite.SendFmtMsg('CurrentStatus: %s',[SyncStatusNames[FStatus]]);
  FCodeSite.ExitMethod( Self, 'RequestDataSyncStatusUpdate' );
end;



end.
