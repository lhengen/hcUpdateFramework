program UpdateNTService;

uses
  FastMM4,
  Vcl.SvcMgr,
  SysUtils,
  WebReq,
  IdHTTPWebBrokerBridge,
  unUpdateNTService in 'unUpdateNTService.pas' {UpdateServerService: TService},
  dmADO in '..\Common\dmADO.pas' {dtmADO: TDataModule},
  UpdateServerWebModule in '..\Common\UpdateServerWebModule.pas' {WebModule1: TWebModule},
  UpdateServiceImpl in '..\Common\UpdateServiceImpl.pas',
  UpdateServiceIntf in '..\Common\UpdateServiceIntf.pas',
  unPath in '..\..\Common\unPath.pas',
  unWebServiceFileUtils in '..\..\Common\unWebServiceFileUtils.pas',
  unitDebugService in 'Z:\NTLowLevel100\Source\unitDebugService.pas',
  FileCache in '..\Common\FileCache.pas',
  hcUpdateConsts in '..\..\Common\hcUpdateConsts.pas';

{$R *.RES}
{$R  UpdateServerEventLogMessages.RES}

begin
  // Windows 2003 Server requires StartServiceCtrlDispatcher to be
  // called before CoRegisterClassObject, which can be called indirectly
  // by Application.Initialize. TServiceApplication.DelayInitialize allows
  // Application.Initialize to be called from TService.Main (after
  // StartServiceCtrlDispatcher has been called).
  //
  // Delayed initialization of the Application object may affect
  // events which then occur prior to initialization, such as
  // TService.OnCreate. It is only recommended if the ServiceApplication
  // registers a class object with OLE and is intended for use with
  // Windows 2003 Server.
  //
  //   Application.DelayInitialize := True;
  //
  if WebRequestHandler <> nil then
    WebRequestHandler.WebModuleClass := WebModuleClass;

  if (paramCount > 0) and (SameText(ParamStr(1), '-DEBUG')) then
  begin
    FreeAndNil (Application);
    Application := TDebugServiceApplication.Create(nil);
  end;

  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(TUpdateServerService, UpdateServerService);
  Application.Run;
end.
