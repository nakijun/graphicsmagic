object frmSwatch: TfrmSwatch
  Left = 672
  Top = 364
  Width = 236
  Height = 154
  BorderStyle = bsSizeToolWin
  Caption = 'Swatches'
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
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object tlbrSwatches: TToolBar
    Left = 0
    Top = 86
    Width = 228
    Height = 24
    Cursor = crHandPoint
    Align = alBottom
    Caption = 'tlbrSwatches'
    Flat = True
    Images = dmSwatches.imglstSwatches
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
    object shpCurrentSwatch: TShape
      Left = 8
      Top = 0
      Width = 22
      Height = 22
    end
    object edtSwatchCount: TEdit
      Left = 30
      Top = 0
      Width = 50
      Height = 22
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 0
    end
    object ToolButton3: TToolButton
      Left = 80
      Top = 0
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 1
      Style = tbsSeparator
    end
    object shpForegroundSwatch: TShape
      Left = 88
      Top = 0
      Width = 22
      Height = 22
      Cursor = crHandPoint
      Hint = 'Foreground Color'
      ParentShowHint = False
      ShowHint = True
      OnMouseDown = shpForegroundSwatchMouseDown
    end
    object ToolButton4: TToolButton
      Left = 110
      Top = 0
      Width = 8
      Caption = 'ToolButton4'
      ImageIndex = 1
      Style = tbsSeparator
    end
    object shpBackgroundSwatch: TShape
      Left = 118
      Top = 0
      Width = 22
      Height = 22
      Cursor = crHandPoint
      Hint = 'Background Color'
      ParentShowHint = False
      ShowHint = True
      OnMouseDown = shpBackgroundSwatchMouseDown
    end
    object ToolButton8: TToolButton
      Left = 140
      Top = 0
      Width = 8
      Caption = 'ToolButton8'
      ImageIndex = 4
      Style = tbsSeparator
    end
    object tlbtnCreateSwatch: TToolButton
      Left = 148
      Top = 0
      Hint = 'Create swatch of foreground/background color'
      Caption = 'tlbtnCreateSwatch'
      ImageIndex = 0
      OnClick = CreateSwatchClick
    end
    object tlbtnSwatchOptions: TToolButton
      Left = 171
      Top = 0
      Cursor = crHandPoint
      Hint = 'Color Swatches Options'
      Caption = 'tlbtnSwatchOptions'
      ImageIndex = 1
      OnClick = tlbtnSwatchOptionsClick
    end
  end
  object scrlbxSwatches: TScrollBox
    Left = 0
    Top = 0
    Width = 228
    Height = 86
    Align = alClient
    TabOrder = 1
    object imgSwatches: TImage
      Left = 0
      Top = 0
      Width = 81
      Height = 81
      AutoSize = True
      OnMouseDown = imgSwatchesMouseDown
      OnMouseMove = imgSwatchesMouseMove
    end
  end
end
