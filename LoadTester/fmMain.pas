unit fmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfrmMain = class(TForm)
    led1: TLabeledEdit;
    btStart: TButton;
    btStop: TButton;
    laThreadsRunning: TLabel;
    procedure btStartClick(Sender: TObject);
    procedure btStopClick(Sender: TObject);
  private
    FThreadList :TList;
    procedure ThreadTerminated(Sender: TObject);
    procedure UpdateThreadCount;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  end;

var
  frmMain: TfrmMain;

implementation

uses
  unClientUpdateThread;

{$R *.dfm}

procedure TfrmMain.AfterConstruction;
begin
  inherited;
  FThreadList := TList.Create;
  laThreadsRunning.Caption := Format('%d Threads are Running',[FThreadList.Count]);
end;

procedure TfrmMain.BeforeDestruction;
begin
  FThreadList.Free;
  inherited;
end;

procedure TfrmMain.btStartClick(Sender: TObject);
var
  nMax,
  I :integer;
  aThread :TUpdateClientThread;
begin
  nMax := StrToInt(led1.Text);
  for I := 1 to nMax do
  begin
    aThread := TUpdateClientThread.Create(True);
    aThread.URI := 'http://localhost:8080/soap/IUpdateService';
    aThread.OnTerminate := ThreadTerminated;
    aThread.FreeOnTerminate := False;
    FThreadList.Add(aThread);
    aThread.Resume;
    ThreadTerminated(Self);
  end;
end;

procedure TfrmMain.btStopClick(Sender: TObject);
var
  I :integer;
  aThread :TUpdateClientThread;
begin
  for I := FThreadList.Count -1 downto 0 do
  begin
    aThread := TUpdateClientThread(FThreadList[I]);
    FThreadList.Remove(aThread);
    aThread.Terminate;
    aThread.WaitFor;
    aThread.Free;
    ThreadTerminated(Self);
  end;
end;

procedure TfrmMain.ThreadTerminated(Sender: TObject);
begin
  UpdateThreadCount;
end;


procedure TfrmMain.UpdateThreadCount;
begin
  laThreadsRunning.Caption := Format('%d Threads are Running',[FThreadList.Count]);
  Application.ProcessMessages;
end;


end.
