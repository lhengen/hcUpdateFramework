unit fmDeployment;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles, cxCustomData,
  cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, ActnList, StdCtrls, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, ExtCtrls,
  hcDeployment, hcComponent, hcUIObjectBinding, hcErrorIndicator, ComCtrls,
  cxNavigator, System.Actions;

type
  TfrmDeployment = class(TForm)
    cbRegisteredApps: TComboBox;
    la1: TLabel;
    actlst1: TActionList;
    actAdd: TAction;
    actEdit: TAction;
    actRemove: TAction;
    meWhatsNew: TRichEdit;
    laWhatsNew: TLabel;
    ledUpdateVersion: TLabeledEdit;
    btOK: TButton;
    btCancel: TButton;
    btNew: TButton;
    btEdit: TButton;
    btDelete: TButton;
    laItems: TLabel;
    grdItems: TcxGrid;
    tvItems: TcxGridTableView;
    colFileName: TcxGridColumn;
    colVersion: TcxGridColumn;
    colTarget: TcxGridColumn;
    lvItems: TcxGridLevel;
    obDeployment: ThcUIObjectBinder;
    hcErrorIndicator1: ThcErrorIndicator;
    chkIsMandatory: TCheckBox;
    chkIsSilent: TCheckBox;
    chkIsImmediate: TCheckBox;
    procedure actEditExecute(Sender: TObject);
    procedure actRemoveExecute(Sender: TObject);
    procedure actRemoveUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actAddExecute(Sender: TObject);
    procedure btOKClick(Sender: TObject);
  private
    FDeployment :ThcDeployment;
    procedure SetDeployment(Value :ThcDeployment);
  public
    class function Execute(Deployment :ThcDeployment) :boolean;
    property Deployment :ThcDeployment read FDeployment write SetDeployment;
  end;

implementation

uses
  fmDeploymentItem
  ,dmADO
  ,hcMemoMediator
  ,hcLabeledEditMediator
  ,hcTypes
  ,hcDevExpressMediators, hcObserverIntf, ftUpdateConsts
  ,hcRichEditMediator
  ;

{$R *.dfm}



procedure TfrmDeployment.actAddExecute(Sender: TObject);
begin
  FDeployment.Items.Append;
  if TfrmDeploymentItem.Execute(FDeployment.Items.Current) then
  begin
    tvItems.DataController.CustomDataSource.DataChanged();
  end
  else
    FDeployment.Items.Delete;
end;

procedure TfrmDeployment.actEditExecute(Sender: TObject);
begin
  //TODO
end;

procedure TfrmDeployment.actRemoveExecute(Sender: TObject);
begin
  //TODO
end;

procedure TfrmDeployment.actRemoveUpdate(Sender: TObject);
begin
  //TODO
end;

procedure TfrmDeployment.btOKClick(Sender: TObject);
var
  sPatchFile,
  UpdateDirectory :string;
  I: Integer;
  aDeploymentItem :ThcDeploymentItem;
begin
  //save the new deployment info in the database
  FDeployment.ApplicationGUID.Value := TRegisteredApp(cbRegisteredApps.Items.Objects[cbRegisteredApps.ItemIndex]).GUID;
  FDeployment.Write(osRDBMS,True);

  //create a directory based on the new update version #
  UpdateDirectory := Format('%sUpdates\%s\',[IncludeTrailingPathDelimiter(dtmADO.UpdateServerPath),FDeployment.UpdateVersion.AsString]);
  ForceDirectories(UpdateDirectory);
  //save the manifest file
  FDeployment.SaveToManifest(UpdateDirectory);
  //copy all files to the Update Folder
  for I := 0 to FDeployment.Items.Count - 1 do
  begin
    aDeploymentItem := ThcDeploymentItem(FDeployment.Items[I]);
//    if aDeploymentItem.IsAZip.AsBoolean then
//    begin
//      sZIPFile := ChangeFileExt(aDeploymentItem.FileName.AsString,PatchFileExtension);
//      CopyFile(PWideChar(WideString(aDeploymentItem.SourcePath.AsString + sPatchFile)),PWideChar(WideString(UpdateDirectory + sPatchFile)),False);
//    end
//    else
    if aDeploymentItem.IsAPatch.AsBoolean then
    begin
      sPatchFile := ChangeFileExt(aDeploymentItem.FileName.AsString,PatchFileExtension);
      CopyFile(PWideChar(WideString(aDeploymentItem.SourcePath.AsString + sPatchFile)),PWideChar(WideString(UpdateDirectory + sPatchFile)),False);
    end
    else
      CopyFile(PWideChar(WideString(aDeploymentItem.SourcePath.AsString + aDeploymentItem.FileName.AsString)),PWideChar(WideString(UpdateDirectory + aDeploymentItem.FileName.AsString)),False);
  end;
end;

class function TfrmDeployment.Execute(Deployment :ThcDeployment): boolean;
var
  dlg: TfrmDeployment;
begin
  dlg := TfrmDeployment.Create(nil);
  try
    dlg.Position := poMainFormCenter;
    dlg.BorderStyle := bsDialog;
    dlg.Deployment := Deployment;
    Result := dlg.ShowModal = mrOK
  finally // wrap up
    dlg.Free;
  end;    // try/finally
end;

procedure TfrmDeployment.FormCreate(Sender: TObject);
begin
  dtmADO.LoadRegisteredApplications(cbRegisteredApps.Items);
  cbRegisteredApps.ItemIndex := 0; //default to first registered app
end;

procedure TfrmDeployment.SetDeployment(Value: ThcDeployment);
begin
  FDeployment := Value;
  obDeployment.BoundObject := FDeployment;
end;

end.
