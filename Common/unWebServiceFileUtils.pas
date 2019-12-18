unit unWebServiceFileUtils;

interface

uses
  Types
  {$ifdef SERVER} ,FileCache {$ENDIF}
  ;

procedure ByteArrayToFile(const ByteArray :TByteDynArray; const FileName :string);

{$ifdef SERVER}
function FileToByteArray(const FileName :string ) :TByteDynArray;
{$ENDIF}

implementation

uses
  Math, System.Classes, System.SysUtils;

{$ifdef SERVER}
var
  FileCache :TFileCache;
{$ENDIF}

procedure ByteArrayToFile(const ByteArray :TByteDynArray; const FileName :string);
var
  Count : integer;
  F : File of Byte;
  pTemp : Pointer;
begin
  AssignFile( F, FileName );
  Rewrite(F);
  try
    Count := Length( ByteArray );
    pTemp := @ByteArray[0];
    BlockWrite(F, pTemp^, Count );
  finally
    CloseFile( F );
  end;
end;

{$ifdef SERVER}
function FileToByteArray(const FileName :string) :TByteDynArray;
const
  BLOCK_SIZE = 1024;
var
  BytesRead, BytesToWrite, Count : integer;
  F : FIle of Byte;
  pTemp : Pointer;
  nIndex :integer;
begin
  nIndex := FileCache.IndexOf(FileName);
  if nIndex = -1 then
  begin
    AssignFile( F, FileName );
    Reset(F);
    try
      Count := FileSize( F );
      SetLength(Result, Count );
      pTemp := @Result[0];
      BytesRead := BLOCK_SIZE;
      while (BytesRead = BLOCK_SIZE ) do
      begin
        BytesToWrite := Min(Count, BLOCK_SIZE);
        BlockRead(F, pTemp^, BytesToWrite , BytesRead );
        pTemp := Pointer(LongInt(pTemp) + BLOCK_SIZE);
        Count := Count-BytesRead;
      end;
    finally
      CloseFile( F );
    end;
    FileCache.AddFile(FileName,Result);
  end
  else
    Result := FileCache.GetFileData(nIndex);
end;

initialization
  FileCache := TFileCache.Create;

finalization
  FileCache.EmptyCache;
  FreeAndNil(FileCache);
{$ENDIF}

end.
