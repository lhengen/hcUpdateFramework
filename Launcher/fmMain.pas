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
    FUpdateApplier :ThcUpdateApplier;
    FErrorEncountered :boolean;
    procedure LaunchEXEAndTerminate;
    procedure OnApplyingUpdate(UpdateVersion, WhatsNew: string);
    procedure OnUpdateFailure(UpdateVersion, UpdateErrorMessage :string);
    procedure OnProgressUpdate(Sender: TObject);
    procedure OnPatchProgress(ASender: TObject; const ACurrentPosition,
      AMaximumPosition: LongWord; var ACanContinue: LongBool);
  public
  end;

var
  frmMain: TfrmMain;

implementation

uses
  CodeSiteLogging
  ,hcUpdateSettings
  ,hcVersionList
  ,ShellAPI
  ,StrUtils
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
  MessageDlg(Format('An error occurred while applying the %s update.  %s may not be usable.  We recommend you contact technical support immediately.',[UpdateVersion,AutoUpdateSettings.TargetEXE]),mtError,[mbOK],0);
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
  FileNameWithPath := IncludeTrailingPathDelimiter(AutoUpdateSettings.AppDir) + AutoUpdateSettings.TargetEXE;
  if not FileExists(FileNameWithPath) then
    MessageDlg(Format('EXE Specified in INI file does not Exist: '#13#10'''%s''',[FileNameWithPath]),mtWarning,[mbOk],0);
  ShellExecute(Handle, 'open', PWideChar(WideString(AutoUpdateSettings.AppDir + AutoUpdateSettings.TargetEXE)), nil, nil, SW_SHOWNORMAL) ;
  PostQuitMessage(0);
end;

end.
