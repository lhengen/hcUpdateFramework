unit ftDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, 
  ImgList, ActnList, ftForm, ftButtons, AdvShapeButton, ftAdvShapeButton;

type
  TfrmDialog = class(TftForm)
    btOK: TftOKButton;
    btCancel: TftCancelButton;
    alDialogActions: TActionList;
    actOk: TAction;
    actCancel: TAction;
    procedure actCancelExecute(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormActivate(Sender: TObject);
  private
  public
    procedure CreateParams(var Params: TCreateParams); override;
  end;

implementation

{$R *.dfm}

procedure TfrmDialog.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style or WS_POPUP;
  if assigned(Owner) then
    Params.WndParent := (Owner as TWinControl).Handle;
end;

procedure TfrmDialog.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmDialog.actOkExecute(Sender: TObject);
begin
  //switch focus to another WinControl to ensure the current focused editor updates it's Subject
  SelectNext(ActiveControl as TWinControl,True,True);
  ModalResult := mrOK;
end;

procedure TfrmDialog.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if (Ord(Key) = VK_RETURN) and
    ((ActiveControl <> nil) and (ActiveControl.ClassType <> TMemo)) or
    (ActiveControl = nil) then
  begin
    Key := #0;
    actOk.Execute;
  end
  else
  if (Ord(Key) = VK_ESCAPE) then
  begin
    Key := #0;  //don't forward it on for processing
    actCancel.Execute;
  end;
end;

procedure TfrmDialog.FormActivate(Sender: TObject);
begin
  inherited;
  //keep method
end;

end.
