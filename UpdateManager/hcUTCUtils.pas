unit hcUTCUtils;

interface

function GetUTC: TDateTime;
function MakeUTCTime(DateTime: TDateTime): TDateTime;

implementation

uses
   Winapi.Windows
   ,SysUtils
   ;

function GetUTC: TDateTime;
var
  stim: SYSTEMTIME;
begin
  GetSystemTime(stim);
  result := SystemTimeToDateTime(stim);
end;

function MakeUTCTime(DateTime: TDateTime): TDateTime;
{
  Converts a local datetime value into UTC.
}
var
  TZI: TTimeZoneInformation;
  Bias :LongInt;  //difference in Minutes from UTC (aka GMT) time
begin
  case GetTimeZoneInformation(TZI) of
    TIME_ZONE_ID_STANDARD:
      Bias := TZI.Bias;
    TIME_ZONE_ID_DAYLIGHT:
      Bias := TZI.Bias + TZI.DaylightBias;
  else
    raise
      Exception.Create('Error converting to UTC Time. Time zone could not be determined.');
  end;
  Result := DateTime + (Bias / MinsPerHour / HoursPerDay);
end;

end.
