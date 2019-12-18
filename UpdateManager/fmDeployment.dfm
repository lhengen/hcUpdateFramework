object frmDeployment: TfrmDeployment
  Left = 0
  Top = 0
  ActiveControl = cbRegisteredApps
  Caption = 'New Deployment'
  ClientHeight = 352
  ClientWidth = 544
  Color = clBtnFace
  Constraints.MinHeight = 390
  Constraints.MinWidth = 560
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    544
    352)
  PixelsPerInch = 96
  TextHeight = 13
  object la1: TLabel
    Left = 8
    Top = 8
    Width = 112
    Height = 13
    Caption = 'Registered Applications'
  end
  object laWhatsNew: TLabel
    Left = 8
    Top = 54
    Width = 55
    Height = 13
    Caption = 'Whats New'
  end
  object laItems: TLabel
    Left = 280
    Top = 8
    Width = 27
    Height = 13
    Anchors = [akLeft]
    Caption = 'Items'
  end
  object cbRegisteredApps: TComboBox
    Left = 8
    Top = 27
    Width = 237
    Height = 21
    TabOrder = 0
  end
  object meWhatsNew: TRichEdit
    Left = 8
    Top = 72
    Width = 237
    Height = 169
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    Zoom = 100
  end
  object ledUpdateVersion: TLabeledEdit
    Left = 8
    Top = 272
    Width = 121
    Height = 21
    EditLabel.Width = 211
    EditLabel.Height = 13
    EditLabel.Caption = 'Update Version (Defaults to next Version#) '
    TabOrder = 2
  end
  object btOK: TButton
    Left = 181
    Top = 319
    Width = 75
    Height = 25
    Anchors = [akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
    OnClick = btOKClick
  end
  object btCancel: TButton
    Left = 258
    Top = 319
    Width = 75
    Height = 25
    Anchors = [akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object btNew: TButton
    Left = 275
    Top = 263
    Width = 75
    Height = 25
    Action = actAdd
    Anchors = [akRight, akBottom]
    TabOrder = 5
  end
  object btEdit: TButton
    Left = 356
    Top = 264
    Width = 75
    Height = 25
    Action = actEdit
    Anchors = [akRight, akBottom]
    TabOrder = 6
  end
  object btDelete: TButton
    Left = 437
    Top = 263
    Width = 75
    Height = 25
    Action = actRemove
    Anchors = [akRight, akBottom]
    TabOrder = 7
  end
  object grdItems: TcxGrid
    Left = 280
    Top = 27
    Width = 230
    Height = 224
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 8
    object tvItems: TcxGridTableView
      Navigator.Buttons.CustomButtons = <>
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsView.GroupByBox = False
      object colFileName: TcxGridColumn
        Caption = 'Filename'
        Width = 76
      end
      object colVersion: TcxGridColumn
        Caption = 'Version'
        Width = 81
      end
      object colTarget: TcxGridColumn
        Caption = 'Target'
        Width = 76
      end
    end
    object lvItems: TcxGridLevel
      GridView = tvItems
    end
  end
  object chkIsMandatory: TCheckBox
    Left = 8
    Top = 330
    Width = 120
    Height = 20
    Hint = 
      'Update must be applied to all locations it is made available to.' +
      '  Depends if launcher allows for optional updates.'
    Caption = 'Update is Mandatory '
    ParentShowHint = False
    ShowHint = True
    TabOrder = 9
  end
  object chkIsSilent: TCheckBox
    Left = 8
    Top = 315
    Width = 120
    Height = 17
    Hint = 'Update will be applied by the ClientUpdateService '
    Caption = 'Apply Silently'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 10
  end
  object chkIsImmediate: TCheckBox
    Left = 8
    Top = 299
    Width = 120
    Height = 17
    Hint = 
      'User will be forced to terminate the application and apply the u' +
      'pdate immediately (dependant on code in application)'
    Caption = 'Apply Immediately'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 11
  end
  object actlst1: TActionList
    Left = 136
    Top = 8
    object actAdd: TAction
      Caption = 'Add..'
      OnExecute = actAddExecute
    end
    object actEdit: TAction
      Caption = 'Edit'
      OnExecute = actEditExecute
    end
    object actRemove: TAction
      Caption = 'Remove'
      OnExecute = actRemoveExecute
      OnUpdate = actRemoveUpdate
    end
  end
  object obDeployment: ThcUIObjectBinder
    Bindings = <
      item
        MediatorClassName = 'ThcTRichEditMediator'
        Mediator.Control = meWhatsNew
        Mediator.AttributeName = 'WhatsNew'
      end
      item
        MediatorClassName = 'ThcTLabeledEditMediator'
        Mediator.Control = ledUpdateVersion
        Mediator.AttributeName = 'UpdateVersion'
        Mediator.CheckOnChange = False
        Mediator.CharCase = ecNormal
        Mediator.MaxLength = 40
        Mediator.ProperCase = False
      end
      item
        MediatorClassName = 'ThcTcxGridMediator'
        Mediator.Control = grdItems
        Mediator.GridView = tvItems
        Mediator.Bindings = <
          item
            TableItem = colFileName
            AttributeName = 'FileName'
          end
          item
            TableItem = colVersion
            AttributeName = 'Version'
          end
          item
            TableItem = colTarget
            AttributeName = 'TargetPath'
          end>
        Mediator.ListName = 'DeploymentItems'
      end
      item
        MediatorClassName = 'ThcTCheckBoxMediator'
        Mediator.Control = chkIsSilent
        Mediator.AttributeName = 'IsSilent'
      end
      item
        MediatorClassName = 'ThcTCheckBoxMediator'
        Mediator.Control = chkIsMandatory
        Mediator.AttributeName = 'IsMandatory'
      end
      item
        MediatorClassName = 'ThcTCheckBoxMediator'
        Mediator.Control = chkIsImmediate
        Mediator.AttributeName = 'IsImmediate'
      end>
    ErrorIndicator = hcErrorIndicator1
    ObjectClass = 'ThcDeployment'
    FactoryPool = dtmADO.hcFactoryPool
    Left = 248
    Top = 128
  end
  object hcErrorIndicator1: ThcErrorIndicator
    ImageIndex = 0
    Left = 248
    Top = 184
  end
end
