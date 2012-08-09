{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-2010, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

program GraphicsMagic;

(* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1/LGPL 2.1/GPL 2.0
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Initial Developer of this unit are
 *
 * Ma Xiaoguang and Ma Xiaoming < gmbros@hotmail.com >
 *
 * Contributor(s):
 * Andre Felix Miertschink
 *
 * Alternatively, the contents of this file may be used under the terms of
 * either the GNU General Public License Version 2 or later (the "GPL"), or
 * the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 * in which case the provisions of the GPL or the LGPL are applicable instead
 * of those above. If you wish to allow use of your version of this file only
 * under the terms of either the GPL or the LGPL, and not to allow others to
 * use your version of this file under the terms of the MPL, indicate your
 * decision by deleting the provisions above and replace them with the notice
 * and other provisions required by the GPL or the LGPL. If you do not delete
 * the provisions above, a recipient may use your version of this file under
 * the terms of any one of the MPL, the GPL or the LGPL.
 * ***** END LICENSE BLOCK ***** *)


{ This include file is suggested by Andre Felix Miertschink to
  make this program could be compiled by Delphi XE. }
  
{$I GraphicsMagic.inc}

uses
{$IFDEF USE_FASTCODE}
  FastCode,            // FastCode lib RTL Speedups
{$ENDIF}
{$IFDEF USE_FASTMOVE}
  FastMove,            // FastMove replaces rtl Move with lighling fast version
{$ENDIF}
{$IFDEF USE_VCLFIXPACK}
  VCLFixPack,          // Will fix many RTL/VCL Bugs and adds some speedups
{$ENDIF}
{$IFDEF USE_TRLVCLOPTIMIZE}
  RtlVclOptimize,      // Will add some Speedups into the Rtl and VCL
{$ENDIF}
  SysUtils,
  Forms,
  MainForm in 'MainForm.pas' {frmMain},
  ChildForm in 'ChildForm.pas' {frmChild},
  NewFileDlg in 'NewFileDlg.pas' {frmCreateNewFile},
  BrightnessContrastDlg in 'BrightnessContrastDlg.pas' {frmBrightnessContrast},
  ColorBalanceDlg in 'ColorBalanceDlg.pas' {frmColorBalance},
  HueSaturationDlg in 'HueSaturationDlg.pas' {frmHueSaturation},
  ReplaceColorDlg in 'ReplaceColorDlg.pas' {frmReplaceColor},
  gmIni in 'gmIni.pas',
  PaintingBrushPopFrm in 'PaintingBrushPopFrm.pas' {frmPaintingBrush},
  PatternNameDlg in 'PatternNameDlg.pas' {frmPatternName},
  ColorSwatchNameDlg in 'ColorSwatchNameDlg.pas' {frmColorSwatchName},
  FeatherSelectionDlg in 'FeatherSelectionDlg.pas' {frmFeatherSelection},
  ColorRangeSelectionDlg in 'ColorRangeSelectionDlg.pas' {frmColorRangeSelection},
  FillDlg in 'FillDlg.pas' {frmFill},
  ThresholdDlg in 'ThresholdDlg.pas' {frmThreshold},
  PosterizeDlg in 'PosterizeDlg.pas' {frmPosterize},
  PatternFillDlg in 'PatternFillDlg.pas' {frmPatternFill},
  PatternsPopFrm in 'PatternsPopFrm.pas' {frmPatterns},
  FigurePropertiesDlg in 'FigurePropertiesDlg.pas' {frmFigureProperties},
  SelectFiguresDlg in 'SelectFiguresDlg.pas' {frmSelectFigures},
  BrushDynamicsPopFrm in 'BrushDynamicsPopFrm.pas' {frmBrushDynamics},
  EraserAdvOptionsPopFrm in 'EraserAdvOptionsPopFrm.pas' {frmEraserAdvancedOptions},
  PaintBucketOptionsPopFrm in 'PaintBucketOptionsPopFrm.pas' {frmPaintBucketAdvancedOptions},
  SavePathDlg in 'SavePathDlg.pas' {frmSavePath},
  CurvesDlg in 'CurvesDlg.pas' {frmCurves},
  GradientPickerPopFrm in 'GradientPickerPopFrm.pas' {frmGradientPicker},
  RenameGradientDlg in 'RenameGradientDlg.pas' {frmGradientName},
  GradientEditorDlg in 'GradientEditorDlg.pas' {frmGradientEditor},
  GradientMapDlg in 'GradientMapDlg.pas' {frmGradientMap},
  GradientFillDlg in 'GradientFillDlg.pas' {frmGradientFill},
  ImageSizeDlg in 'ImageSizeDlg.pas' {frmImageSize},
  CanvasSizeDlg in 'CanvasSizeDlg.pas' {frmCanvasSize},
  RotateCanvasDlg in 'RotateCanvasDlg.pas' {frmRotateCanvas},
  IndexedColorDlg in 'IndexedColorDlg.pas' {frmIndexedColor},
  HistogramDlg in 'HistogramDlg.pas' {frmHistogram},
  PrintOptionsDlg in 'PrintOptionsDlg.pas' {frmPrintOptions},
  PrintPreviewDlg in 'PrintPreviewDlg.pas' {frmPrintPreview},
  RichTextEditorForm in 'RichTextEditorForm.pas' {frmRichTextEditor},
  DuplicateLayerDlg in 'DuplicateLayerDlg.pas' {frmDuplicateLayer},
  SplashForm in 'SplashForm.pas' {frmSplash},
  AboutDlg in 'AboutDlg.pas' {frmAbout},
  LayerPropertiesDlg in 'LayerPropertiesDlg.pas' {frmLayerProperties},
  LevelsToolDlg in 'LevelsToolDlg.pas' {frmLevelsTool},
  ImageColorPickerForm in 'ImageColorPickerForm.pas' {frmImageColorPicker},
  gmLayerPanelCommands in 'gmLayerPanelCommands.pas',
  PreferencesDlg in 'PreferencesDlg.pas' {frmPreferences},
  LicenceDlg in 'LicenceDlg.pas' {frmLicence},
  ChannelOptionsDlg in 'ChannelOptionsDlg.pas' {frmChannelOptions},
  DuplicateChannelDlg in 'DuplicateChannelDlg.pas' {frmDuplicateChannel},
  CreditsDlg in 'CreditsDlg.pas' {frmCredits},
  ChannelMixerDlg in 'ChannelMixerDlg.pas' {frmChannelMixer},
  ApplyImageDlg in 'ApplyImageDlg.pas' {frmApplyImage},
  NilsHaeckBeziers in 'GraphicsMagicLib\NilsHaeckBeziers.pas',
  gmApplyImage in 'GraphicsMagicLib\gmApplyImage.pas',
  gmCommands in 'gmCommands.pas',
  gmPenPathCommands in 'gmPenPathCommands.pas',
  gmSelectionCommands in 'gmSelectionCommands.pas',
  gmHistoryManager in 'gmHistoryManager.pas',
  CommonDataModule in 'GraphicsMagicLib\CommonDataModule.pas' {GMDataModule: TDataModule},
  gmPluginManager in 'gmPluginManager.pas',
  gmTypes in 'GraphicsMagicLib\gmTypes.pas',
  gmCommonFuncs in 'GraphicsMagicLib\gmCommonFuncs.pas',
  gmConstants in 'GraphicsMagicLib\gmConstants.pas',
  gmLayerAndChannel in 'GraphicsMagicLib\gmLayerAndChannel.pas',
  gmLayerReader in 'GraphicsMagicLib\gmLayerReader.pas',
  gmChannelReader in 'GraphicsMagicLib\gmChannelReader.pas',
  gmAlphaFuncs in 'GraphicsMagicLib\gmAlphaFuncs.pas',
  gmBlendModes in 'GraphicsMagicLib\gmBlendModes.pas',
  gmBrushes in 'GraphicsMagicLib\gmBrushes.pas',
  gmChannelMixer in 'GraphicsMagicLib\gmChannelMixer.pas',
  gmColorRange in 'GraphicsMagicLib\gmColorRange.pas',
  gmColorSpace in 'GraphicsMagicLib\gmColorSpace.pas',
  gmColorTransfer in 'GraphicsMagicLib\gmColorTransfer.pas',
  gmConvolve in 'GraphicsMagicLib\gmConvolve.pas',
  gmCrop in 'GraphicsMagicLib\gmCrop.pas',
  gmFigures in 'GraphicsMagicLib\gmFigures.pas',
  gmFill in 'GraphicsMagicLib\gmFill.pas',
  gmGimpBaseEnums in 'GraphicsMagicLib\gmGimpBaseEnums.pas',
  gmGMDFile in 'GraphicsMagicLib\gmGMDFile.pas',
  gmIO in 'GraphicsMagicLib\gmIO.pas',
  gmGaussianBlur in 'GraphicsMagicLib\gmGaussianBlur.pas',
  gmGdkDrawable_Win32 in 'GraphicsMagicLib\gmGdkDrawable_Win32.pas',
  gmGimpBaseCurves in 'GraphicsMagicLib\gmGimpBaseCurves.pas',
  gmColorBalance in 'GraphicsMagicLib\gmColorBalance.pas',
  gmGimpColorBar in 'GraphicsMagicLib\gmGimpColorBar.pas',
  gmGimpColorTypes in 'GraphicsMagicLib\gmGimpColorTypes.pas',
  gmGimpCommonFuncs in 'GraphicsMagicLib\gmGimpCommonFuncs.pas',
  gmCurvesTool in 'GraphicsMagicLib\gmCurvesTool.pas',
  gmGimpHistogram in 'GraphicsMagicLib\gmGimpHistogram.pas',
  gmLevels in 'GraphicsMagicLib\gmLevels.pas',
  gmLevelsTool in 'GraphicsMagicLib\gmLevelsTool.pas',
  gmGimpLut in 'GraphicsMagicLib\gmGimpLut.pas',
  gmGimpRGB in 'GraphicsMagicLib\gmGimpRGB.pas',
  gmGradientMap in 'GraphicsMagicLib\gmGradientMap.pas',
  gmGtkEnums in 'GraphicsMagicLib\gmGtkEnums.pas',
  gmGUIFuncs in 'GraphicsMagicLib\gmGUIFuncs.pas',
  gmPaintFuncs in 'GraphicsMagicLib\gmPaintFuncs.pas',
  gmImageProcessFuncs in 'GraphicsMagicLib\gmImageProcessFuncs.pas',
  gmMagneticLasso in 'GraphicsMagicLib\gmMagneticLasso.pas',
  gmMath in 'GraphicsMagicLib\gmMath.pas',
  gmMeasure in 'GraphicsMagicLib\gmMeasure.pas',
  gmPaintBucket in 'GraphicsMagicLib\gmPaintBucket.pas',
  gmPathPanels in 'GraphicsMagicLib\gmPathPanels.pas',
  gmPatterns in 'GraphicsMagicLib\gmPatterns.pas',
  gmPenTools in 'GraphicsMagicLib\gmPenTools.pas',
  gmPrintOptions in 'GraphicsMagicLib\gmPrintOptions.pas',
  gmRegions in 'GraphicsMagicLib\gmRegions.pas',
  gmReplaceColor in 'GraphicsMagicLib\gmReplaceColor.pas',
  gmResamplers in 'GraphicsMagicLib\gmResamplers.pas',
  gmSelection in 'GraphicsMagicLib\gmSelection.pas',
  gmShapes in 'GraphicsMagicLib\gmShapes.pas',
  gmSwatches in 'GraphicsMagicLib\gmSwatches.pas',
  gmChannelCommands in 'gmChannelCommands.pas',
  InfoForm in 'InfoForm.pas' {frmInfo},
  HistoryForm in 'HistoryForm.pas' {frmHistory},
  HistoryDataModule in 'HistoryDataModule.pas' {dmHistory: TDataModule},
  SwatchForm in 'SwatchForm.pas' {frmSwatch},
  SwatchDataModule in 'SwatchDataModule.pas' {dmSwatches: TDataModule},
  ColorForm in 'ColorForm.pas' {frmColor},
  MainDataModule in 'MainDataModule.pas' {dmMain: TDataModule},
  PathForm in 'PathForm.pas' {frmPath},
  ChannelForm in 'ChannelForm.pas' {frmChannel},
  ChannelDataModule in 'ChannelDataModule.pas' {dmChannel: TDataModule},
  LayerForm in 'LayerForm.pas' {frmLayer},
  LayerDataModule in 'LayerDataModule.pas' {dmLayer: TDataModule},
  GhostForm in 'GhostForm.pas' {frmGhost};

{$R *.RES}

begin
  frmSplash := TfrmSplash.Create(Application);
  frmSplash.ClickEnabled := False;
  frmSplash.Show;
  frmSplash.Update;
  Application.Initialize;
  Application.Title := 'GraphicsMagic Professional 1.4.6';
  Application.CreateForm(TdmMain, dmMain);
  Application.CreateForm(TdmHistory, dmHistory);
  Application.CreateForm(TdmSwatches, dmSwatches);
  Application.CreateForm(TdmLayer, dmLayer);
  Application.CreateForm(TdmChannel, dmChannel);
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmInfo, frmInfo);
  Application.CreateForm(TfrmHistory, frmHistory);
  Application.CreateForm(TfrmColor, frmColor);
  Application.CreateForm(TfrmSwatch, frmSwatch);
  Application.CreateForm(TfrmLayer, frmLayer);
  Application.CreateForm(TfrmChannel, frmChannel);
  Application.CreateForm(TfrmPath, frmPath);
  Application.CreateForm(TfrmPaintingBrush, frmPaintingBrush);
  Application.CreateForm(TfrmFill, frmFill);
  Application.CreateForm(TfrmPatternFill, frmPatternFill);
  Application.CreateForm(TfrmPatterns, frmPatterns);
  Application.CreateForm(TfrmBrushDynamics, frmBrushDynamics);
  Application.CreateForm(TfrmEraserAdvancedOptions, frmEraserAdvancedOptions);
  Application.CreateForm(TfrmPaintBucketAdvancedOptions, frmPaintBucketAdvancedOptions);
  Application.CreateForm(TfrmGradientMap, frmGradientMap);
  Application.CreateForm(TfrmGradientFill, frmGradientFill);
  Application.CreateForm(TfrmGradientPicker, frmGradientPicker);
  Application.CreateForm(TfrmPrintPreview, frmPrintPreview);
  Application.CreateForm(TfrmRichTextEditor, frmRichTextEditor);
  Application.CreateForm(TfrmPrintOptions, frmPrintOptions);
  Application.CreateForm(TfrmCredits, frmCredits);
  Application.CreateForm(TfrmGhost, frmGhost);
  frmSplash.Hide;
  FreeAndNil(frmSplash);  
  Application.Run;
end.
