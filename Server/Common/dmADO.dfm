object dtmADO: TdtmADO
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 263
  Width = 387
  object cnDeployment: TADOConnection
    ConnectionString = 
      'Provider=SQLOLEDB.1;Integrated Security=SSPI;Persist Security In' +
      'fo=False;Initial Catalog=Deployment;'
    ConnectionTimeout = 30
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 56
    Top = 40
  end
  object qryWorker: TADOQuery
    Connection = cnDeployment
    Parameters = <>
    Left = 152
    Top = 40
  end
end
