object frmLayer: TfrmLayer
  Left = 192
  Top = 133
  Width = 236
  Height = 270
  BorderStyle = bsSizeToolWin
  Caption = 'Layers'
  Color = clBtnFace
  DragKind = dkDock
  DragMode = dmAutomatic
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnEndDock = FormEndDock
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object tlbrLayerTools: TToolBar
    Left = 0
    Top = 202
    Width = 228
    Height = 24
    Align = alBottom
    AutoSize = True
    Caption = 'tlbrLayerTools'
    Flat = True
    Images = dmMain.imglstTools
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    object ToolButton2: TToolButton
      Left = 0
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 1
      Style = tbsSeparator
    end
    object tlbtnAdjustmentLayer: TToolButton
      Left = 8
      Top = 0
      Cursor = crHandPoint
      Hint = 'Create new fill or adjustment layer'
      Caption = 'tlbtnAdjustmentLayer'
      ImageIndex = 3
      OnClick = AdjustmentLayerClick
    end
    object tlbtnAddMask: TToolButton
      Left = 31
      Top = 0
      Cursor = crHandPoint
      Hint = 'Add a mask'
      Caption = 'tlbtnAddMask'
      ImageIndex = 1
      OnClick = AddMaskClick
    end
    object tlbtnNewLayer: TToolButton
      Left = 54
      Top = 0
      Cursor = crHandPoint
      Hint = 'Create a new layer'
      Caption = 'tlbtnNewLayer'
      ImageIndex = 0
      OnClick = NewLayerClick
    end
    object tlbtnDeleteLayer: TToolButton
      Left = 77
      Top = 0
      Cursor = crHandPoint
      Hint = 'Delete layer'
      Caption = 'tlbtnDeleteLayer'
      ImageIndex = 2
      OnClick = DeleteLayerClick
    end
  end
  object tlbrLayerBlend: TToolBar
    Left = 0
    Top = 0
    Width = 228
    Height = 23
    AutoSize = True
    ButtonHeight = 21
    Caption = 'tlbrLayerBlend'
    Flat = True
    TabOrder = 1
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      Style = tbsSeparator
    end
    object cmbbxLayerBlendMode: TComboBox
      Left = 8
      Top = 0
      Width = 165
      Height = 21
      Cursor = crHandPoint
      Hint = 'Set the blending mode'
      DropDownCount = 30
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnChange = LayerBlendModeChange
    end
  end
  object tlbrLayerOpacity: TToolBar
    Left = 0
    Top = 23
    Width = 228
    Height = 23
    AutoSize = True
    ButtonHeight = 21
    Caption = 'tlbrLayerOpacity'
    Flat = True
    TabOrder = 2
    object ToolButton3: TToolButton
      Left = 0
      Top = 0
      Width = 8
      Caption = 'ToolButton3'
      Style = tbsSeparator
    end
    object ggbrLayerOpacity: TGaugeBar
      Left = 8
      Top = 0
      Width = 164
      Height = 21
      Cursor = crHandPoint
      Hint = 'Set the opacity'
      Backgnd = bgPattern
      Max = 255
      ShowHandleGrip = True
      Style = rbsMac
      Position = 255
      OnChange = LayerOpacityChange
      OnMouseDown = ggbrLayerOpacityMouseDown
      OnMouseUp = ggbrLayerOpacityMouseUp
    end
    object edtLayerOpacityValue: TEdit
      Left = 172
      Top = 0
      Width = 30
      Height = 21
      TabOrder = 0
      Text = '100'
      OnChange = edtLayerOpacityValueChange
      OnEnter = edtLayerOpacityValueEnter
      OnExit = edtLayerOpacityValueExit
      OnKeyDown = edtLayerOpacityValueKeyDown
    end
    object lblLayerOpacityPercent: TLabel
      Left = 202
      Top = 0
      Width = 12
      Height = 21
      Caption = '%'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
  end
  object tlbrLayerLockTool: TToolBar
    Left = 0
    Top = 46
    Width = 228
    Height = 15
    AutoSize = True
    ButtonHeight = 13
    Caption = 'tlbrLayerLockTool'
    Flat = True
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    object ToolButton5: TToolButton
      Left = 0
      Top = 0
      Width = 8
      Caption = 'ToolButton5'
      ImageIndex = 0
      Style = tbsSeparator
    end
    object lblLockOption: TLabel
      Left = 8
      Top = 0
      Width = 27
      Height = 13
      Caption = 'Lock:'
    end
    object chckbxLockTransparency: TCheckBox
      Left = 35
      Top = 0
      Width = 15
      Height = 13
      Cursor = crHandPoint
      Hint = 'Lock transparent pixels'
      TabOrder = 0
      OnMouseUp = chckbxLockTransparencyMouseUp
    end
    object imgLockTransparency: TImage
      Left = 50
      Top = 0
      Width = 16
      Height = 16
      Hint = 'Lock transparent pixels'
      AutoSize = True
      Picture.Data = {
        07544269746D6170F6000000424DF60000000000000076000000280000001000
        0000100000000100040000000000800000000000000000000000100000000000
        0000000000000000800000800000008080008000000080008000808000008080
        8000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
        FF008888888888888888800000000000000880FFFFFF7777770880FFFFFF7777
        770880FFFFFF7777770880FFFFFF7777770880FFFFFF7777770880FFFFFF7777
        770880777777FFFFFF0880777777FFFFFF0880777777FFFFFF0880777777FFFF
        FF0880777777FFFFFF0880777777FFFFFF088000000000000008888888888888
        8888}
    end
  end
  object scrlbxLayers: TScrollBox
    Left = 0
    Top = 61
    Width = 228
    Height = 141
    Align = alClient
    TabOrder = 4
  end
end
