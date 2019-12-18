unit fmAbout;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, jpeg, ExtCtrls, ImgList,
  ActnList;

type
  TfrmAbout = class(TForm)
    Image1: TImage;
    Label2: TLabel;
    laVersion: TLabel;
    laDebugInfo: TLabel;
    sbMemLeasktest: TSpeedButton;
    sbAVTest: TSpeedButton;
    btOK: TButton;
    procedure FormActivate(Sender: TObject);
    procedure sbMemLeasktestClick(Sender: TObject);
    procedure sbAVTestClick(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure btOKClick(Sender: TObject);
  private
  public
    class procedure Execute;
  end;

implementation

uses
  hcVersionText;

{$R *.DFM}


procedure TfrmAbout.btCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmAbout.btOKClick(Sender: TObject);
begin
  Close;
end;

class procedure TfrmAbout.Execute;
var
  dlg: TfrmAbout;
begin
  dlg := TfrmAbout.Create(nil);
  try
    {$ifdef FABUTAN}
    dlg.Image1.Visible := True;
    dlg.Caption := 'About Fabutan Update Manager';
    {$ELSE}
    dlg.Image1.Visible := False;
    dlg.Caption := 'About Update Manager';
    {$endif}
    dlg.Position := poMainFormCenter;
    dlg.BorderStyle := bsDialog;
    dlg.ShowModal;
  finally // wrap up
    dlg.Free;
  end;    // try/finally
end;

procedure TfrmAbout.FormActivate(Sender: TObject);
var
  sMessage: string;
begin
//  laVersion.Caption := MCForms.Application.ProgramVersion;
{$IFDEF EUREKALOG}
   {$IFDEF EUREKALOG_VER6}
     sMessage := 'Compiled with EurekaLog 6.x.';
   {$ELSE}
     {$IFDEF EUREKALOG_VER5}
       sMessage := 'Compiled with EurekaLog 5.x.';
     {$ELSE}
       sMessage := 'Compiled with EurekaLog 4.x.';
     {$ENDIF}
   {$ENDIF}
  {$ifdef DEBUG}
  sbAVTest.Visible := True;
  sbMemLeasktest.Visible := True;
  {$endif}  // DEBUG
{$ELSE}
   sMessage := 'Compiled without EurekaLog.';
{$ENDIF}

  laDebugInfo.Caption := sMessage;
  laVersion.Caption := GetFileVersionText;
end;



{$HINTS OFF}
procedure TfrmAbout.sbMemLeasktestClick(Sender: TObject);
var
  aLeak: TObject;
begin
  //test memory leak
  aLeak := TObject.Create;
end;

procedure TfrmAbout.sbAVTestClick(Sender: TObject);
begin
  PByte(nil)^ := 0;
end;
{$HINTS ON}

end.
