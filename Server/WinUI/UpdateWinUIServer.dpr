program UpdateWinUIServer;
{$APPTYPE GUI}

{$define D16}

uses
  FastMM4,
  Forms,
  WebReq,
  IdHTTPWebBrokerBridge,
  fmMain in 'fmMain.pas' {frmMain},
  dmADO in '..\Common\dmADO.pas' {dtmADO: TDataModule},
  UpdateServerWebModule in '..\Common\UpdateServerWebModule.pas' {WebModule1: TWebModule},
  UpdateServiceImpl in '..\Common\UpdateServiceImpl.pas',
  UpdateServiceIntf in '..\Common\UpdateServiceIntf.pas',
  unPath in '..\..\Common\unPath.pas',
  unWebServiceFileUtils in '..\..\Common\unWebServiceFileUtils.pas',
  Vcl.Themes,
  Vcl.Styles,
  FileCache in '..\Common\FileCache.pas',
  hcUpdateConsts in '..\..\Common\hcUpdateConsts.pas',
  dmFireDAC in '..\Common\dmFireDAC.pas';

{$R *.res}

begin
  if WebRequestHandler <> nil then
    WebRequestHandler.WebModuleClass := WebModuleClass;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
