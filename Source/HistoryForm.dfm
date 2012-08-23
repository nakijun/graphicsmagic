object frmHistory: TfrmHistory
  Left = 380
  Top = 218
  Width = 236
  Height = 150
  BorderStyle = bsSizeToolWin
  Caption = 'History'
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
  object tlbrHistoryTools: TToolBar
    Left = 0
    Top = 80
    Width = 228
    Height = 26
    Align = alBottom
    Caption = 'tlbrHistoryTools'
    DragKind = dkDock
    DragMode = dmAutomatic
    Flat = True
    Images = dmHistory.imglstCommand
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 1
      Style = tbsSeparator
    end
    object tlbtnDeleteCurrentState: TToolButton
      Left = 8
      Top = 0
      Cursor = crHandPoint
      Hint = 'Delete current state'
      Caption = 'tlbtnDeleteCurrentState'
      Enabled = False
      ImageIndex = 0
      OnClick = tlbtnDeleteCurrentStateClick
    end
  end
  object scrlbxHistory: TScrollBox
    Left = 0
    Top = 0
    Width = 228
    Height = 80
    Align = alClient
    TabOrder = 1
  end
end
