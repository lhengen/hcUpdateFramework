object PatcherDemo: TPatcherDemo
  Left = 253
  Top = 114
  Caption = 'TPatcher Demo'
  ClientHeight = 692
  ClientWidth = 576
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    576
    692)
  PixelsPerInch = 96
  TextHeight = 13
  object lbl5: TLabel
    Left = 15
    Top = 10
    Width = 86
    Height = 13
    Caption = 'Patcher File Mode'
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 541
    Width = 560
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Smooth = True
    TabOrder = 0
  end
  object gbx1: TGroupBox
    Left = 7
    Top = 302
    Width = 261
    Height = 236
    Caption = 'Create Patch File Options'
    TabOrder = 1
    object lbl2: TLabel
      Left = 10
      Top = 17
      Width = 90
      Height = 13
      Caption = 'Compression Mode'
    end
    object cbx1: TComboBox
      Tag = 1
      Left = 110
      Top = 12
      Width = 145
      Height = 21
      Style = csDropDownList
      TabOrder = 0
      OnClick = lbx1Click
      Items.Strings = (
        'pcoUseBest'
        'pcoUseLZX_A'
        'pcoUseLZX_B'
        'pcoUseBestLZX'
        'pcoUseLZX_Large')
    end
    object lbx1: TCheckListBox
      Tag = 1
      Left = 10
      Top = 42
      Width = 241
      Height = 154
      ItemHeight = 13
      Items.Strings = (
        'pcoNoBindFix'
        'pcoNoLockFix'
        'pcoNoRebase'
        'pcoFailIfSameFile'
        'pcoFailIfBigger'
        'pcoNoChecksum'
        'pcoNoResourceTimeStampFix'
        'pcoNoTimeStamp'
        'pcoUseSignatureMD5'
        'pcoReserved1'
        'pcoValidFlags')
      TabOrder = 1
      OnClick = lbx1Click
    end
    object btn1: TBitBtn
      Tag = 1
      Left = 60
      Top = 202
      Width = 126
      Height = 25
      Caption = '&Create Patch'
      DoubleBuffered = True
      Kind = bkRetry
      NumGlyphs = 2
      ParentDoubleBuffered = False
      TabOrder = 2
      OnClick = btn1Click
    end
  end
  object gbx2: TGroupBox
    Left = 275
    Top = 302
    Width = 294
    Height = 236
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Apply Patch To File Options'
    TabOrder = 2
    DesignSize = (
      294
      236)
    object lbx2: TCheckListBox
      Tag = 2
      Left = 10
      Top = 42
      Width = 275
      Height = 154
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      Items.Strings = (
        ' paoFailIfExact'
        ' paoFailIfClose'
        ' paoTestOnly'
        ' paoValidFlags ')
      TabOrder = 0
      OnClick = lbx1Click
    end
    object btn2: TBitBtn
      Tag = 2
      Left = 80
      Top = 202
      Width = 91
      Height = 25
      Caption = '&Apply Patch'
      DoubleBuffered = True
      Kind = bkRetry
      NumGlyphs = 2
      ParentDoubleBuffered = False
      TabOrder = 1
      OnClick = btn2Click
    end
  end
  object mmo1: TMemo
    Left = 7
    Top = 562
    Width = 559
    Height = 129
    Anchors = [akLeft, akTop, akRight, akBottom]
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 3
  end
  object gbx3: TGroupBox
    Left = 5
    Top = 34
    Width = 564
    Height = 265
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Patch Items'
    TabOrder = 4
    DesignSize = (
      564
      265)
    object lbl1: TLabel
      Tag = 1
      Left = 7
      Top = 14
      Width = 35
      Height = 13
      Cursor = crHandPoint
      Caption = 'Old File'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsUnderline]
      ParentFont = False
      OnClick = MyFileSelectClick
    end
    object lbl3: TLabel
      Tag = 2
      Left = 7
      Top = 41
      Width = 41
      Height = 13
      Cursor = crHandPoint
      Caption = 'New File'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsUnderline]
      ParentFont = False
      OnClick = MyFileSelectClick
    end
    object lbl4: TLabel
      Tag = 3
      Left = 7
      Top = 69
      Width = 47
      Height = 13
      Cursor = crHandPoint
      Caption = 'Patch File'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsUnderline]
      ParentFont = False
      OnClick = MyFileSelectClick
    end
    object edt3: TEdit
      Left = 76
      Top = 65
      Width = 393
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
    end
    object edt1: TEdit
      Left = 76
      Top = 10
      Width = 393
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      ReadOnly = True
      TabOrder = 1
    end
    object edt2: TEdit
      Left = 76
      Top = 37
      Width = 393
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
    end
    object grd1: TStringGrid
      Left = 6
      Top = 95
      Width = 552
      Height = 163
      Anchors = [akLeft, akTop, akRight, akBottom]
      ColCount = 3
      DefaultRowHeight = 17
      FixedCols = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect]
      TabOrder = 3
      OnSelectCell = grd1SelectCell
    end
    object btn3: TBitBtn
      Left = 479
      Top = 10
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Insert'
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 4
      OnClick = btn3Click
    end
    object btn4: TBitBtn
      Left = 479
      Top = 65
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Remove'
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 5
      OnClick = btn4Click
    end
    object btn5: TBitBtn
      Left = 479
      Top = 38
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Update'
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 6
      OnClick = btn5Click
    end
  end
  object cbx2: TComboBox
    Left = 110
    Top = 7
    Width = 145
    Height = 21
    Style = csDropDownList
    TabOrder = 5
    Items.Strings = (
      'pcoUseBest'
      'pcoUseLZX_A'
      'pcoUseLZX_B'
      'pcoUseBestLZX'
      'pcoUseLZX_Large')
  end
  object chk1: TCheckBox
    Left = 275
    Top = 10
    Width = 136
    Height = 17
    Caption = 'Always raise exceptions'
    Checked = True
    State = cbChecked
    TabOrder = 6
  end
end
