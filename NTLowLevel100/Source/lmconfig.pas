unit lmconfig;

interface

uses lmglobal;

type
 CONFIG_INFO_0 = record
   cfgi0_key : PWideChar;
   cfgi0_data : PWideChar;
 end;
 PCONFIG_INFO_0 = ^CONFIG_INFO_0;

function NetConfigGet (
  server, component, parameter : PWideChar;
  var buffer : Pointer) : NetAPIStatus; stdcall;

function NetConfigGetAll (
  server, component : PWideChar;
  var buffer : Pointer) : NetAPIStatus; stdcall;

function NetConfigSet (
  server, reserved1, component : PWideChar;
  level1, reserved2 : Integer;
  buffer : Pointer;
  reserved3 : Integer) : NetAPIStatus; stdcall;

implementation

function NetConfigGet;     external 'NETAPI32.DLL';
function NetConfigGetAll;  external 'NETAPI32.DLL';
function NetConfigSet;     external 'NETAPI32.DLL';

end.
