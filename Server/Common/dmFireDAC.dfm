object dtmFireDAC: TdtmFireDAC
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 169
  Width = 300
  object qryWorker: TFDQuery
    Connection = cnDeployment
    Left = 192
    Top = 48
  end
  object cnDeployment: TFDConnection
    Params.Strings = (
      'Database=C:\Data\SkyStone\DEPLOYMENT.FDB'
      'User_Name=SYSDBA'
      'Password=masterkey'
      'DriverID=FB')
    FetchOptions.AssignedValues = [evMode, evRecordCountMode, evUnidirectional]
    FetchOptions.Mode = fmAll
    FetchOptions.Unidirectional = True
    FetchOptions.RecordCountMode = cmFetched
    Left = 88
    Top = 48
  end
  object FDMoniRemoteClientLink1: TFDMoniRemoteClientLink
    Left = 176
    Top = 120
  end
end
