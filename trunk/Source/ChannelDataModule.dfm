object dmChannel: TdmChannel
  OldCreateOrder = False
  Left = 192
  Top = 133
  Height = 296
  Width = 289
  object pmnChannelOptions: TPopupMenu
    Left = 52
    Top = 48
    object mnitmDuplicateChannel: TMenuItem
      Caption = 'Duplicate Channel...'
      OnClick = DuplicateRightClickedChannel
    end
    object mnitmDeleteChannel: TMenuItem
      Caption = 'Delete Channel'
      OnClick = DeleteRightClickedAlphaChannel
    end
  end
end
