unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, Buttons, CheckLst, ComCtrls, uPatcher;

type
  TPatcherDemo = class(TForm)
    ProgressBar1 : TProgressBar;
    gbx1 : TGroupBox;
    cbx1 : TComboBox;
    lbl2 : TLabel;
    lbx1 : TCheckListBox;
    btn1 : TBitBtn;
    gbx2 : TGroupBox;
    lbx2 : TCheckListBox;
    btn2 : TBitBtn;
    mmo1 : TMemo;
    gbx3 : TGroupBox;
    lbl1 : TLabel;
    lbl3 : TLabel;
    lbl4 : TLabel;
    edt3 : TEdit;
    edt1 : TEdit;
    edt2 : TEdit;
    grd1 : TStringGrid;
    btn3 : TBitBtn;
    btn4 : TBitBtn;
    lbl5 : TLabel;
    cbx2 : TComboBox;
    chk1 : TCheckBox;
    btn5: TBitBtn;
    procedure MyFileSelectClick(Sender : TObject);
    procedure btn1Click(Sender : TObject);
    procedure btn2Click(Sender : TObject);
    procedure btn3Click(Sender : TObject);
    procedure grd1SelectCell(Sender : TObject; ACol, ARow : Integer;
      var CanSelect : Boolean);
    procedure btn4Click(Sender : TObject);
    procedure btn5Click(Sender: TObject);
    procedure lbx1Click(Sender: TObject);
  private
    FPatcher : TPatcher;

    procedure DoPatcherProgress(
      ASender : TObject;
      const ACurrentPosition : LongWord;
      const AMaximumPosition : LongWord;
      var ACanContinue : LongBool);
    procedure DoPatcherComplete(
      ASender : TObject;
      const AStatusCode : LongWord;
      const AStatusMessage : string);
    procedure DoPatchFileBegin(
      ASender : TObject;
      APatchItem : TPatchItem;
      const APatchItemNumber : Integer;
      const APatchItemCount : Integer;
      var AContinueIfError : Boolean);

    procedure DoPatchFileEnd(
      ASender : TObject;
      APatchItem : TPatchItem;
      const APatchItemNumber : Integer;
      const APatchItemCount : Integer);

    procedure AddPatchItems(APatcher : TPatcher);
    procedure PopulateControls;
  public
    { Public declarations }
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  end;

var
  PatcherDemo : TPatcherDemo;

implementation

{$R *.dfm}

procedure TPatcherDemo.MyFileSelectClick(Sender : TObject);
var
  LD : TOpenDialog;
  LEdt : TEdit;
begin
  LD := TOpenDialog.Create(nil);
  try
    if TControl(Sender).Tag < 3 then
    begin
      LD.Filter := 'Executable file (*.exe)|*.exe|Any file (*.*)|*.*';
      LD.Title := 'Select an Executable file';
      LD.DefaultExt := 'exe';
    end
    else
    begin
      LD.Filter := 'Patch file (*.pth)|*.pth|Any file (*.*)|*.*';
      LD.Title := 'Select a Patch file';
      LD.DefaultExt := 'pth';
    end;
    if LD.Execute then
    begin
      LEdt := Self.FindComponent('edt' + IntToStr(TControl(Sender).Tag)) as TEdit;
      LEdt.Text := LD.FileName;
    end;
  finally
    FreeAndNil(LD);
  end;
end;

procedure TPatcherDemo.btn1Click(Sender : TObject);
  procedure GetCreatePatchOptionsAdditional;
  var
    LOption : TPatchCreateOption;
    LIdx : Integer;
  begin
    for LIdx := 0 to lbx1.Count - 1 do
    begin
      if lbx1.Checked[LIdx] then
      begin
        LOption := TPatchCreateOption(Ord(pcoUseLZX_Large) + (LIdx + 1));
        FPatcher.AddAdditionalCreatePatchFlag(LOption);
      end;
    end;
  end;

begin
  FPatcher.ResetPatchData(False);
  FPatcher.SetCompressionMode(TPatchCreateOptions_Compression(cbx1.ItemIndex));
  FPatcher.FileMode := PatcherHelper.StringToPatchFileMode(cbx2.Text);
  FPatcher.AlwaysRaiseExceptions := chk1.Checked;
  GetCreatePatchOptionsAdditional;
  AddPatchItems(FPatcher);
  FPatcher.CreatePatches;
end;

procedure TPatcherDemo.btn2Click(Sender : TObject);
  procedure GetApplyPatchOptions;
  var
    LOption : TPatchApplyOption;
    LIdx : Integer;
  begin
    for LIdx := 0 to lbx2.Count - 1 do
    begin
      if lbx2.Checked[LIdx] then
      begin
        LOption := TPatchApplyOption(LIdx);
        FPatcher.AddApplyPatchOptionFlag(LOption);
      end;
    end;
  end;

begin
  FPatcher.ResetPatchData(False);
  FPatcher.FileMode := psmUnicode;
  FPatcher.FileMode := PatcherHelper.StringToPatchFileMode(cbx2.Text);
  FPatcher.AlwaysRaiseExceptions := chk1.Checked;
  GetApplyPatchOptions;
  AddPatchItems(FPatcher);
  FPatcher.ApplyPatches;
end;

procedure TPatcherDemo.DoPatcherProgress(ASender : TObject;
  const ACurrentPosition : LongWord;
  const AMaximumPosition : LongWord;
  var ACanContinue : LongBool);
var
  LStr : string;
begin
  if AMaximumPosition <> ProgressBar1.Max then
    ProgressBar1.Max := AMaximumPosition;
  if ACurrentPosition <> ProgressBar1.Position then
    ProgressBar1.Position := ACurrentPosition;

  LStr := 'Complete: ' + FormatFloat('#,##0', ACurrentPosition) + ' of ' + FormatFloat('#,##0', AMaximumPosition);
  mmo1.Lines.Add(LStr);
  Application.ProcessMessages;
end;

procedure TPatcherDemo.AfterConstruction;
begin
  inherited AfterConstruction;

  PopulateControls;
  cbx1.ItemIndex := 0;
  grd1.DefaultColWidth := grd1.ClientWidth div 3;
  grd1.Cells[0, 0] := 'Old File Version';
  grd1.Cells[1, 0] := 'New File Version';
  grd1.Cells[2, 0] := 'Patch Filename';
  grd1.RowCount := 2;

  FPatcher := TPatcher.Create;
  FPatcher.OnPatchProgress := DoPatcherProgress;
  FPatcher.OnPatchesComplete := DoPatcherComplete;
  FPatcher.OnPatchFileBegin := DoPatchFileBegin;
  FPatcher.OnPatchFileEnd := DoPatchFileEnd;
end;

procedure TPatcherDemo.DoPatcherComplete(ASender : TObject;
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
  mmo1.Lines.Add(LMsg);
end;

procedure TPatcherDemo.AddPatchItems(APatcher : TPatcher);
var
  LIdx : Integer;
begin
  for LIdx := 1 to grd1.RowCount - 1 do
  begin
    if Length(Trim(grd1.Cells[0, LIdx])) <> 0 then
    begin
      APatcher.AddFileToPatch(
        grd1.Cells[0, LIdx],
        grd1.Cells[1, LIdx],
        grd1.Cells[2, LIdx]);
    end;
  end;
end;

procedure TPatcherDemo.btn3Click(Sender : TObject);
begin
  if not ((grd1.RowCount = 2) and (grd1.Cells[0, grd1.RowCount - 1] = '')) then
    grd1.RowCount := grd1.RowCount + 1;
  grd1.Cells[0, grd1.RowCount - 1] := edt1.Text;
  grd1.Cells[1, grd1.RowCount - 1] := edt2.Text;
  grd1.Cells[2, grd1.RowCount - 1] := edt3.Text;
end;

procedure TPatcherDemo.grd1SelectCell(Sender : TObject; ACol, ARow : Integer;
  var CanSelect : Boolean);
begin
  edt1.Text := grd1.Cells[0, ARow];
  edt2.Text := grd1.Cells[1, ARow];
  edt3.Text := grd1.Cells[2, ARow];
end;

procedure TPatcherDemo.btn4Click(Sender : TObject);
var
  LRow : Integer;
  LIdx : Integer;
begin
  if grd1.RowCount = 2 then
  begin
    grd1.Cells[0, 1] := '';
    grd1.Cells[1, 1] := '';
    grd1.Cells[2, 1] := '';
  end
  else
  begin
    LRow := grd1.Row;
    for LIdx := LRow to grd1.RowCount - 2 do
    begin
      grd1.Cells[0, Lidx] := grd1.Cells[0, Lidx + 1];
      grd1.Cells[1, Lidx] := grd1.Cells[1, Lidx + 1];
      grd1.Cells[2, Lidx] := grd1.Cells[2, Lidx + 1];
    end;
    grd1.RowCount := grd1.RowCount - 1;
  end;
end;

procedure TPatcherDemo.PopulateControls;
var
  LCreateFlags : TPatchCreateOption;
  LApplyFlags : TPatchApplyOption;
  LFileMode : TPatcherFileMode;
begin
  cbx2.Clear;
  for LFileMode := Low(TPatcherFileMode) to High(TPatcherFileMode) do
  begin
    cbx2.Items.Add(PatcherHelper.PatchFileModeToString(LFileMode));
  end;
  cbx2.ItemIndex := 0;
  cbx1.Clear;
  for LCreateFlags := Low(TPatchCreateOptions_Compression) to High(TPatchCreateOptions_Compression) do
  begin
    cbx1.Items.Add(PatcherHelper.PatchCreateFlagToString(LCreateFlags));
  end;
  cbx1.ItemIndex := 0;
  lbx1.Clear;
  for LCreateFlags := pcoNoBindFix to High(TPatchCreateOption) do
  begin
    lbx1.Items.Add(PatcherHelper.PatchCreateFlagToString(LCreateFlags));
  end;
  lbx2.Clear;
  for LApplyFlags := Low(TPatchApplyOption) to High(TPatchApplyOption) do
  begin
    lbx2.Items.Add(PatcherHelper.PatchApplyOptionFlagToString(LApplyFlags));
  end;
end;

procedure TPatcherDemo.DoPatchFileBegin(
  ASender : TObject;
  APatchItem : TPatchItem;
  const APatchItemNumber : Integer;
  const APatchItemCount : Integer;
  var AContinueIfError : Boolean);
begin
  mmo1.Lines.Add('Performing patch action on item [' + IntToStr(APatchItemNumber) + '] of [' + IntToStr(APatchItemCount) + ']');
  mmo1.Lines.Add('-------------------------------------------------------------------');
  mmo1.Lines.Add('Old File Version: [' + APatchItem.OldFileName + ']');
  mmo1.Lines.Add('New File Version: [' + APatchItem.NewFileName + ']');
  mmo1.Lines.Add('Patch Filename: [' + APatchItem.PatchFileName + ']');
  mmo1.Lines.Add('-------------------------------------------------------------------');
end;

procedure TPatcherDemo.DoPatchFileEnd(ASender : TObject; APatchItem : TPatchItem;
  const APatchItemNumber, APatchItemCount : Integer);
begin
  mmo1.Lines.Add('Finished patching [' + IntToStr(APatchItemNumber) + '] of [' + IntToStr(APatchItemCount) + ']');
end;

procedure TPatcherDemo.BeforeDestruction;
begin
  inherited BeforeDestruction;

  FreeAndNil(FPatcher);
end;

procedure TPatcherDemo.btn5Click(Sender: TObject);
begin
  grd1.Cells[0, grd1.Row] := edt1.Text;
  grd1.Cells[1, grd1.Row] := edt2.Text;
  grd1.Cells[2, grd1.Row] := edt3.Text;
end;

procedure TPatcherDemo.lbx1Click(Sender: TObject);
var
  LSelection : string;
  LDescription : string;
begin
  case TControl(Sender).Tag of
    1 :
    begin
      if Sender is TCheckListBox then
      begin
        LSelection := 'Create Patch Compression Flag ['+TCheckListBox(Sender).Items[TCheckListBox(Sender).ItemIndex]+']';
        LDescription := Descriptions_TPatchCreateOption[TPatchCreateOption(Ord(pcoUseLZX_Large) + (TCheckListBox(Sender).ItemIndex + 1))];
      end;
      if Sender is TComboBox then
      begin
        LSelection := 'Create Patch Optional Flag ['+TComboBox(Sender).Items[TComboBox(Sender).ItemIndex]+']';
        LDescription := Descriptions_TPatchCreateOption[TPatchCreateOption(TComboBox(Sender).ItemIndex)];
      end;
    end;
    2 :
    begin
      LSelection := 'Apply Patch Flag ['+TCheckListBox(Sender).Items[TCheckListBox(Sender).ItemIndex]+']';
      LDescription := Descriptions_TPatchApplyOption[TPatchApplyOption(TCheckListBox(Sender).ItemIndex)];
    end;
  end;
  mmo1.Lines.Add('-------------------------------------------------------------------');
  mmo1.Lines.Add('Option focused: '+LSelection);
  mmo1.Lines.Add('Description: '+LDescription);
  mmo1.Lines.Add('-------------------------------------------------------------------');
end;

end.

