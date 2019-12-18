unit hcDeployment;

interface

uses
	hcObject
	,hcObjectList
  ,hcParentedObjectList
	,hcAttribute
  ,hcTypes
	;

const
  vchar_max = 2048;

type

  TVersionRec = record
    Major,
    Minor,
    Release,
    Build :SmallInt;
  end;

  {
    Persisted to XML manifest file.
  }
	ThcDeploymentItem = class(ThcObject)
  published
  private
  published
	public
		class procedure Register; override;
    procedure Initialize; override;
    function IsAPriorVersion(const Version :string) :Boolean;
		property FileName :ThcAttribute Index 1 read GetAttribute;
		property Version :ThcAttribute Index 2 read GetAttribute;
		property TargetPath :ThcAttribute Index 3 read GetAttribute;
    property SourcePath :ThcAttribute Index 4 read GetAttribute;
    property IsAPatch :ThcAttribute Index 5 read GetAttribute;
    property IsAZip :ThcAttribute Index 6 read GetAttribute;
    property Launch :ThcAttribute Index 7 read GetAttribute;
	end;

	ThcDeploymentItemList = class(ThcParentedObjectList)
  private
	public
		procedure AfterConstruction; override;
		function Current :ThcDeploymentItem; reintroduce;
		procedure Load; override;
    procedure SortByVersion(SortOrder: TSortType);
  end;

  {
    Persisted to database and to XML manifest file.
  }
	ThcDeployment = class(ThcObject)
  private
    FItems :ThcDeploymentItemList;
    function GetItems :ThcDeploymentItemList;
	public
		class procedure Register; override;
    procedure AfterConstruction; override;
    procedure Initialize; override;
    procedure SaveToManifest(XMLManifestFilePath :string);
    function Write(Dest :ThcObjectStore; ValidateFirst :boolean) :boolean; override;
		property DeploymentGUID :ThcAttribute Index 0 read GetAttribute;
		property UpdateVersion :ThcAttribute Index 1 read GetAttribute;
		property WhatsNew :ThcAttribute Index 2 read GetAttribute;
		property ApplicationGUID :ThcAttribute Index 3 read GetAttribute;
		property Status :ThcAttribute Index 4 read GetAttribute;
		property IsMandatory :ThcAttribute Index 5 read GetAttribute;
		property IsSilent :ThcAttribute Index 6 read GetAttribute;
		property IsImmediate :ThcAttribute Index 7 read GetAttribute;
    {$ifdef FABUTAN}
		property SyncProgrammability :ThcAttribute Index 8 read GetAttribute;
		property SyncData :ThcAttribute Index 9 read GetAttribute;
    {$endif}
    property Items :ThcDeploymentItemList read GetItems;
	end;

  {
    All Deployments that are Active for a given Application.
  }
  ThcActiveDeploymentList = class(ThcObjectList)
  private
    FApplicationGUID :string;
	public
    procedure SortByVersion(SortOrder: TSortType);
		procedure AfterConstruction; override;
		function Current :ThcDeployment; reintroduce;
		procedure Load; override;
    property ApplicationGUID :string write FApplicationGUID;
  end;


function ObjectVersionCompare(Item1, Item2: ThcObject; SortInfo :ThcSortInfo): Integer;
function ParseVersionInfo(const VersInfo :string) :TVersionRec;

implementation

uses
	hcTableDef
	,hcCore
	,hcMetaData
	,hcAttributeDef
	,hcPrimaryKeyConstraint
	,DB
	,hcStdValidators
	,SysUtils
	,hcQueryIntf
	,hcCodeSiteHelper
	,hcFactoryPool
	,hcFunctions
	,Controls
	,Forms
  ,hcStoredProcIntf
  ,XMLDoc
  ,XMLIntf
  ,Variants
  ,hcUpdateConsts
  ,StrUtils
	;

function ParseVersionInfo(const VersInfo :string) :TVersionRec;
var
  nStart,
  nEnd :Integer;
begin
  //parse versiion string into Record since string compare will not work
  nStart := 1;
  nEnd := PosEx('.',VersInfo,nStart);
  Result.Major := StrToInt(Copy(VersInfo,nStart,nEnd-nStart));

  nStart := nEnd + 1;
  nEnd := PosEx('.',VersInfo,nStart);
  Result.Minor := StrToInt(Copy(VersInfo,nStart,nEnd-nStart));

  nStart := nEnd + 1;
  nEnd := PosEx('.',VersInfo,nStart);
  Result.Release := StrToInt(Copy(VersInfo,nStart,nEnd-nStart));

  nStart := nEnd + 1;
  nEnd := Length(VersInfo);
  Result.Build := StrToInt(Copy(VersInfo,nStart,nEnd));
end;

function ThcDeployment.GetItems: ThcDeploymentItemList;
begin
  if not assigned(FItems) then
  begin
    FItems := ThcDeploymentItemList.Create(Self);
    AddChild(FItems);
  end;
  Result := FItems;
end;

procedure ThcDeployment.Initialize;
begin
  inherited;
  WhatsNew.AsString := ''; //database field does not accept NULL and we aren't using a validator
end;

class procedure ThcDeployment.Register;
var
	MetaData: ThcMetaData;
	PrimaryTableDef :ThcTableDef;
  valRequiredBoolean :ThcBooleanValidator;
begin

	MetaData := ThcMetaData.Create;
	with MetaData do
	begin
    valRequiredBoolean := ThcBooleanValidator.Create;
    valRequiredBoolean.AllowNull := False;
    Validators.Add(valRequiredBoolean);

		TableDefs.Clear;
		PrimaryTableDef := TableDefs.AddTableDef('Deployment','D',[]);
		with PrimaryTableDef do
		begin
			with AttributeDefs do
			begin
				PrimaryKey := ThcPrimaryKeyConstraint.Create(kgtServerGeneratedBeforeInsert,[{ 0} AddDef('DeploymentGUID',ftGuid,'DeploymentGUID',ftGuid,[])]);
				OID := PrimaryKey;
				{ 1} AddDef('UpdateVersion',ftString,'UpdateVersion',ftString,[]);
				{ 2} AddDef('WhatsNew',ftString,'WhatsNew',ftString,[]);
        { 3} AddDef('ApplicationGUID',ftGuid,'ApplicationGUID',ftGuid,[]);
        { 4} AddDef('Status',ftString,'Status',ftString,[]); //'Active','Completed' or 'Cancelled'
        { 5} AddDef('IsMandatory',ftBoolean,'IsMandatory',ftBoolean,[],valRequiredBoolean);
        { 6} AddDef('IsSilent',ftBoolean,'IsSilent',ftBoolean,[],valRequiredBoolean);
        { 7} AddDef('IsImmediate',ftBoolean,'IsImmediate',ftBoolean,[],valRequiredBoolean);
        {$ifdef FABUTAN}
        { 8} AddDef('SyncProgrammability',ftBoolean,'SyncProgrammability',ftBoolean,[],valRequiredBoolean);
        { 9} AddDef('SyncData',ftBoolean,'SyncData',ftBoolean,[],valRequiredBoolean);
        {$endif}
			end;
		end;
	end;
	ObjectRegistry.RegisterObject(Self,MetaData);
end;

procedure ThcDeployment.SaveToManifest(XMLManifestFilePath: string);
var
  XMLDoc : IXMLDocument;
  iRootNode,
  iNode : IXMLNode;
  I :Integer;
begin
   //save the new manifest and binary components to disk
  XMLDoc := TXMLDocument.Create(nil);
  try
    XMLDoc.Active := True;
    iRootNode := XMLDoc.AddChild('Manifest');
    iRootNode.Attributes['UpdateVersion'] := UpdateVersion.AsString;
    iRootNode.Attributes['WhatsNew'] := WhatsNew.AsString;
    iRootNode.Attributes['IsMandatory'] := BoolToStr(IsMandatory.AsBoolean,True);
    iRootNode.Attributes['IsImmediate'] := BoolToStr(IsImmediate.AsBoolean,True);
    iRootNode.Attributes['IsSilent'] := BoolToStr(IsSilent.AsBoolean,True);
    {$ifdef FABUTAN}
    iRootNode.Attributes['SyncProgrammability'] := BoolToStr(SyncProgrammability.AsBoolean,True);
    iRootNode.Attributes['SyncData'] := BoolToStr(SyncData.AsBoolean,True);
    {$endif}
    for I := 0 to Items.Count - 1 do
    begin
      iNode := iRootNode.AddChild('Item');
      iNode.Attributes['FileName'] := ThcDeploymentItem(Items[I]).FileName.AsString;
      iNode.Attributes['Version'] := ThcDeploymentItem(Items[I]).Version.AsString;
      iNode.Attributes['TargetPath'] := ThcDeploymentItem(Items[I]).TargetPath.AsString;
      iNode.Attributes['IsAPatch'] := BoolToStr(ThcDeploymentItem(Items[I]).IsAPatch.AsBoolean,True);
      iNode.Attributes['IsAZip'] := BoolToStr(ThcDeploymentItem(Items[I]).IsAZip.AsBoolean,True);
      iNode.Attributes['Launch'] := BoolToStr(ThcDeploymentItem(Items[I]).Launch.AsBoolean,True);
    end;
    XMLDoc.SaveToFile(IncludeTrailingPathDelimiter(XMLManifestFilePath) + ManifestFileName);
  finally
    XMLDoc := nil;
  end;
end;

procedure ThcDeployment.AfterConstruction;
begin
  inherited AfterConstruction;
  Items.Name := 'DeploymentItems';
end;


{ ThcDeploymentItemList }

procedure ThcDeploymentItemList.AfterConstruction;
begin
	inherited AfterConstruction;
	ObjectClassName := ThcDeploymentItem.ClassName;
end;

function ThcDeploymentItemList.Current: ThcDeploymentItem;
begin
	Result := ThcDeploymentItem(inherited Current);
end;

procedure ThcDeploymentItemList.Load;
{
  There is no need to load the list since we never allow editing of
  previously created deployments.  This method will be called when the list is bound
  so it must be handled correctly.
}
begin
  PostLoad;
end;


procedure ThcDeploymentItemList.SortByVersion(SortOrder :TSortType);
var
  SortInfo: ThcSortInfo;
begin
  if (Count > 0) then
  begin
    SortInfo := ThcSortInfo.Create;
    try
      SortInfo.SortOrder1 := SortOrder;
      SortInfo.AttributeIndex1 := 2;  //index of Version
      SortInfo.AttributeDataType1 := ThcAttribute(Current.Attributes[SortInfo.AttributeIndex1]).DataType;
      QSort(0, Count - 1, @ObjectVersionCompare, SortInfo);
    finally // wrap up
      SortInfo.Free;
    end;    // try/finally
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

function ObjectVersionCompare(Item1, Item2: ThcObject; SortInfo :ThcSortInfo): Integer;
{
  function to parse and compare the VersionInfo strings for 2 items
}
var
  Item1VerRec,
  Item2VerRec :TVersionRec;
begin
  with SortInfo do
  begin
    Item1VerRec := ParseVersionInfo(ThcAttribute(Item1.Attributes[AttributeIndex1]).AsString);
    Item2VerRec := ParseVersionInfo(ThcAttribute(Item2.Attributes[AttributeIndex1]).AsString);

    Result := CompareVersion(Item1VerRec,Item2VerRec);

    //compares above assume Ascending so invert result if Descending
    if (SortOrder1 = stDescending) then
      Result := -1 * Result;
  end;  // with
end;



{ ThcDeploymentItem }

procedure ThcDeploymentItem.Initialize;
begin
  inherited;
  IsAPatch.AsBoolean := False;
  Launch.AsBoolean := False;
end;

function ThcDeploymentItem.IsAPriorVersion(const Version :string): Boolean;
{
  Returns True if Version passed is a previous version compared ot this item.
}
var
  VerRec1,
  VerRec2 :TVersionRec;
begin
  VerRec1 := ParseVersionInfo(Self.Version.AsString);
  VerRec2 := ParseVersionInfo(Version);
  Result := CompareVersion(VerRec1,VerRec2) > 0;
end;

class procedure ThcDeploymentItem.Register;
var
	MetaData: ThcMetaData;
	PrimaryTableDef :ThcTableDef;
  aDef :ThcAttributeDef;
begin
	MetaData := ThcMetaData.Create;
	with MetaData do
	begin
		TableDefs.Clear;
		PrimaryTableDef := TableDefs.AddTableDef('DeploymentItem','DI',[]);
		with PrimaryTableDef do
		begin
			with AttributeDefs do
			begin
				PrimaryKey := ThcPrimaryKeyConstraint.Create(kgtServerGeneratedBeforeInsert,[{ 0} AddDef('DeploymentItemGUID',ftGuid,'DeploymentItemGUID',ftGuid,[])]);
				OID := PrimaryKey;
				{ 1} AddDef('FileName',ftString,'FileName',ftString,[]);
				{ 2} AddDef('Version',ftString,'Version',ftString,[]);
        { 3} AddDef('TargetPath',ftString,'TargetPath',ftString,[]);
        { 4} AddDef('SourcePath',ftString,'SourcePath',ftString,[apNotPersisted]);
        { 5} AddDef('IsAPatch',ftBoolean,'IsAPatch',ftBoolean,[apNotPersisted]);
        { 6} AddDef('IsAZip',ftBoolean,'IsAZip',ftBoolean,[apNotPersisted]);
        { 7} AddDef('Launch',ftBoolean,'Launch',ftBoolean,[apNotPersisted]);
        { 8} aDef := AddDef('DeploymentGUID',ftGuid,'DeploymentGUID',ftGuid,[]);
        ForeignKeys.Add([aDef],'Deployment','DeploymentGUID');
			end;
		end;
	end;
	ObjectRegistry.RegisterObject(Self,MetaData);
end;

function ThcDeployment.Write(Dest: ThcObjectStore; ValidateFirst: boolean): boolean;
var
  aProc: IhcStoredProc;
begin
  aProc := ThcFactoryPool(FactoryPool).CreateStoredProc;
  aProc.SetProcedureName('spCreateDeployment');

  aProc.AddParameter('@applicationGUID',ftGUID,ApplicationGUID.Value);
  aProc.AddParameter('@version',ftString,UpdateVersion.Value,pdInput,50);
  aProc.AddParameter('@whatsNew',ftString,WhatsNew.Value,pdInput,vchar_max);
  aProc.AddParameter('@IsImmediate',ftBoolean,IsImmediate.Value);
  aProc.AddParameter('@IsSilent',ftBoolean,IsSilent.Value);
  aProc.AddParameter('@IsMandatory',ftBoolean,IsMandatory.Value);
  {$ifdef FABUTAN}
  aProc.AddParameter('@SyncProgrammability',ftBoolean,SyncProgrammability.Value);
  aProc.AddParameter('@SyncData',ftBoolean,SyncData.Value);
  {$endif}

  //OUTPUTs
  aProc.AddParameter('@deploymentGUID',ftGUID,null,pdInputOutput);

  LogStoredProcCall(aProc);
  DeploymentGUID.AsString := aProc.GetParamValue('@deploymentGUID');
  Result := True;

end;

{ ThcActiveDeploymentList }

procedure ThcActiveDeploymentList.AfterConstruction;
begin
	inherited AfterConstruction;
	ObjectClassName := ThcDeployment.ClassName;
end;

function ThcActiveDeploymentList.Current: ThcDeployment;
begin
	Result := ThcDeployment(inherited Current);
end;

procedure ThcActiveDeploymentList.SortByVersion(SortOrder :TSortType);
var
  SortInfo: ThcSortInfo;
begin
  if (Count > 1) then
  begin
    SortInfo := ThcSortInfo.Create;
    try
      SortInfo.SortOrder1 := SortOrder;
      SortInfo.AttributeIndex1 := 1;  //index of UpdateVersion
      SortInfo.AttributeDataType1 := ThcAttribute(Current.Attributes[SortInfo.AttributeIndex1]).DataType;
      QSort(0, Count - 1, @ObjectVersionCompare, SortInfo);
    finally // wrap up
      SortInfo.Free;
    end;    // try/finally
  end;
end;

procedure ThcActiveDeploymentList.Load;
const
  sSQL :string =
      'SELECT [DeploymentGUID],[UpdateVersion],[WhatsNew],[Status],[IsMandatory],[IsSilent],[IsImmediate]'+
      {$ifdef FABUTAN}
      ',[SyncProgrammability],[SyncData] '+
      {$endif}
      'FROM [dbo].[Deployment] '+
      'where [Status] = ''Active'' and [ApplicationGUID] = ''%s'' '+
      'order by [UpdateVersion] DESC ';
var
	saveCursor: TCursor;
	aQuery: IhcQuery;
begin
	saveCursor := Screen.Cursor;
	Screen.Cursor := crHourGlass;
	try
		PreLoad;
		aQuery := ThcFactoryPool(FactoryPool).CreateQuery;
		with aQuery do
		begin
			SQL.Text := Format(sSQL,[FApplicationGUID]);
			LogQueryOpen(aQuery);
			while not EOF do
			begin
				Self.Append;
				with Current as ThcDeployment do
				begin
					SetObjectState(osReading);  //prevent calcs while loading
          DeploymentGUID.Assign(FieldByName('DeploymentGUID'));
          UpdateVersion.Assign(FieldByName('UpdateVersion'));
          WhatsNew.Assign(FieldByName('WhatsNew'));
          ApplicationGUID.AsString := FApplicationGUID;
          Status.Assign(FieldByName('Status'));
          IsMandatory.Assign(FieldByName('IsMandatory'));
          IsSilent.Assign(FieldByName('IsSilent'));
          IsImmediate.Assign(FieldByName('IsImmediate'));
          {$ifdef FABUTAN}
          SyncProgrammability.Assign(FieldByName('SyncProgrammability'));
          SyncData.Assign(FieldByName('SyncData'));
          {$endif}
					ObjectExistsInStore;
				end;  //with
				aQuery.Next;
			end;  //while
		end;  //with
	finally
		PostLoad;
		Screen.Cursor := saveCursor;
	end;  //try/finally
end;

initialization
	ThcDeploymentItem.Register;
	ThcDeployment.Register;
  ThcDeploymentItemList.Register;


finalization
	ThcDeploymentItem.UnRegister;
	ThcDeployment.UnRegister;
  ThcDeploymentItemList.UnRegister;


end.
