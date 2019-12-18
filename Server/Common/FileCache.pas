unit FileCache;

interface

uses
  classes
  ,System.Types
  ,ExtCtrls
  ;

type
  TFileCacheObject = class(TObject)
    Filename :string;
    FileData :TByteDynArray;
    Cached :TDateTime; //when the item was added to the cache
    LastAccessed :TDateTime;  //when the item was last accessed
  end;

  TFileCache = class(TList)
  private
    FExpiryTimer :TTimer;
    FExpiryTimeOut :integer;  //expiry timeout in minutes since last access
    procedure DecDynArrayRefCount(const ADynArray);
    function GetDynArrayRefCnt(const ADynArray): Longword;
    procedure IncDynArrayRefCount(const ADynArray);
    procedure TimerExpired(Sender: TObject);
    procedure RemoveCachedItem(Index: integer);
    procedure SetExpiryTimeout(Value :integer);
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    procedure EmptyCache;
    function IndexOf(const FileName :string) :integer;
    procedure AddFile(const Filename :string; FileData :TByteDynArray);
    function GetFileData(const Index :integer) :TByteDynArray;
    property ExpiryTimeOut :integer read FExpiryTimeOut write SetExpiryTimeOut;
  end;

implementation

uses
  System.SysUtils, System.DateUtils;

{ TFileCache }

procedure TFileCache.IncDynArrayRefCount(const ADynArray);
begin
  PLongword(Longword(ADynArray) - 8)^ := PLongword(Longword(ADynArray) - 8)^ + 1;
end;

procedure TFileCache.AfterConstruction;
begin
  inherited;
  FExpiryTimer:= TTimer.Create(nil);
  FExpiryTimer.OnTimer := TimerExpired;
  SetExpiryTimeout(15);
end;


procedure TFileCache.BeforeDestruction;
begin
  FExpiryTimer.Free;
  inherited;
end;

procedure TFileCache.TimerExpired(Sender :TObject);
//traverse all objects and release ones that have expired

var
  I: Integer;
  TimeOfScan :TDateTime;
  anItem :TFileCacheObject;
begin
  TimeOfScan := Now;
  for I := Count - 1 downto 0  do
  begin
    anItem := TFileCacheObject(Self[I]);
    if (MinutesBetween(anItem.LastAccessed,TimeOfScan) > 0) then
      RemoveCachedItem(I);
  end;
end;

procedure TFileCache.RemoveCachedItem(Index :integer);
var
  anItem :TFileCacheObject;
begin
  anItem := TFileCacheObject(Self[Index]);
  DecDynArrayRefCount(anItem.FileData);  //enable release of file data
  Delete(Index);  //remove the item from the list
  anItem.Free;  //free the item
end;


procedure TFileCache.SetExpiryTimeout(Value: integer);
begin
  FExpiryTimer.Enabled := False;
  FExpiryTimer.Interval := Value * SecsPerMin * MSecsPerSec;
  FExpiryTimer.Enabled := True;
end;

procedure TFileCache.DecDynArrayRefCount(const ADynArray);
begin
  PLongword(Longword(ADynArray) - 8)^ := PLongword(Longword(ADynArray) - 8)^ - 1;
end;

function TFileCache.GetDynArrayRefCnt(const ADynArray): Longword;
begin
  if Pointer(ADynArray) = nil then
    Result := 1 {or 0, depending what you need}
  else
    Result := PLongword(Longword(ADynArray) - 8)^;
end;

procedure TFileCache.AddFile(const Filename: string; FileData: TByteDynArray);
var
  anItem :TFileCacheObject;
begin
  anItem := TFileCacheObject.Create;
  anItem.Cached := Now;
  anItem.Filename := FileName;
  anItem.FileData := FileData;
  IncDynArrayRefCount(FileData);
  Add(anItem);
end;


procedure TFileCache.EmptyCache;
var
  I :integer;
begin
  for I := Count - 1 downto 0 do
    RemoveCachedItem(I);
end;

function TFileCache.GetFileData(const Index: integer): TByteDynArray;
var
  anItem :TFileCacheObject;
begin
  anItem := TFileCacheObject(Self[Index]);
  anItem.LastAccessed := Now;
  Result := anItem.FileData;
end;

function TFileCache.IndexOf(const FileName: string): integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if (TFileCacheObject(Self[I]).Filename = FileName) then
    begin
      Result := I;
      break;
    end;
  end;
end;

end.
