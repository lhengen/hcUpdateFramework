unit unitNTRegistry;

interface

uses Windows, Classes, SysUtils, Registry;

type

TNTRegistry = class (TRegistry)
public
  function GetMultiSZ (const valueName : string; sl : TStrings) : Integer;
end;

implementation

{ TNTRegistry }

function TNTRegistry.GetMultiSZ(const valueName: string; sl: TStrings): Integer;
var
  st : string;
  tp, cb : DWORD;
  i : Integer;
begin
  cb := 0;
  sl.Clear;
  if RegQueryValueEx (CurrentKey, PChar (valueName), Nil, @tp, Nil, @cb) = ERROR_SUCCESS then
  begin
    if tp <> REG_MULTI_SZ then
      raise ERegistryException.Create('Not a MULTI_SZ value');

    SetLength (st, cb);
    if RegQueryValueEx (CurrentKey, PChar (valueName), Nil, @tp, PByte (PChar (st)), @cb) = ERROR_SUCCESS then
    begin
      i := 1;
      while (Length (st) > 0) and (st [Length (st)] = #0) do
        Delete (st, Length (st), 1);

      while i <= Length (st) do
      begin
        if st [i] = #0 then
          st [i] := #1;
        Inc (i);
      end;

      sl.Delimiter := #1;
      sl.DelimitedText := st
    end
  end;

  result := sl.Count
end;

end.
