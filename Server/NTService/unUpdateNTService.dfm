object UpdateServerService: TUpdateServerService
  OldCreateOrder = False
  AllowPause = False
  DisplayName = 'Update Server Service'
  AfterInstall = ServiceAfterInstall
  AfterUninstall = ServiceAfterUninstall
  OnShutdown = ServiceShutdown
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 150
  Width = 215
end
