
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO


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


CREATE TABLE [dbo].[StudioDeployment](
	[StudioGUID] [uniqueidentifier] NOT NULL,
	[DeploymentGUID] [uniqueidentifier] NOT NULL,
	[IsAvailable] [bit] NOT NULL,
	[UpdatedUTCDate] [datetime] NULL,
	[LastAttemptUTCDate] [datetime] NULL,
	[UpdateResult] [varchar](50) NULL,
	[UpdateLog] [nvarchar](max) NULL,
	[AvailableUTCDate] [datetime] NULL,
	[ReceivedUTCDate] [datetime] NULL,
 CONSTRAINT [PK_StudioDeployment] PRIMARY KEY CLUSTERED 
(
	[StudioGUID] ASC,
	[DeploymentGUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is the update deployment available to this studio?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'StudioDeployment', @level2type=N'COLUMN',@level2name=N'IsAvailable'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'when the update was applied' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'StudioDeployment', @level2type=N'COLUMN',@level2name=N'UpdatedUTCDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'when the last attempt to apply the update was made (= UpdatedUTCDate is successfully applied)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'StudioDeployment', @level2type=N'COLUMN',@level2name=N'LastAttemptUTCDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'The result of the last update attempt (success or failure)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'StudioDeployment', @level2type=N'COLUMN',@level2name=N'UpdateResult'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'contents of client side update log' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'StudioDeployment', @level2type=N'COLUMN',@level2name=N'UpdateLog'
GO

ALTER TABLE [dbo].[StudioDeployment]  WITH CHECK ADD  CONSTRAINT [FK_Studio] FOREIGN KEY([StudioGUID])
REFERENCES [dbo].[Studio] ([StudioGUID])
GO

ALTER TABLE [dbo].[StudioDeployment] CHECK CONSTRAINT [FK_Studio]
GO

ALTER TABLE [dbo].[StudioDeployment]  WITH CHECK ADD  CONSTRAINT [CK_StudioDeploymentUpdateResult] CHECK  (([UpdateResult]='Failure' OR [UpdateResult]='Success' OR [UpdateResult]=NULL))
GO

ALTER TABLE [dbo].[StudioDeployment] CHECK CONSTRAINT [CK_StudioDeploymentUpdateResult]
GO

ALTER TABLE [dbo].[StudioDeployment] ADD  CONSTRAINT [DF_StudioDeployment_UpdateResult]  DEFAULT (NULL) FOR [UpdateResult]
GO


