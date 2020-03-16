// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://localhost:8080/wsdl/IUpdateService
//  >Import : http://localhost:8080/wsdl/IUpdateService>0
// Version  : 1.0
// (10/16/2012 12:51:07 PM - - $Rev: 45757 $)
// ************************************************************************ //

unit unIUpdateService;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;

type

  // ************************************************************************ //
  // The following types, referred to in the WSDL document are not being represented
  // in this file. They are either aliases[@] of other types represented or were referred
  // to but never[!] declared in the document. The types from the latter category
  // typically map to predefined/known XML or Embarcadero types; however, they could also
  // indicate incorrect WSDL documents that failed to declare or import a schema type.
  // ************************************************************************ //
  // !:base64Binary    - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:string          - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:boolean         - "http://www.w3.org/2001/XMLSchema"[Gbl]

  ApplicationUpdateResult = class;              { "urn:UpdateServiceIntf"[GblCplx] }
  ApplicationManifestEntry = class;             { "urn:UpdateServiceIntf"[GblCplx] }
  ApplicationManifest  = class;                 { "urn:UpdateServiceIntf"[GblCplx] }

  ArrayOfApplicationManifestEntry = array of ApplicationManifestEntry;   { "urn:UpdateServiceIntf"[GblCplx] }


  // ************************************************************************ //
  // XML       : ApplicationUpdateResult, global, <complexType>
  // Namespace : urn:UpdateServiceIntf
  // ************************************************************************ //
  ApplicationUpdateResult = class(TRemotable)
  private
    FUpdateIsAvailable: Boolean;
    FNewManifest: ApplicationManifest;
    FLocationGUID: string;
    FApplicationGUID: string;
  public
    destructor Destroy; override;
  published
    property UpdateIsAvailable: Boolean              read FUpdateIsAvailable write FUpdateIsAvailable;
    property NewManifest:       ApplicationManifest  read FNewManifest write FNewManifest;
    property LocationGUID:        string               read FLocationGUID write FLocationGUID;
    property ApplicationGUID:   string               read FApplicationGUID write FApplicationGUID;
  end;



  // ************************************************************************ //
  // XML       : ApplicationManifestEntry, global, <complexType>
  // Namespace : urn:UpdateServiceIntf
  // ************************************************************************ //
  ApplicationManifestEntry = class(TRemotable)
  private
    FVersion: string;
    FFileName: string;
    FIsAPatch: Boolean;
    FIsAZip: Boolean;  //is this file a ZIP archive that needs to be expanded on delivery
    FLaunch: Boolean;
    FTargetPath: string;
    FFileData: TByteDynArray;
  published
    property Version:    string         read FVersion write FVersion;
    property FileName:   string         read FFileName write FFileName;
    property IsAPatch:   Boolean        read FIsAPatch write FIsAPatch;
    property IsAZip:              Boolean                          read FIsAZip write FIsAZip;
    property Launch:     Boolean        read FLaunch write FLaunch;
    property TargetPath: string         read FTargetPath write FTargetPath;
    property FileData:   TByteDynArray  read FFileData write FFileData;
  end;



  // ************************************************************************ //
  // XML       : ApplicationManifest, global, <complexType>
  // Namespace : urn:UpdateServiceIntf
  // ************************************************************************ //
  ApplicationManifest = class(TRemotable)
  private
    FItems: ArrayOfApplicationManifestEntry;
    FWhatsNew: string;
    FUpdateVersion: string;
    FIsMandatory: Boolean;
    FIsSilent: Boolean;
    FIsImmediate: Boolean;
    {$ifdef FABUTAN}
    FSyncProgrammability: Boolean;
    FSyncData: Boolean;
    {$ENDIF}
  public
    destructor Destroy; override;
  published
    property Items:               ArrayOfApplicationManifestEntry  read FItems write FItems;
    property WhatsNew:            string                           read FWhatsNew write FWhatsNew;
    property UpdateVersion:       string                           read FUpdateVersion write FUpdateVersion;
    property IsMandatory:         Boolean                          read FIsMandatory write FIsMandatory;
    property IsSilent:            Boolean                          read FIsSilent write FIsSilent;
    property IsImmediate:         Boolean                          read FIsImmediate write FIsImmediate;
    {$ifdef FABUTAN}
    property SyncProgrammability: Boolean                          read FSyncProgrammability write FSyncProgrammability;
    property SyncData:            Boolean                          read FSyncData write FSyncData;
    {$ENDIF}
  end;


  // ************************************************************************ //
  // Namespace : urn:UpdateServiceIntf-IUpdateService
  // soapAction: urn:UpdateServiceIntf-IUpdateService#%operationName%
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : rpc
  // use       : encoded
  // binding   : IUpdateServicebinding
  // service   : IUpdateServiceservice
  // port      : IUpdateServicePort
  // URL       : http://localhost:8080/soap/IUpdateService
  // ************************************************************************ //
  IUpdateService = interface(IInvokable)
  ['{7115F6C6-418F-AC9A-1460-C8F433092514}']
    function  GetUpdate(const ApplicationGUID: string; const InstallationGUID: string; const Manifest: string): ApplicationUpdateResult; stdcall;
    procedure UpdateReceived(const ApplicationGUID: string; const InstallationGUID: string; const UpdateVersion: string); stdcall;
    procedure UpdateApplied(const ApplicationGUID: string; const InstallationGUID: string; const UpdateVersion: string; const UpdateResult: string; const UpdateLog: string); stdcall;
    function RegisterInstall(const ApplicationGUID, DeviceGUID, DeviceFingerPrint: string) :string; stdcall;  //returns InstallationGUID aka LocationGUID
  end;

function GetIUpdateService(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): IUpdateService;


implementation
  uses SysUtils;

function GetIUpdateService(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): IUpdateService;
const
  defWSDL = 'http://localhost:8080/wsdl/IUpdateService';
  defURL  = 'http://localhost:8080/soap/IUpdateService';
  defSvc  = 'IUpdateServiceservice';
  defPrt  = 'IUpdateServicePort';
var
  RIO: THTTPRIO;
begin
  Result := nil;
  if (Addr = '') then
  begin
    if UseWSDL then
      Addr := defWSDL
    else
      Addr := defURL;
  end;
  if HTTPRIO = nil then
    RIO := THTTPRIO.Create(nil)
  else
    RIO := HTTPRIO;
  try
    Result := (RIO as IUpdateService);
    if UseWSDL then
    begin
      RIO.WSDLLocation := Addr;
      RIO.Service := defSvc;
      RIO.Port := defPrt;
    end else
      RIO.URL := Addr;
  finally
    if (Result = nil) and (HTTPRIO = nil) then
      RIO.Free;
  end;
end;


destructor ApplicationUpdateResult.Destroy;
begin
  SysUtils.FreeAndNil(FNewManifest);
  inherited Destroy;
end;

destructor ApplicationManifest.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FItems)-1 do
    SysUtils.FreeAndNil(FItems[I]);
  System.SetLength(FItems, 0);
  inherited Destroy;
end;

initialization
  { IUpdateService }
  InvRegistry.RegisterInterface(TypeInfo(IUpdateService), 'urn:UpdateServiceIntf-IUpdateService', '');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(IUpdateService), 'urn:UpdateServiceIntf-IUpdateService#%operationName%');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfApplicationManifestEntry), 'urn:UpdateServiceIntf', 'ArrayOfApplicationManifestEntry');
  RemClassRegistry.RegisterXSClass(ApplicationUpdateResult, 'urn:UpdateServiceIntf', 'ApplicationUpdateResult');
  RemClassRegistry.RegisterXSClass(ApplicationManifestEntry, 'urn:UpdateServiceIntf', 'ApplicationManifestEntry');
  RemClassRegistry.RegisterXSClass(ApplicationManifest, 'urn:UpdateServiceIntf', 'ApplicationManifest');

end.
