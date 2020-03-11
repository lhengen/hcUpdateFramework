unit hcUpdateSettings;

interface

uses
  SysUtils;

const
  AutoUpdateConfigFileName :string = 'AutoUpdate.ini';

type
  ThcAutoUpdateSettings = class(TObject)
  private
    FLocationGUID,
    FAppDir,
    FTargetEXE,
    FUpdateRootDir,
    FWebServiceURI :string;
    FFileName: TFileName;
  public
    procedure ReadSettings;
    procedure WriteSettings;
    constructor Create;

    property AppDir :string read FAppDir write FAppDir;
    property TargetEXE :string read FTargetEXE write FTargetEXE;
    property UpdateRootDir :string read FUpdateRootDir write FUpdateRootDir;
    property WebServiceURI :string read FWebServiceURI write FWebServiceURI;
    property LocationGUID :string read FLocationGUID write FLocationGUID;
  end;

var
  AutoUpdateSettings :ThcAutoUpdateSettings;

implementation

uses
  Forms,
  JvJCLUtils,
  IniFiles;

const
  ConfigSection :string = 'Config';
  UpdateRootDirIdent :string = 'UpdateRootDir';
  AppDirIdent :string = 'AppDir';
  AppToLaunchIdent :string = 'AppToLaunch';
  WebServiceURIIdent :string = 'UpdateServiceURI';

constructor ThcAutoUpdateSettings.Create;
begin
  inherited;

  //initialize all settings to their default values
  FAppDir := IncludeTrailingPathDelimiter(LongToShortPath(ExtractFilePath(Application.ExeName)));
  FTargetEXE := 'Some.EXE';
  FUpdateRootDir := IncludeTrailingPathDelimiter(LongToShortPath(Format('%s%s\',[FAppDir,'Updates'])));
  FWebServiceURI := 'http://localhost:8080/soap/IUpdateService';
  FFileName := FAppDir + AutoUpdateConfigFileName;
end;

procedure ThcAutoUpdateSettings.ReadSettings;
var
  iniFile :TIniFile;
begin
  if FileExists(FFileName) then
  begin
    iniFile := TIniFile.Create(FFileName);
    try
      FUpdateRootDir := iniFile.ReadString(ConfigSection,UpdateRootDirIdent,FUpdateRootDir);
      FAppDir := iniFile.ReadString(ConfigSection,AppDirIdent,FAppDir);
      //make sure the Target EXE exists even if the ThcUpdateApplier created the default ini
      if not iniFile.ValueExists(ConfigSection,AppToLaunchIdent) then
      begin
        iniFile.WriteString(ConfigSection,AppToLaunchIdent,FTargetEXE);
        iniFile.UpdateFile;
      end;
      FTargetEXE := iniFile.ReadString(ConfigSection,AppToLaunchIdent,FTargetEXE);
      FWebServiceURI := iniFile.ReadString(ConfigSection,WebServiceURIIdent,FWebServiceURI);
    finally
      iniFile.Free
    end;
  end
  else
    WriteSettings;
end;

procedure ThcAutoUpdateSettings.WriteSettings;
var
  iniFile: TIniFile;
begin
  iniFile := TIniFile.Create(FFileName);
  try
    iniFile.WriteString(ConfigSection,UpdateRootDirIdent,FUpdateRootDir);
    iniFile.WriteString(ConfigSection,AppDirIdent,FAppDir);
    iniFile.WriteString(ConfigSection,AppToLaunchIdent,FTargetEXE);
    iniFile.WriteString(ConfigSection,WebServiceURIIdent,FWebServiceURI);
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
