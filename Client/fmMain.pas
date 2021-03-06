unit fmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmMain = class(TForm)
    btCheckForUpdates: TButton;
    laUpdateServerURI: TLabel;
    Label2: TLabel;
    btRegisterInstall: TButton;
    procedure btCheckForUpdatesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btRegisterInstallClick(Sender: TObject);
  private
  public
  end;

var
  frmMain: TfrmMain;

implementation

uses
  unUpdateClient, IniFiles, Winapi.ShellAPI, hcUpdateSettings;


{$R *.dfm}

procedure TfrmMain.btCheckForUpdatesClick(Sender: TObject);
var
  Client :TUpdateClient;
  sUpdateResult :string;
begin
  Client := TUpdateClient.Create(Self);
  sUpdateResult := Client.CheckForUpdates;
  if sUpdateResult <> '' then
    ShowMessage(sUpdateResult)
  else
  begin
    MessageDlg('An Error Occurred.  Launching Notepad with the log file',mtError,[mbOK],0);
    ShellExecuteW(Forms.Application.Handle, 'open', PWideChar('notepad.exe'), PWideChar('client.log'), PWideChar(ExtractFilePath(Application.ExeName)), SW_SHOWNORMAL) ;
  end;
end;

procedure TfrmMain.btRegisterInstallClick(Sender: TObject);
var
  Client :TUpdateClient;
  sUpdateResult :string;
begin
  Client := TUpdateClient.Create(Self);
  sUpdateResult := Client.RegisterInstall;
  if sUpdateResult <> '' then
    ShowMessage(sUpdateResult)
  else
  begin
    MessageDlg('An Error Occurred.  Launching Notepad with the log file',mtError,[mbOK],0);
    ShellExecuteW(Forms.Application.Handle, 'open', PWideChar('notepad.exe'), PWideChar('client.log'), PWideChar(ExtractFilePath(Application.ExeName)), SW_SHOWNORMAL) ;
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  laUpdateServerURI.Caption := AutoUpdateSettings.WebServiceURI;
end;

end.
