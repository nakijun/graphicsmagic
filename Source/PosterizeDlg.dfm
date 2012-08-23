object frmPosterize: TfrmPosterize
  Left = 189
  Top = 127
  BorderStyle = bsDialog
  Caption = 'Posterize'
  ClientHeight = 97
  ClientWidth = 163
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblLevel: TLabel
    Left = 13
    Top = 13
    Width = 29
    Height = 13
    Caption = 'Level:'
  end
  object edtLevel: TEdit
    Left = 46
    Top = 10
    Width = 32
    Height = 21
    TabOrder = 0
    Text = '255'
    OnChange = edtLevelChange
  end
  object btbtnOK: TBitBtn
    Left = 91
    Top = 10
    Width = 61
    Height = 20
    Cursor = crHandPoint
    TabOrder = 1
    OnClick = btbtnOKClick
    Kind = bkOK
  end
  object btbtnCancel: TBitBtn
    Left = 91
    Top = 39
    Width = 61
    Height = 20
    Cursor = crHandPoint
    TabOrder = 2
    Kind = bkCancel
  end
  object chckbxPreview: TCheckBox
    Left = 91
    Top = 72
    Width = 59
    Height = 13
    Cursor = crHandPoint
    Caption = 'Preview'
    Checked = True
    State = cbChecked
    TabOrder = 3
    OnClick = chckbxPreviewClick
  end
end
