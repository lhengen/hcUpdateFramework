program PatchDemo;

uses
  Forms,
  Unit1 in 'Unit1.pas' {PatcherDemo},
  PatchAPI in 'API\PatchAPI.pas',
  uPatcher in 'API\uPatcher.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TPatcherDemo, PatcherDemo);
  Application.Run;
end.
