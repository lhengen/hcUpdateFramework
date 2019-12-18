{
//***************************************************************************************************************//
 Unit Name: uPatcher
 Author:    Glen Vlotman
 Date:      31 December 2011
 Version:   0.0.0.1
 Changed:   N/A
 TO DO:     Implement symbol file loading functionality.

 Requires:  PatchAPI.pas (the raw API definitions for the PatchAPI interface)
            for creating patches - mspatchc.dll (should ideally be located in application directory)
            for applying patches - mspatcha.dll (should already be on the destination pc in <windows directory>\system32)

 Description:
 This unit provides the functionality to create and apply binary patches (also known as deltas) using the Delta Compression
 Application Programming Interfaces provided by Microsoft (for more information on how binary patching works, go to this URL:
 http://msdn.microsoft.com/en-us/library/bb267312(VS.85).aspx). It hides the raw PatchAPI interface from the user and in effect makes
 it easier to create and apply binary patches.

 Technical Stuff:
 Types:
   TPatchCreateOption - Valid create patch flags.
   TPatchApplyOptions - Set of TPatchCreateOption.
   TPatchCreateOptions_Compression - Valid compression option flags for creating patches. This is a subset of TPatchCreateOption.
   TPatchCreateOptions_Additional - Additional create patch option flags for creating patches. This is a subset of TPatchCreateOption.
   TPatchApplyOption - Valid apply patch flags.
   TPatchApplyOptions - Set of TPatchApplyOption.
   TPatchCreateErrorCode - Error codes when creating patch files.
   TPatchApplyErrorCode - Error codes when applying patch files.
   TPatcherFileMode - Patcher file mode (use AnsiString, Widestring or THandle).

 Constants:
   Descriptions_TPatchCreateOption - Descriptions for the TPatchCreateOption flags.
   Descriptions_TPatchApplyOption - Descriptions for the TPatchApplyOption flags.
   Descriptions_TPatchCreateErrorCode - Descriptions for TPatchCreateErrorCode.
   Descriptions_TPatchApplyOption - Descriptions for TPatchApplyErrorCode.

 Object Events:
   TOnPatchProgress - Fires when part of an apply or create patch operation has completed
     Parameters
       ASender - The (TPatcher) object which fired this event.
       ACurrentPosition - CONSTANT - The current position of the patching process.
       AMaximumPosition - CONSTANT - The maximum position of the patching process.
       ACanContinue - VARIABLE - Should the process continue.

   TOnPatchesComplete - Fires when TPatchItem object(s) have been processed, irrespective of whether the patch operation(s)
                        were successful or not
     Parameters
       ASender - The (TPatcher) object which fired this event.
       AStatusCode - CONSTANT - Status code indicating whether the patch operation(s) were a success ( 0 ) or not ( > 0 )
       AStatusMessage - CONSTANT - Status message (blank if AStatusCode = 0).

   TOnPatchFileBegin - Fires when a TPatchItem is about to have a patch operation applied to it.
     Parameters
       ASender - The (TPatcher) object which fired this event.
       APatchItem  - The TPatchItem object which is going to be used.
       APatchItemNumber - CONSTANT - The current position in the list of TPatchItem objects of the APatchItem parameter.
       APatchItemCount - CONSTANT - The total number of TPatchItem objects that will be processed.
       AContinueIfError - VARIABLE - Indicates whether the patching operation(s) should continue if there is an error.

   TOnPatchFileEnd - Fires after a TPatchItem has had a patch operation applied to it.
     Parameters
       ASender - The (TPatcher) object which fired this event.
       APatchItem  - The TPatchItem object which is going to be used.
       APatchItemNumber - CONSTANT - The current position in the list of TPatchItem objects of the APatchItem parameter.
       APatchItemCount - CONSTANT - The total number of TPatchItem objects that will be processed.

 Exceptions:
   EPatcherException

 Helper Classes:
   PatcherHelper - Miscellaneous helper functions pertaining to the TPatcher object and PatchAPI interface

 Objects:
   TPatchItem - Holds information about a file which is going to be patched.
     Constructor(s)
       Create(<PatchFileExtension>, <PatchFilePath>)
       Create(<PatchFileExtension>, <PatchFilePath>, <OldFileVersion>, <NewFileVersion>, <PatchFileName>)
     Properties
       OldFileVersion (Read/Write) - The old file version
       NewFileVersion (Read/Write) - The new file version
       PatchFileName (Read/Write) - The name of the patch file

   TPatcher - Allows for creating and applying binary patches.
     Methods
       AddFileToPatch - Adds a file to be operated on.
         Parameters
           AOldFileVersion - string
           ANewFileVersion - string
           APatchFileName - string
       AddAdditionalCreatePatchFlag - Add a create patch flag.
         Parameters OVERLOAD ONE
           ACreatePatchFlag - TPatchCreateOption
           ARaiseOnDuplicateFlag - Boolean
         Parameters OVERLOAD TWO
           ACreatePatchFlag - TPatchCreateOption
       AddApplyPatchOptionFlag - Add an apply patch flag.
         Parameters OVERLOAD ONE
           AApplyPatchOptionFlag - TPatchApplyOption
           ARaiseOnDuplicateFlag - Boolean
         Parameters OVERLOAD TWO
           AApplyPatchOptionFlag - TPatchApplyOption
       SetCompressionMode - Change the compression mode of the patch action.
         Parameters
           ACompressionMode - TPatchCreateOptions_Compression
       CreatePatches - Create the patch files for the list of TPatchItem objects.
         Parameters
           None
       ApplyPatches - Applies the patch files for the list of TPatchItem objects.
         Parameters
           None
       TestApplyPatches [NOT YET IMPLEMENTED!!!!!]- Test the patch files against the list of TPatchItem objects.
         Parameters
           None
       ResetPatchData - Reset the TPatcher object's properties.
         Parameters
           AClearEventsAsWell - Boolean
       RemovePatchItemAtIndex - Removes a TPatchItem from the list of items at the specified index.
         Parameters
           AIndex - Integer
     Properties
       AlwaysRaiseExceptions - Boolean
       FileMode (Read/Write) - TPatcherFileMode
       PatchFileExtension (Read/Write) - string
       PatchFilePath (Read/Write) - string
       Items[Index] (Readonly ) - TPatchItem
       CreatePatchCompressionMode (Readonly) - TPatchCreateOptions_Compression
       CreatePatchAdditionalFlags (Readonly) - TPatchCreateOptions_Additional
       ApplyPatchOptions (Readonly) - TPatchApplyOptions
       PatchItemCount (Readonly) - Integer
       OnPatchProgress (Read/Write) - TOnPatchProgress
       OnPatchesComplete (Read/Write) - TOnPatchesComplete
       OnPatchFileBegin (Read/Write) - TOnPatchFileBegin
       OnPatchFileEnd (Read/Write) - TOnPatchFileBegin

//***************************************************************************************************************//
}

unit uPatcher;

interface

uses
  Windows,
  SysUtils,
  Classes,
  TypInfo,
  Contnrs,
  PatchAPI;

type
  TPatchCreateOption = (
    pcoUseBest, // = PATCH_OPTION_USE_BEST
    pcoUseLZX_A, // = PATCH_OPTION_USE_LZX_A
    pcoUseLZX_B, // = PATCH_OPTION_USE_LZX_B
    pcoUseBestLZX, // = PATCH_OPTION_USE_LZX_BEST
    pcoUseLZX_Large, // = PATCH_OPTION_USE_LZX_LARGE
    pcoNoBindFix, // = PATCH_OPTION_NO_BINDFIX
    pcoNoLockFix, // = PATCH_OPTION_NO_LOCKFIX
    pcoNoRebase, // = PATCH_OPTION_NO_REBASE
    pcoFailIfSameFile, // = PATCH_OPTION_FAIL_IF_SAME_FILE
    pcoFailIfBigger, // = PATCH_OPTION_FAIL_IF_BIGGER
    pcoNoChecksum, // = PATCH_OPTION_NO_CHECKSUM,
    pcoNoResourceTimeStampFix, // = PATCH_OPTION_NO_RESTIMEFIX
    pcoNoTimeStamp, // = PATCH_OPTION_NO_TIMESTAMP
    pcoUseSignatureMD5, // = PATCH_OPTION_SIGNATURE_MD5
    pcoReserved1, // = PATCH_OPTION_RESERVED1
    pcoValidFlags // = PATCH_OPTION_VALID_FLAGS
    );
  TPatchCreateOptions_Compression = pcoUseBest..pcoUseLZX_Large;
  TPatchCreateOptions_Additional = set of pcoNoBindFix..pcoValidFlags;
const
  Descriptions_TPatchCreateOption : array[Low(TPatchCreateOption)..High(TPatchCreateOption)] of string = (
    'Auto-choose best of LZX_A or LZX_B (slower). Equivalent to pcoUseBestLZX.',
    'Use standard LZX compression.',
    'Use alternate LZX compression. Better on some x86 binaries.',
    'Auto-choose best of LZX_A or LZX_B (slower). Equivalent to pcoUseBest.',
    'Better support for files larger than 8 MB.',
    'Don'#39't pre-process PE bound imports.',
    'Don'#39't repair disabled lock prefixes in source PE file.',
    'Don'#39't pre-process PE rebase information.',
    'Don'#39't create a delta if source file and target are the same or differ only by normalization.',
    'Fail if delta is larger than simply compressing the target without comparison to the source file. Setting this flag makes the Create process slower.',
    'Set PE checksum to zero.',
    'Don'#39't pre-process PE resource timestamps.',
    'Don'#39't store a timestamp in delta.',
    'Use MD5 instead of CRC32 in signature. (reserved for future use)',
    'Reserved.',
    'The logical OR of all valid delta creation flags.'
    );

type
  TPatchApplyOption = (
    paoFailIfExact, // = APPLY_OPTION_FAIL_IF_EXACT
    paoFailIfClose, // = APPLY_OPTION_FAIL_IF_CLOSE
    paoTestOnly, // = APPLY_OPTION_TEST_ONLY
    paoValidFlags // = APPLY_OPTION_VALID_FLAGS
    );
  TPatchApplyOptions = set of TPatchApplyOption;
const
  Descriptions_TPatchApplyOption : array[Low(TPatchApplyOption)..High(TPatchApplyOption)] of string = (
    'If the source file and the target are the same, return a failure and don'#39't create the target.',
    'If the source file and the target differ by only rebase and bind information (that is, they have the same normalized signature), return a failure and don'#39't create the target.',
    'Don'#39't create the target.',
    'The logical OR of all valid patch apply flags.'
    );

type
  TPatchCreateErrorCode = (
    pcecEncodeFailure, // = ERROR_PATCH_ENCODE_FAILURE
    pcecInvalidOptions, // = ERROR_PATCH_INVALID_OPTIONS
    pcecSameFile, // = ERROR_PATCH_SAME_FILE
    pcecRetainRangesDiffer, // = ERROR_PATCH_RETAIN_RANGES_DIFFER
    pcecBiggerThanCompressed, // = ERROR_PATCH_BIGGER_THAN_COMPRESSED
    pcecImageHlpFailure, // = ERROR_PATCH_IMAGEHLP_FAILURE
    pcecUnknown
    );
const
  Descriptions_TPatchCreateErrorCode : array[Low(TPatchCreateErrorCode)..High(TPatchCreateErrorCode)] of string = (
    'Generic encoding failure. Could not create delta.',
    'Invalid options were specified.',
    'The source file and target are the same.',
    'Retain ranges specified in multiple source files are different.',
    'The delta is larger than simply compressing the target without comparison to the source file. This error is returned only if the pcoFailIfBigger flag is set.',
    'Could not obtain symbols.',
    ''
    );

type
  TPatchApplyErrorCode = (
    paecDecodeFailure, // = ERROR_PATCH_DECODE_FAILURE
    paecCorrupt, // = ERROR_PATCH_CORRUPT
    paecNewerFormat, // = ERROR_PATCH_NEWER_FORMAT
    paecWrongFile, // = ERROR_PATCH_WRONG_FILE
    paecNotNecessary, // = ERROR_PATCH_NOT_NECESSARY
    paecNotAvailable, // = ERROR_PATCH_NOT_AVAILABLE
    paecUnknown // Unknown exception
    );
const
  Descriptions_TPatchApplyErrorCode : array[Low(TPatchApplyErrorCode)..High(TPatchApplyErrorCode)] of string = (
    'Decode failure of the delta.',
    'The delta is corrupt.',
    'The delta was created using a compression algorithm that is not compatible with the source file.',
    'The delta is not applicable to the source file.',
    'The source file and target are the same, or they differ only by normalization. This error is returned only if the pcoFailIfSameFile flag is set.',
    'Delta consists of only an extracted header and an ApplyPatchToFile function is called instead of a TestApplyPatchToFile function.',
    ''
    );

  // Patcher file mode...
type
  TPatcherFileMode = (
    psmAnsi,
    psmUnicode,
    psmHandle);

  // Patcher Exceptions...
type
  EPatcherException = class(Exception)
  end;

type
  TPatchItem = class;

  TOnPatchProgress = procedure(
    ASender : TObject;
    const ACurrentPosition : LongWord;
    const AMaximumPosition : LongWord;
    var ACanContinue : LongBool) of object;

  TOnPatchesComplete = procedure(
    ASender : TObject;
    const AStatusCode : LongWord;
    const AStatusMessage : string) of object;

  TOnPatchFileBegin = procedure(
    ASender : TObject;
    APatchItem : TPatchItem;
    const APatchItemNumber : Integer;
    const APatchItemCount : Integer;
    var AContinueIfError : Boolean) of object;

  TOnPatchFileEnd = procedure(
    ASender : TObject;
    APatchItem : TPatchItem;
    const APatchItemNumber : Integer;
    const APatchItemCount : Integer) of object;

  TPatchItem = class(TObject)
  private
    FPatchFileExtension : string;
    FPatchFilePath : string;
    FOldFileName : string;
    FNewFileName : string;
    FPatchFileName : string;
    function GetPatchFileName : string;
  protected
    constructor Create; overload;
  public
    constructor Create(
      const APatchFileExtension : string;
      const APatchFilePath : string); overload;
    constructor Create(
      const APatchFileExtension : string;
      const APatchFilePath : string;
      const AOldFileName : string;
      const ANewFileName : string;
      const APatchFilename : string); overload;
    property OldFileName : string read FOldFileName write FOldFileName;
    property NewFileName : string read FNewFileName write FNewFileName;
    property PatchFileName : string read FPatchFileName write FNewFileName;
  end;

  TPatcher = class(TObject)
  private
    FOnPatchProgress : TOnPatchProgress;
    FOnPatchesComplete : TOnPatchesComplete;
    FOnPatchFileBegin : TOnPatchFileBegin;
    FOnPatchFileEnd : TOnPatchFileEnd;
  private
    FAlwaysRaiseExceptions : Boolean;
    FPatchFileExtension : string;
    FPatchFilePath : string;
    FPatchList : TObjectList;
    FFileMode : TPatcherFileMode;
    FCreatePatchCompressionMode : TPatchCreateOptions_Compression;
    FCreatePatchAdditionalFlags : TPatchCreateOptions_Additional;
    FApplyPatchOptions : TPatchApplyOptions;

    function GetPatchItemCount : Integer;
    function GetItem(AIndex : Integer) : TPatchItem;

    procedure CreatePatchesAnsi;
    procedure CreatePatchesWide;
    procedure ApplyPatchesAnsi;
    procedure ApplyPatchesWide;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddFileToPatch(
      const AOldFileVersion : string;
      const ANewFileVersion : string;
      const APatchFilename : string);

    procedure AddAdditionalCreatePatchFlag(
      const ACreatePatchFlag : TPatchCreateOption;
      const ARaiseOnDuplicateFlag : Boolean); overload;
    procedure AddAdditionalCreatePatchFlag(
      const ACreatePatchFlag : TPatchCreateOption); overload;

    procedure AddApplyPatchOptionFlag(
      const AApplyPatchOptionFlag : TPatchApplyOption); overload;
    procedure AddApplyPatchOptionFlag(
      const AApplyPatchOptionFlag : TPatchApplyOption;
      const ARaiseOnDuplicateFlag : Boolean); overload;

    procedure SetCompressionMode(const ACompressionMode : TPatchCreateOptions_Compression);

    procedure CreatePatches;
    procedure ApplyPatches;
    procedure TestApplyPatches;
    procedure ResetPatchData(const AClearEventsAsWell : Boolean);
    procedure RemovePatchItemAtIndex(const AIndex : Integer);

    property AlwaysRaiseExceptions : Boolean read FAlwaysRaiseExceptions write FAlwaysRaiseExceptions;
    property FileMode : TPatcherFileMode read FFileMode write FFileMode;
    property PatchFileExtension : string read FPatchFileExtension write FPatchFileExtension;
    property PatchFilePath : string read FPatchFilePath write FPatchFilePath;
    property Items[Index : Integer] : TPatchItem read GetItem;

    property CreatePatchCompressionMode : TPatchCreateOptions_Compression read FCreatePatchCompressionMode;
    property CreatePatchAdditionalFlags : TPatchCreateOptions_Additional read FCreatePatchAdditionalFlags;
    property ApplyPatchOptions : TPatchApplyOptions read FApplyPatchOptions;
    property PatchItemCount : Integer read GetPatchItemCount;

    property OnPatchProgress : TOnPatchProgress read FOnPatchProgress write FOnPatchProgress;
    property OnPatchesComplete : TOnPatchesComplete read FOnPatchesComplete write FOnPatchesComplete;
    property OnPatchFileBegin : TOnPatchFileBegin read FOnPatchFileBegin write FOnPatchFileBegin;
    property OnPatchFileEnd : TOnPatchFileEnd read FOnPatchFileEnd write FOnPatchFileEnd;
  end;

  PatcherHelper = class
  public
    class function EnumTypeToString(
      const ATypeInfoPointer : PTypeInfo;
      const AIntegerOfEnum : Integer) : string;

    class function PatchCreateFlagToString(
      const APatchCreateFlag : TPatchCreateOption) : string;

    class function StringToPatchCreateFlag(
      const APatchCreateFlagString : string) : TPatchCreateOption;

    class function PatchFileModeToString(
      const APatcherFileMode : TPatcherFileMode) : string;
    class function StringToPatchFileMode(
      const APatcherFileModeString : string) : TPatcherFileMode;

    class function PatchApplyOptionFlagToString(
      const APatchApplyOptionFlag : TPatchApplyOption) : string;

    class function StringToPatchApplyOptionFlag(
      const APatchApplyOptionFlagString : string) : TPatchApplyOption;

    class function PatchCreateFlagToAPICode(
      const APatchCreateFlag : TPatchCreateOption) : ULONG;

    class function PatchCreateOptionsToULONG(
      const APatchCreateCompression : TPatchCreateOptions_Compression = pcoUseBest;
      const APatchCreateAdditional : TPatchCreateOptions_Additional = []) : ULONG;

    class function PatchApplyFlagToAPICode(
      const APatchApplyFlag : TPatchApplyOption) : ULONG;

    class function APICodeToPatchApplyErrorCode(
      const AAPICode : ULONG) : TPatchApplyErrorCode;

    class function APICodeToPatchCreateErrorCode(
      const AAPICode : ULONG) : TPatchCreateErrorCode;

    class function PatchApplyOptionsToULONG(
      const APatchApplyOptions : TPatchApplyOptions = []) : ULONG;
  end;

implementation

uses
  Forms,
  Math;

function MyPatchCreateApplyCallback(
  CallbackContext : Pointer;
  CurrentPosition : LongWord;
  MaximumPosition : LongWord) : LongBool; stdcall;
var
  LPatcher : TPatcher;
  LCanContinue : LongBool;
begin
  LCanContinue := True;
  LPatcher := TPatcher(CallbackContext);
  if Assigned(LPatcher.OnPatchProgress) then
  begin
    LPatcher.OnPatchProgress(
      LPatcher,
      CurrentPosition,
      MaximumPosition,
      LCanContinue);
  end;
  Result := LCanContinue;
end;

{ TPatcher }

procedure TPatcher.AddAdditionalCreatePatchFlag(
  const ACreatePatchFlag : TPatchCreateOption;
  const ARaiseOnDuplicateFlag : Boolean);
begin
  if (ACreatePatchFlag in CreatePatchAdditionalFlags) then
  begin
    if ARaiseOnDuplicateFlag then
      raise EPatcherException.Create(
        Format('Flag [%s] already exists in the CreatePatchAdditionalFlags property.',
        [PatcherHelper.PatchCreateFlagToString(ACreatePatchFlag)]));
  end
  else
  begin
    FCreatePatchAdditionalFlags := FCreatePatchAdditionalFlags + [ACreatePatchFlag];
  end;
end;

procedure TPatcher.AddAdditionalCreatePatchFlag(
  const ACreatePatchFlag : TPatchCreateOption);
begin
  AddAdditionalCreatePatchFlag(ACreatePatchFlag, AlwaysRaiseExceptions);
end;

procedure TPatcher.AddApplyPatchOptionFlag(
  const AApplyPatchOptionFlag : TPatchApplyOption);
begin
  AddApplyPatchOptionFlag(AApplyPatchOptionFlag, AlwaysRaiseExceptions);
end;

procedure TPatcher.AddApplyPatchOptionFlag(
  const AApplyPatchOptionFlag : TPatchApplyOption;
  const ARaiseOnDuplicateFlag : Boolean);
begin
  if (AApplyPatchOptionFlag in ApplyPatchOptions) then
  begin
    if ARaiseOnDuplicateFlag then
      raise EPatcherException.Create(
        Format('Flag [%s] already exists in the ApplyPatchOptions property.',
        [PatcherHelper.PatchApplyOptionFlagToString(AApplyPatchOptionFlag)]));
  end
  else
  begin
    FApplyPatchOptions := FApplyPatchOptions + [AApplyPatchOptionFlag];
  end;
end;

procedure TPatcher.AddFileToPatch(
  const AOldFileVersion : string;
  const ANewFileVersion : string;
  const APatchFilename : string);
begin
  FPatchList.Add(
    TPatchItem.Create(
    PatchFileExtension,
    PatchFilePath,
    AOldFileVersion,
    ANewFileVersion,
    APatchFilename));
end;

procedure TPatcher.ApplyPatches;
begin
  case FileMode of
    psmAnsi : ApplyPatchesAnsi;
    psmUnicode : ApplyPatchesWide;
  else
    begin
      raise EPatcherException.Create('Apply Patch To File mode not implemented yet [' +
        PatcherHelper.EnumTypeToString(
        TypeInfo(TPatcherFileMode),
        Integer(FileMode)) + ']');
    end;
  end;
end;

procedure TPatcher.ApplyPatchesAnsi;
var
  LOldFile : AnsiString;
  LNewFile : AnsiString;
  LPatchFile : AnsiString;
  LApplyPatchOptions : ULONG;
  LOld : TPatchOldFileInfoA;
  LIdx : Integer;
  LPatchItem : TPatchItem;
  LApplyPatchResult : LongBool;
  LContinueIfError : Boolean;
  LError : Cardinal;
  LErrorMessage : string;
begin
  LError := 0;
  LErrorMessage := '';
  try
    try
      LContinueIfError := not AlwaysRaiseExceptions;
      LApplyPatchOptions := PatcherHelper.PatchApplyOptionsToULONG(ApplyPatchOptions);
      if PatchItemCount = 0 then
        raise EPatcherException.Create('No patch items to patch.');
      for LIdx := 0 to PatchItemCount - 1 do
      begin
        LOld.SizeOfThisStruct := 0;
        LOld.OldFileName := nil;
        LOld.IgnoreRangeCount := 0;
        LOld.IgnoreRangeArray := nil;
        LOld.RetainRangeCount := 0;
        LOld.RetainRangeArray := nil;

        LPatchItem := TPatchItem(FPatchList.Items[LIdx]);

        if Assigned(OnPatchFileBegin) then
        begin
          OnPatchFileBegin(
            Self,
            LPatchItem,
            LIdx + 1,
            PatchItemCount,
            LContinueIfError);
        end;

        LPatchFile := LPatchItem.PatchFileName;
        LOldFile := LPatchItem.OldFileName;
        LNewFile := LPatchItem.NewFileName;

        LApplyPatchResult := ApplyPatchToFileExA(
          Pointer(LPatchFile),
          Pointer(LOldFile),
          Pointer(LNewFile),
          LApplyPatchOptions,
          @MyPatchCreateApplyCallback,
          Self);
        if LApplyPatchResult <> True then
        begin
          LError := GetLastError;
          LErrorMessage := Descriptions_TPatchApplyErrorCode[PatcherHelper.APICodeToPatchApplyErrorCode(LError)];
          if LErrorMessage = '' then
            LErrorMessage := SysErrorMessage(LError);
          if not (LContinueIfError) then
            raise EPatcherException.Create(LErrorMessage);
        end;
        if Assigned(OnPatchFileEnd) then
        begin
          OnPatchFileEnd(
            Self,
            LPatchItem,
            LIdx + 1,
            PatchItemCount);
        end;
      end;
    except
      on E : Exception do
      begin
        LError := 1;
        LErrorMessage := E.ClassName + ' caught with message: ' + E.Message;
        if AlwaysRaiseExceptions then
        begin
          raise EPatcherException.Create(LErrorMessage);
        end;
      end;
    end;
  finally
    if Assigned(OnPatchesComplete) then
    begin
      OnPatchesComplete(
        Self,
        LError,
        LErrorMessage);
    end;
  end;
end;

procedure TPatcher.ApplyPatchesWide;
var
  LOldFile : WideString;
  LNewFile : WideString;
  LPatchFile : WideString;
  LApplyPatchOptions : ULONG;
  LIdx : Integer;
  LPatchItem : TPatchItem;
  LApplyPatchResult : LongBool;
  LContinueIfError : Boolean;
  LError : Cardinal;
  LErrorMessage : string;
begin
  LError := 0;
  LErrorMessage := '';
  try
    try
      LContinueIfError := not AlwaysRaiseExceptions;
      LApplyPatchOptions := PatcherHelper.PatchApplyOptionsToULONG(ApplyPatchOptions);
      if PatchItemCount = 0 then
        raise EPatcherException.Create('No patch items to patch.');
      for LIdx := 0 to PatchItemCount - 1 do
      begin
        LPatchItem := TPatchItem(FPatchList.Items[LIdx]);

        if Assigned(OnPatchFileBegin) then
        begin
          OnPatchFileBegin(
            Self,
            LPatchItem,
            LIdx + 1,
            PatchItemCount,
            LContinueIfError);
        end;

        LPatchFile := LPatchItem.PatchFileName;
        LOldFile := LPatchItem.OldFileName;
        LNewFile := LPatchItem.NewFileName;

        LApplyPatchResult := ApplyPatchToFileExW(
          Pointer(LPatchFile),
          Pointer(LOldFile),
          Pointer(LNewFile),
          LApplyPatchOptions,
          @MyPatchCreateApplyCallback,
          Self);
        if LApplyPatchResult <> True then
        begin
          LError := GetLastError;
          LErrorMessage := Descriptions_TPatchApplyErrorCode[PatcherHelper.APICodeToPatchApplyErrorCode(LError)];
          if LErrorMessage = '' then
            LErrorMessage := SysErrorMessage(LError);
          if not (LContinueIfError) then
            raise EPatcherException.Create(LErrorMessage);
        end;
        if Assigned(OnPatchFileEnd) then
        begin
          OnPatchFileEnd(
            Self,
            LPatchItem,
            LIdx + 1,
            PatchItemCount);
        end;
      end;
    except
      on E : Exception do
      begin
        LError := 1;
        LErrorMessage := E.ClassName + ' caught with message: ' + E.Message;
        if AlwaysRaiseExceptions then
        begin
          raise EPatcherException.Create(LErrorMessage);
        end;
      end;
    end;
  finally
    if Assigned(OnPatchesComplete) then
    begin
      OnPatchesComplete(
        Self,
        LError,
        LErrorMessage);
    end;
  end;
end;

constructor TPatcher.Create;
begin
  inherited Create;
  FPatchList := TObjectList.Create;
  ResetPatchData(True);
end;

procedure TPatcher.CreatePatches;
begin
  case FileMode of
    psmAnsi : CreatePatchesAnsi;
    psmUnicode : CreatePatchesWide;
  else
    begin
      raise EPatcherException.Create('Create Patch File mode not implemented yet [' +
        PatcherHelper.EnumTypeToString(
        TypeInfo(TPatcherFileMode),
        Integer(FileMode)) + ']');
    end;
  end;
end;

procedure TPatcher.CreatePatchesAnsi;
var
  LOldFile : AnsiString;
  LNewFile : AnsiString;
  LPatchFile : AnsiString;
  LError : Integer;
  LErrorMessage : string;
  LFile : file of byte;
  LOld : TPatchOldFileInfoA;
  LCreatePatchOptions : ULONG;
  LIdx : Integer;
  LPatchItem : TPatchItem;
  LCreatePatchResult : LongBool;
  LContinueIfError : Boolean;
begin
  LError := 0;
  LErrorMessage := '';
  try                       
    try
      LContinueIfError := AlwaysRaiseExceptions;
      LCreatePatchOptions := PatcherHelper.PatchCreateOptionsToULONG(CreatePatchCompressionMode, CreatePatchAdditionalFlags);
      if PatchItemCount = 0 then
        raise EPatcherException.Create('No patch items to patch.');
      for LIdx := 0 to PatchItemCount - 1 do
      begin
        LPatchItem := TPatchItem(FPatchList.Items[LIdx]);

        if Assigned(OnPatchFileBegin) then
        begin
          OnPatchFileBegin(
            Self,
            LPatchItem,
            LIdx + 1,
            PatchItemCount,
            LContinueIfError);
        end;
        LPatchFile := LPatchItem.PatchFileName;
        LOldFile := LPatchItem.OldFileName;
        LNewFile := LPatchItem.NewFileName;
        LOld.SizeOfThisStruct := SizeOf(LOld);
        LOld.OldFileName := Pointer(LOldFile);
        LOld.IgnoreRangeCount := 0;
        LOld.RetainRangeCount := 0;

        AssignFile(LFile, LPatchFile);
        Rewrite(LFile);
        CloseFile(LFile);

        LCreatePatchResult := CreatePatchFileExA(
          1,
          @LOld,
          Pointer(LNewFile),
          Pointer(LPatchFile),
          LCreatePatchOptions,
          nil,
          @MyPatchCreateApplyCallback,
          Self);
        if LCreatePatchResult <> True then
        begin
          LError := GetLastError;
          LErrorMessage := Descriptions_TPatchCreateErrorCode[PatcherHelper.APICodeToPatchCreateErrorCode(LError)];
          if LErrorMessage = '' then
            LErrorMessage := SysErrorMessage(LError);
          if not (LContinueIfError) then
            Break;
        end;
        if Assigned(OnPatchFileEnd) then
        begin
          OnPatchFileEnd(
            Self,
            LPatchItem,
            LIdx + 1,
            PatchItemCount);
        end;
      end;
    except
      on E : Exception do
      begin
        LError := 1;
        LErrorMessage := E.ClassName + ' caught with message: ' + E.Message;
        if AlwaysRaiseExceptions then
        begin
          raise;
        end;
      end;
    end;
  finally
    if Assigned(OnPatchesComplete) then
    begin
      OnPatchesComplete(
        Self,
        LError,
        LErrorMessage);
    end;
  end;
end;

procedure TPatcher.CreatePatchesWide;
var
  LOldFile : WideString;
  LNewFile : WideString;
  LPatchFile : WideString;
  LError : Integer;
  LErrorMessage : string;
  LFile : file of byte;
  LOld : TPatchOldFileInfoW;
  LCreatePatchOptions : ULONG;
  LIdx : Integer;
  LPatchItem : TPatchItem;
  LCreatePatchResult : LongBool;
  LContinueIfError : Boolean;
begin
  LError := 0;
  LErrorMessage := '';
  try
    try
      LContinueIfError := AlwaysRaiseExceptions;
      LCreatePatchOptions := PatcherHelper.PatchCreateOptionsToULONG(CreatePatchCompressionMode, CreatePatchAdditionalFlags);
      if PatchItemCount = 0 then
        raise EPatcherException.Create('No patch items to patch.');
      for LIdx := 0 to PatchItemCount - 1 do
      begin
        LPatchItem := TPatchItem(FPatchList.Items[LIdx]);

        if Assigned(OnPatchFileBegin) then
        begin
          OnPatchFileBegin(
            Self,
            LPatchItem,
            LIdx + 1,
            PatchItemCount,
            LContinueIfError);
        end;

        LPatchFile := LPatchItem.PatchFileName;
        LOldFile := LPatchItem.OldFileName;
        LNewFile := LPatchItem.NewFileName;
        LOld.SizeOfThisStruct := SizeOf(LOld);
        LOld.OldFileName := Pointer(LOldFile);
        LOld.IgnoreRangeCount := 0;
        LOld.RetainRangeCount := 0;

        // We need to rewrite/create the patch file... or else the patch will fail...
        AssignFile(LFile, LPatchFile);
        Rewrite(LFile);
        CloseFile(LFile);

        LCreatePatchResult := CreatePatchFileExW(
          1,
          @LOld,
          Pointer(LNewFile),
          Pointer(LPatchFile),
          LCreatePatchOptions,
          nil,
          @MyPatchCreateApplyCallback,
          Self);
        if LCreatePatchResult <> True then
        begin
          LError := GetLastError;
          LErrorMessage := Descriptions_TPatchCreateErrorCode[PatcherHelper.APICodeToPatchCreateErrorCode(LError)];
          if LErrorMessage = '' then
            LErrorMessage := SysErrorMessage(LError);
          if not (LContinueIfError) then
            Break;
        end;
        if Assigned(OnPatchFileEnd) then
        begin
          OnPatchFileEnd(
            Self,
            LPatchItem,
            LIdx + 1,
            PatchItemCount);
        end;
      end;
    except
      on E : Exception do
      begin
        LError := 1;
        LErrorMessage := E.ClassName + ' caught with message: ' + E.Message;
        if AlwaysRaiseExceptions then
        begin
          raise EPatcherException.Create(LErrorMessage);
        end;
      end;
    end;
  finally
    if Assigned(OnPatchesComplete) then
    begin
      OnPatchesComplete(
        Self,
        LError,
        LErrorMessage);
    end;
  end;
end;

destructor TPatcher.Destroy;
begin
  ResetPatchData(True);
  FreeAndNil(FPatchList);

  inherited Destroy;
end;

function TPatcher.GetItem(AIndex : Integer) : TPatchItem;
begin
  if (PatchItemCount = 0) then
  begin
    raise EPatcherException.Create('Patch item count is zero.');
  end;
  if ((AIndex < 0) and (AIndex >= PatchItemCount)) then
  begin
    raise EPatcherException.Create('Index for retrieving patch item must be between 0 and ' + IntToStr(PatchItemCount) + '.');
  end;
  Result := TPatchItem(FPatchList.Items[AIndex]);
end;

function TPatcher.GetPatchItemCount : Integer;
begin
  Result := FPatchList.Count;
end;

procedure TPatcher.RemovePatchItemAtIndex(const AIndex : Integer);
begin
  if (PatchItemCount = 0) then
  begin
    raise EPatcherException.Create('Patch item count is zero.');
  end;
  if ((AIndex < 0) and (AIndex >= PatchItemCount)) then
  begin
    raise EPatcherException.Create('Index for retrieving patch item must be between 0 and ' + IntToStr(PatchItemCount) + '.');
  end;
  FPatchList.Delete(AIndex);
  FPatchList.Capacity := FPatchList.Count;
end;

procedure TPatcher.ResetPatchData(
  const AClearEventsAsWell : Boolean);
begin
  FPatchList.Clear;
  FPatchList.Capacity := FPatchList.Count;
  FPatchFileExtension := '.pth';
  FPatchFilePath := ExtractFilePath(Application.ExeName);
  FFileMode := psmAnsi;
  FPatchList := TObjectList.Create(True);
  FCreatePatchCompressionMode := pcoUseBest;
  FCreatePatchAdditionalFlags := [];
  FAlwaysRaiseExceptions := True;

  if AClearEventsAsWell then
  begin
    FOnPatchProgress := nil;
    FOnPatchesComplete := nil;
    FOnPatchFileBegin := nil;
    FOnPatchFileEnd := nil;
  end;
end;

procedure TPatcher.SetCompressionMode(
  const ACompressionMode : TPatchCreateOptions_Compression);
begin
  FCreatePatchCompressionMode := ACompressionMode;
end;

procedure TPatcher.TestApplyPatches;
begin
  raise EPatcherException.Create('Test Apply Patch To File mode not implemented yet [' +
    PatcherHelper.EnumTypeToString(
    TypeInfo(TPatcherFileMode),
    Integer(FileMode)) + ']');
end;

{ TPatchItem }

constructor TPatchItem.Create(const APatchFileExtension,
  APatchFilePath : string);
begin
  inherited Create;

  FPatchFileExtension := APatchFileExtension;
  FPatchFilePath := APatchFilePath;
end;

constructor TPatchItem.Create(
  const APatchFileExtension : string;
  const APatchFilePath : string;
  const AOldFileName : string;
  const ANewFileName : string;
  const APatchFilename : string);
begin
  Create(
    APatchFileExtension,
    APatchFilePath);
  FOldFileName := AOldFileName;
  if Trim(ANewFileName) = '' then
    FNewFileName := FOldFileName
  else
    FNewFileName := ANewFileName;
  if Trim(APatchFileName) = '' then
    FPatchFileName := GetPatchFileName
  else
    FPatchFileName := APatchFilename;
end;

constructor TPatchItem.Create;
begin
  raise EPatcherException.Create('You cannot instantiate this object using the constructor.');
end;

function TPatchItem.GetPatchFileName : string;
begin
  Result := FPatchFilePath + ChangeFileExt(ExtractFileName(NewFileName), FPatchFileExtension);
end;

{ PatcherHelper }

class function PatcherHelper.APICodeToPatchApplyErrorCode(
  const AAPICode : ULONG) : TPatchApplyErrorCode;
begin
  Result := paecUnknown;
  case AAPICode of
    ERROR_PATCH_DECODE_FAILURE : Result := paecDecodeFailure;
    ERROR_PATCH_CORRUPT : Result := paecCorrupt;
    ERROR_PATCH_NEWER_FORMAT : Result := paecNewerFormat;
    ERROR_PATCH_WRONG_FILE : Result := paecWrongFile;
    ERROR_PATCH_NOT_NECESSARY : Result := paecNotNecessary;
    ERROR_PATCH_NOT_AVAILABLE : Result := paecNotAvailable;
  end;
end;

class function PatcherHelper.APICodeToPatchCreateErrorCode(
  const AAPICode : ULONG) : TPatchCreateErrorCode;
begin
  Result := pcecUnknown;
  case AAPICode of
    ERROR_PATCH_ENCODE_FAILURE : Result := pcecEncodeFailure;
    ERROR_PATCH_INVALID_OPTIONS : Result := pcecInvalidOptions;
    ERROR_PATCH_SAME_FILE : Result := pcecSameFile;
    ERROR_PATCH_RETAIN_RANGES_DIFFER : Result := pcecRetainRangesDiffer;
    ERROR_PATCH_BIGGER_THAN_COMPRESSED : Result := pcecBiggerThanCompressed;
    ERROR_PATCH_IMAGEHLP_FAILURE : Result := pcecImageHlpFailure;
  end;
end;

class function PatcherHelper.EnumTypeToString(
  const ATypeInfoPointer : PTypeInfo;
  const AIntegerOfEnum : Integer) : string;
begin
  Result := GetEnumName(
    ATypeInfoPointer,
    AIntegerOfEnum);
end;

class function PatcherHelper.PatchApplyFlagToAPICode(
  const APatchApplyFlag : TPatchApplyOption) : ULONG;
begin
  Result := 0;
  case APatchApplyFlag of
    paoFailIfExact : Result := APPLY_OPTION_FAIL_IF_EXACT;
    paoFailIfClose : Result := APPLY_OPTION_FAIL_IF_CLOSE;
    paoTestOnly : Result := APPLY_OPTION_TEST_ONLY;
    paoValidFlags : Result := APPLY_OPTION_VALID_FLAGS;
  end;
end;

class function PatcherHelper.PatchApplyOptionFlagToString(
  const APatchApplyOptionFlag : TPatchApplyOption) : string;
begin
  Result := EnumTypeToString(
    TypeInfo(TPatchApplyOption),
    Integer(APatchApplyOptionFlag));
end;

class function PatcherHelper.PatchApplyOptionsToULONG(
  const APatchApplyOptions : TPatchApplyOptions) : ULONG;
var
  LFlags : ULONG;
  LAdditional : TPatchApplyOption;
begin
  LFlags := 0;
  if APatchApplyOptions <> [] then
  begin
    for LAdditional := Low(TPatchApplyOption) to High(TPatchApplyOption) do
    begin
      if LAdditional in APatchApplyOptions then
      begin
        LFlags := LFlags or PatcherHelper.PatchApplyFlagToAPICode(LAdditional);
      end;
    end;
  end;
  Result := LFlags;
end;

class function PatcherHelper.PatchCreateFlagToAPICode(
  const APatchCreateFlag : TPatchCreateOption) : ULONG;
begin
  Result := PATCH_OPTION_USE_BEST;
  case APatchCreateFlag of
    pcoUseBest : Result := PATCH_OPTION_USE_BEST;
    pcoUseLZX_A : Result := PATCH_OPTION_USE_LZX_A;
    pcoUseLZX_B : Result := PATCH_OPTION_USE_LZX_B;
    pcoUseBestLZX : Result := PATCH_OPTION_USE_LZX_BEST;
    pcoUseLZX_Large : Result := PATCH_OPTION_USE_LZX_LARGE;
    pcoNoBindFix : Result := PATCH_OPTION_NO_BINDFIX;
    pcoNoLockFix : Result := PATCH_OPTION_NO_LOCKFIX;
    pcoNoRebase : Result := PATCH_OPTION_NO_REBASE;
    pcoFailIfSameFile : Result := PATCH_OPTION_FAIL_IF_SAME_FILE;
    pcoFailIfBigger : Result := PATCH_OPTION_FAIL_IF_BIGGER;
    pcoNoChecksum : Result := PATCH_OPTION_NO_CHECKSUM;
    pcoNoResourceTimeStampFix : Result := PATCH_OPTION_NO_RESTIMEFIX;
    pcoNoTimeStamp : Result := PATCH_OPTION_NO_TIMESTAMP;
    pcoUseSignatureMD5 : Result := PATCH_OPTION_SIGNATURE_MD5;
    pcoReserved1 : Result := PATCH_OPTION_RESERVED1;
    pcoValidFlags : Result := PATCH_OPTION_VALID_FLAGS;
  end;
end;

class function PatcherHelper.PatchCreateFlagToString(
  const APatchCreateFlag : TPatchCreateOption) : string;
begin
  Result := EnumTypeToString(
    TypeInfo(TPatchCreateOption),
    Integer(APatchCreateFlag));
end;

class function PatcherHelper.PatchCreateOptionsToULONG(
  const APatchCreateCompression : TPatchCreateOptions_Compression;
  const APatchCreateAdditional : TPatchCreateOptions_Additional) : ULONG;
var
  LFlags : ULONG;
  LAdditional : TPatchCreateOption;
begin
  LFlags := PatcherHelper.PatchCreateFlagToAPICode(APatchCreateCompression);
  if APatchCreateAdditional <> [] then
  begin
    for LAdditional := Low(TPatchCreateOption) to High(TPatchCreateOption) do
    begin
      if LAdditional in APatchCreateAdditional then
      begin
        LFlags := LFlags or PatcherHelper.PatchCreateFlagToAPICode(LAdditional);
      end;
    end;
  end;
  Result := LFlags;
end;

class function PatcherHelper.PatchFileModeToString(
  const APatcherFileMode : TPatcherFileMode) : string;
begin
  Result := EnumTypeToString(
    TypeInfo(TPatcherFileMode),
    Integer(APatcherFileMode));
end;

class function PatcherHelper.StringToPatchApplyOptionFlag(
  const APatchApplyOptionFlagString : string) : TPatchApplyOption;
begin
  Result := TPatchApplyOption(
    GetEnumValue(
    TypeInfo(TPatchApplyOption),
    APatchApplyOptionFlagString));
end;

class function PatcherHelper.StringToPatchCreateFlag(
  const APatchCreateFlagString : string) : TPatchCreateOption;
begin
  Result := TPatchCreateOption(
    GetEnumValue(
    TypeInfo(TPatchCreateOption),
    APatchCreateFlagString));
end;

class function PatcherHelper.StringToPatchFileMode(
  const APatcherFileModeString : string) : TPatcherFileMode;
begin
  Result := TPatcherFileMode(
    GetEnumValue(
    TypeInfo(TPatcherFileMode),
    APatcherFileModeString));
end;

end.

