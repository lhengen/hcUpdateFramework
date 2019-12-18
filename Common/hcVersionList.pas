unit hcVersionList;

interface

uses
  Classes;

type
  TVersionRec = record
    Major,
    Minor,
    Release,
    Build :SmallInt;
  end;

  ThcSortOrder = (soAscending,soDescending);
  ThcVersionList = class(TStringList)
  public
    procedure Sort; override;
  end;

function ParseVersionInfo(const VersInfo :string) :TVersionRec;
function CompareVersion(Version1, Version2 :TVersionRec) :Integer;

implementation

uses
  StrUtils, SysUtils;


function ParseVersionInfo(const VersInfo :string) :TVersionRec;
{
  Method to parse version strings in the format Major.Minor.Release.Build into a version record
  for comparison purposes.  If the version string does not contain all values ie: Build then
  the method assigns 0.  In this manner even one of the VersInfo passed is shorter than expected
  it can still be compared to a complete version string.
}
var
  nStart,
  nEnd :Integer;
begin
  //parse version string into Record since string compare will not work
  nStart := 1;
  nEnd := PosEx('.',VersInfo,nStart);
  if nEnd = 0 then
    raise Exception.CreateFmt('VersionInfo (%s) is not in expected format!',[VersInfo]);

  Result.Major := StrToInt(Copy(VersInfo,nStart,nEnd-nStart));

  nStart := nEnd + 1;
  nEnd := PosEx('.',VersInfo,nStart);
  if nEnd > 0 then
    Result.Minor := StrToInt(Copy(VersInfo,nStart,nEnd-nStart))
  else
  begin
    nEnd := Length(VersInfo);
    Result.Minor := StrToInt(Copy(VersInfo,nStart,nEnd));
    Result.Release := 0;
    Result.Build := 0;
    exit;
  end;

  nStart := nEnd + 1;
  nEnd := PosEx('.',VersInfo,nStart);
  if nEnd > 0 then
    Result.Release := StrToInt(Copy(VersInfo,nStart,nEnd-nStart))
  else
  begin
    nEnd := Length(VersInfo);
    Result.Minor := StrToInt(Copy(VersInfo,nStart,nEnd));
    Result.Release := 0;
    Result.Build := 0;
    exit;
  end;

  nStart := nEnd + 1;
  nEnd := Length(VersInfo);
  if nEnd > 0 then
    Result.Build := StrToInt(Copy(VersInfo,nStart,nEnd-nStart))
  else
  begin
    nEnd := Length(VersInfo);
    Result.Minor := StrToInt(Copy(VersInfo,nStart,nEnd));
    Result.Build := 0;
  end;
end;

function CompareVersion(Version1, Version2 :TVersionRec) :Integer;
begin
  //compare for Ascending sort result
  Result := Version1.Major - Version2.Major;
  if Result = 0 then  //items are equal so continue to compare
  begin
    Result := Version1.Minor - Version2.Minor;
    if Result = 0 then  //items are equal so continue to compare
    begin
      Result := Version1.Release - Version2.Release;
      if Result = 0 then  //items are equal so continue to compare
      begin
        Result := Version1.Build - Version2.Build;
      end;
    end;
  end;
end;

function StringListCompareVersions(List: TStringList; Index1, Index2: Integer): Integer;
{
  function to parse and compare the VersionInfo strings for 2 items
}
var
  Item1VerRec,
  Item2VerRec :TVersionRec;
begin
  Item1VerRec := ParseVersionInfo(List[Index1]);
  Item2VerRec := ParseVersionInfo(List[Index2]);

  Result := CompareVersion(Item1VerRec,Item2VerRec);
end;


procedure ThcVersionList.Sort;
begin
  CustomSort(StringListCompareVersions);
end;

end.
