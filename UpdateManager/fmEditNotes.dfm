object frmEditNotes: TfrmEditNotes
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Notes for %s'
  ClientHeight = 245
  ClientWidth = 464
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  DesignSize = (
    464
    245)
  PixelsPerInch = 96
  TextHeight = 13
  object meNotes: TRichEdit
    Left = 8
    Top = 39
    Width = 368
    Height = 198
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
  end
  object btOK: TButton
    Left = 382
    Top = 8
    Width = 74
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btCancel: TButton
    Left = 382
    Top = 39
    Width = 74
    Height = 25
    Anchors = [akTop, akRight]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object chkUpdateManifest: TCheckBox
    Left = 264
    Top = 16
    Width = 112
    Height = 17
    Caption = 'Update Manifest'
    Checked = True
    State = cbChecked
    TabOrder = 3
  end
end
