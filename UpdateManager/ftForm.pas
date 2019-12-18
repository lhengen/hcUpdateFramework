unit ftForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Registry;

type
  TftForm = class(TForm)
    procedure FormActivate(Sender: TObject);
  //forms which "know" how to save & restore their position but don't necessarily do so
  private
  protected
    procedure DoFormActivate; virtual; 
    procedure SavePosition; virtual;
    procedure RestorePosition; virtual;
    procedure Maximize;
  public
    procedure AfterConstruction; override;
    class function InstanceLimit :integer; virtual;
  end;
  TftFormClass = class of TftForm;


implementation

{$R *.DFM}

uses
  ftConsts
  ;


procedure TftForm.AfterConstruction;
begin
  Color := RGB($F1,$F0,$F1);   //set this before calling inherited so the Color is set before descendants FormCreate event is called
  
  //all forms must be no larger than 1024x768 (currently)
  Constraints.MaxWidth := ftConsts.MAX_WIDTH;
  Constraints.MaxHeight := ftConsts.MAX_HEIGHT;

  inherited AfterConstruction;
end;

class function TftForm.InstanceLimit:integer;
begin
  Result := 0;  //unlimited by default
end;

procedure TftForm.Maximize;
begin
  //maximize the form taking into account the application toolbar and Windows Taskbar
  //up to the maximum constrained size of 1024 x768
end;

procedure TftForm.RestorePosition;
(*
  Author: Larry Hengen
  Date: 09/11/2000
  Purpose:  Restore the window position from the registry.
*)
var
  Registry: TRegistry;
begin
  try
    Registry := TRegistry.Create;
    try
      with Registry do
      begin
        OpenKey(REG_ApplicationRegistryPath+'\'+Self.ClassName,True);
        Self.Top := ReadInteger('Top');
        Self.Left := ReadInteger('Left');
        Self.Height := ReadInteger('Height');
        Self.Width := ReadInteger('Width');
        CloseKey;
      end;  // with
    finally
      Registry.Free;
    end;
  except
    ; //do nothing if the entries were not found in the registry
  end;  // try/except
end;

procedure TftForm.SavePosition;
(*
  Author: Larry Hengen
  Date: 09/11/2000
  Purpose:  Save the window position and State to the registry.
*)
var
  Registry: TRegistry;
begin
  Registry := TRegistry.Create;
  try
    Registry.OpenKey(REG_ApplicationRegistryPath+'\'+Self.ClassName,True);
    Registry.WriteInteger('Top',Self.Top);
    Registry.WriteInteger('Left',Self.Left);
    Registry.WriteInteger('Height',Self.Height);
    Registry.WriteInteger('Width',Self.Width);
    Registry.CloseKey;
  finally
    Registry.Free;
  end;
end;


procedure TftForm.FormActivate(Sender: TObject);
begin                     
  //called when the user clicks on the form to activate it or when the window is first shown
  DoFormActivate;
end;

procedure TftForm.DoFormActivate;
begin
  //descendants need to override
end;

end.
