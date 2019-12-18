unit fmDeploymentItem;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, ExtCtrls, hcDeployment, hcErrorIndicator, hcComponent,
  hcUIObjectBinding, ComCtrls, uPatcher;

type
  TfrmDeploymentItem = class(TForm)
    ledFileName: TLabeledEdit;
    ledVersion: TLabeledEdit;
    ledTargetPath: TLabeledEdit;
    btnFileName: TSpeedButton;
    btnTargetPath: TSpeedButton;
    btOK: TButton;
    btCancel: TButton;
    odDeploymentItems: TFileOpenDialog;
    obDeploymentItem: ThcUIObjectBinder;
    hcErrorIndicator1: ThcErrorIndicator;
    chkIsAPatch: TCheckBox;
    pbProgress: TProgressBar;
    meProgress: TMemo;
    chkLaunch: TCheckBox;
    chkIsAZip: TCheckBox;
    procedure btnFileNameClick(Sender: TObject);
    procedure chkIsAPatchClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure chkIsAZipClick(Sender: TObject);
  private
    FDeploymentItem :ThcDeploymentItem;
    procedure SetDeploymentItem(Value :ThcDeploymentItem);
    procedure DoPatcherComplete(ASender: TObject; const AStatusCode: LongWord;
      const AStatusMessage: string);
    procedure DoPatcherProgress(ASender: TObject; const ACurrentPosition,
      AMaximumPosition: LongWord; var ACanContinue: LongBool);
    procedure DoPatchFileBegin(ASender: TObject; APatchItem: TPatchItem; const APatchItemNumber,
      APatchItemCount: Integer; var AContinueIfError: Boolean);
    procedure DoPatchFileEnd(ASender: TObject; APatchItem: TPatchItem; const APatchItemNumber,
      APatchItemCount: Integer);
    procedure Collapse;
    procedure Expand;
  public
    class function Execute(DeploymentItem :ThcDeploymentItem): boolean;
    property DeploymentItem :ThcDeploymentItem read FDeploymentItem write SetDeploymentItem;
  end;


implementation

uses
  dmADO, hcVersionText, hcUpdateConsts, hcCheckBoxMediator, System.Zip, TemporaryCursor;

{$R *.dfm}

const
  CollapsedHeight :Integer = 195;
  ExpandedHeight :Integer = 340;



procedure TfrmDeploymentItem.btnFileNameClick(Sender: TObject);
var
  sExt :string;
begin
  odDeploymentItems.DefaultFolder := dtmADO.DefaultSourceFolder;
  odDeploymentItems.Title := 'Select File to Add to Deployment';
  if odDeploymentItems.Execute then
  begin
    FDeploymentItem.FileName.AsString := ExtractFileName(odDeploymentItems.FileName);
    FDeploymentItem.SourcePath.AsString := ExtractFilePath(odDeploymentItems.FileName);
    //populate the version information if the file selected is a BPL, DLL, or EXE
    sExt := uppercase(ExtractFileExt(odDeploymentItems.FileName));
    if (sExt = '.DLL') or (sExt = '.BPL') or (sExt = '.EXE') then
    begin
      FDeploymentItem.Version.AsString := hcVersionText.GetFileVersionText(odDeploymentItems.FileName);
      //version of update defaults to first EXE components added
      if ((FDeploymentItem.GetRootObject as ThcDeployment).UpdateVersion.AsString = '') then
        (FDeploymentItem.GetRootObject as ThcDeployment).UpdateVersion.AsString := FDeploymentItem.Version.AsString;
      FDeploymentItem.TargetPath.AsString := AppDir;
    end;
  end;
end;

procedure TfrmDeploymentItem.chkIsAPatchClick(Sender: TObject);
var
  sVersion :string;
  aPatcher :TPatcher;
  PatchSourceFileName,
  sExt :string;
  SaveCursor :TCursor;
begin
  if chkIsAPatch.Checked then
  begin
    //get filename of version we are patching from - make sure it's the same filename as Target and an earlier version #
    odDeploymentItems.DefaultFolder := dtmADO.DefaultSourceFolder;

    odDeploymentItems.Title := Format('Select version of %s prior to %s to Generate a Patch From',[FDeploymentItem.FileName.AsString,FDeploymentItem.Version.AsString]);
    odDeploymentItems.DefaultExtension := ExtractFileExt(FDeploymentItem.FileName.AsString);
    odDeploymentItems.FileName := FDeploymentItem.FileName.AsString;
    if odDeploymentItems.Execute then
    begin
      //filename must be the same and it must be an earlier version
      PatchSourceFileName := odDeploymentItems.FileName;


      //populate the version information if the file selected is a BPL, DLL, or EXE
      sExt := uppercase(ExtractFileExt(PatchSourceFileName));
      if (sExt = '.DLL') or (sExt = '.BPL') or (sExt = '.EXE') then
      begin
        sVersion := hcVersionText.GetFileVersionText(PatchSourceFileName);
        if FDeploymentItem.IsAPriorVersion(sVersion) then
        begin
          Expand;
          aPatcher := uPatcher.TPatcher.Create;
          SaveCursor := Screen.Cursor;
          Screen.Cursor := crHourGlass;
          try
            aPatcher.PatchFileExtension := PatchFileExtension;
            aPatcher.PatchFilePath := FDeploymentItem.SourcePath.AsString;
            aPatcher.AddFileToPatch
              (PatchSourceFileName
              ,FDeploymentItem.SourcePath.AsString + FDeploymentItem.FileName.AsString
              ,ChangeFileExt(FDeploymentItem.SourcePath.AsString + FDeploymentItem.FileName.AsString,PatchFileExtension)
              );
            aPatcher.OnPatchProgress := DoPatcherProgress;
            aPatcher.OnPatchesComplete := DoPatcherComplete;
            aPatcher.OnPatchFileBegin := DoPatchFileBegin;
            aPatcher.OnPatchFileEnd := DoPatchFileEnd;
            aPatcher.CreatePatches;
          finally
            Screen.Cursor := SaveCursor;
            aPatcher.Free;
          end;
        end
        else
        begin
          MessageDlg(Format('The selected file is version %s which is Not a previous version!'#13#10#13#10'A patch cannot be generated...',[sVersion]),mtWarning,[mbOK],0);
          FDeploymentItem.IsAPatch.AsBoolean := False;  //uncheck Patch
          Collapse;
        end;
      end;
    end;
  end;
end;

procedure TfrmDeploymentItem.chkIsAZipClick(Sender: TObject);
var
  SourceFileName,
  TargetFileName :string;
  ZipFile: TZipFile;
begin
  //if the user has chosen to deploy a Zipped version of the selected file when they click on it we need to create the ZIP
  //it will be copied to the Update folder when the user OKs the deployment
  if chkIsAZip.Checked then
  begin
    SourceFileName := FDeploymentItem.SourcePath.AsString + FDeploymentItem.FileName.AsString;
    TargetFileName := FDeploymentItem.SourcePath.AsString + ChangeFileExt(FDeploymentItem.FileName.AsString,'.ZIP');
    if FileExists(TargetFileName) then
      DeleteFile(TargetFileName);

    TTemporaryCursor.SetTemporaryCursor;
    ZipFile := TZipFile.Create;
    try
      ZipFile.Open(TargetFileName,TZipMode.zmWrite);
      ZipFile.Add(SourceFileName);
      //change the file extension so the Manifest is correct and the right file is copied to the update folder
      FDeploymentItem.FileName.AsString := ChangeFileExt(FDeploymentItem.FileName.AsString,'.ZIP');
    finally
      ZipFile.Free;
    end;

  end;
end;

class function TfrmDeploymentItem.Execute(DeploymentItem :ThcDeploymentItem): boolean;
var
  dlg: TfrmDeploymentItem;
begin
  dlg := TfrmDeploymentItem.Create(nil);
  try
    dlg.Position := poMainFormCenter;
    dlg.BorderStyle := bsDialog;
    dlg.DeploymentItem := DeploymentItem;
    Result := dlg.ShowModal = mrOK
  finally // wrap up
    dlg.Free;
  end;    // try/finally
end;

procedure TfrmDeploymentItem.FormCreate(Sender: TObject);
begin
  Collapse;
end;

procedure TfrmDeploymentItem.SetDeploymentItem(Value: ThcDeploymentItem);
begin
  FDeploymentItem := Value;
  obDeploymentItem.BoundObject := Value;
end;

procedure TfrmDeploymentItem.DoPatchFileBegin(
  ASender : TObject;
  APatchItem : TPatchItem;
  const APatchItemNumber : Integer;
  const APatchItemCount : Integer;
  var AContinueIfError : Boolean);
begin
  meProgress.Lines.Add('Performing patch action on item [' + IntToStr(APatchItemNumber) + '] of [' + IntToStr(APatchItemCount) + ']');
  meProgress.Lines.Add('-------------------------------------------------------------------');
  meProgress.Lines.Add('Old File Version: [' + APatchItem.OldFileName + ']');
  meProgress.Lines.Add('New File Version: [' + APatchItem.NewFileName + ']');
  meProgress.Lines.Add('Patch Filename: [' + APatchItem.PatchFileName + ']');
  meProgress.Lines.Add('-------------------------------------------------------------------');
end;

procedure TfrmDeploymentItem.DoPatchFileEnd(ASender : TObject; APatchItem : TPatchItem;
  const APatchItemNumber, APatchItemCount : Integer);
begin
  meProgress.Lines.Add('Finished patching [' + IntToStr(APatchItemNumber) + '] of [' + IntToStr(APatchItemCount) + ']');
end;

procedure TfrmDeploymentItem.DoPatcherComplete(ASender : TObject;
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
  meProgress.Lines.Add(LMsg);
end;

procedure TfrmDeploymentItem.DoPatcherProgress(ASender : TObject;
  const ACurrentPosition : LongWord;
  const AMaximumPosition : LongWord;
  var ACanContinue : LongBool);
var
  LStr : string;
begin
  if AMaximumPosition <> pbProgress.Max then
    pbProgress.Max := AMaximumPosition;
  if ACurrentPosition <> pbProgress.Position then
    pbProgress.Position := ACurrentPosition;

  LStr := 'Complete: ' + FormatFloat('#,##0', ACurrentPosition) + ' of ' + FormatFloat('#,##0', AMaximumPosition);
  meProgress.Lines.Add(LStr);
  Application.ProcessMessages;
end;


procedure TfrmDeploymentItem.Expand;
begin
  Height := ExpandedHeight;
  pbProgress.Visible := True;
  meProgress.Visible := True;
end;

procedure TfrmDeploymentItem.Collapse;
begin
  Height := CollapsedHeight;
  pbProgress.Visible := False;
  meProgress.Visible := False;
end;

end.

