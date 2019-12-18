(*======================================================================*
 | unitDebugService                                                     |
 |                                                                      |
 | TDebugServiceApplication allows you to run and debug a service like  |
 | regular application                                                  |
 |                                                                      |
 | The contents of this file are subject to the Mozilla Public License  |
 | Version 1.1 (the "License"); you may not use this file except in     |
 | compliance with the License. You may obtain a copy of the License    |
 | at http://www.mozilla.org/MPL/                                       |
 |                                                                      |
 | Software distributed under the License is distributed on an "AS IS"  |
 | basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See  |
 | the License for the specific language governing rights and           |
 | limitations under the License.                                       |
 |                                                                      |
 | Copyright © Colin Wilson 2002  All Rights Reserved
 |                                                                      |
 | Version  Date        By    Description                               |
 | -------  ----------  ----  ------------------------------------------|
 | 1.0      19/09/2002  CPWW  Original                                  |
 *======================================================================*)

unit unitDebugService;

interface

uses Windows, Messages, Consts, Classes, SysUtils, Forms, SvcMgr;

type

//---------------------------------------------------------------------
// TDebugServiceApplication class
TDebugServiceApplication = class (TServiceApplication)
private
  procedure OnExceptionHandler(Sender: TObject; E: Exception);
public
  procedure Run; override;
  destructor Destroy; override;
  procedure TerminateThreads (all : boolean);
end;

//---------------------------------------------------------------------
// TDebugServiceThread class
TDebugServiceThread = class (TThread)
private
  fService : TService;
  procedure ProcessRequests(WaitForMessage: Boolean);
protected
  procedure Execute; override;
public
  constructor Create (AService : TService);
end;

implementation

{ TDebugServiceApplication }

(*----------------------------------------------------------------------*
 | procedure TDebugServiceApplication.OnExceptionHandler                |
 |                                                                      |
 | Handler for VCL exceptions                                           |
 |                                                                      |
 | Parameters:                                                          |
 |   Sender: TObject; E: Exception                                      |
 *----------------------------------------------------------------------*)
destructor TDebugServiceApplication.Destroy;
begin

try
  inherited;
except
  MessageBeep ($ffff);
end
end;

procedure TDebugServiceApplication.OnExceptionHandler(Sender: TObject; E: Exception);
begin
  DoHandleException(E);
end;

(*----------------------------------------------------------------------*
 | procedure TDebugServiceApplication.Run                               |
 |                                                                      |
 | Run the service
 *----------------------------------------------------------------------*)
procedure TDebugServiceApplication.Run;
var
  i : Integer;
  service : TService;
  thread : TThread;
begin
  Forms.Application.OnException := OnExceptionHandler;
  try

  // Create a TDebugServiceThread for each of the services

    for i := 0 to ComponentCount - 1 do
      if Components [i] is TService then
      begin
        service := TService (Components [i]);
        thread := TDebugServiceThread.Create(service);
        thread.Resume;
        service.Tag := Integer (thread);
      end;

  // Run the 'service'

    while not Forms.Application.Terminated do
      Forms.Application.HandleMessage;

  // Terminate each TDebugServiceThread

    TerminateThreads (True)

  finally
  end;
end;

{ TDebugServiceThread }

(*----------------------------------------------------------------------*
 | constructor TDebugServiceThread.Create                               |
 |                                                                      |
 | Constructor for TDebugServiceThread                                  |
 *----------------------------------------------------------------------*)
constructor TDebugServiceThread.Create(AService: TService);
begin
  fService := AService;
  inherited Create (True);
end;

(*----------------------------------------------------------------------*
 | procedure TDebugServiceThread.Execute                                |
 |                                                                      |
 | 'Execute' method fot TDebugServiceThread.  Process messages          |
 *----------------------------------------------------------------------*)
procedure TDebugServiceThread.Execute;
var
  msg: TMsg;
  Started: Boolean;
begin
  PeekMessage(msg, 0, WM_USER, WM_USER, PM_NOREMOVE); { Create message queue }
  try
    Started := True;
    if Assigned(FService.OnStart) then FService.OnStart(FService, Started);
    if not Started then
    begin
      PostMessage (Forms.Application.Handle, WM_QUIT, 0, 0);
      ProcessRequests (True);
      Exit
    end;
    try
      if Assigned(FService.OnExecute) then
        FService.OnExecute(FService)
      else
        ProcessRequests(True);
      ProcessRequests(False);
    except
      on E: Exception do
        FService.LogMessage(Format(SServiceFailed,[SExecute, E.Message]));
    end;
  except
    on E: Exception do
    begin
      FService.LogMessage(Format(SServiceFailed,[SStart, E.Message]));
      PostMessage (Forms.Application.Handle, WM_QUIT, 0, 0);
    end
  end;
end;

(*----------------------------------------------------------------------*
 | procedure TDebugServiceThread.ProcessRequests                        |
 |                                                                      |
 | 'ProcessRequests' method.  do a message loop.                        |
 *----------------------------------------------------------------------*)
procedure TDebugServiceThread.ProcessRequests(WaitForMessage: Boolean);
var
  msg: TMsg;
  Rslt, stopped: Boolean;
begin
  while True do
  begin
    if Terminated and WaitForMessage then break;
    if WaitForMessage then
      Rslt := GetMessage(msg, 0, 0, 0)
    else
      Rslt := PeekMessage(msg, 0, 0, 0, PM_REMOVE);

    if not Rslt then    // No message received, or WM_QUIT
    begin
      if not WaitForMessage then
        break;

                        // WM_QUIT received.  Terminate loop - if we're allowed
      stopped := True;

      if Assigned (fService.OnStop) then
        fService.OnStop (fService, stopped); 
      if stopped then
        break
    end
    else
    DispatchMessage(msg);
  end;
end;

procedure TDebugServiceApplication.TerminateThreads (all : boolean);
var
  i, n : Integer;
  service : TService;
  thread : TThread;
begin
  if all then
    n := 0
  else
    n := 1;

  for i := ComponentCount - 1 downto n do
    if Components [i] is TService then
    begin
      service := TService (Components [i]);
      thread := TThread (service.Tag);
      if Assigned (thread) then
      begin
        PostThreadMessage (thread.ThreadID, WM_QUIT, 0, 0);
        thread.WaitFor;
        FreeAndNil (thread)
      end;
      service.Tag := 0;
    end;
end;

end.
