{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

unit gmLayerPanelCommands;

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

{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_CAST OFF}

interface

uses
{ Standard }
  Windows, SysUtils, Graphics, Classes,
{ Graphics32 }
  GR32,
{ GraphicsMagic Package Lib }
  gmGradient,
{ GraphicsMagic }
  gmCommands,
  gmLayerAndChannel,
  gmLevelsTool,
  gmCurvesTool,
  gmColorBalance,
  gmShapes,
  gmFigures,
  gmSelection,
  gmResamplers,
  gmCrop,
  gmChannelMixer,
  gmTypes;

type
  TgmLayerCommandType = (lctNone, lctNew, lctDelete, lctModification);

  TgmLayerArrangementStyle = (lasBringToFront,
                              lasBringForward,
                              lasSendBackward,
                              lasSendToBack);

  TgmMaskCommandType = (mctNone,
                        mctAddLayerMask,
                        mctApplyLayerMask,
                        mctDiscardLayerMask);

  TgmRegionCommandType = (rctCreateRegionLayer,
                          rctAddRegion,
                          rctDeleteRegionLayer);

  TgmLockFigureMode = (lfmLock, lfmUnlock);

  TgmSelectFigureMode = (sfmSelect, sfmDeselect);

  TgmMergeLayerMode = (mlmFlatten, mlmMergeDown, mlmMergeVisible);

//-- TgmBlendingChangeLayerCommand ---------------------------------------------

  TgmBlendingChangeLayerCommand = class(TgmCommand)
  private
    FOldBlendModeIndex: Integer;
    FNewBlendModeIndex: Integer;
  public
    constructor Create(
      const ALayerIndex, AOldBlendModeIndex, ANewBlendModeIndex: Integer);

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmOpacityChangeLayerCommand ----------------------------------------------

  TgmOpacityChangeLayerCommand = class(TgmCommand)
  private
    FOldOpacity: Byte;
    FNewOpacity: Byte;
  public
    constructor Create(const ALayerIndex: Integer;
      const AOldOpacity, ANewOpacity: Byte);

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmSolidColorLayerCommand -------------------------------------------------

  TgmSolidColorLayerCommand = class(TgmCommand)
  private
    FLayerName       : string;
    FFillColor       : TColor;
    FModifiedColor   : TColor;
    FLayerCommandType: TgmLayerCommandType;

    procedure CreateSolidColorLayer;
  public
    constructor Create(const ALayerIndex: Integer;
      const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType;
      const AModifiedColor: TColor = clBlack);

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmGradientFillLayerCommand -----------------------------------------------

  TgmGradientFillLayerCommand = class(TgmCommand)
  private
    FLayerName           : string;
    FGradient            : TgmGradientItem;
    FOldGradient         : TgmGradientItem;
    FGradientFillSettings: TgmGradientFillSettings;
    FOldFillSettings     : TgmGradientFillSettings;
    FLayerCommandType    : TgmLayerCommandType;

    procedure CreateGradientFillLayer;
  public
    constructor Create(const ALayerIndex: Integer;
      const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType);

    destructor Destroy; override;

    procedure RollBack; override;
    procedure Execute; override;
  end;

//-- TgmPatternLayerCommand ----------------------------------------------------

  TgmPatternLayerCommand = class(TgmCommand)
  private
    FLayerName       : string;
    FScale           : Double;
    FOldScale        : Double;
    FPatternBitmap   : TBitmap32;
    FOldPatternBitmap: TBitmap32;
    FLayerCommandType: TgmLayerCommandType;

    procedure CreatePatternLayer;
  public
    constructor Create(const ALayerIndex: Integer;
      const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType);

    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmLevelsLayerCommand -----------------------------------------------------

  TgmLevelsLayerCommand = class(TgmCommand)
  private
    FLayerName       : string;
    FLevelsTool      : TgmLevelsTool;
    FOldLevelsTool   : TgmLevelsTool;
    FLayerCommandType: TgmLayerCommandType;

    procedure CreateLevelsLayer;
  public
    constructor Create(const ALayerIndex: Integer;
      const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType);

    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmCurvesLayerCommand -----------------------------------------------------

  TgmCurvesLayerCommand = class(TgmCommand)
  private
    FLayerName       : string;
    FCurvesTool      : TgmCurvesTool;
    FOldCurvesTool   : TgmCurvesTool;
    FLayerCommandType: TgmLayerCommandType;

    procedure CreateCurvesLayer;
  public
    constructor Create(const ALayerIndex: Integer;
      const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType);

    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmColorBalanceLayerCommand -----------------------------------------------

  TgmColorBalanceLayerCommand = class(TgmCommand)
  private
    FLayerName       : string;
    FColorBalance    : TgmColorBalance;
    FOldColorBalance : TgmColorBalance;
    FLayerCommandType: TgmLayerCommandType;

    procedure CreateColorBalanceLayer;
  public
    constructor Create(const ALayerIndex: Integer;
      const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType);

    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmBrightContrastLayerCommand ---------------------------------------------

  TgmBrightContrastLayerCommand = class(TgmCommand)
  private
    FLayerName       : string;
    FBrightness      : Integer;
    FContrast        : Integer;
    FOldBrightness   : Integer;
    FOldContrast     : Integer;
    FLayerCommandType: TgmLayerCommandType;

    procedure CreateBrightContrastLayer;
  public
    constructor Create(const ALayerIndex: Integer;
      const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType);

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmHLSLayerCommand --------------------------------------------------------

  TgmHLSLayerCommand = class(TgmCommand)
  private
    FLayerName       : string;
    FHue             : Integer;
    FLV              : Integer;
    FSaturation      : Integer;
    FMode            : TgmHueSaturationAdjustMode;
    FLayerCommandType: TgmLayerCommandType;

    FOldH            : Integer;
    FOldLV           : Integer;
    FOldS            : Integer;
    FOldMode         : TgmHueSaturationAdjustMode;

    procedure CreateHLSLayer;
  public
    constructor Create(const ALayerIndex: Integer; const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType);

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmChannelMixerLayerCommand -----------------------------------------------

  TgmChannelMixerLayerCommand = class(TgmCommand)
  private
    FLayerName       : string;
    FPreview         : Boolean;
    FOldPreview      : Boolean;
    FChannelMixer    : TgmChannelMixer;
    FOldChannelMixer : TgmChannelMixer;
    FLayerCommandType: TgmLayerCommandType;

    procedure CreateChannelMixerLayer;
  public
    constructor Create(const ALayerIndex: Integer; const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType);

    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmGradientMapLayerCommand ------------------------------------------------

  TgmGradientMapLayerCommand = class(TgmCommand)
  private
    FLayerName       : string;
    FGradient        : TgmGradientItem;
    FOldGradient     : TgmGradientItem;
    FReversed        : Boolean;
    FOldReversed     : Boolean;
    FLayerCommandType: TgmLayerCommandType;

    procedure CreateGradientMapLayer;
  public
    constructor Create(const ALayerIndex: Integer; const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType);

    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmInvertLayerCommand -----------------------------------------------------

  TgmInvertLayerCommand = class(TgmCommand)
  private
    FLayerName       : string;
    FLayerCommandType: TgmLayerCommandType;

    procedure CreateInvertLayer;
  public
    constructor Create(const ALayerIndex: Integer; const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType);

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmThresholdLayerCommand --------------------------------------------------

  TgmThresholdLayerCommand = class(TgmCommand)
  private
    FLayerName       : string;
    FLevel           : Byte;
    FOldLevel        : Byte;
    FLayerCommandType: TgmLayerCommandType;

    procedure CreateThresholdLayer;
  public
    constructor Create(const ALayerIndex: Integer; const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType);

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmPosterizeLayerCommand --------------------------------------------------

  TgmPosterizeLayerCommand = class(TgmCommand)
  private
    FLayerName       : string;
    FLevel           : Byte;
    FOldLevel        : Byte;
    FLayerCommandType: TgmLayerCommandType;

    procedure CreatePosterizeLayer;
  public
    constructor Create(const ALayerIndex: Integer; const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType);

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmStandardLayerCommand ---------------------------------------------------

  // For background and transparent layer.
  TgmStandardLayerCommand = class(TgmCommand)
  private
    FLayerCommandType   : TgmLayerCommandType;
    { Duplicated Data from a Background or Tranparent Layer and Panel }
    FLayerFeature       : TgmLayerFeature;
    FLocation           : TFloatRect;
    FLayerBitmap        : TBitmap32;
    FLastAlphaChannelBmp: TBitmap32;
    FMask               : TBitmap32;
    FBlendModeIndex     : Integer;
    FLayerMasterAlpha   : Byte;
    FDuplicated         : Boolean;
    FLockTransparency   : Boolean;
    FHasMask            : Boolean;
    FMaskLinked         : Boolean;
    FLayerName          : string;
    FLayerProcessStage  : TgmLayerProcessStage;
    FPrevProcessStage   : TgmLayerProcessStage;

    procedure DuplicateData(const APanel: TgmLayerPanel);
    procedure CreateLayerByData;
  public
    constructor Create(const ALayerIndex: Integer; const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType);

    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmDuplicateLayerCommand --------------------------------------------------

  TgmDuplicateLayerCommand = class(TgmCommand)
  private
    FLayerName      : string;
    FDuplicatedIndex: Integer;
  public
    constructor Create(const ACurrentIndex, ADuplicatedIndex: Integer;
      const ALayerName: string);

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmLayerPropertiesCommand -------------------------------------------------

  TgmLayerPropertiesCommand = class(TgmCommand)
  private
    FOldName: string;
    FNewName: string;
  public
    constructor Create(const ALayerOldName, ALayerNewName: string);

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmArrangeLayerCommand ----------------------------------------------------

  TgmArrangeLayerCommand = class(TgmCommand)
  private
    FArrangementStyle: TgmLayerArrangementStyle;
    FOldIndex        : Integer;
    FNewIndex        : Integer;
    FUndoIndex       : Integer;
    FRedoIndex       : Integer;

    function GetCommandName: string;
    procedure ProcessAfterArrangeCommandDone;
  public
    constructor Create(const AOldIndex, ANewIndex: Integer;
      const AStyle: TgmLayerArrangementStyle);

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmLayerMaskCommand -------------------------------------------------------

  TgmLayerMaskCommand = class(TgmCommand)
  private
    FMaskCommandType     : TgmMaskCommandType;
    FAlphaChannelFileName: string; // we save the alpha and mask data to disk temporarily for save memory
    FMaskFileName        : string;
    FOldLayerBmpFileName : string;
    FOldSelection        : TgmSelection;  // remember old selection if it is exists
    FOldMaskLinked       : Boolean;

    function GetCommandName: string;
  public
    constructor Create(const AMaskCommandType: TgmMaskCommandType;
      const AOldSelection: TgmSelection);
      
    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmLinkMaskCommand --------------------------------------------------------

  TgmLinkMaskCommand = class(TgmCommand)
  public
    constructor Create(const ALayerPanelIndex: Integer);
    
    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmUnlinkMaskCommand ------------------------------------------------------

  TgmUnlinkMaskCommand = class(TgmCommand)
  public
    constructor Create(const ALayerPanelIndex: Integer);

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmShapeRegionLayerCommand ------------------------------------------------

  TgmShapeRegionLayerCommand = class(TgmCommand)
  private
    FRegionCommandType    : TgmRegionCommandType;
    FRegionColor          : TColor;
    FBrushStyle           : TBrushStyle;
    FDismissed            : Boolean;
    FRedoIndex            : Integer;
    FOldOutline           : TgmShapeOutline;
    FLayerName            : string;
    FDuplicatedOutlineList: TgmOutlineList;
    FDuplicated           : Boolean;

    function GetCommandName: string;
  public
    constructor Create(const ALayerIndex: Integer;
      const ALayerPanel: TgmLayerPanel;
      const ARegionCommandType: TgmRegionCommandType;
      const AOutline: TgmShapeOutline = nil);

    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmModifyShapeRegionColorCommand ------------------------------------------

  TgmModifyShapeRegionColorCommand = class(TgmCommand)
  private
    FOldColor : TColor;
    FNewColor : TColor;
    FRedoIndex: Integer;
  public
    constructor Create(const AOldColor, ANewColor: TColor);

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmModifyShapeRegionStyleCommand ------------------------------------------

  TgmModifyShapeRegionStyleCommand = class(TgmCommand)
  private
    FOldStyle : TBrushStyle;
    FNewStyle : TBrushStyle;
    FRedoIndex: Integer;
  public
    constructor Create(const AOldStyle, ANewStyle: TBrushStyle);

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmTranslateShapeRegionCommand --------------------------------------------

  TgmTranslateShapeRegionCommand = class(TgmCommand)
  private
    FAccumTranslatedVector: TPoint;
    FRedoIndex            : Integer;
  public
    constructor Create(const AAccumTranslatedVector: TPoint);

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmScaleShapeRegionCommand ------------------------------------------------

  TgmScaleShapeRegionCommand = class(TgmCommand)
  private
    FOldTopLeft, FOldBottomRight: TPoint;
    FNewTopLeft, FNewBottomRight: TPoint;
    FRedoIndex                  : Integer;
  public
    constructor Create(
      const AOldTopLeft, AOldBottomRight, ANewTopLeft, ANewBottomRight: TPoint);

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmFigureLayerCommand -----------------------------------------------------

  TgmFigureLayerCommand = class(TgmCommand)
  private
    FLayerCommandType   : TgmLayerCommandType;
    FLayerName          : string;
    FOldLockFigureBmp   : TBitmap32;
    FOldFigureList      : TgmFigureList;
    FFigureFlag         : TgmFigureFlags;
    FRedoIndex          : Integer;
    FLastAlphaChannelBmp: TBitmap32;
    FMask               : TBitmap32;
    FDuplicated         : Boolean;
    FHasMask            : Boolean;
    FMaskLinked         : Boolean;
    FLayerProcessStage  : TgmLayerProcessStage;
    FPrevProcessStage   : TgmLayerProcessStage;

    function GetCommandName: string;
    procedure CreateOldFigureLayer;
  public
    constructor Create(const ALayerIndex: Integer;
      const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType;
      const AFigureFlag: TgmFigureFlags = ffNone);

    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmAddFigureCommand -------------------------------------------------------

  TgmAddFigureCommand = class(TgmCommand)
  private
    FFigureFlag : TgmFigureFlags;
    FAddedFigure: TgmFigureObject;

    procedure ChangeFigureNumber(const AChangedAmount: Integer);
  public
    constructor Create(const AFigureObj: TgmFigureObject);
    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmSelectFigureCommand ----------------------------------------------------

  TgmSelectFigureCommand = class(TgmCommand)
  private
    FOldSelectedFigureInfoArray      : array of TgmFigureInfo;
    FNewSelectedFigureInfoArray      : array of TgmFigureInfo;
    FOldSelectedFigureLayerIndexArray: array of Integer;
    FNewSelectedFigureLayerIndexArray: array of Integer;
    FSelectMode                      : TgmSelectFigureMode;
  public
    constructor Create(
      const AOldSelectedFigureInfoArray: array of TgmFigureInfo;
      const ANewSelectedFigureInfoArray: array of TgmFigureInfo;
      const AOldSelectedFigureLayerIndexArray: array of Integer;
      const ANewSelectedFigureLayerIndexArray: array of Integer;
      const AMode: TgmSelectFigureMode);

    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmDeletedFigureInfo ------------------------------------------------------

  TgmDeletedFigureInfo = class(TObject)
  private
    FLayerIndex   : Integer;
    FFigureIndex  : Integer;
    FDeletedFigure: TgmFigureObject;
  public
    constructor Create(const AFigureLayerIndex, AFigureIndex: Integer;
      const AFigureObj: TgmFigureObject);

    destructor Destroy; override;

    property LayerIndex   : Integer         read FLayerIndex;
    property FigureIndex  : Integer         read FFigureIndex;
    property DeletedFigure: TgmFigureObject read FDeletedFigure;
  end;

//-- TgmDeleteFigureCommand ----------------------------------------------------

  TgmDeleteFigureCommand = class(TgmCommand)
  private
    FDeletedFigureList               : TList;
    FOldSelectedFigureInfoArray      : array of TgmFigureInfo;
    FOldSelectedFigureLayerIndexArray: array of Integer;

    procedure RecordDeletedFigureInfoToList;
    procedure RestoreDeletedFigures;
  public
    constructor Create(const AOldSelectedFigureInfoArray: array of TgmFigureInfo;
      const AOldSelectedFigureLayerIndexArray: array of Integer);

    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmLockFigureCommand ------------------------------------------------------

  TgmLockFigureCommand = class(TgmCommand)
  private
    FLockMode: TgmLockFigureMode;
  public
    constructor Create(const ALockMode: TgmLockFigureMode);

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmModifyFigureStyleCommand -----------------------------------------------

  TgmModifyFigureStyleCommand = class(TgmCommand)
  private
    FOldData, FNewData: TgmFigureBasicData;
  public
    constructor Create(const AOldData, ANewData: TgmFigureBasicData);

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmStretchFigureCommand ---------------------------------------------------

  TgmStretchFigureCommand = class(TgmCommand)
  private
    FOldFigure, FNewFigure: TgmFigureObject;
    FFigureFlag           : TgmFigureFlags;

    function GetCommandName: string;
  public
    constructor Create(const AOldFigure, ANewFigure: TgmFigureObject);
    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmTranslateFigureCommand -------------------------------------------------

  TgmTranslateFigureCommand = class(TgmCommand)
  private
    FAccumTranslateVector: TPoint;
  public
    constructor Create(const AAccumTranslateVector: TPoint);

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmTypeToolLayerCommand ---------------------------------------------------

  TgmTypeToolLayerCommand = class(TgmCommand)
  private
    FLayerCommandType: TgmLayerCommandType;
    FOldTextStream   : TMemoryStream;
    FTextBorderStart : TPoint;
    FTextBorderEnd   : TPoint;
    FLayerName       : string;
    FTextFileName    : string;
    FEditState       : Boolean;
    FTextChanged     : Boolean;
    FTextLayerState  : TgmTextLayerState;
    FRedoIndex       : Integer;

    procedure CreateOldRichTextLayer;
  public
    constructor Create(const ALayerIndex: Integer; const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType);

    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmEditTypeCommand --------------------------------------------------------

  TgmEditTypeCommand = class(TgmCommand)
  private
    FOldTextStream: TMemoryStream;
    FNewTextStream: TMemoryStream;
    FRedoIndex    : Integer;
  public
    constructor Create(const ALayerIndex: Integer;
      const AOldTextStream: TMemoryStream; const ALayerPanel: TgmLayerPanel);

    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmTranslateTextRegionCommand ---------------------------------------------

  TgmTranslateTextRegionCommand = class(TgmCommand)
  private
    FAccumTranslateVector: TPoint;
    FRedoIndex           : Integer;
  public
    constructor Create(const ALayerIndex: Integer;
      const AAccumTranslateVector: TPoint);

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmScaleTextRegionCommand -------------------------------------------------

  TgmScaleTextRegionCommand = class(TgmCommand)
  private
    FOldTopLeft, FOldBottomRight: TPoint;
    FNewTopLeft, FNewBottomRight: TPoint;
    FRedoIndex                  : Integer;
  public
    constructor Create(const ALayerIndex: Integer;
      const AOldTopLeft, AOldBottomRight, ANewTopLeft, ANewBottomRight: TPoint);

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmMergeLayersCommand -----------------------------------------------------

  TgmMergeLayersCommand = class(TgmCommand)
  private
    FGMDFileName: string;
    FMergeMode  : TgmMergeLayerMode;

    procedure MergeAllLayers;
    procedure MergeLayerDown;
    procedure MergeVisibleLayers;
  public
    constructor Create(const AMergeMode: TgmMergeLayerMode);
    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmChangeImageSizeCommand -------------------------------------------------

  TgmChangeImageSizeCommand = class(TgmCommand)
  private
    FGMDFileName      : string;
    FNewWidth         : Integer;
    FNewHeight        : Integer;
    FResamplingOptions: TgmResamplingOptions;
  public
    constructor Create(const ANewWidth, ANewHeight: Integer;
      const AResamplingOptions: TgmResamplingOptions);

    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmChangeCanvasSizeCommand ------------------------------------------------

  TgmChangeCanvasSizeCommand = class(TgmCommand)
  private
    FGMDFileName    : string;
    FNewWidth       : Integer;
    FNewHeight      : Integer;
    FAnchorDirection: TgmAnchorDirection;
    FBackgroundColor: TColor32;
  public
    constructor Create(const ANewWidth, ANewHeight: Integer;
      const AAnchorDirection: TgmAnchorDirection;
      const ABackgroundColor: TColor32);

    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmRotateCanvasCommand ----------------------------------------------------

  TgmRotateCanvasCommand = class(TgmCommand)
  private
    FGMDFileName    : string;
    FRotateDegrees  : Integer;
    FRotateDirection: TgmRotateDirection;
  public
    constructor Create(const ADeg: Integer;
      const ARotateDirection: TgmRotateDirection);
      
    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmCropComannd ------------------------------------------------------------

  TgmCropCommand = class(TgmCommand)
  private
    FGMDFileName: string;
    FCropStart  : TPoint;
    FCropEnd    : TPoint;
    FResizeW    : Integer;
    FResizeH    : Integer;
    FResized    : Boolean;
  public
    constructor Create(const ACrop: TgmCrop);
    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmOptimalCropComannd -----------------------------------------------------

  TgmOptimalCropCommand = class(TgmCommand)
  private
    FGMDFileName: string;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

implementation

uses
{ Standard Lib }
  Dialogs,
{ Graphics32 }
  GR32_Layers,
{ GraphicsMagic Lib }
  gmConstants,
  gmAlphaFuncs,
  gmIO,
  gmGMDFile,
  gmImageProcessFuncs,
  gmGUIFuncs,
{ GraphicsMagic Forms/Dialogs }
  MainForm,
  ColorForm,
  LayerForm,
  ChannelForm,
  RichTextEditorForm,
  PatternsPopFrm,
  GradientPickerPopFrm;

//-- TgmBlendingChangeLayerCommand ---------------------------------------------

constructor TgmBlendingChangeLayerCommand.Create(
  const ALayerIndex, AOldBlendModeIndex, ANewBlendModeIndex: Integer);
begin
  inherited Create(caNone, 'Blending Change');

  FOperateName       := 'Undo ' + FCommandName;
  FTargetLayerIndex  := ALayerIndex;
  FOldBlendModeIndex := AOldBlendModeIndex;
  FNewBlendModeIndex := ANewBlendModeIndex;
end;

procedure TgmBlendingChangeLayerCommand.Rollback;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  if FTargetLayerIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
  end;

  frmLayer.IsRecordCommand := False;
  try
    frmLayer.cmbbxLayerBlendMode.ItemIndex := FOldBlendModeIndex;
  finally
    frmLayer.IsRecordCommand := True;
  end;

  ActiveChildForm.LayerPanelList.SelectedLayerPanel.BlendModeIndex := FOldBlendModeIndex;
  ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
  ProcessAfterCommandDone;

  // update channel thumbnails
  ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
end;

procedure TgmBlendingChangeLayerCommand.Execute;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  if FTargetLayerIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
  end;

  frmLayer.IsRecordCommand := False;
  try
    frmLayer.cmbbxLayerBlendMode.ItemIndex := FNewBlendModeIndex;
  finally
    frmLayer.IsRecordCommand := True;
  end;

  ActiveChildForm.LayerPanelList.SelectedLayerPanel.BlendModeIndex := FNewBlendModeIndex;
  ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
  ProcessAfterCommandDone;

  // update channel thumbnails
  ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
end;

//-- TgmOpacityChangeLayerCommand ----------------------------------------------

constructor TgmOpacityChangeLayerCommand.Create(const ALayerIndex: Integer;
  const AOldOpacity, ANewOpacity: Byte);
begin
  inherited Create(caNone, 'Opacity Change');

  FOperateName       := 'Undo ' + FCommandName;
  FTargetLayerIndex  := ALayerIndex;
  FOldOpacity        := AOldOpacity;
  FNewOpacity        := ANewOpacity;
end;

procedure TgmOpacityChangeLayerCommand.Rollback;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  if FTargetLayerIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
  end;

  frmLayer.ggbrLayerOpacity.Position := FOldOpacity;
  ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerMasterAlpha := FOldOpacity;
  ProcessAfterCommandDone;

  // update channel thumbnails
  ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
end; 

procedure TgmOpacityChangeLayerCommand.Execute;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  if FTargetLayerIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
  end;

  frmLayer.ggbrLayerOpacity.Position := FNewOpacity;
  ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerMasterAlpha := FNewOpacity;
  ProcessAfterCommandDone;

  // update channel thumbnails
  ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
end;

//-- TgmSolidColorLayerCommand -------------------------------------------------

constructor TgmSolidColorLayerCommand.Create(const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType;
  const AModifiedColor: TColor = clBlack);
var
  LSolidColorLayerPanel: TgmSolidColorLayerPanel;
begin
  inherited Create(caNone, '');

  LSolidColorLayerPanel := TgmSolidColorLayerPanel(ALayerPanel);

  FTargetLayerIndex := ALayerIndex;
  FFillColor        := LSolidColorLayerPanel.SolidColor;
  FModifiedColor    := AModifiedColor;
  FLayerCommandType := ALayerCommandType;
  FLayerName        := LSolidColorLayerPanel.LayerName.Caption;

  case FLayerCommandType of
    lctNew:
      begin
        FCommandName := 'New ' + FLayerName + ' Layer';
      end;
      
    lctDelete:
      begin
        FCommandName := 'Delete Layer';
      end;
      
    lctModification:
      begin
        FCommandName := 'Modify Color Fill Layer';
      end;
  end;

  FOperateName := 'Undo ' + FCommandName;

  if ALayerCommandType = lctDelete then
  begin
    FLayerLockTransparency := ALayerPanel.IsLockTransparency;
    FLayerBlendModeIndex   := ALayerPanel.BlendModeIndex;
    FLayerOpacity          := ALayerPanel.LayerMasterAlpha;
  end;
end;

procedure TgmSolidColorLayerCommand.CreateSolidColorLayer;
var
  LNewLayer, LBackLayer: TBitmapLayer;
  LLayerPanel          : TgmLayerPanel;
  LSolidColorLayerPanel: TgmSolidColorLayerPanel;
begin
  if frmRichTextEditor.Visible then
  begin
    ActiveChildForm.CommitEdits;
  end;

  LBackLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[0]);

  // insert a new layer to FLayers
  ActiveChildForm.imgDrawingArea.Layers.Insert(FTargetLayerIndex, TBitmapLayer);
  LNewLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[FTargetLayerIndex]);
  LNewLayer.Bitmap.SetSize(LBackLayer.Bitmap.Width, LBackLayer.Bitmap.Height);
  LNewLayer.Location := LBackLayer.Location;
  LNewLayer.Scaled   := True;

  // Create a Layer Panel
  LLayerPanel := TgmSolidColorLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer);
  LLayerPanel.BlendModeIndex     := FLayerBlendModeIndex;
  LLayerPanel.LayerMasterAlpha   := FLayerOpacity;
  LLayerPanel.IsLockTransparency := FLayerLockTransparency;

  // Add new layer panel to list
  ActiveChildForm.LayerPanelList.InsertLayerPanelToList(FTargetLayerIndex, LLayerPanel);

  // creating and showing the mask after the layer panel is inserted to the layer panel list
  if FLayerCommandType = lctNew then
  begin
    frmLayer.AddMaskClick(nil);
  end;

  LSolidColorLayerPanel            := TgmSolidColorLayerPanel(LLayerPanel);
  LSolidColorLayerPanel.SolidColor := FFillColor;

  LNewLayer.Bitmap.Changed;
  ActiveChildForm.IsImageProcessed := True;  // mark the image is processed
  ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
end;

procedure TgmSolidColorLayerCommand.Rollback;
var
  LSolidColorLayerPanel: TgmSolidColorLayerPanel;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
      end;

    lctDelete:
      begin
        CreateSolidColorLayer;
        
        ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerName.Caption := FLayerName;
        
        frmLayer.cmbbxLayerBlendMode.ItemIndex  := FLayerBlendModeIndex;
        frmLayer.ggbrLayerOpacity.Position      := FLayerOpacity;
        frmLayer.chckbxLockTransparency.Checked := FLayerLockTransparency;
      end;

    lctModification:
      begin
        if ActiveChildForm.LayerPanelList.CurrentIndex <> FTargetLayerIndex then
        begin
          ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
        end;

        LSolidColorLayerPanel := TgmSolidColorLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);
        LSolidColorLayerPanel.SolidColor := FFillColor;
        
        ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
      end;
  end;

  if FLayerCommandType in [lctNew, lctDelete] then
  begin
    ActiveChildForm.LayerPanelList.SolidColorLayerNumber := ActiveChildForm.LayerPanelList.SolidColorLayerNumber - 1;
    ProcessAfterCreateDeleteLayerCommandDone;
  end;
end;

procedure TgmSolidColorLayerCommand.Execute;
var
  LSolidColorLayerPanel: TgmSolidColorLayerPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        CreateSolidColorLayer;
      end;
      
    lctDelete:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
      end;

    lctModification:
      begin
        if ActiveChildForm.LayerPanelList.CurrentIndex <> FTargetLayerIndex then
        begin
          ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
        end;
        
        LSolidColorLayerPanel := TgmSolidColorLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);
        LSolidColorLayerPanel.SolidColor := FModifiedColor;

        ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
      end;
  end;

  if FLayerCommandType in [lctNew, lctDelete] then
  begin
    ProcessAfterCreateDeleteLayerCommandDone;
  end;
end; 

//-- TgmGradientFillLayerCommand -----------------------------------------------

constructor TgmGradientFillLayerCommand.Create(const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType);
var
  LGradientFillLayerPanel: TgmGradientFillLayerPanel;
begin
  inherited Create(caNone, '');

  LGradientFillLayerPanel := TgmGradientFillLayerPanel(ALayerPanel);

  FTargetLayerIndex := ALayerIndex;
  FLayerCommandType := ALayerCommandType;
  FLayerName        := LGradientFillLayerPanel.LayerName.Caption;

  case FLayerCommandType of
    lctNew:
      begin
        FCommandName := 'New ' + FLayerName + ' Layer';
      end;
      
    lctDelete:
      begin
        FCommandName := 'Delete Layer';
      end;
      
    lctModification:
      begin
        FCommandName := 'Modify Gradient Fill Layer';
      end;
  end;

  FOperateName := 'Undo ' + FCommandName;

  FGradient := TgmGradientItem.Create(nil);
  FGradient.Assign(LGradientFillLayerPanel.Gradient);

  with FGradientFillSettings do
  begin
    Style         := LGradientFillLayerPanel.Style;
    Angle         := LGradientFillLayerPanel.Angle;
    Scale         := LGradientFillLayerPanel.Scale;
    TranslateX    := LGradientFillLayerPanel.TranslateX;
    TranslateY    := LGradientFillLayerPanel.TranslateY;
    Reversed      := LGradientFillLayerPanel.IsReversed;
    StartPoint    := LGradientFillLayerPanel.StartPoint;
    EndPoint      := LGradientFillLayerPanel.EndPoint;
    CenterPoint   := LGradientFillLayerPanel.CenterPoint;
    OriginalCenter:= LGradientFillLayerPanel.OriginalCenter;
    OriginalStart := LGradientFillLayerPanel.OriginalStart;
    OriginalEnd   := LGradientFillLayerPanel.OriginalEnd;
  end;

  if FLayerCommandType = lctModification then
  begin
    FOldGradient := TgmGradientItem.Create(nil);
    FOldGradient.Assign(LGradientFillLayerPanel.LastGradient);

    with FOldFillSettings do
    begin
      Style         := LGradientFillLayerPanel.LastStyle;
      Angle         := LGradientFillLayerPanel.LastAngle;
      Scale         := LGradientFillLayerPanel.LastScale;
      TranslateX    := LGradientFillLayerPanel.LastTranslateX;
      TranslateY    := LGradientFillLayerPanel.LastTranslateY;
      Reversed      := LGradientFillLayerPanel.IsLastReversed;
      StartPoint    := LGradientFillLayerPanel.LastStartPoint;
      EndPoint      := LGradientFillLayerPanel.LastEndPoint;
      CenterPoint   := LGradientFillLayerPanel.LastCenterPoint;
      OriginalCenter:= LGradientFillLayerPanel.LastCenterPoint;
      OriginalStart := LGradientFillLayerPanel.LastOriginalStart;
      OriginalEnd   := LGradientFillLayerPanel.LastOriginalEnd;
    end;
  end;

  if ALayerCommandType = lctDelete then
  begin
    FLayerLockTransparency := ALayerPanel.IsLockTransparency;
    FLayerBlendModeIndex   := ALayerPanel.BlendModeIndex;
    FLayerOpacity          := ALayerPanel.LayerMasterAlpha;
  end;
end;

destructor TgmGradientFillLayerCommand.Destroy;
begin
  FGradient.Free;
  FOldGradient.Free;
  
  inherited Destroy;
end;

procedure TgmGradientFillLayerCommand.CreateGradientFillLayer;
var
  LNewLayer, LBackLayer  : TBitmapLayer;
  LLayerPanel            : TgmLayerPanel;
  LGradientFillLayerPanel: TgmGradientFillLayerPanel;
begin
  if frmRichTextEditor.Visible then
  begin
    ActiveChildForm.CommitEdits;
  end;

  LBackLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[0]);

  // insert a new layer to FLayers
  ActiveChildForm.imgDrawingArea.Layers.Insert(FTargetLayerIndex, TBitmapLayer);

  LNewLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[FTargetLayerIndex]);
  LNewLayer.Bitmap.SetSize(LBackLayer.Bitmap.Width, LBackLayer.Bitmap.Height);

  LNewLayer.Location := LBackLayer.Location;
  LNewLayer.Scaled   := True;

  // Create a Layer Panel
  LLayerPanel := TgmGradientFillLayerPanel.Create(
    frmLayer.scrlbxLayers, LNewLayer, frmGradientPicker.GetFillLayerGradient);

  LLayerPanel.BlendModeIndex     := FLayerBlendModeIndex;
  LLayerPanel.LayerMasterAlpha   := FLayerOpacity;
  LLayerPanel.IsLockTransparency := FLayerLockTransparency;

  // add new layer panel to list
  ActiveChildForm.LayerPanelList.InsertLayerPanelToList(FTargetLayerIndex, LLayerPanel);

  // creating and showing the mask after the layer panel is inserted to the layer panel list
  if FLayerCommandType = lctNew then
  begin
    frmLayer.AddMaskClick(nil);
  end;

  LGradientFillLayerPanel := TgmGradientFillLayerPanel(LLayerPanel);

  with LGradientFillLayerPanel do
  begin
    Gradient.Assign(FGradient);
    
    Style          := FGradientFillSettings.Style;
    Angle          := FGradientFillSettings.Angle;
    Scale          := FGradientFillSettings.Scale;
    TranslateX     := FGradientFillSettings.TranslateX;
    TranslateY     := FGradientFillSettings.TranslateY;
    IsReversed     := FGradientFillSettings.Reversed;
    StartPoint     := FGradientFillSettings.StartPoint;
    EndPoint       := FGradientFillSettings.EndPoint;
    CenterPoint    := FGradientFillSettings.CenterPoint;
    OriginalCenter := FGradientFillSettings.OriginalCenter;
    OriginalStart  := FGradientFillSettings.OriginalStart;
    OriginalEnd    := FGradientFillSettings.OriginalEnd;

    SaveLastAdjustment;
    DrawGradientOnLayer;
  end;

  LNewLayer.Bitmap.Changed;
  ActiveChildForm.IsImageProcessed := True;
  ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
end;

procedure TgmGradientFillLayerCommand.Rollback;
var
  LGradientFillLayerPanel: TgmGradientFillLayerPanel;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
      end;

    lctDelete:
      begin
        CreateGradientFillLayer;

        ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerName.Caption := FLayerName;
        
        frmLayer.cmbbxLayerBlendMode.ItemIndex  := FLayerBlendModeIndex;
        frmLayer.ggbrLayerOpacity.Position      := FLayerOpacity;
        frmLayer.chckbxLockTransparency.Checked := FLayerLockTransparency;
      end;

    lctModification:
      begin
        if ActiveChildForm.LayerPanelList.CurrentIndex <> FTargetLayerIndex then
        begin
          ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
        end;

        if Assigned(FOldGradient) then
        begin
          LGradientFillLayerPanel := TgmGradientFillLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

          with LGradientFillLayerPanel do
          begin
            Gradient.Assign(FOldGradient);

            Style         := FOldFillSettings.Style;
            Angle         := FOldFillSettings.Angle;
            Scale         := FOldFillSettings.Scale;
            TranslateX    := FOldFillSettings.TranslateX;
            TranslateY    := FOldFillSettings.TranslateY;
            IsReversed    := FOldFillSettings.Reversed;
            StartPoint    := FOldFillSettings.StartPoint;
            EndPoint      := FOldFillSettings.EndPoint;
            CenterPoint   := FOldFillSettings.CenterPoint;
            OriginalStart := FOldFillSettings.OriginalStart;
            OriginalEnd   := FOldFillSettings.OriginalEnd;

            DrawGradientOnLayer;
            DrawGradientFillLayerThumbnail;
            SaveLastAdjustment;
          end;
        end;
      end;
  end;

  if FLayerCommandType in [lctNew, lctDelete] then
  begin
    ActiveChildForm.LayerPanelList.GradientFillLayerNumber := ActiveChildForm.LayerPanelList.GradientFillLayerNumber - 1;
    ProcessAfterCreateDeleteLayerCommandDone;
  end;
end;

procedure TgmGradientFillLayerCommand.Execute;
var
  LGradientFillLayerPanel: TgmGradientFillLayerPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        CreateGradientFillLayer;
      end;
      
    lctDelete:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
      end;

    lctModification:
      begin
        if ActiveChildForm.LayerPanelList.CurrentIndex <> FTargetLayerIndex then
        begin
          ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
        end;

        if Assigned(FGradient) then
        begin
          LGradientFillLayerPanel := TgmGradientFillLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

          with LGradientFillLayerPanel do
          begin
            Gradient.Assign(FGradient);
            
            Style         := FGradientFillSettings.Style;
            Angle         := FGradientFillSettings.Angle;
            Scale         := FGradientFillSettings.Scale;
            TranslateX    := FGradientFillSettings.TranslateX;
            TranslateY    := FGradientFillSettings.TranslateY;
            IsReversed    := FGradientFillSettings.Reversed;
            StartPoint    := FGradientFillSettings.StartPoint;
            EndPoint      := FGradientFillSettings.EndPoint;
            CenterPoint   := FGradientFillSettings.CenterPoint;
            OriginalStart := FGradientFillSettings.OriginalStart;
            OriginalEnd   := FGradientFillSettings.OriginalEnd;

            DrawGradientOnLayer;
            DrawGradientFillLayerThumbnail;
            SaveLastAdjustment;
          end;
        end;
      end;
  end;

  if FLayerCommandType in [lctNew, lctDelete] then
  begin
    ProcessAfterCreateDeleteLayerCommandDone;
  end;
end;

//-- TgmPatternLayerCommand ----------------------------------------------------

constructor TgmPatternLayerCommand.Create(const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType);
var
  LPatternLayerPanel: TgmPatternLayerPanel;
begin
  inherited Create(caNone, '');

  LPatternLayerPanel := TgmPatternLayerPanel(ALayerPanel);

  FTargetLayerIndex := ALayerIndex;
  FLayerCommandType := ALayerCommandType;
  FLayerName        := LPatternLayerPanel.LayerName.Caption;

  case FLayerCommandType of
    lctNew:
      begin
        FCommandName := 'New ' + FLayerName + ' Layer';
      end;
      
    lctDelete:
      begin
        FCommandName := 'Delete Layer';
      end;
      
    lctModification:
      begin
        FCommandName := 'Modify Pattern Fill Layer';
      end;
  end;

  FOperateName := 'Undo ' + FCommandName;

  FPatternBitmap := TBitmap32.Create;
  FPatternBitmap.Assign(LPatternLayerPanel.PatternBitmap);

  FScale := LPatternLayerPanel.Scale;

  if FLayerCommandType = lctModification then
  begin
    FOldScale := LPatternLayerPanel.LastScale;

    FOldPatternBitmap := TBitmap32.Create;
    FOldPatternBitmap.Assign(LPatternLayerPanel.LastPatternBitmap);
  end
  else
  begin
    FOldPatternBitmap := nil;
  end;

  if ALayerCommandType = lctDelete then
  begin
    FLayerLockTransparency := ALayerPanel.IsLockTransparency;
    FLayerBlendModeIndex   := ALayerPanel.BlendModeIndex;
    FLayerOpacity          := ALayerPanel.LayerMasterAlpha;
  end;
end;

destructor TgmPatternLayerCommand.Destroy;
begin
  FPatternBitmap.Free;
  FOldPatternBitmap.Free;

  inherited Destroy;
end; 

procedure TgmPatternLayerCommand.CreatePatternLayer;
var
  LNewLayer, LBackLayer: TBitmapLayer;
  LLayerPanel          : TgmLayerPanel;
  LPatternLayerPanel   : TgmPatternLayerPanel;
begin
  if frmRichTextEditor.Visible then
  begin
    ActiveChildForm.CommitEdits;
  end;

  LBackLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[0]);

  // insert a new layer to FLayers
  ActiveChildForm.imgDrawingArea.Layers.Insert(FTargetLayerIndex, TBitmapLayer);

  LNewLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[FTargetLayerIndex]);
  LNewLayer.Bitmap.SetSize(LBackLayer.Bitmap.Width, LBackLayer.Bitmap.Height);

  LNewLayer.Location := LBackLayer.Location;
  LNewLayer.Scaled   := True;

  // create a Layer Panel
  LLayerPanel := TgmPatternLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer,
                                             frmPatterns.LayerPattern);

  LLayerPanel.BlendModeIndex     := FLayerBlendModeIndex;
  LLayerPanel.LayerMasterAlpha   := FLayerOpacity;
  LLayerPanel.IsLockTransparency := FLayerLockTransparency;

  // Add new layer panel to list
  ActiveChildForm.LayerPanelList.InsertLayerPanelToList(FTargetLayerIndex, LLayerPanel);

  // creating and showing the mask after the layer panel is inserted to the layer panel list
  if FLayerCommandType = lctNew then
  begin
    frmLayer.AddMaskClick(nil);
  end;

  LPatternLayerPanel := TgmPatternLayerPanel(LLayerPanel);

  with LPatternLayerPanel do
  begin
    PatternBitmap := FPatternBitmap;
    Scale         := FScale;
    
    SaveLastAdjustment;
    FillPatternOnLayer;
  end;

  LNewLayer.Bitmap.Changed;
  ActiveChildForm.IsImageProcessed := True;

  ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(
    ActiveChildForm.LayerPanelList);
end; 

procedure TgmPatternLayerCommand.Rollback;
var
  LPatternLayerPanel: TgmPatternLayerPanel;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
      end;
      
    lctDelete:
      begin
        CreatePatternLayer;
        
        ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerName.Caption := FLayerName;

        frmLayer.cmbbxLayerBlendMode.ItemIndex  := FLayerBlendModeIndex;
        frmLayer.ggbrLayerOpacity.Position      := FLayerOpacity;
        frmLayer.chckbxLockTransparency.Checked := FLayerLockTransparency;
      end;

    lctModification:
      begin
        if ActiveChildForm.LayerPanelList.CurrentIndex <> FTargetLayerIndex then
        begin
          ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
        end;
        
        if Assigned(FOldPatternBitmap) then
        begin
          LPatternLayerPanel := TgmPatternLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

          with LPatternLayerPanel do
          begin
            PatternBitmap := FOldPatternBitmap;  // must set pattern before scale setting
            Scale         := FOldScale;

            DrawPatternLayerThumbnail;
            SaveLastAdjustment;
          end;
        end;
      end;
  end;

  if FLayerCommandType in [lctNew, lctDelete] then
  begin
    ActiveChildForm.LayerPanelList.PatternLayerNumber := ActiveChildForm.LayerPanelList.PatternLayerNumber - 1;
    ProcessAfterCreateDeleteLayerCommandDone;
  end;
end; 

procedure TgmPatternLayerCommand.Execute;
var
  LPatternLayerPanel: TgmPatternLayerPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        CreatePatternLayer;
      end;

    lctDelete:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
      end;
      
    lctModification:
      begin
        if ActiveChildForm.LayerPanelList.CurrentIndex <> FTargetLayerIndex then
        begin
          ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
        end;
        
        if Assigned(FPatternBitmap) then
        begin
          LPatternLayerPanel := TgmPatternLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

          with LPatternLayerPanel do
          begin
            PatternBitmap := FPatternBitmap; // must set pattern before scale setting
            Scale         := FScale;

            DrawPatternLayerThumbnail;
            SaveLastAdjustment;
          end;
        end;
      end;
  end;

  if FLayerCommandType in [lctNew, lctDelete] then
  begin
    ProcessAfterCreateDeleteLayerCommandDone;
  end;
end;

//-- TgmLevelsLayerCommand -----------------------------------------------------

constructor TgmLevelsLayerCommand.Create(const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType);
var
  i, j             : Integer;
  LLevelsLayerPanel: TgmLevelsLayerPanel;
begin
  inherited Create(caNone, '');

  LLevelsLayerPanel := TgmLevelsLayerPanel(ALayerPanel);

  FTargetLayerIndex := ALayerIndex;
  FLayerCommandType := ALayerCommandType;
  FLayerName        := LLevelsLayerPanel.LayerName.Caption;

  case FLayerCommandType of
    lctNew         : FCommandName := 'New ' + FLayerName + ' Layer';
    lctDelete      : FCommandName := 'Delete Layer';
    lctModification: FCommandName := 'Modify Levels Layer';
  end;

  FOperateName := 'Undo ' + FCommandName;

  FLevelsTool := TgmLevelsTool.Create(LLevelsLayerPanel.LevelsTool.SourceBitmap);
  FLevelsTool.LUTSetup(3);

  for j := Low(FLevelsTool.LUT.luts) to High(FLevelsTool.LUT.luts) do
    for i := Low(FLevelsTool.LUT.luts[j]) to High(FLevelsTool.LUT.luts[j]) do
      FLevelsTool.LUT.luts[j, i] := LLevelsLayerPanel.LevelsTool.LUT.luts[j, i];

  for i := 0 to 4 do
  begin
    FLevelsTool.SliderPos[i]         := LLevelsLayerPanel.LevelsTool.SliderPos[i];
    FLevelsTool.Levels.Gamma[i]      := LLevelsLayerPanel.LevelsTool.Levels.Gamma[i];
    FLevelsTool.Levels.LowInput[i]   := LLevelsLayerPanel.LevelsTool.Levels.LowInput[i];
    FLevelsTool.Levels.HighInput[i]  := LLevelsLayerPanel.LevelsTool.Levels.HighInput[i];
    FLevelsTool.Levels.LowOutput[i]  := LLevelsLayerPanel.LevelsTool.Levels.LowOutput[i];
    FLevelsTool.Levels.HighOutput[i] := LLevelsLayerPanel.LevelsTool.Levels.HighOutput[i];

    for j := 0 to 255 do
      FLevelsTool.Levels.FInput[i, j] := LLevelsLayerPanel.LevelsTool.Levels.FInput[i, j];
  end;

  FLevelsTool.Channel := LLevelsLayerPanel.LevelsTool.Channel;

  if FLayerCommandType = lctModification then
  begin
    FOldLevelsTool := TgmLevelsTool.Create(LLevelsLayerPanel.LastLevelsTool.SourceBitmap);
    FOldLevelsTool.LUTSetup(3);

    for j := Low(LLevelsLayerPanel.LevelsTool.LUT.luts) to High(LLevelsLayerPanel.LevelsTool.LUT.luts) do
      for i := Low(LLevelsLayerPanel.LevelsTool.LUT.luts[j]) to High(LLevelsLayerPanel.LevelsTool.LUT.luts[j]) do
        FOldLevelsTool.LUT.luts[j, i] := LLevelsLayerPanel.LastLevelsTool.LUT.luts[j, i];


    for i := 0 to 4 do
    begin
      FOldLevelsTool.SliderPos[i]         := LLevelsLayerPanel.LastLevelsTool.SliderPos[i];
      FOldLevelsTool.Levels.Gamma[i]      := LLevelsLayerPanel.LastLevelsTool.Levels.Gamma[i];
      FOldLevelsTool.Levels.LowInput[i]   := LLevelsLayerPanel.LastLevelsTool.Levels.LowInput[i];
      FOldLevelsTool.Levels.HighInput[i]  := LLevelsLayerPanel.LastLevelsTool.Levels.HighInput[i];
      FOldLevelsTool.Levels.LowOutput[i]  := LLevelsLayerPanel.LastLevelsTool.Levels.LowOutput[i];
      FOldLevelsTool.Levels.HighOutput[i] := LLevelsLayerPanel.LastLevelsTool.Levels.HighOutput[i];

      for j := 0 to 255 do
        FOldLevelsTool.Levels.FInput[i, j] := LLevelsLayerPanel.LastLevelsTool.Levels.FInput[i, j];
    end;

    FOldLevelsTool.Channel := LLevelsLayerPanel.LastLevelsTool.Channel;
  end
  else
  begin
    FOldLevelsTool := nil;
  end;

  if ALayerCommandType = lctDelete then
  begin
    FLayerLockTransparency := ALayerPanel.IsLockTransparency;
    FLayerBlendModeIndex   := ALayerPanel.BlendModeIndex;
    FLayerOpacity          := ALayerPanel.LayerMasterAlpha;
  end;
end;

destructor TgmLevelsLayerCommand.Destroy;
begin
  FLevelsTool.Free;
  FOldLevelsTool.Free;

  inherited Destroy;
end;

procedure TgmLevelsLayerCommand.CreateLevelsLayer;
var
  LNewLayer, LBackLayer: TBitmapLayer;
  LLayerPanel          : TgmLayerPanel;
  LLevelsLayerPanel    : TgmLevelsLayerPanel;
  i, j                 : Integer;
begin
  if frmRichTextEditor.Visible then
  begin
    ActiveChildForm.CommitEdits;
  end;

  LBackLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[0]);

  // insert a new layer to FLayers
  ActiveChildForm.imgDrawingArea.Layers.Insert(FTargetLayerIndex, TBitmapLayer);
  LNewLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[FTargetLayerIndex]);
  LNewLayer.Bitmap.SetSize(LBackLayer.Bitmap.Width, LBackLayer.Bitmap.Height);
  LNewLayer.Location := LBackLayer.Location;
  LNewLayer.Scaled   := True;

  // Create a Layer Panel
  LLayerPanel := TgmLevelsLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer);
  LLayerPanel.BlendModeIndex     := FLayerBlendModeIndex;
  LLayerPanel.LayerMasterAlpha   := FLayerOpacity;
  LLayerPanel.IsLockTransparency := FLayerLockTransparency;

  // Add new layer panel to list
  ActiveChildForm.LayerPanelList.InsertLayerPanelToList(FTargetLayerIndex, LLayerPanel);

  // creating and showing the mask after the layer panel is inserted to the layer panel list
  if FLayerCommandType = lctNew then
  begin
    frmLayer.AddMaskClick(nil);
  end;

  LLevelsLayerPanel := TgmLevelsLayerPanel(LLayerPanel);

  for j := Low(FLevelsTool.LUT.luts) to High(FLevelsTool.LUT.luts) do
  begin
    for i := Low(FLevelsTool.LUT.luts[j]) to High(FLevelsTool.LUT.luts[j]) do
    begin
      LLevelsLayerPanel.LevelsTool.LUT.luts[j, i] := FLevelsTool.LUT.luts[j, i];
    end;
  end;

  for i := 0 to 4 do
  begin
    LLevelsLayerPanel.LevelsTool.SliderPos[i]        := FLevelsTool.SliderPos[i];
    LLevelsLayerPanel.LevelsTool.Levels.Gamma[i]     := FLevelsTool.Levels.Gamma[i];
    LLevelsLayerPanel.LevelsTool.Levels.LowInput[i]  := FLevelsTool.Levels.LowInput[i];
    LLevelsLayerPanel.LevelsTool.Levels.HighInput[i] := FLevelsTool.Levels.HighInput[i];
    LLevelsLayerPanel.LevelsTool.Levels.LowOutput[i] := FLevelsTool.Levels.LowOutput[i];
    LLevelsLayerPanel.LevelsTool.Levels.HighOutput[i]:= FLevelsTool.Levels.HighOutput[i];

    for j := 0 to 255 do
    begin
      LLevelsLayerPanel.LevelsTool.Levels.FInput[i, j] := FLevelsTool.Levels.FInput[i, j];
    end;
  end;

  with LLevelsLayerPanel do
  begin
    LevelsTool.Channel := FLevelsTool.Channel;
    SaveLastAdjustment;
  end;

  LNewLayer.Bitmap.Changed;
  ActiveChildForm.IsImageProcessed := True;
  ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
end;

procedure TgmLevelsLayerCommand.Rollback;
var
  i, j             : Integer;
  LLevelsLayerPanel: TgmLevelsLayerPanel;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
      end;
      
    lctDelete:
      begin
        CreateLevelsLayer;

        ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerName.Caption := FLayerName;

        frmLayer.cmbbxLayerBlendMode.ItemIndex  := FLayerBlendModeIndex;
        frmLayer.ggbrLayerOpacity.Position      := FLayerOpacity;
        frmLayer.chckbxLockTransparency.Checked := FLayerLockTransparency;
      end;

    lctModification:
      begin
        if ActiveChildForm.LayerPanelList.CurrentIndex <> FTargetLayerIndex then
        begin
          ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
        end;
        
        if Assigned(FOldLevelsTool) then
        begin
          LLevelsLayerPanel := TgmLevelsLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

          for j := Low(LLevelsLayerPanel.LevelsTool.LUT.luts) to
                   High(LLevelsLayerPanel.LevelsTool.LUT.luts) do
          begin
            for i := Low(LLevelsLayerPanel.LevelsTool.LUT.luts[j]) to
                     High(LLevelsLayerPanel.LevelsTool.LUT.luts[j]) do
            begin
              LLevelsLayerPanel.LevelsTool.LUT.luts[j, i] := FOldLevelsTool.LUT.luts[j, i];
            end;
          end;

          for i := 0 to 4 do
          begin
            LLevelsLayerPanel.LevelsTool.SliderPos[i]         := FOldLevelsTool.SliderPos[i];
            LLevelsLayerPanel.LevelsTool.Levels.Gamma[i]      := FOldLevelsTool.Levels.Gamma[i];
            LLevelsLayerPanel.LevelsTool.Levels.LowInput[i]   := FOldLevelsTool.Levels.LowInput[i];
            LLevelsLayerPanel.LevelsTool.Levels.HighInput[i]  := FOldLevelsTool.Levels.HighInput[i];
            LLevelsLayerPanel.LevelsTool.Levels.LowOutput[i]  := FOldLevelsTool.Levels.LowOutput[i];
            LLevelsLayerPanel.LevelsTool.Levels.HighOutput[i] := FOldLevelsTool.Levels.HighOutput[i];

            for j := 0 to 255 do
            begin
              LLevelsLayerPanel.LevelsTool.Levels.FInput[i, j] := FOldLevelsTool.Levels.FInput[i, j];
            end;
          end;

          LLevelsLayerPanel.LevelsTool.Channel := FOldLevelsTool.Channel;
          LLevelsLayerPanel.SaveLastAdjustment;

          ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
        end;
      end;
  end;

  if FLayerCommandType in [lctNew, lctDelete] then
  begin
    ActiveChildForm.LayerPanelList.LevelsLayerNumber := ActiveChildForm.LayerPanelList.LevelsLayerNumber - 1;
    ProcessAfterCreateDeleteLayerCommandDone;
  end;
end;

procedure TgmLevelsLayerCommand.Execute;
var
  i, j             : Integer;
  LLevelsLayerPanel: TgmLevelsLayerPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        CreateLevelsLayer;
      end;
      
    lctDelete:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
      end;
      
    lctModification:
      begin
        if ActiveChildForm.LayerPanelList.CurrentIndex <> FTargetLayerIndex then
        begin
          ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
        end;
        
        if Assigned(FLevelsTool) then
        begin
          LLevelsLayerPanel := TgmLevelsLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

          for j := Low(LLevelsLayerPanel.LevelsTool.LUT.luts) to
                   High(LLevelsLayerPanel.LevelsTool.LUT.luts) do
          begin
            for i := Low(LLevelsLayerPanel.LevelsTool.LUT.luts[j]) to
                     High(LLevelsLayerPanel.LevelsTool.LUT.luts[j]) do
            begin
              LLevelsLayerPanel.LevelsTool.LUT.luts[j, i] := FLevelsTool.LUT.luts[j, i];
            end;
          end;
            
          for i := 0 to 4 do
          begin
            LLevelsLayerPanel.LevelsTool.SliderPos[i]         := FLevelsTool.SliderPos[i];
            LLevelsLayerPanel.LevelsTool.Levels.Gamma[i]      := FLevelsTool.Levels.Gamma[i];
            LLevelsLayerPanel.LevelsTool.Levels.LowInput[i]   := FLevelsTool.Levels.LowInput[i];
            LLevelsLayerPanel.LevelsTool.Levels.HighInput[i]  := FLevelsTool.Levels.HighInput[i];
            LLevelsLayerPanel.LevelsTool.Levels.LowOutput[i]  := FLevelsTool.Levels.LowOutput[i];
            LLevelsLayerPanel.LevelsTool.Levels.HighOutput[i] := FLevelsTool.Levels.HighOutput[i];

            for j := 0 to 255 do
            begin
              LLevelsLayerPanel.LevelsTool.Levels.FInput[i, j] := FLevelsTool.Levels.FInput[i, j];
            end;
          end;

          LLevelsLayerPanel.LevelsTool.Channel := FLevelsTool.Channel;
          LLevelsLayerPanel.SaveLastAdjustment;
          
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
        end;
      end;
  end;

  if FLayerCommandType in [lctNew, lctDelete] then
  begin
    ProcessAfterCreateDeleteLayerCommandDone;
  end;
end;

//-- TgmCurvesLayerCommand -----------------------------------------------------

constructor TgmCurvesLayerCommand.Create(const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType);
var
  i, j, k          : Integer;
  LCurvesLayerPanel: TgmCurvesLayerPanel;
begin
  inherited Create(caNone, '');

  LCurvesLayerPanel := TgmCurvesLayerPanel(ALayerPanel);

  FTargetLayerIndex := ALayerIndex;
  FLayerCommandType := ALayerCommandType;
  FLayerName        := LCurvesLayerPanel.LayerName.Caption;

  case FLayerCommandType of
    lctNew         : FCommandName := 'New ' + FLayerName + ' Layer';
    lctDelete      : FCommandName := 'Delete Layer';
    lctModification: FCommandName := 'Modify Curves Layer';
  end;

  FOperateName := 'Undo ' + FCommandName;

  FCurvesTool := TgmCurvesTool.Create(LCurvesLayerPanel.CurvesTool.SourceBitmap);
  FCurvesTool.LUTSetup(3);

  for j := Low(FCurvesTool.LUT.luts) to High(FCurvesTool.LUT.luts) do
    for i := Low(FCurvesTool.LUT.luts[j]) to High(FCurvesTool.LUT.luts[j]) do
      FCurvesTool.LUT.luts[j, i] := LCurvesLayerPanel.CurvesTool.LUT.luts[j, i];

  for i := 0 to 4 do
    FCurvesTool.Curves.CurveType[i] := LCurvesLayerPanel.CurvesTool.Curves.CurveType[i];

  for i := 0 to 4 do
    for j := 0 to 16 do
      for k := 0 to 1 do
        FCurvesTool.Curves.Points[i, j, k] := LCurvesLayerPanel.CurvesTool.Curves.Points[i, j, k];

  for i := 0 to 4 do
    for j := 0 to 255 do
      FCurvesTool.Curves.FCurve[i, j] := LCurvesLayerPanel.CurvesTool.Curves.FCurve[i, j];

  FCurvesTool.Channel   := LCurvesLayerPanel.CurvesTool.Channel;
  FCurvesTool.Scale     := LCurvesLayerPanel.CurvesTool.Scale;
  FCurvesTool.CurveType := LCurvesLayerPanel.CurvesTool.CurveType;

  if FLayerCommandType = lctModification then
  begin
    // Copy old records.
    FOldCurvesTool := TgmCurvesTool.Create(LCurvesLayerPanel.LastCurvesTool.SourceBitmap);
    FOldCurvesTool.LUTSetup(3);

    for j := Low(LCurvesLayerPanel.CurvesTool.LUT.luts) to High(LCurvesLayerPanel.CurvesTool.LUT.luts) do
      for i := Low(LCurvesLayerPanel.CurvesTool.LUT.luts[j]) to High(LCurvesLayerPanel.CurvesTool.LUT.luts[j]) do
        FOldCurvesTool.LUT.luts[j, i] := LCurvesLayerPanel.LastCurvesTool.LUT.luts[j, i];

    for i := 0 to 4 do
      FOldCurvesTool.Curves.CurveType[i] := LCurvesLayerPanel.LastCurvesTool.Curves.CurveType[i];

    for i := 0 to 4 do
      for j := 0 to 16 do
        for k := 0 to 1 do
          FOldCurvesTool.Curves.Points[i, j, k] := LCurvesLayerPanel.LastCurvesTool.Curves.Points[i, j, k];

    for i := 0 to 4 do
      for j := 0 to 255 do
        FOldCurvesTool.Curves.FCurve[i, j] := LCurvesLayerPanel.LastCurvesTool.Curves.FCurve[i, j];

    FOldCurvesTool.Channel   := LCurvesLayerPanel.LastCurvesTool.Channel;
    FOldCurvesTool.Scale     := LCurvesLayerPanel.LastCurvesTool.Scale;
    FOldCurvesTool.CurveType := LCurvesLayerPanel.LastCurvesTool.CurveType;
  end
  else
  begin
    FOldCurvesTool := nil;
  end;

  if ALayerCommandType = lctDelete then
  begin
    FLayerLockTransparency := ALayerPanel.IsLockTransparency;
    FLayerBlendModeIndex   := ALayerPanel.BlendModeIndex;
    FLayerOpacity          := ALayerPanel.LayerMasterAlpha;
  end;
end;

destructor TgmCurvesLayerCommand.Destroy;
begin
  FCurvesTool.Free;
  FOldCurvesTool.Free;
  
  inherited Destroy;
end;

procedure TgmCurvesLayerCommand.CreateCurvesLayer;
var
  LNewLayer, LBackLayer: TBitmapLayer;
  LLayerPanel          : TgmLayerPanel;
  LCurvesLayerPanel    : TgmCurvesLayerPanel;
  i, j, k              : Integer;
begin
  if frmRichTextEditor.Visible then
  begin
    ActiveChildForm.CommitEdits;
  end;

  LBackLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[0]);
  
  // insert a new layer to FLayers
  ActiveChildForm.imgDrawingArea.Layers.Insert(FTargetLayerIndex, TBitmapLayer);
  LNewLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[FTargetLayerIndex]);
  LNewLayer.Bitmap.SetSize(LBackLayer.Bitmap.Width, LBackLayer.Bitmap.Height);
  LNewLayer.Location := LBackLayer.Location;
  LNewLayer.Scaled   := True;

  // Create a Layer Panel
  LLayerPanel                    := TgmCurvesLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer);
  LLayerPanel.BlendModeIndex     := FLayerBlendModeIndex;
  LLayerPanel.LayerMasterAlpha   := FLayerOpacity;
  LLayerPanel.IsLockTransparency := FLayerLockTransparency;

  // Add new layer panel to list
  ActiveChildForm.LayerPanelList.InsertLayerPanelToList(FTargetLayerIndex, LLayerPanel);

  // creating and showing the mask after the layer panel is inserted to the layer panel list
  if FLayerCommandType = lctNew then
  begin
    frmLayer.AddMaskClick(nil);
  end;

  LCurvesLayerPanel := TgmCurvesLayerPanel(LLayerPanel);

  for j := Low(FCurvesTool.LUT.luts) to High(FCurvesTool.LUT.luts) do
  begin
    for i := Low(FCurvesTool.LUT.luts[j]) to High(FCurvesTool.LUT.luts[j]) do
    begin
      LCurvesLayerPanel.CurvesTool.LUT.luts[j, i] := FCurvesTool.LUT.luts[j, i];
    end;
  end;

  for i := 0 to 4 do
  begin
    LCurvesLayerPanel.CurvesTool.Curves.CurveType[i] := FCurvesTool.Curves.CurveType[i];
  end;

  for i := 0 to 4 do
  begin
    for j := 0 to 16 do
    begin
      for k := 0 to 1 do
      begin
        LCurvesLayerPanel.CurvesTool.Curves.Points[i, j, k] := FCurvesTool.Curves.Points[i, j, k];
      end;
    end;
  end;

  for i := 0 to 4 do
  begin
    for j := 0 to 255 do
    begin
      LCurvesLayerPanel.CurvesTool.Curves.FCurve[i, j] := FCurvesTool.Curves.FCurve[i, j];
    end;
  end;

  with LCurvesLayerPanel do
  begin
    CurvesTool.Channel   := FCurvesTool.Channel;
    CurvesTool.Scale     := FCurvesTool.Scale;
    CurvesTool.CurveType := FCurvesTool.CurveType;

    SaveLastAdjustment;
  end;

  LNewLayer.Bitmap.Changed;
  ActiveChildForm.IsImageProcessed := True;
  ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
end; 

procedure TgmCurvesLayerCommand.Rollback;
var
  LCurvesLayerPanel: TgmCurvesLayerPanel;
  i, j, k          : Integer;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
      end;

    lctDelete:
      begin
        CreateCurvesLayer;

        ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerName.Caption := FLayerName;

        frmLayer.cmbbxLayerBlendMode.ItemIndex  := FLayerBlendModeIndex;
        frmLayer.ggbrLayerOpacity.Position      := FLayerOpacity;
        frmLayer.chckbxLockTransparency.Checked := FLayerLockTransparency;
      end;

    lctModification:
      begin
        if ActiveChildForm.LayerPanelList.CurrentIndex <> FTargetLayerIndex then
        begin
          ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
        end;

        if Assigned(FOldCurvesTool) then
        begin
          LCurvesLayerPanel := TgmCurvesLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

          for j := Low(LCurvesLayerPanel.CurvesTool.LUT.luts) to
                   High(LCurvesLayerPanel.CurvesTool.LUT.luts) do
          begin
            for i := Low(LCurvesLayerPanel.CurvesTool.LUT.luts[j]) to
                     High(LCurvesLayerPanel.CurvesTool.LUT.luts[j]) do
            begin
              LCurvesLayerPanel.CurvesTool.LUT.luts[j, i] := FOldCurvesTool.LUT.luts[j, i];
            end;
          end;
            
          for i := 0 to 4 do
          begin
            LCurvesLayerPanel.CurvesTool.Curves.CurveType[i] := FOldCurvesTool.Curves.CurveType[i];
          end;

          for i := 0 to 4 do
          begin
            for j := 0 to 16 do
            begin
              for k := 0 to 1 do
              begin
                LCurvesLayerPanel.CurvesTool.Curves.Points[i, j, k] := FOldCurvesTool.Curves.Points[i, j, k];
              end;
            end;
          end;

          for i := 0 to 4 do
          begin
            for j := 0 to 255 do
            begin
              LCurvesLayerPanel.CurvesTool.Curves.FCurve[i, j] := FOldCurvesTool.Curves.FCurve[i, j];
            end;
          end;

          LCurvesLayerPanel.CurvesTool.Channel   := FOldCurvesTool.Channel;
          LCurvesLayerPanel.CurvesTool.Scale     := FOldCurvesTool.Scale;
          LCurvesLayerPanel.CurvesTool.CurveType := FOldCurvesTool.CurveType;
          LCurvesLayerPanel.SaveLastAdjustment;

          ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
        end;
      end;
  end;

  if FLayerCommandType in [lctNew, lctDelete] then
  begin
    ActiveChildForm.LayerPanelList.CurvesLayerNumber := ActiveChildForm.LayerPanelList.CurvesLayerNumber - 1;
    ProcessAfterCreateDeleteLayerCommandDone;
  end;
end;

procedure TgmCurvesLayerCommand.Execute;
var
  LCurvesLayerPanel: TgmCurvesLayerPanel;
  i, j, k          : Integer;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        CreateCurvesLayer;
      end;
      
    lctDelete:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
      end;

    lctModification:
      begin
        if ActiveChildForm.LayerPanelList.CurrentIndex <> FTargetLayerIndex then
        begin
          ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
        end;
        
        if Assigned(FCurvesTool) then
        begin
          LCurvesLayerPanel := TgmCurvesLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

          for j := Low(LCurvesLayerPanel.CurvesTool.LUT.luts) to
                   High(LCurvesLayerPanel.CurvesTool.LUT.luts) do
          begin
            for i := Low(LCurvesLayerPanel.CurvesTool.LUT.luts[j]) to
                     High(LCurvesLayerPanel.CurvesTool.LUT.luts[j]) do
            begin
              LCurvesLayerPanel.CurvesTool.LUT.luts[j, i] := FCurvesTool.LUT.luts[j, i];
            end;
          end;
            
          for i := 0 to 4 do
          begin
            LCurvesLayerPanel.CurvesTool.Curves.CurveType[i] := FCurvesTool.Curves.CurveType[i];
          end;

          for i := 0 to 4 do
          begin
            for j := 0 to 16 do
            begin
              for k := 0 to 1 do
              begin
                LCurvesLayerPanel.CurvesTool.Curves.Points[i, j, k] := FCurvesTool.Curves.Points[i, j, k];
              end;
            end;
          end;

          for i := 0 to 4 do
          begin
            for j := 0 to 255 do
            begin
              LCurvesLayerPanel.CurvesTool.Curves.FCurve[i, j] := FCurvesTool.Curves.FCurve[i, j];
            end;
          end;

          LCurvesLayerPanel.CurvesTool.Channel   := FCurvesTool.Channel;
          LCurvesLayerPanel.CurvesTool.Scale     := FCurvesTool.Scale;
          LCurvesLayerPanel.CurvesTool.CurveType := FCurvesTool.CurveType;
          LCurvesLayerPanel.SaveLastAdjustment;

          ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
        end;
      end;
  end;

  if FLayerCommandType in [lctNew, lctDelete] then
  begin
    ProcessAfterCreateDeleteLayerCommandDone;
  end;
end;

//-- TgmColorBalanceLayerCommand -----------------------------------------------

constructor TgmColorBalanceLayerCommand.Create(const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType);
var
  i                      : Integer;
  LColorBalanceLayerPanel: TgmColorBalanceLayerPanel;
begin
  inherited Create(caNone, '');

  LColorBalanceLayerPanel := TgmColorBalanceLayerPanel(ALayerPanel);

  FTargetLayerIndex := ALayerIndex;
  FLayerCommandType := ALayerCommandType;
  FLayerName        := LColorBalanceLayerPanel.LayerName.Caption;

  case FLayerCommandType of
    lctNew:
      begin
        FCommandName := 'New ' + FLayerName + ' Layer';
      end;

    lctDelete:
      begin
        FCommandName := 'Delete Layer';
      end;
      
    lctModification:
      begin
        FCommandName := 'Modify Color Balance Layer';
      end;
  end;

  FOperateName := 'Undo ' + FCommandName;

  FColorBalance := TgmColorBalance.Create(LColorBalanceLayerPanel.AssociatedLayer.Bitmap);

  with FColorBalance do
  begin
    for i := 0 to 2 do
    begin
      CyanRedArray[i]      := LColorBalanceLayerPanel.ColorBalance.CyanRedArray[i];
      MagentaGreenArray[i] := LColorBalanceLayerPanel.ColorBalance.MagentaGreenArray[i];
      YellowBlueArray[i]   := LColorBalanceLayerPanel.ColorBalance.YellowBlueArray[i];
    end;

    for i := 0 to 255 do
    begin
      RedLookup[i]   := LColorBalanceLayerPanel.ColorBalance.RedLookup[i];
      GreenLookup[i] := LColorBalanceLayerPanel.ColorBalance.GreenLookup[i];
      BlueLookup[i]  := LColorBalanceLayerPanel.ColorBalance.BlueLookup[i];
    end;

    PreserveLuminosity := LColorBalanceLayerPanel.ColorBalance.PreserveLuminosity;
    TransferMode       := LColorBalanceLayerPanel.ColorBalance.TransferMode;
  end;

  if FLayerCommandType = lctModification then
  begin
    // Copy old records.
    FOldColorBalance := TgmColorBalance.Create(LColorBalanceLayerPanel.LastColorBalance.SourceBitmap);

    with FOldColorBalance do
    begin
      for i := 0 to 2 do
      begin
        CyanRedArray[i]      := LColorBalanceLayerPanel.LastColorBalance.CyanRedArray[i];
        MagentaGreenArray[i] := LColorBalanceLayerPanel.LastColorBalance.MagentaGreenArray[i];
        YellowBlueArray[i]   := LColorBalanceLayerPanel.LastColorBalance.YellowBlueArray[i];
      end;

      for i := 0 to 255 do
      begin
        RedLookup[i]   := LColorBalanceLayerPanel.LastColorBalance.RedLookup[i];
        GreenLookup[i] := LColorBalanceLayerPanel.LastColorBalance.GreenLookup[i];
        BlueLookup[i]  := LColorBalanceLayerPanel.LastColorBalance.BlueLookup[i];
      end;

      PreserveLuminosity := LColorBalanceLayerPanel.LastColorBalance.PreserveLuminosity;
      TransferMode       := LColorBalanceLayerPanel.LastColorBalance.TransferMode;
    end;
  end
  else
  begin
    FOldColorBalance := nil;
  end;

  if ALayerCommandType = lctDelete then
  begin
    FLayerLockTransparency := ALayerPanel.IsLockTransparency;
    FLayerBlendModeIndex   := ALayerPanel.BlendModeIndex;
    FLayerOpacity          := ALayerPanel.LayerMasterAlpha;
  end;
end;

destructor TgmColorBalanceLayerCommand.Destroy;
begin
  FColorBalance.Free;
  FOldColorBalance.Free;
  
  inherited Destroy;
end;

procedure TgmColorBalanceLayerCommand.CreateColorBalanceLayer;
var
  LNewLayer, LBackLayer  : TBitmapLayer;
  LLayerPanel            : TgmLayerPanel;
  LColorBalanceLayerPanel: TgmColorBalanceLayerPanel;
  i                      : Integer;
begin
  if frmRichTextEditor.Visible then
  begin
    ActiveChildForm.CommitEdits;
  end;

  LBackLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[0]);
  
  // insert a new layer to FLayers
  ActiveChildForm.imgDrawingArea.Layers.Insert(FTargetLayerIndex, TBitmapLayer);
  LNewLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[FTargetLayerIndex]);
  LNewLayer.Bitmap.SetSize(LBackLayer.Bitmap.Width, LBackLayer.Bitmap.Height);
  LNewLayer.Location := LBackLayer.Location;
  LNewLayer.Scaled   := True;

  // Create a Layer Panel
  LLayerPanel := TgmColorBalanceLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer);
  LLayerPanel.BlendModeIndex     := FLayerBlendModeIndex;
  LLayerPanel.LayerMasterAlpha   := FLayerOpacity;
  LLayerPanel.IsLockTransparency := FLayerLockTransparency;

  // Add new layer panel to list
  ActiveChildForm.LayerPanelList.InsertLayerPanelToList(FTargetLayerIndex, LLayerPanel);

  // creating and showing the mask after the layer panel is inserted to the layer panel list
  if FLayerCommandType = lctNew then
  begin
    frmLayer.AddMaskClick(nil);
  end;

  LColorBalanceLayerPanel := TgmColorBalanceLayerPanel(LLayerPanel);

  with LColorBalanceLayerPanel do
  begin
    for i := 0 to 2 do
    begin
      ColorBalance.CyanRedArray[i]      := FColorBalance.CyanRedArray[i];
      ColorBalance.MagentaGreenArray[i] := FColorBalance.MagentaGreenArray[i];
      ColorBalance.YellowBlueArray[i]   := FColorBalance.YellowBlueArray[i];
    end;

    for i := 0 to 255 do
    begin
      ColorBalance.RedLookup[i]   := FColorBalance.RedLookup[i];
      ColorBalance.GreenLookup[i] := FColorBalance.GreenLookup[i];
      ColorBalance.BlueLookup[i]  := FColorBalance.BlueLookup[i];
    end;

    ColorBalance.PreserveLuminosity := FColorBalance.PreserveLuminosity;
    ColorBalance.TransferMode       := FColorBalance.TransferMode;
    SaveLastAdjustment;
  end;

  LNewLayer.Bitmap.Changed;
  ActiveChildForm.IsImageProcessed := True;
  ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
end;

procedure TgmColorBalanceLayerCommand.Rollback;
var
  LColorBalanceLayerPanel: TgmColorBalanceLayerPanel;
  i                      : Integer;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
      end;

    lctDelete:
      begin
        CreateColorBalanceLayer;

        ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerName.Caption := FLayerName;
        
        frmLayer.cmbbxLayerBlendMode.ItemIndex  := FLayerBlendModeIndex;
        frmLayer.ggbrLayerOpacity.Position      := FLayerOpacity;
        frmLayer.chckbxLockTransparency.Checked := FLayerLockTransparency;
      end;

    lctModification:
      begin
        if ActiveChildForm.LayerPanelList.CurrentIndex <> FTargetLayerIndex then
        begin
          ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
        end;

        if Assigned(FOldColorBalance) then
        begin
          LColorBalanceLayerPanel := TgmColorBalanceLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

          with LColorBalanceLayerPanel do
          begin
            for i := 0 to 2 do
            begin
              ColorBalance.CyanRedArray[i]      := FOldColorBalance.CyanRedArray[i];
              ColorBalance.MagentaGreenArray[i] := FOldColorBalance.MagentaGreenArray[i];
              ColorBalance.YellowBlueArray[i]   := FOldColorBalance.YellowBlueArray[i];
            end;

            for i := 0 to 255 do
            begin
              ColorBalance.RedLookup[i]   := FOldColorBalance.RedLookup[i];
              ColorBalance.GreenLookup[i] := FOldColorBalance.GreenLookup[i];
              ColorBalance.BlueLookup[i]  := FOldColorBalance.BlueLookup[i];
            end;

            ColorBalance.PreserveLuminosity := FOldColorBalance.PreserveLuminosity ;
            ColorBalance.TransferMode       := FOldColorBalance.TransferMode;
            SaveLastAdjustment;
          end;

          ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
        end;
      end;
  end;

  if FLayerCommandType in [lctNew, lctDelete] then
  begin
    ActiveChildForm.LayerPanelList.ColorBalanceLayerNumber := ActiveChildForm.LayerPanelList.ColorBalanceLayerNumber - 1;
    ProcessAfterCreateDeleteLayerCommandDone;
  end;
end;

procedure TgmColorBalanceLayerCommand.Execute;
var
  LColorBalanceLayerPanel: TgmColorBalanceLayerPanel;
  i                      : Integer;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        CreateColorBalanceLayer;
      end;
      
    lctDelete:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
      end;

    lctModification:
      begin
        if ActiveChildForm.LayerPanelList.CurrentIndex <> FTargetLayerIndex then
        begin
          ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
        end;

        if Assigned(FColorBalance) then
        begin
          LColorBalanceLayerPanel := TgmColorBalanceLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

          with LColorBalanceLayerPanel do
          begin
            for i := 0 to 2 do
            begin
              ColorBalance.CyanRedArray[i]      := FColorBalance.CyanRedArray[i];
              ColorBalance.MagentaGreenArray[i] := FColorBalance.MagentaGreenArray[i];
              ColorBalance.YellowBlueArray[i]   := FColorBalance.YellowBlueArray[i];
            end;

            for i := 0 to 255 do
            begin
              ColorBalance.RedLookup[i]   := FColorBalance.RedLookup[i];
              ColorBalance.GreenLookup[i] := FColorBalance.GreenLookup[i];
              ColorBalance.BlueLookup[i]  := FColorBalance.BlueLookup[i];
            end;

            ColorBalance.PreserveLuminosity := FColorBalance.PreserveLuminosity ;
            ColorBalance.TransferMode       := FColorBalance.TransferMode;
            SaveLastAdjustment;
          end;

          ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
        end;
      end;
  end;

  if FLayerCommandType in [lctNew, lctDelete] then
  begin
    ProcessAfterCreateDeleteLayerCommandDone;
  end;
end;

//-- TgmBrightContrastLayerCommand ---------------------------------------------

constructor TgmBrightContrastLayerCommand.Create(const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType);
var
  LBrightContrastLayerPanel: TgmBrightContrastLayerPanel;
begin
  inherited Create(caNone, '');

  LBrightContrastLayerPanel := TgmBrightContrastLayerPanel(ALayerPanel);

  FTargetLayerIndex := ALayerIndex;
  FLayerCommandType := ALayerCommandType;
  FLayerName        := LBrightContrastLayerPanel.LayerName.Caption;

  case FLayerCommandType of
    lctNew         : FCommandName := 'New ' + FLayerName + ' Layer';
    lctDelete      : FCommandName := 'Delete Layer';
    lctModification: FCommandName := 'Modify Brightness/Contrast Layer';
  end;

  FOperateName := 'Undo ' + FCommandName;

  FBrightness := LBrightContrastLayerPanel.AdjustBrightness;
  FContrast   := LBrightContrastLayerPanel.AdjustContrast;

  if FLayerCommandType = lctModification then
  begin
    FOldBrightness := LBrightContrastLayerPanel.LastBrightness;
    FOldContrast   := LBrightContrastLayerPanel.LastContrast;
  end
  else
  if FLayerCommandType = lctDelete then
  begin
    FLayerLockTransparency := ALayerPanel.IsLockTransparency;
    FLayerBlendModeIndex   := ALayerPanel.BlendModeIndex;
    FLayerOpacity          := ALayerPanel.LayerMasterAlpha;
  end;
end;

procedure TgmBrightContrastLayerCommand.CreateBrightContrastLayer;
var
  LNewLayer, LBackLayer    : TBitmapLayer;
  LLayerPanel              : TgmLayerPanel;
  LBrightContrastLayerPanel: TgmBrightContrastLayerPanel;
begin
  if frmRichTextEditor.Visible then
  begin
    ActiveChildForm.CommitEdits;
  end;

  LBackLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[0]);

  // insert a new layer to ActiveChildForm.imgDrawingArea.Layers
  ActiveChildForm.imgDrawingArea.Layers.Insert(FTargetLayerIndex, TBitmapLayer);
  LNewLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[FTargetLayerIndex]);
  LNewLayer.Bitmap.SetSize(LBackLayer.Bitmap.Width, LBackLayer.Bitmap.Height);
  LNewLayer.Location := LBackLayer.Location;
  LNewLayer.Scaled   := True;

  // create a layer panel
  LLayerPanel                    := TgmBrightContrastLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer);
  LLayerPanel.BlendModeIndex     := FLayerBlendModeIndex;
  LLayerPanel.LayerMasterAlpha   := FLayerOpacity;
  LLayerPanel.IsLockTransparency := FLayerLockTransparency;

  // add new layer panel to list
  ActiveChildForm.LayerPanelList.InsertLayerPanelToList(FTargetLayerIndex, LLayerPanel);

  // creating and showing the mask after the layer panel is inserted to the layer panel list
  if FLayerCommandType = lctNew then
  begin
    frmLayer.AddMaskClick(nil);
  end;

  LBrightContrastLayerPanel := TgmBrightContrastLayerPanel(LLayerPanel);

  with LBrightContrastLayerPanel do
  begin
    AdjustBrightness := FBrightness;
    AdjustContrast   := FContrast;
    SaveLastAdjustment;
  end;

  LNewLayer.Bitmap.Changed;
  ActiveChildForm.IsImageProcessed := True;
  ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
end;

procedure TgmBrightContrastLayerCommand.Rollback;
var
  LBrightContrastLayerPanel: TgmBrightContrastlayerPanel;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
      end;

    lctDelete:
      begin
        CreateBrightContrastLayer;

        ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerName.Caption := FLayerName;
        
        frmLayer.cmbbxLayerBlendMode.ItemIndex  := FLayerBlendModeIndex;
        frmLayer.ggbrLayerOpacity.Position      := FLayerOpacity;
        frmLayer.chckbxLockTransparency.Checked := FLayerLockTransparency;
      end;

    lctModification:
      begin
        if ActiveChildForm.LayerPanelList.CurrentIndex <> FTargetLayerIndex then
        begin
          ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
        end;

        LBrightContrastLayerPanel := TgmBrightContrastLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

        with LBrightContrastLayerPanel do
        begin
          AdjustBrightness := FOldBrightness;
          AdjustContrast   := FOldContrast;
          SaveLastAdjustment;
        end;

        ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
      end;
  end;

  if FLayerCommandType in [lctNew, lctDelete] then
  begin
    ActiveChildForm.LayerPanelList.BrightContrastLayerNumber := ActiveChildForm.LayerPanelList.BrightContrastLayerNumber - 1;
    ProcessAfterCreateDeleteLayerCommandDone;
  end;
end;

procedure TgmBrightContrastLayerCommand.Execute;
var
  LBrightContrastLayerPanel: TgmBrightContrastLayerPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        CreateBrightContrastLayer;
      end;

    lctDelete:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
      end;

    lctModification:
      begin
        if ActiveChildForm.LayerPanelList.CurrentIndex <> FTargetLayerIndex then
        begin
          ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
        end;

        LBrightContrastLayerPanel := TgmBrightContrastLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

        with LBrightContrastLayerPanel do
        begin
          AdjustBrightness := FBrightness;
          AdjustContrast   := FContrast;

          SaveLastAdjustment;
        end;

        ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
      end;
  end;

  if FLayerCommandType in [lctNew, lctDelete] then
  begin
    ProcessAfterCreateDeleteLayerCommandDone;
  end;
end;

//-- TgmHLSLayerCommand --------------------------------------------------------

constructor TgmHLSLayerCommand.Create(const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType);
var
  LHueSaturationLayerPanel: TgmHueSaturationLayerPanel;
begin
  inherited Create(caNone, '');

  LHueSaturationLayerPanel := TgmHueSaturationLayerPanel(ALayerPanel);

  FTargetLayerIndex := ALayerIndex;
  FLayerCommandType := ALayerCommandType;
  FLayerName        := LHueSaturationLayerPanel.LayerName.Caption;

  case FLayerCommandType of
    lctNew:
      begin
        FCommandName := 'New ' + FLayerName + ' Layer';
      end;
      
    lctDelete:
      begin
        FCommandName := 'Delete Layer';
      end;
      
    lctModification:
      begin
        FCommandName := 'Modify Hue/Saturation Layer';
      end;
  end;

  FOperateName := 'Undo ' + FCommandName;

  FHue        := LHueSaturationLayerPanel.ChangedH;
  FLV         := LHueSaturationLayerPanel.ChangedLOrV;
  FSaturation := LHueSaturationLayerPanel.ChangedS;
  FMode       := LHueSaturationLayerPanel.AdjustMode;

  if FLayerCommandType = lctModification then
  begin
    FOldH    := LHueSaturationLayerPanel.LastChangedH;
    FOldLV   := LHueSaturationLayerPanel.LastChangedLOrV;
    FOldS    := LHueSaturationLayerPanel.LastChangedS;
    FOldMode := LHueSaturationLayerPanel.LastAdjustMode;
  end;

  if ALayerCommandType = lctDelete then
  begin
    FLayerLockTransparency := ALayerPanel.IsLockTransparency;
    FLayerBlendModeIndex   := ALayerPanel.BlendModeIndex;
    FLayerOpacity          := ALayerPanel.LayerMasterAlpha;
  end;
end;

procedure TgmHLSLayerCommand.CreateHLSLayer;
var
  LNewLayer, LBackLayer   : TBitmapLayer;
  LLayerPanel             : TgmLayerPanel;
  LHueSaturationLayerPanel: TgmHueSaturationLayerPanel;
begin
  if frmRichTextEditor.Visible then
  begin
    ActiveChildForm.CommitEdits;
  end;

  LBackLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[0]);

  // insert a new layer to FLayers
  ActiveChildForm.imgDrawingArea.Layers.Insert(FTargetLayerIndex, TBitmapLayer);
  LNewLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[FTargetLayerIndex]);
  LNewLayer.Bitmap.SetSize(LBackLayer.Bitmap.Width, LBackLayer.Bitmap.Height);
  LNewLayer.Location := LBackLayer.Location;
  LNewLayer.Scaled   := True;

  // create a Layer Panel
  LLayerPanel := TgmHueSaturationLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer);
  LLayerPanel.BlendModeIndex     := FLayerBlendModeIndex;
  LLayerPanel.LayerMasterAlpha   := FLayerOpacity;
  LLayerPanel.IsLockTransparency := FLayerLockTransparency;

  // add new layer panel to list
  ActiveChildForm.LayerPanelList.InsertLayerPanelToList(FTargetLayerIndex, LLayerPanel);

  // creating and showing the mask after the layer panel is inserted to the layer panel list
  if FLayerCommandType = lctNew then
  begin
    frmLayer.AddMaskClick(nil);
  end;

  LHueSaturationLayerPanel := TgmHueSaturationLayerPanel(LLayerPanel);

  with LHueSaturationLayerPanel do
  begin
    ChangedH    := FHue;
    ChangedLOrV := FLV;
    ChangedS    := FSaturation;
    AdjustMode  := FMode;
    
    SaveLastAdjustment;
  end;

  LNewLayer.Bitmap.Changed;
  ActiveChildForm.IsImageProcessed := True;
  ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
end;

procedure TgmHLSLayerCommand.Rollback;
var
  LHueSaturationLayerPanel: TgmHueSaturationLayerPanel;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
      end;

    lctDelete:
      begin
        CreateHLSLayer;

        ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerName.Caption := FLayerName;
        
        frmLayer.cmbbxLayerBlendMode.ItemIndex  := FLayerBlendModeIndex;
        frmLayer.ggbrLayerOpacity.Position      := FLayerOpacity;
        frmLayer.chckbxLockTransparency.Checked := FLayerLockTransparency;
      end;

    lctModification:
      begin
        if ActiveChildForm.LayerPanelList.CurrentIndex <> FTargetLayerIndex then
        begin
          ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
        end;

        LHueSaturationLayerPanel := TgmHueSaturationLayerPanel(
          ActiveChildForm.LayerPanelList.SelectedLayerPanel);

        with LHueSaturationLayerPanel do
        begin
          ChangedH    := FOldH;
          ChangedLOrV := FOldLV;
          ChangedS    := FOldS;
          AdjustMode  := FOldMode;
          
          SaveLastAdjustment;
        end;

        ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
      end;
  end;

  if FLayerCommandType in [lctNew, lctDelete] then
  begin
    ActiveChildForm.LayerPanelList.HLSLayerNumber := ActiveChildForm.LayerPanelList.HLSLayerNumber - 1;
    ProcessAfterCreateDeleteLayerCommandDone;
  end;
end;

procedure TgmHLSLayerCommand.Execute;
var
  LHueSaturationLayerPanel: TgmHueSaturationLayerPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        CreateHLSLayer;
      end;
      
    lctDelete:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
      end;

    lctModification:
      begin
        if ActiveChildForm.LayerPanelList.CurrentIndex <> FTargetLayerIndex then
        begin
          ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
        end;

        LHueSaturationLayerPanel := TgmHueSaturationLayerPanel(
          ActiveChildForm.LayerPanelList.SelectedLayerPanel);

        with LHueSaturationLayerPanel do
        begin
          ChangedH    := FHue;
          ChangedLOrV := FLV;
          ChangedS    := FSaturation;
          AdjustMode  := FMode;
          
          SaveLastAdjustment;
        end;
        
        ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
      end;
  end;

  if FLayerCommandType in [lctNew, lctDelete] then
  begin
    ProcessAfterCreateDeleteLayerCommandDone;
  end;
end;

//-- TgmChannelMixerLayerCommand -----------------------------------------------

constructor TgmChannelMixerLayerCommand.Create(const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType);
var
  LChannelMixerLayerPanel: TgmChannelMixerLayerPanel;
begin
  inherited Create(caNone, '');

  LChannelMixerLayerPanel := TgmChannelMixerLayerPanel(ALayerPanel);

  FTargetLayerIndex := ALayerIndex;
  FLayerCommandType := ALayerCommandType;
  FLayerName        := LChannelMixerLayerPanel.LayerName.Caption;
  FPreview          := LChannelMixerLayerPanel.IsPreview;

  case FLayerCommandType of
    lctNew:
      begin
        FCommandName := 'New ' + FLayerName + ' Layer';
      end;
      
    lctDelete:
      begin
        FCommandName := 'Delete Layer';
      end;
      
    lctModification:
      begin
        FCommandName := 'Modify Channel Mixer Layer';
      end;
  end;

  FOperateName := 'Undo ' + FCommandName;

  FChannelMixer := TgmChannelMixer.Create;
  FChannelMixer.AssignData(LChannelMixerLayerPanel.ChannelMixer);

  FOldChannelMixer := nil;

  if FLayerCommandType = lctModification then
  begin
    FOldChannelMixer := TgmChannelMixer.Create;
    FOldChannelMixer.AssignData(LChannelMixerLayerPanel.LastChannelMixer);
    FOldPreview := LChannelMixerLayerPanel.IsLastPreview;
  end
  else
  if FLayerCommandType = lctDelete then
  begin
    FLayerLockTransparency := ALayerPanel.IsLockTransparency;
    FLayerBlendModeIndex   := ALayerPanel.BlendModeIndex;
    FLayerOpacity          := ALayerPanel.LayerMasterAlpha;
  end;
end;

destructor TgmChannelMixerLayerCommand.Destroy;
begin
  FChannelMixer.Free;
  FOldChannelMixer.Free;

  inherited Destroy;
end;

procedure TgmChannelMixerLayerCommand.CreateChannelMixerLayer;
var
  LNewLayer, LBackLayer  : TBitmapLayer;
  LLayerPanel            : TgmLayerPanel;
  LChannelMixerLayerPanel: TgmChannelMixerLayerPanel;
begin
  if frmRichTextEditor.Visible then
  begin
    ActiveChildForm.CommitEdits;
  end;

  LBackLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[0]);
  
  // insert a new layer to ActiveChildForm.imgDrawingArea.Layers
  ActiveChildForm.imgDrawingArea.Layers.Insert(FTargetLayerIndex, TBitmapLayer);
  LNewLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[FTargetLayerIndex]);
  LNewLayer.Bitmap.SetSize(LBackLayer.Bitmap.Width, LBackLayer.Bitmap.Height);
  LNewLayer.Location := LBackLayer.Location;
  LNewLayer.Scaled   := True;

  // create a layer panel
  LLayerPanel := TgmChannelMixerLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer);
  LLayerPanel.BlendModeIndex     := FLayerBlendModeIndex;
  LLayerPanel.LayerMasterAlpha   := FLayerOpacity;
  LLayerPanel.IsLockTransparency := FLayerLockTransparency;

  // add new layer panel to list
  ActiveChildForm.LayerPanelList.InsertLayerPanelToList(FTargetLayerIndex, LLayerPanel);

  // creating and showing the mask after the layer panel is inserted to the layer panel list
  if FLayerCommandType = lctNew then
  begin
    frmLayer.AddMaskClick(nil);
  end;

  LChannelMixerLayerPanel := TgmChannelMixerLayerPanel(LLayerPanel);

  LChannelMixerLayerPanel.ChannelMixer.AssignData(FChannelMixer);
  LChannelMixerLayerPanel.IsPreview := FPreview;
  LChannelMixerLayerPanel.SaveLastAdjustment;

  LNewLayer.Bitmap.Changed;
  ActiveChildForm.IsImageProcessed := True;
  ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
end;

procedure TgmChannelMixerLayerCommand.Rollback;
var
  LChannelMixerLayerPanel: TgmChannelMixerlayerPanel;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
      end;

    lctDelete:
      begin
        CreateChannelMixerLayer;

        ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerName.Caption := FLayerName;
        
        frmLayer.cmbbxLayerBlendMode.ItemIndex  := FLayerBlendModeIndex;
        frmLayer.ggbrLayerOpacity.Position      := FLayerOpacity;
        frmLayer.chckbxLockTransparency.Checked := FLayerLockTransparency;
      end;

    lctModification:
      begin
        if ActiveChildForm.LayerPanelList.CurrentIndex <> FTargetLayerIndex then
        begin
          ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
        end;

        LChannelMixerLayerPanel := TgmChannelMixerLayerPanel(
          ActiveChildForm.LayerPanelList.SelectedLayerPanel);

        LChannelMixerLayerPanel.ChannelMixer.AssignData(FOldChannelMixer);
        LChannelMixerLayerPanel.IsPreview := FOldPreview;
        LChannelMixerLayerPanel.SaveLastAdjustment;

        ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
      end;
  end;

  if FLayerCommandType in [lctNew, lctDelete] then
  begin
    ActiveChildForm.LayerPanelList.ChannelMixerLayerNumber := ActiveChildForm.LayerPanelList.ChannelMixerLayerNumber - 1;
    ProcessAfterCreateDeleteLayerCommandDone;
  end;
end;

procedure TgmChannelMixerLayerCommand.Execute;
var
  LChannelMixerLayerPanel: TgmChannelMixerLayerPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        CreateChannelMixerLayer;
      end;
      
    lctDelete:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
      end;

    lctModification:
      begin
        if ActiveChildForm.LayerPanelList.CurrentIndex <> FTargetLayerIndex then
        begin
          ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
        end;

        LChannelMixerLayerPanel := TgmChannelMixerLayerPanel(
          ActiveChildForm.LayerPanelList.SelectedLayerPanel);

        LChannelMixerLayerPanel.ChannelMixer.AssignData(FChannelMixer);
        LChannelMixerLayerPanel.IsPreview := FPreview;
        LChannelMixerLayerPanel.SaveLastAdjustment;

        ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
      end;
  end;

  if FLayerCommandType in [lctNew, lctDelete] then
  begin
    ProcessAfterCreateDeleteLayerCommandDone;
  end;
end;

//-- TgmGradientMapLayerCommand --------------------------------------------------

constructor TgmGradientMapLayerCommand.Create(const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType);
var
  LGradientMapLayerPanel: TgmGradientMapLayerPanel;
begin
  inherited Create(caNone, '');

  LGradientMapLayerPanel := TgmGradientMapLayerPanel(ALayerPanel);

  FTargetLayerIndex := ALayerIndex;
  FLayerCommandType := ALayerCommandType;
  FLayerName        := LGradientMapLayerPanel.LayerName.Caption;

  case FLayerCommandType of
    lctNew:
      begin
        FCommandName := 'New ' + FLayerName + ' Layer';
      end;
      
    lctDelete:
      begin
        FCommandName := 'Delete Layer';
      end;

    lctModification:
      begin
        FCommandName := 'Modify Gradient Map Layer';
      end;
  end;

  FOperateName := 'Undo ' + FCommandName;

  FGradient := TgmGradientItem.Create(nil);
  FGradient.Assign(LGradientMapLayerPanel.Gradient);
  
  FReversed := LGradientMapLayerPanel.IsReversed;

  if FLayerCommandType = lctModification then
  begin
    FOldGradient := TgmGradientItem.Create(nil);
    FOldGradient.Assign(LGradientMapLayerPanel.LastGradient);
    FOldReversed := LGradientMapLayerPanel.IsLastReversed;
  end
  else
  begin
    FOldGradient := nil;
  end;

  if ALayerCommandType = lctDelete then
  begin
    FLayerLockTransparency := ALayerPanel.IsLockTransparency;
    FLayerBlendModeIndex   := ALayerPanel.BlendModeIndex;
    FLayerOpacity          := ALayerPanel.LayerMasterAlpha;
  end;
end;

destructor TgmGradientMapLayerCommand.Destroy;
begin
  FGradient.Free;
  FOldGradient.Free;
  
  inherited Destroy;
end;

procedure TgmGradientMapLayerCommand.CreateGradientMapLayer;
var
  LNewLayer, LBackLayer : TBitmapLayer;
  LLayerPanel           : TgmLayerPanel;
  LGradientMapLayerPanel: TgmGradientMapLayerPanel;
begin
  if frmRichTextEditor.Visible then
  begin
    ActiveChildForm.CommitEdits;
  end;

  LBackLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[0]);

  // insert a new layer to FLayers
  ActiveChildForm.imgDrawingArea.Layers.Insert(FTargetLayerIndex, TBitmapLayer);

  LNewLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[FTargetLayerIndex]);
  LNewLayer.Bitmap.SetSize(LBackLayer.Bitmap.Width, LBackLayer.Bitmap.Height);

  LNewLayer.Location := LBackLayer.Location;
  LNewLayer.Scaled   := True;

  // Create a Layer Panel
  LLayerPanel := TgmGradientMapLayerPanel.Create(
    frmLayer.scrlbxLayers, LNewLayer, frmGradientPicker.GetMapLayerGradient);

  LLayerPanel.BlendModeIndex     := FLayerBlendModeIndex;
  LLayerPanel.LayerMasterAlpha   := FLayerOpacity;
  LLayerPanel.IsLockTransparency := FLayerLockTransparency;

  // add new layer panel to list
  ActiveChildForm.LayerPanelList.InsertLayerPanelToList(FTargetLayerIndex, LLayerPanel);

  { Creating and showing the mask after the layer panel is inserted to the
    layer panel list. }
  if FLayerCommandType = lctNew then
  begin
    frmLayer.AddMaskClick(nil);
  end;

  LGradientMapLayerPanel := TgmGradientMapLayerPanel(LLayerPanel);

  with LGradientMapLayerPanel do
  begin
    Gradient   := FGradient;
    IsReversed := FReversed;
    
    SaveLastAdjustment;
  end;

  LNewLayer.Bitmap.Changed;
  ActiveChildForm.IsImageProcessed := True; // identify the image has been modified

  ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
end;

procedure TgmGradientMapLayerCommand.Rollback;
var
  LGradientMapLayerPanel: TgmGradientMapLayerPanel;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
      end;

    lctDelete:
      begin
        CreateGradientMapLayer;

        ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerName.Caption := FLayerName;
        
        frmLayer.cmbbxLayerBlendMode.ItemIndex  := FLayerBlendModeIndex;
        frmLayer.ggbrLayerOpacity.Position      := FLayerOpacity;
        frmLayer.chckbxLockTransparency.Checked := FLayerLockTransparency;
      end;

    lctModification:
      begin
        if ActiveChildForm.LayerPanelList.CurrentIndex <> FTargetLayerIndex then
        begin
          ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
        end;

        if Assigned(FOldGradient) then
        begin
          LGradientMapLayerPanel := TgmGradientMapLayerPanel(
            ActiveChildForm.LayerPanelList.SelectedLayerPanel);

          with LGradientMapLayerPanel do
          begin
            Gradient       := FOldGradient;
            LastGradient   := FOldGradient;
            IsReversed     := FOldReversed;
            IsLastReversed := FOldReversed;
          end;

          ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
        end;
      end;
  end;

  if FLayerCommandType in [lctNew, lctDelete] then
  begin
    ActiveChildForm.LayerPanelList.GradientMapLayerNumber := ActiveChildForm.LayerPanelList.GradientMapLayerNumber - 1;
    ProcessAfterCreateDeleteLayerCommandDone;
  end;
end;

procedure TgmGradientMapLayerCommand.Execute;
var
  LGradientMapLayerPanel: TgmGradientMapLayerPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        CreateGradientMapLayer;
      end;

    lctDelete:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
      end;
      
    lctModification:
      begin
        if ActiveChildForm.LayerPanelList.CurrentIndex <> FTargetLayerIndex then
        begin
          ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
        end;

        if Assigned(FGradient) then
        begin
          LGradientMapLayerPanel := TgmGradientMapLayerPanel(
            ActiveChildForm.LayerPanelList.SelectedLayerPanel);

          with LGradientMapLayerPanel do
          begin
            Gradient       := FGradient;
            LastGradient   := FGradient;
            IsReversed     := FReversed;
            IsLastReversed := FReversed;
          end;

          ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
        end;
      end;
  end;

  if FLayerCommandType in [lctNew, lctDelete] then
  begin
    ProcessAfterCreateDeleteLayerCommandDone;
  end;
end;

//-- TgmInvertLayerCommand -----------------------------------------------------

constructor TgmInvertLayerCommand.Create(const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType);
begin
  inherited Create(caNone, '');

  FTargetLayerIndex := ALayerIndex;
  FLayerCommandType := ALayerCommandType;
  FLayerName        := ALayerPanel.LayerName.Caption;

  case FLayerCommandType of
    lctNew:
      begin
        FCommandName := 'New ' + FLayerName + ' Layer';
      end;
      
    lctDelete:
      begin
        FCommandName := 'Delete Layer';
      end;
  end;

  FOperateName := 'Undo ' + FCommandName;

  if ALayerCommandType = lctDelete then
  begin
    FLayerLockTransparency := ALayerPanel.IsLockTransparency;
    FLayerBlendModeIndex   := ALayerPanel.BlendModeIndex;
    FLayerOpacity          := ALayerPanel.LayerMasterAlpha;
  end;
end;

procedure TgmInvertLayerCommand.CreateInvertLayer;
var
  LNewLayer, LBackLayer: TBitmapLayer;
  LLayerPanel          : TgmLayerPanel;
begin
  if frmRichTextEditor.Visible then
  begin
    ActiveChildForm.CommitEdits;
  end;

  LBackLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[0]);

  // insert a new layer to FLayers
  ActiveChildForm.imgDrawingArea.Layers.Insert(FTargetLayerIndex, TBitmapLayer);
  LNewLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[FTargetLayerIndex]);
  LNewLayer.Bitmap.SetSize(LBackLayer.Bitmap.Width, LBackLayer.Bitmap.Height);
  LNewLayer.Location := LBackLayer.Location;
  LNewLayer.Scaled   := True;

  // create a Layer Panel
  LLayerPanel := TgmInvertLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer);
  LLayerPanel.BlendModeIndex     := FLayerBlendModeIndex;
  LLayerPanel.LayerMasterAlpha   := FLayerOpacity;
  LLayerPanel.IsLockTransparency := FLayerLockTransparency;

  // add new layer panel to list
  ActiveChildForm.LayerPanelList.InsertLayerPanelToList(FTargetLayerIndex, LLayerPanel);

  // creating and showing the mask after the layer panel is inserted to the layer panel list
  if FLayerCommandType = lctNew then
  begin
    frmLayer.AddMaskClick(nil);
  end;

  LNewLayer.Bitmap.Changed;
  ActiveChildForm.IsImageProcessed := True;
  ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
end;

procedure TgmInvertLayerCommand.Rollback;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
      end;

    lctDelete:
      begin
        CreateInvertLayer;

        ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerName.Caption := FLayerName;
        
        frmLayer.cmbbxLayerBlendMode.ItemIndex  := FLayerBlendModeIndex;
        frmLayer.ggbrLayerOpacity.Position      := FLayerOpacity;
        frmLayer.chckbxLockTransparency.Checked := FLayerLockTransparency;
      end;
  end;

  if FLayerCommandType in [lctNew, lctDelete] then
  begin
    ActiveChildForm.LayerPanelList.InvertLayerNumber := ActiveChildForm.LayerPanelList.InvertLayerNumber - 1;
    ProcessAfterCreateDeleteLayerCommandDone;
  end;
end;

procedure TgmInvertLayerCommand.Execute;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        CreateInvertLayer;
      end;
      
    lctDelete:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
      end;
  end;

  if FLayerCommandType in [lctNew, lctDelete] then
  begin
    ProcessAfterCreateDeleteLayerCommandDone;
  end;
end;

//-- TgmThresholdLayerCommand --------------------------------------------------

constructor TgmThresholdLayerCommand.Create(const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType);
var
  LThresholdLayerPanel: TgmThresholdLayerPanel;
begin
  inherited Create(caNone, '');

  LThresholdLayerPanel := TgmThresholdLayerPanel(ALayerPanel);

  FTargetLayerIndex := ALayerIndex;
  FLayerCommandType := ALayerCommandType;
  FLayerName        := LThresholdLayerPanel.LayerName.Caption;

  case FLayerCommandType of
    lctNew:
      begin
        FCommandName := 'New ' + FLayerName + ' Layer';
      end;
      
    lctDelete:
      begin
        FCommandName := 'Delete Layer';
      end;
      
    lctModification:
      begin
        FCommandName := 'Modify Threshold Layer';
      end;
  end;

  FOperateName := 'Undo ' + FCommandName;

  FLevel    := LThresholdLayerPanel.Level;
  FOldLevel := LThresholdLayerPanel.LastLevel;

  if ALayerCommandType = lctDelete then
  begin
    FLayerLockTransparency := ALayerPanel.IsLockTransparency;
    FLayerBlendModeIndex   := ALayerPanel.BlendModeIndex;
    FLayerOpacity          := ALayerPanel.LayerMasterAlpha;
  end;
end;

procedure TgmThresholdLayerCommand.CreateThresholdLayer;
var
  LNewLayer, LBackLayer: TBitmapLayer;
  LLayerPanel          : TgmLayerPanel;
  LThresholdLayerPanel : TgmThresholdLayerPanel;
begin
  if frmRichTextEditor.Visible then
  begin
    ActiveChildForm.CommitEdits;
  end;

  LBackLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[0]);

  // insert a new layer to FLayers
  ActiveChildForm.imgDrawingArea.Layers.Insert(FTargetLayerIndex, TBitmapLayer);
  LNewLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[FTargetLayerIndex]);
  LNewLayer.Bitmap.SetSize(LBackLayer.Bitmap.Width, LBackLayer.Bitmap.Height);
  LNewLayer.Location := LBackLayer.Location;
  LNewLayer.Scaled   := True;

  // create a Layer Panel
  LLayerPanel := TgmThresholdLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer);
  LLayerPanel.BlendModeIndex     := FLayerBlendModeIndex;
  LLayerPanel.LayerMasterAlpha   := FLayerOpacity;
  LLayerPanel.IsLockTransparency := FLayerLockTransparency;

  // add new layer panel to list
  ActiveChildForm.LayerPanelList.InsertLayerPanelToList(FTargetLayerIndex, LLayerPanel);

  // creating and showing the mask after the layer panel is inserted to the layer panel list
  if FLayerCommandType = lctNew then
  begin
    frmLayer.AddMaskClick(nil);
  end;

  LThresholdLayerPanel := TgmThresholdLayerPanel(LLayerPanel);

  with LThresholdLayerPanel do
  begin
    Level := FLevel;
    SaveLastAdjustment;
  end;

  LNewLayer.Bitmap.Changed;
  ActiveChildForm.IsImageProcessed := True;
  ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
end;

procedure TgmThresholdLayerCommand.Rollback;
var
  LThresholdLayerPanel: TgmThresholdLayerPanel;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
      end;

    lctDelete:
      begin
        CreateThresholdLayer;

        ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerName.Caption := FLayerName;
        
        frmLayer.cmbbxLayerBlendMode.ItemIndex  := FLayerBlendModeIndex;
        frmLayer.ggbrLayerOpacity.Position      := FLayerOpacity;
        frmLayer.chckbxLockTransparency.Checked := FLayerLockTransparency;
      end;

    lctModification:
      begin
        if ActiveChildForm.LayerPanelList.CurrentIndex <> FTargetLayerIndex then
        begin
          ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
        end;

        LThresholdLayerPanel := TgmThresholdLayerPanel(
          ActiveChildForm.LayerPanelList.SelectedLayerPanel);

        with LThresholdLayerPanel do
        begin
          Level     := FOldLevel;
          LastLevel := FOldLevel;
        end;

        ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
      end;
  end;

  if FLayerCommandType in [lctNew, lctDelete] then
  begin
    ActiveChildForm.LayerPanelList.ThresholdLayerNumber := ActiveChildForm.LayerPanelList.ThresholdLayerNumber - 1;
    ProcessAfterCreateDeleteLayerCommandDone;
  end;
end;

procedure TgmThresholdLayerCommand.Execute;
var
  LThresholdLayerPanel: TgmThresholdLayerPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        CreateThresholdLayer;
      end;
      
    lctDelete:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
      end;

    lctModification:
      begin
        if ActiveChildForm.LayerPanelList.CurrentIndex <> FTargetLayerIndex then
        begin
          ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
        end;

        LThresholdLayerPanel := TgmThresholdLayerPanel(
          ActiveChildForm.LayerPanelList.SelectedLayerPanel);

        with LThresholdLayerPanel do
        begin
          Level     := FLevel;
          LastLevel := FLevel;
        end;

        ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
      end;
  end;

  if FLayerCommandType in [lctNew, lctDelete] then
  begin
    ProcessAfterCreateDeleteLayerCommandDone;
  end;
end;

//-- TgmPosterizeLayerCommand --------------------------------------------------

constructor TgmPosterizeLayerCommand.Create(const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType);
var
  LPosterizeLayerPanel: TgmPosterizeLayerPanel;
begin
  inherited Create(caNone, '');

  LPosterizeLayerPanel := TgmPosterizeLayerPanel(ALayerPanel);

  FTargetLayerIndex := ALayerIndex;
  FLayerCommandType := ALayerCommandType;
  FLayerName        := LPosterizeLayerPanel.LayerName.Caption;

  case FLayerCommandType of
    lctNew:
      begin
        FCommandName := 'New ' + FLayerName + ' Layer';
      end;
      
    lctDelete:
      begin
        FCommandName := 'Delete Layer';
      end;
      
    lctModification:
      begin
        FCommandName := 'Modify Posterize Layer';
      end;
  end;

  FOperateName := 'Undo ' + FCommandName;

  FLevel    := LPosterizeLayerPanel.Level;
  FOldLevel := LPosterizeLayerPanel.LastLevel;

  if ALayerCommandType = lctDelete then
  begin
    FLayerLockTransparency := ALayerPanel.IsLockTransparency;
    FLayerBlendModeIndex   := ALayerPanel.BlendModeIndex;
    FLayerOpacity          := ALayerPanel.LayerMasterAlpha;
  end;
end;

procedure TgmPosterizeLayerCommand.CreatePosterizeLayer;
var
  LNewLayer, LBackLayer: TBitmapLayer;
  LLayerPanel          : TgmLayerPanel;
  LPosterizeLayerPanel : TgmPosterizeLayerPanel;
begin
  if frmRichTextEditor.Visible then
  begin
    ActiveChildForm.CommitEdits;
  end;

  LBackLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[0]);
  
  // insert a new layer to FLayers
  ActiveChildForm.imgDrawingArea.Layers.Insert(FTargetLayerIndex, TBitmapLayer);
  LNewLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[FTargetLayerIndex]);
  LNewLayer.Bitmap.SetSize(LBackLayer.Bitmap.Width, LBackLayer.Bitmap.Height);
  LNewLayer.Location := LBackLayer.Location;
  LNewLayer.Scaled   := True;

  // create a Layer Panel
  LLayerPanel := TgmPosterizeLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer);
  LLayerPanel.BlendModeIndex     := FLayerBlendModeIndex;
  LLayerPanel.LayerMasterAlpha   := FLayerOpacity;
  LLayerPanel.IsLockTransparency := FLayerLockTransparency;

  // add new layer panel to list
  ActiveChildForm.LayerPanelList.InsertLayerPanelToList(FTargetLayerIndex, LLayerPanel);

  // creating and showing the mask after the layer panel is inserted to the layer panel list
  if FLayerCommandType = lctNew then
  begin
    frmLayer.AddMaskClick(nil);
  end;

  LPosterizeLayerPanel := TgmPosterizeLayerPanel(LLayerPanel);

  with LPosterizeLayerPanel do
  begin
    Level := FLevel;
    SaveLastAdjustment;
  end;

  LNewLayer.Bitmap.Changed;
  ActiveChildForm.IsImageProcessed := True;
  ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
end;

procedure TgmPosterizeLayerCommand.Rollback;
var
  LPosterizeLayerPanel: TgmPosterizeLayerPanel;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
      end;

    lctDelete:
      begin
        CreatePosterizeLayer;

        ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerName.Caption := FLayerName;
        
        frmLayer.cmbbxLayerBlendMode.ItemIndex  := FLayerBlendModeIndex;
        frmLayer.ggbrLayerOpacity.Position      := FLayerOpacity;
        frmLayer.chckbxLockTransparency.Checked := FLayerLockTransparency;
      end;

    lctModification:
      begin
        if ActiveChildForm.LayerPanelList.CurrentIndex <> FTargetLayerIndex then
        begin
          ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
        end;

        LPosterizeLayerPanel := TgmPosterizeLayerPanel(
          ActiveChildForm.LayerPanelList.SelectedLayerPanel);

        with LPosterizeLayerPanel do
        begin
          Level     := FOldLevel;
          LastLevel := FOldLevel;
        end;

        ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
      end;
  end;

  if FLayerCommandType in [lctNew, lctDelete] then
  begin
    ActiveChildForm.LayerPanelList.PosterizeLayerNumber := ActiveChildForm.LayerPanelList.PosterizeLayerNumber - 1;
    ProcessAfterCreateDeleteLayerCommandDone;
  end;
end;

procedure TgmPosterizeLayerCommand.Execute;
var
  LPosterizeLayerPanel: TgmPosterizeLayerPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        CreatePosterizeLayer;
      end;
      
    lctDelete:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
      end;

    LctModification:
      begin
        if ActiveChildForm.LayerPanelList.CurrentIndex <> FTargetLayerIndex then
        begin
          ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
        end;

        LPosterizeLayerPanel := TgmPosterizeLayerPanel(
          ActiveChildForm.LayerPanelList.SelectedLayerPanel);

        with LPosterizeLayerPanel do
        begin
          Level     := FLevel;
          LastLevel := FLevel;
        end;

        ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
      end;
  end;

  if FLayerCommandType in [lctNew, lctDelete] then
  begin
    ProcessAfterCreateDeleteLayerCommandDone;
  end;
end;

//-- TgmStandardLayerCommand ---------------------------------------------------

constructor TgmStandardLayerCommand.Create(const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType);
begin
  inherited Create(caNone, '');

  FLayerCommandType := ALayerCommandType;
  FTargetLayerIndex := ALayerIndex;

  case FLayerCommandType of
    lctNew:
      begin
        FCommandName := 'New Layer';
      end;
      
    lctDelete:
      begin
        FCommandName := 'Delete Layer';
      end;
  end;

  FOperateName := 'Undo ' + FCommandName;
  DuplicateData(ALayerPanel);
end; 

destructor TgmStandardLayerCommand.Destroy;
begin
  FLayerBitmap.Free;
  FLastAlphaChannelBmp.Free;
  FMask.Free;

  inherited Destroy;
end;

procedure TgmStandardLayerCommand.DuplicateData(const APanel: TgmLayerPanel);
begin
  FLayerBitmap := TBitmap32.Create;
  FLayerBitmap.Assign(APanel.AssociatedLayer.Bitmap);

  FLayerFeature      := APanel.LayerFeature;
  FLocation          := APanel.AssociatedLayer.Location;
  FBlendModeIndex    := APanel.BlendModeIndex;
  FLayerMasterAlpha  := APanel.LayerMasterAlpha;
  FDuplicated        := APanel.IsDuplicated;
  FLockTransparency  := APanel.IsLockTransparency;
  FHasMask           := APanel.IsHasMask;
  FMaskLinked        := APanel.IsMaskLinked;
  FLayerName         := APanel.LayerName.Caption;
  FLayerProcessStage := APanel.LayerProcessStage;
  FPrevProcessStage  := APanel.PrevProcessStage;

  if FHasMask then
  begin
    FLastAlphaChannelBmp := TBitmap32.Create;
    FLastAlphaChannelBmp.Assign(APanel.FLastAlphaChannelBmp);

    FMask := TBitmap32.Create;
    FMask.Assign(APanel.FMaskImage.Bitmap);
  end
  else
  begin
    FLastAlphaChannelBmp := nil;
    FMask                := nil;
  end;
end;

procedure TgmStandardLayerCommand.CreateLayerByData;
var
  LNewLayer: TBitmapLayer;
  LNewPanel: TgmLayerPanel;
begin
  LNewPanel := nil;

  if frmRichTextEditor.Visible then
  begin
    ActiveChildForm.CommitEdits;
  end;

  ActiveChildForm.DeleteRichTextHandleLayer;

  ActiveChildForm.imgDrawingArea.Layers.Insert(FTargetLayerIndex, TBitmapLayer);

  LNewLayer          := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[FTargetLayerIndex]);
  LNewLayer.Location := FLocation;
  LNewLayer.Scaled   := True;

  LNewLayer.Bitmap.Assign(FLayerBitmap);
  LNewLayer.Bitmap.MasterAlpha := 255;
  LNewLayer.Bitmap.DrawMode    := dmCustom;

  case FLayerFeature of
    lfBackground:
      begin
        LNewPanel := TgmBackgroundLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer);
      end;

    lfTransparent:
      begin
        LNewPanel := TgmTransparentLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer);
      end;
  end;

  LNewPanel.IsDuplicated       := FDuplicated;
  LNewPanel.BlendModeIndex     := FBlendModeIndex;
  LNewPanel.LayerMasterAlpha   := FLayerMasterAlpha;
  LNewPanel.IsLockTransparency := FLockTransparency;
  
{ Duplicate mask }
  LNewPanel.IsHasMask         := FHasMask;
  LNewPanel.IsMaskLinked      := FMaskLinked;
  LNewPanel.LayerProcessStage := FLayerProcessStage;
  LNewPanel.PrevProcessStage  := FPrevProcessStage;

  if LNewPanel.IsHasMask then
  begin
    LNewPanel.FLastAlphaChannelBmp.Assign(FLastAlphaChannelBmp);
    LNewPanel.FMaskImage.Bitmap.Assign(FMask);
    LNewPanel.UpdateMaskThumbnail;
    LNewPanel.ShowThumbnailByRightOrder;
  end;
  
  ActiveChildForm.LayerPanelList.InsertLayerPanelToList(FTargetLayerIndex, LNewPanel);

  LNewPanel.LayerName.Caption := FLayerName;
  LNewLayer.Changed;
  
  ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
end;

procedure TgmStandardLayerCommand.Rollback;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);

        if FLayerFeature = lfTransparent then
        begin
          ActiveChildForm.LayerPanelList.TransparentLayerNumber := ActiveChildForm.LayerPanelList.TransparentLayerNumber - 1;
        end;
      end;

    lctDelete:
      begin
        CreateLayerByData;
        
        if FLayerFeature = lfTransparent then
        begin
          ActiveChildForm.LayerPanelList.TransparentLayerNumber := ActiveChildForm.LayerPanelList.TransparentLayerNumber - 1;
        end;
      end;
  end;

  ProcessAfterCreateDeleteLayerCommandDone;
end;

procedure TgmStandardLayerCommand.Execute;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        CreateLayerByData;
      end;
      
    lctDelete:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
      end;
  end;

  ProcessAfterCreateDeleteLayerCommandDone;
end;

//-- TgmDuplicateLayerCommand --------------------------------------------------

constructor TgmDuplicateLayerCommand.Create(
  const ACurrentIndex, ADuplicatedIndex: Integer; const ALayerName: string);
begin
  inherited Create(caNone, 'Duplicate Layer');

  FTargetLayerIndex := ACurrentIndex;
  FDuplicatedIndex  := ADuplicatedIndex;
  FLayerName        := ALayerName;
  FOperateName      := 'Undo ' + FCommandName;
end;

procedure TgmDuplicateLayerCommand.Rollback;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
  ProcessAfterCreateDeleteLayerCommandDone;
end;

procedure TgmDuplicateLayerCommand.Execute;
var
  LLayerPanel     : TgmLayerPanel;
  LDuplicatedPanel: TgmLayerPanel;
begin
  FCommandState   := csUndo;
  FOperateName    := 'Undo ' + FCommandName;

  LLayerPanel := ActiveChildForm.LayerPanelList.Items[FDuplicatedIndex];

  LDuplicatedPanel := LLayerPanel.DuplicateCurrentLayerPanel(frmLayer.scrlbxLayers,
    ActiveChildForm.imgDrawingArea.Layers, FTargetLayerIndex, FLayerName);

  ActiveChildForm.LayerPanelList.InsertLayerPanelToList(FTargetLayerIndex, LDuplicatedPanel);
  ProcessAfterCreateDeleteLayerCommandDone;
end;

//-- TgmLayerPropertiesCommand -------------------------------------------------

constructor TgmLayerPropertiesCommand.Create(
  const ALayerOldName, ALayerNewName: string);
begin
  inherited Create(caNone, 'Layer Properties');

  FOperateName      := 'Undo ' + FCommandName;
  FTargetLayerIndex := ActiveChildForm.LayerPanelList.CurrentIndex;
  FOldName          := ALayerOldName;
  FNewName          := ALayerNewName;
end;

procedure TgmLayerPropertiesCommand.Rollback;
var
  LLayerPanel: TgmLayerPanel;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  LLayerPanel := ActiveChildForm.LayerPanelList.Items[FTargetLayerIndex];

  LLayerPanel.LayerName.Caption := FOldName;
end;

procedure TgmLayerPropertiesCommand.Execute;
var
  LLayerPanel: TgmLayerPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  LLayerPanel := ActiveChildForm.LayerPanelList.Items[FTargetLayerIndex];

  LLayerPanel.LayerName.Caption := FNewName;
end;

//-- TgmArrangeLayerCommand ------------------------------------------------------

constructor TgmArrangeLayerCommand.Create(const AOldIndex, ANewIndex: Integer;
  const AStyle: TgmLayerArrangementStyle);
begin
  inherited Create(caNone, '');

  FArrangementStyle := AStyle;
  FCommandName      := GetCommandName;
  FOperateName      := 'Undo ' + FCommandName;
  FOldIndex         := AOldIndex;
  FNewIndex         := ANewIndex;
  FUndoIndex        := ANewIndex;
  FRedoIndex        := ANewIndex;
end;

function TgmArrangeLayerCommand.GetCommandName: string;
begin
  case FArrangementStyle of
    lasBringToFront:
      begin
        Result := 'Bring To Front';
      end;

    lasBringForward:
      begin
        Result := 'Bring Forward';
      end;
      
    lasSendBackward:
      begin
        Result := 'Send Backward';
      end;

    lasSendToBack:
      begin
        Result := 'Send To Back';
      end;
  end;
end;

procedure TgmArrangeLayerCommand.ProcessAfterArrangeCommandDone;
begin
  if Assigned(ActiveChildForm.LayerPanelList.SelectedLayerPanel) then
  begin
    ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;

    // update channel thumbnails
    ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);

    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
    begin
      ActiveChildForm.CreateShapeOutlineLayer;
      ActiveChildForm.DrawShapeOutline;
    end
    else
    begin
      ActiveChildForm.DeleteShapeOutlineLayer;
    end;

    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
    begin
      if frmMain.MainTool = gmtTextTool then
      begin
        ActiveChildForm.UpdateRichTextHandleLayer;
      end
      else
      begin
        ActiveChildForm.DeleteRichTextHandleLayer;
      end;
    end
    else
    begin
      ActiveChildForm.DeleteRichTextHandleLayer;
    end;

    frmLayer.tlbtnAddMask.Enabled := not ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask;
    frmLayer.scrlbxLayers.Update; // show the scroll bar correctly

    // update color window
    case ActiveChildForm.ChannelManager.CurrentChannelType of
      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          frmColor.ColorMode := cmRGB;
        end;
        
      wctAlpha, wctQuickMask, wctLayerMask:
        begin
          frmColor.ColorMode := cmGrayscale;
        end;
    end;
  end;
end;

procedure TgmArrangeLayerCommand.Rollback;
var
  LLayer: TBitmapLayer;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  FRedoIndex := ActiveChildForm.LayerPanelList.CurrentIndex;

  if FUndoIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FUndoIndex);
  end;

  if ActiveChildForm.LayerPanelList.IsAllowRefreshLayerPanels then
  begin
    ActiveChildForm.LayerPanelList.HideAllLayerPanels;
  end;

  LLayer       := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[FNewIndex]);
  LLayer.Index := FOldIndex;
  
  ActiveChildForm.LayerPanelList.Move(FNewIndex, FOldIndex);

  // without this line, Undo process will raise exception in some cases.
  ActiveChildForm.LayerPanelList.ActiveLayerPanel(FOldIndex);

  if ActiveChildForm.LayerPanelList.IsAllowRefreshLayerPanels then
  begin
    ActiveChildForm.LayerPanelList.ShowAllLayerPanels;
  end;

  ProcessAfterArrangeCommandDone;
end;

procedure TgmArrangeLayerCommand.Execute;
var
  LLayer: TBitmapLayer;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  FUndoIndex := ActiveChildForm.LayerPanelList.CurrentIndex;

  if FRedoIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FRedoIndex);
  end;

  if ActiveChildForm.LayerPanelList.IsAllowRefreshLayerPanels then
  begin
    ActiveChildForm.LayerPanelList.HideAllLayerPanels;
  end;
  
  LLayer       := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[FOldIndex]);
  LLayer.Index := FNewIndex;
  
  ActiveChildForm.LayerPanelList.Move(FOldIndex, FNewIndex);

  if ActiveChildForm.LayerPanelList.IsAllowRefreshLayerPanels then
  begin
    ActiveChildForm.LayerPanelList.ShowAllLayerPanels;
  end;

  ProcessAfterArrangeCommandDone;
end; 

//-- TgmLayerMaskCommand -------------------------------------------------------

constructor TgmLayerMaskCommand.Create(
  const AMaskCommandType: TgmMaskCommandType;
  const AOldSelection: TgmSelection);
var
  LCommandDir: string;
  LStream    : TMemoryStream;
begin
  inherited Create(caNone, '');

  FMaskCommandType  := AMaskCommandType;
  FCommandName      := GetCommandName;
  FOperateName      := 'Undo ' + FCommandName;
  FTargetLayerIndex := ActiveChildForm.LayerPanelList.CurrentIndex;
  FOldMaskLinked    := ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsMaskLinked;

  LCommandDir := ExtractFileDir(ParamStr(0)) + '\History';

  if not DirectoryExists(LCommandDir) then
  begin
    CreateDir(LCommandDir);
  end;

  if AMaskCommandType in [mctApplyLayerMask, mctDiscardLayerMask] then
  begin
    FOldLayerBmpFileName := LCommandDir + '\Undo' + IntToStr(GetTickCount);

    LStream := TMemoryStream.Create;
    try
      ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.SaveToStream(LStream);

      LStream.Position := 0;
      LStream.SaveToFile(FOldLayerBmpFileName);
    finally
      LStream.Clear;
      LStream.Free;
    end;

    { Note that, if the bitmap is already a grayscale bitmap, we just need
      to save the blue channels to disk, because it is fatest.

      When we load them back, we should load them with csGrayscale mode to
      get the original grayscale bitmap. }

    FAlphaChannelFileName := LCommandDir + '\AlphaChannel' + IntToStr(GetTickCount);

    SaveChannelsToFile(ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                       csBlue, FAlphaChannelFileName);

    FMaskFileName := LCommandDir + '\LayerMask' + IntToStr(GetTickCount);

    SaveChannelsToFile(ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                       csBlue, FMaskFileName);
  end
  else
  begin
    FAlphaChannelFileName := '';
    FMaskFileName         := '';
    FOldLayerBmpFileName  := '';
  end;

  if Assigned(AOldSelection) then
  begin
    FOldSelection := TgmSelection.Create;
    FOldSelection.AssignAllSelectionData(AOldSelection);
  end
  else
  begin
    FOldSelection := nil;
  end;
end;

destructor TgmLayerMaskCommand.Destroy;
begin
  if FAlphaChannelFileName <> '' then
  begin
    if FileExists(FAlphaChannelFileName) then
    begin
      DeleteFile(PChar(FAlphaChannelFileName));
    end;
  end;

  if FMaskFileName <> '' then
  begin
    if FileExists(FMaskFileName) then
    begin
      DeleteFile(PChar(FMaskFileName));
    end;
  end;

  if FOldLayerBmpFileName <> '' then
  begin
    if FileExists(FOldLayerBmpFileName) then
    begin
      DeleteFile(PChar(FOldLayerBmpFileName));
    end;
  end;

  FOldSelection.Free;

  inherited Destroy;
end; 

function TgmLayerMaskCommand.GetCommandName: string;
begin
  case FMaskCommandType of
    mctNone            : Result := '';
    mctAddLayerMask    : Result := 'Add Layer Mask';
    mctApplyLayerMask  : Result := 'Apply Layer Mask';
    mctDiscardLayerMask: Result := 'Discard Layer Mask';
  end;
end;

procedure TgmLayerMaskCommand.Rollback;
var
  LStream     : TMemoryStream;
  LOldLayerBmp: TBitmap32;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  if FTargetLayerIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
  end;
  
  case FMaskCommandType of
    mctAddLayerMask:
      begin
        ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerProcessStage := lpsLayer;
        ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask         := False;

        // delete layer mask channel
        if Assigned(ActiveChildForm.ChannelManager.LayerMaskPanel) then
        begin
          ActiveChildForm.ChannelManager.DeleteLayerMaskPanel;
        end;

        if Assigned(ActiveChildForm.Selection) then
        begin
          if Assigned(FOldSelection) then
          begin
            ActiveChildForm.Selection.AssignAllSelectionData(FOldSelection);
          end;
        end;
      end;

    mctApplyLayerMask,
    mctDiscardLayerMask:
      begin
        ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask    := True;
        ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsMaskLinked := FOldMaskLinked;

        // restore the last alpha channel record
        if LoadChannelsFromFile(ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                                csGrayscale, FAlphaChannelFileName) = False then
        begin
          MessageDlg(gmIO.GMIOErrorMsgOutput, mtError, [mbOK], 0);
        end;;

        // restore layer mask
        if LoadChannelsFromFile(ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                                csGrayscale, FMaskFileName) = False then
        begin
          MessageDlg(gmIO.GMIOErrorMsgOutput, mtError, [mbOK], 0);
        end;

        // process on channel manager...
        ActiveChildForm.ChannelManager.CreateLayerMaskPanel(
          frmChannel.scrlbxChannelPanelContainer,
          ActiveChildForm.imgDrawingArea.Layers,
          ActiveChildForm.LayerPanelList);

        ActiveChildForm.ChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(
          0, 0, ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
          
        ActiveChildForm.ChannelManager.LayerMaskPanel.UpdateThumbnail;

        // switch channel to layer mask
        ActiveChildForm.ChannelManager.SelectLayerMask;

        if FOldLayerBmpFileName <> '' then
        begin
          if FileExists(FOldLayerBmpFileName) then
          begin
            LStream      := TMemoryStream.Create;
            LOldLayerBmp := TBitmap32.Create;
            try
              LStream.LoadFromFile(FOldLayerBmpFileName);
              LStream.Position := 0;

              LOldLayerBmp.LoadFromStream(LStream);

              { Could not use assign() method, otherwise the draw mode of the
                layer will not be dmCustom any more. }
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Draw(0, 0, LOldLayerBmp);
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
            finally
              LStream.Clear;
              LStream.Free;
              LOldLayerBmp.Free;
            end;
          end;
        end;
      end;
  end;

  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
  begin
    TgmShapeRegionLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel).SetThumbnailPosition;
  end
  else
  begin
    ActiveChildForm.LayerPanelList.SelectedLayerPanel.ShowThumbnailByRightOrder;
  end;

  ActiveChildForm.LayerPanelList.UpdatePanelsState;

  ProcessAfterMaskCommandDone;
end;

procedure TgmLayerMaskCommand.Execute;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  if FTargetLayerIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
  end;
  
  case FMaskCommandType of
    mctAddLayerMask:
      begin
        ActiveChildForm.LayerPanelList.SelectedLayerPanel.AddMask;
      end;

    mctApplyLayerMask:
      begin
        if not ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsMaskLinked then
        begin
          // set this to True temporarily, otherwise, apply Mask operation
          // in Update() method will not work
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsMaskLinked := True;
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;
        end;

        ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerProcessStage := lpsLayer;
        ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask         := False;

        GetAlphaChannelBitmap(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                              ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);

        // delete layer mask channel
        if Assigned(ActiveChildForm.ChannelManager.LayerMaskPanel) then
        begin
          ActiveChildForm.ChannelManager.DeleteLayerMaskPanel;
        end;
      end;

    mctDiscardLayerMask:
      begin
        ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerProcessStage := lpsLayer;
        ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask         := False;

        // not in special layers...
        if not ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
        begin
          ReplaceAlphaChannelWithMask(
            ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
            ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);

          GetAlphaChannelBitmap(
            ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
            ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                                
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.LastProcessed.Assign(
            ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

          ActiveChildForm.LayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
        end;

        // delete layer mask channel
        if Assigned(ActiveChildForm.ChannelManager.LayerMaskPanel) then
        begin
          ActiveChildForm.ChannelManager.DeleteLayerMaskPanel;
        end;
      end;
  end;

  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
  begin
    TgmShapeRegionLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel).SetThumbnailPosition;
  end
  else
  begin
    ActiveChildForm.LayerPanelList.SelectedLayerPanel.ShowThumbnailByRightOrder;
  end;

  ActiveChildForm.LayerPanelList.UpdatePanelsState;

  if Assigned(ActiveChildForm.Selection) then
  begin
    ActiveChildForm.ChangeSelectionTarget;
  end;

  ProcessAfterMaskCommandDone;
end;

//-- TgmLinkMaskCommand --------------------------------------------------------

constructor TgmLinkMaskCommand.Create(const ALayerPanelIndex: Integer);
begin
  inherited Create(caNone, 'Link Mask');

  FOperateName      := 'Undo ' + FCommandName;
  FTargetLayerIndex := ALayerPanelIndex;
end;

procedure TgmLinkMaskCommand.Rollback;
var
  LLayerPanel: TgmLayerPanel;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  LLayerPanel := ActiveChildForm.LayerPanelList.GetLayerPanelByIndex(FTargetLayerIndex);

  if Assigned(LLayerPanel) then
  begin
    LLayerPanel.IsMaskLinked := False;

    if not LLayerPanel.IsHoldMaskInLayerAlpha then
    begin
      ReplaceAlphaChannelWithMask(LLayerPanel.AssociatedLayer.Bitmap,
                                  LLayerPanel.FLastAlphaChannelBmp);

      LLayerPanel.AssociatedLayer.Changed;
    end
    else
    begin
      LLayerPanel.AssociatedLayer.Changed;
    end;

    ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
  end;
end;

procedure TgmLinkMaskCommand.Execute;
var
  LLayerPanel: TgmLayerPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  LLayerPanel := ActiveChildForm.LayerPanelList.GetLayerPanelByIndex(FTargetLayerIndex);

  if Assigned(LLayerPanel) then
  begin
    LLayerPanel.IsMaskLinked := True;

    if not LLayerPanel.IsHoldMaskInLayerAlpha then
    begin
      ChangeAlphaChannelBySubMask(LLayerPanel.AssociatedLayer.Bitmap,
                                  LLayerPanel.FLastAlphaChannelBmp,
                                  LLayerPanel.FMaskImage.Bitmap);

      LLayerPanel.AssociatedLayer.Changed;
    end
    else
    begin
      LLayerPanel.AssociatedLayer.Changed;
    end;

    ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
  end;
end;

//-- TgmUnlinkMaskCommand ------------------------------------------------------

constructor TgmUnlinkMaskCommand.Create(const ALayerPanelIndex: Integer);
begin
  inherited Create(caNone, 'Unlink Mask');

  FOperateName      := 'Undo ' + FCommandName;
  FTargetLayerIndex := ALayerPanelIndex;
end;

procedure TgmUnlinkMaskCommand.Rollback;
var
  LLayerPanel: TgmLayerPanel;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  LLayerPanel := ActiveChildForm.LayerPanelList.GetLayerPanelByIndex(FTargetLayerIndex);

  if Assigned(LLayerPanel) then
  begin
    LLayerPanel.IsMaskLinked := True;
    
    if not LLayerPanel.IsHoldMaskInLayerAlpha then
    begin
      ChangeAlphaChannelBySubMask(LLayerPanel.AssociatedLayer.Bitmap,
                                  LLayerPanel.FLastAlphaChannelBmp,
                                  LLayerPanel.FMaskImage.Bitmap);

      LLayerPanel.AssociatedLayer.Changed;
    end
    else
    begin
      LLayerPanel.AssociatedLayer.Changed;
    end;

    ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
  end;
end; 

procedure TgmUnlinkMaskCommand.Execute;
var
  LLayerPanel: TgmLayerPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  LLayerPanel := ActiveChildForm.LayerPanelList.GetLayerPanelByIndex(FTargetLayerIndex);

  if Assigned(LLayerPanel) then
  begin
    LLayerPanel.IsMaskLinked := False;

    if not LLayerPanel.IsHoldMaskInLayerAlpha then
    begin
      ReplaceAlphaChannelWithMask(LLayerPanel.AssociatedLayer.Bitmap,
                                  LLayerPanel.FLastAlphaChannelBmp);

      LLayerPanel.AssociatedLayer.Changed;
    end
    else
    begin
      LLayerPanel.AssociatedLayer.Changed;
    end;

    ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
  end;
end;

//-- TgmShapeRegionLayerCommand ------------------------------------------------

constructor TgmShapeRegionLayerCommand.Create(const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel;
  const ARegionCommandType: TgmRegionCommandType;
  const AOutline: TgmShapeOutline = nil);
var
  LShapeRegionLayerPanel: TgmShapeRegionLayerPanel;
begin
  inherited Create(caNone, '');

  FTargetLayerIndex  := ALayerIndex;
  FRedoIndex         := ALayerIndex;
  FRegionCommandType := ARegionCommandType;
  FLayerName         := ALayerPanel.LayerName.Caption;

  FOldOutline  := CopyShapeOutline(AOutline);
  FCommandName := GetCommandName;
  FOperateName := 'Undo ' + FCommandName;

  LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(ALayerPanel);

  with LShapeRegionLayerPanel do
  begin
    FRegionColor    := RegionColor;
    FBrushStyle     := BrushStyle;
    FDismissed      := IsDismissed;
    FDuplicated     := IsDuplicated;
  end;

  if FRegionCommandType = rctDeleteRegionLayer then
  begin
    FDuplicatedOutlineList := TgmOutlineList.Create;
    FDuplicatedOutlineList.DuplicateOutlineList(LShapeRegionLayerPanel.ShapeOutlineList);

    FLayerLockTransparency := ALayerPanel.IsLockTransparency;
    FLayerBlendModeIndex   := ALayerPanel.BlendModeIndex;
    FLayerOpacity          := ALayerPanel.LayerMasterAlpha;
  end
  else
  begin
    FDuplicatedOutlineList := nil;
  end;
end;

destructor TgmShapeRegionLayerCommand.Destroy;
begin
  FOldOutline.Free;
  FDuplicatedOutlineList.Free;
  
  inherited Destroy;
end;

function TgmShapeRegionLayerCommand.GetCommandName: string;
begin
  Result := '';

  case FRegionCommandType of
    rctCreateRegionLayer,
    rctAddRegion:
      begin
        if Assigned(FOldOutline) then
        begin
          case FOldOutline.ShapeRegionTool of
            srtRectangle  : Result := 'Rectangle Tool';
            srtRoundedRect: Result := 'Rounded-Corner Rectangle Tool';
            srtEllipse    : Result := 'Ellipse Tool';
            srtPolygon    : Result := 'Regular Polygon Tool';
            srtLine       : Result := 'Line Tool';
          end;
        end;
      end;

    rctDeleteRegionLayer: Result := 'Delete Layer';
  end;
end;

procedure TgmShapeRegionLayerCommand.Rollback;
var
  LShapeRegionLayerPanel : TgmShapeRegionLayerPanel;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  case FRegionCommandType of
    rctCreateRegionLayer:
      begin
        with ActiveChildForm.LayerPanelList do
        begin
          DeleteLayerPanelByIndex(FTargetLayerIndex);
          ActiveLayerPanel(FTargetLayerIndex - 1);
          ShapeRegionLayerNumber := ShapeRegionLayerNumber - 1;
        end;
      end;

    rctAddRegion:
      begin
        FRedoIndex := ActiveChildForm.LayerPanelList.CurrentIndex;

        if FTargetLayerIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
        begin
          ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
        end;

        if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
        begin
          LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

          with LShapeRegionLayerPanel do
          begin
            ShapeOutlineList.DeleteOutlineByIndex(ShapeOutlineList.Count - 1);
            ShapeRegion.AccumRGN := ShapeOutlineList.GetScaledShapesRegion;
            ShapeRegion.ShowRegion(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
            UpdateRegionThumbnial;
            ShapeOutlineList.GetShapesBoundary;
          end;

          GetAlphaChannelBitmap(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                                ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);

          ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;
        end;
      end;

    rctDeleteRegionLayer:
      begin
        FRedoIndex := ActiveChildForm.LayerPanelList.CurrentIndex;

        ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex - 1);
        ActiveChildForm.CreateShapeRegionLayer;
        ActiveChildForm.LayerPanelList.ShapeRegionLayerNumber := ActiveChildForm.LayerPanelList.ShapeRegionLayerNumber - 1;

        ActiveChildForm.LayerPanelList.SelectedLayerPanel.BlendModeIndex     := FLayerBlendModeIndex;
        ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerMasterAlpha   := FLayerOpacity;
        ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsLockTransparency := FLayerLockTransparency;

        frmLayer.cmbbxLayerBlendMode.ItemIndex  := FLayerBlendModeIndex;
        frmLayer.ggbrLayerOpacity.Position      := FLayerOpacity;
        frmLayer.chckbxLockTransparency.Checked := FLayerLockTransparency;

        if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
        begin
          LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

          with LShapeRegionLayerPanel do
          begin
            LayerName.Caption := FLayerName;
            IsDuplicated      := FDuplicated;
            IsDismissed       := FDismissed;
            RegionColor       := FRegionColor;
            BrushStyle        := FBrushStyle;

            if Assigned(FDuplicatedOutlineList) then
            begin
              ShapeOutlineList.DuplicateOutlineList(FDuplicatedOutlineList);
              ShapeRegion.AccumRGN := ShapeOutlineList.GetScaledShapesRegion;
              ShapeRegion.ShowRegion(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
            end;

            UpdateRegionThumbnial;
          end;

          GetAlphaChannelBitmap(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                                ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
        end;
      end;
  end;

  ProcessAfterShapeRegionCommandDone;
end; 

procedure TgmShapeRegionLayerCommand.Execute;
var
  LShapeRegionLayerPanel : TgmShapeRegionLayerPanel;
  LOutline               : TgmShapeOutline;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  case FRegionCommandType of
    rctCreateRegionLayer:
      begin
        ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex - 1);
        ActiveChildForm.CreateShapeRegionLayer;
      end;

    rctAddRegion:
      begin
        if FTargetLayerIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
        begin
          ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
        end;
      end;

    rctDeleteRegionLayer:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
        ActiveChildForm.LayerPanelList.ActiveLayerPanel(FRedoIndex);
      end;
  end;

  if FRegionCommandType in [rctCreateRegionLayer, rctAddRegion] then
  begin
    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
    begin
      LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);
      LOutline               := CopyShapeOutline(FOldOutline);

      with LShapeRegionLayerPanel do
      begin
        if Assigned(LOutline) then
        begin
          ShapeOutlineList.Add(LOutline);
          ShapeOutlineList.GetShapesBoundary;
        end;

        IsDismissed          := FDismissed;
        ShapeRegion.AccumRGN := ShapeOutlineList.GetScaledShapesRegion;
        ShapeRegion.ShowRegion(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

        RegionColor := FRegionColor;
        BrushStyle  := FBrushStyle;
        UpdateRegionThumbnial;

        GetAlphaChannelBitmap(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                              ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);

        Update;
      end;

      if FRegionCommandType = rctAddRegion then
      begin
        if FRedoIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
        begin
          ActiveChildForm.LayerPanelList.ActiveLayerPanel(FRedoIndex);
        end;
      end;
    end;
  end;

  ProcessAfterShapeRegionCommandDone;
end;

//-- TgmModifyShapeRegionColorCommand ------------------------------------------

constructor TgmModifyShapeRegionColorCommand.Create(
  const AOldColor, ANewColor: TColor);
begin
  inherited Create(caNone, 'Modify Shape Region Color');

  FOperateName := 'Undo ' + FCommandName;
  FOldColor    := AOldColor;
  FNewColor    := ANewColor;
  FRedoIndex   := ActiveChildForm.LayerPanelList.CurrentIndex;
end;

procedure TgmModifyShapeRegionColorCommand.Rollback;
var
  LShapeRegionLayerPanel: TgmShapeRegionLayerPanel;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  FRedoIndex := ActiveChildForm.LayerPanelList.CurrentIndex;

  if FTargetLayerIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
  end;

  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
  begin
    LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);
    LShapeRegionLayerPanel.RegionColor := FOldColor;
  end;

  ProcessAfterShapeRegionCommandDone;
end;

procedure TgmModifyShapeRegionColorCommand.Execute;
var
  LShapeRegionLayerPanel: TgmShapeRegionLayerPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  if FTargetLayerIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
  end;

  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
  begin
    LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);
    LShapeRegionLayerPanel.RegionColor := FNewColor;
  end;

  if FRedoIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FRedoIndex);
  end;

  ProcessAfterShapeRegionCommandDone;
end;

//-- TgmModifyShapeRegionStyleCommand ------------------------------------------

constructor TgmModifyShapeRegionStyleCommand.Create(
  const AOldStyle, ANewStyle: TBrushStyle);
begin
  inherited Create(caNone, 'Modify Shape Region Filling Style');

  FOperateName := 'Undo ' + FCommandName;
  FOldStyle    := AOldStyle;
  FNewStyle    := ANewStyle;
  FRedoIndex   := ActiveChildForm.LayerPanelList.CurrentIndex;
end;

procedure TgmModifyShapeRegionStyleCommand.Rollback;
var
  LShapeRegionLayerPanel: TgmShapeRegionLayerPanel;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  FRedoIndex := ActiveChildForm.LayerPanelList.CurrentIndex;

  if FTargetLayerIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
  end;

  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
  begin
    LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);
    LShapeRegionLayerPanel.BrushStyle := FOldStyle;
  end;

  ProcessAfterShapeRegionCommandDone;
end;

procedure TgmModifyShapeRegionStyleCommand.Execute;
var
  LShapeRegionLayerPanel: TgmShapeRegionLayerPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  if FTargetLayerIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
  end;

  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
  begin
    LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);
    LShapeRegionLayerPanel.BrushStyle := FNewStyle;
  end;

  if FRedoIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FRedoIndex);
  end;

  ProcessAfterShapeRegionCommandDone;
end;

//-- TgmTranslateShapeRegionCommand --------------------------------------------

constructor TgmTranslateShapeRegionCommand.Create(
  const AAccumTranslatedVector: TPoint);
begin
  inherited Create(caNone, 'Move Shape Region');

  FOperateName           := 'Undo ' + FCommandName;
  FRedoIndex             := ActiveChildForm.LayerPanelList.CurrentIndex;
  FAccumTranslatedVector := AAccumTranslatedVector;
end;

procedure TgmTranslateShapeRegionCommand.Rollback;
var
  LShapeRegionLayerPanel : TgmShapeRegionLayerPanel;
  LUndoTranslateVector   : TPoint;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  FRedoIndex := ActiveChildForm.LayerPanelList.CurrentIndex;

  if FTargetLayerIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
  end;

  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
  begin
    LUndoTranslateVector.X := -FAccumTranslatedVector.X;
    LUndoTranslateVector.Y := -FAccumTranslatedVector.Y;

    LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

    with LShapeRegionLayerPanel do
    begin
      ShapeOutlineList.Translate(LUndoTranslateVector);
      ShapeRegion.Translate(LUndoTranslateVector);
      ShapeRegion.ShowRegion(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
      UpdateRegionThumbnial;
    end;

    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask then
    begin
      GetAlphaChannelBitmap(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                            ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
    end;

    ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;
  end;

  ProcessAfterShapeRegionCommandDone;
end; 

procedure TgmTranslateShapeRegionCommand.Execute;
var
  LShapeRegionLayerPanel: TgmShapeRegionLayerPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  if FTargetLayerIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
  end;

  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
  begin
    LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

    with LShapeRegionLayerPanel do
    begin
      ShapeOutlineList.Translate(FAccumTranslatedVector);
      ShapeRegion.Translate(FAccumTranslatedVector);
      ShapeRegion.ShowRegion(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
      UpdateRegionThumbnial;
    end;
    
    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask then
    begin
      GetAlphaChannelBitmap(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                            ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
    end;

    ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;
  end;

  if FRedoIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FRedoIndex);
  end;

  ProcessAfterShapeRegionCommandDone;
end; 

//-- TgmScaleShapeRegionCommand ------------------------------------------------

constructor TgmScaleShapeRegionCommand.Create(
  const AOldTopLeft, AOldBottomRight, ANewTopLeft, ANewBottomRight: TPoint);
begin
  inherited Create(caNone, 'Scale Shape Region');

  FOperateName    := 'Undo ' + FCommandName;
  FRedoIndex      := ActiveChildForm.LayerPanelList.CurrentIndex;
  FOldTopLeft     := AOldTopLeft;
  FOldBottomRight := AOldBottomRight;
  FNewTopLeft     := ANewTopLeft;
  FNewBottomRight := ANewBottomRight;
end;

procedure TgmScaleShapeRegionCommand.Rollback;
var
  LShapeRegionLayerPanel : TgmShapeRegionLayerPanel;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  FRedoIndex := ActiveChildForm.LayerPanelList.CurrentIndex;

  if FTargetLayerIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
  end;

  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
  begin
    LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

    with LShapeRegionLayerPanel do
    begin
      ShapeOutlineList.FBoundaryTL := FOldTopLeft;
      ShapeOutlineList.FBoundaryBR := FOldBottomRight;
      ShapeOutlineList.ScaleShapesCoordinates;
      ShapeRegion.AccumRGN := ShapeOutlineList.GetScaledShapesRegion;
      ShapeRegion.ShowRegion(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
      UpdateRegionThumbnial;
    end;

    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask then
    begin
      GetAlphaChannelBitmap(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                            ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
    end;
    
    ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;
  end;

  ProcessAfterShapeRegionCommandDone;
end; 

procedure TgmScaleShapeRegionCommand.Execute;
var
  LShapeRegionLayerPanel : TgmShapeRegionLayerPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  if FTargetLayerIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
  end;

  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
  begin
    LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

    with LShapeRegionLayerPanel do
    begin
      ShapeOutlineList.BackupCoordinates;
      ShapeOutlineList.FBoundaryTL := FNewTopLeft;
      ShapeOutlineList.FBoundaryBR := FNewBottomRight;
      ShapeOutlineList.ScaleShapesCoordinates;
      ShapeRegion.AccumRGN := ShapeOutlineList.GetScaledShapesRegion;
      ShapeRegion.ShowRegion(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
      UpdateRegionThumbnial;
    end;

    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask then
    begin
      GetAlphaChannelBitmap(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                            ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
    end;

    ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;
  end;

  if FRedoIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FRedoIndex);
  end;

  ProcessAfterShapeRegionCommandDone;
end;

//-- TgmFigureLayerCommand -----------------------------------------------------

constructor TgmFigureLayerCommand.Create(const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType;
  const AFigureFlag: TgmFigureFlags = ffNone);
var
  LFigureLayerPanel: TgmFigureLayerPanel;
begin
  inherited Create(caNone, '');

  FTargetLayerIndex  := ALayerIndex;
  FRedoIndex         := ALayerIndex;
  FLayerCommandType  := ALayerCommandType;
  FFigureFlag        := AFigureFlag;
  FLayerName         := ALayerPanel.LayerName.Caption;
  FCommandName       := GetCommandName;
  FOperateName       := 'Undo ' + FCommandName;
  FDuplicated        := ALayerPanel.IsDuplicated;
  FHasMask           := ALayerPanel.IsHasMask;
  FMaskLinked        := ALayerPanel.IsMaskLinked;
  FLayerProcessStage := ALayerPanel.LayerProcessStage;
  FPrevProcessStage  := ALayerPanel.PrevProcessStage;

  LFigureLayerPanel := TgmFigureLayerPanel(ALayerPanel);

  FOldLockFigureBmp := TBitmap32.Create;
  FOldLockFigureBmp.Assign(LFigureLayerPanel.LockFigureBmp);
  FOldLockFigureBmp.DrawMode := dmBlend;

  FOldFigureList := TgmFigureList.Create;
  FOldFigureList.DuplicateFigureList(LFigureLayerPanel.FigureList);

  if ALayerCommandType = lctDelete then
  begin
    FLayerLockTransparency := ALayerPanel.IsLockTransparency;
    FLayerBlendModeIndex   := ALayerPanel.BlendModeIndex;
    FLayerOpacity          := ALayerPanel.LayerMasterAlpha;
  end;

  if FHasMask then
  begin
    FLastAlphaChannelBmp := TBitmap32.Create;
    FLastAlphaChannelBmp.Assign(ALayerPanel.FLastAlphaChannelBmp);

    FMask := TBitmap32.Create;
    FMask.Assign(ALayerPanel.FMaskImage.Bitmap);
  end
  else
  begin
    FLastAlphaChannelBmp := nil;
    FMask                := nil;
  end;
end;

destructor TgmFigureLayerCommand.Destroy;
begin
  FOldLockFigureBmp.Free;
  FOldFigureList.Free;
  FLastAlphaChannelBmp.Free;
  FMask.Free;
  
  inherited Destroy;
end;

function TgmFigureLayerCommand.GetCommandName: string;
begin
  case FLayerCommandType of
    lctNew:
      begin
        case FFigureFlag of
          ffStraightLine:
            begin
              Result := 'Straight Line';
            end;
            
          ffCurve:
            begin
              Result := 'Bezier Curve';
            end;
            
          ffPolygon:
            begin
              Result := 'Polygon';
            end;
            
          ffRegularPolygon:
            begin
              Result := 'Regular Polygon';
            end;

          ffRectangle:
            begin
              Result := 'Rectangle';
            end;
            
          ffSquare:
            begin
              Result := 'Square';
            end;

          ffRoundRectangle:
            begin
              Result := 'Rounded-Corner Rectangle';
            end;
            
          ffRoundSquare:
            begin
              Result := 'Rounded-Corner Square';
            end;
            
          ffEllipse:
            begin
              Result := 'Ellipse';
            end;
            
          ffCircle:
            begin
              Result := 'Circle';
            end;
            
          ffNone:
            begin
              Result := '';
            end;
        end;
      end;

    lctDelete:
      begin
        Result := 'Delete Layer';
      end;
  end;
end;

procedure TgmFigureLayerCommand.CreateOldFigureLayer;
var
  LFigureLayerPanel    : TgmFigureLayerPanel;
  LNewLayer, LBackLayer: TBitmapLayer;
  LLayerPanel          : TgmLayerPanel;
begin
  ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex - 1);

  // create layer
  LBackLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[0]);

  ActiveChildForm.imgDrawingArea.Layers.Insert(FTargetLayerIndex, TBitmapLayer);

  LNewLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[FTargetLayerIndex]);

  LNewLayer.Bitmap.Width  := LBackLayer.Bitmap.Width;
  LNewLayer.Bitmap.Height := LBackLayer.Bitmap.Height;
  LNewLayer.Bitmap.FillRectS(LNewLayer.Bitmap.Canvas.ClipRect, $00FFFFFF);

  LNewLayer.Location := LBackLayer.Location;
  LNewLayer.Scaled   := True;

  // Create panel
  LLayerPanel                    := TgmFigureLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer);
  LLayerPanel.IsDuplicated       := FDuplicated;
  LLayerPanel.BlendModeIndex     := FLayerBlendModeIndex;
  LLayerPanel.LayerMasterAlpha   := FLayerOpacity;
  LLayerPanel.IsLockTransparency := FLayerLockTransparency;

  { Duplicate mask }
  LLayerPanel.IsHasMask         := FHasMask;
  LLayerPanel.IsMaskLinked      := FMaskLinked;
  LLayerPanel.LayerProcessStage := FLayerProcessStage;
  LLayerPanel.PrevProcessStage  := FPrevProcessStage;

  if LLayerPanel.IsHasMask then
  begin
    LLayerPanel.FLastAlphaChannelBmp.Assign(FLastAlphaChannelBmp);
    LLayerPanel.FMaskImage.Bitmap.Assign(FMask);
    LLayerPanel.UpdateMaskThumbnail;
    LLayerPanel.ShowThumbnailByRightOrder;
  end;

  // add new layer panel to list
  ActiveChildForm.LayerPanelList.InsertLayerPanelToList(FTargetLayerIndex, LLayerPanel);
  LLayerPanel.SetLayerName(FLayerName);

  // update the layer panel container for correctly appear the scroll bars
  frmLayer.scrlbxLayers.Update;

  // get old figure list data
  LFigureLayerPanel := TgmFigureLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

  LFigureLayerPanel.FigureList.DuplicateFigureList(FOldFigureList);
  LFigureLayerPanel.LockFigureBmp.Assign(FOldLockFigureBmp);

  LFigureLayerPanel.DrawAllFigures(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                                  $00FFFFFF, pmCopy, fdmRGB);

  LFigureLayerPanel.DrawAllFigures(LFigureLayerPanel.ProcessedPart, clBlack32, pmCopy, fdmMask);

  MakeCanvasProcessedOpaque(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                            LFigureLayerPanel.ProcessedPart);

  if LFigureLayerPanel.IsHasMask then
  begin
    GetAlphaChannelBitmap(
      ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
      ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
  end;

  LFigureLayerPanel.UpdateLayerThumbnail;
end;

procedure TgmFigureLayerCommand.Rollback;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        with ActiveChildForm.LayerPanelList do
        begin
          DeselectAllFiguresOnFigureLayer;
          DeleteLayerPanelByIndex(FTargetLayerIndex);
          ActiveLayerPanel(FTargetLayerIndex - 1);
        end;
      end;

    lctDelete:
      begin
        FRedoIndex := ActiveChildForm.LayerPanelList.CurrentIndex;
        CreateOldFigureLayer;
        frmLayer.cmbbxLayerBlendMode.ItemIndex  := FLayerBlendModeIndex;
        frmLayer.ggbrLayerOpacity.Position      := FLayerOpacity;
        frmLayer.chckbxLockTransparency.Checked := FLayerLockTransparency;
      end;
  end;

  ActiveChildForm.LayerPanelList.FigureLayerNumber := ActiveChildForm.LayerPanelList.FigureLayerNumber - 1;
  ProcessAfterFigureCommandDone;
end; 

procedure TgmFigureLayerCommand.Execute;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        CreateOldFigureLayer;
      end;

    lctDelete:
      begin
        with ActiveChildForm.LayerPanelList do
        begin
          DeleteLayerPanelByIndex(FTargetLayerIndex);
          ActiveLayerPanel(FRedoIndex);
        end;
      end;
  end;
  
  ProcessAfterFigureCommandDone;
end;

//-- TgmAddFigureCommand -------------------------------------------------------

constructor TgmAddFigureCommand.Create(const AFigureObj: TgmFigureObject);
begin
  inherited Create(caNone, '');

  FFigureFlag  := AFigureObj.Flag;
  FCommandName := GetFigureName(FFigureFlag);
  FOperateName := 'Undo ' + FCommandName;
  FAddedFigure := AFigureObj.GetSelfBackup;
end;

destructor TgmAddFigureCommand.Destroy;
begin
  FAddedFigure.Free;
  
  inherited Destroy;
end;

procedure TgmAddFigureCommand.ChangeFigureNumber(const AChangedAmount: Integer);
var
  LFigureLayerPanel: TgmFigureLayerPanel;
begin
  LFigureLayerPanel := TgmFigureLayerPanel(ActiveChildForm.LayerPanelList.Items[FTargetLayerIndex]);
  
  with LFigureLayerPanel.FigureList do
  begin
    case FFigureFlag of
      ffStraightLine:
        begin
          LineNumber := LineNumber + AChangedAmount;
        end;
        
      ffCurve:
        begin
          CurveNumber := CurveNumber + AChangedAmount;
        end;
        
      ffPolygon:
        begin
          PolygonNumber := PolygonNumber + AChangedAmount;
        end;
        
      ffRegularPolygon:
        begin
          RegularPolygonNumber := RegularPolygonNumber + AChangedAmount;
        end;
        
      ffRectangle:
        begin
          RectangleNumber := RectangleNumber + AChangedAmount;
        end;
        
      ffSquare:
        begin
          SquareNumber := SquareNumber + AChangedAmount;
        end;
        
      ffRoundRectangle:
        begin
          RoundRectangleNumber := RoundRectangleNumber + AChangedAmount;
        end;
        
      ffRoundSquare:
        begin
          RoundSquareNumber := RoundSquareNumber + AChangedAmount;
        end;
        
      ffEllipse:
        begin
          EllipseNumber := EllipseNumber + AChangedAmount;
        end;
        
      ffCircle:
        begin
          CircleNumber := CircleNumber + AChangedAmount;
        end;
    end;
  end;
end;

procedure TgmAddFigureCommand.Rollback;
var
  LFigureLayerPanel : TgmFigureLayerPanel;
  LLayerPanel       : TgmLayerPanel;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  LLayerPanel := ActiveChildForm.LayerPanelList.GetLayerPanelByIndex(FTargetLayerIndex);

  if Assigned(LLayerPanel) then
  begin
    LFigureLayerPanel := TgmFigureLayerPanel(LLayerPanel);
    LFigureLayerPanel.FigureList.DeleteFigureByIndex(LFigureLayerPanel.FigureList.Count - 1);
    ChangeFigureNumber(-1);

    LFigureLayerPanel.DrawAllFigures(LLayerPanel.AssociatedLayer.Bitmap, $00FFFFFF, pmCopy, fdmRGB);
    LFigureLayerPanel.DrawAllFigures(LFigureLayerPanel.ProcessedPart, clBlack32, pmCopy, fdmMask);
    MakeCanvasProcessedOpaque(LLayerPanel.AssociatedLayer.Bitmap, LFigureLayerPanel.ProcessedPart);

    if LLayerPanel.IsHasMask then
    begin
      GetAlphaChannelBitmap(LLayerPanel.AssociatedLayer.Bitmap, LLayerPanel.FLastAlphaChannelBmp);
      ActiveChildForm.ApplyMaskByIndex(FTargetLayerIndex);
    end
    else
    begin
      LLayerPanel.AssociatedLayer.Changed;
    end;

    // update thumbnails
    LLayerPanel.UpdateLayerThumbnail;
    ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);

    ProcessAfterFigureCommandDone;
  end;
end; 

procedure TgmAddFigureCommand.Execute;
var
  LFigureLayerPanel : TgmFigureLayerPanel;
  LFigureObj        : TgmFigureObject;
  LLayerPanel       : TgmLayerPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  LLayerPanel := ActiveChildForm.LayerPanelList.GetLayerPanelByIndex(FTargetLayerIndex);

  if Assigned(LLayerPanel) then
  begin
    LFigureObj        := FAddedFigure.GetSelfBackup;
    LFigureLayerPanel := TgmFigureLayerPanel(LLayerPanel);

    LFigureLayerPanel.FigureList.Add(LFigureObj);
    ChangeFigureNumber(1);

    LFigureLayerPanel.DrawAllFigures(LLayerPanel.AssociatedLayer.Bitmap, $00FFFFFF, pmCopy, fdmRGB);
    LFigureLayerPanel.DrawAllFigures(LFigureLayerPanel.ProcessedPart, clBlack32, pmCopy, fdmMask);
    MakeCanvasProcessedOpaque(LLayerPanel.AssociatedLayer.Bitmap, LFigureLayerPanel.ProcessedPart);

    if LLayerPanel.IsHasMask then
    begin
      GetAlphaChannelBitmap(LLayerPanel.AssociatedLayer.Bitmap, LLayerPanel.FLastAlphaChannelBmp);
      ActiveChildForm.ApplyMaskByIndex(FTargetLayerIndex);
    end
    else
    begin
      LLayerPanel.AssociatedLayer.Changed;
    end;

    // update thumbnails
    LLayerPanel.UpdateLayerThumbnail;
    ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);

    ProcessAfterFigureCommandDone;
  end;
end; 

//-- TgmSelectFigureCommand ----------------------------------------------------

constructor TgmSelectFigureCommand.Create(
  const AOldSelectedFigureInfoArray: array of TgmFigureInfo;
  const ANewSelectedFigureInfoArray: array of TgmFigureInfo;
  const AOldSelectedFigureLayerIndexArray: array of Integer;
  const ANewSelectedFigureLayerIndexArray: array of Integer;
  const AMode: TgmSelectFigureMode);
var
  i, ElementCount: Integer;
begin
  inherited Create(caNone, '');

  FSelectMode := AMode;

  case FSelectMode of
    sfmSelect:
      begin
        FCommandName := 'Select Figures';
      end;
      
    sfmDeselect:
      begin
        FCommandName := 'Deselect Figures';
      end;
  end;

  FOperateName := 'Undo ' + FCommandName;

  ElementCount := High(AOldSelectedFigureInfoArray) + 1;
  if ElementCount > 0 then
  begin
    SetLength(FOldSelectedFigureInfoArray, ElementCount);

    for i := 0 to ElementCount - 1 do
    begin
      FOldSelectedFigureInfoArray[i].LayerIndex  := AOldSelectedFigureInfoArray[i].LayerIndex;
      FOldSelectedFigureInfoArray[i].FigureIndex := AOldSelectedFigureInfoArray[i].FigureIndex;
    end;
  end
  else
  begin
    FOldSelectedFigureInfoArray := nil;
  end;

  ElementCount := High(ANewSelectedFigureInfoArray) + 1;
  if ElementCount > 0 then
  begin
    SetLength(FNewSelectedFigureInfoArray, ElementCount);

    for i := 0 to ElementCount - 1 do
    begin
      FNewSelectedFigureInfoArray[i].LayerIndex  := ANewSelectedFigureInfoArray[i].LayerIndex;
      FNewSelectedFigureInfoArray[i].FigureIndex := ANewSelectedFigureInfoArray[i].FigureIndex;
    end;
  end
  else
  begin
    FNewSelectedFigureInfoArray := nil;
  end;

  ElementCount := High(AOldSelectedFigureLayerIndexArray) + 1;
  if ElementCount > 0 then
  begin
    SetLength(FOldSelectedFigureLayerIndexArray, ElementCount);

    for i := 0 to ElementCount - 1 do
    begin
      FOldSelectedFigureLayerIndexArray[i] := AOldSelectedFigureLayerIndexArray[i];
    end;
  end
  else
  begin
    FOldSelectedFigureLayerIndexArray := nil;
  end;

  ElementCount := High(ANewSelectedFigureLayerIndexArray) + 1;
  if ElementCount > 0 then
  begin
    SetLength(FNewSelectedFigureLayerIndexArray, ElementCount);
    
    for i := 0 to ElementCount - 1 do
    begin
      FNewSelectedFigureLayerIndexArray[i] := ANewSelectedFigureLayerIndexArray[i];
    end;
  end
  else
  begin
    FNewSelectedFigureLayerIndexArray := nil;
  end;
end; 

destructor TgmSelectFigureCommand.Destroy;
begin
  if High(FOldSelectedFigureInfoArray) >= 0 then
  begin
    SetLength(FOldSelectedFigureInfoArray, 0);
    FOldSelectedFigureInfoArray := nil;
  end;

  if High(FNewSelectedFigureInfoArray) >= 0 then
  begin
    SetLength(FNewSelectedFigureInfoArray, 0);
    FNewSelectedFigureInfoArray := nil;
  end;

  if High(FOldSelectedFigureLayerIndexArray) >= 0 then
  begin
    SetLength(FOldSelectedFigureLayerIndexArray, 0);
    FOldSelectedFigureLayerIndexArray := nil;
  end;

  if High(FNewSelectedFigureLayerIndexArray) >= 0 then
  begin
    SetLength(FNewSelectedFigureLayerIndexArray, 0);
    FNewSelectedFigureLayerIndexArray := nil;
  end;

  inherited Destroy;
end;

procedure TgmSelectFigureCommand.Rollback;
var
  i            : Integer;
  LElementCount: Integer;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  if frmMain.MainTool <> gmtStandard then
  begin
    frmMain.ChangeMainToolClick(frmMain.spdbtnStandardTools);
    frmMain.spdbtnStandardTools.Down := True;
  end;

  if frmMain.StandardTool <> gstMoveObjects then
  begin
    frmMain.ChangeStandardTools(frmMain.spdbtnMoveObjects);
    frmMain.spdbtnMoveObjects.Down := True;
  end;

  // deselect all figures
  ActiveChildForm.LayerPanelList.DeselectAllFiguresOnFigureLayer;

  LElementCount := High(FOldSelectedFigureInfoArray) + 1;
  SetLength(ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray, LElementCount);

  if LElementCount > 0 then
  begin
    for i := 0 to (LElementCount - 1) do
    begin
      ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray[i].LayerIndex  := FOldSelectedFigureInfoArray[i].LayerIndex;
      ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray[i].FigureIndex := FOldSelectedFigureInfoArray[i].FigureIndex;
    end
  end;

  LElementCount := High(FOldSelectedFigureLayerIndexArray) + 1;
  SetLength(ActiveChildForm.LayerPanelList.FSelectedFigureLayerIndexArray, LElementCount);

  if LElementCount > 0 then
  begin
    for i := 0 to (LElementCount - 1) do
    begin
      ActiveChildForm.LayerPanelList.FSelectedFigureLayerIndexArray[i] := FOldSelectedFigureLayerIndexArray[i];
    end;
  end;

  ActiveChildForm.LayerPanelList.SelectFiguresByFigureInfoArray;

  if ActiveChildForm.LayerPanelList.SelectedFigureCountOnFigureLayer = 1 then
  begin
    ActiveChildForm.FSelectedFigure := ActiveChildForm.LayerPanelList.GetFirstSelectedFigure;
  end
  else
  begin
    ActiveChildForm.FSelectedFigure := nil;
  end;

  ProcessAfterFigureCommandDone;
end;

procedure TgmSelectFigureCommand.Execute;
var
  i            : Integer;
  LElementCount: Integer;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  if frmMain.MainTool <> gmtStandard then
  begin
    frmMain.ChangeMainToolClick(frmMain.spdbtnStandardTools);
    frmMain.spdbtnStandardTools.Down := True;
  end;

  if frmMain.StandardTool <> gstMoveObjects then
  begin
    frmMain.ChangeStandardTools(frmMain.spdbtnMoveObjects);
    frmMain.spdbtnMoveObjects.Down := True;
  end;

  // deselect all figures
  ActiveChildForm.LayerPanelList.DeselectAllFiguresOnFigureLayer;

  LElementCount := High(FNewSelectedFigureInfoArray) + 1;
  SetLength(ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray, LElementCount);

  if LElementCount > 0 then
  begin
    for i := 0 to (LElementCount - 1) do
    begin
      ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray[i].LayerIndex  := FNewSelectedFigureInfoArray[i].LayerIndex;
      ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray[i].FigureIndex := FNewSelectedFigureInfoArray[i].FigureIndex;
    end;
  end;

  LElementCount := High(FNewSelectedFigureLayerIndexArray) + 1;
  SetLength(ActiveChildForm.LayerPanelList.FSelectedFigureLayerIndexArray, LElementCount);

  if LElementCount > 0 then
  begin
    for i := 0 to (LElementCount - 1) do
    begin
      ActiveChildForm.LayerPanelList.FSelectedFigureLayerIndexArray[i] := FNewSelectedFigureLayerIndexArray[i];
    end;
  end;

  ActiveChildForm.LayerPanelList.SelectFiguresByFigureInfoArray;

  if ActiveChildForm.LayerPanelList.SelectedFigureCountOnFigureLayer = 1 then
  begin
    ActiveChildForm.FSelectedFigure := ActiveChildForm.LayerPanelList.GetFirstSelectedFigure;
  end
  else
  begin
    ActiveChildForm.FSelectedFigure := nil;
  end;

  ProcessAfterFigureCommandDone;
end;

//-- TgmDeletedFigureInfo ------------------------------------------------------

constructor TgmDeletedFigureInfo.Create(
  const AFigureLayerIndex, AFigureIndex: Integer;
  const AFigureObj: TgmFigureObject);
begin
  inherited Create;

  FLayerIndex  := AFigureLayerIndex;
  FFigureIndex := AFigureIndex;

  if Assigned(AFigureObj) then
  begin
    FDeletedFigure := AFigureObj.GetSelfBackup;
  end
  else
  begin
    FDeletedFigure := nil;
  end;
end;

destructor TgmDeletedFigureInfo.Destroy;
begin
  FDeletedFigure.Free;

  inherited Destroy;
end;

//-- TgmDeleteFigureCommand ----------------------------------------------------

constructor TgmDeleteFigureCommand.Create(
  const AOldSelectedFigureInfoArray: array of TgmFigureInfo;
  const AOldSelectedFigureLayerIndexArray: array of Integer);
var
  i, LElementCount: Integer;
begin
  inherited Create(caNone, 'Delete Selected Figures');

  FOperateName := 'Undo ' + FCommandName;

  LElementCount := High(AOldSelectedFigureInfoArray) + 1;
  if LElementCount > 0 then
  begin
    SetLength(FOldSelectedFigureInfoArray, LElementCount);

    for i := 0 to (LElementCount - 1) do
    begin
      FOldSelectedFigureInfoArray[i].LayerIndex  := AOldSelectedFigureInfoArray[i].LayerIndex;
      FOldSelectedFigureInfoArray[i].FigureIndex := AOldSelectedFigureInfoArray[i].FigureIndex;
    end;
  end
  else
  begin
    FOldSelectedFigureInfoArray := nil;
  end;

  LElementCount := High(AOldSelectedFigureLayerIndexArray) + 1;
  if LElementCount > 0 then
  begin
    SetLength(FOldSelectedFigureLayerIndexArray, LElementCount);

    for i := 0 to (LElementCount - 1) do
    begin
      FOldSelectedFigureLayerIndexArray[i] := AOldSelectedFigureLayerIndexArray[i];
    end;
  end
  else
  begin
    FOldSelectedFigureLayerIndexArray := nil;
  end;

  FDeletedFigureList := TList.Create;
  RecordDeletedFigureInfoToList;
end;

destructor TgmDeleteFigureCommand.Destroy;
var
  i                 : Integer;
  LDeletedFigureInfo: TgmDeletedFigureInfo;
begin
  if High(FOldSelectedFigureInfoArray) >= 0 then
  begin
    SetLength(FOldSelectedFigureInfoArray, 0);
    FOldSelectedFigureInfoArray := nil;
  end;

  if High(FOldSelectedFigureLayerIndexArray) >= 0 then
  begin
    SetLength(FOldSelectedFigureLayerIndexArray, 0);
    FOldSelectedFigureLayerIndexArray := nil;
  end;

  if FDeletedFigureList.Count > 0 then
  begin
    for i := 0 to (FDeletedFigureList.Count - 1) do
    begin
      LDeletedFigureInfo := TgmDeletedFigureInfo(FDeletedFigureList.Items[i]);
      LDeletedFigureInfo.Free;
    end;
    
    FDeletedFigureList.Clear;
  end;

  FDeletedFigureList.Free;

  inherited Destroy;
end;

procedure TgmDeleteFigureCommand.RecordDeletedFigureInfoToList;
var
  i, LElementCount         : Integer;
  LLayerIndex, LFigureIndex: Integer;
  LFigureLayerPanel        : TgmFigureLayerPanel;
  LOldFigure               : TgmFigureObject;
  LDeletedFigureInfo       : TgmDeletedFigureInfo;
begin
  LElementCount := High(FOldSelectedFigureInfoArray) + 1;

  if LElementCount > 0 then
  begin
    for i := 0 to (LElementCount - 1) do
    begin
      LLayerIndex        := FOldSelectedFigureInfoArray[i].LayerIndex;
      LFigureIndex       := FOldSelectedFigureInfoArray[i].FigureIndex;
      LFigureLayerPanel  := TgmFigureLayerPanel(ActiveChildForm.LayerPanelList.Items[LLayerIndex]);
      LOldFigure         := TgmFigureObject(LFigureLayerPanel.FigureList.Items[LFigureIndex]);
      LDeletedFigureInfo := TgmDeletedFigureInfo.Create(LLayerIndex, LFigureIndex, LOldFigure);

      FDeletedFigureList.Add(LDeletedFigureInfo);
    end;
  end;
end; 

procedure TgmDeleteFigureCommand.RestoreDeletedFigures;
var
  i, LLayerIndex    : Integer;
  LDeletedFigureInfo: TgmDeletedFigureInfo;
  LFigureLayerPanel : TgmFigureLayerPanel;
  LOldFigure        : TgmFigureObject;
begin
  if FDeletedFigureList.Count > 0 then
  begin
    for i := 0 to (FDeletedFigureList.Count - 1) do
    begin
      LDeletedFigureInfo := TgmDeletedFigureInfo(FDeletedFigureList.Items[i]);
      LLayerIndex        := LDeletedFigureInfo.LayerIndex;
      LFigureLayerPanel  := TgmFigureLayerPanel(ActiveChildForm.LayerPanelList.Items[LLayerIndex]);
      LOldFigure         := LDeletedFigureInfo.DeletedFigure.GetSelfBackup;

      if Assigned(LOldFigure) then
      begin
        LFigureLayerPanel.FigureList.Insert(LDeletedFigureInfo.FigureIndex, LOldFigure);
      end;
    end;
  end;
end;

procedure TgmDeleteFigureCommand.Rollback;
var
  i, LElementCount : Integer;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  if frmMain.MainTool <> gmtStandard then
  begin
    frmMain.ChangeMainToolClick(frmMain.spdbtnStandardTools);
    frmMain.spdbtnStandardTools.Down := True;
  end;

  if frmMain.StandardTool <> gstMoveObjects then
  begin
    frmMain.ChangeStandardTools(frmMain.spdbtnMoveObjects);
    frmMain.spdbtnMoveObjects.Down := True;
  end;

  LElementCount := High(FOldSelectedFigureInfoArray) + 1;
  SetLength(ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray, LElementCount);

  if LElementCount > 0 then
  begin
    for i := 0 to (LElementCount - 1) do
    begin
      ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray[i].LayerIndex  := FOldSelectedFigureInfoArray[i].LayerIndex;
      ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray[i].FigureIndex := FOldSelectedFigureInfoArray[i].FigureIndex;
    end
  end;

  LElementCount := High(FOldSelectedFigureLayerIndexArray) + 1;
  SetLength(ActiveChildForm.LayerPanelList.FSelectedFigureLayerIndexArray, LElementCount);

  if LElementCount > 0 then
  begin
    for i := 0 to (LElementCount - 1) do
    begin
      ActiveChildForm.LayerPanelList.FSelectedFigureLayerIndexArray[i] := FOldSelectedFigureLayerIndexArray[i];
    end;
  end;

  RestoreDeletedFigures;

  ActiveChildForm.LayerPanelList.DrawAllFiguresOnSelectedFigureLayer(ActiveChildForm.imgDrawingArea.Layers);
  ActiveChildForm.LayerPanelList.ApplyMaskOnSelectedFigureLayer;
  ActiveChildForm.LayerPanelList.UpdateSelectedFigureLayerThumbnail(ActiveChildForm.imgDrawingArea.Layers);

  if ActiveChildForm.LayerPanelList.SelectedFigureCountOnFigureLayer = 1 then
  begin
    ActiveChildForm.FSelectedFigure := ActiveChildForm.LayerPanelList.GetFirstSelectedFigure;
  end
  else
  begin
    ActiveChildForm.FSelectedFigure := nil;
  end;

  ProcessAfterFigureCommandDone;
end;

procedure TgmDeleteFigureCommand.Execute;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  ActiveChildForm.LayerPanelList.DeleteSelectedFiguresOnFigureLayer;
  ActiveChildForm.LayerPanelList.DrawDeselectedFiguresOnSelectedFigureLayer(ActiveChildForm.imgDrawingArea.Layers);
  ActiveChildForm.LayerPanelList.ApplyMaskOnSelectedFigureLayer;
  ActiveChildForm.LayerPanelList.UpdateSelectedFigureLayerThumbnail(ActiveChildForm.imgDrawingArea.Layers);

  SetLength(ActiveChildForm.LayerPanelList.FSelectedFigureLayerIndexArray, 0);
  SetLength(ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray, 0);

  ProcessAfterFigureCommandDone;
end; 

//-- TgmLockFigureCommand ------------------------------------------------------

constructor TgmLockFigureCommand.Create(const ALockMode: TgmLockFigureMode);
begin
  inherited Create(caNone, '');

  FLockMode := ALockMode;

  case FLockMode of
    lfmLock:
      begin
        FCommandName := 'Lock Selected Figures';
      end;
      
    lfmUnlock:
      begin
        FCommandName := 'Unlock Selected Figures';
      end;
  end;

  FOperateName := 'Undo ' + FCommandName;
end; 

procedure TgmLockFigureCommand.Rollback;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  case FLockMode of
    lfmLock:
      begin
        if ActiveChildForm.LayerPanelList.SelectedFigureCountOnFigureLayer > 0 then
        begin
          ActiveChildForm.LayerPanelList.UnlockSelectedFiguresOnSelectedFigureLayer;
        end;
      end;

    lfmUnlock:
      begin
        if ActiveChildForm.LayerPanelList.SelectedFigureCountOnFigureLayer > 0 then
        begin
          ActiveChildForm.LayerPanelList.LockSelectedFiguresOnSelectedFigureLayer;
        end;
      end;
  end;

  ProcessAfterFigureCommandDone;
end;

procedure TgmLockFigureCommand.Execute;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  case FLockMode of
    lfmLock:
      begin
        if ActiveChildForm.LayerPanelList.SelectedFigureCountOnFigureLayer > 0 then
        begin
          ActiveChildForm.LayerPanelList.LockSelectedFiguresOnSelectedFigureLayer;
        end;
      end;

    lfmUnlock:
      begin
        if ActiveChildForm.LayerPanelList.SelectedFigureCountOnFigureLayer > 0 then
        begin
          ActiveChildForm.LayerPanelList.UnlockSelectedFiguresOnSelectedFigureLayer;
        end;
      end;
  end;

  ProcessAfterFigureCommandDone;
end;

//-- TgmModifyFigureStyleCommand -----------------------------------------------

constructor TgmModifyFigureStyleCommand.Create(
  const AOldData, ANewData: TgmFigureBasicData);
begin
  inherited Create(caNone, 'Modify Figure Properties');

  FOperateName := 'Undo ' + FCommandName;
  FOldData     := AOldData;
  FNewData     := ANewData;
end;

procedure TgmModifyFigureStyleCommand.Rollback;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  if Assigned(ActiveChildForm.FSelectedFigure) then
  begin
    with ActiveChildForm.FSelectedFigure do
    begin
      Name         := FOldData.Name;
      PenColor     := FOldData.PenColor;
      BrushColor   := FOldData.BrushColor;
      PenWidth     := FOldData.PenWidth;
      PenStyle     := FOldData.PenStyle;
      BrushStyle   := FOldData.BrushStyle;

      if Flag in [ffRegularPolygon, ffSquare, ffRoundSquare, ffCircle] then
      begin
        OriginPixelX := FOldData.OriginX;
        OriginPixelY := FOldData.OriginY;
        RadiusPixel  := FOldData.Radius;
      end;
    end;

    ActiveChildForm.LayerPanelList.DrawAllFiguresOnSelectedFigureLayer(ActiveChildForm.imgDrawingArea.Layers);
    ActiveChildForm.LayerPanelList.ApplyMaskOnSelectedFigureLayer;
    ActiveChildForm.LayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
  end;

  ProcessAfterFigureCommandDone;
end; 

procedure TgmModifyFigureStyleCommand.Execute;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  if Assigned(ActiveChildForm.FSelectedFigure) then
  begin
    with ActiveChildForm.FSelectedFigure do
    begin
      Name       := FNewData.Name;
      PenColor   := FNewData.PenColor;
      BrushColor := FNewData.BrushColor;
      PenWidth   := FNewData.PenWidth;
      PenStyle   := FNewData.PenStyle;
      BrushStyle := FNewData.BrushStyle;

      if Flag in [ffRegularPolygon, ffSquare, ffRoundSquare, ffCircle] then
      begin
        OriginPixelX := FNewData.OriginX;
        OriginPixelY := FNewData.OriginY;
        RadiusPixel  := FNewData.Radius;
      end;
    end;

    ActiveChildForm.LayerPanelList.DrawAllFiguresOnSelectedFigureLayer(ActiveChildForm.imgDrawingArea.Layers);
    ActiveChildForm.LayerPanelList.ApplyMaskOnSelectedFigureLayer;
    ActiveChildForm.LayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
  end;

  ProcessAfterFigureCommandDone;
end; 

//-- TgmStretchFigureCommand ---------------------------------------------------

constructor TgmStretchFigureCommand.Create(
  const AOldFigure, ANewFigure: TgmFigureObject);
begin
  inherited Create(caNone, '');

  FFigureFlag  := AOldFigure.Flag;
  FCommandName := GetCommandName;
  FOperateName := 'Undo ' + FCommandName;
  FOldFigure   := AOldFigure.GetSelfBackup;
  FNewFigure   := ANewFigure.GetSelfBackup;
end; 

destructor TgmStretchFigureCommand.Destroy;
begin
  FOldFigure.Free;
  FNewFigure.Free;

  inherited Destroy;
end;

function TgmStretchFigureCommand.GetCommandName: string;
var
  LPrefixName: string;
  LSuffixName: string;
begin
  LPrefixName := 'Stretch ';

  case FFigureFlag of
    ffStraightLine  : LSuffixName := 'Straight Line';
    ffCurve         : LSuffixName := 'Bezier Curve';
    ffPolygon       : LSuffixName := 'Polygon';
    ffRegularPolygon: LSuffixName := 'Regular Polygon';
    ffRectangle     : LSuffixName := 'Rectangle';
    ffSquare        : LSuffixName := 'Square';
    ffRoundRectangle: LSuffixName := 'Rounded-Corner Rectangle';
    ffRoundSquare   : LSuffixName := 'Rounded-Corner Square';
    ffEllipse       : LSuffixName := 'Ellipse';
    ffCircle        : LSuffixName := 'Circle';
  end;

  Result := LPrefixName + LSuffixName;
end; 

procedure TgmStretchFigureCommand.Rollback;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  if Assigned(ActiveChildForm.FSelectedFigure) then
  begin
    ActiveChildForm.FSelectedFigure.AssignData(FOldFigure);
    ActiveChildForm.LayerPanelList.DrawAllFiguresOnSelectedFigureLayer(ActiveChildForm.imgDrawingArea.Layers);
    ActiveChildForm.LayerPanelList.ApplyMaskOnSelectedFigureLayer;
    ActiveChildForm.LayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
  end;

  ProcessAfterFigureCommandDone;
end;

procedure TgmStretchFigureCommand.Execute;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  if Assigned(ActiveChildForm.FSelectedFigure) then
  begin
    ActiveChildForm.FSelectedFigure.AssignData(FNewFigure);
    ActiveChildForm.LayerPanelList.DrawAllFiguresOnSelectedFigureLayer(ActiveChildForm.imgDrawingArea.Layers);
    ActiveChildForm.LayerPanelList.ApplyMaskOnSelectedFigureLayer;
    ActiveChildForm.LayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
  end;

  ProcessAfterFigureCommandDone;
end;

//-- TgmTranslateFigureCommand -------------------------------------------------

constructor TgmTranslateFigureCommand.Create(
  const AAccumTranslateVector: TPoint);
begin
  inherited Create(caNone, 'Move Figures');

  FOperateName          := 'Undo ' + FCommandName;
  FAccumTranslateVector := AAccumTranslateVector;
end; 

procedure TgmTranslateFigureCommand.Rollback;
var
  LOldVector: TPoint;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  if High(ActiveChildForm.LayerPanelList.FSelectedFigureLayerIndexArray) >= 0 then
  begin
    LOldVector.X := -FAccumTranslateVector.X;
    LOldVector.Y := -FAccumTranslateVector.Y;

    ActiveChildForm.LayerPanelList.TranslateSelectedFigures(LOldVector);
    ActiveChildForm.LayerPanelList.DrawAllFiguresOnSelectedFigureLayer(ActiveChildForm.imgDrawingArea.Layers);
    ActiveChildForm.LayerPanelList.ApplyMaskOnSelectedFigureLayer;
    ActiveChildForm.LayerPanelList.UpdateSelectedFigureLayerThumbnail(ActiveChildForm.imgDrawingArea.Layers);
  end;

  ProcessAfterFigureCommandDone;
end;

procedure TgmTranslateFigureCommand.Execute;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  if High(ActiveChildForm.LayerPanelList.FSelectedFigureLayerIndexArray) >= 0 then
  begin
    ActiveChildForm.LayerPanelList.TranslateSelectedFigures(FAccumTranslateVector);
    ActiveChildForm.LayerPanelList.DrawAllFiguresOnSelectedFigureLayer(ActiveChildForm.imgDrawingArea.Layers);
    ActiveChildForm.LayerPanelList.ApplyMaskOnSelectedFigureLayer;
    ActiveChildForm.LayerPanelList.UpdateSelectedFigureLayerThumbnail(ActiveChildForm.imgDrawingArea.Layers);
  end;

  ProcessAfterFigureCommandDone;
end;

//-- TgmTypeToolLayerCommand ---------------------------------------------------

constructor TgmTypeToolLayerCommand.Create(const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType);
var
  LTextLayerPanel: TgmRichTextLayerPanel;
begin
  inherited Create(caNone, '');

  FTargetLayerIndex := ALayerIndex;
  FRedoIndex        := ALayerIndex;
  FLayerCommandType := ALayerCommandType;

  case FLayerCommandType of
    lctNew:
      begin
        FCommandName := 'Type Tool';
      end;
      
    lctDelete:
      begin
        FCommandName := 'Delete Layer';
      end;
  end;

  FOperateName := 'Undo ' + FCommandName;

  LTextLayerPanel  := TgmRichTextLayerPanel(ALayerPanel);
  FLayerName       := LTextLayerPanel.LayerName.Caption;
  FTextFileName    := LTextLayerPanel.TextFileName;
  FTextBorderStart := LTextLayerPanel.BorderStart;
  FTextBorderEnd   := LTextLayerPanel.BorderEnd;
  FEditState       := LTextLayerPanel.IsEditState;
  FTextChanged     := LTextLayerPanel.IsTextChanged;
  FTextLayerState  := LTextLayerPanel.TextLayerState;

  FOldTextStream := TMemoryStream.Create;
  LTextLayerPanel.RichTextStream.Position := 0;
  try
    FOldTextStream.LoadFromStream(LTextLayerPanel.RichTextStream);
    FOldTextStream.Position := 0;
  finally
    LTextLayerPanel.RichTextStream.Position := 0;
  end;

  if ALayerCommandType = lctDelete then
  begin
    FLayerLockTransparency := ALayerPanel.IsLockTransparency;
    FLayerBlendModeIndex   := ALayerPanel.BlendModeIndex;
    FLayerOpacity          := ALayerPanel.LayerMasterAlpha;
  end;
end;

destructor TgmTypeToolLayerCommand.Destroy;
begin
  FOldTextStream.Free;
  
  inherited Destroy;
end;

procedure TgmTypeToolLayerCommand.CreateOldRichTextLayer;
var
  LRichTextLayerPanel: TgmRichTextLayerPanel;
begin
  ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex - 1);
  ActiveChildForm.CreateRichTextLayer;

  ActiveChildForm.LayerPanelList.SelectedLayerPanel.BlendModeIndex     := FLayerBlendModeIndex;
  ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerMasterAlpha   := FLayerOpacity;
  ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsLockTransparency := FLayerLockTransparency;

  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
  begin
    LRichTextLayerPanel := TgmRichTextLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

    LRichTextLayerPanel.LayerName.Caption := FLayerName;
    LRichTextLayerPanel.TextFileName      := FTextFileName;
    LRichTextLayerPanel.BorderStart       := FTextBorderStart;
    LRichTextLayerPanel.BorderEnd         := FTextBorderEnd;
    LRichTextLayerPanel.IsEditState       := FEditState;
    LRichTextLayerPanel.IsTextChanged     := FTextChanged;
    LRichTextLayerPanel.TextLayerState    := FTextLayerState;

    FOldTextStream.Position := 0;
    try
      LRichTextLayerPanel.RichTextStream.Clear;
      LRichTextLayerPanel.RichTextStream.LoadFromStream(FOldTextStream);
      LRichTextLayerPanel.RichTextStream.Position := 0;
    finally
      FOldTextStream.Position := 0;
    end;

    LRichTextLayerPanel.SaveEdits;

    try
      frmRichTextEditor.rchedtRichTextEditor.Lines.LoadFromStream(FOldTextStream);
      ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Clear($00FFFFFF);

      DrawRichTextOnBitmap(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                           LRichTextLayerPanel.BorderRect,
                           frmRichTextEditor.rchedtRichTextEditor);

      if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask then
      begin
        GetAlphaChannelBitmap(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                              ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
      end;
    finally
      FOldTextStream.Position := 0;
      frmRichTextEditor.rchedtRichTextEditor.Lines.Clear;
    end;
  end;
end;

procedure TgmTypeToolLayerCommand.Rollback;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
        ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex - 1);
      end;

    lctDelete:
      begin
        FRedoIndex := ActiveChildForm.LayerPanelList.CurrentIndex;
        CreateOldRichTextLayer;

        frmLayer.cmbbxLayerBlendMode.ItemIndex  := FLayerBlendModeIndex;
        frmLayer.ggbrLayerOpacity.Position      := FLayerOpacity;
        frmLayer.chckbxLockTransparency.Checked := FLayerLockTransparency;
      end;
  end;

  ProcessAfterTextToolCommandDone;
end;

procedure TgmTypeToolLayerCommand.Execute;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  case FLayerCommandType of
    lctNew:
      begin
        CreateOldRichTextLayer;
      end;

    lctDelete:
      begin
        ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FTargetLayerIndex);
        ActiveChildForm.LayerPanelList.ActiveLayerPanel(FRedoIndex);
      end;
  end;

  ProcessAfterTextToolCommandDone;
end;

//-- TgmEditTypeCommand --------------------------------------------------------

constructor TgmEditTypeCommand.Create(const ALayerIndex: Integer;
  const AOldTextStream: TMemoryStream; const ALayerPanel: TgmLayerPanel);
var
  LTextLayerPanel: TgmRichTextLayerPanel;
begin
  inherited Create(caNone, 'Edit Type Layer');

  FOperateName      := 'Undo ' + FCommandName;
  FTargetLayerIndex := ALayerIndex;
  FRedoIndex        := ALayerIndex;

  if Assigned(AOldTextStream) then
  begin
    try
      FOldTextStream          := TMemoryStream.Create;
      AOldTextStream.Position := 0;
      FOldTextStream.LoadFromStream(AOldTextStream);
    finally
      FOldTextStream.Position := 0;
      AOldTextStream.Position := 0;
    end;
  end
  else
  begin
    FOldTextStream := nil;
  end;

  if Assigned(ALayerPanel) then
  begin
    LTextLayerPanel := TgmRichTextLayerPanel(ALayerPanel);
    try
      FNewTextStream := TMemoryStream.Create;
      LTextLayerPanel.RichTextStream.Position := 0;
      FNewTextStream.LoadFromStream(LTextLayerPanel.RichTextStream);
    finally
      FNewTextStream.Position := 0;
      LTextLayerPanel.RichTextStream.Position := 0;
    end;
  end;
end;

destructor TgmEditTypeCommand.Destroy;
begin
  FOldTextStream.Free;
  FNewTextStream.Free;
  
  inherited Destroy;
end;

procedure TgmEditTypeCommand.Rollback;
var
  LTextLayerPanel : TgmRichTextLayerPanel;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;
  FRedoIndex    := ActiveChildForm.LayerPanelList.CurrentIndex;

  if FTargetLayerIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
  end;

  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
  begin
    LTextLayerPanel := TgmRichTextLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

    FOldTextStream.Position := 0;

    try
      LTextLayerPanel.RichTextStream.Clear;
      LTextLayerPanel.RichTextStream.LoadFromStream(FOldTextStream);
      LTextLayerPanel.RichTextStream.Position := 0;
      LTextLayerPanel.SaveEdits;
    finally
      FOldTextStream.Position := 0;
    end;

    try
      frmRichTextEditor.rchedtRichTextEditor.Lines.LoadFromStream(FOldTextStream);
      ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Clear($00FFFFFF);

      DrawRichTextOnBitmap(
        ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
        LTextLayerPanel.BorderRect, frmRichTextEditor.rchedtRichTextEditor);

      if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask then
      begin
        GetAlphaChannelBitmap(
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
      end;

      ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;

      if not LTextLayerPanel.IsRenamed then
      begin
        LTextLayerPanel.SetLayerName(frmRichTextEditor.rchedtRichTextEditor.Lines[0]);
      end;
    finally
      FOldTextStream.Position := 0;
      frmRichTextEditor.rchedtRichTextEditor.Lines.Clear;
    end;
  end;

  ProcessAfterTextToolCommandDone;
end;

procedure TgmEditTypeCommand.Execute;
var
  LTextLayerPanel : TgmRichTextLayerPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  if FTargetLayerIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
  end;

  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
  begin
    LTextLayerPanel := TgmRichTextLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

    FNewTextStream.Position := 0;

    try
      LTextLayerPanel.RichTextStream.Clear;
      LTextLayerPanel.RichTextStream.LoadFromStream(FNewTextStream);
      LTextLayerPanel.RichTextStream.Position := 0;
      LTextLayerPanel.SaveEdits;
    finally
      FNewTextStream.Position := 0;
    end;

    try
      frmRichTextEditor.rchedtRichTextEditor.Lines.LoadFromStream(FNewTextStream);
      ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Clear($00FFFFFF);
      
      DrawRichTextOnBitmap(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                           LTextLayerPanel.BorderRect, frmRichTextEditor.rchedtRichTextEditor);

      if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask then
      begin
        GetAlphaChannelBitmap(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                              ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
      end;

      ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;

      if not LTextLayerPanel.IsRenamed then
      begin
        LTextLayerPanel.SetLayerName(frmRichTextEditor.rchedtRichTextEditor.Lines[0]);
      end;
    finally
      FNewTextStream.Position := 0;
      frmRichTextEditor.rchedtRichTextEditor.Lines.Clear;
    end;
  end;

  if FRedoIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FRedoIndex);
  end;

  ProcessAfterTextToolCommandDone;
end; 

//-- TgmTranslateTextRegionCommand ---------------------------------------------

constructor TgmTranslateTextRegionCommand.Create(const ALayerIndex: Integer;
  const AAccumTranslateVector: TPoint);
begin
  inherited Create(caNone, 'Move Text Region');

  FOperateName          := 'Undo ' + FCommandName;
  FTargetLayerIndex     := ALayerIndex;
  FRedoIndex            := ALayerIndex;
  FAccumTranslateVector := AAccumTranslateVector;
end;

procedure TgmTranslateTextRegionCommand.Rollback;
var
  LTextLayerPanel      : TgmRichTextLayerPanel;
  LUndoTranslateVector : TPoint;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;
  FRedoIndex    := ActiveChildForm.LayerPanelList.CurrentIndex;

  if FTargetLayerIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
  end;

  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
  begin
    LUndoTranslateVector.X := -FAccumTranslateVector.X;
    LUndoTranslateVector.Y := -FAccumTranslateVector.Y;

    LTextLayerPanel := TgmRichTextLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);
    LTextLayerPanel.Translate(LUndoTranslateVector);

    try
      LTextLayerPanel.RichTextStream.Position := 0;

      frmRichTextEditor.rchedtRichTextEditor.Lines.LoadFromStream(LTextLayerPanel.RichTextStream);
      ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Clear($00FFFFFF);
      
      DrawRichTextOnBitmap(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                           LTextLayerPanel.BorderRect, frmRichTextEditor.rchedtRichTextEditor);

      if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask then
      begin
        GetAlphaChannelBitmap(
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
      end;

      ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;
      
    finally
      LTextLayerPanel.RichTextStream.Position := 0;
    end;
  end;

  ProcessAfterTextToolCommandDone;
end; 

procedure TgmTranslateTextRegionCommand.Execute;
var
  LTextLayerPanel : TgmRichTextLayerPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  if FTargetLayerIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
  end;
  
  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
  begin
    LTextLayerPanel := TgmRichTextLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);
    LTextLayerPanel.Translate(FAccumTranslateVector);

    try
      LTextLayerPanel.RichTextStream.Position := 0;

      frmRichTextEditor.rchedtRichTextEditor.Lines.LoadFromStream(LTextLayerPanel.RichTextStream);
      ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Clear($00FFFFFF);

      DrawRichTextOnBitmap(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                           LTextLayerPanel.BorderRect, frmRichTextEditor.rchedtRichTextEditor);

      if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask then
      begin
        GetAlphaChannelBitmap(
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
      end;

      ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;
    finally
      LTextLayerPanel.RichTextStream.Position := 0;
    end;
  end;

  if FRedoIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FRedoIndex);
  end;

  ProcessAfterTextToolCommandDone;
end; 

//-- TgmScaleTextRegionCommand -------------------------------------------------

constructor TgmScaleTextRegionCommand.Create(const ALayerIndex: Integer;
  const AOldTopLeft, AOldBottomRight, ANewTopLeft, ANewBottomRight: TPoint);
begin
  inherited Create(caNone, 'Scale Text Region');

  FOperateName      := 'Undo ' + FCommandName;
  FTargetLayerIndex := ALayerIndex;
  FRedoIndex        := ALayerIndex;
  FOldTopLeft       := AOldTopLeft;
  FOldBottomRight   := AOldBottomRight;
  FNewTopLeft       := ANewTopLeft;
  FNewBottomRight   := ANewBottomRight;
end;

procedure TgmScaleTextRegionCommand.Rollback;
var
  LTextLayerPanel : TgmRichTextLayerPanel;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;
  FRedoIndex    := ActiveChildForm.LayerPanelList.CurrentIndex;

  if FTargetLayerIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
  end;

  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
  begin
    LTextLayerPanel := TgmRichTextLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

    LTextLayerPanel.BorderStart := FOldTopLeft;
    LTextLayerPanel.BorderEnd   := FOldBottomRight;

    try
      LTextLayerPanel.RichTextStream.Position := 0;

      frmRichTextEditor.rchedtRichTextEditor.Lines.LoadFromStream(LTextLayerPanel.RichTextStream);
      ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Clear($00FFFFFF);
      
      DrawRichTextOnBitmap(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                           LTextLayerPanel.BorderRect, frmRichTextEditor.rchedtRichTextEditor);

      if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask then
      begin
        GetAlphaChannelBitmap(
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
      end;

      ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;
    finally
      LTextLayerPanel.RichTextStream.Position := 0;
    end;
  end;

  ProcessAfterTextToolCommandDone;
end;

procedure TgmScaleTextRegionCommand.Execute;
var
  LTextLayerPanel : TgmRichTextLayerPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  if FTargetLayerIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
  end;

  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
  begin
    LTextLayerPanel := TgmRichTextLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

    LTextLayerPanel.BorderStart := FNewTopLeft;
    LTextLayerPanel.BorderEnd   := FNewBottomRight;

    try
      LTextLayerPanel.RichTextStream.Position := 0;

      frmRichTextEditor.rchedtRichTextEditor.Lines.LoadFromStream(LTextLayerPanel.RichTextStream);
      ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Clear($00FFFFFF);

      DrawRichTextOnBitmap(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                           LTextLayerPanel.BorderRect, frmRichTextEditor.rchedtRichTextEditor);

      if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask then
      begin
        GetAlphaChannelBitmap(
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
      end;

      ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;
    finally
      LTextLayerPanel.RichTextStream.Position := 0;
    end;
  end;

  if FRedoIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FRedoIndex);
  end;

  ProcessAfterTextToolCommandDone;
end; 

//-- TgmMergeLayersCommand -----------------------------------------------------

constructor TgmMergeLayersCommand.Create(const AMergeMode: TgmMergeLayerMode);
var
  LCommandDir: string;
  LGMDManager: TgmGMDManager;
begin
  inherited Create(caNone, '');

  FMergeMode := AMergeMode;

  case FMergeMode of
    mlmFlatten:
      begin
        FCommandName := 'Flatten Image';
      end;

    mlmMergeDown:
      begin
        FCommandName := 'Merge Down';
      end;
      
    mlmMergeVisible:
      begin
        FCommandName := 'Merge Visible';
      end;
  end;

  FOperateName := 'Undo ' + FCommandName;

  { Save all the data (layers, channels, paths) to disk for saving the
    system memory. And load them back when doing Undo operation. }

  // save the data at here
  LCommandDir := ExtractFileDir(ParamStr(0)) + '\History';

  if not DirectoryExists(LCommandDir) then
  begin
    CreateDir(LCommandDir);
  end;

  // get the file name
  FGMDFileName := LCommandDir + '\Undo' + IntToStr(GetTickCount);

  LGMDManager := TgmGMDManager.Create;
  try
    // link pointers to the gmd manager
    LGMDManager.LayerPanelList := ActiveChildForm.LayerPanelList;
    LGMDManager.ChannelManager := ActiveChildForm.ChannelManager;
    LGMDManager.PathPanelList  := ActiveChildForm.PathPanelList;

    LGMDManager.SaveToFile(FGMDFileName);
  finally
    LGMDManager.Free;
  end;
end;

destructor TgmMergeLayersCommand.Destroy;
begin
  if FileExists(FGMDFileName) then
  begin
    DeleteFile(PChar(FGMDFileName));
  end;

  inherited Destroy;
end;

procedure TgmMergeLayersCommand.MergeAllLayers;
begin
  if Assigned(ActiveChildForm) then
  begin
    // delete handle layers...
    ActiveChildForm.DeleteRichTextHandleLayer;
    ActiveChildForm.DeleteShapeOutlineLayer;

    // flatten layers
    ActiveChildForm.LayerPanelList.FlattenLayers;
    ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociateLayerToPanel(ActiveChildForm.imgDrawingArea.Layers, 0);

    // associate the flattened layer to channel manager
    ActiveChildForm.ChannelManager.AssociateToLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);
    ActiveChildForm.ChannelManager.SelectAllColorChannels;

    // update channel thumbnail
    ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);

    frmLayer.ggbrLayerOpacity.Position     := ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.MasterAlpha;
    frmLayer.cmbbxLayerBlendMode.ItemIndex := ActiveChildForm.LayerPanelList.SelectedLayerPanel.BlendModeIndex;
    frmLayer.tlbtnAddMask.Enabled          := not ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask;

    ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
  end;
end;

procedure TgmMergeLayersCommand.MergeLayerDown;
begin
  if Assigned(ActiveChildForm) then
  begin
    // delete handle layers...
    ActiveChildForm.DeleteRichTextHandleLayer;
    ActiveChildForm.DeleteShapeOutlineLayer;

    // merge layer down
    ActiveChildForm.LayerPanelList.MergeDown;
    ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;

    frmLayer.scrlbxLayers.Update;
    frmLayer.tlbtnAddMask.Enabled := not ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask;
  end;
end;

procedure TgmMergeLayersCommand.MergeVisibleLayers;
begin
  if Assigned(ActiveChildForm) then
  begin
    // delete handle layers...
    ActiveChildForm.DeleteRichTextHandleLayer;
    ActiveChildForm.DeleteShapeOutlineLayer;

    // merge visible layers
    ActiveChildForm.LayerPanelList.MergeVisble;
    ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;

    frmLayer.scrlbxLayers.Update;
    frmLayer.tlbtnAddMask.Enabled := not ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask;
  end;
end;

procedure TgmMergeLayersCommand.Rollback;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  { First of all, we need to delete all the data, such as layers, channels and
    paths, in a child form which is currently activated, and then load the data
    back from the disk to retore the form to the state that before doing flatten
    command. }

  if Assigned(ActiveChildForm) then
  begin
    ActiveChildForm.LoadDataFromGMDFile(FGMDFileName);
  end;
end; 

procedure TgmMergeLayersCommand.Execute;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  case FMergeMode of
    mlmFlatten     : MergeAllLayers;
    mlmMergeDown   : MergeLayerDown;
    mlmMergeVisible: MergeVisibleLayers;
  end;
end;

//-- TgmChangeImageSizeCommand -------------------------------------------------

constructor TgmChangeImageSizeCommand.Create(
  const ANewWidth, ANewHeight: Integer;
  const AResamplingOptions: TgmResamplingOptions);
var
  LCommandDir: string;
  LGMDManager: TgmGMDManager;
begin
  inherited Create(caNone, 'Image Size');

  FOperateName       := 'Undo ' + FCommandName;
  FNewWidth          := ANewWidth;
  FNewHeight         := ANewHeight;
  FResamplingOptions := AResamplingOptions;

  { Save all the data (layers, channels, paths) to disk for saving the
    system memory. And load them back when doing Undo operation. }

  // save the data at here
  LCommandDir := ExtractFileDir(ParamStr(0)) + '\History';

  if not DirectoryExists(LCommandDir) then
  begin
    CreateDir(LCommandDir);
  end;

  // get the file name
  FGMDFileName := LCommandDir + '\Undo' + IntToStr(GetTickCount);

  LGMDManager := TgmGMDManager.Create;
  try
    // link pointers to the gmd manager
    LGMDManager.LayerPanelList := ActiveChildForm.LayerPanelList;
    LGMDManager.ChannelManager := ActiveChildForm.ChannelManager;
    LGMDManager.PathPanelList  := ActiveChildForm.PathPanelList;

    LGMDManager.SaveToFile(FGMDFileName);
  finally
    LGMDManager.Free;
  end;
end;

destructor TgmChangeImageSizeCommand.Destroy;
begin
  if FileExists(FGMDFileName) then
  begin
    DeleteFile(PChar(FGMDFileName));
  end;

  inherited Destroy;
end;

procedure TgmChangeImageSizeCommand.Rollback;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  { First of all, we need to delete all the data, such as layers, channels and
    paths, in a child form which is currently activated, and then load the data
    back from the disk to retore the form to the state that before doing flatten
    command. }

  if Assigned(ActiveChildForm) then
  begin
    ActiveChildForm.LoadDataFromGMDFile(FGMDFileName);
  end;
end; 

procedure TgmChangeImageSizeCommand.Execute;
var
  LOldWidth, LOldHeight : Integer;
  LLayer                : TBitmapLayer;
  LShapeRegionLayerPanel: TgmShapeRegionLayerPanel;
  LRichTextLayerPanel   : TgmRichTextLayerPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  if Assigned(ActiveChildForm) then
  begin
    LOldWidth  := ActiveChildForm.imgDrawingArea.Bitmap.Width;
    LOldHeight := ActiveChildForm.imgDrawingArea.Bitmap.Height;

    if (FNewWidth <> LOldWidth) or (FNewHeight <> LOldHeight) then
    begin
      // mark the image has changed
      ActiveChildForm.IsImageProcessed := True;

      ActiveChildForm.imgDrawingArea.Bitmap.SetSize(FNewWidth, FNewHeight);

      ActiveChildForm.LayerPanelList.ChangeImageSizeForAllLayers(
        ActiveChildForm.imgDrawingArea, FNewWidth, FNewHeight, FResamplingOptions);

      ActiveChildForm.FLayerTopLeft := ActiveChildForm.GetLayerTopLeft;

      // change the size of channels
      LLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[0]);
      
      ActiveChildForm.ChannelManager.ChangeChannelsSize(LLayer.Bitmap.Width,
                                                        LLayer.Bitmap.Height,
                                                        LLayer.Location);

      if frmMain.MainTool = gmtShape then
      begin
        if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
        begin
          LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(
            ActiveChildForm.LayerPanelList.SelectedLayerPanel);

          if not Assigned(ActiveChildForm.ShapeOutlineLayer) then
          begin
            ActiveChildForm.CreateShapeOutlineLayer;
          end;

          ActiveChildForm.CalcShapeOutlineLayerOffsetVector;
          ActiveChildForm.ShapeOutlineLayer.Bitmap.Clear($00000000);

          with LShapeRegionLayerPanel do
          begin
            if ShapeOutlineList.Count > 0 then
            begin
              ShapeOutlineList.DrawAllOutlines(
                ActiveChildForm.ShapeOutlineLayer.Bitmap.Canvas,
                ActiveChildForm.OutlineOffsetVector, pmNotXor);

              if frmMain.ShapeRegionTool = srtMove then
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

      if frmMain.MainTool = gmtTextTool then
      begin
        if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
        begin
          LRichTextLayerPanel := TgmRichTextLayerPanel(
            ActiveChildForm.LayerPanelList.SelectedLayerPanel);

          if not Assigned(ActiveChildForm.RichTextHandleLayer) then
          begin
            ActiveChildForm.CreateRichTextLayer;
          end;

          ActiveChildForm.RichTextHandleLayer.Bitmap.Clear($00000000);

          LRichTextLayerPanel.DrawRichTextBorder(
            ActiveChildForm.RichTextHandleLayer.Bitmap.Canvas,
            ActiveChildForm.RichTextHandleLayerOffsetVector);

          LRichTextLayerPanel.DrawRichTextBorderHandles(
            ActiveChildForm.RichTextHandleLayer.Bitmap.Canvas,
            ActiveChildForm.RichTextHandleLayerOffsetVector);
        end;
      end;

      // update display
      ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
    end;
  end;
end;

//-- TgmChangeCanvasSizeCommand ------------------------------------------------

constructor TgmChangeCanvasSizeCommand.Create(
  const ANewWidth, ANewHeight: Integer;
  const AAnchorDirection: TgmAnchorDirection;
  const ABackgroundColor: TColor32);
var
  LCommandDir: string;
  LGMDManager: TgmGMDManager;
begin
  inherited Create(caNone, 'Canvas Size');

  FOperateName     := 'Undo ' + FCommandName;
  FNewWidth        := ANewWidth;
  FNewHeight       := ANewHeight;
  FAnchorDirection := AAnchorDirection;
  FBackgroundColor := ABackgroundColor;

  { Save all the data (layers, channels, paths) to disk for saving the
    system memory. And load them back when doing Undo operation. }

  // save the data at here
  LCommandDir := ExtractFileDir(ParamStr(0)) + '\History';

  if not DirectoryExists(LCommandDir) then
  begin
    CreateDir(LCommandDir);
  end;

  // get the file name
  FGMDFileName := LCommandDir + '\Undo' + IntToStr(GetTickCount);

  LGMDManager := TgmGMDManager.Create;
  try
    // link pointers to the gmd manager
    LGMDManager.LayerPanelList := ActiveChildForm.LayerPanelList;
    LGMDManager.ChannelManager := ActiveChildForm.ChannelManager;
    LGMDManager.PathPanelList  := ActiveChildForm.PathPanelList;
    
    LGMDManager.SaveToFile(FGMDFileName);
  finally
    LGMDManager.Free;
  end;
end;

destructor TgmChangeCanvasSizeCommand.Destroy;
begin
  if FileExists(FGMDFileName) then
  begin
    DeleteFile(PChar(FGMDFileName));
  end;

  inherited Destroy;
end;

procedure TgmChangeCanvasSizeCommand.Rollback;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  { First of all, we need to delete all the data, such as layers, channels and
    paths, in a child form which is currently activated, and then load the data
    back from the disk to retore the form to the state that before doing flatten
    command. }

  if Assigned(ActiveChildForm) then
  begin
    ActiveChildForm.LoadDataFromGMDFile(FGMDFileName);
  end;
end;

procedure TgmChangeCanvasSizeCommand.Execute;
var
  LOldWidth, LOldHeight : Integer;
  LLayer                : TBitmapLayer;
  LShapeRegionLayerPanel: TgmShapeRegionLayerPanel;
  LRichTextLayerPanel   : TgmRichTextLayerPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  if Assigned(ActiveChildForm) then
  begin
    LOldWidth  := ActiveChildForm.imgDrawingArea.Bitmap.Width;
    LOldHeight := ActiveChildForm.imgDrawingArea.Bitmap.Height;

    if (FNewWidth <> LOldWidth) or (FNewHeight <> LOldHeight) then
    begin
      // mark the image has changed
      ActiveChildForm.IsImageProcessed := True;

      ActiveChildForm.imgDrawingArea.Bitmap.SetSize(FNewWidth, FNewHeight);

      ActiveChildForm.LayerPanelList.ChangeCanvasSizeForAllLayers(
        ActiveChildForm.imgDrawingArea, FNewWidth, FNewHeight, FAnchorDirection,
        FBackgroundColor);

      ActiveChildForm.FLayerTopLeft := ActiveChildForm.GetLayerTopLeft;

      // change the canvas size of channels
      LLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[0]);
        
      ActiveChildForm.ChannelManager.ChangeChannelsCanvasSize(LLayer.Bitmap.Width,
        LLayer.Bitmap.Height, LLayer.Location, FAnchorDirection);

      if frmMain.MainTool = gmtShape then
      begin
        if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
        begin
          LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(
            ActiveChildForm.LayerPanelList.SelectedLayerPanel);

          if not Assigned(ActiveChildForm.ShapeOutlineLayer) then
          begin
            ActiveChildForm.CreateShapeRegionLayer;
          end;

          ActiveChildForm.CalcShapeOutlineLayerOffsetVector;
          ActiveChildForm.ShapeOutlineLayer.Bitmap.Clear($00000000);

          with LShapeRegionLayerPanel do
          begin
            if ShapeOutlineList.Count > 0 then
            begin
              ShapeOutlineList.DrawAllOutlines(
                ActiveChildForm.ShapeOutlineLayer.Bitmap.Canvas,
                ActiveChildForm.OutlineOffsetVector, pmNotXor);

              if frmMain.ShapeRegionTool = srtMove then
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

      if frmMain.MainTool = gmtTextTool then
      begin
        if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
        begin
          LRichTextLayerPanel := TgmRichTextLayerPanel(
            ActiveChildForm.LayerPanelList.SelectedLayerPanel);

          if not Assigned(ActiveChildForm.RichTextHandleLayer) then
          begin
            ActiveChildForm.CreateRichTextLayer;
          end;

          ActiveChildForm.RichTextHandleLayer.Bitmap.Clear($00000000);

          LRichTextLayerPanel.DrawRichTextBorder(
            ActiveChildForm.RichTextHandleLayer.Bitmap.Canvas,
            ActiveChildForm.RichTextHandleLayerOffsetVector);

          LRichTextLayerPanel.DrawRichTextBorderHandles(
            ActiveChildForm.RichTextHandleLayer.Bitmap.Canvas,
            ActiveChildForm.RichTextHandleLayerOffsetVector);
        end;
      end;

      // update display
      ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
    end;
  end;
end;

//-- TgmRotateCanvasCommand ----------------------------------------------------

constructor TgmRotateCanvasCommand.Create(const ADeg: Integer;
  const ARotateDirection: TgmRotateDirection);
var
  LCommandDir: string;
  LGMDManager: TgmGMDManager;
begin
  inherited Create(caNone, 'Rotate Canvas');

  FOperateName     := 'Undo ' + FCommandName;
  FRotateDegrees   := ADeg;
  FRotateDirection := ARotateDirection;

  { Save all the data (layers, channels, paths) to disk for saving the
    system memory. And load them back when doing Undo operation. }

  // save the data at here
  LCommandDir := ExtractFileDir(ParamStr(0)) + '\History';

  if not DirectoryExists(LCommandDir) then
  begin
    CreateDir(LCommandDir);
  end;

  // get the file name
  FGMDFileName := LCommandDir + '\Undo' + IntToStr(GetTickCount);

  LGMDManager := TgmGMDManager.Create;
  try
    // link pointers to the gmd manager
    LGMDManager.LayerPanelList := ActiveChildForm.LayerPanelList;
    LGMDManager.ChannelManager := ActiveChildForm.ChannelManager;
    LGMDManager.PathPanelList  := ActiveChildForm.PathPanelList;

    LGMDManager.SaveToFile(FGMDFileName);
  finally
    LGMDManager.Free;
  end;
end;

destructor TgmRotateCanvasCommand.Destroy;
begin
  if FileExists(FGMDFileName) then
  begin
    DeleteFile(PChar(FGMDFileName));
  end;

  inherited Destroy;
end;

procedure TgmRotateCanvasCommand.Rollback;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  { First of all, we need to delete all the data, such as layers, channels and
    paths, in a child form which is currently activated, and then load the data
    back from the disk to retore the form to the state that before doing flatten
    command. }

  if Assigned(ActiveChildForm) then
  begin
    ActiveChildForm.LoadDataFromGMDFile(FGMDFileName);
  end;
end;

procedure TgmRotateCanvasCommand.Execute;
var
  LLayer                : TBitmapLayer;
  LShapeRegionLayerPanel: TgmShapeRegionLayerPanel;
  LRichTextLayerPanel   : TgmRichTextLayerPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  if Assigned(ActiveChildForm) then
  begin
    // rotate layers, first
    ActiveChildForm.LayerPanelList.RotateCanvasForAllLayers(
      ActiveChildForm.imgDrawingArea, FRotateDegrees, FRotateDirection,
      Color32(frmMain.GlobalBackColor) );

    ActiveChildForm.FLayerTopLeft := ActiveChildForm.GetLayerTopLeft;

    // rotate channels
    LLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[0]);

    ActiveChildForm.ChannelManager.RotateChannels(LLayer.Bitmap.Width,
      LLayer.Bitmap.Height, FRotateDegrees, FRotateDirection, LLayer.Location);

    if frmMain.MainTool = gmtShape then
    begin
      if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
      begin
        LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(
          ActiveChildForm.LayerPanelList.SelectedLayerPanel);

        if not Assigned(ActiveChildForm.ShapeOutlineLayer) then
        begin
          ActiveChildForm.CreateShapeOutlineLayer;
        end;

        ActiveChildForm.CalcShapeOutlineLayerOffsetVector;
        ActiveChildForm.ShapeOutlineLayer.Bitmap.Clear($00000000);

        with LShapeRegionLayerPanel do
        begin
          if ShapeOutlineList.Count > 0 then
          begin
            ShapeOutlineList.DrawAllOutlines(
              ActiveChildForm.ShapeOutlineLayer.Bitmap.Canvas,
              ActiveChildForm.OutlineOffsetVector, pmNotXor);

            if frmMain.ShapeRegionTool = srtMove then
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

    if frmMain.MainTool = gmtTextTool then
    begin
      if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
      begin
        LRichTextLayerPanel := TgmRichTextLayerPanel(
          ActiveChildForm.LayerPanelList.SelectedLayerPanel);

        if not Assigned(ActiveChildForm.RichTextHandleLayer) then
        begin
          ActiveChildForm.CreateRichTextLayer;
        end;

        ActiveChildForm.RichTextHandleLayer.Bitmap.Clear($00000000);

        LRichTextLayerPanel.DrawRichTextBorder(
          ActiveChildForm.RichTextHandleLayer.Bitmap.Canvas,
          ActiveChildForm.RichTextHandleLayerOffsetVector);

        LRichTextLayerPanel.DrawRichTextBorderHandles(
          ActiveChildForm.RichTextHandleLayer.Bitmap.Canvas,
          ActiveChildForm.RichTextHandleLayerOffsetVector);
      end;
    end;

    // update display
    ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
  end;
end;

//-- TgmCropComannd ------------------------------------------------------------

constructor TgmCropCommand.Create(const ACrop: TgmCrop);
var
  LCommandDir: string;
  LGMDManager: TgmGMDManager;
begin
  inherited Create(caNone, 'Crop');

  FOperateName := 'Undo ' + FCommandName;

  // remember the data of a crop tool
  FCropStart := ACrop.FCropStart;
  FCropEnd   := ACrop.FCropEnd;
  FResizeW   := ACrop.ResizeW;
  FResizeH   := ACrop.ResizeH;
  FResized   := ACrop.IsResized;

  { Save all the data (layers, channels, paths) to disk for saving the
    system memory. And load them back when doing Undo operation. }

  // save the data at here
  LCommandDir := ExtractFileDir(ParamStr(0)) + '\History';

  if not DirectoryExists(LCommandDir) then
  begin
    CreateDir(LCommandDir);
  end;

  // get the file name
  FGMDFileName := LCommandDir + '\Undo' + IntToStr(GetTickCount);

  LGMDManager := TgmGMDManager.Create;
  try
    // link pointers to the gmd manager
    LGMDManager.LayerPanelList := ActiveChildForm.LayerPanelList;
    LGMDManager.ChannelManager := ActiveChildForm.ChannelManager;
    LGMDManager.PathPanelList  := ActiveChildForm.PathPanelList;
    
    LGMDManager.SaveToFile(FGMDFileName);
  finally
    LGMDManager.Free;
  end;
end;

destructor TgmCropCommand.Destroy;
begin
  if FileExists(FGMDFileName) then
  begin
    DeleteFile(PChar(FGMDFileName));
  end;

  inherited Destroy;
end;

procedure TgmCropCommand.Rollback;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  { First of all, we need to delete all the data, such as layers, channels and
    paths, in a child form which is currently activated, and then load the data
    back from the disk to retore the form to the state that before doing flatten
    command. }

  if Assigned(ActiveChildForm) then
  begin
    ActiveChildForm.LoadDataFromGMDFile(FGMDFileName);
  end;
end; 

procedure TgmCropCommand.Execute;
var
  LCrop                 : TgmCrop;
  LNewWidth, LNewHeight : Integer;
  LLayer                : TBitmapLayer;
  LShapeRegionLayerPanel: TgmShapeRegionLayerPanel;
  LRichTextLayerPanel   : TgmRichTextLayerPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  // doing crop
  if Assigned(ActiveChildForm) then
  begin
    { Create a crop tool temporarily. We pass arbitrary parameters to the
      constructor, but the layer collection parameter should be correct. }
    LCrop := TgmCrop.Create(0, 0, ActiveChildForm.imgDrawingArea.Layers, FloatRect(0, 0, 0, 0));
    try
      LCrop.FCropStart := FCropStart;
      LCrop.FCropEnd   := FCropEnd;
      LCrop.ResizeW    := FResizeW;
      LCrop.ResizeH    := FResizeH;
      LCrop.IsResized  := FResized;

      if LCrop.IsResized then
      begin
        LNewWidth  := LCrop.ResizeW;
        LNewHeight := LCrop.ResizeH;
      end
      else
      begin
        LNewWidth  := LCrop.CropAreaWidth;
        LNewHeight := LCrop.CropAreaHeight;
      end;

      ActiveChildForm.imgDrawingArea.Bitmap.SetSize(LNewWidth, LNewHeight);

      ActiveChildForm.LayerPanelList.CropImageForAllLayers(
        ActiveChildForm.imgDrawingArea, LCrop, frmMain.GlobalBackColor);

      ActiveChildForm.FLayerTopLeft := ActiveChildForm.GetLayerTopLeft;

      // crop channels
      LLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[0]);
      ActiveChildForm.ChannelManager.CropChannels(LCrop, LLayer.Location);

      if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
      begin
        LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(
          ActiveChildForm.LayerPanelList.SelectedLayerPanel);

        if not Assigned(ActiveChildForm.ShapeOutlineLayer) then
        begin
          ActiveChildForm.CreateShapeOutlineLayer;
        end;

        ActiveChildForm.CalcShapeOutlineLayerOffsetVector;
        ActiveChildForm.ShapeOutlineLayer.Bitmap.Clear($00000000);

        with LShapeRegionLayerPanel do
        begin
          if ShapeOutlineList.Count > 0 then
          begin
            ShapeOutlineList.DrawAllOutlines(
              ActiveChildForm.ShapeOutlineLayer.Bitmap.Canvas,
              ActiveChildForm.OutlineOffsetVector, pmNotXor);
          end;
        end;
      end;

      if frmMain.MainTool = gmtTextTool then
      begin
        if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
        begin
          LRichTextLayerPanel := TgmRichTextLayerPanel(
            ActiveChildForm.LayerPanelList.SelectedLayerPanel);

          if not Assigned(ActiveChildForm.RichTextHandleLayer) then
          begin
            ActiveChildForm.CreateRichTextLayer;
          end;

          ActiveChildForm.RichTextHandleLayer.Bitmap.Clear($00000000);

          LRichTextLayerPanel.DrawRichTextBorder(
            ActiveChildForm.RichTextHandleLayer.Bitmap.Canvas,
            ActiveChildForm.RichTextHandleLayerOffsetVector);

          LRichTextLayerPanel.DrawRichTextBorderHandles(
            ActiveChildForm.RichTextHandleLayer.Bitmap.Canvas,
            ActiveChildForm.RichTextHandleLayerOffsetVector);
        end;
      end;

      // update display
      ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
    finally
      LCrop.Free;
    end;
  end;
end;

//-- TgmOptimalCropComannd -----------------------------------------------------

constructor TgmOptimalCropCommand.Create;
var
  LCommandDir: string;
  LGMDManager: TgmGMDManager;
begin
  inherited Create(caNone, 'Optimal Crop');

  FOperateName := 'Undo ' + FCommandName;

  { Save all the data (layers, channels, paths) to disk for saving the
    system memory. And load them back when doing Undo operation. }

  // save the data at here
  LCommandDir := ExtractFileDir(ParamStr(0)) + '\History';

  if not DirectoryExists(LCommandDir) then
  begin
    CreateDir(LCommandDir);
  end;

  // get the file name
  FGMDFileName := LCommandDir + '\Undo' + IntToStr(GetTickCount);

  LGMDManager := TgmGMDManager.Create;
  try
    // link pointers to the gmd manager
    LGMDManager.LayerPanelList := ActiveChildForm.LayerPanelList;
    LGMDManager.ChannelManager := ActiveChildForm.ChannelManager;
    LGMDManager.PathPanelList  := ActiveChildForm.PathPanelList;

    LGMDManager.SaveToFile(FGMDFileName);
  finally
    LGMDManager.Free;
  end;
end;

destructor TgmOptimalCropCommand.Destroy;
begin
  if FileExists(FGMDFileName) then
  begin
    DeleteFile(PChar(FGMDFileName));
  end;

  inherited Destroy;
end;

procedure TgmOptimalCropCommand.Rollback;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  { First of all, we need to delete all the data, such as layers, channels and
    paths, in a child form which is currently activated, and then load the data
    back from the disk to retore the form to the state that before doing flatten
    command. }

  if Assigned(ActiveChildForm) then
  begin
    ActiveChildForm.LoadDataFromGMDFile(FGMDFileName);
  end;
end;

procedure TgmOptimalCropCommand.Execute;
var
  LCroppedBmp          : TBitmap32;
  LCropArea, LBackRect : TRect;
  LTopLeft             : TPoint;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  if Assigned(ActiveChildForm) then
  begin
    with ActiveChildForm do
    begin
      if LayerPanelList.Count = 1 then
      begin
        LCroppedBmp := TBitmap32.Create;
        try
          // restore alpha channel, first
          if (LayerPanelList.SelectedLayerPanel.IsHasMask) and
             (LayerPanelList.SelectedLayerPanel.IsMaskLinked) then
          begin
            ReplaceAlphaChannelWithMask(
              LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
              LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
          end;

          // crop the layer and mask (if any)
          LCroppedBmp.Assign(LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
          LCropArea := OptimalCrop(LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap, LCroppedBmp);

          if (LCropArea.Right  > LCropArea.Left) and
             (LCropArea.Bottom > LCropArea.Top) then
          begin
            LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Assign(LCroppedBmp);
          end;

          LayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;

          if LayerPanelList.SelectedLayerPanel.IsHasMask then
          begin
            LayerPanelList.SelectedLayerPanel.CropMask(LCropArea);
            LayerPanelList.SelectedLayerPanel.UpdateMaskThumbnail;
          end;

          // set backgound
          imgDrawingArea.Bitmap.SetSize(
            LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
            LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height);

          // set layer location
          LBackRect := imgDrawingArea.GetBitmapRect;
          LTopLeft  := imgDrawingArea.ControlToBitmap( Point(LBackRect.Left, LBackRect.Top) );

          LayerPanelList.SelectedLayerPanel.AssociatedLayer.Location :=
            FloatRect(LTopLeft.X, LTopLeft.Y,
                      imgDrawingArea.Bitmap.Width,
                      imgDrawingArea.Bitmap.Height);

          FLayerTopLeft := GetLayerTopLeft;

          // crop channels
          ChannelManager.CropChannels(LCropArea,
            LayerPanelList.SelectedLayerPanel.AssociatedLayer.Location);

          LayerPanelList.SelectedLayerPanel.Update;

          IsImageProcessed := True;
        finally
          LCroppedBmp.Free;
        end;
      end;
    end;
  end;
end; 

end.
