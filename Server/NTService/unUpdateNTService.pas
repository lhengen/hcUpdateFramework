unit unUpdateNTService;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics
  ,Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs, IdHTTPWebBrokerBridge, IdContext,
  dmADO;

type
  TUpdateServerService = class(TService)
    procedure ServiceAfterInstall(Sender: TService);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceAfterUninstall(Sender: TService);
    procedure ServiceShutdown(Sender: TService);
  private
    FDataModule :TdtmADO;
    FServer: TIdHTTPWebBrokerBridge;
    procedure RegisterDescription(Sender: TService);
    procedure RegisterMessages(Sender: TService);
    procedure UnRegisterDescription(Sender: TService);
    procedure UnRegisterMessages(Sender: TService);
    procedure LogServerException(AContext: TIdContext; AException: Exception);
    procedure StopService;
  public
    function GetServiceController: TServiceController; override;
  end;

var
  UpdateServerService: TUpdateServerService;

implementation

uses
  System.Win.Registry, System.Win.ComObj, Winapi.ActiveX, Web.WebReq, IdException;

{$R *.DFM}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  UpdateServerService.Controller(CtrlCode);
end;

function TUpdateServerService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TUpdateServerService.ServiceAfterInstall(Sender: TService);
begin
  RegisterDescription(Sender);
  RegisterMessages(Sender);
end;

procedure TUpdateServerService.ServiceAfterUninstall(Sender: TService);
begin
  UnRegisterDescription(Sender);
  UnRegisterMessages(Sender);
end;

procedure TUpdateServerService.LogServerException(AContext: TIdContext; AException: Exception);
begin
  LogMessage(AException.Message,EVENTLOG_ERROR_TYPE,0,103);
end;

procedure TUpdateServerService.ServiceShutdown(Sender: TService);
begin
  StopService;
end;

procedure TUpdateServerService.ServiceStart(Sender: TService; var Started: Boolean);
begin
  {$IFDEF hcCodeSite}
  CodeSite.DestinationDetails:= 'TCP[Host=127.0.0.1],File[Path='+ExtractFilePath(AppFileName)+'UpdateServerService.csl]';
  CodeSite.SendMsg('Service is starting');
  {$ENDIF}

  AllowPause := False;  //don't allow the service to be paused.  Start and Stop only.
  Interactive := True;
  try

    CoInitialize(nil);

    //we don't use anything here other than the setting, but it's best to connect to the database when starting than wait until we receive the first request before we fail if cannot connect to DB
    FDataModule := TdtmADO.Create(Self);
    FServer := TIdHTTPWebBrokerBridge.Create(Self);
    if not FServer.Active then
    begin
      FServer.Bindings.Clear;
      FServer.DefaultPort := FDataModule.DefaultPort;
      FServer.OnException := LogServerException;
      WebRequestHandler.MaxConnections := FDataModule.MaxConcurrentWebRequests;
      FServer.Active := True;
    end;

    Started := True;
    LogMessage('Starting Update Server Service',EVENTLOG_INFORMATION_TYPE,0,0);
    {$IFDEF hcCodeSite}
    CodeSite.SendMsg('Service has been started');
    {$ENDIF}
  except
    on e: Exception do
    begin
      {$IFDEF hcCodeSite}
      CodeSite.SendException;
      {$ENDIF}
      LogMessage(E.Message,EVENTLOG_ERROR_TYPE,0,103);
      Started := False;
    end;
  end;
end;

procedure TUpdateServerService.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  StopService;
end;

procedure TUpdateServerService.StopService;
var
  Stopped :boolean;
begin
  if assigned(FServer) and (FServer.Active) then
  begin
    FServer.Active := False;
    Stopped := not (FServer.Active and FDataModule.cnDeployment.Connected);
  end;
  CoUninitialize();
  if Stopped then
    LogMessage('Update Server Service Stopped',EVENTLOG_INFORMATION_TYPE,0,0)
  else
    LogMessage('Problem stopping Update Server Service',EVENTLOG_ERROR_TYPE,0,103);
end;


procedure TUpdateServerService.RegisterMessages(Sender :TService);
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

procedure TUpdateServerService.UnRegisterMessages(Sender :TService);
begin
  with TRegistry.Create(KEY_READ or KEY_WRITE) do
  try
    RootKey := HKEY_LOCAL_MACHINE;
    DeleteKey('SYSTEM\CurrentControlSet\Services\EventLog\Application\' + Name);
  finally
    Free;
  end;
end;

procedure TUpdateServerService.RegisterDescription(Sender :TService);
{
  Register description displayed in the Service Manager.
}
begin
  with TRegistry.Create(KEY_READ or KEY_WRITE) do
  try
    RootKey := HKEY_LOCAL_MACHINE;
    if OpenKey('SYSTEM\CurrentControlSet\Services\' + Name, True) then
    begin
      WriteString('Description', 'A web service to send updates to client machines.');
    end
  finally
    Free;
  end;
end;

procedure TUpdateServerService.UnRegisterDescription(Sender :TService);
begin
  with TRegistry.Create(KEY_READ or KEY_WRITE) do
  try
    RootKey := HKEY_LOCAL_MACHINE;
    DeleteKey('SYSTEM\CurrentControlSet\Services\' + Name);
  finally
    Free;
  end;
end;

end.
