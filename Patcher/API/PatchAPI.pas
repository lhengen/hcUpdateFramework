unit PatchAPI;

interface

uses
  Windows,
  SysUtils;

const

  //**                                                                                                                                              **//
  //**  The following constants can be combined and used as the OptionFlags                                                                         **//
  //**  parameter in the patch creation apis.                                                                                                       **//
  //**                                                                                                                                              **//
  // CreatePatch Flags...
  PATCH_OPTION_USE_BEST = $00000000; // auto choose best (slower)
{$EXTERNALSYM PATCH_OPTION_USE_BEST}

  PATCH_OPTION_USE_LZX_BEST = $00000003; // auto choose best of LZX
{$EXTERNALSYM PATCH_OPTION_USE_LZX_BEST}
  PATCH_OPTION_USE_LZX_A = $00000001; // normal
{$EXTERNALSYM PATCH_OPTION_USE_LZX_A}
  PATCH_OPTION_USE_LZX_B = $00000002; // better on some x86 binaries
{$EXTERNALSYM PATCH_OPTION_USE_LZX_B}
  PATCH_OPTION_USE_LZX_LARGE = $00000004; // better support for files >8MB
{$EXTERNALSYM PATCH_OPTION_USE_LZX_LARGE}

  PATCH_OPTION_NO_BINDFIX = $00010000; // PE bound imports
{$EXTERNALSYM PATCH_OPTION_NO_BINDFIX}
  PATCH_OPTION_NO_LOCKFIX = $00020000; // PE smashed locks
{$EXTERNALSYM PATCH_OPTION_NO_LOCKFIX}
  PATCH_OPTION_NO_REBASE = $00040000; // PE rebased image
{$EXTERNALSYM PATCH_OPTION_NO_REBASE}
  PATCH_OPTION_FAIL_IF_SAME_FILE = $00080000; // don't create if same
{$EXTERNALSYM PATCH_OPTION_FAIL_IF_SAME_FILE}
  PATCH_OPTION_FAIL_IF_BIGGER = $00100000; // fail if patch is larger than simply compressing new file (slower)
{$EXTERNALSYM PATCH_OPTION_FAIL_IF_BIGGER}
  PATCH_OPTION_NO_CHECKSUM = $00200000; // PE checksum zero
{$EXTERNALSYM PATCH_OPTION_NO_CHECKSUM}
  PATCH_OPTION_NO_RESTIMEFIX = $00400000; // PE resource timestamps
{$EXTERNALSYM PATCH_OPTION_NO_RESTIMEFIX}
  PATCH_OPTION_NO_TIMESTAMP = $00800000; // don't store new file timestamp in patch
{$EXTERNALSYM PATCH_OPTION_NO_TIMESTAMP}
  PATCH_OPTION_SIGNATURE_MD5 = $01000000; // use MD5 instead of CRC32
{$EXTERNALSYM PATCH_OPTION_SIGNATURE_MD5}
  PATCH_OPTION_RESERVED1 = DWORD($80000000); // (used internally)
{$EXTERNALSYM PATCH_OPTION_RESERVED1}
  PATCH_OPTION_VALID_FLAGS = $C0FF0007;
{$EXTERNALSYM PATCH_OPTION_VALID_FLAGS}
  //**                                                                                                                                              **//
  //**  The following flags are used with PATCH_OPTION_DATA SymbolOptionFlags:                                                                      **//
  //**                                                                                                                                              **//
  // Symbol Option Flags
  PATCH_SYMBOL_NO_IMAGEHLP = $00000001; // don't use imagehlp.dll
{$EXTERNALSYM PATCH_SYMBOL_NO_IMAGEHLP}
  PATCH_SYMBOL_NO_FAILURES = $00000002; // don't fail patch due to imagehlp failures
{$EXTERNALSYM PATCH_SYMBOL_NO_FAILURES}
  PATCH_SYMBOL_UNDECORATED_TOO = $00000004; // after matching decorated symbols, try to match remaining by undecorated names
{$EXTERNALSYM PATCH_SYMBOL_UNDECORATED_TOO}
  PATCH_SYMBOL_RESERVED1 = DWORD($80000000); // (used internally)
{$EXTERNALSYM PATCH_SYMBOL_RESERVED1}

  //**                                                                                                                                              **//
  //**  The following flags are used with PATCH_OPTION_DATA ExtendedOptionFlags:                                                                    **//
  //**                                                                                                                                              **//

  PATCH_TRANSFORM_PE_RESOURCE_2 = $00000100; // better handling of PE resources (requires 5.2 or higher applyer)
{$EXTERNALSYM PATCH_TRANSFORM_PE_RESOURCE_2}
  PATCH_TRANSFORM_PE_IRELOC_2 = $00000200; // better handling of PE stripped relocs (requires 5.2 or higher applyer)
{$EXTERNALSYM PATCH_TRANSFORM_PE_IRELOC_2}

  //**                                                                                                                                              **//
  //**  The following constants can be combined and used as the ApplyOptionFlags                                                                    **//
  //**  parameter in the patch apply and test apis.                                                                                                 **//
  //**                                                                                                                                              **//
  // ApplyPatch Flags
  APPLY_OPTION_FAIL_IF_EXACT = $00000001; // don't copy new file
{$EXTERNALSYM APPLY_OPTION_FAIL_IF_EXACT}
  APPLY_OPTION_FAIL_IF_CLOSE = $00000002; // differ by rebase, bind
{$EXTERNALSYM APPLY_OPTION_FAIL_IF_CLOSE}
  APPLY_OPTION_TEST_ONLY = $00000004; // don't create new file
{$EXTERNALSYM APPLY_OPTION_TEST_ONLY}
  APPLY_OPTION_VALID_FLAGS = $00000007;
{$EXTERNALSYM APPLY_OPTION_VALID_FLAGS}

  //**                                                                                                                                              **//
  //**  In addition to standard Win32 error codes, the following error codes may                                                                    **//
  //**  be returned via GetLastError() when one of the patch APIs fails.                                                                            **//
  //**                                                                                                                                              **//
  // CreatePatch error codes
  ERROR_PATCH_ENCODE_FAILURE = DWORD($C00E3101); // create
{$EXTERNALSYM ERROR_PATCH_ENCODE_FAILURE}
  ERROR_PATCH_INVALID_OPTIONS = DWORD($C00E3102); // create
{$EXTERNALSYM ERROR_PATCH_INVALID_OPTIONS}
  ERROR_PATCH_SAME_FILE = DWORD($C00E3103); // create
{$EXTERNALSYM ERROR_PATCH_SAME_FILE}
  ERROR_PATCH_RETAIN_RANGES_DIFFER = DWORD($C00E3104); // create
{$EXTERNALSYM ERROR_PATCH_RETAIN_RANGES_DIFFER}
  ERROR_PATCH_BIGGER_THAN_COMPRESSED = DWORD($C00E3105); // create
{$EXTERNALSYM ERROR_PATCH_BIGGER_THAN_COMPRESSED}
  ERROR_PATCH_IMAGEHLP_FAILURE = DWORD($C00E3106); // create
{$EXTERNALSYM ERROR_PATCH_IMAGEHLP_FAILURE}
  // ApplyPatch error codes
  ERROR_PATCH_DECODE_FAILURE = DWORD($C00E4101); // apply
{$EXTERNALSYM ERROR_PATCH_DECODE_FAILURE}
  ERROR_PATCH_CORRUPT = DWORD($C00E4102); // apply
{$EXTERNALSYM ERROR_PATCH_CORRUPT}
  ERROR_PATCH_NEWER_FORMAT = DWORD($C00E4103); // apply
{$EXTERNALSYM ERROR_PATCH_NEWER_FORMAT}
  ERROR_PATCH_WRONG_FILE = DWORD($C00E4104); // apply
{$EXTERNALSYM ERROR_PATCH_WRONG_FILE}
  ERROR_PATCH_NOT_NECESSARY = DWORD($C00E4105); // apply
{$EXTERNALSYM ERROR_PATCH_NOT_NECESSARY}
  ERROR_PATCH_NOT_AVAILABLE = DWORD($C00E4106); // apply
{$EXTERNALSYM ERROR_PATCH_NOT_AVAILABLE}

type
  //**************************************************************************************************************************************************//
  PATCH_PROGRESS_CALLBACK = function(
    CallbackContext : Pointer;
    CurrentPosition : ULONG;
    MaximumPosition : ULONG) : BOOL; stdcall;
{$EXTERNALSYM PATCH_PROGRESS_CALLBACK}
  TPatchProgressCallback = PATCH_PROGRESS_CALLBACK;

  PPATCH_PROGRESS_CALLBACK = ^PATCH_PROGRESS_CALLBACK;
{$EXTERNALSYM PPATCH_PROGRESS_CALLBACK}
  PPatchProgressCallback = PPATCH_PROGRESS_CALLBACK;
  //**************************************************************************************************************************************************//
  PATCH_SYMLOAD_CALLBACK = function(
    WhichFile : ULONG;
    SymbolFileName : LPCSTR;
    SymType : ULONG;
    SymbolFileCheckSum : ULONG;
    SymbolFileTimeDate : ULONG;
    ImageFileCheckSum : ULONG;
    ImageFileTimeDate : ULONG;
    CallbackContext : Pointer) : BOOL; stdcall;
{$EXTERNALSYM PATCH_SYMLOAD_CALLBACK}
  TPatchSymLoadCallback = PATCH_SYMLOAD_CALLBACK;

  PPATCH_SYMLOAD_CALLBACK = ^PATCH_SYMLOAD_CALLBACK;
{$EXTERNALSYM PPATCH_SYMLOAD_CALLBACK}
  PPatchSymLoadCallback = PPATCH_SYMLOAD_CALLBACK;
  //**************************************************************************************************************************************************//
  PPATCH_IGNORE_RANGE = ^PATCH_IGNORE_RANGE;
{$EXTERNALSYM PPATCH_IGNORE_RANGE}
  _PATCH_IGNORE_RANGE = record
    OffsetInOldFile : ULONG;
    LengthInBytes : ULONG;
  end;
{$EXTERNALSYM _PATCH_IGNORE_RANGE}
  PATCH_IGNORE_RANGE = _PATCH_IGNORE_RANGE;
{$EXTERNALSYM PATCH_IGNORE_RANGE}
  TPatchIgnoreRange = PATCH_IGNORE_RANGE;
  PPatchIgnoreRange = PPATCH_IGNORE_RANGE;
  //**************************************************************************************************************************************************//
  PPATCH_RETAIN_RANGE = ^PATCH_RETAIN_RANGE;
{$EXTERNALSYM PPATCH_RETAIN_RANGE}
  _PATCH_RETAIN_RANGE = record
    OffsetInOldFile : ULONG;
    LengthInBytes : ULONG;
    OffsetInNewFile : ULONG;
  end;
{$EXTERNALSYM _PATCH_RETAIN_RANGE}
  PATCH_RETAIN_RANGE = _PATCH_RETAIN_RANGE;
{$EXTERNALSYM PATCH_RETAIN_RANGE}
  TPatchRetainRange = PATCH_RETAIN_RANGE;
  PPatchRetainRange = PPATCH_RETAIN_RANGE;
  //**************************************************************************************************************************************************//
  PPATCH_OLD_FILE_INFO_A = ^PATCH_OLD_FILE_INFO_A;
{$EXTERNALSYM PPATCH_OLD_FILE_INFO_A}
  _PATCH_OLD_FILE_INFO_A = record
    SizeOfThisStruct : ULONG;
    OldFileName : LPCSTR;
    IgnoreRangeCount : ULONG; // maximum 255
    IgnoreRangeArray : PPATCH_IGNORE_RANGE;
    RetainRangeCount : ULONG; // maximum 255
    RetainRangeArray : PPATCH_RETAIN_RANGE;
  end;
{$EXTERNALSYM _PATCH_OLD_FILE_INFO_A}
  PATCH_OLD_FILE_INFO_A = _PATCH_OLD_FILE_INFO_A;
{$EXTERNALSYM PATCH_OLD_FILE_INFO_A}
  TPatchOldFileInfoA = PATCH_OLD_FILE_INFO_A;
  PPatchOldFileInfoA = PPATCH_OLD_FILE_INFO_A;
  //**************************************************************************************************************************************************//
  PPATCH_OLD_FILE_INFO_W = ^PATCH_OLD_FILE_INFO_W;
{$EXTERNALSYM PPATCH_OLD_FILE_INFO_W}
  _PATCH_OLD_FILE_INFO_W = record
    SizeOfThisStruct : ULONG;
    OldFileName : LPCWSTR;
    IgnoreRangeCount : ULONG; // maximum 255
    IgnoreRangeArray : PPATCH_IGNORE_RANGE;
    RetainRangeCount : ULONG; // maximum 255
    RetainRangeArray : PPATCH_RETAIN_RANGE;
  end;
{$EXTERNALSYM _PATCH_OLD_FILE_INFO_W}
  PATCH_OLD_FILE_INFO_W = _PATCH_OLD_FILE_INFO_W;
{$EXTERNALSYM PATCH_OLD_FILE_INFO_W}
  TPatchOldFileInfoW = PATCH_OLD_FILE_INFO_W;
  PPatchOldFileInfoW = PPATCH_OLD_FILE_INFO_W;
  //**************************************************************************************************************************************************//
  PPATCH_OLD_FILE_INFO_H = ^PATCH_OLD_FILE_INFO_H;
{$EXTERNALSYM PPATCH_OLD_FILE_INFO_H}
  _PATCH_OLD_FILE_INFO_H = record
    SizeOfThisStruct : ULONG;
    OldFileHandle : THandle;
    IgnoreRangeCount : ULONG; // maximum 255
    IgnoreRangeArray : PPATCH_IGNORE_RANGE;
    RetainRangeCount : ULONG; // maximum 255
    RetainRangeArray : PPATCH_RETAIN_RANGE;
  end;
{$EXTERNALSYM _PATCH_OLD_FILE_INFO_H}
  PATCH_OLD_FILE_INFO_H = _PATCH_OLD_FILE_INFO_H;
{$EXTERNALSYM PATCH_OLD_FILE_INFO_H}
  TPatchOldFileInfoH = PATCH_OLD_FILE_INFO_H;
  PPatchOldFileInfoH = PPATCH_OLD_FILE_INFO_H;
  //**************************************************************************************************************************************************//
  PPATCH_OLD_FILE_INFO = ^PATCH_OLD_FILE_INFO;
{$EXTERNALSYM PPATCH_OLD_FILE_INFO}
  _PATCH_OLD_FILE_INFO = record
    SizeOfThisStruct : ULONG;
    Union : record
      case Integer of
        0 : (OldFileNameA : LPCSTR);
        1 : (OldFileNameW : LPCWSTR);
        2 : (OldFileHandle : THandle);
    end;
    IgnoreRangeCount : ULONG; // maximum 255
    IgnoreRangeArray : PPATCH_IGNORE_RANGE;
    RetainRangeCount : ULONG; // maximum 255
    RetainRangeArray : PPATCH_RETAIN_RANGE;
  end;
{$EXTERNALSYM _PATCH_OLD_FILE_INFO}
  PATCH_OLD_FILE_INFO = _PATCH_OLD_FILE_INFO;
{$EXTERNALSYM PATCH_OLD_FILE_INFO}
  TPatchOldFileInfo = PATCH_OLD_FILE_INFO;
  PPatchOldFileInfo = PPATCH_OLD_FILE_INFO;
  //**************************************************************************************************************************************************//
  PPATCH_OPTION_DATA = ^PATCH_OPTION_DATA;
{$EXTERNALSYM PPATCH_OPTION_DATA}
  _PATCH_OPTION_DATA = record
    SizeOfThisStruct : ULONG;
    SymbolOptionFlags : ULONG; // PATCH_SYMBOL_xxx flags
    NewFileSymbolPath : LPCSTR; // always ANSI, never Unicode
    OldFileSymbolPathArray : ^LPCSTR; // array[ OldFileCount ]
    ExtendedOptionFlags : ULONG;
    SymLoadCallback : PATCH_SYMLOAD_CALLBACK;
    SymLoadContext : Pointer;
  end;
{$EXTERNALSYM _PATCH_OPTION_DATA}
  PATCH_OPTION_DATA = _PATCH_OPTION_DATA;
{$EXTERNALSYM PATCH_OPTION_DATA}
  TPatchOptionData = PATCH_OPTION_DATA;
  PPatchOptionData = PPATCH_OPTION_DATA;
  //**************************************************************************************************************************************************//
  //**                                                                                                                                              **//
  //**  Note that PATCH_OPTION_DATA contains LPCSTR paths, and no LPCWSTR (Unicode)                                                                 **//
  //**  path argument is available, even when used with one of the Unicode APIs                                                                     **//
  //**  such as CreatePatchFileW.  This is because the underlying system services                                                                   **//
  //**  for symbol file handling (IMAGEHLP.DLL) only support ANSI file/path names.                                                                  **//
  //**                                                                                                                                              **//
  //**                                                                                                                                              **//
  //**  A note about PATCH_RETAIN_RANGE specifiers with multiple old files:                                                                         **//
  //**                                                                                                                                              **//
  //**  Each old version file must have the same RetainRangeCount, and the same                                                                     **//
  //**  retain range LengthInBytes and OffsetInNewFile values in the same order.                                                                    **//
  //**  Only the OffsetInOldFile values can differ between old files for retain                                                                     **//
  //**  ranges.                                                                                                                                     **//
  //**                                                                                                                                              **//
  //**                                                                                                                                              **//
  //**  The following prototypes are interface for creating patches from files.                                                                     **//
  //**                                                                                                                                              **//
  //**************************************************************************************************************************************************//

//**************************************************************************************************************************************************//
function CreatePatchFileA(
  OldFileName : LPCSTR;
  NewFileName : LPCSTR;
  PatchFileName : LPCSTR;
  OptionFlags : ULONG;
  OptionData : PPatchOptionData) : BOOL; stdcall;
{$EXTERNALSYM CreatePatchFileA}
//**************************************************************************************************************************************************//
function CreatePatchFileW(
  OldFileName : LPCWSTR;
  NewFileName : LPCWSTR;
  PatchFileName : LPCWSTR;
  OptionFlags : ULONG;
  OptionData : PPatchOptionData) : BOOL; stdcall;
{$EXTERNALSYM CreatePatchFileW}
//**************************************************************************************************************************************************//
function CreatePatchFileByHandles(
  OldFileHandle : THandle;
  NewFileHandle : THandle;
  PatchFileHandle : THandle;
  OptionFlags : ULONG;
  OptionData : PPatchOptionData) : BOOL; stdcall;
{$EXTERNALSYM CreatePatchFileByHandles}
//**************************************************************************************************************************************************//

//**************************************************************************************************************************************************//
function CreatePatchFileExA(
  OldFileCount : ULONG; // maximum 255
  OldFileInfoArray : PPatchOldFileInfoA;
  NewFileName : LPCSTR;
  PatchFileName : LPCSTR;
  OptionFlags : ULONG;
  OptionData : PPatchOptionData; // optional
  ProgressCallback : PPatchProgressCallBack;
  CallbackContext : Pointer) : BOOL; stdcall;
{$EXTERNALSYM CreatePatchFileExA}
//**************************************************************************************************************************************************//
function CreatePatchFileExW(
  OldFileCount : ULONG; // maximum 255
  OldFileInfoArray : PPatchOldFileInfoW;
  NewFileName : LPCWSTR;
  PatchFileName : LPCWSTR;
  OptionFlags : ULONG;
  OptionData : PPatchOptionData; // optional
  ProgressCallback : PPatchProgressCallBack;
  CallbackContext : Pointer) : BOOL; stdcall;
{$EXTERNALSYM CreatePatchFileExW}
//**************************************************************************************************************************************************//
function CreatePatchFileByHandlesEx(
  OldFileCount : ULONG; // maximum 255
  OldFileInfoArray : PPatchOldFileInfoH;
  NewFileHandle : THandle;
  PatchFileHandle : THandle;
  OptionFlags : ULONG;
  OptionData : PPatchOptionData; // optional
  ProgressCallback : PPatchProgressCallBack;
  CallbackContext : Pointer) : BOOL; stdcall;
{$EXTERNALSYM CreatePatchFileByHandlesEx}
//**************************************************************************************************************************************************//

//**************************************************************************************************************************************************//
function ExtractPatchHeaderToFileA(
  PatchFileName : LPCSTR;
  PatchHeaderFileName : LPCSTR) : BOOL; stdcall;
{$EXTERNALSYM ExtractPatchHeaderToFileA}
//**************************************************************************************************************************************************//
function ExtractPatchHeaderToFileW(
  PatchFileName : LPCWSTR;
  PatchHeaderFileName : LPCWSTR) : BOOL; stdcall;
{$EXTERNALSYM ExtractPatchHeaderToFileW}
//**************************************************************************************************************************************************//
function ExtractPatchHeaderToFileByHandles(
  PatchFileHandle : THandle;
  PatchHeaderFileHandle : THandle) : BOOL; stdcall;
{$EXTERNALSYM ExtractPatchHeaderToFileByHandles}
//**************************************************************************************************************************************************//

//**************************************************************************************************************************************************//
//
//  The following prototypes are interface for creating new file from old file
//  and patch file.  Note that it is possible for the TestApply API to succeed
//  but the actual Apply to fail since the TestApply only verifies that the
//  old file has the correct CRC without actually applying the patch.  The
//  TestApply API only requires the patch header portion of the patch file,
//  but its CRC must be corrected.
//
//**************************************************************************************************************************************************//

//**************************************************************************************************************************************************//
function TestApplyPatchToFileA(
  PatchFileName : LPCSTR;
  OldFileName : LPCSTR;
  ApplyOptionFlags : ULONG) : BOOL; stdcall;
{$EXTERNALSYM TestApplyPatchToFileA}
//**************************************************************************************************************************************************//
function TestApplyPatchToFileW(
  PatchFileName : LPCWSTR;
  OldFileName : LPCWSTR;
  ApplyOptionFlags : ULONG) : BOOL; stdcall;
{$EXTERNALSYM TestApplyPatchToFileW}
//**************************************************************************************************************************************************//
function TestApplyPatchToFileByHandles(
  PatchFileHandle : THandle; // requires GENERIC_READ access
  OldFileHandle : THandle; // requires GENERIC_READ access
  ApplyOptionFlags : ULONG) : BOOL; stdcall;
{$EXTERNALSYM TestApplyPatchToFileByHandles}
//**************************************************************************************************************************************************//

//**************************************************************************************************************************************************//
function ApplyPatchToFileA(
  PatchFileName : LPCSTR;
  OldFileName : LPCSTR;
  NewFileName : LPCSTR;
  ApplyOptionFlags : ULONG) : BOOL; stdcall;
{$EXTERNALSYM ApplyPatchToFileA}
//**************************************************************************************************************************************************//
function ApplyPatchToFileW(
  PatchFileName : LPCWSTR;
  OldFileName : LPCWSTR;
  NewFileName : LPCWSTR;
  ApplyOptionFlags : ULONG) : BOOL; stdcall;
{$EXTERNALSYM ApplyPatchToFileW}
//**************************************************************************************************************************************************//
function ApplyPatchToFileByHandles(
  PatchFileHandle : THandle; // requires GENERIC_READ access
  OldFileHandle : THandle; // requires GENERIC_READ access
  NewFileHandle : THandle; // requires GENERIC_READ | GENERIC_WRITE
  ApplyOptionFlags : ULONG) : BOOL; stdcall;
{$EXTERNALSYM ApplyPatchToFileByHandles}
//**************************************************************************************************************************************************//

//**************************************************************************************************************************************************//
function ApplyPatchToFileExA(
  PatchFileName : LPCSTR;
  OldFileName : LPCSTR;
  NewFileName : LPCSTR;
  ApplyOptionFlags : ULONG;
  ProgressCallback : PPatchProgressCallBack;
  CallbackContext : Pointer) : BOOL; stdcall;
{$EXTERNALSYM ApplyPatchToFileExA}
//**************************************************************************************************************************************************//
function ApplyPatchToFileExW(
  PatchFileName : LPCWSTR;
  OldFileName : LPCWSTR;
  NewFileName : LPCWSTR;
  ApplyOptionFlags : ULONG;
  ProgressCallback : PPatchProgressCallBack;
  CallbackContext : Pointer) : BOOL; stdcall;
{$EXTERNALSYM ApplyPatchToFileExW}
//**************************************************************************************************************************************************//
function ApplyPatchToFileByHandlesEx(
  PatchFileHandle : THandle; // requires GENERIC_READ access
  OldFileHandle : THandle; // requires GENERIC_READ access
  NewFileHandle : THandle; // requires GENERIC_READ | GENERIC_WRITE
  ApplyOptionFlags : ULONG;
  ProgressCallback : PPatchProgressCallBack;
  CallbackContext : Pointer) : BOOL; stdcall;
{$EXTERNALSYM ApplyPatchToFileByHandlesEx}
//**************************************************************************************************************************************************//

//**************************************************************************************************************************************************//
  //
  //  The following prototypes provide a unique patch "signature" for a given
  //  file.  Consider the case where you have a new foo.dll and the machines
  //  to be updated with the new foo.dll may have one of three different old
  //  foo.dll files.  Rather than creating a single large patch file that can
  //  update any of the three older foo.dll files, three separate smaller patch
  //  files can be created and "named" according to the patch signature of the
  //  old file.  Then the patch applyer application can determine at runtime
  //  which of the three foo.dll patch files is necessary given the specific
  //  foo.dll to be updated.  If patch files are being downloaded over a slow
  //  network connection (Internet over a modem), this signature scheme provides
  //  a mechanism for choosing the correct single patch file to download at
  //  application time thus decreasing total bytes necessary to download.
  //
//**************************************************************************************************************************************************//

//**************************************************************************************************************************************************//
function GetFilePatchSignatureA(
  FileName : LPCSTR;
  OptionFlags : ULONG;
  OptionData : Pointer;
  IgnoreRangeCount : ULONG;
  IgnoreRangeArray : PPatchIgnoreRange;
  RetainRangeCount : ULONG;
  RetainRangeArray : PPatchRetainRange;
  SignatureBufferSize : ULONG;
  SignatureBuffer : Pointer) : BOOL; stdcall;
{$EXTERNALSYM GetFilePatchSignatureA}
//**************************************************************************************************************************************************//
function GetFilePatchSignatureW(
  FileName : LPCWSTR;
  OptionFlags : ULONG;
  OptionData : Pointer;
  IgnoreRangeCount : ULONG;
  IgnoreRangeArray : PPatchIgnoreRange;
  RetainRangeCount : ULONG;
  RetainRangeArray : PPatchRetainRange;
  SignatureBufferSizeInBytes : ULONG;
  SignatureBuffer : Pointer) : BOOL; stdcall;
{$EXTERNALSYM GetFilePatchSignatureW}
//**************************************************************************************************************************************************//
function GetFilePatchSignatureByHandle(
  FileHandle : THandle;
  OptionFlags : ULONG;
  OptionData : Pointer;
  IgnoreRangeCount : ULONG;
  IgnoreRangeArray : PPatchIgnoreRange;
  RetainRangeCount : ULONG;
  RetainRangeArray : PPatchRetainRange;
  SignatureBufferSize : ULONG;
  SignatureBuffer : Pointer) : BOOL; stdcall;
{$EXTERNALSYM GetFilePatchSignatureByHandle}
//**************************************************************************************************************************************************//
implementation

function CreatePatchFileA; external 'mspatchc.dll' name 'CreatePatchFileA';
function CreatePatchFileW; external 'mspatchc.dll' name 'CreatePatchFileW';
function CreatePatchFileByHandles; external 'mspatchc.dll' name 'CreatePatchFileByHandles';

function CreatePatchFileExA; external 'mspatchc.dll' name 'CreatePatchFileExA';
function CreatePatchFileExW; external 'mspatchc.dll' name 'CreatePatchFileExW';
function CreatePatchFileByHandlesEx; external 'mspatchc.dll' name 'CreatePatchFileByHandlesEx';

function ExtractPatchHeaderToFileA; external 'mspatchc.dll' name 'ExtractPatchHeaderToFileA';
function ExtractPatchHeaderToFileW; external 'mspatchc.dll' name 'ExtractPatchHeaderToFileW';
function ExtractPatchHeaderToFileByHandles; external 'mspatchc.dll' name 'ExtractPatchHeaderToFileByHandles';

function TestApplyPatchToFileA; external 'mspatcha.dll' name 'TestApplyPatchToFileA';
function TestApplyPatchToFileW; external 'mspatcha.dll' name 'TestApplyPatchToFileW';
function TestApplyPatchToFileByHandles; external 'mspatcha.dll' name 'TestApplyPatchToFileByHandles';

function ApplyPatchToFileA; external 'mspatcha.dll' name 'ApplyPatchToFileA';
function ApplyPatchToFileW; external 'mspatcha.dll' name 'ApplyPatchToFileW';
function ApplyPatchToFileByHandles; external 'mspatcha.dll' name 'ApplyPatchToFileByHandles';

function ApplyPatchToFileExA; external 'mspatcha.dll' name 'ApplyPatchToFileExA';
function ApplyPatchToFileExW; external 'mspatcha.dll' name 'ApplyPatchToFileExW';
function ApplyPatchToFileByHandlesEx; external 'mspatcha.dll' name 'ApplyPatchToFileByHandlesEx';

function GetFilePatchSignatureA; external 'mspatcha.dll' name 'GetFilePatchSignatureA';
function GetFilePatchSignatureW; external 'mspatcha.dll' name 'GetFilePatchSignatureW';
function GetFilePatchSignatureByHandle; external 'mspatcha.dll' name 'GetFilePatchSignatureByHandle';

end.

