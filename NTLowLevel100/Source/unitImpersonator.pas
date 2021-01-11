{*======================================================================*
 | unitImpersonator                                                     |
 |                                                                      |
 | TImpersonator class.                                                 |
 |                                                                      |
 | The contents of this file are subject to the Mozilla Public License  |
 | Version 1.1 (the "License"); you may not use this file except in     |
 | compliance with the License. You may obtain a copy of the License    |
 | at http://www.mozilla.org/MPL/                                       |
 |                                                                      |
 | Software distributed under the License is distributed on an "AS IS"  |
 | basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See  |
 | the License for the specific language governing rights and           |
 | limitations under the License.                                       |
 |                                                                      |
 | Copyright © Colin Wilson 2004  All Rights Reserved
 |                                                                      |
 | Version  Date        By    Description                               |
 | -------  ----------  ----  ------------------------------------------|
 | 1.0      27/04/2004  CPWW  Original                                  |
 *======================================================================*}


unit unitImpersonator;

interface

uses Windows, Classes, SysUtils;

type

TProfileInfo = record
  dwSize : DWORD;
  dwFlags : DWORD;
  lpUserName : PChar;
  lpProfilePath : PChar;
  lpDefaultPath : PChar;
  lpServerName : PChar;
  lpPolicyPath : PChar;
  hProfile : HKEY;
end;


TImpersonator = class
private
  fTokenHandle : THandle;
  fImpersonating: boolean;
  fProfileLoaded : boolean;
  fProfileInfo : TProfileInfo;
  fLoggedOn : boolean;
  procedure Impersonate;
  function GetImpersonating: boolean;
  function GetHKCURootKey: HKEY;
public
  constructor Create (const domain, user, password : string);
  constructor CreateLoggedOn;   // Impersonate the currently logged on user.

  destructor Destroy; override;

  function CreateProcess(lpApplicationName: PChar; lpCommandLine: PChar;
    lpProcessAttributes, lpThreadAttributes: PSecurityAttributes;
    bInheritHandles: BOOL; dwCreationFlags: DWORD; lpEnvironment: Pointer;
    lpCurrentDirectory: PChar; const lpStartupInfo: TStartupInfo;
    var lpProcessInformation: TProcessInformation): BOOL;

  property RawImpersonating : boolean read fImpersonating;
  property RawProfileLoaded : boolean read fProfileLoaded;

  property Impersonating : boolean read GetImpersonating;
  property HKCURootKey : HKEY read GetHKCURootKey;
  property ProfileLoaded : boolean read fProfileLoaded;
end;

const
  PI_NOUI        = 1;     // Prevents displaying of messages
  PI_APPLYPOLICY = 2;     // Apply NT4 style policy

  LOGON_WITH_PROFILE = 1;
  LOGON_NETCREDENTIALS_ONLY = 2;


function LoadUserProfile (hToken : THandle; var profileInfo : TProfileInfo) : BOOL; stdcall;
function UnloadUserProfile (hToken, HKEY : THandle) : BOOL; stdcall;
function GetCurrentUserName : string;
function OpenProcessHandle (const process : string) : THandle;
function CreateProcessWithLogonW
  (lpUserName, lpDomain, lpPassword : PWideChar;
   dwLogonFlags : DWORD;
   lpApplicationName : PWideChar;
   lpCommandLine : PWideChar;
   dwCreationFlags : DWORD;
   lpEnvironment : pointer;
   lpCurrentDirectory : PWideChar;
   const lpStartupInformation : TStartupInfo;
   var lpProcessInfo : TProcessInformation) : BOOL; stdcall;

implementation

uses psapi;

function LoadUserProfile; external 'userenv.dll' name 'LoadUserProfileA';
function UnLoadUserProfile; external 'userenv.dll';
function CreateProcessWithLogonW; external 'advapi32.dll';

{*----------------------------------------------------------------------*
 | function OpenProcessHandle                                           |
 |                                                                      |
 | Return the process handle for a named running process.               |
 |                                                                      |
 | Parameters:                                                          |
 |   const process : string      eg. explorer.exe                       |
 |                                                                      |
 | The function returns the process handle - or '0' if the prcoess      |
 | is not running.                                                      |
 *----------------------------------------------------------------------*}
function OpenProcessHandle (const process : string) : THandle;
var
  buffer, pid : PDWORD;
  bufLen, cbNeeded : DWORD;
  hp : THandle;
  fileName : array [0..256] of char;
  i : Integer;
begin
  result := 0;
  bufLen := 65536;
  GetMem (buffer, bufLen);
  try
    if EnumProcesses (buffer, bufLen, cbNeeded) then
    begin
      pid := buffer;
      for i := 0 to cbNeeded div sizeof (DWORD) - 1 do
      begin
        hp := OpenProcess (PROCESS_VM_READ or PROCESS_QUERY_INFORMATION, False, pid^);
        if hp <> 0 then
        try
          if (GetModuleBaseName (hp, 0, fileName, sizeof (fileName)) > 0) and
             (CompareText (fileName, process) = 0) then
          begin
            result := hp;
            break
          end
        finally
          if result = 0 then
            CloseHandle (hp)
        end;

        Inc (pid)
      end
    end
  finally
    FreeMem (buffer)
  end
end;

function GetExplorerProcessToken : THandle;
var
  explorerProcessHandle : THandle;
begin
  explorerProcessHandle := OpenProcessHandle ('explorer.exe');
  if explorerProcesshandle <> 0 then
  try
    if not OpenProcessToken (explorerProcessHandle, TOKEN_QUERY or TOKEN_IMPERSONATE or TOKEN_DUPLICATE, result) then
      RaiseLastOSError;
  finally
    CloseHandle (explorerProcessHandle)
  end
  else
    result := INVALID_HANDLE_VALUE;
end;

function GetCurrentUserName : string;
var
  unLen : DWORD;
begin
  unLen := 512;
  SetLength (result, unLen);
  GetUserName (PChar (result), unLen);
  result := PChar (result);
end;

{ TImpersonator }

constructor TImpersonator.Create(const domain, user, password: string);
begin
  if LogonUser (PChar (user), PChar (domain), PChar (password), LOGON32_LOGON_INTERACTIVE, LOGON32_PROVIDER_DEFAULT, fTokenHandle) then
    Impersonate;
end;

procedure TImpersonator.Impersonate;
var
  userName : string;
  rv : DWORD;
begin
  userName := GetCurrentUserName;

  ZeroMemory (@fProfileInfo, sizeof (fProfileInfo));
  fProfileInfo.dwSize := sizeof (fProfileInfo);
  fProfileInfo.lpUserName := PChar (userName);
  fProfileInfo.dwFlags := PI_APPLYPOLICY;

  fProfileLoaded  := LoadUserProfile (fTokenHandle, fProfileInfo);
  if not fProfileLoaded then
    RaiseLastOSError;

  fImpersonating := ImpersonateLoggedOnUser (fTokenHandle);
  if not fImpersonating then
  begin
    rv := GetLastError;
    if fProfileLoaded then
    begin
      UnloadUserProfile (fTokenHandle, fProfileInfo.hProfile);
      fProfileLoaded := False
    end;
    SetLastError (rv);
    RaiseLastOSError
  end
end;

constructor TImpersonator.CreateLoggedOn;
begin
  fLoggedOn := True;
  fTokenHandle := GetExplorerProcessToken;

  if fTokenHandle <> INVALID_HANDLE_VALUE then
    Impersonate;
end;

destructor TImpersonator.Destroy;
begin
  if fProfileLoaded then
    UnloadUserProfile (fTokenHandle, fProfileInfo.hProfile);

  if fImpersonating then
    RevertToSelf;

  CloseHandle (fTokenHandle);
end;

function TImpersonator.GetImpersonating: boolean;
begin
  result := fImpersonating and fProfileLoaded
end;

function TImpersonator.GetHKCURootKey: HKEY;
begin
  if fProfileLoaded then
    result := fProfileInfo.hProfile
  else
    result := HKEY_CURRENT_USER;
end;

function TImpersonator.CreateProcess(lpApplicationName,
  lpCommandLine: PChar; lpProcessAttributes,
  lpThreadAttributes: PSecurityAttributes; bInheritHandles: BOOL;
  dwCreationFlags: DWORD; lpEnvironment: Pointer;
  lpCurrentDirectory: PChar; const lpStartupInfo: TStartupInfo;
  var lpProcessInformation: TProcessInformation): BOOL;
var
  h : THandle;
begin
  if DuplicateTokenEx (fTokenHandle, MAXIMUM_ALLOWED, Nil, SecurityAnonymous, TokenPrimary, h) then
  try
    result := CreateProcessAsUser (h,
      lpApplicationName, lpCommandLine, lpProcessAttributes, lpThreadAttributes,
      bInheritHandles, dwCreationFlags, lpEnvironment,
      lpCurrentDirectory, lpStartupInfo, lpProcessInformation)
  finally
    CloseHandle (h)
  end
  else
    result := False;
end;

end.
