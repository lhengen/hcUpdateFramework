unit unitNamedPipes;

interface

uses Windows, Classes, SysUtils, SyncObjs;

type

TNamedPipeServerState = (npDisconnected, npListening, npConnected);
TNamedPipeServer = class
private
  fPipeName : string;
  fHandle : THandle;
  fState : TNamedPipeServerState;
public
  constructor Create (const APipeName : string);
  destructor Destroy; override;
  function Listen (var clientName : string) : Boolean;
  function Read (var buffer : string) : Boolean;
  function Write (var buffer : string) : Boolean;
  procedure Cancel;
  procedure Disconnect;
end;

TNamedPipeClient = class
private
  fPipeName : string;
  fHandle : THandle;
  fLock : TCriticalSection;
public
  constructor Create (const APipeName : string);
  destructor Destroy; override;
  function Transact (const request : string; var reply : string) : boolean;
  property Handle : THandle read fHandle;
end;

implementation

{ TNamedPipeServer }

procedure TNamedPipeServer.Cancel;
begin
  CloseHandle (CreateFile (PChar ('\\.\pipe\\' + fPipeName),
                          GENERIC_READ or GENERIC_WRITE,
                          0,
                          Nil,
                          OPEN_EXISTING,
                          0,
                          0));
end;

constructor TNamedPipeServer.Create(const APipeName: string);
var
  sd : PSecurityDescriptor;
  sa : TSecurityAttributes;
begin
  fPipeName := APipeName;

  GetMem (sd, SECURITY_DESCRIPTOR_MIN_LENGTH);
  try
    InitializeSecurityDescriptor (sd, SECURITY_DESCRIPTOR_REVISION);
    SetSecurityDescriptorDacl (sd, True, PACL (0), False);
    sa.nLength := SizeOf (sa);
    sa.lpSecurityDescriptor := sd;
    sa.bInheritHandle := True;

    fHandle := CreateNamedPipe (PChar ('\\.\pipe\' + fPipeName),
                                PIPE_ACCESS_DUPLEX,
                                PIPE_TYPE_MESSAGE or PIPE_WAIT,
                                PIPE_UNLIMITED_INSTANCES,
                                4096,
                                8,
                                NMPWAIT_WAIT_FOREVER,
                                @sa);
    if fHandle = INVALID_HANDLE_VALUE then
      RaiseLastOSError;
  finally
    FreeMem (sd)
  end
end;

destructor TNamedPipeServer.Destroy;
begin
  CloseHandle (fHandle)
end;

procedure TNamedPipeServer.Disconnect;
begin
  DisconnectNamedPipe (fHandle);

end;

function TNamedPipeServer.Listen(var clientName: string): Boolean;
begin
  Result := False;
  fState := npListening;
  if ConnectNamedPipe (fHandle, Nil) or (GetLastError = ERROR_PIPE_CONNECTED) then
  begin
    Result := True;
    fState := npConnected;
    SetLength (clientName, 256);
    if not GetNamedPipeHandleState (fHandle, Nil, Nil, Nil, Nil, PChar (clientName), 256) then
      clientName := 'Unknown'
    else
      clientName := PChar (clientName)
  end
  else
    fState := npDisconnected
end;

function TNamedPipeServer.Read(var buffer: string): Boolean;
var
  bytesRead : DWORD;
begin
  SetLength (buffer, 80);
  Result := ReadFile (fHandle, PChar (buffer)^, 80, bytesRead, Nil);
  if Result then
  begin
    SetLength (buffer, bytesRead);
  end
  else
  begin
    buffer := '';
  end
end;

function TNamedPipeServer.Write(var buffer: string): Boolean;
var
  bytesWritten : DWORD;
begin
  Result := WriteFile (fHandle, PChar (buffer)^, Length (buffer), bytesWritten, nil);
end;

{ TNamedPipeClient }

constructor TNamedPipeClient.Create(const APipeName: string);
var
  mode : DWORD;
begin
  fPipeName := APipeName;
  fLock := TCriticalSection.Create;

  fHandle := CreateFile (PChar (fPipeName), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, 0, 0);
  if fHandle = INVALID_HANDLE_VALUE then
    RaiseLastOSError;

  mode := PIPE_READMODE_MESSAGE or PIPE_WAIT;
  if not SetNamedPipeHandleState (fHandle, mode, nil, nil) then
    RaiseLastOSError;
end;

destructor TNamedPipeClient.Destroy;
begin
  CloseHandle (fHandle);
  fLock.Free;

  inherited;
end;

function TNamedPipeClient.Transact(const request: string;
  var reply: string): boolean;
var
  bytesRead : DWORD;
begin
  Result := False;
  if fHandle <> INVALID_HANDLE_VALUE then
  begin
    fLock.Enter;
    try
      if WriteFile (fHandle, PChar (request)^, Length (request), bytesRead, nil) then
      begin
        reply := '';
        SetLength (reply, 65536);
        Result := ReadFile (fHandle, PChar (reply)^, 65536, bytesRead, nil);
        SetLength (reply, bytesRead);
      end;

    finally
      fLock.Leave
    end
  end
end;

end.


