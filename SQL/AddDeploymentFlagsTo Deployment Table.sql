ALTER TABLE dbo.Deployment ADD
	IsMandatory bit NOT NULL default(0),
	IsSilent bit NOT NULL default(0),
	IsImmediate bit NOT NULL default(0)
GO