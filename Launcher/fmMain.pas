unit fmMain;

{
  This application checks for an update on the local file system.  If an update does not exist, it
  launches the target EXE and terminates.

  If an update exists on the file system in the path Updates\Pending\[VersionInfo] then this application
  applies the update by moving the current files specified in the new manifest into a backup directory
  located at Updates\Backup\[VersionInfo], and copying in the new files.  When the update is complete
  the update directory is moved into the Updates\Applied folder, and the update webservice is called
  to signal that the update was applied.

  The Program may find multiple updates on the filesystem.  It will choose the next higher version
  and apply that update first followed by all remaining updates in order of lowest to highest version
  numbers.
}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, uPatcher, unApplyUpdate;

type
  TfrmMain = class(TForm)
    meWhatsNew: TRichEdit;
    meProgress: TMemo;
    btOK: TButton;
    la1: TLabel;
    la2: TLabel;
    pbProgress: TProgressBar;
    procedure btOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    //ini fields
    FAppDir,
    FTargetEXE,
    FUpdateRootDir,
    FWebServiceURI :string;

    FUpdateApplier :ThcUpdateApplier;
    FErrorEncountered :boolean;
    procedure LaunchEXEAndTerminate;
    procedure OnApplyingUpdate(UpdateVersion, WhatsNew: string);
    procedure OnUpdateFailure(UpdateVersion, UpdateErrorMessage :string);
    procedure OnProgressUpdate(Sender: TObject);
    procedure OnPatchProgress(ASender: TObject; const ACurrentPosition,
      AMaximumPosition: LongWord; var ACanContinue: LongBool);
    procedure LoadINISettings;
  public
  end;

var
  frmMain: TfrmMain;

implementation

uses
  IniFiles
  ,CodeSiteLogging
  ,hcVersionList
  ,ShellAPI
  ,StrUtils
  ,JvJCLUtils
  ;

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
var
  nIndex,
  nSecs :integer;
  Param :string;
begin
  FErrorEncountered := False;
  if ParamCount = 1 then
  begin
    Param := ParamStr(1);
    if StartsText('pause',Param) then
    begin
      //determine delay time
      nIndex := Pos(':',Param);
      nSecs := StrToInt(copy(Param,nIndex+1,Length(Param)));
      meProgress.Lines.Add(Format('Delaying CheckForUpdates by %d Seconds',[nSecs]));
      sleep(nSecs * 1000);
    end;
  end;
  LoadINISettings;
  FUpdateApplier := ThcUpdateApplier.Create;
  FUpdateApplier.ApplySilentUpdates := False;  //launcher provides UI for feedback so ignore silent updates
  FUpdateApplier.OnApplyUpdate := OnApplyingUpdate;
  FUpdateApplier.OnProgressUpdate := OnProgressUpdate;
  FUpdateApplier.OnPatchProgress := OnPatchProgress;
  FUpdateApplier.OnApplyUpdateError := OnUpdateFailure;
  if FUpdateApplier.CheckForUpdatesAndApply = 0 then  //if no updates we're found & applied then
    LaunchEXEAndTerminate;
end;

procedure TfrmMain.OnPatchProgress(ASender : TObject;
  const ACurrentPosition : LongWord;
  const AMaximumPosition : LongWord;
  var ACanContinue : LongBool);
begin
  if AMaximumPosition <> pbProgress.Max then
    pbProgress.Max := AMaximumPosition;
  if ACurrentPosition <> pbProgress.Position then
    pbProgress.Position := ACurrentPosition;
  Forms.Application.ProcessMessages;
end;

procedure TfrmMain.OnProgressUpdate(Sender :TObject);
{
  This event is called every time a line is added so just add
  the last line to the TMemo and scroll it into view.
}
begin
  meProgress.Lines.Add(FUpdateApplier.Progress[FUpdateApplier.Progress.Count - 1]);
  SendMessage(meProgress.Handle, EM_SCROLLCARET, 0, 0);
  Forms.Application.ProcessMessages;
end;

procedure TfrmMain.OnUpdateFailure(UpdateVersion, UpdateErrorMessage: string);
begin
  MessageDlg(Format('An error occurred while applying the %s update.  %s may not be usable.  We recommend you contact technical support immediately.',[UpdateVersion,FTargetEXE]),mtError,[mbOK],0);
  btOK.Caption := 'Close';
end;

procedure TfrmMain.OnApplyingUpdate(UpdateVersion :string; WhatsNew :string);
var
  stringStream :TStringStream;
begin
  Caption := Format('Applying Update: %s',[UpdateVersion]);
  stringStream := TStringStream.Create(WhatsNew);
  try
    meWhatsNew.Lines.LoadFromStream(stringStream);
  finally
    stringStream.Free;
  end;
  Forms.Application.ProcessMessages;
end;

procedure TfrmMain.btOKClick(Sender: TObject);
begin
  LaunchEXEAndTerminate;
end;

procedure TfrmMain.LaunchEXEAndTerminate;
var
  FileNameWithPath :string;
begin
  FileNameWithPath := FAppDir + FTargetEXE;
  if not FileExists(FileNameWithPath) then
    MessageDlg(Format('EXE Specified in INI file does not Exist: '#13#10'''%s''',[FileNameWithPath]),mtWarning,[mbOk],0);
  ShellExecute(Handle, 'open', PWideChar(WideString(FAppDir + FTargetEXE)), nil, nil, SW_SHOWNORMAL) ;
  PostQuitMessage(0);
end;

procedure TfrmMain.LoadINISettings;
const
  ConfigSection :string = 'Config';
  UpdateRootDirIdent :string = 'UpdateRootDir';
  AppDirIdent :string = 'AppDir';
  AppToLaunchIdent :string = 'AppToLaunch';
  WebServiceURIIdent :string = 'UpdateServiceURI';

var
  iniFile :TIniFile;
  sFileName :TFileName;

begin
  //initialize all settings to their default values
  FAppDir := IncludeTrailingPathDelimiter(LongToShortPath(ExtractFilePath(Application.ExeName)));
  FTargetEXE := 'Some.EXE';
  FUpdateRootDir := IncludeTrailingPathDelimiter(LongToShortPath(Format('%s%s\',[FAppDir,'Updates'])));
  FWebServiceURI := 'http://localhost:8080/soap/IUpdateService';

  sFileName := ChangeFileExt(Application.ExeName,'.ini');
  if FileExists(sFileName) then
  begin
    iniFile := TIniFile.Create(sFileName);
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
  begin
    iniFile := TIniFile.Create(sFileName);
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
end;


end.
