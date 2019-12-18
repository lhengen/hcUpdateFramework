unit unApplyUpdate;

interface

uses
  Classes, uPatcher;
{
  This object is shared by the Launcher and the ClientUpdateService.  It is
  responsible for the application of updates from the Pending subdir.  If the
  update is marked to be applied by the service, then the client update service
  will apply the update and the launcher will ignore the update if it happens to
  run and see that an update is available.  Normally, the launcher runs only
  when there are users logged into the machine, and any updates to be performed
  by the ClientUpdateService would occur when users are not logged in, or at a
  time when the application being updated is unlikely to be active (ie:  5 am).
}

type
  ThcApplyUpdateEvent = procedure (UpdateVersion :string; WhatsNew :string) of object;
  ThcApplyUpdateErrorEvent = procedure (UpdateVersion, UpdateErrorMessage :string) of object;
  ThcUpdateApplier = class(TObject)
  private
    FErrorEncountered :boolean;
    FApplySilentUpdates :boolean;
    FAppDir,
    FUpdateRootDir,
    FWebServiceURI :string;
    FProgress :TStrings;
    FOnProgressUpdate :TNotifyEvent;
    FOnApplyUpdate :ThcApplyUpdateEvent;
    FOnPatchProgress :TOnPatchProgress;
    FOnApplyUpdateError :ThcApplyUpdateErrorEvent;
    function MoveDir(const fromDir, toDir: string): Boolean;
    procedure ApplyUpdate(const UpdateSubDir :string);
    procedure DoPatcherComplete(ASender: TObject; const AStatusCode: LongWord;
      const AStatusMessage: string);
    procedure DoPatchFileBegin(ASender: TObject; APatchItem: TPatchItem; const APatchItemNumber,
      APatchItemCount: Integer; var AContinueIfError: Boolean);
    procedure DoPatchFileEnd(ASender: TObject; APatchItem: TPatchItem; const APatchItemNumber,
      APatchItemCount: Integer);
    procedure DoPatcherProgress(ASender: TObject; const ACurrentPosition,
      AMaximumPosition: LongWord; var ACanContinue: LongBool);
    procedure OnProgressChange(Sender :TObject);
    procedure LoadINISettings;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    function CheckForUpdatesAndApply :integer;  //returns the # of updates applied/found
    property Progress :TStrings read FProgress;
    property OnProgressUpdate :TNotifyEvent read FOnProgressUpdate write FOnProgressUpdate;  //fired when progress messages are added to Progress
    property OnApplyUpdate :ThcApplyUpdateEvent read FOnApplyUpdate write FOnApplyUpdate;
    property OnApplyUpdateError :ThcApplyUpdateErrorEvent read FOnApplyUpdateError write FOnApplyUpdateError;
    property OnPatchProgress :TOnPatchProgress read FOnPatchProgress write FOnPatchProgress;
    property ApplySilentUpdates :boolean read FApplySilentUpdates write FApplySilentUpdates;
  end;


implementation

uses
  ShellAPI
  ,SysUtils
  ,iniFiles
  ,hcVersionList
  ,Forms
  ,Controls
  ,Windows
  ,XMLDoc
  ,XMLIntf
  ,JvJCLUtils
  ,unIUpdateService
  ,hcUpdateConsts
  ,ActiveX
  ,System.Zip
  {$ifdef FABUTAN}
  ,ftSyncClient,
  {$endif}

  ;

function ThcUpdateApplier.MoveDir(const fromDir, toDir: string): Boolean;
var
  fos: TSHFileOpStruct;
  nErrorCode :integer;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc  := FO_MOVE;
    fFlags := FOF_NOERRORUI or FOF_FILESONLY;
    pFrom  := PChar(fromDir + #0);
    pTo    := PChar(toDir + #0)
  end;
  nErrorCode := ShFileOperation(fos);
  Result := (0 = nErrorCode);
  if not Result then
    Progress.Add(Format('Attempt to Move %s to %s failed with Error Code: %d',[fromDir,toDir,nErrorCode]));
end;


procedure ThcUpdateApplier.OnProgressChange(Sender: TObject);
{
  This event is called whenever the progress string list is changed.
}
begin
  if assigned(FOnProgressUpdate) then
    FOnProgressUpdate(Self);
end;

procedure ThcUpdateApplier.LoadINISettings;
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
  FAppDir := LongToShortPath(ExtractFilePath(Application.ExeName));
  FUpdateRootDir := LongToShortPath(Format('%s%s',[FAppDir,'Updates']));
  FWebServiceURI := 'http://localhost:8080/soap/IUpdateService';

  sFileName := ChangeFileExt(Application.ExeName,'.ini');
  if FileExists(sFileName) then
  begin
    iniFile := TIniFile.Create(sFileName);
    try
      FUpdateRootDir := iniFile.ReadString(ConfigSection,UpdateRootDirIdent,FUpdateRootDir);
      FAppDir := iniFile.ReadString(ConfigSection,AppDirIdent,FAppDir);
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
      iniFile.WriteString(ConfigSection,WebServiceURIIdent,FWebServiceURI);
      iniFile.UpdateFile;
    finally
      iniFile.Free
    end;
  end;
end;

function ThcUpdateApplier.CheckForUpdatesAndApply :integer;
{
  We assume this EXE is in the same directory as the TargetEXE by default.
}
var
  I :integer;
  sr :TSearchRec;
  FileAttrs :Integer;
  slDirs :ThcVersionList;
begin
  Progress.Add('Checking for Updates...');
  LoadINISettings;
  //get directories of pending updates
  slDirs := ThcVersionList.Create;
  try
    //get directory listing under UpdateRootDir of all Pending Updates
    FileAttrs := faDirectory;
    if SysUtils.FindFirst(FUpdateRootDir + 'Pending\*.*', FileAttrs, sr) = 0 then
    begin
      repeat
        if ((sr.Attr and FileAttrs) = sr.Attr) and (sr.Name <> '.') and (sr.Name <> '..') then
        begin
          slDirs.Add(sr.Name);
        end;
      until FindNext(sr) <> 0;
      SysUtils.FindClose(sr);
    end;

    //sort the directories in Ascending order so we will apply the latest version update last
    slDirs.Sort;

    //if we have multiple directories make sure to select the lowest version #
    for I := 0 to slDirs.Count - 1 do
    begin
      if not FErrorEncountered then
        ApplyUpdate(slDirs[I]);
    end;
    Result := slDirs.Count;
  finally
    slDirs.Free;
  end;
end;

procedure ThcUpdateApplier.AfterConstruction;
begin
  inherited;
  FProgress := TStringList.Create;
  TStringList(FProgress).OnChange := OnProgressChange;
end;

procedure ThcUpdateApplier.ApplyUpdate(const UpdateSubDir :string);
var
  SaveCursor :TCursor;
  aPatcher :TPatcher;
  I,
  nMax :Integer;
  XMLDoc : IXMLDocument;
  iRootNode,
  iNode : IXMLNode;
  sTempDirName,
  sManifestFileName,
  sPatchedFileName,
  sErrorMessage,
  SourceFile,
  DestinationFile,
  UpdateResult,
  ApplicationGUID,
  LocationGUID,
  UpdateDir,
  AppliedDir,
  BackupDir,
  TargetPath :string;
  bIsSilent :boolean;
  UpdateService :IUpdateService;
  WinResult :integer;
  ZipFile :TZipFile;
  {$ifdef FABUTAN}
  SyncClient :TftSyncClient;
  SyncProgrammability: boolean;
  SyncData: boolean;
  {$endif}
begin
  CoInitialize(nil);
  try
    try
      //load manifest
      XMLDoc := TXMLDocument.Create(nil);
      try
        UpdateDir := LongToShortPath(Format('%s%s\%s\',[FUpdateRootDir,'Pending',UpdateSubDir]));
        sManifestFileName := UpdateDir + ManifestFileName;
        Progress.Add(Format('Loading Update Manifest from %s',[sManifestFileName]));
        XMLDoc.LoadFromFile(sManifestFileName);
        XMLDoc.Active := True;

        iRootNode := XMLDoc.ChildNodes.First;
        LocationGUID := iRootNode.Attributes['LocationGUID'];
        ApplicationGUID := iRootNode.Attributes['ApplicationGUID'];
        {$ifdef FABUTAN}
        SyncProgrammability := StrToBool(iRootNode.Attributes['SyncProgrammability']);
        SyncData := StrToBool(iRootNode.Attributes['SyncData']);
        {$endif}

        //if the INI file says we're to apply silent updates then proceed otherwise
        //log that we're ignoring the update and exit
        bIsSilent := iRootNode.Attributes['IsSilent'];
        if (bIsSilent and not FApplySilentUpdates) then
          Exit;

        if assigned(FOnApplyUpdate) then
          FOnApplyUpdate(iRootNode.Attributes['UpdateVersion'],iRootNode.Attributes['WhatsNew']);

        //---backup files about to be replaced
        Progress.Add('Backing Up Files...');
        BackupDir := Format('%s%s\%s\',[FUpdateRootDir,'Backup',LongToShortPath(UpdateSubDir)]);
        Progress.Add(Format('Creating Backup Folder: %s',[BackupDir]));
        if not SysUtils.ForceDirectories(BackupDir) then
          raise Exception.Create(Format('Unable to create folder: %s',[BackupDir]));

        nMax := iRootNode.ChildNodes.Count - 1;
        Progress.Add(Format('Processing Manifest: %d Items',[iRootNode.ChildNodes.Count]));
        for I := 0 to nMax do
        begin
          iNode := iRootNode.ChildNodes[I];
          if iNode.Attributes['TargetPath'] = AppDir then
            TargetPath := FAppDir
          else
            TargetPath := iNode.Attributes['TargetPath'];

          //backup the file
          SourceFile := TargetPath + iNode.Attributes['FileName'];
          DestinationFile := BackupDir + iNode.Attributes['FileName'];
          if FileExists(SourceFile) then
          begin
            Progress.Add(Format('Copying %s to %s',[SourceFile,DestinationFile]));
            CopyFile(PWideChar(WideString(SourceFile)), PWideChar(WideString(DestinationFile)),False);
            if GetLastError <> 0 then
              raise Exception.Create(SysErrorMessage(GetLastError));
          end;

          if iNode.Attributes['IsAZip'] then
          begin
            ZipFile := TZipFile.Create;
            try
              SourceFile := UpdateDir + iNode.Attributes['FileName'];
              Progress.Add(Format('Unzipping %s to %s',[SourceFile,TargetPath]));
              ZipFile.ExtractZipFile(SourceFile,TargetPath + '\',nil);
            finally
              ZipFile.Free;
            end;
          end
          else

          if iNode.Attributes['IsAPatch'] then
          begin  //apply the patch
            SourceFile := ChangeFileExt(UpdateDir + iNode.Attributes['FileName'],PatchFileExtension);
            DestinationFile := TargetPath + iNode.Attributes['FileName'];
            sPatchedFileName := ChangeFileExt(DestinationFile,'.new');
            if FileExists(sPatchedFileName) then
            begin
              SysUtils.DeleteFile(sPatchedFileName);
              if GetLastError <> 0 then
                raise Exception.Create(SysErrorMessage(GetLastError));
            end;

            SaveCursor := Screen.Cursor;
            Screen.Cursor := crHourGlass;
            try
              aPatcher := uPatcher.TPatcher.Create;
              try
                aPatcher.AlwaysRaiseExceptions := True;
                aPatcher.PatchFileExtension := PatchFileExtension;
                aPatcher.PatchFilePath := UpdateDir;
                aPatcher.AddFileToPatch
                  (DestinationFile
                  ,sPatchedFileName
                  ,SourceFile
                  );
                aPatcher.OnPatchProgress := DoPatcherProgress;
                aPatcher.OnPatchesComplete := DoPatcherComplete;
                aPatcher.OnPatchFileBegin := DoPatchFileBegin;
                aPatcher.OnPatchFileEnd := DoPatchFileEnd;
                Progress.Add(Format('Applying Patch %s to %s creating %s',[SourceFile,DestinationFile,sPatchedFileName]));
                aPatcher.ApplyPatches;
              finally
                aPatcher.Free;
              end;

              //delete the original EXE and rename the Patched version
              SysUtils.DeleteFile(DestinationFile);
              if GetLastError <> 0 then
                raise Exception.Create(SysErrorMessage(GetLastError));
              RenameFile(sPatchedFileName,DestinationFile);
              if GetLastError <> 0 then
                raise Exception.Create(SysErrorMessage(GetLastError));
            finally
              Screen.Cursor := SaveCursor;
            end;
          end
          else
          begin
            //copy in the new version
            SourceFile := UpdateDir + iNode.Attributes['FileName'];
            DestinationFile := TargetPath + iNode.Attributes['FileName'];
            Progress.Add(Format('Copying %s to %s',[SourceFile,DestinationFile]));
            CopyFile(PWideChar(WideString(SourceFile)), PWideChar(WideString(DestinationFile)),False);
            if GetLastError <> 0 then
              raise Exception.Create(SysErrorMessage(GetLastError));
          end;
        end;

        //launch any items necessary after all files have been processed since there may be some dependances
        //items are launched from the Target directory so that a file can be patched and then launched
        for I := 0 to nMax do
        begin
          iNode := iRootNode.ChildNodes[I];
          if iNode.Attributes['Launch'] then
          begin
            DestinationFile := TargetPath + iNode.Attributes['FileName'];
            Progress.Add(Format('Launching %s',[DestinationFile]));
            WinResult := ShellExecute(0, 'open',PChar(DestinationFile), PChar(''), PChar(TargetPath), SW_SHOWNORMAL) ;
            Progress.Add(Format('ShellExecute reported: %d',[WinResult]));
          end;
        end;
      finally
        XMLDoc.Active := False;  //close the manifest
        XMLDoc := nil;  //release the interface
      end;

      //---copy the new manifest file - this is an implied file to be updated
      //backup the original file
      SourceFile := TargetPath + ManifestFileName;
      DestinationFile := BackupDir + ManifestFileName;
      Progress.Add(Format('Moving %s to %s',[SourceFile,DestinationFile]));
      if not FileExists(DestinationFile) then
      begin
        MoveFile(PWideChar(WideString(SourceFile)), PWideChar(WideString(DestinationFile)));
        if GetLastError <> 0 then
          raise Exception.Create(SysErrorMessage(GetLastError));
      end;

      //copy in the new version
      SourceFile := UpdateDir + ManifestFileName;
      DestinationFile := TargetPath + ManifestFileName;
      Progress.Add(Format('Copying %s to %s',[SourceFile,DestinationFile]));
      CopyFile(PWideChar(WideString(SourceFile)), PWideChar(WideString(DestinationFile)),False);
      if GetLastError <> 0 then
        raise Exception.Create(SysErrorMessage(GetLastError));

      //move the Update from Pending into Applied
      AppliedDir := FUpdateRootDir + 'Applied\';
      if not SysUtils.ForceDirectories(AppliedDir) then
        raise Exception.Create(Format('Unable to create folder: %s',[AppliedDir]));

      sTempDirName := ExcludeTrailingPathDelimiter(UpdateDir);
      Progress.Add(Format('Moving %s to %s',[sTempDirName,AppliedDir]));
      if not MoveDir(sTempDirName,AppliedDir) then
         raise Exception.Create(Format('Unable to Move %s to Applied folder',[sTempDirName]));

      {$ifdef FABUTAN}
      if SyncProgrammability then
      begin
        SyncClient := TftSyncClient.Create(nil);
        try
          SyncClient.SyncProgrammability(60000)
        finally
          SyncClient.Free;
        end;
      end;

      if SyncData then
      begin
        SyncClient := TftSyncClient.Create(nil);
        try
          SyncClient.SyncData(60000)
        finally
          SyncClient.Free;
        end;
      end;
      {$endif}

      //tell the UpdateServer we applied the update
      UpdateResult := UpdateResultNames[urSuccess];
      UpdateService := GetIUpdateService(False, FWebServiceURI);
      Progress.Add('Calling Web Service to Report Update Applied SuccessFully!');
      try
        UpdateService.UpdateApplied(ApplicationGUID,LocationGUID,iRootNode.Attributes['UpdateVersion'],UpdateResult,Progress.Text);
      except
        on E: Exception do   //server is likely not running
        begin   //translate the exception and re-raise (consumer must handle)
          sErrorMessage := Format('Fabware was updated successfully but could not contact Head Office.  If you have any problems, contact technical support and advise them of the following: Error making UpdateApplied web service call to %s.  '#13#10'The original error reported is: %s',[FWebServiceURI,E.Message]);
          Progress.Add(sErrorMessage);
        end;
      end;
    except
      on E: Exception do
      begin
        //EPatcherExceptions are always logged by the DoPatcherComplete event handler
        if not(E is EPatcherException) then
        begin
          Progress.Add('Error:');
          Progress.Add(E.Message);
        end;

        //tell the UpdateServer we failed during application of the update
        UpdateResult := UpdateResultNames[urFailure];
        if not Assigned(UpdateService) then
          UpdateService := GetIUpdateService(False, FWebServiceURI);
        Progress.Add('Calling Web Service to Report Update Failed!');
        try
          UpdateService.UpdateApplied(ApplicationGUID,LocationGUID,iRootNode.Attributes['UpdateVersion'],UpdateResult,Progress.Text);
        except
          on E: Exception do   //server is likely not running
          begin
            sErrorMessage := Format('Error making UpdateApplied web service call to %s.  '#13#10'The error reported is: %s',[FWebServiceURI,E.Message]);
            Progress.Add(sErrorMessage);
          end;
        end;
        if assigned(FOnApplyUpdateError) then
          FOnApplyUpdateError(UpdateDir,E.Message);

        FErrorEncountered := True;
      end;
    end;
  finally
    CoUninitialize;
  end;
end;


procedure ThcUpdateApplier.BeforeDestruction;
begin
  FProgress.Free;
  inherited;
end;


procedure ThcUpdateApplier.DoPatchFileBegin(
  ASender : TObject;
  APatchItem : TPatchItem;
  const APatchItemNumber : Integer;
  const APatchItemCount : Integer;
  var AContinueIfError : Boolean);
begin
  Progress.Add('Performing patch action on item [' + IntToStr(APatchItemNumber) + '] of [' + IntToStr(APatchItemCount) + ']');
  Progress.Add('-------------------------------------------------------------------');
  Progress.Add('Old File Version: [' + APatchItem.OldFileName + ']');
  Progress.Add('New File Version: [' + APatchItem.NewFileName + ']');
  Progress.Add('Patch Filename: [' + APatchItem.PatchFileName + ']');
  Progress.Add('-------------------------------------------------------------------');
end;

procedure ThcUpdateApplier.DoPatchFileEnd(ASender : TObject; APatchItem : TPatchItem;
  const APatchItemNumber, APatchItemCount : Integer);
begin
  Progress.Add('Finished patching [' + IntToStr(APatchItemNumber) + '] of [' + IntToStr(APatchItemCount) + ']');
end;

procedure ThcUpdateApplier.DoPatcherComplete(ASender : TObject;
  const AStatusCode : LongWord; const AStatusMessage : string);
var
  LMsg : string;
begin
  if AStatusCode <> 0 then
  begin
    LMsg := 'ERROR: 0x' + IntToHex(AStatusCode, 8) + ':'#13#10 + AStatusMessage;
  end
  else
  begin
    LMsg := 'Patching successfully completed';
  end;
  Progress.Add(LMsg);
end;

procedure ThcUpdateApplier.DoPatcherProgress(ASender : TObject;
  const ACurrentPosition : LongWord;
  const AMaximumPosition : LongWord;
  var ACanContinue : LongBool);
var
  LStr : string;
begin
  LStr := 'Complete: ' + FormatFloat('#,##0', ACurrentPosition) + ' of ' + FormatFloat('#,##0', AMaximumPosition);
  Progress.Add(LStr);

  if assigned(FOnPatchProgress) then
    FOnPatchProgress(ASender,ACurrentPosition,AMaximumPosition,ACanContinue);
end;

end.
