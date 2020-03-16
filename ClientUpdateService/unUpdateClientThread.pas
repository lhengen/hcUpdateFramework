unit unUpdateClientThread;

interface

uses
  Classes, Windows, unUpdateClient, SvcMgr, unApplyUpdate;

type
  TUpdateClientThread = class(TThread)
  private
    FUpdateProgress :TStringList;
    FService :TService;
    FClientUpdate :TUpdateClient;
    FUpdateApplier :ThcUpdateApplier;
    procedure OnUpdateFailure(UpdateVersion, UpdateErrorMessage: string);
    procedure OnProgressUpdate(Sender: TObject);
  protected
    procedure Execute; override;
  public
    property Service :TService read FService write FService;
  end;

implementation

uses
  IniFiles, SysUtils, unPath, hcUpdateSettings;

{ 
  Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure UpdateClientThread.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; 
    
    or 
    
    Synchronize( 
      procedure 
      begin
        Form1.Caption := 'Updated in thread via an anonymous method' 
      end
      )
    );
    
  where an anonymous method is passed.
  
  Similarly, the developer can call the Queue method with similar parameters as 
  above, instead passing another TThread class as the first parameter, putting
  the calling thread in a queue with the other thread.

}

{ UpdateClientThread }

procedure TUpdateClientThread.Execute;
var
  sResult :string;
begin
  NameThreadForDebugging('UpdateClientThread');
  { Place thread code here }
  FUpdateProgress := TStringList.Create;
  try
    FClientUpdate := TUpdateClient.Create(nil);
    try
      while not Terminated do
      begin
        if AutoUpdateSettings.LogAllMessages then
          Service.LogMessage(Format('URI is %s',[AutoUpdateSettings.WebServiceURI]),EVENTLOG_INFORMATION_TYPE,0,0);

        FUpdateProgress.Clear;  //clear messages from previous run
        try
          sResult := FClientUpdate.CheckForUpdates;
          if AutoUpdateSettings.LogAllMessages then
            Service.LogMessage(sResult,EVENTLOG_INFORMATION_TYPE,0,0);
          //check if we are to apply the update and do so
          FUpdateApplier := ThcUpdateApplier.Create;
          try
            FUpdateApplier.ApplySilentUpdates := True;  //ClientUpdateService is the only process that applies silent updates
            FUpdateApplier.OnApplyUpdateError := OnUpdateFailure;
            FUpdateApplier.OnProgressUpdate := OnProgressUpdate;
            FUpdateApplier.CheckForUpdatesAndApply;
            Service.LogMessage(FUpdateProgress.Text,EVENTLOG_INFORMATION_TYPE,0,0);
          finally
            FUpdateApplier.Free;
          end;
        except
          on E: Exception do
          begin
            Service.LogMessage(FUpdateProgress.Text,EVENTLOG_INFORMATION_TYPE,0,0);
            Service.LogMessage(E.Message,EVENTLOG_ERROR_TYPE,0,103);
          end;
        end;

        if AutoUpdateSettings.LogAllMessages then
          Service.LogMessage(Format('Sleeping for %d minutes',[AutoUpdateSettings.SleepTimeInMinutes]),EVENTLOG_INFORMATION_TYPE,0,0);
        Sleep(AutoUpdateSettings.SleepTimeInMinutes * SecsPerMin * MSecsPerSec);
      end;
    finally
      FClientUpdate.Free;
    end;
  finally
    FUpdateProgress.Free;
  end;
end;

procedure TUpdateClientThread.OnProgressUpdate(Sender :TObject);
{
  This event is called every time a line is added so just add
  the last line to the TMemo and scroll it into view.
}
begin
  FUpdateProgress.Add(FUpdateApplier.Progress[FUpdateApplier.Progress.Count - 1]);
end;

procedure TUpdateClientThread.OnUpdateFailure(UpdateVersion, UpdateErrorMessage: string);
begin
  Service.LogMessage(Format('An error occurred while applying the %s update.  The error reported was: %s',[UpdateVersion,UpdateErrorMessage]),EVENTLOG_ERROR_TYPE,0,103);
end;



end.
