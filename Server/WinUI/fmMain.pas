unit fmMain;

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.AppEvnts, Vcl.StdCtrls, IdHTTPWebBrokerBridge, Web.HTTPApp, Vcl.ActnList,
  Vcl.Samples.Spin, System.Actions
  {$ifdef Firebird}
  ,dmFireDAC
  {$else}
  ,dmADO
  {$endif}
  ;

type
  TfrmMain = class(TForm)
    ButtonStart: TButton;
    ButtonStop: TButton;
    EditPort: TEdit;
    Label1: TLabel;
    ApplicationEvents1: TApplicationEvents;
    ButtonOpenBrowser: TButton;
    actlst1: TActionList;
    actStart: TAction;
    actStop: TAction;
    seMaxConnections: TSpinEdit;
    la1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
    procedure ButtonOpenBrowserClick(Sender: TObject);
    procedure actStartUpdate(Sender: TObject);
    procedure actStartExecute(Sender: TObject);
    procedure actStopUpdate(Sender: TObject);
    procedure actStopExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    {$ifdef Firebird}
    FDataModule :TdtmFireDAC;
    {$else}
    FDataModule :TdtmADO;
    {$endif}
    FServer: TIdHTTPWebBrokerBridge;
    procedure StartServer;
  public
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  Winapi.ShellApi, Web.WebReq, IdException, Winapi.ActiveX
  ;

procedure TfrmMain.actStartExecute(Sender: TObject);
begin
  StartServer;
end;

procedure TfrmMain.actStartUpdate(Sender: TObject);
begin
  actStart.Enabled := not FServer.Active;
end;

procedure TfrmMain.actStopExecute(Sender: TObject);
begin
  FServer.Active := False;
  FServer.Bindings.Clear;
end;

procedure TfrmMain.actStopUpdate(Sender: TObject);
begin
  actStop.Enabled := FServer.Active;
end;

procedure TfrmMain.ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
begin
  ButtonStart.Enabled := not FServer.Active;
  ButtonStop.Enabled := FServer.Active;
  EditPort.Enabled := not FServer.Active;
end;

procedure TfrmMain.ButtonOpenBrowserClick(Sender: TObject);
var
  LURL: string;
begin
  StartServer;
  LURL := Format('http://localhost:%s', [EditPort.Text]);
  ShellExecute(0,nil,PChar(LURL), nil, nil, SW_SHOWNOACTIVATE);
end;


procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FServer.Active then
    FServer.Active := False;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  //TODO - load server config without creating datamodule
  CoInitialize(nil);
  //we don't use anything here other than the setting, but it's best to connect to the database when starting than wait until we receive the first request before we fail if cannot connect to DB
  {$ifdef Firebird}
  FDataModule := TdtmFireDAC.Create(nil);
  {$else}
  FDataModule := TdtmADO.Create(nil);
  {$endif}
  try
    seMaxConnections.Value := FDataModule.MaxConcurrentWebRequests;
    EditPort.Text := IntToStr(FDataModule.DefaultPort);
  finally
    FDatamodule.Free;
  end;


  FServer := TIdHTTPWebBrokerBridge.Create(Self);
end;

procedure TfrmMain.StartServer;
begin
  if not FServer.Active then
  begin
    FServer.Bindings.Clear;
    FServer.DefaultPort := StrToInt(EditPort.Text);
    WebRequestHandler.MaxConnections := seMaxConnections.Value;
    FServer.Active := True;
  end;
end;

end.
