object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Test Update Server Client'
  ClientHeight = 73
  ClientWidth = 279
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    279
    73)
  PixelsPerInch = 96
  TextHeight = 13
  object laUpdateServerURI: TLabel
    Left = 8
    Top = 52
    Width = 3
    Height = 13
  end
  object Label2: TLabel
    Left = 8
    Top = 33
    Width = 95
    Height = 13
    Caption = 'Update Server URI:'
  end
  object btCheckForUpdates: TButton
    Left = 156
    Top = 8
    Width = 115
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Check for Update'
    TabOrder = 0
    OnClick = btCheckForUpdatesClick
  end
end
