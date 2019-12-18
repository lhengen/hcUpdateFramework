unit TemporaryCursor;

interface

uses
  Vcl.Controls;

// .NET/C# Equivalent: http://wiert.me/2012/01/26/netc-using-idisposable-to-restore-temporary-settrings-example-temporarycursor-class/

type
  ITemporaryCursor = interface(IInterface)
    ['{495ADE0F-EFBE-4A0E-BF37-F1ACCACCE03D}']
  end;

  TTemporaryCursor = class(TInterfacedObject, ITemporaryCursor)
  strict private
    FCursor: TCursor;
  public
    constructor Create(const ACursor: TCursor);
    destructor Destroy; override;
    class function SetTemporaryCursor(const ACursor: TCursor = crHourGlass): ITemporaryCursor;
  end;

implementation

uses
  Vcl.Forms;

{ TTemporaryCursor }
constructor TTemporaryCursor.Create(const ACursor: TCursor);
begin
  inherited Create();
  FCursor := Screen.Cursor;
  Screen.Cursor := ACursor;
end;

destructor TTemporaryCursor.Destroy;
begin
  if Assigned(Screen) then
  begin
    Screen.Cursor := FCursor;
  end;
  inherited Destroy();
end;

class function TTemporaryCursor.SetTemporaryCursor(const ACursor: TCursor = crHourGlass): ITemporaryCursor;
begin
  Result := TTemporaryCursor.Create(ACursor);
end;

end.
