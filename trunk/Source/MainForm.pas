{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang, Ma Xiaoming and GraphicsMagic Team.
  All rights reserved. }

unit MainForm;

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
 *   x2nie - Fathony Luthfillah < x2nie@yahoo.com >
 *
 * Contributor(s):
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

{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CAST OFF}

interface

{$I ..\GraphicsMagicLib\GraphicsMagicLib.Inc}

uses
{ Standard Lib }
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ImgList, ComCtrls, ToolWin, ExtCtrls, ExtDlgs, StdCtrls, Buttons,
{ Graphics32 }
  GR32,
  GR32_RangeBars,
  GR32_Image,
{ externals }
  GR32_Add_BlendModes,
{ GraphicsMagic Package Lib }
  gmGradientRender,
{ GraphicsMagic Lib }
  gmTypes,
  gmImageProcessFuncs,
  gmSelection,
  gmLevelsTool,
  gmPluginManager,
  gmCommands,
  gmBrushes,
  gmPaintBucket,
  gmPenTools,
  gmShapes,
{ GraphicsMagic Forms/Dialogs }
  ChildForm;

type
  TgmMainTool = (gmtStandard,
                 gmtBrush,
                 gmtMarquee,
                 gmtCrop,
                 gmtMeasure,
                 gmtGradient,
                 gmtPaintBucket,
                 gmtEraser,
                 gmtPenTools,
                 gmtShape,
                 gmtTextTool,
                 gmtEyedropper,
                 gmtHandTool);

  TgmStandardTool = (gstPencil,
                     gstStraightLine,
                     gstBezierCurve,
                     gstPolygon,
                     gstRegularPolygon,
                     gstRectangle,
                     gstRoundRectangle,
                     gstEllipse,
                     gstMoveObjects,
                     gstPartiallySelect,
                     gstTotallySelect);

  TgmGhostDetect = class(TThread)
  private
    FPoint    : TPoint;
    FExecProc : TNotifyEvent;
  public
    procedure Execute; override;

    property Point    : TPoint       read FPoint    write FPoint;
    property ExecProc : TNotifyEvent read FExecProc write FExecProc;
  end;

  TfrmMain = class(TForm)
    mnMain: TMainMenu;
    mnhdFile: TMenuItem;
    mnitmNewFile: TMenuItem;
    N1: TMenuItem;
    mnitmExitProgram: TMenuItem;
    mnhdLayer: TMenuItem;
    mnitmFlattenImage: TMenuItem;
    N2: TMenuItem;
    mnitmOpenFile: TMenuItem;
    opnpctrdlgOpenPictures: TOpenPictureDialog;
    N3: TMenuItem;
    mnitmSaveFile: TMenuItem;
    mnitmSaveFileAs: TMenuItem;
    svpctrdlgSavePictures: TSavePictureDialog;
    mnitmClose: TMenuItem;
    mnitmCloseAll: TMenuItem;
    mnhdWindow: TMenuItem;
    mnitmCascade: TMenuItem;
    mnitmTile: TMenuItem;
    mnitmTileHorizontally: TMenuItem;
    mnitmTileVertically: TMenuItem;
    mnitmArrangeIcons: TMenuItem;
    N4: TMenuItem;
    mnitmPathForm: TMenuItem;
    mnitmColorForm: TMenuItem;
    mnitmLayerForm: TMenuItem;
    mnitmStatusBar: TMenuItem;
    mnhdImage: TMenuItem;
    mnitmAdjustments: TMenuItem;
    mnitmBrightnessAndContrast: TMenuItem;
    mnitmColorBalance: TMenuItem;
    mnitmHLSOrHSV: TMenuItem;
    N5: TMenuItem;
    mnitmReplaceColor: TMenuItem;
    mnhdSelect: TMenuItem;
    mnitmSelectAll: TMenuItem;
    mnitmCommitSelection: TMenuItem;
    mnitmDeselect: TMenuItem;
    mnitmDeleteSelection: TMenuItem;
    mnitmInvertSelection: TMenuItem;
    N6: TMenuItem;
    mnitmFeatherRadius: TMenuItem;
    N7: TMenuItem;
    mnitmColorRangeSelection: TMenuItem;
    mnhdEdit: TMenuItem;
    mnitmTransform: TMenuItem;
    mnitmHorizFlip: TMenuItem;
    mnitmVertFlip: TMenuItem;
    N12: TMenuItem;
    mnitmOpenRecent: TMenuItem;
    N13: TMenuItem;
    mnitmFill: TMenuItem;
    N14: TMenuItem;
    mnitmDesaturate: TMenuItem;
    mnitmInvert: TMenuItem;
    mnitmThreshold: TMenuItem;
    mnitmPosterize: TMenuItem;
    N16: TMenuItem;
    mnitmDistortTransformation: TMenuItem;
    mnitmGimpCurvesTool: TMenuItem;
    mnitmGradientMap: TMenuItem;
    N17: TMenuItem;
    mnitmImageSize: TMenuItem;
    mnitmCanvasSize: TMenuItem;
    mnitmRotateCanvas: TMenuItem;
    mnitmRotateClockwise: TMenuItem;
    mnitm30dcw: TMenuItem;
    mnitm45dcw: TMenuItem;
    mnitm60dcw: TMenuItem;
    mnitm90dcw: TMenuItem;
    mnitm180dcw: TMenuItem;
    mnitmRotateCounterclockwise: TMenuItem;
    mnitm30ducw: TMenuItem;
    mnitm45ducw: TMenuItem;
    mnitm60ducw: TMenuItem;
    mnitm90ducw: TMenuItem;
    mnitm180ducw: TMenuItem;
    N18: TMenuItem;
    mnitmRotateArbitrary: TMenuItem;
    mnitmCrop: TMenuItem;
    mnitmMode: TMenuItem;
    N19: TMenuItem;
    mnitmIndexedColor: TMenuItem;
    N20: TMenuItem;
    mnitmHistogram: TMenuItem;
    N21: TMenuItem;
    mnitmCut: TMenuItem;
    mnitmCopy: TMenuItem;
    mnitmPaste: TMenuItem;
    N22: TMenuItem;
    mnitmPrintOptions: TMenuItem;
    mnitmPrintPreview: TMenuItem;
    PrinterSetupDialog: TPrinterSetupDialog;
    PrintDialog: TPrintDialog;
    mnitmPageSetup: TMenuItem;
    mnitmPrintImage: TMenuItem;
    mnitmSaveAll: TMenuItem;
    stsbrMain: TStatusBar;
    N23: TMenuItem;
    mnitmNewAdjustmentLayer: TMenuItem;
    mnitmGimpCurvesLayer: TMenuItem;
    mnitmColorBalanceLayer: TMenuItem;
    mnitmBrightContrastLayer: TMenuItem;
    N24: TMenuItem;
    mnitmHueSaturationLayer: TMenuItem;
    mnitmGradientMapLayer: TMenuItem;
    N25: TMenuItem;
    mnitmInvertLayer: TMenuItem;
    mnitmThresholdLayer: TMenuItem;
    mnitmPosterizeLayer: TMenuItem;
    mnitmNewFillLayer: TMenuItem;
    mnitmSolidColorLayer: TMenuItem;
    mnitmGradientFillLayer: TMenuItem;
    mnitmPatternFillLayer: TMenuItem;
    mnitmInfoForm: TMenuItem;
    N26: TMenuItem;
    mnitmArrangeLayer: TMenuItem;
    mnitmBringLayerToFront: TMenuItem;
    mnitmBringLayerForward: TMenuItem;
    mnitmSendLayerBackward: TMenuItem;
    mnitmSendLayerToBack: TMenuItem;
    mnitmMergeVisibleLayers: TMenuItem;
    mnitmMergeDown: TMenuItem;
    N31: TMenuItem;
    mnitmDuplicateLayer: TMenuItem;
    mnitmDeleteLayer: TMenuItem;
    mnhdHelp: TMenuItem;
    mnitmAbout: TMenuItem;
    N27: TMenuItem;
    mnitmLayerProperties: TMenuItem;
    mnitmRotateTransformation: TMenuItem;
    mnitmScaleTransformation: TMenuItem;
    mnitmGimpLevelsTool: TMenuItem;
    mnitmGimpAutoLevels: TMenuItem;
    mnitmGimpLevelsLayer: TMenuItem;
    N28: TMenuItem;
    mnitmUndoRedo: TMenuItem;
    mnhdFilter: TMenuItem;
    mnitmLastFilter: TMenuItem;
    N30: TMenuItem;
    mnitmStepforeward: TMenuItem;
    mnitmStepBackward: TMenuItem;
    mnitmHistoryForm: TMenuItem;
    N8: TMenuItem;
    mnitmPreferences: TMenuItem;
    mnitmGeneralPreferences: TMenuItem;
    mnitmShowSplash: TMenuItem;
    N9: TMenuItem;
    mnitmSoftwarePageCH: TMenuItem;
    mnitmFiltersUpdate: TMenuItem;
    mnitmFiltersPageCH: TMenuItem;
    mnitmFiltersPageEN: TMenuItem;
    mnitmSoftwarePageEN: TMenuItem;
    N10: TMenuItem;
    mnitmDownloadCH: TMenuItem;
    mnitmDownloadEN: TMenuItem;
    mnitmDownloadSourceCodeAtSourceForge: TMenuItem;
    mnitmOptimalCrop: TMenuItem;
    mnitmChannelMixer: TMenuItem;
    mnitmChannelMixerLayer: TMenuItem;
    N11: TMenuItem;
    mnitmApplyImage: TMenuItem;
    pnlRightDockArea: TPanel;
    pnlZoom: TPanel;
    lblZoomViewer: TLabel;
    spdbtnZoomOut: TSpeedButton;
    ggbrZoomSlider: TGaugeBar;
    spdbtnZoomIn: TSpeedButton;
    pgcntrlDockSite1: TPageControl;
    Splitter1: TSplitter;
    pgcntrlDockSite2: TPageControl;
    Splitter2: TSplitter;
    pgcntrlDockSite3: TPageControl;
    pnlToolBoxHolder: TPanel;
    spdbtnStandardTools: TSpeedButton;
    spdbtnBrushTools: TSpeedButton;
    spdbtnMarqueeTools: TSpeedButton;
    spdbtnGradientTools: TSpeedButton;
    spdbtnCropTools: TSpeedButton;
    spdbtnPaintBucketTools: TSpeedButton;
    spdbtnEraserTools: TSpeedButton;
    spdbtnHandTool: TSpeedButton;
    spdbtnEyedropper: TSpeedButton;
    spdbtnMeasureTool: TSpeedButton;
    spdbtnTextTool: TSpeedButton;
    spdbtnShapeTools: TSpeedButton;
    spdbtnPenTools: TSpeedButton;
    Bevel1: TBevel;
    spdbtnQuickMaskMode: TSpeedButton;
    spdbtnStandardMode: TSpeedButton;
    Bevel2: TBevel;
    pnlToolOptionsVisibility: TPanel;
    imgToolOptionsVisibility: TImage32;
    pnlToolOptions: TPanel;
    ntbkToolOptions: TNotebook;
    pnlFigureOpt: TPanel;
    pnlFigureOptHeader: TPanel;
    scrlbxFigureOptions: TScrollBox;
    spdbtnPencil: TSpeedButton;
    spdbtnStraightLine: TSpeedButton;
    spdbtnBezierCurve: TSpeedButton;
    spdbtnPolygon: TSpeedButton;
    spdbtnRegularPolygon: TSpeedButton;
    spdbtnRectangle: TSpeedButton;
    spdbtnRoundRectangle: TSpeedButton;
    spdbtnEllipse: TSpeedButton;
    spdbtnMoveObjects: TSpeedButton;
    spdbtnRSPartially: TSpeedButton;
    spdbtnRSTotally: TSpeedButton;
    spdbtnSelectFigures: TSpeedButton;
    spdbtnFigureProperties: TSpeedButton;
    spdbtnSelectAllFigures: TSpeedButton;
    spdbtnDeleteFigures: TSpeedButton;
    spdbtnLockFigures: TSpeedButton;
    spdbtnUnlockFigures: TSpeedButton;
    lblPenStyle: TLabel;
    lblPenWidth: TLabel;
    lblRadiusSides: TLabel;
    spdbtnSelectBrushStyle: TSpeedButton;
    lblBrushStyle: TLabel;
    cmbbxPenStyle: TComboBox;
    cmbbxPenWidth: TComboBox;
    edtRadiusSides: TEdit;
    updwnRadiusSides: TUpDown;
    pnlBrushStyleHolder: TPanel;
    imgBrushStyleViewer: TImage;
    pnlBrushOpt: TPanel;
    pnlBrushOptHeader: TPanel;
    scrlbxBrushOptions: TScrollBox;
    spdbtnPaintBrush: TSpeedButton;
    spdbtnHistoryBrush: TSpeedButton;
    spdbtnAirBrush: TSpeedButton;
    spdbtnJetGun: TSpeedButton;
    spdbtnCloneStamp: TSpeedButton;
    spdbtnPatternStamp: TSpeedButton;
    spdbtnBlurBrush: TSpeedButton;
    spdbtnSharpenBrush: TSpeedButton;
    spdbtnSmudge: TSpeedButton;
    spdbtnDodgeBrush: TSpeedButton;
    spdbtnBurnBrush: TSpeedButton;
    spdbtnHighHueBrush: TSpeedButton;
    spdbtnLowHueBrush: TSpeedButton;
    spdbtnHighSaturationBrush: TSpeedButton;
    spdbtnLowSaturationBrush: TSpeedButton;
    spdbtnHighLuminosityBrush: TSpeedButton;
    spdbtnLowLuminosityBrush: TSpeedButton;
    spdbtnBrightnessBrush: TSpeedButton;
    spdbtnDarknessBrush: TSpeedButton;
    spdbtnHighContrastBrush: TSpeedButton;
    spdbtnLowContrastBrush: TSpeedButton;
    spdbtnSelectPaintingBrush: TSpeedButton;
    lblBrushStroke: TLabel;
    spdbtnBrushOpenPatternSelector: TSpeedButton;
    lblStampPattern: TLabel;
    spdbtnBrushDynamics: TSpeedButton;
    lblBrushMode: TLabel;
    lblBrushOPEI: TLabel;
    Label1: TLabel;
    lblBrushInterval: TLabel;
    lblBrushRadius: TLabel;
    pnlPaintingBrushHolder: TPanel;
    imgPaintingBrush: TImage32;
    pnlBrushPatternHolder: TPanel;
    imgPatternForStamp: TImage32;
    cmbbxBrushMode: TComboBox;
    edtBrushOPEI: TEdit;
    updwnBrushOPEI: TUpDown;
    edtBrushInterval: TEdit;
    updwnBrushInterval: TUpDown;
    edtBrushRadius: TEdit;
    updwnBrushRadius: TUpDown;
    chckbxColorAndSample: TCheckBox;
    pnlSelectionOpt: TPanel;
    pnlSelectionOptHeader: TPanel;
    scrlbxMarqueeOptions: TScrollBox;
    spdbtnSelect: TSpeedButton;
    spdbtnSingleRowMarquee: TSpeedButton;
    spdbtnSingleColumnMarquee: TSpeedButton;
    spdbtnRectangularMarquee: TSpeedButton;
    spdbtnRoundRectangularMarquee: TSpeedButton;
    spdbtnEllipticalMarquee: TSpeedButton;
    spdbtnPolygonalMarquee: TSpeedButton;
    spdbtnRegularPolygonMarquee: TSpeedButton;
    spdbtnMagneticLasso: TSpeedButton;
    spdbtnLassoMarquee: TSpeedButton;
    spdbtnMagicWand: TSpeedButton;
    spdbtnNewSelection: TSpeedButton;
    spdbtnAddSelection: TSpeedButton;
    spdbtnSubtractSelection: TSpeedButton;
    spdbtnIntersectSelection: TSpeedButton;
    spdbtnExcludeOverlapSelection: TSpeedButton;
    spdbtnCommitSelection: TSpeedButton;
    spdbtnDeselect: TSpeedButton;
    spdbtnDeleteSelection: TSpeedButton;
    lblToleranceSides: TLabel;
    edtToleranceSides: TEdit;
    updwnToleranceSides: TUpDown;
    chckbxUseAllLayers: TCheckBox;
    chckbxMagneticLassoInteractive: TCheckBox;
    pnlGradientOpt: TPanel;
    pnlGradientOptHeader: TPanel;
    scrlbxGradientOptions: TScrollBox;
    spdbtnLinearGradient: TSpeedButton;
    spdbtnRadialGradient: TSpeedButton;
    spdbtnAngleGradient: TSpeedButton;
    spdbtnReflectedGradient: TSpeedButton;
    spdbtnDiamondGradient: TSpeedButton;
    spdbtnOpenGradientPicker: TSpeedButton;
    lblGradientBlendeMode: TLabel;
    lblGradientOpacity: TLabel;
    Label2: TLabel;
    pnlGradientSelector: TPanel;
    imgSelectedGradient: TImage32;
    cmbbxGradientBlendMode: TComboBox;
    edtGradientOpacity: TEdit;
    updwnGradientOpacity: TUpDown;
    chckbxReverseGradient: TCheckBox;
    pnlCropOpt: TPanel;
    pnlCropOptHeader: TPanel;
    scrlbxCropOptions: TScrollBox;
    pnlCropOptions: TPanel;
    lblCropWidth: TLabel;
    lblCropHeight: TLabel;
    edtCropWidth: TEdit;
    edtCropHeight: TEdit;
    btnCommitCrop: TButton;
    btnCancelCrop: TButton;
    chckbxShieldCroppedArea: TCheckBox;
    chckbxResizeCrop: TCheckBox;
    pnlCropShield: TPanel;
    lblCroppedShieldColor: TLabel;
    shpCroppedShieldColor: TShape;
    lblCroppedShieldOpacity: TLabel;
    lblShieldOpacityPercentSign: TLabel;
    pnlCropShieldHeader: TPanel;
    edtCroppedShieldOpacity: TEdit;
    updwnCroppedShieldOpacity: TUpDown;
    pnlResizeCrop: TPanel;
    lblResizeCropWidth: TLabel;
    lblResizeCropHeight: TLabel;
    pnlResizeCropHeader: TPanel;
    edtResizeCropWidth: TEdit;
    edtResizeCropHeight: TEdit;
    btnShowCropedAreaSize: TButton;
    pnlPaintBucketOpt: TPanel;
    pnlPaintBucketOptHeader: TPanel;
    scrlbxPaintBucketOptions: TScrollBox;
    lblPaintBucketFillSource: TLabel;
    lblPaintBucketFillMode: TLabel;
    lblPaintBucketOpacity: TLabel;
    lblPaintBucketTolerance: TLabel;
    lblPaintBucketPattern: TLabel;
    spdbtnOpenPatternForFill: TSpeedButton;
    spdbtnPaintBucketAdvancedOptions: TSpeedButton;
    cmbbxPaintBucketFillSource: TComboBox;
    cmbbxPaintBucketFillMode: TComboBox;
    edtPaintBucketOpacity: TEdit;
    updwnPaintBucketOpacity: TUpDown;
    edtPaintBucketTolerance: TEdit;
    udpwnPaintBucketTolerance: TUpDown;
    pnlFillPatternHolder: TPanel;
    imgPatternForPaintBucket: TImage32;
    chckbxFillContiguous: TCheckBox;
    chckbxFillAllLayers: TCheckBox;
    pnlEraserOpt: TPanel;
    pnlEraserOptHeader: TPanel;
    scrlbxEraserOptions: TScrollBox;
    spdbtnEraser: TSpeedButton;
    spdbtnBackgroundEraser: TSpeedButton;
    spdbtnMagicEraser: TSpeedButton;
    lblEraserPaintBrush: TLabel;
    spdbtnSelectEraserStroke: TSpeedButton;
    spdbtnEraserAdvancedOptions: TSpeedButton;
    spdbtnEraserDynamics: TSpeedButton;
    lblEraserModeLimit: TLabel;
    lblEraserSampling: TLabel;
    lblEraserOpacityPressure: TLabel;
    lblEraserOpacityPercentSign: TLabel;
    lblEraserInterval: TLabel;
    lblEraserTolerance: TLabel;
    lblEraserTolerancePercentSign: TLabel;
    pnlEraserBrushHolder: TPanel;
    imgEraserPaintingBrush: TImage32;
    cmbbxEraserModeLimit: TComboBox;
    cmbbxEraserSampling: TComboBox;
    edtEraserOpacityPressure: TEdit;
    updwnEraserOpacityPressure: TUpDown;
    edtEraserInterval: TEdit;
    updwnEraserInterval: TUpDown;
    edtEraserTolerance: TEdit;
    updwnEraserTolerance: TUpDown;
    pnlPenPathOpt: TPanel;
    pnlPenPathOptHeader: TPanel;
    scrlbxPenToolsOptions: TScrollBox;
    spdbtnPathComponentSelectionTool: TSpeedButton;
    spdbtnDirectSelectionTool: TSpeedButton;
    spdbtnPenTool: TSpeedButton;
    spdbtnAddAnchorPointTool: TSpeedButton;
    spdbtnDeleteAnchorPointTool: TSpeedButton;
    spdbtnConvertPointTool: TSpeedButton;
    pnlMeasureOpt: TPanel;
    pnlMeasureOptHeader: TPanel;
    scrlbxMeasureOptions: TScrollBox;
    lblMeasureUnit: TLabel;
    lblMeasureStartX: TLabel;
    lblMStartXValue: TLabel;
    lblMeasureStartY: TLabel;
    lblMStartYValue: TLabel;
    lblMeasureWidth: TLabel;
    lblMWidthValue: TLabel;
    lblMeasureHeight: TLabel;
    lblMHeightValue: TLabel;
    lblMeasureD1: TLabel;
    lblMD1Value: TLabel;
    lblMeasureD2: TLabel;
    lblMD2Value: TLabel;
    lblMeasureAngle: TLabel;
    lblMAngleValue: TLabel;
    Bevel3: TBevel;
    cmbbxMeasureUnit: TComboBox;
    btnClearMeasureInfo: TButton;
    pnlShapeToolOpt: TPanel;
    pnlShapeToolOptHeader: TPanel;
    scrlbxShapeOptions: TScrollBox;
    spdbtnShapeMove: TSpeedButton;
    spdbtnShapeRectangle: TSpeedButton;
    spdbtnShapeRoundRect: TSpeedButton;
    spdbtnShapeEllipse: TSpeedButton;
    spdbtnShapeRegularPolygon: TSpeedButton;
    spdbtnShapeLine: TSpeedButton;
    spdbtnAddShape: TSpeedButton;
    spdbtnSubtractShape: TSpeedButton;
    spdbtnIntersectShape: TSpeedButton;
    spdbtnExcludeOverlapShape: TSpeedButton;
    spdbtnDismissTargetPath: TSpeedButton;
    lblShapeToolRSW: TLabel;
    spdbtnShapeBrushStyle: TSpeedButton;
    lblShapeBrushStyle: TLabel;
    edtShapeToolRSW: TEdit;
    updwnShapeToolRSW: TUpDown;
    pnlShapeBrushHolder: TPanel;
    imgShapeBrushStyle: TImage;
    pnlTextToolOpt: TPanel;
    pnlTextToolOptHeader: TPanel;
    scrlbxTextOptions: TScrollBox;
    lblFontFamily: TLabel;
    lblFontColor: TLabel;
    shpFontColor: TShape;
    lblFontSize: TLabel;
    spdbtnLeftAlignText: TSpeedButton;
    spdbtnCenterText: TSpeedButton;
    spdbtnRightAlignText: TSpeedButton;
    spdbtnSelectAllRichText: TSpeedButton;
    spdbtnClearRichText: TSpeedButton;
    spdbtnCommitEdits: TSpeedButton;
    spdbtnCancelEdits: TSpeedButton;
    spdbtnOpenRichText: TSpeedButton;
    spdbtnSaveRichText: TSpeedButton;
    spdbtnSaveRichTextAs: TSpeedButton;
    cmbbxFontFamily: TComboBox;
    cmbbxFontSize: TComboBox;
    pnlFontStyleHolder: TPanel;
    tlbrRichTextSetup: TToolBar;
    tlbtnBold: TToolButton;
    tlbtnItalic: TToolButton;
    tlbtnUnderline: TToolButton;
    mnitmChannelForm: TMenuItem;
    mnitmSwatchForm: TMenuItem;
    spdbtnGhost: TSpeedButton;
    spdbtnUntouched: TSpeedButton;
    Bevel4: TBevel;
    procedure ExitProgram(Sender: TObject);
    procedure CreateNewFile(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mnitmFlattenImageClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure UpdateMenuItemClick(Sender: TObject);
    procedure OpenFiles(Sender: TObject);
    procedure SaveFile(Sender: TObject);
    procedure SaveFileAs(Sender: TObject);
    procedure CloseCurrentForm(Sender: TObject);
    procedure CloseAllForms(Sender: TObject);
    procedure mnitmCascadeClick(Sender: TObject);
    procedure mnitmTileHorizontallyClick(Sender: TObject);
    procedure mnitmTileVerticallyClick(Sender: TObject);
    procedure mnitmArrangeIconsClick(Sender: TObject);
    procedure ShowOrHideTools(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ImageAdjustment(Sender: TObject);
    procedure mnitmSelectAllClick(Sender: TObject);
    procedure mnitmCommitSelectionClick(Sender: TObject);
    procedure mnitmDeselectClick(Sender: TObject);
    procedure mnitmDeleteSelectionClick(Sender: TObject);
    procedure mnitmInvertSelectionClick(Sender: TObject);
    procedure mnitmFeatherRadiusClick(Sender: TObject);
    procedure mnitmColorRangeSelectionClick(Sender: TObject);
    procedure mnitmFillClick(Sender: TObject);
    procedure StepImageAdjustment(Sender: TObject);
    procedure FlipImageClick(Sender: TObject);
    procedure ChangeTransformMode(Sender: TObject);
    procedure mnitmImageSizeClick(Sender: TObject);
    procedure mnitmCanvasSizeClick(Sender: TObject);
    procedure RotateCanvas(Sender: TObject);
    procedure mnitmCropClick(Sender: TObject);
    procedure mnitmIndexedColorClick(Sender: TObject);
    procedure mnitmHistogramClick(Sender: TObject);
    procedure mnitmCutClick(Sender: TObject);
    procedure mnitmCopyClick(Sender: TObject);
    procedure mnitmPasteClick(Sender: TObject);
    procedure mnitmPrintOptionsClick(Sender: TObject);
    procedure mnitmPrintPreviewClick(Sender: TObject);
    procedure mnitmPageSetupClick(Sender: TObject);
    procedure mnitmPrintImageClick(Sender: TObject);
    procedure mnitmSaveAllClick(Sender: TObject);
    procedure CreateANewAdjustmentLayer(Sender: TObject);
    procedure CreateANewFillLayer(Sender: TObject);
    procedure ArrangeLayer(Sender: TObject);
    procedure mnitmMergeVisibleLayersClick(Sender: TObject);
    procedure mnitmMergeDownClick(Sender: TObject);
    procedure mnitmDuplicateLayerClick(Sender: TObject);
    procedure mnitmDeleteLayerClick(Sender: TObject);
    procedure mnitmAboutClick(Sender: TObject);
    procedure mnitmLayerPropertiesClick(Sender: TObject);
    procedure mnitmGimpAutoLevelsClick(Sender: TObject);
    procedure mnitmUndoRedoClick(Sender: TObject);
    procedure mnitmLastFilterClick(Sender: TObject);
    procedure mnitmStepBackwardClick(Sender: TObject);
    procedure mnitmStepforewardClick(Sender: TObject);
    procedure mnitmGeneralPreferencesClick(Sender: TObject);
    procedure mnitmShowSplashClick(Sender: TObject);
    procedure mnitmSoftwarePageCHClick(Sender: TObject);
    procedure mnitmFiltersUpdateClick(Sender: TObject);
    procedure mnitmFiltersPageCHClick(Sender: TObject);
    procedure mnitmFiltersPageENClick(Sender: TObject);
    procedure mnitmSoftwarePageENClick(Sender: TObject);
    procedure mnitmDownloadCHClick(Sender: TObject);
    procedure mnitmDownloadENClick(Sender: TObject);
    procedure mnitmDownloadSourceCodeAtSourceForgeClick(Sender: TObject);
    procedure mnitmOptimalCropClick(Sender: TObject);
    procedure mnitmApplyImageClick(Sender: TObject);
    procedure ChangeMainToolClick(Sender: TObject);
    procedure PopupBrushStyleMenusClick(Sender: TObject);
    procedure ShapeBrushStyleClick(Sender: TObject);
    procedure ZoomSliderChange(Sender: TObject);
    procedure cmbbxPenStyleDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure spdbtnZoomInClick(Sender: TObject);
    procedure spdbtnZoomOutClick(Sender: TObject);
    procedure SetChildFormEditMode(Sender: TObject);
    procedure ChangeQuickMaskOptions(Sender: TObject);
    procedure ChangeStandardTools(Sender: TObject);
    procedure OpenSelectFiguresDialog(Sender: TObject);
    procedure OpenFigurePropertiesDialog(Sender: TObject);
    procedure SelectAllFigures(Sender: TObject);
    procedure DeleteSelectedFigures(Sender: TObject);
    procedure LockSelectedFigures(Sender: TObject);
    procedure UnlockSelectedFigures(Sender: TObject);
    procedure cmbbxPenStyleChange(Sender: TObject);
    procedure ChangeGlobalPenWidth(Sender: TObject);
    procedure cmbbxPenWidthDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ChangeRadiusSides(Sender: TObject);
    procedure ChangeBrushTools(Sender: TObject);
    procedure OpenPaintingBrushSelector(Sender: TObject);
    procedure OpenPatternSelectorForStamp(Sender: TObject);
    procedure OpenBrushDynamicsEditor(Sender: TObject);
    procedure ChangeBrushMode(Sender: TObject);
    procedure ChangeBrushOPEI(Sender: TObject);
    procedure ChangeBrushInterval(Sender: TObject);
    procedure ChangeBrushRadius(Sender: TObject);
    procedure chckbxColorAndSampleClick(Sender: TObject);
    procedure ChangeMarqueeTools(Sender: TObject);
    procedure MarqueeToolButtonMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ChangeMarqueeMode(Sender: TObject);
    procedure spdbtnCommitSelectionClick(Sender: TObject);
    procedure spdbtnDeselectClick(Sender: TObject);
    procedure spdbtnDeleteSelectionClick(Sender: TObject);
    procedure edtToleranceSidesChange(Sender: TObject);
    procedure ChangeGradientTools(Sender: TObject);
    procedure spdbtnOpenGradientPickerClick(Sender: TObject);
    procedure imgSelectedGradientClick(Sender: TObject);
    procedure imgSelectedGradientPaintStage(Sender: TObject;
      Buffer: TBitmap32; StageNum: Cardinal);
    procedure ChangeGradientBlendMode(Sender: TObject);
    procedure ChangeGradientOpacity(Sender: TObject);
    procedure chckbxReverseGradientClick(Sender: TObject);
    procedure edtCropWidthChange(Sender: TObject);
    procedure edtCropHeightChange(Sender: TObject);
    procedure btnCommitCropClick(Sender: TObject);
    procedure btnCancelCropClick(Sender: TObject);
    procedure ShieldCroppedArea(Sender: TObject);
    procedure chckbxResizeCropClick(Sender: TObject);
    procedure shpCroppedShieldColorMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ChangeCroppedShieldOpacity(Sender: TObject);
    procedure edtResizeCropWidthChange(Sender: TObject);
    procedure edtResizeCropWidthExit(Sender: TObject);
    procedure edtResizeCropHeightChange(Sender: TObject);
    procedure edtResizeCropHeightExit(Sender: TObject);
    procedure btnShowCropedAreaSizeClick(Sender: TObject);
    procedure ChangePaintBucketFillSource(Sender: TObject);
    procedure ChangePaintBucketFillMode(Sender: TObject);
    procedure ChangePaintBucketOpacity(Sender: TObject);
    procedure ChangePaintBucketTolerance(Sender: TObject);
    procedure spdbtnOpenPatternForFillClick(Sender: TObject);
    procedure spdbtnPaintBucketAdvancedOptionsClick(Sender: TObject);
    procedure ChangeEraserTools(Sender: TObject);
    procedure spdbtnSelectEraserStrokeClick(Sender: TObject);
    procedure spdbtnEraserAdvancedOptionsClick(Sender: TObject);
    procedure spdbtnEraserDynamicsClick(Sender: TObject);
    procedure ChangeEraserModeLimit(Sender: TObject);
    procedure ChangeEraserSampling(Sender: TObject);
    procedure ChangeEraserOpacityPressure(Sender: TObject);
    procedure ChangeEraserInterval(Sender: TObject);
    procedure ChangeEraserTolerance(Sender: TObject);
    procedure ChangePenTools(Sender: TObject);
    procedure ChangeMeasureUnit(Sender: TObject);
    procedure ClearMeasureInfoClick(Sender: TObject);
    procedure ChangeShapeRegionTools(Sender: TObject);
    procedure ChangeRegionCombineMode(Sender: TObject);
    procedure spdbtnDismissTargetPathClick(Sender: TObject);
    procedure edtShapeToolRSWChange(Sender: TObject);
    procedure cmbbxFontFamilyChange(Sender: TObject);
    procedure shpFontColorMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure cmbbxFontSizeChange(Sender: TObject);
    procedure tlbtnBoldClick(Sender: TObject);
    procedure tlbtnItalicClick(Sender: TObject);
    procedure tlbtnUnderlineClick(Sender: TObject);
    procedure spdbtnLeftAlignTextClick(Sender: TObject);
    procedure spdbtnCenterTextClick(Sender: TObject);
    procedure spdbtnRightAlignTextClick(Sender: TObject);
    procedure spdbtnSelectAllRichTextClick(Sender: TObject);
    procedure spdbtnClearRichTextClick(Sender: TObject);
    procedure spdbtnCommitEditsClick(Sender: TObject);
    procedure spdbtnCancelEditsClick(Sender: TObject);
    procedure spdbtnOpenRichTextClick(Sender: TObject);
    procedure spdbtnSaveRichTextClick(Sender: TObject);
    procedure spdbtnSaveRichTextAsClick(Sender: TObject);
    procedure MainToolsDblClick(Sender: TObject);
    procedure imgToolOptionsVisibilityClick(Sender: TObject);
    procedure PageControlDockSiteChange(Sender: TObject);
    procedure SetCanExecClickMark(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure spdbtnGhostClick(Sender: TObject);
    procedure spdbtnUntouchedClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
{ Common }
    FOutputGraphicsFormat: TgmOutputGraphicsFormat;
    FChildFormIsCreating : Boolean;
    FFigureUnits         : TgmAppliedUnit;  // unit for figures
    FNewBitmapWidth      : Integer;
    FNewBitmapHeight     : Integer;
    FGlobalForeColor     : TColor;
    FGlobalBackColor     : TColor;
    FForeGrayColor       : TColor;       // grayscale color of the global foreground color
    FBackGrayColor       : TColor;       // grayscale color of the global background color
    FOpenRecentPathList  : TStringList;  // path list of opened files
    FOpenRecentMenuList  : TList;        // menu list of OpenRecent
    
    FMainTool            : TgmMainTool;
    FCanChange           : Boolean;
    FCanExecClick        : Boolean;      // prevent from the OnClick events of Buttons be execute twice 
    FGlobalPenStyle      : TPenStyle;
    FGlobalPenWidth      : Integer;
    FGlobalBrushStyle    : TBrushStyle;
    
{ Figure Tools Fields }
    FPencil              : TgmPaintBrush;
    FStandardTool        : TgmStandardTool;
    FLastStandardTool    : TgmStandardTool;
    FStandardCornerRadius: Integer;
    FStandardPolygonSides: Integer;
    
{ Brush Tools Fields }
    FGMBrush                 : TgmBrush;
    FAirBrush                : TgmAirBrush;
    FJetGun                  : TgmJetGun;
    FBrushTool               : TgmBrushTool;
    FBrushBlendMode          : TBlendMode32;
    FBrushOpacity            : Integer;
    FBrushIntensity          : Integer;
    FBrushRadius             : Integer;
    FBrushInterval           : Integer;
    FSmudgePressure          : Integer;
    FBlurSharpenPressure     : Integer;
    FBlurSharpenTimerInterval: Integer;
    FDodgeBurnExposure       : Integer;
    FDodgeBurnMode           : TgmDodgeBurnMode;
    FAirPressure             : Byte;
    FJetGunPressure          : Byte;
    FIsRandomColor           : Boolean;
    FIsUseAllLayers          : Boolean;

{ Marquee Tools Fields }
    FMarqueeTool       : TgmMarqueeTools;
    FMarqueeMode       : TgmMarqueeMode;
    FRPMSides          : Integer;  // sides of regular polygonal marquee
    FRRMCornerRadius   : Integer;  // corner radius of rounded-rectangular marquee
    FMagicWandTolerance: Byte;

{ Gradient Tools Fields }
    FGradientRenderMode  : TgmGradientRenderMode;
    FGradientBlendMode   : TBlendMode32;
    FGradientBlendOpacity: Integer;

{ Paint Bucket Tools Fields }
    FPaintBucketFillSource: TgmPaintBucketFillSource;
    FPaintBucketBlendMode : TBlendMode32;
    FPaintBucketOpacity   : Byte;
    FPaintBucketTolerance : Byte;

{ Eraser Tools Fields }
    FGMEraser             : TgmBrush;
    FEraserTool           : TgmEraserTool;
    FErasingMode          : TgmErasingMode;
    FBackgroundEraserLimit: TgmBackgroundEraserLimit;
    FEraserSamplingMode   : TgmBackgroundSamplingMode;
    FErasingOpacity       : Integer;
    FErasingInterval      : Integer;
    FAirErasingPressure   : Integer;
    FAirErasingInterval   : Integer;
    FErasingTolerance     : Byte;

{ Pen Tools Fields }
    FPenTool      : TgmPenTools;
    FActivePenTool: TgmPenTools;

{ Shape Tools Fields }
    FShapeRegionTool  : TgmShapeRegionTool;
    FRegionCombineMode: TgmRegionCombineMode;
    FShapeCornerRadius: Integer;
    FShapePolygonSides: Integer;
    FLineWeight       : Integer;
    FShapeBrushStyle  : TBrushStyle;

{ Filter }
    FGMPluginInfoList      : TgmPluginInfoList;
    FFilterCategoryMenuList: TgmCategoryMenuItemList;
    FLastFilterMenuItem    : TMenuItem;

{ Ghost }
    FGhosts          : TList;
    FGhostDetect     : TgmGhostDetect;
    FGhostModeEnabled: Boolean;
    
    procedure GhostsWakeUp(WakeUp:Boolean);
    procedure GhostsFly;
    procedure GhostsFade(Fade:Boolean);
    procedure WMWINDOWPOSCHANGING(var Msg: TWMWINDOWPOSCHANGING); message WM_WINDOWPOSCHANGING;
    procedure DetectMousePos(ASender: TObject);

    procedure InitFilterMenuItem;
    procedure ExecuteFilters(Sender: TObject);
    function OpenImageInChildForm(const AFileName: string): Boolean;
    function LoadGMDInChildForm(const AFileName: string): Boolean;

    { When trying to open an opened file, then we just show the form with the
      opened file to top of the screen. }
    function ShowOpenedImageTop(const CheckFileName: string): Boolean;

    procedure ShowCannotProcessEmptyLayerInfo(Sender: TObject);

{ Open Recent }
    procedure LoadOpenRecentPathToList(AStringList: TStringList);
    procedure AddFilePathToList(AStringList: TStringList; const AFilePath: string);
    procedure UpdateOpenRecentMenuItem;
    procedure OpenRecentMenuItemClick(Sender: TObject);
    procedure WriteOpenRecentInfoToIniFile;

{ Undo/Redo }
    procedure CreateAutoLevelsUndoRedoCommand;
    procedure SetUndoRedoForFilters(const FilterName: string);
    procedure CreateCommandStorageFolder;  // to create a folder to save the temporary command file

{ Tools }
    function StandardToolsGetStatusInfo: string;
    function BrushToolsGetStatusInfo: string;
    function MarqueeToolsGetStatusInfo: string;
    function GradientToolsGetStatusInfo: string;
    function EraserToolsGetStatusInfo: string;
    function PenToolsGetStatusInfo: string;
    function ShapeToolsGetStatusInfo: string;

    procedure ShowStatusInfoOnStatusBar;

{ Text Tools }
    procedure GetFontNames(const AItems: TStrings);  // Get system supported fonts.
  public
    // global bitmaps used for various image adjustment dialogs, such as filters
    FBeforeProc        : TBitmap32;
    FAfterProc         : TBitmap32;
    FSelectionClipboard: TgmSelection;  // save the selection as if it is in clipboard

    procedure ShowColorRGBInfoOnInfoViewer(const AColor: TColor);
    procedure ShowColorCMYKInfoOnInfoViewer(const AColor: TColor);
    procedure ShowOriginalCoordInfoOnInfoViewerInPixel(const X, Y: Integer);
    procedure ShowCurrentCoordInfoOnInfoViewerInPixel(const X, Y: Integer);
    procedure UpdateStandardOptions;     // Update components of standard page.
    procedure UpdateBrushOptions;        // Update components of brush page.
    procedure UpdateMarqueeOptions;      // Update components of marquee page.
    procedure UpdateCropOptions;         // Update components of crop page.
    procedure UpdatePaintBucketOptions;  // Update components of paint bucket page.
    procedure UpdateEraserOptions;       // Update components of eraser page.
    procedure UpdateMeasureOptions;      // Update componets of measure page.
    procedure UpdateShapeOptions;        // Update componets of shape page.
    procedure UpdateTextOptions;         // Update componets of text page.
    procedure UpdateToolsOptions;
    
    procedure DuplicateSelection;
    function PasteSelection: Boolean;
    
    procedure CreateFillOrAdjustmentLayer(Sender: TObject);

    { This function will loops through each child form and get all the
      file names in that form that has the same size image with the destination
      image which was in the Active Child Form. The function will return all
      the file names it found as result. It will return nil if no such image is
      matched. }
    function GetFileNamesWithSameSizeImage: TStringList;
    function GetChildFormPointerByFileName(const AFileName: string): TfrmChild;

{ Brush Tools }
    function GetBrushName: string;

{ Text Tools }
    procedure ChangeIndexByFontName(const AFontName: string);
    procedure ChangeIndexByFontSize(const AFontSize: Byte);
    procedure SaveNamedTextFile;
    procedure SaveNotNamedTextFile;

{ Common Properties }
    property OutputGraphicsFormat: TgmOutputGraphicsFormat read FOutputGraphicsFormat write FOutputGraphicsFormat;
    property ChildFormIsCreating : Boolean                 read FChildFormIsCreating;
    property FigureUnits         : TgmAppliedUnit          read FFigureUnits          write FFigureUnits;
    property NewBitmapWidth      : Integer                 read FNewBitmapWidth;
    property NewBitmapHeight     : Integer                 read FNewBitmapHeight;
    property GlobalForeColor     : TColor                  read FGlobalForeColor      write FGlobalForeColor;
    property GlobalBackColor     : TColor                  read FGlobalBackColor      write FGlobalBackColor;
    property ForeGrayColor       : TColor                  read FForeGrayColor        write FForeGrayColor;
    property BackGrayColor       : TColor                  read FBackGrayColor        write FBackGrayColor;
    property MainTool            : TgmMainTool             read FMainTool;
    property CanChange           : Boolean                 read FCanChange            write FCanChange;
    property GlobalPenStyle      : TPenStyle               read FGlobalPenStyle;
    property GlobalPenWidth      : Integer                 read FGlobalPenWidth;
    property GlobalBrushStyle    : TBrushStyle             read FGlobalBrushStyle     write FGlobalBrushStyle;
    
{ Figure Tools Properties }
    property StandardTool        : TgmStandardTool read FStandardTool;
    property LastStandardTool    : TgmStandardTool read FLastStandardTool;
    property StandardCornerRadius: Integer         read FStandardCornerRadius;
    property StandardPolygonSides: Integer         read FStandardPolygonSides;
    property Pencil              : TgmPaintBrush   read FPencil;

{ Brush Tools Properties }
    property GMBrush                 : TgmBrush         read FGMBrush;
    property AirBrush                : TgmAirBrush      read FAirBrush;
    property JetGun                  : TgmJetGun        read FJetGun;
    property BrushTool               : TgmBrushTool     read FBrushTool;
    property BrushBlendMode          : TBlendMode32     read FBrushBlendMode;
    property BrushOpacity            : Integer          read FBrushOpacity;
    property BrushIntensity          : Integer          read FBrushIntensity;
    property BrushInterval           : Integer          read FBrushInterval;
    property SmudgePressure          : Integer          read FSmudgePressure;
    property BlurSharpenPressure     : Integer          read FBlurSharpenPressure;
    property BlurSharpenTimerInterval: Integer          read FBlurSharpenTimerInterval;
    property DodgeBurnExposure       : Integer          read FDodgeBurnExposure;
    property DodgeBurnMode           : TgmDodgeBurnMode read FDodgeBurnMode;
    property AirPressure             : Byte             read FAirPressure;
    property JetGunPressure          : Byte             read FJetGunPressure;
    property IsRandomColor           : Boolean          read FIsRandomColor;
    property IsUseAllLayers          : Boolean          read FIsUseAllLayers;

{ Marquee Tools Properties }
    property MarqueeTool       : TgmMarqueeTools read FMarqueeTool;
    property MarqueeMode       : TgmMarqueeMode  read FMarqueeMode;
    property RPMSides          : Integer         read FRPMSides;
    property RRMCornerRadius   : Integer         read FRRMCornerRadius;
    property MagicWandTolerance: Byte            read FMagicWandTolerance;

{ Gradient Tools Properties }
    property GradientRenderMode  : TgmGradientRenderMode read FGradientRenderMode;
    property GradientBlendMode   : TBlendMode32          read FGradientBlendMode;
    property GradientBlendOpacity: Integer               read FGradientBlendOpacity;

{ Paint Bucket Tools Propperties }
    property PaintBucketFillSource: TgmPaintBucketFillSource read FPaintBucketFillSource;
    property PaintBucketBlendMode : TBlendMode32             read FPaintBucketBlendMode;
    property PaintBucketOpacity   : Byte                     read FPaintBucketOpacity;
    property PaintBucketTolerance : Byte                     read FPaintBucketTolerance;

{ Eraser Tools Properties }
    property GMEraser             : TgmBrush                  read FGMEraser;
    property EraserTool           : TgmEraserTool             read FEraserTool;
    property ErasingMode          : TgmErasingMode            read FErasingMode;
    property BackgroundEraserLimit: TgmBackgroundEraserLimit  read FBackgroundEraserLimit;
    property EraserSamplingMode   : TgmBackgroundSamplingMode read FEraserSamplingMode;
    property ErasingOpacity       : Integer                   read FErasingOpacity;
    property ErasingInterval      : Integer                   read FErasingInterval;
    property AirErasingPressure   : Integer                   read FAirErasingPressure;
    property AirErasingInterval   : Integer                   read FAirErasingInterval;
    property ErasingTolerance     : Byte                      read FErasingTolerance;

{ Pen Tools properties }
    property PenTool      : TgmPenTools read FPenTool write FPenTool;
    property ActivePenTool: TgmPenTools read FActivePenTool;

{ Shape Tool properties }
    property ShapeRegionTool  : TgmShapeRegionTool   read FShapeRegionTool;
    property RegionCombineMode: TgmRegionCombineMode read FRegionCombineMode;
    property ShapeCornerRadius: Integer              read FShapeCornerRadius;
    property ShapePolygonSides: Integer              read FShapePolygonSides;
    property LineWeight       : Integer              read FLineWeight;
    property ShapeBrushStyle  : TBrushStyle          read FShapeBrushStyle write FShapeBrushStyle;   
  end;

var
  frmMain        : TfrmMain;
  ActiveChildForm: TfrmChild;  // global pointer to the currently active child form
  PrevChildForm  : TfrmChild;

const
  VER : string = '1.4.7';

implementation

uses
{ Standard Lib }
  ShellAPI, Clipbrd, Printers, INIFiles,
{ Externals }
  Preview, ColorLibrary,
{ Graphics32 }
  GR32_Backends, GR32_Layers, GR32_LowLevel,
{ GraphicsMagic Lib }
  gmConstants,
  gmIO,                        // LoadGraphicsFile(), SaveGraphicsFile()
  gmLayerAndChannel,
  gmIni,
  gmGimpHistogram,
  gmGMDFile,                   // used to load GraphicsMagic work flow from disk
  gmAlphaFuncs,
  gmGUIFuncs,
  gmHistoryManager,
  gmLayerPanelCommands,
  gmSelectionCommands,
  gmCommonFuncs,
  gmMeasure,
  gmFigures,
  gmConvolve,
  gmPaintFuncs,
  gmMath,
{ GraphicsMagic Data Modules }
  MainDataModule,
  HistoryDataModule,
  LayerDataModule,
{ GraphicsMagic Forms/Dialogs }
  InfoForm,                    // frmInfo              
  HistoryForm,
  ColorForm,
  SwatchForm,
  LayerForm,                   // frmLayer
  ChannelForm,
  PathForm,
  RichTextEditorForm,          // frmRichTextEditor
  SplashForm,
  GhostForm,
  PatternsPopFrm,
  GradientPickerPopFrm,
  PaintingBrushPopFrm,
  BrushDynamicsPopFrm,
  PaintBucketOptionsPopFrm,
  EraserAdvOptionsPopFrm,
  NewFileDlg,                  // frmCreateNewFile
  ColorBalanceDlg,             // frmColorBalance
  HueSaturationDlg,            // frmHueSaturation
  BrightnessContrastDlg,       // frmBrightnessAndContrast
  ReplaceColorDlg,             // frmReplaceColor
  ThresholdDlg,                // frmThreshold
  PosterizeDlg,                // frmPosterize
  FeatherSelectionDlg,         // frmFeatherSelection
  ColorRangeSelectionDlg,      // frmColorRangeSelection
  FillDlg,                     // frmFill
  CurvesDlg,
  LevelsToolDlg,
  ChannelMixerDlg,
  GradientMapDlg,
  ImageSizeDlg,                // frmImageSize
  CanvasSizeDlg,               // frmCanvasSize
  RotateCanvasDlg,             // frmRotateCanvas
  IndexedColorDlg,             // frmIndexedColor
  HistogramDlg,                // frmHistogram
  PrintOptionsDlg,             // frmPrintOptions
  PrintPreviewDlg,             // frmPrintPreview
  GradientFillDlg,             // frmGradientFill
  PatternFillDlg,              // frmPatternFill
  DuplicateLayerDlg,           // frmDuplicateLayer
  LayerPropertiesDlg,          // frmLayerProperties
  AboutDlg,                    // frmAbout
  PreferencesDlg,
  ApplyImageDlg,               // frmApplyImage
  ChannelOptionsDlg,
  SelectFiguresDlg,
  FigurePropertiesDlg,
  GradientEditorDlg;

{$R *.DFM}

const
  STANDARD_PAGE_INDEX     = 0;
  BRUSH_PAGE_INDEX        = 1;
  MARQUEE_PAGE_INDEX      = 2;
  GRADIENT_PAGE_INDEX     = 3;
  CROP_PAGE_INDEX         = 4;
  PAINT_BUCKET_PAGE_INDEX = 5;
  ERASER_PAGE_INDEX       = 6;
  PEN_TOOLS_PAGE_INDEX    = 7;
  MEASURE_PAGE_INDEX      = 8;
  SHAPE_PAGE_INDEX        = 9;
  TEXT_PAGE_INDEX         = 10;
  BLANK_PAGE_INDEX        = 11;

  LEFT_GHOST_FORM_INDEX   = 0;
  RIGHT_GHOST_FORM_INDEX  = 1;

{ these methods for common use }

procedure TgmGhostDetect.Execute;
var
  p: TPoint;
begin
  while not Terminated do
  begin
    GetCursorPos(p);

    //dont send update when mouse is same as previous position
    if ( (p.X <> FPoint.X) or (p.Y <> FPoint.Y) ) and
       Assigned(FExecProc) then
    begin
      FPoint := p;
      FExecProc(Self);
    end;

    Sleep(10); //dont be too fast while looping
  end;
end;

// this procedure is for plug-ins for showing the processed image by themselves
procedure UpdateView;
begin
  Screen.Cursor := crHourGlass;
  try
    if Assigned(ActiveChildForm.Selection) then
    begin
      if ActiveChildForm.ChannelManager.CurrentChannelType in
           [wctRGB, wctRed, wctGreen, wctBlue] then
      begin
        if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsLockTransparency) or
           (ActiveChildForm.ChannelManager.SelectedColorChannelCount < 3) then
        begin
          // preserve transparency
          ReplaceAlphaChannelWithSource(ActiveChildForm.Selection.CutOriginal,
                                        frmMain.FBeforeProc);
        end;
      end;

      ActiveChildForm.ShowProcessedSelection;
    end
    else
    begin
      case ActiveChildForm.ChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            if Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
            begin
              ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
            end;
          end;

        wctQuickMask:
          begin
            if Assigned(ActiveChildForm.ChannelManager.QuickMaskPanel) then
            begin
              ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Changed;
            end;
          end;

        wctLayerMask:
          begin
            if Assigned(ActiveChildForm.ChannelManager.LayerMaskPanel) then
            begin
              ActiveChildForm.ChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(
                0, 0, ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
            end;

            ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsLockTransparency) or
               (ActiveChildForm.ChannelManager.SelectedColorChannelCount < 3) then
            begin
              // preserve transparency
              ReplaceAlphaChannelWithSource(
                ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                frmMain.FBeforeProc);
            end;

            ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;
          end;
      end;
    end;
    
  finally
    Screen.Cursor := crDefault;
  end;
end; 

procedure TfrmMain.InitFilterMenuItem;
var
  i, j            : Integer;
  FilterPath      : string;
  CategoryName    : string;
  PluginName      : string;
  GMPlugin        : TgmPlugin;
  PluginInfo      : TgmPluginInfo;
  FilterPathList  : TStringList;
  CategoryList    : TgmUniqueStringList;
  PluginNameList  : TgmUniqueStringList;
  CategoryMenuItem: TMenuItem;
begin
  if Assigned(FGMPluginInfoList) and Assigned(FFilterCategoryMenuList) then
  begin
    FilterPathList := TStringList.Create;
    try
      // Get sorted string list of filter files.
      FilterPath := ExtractFilePath( ParamStr(0) ) + 'Plug-Ins';

      ZarkoFileSearch(FilterPath, '*.gmp', False, FilterPathList);
      FilterPathList.Sort;

      // Get info of all filters.
      if FilterPathList.Count > 0 then
      begin
        for i := 0 to FilterPathList.Count - 1 do
        begin
          GMPlugin := TgmPlugin.Create(FilterPathList.Strings[i]);
          try
            CategoryName := GMPlugin.GetPluginCategory;
            PluginName   := GMPlugin.GetPluginName;

            PluginInfo                    := TgmPluginInfo.Create;
            PluginInfo.LibFileName        := FilterPathList.Strings[i];
            PluginInfo.CategoryName       := CategoryName;
            PluginInfo.PluginName         := PluginName;
            PluginInfo.IsAdjustable       := GMPlugin.IsAdjustablePlugin;
            PluginInfo.IsChannelSupported := GMPlugin.IsChannelSupported;

            FGMPluginInfoList.Add(PluginInfo);
          finally
            GMPlugin.Free;
          end;
        end;

        // Create filter menu items.
        CategoryList := FGMPluginInfoList.GetSortedCategoryList;

        if CategoryList <> nil then
        begin
          // Create filter's category menu items (One-Level menu).
          for i := 0 to CategoryList.Count - 1 do
          begin
            CategoryMenuItem         := TMenuItem.Create(Self);
            CategoryName             := CategoryList.Strings[i];
            CategoryMenuItem.Caption := CategoryName;
            CategoryMenuItem.Visible := True;

            mnhdFilter.Add(CategoryMenuItem);
            FFilterCategoryMenuList.Add(CategoryMenuItem);

            // Create filter menu items (Two-Level menu).
            PluginNameList := FGMPluginInfoList.GetSortedPluginNameList(CategoryName);

            if PluginNameList <> nil then
            begin
              for j := 0 to PluginNameList.Count - 1 do
              begin
                PluginName := PluginNameList.Strings[j];
                PluginInfo := FGMPluginInfoList.GetPluginInfoByName(PluginName);

                if PluginInfo <> nil then
                begin
                  PluginInfo.PluginMenu := TMenuItem.Create(Self);

                  if PluginInfo.IsAdjustable then
                  begin
                    PluginInfo.PluginMenu.Caption := PluginName + '...';
                  end
                  else
                  begin
                    PluginInfo.PluginMenu.Caption := PluginName;
                  end;

                  PluginInfo.PluginMenu.OnClick := ExecuteFilters;
                  CategoryMenuItem.Add(PluginInfo.PluginMenu);
                end;
              end;
              
              PluginNameList.Clear;
              FreeAndNil(PluginNameList);
            end;
          end;

          CategoryList.Clear;
          CategoryList.Free;
        end;
      end;
    finally
      FilterPathList.Clear;
      FilterPathList.Free;
    end;
  end;
end;

procedure TfrmMain.ExecuteFilters(Sender: TObject);
var
  LPluginInfo: TgmPluginInfo;
  LGMPlugin  : TgmPlugin;
  P          : PColor32;
  W, H       : Integer;
  LFillColor : TColor32;
begin
  LFillColor := $00000000;
  P          := nil;
  W          := 0;
  H          := 0;

  if Assigned(FGMPluginInfoList) then
  begin
    // preparing...
    if Assigned(ActiveChildForm.Selection) then
    begin
      FBeforeProc.Assign(ActiveChildForm.Selection.CutOriginal);

      if Assigned(ActiveChildForm.SelectionHandleLayer) then
      begin
        ActiveChildForm.SelectionHandleLayer.Visible := False;
      end;

      ActiveChildForm.ShowProcessedSelection;
    end
    else
    begin
      case ActiveChildForm.ChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            if Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
            begin
              FBeforeProc.Assign(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
            end;
          end;

        wctQuickMask:
          begin
            if Assigned(ActiveChildForm.ChannelManager.QuickMaskPanel) then
            begin
              FBeforeProc.Assign(ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
            end;
          end;

        wctLayerMask:
          begin
            FBeforeProc.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            FBeforeProc.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

            if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsMaskLinked then
            begin
              ReplaceAlphaChannelWithMask(FBeforeProc,
                ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
            end;
          end;
      end;
    end;

    // prepare the filling color
    if Assigned(ActiveChildForm.Selection) then
    begin
      case ActiveChildForm.ChannelManager.CurrentChannelType of
        wctAlpha, wctQuickMask:
          begin
            LFillColor := clBlack32;
          end;

        wctLayerMask:
          begin
            LFillColor := clWhite32;
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            LFillColor := $00000000;
          end;
      end;
    end
    else
    begin
      case ActiveChildForm.ChannelManager.CurrentChannelType of
        wctAlpha, wctQuickMask:
          begin
            LFillColor := clBlack32;
          end;

        wctLayerMask:
          begin
            LFillColor := clWhite32;
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfBackground then
            begin
              LFillColor := Color32(FGlobalBackColor);
            end
            else
            if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfTransparent then
            begin
              LFillColor := $00000000;
            end;
          end;
      end;
    end;

    LPluginInfo := FGMPluginInfoList.GetPluginInfoByMenuItem(Sender);

    if ActiveChildForm.ChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue] then
    begin
      if TgmLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel).IsEmptyLayer then
      begin
        MessageDlg('Could not complete the ' + LPluginInfo.PluginName + ' command' + #10#13 +
                   'because the active layer is empty.', mtError, [mbOK], 0);
        Exit;
      end;
    end;

    if LPluginInfo <> nil then
    begin
      if not FileExists(LPluginInfo.LibFileName) then
      begin
        MessageDlg('The filter you called is not exist.', mtError, [mbOK], 0);
        Exit;
      end;

      LGMPlugin := TgmPlugin.Create(LPluginInfo.LibFileName);
      try
        if Assigned(ActiveChildForm.Selection) then
        begin
          P := @ActiveChildForm.Selection.CutOriginal.Bits[0];
          W := ActiveChildForm.Selection.CutOriginal.Width;
          H := ActiveChildForm.Selection.CutOriginal.Height;
        end
        else
        begin
          case ActiveChildForm.ChannelManager.CurrentChannelType of
            wctAlpha:
              begin
                if Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
                begin
                  P := @ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Bits[0];
                  W := ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Width;
                  H := ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Height;
                end;
              end;

            wctQuickMask:
              begin
                if Assigned(ActiveChildForm.ChannelManager.QuickMaskPanel) then
                begin
                  P := @ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.Bits[0];
                  W := ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.Width;
                  H := ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.Height;
                end;
              end;

            wctLayerMask:
              begin
                P := @ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Bits[0];
                W := ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Width;
                H := ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Height;
              end;

            wctRGB, wctRed, wctGreen, wctBlue:
              begin
                P := @ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Bits[0];
                W := ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width;
                H := ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height;
              end;
          end;
        end;

        // setting channels
        if LPluginInfo.IsChannelSupported then
        begin
          LGMPlugin.SetChannels(ActiveChildForm.ChannelManager.ChannelSelectedSet);
        end;

        // if filter runs sucessfully...
        if LGMPlugin.RunPlugin(P, W, H, @UpdateView, LFillColor) then
        begin
          ActiveChildForm.IsImageProcessed := True;
          UpdateView;

          // Undo/Redo
          SetUndoRedoForFilters(LPluginInfo.PluginName);

          // Upgrade the last filter menu item
          mnitmLastFilter.Caption := LPluginInfo.PluginName;
          FLastFilterMenuItem     := Sender as TMenuItem;
        end
        else
        begin
          UpdateView; // The filter runs failed...
        end;

        if Assigned(ActiveChildForm.Selection) then
        begin
          ActiveChildForm.tmrMarchingAnts.Enabled := True;
        end;

        // update thumnails
        ActiveChildForm.UpdateThumbnailsBySelectedChannel;

        if FMainTool = gmtMarquee then
        begin
          if FMarqueeTool = mtMoveResize then
          begin
            if Assigned(ActiveChildForm.Selection) and
               Assigned(ActiveChildForm.SelectionHandleLayer) then
            begin
              ActiveChildForm.SelectionHandleLayer.Visible := True;
            end;
          end;
        end;
        
      finally
        LGMPlugin.Free;
      end;
    end;
  end;
end;

procedure TfrmMain.SetUndoRedoForFilters(const FilterName: string);
var
  LDestBmp, LTempBmp: TBitmap32;
  LCmdAim           : TCommandAim;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  LDestBmp := nil;

  // Set up the process target and filling color.
  if Assigned(ActiveChildForm.Selection) then
  begin
    LDestBmp := ActiveChildForm.Selection.CutOriginal;
  end
  else
  begin
    case ActiveChildForm.ChannelManager.CurrentChannelType of
      wctAlpha:
        begin
          if Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
          begin
            LDestBmp := ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap;
          end;
        end;

      wctQuickMask:
        begin
          if Assigned(ActiveChildForm.ChannelManager.QuickMaskPanel) then
          begin
            LDestBmp := ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap;
          end;
        end;

      wctLayerMask:
        begin
          LDestBmp := ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap;
        end;
        
      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
               lfBackground, lfTransparent] then
          begin
            LDestBmp := ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap;
          end;
        end;
    end;
  end;

  LCmdAim := ActiveChildForm.GetCommandAimByCurrentChannel;

  LTempBmp := TBitmap32.Create;
  try
    LTempBmp.Assign(LDestBmp);

    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsMaskLinked then
    begin
      if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent]) and
         (ActiveChildForm.ChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue]) then
      begin
        ReplaceAlphaChannelWithMask(LTempBmp,
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
      end;
    end;

    LHistoryStatePanel := TgmImageManipulatingStatePanel.Create(
      frmHistory.scrlbxHistory,
      dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
      LCmdAim,
      FilterName,
      FBeforeProc,
      LTempBmp,
      ActiveChildForm.Selection,
      ActiveChildForm.ChannelManager.SelectedAlphaChannelIndex);
  finally
    LTempBmp.Free;
  end;

  ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);
end;

procedure TfrmMain.CreateAutoLevelsUndoRedoCommand;
var
  LCmdAim           : TCommandAim;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  // Set up the process target and filling color.
  if Assigned(ActiveChildForm.Selection) then
  begin
    FAfterProc.Assign(ActiveChildForm.Selection.CutOriginal);
  end
  else
  begin
    case ActiveChildForm.ChannelManager.CurrentChannelType of
      wctAlpha:
        begin
          if Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
          begin
            FAfterProc.Assign(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
          end;
        end;

      wctQuickMask:
        begin
          if Assigned(ActiveChildForm.ChannelManager.QuickMaskPanel) then
          begin
            FAfterProc.Assign(ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
          end;
        end;

      wctLayerMask:
        begin
          FAfterProc.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
        end;
        
      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
               lfBackground, lfTransparent] then
          begin
            FAfterProc.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

            if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsMaskLinked then
            begin
              ReplaceAlphaChannelWithMask(fAfterProc,
                ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
            end;
          end;
        end;
    end;
  end;

  LCmdAim := ActiveChildForm.GetCommandAimByCurrentChannel;

  LHistoryStatePanel := TgmImageManipulatingStatePanel.Create(
    frmHistory.scrlbxHistory,
    dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
    LCmdAim,
    'Auto Levels',
    FBeforeProc,
    FAfterProc,
    ActiveChildForm.Selection,
    ActiveChildForm.ChannelManager.SelectedAlphaChannelIndex);

  ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);
end;

// to create a folder to save the temporary command files
procedure TfrmMain.CreateCommandStorageFolder;
var
  LCmdDir: string;
begin
  LCmdDir := ExtractFileDir(ParamStr(0)) + '\History';

  if not DirectoryExists(LCmdDir) then
  begin
    CreateDir(LCmdDir);
  end;
end;

procedure TfrmMain.ShowStatusInfoOnStatusBar;
var
  LInfo: string;
begin
  case FMainTool of
    gmtStandard:
      begin
        LInfo := StandardToolsGetStatusInfo;
      end;
      
    gmtBrush:
      begin
        LInfo := BrushToolsGetStatusInfo;
      end;

    gmtMarquee:
      begin
        LInfo := MarqueeToolsGetStatusInfo;
      end;
      
    gmtGradient:
      begin
        LInfo := GradientToolsGetStatusInfo;
      end;
      
    gmtCrop:
      begin
        LInfo := '[Crop]';
      end;

    gmtPaintBucket:
      begin
        LInfo := '[Paint Bucket]';
      end;
      
    gmtEraser:
      begin
        LInfo := EraserToolsGetStatusInfo;
      end;
      
    gmtPenTools:
      begin
        LInfo := PenToolsGetStatusInfo;
      end;
      
    gmtMeasure:
      begin
        LInfo := '[Measure]';
      end;
      
    gmtShape:
      begin
        LInfo := ShapeToolsGetStatusInfo;
      end;
      
    gmtTextTool:
      begin
        LInfo := '[Text]';
      end;
      
    gmtEyedropper:
      begin
        LInfo := '[Eyedropper]';
      end;
      
    gmtHandTool:
      begin
        LInfo := '[Hand Tool]';
      end;
  end;
  
  stsbrMain.Panels[1].Text := LInfo;
end;

function TfrmMain.StandardToolsGetStatusInfo: string;
var
  LInfo: string;
begin
  LInfo := '[Standard]';

  case FStandardTool of
    gstPencil:
      begin
        LInfo := LInfo + spdbtnPencil.Hint;
      end;

    gstStraightLine:
      begin
        LInfo := LInfo + spdbtnStraightLine.Hint;
      end;
      
    gstBezierCurve:
      begin
        LInfo := LInfo + spdbtnBezierCurve.Hint;
      end;
      
    gstPolygon:
      begin
        LInfo := LInfo + spdbtnPolygon.Hint;
      end;
      
    gstRegularPolygon:
      begin
        LInfo := LInfo + spdbtnRegularPolygon.Hint;
      end;
      
    gstRectangle:
      begin
        LInfo := LInfo + spdbtnRectangle.Hint;
      end;
      
    gstRoundRectangle:
      begin
        LInfo := LInfo + spdbtnRoundRectangle.Hint;
      end;
      
    gstEllipse:
      begin
        LInfo := LInfo + spdbtnEllipse.Hint;
      end;

    gstMoveObjects:
      begin
        LInfo := LInfo + spdbtnMoveObjects.Hint;
      end;
      
    gstPartiallySelect:
      begin
        LInfo := LInfo + spdbtnRSPartially.Hint;
      end;
      
    gstTotallySelect:
      begin
        LInfo := LInfo + spdbtnRSTotally.Hint;
      end;
  end;

  if FStandardTool in [gstRectangle, gstRoundRectangle, gstEllipse] then
  begin
    LInfo := LInfo + ' -- Hold down the Shift key when drawing to get a regular figure.';
  end
  else
  if FStandardTool = gstMoveObjects then
  begin
    LInfo := LInfo + ' -- When the two control points of a curve are overlapped, right click on them to make your choise.';
  end;
  
  Result := LInfo;
end; 

function TfrmMain.BrushToolsGetStatusInfo: string;
var
  LInfo: string;
begin
  LInfo := '[Brush]';

  if spdbtnPaintBrush.Down then
  begin
    LInfo := LInfo + spdbtnPaintBrush.Hint;
  end
  else if spdbtnHistoryBrush.Down then
  begin
    LInfo := LInfo + spdbtnHistoryBrush.Hint;
  end
  else if spdbtnAirBrush.Down then
  begin
    LInfo := LInfo + spdbtnAirBrush.Hint;
  end
  else if spdbtnJetGun.Down then
  begin
    LInfo := LInfo + spdbtnJetGun.Hint;
  end
  else if spdbtnCloneStamp.Down then
  begin
    LInfo := LInfo + spdbtnCloneStamp.Hint;
  end
  else if spdbtnPatternStamp.Down then
  begin
    LInfo := LInfo + spdbtnPatternStamp.Hint;
  end
  else if spdbtnBlurBrush.Down then
  begin
    LInfo := LInfo + spdbtnBlurBrush.Hint;
  end
  else if spdbtnSharpenBrush.Down then
  begin
    LInfo := LInfo + spdbtnSharpenBrush.Hint;
  end
  else if spdbtnSmudge.Down then
  begin
    LInfo := LInfo + spdbtnSmudge.Hint;
  end
  else if spdbtnDodgeBrush.Down then
  begin
    LInfo := LInfo + spdbtnDodgeBrush.Hint;
  end
  else if spdbtnBurnBrush.Down then
  begin
    LInfo := LInfo + spdbtnBurnBrush.Hint;
  end
  else if spdbtnHighHueBrush.Down then
  begin
    LInfo := LInfo + spdbtnHighHueBrush.Hint;
  end
  else if spdbtnLowHueBrush.Down then
  begin
    LInfo := LInfo + spdbtnLowHueBrush.Hint;
  end
  else if spdbtnHighSaturationBrush.Down then
  begin
    LInfo := LInfo + spdbtnHighSaturationBrush.Hint;
  end
  else if spdbtnLowSaturationBrush.Down then
  begin
    LInfo := LInfo + spdbtnLowSaturationBrush.Hint;
  end
  else if spdbtnHighLuminosityBrush.Down then
  begin
    LInfo := LInfo + spdbtnHighLuminosityBrush.Hint;
  end
  else if spdbtnLowLuminosityBrush.Down then
  begin
    LInfo := LInfo + spdbtnLowLuminosityBrush.Hint;
  end
  else if spdbtnBrightnessBrush.Down then
  begin
    LInfo := LInfo + spdbtnBrightnessBrush.Hint;
  end
  else if spdbtnDarknessBrush.Down then
  begin
    LInfo := LInfo + spdbtnDarknessBrush.Hint;
  end
  else if spdbtnHighContrastBrush.Down then
  begin
    LInfo := LInfo + spdbtnHighContrastBrush.Hint;
  end
  else if spdbtnLowContrastBrush.Down then
  begin
    LInfo := LInfo + spdbtnLowContrastBrush.Hint;
  end;

  Result := LInfo;
end; 

function TfrmMain.MarqueeToolsGetStatusInfo: string;
var
  LInfo: string;
begin
  LInfo := '[Marquee]';

  case FMarqueeTool of
    mtMoveResize:
      begin
        LInfo := LInfo + spdbtnSelect.Hint;
      end;
      
    mtSingleRow:
      begin
        LInfo := LInfo + spdbtnSingleRowMarquee.Hint;
      end;
      
    mtSingleColumn:
      begin
        LInfo := LInfo + spdbtnSingleColumnMarquee.Hint;
      end;
      
    mtRectangular:
      begin
        LInfo := LInfo + spdbtnRectangularMarquee.Hint;
      end;
      
    mtRoundRectangular:
      begin
        LInfo := LInfo + spdbtnRoundRectangularMarquee.Hint;
      end;
      
    mtElliptical:
      begin
        LInfo := LInfo + spdbtnEllipticalMarquee.Hint;
      end;
      
    mtPolygonal:
      begin
        LInfo := LInfo + spdbtnPolygonalMarquee.Hint;
      end;
      
    mtRegularPolygon:
      begin
        LInfo := LInfo + spdbtnRegularPolygonMarquee.Hint;
      end;
      
    mtLasso:
      begin
        LInfo := LInfo + spdbtnLassoMarquee.Hint;
      end;
      
    mtMagicWand:
      begin
        LInfo := LInfo + spdbtnMagicWand.Hint;
      end;
  end;

  if FMarqueeTool in [mtRectangular, mtRoundRectangular, mtElliptical] then
  begin
    LInfo := LInfo + ' -- Hold down the Shift key when drawing to get a regular marquee.';
  end;

  Result := LInfo;
end;

function TfrmMain.GradientToolsGetStatusInfo: string;
var
  LInfo: string;
begin
  LInfo := '[Gradient]';

  case FGradientRenderMode of
    grmLinear:
      begin
        LInfo := LInfo + spdbtnLinearGradient.Hint;
      end;
      
    grmRadial:
      begin
        LInfo := LInfo + spdbtnRadialGradient.Hint;
      end;

    grmAngle:
      begin
        LInfo := LInfo + spdbtnAngleGradient.Hint;
      end;

    grmReflected:
      begin
        LInfo := LInfo + spdbtnReflectedGradient.Hint;
      end;
      
    grmDiamond:
      begin
        LInfo := LInfo + spdbtnDiamondGradient.Hint;
      end;
  end;

  Result := LInfo + ' -- Click the gradient viewer to edit gradient.';
end;

function TfrmMain.EraserToolsGetStatusInfo: string;
var
  LInfo: string;
begin
  LInfo := '[Eraser]';

  case FEraserTool of
    etEraser:
      begin
        LInfo := LInfo + spdbtnEraser.Hint;
      end;

    etBackgroundEraser:
      begin
        LInfo := LInfo + spdbtnBackgroundEraser.Hint;
      end;
      
    etMagicEraser:
      begin
        LInfo := LInfo + spdbtnMagicEraser.Hint;
      end;
  end;

  Result := LInfo;
end; 

function TfrmMain.PenToolsGetStatusInfo: string;
var
  LInfo: string;
begin
  LInfo := '[Pen Tools]';

  case FPenTool of
    ptPathComponentSelection:
      begin
        LInfo := LInfo + spdbtnPathComponentSelectionTool.Hint;
        LInfo := LInfo + '-- Click to select and/or drag a subpath.';
      end;

    ptDirectSelection:
      begin
        LInfo := LInfo + spdbtnDirectSelectionTool.Hint;
        LInfo := LInfo + '-- Click to select and/or drag an anchor point.';
      end;

    ptPenTool:
      begin
        LInfo := LInfo + spdbtnPenTool.Hint;
        LInfo := LInfo + '-- Click to add points to the path. Click on start point to close path.';
      end;

    ptAddAnchorPoint:
      begin
        LInfo := LInfo + spdbtnAddAnchorPointTool.Hint;
        LInfo := LInfo + '-- Click on path to insert anchor points into the path. ';
      end;

    ptDeleteAnchorPoint:
      begin
        LInfo := LInfo + spdbtnDeleteAnchorPointTool.Hint;
        LInfo := LInfo + '-- Click on anchor points to delete from the path. ';
      end;

    ptConvertPoint:
      begin
        LInfo := LInfo + spdbtnConvertPointTool.Hint;
        LInfo := LInfo + '-- Click curve point to change to corner point. Click-drag converts back to curve point.';
      end;
  end;
  
  Result := LInfo;
end; 

function TfrmMain.ShapeToolsGetStatusInfo: string;
var
  LInfo: string;
begin
  LInfo := '[Shape]';

  case FShapeRegionTool of
    srtMove:
      begin
        LInfo := LInfo + spdbtnShapeMove.Hint;
      end;

    srtRectangle:
      begin
        LInfo := LInfo + spdbtnShapeRectangle.Hint;
      end;
      
    srtRoundedRect:
      begin
        LInfo := LInfo + spdbtnShapeRoundRect.Hint;
      end;
      
    srtEllipse:
      begin
        LInfo := LInfo + spdbtnShapeEllipse.Hint;
      end;
      
    srtPolygon:
      begin
        LInfo := LInfo + spdbtnShapeRegularPolygon.Hint;
      end;
      
    srtLine:
      begin
        LInfo := LInfo + spdbtnShapeLine.Hint;
      end;
  end;

  if FShapeRegionTool in [srtRectangle, srtRoundedRect, srtEllipse] then
  begin
    LInfo := LInfo + ' -- Hold down the Shift key when drawing to get a regular shape.';
  end;

  Result := LInfo;
end;

// adding system supported fonts to a list
function EnumFontsProc(var ALogFont: TLogFont; var ATextMetric: TTextMetric;
  AFontType: Integer; AData: Pointer): Integer; stdcall;
begin
  TStrings(AData).Add(ALogFont.lfFaceName);
  Result := 1;
end;

// Get system supported fonts.
procedure TfrmMain.GetFontNames(const AItems: TStrings);
var
  DC: HDC;
begin
  DC := GetDC(0);
  
  EnumFonts( DC, nil, @EnumFontsProc, Pointer(AItems) );
  ReleaseDC(0, DC);
end; 

procedure TfrmMain.ShowColorRGBInfoOnInfoViewer(const AColor: TColor);
begin
  with frmInfo do
  begin
    lblRed.Caption   := 'R: '   + IntToStr( GetRValue(AColor) );
    lblGreen.Caption := 'G: '   + IntToStr( GetGValue(AColor) );
    lblBlue.Caption  := 'B: '   + IntToStr( GetBValue(AColor) );
    lblHex.Caption   := 'Hex: ' + ColorToString(AColor);
  end;
end;

procedure TfrmMain.ShowColorCMYKInfoOnInfoViewer(const AColor: TColor);
var
  c, m, y, k: Integer;
  RGBTriple : TRGBTriple;
begin
  with RGBTriple do
  begin
    rgbtRed   := GetRValue(AColor);
    rgbtGreen := GetGValue(AColor);
    rgbtBlue  := GetBValue(AColor);
  end;

  RGBTripleToCMYK(RGBTriple, c, m, y, k);

  with frmInfo do
  begin
    lblCyan.Caption    := 'C: ' + IntToStr(c);
    lblMagenta.Caption := 'M: ' + IntToStr(m);
    lblYellow.Caption  := 'Y: ' + IntToStr(y);
    lblBlack.Caption   := 'K: ' + IntToStr(k);
  end;
end;

procedure TfrmMain.ShowOriginalCoordInfoOnInfoViewerInPixel(const X, Y: Integer);
begin
  frmInfo.lblOriginalX.Caption := 'X: ' + IntToStr(X);
  frmInfo.lblOriginalY.Caption := 'Y: ' + IntToStr(Y);
end;

procedure TfrmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(const X, Y: Integer);
begin
  frmInfo.lblCurrentX.Caption := 'X: ' + IntToStr(X);
  frmInfo.lblCurrentY.Caption := 'Y: ' + IntToStr(Y);
end;

// Update components of standard page.
procedure TfrmMain.UpdateStandardOptions;
var
  LAvailable: Boolean;
begin
  case FStandardTool of
    gstRegularPolygon:
      begin
        lblRadiusSides.Caption    := 'Sides:';
        lblRadiusSides.Hint       := 'Set number of sides';
        edtRadiusSides.Hint       := 'Set number of sides';
        updwnRadiusSides.Hint     := 'Set number of sides';
        updwnRadiusSides.Min      := 3;
        updwnRadiusSides.Max      := 100;
        updwnRadiusSides.Position := FStandardPolygonSides;
      end;

    gstRoundRectangle:
      begin
        lblRadiusSides.Caption    := 'Radius:';
        lblRadiusSides.Hint       := 'Set radius of rounded corners';
        edtRadiusSides.Hint       := 'Set radius of rounded corners';
        updwnRadiusSides.Hint     := 'Set radius of rounded corners';
        updwnRadiusSides.Min      := 0;
        updwnRadiusSides.Max      := 1000;
        updwnRadiusSides.Position := FStandardCornerRadius;
      end;
  end;

  LAvailable             := FStandardTool in [gstRegularPolygon, gstRoundRectangle];
  lblRadiusSides.Enabled := LAvailable;
  edtRadiusSides.Enabled := LAvailable;

  if LAvailable then
  begin
    edtRadiusSides.Color := clWindow;
  end
  else
  begin
    edtRadiusSides.Color := clBtnFace;
  end;
  
  updwnRadiusSides.Enabled  := LAvailable;

  if ActiveChildForm <> nil then
  begin
    LAvailable                     := ActiveChildForm.LayerPanelList.HasFiguresOnFigureLayer;
    spdbtnSelectFigures.Enabled    := LAvailable;
    spdbtnFigureProperties.Enabled := ( High(ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray) = 0 ) and (FStandardTool = gstMoveObjects);
    spdbtnSelectAllFigures.Enabled := LAvailable;
    spdbtnDeleteFigures.Enabled    := ( High(ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray) > (-1) ) and (FStandardTool = gstMoveObjects);
    spdbtnLockFigures.Enabled      := ActiveChildForm.LayerPanelList.HasUnlockedFiguresOnSelectedFigureLayer and (FStandardTool = gstMoveObjects);
    spdbtnUnlockFigures.Enabled    := ActiveChildForm.LayerPanelList.HasLockedFiguresOnSelectedFigureLayer and (FStandardTool = gstMoveObjects);
  end
  else
  begin
    spdbtnSelectFigures.Enabled    := False;
    spdbtnFigureProperties.Enabled := False;
    spdbtnSelectAllFigures.Enabled := False;
    spdbtnDeleteFigures.Enabled    := False;
    spdbtnLockFigures.Enabled      := False;
    spdbtnUnlockFigures.Enabled    := False;
  end;
end;

// Update components of brush page.
procedure TfrmMain.UpdateBrushOptions;

  procedure UpdateMode;
  begin
    if FBrushTool in [btPaintBrush, btHistoryBrush, btAirBrush,
                      btJetGunBrush, btCloneStamp, btPatternStamp,
                      btBlurSharpenBrush, btSmudge] then
    begin
      lblBrushMode.Caption     := 'Mode:';
      cmbbxBrushMode.Hint      := 'Set blend mode for stroke';
      cmbbxBrushMode.Clear;
      cmbbxBrushMode.Items     := BlendModeList;
      cmbbxBrushMode.ItemIndex := Ord(FBrushBlendMode);
    end
    else
    if FBrushTool = btDodgeBurnBrush then
    begin
      lblBrushMode.Caption     := 'Range:';
      cmbbxBrushMode.Hint      := 'Set dodge/burn range for stroke';
      cmbbxBrushMode.Clear;
      cmbbxBrushMode.Items     := DodgeBurnRangeList;
      cmbbxBrushMode.ItemIndex := Ord(FDodgeBurnMode);
    end;
  end;

  // The OPEI represents Opacity, Pressure, Exposure and Intensity.
  procedure UpdateBrushOPEI;
  begin
    if FBrushTool in [btPaintBrush, btHistoryBrush, btCloneStamp,
                      btPatternStamp] then
    begin
      lblBrushOPEI.Caption     := 'Opacity:';
      edtBrushOPEI.Hint        := 'Set opacity for stroke';
      updwnBrushOPEI.Position  := FBrushOpacity;
    end
    else
    if FBrushTool = btAirBrush then
    begin
      lblBrushOPEI.Caption     := 'Pressure:';
      edtBrushOPEI.Hint        := 'Set pressure for stroke';
      updwnBrushOPEI.Position  := FAirPressure;
    end
    else
    if FBrushTool = btBlurSharpenBrush then
    begin
      lblBrushOPEI.Caption     := 'Pressure:';
      edtBrushOPEI.Hint        := 'Set pressure for stroke';
      updwnBrushOPEI.Position  := FBlurSharpenPressure;
    end
    else
    if FBrushTool = btJetGunBrush then
    begin
      lblBrushOPEI.Caption     := 'Pressure:';
      edtBrushOPEI.Hint        := 'Set pressure for stroke';
      updwnBrushOPEI.Position  := FJetGunPressure;
    end
    else
    if FBrushTool = btSmudge then
    begin
      lblBrushOPEI.Caption     := 'Pressure:';
      edtBrushOPEI.Hint        := 'Set pressure for stroke';
      updwnBrushOPEI.Position  := FSmudgePressure;
    end
    else
    if FBrushTool = btDodgeBurnBrush then
    begin
      lblBrushOPEI.Caption     := 'Exposure:';
      edtBrushOPEI.Hint        := 'Set exposure for stroke';
      updwnBrushOPEI.Position  := FDodgeBurnExposure;
    end
    else
    if FBrushTool = btLightBrush then
    begin
      lblBrushOPEI.Caption     := 'Intensity:';
      edtBrushOPEI.Hint        := 'Set intensity for stroke';
      updwnBrushOPEI.Position  := FBrushIntensity;
    end;

    updwnBrushOPEI.Hint := edtBrushOPEI.Hint;
  end;

var
  LAvailable: Boolean;
begin
  UpdateMode;
  UpdateBrushOPEI;
  spdbtnSelectPaintingBrush.Enabled := (FBrushTool <> btJetGunBrush);

  cmbbxBrushMode.Enabled := (FBrushTool in [btPaintBrush,
                                            btHistoryBrush,
                                            btAirBrush,
                                            btJetGunBrush,
                                            btCloneStamp,
                                            btPatternStamp,
                                            btBlurSharpenBrush,
                                            btSmudge,
                                            btDodgeBurnBrush]);

  lblBrushMode.Enabled   := cmbbxBrushMode.Enabled;
  LAvailable             := (FBrushTool = btJetGunBrush);
  edtBrushRadius.Enabled := LAvailable;

  if LAvailable then
  begin
    edtBrushRadius.Color := clWindow;
  end
  else
  begin
    edtBrushRadius.Color := clBtnFace;
  end;
  
  lblBrushRadius.Enabled                 := LAvailable;
  updwnBrushRadius.Enabled               := LAvailable;
  updwnBrushInterval.Enabled             := (FBrushTool <> btSmudge);
  edtBrushInterval.Enabled               := updwnBrushInterval.Enabled;
  lblBrushInterval.Enabled               := updwnBrushInterval.Enabled;
  chckbxColorAndSample.Visible           := (FBrushTool in [btCloneStamp, btJetGunBrush]);
  spdbtnBrushOpenPatternSelector.Enabled := (FBrushTool = btPatternStamp);

  if FBrushTool = btJetGunBrush then
  begin
    updwnBrushInterval.Position := FJetGun.Interval;
  end
  else if FBrushTool = btAirBrush then
  begin
    updwnBrushInterval.Position := FAirBrush.Interval;
  end
  else if FBrushTool = btBlurSharpenBrush then
  begin
    updwnBrushInterval.Position := FBlurSharpenTimerInterval;
  end
  else
  begin
    updwnBrushInterval.Position := FBrushInterval;
  end;

  if FBrushTool = btJetGunBrush then
  begin
    chckbxColorAndSample.Caption := 'Get Random Color';
    chckbxColorAndSample.Checked := FIsRandomColor;
  end
  else
  if FBrushTool = btCloneStamp then
  begin
    chckbxColorAndSample.Caption := 'Use All Layers';
    chckbxColorAndSample.Checked := FIsUseAllLayers;
  end;
end; 

// Update components of marquee page.
procedure TfrmMain.UpdateMarqueeOptions;
var
  LHintStr  : string;
  LAvailable: Boolean;
begin
  case FMarqueeTool of
    mtMagicWand:
      begin
        LHintStr                     := 'Set range when sampling color';
        lblToleranceSides.Caption    := 'Tolerance:';
        updwnToleranceSides.Min      := 0;
        updwnToleranceSides.Max      := 100;
        updwnToleranceSides.Position := FMagicWandTolerance;
      end;

    mtRegularPolygon:
      begin
        LHintStr                     := 'Set number of sides';
        lblToleranceSides.Caption    := 'Sides:';
        updwnToleranceSides.Min      := 3;
        updwnToleranceSides.Max      := 100;
        updwnToleranceSides.Position := FRPMSides;
      end;

    mtRoundRectangular:
      begin
        LHintStr                     := 'Set radius of rounded corners';
        lblToleranceSides.Caption    := 'Radius:';
        updwnToleranceSides.Min      := 0;
        updwnToleranceSides.Max      := 1000;
        updwnToleranceSides.Position := FRRMCornerRadius;
      end;
  end;

  lblToleranceSides.Hint   := LHintStr;
  edtToleranceSides.Hint   := LHintStr;
  updwnToleranceSides.Hint := LHintStr;

  if ActiveChildForm <> nil then
  begin
    spdbtnCommitSelection.Enabled := (ActiveChildForm.Selection <> nil);
    spdbtnDeselect.Enabled        := (ActiveChildForm.Selection <> nil);
    spdbtnDeleteSelection.Enabled := (ActiveChildForm.Selection <> nil);
  end
  else
  begin
    spdbtnCommitSelection.Enabled := False;
    spdbtnDeselect.Enabled        := False;
    spdbtnDeleteSelection.Enabled := False;
  end;

  LAvailable := (FMarqueeTool in [mtMagicWand, mtRegularPolygon, mtRoundRectangular]);

  lblToleranceSides.Enabled := LAvailable;
  edtToleranceSides.Enabled := LAvailable;

  if LAvailable then
  begin
    edtToleranceSides.Color := clWindow;
  end
  else
  begin
    edtToleranceSides.Color := clBtnFace;
  end;

  updwnToleranceSides.Enabled            := LAvailable;
  chckbxUseAllLayers.Enabled             := (FMarqueeTool in [mtMagicWand, mtMagneticLasso]);
  chckbxMagneticLassoInteractive.Enabled := (FMarqueeTool = mtMagneticLasso);
end; 

// Update components of crop page.
procedure TfrmMain.UpdateCropOptions;
var
  LCropCreated: Boolean;
begin
  LCropCreated := (ActiveChildForm <> nil) and (ActiveChildForm.Crop <> nil);

  lblCroppedShieldColor.Enabled       := LCropCreated;
  shpCroppedShieldColor.Enabled       := LCropCreated;
  lblCroppedShieldOpacity.Enabled     := LCropCreated;
  lblShieldOpacityPercentSign.Enabled := LCropCreated;
  edtCroppedShieldOpacity.Enabled     := LCropCreated;
  updwnCroppedShieldOpacity.Enabled   := LCropCreated;
  chckbxShieldCroppedArea.Enabled     := LCropCreated;
  chckbxResizeCrop.Enabled            := LCropCreated;
  lblCropWidth.Enabled                := LCropCreated;
  lblCropHeight.Enabled               := LCropCreated;
  edtCropWidth.Enabled                := LCropCreated;
  edtCropHeight.Enabled               := LCropCreated;
  btnCommitCrop.Enabled               := LCropCreated;
  btnCancelCrop.Enabled               := LCropCreated;

  if LCropCreated then
  begin
    edtCropWidth.Color  := clWindow;
    edtCropHeight.Color := clWindow;
  end
  else
  begin
    edtCropWidth.Color  := clBtnFace;
    edtCropHeight.Color := clBtnFace;
  end;

  // display the crop shield group
  if LCropCreated and chckbxShieldCroppedArea.Checked then
  begin
    pnlCropShield.Top     := pnlCropOptions.Top + pnlCropOptions.Height;
    pnlCropShield.Visible := True;
  end
  else
  begin
    pnlCropShield.Visible := False;
  end;

  // display the resize crop group
  if LCropCreated and chckbxResizeCrop.Checked then
  begin
    if pnlCropShield.Visible then
    begin
      pnlResizeCrop.Top := pnlCropShield.Top + pnlCropShield.Height;
    end
    else
    begin
      pnlResizeCrop.Top := pnlCropOptions.Top + pnlCropOptions.Height;
    end;

    pnlResizeCrop.Visible := True;
  end
  else
  begin
    pnlResizeCrop.Visible := False;
  end;
end; 

// Update components of paint bucket page.
procedure TfrmMain.UpdatePaintBucketOptions;
var
  LEnabled: Boolean;
begin
  LEnabled                         := (FPaintBucketFillSource = pbfsPattern);
  lblPaintBucketPattern.Enabled    := LEnabled;
  pnlFillPatternHolder.Enabled     := LEnabled;
  imgPatternForPaintBucket.Enabled := LEnabled;
  spdbtnOpenPatternForFill.Enabled := LEnabled;
end;

// Update components of eraser page.
procedure TfrmMain.UpdateEraserOptions;
begin
  case FEraserTool of
    etEraser:
      begin
        lblEraserModeLimit.Caption     := 'Mode:';
        lblEraserModeLimit.Hint        := 'Erasing Mode';
        cmbbxEraserModeLimit.Items     := ErasingModeList;
        cmbbxEraserModeLimit.ItemIndex := GetErasingModeIndex(FErasingMode);
        cmbbxEraserModeLimit.Hint      := 'Erasing Mode';

        case FErasingMode of
          emPaintBrush:
            begin
              lblEraserOpacityPressure.Caption    := 'Opacity:';
              lblEraserOpacityPressure.Hint       := 'Set eraser opacity';
              edtEraserOpacityPressure.Hint       := 'Set eraser opacity';
              updwnEraserOpacityPressure.Hint     := 'Set eraser opacity';
              updwnEraserOpacityPressure.Position := FErasingOpacity;
              updwnEraserInterval.Position        := FErasingInterval;
            end;

          emAirBrush:
            begin
              lblEraserOpacityPressure.Caption    := 'Pressure:';
              lblEraserOpacityPressure.Hint       := 'Set eraser pressure';
              edtEraserOpacityPressure.Hint       := 'Set eraser pressure';
              updwnEraserOpacityPressure.Hint     := 'Set eraser pressure';
              updwnEraserOpacityPressure.Position := FAirErasingPressure;
              updwnEraserInterval.Position        := FAirErasingInterval;
            end;
        end;
      end;

    etBackgroundEraser:
      begin
        lblEraserModeLimit.Caption     := 'Limit:';
        lblEraserModeLimit.Hint        := 'How far to let the erasing spread';
        cmbbxEraserModeLimit.Items     := ErasingLimitList;
        cmbbxEraserModeLimit.ItemIndex := GetErasingLimitIndex(FBackgroundEraserLimit);
        cmbbxEraserModeLimit.Hint      := 'How far to let the erasing spread';

        case FBackgroundEraserLimit of
          belDiscontiguous:
            begin
              updwnEraserInterval.Position := FAirErasingInterval;
            end;
            
          belContiguous:
            begin
              updwnEraserInterval.Position := FErasingInterval;
            end;
        end;
      end;

    etMagicEraser:
      begin
        lblEraserOpacityPressure.Caption    := 'Opacity:';
        lblEraserOpacityPressure.Hint       := 'Set eraser opacity';
        edtEraserOpacityPressure.Hint       := 'Set eraser opacity';
        updwnEraserOpacityPressure.Hint     := 'Set eraser opacity';
        updwnEraserOpacityPressure.Position := FErasingOpacity;
      end;
  end;

  lblEraserPaintBrush.Enabled      := FEraserTool <> etMagicEraser;
  pnlEraserBrushHolder.Enabled     := lblEraserPaintBrush.Enabled;
  imgEraserPaintingBrush.Enabled   := lblEraserPaintBrush.Enabled;
  spdbtnSelectEraserStroke.Enabled := lblEraserPaintBrush.Enabled;

  lblEraserModeLimit.Enabled   := lblEraserPaintBrush.Enabled;
  cmbbxEraserModeLimit.Enabled := lblEraserPaintBrush.Enabled;

  if cmbbxEraserModeLimit.Enabled then
  begin
    cmbbxEraserModeLimit.Color := clWindow;
  end
  else
  begin
    cmbbxEraserModeLimit.Color := clBtnFace;
  end;

  lblEraserSampling.Enabled   := (FEraserTool = etBackgroundEraser);
  cmbbxEraserSampling.Enabled := lblEraserSampling.Enabled;

  if cmbbxEraserSampling.Enabled then
  begin
    cmbbxEraserSampling.Color := clWindow;
  end
  else
  begin
    cmbbxEraserSampling.Color := clBtnFace;
  end;

  lblEraserOpacityPressure.Enabled    := (FEraserTool <> etBackgroundEraser);
  lblEraserOpacityPercentSign.Enabled := lblEraserOpacityPressure.Enabled;
  updwnEraserOpacityPressure.Enabled  := lblEraserOpacityPressure.Enabled;
  edtEraserOpacityPressure.Enabled    := lblEraserOpacityPressure.Enabled;

  if edtEraserOpacityPressure.Enabled then
  begin
    edtEraserOpacityPressure.Color := clWindow;
  end
  else
  begin
    edtEraserOpacityPressure.Color := clBtnFace;
  end;

  lblEraserInterval.Enabled   := lblEraserPaintBrush.Enabled;
  updwnEraserInterval.Enabled := lblEraserPaintBrush.Enabled;
  edtEraserInterval.Enabled   := lblEraserPaintBrush.Enabled;

  if edtEraserInterval.Enabled then
  begin
    edtEraserInterval.Color := clWindow;
  end
  else
  begin
    edtEraserInterval.Color := clBtnFace;
  end;

  lblEraserTolerance.Enabled            := (FEraserTool <> etEraser);
  lblEraserTolerancePercentSign.Enabled := lblEraserTolerance.Enabled;
  edtEraserTolerance.Enabled            := lblEraserTolerance.Enabled;
  updwnEraserTolerance.Enabled          := lblEraserTolerance.Enabled;

  if edtEraserTolerance.Enabled then
  begin
    edtEraserTolerance.Color := clWindow;
  end
  else
  begin
    edtEraserTolerance.Color := clBtnFace;
  end;

  spdbtnEraserDynamics.Enabled := lblEraserInterval.Enabled;
end; 

// Update components of measure page.
procedure TfrmMain.UpdateMeasureOptions;

  procedure ClearMeasureInfo;
  const
    FLOAT_DIMENSION: Extended = 0.00;
    ANGLE          : Extended = 0.0;
  var
    LMeasureUnit: TgmMeasureUnit;
  begin
    LMeasureUnit := TgmMeasureUnit(cmbbxMeasureUnit.ItemIndex);

    case LMeasureUnit of
      muPixel:
        begin
          lblMStartXValue.Caption := IntToStr(0);
          lblMStartYValue.Caption := IntToStr(0);
          lblMWidthValue.Caption  := IntToStr(0);
          lblMHeightValue.Caption := IntToStr(0);
          lblMAngleValue.Caption  := Format('%.1f', [Angle]);
          lblMD1Value.Caption     := IntToStr(0);
          lblMD2Value.Caption     := IntToStr(0);
        end;

      muInch, muCM:
        begin
          lblMStartXValue.Caption := Format('%.2f', [FLOAT_DIMENSION]);
          lblMStartYValue.Caption := Format('%.2f', [FLOAT_DIMENSION]);
          lblMWidthValue.Caption  := Format('%.2f', [FLOAT_DIMENSION]);
          lblMHeightValue.Caption := Format('%.2f', [FLOAT_DIMENSION]);
          lblMAngleValue.Caption  := Format('%.1f', [ANGLE]);
          lblMD1Value.Caption     := Format('%.2f', [FLOAT_DIMENSION]);
          lblMD2Value.Caption     := Format('%.2f', [FLOAT_DIMENSION]);
        end;
    end;
    
    lblMeasureUnit.Enabled      := False;
    cmbbxMeasureUnit.Enabled    := False;
    cmbbxMeasureUnit.Color      := clBtnFace;
    btnClearMeasureInfo.Enabled := False;
  end;

begin
  if ActiveChildForm <> nil then
  begin
    if Assigned(ActiveChildForm.MeasureLine) then
    begin
      ActiveChildForm.ShowMeasureResult;
      lblMeasureUnit.Enabled      := True;
      cmbbxMeasureUnit.Enabled    := True;
      cmbbxMeasureUnit.Color      := clWindow;
      btnClearMeasureInfo.Enabled := True;
    end
    else
    begin
      ClearMeasureInfo;
    end;
  end
  else
  begin
    ClearMeasureInfo;
  end;
end; 

// Update componets of shape page.
procedure TfrmMain.UpdateShapeOptions;
var
  LAvailable: Boolean;
begin
  case FShapeRegionTool of
    srtRoundedRect:
      begin
        lblShapeToolRSW.Caption    := 'Radius:';
        lblShapeToolRSW.Hint       := 'Set radius of rounded corners';
        edtShapeToolRSW.Hint       := 'Set radius of rounded corners';
        updwnShapeToolRSW.Hint     := 'Set radius of rounded corners';
        updwnShapeToolRSW.Min      := 0;
        updwnShapeToolRSW.Max      := 1000;
        updwnShapeToolRSW.Position := FShapeCornerRadius;
      end;

    srtPolygon:
      begin
        lblShapeToolRSW.Caption    := 'Sides:';
        lblShapeToolRSW.Hint       := 'Set number of sides';
        edtShapeToolRSW.Hint       := 'Set number of sides';
        updwnShapeToolRSW.Hint     := 'Set number of sides';
        updwnShapeToolRSW.Min      := 3;
        updwnShapeToolRSW.Max      := 100;
        updwnShapeToolRSW.Position := FShapePolygonSides;
      end;

    srtLine:
      begin
        lblShapeToolRSW.Caption    := 'Weight:';
        lblShapeToolRSW.Hint       := 'Set line weight';
        edtShapeToolRSW.Hint       := 'Set line weight';
        updwnShapeToolRSW.Hint     := 'Set line weight';
        updwnShapeToolRSW.Min      := 1;
        updwnShapeToolRSW.Max      := 1000;
        updwnShapeToolRSW.Position := FLineWeight;
      end;
  end;

  LAvailable := FShapeRegionTool in [srtRoundedRect, srtPolygon, srtLine];

  lblShapeToolRSW.Enabled   := LAvailable;
  updwnShapeToolRSW.Enabled := LAvailable;
  edtShapeToolRSW.Enabled   := LAvailable;

  if edtShapeToolRSW.Enabled then
  begin
    edtShapeToolRSW.Color := clWindow;
  end
  else
  begin
    edtShapeToolRSW.Color := clBtnFace;
  end;
  
  if Assigned(ActiveChildForm) then
  begin
    if Assigned(ActiveChildForm.LayerPanelList.SelectedLayerPanel) then
    begin
      if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature <> lfShapeRegion then
      begin
        spdbtnDismissTargetPath.Enabled := False;
      end
      else
      begin
        spdbtnDismissTargetPath.Enabled := not TgmShapeRegionLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel).IsDismissed;
      end;
    end
    else
    begin
      spdbtnDismissTargetPath.Enabled := False;
    end;
  end
  else
  begin
    spdbtnDismissTargetPath.Enabled := False;
  end;
end;

// Update componets of text page.
procedure TfrmMain.UpdateTextOptions;
var
  LEnabled: Boolean;
begin
  LEnabled := frmRichTextEditor.Visible;

  lblFontFamily.Enabled   := LEnabled;
  cmbbxFontFamily.Enabled := LEnabled;

  if cmbbxFontFamily.Enabled then
  begin
    cmbbxFontFamily.Color := clWindow;
  end
  else
  begin
    cmbbxFontFamily.Color := clBtnFace;
  end;

  lblFontColor.Enabled  := LEnabled;
  shpFontColor.Enabled  := LEnabled;
  lblFontSize.Enabled   := LEnabled;
  cmbbxFontSize.Enabled := LEnabled;

  if cmbbxFontSize.Enabled then
  begin
    cmbbxFontSize.Color := clWindow;
  end
  else
  begin
    cmbbxFontSize.Color := clBtnFace;
  end;

  spdbtnLeftAlignText.Enabled     := LEnabled;
  spdbtnCenterText.Enabled        := LEnabled;
  spdbtnRightAlignText.Enabled    := LEnabled;
  tlbtnBold.Enabled               := LEnabled;
  tlbtnItalic.Enabled             := LEnabled;
  tlbtnUnderline.Enabled          := LEnabled;
  spdbtnSelectAllRichText.Enabled := LEnabled;
  spdbtnClearRichText.Enabled     := LEnabled;
  spdbtnCommitEdits.Enabled       := LEnabled;
  spdbtnCancelEdits.Enabled       := LEnabled;
  spdbtnOpenRichText.Enabled      := LEnabled;
  spdbtnSaveRichText.Enabled      := LEnabled;
  spdbtnSaveRichTextAs.Enabled    := LEnabled;

  if LEnabled then
  begin
    ChangeIndexByFontName(frmRichTextEditor.rchedtRichTextEditor.SelAttributes.Name);
    ChangeIndexByFontSize(frmRichTextEditor.rchedtRichTextEditor.SelAttributes.Size);

    shpFontColor.Brush.Color   := frmRichTextEditor.rchedtRichTextEditor.SelAttributes.Color;
    tlbtnBold.Down             := (fsBold in frmRichTextEditor.rchedtRichTextEditor.SelAttributes.Style);
    tlbtnItalic.Down           := (fsItalic in frmRichTextEditor.rchedtRichTextEditor.SelAttributes.Style);
    tlbtnUnderline.Down        := (fsUnderline in frmRichTextEditor.rchedtRichTextEditor.SelAttributes.Style);
    spdbtnLeftAlignText.Down   := (frmRichTextEditor.rchedtRichTextEditor.Paragraph.Alignment = taLeftJustify);
    spdbtnCenterText.Down      := (frmRichTextEditor.rchedtRichTextEditor.Paragraph.Alignment = taCenter);
    spdbtnRightAlignText.Down  := (frmRichTextEditor.rchedtRichTextEditor.Paragraph.Alignment = taRightJustify);
  end;
end;

procedure TfrmMain.UpdateToolsOptions;
begin
  case FMainTool of
    gmtStandard:
      begin
        UpdateStandardOptions;
      end;
      
    gmtBrush:
      begin
        UpdateBrushOptions;
      end;
      
    gmtMarquee:
      begin
        UpdateMarqueeOptions;
      end;
      
    gmtCrop:
      begin
        UpdateCropOptions;
      end;
      
    gmtMeasure:
      begin
        UpdateMeasureOptions;
      end;
      
    gmtPaintBucket:
      begin
        UpdatePaintBucketOptions;
      end;
      
    gmtEraser:
      begin
        UpdateEraserOptions;
      end;
      
    gmtShape:
      begin
        UpdateShapeOptions;
      end;
      
    gmtTextTool:
      begin
        UpdateTextOptions;
      end;
  end;

  if ActiveChildForm <> nil then
  begin
    spdbtnZoomOut.Enabled  := True;
    spdbtnZoomIn.Enabled   := True;
    ggbrZoomSlider.Enabled := True;
  end
  else
  begin
    spdbtnZoomOut.Enabled  := False;
    spdbtnZoomIn.Enabled   := False;
    ggbrZoomSlider.Enabled := False;
  end;
end;

// creating child form and open image within it
function TfrmMain.OpenImageInChildForm(const AFileName: string): Boolean;
var
  LOpenedBmp    : TBitmap32;
  LNewLayer     : TBitmapLayer;
  LRect         : TRect;
  LTopLeft      : TPoint;
  LLayerPanel   : TgmLayerPanel;
  LSnapshotPanel: TgmSnapshotPanel;
begin
  Result := False;

  if AFileName <> '' then
  begin
    if FileExists(AFileName) then
    begin
      if LowerCase(ExtractFileExt(AFileName)) = '.gmd' then
      begin
        Result := LoadGMDInChildForm(AFileName);
      end
      else
      begin
        // first, check if we could open the image
        LOpenedBmp := LoadGraphicsFile(AFileName);

        if not Assigned(LOpenedBmp) then
        begin
          MessageDlg('Cannot load picture ''' + ExtractFileName(AFileName) + '''',
                     mtError, [mbOK], 0);
        end
        else
        begin
          // if there is an active child form, hide all layer panels of it
          if ActiveChildForm <> nil then
          begin
            if ActiveChildForm.LayerPanelList.Count > 0 then
            begin
              ActiveChildForm.LayerPanelList.HideAllLayerPanels;
            end;

            if ActiveChildForm.PathPanelList.Count > 0 then
            begin
              ActiveChildForm.PathPanelList.HideAllPathPanels;
            end;

            ActiveChildForm.HistoryManager.HideAllPanels;
            ActiveChildForm.ChannelManager.HideAllChannelPanels;
          end;

          FChildFormIsCreating := True;
          try
            ActiveChildForm := TfrmChild.Create(Self);
          finally
            FChildFormIsCreating := False;
          end;

          // determine whether or not refresh these pannels
          ActiveChildForm.LayerPanelList.IsAllowRefreshLayerPanels   := frmLayer.IsShowingUp;
          ActiveChildForm.ChannelManager.IsAllowRefreshChannelPanels := frmChannel.IsShowingUp;
          ActiveChildForm.PathPanelList.IsAllowRefreshPathPanels     := frmPath.IsShowingUp;
          ActiveChildForm.HistoryManager.IsAllowRefreshPanels        := frmHistory.IsShowingUp;

          ActiveChildForm.FileName := AFileName;

          ActiveChildForm.HistoryBitmap.Assign(LOpenedBmp);
          ActiveChildForm.HistoryBitmap.DrawMode := dmBlend;
          FreeAndNil(LOpenedBmp);

          ActiveChildForm.imgDrawingArea.Bitmap.SetSize(
            ActiveChildForm.HistoryBitmap.Width, ActiveChildForm.HistoryBitmap.Height);

          // create image layer
          LNewLayer := TBitmapLayer.Create(ActiveChildForm.imgDrawingArea.Layers);
          LNewLayer.Bitmap.Assign(ActiveChildForm.HistoryBitmap);

          // get location of the bitmap in the TImage32
          LRect := ActiveChildForm.imgDrawingArea.GetBitmapRect;

          { Convert the top-left point of the background bitmap of the TImage32
            from control coordinate to bitmap coordinate. }
          LTopLeft := ActiveChildForm.imgDrawingArea.ControlToBitmap( Point(LRect.Left, LRect.Top) );

          LNewLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                          ActiveChildForm.imgDrawingArea.Bitmap.Width,
                                          ActiveChildForm.imgDrawingArea.Bitmap.Height);

          LNewLayer.Scaled := True;
          LNewLayer.Bitmap.Changed;

          ActiveChildForm.FLayerTopLeft := Point(LTopLeft.X, LTopLeft.Y);

          // create layer panel
          LLayerPanel := TgmBackgroundLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer);
          frmLayer.cmbbxLayerBlendMode.ItemIndex := LLayerPanel.BlendModeIndex;

          ActiveChildForm.LayerPanelList.AddLayerPanelToList(LLayerPanel);
          ActiveChildForm.FLayerTopLeft := ActiveChildForm.GetLayerTopLeft;

          // create Snapshot for history command
          LSnapshotPanel := TgmSnapshotPanel.Create(frmHistory.scrlbxHistory,
                                                    ActiveChildForm.HistoryBitmap,
                                                    ExtractFileName(AFileName));

          ActiveChildForm.HistoryManager.AddSnapshot(LSnapshotPanel);
          frmHistory.scrlbxHistory.VertScrollBar.Position := frmHistory.scrlbxHistory.VertScrollBar.Range;

          // create preview layer of channel manager for this child form
          ActiveChildForm.ChannelManager.CreateChannelPreviewLayer(
            ActiveChildForm.imgDrawingArea.Layers, ActiveChildForm.LayerPanelList,
            LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height, LNewLayer.Location);

          // associate the new layer panel to the channel mannager
          ActiveChildForm.ChannelManager.AssociateToLayerPanel(
            ActiveChildForm.LayerPanelList.SelectedLayerPanel);

          if ActiveChildForm.WindowState = wsNormal then
          begin
            { Make the size of the window same as the size of the layer, but we
              think that this is not a good method for this purpose. If we could
              find a better way for this, we will rewrite the following code. }

            ActiveChildForm.Width                 := LNewLayer.Bitmap.Width  + 26;
            ActiveChildForm.Height                := LNewLayer.Bitmap.Height + 54;
            ActiveChildForm.imgDrawingArea.Width  := ActiveChildForm.imgDrawingArea.Bitmap.Width;
            ActiveChildForm.imgDrawingArea.Height := ActiveChildForm.imgDrawingArea.Bitmap.Height;
          end;

          stsbrMain.Panels[0].Text := GetBitmapDimensionString(ActiveChildForm.HistoryBitmap);
          ActiveChildForm.RefreshCaption;
          ActiveChildForm.SetupOnChildFormActivate;

          Result := True;
        end;
      end;
    end
    else
    begin
      MessageDlg('The file is not existed.', mtError, [mbOK], 0);
    end;
  end;
end;

// creating child form and load '*.gmd' file
function TfrmMain.LoadGMDInChildForm(const AFileName: string): Boolean;
var
  LGMDManager   : TgmGMDManager;
  LLayerIndex   : Integer;
  LLayerPanel   : TgmLayerPanel;
  LLayerLocation: TFloatRect;
  LRect         : TRect;
  LTopLeft      : TPoint;
  LSnapshotPanel: TgmSnapshotPanel;
  LLastChildForm: TfrmChild; // pointer to last active child form (if any)
begin
  Result         := False;
  LLastChildForm := nil;

  // load data from file
  LGMDManager := TgmGMDManager.Create;
  try
    // check file validity
    if LGMDManager.CheckFileValidity(AFileName) = False then
    begin
      MessageDlg(LGMDManager.OuputMsg, mtError, [mbOK], 0);
    end
    else
    begin
      // if there is an active child form, hide all layer panels of it
      if ActiveChildForm <> nil then
      begin
        if ActiveChildForm.LayerPanelList.Count > 0 then
        begin
          ActiveChildForm.LayerPanelList.HideAllLayerPanels;
        end;

        if ActiveChildForm.PathPanelList.Count > 0 then
        begin
          ActiveChildForm.PathPanelList.HideAllPathPanels;
        end;

        ActiveChildForm.HistoryManager.HideAllPanels;
        ActiveChildForm.ChannelManager.HideAllChannelPanels;

        LLastChildForm := ActiveChildForm;
      end;

      FChildFormIsCreating := True;
      try
        ActiveChildForm := TfrmChild.Create(Self);
      finally
        FChildFormIsCreating := False;
      end;

      // determine whether or not refresh these pannels
      ActiveChildForm.LayerPanelList.IsAllowRefreshLayerPanels   := frmLayer.IsShowingUp;
      ActiveChildForm.ChannelManager.IsAllowRefreshChannelPanels := frmChannel.IsShowingUp;
      ActiveChildForm.PathPanelList.IsAllowRefreshPathPanels     := frmPath.IsShowingUp;
      ActiveChildForm.HistoryManager.IsAllowRefreshPanels        := frmHistory.IsShowingUp;

      ActiveChildForm.FileName := AFileName;

      // link pointers to the gmd manager
      LGMDManager.LayerPanelList := ActiveChildForm.LayerPanelList;
      LGMDManager.ChannelManager := ActiveChildForm.ChannelManager;
      LGMDManager.PathPanelList  := ActiveChildForm.PathPanelList;

      if LGMDManager.LoadFromFile(AFileName) then
      begin
        if ActiveChildForm.LayerPanelList.Count > 0 then
        begin
          { Note that, at this point, the GMD file loader is already make the
            FLayerPanelList.SelectedLayerPanel points to the selected layer panel.
            We could reference to it safely. Actually, this has been done in
            LoadLayersFromStream() method that is member of class TLayerPanelList. }

          LLayerIndex := ActiveChildForm.LayerPanelList.GetFirstSelectedLayerPanelIndex;
          ActiveChildForm.LayerPanelList.CurrentIndex := LLayerIndex;

          // set size of the background
          ActiveChildForm.imgDrawingArea.Bitmap.SetSize(
            ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
            ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height);

          // get location of the bitmap in the TImage32
          LRect := ActiveChildForm.imgDrawingArea.GetBitmapRect;

          { Convert the top-left point of the background bitmap of the TImage32
            from control coordinate to bitmap coordinate. }
          LTopLeft := ActiveChildForm.imgDrawingArea.ControlToBitmap( Point(LRect.Left, LRect.Top) );

          LLayerLocation := FloatRect(LTopLeft.X, LTopLeft.Y,
                                      ActiveChildForm.imgDrawingArea.Bitmap.Width,
                                      ActiveChildForm.imgDrawingArea.Bitmap.Height);

          ActiveChildForm.LayerPanelList.SetLocationForAllLayers(LLayerLocation);

          // set history bitmap
          LLayerIndex := ActiveChildForm.LayerPanelList.GetBackgroundLayerPanelIndex;
          LLayerPanel := ActiveChildForm.LayerPanelList.GetLayerPanelByIndex(LLayerIndex);

          if Assigned(LLayerPanel) then
          begin
            ActiveChildForm.HistoryBitmap.Assign(LLayerPanel.AssociatedLayer.Bitmap);
          end
          else
          begin
            LLayerPanel := ActiveChildForm.LayerPanelList.GetLayerPanelByIndex(0);
            ActiveChildForm.HistoryBitmap.Assign(LLayerPanel.AssociatedLayer.Bitmap)
          end;

          frmLayer.cmbbxLayerBlendMode.ItemIndex := ActiveChildForm.LayerPanelList.SelectedLayerPanel.BlendModeIndex;
          ActiveChildForm.FLayerTopLeft          := ActiveChildForm.GetLayerTopLeft;

          // create Snapshot for history command
          LSnapshotPanel := TgmSnapshotPanel.Create(frmHistory.scrlbxHistory,
                                                    ActiveChildForm.HistoryBitmap,
                                                    ExtractFileName(AFileName));

          ActiveChildForm.HistoryManager.AddSnapshot(LSnapshotPanel);
          frmHistory.scrlbxHistory.VertScrollBar.Position := frmHistory.scrlbxHistory.VertScrollBar.Range;

          // create preview layer of channel manager for this child form
          ActiveChildForm.ChannelManager.CreateChannelPreviewLayer(
            ActiveChildForm.imgDrawingArea.Layers,
            ActiveChildForm.LayerPanelList,
            ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
            ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height,
            ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Location);

          { Set the layer index of the channel preview layer just above all of the
            working layers and below the all of the channel layers and handle layers. }
          TPositionedLayer(ActiveChildForm.ChannelManager.ChannelPreviewLayer).Index := ActiveChildForm.LayerPanelList.Count;

          // associate the new layer panel to the channel mannager
          ActiveChildForm.ChannelManager.AssociateToLayerPanel(
            ActiveChildForm.LayerPanelList.SelectedLayerPanel);

          // set location for channels layers
          ActiveChildForm.ChannelManager.SetLocationForAllChannelLayers(LLayerLocation);
          ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);

          // set paths, update the thumbnail of every path panel in the list
          if ActiveChildForm.PathPanelList.Count > 0 then
          begin
            // create the path layer in order to calculate the offset vector
            ActiveChildForm.CreatePathLayer;

            ActiveChildForm.PathPanelList.UpdateAllThumbnails(
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height,
              ActiveChildForm.PathOffsetVector);

            // we don't need this layer at now
            ActiveChildForm.DeletePathLayer;
          end;

          // activate proper channel
          if Assigned(ActiveChildForm.ChannelManager.QuickMaskPanel) then
          begin
            ActiveChildForm.EditMode := emQuickMaskMode;

            ActiveChildForm.ChannelManager.SelectQuickMask;

            spdbtnQuickMaskMode.Down := True;
          end
          else
          begin
            if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
                 lfBackground, lfTransparent, lfFigure, lfShapeRegion,
                 lfRichText] then
            begin
              ActiveChildForm.ChannelManager.SelectAllColorChannels;
            end
            else
            begin
              if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask then
              begin
                ActiveChildForm.ChannelManager.SelectLayerMask;
              end
              else
              begin
                ActiveChildForm.ChannelManager.SelectAllColorChannels;
              end;
            end;
          end;

          ActiveChildForm.LayerPanelList.SelectedLayerPanel.UpdateLayerPanelState;

          if ActiveChildForm.WindowState = wsNormal then
          begin
            { Make the size of the window same as the size of the layer, but we
              think that this is not a good method for this purpose. If we could
              find a better way for this, we will rewrite the following code. }

            ActiveChildForm.Width                 := ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width  + 26;
            ActiveChildForm.Height                := ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height + 54;
            ActiveChildForm.imgDrawingArea.Width  := ActiveChildForm.imgDrawingArea.Bitmap.Width;
            ActiveChildForm.imgDrawingArea.Height := ActiveChildForm.imgDrawingArea.Bitmap.Height;
          end;

          stsbrMain.Panels[0].Text := GetBitmapDimensionString(ActiveChildForm.HistoryBitmap);
          ActiveChildForm.RefreshCaption;
          ActiveChildForm.SetupOnChildFormActivate;

          Result := True;
        end;
      end
      else // cannot load in the specified .gmd file from disk
      begin
        if Assigned(ActiveChildForm) then
        begin
          ActiveChildForm.Close;
          FreeAndNil(ActiveChildForm);
        end;

        if Assigned(LLastChildForm) then
        begin
          ActiveChildForm := LLastChildForm;
          ActiveChildForm.Show;
        end;
      end;
    end;

  finally
    LGMDManager.Free;
  end;
end;

{ When trying to open an opened file, then we just show the form with the
  opened file to top of the screen. }
function TfrmMain.ShowOpenedImageTop(const CheckFileName: string): Boolean;
var
  i: Integer;
begin
  Result := False;

  if CheckFileName <> '' then
  begin
    if MDIChildCount > 0 then
    begin
      for i := 0 to MDIChildCount - 1 do
      begin
        if CheckFileName = TfrmChild(MDIChildren[i]).FileName then
        begin
          Result := True;
          TfrmChild(MDIChildren[i]).Show;
          Break;
        end;
      end;
    end;
  end;
end;

procedure TfrmMain.ShowCannotProcessEmptyLayerInfo(Sender: TObject);
var
  CommandName: string;
begin
  if      Sender = mnitmGimpLevelsTool        then CommandName := 'Levels'
  else if Sender = mnitmGimpAutoLevels        then CommandName := 'Auto Levels'
  else if Sender = mnitmGimpCurvesTool        then CommandName := 'Curves'
  else if Sender = mnitmBrightnessAndContrast then CommandName := 'Brightness / Contrast'
  else if Sender = mnitmColorBalance          then CommandName := 'Color Balance'
  else if Sender = mnitmHLSOrHSV              then CommandName := 'Hue / Saturation'
  else if Sender = mnitmReplaceColor          then CommandName := 'Replace Color'
  else if Sender = mnitmThreshold             then CommandName := 'Threshold'
  else if Sender = mnitmPosterize             then CommandName := 'Posterize'
  else if Sender = mnitmGradientMap           then CommandName := 'Gradient Map'
  else if Sender = mnitmInvert                then CommandName := 'Invert'
  else if Sender = mnitmDesaturate            then CommandName := 'Desaturate'
  else if Sender = mnitmChannelMixer          then CommandName := 'Channel Mixer';

  MessageDlg('Could not complete the ' + CommandName + ' command' + #10#13 +
             'because the active layer is empty.', mtError, [mbOK], 0);
end; 

{ Open Recent Methods }

procedure TfrmMain.LoadOpenRecentPathToList(AStringList: TStringList);
var
  IniFile                     : TIniFile;
  OpenRecentCount, i          : Integer;
  Ident, FileName, IniFileName: string;
begin
  AStringList.Clear;
  IniFileName := ChangeFileExt(ParamStr(0),'.ini');

  if FileExists(IniFileName) then
  begin
    IniFile := TIniFile.Create(IniFileName);
    try
      // loading the number of OpenRecent file paths
      OpenRecentCount := StrToInt( IniFile.ReadString(SECTION_OPEN_RECENT, IDENT_OPEN_RECENT_COUNT, '0') );

      if OpenRecentCount > 0 then
      begin
        for i := 0 to OpenRecentCount - 1 do
        begin
          Ident    := IDENT_OPEN_RECENT_PATH + IntToStr(i);
          FileName := IniFile.ReadString(SECTION_OPEN_RECENT, Ident, '');
          AStringList.Add(FileName);
        end;
      end;
    finally
      IniFile.Free;
    end;
  end;
end;

procedure TfrmMain.AddFilePathToList(AStringList: TStringList;
  const AFilePath: string);
var
  InList: Boolean;
  i     : Integer;
begin
  if AStringList.Count > 0 then
  begin
    InList := False;

    // check for whether the file path is already in the list
    for i := 0 to AStringList.Count - 1 do
    begin
      if AFilePath = AStringList.Strings[i] then
      begin
        InList := True;
        Break;
      end;
    end;
    
    // if the file path is already in the list, then move it to the first postion of the list
    if InList then
    begin
      AStringList.Move(i, 0);
    end
    else
    begin
      // MAX_OPEN_RECENT_COUNT was declared in gmConstants.pas.
      if AStringList.Count = MAX_OPEN_RECENT_COUNT then
      begin
        AStringList.Delete(AStringList.Count - 1);
      end;

      AStringList.Insert(0, AFilePath);
    end;
  end
  else
  begin
    // if the file path list is empty, add the file path to the list immediately
    AStringList.Add(AFilePath); 
  end;
end;

procedure TfrmMain.UpdateOpenRecentMenuItem;
var
  MenuItem: TMenuItem;
  FileName: string;
  i       : Integer;
begin
  if FOpenRecentPathList.Count > 0 then
  begin
    { Make sure the number of items of the menu list is same as the number of
      items of file paths list. }
    if FOpenRecentMenuList.Count < FOpenRecentPathList.Count then
    begin
      for i := 1 to FOpenRecentPathList.Count - FOpenRecentMenuList.Count do
      begin
        MenuItem         := TMenuItem.Create(Self);   // create menu item
        MenuItem.OnClick := OpenRecentMenuItemClick;  // connect click event to the menu item

        // insert the new menu item under the OpenRecent menu item
        mnitmOpenRecent.Insert(0, MenuItem);
        FOpenRecentMenuList.Insert(0, MenuItem);  // insert the new menu item to the list
      end;
    end;

    // change the caption of the menus with Open Recent file names, respectively
    if FOpenRecentMenuList.Count = FOpenRecentPathList.Count then
    begin
      for i := 0 to FOpenRecentPathList.Count - 1 do
      begin
        FileName := ExtractFileName(FOpenRecentPathList.Strings[i]);
        TMenuItem(FOpenRecentMenuList.Items[i]).Caption := FileName;
      end;
    end;
  end;
end;

// connect this OnClick event to the OpenRecent menus
procedure TfrmMain.OpenRecentMenuItemClick(Sender: TObject);
var
  i       : Integer;
  FileName: string;

begin
  if FOpenRecentMenuList.Count > 0 then
  begin
    for i := 0 to FOpenRecentMenuList.Count - 1 do
    begin
      { If the mouse is clicked on any of the menu items, then open the
        corresponding file. }
      if Sender = TMenuItem(FOpenRecentMenuList.Items[i]) then
      begin
        FileName := FOpenRecentPathList.Strings[i];
        try
          if not ShowOpenedImageTop(FileName)
          then OpenImageInChildForm(FileName);

          // bring the current opened file menu front
          FOpenRecentPathList.Move(i, 0);
          UpdateOpenRecentMenuItem;
        except
          MessageDlg('Can not open the file!', mtError, [mbOK], 0);
        end;
        Break;
      end;
    end;
  end;
end;

procedure TfrmMain.WriteOpenRecentInfoToIniFile;
var
  Ident: string;
  i    : Integer;
begin
  if FOpenRecentPathList.Count > 0 then
  begin
    WriteInfoToIniFile( SECTION_OPEN_RECENT, IDENT_OPEN_RECENT_COUNT, IntToStr(FOpenRecentPathList.Count) );

    for i := 0 to FOpenRecentPathList.Count - 1 do
    begin
      Ident := IDENT_OPEN_RECENT_PATH + IntToStr(i);
      WriteInfoToINIFile(SECTION_OPEN_RECENT, Ident, FOpenRecentPathList.Strings[i]);
    end;
  end;
end;

procedure TfrmMain.DuplicateSelection;
begin
  if Assigned(FSelectionClipboard) then
  begin
    FreeAndNil(FSelectionClipboard);
  end;
  
  if Assigned(ActiveChildForm.Selection) then
  begin
    FSelectionClipboard := TgmSelection.Create;
    FSelectionClipboard.AssignSelectionData(ActiveChildForm.Selection);

    // we need to adjust the forground of the clipboard selection only on the following situation
    if ActiveChildForm.ChannelManager.CurrentChannelType in
         [wctRed, wctGreen, wctBlue] then
    begin
      AdjustBitmapChannels32(FSelectionClipboard.CutOriginal,
                             ActiveChildForm.ChannelManager.ChannelSelectedSet);

      FSelectionClipboard.GetForeground;
    end;
  end;
end;

// the return value of this function indicates whether we pasted on a new layer
function TfrmMain.PasteSelection: Boolean;
begin
  Result := False;

  if Assigned(FSelectionClipboard) then
  begin
    if ActiveChildForm.ChannelManager.CurrentChannelType = wctRGB then
    begin
      ActiveChildForm.CreateBlankLayer;  // Create a new layer.
      Result := True;
    end;

    if ActiveChildForm.Selection = nil then
    begin
      ActiveChildForm.CreateNewSelection;
    end;

    if Assigned(ActiveChildForm.Selection) then
    begin
      ActiveChildForm.tmrMarchingAnts.Enabled := False;
      ActiveChildForm.Selection.AssignSelectionData(FSelectionClipboard);

      { The CenterAlignSelection() method culculates the position of the
        selection according to the background size of the selection, so we
        need to specify the background size beforehand. }

      ActiveChildForm.Selection.Background.SetSize(
        ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
        ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height);

      ActiveChildForm.Selection.CenterAlignSelection;

      if FMarqueeTool = mtMoveResize then
      begin
        if ActiveChildForm.SelectionHandleLayer = nil then
        begin
          ActiveChildForm.CreateSelectionHandleLayer;
        end;

        ActiveChildForm.SelectionHandleLayer.Bitmap.Clear($00000000);

        ActiveChildForm.Selection.DrawMarchingAntsBorder(ActiveChildForm.SelectionHandleLayer.Bitmap.Canvas,
          ActiveChildForm.SelectionHandleLayerOffsetVector.X, ActiveChildForm.SelectionHandleLayerOffsetVector.Y, True);
      end;

      if ActiveChildForm.ChannelManager.CurrentChannelType in [wctAlpha, wctQuickMask, wctLayerMask] then
      begin
        Desaturate32(ActiveChildForm.Selection.CutOriginal);
        ActiveChildForm.Selection.GetForeground;
      end;

      case ActiveChildForm.ChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            if Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
            begin
              ActiveChildForm.Selection.SourceBitmap.Assign(
                ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);

              ActiveChildForm.Selection.Background.Assign(
                ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);

              ActiveChildForm.Selection.ShowSelection(
                ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                ActiveChildForm.ChannelManager.ChannelSelectedSet);

              ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
              ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.UpdateThumbnail;
            end;
          end;

        wctQuickMask:
          begin
            ActiveChildForm.Selection.SourceBitmap.Assign(
              ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);

            ActiveChildForm.Selection.Background.Assign(
              ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);

            ActiveChildForm.Selection.ShowSelection(
              ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
              ActiveChildForm.ChannelManager.ChannelSelectedSet);

            ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Changed;
            ActiveChildForm.ChannelManager.QuickMaskPanel.UpdateThumbnail;
          end;

        wctLayerMask:
          begin
            ActiveChildForm.Selection.SourceBitmap.Assign(
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
              
            ActiveChildForm.Selection.Background.Assign(
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);

            ActiveChildForm.Selection.ShowSelection(
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
              ActiveChildForm.ChannelManager.ChannelSelectedSet);

            ActiveChildForm.LayerPanelList.SelectedLayerPanel.UpdateMaskThumbnail;

            // update the mask channel preview layer
            ActiveChildForm.ChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(
              0, 0, ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
              
            ActiveChildForm.ChannelManager.LayerMaskPanel.UpdateThumbnail;
            
            ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;
            ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            ActiveChildForm.Selection.SourceBitmap.Assign(
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

            ActiveChildForm.Selection.Background.Assign(
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

            ActiveChildForm.Selection.ShowSelection(
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
              ActiveChildForm.ChannelManager.ChannelSelectedSet);

            ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
            ActiveChildForm.LayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
            ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
          end;
      end;

      ActiveChildForm.tmrMarchingAnts.Enabled := True;
    end;
  end;
end;

procedure TfrmMain.CreateFillOrAdjustmentLayer(Sender: TObject);
var
  LNewLayer, LBackLayer    : TBitmapLayer;
  LLayerPanel              : TgmLayerPanel;
  LIndex                   : Integer;
  LFillColor               : TColor32;
  LFlattenedLayers         : TBitmap32;
  LSolidColorLayerPanel    : TgmSolidColorLayerPanel;
  LGradientFillLayerPanel  : TgmGradientFillLayerPanel;
  LChannelMixerLayerPanel  : TgmChannelMixerLayerPanel;
  LGradientMapLayerPanel   : TgmGradientMapLayerPanel;
  LPatternLayerPanel       : TgmPatternLayerPanel;
  LGimpCurvesLayerPanel    : TgmCurvesLayerPanel;
  LGimpLevelsLayerPanel    : TgmLevelsLayerPanel;
  LColorBalanceLayerPanel  : TgmColorBalanceLayerPanel;
  LBrightContrastLayerPanel: TgmBrightContrastLayerPanel;
  LHueSaturationLayerPanel : TgmHueSaturationLayerPanel;
  LInvertLayerPanel        : TgmInvertLayerPanel;
  LThresholdLayerPanel     : TgmThresholdLayerPanel;
  LPosterizeLayerPanel     : TgmPosterizeLayerPanel;
  LModalResult             : TModalResult;
  LHistoryStatePanel       : TgmHistoryStatePanel;
begin
  LHistoryStatePanel    := nil;
  LLayerPanel           := nil;
  LSolidColorLayerPanel := nil;
  LGimpCurvesLayerPanel := nil;
  LGimpLevelsLayerPanel := nil;
  LModalResult          := mrNone;

  if frmRichTextEditor.Visible then
  begin
    ActiveChildForm.CommitEdits;
  end;

  ActiveChildForm.DeleteRichTextHandleLayer;
  ActiveChildForm.DeleteShapeOutlineLayer;

  LBackLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[0]);
  LIndex     := ActiveChildForm.LayerPanelList.CurrentIndex;

  // create a new layer for imgDrawingArea.Layers
  ActiveChildForm.imgDrawingArea.Layers.Insert(LIndex + 1, TBitmapLayer);
  LNewLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[LIndex + 1]);

  LNewLayer.Bitmap.SetSize(LBackLayer.Bitmap.Width, LBackLayer.Bitmap.Height);
  LNewLayer.Location := LBackLayer.Location;
  LNewLayer.Scaled   := True;

  // create various adjustment layers
  if (Sender = mnitmSolidColorLayer) or
     (Sender = dmLayer.pmnitmSolidColor) then
  begin
    LLayerPanel := TgmSolidColorLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer);
  end
  else
  if (Sender = mnitmGradientFillLayer) or
     (Sender = dmLayer.pmnitmGradientFill) then
  begin
    LLayerPanel := TgmGradientFillLayerPanel.Create(
      frmLayer.scrlbxLayers, LNewLayer, frmGradientPicker.GetFillLayerGradient);
  end
  else
  if (Sender = mnitmBrightContrastLayer) or
     (Sender = dmLayer.pmnitmBrightnessContrast) then
  begin
    LLayerPanel := TgmBrightContrastLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer);
  end
  else
  if (Sender = mnitmGimpCurvesLayer) or
     (Sender = dmLayer.pmnitmGimpCurves) then
  begin
    LLayerPanel := TgmCurvesLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer);
  end
  else
  if (Sender = mnitmGimpLevelsLayer) or
     (Sender = dmLayer.pmnitmGimpLevels) then
  begin
    LLayerPanel := TgmLevelsLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer);
  end
  else
  if (Sender = mnitmColorBalanceLayer) or
     (Sender = dmLayer.pmnitmColorBalance) then
  begin
    LLayerPanel := TgmColorBalanceLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer);
  end
  else
  if (Sender = mnitmHueSaturationLayer) or
     (Sender = dmLayer.pmnitmHueSaturation) then
  begin
    LLayerPanel := TgmHueSaturationLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer);
  end
  else
  if (Sender = mnitmChannelMixerLayer) or
     (Sender = dmLayer.pmnitmChannelMixer) then
  begin
    LLayerPanel := TgmChannelMixerLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer);
  end
  else
  if (Sender = mnitmGradientMapLayer) or
     (Sender = dmLayer.pmnitmGradientMap) then
  begin
    LLayerPanel := TgmGradientMapLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer,
                                                   frmGradientPicker.GetMapLayerGradient);
  end
  else
  if (Sender = mnitmInvertLayer) or
     (Sender = dmLayer.pmnitmInvert) then
  begin
    LLayerPanel := TgmInvertLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer);
  end
  else
  if (Sender = mnitmThresholdLayer) or
     (Sender = dmLayer.pmnitmThreshold) then
  begin
    LLayerPanel := TgmThresholdLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer);
  end
  else
  if (Sender = mnitmPosterizeLayer) or
     (Sender = dmLayer.pmnitmPosterize) then
  begin
    LLayerPanel := TgmPosterizeLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer);
  end
  else
  if (Sender = mnitmPatternFillLayer) or
     (Sender = dmLayer.pmnitmPattern) then
  begin
    LLayerPanel := TgmPatternLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer,
                                               frmPatterns.LayerPattern);
  end;

  // add new layer panel to list
  if LIndex = (ActiveChildForm.LayerPanelList.Count - 1) then
  begin
    ActiveChildForm.LayerPanelList.AddLayerPanelToList(LLayerPanel);
  end
  else
  begin
    ActiveChildForm.LayerPanelList.InsertLayerPanelToList(LIndex + 1, LLayerPanel);
  end;

  { Create and display the mask for the layer. This must be done after the
    layer panel is added to the layer panel list. }
  frmLayer.AddMaskClick(Sender);

  if (Sender = mnitmSolidColorLayer) or
     (Sender = dmLayer.pmnitmSolidColor) then
  begin
    LSolidColorLayerPanel  := TgmSolidColorLayerPanel(LLayerPanel);
    dmMain.clrdlgRGB.Color := LSolidColorLayerPanel.SolidColor;

    if dmMain.clrdlgRGB.Execute then
    begin
      LModalResult := idOK;
    end
    else
    begin
      LModalResult := idCancel;
    end;
  end
  else
  if (Sender = mnitmGradientFillLayer) or
     (Sender = dmLayer.pmnitmGradientFill) then
  begin
    LModalResult := frmGradientFill.ShowModal // open Gradient Fill dialog
  end
  else
  if (Sender = mnitmBrightContrastLayer) or
     (Sender = dmLayer.pmnitmBrightnessContrast) then
  begin
    // open the Brightness/Contrast dialog
    frmBrightnessContrast := TfrmBrightnessContrast.Create(nil);
    try
      frmBrightnessContrast.IsWorkingOnEffectLayer := True;
      LModalResult := frmBrightnessContrast.ShowModal;
    finally
      FreeAndNil(frmBrightnessContrast);
    end;
  end
  else
  if (Sender = mnitmGimpCurvesLayer) or
     (Sender = dmLayer.pmnitmGimpCurves) then
  begin
    LGimpCurvesLayerPanel := TgmCurvesLayerPanel(
      ActiveChildForm.LayerPanelList.SelectedLayerPanel);

    LFlattenedLayers := TBitmap32.Create;
    try
      LFlattenedLayers.Assign(ActiveChildForm.HistoryBitmap);

      ActiveChildForm.LayerPanelList.FlattenLayersToBitmap(LFlattenedLayers,
        dmBlend, 0, ActiveChildForm.LayerPanelList.CurrentIndex - 1);

      LGimpCurvesLayerPanel.FlattenedLayer := LFlattenedLayers;
    finally
      LFlattenedLayers.Free;
    end;

    // Open Curves dialog
    frmCurves := TfrmCurves.Create(nil);
    try
      frmCurves.IsWorkingOnEffectLayer := True;
      LModalResult := frmCurves.ShowModal;
    finally
      FreeAndNil(frmCurves);
    end;
  end
  else
  if (Sender = mnitmGimpLevelsLayer) or
     (Sender = dmLayer.pmnitmGimpLevels) then
  begin
    LGimpLevelsLayerPanel := TgmLevelsLayerPanel(
      ActiveChildForm.LayerPanelList.SelectedLayerPanel);

    LFlattenedLayers := TBitmap32.Create;
    try
      LFlattenedLayers.Assign(ActiveChildForm.HistoryBitmap);

      ActiveChildForm.LayerPanelList.FlattenLayersToBitmap(LFlattenedLayers,
        dmBlend, 0, ActiveChildForm.LayerPanelList.CurrentIndex - 1);

      LGimpLevelsLayerPanel.FlattenedLayer := LFlattenedLayers;
    finally
      LFlattenedLayers.Free;
    end;

    // Open Level dialog
    frmLevelsTool := TfrmLevelsTool.Create(nil);
    try
      frmLevelsTool.IsWorkingOnEffectLayer := True;
      LModalResult := frmLevelsTool.ShowModal;
    finally
      FreeAndNil(frmLevelsTool);
    end;
  end
  else
  if (Sender = mnitmColorBalanceLayer) or
     (Sender = dmLayer.pmnitmColorBalance) then
  begin
    // Open Color Balance dialog
    frmColorBalance := TfrmColorBalance.Create(nil);
    try
      LModalResult := frmColorBalance.ShowModal;
    finally
      FreeAndNil(frmColorBalance);
    end;
  end
  else
  if (Sender = mnitmHueSaturationLayer) or
     (Sender = dmLayer.pmnitmHueSaturation) then
  begin
    // open Hue/Saturation dialog
    frmHueSaturation := TfrmHueSaturation.Create(nil);
    try
      LModalResult := frmHueSaturation.ShowModal
    finally
      FreeAndNil(frmHueSaturation);
    end;
  end
  
  else
  if (Sender = mnitmChannelMixerLayer) or
     (Sender = dmLayer.pmnitmChannelMixer) then
  begin
    // open Channel Mixer dialog
    frmChannelMixer := TfrmChannelMixer.Create(nil);
    try
      LModalResult := frmChannelMixer.ShowModal;
    finally
      FreeAndNil(frmChannelMixer);
    end;
  end
  else
  if (Sender = mnitmGradientMapLayer) or
     (Sender = dmLayer.pmnitmGradientMap) then
  begin
    // open Gradient Map dialog which is created automatically
    LModalResult := frmGradientMap.ShowModal;
  end
  else
  if (Sender = mnitmThresholdLayer) or
     (Sender = dmLayer.pmnitmThreshold) then
  begin
    frmThreshold := TfrmThreshold.Create(nil);
    try
      frmThreshold.IsWorkingOnEffectLayer := True;
      LModalResult := frmThreshold.ShowModal; // open Threshold dialog
    finally
      FreeAndNil(frmThreshold);
    end;
  end
  else
  if (Sender = mnitmPosterizeLayer) or
     (Sender = dmLayer.pmnitmPosterize) then
  begin
    // open Posterize dialog
    frmPosterize := TfrmPosterize.Create(nil);
    try
      frmPosterize.IsWorkingOnEffectLayer := True;
      LModalResult := frmPosterize.ShowModal;
    finally
      FreeAndNil(frmPosterize);
    end;
  end
  else
  if (Sender = mnitmPatternFillLayer) or
     (Sender = dmLayer.pmnitmPattern) then
  begin
    // open Pattern Fill dialog which is created automatically
    LModalResult := frmPatternFill.ShowModal;
  end
  else
  if (Sender = mnitmInvertLayer) or
     (Sender = dmLayer.pmnitmInvert) then
  begin
    LModalResult := mrNone;

    // Undo/Redo
    LInvertLayerPanel := TgmInvertLayerPanel(LLayerPanel);

    LHistoryStatePanel := TgmInvertLayerStatePanel.Create(
      frmHistory.scrlbxHistory,
      dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
      LIndex + 1,
      LInvertLayerPanel,
      lctNew);
  end;

  case LModalResult of
    idOK:
      begin
        // Undo/Redo
        if (Sender = mnitmSolidColorLayer) or
           (Sender = dmLayer.pmnitmSolidColor) then
        begin
          LSolidColorLayerPanel.SolidColor := dmMain.clrdlgRGB.Color;

          LHistoryStatePanel := TgmSolidColorLayerStatePanel.Create(
            frmHistory.scrlbxHistory,
            dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
            LIndex + 1,
            LSolidColorLayerPanel,
            lctNew);
        end
        else
        if (Sender = mnitmGradientFillLayer) or
           (Sender = dmLayer.pmnitmGradientFill) then
        begin
          LGradientFillLayerPanel := TgmGradientFillLayerPanel(LLayerPanel);
          LGradientFillLayerPanel.SaveLastAdjustment;

          LHistoryStatePanel := TgmGradientFillLayerStatePanel.Create(
            frmHistory.scrlbxHistory,
            dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
            LIndex + 1,
            LGradientFillLayerPanel,
            lctNew);
        end
        else
        if (Sender = mnitmBrightContrastLayer) or
           (Sender = dmLayer.pmnitmBrightnessContrast) then
        begin
          LBrightContrastLayerPanel := TgmBrightContrastLayerPanel(LLayerPanel);
          LBrightContrastLayerPanel.SaveLastAdjustment;

          LHistoryStatePanel := TgmBrightContrastLayerStatePanel.Create(
            frmHistory.scrlbxHistory,
            dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
            LIndex + 1,
            LBrightContrastLayerPanel,
            lctNew);
        end
        else
        if (Sender = mnitmGimpCurvesLayer) or
           (Sender = dmLayer.pmnitmGimpCurves) then
        begin
          LGimpCurvesLayerPanel.SaveLastAdjustment;
          LGimpCurvesLayerPanel.CurvesTool.LUTSetup(3);
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;

          LHistoryStatePanel := TgmCurvesLayerStatePanel.Create(
            frmHistory.scrlbxHistory,
            dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
            LIndex + 1,
            LGimpCurvesLayerPanel,
            lctNew);
        end
        else
        if (Sender = mnitmGimpLevelsLayer) or
           (Sender = dmLayer.pmnitmGimpLevels) then
        begin
          LGimpLevelsLayerPanel.SaveLastAdjustment;
          LGimpLevelsLayerPanel.LevelsTool.LUTSetup(3);
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;

          LHistoryStatePanel := TgmLevelsLayerStatePanel.Create(
            frmHistory.scrlbxHistory,
            dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
            LIndex + 1,
            LGimpLevelsLayerPanel,
            lctNew);
        end
        else
        if (Sender = mnitmColorBalanceLayer) or
           (Sender = dmLayer.pmnitmColorBalance) then
        begin
          LColorBalanceLayerPanel := TgmColorBalanceLayerPanel(LLayerPanel);
          LColorBalanceLayerPanel.SaveLastAdjustment;
          
          LHistoryStatePanel := TgmColorBalanceLayerStatePanel.Create(
            frmHistory.scrlbxHistory,
            dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
            LIndex + 1,
            LColorBalanceLayerPanel,
            lctNew);
        end
        else
        if (Sender = mnitmHueSaturationLayer) or
           (Sender = dmLayer.pmnitmHueSaturation) then
        begin
          LHueSaturationLayerPanel := TgmHueSaturationLayerPanel(LLayerPanel);
          LHueSaturationLayerPanel.SaveLastAdjustment;

          LHistoryStatePanel := TgmHLSLayerStatePanel.Create(
            frmHistory.scrlbxHistory,
            dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
            LIndex + 1,
            LHueSaturationLayerPanel,
            lctNew);
        end
        else
        if (Sender = mnitmChannelMixerLayer) or
           (Sender = dmLayer.pmnitmChannelMixer) then
        begin
          LChannelMixerLayerPanel := TgmChannelMixerLayerPanel(LLayerPanel);
          LChannelMixerLayerPanel.SaveLastAdjustment;

          LHistoryStatePanel := TgmChannelMixerLayerStatePanel.Create(
            frmHistory.scrlbxHistory,
            dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
            LIndex + 1,
            LChannelMixerLayerPanel,
            lctNew);
        end
        else
        if (Sender = mnitmGradientMapLayer) or
           (Sender = dmLayer.pmnitmGradientMap) then
        begin
          LGradientMapLayerPanel := TgmGradientMapLayerPanel(LLayerPanel);
          LGradientMapLayerPanel.SaveLastAdjustment;

          LHistoryStatePanel := TgmGradientMapLayerStatePanel.Create(
            frmHistory.scrlbxHistory,
            dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
            LIndex + 1,
            LGradientMapLayerPanel,
            lctNew);
        end
        else
        if (Sender = mnitmThresholdLayer) or
           (Sender = dmLayer.pmnitmThreshold) then
        begin
          LThresholdLayerPanel := TgmThresholdLayerPanel(LLayerPanel);
          LThresholdLayerPanel.SaveLastAdjustment;

          LHistoryStatePanel := TgmThresholdLayerStatePanel.Create(
            frmHistory.scrlbxHistory,
            dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
            LIndex + 1,
            LThresholdLayerPanel,
            lctNew);
        end
        else
        if (Sender = mnitmPosterizeLayer) or
           (Sender = dmLayer.pmnitmPosterize) then
        begin
          LPosterizeLayerPanel := TgmPosterizeLayerPanel(LLayerPanel);
          LPosterizeLayerPanel.SaveLastAdjustment;

          LHistoryStatePanel := TgmPosterizeLayerStatePanel.Create(
            frmHistory.scrlbxHistory,
            dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
            LIndex + 1,
            LPosterizeLayerPanel,
            lctNew);
        end
        else
        if (Sender = mnitmPatternFillLayer) or
           (Sender = dmLayer.pmnitmPattern) then
        begin
          LPatternLayerPanel := TgmPatternLayerPanel(LLayerPanel);
          LPatternLayerPanel.SaveLastAdjustment;

          LHistoryStatePanel := TgmPatternLayerStatePanel.Create(
            frmHistory.scrlbxHistory,
            dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
            LIndex + 1,
            LPatternLayerPanel,
            lctNew);
        end;

        // update channel thumbnails
        ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(
          ActiveChildForm.LayerPanelList);
      end;
      
    idCancel:
      begin
        // Decrease the layer number then delete the layer panel.
        ActiveChildForm.LayerPanelList.DecreaseSpecialLayerPanelNumber(
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature);
          
        ActiveChildForm.LayerPanelList.DeleteSelectedLayerPanel;

        LNewLayer                     := nil;
        frmLayer.tlbtnAddMask.Enabled := not ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask;
      end;
  end;

  if Assigned(LHistoryStatePanel) then
  begin
    ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);
  end;

  if LNewLayer <> nil then
  begin
    LNewLayer.Bitmap.Changed;
    ActiveChildForm.IsImageProcessed := True; // identify the image has been changed
  end;

  // update the container of the layer panels for showing the scroll bars of it correctly
  frmLayer.scrlbxLayers.Update;

  // update the appearance of the color form
  if ActiveChildForm.ChannelManager.CurrentChannelType in
       [wctRGB, wctRed, wctGreen, wctBlue] then
  begin
    frmColor.ColorMode := cmRGB;
  end
  else
  begin
    frmColor.ColorMode := cmGrayscale;
  end;
  
  // deselect the movable figures after the ajustment layer is inserted into the layer panel list
  if (LModalResult = idOK) or
     (Sender = mnitmInvertLayer) or
     (Sender = dmLayer.pmnitmInvert) then
  begin
    if High(ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray) > (-1) then
    begin
      ActiveChildForm.LayerPanelList.DeselectAllFiguresOnFigureLayer;

      if ActiveChildForm.FHandleLayer <> nil then
      begin
        ActiveChildForm.FHandleLayer.Bitmap.Clear($00FFFFFF);
        ActiveChildForm.FHandleLayer.Bitmap.Changed;
      end;
      
      UpdateToolsOptions;
    end;

    ActiveChildForm.DeleteRichTextHandleLayer;
  end;

  // show selection border, if any
  ActiveChildForm.ShowSelectionHandleBorder;
end; 

{ This function will loops through each child form and get all the
  file names in that form that has the same size image with the destination
  image which was in the Active Child Form. The function will return all
  the file names it found as result. It will return nil if no such image is
  matched. }
function TfrmMain.GetFileNamesWithSameSizeImage: TStringList;
var
  i                   : Integer;
  SrcImageW, SrcImageH: Integer;
  DstImageW, DstImageH: Integer;
  TempForm            : TfrmChild;
begin
  Result := nil;

  if Assigned(ActiveChildForm) then
  begin
    Result := TStringList.Create;
    Result.Add( ExtractFileName(ActiveChildForm.FileName) );

    DstImageW := ActiveChildForm.imgDrawingArea.Bitmap.Width;
    DstImageH := ActiveChildForm.imgDrawingArea.Bitmap.Height;

    for i := 0 to MDIChildCount - 1 do
    begin
      TempForm := TfrmChild(MDIChildren[i]);

      if TempForm <> ActiveChildForm then
      begin
        SrcImageW := TempForm.imgDrawingArea.Bitmap.Width;
        SrcImageH := TempForm.imgDrawingArea.Bitmap.Height;

        if (SrcImageW = DstImageW) and (SrcImageH = DstImageH)
        then Result.Add( ExtractFileName(TfrmChild(MDIChildren[i]).FileName) );
      end;
    end;

    TStringList(Result).Sort;
  end;
end;

function TfrmMain.GetChildFormPointerByFileName(const AFileName: string): TfrmChild;
var
  i          : Integer;
  TempForm   : TfrmChild;
  SrcFileName: string;
begin
  Result := nil;

  if MDIChildCount > 0 then
  begin
    for i := 0 to MDIChildCount - 1 do
    begin
      TempForm    := TfrmChild(MDIChildren[i]);
      SrcFileName := ExtractFileName(TempForm.FileName);

      if AFileName = SrcFileName then
      begin
        Result := TempForm;
        Break;
      end;
    end;
  end;
end;

{ Brush Tools }

function TfrmMain.GetBrushName: string;
begin
  Result := '';

  case FBrushTool of
    btAirBrush:
      begin
        if Assigned(FAirBrush) then
        begin
          Result := FAirBrush.Name;
        end;
      end;

    btJetGunBrush:
      begin
        if Assigned(FJetGun) then
        begin
          Result := FJetGun.Name;
        end;
      end;

  else
    if Assigned(FGMBrush) then
    begin
      Result := FGMBrush.Name;
    end;
  end;
end;

{ Text Tools }
procedure TfrmMain.ChangeIndexByFontName(const AFontName: string);
begin
  with cmbbxFontFamily do
  begin
    if Items.Count > 0 then
    begin
      ItemIndex := Items.IndexOf(AFontName);
    end;
  end;
end;

procedure TfrmMain.ChangeIndexByFontSize(const AFontSize: Byte);
begin
  with cmbbxFontSize do
  begin
    case AFontSize of
       6: ItemIndex := 0;
       8: ItemIndex := 1;
       9: ItemIndex := 2;
      10: ItemIndex := 3;
      11: ItemIndex := 4;
      12: ItemIndex := 5;
      14: ItemIndex := 6;
      16: ItemIndex := 7;
      18: ItemIndex := 8;
      20: ItemIndex := 9;
      22: ItemIndex := 10;
      24: ItemIndex := 11;
      26: ItemIndex := 12;
      28: ItemIndex := 13;
      30: ItemIndex := 14;
      36: ItemIndex := 15;
      48: ItemIndex := 16;
      60: ItemIndex := 17;
      72: ItemIndex := 18;
    end;
  end;
end; 

procedure TfrmMain.SaveNamedTextFile;
var
  LRichTextLayerPanel: TgmRichTextLayerPanel;
begin
  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
  begin
    LRichTextLayerPanel := TgmRichTextLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

    if LRichTextLayerPanel.TextFileName <> '' then
    begin
      frmRichTextEditor.rchedtRichTextEditor.Lines.SaveToFile(LRichTextLayerPanel.TextFileName);
      frmRichTextEditor.stsbrTextInfo.Panels[0].Text := 'File Name: ' + ExtractFileName(LRichTextLayerPanel.TextFileName);
    end
    else
    begin
      SaveNotNamedTextFile;
    end;
  end;
end;

procedure TfrmMain.SaveNotNamedTextFile;
var
  LRichTextLayerPanel: TgmRichTextLayerPanel;
  LFileName, LExtName: string;
begin
  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
  begin
    LRichTextLayerPanel := TgmRichTextLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);
    LFileName           := LRichTextLayerPanel.TextFileName;

    if LFileName = '' then
    begin
      dmMain.svdlgSaveText.FilterIndex := 1;
      dmMain.svdlgSaveText.FileName    := 'Untitled';
      dmMain.svdlgSaveText.InitialDir  := ExtractFilePath( ParamStr(0) );
    end
    else
    begin
      LExtName := ExtractFileExt(LFileName);

      if LExtName = '.rtf' then
      begin
        dmMain.svdlgSaveText.FilterIndex := 1;
      end
      else if LExtName = '.txt' then
      begin
        dmMain.svdlgSaveText.FilterIndex := 2;
      end;
      
      dmMain.svdlgSaveText.FileName   := ExtractFileName(LFileName);
      dmMain.svdlgSaveText.InitialDir := ExtractFilePath(LFileName);
    end;

    if dmMain.svdlgSaveText.Execute then
    begin
      LRichTextLayerPanel.TextFileName := dmMain.svdlgSaveText.Filename;
      LExtName := ExtractFileExt(LRichTextLayerPanel.TextFileName);

      // save modified files
      if LExtName = '' then
      begin
        case dmMain.svdlgSaveText.FilterIndex of
          1:
            begin
              LRichTextLayerPanel.TextFileName := LRichTextLayerPanel.TextFileName + '.rtf';
            end;
            
          2:
            begin
              LRichTextLayerPanel.TextFileName := LRichTextLayerPanel.TextFileName + '.txt';
            end;
        end;
      end
      else
      begin
        case dmMain.svdlgSaveText.FilterIndex of
          1: begin
               if LExtName <> '.rtf' then
               begin
                 LRichTextLayerPanel.TextFileName := ChangeFileExt(LRichTextLayerPanel.TextFileName, '.rtf');
               end;
             end;

          2: begin
               if LExtName <> '.txt' then
               begin
                 LRichTextLayerPanel.TextFileName := ChangeFileExt(LRichTextLayerPanel.TextFileName, '.txt');
               end;
             end;
        end;
      end;

      if FileExists(LRichTextLayerPanel.TextFileName) then
      begin
        if MessageDlg('The file is already existed. Do you want to replace it?',
                      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        begin
          SaveNamedTextFile;
        end
      end
      else
      begin
        SaveNamedTextFile;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmMain.ExitProgram(Sender: TObject);
begin
  Close; 
end;

procedure TfrmMain.CreateNewFile(Sender: TObject);
var
  LNewLayer     : TBitmapLayer;
  LRect         : TRect;
  LTopLeft      : TPoint;
  LLayerPanel   : TgmLayerPanel;
  LSnapshotPanel: TgmSnapshotPanel;
begin
  if ActiveChildForm <> nil then
  begin
    if frmRichTextEditor.Visible or
       (ActiveChildForm.SelectionTransformation <> nil) or
       (ActiveChildForm.Crop <> nil) then
    begin
      Exit;
    end;
  end;

  frmCreateNewFile := TfrmCreateNewFile.Create(nil);
  try
    // open Create New File dialog for getting the new dimension for the image
    if frmCreateNewFile.ShowModal = mrOK then
    begin
      // if there is an active child form, hide all panels of it
      if ActiveChildForm <> nil then
      begin
        if ActiveChildForm.LayerPanelList.Count > 0 then
        begin
          ActiveChildForm.LayerPanelList.HideAllLayerPanels;
        end;
        
        if ActiveChildForm.PathPanelList.Count > 0 then
        begin
          ActiveChildForm.PathPanelList.HideAllPathPanels;
        end;
        
        ActiveChildForm.HistoryManager.HideAllPanels;
        ActiveChildForm.ChannelManager.HideAllChannelPanels;
      end;

      FNewBitmapWidth  := frmCreateNewFile.BitmapWidth;
      FNewBitmapHeight := frmCreateNewFile.BitmapHeight;

      // create a new child form for holding the new created image
      FChildFormIsCreating := True;
      try
        ActiveChildForm := TfrmChild.Create(Self);
      finally
        FChildFormIsCreating := False;
      end;

      // determine whether or not refresh these pannels
      ActiveChildForm.LayerPanelList.IsAllowRefreshLayerPanels   := frmLayer.IsShowingUp;
      ActiveChildForm.ChannelManager.IsAllowRefreshChannelPanels := frmChannel.IsShowingUp;
      ActiveChildForm.PathPanelList.IsAllowRefreshPathPanels     := frmPath.IsShowingUp;
      ActiveChildForm.HistoryManager.IsAllowRefreshPanels        := frmHistory.IsShowingUp;

      ActiveChildForm.HistoryBitmap.SetSize(FNewBitmapWidth, FNewBitmapHeight);
      ActiveChildForm.HistoryBitmap.FillRect(0, 0, FNewBitmapWidth, FNewBitmapHeight, clWhite32);

      ActiveChildForm.imgDrawingArea.Width  := FNewBitmapWidth;
      ActiveChildForm.imgDrawingArea.Height := FNewBitmapHeight;
      ActiveChildForm.imgDrawingArea.Bitmap.SetSize(FNewBitmapWidth, FNewBitmapHeight);

      // create layer for imgDrawingArea.Layers
      LNewLayer := TBitmapLayer.Create(ActiveChildForm.imgDrawingArea.Layers);
      LNewLayer.Bitmap.SetSize(FNewBitmapWidth, FNewBitmapHeight);
      LNewLayer.Bitmap.FillRect(0, 0, LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height, clWhite32);

      // get location of the bitmap in the TImage32
      LRect := ActiveChildForm.imgDrawingArea.GetBitmapRect;

      { Convert the top-left point of the background bitmap of the TImage32
        from control coordinate to bitmap coordinate. }
      LTopLeft := ActiveChildForm.imgDrawingArea.ControlToBitmap( Point(LRect.Left, LRect.Top) );

      LNewLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                      ActiveChildForm.imgDrawingArea.Bitmap.Width,
                                      ActiveChildForm.imgDrawingArea.Bitmap.Height);

      LNewLayer.Scaled := True;
      LNewLayer.Bitmap.Changed;

      ActiveChildForm.FLayerTopLeft := Point(LTopLeft.X, LTopLeft.Y);

      // create a layer panel for the image
      LLayerPanel := TgmBackgroundLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer);
      
      frmLayer.cmbbxLayerBlendMode.ItemIndex := LLayerPanel.BlendModeIndex;

      ActiveChildForm.LayerPanelList.AddLayerPanelToList(LLayerPanel);
      ActiveChildForm.FLayerTopLeft := ActiveChildForm.GetLayerTopLeft;

      // create Snapshot for history command
      LSnapshotPanel := TgmSnapshotPanel.Create(frmHistory.scrlbxHistory,
                                                ActiveChildForm.HistoryBitmap,
                                                'New');

      ActiveChildForm.HistoryManager.AddSnapshot(LSnapshotPanel);
      frmHistory.scrlbxHistory.VertScrollBar.Position := frmHistory.scrlbxHistory.VertScrollBar.Range;

      // create preview layer of channel manager for this child form
      ActiveChildForm.ChannelManager.CreateChannelPreviewLayer(
        ActiveChildForm.imgDrawingArea.Layers, ActiveChildForm.LayerPanelList,
        LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height, LNewLayer.Location);

      // associate the new layer panel to the channel mannager
      ActiveChildForm.ChannelManager.AssociateToLayerPanel(
        ActiveChildForm.LayerPanelList.SelectedLayerPanel);

      if ActiveChildForm.WindowState = wsNormal then
      begin
        { Make the size of the window same as the size of the layer, but we
          think that this is not a good method for this purpose. If we could
          find a better way for this, we will rewrite the following code. }
          
        ActiveChildForm.Width                 := FNewBitmapWidth  + 26;
        ActiveChildForm.Height                := FNewBitmapHeight + 54;
        ActiveChildForm.imgDrawingArea.Width  := ActiveChildForm.imgDrawingArea.Bitmap.Width;
        ActiveChildForm.imgDrawingArea.Height := ActiveChildForm.imgDrawingArea.Bitmap.Height;
      end;

      ActiveChildForm.SetupOnChildFormActivate;
    end;
  finally
    FreeAndNil(frmCreateNewFile);
  end;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  imgToolOptionsVisibility.Bitmap.Assign(dmMain.bmp32lstMainTools.Bitmap[IMG_LEFT_TRIPLE_ARROW_INDEX]);
  frmGradientPicker.ShowDrawingToolSelectedGradient;
  frmLayer.UpdateLayerOptionsEnableStatus;
  frmPath.UpdatePathOptions;

  if FGhostModeEnabled then
  begin
    FGhostDetect.Resume;
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  LPlugInsDir       : string;
  LGhostFadeInterval: Integer;
  LGhostMaxOpaque   : Integer;
begin
{ INI }
  InitializeINIFile;

{ Command }
  CreateCommandStorageFolder;  // create a folder to hold the temporary command files

{ Common }
  FOutputGraphicsFormat := ogfBMP;
  FChildFormIsCreating  := False;
  ActiveChildForm       := nil;
  PrevChildForm         := nil;
  FCanChange            := True;
  FCanExecClick         := True;

  // global bitmaps used for various image adjustment dialogs, such as filters
  FBeforeProc          := TBitmap32.Create;
  FBeforeProc.DrawMode := dmBlend;
  FAfterProc           := TBitmap32.Create;
  FAfterProc.DrawMode  := dmBlend;

  // For Open Recent menu.
  FOpenRecentPathList := TStringList.Create;
  FOpenRecentMenuList := TList.Create;
  
  // save the selection as if it is in clipboard
  FSelectionClipboard := nil;
  FFigureUnits        := auCentimeter;
  FNewBitmapWidth     := 500;
  FNewBitmapHeight    := 500;
  FGlobalForeColor    := clBlack;
  FGlobalBackColor    := clWhite;
  FForeGrayColor      := clBlack;
  FBackGrayColor      := clWhite;

  FMainTool         := gmtStandard;
  FCanChange        := False;
  FGlobalPenStyle   := psSolid;
  FGlobalPenWidth   := 1;
  dmMain.ChangeGlobalBrushStyle(dmMain.pmnitmSolidBrush);

  ntbkToolOptions.PageIndex                       := STANDARD_PAGE_INDEX;
  scrlbxFigureOptions.HorzScrollBar.Position      := 0;
  scrlbxFigureOptions.VertScrollBar.Position      := 0;
  scrlbxBrushOptions.HorzScrollBar.Position       := 0;
  scrlbxBrushOptions.VertScrollBar.Position       := 0;
  scrlbxMarqueeOptions.HorzScrollBar.Position     := 0;
  scrlbxMarqueeOptions.VertScrollBar.Position     := 0;
  scrlbxGradientOptions.HorzScrollBar.Position    := 0;
  scrlbxGradientOptions.VertScrollBar.Position    := 0;
  scrlbxCropOptions.HorzScrollBar.Position        := 0;
  scrlbxCropOptions.VertScrollBar.Position        := 0;
  scrlbxPaintBucketOptions.HorzScrollBar.Position := 0;
  scrlbxPaintBucketOptions.VertScrollBar.Position := 0;
  scrlbxEraserOptions.HorzScrollBar.Position      := 0;
  scrlbxEraserOptions.VertScrollBar.Position      := 0;
  scrlbxPenToolsOptions.HorzScrollBar.Position    := 0;
  scrlbxPenToolsOptions.VertScrollBar.Position    := 0;
  scrlbxMeasureOptions.HorzScrollBar.Position     := 0;
  scrlbxMeasureOptions.VertScrollBar.Position     := 0;
  scrlbxShapeOptions.HorzScrollBar.Position       := 0;
  scrlbxShapeOptions.VertScrollBar.Position       := 0;
  ggbrZoomSlider.ShowHint                         := True;

{ Figure Tools }
  FStandardTool         := gstPencil;
  FLastStandardTool     := gstPencil;
  FStandardCornerRadius := 30;
  FStandardPolygonSides := 3;
  FPencil               := TgmPaintBrush.Create;

  spdbtnStandardTools.Hint := spdbtnPencil.Hint;
  cmbbxPenStyle.ItemIndex  := 0;
  cmbbxPenWidth.ItemIndex  := 0;
  UpdateStandardOptions;

{ Brush Tools }
  FGMBrush                  := TgmPaintBrush.Create;
  FAirBrush                 := TgmAirBrush.Create;
  FJetGun                   := TgmJetGun.Create;
  FBrushTool                := btPaintBrush;
  FBrushBlendMode           := bbmNormal32;
  FBrushOpacity             := 100;
  FBrushIntensity           := 10;
  FBrushRadius              := 40;
  FBrushInterval            := 0;
  FAirPressure              := 10;
  FJetGunPressure           := 100;
  FIsRandomColor            := False;
  FIsUseAllLayers           := False;
  FSmudgePressure           := SMUDGE_DEFAULT_PRESSURE;
  FBlurSharpenPressure      := BLUR_SHARPEN_DEFAULT_PRESSURE;
  FBlurSharpenTimerInterval := BLUR_SHARPEN_DEFAULT_TIMER_INTERVAL;

  // for Dodge/Burn brush
  FDodgeBurnExposure := DODGE_BURN_DEFAULT_EXPOSURE;
  FDodgeBurnMode     := DODGE_BURN_DEFAULT_MODE;

  spdbtnBrushTools.Glyph.Assign(spdbtnPaintBrush.Glyph);
  spdbtnBrushTools.Hint        := spdbtnPaintBrush.Hint;
  updwnBrushRadius.Position    := FBrushRadius;
  updwnBrushInterval.Position  := FBrushInterval;
  chckbxColorAndSample.Visible := False;

  UpdateBrushOptions;

{ Marquee Tools }
  FMarqueeTool        := mtMoveResize;
  FMarqueeMode        := mmNew;
  FRPMSides           := 3;
  FRRMCornerRadius    := 30;
  FMagicWandTolerance := 30;

  spdbtnMarqueeTools.Glyph.Assign(spdbtnSelect.Glyph);
  spdbtnMarqueeTools.Hint := spdbtnSelect.Hint;

{ Gradient Tools }
  FGradientRenderMode   := grmLinear;
  FGradientBlendMode    := bbmNormal32;
  FGradientBlendOpacity := 100;

  spdbtnGradientTools.Hint         := spdbtnLinearGradient.Hint;
  cmbbxGradientBlendMode.Items     := BlendModeList;
  cmbbxGradientBlendMode.ItemIndex := 0;
  updwnGradientOpacity.Position    := 100;

  imgSelectedGradient.Bitmap.DrawMode := dmBlend;
  imgSelectedGradient.Bitmap.SetSize(imgSelectedGradient.Width, imgSelectedGradient.Height);

  with imgSelectedGradient.PaintStages[0]^ do
  begin
    if Stage = PST_CLEAR_BACKGND then
    begin
      Stage := PST_CUSTOM;
    end;
  end;

{ Crop Tools }
  updwnCroppedShieldOpacity.Position := 50;

{ Paint Bucket Tools }
  FPaintBucketFillSource := pbfsForeColor;
  FPaintBucketBlendMode  := bbmNormal32;
  FPaintBucketOpacity    := 100;
  FPaintBucketTolerance  := 15;

  cmbbxPaintBucketFillSource.ItemIndex := 0;
  cmbbxPaintBucketFillMode.Items       := BlendModeList;
  cmbbxPaintBucketFillMode.ItemIndex   := Ord(FPaintBucketBlendMode);
  updwnPaintBucketOpacity.Position     := 100;

{ Eraser Tools }
  FGMEraser              := TgmEraser.Create;
  FEraserTool            := etEraser;
  FErasingMode           := emPaintBrush;
  FBackgroundEraserLimit := belDiscontiguous;
  FEraserSamplingMode    := bsmContiguous;
  FErasingOpacity        := 100;
  FErasingInterval       := 0;
  FAirErasingPressure    := 10;
  FAirErasingInterval    := 100;
  FErasingTolerance      := 15;

  spdbtnEraserTools.Hint              := spdbtnEraser.Hint;
  cmbbxEraserSampling.ItemIndex       := 0;
  updwnEraserOpacityPressure.Position := 100;
  updwnEraserInterval.Position        := 5;
  updwnEraserTolerance.Position       := FErasingTolerance;

  UpdateEraserOptions;

{ Pen Tools }
  FPenTool       := ptPenTool;
  FActivePenTool := ptPenTool;

  spdbtnPenTools.Hint := spdbtnPenTool.Hint;

{ Shape Tools }
  FShapeRegionTool   := srtRectangle;
  FRegionCombineMode := rcmAdd;
  FShapeCornerRadius := 30;
  FShapePolygonSides := 3;
  FLineWeight        := 1;
  FShapeBrushStyle   := bsSolid;

  spdbtnShapeTools.Hint := spdbtnShapeRectangle.Hint;
  dmMain.ChangeShapeBrushStyle(dmMain.pmnitmShapeSolidBrush);

{ Text Tools }
  GetFontNames(cmbbxFontFamily.Items);
  ChangeIndexByFontName('MS Sans Serif');
  UpdateToolsOptions;

{ All Tools }
  ShowStatusInfoOnStatusBar;
  
{ Filter }
  // create plug-in directory
  LPlugInsDir := ExtractFilePath( ParamStr(0) ) + 'Plug-Ins';

  if not DirectoryExists(LPlugInsDir) then
  begin
    CreateDir(LPlugInsDir);
  end;

  FGMPluginInfoList       := TgmPluginInfoList.Create;
  FFilterCategoryMenuList := TgmCategoryMenuItemList.Create;
  InitFilterMenuItem;
  
{ Open Recent }
  LoadOpenRecentPathToList(FOpenRecentPathList);
  UpdateOpenRecentMenuItem;

  ActiveControl := stsbrMain;
  Caption       := 'GraphicsMagic Professional '+ VER;

{Ghosts}
  FGhostModeEnabled  := Boolean(StrToInt(ReadInfoFromIniFile(SECTION_PREFERENCES, IDENT_GHOST_MODE_ENABLED, '1')));
  LGhostFadeInterval := StrToInt(ReadInfoFromIniFile(SECTION_PREFERENCES, IDENT_GHOST_FADE_INTERVAL, '50'));
  LGhostFadeInterval := Clamp(LGhostFadeInterval, MIN_GHOST_FADE_INTERVAL, MAX_GHOST_FADE_INTERVAL);
  LGhostMaxOpaque    := StrToInt(ReadInfoFromIniFile(SECTION_PREFERENCES, IDENT_GHOST_MAX_OPAQUE, '255'));
  LGhostMaxOpaque    := Clamp(LGhostMaxOpaque, MAX_GHOST_OPAQUE_LOWER, MAX_GHOST_OPAQUE_UPPER);

  if FGhostModeEnabled then
  begin
    GhostsWakeUp(True);

    with TfrmGhost.Create(nil) do  //pnlToolOptions
    begin
      House := Self;
      Eat(pnlToolOptions, Self.FGhosts);
      timerFade.Interval := LGhostFadeInterval;
      MaxOpaque          := LGhostMaxOpaque;
      Show;
    end;
    
    with TfrmGhost.Create(nil) do //pnlRightDockArea
    begin
      House := Self;
      Eat(pnlRightDockArea, Self.FGhosts);
      timerFade.Interval := LGhostFadeInterval;
      MaxOpaque          := LGhostMaxOpaque;
      Show;
    end;

    FGhostDetect          := TgmGhostDetect.Create(True);
    FGhostDetect.ExecProc := Self.DetectMousePos;
  end;

  spdbtnGhost.Enabled     := FGhostModeEnabled;
  spdbtnUntouched.Enabled := FGhostModeEnabled;
end;

procedure TfrmMain.mnitmFlattenImageClick(Sender: TObject);
var
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  Screen.Cursor := crHourGlass;
  try
    if Assigned(ActiveChildForm.SelectionHandleLayer) then
    begin
      ActiveChildForm.DeleteSelectionHandleLayer;
    end;

    if Assigned(ActiveChildForm.FHandleLayer) then
    begin
      FreeAndNil(ActiveChildForm.FHandleLayer);
    end;

    if Assigned(ActiveChildForm.ShapeOutlineLayer) then
    begin
      ActiveChildForm.DeleteShapeOutlineLayer;
    end;

    if Assigned(ActiveChildForm.RichTextHandleLayer) then
    begin
      ActiveChildForm.DeleteRichTextHandleLayer;
    end;

    if frmRichTextEditor.Visible then
    begin
      frmRichTextEditor.Close;
    end;

    // deselect all movable figures before flatten the layers
    if High(ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray) > (-1) then
    begin
      ActiveChildForm.LayerPanelList.DeselectAllFiguresOnFigureLayer;
      UpdateToolsOptions;
    end;

    // create Undo/Redo first
    LHistoryStatePanel := TgmFlattenImageStatePanel.Create(
      frmHistory.scrlbxHistory,
      dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX]);

    ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);

    // merge layers
    ActiveChildForm.LayerPanelList.FlattenLayers;

    // associate the flattened layer to channel manager
    ActiveChildForm.ChannelManager.AssociateToLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);
    ActiveChildForm.ChannelManager.SelectAllColorChannels;

    // update channel thumbnail
    ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);

    frmLayer.ggbrLayerOpacity.Position     := ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.MasterAlpha;
    frmLayer.cmbbxLayerBlendMode.ItemIndex := ActiveChildForm.LayerPanelList.SelectedLayerPanel.BlendModeIndex;
    frmLayer.tlbtnAddMask.Enabled          := not ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask;

    ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;

  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfrmMain.FormActivate(Sender: TObject);
begin
  if MDIChildCount < 1 then
  begin
    stsbrMain.Panels[0].Text := 'Thank you for choose this program!';
  end;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: Integer;
begin
  if MDIChildCount > 0 then
  begin
    for i := (MDIChildCount - 1) downto 0 do
    begin
      MDIChildren[i].Close;
    end;
  end;

  WriteOpenRecentInfoToIniFile;

  if FGhostModeEnabled then
  begin
    FGhostDetect.Terminate;
  end;
end;

procedure TfrmMain.UpdateMenuItemClick(Sender: TObject);
var
  LCurIndex, i              : Integer;
  LSelectedColorChannelCount: Integer;
  LTextEditorInvisible      : Boolean;
  LCanCutSelection          : Boolean;
  LFilterMenuEnabled        : Boolean;
  LEnabled                  : Boolean;
  LMenuItem                 : TMenuItem;
  LPluginInfo               : TgmPluginInfo;
begin
  LTextEditorInvisible := (not frmRichTextEditor.Visible);

  if MDIChildCount < 1 then
  begin
    if Sender = mnhdFile then
    begin
      mnitmNewFile.Enabled      := True;
      mnitmOpenFile.Enabled     := True;
      mnitmOpenRecent.Enabled   := (FOpenRecentMenuList.Count > 0);
      mnitmSaveFile.Enabled     := False;
      mnitmSaveFileAs.Enabled   := False;
      mnitmSaveAll.Enabled      := False;
      mnitmClose.Enabled        := False;
      mnitmCloseAll.Enabled     := False;
      mnitmPrintPreview.Enabled := False;
      mnitmPrintOptions.Enabled := False;
      mnitmPageSetup.Enabled    := False;
      mnitmPrintImage.Enabled   := False;
    end
    else if Sender = mnhdEdit then
    begin
      mnitmUndoRedo.Enabled     := False;
      mnitmUndoRedo.Caption     := 'Undo';
      mnitmStepBackward.Enabled := False;
      mnitmStepForeward.Enabled := False;
      mnitmCut.Enabled          := False;
      mnitmCopy.Enabled         := False;
      mnitmPaste.Enabled        := False;
      mnitmFill.Enabled         := False;
      mnitmTransform.Enabled    := False;
    end
    else if Sender = mnhdImage then
    begin
      mnitmMode.Enabled         := False;
      mnitmAdjustments.Enabled  := False;
      mnitmApplyImage.Enabled   := False;
      mnitmImageSize.Enabled    := False;
      mnitmCanvasSize.Enabled   := False;
      mnitmRotateCanvas.Enabled := False;
      mnitmCrop.Enabled         := False;
      mnitmOptimalCrop.Enabled  := False;
      mnitmHistogram.Enabled    := False;
    end
    else if Sender = mnhdLayer then
    begin
      mnitmDuplicateLayer.Enabled     := False;
      mnitmDeleteLayer.Enabled        := False;
      mnitmLayerProperties.Enabled    := False;
      mnitmNewFillLayer.Enabled       := False;
      mnitmNewAdjustmentLayer.Enabled := False;
      mnitmArrangeLayer.Enabled       := False;
      mnitmMergeDown.Enabled          := False;
      mnitmMergeVisibleLayers.Enabled := False;
      mnitmFlattenImage.Enabled       := False;
    end
    else if Sender = mnhdSelect then
    begin
      mnitmSelectAll.Enabled           := False;
      mnitmCommitSelection.Enabled     := False;
      mnitmDeselect.Enabled            := False;
      mnitmDeleteSelection.Enabled     := False;
      mnitmInvertSelection.Enabled     := False;
      mnitmColorRangeSelection.Enabled := False;
      mnitmFeatherRadius.Enabled       := False;
    end
    else if Sender = mnhdFilter then
    begin
      mnitmLastFilter.Enabled := False;

      if Assigned(FFilterCategoryMenuList) then
      begin
        if FFilterCategoryMenuList.Count > 0 then
        begin
          for i := 0 to (FFilterCategoryMenuList.Count - 1) do
          begin
            LMenuItem         := TMenuItem(FFilterCategoryMenuList.Items[i]);
            LMenuItem.Enabled := False;
          end;
        end;
      end;
      
    end;
  end
  else
  begin
    if Sender = mnhdFile then
    begin
      mnitmNewFile.Enabled      := (ActiveChildForm.Crop = nil) and
                                   (LTextEditorInvisible) and
                                   (ActiveChildForm.SelectionTransformation = nil);

      mnitmOpenFile.Enabled     := mnitmNewFile.Enabled;
      mnitmOpenRecent.Enabled   := (FOpenRecentMenuList.Count > 0) and mnitmNewFile.Enabled;
      mnitmSaveFile.Enabled     := mnitmNewFile.Enabled;
      mnitmSaveFileAs.Enabled   := mnitmNewFile.Enabled;
      mnitmSaveAll.Enabled      := mnitmNewFile.Enabled;
      mnitmClose.Enabled        := True;
      mnitmCloseAll.Enabled     := True;
      mnitmPrintPreview.Enabled := mnitmNewFile.Enabled;
      mnitmPrintOptions.Enabled := mnitmNewFile.Enabled;
      mnitmPageSetup.Enabled    := mnitmNewFile.Enabled;
      mnitmPrintImage.Enabled   := mnitmNewFile.Enabled;
    end
    else if Sender = mnhdEdit then
    begin
      if ActiveChildForm.HistoryManager.CommandCount > 0 then
      begin
        mnitmUndoRedo.Enabled := True;
        mnitmUndoRedo.Caption := ActiveChildForm.HistoryManager.OperateName;
      end
      else
      begin
        mnitmUndoRedo.Enabled := False;
        mnitmUndoRedo.Caption := 'Undo';
      end;

      mnitmStepBackward.Enabled := (ActiveChildForm.HistoryManager.CurrentStateIndex >= 0);
      mnitmStepForeward.Enabled := (ActiveChildForm.HistoryManager.CurrentStateIndex < ActiveChildForm.HistoryManager.CommandCount - 1);

      if frmRichTextEditor.Visible then
      begin
        mnitmCut.Enabled   := (frmRichTextEditor.rchedtRichTextEditor.SelLength > 0);
        mnitmPaste.Enabled := Clipboard.HasFormat(cf_TEXT);
      end
      else
      begin
        LCanCutSelection := (ActiveChildForm.Crop = nil) and
                            (ActiveChildForm.Selection <> nil) and
                            ( (ActiveChildForm.ChannelManager.CurrentChannelType in [wctAlpha, wctQuickMask, wctLayerMask]) or
                              (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent]) );

        mnitmCut.Enabled := (ActiveChildForm.SelectionTransformation = nil) and LCanCutSelection;

        mnitmPaste.Enabled := (ActiveChildForm.Crop = nil) and
                              (ActiveChildForm.SelectionTransformation = nil) and
                              (FSelectionClipboard <> nil);
      end;

      mnitmCopy.Enabled := mnitmCut.Enabled;

      mnitmFill.Enabled := (ActiveChildForm.Crop = nil) and
                           (LTextEditorInvisible) and
                           (ActiveChildForm.SelectionTransformation = nil) and
                           ( (ActiveChildForm.ChannelManager.CurrentChannelType in [wctAlpha, wctQuickMask, wctLayerMask]) or
                             (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent]) );

      mnitmTransform.Enabled := (ActiveChildForm.Crop = nil);

      mnitmTransform.Items[0].Enabled := (ActiveChildForm.Crop = nil) and
                                         (ActiveChildForm.Selection <> nil) and
                                         ( (ActiveChildForm.ChannelManager.CurrentChannelType in [wctAlpha, wctQuickMask, wctLayerMask]) or
                                           (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent]) );

      mnitmTransform.Items[0].Checked := (ActiveChildForm.SelectionTransformation <> nil) and
                                         (ActiveChildForm.SelectionTransformation.TransformMode = tmScale);

      mnitmTransform.Items[1].Enabled := mnitmTransform.Items[0].Enabled;

      mnitmTransform.Items[1].Checked := (ActiveChildForm.SelectionTransformation <> nil) and
                                         (ActiveChildForm.SelectionTransformation.TransformMode = tmRotate);

      mnitmTransform.Items[2].Enabled := mnitmTransform.Items[0].Enabled;

      mnitmTransform.Items[2].Checked := (ActiveChildForm.SelectionTransformation <> nil) and
                                         (ActiveChildForm.SelectionTransformation.TransformMode = tmDistort);

      if (ActiveChildForm.ChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue]) and
         (not (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent])) then
      begin
        // we cannot do flip on special layers
        mnitmTransform.Items[4].Enabled := False;
        mnitmTransform.Items[5].Enabled := False;
      end
      else
      begin
        if Assigned(ActiveChildForm.Selection) then
        begin
          mnitmTransform.Items[4].Enabled := (ActiveChildForm.Crop = nil) and
                                             (LTextEditorInvisible) and
                                             (ActiveChildForm.SelectionTransformation = nil);

          mnitmTransform.Items[5].Enabled := mnitmTransform.Items[4].Enabled;
        end
        else
        begin
          mnitmTransform.Items[4].Enabled := (ActiveChildForm.Crop = nil) and
                                             (LTextEditorInvisible) and
                                             (ActiveChildForm.SelectionTransformation = nil) and
                                             (ActiveChildForm.ChannelManager.CurrentChannelType in [wctRGB, wctAlpha, wctQuickMask, wctLayerMask]);

          mnitmTransform.Items[5].Enabled := mnitmTransform.Items[4].Enabled;
        end;
      end;
    end
    else if Sender = mnhdImage then
    begin
      if ActiveChildForm.LayerPanelList.Count = 1 then
      begin
        mnitmMode.Enabled := (ActiveChildForm.Crop = nil) and
                             (ActiveChildForm.SelectionTransformation = nil) and
                             (ActiveChildForm.Selection = nil) and
                             (LTextEditorInvisible) and
                             ( (ActiveChildForm.ChannelManager.CurrentChannelType in [wctAlpha, wctQuickMask, wctLayerMask]) or
                               (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent]) );
      end
      else
      begin
        mnitmMode.Enabled := (ActiveChildForm.Crop = nil) and
                             (ActiveChildForm.SelectionTransformation = nil) and
                             (ActiveChildForm.Selection = nil) and
                             (LTextEditorInvisible);
      end;

      mnitmAdjustments.Enabled := (ActiveChildForm.Crop = nil) and
                                  (ActiveChildForm.SelectionTransformation = nil) and
                                  (LTextEditorInvisible) and
                                  ( (ActiveChildForm.ChannelManager.CurrentChannelType in [wctAlpha, wctQuickMask, wctLayerMask]) or
                                    (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent]) );

      mnitmApplyImage.Enabled := (ActiveChildForm.EditMode = emStandardMode) and
                                 (ActiveChildForm.Crop = nil) and
                                 (ActiveChildForm.SelectionTransformation = nil) and
                                 (LTextEditorInvisible) and
                                 ( (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent]) or
                                   (ActiveChildForm.ChannelManager.CurrentChannelType in [wctAlpha, wctLayerMask]) );

      if ActiveChildForm.ChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue] then
      begin
        mnitmApplyImage.Enabled := mnitmApplyImage.Enabled and
                                   (ActiveChildForm.ChannelManager.SelectedColorChannelCount <> 2);
      end;

      mnitmColorBalance.Enabled := (ActiveChildForm.ChannelManager.CurrentChannelType = wctRGB) and
                                   (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent]);

      mnitmHLSOrHSV.Enabled     := mnitmColorBalance.Enabled;
      mnitmGradientMap.Enabled  := mnitmColorBalance.Enabled;
      mnitmDesaturate.Enabled   := mnitmColorBalance.Enabled;
      mnitmChannelMixer.Enabled := mnitmColorBalance.Enabled;

      mnitmImageSize.Enabled := (ActiveChildForm.Crop = nil) and
                                (LTextEditorInvisible) and
                                (ActiveChildForm.Selection = nil) and
                                (ActiveChildForm.SelectionTransformation = nil);

      mnitmCanvasSize.Enabled   := mnitmImageSize.Enabled;
      mnitmRotateCanvas.Enabled := mnitmImageSize.Enabled;
      mnitmCrop.Enabled         := ActiveChildForm.Crop <> nil;

      mnitmOptimalCrop.Enabled  := (ActiveChildForm.LayerPanelList.Count = 1) and
                                   (ActiveChildForm.ChannelManager.CurrentChannelType = wctRGB) and
                                   (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent]) and
                                   (ActiveChildForm.Selection = nil) and
                                   (ActiveChildForm.Crop = nil);


      mnitmHistogram.Enabled := (ActiveChildForm.Crop = nil) and
                                (ActiveChildForm.SelectionTransformation = nil) and
                                (LTextEditorInvisible);
    end
    else if Sender = mnhdLayer then
    begin
      LCurIndex := ActiveChildForm.LayerPanelList.CurrentIndex;

      mnitmDuplicateLayer.Enabled := (ActiveChildForm.Crop = nil) and
                                     (ActiveChildForm.SelectionTransformation = nil) and
                                     (LTextEditorInvisible);

      mnitmDeleteLayer.Enabled           := mnitmDuplicateLayer.Enabled and (ActiveChildForm.LayerPanelList.Count > 1);
      mnitmLayerProperties.Enabled       := mnitmDuplicateLayer.Enabled;
      mnitmNewFillLayer.Enabled          := mnitmDuplicateLayer.Enabled;
      mnitmNewAdjustmentLayer.Enabled    := mnitmDuplicateLayer.Enabled;

      mnitmArrangeLayer.Enabled          := mnitmDuplicateLayer.Enabled;
      mnitmArrangeLayer.Items[0].Enabled := (LCurIndex < ActiveChildForm.LayerPanelList.Count - 1);
      mnitmArrangeLayer.Items[1].Enabled := mnitmArrangeLayer.Items[0].Enabled;
      mnitmArrangeLayer.Items[2].Enabled := (LCurIndex > 0);
      mnitmArrangeLayer.Items[3].Enabled := mnitmArrangeLayer.Items[2].Enabled;

      mnitmMergeDown.Enabled := (mnitmDuplicateLayer.Enabled) and
                                (ActiveChildForm.LayerPanelList.Count > 1) and
                                (LCurIndex > 0) and
                                (ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsLayerVisible) and
                                (TgmLayerPanel(ActiveChildForm.LayerPanelList.Items[LCurIndex - 1]).IsLayerVisible) and
                                (TgmLayerPanel(ActiveChildForm.LayerPanelList.Items[LCurIndex - 1]).LayerFeature in [lfBackground, lfTransparent]);

      mnitmMergeVisibleLayers.Enabled := (mnitmDuplicateLayer.Enabled) and
                                         (ActiveChildForm.LayerPanelList.Count > 1) and
                                         (ActiveChildForm.LayerPanelList.GetVisibleLayerCount > 1) and
                                         (ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsLayerVisible);

      mnitmFlattenImage.Enabled := mnitmDuplicateLayer.Enabled and (ActiveChildForm.LayerPanelList.Count > 1);
    end
    else if Sender = mnhdSelect then
    begin
      if frmRichTextEditor.Visible then
      begin
        mnitmSelectAll.Enabled           := True;
        mnitmCommitSelection.Enabled     := False;
        mnitmDeselect.Enabled            := False;
        mnitmDeleteSelection.Enabled     := False;
        mnitmInvertSelection.Enabled     := False;
        mnitmColorRangeSelection.Enabled := False;
        mnitmFeatherRadius.Enabled       := False;
      end
      else
      begin
        LEnabled := True;

        if ActiveChildForm.ChannelManager.CurrentChannelType = wctAlpha then
        begin
          // more than one alpha channels were selected
          if ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel = nil then
          begin
            LEnabled := False;
          end;
        end
        else
        if ActiveChildForm.ChannelManager.CurrentChannelType in
             [wctRGB, wctRed, wctGreen, wctBlue] then
        begin
          { The variable IsEnable is trun only when full color channels were
            selected or single color channel was selected. }

          LSelectedColorChannelCount := ActiveChildForm.ChannelManager.SelectedColorChannelCount;

          if (LSelectedColorChannelCount > 1) and (LSelectedColorChannelCount < 3) then
          begin
            LEnabled := False;
          end;
        end;

        if ActiveChildForm.Selection <> nil then
        begin
          mnitmSelectAll.Enabled := (ActiveChildForm.Selection.IsTranslated = False) and
                                    (ActiveChildForm.Selection.IsCornerStretched = False) and
                                    (ActiveChildForm.Selection.IsHorizFlipped = False) and
                                    (ActiveChildForm.Selection.IsVertFlipped = False) and
                                    (ActiveChildForm.SelectionTransformation = nil);

          mnitmCommitSelection.Enabled     := (ActiveChildForm.SelectionTransformation = nil);
          mnitmDeselect.Enabled            := mnitmCommitSelection.Enabled;
          mnitmDeleteSelection.Enabled     := mnitmCommitSelection.Enabled;
          mnitmInvertSelection.Enabled     := mnitmSelectAll.Enabled;
          mnitmColorRangeSelection.Enabled := LEnabled and mnitmSelectAll.Enabled;
          mnitmFeatherRadius.Enabled       := mnitmSelectAll.Enabled;
        end
        else
        begin
          mnitmSelectAll.Enabled := (ActiveChildForm.SelectionTransformation = nil) and
                                    (ActiveChildForm.Crop = nil);

          mnitmCommitSelection.Enabled     := False;
          mnitmDeselect.Enabled            := False;
          mnitmDeleteSelection.Enabled     := False;
          mnitmInvertSelection.Enabled     := False;
          mnitmColorRangeSelection.Enabled := LEnabled and mnitmSelectAll.Enabled;
          mnitmFeatherRadius.Enabled       := False;
        end;
      end;
    end
    else if Sender = mnhdFilter then
    begin
      LFilterMenuEnabled := (ActiveChildForm.SelectionTransformation = nil) and
                            (ActiveChildForm.Crop = nil) and
                            (LTextEditorInvisible) and
                            ( (ActiveChildForm.ChannelManager.CurrentChannelType in [wctAlpha, wctQuickMask, wctLayerMask]) or
                              (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent]) );
                                 
      // update menu items of filters
      FGMPluginInfoList.UpdatePluginMenusEnableState(ActiveChildForm.ChannelManager.CurrentChannelType);

      if Assigned(FLastFilterMenuItem) then
      begin
        LPluginInfo := FGMPluginInfoList.GetPluginInfoByMenuItem(FLastFilterMenuItem);
        
        mnitmLastFilter.Enabled := (LPluginInfo.PluginMenu.Enabled and LFilterMenuEnabled);
      end
      else
      begin
        mnitmLastFilter.Enabled := False;
      end;

      // enable/disable category menu items of filters
      if Assigned(FFilterCategoryMenuList) then
      begin
        if FFilterCategoryMenuList.Count > 0 then
        begin
          for i := 0 to (FFilterCategoryMenuList.Count - 1) do
          begin
            LMenuItem         := TMenuItem(FFilterCategoryMenuList.Items[i]);
            LMenuItem.Enabled := LFilterMenuEnabled;
          end;
        end;
      end;
    end
    else if Sender = mnhdWindow then
    begin
      mnitmCascade.Enabled      := True;
      mnitmTile.Enabled         := True;
      mnitmArrangeIcons.Enabled := True;
    end;
  end;

  if Sender = mnhdWindow then
  begin
    mnitmChannelForm.Checked := frmChannel.Visible;
    mnitmColorForm.Checked   := frmColor.Visible;
    mnitmHistoryForm.Checked := frmHistory.Visible;
    mnitmInfoForm.Checked    := frmInfo.Visible;
    mnitmLayerForm.Checked   := frmLayer.Visible;
    mnitmPathForm.Checked    := frmPath.Visible;
    mnitmSwatchForm.Checked  := frmSwatch.Visible;
    mnitmStatusBar.Checked   := stsbrMain.Visible;
  end;
end;

procedure TfrmMain.OpenFiles(Sender: TObject);
var
  LNewPath: string;
begin
  if ActiveChildForm <> nil then
  begin
    if frmRichTextEditor.Visible or
       (ActiveChildForm.SelectionTransformation <> nil) or
       (ActiveChildForm.Crop <> nil) then
    begin
      Exit;
    end;
  end;

  opnpctrdlgOpenPictures.InitialDir  := ReadInfoFromIniFile(  SECTION_SETUP, IDENT_OPEN_IMAGE_DIR, ExtractFilePath( ParamStr(0) )  );
  opnpctrdlgOpenPictures.FilterIndex := 1; // open files of types that all supported by this program

  if opnpctrdlgOpenPictures.Execute then
  begin
    if opnpctrdlgOpenPictures.FileName <> '' then
    begin
      if FileExists(opnpctrdlgOpenPictures.FileName) then
      begin
        LNewPath := ExtractFilePath(opnpctrdlgOpenPictures.FileName);

        if not ShowOpenedImageTop(opnpctrdlgOpenPictures.FileName) then
        begin
          // Update INI file
          WriteInfoToINIFile(SECTION_SETUP, IDENT_OPEN_IMAGE_DIR, LNewPath);

          if OpenImageInChildForm(opnpctrdlgOpenPictures.FileName) then
          begin
            AddFilePathToList(FOpenRecentPathList, ActiveChildForm.FileName);
            UpdateOpenRecentMenuItem;
          end;
        end;
      end;
    end;
  end;
end;

procedure TfrmMain.SaveFile(Sender: TObject);
begin
  if ActiveChildForm <> nil then
  begin
    if frmRichTextEditor.Visible or
       (ActiveChildForm.SelectionTransformation <> nil) or
       (ActiveChildForm.Crop <> nil) then
    begin
      Exit;
    end;
  end;

  ActiveChildForm.SaveNamedFile;
end;

procedure TfrmMain.SaveFileAs(Sender: TObject);
begin
  if ActiveChildForm <> nil then
  begin
    if frmRichTextEditor.Visible or
       (ActiveChildForm.SelectionTransformation <> nil) or
       (ActiveChildForm.Crop <> nil) then
    begin
      Exit;
    end;
  end;

  ActiveChildForm.SaveFileWithNewName;
end;

procedure TfrmMain.CloseCurrentForm(Sender: TObject);
begin
  ActiveChildForm.Close;
end;

procedure TfrmMain.CloseAllForms(Sender: TObject);
var
  i: Integer;
begin
  // Close all opened forms
  if MDIChildCount > 0 then
  begin
    for i := MDIChildCount - 1 downto 0 do
      MDIChildren[i].Close;
  end;
end;

procedure TfrmMain.mnitmCascadeClick(Sender: TObject);
begin
  Cascade;
end; 

procedure TfrmMain.mnitmTileHorizontallyClick(Sender: TObject);
begin
  TileMode := tbHorizontal;
  Tile;
end;

procedure TfrmMain.mnitmTileVerticallyClick(Sender: TObject);
begin
  TileMode := tbVertical;
  Tile;
end;

procedure TfrmMain.mnitmArrangeIconsClick(Sender: TObject);
begin
  ArrangeIcons; 
end; 

procedure TfrmMain.ShowOrHideTools(Sender: TObject);
begin
if Sender = mnitmChannelForm then
  begin
    case mnitmChannelForm.Checked of
      True:
        begin
          mnitmChannelForm.Checked := False;
          frmChannel.Close;
        end;

      False:
        begin
          mnitmChannelForm.Checked := True;
          frmChannel.Show;
        end;
    end;
  end
  else
  if Sender = mnitmColorForm then
  begin
    case mnitmColorForm.Checked of
      True:
        begin
          mnitmColorForm.Checked := False;
          frmColor.Close;
        end;

      False:
        begin
          mnitmColorForm.Checked := True;
          frmColor.Show;
        end;
    end;
  end
  else
  if Sender = mnitmHistoryForm then
  begin
    case mnitmHistoryForm.Checked of
      True:
        begin
          mnitmHistoryForm.Checked := False;
          frmHistory.Close;
        end;

      False:
        begin
          mnitmHistoryForm.Checked := True;
          frmHistory.Show;
        end;
    end;
  end
  else
  if Sender = mnitmInfoForm then
  begin
    case mnitmInfoForm.Checked of
      True:
        begin
          mnitmInfoForm.Checked := False;
          frmInfo.Close;
        end;

      False:
        begin
          mnitmInfoForm.Checked := True;
          frmInfo.Show;
        end;
    end;
  end
  else
  if Sender = mnitmLayerForm then
  begin
    case mnitmLayerForm.Checked of
      True:
        begin
          mnitmLayerForm.Checked := False;
          frmLayer.Close;
        end;

      False:
        begin
          mnitmLayerForm.Checked := True;
          frmLayer.Show;
        end;
    end;
  end
  else
  if Sender = mnitmPathForm then
  begin
    case mnitmPathForm.Checked of
      True:
        begin
          mnitmPathForm.Checked := False;
          frmPath.Close;
        end;

      False:
        begin
          mnitmPathForm.Checked := True;
          frmPath.Show;
        end;
    end;
  end
  else
  if Sender = mnitmSwatchForm then
  begin
    case mnitmSwatchForm.Checked of
      True:
        begin
          mnitmSwatchForm.Checked := False;
          frmSwatch.Close;
        end;

      False:
        begin
          mnitmSwatchForm.Checked := True;
          frmSwatch.Show;
        end;
    end;
  end
  else
  if Sender = mnitmStatusBar then
  begin
    case mnitmStatusBar.Checked of
      True:
        begin
          mnitmStatusBar.Checked := False;
          stsbrMain.Visible      := False;
        end;
             
      False:
        begin
          mnitmStatusBar.Checked := True;
          stsbrMain.Visible      := True;
        end;
    end;
  end;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
{ Ghost}
  GhostsWakeUp(False);
  if Assigned(FGhostDetect) then
  begin
    FGhostDetect.Free;
  end;

  FOpenRecentPathList.Clear;
  FOpenRecentPathList.Free;
  FOpenRecentMenuList.Clear;
  FOpenRecentMenuList.Free;
  FBeforeProc.Free;
  FAfterProc.Free;
  FSelectionClipboard.Free;

{ Figure Tools }
  FPencil.Free;

{ Brush Tools }
  FGMBrush.Free;
  FAirBrush.Free;
  FJetGun.Free;

{ Eraser Tools }
  FGMEraser.Free;

{ Filter }
  FGMPluginInfoList.Free;
  FFilterCategoryMenuList.Free;
  FLastFilterMenuItem := nil;
end;

procedure TfrmMain.ImageAdjustment(Sender: TObject);
var
  LModalResult : TModalResult;
  LResultBmp   : TBitmap32;
begin
  LModalResult := 0;
  LResultBmp   := nil;

  if (ActiveChildForm.SelectionTransformation <> nil) or
     frmRichTextEditor.Visible or
     (ActiveChildForm.Crop <> nil) then
  begin
    Exit;
  end;

  // we could not process more than one alpha channel at a time
  if ActiveChildForm.ChannelManager.CurrentChannelType = wctAlpha then
  begin
    if not Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
    begin
      Exit;
    end;
  end;

  if Sender = mnitmGimpLevelsTool then
  begin
    // cannot process special layers
    if ActiveChildForm.ChannelManager.CurrentChannelType in [
         wctRGB, wctRed, wctGreen, wctBlue] then
    begin
      if not (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
                lfBackground, lfTransparent]) then
      begin
        Exit;
      end;

      // we cannot process empty images
      if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsEmptyLayer then
      begin
        ShowCannotProcessEmptyLayerInfo(mnitmGimpLevelsTool);
        Exit;
      end;
    end;

    frmLevelsTool := TfrmLevelsTool.Create(nil);
    try
      LModalResult := frmLevelsTool.ShowModal;
    finally
      FreeAndNil(frmLevelsTool);
    end;
  end
  else
  if Sender = mnitmGimpCurvesTool then
  begin
    // cannot process special layers
    if ActiveChildForm.ChannelManager.CurrentChannelType in [
         wctRGB, wctRed, wctGreen, wctBlue] then
    begin
      if not (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
                lfBackground, lfTransparent]) then
      begin
        Exit;
      end;

      // we cannot process empty images
      if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsEmptyLayer then
      begin
        ShowCannotProcessEmptyLayerInfo(mnitmGimpCurvesTool);
        Exit;
      end;
    end;

    frmCurves := TfrmCurves.Create(nil);
    try
      LModalResult := frmCurves.ShowModal;
    finally
      FreeAndNil(frmCurves);
    end;
  end
  else
  if Sender = mnitmBrightnessAndContrast then
  begin
    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsEmptyLayer then
    begin
      ShowCannotProcessEmptyLayerInfo(mnitmBrightnessAndContrast);
      Exit;
    end;

    frmBrightnessContrast := TfrmBrightnessContrast.Create(nil);
    try
      LModalResult := frmBrightnessContrast.ShowModal;
    finally
      FreeAndNil(frmBrightnessContrast);
    end;
  end
  else
  if Sender = mnitmColorBalance then
  begin
    // could not process on alpha channel, quick mask or layer mask
    if ActiveChildForm.ChannelManager.CurrentChannelType in [
         wctAlpha, wctQuickMask, wctLayerMask] then
    begin
      Exit;
    end
    else
    begin
      // could not process on special layers
      if not (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
                lfBackground, lfTransparent]) then
      begin
        Exit;
      end;

      // only process on the layer with full color channels are selected
      if ActiveChildForm.ChannelManager.CurrentChannelType <> wctRGB then
      begin
        Exit;
      end;

      // could not process on empty layers
      if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsEmptyLayer then
      begin
        ShowCannotProcessEmptyLayerInfo(mnitmColorBalance);
        Exit;
      end;
    end;

    frmColorBalance := TfrmColorBalance.Create(nil);
    try
      LModalResult := frmColorBalance.ShowModal;
    finally
      FreeAndNil(frmColorBalance);
    end;
  end
  else
  if Sender = mnitmHLSOrHSV then
  begin
    // could not process on alpha channel, quick mask or layer mask
    if ActiveChildForm.ChannelManager.CurrentChannelType in [
         wctAlpha, wctQuickMask, wctLayerMask] then
    begin
      Exit;
    end
    else
    begin
      // could not process on special layers
      if not (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
                lfBackground, lfTransparent]) then
      begin
        Exit;
      end;

      // only process on the layer with full color channels are selected
      if ActiveChildForm.ChannelManager.CurrentChannelType <> wctRGB then
      begin
        Exit;
      end;

      // could not process on empty layers
      if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsEmptyLayer then
      begin
        ShowCannotProcessEmptyLayerInfo(mnitmHLSOrHSV);
        Exit;
      end;
    end;

    frmHueSaturation := TfrmHueSaturation.Create(nil);
    try
      LModalResult := frmHueSaturation.ShowModal;
    finally
      FreeAndNil(frmHueSaturation);
    end;
  end
  else
  if Sender = mnitmReplaceColor then
  begin
    if ActiveChildForm.ChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue] then
    begin
      // we could only process full color channel selected or one color channel selected
      if ActiveChildForm.ChannelManager.SelectedColorChannelCount = 2 then
      begin
        Exit;
      end;

      if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsEmptyLayer then
      begin
        ShowCannotProcessEmptyLayerInfo(mnitmReplaceColor);
        Exit;
      end;
    end;

    frmReplaceColor := TfrmReplaceColor.Create(nil);
    try
      LModalResult := frmReplaceColor.ShowModal;
    finally
      FreeAndNil(frmReplaceColor);
    end;
  end
  else
  if Sender = mnitmChannelMixer then
  begin
    // could not process on alpha channel, quick mask or layer mask
    if ActiveChildForm.ChannelManager.CurrentChannelType in [
         wctAlpha, wctQuickMask, wctLayerMask] then
    begin
      Exit;
    end
    else
    begin
      // could not process on special layers
      if not (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
                lfBackground, lfTransparent]) then
      begin
        Exit;
      end;

      // only process on the layer with full color channels are selected
      if ActiveChildForm.ChannelManager.CurrentChannelType <> wctRGB then
      begin
        Exit;
      end;

      // could not process on empty layers
      if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsEmptyLayer then
      begin
        ShowCannotProcessEmptyLayerInfo(mnitmChannelMixer);
        Exit;
      end;
    end;

    frmChannelMixer := TfrmChannelMixer.Create(nil);
    try
      LModalResult := frmChannelMixer.ShowModal;
    finally
      FreeAndNil(frmChannelMixer);
    end;
  end
  else
  if Sender = mnitmThreshold then
  begin
    // cannot process special layers
    if ActiveChildForm.ChannelManager.CurrentChannelType in [
         wctRGB, wctRed, wctGreen, wctBlue] then
    begin
      if not (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
                lfBackground, lfTransparent]) then
      begin
        Exit;
      end;

      // we cannot process empty images
      if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsEmptyLayer then
      begin
        ShowCannotProcessEmptyLayerInfo(mnitmThreshold);
        Exit;
      end;
    end;

    frmThreshold := TfrmThreshold.Create(nil);
    try
      LModalResult := frmThreshold.ShowModal;
    finally
      FreeAndNil(frmThreshold);
    end;
  end
  else
  if Sender = mnitmPosterize then
  begin
    // cannot process special layers
    if ActiveChildForm.ChannelManager.CurrentChannelType in [
         wctRGB, wctRed, wctGreen, wctBlue] then
    begin
      if not (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
                lfBackground, lfTransparent]) then
      begin
        Exit;
      end;

      // we cannot process empty images
      if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsEmptyLayer then
      begin
        ShowCannotProcessEmptyLayerInfo(mnitmPosterize);
        Exit;
      end;
    end;

    frmPosterize := TfrmPosterize.Create(nil);
    try
      LModalResult := frmPosterize.ShowModal;
    finally
      FreeAndNil(frmPosterize);
    end;
  end
  else
  if Sender = mnitmGradientMap then
  begin
    // could not process on alpha channel, quick mask or layer mask
    if ActiveChildForm.ChannelManager.CurrentChannelType in [
         wctAlpha, wctQuickMask, wctLayerMask] then
    begin
      Exit;
    end
    else
    begin
      // could not process on special layers
      if not (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
                lfBackground, lfTransparent]) then
      begin
        Exit;
      end;

      // only process on the layer with full color channels are selected
      if ActiveChildForm.ChannelManager.CurrentChannelType <> wctRGB then
      begin
        Exit;
      end;

      // could not process on empty layers
      if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsEmptyLayer then
      begin
        ShowCannotProcessEmptyLayerInfo(mnitmGradientMap);
        Exit;
      end;
    end;

    LModalResult := frmGradientMap.ShowModal;
  end;

  case LModalResult of
    idOK:
      begin
        ActiveChildForm.IsImageProcessed := True;
        LResultBmp                       := FAfterProc;
      end;

    idCancel:
      begin
        LResultBmp := FBeforeProc;
      end;
  end;

  if Assigned(LResultBmp) then
  begin
    if Assigned(ActiveChildForm.Selection) then
    begin
      ActiveChildForm.Selection.CutOriginal.Assign(LResultBmp);
      ActiveChildForm.ShowProcessedSelection;
      ActiveChildForm.RemoveMarchingAnts;
      ActiveChildForm.tmrMarchingAnts.Enabled := True;
    end
    else
    begin
      case ActiveChildForm.ChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            if Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
            begin
              ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Assign(LResultBmp);
              ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
            end;
          end;

        wctQuickMask:
          begin
            if Assigned(ActiveChildForm.ChannelManager.QuickMaskPanel) then
            begin
              ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.Assign(LResultBmp);
              ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Changed;
            end;
          end;

        wctLayerMask:
          begin
            ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Assign(LResultBmp);

            if Assigned(ActiveChildForm.ChannelManager.LayerMaskPanel) then
            begin
              ActiveChildForm.ChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(
                0, 0, ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
            end;

            ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            if not ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
            begin
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Assign(LResultBmp);
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;
            end;
          end;
      end;
    end;
  end;

  // update thumbnails
  ActiveChildForm.UpdateThumbnailsBySelectedChannel;

  // show selection border, if any
  ActiveChildForm.ShowSelectionHandleBorder;
end;

procedure TfrmMain.mnitmSelectAllClick(Sender: TObject);
var
  LCmdAim           : TCommandAim;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  if frmRichTextEditor.Visible then
  begin
    frmRichTextEditor.rchedtRichTextEditor.SelectAll;
    frmRichTextEditor.Show;
  end
  else
  begin
    if Assigned(ActiveChildForm.Selection) then
    begin
      if ActiveChildForm.Selection.IsTranslated or
         ActiveChildForm.Selection.IsCornerStretched or
         ActiveChildForm.Selection.IsHorizFlipped or
         ActiveChildForm.Selection.IsVertFlipped or
         (ActiveChildForm.SelectionTransformation <> nil) then
      begin
        Exit;
      end;
    end
    else
    begin
      if (ActiveChildForm.SelectionTransformation <> nil) or
         (ActiveChildForm.Crop <> nil) then
      begin
        Exit;
      end;
    end;

    // Remerber the old selection for Undo/Redo if the selection is existed.
    if Assigned(ActiveChildForm.Selection) then
    begin
      if ActiveChildForm.SelectionCopy = nil then
      begin
        ActiveChildForm.CreateCopySelection;
      end;

      ActiveChildForm.SelectionCopy.AssignAllSelectionData(ActiveChildForm.Selection);
    end
    else
    begin
      if Assigned(ActiveChildForm.SelectionCopy) then
      begin
        ActiveChildForm.FreeCopySelection;
      end;
    end;

    ActiveChildForm.CreateSelectionForAll;

    // Create Undo/Redo
    LCmdAim := ActiveChildForm.GetCommandAimByCurrentChannel;

    LHistoryStatePanel := TgmSelectionStatePanel.Create(
      frmHistory.scrlbxHistory,
      dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
      LCmdAim,
      FMarqueeTool,
      sctSelectCanvas,
      ActiveChildForm.SelectionCopy,
      ActiveChildForm.Selection);

    ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);
  end;
end;

procedure TfrmMain.mnitmCommitSelectionClick(Sender: TObject);
var
  LCmdAim           : TCommandAim;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  if (ActiveChildForm.Selection = nil) or
     (ActiveChildForm.SelectionTransformation <> nil) or
     (ActiveChildForm.Crop <> nil) or
     frmRichTextEditor.Visible then
  begin
    Exit;
  end;

  if ActiveChildForm.SelectionCopy = nil then
  begin
    ActiveChildForm.CreateCopySelection;
  end;

  ActiveChildForm.SelectionCopy.AssignAllSelectionData(ActiveChildForm.Selection);
  ActiveChildForm.CommitSelection;

  // Create Undo/Redo
  LCmdAim := ActiveChildForm.GetCommandAimByCurrentChannel;

  spdbtnCommitSelection.Enabled := False;
  spdbtnDeselect.Enabled        := False;
  spdbtnDeleteSelection.Enabled := False;

  LHistoryStatePanel := TgmSelectionStatePanel.Create(
    frmHistory.scrlbxHistory,
    dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
    LCmdAim,
    FMarqueeTool,
    sctCommitSelection,
    ActiveChildForm.SelectionCopy,
    ActiveChildForm.Selection);

  ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);
end;

procedure TfrmMain.mnitmDeselectClick(Sender: TObject);
var
  LCmdAim           : TCommandAim;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  if (ActiveChildForm.Selection = nil) or
     (ActiveChildForm.SelectionTransformation <> nil) or
     (ActiveChildForm.Crop <> nil) or
     frmRichTextEditor.Visible then
  begin
    Exit;
  end;

  // Dupicate the old selection for Undo/Redo if the selection is existed.
  if ActiveChildForm.SelectionCopy = nil then
  begin
    ActiveChildForm.CreateCopySelection;
  end;

  ActiveChildForm.SelectionCopy.AssignAllSelectionData(ActiveChildForm.Selection);
  ActiveChildForm.CancelSelection;

  // Create Undo/Redo
  LCmdAim := ActiveChildForm.GetCommandAimByCurrentChannel;

  spdbtnCommitSelection.Enabled := False;
  spdbtnDeselect.Enabled        := False;
  spdbtnDeleteSelection.Enabled := False;

  LHistoryStatePanel := TgmSelectionStatePanel.Create(
    frmHistory.scrlbxHistory,
    dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
    LCmdAim,
    FMarqueeTool,
    sctDeselect,
    ActiveChildForm.SelectionCopy,
    ActiveChildForm.Selection);

  ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);
end;

procedure TfrmMain.mnitmDeleteSelectionClick(Sender: TObject);
var
  LCmdAim           : TCommandAim;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  if (ActiveChildForm.Selection = nil) or
     (ActiveChildForm.SelectionTransformation <> nil) or
     (ActiveChildForm.Crop <> nil) or
     frmRichTextEditor.Visible then
  begin
    Exit;
  end;

  if ActiveChildForm.SelectionCopy = nil then
  begin
    ActiveChildForm.CreateCopySelection;
  end;

  ActiveChildForm.SelectionCopy.AssignAllSelectionData(ActiveChildForm.Selection);
  ActiveChildForm.DeleteSelection;

  // Create Undo/Redo
  LCmdAim := ActiveChildForm.GetCommandAimByCurrentChannel;

  spdbtnCommitSelection.Enabled := False;
  spdbtnDeselect.Enabled        := False;
  spdbtnDeleteSelection.Enabled := False;

  LHistoryStatePanel := TgmSelectionStatePanel.Create(
    frmHistory.scrlbxHistory,
    dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
    LCmdAim,
    FMarqueeTool,
    sctDeleteSelection,
    ActiveChildForm.SelectionCopy,
    ActiveChildForm.Selection);

  ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);
end;

procedure TfrmMain.mnitmInvertSelectionClick(Sender: TObject);
var
  LCmdAim           : TCommandAim;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  if (ActiveChildForm.Selection = nil) or
     (ActiveChildForm.SelectionTransformation <> nil) or
     (ActiveChildForm.Crop <> nil) or
     frmRichTextEditor.Visible then
  begin
    Exit;
  end;

  if ActiveChildForm.SelectionCopy = nil then
  begin
    ActiveChildForm.CreateCopySelection;
  end;

  ActiveChildForm.SelectionCopy.AssignAllSelectionData(ActiveChildForm.Selection);
  ActiveChildForm.MakeSelectionInverse;

  // Create Undo/Redo
  LCmdAim := ActiveChildForm.GetCommandAimByCurrentChannel;

  LHistoryStatePanel := TgmSelectionStatePanel.Create(
    frmHistory.scrlbxHistory,
    dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
    LCmdAim,
    FMarqueeTool,
    sctSelectInverse,
    ActiveChildForm.SelectionCopy,
    ActiveChildForm.Selection);

  ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);

  // Draw selection border with handles.
  ActiveChildForm.UpdateSelectionHandleBorder;
end;

procedure TfrmMain.mnitmFeatherRadiusClick(Sender: TObject);
var
  LCmdAim           : TCommandAim;
  LHistoryStatePanel: TgmHistoryStatePanel;
  LOldSelectionCopy : TgmSelection;
begin
  LOldSelectionCopy := nil;

  if (ActiveChildForm.Selection = nil) or
     (ActiveChildForm.SelectionTransformation <> nil) or
     (ActiveChildForm.Crop <> nil) or
     frmRichTextEditor.Visible then
  begin
    Exit;
  end;

  frmFeatherSelection := TfrmFeatherSelection.Create(nil);
  try
    if frmFeatherSelection.ShowModal = id_OK then
    begin
      if Assigned(ActiveChildForm.Selection) then
      begin
        if (ActiveChildForm.Selection.IsTranslated      = False) and
           (ActiveChildForm.Selection.IsCornerStretched = False) and
           (ActiveChildForm.Selection.IsHorizFlipped    = False) and
           (ActiveChildForm.Selection.IsVertFlipped     = False) then
        begin
          Screen.Cursor := crHourGlass;
          try
            // Remember the old selection for Undo/Redo command.
            if ActiveChildForm.SelectionCopy = nil then
            begin
              ActiveChildForm.CreateCopySelection;
            end
            else
            begin
              LOldSelectionCopy := TgmSelection.Create;
              LOldSelectionCopy.AssignAllSelectionData(ActiveChildForm.SelectionCopy);
            end;

            ActiveChildForm.SelectionCopy.AssignAllSelectionData(ActiveChildForm.Selection);

            if ActiveChildForm.MakeSelectionFeather = True then
            begin
              // Create Undo/Redo
              LCmdAim := ActiveChildForm.GetCommandAimByCurrentChannel;

              LHistoryStatePanel := TgmSelectionStatePanel.Create(
                frmHistory.scrlbxHistory,
                dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
                LCmdAim,
                FMarqueeTool,
                sctFeatherSelection,
                ActiveChildForm.SelectionCopy,
                ActiveChildForm.Selection,
                ActiveChildForm.ChannelManager.SelectedAlphaChannelIndex);

              ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);
            end
            else
            begin
              if Assigned(LOldSelectionCopy) then
              begin
                ActiveChildForm.SelectionCopy.AssignAllSelectionData(LOldSelectionCopy);
                FreeAndNil(LOldSelectionCopy);
              end;
            end;
            
            // draw selection with borders
            ActiveChildForm.UpdateSelectionHandleBorder;

          finally
            Screen.Cursor := crDefault;
          end;
        end;
      end;
    end;
    
  finally
    FreeAndNil(frmFeatherSelection);
  end;

  if Assigned(ActiveChildForm.Selection) then
  begin
    if ActiveChildForm.tmrMarchingAnts.Enabled = False then
    begin
      ActiveChildForm.tmrMarchingAnts.Enabled := True;
    end;
  end;
end; 

procedure TfrmMain.mnitmColorRangeSelectionClick(Sender: TObject);
var
  LCmdAim           : TCommandAim;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  frmColorRangeSelection := TfrmColorRangeSelection.Create(nil);
  try
    if frmColorRangeSelection.ShowModal = idOK then
    begin
      Screen.Cursor := crHourGlass;
      try
        // Remerber the old selection for Undo/Redo if the selection is existed.
        if Assigned(ActiveChildForm.Selection) then
        begin
          if ActiveChildForm.SelectionCopy = nil then
          begin
            ActiveChildForm.CreateCopySelection;
          end;

          ActiveChildForm.SelectionCopy.AssignAllSelectionData(ActiveChildForm.Selection);
        end
        else
        begin
          if Assigned(ActiveChildForm.SelectionCopy) then
          begin
            ActiveChildForm.FreeCopySelection;
          end;
        end;

        ActiveChildForm.CreateSelectionByColorRange;

        // Create Undo/Redo
        LCmdAim := ActiveChildForm.GetCommandAimByCurrentChannel;

        LHistoryStatePanel := TgmSelectionStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          LCmdAim,
          FMarqueeTool,
          sctColorRangeSelection,
          ActiveChildForm.SelectionCopy,
          ActiveChildForm.Selection);

        ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);
      finally
        Screen.Cursor := crDefault;
      end;

      // update selection border
      ActiveChildForm.UpdateSelectionHandleBorder;
    end;
  finally
    FreeAndNil(frmColorRangeSelection);
  end;

  if Assigned(ActiveChildForm.Selection) then
  begin
    ActiveChildForm.RemoveMarchingAnts;
    ActiveChildForm.tmrMarchingAnts.Enabled := True;

    spdbtnCommitSelection.Enabled := True;
    spdbtnDeselect.Enabled        := True;
    spdbtnDeleteSelection.Enabled := True;
  end
  else
  begin
    ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;

    spdbtnCommitSelection.Enabled := False;
    spdbtnDeselect.Enabled        := False;
    spdbtnDeleteSelection.Enabled := False;
  end;
end;

procedure TfrmMain.mnitmFillClick(Sender: TObject);
begin
  if Assigned(ActiveChildForm.Selection) then
  begin
    ActiveChildForm.tmrMarchingAnts.Enabled := False;
  end;
  
  if Assigned(ActiveChildForm.SelectionHandleLayer) then
  begin
    ActiveChildForm.SelectionHandleLayer.Visible := False;
  end;
  
  if frmFill.ShowModal = idOK then
  begin
    ActiveChildForm.IsImageProcessed := True;

    if Assigned(ActiveChildForm.Selection) then
    begin
      ActiveChildForm.tmrMarchingAnts.Enabled := True;
    end;
    
    // update thumbnails
    ActiveChildForm.UpdateThumbnailsBySelectedChannel;
  end;

  if FMainTool = gmtMarquee then
  begin
    if MarqueeTool = mtMoveResize then
    begin
      if Assigned(ActiveChildForm.Selection) and
         Assigned(ActiveChildForm.SelectionHandleLayer) then
      begin
        ActiveChildForm.SelectionHandleLayer.Visible := True;
      end;
    end;
  end;
end;

procedure TfrmMain.StepImageAdjustment(Sender: TObject);
var
  LActionName        : string;
  LCmdAim            : TCommandAim;
  LHistoryStatePanel : TgmHistoryStatePanel;
begin
  // we could not process more than one alpha channel at a time
  if ActiveChildForm.ChannelManager.CurrentChannelType = wctAlpha then
  begin
    if not Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
    begin
      Exit;
    end;
  end;

  if ActiveChildForm.ChannelManager.CurrentChannelType in [
       wctRGB, wctRed, wctGreen, wctBlue] then
  begin
    // could not process on special layers
    if not (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
              lfBackground, lfTransparent]) then
    begin
      Exit;
    end;
  end;

  if Sender = mnitmInvert then
  begin
    // could not process on empty layers
    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsEmptyLayer then
    begin
      ShowCannotProcessEmptyLayerInfo(mnitmInvert);
      Exit;
    end;
  end
  else
  if Sender = mnitmDesaturate then
  begin
    // could not process on alpha channel, quick mask or layer mask
    if ActiveChildForm.ChannelManager.CurrentChannelType in
         [wctAlpha, wctQuickMask, wctLayerMask] then
    begin
      Exit;
    end
    else
    begin
      // could not process on empty layers
      if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsEmptyLayer then
      begin
        ShowCannotProcessEmptyLayerInfo(mnitmDesaturate);
        Exit;
      end;

      // only process on the layer with full color channels are selected
      if ActiveChildForm.ChannelManager.CurrentChannelType <> wctRGB then
      begin
        Exit;
      end;
    end;
  end;

  ActiveChildForm.IsImageProcessed := True;

  // prepare for Undo/Redo
  if Assigned(ActiveChildForm.Selection) then
  begin
    FBeforeProc.Assign(ActiveChildForm.Selection.CutOriginal);
  end
  else
  begin
    case ActiveChildForm.ChannelManager.CurrentChannelType of
      wctAlpha:
        begin
          if Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
          begin
            FBeforeProc.Assign(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
          end;
        end;

      wctQuickMask:
        begin
          if Assigned(ActiveChildForm.ChannelManager.QuickMaskPanel) then
          begin
            FBeforeProc.Assign(ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
          end;
        end;

      wctLayerMask:
        begin
          FBeforeProc.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
        end;

      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          if not ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
          begin
            FBeforeProc.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
            
            if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsMaskLinked then
            begin
              ReplaceAlphaChannelWithMask(FBeforeProc,
                ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
            end;
          end;
        end;
    end;
  end;

  if Assigned(ActiveChildForm.Selection) then
  begin
    ActiveChildForm.tmrMarchingAnts.Enabled := False;

    if Sender = mnitmInvert then
    begin
      LActionName := 'Invert';

      InvertBitmap32(ActiveChildForm.Selection.CutOriginal,
                     ActiveChildForm.ChannelManager.ChannelSelectedSet);
    end
    else
    if Sender = mnitmDesaturate then
    begin
      LActionName := 'Desaturate';
      Desaturate32(ActiveChildForm.Selection.CutOriginal);
    end;

    ActiveChildForm.ShowProcessedSelection;
    ActiveChildForm.RemoveMarchingAnts;
    ActiveChildForm.tmrMarchingAnts.Enabled := True;

    // need this two lines to update the mask channel thumbnail
    if Assigned(ActiveChildForm.ChannelManager.LayerMaskPanel) then
    begin
      ActiveChildForm.ChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(
        0, 0, ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
    end;

    if (FMainTool = gmtMarquee) and
       (MarqueeTool = mtMoveResize) then
    begin
      if Assigned(ActiveChildForm.SelectionHandleLayer) then
      begin
        ActiveChildForm.SelectionHandleLayer.Visible := True;
      end;
    end;
  end
  else
  begin
    case ActiveChildForm.ChannelManager.CurrentChannelType of
      wctAlpha:
        begin
          if Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
          begin
            if Sender = mnitmInvert then
            begin
              LActionName := 'Invert';
              
              InvertBitmap32(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                             ActiveChildForm.ChannelManager.ChannelSelectedSet);

              ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
            end;
          end;
        end;

      wctQuickMask:
        begin
          if Assigned(ActiveChildForm.ChannelManager.QuickMaskPanel) then
          begin
            if Sender = mnitmInvert then
            begin
              LActionName := 'Invert';

              InvertBitmap32(ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                             ActiveChildForm.ChannelManager.ChannelSelectedSet);

              ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Changed;
            end;
          end;
        end;

      wctLayerMask:
        begin
          if Sender = mnitmInvert then
          begin
            LActionName := 'Invert';

            InvertBitmap32(ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                           ActiveChildForm.ChannelManager.ChannelSelectedSet);

            ActiveChildForm.LayerPanelList.SelectedLayerPanel.UpdateMaskThumbnail;

            if Assigned(ActiveChildForm.ChannelManager.LayerMaskPanel) then
            begin
              ActiveChildForm.ChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(
                0, 0, ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
            end;

            ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;
          end;
        end;

      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          if Sender = mnitmInvert then
          begin
            LActionName := 'Invert';
            
            InvertBitmap32(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                           ActiveChildForm.ChannelManager.ChannelSelectedSet);
          end
          else
          if Sender = mnitmDesaturate then
          begin
            LActionName := 'Desaturate';
            Desaturate32(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
          end;

          ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;
        end;
    end;
  end;

  // update thumbnails
  ActiveChildForm.UpdateThumbnailsBySelectedChannel;

{ Create Undo/Redo }

  // Set up the process target and filling color.
  if Assigned(ActiveChildForm.Selection) then
  begin
    FAfterProc.Assign(ActiveChildForm.Selection.CutOriginal);
  end
  else
  begin
    case ActiveChildForm.ChannelManager.CurrentChannelType of
      wctAlpha:
        begin
          if Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
          begin
            FAfterProc.Assign(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
          end;
        end;

      wctQuickMask:
        begin
          if Assigned(ActiveChildForm.ChannelManager.QuickMaskPanel) then
          begin
            FAfterProc.Assign(ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
          end;
        end;

      wctLayerMask:
        begin
          FAfterProc.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
        end;

      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
               lfBackground, lfTransparent] then
          begin
            FAfterProc.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
            
            if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsMaskLinked then
            begin
              ReplaceAlphaChannelWithMask(FAfterProc,
                ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
            end;
          end;
        end;
    end;
  end;

  LCmdAim := ActiveChildForm.GetCommandAimByCurrentChannel;

  LHistoryStatePanel := TgmImageManipulatingStatePanel.Create(
    frmHistory.scrlbxHistory,
    dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
    LCmdAim,
    LActionName,
    FBeforeProc,
    FAfterProc,
    ActiveChildForm.Selection,
    ActiveChildForm.ChannelManager.SelectedAlphaChannelIndex);

  ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);
end; 

procedure TfrmMain.FlipImageClick(Sender: TObject);
var
  LFlipMode          : TgmFlipMode;
  LCmdAim            : TCommandAim;
  LCmdName           : string;
  LOldSelection      : TgmSelection;
  LHistoryStatePanel : TgmHistoryStatePanel;
begin
  LFlipMode := fmHorizontal;

  if ActiveChildForm.ChannelManager.CurrentChannelType = wctAlpha then
  begin
    if not Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
    begin
      MessageDlg('Could not process more than one alpha channels at a time.', mtError, [mbOK], 0);
      Exit;
    end;
  end;

  if Sender = mnitmHorizFlip then
  begin
    LFlipMode := fmHorizontal;
    LCmdName  := 'Flip Horizontal';
  end
  else
  if Sender = mnitmVertFlip then
  begin
    LFlipMode := fmVertical;
    LCmdName  := 'Flip Vertical';
  end;

  // Undo/Redo
  LOldSelection := nil;

  if Assigned(ActiveChildForm.Selection) then
  begin
    // For Undo/Redo Command
    LOldSelection := TgmSelection.Create;
    LOldSelection.AssignAllSelectionData(ActiveChildForm.Selection);

    ActiveChildForm.tmrMarchingAnts.Enabled := False;
    ActiveChildForm.Selection.FlipSelection(LFlipMode);
    ActiveChildForm.ShowProcessedSelection;
    ActiveChildForm.RemoveMarchingAnts;
    ActiveChildForm.tmrMarchingAnts.Enabled := True;

    // Undo/Redo
    LCmdAim := ActiveChildForm.GetCommandAimByCurrentChannel;

    LHistoryStatePanel := TgmFlipSelectionStatePanel.Create(
      frmHistory.scrlbxHistory,
      dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
      LCmdAim,
      LOldSelection,
      ActiveChildForm.Selection,
      LFlipMode,
      ActiveChildForm.ChannelManager.SelectedAlphaChannelIndex);

    FreeAndNil(LOldSelection);
  end
  else
  begin
    case ActiveChildForm.ChannelManager.CurrentChannelType of
      wctAlpha:
        begin
          if Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
          begin
            // For Undo/Redo Command
            FBeforeProc.Assign(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
            FlipBitmap(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap, LFlipMode);
            ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;

            // Undo/Redo
            FAfterProc.Assign(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
          end;
        end;

      wctQuickMask:
        begin
          if Assigned(ActiveChildForm.ChannelManager.QuickMaskPanel) then
          begin
            // For Undo/Redo Command
            FBeforeProc.Assign(ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
            FlipBitmap(ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap, LFlipMode);
            ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Changed;

            // Undo/Redo
            FAfterProc.Assign(ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
          end;
        end;

      wctLayerMask:
        begin
          // For Undo/Redo Command
          FBeforeProc.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
          FlipBitmap(ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap, LFlipMode);

          if Assigned(ActiveChildForm.ChannelManager.LayerMaskPanel) then
          begin
            ActiveChildForm.ChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(
              0, 0, ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
          end;

          ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;

          // Undo/Redo
          FAfterProc.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
        end;

      wctRGB:
        begin
          if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
               lfBackground, lfTransparent] then
          begin
            if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsMaskLinked then
            begin
              ReplaceAlphaChannelWithMask(
                ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
            end;

            // For Undo/Redo Command
            FBeforeProc.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

            FlipBitmap(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap, LFlipMode);

            // Undo/Redo
            FAfterProc.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

            if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask then
            begin
              FlipBitmap(ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp, LFlipMode);
            end;

            ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;
          end;
        end;
    end;

    // Undo/Redo
    LCmdAim := ActiveChildForm.GetCommandAimByCurrentChannel;

    LHistoryStatePanel := TgmImageManipulatingStatePanel.Create(
      frmHistory.scrlbxHistory,
      dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
      LCmdAim,
      LCmdName,
      FBeforeProc,
      FAfterProc,
      ActiveChildForm.Selection,
      ActiveChildForm.ChannelManager.SelectedAlphaChannelIndex);
  end;

  // updating thumbnails
  ActiveChildForm.UpdateThumbnailsBySelectedChannel;

  if Assigned(LHistoryStatePanel) then
  begin
    ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);
  end;
end; 

procedure TfrmMain.ChangeTransformMode(Sender: TObject);
var
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  if Assigned(ActiveChildForm.Selection) then
  begin
    if Assigned(ActiveChildForm.SelectionHandleLayer) then
    begin
      ActiveChildForm.DeleteSelectionHandleLayer;
    end;

    if Sender = mnitmDistortTransformation then
    begin
      if ActiveChildForm.SelectionTransformation <> nil then
      begin
        if ActiveChildForm.SelectionTransformation.TransformMode <> tmDistort then
        begin
          ActiveChildForm.FinishTransformation;
        end
        else
        begin
          Exit;
        end;
      end;

      mnitmDistortTransformation.Checked := True;

      if ActiveChildForm.SelectionTransformation = nil then
      begin
        ActiveChildForm.CreateSelectionTransformation(tmDistort);
      end;
    end
    else
    if Sender = mnitmRotateTransformation then
    begin
      if ActiveChildForm.SelectionTransformation <> nil then
      begin
        if ActiveChildForm.SelectionTransformation.TransformMode <> tmRotate then
        begin
          ActiveChildForm.FinishTransformation;
        end
        else
        begin
          Exit;
        end;
      end;

      mnitmRotateTransformation.Checked := True;

      if ActiveChildForm.SelectionTransformation = nil then
      begin
        ActiveChildForm.CreateSelectionTransformation(tmRotate);
      end;
    end
    else
    if Sender = mnitmScaleTransformation then
    begin
      if ActiveChildForm.SelectionTransformation <> nil then
      begin
        if ActiveChildForm.SelectionTransformation.TransformMode <> tmScale then
        begin
          ActiveChildForm.FinishTransformation;
        end
        else
        begin
          Exit;
        end;
      end;

      mnitmScaleTransformation.Checked := True;

      if ActiveChildForm.SelectionTransformation = nil then
      begin
        ActiveChildForm.CreateSelectionTransformation(tmScale);
      end;
    end;

    if ActiveChildForm.TransformLayer = nil then
    begin
      ActiveChildForm.CreateTransformLayer;
    end;

    if ActiveChildForm.SelectionTransformation <> nil then
    begin
      ActiveChildForm.TransformLayer.Bitmap.Clear($00000000);

      ActiveChildForm.SelectionTransformation.DrawOutline(
        ActiveChildForm.TransformLayer.Bitmap.Canvas,
        ActiveChildForm.TransformOffsetVector, pmNotXor);

      ActiveChildForm.TransformLayer.Bitmap.Changed;
      ActiveChildForm.ConnectTransformMouseEvents;

      // Undo/Redo
      LHistoryStatePanel := TgmTransformStatePanel.Create(
        frmHistory.scrlbxHistory,
        dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
        tctCreate,
        ActiveChildForm.SelectionTransformation.TransformMode,
        ActiveChildForm.Selection,
        nil,
        ActiveChildForm.SelectionTransformation);

      ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);

      // disable channel manager and path panel manager when selection transformation is created
      ActiveChildForm.ChannelManager.IsEnabled := False;
      ActiveChildForm.PathPanelList.IsEnabled  := False;
    end;
  end;
end;

procedure TfrmMain.mnitmImageSizeClick(Sender: TObject);
var
  LNewWidth, LNewHeight : Integer;
  LOldWidth, LOldHeight : Integer;
  LLayer                : TBitmapLayer;
  LShapeRegionLayerPanel: TgmShapeRegionLayerPanel;
  LRichTextLayerPanel   : TgmRichTextLayerPanel;
  LHistoryStatePanel    : TgmHistoryStatePanel;
begin
  frmImageSize := TfrmImageSize.Create(nil);
  try
    if frmImageSize.ShowModal = mrOK then
    begin
      LOldWidth  := ActiveChildForm.imgDrawingArea.Bitmap.Width;
      LOldHeight := ActiveChildForm.imgDrawingArea.Bitmap.Height;
      LNewWidth  := frmImageSize.NewWidth;
      LNewHeight := frmImageSize.NewHeight;

      if (LNewWidth <> LOldWidth) or (LNewHeight <> LOldHeight) then
      begin
        // create Undo/Redo first
        LHistoryStatePanel := TgmChangeImageSizeStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          LNewWidth,
          LNewHeight,
          frmImageSize.ResamplingOptions);

        ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);

        // mark the image has changed
        ActiveChildForm.IsImageProcessed := True;

        ActiveChildForm.imgDrawingArea.Bitmap.SetSize(LNewWidth, LNewHeight);

        ActiveChildForm.LayerPanelList.ChangeImageSizeForAllLayers(
          ActiveChildForm.imgDrawingArea, LNewWidth, LNewHeight,
          frmImageSize.ResamplingOptions);

        ActiveChildForm.FLayerTopLeft := ActiveChildForm.GetLayerTopLeft;

        // change the size of channels
        LLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[0]);

        ActiveChildForm.ChannelManager.ChangeChannelsSize(LLayer.Bitmap.Width,
                                                          LLayer.Bitmap.Height,
                                                          LLayer.Location);

        if FMainTool = gmtShape then
        begin
          if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
          begin
            LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

            if ActiveChildForm.ShapeOutlineLayer <> nil then
            begin
              ActiveChildForm.CalcShapeOutlineLayerOffsetVector;
              ActiveChildForm.ShapeOutlineLayer.Bitmap.Clear($00000000);

              with LShapeRegionLayerPanel do
              begin
                if ShapeOutlineList.Count > 0 then
                begin
                  ShapeOutlineList.DrawAllOutlines(ActiveChildForm.ShapeOutlineLayer.Bitmap.Canvas,
                  ActiveChildForm.OutlineOffsetVector, pmNotXor);

                  if FShapeRegionTool = srtMove then
                  begin
                    ShapeOutlineList.DrawShapesBoundary(
                      ActiveChildForm.ShapeOutlineLayer.Bitmap.Canvas,
                      HANDLE_RADIUS,
                      ActiveChildForm.OutlineOffsetVector,
                      pmNotXor);

                    ShapeOutlineList.DrawShapesBoundaryHandles(
                      ActiveChildForm.ShapeOutlineLayer.Bitmap.Canvas,
                      HANDLE_RADIUS,
                      ActiveChildForm.OutlineOffsetVector,
                      pmNotXor);
                  end;
                end;
              end;
            end;
          end;
        end;

        if FMainTool = gmtStandard then
        begin
          if ActiveChildForm.FHandleLayer <> nil then
          begin
            ActiveChildForm.FHandleLayer.Bitmap.Clear($00FFFFFF);

            ActiveChildForm.LayerPanelList.DrawSelectedFiguresHandles(ActiveChildForm.FHandleLayer.Bitmap,
              ActiveChildForm.FHandleLayerOffsetVector);
          end;
        end;

        if FMainTool = gmtTextTool then
        begin
          if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
          begin
            LRichTextLayerPanel := TgmRichTextLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

            if ActiveChildForm.RichTextHandleLayer <> nil then
            begin
              ActiveChildForm.RichTextHandleLayer.Bitmap.Clear($00000000);

              LRichTextLayerPanel.DrawRichTextBorder(
                ActiveChildForm.RichTextHandleLayer.Bitmap.Canvas,
                ActiveChildForm.RichTextHandleLayerOffsetVector);

              LRichTextLayerPanel.DrawRichTextBorderHandles(
                ActiveChildForm.RichTextHandleLayer.Bitmap.Canvas,
                ActiveChildForm.RichTextHandleLayerOffsetVector);
            end;
          end;
        end;

        // update display
        ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
      end;
    end;
  finally
    FreeAndNil(frmImageSize);
  end;
end;

procedure TfrmMain.mnitmCanvasSizeClick(Sender: TObject);
var
  LNewWidth, LNewHeight : Integer;
  LOldWidth, LOldHeight : Integer;
  LLayer                : TBitmapLayer;
  LShapeRegionLayerPanel: TgmShapeRegionLayerPanel;
  LRichTextLayerPanel   : TgmRichTextLayerPanel;
  LHistoryStatePanel    : TgmHistoryStatePanel;
begin
  frmCanvasSize := TfrmCanvasSize.Create(nil);
  try
    if frmCanvasSize.ShowModal = mrOK then
    begin
      LOldWidth  := ActiveChildForm.imgDrawingArea.Bitmap.Width;
      LOldHeight := ActiveChildForm.imgDrawingArea.Bitmap.Height;
      LNewWidth  := frmCanvasSize.NewWidth;
      LNewHeight := frmCanvasSize.NewHeight;

      if (LNewWidth <> LOldWidth) or (LNewHeight <> LOldHeight) then
      begin
        // create Undo/Redo first
        LHistoryStatePanel := TgmChangeCanvasSizeStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          LNewWidth,
          LNewHeight,
          frmCanvasSize.AnchorDirection,
          Color32(FGlobalBackColor));

        ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);

        // mark the image has changed
        ActiveChildForm.IsImageProcessed := True;

        ActiveChildForm.imgDrawingArea.Bitmap.SetSize(LNewWidth, LNewHeight);

        ActiveChildForm.LayerPanelList.ChangeCanvasSizeForAllLayers(
          ActiveChildForm.imgDrawingArea, LNewWidth, LNewHeight,
          frmCanvasSize.AnchorDirection, Color32(FGlobalBackColor) );

        ActiveChildForm.FLayerTopLeft := ActiveChildForm.GetLayerTopLeft;

        // change the canvas size of channels
        LLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[0]);
        
        ActiveChildForm.ChannelManager.ChangeChannelsCanvasSize(
          LLayer.Bitmap.Width, LLayer.Bitmap.Height, LLayer.Location,
          frmCanvasSize.AnchorDirection);

        if FMainTool = gmtShape then
        begin
          if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
          begin
            LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

            if ActiveChildForm.ShapeOutlineLayer <> nil then
            begin
              ActiveChildForm.CalcShapeOutlineLayerOffsetVector;
              ActiveChildForm.ShapeOutlineLayer.Bitmap.Clear($00000000);

              with LShapeRegionLayerPanel do
              begin
                if ShapeOutlineList.Count > 0 then
                begin
                  ShapeOutlineList.DrawAllOutlines(
                    ActiveChildForm.ShapeOutlineLayer.Bitmap.Canvas,
                    ActiveChildForm.OutlineOffsetVector, pmNotXor);

                  if FShapeRegionTool = srtMove then
                  begin
                    ShapeOutlineList.DrawShapesBoundary(
                      ActiveChildForm.ShapeOutlineLayer.Bitmap.Canvas,
                      HANDLE_RADIUS,
                      ActiveChildForm.OutlineOffsetVector,
                      pmNotXor);

                    ShapeOutlineList.DrawShapesBoundaryHandles(
                      ActiveChildForm.ShapeOutlineLayer.Bitmap.Canvas,
                      HANDLE_RADIUS,
                      ActiveChildForm.OutlineOffsetVector,
                      pmNotXor);
                  end;
                end;
              end;
            end;
          end;
        end;

        if FMainTool = gmtStandard then
        begin
          if ActiveChildForm.FHandleLayer <> nil then
          begin
            ActiveChildForm.FHandleLayer.Bitmap.Clear($00FFFFFF);

            ActiveChildForm.LayerPanelList.DrawSelectedFiguresHandles(
              ActiveChildForm.FHandleLayer.Bitmap, ActiveChildForm.FHandleLayerOffsetVector);
          end;
        end;

        if FMainTool = gmtTextTool then
        begin
          if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
          begin
            LRichTextLayerPanel := TgmRichTextLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

            if ActiveChildForm.RichTextHandleLayer <> nil then
            begin
              ActiveChildForm.RichTextHandleLayer.Bitmap.Clear($00000000);

              LRichTextLayerPanel.DrawRichTextBorder(
                ActiveChildForm.RichTextHandleLayer.Bitmap.Canvas,
                ActiveChildForm.RichTextHandleLayerOffsetVector);

              LRichTextLayerPanel.DrawRichTextBorderHandles(
                ActiveChildForm.RichTextHandleLayer.Bitmap.Canvas,
                ActiveChildForm.RichTextHandleLayerOffsetVector);
            end;
          end;
        end;

        // update display
        ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
      end;
    end;
  finally
    FreeAndNil(frmCanvasSize);
  end;
end;

procedure TfrmMain.RotateCanvas(Sender: TObject);
var
  LDeg                  : Integer;
  LRotateDirection      : TgmRotateDirection;
  LLayer                : TBitmapLayer;
  LShapeRegionLayerPanel: TgmShapeRegionLayerPanel;
  LRichTextLayerPanel   : TgmRichTextLayerPanel;
  LHistoryStatePanel    : TgmHistoryStatePanel;
begin
  LDeg             := 0;
  LRotateDirection := rdClockwise;
  
  // determine the rotate direction
  if (Sender = mnitm30dcw) or
     (Sender = mnitm45dcw) or
     (Sender = mnitm60dcw) or
     (Sender = mnitm90dcw) or
     (Sender = mnitm180dcw) then
  begin
    LRotateDirection := rdClockwise;
  end
  else
  if (Sender = mnitm30ducw) or
     (Sender = mnitm45ducw) or
     (Sender = mnitm60ducw) or
     (Sender = mnitm90ducw) or
     (Sender = mnitm180ducw) then
  begin
    LRotateDirection := rdCounterclockwise;
  end;

  // determine the rotate degrees
  if (Sender = mnitm30dcw) or (Sender = mnitm30ducw) then
  begin
    LDeg := 30;
  end
  else if (Sender = mnitm45dcw) or (Sender = mnitm45ducw) then
  begin
    LDeg := 45;
  end
  else if (Sender = mnitm60dcw) or (Sender = mnitm60ducw) then
  begin
    LDeg := 60;
  end
  else if (Sender = mnitm90dcw) or (Sender = mnitm90ducw) then
  begin
    LDeg := 90;
  end
  else if (Sender = mnitm180dcw) or (Sender = mnitm180ducw) then
  begin
    LDeg := 180;
  end
  else if Sender = mnitmRotateArbitrary then
  begin
    frmRotateCanvas := TfrmRotateCanvas.Create(nil);
    try
      if frmRotateCanvas.ShowModal = mrOK then
      begin
        LDeg             := frmRotateCanvas.RotateAngle;
        LRotateDirection := frmRotateCanvas.RotateDirection;
      end
      else
      begin
        Exit;
      end;
    finally
      FreeAndNil(frmRotateCanvas);
    end;
  end;

  // create Undo/Redo first
  LHistoryStatePanel := TgmRotateCanvasStatePanel.Create(
    frmHistory.scrlbxHistory,
    dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
    LDeg,
    LRotateDirection);

  ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);

  // rotate layers, first
  ActiveChildForm.LayerPanelList.RotateCanvasForAllLayers(
    ActiveChildForm.imgDrawingArea, LDeg, LRotateDirection,
    Color32(FGlobalBackColor));

  ActiveChildForm.FLayerTopLeft := ActiveChildForm.GetLayerTopLeft;

  // rotate channels
  LLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[0]);
  
  ActiveChildForm.ChannelManager.RotateChannels(LLayer.Bitmap.Width,
    LLayer.Bitmap.Height, LDeg, LRotateDirection, LLayer.Location);

  if FMainTool = gmtShape then
  begin
    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
    begin
      LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

      if ActiveChildForm.ShapeOutlineLayer <> nil then
      begin
        ActiveChildForm.CalcShapeOutlineLayerOffsetVector;
        ActiveChildForm.ShapeOutlineLayer.Bitmap.Clear($00000000);

        with LShapeRegionLayerPanel do
        begin
          if ShapeOutlineList.Count > 0 then
          begin
            ShapeOutlineList.DrawAllOutlines(
              ActiveChildForm.ShapeOutlineLayer.Bitmap.Canvas,
              ActiveChildForm.OutlineOffsetVector, pmNotXor);

            if FShapeRegionTool = srtMove then
            begin
              ShapeOutlineList.DrawShapesBoundary(
                ActiveChildForm.ShapeOutlineLayer.Bitmap.Canvas,
                HANDLE_RADIUS, ActiveChildForm.OutlineOffsetVector, pmNotXor);
                
              ShapeOutlineList.DrawShapesBoundaryHandles(
                ActiveChildForm.ShapeOutlineLayer.Bitmap.Canvas,
                HANDLE_RADIUS, ActiveChildForm.OutlineOffsetVector, pmNotXor);
            end;
          end;
        end;
      end;
    end;
  end;

  if FMainTool = gmtStandard then
  begin
    if ActiveChildForm.FHandleLayer <> nil then
    begin
      ActiveChildForm.FHandleLayer.Bitmap.Clear($00FFFFFF);

      ActiveChildForm.LayerPanelList.DrawSelectedFiguresHandles(
        ActiveChildForm.FHandleLayer.Bitmap,
        ActiveChildForm.FHandleLayerOffsetVector);
    end;
  end;

  if FMainTool = gmtTextTool then
  begin
    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
    begin
      LRichTextLayerPanel := TgmRichTextLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

      if ActiveChildForm.RichTextHandleLayer <> nil then
      begin
        ActiveChildForm.RichTextHandleLayer.Bitmap.Clear($00000000);

        LRichTextLayerPanel.DrawRichTextBorder(
          ActiveChildForm.RichTextHandleLayer.Bitmap.Canvas,
          ActiveChildForm.RichTextHandleLayerOffsetVector);

        LRichTextLayerPanel.DrawRichTextBorderHandles(
          ActiveChildForm.RichTextHandleLayer.Bitmap.Canvas,
          ActiveChildForm.RichTextHandleLayerOffsetVector);
      end;
    end;
  end;

  // update display
  ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
end;

procedure TfrmMain.mnitmCropClick(Sender: TObject);
begin
  ActiveChildForm.CommitCrop;
end;

procedure TfrmMain.mnitmIndexedColorClick(Sender: TObject);
begin
  if ActiveChildForm.LayerPanelList.Count > 1 then
  begin
    case MessageDlg('Flatten layers?', mtConfirmation, [mbOK, mbCancel], 0) of
      mrOK:
        begin
          mnitmFlattenImageClick(Sender);
        end;
        
      mrCancel:
        begin
          Exit;
        end;
    end;
  end
  else
  if ActiveChildForm.LayerPanelList.Count = 1 then
  begin
    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask then
    begin
      case MessageDlg('Merge layers?', mtConfirmation, [mbOK, mbCancel], 0) of
        mrOK:
          begin
            ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerProcessStage := lpsLayer;
            ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask         := False;

            ActiveChildForm.ChannelManager.DeleteLayerMaskPanel;
            ActiveChildForm.ChannelManager.DeselectAllChannels(HIDE_CHANNEL);
            ActiveChildForm.ChannelManager.SelectAllColorChannels;

            // update channel thumbnail
            ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);

            if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
            begin
              TgmShapeRegionLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel).SetThumbnailPosition;
            end
            else
            begin
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.ShowThumbnailByRightOrder;
            end;

            ActiveChildForm.LayerPanelList.UpdatePanelsState;
          end;

        mrCancel:
          begin
            Exit;
          end;
      end;
    end;
  end;

  // replace the transparent area with white
  MergeBitmapToColoredBackground(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap, clWhite32);
  FBeforeProc.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

  frmIndexedColor := TfrmIndexedColor.Create(nil);
  try
    case frmIndexedColor.ShowModal of
      mrOK:
        begin
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Assign(FAfterProc);
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
        end;

      mrCancel:
        begin
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Assign(FBeforeProc);
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
        end;
    end;
    
    ActiveChildForm.ChannelManager.DeselectAllChannels(HIDE_CHANNEL);
    ActiveChildForm.ChannelManager.SelectAllColorChannels;
    ActiveChildForm.LayerPanelList.SelectedLayerPanel.UpdateLayerPanelState;

    // update channel thumbnail
    ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
  finally
    FreeAndNil(frmIndexedColor);
  end;

  // Undo/Redo (can not create Undo/Redo for Now)
  // Clear UndoRedo
  ActiveChildForm.HistoryManager.DeleteAllHistoryStates;
  ActiveChildForm.HistoryManager.SelectSnapshotByIndex(0);
  ActiveChildForm.HistoryManager.UpdateAllPanelsState;
end;

procedure TfrmMain.mnitmHistogramClick(Sender: TObject);
begin
  frmHistogram := TfrmHistogram.Create(nil);
  try
    frmHistogram.ShowModal;
  finally
    FreeAndNil(frmHistogram);
  end;
  
  if ActiveChildForm.Selection <> nil then
  begin
    if ActiveChildForm.tmrMarchingAnts.Enabled = False then
    begin
      ActiveChildForm.tmrMarchingAnts.Enabled := True;
    end;
  end;
end;

procedure TfrmMain.mnitmCutClick(Sender: TObject);
var
  LCmdAim           : TCommandAim;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  if ActiveChildForm <> nil then
  begin
    if (ActiveChildForm.SelectionTransformation <> nil) or
       (ActiveChildForm.Crop <> nil) then
    begin
      Exit;
    end;
  end;

  if frmRichTextEditor.Visible then
  begin
    if Assigned(FSelectionClipboard) then
    begin
      FreeAndNil(FSelectionClipboard);
    end;

    frmRichTextEditor.rchedtRichTextEditor.CutToClipboard;
    frmRichTextEditor.Show;
  end
  else
  begin
    // we cannot cut in special layers
    if ActiveChildForm.ChannelManager.CurrentChannelType in [
         wctRGB, wctRed, wctGreen, wctBlue] then
    begin
      if not (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
                lfBackground, lfTransparent]) then
      begin
        Exit;
      end;
    end;

    Clipboard.Clear;

    if Assigned(ActiveChildForm.Selection) then
    begin
      // Create Undo/Redo first.
      case ActiveChildForm.ChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            LCmdAim := caAlphaChannel;
          end;

        wctQuickMask:
          begin
            LCmdAim := caQuickMask;
          end;
          
        wctLayerMask:
          begin
            LCmdAim := caLayerMask;
          end;
          
      else
        LCmdAim := caLayer;
      end;

      LHistoryStatePanel := TgmCutPixelsStatePanel.Create(
        frmHistory.scrlbxHistory,
        dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
        LCmdAim,
        ActiveChildForm.Selection,
        FSelectionClipboard,
        ActiveChildForm.ChannelManager.SelectedAlphaChannelIndex);

      ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);

      // Cutting Selection
      DuplicateSelection;
      ActiveChildForm.DeleteSelection;
      ActiveChildForm.IsImageProcessed := True;
      UpdateMarqueeOptions;
    end;
  end;
end;

procedure TfrmMain.mnitmCopyClick(Sender: TObject);
var
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  if ActiveChildForm <> nil then
  begin
    if (ActiveChildForm.SelectionTransformation <> nil) or
       (ActiveChildForm.Crop <> nil) then
    begin
      Exit;
    end;
  end;

  if frmRichTextEditor.Visible then
  begin
    if Assigned(FSelectionClipboard) then
    begin
      FreeAndNil(FSelectionClipboard);
    end;

    frmRichTextEditor.rchedtRichTextEditor.CopyToClipboard;
    frmRichTextEditor.Show;
  end
  else
  begin
    Clipboard.Clear;
    
    if Assigned(ActiveChildForm.Selection) then
    begin
      if (ActiveChildForm.ChannelManager.CurrentChannelType in [wctAlpha, wctQuickMask, wctLayerMask]) or
         (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent]) then
      begin
        // Create Undo/Redo first.
        LHistoryStatePanel := TgmCopyPixelsStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          ActiveChildForm.Selection,
          FSelectionClipboard);

        ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);

        // Then copy pixels.
        DuplicateSelection;
      end;
    end;
  end;
end;

procedure TfrmMain.mnitmPasteClick(Sender: TObject);
var
  LSelectionCopy        : TgmSelection;
  LCmdAim               : TCommandAim;
  LHistoryStatePanel    : TgmHistoryStatePanel;
  LPastedLayerIndex     : Integer;
  LBeforePasteLayerIndex: Integer;
  LBackgroundBmp        : TBitmap32;
begin
  LSelectionCopy := nil;
  LCmdAim        := caNone;

  if ActiveChildForm <> nil then
  begin
    if (ActiveChildForm.Crop <> nil) or
       (ActiveChildForm.SelectionTransformation <> nil) then
    begin
      Exit;
    end;
  end;

  if frmRichTextEditor.Visible then
  begin
    frmRichTextEditor.rchedtRichTextEditor.PasteFromClipboard;
    frmRichTextEditor.Show;
  end
  else
  begin
    LBackgroundBmp := TBitmap32.Create;
    try
      if Assigned(FSelectionClipboard) then
      begin
        // Remember the old selection for Undo/Redo, if it is existed.
        if Assigned(ActiveChildForm.Selection) then
        begin
          LSelectionCopy := TgmSelection.Create;
          LSelectionCopy.AssignAllSelectionData(ActiveChildForm.Selection);
        end;

        case ActiveChildForm.ChannelManager.CurrentChannelType of
          wctAlpha:
            begin
              LCmdAim := caAlphaChannel;

              if Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
              begin
                LBackgroundBmp.Assign(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
              end;
            end;

          wctQuickMask:
            begin
              LCmdAim := caQuickMask;

              if Assigned(ActiveChildForm.ChannelManager.QuickMaskPanel) then
              begin
                LBackgroundBmp.Assign(ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
              end;
            end;

          wctLayerMask:
            begin
              LCmdAim := caLayerMask;
              LBackgroundBmp.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
            end;

          wctRGB, wctRed, wctGreen, wctBlue:
            begin
              LCmdAim:= caLayer;
              LBackgroundBmp.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
            end;
        end;

        // commit the old selection if any
        ActiveChildForm.CommitSelection;

        // doing paste
        if PasteSelection = True then
        begin
          LPastedLayerIndex      := ActiveChildForm.LayerPanelList.CurrentIndex;
          LBeforePasteLayerIndex := LPastedLayerIndex - 1;
        end
        else
        begin
          LPastedLayerIndex      := ActiveChildForm.LayerPanelList.CurrentIndex;
          LBeforePasteLayerIndex := ActiveChildForm.LayerPanelList.CurrentIndex;;
        end;

        ActiveChildForm.IsImageProcessed := True;
        UpdateMarqueeOptions;

        // create Undo/Redo for Paste

        LHistoryStatePanel := TgmPastePixelsStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX], LCmdAim,
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerName.Caption,
          LPastedLayerIndex,
          LBeforePasteLayerIndex,
          ActiveChildForm.ChannelManager.SelectedAlphaChannelIndex,
          LSelectionCopy,
          LBackgroundBmp);

        ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);
      end;
    finally
      LBackgroundBmp.Free;
    end;
  end;
end;

procedure TfrmMain.mnitmPrintOptionsClick(Sender: TObject);
begin
  if ActiveChildForm <> nil then
  begin
    if frmRichTextEditor.Visible or
       (ActiveChildForm.SelectionTransformation <> nil) or
       (ActiveChildForm.Crop <> nil) then
    begin
      Exit;
    end;
  end;

  frmPrintOptions.ShowModal;
end;

procedure TfrmMain.mnitmPrintPreviewClick(Sender: TObject);
begin
  frmPrintPreview.Left   := 0;
  frmPrintPreview.Top    := 0;
  frmPrintPreview.Width  := Screen.Width;
  frmPrintPreview.Height := Screen.Height - 30;
  frmPrintPreview.ShowModal;
end; 

procedure TfrmMain.mnitmPageSetupClick(Sender: TObject);
begin
  if ActiveChildForm <> nil then
  begin
    if frmRichTextEditor.Visible or
       (ActiveChildForm.SelectionTransformation <> nil) or
       (ActiveChildForm.Crop <> nil) then
    begin
      Exit;
    end;
  end;
  
  if PrinterSetupDialog.Execute then
  begin
    { Calling these routines must after the printer setup process is complete,
      for making the print preview to take effect. }

    frmPrintPreview.prntprvwPreview.BeginDoc;
    frmPrintPreview.prntprvwPreview.EndDoc;
  end;
end;

procedure TfrmMain.mnitmPrintImageClick(Sender: TObject);
begin
  if ActiveChildForm <> nil then
  begin
    if frmRichTextEditor.Visible or
       (ActiveChildForm.SelectionTransformation <> nil) or
       (ActiveChildForm.Crop <> nil) then
    begin
      Exit;
    end;
  end;

  frmPrintPreview.DrawBitmapOnPreview;

  if frmPrintPreview.prntprvwPreview.State = psReady then
  begin
    if PrintDialog.Execute then
    begin
      frmPrintPreview.prntprvwPreview.Print;
    end;
  end;
end;

procedure TfrmMain.mnitmSaveAllClick(Sender: TObject);
var
  i       : Integer;
  TempForm: TfrmChild;
begin
  if MDIChildCount > -1 then
  begin
    for i := MDIChildCount - 1 downto 0 do
    begin
      TempForm := TfrmChild(MDIChildren[i]);
      TempForm.SaveNamedFile;
    end;
  end;
end;

procedure TfrmMain.CreateANewAdjustmentLayer(Sender: TObject);
begin
  CreateFillOrAdjustmentLayer(Sender);
end;

procedure TfrmMain.CreateANewFillLayer(Sender: TObject);
begin
  CreateFillOrAdjustmentLayer(Sender);
end; 

procedure TfrmMain.ArrangeLayer(Sender: TObject);
var
  LCurIndex, LNewIndex  : Integer;
  LLayer                : TBitmapLayer;
  LLayerArrangementStyle: TgmLayerArrangementStyle;
  LHistoryStatePanel    : TgmHistoryStatePanel;
begin
  LNewIndex              := -1;
  LLayerArrangementStyle := lasBringToFront;

  if ActiveChildForm <> nil then
  begin
    if frmRichTextEditor.Visible or
       (ActiveChildForm.SelectionTransformation <> nil) or
       (ActiveChildForm.Crop <> nil) then
    begin
      Exit;
    end;
  end;

  // deselect all movable figures before moving layers
  if High(ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray) > (-1) then
  begin
    ActiveChildForm.LayerPanelList.DeselectAllFiguresOnFigureLayer;

    if ActiveChildForm.FHandleLayer <> nil then
    begin
      ActiveChildForm.FHandleLayer.Bitmap.Clear($00FFFFFF);
    end;

    UpdateToolsOptions;
  end;

  if ActiveChildForm.LayerPanelList.IsAllowRefreshLayerPanels then
  begin
    ActiveChildForm.LayerPanelList.HideAllLayerPanels;
  end;

  LCurIndex := ActiveChildForm.LayerPanelList.CurrentIndex;
  LLayer   := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[LCurIndex]);

  if Sender = mnitmBringLayerToFront then
  begin
    LNewIndex := ActiveChildForm.LayerPanelList.Count - 1;

    // because there are other special layers, so we can't use BringToFront() method directly
    LLayer.Index           := LNewIndex;
    LLayerArrangementStyle := lasBringToFront;
  end
  else
  if Sender = mnitmBringLayerForward then
  begin
    LNewIndex              := LCurIndex + 1;
    LLayer.Index           := LNewIndex;
    LLayerArrangementStyle := lasBringForward;
  end
  else
  if Sender = mnitmSendLayerBackward then
  begin
    LNewIndex              := LCurIndex - 1;
    LLayer.Index           := LNewIndex;
    LLayerArrangementStyle := lasSendBackward;
  end
  else
  if Sender = mnitmSendLayerToBack then
  begin
    LNewIndex := 0;
    LLayer.SendToBack;
    LLayerArrangementStyle := lasSendToBack;
  end;

  ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
  ActiveChildForm.LayerPanelList.Move(LCurIndex, LNewIndex);
  ActiveChildForm.LayerPanelList.CurrentIndex := LNewIndex;

  if ActiveChildForm.LayerPanelList.IsAllowRefreshLayerPanels then
  begin
    ActiveChildForm.LayerPanelList.ShowAllLayerPanels;
  end;

  // Undo/Redo
  LHistoryStatePanel := TgmArrangeLayerStatePanel.Create(
    frmHistory.scrlbxHistory,
    dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
    LCurIndex,
    LNewIndex,
    LLayerArrangementStyle);

  ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);

  ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
end;

procedure TfrmMain.mnitmMergeVisibleLayersClick(Sender: TObject);
var
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  if ActiveChildForm <> nil then
  begin
    if frmRichTextEditor.Visible or
       (ActiveChildForm.SelectionTransformation <> nil) or
       (ActiveChildForm.Crop <> nil) then
    begin
      Exit;
    end;
  end;

  Screen.Cursor := crHourGlass;
  try
    // deselect all movable figures before merging layers
    if High(ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray) > (-1) then
    begin
      ActiveChildForm.LayerPanelList.DeselectAllFiguresOnFigureLayer;

      if ActiveChildForm.FHandleLayer <> nil then
      begin
        ActiveChildForm.FHandleLayer.Bitmap.Clear($00FFFFFF);
      end;

      UpdateToolsOptions;
    end;

    // create Undo/Redo first
    LHistoryStatePanel := TgmMergeVisibleLayersStatePanel.Create(
      frmHistory.scrlbxHistory,
      dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX]);

    ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);

    // merge visible layers
    ActiveChildForm.LayerPanelList.MergeVisble;
    ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;

    frmLayer.scrlbxLayers.Update;
    frmLayer.tlbtnAddMask.Enabled := not ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfrmMain.mnitmMergeDownClick(Sender: TObject);
var
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  if ActiveChildForm <> nil then
  begin
    if frmRichTextEditor.Visible or
       (ActiveChildForm.SelectionTransformation <> nil) or
       (ActiveChildForm.Crop <> nil) then
    begin
      Exit;
    end;
  end;

  Screen.Cursor := crHourGlass;
  try
    // deselect all movable figures before merging layers
    if High(ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray) > (-1) then
    begin
      ActiveChildForm.LayerPanelList.DeselectAllFiguresOnFigureLayer;

      if ActiveChildForm.FHandleLayer <> nil then
      begin
        ActiveChildForm.FHandleLayer.Bitmap.Clear($00FFFFFF);
      end;

      UpdateToolsOptions;
    end;

    // create Undo/Redo first
    LHistoryStatePanel := TgmMergeLayerDownStatePanel.Create(
      frmHistory.scrlbxHistory,
      dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX]);

    ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);

    // merge layer down
    ActiveChildForm.LayerPanelList.MergeDown;
    ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;

    frmLayer.scrlbxLayers.Update;
    frmLayer.tlbtnAddMask.Enabled := not ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfrmMain.mnitmDuplicateLayerClick(Sender: TObject);
var
  LLayerPanel       : TgmLayerPanel;
  LIndex            : Integer;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  frmDuplicateLayer := TfrmDuplicateLayer.Create(nil);
  try
    if frmDuplicateLayer.ShowModal = mrOK then
    begin

      Screen.Cursor := crHourGlass;
      try
        if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfFigure then
        begin
          if ActiveChildForm.LayerPanelList.SelectedFigureCountOnFigureLayer > 0 then
          begin
            ActiveChildForm.LayerPanelList.DeselectAllFiguresOnFigureLayer;
          end;

          if ActiveChildForm.FHandleLayer <> nil then
          begin
            ActiveChildForm.FHandleLayer.Bitmap.Clear($00FFFFFF);
            ActiveChildForm.FHandleLayer.Bitmap.Changed;
          end;
        end;

        LIndex := ActiveChildForm.LayerPanelList.CurrentIndex + 1;

        LLayerPanel := ActiveChildForm.LayerPanelList.SelectedLayerPanel.DuplicateCurrentLayerPanel(
          frmLayer.scrlbxLayers, ActiveChildForm.imgDrawingArea.Layers, LIndex,
          frmDuplicateLayer.DuplicatedLayerName);

        ActiveChildForm.LayerPanelList.InsertLayerPanelToList(LIndex, LLayerPanel);

        // Undo/Redo
        LHistoryStatePanel := TgmDuplicateLayerStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          ActiveChildForm.LayerPanelList.CurrentIndex,
          ActiveChildForm.LayerPanelList.CurrentIndex - 1,
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerName.Caption);

        ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);
      finally
        Screen.Cursor := crDefault;
      end;
      
    end;
  finally
    FreeAndNil(frmDuplicateLayer);
  end;
end;

procedure TfrmMain.mnitmDeleteLayerClick(Sender: TObject);
begin
  ActiveChildForm.DeleteCurrentLayer;
end; 

procedure TfrmMain.mnitmAboutClick(Sender: TObject);
begin
  ShowGraphicsMagicAbout;
end;

procedure TfrmMain.mnitmLayerPropertiesClick(Sender: TObject);
var
  LOldName          : string;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  frmLayerProperties := TfrmLayerProperties.Create(nil);
  try
    with frmLayerProperties do
    begin
      edtLayerName.Text := ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerName.Caption;
      LOldName          := edtLayerName.Text;

      if ShowModal = mrOK then
      begin
        if edtLayerName.Text <> '' then
        begin
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.SetLayerName(edtLayerName.Text);
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsRenamed := True;

          // Undo/Redo
          LHistoryStatePanel := TgmLayerPropertiesStatePanel.Create(
            frmHistory.scrlbxHistory,
            dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
            LOldName,
            ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerName.Caption);

          ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);
        end;
      end;
    end;
  finally
    FreeAndNil(frmLayerProperties);
  end;
end;

procedure TfrmMain.mnitmGimpAutoLevelsClick(Sender: TObject);
var
  LGimpLevelsTool : TgmLevelsTool;
  LGimpHistogram  : TgmGimpHistogram;
  LBmp            : TBitmap32;
begin
  if (ActiveChildForm.SelectionTransformation <> nil) or
     frmRichTextEditor.Visible or
     (ActiveChildForm.Crop <> nil) then
  begin
    Exit;
  end;

  // we could not process more than one alpha channel at a time
  if ActiveChildForm.ChannelManager.CurrentChannelType = wctAlpha then
  begin
    if not Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
    begin
      Exit;
    end;
  end;

  // cannot process special layers
  if ActiveChildForm.ChannelManager.CurrentChannelType in [
       wctRGB, wctRed, wctGreen, wctBlue] then
  begin
    if not (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
              lfBackground, lfTransparent]) then
    begin
      Exit;
    end;

    // we cannot process empty images
    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsEmptyLayer then
    begin
      ShowCannotProcessEmptyLayerInfo(mnitmGimpAutoLevels);
      Exit;
    end;
  end;

  if Assigned(ActiveChildForm.Selection) then
  begin
    FBeforeProc.Assign(ActiveChildForm.Selection.CutOriginal); // For Undo/Redo

    LGimpLevelsTool := TgmLevelsTool.Create(ActiveChildForm.Selection.CutOriginal);
    try
      LGimpHistogram := TgmGimpHistogram.Create;
      try
        LGimpHistogram.gimp_histogram_calculate(ActiveChildForm.Selection.CutOriginal);
        LGimpLevelsTool.LevelsStretch(LGimpHistogram);

        LGimpLevelsTool.Map(ActiveChildForm.Selection.CutOriginal,
                            ActiveChildForm.ChannelManager.ChannelSelectedSet);

        if ActiveChildForm.ChannelManager.CurrentChannelType in
             [wctAlpha, wctQuickMask, wctLayerMask] then
        begin
          Desaturate32(ActiveChildForm.Selection.CutOriginal);
        end;

        ActiveChildForm.ShowProcessedSelection;
        ActiveChildForm.tmrMarchingAnts.Enabled := True;

        // need this two lines to update the mask channel thumbnail
        if Assigned(ActiveChildForm.ChannelManager.LayerMaskPanel) then
        begin
          ActiveChildForm.ChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(
            0, 0, ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
        end;
      finally
        LGimpHistogram.Free;
      end;
    finally
      LGimpLevelsTool.Free;
    end;
  end
  else
  begin
    case ActiveChildForm.ChannelManager.CurrentChannelType of
      wctAlpha:
        begin
          if Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
          begin
            // for Undo/Redo
            FBeforeProc.Assign(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);

            LGimpLevelsTool := TgmLevelsTool.Create(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
            try
              LGimpHistogram := TgmGimpHistogram.Create;
              try
                LGimpHistogram.gimp_histogram_calculate(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
                LGimpLevelsTool.LevelsStretch(LGimpHistogram);

                LBmp := TBitmap32.Create;
                try
                  LBmp.Assign(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
                  LGimpLevelsTool.Map(LBmp, ActiveChildForm.ChannelManager.ChannelSelectedSet);
                  ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Assign(LBmp);
                  ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
                finally
                  LBmp.Free;
                end;

              finally
                LGimpHistogram.Free;
              end;
            finally
              LGimpLevelsTool.Free;
            end;
          end;
        end;

      wctQuickMask:
        begin
          if Assigned(ActiveChildForm.ChannelManager.QuickMaskPanel) then
          begin
            // for Undo/Redo
            FBeforeProc.Assign(ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);

            LGimpLevelsTool := TgmLevelsTool.Create(ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
            try
              LGimpHistogram := TgmGimpHistogram.Create;
              try
                LGimpHistogram.gimp_histogram_calculate(ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
                LGimpLevelsTool.LevelsStretch(LGimpHistogram);

                LBmp := TBitmap32.Create;
                try
                  LBmp.Assign(ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
                  LGimpLevelsTool.Map(LBmp, ActiveChildForm.ChannelManager.ChannelSelectedSet);
                  ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.Assign(LBmp);
                  ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Changed;
                finally
                  LBmp.Free;
                end;

              finally
                LGimpHistogram.Free;
              end;
            finally
              LGimpLevelsTool.Free;
            end;
          end;
        end;

      wctLayerMask:
        begin
          // For Undo/Redo
          FBeforeProc.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);

          LGimpLevelsTool := TgmLevelsTool.Create(
            ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
            
          try
            LGimpHistogram := TgmGimpHistogram.Create;
            try
              LGimpHistogram.gimp_histogram_calculate(
                ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
                
              LGimpLevelsTool.LevelsStretch(LGimpHistogram);

              LBmp := TBitmap32.Create;
              try
                LBmp.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
                LGimpLevelsTool.Map(LBmp, ActiveChildForm.ChannelManager.ChannelSelectedSet);
                ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Assign(LBmp);
              finally
                LBmp.Free;
              end;

              // update the mask channel in Channel Manager
              if Assigned(ActiveChildForm.ChannelManager.LayerMaskPanel) then
              begin
                ActiveChildForm.ChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(
                  0, 0, ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
              end;

              ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;

            finally
              LGimpHistogram.Free;
            end;
          finally
            LGimpLevelsTool.Free;
          end;
        end;

      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
               lfBackground, lfTransparent] then
          begin
            // For Undo/Redo
            FBeforeProc.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

            if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsMaskLinked then
            begin
              ReplaceAlphaChannelWithMask(FBeforeProc,
                ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
            end;

            LGimpLevelsTool := TgmLevelsTool.Create(
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
              
            try
              LGimpHistogram := TgmGimpHistogram.Create;
              try
                LGimpHistogram.gimp_histogram_calculate(
                  ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
                  
                LGimpLevelsTool.LevelsStretch(LGimpHistogram);
                
                LGimpLevelsTool.Map(
                  ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                  ActiveChildForm.ChannelManager.ChannelSelectedSet);

                ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;
              finally
                LGimpHistogram.Free;
              end;
            finally
              LGimpLevelsTool.Free;
            end;
          end;
        end;
    end;
  end;

  // update thumbnails
  ActiveChildForm.UpdateThumbnailsBySelectedChannel;

  CreateAutoLevelsUndoRedoCommand;
  ActiveChildForm.IsImageProcessed := True;
end; 

procedure TfrmMain.mnitmUndoRedoClick(Sender: TObject);
begin
  case ActiveChildForm.HistoryManager.CommandState of
    csUndo:
      begin
        ActiveChildForm.HistoryManager.RollbackCommand;
      end;

    csRedo:
      begin
        ActiveChildForm.HistoryManager.ExecuteCommand;
      end;
  end;
end;

procedure TfrmMain.mnitmLastFilterClick(Sender: TObject);
var
  LPluginInfo: TgmPluginInfo;
begin
  if Assigned(ActiveChildForm.SelectionTransformation) or
     Assigned(ActiveChildForm.Crop) or
     frmRichTextEditor.Visible then
  begin
    Exit;
  end;

  if ActiveChildForm.ChannelManager.CurrentChannelType in [
       wctRGB, wctRed, wctGreen, wctBlue] then
  begin
    if not (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
              lfBackground, lfTransparent]) then
    begin
      Exit;
    end;
  end;

  if Assigned(FLastFilterMenuItem) then
  begin
    LPluginInfo := FGMPluginInfoList.GetPluginInfoByMenuItem(FLastFilterMenuItem);
    LPluginInfo.UpdatePluginMenuEnableState(ActiveChildForm.ChannelManager.CurrentChannelType);

    if LPluginInfo.PluginMenu.Enabled then
    begin
      ExecuteFilters(FLastFilterMenuItem);
    end;
  end;
end;

procedure TfrmMain.mnitmStepBackwardClick(Sender: TObject);
begin
  ActiveChildForm.HistoryManager.RollbackCommand;
end;

procedure TfrmMain.mnitmStepforewardClick(Sender: TObject);
begin
  ActiveChildForm.HistoryManager.ExecuteCommand;
end; 

procedure TfrmMain.mnitmGeneralPreferencesClick(Sender: TObject);
begin
  frmPreferences := TfrmPreferences.Create(nil);
  try
    if frmPreferences.ShowModal = mrOK then
    begin
      if ActiveChildForm <> nil then
      begin
        ActiveChildForm.HistoryManager.MaxStateCount := frmPreferences.HistoryStatesCount;
      end;
    end;
  finally
    FreeAndNil(frmPreferences);
  end;
end;

procedure TfrmMain.mnitmShowSplashClick(Sender: TObject);
begin
  frmSplash := TfrmSplash.Create(nil);
  try
    frmSplash.imgSplash.Cursor := crHandPoint;
    frmSplash.ShowModal;
  finally
    FreeAndNil(frmSplash);
  end;
end;

procedure TfrmMain.mnitmSoftwarePageCHClick(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar('http://www.mandrillsoft.com/ch/software.html'), nil, nil, SW_NORMAL);
end; 

procedure TfrmMain.mnitmFiltersUpdateClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    // delete all filters info
    FreeAndNil(FGMPluginInfoList);
    FreeAndNil(FFilterCategoryMenuList);
    FLastFilterMenuItem := nil;
    mnitmLastFilter.Caption := 'Last Filter';

    // reload filters
    FGMPluginInfoList       := TgmPluginInfoList.Create;
    FFilterCategoryMenuList := TgmCategoryMenuItemList.Create;
    InitFilterMenuItem;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfrmMain.mnitmFiltersPageCHClick(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar('http://www.mandrillsoft.com/ch/filters.html'), nil, nil, SW_NORMAL);
end;

procedure TfrmMain.mnitmFiltersPageENClick(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar('http://www.mandrillsoft.com/en/filters.html'), nil, nil, SW_NORMAL);
end; 

procedure TfrmMain.mnitmSoftwarePageENClick(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar('http://www.mandrillsoft.com/en/software.html'), nil, nil, SW_NORMAL);
end;

procedure TfrmMain.mnitmDownloadCHClick(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar('http://www.mandrillsoft.com/ch/codecenter.html'), nil, nil, SW_NORMAL);
end;

procedure TfrmMain.mnitmDownloadENClick(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar('http://www.mandrillsoft.com/en/codecenter.html'), nil, nil, SW_NORMAL);
end;

procedure TfrmMain.mnitmDownloadSourceCodeAtSourceForgeClick(
  Sender: TObject);
begin
  ShellExecute(0, 'open', PChar('http://graphicsmagic.sourceforge.net/'), nil, nil, SW_NORMAL);
end;

procedure TfrmMain.mnitmOptimalCropClick(Sender: TObject);
begin
  ActiveChildForm.ExecuteOptimalCrop;
end;

procedure TfrmMain.mnitmApplyImageClick(Sender: TObject);
var
  LResultBmp : TBitmap32;
begin
  LResultBmp := nil;

  frmApplyImage := TfrmApplyImage.Create(nil);
  try
    case frmApplyImage.ShowModal of
      idOK:
        begin
          ActiveChildForm.IsImageProcessed := True;
          LResultBmp                       := FAfterProc;
        end;

      idCancel:
        begin
          LResultBmp := FBeforeProc;
        end;
    end;

    if Assigned(LResultBmp) then
    begin
      if Assigned(ActiveChildForm.Selection) then
      begin
        ActiveChildForm.Selection.CutOriginal.Assign(LResultBmp);
        ActiveChildForm.ShowProcessedSelection;
        ActiveChildForm.RemoveMarchingAnts;
        ActiveChildForm.tmrMarchingAnts.Enabled := True;
      end
      else
      begin
        case ActiveChildForm.ChannelManager.CurrentChannelType of
          wctAlpha:
            begin
              if Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
              begin
                ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Assign(LResultBmp);
                ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
              end;
            end;

          wctLayerMask:
            begin
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Assign(LResultBmp);

              if Assigned(ActiveChildForm.ChannelManager.LayerMaskPanel) then
              begin
                ActiveChildForm.ChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(
                  0, 0, ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
              end;

              ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;
            end;

          wctRGB, wctRed, wctGreen, wctBlue:
            begin
              // not on special layers...
              if not ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
              begin
                ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Assign(LResultBmp);
                ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;
              end;
            end;
        end;
      end;
    end;

    // update thumbnails
    ActiveChildForm.UpdateThumbnailsBySelectedChannel;

    if FMainTool = gmtMarquee then
    begin
      if FMarqueeTool = mtMoveResize then
      begin
        if Assigned(ActiveChildForm.Selection) and
           Assigned(ActiveChildForm.SelectionHandleLayer) then
        begin
          ActiveChildForm.SelectionHandleLayer.Visible := True;
        end;
      end;
    end;
    
  finally
    FreeAndNil(frmApplyImage);
  end;
end; 

procedure TfrmMain.ChangeMainToolClick(Sender: TObject);
var
  LLastMainTool         : TgmMainTool;
  LShapeRegionLayerPanel: TgmShapeRegionLayerPanel;
  LTextLayerPanel       : TgmRichTextLayerPanel;
begin
  // prevent from the click event execute twice
  if not FCanExecClick then
  begin
    Exit;
  end;

  LLastMainTool := FMainTool;  // remember the tool that last used

  if Assigned(ActiveChildForm) then
  begin
    ActiveChildForm.FinishTransformation;
    ActiveChildForm.DeleteMeasureLine;
  end;

  if Sender = spdbtnStandardTools then
  begin
    ntbkToolOptions.PageIndex := STANDARD_PAGE_INDEX;
    FMainTool                 := gmtStandard;
  end
  else
  if Sender = spdbtnBrushTools then
  begin
    ntbkToolOptions.PageIndex := BRUSH_PAGE_INDEX;
    FMainTool                 := gmtBrush;
  end
  else
  if Sender = spdbtnMarqueeTools then
  begin
    ntbkToolOptions.PageIndex := MARQUEE_PAGE_INDEX;
    FMainTool                 := gmtMarquee;

    if FMainTool <> LLastMainTool then
    begin
      if ActiveChildForm <> nil then
      begin
        // if the selection is exists, draw the selection and the control border
        if Assigned(ActiveChildForm.Selection) and
           ActiveChildForm.Selection.HasShadow then
        begin
          ActiveChildForm.UpdateSelectionHandleBorder;
        end;
      end;
    end;
  end
  else
  if Sender = spdbtnGradientTools then
  begin
    ntbkToolOptions.PageIndex := GRADIENT_PAGE_INDEX;
    FMainTool                 := gmtGradient;
  end
  else
  if Sender = spdbtnCropTools then
  begin
    ntbkToolOptions.PageIndex := CROP_PAGE_INDEX;
    FMainTool                 := gmtCrop;
  end
  else
  if Sender = spdbtnPaintBucketTools then
  begin
    ntbkToolOptions.PageIndex := PAINT_BUCKET_PAGE_INDEX;
    FMainTool                 := gmtPaintBucket;
  end
  else
  if Sender = spdbtnEraserTools then
  begin
    ntbkToolOptions.PageIndex := ERASER_PAGE_INDEX;
    FMainTool                 := gmtEraser;
  end
  else
  if Sender = spdbtnPenTools then
  begin
    ntbkToolOptions.PageIndex := PEN_TOOLS_PAGE_INDEX;
    FMainTool                 := gmtPenTools;

    if FMainTool <> LLastMainTool then
    begin
      if ActiveChildForm <> nil then
      begin
        // bring the path layer to front
        if Assigned(ActiveChildForm.PathLayer) then
        begin
          ActiveChildForm.PathLayer.BringToFront;
        end;
      end;
    end;
  end
  else
  if Sender = spdbtnMeasureTool then
  begin
    ntbkToolOptions.PageIndex := MEASURE_PAGE_INDEX;
    FMainTool                 := gmtMeasure;
  end
  else
  if Sender = spdbtnShapeTools then
  begin
    ntbkToolOptions.PageIndex := SHAPE_PAGE_INDEX;
    FMainTool                 := gmtShape;

    if ActiveChildForm <> nil then
    begin
      if ActiveChildForm.ShapeOutlineLayer = nil then
      begin
        ActiveChildForm.CreateShapeOutlineLayer;
      end;

      if FShapeRegionTool = srtMove then
      begin
        if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
        begin
          LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

          LShapeRegionLayerPanel.ShapeOutlineList.BackupCoordinates;

          LShapeRegionLayerPanel.ShapeOutlineList.DrawShapesBoundary(
            ActiveChildForm.ShapeOutlineLayer.Bitmap.Canvas, HANDLE_RADIUS,
            ActiveChildForm.OutlineOffsetVector, pmNotXor);

          LShapeRegionLayerPanel.ShapeOutlineList.DrawShapesBoundaryHandles(
            ActiveChildForm.ShapeOutlineLayer.Bitmap.Canvas, HANDLE_RADIUS,
            ActiveChildForm.OutlineOffsetVector, pmNotXor);

          LShapeRegionLayerPanel.IsDismissed := False;
          ActiveChildForm.ShapeOutlineLayer.Bitmap.Changed;
        end;
      end;
    end;
  end
  else
  if Sender = spdbtnTextTool then
  begin
    ntbkToolOptions.PageIndex := TEXT_PAGE_INDEX;
    FMainTool                 := gmtTextTool;

    if FMainTool <> LLastMainTool then
    begin
      if ActiveChildForm <> nil then
      begin
        if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
        begin
          if ActiveChildForm.RichTextHandleLayer = nil then
          begin
            ActiveChildForm.CreateRichTextHandleLayer;
          end;

          ActiveChildForm.RichTextHandleLayer.Bitmap.Clear($00000000);
          LTextLayerPanel := TgmRichTextLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

          LTextLayerPanel.DrawRichTextBorder(ActiveChildForm.RichTextHandleLayer.Bitmap.Canvas,
                                             ActiveChildForm.RichTextHandleLayerOffsetVector);

          LTextLayerPanel.DrawRichTextBorderHandles(ActiveChildForm.RichTextHandleLayer.Bitmap.Canvas,
                                                    ActiveChildForm.RichTextHandleLayerOffsetVector);

          ActiveChildForm.RichTextHandleLayer.Bitmap.Changed;
        end;
      end;
    end;
  end
  else
  if Sender = spdbtnEyedropper then
  begin
    FMainTool := gmtEyedropper;
  end
  else
  if Sender = spdbtnHandTool then
  begin
    FMainTool := gmtHandTool;
  end;

  if Assigned(ActiveChildForm) then
  begin
    if FMainTool <> gmtStandard then
    begin
      if ActiveChildForm.LayerPanelList.SelectedFigureCountOnFigureLayer > 0 then
      begin
        ActiveChildForm.RecordOldFigureSelectedData;
        ActiveChildForm.LayerPanelList.DeselectAllFiguresOnFigureLayer;
        ActiveChildForm.CreateSelectFigureUndoRedo(sfmDeselect);
      end;

      ActiveChildForm.DeleteFigureHandleLayer;
    end;

    if FMainTool <> gmtMarquee then
    begin
      ActiveChildForm.DeleteSelectionHandleLayer;
    end;

    if FMainTool <> gmtShape then
    begin
      if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
      begin
        if ActiveChildForm.ShapeOutlineLayer = nil then
        begin
          ActiveChildForm.CreateShapeOutlineLayer;
        end;

        ActiveChildForm.ShapeOutlineLayer.Bitmap.Clear($00000000);
        LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

        LShapeRegionLayerPanel.ShapeOutlineList.DrawAllOutlines(
          ActiveChildForm.ShapeOutlineLayer.Bitmap.Canvas, ActiveChildForm.OutlineOffsetVector, pmNotXor);
      end
      else
      begin
        ActiveChildForm.DeleteShapeOutlineLayer;
      end;
    end;

    if FMainTool <> gmtTextTool then
    begin
      ActiveChildForm.DeleteRichTextHandleLayer;

      if frmRichTextEditor.Visible then
      begin
        ActiveChildForm.CommitEdits;
      end;
    end;

    // Connect mouse events for image.
    ActiveChildForm.ConnectMouseEventsToImage;

    // Change cursor according to different main tool.
    ActiveChildForm.ChangeImageCursorByToolTemplets;

    if FMainTool <> gmtCrop then
    begin
      ActiveChildForm.FinishCrop;
    end;

    if Assigned(ActiveChildForm.MagneticLasso) then
    begin
      if (FMainTool <> gmtMarquee) or
         (FMarqueeTool <> mtMagneticLasso) then
      begin
        ActiveChildForm.FinishMagneticLasso;
      end;
    end;
  end;
  
  UpdateToolsOptions;
  ShowStatusInfoOnStatusBar;

  if FMainTool in [gmtHandTool, gmtEyeDropper] then
  begin
    pnlToolOptions.Visible := False;
  end;

  imgToolOptionsVisibility.Visible := not (FMainTool in [gmtHandTool, gmtEyeDropper]);

  if pnlToolOptions.Visible then
  begin
    imgToolOptionsVisibility.Bitmap.Assign(dmMain.bmp32lstMainTools.Bitmap[IMG_LEFT_TRIPLE_ARROW_INDEX]);
  end
  else
  begin
    imgToolOptionsVisibility.Bitmap.Assign(dmMain.bmp32lstMainTools.Bitmap[IMG_RIGHT_TRIPLE_ARROW_INDEX]);
  end;
end;

procedure TfrmMain.PopupBrushStyleMenusClick(Sender: TObject);
var
  LPoint: TPoint;
begin
  GetCursorPos(LPoint);
  dmMain.pmnBrushStyle.Popup(LPoint.X, LPoint.Y);
end;

procedure TfrmMain.ShapeBrushStyleClick(Sender: TObject);
var
  p: TPoint;
begin
  GetCursorPos(p);
  dmMain.pmnShapeBrushStyle.Popup(p.X, p.Y);
end;

procedure TfrmMain.ZoomSliderChange(Sender: TObject);
var
  LZoomValue: Integer;
begin
  LZoomValue            := ggbrZoomSlider.Position;
  lblZoomViewer.Caption := IntToStr(LZoomValue) + '%';

  if FCanChange then
  begin
    ActiveChildForm.Magnification        := LZoomValue;
    ActiveChildForm.imgDrawingArea.Scale := LZoomValue / 100;
    ActiveChildForm.FLayerTopLeft        := ActiveChildForm.GetLayerTopLeft;

    if Assigned(ActiveChildForm.Selection) then
    begin
      ActiveChildForm.ShowProcessedSelection;
    end;

    if Assigned(ActiveChildForm.PathLayer) then
    begin
      ActiveChildForm.CalcPathLayerOffsetVector;
    end;

    ActiveChildForm.RefreshCaption;
  end;
end;

procedure TfrmMain.cmbbxPenStyleDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  LBrushInfo: TLogBrush;
  i1, i2    : Integer;
  LPenStyle : DWORD;
begin
  with LBrushInfo do
  begin
    lbStyle := BS_SOLID;
    lbColor := clBlack;
    lbHatch := 0
  end;

  LPenStyle := PS_GEOMETRIC or PS_ENDCAP_SQUARE or PS_JOIN_MITER;

  case Index of
    0:
      begin
        LPenStyle := LPenStyle + PS_SOLID;
      end;
      
    1:
      begin
        LPenStyle := LPenStyle + PS_DASH;
      end;
      
    2:
      begin
        LPenStyle := LPenStyle + PS_DOT;
      end;
      
    3:
      begin
        LPenStyle := LPenStyle + PS_DASHDOT;
      end;
      
    4:
      begin
        LPenStyle := LPenStyle + PS_DASHDOTDOT;
      end;
  end;

  (Control as TComboBox).Canvas.Pen.Handle :=
    ExtCreatePen(LPenStyle, 3, LBrushInfo, 0, nil);

  with (Control as TComboBox).Canvas do
  begin
    i1 := MulDiv(Rect.Left + Rect.Right, 1, 5);
    i2 := MulDiv(Rect.Left + Rect.Right, 4, 5);

    MoveTo( i1, (Rect.Top + Rect.Bottom) div 2 );
    LineTo( i2, (Rect.Top + Rect.Bottom) div 2 );
  end;
end;

procedure TfrmMain.spdbtnZoomInClick(Sender: TObject);
var
  LZoomValue: Integer;
begin
  if (ActiveChildForm.Magnification >= 1) and
     (ActiveChildForm.Magnification < 10) then
  begin
    ggbrZoomSlider.Position := ggbrZoomSlider.Position + 1;
  end
  else
  if (ActiveChildForm.Magnification >= 10) and
     (ActiveChildForm.Magnification < 25) then
  begin
    ggbrZoomSlider.Position := 25;
  end
  else
  if (ActiveChildForm.Magnification >= 25) and
     (ActiveChildForm.Magnification < 50) then
  begin
    ggbrZoomSlider.Position := 50;
  end
  else
  if (ActiveChildForm.Magnification >= 50) and
     (ActiveChildForm.Magnification < 75) then
  begin
    ggbrZoomSlider.Position := 75;
  end
  else
  if (ActiveChildForm.Magnification >= 75) and
     (ActiveChildForm.Magnification < 100) then
  begin
    ggbrZoomSlider.Position := 100;
  end
  else
  if (ActiveChildForm.Magnification >= 100) and
     (ActiveChildForm.Magnification < 800) then
  begin
    LZoomValue              := ggbrZoomSlider.Position;
    LZoomValue              := Trunc(LZoomValue / 100) * 100 + 100;
    ggbrZoomSlider.Position := LZoomValue;
  end
  else
  if (ActiveChildForm.Magnification >= 800) and
     (ActiveChildForm.Magnification < 1200) then
  begin
    ggbrZoomSlider.Position := 1200;
  end
  else
  if (ActiveChildForm.Magnification >= 1200) and
     (ActiveChildForm.Magnification < 1600) then
  begin
    ggbrZoomSlider.Position := 1600;
  end;
end;

procedure TfrmMain.spdbtnZoomOutClick(Sender: TObject);
var
  LZoomValue: Integer;
begin
  if (ActiveChildForm.Magnification > 1) and
     (ActiveChildForm.Magnification <= 10) then
  begin
    ggbrZoomSlider.Position := ggbrZoomSlider.Position - 1;
  end
  else
  if (ActiveChildForm.Magnification > 10) and
     (ActiveChildForm.Magnification <= 25) then
  begin
    ggbrZoomSlider.Position := 10;
  end
  else
  if (ActiveChildForm.Magnification > 25) and
     (ActiveChildForm.Magnification <= 50) then
  begin
    ggbrZoomSlider.Position := 25;
  end
  else
  if (ActiveChildForm.Magnification > 50) and
     (ActiveChildForm.Magnification <= 75) then
  begin
    ggbrZoomSlider.Position := 50;
  end
  else
  if (ActiveChildForm.Magnification > 75) and
     (ActiveChildForm.Magnification <= 100) then
  begin
    ggbrZoomSlider.Position := 75;
  end
  else
  if (ActiveChildForm.Magnification > 100) and
     (ActiveChildForm.Magnification <= 800) then
  begin
    LZoomValue := ggbrZoomSlider.Position;

    if (LZoomValue mod 100) > 0 then
    begin
      LZoomValue := Trunc(LZoomValue / 100) * 100;
    end
    else
    begin
      LZoomValue := LZoomValue - 100;
    end;

    ggbrZoomSlider.Position := LZoomValue;
  end
  else
  if (ActiveChildForm.Magnification > 800) and
     (ActiveChildForm.Magnification <= 1200) then
  begin
    ggbrZoomSlider.Position := 800;
  end
  else
  if (ActiveChildForm.Magnification > 1200) and
     (ActiveChildForm.Magnification <= 1600) then
  begin
    ggbrZoomSlider.Position := 1200;
  end;
end;

procedure TfrmMain.SetChildFormEditMode(Sender: TObject);
var
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  if Assigned(ActiveChildForm) then
  begin
    if Sender = spdbtnStandardMode then
    begin
      if ActiveChildForm.EditMode <> emStandardMode then
      begin
        // create Undo/Redo, first
        LHistoryStatePanel := TgmExitQuickMaskStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          ActiveChildForm.ChannelManager.QuickMaskPanel,
          ActiveChildForm.Selection);

        ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);

        // then, switch to standard edit mode
        ActiveChildForm.EditMode := emStandardMode;
        frmColor.ColorMode       := cmRGB;  // update the appearance of the color form
      end;
    end
    else
    if Sender = spdbtnQuickMaskMode then
    begin
      if ActiveChildForm.EditMode <> emQuickMaskMode then
      begin
        // create Undo/Redo, first
        LHistoryStatePanel := TgmEnterQuickMaskStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          ActiveChildForm.Selection);

        ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);

        // then, switch to quick mask edit mode
        ActiveChildForm.EditMode := emQuickMaskMode;
        frmColor.ColorMode       := cmGrayscale;
      end;
    end;
  end;
end;

procedure TfrmMain.ChangeQuickMaskOptions(Sender: TObject);
begin
  if Assigned(ActiveChildForm) then
  begin
    frmChannelOptions := TfrmChannelOptions.Create(nil);
    try
      with ActiveChildForm do
      begin
        frmChannelOptions.ChannelProcessType            := cptQuickMask;
        frmChannelOptions.shpMaskColor.Brush.Color      := WinColor(ChannelManager.QuickMaskColor);
        frmChannelOptions.MaskOpacityPercent            := ChannelManager.QuickMaskOpacityPercent;
        frmChannelOptions.rdgrpColorIndicator.ItemIndex := Ord(ChannelManager.QuickMaskColorIndicator);

        if frmChannelOptions.ShowModal = mrOK then
        begin
          ChannelManager.QuickMaskColor          := Color32(frmChannelOptions.shpMaskColor.Brush.Color);
          ChannelManager.QuickMaskOpacityPercent := frmChannelOptions.MaskOpacityPercent;
          ChannelManager.QuickMaskColorIndicator := TgmMaskColorIndicator(frmChannelOptions.rdgrpColorIndicator.ItemIndex);

          ChannelManager.QuickMaskPanel.AlphaLayer.Changed;
        end;
      end;
      
    finally
      FreeAndNil(frmChannelOptions);
    end;
  end;
end;

procedure TfrmMain.ChangeStandardTools(Sender: TObject);
var
  LST: TgmStandardTool;
begin
  // prevent from the click event execute twice
  if not FCanExecClick then
  begin
    Exit;
  end;

  // change Figure Tool button on the main tool bar
  if Sender is TSpeedButton then
  begin
    spdbtnStandardTools.Glyph.Assign(TSpeedButton(Sender).Glyph);
    spdbtnStandardTools.Hint := TSpeedButton(Sender).Hint;
  end;

  LST := FStandardTool;

  if Sender = spdbtnPencil then
  begin
    FStandardTool     := gstPencil;
    FLastStandardTool := gstPencil;
  end
  else
  if Sender = spdbtnStraightLine then
  begin
    FStandardTool     := gstStraightLine;
    FLastStandardTool := gstStraightLine;
  end
  else
  if Sender = spdbtnBezierCurve then
  begin
    FStandardTool     := gstBezierCurve;
    FLastStandardTool := gstBezierCurve;
  end
  else
  if Sender = spdbtnPolygon then
  begin
    FStandardTool     := gstPolygon;
    FLastStandardTool := gstPolygon;
  end
  else
  if Sender = spdbtnRegularPolygon then
  begin
    FStandardTool     := gstRegularPolygon;
    FLastStandardTool := gstRegularPolygon;
  end
  else
  if Sender = spdbtnRectangle then
  begin
    FStandardTool     := gstRectangle;
    FLastStandardTool := gstRectangle;
  end
  else
  if Sender = spdbtnRoundRectangle then
  begin
    FStandardTool     := gstRoundRectangle;
    FLastStandardTool := gstRoundRectangle;
  end
  else
  if Sender = spdbtnEllipse then
  begin
    FStandardTool     := gstEllipse;
    FLastStandardTool := gstEllipse;
  end
  else
  if Sender = spdbtnMoveObjects then
  begin
    FStandardTool := gstMoveObjects;
  end
  else
  if Sender = spdbtnRSPartially then
  begin
    FStandardTool := gstPartiallySelect;

    if FStandardTool <> LST then
    begin
      if ActiveChildForm <> nil then
      begin
        if ActiveChildForm.LayerPanelList.SelectedFigureCountOnFigureLayer > 0 then
        begin
          ActiveChildForm.RecordOldFigureSelectedData;
          ActiveChildForm.LayerPanelList.DeselectAllFiguresOnFigureLayer;
          ActiveChildForm.CreateSelectFigureUndoRedo(sfmDeselect);
          ActiveChildForm.FHandleLayer.Bitmap.Clear($00FFFFFF);
          ActiveChildForm.FHandleLayer.Bitmap.Changed;
        end;
      end;
    end;
  end
  else
  if Sender = spdbtnRSTotally then
  begin
    FStandardTool := gstTotallySelect;

    if FStandardTool <> LST then
    begin
      if ActiveChildForm <> nil then
      begin
        if ActiveChildForm.LayerPanelList.SelectedFigureCountOnFigureLayer > 0 then
        begin
          ActiveChildForm.RecordOldFigureSelectedData;
          ActiveChildForm.LayerPanelList.DeselectAllFiguresOnFigureLayer;
          ActiveChildForm.CreateSelectFigureUndoRedo(sfmDeselect);
          ActiveChildForm.FHandleLayer.Bitmap.Clear($00FFFFFF);
          ActiveChildForm.FHandleLayer.Bitmap.Changed;
        end;
      end;
    end;
  end;

  if ActiveChildForm <> nil then
  begin
    if not (FStandardTool in [gstMoveObjects, gstPartiallySelect,
                              gstTotallySelect]) then
    begin
      ActiveChildForm.DeleteFigureHandleLayer;
    end;

    if FStandardTool <> gstMoveObjects then
    begin
      if ActiveChildForm.LayerPanelList.SelectedFigureCount > 0 then
      begin
        ActiveChildForm.RecordOldFigureSelectedData;
        ActiveChildForm.LayerPanelList.DeselectAllFiguresOnFigureLayer;
        ActiveChildForm.CreateSelectFigureUndoRedo(sfmDeselect);
      end;
    end;

    ActiveChildForm.ConnectMouseEventsToImage;
    ActiveChildForm.ChangeImageCursorByStandardTools; // Change cursor
  end;

  UpdateStandardOptions;
  ShowStatusInfoOnStatusBar;
end;

procedure TfrmMain.OpenSelectFiguresDialog(Sender: TObject);
begin
  // get the latest index of layer
  ActiveChildForm.LayerPanelList.GetFigureLayerIndex;

  if ActiveChildForm.LayerPanelList.SelectedFigureCountOnFigureLayer > 0 then
  begin
    ActiveChildForm.LayerPanelList.DeselectAllFiguresOnFigureLayer;
    SetLength(ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray, 0);
    SetLength(ActiveChildForm.LayerPanelList.FSelectedFigureLayerIndexArray, 0);
  end;

  if ActiveChildForm.FHandleLayer = nil then
  begin
    ActiveChildForm.CreateFigureHandleLayer;
  end;
  
  if ActiveChildForm.FHandleLayer <> nil then
  begin
    ActiveChildForm.FHandleLayer.Bitmap.Clear($00FFFFFF);
    ActiveChildForm.FHandleLayer.Bitmap.Changed;
  end;

  frmSelectFigures := TfrmSelectFigures.Create(nil);
  try
    case frmSelectFigures.ShowModal of
      idOK:
        begin
          frmSelectFigures.ApplyConfiguration;

          // Undo/Redo (can not create Undo/Redo for Now)
          // Clear UndoRedo
          ActiveChildForm.HistoryManager.DeleteAllHistoryStates;
          ActiveChildForm.HistoryManager.SelectSnapshotByIndex(0);
          ActiveChildForm.HistoryManager.UpdateAllPanelsState;
        end;

      idCancel:
        begin
          frmSelectFigures.CancelConfiguration;
          ActiveChildForm.LayerPanelList.DrawAllFiguresOnFigureLayer(ActiveChildForm.imgDrawingArea.Layers);
          ActiveChildForm.LayerPanelList.ApplyMaskOnAllFigureLayers;

          if ActiveChildForm.FHandleLayer <> nil then
          begin
            ActiveChildForm.FHandleLayer.Bitmap.Clear($00FFFFFF);
            ActiveChildForm.FHandleLayer.Bitmap.Changed;
          end
          else
          begin
            ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
          end;
        end;
    end;

    frmSelectFigures.ClearSelectedInfoArray;
    frmSelectFigures.ClearAllOriginalFiguresArray;
  finally
    FreeAndNil(frmSelectFigures);
  end;

  if ActiveChildForm.LayerPanelList.SelectedFigureCountOnFigureLayer = 1 then
  begin
    ActiveChildForm.FSelectedFigure := nil;
    ActiveChildForm.FSelectedFigure := ActiveChildForm.LayerPanelList.GetFirstSelectedFigure;
  end
  else
  begin
    ActiveChildForm.FSelectedFigure := nil;
  end;
  
  // if there is no selected figures, delete figure handle layer
  if High(ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray) < 0 then
  begin
    ActiveChildForm.DeleteFigureHandleLayer;
  end
  else
  begin
    // if there is selected figures, switch to MoveObject tool of standard tools
    spdbtnMoveObjects.Down := True;
    ChangeStandardTools(spdbtnMoveObjects);
  end;
  
  UpdateStandardOptions;
end;

procedure TfrmMain.OpenFigurePropertiesDialog(Sender: TObject);
var
  LOldData, LNewData: TgmFigureBasicData;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  if ActiveChildForm.LayerPanelList.SelectedFigureCountOnFigureLayer = 1 then
  begin
    ActiveChildForm.FSelectedFigure := ActiveChildForm.LayerPanelList.GetFirstSelectedFigure;
  end
  else
  begin
    ActiveChildForm.FSelectedFigure := nil;
  end;

  if Assigned(ActiveChildForm.FSelectedFigure) then
  begin
    // copy the old data for Undo/Redo
    with ActiveChildForm.FSelectedFigure do
    begin
      LOldData.Name       := Name;
      LOldData.PenColor   := PenColor;
      LOldData.BrushColor := BrushColor;
      LOldData.PenWidth   := PenWidth;
      LOldData.PenStyle   := PenStyle;
      LOldData.BrushStyle := BrushStyle;

      if Flag in [ffRegularPolygon, ffSquare, ffRoundSquare, ffCircle] then
      begin
        LOldData.OriginX := OriginPixelX;
        LOldData.OriginY := OriginPixelY;
        LOldData.Radius  := RadiusPixel;
      end;
    end;

    frmFigureProperties := TfrmFigureProperties.Create(nil);
    try
      case frmFigureProperties.ShowModal of
        idCancel:
          begin
            frmFigureProperties.RestoreSettings;
            Exit;
          end;

        idOK:
          begin
            with ActiveChildForm.FSelectedFigure do
            begin
              Name       := frmFigureProperties.edtFigureName.Text;
              PenColor   := frmFigureProperties.shpPenColor.Brush.Color;
              BrushColor := frmFigureProperties.shpBrushColor.Brush.Color;
              PenWidth   := frmFigureProperties.updwnPenWidth.Position;
              PenStyle   := frmFigureProperties.PenStyle;
              BrushStyle := frmFigureProperties.BrushStyle;

              if Flag in [ffRegularPolygon, ffSquare, ffRoundSquare, ffCircle] then
              begin
                frmFigureProperties.SetFigureProperties(FFigureUnits);
              end;
            end;

            // copy the old data for Undo/Redo
            with ActiveChildForm.FSelectedFigure do
            begin
              LNewData.Name       := Name;
              LNewData.PenColor   := PenColor;
              LNewData.BrushColor := BrushColor;
              LNewData.PenWidth   := PenWidth;
              LNewData.PenStyle   := PenStyle;
              LNewData.BrushStyle := BrushStyle;

              if Flag in [ffRegularPolygon, ffSquare, ffRoundSquare, ffCircle] then
              begin
                LNewData.OriginX := OriginPixelX;
                LNewData.OriginY := OriginPixelY;
                LNewData.Radius  := RadiusPixel;
              end;
            end;

            // Create Undo/Redo
            LHistoryStatePanel := TgmModifyFigureStyleStatePanel.Create(
              frmHistory.scrlbxHistory,
              dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
              LOldData,
              LNewData);

            ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);
          end;
      end;
    finally
      FreeAndNil(frmFigureProperties);
    end;

    ActiveChildForm.LayerPanelList.DrawAllFiguresOnSelectedFigureLayer(
      ActiveChildForm.imgDrawingArea.Layers);

    ActiveChildForm.LayerPanelList.DrawSelectedFiguresHandles(
      ActiveChildForm.FHandleLayer.Bitmap, ActiveChildForm.FHandleLayerOffsetVector);

    ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
    ActiveChildForm.LayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
  end;
end;

procedure TfrmMain.SelectAllFigures(Sender: TObject);
begin
  if ActiveChildForm.FHandleLayer = nil then
  begin
    ActiveChildForm.CreateFigureHandleLayer;
  end;

  ActiveChildForm.RecordOldFigureSelectedData;  // For Undo/Redo
  ActiveChildForm.LayerPanelList.SelectAllFiguresOnFigureLayer;
  ActiveChildForm.CreateSelectFigureUndoRedo(sfmSelect);  // Create Undo/Redo

  ActiveChildForm.LayerPanelList.DrawSelectedFiguresHandles(
    ActiveChildForm.FHandleLayer.Bitmap, ActiveChildForm.FHandleLayerOffsetVector);

  if ActiveChildForm.LayerPanelList.SelectedFigureCountOnFigureLayer = 1 then
  begin
    ActiveChildForm.FSelectedFigure := nil;
    ActiveChildForm.FSelectedFigure := ActiveChildForm.LayerPanelList.GetFirstSelectedFigure;
  end
  else
  begin
    ActiveChildForm.FSelectedFigure := nil;
  end;
  
  spdbtnMoveObjects.Down := True;
  ChangeStandardTools(spdbtnMoveObjects);
  UpdateStandardOptions;
end;

procedure TfrmMain.DeleteSelectedFigures(Sender: TObject);
var
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  // Undo/Redo
  LHistoryStatePanel := TgmDeleteFigureStatePanel.Create(
    frmHistory.scrlbxHistory,
    dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
    ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray,
    ActiveChildForm.LayerPanelList.FSelectedFigureLayerIndexArray);

  ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);

  // doing deletion
  ActiveChildForm.LayerPanelList.DeleteSelectedFiguresOnFigureLayer;

  { After all the selected figures are deleted, draw the rest figures on that
    layers which not be selected. Because the field FSelectedFigureIndexArray in
    the FLayerPanelList has not been cleared yet, so use these indices for
    drawing the rest figures on the respective layers. This will speed up the
    proformance. After that, clear the FSelectedFigureIndexArray. }
  ActiveChildForm.LayerPanelList.DrawDeselectedFiguresOnSelectedFigureLayer(
    ActiveChildForm.imgDrawingArea.Layers);

  ActiveChildForm.FHandleLayer.Bitmap.Clear($00FFFFFF);
  ActiveChildForm.FHandleLayer.Bitmap.Changed;

  ActiveChildForm.LayerPanelList.UpdateSelectedFigureLayerThumbnail(
    ActiveChildForm.imgDrawingArea.Layers);

  SetLength(ActiveChildForm.LayerPanelList.FSelectedFigureLayerIndexArray, 0);
  SetLength(ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray, 0);
  UpdateStandardOptions;
end;

procedure TfrmMain.LockSelectedFigures(Sender: TObject);
var
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  ActiveChildForm.LayerPanelList.LockSelectedFiguresOnSelectedFigureLayer;

  if Assigned(ActiveChildForm.FHandleLayer) then
  begin
    ActiveChildForm.FHandleLayer.Bitmap.Clear($00FFFFFF);

    ActiveChildForm.LayerPanelList.DrawSelectedFiguresHandles(
      ActiveChildForm.FHandleLayer.Bitmap, ActiveChildForm.FHandleLayerOffsetVector);

    ActiveChildForm.FHandleLayer.Bitmap.Changed;
  end;

  UpdateStandardOptions;

  // Undo/Redo
  LHistoryStatePanel := TgmLockFigureStatePanel.Create(
    frmHistory.scrlbxHistory,
    dmHistory.bmp32lstHistory.Bitmap[LOCK_COMMAND_ICON_INDEX],
    lfmLock);

  ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);
end;

procedure TfrmMain.UnlockSelectedFigures(Sender: TObject);
var
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  ActiveChildForm.LayerPanelList.UnlockSelectedFiguresOnSelectedFigureLayer;

  if Assigned(ActiveChildForm.FHandleLayer) then
  begin
    ActiveChildForm.FHandleLayer.Bitmap.Clear($00FFFFFF);

    ActiveChildForm.LayerPanelList.DrawSelectedFiguresHandles(
      ActiveChildForm.FHandleLayer.Bitmap, ActiveChildForm.FHandleLayerOffsetVector);

    ActiveChildForm.FHandleLayer.Bitmap.Changed;
  end;
  
  UpdateStandardOptions;

  // Undo/Redo
  LHistoryStatePanel := TgmLockFigureStatePanel.Create(
    frmHistory.scrlbxHistory,
    dmHistory.bmp32lstHistory.Bitmap[UNLOCK_COMMAND_ICON_INDEX],
    lfmUnlock);

  ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);
end;

procedure TfrmMain.cmbbxPenStyleChange(Sender: TObject);
begin
  // Change line style.
  FGlobalPenStyle := TPenStyle(cmbbxPenStyle.ItemIndex);
end;

procedure TfrmMain.ChangeGlobalPenWidth(Sender: TObject);
begin
  // Change line width.
  FGlobalPenWidth := cmbbxPenWidth.ItemIndex + 1;
end;

procedure TfrmMain.cmbbxPenWidthDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  LBrushInfo: TLogBrush;
  i1, i2    : Integer;
begin
  with LBrushInfo do
  begin
    lbstyle := BS_Solid;
    lbColor := clBlack;
    lbHatch :=0;
  end;

  (Control as TComboBox).Canvas.Pen.Handle :=
    ExtCreatePen(PS_GEOMETRIC or PS_ENDCAP_SQUARE or PS_JOIN_MITER,
    Index + 1, LBrushInfo, 0, nil);

  with (Control as TComboBox).Canvas do
  begin
    i1 := MulDiv(Rect.Left + Rect.Right, 1, 5);
    i2 := MulDiv(Rect.Left + Rect.Right, 4, 5);

    MoveTo( i1, (Rect.Top + Rect.Bottom) div 2 );
    LineTo( i2, (Rect.Top + Rect.Bottom) div 2 );
  end;
end;

procedure TfrmMain.ChangeRadiusSides(Sender: TObject);
begin
  if FCanChange then
  begin
    try
      case FStandardTool of
        gstRegularPolygon:
          begin
            updwnRadiusSides.Position := StrToInt(edtRadiusSides.Text);
            FStandardPolygonSides     := updwnRadiusSides.Position;
          end;

        gstRoundRectangle:
          begin
            updwnRadiusSides.Position := StrToInt(edtRadiusSides.Text);
            FStandardCornerRadius     := updwnRadiusSides.Position;
          end;
      end;

    except
      case FStandardTool of
        gstRegularPolygon:
          begin
            edtRadiusSides.Text := IntToStr(FStandardPolygonSides);
          end;

        gstRoundRectangle:
          begin
            edtRadiusSides.Text := IntToStr(FStandardCornerRadius);
          end;
      end;
    end;
  end;
end;

procedure TfrmMain.ChangeBrushTools(Sender: TObject);

    procedure DeleteLastBrush;
    begin
      if Assigned(FGMBrush) then
      begin
        FreeAndNil(FGMBrush);
      end;
    end;

begin
  // prevent from the click event execute twice
  if not FCanExecClick then
  begin
    Exit;
  end;

  // change Brush Tool button on the main tool bar
  if Sender is TSpeedButton then
  begin
    spdbtnBrushTools.Glyph.Assign(TSpeedButton(Sender).Glyph);
    spdbtnBrushTools.Hint := TSpeedButton(Sender).Hint;
  end;

  DeleteLastBrush;

  if Sender = spdbtnPaintBrush then
  begin
    FBrushTool := btPaintBrush;
    FGMBrush   := TgmPaintBrush.Create;
  end
  else
  if Sender = spdbtnHistoryBrush then
  begin
    FBrushTool := btHistoryBrush;
    FGMBrush   := TgmHistoryBrush.Create;
  end
  else
  if Sender = spdbtnAirBrush then
  begin
    FBrushTool := btAirBrush;
  end
  else
  if Sender = spdbtnJetGun then
  begin
    FBrushTool := btJetGunBrush;
  end
  else
  if Sender = spdbtnCloneStamp then
  begin
    FBrushTool := btCloneStamp;
    FGMBrush   := TgmCloneStamp.Create;
  end
  else
  if Sender = spdbtnPatternStamp then
  begin
    FBrushTool := btPatternStamp;
    FGMBrush   := TgmPatternStamp.Create;
  end
  else
  if Sender = spdbtnBlurBrush then
  begin
    FBrushTool := btBlurSharpenBrush;
    FGMBrush   := TgmBlurSharpenBrush.Create(gmctBlur);
  end
  else
  if Sender = spdbtnSharpenBrush then
  begin
    FBrushTool := btBlurSharpenBrush;
    FGMBrush   := TgmBlurSharpenBrush.Create(gmctSharpen);
  end
  else
  if Sender = spdbtnSmudge then
  begin
    FBrushTool := btSmudge;
    FGMBrush   := TgmSmudge.Create;
  end
  else
  if Sender = spdbtnDodgeBrush then
  begin
    FBrushTool := btDodgeBurnBrush;
    FGMBrush   := TgmDodgeBurnBrush.Create(dbtDodge);
  end
  else
  if Sender = spdbtnBurnBrush then
  begin
    FBrushTool := btDodgeBurnBrush;
    FGMBrush   := TgmDodgeBurnBrush.Create(dbtBurn);
  end
  else
  if Sender = spdbtnHighHueBrush then
  begin
    FBrushTool := btLightBrush;
    FGMBrush   := TgmLightBrush.Create(lbmHighHue);
  end
  else
  if Sender = spdbtnLowHueBrush then
  begin
    FBrushTool := btLightBrush;
    FGMBrush   := TgmLightBrush.Create(lbmLowHue);
  end
  else
  if Sender = spdbtnHighSaturationBrush then
  begin
    FBrushTool := btLightBrush;
    FGMBrush   := TgmLightBrush.Create(lbmHighSaturation);
  end
  else
  if Sender = spdbtnLowSaturationBrush then
  begin
    FBrushTool := btLightBrush;
    FGMBrush   := TgmLightBrush.Create(lbmLowSaturation);
  end
  else
  if Sender = spdbtnHighLuminosityBrush then
  begin
    FBrushTool := btLightBrush;
    FGMBrush   := TgmLightBrush.Create(lbmHighLuminosity);
  end
  else
  if Sender = spdbtnLowLuminosityBrush then
  begin
    FBrushTool := btLightBrush;
    FGMBrush   := TgmLightBrush.Create(lbmLowLuminosity);
  end
  else
  if Sender = spdbtnBrightnessBrush then
  begin
    FBrushTool := btLightBrush;
    FGMBrush   := TgmLightBrush.Create(lbmBrightness);
  end
  else
  if Sender = spdbtnDarknessBrush then
  begin
    FBrushTool := btLightBrush;
    FGMBrush   := TgmLightBrush.Create(lbmDarkness);
  end
  else
  if Sender = spdbtnHighContrastBrush then
  begin
    FBrushTool := btLightBrush;
    FGMBrush   := TgmLightBrush.Create(lbmHighContrast);
  end
  else
  if Sender = spdbtnLowContrastBrush then
  begin
    FBrushTool := btLightBrush;
    FGMBrush   := TgmLightBrush.Create(lbmLowContrast);
  end;
  
  UpdateBrushOptions;
  ShowStatusInfoOnStatusBar;
end;

procedure TfrmMain.OpenPaintingBrushSelector(Sender: TObject);
var
  p: TPoint;
begin
  GetCursorPos(p);
  frmPaintingBrush.Left           := p.X;
  frmPaintingBrush.Top            := p.Y;
  frmPaintingBrush.StrokeListUser := sluBrush;
  frmPaintingBrush.Show;
end;

procedure TfrmMain.OpenPatternSelectorForStamp(Sender: TObject);
var
  p: TPoint;
begin
  GetCursorPos(p);
  frmPatterns.Left            := p.X;
  frmPatterns.Top             := p.Y;
  frmPatterns.PatternListUser := pluStamp;
  frmPatternS.Show;
end;

procedure TfrmMain.OpenBrushDynamicsEditor(Sender: TObject);
var
  p: TPoint;
begin
  GetCursorPos(p);
  frmBrushDynamics.Left := p.X;
  frmBrushDynamics.Top  := p.Y;
  frmBrushDynamics.Show;
end;

procedure TfrmMain.ChangeBrushMode(Sender: TObject);
begin
  if FBrushTool = btDodgeBurnBrush then
  begin
    FDodgeBurnMode := TgmDodgeBurnMode(cmbbxBrushMode.ItemIndex);
  end
  else
  begin
    FBrushBlendMode := TBlendMode32(cmbbxBrushMode.ItemIndex);
  end;
end;

procedure TfrmMain.ChangeBrushOPEI(Sender: TObject);
begin
  if FCanChange then
  begin
    try
      updwnBrushOPEI.Position :=StrToInt(edtBrushOPEI.Text);

      if FBrushTool in [btPaintBrush, btHistoryBrush, btCloneStamp,
                        btPatternStamp] then
      begin
        FBrushOpacity := updwnBrushOPEI.Position;
      end
      else if FBrushTool = btAirBrush then
      begin
        FAirPressure := updwnBrushOPEI.Position;
      end
      else if FBrushTool = btJetGunBrush then
      begin
        FJetGunPressure := updwnBrushOPEI.Position;
      end
      else if FBrushTool = btSmudge then
      begin
        FSmudgePressure := updwnBrushOPEI.Position;
      end
      else if FBrushTool = btDodgeBurnBrush then
      begin
        FDodgeBurnExposure := updwnBrushOPEI.Position;
      end
      else if FBrushTool = btBlurSharpenBrush then
      begin
        FBlurSharpenPressure := updwnBrushOPEI.Position;
      end
      else if FBrushTool = btLightBrush then
      begin
        FBrushIntensity := updwnBrushOPEI.Position;
      end;
      
    except
      case FBrushTool of
        btPaintBrush,
        btHistoryBrush,
        btCloneStamp,
        btPatternStamp:
          begin
            edtBrushOPEI.Text := IntToStr(FBrushOpacity);
          end;
      
        btAirBrush:
          begin
            edtBrushOPEI.Text := IntToStr(FAirPressure);
          end;
          
        btJetGunBrush:
          begin
            edtBrushOPEI.Text := IntToStr(FJetGunPressure);
          end;
          
        btSmudge :
          begin
            edtBrushOPEI.Text := IntToStr(FSmudgePressure);
          end;
          
        btDodgeBurnBrush:
          begin
            edtBrushOPEI.Text := IntToStr(FDodgeBurnExposure);
          end;
          
        btBlurSharpenBrush:
          begin
            edtBrushOPEI.Text := IntToStr(FBlurSharpenPressure);
          end;
          
        btLightBrush:
          begin
            edtBrushOPEI.Text := IntToStr(FBrushIntensity);
          end;
      end;
    end;
  end;
end;

procedure TfrmMain.ChangeBrushInterval(Sender: TObject);
begin
  if FCanChange then
  begin
    try
      updwnBrushInterval.Position := StrToInt(edtBrushInterval.Text);

      if FBrushTool = btJetGunBrush then
      begin
        FJetGun.Interval := updwnBrushInterval.Position;

        if ActiveChildForm <> nil then
        begin
          ActiveChildForm.tmrSpecialBrush.Interval := FJetGun.Interval;
        end;
      end
      else
      if FBrushTool = btAirBrush then
      begin
        FAirBrush.Interval := updwnBrushInterval.Position;

        if ActiveChildForm <> nil then
        begin
          ActiveChildForm.tmrSpecialBrush.Interval := FAirBrush.Interval;
        end;
      end
      else
      if FBrushTool = btBlurSharpenBrush then
      begin
        FBlurSharpenTimerInterval := updwnBrushInterval.Position;

        if ActiveChildForm <> nil then
        begin
          ActiveChildForm.tmrSpecialBrush.Interval := FBlurSharpenTimerInterval;
        end;
      end
      else
      begin
        FBrushInterval := updwnBrushInterval.Position;
      end;
      
    except
      edtBrushInterval.Text := IntToStr(updwnBrushInterval.Position);
    end;
  end;
end;

procedure TfrmMain.ChangeBrushRadius(Sender: TObject);
begin
  if FCanChange then
  begin
    try
      updwnBrushRadius.Position := StrToInt(edtBrushRadius.Text);
      FBrushRadius              := updwnBrushRadius.Position;
    except
      edtBrushRadius.Text := IntToStr(FBrushRadius);
    end;
  end;
end;

procedure TfrmMain.chckbxColorAndSampleClick(Sender: TObject);
begin
  case FBrushTool of
    btJetGunBrush:
      begin
        FIsRandomColor := chckbxColorAndSample.Checked;
      end;

    btCloneStamp:
      begin
        FIsUseAllLayers := chckbxColorAndSample.Checked;
      end;
  end;
end;

procedure TfrmMain.ChangeMarqueeTools(Sender: TObject);
begin
  // prevent from the click event execute twice
  if not FCanExecClick then
  begin
    Exit;
  end;

  // change Marquee Tool button on the main tool bar
  if Sender is TSpeedButton then
  begin
    spdbtnMarqueeTools.Glyph.Assign(TSpeedButton(Sender).Glyph);
    spdbtnMarqueeTools.Hint := TSpeedButton(Sender).Hint;
  end;

  if ActiveChildForm <> nil then
  begin
    if Sender = spdbtnSelect then
    begin
      // don't drawing the selection
      ActiveChildForm.MarqueeDrawingState := dsNotDrawing
    end
    else
    begin
      // drawing new marquee
      ActiveChildForm.MarqueeDrawingState := dsNewFigure;
    end;
  end;

  if Sender = spdbtnSelect then
  begin
    FMarqueeTool := mtMoveResize;
  end
  else if Sender = spdbtnSingleRowMarquee then
  begin
    FMarqueeTool := mtSingleRow;
  end
  else if Sender = spdbtnSingleColumnMarquee then
  begin
    FMarqueeTool := mtSingleColumn;
  end
  else if Sender = spdbtnRectangularMarquee then
  begin
    FMarqueeTool := mtRectangular;
  end
  else if Sender = spdbtnRoundRectangularMarquee then
  begin
    FMarqueeTool := mtRoundRectangular;
  end
  else if Sender = spdbtnEllipticalMarquee then
  begin
    FMarqueeTool := mtElliptical;
  end
  else if Sender = spdbtnPolygonalMarquee then
  begin
    FMarqueeTool := mtPolygonal;
  end
  else if Sender = spdbtnRegularPolygonMarquee then
  begin
    FMarqueeTool := mtRegularPolygon;
  end
  else if Sender = spdbtnMagneticLasso then
  begin
    FMarqueeTool := mtMagneticLasso;
  end
  else if Sender = spdbtnLassoMarquee then
  begin
    FMarqueeTool := mtLasso;
  end
  else if Sender = spdbtnMagicWand then
  begin
    FMarqueeTool := mtMagicWand;
  end;

  if Assigned(ActiveChildForm) then
  begin
    if Assigned(ActiveChildForm.MagneticLasso) then
    begin
      if FMarqueeTool <> mtMagneticLasso then
      begin
        ActiveChildForm.FinishMagneticLasso;
      end;
    end;
  end;

  UpdateMarqueeOptions;
  ShowStatusInfoOnStatusBar;

  if ActiveChildForm <> nil then
  begin
    if Assigned(ActiveChildForm.Selection) then
    begin
      if ActiveChildForm.ChannelManager.CurrentChannelType in [
           wctRGB, wctRed, wctGreen, wctBlue] then
      begin
        if ActiveChildForm.SelectionTransformation = nil then
        begin
          if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
               lfBackground, lfTransparent] then
          begin
            // render the selection
            ActiveChildForm.Selection.ShowSelection(
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
              ActiveChildForm.ChannelManager.ChannelSelectedSet);

            ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;
          end;
        end;
      end;

      // update selectioin border
      ActiveChildForm.UpdateSelectionHandleBorder;
    end;

    // change cursor
    ActiveChildForm.ChangeImageCursorByMarqueeTools;
  end;
end;

procedure TfrmMain.MarqueeToolButtonMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if ActiveChildForm <> nil then
  begin
    ActiveChildForm.FinishTransformation;
  end;
end;

procedure TfrmMain.ChangeMarqueeMode(Sender: TObject);
begin
  // prevent from the click event execute twice
  if not FCanExecClick then
  begin
    Exit;
  end;

  if Sender = spdbtnNewSelection then
  begin
    FMarqueeMode := mmNew;
  end
  else if Sender = spdbtnAddSelection then
  begin
    FMarqueeMode := mmAdd;
  end
  else if Sender = spdbtnSubtractSelection then
  begin
    FMarqueeMode := mmSubtract;
  end 
  else if Sender = spdbtnIntersectSelection then
  begin
    FMarqueeMode := mmIntersect;
  end
  else if Sender = spdbtnExcludeOverlapSelection then
  begin
    FMarqueeMode := mmExcludeOverlap;
  end;

  if ActiveChildForm <> nil then
  begin
    ActiveChildForm.ChangeImageCursorByMarqueeTools; // change cursor
  end;
end;

procedure TfrmMain.spdbtnCommitSelectionClick(Sender: TObject);
var
  LCmdAim           : TCommandAim;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  if ActiveChildForm.SelectionTransformation = nil then
  begin
    if Assigned(ActiveChildForm.Selection) then
    begin
      if ActiveChildForm.SelectionCopy = nil then
      begin
        ActiveChildForm.CreateCopySelection;
      end;

      ActiveChildForm.SelectionCopy.AssignAllSelectionData(ActiveChildForm.Selection);
      ActiveChildForm.CommitSelection;

      // Create Undo/Redo
      LCmdAim := ActiveChildForm.GetCommandAimByCurrentChannel;

      LHistoryStatePanel := TgmSelectionStatePanel.Create(
        frmHistory.scrlbxHistory,
        dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
        LCmdAim,
        FMarqueeTool,
        sctCommitSelection,
        ActiveChildForm.SelectionCopy,
        ActiveChildForm.Selection,
        ActiveChildForm.ChannelManager.SelectedAlphaChannelIndex);

      ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);

      spdbtnCommitSelection.Enabled := False;
      spdbtnDeselect.Enabled        := False;
      spdbtnDeleteSelection.Enabled := False;
    end;
  end;
end;

procedure TfrmMain.spdbtnDeselectClick(Sender: TObject);
var
  LCmdAim           : TCommandAim;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  LCmdAim := caNone;

  if ActiveChildForm.SelectionTransformation = nil then
  begin
    if Assigned(ActiveChildForm.Selection) then
    begin
      // Duplicate the old selection for Undo/Redo if the selection is existed.
      if ActiveChildForm.SelectionCopy = nil then
      begin
        ActiveChildForm.CreateCopySelection;
      end;

      ActiveChildForm.SelectionCopy.AssignAllSelectionData(ActiveChildForm.Selection);
      ActiveChildForm.CancelSelection;

      // Create Undo/Redo 
      case ActiveChildForm.ChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            LCmdAim := caAlphaChannel;
          end;

        wctQuickMask:
          begin
            LCmdAim := caQuickMask;
          end;

        wctLayerMask:
          begin
            LCmdAim := caLayerMask;
          end;

      else
        LCmdAim := caLayer;
      end;
    end;

    spdbtnCommitSelection.Enabled := False;
    spdbtnDeselect.Enabled        := False;
    spdbtnDeleteSelection.Enabled := False;

    LHistoryStatePanel := TgmSelectionStatePanel.Create(
      frmHistory.scrlbxHistory,
      dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
      LCmdAim,
      FMarqueeTool,
      sctDeselect,
      ActiveChildForm.SelectionCopy,
      ActiveChildForm.Selection,
      ActiveChildForm.ChannelManager.SelectedAlphaChannelIndex);

    ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);
  end;
end;

procedure TfrmMain.spdbtnDeleteSelectionClick(Sender: TObject);
var
  LCmdAim           : TCommandAim;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  LCmdAim := caNone;

  if ActiveChildForm.SelectionTransformation = nil then
  begin
    if Assigned(ActiveChildForm.Selection) then
    begin
      if ActiveChildForm.SelectionCopy = nil then
      begin
        ActiveChildForm.CreateCopySelection;
      end;

      ActiveChildForm.SelectionCopy.AssignAllSelectionData(ActiveChildForm.Selection);
      ActiveChildForm.DeleteSelection;

      // Create Undo/Redo
      case ActiveChildForm.ChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            LCmdAim := caAlphaChannel;
          end;

        wctQuickMask:
          begin
            LCmdAim := caQuickMask;
          end;

        wctLayerMask:
          begin
            LCmdAim := caLayerMask;
          end;

      else
        LCmdAim := caLayer;
      end;
    end;
    
    spdbtnCommitSelection.Enabled := False;
    spdbtnDeselect.Enabled        := False;
    spdbtnDeleteSelection.Enabled := False;

    LHistoryStatePanel := TgmSelectionStatePanel.Create(
      frmHistory.scrlbxHistory,
      dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
      LCmdAim,
      FMarqueeTool,
      sctDeleteSelection,
      ActiveChildForm.SelectionCopy,
      ActiveChildForm.Selection,
      ActiveChildForm.ChannelManager.SelectedAlphaChannelIndex);

    ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);
  end;
end;

procedure TfrmMain.edtToleranceSidesChange(Sender: TObject);
begin
  if FCanChange then
  begin
    try
      updwnToleranceSides.Position := StrToInt(edtToleranceSides.Text);

      case FMarqueeTool of
        mtMagicWand:
          begin
            FMagicWandTolerance := updwnToleranceSides.Position;
          end;

        mtRegularPolygon:
          begin
            FRPMSides := updwnToleranceSides.Position;
          end;

        mtRoundRectangular:
          begin
            FRRMCornerRadius := updwnToleranceSides.Position;
          end;
      end;

    except
      case FMarqueeTool of
        mtMagicWand:
          begin
            edtToleranceSides.Text := IntToStr(FMagicWandTolerance);
          end;

        mtRegularPolygon:
          begin
            edtToleranceSides.Text := IntToStr(FRPMSides);
          end;
          
        mtRoundRectangular:
          begin
            edtToleranceSides.Text := IntToStr(FRRMCornerRadius);
          end;
      end;
    end;
  end;
end;

procedure TfrmMain.ChangeGradientTools(Sender: TObject);
begin
  // prevent from the click event execute twice
  if not FCanExecClick then
  begin
    Exit;
  end;

  // change Gradient Tool button on the main tool bar
  if Sender is TSpeedButton then
  begin
    spdbtnGradientTools.Glyph.Assign(TSpeedButton(Sender).Glyph);
    spdbtnGradientTools.Hint := TSpeedButton(Sender).Hint;
  end;

  if Sender = spdbtnLinearGradient then
  begin
    FGradientRenderMode := grmLinear;
  end
  else if Sender = spdbtnRadialGradient then
  begin
    FGradientRenderMode := grmRadial;
  end
  else if Sender = spdbtnAngleGradient then
  begin
    FGradientRenderMode := grmAngle;
  end
  else if Sender = spdbtnReflectedGradient then
  begin
    FGradientRenderMode := grmReflected;
  end
  else if Sender = spdbtnDiamondGradient then
  begin
    FGradientRenderMode := grmDiamond;
  end;

  ShowStatusInfoOnStatusBar;
end;

procedure TfrmMain.spdbtnOpenGradientPickerClick(Sender: TObject);
var
  p: TPoint;
begin
  GetCursorPos(p);
  frmGradientPicker.Left         := p.X;
  frmGradientPicker.Top          := p.Y;
  frmGradientPicker.GradientUser := guGradientTools;
  frmGradientPicker.Show;
end;

procedure TfrmMain.imgSelectedGradientClick(Sender: TObject);
begin
  frmGradientEditor := TfrmGradientEditor.Create(nil);
  try
    frmGradientEditor.GradientUser := guGradientTools;
    frmGradientEditor.ShowModal;
  finally
    FreeAndNil(frmGradientEditor);
  end;
end;

procedure TfrmMain.imgSelectedGradientPaintStage(Sender: TObject;
  Buffer: TBitmap32; StageNum: Cardinal);
begin
  DrawCheckerboardPattern(Buffer, True);
end;

procedure TfrmMain.ChangeGradientBlendMode(Sender: TObject);
begin
  FGradientBlendMode := TBlendMode32(cmbbxGradientBlendMode.ItemIndex);
end;

procedure TfrmMain.ChangeGradientOpacity(Sender: TObject);
begin
  if FCanChange then
  begin
    try
      updwnGradientOpacity.Position := StrToInt(edtGradientOpacity.Text);
      FGradientBlendOpacity         := updwnGradientOpacity.Position;
    except
      edtGradientOpacity.Text := IntToStr(FGradientBlendOpacity);
    end;
  end;
end;

procedure TfrmMain.chckbxReverseGradientClick(Sender: TObject);
begin
  frmGradientPicker.ShowDrawingToolSelectedGradient;
end;

procedure TfrmMain.edtCropWidthChange(Sender: TObject);
var
  LValue: Integer;
begin
  if ActiveChildForm.Crop <> nil then
  begin
    if edtCropWidth.Text <> '' then
    begin
      if FCanChange then
      begin
        try
          LValue := StrToInt(edtCropWidth.Text);

          if LValue < 0 then
          begin
            LValue            := 0;
            edtCropWidth.Text := IntToStr(LValue);
          end;

          ActiveChildForm.Crop.CropAreaWidth := LValue;
        except
          edtCropWidth.Text := IntToStr(ActiveChildForm.Crop.CropAreaWidth);
        end;

        // update the crop tool display
        ActiveChildForm.Crop.DrawShield;

        if Assigned(ActiveChildForm.CropHandleLayer) then
        begin
          ActiveChildForm.CropHandleLayer.Bitmap.Clear($00000000);
          
          ActiveChildForm.Crop.DrawCropBorder(
            ActiveChildForm.CropHandleLayer.Bitmap.Canvas,
            ActiveChildForm.CropHandleLayerOffsetVector);

          ActiveChildForm.Crop.DrawCropHandles(
            ActiveChildForm.CropHandleLayer.Bitmap.Canvas,
            ActiveChildForm.CropHandleLayerOffsetVector);

          ActiveChildForm.CropHandleLayer.Bitmap.Changed;
        end;
      end;
    end;
  end;
end;

procedure TfrmMain.edtCropHeightChange(Sender: TObject);
var
  LValue: Integer;
begin
  if ActiveChildForm.Crop <> nil then
  begin
    if edtCropHeight.Text <> '' then
    begin
      if FCanChange then
      begin
        try
          LValue := StrToInt(edtCropHeight.Text);

          if LValue < 0 then
          begin
            LValue             := 0;
            edtCropHeight.Text := IntToStr(LValue);
          end;

          ActiveChildForm.Crop.CropAreaHeight := LValue;
        except
          edtCropHeight.Text := IntToStr(ActiveChildForm.Crop.CropAreaHeight);
        end;

        // update the crop tool display
        ActiveChildForm.Crop.DrawShield;

        if Assigned(ActiveChildForm.CropHandleLayer) then
        begin
          ActiveChildForm.CropHandleLayer.Bitmap.Clear($00000000);
          
          ActiveChildForm.Crop.DrawCropBorder(
            ActiveChildForm.CropHandleLayer.Bitmap.Canvas,
            ActiveChildForm.CropHandleLayerOffsetVector);

          ActiveChildForm.Crop.DrawCropHandles(
            ActiveChildForm.CropHandleLayer.Bitmap.Canvas,
            ActiveChildForm.CropHandleLayerOffsetVector);

          ActiveChildForm.CropHandleLayer.Bitmap.Changed;
        end;
      end;
    end;
  end;
end;

procedure TfrmMain.btnCommitCropClick(Sender: TObject);
begin
  ActiveChildForm.CommitCrop;

  edtCropWidth.Text  := '';
  edtCropHeight.Text := '';
end;

procedure TfrmMain.btnCancelCropClick(Sender: TObject);
begin
  ActiveChildForm.CancelCrop;
  
  edtCropWidth.Text  := '';
  edtCropHeight.Text := '';
end;

procedure TfrmMain.ShieldCroppedArea(Sender: TObject);
begin
  if chckbxShieldCroppedArea.Checked then
  begin
    pnlCropShield.Top     := pnlCropOptions.Top + pnlCropOptions.Height;
    pnlCropShield.Visible := True;
  end
  else
  begin
    pnlCropShield.Visible := False;
  end;

  if Assigned(ActiveChildForm.Crop) then
  begin
    ActiveChildForm.Crop.IsShieldCroppedArea := chckbxShieldCroppedArea.Checked;
    ActiveChildForm.Crop.DrawShield;
    ActiveChildForm.CropHandleLayer.Bitmap.Changed;
  end;
end;

procedure TfrmMain.chckbxResizeCropClick(Sender: TObject);
begin
  if chckbxResizeCrop.Checked then
  begin
    if pnlCropShield.Visible then
    begin
      pnlResizeCrop.Top := pnlCropShield.Top + pnlCropShield.Height;
    end
    else
    begin
      pnlResizeCrop.Top := pnlCropOptions.Top + pnlCropOptions.Height;
    end;

    pnlResizeCrop.Visible := True;
  end
  else
  begin
    pnlResizeCrop.Visible := False;
  end;
end;

procedure TfrmMain.shpCroppedShieldColorMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(ActiveChildForm.Crop) then
  begin
    dmMain.clrdlgRGB.Color := ActiveChildForm.Crop.ShieldWinColor;

    if dmMain.clrdlgRGB.Execute then
    begin
      shpCroppedShieldColor.Brush.Color  := dmMain.clrdlgRGB.Color;
      ActiveChildForm.Crop.ShieldColor32 := Color32(dmMain.clrdlgRGB.Color);

      ActiveChildForm.Crop.DrawShield;
      ActiveChildForm.CropHandleLayer.Bitmap.Changed;
    end;
  end;
end;

procedure TfrmMain.ChangeCroppedShieldOpacity(Sender: TObject);
begin
  if FCanChange then
  begin
    try
      updwnCroppedShieldOpacity.Position := StrToInt(edtCroppedShieldOpacity.Text);

      if ActiveChildForm <> nil then
      begin
        if Assigned(ActiveChildForm.Crop) then
        begin
          ActiveChildForm.Crop.ShieldOpacity := updwnCroppedShieldOpacity.Position;
          ActiveChildForm.Crop.DrawShield;
          ActiveChildForm.CropHandleLayer.Bitmap.Changed;
        end;
      end;

    except
      edtCroppedShieldOpacity.Text := IntToStr(updwnCroppedShieldOpacity.Position);
    end;
  end;
end;

procedure TfrmMain.edtResizeCropWidthChange(Sender: TObject);
var
  LMinWidth, LMaxWidth, LValue:Integer;
begin
  if Assigned(ActiveChildForm.Crop) then
  begin
    if edtResizeCropWidth.Text <> '' then
    begin
      if FCanChange then
      begin
        LMinWidth := 16;
        LMaxWidth := ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width;
        try
          LValue := StrToInt(edtResizeCropWidth.Text);
          EnsureValueInRange(LValue, LMinWidth, LMaxWidth);
          ActiveChildForm.Crop.ResizeW := LValue;
        except
          edtResizeCropWidth.Text := IntToStr(ActiveChildForm.Crop.ResizeW);
        end;
      end;
    end;
  end;
end;

procedure TfrmMain.edtResizeCropWidthExit(Sender: TObject);
begin
  FCanChange := False;
  try
    if Assigned(ActiveChildForm.Crop) then
    begin
      if edtResizeCropWidth.Text <> '' then
      begin
        edtResizeCropWidth.Text := IntToStr(ActiveChildForm.Crop.ResizeW);
      end;
    end;
  finally
    FCanChange := True;
  end;
end;

procedure TfrmMain.edtResizeCropHeightChange(Sender: TObject);
var
  LMinHeight, LMaxHeight, LValue:Integer;
begin
  if ActiveChildForm.Crop <> nil then
  begin
    if edtResizeCropHeight.Text <> '' then
    begin
      if FCanChange then
      begin
        LMinHeight := 16;
        LMaxHeight := ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height;
        try
          LValue := StrToInt(edtResizeCropHeight.Text);
          EnsureValueInRange(LValue, LMinHeight, LMaxHeight);
          ActiveChildForm.Crop.ResizeH := LValue;
        except
          edtResizeCropHeight.Text := IntToStr(ActiveChildForm.Crop.ResizeH);
        end;
      end;
    end;
  end;
end;

procedure TfrmMain.edtResizeCropHeightExit(Sender: TObject);
begin
  FCanChange := False;
  try
    if Assigned(ActiveChildForm.Crop) then
    begin
      if edtResizeCropHeight.Text <> '' then
      begin
        edtResizeCropHeight.Text := IntToStr(ActiveChildForm.Crop.ResizeH);
      end;
    end;
  finally
    FCanChange := True;
  end;
end;

procedure TfrmMain.btnShowCropedAreaSizeClick(Sender: TObject);
begin
  if Assigned(ActiveChildForm) then
  begin
    if Assigned(ActiveChildForm.Crop) then
    begin
      edtResizeCropWidth.Text  := IntToStr(ActiveChildForm.Crop.CropAreaWidth);
      edtResizeCropHeight.Text := IntToStr(ActiveChildForm.Crop.CropAreaHeight);
    end;
  end;
end;

procedure TfrmMain.ChangePaintBucketFillSource(Sender: TObject);
begin
  case cmbbxPaintBucketFillSource.ItemIndex of
    0:
      begin
        FPaintBucketFillSource := pbfsForeColor;
      end;

    1:
      begin
        FPaintBucketFillSource := pbfsBackColor;
      end;
      
    2:
      begin
        FPaintBucketFillSource := pbfsPattern;
      end;
  end;

  UpdatePaintBucketOptions;
end;

procedure TfrmMain.ChangePaintBucketFillMode(Sender: TObject);
begin
  FPaintBucketBlendMode := TBlendMode32(cmbbxPaintBucketFillMode.ItemIndex);
end;

procedure TfrmMain.ChangePaintBucketOpacity(Sender: TObject);
begin
  if FCanChange then
  begin
    try
      updwnPaintBucketOpacity.Position := StrToInt(edtPaintBucketOpacity.Text);
      FPaintBucketOpacity              := updwnPaintBucketOpacity.Position;
    except
      edtPaintBucketOpacity.Text := IntToStr(FPaintBucketOpacity);
    end;
  end;
end;

procedure TfrmMain.ChangePaintBucketTolerance(Sender: TObject);
begin
  if FCanChange then
  begin
    try
      udpwnPaintBucketTolerance.Position := StrToInt(edtPaintBucketTolerance.Text);
      FPaintBucketTolerance              := udpwnPaintBucketTolerance.Position;
    except
      edtPaintBucketTolerance.Text := IntToStr(FPaintBucketTolerance);
    end;
  end;
end;

procedure TfrmMain.spdbtnOpenPatternForFillClick(Sender: TObject);
var
  p: TPoint;
begin
  GetCursorPos(p);
  frmPatterns.Left            := p.X;
  frmPatterns.Top             := p.Y;
  frmPatterns.PatternListUser := pluPaintBucket;
  frmPatternS.Show;
end;

procedure TfrmMain.spdbtnPaintBucketAdvancedOptionsClick(Sender: TObject);
var
  p: TPoint;
begin
  GetCursorPos(p);
  frmPaintBucketAdvancedOptions.Left := p.X;
  frmPaintBucketAdvancedOptions.Top  := p.Y;
  frmPaintBucketAdvancedOptions.Show;
end;

procedure TfrmMain.ChangeEraserTools(Sender: TObject);

    procedure DeleteLastEraser;
    begin
      if Assigned(FGMEraser) then
      begin
        FreeAndNil(FGMEraser);
      end;
    end;

var
  LLastEraserTool: TgmEraserTool;
begin
  // prevent from the click event execute twice
  if not FCanExecClick then
  begin
    Exit;
  end;

  // change Eraser Tool button on the main tool bar
  if Sender is TSpeedButton then
  begin
    spdbtnEraserTools.Glyph.Assign(TSpeedButton(Sender).Glyph);
    spdbtnEraserTools.Hint := TSpeedButton(Sender).Hint;
  end;

  LLastEraserTool := FEraserTool;

  if Sender = spdbtnEraser then
  begin
    FEraserTool := etEraser;

    if FEraserTool <> LLastEraserTool then
    begin
      DeleteLastEraser;
      FGMEraser := TgmEraser.Create;
    end;
  end
  else
  if Sender = spdbtnBackgroundEraser then
  begin
    FEraserTool := etBackgroundEraser;

    if FEraserTool <> LLastEraserTool then
    begin
      DeleteLastEraser;
      FGMEraser := TgmBackgroundEraser.Create;
    end;
  end
  else
  if Sender = spdbtnMagicEraser then
  begin
    FEraserTool := etMagicEraser;
  end;

  if Assigned(ActiveChildForm) then
  begin
    ActiveChildForm.ChangeImageCursorByEraserTools;
  end;
  
  UpdateEraserOptions;
  ShowStatusInfoOnStatusBar;
end;

procedure TfrmMain.spdbtnSelectEraserStrokeClick(Sender: TObject);
var
  p: TPoint;
begin
  GetCursorPos(p);
  frmPaintingBrush.Left           := p.X;
  frmPaintingBrush.Top            := p.Y;
  frmPaintingBrush.StrokeListUser := sluEraser;
  frmPaintingBrush.Show;
end;

procedure TfrmMain.spdbtnEraserAdvancedOptionsClick(Sender: TObject);
var
  p: TPoint;
begin
  GetCursorPos(p);
  frmEraserAdvancedOptions.Left := p.X;
  frmEraserAdvancedOptions.Top  := p.Y;
  frmEraserAdvancedOptions.Show;
end;

procedure TfrmMain.spdbtnEraserDynamicsClick(Sender: TObject);
var
  p: TPoint;
begin
  GetCursorPos(p);
  frmBrushDynamics.Left := p.X;
  frmBrushDynamics.Top  := p.Y;
  frmBrushDynamics.Show;
end;

procedure TfrmMain.ChangeEraserModeLimit(Sender: TObject);
begin
  case FEraserTool of
    etEraser:
      begin
        FErasingMode := GetErasingMode(cmbbxEraserModeLimit.ItemIndex);
      end;

    etBackgroundEraser:
      begin
        FBackgroundEraserLimit := GetErasingLimit(cmbbxEraserModeLimit.ItemIndex);
      end;
  end;

  UpdateEraserOptions;
end;

procedure TfrmMain.ChangeEraserSampling(Sender: TObject);
begin
  FEraserSamplingMode := TgmBackgroundSamplingMode(cmbbxEraserSampling.ItemIndex);
end;

procedure TfrmMain.ChangeEraserOpacityPressure(Sender: TObject);
begin
  if FCanChange then
  begin
    try
      updwnEraserOpacityPressure.Position := StrToInt(edtEraserOpacityPressure.Text);

      case FEraserTool of
        etEraser:
          begin
            case FErasingMode of
              emPaintBrush:
                begin
                  FErasingOpacity := updwnEraserOpacityPressure.Position;
                end;
                
              emAirBrush:
                begin
                  FAirErasingPressure := updwnEraserOpacityPressure.Position;
                end;
            end;
          end;

        etMagicEraser:
          begin
            FErasingOpacity := updwnEraserOpacityPressure.Position;
          end;
      end;
      
    except
      case FEraserTool of
        etEraser:
          begin
            case FErasingMode of
              emPaintBrush:
                begin
                  edtEraserOpacityPressure.Text := IntToStr(FErasingOpacity);
                end;
                
              emAirBrush:
                begin
                  edtEraserOpacityPressure.Text := IntToStr(FAirErasingPressure);
                end;
            end;
          end;
          
        etMagicEraser:
          begin
            edtEraserOpacityPressure.Text := IntToStr(FErasingOpacity);
          end;
      end;
    end;
  end;
end;

procedure TfrmMain.ChangeEraserInterval(Sender: TObject);
begin
  if FCanChange then
  begin
    try
      updwnEraserInterval.Position := StrToInt(edtEraserInterval.Text);

      case FEraserTool of
        etEraser:
          begin
            case FErasingMode of
              emPaintBrush:
                begin
                  FErasingInterval := updwnEraserInterval.Position;
                end;
                
              emAirBrush:
                begin
                  FAirErasingInterval := updwnEraserInterval.Position;
                end;
            end;
          end;

        etBackgroundEraser:
          begin
            case FBackgroundEraserLimit of
              belDiscontiguous:
                begin
                  FAirErasingInterval := updwnEraserInterval.Position;
                end;
                
              belContiguous:
                begin
                  FErasingInterval := updwnEraserInterval.Position;
                end;
            end;
          end;
      end;
      
    except
      case FEraserTool of
        etEraser:
          begin
            case FErasingMode of
              emPaintBrush:
                begin
                  edtEraserInterval.Text := IntToStr(FErasingInterval);
                end;
                
              emAirBrush:
                begin
                  edtEraserInterval.Text := IntToStr(FAirErasingInterval);
                end;
            end;
          end;
          
        etBackgroundEraser:
          begin
            case FBackgroundEraserLimit of
              belDiscontiguous:
                begin
                  edtEraserInterval.Text := IntToStr(FAirErasingInterval);
                end;
                
              belContiguous:
                begin
                  edtEraserInterval.Text := IntToStr(FErasingInterval);
                end;
            end;
          end;
      end;
    end;
  end;
end;

procedure TfrmMain.ChangeEraserTolerance(Sender: TObject);
begin
  if FCanChange then
  begin
    try
      updwnEraserTolerance.Position := StrToInt(edtEraserTolerance.Text);
      FErasingTolerance             := updwnEraserTolerance.Position;
    except
      edtEraserTolerance.Text := IntToStr(FErasingTolerance);
    end;
  end;
end;

procedure TfrmMain.ChangePenTools(Sender: TObject);
begin
  // prevent from the click event execute twice
  if not FCanExecClick then
  begin
    Exit;
  end;

  // change Pen Path Tool button on the main tool bar
  if Sender is TSpeedButton then
  begin
    spdbtnPenTools.Glyph.Assign(TSpeedButton(Sender).Glyph);
    spdbtnPenTools.Hint := TSpeedButton(Sender).Hint;
  end;

  if Sender = spdbtnPathComponentSelectionTool then
  begin
    FPenTool := ptPathComponentSelection;
  end
  else if Sender = spdbtnDirectSelectionTool then
  begin
    FPenTool := ptDirectSelection;
  end
  else if Sender = spdbtnPenTool then
  begin
    FPenTool := ptPenTool;
  end
  else if Sender = spdbtnAddAnchorPointTool then
  begin
    FPenTool := ptAddAnchorPoint;
  end
  else if Sender = spdbtnDeleteAnchorPointTool then
  begin
    FPenTool := ptDeleteAnchorPoint;
  end
  else if Sender = spdbtnConvertPointTool then
  begin
    FPenTool := ptConvertPoint;
  end;

  FActivePenTool := FPenTool;
  ShowStatusInfoOnStatusBar;

  if ActiveChildForm <> nil then
  begin
    case FPenTool of
      ptPathComponentSelection:
        begin
          if Assigned(ActiveChildForm.PathPanelList.SelectedPanel) then
          begin
            if Assigned(ActiveChildForm.FPenPath) then
            begin
              if ActiveChildForm.FPenPath.CurveSegmentsList.SelectedCount > 0 then
              begin
                ActiveChildForm.FPenPath.CurveSegmentsList.IsSelectedAll := True;
                ActiveChildForm.FPenPath.CurveSegmentsList.IsSelected    := False;
              end;
            end;
          end;
        end;

      { When switch to the Pen Tool --

        If there is any full selected path, then deselect all paths, and switch
        the path list to Add New Path state; if there is no full selected path,
        but there is a selected path, if the path is closed, then switch the
        path list to Ajustment state, if the path is not closed, then switch the
        path list Add Next Anchor Point state. }
      ptPenTool:
        begin
          if Assigned(ActiveChildForm.PathPanelList.SelectedPanel) then
          begin
            if ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.GetWholeSelectedPathsCount > 0 then
            begin
              ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.DeselectAllPaths;
              ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.PathListState := plsAddNewPath;
            end
            else
            begin
              if Assigned(ActiveChildForm.FPenPath) then
              begin
                if ActiveChildForm.FPenPath.CurveSegmentsList.IsClosed then
                begin
                  ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.PathListState := plsAdjust;
                end
                else
                begin
                  ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.PathListState := plsAddNextAnchorPoint;
                end;
              end
              else
              begin
                ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.PathListState := plsAddNewPath;
              end;
            end;
          end;
        end;
    end;

    if Assigned(ActiveChildForm.PathPanelList.SelectedPanel) then
    begin
      // clear paths
      ActiveChildForm.PathLayer.Bitmap.Clear($00000000);
      
      ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.DrawAllPaths(
        ActiveChildForm.PathLayer.Bitmap.Canvas, pmNotXor, Point(0, 0) );
    end;

    ActiveChildForm.ChangeImageCursorByPenTools;
  end;
end;

procedure TfrmMain.ChangeMeasureUnit(Sender: TObject);
begin
  UpdateMeasureOptions;
end;

procedure TfrmMain.ClearMeasureInfoClick(Sender: TObject);
begin
  ActiveChildForm.DeleteMeasureLine;
  UpdateMeasureOptions;
end;

procedure TfrmMain.ChangeShapeRegionTools(Sender: TObject);
var
  LShapeRegionLayerPanel: TgmShapeRegionLayerPanel;
  LLastShapeRegionTool  : TgmShapeRegionTool;
begin
  // prevent from the click event execute twice
  if not FCanExecClick then
  begin
    Exit;
  end;

  // change Shape Tool button on the main tool bar
  if Sender is TSpeedButton then
  begin
    spdbtnShapeTools.Glyph.Assign(TSpeedButton(Sender).Glyph);
    spdbtnShapeTools.Hint := TSpeedButton(Sender).Hint;
  end;

  LLastShapeRegionTool := FShapeRegionTool;

  if ActiveChildForm <> nil then
  begin
    if Sender = spdbtnShapeMove then
    begin
      ActiveChildForm.ShapeDrawingState := dsNotDrawing;
    end
    else
    begin
      ActiveChildForm.ShapeDrawingState := dsNewFigure;
    end;
  end;

  if Sender = spdbtnShapeMove then
  begin
    FShapeRegionTool := srtMove;
  end
  else if Sender = spdbtnShapeRectangle then
  begin
    FShapeRegionTool := srtRectangle;
  end
  else if Sender = spdbtnShapeRoundRect then
  begin
    FShapeRegionTool := srtRoundedRect;
  end
  else if Sender = spdbtnShapeEllipse then
  begin
    FShapeRegionTool := srtEllipse;
  end
  else if Sender = spdbtnShapeRegularPolygon then
  begin
    FShapeRegionTool := srtPolygon;
  end
  else if Sender = spdbtnShapeLine then
  begin
    FShapeRegionTool := srtLine;
  end;

  UpdateShapeOptions;
  ShowStatusInfoOnStatusBar;

  if ActiveChildForm <> nil then
  begin
    ActiveChildForm.ChangeImageCursorByShapeTools;

    if FShapeRegionTool = srtMove then
    begin
      if LLastShapeRegionTool <> srtMove then
      begin
        if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
        begin
          if ActiveChildForm.ShapeOutlineLayer = nil then
          begin
            ActiveChildForm.CreateShapeOutlineLayer;
            ActiveChildForm.CalcShapeOutlineLayerOffsetVector;
            ActiveChildForm.ShapeOutlineLayer.Bitmap.Clear($00000000);
          end;

          LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);
          LShapeRegionLayerPanel.ShapeOutlineList.BackupCoordinates;

          LShapeRegionLayerPanel.ShapeOutlineList.DrawShapesBoundary(
            ActiveChildForm.ShapeOutlineLayer.Bitmap.Canvas, HANDLE_RADIUS,
            ActiveChildForm.OutlineOffsetVector, pmNotXor);

          LShapeRegionLayerPanel.ShapeOutlineList.DrawShapesBoundaryHandles(
            ActiveChildForm.ShapeOutlineLayer.Bitmap.Canvas, HANDLE_RADIUS,
            ActiveChildForm.OutlineOffsetVector, pmNotXor);

          ActiveChildForm.ShapeOutlineLayer.Bitmap.Changed;
        end;
      end;
    end
    else
    begin
      if LLastShapeRegionTool = srtMove then
      begin
        if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
        begin
          if ActiveChildForm.ShapeOutlineLayer = nil then
          begin
            ActiveChildForm.CreateShapeOutlineLayer;
            ActiveChildForm.CalcShapeOutlineLayerOffsetVector;
          end;

          ActiveChildForm.ShapeOutlineLayer.Bitmap.Clear($00000000);
          LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

          if not LShapeRegionLayerPanel.IsDismissed then
          begin
            LShapeRegionLayerPanel.ShapeOutlineList.DrawAllOutlines(
              ActiveChildForm.ShapeOutlineLayer.Bitmap.Canvas,
              ActiveChildForm.OutlineOffsetVector, pmNotXor);
          end;

          ActiveChildForm.ShapeOutlineLayer.Bitmap.Changed;
        end;
      end;
    end;
  end;
end;

procedure TfrmMain.ChangeRegionCombineMode(Sender: TObject);
begin
  // prevent from the click event execute twice
  if not FCanExecClick then
  begin
    Exit;
  end;

  if Sender = spdbtnAddShape then
  begin
    FRegionCombineMode := rcmAdd;
  end
  else if Sender = spdbtnSubtractShape then
  begin
    FRegionCombineMode := rcmSubtract;
  end
  else if Sender = spdbtnIntersectShape then
  begin
    FRegionCombineMode := rcmIntersect;
  end
  else if Sender = spdbtnExcludeOverlapShape then
  begin
    FRegionCombineMode := rcmExcludeOverlap;
  end;
end;

procedure TfrmMain.spdbtnDismissTargetPathClick(Sender: TObject);
var
  LShapeRegionLayerPanel: TgmShapeRegionLayerPanel;
begin
  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
  begin
    LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

    if FShapeRegionTool = srtMove then
    begin
      if ActiveChildForm.ShapeOutlineLayer = nil then
      begin
        ActiveChildForm.CreateShapeOutlineLayer;
      end;

      if ActiveChildForm.ShapeOutlineLayer <> nil then
      begin
        ActiveChildForm.ShapeOutlineLayer.Bitmap.Clear($00000000);

        LShapeRegionLayerPanel.ShapeOutlineList.DrawShapesBoundary(
          ActiveChildForm.ShapeOutlineLayer.Bitmap.Canvas, HANDLE_RADIUS,
          ActiveChildForm.OutlineOffsetVector, pmNotXor);

        LShapeRegionLayerPanel.ShapeOutlineList.DrawShapesBoundaryHandles(
          ActiveChildForm.ShapeOutlineLayer.Bitmap.Canvas, HANDLE_RADIUS,
          ActiveChildForm.OutlineOffsetVector, pmNotXor);

        ActiveChildForm.ShapeOutlineLayer.Bitmap.Changed;
      end;
    end
    else
    begin
      if ActiveChildForm.ShapeOutlineLayer <> nil then
      begin
        ActiveChildForm.DeleteShapeOutlineLayer;
      end;
    end;

    LShapeRegionLayerPanel.IsDismissed := True;
    spdbtnDismissTargetPath.Enabled    := False;
  end;
end;

procedure TfrmMain.edtShapeToolRSWChange(Sender: TObject);
begin
  if FCanChange then
  begin
    try
      updwnShapeToolRSW.Position := StrToInt(edtShapeToolRSW.Text);

      case FShapeRegionTool of
        srtRoundedRect:
          begin
            FShapeCornerRadius := updwnShapeToolRSW.Position;
          end;

        srtPolygon:
          begin
            FShapePolygonSides := updwnShapeToolRSW.Position;
          end;

        srtLine:
          begin
            FLineWeight := updwnShapeToolRSW.Position;
          end;
      end;

    except
      case FShapeRegionTool of
        srtRoundedRect:
          begin
            edtShapeToolRSW.Text := IntToStr(FShapeCornerRadius);
          end;
          
        srtPolygon:
          begin
            edtShapeToolRSW.Text := IntToStr(FShapePolygonSides);
          end;
          
        srtLine:
          begin
            edtShapeToolRSW.Text := IntToStr(FLineWeight);
          end;
      end;
    end;
  end;
end;

procedure TfrmMain.cmbbxFontFamilyChange(Sender: TObject);
begin
  frmRichTextEditor.rchedtRichTextEditor.SelAttributes.Name :=
    cmbbxFontFamily.Items[cmbbxFontFamily.ItemIndex];

  frmRichTextEditor.Show;
end;

procedure TfrmMain.shpFontColorMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  dmMain.clrdlgRGB.Color := shpFontColor.Brush.Color;

  if dmMain.clrdlgRGB.Execute then
  begin
    shpFontColor.Brush.Color := dmMain.clrdlgRGB.Color;
    frmRichTextEditor.rchedtRichTextEditor.SelAttributes.Color := shpFontColor.Brush.Color;
    frmRichTextEditor.Show;
  end;
end;

procedure TfrmMain.cmbbxFontSizeChange(Sender: TObject);
var
  LFontSize: Byte;
begin
  case cmbbxFontSize.ItemIndex of
     0:  LFontSize := 6;
     1:  LFontSize := 8;
     2:  LFontSize := 9;
     3:  LFontSize := 10;
     4:  LFontSize := 11;
     5:  LFontSize := 12;
     6:  LFontSize := 14;
     7:  LFontSize := 16;
     8:  LFontSize := 18;
     9:  LFontSize := 20;
    10:  LFontSize := 22;
    11:  LFontSize := 24;
    12:  LFontSize := 26;
    13:  LFontSize := 28;
    14:  LFontSize := 30;
    15:  LFontSize := 36;
    16:  LFontSize := 48;
    17:  LFontSize := 60;
    18:  LFontSize := 72;
  else
    LFontSize := 0;
  end;

  frmRichTextEditor.rchedtRichTextEditor.SelAttributes.Size := LFontSize;
  frmRichTextEditor.Show;
end;

procedure TfrmMain.tlbtnBoldClick(Sender: TObject);
begin
  with frmRichTextEditor.rchedtRichTextEditor.SelAttributes do
  begin
    if tlbtnBold.Down then
    begin
      Style := Style + [fsBold];
    end
    else
    begin
      Style := Style - [fsBold];
    end;
  end;

  frmRichTextEditor.Show;
end;

procedure TfrmMain.tlbtnItalicClick(Sender: TObject);
begin
  with frmRichTextEditor.rchedtRichTextEditor.SelAttributes do
  begin
    if tlbtnItalic.Down then
    begin
      Style := Style + [fsItalic];
    end
    else
    begin
      Style := Style - [fsItalic];
    end;
  end;

  frmRichTextEditor.Show;
end;

procedure TfrmMain.tlbtnUnderlineClick(Sender: TObject);
begin
  with frmRichTextEditor.rchedtRichTextEditor.SelAttributes do
  begin
    if tlbtnUnderline.Down then
    begin
      Style := Style + [fsUnderline];
    end
    else
    begin
      Style := Style - [fsUnderline];
    end;
  end;

  frmRichTextEditor.Show;
end;

procedure TfrmMain.spdbtnLeftAlignTextClick(Sender: TObject);
begin
  frmRichTextEditor.rchedtRichTextEditor.Paragraph.Alignment := taLeftJustify;
  frmRichTextEditor.Show;
end;

procedure TfrmMain.spdbtnCenterTextClick(Sender: TObject);
begin
  frmRichTextEditor.rchedtRichTextEditor.Paragraph.Alignment := taCenter;
  frmRichTextEditor.Show;
end;

procedure TfrmMain.spdbtnRightAlignTextClick(Sender: TObject);
begin
  frmRichTextEditor.rchedtRichTextEditor.Paragraph.Alignment := taRightJustify;
  frmRichTextEditor.Show;
end;

procedure TfrmMain.spdbtnSelectAllRichTextClick(Sender: TObject);
begin
  frmRichTextEditor.rchedtRichTextEditor.SelectAll;
  frmRichTextEditor.Show;
end;

procedure TfrmMain.spdbtnClearRichTextClick(Sender: TObject);
begin
  frmRichTextEditor.rchedtRichTextEditor.Clear;
  frmRichTextEditor.Show;
end;

procedure TfrmMain.spdbtnCommitEditsClick(Sender: TObject);
var
  LRichTextLayerPanel: TgmRichTextLayerPanel;
  LOldTextStream     : TMemoryStream;
  LHistoryStatePanel : TgmHistoryStatePanel;
begin
  LHistoryStatePanel := nil;

  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
  begin
    LRichTextLayerPanel := TgmRichTextLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

    case LRichTextLayerPanel.TextLayerState of
      tlsNew:
        begin
          ActiveChildForm.CommitEdits;

          // Undo/Redo
          LHistoryStatePanel := TgmTypeToolLayerStatePanel.Create(
            frmHistory.scrlbxHistory,
            dmHistory.bmp32lstHistory.Bitmap[TYPE_TOOL_COMMAND_ICON_INDEX],
            ActiveChildForm.LayerPanelList.CurrentIndex,
            ActiveChildForm.LayerPanelList.SelectedLayerPanel,
            lctNew);
        end;

      tlsModify:
        begin
          LOldTextStream := TMemoryStream.Create;
          try
            LRichTextLayerPanel.CopyStream.Position := 0;
            LOldTextStream.LoadFromStream(LRichTextLayerPanel.CopyStream);
            LOldTextStream.Position := 0;

            ActiveChildForm.CommitEdits;

            // Undo/Redo
            LHistoryStatePanel := TgmEditTypeStatePanel.Create(
              frmHistory.scrlbxHistory,
              dmHistory.bmp32lstHistory.Bitmap[TYPE_TOOL_COMMAND_ICON_INDEX],
              ActiveChildForm.LayerPanelList.CurrentIndex,
              LOldTextStream,
              ActiveChildForm.LayerPanelList.SelectedLayerPanel);
          finally
            LOldTextStream.Free;
          end;
        end;
    end;

    if Assigned(LHistoryStatePanel) then
    begin
      ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);
    end;
  end;
end;

procedure TfrmMain.spdbtnCancelEditsClick(Sender: TObject);
var
  LRichTextLayerPanel: TgmRichTextLayerPanel;
begin
  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
  begin
    LRichTextLayerPanel := TgmRichTextLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

    case LRichTextLayerPanel.TextLayerState of
      tlsNew:
        begin
          frmRichTextEditor.Close;
          ActiveChildForm.LayerPanelList.DeleteSelectedLayerPanel;

          if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature <> lfRichText then
          begin
            ActiveChildForm.DeleteRichTextHandleLayer;
          end
          else
          begin
            ActiveChildForm.UpdateRichTextHandleLayer;
          end;
          
          UpdateTextOptions;
        end;
        
      tlsModify:
        begin
          ActiveChildForm.CancelEdits;
        end;
    end;
  end;
end;

procedure TfrmMain.spdbtnOpenRichTextClick(Sender: TObject);
var
  LRichTextLayerPanel : TgmRichTextLayerPanel;
begin
  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
  begin
    LRichTextLayerPanel := TgmRichTextLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

    if dmMain.OpndlgOpenText.Execute then
    begin
      frmRichTextEditor.rchedtRichTextEditor.Lines.LoadFromFile(dmMain.OpndlgOpenText.FileName);

      LRichTextLayerPanel.TextFileName := dmMain.OpndlgOpenText.FileName;
      frmRichTextEditor.stsbrTextInfo.Panels[0].Text := 'File Name: ' + ExtractFileName(LRichTextLayerPanel.TextFileName);

      frmRichTextEditor.Show;
    end;
  end;
end;

procedure TfrmMain.spdbtnSaveRichTextClick(Sender: TObject);
begin
  SaveNamedTextFile;
  frmRichTextEditor.Show;
end;

procedure TfrmMain.spdbtnSaveRichTextAsClick(Sender: TObject);
begin
  SaveNotNamedTextFile;
  frmRichTextEditor.Show;
end;

procedure TfrmMain.MainToolsDblClick(Sender: TObject);
begin
  if not pnlToolOptions.Visible then
  begin
    pnlToolOptions.Visible := True;
  end;
end;

procedure TfrmMain.imgToolOptionsVisibilityClick(Sender: TObject);
begin
  pnlToolOptions.Visible := not pnlToolOptions.Visible;

  if pnlToolOptions.Visible then
  begin
    imgToolOptionsVisibility.Bitmap.Assign(dmMain.bmp32lstMainTools.Bitmap[IMG_LEFT_TRIPLE_ARROW_INDEX]);
  end
  else
  begin
    imgToolOptionsVisibility.Bitmap.Assign(dmMain.bmp32lstMainTools.Bitmap[IMG_RIGHT_TRIPLE_ARROW_INDEX]);
  end;
end;

procedure TfrmMain.PageControlDockSiteChange(Sender: TObject);
var
  LPageControl: TPageControl;
  i           : Integer;
  LFound      : Boolean;
begin
  if Sender is TPageControl then
  begin
    LPageControl := (Sender as TPageControl);

    if LPageControl.PageCount > 0 then
    begin
      // determine whether or not the Layers tab is active
      LFound := False;
      for i := 0 to (LPageControl.PageCount - 1) do
      begin
        if LPageControl.Pages[i].Caption = 'Layers' then
        begin
          LFound := True;
          Break;
        end;
      end;

      if LFound then
      begin
        if StrComp(PAnsiChar(LPageControl.ActivePage.Caption), 'Layers') = 0 then
        begin
          frmLayer.IsShowingUp := True;

          if Assigned(ActiveChildForm) then
          begin
            ActiveChildForm.LayerPanelList.HideAllLayerPanels;
            ActiveChildForm.LayerPanelList.ShowAllLayerPanels;
          end;
        end
        else
        begin
          frmLayer.IsShowingUp := False;
        end;
      end;

      // determine whether or not the Channels tab is active
      LFound := False;
      for i := 0 to (LPageControl.PageCount - 1) do
      begin
        if LPageControl.Pages[i].Caption = 'Channels' then
        begin
          LFound := True;
          Break;
        end;
      end;

      if LFound then
      begin
        if StrComp(PAnsiChar(LPageControl.ActivePage.Caption), 'Channels') = 0 then
        begin
          frmChannel.IsShowingUp := True;

          if Assigned(ActiveChildForm) then
          begin
            ActiveChildForm.ChannelManager.HideAllChannelPanels;
            ActiveChildForm.ChannelManager.ShowAllChannelPanels;
          end;
        end
        else
        begin
          frmChannel.IsShowingUp := False;
        end;
      end;

      // determine whether or not the Paths tab is active
      LFound := False;
      for i := 0 to (LPageControl.PageCount - 1) do
      begin
        if LPageControl.Pages[i].Caption = 'Paths' then
        begin
          LFound := True;
          Break;
        end;
      end;

      if LFound then
      begin
        if StrComp(PAnsiChar(LPageControl.ActivePage.Caption), 'Paths') = 0 then
        begin
          frmPath.IsShowingUp := True;

          if Assigned(ActiveChildForm) then
          begin
            ActiveChildForm.PathPanelList.HideAllPathPanels;
            ActiveChildForm.PathPanelList.ShowAllPathPanels;
          end;
        end
        else
        begin
          frmPath.IsShowingUp := False;
        end;
      end;

      // determine whether or not the History tab is active
      LFound := False;
      for i := 0 to (LPageControl.PageCount - 1) do
      begin
        if LPageControl.Pages[i].Caption = 'History' then
        begin
          LFound := True;
          Break;
        end;
      end;

      if LFound then
      begin
        if StrComp(PAnsiChar(LPageControl.ActivePage.Caption), 'History') = 0 then
        begin
          frmHistory.IsShowingUp := True;

          if Assigned(ActiveChildForm) then
          begin
            ActiveChildForm.HistoryManager.HideAllPanels;
            ActiveChildForm.HistoryManager.ShowAllPanelsByRightOrder;
          end;
        end
        else
        begin
          frmHistory.IsShowingUp := False;
        end;
      end;
    end;
  end;
end;

procedure TfrmMain.SetCanExecClickMark(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Sender is TSpeedButton then
  begin
    FCanExecClick := (not TSpeedButton(Sender).Down);
  end;
end;

procedure TfrmMain.GhostsWakeUp(WakeUp: Boolean);
begin
  if WakeUp then
  begin
    FGhosts := TList.Create;
  end
  else
  begin
    FreeAndNil(FGhosts);
  end;
end;

procedure TfrmMain.GhostsFly;
var
  i : integer;
begin
  if not Assigned(FGhosts) then Exit;
  
  for i := 0 to (FGhosts.Count -1) do
  begin
    TfrmGhost(FGhosts[i]).Fly;
  end;
end;

procedure TfrmMain.GhostsFade(Fade: Boolean);
var
  i : integer;
begin
  if not Assigned(FGhosts) then
  begin
    Exit;
  end;

  for i := 0 to (FGhosts.Count -1) do
  begin
    with TfrmGhost(FGhosts[i]) do
    begin
      if not Untouchable then
      begin
        if Fade then
          Blending
        else
          Opaqueing;
      end;

      Scaring := Fade;
    end;
  end;
end;

procedure TfrmMain.WMWINDOWPOSCHANGING(var Msg: TWMWINDOWPOSCHANGING);
//http://delphi.about.com/od/formsdialogs/a/frm_dock_screen.htm
begin
  GhostsFly;
end;

procedure TfrmMain.DetectMousePos(ASender: TObject);
var
  p              : TPoint;
  LLeftGhostArea : TRect;
  LRightGhostArea: TRect;
begin
  //Now, it will only called when "mouse were really moved". not every time.
  p :=  TgmGhostDetect(ASender).Point;

  // if the mouse over the left ghost area, opaqueing the left ghost form
  with LLeftGhostArea do
  begin
    TopLeft := pnlToolBoxHolder.ClientToScreen( Point(0, 0) );

    BottomRight := pnlToolOptions.ClientToScreen( Point(pnlToolOptions.Width,
                                                        pnlToolOptions.Height) );
  end;

  with LRightGhostArea do
  begin
    TopLeft := pnlRightDockArea.ClientToScreen( Point(0, 0) );

    BottomRight := pnlRightDockArea.ClientToScreen( Point(pnlRightDockArea.Width,
                                                          pnlRightDockArea.Height) );
  end;

  if ( TfrmGhost(FGhosts[LEFT_GHOST_FORM_INDEX]).Scaring ) and
     ( not TfrmGhost(FGhosts[LEFT_GHOST_FORM_INDEX]).Untouchable ) then
  begin
    if Windows.PtInRect(LLeftGhostArea, p) then
    begin
      TfrmGhost(FGhosts[LEFT_GHOST_FORM_INDEX]).Opaqueing;
    end
    else
    begin
      TfrmGhost(FGhosts[LEFT_GHOST_FORM_INDEX]).Blending;
    end;
  end;

  if ( TfrmGhost(FGhosts[RIGHT_GHOST_FORM_INDEX]).Scaring ) and
     ( not TfrmGhost(FGhosts[RIGHT_GHOST_FORM_INDEX]).Untouchable ) then
  begin
    if Windows.PtInRect(LRightGhostArea, p) then
    begin
      TfrmGhost(FGhosts[RIGHT_GHOST_FORM_INDEX]).Opaqueing;
    end
    else
    begin
      TfrmGhost(FGhosts[RIGHT_GHOST_FORM_INDEX]).Blending;
    end;
  end;
end;

procedure TfrmMain.spdbtnGhostClick(Sender: TObject);
begin
  GhostsFade(spdbtnGhost.Down);
end;

procedure TfrmMain.spdbtnUntouchedClick(Sender: TObject);
var
  i: Integer;
begin
  if not Assigned(FGhosts) then
  begin
    Exit;
  end;

  for i := 0 to (FGhosts.Count -1) do
  begin
    with  TfrmGhost(FGhosts[i]) do
    begin
      Untouchable := spdbtnUntouched.Down;

      if Untouchable then
        Blending
      else
        Opaqueing;
    end;
  end;
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  GhostsFly;
end;

end.
