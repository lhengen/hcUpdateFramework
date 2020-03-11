program ClientUpdateService;

uses
  SvcMgr,
  SysUtils,
  unClientUpdateService in 'unClientUpdateService.pas' {ClientUpdater: TService},
  unUpdateClient in '..\Common\unUpdateClient.pas',
  unWebServiceFileUtils in '..\Common\unWebServiceFileUtils.pas',
  unUpdateClientThread in 'unUpdateClientThread.pas',
  unPath in '..\Common\unPath.pas',
  unIUpdateService in '..\Common\unIUpdateService.pas',
  unApplyUpdate in '..\Common\unApplyUpdate.pas',
  PatchAPI in '..\Patcher\API\PatchAPI.pas',
  uPatcher in '..\Patcher\API\uPatcher.pas',
  unitDebugService in 'unitDebugService.pas',
  hcUpdateConsts in '..\Common\hcUpdateConsts.pas',
  hcVersionList in '..\Common\hcVersionList.pas',
  hcVersionText in '..\Common\hcVersionText.pas',
  hcUpdateSettings in '..\Common\hcUpdateSettings.pas';

{$R *.RES}

begin
  if (paramCount > 0) and (SameText(ParamStr(1), '-DEBUG')) then
  begin
    FreeAndNil (Application);
    Application := TDebugServiceApplication.Create(nil);
  end
  else
  begin
    FreeAndNil (Application);
    Application := TServiceApplication.Create(nil);
  end;

  Application.Initialize;
  Application.CreateForm(TClientUpdater, ClientUpdater);
  Application.Run;
end.
