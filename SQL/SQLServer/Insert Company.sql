
/****** Script for SelectTopNRows command from SSMS  ******/
declare @stateProvGUID uniqueidentifier

select @stateProvGUID = StateProvinceGUID from StateProvince where Abbreviation = 'AB'
print 'AB = ' + cast(@stateProvGUID as varchar(40))

/****** Script for SelectTopNRows command from SSMS  ******/
declare @countryGUID uniqueidentifier;

select @countryGUID = countryGUID from country where Abbreviation = 'CA'
print 'CA = ' + cast(@countryGUID as varchar(40))

declare @locationGUID uniqueidentifier
declare @addressGUID uniqueidentifier
declare @companyGUID uniqueidentifier
declare @companyLocationGUID uniqueidentifier

set @addressGUID = newid()
insert into Address(addressGUID,StreetAddress,City,StateProvinceGUID,ZipPostal) values (@addressGUID,'1110, 333 – 11 Avenue SW','Calgary',@stateProvGUID,'T2R1L9')

set @locationGUID = newid()
insert into Location(locationGUID,addressGUID,description,latitude,longitude) values (@locationGUID,@addressGUID,'Head Office',null,null) 

set @companyGUID = newid() --insert company without a location and then update it's location (we have a circular reference here)
insert into Company (companyGUID, Name, CompanyLocationGUID) Values (@companyGUID, 'Dynamic Risk Assessment Systems, Inc.',null)

set @companyLocationGUID  = newid()
insert into CompanyLocation (companyLocationGUID, SiteName, CompanyGUID, LocationGUID) Values (@companyLocationGUID, 'Head Office',@companyGUID,@locationGUID)

update Company set CompanyLocationGUID = @companyLocationGUID where companyGUID = @companyGUID



