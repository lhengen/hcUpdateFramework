unit fmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ActnList, Menus, ImgList,
  StdCtrls, ToolWin, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, cxGridLevel,
  cxClasses, cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ADODB, cxMemo, cxCheckBox, hcDeployment, cxBlobEdit, Vcl.ExtCtrls, Vcl.Buttons,
  cxNavigator, System.ImageList, System.Actions, dxDateRanges, dxScrollbarAnnotations;

type
  TfrmMain = class(TForm)
    mm1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    N3: TMenuItem;
    Help1: TMenuItem;
    Contents1: TMenuItem;
    SearchforHelpOn1: TMenuItem;
    HowtoUseHelp1: TMenuItem;
    About1: TMenuItem;
    CreateDeployment1: TMenuItem;
    mnuDeployments: TMenuItem;
    actlst1: TActionList;
    actExitApp: TAction;
    actCreateUpdate: TAction;
    actManageUpdate: TAction;
    Manage1: TMenuItem;
    tlbMain: TToolBar;
    cbUpdates: TComboBox;
    la1: TLabel;
    la2: TLabel;
    cbApps: TComboBox;
    tvGrid1DBTableView1: TcxGridDBTableView;
    lvGrid1Level1: TcxGridLevel;
    grd1: TcxGrid;
    statMain: TStatusBar;
    btnRefresh: TToolButton;
    btn2: TToolButton;
    il1: TImageList;
    qryLocationDeployment: TADOQuery;
    dsDeployments: TDataSource;
    colStudioNumber: TcxGridDBColumn;
    colIsAvailable: TcxGridDBColumn;
    colAvailableDate: TcxGridDBColumn;
    colLastAttempt: TcxGridDBColumn;
    colUpdateResult: TcxGridDBColumn;
    colUpdateLog: TcxGridDBColumn;
    actRefresh: TAction;
    colReceivedDate: TcxGridDBColumn;
    chkAutoRefresh: TCheckBox;
    tmrRefresh: TTimer;
    pmDeploymentItem: TPopupMenu;
    UnSelect1: TMenuItem;
    actlstDeploymentItem: TActionList;
    actUnSelect: TAction;
    qryWorker: TADOQuery;
    colStudioGUID: TcxGridDBColumn;
    btnRecall: TSpeedButton;
    btnNotes: TSpeedButton;
    mnuMarkAsSuccessful: TMenuItem;
    actMarkAsSuccessful: TAction;
    actMarkAsNotReceived: TAction;
    MarkAsNotReceived1: TMenuItem;
    actMarkAsAvailable: TAction;
    MarkAsAvailable1: TMenuItem;
    actMarkAsUnAvailable: TAction;
    MarkAsUnAvailable1: TMenuItem;
    procedure About1Click(Sender: TObject);
    procedure actExitAppExecute(Sender: TObject);
    procedure actCreateUpdateExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbAppsChange(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure actManageUpdateExecute(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure cbUpdatesChange(Sender: TObject);
    procedure actManageUpdateUpdate(Sender: TObject);
    procedure tmrRefreshTimer(Sender: TObject);
    procedure chkAutoRefreshClick(Sender: TObject);
    procedure actUnSelectUpdate(Sender: TObject);
    procedure actUnSelectExecute(Sender: TObject);
    procedure btnRecallClick(Sender: TObject);
    procedure btnNotesClick(Sender: TObject);
    procedure actMarkAsSuccessfulUpdate(Sender: TObject);
    procedure actMarkAsSuccessfulExecute(Sender: TObject);
    procedure actMarkAsNotReceivedExecute(Sender: TObject);
    procedure actMarkAsNotReceivedUpdate(Sender: TObject);
    procedure tvGrid1DBTableView1TcxGridDBDataControllerTcxDataSummaryFooterSummaryItems0GetText(
      Sender: TcxDataSummaryItem; const AValue: Variant; AIsFooter: Boolean;
      var AText: string);
    procedure qryLocationDeploymentAfterOpen(DataSet: TDataSet);
    procedure actMarkAsAvailableExecute(Sender: TObject);
    procedure actMarkAsUnAvailableExecute(Sender: TObject);
  private
    FActiveDeployments :ThcActiveDeploymentList;
    procedure LoadUpdatesForApplication;
    procedure ShowCurrentStatusForUpdate;
    function SelectedUpdate :ThcDeployment;
    procedure LoadUpdateVersionCombo;
  public
  end;

var
  frmMain: TfrmMain;

implementation

uses
  dmADO, hcQueryIntf, hcCodesiteHelper, fmAbout, fmDeployment,
  hcTypes, fmSelectStudios, hcUpdateConsts, hcObjectList, System.IOUtils,
  System.UITypes, fmEditNotes, Xml.XMLDoc, Xml.XMLIntf;

{$R *.dfm}

procedure TfrmMain.About1Click(Sender: TObject);
begin
  TfrmAbout.Execute;
end;

procedure TfrmMain.actCreateUpdateExecute(Sender: TObject);
var
  NewDeployment :ThcDeployment;
  VersionRec :TVersionRec;
begin
  NewDeployment := ThcDeployment.Create(nil);
  NewDeployment.FactoryPool := dtmADO.hcFactoryPool;
  NewDeployment.Initialize;
  //default the new version to be 1 higher than the highest Version
  if FActiveDeployments.Count > 0 then
  begin
    VersionRec := ParseVersionInfo(ThcDeployment(FActiveDeployments.Items[0]).UpdateVersion.AsString);
    VersionRec.Build := VersionRec.Build + 1;
    with VersionRec do
      NewDeployment.UpdateVersion.AsString := Format('%d.%d.%d.%d',[Major,Minor,Release,Build]);
  end;

  if TfrmDeployment.Execute(NewDeployment) then
  begin
    //add the deployment to our list and make it the current one.
    FActiveDeployments.AddExternalObject(NewDeployment);
    FActiveDeployments.SortByVersion(stDescending);
    LoadUpdateVersionCombo;
    cbUpdates.ItemIndex := cbUpdates.Items.IndexOfObject(NewDeployment);
    ShowCurrentStatusForUpdate;
  end
  else
    NewDeployment.Release;
end;

procedure TfrmMain.actExitAppExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.actManageUpdateExecute(Sender: TObject);
begin
  if (SelectedUpdate <> nil) and TfrmSelectStudios.Execute(SelectedUpdate) then
    actRefresh.Execute;
end;

procedure TfrmMain.actManageUpdateUpdate(Sender: TObject);
begin
  actManageUpdate.Enabled := SelectedUpdate <> nil;
end;
procedure TfrmMain.actMarkAsUnAvailableExecute(Sender: TObject);
begin
  with qryWorker do
  begin
    SQL.Text := Format('update LocationDeployment set AvailableUTCDate = NULL, IsAvailable = 0 where LocationGUID = ''%s'' and DeploymentGUID = ''%s'' ',[qryLocationDeployment.FieldByName('LocationGUID').AsString,qryLocationDeployment.FieldByName('DeploymentGUID').AsString]);
    ExecSQL;
    btnRefresh.Click;
  end;
end;

procedure TfrmMain.actMarkAsAvailableExecute(Sender: TObject);
begin
  with qryWorker do
  begin
    SQL.Text := Format('update LocationDeployment set AvailableUTCDate = getdate(), IsAvailable = 1 where LocationGUID = ''%s'' and DeploymentGUID = ''%s'' ',[qryLocationDeployment.FieldByName('LocationGUID').AsString,qryLocationDeployment.FieldByName('DeploymentGUID').AsString]);
    ExecSQL;
    btnRefresh.Click;
  end;
end;

procedure TfrmMain.actMarkAsNotReceivedExecute(Sender: TObject);
begin
  with qryWorker do
  begin
    SQL.Text := Format('update LocationDeployment set ReceivedUTCDate = null where LocationGUID = ''%s'' and DeploymentGUID = ''%s'' ',[qryLocationDeployment.FieldByName('LocationGUID').AsString,qryLocationDeployment.FieldByName('DeploymentGUID').AsString]);
    ExecSQL;
    btnRefresh.Click;
  end;
end;

procedure TfrmMain.actMarkAsNotReceivedUpdate(Sender: TObject);
begin
  //only allow the user to reset the received date if there has been no attempt to apply the update which will only happen if the update was not actually received or if the Launcher was not run
  //this should only be used if the update was not actually received by the client
  actManageUpdate.Enabled := not(qryLocationDeployment.FieldByName('ReceivedUTCDate').IsNull) and (qryLocationDeployment.FieldByName('LastAttemptUTCDate').IsNull);
end;

procedure TfrmMain.actMarkAsSuccessfulExecute(Sender: TObject);
begin
  with qryWorker do
  begin
    SQL.Text := Format('update StudioDeployment set LastAttemptUTCDate = getdate(), UpdateResult = ''Success'', UpdateLog = ''Manually Updated''  where StudioGUID = (Select StudioGUID from Studio where StudioNumber = %d) and DeploymentGUID = ''%s'' ',[qryLocationDeployment.FieldByName('StudioNumber').AsInteger,qryLocationDeployment.FieldByName('DeploymentGUID').AsString]);
    ExecSQL;
    btnRefresh.Click;
  end;
end;

procedure TfrmMain.actMarkAsSuccessfulUpdate(Sender: TObject);
begin
  //if the studio received the update we can mark it as applied successfully (in case an error occurred and it was manually updated)
  if (qryLocationDeployment.FieldByName('IsAvailable').AsBoolean) and not(qryLocationDeployment.FieldByName('ReceivedUTCDate').IsNull) then
  begin
    {$ifdef FABUTAN}
    actMarkAsSuccessful.Caption := Format('Mark Update as Applied to Studio %d',[qryLocationDeployment.FieldByName('StudioNumber').AsInteger]);
    {$else}
    actMarkAsSuccessful.Caption := Format('Mark Update as Applied to Location: %s',[qryLocationDeployment.FieldByName('Location').AsString]);
    {$endif}
    actMarkAsSuccessful.Enabled := True;
  end
  else
  begin
    actMarkAsSuccessful.Caption := 'Mark Update as Applied';
    actMarkAsSuccessful.Enabled := False;
  end;
end;

procedure TfrmMain.actRefreshExecute(Sender: TObject);
begin
  ShowCurrentStatusForUpdate;
end;

procedure TfrmMain.actUnSelectExecute(Sender: TObject);
begin
  with qryWorker do
  begin
    SQL.Text := Format('update StudioDeployment set IsAvailable = 0, AvailableUTCDate = null where StudioGUID = (Select StudioGUID from Studio where StudioNumber = %d) and DeploymentGUID = ''%s'' ',[qryLocationDeployment.FieldByName('StudioNumber').AsInteger,qryLocationDeployment.FieldByName('DeploymentGUID').AsString]);
    ExecSQL;
    btnRefresh.Click;
  end;
end;

procedure TfrmMain.actUnSelectUpdate(Sender: TObject);
begin
  actUnSelect.Enabled := (tvGrid1DBTableView1.Controller.SelectedRecordCount = 1) and (tvGrid1DBTableView1.Controller.SelectedRecords[0].Values[colReceivedDate.Index] = Null) and (tvGrid1DBTableView1.Controller.SelectedRecords[0].Values[colIsAvailable.Index] = True)
end;

procedure TfrmMain.btnNotesClick(Sender: TObject);
//display the change notes associated with this release
var
  dlg :TfrmEditNotes;
  XMLDoc :IXMLDocument;
  iRootNode :IXMLNode;
  sFilePath :string;
begin
  dlg := TfrmEditNotes.Create(Self);
  try
    dlg.Notes := SelectedUpdate.WhatsNew.AsString;
    dlg.Caption := Format('Notes for %s', [SelectedUpdate.UpdateVersion.AsString]);
    if dlg.ShowModal = mrOK then
    begin
      SelectedUpdate.WhatsNew.AsString := dlg.Notes;
      SelectedUpdate.WhatsNew.Write(osRDBMS,False);

      //see if we need to update the manifest
      if dlg.chkUpdateManifest.Checked then
      begin
        sFilePath := IncludeTrailingPathDelimiter(dtmADO.UpdateServerPath) + SelectedUpdate.UpdateVersion.AsString + '\';
        //slProgress.Add('Loading and Processing Existing Manifest');
        XMLDoc := TXMLDocument.Create(nil);
        try
          XMLDoc.LoadFromFile(sFilePath + ManifestFileName);
          XMLDoc.Active := True;

          iRootNode := XMLDoc.ChildNodes.First;
          iRootNode.Attributes['WhatsNew'] := SelectedUpdate.WhatsNew.AsString;
          XMLDoc.SaveToFile(sFilePath + ManifestFileName);
        finally
          XMLDoc := nil;
        end;

      end;
    end;
  finally
    dlg.Free;
  end;
end;

procedure TfrmMain.btnRecallClick(Sender: TObject);
{
  Recall the update from all studios that have received it.  Takes advantage of
  the shares available for each studio to delete the update folder (ie 3.2.1.4)
  from the Updates\Pending folder.
}
var
  sUpdateFolder :string;
  SaveCursor :TCursor;
begin
  if MessageDlg('This will recall the update from all studios who have not yet applied it.  The update will be removed from their hard drive and marked in the database as not available and not received.  Are you sure you want to recall it?',mtConfirmation,mbYesNo,0) = mrYes  then
  begin
    //make sure AutoRefresh is off
    if chkAutoRefresh.Checked then
      chkAutoRefreshClick(chkAutoRefresh);

    SaveCursor := Screen.Cursor;
    Screen.Cursor := crHourGlass;
    try
      with qryLocationDeployment do
      begin
        First;
        while not EOF do
        begin
          sUpdateFolder := Format('\\studio%d\Studsoft\studio\Updates\Pending\%s',[FieldByName('StudioNumber').AsInteger,ThcDeployment(cbUpdates.Items.Objects[cbUpdates.ItemIndex]).UpdateVersion.AsString]);
          if TDirectory.Exists(sUpdateFolder) then
          begin
            TDirectory.Delete(sUpdateFolder,True);
            //mark the update as recalled (never received and not available)
            qryWorker.SQL.Text := Format('update LocationDeployment set ReceivedUTCDate = null, AvailableUTCDate = null, IsAvailable = 0  where StudioGUID = (Select StudioGUID from Studio where StudioNumber = %d) and DeploymentGUID = ''%s'' ',[FieldByName('StudioNumber').AsInteger,FieldByName('DeploymentGUID').AsString]);
            qryWorker.ExecSQL;
          end;
          Application.ProcessMessages;
          Next;
        end;
      end;
    finally
      Screen.Cursor := saveCursor;
    end;
  end;
end;

procedure TfrmMain.cbAppsChange(Sender: TObject);
begin
  LoadUpdatesForApplication;
end;

procedure TfrmMain.cbUpdatesChange(Sender: TObject);
begin
  ShowCurrentStatusForUpdate;
end;

procedure TfrmMain.chkAutoRefreshClick(Sender: TObject);
begin
  tmrRefresh.Enabled := chkAutoRefresh.Checked;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  {$ifdef FABUTAN}
    actUnSelect.Visible := True;
    actMarkAsSuccessful.Visible := True;
    actMarkAsNotReceived.Visible := True;
    actManageUpdate.Visible := True;
    colStudioNumber.Caption := 'Studio';
    TcxGridDBColumn(colStudioNumber).DataBinding.FieldName := 'StudioNumber';
    Caption := 'Manage Studio Updates';
    qryLocationDeployment.SQL.Text :=
    'SELECT '+
    's.StudioNumber '+
    ',s.StudioGUID '+
    ',DeploymentGUID '+
    ',IsAvailable '+
    ',dateadd(hour, datediff(hour, getutcdate(), getdate()),ReceivedUTCDate) as ReceivedUTCDate '+
    ',dateadd(hour, datediff(hour, getutcdate(), getdate()),UpdatedUTCDate) as UpdatedUTCDate '+
    ',dateadd(hour, datediff(hour, getutcdate(), getdate()),LastAttemptUTCDate) as LastAttemptUTCDate '+
    ',UpdateResult '+
    ',UpdateLog '+
    ',dateadd(hour, datediff(hour, getutcdate(), getdate()),AvailableUTCDate) as AvailableUTCDate '+
    'FROM LocationDeployment sd '+
    'inner join studio s on s.StudioGUID = sd.StudioGUID '+
    'where DeploymentGUID = :DeploymentGUID '+
    'and s.IsActive = 1 '+
    'order by StudioNumber asc ';
    //the ability to recall a release requires a Fabutan specific share on a Virtual Private Network
    btnRecall.Visible := True;
    //the ability to update the notes for a release manifest requires access to the Update server's folder
    btnNotes.Visible := True;
    chkAutoRefresh.Visible := False;
  {$ELSE}
    actUnSelect.Visible := False;
    actMarkAsSuccessful.Visible := False;
//    actMarkAsNotReceived.Visible := False;
    actManageUpdate.Visible := False;
    chkAutoRefresh.Visible := False;
    //the ability to recall a release requires a Fabutan specific share on a Virtual Private Network
    btnRecall.Visible := False;
    //the ability to update the notes for a release manifest requires access to the Update server's folder
    btnNotes.Visible := False;
    colStudioNumber.Caption := 'Location';
    TcxGridDBColumn(colStudioNumber).DataBinding.FieldName := 'Location';
    Caption := 'Manage Location Updates';
    qryLocationDeployment.SQL.Text :=
    'SELECT '+
    'l.Description as Location '+
    ',l.LocationGUID '+
    ',DeploymentGUID '+
    ',IsAvailable '+
    ',dateadd(hour, datediff(hour, getutcdate(), getdate()),ReceivedUTCDate) as ReceivedUTCDate '+
    ',dateadd(hour, datediff(hour, getutcdate(), getdate()),UpdatedUTCDate) as UpdatedUTCDate '+
    ',dateadd(hour, datediff(hour, getutcdate(), getdate()),LastAttemptUTCDate) as LastAttemptUTCDate '+
    ',UpdateResult '+
    ',UpdateLog '+
    ',dateadd(hour, datediff(hour, getutcdate(), getdate()),AvailableUTCDate) as AvailableUTCDate '+
    'FROM LocationDeployment ld '+
    'inner join Location L on l.LocationGUID = ld.LocationGUID '+
    'where DeploymentGUID = :DeploymentGUID '+
   // 'and l.IsActive = 1 '+
    'order by Location asc ';
  {$ENDIF}

  dtmADO.LoadRegisteredApplications(cbApps.Items);
  cbApps.ItemIndex := 0; //we're guaranteed to have at least 1 app
  LoadUpdatesForApplication;
  ShowCurrentStatusForUpdate;
  statMain.Panels[0].Text := dtmADO.DataSource;

  chkAutoRefresh.Checked := False;
//  chkAutoRefresh.Checked := True;
//  chkAutoRefreshClick(Self);  //start autorefresh
end;

function TfrmMain.SelectedUpdate: ThcDeployment;
begin
  if cbUpdates.ItemIndex <> -1 then
    Result := ThcDeployment(cbUpdates.Items.Objects[cbUpdates.ItemIndex])
  else
    Result := nil;
end;

procedure TfrmMain.ShowCurrentStatusForUpdate;
begin
  if (SelectedUpdate <> nil) then
  begin
    qryLocationDeployment.Close;
    qryLocationDeployment.Parameters.ParamByName('DeploymentGUID').Value :=  SelectedUpdate.DeploymentGUID.AsString;
    qryLocationDeployment.Open;
  end;
end;

procedure TfrmMain.tmrRefreshTimer(Sender: TObject);
begin
  btnRefresh.Click;
end;

procedure TfrmMain.tvGrid1DBTableView1TcxGridDBDataControllerTcxDataSummaryFooterSummaryItems0GetText(
  Sender: TcxDataSummaryItem; const AValue: Variant; AIsFooter: Boolean;
  var AText: string);
begin
  AText := Format('Total: %s',[AText]);
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  //simulate alClient alignment for grid (align to client doesn't work)
  grd1.Top := tlbMain.Height;
  grd1.Height := ClientHeight - statMain.Height -  tlbMain.Height;
  grd1.Width := ClientWidth;
end;

procedure TfrmMain.LoadUpdateVersionCombo;
var
  I: Integer;
begin
  cbUpdates.Items.Clear;
  for I := 0 to FActiveDeployments.Count - 1 do
    cbUpdates.Items.AddObject(ThcDeployment(FActiveDeployments[I]).UpdateVersion.AsString,ThcDeployment(FActiveDeployments[I]));
  if cbUpdates.Items.Count > 0 then
    cbUpdates.ItemIndex := 0
  else
    cbUpdates.Text := '<None>';
end;

procedure TfrmMain.qryLocationDeploymentAfterOpen(DataSet: TDataSet);
begin
  {$ifdef FABUTAN}
  statMain.Panels[1].Text := Format('Total # of Studios: %d       ',[qryLocationDeployment.RecordCount]);
  {$ELSE}
  statMain.Panels[1].Text := Format('Total # of Locations: %d       ',[qryLocationDeployment.RecordCount]);
  {$ENDIF}
end;

procedure TfrmMain.LoadUpdatesForApplication;
{
  Loads updates for currently selected application, excluding any updates that are marked as
  complete in order of the most recent Update Version first, which is the default.
}
begin
  FActiveDeployments := ThcActiveDeploymentList.Create;
  FActiveDeployments.FactoryPool := dtmADO.hcFactoryPool;
//  if cbApps.ItemIndex = -1 then
//  begin
//    ShowMessage('No Applications are Registered');
//    Halt(0);
//  end;
  FActiveDeployments.ApplicationGUID := TRegisteredApp(cbApps.Items.Objects[cbApps.ItemIndex]).GUID;
  FActiveDeployments.Load;
  FActiveDeployments.SortByVersion(stDescending);
  LoadUpdateVersionCombo;
end;

end.
