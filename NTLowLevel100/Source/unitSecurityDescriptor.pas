(*======================================================================*
 | unitSecurityDescriptor unit for NSIHHTController                     |
 |                                                                      |
 | Class to initialize a security descriptor from a thread token.  Used |
 | to set server's DCOM security model.                                 |
 |                                                                      |
 | Copyright © Marks & Spencer PLC 2002.  All Rights Reserved           |
 |                                                                      |
 | Version  Date        By    Description                               |
 | -------  ----------  ----  ------------------------------------------|
 | 1.0      12/02/2002  CPWW  Original                                  |
 *======================================================================*)

unit unitSecurityDescriptor;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses Windows, Classes, SysUtils;

const
  RPC_C_AUTHN_LEVEL_DEFAULT       = 0;
  RPC_C_AUTHN_LEVEL_NONE          = 1;
  RPC_C_AUTHN_LEVEL_CONNECT       = 2;
  RPC_C_AUTHN_LEVEL_CALL          = 3;
  RPC_C_AUTHN_LEVEL_PKT           = 4;
  RPC_C_AUTHN_LEVEL_PKT_INTEGRITY = 5;
  RPC_C_AUTHN_LEVEL_PKT_PRIVACY   = 6;

  RPC_C_IMP_LEVEL_DEFAULT      = 0;
  RPC_C_IMP_LEVEL_ANONYMOUS    = 1;
  RPC_C_IMP_LEVEL_IDENTIFY     = 2;
  RPC_C_IMP_LEVEL_IMPERSONATE  = 3;
  RPC_C_IMP_LEVEL_DELEGATE     = 4;

type
EOLE_AUTHENTICATION_CAPABILITIES = (
  EOAC_NONE	        = 0,
  EOAC_MUTUAL_AUTH	= $1,
  EOAC_STATIC_CLOAKING	= $20,
  EOAC_DYNAMIC_CLOAKING	= $40,
  EOAC_ANY_AUTHORITY	= $80,
  EOAC_MAKE_FULLSIC	= $100,
  EOAC_DEFAULT	        = $800,
  EOAC_SECURE_REFS	= $2,
  EOAC_ACCESS_CONTROL	= $4,
  EOAC_APPID	        = $8,
  EOAC_DYNAMIC	        = $10,
  EOAC_REQUIRE_FULLSIC	= $200,
  EOAC_AUTO_IMPERSONATE	= $400,
  EOAC_NO_CUSTOM_MARSHAL= $2000,
  EOAC_DISABLE_AAA	= $1000);

procedure InitializeSDFromThreadToken (var sd : TSecurityDescriptor; bDefaulted : Boolean = False; bRevertToProcessToken : boolean = TRUE);

implementation

type

TTokenUser = record
  User : SID_AND_ATTRIBUTES;
end;
PTokenUser = ^TTokenUser;

TTokenGroups = record
  dwGroupCount : DWORD;
  Groups : array [0..0] of SID_AND_ATTRIBUTES;
end;
PTokenGroups = ^TTokenGroups;

TTokenPrimaryGroup = record
  PrimaryGroup : PSID;
end;
PTokenPrimaryGroup = ^TTokenPrimaryGroup;

(*----------------------------------------------------------------------*
 | GetTokenSids                                                         |
 |                                                                      |
 | Get the user and primary group SID for a token's hande.              |
 |                                                                      |
 | Parameters:                                                          |
 |   hToken : THandle;          The token to query                      |
 |   var pUserSid : PSID        Returns the user SID                    |
 |   var pGroupSid : PSID       Returns the primary group's SID         |
 *----------------------------------------------------------------------*)
procedure GetTokenSids (hToken : THandle; var pUserSid, pGroupSid : PSID);
var
  ptkUser : PTokenUser;
  ptkGroup : PTokenPrimaryGroup;
  ps : PSID;
  dwSize : DWORD;
begin
  pUserSid := Nil;
  pGroupSid := Nil;

  try
    if not GetTokenInformation (hToken, TokenUser, Nil, 0, dwSize) then
      if GetLastError <> ERROR_INSUFFICIENT_BUFFER then
        RaiseLastOSError;

    GetMem (ptkUser, dwSize);   // Get the token's user
    Win32Check (GetTokenInformation (hToken, TokenUser, ptkUser, dwSize, dwSize));

    dwSize := GetLengthSid (ptkUser^.User.Sid);

    GetMem (ps, dwSize);
    try
      Win32Check (CopySid (dwSize, ps, ptkUser^.User.Sid));
      Win32Check (IsValidSID (ps));
    except
      FreeMem (ps);
      raise
    end;
    pUserSid := ps;             // Allocate & save pUserSid

                                // Get the token's primary group
    if not GetTokenInformation (hToken, TokenPrimaryGroup, Nil, 0, dwSize) then
      if GetLastError <> ERROR_INSUFFICIENT_BUFFER then
        RaiseLastOSError;

    GetMem (ptkGroup, dwSize);
    Win32Check (GetTokenInformation (hToken, TokenPrimaryGroup, ptkGroup, dwSize, dwSize));

    dwSize := GetLengthSid (ptkGroup^.PrimaryGroup);

    GetMem (ps, dwSize);
    try
      Win32Check (CopySid (dwSize, ps, ptkGroup^.PrimaryGroup));
      Win32Check (IsValidSID (ps));
    except
      FreeMem (ps);
      raise
    end;
    pGroupSid := ps;            // Allocate & save primary group

  except                        // If there were errors, clear up by
    ReallocMem (pUserSid, 0);   // deleting the allocated SIDs
    ReallocMem (pGroupSid, 0);
    raise
  end
end;

(*----------------------------------------------------------------------*
 | GetThreadSids                                                        |
 |                                                                      |
 | Get the user & primary group SID for the current thread              |
 |                                                                      |
 | Parameters:                                                          |
 |   var pUserSid, pGroupSid : PSID                                     |
 |                                                                      |
 | The function returns boolean                                         |
 *----------------------------------------------------------------------*)
function GetThreadSids (var pUserSid, pGroupSid : PSID) : boolean;
var
  hToken : THandle;
begin
  result := False;
  if OpenThreadToken (GetCurrentThread, TOKEN_QUERY, False, hToken) then
  begin
    GetTokenSids (hToken, pUserSid, pGroupSid);
    Result := True
  end
  else
    if GetLastError <> ERROR_NO_TOKEN then
      RaiseLastOSError
end;

(*----------------------------------------------------------------------*
 | GetProcessSids                                                       |
 |                                                                      |
 | Get the user & primary group SID for the current process             |
 |                                                                      |
 | Parameters:                                                          |
 |   var pUserSid, pGroupSid : PSID                                     |
 |                                                                      |
 | The function returns boolean                                         |
 *----------------------------------------------------------------------*)
function GetProcessSids (var pUserSid, pGroupSid : PSID) : boolean;
var
  hToken : THandle;
begin
  Result := False;
  if OpenProcessToken (GetCurrentProcess, TOKEN_QUERY, hToken) then
  begin
    GetTokenSids (hToken, pUserSid, pGroupSid);
    Result := True
  end
  else
    if GetLastError <> ERROR_NO_TOKEN then
      RaiseLastOSError
end;

(*
function CreateSelfRelativeSD (sd : TSecurityDescriptor) : PSECURITY_DESCRIPTOR;
var
  sdLen : DWORD;
begin
  sdLen := 1024;
  Result := nil;
  try
    repeat
      ReallocMem (result, sdLen);
      if MakeSelfRelativeSD (@sd, result, sdLen) then
        SetLastError (0)
    until GetLastError <> ERROR_INSUFFICIENT_BUFFER;

    if GetLastError <> 0 then
      RaiseLastOSError;

    sdLen := GetSecurityDescriptorLength (result);
    ReallocMem (result, sdLen);
  except
    FreeMem (result);
    raise
  end
end;
*)

(*----------------------------------------------------------------------*
 | InitializeSDFromThreadToken                                          |
 |                                                                      |
 | Initialize an SD, and fill in it's DACL (a clear one!) and it's      |
 | owner and group (from this process or thread).                       |
 |                                                                      |
 | Remember to Free sd.owner & sd.group afterwards.                     |
 |                                                                      |
 | Parameters:                                                          |
 |   var sd : TSecurityDescriptor;              The SD to initialize    |
 |   bDefaulted : Boolean = False;                                      |
 |   bRevertToProcessToken : boolean = TRUE     Use process roken if    |
 |                                              thread token not there! |
 *----------------------------------------------------------------------*)
procedure InitializeSDFromThreadToken (var sd : TSecurityDescriptor; bDefaulted : Boolean = False; bRevertToProcessToken : boolean = TRUE);
var
  pUserSid : PSID;
  pGroupSid : PSID;
begin
  pUserSid := nil;
  pGroupSid := nil;

  Win32Check (InitializeSecurityDescriptor (@sd, SECURITY_DESCRIPTOR_REVISION));
  SetSecurityDescriptorDacl (@sd, True, nil, False);

  if GetThreadSids (pUserSid, pGroupSid) or (bRevertToProcessToken and GetProcessSids (pUserSid, pGroupSid)) then
  try
    if SetSecurityDescriptorOwner (@sd, pUserSid, bDefaulted) then
      Win32Check (SetSecurityDescriptorGroup (@sd, pGroupSid, bDefaulted))
    else
      RaiseLastOSError;

  finally
//---------------------------------------------------------
// CoInitializeSecurity seems to need an absolute SD (not a
// self-relative one) - so we can't free the sids 'til after
// we've called it.
//
//    ReallocMem (pUserSid, 0);
//    ReallocMem (pGroupSid, 0)
  end
end;

end.
