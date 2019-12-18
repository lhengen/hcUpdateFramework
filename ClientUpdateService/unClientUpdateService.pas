unit unClientUpdateService;

{
  In order for CodeSite to be able to send messages, the service must be configured
  as an interactive service after it is installed.  Otherwise, Codesite will not log
  any messages to any destination.
}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs
  ,unUpdateClientThread
  ;


resourcestring
  SRESException = 'Client Update Service reported %1.  Please Check the ClientUpdateService.csl log file for details.';

type
  TClientUpdater = class(TService)
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceAfterInstall(Sender: TService);
  private
    FClientUpdateThread :TUpdateClientThread;
    procedure RegisterMessages(Sender:TService);
    procedure RegisterDescription(Sender:TService);
    procedure ThreadTerminate(Sender: TObject);
  public
    function GetServiceController: TServiceController; override;
  end;

var
  ClientUpdater: TClientUpdater;

implementation

{$R *.DFM}
{$R  ClientUpdateServiceEventLogMessages.RES}

uses
{$IFDEF hcCodeSite}
 hcCodesiteHelper,
{$ENDIF}
  unPath
  ,Registry
  ;


procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  ClientUpdater.Controller(CtrlCode);
end;

function TClientUpdater.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;


procedure TClientUpdater.ServiceStart(Sender: TService; var Started: Boolean);
begin
  {$IFDEF hcCodeSite}
  hcCodeSite.DestinationDetails:= 'File[Path='+ExtractFilePath(AppFileName)+'ClientUpdateService.csl] ';
  hcCodeSite.SendMsg('Service is starting');
  {$ENDIF}
  AllowPause := False;  //don't allow the service to be paused.  Start and Stop only.
  Interactive := True;
  try
    FClientUpdateThread := TUpdateClientThread.Create(True);
    with FClientUpdateThread do
    begin
      Service := Self;
      FreeOnTerminate := True;
      OnTerminate := ThreadTerminate;
      Start;
    end;

    Started := True;
    if True then

    LogMessage('Client Update Service Started',EVENTLOG_INFORMATION_TYPE,0,0);
    {$IFDEF hcCodeSite}
    hcCodeSite.SendMsg('Service has been started');
    {$ENDIF}
  except
    on e: Exception do
    begin
      {$IFDEF hcCodeSite}
      hcCodeSite.SendException(E);
      {$ENDIF}
      LogMessage(E.Message,EVENTLOG_ERROR_TYPE,0,103);
      Started := False;
    end;
  end;
end;

procedure TClientUpdater.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  try
    {$IFDEF hcCodeSite}
    hcCodeSite.SendMsg('Service is stopping');
    {$ENDIF}
    Stopped := True;
    LogMessage('Client Update Service Stopped',EVENTLOG_INFORMATION_TYPE,0,0);
  except
    on e: Exception do
    begin
      {$IFDEF hcCodeSite}
      hcCodeSite.SendException(E);
      {$ENDIF}
      LogMessage(Format('Exception Occurred: %s',[E.Message]));
      Stopped := False;
    end;
  end;
end;

procedure TClientUpdater.ThreadTerminate(Sender: TObject);
begin
  //restart the worker thread if the service is supposed to be running
  if self.Status = csRunning then
  begin
    {$IFDEF hcCodeSite}
    hcCodeSite.SendMsg('Starting New Thread');
    {$ENDIF}
    FClientUpdateThread := TUpdateClientThread.Create(True);
    with FClientUpdateThread do
    begin
      Service := Self;
      FreeOnTerminate := True;
      OnTerminate := ThreadTerminate;
      Start;
    end;
  end;
end;

procedure TClientUpdater.ServiceAfterInstall(Sender: TService);
begin
  RegisterDescription(Sender);
  RegisterMessages(Sender);
end;

procedure TClientUpdater.RegisterMessages(Sender :TService);
{
  Register the message table compiled into this EXE with the EventLog so it can properly display
  any of our error messages.
}
begin
  with TRegistry.Create(KEY_READ or KEY_WRITE) do
  try
    RootKey := HKEY_LOCAL_MACHINE;
    if OpenKey('SYSTEM\CurrentControlSet\Services\EventLog\Application\' + Name, True) then
    begin
      WriteString('EventMessageFile', ParamStr(0));
    end
  finally
    Free;
  end;
end;

procedure TClientUpdater.RegisterDescription(Sender :TService);
{
  Register description displayed in the Service Manager.
}
begin
  with TRegistry.Create(KEY_READ or KEY_WRITE) do
  try
    RootKey := HKEY_LOCAL_MACHINE;
    if OpenKey('SYSTEM\CurrentControlSet\Services\' + Name, True) then
    begin
      WriteString('Description', 'A service to update application components.');
    end
  finally
    Free;
  end;
end;

end.
