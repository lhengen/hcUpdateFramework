unit dmADO;

interface

uses
  SysUtils, Classes, DB, ADODB, hcComponent, hcTransactMgrIntf,
  hcADO, IdMessage, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdMessageClient, IdSMTP, dxmdaset
  {$ifdef EUREKALOG}
  ,ExceptionLog
  ,ECore
  ,ETypes
  {$endif}  // EUREKALOG
  ,midaslib, hcFactoryPool, hcSQLMapper
  ;

type
  TRegisteredApp = class(TObject)
    Name :string;
    GUID :string;
  end;

  TdtmADO = class(TDataModule)
    cnWareHouse: ThcADOConnection;
    hcTransactMgr: ThcADOTransactMgr;
    hcSQLMapper: ThcSQLMapper;
    hcFactoryPool: ThcFactoryPool;
    procedure DataModuleCreate(Sender: TObject);
  private
    FDefaultSourceFolder :string;
    FUpdateServerPath :string;
    FDataSource :string;
    procedure LoadConfig;
  public
    procedure OpenDeploymentDatabase;
    procedure LoadRegisteredApplications(Items: TStrings);
    property UpdateServerPath :string read FUpdateServerPath;
    property DataSource :string read FDataSource;
    property DefaultSourceFolder :string read FDefaultSourceFolder;
  end;

var
  dtmADO: TdtmADO;



implementation

uses
  Forms
  ,Dialogs
  ,Controls
  ,hcCodeSiteHelper
  ,Windows, hcUpdateConsts, IniFiles, hcQueryIntf
  ;

{$R *.dfm}

procedure TdtmADO.DataModuleCreate(Sender: TObject);
begin
  LoadConfig;
  OpenDeploymentDatabase;
end;

procedure TdtmADO.OpenDeploymentDatabase;
var
  sConnection: string;
begin
  {$ifdef SQL_NATIVE_CLIENT}
  sConnection := 'Provider=SQLNCLI10.1;';
  {$else}
  sConnection := 'Provider=SQLOLEDB.1;';
  {$endif}
  sConnection := sConnection + 'Integrated Security=SSPI;';
  sConnection := sConnection + 'Persist Security Info=False;';
  sConnection := sConnection + 'Initial Catalog=Deployment;';

  sConnection := sConnection + 'Data Source='+TRIM(FDataSource);
  cnWareHouse.ConnectionString := sConnection;
  try
    cnWareHouse.Open;
  except
    Forms.Application.ProcessMessages;
    MessageDlg('There was an error opening the WareHouse database. You will not be able to tan Global clients or allocate KeyTags.', mtError, [mbOk], 0);
  end;
end;

procedure TdtmADO.LoadConfig;
const
  ConfigSection :string = 'Config';
  DataSourceIdent :string = 'SQLServerDataSource';
  UpdateServerPathIdent :string = 'UpdateServerPath';
  DefaultSourceFolderIdent :string = 'DefaultUpdateSourceFolder';

var
  sFileName :TFileName;
  iniFile :TIniFile;
begin
  //SET DEFAULT VALUES
  FDataSource := '.';
  FUpdateServerPath := 'C:\Data\UpdateFramework\Server\Win32\Debug\';
  FDefaultSourceFolder := 'C:\Data\Studio3\bin';

  sFileName := ChangeFileExt(Application.ExeName,'.ini');
  if FileExists(sFileName) then
  begin
    iniFile := TIniFile.Create(sFileName);
    try
      FDataSource := iniFile.ReadString(ConfigSection,DataSourceIdent,FDataSource);
      FUpdateServerPath := iniFile.ReadString(ConfigSection,UpdateServerPathIdent,FUpdateServerPath);
      FDefaultSourceFolder := iniFile.ReadString(ConfigSection,DefaultSourceFolderIdent,FDefaultSourceFolder);
    finally
      iniFile.Free
    end;
  end
  else
  begin
    iniFile := TIniFile.Create(sFileName);
    try
      iniFile.WriteString(ConfigSection,DataSourceIdent,FDataSource);
      iniFile.WriteString(ConfigSection,UpdateServerPathIdent,FUpdateServerPath);
      iniFile.WriteString(ConfigSection,DefaultSourceFolderIdent,FDefaultSourceFolder);
      iniFile.UpdateFile;
    finally
      iniFile.Free
    end;
    MessageDlg(Format('%s Configuration File Does NOT Exist. '#13#10'Defaults will be used.',[sFileName,Application.Title]), mtWarning, [mbOk], 0);
  end;
end;

procedure TdtmADO.LoadRegisteredApplications(Items :TStrings);
var
  anApp :TRegisteredApp;
  aQuery: IhcQuery;
begin
  Items.Clear;
  aQuery := hcFactoryPool.CreateQuery;
  aQuery.SQL.Text := 'select ApplicationGUID,ApplicationName from Application order by ApplicationName ASC';
  aQuery.Open;
  if aQuery.EOF then
  begin
    {TODO -olwh -cGeneral : invoke a wizard to register an application?}
    MessageDlg('No Applications are Currently Registered.  Please create an Application record',mtWarning,[mbOk],0);
    Halt(0);
  end;
  while not aQuery.EOF do
  begin
    anApp := TRegisteredApp.Create;
    anApp.Name := aQuery.Fields[1].AsString;
    anApp.GUID := aQuery.Fields[0].AsString;
    Items.AddObject(anApp.Name,anApp);
    aQuery.Next;
  end;
end;

end.
