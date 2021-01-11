{-----------------------------------------------------------------------------}
{ A component to read version info resources.  It is intended for Delphi 3,   }
{ but should work with any file that contains a properly formatted resource.  }
{ Copyright 1996, Brad Stowers.  All Rights Reserved.                         }
{ This component can be freely used and distributed in commercial and private }
{ environments, provied this notice is not modified in any way and there is   }
{ no charge for it other than nomial handling fees.  Contact me directly for  }
{ modifications to this agreement.                                            }
{-----------------------------------------------------------------------------}
{ Feel free to contact me if you have any questions, comments or suggestions  }
{ at bstowers@pobox.com or 72733,3374 on CompuServe.                          }
{ The lateset version will always be available on the web at:                 }
{   http://www.pobox.com/~bstowers/delphi/                                    }
{-----------------------------------------------------------------------------}
{ Date last modified:  June 17, 1997                                          }
{-----------------------------------------------------------------------------}


{ ----------------------------------------------------------------------------}
{ ThcVersionInfo v1.00                                                  }
{ ----------------------------------------------------------------------------}
{ Description:                                                                }
{   A component to read version info resources.  It is intended for Delphi 3, }
{   but should work with any file that contains a properly formatted resource.}
{ Notes:                                                                      }
{   * I have not tested this on anything but Delphi 3 generated EXEs with     }
{     proper version info resources.                                          }
{ ----------------------------------------------------------------------------}
{ Revision History:                                                           }
{ 1.00:  + Initial release.                                                   }
{ ----------------------------------------------------------------------------}

unit hcVersionInfo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

const
  IDX_COMPANYNAME           = 0;
  IDX_FILEDESCRIPTION       = 1;
  IDX_FILEVERSION           = 2;
  IDX_INTERNALNAME          = 3;
  IDX_LEGALCOPYRIGHT        = 4;
  IDX_LEGALTRADEMARKS       = 5;
  IDX_ORIGINALFILENAME      = 6;
  IDX_PRODUCTNAME           = 7;
  IDX_PRODUCTVERSION        = 8;
  IDX_COMMENTS              = 9;

type
  TFixedFileInfoFlag = (ffDebug, ffInfoInferred, ffPatched, ffPreRelease,
      ffPrivateBuild, ffSpecialBuild);
  TFixedFileInfoFlags = set of TFixedFileInfoFlag;

  TVersionOperatingSystemFlag = (vosUnknown, vosDOS, vosOS2_16, vosOS2_32,
      vosNT, vosWindows16, vosPresentationManager16, vosPresentationManager32,
      vosWindows32);
  { This is supposed to be one of the first line, and one of the second line. }
  TVersionOperatingSystemFlags = set of TVersionOperatingSystemFlag;

  TVersionFileType = (vftUnknown, vftApplication, vftDLL, vftDriver, vftFont,
      vftVXD, vftStaticLib);

  TFixedFileVersionInfo = class
  private
    FData: PVSFixedFileInfo;

    function GetSignature: DWORD;
    function GetStructureVersion: DWORD;
    function GetFileVersionMS: DWORD;
    function GetFileVersionLS: DWORD;
    function GetProductVersionMS: DWORD;
    function GetProductVersionLS: DWORD;
    function GetValidFlags: TFixedFileInfoFlags;
    function GetFlags: TFixedFileInfoFlags;
    function GetFileOperatingSystem: TVersionOperatingSystemFlags;
    function GetFileType: TVersionFileType;
    function GetFileSubType: DWORD;
    function GetCreationDate: TDateTime;
  public
    property Data: PVSFixedFileInfo
      read FData write FData;

    property Signature: DWORD
      read GetSignature;
    property StructureVersion: DWORD
      read GetStructureVersion;
    property FileVersionMS: DWORD
      read GetFileVersionMS;
    property FileVersionLS: DWORD
      read GetFileVersionLS;
    property ProductVersionMS: DWORD
      read GetProductVersionMS;
    property ProductVersionLS: DWORD
      read GetProductVersionLS;
    property ValidFlags: TFixedFileInfoFlags
      read GetValidFlags;
    property Flags: TFixedFileInfoFlags
      read GetFlags;
    property FileOperatingSystem: TVersionOperatingSystemFlags
      read GetFileOperatingSystem;
    property FileType: TVersionFileType
      read GetFileType;
    property FileSubType: DWORD
      read GetFileSubType;
    property CreationDate: TDateTime
      read GetCreationDate;
  end;

  ThcVersionInfo = class(TComponent)
  private
    FVersionInfo: PChar;
    FVersionInfoSize: DWORD;
    FFilename: string;
    FTranslationIDs: TStringList;
    FTranslationIDIndex: integer;
    FFixedInfo: TFixedFileVersionInfo;
    FForceEXE: boolean;
  protected
    procedure SetFilename(Val: string);
    procedure SetTranslationIDIndex(Val: integer);
    function GetTranslationIDs: TStrings;
    procedure SetForceEXE(Val: boolean);

    procedure ReadVersionInfoData;
    function GetVersionInfoString(Index: integer): string;
    function GetResourceStr(Index: string): string;

    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property TranslationIDIndex: integer
      read FTranslationIDIndex
      write SetTranslationIDIndex;
    property TranslationIDs: TStrings
      read GetTranslationIDs;
    property FixedInfo: TFixedFileVersionInfo
      read FFixedInfo;
    property UserResource[Index: string]: string
      read GetResourceStr;

  published
    property Filename: string
      read FFilename
      write SetFilename;
    property CompanyName: string index IDX_COMPANYNAME
      read GetVersionInfoString;
    property FileDescription: string index IDX_FILEDESCRIPTION
      read GetVersionInfoString;
    property FileVersion: string index IDX_FILEVERSION
      read GetVersionInfoString;
    property InternalName: string index IDX_INTERNALNAME
      read GetVersionInfoString;
    property LegalCopyright: string index IDX_LEGALCOPYRIGHT
      read GetVersionInfoString;
    property LegalTrademarks: string index IDX_LEGALTRADEMARKS
      read GetVersionInfoString;
    property OriginalFilename: string index IDX_ORIGINALFILENAME
      read GetVersionInfoString;
    property ProductName: string index IDX_PRODUCTNAME
      read GetVersionInfoString;
    property ProductVersion: string index IDX_PRODUCTVERSION
      read GetVersionInfoString;
    property Comments: string index IDX_COMMENTS
      read GetVersionInfoString;

    property ForceEXE: boolean
      read FForceEXE write SetForceEXE default FALSE;
  end;

implementation

const
  PREDEF_RESOURCES: array[IDX_COMPANYNAME..IDX_COMMENTS] of string = (
     'CompanyName', 'FileDescription', 'FileVersion', 'InternalName',
     'LegalCopyright', 'LegalTrademarks', 'OriginalFilename', 'ProductName',
     'ProductVersion', 'Comments'
    );

constructor ThcVersionInfo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FVersionInfo := NIL;
  FVersionInfoSize := 0;
  FFilename := '';
  FTranslationIDIndex := 0;
  FForceEXE := FALSE;
  FTranslationIDs := TStringList.Create;
  FFixedInfo := TFixedFileVersionInfo.Create;
end;


destructor ThcVersionInfo.Destroy;
begin
  FFixedInfo.Free;
  FTranslationIDs.Free;
  if FVersionInfo <> NIL then
    FreeMem(FVersionInfo, FVersionInfoSize);

  inherited Destroy;
end;


procedure ThcVersionInfo.Loaded;
begin
  inherited Loaded;

  ReadVersionInfoData;
end;


procedure ThcVersionInfo.SetFilename(Val: string);
begin
  FFilename := Val;
  ReadVersionInfoData;
end;

procedure ThcVersionInfo.ReadVersionInfoData;
const
  TRANSLATION_INFO = '\VarFileInfo\Translation';
type
  TTranslationPair = packed record
    Lang,
    CharSet: word;
  end;
  PTranslationIDList = ^TTranslationIDList;
  TTranslationIDList = array[0..MAXINT div SizeOf(TTranslationPair)-1] of TTranslationPair;
var
  Dummy: DWORD;
  TempFilename: string;
  IDs: PTranslationIDList;
  IDsLen: UINT;
  IDCount: integer;
  FixedInfoData: PVSFixedFileInfo;
begin
  FTranslationIDs.Clear;
  FFixedInfo.Data := NIL;
  if FVersionInfo <> NIL then
    FreeMem(FVersionInfo, FVersionInfoSize);

  if FFilename = '' then
  begin
    if IsLibrary and (not FForceEXE) then
    begin
      SetLength(TempFileName, 255);
      SetLength(TempFileName, GetModuleFileName(HInstance, PChar(TempFileName), 255));
    end else
      TempFileName := Application.EXEName;
  end else
    TempFileName := FFilename;

  FVersionInfoSize := GetFileVersionInfoSize(PChar(TempFileName), Dummy);
  if FVersionInfoSize = 0 then
    FVersionInfo := NIL
  else begin
    GetMem(FVersionInfo, FVersionInfoSize);
    GetFileVersionInfo(PChar(TempFileName), Dummy, FVersionInfoSize, FVersionInfo);

    VerQueryValue(FVersionInfo, '\', pointer(FixedInfoData), Dummy);
    FFixedInfo.Data := FixedInfoData;
    if VerQueryValue(FVersionInfo, TRANSLATION_INFO, Pointer(IDs), IDsLen) then
    begin
      IDCount := IDsLen div SizeOf(TTranslationPair);
      for Dummy := 0 to IDCount-1 do
        FTranslationIDs.Add(Format('%.4x%.4x', [IDs[Dummy].Lang, IDs[Dummy].CharSet]));
    end;
  end;

  if FTranslationIDIndex >= FTranslationIDs.Count then
    FTranslationIDIndex := 0;
end;


function ThcVersionInfo.GetVersionInfoString(Index: integer): string;
begin
  if (Index >= Low(PREDEF_RESOURCES)) and (Index <= High(PREDEF_RESOURCES)) then
    Result := GetResourceStr(PREDEF_RESOURCES[Index])
  else
    Result := ''
end;


function ThcVersionInfo.GetResourceStr(Index: string): string;
var
  ResStr: PChar;
  StrLen: UINT;
  SubBlock: string;
  LangCharSet: string;
begin
  if FTranslationIDIndex < FTranslationIDs.Count then
    LangCharSet := FTranslationIDs[FTranslationIDIndex]
  else
    LangCharSet := '';
  SubBlock := '\StringFileInfo\' + LangCharSet + '\' + Index;
  if (FVersionInfo <> NIL) and
     VerQueryValue(FVersionInfo, PChar(SubBlock), Pointer(ResStr), StrLen)
  then
    Result := string(ResStr)
  else
    Result := '';
end;

procedure ThcVersionInfo.SetTranslationIDIndex(Val: integer);
begin
  if (Val > 0) and (Val < FTranslationIDs.Count) then
    FTranslationIDIndex := Val;
end;

function ThcVersionInfo.GetTranslationIDs: TStrings;
begin
  Result := FTranslationIDs;
end;

procedure ThcVersionInfo.SetForceEXE(Val: boolean);
begin
  if FForceEXE <> Val then
  begin
    FForceEXE := Val;
    ReadVersionInfoData;
  end;
end;



function TFixedFileVersionInfo.GetSignature: DWORD;
begin
  if FData = NIL then
    Result := 0
  else
    Result := FData.dwSignature;
end;

function TFixedFileVersionInfo.GetStructureVersion: DWORD;
begin
  if FData = NIL then
    Result := 0
  else
    Result := FData.dwStrucVersion;
end;

function TFixedFileVersionInfo.GetFileVersionMS: DWORD;
begin
  if FData = NIL then
    Result := 0
  else
    Result := FData.dwFileVersionMS;
end;

function TFixedFileVersionInfo.GetFileVersionLS: DWORD;
begin
  if FData = NIL then
    Result := 0
  else
    Result := FData.dwFileVersionLS;
end;

function TFixedFileVersionInfo.GetProductVersionMS: DWORD;
begin
  if FData = NIL then
    Result := 0
  else
    Result := FData.dwProductVersionMS;
end;

function TFixedFileVersionInfo.GetProductVersionLS: DWORD;
begin
  if FData = NIL then
    Result := 0
  else
    Result := FData.dwProductVersionLS;
end;

function TFixedFileVersionInfo.GetValidFlags: TFixedFileInfoFlags;
begin
  Result := [];
  if FData <> NIL then
  begin
    if (FData.dwFileFlagsMask and VS_FF_DEBUG) <> 0 then
      Include(Result, ffDebug);
    if (FData.dwFileFlagsMask and VS_FF_PRERELEASE) <> 0 then
      Include(Result, ffPreRelease);
    if (FData.dwFileFlagsMask and VS_FF_PATCHED) <> 0 then
      Include(Result, ffPatched);
    if (FData.dwFileFlagsMask and VS_FF_PRIVATEBUILD) <> 0 then
      Include(Result, ffPrivateBuild);
    if (FData.dwFileFlagsMask and VS_FF_INFOINFERRED ) <> 0 then
      Include(Result, ffInfoInferred );
    if (FData.dwFileFlagsMask and VS_FF_SPECIALBUILD ) <> 0 then
      Include(Result, ffSpecialBuild );
  end;
end;

function TFixedFileVersionInfo.GetFlags: TFixedFileInfoFlags;
begin
  Result := [];
  if FData <> NIL then
  begin
    if (FData.dwFileFlags and VS_FF_DEBUG) <> 0 then
      Include(Result, ffDebug);
    if (FData.dwFileFlags and VS_FF_PRERELEASE) <> 0 then
      Include(Result, ffPreRelease);
    if (FData.dwFileFlags and VS_FF_PATCHED) <> 0 then
      Include(Result, ffPatched);
    if (FData.dwFileFlags and VS_FF_PRIVATEBUILD) <> 0 then
      Include(Result, ffPrivateBuild);
    if (FData.dwFileFlags and VS_FF_INFOINFERRED ) <> 0 then
      Include(Result, ffInfoInferred );
    if (FData.dwFileFlags and VS_FF_SPECIALBUILD ) <> 0 then
      Include(Result, ffSpecialBuild );
  end;
end;

function TFixedFileVersionInfo.GetFileOperatingSystem: TVersionOperatingSystemFlags;
begin
  Result := [];
  if FData <> NIL then
  begin
    case HiWord(FData.dwFileOS) of
      VOS_DOS shr 16:   Include(Result, vosDOS);
      VOS_OS216 shr 16: Include(Result, vosOS2_16);
      VOS_OS232 shr 16: Include(Result, vosOS2_32);
      VOS_NT shr 16:    Include(Result, vosNT);
    else
      Include(Result, vosUnknown);
    end;

    case LoWord(FData.dwFileOS) of
      LoWord(VOS__WINDOWS16): Include(Result, vosWindows16);
      LoWord(VOS__PM16):      Include(Result, vosPresentationManager16);
      LoWord(VOS__PM32):      Include(Result, vosPresentationManager32);
      LoWord(VOS__WINDOWS32): Include(Result, vosWindows32);
    else
      Include(Result, vosUnknown);
    end;
  end;
end;

function TFixedFileVersionInfo.GetFileType: TVersionFileType;
begin
  Result := vftUnknown;
  if FData <> NIL then
  begin
    case FData.dwFileType of
      VFT_APP:        Result := vftApplication;
      VFT_DLL:        Result := vftDLL;
      VFT_DRV:        Result := vftDriver;
      VFT_FONT:       Result := vftFont;
      VFT_VXD:        Result := vftVXD;
      VFT_STATIC_LIB: Result := vftStaticLib;
    end;
  end;
end;

function TFixedFileVersionInfo.GetFileSubType: DWORD;
begin
  if FData = NIL then
    Result := 0
  else begin
    Result := FData.dwFileSubtype;
  end;
end;

function TFixedFileVersionInfo.GetCreationDate: TDateTime;
var
  SysTime: TSystemTime;
  FileTime: TFileTime;
begin
  if FData = NIL then
    Result := 0
  else begin
    FileTime.dwLowDateTime := FData.dwFileDateLS;
    FileTime.dwHighDateTime := FData.dwFileDateMS;
    if FileTimeToSystemTime(FileTime, SysTime) then
    begin
      Result := SystemTimeToDateTime(SysTime);
    end else
      Result := 0;
  end;
end;



end.



