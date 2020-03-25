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
  protected
    function GetDeviceFingerPrint :string; virtual;
  public
    function RegisterInstall :string;
    function CheckForUpdates :string;
    property ApplicationGUID :string read FApplicationGUID write FApplicationGUID;
  end;


implementation

uses
  unIUpdateService, XMLDoc, XMLIntf, unPath, hcUpdateConsts,
  SysUtils, hcVersionInfo, System.DateUtils, unWebServiceFileUtils,
  hcUpdateSettings, Winapi.Windows, System.Win.Registry, PJSysInfo,
  System.TypInfo;


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

function TUpdateClient.GetDeviceFingerPrint: string;
const
  cProcessors: array[TPJProcessorArchitecture] of string = (
    'paUnknown', 'paX64', 'paIA64', 'paX86'
  );
  cBootModes: array[TPJBootMode] of string = (
    'bmUnknown', 'bmNormal', 'bmSafeMode', 'bmSafeModeNetwork'
  );
var
  slFingerPrint :TStringList;
begin
  slFingerPrint := TStringList.Create;
  try
    with slFingerPrint do
    begin
      //Computer information
      AddPair('User Name', TPJComputerInfo.UserName);
      AddPair('Computer Name', TPJComputerInfo.ComputerName);
      AddPair('MAC Address', TPJComputerInfo.MACAddress);
      AddPair('Processor Count', IntToStr(TPJComputerInfo.ProcessorCount));
      AddPair('Processor Architecture', cProcessors[TPJComputerInfo.Processor]);
      AddPair('Processor Identifier', TPJComputerInfo.ProcessorIdentifier);
      AddPair('Processor Name', TPJComputerInfo.ProcessorName);
      AddPair('Processor Speed (MHz)', IntToStr(TPJComputerInfo.ProcessorSpeedMHz));
      AddPair('Is 64 Bit?', BoolToStr(TPJComputerInfo.Is64Bit,True));
      AddPair('Is Network Present?', BoolToStr(TPJComputerInfo.IsNetworkPresent,True));
      AddPair('Boot Mode', cBootModes[TPJComputerInfo.BootMode]);
      AddPair('Is Administrator?', BoolToStr(TPJComputerInfo.IsAdmin,True));
      AddPair('Is UAC active?', BoolToStr(TPJComputerInfo.IsUACActive,True));
      AddPair('BIOS Vender', TPJComputerInfo.BiosVendor);
      AddPair('System Manufacturer', TPJComputerInfo.SystemManufacturer);
      AddPair('System Product Name', TPJComputerInfo.SystemProductName);

      //OS information
      AddPair('BuildNumber', IntToStr(TPJOSInfo.BuildNumber));
      AddPair('Description', TPJOSInfo.Description);
      AddPair('Edition', TPJOSInfo.Edition);
      if SameDateTime(TPJOSInfo.InstallationDate, 0.0) then
        AddPair('InstallationDate', 'Unknown')
      else
        AddPair('InstallationDate', DateTimeToStr(TPJOSInfo.InstallationDate));
      AddPair('IsServer', BoolToStr(TPJOSInfo.IsServer,True));
      AddPair('IsWin32s', BoolToStr(TPJOSInfo.IsWin32s,True));
      AddPair('IsWin9x', BoolToStr(TPJOSInfo.IsWin9x,True));
      AddPair('IsWinNT', BoolToStr(TPJOSInfo.IsWinNT,True));
      AddPair('IsWow64', BoolToStr(TPJOSInfo.IsWow64,True));
      AddPair('IsMediaCenter', BoolToStr(TPJOSInfo.IsMediaCenter,True));
      AddPair('IsTabletPC', BoolToStr(TPJOSInfo.IsTabletPC,True));
      AddPair('IsRemoteSession', BoolToStr(TPJOSInfo.IsRemoteSession,True));
      AddPair('MajorVersion', IntToStr(TPJOSInfo.MajorVersion));
      AddPair('MinorVersion', IntToStr(TPJOSInfo.MinorVersion));

      AddPair('Platform', GetEnumName(TypeInfo(TPJOSPlatform),Ord(TPJOSInfo.Platform)));
      AddPair('Product', TPJOSInfo.ProductName);
      AddPair('ProductID', TPJOSInfo.ProductID);
      AddPair('ProductName', TPJOSInfo.ProductName);
      AddPair('ServicePack', TPJOSInfo.ServicePack);
      AddPair('ServicePackEx', TPJOSInfo.ServicePackEx);

      AddPair('ServicePackMajor', IntToStr(TPJOSInfo.ServicePackMajor));
      AddPair('ServicePackMinor', IntToStr(TPJOSInfo.ServicePackMinor));
      AddPair('HasPenExtensions', BoolToStr(TPJOSInfo.HasPenExtensions,True));
      AddPair('RegisteredOrganization', TPJOSInfo.RegisteredOrganisation);
      AddPair('RegisteredOwner', TPJOSInfo.RegisteredOwner);
      AddPair('CanSpoof', BoolToStr(TPJOSInfo.CanSpoof,True));
      AddPair('IsReallyWindows2000OrGreater',
        BoolToStr(TPJOSInfo.IsReallyWindows2000OrGreater,True));
      AddPair('IsReallyWindows2000SP1OrGreater',
        BoolToStr(TPJOSInfo.IsReallyWindows2000SP1OrGreater,True));
      AddPair('IsReallyWindows2000SP2OrGreater',
        BoolToStr(TPJOSInfo.IsReallyWindows2000SP2OrGreater,True));
      AddPair('IsReallyWindows2000SP3OrGreater',
        BoolToStr(TPJOSInfo.IsReallyWindows2000SP3OrGreater,True));
      AddPair('IsReallyWindows2000SP4OrGreater',
        BoolToStr(TPJOSInfo.IsReallyWindows2000SP4OrGreater,True));
      AddPair('IsReallyWindowsXPOrGreater',
        BoolToStr(TPJOSInfo.IsReallyWindowsXPOrGreater,True));
      AddPair('IsReallyWindowsXPSP1OrGreater',
        BoolToStr(TPJOSInfo.IsReallyWindowsXPSP1OrGreater,True));
      AddPair('IsReallyWindowsXPSP2OrGreater',
        BoolToStr(TPJOSInfo.IsReallyWindowsXPSP2OrGreater,True));
      AddPair('IsReallyWindowsXPSP3OrGreater',
        BoolToStr(TPJOSInfo.IsReallyWindowsXPSP3OrGreater,True));
      AddPair('IsReallyWindowsVistaOrGreater',
        BoolToStr(TPJOSInfo.IsReallyWindowsVistaOrGreater,True));
      AddPair('IsReallyWindowsVistaSP1OrGreater',
        BoolToStr(TPJOSInfo.IsReallyWindowsVistaSP1OrGreater,True));
      AddPair('IsReallyWindowsVistaSP2OrGreater',
        BoolToStr(TPJOSInfo.IsReallyWindowsVistaSP2OrGreater,True));
      AddPair('IsReallyWindows7OrGreater',
        BoolToStr(TPJOSInfo.IsReallyWindows7OrGreater,True));
      AddPair('IsReallyWindows7SP1OrGreater',
        BoolToStr(TPJOSInfo.IsReallyWindows7SP1OrGreater,True));
      AddPair('IsReallyWindows8OrGreater',
        BoolToStr(TPJOSInfo.IsReallyWindows8OrGreater,True));
      AddPair('IsReallyWindows8Point1OrGreater',
        BoolToStr(TPJOSInfo.IsReallyWindows8Point1OrGreater,True));
      AddPair('IsReallyWindows10OrGreater',
        BoolToStr(TPJOSInfo.IsReallyWindows10OrGreater,True));
      AddPair('IsWindowsServer', BoolToStr(TPJOSInfo.IsWindowsServer,True));
      AddPair('Win32Platform', IntToStr(Win32Platform));
      AddPair('Win32MajorVersion', IntToStr(Win32MajorVersion));
      AddPair('Win32MinorVersion', IntToStr(Win32MinorVersion));
      AddPair('Win32BuildNumber', IntToStr(Win32BuildNumber));
      AddPair('Win32CSDVersion', Win32CSDVersion);
    end;
    Result := slFingerPrint.Text;
  finally
    slFingerPrint.Free;
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
  DeviceFingerPrint := GetDeviceFingerPrint;
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
  //update folders to actual deployment path
  AutoUpdateSettings.AppDir := ExtractFilePath(AppFileName);
  AutoUpdateSettings.WriteSettings;
end;

end.
