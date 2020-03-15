{ Invokable interface IUpdateService }

unit UpdateServiceIntf;

interface

uses Soap.InvokeRegistry, System.Types, Soap.XSBuiltIns, System.Contnrs;

const
  IS_OPTN = $0001;
  IS_UNBD = $0002;
  IS_NLBL = $0004;
  IS_REF  = $0080;

type

  ApplicationManifestEntry = class(TRemotable)
  private
    FLaunch,
    FIsAPatch :Boolean;
    FIsAZip :Boolean;
    FFileData :TByteDynArray;
    FFileName,
    FTargetPath,
    FVersion :string;
  published
    property Version :string read FVersion write FVersion;
    property FileName :string read FFileName write FFileName;
    property IsAPatch :boolean read FIsAPatch write FIsAPatch;
    property IsAZip :boolean read FIsAZip write FIsAZip;
    property Launch :boolean read FLaunch write FLaunch;
    property TargetPath :string read FTargetPath write FTargetPath;
    property FileData :TByteDynArray read FFileData write FFileData;
  end;

  ArrayOfApplicationManifestEntry = array of ApplicationManifestEntry;

  ApplicationManifest = class(TRemotable)
  private
    FIsMandatory,
    FIsSilent,
    FIsImmediate :boolean;

    FUpdateVersion,
    FWhatsNew :string;
    FItems_Specified: boolean;
    FItems :ArrayOfApplicationManifestEntry;
    procedure SetItems(Index: Integer; const AArrayOfApplicationManifestEntry: ArrayOfApplicationManifestEntry);
    function Items_Specified(Index: Integer): boolean;
  published
    property Items :ArrayOfApplicationManifestEntry  Index (IS_OPTN) read FItems write SetItems stored Items_Specified;
    property WhatsNew :string read FWhatsNew write FWhatsNew;
    property UpdateVersion :string read FUpdateVersion write FUpdateVersion;
		property IsMandatory :boolean read FIsMandatory write FIsMandatory;
		property IsSilent :boolean read FIsSilent write FIsSilent;
		property IsImmediate :boolean read FIsImmediate write FIsImmediate;
  end;


  ApplicationUpdateResult = class(TRemotable)
  private
    FUpdateIsAvailable :Boolean;
    FApplicationManifest :ApplicationManifest;
    FInstallationGUID :string;
    FApplicationGUID :string;
  published
    property UpdateIsAvailable :Boolean read FUpdateIsAvailable write FUpdateIsAvailable;
    property NewManifest :ApplicationManifest read FApplicationManifest write FApplicationManifest;
    property InstallationGUID :string read FInstallationGUID write FInstallationGUID;
    property ApplicationGUID :string read FApplicationGUID write FApplicationGUID;
  end;

  { Invokable interfaces must derive from IInvokable }
  IUpdateService = interface(IInvokable)
  ['{6DFF52A8-106B-4D68-AF10-7E424C17AAEF}']
    { Methods of Invokable interface must not use the default }
    { calling convention; stdcall is recommended }
    function GetUpdate(const ApplicationGUID, LocationGUID, Manifest: string): ApplicationUpdateResult; stdcall;
    procedure UpdateReceived(const ApplicationGUID, LocationGUID, UpdateVersion: string); stdcall;
    procedure UpdateApplied(const ApplicationGUID, LocationGUID, UpdateVersion, UpdateResult, UpdateLog: string); stdcall;
    function RegisterInstall(const ApplicationGUID, DeviceGUID, DeviceFingerPrint: string) :string; stdcall;  //returns InstallationGUID
  end;

implementation

{ TApplicationManifestEntryList }

procedure ApplicationManifest.SetItems(Index: Integer; const AArrayOfApplicationManifestEntry: ArrayOfApplicationManifestEntry);
begin
  FItems := AArrayOfApplicationManifestEntry;
  FItems_Specified := True;
end;

function ApplicationManifest.Items_Specified(Index: Integer): boolean;
begin
  Result := FItems_Specified;
end;

initialization
  { Invokable interfaces must be registered }
  InvRegistry.RegisterInterface(TypeInfo(IUpdateService));

end.
