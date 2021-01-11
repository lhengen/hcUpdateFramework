unit lmremutl;

interface

uses lmglobal;

const

//
// Special Values and Constants
//

//
// Mask bits for use with NetRemoteComputerSupports:
//

 SUPPORTS_REMOTE_ADMIN_PROTOCOL  = $00000002;
 SUPPORTS_RPC                    = $00000004;
 SUPPORTS_SAM_PROTOCOL           = $00000008;
 SUPPORTS_UNICODE                = $00000010;
 SUPPORTS_LOCAL                  = $00000020;
 SUPPORTS_ANY                    = $FFFFFFFF;

//
// Flag bits for RxRemoteApi:
//

 NO_PERMISSION_REQUIRED  = $00000001;      // set if use NULL session
 ALLOCATE_RESPONSE       = $00000002;      // set if RxRemoteApi allocates response buffer
 USE_SPECIFIC_TRANSPORT  = $80000000;

//
//  Data Structures
//

type
  TIME_OF_DAY_INFO = record
    tod_elapsedt : Integer;
    tod_msecs : Integer;
    tod_hours : Integer;
    tod_mins : Integer;
    tod_secs : Integer;
    tod_hunds : Integer;
    tod_timezone : Integer;
    tod_tinterval : Integer;
    tod_day : Integer;
    tod_month : Integer;
    tod_year : Integer;
    tod_weekday : Integer;
  end;
  PTIME_OF_DAY_INFO = ^TIME_OF_DAY_INFO;

//
// Function Prototypes
//

function NetRemoteTOD (
  UncServerName : PWideChar;
  var BufferPtr : Pointer): NetAPIStatus; stdcall;

function NetRemoteComputerSupports(
  UncServerName : PWideChar;
  OptionsWanted : Integer;              // Set SUPPORTS_ bits wanted.
  var OptionsSupported : Integer        // Supported features, masked.
): NetAPIStatus; stdcall;

(*
function
RxRemoteApi(
    IN DWORD ApiNumber,
    IN LPCWSTR UncServerName,                    // Required, with \\name.
    IN LPDESC ParmDescString,
    IN LPDESC DataDesc16 OPTIONAL,
    IN LPDESC DataDesc32 OPTIONAL,
    IN LPDESC DataDescSmb OPTIONAL,
    IN LPDESC AuxDesc16 OPTIONAL,
    IN LPDESC AuxDesc32 OPTIONAL,
    IN LPDESC AuxDescSmb OPTIONAL,
    IN DWORD  Flags,
    ...                                         // rest of API's arguments
    ): NetAPIStatus; cdecl;

*)

implementation

function NetRemoteTOD; external 'NETAPI32.DLL';
function NetRemoteComputerSupports; external 'NETAPI32.DLL';

end.
