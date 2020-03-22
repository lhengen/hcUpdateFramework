object Form3: TForm3
  Left = 0
  Top = 0
  BorderIcons = []
  Caption = 'Registering Appication...'
  ClientHeight = 101
  ClientWidth = 347
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object laResult: TLabel
    Left = 8
    Top = 8
    Width = 331
    Height = 33
    AutoSize = False
  end
  object Button1: TButton
    Left = 128
    Top = 68
    Width = 75
    Height = 25
    Caption = 'Ok'
    ModalResult = 1
    TabOrder = 0
    OnClick = Button1Click
  end
end
