program Launcher;

uses
  Forms,
  fmMain in 'fmMain.pas' {frmMain},
  PatchAPI in '..\Patcher\API\PatchAPI.pas',
  uPatcher in '..\Patcher\API\uPatcher.pas',
  unIUpdateService in '..\Common\unIUpdateService.pas',
  unApplyUpdate in '..\Common\unApplyUpdate.pas',
  hcVersionList in '..\Common\hcVersionList.pas',
  hcUpdateConsts in '..\Common\hcUpdateConsts.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
