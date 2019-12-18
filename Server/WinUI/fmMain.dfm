object frmMain: TfrmMain
  Left = 271
  Top = 114
  Caption = 'Update Server'
  ClientHeight = 235
  ClientWidth = 399
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 48
    Width = 20
    Height = 13
    Caption = 'Port'
  end
  object la1: TLabel
    Left = 24
    Top = 165
    Width = 159
    Height = 13
    Caption = 'Maximum Number of Connections'
  end
  object ButtonStart: TButton
    Left = 24
    Top = 8
    Width = 75
    Height = 25
    Action = actStart
    TabOrder = 0
  end
  object ButtonStop: TButton
    Left = 105
    Top = 8
    Width = 75
    Height = 25
    Action = actStop
    TabOrder = 1
  end
  object EditPort: TEdit
    Left = 24
    Top = 67
    Width = 121
    Height = 21
    TabOrder = 2
    Text = '8080'
  end
  object ButtonOpenBrowser: TButton
    Left = 24
    Top = 112
    Width = 107
    Height = 25
    Caption = 'Open Browser'
    TabOrder = 3
    OnClick = ButtonOpenBrowserClick
  end
  object seMaxConnections: TSpinEdit
    Left = 24
    Top = 184
    Width = 121
    Height = 22
    MaxValue = 150
    MinValue = 0
    TabOrder = 4
    Value = 0
  end
  object ApplicationEvents1: TApplicationEvents
    OnIdle = ApplicationEvents1Idle
    Left = 288
    Top = 24
  end
  object actlst1: TActionList
    Left = 192
    Top = 120
    object actStart: TAction
      Caption = 'Start'
      OnExecute = actStartExecute
      OnUpdate = actStartUpdate
    end
    object actStop: TAction
      Caption = 'Stop'
      OnExecute = actStopExecute
      OnUpdate = actStopUpdate
    end
  end
end
