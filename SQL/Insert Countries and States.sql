use Deployment

declare @countryGUID uniqueidentifier 

set @countryGUID = NEWID();

INSERT INTO [dbo].[Country] ([CountryGUID],[Abbreviation],[Description]) VALUES (@countryGUID,'US','United States')



-- US States
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('ed45716f-e11d-e611-8319-00190e0c985e', 'AK', 'Alaska', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('ee45716f-e11d-e611-8319-00190e0c985e', 'AL', 'Alabama', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('ef45716f-e11d-e611-8319-00190e0c985e', 'AR', 'Arkansas', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('f045716f-e11d-e611-8319-00190e0c985e', 'AZ', 'Arizona', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('f145716f-e11d-e611-8319-00190e0c985e', 'CA', 'California', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('f245716f-e11d-e611-8319-00190e0c985e', 'CO', 'Colorado', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('f345716f-e11d-e611-8319-00190e0c985e', 'CT', 'Connecticut', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('f445716f-e11d-e611-8319-00190e0c985e', 'DE', 'Delaware', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('f545716f-e11d-e611-8319-00190e0c985e', 'FL', 'Florida', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('f645716f-e11d-e611-8319-00190e0c985e', 'GA', 'Georgia', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('f745716f-e11d-e611-8319-00190e0c985e', 'HI', 'Hawaii', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('f845716f-e11d-e611-8319-00190e0c985e', 'IA', 'Iowa', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('f945716f-e11d-e611-8319-00190e0c985e', 'ID', 'Idaho', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('fa45716f-e11d-e611-8319-00190e0c985e', 'IL', 'Illinois', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('fb45716f-e11d-e611-8319-00190e0c985e', 'IN', 'Indiana', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('fc45716f-e11d-e611-8319-00190e0c985e', 'KS', 'Kansas', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('fd45716f-e11d-e611-8319-00190e0c985e', 'KY', 'Kentucky', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('fe45716f-e11d-e611-8319-00190e0c985e', 'LA', 'Louisiana', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('ff45716f-e11d-e611-8319-00190e0c985e', 'MA', 'Massachusetts', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('0046716f-e11d-e611-8319-00190e0c985e', 'MD', 'Maryland', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('0146716f-e11d-e611-8319-00190e0c985e', 'ME', 'Maine', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('0246716f-e11d-e611-8319-00190e0c985e', 'MI', 'Michigan', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('0346716f-e11d-e611-8319-00190e0c985e', 'MN', 'Minnesota', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('0446716f-e11d-e611-8319-00190e0c985e', 'MO', 'Missouri', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('0546716f-e11d-e611-8319-00190e0c985e', 'MS', 'Mississippi', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('0646716f-e11d-e611-8319-00190e0c985e', 'MT', 'Montana', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('0746716f-e11d-e611-8319-00190e0c985e', 'NC', 'North Carolina', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('0846716f-e11d-e611-8319-00190e0c985e', 'ND', 'North Dakota', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('0946716f-e11d-e611-8319-00190e0c985e', 'NE', 'Nebraska', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('0a46716f-e11d-e611-8319-00190e0c985e', 'NH', 'New Hampshire', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('0b46716f-e11d-e611-8319-00190e0c985e', 'NJ', 'New Jersey', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('0c46716f-e11d-e611-8319-00190e0c985e', 'NM', 'New Mexico', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('0d46716f-e11d-e611-8319-00190e0c985e', 'NV', 'Nevada', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('0e46716f-e11d-e611-8319-00190e0c985e', 'NY', 'New York', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('0f46716f-e11d-e611-8319-00190e0c985e', 'OH', 'Ohio', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('1046716f-e11d-e611-8319-00190e0c985e', 'OK', 'Oklahoma', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('1146716f-e11d-e611-8319-00190e0c985e', 'OR', 'Oregon', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('1246716f-e11d-e611-8319-00190e0c985e', 'PA', 'Pennsylvania', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('1346716f-e11d-e611-8319-00190e0c985e', 'RI', 'Rhode Island', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('1446716f-e11d-e611-8319-00190e0c985e', 'SC', 'South Carolina', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('1546716f-e11d-e611-8319-00190e0c985e', 'SD', 'South Dakota', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('1646716f-e11d-e611-8319-00190e0c985e', 'TN', 'Tennessee', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('1746716f-e11d-e611-8319-00190e0c985e', 'TX', 'Texas', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('1846716f-e11d-e611-8319-00190e0c985e', 'UT', 'Utah', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('1946716f-e11d-e611-8319-00190e0c985e', 'VA', 'Virginia', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('1a46716f-e11d-e611-8319-00190e0c985e', 'VT', 'Vermont', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('1b46716f-e11d-e611-8319-00190e0c985e', 'WA', 'Washington', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('1c46716f-e11d-e611-8319-00190e0c985e', 'WI', 'Wisconsin', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('1d46716f-e11d-e611-8319-00190e0c985e', 'WV', 'West Virginia', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('1e46716f-e11d-e611-8319-00190e0c985e', 'WY', 'Wyoming', @countryGUID);

--Canadian Provinces

set @countryGUID = NEWID();

INSERT INTO [dbo].[Country] ([CountryGUID],[Abbreviation],[Description]) VALUES (@countryGUID,'CA','Canada')


INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('8515e081-3c07-e011-ad82-001ec9514fcd', 'AB', 'Alberta', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('8615e081-3c07-e011-ad82-001ec9514fcd', 'BC', 'British Columbia', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('8715e081-3c07-e011-ad82-001ec9514fcd', 'MB', 'Manitoba', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('8815e081-3c07-e011-ad82-001ec9514fcd', 'NB', 'New Brunswick', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('8915e081-3c07-e011-ad82-001ec9514fcd', 'NL', 'Newfoundland and Labrador', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('8a15e081-3c07-e011-ad82-001ec9514fcd', 'NS', 'Nova Scotia', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('8b15e081-3c07-e011-ad82-001ec9514fcd', 'NT', 'Northwest Territories', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('8c15e081-3c07-e011-ad82-001ec9514fcd', 'NU', 'Nunavut', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('8d15e081-3c07-e011-ad82-001ec9514fcd', 'ON', 'Ontario', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('8e15e081-3c07-e011-ad82-001ec9514fcd', 'PE', 'Prince Edward Island', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('8f15e081-3c07-e011-ad82-001ec9514fcd', 'QC', 'Quebec', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('9015e081-3c07-e011-ad82-001ec9514fcd', 'SK', 'Saskatchewan', @countryGUID);
INSERT INTO [StateProvince] ([StateProvinceGUID], [Abbreviation], [Description], [CountryGUID]) VALUES ('9115e081-3c07-e011-ad82-001ec9514fcd', 'YT', 'Yukon', @countryGUID);
