object frmMain: TfrmMain
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'frmMain'
  ClientHeight = 332
  ClientWidth = 410
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    410
    332)
  PixelsPerInch = 96
  TextHeight = 13
  object la1: TLabel
    Left = 8
    Top = 135
    Width = 42
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Progress'
    ExplicitTop = 150
  end
  object la2: TLabel
    Left = 8
    Top = 8
    Width = 124
    Height = 13
    Caption = 'Whats New in this Update'
  end
  object meWhatsNew: TRichEdit
    Left = 8
    Top = 27
    Width = 394
    Height = 102
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
    Zoom = 100
  end
  object meProgress: TMemo
    Left = 8
    Top = 151
    Width = 394
    Height = 98
    Anchors = [akLeft, akRight, akBottom]
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object btOK: TButton
    Left = 167
    Top = 299
    Width = 75
    Height = 25
    Anchors = [akBottom]
    Caption = 'Continue'
    ModalResult = 1
    TabOrder = 2
    OnClick = btOKClick
  end
  object pbProgress: TProgressBar
    Left = 8
    Top = 262
    Width = 394
    Height = 17
    Smooth = True
    TabOrder = 3
  end
end
