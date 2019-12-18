program Client;

uses
  Forms,
  Unit1 in 'Unit1.pas' {frmMain},
  unWebServiceFileUtils in '..\Common\unWebServiceFileUtils.pas',
  unUpdateClient in '..\Common\unUpdateClient.pas',
  unPath in '..\Common\unPath.pas',
  unIUpdateService in '..\Common\unIUpdateService.pas',
  hcUpdateConsts in '..\Common\hcUpdateConsts.pas',
  hcVersionText in '..\Common\hcVersionText.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
