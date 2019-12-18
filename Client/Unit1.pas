unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmMain = class(TForm)
    btCheckForUpdates: TButton;
    laUpdateServerURI: TLabel;
    Label2: TLabel;
    procedure btCheckForUpdatesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FURI :string;
  public
  end;

var
  frmMain: TfrmMain;

implementation

uses
  unUpdateClient, IniFiles, Winapi.ShellAPI;


{$R *.dfm}

procedure TfrmMain.btCheckForUpdatesClick(Sender: TObject);
var
  Client :TUpdateClient;
  sUpdateResult :string;
begin
  Client := TUpdateClient.Create(Self);
  Client.URI := FURI;
  sUpdateResult := Client.CheckForUpdates;
  if sUpdateResult <> '' then
    ShowMessage(sUpdateResult)
  else
  begin
    MessageDlg('An Error Occurred.  Launching Notepad with the log file',mtError,[mbOK],0);
    ShellExecuteW(Forms.Application.Handle, 'open', PWideChar('notepad.exe'), PWideChar('client.log'), PWideChar(ExtractFilePath(Application.ExeName)), SW_SHOWNORMAL) ;
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
const
  ConfigSection :string = 'Config';
  PollingIntervalInMinutesIdent :string = 'PollingIntervalinMinutes';
  UpdateServiceURIIdent :string = 'UpdateServiceURI';
var
  sFileName :string;
  iniFile :TiniFile;
begin
  FURI :=  'http://localhost:8080/soap/IUpdateService';

  sFileName := ChangeFileExt(Application.ExeName,'.ini');
  if FileExists(sFileName) then
  begin
    iniFile := TIniFile.Create(sFileName);
    try
      FURI := iniFile.ReadString(ConfigSection,UpdateServiceURIIdent,FURI);
    finally
      iniFile.Free
    end;
  end
  else
  begin
    iniFile := TIniFile.Create(sFileName);
    try
      iniFile.WriteString(ConfigSection,UpdateServiceURIIdent,FURI);
      iniFile.UpdateFile;
    finally
      iniFile.Free
    end;
  end;
  laUpdateServerURI.Caption := FURI;
end;

end.
