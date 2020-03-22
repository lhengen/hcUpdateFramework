unit hcUpdateSettings;

interface

uses
  SysUtils;

const
  AutoUpdateConfigFileName :string = 'AutoUpdate.ini';

type
  ThcAutoUpdateSettings = class(TObject)
  private
    FInstallationGUID,
    FAppDir,
    FTargetEXE,
    FUpdateRootDir,
    FWebServiceURI :string;
    FFileName: TFileName;
    FLogAllMessages: boolean;
    FSleepTimeInMinutes :integer;
    procedure SetAppDir(const AValue: string);
    procedure SetUpdateRootDir(const AValue: string);
  public
    procedure ReadSettings;
    procedure WriteSettings;
    constructor Create;

    property AppDir :string read FAppDir write SetAppDir;
    property TargetEXE :string read FTargetEXE write FTargetEXE;
    property UpdateRootDir :string read FUpdateRootDir write SetUpdateRootDir;
    property WebServiceURI :string read FWebServiceURI write FWebServiceURI;
    property InstallionGUID :string read FInstallationGUID write FInstallationGUID;
    property LogAllMessages :boolean read FLogAllMessages write FLogAllMessages;
    property SleepTimeInMinutes :integer read FSleepTimeInMinutes write FSleepTimeInMinutes;
  end;

var
  AutoUpdateSettings :ThcAutoUpdateSettings;

implementation

uses
  Forms,
  JvJCLUtils,
  IniFiles;

const
  SharedSection :string = 'Shared';
  ServiceSection :string = 'Service';
  LauncherSection :string = 'Launcher';

  UpdateRootDirIdent :string = 'UpdateRootDir';
  AppDirIdent :string = 'AppDir';
  AppToLaunchIdent :string = 'AppToLaunch';
  WebServiceURIIdent :string = 'UpdateServiceURI';
  InstallationGUIDIdent :string = 'InstallationGUID';
  LogAllMessagesIdent :string = 'LogAllMessages';
  SleepTimeInMinutesIdent :string = 'SleepTimeInMinutes';

constructor ThcAutoUpdateSettings.Create;
begin
  inherited;

  //initialize all settings to their default values
  AppDir := IncludeTrailingPathDelimiter(LongToShortPath(ExtractFilePath(Application.ExeName)));
  FTargetEXE := 'Some.EXE';
  FWebServiceURI := 'http://localhost:8080/soap/IUpdateService';
  FFileName := FAppDir + AutoUpdateConfigFileName;
  FLogAllMessages := True;
  FSleepTimeInMinutes := 15;
  FInstallationGUID := EmptyStr;
end;

procedure ThcAutoUpdateSettings.ReadSettings;
var
  iniFile :TIniFile;
begin
  if FileExists(FFileName) then
  begin
    iniFile := TIniFile.Create(FFileName);
    try
      FUpdateRootDir := iniFile.ReadString(SharedSection,UpdateRootDirIdent,FUpdateRootDir);
      FAppDir := iniFile.ReadString(SharedSection,AppDirIdent,FAppDir);
      FWebServiceURI := iniFile.ReadString(SharedSection,WebServiceURIIdent,FWebServiceURI);
      FInstallationGUID := iniFile.ReadString(SharedSection,InstallationGUIDIdent,FInstallationGUID);

      //make sure the Target EXE exists even if the ThcUpdateApplier created the default ini
      if not iniFile.ValueExists(LauncherSection,AppToLaunchIdent) then
      begin
        iniFile.WriteString(SharedSection,AppToLaunchIdent,FTargetEXE);
        iniFile.UpdateFile;
      end;
      FTargetEXE := iniFile.ReadString(LauncherSection,AppToLaunchIdent,FTargetEXE);

      FLogAllMessages := iniFile.ReadBool(ServiceSection,LogAllMessagesIdent,FLogAllMessages);
      FSleepTimeInMinutes := iniFile.ReadInteger(ServiceSection,SleepTimeInMinutesIdent,FSleepTimeInMinutes);
    finally
      iniFile.Free
    end;
  end
  else
    WriteSettings;
end;

procedure ThcAutoUpdateSettings.SetAppDir(const AValue: string);
begin
  FAppDir := IncludeTrailingPathDelimiter(AValue);
  FUpdateRootDir := FAppDir + 'Updates\';
end;

procedure ThcAutoUpdateSettings.SetUpdateRootDir(const AValue: string);
begin
  FUpdateRootDir := IncludeTrailingPathDelimiter(AValue);
end;

procedure ThcAutoUpdateSettings.WriteSettings;
var
  iniFile: TIniFile;
begin
  iniFile := TIniFile.Create(FFileName);
  try
    iniFile.WriteString(SharedSection,UpdateRootDirIdent,FUpdateRootDir);
    iniFile.WriteString(SharedSection,AppDirIdent,FAppDir);
    iniFile.WriteString(SharedSection,WebServiceURIIdent,FWebServiceURI);
    iniFile.WriteString(SharedSection,InstallationGUIDIdent,FInstallationGUID);

    iniFile.WriteString(LauncherSection,AppToLaunchIdent,FTargetEXE);

    iniFile.WriteBool(ServiceSection,LogAllMessagesIdent,FLogAllMessages);
    iniFile.WriteInteger(ServiceSection,SleepTimeInMinutesIdent,FSleepTimeInMinutes);
    iniFile.UpdateFile;
  finally
    iniFile.Free
  end;
end;

initialization
  AutoUpdateSettings := ThcAutoUpdateSettings.Create;
  AutoUpdateSettings.ReadSettings;

finalization
  FreeAndNil(AutoUpdateSettings);

end.
