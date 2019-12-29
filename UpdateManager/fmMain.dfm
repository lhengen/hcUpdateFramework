object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Select Studios for Update'
  ClientHeight = 337
  ClientWidth = 833
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = mm1
  OldCreateOrder = False
  OnCreate = FormCreate
  OnResize = FormResize
  DesignSize = (
    833
    337)
  PixelsPerInch = 96
  TextHeight = 13
  object tlbMain: TToolBar
    Left = 0
    Top = 0
    Width = 833
    Height = 29
    Margins.Left = 1
    Margins.Top = 1
    Margins.Right = 1
    Margins.Bottom = 1
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 31
    Flat = False
    Images = il1
    TabOrder = 0
    DesignSize = (
      833
      32)
    object la2: TLabel
      AlignWithMargins = True
      Left = 0
      Top = 0
      Width = 98
      Height = 30
      Margins.Left = 1
      Margins.Top = 10
      Margins.Right = 2
      Margins.Bottom = 1
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Application:  '
      Layout = tlCenter
    end
    object cbApps: TComboBox
      AlignWithMargins = True
      Left = 98
      Top = 0
      Width = 145
      Height = 30
      Anchors = []
      TabOrder = 1
      Text = 'cbApps'
      OnChange = cbAppsChange
    end
    object la1: TLabel
      Left = 243
      Top = 0
      Width = 78
      Height = 30
      Margins.Left = 1
      Margins.Right = 2
      Margins.Bottom = 1
      Align = alBottom
      Alignment = taRightJustify
      Anchors = []
      AutoSize = False
      Caption = 'Update:  '
      Layout = tlCenter
    end
    object cbUpdates: TComboBox
      AlignWithMargins = True
      Left = 321
      Top = 0
      Width = 145
      Height = 30
      Anchors = []
      TabOrder = 0
      Text = 'cbUpdates'
      OnChange = cbUpdatesChange
    end
    object btn2: TToolButton
      Left = 466
      Top = 0
      Width = 50
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      Caption = 'btn2'
      ImageIndex = 0
      Style = tbsSeparator
    end
    object btnRefresh: TToolButton
      Left = 516
      Top = 0
      Margins.Left = 1
      Margins.Top = 1
      Margins.Right = 1
      Margins.Bottom = 1
      Action = actRefresh
      AutoSize = True
      ParentShowHint = False
      ShowHint = True
    end
    object chkAutoRefresh: TCheckBox
      Left = 547
      Top = 0
      Width = 97
      Height = 30
      Caption = 'AutoRefresh'
      Checked = True
      State = cbChecked
      TabOrder = 2
      OnClick = chkAutoRefreshClick
    end
    object btnRecall: TSpeedButton
      Left = 644
      Top = 0
      Width = 45
      Height = 30
      Hint = 'Recall an update that has not been applied'
      Caption = 'Recall'
      OnClick = btnRecallClick
    end
    object btnNotes: TSpeedButton
      Left = 689
      Top = 0
      Width = 45
      Height = 30
      Hint = 'Recall an update that has not been applied'
      Caption = 'Notes'
      OnClick = btnNotesClick
    end
  end
  object grd1: TcxGrid
    Left = 2
    Top = 44
    Width = 831
    Height = 268
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
    object tvGrid1DBTableView1: TcxGridDBTableView
      PopupMenu = pmDeploymentItem
      Navigator.Buttons.CustomButtons = <>
      ScrollbarAnnotations.CustomAnnotations = <>
      DataController.DataSource = dsDeployments
      DataController.Summary.DefaultGroupSummaryItems = <
        item
          Kind = skCount
          FieldName = 'UpdateResult'
          Column = colStudioNumber
        end>
      DataController.Summary.FooterSummaryItems = <
        item
          Kind = skCount
          OnGetText = tvGrid1DBTableView1TcxGridDBDataControllerTcxDataSummaryFooterSummaryItems0GetText
          FieldName = 'StudioNumber'
          Column = colStudioNumber
        end>
      DataController.Summary.SummaryGroups = <>
      OptionsData.CancelOnExit = False
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Inserting = False
      OptionsView.GroupRowHeight = 18
      object colStudioNumber: TcxGridDBColumn
        Caption = 'Studio'
        DataBinding.FieldName = 'StudioNumber'
        Options.Editing = False
        Options.GroupFooters = False
        Options.Grouping = False
        Options.Moving = False
        Width = 40
      end
      object colIsAvailable: TcxGridDBColumn
        Caption = 'Update Is Available'
        DataBinding.FieldName = 'IsAvailable'
        PropertiesClassName = 'TcxCheckBoxProperties'
        Properties.ReadOnly = True
        GroupIndex = 0
        Options.Editing = False
        Options.GroupFooters = False
        Options.Moving = False
        Options.Sorting = False
        Width = 110
      end
      object colAvailableDate: TcxGridDBColumn
        Caption = 'Available as Of'
        DataBinding.FieldName = 'AvailableUTCDate'
        Options.Editing = False
        Options.GroupFooters = False
        Options.Moving = False
        Width = 110
      end
      object colReceivedDate: TcxGridDBColumn
        Caption = 'ReceivedDate'
        DataBinding.FieldName = 'ReceivedUTCDate'
        Options.Editing = False
        Options.Moving = False
        Width = 110
      end
      object colLastAttempt: TcxGridDBColumn
        Caption = 'Last Attempt to Apply'
        DataBinding.FieldName = 'LastAttemptUTCDate'
        Options.Editing = False
        Options.Moving = False
        Width = 110
      end
      object colUpdateResult: TcxGridDBColumn
        Caption = 'Update Result'
        DataBinding.FieldName = 'UpdateResult'
        Visible = False
        GroupIndex = 1
        Options.Editing = False
        Options.Moving = False
        Width = 80
      end
      object colUpdateLog: TcxGridDBColumn
        Caption = 'Update Log'
        DataBinding.FieldName = 'UpdateLog'
        PropertiesClassName = 'TcxBlobEditProperties'
        Properties.BlobEditKind = bekMemo
        Properties.MemoScrollBars = ssBoth
        Properties.ReadOnly = True
        Options.Filtering = False
        Options.IncSearch = False
        Options.FilteringFilteredItemsList = False
        Options.FilteringMRUItemsList = False
        Options.FilteringPopup = False
        Options.FilteringPopupMultiSelect = False
        Options.ShowEditButtons = isebAlways
        Options.GroupFooters = False
        Options.Grouping = False
        Options.Moving = False
        Width = 75
      end
      object colStudioGUID: TcxGridDBColumn
        DataBinding.FieldName = 'St'
        Visible = False
        Options.Grouping = False
      end
    end
    object lvGrid1Level1: TcxGridLevel
      GridView = tvGrid1DBTableView1
    end
  end
  object statMain: TStatusBar
    Left = 0
    Top = 318
    Width = 833
    Height = 19
    Panels = <
      item
        Width = 100
      end
      item
        Alignment = taRightJustify
        Text = 'Total # of Studios: 999        '
        Width = 500
      end>
  end
  object mm1: TMainMenu
    Left = 272
    Top = 112
    object File1: TMenuItem
      Caption = '&File'
      object N3: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Action = actExitApp
      end
    end
    object mnuDeployments: TMenuItem
      Caption = '&Updates'
      object CreateDeployment1: TMenuItem
        Action = actCreateUpdate
      end
      object Manage1: TMenuItem
        Action = actManageUpdate
      end
    end
    object Help1: TMenuItem
      Caption = '&Help'
      object Contents1: TMenuItem
        Caption = '&Contents'
        Visible = False
      end
      object SearchforHelpOn1: TMenuItem
        Caption = '&Search for Help On...'
        Visible = False
      end
      object HowtoUseHelp1: TMenuItem
        Caption = '&How to Use Help'
        Visible = False
      end
      object About1: TMenuItem
        Caption = '&About...'
        OnClick = About1Click
      end
    end
  end
  object actlst1: TActionList
    Images = il1
    Left = 304
    Top = 112
    object actExitApp: TAction
      Caption = 'E&xit'
      OnExecute = actExitAppExecute
    end
    object actCreateUpdate: TAction
      Caption = '&Create...'
      OnExecute = actCreateUpdateExecute
    end
    object actManageUpdate: TAction
      Caption = '&Manage..'
      OnExecute = actManageUpdateExecute
      OnUpdate = actManageUpdateUpdate
    end
    object actRefresh: TAction
      Caption = 'Refresh'
      Hint = 'Refresh from Database'
      ImageIndex = 0
      OnExecute = actRefreshExecute
    end
  end
  object il1: TImageList
    Height = 24
    Width = 24
    Left = 352
    Top = 120
    Bitmap = {
      494C010101002400040018001800FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000600000001800000001002000000000000024
      000000000000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00C6C6C700B1B1B200A3A3A50099999C0098989A0098989A0098989A009898
      9A0098989A0098989A0098989A0099999C00A3A3A500B1B1B200C6C6C700FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00D4D4
      D400BBBBBC00C8C8C900CFCFCF00CECED000CECED000CECED000CECED000CECE
      D000CECED000CECED000CECED000CECED000ABA9AB008B8B8D0098979800D2D2
      D300FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00D6D5D600C6C5
      C600EDE9E700F0EBE900F3EBE800F3EBE800F3EBE800F3EBE800F3EBE800F3EB
      E800F3EBE800F3EBE800F3EBE800F3EBE800EDE9E700E0E0E0009F9FA200B1B1
      B200D6D5D600FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00D6D6D600E5E5E500F1E1
      D600F5E2D600F5E2D600F5E2D600EEDCD000D1C0B600AE9B92009D817200A188
      7A00AF9C9200EFDDD100F5E2D600F5E2D600F5E2D600F5E2D600F1E1D6009392
      9400A3A3A300D0D0D100FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00DCDCDC00ECDDD100F3DA
      C700F3DAC700F3DAC700F3DAC7009A81730084533B0097502600BF6B2F00C06E
      3100B0663400A0877800DBC4B300F3DAC700F3DAC700F3DAC700F3DAC700C6C6
      C6008F8E9000C1C1C100FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00E6E3E000F0D0B600F0D0
      B600F0D0B600EFCFB500C7AA93009F512200C76F2F00D87D3300EC8A3600F792
      3900FF9C3D00D17C3B0092674E00CAAD9700F0D0B600F0D0B600F0D0B600E6E3
      E0008F8E9000B5B5B600FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00E9D9CD00EECCB100EECC
      B100DFBFA6008B675200A6552700BF6A2A00BA662B00A55E3000A46C4D00A86A
      4700C0733C00FF9C3A00FFA64200E5914600CFB19900EECCB100EECCB100E9D9
      CC00AEAEAE00AAAAAB00FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00E9D9CD00EECEB300EECE
      B300BCA089008D4E2B00B2602B00B0612A0097573600B5897000EECEB300E7C6
      AB00BA907700ED913D00FFA13B00FFA74700A1816B00EECEB300EECEB300E9D8
      CA00B3B3B300A9A9A900FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00E9DBCF00EED0B800EED0
      B8009E7D6900A55A2E00B05F29009E5A3400C3988000EED0B800EED0B800EED0
      B800EED0B800C1784200FBA33E00FFAB4100A9795800EED0B800EED0B800E9D9
      CC00B3B3B300A9A9A900FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00E9DED500EED7C400EED7
      C400AB775B00B4724400C17841009A745E00E8D1BE00EED7C400E3CDBA00E5CF
      BC00EED7C400C9A18900BA805D00C3876100BC8B6C00EED7C400EED7C400E9DC
      D300B3B3B300A9A9A900FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00E9E0D800EEDBCB00EEDB
      CB00B1846C00B6774B00C8824B008D674F00CABAAC00EEDBCB00CAB09E009F86
      7800CAB9AB00EAD5C400E2CAB900E3CCBB00E4CDBC00EEDBCB00EEDBCB00E9DF
      D600B3B3B300A9A9A900FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00E9E2DC00EEDFD400EEDF
      D400C3A29100AF734900CB8B5700B1734A008F796D00E3D4C900C6B0A300A266
      4400886C5C00EEDFD400EEDFD400EEDFD400EEDFD400EEDFD400EEDFD400E9E1
      DB00B3B3B300A9A9A900FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00E9E6E400EFE8E300EFE8
      E300EDE6E000C2A59700B5825C00D89D6300DD9C6100CD8E5D009F735400C88C
      5B00FFB26A00987D6C00D0C9C400EFE8E300EFE8E300EFE8E300EFE8E300E9E5
      E300B3B3B500AAAAAB00FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00E9E8E600F0ECE900F0EC
      E900F0ECE900E9E2DE00B7958400DEAE7900E4AD7300E7AC6F00E9AA6B00DFA0
      6300E2A05F00E8A76A009F816E00DDD6D200F0ECE900F0ECE900F0ECE900EAE8
      E600B4B4B500ADACAE00FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00EAE9E900F1EFEF00F1EF
      EF00F1EFEF00F1EFEF00E9E4E200B3866700CD9E7000DEAF7B00EDB97C00E4AB
      6F00DFA36500EDB37600B98D7500E4DBD900F1EFEF00F1EFEF00F1EFEF00EAE9
      E900B3B3B400B3B2B400FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00E8E8E800F4F6F800F4F6
      F800F4F6F800F4F6F800F4F6F800F4F6F800F1F1F200ECE9E900CAB6AE00CDA7
      8400E3BA8B00E6E1E000F4F6F800F4F6F800F4F6F800F4F6F800F4F6F800E8E8
      E800AAAAAB00CDCDCE00FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00E4E4E400F0F2F400F6F8
      FB00F6F8FB00F6F8FB00F6F8FB00F6F8FB00F6F8FB00F6F8FB00D6C8C300B48B
      6F00BA998700F6F8FB00F6F8FB00F6F8FB00F6F8FB00F6F8FB00F6F8FB00D7D7
      D700B6B6B800DEDDDE00FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00EBEBEB00EBEBEC00F9FB
      FC00F9FBFC00F9FBFC00F9FBFC00F9FBFC00F9FBFC00F9FBFC00D9CAC400C6AD
      A100E6DEDB00F9FBFC00F9FBFC00F9FBFC00F9FBFC00F9FBFC00F9FBFC00BEBE
      BF00D2D2D300FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00E7E7
      E700F4F4F400F9F9F900FEFEFE00FEFEFE00FEFEFE00FEFEFE00FEFEFE00FEFE
      FE00FEFEFE00FEFEFE00FEFEFE00FEFEFE00F4F4F400EAEAEA00D4D4D400FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00E6E6E600E4E4E400E5E5E500E5E5E500E5E5E500E5E5E500E5E5E500E5E5
      E500E5E5E500E5E5E500E5E5E500E5E5E500DDDDDD00DADADA00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000060000000180000000100010000000000200100000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000}
  end
  object qryLocationDeployment: TADOQuery
    Connection = dtmADO.cnWareHouse
    CursorType = ctStatic
    AfterOpen = qryLocationDeploymentAfterOpen
    Parameters = <
      item
        Name = 'DeploymentGUID'
        DataType = ftGuid
        NumericScale = 255
        Precision = 255
        Size = 16
        Value = '{E9BBCEA3-3CB1-4648-92FA-42EBD6A6429F}'
      end>
    SQL.Strings = (
      '')
    Left = 312
    Top = 184
  end
  object dsDeployments: TDataSource
    DataSet = qryLocationDeployment
    Left = 424
    Top = 168
  end
  object tmrRefresh: TTimer
    Enabled = False
    Interval = 10000
    OnTimer = tmrRefreshTimer
    Left = 568
    Top = 112
  end
  object pmDeploymentItem: TPopupMenu
    Left = 312
    Top = 256
    object UnSelect1: TMenuItem
      Action = actUnSelect
    end
    object mnuMarkAsSuccessful: TMenuItem
      Action = actMarkAsSuccessful
    end
    object MarkAsNotReceived1: TMenuItem
      Action = actMarkAsNotReceived
    end
    object MarkAsAvailable1: TMenuItem
      Action = actMarkAsAvailable
    end
    object MarkAsUnAvailable1: TMenuItem
      Action = actMarkAsUnAvailable
    end
  end
  object actlstDeploymentItem: TActionList
    Left = 216
    Top = 240
    object actUnSelect: TAction
      Caption = 'Mark as Not Available'
      Hint = 
        'Mark as Unavailable for a Studio that has not yet received the U' +
        'pdate'
      OnExecute = actUnSelectExecute
      OnUpdate = actUnSelectUpdate
    end
    object actMarkAsSuccessful: TAction
      Caption = 'Mark As Successful'
      OnExecute = actMarkAsSuccessfulExecute
      OnUpdate = actMarkAsSuccessfulUpdate
    end
    object actMarkAsNotReceived: TAction
      Caption = 'Mark As Not Received'
      OnExecute = actMarkAsNotReceivedExecute
      OnUpdate = actMarkAsNotReceivedUpdate
    end
    object actMarkAsAvailable: TAction
      Caption = 'Mark As Available'
      OnExecute = actMarkAsAvailableExecute
    end
    object actMarkAsUnAvailable: TAction
      Caption = 'Mark As UnAvailable'
      OnExecute = actMarkAsUnAvailableExecute
    end
  end
  object qryWorker: TADOQuery
    Connection = dtmADO.cnWareHouse
    CursorType = ctStatic
    Parameters = <
      item
        Name = 'DeploymentGUID'
        DataType = ftGuid
        NumericScale = 255
        Precision = 255
        Size = 16
        Value = '{E9BBCEA3-3CB1-4648-92FA-42EBD6A6429F}'
      end>
    SQL.Strings = (
      'SELECT '
      's.StudioNumber'
      '      ,DeploymentGUID'
      '      ,IsAvailable'
      
        '      ,dateadd(hour, datediff(hour, getutcdate(), getdate()),Rec' +
        'eivedUTCDate) as ReceivedUTCDate'
      
        '      ,dateadd(hour, datediff(hour, getutcdate(), getdate()),Upd' +
        'atedUTCDate) as UpdatedUTCDate'
      
        '      ,dateadd(hour, datediff(hour, getutcdate(), getdate()),Las' +
        'tAttemptUTCDate) as LastAttemptUTCDate'
      '      ,UpdateResult'
      '      ,UpdateLog'
      
        '      ,dateadd(hour, datediff(hour, getutcdate(), getdate()),Ava' +
        'ilableUTCDate) as AvailableUTCDate'
      '  FROM LocationDeployment sd'
      '  inner join studio s on s.StudioGUID = sd.StudioGUID'
      '  where DeploymentGUID = :DeploymentGUID'
      '  and s.IsActive = 1'
      '  order by StudioNumber asc')
    Left = 48
    Top = 176
  end
end
