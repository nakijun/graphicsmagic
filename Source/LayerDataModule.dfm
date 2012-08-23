object dmLayer: TdmLayer
  OldCreateOrder = False
  Left = 192
  Top = 133
  Height = 275
  Width = 381
  object pmnAdjustmentLayers: TPopupMenu
    Left = 50
    Top = 32
    object pmnitmSolidColor: TMenuItem
      Caption = 'Solid Color...'
      OnClick = CreateFillOrAdjustmentLayer
    end
    object pmnitmGradientFill: TMenuItem
      Caption = 'Gradient...'
      OnClick = CreateFillOrAdjustmentLayer
    end
    object pmnitmPattern: TMenuItem
      Caption = 'Pattern...'
      OnClick = CreateFillOrAdjustmentLayer
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object pmnitmGimpLevels: TMenuItem
      Caption = 'Levels...'
      OnClick = CreateFillOrAdjustmentLayer
    end
    object pmnitmGimpCurves: TMenuItem
      Caption = 'Curves...'
      OnClick = CreateFillOrAdjustmentLayer
    end
    object pmnitmColorBalance: TMenuItem
      Caption = 'Color Balance...'
      OnClick = CreateFillOrAdjustmentLayer
    end
    object pmnitmBrightnessContrast: TMenuItem
      Caption = 'Brightness / Contrast...'
      OnClick = CreateFillOrAdjustmentLayer
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object pmnitmHueSaturation: TMenuItem
      Caption = 'Hue / Saturation...'
      OnClick = CreateFillOrAdjustmentLayer
    end
    object pmnitmChannelMixer: TMenuItem
      Caption = 'Channel Mixer...'
      OnClick = CreateFillOrAdjustmentLayer
    end
    object pmnitmGradientMap: TMenuItem
      Caption = 'Gradient Map...'
      OnClick = CreateFillOrAdjustmentLayer
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object pmnitmInvert: TMenuItem
      Caption = 'Invert'
      OnClick = CreateFillOrAdjustmentLayer
    end
    object pmnitmThreshold: TMenuItem
      Caption = 'Threshold...'
      OnClick = CreateFillOrAdjustmentLayer
    end
    object pmnitmPosterize: TMenuItem
      Caption = 'Posterize...'
      OnClick = CreateFillOrAdjustmentLayer
    end
  end
end
