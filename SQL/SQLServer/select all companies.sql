/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 
      [Name]
	  ,cl.SiteName
	  ,l.description
	  ,A.StreetAddress
	  ,a.City
	  ,a.zipPostal
  FROM [Company] c
  join companylocation cl on c.companylocationguid = cl.companylocationGUID
  join location l on cl.locationguid = l.locationguid
  join address a on l.Addressguid = a.addressguid