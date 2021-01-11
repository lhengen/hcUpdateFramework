unit dmFireDAC;

interface

uses
  SysUtils, Classes, DB, ADODB,
  IdMessage, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdMessageClient, IdSMTP
  ,midaslib, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait, FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  FireDAC.Moni.Base, FireDAC.Moni.RemoteClient
  ;


type
  TdtmFireDAC = class(TDataModule)
    qryWorker: TFDQuery;
    cnDeployment: TFDConnection;
    FDMoniRemoteClientLink1: TFDMoniRemoteClientLink;
    procedure DataModuleCreate(Sender: TObject);
  private
    FDatabasePath :string;
    FUserName :string;
    FPassword :string;
    FDefaultPort, //TCP port UpdateService listens on
    FMaxConcurrentWebRequests :integer;  //how many concurrent web requests we can service
  public
    procedure LoadConfig;
    procedure OpenDBConnection;
    property DefaultPort :integer read FDefaultPort;
    property MaxConcurrentWebRequests :integer read FMaxConcurrentWebRequests;
  end;

var
  dtmADO: TdtmFireDAC;

implementation

uses
  Forms
  ,Dialogs
  ,Controls
  ,Windows, System.IniFiles
  ;

{$R *.dfm}

procedure TdtmFireDAC.DataModuleCreate(Sender: TObject);
begin
  //at this point the splash form exists but the global variable for the form is not set
  LoadConfig;
  OpenDBConnection;
end;


procedure TdtmFireDAC.OpenDBConnection;
begin
  cnDeployment.Params.Clear;
  cnDeployment.Params.Database := FDatabasePath;
  cnDeployment.Params.DriverID := 'FB';
  cnDeployment.Params.UserName := FUserName;
  cnDeployment.Params.Password := FPassword;
  cnDeployment.Params.Add('lc_ctype=WIN1252');
  {$ifdef DEBUG}
  cnDeployment.Params.Add('MonitorBy=Remote');
  {$endif}
  try
    cnDeployment.Open;
  except
    Forms.Application.ProcessMessages;
    MessageDlg('There was an error opening the database.', mtError, [mbOk], 0);
  end;
end;

procedure TdtmFireDAC.LoadConfig;
const
  ConfigSection :string = 'Config';
  MaxConcurrentWebRequestsIdent :string = 'MaxConcurrentWebRequests';
  DefaultPortIdent :string = 'ListeningPort';
  DatabaseFileNameIdent :string = 'DatabaseFileName';
  UserNameIdent :string = 'UserName';
  PasswordIdent :string = 'Password';

var
  sFileName :TFileName;
  iniFile :TIniFile;

begin
  sFileName := ChangeFileExt(Application.ExeName,'.ini');
  //SET DEFAULT VALUES
  FDatabasePath := 'C:\Data\SkyStone\Deployment.fdb';
  FUserName := 'sysdba';
  FPassword := 'masterkey';
  FMaxConcurrentWebRequests := 32;
  FDefaultPort := 8080;

  if FileExists(sFileName) then
  begin
    iniFile := TIniFile.Create(sFileName);
    try
      FMaxConcurrentWebRequests := iniFile.ReadInteger(ConfigSection,MaxConcurrentWebRequestsIdent,FMaxConcurrentWebRequests);
      FDefaultPort := iniFile.ReadInteger(ConfigSection,DefaultPortIdent,FDefaultPort);
      FDatabasePath := iniFile.ReadString(ConfigSection,DatabaseFileNameIdent,FDatabasePath);
      FUserName := iniFile.ReadString(ConfigSection,UserNameIdent,FUserName);
      FPassword := iniFile.ReadString(ConfigSection,PasswordIdent,FPassword);
    finally
      iniFile.Free
    end;
  end
  else
  begin
    iniFile := TIniFile.Create(sFileName);
    try
      iniFile.WriteInteger(ConfigSection,MaxConcurrentWebRequestsIdent,FMaxConcurrentWebRequests);
      iniFile.WriteInteger(ConfigSection,DefaultPortIdent,FDefaultPort);
      iniFile.WriteString(ConfigSection,DatabaseFileNameIdent,FDatabasePath);
      iniFile.WriteString(ConfigSection,UserNameIdent,FUserName);
      iniFile.WriteString(ConfigSection,PasswordIdent,FPassword);
      iniFile.UpdateFile;
    finally
      iniFile.Free
    end;
    MessageDlg(Format('%s Configuration File Does NOT Exist. '#13#10'Defaults will be used.',[sFileName,Application.Title]), mtWarning, [mbOk], 0);
  end;
end;

end.
