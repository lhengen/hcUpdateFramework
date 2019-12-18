SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO


use Deployment
GO


CREATE TABLE [dbo].[Country](
	[CountryGUID] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[Abbreviation] [char](2) NOT NULL,
	[Description] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Country] PRIMARY KEY CLUSTERED 
(
	[CountryGUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[StateProvince](
	[StateProvinceGUID] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[Abbreviation] [char](2) NOT NULL,
	[Description] [varchar](50) NOT NULL,
	[CountryGUID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_StateProvince] PRIMARY KEY CLUSTERED 
(
	[StateProvinceGUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[StateProvince] ADD  CONSTRAINT [DF_StateProvince_StateProvinceGUID]  DEFAULT (newsequentialid()) FOR [StateProvinceGUID]
GO

CREATE TABLE [dbo].[Address](
	[AddressGUID] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[StreetAddress] [varchar](50) NULL,
	[City] [varchar](50) NULL,
	[StateProvinceGUID] [uniqueidentifier] NULL,
	[ZipPostal] [varchar](10) NULL,
 CONSTRAINT [PK_Address] PRIMARY KEY CLUSTERED 
(
	[AddressGUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[Address]  WITH NOCHECK ADD  CONSTRAINT [FK_Address_StateProvinceGUID] FOREIGN KEY([StateProvinceGUID])
REFERENCES [dbo].[StateProvince] ([StateProvinceGUID])
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[Address] CHECK CONSTRAINT [FK_Address_StateProvinceGUID]
GO

ALTER TABLE [dbo].[Address]  WITH NOCHECK ADD  CONSTRAINT [CK_Address_ZipPostal] CHECK NOT FOR REPLICATION (([ZipPostal] like '[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]' OR [ZipPostal] like '[0-9][0-9][0-9][0-9][0-9]' OR [ZipPostal] like '[a-z][0-9][a-z][0-9][a-z][0-9]' OR [ZipPostal]=''))
GO

ALTER TABLE [dbo].[Address] CHECK CONSTRAINT [CK_Address_ZipPostal]
GO

ALTER TABLE [dbo].[Address] ADD  CONSTRAINT [DF_Address_AddressGUID]  DEFAULT (newsequentialid()) FOR [AddressGUID]
GO

CREATE TABLE [dbo].[Installation](
	[InstallationGUID] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[DeviceName] [varchar](50) NOT NULL,
	[LocationGUID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Installation] PRIMARY KEY CLUSTERED 
(
	[LocationGUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

/* a location may be an address or lat/long or both.  Lat/Long locations may be described */
CREATE TABLE [dbo].[Location](
	[LocationGUID] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[AddressGUID] [uniqueidentifier] NULL,
	[Description] [varchar](50) NULL,
	[Latitude] [float]  NULL,
	[Longitude] [float]  NULL,
 CONSTRAINT [PK_Location] PRIMARY KEY CLUSTERED 
(
	[LocationGUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]


CREATE TABLE [dbo].[Company](
	[CompanyGUID] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[CompanyLocationGUID] [uniqueidentifier]  NULL,
 CONSTRAINT [PK_Company] PRIMARY KEY CLUSTERED 
(
	[CompanyGUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

CREATE TABLE [dbo].[CompanyLocation](
	[CompanyLocationGUID] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[CompanyGUID] [uniqueidentifier] NOT NULL,
	[LocationGUID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_CompanyLocation] PRIMARY KEY CLUSTERED 
(
	[CompanyLocationGUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]


CREATE TABLE [dbo].[Application](
	[ApplicationGUID] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ApplicationName] [varchar](50) NOT NULL,
	[IsTrial] [bit] NOT NULL,
 CONSTRAINT [PK_Application] PRIMARY KEY CLUSTERED 
(
	[ApplicationGUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]


CREATE TABLE [dbo].[Deployment](
	[DeploymentGUID] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[UpdateVersion] [varchar](50) NOT NULL,
	[WhatsNew] [varchar](max) NOT NULL,
	[ApplicationGUID] [uniqueidentifier] NOT NULL,
	[Status] [varchar](50) NOT NULL,
	[CreatedUTCDate] [datetime] NOT NULL,
	[IsMandatory] [bit] NOT NULL,
	[IsSilent] [bit] NOT NULL,
	[IsImmediate] [bit] NOT NULL,
 CONSTRAINT [PK_Deployment] PRIMARY KEY CLUSTERED 
(
	[DeploymentGUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Deployment]  WITH CHECK ADD CHECK  (([Status]='Cancelled' OR [Status]='Completed' OR [Status]='Active'))
GO

ALTER TABLE [dbo].[Deployment] ADD  CONSTRAINT [DF_Deployment_DeploymentGUID]  DEFAULT (newsequentialid()) FOR [DeploymentGUID]
GO

ALTER TABLE [dbo].[Deployment] ADD  DEFAULT ('Active') FOR [Status]
GO

ALTER TABLE [dbo].[Deployment] ADD  DEFAULT (getutcdate()) FOR [CreatedUTCDate]
GO

ALTER TABLE [dbo].[Deployment] ADD  DEFAULT ((0)) FOR [IsMandatory]
GO

ALTER TABLE [dbo].[Deployment] ADD  DEFAULT ((0)) FOR [IsSilent]
GO

ALTER TABLE [dbo].[Deployment] ADD  DEFAULT ((0)) FOR [IsImmediate]
GO


CREATE TABLE [dbo].[LocationDeployment](
	[LocationGUID] [uniqueidentifier] NOT NULL,
	[DeploymentGUID] [uniqueidentifier] NOT NULL,
	[IsAvailable] [bit] NOT NULL,
	[UpdatedUTCDate] [datetime] NULL,
	[LastAttemptUTCDate] [datetime] NULL,
	[UpdateResult] [varchar](50) NULL,
	[UpdateLog] [nvarchar](max) NULL,
	[AvailableUTCDate] [datetime] NULL,
	[ReceivedUTCDate] [datetime] NULL,
 CONSTRAINT [PK_LocationDeployment] PRIMARY KEY CLUSTERED 
(
	[LocationGUID] ASC,
	[DeploymentGUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is the update deployment available to this location?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocationDeployment', @level2type=N'COLUMN',@level2name=N'IsAvailable'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'when the update was applied' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocationDeployment', @level2type=N'COLUMN',@level2name=N'UpdatedUTCDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'when the last attempt to apply the update was made (= UpdatedUTCDate is successfully applied)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocationDeployment', @level2type=N'COLUMN',@level2name=N'LastAttemptUTCDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The result of the last update attempt (success or failure)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocationDeployment', @level2type=N'COLUMN',@level2name=N'UpdateResult'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'contents of client side update log' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LocationDeployment', @level2type=N'COLUMN',@level2name=N'UpdateLog'
GO

ALTER TABLE [dbo].[LocationDeployment]  WITH CHECK ADD  CONSTRAINT [FK_Location] FOREIGN KEY([LocationGUID])
REFERENCES [dbo].[Location] ([LocationGUID])
GO

ALTER TABLE [dbo].[LocationDeployment] CHECK CONSTRAINT [FK_Location]
GO

ALTER TABLE [dbo].[LocationDeployment]  WITH CHECK ADD  CONSTRAINT [CK_LocationDeploymentUpdateResult] CHECK  (([UpdateResult]='Failure' OR [UpdateResult]='Success' OR [UpdateResult]=NULL))
GO

ALTER TABLE [dbo].[LocationDeployment] CHECK CONSTRAINT [CK_LocationDeploymentUpdateResult]
GO

ALTER TABLE [dbo].[LocationDeployment] ADD  CONSTRAINT [DF_LocationDeployment_UpdateResult]  DEFAULT (NULL) FOR [UpdateResult]
GO


