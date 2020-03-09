select * from StudioDeployment where StudioGUID = (Select StudioGUID from Studio where StudioNumber = 1) and DeploymentGUID = 'B6531F5D-93F2-4A95-BD0F-588E295B04D0'

update StudioDeployment set ReceivedUTCDate = null  where StudioGUID = (Select StudioGUID from Studio where StudioNumber = 155) and DeploymentGUID = 'B6531F5D-93F2-4A95-BD0F-588E295B04D0'