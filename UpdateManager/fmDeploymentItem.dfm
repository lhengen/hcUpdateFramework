object frmDeploymentItem: TfrmDeploymentItem
  Left = 0
  Top = 0
  Caption = 'New Deployment Item'
  ClientHeight = 269
  ClientWidth = 392
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    392
    269)
  PixelsPerInch = 96
  TextHeight = 13
  object btnFileName: TSpeedButton
    Left = 353
    Top = 15
    Width = 21
    Height = 22
    Anchors = [akTop, akRight]
    Caption = '...'
    OnClick = btnFileNameClick
    ExplicitLeft = 319
  end
  object btnTargetPath: TSpeedButton
    Left = 353
    Top = 69
    Width = 21
    Height = 22
    Anchors = [akTop, akRight]
    Caption = '...'
    ExplicitLeft = 319
  end
  object ledFileName: TLabeledEdit
    Left = 88
    Top = 16
    Width = 254
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 50
    EditLabel.Height = 13
    EditLabel.Caption = 'File Name:'
    LabelPosition = lpLeft
    TabOrder = 0
  end
  object ledVersion: TLabeledEdit
    Left = 88
    Top = 43
    Width = 254
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 39
    EditLabel.Height = 13
    EditLabel.Caption = 'Version:'
    LabelPosition = lpLeft
    TabOrder = 1
  end
  object ledTargetPath: TLabeledEdit
    Left = 88
    Top = 70
    Width = 254
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 61
    EditLabel.Height = 13
    EditLabel.Caption = 'Target Path:'
    LabelPosition = lpLeft
    TabOrder = 2
  end
  object btOK: TButton
    Left = 102
    Top = 232
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
  end
  object btCancel: TButton
    Left = 183
    Top = 232
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object chkIsAPatch: TCheckBox
    Left = 88
    Top = 95
    Width = 113
    Height = 17
    Caption = 'Generate a Patch'
    TabOrder = 5
    OnClick = chkIsAPatchClick
  end
  object pbProgress: TProgressBar
    Left = 8
    Top = 118
    Width = 366
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Smooth = True
    TabOrder = 6
  end
  object meProgress: TMemo
    Left = 8
    Top = 141
    Width = 366
    Height = 85
    Anchors = [akLeft, akTop, akRight]
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 7
  end
  object chkLaunch: TCheckBox
    Left = 216
    Top = 95
    Width = 65
    Height = 17
    Caption = 'Launch'
    TabOrder = 8
    OnClick = chkIsAPatchClick
  end
  object chkIsAZip: TCheckBox
    Left = 295
    Top = 95
    Width = 41
    Height = 17
    Caption = 'Zip'
    TabOrder = 9
    OnClick = chkIsAZipClick
  end
  object odDeploymentItems: TFileOpenDialog
    DefaultExtension = '*.exe'
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'Application Components'
        FileMask = '*.exe;'#13#10'*.dll'#13#10';*.bpl'
      end>
    Options = []
    Left = 16
    Top = 80
  end
  object obDeploymentItem: ThcUIObjectBinder
    Bindings = <
      item
        MediatorClassName = 'ThcTLabeledEditMediator'
        Mediator.Control = ledFileName
        Mediator.AttributeName = 'FileName'
        Mediator.CheckOnChange = False
        Mediator.CharCase = ecNormal
        Mediator.MaxLength = 0
        Mediator.ProperCase = False
      end
      item
        MediatorClassName = 'ThcTLabeledEditMediator'
        Mediator.Control = ledVersion
        Mediator.AttributeName = 'Version'
        Mediator.CheckOnChange = False
        Mediator.CharCase = ecNormal
        Mediator.MaxLength = 0
        Mediator.ProperCase = False
      end
      item
        MediatorClassName = 'ThcTLabeledEditMediator'
        Mediator.Control = ledTargetPath
        Mediator.AttributeName = 'TargetPath'
        Mediator.CheckOnChange = False
        Mediator.CharCase = ecNormal
        Mediator.MaxLength = 0
        Mediator.ProperCase = False
      end
      item
        MediatorClassName = 'ThcTCheckBoxMediator'
        Mediator.Control = chkIsAPatch
        Mediator.AttributeName = 'IsAPatch'
      end
      item
        MediatorClassName = 'ThcTCheckBoxMediator'
        Mediator.Control = chkIsAZip
        Mediator.AttributeName = 'IsAZip'
      end
      item
        MediatorClassName = 'ThcTCheckBoxMediator'
        Mediator.Control = chkLaunch
        Mediator.AttributeName = 'Launch'
      end>
    ErrorIndicator = hcErrorIndicator1
    ObjectClass = 'ThcDeploymentItem'
    FactoryPool = dtmADO.hcFactoryPool
    Left = 8
    Top = 32
  end
  object hcErrorIndicator1: ThcErrorIndicator
    ImageIndex = 0
    Left = 16
    Top = 128
  end
end
