unit hcDeploymentRegion;


interface


uses
	hcObject
	,hcObjectList
	,hcAttribute
	;


type
	ThcDeploymentRegion = class(ThcObject)
	public
		class procedure Register; override;
		property RegionGUID :ThcAttribute Index 0 read GetAttribute;
		property Number :ThcAttribute Index 1 read GetAttribute;
		property IsLocalAreaSubFranchised :ThcAttribute Index 2 read GetAttribute;
		property Description :ThcAttribute Index 3 read GetAttribute;
		property Details :ThcAttribute Index 4 read GetAttribute;
	end;


	ThcDeploymentRegionList = class(ThcObjectList)
	public
		procedure AfterConstruction; override;
		function Current :ThcDeploymentRegion; reintroduce;
		procedure Load; override;
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
	,hcTypes
	,hcFunctions
	,Controls
	,Forms
	;


class procedure ThcDeploymentRegion.Register;
var
	MetaData: ThcMetaData;
	PrimaryTableDef :ThcTableDef;
begin
	MetaData := ThcMetaData.Create;
	with MetaData do
	begin
		TableDefs.Clear;
		PrimaryTableDef := TableDefs.AddTableDef('Region','R',[tpReadOnly]);
		with PrimaryTableDef do
		begin
			with AttributeDefs do
			begin
				PrimaryKey := ThcPrimaryKeyConstraint.Create(kgtServerGeneratedBeforeInsert,[{ 0} AddDef('RegionGUID',ftGuid,'RegionGUID',ftGuid,[])]);
				OID := PrimaryKey;
				{ 1} AddDef('Number',ftSmallint,'Number',ftSmallint,[]);
				{ 2} AddDef('IsLocalAreaSubFranchised',ftBoolean,'IsLocalAreaSubFranchised',ftBoolean,[]);
				{ 3} AddDef('Description',ftString,'Description',ftString,[]);
				{ 4} AddDef('Details',ftString,'Details',ftString,[]);
			end;
		end;
	end;
	ObjectRegistry.RegisterObject(Self,MetaData);
end;

procedure ThcDeploymentRegionList.Load;
const
	FSQL :string =
		' select r.RegionGUID, r.Number, r.IsLocalAreaSubFranchised, r.Description, r.Details  '+
		' from Region r '+
		' where LocalAreaEmployeeGUID is not null '+  //exclude HeadOffice
		' order by Description asc ';

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
			SQL.Text := FSQL;
			LogQueryOpen(aQuery);
			while not EOF do
			begin
				Self.Append;
				with Current as ThcDeploymentRegion do
				begin
					SetObjectState(osReading);  //prevent calcs while loading
					RegionGUID.Assign(FieldByName('RegionGUID'));
					Number.Assign(FieldByName('Number'));
					IsLocalAreaSubFranchised.Assign(FieldByName('IsLocalAreaSubFranchised'));
					Description.Assign(FieldByName('Description'));
					Details.Assign(FieldByName('Details'));
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

function ThcDeploymentRegionList.Current :ThcDeploymentRegion;
begin
	Result := ThcDeploymentRegion(inherited Current);
end;

procedure ThcDeploymentRegionList.AfterConstruction;
begin
	inherited AfterConstruction;
	ObjectClassName := ThcDeploymentRegion.ClassName;
end;

initialization
	ThcDeploymentRegion.Register;


finalization
	ThcDeploymentRegion.UnRegister;


end.
