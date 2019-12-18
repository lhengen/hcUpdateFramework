unit unUpdateClient;

interface

uses
  Classes, ComObj, ActiveX;

type
  TUpdateClient = class(TComponent)
  private
//    FApplicationFileName,
    FApplicationGUID,
    FURI :string;
//    function GetLocationGUID: string;
  public
    function CheckForUpdates :string;
    property URI :string read FURI write FURI;
    property ApplicationGUID :string read FApplicationGUID write FApplicationGUID;
//    property ApplicationFileName :string read FApplicationFileName write FApplicationFileName;
  end;

implementation

uses
  unIUpdateService, XMLDoc, XMLIntf, unWebServiceFileUtils,
  hcUpdateConsts, ADODB, SysUtils, unPath, hcVersionInfo, System.DateUtils;


function TUpdateClient.CheckForUpdates :string;
{
  This method assumes the current application directory contains the Manifest file and that it
  contains the LocationGUID and ApplicationGUID.  Client side manifests have these additional
  root node attributes injected by the update server when requesting an update.
}
var
  UpdateService :IUpdateService;
  AppUpdateResult :ApplicationUpdateResult;
  I: Integer;
  LocationGUID,
  ApplicationGUID,
  AppDir,
  UpdateDirectory :string;
  XMLDoc : IXMLDocument;
  iRootNode,
  iNode : IXMLNode;
  StringStream :TStringStream;
  sPatchFileName :string;
  slProgress :TStringList;
  StartTime, EndTime :TDateTime;
  sError :string;
begin
  slProgress := TStringList.Create;
  StartTime := Now;
  slProgress.Add(Format('Update Log for a single request starting %s',[DateTimeToStr(StartTime)]));
  try
    try
      slProgress.Add('Initializing COM');
      CoInitialize(nil);
      try
        StringStream := TStringStream.Create;
        try
          AppDir := ExtractFilePath(AppFileName);

          //---need to get ApplicationGUID and LocationGUID from Manifest file if it exists, or build an initial one
          //if the manifest file does not exist (this is the initial deployment), then try to create it
          if not FileExists(AppDir + ManifestFileName) then
          begin
//            raise Exception.CreateFmt('There is no application Manifest file (%s%s)!',[AppDir,ManifestFileName]);
            slProgress.Add('Creating Default Manifest');
            //save the new manifest and binary components to disk
            XMLDoc := TXMLDocument.Create(nil);
            try
              XMLDoc.Active := True;
              iRootNode := XMLDoc.AddChild('Manifest');
              LocationGUID := '{1145FC6F-6046-49B7-9FE1-008140859052}'; //TODO - get GetLocationGUID
              iRootNode.Attributes['LocationGUID'] := LocationGUID;
              ApplicationGUID := FApplicationGUID;
              iRootNode.Attributes['ApplicationGUID'] := ApplicationGUID;
              iRootNode.Attributes['UpdateVersion'] := '0.0.0.0'; //fake version #
              iRootNode.Attributes['WhatsNew'] := 'Initial Manifest Created';
              iRootNode.Attributes['IsMandatory'] := False;
              iRootNode.Attributes['IsSilent'] := False;
              iRootNode.Attributes['IsImmediate'] := False;

              iNode := iRootNode.AddChild('Item');
              iNode.Attributes['FileName'] := 'Some.EXE';
              iNode.Attributes['Version'] := '0.0.0.0'; //ftVersionInfo.GetFileVersionText(AppDir + ApplicationFileName);
              iNode.Attributes['TargetPath'] := AppDir;
              XMLDoc.SaveToFile(AppDir + ManifestFileName);
            finally
              XMLDoc := nil;
            end;
          end
          else
          begin
            slProgress.Add('Loading and Processing Existing Manifest');
            XMLDoc := TXMLDocument.Create(nil);
            try
              XMLDoc.LoadFromFile(AppDir + ManifestFileName);
              XMLDoc.Active := True;

              iRootNode := XMLDoc.ChildNodes.First;
              LocationGUID := iRootNode.Attributes['LocationGUID'];
              ApplicationGUID := iRootNode.Attributes['ApplicationGUID'];
            finally
              XMLDoc := nil;
            end;
          end;

          slProgress.Add('Loading Manifest for GetUpdateRequest');
          StringStream.LoadFromFile(AppDir + ManifestFileName);
          slProgress.Add('Getting Reference to IUpdateService');
          UpdateService := GetIUpdateService(False, FURI);
          try
            slProgress.Add(Format('Calling IUpdateService.GetUpdate with ApplicationGUID: %s LocationGUID: %s',[ApplicationGUID,LocationGUID]));
            AppUpdateResult := UpdateService.GetUpdate(ApplicationGUID,LocationGUID,StringStream.DataString);
          except
            on E: Exception do   //server is likely not running
            begin   //translate the exception and re-raise (consumer must handle)
              Result := '';
              slProgress.Add('Call to IUpdateService.GetUpdate FAILED with Error:' + E.Message);
              raise;
            end;
          end;
          if AppUpdateResult.UpdateIsAvailable then
          begin
            slProgress.Add('An Update is available');
            //create a directory based on the new update version #
            UpdateDirectory := Format('%sUpdates\Pending\%s\',[AppDir,AppUpdateResult.NewManifest.UpdateVersion]);
            slProgress.Add('Forcing Directory :'+UpdateDirectory);
            ForceDirectories(UpdateDirectory);

            slProgress.Add('Saving Update Request result');
            //save the new manifest and binary components to disk
            XMLDoc := TXMLDocument.Create(nil);
            try
              XMLDoc.Active := True;
              iRootNode := XMLDoc.AddChild('Manifest');
              iRootNode.Attributes['LocationGUID'] := AppUpdateResult.LocationGUID;
              iRootNode.Attributes['ApplicationGUID'] := AppUpdateResult.ApplicationGUID;
              iRootNode.Attributes['UpdateVersion'] := AppUpdateResult.NewManifest.UpdateVersion;
              iRootNode.Attributes['WhatsNew'] := AppUpdateResult.NewManifest.WhatsNew;
              iRootNode.Attributes['IsMandatory'] := AppUpdateResult.NewManifest.IsMandatory;
              iRootNode.Attributes['IsSilent'] := AppUpdateResult.NewManifest.IsSilent;
              iRootNode.Attributes['IsImmediate'] := AppUpdateResult.NewManifest.IsImmediate;

              {$ifdef FABUTAN}
              iRootNode.Attributes['SyncProgrammability'] := AppUpdateResult.NewManifest.SyncProgrammability;
              iRootNode.Attributes['SyncData'] := AppUpdateResult.NewManifest.SyncData;
              {$endif}

              for I := Low(AppUpdateResult.NewManifest.Items) to High(AppUpdateResult.NewManifest.Items) do
              begin
                slProgress.Add(Format('Saving Manifest Item %d of %d (%s)',[I+1,High(AppUpdateResult.NewManifest.Items),AppUpdateResult.NewManifest.Items[I].FileName]));
                iNode := iRootNode.AddChild('Item');
                iNode.Attributes['FileName'] := AppUpdateResult.NewManifest.Items[I].FileName;
                iNode.Attributes['IsAPatch'] := AppUpdateResult.NewManifest.Items[I].IsAPatch;
                iNode.Attributes['IsAZip'] := AppUpdateResult.NewManifest.Items[I].IsAZip;
                iNode.Attributes['Launch'] := AppUpdateResult.NewManifest.Items[I].Launch;
                iNode.Attributes['Version'] := AppUpdateResult.NewManifest.Items[I].Version;
                iNode.Attributes['TargetPath'] := AppUpdateResult.NewManifest.Items[I].TargetPath;
                if iNode.Attributes['IsAPatch'] then
                begin
                  sPatchFileName := ChangeFileExt(AppUpdateResult.NewManifest.Items[I].FileName,PatchFileExtension);
                  slProgress.Add(Format('Processing Patch File: %s',[sPatchFileName]));
                  ByteArrayToFile(AppUpdateResult.NewManifest.Items[I].FileData,UpdateDirectory + '\'+ sPatchFileName);
                end
                else
                begin
                  slProgress.Add(Format('Saving File: %s',[AppUpdateResult.NewManifest.Items[I].FileName]));
                  ByteArrayToFile(AppUpdateResult.NewManifest.Items[I].FileData,UpdateDirectory + '\'+ AppUpdateResult.NewManifest.Items[I].FileName);
                end;
              end;
              slProgress.Add('Saving new Manifest');
              XMLDoc.SaveToFile(UpdateDirectory+'\Manifest.xml');
            finally
              XMLDoc := nil;
            end;
            slProgress.Add('Calling IUpdateService.UpdateReceived');
            UpdateService.UpdateReceived(ApplicationGUID,LocationGUID,AppUpdateResult.NewManifest.UpdateVersion);
            Result := Format('Update v.%s is available!',[AppUpdateResult.NewManifest.UpdateVersion]);
            slProgress.Add(Format('Returning Result: %s',[Result]));
          end
          else
          begin
            slProgress.Add('No Update is Available...');
            Result := 'NO Update is available...';
          end;
          AppUpdateResult.Free;
        finally
          StringStream.Free;
        end;
      finally
        CoUninitialize;
      end;
    except
      On E: Exception do
      begin
        sError := Format('ERROR during Update Request: %s',[E.Message]);
        slProgress.Add(sError);
        Result := sError;
      end;
    end;
  finally
    EndTime := Now;
    slProgress.Add(Format('END of Update Log %s.  Update Request Duration was %d seconds',[DateTimeToStr(EndTime),SecondsBetween(StartTime,EndTime)]));
    {$ifdef LOGGING}
    slProgress.SaveToFile(ChangeFileExt(AppFileName,'.log'));
    {$endif}
    slProgress.Free;
  end;
end;

//function TUpdateClient.GetLocationGUID :string;
//var
//  cnFabWare :TADOConnection;
//  qryWorker :TADOQuery;
//  StudioNumber,
//  DataSource,
//  sConnection: string;
//
//  procedure LoadFabWareConfig;
//  const
//    sConfigFileName :string = 'Fabware.config';
//  var
//    F: TextFile;
//    sFileName :string;
//  begin
//    sFileName :=  ExtractFilePath(AppFileName) + sConfigFileName;
//    if FileExists(sFileName) then
//    begin
//      AssignFile(F,sFileName);
//      Reset(F);
//      try
//        Readln(F, StudioNumber);
//        Readln(F, DataSource);
//      finally
//        CloseFile(F);
//      end;
//    end
//    else
//    begin
//      raise Exception.CreateFmt('%s file does not exist in same directory as %s',[sFileName,AppFileName]);
//      Halt(0);
//    end;
//  end;
//
//begin
//  try
//    LoadFabWareConfig;
//    {$ifdef SQL_NATIVE_CLIENT}
//    sConnection := 'Provider=SQLNCLI10.1;';
//    {$else}
//    sConnection := 'Provider=SQLOLEDB.1;';
//    {$endif}
//    sConnection := sConnection + 'User ID=fabware;';
//    sConnection := sConnection + 'Password=tH9b4ruP;';
//    sConnection := sConnection + 'Persist Security Info=True;';
//    sConnection := sConnection + 'Initial Catalog=LocalStudio'+TRIM(StudioNumber)+';';
//    sConnection := sConnection + 'Data Source= '+TRIM(DataSource);
//    cnFabWare := TADOConnection.Create(nil);
//    qryWorker := TADOQuery.Create(nil);
//    try
//      qryWorker.Connection := cnFabWare;
//      cnFabWare.ConnectionString := sConnection;
//      cnFabWare.Open;
//      qryWorker.SQL.Text := Format('select LocationGUID from Studio where StudioNumber = %s',[StudioNumber]);
//      qryWorker.Open;
//      Result := qryWorker.Fields[0].AsString;
//      qryWorker.Close;
//      cnFabWare.Close;
//    finally
//      if Assigned(cnFabWare) then
//        cnFabWare.Free;
//      if Assigned(qryWorker) then
//        qryWorker.Free;
//    end;
//  except
//    on E :Exception do
//    begin
//      raise Exception.CreateFmt('There was an error opening the database. The error reported is'#13#10'%s',[E.Message]);
//    end
//  end;
//end;








end.
