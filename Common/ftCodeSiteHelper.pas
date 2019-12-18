unit ftCodeSiteHelper;

interface

{$I codesite.inc}

uses
  ADODB
  ;

{$ifdef hcCodeSite}
procedure LogQueryOpen(aQuery :TADOQuery);
procedure LogStoredProcOpen(aProc :TADOStoredProc);
procedure LogStoredProcCall(aProc :TADOStoredProc);
{$else}
procedure LogStoredProcCall(aProc :TADOStoredProc);
procedure LogStoredProcOpen(aProc :TADOStoredProc);
procedure LogQueryOpen(aQuery :TADOQuery);
{$endif}  // hcCodeSite


implementation

uses
  hcCodeSiteHelper
  ,Variants
  ,SysUtils
  ,hcFunctions
  ;

{$ifdef hcCodeSite}

procedure LogQueryOpen(aQuery :TADOQuery);
var
  I: Integer;
  bOpen: boolean;
  dtStart,
  dtEnd :TDateTime;
begin
  hcCodeSite.SendSQL(aQuery.SQL.Text);

  //output all parameters
  for I := 0 to aQuery.Parameters.Count - 1 do    // Iterate
  begin
    if VarIsNull(aQuery.Parameters.Items[I].Value) then
      hcCodeSite.SendSQL(Format('Parameter %d - Name: %s Value: %s ',[I,aQuery.Parameters.Items[I].Name,'<Null>']))
    else
      hcCodeSite.SendSQL(Format('Parameter %d - Name: %s Value: %s ',[I,aQuery.Parameters.Items[I].Name,aQuery.Parameters.Items[I].Value]));
  end;    // for

  bOpen := False;
  dtStart := Now;
  try
    try
      aQuery.Open;
      bOpen := True;
    except
      on E: Exception do
      begin
        hcCodeSite.SendSQLException(E);
        raise;
      end;
    end;
  finally
    dtEnd := Now;
    if bOpen then
      hcCodeSite.SendSQL(Format('Rows Returned: %d  %s',[aQuery.RecordCount,GetDurationInMilliSecs(dtStart, dtEnd)]));
  end;
  hcCodeSite.AddSeperator;
end;
{$else}

procedure LogQueryOpen(aQuery :TADOQuery);
begin
  aQuery.Open;
end;
{$endif}  // hcCodeSite


{$ifdef hcCodeSite}
procedure LogStoredProcOpen(aProc :TADOStoredProc);
var
  I: Integer;
begin
  for I := 0 to aProc.Parameters.Count - 1 do    // Iterate
  begin
    if VarIsNull(aProc.Parameters[I].Value) then
      hcCodeSite.SendSQL(Format('Parameter %d - Name: %s Value: %s ',[I,aProc.Parameters[I].Name,'<Null>']))
    else
      hcCodeSite.SendSQL(Format('Parameter %d - Name: %s Value: %s ',[I,aProc.Parameters[I].Name,aProc.Parameters[I].Value]));
  end;    // for

  hcCodeSite.SendSQL(Format('Open %s',[aProc.ProcedureName]));
  aProc.Open;

  //output all Output and InputOutput parameters
  for I := 0 to aProc.Parameters.Count - 1 do    // Iterate
  begin
    if aProc.Parameters[I].Direction in [pdInput,pdInputOutput,pdReturnValue] then
    begin
      if VarIsNull(aProc.Parameters[I].Value) then
        hcCodeSite.SendSQL(Format('Parameter %d - Name: %s Value: %s ',[I,aProc.Parameters[I].Name,'<Null>']))
      else
        hcCodeSite.SendSQL(Format('Parameter %d - Name: %s Value: %s ',[I,aProc.Parameters[I].Name,aProc.Parameters[I].Value]));
    end;
  end;    // for
  if aProc.Parameters.ParamByName('@RETURN_VALUE').Value <> 0 then
    hcCodeSite.SendError(Format('Procedure %s returned an error code of %s',[aProc.ProcedureName,aProc.Parameters.ParamByName('@RETURN_VALUE').Value]));

  hcCodeSite.AddSeperator;
end;

procedure LogStoredProcCall(aProc :TADOStoredProc);
var
  I: Integer;
begin
  for I := 0 to aProc.Parameters.Count - 1 do    // Iterate
  begin
    if VarIsNull(aProc.Parameters[I].Value) then
      hcCodeSite.SendSQL(Format('Parameter %d - Name: %s Value: %s ',[I,aProc.Parameters[I].Name,'<Null>']))
    else
      hcCodeSite.SendSQL(Format('Parameter %d - Name: %s Value: %s ',[I,aProc.Parameters[I].Name,aProc.Parameters[I].Value]));
  end;    // for

  hcCodeSite.SendSQL(Format('Exec %s',[aProc.ProcedureName]));
  aProc.ExecProc;

  //output all Output and InputOutput parameters
  for I := 0 to aProc.Parameters.Count - 1 do    // Iterate
  begin
    if aProc.Parameters[I].Direction in [pdInput,pdInputOutput,pdReturnValue] then
    begin
      if VarIsNull(aProc.Parameters[I].Value) then
        hcCodeSite.SendSQL(Format('Parameter %d - Name: %s Value: %s ',[I,aProc.Parameters[I].Name,'<Null>']))
      else
        hcCodeSite.SendSQL(Format('Parameter %d - Name: %s Value: %s ',[I,aProc.Parameters[I].Name,aProc.Parameters[I].Value]));
    end;
  end;    // for
  if aProc.Parameters.ParamByName('@RETURN_VALUE').Value <> 0 then
    hcCodeSite.SendError(Format('Procedure %s returned an error code of %s',[aProc.ProcedureName,aProc.Parameters.ParamByName('@RETURN_VALUE').Value]));

  hcCodeSite.AddSeperator;
end;
{$else}
procedure LogStoredProcOpen(aProc :TADOStoredProc);
begin
  aProc.Open;
end;

procedure LogStoredProcCall(aProc :TADOStoredProc);
begin
  aProc.ExecProc;
end;
{$endif}



end.
