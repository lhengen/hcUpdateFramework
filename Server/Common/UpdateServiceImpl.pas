{ Invokable implementation File for ApplicationUpdateService which implements IUpdateService }

unit UpdateServiceImpl;

interface

uses Soap.InvokeRegistry, System.Types, Soap.XSBuiltIns, UpdateServiceIntf, dmADO;

type
  ApplicationUpdateService = class(TInvokableClass, IUpdateService)
  private
    FDataModule :TdtmADO;
    function GetUpdate(const ApplicationGUID, LocationGUID, Manifest: string): ApplicationUpdateResult; stdcall;
    procedure UpdateReceived(const ApplicationGUID, LocationGUID, UpdateVersion: string); stdcall;
    procedure UpdateApplied(const ApplicationGUID, LocationGUID, UpdateVersion, UpdateResult, UpdateLog: string); stdcall;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  end;

implementation

uses
  System.SysUtils, Vcl.Forms, Xml.XMLDoc, Xml.XMLIntf, unWebServiceFileUtils,
  unPath, hcUpdateConsts, WinAPI.ActiveX;

procedure ApplicationUpdateService.AfterConstruction;
begin
  inherited;
  CoInitialize(nil);
  FDataModule := TdtmADO.Create(nil);
end;

procedure ApplicationUpdateService.BeforeDestruction;
begin
  FDataModule.Free;
  CoUninitialize;
  inherited;
end;

function ApplicationUpdateService.GetUpdate(const ApplicationGUID, LocationGUID, Manifest: string): ApplicationUpdateResult; stdcall;
const
  //if multiple updates are available when the request is made send the first available one
  CheckForUpdateSQL :string =
  'SELECT top 1 d.UpdateVersion, d.WhatsNew, IsAvailable,AvailableUTCDate,UpdatedUTCDate,LastAttemptUTCDate, '+
  'UpdateResult,UpdateLog, l.Description as LocationName, IsMandatory, IsSilent, IsImmediate '+
  'FROM LocationDeployment ld ' +
  'inner join Deployment d on d.DeploymentGUID = ld.DeploymentGUID ' +
  'inner join Location l on l.LocationGUID = ld.LocationGUID '+
  'where ld.LocationGUID = ''%s'' and d.ApplicationGUID = ''%s'' and ReceivedUTCDate IS NULL and IsAvailable = 1 and getutcdate() > AvailableUTCDate '+
  'order by AvailableUTCDate ASC ';
var
  i :Integer;
  TempArray :ArrayOfApplicationManifestEntry;
  UpdateDirectory :string;
  XMLDoc : IXMLDocument;
  iRootNode,
  iNode : IXMLNode;
  sPatchFileName :string;
begin
  Result := ApplicationUpdateResult.Create;
  FDataModule.cnDeployment.Connected := True;
  try
    with FDataModule.qryWorker do
    begin
      SQL.Text := format(CheckForUpdateSQL,[LocationGUID,ApplicationGUID]);
      Open;
      try
        if EOF then
        begin
          Result.UpdateIsAvailable := False;
          Result.LocationGUID := LocationGUID;
          Result.ApplicationGUID := ApplicationGUID;

          Result.NewManifest := ApplicationManifest.Create;
          Result.NewManifest.WhatsNew := '';
          Result.NewManifest.UpdateVersion := '';

          //add manifest entries
          System.SetLength(TempArray, 0);
          Result.NewManifest.Items := TempArray;
        end
        else
        begin
          Result.UpdateIsAvailable := FieldByName('IsAvailable').AsBoolean;
          Result.LocationGUID := LocationGUID;
          Result.ApplicationGUID := ApplicationGUID;

          Result.NewManifest := ApplicationManifest.Create;
          Result.NewManifest.WhatsNew := FieldByName('WhatsNew').AsString;
          Result.NewManifest.UpdateVersion := FieldByName('UpdateVersion').AsString;

          Result.NewManifest.IsMandatory := FieldByName('IsMandatory').AsBoolean;
          Result.NewManifest.IsSilent := FieldByName('IsSilent').AsBoolean;
          Result.NewManifest.IsImmediate := FieldByName('IsImmediate').AsBoolean;

          {$ifdef FABUTAN}
          Result.NewManifest.SyncProgrammability := FieldByName('SyncProgrammability').AsBoolean;
          Result.NewManifest.SyncData := FieldByName('SyncData').AsBoolean;
          {$endif}

          //add manifest entries
          //get the manifest from the file system based on the UpdateVersion
          UpdateDirectory := Format('%sUpdates\%s\',[ExtractFilePath(AppFileName),FieldByName('UpdateVersion').AsString]);
          if not DirectoryExists(UpdateDirectory) then
            raise Exception.CreateFmt('Update folder ''%s'' does not exist!',[UpdateDirectory]);

          //load the new manifest and binary components from disk
          XMLDoc := TXMLDocument.Create(nil);
          try
            XMLDoc.LoadFromFile(UpdateDirectory+ ManifestFileName);
            XMLDoc.Active := True;

            //the manifest is considered the source of truth for WhatsNew and the Version
            iRootNode := XMLDoc.ChildNodes.First;
            Result.NewManifest.UpdateVersion := iRootNode.Attributes['UpdateVersion'];
            Result.NewManifest.WhatsNew := iRootNode.Attributes['WhatsNew'];

            //determine how many files are included in the manifest and allocate the array
            System.SetLength(TempArray, iRootNode.ChildNodes.Count);
            for I := Low(TempArray) to High(TempArray) do
            begin
              iNode := iRootNode.ChildNodes[I];
              TempArray[I] := ApplicationManifestEntry.Create;
              TempArray[I].IsAPatch := iNode.Attributes['IsAPatch'];
              TempArray[I].IsAZip := iNode.Attributes['IsAZip'];
              TempArray[I].FileName := iNode.Attributes['FileName'];
              TempArray[I].Version := iNode.Attributes['Version'];
              TempArray[I].TargetPath := iNode.Attributes['TargetPath'];
              TempArray[I].Launch := iNode.Attributes['Launch'];
              if iNode.Attributes['IsAPatch'] then
              begin
                sPatchFileName := ChangeFileExt(TempArray[I].FileName,PatchFileExtension);
                TempArray[I].FileData := FileToByteArray(UpdateDirectory + sPatchFileName);
              end
              else
                TempArray[I].FileData := FileToByteArray(UpdateDirectory + TempArray[I].FileName);
            end;
          finally
            XMLDoc := nil;
          end;
          Result.NewManifest.Items := TempArray;
          TempArray := nil;
        end;
      finally
        Close;
      end;
    end;
  finally
    FDataModule.cnDeployment.Connected := False;
  end;
end;

procedure ApplicationUpdateService.UpdateApplied(const ApplicationGUID, LocationGUID, UpdateVersion, UpdateResult, UpdateLog: string);
const
  UpdateAppliedSQL :string =
    'update LocationDeployment set UpdatedUTCDate = GETUTCDATE(), LastAttemptUTCDate = GETUTCDATE(), UpdateResult = ''%s'', UpdateLog = ''%s'' '+
    'where LocationGUID = ''%s'' and DeploymentGUID = (select DeploymentGUID from Deployment where '+
    ' ApplicationGUID = ''%s'' and Status = ''Active'' and [UpdateVersion] = ''%s'')';
begin
  FDataModule.cnDeployment.Connected := True;
  try
    with FDataModule.qryWorker do
    begin
      SQL.Text := format(UpdateAppliedSQL,[UpdateResult,UpdateLog,LocationGUID,ApplicationGUID,UpDateVersion]);
      ExecSQL;
    end;
  finally
    FDataModule.cnDeployment.Connected := False;
  end;
end;

procedure ApplicationUpdateService.UpdateReceived(const ApplicationGUID, LocationGUID, UpdateVersion: string);
const
  UpdateAppliedSQL :string =
    'update LocationDeployment set ReceivedUTCDate = GETUTCDATE() '+
    'where LocationGUID = ''%s'' and DeploymentGUID = (select DeploymentGUID from Deployment where '+
    ' ApplicationGUID = ''%s'' and Status = ''Active'' and [UpdateVersion] = ''%s'')';
begin
  FDataModule.cnDeployment.Connected := True;
  try
    with FDataModule.qryWorker do
    begin
      SQL.Text := format(UpdateAppliedSQL,[LocationGUID,ApplicationGUID,UpdateVersion]);
      ExecSQL;
    end;
  finally
    FDataModule.cnDeployment.Connected := False;
  end;
end;

initialization
{ Invokable classes must be registered }
   InvRegistry.RegisterInvokableClass(ApplicationUpdateService);
end.

