program DeploymentManager;

uses
  Forms,
  dmADO in 'dmADO.pas' {dtmADO: TDataModule},
  fmAbout in 'fmAbout.pas',
  fmDeployment in 'fmDeployment.pas' {frmDeployment},
  fmSelectStudios in 'fmSelectStudios.pas' {frmSelectStudios},
  fmMain in 'fmMain.pas' {frmMain},
  fmDeploymentItem in 'fmDeploymentItem.pas' {frmDeploymentItem},
  PatchAPI in '..\Patcher\API\PatchAPI.pas',
  uPatcher in '..\Patcher\API\uPatcher.pas',
  fmEditNotes in 'fmEditNotes.pas' {frmEditNotes},
  hcTreeViewUtils in 'hcTreeViewUtils.pas',
  hcUTCUtils in 'hcUTCUtils.pas',
  hcVersionText in '..\Common\hcVersionText.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TdtmADO, dtmADO);
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
