unit unUpdateClient;

interface

uses
  Classes, ComObj, ActiveX;

type
  TUpdateClient = class(TComponent)
  private
    FApplicationGUID :string;
    procedure SaveInstallionGUID(const AInstallionGUID: string);
    function GetMachineGUID :string;
    function GetComputerName: string;
  public
    function RegisterInstall :string;
    function CheckForUpdates :string;
    property ApplicationGUID :string read FApplicationGUID write FApplicationGUID;
  end;


implementation

uses
  unIUpdateService, XMLDoc, XMLIntf, unPath, hcUpdateConsts,
  SysUtils, hcVersionInfo, System.DateUtils, unWebServiceFileUtils,
  hcUpdateSettings, Winapi.Windows, System.Win.Registry;


function TUpdateClient.CheckForUpdates :string;
{
  This method assumes the current application directory contains the Manifest file and that it
  contains the ApplicationGUID.  It also assume that the AutoUpdates.ini file is present in the
  same folder and has been updated to contain the InstallationGUID by the registration process.
}
var
  UpdateService :IUpdateService;
  AppUpdateResult :ApplicationUpdateResult;
  I: Integer;
  InstallionGUID,
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
    InstallionGUID := AutoUpdateSettings.InstallionGUID;
    if InstallionGUID = EmptyStr then
      raise Exception.Create('InstallionGUID is Empty!');
    try
      slProgress.Add('Initializing COM');
      CoInitialize(nil);
      try
        StringStream := TStringStream.Create;
        try
          AppDir := ExtractFilePath(AppFileName);

          //---need to get ApplicationGUID from Manifest file if it exists otherwise we're done
          if not FileExists(AppDir + ManifestFileName) then
            raise Exception.CreateFmt('No Manifest file is present in ''%s''',[AppDir])
          else
          begin
            slProgress.Add('Loading and Processing Existing Manifest');
            XMLDoc := TXMLDocument.Create(nil);
            try
              XMLDoc.LoadFromFile(AppDir + ManifestFileName);
              XMLDoc.Active := True;
              iRootNode := XMLDoc.ChildNodes.First;
              ApplicationGUID := iRootNode.Attributes['ApplicationGUID'];
            finally
              XMLDoc := nil;
            end;
          end;

          slProgress.Add('Getting Reference to IUpdateService');
          UpdateService := GetIUpdateService(False, AutoUpdateSettings.WebServiceURI);
          try
            slProgress.Add(Format('Calling IUpdateService.GetUpdate with ApplicationGUID: %s InstallionGUID: %s',[ApplicationGUID,InstallionGUID]));
            AppUpdateResult := UpdateService.GetUpdate(ApplicationGUID,InstallionGUID,StringStream.DataString);
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
              iRootNode.Attributes['ApplicationGUID'] := AppUpdateResult.ApplicationGUID;
              iRootNode.Attributes['UpdateVersion'] := AppUpdateResult.NewManifest.UpdateVersion;
              iRootNode.Attributes['WhatsNew'] := AppUpdateResult.NewManifest.WhatsNew;
              iRootNode.Attributes['IsMandatory'] := AppUpdateResult.NewManifest.IsMandatory;
              iRootNode.Attributes['IsSilent'] := AppUpdateResult.NewManifest.IsSilent;
              iRootNode.Attributes['IsImmediate'] := AppUpdateResult.NewManifest.IsImmediate;

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
            UpdateService.UpdateReceived(ApplicationGUID,InstallionGUID,AppUpdateResult.NewManifest.UpdateVersion);
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

function TUpdateClient.GetComputerName: string;
var
  dwSize: DWORD;
begin
  // Set max size
  dwSize := Succ(MAX_PATH);

  // Resource protection
  try
    // Set string length
    SetLength(result, dwSize);
    // Attempt to get the computer name
    if not (WinAPI.Windows.GetComputerName(@result[1], dwSize)) then
      dwSize := 0;
  finally
    // Truncate string
    SetLength(result, dwSize);
  end;
end;


function TUpdateClient.GetMachineGUID: string;
var
  Registry: TRegistry;
begin
  Registry := TRegistry.Create(KEY_READ or KEY_WOW64_64KEY);
  try
    Registry.RootKey := HKEY_LOCAL_MACHINE;
    if not Registry.OpenKeyReadOnly('SOFTWARE\Microsoft\Cryptography') then
      raise Exception.Create('Unable to access MachineGUID');
    Result := Registry.ReadString('MachineGuid');
  finally
    Registry.Free;
  end;
end;

function TUpdateClient.RegisterInstall: string;
var
  UpdateService :IUpdateService;
  InstallationGUID,
  ApplicationGUID,
  AppDir :string;
  XMLDoc : IXMLDocument;
  iRootNode :IXMLNode;
  slProgress :TStringList;
  StartTime, EndTime :TDateTime;
  sError :string;
  DeviceFingerPrint: string;
  DeviceGUID: string;
begin
  DeviceGUID := GetMachineGUID;;
  DeviceFingerPrint := '';
  slProgress := TStringList.Create;
  StartTime := Now;
  slProgress.Add(Format('Update Log for a RegisterInstall request starting %s',[DateTimeToStr(StartTime)]));
  try
    try
      slProgress.Add('Initializing COM');
      CoInitialize(nil);
      try
        AppDir := ExtractFilePath(AppFileName);

        //---need to get ApplicationGUID from Manifest file if it exists otherwise we're done
        if not FileExists(AppDir + ManifestFileName) then
          raise Exception.CreateFmt('No Manifest file is present in ''%s''',[AppDir])
        else
        begin
          slProgress.Add('Loading Manifest for RegisterInstall request');
          XMLDoc := TXMLDocument.Create(nil);
          try
            XMLDoc.LoadFromFile(AppDir + ManifestFileName);
            XMLDoc.Active := True;
            iRootNode := XMLDoc.ChildNodes.First;
            ApplicationGUID := iRootNode.Attributes['ApplicationGUID'];
          finally
            XMLDoc := nil;
          end;
        end;

        slProgress.Add('Getting Reference to IUpdateService');
        UpdateService := GetIUpdateService(False, AutoUpdateSettings.WebServiceURI);
        try
          slProgress.Add(Format('Calling IUpdateService.RegisterInstall with ApplicationGUID: %s ',[ApplicationGUID]));
          InstallationGUID := UpdateService.RegisterInstall(ApplicationGUID,DeviceGUID,DeviceFingerPrint);
        except
          on E: Exception do   //server is likely not running
          begin   //translate the exception and re-raise (consumer must handle)
            Result := '';
            slProgress.Add('Call to IUpdateService.RegisterInstall FAILED with Error:' + E.Message);
            raise;
          end;
        end;

        if InstallationGUID = EmptyStr then
          raise Exception.Create('LocationGUID was not returned!')
        else //save it on the AutoUpdate.config file
        begin
          Result := 'Installation Registered Successfully!';
          SaveInstallionGUID(InstallationGUID);
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

procedure TUpdateClient.SaveInstallionGUID(const AInstallionGUID: string);
begin
  AutoUpdateSettings.InstallionGUID := AInstallionGUID;
  AutoUpdateSettings.WriteSettings;
end;

end.
