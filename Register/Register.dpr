program Register;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Dialogs,
  unUpdateClient in '..\Common\unUpdateClient.pas',
  hcUpdateSettings in '..\Common\hcUpdateSettings.pas',
  unIUpdateService in '..\Common\unIUpdateService.pas',
  unPath in '..\Common\unPath.pas',
  hcUpdateConsts in '..\Common\hcUpdateConsts.pas',
  unWebServiceFileUtils in '..\Common\unWebServiceFileUtils.pas';

var
  Client :TUpdateClient;
  sUpdateResult :string;
begin
  Client := TUpdateClient.Create(nil);
  try
    sUpdateResult := Client.RegisterInstall;
  finally
    Client.Free;
  end;
end.
