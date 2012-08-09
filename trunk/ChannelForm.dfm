object frmChannel: TfrmChannel
  Left = 192
  Top = 133
  Width = 236
  Height = 160
  BorderStyle = bsSizeToolWin
  Caption = 'Channels'
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
  object tlbrChannelTools: TToolBar
    Left = 0
    Top = 92
    Width = 228
    Height = 24
    Align = alBottom
    AutoSize = True
    Caption = 'tlbrChannelTools'
    Flat = True
    Images = dmMain.imglstTools
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    object ToolButton6: TToolButton
      Left = 0
      Top = 0
      Width = 8
      Caption = 'ToolButton6'
      ImageIndex = 1
      Style = tbsSeparator
    end
    object tlbtnLoadChannelAsSelection: TToolButton
      Left = 8
      Top = 0
      Cursor = crHandPoint
      Hint = 'Load channel as selection'
      Enabled = False
      ImageIndex = 6
      OnClick = LoadChannelAsSelectionClick
    end
    object tlbtnSaveSelectionAsChannel: TToolButton
      Left = 31
      Top = 0
      Cursor = crHandPoint
      Hint = 'Save selection as channel'
      Caption = 'tlbtnSaveSelectionAsChannel'
      Enabled = False
      ImageIndex = 1
      OnClick = SaveSelectionAsChannelClick
    end
    object tlbtnCreateNewChannel: TToolButton
      Left = 54
      Top = 0
      Cursor = crHandPoint
      Hint = 'Create new channel'
      Caption = 'tlbtnCreateNewChannel'
      Enabled = False
      ImageIndex = 0
      OnClick = CreateNewChannelClick
    end
    object tlbtnDeleteCurrentChannel: TToolButton
      Left = 77
      Top = 0
      Cursor = crHandPoint
      Hint = 'Delete current channel'
      Caption = 'tlbtnDeleteCurrentChannel'
      Enabled = False
      ImageIndex = 2
      OnClick = DeleteCurrentChannelClick
    end
  end
  object scrlbxChannelPanelContainer: TScrollBox
    Left = 0
    Top = 0
    Width = 228
    Height = 92
    Align = alClient
    TabOrder = 1
  end
end
