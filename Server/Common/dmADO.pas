unit dmADO;

interface

uses
  SysUtils, Classes, DB, ADODB,
  IdMessage, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdMessageClient, IdSMTP
  ,midaslib
  ;


type
  TdtmADO = class(TDataModule)
    cnDeployment: TADOConnection;
    qryWorker: TADOQuery;
    procedure DataModuleCreate(Sender: TObject);
  private
    FDataSource :string;
    FDefaultPort, //TCP port UpdateService listens on
    FMaxConcurrentWebRequests :integer;  //how many concurrent web requests we can service
  public
    procedure LoadConfig;
    procedure OpenDBConnection;
    property DefaultPort :integer read FDefaultPort;
    property MaxConcurrentWebRequests :integer read FMaxConcurrentWebRequests;
  end;

var
  dtmADO: TdtmADO;

implementation

uses
  Forms
  ,Dialogs
  ,Controls
  ,Windows, System.IniFiles
  ;

{$R *.dfm}

procedure TdtmADO.DataModuleCreate(Sender: TObject);
begin
  //at this point the splash form exists but the global variable for the form is not set
  LoadConfig;
  OpenDBConnection;
end;


procedure TdtmADO.OpenDBConnection;
var
  sConnection: string;
begin
  {$ifdef SQL_NATIVE_CLIENT}
  sConnection := 'Provider=SQLNCLI10.1;';
  {$else}
  sConnection := 'Provider=SQLOLEDB.1;';
  {$endif}
  {$ifdef FABUTAN}
  sConnection := sConnection + 'User ID=studio;';
  sConnection := sConnection + 'Password=b58e#j*3puL!;';
  sConnection := sConnection + 'Persist Security Info=True;';
  sConnection := sConnection + 'Initial Catalog=FabWareHouse;';
  {$ELSE}
  sConnection := sConnection + 'Integrated Security=SSPI;';
  sConnection := sConnection + 'Persist Security Info=False;';
  sConnection := sConnection + 'Initial Catalog=Deployment;';
  {$ENDIF}
  sConnection := sConnection + 'Data Source='+TRIM(FDataSource);
  cnDeployment.ConnectionString := sConnection;
  try
    cnDeployment.Open;
  except
    Forms.Application.ProcessMessages;
    MessageDlg('There was an error opening the WareHouse database. You will not be able to tan Global clients or allocate KeyTags.', mtError, [mbOk], 0);
  end;
end;

procedure TdtmADO.LoadConfig;
const
  ConfigSection :string = 'Config';
  DataSourceIdent    :string = 'SQLServerDataSource';
  MaxConcurrentWebRequestsIdent :string = 'MaxConcurrentWebRequests';
  DefaultPortIdent :string = 'ListeningPort';

var
  sFileName :TFileName;
  iniFile :TIniFile;

begin
  sFileName := ChangeFileExt(Application.ExeName,'.ini');
  //SET DEFAULT VALUES
  FDataSource := '.';
  FMaxConcurrentWebRequests := 32;
  FDefaultPort := 8080;

  if FileExists(sFileName) then
  begin
    iniFile := TIniFile.Create(sFileName);
    try
      FDataSource := iniFile.ReadString(ConfigSection,DataSourceIdent,FDataSource);
      FMaxConcurrentWebRequests := iniFile.ReadInteger(ConfigSection,MaxConcurrentWebRequestsIdent,FMaxConcurrentWebRequests);
      FDefaultPort := iniFile.ReadInteger(ConfigSection,DefaultPortIdent,FDefaultPort);
    finally
      iniFile.Free
    end;
  end
  else
  begin
    iniFile := TIniFile.Create(sFileName);
    try
      iniFile.WriteString(ConfigSection,DataSourceIdent,FDataSource);
      iniFile.WriteInteger(ConfigSection,MaxConcurrentWebRequestsIdent,FMaxConcurrentWebRequests);
      iniFile.WriteInteger(ConfigSection,DefaultPortIdent,FDefaultPort);
      iniFile.UpdateFile;
    finally
      iniFile.Free
    end;
    MessageDlg(Format('%s Configuration File Does NOT Exist. '#13#10'Defaults will be used.',[sFileName,Application.Title]), mtWarning, [mbOk], 0);
  end;
end;

end.
