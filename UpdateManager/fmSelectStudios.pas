unit fmSelectStudios;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, hcAttribute, hcDeploymentStudio, hcDeploymentRegion, ActnList, ComCtrls, Menus, ImgList,
  StdCtrls, hcDeployment, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxCalendar, Vcl.ExtCtrls, dxCore, cxDateUtils, dxSkinsCore,
  System.ImageList, System.Actions;

type
  TfrmSelectStudios = class(TForm)
    actlst1: TActionList;
    actSelectAllChildren: TAction;
    actSelect: TAction;
    actSelectAllSiblings: TAction;
    actUnSelectAllChildren: TAction;
    actUnSelect: TAction;
    actUnSelectAllSiblings: TAction;
    actExpand: TAction;
    actExpandAll: TAction;
    actCollapse: TAction;
    actCollapseAll: TAction;
    actSelectCorporates: TAction;
    actUnSelectCorporates: TAction;
    pmSelection: TPopupMenu;
    SelectCurrent1: TMenuItem;
    SelectCurrent2: TMenuItem;
    N1: TMenuItem;
    SelectCorporates1: TMenuItem;
    UnSelectCorporates1: TMenuItem;
    N2: TMenuItem;
    Expand1: TMenuItem;
    actExpandAll1: TMenuItem;
    Collapse1: TMenuItem;
    CollapseAll1: TMenuItem;
    tv1: TTreeView;
    ilStateImages: TImageList;
    laSelectionCount: TLabel;
    btOK: TButton;
    btCancel: TButton;
    actFindByNumber: TAction;
    N3: TMenuItem;
    FindByStudioNumber1: TMenuItem;
    grp1: TGroupBox;
    rbImmediately: TRadioButton;
    rbAsOf: TRadioButton;
    deAvailable: TcxDateEdit;
    procedure actSelectAllChildrenExecute(Sender: TObject);
    procedure actSelectExecute(Sender: TObject);
    procedure actSelectAllSiblingsExecute(Sender: TObject);
    procedure actUnSelectAllChildrenExecute(Sender: TObject);
    procedure actUnSelectExecute(Sender: TObject);
    procedure actUnSelectAllSiblingsExecute(Sender: TObject);
    procedure actExpandExecute(Sender: TObject);
    procedure actExpandAllExecute(Sender: TObject);
    procedure actCollapseExecute(Sender: TObject);
    procedure actCollapseAllExecute(Sender: TObject);
    procedure actSelectCorporatesExecute(Sender: TObject);
    procedure actUnSelectCorporatesExecute(Sender: TObject);
    procedure btOKClick(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure actFindByNumberExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FSelectionCount :Integer;
    FStudios :ThcDeploymentStudioList;
    FRegions :ThcDeploymentRegionList;
    FDeployment :ThcDeployment;
    procedure LoadHierarchy(const DeploymentGUID :string);
    procedure ToggleCorporates(Select: Boolean);
    procedure SelectionChange(Sender: TObject);
    procedure SetDeployment(Value :ThcDeployment);
  public
    class function Execute(Deployment: ThcDeployment): boolean; static;
    property Deployment :ThcDeployment read FDeployment write SetDeployment;
  end;


implementation

uses dmADO, hcTreeViewUtils, hcQueryIntf, hcUTCUtils;

{$R *.dfm}

class function TfrmSelectStudios.Execute(Deployment :ThcDeployment): boolean;
var
  dlg: TfrmSelectStudios;
begin
  dlg := TfrmSelectStudios.Create(nil);
  try
    dlg.Position := poMainFormCenter;
    dlg.BorderStyle := bsDialog;
    dlg.Deployment := Deployment;
    Result := dlg.ShowModal = mrOK
  finally // wrap up
    dlg.Free;
  end;    // try/finally
end;

procedure TfrmSelectStudios.FormCreate(Sender: TObject);
begin
  deAvailable.Date := Now;
  {$ifdef FABUTAN}
  Caption := 'Select Studios for Deployment';
  {$else}
  Caption := 'Select Locations for Deployment';
  {$endif}
end;

procedure TfrmSelectStudios.LoadHierarchy(const DeploymentGUID :string);
var
  TempNode,
  CurrentNode,
  RootNode :TTreeNode;
  I: Integer;
begin
  //root node
  {$ifdef FABUTAN}
  RootNode := tv1.Items.AddChildObject(nil,'Fabutan',nil);
  {$else}
  RootNode := tv1.Items.AddChildObject(nil,'Dynamic Risk',nil);
  {$endif}

  FRegions := ThcDeploymentRegionList.Create();
  FRegions.FactoryPool := dtmADO.hcFactoryPool;
  //regions are loaded in order by Region Description
  FRegions.Load;
  while not FRegions.EOL do
  begin
    tv1.Items.AddChildObject(RootNode,FRegions.Current.Description.AsString,FRegions.Current);
    FRegions.Next;
  end;

  //studios are loaded in order by Region # and then Name so we need to locate the region in the list an iterate over it
  FStudios := ThcDeploymentStudioList.Create();
  FStudios.FactoryPool := dtmADO.hcFactoryPool;
  FStudios.DeploymentGUID := DeploymentGUID;
  FStudios.Load;

  //hook in on attribute change to get updated count of selected studios
  for I := 0 to FStudios.Count - 1 do
    ThcDeploymentStudio(FStudios[I]).UserSelected.OnChange.AddEvent(SelectionChange);

  CurrentNode := RootNode.getFirstChild;
  while CurrentNode <> nil do
  begin
    //locate first studio by region #
//  removed since Region 13 doesn't have any studios
//    Assert(FStudios.LocateRegion(ThcDeploymentItemRegion(CurrentNode.Data).Number.AsInteger),'Unable to locate Region');
    if FStudios.LocateRegion(ThcDeploymentRegion(CurrentNode.Data).Number.AsInteger) then
      while (FStudios.Current.Region.AsInteger = ThcDeploymentRegion(CurrentNode.Data).Number.AsInteger) and not FStudios.EOL do
      begin
        TempNode := tv1.Items.AddChildObject(CurrentNode,Format('%d - %s - v.%s',[FStudios.Current.StudioNumber.AsInteger, FStudios.Current.StudioName.AsString, FStudios.Current.CurrentVersion.AsString]),FStudios.Current);
        ToggleNode(TempNode,FStudios.Current.UserSelected.AsBoolean);
        //if the studio is selected the SelectionChange handler will not adjust the count since the value doesn't get changed (True to True)
        if FStudios.Current.UserSelected.AsBoolean then
          Inc(FSelectionCount,1);

        FStudios.Next;
      end;
    CurrentNode := CurrentNode.getNextSibling;
  end;

end;

procedure TfrmSelectStudios.SelectionChange(Sender: TObject);
var
  anAttribute :ThcAttribute;
begin
  anAttribute := Sender as ThcAttribute;
  if anAttribute.AsBoolean then
    Inc(FSelectionCount,1)
  else
  begin
    if FSelectionCount > 0 then
      Dec(FSelectionCount,1);
  end;

  laSelectionCount.Caption := Format('%d Studios Selected',[FSelectionCount]);
end;

procedure TfrmSelectStudios.actExpandAllExecute(Sender: TObject);
begin
  if tv1.SelectionCount = 1 then
    tv1.Selected.Expand(True);
end;

procedure TfrmSelectStudios.actExpandExecute(Sender: TObject);
begin
  if tv1.SelectionCount = 1 then
    tv1.Selected.Expanded := True;
end;

procedure TfrmSelectStudios.actFindByNumberExecute(Sender: TObject);
var
  nInput :integer;
  sInput :string;
  I: Integer;
begin
  sInput := InputBox('Find Studio','Enter the Studio # to Find','0');
  if (Length(sInput) > 0) then
  begin
    try
      nInput := StrToInt(sInput);
      for I := 0 to tv1.Items.Count - 1 do
      begin
        if (tv1.Items[I].Level = 2) and (ThcDeploymentStudio(tv1.Items[I].Data).StudioNumber.AsInteger = nInput) then
        begin
          tv1.Select(tv1.Items[I]);
          break;
        end;
      end;
    except
      ;
    end;

  end;


end;

procedure TfrmSelectStudios.actSelectAllChildrenExecute(Sender: TObject);
var
  I: Integer;
begin
  if tv1.SelectionCount > 0 then
    for I := 0 to tv1.SelectionCount - 1 do
      ToggleNodeChildren(tv1.Selections[I],True);
end;

procedure TfrmSelectStudios.actSelectAllSiblingsExecute(Sender: TObject);
var
  I: Integer;
begin
  if tv1.SelectionCount > 0 then
    for I := 0 to tv1.SelectionCount - 1 do
      ToggleNodeSiblings(tv1.Selections[I],True);
end;

procedure TfrmSelectStudios.actSelectCorporatesExecute(Sender: TObject);
begin
  ToggleCorporates(True);
end;

procedure TfrmSelectStudios.ToggleCorporates(Select :Boolean);
var
  I :Integer;
begin
  for I := 0 to tv1.Items.Count - 1 do
  begin
    if (TObject(tv1.Items[I].Data) is ThcDeploymentStudio) and
      (ThcDeploymentStudio(tv1.Items[I].Data).IsCorporate.AsBoolean)
    then
    begin
      if Select then
      begin
        ThcDeploymentStudio(tv1.Items[I].Data).UserSelected.AsBoolean := True;
        tv1.Items[I].StateIndex := 1;
      end
      else
      begin
        ThcDeploymentStudio(tv1.Items[I].Data).UserSelected.AsBoolean := False;
        tv1.Items[I].StateIndex := 0;
      end;
     end;
  end;
end;

procedure TfrmSelectStudios.actSelectExecute(Sender: TObject);
var
  I: Integer;
begin
  if tv1.SelectionCount > 0 then
    for I := 0 to tv1.SelectionCount - 1 do
      ToggleNode(tv1.Selections[I],True);
end;

procedure TfrmSelectStudios.actUnSelectAllChildrenExecute(Sender: TObject);
var
  I: Integer;
begin
  if tv1.SelectionCount > 0 then
    for I := 0 to tv1.SelectionCount - 1 do
      ToggleNode(tv1.Selections[I],False);
end;

procedure TfrmSelectStudios.actUnSelectAllSiblingsExecute(Sender: TObject);
var
  I: Integer;
begin
  if tv1.SelectionCount > 0 then
    for I := 0 to tv1.SelectionCount - 1 do
      ToggleNodeSiblings(tv1.Selections[I],False);
end;

procedure TfrmSelectStudios.actUnSelectCorporatesExecute(Sender: TObject);
begin
  ToggleCorporates(False);
end;

procedure TfrmSelectStudios.actUnSelectExecute(Sender: TObject);
var
  I: Integer;
begin
  if tv1.SelectionCount > 0 then
    for I := 0 to tv1.SelectionCount - 1 do
      ToggleNode(tv1.Selections[I],False);
end;

procedure TfrmSelectStudios.btCancelClick(Sender: TObject);
begin
  //rollback any changes to deployment list
  if FStudios.Modified then
    FStudios.CancelUpdates;
end;

procedure TfrmSelectStudios.btOKClick(Sender: TObject);
begin
  //save deployment selection changes
  if FStudios.Modified then
  begin
    if rbImmediately.Checked then
      FStudios.SetAvailableUTCDate(GetUTC)
    else
      FStudios.SetAvailableUTCDate(MakeUTCTime(deAvailable.Date));

    FStudios.ApplyUpdates(True);
  end;
end;

procedure TfrmSelectStudios.actCollapseAllExecute(Sender: TObject);
begin
  if tv1.SelectionCount = 1 then
    tv1.Selected.Collapse(True);
end;

procedure TfrmSelectStudios.actCollapseExecute(Sender: TObject);
begin
  if tv1.SelectionCount = 1 then
    tv1.Selected.Collapse(False);
end;

procedure TfrmSelectStudios.SetDeployment(Value: ThcDeployment);
begin
  FDeployment := Value;
  //load selection value for all studios and whether the update has been applied
  FSelectionCount := 0;
  LoadHierarchy(FDeployment.DeploymentGUID.AsString);

  tv1.Items.GetFirstNode.Expanded := True;  //expand root node

  Caption := Format('Select Studios for Deployment of Update v%s',[FDeployment.UpdateVersion.AsString]);
  laSelectionCount.Caption := Format('%d Studios Selected',[FSelectionCount]);
end;

end.
