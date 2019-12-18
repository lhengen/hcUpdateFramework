unit unClientUpdateThread;

interface

uses
  System.Classes;

type
  TUpdateClientThread = class(TThread)
  private
    FURI :string;
  protected
    procedure Execute; override;
  public
    property URI :string read FURI write FURI;
  end;

implementation

uses
  unUpdateClient;

{
  Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure TUpdateClientThread.UpdateCaption;
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

{ TUpdateClientThread }

procedure TUpdateClientThread.Execute;
var
  Client :TUpdateClient;
begin
  NameThreadForDebugging('UpdateClientThread');
  { Place thread code here }
  while not Terminated do
  begin
    Client := TUpdateClient.Create(nil);
    try
      Client.URI := FURI;
      Client.CheckForUpdates;
    finally
      Client.Free;
    end;
  end;
end;

end.
