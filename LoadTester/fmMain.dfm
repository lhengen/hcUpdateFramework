object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'frmMain'
  ClientHeight = 122
  ClientWidth = 318
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object laThreadsRunning: TLabel
    Left = 24
    Top = 66
    Width = 86
    Height = 13
    Caption = 'laThreadsRunning'
  end
  object led1: TLabeledEdit
    Left = 24
    Top = 32
    Width = 121
    Height = 21
    EditLabel.Width = 157
    EditLabel.Height = 13
    EditLabel.Caption = 'Number of UpdateClient Threads'
    TabOrder = 0
    Text = '16'
  end
  object btStart: TButton
    Left = 216
    Top = 30
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 1
    OnClick = btStartClick
  end
  object btStop: TButton
    Left = 216
    Top = 61
    Width = 75
    Height = 25
    Caption = 'Stop'
    TabOrder = 2
    OnClick = btStopClick
  end
end
