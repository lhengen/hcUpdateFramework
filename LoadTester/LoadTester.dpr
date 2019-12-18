program LoadTester;

uses
  FastMM4,
  Vcl.Forms,
  fmMain in 'fmMain.pas' {frmMain},
  unClientUpdateThread in 'unClientUpdateThread.pas',
  unUpdateClient in '..\Common\unUpdateClient.pas',
  hcUpdateConsts in '..\Common\hcUpdateConsts.pas',
  unIUpdateService in '..\Common\unIUpdateService.pas',
  unPath in '..\Common\unPath.pas',
  unWebServiceFileUtils in '..\Common\unWebServiceFileUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
