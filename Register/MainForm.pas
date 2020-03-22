unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm3 = class(TForm)
    Button1: TButton;
    laResult: TLabel;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

uses
  unUpdateClient;

procedure TForm3.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TForm3.FormShow(Sender: TObject);
var
  Client :TUpdateClient;
  sUpdateResult :string;
begin
  Client := TUpdateClient.Create(nil);
  try
    sUpdateResult := Client.RegisterInstall;
    laResult.Caption := sUpdateResult;
    if sUpdateResult.StartsWith('ERROR') then
      ExitCode := 99;
  finally
    Client.Free;
  end;
end;

end.
