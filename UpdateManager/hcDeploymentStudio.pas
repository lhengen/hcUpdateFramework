unit hcDeploymentStudio;


interface


uses
	hcObject
	,hcObjectList
	,hcAttribute
  ,hcTypes
	;


type
	ThcDeploymentStudio = class(ThcObject)
  private
	public
		class procedure Register; override;
    function Write(Dest :ThcObjectStore; ValidateFirst :boolean) :boolean; override;
    function UserCanChangeSelectionStatus(UpdateVersion :string) :Boolean;
		property StudioGUID :ThcAttribute Index 0 read GetAttribute;
		property IsCorporate :ThcAttribute Index 1 read GetAttribute;
		property StudioLevel :ThcAttribute Index 2 read GetAttribute;
		property Region :ThcAttribute Index 3 read GetAttribute;
		property StudioNumber :ThcAttribute Index 4 read GetAttribute;
		property UserSelected :ThcAttribute Index 5 read GetAttribute;
		property CurrentVersion :ThcAttribute Index 6 read GetAttribute;
		property StudioName :ThcAttribute Index 7 read GetAttribute;
    property AvailableUTCDate :ThcAttribute Index 8 read GetAttribute;
	end;


	ThcDeploymentStudioList = class(ThcObjectList)
  private
    FDeploymentGUID :string;
	public
		procedure AfterConstruction; override;
		function Current :ThcDeploymentStudio; reintroduce;
		procedure Load; override;
    procedure SetAvailableUTCDate(AvailableAsOf :TDateTime);
    function LocateRegion(Region :Integer) :Boolean;
    property DeploymentGUID :string write FDeploymentGUID;
	end;


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
	,Forms, Variants
	;


function ThcDeploymentStudio.UserCanChangeSelectionStatus(UpdateVersion :string) :Boolean;
begin
  Result := (CurrentVersion.AsString < UpdateVersion);
end;

function ThcDeploymentStudio.Write(Dest:ThcObjectStore; ValidateFirst:boolean):boolean;
var
  {$ifdef hcCodeSite}
  I: Integer;
  {$endif}  // hcCodeSite
  aQuery :IhcQuery;
begin
  aQuery := ThcFactoryPool(FactoryPool).CreateQuery;
  aQuery.SQL.Text := 'update StudioDeployment set IsAvailable = :IsAvailable, AvailableUTCDate = :AvailableUTCDate where StudioGUID = :StudioGUID and DeploymentGUID = :DeploymentGUID and IsAvailable = 0';
  aQuery.SetParamValue('StudioGUID',ftGUID,StudioGUID.AsString);
  aQuery.SetParamValue('DeploymentGUID',ftGUID,(Owner as ThcDeploymentStudioList).FDeploymentGUID);
  aQuery.SetParamValue('IsAvailable',ftBoolean,UserSelected.AsBoolean);
  aQuery.SetParamValue('AvailableUTCDate',ftDateTime,AvailableUTCDate.Value);

  {$ifdef hcCodeSite}
    hcCodeSite.SendSQL(aQuery.SQL.Text);
    for I := 0 to aQuery.ParameterCount - 1 do    // Iterate
      hcCodeSite.SendParameter(I,aQuery.GetParameterName(I),aQuery.GetParamValue(I));
  {$endif}  // hcCodeSite

  LogQueryExecSQL(aQuery);
  Result := True;
end;


class procedure ThcDeploymentStudio.Register;
var
	MetaData: ThcMetaData;
	PrimaryTableDef :ThcTableDef;
begin
	MetaData := ThcMetaData.Create;
	with MetaData do
	begin
		TableDefs.Clear;
		PrimaryTableDef := TableDefs.AddTableDef('Studio','S',[]);
		with PrimaryTableDef do
		begin
			with AttributeDefs do
			begin
				PrimaryKey := ThcPrimaryKeyConstraint.Create(kgtServerGeneratedBeforeInsert,[{ 0} AddDef('StudioGUID',ftGUID,'StudioGUID',ftGUID,[])]);
				OID := PrimaryKey;
				{ 1} AddDef('IsCorporate',ftBoolean,'IsCorporate',ftBoolean,[]);
				{ 2} AddDef('StudioLevel',ftWord,'StudioLevel',ftWord,[]);
				{ 3} AddDef('Region',ftSmallint,'Region',ftSmallint,[]);
				{ 4} AddDef('StudioNumber',ftInteger,'StudioNumber',ftInteger,[]);
				{ 5} AddDef('UserSelected',ftBoolean,'UserSelected',ftBoolean,[]);
				{ 6} AddDef('CurrentVersion',ftString,'CurrentVersion',ftString,[]);
        { 7} AddDef('StudioName',ftString,'StudioName',ftString,[]);
        { 8} AddDef('AvailableUTCDate',ftDateTime,'AvailableUTCDate',ftDateTime,[]);
			end;
		end;
	end;
	ObjectRegistry.RegisterObject(Self,MetaData);
end;

procedure ThcDeploymentStudioList.Load;
const
	FSQL :string = 
		' select s.StudioGUID, s.Name as StudioName, s.StudioNumber, s.IsCorporate,s.StudioLevel,r.Number as Region, r.Description as RegionName  '+
    ' ,(select [Value] as ProgramVersion from fnCategorizedStudioSetting(s.StudioGUID,getdate()) where [Key] = ''ProgramVersion'') as CurrentVersion '+
    ' ,(select IsAvailable from StudioDeployment sd where sd.StudioGUID = s.StudioGUID and sd.DeploymentGUID = ''%s'') as IsAvailable'+
    ' ,(select AvailableUTCDate from StudioDeployment sd where sd.StudioGUID = s.StudioGUID and sd.DeploymentGUID = ''%s'') as AvailableUTCDate'+
		' from Studio s inner join Region r on s.RegionGUID = r.RegionGUID '+
    ' where s.StudioNumber > 0 and s.IsActive = 1 order by Region asc, StudioNumber asc ';

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
			SQL.Text := Format(FSQL,[FDeploymentGUID,FDeploymentGUID]);
			LogQueryOpen(aQuery);
			while not EOF do
			begin
				Self.Append;
				with Current as ThcDeploymentStudio do
				begin
					SetObjectState(osReading);  //prevent calcs while loading

					StudioGUID.Assign(FieldByName('StudioGUID'));
					IsCorporate.Assign(FieldByName('IsCorporate'));
					StudioLevel.Assign(FieldByName('StudioLevel'));
					Region.Assign(FieldByName('Region'));
					StudioNumber.Assign(FieldByName('StudioNumber'));
          UserSelected.Assign(FieldByName('IsAvailable'));
					CurrentVersion.Assign(FieldByName('CurrentVersion'));
					StudioName.Assign(FieldByName('StudioName'));
					AvailableUTCDate.Assign(FieldByName('AvailableUTCDate'));

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

function ThcDeploymentStudioList.LocateRegion(Region: Integer): Boolean;
var
  I :Integer;
begin
  Result := False;
  for I := 0 to count - 1 do
  begin
    if ThcDeploymentStudio(Items[I]).Region.AsInteger = Region then
    begin
      Result := True;
      CurrentItem := I;
      Break;
    end;
  end;
end;

procedure ThcDeploymentStudioList.SetAvailableUTCDate(AvailableAsOf: TDateTime);
{
  Set the available date in UTC form for all UserSelected Studios that have been modified
}
var
  I :integer;
begin
  for I := 0 to Count - 1 do
  begin
    if (ThcDeploymentStudio(Self[I]).UserSelected.AsBoolean) and (ThcDeploymentStudio(Self[I]).AvailableUTCDate.IsNull)  then
    begin
      ThcDeploymentStudio(Self[I]).AvailableUTCDate.AsDateTime := AvailableAsOf;
    end;
  end;
end;

function ThcDeploymentStudioList.Current :ThcDeploymentStudio;
begin
	Result := ThcDeploymentStudio(inherited Current);
end;

procedure ThcDeploymentStudioList.AfterConstruction;
begin
	inherited AfterConstruction;
	ObjectClassName := ThcDeploymentStudio.ClassName;
end;

initialization
	ThcDeploymentStudio.Register;


finalization
	ThcDeploymentStudio.UnRegister;


end.
