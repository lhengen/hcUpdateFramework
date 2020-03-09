USE [Deployment]
GO

/****** Object:  StoredProcedure [dbo].[spCreateDeployment]    Script Date: 02/10/2017 13:49:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Larry Hengen
-- Create date: April 13, 2012
-- Description:	Creates a new Deployment record with default LocationDeployment records for all active Locations
-- =============================================
CREATE PROCEDURE [dbo].[spCreateDeployment] 
	@applicationGUID uniqueidentifier, 
	@version varchar(50) = 0, 
	@whatsNew varchar(max) = 0,
	@IsImmediate bit = 0,
	@IsSilent bit = 0,
	@IsMandatory bit = 0,
	@deploymentGUID uniqueidentifier OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	set @deploymentGUID = newid()
	
	--create new Deployment record
	INSERT INTO [dbo].[Deployment]
           (
						[DeploymentGUID]
           ,[UpdateVersion]
           ,[WhatsNew]
           ,[ApplicationGUID]
           ,[IsImmediate]
           ,[IsSilent]
           ,[IsMandatory]
           )
     VALUES
           (
						@deploymentGUID
           ,@version
           ,@whatsNew
           ,@applicationGUID
           ,@IsImmediate
           ,@IsSilent
           ,@IsMandatory
           )
         
	INSERT INTO [dbo].[LocationDeployment]
			   ([LocationGUID]
			   ,[DeploymentGUID]
			   ,[IsAvailable]
			   ,[AvailableUTCDate]
			   ,[UpdatedUTCDate]
			   ,[LastAttemptUTCDate]
			   ,[UpdateResult]
			   ,[UpdateLog]
			   )
	     
			Select LocationGUID 
			,@deploymentGUID
			,0
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			from Location            
           
END

GO


