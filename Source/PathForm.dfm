object frmPath: TfrmPath
  Left = 192
  Top = 133
  Width = 236
  Height = 160
  BorderStyle = bsSizeToolWin
  Caption = 'Paths'
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
  object tlbrPathTools: TToolBar
    Left = 0
    Top = 92
    Width = 228
    Height = 24
    Align = alBottom
    AutoSize = True
    Caption = 'tlbrPathTools'
    Flat = True
    Images = dmMain.imglstTools
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    object tlbtnVertLine: TToolButton
      Left = 0
      Top = 0
      Width = 8
      Style = tbsSeparator
    end
    object tlbtnFillPath: TToolButton
      Left = 8
      Top = 0
      Cursor = crHandPoint
      Hint = 'Fills path with foreground color'
      Caption = 'tlbtnFillPath'
      ImageIndex = 4
      OnClick = FillPathClick
    end
    object tlbtnStrokePath: TToolButton
      Left = 31
      Top = 0
      Cursor = crHandPoint
      Hint = 'Strokes path with forground color'
      Caption = 'tlbtnStrokePath'
      ImageIndex = 5
      OnClick = StrokePathClick
    end
    object tlbtnLoadPathAsSelection: TToolButton
      Left = 54
      Top = 0
      Cursor = crHandPoint
      Hint = 'Loads path as a selection'
      Caption = 'tlbtnLoadPathAsSelection'
      ImageIndex = 6
      OnClick = LoadPathAsSelectionClick
    end
    object tlbtnCreateNewPath: TToolButton
      Left = 77
      Top = 0
      Cursor = crHandPoint
      Hint = 'Creates new path'
      Caption = 'tlbtnCreateNewPath'
      ImageIndex = 0
      OnClick = CreateNewPathClick
    end
    object tlbtnDeleteCurrentPath: TToolButton
      Left = 100
      Top = 0
      Cursor = crHandPoint
      Hint = 'Deletes current path'
      Caption = 'tlbtnDeleteCurrentPath'
      ImageIndex = 2
      OnClick = DeleteCurrentPathClick
    end
  end
  object scrlbxPathPanelContainer: TScrollBox
    Left = 0
    Top = 0
    Width = 228
    Height = 92
    Align = alClient
    TabOrder = 1
    OnClick = PathPanelContainerClick
  end
end
