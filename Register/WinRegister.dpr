program WinRegister;

uses
  Vcl.Forms,
  unUpdateClient in '..\Common\unUpdateClient.pas',
  hcUpdateSettings in '..\Common\hcUpdateSettings.pas',
  unIUpdateService in '..\Common\unIUpdateService.pas',
  unPath in '..\Common\unPath.pas',
  hcUpdateConsts in '..\Common\hcUpdateConsts.pas',
  unWebServiceFileUtils in '..\Common\unWebServiceFileUtils.pas',
  MainForm in 'MainForm.pas' {Form3};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
