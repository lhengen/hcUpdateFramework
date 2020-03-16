{ Invokable implementation File for ApplicationUpdateService which implements IUpdateService }

unit UpdateServiceImpl;

interface

uses Soap.InvokeRegistry, System.Types, Soap.XSBuiltIns, UpdateServiceIntf
  {$ifdef Firebird}
  ,dmFireDAC
  {$else}
  ,dmADO
  {$endif}
  ;

type
  ApplicationUpdateService = class(TInvokableClass, IUpdateService)
  private
    {$ifdef Firebird}
    FDataModule :TdtmFireDAC;
    {$else}
    FDataModule :TdtmADO;
    {$endif}
    function GetUpdate(const ApplicationGUID, InstallationGUID, Manifest: string): ApplicationUpdateResult; stdcall;
    procedure UpdateReceived(const ApplicationGUID, InstallationGUID, UpdateVersion: string); stdcall;
    procedure UpdateApplied(const ApplicationGUID, InstallationGUID, UpdateVersion, UpdateResult, UpdateLog: string); stdcall;
    function RegisterInstall(const ApplicationGUID, DeviceGUID, DeviceFingerPrint: string) :string; stdcall;  //returns InstallationGUID
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
  {$ifdef Firebird}
  FDataModule := TdtmFireDAC.Create(nil);
  {$else}
  FDataModule := TdtmADO.Create(nil);
  {$endif}
end;

procedure ApplicationUpdateService.BeforeDestruction;
begin
  FDataModule.Free;
  CoUninitialize;
  inherited;
end;

function ApplicationUpdateService.GetUpdate(const ApplicationGUID, InstallationGUID, Manifest: string): ApplicationUpdateResult; stdcall;
const
  //if multiple updates are available when the request is made send the first available one
  CheckForUpdateSQL :string =
    'SELECT %0:s 1 '+
    'd.UpdateVersion, '+
    'd.WhatsNew, '+
    'IsAvailable, '+
    'AvailableUTCDate, '+
    'UpdatedUTCDate, '+
    'LastAttemptUTCDate, '+
    'UpdateResult, '+
    'UpdateLog, '+
    'IsMandatory, '+
    'IsSilent, '+
    'IsImmediate '+
    'FROM InstallationDeployment id '+
    'inner join Deployment d on d.DeploymentGUID = id.DeploymentGUID '+
    'inner join Installation l on l.InstallationGUID = id.InstallationGUID '+
    'where id.InstallationGUID = %1:s '+
    'and d.ApplicationGUID = %2:s '+
    'and ReceivedUTCDate IS NULL '+
    'and IsAvailable = %3:s '+
    'and %4:s > AvailableUTCDate '+
    'order by AvailableUTCDate ASC';

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
      {$ifdef Firebird}
      assert(Length(InstallationGUID) = 36,Format('InstallationGUID is invalid: %s',[InstallationGUID]));
      assert(Length(ApplicationGUID) = 36,Format('ApplicationGUID is invalid: %s',[ApplicationGUID]));
      SQL.Text := format(CheckForUpdateSQL,
      [
        'first'
        ,Format('CHAR_TO_UUID(''%s'')',[InstallationGUID])
        ,Format('CHAR_TO_UUID(''%s'')',[ApplicationGUID])
        ,'True'
        ,'CURRENT_TIMESTAMP'
      ]); //TODO - change to use utc
      {$else}
      SQL.Text := format(CheckForUpdateSQL,['top',AnsiQuotedStr(InstallationGUID,''''),AnsiQuotedStr(ApplicationGUID,''''),'1','getutcdate()']);
      {$endif}
      Open;
      try
        if EOF then
        begin
          Result.UpdateIsAvailable := False;
          Result.InstallationGUID := InstallationGUID;
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
          Result.InstallationGUID := InstallationGUID;
          Result.ApplicationGUID := ApplicationGUID;

          Result.NewManifest := ApplicationManifest.Create;
          Result.NewManifest.WhatsNew := FieldByName('WhatsNew').AsString;
          Result.NewManifest.UpdateVersion := FieldByName('UpdateVersion').AsString;

          Result.NewManifest.IsMandatory := FieldByName('IsMandatory').AsBoolean;
          Result.NewManifest.IsSilent := FieldByName('IsSilent').AsBoolean;
          Result.NewManifest.IsImmediate := FieldByName('IsImmediate').AsBoolean;

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
              begin
                if not FileExists(UpdateDirectory + TempArray[I].FileName) then
                  raise Exception.CreateFmt('File Not present on Update Server: %s%s',[UpdateDirectory,TempArray[I].FileName]);

                TempArray[I].FileData := FileToByteArray(UpdateDirectory + TempArray[I].FileName);
              end;
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

function ApplicationUpdateService.RegisterInstall(const ApplicationGUID, DeviceGUID, DeviceFingerPrint: string) :string; stdcall;  //returns InstallationGUID
const
  CreateInstallationSQL :string =
    'insert into Installation(InstallationGUID,ApplicationGUID, LocationGUID, DeviceGUID, DeviceFingerPrint) values (%s,%s,%s,%s,''%s'' )';
begin
  FDataModule.cnDeployment.Connected := True;
  try
    with FDataModule.qryWorker do
    begin
      {$ifdef Firebird}
      assert(Length(DeviceGUID) = 36,Format('DeviceGUID is invalid: %s',[DeviceGUID]));
      assert(Length(ApplicationGUID) = 36,Format('ApplicationGUID is invalid: %s',[ApplicationGUID]));
      SQL.Text := 'select UUID_TO_CHAR(gen_uuid()) from RDB$Database';
      Open;
      Result := Fields[0].AsString;
      Close;

      SQL.Text := format(CreateInstallationSQL,[
        Format('CHAR_TO_UUID(''%s'')',[Result]),
        Format('CHAR_TO_UUID(''%s'')',[ApplicationGUID]),
        //this is temporary to accomodate automatic registration for a specific company's inhouse software
        //normally we would get address or lat/long location information and use this to create a new Location then a new install at that location
        'CHAR_TO_UUID(''3380EB06-FFC6-4E7A-8D15-4B87FDC4AEEB'')',
        Format('CHAR_TO_UUID(''%s'')',[DeviceGUID]),
        DeviceFingerPrint
      ]); //todo - change to use UTC

      {$else}
// TODO - implement
//      SQL.Text := format(CreateLocationSQL,['getutcdate()',UpdateResult,UpdateLog,LocationGUID,ApplicationGUID,UpDateVersion]);

      {$endif}
      ExecSQL;
    end;
  finally
    FDataModule.cnDeployment.Connected := False;
  end;
end;

procedure ApplicationUpdateService.UpdateApplied(const ApplicationGUID, InstallationGUID, UpdateVersion, UpdateResult, UpdateLog: string);
const
  UpdateAppliedSQL :string =
    'update InstallationDeployment set UpdatedUTCDate = %0:s, LastAttemptUTCDate = %0:s, UpdateResult = ''%1:s'', UpdateLog = ''%2:s'' '+
    'where InstallationGUID = %3:s and DeploymentGUID = (select DeploymentGUID from Deployment where '+
    ' ApplicationGUID = %4:s and Status = ''Active'' and UpdateVersion = ''%5:s'')';
begin
  FDataModule.cnDeployment.Connected := True;
  try
    with FDataModule.qryWorker do
    begin
      {$ifdef Firebird}
      assert(Length(InstallationGUID) = 36,Format('InstallationGUID is invalid: %s',[InstallationGUID]));
      assert(Length(ApplicationGUID) = 36,Format('ApplicationGUID is invalid: %s',[ApplicationGUID]));
      SQL.Text := format(UpdateAppliedSQL,[
        'current_timestamp'
        ,UpdateResult
        ,UpdateLog
        ,Format('CHAR_TO_UUID(''%s'')',[InstallationGUID])
        ,Format('CHAR_TO_UUID(''%s'')',[ApplicationGUID])
        ,UpdateVersion
      ]); //todo - change to use utc
      {$else}
      SQL.Text := format(UpdateAppliedSQL,['getutcdate()',UpdateResult,UpdateLog,InstallationGUID,ApplicationGUID,UpDateVersion]);
      {$endif}
      ExecSQL;
    end;
  finally
    FDataModule.cnDeployment.Connected := False;
  end;
end;

procedure ApplicationUpdateService.UpdateReceived(const ApplicationGUID, InstallationGUID, UpdateVersion: string);
const
  UpdateAppliedSQL :string =
    'update InstallationDeployment set ReceivedUTCDate = %0:s '+
    'where InstallationGUID = %1:s and DeploymentGUID = (select DeploymentGUID from Deployment where '+
    ' ApplicationGUID = %2:s and Status = ''Active'' and UpdateVersion = ''%3:s'')';
begin
  FDataModule.cnDeployment.Connected := True;
  try
    with FDataModule.qryWorker do
    begin
      {$ifdef Firebird}
      assert(Length(InstallationGUID) = 36,Format('InstallationGUID is invalid: %s',[InstallationGUID]));
      assert(Length(ApplicationGUID) = 36,Format('ApplicationGUID is invalid: %s',[ApplicationGUID]));
      SQL.Text := format(UpdateAppliedSQL,['current_timestamp',Format('CHAR_TO_UUID(''%s'')',[InstallationGUID]),Format('CHAR_TO_UUID(''%s'')',[ApplicationGUID]),UpdateVersion]); //todo - change to use utc
      {$else}
      SQL.Text := format(UpdateAppliedSQL,['getutcdate()',InstallationGUID,ApplicationGUID,UpdateVersion]);
      {$endif}
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

