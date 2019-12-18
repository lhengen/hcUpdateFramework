unit hcVersionText;

interface

function GetFileVersionText : string; overload;
function GetFileVersionText(const sFileName:string): string; overload;

implementation

uses
  SysUtils, Windows;

function GetFileVersionText : string;
var
  VerMajor, VerMinor, VerRelease, VerBuild : word;
  VerInfoSize : DWORD;
  VerInfo : Pointer;
  VerValueSize : DWORD;
  VerValue : PVSFixedFileInfo;
  Dummy : DWORD;
begin
  VerInfoSize := GetFileVersionInfoSize(PChar(ParamStr(0)), Dummy);
  if VerInfoSize = 0 then
  begin
    Result := '';
  end
  else
  begin
    GetMem(VerInfo, VerInfoSize);
    GetFileVersionInfo(PChar(ParamStr(0)), 0, VerInfoSize, VerInfo);
    VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
    with VerValue^ do
    begin
      VerMajor := dwFileVersionMS shr 16;
      VerMinor := dwFileVersionMS and $FFFF;
      VerRelease := dwFileVersionLS shr 16;
      VerBuild := dwFileVersionLS and $FFFF;
    end;
    FreeMem(VerInfo, VerInfoSize);
    Result := Format('%d.%d.%d.%d', [VerMajor, VerMinor, VerRelease, VerBuild]);
  end;
end;

function GetFileVersionText(const sFileName :string) : string;
var
  VerMajor, VerMinor, VerRelease, VerBuild : word;
  VerInfoSize : DWORD;
  VerInfo : Pointer;
  VerValueSize : DWORD;
  VerValue : PVSFixedFileInfo;
  Dummy : DWORD;
begin
  VerInfoSize := GetFileVersionInfoSize(PChar(sFilename), Dummy);
  if VerInfoSize = 0 then
  begin
    Result := '';
  end
  else
  begin
    GetMem(VerInfo, VerInfoSize);
    GetFileVersionInfo(PChar(sFilename), 0, VerInfoSize, VerInfo);
    VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
    with VerValue^ do
    begin
      VerMajor := dwFileVersionMS shr 16;
      VerMinor := dwFileVersionMS and $FFFF;
      VerRelease := dwFileVersionLS shr 16;
      VerBuild := dwFileVersionLS and $FFFF;
    end;
    FreeMem(VerInfo, VerInfoSize);
    Result := Format('%d.%d.%d.%d', [VerMajor, VerMinor, VerRelease, VerBuild]);
  end;
end;


end.
