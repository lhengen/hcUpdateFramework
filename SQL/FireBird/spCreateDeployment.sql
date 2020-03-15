SET TERM ^ ;
ALTER PROCEDURE SPCREATEDEPLOYMENT (
    APPLICATIONGUID GUID,
    "VERSION" VARCHAR(50),
    WHATSNEW VARCHAR(8192),
    ISIMMEDIATE BOOLEAN DEFAULT FALSE,
    ISSILENT BOOLEAN DEFAULT FALSE,
    ISMANDATORY BOOLEAN DEFAULT FALSE )
RETURNS (
    DEPLOYMENTGUID GUID )
AS
BEGIN
	 select gen_uuid() from RDB$Database into :deploymentGUID;

	--create new Deployment record
	INSERT INTO DEPLOYMENT
           (
            DEPLOYMENTGUID
           ,UPDATEVERSION
           ,WHATSNEW
           ,APPLICATIONGUID
           ,ISIMMEDIATE
           ,ISSILENT
           ,ISMANDATORY
           )
     VALUES
           (
            :deploymentGUID
           ,:version
           ,:whatsNew
           ,:applicationGUID
           ,:IsImmediate
           ,:IsSilent
           ,:IsMandatory
           );
    
      	INSERT INTO INSTALLATIONDEPLOYMENT
			   (INSTALLATIONGUID
			   ,DEPLOYMENTGUID
			   ,ISAVAILABLE
			   ,AVAILABLEUTCDATE
			   ,UPDATEDUTCDATE
			   ,LASTATTEMPTUTCDATE
			   ,UPDATERESULT
			   ,UPDATELOG
			   )

			Select INSTALLATIONGUID 
			,:deploymentGUID
			,0
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			from INSTALLATION;   
            
END^
SET TERM ; ^


GRANT EXECUTE
 ON PROCEDURE SPCREATEDEPLOYMENT TO  SYSDBA WITH GRANT OPTION;

