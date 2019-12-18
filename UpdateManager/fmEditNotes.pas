unit fmEditNOtes;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TfrmEditNotes = class(TForm)
    meNotes: TRichEdit;
    btOK: TButton;
    btCancel: TButton;
    chkUpdateManifest: TCheckBox;
  private
    procedure SetNotes(Value :string);
    function GetNotes :string;
  public
    property Notes :string read GetNotes write SetNotes;
  end;

var
  frmEditNotes: TfrmEditNotes;

implementation

{$R *.dfm}


function TfrmEditNotes.GetNotes: string;
begin
  result := meNotes.Lines.Text;
end;

procedure TfrmEditNotes.SetNotes(Value: string);
var
  stringStream :TStringStream;
begin
  stringStream := TStringStream.Create(Value);
  try
    meNotes.Lines.LoadFromStream(stringStream);
  finally
    stringStream.Free;
  end;
end;

end.
