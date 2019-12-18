object ClientUpdater: TClientUpdater
  OldCreateOrder = False
  AllowPause = False
  DisplayName = 'Hengen Computing Client Update Service'
  Interactive = True
  AfterInstall = ServiceAfterInstall
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 150
  Width = 215
end
