unit unPath;

interface

uses
  Windows
  ;
  
function AppFileName: string;
procedure Write2EventLog(Source,Msg: string);

implementation

function AppFileName: string;
var
  FileName: array [0..MAX_PATH] of Char;
begin
  if IsLibrary then
  begin
    GetModuleFileName(HInstance, FileName, SizeOf(FileName) - 1);
    Result := FileName;
  end
  else
    Result := ParamStr(0);
end;

procedure Write2EventLog(Source,Msg: string);
var h: THandle;
    ss: array [0..0] of pchar;
begin
    ss[0] := pchar(Msg);
    h := RegisterEventSource(nil,  // uses local computer
             pchar(Source));          // source name
    if h <> 0 then
      ReportEvent(h,           // event log handle
            EVENTLOG_ERROR_TYPE,  // event type
            0,                    // category zero
            0,        // event identifier
            nil,                 // no user security identifier
            1,                    // one substitution string
            0,                    // no data
            @ss,     // pointer to string array
            nil);                // pointer to data
    DeregisterEventSource(h);
end;



end.

