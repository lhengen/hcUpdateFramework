library UpdateISAPIService;

uses
  Winapi.ActiveX,
  System.Win.ComObj,
  Web.WebBroker,
  Web.Win.ISAPIApp,
  Web.Win.ISAPIThreadPool,
  unPath in '..\..\Common\unPath.pas',
  unWebServiceFileUtils in '..\..\Common\unWebServiceFileUtils.pas',
  UpdateServerWebModule in '..\Common\UpdateServerWebModule.pas' {WebModule1: TWebModule},
  FileCache in '..\Common\FileCache.pas',
  dmADO in '..\Common\dmADO.pas',
  UpdateServiceImpl in '..\Common\UpdateServiceImpl.pas',
  UpdateServiceIntf in '..\Common\UpdateServiceIntf.pas',
  hcUpdateConsts in '..\..\Common\hcUpdateConsts.pas';

{$R *.res}

exports
  GetExtensionVersion,
  HttpExtensionProc,
  TerminateExtension;

begin
  CoInitFlags := COINIT_MULTITHREADED;
  Application.Initialize;
  Application.WebModuleClass := WebModuleClass;
  Application.Run;
end.
