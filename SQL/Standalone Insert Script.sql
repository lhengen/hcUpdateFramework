USE [Deployments]
GO

INSERT INTO [dbo].[Application]
           ([ApplicationGUID]
           ,[ApplicationName]
           ,[IsTrial])
     VALUES
           (NEWID()
		   ,'CAT'
           ,0)


INSERT INTO [dbo].[Location]
           ([LocationGUID]
           ,[LocationName]
           ,[Latitude]
           ,[Longitude])
     VALUES
           (newid()
           ,'Kinder Morgan Canada'
           , 	51.0833
           ,	-114.0833)
GO



