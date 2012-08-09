{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }
                           
unit ChildForm;

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

{$WARN UNSAFE_CAST OFF}
{$WARN UNSAFE_CODE OFF}

interface

uses
{ Standard }
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ExtCtrls,
  StdCtrls,
  Menus,
  ImgList,
{ Graphics32 }
  GR32,
  GR32_Image,
  GR32_Layers,
{ GraphicsMagic Lib}
  gmTypes,
  gmSelection,
  gmLayerAndChannel,
  gmCrop,
  gmFigures,
  gmPenTools,        // Pen-Path Tools
  gmPathPanels,
  gmMeasure,
  gmMagneticLasso,
  gmRegions,
  gmCommands,
  gmHistoryManager,
  gmPenPathCommands,
  gmLayerPanelCommands;

type
  TfrmChild = class(TForm)
    tmrSpecialBrush: TTimer;
    tmrMarchingAnts: TTimer;
    pmnChangeCurveControlPoints: TPopupMenu;
    pmnitmCurveControlP1: TMenuItem;
    pmnitmCurveControlP2: TMenuItem;
    imglstChild: TImageList;
    imgDrawingArea: TImgView32;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tmrSpecialBrushTimer(Sender: TObject);
    procedure tmrMarchingAntsTimer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ChangeCurveControlPoints(Sender: TObject);
    procedure pmnChangeCurveControlPointsPopup(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure imgDrawingAreaDblClick(Sender: TObject);
    procedure imgDrawingAreaPaintStage(Sender: TObject; Buffer: TBitmap32;
      StageNum: Cardinal);
    procedure imgDrawingAreaResize(Sender: TObject);
    procedure imgDrawingAreaScroll(Sender: TObject);
  private
{ Common }
    FEditMode            : TgmEditMode;  // indicate which edit mode we are in
    FAccumTranslateVector: TPoint;       // accumulated translation vector
    FGlobalTopLeft       : TPoint;       // commonly used for save top-left position temporarily
    FGlobalBottomRight   : TPoint;       // commonly used for save bottom-right position temporarily
    FKeyIsDown           : Boolean;      // Mark that if we have pressed a key.
    FFileName            : string;       // the filename of the created/opened image file
    FImageProcessed      : Boolean;      // whether the image is modified
    FDrawing             : Boolean;      // whether the left button of the mouse is pressed
    FMayClick            : Boolean;      // whether we could define a polygon by single click the mouse left button
    FDoubleClicked       : Boolean;      // whether the left button of the mouse is double clicked
    FXActual             : Integer;      // actual x coordinate no matter what scale is used
    FYActual             : Integer;      // actual y coordinate no matter what scale is used
    FMarqueeX            : Integer;      // actual x coordinate on selection
    FMarqueeY            : Integer;      // actual y coordinate on selection
    FStartPoint          : TPoint;       // this field is for common use that may holding scaled/translated coordinates
    FEndPoint            : TPoint;       // this field is for common use that may holding scaled/translated coordinates
    FActualStartPoint    : TPoint;       // this field is for common use that may holding scaled but not translated coordinates
    FActualEndPoint      : TPoint;       // this field is for common use that may holding scaled but not translated coordinates
    FDrawingBasePoint    : TPoint;
    FPrevStrokePoint     : TPoint;
    FMagnification       : Integer;
    FPrevWheelDelta      : Integer;

    FLayerPanelList      : TgmLayerPanelList;
    FChannelManager      : TgmChannelManager;
    FHistoryManager      : TgmHistoryManager;  // Undo/Redo list
    FHistoryBitmap       : TBitmap32;

{ for Standard tools}
    FOldSelectedFigureInfoArray      : array of TgmFigureInfo; // For Undo/Redo
    FOldSelectedFigureLayerIndexArray: array of Integer;       // For Undo/Redo
    FOldFigure                       : TgmFigureObject;        // For Undo/Redo
    FCurvePoint1                     : TPoint;
    FCurvePoint2                     : TPoint;
    FActualCurvePoint1               : TPoint;
    FActualCurvePoint2               : TPoint;
    FDrawCurveTime                   : Integer;
    FPolygon                         : array of TPoint;
    FActualPolygon                   : array of TPoint;
    FMoveDrawingState                : TgmDrawingState;   // state of the Move tool
    FMoveDrawingHandle               : TgmDrawingHandle;
    FRegularBasePoint                : TPoint;
    FRegionSelectOK                  : Boolean;

{ for Brush tools }
    Felozox, Felozoy: Integer;
    Ftavolsag       : Double;
    FAimPoint       : TPoint;

{ for Measure tool }
    FMeasureLine         : TgmMeasureLine;
    FMeasureLayer        : TBitmapLayer;
    FMeasureLayerX       : Integer;
    FMeasureLayerY       : Integer;
    FMeasureDrawingState : TgmDrawingState;
    FMeasurePointSelector: TgmMeasurePointSelector;  // indicating current endpoint type of the measure line
    FMeasureOffsetVector : TPoint;
    
{ for Marquee tools}
    FSelection                       : TgmSelection;
    FSelectionCopy                   : TgmSelection;      // Used for selection undo/redo command.
    FSelectionHandleLayer            : TBitmapLayer;      // the layer for drawing selection handles
    FSelectionTranslateTarget        : TgmTranslateTarget;
    FMarqueeDrawingState             : TgmDrawingState;
    FMarqueeDrawingHandle            : TgmDrawingHandle;  // which handle the mouse is hovered
    FSelectionHandleLayerOffsetVector: TPoint;
    FRegion                          : TgmRegion;

    // Magnetic Lasso
    FMagneticLasso     : TgmMagneticLasso;
    FMagneticLassoLayer: TBitmapLayer;
    FLassoLayerOffsetX : Integer;
    FLassoLayerOffsetY : Integer;

{ for Transform tools }
    FSelectionTransformation : TgmSelectionTransformation;
    FTransformCopy           : TgmSelectionTransformation;  // Used for Undo/Redo
    FLastTransformMode       : TgmTransformMode;
    FTransformOffsetVector   : TPoint;
    FTransformLayer          : TBitmapLayer;                // used to drawing transform handles
    FTransformLayerX         : Integer;
    FTransformLayerY         : Integer;
    FTransformHandle         : TgmDrawingHandle;
    FRotateRadiansInMouseDown: Extended;
    FRotateRadiansInMouseMove: Extended;

{ for Crop tool }
    FCrop                       : TgmCrop;
    FCropHandleLayer            : TBitmapLayer;
    FCropDrawingState           : TgmDrawingState;
    FCropDrawingHandle          : TgmDrawingHandle;
    FCropHandleLayerOffsetVector: TPoint;

{ for Pen Path tools }
    FOldPathList          : TgmPenPathList;  // For Undo/Redo
    FOldPathIndex         : Integer;
    FOldPathListState     : TgmPathListState;
    FModifyPathMode       : TgmModifyPathMode;
    FPathPanelList        : TgmPathPanelList;
    FPathLayer            : TBitmapLayer;
    FPathOffsetVector     : TPoint;
    FPathLayerX           : Integer;
    FPathLayerY           : Integer;
    FPathSelectHandle     : TgmPathSelectHandle;
    FMouseDownX           : Integer;
    FMouseDownY           : Integer;
    FMouseMoveX           : Integer;
    FMouseMoveY           : Integer;
    FWholePathIndex       : Integer;       // index of whole selected path
    FOriginalPairState    : TgmPairState;  // indicating whether modify the direction line 1 and 2 simultaneously
    FOppositeLineOperation: TgmOppositeLineOperation;

{ for Shape Region tools }
    FShapeOutlineLayer  : TBitmapLayer;
    FOutlineOffsetVector: TPoint;
    FShapeDrawingHandle : TgmDrawingHandle;
    FShapeDrawingState  : TgmDrawingState;
    FRegionPolygon      : array [0 .. 99] of TPoint;

{ for Text tool }
    FRichTextHandleLayer            : TBitmapLayer;
    FRichTextHandleLayerOffsetVector: TPoint;
    FRichTextDrawingState           : TgmDrawingState;
    FRichTextDrawingHandle          : TgmDrawingHandle;

{ callback functions }
    // callback function for OnPixelCombine event
    procedure GrayNotXorLayerBlend(F: TColor32; var B: TColor32; M: TColor32);

    // callback function for double click on layer thumbnail
    procedure LayerThumbnailDblClick(Sender: TObject);

    // callback function for click on layer panel
    procedure LayerPanelClick(Sender: TObject);

    // callback function for click on layer thumbnail on layer panel
    procedure LayerThumbnailClick(Sender: TObject);

    // callback function for click on mask thumbnail on layer panel
    procedure MaskThumbnailClick(Sender: TObject);

    // callback function for add layer panel to list
    procedure AfterAddLayerPanelToList(Sender: TObject);

    // callback function for active a layer panel in list
    procedure AfterActiveLayerPanelInList(Sender: TObject);

    // callback function for delete selected layer panel from list
    procedure AfterDeleteSelectedLayerPanelFromList(Sender: TObject);

    // callback function for change color mode
    procedure ColorModeChanged(const AColorMode: TgmColorMode);

    // callback function for double click on alpha channel panels
    procedure AlphaChannelPanelDblClick(Sender: TObject);

    // callback function for double click on quick mask channel panel
    procedure QuickMaskPanelDblClick(Sender: TObject);

    // callback function for double click on layer mask channel panel
    procedure LayerMaskPanelDblClick(Sender: TObject);

    // callback function for right click on channel panels
    procedure ChannelPanelRightClick(Sender: TObject);

    // callback function for right click on quick mask channel panel
    procedure QuickMaskPanelRightClick(Sender: TObject);

    // callback function for right click on layer mask channel panel
    procedure LayerMaskPanelRightClick(Sender: TObject);

    // callback function for channel is changed
    procedure OnChannelChanged(const AIsChangeSelectionTarget: Boolean);

    // callback function for click on chain icon that on a layer panel
    procedure OnLayerChainImageClick(Sender: TObject; const ALayerPanelIndex: Integer);

    // callback function for click on path panel
    procedure PathPanelClick(Sender: TObject);

    // callback function for double-click on path panel
    procedure PathPanelDblClick(Sender: TObject);

    // callback function for do something when update path panel state
    procedure OnUpdatePathPanelState(Sender: TObject);

{ methods for Main form }
    procedure UpdateMainFormStatusBarWhenMouseDown;

    // refresh current shape region layer appearance
    procedure UpdateCurrentSelectedShapeRegionLayer;
    procedure UpdateCurrentSelectedTextLayer;

{ methods for Child form }
    procedure InitializeCanvas;
    procedure BeforeExit(Sender: TObject);  // confirm to save the last change to the image when exit the main program

    // Show/Hide assistant layer -- FHandleLayer, FCropHandleLayer, FPathLayer, FShapeOutlineLayer
    procedure SetAssistantLayerVisible(const IsVisible: Boolean);

{ Methods for Standard Tools }
    procedure FinishCurves;
    procedure FinishPolygon;
    procedure PreparePencil;

    procedure SetPencilStipplePattern(DestBmp: TBitmap32; const APenStyle: TPenStyle;
      const Color1, Color2: TColor32);

    // Adapted from RebuildBrush() which by Zoltan in gr32PaintDemo3.
    procedure BuildPencilStroke(const ADest: TBitmap32);
    
    // Adapted from BrushLine() which by Zoltan in gr32PaintDemo3.
    procedure PencilLine(const xStart, yStart, xEnd, yEnd, distance: Integer;
      ToBitmap: TBitmap32; const ChannelSet: TgmChannelSet);

    procedure PencilLineOnMask(const xStart, yStart, xEnd, yEnd, distance: Integer;
      const ChannelSet: TgmChannelSet);

    procedure ProcessFigureMouseUpOnLayer(const ShiftState: TShiftState);
    procedure ProcessFigureMouseUpOnSpecialChannels(const ShiftState: TShiftState);
    procedure ProcessFigureMouseUpOnSelection(const ShiftState: TShiftState);
    procedure ProcessFigureDoubleClickOnLayer;
    procedure ProcessFigureDoubleClickOnSpecialChannels;
    procedure ProcessFigureDoubleClickOnSelection;

    procedure FinishCurveOnLayer;
    procedure FinishCurveOnSpecialChannels;
    procedure FinishCurveOnSelection;

    procedure FinishPolygonOnLayer;
    procedure FinishPolygonOnSpecialChannels;
    procedure FinishPolygonOnSelection;

    procedure CreateFigureLayer(const AFigureFlag: TgmFigureFlags);

{ methods for Brush tools }
    procedure BrushLine(const xStart, yStart, xEnd, yEnd, distance: Integer;
      ToBitmap: TBitmap32; const ChannelSet: TgmChannelSet);

    procedure BrushLineOnMask(const xStart, yStart, xEnd, yEnd, distance: Integer;
      const ChannelSet: TgmChannelSet);
      
    procedure AirBrushLine(const xStart, yStart, xEnd, yEnd, distance: Integer;
      ToBitmap: TBitmap32; const ChannelSet: TgmChannelSet);
      
    procedure AirBrushLineOnMask(const xStart, yStart, xEnd, yEnd, distance: Integer;
      const ChannelSet: TgmChannelSet);
      
    procedure EraserLine(const xStart, yStart, xEnd, yEnd, distance: Integer;
      ToBitmap: TBitmap32; const ChannelSet: TgmChannelSet);
      
    procedure EraserLineOnMask(const xStart, yStart, xEnd, yEnd, distance: Integer;
      const ChannelSet: TgmChannelSet);

{ methods for Marquee tools }
    procedure FinishPolygonalSelection;
    procedure PauseMarchingAnts;     // pause drawing the Marching-Ants lines
    procedure CalcSelectionHandleLayerOffsetVector;

    // Magnetic Lasso 
    procedure CreateLassoLayer;
    procedure CalcLassoLayerOffsetVector;
    
{ methods for Transform tools }
    procedure CalcTransformLayerOffsetVector;
    procedure CalcTransformLayerCoord(X, Y: Integer);

{ methods for Crop tool }
    procedure CreateCropHandleLayer;
    procedure CalcCropHandleLayerOffsetVector;

{ methods for Measure tool}
    procedure CreateMeasureLayer;
    procedure CalcMeasureLayerCoord(const X, Y: Integer);
    procedure CalcMeasureLayerOffsetVector;

{ methods for Pen Path tools }
    procedure RecordOldPathDataForUndoRedo;     // Undo/Redo
    procedure CreateModifyPathUndoRedoCommand(const ModifyMode: TgmModifyPathMode);
    procedure CalcPathLayerCoord(X, Y: Integer);
    function GetPenToolDefaultCursor: TCursor;

{ methods for Shape Region tools }
    procedure CalcVertexForLineRegionOutline;

{ methods for Text tool }
    procedure CalcRichTextHandleLayerOffsetVector;

{ Mouse Events }
    // calculate the coordinate of the mouse on the layer
    procedure CalcLayerCoord(X, Y: Integer);

    { Calculate the coordinate of the mouse on the selection -- calling it after
      the CalcLayerCoord() method has been called for getting the right coordinate. }
    procedure CalcSelectionCoord;

{ events for standard tools }
    procedure PencilMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

    procedure PencilMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);

    procedure PencilMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

    procedure FigureToolsMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

    procedure FigureToolsMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);

    procedure FigureToolsMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

{ events for move figure tools }
    procedure MoveToolsMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

    procedure MoveToolsMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);

    procedure MoveToolsMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

{ events for brush tools }
    procedure BrushToolsMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

    procedure BrushToolsMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);

    procedure BrushToolsMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

{ events for marquee tools }
    procedure MarqueeToolsMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

    procedure MarqueeToolsMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);

    procedure MarqueeToolsMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

    // translate selection by keyboard strokes
    procedure TranslateSelectionKeyDown(var Key: Word; Shift: TShiftState);
    procedure TranslateSelectionKeyUp(var Key: Word; Shift: TShiftState);

{ events for gradient tools }
    procedure GradientToolsMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

    procedure GradientToolsMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);

    procedure GradientToolsMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

{ events for crop tool }
    procedure CropToolsMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

    procedure CropToolsMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);

    procedure CropToolsMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

    // translate crop area by keyboard strokes
    procedure TranslateCropKeyDown(var Key: Word; Shift: TShiftState);

{ events for paint bucket tools }
    procedure PaintBucketToolsMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

    procedure PaintBucketToolsMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);

    procedure PaintBucketToolsMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

{ events for eraser tools }
    procedure EraserToolsMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

    procedure EraserToolsMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);

    procedure EraserToolsMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

{ events for pen path tools  }
    procedure PenToolsMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

    procedure PenToolsMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);

    procedure PenToolsMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

{ events for measure tool }
    procedure MeasureToolsMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

    procedure MeasureToolsMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);

    procedure MeasureToolsMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

    // translate Measure Line by keyboard strokes
    procedure TranslateMeasureKeyDown(var Key: Word; Shift: TShiftState);
    procedure TranslateMeasureKeyUp(var Key: Word; Shift: TShiftState);

{ events for shape region tools }
    procedure ShapeRegionToolsMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

    procedure ShapeRegionToolsMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);

    procedure ShapeRegionToolsMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

    // translate shape regions by keyboard strokes
    procedure TranslateShapeRegionKeyDown(var Key: Word; Shift: TShiftState);
    procedure TranslateShapeRegionKeyUp(var Key: Word; Shift: TShiftState);

{ events for Transform tools}
    procedure TransformSelectionMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

    procedure TransformSelectionMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);

    procedure TransformSelectionMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

{ events for Text tool }
    procedure TextToolsMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

    procedure TextToolsMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);

    procedure TextToolsMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

    // translate Text by keyboard stroke
    procedure TranslateTextKeyDown(var Key: Word; Shift: TShiftState);
    procedure TranslateTextKeyUp(var Key: Word; Shift: TShiftState);

{ events for Eyedropper tool }

    procedure EyedropperMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

    procedure EyedropperMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);

    procedure EyedropperMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

{ events for Hand tool }

    procedure HandToolMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

    procedure HandToolMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);

    procedure HandToolMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

{ property methods }
    procedure SetEditMode(const Value: TgmEditMode);
  public
{ for child form }
    FLayerTopLeft: TPoint;

{ for Standard tools }
    FSelectedFigure         : TgmFigureObject; // pointer to the selected figure
    FHandleLayer            : TBitmapLayer;    // layer for drawing handles
    FHandleLayerOffsetVector: TPoint;
    
{ for Pen Path tools }
    FPenPath: TgmPenPath;    // point to current selected path

{ common }
    procedure UpdateThumbnailsBySelectedChannel;

{ methods for Child form }
    procedure SetupOnChildFormActivate;
    procedure ApplyMask(const ARect: TRect);           // apply mask to current selected layer
    procedure ApplyMaskByIndex(const AIndex: Integer); // apply mask to specified layer
    procedure ConnectMouseEventsToImage;
    procedure ChangeImageCursorByToolTemplets;
    procedure CreateBlankLayer;
    procedure CreateBlankLayerWithIndex(AIndex: Integer);
    procedure SaveNamedFile;
    procedure SaveFileWithNewName;
    procedure DeleteCurrentLayer;
    procedure CreateUndoRedoForDeleteLayer;
    procedure LoadDataFromGMDFile(const AFileName: string);
    procedure RefreshCaption;  // refresh the caption of this form

    function GetLayerTopLeft: TPoint; // get top left location of the current layer
    function GetCommandAimByCurrentChannel: TCommandAim;

{ channel methods }
    procedure LoadChannelAsSelection;  // channel to selection
    procedure LoadQuickMaskAsSelection;
    procedure UpdateChannelFormButtonsEnableState;

{ methods for Standard tools}
    procedure ChangeImageCursorByStandardTools;
    procedure CreateFigureHandleLayer;
    procedure DeleteFigureHandleLayer;
    procedure CalcHandleLayerOffsetVector;  // calculate the offset vector of the handle layer relative to current image layer
    procedure RecordOldFigureSelectedData;
    procedure CreateSelectFigureUndoRedo(const Mode: TgmSelectFigureMode);

{ methods for Marquee tools }
    procedure DrawMarchingAnts;      // draw the Marching-Ants lines
    procedure RemoveMarchingAnts;    // remove the Marching-Ants lines
    procedure DeleteSelectionHandleLayer;
    procedure CommitSelection;
    procedure CancelSelection;
    procedure DeleteSelection;
    procedure FreeSelection;         // just free the selection object and do nothing else
    procedure FreeCopySelection;
    procedure CreateNewSelection;
    procedure CreateCopySelection;
    procedure CreateSelectionForAll;
    procedure CreateSelectionByColorRange;
    procedure MakeSelectionInverse;
    function MakeSelectionFeather: Boolean;
    procedure ChangeSelectionTarget;
    procedure ShowProcessedSelection(const UpdateDisplay: Boolean = True);
    procedure ShowSelectionAtBrushStroke(const ARect: TRect);
    procedure CreateSelectionHandleLayer;
    procedure UpdateSelectionHandleBorder;
    procedure ShowSelectionHandleBorder;
    procedure ChangeImageCursorByMarqueeTools;

    // Magnetic Lasso
    procedure FinishMagneticLasso;

{ methods for Transform tools }
    procedure CreateSelectionTransformation(const AMode: TgmTransformMode);
    procedure FreeSelectionTransformation;
    procedure CreateTransformLayer;
    procedure DeleteTransformLayer;
    procedure ConnectTransformMouseEvents;
    procedure FinishTransformation;

{ methods for Crop tool }
    procedure CommitCrop;
    procedure CancelCrop;
    procedure FinishCrop;
    procedure ExecuteOptimalCrop;

{ methods for Eraser Tools }
    procedure ChangeImageCursorByEraserTools;

{ methods for Pen Path tools }
    procedure CreatePathLayer;
    procedure DeletePathLayer;
    procedure CalcPathLayerOffsetVector;
    procedure ChangeImageCursorByPenTools;
    procedure LoadPathAsSelection;  // Path to Selection

{ methods for Measure tool }
    procedure ShowMeasureResult;
    procedure DeleteMeasureLine;

{ methods for Shape Region tools }
    function CreateShapeRegionLayer: Boolean;
    procedure CreateShapeOutlineLayer;  // creating a layer for holding outlines of shape regions
    procedure DeleteShapeOutlineLayer;
    procedure DrawShapeOutline;
    procedure CalcShapeOutlineLayerOffsetVector;
    procedure ChangeImageCursorByShapeTools;
    
{ methods for Text tool }
    procedure CreateRichTextLayer;
    procedure CreateRichTextHandleLayer;  // creating a layer to draw a frame for Rich Text layer
    procedure DeleteRichTextHandleLayer;
    procedure UpdateRichTextHandleLayer;
    procedure CommitEdits;
    procedure CancelEdits;

    property LayerPanelList                  : TgmLayerPanelList          read FLayerPanelList;
    property ChannelManager                  : TgmChannelManager          read FChannelManager;
    property HistoryManager                  : TgmHistoryManager          read FHistoryManager;
    property MagneticLasso                   : TgmMagneticLasso           read FMagneticLasso;
    property HistoryBitmap                   : TBitmap32                  read FHistoryBitmap;
    property Selection                       : TgmSelection               read FSelection;
    property SelectionCopy                   : TgmSelection               read FSelectionCopy;
    property SelectionTransformation         : TgmSelectionTransformation read FSelectionTransformation;
    property TransformLayer                  : TBitmapLayer               read FTransformLayer;
    property EditMode                        : TgmEditMode                read FEditMode               write SetEditMode;
    property FileName                        : string                     read FFileName               write FFileName;
    property IsImageProcessed                : Boolean                    read FImageProcessed         write FImageProcessed;
    property IsMayClick                      : Boolean                    read FMayClick               write FMayClick;
    property Magnification                   : Integer                    read FMagnification          write FMagnification;
    property SelectionHandleLayer            : TBitmapLayer               read FSelectionHandleLayer;
    property SelectionHandleLayerOffsetVector: TPoint                     read FSelectionHandleLayerOffsetVector;
    property MarqueeDrawingState             : TgmDrawingState            read FMarqueeDrawingState    write FMarqueeDrawingState;
    property TransformOffsetVector           : TPoint                     read FTransformOffsetVector;
    property Crop                            : TgmCrop                    read FCrop;
    property CropHandleLayer                 : TBitmapLayer               read FCropHandleLayer;
    property CropHandleLayerOffsetVector     : TPoint                     read FCropHandleLayerOffsetVector;
    property PathLayer                       : TBitmapLayer               read FPathLayer;
    property PathOffsetVector                : TPoint                     read FPathOffsetVector;
    property PathPanelList                   : TgmPathPanelList           read FPathPanelList;
    property MeasureLine                     : TgmMeasureLine             read FMeasureLine;
    property MeasureLayer                    : TBitmapLayer               read FMeasureLayer;
    property ShapeOutlineLayer               : TBitmapLayer               read FShapeOutlineLayer;
    property OutlineOffsetVector             : TPoint                     read FOutlineOffsetVector;
    property ShapeDrawingState               : TgmDrawingState            read FShapeDrawingState      write FShapeDrawingState;
    property RichTextHandleLayer             : TBitmapLayer               read FRichTextHandleLayer;
    property RichTextHandleLayerOffsetVector : TPoint                     read FRichTextHandleLayerOffsetVector;
  end;

var
  frmChild: TfrmChild;

implementation

uses
{ Standard Lib }
  Math, GIFImage,
{ Graphics32 Lib }
  GR32_LowLevel,
{ externals }
  GR32_Add_BlendModes,         // BlendMode for layer blending
  ColorLibrary,                // Color Conversion Routines
  LineLibrary,                 // AddPoints(), SubtractPoints()...
{ GraphicsMagic Package Lib }
  gmGradientRender,
{ GraphicsMagic Lib }
  gmConstants,
  gmIni,
  gmIO,                        // LoadGraphicsFile(), SaveGraphicsFile()
  gmPaintFuncs,                // DrawCheckboardPattern()
  gmImageProcessFuncs,         // FlattenImageToBitmap32()...
  gmBlendModes,
  gmBrushes,
  gmConvolve,
  gmAlphaFuncs,                // Functions for alpha processing
  gmMath,
  gmPaintBucket,
  gmShapes,
  gmGMDFile,                   // used to ouput work flow to disk with extension name '.gmd'
  gmGUIFuncs,
  gmSelectionCommands,
  gmChannelCommands,
  gmCommonFuncs,
{ GraphicsMagic Data Modules }
  MainDataModule,
  HistoryDataModule,
  ChannelDataModule,
{ GraphicsMagic Forms/Dialogs }
  MainForm,
  HistoryForm,
  ColorForm,
  LayerForm,
  ChannelForm,
  PathForm,
  RichTextEditorForm,          // frmRichTextEditor
  PaintingBrushPopFrm,
  PatternsPopFrm,
  EraserAdvOptionsPopFrm,      // frmEraserAdvancedOptions
  BrushDynamicsPopFrm,         // frmBrushDynamics
  GradientPickerPopFrm,        // frmGradientPicker
  PaintBucketOptionsPopFrm,    // frmPaintBucketAdvancedOptions
  ColorRangeSelectionDlg,      // frmColorRangeSelection
  IndexedColorDlg,
  BrightnessContrastDlg,
  ChannelMixerDlg,
  ColorBalanceDlg,
  CurvesDlg,
  LevelsToolDlg,
  GradientFillDlg,
  GradientMapDlg,
  HueSaturationDlg,
  PatternFillDlg,
  PosterizeDlg,
  ThresholdDlg,
  ChannelOptionsDlg,
  SavePathDlg;

{$R *.DFM}

var
  MarchingAntsCounter     : Byte;
  MarchingAntsCounterStart: Byte;

//-- Custom procedures and functions -------------------------------------------

// MarchingAnts -- MovingDots
// plot the pixel of Marching-Ants lines, this method will pass to
// LineDDA API function as a parameter
procedure MarchingAnts(X, Y: Integer; ACanvas: TCanvas); stdcall;
begin
  if MarchingAntsCounter = $80  then // this check will avoid the Range Checking failed
  begin
    MarchingAntsCounter := 1;
  end
  else
  begin
    MarchingAntsCounter := MarchingAntsCounter shl 1; // Shift one bit left
  end;

  if (MarchingAntsCounter and $E0) > 0 then    // Any of the left 3 bits set?
  begin
    ACanvas.Pixels[X, Y] := clWhite;           // Erase the pixel
  end
  else
  begin
    ACanvas.Pixels[X, Y] := clBlack;           // Draw the pixel
  end;
end; 

function NormalizeRect(const ARectangle: TRect): TRect;
begin
  // This routine normalizes a rectangle by making sure that the (Left, Top)
  // coordinates are always above and to the left of the (Bottom, Right)
  // coordiantes.
  with ARectangle do
  begin
    if Left > Right then
    begin
      if Top > Bottom then
      begin
        Result := Rect(Right, Bottom, Left, Top);
      end
      else
      begin
        Result := Rect(Right, Top, Left, Bottom);
      end;
    end
    else
    begin
      if Top > Bottom then
      begin
        Result := Rect(Left, Bottom, Right, Top);
      end
      else
      begin
        Result := Rect(Left, Top, Right, Bottom);
      end;
    end;
  end
end;

procedure TfrmChild.SetEditMode(const Value: TgmEditMode);
begin
  if FEditMode <> Value then
  begin
    FEditMode := Value;

    case FEditMode of
      emStandardMode:
        begin
          LoadQuickMaskAsSelection;
          FChannelManager.DeleteQuickMask;
          ChangeSelectionTarget;
        end;

      emQuickMaskMode:
        begin
          if Assigned(FSelection) then
          begin
            FSelection.UpdateOriginalMaskWithResizedMask;
          end;

          if not Assigned(FChannelManager.QuickMaskPanel) then
          begin
            FChannelManager.CreateQuickMask(
              frmChannel.scrlbxChannelPanelContainer,
              imgDrawingArea.Layers, FLayerPanelList,
              FSelection);
          end;

          if Assigned(FSelection) then
          begin
            CommitSelection;
          end;
        end;
    end;

    UpdateChannelFormButtonsEnableState;
  end;
end;

// blending callback function for the OnPixelCombine event
procedure TfrmChild.GrayNotXorLayerBlend(F: TColor32; var B: TColor32;
  M: TColor32);
var
  LBlendColor: TColor32;
begin
  if F <> $00000000 then
  begin
    LBlendColor := not ($FF7F7F7F xor B);
    B           := LBlendColor or $FF000000;
  end;
end; 

// callback function for double click on layer thumbnail
procedure TfrmChild.LayerThumbnailDblClick(Sender: TObject);
var
  LFlattenedBmp     : TBitmap32;
  LHistoryStatePanel: TgmHistoryStatePanel;
  LLayerPanel       : TgmLayerPanel;
  LOldColor         : TColor;
begin
  LLayerPanel := nil;

  if not Assigned(Sender) then
  begin
    Exception.Create('TfrmChild.LayerThumbnailDblClick() -- parameter Sender is nil.');
  end;

  if (FSelectionTransformation <> nil) or
     (FCrop <> nil) or
     frmRichTextEditor.Visible then
  begin
    Exit;
  end;

  try
    LLayerPanel := TgmLayerPanel(Sender);
  except
    Exception.Create('TfrmChild.LayerThumbnailDblClick() -- Cannot convert Sender to TLayerPanel.');
  end;

//-- Brightness/Contrast LayerPanel --------------------------------------------
  if Sender is TgmBrightContrastLayerPanel then
  begin
    // open the Brightness/Contrast dialog
    frmBrightnessContrast := TfrmBrightnessContrast.Create(nil);
    try
      frmBrightnessContrast.IsWorkingOnEffectLayer := True;

      case frmBrightnessContrast.ShowModal of
        mrOK:
          begin
            // create undo/redo first
            LHistoryStatePanel := TgmBrightContrastLayerStatePanel.Create(
              frmHistory.scrlbxHistory,
              dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
              FLayerPanelList.CurrentIndex,
              LLayerPanel,
              lctModification);

            FHistoryManager.AddHistoryState(LHistoryStatePanel);

            // now save last settings
            TgmBrightContrastLayerPanel(Sender).SaveLastAdjustment;
          end;

        mrCancel:
          begin
            // restore previous settings
            TgmBrightContrastLayerPanel(Sender).RestoreLastAdjustment;
          end;
      end;

    finally
      FreeAndNil(frmBrightnessContrast);
    end;
  end
  else
//-- Channel Mixer Layer Panel -------------------------------------------------
  if Sender is TgmChannelMixerLayerPanel then
  begin
    // open Channel Mixer dialog
    frmChannelMixer := TfrmChannelMixer.Create(nil);
    try
      case frmChannelMixer.ShowModal of
        mrOK:
          begin
            // create undo/redo first
            LHistoryStatePanel := TgmChannelMixerLayerStatePanel.Create(
              frmHistory.scrlbxHistory,
              dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
              FLayerPanelList.CurrentIndex,
              LLayerPanel,
              lctModification);

            FHistoryManager.AddHistoryState(LHistoryStatePanel);

            // now save last settings
            TgmChannelMixerLayerPanel(Sender).SaveLastAdjustment;
          end;

        mrCancel:
          begin
            TgmChannelMixerLayerPanel(Sender).RestoreLastAdjustment;
          end;
      end;

    finally
      FreeAndNil(frmChannelMixer);
    end;
  end
  else
//-- Color Balance Layer Panel -------------------------------------------------
  if Sender is TgmColorBalanceLayerPanel then
  begin
    // open Color Balance dialog
    frmColorBalance := TfrmColorBalance.Create(nil);
    try
      case frmColorBalance.ShowModal of
        mrOK:
          begin
            // create undo/redo first
            LHistoryStatePanel := TgmColorBalanceLayerStatePanel.Create(
              frmHistory.scrlbxHistory,
              dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
              FLayerPanelList.CurrentIndex,
              LLayerPanel,
              lctModification);

            FHistoryManager.AddHistoryState(LHistoryStatePanel);

            // now save last settings
            TgmColorBalanceLayerPanel(Sender).SaveLastAdjustment;
          end;

        mrCancel:
          begin
            TgmColorBalanceLayerPanel(Sender).RestoreLastAdjustment;
          end;
      end;

    finally
      FreeAndNil(frmColorBalance);
    end;
  end
  else
//-- Curves Layer Panel --------------------------------------------------------
  if Sender is TgmCurvesLayerPanel then
  begin
    LFlattenedBmp := TBitmap32.Create;
    try
      LFlattenedBmp.SetSize(LLayerPanel.AssociatedLayer.Bitmap.Width,
                            LLayerPanel.AssociatedLayer.Bitmap.Height);

      LFlattenedBmp.Clear($00FFFFFF);

      FLayerPanelList.FlattenLayersToBitmap(LFlattenedBmp, dmBlend, 0,
                                            FLayerPanelList.CurrentIndex - 1);


      TgmCurvesLayerPanel(Sender).SetFlattenedLayer(LFlattenedBmp);
    finally
      LFlattenedBmp.Free;
    end;

    // open Curves dialog
    frmCurves := TfrmCurves.Create(nil);
    try
      frmCurves.IsWorkingOnEffectLayer := True;

      case frmCurves.ShowModal of
        mrOK:
          begin
            if not frmCurves.chckbxPreview.Checked then
            begin
              TgmCurvesLayerPanel(Sender).CurvesTool.LUTSetup(3);
            end;

            // Create undo/redo first.
            LHistoryStatePanel := TgmCurvesLayerStatePanel.Create(
              frmHistory.scrlbxHistory,
              dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
              FLayerPanelList.CurrentIndex,
              LLayerPanel,
              lctModification);

            FHistoryManager.AddHistoryState(LHistoryStatePanel);
          
            // now save last settings
            TgmCurvesLayerPanel(Sender).SaveLastAdjustment;
          end;

        mrCancel:
          begin
            TgmCurvesLayerPanel(Sender).RestoreLastAdjustment;
          end;
      end;
      
    finally
      FreeAndNil(frmCurves);
    end;
  end
  else
//-- Levels Layer Panel --------------------------------------------------------
  if Sender is TgmLevelsLayerPanel then
  begin
    LFlattenedBmp := TBitmap32.Create;
    try
      LFlattenedBmp.SetSize(LLayerPanel.AssociatedLayer.Bitmap.Width,
                            LLayerPanel.AssociatedLayer.Bitmap.Height);

      LFlattenedBmp.Clear($00FFFFFF);

      FLayerPanelList.FlattenLayersToBitmap(LFlattenedBmp, dmBlend, 0,
                                            FLayerPanelList.CurrentIndex - 1);

      TgmLevelsLayerPanel(Sender).SetFlattenedLayer(LFlattenedBmp);
    finally
      LFlattenedBmp.Free;
    end;

    frmLevelsTool := TfrmLevelsTool.Create(nil);
    try
      frmLevelsTool.IsWorkingOnEffectLayer := True;

      // open Levels dialog
      case frmLevelsTool.ShowModal of
        mrOK:
          begin
            if not frmLevelsTool.chckbxPreview.Checked then
            begin
              TgmLevelsLayerPanel(Sender).LevelsTool.LUTSetup(3);
            end;

            // create undo/redo first
            LHistoryStatePanel := TgmLevelsLayerStatePanel.Create(
              frmHistory.scrlbxHistory,
              dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
              FLayerPanelList.CurrentIndex,
              LLayerPanel,
              lctModification);

            FHistoryManager.AddHistoryState(LHistoryStatePanel);

            // now record the last adjustment
            TgmLevelsLayerPanel(Sender).SaveLastAdjustment;
          end;

        mrCancel:
          begin
            TgmLevelsLayerPanel(Sender).RestoreLastAdjustment;
          end;
      end;

    finally
      FreeAndNil(frmLevelsTool);
    end;
  end
  else
//-- Gradient Fill Layer Panel -------------------------------------------------
  if Sender is TgmGradientFillLayerPanel then
  begin
    // Open Gradient Fill dialog.
    case frmGradientFill.ShowModal of
      mrOK:
        begin
          // create undo/redo first
          LHistoryStatePanel := TgmGradientFillLayerStatePanel.Create(
            frmHistory.scrlbxHistory,
            dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
            FLayerPanelList.CurrentIndex,
            LLayerPanel,
            lctModification);

          FHistoryManager.AddHistoryState(LHistoryStatePanel);

          // now, save last settings
          TgmGradientFillLayerPanel(Sender).SaveLastAdjustment;
        end;

      mrCancel:
        begin
          TgmGradientFillLayerPanel(Sender).RestoreLastAdjustment;
        end;
    end;
  end
  else
//-- Gradient Map Layer Panel --------------------------------------------------
  if Sender is TgmGradientMapLayerPanel then
  begin
    // open Gradient Map dialog
    case frmGradientMap.ShowModal of
      mrOK:
        begin
          // create undo/redo first
          LHistoryStatePanel := TgmGradientMapLayerStatePanel.Create(
            frmHistory.scrlbxHistory,
            dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
            FLayerPanelList.CurrentIndex,
            LLayerPanel,
            lctModification);

          FHistoryManager.AddHistoryState(LHistoryStatePanel);

          // now save last settings
          TgmGradientMapLayerPanel(Sender).SaveLastAdjustment;
        end;

      mrCancel:
        begin
          TgmGradientMapLayerPanel(Sender).RestoreLastAdjustment;
        end;
    end;
  end
  else
//-- Hue/Saturation Layer Panel ------------------------------------------------
  if Sender is TgmHueSaturationLayerPanel then
  begin
    frmHueSaturation := TfrmHueSaturation.Create(nil);
    try
      case frmHueSaturation.ShowModal of
        mrOK:
          begin
            // create undo/redo first
            LHistoryStatePanel := TgmHLSLayerStatePanel.Create(
              frmHistory.scrlbxHistory,
              dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
              FLayerPanelList.CurrentIndex,
              LLayerPanel,
              lctModification);

            FHistoryManager.AddHistoryState(LHistoryStatePanel);

            // now save last settings
            TgmHueSaturationLayerPanel(Sender).SaveLastAdjustment;
          end;

        idCancel:
          begin
            TgmHueSaturationLayerPanel(Sender).RestoreLastAdjustment;
          end;
      end;
    finally
      FreeAndNil(frmHueSaturation);
    end;
  end
  else
//-- Pattern Fill Layer Panel --------------------------------------------------
  if Sender is TgmPatternLayerPanel then
  begin
    case frmPatternFill.ShowModal of
      mrOK:
        begin
          // create undo/redo first
          LHistoryStatePanel := TgmPatternLayerStatePanel.Create(
            frmHistory.scrlbxHistory,
            dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
            FLayerPanelList.CurrentIndex,
            LLayerPanel,
            lctModification);

          FHistoryManager.AddHistoryState(LHistoryStatePanel);

          // now save last settings
          TgmPatternLayerPanel(Sender).SaveLastAdjustment;
        end;

      mrCancel:
        begin
          TgmPatternLayerPanel(Sender).RestoreLastAdjustment;
        end;
    end;
  end
  else
//-- Posterize Layer Panel -----------------------------------------------------
  if Sender is TgmPosterizeLayerPanel then
  begin
    // open Posterize dialog
    frmPosterize := TfrmPosterize.Create(nil);
    try
      frmPosterize.IsWorkingOnEffectLayer := True;

      case frmPosterize.ShowModal of
        mrOK:
          begin
            // create undo/redo first
            LHistoryStatePanel := TgmPosterizeLayerStatePanel.Create(
              frmHistory.scrlbxHistory,
              dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
              FLayerPanelList.CurrentIndex,
              LLayerPanel,
              lctModification);

            FHistoryManager.AddHistoryState(LHistoryStatePanel);

            // now save last settings
            TgmPosterizeLayerPanel(Sender).SaveLastAdjustment;
          end;

        mrCancel:
          begin
            TgmPosterizeLayerPanel(Sender).RestoreLastAdjustment;
          end;
      end;
    finally
      FreeAndNil(frmPosterize);
    end;
  end
  else
//-- Threshold Layer Panel -----------------------------------------------------
  if Sender is TgmThresholdLayerPanel then
  begin
    // open Threshold dialog
    frmThreshold := TfrmThreshold.Create(nil);
    try
      frmThreshold.IsWorkingOnEffectLayer := True;

      case frmThreshold.ShowModal of
        mrOK:
          begin
            // create undo/redo first
            LHistoryStatePanel := TgmThresholdLayerStatePanel.Create(
              frmHistory.scrlbxHistory,
              dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
              FLayerPanelList.CurrentIndex,
              LLayerPanel,
              lctModification);

            FHistoryManager.AddHistoryState(LHistoryStatePanel);

            // now save the last settings
            TgmThresholdLayerPanel(Sender).SaveLastAdjustment;
          end;

        mrCancel:
          begin
            TgmThresholdLayerPanel(Sender).RestoreLastAdjustment;
          end;
      end;
    finally
      FreeAndNil(frmThreshold);
    end;
  end
  else
//-- Solid Color Layer Panel ---------------------------------------------------
  if Sender is TgmSolidColorLayerPanel then
  begin
    dmMain.clrdlgRGB.Color := TgmSolidColorLayerPanel(Sender).SolidColor;
  
    if dmMain.clrdlgRGB.Execute then
    begin
      // Undo/Redo
      LHistoryStatePanel := TgmSolidColorLayerStatePanel.Create(
        frmHistory.scrlbxHistory,
        dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
        FLayerPanelList.CurrentIndex,
        LLayerPanel,
        lctModification,
        dmMain.clrdlgRGB.Color);

      FHistoryManager.AddHistoryState(LHistoryStatePanel);

      // now, change color for this panel
      TgmSolidColorLayerPanel(Sender).SolidColor := dmMain.clrdlgRGB.Color;
    end;
  end
  else
//-- Rich Text Layer Panel -----------------------------------------------------
  if Sender is TgmRichTextLayerPanel then
  begin
    // change the main tool to Text tool, if necessary
    if frmMain.MainTool <> gmtTextTool then
    begin
      frmMain.spdbtnTextTool.Down := True;
      frmMain.ChangeMainToolClick(frmMain.spdbtnTextTool);
    end;

    // change the text layer state to Modify state
    if TgmRichTextLayerPanel(Sender).TextLayerState <> tlsModify then
    begin
      TgmRichTextLayerPanel(Sender).TextLayerState := tlsModify;
    end;

    if frmRichTextEditor.Visible = False then
    begin
      TgmRichTextLayerPanel(Sender).RichTextStream.Position := 0;

      frmRichTextEditor.rchedtRichTextEditor.Lines.LoadFromStream(
        TgmRichTextLayerPanel(Sender).RichTextStream );
        
      TgmRichTextLayerPanel(Sender).IsTextChanged := False;
    end;
  
    frmRichTextEditor.Show;
    frmMain.UpdateTextOptions;
  end
  else
//-- Shape Region Layer Panel --------------------------------------------------
  if Sender is TgmShapeRegionLayerPanel then
  begin
    LOldColor              := TgmShapeRegionLayerPanel(Sender).RegionColor;
    dmMain.clrdlgRGB.Color := TgmShapeRegionLayerPanel(Sender).RegionColor;

    if dmMain.clrdlgRGB.Execute then
    begin
      TgmShapeRegionLayerPanel(Sender).RegionColor := dmMain.clrdlgRGB.Color;

      // Undo/Redo
      LHistoryStatePanel := TgmModifyShapeRegionColorStatePanel.Create(
        frmHistory.scrlbxHistory,
        dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
        LOldColor,
        TgmShapeRegionLayerPanel(Sender).RegionColor);

      FHistoryManager.AddHistoryState(LHistoryStatePanel);
    end;
  end;
//------------------------------------------------------------------------------

  if Assigned(FSelection) then
  begin
    ShowSelectionHandleBorder;
  end;

  LLayerPanel.AssociatedLayer.Bitmap.Changed;
end; 

// callback function for click on layer panel
procedure TfrmChild.LayerPanelClick(Sender: TObject);
var
  LClickedIndex: Integer;
begin
  if (FSelectionTransformation <> nil) or
     (FCrop <> nil) or
     frmRichTextEditor.Visible then
  begin
    Exit;
  end;

  if FLayerPanelList.Count > 0 then
  begin
    LClickedIndex := FLayerPanelList.GetClickedLayerPanelIndex(Sender);

    if LClickedIndex >= 0 then
    begin
      if LClickedIndex <> FLayerPanelList.CurrentIndex then
      begin
        // deselect all figures
        if High(FLayerPanelList.FSelectedFigureInfoArray) > (-1) then
        begin
          FLayerPanelList.DeselectAllFiguresOnFigureLayer;

          if Assigned(FHandleLayer) then
          begin
            FreeAndNil(FHandleLayer);
          end;
        end;

        // switch layer panel
        FLayerPanelList.ActiveLayerPanel(LClickedIndex);

        // on special layers...
        if not (FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                  lfBackground, lfTransparent, lfFigure]) then
        begin
          // if not in Quick Mask mode...
          if FChannelManager.CurrentChannelType <> wctQuickMask then
          begin
            FChannelManager.SelectLayerMask;
          end;
        end;
      end
      else
      begin
        // if not in Quick Mask mode...
        if not Assigned(FChannelManager.QuickMaskPanel) then
        begin
          if (Sender = FLayerPanelList.SelectedLayerPanel.Panel) or
             (Sender = FLayerPanelList.SelectedLayerPanel.LayerName) then
          begin
            // if on "normal" layers...
            if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                 lfBackground, lfTransparent, lfFigure] then
            begin
              if FChannelManager.CurrentChannelType in [wctAlpha, wctLayerMask] then
              begin
                FChannelManager.DeselectAllChannels(True);
                FChannelManager.SelectAllColorChannels;
                FChannelManager.ChannelPreviewLayer.Changed;

                if Assigned(FSelection) then
                begin
                  ChangeSelectionTarget;
                  UpdateSelectionHandleBorder;
                end;
              end;
            end
            else
            begin
              // if on special layers...
              if FLayerPanelList.SelectedLayerPanel.IsHasMask then
              begin
                if FChannelManager.CurrentChannelType <> wctLayerMask then
                begin
                  FChannelManager.SelectLayerMask;
                end;
              end;
            end;

            FLayerPanelList.UpdatePanelsState;

            // update layer form
            frmLayer.UpdateLayerOptions(FLayerPanelList.SelectedLayerPanel);

            // update color form
            if FChannelManager.CurrentChannelType in
                 [wctRGB, wctRed, wctGreen, wctBlue] then
            begin
              frmColor.ColorMode := cmRGB;
            end
            else
            begin
              frmColor.ColorMode := cmGrayscale;
            end;
          end;
        end;
      end;

      UpdateCurrentSelectedShapeRegionLayer;
      UpdateCurrentSelectedTextLayer;

      // synchronize settings
      FLayerPanelList.SynchronizeIndex;
      FLayerPanelList.SelectedLayerPanel.SynchronizeProcessStage;
    end;
  end;
end;

// callback function for click on layer thumbnail on layer panel
procedure TfrmChild.LayerThumbnailClick(Sender: TObject);
var
  LClickedIndex: Integer;
begin
  if (FSelectionTransformation <> nil) or
     (FCrop <> nil) or
     frmRichTextEditor.Visible then
  begin
    Exit;
  end;

  if FLayerPanelList.Count > 0 then
  begin
    LClickedIndex := FLayerPanelList.GetClickedLayerPanelIndex(Sender);

    if LClickedIndex >= 0 then
    begin
      if LClickedIndex <> FLayerPanelList.CurrentIndex then
      begin
        FLayerPanelList.ActiveLayerPanel(LClickedIndex); // switch layer panel

        // on special layers...
        if not (FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                  lfBackground, lfTransparent, lfFigure]) then
        begin
          // if not in Quick Mask mode...
          if FChannelManager.CurrentChannelType <> wctQuickMask then
          begin
            FChannelManager.SelectLayerMask;
          end;
        end;
      end
      else
      begin
        // if not in Quick Mask mode...
        if not Assigned(FChannelManager.QuickMaskPanel) then
        begin
          if (Sender = FLayerPanelList.SelectedLayerPanel.LayerImage) or
             (Sender = FLayerPanelList.SelectedLayerPanel.LayerImageHolder) then
          begin
            // if on "normal" layers...
            if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                 lfBackground, lfTransparent, lfFigure] then
            begin
              if FChannelManager.CurrentChannelType in [wctAlpha, wctLayerMask] then
              begin
                FChannelManager.DeselectAllChannels(True);
                FChannelManager.SelectAllColorChannels;
                FChannelManager.ChannelPreviewLayer.Changed;

                if Assigned(FSelection) then
                begin
                  ChangeSelectionTarget;
                  UpdateSelectionHandleBorder;
                end;
              end
              else
              if FChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue] then
              begin
                if FChannelManager.SelectedColorChannelCount < 3 then
                begin
                  FChannelManager.SelectAllColorChannels;
                  FChannelManager.ChannelPreviewLayer.Changed;
                end;
              end;
            end
            else
            begin
              // if on special layers...
              if FLayerPanelList.SelectedLayerPanel.IsHasMask then
              begin
                if FChannelManager.CurrentChannelType <> wctLayerMask then
                begin
                  FChannelManager.SelectLayerMask;
                end;
              end
              else
              begin
                if FChannelManager.SelectedColorChannelCount < 3 then
                begin
                  FChannelManager.SelectAllColorChannels;
                  FChannelManager.ChannelPreviewLayer.Changed;
                end;
              end;
            end;

            FLayerPanelList.UpdatePanelsState;

            // update layer form
            frmLayer.UpdateLayerOptions(FLayerPanelList.SelectedLayerPanel);

            // update color form
            if FChannelManager.CurrentChannelType in
                 [wctRGB, wctRed, wctGreen, wctBlue] then
            begin
              frmColor.ColorMode := cmRGB;
            end
            else
            begin
              frmColor.ColorMode := cmGrayscale;
            end;
          end;
        end;
      end;

      UpdateCurrentSelectedShapeRegionLayer;
      UpdateCurrentSelectedTextLayer;

      // synchronize settings
      FLayerPanelList.SynchronizeIndex;
      FLayerPanelList.SelectedLayerPanel.SynchronizeProcessStage;
    end;
  end;
end;

// callback function for click on mask thumbnail on layer panel
procedure TfrmChild.MaskThumbnailClick(Sender: TObject);
var
  LClickedIndex: Integer;
begin
  if (FSelectionTransformation <> nil) or
     (FCrop <> nil) or
     frmRichTextEditor.Visible then
  begin
    Exit;
  end;

  if FLayerPanelList.Count > 0 then
  begin
    LClickedIndex := FLayerPanelList.GetClickedLayerPanelIndex(Sender);

    if LClickedIndex >= 0 then
    begin
      if LClickedIndex <> FLayerPanelList.CurrentIndex then
      begin
        FLayerPanelList.ActiveLayerPanel(LClickedIndex); // switch layer panel

        if FChannelManager.CurrentChannelType <> wctQuickMask then
        begin
          FChannelManager.SelectLayerMask;
        end;
      end
      else
      begin
        // if not in Quick Mask mode...
        if not Assigned(FChannelManager.QuickMaskPanel) then
        begin
          if (Sender = FLayerPanelList.SelectedLayerPanel.FMaskImage) or
             (Sender = FLayerPanelList.SelectedLayerPanel.MaskImageHolder) then
          begin
            if FChannelManager.CurrentChannelType <> wctLayerMask then
            begin
              FChannelManager.SelectLayerMask;
            end;
          end;
        end;
      end;

      // update layer form
      frmLayer.UpdateLayerOptions(FLayerPanelList.SelectedLayerPanel);

      // update color form
      if FChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue] then
      begin
        frmColor.ColorMode := cmRGB;
      end
      else
      begin
        frmColor.ColorMode := cmGrayscale;
      end;

      // synchronize settings
      FLayerPanelList.SynchronizeIndex;
      FLayerPanelList.SelectedLayerPanel.SynchronizeProcessStage;
    end;
  end;
end;

// callback function for add layer panel to list
procedure TfrmChild.AfterAddLayerPanelToList(Sender: TObject);
begin
  if FLayerPanelList.Count > 0 then
  begin
    // associate this layer panel to the channel manager
    FChannelManager.AssociateToLayerPanel(FLayerPanelList.SelectedLayerPanel);

    if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
         lfBackground, lfTransparent, lfFigure, lfShapeRegion, lfRichText] then
    begin
      FChannelManager.DeselectAllChannels(True);
      FChannelManager.SelectAllColorChannels;
    end;

    FLayerPanelList.UpdatePanelsState;

    if FLayerPanelList.IsAllowRefreshLayerPanels then
    begin
      FLayerPanelList.HideAllLayerPanels;
      FLayerPanelList.ShowAllLayerPanels;
    end;

    if Assigned(FSelection) then
    begin
      case FChannelManager.CurrentChannelType of
        wctAlpha, wctQuickMask, wctLayerMask:
          begin
            ChangeSelectionTarget;
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                 lfBackground, lfTransparent] then
            begin
              ChangeSelectionTarget;
            end;
          end;
      end;

      UpdateSelectionHandleBorder;
    end;

    // update layers form
    frmLayer.UpdateLayerOptions(FLayerPanelList.SelectedLayerPanel);

    // update color form
    if (FChannelManager.CurrentChannelType in
          [wctRGB, wctRed, wctGreen, wctBlue]) then
    begin
      frmColor.ColorMode := cmRGB;
    end
    else
    begin
      frmColor.ColorMode := cmGrayscale;
    end;
  end;
end;

// callback function for active a layer panel in list
procedure TfrmChild.AfterActiveLayerPanelInList(Sender: TObject);
begin
  if FLayerPanelList.Count > 0 then
  begin
    if frmLayer.Visible and frmLayer.Floating then
    begin
      FLayerPanelList.SelectedLayerPanel.Panel.SetFocus;
    end;

    // associate this layer panel to the channel manager
    FChannelManager.AssociateToLayerPanel(FLayerPanelList.SelectedLayerPanel);
    FLayerPanelList.UpdatePanelsState;

    // switch selection target
    if Assigned(FSelection) then
    begin
      if (FChannelManager.CurrentChannelType in [
            wctAlpha, wctQuickMask, wctLayerMask]) then
      begin
        ChangeSelectionTarget;
      end
      else
      if (FChannelManager.CurrentChannelType in [
            wctRGB, wctRed, wctGreen, wctBlue]) then
      begin
        if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
             lfBackground, lfTransparent] then
        begin
          ChangeSelectionTarget;
        end;
      end;

      UpdateSelectionHandleBorder;
    end;

    // update layer form
    frmLayer.UpdateLayerOptions(FLayerPanelList.SelectedLayerPanel);
  end;

  // update color form
  if (FChannelManager.CurrentChannelType in
        [wctRGB, wctRed, wctGreen, wctBlue]) then
  begin
    frmColor.ColorMode := cmRGB;
  end
  else
  begin
    frmColor.ColorMode := cmGrayscale;
  end;
end;

// callback function for delete selected layer panel from list
procedure TfrmChild.AfterDeleteSelectedLayerPanelFromList(Sender: TObject);
var
  LShapeRegionLayerPanel: TgmShapeRegionLayerPanel;
begin
  if FLayerPanelList.Count > 0 then
  begin
    frmLayer.ggbrLayerOpacity.Position :=
      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.MasterAlpha;

    // associated the panel to channel manager, again
    FChannelManager.AssociateToLayerPanel(FLayerPanelList.SelectedLayerPanel);
    FLayerPanelList.UpdatePanelsState;

    if Assigned(FSelection) then
    begin
      case FChannelManager.CurrentChannelType of
        wctLayerMask:
          begin
            // switch the selection to work on this layer
            tmrMarchingAnts.Enabled := False;
            ChangeSelectionTarget;
            tmrMarchingAnts.Enabled := True;
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                 lfBackground, lfTransparent] then
            begin
              // switch the selection to work on this layer
              tmrMarchingAnts.Enabled := False;
              ChangeSelectionTarget;
              tmrMarchingAnts.Enabled := True;
            end;
          end;
      end;

      // update selection border
      UpdateSelectionHandleBorder;
    end;

    if FLayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
    begin
      if not Assigned(FShapeOutlineLayer) then
      begin
        CreateShapeOutlineLayer;
      end;

      if Assigned(FShapeOutlineLayer) then
      begin
        FShapeOutlineLayer.Bitmap.Clear($00000000);
        LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(FLayerPanelList.SelectedLayerPanel);

        LShapeRegionLayerPanel.ShapeOutlineList.DrawAllOutlines(
          FShapeOutlineLayer.Bitmap.Canvas, FOutlineOffsetVector, pmNotXor);

        if frmMain.ShapeRegionTool = srtMove then
        begin
          LShapeRegionLayerPanel.ShapeOutlineList.BackupCoordinates;

          LShapeRegionLayerPanel.ShapeOutlineList.DrawShapesBoundary(
            FShapeOutlineLayer.Bitmap.Canvas, HANDLE_RADIUS,
            FOutlineOffsetVector, pmNotXor);

          LShapeRegionLayerPanel.ShapeOutlineList.DrawShapesBoundaryHandles(
            FShapeOutlineLayer.Bitmap.Canvas, HANDLE_RADIUS,
            FOutlineOffsetVector, pmNotXor);
        end;

        LShapeRegionLayerPanel.IsDismissed := False;
        FShapeOutlineLayer.Bitmap.Changed;
        frmMain.UpdateShapeOptions;
      end
    end
    else
    begin
      if Assigned(FShapeOutlineLayer) then
      begin
        DeleteShapeOutlineLayer;
      end;
    end;

    // update layer form
    frmLayer.UpdateLayerOptions(FLayerPanelList.SelectedLayerPanel);
  end;

  // update color form
  case FChannelManager.CurrentChannelType of
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

// callback function for change color mode
procedure TfrmChild.ColorModeChanged(const AColorMode: TgmColorMode);
begin
  frmColor.ColorMode := AColorMode;
end;

// callback function for double click on alpha channel panels
procedure TfrmChild.AlphaChannelPanelDblClick(Sender: TObject);
var
  LOptionsHistoryData: TgmChannelOptionsHistoryData;
  LHistoryStatePanel : TgmHistoryStatePanel;
begin
  if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
  begin
    if FChannelManager.SelectedAlphaChannelPanel.IfClickOnPanel(Sender) then
    begin
      frmChannelOptions := TfrmChannelOptions.Create(nil);
      try
        frmChannelOptions.edtChannelName.Text           := FChannelManager.SelectedAlphaChannelPanel.ChannelName;
        frmChannelOptions.shpMaskColor.Brush.Color      := WinColor(FChannelManager.SelectedAlphaChannelPanel.MaskColor);
        frmChannelOptions.MaskOpacityPercent            := FChannelManager.SelectedAlphaChannelPanel.MaskOpacityPercent;
        frmChannelOptions.rdgrpColorIndicator.ItemIndex := Ord(FChannelManager.SelectedAlphaChannelPanel.MaskColorIndicator);

        // for Undo command
        LOptionsHistoryData.OldChannelName    := FChannelManager.SelectedAlphaChannelPanel.ChannelName;
        LOptionsHistoryData.OldMaskColor      := FChannelManager.SelectedAlphaChannelPanel.MaskColor;
        LOptionsHistoryData.OldOpacityPercent := FChannelManager.SelectedAlphaChannelPanel.MaskOpacityPercent;
        LOptionsHistoryData.OldColorIndicator := FChannelManager.SelectedAlphaChannelPanel.MaskColorIndicator;

        if frmChannelOptions.ShowModal = mrOK then
        begin
          with FChannelManager.SelectedAlphaChannelPanel do
          begin
            ChannelName        := frmChannelOptions.edtChannelName.Text;
            MaskOpacityPercent := frmChannelOptions.MaskOpacityPercent;
            MaskColorIndicator := TgmMaskColorIndicator(frmChannelOptions.rdgrpColorIndicator.ItemIndex);
            MaskColor          := Color32(frmChannelOptions.shpMaskColor.Brush.Color);

            // make a global copy of the mask color
            FChannelManager.GlobalMaskColor := MaskColor;
          end;

          // for Redo command
          LOptionsHistoryData.NewChannelName    := FChannelManager.SelectedAlphaChannelPanel.ChannelName;
          LOptionsHistoryData.NewMaskColor      := FChannelManager.SelectedAlphaChannelPanel.MaskColor;
          LOptionsHistoryData.NewOpacityPercent := FChannelManager.SelectedAlphaChannelPanel.MaskOpacityPercent;
          LOptionsHistoryData.NewColorIndicator := FChannelManager.SelectedAlphaChannelPanel.MaskColorIndicator;

          LHistoryStatePanel := TgmAlphaChannelOptionsStatePanel.Create(
              frmHistory.scrlbxHistory,
              dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
              FChannelManager.SelectedAlphaChannelIndex,
              LOptionsHistoryData);

          FHistoryManager.AddHistoryState(LHistoryStatePanel);
        end;
      finally
        FreeAndNil(frmChannelOptions);
      end;
    end;
  end;
end;

// callback function for double click on quick mask channel panel
procedure TfrmChild.QuickMaskPanelDblClick(Sender: TObject);
var
  LOptionsHistoryData: TgmChannelOptionsHistoryData;
  LHistoryStatePanel : TgmHistoryStatePanel;
begin
  if Assigned(FChannelManager.QuickMaskPanel) then
  begin
    if FChannelManager.QuickMaskPanel.IfClickOnPanel(Sender) then
    begin
      frmChannelOptions := TfrmChannelOptions.Create(nil);
      try
        frmChannelOptions.ChannelProcessType            := cptQuickMask;
        frmChannelOptions.shpMaskColor.Brush.Color      := WinColor(FChannelManager.QuickMaskColor);
        frmChannelOptions.MaskOpacityPercent            := FChannelManager.QuickMaskOpacityPercent;
        frmChannelOptions.rdgrpColorIndicator.ItemIndex := Ord(FChannelManager.QuickMaskColorIndicator);

        // for Undo command
        LOptionsHistoryData.OldMaskColor      := FChannelManager.QuickMaskPanel.MaskColor;
        LOptionsHistoryData.OldOpacityPercent := FChannelManager.QuickMaskPanel.MaskOpacityPercent;
        LOptionsHistoryData.OldColorIndicator := FChannelManager.QuickMaskPanel.MaskColorIndicator;

        if frmChannelOptions.ShowModal = mrOK then
        begin
          FChannelManager.QuickMaskOpacityPercent := frmChannelOptions.MaskOpacityPercent;
          FChannelManager.QuickMaskColorIndicator := TgmMaskColorIndicator(frmChannelOptions.rdgrpColorIndicator.ItemIndex);
          FChannelManager.QuickMaskColor          := Color32(frmChannelOptions.shpMaskColor.Brush.Color);

          FChannelManager.QuickMaskPanel.MaskOpacityPercent := FChannelManager.QuickMaskOpacityPercent;
          FChannelManager.QuickMaskPanel.MaskColorIndicator := FChannelManager.QuickMaskColorIndicator;
          FChannelManager.QuickMaskPanel.MaskColor          := FChannelManager.QuickMaskColor;

          // for Redo command
          LOptionsHistoryData.NewMaskColor      := FChannelManager.QuickMaskPanel.MaskColor;
          LOptionsHistoryData.NewOpacityPercent := FChannelManager.QuickMaskPanel.MaskOpacityPercent;
          LOptionsHistoryData.NewColorIndicator := FChannelManager.QuickMaskPanel.MaskColorIndicator;

          LHistoryStatePanel := TgmQuickMaskOptionsStatePanel.Create(
            frmHistory.scrlbxHistory,
            dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
            FChannelManager.QuickMaskPanel,
            LOptionsHistoryData);

          FHistoryManager.AddHistoryState(LHistoryStatePanel);
        end;
      finally
        FreeAndNil(frmChannelOptions);
      end;
    end;
  end;
end;

// callback function for double click on layer mask channel panel
procedure TfrmChild.LayerMaskPanelDblClick(Sender: TObject);
begin
  if Assigned(FChannelManager.LayerMaskPanel) then
  begin
    if FChannelManager.LayerMaskPanel.IfClickOnPanel(Sender) then
    begin
      frmChannelOptions := TfrmChannelOptions.Create(nil);
      try
        frmChannelOptions.edtChannelName.Text      := FChannelManager.LayerMaskPanel.ChannelName;
        frmChannelOptions.ChannelProcessType       := cptLayerMask;
        frmChannelOptions.shpMaskColor.Brush.Color := WinColor(FChannelManager.LayerMaskColor);
        frmChannelOptions.MaskOpacityPercent       := FChannelManager.LayerMaskOpacityPercent;

        if frmChannelOptions.ShowModal = mrOK then
        begin
          FChannelManager.LayerMaskOpacityPercent := frmChannelOptions.MaskOpacityPercent;
          FChannelManager.LayerMaskColor          := Color32(frmChannelOptions.shpMaskColor.Brush.Color);

          FChannelManager.LayerMaskPanel.MaskOpacityPercent := FChannelManager.LayerMaskOpacityPercent;
          FChannelManager.LayerMaskPanel.MaskColor          := FChannelManager.LayerMaskColor;
        end;
      finally
        FreeAndNil(frmChannelOptions);
      end;
    end;
  end;
end;

// callback function for right click on channel panels
procedure TfrmChild.ChannelPanelRightClick(Sender: TObject);
var
  LCursorPos: TPoint;
begin
  dmChannel.mnitmDuplicateChannel.Enabled := (FChannelManager.CurrentChannelType <> wctRGB) and
                                             (FChannelManager.AlphaChannelPanelList.Count < MAX_ALPHA_CHANNEL_COUNT);

  dmChannel.mnitmDeleteChannel.Enabled := (FChannelManager.CurrentChannelType = wctAlpha);

  GetCursorPos(LCursorPos);
  dmChannel.pmnChannelOptions.Popup(LCursorPos.X, LCursorPos.Y);
end; 

// callback function for right click on quick mask channel panel
procedure TfrmChild.QuickMaskPanelRightClick(Sender: TObject);
var
  LCursorPos: TPoint;
begin
  dmChannel.mnitmDuplicateChannel.Enabled := (FChannelManager.AlphaChannelPanelList.Count < MAX_ALPHA_CHANNEL_COUNT);
  dmChannel.mnitmDeleteChannel.Enabled    := True;

  GetCursorPos(LCursorPos);
  dmChannel.pmnChannelOptions.Popup(LCursorPos.X, LCursorPos.Y);
end;

// callback function for right click on layer mask channel panel
procedure TfrmChild.LayerMaskPanelRightClick(Sender: TObject);
var
  LCursorPos: TPoint;
begin
  dmChannel.mnitmDuplicateChannel.Enabled := True;
  dmChannel.mnitmDeleteChannel.Enabled    := True;

  GetCursorPos(LCursorPos);
  dmChannel.pmnChannelOptions.Popup(LCursorPos.X, LCursorPos.Y);
end; 

// callback function for channel is changed
procedure TfrmChild.OnChannelChanged(const AIsChangeSelectionTarget: Boolean);
begin
  UpdateChannelFormButtonsEnableState;

  if AIsChangeSelectionTarget then
  begin
    if Assigned(FSelection) then
    begin
      ChangeSelectionTarget;
    end;
  end;
end;

// callback function for click on chain icon that on a layer panel
procedure TfrmChild.OnLayerChainImageClick(Sender: TObject;
  const ALayerPanelIndex: Integer);
var
  LHistoryStatePanel: TgmHistoryStatePanel;
  LLayerPanel       : TgmLayerPanel;
begin
  if (ALayerPanelIndex >= 0) and
     (ALayerPanelIndex < FLayerPanelList.Count) then
  begin
    LLayerPanel := TgmLayerPanel(FLayerPanelList.Items[ALayerPanelIndex]);

    // undo/redo
    if LLayerPanel.IsMaskLinked then
    begin
      LHistoryStatePanel := TgmLinkMaskStatePanel.Create(
        frmHistory.scrlbxHistory,
        dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
        ALayerPanelIndex);
    end
    else
    begin
      LHistoryStatePanel := TgmUnLinkMaskStatePanel.Create(
        frmHistory.scrlbxHistory,
        dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
        ALayerPanelIndex);
    end;

    if Assigned(LHistoryStatePanel) then
    begin
      FHistoryManager.AddHistoryState(LHistoryStatePanel);
    end;
  end;
end;

// callback function for click on path panel
procedure TfrmChild.PathPanelClick(Sender: TObject);
begin
  FMayClick := True;

  if frmMain.MainTool <> gmtPenTools then
  begin
    frmMain.spdbtnPenTools.Down := True;
    frmMain.ChangeMainToolClick(frmMain.spdbtnPenTools);
  end;

  if FPathLayer = nil then
  begin
    CreatePathLayer;
  end;

  FPathLayer.BringToFront;

  if Assigned(FPathPanelList.SelectedPanel) then
  begin
    // update the path layer
    FPathLayer.Bitmap.FillRect(0, 0, FPathLayer.Bitmap.Width,
                               FPathLayer.Bitmap.Height, $00000000);

    // draw the paths on the path layer
    FPathPanelList.SelectedPanel.PenPathList.DrawAllPaths(
      FPathLayer.Bitmap.Canvas, pmNotXor, Point(0, 0) );
  end;

  ActiveChildForm.imgDrawingArea.Cursor := crPenToolDeselected;
  Screen.Cursor                         := crDefault;

  frmPath.tlbtnStrokePath.Enabled          := (FPathPanelList.SelectedPanel.PenPathList.GetSelectedPathsCount > 0);
  frmPath.tlbtnFillPath.Enabled            := frmPath.tlbtnStrokePath.Enabled;
  frmPath.tlbtnLoadPathAsSelection.Enabled := frmPath.tlbtnStrokePath.Enabled;
end;

// callback function for double-click on path panel
procedure TfrmChild.PathPanelDblClick(Sender: TObject);
begin
  if (FSelectionTransformation <> nil) or
     (FCrop <> nil) or
     frmRichTextEditor.Visible then
  begin
    Exit;
  end;

  frmSavePath := TfrmSavePath.Create(nil);
  try
    if frmSavePath.ShowModal = mrOK then
    begin
      with FPathPanelList.SelectedPanel do
      begin
        IsNamed  := True;
        PathName := frmSavePath.edtPathName.Text;
        
        ShowPathPanelName;
      end;
    end;
  finally
    FreeAndNil(frmSavePath);
  end;
end;

// callback function for do something when update path panel state
procedure TfrmChild.OnUpdatePathPanelState(Sender: TObject);
begin
  frmPath.tlbtnDeleteCurrentPath.Enabled := (FPathPanelList.SelectedPanelIndex > -1);

  frmPath.tlbtnStrokePath.Enabled := (FPathPanelList.SelectedPanel <> nil) and
                                     (FPathPanelList.SelectedPanel.PenPathList.GetSelectedPathsCount > 0);

  frmPath.tlbtnFillPath.Enabled            := frmPath.tlbtnStrokePath.Enabled;
  frmPath.tlbtnLoadPathAsSelection.Enabled := frmPath.tlbtnStrokePath.Enabled;
end;

procedure TfrmChild.UpdateMainFormStatusBarWhenMouseDown;
begin
  frmMain.stsbrMain.Panels[0].Text := GetBitmapDimensionString(
    FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

  frmMain.ShowOriginalCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
  frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
end; 

// refresh current shape region layer appearance
procedure TfrmChild.UpdateCurrentSelectedShapeRegionLayer;
var
  LShapeRegionLayerPanel: TgmShapeRegionLayerPanel;
begin
  if FLayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
  begin
    if FShapeOutlineLayer = nil then
    begin
      CreateShapeOutlineLayer;
    end;

    if FShapeOutlineLayer <> nil then
    begin
      FShapeOutlineLayer.Bitmap.Clear($00000000);
      LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(FLayerPanelList.SelectedLayerPanel);

      LShapeRegionLayerPanel.ShapeOutlineList.DrawAllOutlines(
        FShapeOutlineLayer.Bitmap.Canvas, FOutlineOffsetVector, pmNotXor);

      if (frmMain.MainTool = gmtShape) and
         (frmMain.ShapeRegionTool = srtMove) then
      begin
        LShapeRegionLayerPanel.ShapeOutlineList.BackupCoordinates;

        LShapeRegionLayerPanel.ShapeOutlineList.DrawShapesBoundary(
          FShapeOutlineLayer.Bitmap.Canvas, HANDLE_RADIUS,
          FOutlineOffsetVector, pmNotXor);

        LShapeRegionLayerPanel.ShapeOutlineList.DrawShapesBoundaryHandles(
          FShapeOutlineLayer.Bitmap.Canvas, HANDLE_RADIUS,
          FOutlineOffsetVector, pmNotXor);
      end;

      LShapeRegionLayerPanel.IsDismissed := False;
      FShapeOutlineLayer.Bitmap.Changed;
      frmMain.UpdateShapeOptions;
    end;
  end
  else
  begin
    if FShapeOutlineLayer <> nil then
    begin
      DeleteShapeOutlineLayer;
    end;
  end;
end;

procedure TfrmChild.UpdateCurrentSelectedTextLayer;
var
  LRichTextLayerPanel: TgmRichTextLayerPanel;
begin
  if FLayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
  begin
    LRichTextLayerPanel := TgmRichTextLayerPanel(FLayerPanelList.SelectedLayerPanel);

    if frmMain.MainTool = gmtTextTool then
    begin
      // creating Rich Text Handle layer
      if FRichTextHandleLayer = nil then
      begin
        CreateRichTextHandleLayer;
      end;

      FRichTextHandleLayer.Bitmap.Clear($00000000);

      LRichTextLayerPanel.DrawRichTextBorder(FRichTextHandleLayer.Bitmap.Canvas,
                                             FRichTextHandleLayerOffsetVector);

      LRichTextLayerPanel.DrawRichTextBorderHandles(FRichTextHandleLayer.Bitmap.Canvas,
                                                    FRichTextHandleLayerOffsetVector);

      FRichTextHandleLayer.Bitmap.Changed;
    end;
  end
  else
  begin
    if FRichTextHandleLayer <> nil then
    begin
      DeleteRichTextHandleLayer;
    end;
  end;
end;

// adapted from RebuildBrush() by Zoltan in gr32PaintDemo3 demo program
procedure TfrmChild.BuildPencilStroke(const ADest: TBitmap32);
var
  LPenWidth           : Integer;
  LBackBmp, LStrokeBmp: TBitmap32;
begin
  LPenWidth := frmMain.GlobalPenWidth - 1;

  LBackBmp   := TBitmap32.Create;
  LStrokeBmp := TBitmap32.Create;
  try
    LBackBmp.SetSize(LPenWidth * 2 + 1, LPenWidth * 2 + 1);
    LBackBmp.Clear(clWhite32);

    LStrokeBmp.SetSize(LBackBmp.Width, LBackBmp.Height);
    LStrokeBmp.DrawMode    := dmBlend;
    LStrokeBmp.CombineMode := cmMerge;
    LStrokeBmp.Clear(clBlack32);

    FeatheredCircleAlpha(LStrokeBmp, LStrokeBmp.Width div 2,
                         LStrokeBmp.Height div 2,
                         frmMain.GlobalPenWidth div 2, 5);

    LStrokeBmp.DrawTo(LBackBmp);
    ADest.Assign(LBackBmp);
  finally
    LStrokeBmp.Free;
    LBackBmp.Free;
  end;
end;

// adapted from BrushLine() by Zoltan in gr32PaintDemo3 demo program
procedure TfrmChild.PencilLine(const xStart, yStart, xEnd, yEnd, distance: Integer;
  ToBitmap: TBitmap32; const ChannelSet: TgmChannelSet);
var
  a,b        : Integer;  // displacements in x and y
  d          : Integer;  // decision variable
  diag_inc   : Integer;  // d's increment for diagonal steps
  dx_diag    : Integer;  // diagonal x step for next pixel
  dx_nondiag : Integer;  // nondiagonal x step for next pixel
  dy_diag    : Integer;  // diagonal y step for next pixel
  dy_nondiag : Integer;  // nondiagonal y step for next pixel
  i          : Integer;  // loop index
  nondiag_inc: Integer;  // d's increment for nondiagonal steps
  swap       : Integer;  // temporary variable for swap
  x,y        : Integer;  // current x and y coordinates
begin {DrawLine}
  x := xStart;              // line starting point
  y := yStart;

  // Determine drawing direction and step to the next pixel.
  a := xEnd - xStart;       // difference in x dimension
  b := yEnd - yStart;       // difference in y dimension

  // Determine whether end point lies to right or left of start point.
  if a < 0 then               // drawing towards smaller x values?
  begin
    a       := -a;            // make 'a' positive
    dx_diag := -1
  end
  else dx_diag := 1;

  // Determine whether end point lies above or below start point.
  if b < 0 then               // drawing towards smaller y values?
  begin
    b       := -b;            // make 'b' positive
    dy_diag := -1
  end
  else dy_diag := 1;

  // Identify octant containing end point.
  if a < b then
  begin
    swap       := a;
    a          := b;
    b          := swap;
    dx_nondiag := 0;
    dy_nondiag := dy_diag
  end
  else
  begin
    dx_nondiag := dx_diag;
    dy_nondiag := 0
  end;

  d           := b + b - a;  // initial value for d is 2*b - a
  nondiag_inc := b + b;      // set initial d increment values
  diag_inc    := b + b - a - a;

  for i := 0 to a do    // draw the a+1 pixels
  begin
    if Ftavolsag >= distance then
    begin
      frmMain.Pencil.Paint(tobitmap, x, y, ChannelSet);
      Ftavolsag := 0;
      Felozox   := x;
      Felozoy   := y;
    end;

    if d < 0 then              // is midpoint above the line?
    begin                      // step nondiagonally
      x := x + dx_nondiag;
      y := y + dy_nondiag;
      d := d + nondiag_inc   // update decision variable
    end
    else
    begin                    // midpoint is above the line; step diagonally
      x := x + dx_diag;
      y := y + dy_diag;
      d := d + diag_inc
    end;

    Ftavolsag := (  sqrt( sqr(x - Felozox) + sqr(y - Felozoy) )  );
  end;
end; 

procedure TfrmChild.PencilLineOnMask(
  const xStart, yStart, xEnd, yEnd, distance: Integer;
  const ChannelSet: TgmChannelSet);
var
  a,b        : Integer;  // displacements in x and y
  d          : Integer;  // decision variable
  diag_inc   : Integer;  // d's increment for diagonal steps
  dx_diag    : Integer;  // diagonal x step for next pixel
  dx_nondiag : Integer;  // nondiagonal x step for next pixel
  dy_diag    : Integer;  // diagonal y step for next pixel
  dy_nondiag : Integer;  // nondiagonal y step for next pixel
  i          : Integer;  // loop index
  nondiag_inc: Integer;  // d's increment for nondiagonal steps
  swap       : Integer;  // temporary variable for swap
  x,y        : Integer;  // current x and y coordinates
  PencilArea : TRect;
begin {DrawLine}
  x := xStart;              // line starting point
  y := yStart;

  // Determine drawing direction and step to the next pixel.
  a := xEnd - xStart;       // difference in x dimension
  b := yEnd - yStart;       // difference in y dimension

  // Determine whether end point lies to right or left of start point.
  if a < 0 then               // drawing towards smaller x values?
  begin
    a       := -a;            // make 'a' positive
    dx_diag := -1
  end
  else
  begin
    dx_diag := 1;
  end;

  // Determine whether end point lies above or below start point.
  if b < 0 then               // drawing towards smaller y values?
  begin
    b       := -b;            // make 'b' positive
    dy_diag := -1
  end
  else
  begin
    dy_diag := 1;
  end;

  // Identify octant containing end point.
  if a < b then
  begin
    swap       := a;
    a          := b;
    b          := swap;
    dx_nondiag := 0;
    dy_nondiag := dy_diag
  end
  else
  begin
    dx_nondiag := dx_diag;
    dy_nondiag := 0
  end;

  d           := b + b - a;  // initial value for d is 2*b - a
  nondiag_inc := b + b;      // set initial d increment values
  diag_inc    := b + b - a - a;

  for i := 0 to a do    // draw the a+1 pixels
  begin
    if Ftavolsag >= distance then
    begin
      frmMain.Pencil.Paint(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                           x, y, ChannelSet);

      // paint on mask channel preview layer, too
      if Assigned(FChannelManager.LayerMaskPanel) then
      begin
        frmMain.Pencil.Paint(FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap,
                             x, y, ChannelSet);
      end;

      // on special layers, save the new mask into its alpha channels
      if FLayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
      begin
        PencilArea := frmMain.Pencil.GetBrushArea(x, y);
        FLayerPanelList.SelectedLayerPanel.UpdateLayerAlphaWithMask(PencilArea);
      end;

      Ftavolsag := 0;
      Felozox   := x;
      Felozoy   := y;
    end;

    if d < 0 then              // is midpoint above the line?
    begin                      // step nondiagonally
      x := x + dx_nondiag;
      y := y + dy_nondiag;
      d := d + nondiag_inc   // update decision variable
    end
    else
    begin                    // midpoint is above the line; step diagonally
      x := x + dx_diag;
      y := y + dy_diag;
      d := d + diag_inc
    end;

    Ftavolsag := (  sqrt( sqr(x - Felozox) + sqr(y - Felozoy) )  );
  end;
end; 

procedure TfrmChild.ProcessFigureMouseUpOnLayer(
  const ShiftState: TShiftState);
begin
  case frmMain.StandardTool of
    gstStraightLine,
    gstRegularPolygon,
    gstRectangle,
    gstRoundRectangle,
    gstEllipse:
      begin
        // calculating coordinates of figures
        if frmMain.StandardTool in [gstStraightLine, gstRegularPolygon] then
        begin
          FActualEndPoint := Point(FXActual, FYActual);
        end
        else if frmMain.StandardTool in [gstRectangle, gstRoundRectangle, gstEllipse] then
        begin
          if ssShift in ShiftState then
          begin
            FActualEndPoint := CalculateRegularFigureEndPoint(FActualStartPoint, Point(FXActual, FYActual));
          end
          else
          begin
            FActualEndPoint := Point(FXActual, FYActual);
          end;
        end;

        // create or switch to figure layer, and add figure to list
        if frmMain.StandardTool = gstStraightLine then
        begin
          CreateFigureLayer(ffStraightLine);
        end
        else if frmMain.StandardTool = gstRectangle then
        begin
          if ssShift in ShiftState then
          begin
            CreateFigureLayer(ffSquare);
          end
          else
          begin
            CreateFigureLayer(ffRectangle);
          end;
        end
        else if frmMain.StandardTool = gstRoundRectangle then
        begin
          if ssShift in ShiftState then
          begin
            CreateFigureLayer(ffRoundSquare);
          end
          else
          begin
            CreateFigureLayer(ffRoundRectangle);
          end;
        end
        else if frmMain.StandardTool = gstEllipse then
        begin
          if ssShift in ShiftState then
          begin
            CreateFigureLayer(ffCircle);
          end
          else
          begin
            CreateFigureLayer(ffEllipse);
          end;
        end
        else if frmMain.StandardTool = gstRegularPolygon then
        begin
          CreateFigureLayer(ffRegularPolygon);
        end;

        if FLayerPanelList.SelectedLayerPanel.LayerFeature = lfFigure then
        begin
          TgmFigureLayerPanel(FLayerPanelList.SelectedLayerPanel).DrawAllFigures(
            FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap, $00FFFFFF, pmCopy, fdmRGB);
            
          TgmFigureLayerPanel(FLayerPanelList.SelectedLayerPanel).DrawAllFigures(
            FLayerPanelList.SelectedLayerPanel.ProcessedPart, clBlack32, pmCopy, fdmMask);
        end;

        MakeCanvasProcessedOpaque(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                                  FLayerPanelList.SelectedLayerPanel.ProcessedPart);

        if FLayerPanelList.SelectedLayerPanel.IsHasMask then
        begin
          GetAlphaChannelBitmap(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                                FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
        end;

        FLayerPanelList.SelectedLayerPanel.Update;

        // update thumbnails
        FLayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
        FChannelManager.UpdateColorChannelThumbnails(FLayerPanelList);
      end;

    gstBezierCurve:
      begin
        if FDrawCurveTime = 1 then
        begin
          FDrawCurveTime := 2;
        end
        else if FDrawCurveTime = 2 then
        begin
          FDrawCurveTime := 3;
        end
        else if FDrawCurveTime = 3 then
        begin
          FDrawCurveTime := 0;
          FinishCurveOnLayer;
        end;
      end;

    gstPolygon:
      begin
        if FMayClick then
        begin
          with imgDrawingArea.Canvas do
          begin
            DrawStraightLine(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);

            FEndPoint.X := FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100);
            FEndPoint.Y := FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100);

            DrawStraightLine(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);
          end;
        
          FStartPoint := FEndPoint;
        end
        else
        begin
          { If FMayClick is false, it indicates that users double clicked the
          mouse and finished the polygon definition. So the following routines
          that add points to the polygon array won't be executed. }

          SetLength(FPolygon, 0);
          SetLength(FActualPolygon, 0);
          FMayClick := True;
          FDrawing  := False;
          Exit;
        end;
        
        { If FMayClick is true, it indicates that users have not double clicked
          the mouse to finish the polygon definition, so we could add a new point
          to the polygon array. }
        SetLength(FPolygon, High(FPolygon) + 2);
        FPolygon[High(FPolygon)].X := FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100);
        FPolygon[High(FPolygon)].Y := FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100);

        SetLength(FActualPolygon, High(FActualPolygon) + 2);
        FActualPolygon[High(FActualPolygon)] := Point(FXActual, FYActual);
      end;
  end;
end;

procedure TfrmChild.ProcessFigureMouseUpOnSpecialChannels(
  const ShiftState: TShiftState);
var
  LDestBmp          : TBitmap32;
  LFigureFlag       : TgmFigureFlags;
  LFigureName       : string;
  LHistoryStatePanel: TgmHistoryStatePanel;
  LCommandIconIndex : Integer;
  LCmdAim           : TCommandAim;
begin
  LDestBmp          := nil;
  LFigureName       := '';
  LFigureFlag       := ffNone;
  LCommandIconIndex := DEFAULT_COMMAND_ICON_INDEX;

  case frmMain.StandardTool of
    gstStraightLine,
    gstRegularPolygon,
    gstRectangle,
    gstRoundRectangle,
    gstEllipse:
      begin
        // remember bitmap for create Undo/Redo command
        case FChannelManager.CurrentChannelType of
          wctAlpha:
            begin
              frmMain.FBeforeProc.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
              LDestBmp := FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap;
            end;

          wctQuickMask:
            begin
              frmMain.FBeforeProc.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
              LDestBmp := FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap;
            end;

          wctLayerMask:
            begin
              frmMain.FBeforeProc.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
              LDestBmp := FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap;
            end;
        end;

        // calculating the coordinates of figures
        if frmMain.StandardTool in
             [gstStraightLine, gstRegularPolygon] then
        begin
          FActualEndPoint := Point(FXActual, FYActual);
        end
        else
        if frmMain.StandardTool in
             [gstRectangle, gstRoundRectangle, gstEllipse] then
        begin
          if ssShift in ShiftState then
          begin
            FActualEndPoint := CalculateRegularFigureEndPoint(
              FActualStartPoint, Point(FXActual, FYActual));
          end
          else
          begin
            FActualEndPoint := Point(FXActual, FYActual);
          end;
        end;

        with LDestBmp do
        begin
          if frmMain.StandardTool = gstStraightLine then
          begin
            DrawStraightLine(Canvas, FActualStartPoint, FActualEndPoint, pmCopy);

            LFigureFlag       := ffStraightLine;
            LCommandIconIndex := STRAIGHT_LINE_COMMAND_ICON_INDEX;
          end
          else
          if frmMain.StandardTool = gstRectangle then
          begin
            DrawRectangle(Canvas, FActualStartPoint, FActualEndPoint, pmCopy);

            if ssShift in ShiftState then
            begin
              LFigureFlag := ffSquare;
            end
            else
            begin
              LFigureFlag := ffRectangle;
            end;

            LCommandIconIndex := RECTANGLE_COMMAND_ICON_INDEX;
          end
          else
          if frmMain.StandardTool = gstRoundRectangle then
          begin
            DrawRoundRect(Canvas, FActualStartPoint, FActualEndPoint,
                          frmMain.StandardCornerRadius, pmCopy);

            if ssShift in ShiftState then
            begin
              LFigureFlag := ffRoundSquare;
            end
            else
            begin
              LFigureFlag := ffRoundRectangle;
            end;

            LCommandIconIndex := ROUND_RECT_COMMAND_ICON_INDEX;
          end
          else
          if frmMain.StandardTool = gstEllipse then
          begin
            DrawEllipse(Canvas, FActualStartPoint, FActualEndPoint, pmCopy);

            if ssShift in ShiftState then
            begin
              LFigureFlag := ffCircle;
            end
            else
            begin
              LFigureFlag := ffEllipse;
            end;

            LCommandIconIndex := ELLIPSE_COMMAND_ICON_INDEX;
          end
          else
          if frmMain.StandardTool = gstRegularPolygon then
          begin
            DrawRegularPolygon(Canvas, FActualStartPoint, FActualEndPoint,
                               frmMain.StandardPolygonSides, pmCopy, FILL_INSIDE);

            LFigureFlag       := ffRegularPolygon;
            LCommandIconIndex := REGULAR_POLY_COMMAND_ICON_INDEX;
          end;
        end;

        { Restore the alpha channels to opaque after applied canvas operations on
          the mask. Otherwise, if you create selection on mask, you will get a
          mask selection with transparent area, which is bad. }
        ReplaceAlphaChannelWithNewValue(LDestBmp, 255);

        case FChannelManager.CurrentChannelType of
          wctAlpha:
            begin
              FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
            end;
            
          wctQuickMask:
            begin
              FChannelManager.QuickMaskPanel.AlphaLayer.Changed;
            end;

          wctLayerMask:
            begin
              if Assigned(FChannelManager.LayerMaskPanel) then
              begin
                FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(
                  0, 0, FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
              end;

              FLayerPanelList.SelectedLayerPanel.Update;
            end;
        end;

        // update thumbnails
        UpdateThumbnailsBySelectedChannel;

        // Undo/Redo
        LFigureName := GetFigureName(LFigureFlag);
        LCmdAim     := GetCommandAimByCurrentChannel;

        LHistoryStatePanel := TgmImageManipulatingStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[LCommandIconIndex],
          LCmdAim,
          LFigureName,
          frmMain.FBeforeProc,
          LDestBmp,
          FSelection,
          FChannelManager.SelectedAlphaChannelIndex);

        FHistoryManager.AddHistoryState(LHistoryStatePanel);
      end;

    gstBezierCurve:
      begin
        if FDrawCurveTime = 1 then
        begin
          FDrawCurveTime := 2;
        end
        else if FDrawCurveTime = 2 then
        begin
          FDrawCurveTime := 3;
        end
        else if FDrawCurveTime = 3 then
        begin
          FDrawCurveTime := 0;
          FinishCurveOnSpecialChannels;
        end;
      end;

    gstPolygon:
      begin
        if FMayClick then
        begin
          with imgDrawingArea.Canvas do
          begin
            DrawStraightLine(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);

            FEndPoint.X := FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100);
            FEndPoint.Y := FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100);

            DrawStraightLine(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);
          end;

          FStartPoint := FEndPoint;
        end
        else
        begin
          SetLength(FPolygon, 0);
          SetLength(FActualPolygon, 0);
          FMayClick := True;
          FDrawing  := False;
          Exit;
        end;

        SetLength(FPolygon, High(FPolygon) + 2);
        FPolygon[High(FPolygon)].X := FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100);
        FPolygon[High(FPolygon)].Y := FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100);

        SetLength(FActualPolygon, High(FActualPolygon) + 2);
        FActualPolygon[High(FActualPolygon)] := Point(FXActual, FYActual);
      end;
  end;
end; 

procedure TfrmChild.ProcessFigureMouseUpOnSelection(
  const ShiftState: TShiftState);
var
  LFigureFlag       : TgmFigureFlags;
  LFigureName       : string;
  LHistoryStatePanel: TgmHistoryStatePanel;
  LCommandIconIndex : Integer;
  LCmdAim           : TCommandAim;
begin
  LFigureFlag       := ffNone;
  LCommandIconIndex := DEFAULT_COMMAND_ICON_INDEX;

  if Assigned(FSelection) then
  begin
    case frmMain.StandardTool of
      gstStraightLine,
      gstRegularPolygon,
      gstRectangle,
      gstRoundRectangle,
      gstEllipse:
        begin
          // remember bitmap for create Undo/Redo command
          frmMain.FBeforeProc.Assign(FSelection.CutOriginal);

          { Temporarily change the size of ProcessedPart bitmap to be same as
            CutOriginal, and use it to track the processed part by canvas. }
          if (FLayerPanelList.SelectedLayerPanel.ProcessedPart.Width  <> FSelection.CutOriginal.Width) or
             (FLayerPanelList.SelectedLayerPanel.ProcessedPart.Height <> FSelection.CutOriginal.Height) then
          begin
            FLayerPanelList.SelectedLayerPanel.ProcessedPart.SetSize(FSelection.CutOriginal.Width,
                                                                     FSelection.CutOriginal.Height);

            FLayerPanelList.SelectedLayerPanel.ProcessedPart.Clear(clBlack32);
            InitializeCanvas; // need reset the canvas properties after the bitmap size is changed
          end;

          { Don't know why we need to set the brush style for
            CutOriginal.Canvas again. Otherwise, the bsClear brush style
            setting will not affect the selection. }
          FSelection.CutOriginal.Canvas.Brush.Style := frmMain.GlobalBrushStyle;

          // calculating the coordinates of figures
          if frmMain.StandardTool in [gstStraightLine, gstRegularPolygon] then
          begin
            FActualEndPoint := Point(FMarqueeX, FMarqueeY);
          end
          else
          if frmMain.StandardTool in [gstRectangle, gstRoundRectangle, gstEllipse] then
          begin
            if ssShift in ShiftState then
            begin
              FActualEndPoint := CalculateRegularFigureEndPoint(FActualStartPoint, Point(FMarqueeX, FMarqueeY));
            end
            else
            begin
              FActualEndPoint := Point(FMarqueeX, FMarqueeY);
            end;
          end;

          // remember old transparency if we need
          if FChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue] then
          begin
            if (FLayerPanelList.SelectedLayerPanel.IsLockTransparency) or
               (FChannelManager.SelectedColorChannelCount < 3) then
            begin
              CopyBitmap32(FLayerPanelList.SelectedLayerPanel.LastProcessed, FSelection.CutOriginal);
            end;
          end;

          // draw figure on selection
          if frmMain.StandardTool = gstStraightLine then
          begin
            DrawStraightLine(FSelection.CutOriginal.Canvas,
                             FActualStartPoint, FActualEndPoint, pmCopy);

            DrawStraightLine(FLayerPanelList.SelectedLayerPanel.ProcessedPart.Canvas,
                             FActualStartPoint, FActualEndPoint, pmCopy);

            LFigureFlag       := ffStraightLine;
            LCommandIconIndex := STRAIGHT_LINE_COMMAND_ICON_INDEX;
          end
          else if frmMain.StandardTool = gstRectangle then
          begin
            DrawRectangle(FSelection.CutOriginal.Canvas,
                          FActualStartPoint, FActualEndPoint, pmCopy);

            DrawRectangle(FLayerPanelList.SelectedLayerPanel.ProcessedPart.Canvas,
                          FActualStartPoint, FActualEndPoint, pmCopy);

            if ssShift in ShiftState then
            begin
              LFigureFlag := ffSquare;
            end
            else
            begin
              LFigureFlag := ffRectangle;
            end;

            LCommandIconIndex := RECTANGLE_COMMAND_ICON_INDEX;
          end
          else if frmMain.StandardTool = gstRoundRectangle then
          begin
            DrawRoundRect(FSelection.CutOriginal.Canvas, FActualStartPoint, FActualEndPoint,
                          frmMain.StandardCornerRadius, pmCopy);

            DrawRoundRect(FLayerPanelList.SelectedLayerPanel.ProcessedPart.Canvas,
                          FActualStartPoint, FActualEndPoint,
                          frmMain.StandardCornerRadius, pmCopy);

            if ssShift in ShiftState then
            begin
              LFigureFlag := ffRoundSquare;
            end
            else
            begin
              LFigureFlag := ffRoundRectangle;
            end;

            LCommandIconIndex := ROUND_RECT_COMMAND_ICON_INDEX;
          end
          else if frmMain.StandardTool = gstEllipse then
          begin
            DrawEllipse(FSelection.CutOriginal.Canvas,
                        FActualStartPoint, FActualEndPoint, pmCopy);

            DrawEllipse(FLayerPanelList.SelectedLayerPanel.ProcessedPart.Canvas,
                        FActualStartPoint, FActualEndPoint, pmCopy);

            if ssShift in ShiftState then
            begin
              LFigureFlag := ffCircle;
            end
            else
            begin
              LFigureFlag := ffEllipse;
            end;

            LCommandIconIndex := ELLIPSE_COMMAND_ICON_INDEX;
          end
          else if frmMain.StandardTool = gstRegularPolygon then
          begin
            DrawRegularPolygon(FSelection.CutOriginal.Canvas,
                               FActualStartPoint, FActualEndPoint,
                               frmMain.StandardPolygonSides,
                               pmCopy, FILL_INSIDE);

            DrawRegularPolygon(FLayerPanelList.SelectedLayerPanel.ProcessedPart.Canvas,
                               FActualStartPoint, FActualEndPoint,
                               frmMain.StandardPolygonSides,
                               pmCopy, FILL_INSIDE);
                                     
            LFigureFlag       := ffRegularPolygon;
            LCommandIconIndex := REGULAR_POLY_COMMAND_ICON_INDEX;
          end;

          if FLayerPanelList.SelectedLayerPanel.IsLockTransparency then
          begin
            case FChannelManager.CurrentChannelType of
              wctRGB, wctRed, wctGreen, wctBlue:
                begin
                  ReplaceAlphaChannelWithSource(FSelection.CutOriginal,
                    FLayerPanelList.SelectedLayerPanel.LastProcessed);
                end;

              wctAlpha, wctQuickMask, wctLayerMask:
                begin
                  ReplaceAlphaChannelWithNewValue(FSelection.CutOriginal, 255);
                end;
            end;
          end
          else
          begin
            if (FChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue]) and
               (FChannelManager.SelectedColorChannelCount < 3) then
            begin
              ReplaceAlphaChannelWithSource(FSelection.CutOriginal, FLayerPanelList.SelectedLayerPanel.LastProcessed);
            end
            else
            begin
              MakeCanvasProcessedOpaque(FSelection.CutOriginal, FLayerPanelList.SelectedLayerPanel.ProcessedPart);
            end;
          end;

          // adjust RGB channels of layer...
          if FChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue] then
          begin
            ReplaceRGBChannels(frmMain.FBeforeProc, FSelection.CutOriginal,
                               FLayerPanelList.SelectedLayerPanel.ProcessedPart,
                               FChannelManager.ChannelSelectedSet,
                               crsRemainDest);
          end;

          ShowProcessedSelection;
          UpdateThumbnailsBySelectedChannel;

          // restore the size of ProcessedPart bitmap to be same as current layer.
          if (FLayerPanelList.SelectedLayerPanel.ProcessedPart.Width  <> FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width) or
             (FLayerPanelList.SelectedLayerPanel.ProcessedPart.Height <> FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height) then
          begin
            with FLayerPanelList.SelectedLayerPanel.ProcessedPart do
            begin
              FLayerPanelList.SelectedLayerPanel.ProcessedPart.SetSize(
                FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
                FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height);

              FLayerPanelList.SelectedLayerPanel.ProcessedPart.Clear(clBlack32);
              InitializeCanvas; // need reset the canvas properties after the bitmap size is changed
            end;
          end;

          // Undo/Redo
          LFigureName := GetFigureName(LFigureFlag);
          LCmdAim     := GetCommandAimByCurrentChannel;

          LHistoryStatePanel := TgmImageManipulatingStatePanel.Create(
            frmHistory.scrlbxHistory,
            dmHistory.bmp32lstHistory.Bitmap[LCommandIconIndex],
            LCmdAim,
            LFigureName,
            frmMain.FBeforeProc,
            FSelection.CutOriginal,
            FSelection,
            FChannelManager.SelectedAlphaChannelIndex);
            
          FHistoryManager.AddHistoryState(LHistoryStatePanel);
        end;

      gstBezierCurve:
        begin
          if FDrawCurveTime = 1 then
          begin
            FDrawCurveTime := 2;
          end
          else if FDrawCurveTime = 2 then
          begin
            FDrawCurveTime := 3;
          end
          else if FDrawCurveTime = 3 then
          begin
            FDrawCurveTime := 0;
            FinishCurveOnSelection;
          end;
        end;

      gstPolygon:
        begin
          if FMayClick then
          begin
            with imgDrawingArea.Canvas do
            begin
              // clear the old figure
              DrawStraightLine(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);

              FEndPoint.X := FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100);
              FEndPoint.Y := FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100);

              // drawing the new one
              DrawStraightLine(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);
            end;

            FStartPoint := FEndPoint;
          end
          else
          begin
            SetLength(FPolygon, 0);
            SetLength(FActualPolygon, 0);
            FMayClick := True;
            FDrawing  := False;
            Exit;
          end;

          SetLength(FPolygon, High(FPolygon) + 2);
          FPolygon[High(FPolygon)].X := FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100);
          FPolygon[High(FPolygon)].Y := FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100);

          SetLength(FActualPolygon, High(FActualPolygon) + 2);
          FActualPolygon[High(FActualPolygon)] := Point(FMarqueeX, FMarqueeY);
        end;
    end;
  end;
end;

procedure TfrmChild.ProcessFigureDoubleClickOnLayer;
begin
  if High(FActualPolygon) > 2 then
  begin
    FActualPolygon[High(FActualPolygon)] := FActualPolygon[0];
    FinishPolygonOnLayer;
    SetLength(FPolygon, 0);
    SetLength(FActualPolygon, 0);
  end
  else
  begin
    imgDrawingArea.Bitmap.Changed;
    SetLength(FPolygon, 0);
    SetLength(FActualPolygon, 0);
  end;
end;

procedure TfrmChild.ProcessFigureDoubleClickOnSpecialChannels;
begin
  if High(FActualPolygon) > 2 then
  begin
    FActualPolygon[High(FActualPolygon)] := FActualPolygon[0];
    FinishPolygonOnSpecialChannels;
    SetLength(FPolygon, 0);
    SetLength(FActualPolygon, 0);
  end
  else
  begin
    imgDrawingArea.Bitmap.Changed;
    SetLength(FPolygon, 0);
    SetLength(FActualPolygon, 0);
  end;
end; 

procedure TfrmChild.ProcessFigureDoubleClickOnSelection;
begin
  if Assigned(FSelection) then
  begin
    if High(FActualPolygon) > 2 then
    begin
      FActualPolygon[High(FActualPolygon)] := FActualPolygon[0];
      FinishPolygonOnSelection;
    end
    else
    begin
      imgDrawingArea.Bitmap.Changed;
      SetLength(FPolygon, 0);
      SetLength(FActualPolygon, 0);
    end;
  end;
end; 

procedure TfrmChild.FinishCurveOnLayer;
var
  LFigureLayerPanel : TgmFigureLayerPanel;
begin
  CreateFigureLayer(ffCurve);

  if FLayerPanelList.SelectedLayerPanel.LayerFeature = lfFigure then
  begin
    LFigureLayerPanel := TgmFigureLayerPanel(FLayerPanelList.SelectedLayerPanel);

    LFigureLayerPanel.DrawAllFigures(
      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
      $00FFFFFF, pmCopy, fdmRGB);

    LFigureLayerPanel.DrawAllFigures(LFigureLayerPanel.ProcessedPart, clBlack32,
                                     pmCopy, fdmMask);
  end;

  MakeCanvasProcessedOpaque(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                            FLayerPanelList.SelectedLayerPanel.ProcessedPart);

  FLayerPanelList.SelectedLayerPanel.ProcessedPart.Clear(clBlack32);

  if FLayerPanelList.SelectedLayerPanel.IsHasMask then
  begin
    GetAlphaChannelBitmap(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                          FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
  end;

  FLayerPanelList.SelectedLayerPanel.Update;

  // update thumbnails
  FLayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
  FChannelManager.UpdateColorChannelThumbnails(FLayerPanelList);
end; 

procedure TfrmChild.FinishCurveOnSpecialChannels;
var
  LFigureName       : string;
  LDestBmp          : TBitmap32; // a bitmap32 pointer
  LCmdAim           : TCommandAim;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  LDestBmp := nil;
  
  // remember bitmap for create Undo/Redo command
  case FChannelManager.CurrentChannelType of
    wctAlpha:
      begin
        frmMain.FBeforeProc.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
        LDestBmp := FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap;
      end;

    wctQuickMask:
      begin
        frmMain.FBeforeProc.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
        LDestBmp := FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap;
      end;

    wctLayerMask:
      begin
        frmMain.FBeforeProc.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
        LDestBmp := FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap;
      end;
  end;

  DrawPolyBezier(LDestBmp.Canvas,
    [FActualStartPoint, FActualCurvePoint1, FActualCurvePoint2, FActualEndPoint],
    pmCopy);

  { Restore the alpha channels to opaque after applied canvas operations on
    the mask. Otherwise, if you create selection on mask, you will get a
    mask selection with transparent area, which is bad. }
  ReplaceAlphaChannelWithNewValue(LDestBmp, 255);

  case FChannelManager.CurrentChannelType of
    wctAlpha:
      begin
        FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
      end;

    wctQuickMask:
      begin
        FChannelManager.QuickMaskPanel.AlphaLayer.Changed;
      end;

    wctLayerMask:
      begin
        if Assigned(FChannelManager.LayerMaskPanel) then
        begin
          FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(0, 0,
            FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
        end;

        FLayerPanelList.SelectedLayerPanel.Update;
      end;
  end;

  // update thumbnails
  UpdateThumbnailsBySelectedChannel;

  // Undo/Redo
  LFigureName := GetFigureName(ffCurve);
  LCmdAim     := GetCommandAimByCurrentChannel;

  LHistoryStatePanel := TgmImageManipulatingStatePanel.Create(
    frmHistory.scrlbxHistory,
    dmHistory.bmp32lstHistory.Bitmap[BEZIER_CURVE_COMMAND_ICON_INDEX],
    LCmdAim,
    LFigureName,
    frmMain.FBeforeProc,
    LDestBmp,
    FSelection,
    FChannelManager.SelectedAlphaChannelIndex);

  FHistoryManager.AddHistoryState(LHistoryStatePanel);
end; 

procedure TfrmChild.FinishCurveOnSelection;
var
  FigureName       : string;
  CmdAim           : TCommandAim;
  HistoryStatePanel: TgmHistoryStatePanel;
begin
  if Assigned(FSelection) then
  begin
    // remember bitmap for create Undo/Redo command
    frmMain.FBeforeProc.Assign(FSelection.CutOriginal);

    { Temporarily change the size of ProcessedPart bitmap to be same
      as CutOriginal for track the processed part by canvas functions. }
    if (FLayerPanelList.SelectedLayerPanel.ProcessedPart.Width  <> FSelection.CutOriginal.Width) or
       (FLayerPanelList.SelectedLayerPanel.ProcessedPart.Height <> FSelection.CutOriginal.Height) then
    begin
      FLayerPanelList.SelectedLayerPanel.ProcessedPart.SetSize(FSelection.CutOriginal.Width, FSelection.CutOriginal.Height);
      FLayerPanelList.SelectedLayerPanel.ProcessedPart.Clear(clBlack32);
      InitializeCanvas; // need reset the canvas properties after the bitmap size is changed
    end;

    { Don't know why we need to set the brush style for
      CutOriginal.Canvas again. Otherwise, the bsClear brush style
      setting will not affect the selection. }
    FSelection.CutOriginal.Canvas.Brush.Style := frmMain.GlobalBrushStyle;

    // remember old transparency if we need
    if FChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue] then
    begin
      if (FLayerPanelList.SelectedLayerPanel.IsLockTransparency) or
         (FChannelManager.SelectedColorChannelCount < 3) then
      begin
        CopyBitmap32(FLayerPanelList.SelectedLayerPanel.LastProcessed, FSelection.CutOriginal);
      end;
    end;

    // drawing the bezier curve
    DrawPolyBezier(FSelection.CutOriginal.Canvas,
                   [FActualStartPoint, FActualCurvePoint1, FActualCurvePoint2, FActualEndPoint],
                   pmCopy);

    DrawPolyBezier(FLayerPanelList.SelectedLayerPanel.ProcessedPart.Canvas,
                   [FActualStartPoint, FActualCurvePoint1, FActualCurvePoint2, FActualEndPoint],
                   pmCopy);

    // restore the alpha channels
    if FLayerPanelList.SelectedLayerPanel.IsLockTransparency then
    begin
      case FChannelManager.CurrentChannelType of
        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            ReplaceAlphaChannelWithSource(FSelection.CutOriginal, FLayerPanelList.SelectedLayerPanel.LastProcessed);
          end;
          
        wctAlpha, wctQuickMask, wctLayerMask:
          begin
            ReplaceAlphaChannelWithNewValue(FSelection.CutOriginal, 255);
          end;
      end;
    end
    else
    begin
      if (FChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue]) and
         (FChannelManager.SelectedColorChannelCount < 3) then
      begin
        ReplaceAlphaChannelWithSource(FSelection.CutOriginal, FLayerPanelList.SelectedLayerPanel.LastProcessed);
      end
      else
      begin
        MakeCanvasProcessedOpaque(FSelection.CutOriginal, FLayerPanelList.SelectedLayerPanel.ProcessedPart);
      end;
    end;

    // adjust RGB channels of layer...
    if FChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue] then
    begin
      ReplaceRGBChannels(frmMain.FBeforeProc, FSelection.CutOriginal,
                         FLayerPanelList.SelectedLayerPanel.ProcessedPart,
                         FChannelManager.ChannelSelectedSet, crsRemainDest);
    end;

    ShowProcessedSelection;
    UpdateThumbnailsBySelectedChannel;

    // restore the size of ProcessedPart bitmap to be same as current layer
    if (FLayerPanelList.SelectedLayerPanel.ProcessedPart.Width  <> FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width) or
       (FLayerPanelList.SelectedLayerPanel.ProcessedPart.Height <> FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height) then
    begin
      FLayerPanelList.SelectedLayerPanel.ProcessedPart.SetSize(
        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height);

      FLayerPanelList.SelectedLayerPanel.ProcessedPart.Clear(clBlack32);
      InitializeCanvas;
    end;
  end;

  // Undo/Redo
  FigureName := GetFigureName(ffCurve);
  CmdAim     := GetCommandAimByCurrentChannel;

  HistoryStatePanel := TgmImageManipulatingStatePanel.Create(
    frmHistory.scrlbxHistory,
    dmHistory.bmp32lstHistory.Bitmap[BEZIER_CURVE_COMMAND_ICON_INDEX],
    CmdAim,
    FigureName,
    frmMain.FBeforeProc,
    FSelection.CutOriginal,
    FSelection,
    FChannelManager.SelectedAlphaChannelIndex);
    
  FHistoryManager.AddHistoryState(HistoryStatePanel);
end;

procedure TfrmChild.FinishPolygonOnLayer;
var
  LFigureLayerPanel : TgmFigureLayerPanel;
begin
  CreateFigureLayer(ffPolygon);

  if FLayerPanelList.SelectedLayerPanel.LayerFeature = lfFigure then
  begin
    LFigureLayerPanel := TgmFigureLayerPanel(FLayerPanelList.SelectedLayerPanel);

    LFigureLayerPanel.DrawAllFigures(
      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
      $00FFFFFF, pmCopy, fdmRGB);
      
    LFigureLayerPanel.DrawAllFigures(LFigureLayerPanel.ProcessedPart, clBlack32,
                                     pmCopy, fdmMask);
  end;

  MakeCanvasProcessedOpaque(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                            FLayerPanelList.SelectedLayerPanel.ProcessedPart);
                            
  FLayerPanelList.SelectedLayerPanel.ProcessedPart.Clear(clBlack32);

  if FLayerPanelList.SelectedLayerPanel.IsHasMask then
  begin
    GetAlphaChannelBitmap(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                          FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
  end;

  FLayerPanelList.SelectedLayerPanel.Update;

  // update thumbnails
  FLayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
  FChannelManager.UpdateColorChannelThumbnails(FLayerPanelList);
end; 

procedure TfrmChild.FinishPolygonOnSpecialChannels;
var
  LFigureName       : string;
  LDestBmp          : TBitmap32;
  LCmdAim           : TCommandAim;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  LDestBmp := nil;

  // remember bitmap for create Undo/Redo command
  case FChannelManager.CurrentChannelType of
    wctAlpha:
      begin
        frmMain.FBeforeProc.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
        LDestBmp := FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap;
      end;

    wctQuickMask:
      begin
        frmMain.FBeforeProc.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
        LDestBmp := FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap;
      end;

    wctLayerMask:
      begin
        frmMain.FBeforeProc.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
        LDestBmp := FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap;
      end;
  end;

  DrawPolygon(LDestBmp.Canvas, FActualPolygon, pmCopy);

  { Restore the alpha channels to opaque after applied canvas operations on
    the mask. Otherwise, if you create selection on mask, you will get a
    mask selection with transparent area, which is bad. }
  ReplaceAlphaChannelWithNewValue(LDestBmp, 255);

  case FChannelManager.CurrentChannelType of
    wctAlpha:
      begin
        FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
      end;

    wctQuickMask:
      begin
        FChannelManager.QuickMaskPanel.AlphaLayer.Changed;
      end;

    wctLayerMask:
      begin
        if Assigned(FChannelManager.LayerMaskPanel) then
        begin
          FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(
            0, 0, FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
        end;

        FLayerPanelList.SelectedLayerPanel.Update;
      end;
  end;

  // update thumbnails
  UpdateThumbnailsBySelectedChannel;

  // Undo/Redo
  LFigureName := GetFigureName(ffPolygon);
  LCmdAim     := GetCommandAimByCurrentChannel;

  LHistoryStatePanel := TgmImageManipulatingStatePanel.Create(
    frmHistory.scrlbxHistory,
    dmHistory.bmp32lstHistory.Bitmap[POLYGON_COMMAND_ICON_INDEX],
    LCmdAim,
    LFigureName,
    frmMain.FBeforeProc,
    LDestBmp,
    FSelection,
    FChannelManager.SelectedAlphaChannelIndex);
    
  FHistoryManager.AddHistoryState(LHistoryStatePanel);
end;

procedure TfrmChild.FinishPolygonOnSelection;
var
  FigureName       : string;
  CmdAim           : TCommandAim;
  HistoryStatePanel: TgmHistoryStatePanel;
begin
  if Assigned(FSelection) then
  begin
    // remember bitmap for create Undo/Redo command
    frmMain.FBeforeProc.Assign(FSelection.CutOriginal);

    { Temporarily change the size of ProcessedPart bitmap to be same
      as CutOriginal for tracking the processed part of canvas. }
    if (FLayerPanelList.SelectedLayerPanel.ProcessedPart.Width  <> FSelection.CutOriginal.Width) or
       (FLayerPanelList.SelectedLayerPanel.ProcessedPart.Height <> FSelection.CutOriginal.Height) then
    begin
      FLayerPanelList.SelectedLayerPanel.ProcessedPart.SetSize(FSelection.CutOriginal.Width, FSelection.CutOriginal.Height);
      FLayerPanelList.SelectedLayerPanel.ProcessedPart.Clear(clBlack32);
      InitializeCanvas; // need reset the canvas properties after the bitmap size is changed
    end;

    { Don't know why we need to set the brush style for
      CutOriginal.Canvas again. Otherwise, the bsClear brush style
      setting will not affect the selection. }
    FSelection.CutOriginal.Canvas.Brush.Style := frmMain.GlobalBrushStyle;

    // remember old transparency if we need
    if FChannelManager.CurrentChannelType in [
         wctRGB, wctRed, wctGreen, wctBlue] then
    begin
      if (FLayerPanelList.SelectedLayerPanel.IsLockTransparency) or
         (FChannelManager.SelectedColorChannelCount < 3) then
      begin
        CopyBitmap32(FLayerPanelList.SelectedLayerPanel.LastProcessed,
                     FSelection.CutOriginal);
      end;
    end;

    // drawing the polygon
    DrawPolygon(FSelection.CutOriginal.Canvas, FActualPolygon, pmCopy);
    
    DrawPolygon(FLayerPanelList.SelectedLayerPanel.ProcessedPart.Canvas,
                FActualPolygon, pmCopy);

    // restore the alpha channels
    if FLayerPanelList.SelectedLayerPanel.IsLockTransparency then
    begin
      case FChannelManager.CurrentChannelType of
        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            ReplaceAlphaChannelWithSource(FSelection.CutOriginal, FLayerPanelList.SelectedLayerPanel.LastProcessed);
          end;

        wctAlpha, wctQuickMask, wctLayerMask:
          begin
            ReplaceAlphaChannelWithNewValue(FSelection.CutOriginal, 255);
          end;
      end;
    end
    else
    begin
      if (FChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue]) and
         (FChannelManager.SelectedColorChannelCount < 3) then
      begin
        ReplaceAlphaChannelWithSource(FSelection.CutOriginal, FLayerPanelList.SelectedLayerPanel.LastProcessed);
      end
      else
      begin
        MakeCanvasProcessedOpaque(FSelection.CutOriginal, FLayerPanelList.SelectedLayerPanel.ProcessedPart);
      end;
    end;

    // adjust RGB channels of layer...
    if FChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue] then
    begin
      ReplaceRGBChannels(frmMain.FBeforeProc, FSelection.CutOriginal,
                         FLayerPanelList.SelectedLayerPanel.ProcessedPart,
                         FChannelManager.ChannelSelectedSet, crsRemainDest);
    end;

    ShowProcessedSelection;
    UpdateThumbnailsBySelectedChannel;

    // restore the size of FProcessedPart bitmap to be same as current layer
    if (FLayerPanelList.SelectedLayerPanel.ProcessedPart.Width  <> FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width) or
       (FLayerPanelList.SelectedLayerPanel.ProcessedPart.Height <> FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height) then
    begin
      FLayerPanelList.SelectedLayerPanel.ProcessedPart.SetSize(
        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height);
                                          
      FLayerPanelList.SelectedLayerPanel.ProcessedPart.Clear(clBlack32);
      InitializeCanvas;
    end;
  end;

  // Undo/Redo
  FigureName := GetFigureName(ffPolygon);
  CmdAim     := GetCommandAimByCurrentChannel;

  HistoryStatePanel := TgmImageManipulatingStatePanel.Create(
    frmHistory.scrlbxHistory,
    dmHistory.bmp32lstHistory.Bitmap[POLYGON_COMMAND_ICON_INDEX],
    CmdAim,
    FigureName,
    frmMain.FBeforeProc,
    FSelection.CutOriginal,
    FSelection,
    FChannelManager.SelectedAlphaChannelIndex);
    
  FHistoryManager.AddHistoryState(HistoryStatePanel);
end; 

{ Bresenham algorithm for Brush tools to get continuous brush strokes.
  Author         : Zoltan Komaromy (zoltan@komaromy-nospam.hu)
  Website        : www.mandalapainter.com
  SourceCode From: gr32PainterDemo3 }
procedure TfrmChild.BrushLine(const xStart, yStart, xEnd, yEnd, distance: Integer;
  ToBitmap: TBitmap32; const ChannelSet: TgmChannelSet);
var
  a,b         : Integer;  // displacements in x and y
  d           : Integer;  // decision variable
  diag_inc    : Integer;  // d's increment for diagonal steps
  dx_diag     : Integer;  // diagonal x step for next pixel
  dx_nondiag  : Integer;  // nondiagonal x step for next pixel
  dy_diag     : Integer;  // diagonal y step for next pixel
  dy_nondiag  : Integer;  // nondiagonal y step for next pixel
  i           : Integer;  // loop index
  nondiag_inc : Integer;  // d's increment for nondiagonal steps
  swap        : Integer;  // temporary variable for swap
  x,y         : Integer;  // current x and y coordinates
  TimerEnabled: Boolean;
begin {DrawLine}
  if Assigned(frmMain.GMBrush) then
  begin
    x := xStart;              // line starting point
    y := yStart;

    // Determine drawing direction and step to the next pixel.
    a := xEnd - xStart;       // difference in x dimension
    b := yEnd - yStart;       // difference in y dimension

    // Determine whether end point lies to right or left of start point.
    if a < 0 then               // drawing towards smaller x values?
    begin
      a       := -a;            // make 'a' positive
      dx_diag := -1
    end
    else dx_diag := 1;

    // Determine whether end point lies above or below start point.
    if b < 0 then               // drawing towards smaller y values?
    begin
      b       := -b;            // make 'b' positive
      dy_diag := -1
    end
    else dy_diag := 1;

    // Identify octant containing end point.
    if a < b then
    begin
      swap       := a;
      a          := b;
      b          := swap;
      dx_nondiag := 0;
      dy_nondiag := dy_diag
    end
    else
    begin
      dx_nondiag := dx_diag;
      dy_nondiag := 0
    end;

    d           := b + b - a;  // initial value for d is 2*b - a
    nondiag_inc := b + b;      // set initial d increment values
    diag_inc    := b + b - a - a;

    TimerEnabled            := tmrSpecialBrush.Enabled;
    tmrSpecialBrush.Enabled := False;
    try
      for i := 0 to a do    // draw the a+1 pixels
      begin
        if Ftavolsag >= distance then
        begin
          frmMain.GMBrush.Paint(ToBitmap, x, y, ChannelSet);
          Ftavolsag := 0;
          Felozox   := x;
          Felozoy   := y;
        end;

        if d < 0 then              // is midpoint above the line?
        begin                      // step nondiagonally
          x := x + dx_nondiag;
          y := y + dy_nondiag;
          d := d + nondiag_inc   // update decision variable
        end
        else
        begin                    // midpoint is above the line; step diagonally
          x := x + dx_diag;
          y := y + dy_diag;
          d := d + diag_inc
        end;

        Ftavolsag := (  sqrt( sqr(x - Felozox) + sqr(y - Felozoy) )  );
      end; //for

    finally
      tmrSpecialBrush.Enabled := TimerEnabled;
    end;
  end;
end;

{ Bresenham algorithm for Brush tools to get continuous brush strokes.
  Author         : Zoltan Komaromy (zoltan@komaromy-nospam.hu)
  Website        : www.mandalapainter.com
  SourceCode From: gr32PainterDemo3

  Adapted for mask of layers, just for improve performance. }
procedure TfrmChild.BrushLineOnMask(
  const xStart, yStart, xEnd, yEnd, distance: Integer;
  const ChannelSet: TgmChannelSet);
var
  a,b         : Integer;  // displacements in x and y
  d           : Integer;  // decision variable
  diag_inc    : Integer;  // d's increment for diagonal steps
  dx_diag     : Integer;  // diagonal x step for next pixel
  dx_nondiag  : Integer;  // nondiagonal x step for next pixel
  dy_diag     : Integer;  // diagonal y step for next pixel
  dy_nondiag  : Integer;  // nondiagonal y step for next pixel
  i           : Integer;  // loop index
  nondiag_inc : Integer;  // d's increment for nondiagonal steps
  swap        : Integer;  // temporary variable for swap
  x,y         : Integer;  // current x and y coordinates
  TimerEnabled: Boolean;
  BrushArea   : TRect;
begin {DrawLine}
  if Assigned(frmMain.GMBrush) then
  begin
    x := xStart;              // line starting point
    y := yStart;

    // Determine drawing direction and step to the next pixel.
    a := xEnd - xStart;       // difference in x dimension
    b := yEnd - yStart;       // difference in y dimension

    // Determine whether end point lies to right or left of start point.
    if a < 0 then               // drawing towards smaller x values?
    begin
      a       := -a;            // make 'a' positive
      dx_diag := -1
    end
    else dx_diag := 1;

    // Determine whether end point lies above or below start point.
    if b < 0 then               // drawing towards smaller y values?
    begin
      b       := -b;            // make 'b' positive
      dy_diag := -1
    end
    else dy_diag := 1;

    // Identify octant containing end point.
    if a < b then
    begin
      swap       := a;
      a          := b;
      b          := swap;
      dx_nondiag := 0;
      dy_nondiag := dy_diag
    end
    else
    begin
      dx_nondiag := dx_diag;
      dy_nondiag := 0
    end;

    d           := b + b - a;  // initial value for d is 2*b - a
    nondiag_inc := b + b;      // set initial d increment values
    diag_inc    := b + b - a - a;

    TimerEnabled            := tmrSpecialBrush.Enabled;
    tmrSpecialBrush.Enabled := False;
    try
      for i := 0 to a do    // draw the a+1 pixels
      begin
        if Ftavolsag >= distance then
        begin
          frmMain.GMBrush.Paint(
            FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
            x, y, ChannelSet);

          // paint on mask channel preview layer, too
          if Assigned(FChannelManager.LayerMaskPanel) then
          begin
            frmMain.GMBrush.Paint(
              FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap,
              x, y, ChannelSet);
          end;

          // on special layers, save the new mask into its alpha channels
          if FLayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
          begin
            BrushArea := frmMain.GMBrush.GetBrushArea(x, y);
            FLayerPanelList.SelectedLayerPanel.UpdateLayerAlphaWithMask(BrushArea);
          end;

          Ftavolsag := 0;
          Felozox   := x;
          Felozoy   := y;
        end;

        if d < 0 then              // is midpoint above the line?
        begin                      // step nondiagonally
          x := x + dx_nondiag;
          y := y + dy_nondiag;
          d := d + nondiag_inc   // update decision variable
        end
        else
        begin                    // midpoint is above the line; step diagonally
          x := x + dx_diag;
          y := y + dy_diag;
          d := d + diag_inc
        end;

        Ftavolsag := (  sqrt( sqr(x - Felozox) + sqr(y - Felozoy) )  );
      end; //for

    finally
      tmrSpecialBrush.Enabled := TimerEnabled;
    end;
  end;
end;

procedure TfrmChild.AirBrushLine(const xStart, yStart, xEnd, yEnd, distance: Integer;
  ToBitmap: TBitmap32; const ChannelSet: TgmChannelSet);
var
  a,b         : Integer;  // displacements in x and y
  d           : Integer;  // decision variable
  diag_inc    : Integer;  // d's increment for diagonal steps
  dx_diag     : Integer;  // diagonal x step for next pixel
  dx_nondiag  : Integer;  // nondiagonal x step for next pixel
  dy_diag     : Integer;  // diagonal y step for next pixel
  dy_nondiag  : Integer;  // nondiagonal y step for next pixel
  i           : Integer;  // loop index
  nondiag_inc : Integer;  // d's increment for nondiagonal steps
  swap        : Integer;  // temporary variable for swap
  x,y         : Integer;  // current x and y coordinates
  TimerEnabled: Boolean;
begin {DrawLine}
  if Assigned(frmMain.AirBrush) then
  begin
    x := xStart;              // line starting point
    y := yStart;

    // Determine drawing direction and step to the next pixel.
    a := xEnd - xStart;       // difference in x dimension
    b := yEnd - yStart;       // difference in y dimension

    // Determine whether end point lies to right or left of start point.
    if a < 0 then               // drawing towards smaller x values?
    begin
      a       := -a;            // make 'a' positive
      dx_diag := -1
    end
    else dx_diag := 1;

    // Determine whether end point lies above or below start point.
    if b < 0 then               // drawing towards smaller y values?
    begin
      b       := -b;            // make 'b' positive
      dy_diag := -1
    end
    else dy_diag := 1;

    // Identify octant containing end point.
    if a < b then
    begin
      swap       := a;
      a          := b;
      b          := swap;
      dx_nondiag := 0;
      dy_nondiag := dy_diag
    end
    else
    begin
      dx_nondiag := dx_diag;
      dy_nondiag := 0
    end;

    d           := b + b - a;  // initial value for d is 2*b - a
    nondiag_inc := b + b;      // set initial d increment values
    diag_inc    := b + b - a - a;

    TimerEnabled            := tmrSpecialBrush.Enabled;
    tmrSpecialBrush.Enabled := False;
    try
      for i := 0 to a do    // draw the a+1 pixels
      begin
        if Ftavolsag >= distance then
        begin
          frmMain.AirBrush.Draw(ToBitmap, x, y, ChannelSet);
          
          Ftavolsag := 0;
          Felozox   := x;
          Felozoy   := y;
        end;

        if d < 0 then              // is midpoint above the line?
        begin                      // step nondiagonally
          x := x + dx_nondiag;
          y := y + dy_nondiag;
          d := d + nondiag_inc   // update decision variable
        end
        else
        begin                    // midpoint is above the line; step diagonally
          x := x + dx_diag;
          y := y + dy_diag;
          d := d + diag_inc
        end;

        Ftavolsag := (  sqrt( sqr(x - Felozox) + sqr(y - Felozoy) )  );
      end;

    finally
      tmrSpecialBrush.Enabled := TimerEnabled;
    end;
  end;
end;

procedure TfrmChild.AirBrushLineOnMask(
  const xStart, yStart, xEnd, yEnd, distance: Integer;
  const ChannelSet: TgmChannelSet);
var
  a,b         : Integer;  // displacements in x and y
  d           : Integer;  // decision variable
  diag_inc    : Integer;  // d's increment for diagonal steps
  dx_diag     : Integer;  // diagonal x step for next pixel
  dx_nondiag  : Integer;  // nondiagonal x step for next pixel
  dy_diag     : Integer;  // diagonal y step for next pixel
  dy_nondiag  : Integer;  // nondiagonal y step for next pixel
  i           : Integer;  // loop index
  nondiag_inc : Integer;  // d's increment for nondiagonal steps
  swap        : Integer;  // temporary variable for swap
  x,y         : Integer;  // current x and y coordinates
  TimerEnabled: Boolean;
  BrushArea   : TRect;
begin {DrawLine}
  if Assigned(frmMain.AirBrush) then
  begin
    x := xStart;              // line starting point
    y := yStart;

    // Determine drawing direction and step to the next pixel.
    a := xEnd - xStart;       // difference in x dimension
    b := yEnd - yStart;       // difference in y dimension

    // Determine whether end point lies to right or left of start point.
    if a < 0 then               // drawing towards smaller x values?
    begin
      a       := -a;            // make 'a' positive
      dx_diag := -1
    end
    else
    begin
      dx_diag := 1;
    end;

    // Determine whether end point lies above or below start point.
    if b < 0 then               // drawing towards smaller y values?
    begin
      b       := -b;            // make 'b' positive
      dy_diag := -1
    end
    else
    begin
      dy_diag := 1;
    end;

    // Identify octant containing end point.
    if a < b then
    begin
      swap       := a;
      a          := b;
      b          := swap;
      dx_nondiag := 0;
      dy_nondiag := dy_diag
    end
    else
    begin
      dx_nondiag := dx_diag;
      dy_nondiag := 0
    end;

    d           := b + b - a;  // initial value for d is 2*b - a
    nondiag_inc := b + b;      // set initial d increment values
    diag_inc    := b + b - a - a;

    TimerEnabled            := tmrSpecialBrush.Enabled;
    tmrSpecialBrush.Enabled := False;
    try
      for i := 0 to a do    // draw the a+1 pixels
      begin
        if Ftavolsag >= distance then
        begin
          frmMain.AirBrush.Draw(
            FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
            x, y, ChannelSet);

          // paint on mask channel preview layer, too
          if Assigned(FChannelManager.LayerMaskPanel) then
          begin
            frmMain.AirBrush.Draw(
              FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap,
              x, y, ChannelSet);
          end;

          // on special layers, save the new mask into its alpha channels
          if FLayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
          begin
            BrushArea := frmMain.AirBrush.GetBrushArea(x, y);
            FLayerPanelList.SelectedLayerPanel.UpdateLayerAlphaWithMask(BrushArea);
          end;
          
          Ftavolsag := 0;
          Felozox   := x;
          Felozoy   := y;
        end;

        if d < 0 then              // is midpoint above the line?
        begin                      // step nondiagonally
          x := x + dx_nondiag;
          y := y + dy_nondiag;
          d := d + nondiag_inc   // update decision variable
        end
        else
        begin                    // midpoint is above the line; step diagonally
          x := x + dx_diag;
          y := y + dy_diag;
          d := d + diag_inc
        end;

        Ftavolsag := (  sqrt( sqr(x - Felozox) + sqr(y - Felozoy) )  );
      end;

    finally
      tmrSpecialBrush.Enabled := TimerEnabled;
    end;
  end;
end;

procedure TfrmChild.EraserLine(const xStart, yStart, xEnd, yEnd, distance: Integer;
  ToBitmap: TBitmap32; const ChannelSet: TgmChannelSet);
var
  a,b        : Integer;  // displacements in x and y
  d          : Integer;  // decision variable
  diag_inc   : Integer;  // d's increment for diagonal steps
  dx_diag    : Integer;  // diagonal x step for next pixel
  dx_nondiag : Integer;  // nondiagonal x step for next pixel
  dy_diag    : Integer;  // diagonal y step for next pixel
  dy_nondiag : Integer;  // nondiagonal y step for next pixel
  i          : Integer;  // loop index
  nondiag_inc: Integer;  // d's increment for nondiagonal steps
  swap       : Integer;  // temporary variable for swap
  x,y        : Integer;  // current x and y coordinates
begin {DrawLine}
  if Assigned(frmMain.GMEraser) then
  begin
    x := xStart;              // line starting point
    y := yStart;

    // Determine drawing direction and step to the next pixel.
    a := xEnd - xStart;       // difference in x dimension
    b := yEnd - yStart;       // difference in y dimension

    // Determine whether end point lies to right or left of start point.
    if a < 0 then               // drawing towards smaller x values?
    begin
      a       := -a;            // make 'a' positive
      dx_diag := -1
    end
    else dx_diag := 1;

    // Determine whether end point lies above or below start point.
    if b < 0 then               // drawing towards smaller y values?
    begin
      b       := -b;            // make 'b' positive
      dy_diag := -1
    end
    else dy_diag := 1;

    // Identify octant containing end point.
    if a < b then
    begin
      swap       := a;
      a          := b;
      b          := swap;
      dx_nondiag := 0;
      dy_nondiag := dy_diag
    end
    else
    begin
      dx_nondiag := dx_diag;
      dy_nondiag := 0
    end;

    d           := b + b - a;  // initial value for d is 2*b - a
    nondiag_inc := b + b;      // set initial d increment values
    diag_inc    := b + b - a - a;

    for i := 0 to a do    // draw the a+1 pixels
    begin
      if Ftavolsag >= distance then
      begin
        frmMain.GMEraser.Paint(ToBitmap, x, y, ChannelSet);
        Ftavolsag := 0;
        Felozox   := x;
        Felozoy   := y;
      end;

      if d < 0 then              // is midpoint above the line?
      begin                      // step nondiagonally
        x := x + dx_nondiag;
        y := y + dy_nondiag;
        d := d + nondiag_inc   // update decision variable
      end
      else
      begin                    // midpoint is above the line; step diagonally
        x := x + dx_diag;
        y := y + dy_diag;
        d := d + diag_inc
      end;

      Ftavolsag := (  sqrt( sqr(x - Felozox) + sqr(y - Felozoy) )  );
    end;
  end;
end;

procedure TfrmChild.EraserLineOnMask(
  const xStart, yStart, xEnd, yEnd, distance: Integer;
  const ChannelSet: TgmChannelSet);
var
  a,b        : Integer;  // displacements in x and y
  d          : Integer;  // decision variable
  diag_inc   : Integer;  // d's increment for diagonal steps
  dx_diag    : Integer;  // diagonal x step for next pixel
  dx_nondiag : Integer;  // nondiagonal x step for next pixel
  dy_diag    : Integer;  // diagonal y step for next pixel
  dy_nondiag : Integer;  // nondiagonal y step for next pixel
  i          : Integer;  // loop index
  nondiag_inc: Integer;  // d's increment for nondiagonal steps
  swap       : Integer;  // temporary variable for swap
  x,y        : Integer;  // current x and y coordinates
  BrushArea  : TRect;
begin {DrawLine}
  if Assigned(frmMain.GMEraser) then
  begin
    x := xStart;              // line starting point
    y := yStart;

    // Determine drawing direction and step to the next pixel.
    a := xEnd - xStart;       // difference in x dimension
    b := yEnd - yStart;       // difference in y dimension

    // Determine whether end point lies to right or left of start point.
    if a < 0 then               // drawing towards smaller x values?
    begin
      a       := -a;            // make 'a' positive
      dx_diag := -1
    end
    else
    begin
      dx_diag := 1;
    end;

    // Determine whether end point lies above or below start point.
    if b < 0 then               // drawing towards smaller y values?
    begin
      b       := -b;            // make 'b' positive
      dy_diag := -1
    end
    else
    begin
      dy_diag := 1;
    end;

    // Identify octant containing end point.
    if a < b then
    begin
      swap       := a;
      a          := b;
      b          := swap;
      dx_nondiag := 0;
      dy_nondiag := dy_diag
    end
    else
    begin
      dx_nondiag := dx_diag;
      dy_nondiag := 0
    end;

    d           := b + b - a;  // initial value for d is 2*b - a
    nondiag_inc := b + b;      // set initial d increment values
    diag_inc    := b + b - a - a;

    for i := 0 to a do    // draw the a+1 pixels
    begin
      if Ftavolsag >= distance then
      begin
        frmMain.GMEraser.Paint(
          FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
          x, y, ChannelSet);

        // paint on mask channel preview layer, too
        if Assigned(FChannelManager.LayerMaskPanel) then
        begin
          frmMain.GMEraser.Paint(
            FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap,
            x, y, ChannelSet);
        end;

        // on special layers, save the new mask into its alpha channels
        if FLayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
        begin
          BrushArea := frmMain.GMEraser.GetBrushArea(x, y);
          FLayerPanelList.SelectedLayerPanel.UpdateLayerAlphaWithMask(BrushArea);
        end;

        Ftavolsag := 0;
        Felozox   := x;
        Felozoy   := y;
      end;

      if d < 0 then              // is midpoint above the line?
      begin                      // step nondiagonally
        x := x + dx_nondiag;
        y := y + dy_nondiag;
        d := d + nondiag_inc   // update decision variable
      end
      else
      begin                    // midpoint is above the line; step diagonally
        x := x + dx_diag;
        y := y + dy_diag;
        d := d + diag_inc
      end;

      Ftavolsag := (  sqrt( sqr(x - Felozox) + sqr(y - Felozoy) )  );
    end;
  end;
end;

procedure TfrmChild.CreateMeasureLayer;
var
  LayerHalfW, LayerHalfH: Single;
  CenterPoint           : TPoint;
begin
  if FMeasureLayer = nil then
  begin
    FMeasureLayer := TBitmapLayer.Create(imgDrawingArea.Layers);

    with FMeasureLayer do
    begin
      Bitmap.DrawMode       := dmCustom;
      Bitmap.OnPixelCombine := GrayNotXorLayerBlend;
      Bitmap.Width          := Screen.Width;
      Bitmap.Height         := Screen.Height;
      LayerHalfW            := Bitmap.Width  / 2;
      LayerHalfH            := Bitmap.Height / 2;
    end;

    { Get the center point of the viewport of the Image32, and convert it from
      control coordinate space to bitmap coordinate space. }
    with imgDrawingArea.GetViewportRect do
      CenterPoint := imgDrawingArea.ControlToBitmap(  Point( (Right + Left) div 2, (Top + Bottom) div 2 )  );

    // set location of the layer
    FMeasureLayer.Location := FloatRect(CenterPoint.X - LayerHalfW, CenterPoint.Y - LayerHalfH,
                                        CenterPoint.X + LayerHalfW, CenterPoint.Y + LayerHalfH);

    FMeasureLayer.Scaled := True;
    FMeasureLayer.Bitmap.FillRect(0, 0, FMeasureLayer.Bitmap.Width, FMeasureLayer.Bitmap.Height, $00000000);
    CalcMeasureLayerOffsetVector;  // calculate the offset vector of the measure layer relative to current selected layer
  end;
end;

procedure TfrmChild.CalcMeasureLayerCoord(const X, Y: Integer);
begin
  if Assigned(FMeasureLayer) then
  begin
    FMeasureLayerX := X - Round(FMeasureLayer.GetAdjustedLocation.Left);
    FMeasureLayerY := Y - Round(FMeasureLayer.GetAdjustedLocation.Top);

    if imgDrawingArea.Scale <> 1 then
    begin
      FMeasureLayerX := MulDiv( FMeasureLayerX, FMeasureLayer.Bitmap.Width,
                                Round(FMeasureLayer.Bitmap.Width  * imgDrawingArea.Scale) );

      FMeasureLayerY := MulDiv( FMeasureLayerY, FMeasureLayer.Bitmap.Height,
                                Round(FMeasureLayer.Bitmap.Height * imgDrawingArea.Scale) );
    end;
  end;
end;

// calculate the offset vector of the measure layer relative to current selected layer
procedure TfrmChild.CalcMeasureLayerOffsetVector;
var
  MeasureLayerLeft: Single;
  MeasureLayerTop : Single;
  CurrentLayerLeft: Single;
  CurrentLayerTop : Single;
  TheScale        : Single;
begin
  if Assigned(FMeasureLayer) then
  begin
    TheScale               := 100 / FMagnification;
    MeasureLayerLeft       := FMeasureLayer.GetAdjustedLocation.Left * TheScale;
    MeasureLayerTop        := FMeasureLayer.GetAdjustedLocation.Top  * TheScale;
    CurrentLayerLeft       := FLayerPanelList.SelectedLayerPanel.AssociatedLayer.GetAdjustedLocation.Left * TheScale;
    CurrentLayerTop        := FLayerPanelList.SelectedLayerPanel.AssociatedLayer.GetAdjustedLocation.Top  * TheScale;
    FMeasureOffsetVector.X := Round(MeasureLayerLeft - CurrentLayerLeft);
    FMeasureOffsetVector.Y := Round(MeasureLayerTop  - CurrentLayerTop);
  end;
end; 

procedure TfrmChild.RecordOldPathDataForUndoRedo;
begin
  if Assigned(FPathPanelList.SelectedPanel) then
  begin
    if FOldPathList = nil then
    begin
      FOldPathList := TgmPenPathList.Create;
    end;

    FOldPathList.AssignPenPathListData(FPathPanelList.SelectedPanel.PenPathList);
    
    FOldPathListState := FPathPanelList.SelectedPanel.PenPathList.PathListState;
    FOldPathIndex     := FPathPanelList.SelectedPanel.PenPathList.SelectedPathIndex;
  end;
end;

procedure TfrmChild.CreateModifyPathUndoRedoCommand(const ModifyMode: TgmModifyPathMode);
var
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  if ModifyMode <> mpmNone then
  begin
    LHistoryStatePanel := TgmModifyPathStatePanel.Create(
      frmHistory.scrlbxHistory,
      dmHistory.bmp32lstHistory.Bitmap[DEfAULT_COMMAND_ICON_INDEX],
      FPathPanelList.SelectedPanelIndex,
      FOldPathIndex,
      FPathPanelList.SelectedPanel.PenPathList.SelectedPathIndex,
      FOldPathList,
      FPathPanelList.SelectedPanel.PenPathList,
      ModifyMode);

    FHistoryManager.AddHistoryState(LHistoryStatePanel);

    FreeAndNil(FOldPathList);
  end;
end; 

procedure TfrmChild.CalcLayerCoord(X, Y: Integer);
begin
  FXActual := X - Round(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.GetAdjustedLocation.Left);
  FYActual := Y - Round(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.GetAdjustedLocation.Top);

  if imgDrawingArea.Scale <> 1 then
  begin
    FXActual := MulDiv( FXActual, FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
                        Round(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width * imgDrawingArea.Scale) );

    FYActual := MulDiv( FYActual, FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height,
                        Round(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height * imgDrawingArea.Scale) );
  end;
end;

{ Calculate coordinates for selection when the mouse pointer is over it.
  Note, the CalLayerCoord() method must be called first to get the layer
  coordinates. And then this method will convert the coordnates from layer space
  to selection space. }
procedure TfrmChild.CalcSelectionCoord;
begin
  if Assigned(FSelection) then
  begin
    FMarqueeX := MulDiv(FXActual - FSelection.FMaskBorderStart.X,
                        FSelection.CutOriginal.Width - 1, FSelection.Foreground.Width - 1 );

    FMarqueeY := MulDiv(FYActual - FSelection.FMaskBorderStart.Y,
                        FSelection.CutOriginal.Height - 1, FSelection.Foreground.Height - 1);
  end;
end;

procedure TfrmChild.PencilMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  LStrokeBmp   : TBitmap32;
  LRefreshArea : TRect;
begin
  CalcLayerCoord(X, Y); // get layer space coordinates

  if Button = mbLeft then
  begin
    // showing the coordinates of starting point
    frmMain.ShowOriginalCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
    frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);

    InitializeCanvas;  // Update the respective canvas to correct status.

    if FChannelManager.CurrentChannelType = wctAlpha then
    begin
      if not Assigned(FChannelManager.SelectedAlphaChannelPanel) then
      begin
        MessageDlg('Could not process more than one alpha channels at a time.', mtError, [mbOK], 0);
        Exit;
      end;
    end;

    if FChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue] then
    begin
      // can not process on special layers...
      if not (FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                lfBackground, lfTransparent]) then
      begin
        MessageDlg('Could not using the Pencil tool on current layer.', mtError, [mbOK], 0);
        Exit;
      end;
    end;

    // for performance, we just need to render the processed area
    if imgDrawingArea.RepaintMode <> rmOptimizer then
    begin
      imgDrawingArea.RepaintMode := rmOptimizer;
    end;

    // remember bitmap for create Undo/Redo command
    if Assigned(FSelection) then
    begin
      frmMain.FBeforeProc.Assign(FSelection.CutOriginal);
    end
    else
    begin
      case FChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            frmMain.FBeforeProc.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
          end;

        wctQuickMask:
          begin
            frmMain.FBeforeProc.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
          end;

        wctLayerMask:
          begin
            frmMain.FBeforeProc.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            frmMain.FBeforeProc.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

            if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
            begin
              ReplaceAlphaChannelWithMask(frmMain.FBeforeProc,
                FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
            end;
          end;
      end;
    end;

    PreparePencil;

    if Assigned(FSelection) then
    begin
      // confirm the foreground of the selection to avoid the distortion of the brush stroke
      FSelection.ConfirmForeground;

      CalcSelectionCoord;
      RemoveMarchingAnts;
      DrawMarchingAnts;

      Felozox          := FMarqueeX;
      Felozoy          := FMarqueeY;
      FPrevStrokePoint := Point(FMarqueeX, FMarqueeY)
    end
    else
    begin
      Felozox          := FXActual;
      Felozoy          := FYActual;
      FPrevStrokePoint := Point(FXActual, FYActual);
    end;

    Ftavolsag := 0;

    // if pen width greater than 1, then create pencil stroke
    if frmMain.GlobalPenWidth <> 1 then
    begin
      if Assigned(frmMain.Pencil) then
      begin
        frmMain.Pencil.IsPreserveTransparency := FLayerPanelList.SelectedLayerPanel.IsLockTransparency;
        frmMain.Pencil.SetBlendMode(bbmNormal32);
        frmMain.Pencil.SetBrushOpacity(100);

        LStrokeBmp := TBitmap32.Create;
        try
          BuildPencilStroke(LStrokeBmp);
          frmMain.Pencil.SetPaintingStroke(LStrokeBmp);
        finally
          LStrokeBmp.Free;
        end;

        // set color
        if FChannelManager.CurrentChannelType in [
             wctAlpha, wctQuickMask, wctLayerMask] then
        begin
          frmMain.Pencil.SetColor( Color32(frmMain.ForeGrayColor) );
        end
        else
        begin
          frmMain.Pencil.SetColor( Color32(frmMain.GlobalForeColor) );
        end;
      end;
    end;

    if Assigned(FSelection) then
    begin
      // do not draw the dynamic Marching-Ants lines when processing image
      PauseMarchingAnts;

      if frmMain.GlobalPenWidth = 1 then
      begin
        if FChannelManager.CurrentChannelType in [
             wctRGB, wctRed, wctGreen, wctBlue] then
        begin
          if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
               lfBackground, lfTransparent] then
          begin
            if (FLayerPanelList.SelectedLayerPanel.IsLockTransparency) or
               (FChannelManager.SelectedColorChannelCount < 3) then
            begin
              CopyBitmap32(FLayerPanelList.SelectedLayerPanel.LastProcessed,
                           FSelection.CutOriginal);
            end;
          end;
        end;

        FSelection.CutOriginal.MoveToF(FMarqueeX, FMarqueeY);

        if FChannelManager.CurrentChannelType in [
             wctRGB, wctRed, wctGreen, wctBlue] then
        begin
          FLayerPanelList.SelectedLayerPanel.ProcessedPart.MoveToF(FMarqueeX, FMarqueeY);
        end;

        DrawFreeLine32(FSelection.CutOriginal, FMarqueeX, FMarqueeY,
                       frmMain.GlobalPenStyle);

        if FChannelManager.CurrentChannelType in [
             wctRGB, wctRed, wctGreen, wctBlue] then
        begin
          DrawFreeLine32(FLayerPanelList.SelectedLayerPanel.ProcessedPart,
                         FMarqueeX, FMarqueeY, frmMain.GlobalPenStyle);
        end;

        // preserve transparency...
        if (FLayerPanelList.SelectedLayerPanel.IsLockTransparency) then
        begin
          ReplaceAlphaChannelWithSource(FSelection.CutOriginal,
            FLayerPanelList.SelectedLayerPanel.LastProcessed);
        end
        else
        begin
          if (FChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue]) and
             (FChannelManager.SelectedColorChannelCount < 3) then
          begin
            ReplaceAlphaChannelWithSource(FSelection.CutOriginal,
              FLayerPanelList.SelectedLayerPanel.LastProcessed);
          end;
        end;

        // channel replacement
        if FChannelManager.CurrentChannelType in [
             wctRGB, wctRed, wctGreen, wctBlue] then
        begin
           ReplaceRGBChannels(frmMain.FBeforeProc,
                              ActiveChildForm.FSelection.CutOriginal,
                              FLayerPanelList.SelectedLayerPanel.ProcessedPart,
                              ActiveChildForm.FChannelManager.ChannelSelectedSet,
                              crsRemainDest);
        end;

        LRefreshArea := Rect(FMarqueeX - 1, FMarqueeY - 1, FMarqueeX + 1, FMarqueeY + 1);
      end
      else // if pen width greater than 1...
      begin
        frmMain.Pencil.UpdateSourceBitmap(FSelection.CutOriginal);

        frmMain.Pencil.Paint(FSelection.CutOriginal, FMarqueeX, FMarqueeY,
                             FChannelManager.ChannelSelectedSet);

        LRefreshArea := frmMain.Pencil.GetBrushArea(FMarqueeX, FMarqueeY);
      end;

      ShowSelectionAtBrushStroke(LRefreshArea);
    end
    else // if not paint on selection...
    begin
      case FChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            if frmMain.GlobalPenWidth = 1 then
            begin
              FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.MoveToF(FXActual, FYActual);

              DrawFreeLine32(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                             FXActual, FYActual, frmMain.GlobalPenStyle);

              // get refresh area
              LRefreshArea := Rect(FXActual - 2, FYActual - 2,
                                   FXActual + 2, FYActual + 2);
            end
            else
            begin
              frmMain.Pencil.UpdateSourceBitmap(
                FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);

              frmMain.Pencil.Paint(
                FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                FXActual, FYActual, FChannelManager.ChannelSelectedSet);

              // get refresh area
              LRefreshArea := frmMain.Pencil.GetBrushArea(FXActual, FYActual);
            end;

            // bitmap coordinate space to control coordinate space
            LRefreshArea.TopLeft     := imgDrawingArea.BitmapToControl(LRefreshArea.TopLeft);
            LRefreshArea.BottomRight := imgDrawingArea.BitmapToControl(LRefreshArea.BottomRight);

            FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed(LRefreshArea)
          end;

        wctQuickMask:
          begin
            if frmMain.GlobalPenWidth = 1 then
            begin
              FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.MoveToF(FXActual, FYActual);

              DrawFreeLine32(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                             FXActual, FYActual, frmMain.GlobalPenStyle);

              // get refresh area
              LRefreshArea := Rect(FXActual - 2, FYActual - 2,
                                   FXActual + 2, FYActual + 2);
            end
            else
            begin
              frmMain.Pencil.UpdateSourceBitmap(
                FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);

              frmMain.Pencil.Paint(
                FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                FXActual, FYActual, FChannelManager.ChannelSelectedSet);

              // get refresh area
              LRefreshArea := frmMain.Pencil.GetBrushArea(FXActual, FYActual);
            end;

            // bitmap coordinate space to control coordinate space
            LRefreshArea.TopLeft     := imgDrawingArea.BitmapToControl(LRefreshArea.TopLeft);
            LRefreshArea.BottomRight := imgDrawingArea.BitmapToControl(LRefreshArea.BottomRight);

            FChannelManager.QuickMaskPanel.AlphaLayer.Changed(LRefreshArea);
          end;

        wctLayerMask:
          begin
            if frmMain.GlobalPenWidth = 1 then
            begin
              LRefreshArea := Rect(FXActual - 2, FYActual - 2,
                                   FXActual + 2, FYActual + 2);

              FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.MoveToF(FXActual, FYActual);

              DrawFreeLine32(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                             FXActual, FYActual, frmMain.GlobalPenStyle);

              if Assigned(FChannelManager.LayerMaskPanel) then
              begin
                CopyBitmap32(FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap,
                             FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                             LRefreshArea);
              end;
            end
            else
            begin
              frmMain.Pencil.UpdateSourceBitmap(
                FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);

              frmMain.Pencil.Paint(
                FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                FXActual, FYActual, FChannelManager.ChannelSelectedSet);

              // paint on mask channel preview layer, too
              if Assigned(FChannelManager.LayerMaskPanel) then
              begin
                frmMain.Pencil.Paint(
                  FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap,
                  FXActual, FYActual, FChannelManager.ChannelSelectedSet);
              end;

              // get brush area
              LRefreshArea := frmMain.Pencil.GetBrushArea(FXActual, FYActual);
            end;

            if not FLayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
            begin
              ApplyMask(LRefreshArea);
            end
            else
            begin
              // on special layers, we need save the new mask into its alpha channels
              FLayerPanelList.SelectedLayerPanel.UpdateLayerAlphaWithMask(LRefreshArea);

              // convert from bitmap coordinate space to image coordinates space
              LRefreshArea.TopLeft     := imgDrawingArea.BitmapToControl(LRefreshArea.TopLeft);
              LRefreshArea.BottomRight := imgDrawingArea.BitmapToControl(LRefreshArea.BottomRight);

              FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(LRefreshArea);
            end;
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                 lfBackground, lfTransparent] then
            begin
              if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
              begin
                ReplaceAlphaChannelWithMask(
                  FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                  FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
              end;

              if frmMain.GlobalPenWidth = 1 then
              begin
                LRefreshArea := Rect(FXActual - 1, FYActual - 1,
                                     FXActual + 1, FYActual + 1);

                if (FLayerPanelList.SelectedLayerPanel.IsLockTransparency) or
                   (FChannelManager.SelectedColorChannelCount < 3) then
                begin
                  CopyBitmap32(FLayerPanelList.SelectedLayerPanel.LastProcessed,
                               FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
                end;

                FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.MoveToF(FXActual, FYActual);
                FLayerPanelList.SelectedLayerPanel.ProcessedPart.MoveToF(FXActual, FYActual);

                DrawFreeLine32(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                               FXActual, FYActual, frmMain.GlobalPenStyle);

                DrawFreeLine32(FLayerPanelList.SelectedLayerPanel.ProcessedPart,
                               FXActual, FYActual, frmMain.GlobalPenStyle);

                // replace the processed parts
                ReplaceRGBChannels(frmMain.FBeforeProc,
                                   FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                                   FLayerPanelList.SelectedLayerPanel.ProcessedPart,
                                   ActiveChildForm.FChannelManager.ChannelSelectedSet,
                                   crsRemainDest);

                // restore alpha channels
                if (FLayerPanelList.SelectedLayerPanel.IsLockTransparency) or
                   (FChannelManager.SelectedColorChannelCount < 3) then
                begin
                  ReplaceAlphaChannelWithSource(
                    FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                    FLayerPanelList.SelectedLayerPanel.LastProcessed);
                end;
              end
              else
              begin
                frmMain.Pencil.UpdateSourceBitmap(
                  FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

                frmMain.Pencil.Paint(
                  FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                  FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                // get refresh area
                LRefreshArea := frmMain.Pencil.GetBrushArea(FXActual, FYActual);
              end;

              if FLayerPanelList.SelectedLayerPanel.IsHasMask then
              begin
                GetAlphaChannelBitmap(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                                      FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                                      LRefreshArea);

                FLayerPanelList.SelectedLayerPanel.Update;
              end
              else
              begin
                // from bitmap coordinate space to control coordinate space
                LRefreshArea.TopLeft     := imgDrawingArea.BitmapToControl(LRefreshArea.TopLeft);
                LRefreshArea.BottomRight := imgDrawingArea.BitmapToControl(LRefreshArea.BottomRight);

                FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(LRefreshArea);
              end;
            end;
          end;
      end;
    end;

    FImageProcessed := True; // mark the image has been modified
    FDrawing        := True;
  end;
end;

procedure TfrmChild.PencilMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
var
  AColor         : TColor;
  LastRefreshArea: TRect;
  RefreshArea    : TRect;
begin
  CalcLayerCoord(X, Y);  // get layer space coordinates
  CalcSelectionCoord;    // get selection space coordinates

  { Move mouse when mouse left button down }

  if FDrawing then
  begin
    if Assigned(FSelection) then
    begin
      if frmMain.GlobalPenWidth = 1 then
      begin
        DrawFreeLine32(FSelection.CutOriginal, FMarqueeX, FMarqueeY,
                       frmMain.GlobalPenStyle);

        if FChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue] then
        begin
          // remember the processed part...
          DrawFreeLine32(FLayerPanelList.SelectedLayerPanel.ProcessedPart,
                         FMarqueeX, FMarqueeY, frmMain.GlobalPenStyle);
        end;

        // preserve transparency...
        if FLayerPanelList.SelectedLayerPanel.IsLockTransparency then
        begin
          ReplaceAlphaChannelWithSource(FSelection.CutOriginal,
            FLayerPanelList.SelectedLayerPanel.LastProcessed);
        end
        else
        if (FChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue]) and
           (FChannelManager.SelectedColorChannelCount < 3) then
        begin
          ReplaceAlphaChannelWithSource(FSelection.CutOriginal,
            FLayerPanelList.SelectedLayerPanel.LastProcessed);
        end;

        // channel replacement
        if FChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue] then
        begin
          ReplaceRGBChannels(frmMain.FBeforeProc, FSelection.CutOriginal,
                             FLayerPanelList.SelectedLayerPanel.ProcessedPart,
                             FChannelManager.ChannelSelectedSet,
                             crsRemainDest);
        end;

        // get refresh area

        LastRefreshArea := Rect(FPrevStrokePoint.X - 2, FPrevStrokePoint.Y - 2,
                                FPrevStrokePoint.X + 2, FPrevStrokePoint.Y + 2);

        RefreshArea := Rect(FMarqueeX - 2, FMarqueeY - 2, FMarqueeX + 2, FMarqueeY + 2);
        RefreshArea := AddRects(LastRefreshArea, RefreshArea);
      end
      else
      begin
        PencilLine(FPrevStrokePoint.X, FPrevStrokePoint.Y, FMarqueeX, FMarqueeY,
                   0, FSelection.CutOriginal, FChannelManager.ChannelSelectedSet);

        // get brush area
        LastRefreshArea := frmMain.Pencil.GetBrushArea(FPrevStrokePoint.X, FPrevStrokePoint.Y);
        RefreshArea     := frmMain.Pencil.GetBrushArea(FMarqueeX, FMarqueeY);
        RefreshArea     := AddRects(LastRefreshArea, RefreshArea);
      end;

      ShowSelectionAtBrushStroke(RefreshArea);
      FPrevStrokePoint := Point(FMarqueeX, FMarqueeY);
    end
    else // not paint on selection...
    begin
      case FChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            if frmMain.GlobalPenWidth = 1 then
            begin
              // get refresh area
              LastRefreshArea := Rect(FPrevStrokePoint.X - 2, FPrevStrokePoint.Y - 2,
                                      FPrevStrokePoint.X + 2, FPrevStrokePoint.Y + 2);

              RefreshArea := Rect(FXActual - 2, FYActual - 2, FXActual + 2, FYActual + 2);
              RefreshArea := AddRects(LastRefreshArea, RefreshArea);

              DrawFreeLine32(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                             FXActual, FYActual, frmMain.GlobalPenStyle);
            end
            else
            begin
              PencilLine(FPrevStrokePoint.X, FPrevStrokePoint.Y, FXActual, FYActual,
                         0, FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                         FChannelManager.ChannelSelectedSet);

              // get refresh area
              LastRefreshArea         := frmMain.Pencil.GetBrushArea(FPrevStrokePoint.X, FPrevStrokePoint.Y);
              RefreshArea             := frmMain.Pencil.GetBrushArea(FXActual, FYActual);
              RefreshArea             := AddRects(LastRefreshArea, RefreshArea);
              RefreshArea.TopLeft     := imgDrawingArea.BitmapToControl(RefreshArea.TopLeft);
              RefreshArea.BottomRight := imgDrawingArea.BitmapToControl(RefreshArea.BottomRight);

              FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed(RefreshArea);
            end;
          end;

        wctQuickMask:
          begin
            if frmMain.GlobalPenWidth = 1 then
            begin
              // get refresh area
              LastRefreshArea := Rect(FPrevStrokePoint.X - 2, FPrevStrokePoint.Y - 2,
                                      FPrevStrokePoint.X + 2, FPrevStrokePoint.Y + 2);

              RefreshArea := Rect(FXActual - 2, FYActual - 2, FXActual + 2, FYActual + 2);
              RefreshArea := AddRects(LastRefreshArea, RefreshArea);

              DrawFreeLine32(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                             FXActual, FYActual, frmMain.GlobalPenStyle);
            end
            else
            begin
              PencilLine(FPrevStrokePoint.X, FPrevStrokePoint.Y, FXActual, FYActual,
                         0, FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                         FChannelManager.ChannelSelectedSet);

              // get refresh area
              LastRefreshArea         := frmMain.Pencil.GetBrushArea(FPrevStrokePoint.X, FPrevStrokePoint.Y);
              RefreshArea             := frmMain.Pencil.GetBrushArea(FXActual, FYActual);
              RefreshArea             := AddRects(LastRefreshArea, RefreshArea);
              RefreshArea.TopLeft     := imgDrawingArea.BitmapToControl(RefreshArea.TopLeft);
              RefreshArea.BottomRight := imgDrawingArea.BitmapToControl(RefreshArea.BottomRight);

              FChannelManager.QuickMaskPanel.AlphaLayer.Changed(RefreshArea);
            end;
          end;

        wctLayerMask:
          begin
            if frmMain.GlobalPenWidth = 1 then
            begin
              // get refresh area
              LastRefreshArea := Rect(FPrevStrokePoint.X - 2, FPrevStrokePoint.Y - 2,
                                      FPrevStrokePoint.X + 2, FPrevStrokePoint.Y + 2);

              RefreshArea := Rect(FXActual - 2, FYActual - 2, FXActual + 2, FYActual + 2);
              RefreshArea := AddRects(LastRefreshArea, RefreshArea);

              DrawFreeLine32(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                             FXActual, FYActual, frmMain.GlobalPenStyle);

              if Assigned(FChannelManager.LayerMaskPanel) then
              begin
                CopyBitmap32(FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap,
                             FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                             RefreshArea);
              end;

              // save Mask into special layer's alpha channel
              if FLayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
              begin
                FLayerPanelList.SelectedLayerPanel.UpdateLayerAlphaWithMask(RefreshArea);
              end;
            end
            else
            begin
              { PencilLineOnMask() will paint pencil stroke both on
                FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap and
                FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.

                And the function will also save the new Mask into the
                alpha channels of special layers. }

              PencilLineOnMask(FPrevStrokePoint.X, FPrevStrokePoint.Y,
                               FXActual, FYActual, 0, FChannelManager.ChannelSelectedSet);

              // get brush area
              LastRefreshArea := frmMain.Pencil.GetBrushArea(FPrevStrokePoint.X, FPrevStrokePoint.Y);
              RefreshArea     := frmMain.Pencil.GetBrushArea(FXActual, FYActual);
              RefreshArea     := AddRects(LastRefreshArea, RefreshArea);

              PencilLineOnMask(FPrevStrokePoint.X, FPrevStrokePoint.Y, FXActual,
                               FYActual, 0, FChannelManager.ChannelSelectedSet);
            end;

            if not FLayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
            begin
              ApplyMask(RefreshArea);
            end
            else
            begin
              // convert from bitmap coordinate space to control coordinate space
              RefreshArea.TopLeft     := imgDrawingArea.BitmapToControl(RefreshArea.TopLeft);
              RefreshArea.BottomRight := imgDrawingArea.BitmapToControl(RefreshArea.BottomRight);

              FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(RefreshArea);
            end;
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            if frmMain.GlobalPenWidth = 1 then
            begin
              // get refresh area
              LastRefreshArea := Rect(FPrevStrokePoint.X - 1, FPrevStrokePoint.Y - 1,
                                      FPrevStrokePoint.X + 1, FPrevStrokePoint.Y + 1);

              RefreshArea := Rect(FXActual - 1, FYActual - 1, FXActual + 1, FYActual + 1);
              RefreshArea := AddRects(LastRefreshArea, RefreshArea);

              // restore the alpha channel to the state that before applied mask
              if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
              begin
                ReplaceAlphaChannelWithMask(
                  FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                  FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                  RefreshArea);
              end;

              DrawFreeLine32(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                             FXActual, FYActual, frmMain.GlobalPenStyle);

              DrawFreeLine32(FLayerPanelList.SelectedLayerPanel.ProcessedPart,
                             FXActual, FYActual, frmMain.GlobalPenStyle);

              // replace the processed parts
              ReplaceRGBChannels(frmMain.FBeforeProc,
                                 FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                                 FLayerPanelList.SelectedLayerPanel.ProcessedPart,
                                 FChannelManager.ChannelSelectedSet,
                                 crsRemainDest);

              // restore alpha channels
              if (FLayerPanelList.SelectedLayerPanel.IsLockTransparency) or
                 (FChannelManager.SelectedColorChannelCount < 3) then
              begin
                ReplaceAlphaChannelWithSource(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                                              FLayerPanelList.SelectedLayerPanel.LastProcessed);
              end;
            end
            else // pen width is greater than 1
            begin
              // get refresh area
              LastRefreshArea := frmMain.Pencil.GetBrushArea(FPrevStrokePoint.X, FPrevStrokePoint.Y);
              RefreshArea     := frmMain.Pencil.GetBrushArea(FXActual, FYActual);
              RefreshArea     := AddRects(LastRefreshArea, RefreshArea);

              // restore the alpha channel to the state that before applied mask
              if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
              begin
                ReplaceAlphaChannelWithMask(
                  FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                  FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                  RefreshArea);
              end;

              PencilLine(FPrevStrokePoint.X, FPrevStrokePoint.Y, FXActual, FYActual,
                         0, FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                         FChannelManager.ChannelSelectedSet);
            end;

            if FLayerPanelList.SelectedLayerPanel.IsHasMask then
            begin
              GetAlphaChannelBitmap(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                                    FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                                    RefreshArea);
                                    
              ApplyMask(RefreshArea);
            end
            else
            begin
              // from bitmap coordinate space to control coordinate space
              RefreshArea.TopLeft     := imgDrawingArea.BitmapToControl(RefreshArea.TopLeft);
              RefreshArea.BottomRight := imgDrawingArea.BitmapToControl(RefreshArea.BottomRight);

              FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(RefreshArea);
            end;
          end;
      end;

      FPrevStrokePoint := Point(FXActual, FYActual);
    end;
  end
  else // if the FDrawing = False
  begin
    if (FXActual >= 0) and
       (FYActual >= 0) and
       (FXActual <= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width) and
       (FYActual <= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height) then
    begin
      // showing color info
      AColor := imgDrawingArea.Canvas.Pixels[X, Y];
      frmMain.ShowColorRGBInfoOnInfoViewer(AColor);
      frmMain.ShowColorCMYKInfoOnInfoViewer(AColor);
    end;
  end;
  
  imgDrawingArea.Canvas.Pen.Mode := pmCopy;
  frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);  // showing current layer coordinates
end;

procedure TfrmChild.PencilMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  HistoryStatePanel: TgmHistoryStatePanel;
  CmdAim           : TCommandAim;
begin
  if imgDrawingArea.RepaintMode <> rmFull then
  begin
    imgDrawingArea.RepaintMode := rmFull;
  end;

  CalcLayerCoord(X, Y);  // get layer space coordinates
  CalcSelectionCoord;    // get selection space coordinates

{ Mouse left button up }

  if Button = mbLeft then
  begin
    if FDrawing then
    begin
      FDrawing := False;

      if Assigned(FSelection) then
      begin
        RemoveMarchingAnts;
        tmrMarchingAnts.Enabled := True;
      end;

      UpdateThumbnailsBySelectedChannel;

      { Create Undo/Redo for Pencil }

      if Assigned(FSelection) then
      begin
        frmMain.FAfterProc.Assign(FSelection.CutOriginal);

        // refresh screen for correcting the view
        ShowProcessedSelection;
      end
      else
      begin
        case FChannelManager.CurrentChannelType of
          wctAlpha:
            begin
              frmMain.FAfterProc.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
            end;

          wctQuickMask:
            begin
              frmMain.FAfterProc.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
            end;

          wctLayerMask:
            begin
              frmMain.FAfterProc.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
            end;

          wctRGB, wctRed, wctGreen, wctBlue:
            begin
              frmMain.FAfterProc.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

              if (FLayerPanelList.SelectedLayerPanel.IsMaskLinked) and
                 (FLayerPanelList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent]) then
              begin
                // remember the newest alpha channel
                ReplaceAlphaChannelWithMask(frmMain.FAfterProc, FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
              end;
            end;
        end;
      end;

      CmdAim := GetCommandAimByCurrentChannel;

      HistoryStatePanel := TgmImageManipulatingStatePanel.Create(
        frmHistory.scrlbxHistory,
        dmHistory.bmp32lstHistory.Bitmap[PENCIL_COMMAND_ICON_INDEX],
        CmdAim,
        'Pencil',
        frmMain.FBeforeProc,
        frmMain.FAfterProc,
        FSelection,
        FChannelManager.SelectedAlphaChannelIndex);

      FHistoryManager.AddHistoryState(HistoryStatePanel);

      // restore the size of ProcessPart
      FLayerPanelList.SelectedLayerPanel.ProcessedPart.SetSize(
        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height);

      FLayerPanelList.SelectedLayerPanel.ProcessedPart.Clear(clBlack32);
    end;
  end;
end;

procedure TfrmChild.FigureToolsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
begin
  CalcLayerCoord(X, Y); // get layer space coordinates

{ Mouse left button down }

  if Button = mbLeft then
  begin
    // showing the coordinates of starting point
    frmMain.ShowOriginalCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
    frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
    
    InitializeCanvas;  // Update the respective canvas to correct status.

    if FChannelManager.CurrentChannelType = wctAlpha then
    begin
      if not Assigned(FChannelManager.SelectedAlphaChannelPanel) then
      begin
        MessageDlg('Could not process more than one alpha channels at a time.', mtError, [mbOK], 0);
        Exit;
      end;
    end;

    if frmMain.StandardTool in [gstStraightLine, gstRegularPolygon,
                                gstRectangle, gstRoundRectangle,
                                gstEllipse] then
    begin
      // calculate coordinates
      FStartPoint := Point( FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100),
                            FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100) );

      FEndPoint   := FStartPoint;

      if Assigned(FSelection) then
      begin
        case FChannelManager.CurrentChannelType of
          wctAlpha, wctQuickMask, wctLayerMask:
            begin
              FActualStartPoint := Point(FMarqueeX, FMarqueeY);
            end;

          wctRGB, wctRed, wctGreen, wctBlue:
            begin
              if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                   lfBackground, lfTransparent] then
              begin
                FActualStartPoint := Point(FMarqueeX, FMarqueeY);
              end
              else
              begin
                FActualStartPoint := Point(FXActual, FYActual);
              end;
            end;
        end;
      end
      else // if not on selection
      begin
        FActualStartPoint := Point(FXActual, FYActual);
      end;

      FActualEndPoint := FActualStartPoint;
    end;

    case frmMain.StandardTool of
      gstStraightLine:
        begin
          DrawStraightLine(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);
        end;

      gstRegularPolygon:
        begin
          DrawRegularPolygon(imgDrawingArea.Canvas, FStartPoint, FEndPoint,
            frmMain.StandardPolygonSides, pmNotXor, FILL_INSIDE);
        end;
        
      gstRectangle:
        begin
          DrawRectangle(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);
        end;
        
      gstRoundRectangle:
        begin
          DrawRoundRect(imgDrawingArea.Canvas, FStartPoint, FEndPoint,
                        frmMain.StandardCornerRadius, pmNotXor);
        end;

      gstEllipse:
        begin
          DrawEllipse(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);
        end;
        
      gstBezierCurve:
        begin
          // clear the last curve
          if FDrawCurveTime > 1 then
          begin
            DrawPolyBezier(imgDrawingArea.Canvas,
              [FStartPoint, FCurvePoint1, FCurvePoint2, FEndPoint], pmNotXor);
          end;

          if FDrawCurveTime = 0 then
          begin
            if Assigned(FSelection) then
            begin
              case FChannelManager.CurrentChannelType of
                wctAlpha, wctQuickMask, wctLayerMask:
                  begin
                    FActualStartPoint := Point(FMarqueeX, FMarqueeY);
                  end;

                wctRGB, wctRed, wctGreen, wctBlue:
                  begin
                    if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                         lfBackground, lfTransparent] then
                    begin
                      FActualStartPoint := Point(FMarqueeX, FMarqueeY);
                    end
                    else
                    begin
                      FActualStartPoint := Point(FXActual, FYActual);
                    end;
                  end;
              end;
            end
            else // if not on selection...
            begin
              FActualStartPoint := Point(FXActual, FYActual);
            end;

            FActualCurvePoint1 := FActualStartPoint;
            FActualCurvePoint2 := FActualStartPoint;
            FActualEndPoint    := FActualStartPoint;

            FStartPoint := Point( FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100),
                                  FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100) );

            FCurvePoint1   := FStartPoint;
            FCurvePoint2   := FStartPoint;
            FEndPoint      := FStartPoint;
            FDrawCurveTime := 1;
          end
          else if FDrawCurveTime = 2 then
          begin
            if Assigned(FSelection) then
            begin
              case FChannelManager.CurrentChannelType of
                wctAlpha, wctQuickMask, wctLayerMask:
                  begin
                    FActualCurvePoint1 := Point(FMarqueeX, FMarqueeY);
                  end;

                wctRGB, wctRed, wctGreen, wctBlue:
                  begin
                    if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                         lfBackground, lfTransparent] then
                    begin
                      FActualCurvePoint1 := Point(FMarqueeX, FMarqueeY);
                    end
                    else
                    begin
                      FActualCurvePoint1 := Point(FXActual, FYActual);
                    end;
                  end;
              end;
            end
            else // if not on selection...
            begin
              FActualCurvePoint1 := Point(FXActual, FYActual);
            end;

            FCurvePoint1 := Point( FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100),
                                   FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100) );
          end
          else if FDrawCurveTime = 3 then
          begin
            if Assigned(FSelection) then
            begin
              case FChannelManager.CurrentChannelType of
                wctAlpha, wctQuickMask, wctLayerMask:
                  begin
                    FActualCurvePoint2 := Point(FMarqueeX, FMarqueeY);
                  end;

                wctRGB, wctRed, wctGreen, wctBlue:
                  begin
                    if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                         lfBackground, lfTransparent] then
                    begin
                      FActualCurvePoint2 := Point(FMarqueeX, FMarqueeY);
                    end
                    else
                    begin
                      FActualCurvePoint2 := Point(FXActual, FYActual);
                    end;
                  end;
              end;
            end
            else // if not on selection...
            begin
              FActualCurvePoint2 := Point(FXActual, FYActual);
            end;

            FCurvePoint2 := Point( FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100),
                                   FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100) );
          end;

          DrawPolyBezier(imgDrawingArea.Canvas,
            [FStartPoint, FCurvePoint1, FCurvePoint2, FEndPoint], pmNotXor);
        end;

      gstPolygon:
        begin
          { If the FMayClick is true, then it indicates that we could add
            points to the polygon vertices array to define a new polygon. }

          if FMayClick then
          begin
            { If the polygon vertices array is empty, at the first polygon
              vertex setting, we add a vertex to the array in MouseDown event,
              the following vertices adding task is completed by MouseUp event. }

            if High(FPolygon) < 0 then
            begin
              SetLength(FActualPolygon, 0);

              FStartPoint.X := FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100);
              FStartPoint.Y := FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100);
              FEndPoint     := FStartPoint;

              SetLength( FPolygon, High(FPolygon) + 2 );
              FPolygon[High(FPolygon)] := FStartPoint;
              SetLength( FActualPolygon, High(FActualPolygon) + 2 );

              if Assigned(FSelection) then
              begin
                case FChannelManager.CurrentChannelType of
                  wctAlpha, wctQuickMask, wctLayerMask:
                    begin
                      FActualPolygon[High(FActualPolygon)] := Point(FMarqueeX, FMarqueeY);
                    end;

                  wctRGB, wctRed, wctGreen, wctBlue:
                    begin
                      if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                           lfBackground, lfTransparent] then
                      begin
                        FActualPolygon[High(FActualPolygon)] := Point(FMarqueeX, FMarqueeY);
                      end
                      else
                      begin
                        FActualPolygon[High(FActualPolygon)] := Point(FXActual, FYActual);
                      end;
                    end;
                end;
              end
              else // not on selection...
              begin
                FActualPolygon[High(FActualPolygon)] := Point(FXActual, FYActual);
              end;
            end;

            { Change the pen mode to pmNotXor, and draw the line again for
              clearing the last temporary line for the polygon. }
            imgDrawingArea.Canvas.Pen.Mode := pmNotXor;

            FEndPoint.X := FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100);
            FEndPoint.Y := FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100);

            imgDrawingArea.Canvas.MoveTo(FStartPoint.X, FStartPoint.Y);
            imgDrawingArea.Canvas.LineTo(FEndPoint.X, FEndPoint.Y);
          end;
        end;
    end;

    FImageProcessed := True; // mark the image has been modified
    FDrawing        := True;
  end;
end;

procedure TfrmChild.FigureToolsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
var
  LColor     : TColor;
  LScalePoint: TPoint;
begin
  CalcLayerCoord(X, Y);  // get layer space coordinates
  CalcSelectionCoord;    // get selection space coordinates

{ Move mouse when mouse left button down }

  if FDrawing then
  begin
    case frmMain.StandardTool of
      gstStraightLine:
        begin
          // clear the last figure
          DrawStraightLine(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);

          FEndPoint := Point( FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100),
                              FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100) );

          // draw the new figure
          DrawStraightLine(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);
        end;

      gstRegularPolygon:
        begin
          DrawRegularPolygon(imgDrawingArea.Canvas, FStartPoint, FEndPoint,
                             frmMain.StandardPolygonSides, pmNotXor, FILL_INSIDE);

          FEndPoint := Point( FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100),
                              FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100) );

          DrawRegularPolygon(imgDrawingArea.Canvas, FStartPoint, FEndPoint,
                             frmMain.StandardPolygonSides, pmNotXor, FILL_INSIDE);
        end;

      gstBezierCurve:
        begin
          // clear the last figure
          if FDrawCurveTime > 0 then
          begin
            DrawPolyBezier(imgDrawingArea.Canvas,
              [FStartPoint, FCurvePoint1, FCurvePoint2, FEndPoint], pmNotXor);
          end;

          if FDrawCurveTime = 0 then
          begin
            Exit;
          end
          else if FDrawCurveTime = 1 then
          begin
            if Assigned(FSelection) then
            begin
              case FChannelManager.CurrentChannelType of
                wctAlpha, wctQuickMask, wctLayerMask:
                  begin
                    FActualCurvePoint2 := Point(FMarqueeX, FMarqueeY);
                  end;

                wctRGB, wctRed, wctGreen, wctBlue:
                  begin
                    if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                         lfBackground, lfTransparent] then
                    begin
                      FActualCurvePoint2 := Point(FMarqueeX, FMarqueeY);
                    end
                    else
                    begin
                      FActualCurvePoint2 := Point(FXActual, FYActual);
                    end;
                  end;
              end;
            end
            else // if not on selection...
            begin
              FActualCurvePoint2 := Point(FXActual, FYActual);
            end;

            FActualEndPoint := FActualCurvePoint2;

            FCurvePoint2 := Point( FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100),
                                   FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100) );

            FEndPoint := FCurvePoint2;
          end
          else if FDrawCurveTime = 2 then
          begin
            if Assigned(FSelection) then
            begin
              case FChannelManager.CurrentChannelType of
                wctAlpha, wctQuickMask, wctLayerMask:
                  begin
                    FActualCurvePoint1 := Point(FMarqueeX, FMarqueeY);
                  end;

                wctRGB, wctRed, wctGreen, wctBlue:
                  begin
                    if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                         lfBackground, lfTransparent] then
                    begin
                      FActualCurvePoint1 := Point(FMarqueeX, FMarqueeY);
                    end
                    else
                    begin
                      FActualCurvePoint1 := Point(FXActual, FYActual);
                    end;
                  end;
              end;
            end
            else // if not on selection...
            begin
              FActualCurvePoint1 := Point(FXActual, FYActual);
            end;

            FCurvePoint1 := Point( FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100),
                                   FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100) );
          end
          else if FDrawCurveTime = 3 then
          begin
            if Assigned(FSelection) then
            begin
              case FChannelManager.CurrentChannelType of
                wctAlpha, wctQuickMask, wctLayerMask:
                  begin
                    FActualCurvePoint2 := Point(FMarqueeX, FMarqueeY);
                  end;

                wctRGB, wctRed, wctGreen, wctBlue:
                  begin
                    if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                         lfBackground, lfTransparent] then
                    begin
                      FActualCurvePoint2 := Point(FMarqueeX, FMarqueeY);
                    end
                    else
                    begin
                      FActualCurvePoint2 := Point(FXActual, FYActual);
                    end;
                  end;
              end;
            end
            else // if not on selection...
            begin
              FActualCurvePoint2 := Point(FXActual, FYActual);
            end;

            FCurvePoint2 := Point( FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100),
                                   FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100) );
          end;

          // draw the new figure
          if FDrawCurveTime > 0 then
          begin
            DrawPolyBezier(imgDrawingArea.Canvas,
              [FStartPoint, FCurvePoint1, FCurvePoint2, FEndPoint], pmNotXor);
          end;
        end;

      gstPolygon:
        begin
          DrawStraightLine(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);

          FEndPoint := Point( FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100),
                              FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100) );

          DrawStraightLine(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);
        end;

      gstRectangle:
        begin
          DrawRectangle(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);

          if ssShift in Shift then
          begin
            LScalePoint := Point( FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100),
                                  FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100) );

            FEndPoint := CalculateRegularFigureEndPoint(FStartPoint, LScalePoint);
          end
          else
          begin
            FEndPoint := Point( FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100),
                                FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100) );
          end;

          DrawRectangle(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);
        end;

      gstRoundRectangle:
        begin
          DrawRoundRect(imgDrawingArea.Canvas, FStartPoint, FEndPoint,
                        frmMain.StandardCornerRadius, pmNotXor);

          if ssShift in Shift then
          begin
            LScalePoint := Point( FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100),
                                  FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100) );

            FEndPoint := CalculateRegularFigureEndPoint(FStartPoint, LScalePoint);
          end
          else
          begin
            FEndPoint := Point( FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100),
                                FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100) );
          end;

          DrawRoundRect(imgDrawingArea.Canvas, FStartPoint, FEndPoint,
                        frmMain.StandardCornerRadius, pmNotXor);
        end;

      gstEllipse:
        begin
          DrawEllipse(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);

          if ssShift in Shift then
          begin
            LScalePoint := Point( FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100),
                                  FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100) );

            FEndPoint := CalculateRegularFigureEndPoint(FStartPoint, LScalePoint);
          end
          else
          begin
            FEndPoint := Point( FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100),
                                FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100) );
          end;

          DrawEllipse(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);
        end;
    end;
  end
  else // if the FDrawing = False
  begin
    if (FXActual >= 0) and
       (FYActual >= 0) and
       (FXActual <= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width) and
       (FYActual <= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height) then
    begin
      // showing color info
      LColor := imgDrawingArea.Canvas.Pixels[X, Y];
      frmMain.ShowColorRGBInfoOnInfoViewer(LColor);
      frmMain.ShowColorCMYKInfoOnInfoViewer(LColor);
    end;
  end;
  
  imgDrawingArea.Canvas.Pen.Mode := pmCopy;
  frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);  // showing current layer coordinates
end; 

procedure TfrmChild.FigureToolsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
begin
  if imgDrawingArea.RepaintMode <> rmFull then
  begin
    imgDrawingArea.RepaintMode := rmFull;
  end;

  CalcLayerCoord(X, Y);  // get layer space coordinates
  CalcSelectionCoord;    // get selection space coordinates
  
{ Mouse left button up }

  if Button = mbLeft then
  begin
    if FDrawing then
    begin
      FDrawing := False;

      if Assigned(FSelection) then
      begin
        // on special layers...
        if (FChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue]) and
           (not (FLayerPanelList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent])) then
        begin
          ProcessFigureMouseUpOnLayer(Shift);
        end
        else
        begin
          ProcessFigureMouseUpOnSelection(Shift);
        end;
      end
      else // if not on selection...
      begin
        if FChannelManager.CurrentChannelType in [wctAlpha, wctQuickMask, wctLayerMask] then
        begin
          ProcessFigureMouseUpOnSpecialChannels(Shift);
        end
        else
        begin
          ProcessFigureMouseUpOnLayer(Shift);
        end;
      end;
    end;

    frmMain.UpdateStandardOptions;

    FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Canvas.Pen.Mode := pmCopy;
    FLayerPanelList.SelectedLayerPanel.ProcessedPart.Canvas.Pen.Mode          := pmCopy;
    FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp.Canvas.Pen.Mode   := pmCopy;
  end;
end;

// Move Page
procedure TfrmChild.MoveToolsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  LMenuPopupPoint: TPoint;
begin
  CalcLayerCoord(X, Y);  // get layer space coordinates

{ Mouse left button down }
  if Button = mbLeft then
  begin
    // showing coordinates of starting point
    frmMain.ShowOriginalCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
    frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);

    FImageProcessed := True; // mark the image has been modified
    FDrawing        := True;

    case frmMain.StandardTool of
      gstMoveObjects:
        begin
          PopupMenu         := nil;
          FMoveDrawingState := dsNotDrawing;

          // get handle that selected by the mouse
          FMoveDrawingHandle := FLayerPanelList.GetSelectedHandleAtPointOnFigureLayer(FXActual, FYActual);

          // if the mouse is pointing on one of the following handles...
          if FMoveDrawingHandle in [dhAXAY, dhBXBY, dhAXBY, dhBXAY, dhLeftHalfAYBY,
                                    dhRightHalfAYBY, dhTopHalfAXBX, dhBottomHalfAXBX,
                                    dhCurvePoint1, dhCurvePoint2, dhLineStart,
                                    dhLineEnd, dhPolygonPoint] then
          begin
            { Let FSelectedFigure points to current selected figure.
              If there are more than one figures were selected,
              the GetFirstSelectedFigure() routine will return nil. }
            FSelectedFigure       := FLayerPanelList.GetFirstSelectedFigure;
            Screen.Cursor         := SetCursorByHandle(FMoveDrawingHandle);
            imgDrawingArea.Cursor := Screen.Cursor;
            FDrawingBasePoint     := Point(FXActual, FYActual);
            FMoveDrawingState     := dsStretchCorner;
            FDrawing              := True;
            
            FHandleLayer.Bitmap.Clear($00FFFFFF);
            FHandleLayer.Bitmap.Changed;

            FLayerPanelList.DrawDeselectedFiguresOnSelectedFigureLayer(imgDrawingArea.Layers);
            FLayerPanelList.ApplyMaskOnSelectedFigureLayer;

            imgDrawingArea.Bitmap.Changed;
            imgDrawingArea.Update;

            FLayerPanelList.DrawSelectedFiguresOnCanvas(imgDrawingArea.Canvas, pmNotXor,
                                                        FLayerTopLeft, FMagnification, fdmRGB);

            if Assigned(FSelectedFigure) then
            begin
              if FMoveDrawingHandle = dhAXAY
              then FRegularBasePoint := FSelectedFigure.FEndPoint
              else
              if FMoveDrawingHandle = dhBXBY
              then FRegularBasePoint := FSelectedFigure.FStartPoint
              else
              if FMoveDrawingHandle = dhAXBY
              then FRegularBasePoint := Point(FSelectedFigure.FEndPoint.X, FSelectedFigure.FStartPoint.Y)
              else
              if FMoveDrawingHandle = dhBXAY
              then FRegularBasePoint := Point(FSelectedFigure.FStartPoint.X, FSelectedFigure.FEndPoint.Y);

              FDrawingBasePoint     := Point(FXActual, FYActual);
              FAccumTranslateVector := Point(0, 0);                    // Undo/Redo
              FOldFigure            := FSelectedFigure.GetSelfBackup;  // For Undo/Redo;
            end;
          end
          else
          begin
            { If the mouse is not pointing on any control handles, then we check
              whether the mouse is pointing on any of figure objects. }
            if FLayerPanelList.IfPointOnSelectedFigureOnFigureLayer(FXActual, FYActual) then
            begin
              FDrawingBasePoint     := Point(FXActual, FYActual);
              Screen.Cursor         := crDrag;
              imgDrawingArea.Cursor := crDrag;
              FMoveDrawingState     := dsTranslate;
              FDrawing              := True;
              FAccumTranslateVector := Point(0, 0); // Undo/Redo

              if FHandleLayer <> nil then
              begin
                FHandleLayer.Bitmap.Clear($00FFFFFF);
                FHandleLayer.Bitmap.Changed;
              end;

              FLayerPanelList.DrawDeselectedFiguresOnSelectedFigureLayer(imgDrawingArea.Layers);
              FLayerPanelList.ApplyMaskOnSelectedFigureLayer;

              imgDrawingArea.Bitmap.Changed;
              imgDrawingArea.Update;

              FLayerPanelList.DrawSelectedFiguresOnCanvas(imgDrawingArea.Canvas, pmNotXor,
                                                          FLayerTopLeft, FMagnification, fdmRGB);
            end
            else
            begin
              // remember the old selected figures info for Undo/Redo
              RecordOldFigureSelectedData;

              // select figures
              if not (ssShift in Shift)
              then FLayerPanelList.DeselectAllFiguresOnFigureLayer;

              FLayerPanelList.SelectFiguresOnFigureLayer(Shift, FXActual, FYActual);

              if FLayerPanelList.SelectedFigureCountOnFigureLayer > 0 then
              begin
                FDrawingBasePoint     := Point(FXActual, FYActual);
                Screen.Cursor         := crDrag;
                imgDrawingArea.Cursor := crDrag;
                FMoveDrawingState     := dsTranslate;
                FDrawing              := True;

                if FHandleLayer <> nil then
                begin
                  FHandleLayer.Bitmap.Clear($00FFFFFF);
                  FHandleLayer.Bitmap.Changed;
                end;

                FLayerPanelList.DrawDeselectedFiguresOnSelectedFigureLayer(imgDrawingArea.Layers);
                FLayerPanelList.ApplyMaskOnSelectedFigureLayer;

                imgDrawingArea.Bitmap.Changed;
                imgDrawingArea.Update;

                FLayerPanelList.DrawSelectedFiguresOnCanvas(imgDrawingArea.Canvas, pmNotXor,
                                                            FLayerTopLeft, FMagnification, fdmRGB);
              end;

              // If the old info is different with the new info, then create Undo/Redo.
              if High(FOldSelectedFigureInfoArray) <> High(FLayerPanelList.FSelectedFigureInfoArray) then
              begin
                if  ( High(FOldSelectedFigureInfoArray) >= 0 )
                and (FLayerPanelList.SelectedFigureCountOnFigureLayer = 0)
                then CreateSelectFigureUndoRedo(sfmDeselect)
                else CreateSelectFigureUndoRedo(sfmSelect);
              end;
            end;
          end;
        end;

      gstPartiallySelect, gstTotallySelect:
        begin
          with imgDrawingArea.Canvas do
          begin
            Pen.Color   := RUBBER_BAND_PEN_COLOR;
            Pen.Style   := RUBBER_BAND_PEN_STYLE;
            Pen.Width   := RUBBER_BAND_PEN_WIDTH;
            Brush.Color := RUBBER_BAND_BRUSH_COLOR;
            Brush.Style := RUBBER_BAND_BRUSH_STYLE;
          end;

          FStartPoint := Point( FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100),
                                FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100) );

          FEndPoint         := FStartPoint;
          FActualStartPoint := Point(FXActual, FYActual);
          FRegionSelectOK   := False;
        end;
    end;
  end
  else
  if Button = mbRight then  // Mouse Right Button Down 
  begin
    if frmMain.StandardTool = gstMoveObjects then
    begin
      // get handle that selected by the mouse
      FMoveDrawingHandle := FLayerPanelList.GetSelectedHandleAtPointOnFigureLayer(FXActual, FYActual);

      // if the mouse selected one of the following curve control handles...
      if FMoveDrawingHandle in [dhCurvePoint1, dhCurvePoint2] then
      begin
        { Let FSelectedFigure points to current selected figure.
          If there are more than one figures were selected,
          the GetFirstSelectedFigure() routine will return nil. }
        FSelectedFigure := nil;
        FSelectedFigure := FLayerPanelList.GetFirstSelectedFigure;
        
        // there is only one figure was selected...
        if Assigned(FSelectedFigure) then
        begin
          { If the two curve control handles both at the same postion, then
            showing a pop-up menu to allow the users to make decision of
            which handle they want to select. }
          if  (FSelectedFigure.FCurvePoint1.X = FSelectedFigure.FCurvePoint2.X)
          and (FSelectedFigure.FCurvePoint1.Y = FSelectedFigure.FCurvePoint2.Y) then
          begin
            // connect the pop-up menu to the form and showing it at current position
            PopupMenu := pmnChangeCurveControlPoints;
             
            GetCursorPos(LMenuPopupPoint);
            pmnChangeCurveControlPoints.Popup(LMenuPopupPoint.X, LMenuPopupPoint.Y);
          end
          else
          begin
            PopupMenu := nil;
          end;
        end;
      end
      else
      begin
        PopupMenu := nil; // disconnect the pop-up menu to the form
      end;
    end;
  end;
end;

procedure TfrmChild.MoveToolsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
var
  LNewPoint, LTranslateVector: TPoint;
  LColor                   : TColor;
begin
  CalcLayerCoord(X, Y);  // get layer space coordinates
  
{ Move mouse when mouse left button down }
  if FDrawing then
  begin
    case frmMain.StandardTool of
      gstMoveObjects:
        begin
          case FMoveDrawingState of
            dsStretchCorner:
              begin
                // clear the old figure
                FLayerPanelList.DrawSelectedFiguresOnCanvas(
                  imgDrawingArea.Canvas, pmNotXor, FLayerTopLeft,
                  FMagnification, fdmRGB);

                if Assigned(FSelectedFigure) then
                begin
                  if (FSelectedFigure.Flag = ffSquare) or
                     (FSelectedFigure.Flag = ffRoundSquare) or
                     (FSelectedFigure.Flag = ffCircle) then
                  begin
                    if FMoveDrawingHandle in [dhAXAY, dhBXBY, dhAXBY, dhBXAY] then
                    begin
                      FSelectedFigure.FStartPoint := FRegularBasePoint;
                      FSelectedFigure.FEndPoint   := CalculateRegularFigureEndPoint(FRegularBasePoint, Point(FXActual, FYActual));
                    end;
                  end
                  else
                  begin
                    case FMoveDrawingHandle of
                      dhAXAY,
                      dhLineStart:
                        begin
                          FSelectedFigure.FStartPoint := Point(FXActual, FYActual);
                        end;
                        
                      dhBXBY,
                      dhLineEnd:
                        begin
                          FSelectedFigure.FEndPoint := Point(FXActual, FYActual);
                        end;

                      dhAXBY:
                        begin
                          FSelectedFigure.FStartPoint := Point(FXActual, FSelectedFigure.FStartPoint.Y);
                          FSelectedFigure.FEndPoint   := Point(FSelectedFigure.FEndPoint.X, FYActual);
                        end;

                      dhBXAY:
                        begin
                          FSelectedFigure.FStartPoint := Point(FSelectedFigure.FStartPoint.X, FYActual);
                          FSelectedFigure.FEndPoint   := Point(FXActual, FSelectedFigure.FEndPoint.Y);
                        end;

                      dhLeftHalfAYBY:
                        begin
                          FSelectedFigure.FStartPoint := Point(FXActual, FSelectedFigure.FStartPoint.Y);
                        end;
                        
                      dhRightHalfAYBY:
                        begin
                          FSelectedFigure.FEndPoint := Point(FXActual, FSelectedFigure.FEndPoint.Y);
                        end;
                        
                      dhTopHalfAXBX:
                        begin
                          FSelectedFigure.FStartPoint := Point(FSelectedFigure.FStartPoint.X, FYActual);
                        end;
                        
                      dhBottomHalfAXBX:
                        begin
                          FSelectedFigure.FEndPoint := Point(FSelectedFigure.FEndPoint.X, FYActual);
                        end;
                        
                      dhCurvePoint1 :
                        begin
                          FSelectedFigure.FCurvePoint1 := Point(FXActual, FYActual);
                        end;
                        
                      dhCurvePoint2:
                        begin
                          FSelectedFigure.FCurvePoint2 := Point(FXActual, FYActual);
                        end;

                      dhPolygonPoint:
                        begin
                          if FSelectedFigure.Flag = ffPolygon then
                          begin
                            { If the mouse selected the first point of the polygon,
                              then we need to modify both the first and last point
                              of the polygon. } 
                            if FSelectedFigure.PolygonCurrentPointIndex = Low(FSelectedFigure.FPolygonPoints) then
                            begin
                              FSelectedFigure.FPolygonPoints[Low(FSelectedFigure.FPolygonPoints)]  := Point(FXActual, FYActual);
                              FSelectedFigure.FPolygonPoints[High(FSelectedFigure.FPolygonPoints)] := Point(FXActual, FYActual);
                            end
                            else
                            begin
                              FSelectedFigure.FPolygonPoints[FSelectedFigure.PolygonCurrentPointIndex] := Point(FXActual, FYActual);
                            end;
                          end
                          else
                          if FSelectedFigure.Flag = ffRegularPolygon then
                          begin
                            FSelectedFigure.FEndPoint := Point(FXActual, FYActual);

                            CalcRegularPolygonVertices(
                              FSelectedFigure.FPolygonPoints,
                              FSelectedFigure.FStartPoint,
                              Point(FXActual, FYActual),
                              frmMain.StandardPolygonSides );
                          end;
                        end;
                    end;
                  end;
                end;

                // drawing the new figure
                FLayerPanelList.DrawSelectedFiguresOnCanvas(imgDrawingArea.Canvas, pmNotXor,
                                                            FLayerTopLeft, FMagnification, fdmRGB);

                // remember the position change amount of selected point of current selected figure
                LNewPoint             := Point(FXActual, FYActual);
                LTranslateVector      := SubtractPoints(LNewPoint, FDrawingBasePoint);
                FAccumTranslateVector := AddPoints(FAccumTranslateVector, LTranslateVector);  //  Undo/Redo for figures translation
                FDrawingBasePoint     := LNewPoint;
              end;

            dsTranslate:
              begin
                // clear the old figure
                FLayerPanelList.DrawSelectedFiguresOnCanvas(
                  imgDrawingArea.Canvas, pmNotXor, FLayerTopLeft,
                  FMagnification, fdmRGB);

                // calculate the translation vector
                LNewPoint             := Point(FXActual, FYActual);
                LTranslateVector      := SubtractPoints(LNewPoint, FDrawingBasePoint);
                FAccumTranslateVector := AddPoints(FAccumTranslateVector, LTranslateVector);  // Undo/Redo for figures translation

                FLayerPanelList.TranslateSelectedFigures(LTranslateVector);

                // drawing the new figure
                FLayerPanelList.DrawSelectedFiguresOnCanvas(
                  imgDrawingArea.Canvas, pmNotXor, FLayerTopLeft,
                  FMagnification, fdmRGB);

                FDrawingBasePoint := LNewPoint;
              end;
          end;
        end;

      gstPartiallySelect, gstTotallySelect:
        begin
          DrawRectangle(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);

          FActualEndPoint := Point(FXActual, FYActual);
          FEndPoint       := Point( FLayerTopLeft.X + MulDiv(FActualEndPoint.X, FMagnification, 100),
                                    FLayerTopLeft.Y + MulDiv(FActualEndPoint.Y, FMagnification, 100) );

          DrawRectangle(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);
        end;
    end;
  end
  else // if the FDrawing = False
  begin
    FMoveDrawingHandle := FLayerPanelList.GetSelectedHandleAtPointOnFigureLayer(FXActual, FYActual);

    // change cursor according to different selected handles
    if FMoveDrawingHandle in [dhAXAY, dhBXBY, dhAXBY, dhBXAY, dhLeftHalfAYBY,
                              dhRightHalfAYBY, dhTopHalfAXBX, dhBottomHalfAXBX,
                              dhLineStart, dhLineEnd, dhCurvePoint1,
                              dhCurvePoint2, dhPolygonPoint]
    then
    begin
      Screen.Cursor         := SetCursorByHandle(FMoveDrawingHandle);
      imgDrawingArea.Cursor := Screen.Cursor;
    end
    else
    begin
      if FLayerPanelList.IfPointOnFigureOnFigureLayer(FXActual, FYActual) then
      begin
        Screen.Cursor         := crHandPoint;
        imgDrawingArea.Cursor := crHandPoint;
      end
      else
      begin
        Screen.Cursor := crDefault;

        case frmMain.StandardTool of
          gstMoveObjects:
            begin
              imgDrawingArea.Cursor := crMoveSelection;
            end;

          gstPartiallySelect,
          gstTotallySelect:
          begin
            imgDrawingArea.Cursor := crCross;
          end;
        end;
      end;
    end;

    if (FXActual >= 0) and
       (FYActual >= 0) and
       (FXActual <= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width) and
       (FYActual <= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height) then
    begin
      // showing color info that under the mouse pointer
      LColor := imgDrawingArea.Canvas.Pixels[X, Y];
      
      frmMain.ShowColorRGBInfoOnInfoViewer(LColor);
      frmMain.ShowColorCMYKInfoOnInfoViewer(LColor);
    end;
  end;

  imgDrawingArea.Canvas.Pen.Mode := pmCopy;
  frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
end;

procedure TfrmChild.MoveToolsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  CalcLayerCoord(X, Y);  // get layer space coordinates

{ Mouse left button up }

  if Button = mbLeft then
  begin
    if FDrawing then
    begin
      Screen.Cursor := crDefault;

      if FHandleLayer = nil then
      begin
        CreateFigureHandleLayer;
      end;

      case frmMain.StandardTool of
        gstMoveObjects:
          begin
            case FMoveDrawingState of
              dsTranslate, dsStretchCorner:
                begin
                  imgDrawingArea.Cursor := crMoveSelection;

                  if Assigned(FSelectedFigure) then
                  begin
                    if FSelectedFigure.Flag in [ffRectangle, ffSquare,
                                                ffRoundRectangle, ffRoundSquare,
                                                ffEllipse, ffCircle] then
                    begin
                      FSelectedFigure.StandardizeOrder;
                    end;

                    if FSelectedFigure.Flag in [ffRegularPolygon, ffSquare,
                                                ffRoundSquare, ffCircle] then
                    begin
                      FSelectedFigure.CalcOrigin;
                      FSelectedFigure.CalcRadius;
                    end;
                  end;

                  if (FAccumTranslateVector.X <> 0) or
                     (FAccumTranslateVector.Y <> 0) then
                  begin
                    // Undo/Redo
                    LHistoryStatePanel := nil;

                    if FMoveDrawingState = dsTranslate then
                    begin
                      LHistoryStatePanel := TgmTranslateFigureStatePanel.Create(
                        frmHistory.scrlbxHistory,
                        dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
                        FAccumTranslateVector);
                    end
                    else
                    if FMoveDrawingState = dsStretchCorner then
                    begin
                      LHistoryStatePanel := TgmStretchFigureStatePanel.Create(
                        frmHistory.scrlbxHistory,
                        dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
                        FOldFigure,
                        FSelectedFigure);

                      FreeAndNil(FOldFigure);
                    end;

                    FAccumTranslateVector := Point(0, 0);

                    if Assigned(LHistoryStatePanel) then
                    begin
                      FHistoryManager.AddHistoryState(LHistoryStatePanel);
                    end;
                  end;
                end;
            end;
          end;

        gstPartiallySelect, gstTotallySelect:
          begin
            if FLayerPanelList.HasFiguresOnFigureLayer then
            begin
              CalcHandleLayerOffsetVector;

              FEndPoint.X := FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100);
              FEndPoint.Y := FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100);

              DrawRectangle(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);

              FActualEndPoint := Point(FXActual, FYActual);
              PointStandardizeOrder(FActualStartPoint, FActualEndPoint);

              FRegionSelectOK := ( ABS(FActualStartPoint.X - FActualEndPoint.X) > 4 ) and
                                 ( ABS(FActualStartPoint.Y - FActualEndPoint.Y) > 4 );

              if FRegionSelectOK then
              begin
                if frmMain.StandardTool = gstPartiallySelect then
                begin
                  FLayerPanelList.SelectRectOnFigureLayer(fsimPartiallyInclude,
                    FActualStartPoint, FActualEndPoint);
                end
                else
                if frmMain.StandardTool = gstTotallySelect then
                begin
                  FLayerPanelList.SelectRectOnFigureLayer(fsimTotallyInclude,
                    FActualStartPoint, FActualEndPoint);
                end;

                FLayerPanelList.DrawSelectedFiguresHandles(FHandleLayer.Bitmap,
                  FHandleLayerOffsetVector);

                // if there is selected figure then switch to Move Figure tool
                if High(FLayerPanelList.FSelectedFigureInfoArray) > (-1) then
                begin
                  frmMain.spdbtnMoveObjects.Down := True;
                  frmMain.ChangeStandardTools(frmMain.spdbtnMoveObjects);
                end;
              end;

              SetLength(FOldSelectedFigureInfoArray, 0);
              FOldSelectedFigureInfoArray := nil;

              SetLength(FOldSelectedFigureLayerIndexArray, 0);
              FOldSelectedFigureLayerIndexArray := nil;

              // if the old info is different with the new info, then create Undo/Redo
              if High(FOldSelectedFigureInfoArray) <> High(FLayerPanelList.FSelectedFigureInfoArray) then
              begin
                CreateSelectFigureUndoRedo(sfmSelect);
              end;
            end
            else
            begin
              FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
            end;
          end;
      end;

      if FLayerPanelList.HasFiguresOnFigureLayer then
      begin
        FLayerPanelList.DrawAllFiguresOnSelectedFigureLayer(imgDrawingArea.Layers);
        FLayerPanelList.ApplyMaskOnSelectedFigureLayer;
        FLayerPanelList.DrawSelectedFiguresHandles(FHandleLayer.Bitmap, FHandleLayerOffsetVector);
        FHandleLayer.Bitmap.Changed;
        FLayerPanelList.UpdateSelectedFigureLayerThumbnail(imgDrawingArea.Layers);
        frmMain.UpdateStandardOptions;
      end;

      if FLayerPanelList.SelectedFigureCountOnFigureLayer = 1 then
      begin
        FSelectedFigure := nil;
        FSelectedFigure := FLayerPanelList.GetFirstSelectedFigure;
      end
      else
      begin
        FSelectedFigure := nil;
      end;

      // update thumbnails
      ActiveChildForm.FChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.FLayerPanelList);
    end;

    FDrawing := False;
    FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Canvas.Pen.Mode := pmCopy;
    FLayerPanelList.SelectedLayerPanel.ProcessedPart.Canvas.Pen.Mode          := pmCopy;
    FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp.Canvas.Pen.Mode   := pmCopy;
  end;
end;

procedure TfrmChild.BrushToolsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  BrushName       : string;
  BlurSharpenBrush: TgmBlurSharpenBrush;
  CloneStamp      : TgmCloneStamp;
  SampleBmp       : TBitmap32;
  BrushArea       : TRect;
  TempBmp         : TBitmap32;
begin
  CalcLayerCoord(X, Y);  // get layer space coordinates
  
{ Mouse left button down }

  if Button = mbLeft then
  begin
    // showing the coordinates of the starting point
    frmMain.ShowOriginalCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
    frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);

    if FChannelManager.CurrentChannelType = wctAlpha then
    begin
      if not Assigned(FChannelManager.SelectedAlphaChannelPanel) then
      begin
        MessageDlg('Could not process more than one alpha channels at a time.', mtError, [mbOK], 0);
        Exit;
      end;
    end;

    if (FChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue]) then
    begin
      if not (FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                lfBackground, lfTransparent]) then
      begin
        BrushName := frmMain.GetBrushName;

        MessageDlg('Could not use the ' + BrushName + ' because the' + #10#13 +
                   'content of the layer is not directly' + #10#13 +
                   'editable.', mtError, [mbOK], 0);
        Exit;
      end;
    end;

    // for performance, we just need to render the processed area
    if imgDrawingArea.RepaintMode <> rmOptimizer then
    begin
      imgDrawingArea.RepaintMode := rmOptimizer;
    end;

    // don't draw the Marching-Ants lines dynamically when processing image
    if tmrMarchingAnts.Enabled then
    begin
      tmrMarchingAnts.Enabled := False;
    end;

    if Assigned(FSelection) then
    begin
      // confirm the foreground of the selection to avoid the distortion of the brush stroke
      FSelection.ConfirmForeground;

      CalcSelectionCoord;
      RemoveMarchingAnts;
      DrawMarchingAnts;

      Felozox          := FMarqueeX;
      Felozoy          := FMarqueeY;
      FPrevStrokePoint := Point(FMarqueeX, FMarqueeY)
    end
    else
    begin
      Felozox          := FXActual;
      Felozoy          := FYActual;
      FPrevStrokePoint := Point(FXActual, FYActual);
    end;

    if Assigned(frmMain.GMBrush) then
    begin
      frmMain.GMBrush.IsPreserveTransparency :=
        FLayerPanelList.SelectedLayerPanel.IsLockTransparency;
    end;

    if Assigned(frmMain.AirBrush) then
    begin
      frmMain.AirBrush.IsLockTransparent :=
        FLayerPanelList.SelectedLayerPanel.IsLockTransparency;
    end;

    if Assigned(frmMain.JetGun) then
    begin
      frmMain.JetGun.IsLockTransparent :=
        FLayerPanelList.SelectedLayerPanel.IsLockTransparency;
    end;

    // Remember bitmap for create Undo/Redo action.
    if Assigned(FSelection) then
    begin
      frmMain.FBeforeProc.Assign(FSelection.CutOriginal);
    end
    else
    begin
      case FChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
            begin
              frmMain.FBeforeProc.Assign(
                FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
            end;
          end;

        wctQuickMask:
          begin
            if Assigned(FChannelManager.QuickMaskPanel) then
            begin
              frmMain.FBeforeProc.Assign(
                FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
            end;
          end;

        wctLayerMask:
        begin
          frmMain.FBeforeProc.Assign(
            FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
        end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            frmMain.FBeforeProc.Assign(
              FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

            if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
            begin
              ReplaceAlphaChannelWithMask(frmMain.FBeforeProc,
                FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
            end;
          end;
      end;
    end;

    Ftavolsag := 0; // For BrushLine function

    case frmMain.BrushTool of
      btPaintBrush:
        begin
          tmrSpecialBrush.Enabled := False;

          if Assigned(frmMain.GMBrush) and
             (frmMain.GMBrush.BrushID = bidPaintBrush) and
             Assigned(frmPaintingBrush.BrushStroke) then
          begin
            with frmMain.GMBrush do
            begin
              SetBlendMode(frmMain.BrushBlendMode);
              SetBrushOpacity(frmMain.BrushOpacity);
              SetPaintingStroke(frmPaintingBrush.BrushStroke);
            end;

            // set brush color
            if FChannelManager.CurrentChannelType in [
                 wctAlpha, wctQuickMask, wctLayerMask] then
            begin
              TgmPaintBrush(frmMain.GMBrush).SetColor( Color32(frmMain.ForeGrayColor) );
            end
            else
            begin
              TgmPaintBrush(frmMain.GMBrush).SetColor( Color32(frmMain.GlobalForeColor) );
            end;

            { Brush Dynamics Settings }
            with frmMain.GMBrush do
            begin
              SetDynamicSize(frmPaintingBrush.BrushStroke,
                             frmBrushDynamics.SizeDynamicsState,
                             frmBrushDynamics.SizeSteps);

              SetDynamicOpacity(frmMain.BrushOpacity,
                                frmBrushDynamics.OpacityDynamicsState,
                                frmBrushDynamics.OpacitySteps);

              if FChannelManager.CurrentChannelType in [
                   wctAlpha, wctQuickMask, wctLayerMask] then
              begin
                SetDynamicColor( Color32(frmMain.ForeGrayColor),
                                 Color32(frmMain.BackGrayColor),
                                 frmBrushDynamics.ColorDynamicsState,
                                 frmBrushDynamics.ColorSteps );
              end
              else
              begin
                SetDynamicColor( Color32(frmMain.GlobalForeColor),
                                 Color32(frmMain.GlobalBackColor),
                                 frmBrushDynamics.ColorDynamicsState,
                                 frmBrushDynamics.ColorSteps );
              end;
            end;

            if Assigned(FSelection) then
            begin
              { Assigned the CutOriginal to FSouceBMP of the Brush to let the
                cropped area as the background, and then cut area from it as
                the new cropped area, and drawing the brush in the new area
                to make the brush opacity setting takes effect. }
              frmMain.GMBrush.UpdateSourceBitmap(FSelection.CutOriginal);

              frmMain.GMBrush.Paint(FSelection.CutOriginal, FMarqueeX, FMarqueeY,
                                    FChannelManager.ChannelSelectedSet);

              BrushArea := frmMain.GMBrush.GetBrushArea(FMarqueeX, FMarqueeY);
              ShowSelectionAtBrushStroke(BrushArea);
            end
            else
            begin
              case FChannelManager.CurrentChannelType of
                wctAlpha:
                  begin
                    frmMain.GMBrush.UpdateSourceBitmap(
                      FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);

                    frmMain.GMBrush.Paint(
                      FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    // get refresh area
                    BrushArea             := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);
                    BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                    BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);
                    
                    FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed(BrushArea);
                  end;

                wctQuickMask:
                  begin
                    frmMain.GMBrush.UpdateSourceBitmap(
                      FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);

                    frmMain.GMBrush.Paint(
                      FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    // get refresh area
                    BrushArea             := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);
                    BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                    BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                    FChannelManager.QuickMaskPanel.AlphaLayer.Changed(BrushArea);
                  end;

                wctLayerMask:
                  begin
                    frmMain.GMBrush.UpdateSourceBitmap(
                      FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);

                    frmMain.GMBrush.Paint(
                      FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    // paint on mask channel preview layer, too
                    if Assigned(FChannelManager.LayerMaskPanel) then
                    begin
                      frmMain.GMBrush.Paint(
                        FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap,
                        FXActual, FYActual, FChannelManager.ChannelSelectedSet);
                    end;

                    // get brush area
                    BrushArea := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);

                    if not FLayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
                    begin
                      ApplyMask(BrushArea);
                    end
                    else
                    begin
                      // on special layers, we need save the new mask into its alpha channels
                      FLayerPanelList.SelectedLayerPanel.UpdateLayerAlphaWithMask(BrushArea);

                      // convert from bitmap coordinate space to image coordinates space
                      BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                      BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                    end;
                  end;

                wctRGB, wctRed, wctGreen, wctBlue:
                  begin
                    // must be on layer

                    // get refresh area
                    BrushArea := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);

                    TempBmp := TBitmap32.Create;
                    try
                      TempBmp.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

                      // restore the alpha channel to the state that before applied mask
                      if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                      begin
                        ReplaceAlphaChannelWithMask(TempBmp,
                          FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                      end;

                      frmMain.GMBrush.UpdateSourceBitmap(TempBmp);
                    finally
                      TempBmp.Free;
                    end;

                    // restore the alpha channel to the state that before applied mask
                    if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                    begin
                      ReplaceAlphaChannelWithMask(
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                        FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                        BrushArea);
                    end;

                    frmMain.GMBrush.Paint(
                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    if FLayerPanelList.SelectedLayerPanel.IsHasMask then
                    begin
                      GetAlphaChannelBitmap(
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                        FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                        BrushArea);
                                            
                      ApplyMask(BrushArea);
                    end
                    else
                    begin
                      // from bitmap coordinate space to control coordinate space
                      BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                      BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                    end;
                  end;
              end;
            end;
          end;
        end;

      btHistoryBrush:
        begin
          tmrSpecialBrush.Enabled := False;

          if FChannelManager.CurrentChannelType in [wctAlpha, wctQuickMask] then
          begin
            if Assigned(FSelection)
            then tmrMarchingAnts.Enabled := True;

            MessageDlg('Could not use the history brush because the' + #10#13 +
                       'history state lacks a corresponding channel.', mtError, [mbOK], 0);

            Exit;
          end
          else
          if FChannelManager.CurrentChannelType = wctLayerMask then
          begin
            if Assigned(FSelection)
            then tmrMarchingAnts.Enabled := True;

            MessageDlg('Could not use the history brush because the' + #10#13 +
                       'history state does not contain a corresponding' + #10#13 +
                       'layer.', mtError, [mbOK], 0);

            Exit;
          end
          else // must be on layer
          begin
            if Assigned(frmMain.GMBrush) and
               (frmMain.GMBrush.BrushID = bidHistoryBrush) and
               Assigned(frmPaintingBrush.BrushStroke) then
            begin
              with frmMain.GMBrush do
              begin
                SetBlendMode(frmMain.BrushBlendMode);
                SetBrushOpacity(frmMain.BrushOpacity);
                SetPaintingStroke(frmPaintingBrush.BrushStroke);

                { Brush Dynamics Settings }
                SetDynamicSize(frmPaintingBrush.BrushStroke,
                               frmBrushDynamics.SizeDynamicsState,
                               frmBrushDynamics.SizeSteps);

                SetDynamicOpacity(frmMain.BrushOpacity,
                                  frmBrushDynamics.OpacityDynamicsState,
                                  frmBrushDynamics.OpacitySteps);
              end;

              TgmHistoryBrush(frmMain.GMBrush).LoadHistoryBitmap(FHistoryBitmap);

              if Assigned(FSelection) then
              begin
                with frmMain.GMBrush do
                begin
                  // then setting the history sample offset
                  SelectionOffsetX := FSelection.FMaskBorderStart.X;
                  SelectionOffsetY := FSelection.FMaskBorderStart.Y;

                  // finally, painting
                  UpdateSourceBitmap(FSelection.CutOriginal);

                  Paint(FSelection.CutOriginal, FMarqueeX, FMarqueeY,
                        FChannelManager.ChannelSelectedSet);
                end;

                BrushArea := frmMain.GMBrush.GetBrushArea(FMarqueeX, FMarqueeY);
                ShowSelectionAtBrushStroke(BrushArea);
              end
              else
              begin
                if (FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width  <> FHistoryBitmap.Width) or
                   (FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height <> FHistoryBitmap.Height) then
                begin
                  MessageDlg('Could not use the history brush because the current' + #10#13 +
                             'canvas size does not match that of the history state!', mtError, [mbOK], 0);

                  Exit;
                end
                else
                begin
                  // get refresh area
                  BrushArea := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);

                  TempBmp := TBitmap32.Create;
                  try
                    TempBmp.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

                    // restore the alpha channel to the state that before applied mask
                    if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                    begin
                      ReplaceAlphaChannelWithMask(TempBmp,
                        FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                    end;

                    frmMain.GMBrush.UpdateSourceBitmap(TempBmp);
                  finally
                    TempBmp.Free;
                  end;

                  // restore the alpha channel to the state that before applied mask
                  if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                  begin
                    ReplaceAlphaChannelWithMask(
                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                      FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                      BrushArea);
                  end;

                  frmMain.GMBrush.Paint(
                    FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                    FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                  if FLayerPanelList.SelectedLayerPanel.IsHasMask then
                  begin
                    GetAlphaChannelBitmap(
                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                      FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                      BrushArea);
                      
                    ApplyMask(BrushArea);
                  end
                  else
                  begin
                    // from bitmap coordinate space to control coordinate space
                    BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                    BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);
                    
                    FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                  end;
                end;
              end;
            end;
          end;
        end;

      btCloneStamp:
        begin
          tmrSpecialBrush.Enabled := False;

          if Assigned(frmMain.GMBrush) and
             (frmMain.GMBrush.BrushID = bidCloneStamp) and
             Assigned(frmPaintingBrush.BrushStroke) then
          begin
            { If the users click the mouse with the Alt key is pressed, then
              we redefine the sample point of the clone stamp. And then mark
              the sample point is already defined, and we need to do some
              calculations related to the sample point and current point.
              These task will be done by the single method call -- SetSamplingPoint(). }
            if ssAlt in Shift then
            begin
              TgmCloneStamp(frmMain.GMBrush).SetSamplingPoint(FXActual, FYActual);

              if Assigned(FSelection) then
              begin
                tmrMarchingAnts.Enabled := True;
              end;

              Exit;  // calling Exit() to avoid the OnMouseUp event to be executed.
            end
            else
            begin
              if not TgmCloneStamp(frmMain.GMBrush).IsSamplingPointExist then
              begin
                if Assigned(FSelection) then
                begin
                  tmrMarchingAnts.Enabled := True;
                end;

                MessageDlg('Could not use the cloning stamp because the area to' + #10#13 +
                           'clone has not been defined(Alt-click to define a' + #10#13 +
                           'source point).', mtError, [mbOK], 0);
                Exit;
              end
              else
              begin
                { If the property IsUpdateStampOffset is true, then it indicates
                  that we have already defined a sample point for the clone stamp,
                  we need to calculate the offset vector from current point to
                  sample point. We only need to do this once after the sample
                  point is redefined. }
                if TgmCloneStamp(frmMain.GMBrush).IsUpdateStampOffset then
                begin
                  TgmCloneStamp(frmMain.GMBrush).SetStampPointOffset(FXActual, FYActual);
                end;

                with frmMain.GMBrush do
                begin
                  SetBlendMode(frmMain.BrushBlendMode);
                  SetBrushOpacity(frmMain.BrushOpacity);
                  SetPaintingStroke(frmPaintingBrush.BrushStroke);

                  { Brush Dynamics Settings }
                  SetDynamicSize(frmPaintingBrush.BrushStroke,
                                 frmBrushDynamics.SizeDynamicsState,
                                 frmBrushDynamics.SizeSteps);

                  SetDynamicOpacity(frmMain.BrushOpacity,
                                    frmBrushDynamics.OpacityDynamicsState,
                                    frmBrushDynamics.OpacitySteps);

                  // update the sampling bitmap
                  case FChannelManager.CurrentChannelType of
                    wctAlpha:
                      begin
                        UpdateSourceBitmap(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
                      end;

                    wctQuickMask:
                      begin
                        UpdateSourceBitmap(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
                      end;

                    wctLayerMask:
                      begin
                        UpdateSourceBitmap(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
                      end;

                    wctRGB, wctRed, wctGreen, wctBlue:
                      begin
                        // must be on layer

                        if frmMain.IsUseAllLayers then
                        begin
                          SampleBmp := TBitmap32.Create;
                          try
                            SampleBmp.DrawMode := dmBlend;
                            
                            FLayerPanelList.FlattenLayersToBitmapWithoutMask(SampleBmp, dmBlend);
                            UpdateSourceBitmap(SampleBmp);
                          finally
                            SampleBmp.Free;
                          end;
                        end
                        else
                        begin
                          TempBmp := TBitmap32.Create;
                          try
                            TempBmp.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

                            if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                            begin
                              ReplaceAlphaChannelWithMask(TempBmp,
                                FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                            end;

                            UpdateSourceBitmap(TempBmp);
                          finally
                            TempBmp.Free;
                          end;
                        end;
                      end;
                  end;
                end;

                if Assigned(FSelection) then
                begin
                  with frmMain.GMBrush do
                  begin
                    // then setting the history sample offset
                    SelectionOffsetX := FSelection.FMaskBorderStart.X;
                    SelectionOffsetY := FSelection.FMaskBorderStart.Y;

                    // make a copy of the original bitmap
                    UpdateForeground(FSelection.CutOriginal);

                    // finally, painting
                    Paint(FSelection.CutOriginal, FMarqueeX, FMarqueeY,
                          FChannelManager.ChannelSelectedSet);
                  end;

                  BrushArea := frmMain.GMBrush.GetBrushArea(FMarqueeX, FMarqueeY);
                  ShowSelectionAtBrushStroke(BrushArea);
                end
                else
                begin
                  case FChannelManager.CurrentChannelType of
                    wctAlpha:
                      begin
                        frmMain.GMBrush.UpdateForeground(
                          FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);

                        frmMain.GMBrush.Paint(
                          FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                          FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                        // get refresh area
                        BrushArea             := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);
                        BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                        BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);
                    
                        FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed(BrushArea);
                      end;

                    wctQuickMask:
                      begin
                        frmMain.GMBrush.UpdateForeground(
                          FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);

                        frmMain.GMBrush.Paint(
                          FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                          FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                        // get refresh area
                        BrushArea             := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);
                        BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                        BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                        FChannelManager.QuickMaskPanel.AlphaLayer.Changed(BrushArea);
                      end;

                    wctLayerMask:
                      begin
                        frmMain.GMBrush.UpdateForeground(
                          FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);

                        frmMain.GMBrush.Paint(
                          FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                          FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                        // paint on mask channel preview layer, too
                        if Assigned(FChannelManager.LayerMaskPanel) then
                        begin
                          frmMain.GMBrush.Paint(
                            FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap,
                            FXActual, FYActual, FChannelManager.ChannelSelectedSet);
                        end;

                        // get brush area
                        BrushArea := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);

                        if not FLayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
                        begin
                          ApplyMask(BrushArea);
                        end
                        else
                        begin
                          // on special layers, we need save the new mask into its alpha channels
                          FLayerPanelList.SelectedLayerPanel.UpdateLayerAlphaWithMask(BrushArea);

                          // convert from bitmap coordinate space to image coordinates space
                          BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                          BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                          FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                        end;
                      end;

                    wctRGB, wctRed, wctGreen, wctBlue:
                      begin
                        // must be on layer

                        // get refresh area
                        BrushArea := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);

                        TempBmp := TBitmap32.Create;
                        try
                          TempBmp.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

                          // restore the alpha channel to the state that before applied mask
                          if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                          begin
                            ReplaceAlphaChannelWithMask(TempBmp,
                              FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                          end;

                          frmMain.GMBrush.UpdateForeground(TempBmp);
                        finally
                          TempBmp.Free;
                        end;

                        // restore the alpha channel to the state that before applied mask
                        if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                        begin
                          ReplaceAlphaChannelWithMask(
                            FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                            FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                            BrushArea);
                        end;
                        
                        frmMain.GMBrush.Paint(
                          FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                          FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                        if FLayerPanelList.SelectedLayerPanel.IsHasMask then
                        begin
                          GetAlphaChannelBitmap(
                            FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                            FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                            BrushArea);
                            
                          ApplyMask(BrushArea);
                        end
                        else
                        begin
                          // from bitmap coordinate space to control coordinate space
                          BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                          BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                          FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                        end;
                      end;
                  end;
                end;

                { Draw aim flag of the clone stamp on imgDrawingArea.Canvas
                  with the pen mode of the canvas set to pmNotXor mode. }

                CloneStamp := TgmCloneStamp(frmMain.GMBrush);

                FAimPoint.X := Round( FLayerPanelList.SelectedLayerPanel.AssociatedLayer.GetAdjustedLocation.Left +
                                      (FXActual + CloneStamp.OffsetX) * imgDrawingArea.Scale );

                FAimPoint.Y := Round( FLayerPanelList.SelectedLayerPanel.AssociatedLayer.GetAdjustedLocation.Top +
                                      (FYActual + CloneStamp.OffsetY) * imgDrawingArea.Scale );

                // this method will draw the aim flag with pen mode set to pmNotXor
                CloneStamp.DrawStampAimFlag(imgDrawingArea.Canvas, FAimPoint.X, FAimPoint.Y);
              end;
            end;
          end;
        end;

      btPatternStamp:
        begin
          tmrSpecialBrush.Enabled := False;

          if Assigned(frmMain.GMBrush) and
             (frmMain.GMBrush.BrushID = bidPatternStamp) and
             Assigned(frmPaintingBrush.BrushStroke) then
          begin
            if Assigned(frmPatterns.StampPattern) then
            begin
              with frmMain.GMBrush do
              begin
                SetBlendMode(frmMain.BrushBlendMode);
                SetBrushOpacity(frmMain.BrushOpacity);
                SetPaintingStroke(frmPaintingBrush.BrushStroke);

                { Brush Dynamics Settings }
                SetDynamicSize(frmPaintingBrush.BrushStroke,
                               frmBrushDynamics.SizeDynamicsState,
                               frmBrushDynamics.SizeSteps);

                SetDynamicOpacity(frmMain.BrushOpacity,
                                  frmBrushDynamics.OpacityDynamicsState,
                                  frmBrushDynamics.OpacitySteps);
              end;

              if Assigned(FSelection) then
              begin
                TgmPatternStamp(frmMain.GMBrush).SetPatternBitmap(
                  frmPatterns.StampPattern,
                  FSelection.CutOriginal.Width,
                  FSelection.CutOriginal.Height);

                frmMain.GMBrush.UpdateSourceBitmap(FSelection.CutOriginal);

                frmMain.GMBrush.Paint(FSelection.CutOriginal, FMarqueeX, FMarqueeY,
                                      FChannelManager.ChannelSelectedSet);

                BrushArea := frmMain.GMBrush.GetBrushArea(FMarqueeX, FMarqueeY);
                ShowSelectionAtBrushStroke(BrushArea);
              end
              else
              begin
                TgmPatternStamp(frmMain.GMBrush).SetPatternBitmap(
                  frmPatterns.StampPattern,
                  FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
                  FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height);

                case FChannelManager.CurrentChannelType of
                  wctAlpha:
                    begin
                      frmMain.GMBrush.UpdateSourceBitmap(
                        FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);

                      frmMain.GMBrush.Paint(
                        FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                        FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                      // get refresh area
                      BrushArea             := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);
                      BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                      BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);
                    
                      FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed(BrushArea);
                    end;

                  wctQuickMask:
                    begin
                      frmMain.GMBrush.UpdateSourceBitmap(
                        FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);

                      frmMain.GMBrush.Paint(
                        FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                        FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                      // get refresh area
                      BrushArea             := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);
                      BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                      BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                      FChannelManager.QuickMaskPanel.AlphaLayer.Changed(BrushArea);
                    end;

                  wctLayerMask:
                    begin
                      frmMain.GMBrush.UpdateSourceBitmap(
                        FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);

                      frmMain.GMBrush.Paint(
                        FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                        FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                      // paint on mask channel preview layer, too
                      if Assigned(FChannelManager.LayerMaskPanel) then
                      begin
                        frmMain.GMBrush.Paint(
                          FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap,
                          FXActual, FYActual, FChannelManager.ChannelSelectedSet);
                      end;

                      // get brush area
                      BrushArea := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);

                      if not FLayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
                      begin
                        ApplyMask(BrushArea);
                      end
                      else
                      begin
                        // on special layers, we need save the new mask into its alpha channels
                        FLayerPanelList.SelectedLayerPanel.UpdateLayerAlphaWithMask(BrushArea);

                        // convert from bitmap coordinate space to image coordinates space
                        BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                        BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                      end;
                    end;

                  wctRGB, wctRed, wctGreen, wctBlue:
                    begin
                      // must be on layer

                      // get refresh area
                      BrushArea := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);

                      TempBmp := TBitmap32.Create;
                      try
                        TempBmp.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

                        if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                        begin
                          ReplaceAlphaChannelWithMask(TempBmp,
                            FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                        end;

                        frmMain.GMBrush.UpdateSourceBitmap(TempBmp);
                      finally
                        TempBmp.Free;
                      end;

                      if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                      begin
                        ReplaceAlphaChannelWithMask(
                          FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                          FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                          BrushArea);
                      end;

                      frmMain.GMBrush.Paint(
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                        FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                      if FLayerPanelList.SelectedLayerPanel.IsHasMask then
                      begin
                        GetAlphaChannelBitmap(
                          FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                          FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                          BrushArea);
                          
                        ApplyMask(BrushArea);
                      end
                      else
                      begin
                        // from bitmap coordinate space to control coordinate space
                        BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                        BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                      end;
                    end;
                end;
              end;
            end
            else
            begin
              if Assigned(FSelection)
              then tmrMarchingAnts.Enabled := True;

              MessageDlg('The pattern has not selected.', mtError, [mbOK], 0);
              Exit;
            end;
          end;
        end;

      btBlurSharpenBrush:
        begin
          if Assigned(frmMain.GMBrush) and
             (frmMain.GMBrush.BrushID = bidBlurSharpen) and
             Assigned(frmPaintingBrush.BrushStroke) then
          begin
            BlurSharpenBrush := TgmBlurSharpenBrush(frmMain.GMBrush);

            with BlurSharpenBrush do
            begin
              SetBlendMode(frmMain.BrushBlendMode);

              Pressure := frmMain.BlurSharpenPressure;
              
              SetPaintingStroke(frmPaintingBrush.BrushStroke);

              { Brush Dynamics Settings }
              SetDynamicSize(frmPaintingBrush.BrushStroke,
                             frmBrushDynamics.SizeDynamicsState,
                             frmBrushDynamics.SizeSteps);

              SetDynamicPressure(frmMain.BlurSharpenPressure,
                                 frmBrushDynamics.OpacityDynamicsState,
                                 frmBrushDynamics.OpacitySteps);
            end;

            if Assigned(FSelection) then
            begin
              frmMain.GMBrush.UpdateSourceBitmap(FSelection.CutOriginal);

              frmMain.GMBrush.Paint(FSelection.CutOriginal, FMarqueeX, FMarqueeY,
                                    FChannelManager.ChannelSelectedSet);

              BrushArea := frmMain.GMBrush.GetBrushArea(FMarqueeX, FMarqueeY);
              ShowSelectionAtBrushStroke(BrushArea);
            end
            else
            begin
              case FChannelManager.CurrentChannelType of
                wctAlpha:
                  begin
                    frmMain.GMBrush.UpdateSourceBitmap(
                      FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);

                    frmMain.GMBrush.Paint(
                      FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    // get refresh area
                    BrushArea             := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);
                    BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                    BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                    FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed(BrushArea);
                  end;

                wctQuickMask:
                  begin
                    frmMain.GMBrush.UpdateSourceBitmap(
                      FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);

                    frmMain.GMBrush.Paint(
                      FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    // get refresh area
                    BrushArea             := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);
                    BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                    BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                    FChannelManager.QuickMaskPanel.AlphaLayer.Changed(BrushArea);
                  end;

                wctLayerMask:
                  begin
                    frmMain.GMBrush.UpdateSourceBitmap(
                      FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);

                    frmMain.GMBrush.Paint(
                      FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    // paint on mask channel preview layer, too
                    if Assigned(FChannelManager.LayerMaskPanel) then
                    begin
                      frmMain.GMBrush.Paint(
                        FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap,
                        FXActual, FYActual, FChannelManager.ChannelSelectedSet);
                    end;

                    // get brush area
                    BrushArea := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);

                    if not FLayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
                    begin
                      ApplyMask(BrushArea);
                    end
                    else
                    begin
                      // on special layers, we need save the new mask into its alpha channels
                      FLayerPanelList.SelectedLayerPanel.UpdateLayerAlphaWithMask(BrushArea);

                      // convert from bitmap coordinate space to image coordinates space
                      BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                      BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                    end;
                  end;

                wctRGB, wctRed, wctGreen, wctBlue:
                  begin
                    // must be on layer

                    // get refresh area
                    BrushArea := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);

                    TempBmp := TBitmap32.Create;
                    try
                      TempBmp.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

                      if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                      begin
                        ReplaceAlphaChannelWithMask(TempBmp,
                          FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                      end;

                      frmMain.GMBrush.UpdateSourceBitmap(TempBmp);
                    finally
                      TempBmp.Free;
                    end;

                    if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                    begin
                      ReplaceAlphaChannelWithMask(
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                        FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                        BrushArea);
                    end;

                    frmMain.GMBrush.Paint(
                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    if FLayerPanelList.SelectedLayerPanel.IsHasMask then
                    begin
                      GetAlphaChannelBitmap(
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                        FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                        BrushArea);
                        
                      ApplyMask(BrushArea);
                    end
                    else
                    begin
                      // from bitmap coordinate space to control coordinate space
                      BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                      BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                    end;
                  end;
              end;
            end;

            tmrSpecialBrush.Interval := frmMain.BlurSharpenTimerInterval;

            if tmrSpecialBrush.Enabled <> True then
            begin
              tmrSpecialBrush.Enabled := True;
            end;
          end;
        end;

      btSmudge:
        begin
          tmrSpecialBrush.Enabled := False;

          if Assigned(frmMain.GMBrush) and
             (frmMain.GMBrush.BrushID = bidSmudge) and
             Assigned(frmPaintingBrush.BrushStroke) then
          begin
            with frmMain.GMBrush do
            begin
              SetBlendMode(frmMain.BrushBlendMode);
              SetPaintingStroke(frmPaintingBrush.BrushStroke);
              TgmSmudge(frmMain.GMBrush).SetPressure(frmMain.SmudgePressure);

              { Brush Dynamics Settings }
              SetDynamicSize(frmPaintingBrush.BrushStroke,
                             frmBrushDynamics.SizeDynamicsState,
                             frmBrushDynamics.SizeSteps);

              SetDynamicOpacity(frmMain.SmudgePressure,
                                frmBrushDynamics.OpacityDynamicsState,
                                frmBrushDynamics.OpacitySteps);
            end;

            if Assigned(FSelection) then
            begin
              { The CutRegionToForegroundBySize procedure using the half width
                and half height value which was from the TgmBrush class. It
                was already assigned above. }
                
              TgmSmudge(frmMain.GMBrush).CutRegionToForegroundBySize(
                FSelection.CutOriginal, FMarqueeX, FMarqueeY);

              frmMain.GMBrush.Paint(FSelection.CutOriginal,
                FMarqueeX, FMarqueeY, FChannelManager.ChannelSelectedSet);

              BrushArea := frmMain.GMBrush.GetBrushArea(FMarqueeX, FMarqueeY);
              ShowSelectionAtBrushStroke(BrushArea);
            end
            else
            begin
              case FChannelManager.CurrentChannelType of
                wctAlpha:
                  begin
                    TgmSmudge(frmMain.GMBrush).CutRegionToForegroundBySize(
                      FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                      FXActual, FYActual);

                    frmMain.GMBrush.Paint(
                      FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    // get refresh area
                    BrushArea             := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);
                    BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                    BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                    FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed(BrushArea);
                  end;

                wctQuickMask:
                  begin
                    TgmSmudge(frmMain.GMBrush).CutRegionToForegroundBySize(
                      FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                      FXActual, FYActual);

                    frmMain.GMBrush.Paint(
                      FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    // get refresh area
                    BrushArea             := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);
                    BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                    BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                    FChannelManager.QuickMaskPanel.AlphaLayer.Changed(BrushArea);
                  end;

                wctLayerMask:
                  begin
                    TgmSmudge(frmMain.GMBrush).CutRegionToForegroundBySize(
                      FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                      FXActual, FYActual);

                    frmMain.GMBrush.Paint(
                      FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    // paint on mask channel preview layer, too
                    if Assigned(FChannelManager.LayerMaskPanel) then
                    begin
                      frmMain.GMBrush.Paint(
                        FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap,
                        FXActual, FYActual, FChannelManager.ChannelSelectedSet);
                    end;

                    // get brush area
                    BrushArea := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);

                    if not FLayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
                    begin
                      ApplyMask(BrushArea);
                    end
                    else
                    begin
                      // on special layers, we need save the new mask into its alpha channels
                      FLayerPanelList.SelectedLayerPanel.UpdateLayerAlphaWithMask(BrushArea);

                      // convert from bitmap coordinate space to image coordinates space
                      BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                      BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                    end;
                  end;

                wctRGB, wctRed, wctGreen, wctBlue:
                  begin
                    // must be on layer

                    // get refresh area
                    BrushArea := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);

                    TempBmp := TBitmap32.Create;
                    try
                      TempBmp.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

                      if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                      begin
                        ReplaceAlphaChannelWithMask(TempBmp,
                          FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                      end;

                      TgmSmudge(frmMain.GMBrush).CutRegionToForegroundBySize(
                        TempBmp, FXActual, FYActual);
                    finally
                      TempBmp.Free;
                    end;

                    if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                    begin
                      ReplaceAlphaChannelWithMask(
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                        FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                        BrushArea);
                    end;

                    frmMain.GMBrush.Paint(
                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    if FLayerPanelList.SelectedLayerPanel.IsHasMask then
                    begin
                      GetAlphaChannelBitmap(
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                        FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                        BrushArea);

                      ApplyMask(BrushArea);
                    end
                    else
                    begin
                      // from bitmap coordinate space to control coordinate space
                      BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                      BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                    end;
                  end;
              end;
            end;
          end;
        end;

      btDodgeBurnBrush:
        begin
          tmrSpecialBrush.Enabled := False;

          if Assigned(frmMain.GMBrush) and
             (frmMain.GMBrush.BrushID = bidDodgeBurn) and
             Assigned(frmPaintingBrush.BrushStroke) then
          begin
            frmMain.GMBrush.SetPaintingStroke(frmPaintingBrush.BrushStroke);
            TgmDodgeBurnBrush(frmMain.GMBrush).SetDodgeBurnMode(frmMain.DodgeBurnMode);
            TgmDodgeBurnBrush(frmMain.GMBrush).SetDodgeBurnExposure(frmMain.DodgeBurnExposure);
            TgmDodgeBurnBrush(frmMain.GMBrush).MakeLUT;

            { Brush Dynamics Settings }
            frmMain.GMBrush.SetDynamicSize(frmPaintingBrush.BrushStroke,
                                           frmBrushDynamics.SizeDynamicsState,
                                           frmBrushDynamics.SizeSteps);

            frmMain.GMBrush.SetDynamicOpacity(frmMain.DodgeBurnExposure,
                                              frmBrushDynamics.OpacityDynamicsState,
                                              frmBrushDynamics.OpacitySteps);

            if Assigned(FSelection) then
            begin
              frmMain.GMBrush.UpdateSourceBitmap(FSelection.CutOriginal);

              frmMain.GMBrush.Paint(FSelection.CutOriginal, FMarqueeX, FMarqueeY,
                                    FChannelManager.ChannelSelectedSet);

              BrushArea := frmMain.GMBrush.GetBrushArea(FMarqueeX, FMarqueeY);
              ShowSelectionAtBrushStroke(BrushArea);
            end
            else
            begin
              case FChannelManager.CurrentChannelType of
                wctAlpha:
                  begin
                    frmMain.GMBrush.UpdateSourceBitmap(
                      FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);

                    frmMain.GMBrush.Paint(
                      FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    // get refresh area
                    BrushArea             := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);
                    BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                    BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                    FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed(BrushArea);
                  end;

                wctQuickMask:
                  begin
                    frmMain.GMBrush.UpdateSourceBitmap(
                      FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);

                    frmMain.GMBrush.Paint(
                      FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    // get refresh area
                    BrushArea             := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);
                    BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                    BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                    FChannelManager.QuickMaskPanel.AlphaLayer.Changed(BrushArea);
                  end;

                wctLayerMask:
                  begin
                    frmMain.GMBrush.UpdateSourceBitmap(
                      FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);

                    frmMain.GMBrush.Paint(
                      FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    // paint on mask channel preview layer, too
                    if Assigned(FChannelManager.LayerMaskPanel) then
                    begin
                      frmMain.GMBrush.Paint(
                        FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap,
                        FXActual, FYActual, FChannelManager.ChannelSelectedSet);
                    end;

                    // get brush area
                    BrushArea := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);

                    if not FLayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
                    begin
                      ApplyMask(BrushArea);
                    end
                    else
                    begin
                      // on special layers, we need save the new mask into its alpha channels
                      FLayerPanelList.SelectedLayerPanel.UpdateLayerAlphaWithMask(BrushArea);

                      // convert from bitmap coordinate space to image coordinates space
                      BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                      BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                    end;
                  end;

                wctRGB, wctRed, wctGreen, wctBlue:
                  begin
                    // must be on layer

                    // get refresh area
                    BrushArea := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);

                    TempBmp := TBitmap32.Create;
                    try
                      TempBmp.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

                      if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                      begin
                        ReplaceAlphaChannelWithMask(TempBmp,
                          FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                      end;

                      frmMain.GMBrush.UpdateSourceBitmap(TempBmp);
                    finally
                      TempBmp.Free;
                    end;

                    if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                    begin
                      ReplaceAlphaChannelWithMask(
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                        FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                        BrushArea);
                    end;

                    frmMain.GMBrush.Paint(
                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    if FLayerPanelList.SelectedLayerPanel.IsHasMask then
                    begin
                      GetAlphaChannelBitmap(
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                        FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                        BrushArea);

                      ApplyMask(BrushArea);
                    end
                    else
                    begin
                      // from bitmap coordinate space to control coordinate space
                      BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                      BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                    end;
                  end;
              end;
            end;
          end;
        end;

      btLightBrush:
        begin
          tmrSpecialBrush.Enabled := False;

          if Assigned(frmMain.GMBrush) and
             (frmMain.GMBrush.BrushID = bidLightBrush) and
             Assigned(frmPaintingBrush.BrushStroke) then
          begin
            with frmMain.GMBrush do
            begin
              SetPaintingStroke(frmPaintingBrush.BrushStroke);
              SetBrushIntensity(frmMain.BrushIntensity);

              { Brush Dynamics Settings }
              SetDynamicSize(frmPaintingBrush.BrushStroke,
                             frmBrushDynamics.SizeDynamicsState,
                             frmBrushDynamics.SizeSteps);

              SetDynamicOpacity( MulDiv(255, frmMain.BrushIntensity, 100),
                                 frmBrushDynamics.OpacityDynamicsState,
                                 frmBrushDynamics.OpacitySteps );
            end;

            if Assigned(FSelection) then
            begin
              frmMain.GMBrush.UpdateSourceBitmap(FSelection.CutOriginal);

              frmMain.GMBrush.Paint(FSelection.CutOriginal, FMarqueeX, FMarqueeY,
                                    FChannelManager.ChannelSelectedSet);

              BrushArea := frmMain.GMBrush.GetBrushArea(FMarqueeX, FMarqueeY);
              ShowSelectionAtBrushStroke(BrushArea);
            end
            else
            begin
              case FChannelManager.CurrentChannelType of
                wctAlpha:
                  begin
                    frmMain.GMBrush.UpdateSourceBitmap(
                      FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);

                    frmMain.GMBrush.Paint(
                      FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    // get refresh area
                    BrushArea             := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);
                    BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                    BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                    FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed(BrushArea);
                  end;

                wctQuickMask:
                  begin
                    frmMain.GMBrush.UpdateSourceBitmap(
                      FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);

                    frmMain.GMBrush.Paint(
                      FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    // get refresh area
                    BrushArea             := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);
                    BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                    BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                    FChannelManager.QuickMaskPanel.AlphaLayer.Changed(BrushArea);
                  end;

                wctLayerMask:
                  begin
                    frmMain.GMBrush.UpdateSourceBitmap(
                      FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);

                    frmMain.GMBrush.Paint(
                      FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    // paint on mask channel preview layer, too
                    if Assigned(FChannelManager.LayerMaskPanel) then
                    begin
                      frmMain.GMBrush.Paint(
                        FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap,
                        FXActual, FYActual, FChannelManager.ChannelSelectedSet);
                    end;

                    // get brush area
                    BrushArea := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);

                    if not FLayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
                    begin
                      ApplyMask(BrushArea);
                    end
                    else
                    begin
                      // on special layers, we need save the new mask into its alpha channels
                      FLayerPanelList.SelectedLayerPanel.UpdateLayerAlphaWithMask(BrushArea);

                      // convert from bitmap coordinate space to image coordinates space
                      BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                      BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                    end;
                  end;

                wctRGB, wctRed, wctGreen, wctBlue:
                  begin
                    // must be on layer

                    // get refresh area
                    BrushArea := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);

                    TempBmp := TBitmap32.Create;
                    try
                      TempBmp.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

                      if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                      begin
                        ReplaceAlphaChannelWithMask(TempBmp,
                          FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                      end;

                      frmMain.GMBrush.UpdateSourceBitmap(TempBmp);
                    finally
                      TempBmp.Free;
                    end;

                    if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                    begin
                      ReplaceAlphaChannelWithMask(
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                        FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                        BrushArea);
                    end;

                    frmMain.GMBrush.Paint(
                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    if FLayerPanelList.SelectedLayerPanel.IsHasMask then
                    begin
                      GetAlphaChannelBitmap(
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                        FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                        BrushArea);

                      ApplyMask(BrushArea);
                    end
                    else
                    begin
                      // from bitmap coordinate space to control coordinate space
                      BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                      BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                    end;
                  end;
              end;
            end;
          end;
        end;

      btAirBrush:
        begin
          if frmMain.AirBrush.IsAir and
             Assigned(frmPaintingBrush.BrushStroke) then
          begin
            with frmMain.AirBrush do
            begin
              // set brush color
              if FChannelManager.CurrentChannelType in
                   [wctAlpha, wctQuickMask, wctLayerMask] then
              begin
                Color := Color32(frmMain.ForeGrayColor);
              end
              else
              begin
                Color := Color32(frmMain.GlobalForeColor);
              end;

              AirIntensity := frmMain.AirPressure;
              BlendMode    := frmMain.BrushBlendMode;
              SetPaintingStroke(frmPaintingBrush.BrushStroke);

              { Brush Dynamics Settings }
              SetDynamicSize(frmPaintingBrush.BrushStroke,
                             frmBrushDynamics.SizeDynamicsState,
                             frmBrushDynamics.SizeSteps);

              SetDynamicPressure(frmMain.AirPressure,
                                 frmBrushDynamics.OpacityDynamicsState,
                                 frmBrushDynamics.OpacitySteps);

              SetDynamicColor( Color32(frmMain.GlobalForeColor),
                               Color32(frmMain.GlobalBackColor),
                               frmBrushDynamics.ColorDynamicsState,
                               frmBrushDynamics.ColorSteps );
            end;

            if Assigned(FSelection) then
            begin
              frmMain.AirBrush.UpdateSourceBitmap(FSelection.CutOriginal);

              frmMain.AirBrush.Draw(FSelection.CutOriginal, FMarqueeX, FMarqueeY,
                                    FChannelManager.ChannelSelectedSet);

              ShowProcessedSelection;
            end
            else
            begin
              case FChannelManager.CurrentChannelType of
                wctAlpha:
                  begin
                    if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
                    begin
                      frmMain.AirBrush.UpdateSourceBitmap(
                        FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);

                      frmMain.AirBrush.Draw(
                        FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                        FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                      FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
                    end
                    else
                    begin
                      MessageDlg('Could not process more than one alpha channels at a time.', mtError, [mbOK], 0);
                      Exit;
                    end;
                  end;

                wctQuickMask:
                  begin
                    frmMain.AirBrush.UpdateSourceBitmap(
                      FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);

                    frmMain.AirBrush.Draw(
                      FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    FChannelManager.QuickMaskPanel.AlphaLayer.Changed;
                  end;

                wctLayerMask:
                  begin
                    frmMain.AirBrush.UpdateSourceBitmap(
                      FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);

                    frmMain.AirBrush.Draw(
                      FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    // paint on mask channel preview layer, too
                    if Assigned(FChannelManager.LayerMaskPanel) then
                    begin
                      frmMain.AirBrush.Draw(
                        FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap,
                        FXActual, FYActual, FChannelManager.ChannelSelectedSet);
                    end;

                    // get brush area
                    BrushArea := frmMain.AirBrush.GetBrushArea(FXActual, FYActual);

                    if not FLayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
                    begin
                      ApplyMask(BrushArea);
                    end
                    else
                    begin
                      // on special layers, we need save the new mask into its alpha channels
                      FLayerPanelList.SelectedLayerPanel.UpdateLayerAlphaWithMask(BrushArea);

                      // convert from bitmap coordinate space to image coordinates space
                      BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                      BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                    end;
                  end;

                wctRGB, wctRed, wctGreen, wctBlue:
                  begin
                    // must be on layer

                    // get refresh area
                    BrushArea := frmMain.AirBrush.GetBrushArea(FXActual, FYActual);

                    TempBmp := TBitmap32.Create;
                    try
                      TempBmp.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

                      if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                      begin
                        ReplaceAlphaChannelWithMask(TempBmp,
                          FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                      end;

                      frmMain.AirBrush.UpdateSourceBitmap(TempBmp);
                    finally
                      TempBmp.Free;
                    end;

                    if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                    begin
                      ReplaceAlphaChannelWithMask(
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                        FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                        BrushArea);
                    end;

                    frmMain.AirBrush.Draw(
                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    if FLayerPanelList.SelectedLayerPanel.IsHasMask then
                    begin
                      GetAlphaChannelBitmap(
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                        FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                        BrushArea);

                      ApplyMask(BrushArea);
                    end
                    else
                    begin
                      // from bitmap coordinate space to control coordinate space
                      BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                      BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                    end;
                  end;
              end;
            end;

            tmrSpecialBrush.Interval := frmMain.AirBrush.Interval;

            if not tmrSpecialBrush.Enabled then
            begin
              tmrSpecialBrush.Enabled := True;
            end;
          end;
        end;

      btJetGunBrush:
        begin
          if Assigned(frmMain.JetGun) then
          begin
            with frmMain.JetGun do
            begin
              Radius      := frmMain.updwnBrushRadius.Position;
              IsRandom    := frmMain.IsRandomColor;
              JetGunIndex := 0;
              
              SetBlendMode(frmMain.BrushBlendMode);
              SetPressure(frmMain.JetGunPressure);
            end;

            if Assigned(FSelection) then
            begin
              if FChannelManager.CurrentChannelType in [
                   wctAlpha, wctQuickMask, wctLayerMask] then
              begin
                frmMain.JetGun.Color := Color32(frmMain.ForeGrayColor);
              end
              else
              begin
                frmMain.JetGun.Color := Color32(frmMain.GlobalForeColor);
              end;

              frmMain.JetGun.UpdateSourceBitmap(FSelection.CutOriginal);

              frmMain.JetGun.Jet(FSelection.CutOriginal, FMarqueeX, FMarqueeY,
                                 FChannelManager.ChannelSelectedSet);

              // get brush area
              BrushArea := frmMain.JetGun.GetJetArea(FMarqueeX, FMarqueeY);
              ShowSelectionAtBrushStroke(BrushArea);
            end
            else
            begin
              case FChannelManager.CurrentChannelType of
                wctAlpha:
                  begin
                    frmMain.JetGun.Color := Color32(frmMain.ForeGrayColor);

                    frmMain.JetGun.UpdateSourceBitmap(
                      FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);

                    frmMain.JetGun.Jet(
                      FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    // get refresh area
                    BrushArea             := frmMain.JetGun.GetJetArea(FXActual, FYActual);
                    BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                    BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                    FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed(BrushArea);
                  end;

                wctQuickMask:
                  begin
                    frmMain.JetGun.Color := Color32(frmMain.ForeGrayColor);

                    frmMain.JetGun.UpdateSourceBitmap(
                      FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);

                    frmMain.JetGun.Jet(
                      FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    // get refresh area
                    BrushArea             := frmMain.JetGun.GetJetArea(FXActual, FYActual);
                    BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                    BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                    FChannelManager.QuickMaskPanel.AlphaLayer.Changed(BrushArea);
                  end;

                wctLayerMask:
                  begin
                    frmMain.JetGun.Color := Color32(frmMain.ForeGrayColor);
                    
                    frmMain.JetGun.UpdateSourceBitmap(
                      FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);

                    BrushArea := frmMain.JetGun.GetJetArea(FXActual, FYActual);

                    frmMain.JetGun.Jet(
                      FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    // update the mask channel preview layer
                    if Assigned(FChannelManager.LayerMaskPanel) then
                    begin
                      CopyBitmap32(
                        FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap,
                        FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                        BrushArea);
                    end;

                    if not FLayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
                    begin
                      ApplyMask(BrushArea);
                    end
                    else
                    begin
                      // save Mask into layer's alpha channel
                      FLayerPanelList.SelectedLayerPanel.UpdateLayerAlphaWithMask(BrushArea);
                        
                      // convert from bitmap coordinate space to control coordinate space
                      BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                      BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                    end;
                  end;

                wctRGB, wctRed, wctGreen, wctBlue:
                  begin
                    // must be on layer

                    frmMain.JetGun.Color := Color32(frmMain.GlobalForeColor);
                    
                    // get refresh area
                    BrushArea  := frmMain.JetGun.GetJetArea(FXActual, FYActual);

                    TempBmp := TBitmap32.Create;
                    try
                      TempBmp.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

                      if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                      begin
                        ReplaceAlphaChannelWithMask(TempBmp,
                          FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                      end;

                      frmMain.JetGun.UpdateSourceBitmap(TempBmp);
                    finally
                      TempBmp.Free;
                    end;

                    if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                    begin
                      ReplaceAlphaChannelWithMask(
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                        FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                        BrushArea);
                    end;

                    frmMain.JetGun.Jet(
                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    if FLayerPanelList.SelectedLayerPanel.IsHasMask then
                    begin
                      GetAlphaChannelBitmap(
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                        FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                        BrushArea);

                      ApplyMask(BrushArea);
                    end
                    else
                    begin
                      // from bitmap coordinate space to control coordinate space
                      BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                      BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                    end;
                  end;
              end;
            end;

            { Dynamics Part }
            with frmMain.JetGun do
            begin
              SetDynamicRadius(frmMain.updwnBrushRadius.Position,
                               frmBrushDynamics.SizeDynamicsState,
                               frmBrushDynamics.SizeSteps);

              SetDynamicPressure( MulDiv(255, frmMain.JetGunPressure, 100),
                                  frmBrushDynamics.OpacityDynamicsState,
                                  frmBrushDynamics.OpacitySteps );

              SetDynamicColor( Color32(frmMain.GlobalForeColor),
                               Color32(frmMain.GlobalBackColor),
                               frmBrushDynamics.ColorDynamicsState,
                               frmBrushDynamics.ColorSteps );
            end;

            if not tmrSpecialBrush.Enabled then
            begin
              tmrSpecialBrush.Enabled := True;
            end;
          end;
        end;
    end;
    
    FImageProcessed := True; // mark the image has already been modified
    FDrawing        := True;
  end;
end;

procedure TfrmChild.BrushToolsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
var
  AColor        : TColor;
  CloneStamp    : TgmCloneStamp;
  Interval      : Integer;
  LastStrokeArea: TRect;
  BrushArea     : TRect;
begin
  CalcLayerCoord(X, Y);  // get layer space coordinates
  CalcSelectionCoord;    // get selection space coordinates

{ Move mouse when mouse left button down }

  if FDrawing then
  begin
    case frmMain.BrushTool of
      btPaintBrush,
      btHistoryBrush,
      btCloneStamp,
      btPatternStamp,
      btBlurSharpenBrush,
      btSmudge,
      btDodgeBurnBrush,
      btLightBrush:
        begin
          if frmMain.BrushTool in [btBlurSharpenBrush, btSmudge] then
          begin
            Interval := 0;
          end
          else
          begin
            Interval := frmMain.BrushInterval;
          end;

          if Assigned(FSelection) then
          begin
            BrushLine(FPrevStrokePoint.X, FPrevStrokePoint.Y, FMarqueeX, FMarqueeY,
                      Interval, FSelection.CutOriginal, FChannelManager.ChannelSelectedSet);

            // get brush area
            LastStrokeArea := frmMain.GMBrush.GetBrushArea(FPrevStrokePoint.X, FPrevStrokePoint.Y);
            BrushArea      := frmMain.GMBrush.GetBrushArea(FMarqueeX, FMarqueeY);
            BrushArea      := AddRects(LastStrokeArea, BrushArea);
    
            ShowSelectionAtBrushStroke(BrushArea);
            FPrevStrokePoint := Point(FMarqueeX, FMarqueeY);
          end
          else
          begin
            case FChannelManager.CurrentChannelType of
              wctAlpha:
                begin
                  BrushLine(FPrevStrokePoint.X, FPrevStrokePoint.Y, FXActual, FYActual,
                            Interval, FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                            FChannelManager.ChannelSelectedSet);

                  // get refresh area
                  LastStrokeArea        := frmMain.GMBrush.GetBrushArea(FPrevStrokePoint.X, FPrevStrokePoint.Y);
                  BrushArea             := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);
                  BrushArea             := AddRects(LastStrokeArea, BrushArea);
                  BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                  BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                  FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed(BrushArea);
                end;

              wctQuickMask:
                begin
                  BrushLine(FPrevStrokePoint.X, FPrevStrokePoint.Y, FXActual, FYActual,
                            Interval, FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                            FChannelManager.ChannelSelectedSet);

                  // get refresh area
                  LastStrokeArea        := frmMain.GMBrush.GetBrushArea(FPrevStrokePoint.X, FPrevStrokePoint.Y);
                  BrushArea             := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);
                  BrushArea             := AddRects(LastStrokeArea, BrushArea);
                  BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                  BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                  FChannelManager.QuickMaskPanel.AlphaLayer.Changed(BrushArea);
                end;

              wctLayerMask:
                begin
                  { BrushLineOnMask() will paint brush stroke both on
                    FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap and
                    FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.

                    And the function will also save the new Mask into the
                    alpha channels of special layers. }

                  BrushLineOnMask(FPrevStrokePoint.X, FPrevStrokePoint.Y,
                                  FXActual, FYActual, Interval,
                                  FChannelManager.ChannelSelectedSet);

                  // get brush area
                  LastStrokeArea := frmMain.GMBrush.GetBrushArea(FPrevStrokePoint.X, FPrevStrokePoint.Y);
                  BrushArea      := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);
                  BrushArea      := AddRects(LastStrokeArea, BrushArea);

                  if not FLayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
                  begin
                    ApplyMask(BrushArea);
                  end
                  else
                  begin
                    // convert from bitmap coordinate space to control coordinate space
                    BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                    BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);
                    FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                  end;
                end;

              wctRGB, wctRed, wctGreen, wctBlue:
                begin
                  // must be on layer

                  // get refresh area
                  LastStrokeArea := frmMain.GMBrush.GetBrushArea(FPrevStrokePoint.X, FPrevStrokePoint.Y);
                  BrushArea      := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);
                  BrushArea      := AddRects(LastStrokeArea, BrushArea);

                  // restore the alpha channel to the state that before applied mask
                  if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                  begin
                    ReplaceAlphaChannelWithMask(
                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                      FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                      BrushArea);
                  end;

                  BrushLine(FPrevStrokePoint.X, FPrevStrokePoint.Y,
                            FXActual, FYActual, Interval,
                            FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                            FChannelManager.ChannelSelectedSet);

                  if FLayerPanelList.SelectedLayerPanel.IsHasMask then
                  begin
                    GetAlphaChannelBitmap(
                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                      FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                      BrushArea);
                      
                    ApplyMask(BrushArea);
                  end
                  else
                  begin
                    // from bitmap coordinate space to control coordinate space
                    BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                    BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                    FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                  end;
                end;
            end;

            FPrevStrokePoint := Point(FXActual, FYActual);
          end;

          if frmMain.BrushTool = btCloneStamp then
          begin
            CloneStamp := TgmCloneStamp(frmMain.GMBrush);

            { Because of aim flag is drawn on the canvas with pen mode
              set to pmNotXor, draw it again at the last position will clear
              the old flag on the canvas. }
            CloneStamp.DrawStampAimFlag(imgDrawingArea.Canvas, FAimPoint.X, FAimPoint.Y);

            FAimPoint.X := Round( FLayerPanelList.SelectedLayerPanel.AssociatedLayer.GetAdjustedLocation.Left +
                                  (FXActual + CloneStamp.OffsetX) * imgDrawingArea.Scale );

            FAimPoint.Y := Round( FLayerPanelList.SelectedLayerPanel.AssociatedLayer.GetAdjustedLocation.Top +
                                  (FYActual + CloneStamp.OffsetY) * imgDrawingArea.Scale );

            // draw aim flag at new postion with pen mode set to pmNotXor
            CloneStamp.DrawStampAimFlag(imgDrawingArea.Canvas, FAimPoint.X, FAimPoint.Y);
          end;
        end;

      btAirBrush:
        begin
          if Assigned(FSelection) then
          begin
            AirBrushLine(FPrevStrokePoint.X, FPrevStrokePoint.Y, FMarqueeX, FMarqueeY, 0,
                         FSelection.CutOriginal, FChannelManager.ChannelSelectedSet);

            // get brush area
            LastStrokeArea := frmMain.AirBrush.GetBrushArea(FPrevStrokePoint.X, FPrevStrokePoint.Y);
            BrushArea      := frmMain.AirBrush.GetBrushArea(FMarqueeX, FMarqueeY);
            BrushArea      := AddRects(LastStrokeArea, BrushArea);
    
            ShowSelectionAtBrushStroke(BrushArea);
            
            FPrevStrokePoint := Point(FMarqueeX, FMarqueeY);
          end
          else
          begin
            case FChannelManager.CurrentChannelType of
              wctAlpha:
                begin
                  AirBrushLine(FPrevStrokePoint.X, FPrevStrokePoint.Y,
                               FXActual, FYActual, 0,
                               FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                               FChannelManager.ChannelSelectedSet);

                  // get refresh area
                  LastStrokeArea        := frmMain.AirBrush.GetBrushArea(FPrevStrokePoint.X, FPrevStrokePoint.Y);
                  BrushArea             := frmMain.AirBrush.GetBrushArea(FXActual, FYActual);
                  BrushArea             := AddRects(LastStrokeArea, BrushArea);
                  BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                  BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                  FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed(BrushArea);
                end;

              wctQuickMask:
                begin
                  AirBrushLine(FPrevStrokePoint.X, FPrevStrokePoint.Y,
                               FXActual, FYActual, 0,
                               FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                               FChannelManager.ChannelSelectedSet);

                  // get refresh area
                  LastStrokeArea        := frmMain.AirBrush.GetBrushArea(FPrevStrokePoint.X, FPrevStrokePoint.Y);
                  BrushArea             := frmMain.AirBrush.GetBrushArea(FXActual, FYActual);
                  BrushArea             := AddRects(LastStrokeArea, BrushArea);
                  BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                  BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                  FChannelManager.QuickMaskPanel.AlphaLayer.Changed(BrushArea);
                end;

              wctLayerMask:
                begin
                  { AirBrushLineOnMask() will paint brush stroke both on
                    FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap and
                    FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.

                    And the function will also save the new Mask into the
                    alpha channels of special layers. }
                  AirBrushLineOnMask(FPrevStrokePoint.X, FPrevStrokePoint.Y,
                                     FXActual, FYActual, 0,
                                     FChannelManager.ChannelSelectedSet);

                  // get brush area
                  LastStrokeArea := frmMain.AirBrush.GetBrushArea(FPrevStrokePoint.X, FPrevStrokePoint.Y);
                  BrushArea      := frmMain.AirBrush.GetBrushArea(FXActual, FYActual);
                  BrushArea      := AddRects(LastStrokeArea, BrushArea);

                  if not FLayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
                  begin
                    ApplyMask(BrushArea);
                  end
                  else
                  begin
                    // convert from bitmap coordinate space to control coordinate space
                    BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                    BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);
                    FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                  end;
                end;

              wctRGB, wctRed, wctGreen, wctBlue:
                begin
                  // must be on layer

                  // get refresh area
                  LastStrokeArea := frmMain.AirBrush.GetBrushArea(FPrevStrokePoint.X, FPrevStrokePoint.Y);
                  BrushArea      := frmMain.AirBrush.GetBrushArea(FXActual, FYActual);
                  BrushArea      := AddRects(LastStrokeArea, BrushArea);

                  // restore the alpha channel to the state that before applied mask
                  if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                  begin
                    ReplaceAlphaChannelWithMask(
                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                      FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                      BrushArea);
                  end;

                  AirBrushLine(FPrevStrokePoint.X, FPrevStrokePoint.Y,
                               FXActual, FYActual, 0,
                               FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                               FChannelManager.ChannelSelectedSet);

                  if FLayerPanelList.SelectedLayerPanel.IsHasMask then
                  begin
                    GetAlphaChannelBitmap(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                                          FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                                          BrushArea);
                    ApplyMask(BrushArea);
                  end
                  else
                  begin
                    // from bitmap coordinate space to control coordinate space
                    BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                    BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                    FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                  end;
                end;
            end;

            FPrevStrokePoint := Point(FXActual, FYActual);
          end;
        end;
    end;
  end
  else // if the FDrawing = False
  begin
    if frmMain.BrushTool = btCloneStamp then
    begin
      if ssAlt in Shift then
      begin
        Screen.Cursor         := crCloneStamp;
        imgDrawingArea.Cursor := crCloneStamp;
      end
      else
      begin
        Screen.Cursor         := crDefault;
        imgDrawingArea.Cursor := crCross;
      end;
    end;

    if (FXActual >= 0) and
       (FYActual >= 0) and
       (FXActual <= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width) and
       (FYActual <= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height) then
    begin
      // showing the color info of the pixel that below the mouse pointer
      AColor := imgDrawingArea.Canvas.Pixels[X, Y];
      
      frmMain.ShowColorRGBInfoOnInfoViewer(AColor);
      frmMain.ShowColorCMYKInfoOnInfoViewer(AColor);
    end;
  end;
  
  imgDrawingArea.Canvas.Pen.Mode := pmCopy;
  frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
end; 

procedure TfrmChild.BrushToolsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  CmdName          : string;
  CmdAim           : TCommandAim;
  HistoryStatePanel: TgmHistoryStatePanel;
  CommandIconIndex : Integer;
begin
  if imgDrawingArea.RepaintMode <> rmFull
  then imgDrawingArea.RepaintMode := rmFull;

  if FDrawing then
  begin
    FDrawing := False;

    if tmrSpecialBrush.Enabled
    then tmrSpecialBrush.Enabled := False;

    if Assigned(FSelection) then
    begin
      ShowProcessedSelection;
      tmrMarchingAnts.Enabled := True;

      // for Undo/Redo
      frmMain.FAfterProc.Assign(FSelection.CutOriginal);
    end
    else
    begin
      case FChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
            frmMain.FAfterProc.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
          end;

        wctQuickMask:
          begin
            FChannelManager.QuickMaskPanel.AlphaLayer.Changed;
            frmMain.FAfterProc.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
          end;

        wctLayerMask:
          begin
            FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Changed;
            FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(0, 0, FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
            frmMain.FAfterProc.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            // must be on layer
            frmMain.FAfterProc.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

            if (FLayerPanelList.SelectedLayerPanel.IsMaskLinked) and
               (FLayerPanelList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent]) then
            begin
              ReplaceAlphaChannelWithMask(frmMain.FAfterProc,
                FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
            end;
          end;
      end;

      // refresh the whole display
      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
    end;

    // update thumbnails
    UpdateThumbnailsBySelectedChannel;

{ Create Undo/Redo for brushes. }

    CommandIconIndex := DEFAULT_COMMAND_ICON_INDEX;

    case frmMain.BrushTool of
      btAirBrush:
        begin
          CmdName          := frmMain.AirBrush.Name;
          CommandIconIndex := AIR_BRUSH_COMMAND_ICON_INDEX;
        end;

      btJetGunBrush:
        begin
          CmdName          := frmMain.JetGun.Name;
          CommandIconIndex := JET_GUN_COMMAND_ICON_INDEX;
        end;

      else
      begin
        CmdName := frmMain.GMBrush.Name;

        case frmMain.GMBrush.BrushID of
          bidPaintBrush:
            begin
              CommandIconIndex := PAINTBRUSH_COMMAND_ICON_INDEX;
            end;
            
          bidHistoryBrush:
            begin
              CommandIconIndex := HISTORY_BRUSH_COMMAND_ICON_INDEX;
            end;
            
          bidCloneStamp:
            begin
              CommandIconIndex := CLONE_STAMP_COMMAND_ICON_INDEX;
            end;
            
          bidPatternStamp:
            begin
              CommandIconIndex := PATTERN_STAMP_COMMAND_ICON_INDEX;
            end;
            
          bidSmudge:
            begin
              CommandIconIndex := SMUDGE_BRUSH_COMMAND_ICON_INDEX;
            end;

          bidBlurSharpen:
            begin
              case TgmBlurSharpenBrush(frmMain.GMBrush).ConvolveType of
                gmctBlur:
                  begin
                    CommandIconIndex := BLUR_BRUSH_COMMAND_ICON_INDEX;
                  end;

                gmctSharpen:
                  begin
                    CommandIconIndex := SHARPEN_BRUSH_COMMAND_ICON_INDEX;
                  end;
              end;
            end;

          bidDodgeBurn:
            begin
              case TgmDodgeBurnBrush(frmMain.GMBrush).DodgeBurnType of
                dbtDodge:
                  begin
                    CommandIconIndex := DODGE_BRUSH_COMMAND_ICON_INDEX;
                  end;
                  
                dbtBurn:
                  begin
                    CommandIconIndex := BURN_BRUSH_COMMAND_ICON_INDEX;
                  end;
              end;
            end;

          bidLightBrush:
            begin
              case TgmLightBrush(frmMain.GMBrush).LightMode of
                lbmHighHue:
                  begin
                    CommandIconIndex := HIGH_HUE_BRUSH_COMMAND_ICON_INDEX;
                  end;
                  
                lbmLowHue:
                  begin
                    CommandIconIndex := LOW_HUE_BRUSH_COMMAND_ICON_INDEX;
                  end;
                  
                lbmHighSaturation:
                  begin
                    CommandIconIndex := HIGH_SATURATION_BRUSH_COMMAND_ICON_INDEX;
                  end;
                  
                lbmLowSaturation:
                  begin
                    CommandIconIndex := LOW_SATURATION_BRUSH_COMMAND_ICON_INDEX;
                  end;
                  
                lbmHighLuminosity:
                  begin
                    CommandIconIndex := HIGH_LUMINOSITY_BRUSH_COMMAND_ICON_INDEX;
                  end;
                  
                lbmLowLuminosity:
                  begin
                    CommandIconIndex := LOW_LUMINOSITY_BRUSH_COMMAND_ICON_INDEX;
                  end;
                  
                lbmBrightness:
                  begin
                    CommandIconIndex := BRIGHT_BRUSH_COMMAND_ICON_INDEX;
                  end;
                  
                lbmDarkness:
                  begin
                    CommandIconIndex := DARK_BRUSH_COMMAND_ICON_INDEX;
                  end;
                  
                lbmHighContrast:
                  begin
                    CommandIconIndex := HIGH_CONTRAST_BRUSH_COMMAND_ICON_INDEX;
                  end;
                  
                lbmLowContrast:
                  begin
                    CommandIconIndex := LOW_CONTRAST_BRUSH_COMMAND_ICON_INDEX;
                  end;
              end;
            end;
        end;
      end;
    end;

    // create Undo/Redo command
    CmdAim := GetCommandAimByCurrentChannel;

    HistoryStatePanel := TgmImageManipulatingStatePanel.Create(
      frmHistory.scrlbxHistory,
      dmHistory.bmp32lstHistory.Bitmap[CommandIconIndex],
      CmdAim,
      CmdName,
      frmMain.FBeforeProc,
      frmMain.FAfterProc,
      FSelection,
      FChannelManager.SelectedAlphaChannelIndex);

    if Assigned(HistoryStatePanel) then
    begin
      FHistoryManager.AddHistoryState(HistoryStatePanel);
    end;
  end;
end;

procedure TfrmChild.MarqueeToolsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  LMergedBmp: TBitmap32;
  LBmpRect  : TRect;
begin
  CalcLayerCoord(X, Y);  // get layer space coordinates

{ Mouse left button down }

  if Button = mbLeft then
  begin
    // showing the coordinates of starting point
    frmMain.ShowOriginalCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
    frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
    
    // don't draw dynamic Marching-Ants lines when processing image
    if tmrMarchingAnts.Enabled = True then
    begin
      tmrMarchingAnts.Enabled := False;
    end;

    FImageProcessed := True; // mark that the image has been modified

    with imgDrawingArea.Canvas do
    begin
      Pen.Color   := RUBBER_BAND_PEN_COLOR;
      Pen.Style   := RUBBER_BAND_PEN_STYLE;
      Pen.Width   := RUBBER_BAND_PEN_WIDTH;
      Brush.Color := RUBBER_BAND_BRUSH_COLOR;
      Brush.Style := RUBBER_BAND_BRUSH_STYLE;
    end;

    case FMarqueeDrawingState of
      dsNotDrawing:
        begin
          if frmMain.MarqueeTool = mtMoveResize then
          begin
            if Assigned(FSelection) then
            begin
              FMarqueeDrawingHandle := dhNone;

              // check if the mouse is pointing on any of the selection handes
              case FChannelManager.CurrentChannelType of
                wctAlpha:
                  begin
                    if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
                    begin
                      FMarqueeDrawingHandle := FSelection.GetHandleAtPoint(FXActual, FYActual, SELECTION_HANDLE_RADIUS);
                    end;
                  end;

                wctQuickMask, wctLayerMask:
                  begin
                    FMarqueeDrawingHandle := FSelection.GetHandleAtPoint(FXActual, FYActual, SELECTION_HANDLE_RADIUS);
                  end;

                wctRGB, wctRed, wctGreen, wctBlue:
                  begin
                    if FLayerPanelList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent] then
                    begin
                      FMarqueeDrawingHandle := FSelection.GetHandleAtPoint(FXActual, FYActual, SELECTION_HANDLE_RADIUS);
                    end;
                  end;
              end;

              if FMarqueeDrawingHandle in [dhAxAy, dhBxBy, dhAxBy, dhBxAy,
                                           dhLeftHalfAyBy, dhRightHalfAyBy,
                                           dhTopHalfAxBx, dhBottomHalfAxBx] then
              begin
                Screen.Cursor         := SetCursorByHandle(FMarqueeDrawingHandle);
                imgDrawingArea.Cursor := Screen.Cursor;
                FMarqueeDrawingState  := dsStretchCorner;

                if FSelectionHandleLayer <> nil then
                begin
                  FSelectionHandleLayer.Bitmap.Clear($00000000);
                  FSelectionHandleLayer.Visible := False;
                end;
                
                imgDrawingArea.Update;
                DrawMarchingAnts;
              end
              else
              begin
                // check if the mouse pointer is within the selection
                if FSelection.ContainsPoint( Point(FXActual, FYActual) ) then
                begin
                  Screen.Cursor         := crDrag;
                  imgDrawingArea.Cursor := Screen.Cursor;
                  FMarqueeDrawingState  := dsTranslate;
                  FDrawingBasePoint     := Point(FXActual, FYActual);

                  if FSelectionHandleLayer <> nil then
                  begin
                    FSelectionHandleLayer.Bitmap.Clear($00000000);
                    FSelectionHandleLayer.Visible := False;
                  end;

                  imgDrawingArea.Update;
                  DrawMarchingAnts;
                end;
              end;
            end;
          end;
        end;

      dsNewFigure:
        begin
          if FSelection <> nil then
          begin
            RemoveMarchingAnts;
            imgDrawingArea.Update;
            DrawMarchingAnts;
          end;

          case frmMain.MarqueeTool of
            mtSingleRow,
            mtSingleColumn,
            mtRectangular,
            mtRoundRectangular,
            mtElliptical,
            mtPolygonal,
            mtRegularPolygon,
            mtLasso:
              begin
                if Assigned(FRegion) then
                begin
                  if FRegion.IsValidRegion then
                  begin
                    FreeAndNil(FRegion);
                  end;
                end;

                if not Assigned(FRegion) then
                begin
                  if frmMain.MarqueeTool = mtSingleRow then
                  begin
                    FRegion := TgmSingleRowRegion.Create(imgDrawingArea.Canvas);
                    
                    TgmSingleRowRegion(FRegion).RowWidth :=
                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width;
                  end
                  else if frmMain.MarqueeTool = mtSingleColumn then
                  begin
                    FRegion := TgmSingleColumnRegion.Create(imgDrawingArea.Canvas);
                    
                    TgmSingleColumnRegion(FRegion).ColumnHeight :=
                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height;
                  end
                  else if frmMain.MarqueeTool = mtRectangular then
                  begin
                    FRegion := TgmRectangularRegion.Create(imgDrawingArea.Canvas);
                  end
                  else if frmMain.MarqueeTool = mtRoundRectangular then
                  begin
                    FRegion := TgmRoundRectangularRegion.Create(imgDrawingArea.Canvas);
                    TgmRoundRectangularRegion(FRegion).CornerRadius := frmMain.RRMCornerRadius;
                  end
                  else if frmMain.MarqueeTool = mtElliptical then
                  begin
                    FRegion := TgmEllipticRegion.Create(imgDrawingArea.Canvas);
                  end
                  else if frmMain.MarqueeTool = mtPolygonal then
                  begin
                    FRegion := TgmPolygonalRegion.Create(imgDrawingArea.Canvas);
                  end
                  else if frmMain.MarqueeTool = mtRegularPolygon then
                  begin
                    FRegion := TgmRegularPolygonalRegion.Create(imgDrawingArea.Canvas);
                    TgmRegularPolygonalRegion(FRegion).EdgeCount := frmMain.RPMSides;
                  end
                  else if frmMain.MarqueeTool = mtLasso then
                  begin
                    FRegion := TgmLassoRegion.Create(imgDrawingArea.Canvas);
                  end;
                end;

                LBmpRect        := imgDrawingArea.GetBitmapRect;
                FRegion.OffsetX := LBmpRect.Left;
                FRegion.OffsetY := LBmpRect.Top;
                FRegion.Scale   := imgDrawingArea.Scale;

                FRegion.MouseDown(Button, Shift, FXActual, FYActual);
              end;

            mtMagneticLasso:
              begin
                if Assigned(FSelection) then
                begin
                  if FSelection.IsTranslated or
                     FSelection.IsCornerStretched or
                     FSelection.IsTransformed or
                     FSelection.IsHorizFlipped or
                     FSelection.IsVertFlipped or
                     FSelection.IsForeAlphaChanged then
                  begin
                    MessageDlg('The selection has been moved, resized, flipped or transformed.' + #10#13 +
                               'Cannot create new selection.', mtError, [mbOK], 0);
                               
                    tmrMarchingAnts.Enabled := True;
                    Exit;
                  end;
                end;

                if not Assigned(FMagneticLassoLayer) then
                begin
                  CreateLassoLayer;
                end;

                // create Magnetic Lasso
                if not Assigned(FMagneticLasso) then
                begin
                  case FChannelManager.CurrentChannelType of
                    wctAlpha:
                      begin
                        FMagneticLasso := TgmMagneticLasso.Create(
                          FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                          FMagneticLassoLayer.Bitmap.Canvas);
                      end;

                    wctQuickMask:
                      begin
                        FMagneticLasso := TgmMagneticLasso.Create(
                          FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                          FMagneticLassoLayer.Bitmap.Canvas);
                      end;

                    wctLayerMask:
                      begin
                        FMagneticLasso := TgmMagneticLasso.Create(
                          FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                          FMagneticLassoLayer.Bitmap.Canvas);
                      end;

                    wctRGB, wctRed, wctGreen, wctBlue:
                      begin
                        if frmMain.chckbxUseAllLayers.Checked then
                        begin
                          LMergedBmp := TBitmap32.Create;
                          try
                            LMergedBmp.DrawMode := dmBlend;
                            FLayerPanelList.FlattenLayersToBitmap(LMergedBmp, dmBlend);

                            FMagneticLasso := TgmMagneticLasso.Create(
                              LMergedBmp, FMagneticLassoLayer.Bitmap.Canvas);
                          finally
                            LMergedBmp.Free;
                          end;
                        end
                        else
                        begin
                          FMagneticLasso := TgmMagneticLasso.Create(
                            FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                            FMagneticLassoLayer.Bitmap.Canvas);
                        end;
                      end;
                  end;

                  FMagneticLasso.IsInteractive := frmMain.chckbxMagneticLassoInteractive.Checked;
                end;

                if Assigned(FMagneticLasso) then
                begin
                  FMagneticLasso.MouseDown(Button, Shift, FXActual, FYActual);

                  if Assigned(FMagneticLassoLayer) then
                  begin
                    FMagneticLassoLayer.Changed;
                  end;
                end;

                if Assigned(FSelection) then
                begin
                  // the Image must be updated before drawing the Marching Ants lines
                  imgDrawingArea.Update;
                  DrawMarchingAnts;
                end;
              end;
          end;
        end;
    end;

    if Assigned(FSelection) then
    begin
      if FSelectionCopy = nil then
      begin
        FSelectionCopy := TgmSelection.Create;
      end;

      FSelectionCopy.AssignAllSelectionData(FSelection);
    end
    else
    begin
      if Assigned(FSelectionCopy) then
      begin
        FreeAndNil(FSelectionCopy);
      end;
    end;

    FDrawing := True;
  end;
end;

procedure TfrmChild.MarqueeToolsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
var
  LNewPoint        : TPoint;
  LTranslateVector : TPoint;
  LColor           : TColor;
begin
  CalcLayerCoord(X, Y);  // get layer space coordinates
  
{ Move mouse when mouse left button down }

  if FDrawing then
  begin
    case FMarqueeDrawingState of
      dsNewFigure:
        begin
          case frmMain.MarqueeTool of
            mtSingleRow,
            mtSingleColumn,
            mtRectangular,
            mtRoundRectangular,
            mtElliptical,
            mtPolygonal,
            mtRegularPolygon,
            mtLasso:
              begin
                if Assigned(FRegion) then
                begin
                  FRegion.MouseMove(Shift, FXActual, FYActual);
                end;
              end;

            mtMagneticLasso:
              begin
                if Assigned(FMagneticLasso) then
                begin
                  FMagneticLasso.MouseMove(Shift, FXActual, FYActual);

                  if Assigned(FMagneticLassoLayer) then
                  begin
                    FMagneticLassoLayer.Changed;
                  end;
                end;

                if Assigned(FSelection) then
                begin
                  // the Image must be updated before drawing the Marching Ants lines
                  imgDrawingArea.Update;
                  DrawMarchingAnts;
                end;
              end;
          end;
        end;

      dsStretchCorner:
        begin
          if Assigned(FSelection) then
          begin
            { The border of the selection is always wider than the actual selection
              by the radius of the border handle at each side. }

            case FMarqueeDrawingHandle of
              dhAxAy:
                begin
                  FSelection.FMaskBorderStart.X := FXActual + SELECTION_HANDLE_RADIUS;
                  FSelection.FMaskBorderStart.Y := FYActual + SELECTION_HANDLE_RADIUS;
                end;

              dhBxBy:
                begin
                  FSelection.FMaskBorderEnd.X := FXActual - SELECTION_HANDLE_RADIUS;
                  FSelection.FMaskBorderEnd.Y := FYActual - SELECTION_HANDLE_RADIUS;
                end;

              dhAxBy:
                begin
                  FSelection.FMaskBorderStart.X := FXActual + SELECTION_HANDLE_RADIUS;
                  FSelection.FMaskBorderEnd.Y   := FYActual - SELECTION_HANDLE_RADIUS;
                end;

              dhBxAy:
                begin
                  FSelection.FMaskBorderStart.Y := FYActual + SELECTION_HANDLE_RADIUS;
                  fSelection.FMaskBorderEnd.X   := FXActual - SELECTION_HANDLE_RADIUS;
                end;

              dhTopHalfAxBx:
                begin
                  FSelection.FMaskBorderStart.Y := FYActual + SELECTION_HANDLE_RADIUS;
                end;
                
              dhBottomHalfAxBx:
                begin
                  FSelection.FMaskBorderEnd.Y := FYActual - SELECTION_HANDLE_RADIUS;
                end;

              dhLeftHalfAyBy:
                begin
                  FSelection.FMaskBorderStart.X := FXActual + SELECTION_HANDLE_RADIUS;
                end;
                
              dhRightHalfAyBy:
                begin
                  FSelection.FMaskBorderEnd.X := FXActual - SELECTION_HANDLE_RADIUS;
                end;
            end;

            FSelection.StandardizeOrder;
            FSelection.ResizeSelection;
            FSelection.GetMarchingAntsLines;

            case FChannelManager.CurrentChannelType of
              wctAlpha:
                begin
                  if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
                  begin
                    FSelection.ShowSelection(
                      FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                      FChannelManager.ChannelSelectedSet);

                    FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
                  end;
                end;

              wctQuickMask:
                begin
                  FSelection.ShowSelection(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                                           FChannelManager.ChannelSelectedSet);

                  FChannelManager.QuickMaskPanel.AlphaLayer.Changed;
                end;

              wctLayerMask:
                begin
                  FSelection.ShowSelection(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                                           FChannelManager.ChannelSelectedSet);

                  if Assigned(FChannelManager.LayerMaskPanel) and
                     FChannelManager.LayerMaskPanel.IsChannelVisible then
                  begin
                    FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(0, 0,
                      FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
                  end;

                  FLayerPanelList.SelectedLayerPanel.Update;
                end;

              wctRGB, wctRed, wctGreen, wctBlue:
                begin // must be on layer
                  FSelection.ShowSelection(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                                           FChannelManager.ChannelSelectedSet);

                  if FLayerPanelList.SelectedLayerPanel.IsHasMask then
                  begin
                    // save the alpha channel data of the current layer with a grayscale bitmap
                    GetAlphaChannelBitmap(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                                          FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                  end;

                  FLayerPanelList.SelectedLayerPanel.Update;
                end;
            end;

            imgDrawingArea.Update;  // we need to update the image control before drawing the Marching-Ants lines
            RemoveMarchingAnts;     // clear old Marching-Ants lines
            DrawMarchingAnts;       // darw new Marching-Ants lines
          end;
        end;

      dsTranslate:
        begin
          if Assigned(FSelection) then
          begin
            // calculate the new position
            LNewPoint        := Point(FXActual, FYActual);
            LTranslateVector := SubtractPoints(LNewPoint, FDrawingBasePoint);
            
            FSelection.TranslateSelection(LTranslateVector);

            case FChannelManager.CurrentChannelType of
              wctAlpha:
                begin
                  if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
                  begin
                    FSelection.ShowSelection(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                                             FChannelManager.ChannelSelectedSet);

                    FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
                  end
                  else
                  begin
                    FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
                  end;
                end;

              wctQuickMask:
                begin
                  FSelection.ShowSelection(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                                           FChannelManager.ChannelSelectedSet);

                  FChannelManager.QuickMaskPanel.AlphaLayer.Changed;
                end;

              wctLayerMask:
                begin
                  FSelection.ShowSelection(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                                           FChannelManager.ChannelSelectedSet);

                  if Assigned(FChannelManager.LayerMaskPanel) and
                     FChannelManager.LayerMaskPanel.IsChannelVisible then
                  begin
                    FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(0, 0,
                      FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
                  end;

                  FLayerPanelList.SelectedLayerPanel.Update;
                end;

              wctRGB, wctRed, wctGreen, wctBlue:
                begin
                  // must be on layer
                  if FLayerPanelList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent] then
                  begin
                    FSelection.ShowSelection(
                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                      FChannelManager.ChannelSelectedSet);

                    if FLayerPanelList.SelectedLayerPanel.IsHasMask then
                    begin
                      // save alpha channel of current layer
                      GetAlphaChannelBitmap(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                                            FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                    end;
                  end;

                  FLayerPanelList.SelectedLayerPanel.Update;
                end;
            end;

            imgDrawingArea.Update;
            RemoveMarchingAnts;
            DrawMarchingAnts;
            FDrawingBasePoint := LNewPoint;
          end;
        end;
    end;
  end
  else // if the FDrawing = False
  begin
    if Assigned(FSelection) then
    begin
      if FMarqueeDrawingState = dsNotDrawing then
      begin
        if (FChannelManager.CurrentChannelType in [wctAlpha, wctQuickMask, wctLayerMask]) or
           (FLayerPanelList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent]) then
        begin
          FMarqueeDrawingHandle := FSelection.GetHandleAtPoint(
            FXActual, FYActual, SELECTION_HANDLE_RADIUS);
        end
        else
        begin
          FMarqueeDrawingHandle := dhNone;
        end;

        if FMarqueeDrawingHandle in [dhNone, dhAxAy, dhBxBy, dhAxBy, dhBxAy,
                                     dhLeftHalfAyBy, dhRightHalfAyBy,
                                     dhTopHalfAxBx, dhBottomHalfAxBx] then
        begin
          Screen.Cursor := SetCursorByHandle(FMarqueeDrawingHandle);
        end;
      end;
    end;

    if (FXActual >= 0) and
       (FYActual >= 0) and
       (FXActual <= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width) and
       (FYActual <= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height) then
    begin
      // showing the color info of the pixel which is below the mouse pointer
      LColor := imgDrawingArea.Canvas.Pixels[X, Y];
      
      frmMain.ShowColorRGBInfoOnInfoViewer(LColor);
      frmMain.ShowColorCMYKInfoOnInfoViewer(LColor);
    end;
  end;

  imgDrawingArea.Canvas.Pen.Mode := pmCopy;
  frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
end;

procedure TfrmChild.MarqueeToolsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  LMergedBmp        : TBitmap32;
  LCmdAim           : TCommandAim;
  LHistoryStatePanel: TgmHistoryStatePanel;
  LCommandIconIndex : Integer;
begin
  CalcLayerCoord(X, Y);  // get layer space coordinates

{ Move mouse when mouse left button down }

  if FDrawing then
  begin
    FDrawing := False;
    
    imgDrawingArea.Canvas.Pen.Mode := pmCopy;

    case FMarqueeDrawingState of
      dsNewFigure:
        begin
          // if the selection has not been created, then create one
          if FSelection = nil then
          begin
            FSelection := TgmSelection.Create;

            // this line is necessary
            FSelection.SetOriginalMask(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
                                       FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height);

            case FChannelManager.CurrentChannelType of
              wctAlpha:
                begin
                  if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
                  begin
                    FSelection.SourceBitmap.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
                    FSelection.Background.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
                  end
                  else
                  begin
                    // in order to let the source bitmap of the selection has the same size as current layer
                    FSelection.SourceBitmap.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
                    FSelection.Background.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
                  end;
                end;

              wctQuickMask:
                begin
                  FSelection.SourceBitmap.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
                  FSelection.Background.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
                end;

              wctLayerMask:
                begin
                  FSelection.SourceBitmap.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
                  FSelection.Background.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
                end;

              wctRGB, wctRed, wctGreen, wctBlue:
                begin
                  // must be on layer
                  if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                  begin
                    ReplaceAlphaChannelWithMask(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                                                FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                  end;

                  // these methods must be called
                  FSelection.SourceBitmap.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
                  FSelection.Background.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
                end;
            end;
          end;

          if (FSelection.IsTranslated      = False) and
             (FSelection.IsCornerStretched = False) and
             (FSelection.IsHorizFlipped    = False) and
             (FSelection.IsVertFlipped     = False) then
          begin
            LCommandIconIndex := 0;

            case frmMain.MarqueeTool of
              mtSingleRow,
              mtSingleColumn,
              mtRectangular,
              mtRoundRectangular,
              mtElliptical,
              mtPolygonal,
              mtRegularPolygon,
              mtLasso:
                begin
                  if Assigned(FRegion) then
                  begin
                    FRegion.MouseUp(Button, Shift, FXActual, FYActual);

                    // for Polygonal region...
                    if not FRegion.IsRegionDefineCompleted then
                    begin
                      if Assigned(FSelection) then
                      begin
                        tmrMarchingAnts.Enabled := True;
                      end;

                      Exit;
                    end;

                    if FRegion.IsValidRegion then
                    begin
                      FSelection.CreateCustomRGN(FRegion.Region, frmMain.MarqueeMode);
                    end;

                    FreeAndNil(FRegion);

                    if frmMain.MarqueeTool = mtSingleRow then
                    begin
                      LCommandIconIndex := SINGLE_ROW_MARQUEE_COMMAND_ICON_INDEX;
                    end
                    else if frmMain.MarqueeTool = mtSingleColumn then
                    begin
                      LCommandIconIndex := SINGLE_COLUMN_MARQUEE_COMMAND_ICON_INDEX;
                    end
                    else if frmMain.MarqueeTool = mtRectangular then
                    begin
                      LCommandIconIndex := RECT_MARQUEE_COMMAND_ICON_INDEX;
                    end
                    else if frmMain.MarqueeTool = mtRoundRectangular then
                    begin
                      LCommandIconIndex := ROUND_RECT_MARQUEE_COMMAND_ICON_INDEX;
                    end
                    else if frmMain.MarqueeTool = mtElliptical then
                    begin
                      LCommandIconIndex := ELLIPTICAL_MARQUEE_COMMAND_ICON_INDEX;
                    end
                    else if frmMain.MarqueeTool = mtRegularPolygon then
                    begin
                      LCommandIconIndex := REGULAR_POLY_COMMAND_ICON_INDEX;
                    end
                    else if frmMain.MarqueeTool = mtPolygonal then
                    begin
                      LCommandIconIndex := POLY_MARQUEE_COMMAND_ICON_INDEX;
                    end
                    else if frmMain.MarqueeTool = mtLasso then
                    begin
                      LCommandIconIndex := LASSO_MARQUEE_COMMAND_ICON_INDEX;
                    end;
                  end;
                end;

              mtMagicWand:
                begin
                  if (FXActual >= 0) and
                     (FYActual >= 0) and
                     (FXActual < FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width) and
                     (FYActual < FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height) then
                  begin
                    FSelection.MagicTolerance := frmMain.MagicWandTolerance / 100;

                    case FChannelManager.CurrentChannelType of
                      wctAlpha:
                        begin
                          if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
                          begin
                            FSelection.CreateMagicWandMarqueeRGN(
                              FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap, FXActual, FYActual,
                              FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Pixel[FXActual, FYActual],
                              frmMain.MarqueeMode);
                          end;
                        end;

                      wctQuickMask:
                        begin
                          FSelection.CreateMagicWandMarqueeRGN(
                            FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap, FXActual, FYActual,
                            FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.Pixel[FXActual, FYActual],
                            frmMain.MarqueeMode);
                        end;

                      wctLayerMask:
                        begin
                          FSelection.CreateMagicWandMarqueeRGN(
                            FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap, FXActual, FYActual,
                            FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Pixel[FXActual, FYActual],
                            frmMain.MarqueeMode);
                        end;

                      wctRGB, wctRed, wctGreen, wctBlue:
                        begin
                          // must be on layer
                          if frmMain.chckbxUseAllLayers.Checked then
                          begin
                            LMergedBmp := TBitmap32.Create;
                            try
                              LMergedBmp.DrawMode := dmBlend;
                              FLayerPanelList.FlattenLayersToBitmap(LMergedBmp, dmBlend);

                              FSelection.CreateMagicWandMarqueeRGN(LMergedBmp,
                                FXActual, FYActual, LMergedBmp.Pixel[FXActual, FYActual],
                                frmMain.MarqueeMode);
                            finally
                              LMergedBmp.Free;
                            end;
                          end
                          else
                          begin
                            FSelection.CreateMagicWandMarqueeRGN(
                              FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap, FXActual, FYActual,
                              FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Pixel[FXActual, FYActual],
                              frmMain.MarqueeMode);
                          end;
                        end;
                    end;

                    LCommandIconIndex := MAGIC_WAND_MARQUEE_COMMAND_ICON_INDEX;
                  end;
                end;

              mtMagneticLasso:
                begin
                  if Assigned(FMagneticLasso) then
                  begin
                    if FDoubleClicked = False then
                    begin
                      FMagneticLasso.MouseUp(Button, Shift, FXActual, FYActual);

                      if Assigned(FMagneticLassoLayer) then
                      begin
                        FMagneticLassoLayer.Changed;
                      end;

                      if Assigned(FSelection) then
                      begin
                        tmrMarchingAnts.Enabled := True;
                      end;

                      Exit;
                    end
                    else
                    begin
                      FDoubleClicked := False; // restore the mark

                      // convert lasso to selection
                      if FMagneticLasso.IsConnected then
                      begin
                        FSelection.CreateCustomRGN(FMagneticLasso.CurveRegion,
                                                   frmMain.MarqueeMode);

                        FreeAndNil(FMagneticLasso);

                        if Assigned(FMagneticLassoLayer) then
                        begin
                          FreeAndNil(FMagneticLassoLayer);
                        end;

                        LCommandIconIndex := MAGNETIC_LASSO_MARQUEE_COMMAND_ICON_INDEX;
                      end
                      else
                      begin
                        if Assigned(FSelection) then
                        begin
                          tmrMarchingAnts.Enabled := True;
                        end;

                        Exit;
                      end;
                    end;
                  end;
                end;
            end;

            FSelection.Background.Assign(FSelection.SourceBitmap);
            FSelection.GetActualMaskBorder;
            FSelection.CutRegionFromOriginal;
            FSelection.GetForeground;
            FSelection.GetMarchingAntsLines;

            // update the background of the layer/mask
            if FChannelManager.CurrentChannelType in [wctAlpha, wctQuickMask, wctLayerMask] then
            begin
              FSelection.GetBackgroundWithFilledColor( Color32(frmMain.BackGrayColor),
                                                       FChannelManager.ChannelSelectedSet );
            end
            else // must be on layer
            begin
              case FLayerPanelList.SelectedLayerPanel.LayerFeature of
                lfBackground:
                  begin
                    FSelection.GetBackgroundWithFilledColor( Color32(frmMain.GlobalBackColor),
                                                             FChannelManager.ChannelSelectedSet );
                  end;

                lfTransparent:
                  begin
                    if (csRed   in FChannelManager.ChannelSelectedSet) and
                       (csGreen in FChannelManager.ChannelSelectedSet) and
                       (csBlue  in FChannelManager.ChannelSelectedSet) then
                    begin
                      FSelection.GetBackgroundWithTransparent;
                    end
                    else
                    begin
                      FSelection.GetBackgroundWithFilledColor( Color32(frmMain.GlobalBackColor),
                                                               FChannelManager.ChannelSelectedSet );
                    end;
                  end;
              end;
            end;
          end
          else
          begin
            MessageDlg('Could not create a new selection,' + #10#13 +
                       'because the current selection was flipped,' + #10#13 +
                       'translated or resized.', mtInformation, [mbOK], 0);

            if Assigned(FRegion) then
            begin
              FreeAndNil(FRegion);
            end;

            ShowProcessedSelection;
            tmrMarchingAnts.Enabled := True;

            if Assigned(FSelectionCopy) then
            begin
              FreeAndNil(FSelectionCopy);
            end;

            Exit;
          end;

          // show selection
          case FChannelManager.CurrentChannelType of
            wctAlpha:
              begin
                if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
                begin
                  FSelection.ShowSelection(
                    FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                    FChannelManager.ChannelSelectedSet);

                  FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
                end;
              end;

            wctQuickMask:
              begin
                FSelection.ShowSelection(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                                         FChannelManager.ChannelSelectedSet);

                FChannelManager.QuickMaskPanel.AlphaLayer.Changed;
              end;

            wctLayerMask:
              begin
                FSelection.ShowSelection(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                                         FChannelManager.ChannelSelectedSet);

                FLayerPanelList.SelectedLayerPanel.Update;
              end;

            wctRGB, wctRed, wctGreen, wctBlue:
              begin
                // mast be on layer
                if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                     lfBackground, lfTransparent] then
                begin
                  FSelection.ShowSelection(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                                           FChannelManager.ChannelSelectedSet);

                  FLayerPanelList.SelectedLayerPanel.Update;
                end;
              end;
          end;

          // if the selection shadow is not exists, the delete the selection
          if FSelection.HasShadow = False then
          begin
            case FChannelManager.CurrentChannelType of
              wctAlpha:
                begin
                  if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
                  begin
                    FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Assign(FSelection.SourceBitmap);
                    FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
                  end;
                end;

              wctQuickMask:
                begin
                  FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.Assign(FSelection.SourceBitmap);
                  FChannelManager.QuickMaskPanel.AlphaLayer.Changed;
                end;

              wctLayerMask:
                begin
                  FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Assign(FSelection.SourceBitmap);
                  FLayerPanelList.SelectedLayerPanel.Update;
                end;

              wctRGB, wctRed, wctGreen, wctBlue:
                begin
                  // must be on layer
                  if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                       lfBackground, lfTransparent] then
                  begin
                    FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Assign(FSelection.SourceBitmap);
                    FLayerPanelList.SelectedLayerPanel.Update;
                  end;
                end;
            end;

            FreeAndNil(FSelection);
            frmMain.spdbtnCommitSelection.Enabled := False;
            frmMain.spdbtnDeselect.Enabled        := False;
            frmMain.spdbtnDeleteSelection.Enabled := False;
          end
          else
          begin
            frmMain.spdbtnCommitSelection.Enabled := True;
            frmMain.spdbtnDeselect.Enabled        := True;
            frmMain.spdbtnDeleteSelection.Enabled := True;
          end;

          ChangeImageCursorByMarqueeTools; 

          // create Undo/Redo for selection
          if Assigned(FSelection) then
          begin
            LCmdAim := GetCommandAimByCurrentChannel;

            LHistoryStatePanel := TgmSelectionStatePanel.Create(
              frmHistory.scrlbxHistory,
              dmHistory.bmp32lstHistory.Bitmap[LCommandIconIndex],
              LCmdAim,
              frmMain.MarqueeTool,
              sctNew,
              FSelectionCopy,
              FSelection,
              FChannelManager.SelectedAlphaChannelIndex);

            FHistoryManager.AddHistoryState(LHistoryStatePanel);
          end;
        end;

      dsStretchCorner, dsTranslate:
        begin
          LHistoryStatePanel := nil;

          Screen.Cursor := crDefault;
          ChangeImageCursorByMarqueeTools;

          if Assigned(FSelection) then
          begin
            if FSelection.MarchingAntsLineList.Count > 0 then
            begin
              ActiveChildForm.UpdateSelectionHandleBorder;
            end;

            // Undo/Redo command
            LCmdAim := GetCommandAimByCurrentChannel;

            if FMarqueeDrawingState = dsTranslate then
            begin
              LHistoryStatePanel := TgmSelectionStatePanel.Create(
                frmHistory.scrlbxHistory,
                dmHistory.bmp32lstHistory.Bitmap[MOVE_OBJECTS_COMMAND_ICON_INDEX],
                LCmdAim,
                frmMain.MarqueeTool,
                sctTranslate,
                FSelectionCopy,
                FSelection,
                FChannelManager.SelectedAlphaChannelIndex);
            end
            else
            if FMarqueeDrawingState = dsStretchCorner then
            begin
              LHistoryStatePanel := TgmSelectionStatePanel.Create(
                frmHistory.scrlbxHistory,
                dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
                LCmdAim,
                frmMain.MarqueeTool,
                sctStretchCorner,
                FSelectionCopy,
                FSelection,
                FChannelManager.SelectedAlphaChannelIndex);
            end;

            if Assigned(LHistoryStatePanel) then
            begin
              FHistoryManager.AddHistoryState(LHistoryStatePanel);
            end;
          end;

          FMarqueeDrawingState := dsNotDrawing;

          case FChannelManager.CurrentChannelType of
            wctAlpha:
              begin
                if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
                begin
                  FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
                end;
              end;

            wctQuickMask:
              begin
                FChannelManager.QuickMaskPanel.AlphaLayer.Changed;
              end;
              
            wctLayerMask:
              begin
                FLayerPanelList.SelectedLayerPanel.Update;
              end;

            wctRGB, wctRed, wctGreen, wctBlue:
              begin
                // must be on layer
                FLayerPanelList.SelectedLayerPanel.Update;
              end;
          end;
        end;
    end;

    if Assigned(FSelection) and
       (FSelection.MarchingAntsLineList.Count > 0) then
    begin
      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
      imgDrawingArea.Update;
      RemoveMarchingAnts;
      tmrMarchingAnts.Enabled := True;
    end;

    case FChannelManager.CurrentChannelType of
      wctAlpha:
        begin
          if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
          begin
            FChannelManager.SelectedAlphaChannelPanel.UpdateThumbnail;
          end;
        end;

      wctQuickMask:
        begin
          FChannelManager.QuickMaskPanel.UpdateThumbnail;
        end;
        
      wctLayerMask:
        begin
          FLayerPanelList.SelectedLayerPanel.UpdateMaskThumbnail;

          // update the mask channel preview layer
          FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(
            0, 0, FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
            
          FChannelManager.LayerMaskPanel.UpdateThumbnail;

          FChannelManager.UpdateColorChannelThumbnails(FLayerPanelList);
        end;

      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
               lfBackground, lfTransparent] then
          begin
            FLayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
            FChannelManager.UpdateColorChannelThumbnails(FLayerPanelList);
          end;
        end;
    end;

    if Assigned(FSelectionCopy) then
    begin
      FreeAndNil(FSelectionCopy);
    end;
  end;
end; 

// translate selection by keyboard stroke
procedure TfrmChild.TranslateSelectionKeyDown(var Key: Word; Shift: TShiftState);
var
  LTranslateVector : TPoint;
  LIncrement       : Integer;
begin
  // if a selection definition has not been finished...
  if Assigned(FRegion) or Assigned(FMagneticLasso) then
  begin
    Exit;
  end;

  if Key in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN] then
  begin
    if Assigned(FSelection) then
    begin
      if tmrMarchingAnts.Enabled <> False then
      begin
        tmrMarchingAnts.Enabled := False;
      end;

      RemoveMarchingAnts;

      if ssShift in Shift then
      begin
        LIncrement := 10;
      end
      else
      begin
        LIncrement := 1;
      end;

      case Key of
        VK_LEFT:
          begin
            LTranslateVector := Point(-LIncrement, 0);
          end;

        VK_UP:
          begin
            LTranslateVector := Point(0, -LIncrement);
          end;
          
        VK_RIGHT:
          begin
            LTranslateVector := Point(LIncrement, 0);
          end;
          
        VK_DOWN:
          begin
            LTranslateVector := Point(0, LIncrement);
          end;
      end;

      if (ssCtrl in Shift) or
         (FSelection.IsProcessed) or
         (not FSelection.IsPrimitive) then
      begin
        // For Undo/Redo
        if FKeyIsDown = False then
        begin
          if FSelectionCopy = nil then
          begin
            FSelectionCopy := TgmSelection.Create;
          end;

          FSelectionCopy.AssignAllSelectionData(FSelection);
          FKeyIsDown := True;
        end;

        // translate selection
        FSelection.TranslateSelection(LTranslateVector);

        case FChannelManager.CurrentChannelType of
          wctAlpha:
            begin
              if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
              begin
                FSelection.ShowSelection(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                                         FChannelManager.ChannelSelectedSet);
              end;
            end;

          wctQuickMask:
            begin
              FSelection.ShowSelection(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                                       FChannelManager.ChannelSelectedSet);
            end;

          wctLayerMask:
            begin
              FSelection.ShowSelection(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                                       FChannelManager.ChannelSelectedSet);
            end;

          wctRGB, wctRed, wctGreen, wctBlue:
            begin
              if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                   lfBackground, lfTransparent] then
              begin
                FSelection.ShowSelection(
                  FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                  FChannelManager.ChannelSelectedSet);
              end;
            end;
        end;

        // mark that we are translate the selection itself
        if FSelectionTranslateTarget <> sttSelection then
        begin
          FSelectionTranslateTarget := sttSelection;
        end;
      end
      else
      begin
        // For Undo/Redo
        if FKeyIsDown = False then
        begin
          if FSelectionCopy = nil then
          begin
            FSelectionCopy := TgmSelection.Create;
          end;

          FSelectionCopy.AssignAllSelectionData(FSelection);
          FKeyIsDown := True;
        end;

        // Nudge Selection Outline
        if (not FSelection.IsProcessed) and FSelection.IsPrimitive then
        begin
          FSelection.TranslateCutRegion(LTranslateVector);
        end;

        // mark that we are translate the cutted region of the selection
        if FSelectionTranslateTarget <> sttCutRegion then
        begin
          FSelectionTranslateTarget := sttCutRegion;
        end;
      end;

      if frmMain.MarqueeTool = mtMoveResize then
      begin
        Self.UpdateSelectionHandleBorder;
      end;

      case FChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
            begin
              FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
            end;
          end;

        wctQuickMask:
          begin
            FChannelManager.QuickMaskPanel.AlphaLayer.Changed;
          end;

        wctLayerMask:
          begin
            FLayerPanelList.SelectedLayerPanel.Update;
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            FLayerPanelList.SelectedLayerPanel.Update;
          end;
      end;

      imgDrawingArea.Update;
      DrawMarchingAnts;
    end;
  end;
end; 

procedure TfrmChild.TranslateSelectionKeyUp(var Key: Word; Shift: TShiftState);
var
  LStdCutMask       : TBitmap;
  LCmdAim           : TCommandAim;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  // if a selection definition has not been finished...
  if Assigned(FRegion) or Assigned(FMagneticLasso) then
  begin
    Exit;
  end;

  LHistoryStatePanel := nil;

  if Key in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN] then
  begin
    if Assigned(FSelection) then
    begin
      RemoveMarchingAnts;
      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;

      case FSelectionTranslateTarget of
        sttSelection:
          begin
            // Undo/Redo
            LCmdAim := GetCommandAimByCurrentChannel;

            LHistoryStatePanel := TgmSelectionStatePanel.Create(
              frmHistory.scrlbxHistory,
              dmHistory.bmp32lstHistory.Bitmap[MOVE_OBJECTS_COMMAND_ICON_INDEX],
              LCmdAim,
              frmMain.MarqueeTool,
              sctTranslate,
              FSelectionCopy,
              FSelection,
              FChannelManager.SelectedAlphaChannelIndex);
          end;

        sttCutRegion:
          begin
            { If the cut region is out of the range of current layer,
              then recalculating the selection. }
            if (FSelection.FMaskBorderStart.X < 0) or
               (FSelection.FMaskBorderStart.Y < 0) or
               (FSelection.FMaskBorderEnd.X >= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width) or
               (FSelection.FMaskBorderEnd.Y >= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height) then
            begin
              FSelection.OriginalMask.Clear(clBlack32);
              
              LStdCutMask := TBitmap.Create;
              try
                LStdCutMask.Assign(FSelection.CutMask);

                FSelection.OriginalMask.Canvas.Draw(FSelection.FMaskBorderStart.X,
                                                    FSelection.FMaskBorderStart.Y,
                                                    LStdCutMask);
              finally
                LStdCutMask.Free;
              end;

              FSelection.GetActualMaskBorder;
              FSelection.CutRegionFromOriginal;
              FSelection.GetForeground;
              FSelection.GetMarchingAntsLines;  
            end;

            // update the background
            case FChannelManager.CurrentChannelType of
              wctAlpha, wctQuickMask, wctLayerMask:
                begin
                  FSelection.GetBackgroundWithFilledColor(
                    Color32(frmMain.BackGrayColor),
                    FChannelManager.ChannelSelectedSet );
                end;

              wctRGB, wctRed, wctGreen, wctBlue:
                begin
                  case FLayerPanelList.SelectedLayerPanel.LayerFeature of
                    lfBackground:
                      begin
                        FSelection.GetBackgroundWithFilledColor(
                          Color32(frmMain.GlobalBackColor),
                          FChannelManager.ChannelSelectedSet );
                      end;

                    lfTransparent:
                      begin
                        if (csRed   in FChannelManager.ChannelSelectedSet) and
                           (csGreen in FChannelManager.ChannelSelectedSet) and
                           (csBlue  in FChannelManager.ChannelSelectedSet) then
                        begin
                          FSelection.GetBackgroundWithTransparent;
                        end
                        else
                        begin
                          FSelection.GetBackgroundWithFilledColor(
                            Color32(frmMain.GlobalBackColor),
                            FChannelManager.ChannelSelectedSet );
                        end;
                      end;
                  end;
                end;
            end;

            // Undo/Redo
            LCmdAim := GetCommandAimByCurrentChannel;

            LHistoryStatePanel := TgmSelectionStatePanel.Create(
              frmHistory.scrlbxHistory,
              dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
              LCmdAim,
              frmMain.MarqueeTool,
              sctNudgeSelectionOutline,
              FSelectionCopy,
              FSelection,
              FChannelManager.SelectedAlphaChannelIndex);
          end;
      end;

      // Update thumbnails.
      UpdateThumbnailsBySelectedChannel;

      if not tmrMarchingAnts.Enabled then
      begin
        tmrMarchingAnts.Enabled := True;
      end;

      if Assigned(LHistoryStatePanel) then
      begin
        FHistoryManager.AddHistoryState(LHistoryStatePanel);
      end;
    end;
  end;
end;

procedure TfrmChild.GradientToolsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
begin
  CalcLayerCoord(X, Y);                 // get layer space coordinates
  CalcSelectionCoord;                   // get selection space coordinates
  UpdateMainFormStatusBarWhenMouseDown;

{ Mouse left button down }

  if Button = mbLeft then
  begin
    if FChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue] then
    begin
      if not (FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                lfBackground, lfTransparent]) then
      begin
        MessageDlg('Could not use the gradient tool ' + 'because the' + #10#13 +
                   'content of the layer is not directly' + #10#13 +
                   'editable.', mtError, [mbOK], 0);
        Exit;
      end;
    end;

    PauseMarchingAnts;       // don't draw dynamic Marching-Ants lines when processing image
    FImageProcessed := True; // mark the image has been modified

    imgDrawingArea.Canvas.Pen.Style := psSolid;
    imgDrawingArea.Canvas.Pen.Color := clBlack;
    imgDrawingArea.Canvas.Pen.Width := 1;

    FStartPoint := Point( FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100),
                          FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100) );

    FEndPoint         := FStartPoint;
    FActualStartPoint := Point(FXActual, FYActual);

    { Because in the mouse move event, it always clears the old line first and
      draws the new one, so we need to draw an "old" line to let the mouse
      move event to clears it. Note, the pen mode must be pmNotXor before darw
      the "old" line. }
    imgDrawingArea.Canvas.Pen.Mode := pmNotXor;
    imgDrawingArea.Canvas.MoveTo(FStartPoint.X, FStartPoint.Y);
    imgDrawingArea.Canvas.LineTo(FEndPoint.X, FEndPoint.Y);
    FDrawing := True;
  end;
end;

procedure TfrmChild.GradientToolsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
var
  AColor: TColor;
begin
  CalcLayerCoord(X, Y);   // get layer space coordinates
  CalcSelectionCoord;     // get selection space coordinates

{ Move mouse when mouse left button down }

  if FDrawing then
  begin
    // clear the old line with pen mode set to pmNotXor
    imgDrawingArea.Canvas.Pen.Mode := pmNotXor;
    imgDrawingArea.Canvas.MoveTo(FStartPoint.X, FStartPoint.Y);
    imgDrawingArea.Canvas.LineTo(FEndPoint.X, FEndPoint.Y);

    FEndPoint := Point( FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100),
                        FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100));

    // draw the new line
    imgDrawingArea.Canvas.MoveTo(FStartPoint.X, FStartPoint.Y);
    imgDrawingArea.Canvas.LineTo(FEndPoint.X, FEndPoint.Y);
  end
  else { Move mouse when mouse left button not down }
  begin
    if  (FXActual >= 0) and (FXActual <= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width)
    and (FYActual >= 0) and (FYActual <= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height) then
    begin
      AColor := imgDrawingArea.Canvas.Pixels[X, Y];
      frmMain.ShowColorRGBInfoOnInfoViewer(AColor);
      frmMain.ShowColorCMYKInfoOnInfoViewer(AColor);
    end;
  end;

  frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
end;

procedure TfrmChild.GradientToolsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  LHistoryStatePanel: TgmHistoryStatePanel;
  LCmdAim           : TCommandAim;
  LGradientRender   : TgmGradientRender;
begin
  CalcLayerCoord(X, Y);   // get layer space coordinates
  CalcSelectionCoord;     // get selection space coordinates

{ Mouse left button up }

  if Button = mbLeft then
  begin
    if FDrawing then
    begin
      FDrawing      := False;
      Screen.Cursor := crDefault;

      if imgDrawingArea.Canvas.Pen.Mode <> pmCopy
      then imgDrawingArea.Canvas.Pen.Mode := pmCopy;

      if FChannelManager.CurrentChannelType = wctAlpha then
      begin
        if not Assigned(FChannelManager.SelectedAlphaChannelPanel) then
        begin
          MessageDlg('Could not process more than one alpha channels at a time.', mtError, [mbOK], 0);
          Exit;
        end;
      end;

      LGradientRender := TgmGradientRender.Create;
      try
        LGradientRender.ColorGradient := frmGradientPicker.glDrawingToolGradients.Items[frmGradientPicker.DrawingToolGradientListState.SelectedIndex];
        LGradientRender.BlendMode     := frmMain.GradientBlendMode;
        LGradientRender.Opacity       := frmMain.GradientBlendOpacity / 100;
        LGradientRender.IsReverse     := frmMain.chckbxReverseGradient.Checked;
        LGradientRender.RenderMode    := frmMain.GradientRenderMode;
        LGradientRender.ChannelSet    := FChannelManager.ChannelSelectedSet;

        if Assigned(FSelection) then
        begin
          { Convert the coordiantes of endpoints of the gradient line from Image
            control space to selection space. Note, we just need to convert the
            starting point of the gradient line. }

          FActualStartPoint.X := MulDiv( FActualStartPoint.X - FSelection.FMaskBorderStart.X,
                                         FSelection.CutOriginal.Width - 1, FSelection.Foreground.Width - 1);

          FActualStartPoint.Y := MulDiv( FActualStartPoint.Y - FSelection.FMaskBorderStart.Y,
                                         FSelection.CutOriginal.Height - 1, FSelection.Foreground.Height - 1 );

          FActualEndPoint := Point(FMarqueeX, FMarqueeY);

          LGradientRender.StartPoint := FActualStartPoint;
          LGradientRender.EndPoint   := FActualEndPoint;

          // for Undo/Redo
          frmMain.FBeforeProc.Assign(FSelection.CutOriginal);

          // Then doing the gradient.
          if LGradientRender.Render(FSelection.CutOriginal) then
          begin
            ShowProcessedSelection;
            UpdateThumbnailsBySelectedChannel;

            // for Undo/Redo
            frmMain.FAfterProc.Assign(FSelection.CutOriginal);
          end;
        end
        else
        begin
          FActualEndPoint := Point(FXActual, FYActual);

          LGradientRender.StartPoint := FActualStartPoint;
          LGradientRender.EndPoint   := FActualEndPoint;

          case FChannelManager.CurrentChannelType of
            wctAlpha:
              begin
                if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
                begin
                  // for Undo/Redo
                  frmMain.FBeforeProc.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);

                  // then doing gradient
                  if LGradientRender.Render(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap) then
                  begin
                    FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
                    FChannelManager.SelectedAlphaChannelPanel.UpdateThumbnail;

                    // for Undo/Redo
                    frmMain.FAfterProc.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
                  end;
                end;
              end;

            wctQuickMask:
              begin
                if Assigned(FChannelManager.QuickMaskPanel) then
                begin
                  // for Undo/Redo
                  frmMain.FBeforeProc.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);

                  // then doing gradient
                  if LGradientRender.Render(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap) then
                  begin
                    FChannelManager.QuickMaskPanel.AlphaLayer.Changed;
                    FChannelManager.QuickMaskPanel.UpdateThumbnail;

                    // for Undo/Redo
                    frmMain.FAfterProc.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
                  end;
                end;
              end;

            wctLayerMask:
              begin
                // for Undo/Redo
                frmMain.FBeforeProc.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);

                // then doing gradient
                if LGradientRender.Render(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap) then
                begin
                  if Assigned(FChannelManager.LayerMaskPanel) then
                  begin
                    FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(0, 0,
                      FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);

                    FChannelManager.LayerMaskPanel.UpdateThumbnail;
                  end;

                  FLayerPanelList.SelectedLayerPanel.Update;
                  FLayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
                  FLayerPanelList.SelectedLayerPanel.UpdateMaskThumbnail;
                  FChannelManager.UpdateColorChannelThumbnails(FLayerPanelList);

                  // for Undo/Redo
                  frmMain.FAfterProc.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
                end;
              end;

            wctRGB, wctRed, wctGreen, wctBlue:
              begin
                if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                begin
                  ReplaceAlphaChannelWithMask(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                                              FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                end;

                // for Undo/Redo
                frmMain.FBeforeProc.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

                // then doing gradient
                if LGradientRender.Render(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap) then
                begin
                  // for Undo/Redo
                  frmMain.FAfterProc.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
                  FLayerPanelList.SelectedLayerPanel.Update;
                  FLayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
                  FChannelManager.UpdateColorChannelThumbnails(FLayerPanelList);
                end;
              end;
          end;
        end;

      finally
        FreeAndNil(LGradientRender);
      end;

      if Assigned(FSelection) then
      begin
        RemoveMarchingAnts;
        tmrMarchingAnts.Enabled := True;
      end;

      // Undo/Redo
      LCmdAim := GetCommandAimByCurrentChannel;

      LHistoryStatePanel := TgmImageManipulatingStatePanel.Create(
        frmHistory.scrlbxHistory,
        dmHistory.bmp32lstHistory.Bitmap[GRADIENT_COMMAND_ICON_INDEX],
        LCmdAim,
        'Gradient',
        frmMain.FBeforeProc,
        frmMain.FAfterProc,
        FSelection,
        FChannelManager.SelectedAlphaChannelIndex);

      FHistoryManager.AddHistoryState(LHistoryStatePanel);
    end;
  end;
end; 

procedure TfrmChild.CropToolsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
begin
  CalcLayerCoord(X, Y);  // get layer space coordinates

{ Mouse left button down }

  if Button = mbLeft then
  begin
    // show the coordinates of the starting point
    frmMain.ShowOriginalCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
    frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);

    with imgDrawingArea.Canvas do
    begin
      Pen.Color   := RUBBER_BAND_PEN_COLOR;
      Pen.Style   := RUBBER_BAND_PEN_STYLE;
      Pen.Width   := RUBBER_BAND_PEN_WIDTH;
      Brush.Color := RUBBER_BAND_BRUSH_COLOR;
      Brush.Style := RUBBER_BAND_BRUSH_STYLE;
    end;

    if Assigned(FCrop) then
    begin
      // 1.  Trying to stretch corner of selected figure?
      FCropDrawingHandle := FCrop.GetHandleAtPoint(FXActual, FYActual);

      if FCropDrawingHandle in [dhAXAY, dhBXBY, dhAXBY, dhBXAY, dhTopHalfAXBX,
                                dhBottomHalfAXBX, dhLeftHalfAYBY, dhRightHalfAYBY] then
      begin
        Screen.Cursor         := SetCursorByHandle(FCropDrawingHandle);
        imgDrawingArea.Cursor := Screen.Cursor;

        if FCropHandleLayer <> nil then
        begin
          FCropHandleLayer.Bitmap.Clear($00000000);
          FCrop.DrawCropBorder(FCropHandleLayer.Bitmap.Canvas, FCropHandleLayerOffsetVector);
          FCropHandleLayer.Bitmap.Changed;
        end;

        FCropDrawingState := dsStretchCorner;  // change crop tool to stretch state
      end
      else
      // 2.  Trying to translate selected figure(s)? Check first for existing set of selected figures.
      if FCrop.ContainsPoint( Point(FXActual, FYActual) ) then
      begin
        Screen.Cursor         := crDrag;
        imgDrawingArea.Cursor := crDrag;

        if FCropHandleLayer <> nil then
        begin
          FCropHandleLayer.Bitmap.Clear($00000000);
          FCrop.DrawCropBorder(FCropHandleLayer.Bitmap.Canvas, FCropHandleLayerOffsetVector);
          FCropHandleLayer.Bitmap.Changed;
        end;

        FCropDrawingState := dsTranslate;
        FDrawingBasePoint := Point(FXActual, FYActual);
      end;
    end
    else
    begin
      Screen.Cursor         := crCrop;
      imgDrawingArea.Cursor := crCrop;

      FStartPoint := Point( FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100),
                            FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100) );

      FEndPoint         := FStartPoint;
      FActualStartPoint := Point(FXActual, FYActual);
      
      DrawRectangle(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);
    end;
    
    FDrawing := True;
  end;
end;

procedure TfrmChild.CropToolsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
var
  NewPoint, TranslateVector: TPoint;
  AColor                   : TColor;
begin
  CalcLayerCoord(X, Y);  // get layer space coordinates

{ Move mouse when mouse left button down }

  if FDrawing then
  begin
    if Assigned(FCrop) then
    begin
      case FCropDrawingState of
        dsStretchCorner:
          begin
            with FCrop do
            begin
              // clear the old border
              DrawCropBorder(FCropHandleLayer.Bitmap.Canvas, FCropHandleLayerOffsetVector);

              case FCropDrawingHandle of
                dhAxAy: FCropStart := Point(FXActual, FYActual);
                dhBxBy: FCropEnd   := Point(FXActual, FYActual);

                dhAxBy: begin
                          FCropStart.X := FXActual;
                          FCropEnd.Y   := FYActual;
                        end;

                dhBxAy: begin
                          FCropStart.Y := FYActual;
                          FCropEnd.X   := FXActual;
                        end;

                dhTopHalfAxBx   : FCropStart.Y := FYActual;
                dhBottomHalfAxBx: FCropEnd.Y   := FYActual;
                dhLeftHalfAyBy  : FCropStart.X := FXActual;
                dhRightHalfAyBy : FCropEnd.X   := FXActual;
              end;

              StandardizeOrder;
              DrawShield;
              DrawCropBorder(FCropHandleLayer.Bitmap.Canvas, FCropHandleLayerOffsetVector);
              FCropHandleLayer.Bitmap.Changed;
            end;

            // showing the dimension of the cropped area
            frmMain.CanChange := False;
            try
              frmMain.edtCropWidth.Text  := IntToStr(FCrop.CropAreaWidth);
              frmMain.edtCropHeight.Text := IntToStr(FCrop.CropAreaHeight);
            finally
              frmMain.CanChange := True;
            end;
          end;

        dsTranslate:
          begin
            with FCrop do
            begin
              DrawCropBorder(FCropHandleLayer.Bitmap.Canvas, FCropHandleLayerOffsetVector);

              NewPoint        := Point(FXActual, FYActual);
              TranslateVector := SubtractPoints(NewPoint, FDrawingBasePoint);

              Translate(TranslateVector);
              DrawShield;
              DrawCropBorder(FCropHandleLayer.Bitmap.Canvas, FCropHandleLayerOffsetVector);
              FCropHandleLayer.Bitmap.Changed;
              FDrawingBasePoint := NewPoint;
            end;
          end;
      end;
    end
    else
    begin
      // clear the old figure
      DrawRectangle(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);

      FEndPoint := Point( FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100),
                          FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100));

      // drawing the new one
      DrawRectangle(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);

      // showing the dimension of the cropped area
      frmMain.CanChange := False;
      try
        frmMain.edtCropWidth.Text  := IntToStr(Abs(FEndPoint.X - FStartPoint.X));
        frmMain.edtCropHeight.Text := IntToStr(Abs(FEndPoint.Y - FStartPoint.Y));
      finally
        frmMain.CanChange := True;
      end;
    end;
  end
  else // if the FDrawing = False
  begin
    if Assigned(FCrop) then
    begin
      FCropDrawingHandle := FCrop.GetHandleAtPoint(FXActual, FYActual);
      Screen.Cursor      := SetCursorByHandle(FCropDrawingHandle);

      if Screen.Cursor = crDefault
      then imgDrawingArea.Cursor := crCrop
      else imgDrawingArea.Cursor := Screen.Cursor;
    end;

    if  (FXActual >= 0) and (FXActual <= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width)
    and (FYActual >= 0) and (FYActual <= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height) then
    begin
      AColor := imgDrawingArea.Canvas.Pixels[X, Y];
      frmMain.ShowColorRGBInfoOnInfoViewer(AColor);
      frmMain.ShowColorCMYKInfoOnInfoViewer(AColor);
    end;
  end;

  imgDrawingArea.Canvas.Pen.Mode := pmCopy;
  frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
end;

procedure TfrmChild.CropToolsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  CmdAim           : TCommandAim;
  HistoryStatePanel: TgmHistoryStatePanel;
begin
  CalcLayerCoord(X, Y);  // get layer space coordinates

{ Move mouse when mouse left button down }

  if FDrawing then
  begin
    FDrawing              := False;
    Screen.Cursor         := crDefault;
    imgDrawingArea.Cursor := crCrop;
    
    if Assigned(FCrop) then
    begin
      case FCropDrawingState of
        dsStretchCorner, dsTranslate:
          begin
            FCrop.DrawCropHandles(FCropHandleLayer.Bitmap.Canvas, FCropHandleLayerOffsetVector);
            FCropHandleLayer.Bitmap.Changed;
            FCropDrawingState := dsNotDrawing;
          end;
      end;
    end
    else
    begin
      // if there is an existing selection, we need to commit the selection first
      if FSelection <> nil then
      begin
        if FSelectionCopy = nil then
        begin
          FSelectionCopy := TgmSelection.Create;
        end;

        FSelectionCopy.AssignAllSelectionData(FSelection);
        CommitSelection;

        // Create Undo/Redo
        CmdAim := GetCommandAimByCurrentChannel;

        HistoryStatePanel := TgmSelectionStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          CmdAim,
          frmMain.MarqueeTool,
          sctCommitSelection,
          FSelectionCopy,
          FSelection,
          FChannelManager.SelectedAlphaChannelIndex);

        ActiveChildForm.FHistoryManager.AddHistoryState(HistoryStatePanel);
      end
      else
      begin
        FActualEndPoint := Point(FXActual, FYActual);
        PointStandardizeOrder(FActualStartPoint, FActualEndPoint);

        FCrop := TgmCrop.Create( FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
                                 FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height,
                                 imgDrawingArea.Layers,
                                 TBitmapLayer(imgDrawingArea.Layers.Items[0]).Location);
        with FCrop do
        begin
          FCropStart          := FActualStartPoint;
          FCropEnd            := FActualEndPoint;
          ShieldColor32       := Color32(frmMain.shpCroppedShieldColor.Brush.Color);
          ShieldOpacity       := frmMain.updwnCroppedShieldOpacity.Position;
          IsShieldCroppedArea := frmMain.chckbxShieldCroppedArea.Checked;
          DrawShield;
        end;

        if FCropHandleLayer = nil then
        begin
          CreateCropHandleLayer;
        end;

        FCrop.DrawCropBorder(FCropHandleLayer.Bitmap.Canvas, FCropHandleLayerOffsetVector);
        FCrop.DrawCropHandles(FCropHandleLayer.Bitmap.Canvas, FCropHandleLayerOffsetVector);
        FCropHandleLayer.Bitmap.Changed;
        frmMain.UpdateCropOptions;

        // disable channel manager and path panel manager when crop is created
        FChannelManager.IsEnabled := False;
        FPathPanelList.IsEnabled  := False;
      end;
    end;

    imgDrawingArea.Canvas.Pen.Mode := pmCopy;
  end;
end;

// translate Crop by keyboard stroke
procedure TfrmChild.TranslateCropKeyDown(var Key: Word; Shift: TShiftState);
var
  TranslateVector: TPoint;
  Increment      : Integer;
begin
  if Key in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN] then
  begin
    if Assigned(FCrop) then
    begin
      if   ssShift in Shift
      then Increment := 10
      else increment := 1;

      case Key of
        VK_LEFT : TranslateVector := Point(-Increment, 0);
        VK_UP   : TranslateVector := Point(0, -Increment);
        VK_RIGHT: TranslateVector := Point(Increment, 0);
        VK_DOWN : TranslateVector := Point(0, Increment);
      end;

      with FCrop do
      begin
        DrawCropBorder(FCropHandleLayer.Bitmap.Canvas, FCropHandleLayerOffsetVector);
        DrawCropHandles(FCropHandleLayer.Bitmap.Canvas, FCropHandleLayerOffsetVector);
        Translate(TranslateVector);
        DrawShield;
        DrawCropBorder(FCropHandleLayer.Bitmap.Canvas, FCropHandleLayerOffsetVector);
        DrawCropHandles(FCropHandleLayer.Bitmap.Canvas, FCropHandleLayerOffsetVector);
      end;
      
      FCropHandleLayer.Bitmap.Changed;
    end;
  end;
end;

// Paint Bucket Page
procedure TfrmChild.PaintBucketToolsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
begin
  CalcLayerCoord(X, Y);  // get layer space coordinates
  CalcSelectionCoord;    // get selection space coordinates

{ Mouse left button down }

  if Button = mbLeft then
  begin
    if FChannelManager.CurrentChannelType = wctAlpha then
    begin
      if not Assigned(FChannelManager.SelectedAlphaChannelPanel) then
      begin
        MessageDlg('Could not process more than one alpha channels at a time.', mtError, [mbOK], 0);
        Exit;
      end;
    end
    else
    if FChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue] then
    begin
      if not (FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                lfBackground, lfTransparent]) then
      begin
        MessageDlg('Could not use the Paint Bucket because the' + #10#13 +
                   'content of the layer is not directly' + #10#13 +
                   'editable.', mtError, [mbOK], 0);
        Exit;
      end;
    end;

    // processing only when the mouse pointer is on the layer or selection
    if Assigned(FSelection) then
    begin
      if not FSelection.IfPointsOnSelection(FMarqueeX, FMarqueeY)
      then Exit;
    end
    else
    begin
      if (FXActual < 0) or (FXActual > FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width - 1)
      or (FYActual < 0) or (FYActual > FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height - 1)
      then Exit;
    end;

    // showing the coordinates of the starting point
    frmMain.ShowOriginalCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
    frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);

    // not draw the dynamic Marching-Lines when process image
    if tmrMarchingAnts.Enabled = True
    then tmrMarchingAnts.Enabled := False;

    if Assigned(FSelection) then
    begin
      RemoveMarchingAnts;
      DrawMarchingAnts;
    end;

    if Assigned(FSelectionHandleLayer) then
    begin
      if FSelectionHandleLayer.Visible
      then FSelectionHandleLayer.Visible := False;
    end;

    // remember the bitmap for create Undo/Redo command
    if Assigned(FSelection)
    then frmMain.FBeforeProc.Assign(FSelection.CutOriginal)
    else
    begin
      case FChannelManager.CurrentChannelType of
        wctAlpha    : frmMain.FBeforeProc.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
        wctQuickMask: frmMain.FBeforeProc.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
        wctLayerMask: frmMain.FBeforeProc.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            frmMain.FBeforeProc.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

            if FLayerPanelList.SelectedLayerPanel.IsMaskLinked
            then ReplaceAlphaChannelWithMask(frmMain.FBeforeProc, FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
          end;
      end;
    end;

    FImageProcessed := True; // mark the image has been modified
    FDrawing        := True;
  end;
end;

procedure TfrmChild.PaintBucketToolsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
var
  AColor: TColor;
begin
  CalcLayerCoord(X, Y);  // get layer space coordinates

  if FDrawing = False then
  begin
    if  (FXActual >= 0) and (FXActual <= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width)
    and (FYActual >= 0) and (FYActual <= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height) then
    begin
      // showing the color info of the current pixel that under the mouse pointer
      AColor := imgDrawingArea.Canvas.Pixels[X, Y];
      frmMain.ShowColorRGBInfoOnInfoViewer(AColor);
      frmMain.ShowColorCMYKInfoOnInfoViewer(AColor);
    end;
  end;

  // showing the current coordinates of the mouse
  frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
end;

procedure TfrmChild.PaintBucketToolsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  LHistoryStatePanel: TgmHistoryStatePanel;
  LPaintBucket      : TgmPaintBucket;
  LFlattenBmp       : TBitmap32;
  LSampleBmp        : TBitmap32;
  LCmdAim           : TCommandAim;
begin
  if FDrawing then
  begin
    FDrawing := False;  // finish drawing

    if Assigned(FSelection) then
    begin
      if tmrMarchingAnts.Enabled = False then
      begin
        tmrMarchingAnts.Enabled := True;
      end;
    end;
    
    LFlattenBmp  := TBitmap32.Create;
    LSampleBmp   := TBitmap32.Create;
    LPaintBucket := TgmPaintBucket.Create;
    try
      LFlattenBmp.DrawMode := dmBlend;
      LSampleBmp.DrawMode  := dmBlend;

      LPaintBucket.Tolerance            := MulDiv(255, frmMain.PaintBucketTolerance, 100);
      LPaintBucket.Opacity              := MulDiv(255, frmMain.PaintBucketOpacity, 100);
      LPaintBucket.AdjustIntensity      := frmPaintBucketAdvancedOptions.updwnFillIntensity.Position / 100;
      LPaintBucket.FillSource           := frmMain.PaintBucketFillSource;
      LPaintBucket.BlendMode            := frmMain.PaintBucketBlendMode;
      LPaintBucket.ColorMode            := TgmPaintBucketColorMode(frmPaintBucketAdvancedOptions.cmbbxFillType.ItemIndex);
      LPaintBucket.PreserveTransparency := frmLayer.chckbxLockTransparency.Checked;
      LPaintBucket.ChannelSet           := FChannelManager.ChannelSelectedSet;

      if frmMain.chckbxFillContiguous.Checked then
      begin
        LPaintBucket.FillCondition := pbfcContiguous;
      end
      else
      begin
        LPaintBucket.FillCondition := pbfcDiscontiguous;
      end;

      // setting the filling color
      case FChannelManager.CurrentChannelType of
        wctAlpha,
        wctQuickMask,
        wctLayerMask:
          begin
            case frmMain.PaintBucketFillSource of
              pbfsForeColor:
                begin
                  LPaintBucket.Color := Color32(frmMain.ForeGrayColor);
                end;
                
              pbfsBackColor:
                begin
                  LPaintBucket.Color := Color32(frmMain.BackGrayColor);
                end;
            end;
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                 lfBackground, lfTransparent] then
            begin
              case frmMain.PaintBucketFillSource of
                pbfsForeColor:
                  begin
                    LPaintBucket.Color := Color32(frmMain.GlobalForeColor);
                  end;
                  
                pbfsBackColor:
                  begin
                    LPaintBucket.Color := Color32(frmMain.GlobalBackColor);
                  end;
              end;
            end;
          end;
      end;

      // set filling pattern
      if frmMain.PaintBucketFillSource = pbfsPattern then
      begin
        LPaintBucket.Pattern.Assign(frmPatterns.PaintBucketPattern);
        LPaintBucket.Pattern.PixelFormat := pf24bit;

        if FChannelManager.CurrentChannelType in [
             wctAlpha, wctQuickMask, wctLayerMask] then
        begin
          Desaturate(LPaintBucket.Pattern);
        end;
      end;

      // get the sample bitmap for sampling color
      if frmMain.chckbxFillAllLayers.Checked then
      begin
        LFlattenBmp.SetSize(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
                            FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height);
                           
        imgDrawingArea.PaintTo(LFlattenBmp, LFlattenBmp.ClipRect);

        if Assigned(FSelection) then
        begin
          CopyRect32WithARGB( LSampleBmp, LFlattenBmp,
                              Rect(FSelection.FMaskBorderStart.X, FSelection.FMaskBorderStart.Y,
                                   FSelection.FMaskBorderEnd.X, FSelection.FMaskBorderEnd.Y),
                              Color32(frmMain.GlobalForeColor) );

          SmoothResize32(LSampleBmp, FSelection.CutOriginal.Width, FSelection.CutOriginal.Height);
        end
        else
        begin
          LSampleBmp.Assign(LFlattenBmp);
        end;
      end
      else
      begin
        if Assigned(FSelection) then
        begin
          LSampleBmp.Assign(FSelection.CutOriginal);
        end
        else
        begin
          case FChannelManager.CurrentChannelType of
            wctAlpha:
              begin
                LSampleBmp.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
              end;
              
            wctQuickMask:
              begin
                LSampleBmp.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
              end;
              
            wctLayerMask:
              begin
                LSampleBmp.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
              end;

            wctRGB, wctRed, wctGreen, wctBlue:
              begin
                LSampleBmp.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

                if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                begin
                  ReplaceAlphaChannelWithMask(LSampleBmp,
                    FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                end;
              end;
          end;
        end;
      end;

      // execute filling
      if Assigned(FSelection) then
      begin
        LPaintBucket.Paint(LSampleBmp, FSelection.CutOriginal, FMarqueeX, FMarqueeY);
        ShowProcessedSelection;
        UpdateThumbnailsBySelectedChannel;

        // for Undo/Redo
        frmMain.FAfterProc.Assign(FSelection.CutOriginal);
      end
      else
      begin
        case FChannelManager.CurrentChannelType of
          wctAlpha:
            begin
              LPaintBucket.Paint(LSampleBmp,
                FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                FXActual, FYActual);

              FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
              FChannelManager.SelectedAlphaChannelPanel.UpdateThumbnail;

              // for Undo/Redo
              frmMain.FAfterProc.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
            end;

          wctQuickMask:
            begin
              LPaintBucket.Paint(LSampleBmp,
                FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                FXActual, FYActual);

              FChannelManager.QuickMaskPanel.AlphaLayer.Changed;
              FChannelManager.QuickMaskPanel.UpdateThumbnail;

              // for Undo/Redo
              frmMain.FAfterProc.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
            end;

          wctLayerMask:
            begin
              LPaintBucket.Paint(LSampleBmp,
                                 FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                                 FXActual, FYActual);

              if Assigned(FChannelManager.LayerMaskPanel) then
              begin
                FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(0, 0,
                  FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
                  
                FChannelManager.LayerMaskPanel.UpdateThumbnail;
              end;

              FLayerPanelList.SelectedLayerPanel.Update;
              FLayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
              FLayerPanelList.SelectedLayerPanel.UpdateMaskThumbnail;

              FChannelManager.UpdateColorChannelThumbnails(FLayerPanelList);

              // for Undo/Redo
              frmMain.FAfterProc.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
            end;

          wctRGB, wctRed, wctGreen, wctBlue:
            begin
              if (FLayerPanelList.SelectedLayerPanel.IsMaskLinked) and
                 (FLayerPanelList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent]) then
              begin
                ReplaceAlphaChannelWithMask(
                  FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                  FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
              end;

              LPaintBucket.Paint(LSampleBmp,
                FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                FXActual, FYActual);

              // for Undo/Redo
              frmMain.FAfterProc.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

              FLayerPanelList.SelectedLayerPanel.Update;
              FLayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
              FChannelManager.UpdateColorChannelThumbnails(FLayerPanelList);
            end;
        end;
      end;
      
    finally
      LPaintBucket.Free;
      LFlattenBmp.Free;
      LSampleBmp.Free;
    end;

{ create Undo/Redo for brushes }

    LCmdAim := GetCommandAimByCurrentChannel;

    LHistoryStatePanel := TgmImageManipulatingStatePanel.Create(
      frmHistory.scrlbxHistory,
      dmHistory.bmp32lstHistory.Bitmap[PAINT_BUCKET_COMMAND_ICON_INDEX],
      LCmdAim,
      'Paint Bucket',
      frmMain.FBeforeProc,
      frmMain.FAfterProc,
      FSelection,
      FChannelManager.SelectedAlphaChannelIndex);

    if Assigned(LHistoryStatePanel) then
    begin
      FHistoryManager.AddHistoryState(LHistoryStatePanel);
    end;
  end;
end; 

procedure TfrmChild.EraserToolsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  r, g, b      : Integer;
  LFlattenBmp  : TBitmap32;
  LSampleBmp   : TBitmap32;
  LTempBmp     : TBitmap32;
  LEraser      : TgmEraser;
  LEraserName  : string;
  LBackEraser  : TgmBackgroundEraser;
  LPaintBucket : TgmPaintBucket;
  LBrushArea   : TRect;
begin
  CalcLayerCoord(X, Y);  // get layer space coordinates

{ Mouse left button down }

  if Button = mbLeft then
  begin
    // showing the coordinates of starting point
    frmMain.ShowOriginalCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
    frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);

    if not Assigned(frmMain.GMEraser) then
    begin
      Exit;
    end;

    if FChannelManager.CurrentChannelType = wctAlpha then
    begin
      if not Assigned(FChannelManager.SelectedAlphaChannelPanel) then
      begin
        MessageDlg('Could not process more than one alpha channels at a time.', mtError, [mbOK], 0);
        Exit;
      end;
    end;

    if (FChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue]) then
    begin
      if not (FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                lfBackground, lfTransparent]) then
      begin
        LEraserName := frmMain.GMEraser.Name;

        MessageDlg('Could not use the ' + LEraserName + ' because the' + #10#13 +
                   'content of the layer is not directly' + #10#13 +
                   'editable.', mtError, [mbOK], 0);
        Exit;
      end;
    end;

    if imgDrawingArea.RepaintMode <> rmOptimizer then
    begin
      imgDrawingArea.RepaintMode := rmOptimizer;
    end;

    // don't draw dynamic Marching-Ants lines when processing image
    if tmrMarchingAnts.Enabled then
    begin
      tmrMarchingAnts.Enabled := False;
    end;

    if Assigned(FSelection) then
    begin
      // confirm the foreground of the selection to avoid the distortion of the brush stroke
      FSelection.ConfirmForeground;

      CalcSelectionCoord;    // get selection space coordinates
      RemoveMarchingAnts;
      DrawMarchingAnts;

      Felozox          := FMarqueeX;
      Felozoy          := FMarqueeY;
      FPrevStrokePoint := Point(FMarqueeX, FMarqueeY)
    end
    else
    begin
      Felozox          := FXActual;
      Felozoy          := FYActual;
      FPrevStrokePoint := Point(FXActual, FYActual);
    end;

    if Assigned(FSelectionHandleLayer) then
    begin
      if FSelectionHandleLayer.Visible then
      begin
        FSelectionHandleLayer.Visible := False;
      end;
    end;

    // remember bitmap for create Undo/Redo command
    if Assigned(FSelection) then
    begin
      frmMain.FBeforeProc.Assign(FSelection.CutOriginal);
    end
    else
    begin
      case FChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            frmMain.FBeforeProc.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
          end;
          
        wctQuickMask:
          begin
            frmMain.FBeforeProc.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
          end;

        wctLayerMask:
          begin
            frmMain.FBeforeProc.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            frmMain.FBeforeProc.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

            if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
            begin
              ReplaceAlphaChannelWithMask(frmMain.FBeforeProc,
                FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
            end;
          end;
      end;
    end;

    frmMain.FBeforeProc.DrawMode := dmBlend;

    Ftavolsag := 0; // For EraserLine function

    frmMain.GMEraser.IsPreserveTransparency :=
      FLayerPanelList.SelectedLayerPanel.IsLockTransparency;

    case frmMain.EraserTool of
      etEraser:
        begin
          tmrSpecialBrush.Enabled := False;

          if (frmMain.GMEraser.BrushID = bidEraser) and
             Assigned(frmPaintingBrush.EraserStroke) then
          begin
            LEraser                  := TgmEraser(frmMain.GMEraser);
            LEraser.IsEraseToHistory := frmEraserAdvancedOptions.chckbxEraserHistory.Checked;

            if frmEraserAdvancedOptions.chckbxEraserHistory.Checked then
            begin
              LEraser.SetHistoryBitmap(FHistoryBitmap);
            end;

            LEraser.SetErasingMode(frmMain.ErasingMode);
            LEraser.SetAirErasingPressure(frmMain.AirErasingPressure);

            LEraser.SetBrushOpacity(frmMain.ErasingOpacity);
            LEraser.SetPaintingStroke(frmPaintingBrush.EraserStroke);

            // set eraser color
            if FChannelManager.CurrentChannelType in [wctAlpha, wctQuickMask, wctLayerMask] then
            begin
              LEraser.SetErasingColor( Color32(frmMain.BackGrayColor) );
            end
            else
            begin
              LEraser.SetErasingColor( Color32(frmMain.GlobalBackColor) );
            end;
            
            { Brush Dynamics Settings }
            LEraser.OriginalPressure := frmMain.AirErasingPressure;

            LEraser.SetDynamicSize(frmPaintingBrush.EraserStroke,
                                   frmBrushDynamics.SizeDynamicsState,
                                   frmBrushDynamics.SizeSteps);

            LEraser.SetDynamicOpacity(frmMain.ErasingOpacity,
                                      frmBrushDynamics.OpacityDynamicsState,
                                      frmBrushDynamics.OpacitySteps );

            if (FChannelManager.CurrentChannelType in [
                  wctAlpha, wctQuickMask, wctLayerMask]) then
            begin
              { set the preserve transparency of eraser to True to let the
                eraser to draw color }

              LEraser.IsPreserveTransparency := True;

              // do not erase to history state
              if frmEraserAdvancedOptions.chckbxEraserHistory.Checked then
              begin
                LEraser.IsEraseToHistory := False;
              end;
            end
            else
            begin
              { If currently work with layer, and the color channels are not
                fully selected, that is, red, green and blue channel are not all
                in selection, then we set the perserve transparency of eraser to
                True to let it draw background color to the destination, not
                drawing transparent pixels on destination. }

              if not FChannelManager.IsSelectedAllColorChannels then
              begin
                LEraser.IsPreserveTransparency := True;
              end;
            end;

            if Assigned(FSelection) then
            begin
              with LEraser do
              begin
                if (FChannelManager.CurrentChannelType in [wctAlpha, wctQuickMask, wctLayerMask]) then
                begin
                  if frmEraserAdvancedOptions.chckbxEraserHistory.Checked then
                  begin
                    IsEraseToHistory := False;
                  end;
                end;

                // setting the history sample offset
                SelectionOffsetX := FSelection.FMaskBorderStart.X;
                SelectionOffsetY := FSelection.FMaskBorderStart.Y;

                UpdateSourceBitmap(FSelection.CutOriginal);

                Paint(FSelection.CutOriginal, FMarqueeX, FMarqueeY,
                      FChannelManager.ChannelSelectedSet);
              end;

              { Mark the alpha channel of the selection forground is changed,
                so the selection will use its background to refresh the view
                before drawing foreground. }
              if not FSelection.IsForeAlphaChanged then
              begin
                FSelection.IsForeAlphaChanged := True;
              end;

              LBrushArea := LEraser.GetBrushArea(FMarqueeX, FMarqueeY);
              ShowSelectionAtBrushStroke(LBrushArea);
            end
            else
            begin
              case FChannelManager.CurrentChannelType of
                wctAlpha:
                  begin
                    LEraser.UpdateSourceBitmap(
                      FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);

                    LEraser.Paint(
                      FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    // get refresh area
                    LBrushArea             := LEraser.GetBrushArea(FXActual, FYActual);
                    LBrushArea.TopLeft     := imgDrawingArea.BitmapToControl(LBrushArea.TopLeft);
                    LBrushArea.BottomRight := imgDrawingArea.BitmapToControl(LBrushArea.BottomRight);

                    FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed(LBrushArea);
                  end;

                wctQuickMask:
                  begin
                    LEraser.UpdateSourceBitmap(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);

                    LEraser.Paint(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                                  FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    // get refresh area
                    LBrushArea             := LEraser.GetBrushArea(FXActual, FYActual);
                    LBrushArea.TopLeft     := imgDrawingArea.BitmapToControl(LBrushArea.TopLeft);
                    LBrushArea.BottomRight := imgDrawingArea.BitmapToControl(LBrushArea.BottomRight);

                    FChannelManager.QuickMaskPanel.AlphaLayer.Changed(LBrushArea);
                  end;

                wctLayerMask:
                  begin
                    LEraser.UpdateSourceBitmap(
                      FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);

                    LEraser.Paint(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                                  FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    // paint on mask channel preview layer, too
                    if Assigned(FChannelManager.LayerMaskPanel) then
                    begin
                      LEraser.Paint(FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap,
                                    FXActual, FYActual, FChannelManager.ChannelSelectedSet);
                    end;

                    // get refresh area
                    LBrushArea := LEraser.GetBrushArea(FXActual, FYActual);

                    if not FLayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
                    begin
                      ApplyMask(LBrushArea);
                    end
                    else
                    begin
                      // on special layers, we need save the new mask into its alpha channels
                      FLayerPanelList.SelectedLayerPanel.UpdateLayerAlphaWithMask(LBrushArea);

                      // convert from bitmap coordinate space to image coordinates space
                      LBrushArea.TopLeft     := imgDrawingArea.BitmapToControl(LBrushArea.TopLeft);
                      LBrushArea.BottomRight := imgDrawingArea.BitmapToControl(LBrushArea.BottomRight);

                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(LBrushArea);
                    end;
                  end;

                wctRGB, wctRed, wctGreen, wctBlue:
                  begin
                    // must be on layer
                    if frmEraserAdvancedOptions.chckbxEraserHistory.Checked then
                    begin
                      if (FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width  <> FHistoryBitmap.Width) or
                         (FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height <> FHistoryBitmap.Height) then
                      begin
                        MessageDlg('Could not to erase to the history state because the current' + #10#13 +
                                   'canvas size does not match that of the history state!', mtError, [mbOK], 0);

                        Exit;
                      end;
                    end;

                    LTempBmp := TBitmap32.Create;
                    try
                      LTempBmp.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

                      if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                      begin
                        ReplaceAlphaChannelWithMask(LTempBmp,
                          FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                      end;

                      LEraser.UpdateSourceBitmap(LTempBmp);
                    finally
                      LTempBmp.Free;
                    end;

                    // get refresh area
                    LBrushArea := LEraser.GetBrushArea(FXActual, FYActual);

                    if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                    begin
                      ReplaceAlphaChannelWithMask(
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                        FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                        LBrushArea);
                    end;

                    LEraser.Paint(
                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                      FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                    if FLayerPanelList.SelectedLayerPanel.IsHasMask then
                    begin
                      GetAlphaChannelBitmap(
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                        FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                        LBrushArea);

                      ApplyMask(LBrushArea);
                    end
                    else
                    begin
                      // from bitmap coordinate space to control coordinate space
                      LBrushArea.TopLeft     := imgDrawingArea.BitmapToControl(LBrushArea.TopLeft);
                      LBrushArea.BottomRight := imgDrawingArea.BitmapToControl(LBrushArea.BottomRight);

                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(LBrushArea);
                    end;
                  end;
              end;
            end;

            if frmMain.ErasingMode = emAirBrush then
            begin
              tmrSpecialBrush.Interval := frmMain.AirErasingInterval;

              if tmrSpecialBrush.Enabled <> True then
              begin
                tmrSpecialBrush.Enabled := True;
              end;
            end;
          end;
        end;

      etBackgroundEraser:
        begin
          case FChannelManager.CurrentChannelType of
            wctAlpha, wctQuickMask:
              begin
                MessageDlg('Could not use the background eraser because' + #10#13 +
                           'it does not work with alpha channels.', mtError, [mbOK], 0);

                if Assigned(FSelection) then
                begin
                  tmrMarchingAnts.Enabled := True;
                end;
                
                Exit;
              end;

            wctLayerMask:
              begin
                MessageDlg('Could not use the background eraser because' + #10#13 +
                           'the target channels do not cover the' + #10#13 +
                           'composite.', mtError, [mbOK], 0);

                if Assigned(FSelection) then
                begin
                  tmrMarchingAnts.Enabled := True;
                end;

                Exit;
              end;

            wctRGB, wctRed, wctGreen, wctBlue:
              begin
                // must be on layer

                if not FChannelManager.IsSelectedAllColorChannels then
                begin
                  MessageDlg('Could not use the background eraser because' + #10#13 +
                             'the target channels do not cover the' + #10#13 +
                             'composite.', mtError, [mbOK], 0);

                  if Assigned(FSelection) then
                  begin
                    tmrMarchingAnts.Enabled := True;
                  end;
                  
                  Exit;
                end;

                if not (FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                          lfBackground, lfTransparent]) then
                begin
                  MessageDlg('Could not use the background eraser because' + #10#13 +
                             'the content of the layer is not directly' + #10#13 +
                             'editable.', mtError, [mbOK], 0);

                  if Assigned(FSelection) then
                  begin
                    tmrMarchingAnts.Enabled := True;
                  end;
                  
                  Exit;
                end;

                tmrSpecialBrush.Enabled := False;

                if Assigned(frmMain.GMEraser) and
                   (frmMain.GMEraser.BrushID = bidBackgroundEraser) then
                begin
                  if Assigned(frmPaintingBrush.EraserStroke) then
                  begin
                    LBackEraser := TgmBackgroundEraser(frmMain.GMEraser);

                    with LBackEraser do
                    begin
                      IsProtectedForeground := frmEraserAdvancedOptions.chckbxProtectForeground.Checked;
                      ProtectedColor        := Color32(frmMain.GlobalForeColor);

                      SetSamplingMode(frmMain.EraserSamplingMode);
                      SetErasingLimit(frmMain.BackgroundEraserLimit);
                      SetTolerance(frmMain.ErasingTolerance);
                    end;

                    if frmMain.EraserSamplingMode = bsmBackgroundSwatch then
                    begin
                      LBackEraser.SampledColor := Color32(frmMain.GlobalBackColor);
                    end;

                    frmMain.GMEraser.SetPaintingStroke(frmPaintingBrush.EraserStroke);

                    { Brush Dynamics Settings }
                    LBackEraser.OriginalTolerance := frmMain.ErasingTolerance;

                    frmMain.GMEraser.SetDynamicSize(frmPaintingBrush.EraserStroke,
                                                    frmBrushDynamics.SizeDynamicsState,
                                                    frmBrushDynamics.SizeSteps);

                    frmMain.GMEraser.SetDynamicOpacity(frmMain.ErasingTolerance,
                                                       frmBrushDynamics.OpacityDynamicsState,
                                                       frmBrushDynamics.OpacitySteps );

                    if Assigned(FSelection) then
                    begin
                      frmMain.GMEraser.UpdateSourceBitmap(FSelection.CutOriginal);

                      if frmMain.EraserSamplingMode in [bsmContiguous, bsmOnce] then
                      begin
                        LBackEraser.SamplingColor(FMarqueeX, FMarqueeY);
                      end;

                      frmMain.GMEraser.Paint(
                        FSelection.CutOriginal, FMarqueeX, FMarqueeY,
                        FChannelManager.ChannelSelectedSet);

                      LBrushArea := frmMain.GMEraser.GetBrushArea(FMarqueeX, FMarqueeY);

                      { Mark the alpha channel of the selection forground is changed,
                        so the selection will use its background to refresh the view
                        before drawing foreground. }
                      if not FSelection.IsForeAlphaChanged then
                      begin
                        FSelection.IsForeAlphaChanged := True;
                      end;
                      
                      ShowSelectionAtBrushStroke(LBrushArea);
                    end
                    else
                    begin
                      LTempBmp := TBitmap32.Create;
                      try
                        LTempBmp.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

                        if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                        begin
                          ReplaceAlphaChannelWithMask(LTempBmp,
                            FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                        end;

                        frmMain.GMEraser.UpdateSourceBitmap(LTempBmp);
                      finally
                        LTempBmp.Free;
                      end;

                      if frmMain.EraserSamplingMode in [bsmContiguous, bsmOnce] then
                      begin
                        LBackEraser.SamplingColor(FXActual, FYActual);
                      end;

                      // get refresh area
                      LBrushArea := frmMain.GMEraser.GetBrushArea(FXActual, FYActual);

                      if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                      begin
                        ReplaceAlphaChannelWithMask(
                          FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                          FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                          LBrushArea);
                      end;

                      frmMain.GMEraser.Paint(
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                        FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                      if FLayerPanelList.SelectedLayerPanel.IsHasMask then
                      begin
                        GetAlphaChannelBitmap(
                          FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                          FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                          LBrushArea);

                        ApplyMask(LBrushArea);
                      end
                      else
                      begin
                        // from bitmap coordinate space to control coordinate space
                        LBrushArea.TopLeft     := imgDrawingArea.BitmapToControl(LBrushArea.TopLeft);
                        LBrushArea.BottomRight := imgDrawingArea.BitmapToControl(LBrushArea.BottomRight);

                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(LBrushArea);
                      end;
                    end;

                    if frmMain.EraserSamplingMode in [bsmContiguous, bsmOnce] then
                    begin
                      frmColor.CurrColorSelector := csBackColor;

                      r := LBackEraser.SampledColor shr 16 and $FF;
                      g := LBackEraser.SampledColor shr  8 and $FF;
                      b := LBackEraser.SampledColor        and $FF;

                      frmColor.ChangeColorViaTrackBar(r, g, b);
                    end;

                    if frmMain.BackgroundEraserLimit = belDiscontiguous then
                    begin
                      tmrSpecialBrush.Interval := frmMain.AirErasingInterval;

                      if tmrSpecialBrush.Enabled <> True then
                      begin
                        tmrSpecialBrush.Enabled := True;
                      end;
                    end;
                  end;
                end;
              end;
          end;
        end;

      etMagicEraser:
        begin
          case FChannelManager.CurrentChannelType of
            wctAlpha, wctQuickMask:
              begin
                MessageDlg('Could not use the background eraser because' + #10#13 +
                           'it does not work with alpha channels.', mtError, [mbOK], 0);

                if Assigned(FSelection) then
                begin
                  tmrMarchingAnts.Enabled := True;
                end;

                Exit;
              end;

            wctLayerMask:
              begin
                MessageDlg('Could not use the magic eraser because the ' + #10#13 +
                           'target channels do not cover the composite.', mtError, [mbOK], 0);

                if Assigned(FSelection) then
                begin
                  tmrMarchingAnts.Enabled := True;
                end;

                Exit;
              end;

            wctRGB, wctRed, wctGreen, wctBlue:
              begin
                // must be on layer

                if not FChannelManager.IsSelectedAllColorChannels then
                begin
                  MessageDlg('Could not use the magic eraser because the ' + #10#13 +
                             'target channels do not cover the composite.', mtError, [mbOK], 0);

                  if Assigned(FSelection) then
                  begin
                    tmrMarchingAnts.Enabled := True;
                  end;

                  Exit;
                end;

                if not (FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                          lfBackground, lfTransparent]) then
                begin
                  MessageDlg('Could not use the magic eraser because' + #10#13 +
                             'the content of the layer is not directly' + #10#13 +
                             'editable.', mtError, [mbOK], 0);

                  if Assigned(FSelection) then
                  begin
                    tmrMarchingAnts.Enabled := True;
                  end;

                  Exit;
                end;

                // the RepaintMode should be set to rmFull
                if imgDrawingArea.RepaintMode <> rmFull then
                begin
                  imgDrawingArea.RepaintMode := rmFull;
                end;

                LSampleBmp   := TBitmap32.Create;
                LFlattenBmp  := TBitmap32.Create;
                LPaintBucket := TgmPaintBucket.Create;
                try
                  LSampleBmp.DrawMode  := dmBlend;
                  LFlattenBmp.DrawMode := dmBlend;

                  LPaintBucket.Color                := Color32(frmMain.GlobalBackColor);
                  LPaintBucket.Tolerance            := MulDiv(255, frmMain.ErasingTolerance, 100);
                  LPaintBucket.Opacity              := MulDiv(255, frmMain.ErasingOpacity, 100);
                  LPaintBucket.BlendMode            := bbmNormal32;
                  LPaintBucket.PreserveTransparency := frmLayer.chckbxLockTransparency.Checked;

                  if frmMain.chckbxFillContiguous.Checked then
                  begin
                    LPaintBucket.FillCondition := pbfcContiguous;
                  end
                  else
                  begin
                    LPaintBucket.FillCondition := pbfcDiscontiguous;
                  end;

                  if FLayerPanelList.SelectedLayerPanel.IsLockTransparency then
                  begin
                    LPaintBucket.FillSource := pbfsBackColor;
                  end
                  else
                  begin
                    LPaintBucket.FillSource := pbfsTransparent;
                  end;

                  if frmEraserAdvancedOptions.chckbxUseAllLayers.Checked then
                  begin
                    FLayerPanelList.FlattenLayersToBitmapWithoutMask(LFlattenBmp, dmBlend);

                    if Assigned(FSelection) then
                    begin
                      CopyRect32WithARGB( LSampleBmp, LFlattenBmp,
                                          Rect(FSelection.FMaskBorderStart.X,
                                               FSelection.FMaskBorderStart.Y,
                                               FSelection.FMaskBorderEnd.X,
                                               fSelection.FMaskBorderEnd.Y),
                                          Color32(frmMain.GlobalBackColor) );

                      SmoothResize32(LSampleBmp,
                                     FSelection.CutOriginal.Width,
                                     FSelection.CutOriginal.Height);
                    end
                    else
                    begin
                      LSampleBmp.Assign(LFlattenBmp);
                    end;
                  end
                  else
                  begin
                    if Assigned(FSelection) then
                    begin
                      LSampleBmp.Assign(FSelection.CutOriginal);
                    end
                    else
                    begin
                      LSampleBmp.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

                      if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                      begin
                        ReplaceAlphaChannelWithMask(LSampleBmp,
                          FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                      end;
                    end;
                  end;

                  // execute filling
                  if Assigned(FSelection) then
                  begin
                    LPaintBucket.Paint(LSampleBmp, FSelection.CutOriginal,
                                       FMarqueeX, FMarqueeY);

                    // mark the alpha channel of selection foreground is changed
                    if not FSelection.IsForeAlphaChanged then
                    begin
                      FSelection.IsForeAlphaChanged := True;
                    end;

                    ShowProcessedSelection;
                  end
                  else
                  begin
                    if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                    begin
                      ReplaceAlphaChannelWithMask(
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                        FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                    end;

                    LPaintBucket.Paint(LSampleBmp,
                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                      FXActual, FYActual);

                    GetAlphaChannelBitmap(
                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                      FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);

                    FLayerPanelList.SelectedLayerPanel.Update;
                  end;

                finally
                  LPaintBucket.Free;
                  LSampleBmp.Free;
                  LFlattenBmp.Free;
                end;
              end;
          end;
        end;
    end;

    FImageProcessed := True;  // mark the image has been modified
    FDrawing        := True;
  end;
end; 

procedure TfrmChild.EraserToolsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
var
  Red, Green, Blue: Byte;
  Interval        : Integer;
  AColor          : TColor;
  BackEraser      : TgmBackgroundEraser;
  BrushArea       : TRect;
  LastStrokeArea  : TRect;
begin
  CalcLayerCoord(X, Y);  // get layer space coordinates
  CalcSelectionCoord;    // get selection space coordinates

{ Move mouse when mouse left button down }

  if FDrawing then
  begin
    case frmMain.EraserTool of
      etEraser:
        begin
          case frmMain.ErasingMode of
            emPaintBrush:
              begin
                Interval := frmMain.ErasingInterval;
              end;

            emAirBrush:
              begin
                Interval := 0;
              end;
              
          else
            Interval := 0;
          end;

          if Assigned(FSelection) then
          begin
            EraserLine(FPrevStrokePoint.X, FPrevStrokePoint.Y, FMarqueeX, FMarqueeY,
                       Interval, FSelection.CutOriginal, FChannelManager.ChannelSelectedSet);

            // get brush area
            LastStrokeArea := frmMain.GMEraser.GetBrushArea(FPrevStrokePoint.X, FPrevStrokePoint.Y);
            BrushArea      := frmMain.GMEraser.GetBrushArea(FMarqueeX, FMarqueeY);
            BrushArea      := AddRects(LastStrokeArea, BrushArea);
    
            ShowSelectionAtBrushStroke(BrushArea);
            FPrevStrokePoint := Point(FMarqueeX, FMarqueeY);
          end
          else
          begin
            case FChannelManager.CurrentChannelType of
              wctAlpha:
                begin
                  EraserLine(FPrevStrokePoint.X, FPrevStrokePoint.Y, FXActual, FYActual,
                             Interval, FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                             FChannelManager.ChannelSelectedSet);

                  // get refresh area
                  LastStrokeArea        := frmMain.GMEraser.GetBrushArea(FPrevStrokePoint.X, FPrevStrokePoint.Y);
                  BrushArea             := frmMain.GMEraser.GetBrushArea(FXActual, FYActual);
                  BrushArea             := AddRects(LastStrokeArea, BrushArea);
                  BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                  BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                  FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed(BrushArea);
                end;

              wctQuickMask:
                begin
                  EraserLine(FPrevStrokePoint.X, FPrevStrokePoint.Y, FXActual, FYActual,
                             Interval, FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                             FChannelManager.ChannelSelectedSet);

                  // get refresh area
                  LastStrokeArea        := frmMain.GMEraser.GetBrushArea(FPrevStrokePoint.X, FPrevStrokePoint.Y);
                  BrushArea             := frmMain.GMEraser.GetBrushArea(FXActual, FYActual);
                  BrushArea             := AddRects(LastStrokeArea, BrushArea);
                  BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                  BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                  FChannelManager.QuickMaskPanel.AlphaLayer.Changed(BrushArea);
                end;

              wctLayerMask:
                begin
                  { EraserLineOnMask() will paint eraser stroke both on
                    FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap and
                    FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.

                    And the function will also save the new Mask into the
                    alpha channels of special layers. }

                  EraserLineOnMask(FPrevStrokePoint.X, FPrevStrokePoint.Y, FXActual, FYActual,
                                   Interval, FChannelManager.ChannelSelectedSet);

                  // get brush area
                  LastStrokeArea := frmMain.GMEraser.GetBrushArea(FPrevStrokePoint.X, FPrevStrokePoint.Y);
                  BrushArea      := frmMain.GMEraser.GetBrushArea(FXActual, FYActual);
                  BrushArea      := AddRects(LastStrokeArea, BrushArea);

                  if not FLayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
                  begin
                    ApplyMask(BrushArea);
                  end
                  else
                  begin
                    // convert from bitmap coordinate space to control coordinate space
                    BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                    BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);
                    FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                  end;
                end;

              wctRGB, wctRed, wctGreen, wctBlue:
                begin
                  // must be on layer

                  // get refresh area
                  LastStrokeArea := frmMain.GMEraser.GetBrushArea(FPrevStrokePoint.X, FPrevStrokePoint.Y);
                  BrushArea      := frmMain.GMEraser.GetBrushArea(FXActual, FYActual);
                  BrushArea      := AddRects(LastStrokeArea, BrushArea);

                  // restore the alpha channel to the state that before applied mask
                  if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                  begin
                    ReplaceAlphaChannelWithMask(
                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                      FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                      BrushArea);
                  end;

                  EraserLine(
                    FPrevStrokePoint.X, FPrevStrokePoint.Y, FXActual, FYActual,
                    Interval, FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                    FChannelManager.ChannelSelectedSet);

                  if FLayerPanelList.SelectedLayerPanel.IsHasMask then
                  begin
                    GetAlphaChannelBitmap(
                      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                      FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                      BrushArea);
                      
                    ApplyMask(BrushArea);
                  end
                  else
                  begin
                    // from bitmap coordinate space to control coordinate space
                    BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                    BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                    FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                  end;
                end;
            end;

            FPrevStrokePoint := Point(FXActual, FYActual);
          end;
        end;

      etBackgroundEraser:
        begin
          if Assigned(frmMain.GMBrush) and
             (frmMain.GMEraser.BrushID = bidBackgroundEraser) then
          begin
            if Assigned(frmPaintingBrush.EraserStroke) then
            begin
              BackEraser := TgmBackgroundEraser(frmMain.GMEraser);

              if Assigned(FSelection) then
              begin
                // Sampling Color
                if frmMain.EraserSamplingMode = bsmContiguous then
                begin
                  BackEraser.SamplingColor(FMarqueeX, FMarqueeY);
                end;

                case frmMain.BackgroundEraserLimit of
                  belDiscontiguous:
                    begin
                      EraserLine(FPrevStrokePoint.X, FPrevStrokePoint.Y,
                                 FMarqueeX, FMarqueeY, 0,
                                 FSelection.CutOriginal,
                                 FChannelManager.ChannelSelectedSet);
                    end;

                  belContiguous:
                    begin
                      EraserLine(FPrevStrokePoint.X, FPrevStrokePoint.Y,
                                 FMarqueeX, FMarqueeY,
                                 frmMain.ErasingInterval,
                                 FSelection.CutOriginal,
                                 FChannelManager.ChannelSelectedSet);
                    end;
                end;

                // get brush area
                LastStrokeArea := BackEraser.GetBrushArea(FPrevStrokePoint.X, FPrevStrokePoint.Y);
                BrushArea      := BackEraser.GetBrushArea(FMarqueeX, FMarqueeY);
                BrushArea      := AddRects(LastStrokeArea, BrushArea);
    
                ShowSelectionAtBrushStroke(BrushArea);
                FPrevStrokePoint := Point(FMarqueeX, FMarqueeY);
              end
              else
              begin
                // on normal layers...

                // get refresh area
                LastStrokeArea := frmMain.GMEraser.GetBrushArea(FPrevStrokePoint.X, FPrevStrokePoint.Y);
                BrushArea      := frmMain.GMEraser.GetBrushArea(FXActual, FYActual);
                BrushArea      := AddRects(LastStrokeArea, BrushArea);

                // restore the alpha channel to the state that before applied mask
                if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                begin
                  ReplaceAlphaChannelWithMask(
                    FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                    FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                    BrushArea);
                end;

                // Sampling Color
                if frmMain.EraserSamplingMode = bsmContiguous then
                begin
                  BackEraser.SamplingColor(FXActual, FYActual);
                end;

                case frmMain.BackgroundEraserLimit of
                  belDiscontiguous:
                    begin
                      EraserLine(
                        FPrevStrokePoint.X, FPrevStrokePoint.Y,
                        FXActual, FYActual, 0,
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                        FChannelManager.ChannelSelectedSet);
                    end;

                  belContiguous:
                    begin
                      EraserLine(
                        FPrevStrokePoint.X, FPrevStrokePoint.Y,
                        FXActual, FYActual, frmMain.ErasingInterval,
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                        FChannelManager.ChannelSelectedSet);
                    end;
                end;

                if FLayerPanelList.SelectedLayerPanel.IsHasMask then
                begin
                  GetAlphaChannelBitmap(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                                        FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                                        BrushArea);
                  ApplyMask(BrushArea);
                end
                else
                begin
                  // from bitmap coordinate space to control coordinate space
                  BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                  BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                  FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                end;

                FPrevStrokePoint := Point(FXActual, FYActual);
              end;

              // show sampling color
              if frmMain.EraserSamplingMode = bsmContiguous then
              begin
                Red   := BackEraser.SampledColor shr 16 and $FF;
                Green := BackEraser.SampledColor shr  8 and $FF;
                Blue  := BackEraser.SampledColor        and $FF;

                frmColor.ChangeColorViaTrackBar(Red, Green, Blue);
              end;
            end;
          end;
        end;
    end;
  end
  else // if the FDrawing = False
  begin
    if  (FXActual >= 0) and (FXActual <= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width)
    and (FYActual >= 0) and (FYActual <= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height) then
    begin
      AColor := imgDrawingArea.Canvas.Pixels[X, Y];
      frmMain.ShowColorRGBInfoOnInfoViewer(AColor);
      frmMain.ShowColorCMYKInfoOnInfoViewer(AColor);
    end;
  end;

  frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
end;

procedure TfrmChild.EraserToolsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  LCmdName          : string;
  LCmdAim           : TCommandAim;
  LHistoryStatePanel: TgmHistoryStatePanel;
  LCommandIconIndex : Integer;
begin
  if imgDrawingArea.RepaintMode <> rmFull then
  begin
    imgDrawingArea.RepaintMode := rmFull;
  end;

  CalcLayerCoord(X, Y);  // get layer space coordinates
  CalcSelectionCoord;    // get selection space coordinates

{ Move mouse when mouse left button down }

  if FDrawing then
  begin
    FDrawing := False;

    if tmrSpecialBrush.Enabled then
    begin
      tmrSpecialBrush.Enabled := False;
    end;

    if Assigned(FSelection) then
    begin
      ShowProcessedSelection;
      tmrMarchingAnts.Enabled := True;

      // for Undo/Redo
      frmMain.FAfterProc.Assign(FSelection.CutOriginal);
    end
    else
    begin
      case FChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
            frmMain.FAfterProc.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
          end;

        wctQuickMask:
          begin
            FChannelManager.QuickMaskPanel.AlphaLayer.Changed;
            frmMain.FAfterProc.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
          end;

        wctLayerMask:
          begin
            FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Changed;

            FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(0, 0,
              FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);

            FLayerPanelList.SelectedLayerPanel.Update;

            // for Undo/Redo
            frmMain.FAfterProc.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            // must be on layer
            FLayerPanelList.SelectedLayerPanel.Update;

            // for Undo/Redo
            frmMain.FAfterProc.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
            
            if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
            begin
              ReplaceAlphaChannelWithMask(frmMain.FAfterProc,
                FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
            end;
          end;
      end;
    end;

    // update thumbnails
    UpdateThumbnailsBySelectedChannel;

    if frmMain.EraserTool = etBackgroundEraser then
    begin
      frmColor.CurrColorSelector := frmColor.LastColorSelector;
    end;

{ Create Undo/Redo for erasers. }

    LCommandIconIndex := 0;

    case frmMain.EraserTool of
      etEraser:
        begin
          LCmdName          := frmMain.GMEraser.Name;
          LCommandIconIndex := ERASER_COMMAND_ICON_INDEX;
        end;

      etBackgroundEraser:
        begin
          LCmdName          := frmMain.GMEraser.Name;
          LCommandIconIndex := BACK_ERASER_COMMAND_ICON_INDEX;
        end;

      etMagicEraser:
        begin
          LCmdName          := 'Magic Eraser';
          LCommandIconIndex := MAGIC_ERASER_COMMAND_ICON_INDEX;
        end;
    end;

    // create Undo/Redo command
    LCmdAim := GetCommandAimByCurrentChannel;

    LHistoryStatePanel := TgmImageManipulatingStatePanel.Create(
      frmHistory.scrlbxHistory,
      dmHistory.bmp32lstHistory.Bitmap[LCommandIconIndex],
      LCmdAim,
      LCmdName,
      frmMain.FBeforeProc,
      frmMain.FAfterProc,
      FSelection,
      FChannelManager.SelectedAlphaChannelIndex);

    if Assigned(LHistoryStatePanel) then
    begin
      FHistoryManager.AddHistoryState(LHistoryStatePanel);
    end;
  end;
end; 

procedure TfrmChild.PenToolsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  LTempSegment      : TgmCurveSegment;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  CalcLayerCoord(X, Y);  // get layer space coordinates

{ Mouse left button down }

  if Button = mbLeft then
  begin
    // showing the coordinates of starting point
    frmMain.ShowOriginalCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
    frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);

    // don't draw dynamic Marching-Ants lines when processing image
    if tmrMarchingAnts.Enabled = True then
    begin
      tmrMarchingAnts.Enabled := False;
    end;

    // if there is no existed path layer then create one
    if FPathLayer = nil then
    begin
      CreatePathLayer;
    end;

    CalcPathLayerCoord(X, Y);  // get path layer space coordinates

    FDrawing        := True;
    FModifyPathMode := mpmNone;

    case frmMain.PenTool of
      ptPathComponentSelection:
        begin
          if Assigned(FPathPanelList.SelectedPanel) then
          begin
            FAccumTranslateVector := Point(0, 0); // Undo/Redo

            FWholePathIndex := FPathPanelList.SelectedPanel.PenPathList.IfPointOnPathsForWholePath(FPathLayerX, FPathLayerY);

            if ssShift in Shift then
            begin
              // if the Shift key is pressed, then select the whole path with the mouse
              if FWholePathIndex > -1 then
              begin
                FPathPanelList.SelectedPanel.PenPathList.SelectWholePathByIndex(FWholePathIndex);
              end;
            end
            else
            begin  // if the Shift key is not pressed...
              { If the mouse is clicked on any path then select it, otherwise,
                deselect all paths. }
              if FWholePathIndex > (-1) then
              begin
                { If the mouse is clicked on am unselected path, then we deselect
                  all paths and only select this path. }
                if not FPathPanelList.SelectedPanel.PenPathList.IfSelectedWholePathByIndex(FWholePathIndex) then
                begin
                  FPathPanelList.SelectedPanel.PenPathList.DeselectAllPaths;
                  FPathPanelList.SelectedPanel.PenPathList.SelectWholePathByIndex(FWholePathIndex);
                end;
              end
              else
              begin
                FPathPanelList.SelectedPanel.PenPathList.DeselectAllPaths;
                FPenPath := nil;
              end;
            end;

            if FWholePathIndex > (- 1) then
            begin
              Screen.Cursor         := crMovePath;
              imgDrawingArea.Cursor := crMovePath;
              FDrawingBasePoint     := Point(FPathLayerX, FPathLayerY);

              RecordOldPathDataForUndoRedo;  // Undo/Redo
            end
            else
            begin
              Screen.Cursor         := crDefault;
              imgDrawingArea.Cursor := crPathComponentSelection;
            end;

            // clear the old paths and draw the new paths
            FPathLayer.Bitmap.Clear($00000000);

            FPathPanelList.SelectedPanel.PenPathList.DrawAllPaths(
              FPathLayer.Bitmap.Canvas, pmNotXor, Point(0, 0) );
              
            FPathLayer.Bitmap.Changed;

            // draw the Marching-Ants lines if the select is existed
            if Assigned(FSelection) then
            begin
              imgDrawingArea.Update;
              DrawMarchingAnts;
            end;
          end;
        end;

      ptDirectSelection:
        begin
          if Assigned(FPathPanelList.SelectedPanel) then
          begin
            FAccumTranslateVector := Point(0, 0); // For Undo/Redo
            RecordOldPathDataForUndoRedo;         // For Undo/Redo

            FPathLayer.Bitmap.Clear($00000000);  // clear the paths
            
            FPenPath := FPathPanelList.SelectedPanel.PenPathList.SelectPath(
              FPathLayerX, FPathLayerY, FPathSelectHandle);

            if Assigned(FPenPath) then
            begin
              // save the original status
              FOriginalPairState    := FPenPath.CurveSegmentsList.GetSelectedSegmentsPairState;
              Screen.Cursor         := GetPenPathCursor(FPathSelectHandle);
              imgDrawingArea.Cursor := Screen.Cursor;
              FDrawingBasePoint     := Point(FPathLayerX, FPathLayerY);
            end;

            // draw the new paths
            FPathPanelList.SelectedPanel.PenPathList.DrawAllPaths(
              FPathLayer.Bitmap.Canvas, pmNotXor, Point(0, 0) );
              
            FPathLayer.Bitmap.Changed;

            // draw the Marching-Ants lines if the select is existed
            if Assigned(FSelection) then
            begin
              imgDrawingArea.Update;
              DrawMarchingAnts;
            end;

            // for Undo/Redo
            if FPathSelectHandle in [pshStart, pshEnd] then
            begin
              FModifyPathMode := mpmDragAnchorPoint;
            end
            else
            if FPathSelectHandle in [pshControl1, pshControl2, pshOpposite1,
                                     pshOpposite2] then
            begin
              FModifyPathMode := mpmDragControlPoint;
            end;
          end;
        end;

      ptPenTool:
        begin
          { If the current selected path is a closed path, and the mouse is not
            clicked on it or the endpoints of it, then set the state of the path
            list to plsAddNewPath for adding a path.  }
          if Assigned(FPenPath) then
          begin
            if Assigned(FPathPanelList.SelectedPanel) then
            begin
              if FPathPanelList.SelectedPanel.PenPathList.PathListState = plsAdjust then
              begin
                if ( FPenPath.CurveSegmentsList.GetSelectedEndingHandle(FPathLayerX, FPathLayerY) = pshNone ) and
                   ( not FPenPath.CurveSegmentsList.NilsIfPointOnBezier(FPathLayerX, FPathLayerY) ) then
                begin
                  FPathPanelList.SelectedPanel.PenPathList.PathListState := plsAddNewPath;
                end;
              end;
            end;
          end;

          { If there is no selected path panel, or the state of the path list is
            plsAddNewPath, then nil the FPenPath field. }
          if (FPathPanelList.SelectedPanel = nil) or
             (FPathPanelList.SelectedPanel.PenPathList.PathListState = plsAddNewPath) then
          begin
            FPenPath := nil;
          end;

          // if FPenPath is nil, the create a new path
          if FPenPath = nil then
          begin
            if Assigned(FPathPanelList.SelectedPanel) then
            begin
              FPathPanelList.SelectedPanel.PenPathList.DeselectAllPaths;
            end;
            
            FPenPath := TgmPenPath.Create;
          end;

          { If the state of the path list is plsAddNewPath, then adding the path
            FPenPath to the list, and set the state of the list to plsAddNextAnchorPoint.}
          if Assigned(FPathPanelList.SelectedPanel) and
             (FPathPanelList.SelectedPanel.PenPathList.PathListState = plsAddNewPath) then
          begin
            RecordOldPathDataForUndoRedo;  // Undo/Redo
            FPathPanelList.SelectedPanel.PenPathList.AddNewPathToList(FPenPath);

            FModifyPathMode := mpmNewPathComponent;
          end;

          FPathLayer.Bitmap.Clear($00000000); // clear the old paths

          with FPenPath.CurveSegmentsList do
          begin
            // if there is no any curve segment in the list...
            if Count = 0 then
            begin
              AddFirstSegment( Point(FPathLayerX, FPathLayerY),
                               Point(FPathLayerX, FPathLayerY),
                               Point(FPathLayerX, FPathLayerY),
                               Point(FPathLayerX, FPathLayerY) );

              imgDrawingArea.Cursor := crMovePath;
            end
            else
            if Count > 0 then
            begin
              if IsFirstSegmentOK = False then
              begin
                { If the Alt key is pressed, and the mouse is pointing on the
                  starting point of the first curve segment, then mark the
                  starting point as the Corner Point. }
                if ssAlt in Shift then
                begin
                  if PointOnFirstSegmentStart(FPathLayerX, FPathLayerY) then
                  begin
                    RecordOldPathDataForUndoRedo; // Undo/Redo
                    CurrentSegment.Opposite1         := CurrentSegment.Control1;
                    CurrentSegment.Control1          := CurrentSegment.StartPoint;
                    CurrentSegment.StartingPointType := eptCornerPoint;

                    // Undo/Redo
                    CreateModifyPathUndoRedoCommand(mpmPickupPath);
                    FDrawing := False;
                  end;
                end
                else
                begin
                  { If the mouse is pointing on the starting point of the first
                    curve segment of the path, then switch the pen tool to
                    Direct Selection tool. }
                  if PointOnFirstSegmentStart(FPathLayerX, FPathLayerY) then
                  begin
                    RecordOldPathDataForUndoRedo; // Undo/Redo
                    FModifyPathMode := mpmPickupPath;

                    CurrentSegment.Control1 := CurrentSegment.StartPoint;
                    FPathSelectHandle       := pshControl1;
                    Screen.Cursor           := crMovePath;
                    imgDrawingArea.Cursor   := crMovePath;
                    FDrawingBasePoint       := Point(FPathLayerX, FPathLayerY);
                    frmMain.PenTool         := ptDirectSelection;
                  end
                  else
                  begin
                    RecordOldPathDataForUndoRedo; // Undo/Redo
                    FModifyPathMode := mpmNewAnchorPoint;

                    // specify that we want to modify the end point of the first curve segment
                    CurrentSegment.ActivePoint := apEnd;
                    IsFirstSegmentOK           := True;

                    { If the Alt key has not been pressed, then we modify the
                      end point, control point 2 and opposite control point 2
                      of the current curve segment. }
                    if CurrentSegment.ActivePoint = apEnd then
                    begin
                      CurrentSegment.Control2  := Point(FPathLayerX, FPathLayerY);
                      CurrentSegment.Opposite2 := Point(FPathLayerX, FPathLayerY);
                      CurrentSegment.EndPoint  := Point(FPathLayerX, FPathLayerY);
                    end;

                    Screen.Cursor         := crMovePath;
                    imgDrawingArea.Cursor := crMovePath;
                  end;
                end;
              end
              else
              begin
                // if the mouse is pointing on any of endpoints of the curve segments...
                if GetSelectedEndingHandle(FPathLayerX, FPathLayerY) <> pshNone then
                begin
                  { If the mouse is pointing on the starting point of the first
                    curve segment of a path, then close the path. }
                  if PointOnFirstSegmentStart(FPathLayerX, FPathLayerY) then
                  begin
                    if FPenPath.CurveSegmentsList.IsClosed then
                    begin
                      { If the Alt is pressed, then convert the endpoint of the
                        curve segment from Anchor Point to Corner Point, and then
                        switch the pen tools to Convert Point tool. }
                      if ssAlt in Shift then
                      begin
                        RecordOldPathDataForUndoRedo; // Undo/Redo
                        FModifyPathMode := mpmChangeAnchorPoint;

                        FPenPath := FPathPanelList.SelectedPanel.PenPathList.SelectPath(
                          FPathLayerX, FPathLayerY, FPathSelectHandle);

                        FPenPath.CurveSegmentsList.ConvertPoint(
                          FPathLayerX, FPathLayerY, coAnchorToCorner);

                        FMouseDownX            := FPathLayerX;
                        FMouseDownY            := FPathLayerY;
                        Screen.Cursor          := crMovePath;
                        imgDrawingArea.Cursor  := crMovePath;
                        FDrawingBasePoint      := Point(FPathLayerX, FPathLayerY);
                        frmMain.PenTool        := ptConvertPoint;
                      end
                      else
                      begin
                        RecordOldPathDataForUndoRedo; // Undo/Redo
                        FModifyPathMode := mpmDeleteAnchorPoint;

                        // if the Alt key is pressed then delete the anchor point
                        DeleteAnchorPointOnSegment(FPathLayerX, FPathLayerY);

                        Screen.Cursor         := crDefault;
                        imgDrawingArea.Cursor := GetPenToolDefaultCursor;
                      end;
                    end
                    else
                    begin
                      RecordOldPathDataForUndoRedo;  // Undo/Redo
                      ClosePath;
                      FPenPath := nil;
                      FPathPanelList.SelectedPanel.PenPathList.PathListState := plsAddNewPath;

                      FPathLayer.Bitmap.Clear($00000000); // clear the old paths

                      if Assigned(FSelection) then
                      begin
                        tmrMarchingAnts.Enabled := True;
                      end;

                      if Assigned(FPathPanelList.SelectedPanel) then
                      begin
                        FPathPanelList.SelectedPanel.PenPathList.DrawAllPaths(
                          FPathLayer.Bitmap.Canvas, pmNotXor, Point(0, 0) );
                      end
                      else
                      begin
                        DrawCurveSegments( FPathLayer.Bitmap.Canvas, pmNotXor, Point(0, 0) );
                      end;

                      FPathLayer.Bitmap.Changed;
                      FDrawing              := False;
                      Screen.Cursor         := crDefault;
                      imgDrawingArea.Cursor := GetPenToolDefaultCursor;

                      { If there is selected curve segment then compute the
                        radian and length of it. }
                      if Assigned(FPenPath) then
                      begin
                        FPenPath.CurveSegmentsList.CalcRadLenForCurveSegments;
                      end;

                      FPathPanelList.SelectedPanel.UpdateThumbnail(
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height,
                        FPathOffsetVector);

                      // Undo/Redo
                      LHistoryStatePanel := TgmClosePathStatePanel.Create(
                        frmHistory.scrlbxHistory,
                        dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
                        FPathPanelList.SelectedPanelIndex,
                        FOldPathIndex,
                        FOldPathList);

                      FHistoryManager.AddHistoryState(LHistoryStatePanel);

                      FreeAndNil(FOldPathList);
                      Exit;
                    end;
                  end
                  else
                  begin
                    // if the mouse is pointing on the end point of the last curve segment of the path...
                    LTempSegment := PointOnLastSegmentEndingPoint(FPathLayerX, FPathLayerY);

                    if Assigned(LTempSegment) then
                    begin
                      // if the Alt key is pressed, then change the anchor point to corner point
                      if ssAlt in Shift then
                      begin
                        RecordOldPathDataForUndoRedo; // Undo/Redo
                        FModifyPathMode := mpmPickupPath;

                        { If the mouse is clicked on the end point of the last
                          curve segment of the path with the Alt key is pressed,
                          and the last curve segment is not selected, then select
                          ii and activate the end point of it. }
                        if (CurrentIndex <> Count - 1) or
                           (CurrentSegment.ActivePoint <> apEnd) then
                        begin
                          FPenPath := FPathPanelList.SelectedPanel.PenPathList.SelectPath(
                            FPathLayerX, FPathLayerY, FPathSelectHandle);
                            
                          LTempSegment := FPenPath.CurveSegmentsList.CurrentSegment;
                        end;

                        // convert to convert point
                        LTempSegment.EndingPointType := eptCornerPoint;
                        LTempSegment.Opposite2       := LTempSegment.EndPoint;
                      end
                      else
                      begin
                        if (CurrentIndex <> Count - 1) or
                           (CurrentSegment.ActivePoint <> apEnd) then
                        begin
                          FPenPath := FPathPanelList.SelectedPanel.PenPathList.SelectPath(
                            FPathLayerX, FPathLayerY, FPathSelectHandle);
                        end;

                        RecordOldPathDataForUndoRedo; // Undo/Redo
                        FModifyPathMode := mpmPickupPath;
                               
                        CurrentSegment.Opposite2 := CurrentSegment.EndPoint;
                        FPathSelectHandle        := pshOpposite2;
                        Screen.Cursor            := crMovePath;
                        imgDrawingArea.Cursor    := crMovePath;
                        FDrawingBasePoint        := Point(FPathLayerX, FPathLayerY);
                        frmMain.PenTool          := ptDirectSelection; // switch to Direct Selection tool
                      end;
                    end
                    else 
                    begin
                      { If the mouse is not point on neither the starting point
                        of the first curve segment nor the end point of the last
                        curve segment of the path... }

                      { If the Alt key is pressed, then convert the anchor point
                        to corner point and switch the pen tool to Convert Point
                        tool. }
                      if ssAlt in Shift then
                      begin
                        RecordOldPathDataForUndoRedo;  // Undo/Redo

                        FPenPath := FPathPanelList.SelectedPanel.PenPathList.SelectPath(
                          FPathLayerX, FPathLayerY, FPathSelectHandle);

                        FPenPath.CurveSegmentsList.ConvertPoint(
                          FPathLayerX, FPathLayerY, coAnchorToCorner);

                        FMouseDownX            := FPathLayerX;
                        FMouseDownY            := FPathLayerY;
                        Screen.Cursor          := crMovePath;
                        imgDrawingArea.Cursor  := crMovePath;
                        FDrawingBasePoint      := Point(FPathLayerX, FPathLayerY);
                        frmMain.PenTool        := ptConvertPoint;

                        if FPathSelectHandle in [pshStart, pshEnd] then
                        begin
                          FModifyPathMode := mpmChangeAnchorPoint;
                        end
                        else
                        if FPathSelectHandle in [pshControl1, pshOpposite1,
                                                 pshControl2, pshOpposite2] then
                        begin
                          FModifyPathMode := mpmCornerDrag;
                        end;
                      end
                      else
                      begin
                        RecordOldPathDataForUndoRedo; // Undo/Redo
                        FModifyPathMode := mpmDeleteAnchorPoint;
                        
                        // if the Alt key is not pressed, then delete the anchor point
                        DeleteAnchorPointOnSegment(FPathLayerX, FPathLayerY);

                        Screen.Cursor         := crDefault;
                        imgDrawingArea.Cursor := GetPenToolDefaultCursor;
                      end;
                    end;
                  end;
                end
                else  // if the mouse is not pointing on any of the endpoints of path...
                begin
                  // if the mouse is pointing on the path...
                  if NilsIfPointOnBezier(FPathLayerX, FPathLayerY) then
                  begin
                    RecordOldPathDataForUndoRedo;
                    FModifyPathMode := mpmAddAnchorPoint;

                    // add anchor point
                    if FPenPath.CurveSegmentsList.AddAnchorPointOnSegment(FPathLayerX, FPathLayerY) then
                    begin
                      // compute the radian and length for the selected curve segment
                      FPenPath.CurveSegmentsList.CalcRadLenForCurveSegments;
                      
                      { After the anchor point is added to the list, at the same
                        time, if the user move the anchor point, then specify that
                        we want to modify the opposite control point 2 of the
                        anchor point in the mouse move event. }
                      FPathSelectHandle     := pshOpposite2;
                      frmMain.PenTool       := ptAddAnchorPoint;  // switch to Add Anchor Point tool
                      Screen.Cursor         := crMovePath;
                      imgDrawingArea.Cursor := crMovePath;
                    end;
                  end
                  else
                  begin
                    if not IsClosed then
                    begin
                      RecordOldPathDataForUndoRedo; // Undo/Redo
                      FModifyPathMode := mpmNewAnchorPoint;

                      AddFollowSegment( Point(FPathLayerX, FPathLayerY), Point(FPathLayerX, FPathLayerY) );
                      Screen.Cursor         := crMovePath;
                      imgDrawingArea.Cursor := crMovePath;
                    end
                    else
                    begin
                      FDrawing := False;
                    end;
                  end;
                end;
              end;
            end;

            // draw curve segments of the path
            if Assigned(FPathPanelList.SelectedPanel) then
            begin
              FPathPanelList.SelectedPanel.PenPathList.DrawAllPaths(
                FPathLayer.Bitmap.Canvas, pmNotXor, Point(0, 0) );
            end
            else
            begin
              if Count > 0 then
              begin
                DrawCurveDirectionLines(FPathLayer.Bitmap.Canvas, pmNotXor);
                DrawCurveSegments( FPathLayer.Bitmap.Canvas, pmNotXor, Point(0, 0) );
                DrawCurveHandles(FPathLayer.Bitmap.Canvas, pmNotXor);
              end;
            end;

            FPathLayer.Bitmap.Changed;
          end;

          // draw the Marching-Ants lines if the selection is existed
          if Assigned(FSelection) then
          begin
            imgDrawingArea.Update;
            DrawMarchingAnts;
          end;
        end;

      ptAddAnchorPoint:
        begin
          if Assigned(FPathPanelList.SelectedPanel) then
          begin
            FPathLayer.Bitmap.Clear($00000000);  // clear path

            // select a path
            FPenPath := FPathPanelList.SelectedPanel.PenPathList.SelectPath(
              FPathLayerX, FPathLayerY, FPathSelectHandle);

            { If the mouse is pointing on a handle then move the handle; if the
              mouse is pointing on a curve segment then add an anchor point to
              the curve segment. }
            if FPathSelectHandle <> pshNone then
            begin
              if Assigned(FPenPath) then
              begin
                // For Undo/Redo
                FAccumTranslateVector := Point(0, 0);
                RecordOldPathDataForUndoRedo;

                if FPathSelectHandle in [pshStart, pshEnd] then
                begin
                  FModifyPathMode := mpmDragAnchorPoint;
                end
                else
                if FPathSelectHandle in [pshControl1, pshControl2,
                                         pshOpposite1, pshOpposite2] then
                begin
                  FModifyPathMode := mpmDragControlPoint;
                end;

                Screen.Cursor         := crMovePath;
                imgDrawingArea.Cursor := crMovePath;
                FDrawingBasePoint     := Point(FPathLayerX, FPathLayerY);
                FOriginalPairState    := FPenPath.CurveSegmentsList.GetSelectedSegmentsPairState; // save the original status
                frmMain.PenTool       := ptDirectSelection; // convert to Direct Selection tool
              end;
            end
            else
            begin
              if Assigned(FPenPath) then
              begin
                with FPenPath.CurveSegmentsList do
                begin
                  if Count > 0 then
                  begin
                    if IsFirstSegmentOK then
                    begin
                      RecordOldPathDataForUndoRedo;  // For Undo/Redo
                      FModifyPathMode := mpmAddAnchorPoint;

                      // add anchor point
                      if FPenPath.CurveSegmentsList.AddAnchorPointOnSegment(FPathLayerX, FPathLayerY) then
                      begin
                        FPathSelectHandle := pshOpposite2;
                        FPenPath.CurveSegmentsList.CalcRadLenForCurveSegments;
                      end;
                    end;
                  end;
                end;
              end;
            end;

            if FPathSelectHandle <> pshNone then
            begin
              Screen.Cursor         := GetPenPathCursor(FPathSelectHandle);
              imgDrawingArea.Cursor := Screen.Cursor;
              FDrawingBasePoint     := Point(FPathLayerX, FPathLayerY);
            end;

            FPathPanelList.SelectedPanel.PenPathList.DrawAllPaths(
              FPathLayer.Bitmap.Canvas, pmNotXor, Point(0, 0) );

            FPathLayer.Bitmap.Changed;

            if Assigned(FSelection) then
            begin
              imgDrawingArea.Update;
              DrawMarchingAnts;
            end;
          end;
        end;

      ptDeleteAnchorPoint:
        begin
          if Assigned(FPathPanelList.SelectedPanel) then
          begin
            FPathLayer.Bitmap.Clear($00000000);  // clear paths

            // select a path
            FPenPath := FPathPanelList.SelectedPanel.PenPathList.SelectPath(
              FPathLayerX, FPathLayerY, FPathSelectHandle);

            if Assigned(FPenPath) then
            begin
              with FPenPath.CurveSegmentsList do
              begin
                if Count > 0 then
                begin
                  // if the mouse is pointing on any of the endpoints of the path, then delete it
                  if FPathSelectHandle in [pshStart, pshEnd] then
                  begin
                    RecordOldPathDataForUndoRedo;  // For Undo/Redo
                    FModifyPathMode := mpmDeleteAnchorPoint;

                    DeleteAnchorPointOnSegment(FPathLayerX, FPathLayerY);
                    
                    Screen.Cursor         := crDefault;
                    imgDrawingArea.Cursor := crDirectSelection;
                  end;
                end;
              end;

              if FPathSelectHandle in [pshControl1, pshOpposite1,
                                       pshControl2, pshOpposite2] then
              begin
                // For Undo/Redo
                FAccumTranslateVector := Point(0, 0); 
                RecordOldPathDataForUndoRedo;

                if FPathSelectHandle in [pshStart, pshEnd] then
                begin
                  FModifyPathMode := mpmDragAnchorPoint;
                end
                else
                if FPathSelectHandle in [pshControl1, pshControl2,
                                         pshOpposite1, pshOpposite2] then
                begin
                  FModifyPathMode := mpmDragControlPoint;
                end;

                Screen.Cursor         := GetPenPathCursor(FPathSelectHandle);
                imgDrawingArea.Cursor := Screen.Cursor;
                FDrawingBasePoint     := Point(FPathLayerX, FPathLayerY);
                FOriginalPairState    := FPenPath.CurveSegmentsList.GetSelectedSegmentsPairState;  // save the original status
                frmMain.PenTool       := ptDirectSelection;  // convert to Direct Selection tool
              end;
            end;

            FPathPanelList.SelectedPanel.PenPathList.DrawAllPaths(
              FPathLayer.Bitmap.Canvas, pmNotXor, Point(0, 0) );
              
            FPathLayer.Bitmap.Changed;
       
            if Assigned(FSelection) then
            begin
              imgDrawingArea.Update;
              DrawMarchingAnts;
            end;
          end;
        end;

      ptConvertPoint:
        begin
          if Assigned(FPathPanelList.SelectedPanel) then
          begin
            FPathLayer.Bitmap.Clear($00000000);  // clear paths

            // select a path
            FPenPath := FPathPanelList.SelectedPanel.PenPathList.SelectPath(
              FPathLayerX, FPathLayerY, FPathSelectHandle);

            if Assigned(FPenPath) then
            begin
              with FPenPath.CurveSegmentsList do
              begin
                if Count > 0 then
                begin
                  if FPathSelectHandle in [pshStart, pshEnd] then
                  begin
                    RecordOldPathDataForUndoRedo;  // For Undo/Redo
                    FModifyPathMode := mpmChangeAnchorPoint;

                    FPenPath.CurveSegmentsList.ConvertPoint(
                      FPathLayerX, FPathLayerY, coAnchorToCorner);

                    FOppositeLineOperation := oloAbsoluteOpposite;
                    FMouseDownX            := FPathLayerX;
                    FMouseDownY            := FPathLayerY;
                  end
                  else
                  begin
                    FOppositeLineOperation := oloChangeAngleOnly;
                  end;
                end;
              end;

              if FPathSelectHandle <> pshNone then
              begin
                Screen.Cursor     := GetPenPathCursor(FPathSelectHandle);
                FDrawingBasePoint := Point(FPathLayerX, FPathLayerY);

                if FPathSelectHandle in [pshControl1, pshOpposite1,
                                         pshControl2, pshOpposite2] then
                begin
                  RecordOldPathDataForUndoRedo;  // For Undo/Redo

                  FModifyPathMode       := mpmCornerDrag;
                  FAccumTranslateVector := Point(0, 0);

                  FPenPath.CurveSegmentsList.ChangeDirectionLinesPairState(psUnpaired, True);
                end;
              end;
            end;

            FPathPanelList.SelectedPanel.PenPathList.DrawAllPaths(
              FPathLayer.Bitmap.Canvas, pmNotXor, Point(0, 0) );
              
            FPathLayer.Bitmap.Changed;

            if Assigned(FSelection) then
            begin
              imgDrawingArea.Update;
              DrawMarchingAnts;
            end;
          end;
        end;
    end;
  end;
end;

procedure TfrmChild.PenToolsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
var
  LTranslateVector: TPoint;
  LPairState      : TgmPairState;
  LColor          : TColor;
begin
  CalcLayerCoord(X, Y);  // get layer space coordinates

  // if the path layer is existed, then get the path layer space coordinates
  if Assigned(FPathLayer) then
  begin
    CalcPathLayerCoord(X, Y);
  end;
  
{ Move mouse when mouse left button down }

  if FDrawing then
  begin
    // Change cursor
    if Screen.Cursor <> crMovePath then
    begin
      Screen.Cursor         := crMovePath;
      imgDrawingArea.Cursor := crMovePath;
    end;

    if Assigned(FPathLayer) then
    begin
      case frmMain.PenTool of
        ptPathComponentSelection:
          begin
            if Assigned(FPathPanelList.SelectedPanel) then
            begin
              if FWholePathIndex > (-1) then
              begin
                with FPathPanelList.SelectedPanel.PenPathList do
                begin
                  // clear the old paths
                  DrawAllPaths( FPathLayer.Bitmap.Canvas, pmNotXor, Point(0, 0) );

                  // translate the selected paths
                  LTranslateVector      := SubtractPoints( Point(FPathLayerX, FPathLayerY), FDrawingBasePoint );
                  FAccumTranslateVector := AddPoints(FAccumTranslateVector, LTranslateVector);  // for Undo/Redo

                  TranslateAllSelectedPaths(LTranslateVector);

                  // draw the new paths
                  DrawAllPaths( FPathLayer.Bitmap.Canvas, pmNotXor, Point(0, 0) );
                  FPathLayer.Bitmap.Changed;
                  
                  FDrawingBasePoint := Point(FPathLayerX, FPathLayerY);
                end;
              end;
            end;
          end;

        ptDirectSelection:
          begin
            if Assigned(FPenPath) then
            begin
              with FPenPath.CurveSegmentsList do
              begin
                if FPathSelectHandle <> pshNone then
                begin
                  if ssAlt in Shift then
                  begin
                    { If the pair state of the direction lines of the curve segment
                      is changed, then we set the two direction lines are in
                      paired state, otherwise in unpaired state. }
                    if IsPairStateChanged then
                    begin
                      LPairState := psPaired;
                    end
                    else
                    begin
                      LPairState := psUnpaired;
                    end;

                    if GetSelectedSegmentsPairState <> LPairState then
                    begin
                      ChangeDirectionLinesPairState(LPairState, False);
                    end;
                  end
                  else
                  begin
                    { If moving the mouse with the Alt key released, then
                      change the pair state of the two direction lines back to
                      the original state. }
                    if GetSelectedSegmentsPairState <> FOriginalPairState then
                    begin
                      ChangeDirectionLinesPairState(FOriginalPairState, False);
                    end;
                  end;

                  // clear the old paths
                  FPathPanelList.SelectedPanel.PenPathList.DrawAllPaths(
                    FPathLayer.Bitmap.Canvas, pmNotXor, Point(0, 0) );

                  // change the curve segment handle position
                  LTranslateVector       := SubtractPoints( Point(FPathLayerX, FPathLayerY), FDrawingBasePoint );
                  FAccumTranslateVector := AddPoints(FAccumTranslateVector, LTranslateVector);  // for Undo/Redo

                  ChangeSelectedHandlePosition(FPathSelectHandle,
                                               LTranslateVector,
                                               oloChangeAngleOnly);

                  // draw the new paths
                  FPathPanelList.SelectedPanel.PenPathList.DrawAllPaths(
                    FPathLayer.Bitmap.Canvas, pmNotXor, Point(0, 0) );
                    
                  FPathLayer.Bitmap.Changed;

                  FDrawingBasePoint := Point(FPathLayerX, FPathLayerY);
                end;
              end;
            end;
          end;

        ptPenTool:
          begin
            if Assigned(FPenPath) then
            begin
              with FPenPath.CurveSegmentsList do
              begin
                if Assigned(FPathPanelList.SelectedPanel) then
                begin
                  FPathPanelList.SelectedPanel.PenPathList.DrawAllPaths(
                    FPathLayer.Bitmap.Canvas, pmNotXor, Point(0, 0) );
                end;

                if Count > 0 then
                begin
                  if FPathPanelList.SelectedPanel = nil then
                  begin
                    // clear the old direction lines
                    DrawCurveDirectionLines(FPathLayer.Bitmap.Canvas, pmNotXor);
                    DrawCurveSegments( FPathLayer.Bitmap.Canvas, pmNotXor, Point(0, 0) );
                    DrawCurveHandles(FPathLayer.Bitmap.Canvas, pmNotXor);
                  end;

                  if IsFirstSegmentOK = False then
                  begin
                    if Assigned(CurrentSegment) then
                    begin
                      CurrentSegment.Control1  := Point(FPathLayerX, FPathLayerY);
                      CurrentSegment.Opposite1 := GetOppositePoint(CurrentSegment.StartPoint, CurrentSegment.Control1);
                    end;
                  end
                  else
                  begin
                    if Assigned(CurrentSegment) then
                    begin
                      case CurrentSegment.ActivePoint of
                        apStart:
                          begin
                            CurrentSegment.Control1  := Point(FPathLayerX, FPathLayerY);
                            CurrentSegment.Control2  := Point(FPathLayerX, FPathLayerY);
                            CurrentSegment.EndPoint  := Point(FPathLayerX, FPathLayerY);
                            CurrentSegment.Opposite1 := GetOppositePoint(CurrentSegment.StartPoint, CurrentSegment.Control1);
                          end;

                        apEnd:
                          begin
                            CurrentSegment.Opposite2 := Point(FPathLayerX, FPathLayerY);
                            CurrentSegment.Control2  := GetOppositePoint(CurrentSegment.EndPoint, CurrentSegment.Opposite2);
                          end;
                      end;
                    end;
                  end;

                  if Assigned(FPathPanelList.SelectedPanel) then
                  begin
                    FPathPanelList.SelectedPanel.PenPathList.DrawAllPaths(
                      FPathLayer.Bitmap.Canvas, pmNotXor, Point(0, 0) );
                  end
                  else
                  begin
                    // draw the new direction lines
                    DrawCurveDirectionLines(FPathLayer.Bitmap.Canvas, pmNotXor);
                    DrawCurveSegments( FPathLayer.Bitmap.Canvas, pmNotXor, Point(0, 0) );
                    DrawCurveHandles(FPathLayer.Bitmap.Canvas, pmNotXor);
                  end;
                end;
                
                FPathLayer.Bitmap.Changed;
              end;
            end;
          end;

        ptAddAnchorPoint:
          begin
            if Assigned(FPenPath) then
            begin
              with FPenPath.CurveSegmentsList do
              begin
                if FPathSelectHandle <> pshNone then
                begin
                  // clear the old paths
                  FPathPanelList.SelectedPanel.PenPathList.DrawAllPaths(
                    FPathLayer.Bitmap.Canvas, pmNotXor, Point(0, 0) );

                  // if the user add an anchor point to the path and simultaneously move the mouse...
                  if FPathSelectHandle = pshOpposite2 then
                  begin
                    if DifferentCoordinate( CurrentSegment.Opposite2, Point(FPathLayerX, FPathLayerY) ) then
                    begin
                      CurrentSegment.Opposite2 := Point(FPathLayerX, FPathLayerY);
                    end;
                  end;
                  
                  // change curve segment handle position
                  LTranslateVector := SubtractPoints( Point(FPathLayerX, FPathLayerY),
                                                      FDrawingBasePoint );

                  ChangeSelectedHandlePosition(FPathSelectHandle,
                                               LTranslateVector,
                                               oloChangeAngleOnly);

                  // draw the new paths
                  FPathPanelList.SelectedPanel.PenPathList.DrawAllPaths(
                    FPathLayer.Bitmap.Canvas, pmNotXor, Point(0, 0) );
                    
                  FPathLayer.Bitmap.Changed;
                  
                  FDrawingBasePoint := Point(FPathLayerX, FPathLayerY);
                end;
              end;
            end;
          end;

        ptDeleteAnchorPoint:
          begin
            if Assigned(FPathPanelList.SelectedPanel) then
            begin
              if Assigned(FPenPath) then
              begin
                if FPathSelectHandle in [pshControl1, pshOpposite1,
                                         pshControl2, pshOpposite2] then
                begin
                  with FPenPath.CurveSegmentsList do
                  begin
                    // clear the old paths
                    FPathPanelList.SelectedPanel.PenPathList.DrawAllPaths(
                      FPathLayer.Bitmap.Canvas, pmNotXor, Point(0, 0) );

                    // change handle position
                    LTranslateVector := SubtractPoints( Point(FPathLayerX, FPathLayerY),
                                                        FDrawingBasePoint );

                    ChangeSelectedHandlePosition(FPathSelectHandle,
                                                 LTranslateVector,
                                                 oloAbsoluteOpposite);

                    // draw the paths
                    FPathPanelList.SelectedPanel.PenPathList.DrawAllPaths(
                      FPathLayer.Bitmap.Canvas, pmNotXor, Point(0, 0) );
                      
                    FPathLayer.Bitmap.Changed;
                    
                    FDrawingBasePoint := Point(FPathLayerX, FPathLayerY);
                  end;
                end;
              end;
            end;
          end;

        ptConvertPoint:
          begin
            if Assigned(FPathPanelList.SelectedPanel) then
            begin
              if Assigned(FPenPath) then
              begin
                if FPathSelectHandle <> pshNone then
                begin
                  // change the endpoint of the curve segment from corner point to anchor point
                  if FPathSelectHandle in [pshStart, pshEnd] then
                  begin
                    FPenPath.CurveSegmentsList.ConvertPoint(
                      FMouseDownX, FMouseDownY, coCornerToAnchor);
                  end;

                  case FPathSelectHandle of
                    pshStart:
                      begin
                        if FPenPath.CurveSegmentsList.IsClosed then
                        begin
                          FPathSelectHandle := pshOpposite2;
                        end
                        else
                        begin
                          FPathSelectHandle := pshControl1;
                        end;
                      end;

                    pshEnd:
                      begin
                        FPathSelectHandle := pshOpposite2;
                      end;
                  end;

                  with FPenPath.CurveSegmentsList do
                  begin
                    // clear the old paths
                    FPathPanelList.SelectedPanel.PenPathList.DrawAllPaths(
                      FPathLayer.Bitmap.Canvas, pmNotXor, Point(0, 0) );

                    // change curve segment handle position
                    LTranslateVector      := SubtractPoints( Point(FPathLayerX, FPathLayerY), FDrawingBasePoint );
                    FAccumTranslateVector := AddPoints(FAccumTranslateVector, LTranslateVector);  // for Undo/Redo

                    ChangeSelectedHandlePosition(FPathSelectHandle,
                                                 LTranslateVector,
                                                 FOppositeLineOperation);

                    // draw the new paths
                    FPathPanelList.SelectedPanel.PenPathList.DrawAllPaths(
                      FPathLayer.Bitmap.Canvas, pmNotXor, Point(0, 0) );
                      
                    FDrawingBasePoint := Point(FPathLayerX, FPathLayerY);
                  end;
                end;
              end;
            end;
          end;
      end;

      if Assigned(FSelection) then
      begin
        imgDrawingArea.Update;
        DrawMarchingAnts;
      end;
    end;
  end
  else // Move Mouse When Mouse Button Not Down
  begin
    // change cursor
    if Assigned(FPathLayer) then
    begin
      case frmMain.PenTool of
        ptPathComponentSelection:
          begin
            if Assigned(FPathPanelList.SelectedPanel) then
            begin
              if FPathPanelList.SelectedPanel.PenPathList.IfPointOnPathsForWholePath(FPathLayerX, FPathLayerY) > (-1) then
              begin
                Screen.Cursor         := crMovePath;
                imgDrawingArea.Cursor := crMovePath;
              end
              else
              begin
                Screen.Cursor         := crDefault;
                imgDrawingArea.Cursor := crPathComponentSelection;
              end;
            end
            else
            begin
              Screen.Cursor         := crDefault;
              imgDrawingArea.Cursor := crPathComponentSelection;
            end;
          end;

        ptDirectSelection:
          begin
            if Assigned(FPathPanelList.SelectedPanel) then
            begin
              Screen.Cursor := FPathPanelList.SelectedPanel.PenPathList.GetCursor(
                FPathLayerX, FPathLayerY, frmMain.PenTool);

              imgDrawingArea.Cursor := Screen.Cursor;
            end
            else
            begin
              Screen.Cursor         := crDefault;
              imgDrawingArea.Cursor := crDirectSelection;
            end;
          end;

        ptPenTool:
          begin
            if Assigned(FPenPath) then
            begin
              with FPenPath.CurveSegmentsList do
              begin
                // if the first curve segment is complete...
                if IsFirstSegmentOK then
                begin
                  // if the mouse is pointing on the endpoints of the path...
                  if GetSelectedEndingHandle(FPathLayerX, FPathLayerY) <> pshNone then
                  begin
                    // if the path is not closed...
                    if not IsClosed then
                    begin
                      // if the mouse is on the starting point of the first curve segment...
                      if PointOnFirstSegmentStart(FPathLayerX, FPathLayerY) then
                      begin
                        Screen.Cursor         := crClosePath;
                        imgDrawingArea.Cursor := crClosePath;
                      end
                      else
                      // if the mouse is on the end point of the last curve segment...
                      if PointOnLastSegmentEndingPoint(FPathLayerX, FPathLayerY) <> nil then
                      begin
                        if ssAlt in Shift then
                        begin
                          Screen.Cursor         := crAddCornerPoint;
                          imgDrawingArea.Cursor := crAddCornerPoint;
                        end
                        else
                        begin
                          Screen.Cursor         := crPenToolLastEnd;
                          imgDrawingArea.Cursor := crPenToolLastEnd;
                        end;
                      end
                      { If the mouse is on any of the endpoints of the path that
                        neither the first endpoint nor the last endpoint... }
                      else
                      begin
                        if ssAlt in Shift then
                        begin
                          Screen.Cursor         := crConvertPoint;
                          imgDrawingArea.Cursor := crConvertPoint;
                        end
                        else
                        begin
                          Screen.Cursor         := crDeleteAnchorPoint;
                          imgDrawingArea.Cursor := crDeleteAnchorPoint;
                        end;
                      end;
                    end
                    else  // if the path is closed...
                    begin
                      if ssAlt in Shift then
                      begin
                        Screen.Cursor         := crConvertPoint;
                        imgDrawingArea.Cursor := crConvertPoint;
                      end
                      else
                      begin
                        Screen.Cursor         := crDeleteAnchorPoint;
                        imgDrawingArea.Cursor := crDeleteAnchorPoint;
                      end;
                    end;
                  end
                  else
                  // if the mouse is on the path ...
                  if NilsIfPointOnBezier(FPathLayerX, FPathLayerY) then
                  begin
                    Screen.Cursor         := crAddAnchorPoint;
                    imgDrawingArea.Cursor := crAddAnchorPoint;
                  end
                  else
                  begin
                    Screen.Cursor         := crDefault;
                    imgDrawingArea.Cursor := GetPenToolDefaultCursor;
                  end;
                end
                else  // if the first curve segment is not complete...
                begin
                  // if the mouse is on the starting point of the first curve segment...
                  if PointOnFirstSegmentStart(FPathLayerX, FPathLayerY) then
                  begin
                    if ssAlt in Shift then
                    begin
                      Screen.Cursor         := crAddCornerPoint;
                      imgDrawingArea.Cursor := crAddCornerPoint;
                    end
                    else
                    begin
                      Screen.Cursor         := crPenToolLastEnd;
                      imgDrawingArea.Cursor := crPenToolLastEnd;
                    end;
                  end
                  else
                  begin
                    Screen.Cursor         := crDefault;
                    imgDrawingArea.Cursor := GetPenToolDefaultCursor;
                  end;
                end;
              end;
            end
            else
            begin
              Screen.Cursor         := crDefault;
              imgDrawingArea.Cursor := GetPenToolDefaultCursor;
            end;
          end;

        ptAddAnchorPoint:
          begin
            if Assigned(FPathPanelList.SelectedPanel) then
            begin
              if FPathPanelList.SelectedPanel.PenPathList.IfPointOnSelectedPathHandles(FPathLayerX, FPathLayerY) then
              begin
                Screen.Cursor         := crMovePath;
                imgDrawingArea.Cursor := crMovePath;
              end
              else
              if FPathPanelList.SelectedPanel.PenPathList.IfPointOnPaths(FPathLayerX, FPathLayerY) then
              begin
                Screen.Cursor         := crAddAnchorPoint;
                imgDrawingArea.Cursor := crAddAnchorPoint;
              end
              else
              begin
                Screen.Cursor         := crDefault;
                imgDrawingArea.Cursor := crDirectSelection;
              end;
            end;
          end;

        ptDeleteAnchorPoint:
          begin
            if Assigned(FPathPanelList.SelectedPanel) then
            begin
              with FPathPanelList.SelectedPanel.PenPathList do
              begin
                if Assigned(SelectedPath) then
                begin
                  if SelectedPath.CurveSegmentsList.GetSelectedEndingHandle(FPathLayerX, FPathLayerY) <> pshNone then
                  begin
                    Screen.Cursor         := crDeleteAnchorPoint;
                    imgDrawingArea.Cursor := crDeleteAnchorPoint;
                  end
                  else
                  if SelectedPath.CurveSegmentsList.GetSelectedDirectionHandle(FPathLayerX, FPathLayerY) <> pshNone then
                  begin
                    Screen.Cursor         := crMovePath;
                    imgDrawingArea.Cursor := crMovePath;
                  end
                  else
                  begin
                    if IfPointOnPaths(FPathLayerX, FPathLayerY) then
                    begin
                      Screen.Cursor         := crHandPoint;
                      imgDrawingArea.Cursor := crHandPoint;
                    end
                    else
                    begin
                      Screen.Cursor         := crDefault;
                      imgDrawingArea.Cursor := crDirectSelection;
                    end;
                  end;
                end
                else
                begin
                  if IfPointOnPaths(FPathLayerX, FPathLayerY) then
                  begin
                    Screen.Cursor         := crHandPoint;
                    imgDrawingArea.Cursor := crHandPoint;
                  end
                  else
                  begin
                    Screen.Cursor         := crDefault;
                    imgDrawingArea.Cursor := crDirectSelection;
                  end;
                end;
              end;
            end;
          end;

        ptConvertPoint:
          begin
            if Assigned(FPathPanelList.SelectedPanel) then
            begin
              if FPathPanelList.SelectedPanel.PenPathList.IfPointOnSelectedPathHandles(FPathLayerX, FPathLayerY) then
              begin
                Screen.Cursor         := crConvertPoint;
                imgDrawingArea.Cursor := crConvertPoint;
              end
              else
              if FPathPanelList.SelectedPanel.PenPathList.IfPointOnPaths(FPathLayerX, FPathLayerY) then
              begin
                Screen.Cursor         := crHandPoint;
                imgDrawingArea.Cursor := crHandPoint;
              end
              else
              begin
                Screen.Cursor         := crDefault;
                imgDrawingArea.Cursor := crDirectSelection;
              end;
            end;
          end;
      end;
    end;

    if (FXActual >= 0) and
       (FYActual >= 0) and
       (FXActual <= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width) and
       (FYActual <= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height) then
    begin
      LColor := imgDrawingArea.Canvas.Pixels[X, Y];
      
      frmMain.ShowColorRGBInfoOnInfoViewer(LColor);
      frmMain.ShowColorCMYKInfoOnInfoViewer(LColor);
    end;
  end;

  frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
end;

procedure TfrmChild.PenToolsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  LOldPenPathList   : TgmPenPathList;
  LPathPanel        : TgmPathPanel;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  if FDrawing then
  begin
    Screen.Cursor      := crDefault;
    LHistoryStatePanel := nil;

    if Assigned(FPathLayer) then
    begin
      CalcPathLayerCoord(X, Y);  // get path layer space coordinates

      case frmMain.PenTool of
        ptPathComponentSelection:
          begin
            if Assigned(FPathPanelList.SelectedPanel) then
            begin
              FPathPanelList.SelectedPanel.UpdateThumbnail(
                FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
                FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height,
                FPathOffsetVector);
            end;

            if (FAccumTranslateVector.X <> 0) or
               (FAccumTranslateVector.Y <> 0) then
            begin
              LHistoryStatePanel := TgmTranslatePathsStatePanel.Create(
                frmHistory.scrlbxHistory,
                dmHistory.bmp32lstHistory.Bitmap[MOVE_OBJECTS_COMMAND_ICON_INDEX],
                FPathPanelList.SelectedPanelIndex,
                FAccumTranslateVector);
            end;
          end;

        ptDirectSelection:
          begin
            if Assigned(FPenPath) then
            begin
              { If release the mouse left button with the Alt key is pressed,
                then change the pair state to psUnpaired and save the settings. }
              if ssAlt in Shift then
              begin
                FPenPath.CurveSegmentsList.ChangeDirectionLinesPairState(psUnpaired, True);
              end
              else
              begin
                { If the Alt key is not pressed, and the pair state is change,
                  then change the pair state to psUnpaired. }
                if FPenPath.CurveSegmentsList.IsPairStateChanged then
                begin
                  FPenPath.CurveSegmentsList.ChangeDirectionLinesPairState(psUnpaired, True);
                end;
              end;

              // recalculate the radian and length of the curve segment
              FPenPath.CurveSegmentsList.CalcRadLenForCurveSegments;
            end;

            if Assigned(FPathPanelList.SelectedPanel) then
            begin
              FPathPanelList.SelectedPanel.UpdateThumbnail(
                FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
                FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height,
                FPathOffsetVector);
            end;

            imgDrawingArea.Cursor := crDirectSelection;

            // Undo/Redo
            if (FAccumTranslateVector.X <> 0) or
               (FAccumTranslateVector.Y <> 0) then
            begin
              CreateModifyPathUndoRedoCommand(FModifyPathMode);
            end;
          end;

        ptPenTool:
          begin
            // if there is a selected path, then calculate the radian and length of it
            if Assigned(FPenPath) then
            begin
              FPenPath.CurveSegmentsList.CalcRadLenForCurveSegments;
            end;

            if FPathPanelList.SelectedPanel = nil then
            begin
              if (FPathPanelList.Count = 0) or
                 (FPathPanelList.IfLastPathPanelNamed) then
              begin
                LPathPanel := TgmPathPanel.Create(frmPath.scrlbxPathPanelContainer, pptWorkPath);

                LPathPanel.PenPathList.AddNewPathToList(FPenPath);
                FPathPanelList.AddPathPanelToList(LPathPanel);

                // Undo/Redo
                LHistoryStatePanel := TgmNewWorkPathStatePanel.Create(
                  frmHistory.scrlbxHistory,
                  dmHistory.bmp32lstHistory.Bitmap[WORK_PATH_COMMAND_ICON_INDEX],
                  FPathPanelList.Count - 1,
                  FPenPath);
              end
              else
              if (FPathPanelList.Count > 0) or
                 (not FPathPanelList.IfLastPathPanelNamed) then
              begin
                LOldPenPathList := TgmPenPathList.Create;
                try
                  LPathPanel := TgmPathPanel(FPathPanelList.Items[FPathPanelList.Count - 1]);

                  LOldPenPathList.AssignPenPathListData(LPathPanel.PenPathList);

                  FPathPanelList.ActivateWorkPath;

                  if Assigned(FPathPanelList.SelectedPanel) then
                  begin
                    FPathPanelList.SelectedPanel.PenPathList.AddNewPathToList(FPenPath);
                  end;

                  // Undo/Redo
                  LHistoryStatePanel := TgmActiveWorkPathStatePanel.Create(
                    frmHistory.scrlbxHistory,
                    dmHistory.bmp32lstHistory.Bitmap[WORK_PATH_COMMAND_ICON_INDEX],
                    FPathPanelList.SelectedPanelIndex,
                    LOldPenPathList,
                    FPenPath);
                finally
                  LOldPenPathList.Free;
                end;
              end;
            end
            else
            begin
              if FPathPanelList.SelectedPanel.PenPathList.PathListState = plsAddNewPath then
              begin
                if Assigned(FPenPath) then
                begin
                  FPathPanelList.SelectedPanel.PenPathList.AddNewPathToList(FPenPath);
                end;
              end;

              // Undo/Redo
              CreateModifyPathUndoRedoCommand(FModifyPathMode);
            end;

            if Assigned(FPathPanelList.SelectedPanel) then
            begin
              FPathPanelList.SelectedPanel.UpdateThumbnail(
                FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
                FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height,
                FPathOffsetVector);
            end;

            // change cursor
            if Assigned(FPenPath) then
            begin
              if FPenPath.CurveSegmentsList.GetSelectedEndingHandle(FPathLayerX, FPathLayerY) = pshNone then
              begin
                imgDrawingArea.Cursor := GetPenToolDefaultCursor;
              end;
            end
            else
            begin
              imgDrawingArea.Cursor := GetPenToolDefaultCursor;
            end;
          end;

        ptAddAnchorPoint, ptConvertPoint:
          begin
            FPathSelectHandle := pshNone;

            // if there is a selected path, then calculate the radian and length of it
            if Assigned(FPenPath) then
            begin
              FPenPath.CurveSegmentsList.CalcRadLenForCurveSegments;

              FPathPanelList.SelectedPanel.UpdateThumbnail(
                FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
                FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height,
                FPathOffsetVector);
            end;

            // Undo/Redo
            if FModifyPathMode = mpmCornerDrag then
            begin
              // Undo/Redo
              if (FAccumTranslateVector.X <> 0) or
                 (FAccumTranslateVector.Y <> 0) then
              begin
                CreateModifyPathUndoRedoCommand(FModifyPathMode);
              end;
            end
            else
            begin
              CreateModifyPathUndoRedoCommand(FModifyPathMode);
            end;
          end;

        ptDeleteAnchorPoint:
          begin
            FPathSelectHandle := pshNone;
            
            if Assigned(FPathPanelList.SelectedPanel) then
            begin
              { If there is no any curve segment in the selected path after
                deleting an anchor point, then delete the whole path, and set
                the path list to Add New Path state. }
              if Assigned(FPathPanelList.SelectedPanel.PenPathList.SelectedPath) then
              begin
                if FPathPanelList.SelectedPanel.PenPathList.SelectedPath.CurveSegmentsList.Count = 0 then
                begin
                  FPathPanelList.SelectedPanel.PenPathList.Delete(
                    FPathPanelList.SelectedPanel.PenPathList.SelectedPathIndex);

                  FPathPanelList.SelectedPanel.PenPathList.SelectedPath      := nil;
                  FPenPath                                                   := nil;
                  FPathPanelList.SelectedPanel.PenPathList.PathListState     := plsAddNewPath;
                  FPathPanelList.SelectedPanel.PenPathList.SelectedPathIndex := -1;
                end;
              end;

              FPathPanelList.SelectedPanel.UpdateThumbnail(
                FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
                FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height,
                FPathOffsetVector);
                
              // Undo/Redo
              CreateModifyPathUndoRedoCommand(FModifyPathMode);
            end;
            
            // if there is a selected path, then calculate the radian and length of it
            if Assigned(FPenPath) then
            begin
              FPenPath.CurveSegmentsList.CalcRadLenForCurveSegments;
            end;
          end;
      end;

      // switch to current selected tool in the tool box
      frmMain.PenTool := frmMain.ActivePenTool;

      if Assigned(FSelection) then
      begin
        tmrMarchingAnts.Enabled := True;
      end;
    end;

    FDrawing := False;

    if Assigned(LHistoryStatePanel) then
    begin
      FHistoryManager.AddHistoryState(LHistoryStatePanel);
    end;
  end;

  if Assigned(FPathPanelList.SelectedPanel) then
  begin
    frmPath.tlbtnStrokePath.Enabled          := (FPathPanelList.SelectedPanel.PenPathList.GetSelectedPathsCount > 0);
    frmPath.tlbtnFillPath.Enabled            := frmPath.tlbtnStrokePath.Enabled;
    frmPath.tlbtnLoadPathAsSelection.Enabled := frmPath.tlbtnStrokePath.Enabled;
  end;
end;

procedure TfrmChild.MeasureToolsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
begin
  CalcLayerCoord(X, Y);  // get layer space coordinates

{ Mouse Left Button Down }

  if Button = mbLeft then
  begin
    // showing the coordinates of the starting point and current point
    frmMain.ShowOriginalCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
    frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);

    PauseMarchingAnts;  // not drawing dynamic Marching-Ants lines when processing image
    FDrawing := True;

    if FMeasureLayer = nil
    then CreateMeasureLayer;

    CalcMeasureLayerCoord(X, Y);  // get measure layer space coordinates

    if Assigned(FMeasureLine) then
    begin
      if ssAlt in Shift then
      begin
        if  (FMeasureLine.LineCount = 2) then
        begin
          FMeasurePointSelector := FMeasureLine.GetHandleAtPoint(FMeasureLayerX, FMeasureLayerY);

          if ( FMeasurePointSelector in [mpsFirst, mpsSecond] ) then
          begin
            if   FMeasurePointSelector = mpsFirst
            then FMeasureLine.SwapFirstAndSecondMeasurePoint;

            FMeasureLine.AddThirdMeasurePoint(FMeasureLayerX, FMeasureLayerY);
            FMeasureDrawingState := dsNewFigure;
            Screen.Cursor        := crMeasureMove;

            // update the measure line
            FMeasureLayer.Bitmap.Clear($00000000);
            FMeasureLine.Draw(FMeasureLayer.Bitmap.Canvas, pmNotXor);
            FMeasureLayer.Bitmap.Changed;
          end;
        end;
      end
      else
      begin
        // determine wheter the mouse points on any endpoints of the measure line
        FMeasurePointSelector := FMeasureLine.GetHandleAtPoint(FMeasureLayerX, FMeasureLayerY);

        if FMeasurePointSelector <> mpsNone then
        begin
          FMeasureDrawingState := dsStretchCorner;
          Screen.Cursor        := crMeasureMove;
        end
        else
        begin
          // determine wheter the mouse points on the body of the measure line
          if FMeasureLine.ContainsPoint(FMeasureLayerX, FMeasureLayerY) then
          begin
            FDrawingBasePoint    := Point(FMeasureLayerX, FMeasureLayerY);
            Screen.Cursor        := crMeasureMove;
            FMeasureDrawingState := dsTranslate;
          end
        end;
      end;
    end
    else
    begin
      Screen.Cursor := crMeasureMove;
      FMeasureLine  := nil;
      FMeasureLine  := TgmMeasureLine.Create(FMeasureOffsetVector); 

      // set two measuring points for the first measure line
      FMeasureLine.SetMeasurePoint(FMeasureLayerX, FMeasureLayerY, mpsFirst);
      FMeasureLine.SetMeasurePoint(FMeasureLayerX, FMeasureLayerY, mpsSecond);
      FMeasureLine.Draw(FMeasureLayer.Bitmap.Canvas, pmNotXor);
      FMeasureDrawingState := dsNewFigure;
    end;
    
    ShowMeasureResult;
  end;
end;

procedure TfrmChild.MeasureToolsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
var
  NewPoint       : TPoint;
  TranslateVector: TPoint;
  AColor         : TColor;
begin
  CalcLayerCoord(X, Y);  // get layer space coordinates

  if   Assigned(FMeasureLayer)
  then CalcMeasureLayerCoord(X, Y);  // get measure layer space coordinates

{ Move mouse when mouse left button down }

  if FDrawing then
  begin
    if Assigned(FMeasureLayer) then
    begin
      case FMeasureDrawingState of
        dsNewFigure:
          begin
            if Assigned(FMeasureLine) then
            begin
              // clear the old measure line
              FMeasureLine.Draw(FMeasureLayer.Bitmap.Canvas, pmNotXor);

              // change the measure points
              if   FMeasureLine.LineCount = 2
              then FMeasureLine.SetMeasurePoint(FMeasureLayerX, FMeasureLayerY, mpsSecond)
              else
              if   FMeasureLine.LineCount = 3
              then FMeasureLine.SetMeasurePoint(FMeasureLayerX, FMeasureLayerY, mpsThird);

              // draw the new measure line
              FMeasureLine.Draw(FMeasureLayer.Bitmap.Canvas, pmNotXor);
              FMeasureLayer.Bitmap.Changed;
              Screen.Cursor := crMeasureMove;
            end;
          end;

        dsStretchCorner:
          begin
            // clear the old measure line
            FMeasureLine.Draw(FMeasureLayer.Bitmap.Canvas, pmNotXor);

            // change the measure points
            FMeasureLine.SetMeasurePoint(FMeasureLayerX, FMeasureLayerY, FMeasurePointSelector);

            // draw the new measure line
            FMeasureLine.Draw(FMeasureLayer.Bitmap.Canvas, pmNotXor);
            FMeasureLayer.Bitmap.Changed;
            Screen.Cursor := crMeasureMove;
          end;

        dsTranslate:
          begin
            // clear the old measure line
            FMeasureLine.Draw(FMeasureLayer.Bitmap.Canvas, pmNotXor);

            // calculate the translating amount
            NewPoint        := Point(FMeasureLayerX, FMeasureLayerY);
            TranslateVector := SubtractPoints(NewPoint, FDrawingBasePoint);
            FMeasureLine.Translate(TranslateVector);

            // draw the new measure line
            FMeasureLine.Draw(FMeasureLayer.Bitmap.Canvas, pmNotXor);
            FMeasureLayer.Bitmap.Changed;

            // track the coordinates
            FDrawingBasePoint := NewPoint;
            Screen.Cursor     := crMeasureMove;
          end;
      end;

      ShowMeasureResult;

      if Assigned(FSelection) then
      begin
        imgDrawingArea.Update;
        DrawMarchingAnts;
      end;
    end;
  end
  else // change cursor when mouse left button not down
  begin
    if Assigned(FMeasureLayer) and Assigned(FMeasureLine) then
    begin
      FMeasurePointSelector := FMeasureLine.GetHandleAtPoint(FMeasureLayerX, FMeasureLayerY);

      if FMeasurePointSelector <> mpsNone then
      begin
        if ssAlt in Shift then
        begin
          if   FMeasureLine.LineCount = 2
          then Screen.Cursor := crMeasureAngle
          else Screen.Cursor := crMeasureMove;
        end
        else Screen.Cursor := crMeasureMove;
      end
      else
      if   FMeasureLine.ContainsPoint(FMeasureLayerX, FMeasureLayerY)
      then Screen.Cursor := crHandPoint
      else Screen.Cursor := crDefault;
    end;

    if  (FXActual >= 0) and (FXActual <= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width)
    and (FYActual >= 0) and (FYActual <= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height) then
    begin
      // showing the color info of the pixel that under the mouse pointer
      AColor := imgDrawingArea.Canvas.Pixels[X, Y];
      frmMain.ShowColorRGBInfoOnInfoViewer(AColor);
      frmMain.ShowColorCMYKInfoOnInfoViewer(AColor);
    end;
  end;

  // showing the current coordinates 
  frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
end;

procedure TfrmChild.MeasureToolsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
begin
{ Mouse left button up }

  if Button = mbLeft then
  begin
    if FDrawing then
    begin
      if Assigned(FMeasureLayer) then
      begin
        FMeasureDrawingState := dsNotDrawing;

        if Assigned(FSelection) then
        begin
          tmrMarchingAnts.Enabled := True;
        end;
      end;

      if Assigned(FMeasureLine) then
      begin
        if not frmMain.lblMeasureUnit.Enabled then
        begin
          frmMain.lblMeasureUnit.Enabled := True;
        end;

        if not frmMain.cmbbxMeasureUnit.Enabled then
        begin
          frmMain.cmbbxMeasureUnit.Enabled := True;
          frmMain.cmbbxMeasureUnit.Color   := clWindow;
        end;

        if not frmMain.btnClearMeasureInfo.Enabled then
        begin
          frmMain.btnClearMeasureInfo.Enabled := True;
        end;
      end;
    end;

    FDrawing      := False;   // finish the processing
    Screen.Cursor := crDefault;
  end;
end;

// translate Measure Line by keyboard stroke
procedure TfrmChild.TranslateMeasureKeyDown(var Key: Word; Shift: TShiftState);
var
  LTranslateVector: TPoint;
  LIncrement      : Integer;
begin
  if Key in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN] then
  begin
    if (frmMain.MainTool = gmtMeasure) and
       Assigned(FMeasureLine) and
       Assigned(FMeasureLayer) then
    begin
      if ssShift in Shift then
      begin
        LIncrement := 10;
      end
      else
      begin
        LIncrement := 1;
      end;

      case Key of
        VK_LEFT:
          begin
            LTranslateVector := Point(-LIncrement, 0);
          end;
          
        VK_UP:
          begin
            LTranslateVector := Point(0, -LIncrement);
          end;
          
        VK_RIGHT:
          begin
            LTranslateVector := Point(LIncrement, 0);
          end;

        VK_DOWN:
          begin
            LTranslateVector := Point(0, LIncrement);
          end;
      end;

      if tmrMarchingAnts.Enabled then
      begin
        tmrMarchingAnts.Enabled := False;
      end;

      // clear the old measure line
      FMeasureLine.Draw(FMeasureLayer.Bitmap.Canvas, pmNotXor);
      FMeasureLine.Translate(LTranslateVector);

      // draw the new measure line
      FMeasureLine.Draw(FMeasureLayer.Bitmap.Canvas, pmNotXor);
      FMeasureLayer.Bitmap.Changed;

      if Assigned(FSelection) then
      begin
        imgDrawingArea.Update;
        DrawMarchingAnts;
      end;

      ShowMeasureResult;
    end;
  end;
end;

procedure TfrmChild.TranslateMeasureKeyUp(var Key: Word; Shift: TShiftState);
begin
  if Key in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN] then
  begin
    if (frmMain.MainTool = gmtMeasure) and
       Assigned(FMeasureLine) and
       Assigned(FMeasureLayer) then
    begin
      if Assigned(FSelection) then
      begin
        if tmrMarchingAnts.Enabled = False then
        begin
          tmrMarchingAnts.Enabled := True;
        end;
      end;
    end;
  end;
end;

procedure TfrmChild.ShapeRegionToolsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  LShapeRegionLayerPanel: TgmShapeRegionLayerPanel;
begin
  CalcLayerCoord(X, Y); // get layer space coordinates

{ Mouse Left Button Down }

  if Button = mbLeft then
  begin
    // showing the coordinates info of the starting point and current point
    frmMain.ShowOriginalCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
    frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);

    case frmMain.ShapeRegionTool of
      srtMove:
        begin
          if FLayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
          begin
            if FShapeOutlineLayer <> nil then
            begin
              LShapeRegionLayerPanel :=
                TgmShapeRegionLayerPanel(FLayerPanelList.SelectedLayerPanel);

              if LShapeRegionLayerPanel.ShapeOutlineList.Count > 0 then
              begin
                FShapeDrawingHandle :=
                  LShapeRegionLayerPanel.ShapeOutlineList.GetHandlePoint(FXActual, FYActual, HANDLE_RADIUS);

                if FShapeDrawingHandle in [dhAxAy, dhBxBy, dhAxBy, dhBxAy,
                                           dhLeftHalfAyBy, dhRightHalfAyBy,
                                           dhTopHalfAxBx, dhBottomHalfAxBx] then
                begin
                  FShapeDrawingState    := dsStretchCorner;
                  Screen.Cursor         := SetCursorByHandle(FShapeDrawingHandle);
                  imgDrawingArea.Cursor := Screen.Cursor;
                  FShapeOutlineLayer.Bitmap.Clear($00000000);

                  if not LShapeRegionLayerPanel.IsDismissed then
                  begin
                    LShapeRegionLayerPanel.ShapeOutlineList.DrawAllOutlines(
                      FShapeOutlineLayer.Bitmap.Canvas, FOutlineOffsetVector, pmNotXor);
                  end;

                  LShapeRegionLayerPanel.ShapeOutlineList.DrawShapesBoundary(
                    FShapeOutlineLayer.Bitmap.Canvas, HANDLE_RADIUS,
                    FOutlineOffsetVector, pmNotXor);

                  FShapeOutlineLayer.Bitmap.Changed;

                  // Undo/Redo
                  FGlobalTopLeft     := LShapeRegionLayerPanel.ShapeOutlineList.FBoundaryTL;
                  FGlobalBottomRight := LShapeRegionLayerPanel.ShapeOutlineList.FBoundaryBR;
                end
                else
                begin
                  if LShapeRegionLayerPanel.ShapeOutlineList.PointInBoundary(
                       FXActual, FYActual, HANDLE_RADIUS) then
                  begin
                    FShapeDrawingState    := dsTranslate;
                    imgDrawingArea.Cursor := crDrag;
                    Screen.Cursor         := crDrag;
                    FShapeOutlineLayer.Bitmap.Clear($00000000);

                    if not LShapeRegionLayerPanel.IsDismissed then
                    begin
                      LShapeRegionLayerPanel.ShapeOutlineList.DrawAllOutlines(
                         FShapeOutlineLayer.Bitmap.Canvas, FOutlineOffsetVector,
                         pmNotXor);
                    end;

                    LShapeRegionLayerPanel.ShapeOutlineList.DrawShapesBoundary(
                      FShapeOutlineLayer.Bitmap.Canvas, HANDLE_RADIUS,
                      FOutlineOffsetVector, pmNotXor);

                    FShapeOutlineLayer.Bitmap.Changed;
                    FDrawingBasePoint := Point(FXActual, FYActual);

                    FAccumTranslateVector := Point(0, 0); // Undo/Redo
                  end;
                end;
              end;
            end;
          end;
        end;

      srtRectangle, srtRoundedRect, srtEllipse, srtPolygon, srtLine:
        begin
          with imgDrawingArea.Canvas do
          begin
            Pen.Color   := clBlack;
            Pen.Style   := psSolid;
            Pen.Width   := Round(imgDrawingArea.Scale);
            Pen.Mode    := pmNotXor;
            Brush.Style := bsClear;
          end;

          FActualStartPoint := Point(FXActual, FYActual);
          FActualEndPoint   := Point(FXActual, FYActual);

          FStartPoint := Point( FLayerTopLeft.X + MulDiv(FActualStartPoint.X, FMagnification, 100),
                                FLayerTopLeft.Y + MulDiv(FActualStartPoint.Y, FMagnification, 100) );

          FEndPoint := Point( FLayerTopLeft.X + MulDiv(FActualEndPoint.X, FMagnification, 100),
                              FLayerTopLeft.Y + MulDiv(FActualEndPoint.Y, FMagnification, 100) );

          // draw the "old" shape to let the OnMouseMove event to clear
          if frmMain.ShapeRegionTool = srtRectangle then
          begin
            DrawRectangle(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);
          end
          else
          if frmMain.ShapeRegionTool = srtRoundedRect then
          begin
            DrawRoundRect(imgDrawingArea.Canvas, FStartPoint, FEndPoint,
                          frmMain.ShapeCornerRadius, pmNotXor);
          end
          else
          if frmMain.ShapeRegionTool = srtEllipse then
          begin
            DrawEllipse(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);
          end
          else
          if frmMain.ShapeRegionTool = srtPolygon then
          begin
            DrawRegularPolygon(imgDrawingArea.Canvas, FStartPoint, FEndPoint,
                               frmMain.ShapePolygonSides, pmNotXor, DONOT_FILL_INSIDE);
          end
          else
          if frmMain.ShapeRegionTool = srtLine then
          begin
            DrawLineOutline(imgDrawingArea.Canvas, FStartPoint, FEndPoint,
                            frmMain.LineWeight, imgDrawingArea.Scale);
          end;
        end;
    end;
    
    FDrawing := True;
  end;
end;

procedure TfrmChild.ShapeRegionToolsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
var
  LNewPoint              : TPoint;
  LTranslateVector       : TPoint;
  LShapeRegionLayerPanel : TgmShapeRegionLayerPanel;
  LColor                 : TColor;
begin
  CalcLayerCoord(X, Y);  // get layer space coordinates

{ Move mouse when mouse left button down }

  if FDrawing then
  begin
    case FShapeDrawingState of
      dsNewFigure:
        begin
          case frmMain.ShapeRegionTool of
            srtRectangle:
              begin
                // clear the old shape
                DrawRectangle(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);

                if ssShift in Shift then
                begin
                  FActualEndPoint := CalculateRegularFigureEndPoint(
                    FActualStartPoint, Point(FXActual, FYActual) );
                end
                else
                begin
                  FActualEndPoint := Point(FXActual, FYActual);
                end;

                FEndPoint := Point( FLayerTopLeft.X + MulDiv(FActualEndPoint.X, FMagnification, 100),
                                    FLayerTopLeft.Y + MulDiv(FActualEndPoint.Y, FMagnification, 100) );

                // draw the new one
                DrawRectangle(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);
              end;
              
            srtRoundedRect:
              begin
                DrawRoundRect(imgDrawingArea.Canvas, FStartPoint, FEndPoint,
                              frmMain.ShapeCornerRadius, pmNotXor);

                if ssShift in Shift then
                begin
                  FActualEndPoint := CalculateRegularFigureEndPoint(
                    FActualStartPoint, Point(FXActual, FYActual) );
                end
                else
                begin
                  FActualEndPoint := Point(FXActual, FYActual);
                end;

                FEndPoint := Point( FLayerTopLeft.X + MulDiv(FActualEndPoint.X, FMagnification, 100),
                                    FLayerTopLeft.Y + MulDiv(FActualEndPoint.Y, FMagnification, 100) );

                DrawRoundRect(imgDrawingArea.Canvas, FStartPoint, FEndPoint,
                              frmMain.ShapeCornerRadius, pmNotXor);
              end;

            srtEllipse:
              begin
                DrawEllipse(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);

                if ssShift in Shift then
                begin
                  FActualEndPoint := CalculateRegularFigureEndPoint(
                    FActualStartPoint, Point(FXActual, FYActual) );
                end
                else
                begin
                  FActualEndPoint := Point(FXActual, FYActual);
                end;

                FEndPoint := Point( FLayerTopLeft.X + MulDiv(FActualEndPoint.X, FMagnification, 100),
                                    FLayerTopLeft.Y + MulDiv(FActualEndPoint.Y, FMagnification, 100) );

                DrawEllipse(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);
              end;

            srtPolygon:
              begin
                DrawRegularPolygon(imgDrawingArea.Canvas, FStartPoint, FEndPoint,
                                   frmMain.ShapePolygonSides, pmNotXor,
                                   DONOT_FILL_INSIDE);

                FActualEndPoint := Point(FXActual, FYActual);

                FEndPoint := Point( FLayerTopLeft.X + MulDiv(FActualEndPoint.X, FMagnification, 100),
                                    FLayerTopLeft.Y + MulDiv(FActualEndPoint.Y, FMagnification, 100) );

                DrawRegularPolygon(imgDrawingArea.Canvas, FStartPoint, FEndPoint,
                                   frmMain.ShapePolygonSides, pmNotXor, DONOT_FILL_INSIDE);
              end;

            srtLine:
              begin
                DrawLineOutline(imgDrawingArea.Canvas, FStartPoint, FEndPoint,
                                frmMain.LineWeight, imgDrawingArea.Scale);

                FActualEndPoint := Point(FXActual, FYActual);

                FEndPoint := Point( FLayerTopLeft.X + MulDiv(FActualEndPoint.X, FMagnification, 100),
                                    FLayerTopLeft.Y + MulDiv(FActualEndPoint.Y, FMagnification, 100) );

                DrawLineOutline(imgDrawingArea.Canvas, FStartPoint, FEndPoint,
                                frmMain.LineWeight, imgDrawingArea.Scale);
              end;
          end;
        end;

      dsTranslate:
        begin
          if FLayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
          begin
            if FShapeOutlineLayer <> nil then
            begin
              LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(FLayerPanelList.SelectedLayerPanel);

              if (LShapeRegionLayerPanel.ShapeOutlineList.Count > 0) and
                 Assigned(LShapeRegionLayerPanel.ShapeRegion) then
              begin
                if not LShapeRegionLayerPanel.IsDismissed then
                begin
                  LShapeRegionLayerPanel.ShapeOutlineList.DrawAllOutlines(
                    FShapeOutlineLayer.Bitmap.Canvas, FOutlineOffsetVector,
                    pmNotXor);
                end;

                LShapeRegionLayerPanel.ShapeOutlineList.DrawShapesBoundary(
                  FShapeOutlineLayer.Bitmap.Canvas, HANDLE_RADIUS,
                  FOutlineOffsetVector, pmNotXor);

                LNewPoint             := Point(FXActual, FYActual);
                LTranslateVector      := SubtractPoints(LNewPoint, FDrawingBasePoint);
                FAccumTranslateVector := AddPoints(FAccumTranslateVector, LTranslateVector);  // For Undo/Redo translate shape region.

                LShapeRegionLayerPanel.ShapeOutlineList.Translate(LTranslateVector);
                LShapeRegionLayerPanel.ShapeRegion.Translate(LTranslateVector);
                LShapeRegionLayerPanel.ShapeRegion.ShowRegion(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

                if not LShapeRegionLayerPanel.IsDismissed then
                begin
                  LShapeRegionLayerPanel.ShapeOutlineList.DrawAllOutlines(
                    FShapeOutlineLayer.Bitmap.Canvas, FOutlineOffsetVector,
                    pmNotXor);
                end;

                LShapeRegionLayerPanel.ShapeOutlineList.DrawShapesBoundary(
                  FShapeOutlineLayer.Bitmap.Canvas, HANDLE_RADIUS,
                  FOutlineOffsetVector, pmNotXor);

                if FLayerPanelList.SelectedLayerPanel.IsHasMask then
                begin
                  GetAlphaChannelBitmap(
                    FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                    FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                end;

                FLayerPanelList.SelectedLayerPanel.Update;

                FDrawingBasePoint := Point(FXActual, FYActual);
              end;
            end;
          end;
        end;

      dsStretchCorner:
        begin
          if FLayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
          begin
            if FShapeOutlineLayer <> nil then
            begin
              LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(FLayerPanelList.SelectedLayerPanel);

              if (LShapeRegionLayerPanel.ShapeOutlineList.Count > 0) and
                 Assigned(LShapeRegionLayerPanel.ShapeRegion) then
              begin
                if not LShapeRegionLayerPanel.IsDismissed then
                begin
                  LShapeRegionLayerPanel.ShapeOutlineList.DrawAllOutlines(
                    FShapeOutlineLayer.Bitmap.Canvas, FOutlineOffsetVector,
                    pmNotXor);
                end;

                LShapeRegionLayerPanel.ShapeOutlineList.DrawShapesBoundary(
                  FShapeOutlineLayer.Bitmap.Canvas, HANDLE_RADIUS,
                  FOutlineOffsetVector, pmNotXor);

                with LShapeRegionLayerPanel do
                begin
                  case FShapeDrawingHandle of
                    dhAxAy:
                      begin
                        ShapeOutlineList.FBoundaryTL := Point(FXActual, FYActual);
                      end;
                      
                    dhBxBy:
                      begin
                        ShapeOutlineList.FBoundaryBR := Point(FXActual, FYActual);
                      end;

                    dhAxBy:
                      begin
                        ShapeOutlineList.FBoundaryTL.X := FXActual;
                        ShapeOutlineList.FBoundaryBR.Y := FYActual;
                      end;

                    dhBxAy:
                      begin
                        ShapeOutlineList.FBoundaryTL.Y := FYActual;
                        ShapeOutlineList.FBoundaryBR.X := FXActual;
                      end;

                    dhTopHalfAxBx:
                      begin
                        ShapeOutlineList.FBoundaryTL.Y := FYActual;
                      end;
                      
                    dhBottomHalfAxBx:
                      begin
                        ShapeOutlineList.FBoundaryBR.Y := FYActual;
                      end;
                      
                    dhLeftHalfAyBy:
                      begin
                        ShapeOutlineList.FBoundaryTL.X := FXActual;
                      end;

                    dhRightHalfAyBy:
                      begin
                        ShapeOutlineList.FBoundaryBR.X := FXActual;
                      end;
                  end;
                  
                  ShapeOutlineList.BoundaryStandardizeOrder;
                  ShapeOutlineList.ScaleShapesCoordinates;
                  ShapeRegion.AccumRGN := LShapeRegionLayerPanel.ShapeOutlineList.GetScaledShapesRegion;
                  ShapeRegion.ShowRegion(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
                end;

                if not LShapeRegionLayerPanel.IsDismissed then
                begin
                  LShapeRegionLayerPanel.ShapeOutlineList.DrawAllOutlines(
                    FShapeOutlineLayer.Bitmap.Canvas, FOutlineOffsetVector,
                    pmNotXor);
                end;

                LShapeRegionLayerPanel.ShapeOutlineList.DrawShapesBoundary(
                  FShapeOutlineLayer.Bitmap.Canvas, HANDLE_RADIUS,
                  FOutlineOffsetVector, pmNotXor);

                if FLayerPanelList.SelectedLayerPanel.IsHasMask then
                begin
                  GetAlphaChannelBitmap(
                    FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                    FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                end;

                FLayerPanelList.SelectedLayerPanel.Update;
              end;
            end;
          end;
        end;
    end;
  end
  else // do OnMouseMove event when mouse left button not down
  begin
    if frmMain.ShapeRegionTool = srtMove then
    begin
      if FLayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
      begin
        LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(FLayerPanelList.SelectedLayerPanel);
        
        if LShapeRegionLayerPanel.ShapeOutlineList.Count > 0 then
        begin
          FShapeDrawingHandle :=
            LShapeRegionLayerPanel.ShapeOutlineList.GetHandlePoint(FXActual, FYActual, HANDLE_RADIUS);

          Screen.Cursor := SetCursorByHandle(FShapeDrawingHandle);

          if Screen.Cursor = crDefault then
          begin
            if frmMain.ShapeRegionTool = srtMove then
            begin
              imgDrawingArea.Cursor := crMoveSelection;
            end
            else
            begin
              case frmMain.RegionCombineMode of
                rcmAdd:
                  begin
                    imgDrawingArea.Cursor := crCrossAdd;
                  end;
                  
                rcmSubtract:
                  begin
                    imgDrawingArea.Cursor := crCrossSub;
                  end;
                  
                rcmIntersect:
                  begin
                    imgDrawingArea.Cursor := crCrossIntersect;
                  end;
                  
                rcmExcludeOverlap:
                  begin
                    imgDrawingArea.Cursor := crCrossInterSub;
                  end;
              end;
            end;
          end
          else
          begin
            imgDrawingArea.Cursor := Screen.Cursor;
          end;
        end;
      end;
    end;

    // showing the color info of the pixel that under the mouse pointer
    LColor := imgDrawingArea.Canvas.Pixels[X, Y];
    frmMain.ShowColorRGBInfoOnInfoViewer(LColor);
    frmMain.ShowColorCMYKInfoOnInfoViewer(LColor);
  end;

  // showing the coordinates info 
  frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
end; 

procedure TfrmChild.ShapeRegionToolsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  LOutline                 : TgmShapeOutline;
  LShapeRegionLayerPanel   : TgmShapeRegionLayerPanel;
  LWhetherCreateRegionLayer: Boolean;  // mark whether the shape region layer is created
  LHistoryStatePanel       : TgmHistoryStatePanel;
begin
  LShapeRegionLayerPanel := nil;

  CalcLayerCoord(X, Y);  // get layer space coordinates

{ Mouse left button up }

  if Button = mbLeft then
  begin
    LHistoryStatePanel := nil;

    if FDrawing then
    begin
      Screen.Cursor := crDefault;

      if frmMain.ShapeRegionTool = srtMove then
      begin
        imgDrawingArea.Cursor := crMoveSelection;
      end
      else
      begin
        case frmMain.RegionCombineMode of
          rcmAdd:
            begin
              imgDrawingArea.Cursor := crCrossAdd;
            end;
            
          rcmSubtract:
            begin
              imgDrawingArea.Cursor := crCrossSub;
            end;
            
          rcmIntersect:
            begin
              imgDrawingArea.Cursor := crCrossIntersect;
            end;
            
          rcmExcludeOverlap:
            begin
              imgDrawingArea.Cursor := crCrossInterSub;
            end;
        end;
      end;

      case FShapeDrawingState of
        dsNewFigure:
          begin
            LOutline := nil;

            if frmMain.ShapeRegionTool in [
                 srtRectangle, srtRoundedRect, srtEllipse] then
            begin
              if ssShift in Shift then
              begin
                FActualEndPoint := CalculateRegularFigureEndPoint(
                  FActualStartPoint, Point(FXActual, FYActual) );
              end
              else
              begin
                FActualEndPoint := Point(FXActual, FYActual);
              end;
            end
            else
            begin
              FActualEndPoint := Point(FXActual, FYActual);
            end;

            if (FActualStartPoint.X <> FActualEndPoint.X) or
               (FActualStartPoint.Y <> FActualEndPoint.Y) then
            begin
              LWhetherCreateRegionLayer := CreateShapeRegionLayer;

              if FLayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
              begin
                LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(FLayerPanelList.SelectedLayerPanel);

                case frmMain.ShapeRegionTool of
                  srtRectangle:
                    begin
                      LOutline            := TgmRectangleOutline.Create;
                      LOutline.StartPoint := FActualStartPoint;
                      LOutline.EndPoint   := FActualEndPoint;

                      LShapeRegionLayerPanel.ShapeRegion.NewRGN :=
                        CreateRectRGN(FActualStartPoint.X, FActualStartPoint.Y,
                                      FActualEndPoint.X, FActualEndPoint.Y);
                    end;

                  srtRoundedRect:
                    begin
                      LOutline            := TgmRoundRectOutline.Create;
                      LOutline.StartPoint := FActualStartPoint;
                      LOutline.EndPoint   := FActualEndPoint;

                      TgmRoundRectOutline(LOutline).CornerRadius := frmMain.ShapeCornerRadius;

                      LShapeRegionLayerPanel.ShapeRegion.NewRGN :=
                        CreateRoundRectRGN(FActualStartPoint.X,
                                           FActualStartPoint.Y,
                                           FActualEndPoint.X,
                                           FActualEndPoint.Y,
                                           frmMain.ShapeCornerRadius,
                                           frmMain.ShapeCornerRadius);
                    end;

                  srtEllipse:
                    begin
                      LOutline            := TgmEllipseOutline.Create;
                      LOutline.StartPoint := FActualStartPoint;
                      LOutline.EndPoint   := FActualEndPoint;

                      LShapeRegionLayerPanel.ShapeRegion.NewRGN :=
                        CreateEllipticRGN(FActualStartPoint.X, FActualStartPoint.Y,
                                          FActualEndPoint.X, FActualEndPoint.Y);
                    end;

                  srtPolygon:
                    begin
                      LOutline            := TgmRegularPolygonOutline.Create;
                      LOutline.StartPoint := FActualStartPoint;
                      LOutline.EndPoint   := FActualEndPoint;
                      
                      TgmRegularPolygonOutline(LOutline).Sides := frmMain.ShapePolygonSides;

                      TgmRegularPolygonOutline(LOutline).SetVertex;

                      CalcRegularPolygonVertices(FRegionPolygon,
                                                 FActualStartPoint,
                                                 FActualEndPoint,
                                                 frmMain.ShapePolygonSides);

                      LShapeRegionLayerPanel.ShapeRegion.NewRGN :=
                        CreatePolygonRGN(FRegionPolygon,
                                         frmMain.ShapePolygonSides,
                                         ALTERNATE);
                    end;

                  srtLine:
                    begin
                      LOutline                        := TgmLineOutline.Create;
                      LOutline.StartPoint             := FActualStartPoint;
                      LOutline.EndPoint               := FActualEndPoint;
                      TgmLineOutline(LOutline).Weight := frmMain.LineWeight;

                      TgmLineOutline(LOutline).SetVertex;
                      CalcVertexForLineRegionOutline;

                      LShapeRegionLayerPanel.ShapeRegion.NewRGN :=
                        CreatePolygonRGN(FRegionPolygon, 4, ALTERNATE);
                    end;
                end;

                if Assigned(LOutline) then
                begin
                  LOutline.CombineMode := frmMain.RegionCombineMode;
                  
                  LShapeRegionLayerPanel.ShapeOutlineList.Add(LOutline);
                  LShapeRegionLayerPanel.ShapeOutlineList.GetShapesBoundary;
                end;
                
                LShapeRegionLayerPanel.ShapeRegion.CombineRGNToAccumRGN(
                  frmMain.RegionCombineMode);

                LShapeRegionLayerPanel.ShapeRegion.ShowRegion(
                  FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
                  
                LShapeRegionLayerPanel.UpdateRegionThumbnial;

                if FShapeOutlineLayer = nil then
                begin
                  CreateShapeOutlineLayer;
                end;

                CalcShapeOutlineLayerOffsetVector;
                FShapeOutlineLayer.Bitmap.Clear($00000000);

                if not LShapeRegionLayerPanel.IsDismissed then
                begin
                  LShapeRegionLayerPanel.ShapeOutlineList.DrawAllOutlines(
                    FShapeOutlineLayer.Bitmap.Canvas, FOutlineOffsetVector,
                    pmNotXor);
                end;

                if LShapeRegionLayerPanel.IsHasMask then
                begin
                  GetAlphaChannelBitmap(
                    FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                    FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                end;

                FLayerPanelList.SelectedLayerPanel.Update;
                frmMain.UpdateShapeOptions;
              end;

              // Undo/Redo
              if LWhetherCreateRegionLayer then
              begin
                LHistoryStatePanel := TgmShapeRegionLayerStatePanel.Create(
                  frmHistory.scrlbxHistory,
                  dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
                  FLayerPanelList.CurrentIndex,
                  LShapeRegionLayerPanel,
                  rctCreateRegionLayer,
                  LOutline);
              end
              else
              begin
                LHistoryStatePanel := TgmShapeRegionLayerStatePanel.Create(
                  frmHistory.scrlbxHistory,
                  dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
                  FLayerPanelList.CurrentIndex,
                  LShapeRegionLayerPanel,
                  rctAddRegion,
                  LOutline);
              end;
            end;
          end;

        dsTranslate, dsStretchCorner:
          begin
            if FLayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
            begin
              if FShapeOutlineLayer <> nil then
              begin
                LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(FLayerPanelList.SelectedLayerPanel);

                if (LShapeRegionLayerPanel.ShapeOutlineList.Count > 0) and
                   Assigned(LShapeRegionLayerPanel.ShapeRegion) then
                begin
                  FShapeOutlineLayer.Bitmap.Clear($00000000);

                  if not LShapeRegionLayerPanel.IsDismissed then
                  begin
                    LShapeRegionLayerPanel.ShapeOutlineList.DrawAllOutlines(
                      FShapeOutlineLayer.Bitmap.Canvas, FOutlineOffsetVector,
                      pmNotXor);
                  end;

                  LShapeRegionLayerPanel.ShapeOutlineList.DrawShapesBoundary(
                    FShapeOutlineLayer.Bitmap.Canvas, HANDLE_RADIUS,
                    FOutlineOffsetVector, pmNotXor);

                  LShapeRegionLayerPanel.ShapeOutlineList.DrawShapesBoundaryHandles(
                    FShapeOutlineLayer.Bitmap.Canvas, HANDLE_RADIUS,
                    FOutlineOffsetVector, pmNotXor);

                  FShapeOutlineLayer.Bitmap.Changed;
                  LShapeRegionLayerPanel.UpdateRegionThumbnial;
                end;
              end;
            end;

            // Undo/Redo
            if FShapeDrawingState = dsTranslate then
            begin
              LHistoryStatePanel := TgmTranslateShapeRegionStatePanel.Create(
                frmHistory.scrlbxHistory,
                dmHistory.bmp32lstHistory.Bitmap[MOVE_OBJECTS_COMMAND_ICON_INDEX],
                FAccumTranslateVector);
            end
            else if FShapeDrawingState = dsStretchCorner then
            begin
              LHistoryStatePanel := TgmScaleShapeRegionStatePanel.Create(
                frmHistory.scrlbxHistory,
                dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
                FGlobalTopLeft,
                FGlobalBottomRight,
                LShapeRegionLayerPanel.ShapeOutlineList.FBoundaryTL,
                LShapeRegionLayerPanel.ShapeOutlineList.FBoundaryBR);
            end;

            FShapeDrawingState := dsNotDrawing;
          end;
      end;
    end;

    FDrawing := False; // finish processing

    if imgDrawingArea.Canvas.Pen.Mode <> pmCopy then
    begin
      imgDrawingArea.Canvas.Pen.Mode := pmCopy;
    end;

    if Assigned(LHistoryStatePanel) then
    begin
      FHistoryManager.AddHistoryState(LHistoryStatePanel);
    end;
  end;
end; 

procedure TfrmChild.TranslateShapeRegionKeyDown(
  var Key: Word; Shift: TShiftState);
var
  LTranslateVector       : TPoint;
  LIncrement             : Integer;
  LShapeRegionLayerPanel : TgmShapeRegionLayerPanel;
begin
  if Key in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN] then
  begin
    if (frmMain.MainTool = gmtShape) and
       (FLayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion) then
    begin
      LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(FLayerPanelList.SelectedLayerPanel);

      if (LShapeRegionLayerPanel.ShapeOutlineList.Count > 0) and
         Assigned(LShapeRegionLayerPanel.ShapeRegion) then
      begin
        if ssShift in Shift then
        begin
          LIncrement := 10;
        end
        else
        begin
          LIncrement := 1;
        end;

        case Key of
          VK_LEFT:
            begin
              LTranslateVector := Point(-LIncrement, 0);
            end;
            
          VK_UP:
            begin
              LTranslateVector := Point(0, -LIncrement);
            end;
            
          VK_RIGHT:
            begin
              LTranslateVector := Point(LIncrement, 0);
            end;
            
          VK_DOWN:
            begin
              LTranslateVector := Point(0, LIncrement);
            end;
        end;

        // For Undo/Redo
        if FKeyIsDown = False then
        begin
          FAccumTranslateVector := Point(0, 0);
          FKeyIsDown := True;
        end;

        FAccumTranslateVector := AddPoints(FAccumTranslateVector, LTranslateVector);

        // translate shape regions
        if tmrMarchingAnts.Enabled = True then
        begin
          tmrMarchingAnts.Enabled := False;
        end;

        FShapeOutlineLayer.Bitmap.Clear($00000000);

        LShapeRegionLayerPanel.ShapeOutlineList.Translate(LTranslateVector);
        LShapeRegionLayerPanel.ShapeRegion.Translate(LTranslateVector);
        LShapeRegionLayerPanel.ShapeRegion.ShowRegion(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

        if not LShapeRegionLayerPanel.IsDismissed then
        begin
          LShapeRegionLayerPanel.ShapeOutlineList.DrawAllOutlines(
            FShapeOutlineLayer.Bitmap.Canvas, FOutlineOffsetVector, pmNotXor);
        end;

        if frmMain.ShapeRegionTool = srtMove then
        begin
          LShapeRegionLayerPanel.ShapeOutlineList.DrawShapesBoundary(
            FShapeOutlineLayer.Bitmap.Canvas, HANDLE_RADIUS,
            FOutlineOffsetVector, pmNotXor);

          LShapeRegionLayerPanel.ShapeOutlineList.DrawShapesBoundaryHandles(
            FShapeOutlineLayer.Bitmap.Canvas, HANDLE_RADIUS,
            FOutlineOffsetVector, pmNotXor);
        end;
        
        if FLayerPanelList.SelectedLayerPanel.IsHasMask then
        begin
          GetAlphaChannelBitmap(
            FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
            FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
        end;

        FLayerPanelList.SelectedLayerPanel.Update;

        if Assigned(FSelection) then
        begin
          imgDrawingArea.Update;
          DrawMarchingAnts;
        end;
      end;
    end;
  end;
end; 

procedure TfrmChild.TranslateShapeRegionKeyUp(var Key: Word; Shift: TShiftState);
var
  LShapeRegionLayerPanel: TgmShapeRegionLayerPanel;
  LHistoryStatePanel    : TgmHistoryStatePanel;
begin
  if Key in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN] then
  begin
    if (frmMain.MainTool = gmtShape) and
       (FLayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion) then
    begin
      LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(FLayerPanelList.SelectedLayerPanel);
      LShapeRegionLayerPanel.UpdateRegionThumbnial;

      if Assigned(FSelection) then
      begin
        if tmrMarchingAnts.Enabled = False then
        begin
          tmrMarchingAnts.Enabled := True;
        end;
      end;
    end;

    // Undo/Redo
    LHistoryStatePanel := TgmTranslateShapeRegionStatePanel.Create(
      frmHistory.scrlbxHistory,
      dmHistory.bmp32lstHistory.Bitmap[MOVE_OBJECTS_COMMAND_ICON_INDEX],
      FAccumTranslateVector);

    FHistoryManager.AddHistoryState(LHistoryStatePanel);
  end;
end; 

procedure TfrmChild.TransformSelectionMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
begin
  CalcTransformLayerCoord(X, Y);  // get transform layer space coordinates

  if Assigned(FSelectionTransformation) then
  begin
    FLastTransformMode := FSelectionTransformation.TransformMode;

    case FSelectionTransformation.TransformMode of
       tmDistort:
        begin
          FTransformHandle := FSelectionTransformation.GetHandleAtPoint(FTransformLayerX, FTransformLayerY, SELECTION_HANDLE_RADIUS);

          if FTransformHandle <> dhNone then
          begin
            FDrawingBasePoint       := Point(FTransformLayerX, FTransformLayerY);
            tmrMarchingAnts.Enabled := False;
            FDrawing                := True;
            Screen.Cursor           := crMovePath;
            imgDrawingArea.Cursor   := crMovePath;
          end
          else
          if FSelectionTransformation.PointOnSelectionBody(FTransformLayerX, FTransformLayerY) then
          begin
            FDrawingBasePoint       := Point(FTransformLayerX, FTransformLayerY);
            tmrMarchingAnts.Enabled := False;
            FDrawing                := True;
            Screen.Cursor           := crHandGrip;
            imgDrawingArea.Cursor   := crHandGrip;

            FSelectionTransformation.TransformMode := tmTranslate;
          end
          else
          begin
            Screen.Cursor         := crDefault;
            imgDrawingArea.Cursor := crMoveSelection;
          end;
        end;

      tmRotate:
        begin
          if FSelectionTransformation.PointOnSelectionBody(FTransformLayerX, FTransformLayerY) then
          begin
            FDrawingBasePoint       := Point(FTransformLayerX, FTransformLayerY);
            tmrMarchingAnts.Enabled := False;
            FDrawing                := True;
            Screen.Cursor           := crHandGrip;
            imgDrawingArea.Cursor   := crHandGrip;

            FSelectionTransformation.TransformMode := tmTranslate;
          end
          else
          begin
            FRotateRadiansInMouseDown := ArcTan2(FTransformLayerY - FSelectionTransformation.SelectionCenterCoord.Y,
                                                 FTransformLayerX - FSelectionTransformation.SelectionCenterCoord.X);
            tmrMarchingAnts.Enabled   := False;
            FDrawing                  := True;
          end;
        end;

      tmScale:
        begin
          FTransformHandle := FSelectionTransformation.GetHandleAtPoint(FTransformLayerX, FTransformLayerY, SELECTION_HANDLE_RADIUS);

          if FTransformHandle <> dhNone then
          begin
            FDrawingBasePoint       := Point(FTransformLayerX, FTransformLayerY);
            tmrMarchingAnts.Enabled := False;
            FDrawing                := True;
            Screen.Cursor           := SetCursorByHandle(FTransformHandle);
            imgDrawingArea.Cursor   := Screen.Cursor;
          end
          else
          if FSelectionTransformation.PointOnSelectionBody(FTransformLayerX, FTransformLayerY) then
          begin
            FDrawingBasePoint       := Point(FTransformLayerX, FTransformLayerY);
            tmrMarchingAnts.Enabled := False;
            FDrawing                := True;
            Screen.Cursor           := crHandGrip;
            imgDrawingArea.Cursor   := crHandGrip;

            FSelectionTransformation.TransformMode := tmTranslate;
          end
          else
          begin
            Screen.Cursor         := crDefault;
            imgDrawingArea.Cursor := crMoveSelection;
          end;
        end;
    end;

    // Undo/Redo
    if FTransformCopy = nil then
    begin
      FTransformCopy := TgmSelectionTransformation.Create(FSelection);
    end;
    
    FTransformCopy.AssignTransformData(FSelectionTransformation);
  end;
end;

procedure TfrmChild.TransformSelectionMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
var
  LNewPoint, LTranslateVector : TPoint;
  LRadiansIncrement, LRadians : Extended;
begin
  CalcLayerCoord(X, Y);
  CalcTransformLayerCoord(X, Y);

  if FDrawing then
  begin
    // erasing the old outline
    FSelectionTransformation.DrawOutline(FTransformLayer.Bitmap.Canvas,
                                         FTransformOffsetVector, pmNotXor);

    case FSelectionTransformation.TransformMode of
      tmDistort:
        begin
          // calculte the offset vector
          LNewPoint        := Point(FTransformLayerX, FTransformLayerY);
          LTranslateVector := SubtractPoints(LNewPoint, FDrawingBasePoint);

          // change the vertices of the transformation by the offset vector
          FSelectionTransformation.ChangeVertices_Distort(LTranslateVector, FTransformHandle);
        end;

      tmRotate:
        begin
          FRotateRadiansInMouseMove :=
            ArcTan2(FTransformLayerY - FSelectionTransformation.SelectionCenterCoord.Y,
                    FTransformLayerX - FSelectionTransformation.SelectionCenterCoord.X);

          LRadiansIncrement := FRotateRadiansInMouseMove - FRotateRadiansInMouseDown;
          FSelectionTransformation.ChangeVertices_Rotate(LRadiansIncrement);

          Screen.Cursor         := GetCursorByDegree( RadToDeg(FRotateRadiansInMouseMove) );
          imgDrawingArea.Cursor := Screen.Cursor;
        end;

      tmScale:
        begin
          LNewPoint        := Point(FTransformLayerX, FTransformLayerY);
          LTranslateVector := SubtractPoints(LNewPoint, FDrawingBasePoint);

          FSelectionTransformation.ChangeVertices_Scale(LTranslateVector, FTransformHandle);
        end;

      tmTranslate:
        begin
          LNewPoint        := Point(FTransformLayerX, FTransformLayerY);
          LTranslateVector := SubtractPoints(LNewPoint, FDrawingBasePoint);

          FSelectionTransformation.TranslateVertices(LTranslateVector);
        end;
    end;

    FSelectionTransformation.ExecuteTransform;

    // indicating that we are doing the transformation now
    if not FSelectionTransformation.IsTransforming then
    begin
      FSelectionTransformation.IsTransforming := True;
    end;
    
    case FChannelManager.CurrentChannelType of
      wctAlpha:
        begin
          if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
          begin
            FSelectionTransformation.ShowTransformedSelection(
              FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
              FChannelManager.ChannelSelectedSet);
          end;
        end;

      wctQuickMask:
        begin
          FSelectionTransformation.ShowTransformedSelection(
            FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
            FChannelManager.ChannelSelectedSet);
        end;

      wctLayerMask:
        begin
          FSelectionTransformation.ShowTransformedSelection(
            FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
            FChannelManager.ChannelSelectedSet);

          if Assigned(FChannelManager.LayerMaskPanel) then
          begin
            if FChannelManager.LayerMaskPanel.IsChannelVisible then
            begin
              FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(0, 0,
                FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
            end;
          end;
        end;

      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          FSelectionTransformation.ShowTransformedSelection(
            FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
            FChannelManager.ChannelSelectedSet);
        end;
    end;

    FSelectionTransformation.DrawOutline(FTransformLayer.Bitmap.Canvas,
                                         FTransformOffsetVector, pmNotXor);

    // showing the result of the transformation
    case FChannelManager.CurrentChannelType of
      wctAlpha:
        begin
          if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
          begin
            FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
          end;
        end;

      wctQuickMask:
        begin
          FChannelManager.QuickMaskPanel.AlphaLayer.Changed;
        end;
        
      wctLayerMask:
        begin
          FLayerPanelList.SelectedLayerPanel.Update;
        end;

      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          if FLayerPanelList.SelectedLayerPanel.IsHasMask then
          begin
            GetAlphaChannelBitmap(
              FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
              FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
          end;

          FLayerPanelList.SelectedLayerPanel.Update;
        end;
    end;

    imgDrawingArea.Update;
    DrawMarchingAnts;
    FDrawingBasePoint := LNewPoint;
  end
  else
  begin
    if Assigned(FSelectionTransformation) then
    begin
      case FSelectionTransformation.TransformMode of
        tmDistort:
          begin
            if FSelectionTransformation.GetHandleAtPoint(FTransformLayerX,
                                                         FTransformLayerY,
                                                         SELECTION_HANDLE_RADIUS) <> dhNone then
            begin
              Screen.Cursor         := crMovePath;
              imgDrawingArea.Cursor := crMovePath;
            end
            else
            if FSelectionTransformation.PointOnSelectionBody(FTransformLayerX, FTransformLayerY) then
            begin
              Screen.Cursor         := crHandLoosen;
              imgDrawingArea.Cursor := crHandLoosen;
            end
            else
            begin
              Screen.Cursor         := crDefault;
              imgDrawingArea.Cursor := crMoveSelection;
            end;
          end;

        tmRotate:
          begin
            if FSelectionTransformation.PointOnSelectionBody(FTransformLayerX, FTransformLayerY) then
            begin
              Screen.Cursor         := crHandLoosen;
              imgDrawingArea.Cursor := crHandLoosen;
            end
            else
            begin
              LRadians := ArcTan2(FTransformLayerY - FSelectionTransformation.SelectionCenterCoord.Y,
                                  FTransformLayerX - FSelectionTransformation.SelectionCenterCoord.X);

              Screen.Cursor         := GetCursorByDegree( RadToDeg(LRadians) );
              imgDrawingArea.Cursor := Screen.Cursor;
            end;
          end;

        tmScale:
          begin
            FTransformHandle := FSelectionTransformation.GetHandleAtPoint(
              FTransformLayerX, FTransformLayerY, SELECTION_HANDLE_RADIUS);

            if FTransformHandle <> dhNone then
            begin
              Screen.Cursor         := SetCursorByHandle(FTransformHandle);
              imgDrawingArea.Cursor := Screen.Cursor;
            end
            else
            if FSelectionTransformation.PointOnSelectionBody(FTransformLayerX, FTransformLayerY) then
            begin
              Screen.Cursor         := crHandLoosen;
              imgDrawingArea.Cursor := crHandLoosen;
            end
            else
            begin
              Screen.Cursor         := crDefault;
              imgDrawingArea.Cursor := crMoveSelection;
            end;
          end;
      end;
    end;
  end;

  // showing the coordinates info
  frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
end; 

procedure TfrmChild.TransformSelectionMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  HistoryStatePanel: TgmHistoryStatePanel;
begin
  if FDrawing then
  begin
    tmrMarchingAnts.Enabled := True;
    FDrawing                := False;
    FImageProcessed         := True;

    // update thumbnails
    case FChannelManager.CurrentChannelType of
      wctAlpha:
        begin
          if Assigned(FChannelManager.SelectedAlphaChannelPanel)
          then FChannelManager.SelectedAlphaChannelPanel.UpdateThumbnail;
        end;

      wctQuickMask: FChannelManager.QuickMaskPanel.UpdateThumbnail;

      wctLayerMask:
        begin
          FLayerPanelList.SelectedLayerPanel.UpdateMaskThumbnail;
          
          if Assigned(FChannelManager.LayerMaskPanel) then
          begin
            FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(0, 0, FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
            FChannelManager.LayerMaskPanel.UpdateThumbnail;
          end;

          if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
               lfBackground, lfTransparent] then
          begin
            FLayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
          end;

          FChannelManager.UpdateColorChannelThumbnails(FLayerPanelList);
        end;

      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
               lfBackground, lfTransparent] then
          begin
            FLayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
          end;

          FChannelManager.UpdateColorChannelThumbnails(FLayerPanelList);
        end;
    end;

    if Assigned(FSelectionTransformation) then
    begin
      // Undo/Redo
      HistoryStatePanel := TgmTransformStatePanel.Create(
        frmHistory.scrlbxHistory,
        dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
        tctAdjust,
        FSelectionTransformation.TransformMode,
        FSelection,
        FTransformCopy,
        FSelectionTransformation);

      FHistoryManager.AddHistoryState(HistoryStatePanel);

      if Assigned(FTransformCopy) then
      begin
        FreeAndNil(FTransformCopy);
      end;

      { We changed the transform mode to tmTranslate at some point,
        so we need to restore it back to tmScale, tmDistort or tmRotate. }
      FSelectionTransformation.TransformMode := FLastTransformMode;

      if FSelectionTransformation.TransformMode = tmRotate then
      begin
        TgmSelectionRotate(FSelectionTransformation).UpdateRotateState;
      end;
    end;
  end;
end;

procedure TfrmChild.TextToolsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  IsRichTextLayer   : Boolean;
  PointOnTextBorder : Boolean;
  PointOnTextHandle : Boolean;
  RichTextLayerPanel: TgmRichTextLayerPanel;
begin
  CalcLayerCoord(X, Y);  // get layer space coordinates

{ Mouse left button down }

  if Button = mbLeft then
  begin
    // showing the coordinates of the starting and current point
    frmMain.ShowOriginalCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
    frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);

    with imgDrawingArea.Canvas do
    begin
      Pen.Color   := RUBBER_BAND_PEN_COLOR;
      Pen.Style   := RUBBER_BAND_PEN_STYLE;
      Pen.Width   := RUBBER_BAND_PEN_WIDTH;
      Brush.Color := RUBBER_BAND_BRUSH_COLOR;
      Brush.Style := RUBBER_BAND_BRUSH_STYLE;
    end;

    IsRichTextLayer    := False;
    PointOnTextBorder  := False;
    PointOnTextHandle  := False;
    RichTextLayerPanel := nil;
    
    if FLayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
    begin
      RichTextLayerPanel     := TgmRichTextLayerPanel(FLayerPanelList.SelectedLayerPanel);
      IsRichTextLayer        := True;
      PointOnTextBorder      := RichTextLayerPanel.ContainsPoint( Point(FXActual, FYActual) );
      FRichTextDrawingHandle := RichTextLayerPanel.GetHandleAtPoint(FXActual, FYActual);
      PointOnTextHandle      := (FRichTextDrawingHandle <> dhNone);
    end;

    if IsRichTextLayer and (PointOnTextHandle or PointOnTextBorder) then
    begin
      if not frmRichTextEditor.Visible then
      begin
        RichTextLayerPanel.RichTextStream.Position := 0;
        frmRichTextEditor.rchedtRichTextEditor.Lines.LoadFromStream(RichTextLayerPanel.RichTextStream);
      end;
      
      if PointOnTextHandle then
      begin
        // 1.  Trying to stretch corner of selected figure?
        Screen.Cursor         := SetCursorByHandle(FRichTextDrawingHandle);
        FRichTextDrawingState := dsStretchCorner;

        // Undo/Redo
        FGlobalTopLeft     := RichTextLayerPanel.BorderStart;
        FGlobalBottomRight := RichTextLayerPanel.BorderEnd;
      end
      else
      // 2.  Trying to translate selected figure(s)? Check first for existing set of selected figures.
      if PointOnTextBorder then
      begin
        Screen.Cursor         := crDrag;
        FRichTextDrawingState := dsTranslate;
        FDrawingBasePoint     := Point(FXActual, FYActual);
        FAccumTranslateVector := Point(0, 0); // Undo/Redo
      end;

      if FRichTextHandleLayer <> nil then
      begin
        FRichTextHandleLayer.Bitmap.Clear($00000000);

        if   RichTextLayerPanel <> nil
        then RichTextLayerPanel.DrawRichTextBorder(FRichTextHandleLayer.Bitmap.Canvas,
                                                   FRichTextHandleLayerOffsetVector);
        FRichTextHandleLayer.Bitmap.Changed;
      end;
    end
    else
    begin
      Screen.Cursor := crCross;

      FStartPoint := Point( FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100),
                            FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100) );

      FEndPoint         := FStartPoint;
      FActualStartPoint := Point(FXActual, FYActual);
      
      DrawRectangle(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);
      FRichTextDrawingState := dsNewFigure;
    end;
    
    FDrawing := True;
  end;
end;

procedure TfrmChild.TextToolsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
var
  LRichTextLayerPanel         : TgmRichTextLayerPanel;
  LNewPoint, LTranslateVector : TPoint;
  LColor                      : TColor;
begin
  CalcLayerCoord(X, Y);

{ Move mouse when mouse left button down }

  if FDrawing then
  begin
    case FRichTextDrawingState of
      dsStretchCorner:
        begin
          LRichTextLayerPanel := TgmRichTextLayerPanel(FLayerPanelList.SelectedLayerPanel);

          if FRichTextHandleLayer <> nil then
          begin
            LRichTextLayerPanel.DrawRichTextBorder(FRichTextHandleLayer.Bitmap.Canvas,
                                                   FRichTextHandleLayerOffsetVector);
          end;

          with LRichTextLayerPanel do
          begin
            case FRichTextDrawingHandle of
              dhAxAy:
                begin
                  BorderStart := Point(FXActual, FYActual);
                end;

              dhBxBy:
                begin
                  BorderEnd := Point(FXActual, FYActual);
                end;

              dhAxBy:
                begin
                  BorderStart := Point(FXActual, BorderStart.Y);
                  BorderEnd   := Point(BorderEnd.X, FYActual);
                end;

              dhBxAy:
                begin
                  BorderStart := Point(BorderStart.X, FYActual);
                  BorderEnd   := Point(FXActual, BorderEnd.Y);
                end;
                
              dhTopHalfAxBx:
                begin
                  BorderStart := Point(BorderStart.X, FYActual);
                end;

              dhBottomHalfAxBx:
                begin
                  BorderEnd := Point(BorderEnd.X, FYActual);
                end;

              dhLeftHalfAyBy:
                begin
                  BorderStart := Point(FXActual, BorderStart.Y);
                end;

              dhRightHalfAyBy:
                begin
                  BorderEnd := Point(FXActual, BorderEnd.Y);
                end;
            end;
          end;

          LRichTextLayerPanel.StandardizeOrder;
          FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Clear($00FFFFFF);
          
          DrawRichTextOnBitmap(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                               LRichTextLayerPanel.BorderRect,
                               frmRichTextEditor.rchedtRichTextEditor);

          if FRichTextHandleLayer <> nil then
          begin
            LRichTextLayerPanel.DrawRichTextBorder(FRichTextHandleLayer.Bitmap.Canvas,
                                                   FRichTextHandleLayerOffsetVector);
          end;

          if FLayerPanelList.SelectedLayerPanel.IsHasMask then
          begin
            GetAlphaChannelBitmap(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                                  FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
          end;

          FLayerPanelList.SelectedLayerPanel.Update;
        end;

      dsTranslate:
        begin
          LRichTextLayerPanel := TgmRichTextLayerPanel(FLayerPanelList.SelectedLayerPanel);

          if FRichTextHandleLayer <> nil then
          begin
            LRichTextLayerPanel.DrawRichTextBorder(FRichTextHandleLayer.Bitmap.Canvas,
                                                   FRichTextHandleLayerOffsetVector);
          end;

          LNewPoint        := Point(FXActual, FYActual);
          LTranslateVector := SubtractPoints(LNewPoint, FDrawingBasePoint);

          // For Undo/Redo translate Text region.
          FAccumTranslateVector := AddPoints(FAccumTranslateVector, LTranslateVector);  

          LRichTextLayerPanel.Translate(LTranslateVector);

          FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Clear($00FFFFFF);
          
          DrawRichTextOnBitmap(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                               LRichTextLayerPanel.BorderRect,
                               frmRichTextEditor.rchedtRichTextEditor);

          if FRichTextHandleLayer <> nil then
          begin
            LRichTextLayerPanel.DrawRichTextBorder(FRichTextHandleLayer.Bitmap.Canvas,
                                                   FRichTextHandleLayerOffsetVector);
          end;

          if FLayerPanelList.SelectedLayerPanel.IsHasMask then
          begin
            GetAlphaChannelBitmap(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                                  FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
          end;

          FLayerPanelList.SelectedLayerPanel.Update;

          FDrawingBasePoint := LNewPoint;
        end;

      dsNewFigure:
        begin
          DrawRectangle(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);

          FEndPoint := Point( FLayerTopLeft.X + MulDiv(FXActual, FMagnification, 100),
                              FLayerTopLeft.Y + MulDiv(FYActual, FMagnification, 100));

          DrawRectangle(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);
        end;
    end;
  end
  else // if the FDrawing = False
  begin
    if FLayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
    begin
      LRichTextLayerPanel    := TgmRichTextLayerPanel(FLayerPanelList.SelectedLayerPanel);
      FRichTextDrawingHandle := LRichTextLayerPanel.GetHandleAtPoint(FXActual, FYActual);
      Screen.Cursor          := SetCursorByHandle(FRichTextDrawingHandle);
    end;

    if (FXActual >= 0) and
       (FYActual >= 0) and
       (FXActual <= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width) and
       (FYActual <= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height) then
    begin
      // showing the color info of the pixel that under the mouse pointer
      LColor := imgDrawingArea.Canvas.Pixels[X, Y];
      
      frmMain.ShowColorRGBInfoOnInfoViewer(LColor);
      frmMain.ShowColorCMYKInfoOnInfoViewer(LColor);
    end;
  end;

  imgDrawingArea.Canvas.Pen.Mode := pmCopy;
  frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual); 
end; 

procedure TfrmChild.TextToolsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  RichTextLayerPanel: TgmRichTextLayerPanel;
  HistoryStatePanel : TgmHistoryStatePanel;
begin
  CalcLayerCoord(X, Y);

{ Move mouse when mouse left button down }

  if FDrawing then
  begin
    if FRichTextDrawingState in [dsTranslate, dsStretchCorner] then
    begin
      RichTextLayerPanel := TgmRichTextLayerPanel(FLayerPanelList.SelectedLayerPanel);
      Screen.Cursor      := crDefault;
      
      if FRichTextHandleLayer <> nil then
      begin
        RichTextLayerPanel.DrawRichTextBorderHandles(FRichTextHandleLayer.Bitmap.Canvas,
                                                     FRichTextHandleLayerOffsetVector);
        FRichTextHandleLayer.Bitmap.Changed;
      end;

      if frmRichTextEditor.Visible = False then
      begin
        // Undo/Redo
        HistoryStatePanel := nil;

        if FRichTextDrawingState = dsTranslate then
        begin
          HistoryStatePanel := TgmTranslateTextRegionStatePanel.Create(
            frmHistory.scrlbxHistory,
            dmHistory.bmp32lstHistory.Bitmap[MOVE_OBJECTS_COMMAND_ICON_INDEX],
            FLayerPanelList.CurrentIndex,
            FAccumTranslateVector);
        end
        else
        if FRichTextDrawingState = dsStretchCorner then
        begin
          HistoryStatePanel := TgmScaleTextRegionStatePanel.Create(
            frmHistory.scrlbxHistory,
            dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
            FLayerPanelList.CurrentIndex,
            FGlobalTopLeft,
            FGlobalBottomRight,
            RichTextLayerPanel.BorderStart,
            RichTextLayerPanel.BorderEnd);
        end;

        if Assigned(HistoryStatePanel) then
        begin
          FHistoryManager.AddHistoryState(HistoryStatePanel);
        end;
      end;
    end
    else
    if FRichTextDrawingState = dsNewFigure then
    begin
      // If we are editing a text layer now, then save the current text layer and create a new one
      if frmRichTextEditor.Visible then
      begin
        CommitEdits;
      end;

      Screen.Cursor   := crDefault;
      FActualEndPoint := Point(FXActual, FYActual);
      
      PointStandardizeOrder(FActualStartPoint, FActualEndPoint);

      { If the starting point and the ending point are same, change the ending
        point, make the input area is same as default size of an TEdit component. }
      if SameCoordinate(FActualStartPoint, FActualEndPoint) then
      begin
        FActualEndPoint.X := FXActual + 121;
        FActualEndPoint.Y := FYActual + 21;
      end;

      CreateRichTextLayer;

      if FRichTextHandleLayer = nil then
      begin
        CreateRichTextHandleLayer;
      end;

      if FLayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
      begin
        RichTextLayerPanel := TgmRichTextLayerPanel(FLayerPanelList.SelectedLayerPanel);
        RichTextLayerPanel.SetRichTextBorder(FActualStartPoint, FActualEndPoint);

        FRichTextHandleLayer.Bitmap.Clear($00000000);

        RichTextLayerPanel.DrawRichTextBorder(FRichTextHandleLayer.Bitmap.Canvas,
                                              FRichTextHandleLayerOffsetVector);

        RichTextLayerPanel.DrawRichTextBorderHandles(FRichTextHandleLayer.Bitmap.Canvas,
                                                     FRichTextHandleLayerOffsetVector);
        FRichTextHandleLayer.Bitmap.Changed;

        // Open Rich Text Editor
        frmRichTextEditor.Width  := RichTextLayerPanel.BorderWidth  + 14;
        frmRichTextEditor.Height := RichTextLayerPanel.BorderHeight + frmRichTextEditor.stsbrTextInfo.Height + 44;

        frmRichTextEditor.rchedtRichTextEditor.Clear;
        frmRichTextEditor.Show;
        frmMain.UpdateTextOptions;
      end;
    end;

    FDrawing                       := False;  // finish the processing
    imgDrawingArea.Canvas.Pen.Mode := pmCopy;
    FRichTextDrawingState          := dsNotDrawing;
  end;
end; 

// translate Text by keyboard stroke
procedure TfrmChild.TranslateTextKeyDown(var Key: Word; Shift: TShiftState);
var
  LTranslateVector : TPoint;
  LIncrement       : Integer;
  LTextLayerPanel  : TgmRichTextLayerPanel;
begin
  if Key in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN] then
  begin
    if (frmMain.MainTool = gmtTextTool) and
       (FLayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText) then
    begin
      if ssShift in Shift then
      begin
        LIncrement := 10;
      end
      else
      begin
        LIncrement := 1;
      end;

      case Key of
        VK_LEFT:
          begin
            LTranslateVector := Point(-LIncrement, 0);
          end;
          
        VK_UP:
          begin
            LTranslateVector := Point(0, -LIncrement);
          end;
          
        VK_RIGHT:
          begin
            LTranslateVector := Point(LIncrement, 0);
          end;
          
        VK_DOWN:
          begin
            LTranslateVector := Point(0, LIncrement);
          end;
      end;

      // For Undo/Redo
      if FKeyIsDown = False then
      begin
        FAccumTranslateVector := Point(0, 0);
        FKeyIsDown := True;
      end;

      FAccumTranslateVector := AddPoints(FAccumTranslateVector, LTranslateVector);

      // translate text
      if tmrMarchingAnts.Enabled then
      begin
        tmrMarchingAnts.Enabled := False;
      end;

      LTextLayerPanel := TgmRichTextLayerPanel(FLayerPanelList.SelectedLayerPanel);

      if FRichTextHandleLayer <> nil then
      begin
        LTextLayerPanel.DrawRichTextBorder(FRichTextHandleLayer.Bitmap.Canvas,
                                           FRichTextHandleLayerOffsetVector);

        LTextLayerPanel.DrawRichTextBorderHandles(FRichTextHandleLayer.Bitmap.Canvas,
                                                  FRichTextHandleLayerOffsetVector);
      end;

      LTextLayerPanel.Translate(LTranslateVector);

      if not frmRichTextEditor.Visible then
      begin
        if frmRichTextEditor.rchedtRichTextEditor.Lines.Count = 0 then
        begin
          LTextLayerPanel.RichTextStream.Position := 0;
          frmRichTextEditor.rchedtRichTextEditor.Lines.LoadFromStream(LTextLayerPanel.RichTextStream);
        end;
      end;

      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Clear($00FFFFFF);
      
      DrawRichTextOnBitmap(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                           LTextLayerPanel.BorderRect,
                           frmRichTextEditor.rchedtRichTextEditor);

      if FRichTextHandleLayer <> nil then
      begin
        LTextLayerPanel.DrawRichTextBorder(FRichTextHandleLayer.Bitmap.Canvas,
                                           FRichTextHandleLayerOffsetVector);

        LTextLayerPanel.DrawRichTextBorderHandles(FRichTextHandleLayer.Bitmap.Canvas,
                                                  FRichTextHandleLayerOffsetVector);
      end;

      if FLayerPanelList.SelectedLayerPanel.IsHasMask then
      begin
        GetAlphaChannelBitmap(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                              FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
      end;

      FLayerPanelList.SelectedLayerPanel.Update;

      if Assigned(FSelection) then
      begin
        imgDrawingArea.Update;
        DrawMarchingAnts;
      end;
    end;
  end;
end; 

procedure TfrmChild.TranslateTextKeyUp(var Key: Word; Shift: TShiftState);
var
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  if Key in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN] then
  begin
    if (frmMain.MainTool = gmtTextTool) and
       (FLayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText) then
    begin
      if not frmRichTextEditor.Visible then
      begin
        frmRichTextEditor.rchedtRichTextEditor.Clear;
      end;

      if Assigned(FSelection) then
      begin
        if not tmrMarchingAnts.Enabled then
        begin
          tmrMarchingAnts.Enabled := True;
        end;
      end;
    end;

    if not frmRichTextEditor.Visible then
    begin
      // Undo/Redo
      LHistoryStatePanel := TgmTranslateTextRegionStatePanel.Create(
        frmHistory.scrlbxHistory,
        dmHistory.bmp32lstHistory.Bitmap[MOVE_OBJECTS_COMMAND_ICON_INDEX],
        FLayerPanelList.CurrentIndex,
        FAccumTranslateVector);

      FHistoryManager.AddHistoryState(LHistoryStatePanel);
    end;
  end;
end;

{ events for Eyedropper tool }

procedure TfrmChild.EyedropperMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
begin
  CalcLayerCoord(X, Y); // get layer space coordinates

{ Mouse left button down }

  if Button = mbLeft then
  begin
    // showing the coordinates of starting point
    frmMain.ShowOriginalCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
    frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);

    case FChannelManager.CurrentChannelType of
      wctAlpha:
        begin
          if Assigned(FChannelManager.SelectedAlphaChannelPanel)
          then frmColor.ggbrRValue.Position := 255 - GetRValue(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Canvas.Pixels[FXActual, FYActual]);
        end;

      wctQuickMask:
        begin
          if Assigned(FChannelManager.QuickMaskPanel)
          then frmColor.ggbrRValue.Position := 255 - GetRValue(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.Canvas.Pixels[FXActual, FYActual]);
        end;

      wctLayerMask:
        frmColor.ggbrRValue.Position := 255 - GetRValue(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Canvas.Pixels[FXActual, FYActual]);

      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          if csRed in FChannelManager.ChannelSelectedSet
          then frmColor.ggbrRValue.Position := GetRValue(imgDrawingArea.Canvas.Pixels[X, Y]);

          if csGreen in FChannelManager.ChannelSelectedSet
          then frmColor.ggbrGValue.Position := GetGValue(imgDrawingArea.Canvas.Pixels[X, Y]);

          if csBlue in FChannelManager.ChannelSelectedSet
          then frmColor.ggbrBValue.Position := GetBValue(imgDrawingArea.Canvas.Pixels[X, Y]);
        end;
    end;

    FDrawing := True;
  end;
end;

procedure TfrmChild.EyedropperMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
var
  LColor: TColor;
begin
  CalcLayerCoord(X, Y);  // get layer space coordinates

{ Move mouse when mouse left button down }

  if FDrawing then
  begin
    case FChannelManager.CurrentChannelType of
      wctAlpha:
        begin
          if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
          begin
            frmColor.ggbrRValue.Position :=
              255 - GetRValue(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Canvas.Pixels[FXActual, FYActual]);
          end;
        end;

      wctQuickMask:
        begin
          if Assigned(FChannelManager.QuickMaskPanel) then
          begin
            frmColor.ggbrRValue.Position :=
              255 - GetRValue(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.Canvas.Pixels[FXActual, FYActual]);
          end;
        end;

      wctLayerMask:
        begin
          frmColor.ggbrRValue.Position :=
            255 - GetRValue(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Canvas.Pixels[FXActual, FYActual]);
        end;

      wctRGB, wctRed, wctGreen, wctBlue:
        begin
{$RANGECHECKS OFF}
          if csRed in FChannelManager.ChannelSelectedSet then
          begin
            frmColor.ggbrRValue.Position := GetRValue(imgDrawingArea.Canvas.Pixels[X, Y]);
          end;

          if csGreen in FChannelManager.ChannelSelectedSet then
          begin
            frmColor.ggbrGValue.Position := GetGValue(imgDrawingArea.Canvas.Pixels[X, Y]);
          end;

          if csBlue in FChannelManager.ChannelSelectedSet then
          begin
            frmColor.ggbrBValue.Position := GetBValue(imgDrawingArea.Canvas.Pixels[X, Y]);
          end;
{$RANGECHECKS ON}
        end;
    end;
  end
  else
  begin
    if (FXActual >= 0) and
       (FYActual >= 0) and
       (FXActual <= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width) and
       (FYActual <= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height) then
    begin
      // showing color info
      LColor := imgDrawingArea.Canvas.Pixels[X, Y];

      frmMain.ShowColorRGBInfoOnInfoViewer(LColor);
      frmMain.ShowColorCMYKInfoOnInfoViewer(LColor);
    end;
  end;

  // showing current layer coordinates
  frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
end;

procedure TfrmChild.EyedropperMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
begin
{ Mouse left button up }

  if Button = mbLeft then
  begin
    if FDrawing then
    begin
      FDrawing := False;
    end;
  end;
end; 

{ events for Hand tool }

procedure TfrmChild.HandToolMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
begin
  CalcLayerCoord(X, Y); // get layer space coordinates

{ Mouse left button down }

  if Button = mbLeft then
  begin
    // showing the coordinates of starting point
    frmMain.ShowOriginalCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
    frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);

    Screen.Cursor                   := crHandGrip;
    FStartPoint                     := Point(X, Y);
    FEndPoint                       := Point(X, Y);
    imgDrawingArea.Canvas.Pen.Width := 1;
    imgDrawingArea.Canvas.Pen.Color := clBlack;
    imgDrawingArea.Canvas.Pen.Style := psSolid;

    DrawStraightLine(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);

    FDrawing := True;
  end;
end;

procedure TfrmChild.HandToolMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
var
  LColor: TColor;
begin
  CalcLayerCoord(X, Y);  // get layer space coordinates

{ Move mouse when mouse left button down }

  if FDrawing then
  begin
    Screen.Cursor := crHandGrip;
    // clear the old line
    DrawStraightLine(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);

    FEndPoint := Point(X, Y);
    DrawStraightLine(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);
  end
  else
  begin
    if (FXActual >= 0) and
       (FYActual >= 0) and
       (FXActual <= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width) and
       (FYActual <= FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height) then
    begin
      // showing color info
      LColor := imgDrawingArea.Canvas.Pixels[X, Y];

      frmMain.ShowColorRGBInfoOnInfoViewer(LColor);
      frmMain.ShowColorCMYKInfoOnInfoViewer(LColor);
    end;
  end;

  imgDrawingArea.Canvas.Pen.Mode := pmCopy;
  
  // showing current layer coordinates
  frmMain.ShowCurrentCoordInfoOnInfoViewerInPixel(FXActual, FYActual);
end;

procedure TfrmChild.HandToolMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  dx, dy: Integer;
begin
  CalcLayerCoord(X, Y);  // get layer space coordinates

{ Mouse left button up }

  if Button = mbLeft then
  begin
    if FDrawing then
    begin
      FDrawing      := False;
      Screen.Cursor := crDefault;
      dx            := FEndPoint.X - FStartPoint.X;
      dy            := FEndPoint.Y - FStartPoint.Y;

      imgDrawingArea.Scroll(dx, dy);

      FLayerTopLeft := GetLayerTopLeft;
      DrawStraightLine(imgDrawingArea.Canvas, FStartPoint, FEndPoint, pmNotXor);
    end;

    imgDrawingArea.Canvas.Pen.Mode := pmCopy;
  end;
end;

// udpate corresponding thumbnail depending on which channel is selected
procedure TfrmChild.UpdateThumbnailsBySelectedChannel;
begin
  case FChannelManager.CurrentChannelType of
    wctAlpha:
      begin
        if Assigned(FChannelManager.SelectedAlphaChannelPanel)
        then FChannelManager.SelectedAlphaChannelPanel.UpdateThumbnail;
      end;

    wctQuickMask:
      begin
        if Assigned(FChannelManager.QuickMaskPanel)
        then FChannelManager.QuickMaskPanel.UpdateThumbnail;
      end;

    wctLayerMask:
      begin
        FLayerPanelList.SelectedLayerPanel.UpdateMaskThumbnail;
        FLayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;

        if Assigned(FChannelManager.LayerMaskPanel) then
        begin
          FChannelManager.LayerMaskPanel.UpdateThumbnail;
        end;

        if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
             lfBackground, lfTransparent] then
        begin
          FLayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
        end;
        
        FChannelManager.UpdateColorChannelThumbnails(FLayerPanelList);
      end;

    wctRGB, wctRed, wctGreen, wctBlue:
      begin
        if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
             lfBackground, lfTransparent] then
        begin
          FLayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
        end;

        FChannelManager.UpdateColorChannelThumbnails(FLayerPanelList);
      end;
  end;
end;

procedure TfrmChild.SetupOnChildFormActivate;
var
  LShapeRegionLayerPanel: TgmShapeRegionLayerPanel;
  LRichTextLayerPanel   : TgmRichTextLayerPanel;
begin
  if frmMain.ChildFormIsCreating then
  begin
    Exit;
  end;

  if ActiveChildForm <> nil then
  begin
    if ActiveChildForm <> Self then
    begin
      // hide the layer and path panels from previous child form
      if Assigned(ActiveChildForm.FSelection) then
      begin
        ActiveChildForm.tmrMarchingAnts.Enabled := False;
      end;

      if ActiveChildForm.FLayerPanelList.Count > 0 then
      begin
        ActiveChildForm.FLayerPanelList.HideAllLayerPanels;
      end;

      if ActiveChildForm.FPathPanelList.Count > 0 then
      begin
        ActiveChildForm.FPathPanelList.HideAllPathPanels;
      end;

      ActiveChildForm.FHistoryManager.HideAllPanels;
      ActiveChildForm.FChannelManager.HideAllChannelPanels;

      // save the text from previous child form
      if frmRichTextEditor.Visible then
      begin
        ActiveChildForm.CommitEdits;
      end;
    end;
  end;

  PrevChildForm   := ActiveChildForm;  // remember the old active child form
  ActiveChildForm := Self;             // force ActiveChildForm points to current active child form

  Self.LayerPanelList.IsAllowRefreshLayerPanels   := frmLayer.IsShowingUp;
  Self.ChannelManager.IsAllowRefreshChannelPanels := frmChannel.IsShowingUp;
  Self.PathPanelList.IsAllowRefreshPathPanels     := frmPath.IsShowingUp;
  Self.HistoryManager.IsAllowRefreshPanels        := frmHistory.IsShowingUp;

  // update the appearance of the color window
  if FLayerPanelList.SelectedLayerPanel <> nil then
  begin
    if FChannelManager.CurrentChannelType in [wctAlpha, wctQuickMask, wctLayerMask] then
    begin
      frmColor.ColorMode := cmGrayscale;
    end
    else
    begin
      frmColor.ColorMode := cmRGB;  // must be on layer
    end;
  end;

  if (FLayerPanelList.Count > 0) and
     FLayerPanelList.IsAllowRefreshLayerPanels then
  begin
    FLayerPanelList.ShowAllLayerPanels;
  end;

  if FChannelManager.IsAllowRefreshChannelPanels then
  begin
    FChannelManager.ShowAllChannelPanels;
  end;

  if (FPathPanelList.Count > 0) and
     FPathPanelList.IsAllowRefreshPathPanels then
  begin
    FPathPanelList.ShowAllPathPanels;
  end;

  if FHistoryManager.IsAllowRefreshPanels then
  begin
    FHistoryManager.ShowAllPanelsByRightOrder;
  end;

  // connect mouse event handle
  if Assigned(FSelectionTransformation) then
  begin
    ConnectTransformMouseEvents;
  end
  else
  begin
    ConnectMouseEventsToImage;
  end;

  if Assigned(FSelection) then
  begin
    tmrMarchingAnts.Enabled := True;
  end;

  // showing the magnification of the current image
  frmMain.CanChange := False;
  try
    frmMain.ggbrZoomSlider.Position := FMagnification;
  finally
    frmMain.CanChange := True;
  end;

  if Assigned(FLayerPanelList.SelectedLayerPanel) then
  begin
    frmLayer.cmbbxLayerBlendMode.ItemIndex := FLayerPanelList.SelectedLayerPanel.BlendModeIndex;
    frmLayer.ggbrLayerOpacity.Position     := FLayerPanelList.SelectedLayerPanel.LayerMasterAlpha;
  end;

  // initialze the status bar of the main form when the child form is activated 
  frmMain.stsbrMain.Panels[0].Text := GetBitmapDimensionString(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

  // if current tool is not any of the Standard tools, then clear the movable figures
  if frmMain.MainTool <> gmtStandard then
  begin
    // deselect all the movable figures
    if FLayerPanelList.SelectedFigureCount > 0 then
    begin
      RecordOldFigureSelectedData;
      FLayerPanelList.DeselectAllFiguresOnFigureLayer;
      CreateSelectFigureUndoRedo(sfmDeselect);
    end;

    DeleteFigureHandleLayer;
  end
  else
  begin
    if frmMain.StandardTool <> gstMoveObjects then
    begin
      // deselect all the movable figures
      if FLayerPanelList.SelectedFigureCount > 0 then
      begin
        RecordOldFigureSelectedData;
        FLayerPanelList.DeselectAllFiguresOnFigureLayer;
        CreateSelectFigureUndoRedo(sfmDeselect);
      end;
      
      DeleteFigureHandleLayer;
    end;
  end;

  // finish Magnetic Lasso if the current tool is not Magnetic Lasso Tool
  if Assigned(FMagneticLasso) then
  begin
    if (frmMain.MainTool <> gmtMarquee) or
       (frmMain.MarqueeTool <> mtMagneticLasso) then
    begin
      FinishMagneticLasso;
    end;
  end;

  // if the current tool is Marquee tool...
  if frmMain.MainTool = gmtMarquee then
  begin
    if frmMain.MarqueeTool = mtMoveResize then
    begin
      // identify not to draw the selection
      FMarqueeDrawingState := dsNotDrawing;
    end
    else
    begin
      // identify draw new selection
      FMarqueeDrawingState := dsNewFigure;
    end;

    // if the selection is already exists, updating the selection border
    if Assigned(FSelection) then
    begin
      Self.UpdateSelectionHandleBorder;
    end;
  end
  else
  begin
    // if current tool is not marquee tool, then delete the handle layer
    DeleteSelectionHandleLayer;
  end;


  // if the current tool is Crop tool...
  if frmMain.MainTool = gmtCrop then
  begin
    if FCrop <> nil then
    begin
      frmMain.shpCroppedShieldColor.Brush.Color  := FCrop.ShieldWinColor;
      frmMain.updwnCroppedShieldOpacity.Position := FCrop.ShieldOpacity;
      frmMain.chckbxShieldCroppedArea.Checked    := FCrop.IsShieldCroppedArea;

      frmMain.CanChange := False;
      try
        frmMain.edtCropWidth.Text  := IntToStr(FCrop.CropAreaWidth);
        frmMain.edtCropHeight.Text := IntToStr(FCrop.CropAreaHeight);
      finally
        frmMain.CanChange := True;
      end;
    end
    else
    begin
      frmMain.edtCropWidth.Text  := '';
      frmMain.edtCropHeight.Text := '';
    end;
  end
  else
  begin
    FinishCrop;
  end;

  // if current tool is not Measure tool, then delete the measure line and its layer
  if frmMain.MainTool <> gmtMeasure then
  begin
    DeleteMeasureLine;
  end;

  // if the current tool is Shape Region tool...
  if frmMain.MainTool = gmtShape then
  begin
    CreateShapeOutlineLayer;
    FShapeOutlineLayer.Bitmap.Clear($00000000);

    if frmMain.ShapeRegionTool = srtMove then
    begin
      FShapeDrawingState := dsNotDrawing;

      if FLayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
      begin
        LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(FLayerPanelList.SelectedLayerPanel);
        LShapeRegionLayerPanel.ShapeOutlineList.BackupCoordinates;

        with LShapeRegionLayerPanel do
        begin
          ShapeOutlineList.DrawAllOutlines(FShapeOutlineLayer.Bitmap.Canvas,
                                           FOutlineOffsetVector, pmNotXor);

          ShapeOutlineList.DrawShapesBoundary(FShapeOutlineLayer.Bitmap.Canvas,
                                              HANDLE_RADIUS,
                                              FOutlineOffsetVector,
                                              pmNotXor);

          ShapeOutlineList.DrawShapesBoundaryHandles(FShapeOutlineLayer.Bitmap.Canvas,
                                                     HANDLE_RADIUS,
                                                     FOutlineOffsetVector,
                                                     pmNotXor);
        end;
      end
      else
      begin
        DeleteShapeOutlineLayer;
      end;
    end
    else
    begin
      FShapeDrawingState := dsNewFigure;
      
      if FLayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
      begin
        LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(
          FLayerPanelList.SelectedLayerPanel);

        with LShapeRegionLayerPanel do
        begin
          ShapeOutlineList.DrawAllOutlines(FShapeOutlineLayer.Bitmap.Canvas,
                                           FOutlineOffsetVector, pmNotXor);
        end;
      end
      else
      begin
        DeleteShapeOutlineLayer;
      end;
    end;
  end
  else
  begin
    if Assigned(FLayerPanelList.SelectedLayerPanel) then
    begin
      if FLayerPanelList.SelectedLayerPanel.LayerFeature <> lfShapeRegion then
      begin
        DeleteShapeOutlineLayer;
      end;
    end;
  end;

  // if current tool is Text tool...
  if frmMain.MainTool = gmtTextTool then
  begin
    if FLayerPanelList.SelectedLayerPanel <> nil then
    begin
      if FLayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
      begin
        CreateRichTextHandleLayer;
        FRichTextHandleLayer.Bitmap.Clear($00000000);
        
        LRichTextLayerPanel := TgmRichTextLayerPanel(FLayerPanelList.SelectedLayerPanel);
        
        with LRichTextLayerPanel do
        begin
          DrawRichTextBorder(FRichTextHandleLayer.Bitmap.Canvas,
                             FRichTextHandleLayerOffsetVector);

          DrawRichTextBorderHandles(FRichTextHandleLayer.Bitmap.Canvas,
                                    FRichTextHandleLayerOffsetVector);
        end;
      end
      else
      begin
        DeleteRichTextHandleLayer;
      end;
    end;
  end
  else
  begin
    DeleteRichTextHandleLayer;
  end;

  // if current tool is not Magnetic Lasso tool...
  if Assigned(FMagneticLasso) then
  begin
    if (frmMain.MainTool <> gmtMarquee) or
       (frmMain.MarqueeTool <> mtMagneticLasso) then
    begin
      FinishMagneticLasso;
    end;
  end;

  ChangeImageCursorByToolTemplets;
  frmMain.UpdateToolsOptions;
  frmLayer.UpdateLayerOptionsEnableStatus;
  frmLayer.UpdateLayerOptions(FLayerPanelList.SelectedLayerPanel);
  frmPath.UpdatePathOptions;
end; 

// apply mask to specified area of current layer,
// the ARect must be in bitmap coordinate space
procedure TfrmChild.ApplyMask(const ARect: TRect);
var
  LRefreshArea: TRect;
begin
  if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
  begin
    ChangeAlphaChannelBySubMask(
      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
      FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
      FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap, ARect);
  end;

  // bitmap coordinate space to control coordinate space
  LRefreshArea.TopLeft     := imgDrawingArea.BitmapToControl(ARect.TopLeft);
  LRefreshArea.BottomRight := imgDrawingArea.BitmapToControl(ARect.BottomRight);
  
  FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(LRefreshArea);
end; 

// apply mask to specified layer
procedure TfrmChild.ApplyMaskByIndex(const AIndex: Integer);
var
  LayerPanel: TgmLayerPanel;
begin
  LayerPanel := FLayerPanelList.GetLayerPanelByIndex(AIndex);

  if Assigned(LayerPanel) then
  begin
    if LayerPanel.IsMaskLinked
    then ChangeAlphaChannelBySubMask(LayerPanel.AssociatedLayer.Bitmap,
                                     LayerPanel.FLastAlphaChannelBmp,
                                     LayerPanel.FMaskImage.Bitmap);

    LayerPanel.AssociatedLayer.Changed;
  end;
end;

// confirm to save the image when exit the program
procedure TfrmChild.BeforeExit(Sender: TObject);
begin
  // if the image has been modified...
  if FImageProcessed then
  begin
    // if the image has a filename, then confirm to save the file
    if FFileName <> '' then
    begin
      case MessageDlg(Format('Save change to %s ?', [ExtractFileName(FFileName)]),
                      mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
        mrYes:
          begin
            frmMain.SaveFile(Sender);
          end;

        mrCancel:
          begin
            Self.Activate;  // make the ActiveChildForm global variable points to me again
            Abort;
          end;
      end;
    end
    else // if the image has no a filename, then confirm to save the new file
    begin
      case MessageDlg(Format('Save change to %s ?', ['Untitled']),
                      mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
        mrYes:
          begin
            frmMain.SaveFileAs(Sender);
          end;
          
        mrCancel:
          begin
            Self.Activate; // make the ActiveChildForm global variable points to me again
            Abort;
          end;
      end;
    end;
  end;
end;

procedure TfrmChild.InitializeCanvas;
begin
  with imgDrawingArea.Canvas do
  begin
    { If color of pen/brush is white, when PenMode is pmNotXor,
      we couldn't see the drawing process. }
    Pen.Color   := clBlack;
    Pen.Width   := frmMain.GlobalPenWidth;
    Pen.Style   := frmMain.GlobalPenStyle;
    Brush.Color := clBlack;
    Brush.Style := frmMain.GlobalBrushStyle;
  end;

  if Assigned(FSelection) then
  begin
    with FSelection.CutOriginal.Canvas do
    begin
      Pen.Width   := frmMain.GlobalPenWidth;
      Pen.Style   := frmMain.GlobalPenStyle;
      Brush.Style := frmMain.GlobalBrushStyle;

      case FChannelManager.CurrentChannelType of
        wctAlpha, wctQuickMask, wctLayerMask:
          begin
            Pen.Color   := frmMain.ForeGrayColor;
            Brush.Color := frmMain.BackGrayColor;
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            Pen.Color   := frmMain.GlobalForeColor;
            Brush.Color := frmMain.GlobalBackColor;
          end;
      end;
    end;
  end
  else
  begin
    case FChannelManager.CurrentChannelType of
      wctAlpha:
        begin
          if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
          begin
            with FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Canvas do
            begin
              Pen.Color   := frmMain.ForeGrayColor;
              Pen.Style   := frmMain.GlobalPenStyle;
              Pen.Width   := frmMain.GlobalPenWidth;
              Brush.Color := frmMain.BackGrayColor;
              Brush.Style := frmMain.GlobalBrushStyle;
            end;
          end;
        end;

      wctQuickMask:
        begin
          if Assigned(FChannelManager.QuickMaskPanel) then
          begin
            with FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.Canvas do
            begin
              Pen.Color   := frmMain.ForeGrayColor;
              Pen.Style   := frmMain.GlobalPenStyle;
              Pen.Width   := frmMain.GlobalPenWidth;
              Brush.Color := frmMain.BackGrayColor;
              Brush.Style := frmMain.GlobalBrushStyle;
            end;
          end;
        end;

      wctLayerMask:
        begin
          with FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Canvas do
          begin
            Pen.Color   := frmMain.ForeGrayColor;
            Pen.Style   := frmMain.GlobalPenStyle;
            Pen.Width   := frmMain.GlobalPenWidth;
            Brush.Color := frmMain.BackGrayColor;
            Brush.Style := frmMain.GlobalBrushStyle;
          end;
        end;

      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          with FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Canvas do
          begin
            Pen.Color   := frmMain.GlobalForeColor;
            Pen.Width   := frmMain.GlobalPenWidth;
            Pen.Style   := frmMain.GlobalPenStyle;
            Brush.Color := frmMain.GlobalBackColor;
            Brush.Style := frmMain.GlobalBrushStyle;
          end;

          with FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp.Canvas do
          begin
            Pen.Color := clWhite;
            Pen.Width := frmMain.GlobalPenWidth;

            if frmMain.GlobalBrushStyle = bsSolid then
            begin
              Pen.Style := psSolid;
            end
            else
            begin
              Pen.Style := frmMain.GlobalPenStyle;
            end;

            Brush.Color := clWhite;
            Brush.Style := frmMain.GlobalBrushStyle;
          end;
        end;
    end;
  end;

  with FLayerPanelList.SelectedLayerPanel.ProcessedPart.Canvas do
  begin
    Pen.Color := clWhite;
    Pen.Width := frmMain.GlobalPenWidth;

    if frmMain.GlobalBrushStyle = bsSolid then
    begin
      Pen.Style := psSolid;
    end
    else
    begin
      Pen.Style := frmMain.GlobalPenStyle;
    end;

    Brush.Color := clWhite;
    Brush.Style := frmMain.GlobalBrushStyle;
  end;
end;

procedure TfrmChild.PreparePencil;
var
  FGColor, BKColor: TColor32;
begin
  FGColor := $0;
  BKColor := $0;

  if frmMain.GlobalPenStyle <> psSolid then
  begin
    case FChannelManager.CurrentChannelType of
      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          FGColor := Color32(frmMain.GlobalForeColor);

          if frmMain.GlobalBrushStyle = bsSolid then
          begin
            BKColor := Color32(frmMain.GlobalBackColor);
          end
          else
          begin
            BKColor := $0;
          end;
        end;

      wctAlpha, wctQuickMask, wctLayerMask:
        begin
          FGColor := Color32(frmMain.ForeGrayColor);

          if frmMain.GlobalBrushStyle = bsSolid then
          begin
            BKColor := Color32(frmMain.BackGrayColor);
          end
          else
          begin
            BKColor := $0;
          end;
        end;
    end;
  end;

  if Assigned(FSelection) then
  begin
    case FChannelManager.CurrentChannelType of
      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          FSelection.CutOriginal.PenColor := Color32(frmMain.GlobalForeColor);
        end;

      wctAlpha, wctQuickMask, wctLayerMask:
        begin
          FSelection.CutOriginal.PenColor := Color32(frmMain.ForeGrayColor);
        end;
    end;

    if frmMain.GlobalPenStyle <> psSolid then
    begin
      SetPencilStipplePattern(FSelection.CutOriginal, frmMain.GlobalPenStyle,
                              FGColor, BKColor);

      { The following code is very odd, it should draws a white solid line,
        not a stippled line. But we can't without this line, otherwise,
        the channels of processed part could not be mixed. }
      if FChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue] then
      begin
        SetPencilStipplePattern(FLayerPanelList.SelectedLayerPanel.ProcessedPart,
                                frmMain.GlobalPenStyle, clWhite32, clWhite32);
      end;
    end;

    // used to track the processed part
    FLayerPanelList.SelectedLayerPanel.ProcessedPart.SetSize(
      FSelection.CutOriginal.Width, FSelection.CutOriginal.Height);
      
    FLayerPanelList.SelectedLayerPanel.ProcessedPart.Clear(clBlack32);
    FLayerPanelList.SelectedLayerPanel.ProcessedPart.PenColor := clWhite32;
  end
  else
  begin
    case FChannelManager.CurrentChannelType of
      wctAlpha:
        begin
          FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.PenColor := Color32(frmMain.ForeGrayColor);

          if frmMain.GlobalPenStyle <> psSolid then
          begin
            SetPencilStipplePattern(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                                    frmMain.GlobalPenStyle, FGColor, BKColor);
          end;
        end;

      wctQuickMask:
        begin
          FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.PenColor := Color32(frmMain.ForeGrayColor);

          if frmMain.GlobalPenStyle <> psSolid then
          begin
            SetPencilStipplePattern(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                                    frmMain.GlobalPenStyle, FGColor, BKColor);
          end;
        end;

      wctLayerMask:
        begin
          FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.PenColor := Color32(frmMain.ForeGrayColor);

          if frmMain.GlobalPenStyle <> psSolid then
          begin
            SetPencilStipplePattern(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                                    frmMain.GlobalPenStyle, FGColor, BKColor);
          end;
        end;

      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.PenColor := Color32(frmMain.GlobalForeColor);

          if frmMain.GlobalPenStyle <> psSolid then
          begin
            SetPencilStipplePattern(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                                    frmMain.GlobalPenStyle, FGColor, BKColor);

            { The following code is very odd, it should draws a white solid line,
              not a stippled line. But we can't without this line, otherwise,
              the channels of processed part could not be mixed. }
            SetPencilStipplePattern(FLayerPanelList.SelectedLayerPanel.ProcessedPart,
                                    frmMain.GlobalPenStyle, clWhite32, clWhite32);
          end;

          with FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp do
          begin
            PenColor := clWhite32;

            if frmMain.GlobalPenStyle <> psSolid then
            begin
              SetPencilStipplePattern(FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                                      frmMain.GlobalPenStyle, clWhite32, clWhite32);
            end;
          end;

          // used to track the processed part
          FLayerPanelList.SelectedLayerPanel.ProcessedPart.SetSize(
            FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
            FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height);

          FLayerPanelList.SelectedLayerPanel.ProcessedPart.Clear(clBlack32);
          FLayerPanelList.SelectedLayerPanel.ProcessedPart.PenColor := clWhite32;
        end;
    end;
  end;
end;

procedure TfrmChild.SetPencilStipplePattern(DestBmp: TBitmap32;
  const APenStyle: TPenStyle; const Color1, Color2: TColor32);
begin
  DestBmp.BeginUpdate;
  try
    case APenStyle of
      psDash:
        begin
          DestBmp.StippleStep := 0.75;

          DestBmp.SetStipple([Color1, Color1, Color1, Color1, Color1, Color1,
                              Color1, Color1, Color1, Color1, Color1, Color1,
                              Color1, Color1, Color1, Color1, Color1, Color1,
                              Color2, Color2, Color2, Color2, Color2, Color2]);
        end;

      psDot:
        begin
          DestBmp.StippleStep := 0.5;
          DestBmp.SetStipple([Color1, Color1, Color2, Color2]);
        end;

      psDashDot:
        begin
          DestBmp.StippleStep := 0.5;

          DestBmp.SetStipple([Color1, Color1, Color1, Color1, Color1, Color1,
                              Color2, Color2, Color1, Color1, Color2, Color2]);
        end;

      psDashDotDot:
        begin
          DestBmp.StippleStep := 0.5;
          
          DestBmp.SetStipple([Color1, Color1, Color1, Color1, Color1, Color1,
                              Color2, Color2, Color1, Color1, Color2, Color2,
                              Color1, Color1, Color2, Color2]);
        end;
    end;
  finally
    DestBmp.EndUpdate;
  end;
end;

// get the top left coordinates of the current layer
function TfrmChild.GetLayerTopLeft: TPoint;
var
  LCurrentLayer: TBitmapLayer;
  LLocation    : TFloatRect;
begin
  if (FLayerPanelList.Count > 0) and
     (FLayerPanelList.CurrentIndex > -1) then
  begin
    LCurrentLayer := TBitmapLayer(imgDrawingArea.Layers[FLayerPanelList.CurrentIndex]);
    LLocation     := LCurrentLayer.GetAdjustedLocation;
    Result.X      := Round(LLocation.Left);
    Result.Y      := Round(LLocation.Top);
  end;
end; 

function TfrmChild.GetCommandAimByCurrentChannel: TCommandAim;
begin
  Result := caNone;

  case FChannelManager.CurrentChannelType of
    wctAlpha:
      begin
        Result := caAlphaChannel;
      end;
      
    wctQuickMask:
      begin
        Result := caQuickMask;
      end;
      
    wctLayerMask:
      begin
        Result := caLayerMask;
      end;
      
    wctRGB, wctRed, wctGreen, wctBlue:
      begin
        Result := caLayer;
      end;
  end;
end; 

// connect mouse events to TImage32 component
procedure TfrmChild.ConnectMouseEventsToImage;
begin
  case frmMain.MainTool of
    gmtStandard:
      begin
        if frmMain.StandardTool = gstPencil then
        begin
          imgDrawingArea.OnMouseDown := PencilMouseDown;
          imgDrawingArea.OnMouseMove := PencilMouseMove;
          imgDrawingArea.OnMouseUp   := PencilMouseUp;
        end
        else
        if frmMain.StandardTool in [gstStraightLine, gstBezierCurve,
                                    gstPolygon, gstRegularPolygon,
                                    gstRectangle, gstRoundRectangle,
                                    gstEllipse] then
        begin
          imgDrawingArea.OnMouseDown := FigureToolsMouseDown;
          imgDrawingArea.OnMouseMove := FigureToolsMouseMove;
          imgDrawingArea.OnMouseUp   := FigureToolsMouseUp;
        end
        else
        if frmMain.StandardTool in [gstMoveObjects, gstPartiallySelect,
                                    gstTotallySelect] then
        begin
          imgDrawingArea.OnMouseDown := MoveToolsMouseDown;
          imgDrawingArea.OnMouseMove := MoveToolsMouseMove;
          imgDrawingArea.OnMouseUp   := MoveToolsMouseUp;
        end;
      end;

    gmtBrush:
      begin
        imgDrawingArea.OnMouseDown := BrushToolsMouseDown;
        imgDrawingArea.OnMouseMove := BrushToolsMouseMove;
        imgDrawingArea.OnMouseUp   := BrushToolsMouseUp;
      end;

    gmtMarquee:
      begin
        imgDrawingArea.OnMouseDown := MarqueeToolsMouseDown;
        imgDrawingArea.OnMouseMove := MarqueeToolsMouseMove;
        imgDrawingArea.OnMouseUp   := MarqueeToolsMouseUp;
      end;

    gmtGradient:
      begin
        imgDrawingArea.OnMouseDown := GradientToolsMouseDown;
        imgDrawingArea.OnMouseMove := GradientToolsMouseMove;
        imgDrawingArea.OnMouseUp   := GradientToolsMouseUp;
      end;

    gmtCrop:
      begin
        imgDrawingArea.OnMouseDown := CropToolsMouseDown;
        imgDrawingArea.OnMouseMove := CropToolsMouseMove;
        imgDrawingArea.OnMouseUp   := CropToolsMouseUp;
      end;

    gmtPaintBucket:
      begin
        imgDrawingArea.OnMouseDown := PaintBucketToolsMouseDown;
        imgDrawingArea.OnMouseMove := PaintBucketToolsMouseMove;
        imgDrawingArea.OnMouseUp   := PaintBucketToolsMouseUp;
      end;

    gmtEraser:
      begin
        imgDrawingArea.OnMouseDown := EraserToolsMouseDown;
        imgDrawingArea.OnMouseMove := EraserToolsMouseMove;
        imgDrawingArea.OnMouseUp   := EraserToolsMouseUp;
      end;

    gmtPenTools:
      begin
        imgDrawingArea.OnMouseDown := PenToolsMouseDown;
        imgDrawingArea.OnMouseMove := PenToolsMouseMove;
        imgDrawingArea.OnMouseUp   := PenToolsMouseUp;
      end;

    gmtMeasure:
      begin
        imgDrawingArea.OnMouseDown := MeasureToolsMouseDown;
        imgDrawingArea.OnMouseMove := MeasureToolsMouseMove;
        imgDrawingArea.OnMouseUp   := MeasureToolsMouseUp;
      end;

    gmtShape:
      begin
        imgDrawingArea.OnMouseDown := ShapeRegionToolsMouseDown;
        imgDrawingArea.OnMouseMove := ShapeRegionToolsMouseMove;
        imgDrawingArea.OnMouseUp   := ShapeRegionToolsMouseUp;
      end;

    gmtTextTool:
      begin
        imgDrawingArea.OnMouseDown := TextToolsMouseDown;
        imgDrawingArea.OnMouseMove := TextToolsMouseMove;
        imgDrawingArea.OnMouseUp   := TextToolsMouseUp;
      end;

    gmtEyedropper:
      begin
        imgDrawingArea.OnMouseDown := EyedropperMouseDown;
        imgDrawingArea.OnMouseMove := EyedropperMouseMove;
        imgDrawingArea.OnMouseUp   := EyedropperMouseUp;
      end;

    gmtHandTool:
      begin
        imgDrawingArea.OnMouseDown := HandToolMouseDown;
        imgDrawingArea.OnMouseMove := HandToolMouseMove;
        imgDrawingArea.OnMouseUp   := HandToolMouseUp;
      end;

  else
    imgDrawingArea.OnMouseDown := nil;
    imgDrawingArea.OnMouseMove := nil;
    imgDrawingArea.OnMouseUp   := nil;
  end;
end;

// change cursor according to the main tools
procedure TfrmChild.ChangeImageCursorByToolTemplets;
begin
  imgDrawingArea.Cursor := crCross;

  case frmMain.MainTool of
    gmtStandard:
      begin
        ChangeImageCursorByStandardTools;
      end;
      
    gmtEraser:
      begin
        ChangeImageCursorByEraserTools;
      end;
      
    gmtPenTools:
      begin
        ChangeImageCursorByPenTools;
      end;
      
    gmtMarquee:
      begin
        ChangeImageCursorByMarqueeTools;
      end;

    gmtCrop:
      begin
        imgDrawingArea.Cursor := crCrop;
      end;

    gmtMeasure:
      begin
        imgDrawingArea.Cursor := crMeasure;
      end;
      
    gmtPaintBucket:
      begin
        imgDrawingArea.Cursor := crPaintBucket;
      end;
      
    gmtShape:
      begin
        ChangeImageCursorByShapeTools;
      end;
      
    gmtEyedropper:
      begin
        imgDrawingArea.Cursor := crEyedropper;
      end;
      
    gmtHandTool:
      begin
        imgDrawingArea.Cursor := crHandLoosen;
      end;
  end;
end;

{ Show/Hide assistant layers -- FHandleLayer, FCropHandleLayer, FPathLayer,
                                FShapeOutlineLayer }
procedure TfrmChild.SetAssistantLayerVisible(const IsVisible: Boolean);
begin
  if FHandleLayer <> nil
  then FHandleLayer.Visible := IsVisible;

  if FCropHandleLayer <> nil
  then FCropHandleLayer.Visible := IsVisible;

  if FPathLayer <> nil
  then FPathLayer.Visible := IsVisible;

  if FShapeOutlineLayer <> nil
  then FShapeOutlineLayer.Visible := IsVisible;
end; 

procedure TfrmChild.CreateBlankLayer;
var
  LNewLayer  : TBitmapLayer;
  LBackLayer : TBitmapLayer;
  LLayerPanel: TgmLayerPanel;
  LIndex     : Integer;
begin
  if frmRichTextEditor.Visible then
  begin
    CommitEdits;
  end;

  DeleteShapeOutlineLayer;
  DeleteRichTextHandleLayer;

  if (imgDrawingArea.Layers.Count > 0) and (FLayerPanelList.Count > 0) then
  begin
    LBackLayer := TBitmapLayer(imgDrawingArea.Layers[0]);
    LIndex     := FLayerPanelList.CurrentIndex;

    // create a new layer, insert it into the layer list
    imgDrawingArea.Layers.Insert(LIndex + 1, TBitmapLayer);
    LNewLayer := TBitmapLayer(imgDrawingArea.Layers[LIndex + 1]);

    with LNewLayer do
    begin
      Bitmap.DrawMode := dmCustom;
      Bitmap.SetSize(LBackLayer.Bitmap.Width, LBackLayer.Bitmap.Height);
      Bitmap.Clear($00FFFFFF);

      Location := LBackLayer.Location;
      Scaled   := True;
      
      Bitmap.Changed;
    end;

    // create a layer panel and showing it in frmLayer form
    LLayerPanel := TgmTransparentLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer);

    // add new layer panel to list
    if LIndex = (FLayerPanelList.Count - 1) then
    begin
      FLayerPanelList.AddLayerPanelToList(LLayerPanel);
    end
    else
    begin
      FLayerPanelList.InsertLayerPanelToList(LIndex + 1, LLayerPanel);
    end;

    FImageProcessed := True;       // identify the image has been modified
    frmLayer.scrlbxLayers.Update;  // update the layer panels container for showing the scroll bars correctly

    // update the appearance of the color form
    frmColor.ColorMode := cmRGB;
  end;
end;

procedure TfrmChild.CreateBlankLayerWithIndex(AIndex: Integer);
var
  LNewLayer  : TBitmapLayer;
  LBackLayer : TBitmapLayer;
  LLayerPanel: TgmLayerPanel;
begin
  if AIndex < 0 then
  begin
    Exit;
  end;

  if AIndex > FLayerPanelList.Count then
  begin
    AIndex := FLayerPanelList.Count;
  end;

  if frmRichTextEditor.Visible then
  begin
    CommitEdits;
  end;

  DeleteShapeOutlineLayer;
  DeleteRichTextHandleLayer;

  if (imgDrawingArea.Layers.Count > 0) and (FLayerPanelList.Count > 0) then
  begin
    LBackLayer := TBitmapLayer(imgDrawingArea.Layers[0]);

    // create a new layer, insert it into the layer list
    imgDrawingArea.Layers.Insert(AIndex, TBitmapLayer);
    LNewLayer := TBitmapLayer(imgDrawingArea.Layers[AIndex]);

    with LNewLayer do
    begin
      Bitmap.DrawMode := dmCustom;
      Bitmap.SetSize(LBackLayer.Bitmap.Width, LBackLayer.Bitmap.Height);
      Bitmap.Clear($00FFFFFF);

      Location := LBackLayer.Location;
      Scaled   := True;
      
      Bitmap.Changed;
    end;

    // create a layer panel and showing it in frmLayer form
    LLayerPanel := TgmTransparentLayerPanel.Create(frmLayer.scrlbxLayers, LNewLayer);

    // add new layer panel to list
    if AIndex >= FLayerPanelList.Count then
    begin
      FLayerPanelList.AddLayerPanelToList(LLayerPanel);
    end
    else
    begin
      FLayerPanelList.InsertLayerPanelToList(AIndex, LLayerPanel);
    end;

    FImageProcessed := True;       // identify the image has been modified
    frmLayer.scrlbxLayers.Update;  // update the layer panels container for showing the scroll bars correctly

    // update the appearance of the color form
    frmColor.ColorMode := cmRGB;
  end;
end;

procedure TfrmChild.SaveNamedFile;
var
  LOutputBitmap   : TBitmap32;
  LColorReducedBmp: TBitmap;
  LTempBmp        : TBitmap;
  LExtensionName  : string;
  LGMDManager     : TgmGMDManager;
begin
  LColorReducedBmp := nil;

  if FFileName <> '' then
  begin
    Screen.Cursor := crHourGlass;
    try
      LExtensionName := Lowercase( ExtractFileExt(FFileName) );

      if LExtensionName = '.bmp' then
      begin
        frmMain.OutputGraphicsFormat := ogfBMP;
      end
      else if LExtensionName = '.jpg' then
      begin
        frmMain.OutputGraphicsFormat := ogfJPG;
      end
      else if LExtensionName = '.gif' then
      begin
        frmMain.OutputGraphicsFormat := ogfGIF;
      end
      else if LExtensionName = '.png' then
      begin
        frmMain.OutputGraphicsFormat := ogfPNG;
      end
      else if LExtensionName = '.tif' then
      begin
        frmMain.OutputGraphicsFormat := ogfTIF;
      end
      else if LExtensionName = '.gmd' then
      begin
        frmMain.OutputGraphicsFormat := ogfGMD;
      end;

      if frmMain.OutputGraphicsFormat = ogfGMD then
      begin
        LGMDManager := TgmGMDManager.Create;
        try
          // link pointers to the gmd manager
          LGMDManager.LayerPanelList := FLayerPanelList;
          LGMDManager.ChannelManager := FChannelManager;
          LGMDManager.PathPanelList  := FPathPanelList;

          LGMDManager.SaveToFile(FFileName);
          Self.RefreshCaption;
          FImageProcessed := False;
        finally
          LGMDManager.Free;
        end;
      end
      else
      begin
        LOutputBitmap := TBitmap32.Create;
        try
          { Note that, to get the actual number of layers, you should always
            using the count property of TLayerPanelList, because in this program,
            the layers property of imgDrawingArea may has extra layers,
            such as handle layers. }

          if FLayerPanelList.Count > 1 then
          begin
            FLayerPanelList.FlattenLayersToBitmap(LOutputBitmap, dmBlend);
          end
          else
          begin
            LOutputBitmap.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
          end;

          LOutputBitmap.DrawMode := dmBlend;

          case frmMain.OutputGraphicsFormat of
            ogfBMP,
            ogfJPG,
            ogfTIF:
              begin
                MergeBitmapToColoredBackground(LOutputBitmap, clWhite32);
              end;

            ogfGIF:
              begin
                MergeBitmapToColoredBackground(LOutputBitmap, clWhite32);
                FLayerPanelList.HideAllLayerPanels;
                SetAssistantLayerVisible(False);

                frmIndexedColor := TfrmIndexedColor.Create(nil);
                LTempBmp        := TBitmap.Create;
                try
                  LTempBmp.Assign(LOutputBitmap);

                  // to open the frmIndexedColor dialog, we need to assign value to FBeforeProc
                  frmMain.FBeforeProc.Assign(LOutputBitmap);

                  if frmIndexedColor.ShowModal = mrOK then
                  begin
                    LColorReducedBmp := ReduceColors(LTempBmp, frmIndexedColor.ColorReduction,
                                                     frmIndexedColor.DitherMode,
                                                     GIFImageDefaultColorReductionBits, 0);

                    if Assigned(LColorReducedBmp) then
                    begin
                      LOutputBitmap.Assign(LColorReducedBmp);
                    end;
                  end;

                finally
                  FreeAndNil(frmIndexedColor);
                  LTempBmp.Free;

                  if Assigned(LColorReducedBmp) then
                  begin
                    LColorReducedBmp.Free;
                  end;
                end;
              end;
          end;

          frmMain.FBeforeProc.Assign(LOutputBitmap);
          SaveGraphicsFile(FFileName, LOutputBitmap);
          RefreshCaption;

          if frmMain.svpctrdlgSavePictures.FilterIndex = 3 then
          begin
            if FLayerPanelList.IsAllowRefreshLayerPanels then
            begin
              FLayerPanelList.ShowAllLayerPanels;
            end;
            
            SetAssistantLayerVisible(True);
          end;

          FImageProcessed := False;
        finally
          LOutputBitmap.Free;
        end;
      end;
    finally
      Screen.Cursor := crDefault;
    end;
  end
  else
  begin
    SaveFileWithNewName;
  end;
end;

procedure TfrmChild.SaveFileWithNewName;
var
  LExtensionName: string;
  LShortFileName: string;
begin
  if FFileName = '' then
  begin
    frmMain.OutputGraphicsFormat              := ogfBMP;
    frmMain.svpctrdlgSavePictures.FilterIndex := Ord(ogfBMP);
    frmMain.svpctrdlgSavePictures.FileName    := 'Untitled';
  end
  else
  begin
    LExtensionName := Lowercase( ExtractFileExt(FFileName) );
    LShortFileName := ExtractFileName(FFileName);

    if LExtensionName = '.bmp' then
    begin
      frmMain.OutputGraphicsFormat := ogfBMP;
    end
    else if LExtensionName = '.jpg' then
    begin
      frmMain.OutputGraphicsFormat := ogfJPG;
    end
    else if LExtensionName = '.gif' then
    begin
      frmMain.OutputGraphicsFormat := ogfGIF;
    end
    else if LExtensionName = '.png' then
    begin
      frmMain.OutputGraphicsFormat := ogfPNG;
    end
    else if LExtensionName = '.tif' then
    begin
      frmMain.OutputGraphicsFormat := ogfTIF;
    end
    else if LExtensionName = '.gmd' then
    begin
      frmMain.OutputGraphicsFormat := ogfGMD;
    end;

    frmMain.svpctrdlgSavePictures.FilterIndex := Ord(frmMain.OutputGraphicsFormat);

    if LExtensionName <> '' then
    begin
      frmMain.svpctrdlgSavePictures.FileName := Copy( LShortFileName, 1, Length(LShortFileName) - 4 );
    end
    else
    begin
      frmMain.svpctrdlgSavePictures.FileName := LShortFileName;
    end;
  end;

  if frmMain.svpctrdlgSavePictures.Execute then
  begin
    frmMain.OutputGraphicsFormat :=
      TgmOutputGraphicsFormat(frmMain.svpctrdlgSavePictures.FilterIndex);

    FFileName      := frmMain.svpctrdlgSavePictures.Filename;
    LExtensionName := Lowercase( ExtractFileExt(FFileName) );

    if LExtensionName = '' then
    begin
      case frmMain.OutputGraphicsFormat of
        ogfBMP: FFileName := FFileName + '.bmp';
        ogfJPG: FFileName := FFileName + '.jpg';
        ogfGIF: FFileName := FFileName + '.gif';
        ogfPNG: FFileName := FFileName + '.png';
        ogfTIF: FFileName := FFileName + '.tif';
        ogfGMD: FFileName := FFileName + '.gmd';
      end;
    end
    else
    begin
      case frmMain.OutputGraphicsFormat of
        ogfBMP:
          begin
            if LExtensionName <> '.bmp' then
            begin
              FFileName := ChangeFileExt(FFileName, '.bmp');
            end;
          end;

        ogfJPG:
          begin
            if LExtensionName <> '.jpg' then
            begin
              FFileName := ChangeFileExt(FFileName, '.jpg');
            end;
          end;

        ogfGIF:
          begin
            if LExtensionName <> '.gif' then
            begin
              FFileName := ChangeFileExt(FFileName, '.gif');
            end;
          end;

        ogfPNG:
          begin
            if LExtensionName <> '.png' then
            begin
              FFileName := ChangeFileExt(FFileName, '.png');
            end;
          end;

        ogfTIF:
          begin
            if LExtensionName <> '.tif' then
            begin
              FFileName := ChangeFileExt(FFileName, '.tif');
            end;
          end;

        ogfGMD:
          begin
            if LExtensionName <> '.gmd' then
            begin
              FFileName := ChangeFileExt(FFileName, '.gmd');
            end;
          end;
      end;
    end;

    if FileExists(FFileName) then
    begin
      if MessageDlg('File: ' + FFileName + ' is already exists.' + #10#13 +
                    'Do you want to replace it?',
                    mtConfirmation, mbOKCancel, 0) <> mrOK then
      begin
        Exit;
      end;
    end;

    SaveNamedFile;
  end;
end;

procedure TfrmChild.DeleteCurrentLayer;
var
  LLayerName     : string;
  LTextLayerPanel: TgmRichTextLayerPanel;
begin
  if FLayerPanelList.Count > 1 then
  begin
    LLayerName := '"' + FLayerPanelList.SelectedLayerPanel.LayerName.Caption + '"';

    if MessageDlg('Delete the layer ' + LLayerName + '?',
                  mtConfirmation, [mbOK, mbCancel], 0) = mrOK then
    begin
      // deselect all figures
      if High(FLayerPanelList.FSelectedFigureInfoArray) > (-1) then
      begin
        FLayerPanelList.DeselectAllFiguresOnFigureLayer;

        if FHandleLayer <> nil then
        begin
          FreeAndNil(FHandleLayer);
        end;

        frmMain.UpdateToolsOptions;
      end;

      CreateUndoRedoForDeleteLayer;  // create Undo/Redo first

      // delete the layer
      FLayerPanelList.DeleteSelectedLayerPanel;

      // update thumbnails
      FChannelManager.UpdateColorChannelThumbnails(FLayerPanelList);

      if FSelection <> nil then
      begin
        case FChannelManager.CurrentChannelType of
          wctAlpha:
            begin
              if Assigned(FChannelManager.SelectedAlphaChannelPanel)
              then ChangeSelectionTarget;
            end;

          wctQuickMask, wctLayerMask:
            begin
              ChangeSelectionTarget;
            end;

          wctRGB, wctRed, wctGreen, wctBlue:
            begin
              if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                   lfBackground, lfTransparent] then
              begin
                ChangeSelectionTarget;
              end;
            end;
        end;

        // update selection border
        UpdateSelectionHandleBorder;
      end;

      if FLayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
      begin
        if frmRichTextEditor.Visible then
        begin
          frmRichTextEditor.Close;
        end;

        if frmMain.MainTool = gmtTextTool then
        begin
          CreateRichTextHandleLayer;
          LTextLayerPanel := TgmRichTextLayerPanel(FLayerPanelList.SelectedLayerPanel);

          if FRichTextHandleLayer <> nil then
          begin
            FRichTextHandleLayer.Bitmap.Clear($00000000);

            LTextLayerPanel.DrawRichTextBorder(
              FRichTextHandleLayer.Bitmap.Canvas,
              FRichTextHandleLayerOffsetVector);

            LTextLayerPanel.DrawRichTextBorderHandles(
              FRichTextHandleLayer.Bitmap.Canvas,
              FRichTextHandleLayerOffsetVector);

            FRichTextHandleLayer.Bitmap.Changed;
          end;
        end
        else
        begin
          DeleteRichTextHandleLayer;
        end;
      end
      else
      begin
        if frmRichTextEditor.Visible then
        begin
          frmRichTextEditor.Close;
        end;

        DeleteRichTextHandleLayer;
      end;
    end;
  end;
end;

procedure TfrmChild.CreateUndoRedoForDeleteLayer;
var
  HistoryStatePanel: TgmHistoryStatePanel;
begin
  // Undo/Redo
  HistoryStatePanel := nil;

  case FLayerPanelList.SelectedLayerPanel.LayerFeature of
    lfBackground:
      begin
        HistoryStatePanel := TgmStandardLayerStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          FLayerPanelList.CurrentIndex,
          FLayerPanelList.SelectedLayerPanel,
          lctDelete);
      end;

    lfTransparent:
      begin
        HistoryStatePanel := TgmStandardLayerStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          FLayerPanelList.CurrentIndex,
          FLayerPanelList.SelectedLayerPanel,
          lctDelete);
      end;

    lfSolidColor:
      begin
        HistoryStatePanel := TgmSolidColorLayerStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          FLayerPanelList.CurrentIndex,
          FLayerPanelList.SelectedLayerPanel,
          lctDelete);
      end;

    lfGradientFill:
      begin
        HistoryStatePanel := TgmGradientFillLayerStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          FLayerPanelList.CurrentIndex,
          FLayerPanelList.SelectedLayerPanel,
          lctDelete);
      end;

    lfPattern:
      begin
        HistoryStatePanel := TgmPatternLayerStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          FLayerPanelList.CurrentIndex,
          FLayerPanelList.SelectedLayerPanel,
          lctDelete);
      end;

    lfLevels:
      begin
        HistoryStatePanel := TgmLevelsLayerStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          FLayerPanelList.CurrentIndex,
          FLayerPanelList.SelectedLayerPanel,
          lctDelete);
      end;

    lfCurves:
      begin
        HistoryStatePanel := TgmCurvesLayerStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          FLayerPanelList.CurrentIndex,
          FLayerPanelList.SelectedLayerPanel,
          lctDelete);
      end;

    lfColorBalance:
      begin
        HistoryStatePanel := TgmColorBalanceLayerStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          FLayerPanelList.CurrentIndex,
          FLayerPanelList.SelectedLayerPanel,
          lctDelete);
      end;

    lfBrightContrast:
      begin
        HistoryStatePanel := TgmBrightContrastLayerStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          FLayerPanelList.CurrentIndex,
          FLayerPanelList.SelectedLayerPanel,
          lctDelete);
      end;

    lfHLSOrHSV:
      begin
        HistoryStatePanel := TgmHLSLayerStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          FLayerPanelList.CurrentIndex,
          FLayerPanelList.SelectedLayerPanel,
          lctDelete);
      end;

    lfChannelMixer:
      begin
        HistoryStatePanel := TgmChannelMixerLayerStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          FLayerPanelList.CurrentIndex,
          FLayerPanelList.SelectedLayerPanel,
          lctDelete);
      end;

    lfGradientMap:
      begin
        HistoryStatePanel := TgmGradientMapLayerStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          FLayerPanelList.CurrentIndex,
          FLayerPanelList.SelectedLayerPanel,
          lctDelete);
      end;

    lfInvert:
      begin
        HistoryStatePanel := TgmInvertLayerStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          FLayerPanelList.CurrentIndex,
          FLayerPanelList.SelectedLayerPanel,
          lctDelete);
      end;

    lfThreshold:
      begin
        HistoryStatePanel := TgmThresholdLayerStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          FLayerPanelList.CurrentIndex,
          FLayerPanelList.SelectedLayerPanel,
          lctDelete);
      end;
      
    lfPosterize:
      begin
        HistoryStatePanel := TgmPosterizeLayerStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          FLayerPanelList.CurrentIndex,
          FLayerPanelList.SelectedLayerPanel,
          lctDelete);
      end;
      
    lfShapeRegion:
      begin
        HistoryStatePanel := TgmShapeRegionLayerStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          FLayerPanelList.CurrentIndex,
          FLayerPanelList.SelectedLayerPanel,
          rctDeleteRegionLayer);
      end;

    lfRichText:
      begin
        HistoryStatePanel := TgmTypeToolLayerStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          FLayerPanelList.CurrentIndex,
          FLayerPanelList.SelectedLayerPanel,
          lctDelete);
      end;

    lfFigure:
      begin
        HistoryStatePanel := TgmFigureLayerStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          FLayerPanelList.CurrentIndex,
          FLayerPanelList.SelectedLayerPanel,
          lctDelete);
      end;
  end;

  if Assigned(HistoryStatePanel) then
  begin
    FHistoryManager.AddHistoryState(HistoryStatePanel);
  end;
end;

procedure TfrmChild.LoadDataFromGMDFile(const AFileName: string);
var
  LGMDManager           : TgmGMDManager;
  LLayerIndex           : Integer;
  LLayerLocation        : TFloatRect;
  LRect                 : TRect;
  LTopLeft              : TPoint;
  LRichTextLayerPanel   : TgmRichTextLayerPanel;
  LShapeRegionLayerPanel: TgmShapeRegionLayerPanel;
begin
  if not FileExists(AFileName) then
  begin
    Exit;
  end;
  
  Screen.Cursor := crHourGlass;
  try
    // delete selection
    if Assigned(FSelection) then
    begin
      CommitSelection;
    end;

    // deselect figures
    FLayerPanelList.DeselectAllFiguresOnFigureLayer;
    DeleteFigureHandleLayer;

    // delete measure line
    DeleteMeasureLine;

    // cancel crop
    if Assigned(Crop) then
    begin
      CancelCrop;
    end;

    // delete handle layers...
    DeleteRichTextHandleLayer;
    DeleteShapeOutlineLayer;
    DeletePathLayer;

    // delete paths...
    PathPanelList.DeselectAllPathPanels;
    PathPanelList.DeleteAllPathPanels;
    FPenPath := nil;

    // delete channels...
    FChannelManager.SelectAllColorChannels;
    FChannelManager.DeleteAllAlphaChannelPanels;
    FChannelManager.DeleteLayerMaskPanel;
    FChannelManager.DeleteQuickMask;
    FChannelManager.DeleteChannelPreviewLayer;

    // delete layers...
    FLayerPanelList.DeleteAllLayerPanels;
    imgDrawingArea.Layers.Clear;

    // read the data in...
    LGMDManager := TgmGMDManager.Create;
    try
      // link pointers to the gmd manager
      LGMDManager.LayerPanelList := FLayerPanelList;
      LGMDManager.ChannelManager := FChannelManager;
      LGMDManager.PathPanelList  := FPathPanelList;

      if LGMDManager.LoadFromFile(AFileName) then
      begin
        if FLayerPanelList.Count > 0 then
        begin
          { Note that, at this point, the GMD file loader is already make the
            FLayerPanelList.SelectedLayerPanel points to the selected layer panel.
            We could reference to it safely. Actually, this has been done in
            LoadLayersFromStream() method that is member of class TLayerPanelList. }

          LLayerIndex := FLayerPanelList.GetFirstSelectedLayerPanelIndex;

          FLayerPanelList.CurrentIndex := LLayerIndex;

          // set size of the background
          imgDrawingArea.Bitmap.SetSize(
            FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
            FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height);

          // get location of the bitmap in the TImage32
          LRect := imgDrawingArea.GetBitmapRect;

          { Convert the top-left point of the background bitmap of the TImage32
            from control coordinate to bitmap coordinate. }
          LTopLeft := imgDrawingArea.ControlToBitmap( Point(LRect.Left, LRect.Top) );

          LLayerLocation := FloatRect(LTopLeft.X, LTopLeft.Y,
                                      imgDrawingArea.Bitmap.Width,
                                      imgDrawingArea.Bitmap.Height);

          FLayerPanelList.SetLocationForAllLayers(LLayerLocation);

          frmLayer.cmbbxLayerBlendMode.ItemIndex := FLayerPanelList.SelectedLayerPanel.BlendModeIndex;

          FLayerTopLeft := ActiveChildForm.GetLayerTopLeft;

          // create preview layer of channel manager for this child form
          FChannelManager.CreateChannelPreviewLayer(
            imgDrawingArea.Layers, FLayerPanelList,
            FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
            FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height,
            FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Location);

          { Set the layer index of the channel preview layer just above all of the
            working layers and below the all of the channel layers and handle layers. }
          TPositionedLayer(FChannelManager.ChannelPreviewLayer).Index := FLayerPanelList.Count;

          // associate the new layer panel to the channel mannager
          FChannelManager.AssociateToLayerPanel(FLayerPanelList.SelectedLayerPanel);

          // set location for channels layers
          FChannelManager.SetLocationForAllChannelLayers(LLayerLocation);
          FChannelManager.UpdateColorChannelThumbnails(FLayerPanelList);

          // set paths, update the thumbnail of every path panel in the list
          if PathPanelList.Count > 0 then
          begin
            // create the path layer in order to calculate the offset vector
            CreatePathLayer;

            PathPanelList.UpdateAllThumbnails(
              FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
              FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height,
              PathOffsetVector);
              
            // we don't need this layer at now
            DeletePathLayer;
          end;

          // activate proper channel
          if Assigned(FChannelManager.QuickMaskPanel) then
          begin
            EditMode := emQuickMaskMode;
            FChannelManager.SelectQuickMask;
            frmMain.spdbtnQuickMaskMode.Down := True;
          end
          else
          begin
            if FLayerPanelList.SelectedLayerPanel.LayerFeature in
                 [lfBackground, lfTransparent, lfFigure, lfShapeRegion,
                  lfRichText] then
            begin
              FChannelManager.SelectAllColorChannels;
            end
            else
            begin
              if FLayerPanelList.SelectedLayerPanel.IsHasMask then
              begin
                FChannelManager.SelectLayerMask;
              end
              else
              begin
                FChannelManager.SelectAllColorChannels;
              end;
            end;
          end;

          FLayerPanelList.SelectedLayerPanel.UpdateLayerPanelState;

          // if the current layer is a rich text layer...
          if FLayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
          begin
            if frmMain.MainTool = gmtTextTool then
            begin
              CreateRichTextHandleLayer;
              FRichTextHandleLayer.Bitmap.Clear($00000000);

              LRichTextLayerPanel := TgmRichTextLayerPanel(FLayerPanelList.SelectedLayerPanel);

              with LRichTextLayerPanel do
              begin
                DrawRichTextBorder(FRichTextHandleLayer.Bitmap.Canvas,
                                   FRichTextHandleLayerOffsetVector);

                DrawRichTextBorderHandles(FRichTextHandleLayer.Bitmap.Canvas,
                                          FRichTextHandleLayerOffsetVector);
              end;
            end;
          end
          else // if the current layer is a shape region layer...
          if FLayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
          begin
            // if the current tool is Shape Region tool...
            if frmMain.MainTool = gmtShape then
            begin
              CreateShapeOutlineLayer;
              FShapeOutlineLayer.Bitmap.Clear($00000000);

              LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(FLayerPanelList.SelectedLayerPanel);

              with LShapeRegionLayerPanel do
              begin
                ShapeOutlineList.DrawAllOutlines(FShapeOutlineLayer.Bitmap.Canvas,
                                                 FOutlineOffsetVector, pmNotXor);

                if frmMain.ShapeRegionTool = srtMove then
                begin
                  ShapeOutlineList.DrawShapesBoundary(FShapeOutlineLayer.Bitmap.Canvas,
                    HANDLE_RADIUS, FOutlineOffsetVector, pmNotXor);

                  ShapeOutlineList.DrawShapesBoundaryHandles(FShapeOutlineLayer.Bitmap.Canvas,
                    HANDLE_RADIUS, FOutlineOffsetVector, pmNotXor);
                end;
              end;
            end;
          end;

          frmMain.stsbrMain.Panels[0].Text := GetBitmapDimensionString(ActiveChildForm.FHistoryBitmap);
        end;
      end;

    finally
      LGMDManager.Free;
    end;   

  finally
    Screen.Cursor := crDefault;
  end;
end;

// refresh the caption of this form
procedure TfrmChild.RefreshCaption;
var
  s: string;
begin
  if FFileName = '' then
  begin
    s := 'Untitled';
  end
  else
  begin
    s := ExtractFileName(FFileName);
  end;

  Caption := s + ' @ ' + IntToStr( Round(imgDrawingArea.Scale * 100) ) + '%';
end;

// finish current curve definition and prepare for drawing new one
procedure TfrmChild.FinishCurves;
begin
  if FDrawCurveTime > 0 then
  begin
    InitializeCanvas;

    if Assigned(FSelection) then
    begin
      if (FChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue]) and
         (not (FLayerPanelList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent])) then
      begin
        FinishCurveOnLayer;
      end
      else
      begin
        FinishCurveOnSelection;
      end;
    end
    else
    begin
      case FChannelManager.CurrentChannelType of
        wctAlpha, wctQuickMask, wctLayerMask:
          begin
            FinishCurveOnSpecialChannels;
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            FinishCurveOnLayer;
          end;
      end;
    end;
    
    FDrawCurveTime := 0;
  end;
end;

// finish current polygon definition and prepare for drawing new one
procedure TfrmChild.FinishPolygon;
begin
  if   High(FPolygon) = 1
  then imgDrawingArea.Bitmap.Changed
  else
  if High(FPolygon) > 1 then
  begin
    SetLength( FPolygon, High(FPolygon) + 2 );
    FPolygon[High(FPolygon)] := FPolygon[0];

    SetLength( FActualPolygon, High(FActualPolygon) + 2 );
    FActualPolygon[High(FActualPolygon)] := FActualPolygon[0];

    InitializeCanvas;

    if Assigned(FSelection) then
    begin
      if  (FChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue])
      and (not (FLayerPanelList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent]))
      then FinishPolygonOnLayer
      else FinishPolygonOnSelection;
    end
    else
    begin
      case FChannelManager.CurrentChannelType of
        wctAlpha, wctQuickMask, wctLayerMask:
          FinishPolygonOnSpecialChannels;

        wctRGB, wctRed, wctGreen, wctBlue:
          FinishPolygonOnLayer;
      end;
    end;
  end;

  FPolygon       := nil;
  FActualPolygon := nil;
end; 

procedure TfrmChild.CreateFigureLayer(const AFigureFlag: TgmFigureFlags);
var
  NewLayer, BackLayer: TBitmapLayer;
  FigureLayerPanel   : TgmFigureLayerPanel;
  LayerPanel         : TgmLayerPanel;
  Index              : Integer;
  FigureObj          : TgmFigureObject;
  HasCreatedNewLayer : Boolean;  // indicating whether if we have already created a new figure layer
  HistoryStatePanel  : TgmHistoryStatePanel;
  CommandIconIndex   : Integer;
begin
  CommandIconIndex   := DEFAULT_COMMAND_ICON_INDEX;
  HasCreatedNewLayer := False;

  if (imgDrawingArea.Layers.Count > 0) and (FLayerPanelList.Count > 0) then
  begin
    if FLayerPanelList.SelectedLayerPanel.LayerFeature <> lfFigure then
    begin
      Index := FLayerPanelList.CurrentIndex;

      if  (Index < FLayerPanelList.Count - 1)
      and ( TgmLayerPanel(FLayerPanelList.Items[Index + 1]).LayerFeature = lfFigure )
      then FLayerPanelList.ActiveLayerPanel(Index + 1)
      else
      begin
        BackLayer := TBitmapLayer(imgDrawingArea.Layers[0]);

        // create a new layer, insert it into the layer list
        imgDrawingArea.Layers.Insert(Index + 1, TBitmapLayer);
        NewLayer := TBitmapLayer(imgDrawingArea.Layers[Index + 1]);

        with NewLayer do
        begin
          Bitmap.Width  := BackLayer.Bitmap.Width;
          Bitmap.Height := BackLayer.Bitmap.Height;
          Bitmap.FillRectS(Bitmap.Canvas.ClipRect, $00FFFFFF);

          Location := BackLayer.Location;
          Scaled   := True;
          Bitmap.Changed;
        end;

        // create a new layer panel and showing it in frmLayer form
        LayerPanel := TgmFigureLayerPanel.Create(frmLayer.scrlbxLayers, NewLayer);

        // add new layer panel to list
        if Index = (FLayerPanelList.Count - 1) then
        begin
          FLayerPanelList.AddLayerPanelToList(LayerPanel);
        end
        else
        begin
          FLayerPanelList.InsertLayerPanelToList(Index + 1, LayerPanel);
        end;

        HasCreatedNewLayer := True;
      end;

      // update the layer panel container for showing the scroll bars of it correctly
      frmLayer.scrlbxLayers.Update;

      // update the appearance of the color form
      frmColor.ColorMode := cmRGB;
    end;

    FImageProcessed := True; // identify the image has been modified

    case AFigureFlag of
      ffStraightLine:
        begin
          TgmFigureLayerPanel(FLayerPanelList.SelectedLayerPanel).FigureList.AddStraightLineToList(
            frmMain.GlobalForeColor, frmMain.GlobalBackColor, frmMain.GlobalPenStyle,
            frmMain.GlobalBrushStyle, frmMain.GlobalPenWidth,
            FActualStartPoint, FActualEndPoint);

          CommandIconIndex := STRAIGHT_LINE_COMMAND_ICON_INDEX;
        end;

      ffCurve:
        begin
          TgmFigureLayerPanel(FLayerPanelList.SelectedLayerPanel).FigureList.AddCurveToList(
            frmMain.GlobalForeColor, frmMain.GlobalBackColor, frmMain.GlobalPenStyle,
            frmMain.GlobalBrushStyle, frmMain.GlobalPenWidth,
            FActualStartPoint, FActualCurvePoint1, FActualCurvePoint2, FActualEndPoint);

          CommandIconIndex := BEZIER_CURVE_COMMAND_ICON_INDEX;
        end;

      ffPolygon:
        begin
          TgmFigureLayerPanel(FLayerPanelList.SelectedLayerPanel).FigureList.AddPolygonToList(
            frmMain.GlobalForeColor, frmMain.GlobalBackColor, frmMain.GlobalPenStyle,
            frmMain.GlobalBrushStyle, frmMain.GlobalPenWidth, FActualPolygon);

          CommandIconIndex := POLYGON_COMMAND_ICON_INDEX;
        end;

      ffRegularPolygon:
        begin
          TgmFigureLayerPanel(FLayerPanelList.SelectedLayerPanel).FigureList.AddRegularPolygonToList(
            frmMain.GlobalForeColor, frmMain.GlobalBackColor,
            frmMain.GlobalPenStyle, frmMain.GlobalBrushStyle,
            frmMain.GlobalPenWidth, frmMain.StandardPolygonSides,
            FActualStartPoint, FActualEndPoint);

          CommandIconIndex := REGULAR_POLY_COMMAND_ICON_INDEX;
        end;

      ffRectangle:
        begin
          PointStandardizeOrder(FActualStartPoint, FActualEndPoint);

          TgmFigureLayerPanel(FLayerPanelList.SelectedLayerPanel).FigureList.AddRectangleToList(
            frmMain.GlobalForeColor, frmMain.GlobalBackColor, frmMain.GlobalPenStyle,
            frmMain.GlobalBrushStyle, frmMain.GlobalPenWidth,
            FActualStartPoint, FActualEndPoint, IRREGULAR_FIGURE);

          CommandIconIndex := RECTANGLE_COMMAND_ICON_INDEX;
        end;

      ffSquare:
        begin
          PointStandardizeOrder(FActualStartPoint, FActualEndPoint);
          
          TgmFigureLayerPanel(FLayerPanelList.SelectedLayerPanel).FigureList.AddRectangleToList(
            frmMain.GlobalForeColor, frmMain.GlobalBackColor, frmMain.GlobalPenStyle,
            frmMain.GlobalBrushStyle, frmMain.GlobalPenWidth,
            FActualStartPoint, FActualEndPoint, REGULAR_FIGURE);

          CommandIconIndex := RECTANGLE_COMMAND_ICON_INDEX;
        end;

      ffRoundRectangle:
        begin
          PointStandardizeOrder(FActualStartPoint, FActualEndPoint);
          
          TgmFigureLayerPanel(FLayerPanelList.SelectedLayerPanel).FigureList.AddRoundRectangleToList(
            frmMain.GlobalForeColor, frmMain.GlobalBackColor,
            frmMain.GlobalPenStyle, frmMain.GlobalBrushStyle,
            frmMain.GlobalPenWidth, FActualStartPoint, FActualEndPoint,
            frmMain.StandardCornerRadius, IRREGULAR_FIGURE);

          CommandIconIndex := ROUND_RECT_COMMAND_ICON_INDEX;
        end;

      ffRoundSquare:
        begin
          PointStandardizeOrder(FActualStartPoint, FActualEndPoint);

          TgmFigureLayerPanel(FLayerPanelList.SelectedLayerPanel).FigureList.AddRoundRectangleToList(
            frmMain.GlobalForeColor, frmMain.GlobalBackColor, frmMain.GlobalPenStyle,
            frmMain.GlobalBrushStyle, frmMain.GlobalPenWidth, FActualStartPoint,
            FActualEndPoint, frmMain.StandardCornerRadius, REGULAR_FIGURE);

          CommandIconIndex := ROUND_RECT_COMMAND_ICON_INDEX;
        end;

      ffEllipse:
        begin
          PointStandardizeOrder(FActualStartPoint, FActualEndPoint);

          TgmFigureLayerPanel(FLayerPanelList.SelectedLayerPanel).FigureList.AddEllipseToList(
            frmMain.GlobalForeColor, frmMain.GlobalBackColor, frmMain.GlobalPenStyle,
            frmMain.GlobalBrushStyle, frmMain.GlobalPenWidth,
            FActualStartPoint, FActualEndPoint, IRREGULAR_FIGURE);

          CommandIconIndex := ELLIPSE_COMMAND_ICON_INDEX;
        end;

      ffCircle:
        begin
          PointStandardizeOrder(FActualStartPoint, FActualEndPoint);

          TgmFigureLayerPanel(FLayerPanelList.SelectedLayerPanel).FigureList.AddEllipseToList(
            frmMain.GlobalForeColor, frmMain.GlobalBackColor, frmMain.GlobalPenStyle,
            frmMain.GlobalBrushStyle, frmMain.GlobalPenWidth,
            FActualStartPoint, FActualEndPoint, REGULAR_FIGURE);

          CommandIconIndex := ELLIPSE_COMMAND_ICON_INDEX;
        end;
    end;

    FigureLayerPanel := TgmFigureLayerPanel(FLayerPanelList.SelectedLayerPanel);
    FigureObj        := TgmFigureObject(FigureLayerPanel.FigureList.Items[FigureLayerPanel.FigureList.Count - 1]);

    // Undo/Redo
    
    if HasCreatedNewLayer then
    begin
      HistoryStatePanel := TgmFigureLayerStatePanel.Create(
        frmHistory.scrlbxHistory,
        dmHistory.bmp32lstHistory.Bitmap[CommandIconIndex],
        FLayerPanelList.CurrentIndex,
        FLayerPanelList.SelectedLayerPanel,
        lctNew,
        AFigureFlag);
    end
    else
    begin
      HistoryStatePanel := TgmAddFigureStatePanel.Create(
        frmHistory.scrlbxHistory,
        dmHistory.bmp32lstHistory.Bitmap[CommandIconIndex],
        FigureObj);
    end;

    if Assigned(HistoryStatePanel) then
    begin
      FHistoryManager.AddHistoryState(HistoryStatePanel);
    end;
  end;
end;

procedure TfrmChild.ChangeImageCursorByStandardTools;
begin
  imgDrawingArea.Cursor := crCross;
  
  case frmMain.StandardTool of
    gstMoveObjects:
      begin
        imgDrawingArea.Cursor := crMoveSelection;
      end;

    gstPartiallySelect,
    gstTotallySelect:
      begin
        imgDrawingArea.Cursor := crCross;
      end;
  end;
end;

procedure TfrmChild.CreateFigureHandleLayer;
var
  LLayerHalfW, LLayerHalfH: Single;
  LCenterPoint            : TPoint;
begin
  if FHandleLayer = nil then
  begin
    FHandleLayer                 := TBitmapLayer.Create(imgDrawingArea.Layers);
    FHandleLayer.Bitmap.DrawMode := dmBlend;
    FHandleLayer.Bitmap.Width    := Screen.Width;
    FHandleLayer.Bitmap.Height   := Screen.Height;
    LLayerHalfW                  := FHandleLayer.Bitmap.Width  / 2;
    LLayerHalfH                  := FHandleLayer.Bitmap.Height / 2;

    // get the center point of the viewport and convert it from control space to bitmap space
    with imgDrawingArea.GetViewportRect do
    begin
      LCenterPoint := imgDrawingArea.ControlToBitmap(
        Point( (Right + Left) div 2, (Top + Bottom) div 2 )  );
    end;

    FHandleLayer.Location := FloatRect(LCenterPoint.X - LLayerHalfW,
                                       LCenterPoint.Y - LLayerHalfH,
                                       LCenterPoint.X + LLayerHalfW,
                                       LCenterPoint.Y + LLayerHalfH);
                                       
    FHandleLayer.Scaled := True;
    FHandleLayer.Bitmap.Clear($00FFFFFF);

    // calculate the offset vector of the handle layer relative to the image layer
    CalcHandleLayerOffsetVector;
  end;
end;

procedure TfrmChild.DeleteFigureHandleLayer;
begin
  if Assigned(FHandleLayer)
  then FreeAndNil(FHandleLayer);
end;

// calculate the offset vector of the handle layer relative to the image layer
procedure TfrmChild.CalcHandleLayerOffsetVector;
var
  HandleLayerLeft : Single;
  HandleLayerTop  : Single;
  CurrentLayerLeft: Single;
  CurrentLayerTop : Single;
  TheScale        : Single;
begin
  if Assigned(FHandleLayer) then
  begin
    TheScale                   := 100 / FMagnification;
    HandleLayerLeft            := FHandleLayer.GetAdjustedLocation.Left * TheScale;
    HandleLayerTop             := FHandleLayer.GetAdjustedLocation.Top  * TheScale;
    CurrentLayerLeft           := FLayerPanelList.SelectedLayerPanel.AssociatedLayer.GetAdjustedLocation.Left * TheScale;
    CurrentLayerTop            := FLayerPanelList.SelectedLayerPanel.AssociatedLayer.GetAdjustedLocation.Top  * TheScale;
    FHandleLayerOffsetVector.X := Round(CurrentLayerLeft - HandleLayerLeft);
    FHandleLayerOffsetVector.Y := Round(CurrentLayerTop  - HandleLayerTop);
  end;
end;

procedure TfrmChild.RecordOldFigureSelectedData;
var
  i, ElementCount: Integer;
begin
  ElementCount := High(FLayerPanelList.FSelectedFigureInfoArray) + 1;

  if ElementCount > 0 then
  begin
    SetLength(FOldSelectedFigureInfoArray, ElementCount);

    for i := 0 to ElementCount - 1 do
    begin
      FOldSelectedFigureInfoArray[i].LayerIndex  := FLayerPanelList.FSelectedFigureInfoArray[i].LayerIndex;
      FOldSelectedFigureInfoArray[i].FigureIndex := FLayerPanelList.FSelectedFigureInfoArray[i].FigureIndex;
    end;
  end
  else
  begin
    SetLength(FOldSelectedFigureInfoArray, 0);
    FOldSelectedFigureInfoArray := nil;
  end;

  ElementCount := High(FLayerPanelList.FSelectedFigureLayerIndexArray) + 1;

  if ElementCount > 0 then
  begin
    SetLength(FOldSelectedFigureLayerIndexArray, ElementCount);

    for i := 0 to ElementCount - 1 do
      FOldSelectedFigureLayerIndexArray[i] := FLayerPanelList.FSelectedFigureLayerIndexArray[i];
  end
  else
  begin
    SetLength(FOldSelectedFigureLayerIndexArray, 0);
    FOldSelectedFigureLayerIndexArray := nil;
  end;
end;

procedure TfrmChild.CreateSelectFigureUndoRedo(const Mode: TgmSelectFigureMode);
var
  HistoryStatePanel: TgmHistoryStatePanel;
begin
  HistoryStatePanel := TgmSelectFigureStatePanel.Create(
    frmHistory.scrlbxHistory,
    dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
    FOldSelectedFigureInfoArray,
    FLayerPanelList.FSelectedFigureInfoArray,
    FOldSelectedFigureLayerIndexArray,
    FLayerPanelList.FSelectedFigureLayerIndexArray,
    Mode);

  FHistoryManager.AddHistoryState(HistoryStatePanel);
end;

procedure TfrmChild.DrawMarchingAnts;
var
  MarchingAntsLine: TgmRectRegionNode;
  StartX, StartY  : Integer;
  EndX, EndY, i   : Integer;
  XOffset, YOffset: Integer;
begin
  MarchingAntsCounter := MarchingAntsCounterStart;

  if Assigned(FSelection) and (FSelection.MarchingAntsLineList.Count > 0) then
  begin
    XOffset := Muldiv(FSelection.FMaskBorderStart.X, FMagnification, 100);
    YOffset := Muldiv(FSelection.FMaskBorderStart.Y, FMagnification, 100);

    for i := 0 to FSelection.MarchingAntsLineList.Count - 1 do
    begin
      // get a Marching-Ants line
      MarchingAntsLine := TgmRectRegionNode(FSelection.MarchingAntsLineList.Items[i]);

      StartX := FLayerTopLeft.X + MulDiv(MarchingAntsLine.StartPoint.X, FMagnification, 100);
      StartY := FLayerTopLeft.Y + MulDiv(MarchingAntsLine.StartPoint.Y, FMagnification, 100);
      EndX   := FLayerTopLeft.X + MulDiv(MarchingAntsLine.EndPoint.X,   FMagnification, 100);
      EndY   := FLayerTopLeft.Y + MulDiv(MarchingAntsLine.EndPoint.Y,   FMagnification, 100);

      { Drawing the Marching-Ants line with LineDDA API call. Note, we should add
        the offset to the starting and ending points of the Marching-Ants line
        for showing it at the right place. }
      LineDDA(StartX + XOffset, StartY + YOffset,
              EndX + XOffset, EndY + YOffset,
              @MarchingAnts, LongInt(imgDrawingArea.Canvas));

    end;
  end;
end;

procedure TfrmChild.RemoveMarchingAnts;
var
  r     : TRect;
  TL, BR: TPoint;
begin
  if Assigned(FSelection) then
  begin
    if FSelection.MarchingAntsLineList.Count > 0 then
    begin
      TL.X := FLayerTopLeft.X + MulDiv(FSelection.FMaskBorderStart.X, FMagnification, 100);
      TL.Y := FLayerTopLeft.Y + MulDiv(FSelection.FMaskBorderStart.Y, FMagnification, 100);
      BR.X := FLayerTopLeft.X + MulDiv(FSelection.FMaskBorderEnd.X,   FMagnification, 100);
      BR.Y := FLayerTopLeft.Y + MulDiv(FSelection.FMaskBorderEnd.Y,   FMagnification, 100);

      r := NormalizeRect( Rect(TL.X, TL.Y, BR.X, BR.Y));

      InflateRect(r, 1, 1);                                   // make the rectangle 1 pixel larger
      InvalidateRect(imgDrawingArea.Canvas.Handle, @r, True); // mark as invalid
      InflateRect(r, -2, -2);                                 // now shrink the rectangle 2 pixels
      ValidateRect(imgDrawingArea.Canvas.Handle, @r);         // walidate new rectangle

      // This leaves a 2 pixel band all the way around
      // the rectangle that will be erased and redrawn
      UpdateWindow(imgDrawingArea.Canvas.Handle);
    end;
  end;
end;

procedure TfrmChild.DeleteSelectionHandleLayer;
begin
  if Assigned(FSelectionHandleLayer)
  then FreeAndNil(FSelectionHandleLayer);
end;

procedure TfrmChild.CommitSelection;
begin
  if Assigned(FSelection) then
  begin
    if FSelection.HasShadow then
    begin
      Screen.Cursor := crHourGlass;
      try
        tmrMarchingAnts.Enabled := False;

        RemoveMarchingAnts;
        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
        
        FreeAndNil(FSelection);
        DeleteSelectionHandleLayer;
        ChangeImageCursorByMarqueeTools;
      finally
        Screen.Cursor := crDefault;
      end;
    end;
  end;
end;

procedure TfrmChild.CancelSelection;
begin
  if Assigned(FLayerPanelList.SelectedLayerPanel) then
  begin
    if Assigned(FSelection) then
    begin
      if FChannelManager.CurrentChannelType = wctAlpha then
      begin
        if not Assigned(FChannelManager.SelectedAlphaChannelPanel) then
        begin
          MessageDlg('Could not process more than one alpha channels at a time.', mtError, [mbOK], 0);
          Exit;
        end;
      end;

      tmrMarchingAnts.Enabled := False;
      RemoveMarchingAnts;

      if FSelection.HasShadow then
      begin
        Screen.Cursor := crHourGlass;
        try
          case FChannelManager.CurrentChannelType of
            wctAlpha:
              begin
                with FChannelManager.SelectedAlphaChannelPanel do
                begin
                  AlphaLayer.Bitmap.Assign(FSelection.SourceBitmap);
                  AlphaLayer.Changed;
                  UpdateThumbnail;
                end;
              end;

            wctQuickMask:
              begin
                with FChannelManager.QuickMaskPanel do
                begin
                  AlphaLayer.Bitmap.Assign(FSelection.SourceBitmap);
                  AlphaLayer.Changed;
                  UpdateThumbnail;
                end;
              end;

            wctLayerMask:
              begin
                FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Assign(FSelection.SourceBitmap);

                if Assigned(FChannelManager.LayerMaskPanel) then
                begin
                  FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(0, 0,
                    FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
                    
                  FChannelManager.LayerMaskPanel.UpdateThumbnail;
                end;

                FLayerPanelList.SelectedLayerPanel.Update;
                FLayerPanelList.SelectedLayerPanel.UpdateMaskThumbnail;
                FLayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
                FChannelManager.UpdateColorChannelThumbnails(FLayerPanelList);
              end;

            wctRGB, wctRed, wctGreen, wctBlue:
              begin
                // must be on layer
                if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                     lfBackground, lfTransparent] then
                begin
                  FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Assign(FSelection.SourceBitmap);
                end;

                if FLayerPanelList.SelectedLayerPanel.IsHasMask then
                begin
                  // get the alpha channels of the current layer and then apply mask on it
                  GetAlphaChannelBitmap(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                                        FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                end;

                FLayerPanelList.SelectedLayerPanel.Update;
                FLayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
                FChannelManager.UpdateColorChannelThumbnails(FLayerPanelList);
              end;
          end;

          FreeAndNil(FSelection);
          DeleteSelectionHandleLayer;
          FLayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
          ChangeImageCursorByMarqueeTools;
        finally
          Screen.Cursor := crDefault;
        end;
      end
      else
      begin
        // if the selection has no "shadow"
        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;  
      end;
    end;
  end;
end; 

procedure TfrmChild.DeleteSelection;
begin
  if Assigned(FLayerPanelList.SelectedLayerPanel) then
  begin
    if Assigned(FSelection) then
    begin
      if FSelection.HasShadow then
      begin
        if FChannelManager.CurrentChannelType = wctAlpha then
        begin
          if not Assigned(FChannelManager.SelectedAlphaChannelPanel) then
          begin
            MessageDlg('Could not process more than one alpha channels at a time.', mtError, [mbOK], 0);
            Exit;
          end;
        end;

        Screen.Cursor := crHourGlass;
        try
          tmrMarchingAnts.Enabled := False;
          RemoveMarchingAnts;

          case FChannelManager.CurrentChannelType of
            wctAlpha:
              begin
                with FChannelManager.SelectedAlphaChannelPanel do
                begin
                  AlphaLayer.Bitmap.Assign(FSelection.Background);
                  AlphaLayer.Changed;
                  UpdateThumbnail;
                end;
              end;

            wctQuickMask:
              begin
                with FChannelManager.QuickMaskPanel do
                begin
                  AlphaLayer.Bitmap.Assign(FSelection.Background);
                  AlphaLayer.Changed;
                  UpdateThumbnail;
                end;
              end;

            wctLayerMask:
              begin
                FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Assign(FSelection.Background);

                // update the mask channel layer
                if Assigned(FChannelManager.LayerMaskPanel) then
                begin
                  FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(0, 0,
                    FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
                end;

                FLayerPanelList.SelectedLayerPanel.Update;
                FLayerPanelList.SelectedLayerPanel.UpdateMaskThumbnail;
                FLayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
                FChannelManager.UpdateColorChannelThumbnails(FLayerPanelList);
              end;

            wctRGB, wctRed, wctGreen, wctBlue:
              begin
                // must be on layer

                if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                     lfBackground, lfTransparent] then
                begin
                  FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Assign(FSelection.Background);
                end;

                if FLayerPanelList.SelectedLayerPanel.IsHasMask then
                begin
                  // get the alpha channels of the current layer and then apply mask on it
                  GetAlphaChannelBitmap(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                                        FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                end;

                FLayerPanelList.SelectedLayerPanel.Update;
                FLayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
                FChannelManager.UpdateColorChannelThumbnails(FLayerPanelList);
              end;
          end;

          FreeAndNil(FSelection);
          DeleteSelectionHandleLayer;
          FLayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
          ChangeImageCursorByMarqueeTools;  
        finally
          Screen.Cursor := crDefault;
        end;
      end;
    end;
  end;
end;

procedure TfrmChild.FreeSelection;
begin
  if Assigned(FSelection) then
  begin
    FreeAndNil(FSelection);
  end;
end;

procedure TfrmChild.FreeCopySelection;
begin
  if Assigned(FSelectionCopy) then
  begin
    FreeAndNil(FSelectionCopy);
  end;
end;

procedure TfrmChild.CreateNewSelection;
begin
  if Assigned(FSelection) then
  begin
    FreeAndNil(FSelection);
  end;

  FSelection := TgmSelection.Create;
end;

procedure TfrmChild.CreateCopySelection;
begin
  if Assigned(FSelectionCopy) then
  begin
    FreeAndNil(FSelectionCopy);
  end;

  FSelectionCopy := TgmSelection.Create;
end;

procedure TfrmChild.CreateSelectionForAll;
begin
  if FChannelManager.CurrentChannelType = wctAlpha then
  begin
    // if the SelectedAlphaChannelPanel is nil, indicates that the user selected more than one alpha channels
    if FChannelManager.SelectedAlphaChannelPanel = nil then
    begin
      MessageDlg('Could not process more than one alpha channels at a time.', mtError, [mbOK], 0);
      Exit;
    end;
  end;

  if frmMain.MainTool <> gmtMarquee then
  begin
    frmMain.spdbtnMarqueeTools.Down := True;
    frmMain.ChangeMainToolClick(frmMain.spdbtnMarqueeTools);
  end;

  if Assigned(FLayerPanelList.SelectedLayerPanel) then
  begin
    // if the selection has not been created, then create one
    if FSelection = nil then
    begin
      FSelection := TgmSelection.Create;

      FSelection.SetOriginalMask(
        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height);

      case FChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            FSelection.SourceBitmap.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
            FSelection.Background.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
          end;

        wctQuickMask:
          begin
            FSelection.SourceBitmap.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
            FSelection.Background.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
          end;

        wctLayerMask:
          begin
            FSelection.SourceBitmap.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
            FSelection.Background.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
            begin
              ReplaceAlphaChannelWithMask(
                FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
            end;
            
            // must be on layer
            FSelection.SourceBitmap.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
            FSelection.Background.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
          end;
      end;
    end;

    if Assigned(FSelection) then
    begin
      tmrMarchingAnts.Enabled := False;
      
      FSelection.SelectAll;
      FSelection.GetActualMaskBorder;
      FSelection.CutRegionFromOriginal;
      FSelection.GetForeground;
      FSelection.GetMarchingAntsLines;

      // filling the background that under the selection, and showing the selection
      case FChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            FSelection.GetBackgroundWithFilledColor(
              Color32(frmMain.BackGrayColor), FChannelManager.ChannelSelectedSet );

            FSelection.ShowSelection(
              FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
              FChannelManager.ChannelSelectedSet);

            FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
          end;

        wctQuickMask:
          begin
            FSelection.GetBackgroundWithFilledColor(
              Color32(frmMain.BackGrayColor), FChannelManager.ChannelSelectedSet );

            FSelection.ShowSelection(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                                     FChannelManager.ChannelSelectedSet);

            FChannelManager.QuickMaskPanel.AlphaLayer.Changed;
          end;

        wctLayerMask:
          begin
            FSelection.GetBackgroundWithFilledColor(
              Color32(frmMain.BackGrayColor), FChannelManager.ChannelSelectedSet );

            FSelection.ShowSelection(
              FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
              FChannelManager.ChannelSelectedSet);

            FLayerPanelList.SelectedLayerPanel.Update;
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            // must be on layer
            case FLayerPanelList.SelectedLayerPanel.LayerFeature of
              lfBackground:
                begin
                  FSelection.GetBackgroundWithFilledColor(
                    Color32(frmMain.GlobalBackColor),
                    FChannelManager.ChannelSelectedSet );
                end;

              lfTransparent:
                begin
                  if (csRed   in FChannelManager.ChannelSelectedSet) and
                     (csGreen in FChannelManager.ChannelSelectedSet) and
                     (csBlue  in FChannelManager.ChannelSelectedSet) then
                  begin
                    FSelection.GetBackgroundWithTransparent;
                  end
                  else
                  begin
                    FSelection.GetBackgroundWithFilledColor(
                      Color32(frmMain.GlobalBackColor),
                      FChannelManager.ChannelSelectedSet );
                  end;
                end;
            end;

            FSelection.ShowSelection(
              FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
              FChannelManager.ChannelSelectedSet);

            FLayerPanelList.SelectedLayerPanel.Update;
          end;
      end;

      RemoveMarchingAnts;
      tmrMarchingAnts.Enabled := True;
      
      frmMain.spdbtnCommitSelection.Enabled := True;
      frmMain.spdbtnDeselect.Enabled        := True;
      frmMain.spdbtnDeleteSelection.Enabled := True;
    end;

    // update selection border
    UpdateSelectionHandleBorder;
  end;
end; 

procedure TfrmChild.CreateSelectionByColorRange;
var
  LTempBmp : TBitmap32;
begin
  if not Assigned(frmColorRangeSelection) then
  begin
    Exit;
  end;

  if frmMain.MainTool <> gmtMarquee then
  begin
    frmMain.spdbtnMarqueeTools.Down := True;
    frmMain.ChangeMainToolClick(frmMain.spdbtnMarqueeTools);
  end;

  if Assigned(FLayerPanelList.SelectedLayerPanel) then
  begin
    // if the selection has not been created, then create one¡£
    if FSelection = nil then
    begin
      FSelection := TgmSelection.Create;

      FSelection.SetOriginalMask(
        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height);

      case FChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            FSelection.SourceBitmap.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
            FSelection.Background.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
          end;

        wctQuickMask:
          begin
            FSelection.SourceBitmap.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
            FSelection.Background.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
          end;

        wctLayerMask:
          begin
            FSelection.SourceBitmap.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
            FSelection.Background.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            LTempBmp := TBitmap32.Create;
            try
              LTempBmp.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

              if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
              begin
                if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                     lfBackground, lfTransparent] then
                begin
                  ReplaceAlphaChannelWithMask(LTempBmp,
                    FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                end;
              end;

              FSelection.SourceBitmap.Assign(LTempBmp);
              FSelection.Background.Assign(LTempBmp);
            finally
              LTempBmp.Free;
            end;
          end;
      end;
    end;

    if Assigned(FSelection) then
    begin
      FSelection.CreateColorRangeRGN(frmColorRangeSelection.SourceBitmap,
                                     frmColorRangeSelection.SampledColor,
                                     frmColorRangeSelection.Fuzziness);

      FSelection.GetActualMaskBorder;

      // if the selection has selected area...
      if FSelection.HasShadow then
      begin
        FSelection.Background.Assign(FSelection.SourceBitmap);
        FSelection.CutRegionFromOriginal;
        FSelection.GetForeground;
        FSelection.GetMarchingAntsLines;

        case FChannelManager.CurrentChannelType of
          wctAlpha:
            begin
              FSelection.GetBackgroundWithFilledColor(
                Color32(frmMain.BackGrayColor), FChannelManager.ChannelSelectedSet );

              FSelection.ShowSelection(
                FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                FChannelManager.ChannelSelectedSet);

              FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
            end;

          wctQuickMask:
            begin
              FSelection.GetBackgroundWithFilledColor(
                Color32(frmMain.BackGrayColor), FChannelManager.ChannelSelectedSet );

              FSelection.ShowSelection(
                FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                FChannelManager.ChannelSelectedSet);

              FChannelManager.QuickMaskPanel.AlphaLayer.Changed;
            end;

          wctLayerMask:
            begin
              FSelection.GetBackgroundWithFilledColor(
                Color32(frmMain.BackGrayColor), FChannelManager.ChannelSelectedSet );

              FSelection.ShowSelection(
                FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                FChannelManager.ChannelSelectedSet);

              FLayerPanelList.SelectedLayerPanel.Update;
            end;

          wctRGB, wctRed, wctGreen, wctBlue:
            begin
              // filling background that beneath the selection
              case FLayerPanelList.SelectedLayerPanel.LayerFeature of
                lfBackground:
                  begin
                    FSelection.GetBackgroundWithFilledColor(
                      Color32(frmMain.GlobalBackColor),
                      FChannelManager.ChannelSelectedSet );
                  end;

                lfTransparent:
                  begin
                    if (csRed   in FChannelManager.ChannelSelectedSet) and
                       (csGreen in FChannelManager.ChannelSelectedSet) and
                       (csBlue  in FChannelManager.ChannelSelectedSet) then
                    begin
                      FSelection.GetBackgroundWithTransparent;
                    end
                    else
                    begin
                      FSelection.GetBackgroundWithFilledColor(
                        Color32(frmMain.GlobalBackColor),
                        FChannelManager.ChannelSelectedSet );
                    end;
                  end;
              end;
              
              FSelection.ShowSelection(
                FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                FChannelManager.ChannelSelectedSet);

              FLayerPanelList.SelectedLayerPanel.Update;
            end;
        end;

        if frmMain.MarqueeTool = mtMoveResize then
        begin
          if FSelectionHandleLayer = nil then
          begin
            CreateSelectionHandleLayer;
          end;
        end;
      end
      else
      begin
        // if the selection does not have the selected area, then delete the it
        MessageDlg('No pixels were selected.', mtWarning, [mbOK], 0);

        case FChannelManager.CurrentChannelType of
          wctAlpha:
            begin
              FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Assign(FSelection.SourceBitmap);
            end;
            
          wctQuickMask:
            begin
              FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.Assign(FSelection.SourceBitmap);
            end;
            
          wctLayerMask:
            begin
              FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Assign(FSelection.SourceBitmap);
            end;

          wctRGB, wctRed, wctGreen, wctBlue:
            begin
              FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Assign(FSelection.SourceBitmap);
            end;
        end;

        FreeAndNil(FSelection);
        DeleteSelectionHandleLayer;
      end;
    end;
  end;
end;

procedure TfrmChild.MakeSelectionInverse;
begin
  if Assigned(FLayerPanelList.SelectedLayerPanel) then
  begin
    if Assigned(FSelection) then
    begin
      if Assigned(FSelectionHandleLayer) then
      begin
        FSelectionHandleLayer.Visible := False;
      end;

      tmrMarchingAnts.Enabled := False;
      FSelection.InvertSelection;
      FSelection.GetActualMaskBorder;

      // if the selection has selected area...
      if FSelection.HasShadow then
      begin
        FSelection.CutRegionFromOriginal;
        FSelection.GetForeground;
        FSelection.GetMarchingAntsLines;

        case FChannelManager.CurrentChannelType of
          wctAlpha:
            begin
              FSelection.GetBackgroundWithFilledColor(
                Color32(frmMain.BackGrayColor), FChannelManager.ChannelSelectedSet );

              FSelection.ShowSelection(
                FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                FChannelManager.ChannelSelectedSet);

              FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
            end;

          wctQuickMask:
            begin
              FSelection.GetBackgroundWithFilledColor(
                Color32(frmMain.BackGrayColor), FChannelManager.ChannelSelectedSet );

              FSelection.ShowSelection(
                FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                FChannelManager.ChannelSelectedSet);

              FChannelManager.QuickMaskPanel.AlphaLayer.Changed;
            end;

          wctLayerMask:
            begin
              FSelection.GetBackgroundWithFilledColor(
                Color32(frmMain.BackGrayColor), FChannelManager.ChannelSelectedSet );

              FSelection.ShowSelection(
                FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                FChannelManager.ChannelSelectedSet);

              FLayerPanelList.SelectedLayerPanel.Update;
            end;

          wctRGB, wctRed, wctGreen, wctBlue:
            begin
              // must be on layer

              // filling background that beneath the selection
              case FLayerPanelList.SelectedLayerPanel.LayerFeature of
                lfBackground:
                  begin
                    FSelection.GetBackgroundWithFilledColor(
                      Color32(frmMain.GlobalBackColor),
                      FChannelManager.ChannelSelectedSet );
                  end;

                lfTransparent:
                  begin
                    if (csRed   in FChannelManager.ChannelSelectedSet) and
                       (csGreen in FChannelManager.ChannelSelectedSet) and
                       (csBlue  in FChannelManager.ChannelSelectedSet) then
                    begin
                      FSelection.GetBackgroundWithTransparent;
                    end
                    else
                    begin
                      FSelection.GetBackgroundWithFilledColor(
                        Color32(frmMain.GlobalBackColor),
                        FChannelManager.ChannelSelectedSet );
                    end;
                  end;
              end;

              if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                   lfBackground, lfTransparent] then
              begin
                FSelection.ShowSelection(
                  FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                  FChannelManager.ChannelSelectedSet);

                FLayerPanelList.SelectedLayerPanel.Update;
              end;
            end;
        end;

        RemoveMarchingAnts;
        tmrMarchingAnts.Enabled := True;

        if frmMain.MarqueeTool = mtMoveResize then
        begin
          if FSelectionHandleLayer = nil then
          begin
            CreateSelectionHandleLayer;
          end;
        end;
      end
      else
      begin
        // if the selection does not have the selected area, then delete the it
        MessageDlg('No pixels were selected.', mtWarning, [mbOK], 0);

        case FChannelManager.CurrentChannelType of
          wctAlpha:
            begin
              FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Assign(FSelection.SourceBitmap);
              FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
            end;

          wctQuickMask:
            begin
              FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.Assign(FSelection.SourceBitmap);
              FChannelManager.QuickMaskPanel.AlphaLayer.Changed;
            end;

          wctLayerMask:
            begin
              FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Assign(FSelection.SourceBitmap);
              FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Changed;
            end;

          wctRGB, wctRed, wctGreen, wctBlue:
            begin
              // must be on layer
              if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                   lfBackground, lfTransparent] then
              begin
                FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Assign(FSelection.SourceBitmap);
                FLayerPanelList.SelectedLayerPanel.Update;
              end;
            end;
        end;

        FreeAndNil(FSelection);
        DeleteSelectionHandleLayer;
      end;
    end;
  end;
end; 

function TfrmChild.MakeSelectionFeather: Boolean;
var
  LNewFeatherRadius : Integer;
  LOldFeatherRadius : Integer;
begin
  Result := False;

  if Assigned(FLayerPanelList.SelectedLayerPanel) then
  begin
    if Assigned(FSelection) then
    begin
      LOldFeatherRadius := FSelection.FeatherRadius;
      LNewFeatherRadius := StrToInt(ReadInfoFromIniFile(SECTION_SELECTION, IDENT_FEATHER_RADIUS, '0'));

      // feathering selection
      FSelection.FeatherRadius := LNewFeatherRadius;

      { NOTE: if the FeatherRadius is set a value that is greater then zero,
        and the GetActualMaskBorder() finds that after added the FeatherRadius,
        the selection border will out of the image border, the function
        will set the FeatherRadius back to zero. }

      FSelection.GetActualMaskBorder;

      // set feather radius failed...
      if (LNewFeatherRadius > 0) and
         (FSelection.FeatherRadius = 0) then
      begin
        MessageDlg('The feather radius is out of the range.', mtError, [mbOK], 0);

        FSelection.FeatherRadius := LOldFeatherRadius;
        FSelection.GetActualMaskBorder; // get the old border
      end
      else
      begin
        FSelection.CutRegionFromOriginal;
        FSelection.GetForeground;
        FSelection.GetMarchingAntsLines;

        case FChannelManager.CurrentChannelType of
          wctAlpha:
            begin
              FSelection.GetBackgroundWithFilledColor(
                Color32(frmMain.BackGrayColor), FChannelManager.ChannelSelectedSet );

              FSelection.ShowSelection(
                FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                FChannelManager.ChannelSelectedSet);

              FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
              FChannelManager.SelectedAlphaChannelPanel.UpdateThumbnail;
            end;

          wctQuickMask:
            begin
              FSelection.GetBackgroundWithFilledColor(
                Color32(frmMain.BackGrayColor), FChannelManager.ChannelSelectedSet );

              FSelection.ShowSelection(
                FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                FChannelManager.ChannelSelectedSet);

              FChannelManager.QuickMaskPanel.AlphaLayer.Changed;
              FChannelManager.QuickMaskPanel.UpdateThumbnail;
            end;

          wctLayerMask:
            begin
              FSelection.GetBackgroundWithFilledColor(
                Color32(frmMain.BackGrayColor), FChannelManager.ChannelSelectedSet );

              FSelection.ShowSelection(
                FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                FChannelManager.ChannelSelectedSet);

              if Assigned(FChannelManager.LayerMaskPanel) then
              begin
                FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(
                  0, 0, FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
              end;

              FLayerPanelList.SelectedLayerPanel.Update;
              FLayerPanelList.SelectedLayerPanel.UpdateMaskThumbnail;
              FLayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
              FChannelManager.UpdateColorChannelThumbnails(FLayerPanelList);
            end;

          wctRGB, wctRed, wctGreen, wctBlue:
            begin
              // filling background that beneath the selection
              case FLayerPanelList.SelectedLayerPanel.LayerFeature of
                lfBackground:
                  begin
                    FSelection.GetBackgroundWithFilledColor(
                      Color32(frmMain.GlobalBackColor),
                      FChannelManager.ChannelSelectedSet );
                  end;

                lfTransparent:
                  begin
                    if (csRed   in FChannelManager.ChannelSelectedSet) and
                       (csGreen in FChannelManager.ChannelSelectedSet) and
                       (csBlue  in FChannelManager.ChannelSelectedSet) then
                    begin
                      FSelection.GetBackgroundWithTransparent;
                    end
                    else
                    begin
                      FSelection.GetBackgroundWithFilledColor(
                        Color32(frmMain.GlobalBackColor),
                        FChannelManager.ChannelSelectedSet );
                    end;
                  end;
              end;

              FSelection.ShowSelection(
                FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                FChannelManager.ChannelSelectedSet);

              FLayerPanelList.SelectedLayerPanel.Update;
              FLayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
              FChannelManager.UpdateColorChannelThumbnails(FLayerPanelList);
            end;
        end;

        FSelection.IsFeathered := True;
        Result                 := True;
      end;
    end;
  end;
end; 

// finish current definition of the polyonal selection and prepare to define a new one
procedure TfrmChild.FinishPolygonalSelection;
var
  LPolygonalRegion   : TgmPolygonalRegion;
  LCmdAim            : TCommandAim;
  LHistoryStatePanel : TgmHistoryStatePanel;
begin
  if Assigned(FLayerPanelList.SelectedLayerPanel) and
     Assigned(FRegion) then
  begin
    if FRegion.RegionStyle = gmrsPolygonal then
    begin
      // remember the old selection (if any) for Undo/Redo
      if Assigned(FSelection) and FSelection.HasShadow then
      begin
        if FSelectionCopy = nil then
        begin
          FSelectionCopy := TgmSelection.Create;
        end;

        FSelectionCopy.AssignAllSelectionData(FSelection);
      end
      else
      begin
        if Assigned(FSelectionCopy) then
        begin
          FreeAndNil(FSelectionCopy);
        end;
      end;

      LPolygonalRegion := TgmPolygonalRegion(FRegion);

      if not LPolygonalRegion.IsRegionDefineCompleted then
      begin
        // force to close the polygonal region
        LPolygonalRegion.ClosePolgonalRegion;
      end;

      if LPolygonalRegion.IsValidRegion then
      begin
        // create the polygonal selection
        if FSelection = nil then
        begin
          FSelection := TgmSelection.Create;

          FSelection.SetOriginalMask(
            FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
            FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height);

          case FChannelManager.CurrentChannelType of
            wctAlpha:
              begin
                if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
                begin
                  FSelection.SourceBitmap.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
                  FSelection.Background.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
                end;
              end;

            wctQuickMask:
              begin
                FSelection.SourceBitmap.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
                FSelection.Background.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
              end;

            wctLayerMask:
              begin
                FSelection.SourceBitmap.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
                FSelection.Background.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
              end;

            wctRGB, wctRed, wctGreen, wctBlue:
              begin
                // must be on layer
                if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                begin
                  ReplaceAlphaChannelWithMask(
                    FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                    FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                end;

                // these methods must be called
                FSelection.SourceBitmap.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
                FSelection.Background.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
              end;
          end;
        end;

        FSelection.CreateCustomRGN(LPolygonalRegion.Region, frmMain.MarqueeMode);

        FSelection.GetActualMaskBorder;
        FSelection.CutRegionFromOriginal;
        FSelection.GetForeground;
        FSelection.GetMarchingAntsLines;

        // filling the backgound that under the selection
        if FChannelManager.CurrentChannelType in [
             wctAlpha, wctQuickMask, wctLayerMask] then
        begin
          FSelection.GetBackgroundWithFilledColor(
            Color32(frmMain.BackGrayColor), FChannelManager.ChannelSelectedSet );
        end
        else // must be on layer
        begin
          case FLayerPanelList.SelectedLayerPanel.LayerFeature of
            lfBackground:
              begin
                FSelection.GetBackgroundWithFilledColor(
                  Color32(frmMain.GlobalBackColor),
                  FChannelManager.ChannelSelectedSet );
              end;

            lfTransparent:
              begin
                if (csRed   in FChannelManager.ChannelSelectedSet) and
                   (csGreen in FChannelManager.ChannelSelectedSet) and
                   (csBlue  in FChannelManager.ChannelSelectedSet) then
                begin
                  FSelection.GetBackgroundWithTransparent;
                end
                else
                begin
                  FSelection.GetBackgroundWithFilledColor(
                    Color32(frmMain.GlobalBackColor), FChannelManager.ChannelSelectedSet );
                end;
              end;
          end;
        end;

        // if the selection is created incorrectly, then delete it
        if FSelection.HasShadow = False then
        begin
          case FChannelManager.CurrentChannelType of
            wctAlpha:
              begin
                if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
                begin
                  FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Assign(FSelection.SourceBitmap);
                  FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
                end;
              end;

            wctQuickMask:
              begin
                FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.Assign(FSelection.SourceBitmap);
                FChannelManager.QuickMaskPanel.AlphaLayer.Changed;
              end;

            wctLayerMask:
              begin
                FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Assign(FSelection.SourceBitmap);
                FLayerPanelList.SelectedLayerPanel.Update;
              end;

            wctRGB, wctRed, wctGreen, wctBlue:
              begin
                // must be on layer
                if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                     lfBackground, lfTransparent] then
                begin
                  FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Assign(FSelection.SourceBitmap);
                  FLayerPanelList.SelectedLayerPanel.Update;
                end;
              end;
          end;

          FreeAndNil(FSelection);
      
          tmrMarchingAnts.Enabled := False;

          frmMain.spdbtnCommitSelection.Enabled := False;
          frmMain.spdbtnDeselect.Enabled        := False;
          frmMain.spdbtnDeleteSelection.Enabled := False;
        end
        else
        begin
          ShowProcessedSelection;

          tmrMarchingAnts.Enabled := True;

          frmMain.spdbtnCommitSelection.Enabled := True;
          frmMain.spdbtnDeselect.Enabled        := True;
          frmMain.spdbtnDeleteSelection.Enabled := True;

          if (frmMain.MainTool = gmtMarquee) and
             (frmMain.MarqueeTool = mtMoveResize) then
          begin
            CreateSelectionHandleLayer;
          end;

          // Create Undo/Redo for selection.
          LCmdAim := GetCommandAimByCurrentChannel;

          LHistoryStatePanel := TgmSelectionStatePanel.Create(
            frmHistory.scrlbxHistory,
            dmHistory.bmp32lstHistory.Bitmap[POLY_MARQUEE_COMMAND_ICON_INDEX],
            LCmdAim,
            frmMain.MarqueeTool,
            sctNew,
            FSelectionCopy,
            FSelection,
            FChannelManager.SelectedAlphaChannelIndex);

          FHistoryManager.AddHistoryState(LHistoryStatePanel);
        end;
      end;
    end;

    FreeAndNil(FRegion);
  end;
end;

procedure TfrmChild.ChangeSelectionTarget;
begin
  if Assigned(FLayerPanelList.SelectedLayerPanel) then
  begin
    if Assigned(FSelection) then
    begin
      tmrMarchingAnts.Enabled := False;

      FSelection.IsTranslated      := False;
      FSelection.IsCornerStretched := False;
      FSelection.IsHorizFlipped    := False;
      FSelection.IsVertFlipped     := False;

      // setting the background for the selection
      case FChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
            begin
              FSelection.SourceBitmap.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
              FSelection.Background.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
            end;
          end;

        wctQuickMask:
          begin
            FSelection.SourceBitmap.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
            FSelection.Background.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
          end;

        wctLayerMask:
          begin
            FSelection.SourceBitmap.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
            FSelection.Background.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
            begin
              ReplaceAlphaChannelWithMask(
                FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
            end;

            FSelection.SourceBitmap.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
            FSelection.Background.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
          end;
      end;

      // make the original mask of the selection same as its resized mask
      FSelection.OriginalMask.SetSize(
        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height);
                                      
      FSelection.OriginalMask.Clear(clBlack32);

      FSelection.OriginalMask.Draw(FSelection.FMaskBorderStart.X,
                                   FSelection.FMaskBorderStart.Y,
                                   FSelection.ResizedMask);

      FSelection.MakeRegionWithMask(FSelection.OriginalMask);
      FSelection.GetActualMaskBorder;
      FSelection.CutRegionFromOriginal;
      FSelection.GetForeground;
      FSelection.GetMarchingAntsLines;

      // filling the background that under the selection, and show the selection
      case FChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
            begin
              FSelection.GetBackgroundWithFilledColor(
                Color32(frmMain.BackGrayColor), FChannelManager.ChannelSelectedSet );

              FSelection.ShowSelection(
                FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                FChannelManager.ChannelSelectedSet);

              FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Changed;
            end;
          end;

        wctQuickMask:
          begin
            FSelection.GetBackgroundWithFilledColor(
              Color32(frmMain.BackGrayColor), FChannelManager.ChannelSelectedSet );

            FSelection.ShowSelection(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                                     FChannelManager.ChannelSelectedSet);

            FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.Changed;
          end;

        wctLayerMask:
          begin
            FSelection.GetBackgroundWithFilledColor(
              Color32(frmMain.BackGrayColor), FChannelManager.ChannelSelectedSet );

            FSelection.ShowSelection(
              FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
              FChannelManager.ChannelSelectedSet);

            FLayerPanelList.SelectedLayerPanel.Update;
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            case FLayerPanelList.SelectedLayerPanel.LayerFeature of
              lfBackground:
                begin
                  FSelection.GetBackgroundWithFilledColor(
                    Color32(frmMain.GlobalBackColor),
                    FChannelManager.ChannelSelectedSet );
                end;

              lfTransparent:
                begin
                  if (csRed   in FChannelManager.ChannelSelectedSet) and
                     (csGreen in FChannelManager.ChannelSelectedSet) and
                     (csBlue  in FChannelManager.ChannelSelectedSet) then
                  begin
                    FSelection.GetBackgroundWithTransparent;
                  end
                  else
                  begin
                    FSelection.GetBackgroundWithFilledColor(
                      Color32(frmMain.GlobalBackColor),
                      FChannelManager.ChannelSelectedSet );
                  end;
                end;
            end;
            
            FSelection.ShowSelection(
              FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
              FChannelManager.ChannelSelectedSet);

            FLayerPanelList.SelectedLayerPanel.Update;
          end;
      end;

      FSelection.IsTargetChanged := True;
      tmrMarchingAnts.Enabled    := True;
    end;
  end;
end; 

// showing the selection
procedure TfrmChild.ShowProcessedSelection(const UpdateDisplay: Boolean = True);
begin
  if Assigned(FSelection) then
  begin
    // update the foregound of the selection
    FSelection.GetForeground;

    case FChannelManager.CurrentChannelType of
      wctAlpha:
        begin
          if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
          begin
            if Assigned(FSelectionTransformation) and
               FSelectionTransformation.IsTransforming then
            begin
              FSelectionTransformation.ShowTransformedSelection(
                FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                FChannelManager.ChannelSelectedSet);
            end
            else
            begin
              FSelection.ShowSelection(
                FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                FChannelManager.ChannelSelectedSet);
            end;

            if UpdateDisplay then
            begin
              FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
            end;
          end;
        end;

      wctQuickMask:
        begin
          if Assigned(FSelectionTransformation) and
             FSelectionTransformation.IsTransforming then
          begin
            FSelectionTransformation.ShowTransformedSelection(
              FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
              FChannelManager.ChannelSelectedSet);
          end
          else
          begin
            FSelection.ShowSelection(
              FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
              FChannelManager.ChannelSelectedSet);
          end;

          if UpdateDisplay then
          begin
            FChannelManager.QuickMaskPanel.AlphaLayer.Changed;
          end;
        end;

      wctLayerMask:
        begin
          if Assigned(FSelectionTransformation) and
             FSelectionTransformation.IsTransforming then
          begin
            FSelectionTransformation.ShowTransformedSelection(
              FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
              FChannelManager.ChannelSelectedSet);
          end
          else
          begin
            FSelection.ShowSelection(
              FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
              FChannelManager.ChannelSelectedSet);
          end;

          // update the mask channel preview layer
          if FChannelManager.LayerMaskPanel.IsChannelVisible then
          begin
            FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(0, 0,
              FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
          end;

          // on special layers, save the new mask into its alpha channels
          if FLayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
          begin
            FLayerPanelList.SelectedLayerPanel.UpdateLayerAlphaWithMask;
          end;
        end;

      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          if Assigned(FSelectionTransformation) and
             FSelectionTransformation.IsTransforming then
          begin
            FSelectionTransformation.ShowTransformedSelection(
              FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
              FChannelManager.ChannelSelectedSet);
          end
          else
          begin
            FSelection.ShowSelection(
              FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
              FChannelManager.ChannelSelectedSet);
          end;

          // save the new alpha channels
          GetAlphaChannelBitmap(
            FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
            FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
        end;
    end;

    if UpdateDisplay then
    begin
      if FChannelManager.CurrentChannelType in [
           wctRGB, wctRed, wctGreen, wctBlue, wctLayerMask] then
      begin
        FLayerPanelList.SelectedLayerPanel.Update;
      end;

      imgDrawingArea.Update;
      DrawMarchingAnts;
    end;
  end;
end; 

procedure TfrmChild.ShowSelectionAtBrushStroke(const ARect: TRect);
var
  LRefreshRect: TRect;
begin
  if Assigned(FSelection) then
  begin
    // update the foregound of the selection
    FSelection.GetForeground;

    case FChannelManager.CurrentChannelType of
      wctAlpha:
        begin
          if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
          begin
            FSelection.ShowSelection(
              FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
              FChannelManager.ChannelSelectedSet, ARect);

            // selection space to bitmap space
            LRefreshRect.TopLeft     := FSelection.SelectionPointToBitmapPoint(ARect.TopLeft);
            LRefreshRect.BottomRight := FSelection.SelectionPointToBitmapPoint(ARect.BottomRight);
            
            // bitmap space to control space
            LRefreshRect.TopLeft     := imgDrawingArea.BitmapToControl(LRefreshRect.TopLeft);
            LRefreshRect.BottomRight := imgDrawingArea.BitmapToControl(LRefreshRect.BottomRight);

            FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed(LRefreshRect);
          end;
        end;

      wctQuickMask:
        begin
          FSelection.ShowSelection(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                                   FChannelManager.ChannelSelectedSet, ARect);

          // selection space to bitmap space
          LRefreshRect.TopLeft     := FSelection.SelectionPointToBitmapPoint(ARect.TopLeft);
          LRefreshRect.BottomRight := FSelection.SelectionPointToBitmapPoint(ARect.BottomRight);

          // bitmap space to control space
          LRefreshRect.TopLeft     := imgDrawingArea.BitmapToControl(LRefreshRect.TopLeft);
          LRefreshRect.BottomRight := imgDrawingArea.BitmapToControl(LRefreshRect.BottomRight);

          FChannelManager.QuickMaskPanel.AlphaLayer.Changed(LRefreshRect);
        end;

      wctLayerMask:
        begin
          FSelection.ShowSelection(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                                   FChannelManager.ChannelSelectedSet, ARect);

          // update the mask channel preview layer
          if Assigned(FChannelManager.LayerMaskPanel) then
          begin
            FSelection.ShowSelection(FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap,
                                     FChannelManager.ChannelSelectedSet, ARect);
          end;

          // on special layers, save the new mask into its alpha channels
          if FLayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
          begin
            // selection space to bitmap space
            LRefreshRect.TopLeft     := FSelection.SelectionPointToBitmapPoint(ARect.TopLeft);
            LRefreshRect.BottomRight := FSelection.SelectionPointToBitmapPoint(ARect.BottomRight);

            // save the mask into layer's alpha channel
            FLayerPanelList.SelectedLayerPanel.UpdateLayerAlphaWithMask(LRefreshRect);
          end;
        end;

      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          // selection space to bitmap space
          LRefreshRect.TopLeft     := FSelection.SelectionPointToBitmapPoint(ARect.TopLeft);
          LRefreshRect.BottomRight := FSelection.SelectionPointToBitmapPoint(ARect.BottomRight);

          // must using bitmap space rect to restore the background
          FSelection.RestoreBackground(
            FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
            LRefreshRect);

          FSelection.ShowSelection(
            FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
            FChannelManager.ChannelSelectedSet, ARect);


          // save the new alpha channels
          GetAlphaChannelBitmap(
            FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
            FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
            LRefreshRect);
        end;
    end;

    if FChannelManager.CurrentChannelType in [
         wctRGB, wctRed, wctGreen, wctBlue, wctLayerMask] then
    begin
      // selection space to bitmap space
      LRefreshRect.TopLeft     := FSelection.SelectionPointToBitmapPoint(ARect.TopLeft);
      LRefreshRect.BottomRight := FSelection.SelectionPointToBitmapPoint(ARect.BottomRight);

      if not FLayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
      begin
        if FLayerPanelList.SelectedLayerPanel.IsHasMask then
        begin
          ApplyMask(LRefreshRect); // note, pass it the bitmap space rect
        end
        else
        begin
          // bitmap space to control space
          LRefreshRect.TopLeft     := imgDrawingArea.BitmapToControl(LRefreshRect.TopLeft);
          LRefreshRect.BottomRight := imgDrawingArea.BitmapToControl(LRefreshRect.BottomRight);
          FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(LRefreshRect);
        end;
      end
      else
      begin
        // bitmap space to control space
        LRefreshRect.TopLeft     := imgDrawingArea.BitmapToControl(LRefreshRect.TopLeft);
        LRefreshRect.BottomRight := imgDrawingArea.BitmapToControl(LRefreshRect.BottomRight);
        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(LRefreshRect);
      end;
    end;

    //imgDrawingArea.Update;
    DrawMarchingAnts;
  end;
end; 

procedure TfrmChild.CreateSelectionHandleLayer;
var
  LayerHalfW, LayerHalfH: Single;
  CenterPoint           : TPoint;
begin
  if FSelectionHandleLayer = nil then
  begin
    FSelectionHandleLayer := TBitmapLayer.Create(imgDrawingArea.Layers);

    with FSelectionHandleLayer do
    begin
      Bitmap.DrawMode       := dmCustom;
      Bitmap.OnPixelCombine := GrayNotXorLayerBlend;
      Bitmap.Width          := Screen.Width;
      Bitmap.Height         := Screen.Height;
      LayerHalfW            := Bitmap.Width  / 2;
      LayerHalfH            := Bitmap.Height / 2;
    end;

    // get the center point of the viewport of the TImage32 and convert it from control space to bitmap space
    with imgDrawingArea.GetViewportRect do
      CenterPoint := imgDrawingArea.ControlToBitmap(  Point( (Right + Left) div 2, (Top + Bottom) div 2 )  );

    // setting the location of the handle layer
    with FSelectionHandleLayer do
    begin
      Location := FloatRect(CenterPoint.X - LayerHalfW, CenterPoint.Y - LayerHalfH,
                            CenterPoint.X + LayerHalfW, CenterPoint.Y + LayerHalfH);

      Scaled   := True;
      Bitmap.Clear($00000000);
    end;

    // calculate the offset vector of the handle layer relative to the image layer
    CalcSelectionHandleLayerOffsetVector;
  end;
end;

procedure TfrmChild.UpdateSelectionHandleBorder;
var
  LDrawHandles: Boolean;
begin
  LDrawHandles := False;

  if Assigned(FSelection) then
  begin
    if frmMain.MainTool = gmtMarquee then
    begin
      if frmMain.MarqueeTool = mtMoveResize then
      begin
        if FSelectionHandleLayer = nil then
        begin
          CreateSelectionHandleLayer;
        end;

        FSelectionHandleLayer.Bitmap.Clear($00000000);

        case FChannelManager.CurrentChannelType of
          wctAlpha:
            begin
              if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
              begin
                LDrawHandles := True;
              end;
            end;

          wctQuickMask, wctLayerMask:
            begin
              LDrawHandles := True;
            end;

          wctRGB, wctRed, wctGreen, wctBlue:
            begin
              if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                   lfBackground, lfTransparent] then
              begin
                LDrawHandles := True;
              end;
            end;
        end;

        FSelection.DrawMarchingAntsBorder(FSelectionHandleLayer.Bitmap.Canvas,
                                          FSelectionHandleLayerOffsetVector.X,
                                          FSelectionHandleLayerOffsetVector.Y,
                                          LDrawHandles);

        if not FSelectionHandleLayer.Visible then
        begin
          FSelectionHandleLayer.Visible := True;
        end;
      end
      else
      begin
        DeleteSelectionHandleLayer;
      end;
    end
    else
    begin
      DeleteSelectionHandleLayer;
    end;
  end;
end;

procedure TfrmChild.ShowSelectionHandleBorder;
begin
  // show selection border
  if frmMain.MainTool = gmtMarquee then
  begin
    if frmMain.MarqueeTool = mtMoveResize then
    begin
      if Assigned(FSelection) and Assigned(SelectionHandleLayer) then
      begin
        SelectionHandleLayer.Visible := True;
      end;
    end;
  end;
end;

procedure TfrmChild.PauseMarchingAnts;
begin
  if tmrMarchingAnts.Enabled = True then
  begin
    tmrMarchingAnts.Enabled := False;
  end;

  if Assigned(FSelection) then
  begin
    RemoveMarchingAnts;
    DrawMarchingAnts;
  end;
end;

procedure TfrmChild.ChangeImageCursorByMarqueeTools;
begin
  case frmMain.MarqueeMode of
    mmNew:
      begin
        if frmMain.MarqueeTool in [mtRectangular, mtRoundRectangular,
                                   mtElliptical, mtSingleRow,
                                   mtSingleColumn, mtRegularPolygon] then
        begin
          imgDrawingArea.Cursor := crCross;
        end
        else
        if frmMain.MarqueeTool = mtPolygonal then
        begin
          imgDrawingArea.Cursor := crPolygonSelection;
        end
        else
        if frmMain.MarqueeTool = mtLasso then
        begin
          imgDrawingArea.Cursor := crLassoSelection;
        end
        else
        if frmMain.MarqueeTool = mtMagicWand then
        begin
          imgDrawingArea.Cursor := crMagicWand;
        end;
      end;

    mmAdd:
      begin
        if frmMain.MarqueeTool in [mtRectangular, mtRoundRectangular,
                                   mtElliptical, mtSingleRow,
                                   mtSingleColumn, mtRegularPolygon] then
        begin
          if FSelection <> nil then
          begin
            imgDrawingArea.Cursor := crCrossAdd;
          end
          else
          begin
            imgDrawingArea.Cursor := crCross;
          end;
        end
        else
        if frmMain.MarqueeTool = mtPolygonal then
        begin
          if FSelection <> nil then
          begin
            imgDrawingArea.Cursor := crPolygonAdd;
          end
          else
          begin
            imgDrawingArea.Cursor := crPolygonSelection;
          end;
        end
        else
        if frmMain.MarqueeTool = mtLasso then
        begin
          if FSelection <> nil then
          begin
            imgDrawingArea.Cursor := crLassoAdd;
          end
          else
          begin
            imgDrawingArea.Cursor := crLassoSelection;
          end
        end
        else
        if frmMain.MarqueeTool = mtMagicWand then
        begin
          if FSelection <> nil then
          begin
            imgDrawingArea.Cursor := crMagicWandAdd;
          end
          else
          begin
            imgDrawingArea.Cursor := crMagicWand;
          end;
        end;
      end;

    mmSubtract:
      begin
        if frmMain.MarqueeTool in [mtRectangular, mtRoundRectangular,
                                   mtElliptical, mtSingleRow,
                                   mtSingleColumn, mtRegularPolygon] then
        begin
          if FSelection <> nil then
          begin
            imgDrawingArea.Cursor := crCrossSub;
          end
          else
          begin
            imgDrawingArea.Cursor := crCross;
          end;
        end
        else
        if frmMain.MarqueeTool = mtPolygonal then
        begin
          if FSelection <> nil then
          begin
            imgDrawingArea.Cursor := crPolygonSub;
          end
          else
          begin
            imgDrawingArea.Cursor := crPolygonSelection;
          end;
        end
        else
        if frmMain.MarqueeTool = mtLasso then
        begin
          if FSelection <> nil then
          begin
            imgDrawingArea.Cursor := crLassoSub;
          end
          else
          begin
            imgDrawingArea.Cursor := crLassoSelection;
          end;
        end
        else
        if frmMain.MarqueeTool = mtMagicWand then
        begin
          if FSelection <> nil then
          begin
            imgDrawingArea.Cursor := crMagicWandSub;
          end
          else
          begin
            imgDrawingArea.Cursor := crMagicWand;
          end;
        end;
      end;

    mmIntersect:
      begin
        if frmMain.MarqueeTool in [mtRectangular, mtRoundRectangular,
                                   mtElliptical, mtSingleRow,
                                   mtSingleColumn, mtRegularPolygon] then
        begin
          if FSelection <> nil then
          begin
            imgDrawingArea.Cursor := crCrossIntersect;
          end
          else
          begin
            imgDrawingArea.Cursor := crCross;
          end;
        end
        else
        if frmMain.MarqueeTool = mtPolygonal then
        begin
          if FSelection <> nil then
          begin
            imgDrawingArea.Cursor := crPolygonIntersect;
          end
          else
          begin
            imgDrawingArea.Cursor := crPolygonSelection;
          end;
        end
        else
        if frmMain.MarqueeTool = mtLasso then
        begin
          if FSelection <> nil then
          begin
            imgDrawingArea.Cursor := crLassoIntersect;
          end
          else
          begin
            imgDrawingArea.Cursor := crLassoSelection;
          end;
        end
        else
        if frmMain.MarqueeTool = mtMagicWand then
        begin
          if FSelection <> nil then
          begin
            imgDrawingArea.Cursor := crMagicWandIntersect;
          end
          else
          begin
            imgDrawingArea.Cursor := crMagicWand;
          end;
        end;
      end;

    mmExcludeOverlap:
      begin
        if frmMain.MarqueeTool in [mtRectangular, mtRoundRectangular,
                                   mtElliptical, mtSingleRow,
                                   mtSingleColumn, mtRegularPolygon] then
        begin
          if FSelection <> nil then
          begin
            imgDrawingArea.Cursor := crCrossInterSub;
          end
          else
          begin
            imgDrawingArea.Cursor := crCross;
          end;
        end
        else
        if frmMain.MarqueeTool = mtPolygonal then
        begin
          if FSelection <> nil then
          begin
            imgDrawingArea.Cursor := crPolygonInterSub;
          end
          else
          begin
            imgDrawingArea.Cursor := crPolygonSelection;
          end;
        end
        else
        if frmMain.MarqueeTool = mtLasso then
        begin
          if FSelection <> nil then
          begin
            imgDrawingArea.Cursor := crLassoInterSub;
          end
          else
          begin
            imgDrawingArea.Cursor := crLassoSelection;
          end;
        end
        else
        if frmMain.MarqueeTool = mtMagicWand then
        begin
          if FSelection <> nil then
          begin
            imgDrawingArea.Cursor := crMagicWandInterSub;
          end
          else
          begin
            imgDrawingArea.Cursor := crMagicWand;
          end;
        end;
      end;
  end;

  if frmMain.MarqueeTool = mtMoveResize then
  begin
    imgDrawingArea.Cursor := crMoveSelection;
  end
  else
  if frmMain.MarqueeTool = mtMagneticLasso then
  begin
    imgDrawingArea.Cursor := crMagneticLasso;
  end
end;

// calculate the offset vector of the selection handle layer relative to the image layer
procedure TfrmChild.CalcSelectionHandleLayerOffsetVector;
var
  HandleLayerLeft : Single;
  HandleLayerTop  : Single;
  CurrentLayerLeft: Single;
  CurrentLayerTop : Single;
  TheScale        : Single;
begin
  if Assigned(FSelectionHandleLayer) then
  begin
    TheScale         := 100 / FMagnification;
    HandleLayerLeft  := FSelectionHandleLayer.GetAdjustedLocation.Left * TheScale;
    HandleLayerTop   := FSelectionHandleLayer.GetAdjustedLocation.Top  * TheScale;
    CurrentLayerLeft := FLayerPanelList.SelectedLayerPanel.AssociatedLayer.GetAdjustedLocation.Left * TheScale;
    CurrentLayerTop  := FLayerPanelList.SelectedLayerPanel.AssociatedLayer.GetAdjustedLocation.Top  * TheScale;

    FSelectionHandleLayerOffsetVector.X := Round(CurrentLayerLeft - HandleLayerLeft);
    FSelectionHandleLayerOffsetVector.Y := Round(CurrentLayerTop  - HandleLayerTop);
  end;
end; 

// create temporary layer for showing magnetic lasso
procedure TfrmChild.CreateLassoLayer;
var
  LHalfWidth, LHalfHeight: Single;
  LCenterPoint           : TPoint;
begin
  if not Assigned(FMagneticLassoLayer) then
  begin
    FMagneticLassoLayer := TBitmapLayer.Create(imgDrawingArea.Layers);

    FMagneticLassoLayer.Bitmap.DrawMode       := dmCustom;
    FMagneticLassoLayer.Bitmap.OnPixelCombine := GrayNotXorLayerBlend;

    FMagneticLassoLayer.Bitmap.SetSize(imgDrawingArea.Bitmap.Width,
                                       imgDrawingArea.Bitmap.Height);
                                       
    FMagneticLassoLayer.Bitmap.Clear($00000000);

    LHalfWidth  := FMagneticLassoLayer.Bitmap.Width  / 2;
    LHalfHeight := FMagneticLassoLayer.Bitmap.Height / 2;

    { Get the center point of the viewport of the TImage32/TImgView32 and
      convert it from control space to bitmap space. }
    with imgDrawingArea.GetViewportRect do
    begin
      LCenterPoint := imgDrawingArea.ControlToBitmap(
        Point( (Right + Left) div 2, (Top + Bottom) div 2 )  );
    end;
    
    // setting the location of the layer
    FMagneticLassoLayer.Location := FloatRect(LCenterPoint.X - LHalfWidth,
                                              LCenterPoint.Y - LHalfHeight,
                                              LCenterPoint.X + LHalfWidth,
                                              LCenterPoint.Y + LHalfHeight);

    FMagneticLassoLayer.Scaled := True;

    // calculate the offset vector of the lasso layer relative to the image layer
    CalcLassoLayerOffsetVector;
  end;
end;

// calculate the offset vector of the lasso layer relative to the image bitmap
procedure TfrmChild.CalcLassoLayerOffsetVector;
var
  LLassoLayerLeft: Single;
  LLassoLayerTop : Single;
  LRect          : TRect;
begin
  if Assigned(FMagneticLassoLayer) then
  begin
    LLassoLayerLeft := FMagneticLassoLayer.GetAdjustedLocation.Left;
    LLassoLayerTop  := FMagneticLassoLayer.GetAdjustedLocation.Top;

    LRect := imgDrawingArea.GetBitmapRect;

    FLassoLayerOffsetX := Round(LRect.Left - LLassoLayerLeft);
    FLassoLayerOffsetY := Round(LRect.Top  - LLassoLayerTop);
  end;
end;

procedure TfrmChild.FinishMagneticLasso;
var
  LCmdAim            : TCommandAim;
  LHistoryStatePanel : TgmHistoryStatePanel;
begin
  if Assigned(FLayerPanelList.SelectedLayerPanel) and
     Assigned(FMagneticLasso) then
  begin
    if FMagneticLasso.IsConnected then
    begin
      // remember the old selection (if any) for Undo/Redo
      if Assigned(FSelection) and FSelection.HasShadow then
      begin
        if FSelectionCopy = nil then
        begin
          FSelectionCopy := TgmSelection.Create;
        end;

        FSelectionCopy.AssignAllSelectionData(FSelection);
      end
      else
      begin
        if Assigned(FSelectionCopy) then
        begin
          FreeAndNil(FSelectionCopy);
        end;
      end;

      // if there is no selection, create one
      if not Assigned(FSelection) then
      begin
        // any of the following lines could not be absent
        FSelection := TgmSelection.Create;

        FSelection.SetOriginalMask(
          FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
          FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height);

        case FChannelManager.CurrentChannelType of
          wctAlpha:
            begin
              if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
              begin
                FSelection.SourceBitmap.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
                FSelection.Background.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
              end;
            end;

          wctQuickMask:
            begin
              FSelection.SourceBitmap.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
              FSelection.Background.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
            end;

          wctLayerMask:
            begin
              FSelection.SourceBitmap.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
              FSelection.Background.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
            end;

          wctRGB, wctRed, wctGreen, wctBlue:
            begin
              // must be on layer
              if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
              begin
                ReplaceAlphaChannelWithMask(
                  FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                  FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
              end;

              // these methods must be called
              FSelection.SourceBitmap.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
              FSelection.Background.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
            end;
        end;
      end;

      FSelection.CreateCustomRGN(FMagneticLasso.CurveRegion, frmMain.MarqueeMode);

      FSelection.GetActualMaskBorder;   // get the border of the selection
      FSelection.CutRegionFromOriginal; // cut region from FSourceBitmap and FOriginalMask of the selection
      FSelection.GetForeground;         // get foreground of the selection
      FSelection.GetMarchingAntsLines;  // get the Marching Ants lines form the FResizeMask of the selection

      // filling the backgound that under the selection
      if FChannelManager.CurrentChannelType in [
           wctAlpha, wctQuickMask, wctLayerMask] then
      begin
        FSelection.GetBackgroundWithFilledColor(
          Color32(frmMain.BackGrayColor), FChannelManager.ChannelSelectedSet );
      end
      else // must be on layer
      begin
        case FLayerPanelList.SelectedLayerPanel.LayerFeature of
          lfBackground:
            begin
              FSelection.GetBackgroundWithFilledColor(
                Color32(frmMain.GlobalBackColor), FChannelManager.ChannelSelectedSet );
            end;

          lfTransparent:
            begin
              if (csRed   in FChannelManager.ChannelSelectedSet) and
                 (csGreen in FChannelManager.ChannelSelectedSet) and
                 (csBlue  in FChannelManager.ChannelSelectedSet) then
              begin
                FSelection.GetBackgroundWithTransparent;
              end
              else
              begin
                FSelection.GetBackgroundWithFilledColor(
                  Color32(frmMain.GlobalBackColor), FChannelManager.ChannelSelectedSet );
              end;
            end;
        end;
      end;

      // if there is no mask shadow, delete the selection
      if FSelection.HasShadow = False then
      begin
        case FChannelManager.CurrentChannelType of
          wctAlpha:
            begin
              if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
              begin
                FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Assign(FSelection.SourceBitmap);
                FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
              end;
            end;

          wctQuickMask:
            begin
              FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.Assign(FSelection.SourceBitmap);
              FChannelManager.QuickMaskPanel.AlphaLayer.Changed;
            end;

          wctLayerMask:
            begin
              FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Assign(FSelection.SourceBitmap);
              FLayerPanelList.SelectedLayerPanel.Update;
            end;

          wctRGB, wctRed, wctGreen, wctBlue:
            begin
              // must be on layer
              if FLayerPanelList.SelectedLayerPanel.LayerFeature in [
                   lfBackground, lfTransparent] then
              begin
                FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Assign(FSelection.SourceBitmap);
                FLayerPanelList.SelectedLayerPanel.Update;
              end;
            end;
        end;

        FreeAndNil(FSelection);

        tmrMarchingAnts.Enabled := False;

        frmMain.spdbtnCommitSelection.Enabled := False;
        frmMain.spdbtnDeselect.Enabled        := False;
        frmMain.spdbtnDeleteSelection.Enabled := False;
      end
      else
      begin
        ShowProcessedSelection;

        tmrMarchingAnts.Enabled := True;
        
        frmMain.spdbtnCommitSelection.Enabled := True;
        frmMain.spdbtnDeselect.Enabled        := True;
        frmMain.spdbtnDeleteSelection.Enabled := True;

        if (frmMain.MainTool = gmtMarquee) and
           (frmMain.MarqueeTool = mtMoveResize) then
        begin
          CreateSelectionHandleLayer;
        end;

        // Create Undo/Redo for selection.
        LCmdAim := GetCommandAimByCurrentChannel;

        LHistoryStatePanel := TgmSelectionStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[MAGNETIC_LASSO_MARQUEE_COMMAND_ICON_INDEX],
          LCmdAim,
          mtMagneticLasso,
          sctNew,
          FSelectionCopy,
          FSelection,
          FChannelManager.SelectedAlphaChannelIndex);

        FHistoryManager.AddHistoryState(LHistoryStatePanel);
      end;
    end;

    FreeAndNil(FMagneticLasso);
  end;

  if Assigned(FMagneticLassoLayer) then
  begin
    FreeAndNil(FMagneticLassoLayer);
  end; 
end;

procedure TfrmChild.CreateSelectionTransformation(
  const AMode: TgmTransformMode);
begin
  if (AMode = tmNone) or
     (AMode = tmTranslate) or
     (not Assigned(FSelection)) then
  begin
    Exit;
  end;

  if Assigned(FSelectionTransformation) then
  begin
    FreeAndNil(FSelectionTransformation);
  end;

  case AMode of
    tmDistort:
      begin
        FSelectionTransformation := TgmSelectionDistort.Create(FSelection);
      end;

    tmRotate:
      begin
        FSelectionTransformation := TgmSelectionRotate.Create(FSelection);
      end;

    tmScale:
      begin
        FSelectionTransformation := TgmSelectionScale.Create(FSelection);
      end;
  end;
end;

procedure TfrmChild.FreeSelectionTransformation;
begin
  if Assigned(FSelectionTransformation) then
  begin
    FreeAndNil(FSelectionTransformation);
  end;
end; 

procedure TfrmChild.CreateTransformLayer;
var
  LayerHalfW, LayerHalfH: Single;
  CenterPoint           : TPoint;
begin
  if FTransformLayer = nil then
  begin
    FTransformLayer := TBitmapLayer.Create(imgDrawingArea.Layers);

    with FTransformLayer do
    begin
      Bitmap.DrawMode       := dmCustom;
      Bitmap.OnPixelCombine := GrayNotXorLayerBlend;
      Bitmap.Width          := Screen.Width;
      Bitmap.Height         := Screen.Height;
      LayerHalfW            := Bitmap.Width  / 2;
      LayerHalfH            := Bitmap.Height / 2;
    end;

    // get the center point of the viewport of the TImage32 and convert it from control space to bitmap space
    with imgDrawingArea.GetViewportRect do
      CenterPoint := imgDrawingArea.ControlToBitmap(  Point( (Right + Left) div 2, (Top + Bottom) div 2 )  );

    // setting location of the layer
    with FTransformLayer do
    begin
      Location := FloatRect(CenterPoint.X - LayerHalfW, CenterPoint.Y - LayerHalfH,
                            CenterPoint.X + LayerHalfW, CenterPoint.Y + LayerHalfH);

      Scaled   := True;
      Bitmap.FillRect(0, 0, Bitmap.Width, Bitmap.Height, $00000000);
    end;
    
    // calculate the offset vector of the transform layer relative to the image layer
    CalcTransformLayerOffsetVector;
  end;
end;

procedure TfrmChild.DeleteTransformLayer;  
begin
  if Assigned(FTransformLayer) then
  begin
    FreeAndNil(FTransformLayer);
  end;
end;

// calculate the offset vector of the transform layer relative to the image layer
procedure TfrmChild.CalcTransformLayerOffsetVector;
var
  TransformLayerLeft: Single;
  TransformLayerTop : Single;
  CurrentLayerLeft  : Single;
  CurrentLayerTop   : Single;
  TheScale          : Single;
begin
  if Assigned(FTransformLayer) then
  begin
    TheScale                 := 100 / FMagnification;
    TransformLayerLeft       := FTransformLayer.GetAdjustedLocation.Left * TheScale;
    TransformLayerTop        := FTransformLayer.GetAdjustedLocation.Top  * TheScale;
    CurrentLayerLeft         := FLayerPanelList.SelectedLayerPanel.AssociatedLayer.GetAdjustedLocation.Left * TheScale;
    CurrentLayerTop          := FLayerPanelList.SelectedLayerPanel.AssociatedLayer.GetAdjustedLocation.Top  * TheScale;
    FTransformOffsetVector.X := Round(CurrentLayerLeft - TransformLayerLeft);
    FTransformOffsetVector.Y := Round(CurrentLayerTop  - TransformLayerTop);
  end;
end; 

// calculate the coordinates of the mouse pointer when it hovering on the transform layer
procedure TfrmChild.CalcTransformLayerCoord(X, Y: Integer);
begin
  if Assigned(FTransformLayer) then
  begin
    FTransformLayerX := X - Round(FTransformLayer.GetAdjustedLocation.Left) - Round(FTransformOffsetVector.X * imgDrawingArea.Scale);
    FTransformLayerY := Y - Round(FTransformLayer.GetAdjustedLocation.Top)  - Round(FTransformOffsetVector.Y * imgDrawingArea.Scale);

    if imgDrawingArea.Scale <> 1 then
    begin
      FTransformLayerX := MulDiv( FTransformLayerX, FTransformLayer.Bitmap.Width,  Round(FTransformLayer.Bitmap.Width  * imgDrawingArea.Scale) );
      FTransformLayerY := MulDiv( FTransformLayerY, FTransformLayer.Bitmap.Height, Round(FTransformLayer.Bitmap.Height * imgDrawingArea.Scale) );
    end;
  end;
end;

procedure TfrmChild.ConnectTransformMouseEvents;
begin
  imgDrawingArea.OnMouseDown := TransformSelectionMouseDown;
  imgDrawingArea.OnMouseMove := TransformSelectionMouseMove;
  imgDrawingArea.OnMouseUp   := TransformSelectionMouseUp;
end;

procedure TfrmChild.FinishTransformation;
var
  MsgDlgResult     : Integer;
  HistoryStatePanel: TgmHistoryStatePanel;
begin
  if FSelectionTransformation <> nil then
  begin
    HistoryStatePanel := nil;

    MsgDlgResult := MessageDlg('Apply the transformation?', mtInformation, [mbYes, mbNo, mbCancel], 0);

    case MsgDlgResult of
      mrYes:
        begin
          // Undo/Redo
          HistoryStatePanel := TgmTransformStatePanel.Create(
            frmHistory.scrlbxHistory,
            dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
            tctApply,
            FSelectionTransformation.TransformMode,
            FSelection,
            FSelectionTransformation,
            nil);

          // then, apply the transformation
          FSelectionTransformation.AcceptTransform;
        end;

      mrNo:
        begin
          // Undo/Redo
          HistoryStatePanel := TgmTransformStatePanel.Create(
            frmHistory.scrlbxHistory,
            dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
            tctCancel,
            FSelectionTransformation.TransformMode,
            FSelection,
            FSelectionTransformation,
            nil);

          FSelectionTransformation.CancelTransform;
          ShowProcessedSelection;
        end;
    end;

    if MsgDlgResult in [mrYes, mrNo] then
    begin
      FreeAndNil(FSelectionTransformation);
      DeleteTransformLayer;
      ConnectMouseEventsToImage;
      ChangeImageCursorByToolTemplets;

      if frmMain.MarqueeTool = mtMoveResize then
      begin
        CreateSelectionHandleLayer;
      end;

      if Assigned(HistoryStatePanel) then
      begin
        FHistoryManager.AddHistoryState(HistoryStatePanel);
      end;

      // enable channel manager and path panel manager
      FChannelManager.IsEnabled := True;
      FPathPanelList.IsEnabled  := True;
    end;
  end;
end;

procedure TfrmChild.CreateCropHandleLayer;
var
  LayerHalfW, LayerHalfH: Single;
  CenterPoint           : TPoint;
begin
  if FCropHandleLayer = nil then
  begin
    FCropHandleLayer := TBitmapLayer.Create(imgDrawingArea.Layers);

    with FCropHandleLayer do
    begin
      Bitmap.DrawMode       := dmCustom;
      Bitmap.OnPixelCombine := GrayNotXorLayerBlend;
      Bitmap.SetSize(Screen.Width, Screen.Height);
      LayerHalfW := Bitmap.Width  / 2;
      LayerHalfH := Bitmap.Height / 2;
    end;

    // get the center point of the viewport of the TImage32 and convert it from control space to bitmap space
    with imgDrawingArea.GetViewportRect do
      CenterPoint := imgDrawingArea.ControlToBitmap(  Point( (Right + Left) div 2, (Top + Bottom) div 2 )  );

    // setting the location of the layer
    with FCropHandleLayer do
    begin
      Location := FloatRect(CenterPoint.X - LayerHalfW, CenterPoint.Y - LayerHalfH,
                            CenterPoint.X + LayerHalfW, CenterPoint.Y + LayerHalfH);

      Scaled   := True;
      Bitmap.Clear($00000000);
    end;

    // calculate the offset vector of the crop handle layer relative to the image layer
    CalcCropHandleLayerOffsetVector;
  end;
end;

// calculate the offset vector of the crop handle layer relative to the image layer
procedure TfrmChild.CalcCropHandleLayerOffsetVector;
var
  HandleLayerLeft : Single;
  HandleLayerTop  : Single;
  CurrentLayerLeft: Single;
  CurrentLayerTop : Single;
  TheScale        : Single;
begin
  if Assigned(FCropHandleLayer) then
  begin
    TheScale                       := 100 / FMagnification;
    HandleLayerLeft                := FCropHandleLayer.GetAdjustedLocation.Left * TheScale;
    HandleLayerTop                 := FCropHandleLayer.GetAdjustedLocation.Top  * TheScale;
    CurrentLayerLeft               := FLayerPanelList.SelectedLayerPanel.AssociatedLayer.GetAdjustedLocation.Left * TheScale;
    CurrentLayerTop                := FLayerPanelList.SelectedLayerPanel.AssociatedLayer.GetAdjustedLocation.Top  * TheScale;
    FCropHandleLayerOffsetVector.X := Round(CurrentLayerLeft - HandleLayerLeft);
    FCropHandleLayerOffsetVector.Y := Round(CurrentLayerTop  - HandleLayerTop);
  end;
end;

procedure TfrmChild.CommitCrop;
var
  LNewWidth, LNewHeight : Integer;
  LLayer                : TBitmapLayer;
  LShapeRegionLayerPanel: TgmShapeRegionLayerPanel;
  LHistoryStatePanel    : TgmHistoryStatePanel;
begin
  if Assigned(FCrop) then
  begin
    Screen.Cursor := crHourGlass;
    try
      // doing crop...
      if (frmMain.chckbxResizeCrop.Checked) and
         (frmMain.edtResizeCropWidth.Text  <> '') and
         (frmMain.edtResizeCropHeight.Text <> '') then
      begin
        FCrop.ResizeW   := StrToInt(frmMain.edtResizeCropWidth.Text);
        FCrop.ResizeH   := StrToInt(frmMain.edtResizeCropHeight.Text);
        FCrop.IsResized := True;
      end
      else
      begin
        FCrop.IsResized := False;
      end;

      if FCrop.IsResized then
      begin
        LNewWidth  := FCrop.ResizeW;
        LNewHeight := FCrop.ResizeH;
      end
      else
      begin
        LNewWidth  := FCrop.CropAreaWidth;
        LNewHeight := FCrop.CropAreaHeight;
      end;

      // create Undo/Redo first
      LHistoryStatePanel := TgmCropStatePanel.Create(
        frmHistory.scrlbxHistory,
        dmHistory.bmp32lstHistory.Bitmap[CROP_COMMAND_ICON_INDEX],
        FCrop);

      FHistoryManager.AddHistoryState(LHistoryStatePanel);

      imgDrawingArea.Bitmap.SetSize(LNewWidth, LNewHeight);

      FLayerPanelList.CropImageForAllLayers(imgDrawingArea, FCrop,
                                            frmMain.GlobalBackColor);

      FLayerTopLeft := GetLayerTopLeft;

      // crop channels
      LLayer := TBitmapLayer(imgDrawingArea.Layers[0]);
      FChannelManager.CropChannels(FCrop, LLayer.Location);

      if FCropHandleLayer <> nil then
      begin
        FreeAndNil(FCropHandleLayer);
      end;

      FreeAndNil(FCrop);
      frmMain.UpdateCropOptions;

      if FLayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
      begin
        LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(FLayerPanelList.SelectedLayerPanel);

        if FShapeOutlineLayer <> nil then
        begin
          CalcShapeOutlineLayerOffsetVector;
          FShapeOutlineLayer.Bitmap.Clear($00000000);

          with LShapeRegionLayerPanel do
          begin
            if ShapeOutlineList.Count > 0 then
            begin
              ShapeOutlineList.DrawAllOutlines(FShapeOutlineLayer.Bitmap.Canvas,
                                               FOutlineOffsetVector, pmNotXor);
            end;
          end;
        end;
      end;

      if frmMain.MainTool = gmtStandard then
      begin
        if FHandleLayer <> nil then
        begin
          FHandleLayer.Bitmap.Clear($00FFFFFF);
          FLayerPanelList.DrawSelectedFiguresHandles(FHandleLayer.Bitmap, FHandleLayerOffsetVector);
        end;
      end;

      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;

      // enable channel manager and path panel manager after crop tool is destroy
      FChannelManager.IsEnabled := True;
      FPathPanelList.IsEnabled  := True;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TfrmChild.CancelCrop;
begin
  if Assigned(FCrop) then
  begin
    if FCropHandleLayer <> nil then
    begin
      FreeAndNil(FCropHandleLayer);
    end;
    
    FreeAndNil(FCrop);
    frmMain.UpdateCropOptions;

    // enable channel manager and path panel manager after crop tool is destroy
    FChannelManager.IsEnabled := True;
    FPathPanelList.IsEnabled  := True;
  end;
end;

procedure TfrmChild.FinishCrop;
begin
  if Assigned(FCrop) then
  begin
    case MessageDlg('Crop the image?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
      mrYes:
        begin
          CommitCrop;
        end;

      mrNo:
        begin
          CancelCrop;
        end;

      mrCancel:
        begin
          // switch to Crop tool
          if frmMain.MainTool <> gmtCrop then
          begin
            frmMain.spdbtnCropTools.Down := True;
            frmMain.ChangeMainToolClick(frmMain.spdbtnCropTools);
          end;
        end;
    end;
  end;
end;

procedure TfrmChild.ExecuteOptimalCrop;
var
  LCroppedBmp          : TBitmap32;
  LCropArea, LBackRect : TRect;
  LTopLeft             : TPoint;
  LHistoryStatePanel   : TgmHistoryStatePanel;
begin
  LCropArea := Rect(0, 0, 0, 0);

  if FLayerPanelList.Count = 1 then
  begin
    Screen.Cursor := crHourGlass;
    LCroppedBmp   := TBitmap32.Create;
    try
      // restore alpha channel, first
      if (FLayerPanelList.SelectedLayerPanel.IsHasMask) and
         (FLayerPanelList.SelectedLayerPanel.IsMaskLinked) then
      begin
        ReplaceAlphaChannelWithMask(
          FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
          FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
      end;

      // crop the layer and mask (if any)
      LCroppedBmp.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
      LCropArea := OptimalCrop(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap, LCroppedBmp);

      if (LCropArea.Right  > LCropArea.Left) and
         (LCropArea.Bottom > LCropArea.Top) then
      begin
        // create Undo/Redo first
        LHistoryStatePanel := TgmOptimalCropStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[CROP_COMMAND_ICON_INDEX]);

        FHistoryManager.AddHistoryState(LHistoryStatePanel);

        // applying crop
        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Assign(LCroppedBmp);
      end;
      
      FLayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;

      if FLayerPanelList.SelectedLayerPanel.IsHasMask then
      begin
        FLayerPanelList.SelectedLayerPanel.CropMask(LCropArea);
        FLayerPanelList.SelectedLayerPanel.UpdateMaskThumbnail;
      end;

      // set backgound
      imgDrawingArea.Bitmap.SetSize(
        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height);

      // set layer location
      LBackRect := imgDrawingArea.GetBitmapRect;
      LTopLeft  := imgDrawingArea.ControlToBitmap( Point(LBackRect.Left, LBackRect.Top) );

      FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Location :=
        FloatRect(LTopLeft.X, LTopLeft.Y,
                  imgDrawingArea.Bitmap.Width,
                  imgDrawingArea.Bitmap.Height);

      FLayerTopLeft := GetLayerTopLeft;

      // crop channels
      FChannelManager.CropChannels(LCropArea,
        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Location);

      FLayerPanelList.SelectedLayerPanel.Update;

      FImageProcessed := True;
    finally
      LCroppedBmp.Free;
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TfrmChild.ChangeImageCursorByEraserTools;
begin
  case frmMain.EraserTool of
    etEraser,
    etBackgroundEraser:
      begin
        imgDrawingArea.Cursor := crCross;
      end;

    etMagicEraser:
      begin
        imgDrawingArea.Cursor := crMagicEraser;
      end;
  end;
end; 

procedure TfrmChild.CreatePathLayer;
var
  LayerHalfW, LayerHalfH: Single;
  CenterPoint           : TPoint;
begin
  if FPathLayer = nil then
  begin
    FPathLayer := TBitmapLayer.Create(imgDrawingArea.Layers);

    with FPathLayer do
    begin
      Bitmap.DrawMode       := dmCustom;
      Bitmap.OnPixelCombine := GrayNotXorLayerBlend;
      Bitmap.Width          := Screen.Width;
      Bitmap.Height         := Screen.Height;
      LayerHalfW            := Bitmap.Width  / 2;
      LayerHalfH            := Bitmap.Height / 2;
    end;

    // get the center point of the viewport of the TImage32 and convert it from control space to bitmap space
    with imgDrawingArea.GetViewportRect do
      CenterPoint := imgDrawingArea.ControlToBitmap(  Point( (Right + Left) div 2, (Top + Bottom) div 2 )  );

    // setting the location of the layer
    with FPathLayer do
    begin
      Location := FloatRect(CenterPoint.X - LayerHalfW, CenterPoint.Y - LayerHalfH,
                            CenterPoint.X + LayerHalfW, CenterPoint.Y + LayerHalfH);

      Scaled   := True;
      Bitmap.Clear($00000000);
    end;

    // calculate the offset vector of the path layer relative to the image layer
    CalcPathLayerOffsetVector;
  end;
end;

procedure TfrmChild.DeletePathLayer;
begin
  if Assigned(FPathLayer) then
  begin
    FreeAndNil(FPathLayer);
  end;
end;

// calculate the coordinates of the mouse pointer when it hovering on the path layer
procedure TfrmChild.CalcPathLayerCoord(X, Y: Integer);
begin
  if Assigned(FPathLayer) then
  begin
    FPathLayerX := X - Round(FPathLayer.GetAdjustedLocation.Left);
    FPathLayerY := Y - Round(FPathLayer.GetAdjustedLocation.Top);

    if imgDrawingArea.Scale <> 1 then
    begin
      FPathLayerX := MulDiv( FPathLayerX, FPathLayer.Bitmap.Width,  Round(FPathLayer.Bitmap.Width  * imgDrawingArea.Scale) );
      FPathLayerY := MulDiv( FPathLayerY, FPathLayer.Bitmap.Height, Round(FPathLayer.Bitmap.Height * imgDrawingArea.Scale) );
    end;
  end;
end;

// calculate the offset vector of the path layer relative to the image layer
procedure TfrmChild.CalcPathLayerOffsetVector;
var
  PathLayerLeft   : Single;
  PathLayerTop    : Single;
  CurrentLayerLeft: Single;
  CurrentLayerTop : Single;
  TheScale        : Single;
begin
  if Assigned(FPathLayer) then
  begin
    TheScale            := 100 / FMagnification;
    PathLayerLeft       := FPathLayer.GetAdjustedLocation.Left * TheScale;
    PathLayerTop        := FPathLayer.GetAdjustedLocation.Top  * TheScale;
    CurrentLayerLeft    := FLayerPanelList.SelectedLayerPanel.AssociatedLayer.GetAdjustedLocation.Left * TheScale;
    CurrentLayerTop     := FLayerPanelList.SelectedLayerPanel.AssociatedLayer.GetAdjustedLocation.Top  * TheScale;
    FPathOffsetVector.X := Round(PathLayerLeft - CurrentLayerLeft);
    FPathOffsetVector.Y := Round(PathLayerTop  - CurrentLayerTop);
  end;
end;

procedure TfrmChild.ChangeImageCursorByPenTools;
begin
  case frmMain.PenTool of
    ptPathComponentSelection:
      begin
        imgDrawingArea.Cursor := crPathComponentSelection;
      end;
      
    ptPenTool:
      begin
        imgDrawingArea.Cursor := GetPenToolDefaultCursor;
      end;

    ptDirectSelection,
    ptAddAnchorPoint,
    ptDeleteAnchorPoint,
    ptConvertPoint:
      begin
        imgDrawingArea.Cursor := crDirectSelection;
      end;
  end;
end;

function TfrmChild.GetPenToolDefaultCursor: TCursor;
begin
  if Assigned(FPenPath) then
  begin
    Result := crPenToolSelected;
  end
  else
  begin
    Result := crPenToolDeselected;
  end;
end; 

// Path to Selection
procedure TfrmChild.LoadPathAsSelection;
begin
  Screen.Cursor := crHourGlass;
  try
    if Assigned(FSelection) then
    begin
      CommitSelection;
    end;

    // create a selection
    if FSelection = nil then
    begin
      FSelection := TgmSelection.Create;

      case FChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
            begin
              FSelection.SourceBitmap.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
              FSelection.Background.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
            end;
          end;

        wctQuickMask:
          begin
            FSelection.SourceBitmap.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
            FSelection.Background.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
          end;

        wctLayerMask:
          begin
            FSelection.SourceBitmap.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
            FSelection.Background.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
            begin
              ReplaceAlphaChannelWithMask(
                FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
            end;

            FSelection.SourceBitmap.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
            FSelection.Background.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
          end;
      end;

      FSelection.SetOriginalMask(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
                                 FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height);
    end;

    if Assigned(FSelection) then
    begin
      if Assigned(FPathPanelList.SelectedPanel) then
      begin
        if FPathPanelList.SelectedPanel.PenPathList.UpdatePathRegion(
             FSelection.SourceBitmap.Width,
             FSelection.SourceBitmap.Height,
             FPathOffsetVector) then
        begin
          FSelection.CreateCustomRGN(FPathPanelList.SelectedPanel.PenPathList.PathRegion, mmNew);
        end;
      end;

      FSelection.GetActualMaskBorder;

      // if the selection is created successfully...
      if FSelection.HasShadow then
      begin
        FSelection.CutRegionFromOriginal;
        FSelection.GetForeground;
        FSelection.GetMarchingAntsLines;

        // filling the background that is beneath the selection
        case FChannelManager.CurrentChannelType of
          wctAlpha, wctQuickMask, wctLayerMask:
            begin
              FSelection.GetBackgroundWithFilledColor( Color32(frmMain.BackGrayColor),
                                                       FChannelManager.ChannelSelectedSet );
            end;

          wctRGB, wctRed, wctGreen, wctBlue:
            begin
              case FLayerPanelList.SelectedLayerPanel.LayerFeature of
                lfBackground:
                  begin
                    FSelection.GetBackgroundWithFilledColor(
                      Color32(frmMain.GlobalBackColor),
                      FChannelManager.ChannelSelectedSet );
                  end;

                lfTransparent:
                  begin
                    if (csRed   in FChannelManager.ChannelSelectedSet) and
                       (csGreen in FChannelManager.ChannelSelectedSet) and
                       (csBlue  in FChannelManager.ChannelSelectedSet) then
                    begin
                      FSelection.GetBackgroundWithTransparent;
                    end
                    else
                    begin
                      FSelection.GetBackgroundWithFilledColor( Color32(frmMain.GlobalBackColor),
                                                               FChannelManager.ChannelSelectedSet );
                    end;
                  end;
              end;
            end;
        end;
      end
      else
      begin
        MessageDlg('No pixels were selected.', mtWarning, [mbOK], 0);
        FreeAndNil(FSelection);
      end;
    end;
  finally
    Screen.Cursor := crDefault;
  end;

  if Assigned(FSelection) then
  begin
    ShowProcessedSelection;
    RemoveMarchingAnts;
    tmrMarchingAnts.Enabled := True;
  end;

  // updating the selection border
  UpdateSelectionHandleBorder;
  frmMain.UpdateMarqueeOptions;
end;

// channel to selection
procedure TfrmChild.LoadChannelAsSelection;
var
  LChannelBmp  : TBitmap32;
  LMarqueeMode: TgmMarqueeMode;
begin
  Screen.Cursor := crHourGlass;
  try
    // if the selection has not been created, then create one
    if FSelection = nil then
    begin
      LMarqueeMode := mmNew;
      FSelection   := TgmSelection.Create;

      case FChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
            begin
              FSelection.SourceBitmap.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
              FSelection.Background.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
            end;
          end;

        wctQuickMask:
          begin
            FSelection.SourceBitmap.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
            FSelection.Background.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
          end;

        wctLayerMask:
          begin
            FSelection.SourceBitmap.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
            FSelection.Background.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
            begin
              ReplaceAlphaChannelWithMask(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                                          FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
            end;

            FSelection.SourceBitmap.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
            FSelection.Background.Assign(FLayerpanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
          end;
      end;

      FSelection.SetOriginalMask(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
                                 FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height);
    end
    else
    begin
      LMarqueeMode := frmMain.MarqueeMode;
    end;

    if Assigned(FSelection) then
    begin
      case FChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            LChannelBmp := FChannelManager.GetAlphaChannelBitmap;
          end;
          
        wctQuickMask:
          begin
            LChannelBmp := FChannelManager.GetQuickMaskBitmap;
          end;
          
        wctLayerMask:
          begin
            LChannelBmp := FChannelManager.GetLayerMaskBitmap;
          end;
          
      else
        LChannelBmp := FChannelManager.GetChannelCompositeBitmap;
      end;

      try
        if FSelection.LoadChannelAsSelection(LChannelBmp, LMarqueeMode) = False then
        begin
          MessageDlg(FSelection.OutputMsg, mtError, [mbOK], 0);
        end;
      finally
        LChannelBmp.Free;
      end;

      FSelection.GetActualMaskBorder;

      // if the selection is created successfully...
      if FSelection.HasShadow then
      begin
        FSelection.CutRegionFromOriginal;
        FSelection.GetForeground;
        FSelection.GetMarchingAntsLines;

        // filling the background that is under the selection
        case FChannelManager.CurrentChannelType of
          wctAlpha, wctQuickMask, wctLayerMask:
            begin
              FSelection.GetBackgroundWithFilledColor( Color32(frmMain.BackGrayColor),
                                                       FChannelManager.ChannelSelectedSet );
            end;

          wctRGB, wctRed, wctGreen, wctBlue:
            begin
              case FLayerPanelList.SelectedLayerPanel.LayerFeature of
                lfBackground:
                  begin
                    FSelection.GetBackgroundWithFilledColor(
                      Color32(frmMain.GlobalBackColor),
                      FChannelManager.ChannelSelectedSet );
                  end;

                lfTransparent:
                  begin
                    if (csRed   in FChannelManager.ChannelSelectedSet) and
                       (csGreen in FChannelManager.ChannelSelectedSet) and
                       (csBlue  in FChannelManager.ChannelSelectedSet) then
                    begin
                      FSelection.GetBackgroundWithTransparent;
                    end
                    else
                    begin
                      FSelection.GetBackgroundWithFilledColor( Color32(frmMain.GlobalBackColor),
                                                               FChannelManager.ChannelSelectedSet );
                    end;
                  end;
              end;
            end;
        end;
      end
      else
      begin
        MessageDlg('No pixels were selected.', mtWarning, [mbOK], 0);
        FreeAndNil(FSelection);
      end;
    end;
  finally
    Screen.Cursor := crDefault;
  end;

  if Assigned(FSelection) then
  begin
    ShowProcessedSelection;
    RemoveMarchingAnts;
    tmrMarchingAnts.Enabled := True;
  end;

  // updating the selection border
  UpdateSelectionHandleBorder;
  frmMain.UpdateMarqueeOptions;
end;

procedure TfrmChild.LoadQuickMaskAsSelection;
var
  LChannelBmp : TBitmap32;
  LMarqueeMode: TgmMarqueeMode;
begin
  LChannelBmp := nil;

  Screen.Cursor := crHourGlass;
  try
    // if the selection has not been created, then create one
    if FSelection = nil then
    begin
      LMarqueeMode := mmNew;
      FSelection   := TgmSelection.Create;

      case FChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            if Assigned(FChannelManager.SelectedAlphaChannelPanel) then
            begin
              FSelection.SourceBitmap.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
              FSelection.Background.Assign(FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
            end;
          end;

        wctQuickMask:
          begin
            FSelection.SourceBitmap.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
            FSelection.Background.Assign(FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
          end;

        wctLayerMask:
          begin
            FSelection.SourceBitmap.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
            FSelection.Background.Assign(FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            if FLayerPanelList.SelectedLayerPanel.IsMaskLinked
            then ReplaceAlphaChannelWithMask(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                                             FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);

            FSelection.SourceBitmap.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
            FSelection.Background.Assign(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
          end;
      end;

      FSelection.SetOriginalMask(FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
                                 FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height);
    end
    else
    begin
      LMarqueeMode := frmMain.MarqueeMode;
    end;

    if Assigned(FSelection) then
    begin
      try
        LChannelBmp := FChannelManager.GetQuickMaskBitmap;

        if FSelection.LoadChannelAsSelection(LChannelBmp, LMarqueeMode) = False then
        begin
          MessageDlg(FSelection.OutputMsg, mtError, [mbOK], 0);
        end;
      finally
        LChannelBmp.Free;
      end;

      FSelection.GetActualMaskBorder;

      // if the selection is created successfully...
      if FSelection.HasShadow then
      begin
        FSelection.CutRegionFromOriginal;
        FSelection.GetForeground;
        FSelection.GetMarchingAntsLines;

        // filling the background that is under the selection
        case FChannelManager.CurrentChannelType of
          wctAlpha, wctQuickMask, wctLayerMask:
            begin
              FSelection.GetBackgroundWithFilledColor(
                Color32(frmMain.BackGrayColor),
                FChannelManager.ChannelSelectedSet );
            end;

          wctRGB, wctRed, wctGreen, wctBlue:
            begin
              case FLayerPanelList.SelectedLayerPanel.LayerFeature of
                lfBackground:
                  begin
                    FSelection.GetBackgroundWithFilledColor(
                      Color32(frmMain.GlobalBackColor),
                      FChannelManager.ChannelSelectedSet );
                  end;

                lfTransparent:
                  begin
                    if  (csRed   in FChannelManager.ChannelSelectedSet)
                    and (csGreen in FChannelManager.ChannelSelectedSet)
                    and (csBlue  in FChannelManager.ChannelSelectedSet)
                    then FSelection.GetBackgroundWithTransparent
                    else FSelection.GetBackgroundWithFilledColor( Color32(frmMain.GlobalBackColor),
                                                                  FChannelManager.ChannelSelectedSet );
                  end;
              end;
            end;
        end;
      end
      else
      begin
        MessageDlg('No pixels were selected.', mtWarning, [mbOK], 0);
        FreeAndNil(FSelection);
      end;
    end;
  finally
    Screen.Cursor := crDefault;
  end;

  if Assigned(FSelection) then
  begin
    ShowProcessedSelection;
    RemoveMarchingAnts;
    tmrMarchingAnts.Enabled := True;
  end;

  // update selection border
  UpdateSelectionHandleBorder;
  frmMain.UpdateMarqueeOptions;
end; 

procedure TfrmChild.UpdateChannelFormButtonsEnableState;
var
  LSelectedAlphaChannelCount: Integer;
  LQuickMaskIsSelected      : Boolean;
  LLayerMaskIsSelected      : Boolean;
begin
  LSelectedAlphaChannelCount := FChannelManager.SelectedAlphaChannelCount;
  LQuickMaskIsSelected       := ( Assigned(FChannelManager.QuickMaskPanel) and FChannelManager.QuickMaskPanel.IsSelected );
  LLayerMaskIsSelected       := ( Assigned(FChannelManager.LayerMaskPanel) and FChannelManager.LayerMaskPanel.IsSelected );

  with frmChannel do
  begin
    tlbtnLoadChannelAsSelection.Enabled := ( FChannelManager.RedChannelPanel.IsSelected or
                                             FChannelManager.GreenChannelPanel.IsSelected or
                                             FChannelManager.BlueChannelPanel.IsSelected or
                                             (LSelectedAlphaChannelCount > 0) or
                                             LQuickMaskIsSelected or
                                             LLayerMaskIsSelected );

    tlbtnCreateNewChannel.Enabled := (FChannelManager.AlphaChannelPanelList.Count < MAX_ALPHA_CHANNEL_COUNT);

    tlbtnDeleteCurrentChannel.Enabled := ( (FChannelManager.RedChannelPanel.IsSelected   = False) and
                                           (FChannelManager.GreenChannelPanel.IsSelected = False) and
                                           (FChannelManager.BlueChannelPanel.IsSelected  = False) and
                                           (LSelectedAlphaChannelCount = 1) ) or
                                           LQuickMaskIsSelected or
                                           LLayerMaskIsSelected;


  end;
end;

procedure TfrmChild.ShowMeasureResult;
var
  LMeasureUnit: TgmMeasureUnit;
begin
  if Assigned(FMeasureLayer) and Assigned(FMeasureLine) then
  begin
    LMeasureUnit := TgmMeasureUnit(frmMain.cmbbxMeasureUnit.ItemIndex);

    FMeasureLine.Calculate(LMeasureUnit, PixelsPerInch);

    case LMeasureUnit of
      muPixel:
        begin
          with frmMain do
          begin
            lblMStartXValue.Caption := Format('%d',   [FMeasureLine.OriginalIntX]);
            lblMStartYValue.Caption := Format('%d',   [FMeasureLine.OriginalIntY]);
            lblMWidthValue.Caption  := Format('%d',   [FMeasureLine.IntWidth]);
            lblMHeightValue.Caption := Format('%d',   [FMeasureLine.IntHeight]);
            lblMAngleValue.Caption  := Format('%.1f', [FMeasureLine.MeasureAngle]);
            lblMD1Value.Caption     := Format('%d',   [FMeasureLine.IntDistance1]);
            lblMD2Value.Caption     := Format('%d',   [FMeasureLine.IntDistance2]);
          end;
        end;

      muInch, muCM:
        begin
          with frmMain do
          begin
            lblMStartXValue.Caption := Format('%.2f', [FMeasureLine.OriginalFloatX]);
            lblMStartYValue.Caption := Format('%.2f', [FMeasureLine.OriginalFloatY]);
            lblMWidthValue.Caption  := Format('%.2f', [FMeasureLine.FloatWidth]);
            lblMHeightValue.Caption := Format('%.2f', [FMeasureLine.FloatHeight]);
            lblMAngleValue.Caption  := Format('%.1f', [FMeasureLine.MeasureAngle]);
            lblMD1Value.Caption     := Format('%.2f', [FMeasureLine.FloatDistance1]);
            lblMD2Value.Caption     := Format('%.2f', [FMeasureLine.FloatDistance2]);
          end;
        end;
    end;
  end;
end;

procedure TfrmChild.DeleteMeasureLine;
begin
  if Assigned(FMeasureLayer) then
  begin
    if Assigned(FMeasureLine) then
    begin
      FreeAndNil(FMeasureLine);
    end;

    FreeAndNil(FMeasureLayer);
  end;
end; 

function TfrmChild.CreateShapeRegionLayer: Boolean;
var
  NewLayer, BackLayer: TBitmapLayer;
  LayerPanel         : TgmShapeRegionLayerPanel;
  Index              : Integer;
begin
  Result := False;
  if (imgDrawingArea.Layers.Count > 0) and (FLayerPanelList.Count > 0) then
  begin
    { If the current layer is not a Shape Region layer, or it is a Shape Region
      layer but it is not in edit state, then create a new Shape Region layer
      just upon the current layer. }
    if (FLayerPanelList.SelectedLayerPanel.LayerFeature <> lfShapeRegion)
    or ( (FLayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion) and
         (TgmShapeRegionLayerPanel(FLayerPanelList.SelectedLayerPanel).IsDismissed) ) then
    begin
      Index     := FLayerPanelList.CurrentIndex;
      BackLayer := TBitmapLayer(imgDrawingArea.Layers[0]);

      // create a new layer and insert it into the layer list
      imgDrawingArea.Layers.Insert(Index + 1, TBitmapLayer);
      NewLayer := TBitmapLayer(imgDrawingArea.Layers[Index + 1]);

      with NewLayer do
      begin
        Bitmap.SetSize(BackLayer.Bitmap.Width, BackLayer.Bitmap.Height);
        Bitmap.Clear($00FFFFFF);
        Location := BackLayer.Location;
        Scaled   := True;
      end;

      // create layer panel that associated with the new layer and showing it in frmLayer form
      LayerPanel := TgmShapeRegionLayerPanel.Create(frmLayer.scrlbxLayers, NewLayer);
      LayerPanel.RegionColor := frmMain.GlobalForeColor;
      LayerPanel.BrushStyle  := frmMain.ShapeBrushStyle;

      // add the new layer panel to list
      if Index = FLayerPanelList.Count - 1
      then FLayerPanelList.AddLayerPanelToList(LayerPanel)
      else FLayerPanelList.InsertLayerPanelToList(Index + 1, LayerPanel);

      frmLayer.scrlbxLayers.Update;  // update the layer panel container for showing the scroll bar of it correctly

      frmColor.ColorMode := cmRGB;   // update the appearance of the color form
      Result             := True;    // identify that we have created a shape region layer
    end;

    FImageProcessed := True; // identify the image has been modified
  end;
end;

// creating a layer for holding outlines of shapes
procedure TfrmChild.CreateShapeOutlineLayer;
var
  LayerHalfW, LayerHalfH: Single;
  CenterPoint           : TPoint;
begin
  if FShapeOutlineLayer = nil then
  begin
    FShapeOutlineLayer := TBitmapLayer.Create(imgDrawingArea.Layers);

    with FShapeOutlineLayer do
    begin
      Bitmap.DrawMode       := dmCustom;
      Bitmap.OnPixelCombine := GrayNotXorLayerBlend;
      Bitmap.Width          := Screen.Width;
      Bitmap.Height         := Screen.Height;
      LayerHalfW            := Bitmap.Width  / 2;
      LayerHalfH            := Bitmap.Height / 2;
    end;

    // get the center point of the viewport of the TImage32 and convert it from control space to bitmap space
    with imgDrawingArea.GetViewportRect do
      CenterPoint := imgDrawingArea.ControlToBitmap(  Point( (Right + Left) div 2, (Top + Bottom) div 2 )  );

    // set location of the the layer
    with FShapeOutlineLayer do
    begin
      Location := FloatRect(CenterPoint.X - LayerHalfW, CenterPoint.Y - LayerHalfH,
                            CenterPoint.X + LayerHalfW, CenterPoint.Y + LayerHalfH);

      Scaled   := True;
      Bitmap.Clear($00000000);
    end;

    // calculate the offset vector of the outline layer relative to the image layer
    CalcShapeOutlineLayerOffsetVector;
  end;
end;

procedure TfrmChild.DeleteShapeOutlineLayer;
begin
  if Assigned(FShapeOutlineLayer) then
  begin
    FreeAndNil(FShapeOutlineLayer);
  end;
end;

procedure TfrmChild.DrawShapeOutline;
var
  ShapeRegionLayerPanel: TgmShapeRegionLayerPanel;
begin
  if Assigned(FShapeOutlineLayer) then
  begin
    if FLayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
    begin
      FShapeOutlineLayer.Bitmap.Clear($00000000);
      ShapeRegionLayerPanel := TgmShapeRegionLayerPanel(FLayerPanelList.SelectedLayerPanel);

      if not ShapeRegionLayerPanel.IsDismissed then
      begin
        ShapeRegionLayerPanel.ShapeOutlineList.DrawAllOutlines(
          FShapeOutlineLayer.Bitmap.Canvas, FOutlineOffsetVector, pmNotXor);

        if frmMain.ShapeRegionTool = srtMove then
        begin
          ShapeRegionLayerPanel.ShapeOutlineList.DrawShapesBoundary(
            FShapeOutlineLayer.Bitmap.Canvas, HANDLE_RADIUS,
            FOutlineOffsetVector, pmNotXor);

          ShapeRegionLayerPanel.ShapeOutlineList.DrawShapesBoundaryHandles(
            FShapeOutlineLayer.Bitmap.Canvas, HANDLE_RADIUS,
            FOutlineOffsetVector, pmNotXor);
        end;

        FShapeOutlineLayer.Bitmap.Changed;
      end;
    end;
  end;
end;

// calculate the offset vector of the Shape Outline layer relative to the image layer
procedure TfrmChild.CalcShapeOutlineLayerOffsetVector;
var
  OutlineLayerLeft: Single;
  OutlineLayerTop : Single;
  CurrentLayerLeft: Single;
  CurrentLayerTop : Single;
  TheScale        : Single;
begin
  if Assigned(FShapeOutlineLayer) then
  begin
    TheScale               := 100 / FMagnification;
    OutlineLayerLeft       := FShapeOutlineLayer.GetAdjustedLocation.Left * TheScale;
    OutlineLayerTop        := FShapeOutlineLayer.GetAdjustedLocation.Top  * TheScale;
    CurrentLayerLeft       := FLayerPanelList.SelectedLayerPanel.AssociatedLayer.GetAdjustedLocation.Left * TheScale;
    CurrentLayerTop        := FLayerPanelList.SelectedLayerPanel.AssociatedLayer.GetAdjustedLocation.Top  * TheScale;
    FOutlineOffsetVector.X := Round(CurrentLayerLeft - OutlineLayerLeft);
    FOutlineOffsetVector.Y := Round(CurrentLayerTop  - OutlineLayerTop);
  end;
end;

procedure TfrmChild.CalcVertexForLineRegionOutline;
var
  LTempPolygon: array [0..4] of TPoint;
  i           : Integer;
begin
  CalcLineOutlineVertices(LTempPolygon, FActualStartPoint, FActualEndPoint,
                          frmMain.LineWeight);

  for i := 0 to 4 do
  begin
    FRegionPolygon[i] := LTempPolygon[i];
  end;
end;

procedure TfrmChild.ChangeImageCursorByShapeTools;
begin
  if frmMain.ShapeRegionTool = srtMove then
  begin
    imgDrawingArea.Cursor := crMoveSelection;
  end
  else
  begin
    case frmMain.RegionCombineMode of
      rcmAdd:
        begin
          imgDrawingArea.Cursor := crCrossAdd;
        end;

      rcmSubtract:
        begin
          imgDrawingArea.Cursor := crCrossSub;
        end;
        
      rcmIntersect:
        begin
          imgDrawingArea.Cursor := crCrossIntersect;
        end;
        
      rcmExcludeOverlap:
        begin
          imgDrawingArea.Cursor := crCrossInterSub;
        end;
    end;
  end;
end;

procedure TfrmChild.CreateRichTextLayer;
var
  NewLayer, BackLayer: TBitmapLayer;
  LayerPanel         : TgmRichTextLayerPanel;
  Index              : Integer;
begin
  if (imgDrawingArea.Layers.Count > 0) and (FLayerPanelList.Count > 0) then
  begin
    Index     := FLayerPanelList.CurrentIndex;
    BackLayer := TBitmapLayer(imgDrawingArea.Layers[0]);

    // create a new layer and insert it into the layer list
    imgDrawingArea.Layers.Insert(Index + 1, TBitmapLayer);
    NewLayer := TBitmapLayer(imgDrawingArea.Layers[Index + 1]);

    with NewLayer do
    begin
      Bitmap.SetSize(BackLayer.Bitmap.Width, BackLayer.Bitmap.Height);
      Bitmap.Clear($00FFFFFF);
      Location := BackLayer.Location;
      Scaled   := True;
    end;

    // create layer panel that associated with the new layer and showing it in frmLayer form
    LayerPanel := TgmRichTextLayerPanel.Create(frmLayer.scrlbxLayers, NewLayer,
                                               frmRichTextEditor.rchedtRichTextEditor);

    // add the new layer panel to list
    if Index = (FLayerPanelList.Count - 1) then
    begin
      FLayerPanelList.AddLayerPanelToList(LayerPanel);
    end
    else
    begin
      FLayerPanelList.InsertLayerPanelToList(Index + 1, LayerPanel);
    end;

    frmLayer.scrlbxLayers.Update;  // update the layer panel container for showing the scroll bar of it correctly

    frmColor.ColorMode := cmRGB;   // update the appearance of the color form
    FImageProcessed    := True;    // identify the image has been modified
  end;
end; 

// creating a layer for drawing a frame for Rich Text layer
procedure TfrmChild.CreateRichTextHandleLayer;
var
  LayerHalfW, LayerHalfH: Single;
  CenterPoint           : TPoint;
begin
  if FRichTextHandleLayer = nil then
  begin
    FRichTextHandleLayer := TBitmapLayer.Create(imgDrawingArea.Layers);

    with FRichTextHandleLayer do
    begin
      Bitmap.DrawMode       := dmCustom;
      Bitmap.OnPixelCombine := GrayNotXorLayerBlend;
      Bitmap.Width          := Screen.Width;
      Bitmap.Height         := Screen.Height;
      LayerHalfW            := Bitmap.Width  / 2;
      LayerHalfH            := Bitmap.Height / 2;
    end;

    // get the center point of the viewport of the TImage32 and convert it from control space to bitmap space
    with imgDrawingArea.GetViewportRect do
      CenterPoint := imgDrawingArea.ControlToBitmap(  Point( (Right + Left) div 2, (Top + Bottom) div 2 )  );

    // set location of the layer
    with FRichTextHandleLayer do
    begin
      Location := FloatRect(CenterPoint.X - LayerHalfW, CenterPoint.Y - LayerHalfH,
                            CenterPoint.X + LayerHalfW, CenterPoint.Y + LayerHalfH);

      Scaled   := True;
      Bitmap.Clear($00000000);
    end;

    // calculate the offset vector of the handle layer relative to the image layer
    CalcRichTextHandleLayerOffsetVector;
  end;
end;

procedure TfrmChild.DeleteRichTextHandleLayer;
begin
  if FRichTextHandleLayer <> nil then
  begin
    FreeAndNil(FRichTextHandleLayer);
  end;
end;

procedure TfrmChild.UpdateRichTextHandleLayer;
var
  LRichTextLayerPanel: TgmRichTextLayerPanel;
begin
  if frmMain.MainTool = gmtTextTool then
  begin
    if FLayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
    begin
      LRichTextLayerPanel := TgmRichTextLayerPanel(FLayerPanelList.SelectedLayerPanel);

      if FRichTextHandleLayer = nil then
      begin
        CreateRichTextHandleLayer;
      end;

      FRichTextHandleLayer.Bitmap.Clear($00000000);

      LRichTextLayerPanel.DrawRichTextBorder(FRichTextHandleLayer.Bitmap.Canvas,
                                             FRichTextHandleLayerOffsetVector);

      LRichTextLayerPanel.DrawRichTextBorderHandles(FRichTextHandleLayer.Bitmap.Canvas,
                                                    FRichTextHandleLayerOffsetVector);
    end;
  end;
end;

// calculate the offset vector of the text handle layer relative to the image layer
procedure TfrmChild.CalcRichTextHandleLayerOffsetVector;
var
  HandleLayerLeft : Single;
  HandleLayerTop  : Single;
  CurrentLayerLeft: Single;
  CurrentLayerTop : Single;
  TheScale        : Single;
begin
  if Assigned(FRichTextHandleLayer) then
  begin
    TheScale         := 100 / FMagnification;
    HandleLayerLeft  := FRichTextHandleLayer.GetAdjustedLocation.Left * TheScale;
    HandleLayerTop   := FRichTextHandleLayer.GetAdjustedLocation.Top  * TheScale;
    CurrentLayerLeft := FLayerPanelList.SelectedLayerPanel.AssociatedLayer.GetAdjustedLocation.Left * TheScale;
    CurrentLayerTop  := FLayerPanelList.SelectedLayerPanel.AssociatedLayer.GetAdjustedLocation.Top  * TheScale;

    FRichTextHandleLayerOffsetVector.X := Round(CurrentLayerLeft - HandleLayerLeft);
    FRichTextHandleLayerOffsetVector.Y := Round(CurrentLayerTop  - HandleLayerTop);
  end;
end;

procedure TfrmChild.CommitEdits;
var
  LRichTextLayerPanel: TgmRichTextLayerPanel;
begin
  if FLayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
  begin
    LRichTextLayerPanel := TgmRichTextLayerPanel(FLayerPanelList.SelectedLayerPanel);

    LRichTextLayerPanel.RichTextStream.Clear;
    frmRichTextEditor.rchedtRichTextEditor.Lines.SaveToStream(LRichTextLayerPanel.RichTextStream);
    LRichTextLayerPanel.SaveEdits;

    if not LRichTextLayerPanel.IsRenamed then
    begin
      LRichTextLayerPanel.SetLayerName(frmRichTextEditor.rchedtRichTextEditor.Lines[0]);
    end;
    
    frmRichTextEditor.Close;
    frmRichTextEditor.rchedtRichTextEditor.Lines.Clear;
    frmMain.UpdateTextOptions;
  end;
end;

procedure TfrmChild.CancelEdits;
var
  LRichTextLayerPanel: TgmRichTextLayerPanel;
begin
  if FLayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
  begin
    LRichTextLayerPanel := TgmRichTextLayerPanel(FLayerPanelList.SelectedLayerPanel);

    LRichTextLayerPanel.RestoreEdits;
    frmRichTextEditor.Close;
    LRichTextLayerPanel.RichTextStream.Position := 0;
    frmRichTextEditor.CanChange := True;

    try
      frmRichTextEditor.rchedtRichTextEditor.Lines.LoadFromStream(LRichTextLayerPanel.RichTextStream);
    finally
      frmRichTextEditor.CanChange := False;
    end;

    frmRichTextEditor.rchedtRichTextEditor.Lines.Clear;
    frmMain.UpdateTextOptions;
  end;
end;

procedure TfrmChild.FormCreate(Sender: TObject);
begin
{ Common }

  FEditMode := emStandardMode;  // indicate which edit mode we are in
  FFileName := '';
  RefreshCaption;


  FImageProcessed := False;
  FDrawing        := False;
  FMayClick       := True;
  FDoubleClicked  := False;
  FXActual        := 0;
  FYActual        := 0;

  // coordinates of selection space
  FMarqueeX := 0;
  FMarqueeY := 0;

  // points for common use
  FStartPoint       := Point(0, 0);
  FEndPoint         := Point(0, 0);
  FActualStartPoint := Point(0, 0);
  FActualEndPoint   := Point(0, 0);
  FDrawingBasePoint := Point(0, 0);
  FPrevStrokePoint  := Point(0, 0);

  FHistoryBitmap          := TBitmap32.Create;
  FHistoryBitmap.DrawMode := dmBlend;

  // create history manager -- for Undo/Redo
  FHistoryManager := TgmHistoryManager.Create(
    StrToInt(ReadInfoFromIniFile(SECTION_PREFERENCES, IDENT_HISTORY_STATES, '20')));

  FAccumTranslateVector := Point(0, 0);
  FGlobalTopLeft        := Point(0, 0);
  FGlobalBottomRight    := Point(0, 0);
  FKeyIsDown            := False;  // mark if we have pressed a key
  FMagnification        := 100;    // zoom scale of the image, 100% in default
  FPrevWheelDelta       := 0;

{ frmChild }

  { by default, PST_CLEAR_BACKGND is executed at this stage,
    which, in turn, calls ExecClearBackgnd method of ImgView.
    Here I substitute PST_CLEAR_BACKGND with PST_CUSTOM, so force ImgView
    to call the OnPaintStage event instead of performing default action. }
  with imgDrawingArea.PaintStages[0]^ do
  begin
    if Stage = PST_CLEAR_BACKGND then Stage := PST_CUSTOM;
  end;
  
  imgDrawingArea.Bitmap.DrawMode := dmCustom;
  imgDrawingArea.Bitmap.OnPixelCombine := BlendMode.NormalBlend;
  imgDrawingArea.Bitmap.SetSize(frmMain.NewBitmapWidth, frmMain.NewBitmapHeight);
  imgDrawingArea.Scale := 1;
  imgDrawingArea.Bitmap.Changed;

  FLayerPanelList := TgmLayerPanelList.Create(imgDrawingArea.Layers,
                                              frmLayer.scrlbxLayers,
                                              frmRichTextEditor.rchedtRichTextEditor);
  
  FLayerPanelList.OnLayerThumbnailDblClick   := LayerThumbnailDblClick;
  FLayerPanelList.OnLayerPanelClick          := LayerPanelClick;
  FLayerPanelList.OnLayerThumbnailClick      := LayerThumbnailClick;
  FLayerPanelList.OnMaskThumbnailClick       := MaskThumbnailClick;
  FLayerPanelList.OnAddLayerPanelToList      := AfterAddLayerPanelToList;
  FLayerPanelList.OnActiveLayerPanelInList   := AfterActiveLayerPanelInList;
  FLayerPanelList.OnDeleteSelectedLayerPanel := AfterDeleteSelectedLayerPanelFromList;
  FLayerPanelList.OnChainImageClick          := OnLayerChainImageClick;
  
  FLayerTopLeft := Point(0, 0);

  // create channel manager
  FChannelManager := TgmChannelManager.Create(frmChannel.scrlbxChannelPanelContainer,
                                              imgDrawingArea.Layers, FLayerPanelList);

  FChannelManager.OnColorModeChanged          := ColorModeChanged;
  FChannelManager.OnAlphaChannelPanelDblClick := AlphaChannelPanelDblClick;
  FChannelManager.OnQuickMaskPanelDblClick    := QuickMaskPanelDblClick;
  FChannelManager.OnLayerMaskPanelDblClick    := LayerMaskPanelDblClick;
  FChannelManager.OnChannelPanelRightClick    := ChannelPanelRightClick;
  FChannelManager.OnQuickMaskPanelRightClick  := QuickMaskPanelRightClick;
  FChannelManager.OnLayerMaskPanelRightClick  := LayerMaskPanelRightClick;
  FChannelManager.OnChannelChanged            := OnChannelChanged;

  // link the channel manager to layer panel list
  FLayerPanelList.AssociateToChannelManager(FChannelManager);

{ Standard Page }

  FCurvePoint1       := Point(0, 0);
  FCurvePoint2       := Point(0, 0);
  FActualCurvePoint1 := Point(0, 0);
  FActualCurvePoint2 := Point(0, 0);
  FDrawCurveTime     := 0;
  FPolygon           := nil;
  FActualPolygon     := nil;

  FSelectedFigure          := nil;
  FHandleLayer             := nil;
  FMoveDrawingState        := dsNotDrawing;
  FMoveDrawingHandle       := dhNone;
  FRegularBasePoint        := Point(0, 0);
  FRegionSelectOK          := False;
  FHandleLayerOffsetVector := Point(0, 0);

  // for Undo/Redo
  FOldSelectedFigureInfoArray       := nil;
  FOldSelectedFigureLayerIndexArray := nil;
  FOldFigure                        := nil;

{ Marquee page }

  // Marching Ants
  MarchingAntsCounterStart          := 128;
  TmrMarchingAnts.Interval          := 100;
  TmrMarchingAnts.Enabled           := False;
  FMarqueeDrawingState              := dsNotDrawing;
  FMarqueeDrawingHandle             := dhNone;
  FSelection                        := nil;
  FSelectionCopy                    := nil;
  FSelectionHandleLayer             := nil;
  FSelectionHandleLayerOffsetVector := Point(0, 0);
  FSelectionTranslateTarget         := sttNone;

  FRegion := nil;

  // Magnetic Lasso
  FMagneticLasso      := nil;
  FMagneticLassoLayer := nil;

  // Transformation 
  FSelectionTransformation := nil;
  FTransformCopy           := nil;  // used for Undo/Redo
  FTransformLayer          := nil;  // handle layer for the transformation
  FTransformOffsetVector   := Point(0, 0);
  FTransformLayerX         := 0;
  FTransformLayerY         := 0;
  FTransformHandle         := dhNone;

{ Crop Tool }
  FCrop                        := nil;
  FCropHandleLayer             := nil;
  FCropDrawingState            := dsNotDrawing;
  FCropDrawingHandle           := dhNone;
  FCropHandleLayerOffsetVector := Point(0, 0);

{ Pen Tools }
  FPathLayer        := nil;
  FPathLayerX       := 0;
  FPathLayerY       := 0;
  FPathOffsetVector := Point(0, 0);
  FPenPath          := nil;
  FPathSelectHandle := pshNone;
  
  FPathPanelList := TgmPathPanelList.Create(frmPath.scrlbxPathPanelContainer);
  FPathPanelList.OnPathPanelClick    := PathPanelClick;
  FPathPanelList.OnPathPanelDblClick := PathPanelDblClick;
  FPathPanelList.OnUpdatePanelState  := OnUpdatePathPanelState;

  FWholePathIndex        := -1;
  FMouseDownX            := 0;
  FMouseDownY            := 0;
  FMouseMoveX            := 0;
  FMouseMoveY            := 0;
  FOriginalPairState     := psUnknown;
  FOppositeLineOperation := oloAbsoluteOpposite;

  FOldPathList      := nil;            // for Undo/Redo
  FOldPathListState := plsAddNewPath;  // for Undo/Redo
  FModifyPathMode   := mpmNone;

{ Measure Tool }
  FMeasureLine          := nil;
  FMeasureLayer         := nil;
  FMeasureLayerX        := 0;
  FMeasureLayerY        := 0;
  FMeasureDrawingState  := dsNotDrawing;
  FMeasurePointSelector := mpsNone;
  FMeasureOffsetVector  := Point(0, 0);

{ Shape Tool }
  FShapeDrawingHandle  := dhNone;
  FShapeDrawingState   := dsNewFigure;
  FShapeOutlineLayer   := nil;
  FOutlineOffsetVector := Point(0, 0);
  
{ Text Tool }
  FRichTextHandleLayer             := nil;
  FRichTextHandleLayerOffsetVector := Point(0, 0);
  FRichTextDrawingState            := dsNotDrawing;
  FRichTextDrawingHandle           := dhNone;
end; 

procedure TfrmChild.FormActivate(Sender: TObject);
begin
  SetupOnChildFormActivate;

  UpdateChannelFormButtonsEnableState;
  frmChannel.tlbtnSaveSelectionAsChannel.Enabled := True;

  with frmMain do
  begin
    spdbtnStandardMode.Enabled  := True;
    spdbtnQuickMaskMode.Enabled := True;
    spdbtnStandardMode.Down     := (FEditMode = emStandardMode);
    spdbtnQuickMaskMode.Down    := (FEditMode = emQuickMaskMode);
  end;
end; 

procedure TfrmChild.FormDestroy(Sender: TObject);
begin
{ Common }
  // restore the content of the status bar of the main form after the child form is closed
  frmMain.stsbrMain.Panels[0].Text := 'Thank you for choose this program!';

  FHistoryBitmap.Free;
  FLayerPanelList.Free;
  FHistoryManager.Free;
  FChannelManager.Free;

  FPolygon       := nil;
  FActualPolygon := nil;

{ Standard Tools }
  FHandleLayer.Free;
  FOldFigure.Free;

  FOldSelectedFigureInfoArray       := nil;
  FOldSelectedFigureLayerIndexArray := nil;

{ Marquee }
  FSelection.Free;
  FSelectionCopy.Free;
  FSelectionHandleLayer.Free;

  if Assigned(FRegion) then
  begin
    FRegion.Free;
  end;

  // Magnetic Lasso
  if Assigned(FMagneticLasso) then
  begin
    FMagneticLasso.Free;
  end;

  if Assigned(FMagneticLassoLayer) then
  begin
    FMagneticLassoLayer.Free;
  end;

  // Tranformation
  FSelectionTransformation.Free;
  FTransformLayer.Free;
  FTransformCopy.Free;

{ Crop Tool }
  FCrop.Free;
  FCropHandleLayer.Free;

{ Pen Tools }
  FPathLayer.Free;
  FPathPanelList.Free;
  FOldPathList.Free;

{ Measure Tool }
  FMeasureLine.Free;
  FMeasureLayer.Free;

{ Shape Tools }
  FShapeOutlineLayer.Free;
  
{ Text Tool }
  FRichTextHandleLayer.Free;

  ActiveChildForm := nil;
  frmMain.UpdateToolsOptions;
  frmLayer.UpdateLayerOptionsEnableStatus;
  frmPath.UpdatePathOptions;
end; 

procedure TfrmChild.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // call the BeforeExit() procedure to confirm the user to save the image before close the child form
  BeforeExit(Sender);

  if Assigned(FLayerPanelList) then
  begin
    FLayerPanelList.HideAllLayerPanels;
  end;

  if Assigned(FPathPanelList) then
  begin
    FPathPanelList.HideAllPathPanels;
  end;

  FHistoryManager.HideAllPanels;

  if frmRichTextEditor.Visible then
  begin
    frmRichTextEditor.Close;
  end;

  with frmChannel do
  begin
    tlbtnLoadChannelAsSelection.Enabled := False;
    tlbtnSaveSelectionAsChannel.Enabled := False;
    tlbtnCreateNewChannel.Enabled       := False;
    tlbtnDeleteCurrentChannel.Enabled   := False;
  end;

  with frmMain do
  begin
    spdbtnStandardMode.Enabled  := False;
    spdbtnQuickMaskMode.Enabled := False;
    edtCropWidth.Text           := '';
    edtCropHeight.Text          := '';
  end;

  Action := caFree;  // close the child form
end;

procedure TfrmChild.tmrSpecialBrushTimer(Sender: TObject);
var
  Red, Green, Blue: Byte;
  BackEraser      : TgmBackgroundEraser;
  BrushArea       : TRect;
begin
  case frmMain.MainTool of
    gmtBrush:
      begin
        case frmMain.BrushTool of
          btAirBrush:
            begin
              if Assigned(FSelection) then
              begin
                frmMain.AirBrush.Draw(
                  FSelection.CutOriginal, FMarqueeX, FMarqueeY,
                  FChannelManager.ChannelSelectedSet);

                // get brush area
                BrushArea := frmMain.AirBrush.GetBrushArea(FMarqueeX, FMarqueeY);
                
                ShowSelectionAtBrushStroke(BrushArea);
              end
              else
              begin
                case FChannelManager.CurrentChannelType of
                  wctAlpha:
                    begin
                      frmMain.AirBrush.Draw(
                        FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                        FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                      // get refresh area
                      BrushArea             := frmMain.AirBrush.GetBrushArea(FXActual, FYActual);
                      BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                      BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                      FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed(BrushArea);
                    end;

                  wctQuickMask:
                    begin
                      frmMain.AirBrush.Draw(
                        FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                        FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                      // get refresh area
                      BrushArea             := frmMain.AirBrush.GetBrushArea(FXActual, FYActual);
                      BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                      BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                      FChannelManager.QuickMaskPanel.AlphaLayer.Changed(BrushArea);
                    end;

                  wctLayerMask:
                    begin
                      frmMain.AirBrush.Draw(
                        FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                        FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                      // paint on mask channel preview layer, too
                      if Assigned(FChannelManager.LayerMaskPanel) then
                      begin
                        frmMain.AirBrush.Draw(
                          FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap,
                          FXActual, FYActual, FChannelManager.ChannelSelectedSet);
                      end;

                      // get brush area
                      BrushArea := frmMain.AirBrush.GetBrushArea(FXActual, FYActual);

                      if not FLayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
                      begin
                        ApplyMask(BrushArea);
                      end
                      else
                      begin
                        // save Mask into layer's alpha channel
                        FLayerPanelList.SelectedLayerPanel.UpdateLayerAlphaWithMask(BrushArea);
                        
                        // convert from bitmap coordinate space to control coordinate space
                        BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                        BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                      end;
                    end;

                  wctRGB, wctRed, wctGreen, wctBlue:
                    begin
                      // must be on layer

                      // get refresh area
                      BrushArea := frmMain.AirBrush.GetBrushArea(FXActual, FYActual);

                      // restore the alpha channel to the state that before applied mask
                      if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                      begin
                        ReplaceAlphaChannelWithMask(
                          FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                          FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                          BrushArea);
                      end;

                      frmMain.AirBrush.Draw(
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                        FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                      if FLayerPanelList.SelectedLayerPanel.IsHasMask then
                      begin
                        GetAlphaChannelBitmap(
                          FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                          FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                          BrushArea);
                          
                        ApplyMask(BrushArea);
                      end
                      else
                      begin
                        // from bitmap coordinate space to control coordinate space
                        BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                        BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                      end;
                    end;
                end;
              end;
            end;

          btJetGunBrush:
            begin
              if Assigned(FSelection) then
              begin
                frmMain.JetGun.Jet(FSelection.CutOriginal, FMarqueeX, FMarqueeY,
                                   FChannelManager.ChannelSelectedSet);

                // get brush area
                BrushArea := frmMain.JetGun.GetJetArea(FMarqueeX, FMarqueeY);
                ShowSelectionAtBrushStroke(BrushArea);
              end
              else
              begin
                case FChannelManager.CurrentChannelType of
                  wctAlpha:
                    begin
                      frmMain.JetGun.Jet(
                        FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                        FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                      // get refresh area
                      BrushArea             := frmMain.JetGun.GetJetArea(FXActual, FYActual);
                      BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                      BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                      FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed(BrushArea);
                    end;

                  wctQuickMask:
                    begin
                      frmMain.JetGun.Jet(
                        FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                        FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                      // get refresh area
                      BrushArea             := frmMain.JetGun.GetJetArea(FXActual, FYActual);
                      BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                      BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                      FChannelManager.QuickMaskPanel.AlphaLayer.Changed(BrushArea);
                    end;

                  wctLayerMask:
                    begin
                      BrushArea := frmMain.JetGun.GetJetArea(FXActual, FYActual);

                      frmMain.JetGun.Jet(
                        FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                        FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                      // update the mask channel preview layer
                      if Assigned(FChannelManager.LayerMaskPanel) then
                      begin
                        CopyBitmap32(
                          FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap,
                          FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                          BrushArea);
                      end;

                      if not FLayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
                      begin
                        ApplyMask(BrushArea);
                      end
                      else
                      begin
                        // save Mask into layer's alpha channel
                        FLayerPanelList.SelectedLayerPanel.UpdateLayerAlphaWithMask(BrushArea);
                        
                        // convert from bitmap coordinate space to control coordinate space
                        BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                        BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                      end;
                    end;

                  wctRGB, wctRed, wctGreen, wctBlue:
                    begin
                      // must be on layer

                      // get refresh area
                      BrushArea  := frmMain.JetGun.GetJetArea(FXActual, FYActual);

                      // restore the alpha channel of the layer to the state that does not apply the mask
                      if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                      begin
                        ReplaceAlphaChannelWithMask(
                          FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                          FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                          BrushArea);
                      end;

                      frmMain.JetGun.Jet(
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                        FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                      if FLayerPanelList.SelectedLayerPanel.IsHasMask then
                      begin
                        GetAlphaChannelBitmap(
                          FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                          FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                          BrushArea);
                                              
                        ApplyMask(BrushArea);
                      end
                      else
                      begin
                        // from bitmap coordinate space to control coordinate space
                        BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                        BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                      end;
                    end;
                end;
              end;
            end;

          btBlurSharpenBrush:
            begin
              if Assigned(FSelection) then
              begin
                frmMain.GMBrush.Paint(
                  FSelection.CutOriginal, FMarqueeX, FMarqueeY,
                  FChannelManager.ChannelSelectedSet);

                // get brush area
                BrushArea := frmMain.GMBrush.GetBrushArea(FMarqueeX, FMarqueeY);
                ShowSelectionAtBrushStroke(BrushArea);
              end
              else
              begin
                case FChannelManager.CurrentChannelType of
                  wctAlpha:
                    begin
                      frmMain.GMBrush.Paint(
                        FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                        FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                      // get refresh area
                      BrushArea             := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);
                      BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                      BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                      FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed(BrushArea);
                    end;

                  wctQuickMask:
                    begin
                      frmMain.GMBrush.Paint(
                        FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                        FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                      // get refresh area
                      BrushArea             := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);
                      BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                      BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                      FChannelManager.QuickMaskPanel.AlphaLayer.Changed(BrushArea);
                    end;

                  wctLayerMask:
                    begin
                      frmMain.AirBrush.Draw(
                        FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                        FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                      // paint on mask channel preview layer, too
                      if Assigned(FChannelManager.LayerMaskPanel) then
                      begin
                        frmMain.AirBrush.Draw(
                          FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap,
                          FXActual, FYActual, FChannelManager.ChannelSelectedSet);
                      end;

                      // get brush area
                      BrushArea := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);

                      if not FLayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
                      begin
                        ApplyMask(BrushArea);
                      end
                      else
                      begin
                        // save Mask into layer's alpha channel
                        FLayerPanelList.SelectedLayerPanel.UpdateLayerAlphaWithMask(BrushArea);

                        // convert from bitmap coordinate space to control coordinate space
                        BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                        BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                      end;
                    end;

                  wctRGB, wctRed, wctGreen, wctBlue:
                    begin
                      // get refresh area
                      BrushArea := frmMain.GMBrush.GetBrushArea(FXActual, FYActual);

                      // restore the alpha channel to the state that before applied mask
                      if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                      begin
                        ReplaceAlphaChannelWithMask(
                          FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                          FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                          BrushArea);
                      end;

                      frmMain.GMBrush.Paint(
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                        FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                      if FLayerPanelList.SelectedLayerPanel.IsHasMask then
                      begin
                        GetAlphaChannelBitmap(
                          FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                          FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                          BrushArea);
                          
                        ApplyMask(BrushArea);
                      end
                      else
                      begin
                        // from bitmap coordinate space to control coordinate space
                        BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                        BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                      end;
                    end;
                end;
              end;
            end;
        end;
      end;

    gmtEraser:
      begin
        case frmMain.EraserTool of
          etEraser:
            begin
              if Assigned(FSelection) then
              begin
                frmMain.GMEraser.Paint(FSelection.CutOriginal, FMarqueeX, FMarqueeY,
                                       FChannelManager.ChannelSelectedSet);

                // get brush area
                BrushArea := frmMain.AirBrush.GetBrushArea(FMarqueeX, FMarqueeY);
                ShowSelectionAtBrushStroke(BrushArea);
              end
              else
              begin
                case FChannelManager.CurrentChannelType of
                  wctAlpha:
                    begin
                      frmMain.GMEraser.Paint(
                        FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                        FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                      // get refresh area
                      BrushArea             := frmMain.GMEraser.GetBrushArea(FXActual, FYActual);
                      BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                      BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                      FChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed(BrushArea);
                    end;

                  wctQuickMask:
                    begin
                      frmMain.GMEraser.Paint(
                        FChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                        FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                      // get refresh area
                      BrushArea             := frmMain.GMEraser.GetBrushArea(FXActual, FYActual);
                      BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                      BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                      FChannelManager.QuickMaskPanel.AlphaLayer.Changed(BrushArea);
                    end;

                  wctLayerMask:
                    begin
                      frmMain.GMEraser.Paint(
                        FLayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                        FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                      // paint on mask channel preview layer, too
                      if Assigned(FChannelManager.LayerMaskPanel) then
                      begin
                        frmMain.GMEraser.Paint(
                          FChannelManager.LayerMaskPanel.AlphaLayer.Bitmap,
                          FXActual, FYActual, FChannelManager.ChannelSelectedSet);
                      end;

                      // get brush area
                      BrushArea := frmMain.GMEraser.GetBrushArea(FXActual, FYActual);

                      if not FLayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
                      begin
                        ApplyMask(BrushArea);
                      end
                      else
                      begin
                        // save Mask into layer's alpha channel
                        FLayerPanelList.SelectedLayerPanel.UpdateLayerAlphaWithMask(BrushArea);

                        // convert from bitmap coordinate space to control coordinate space
                        BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                        BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                      end;
                    end;

                  wctRGB, wctRed, wctGreen, wctBlue:
                    begin
                      // must be on layer

                      BrushArea := frmMain.GMEraser.GetBrushArea(FXActual, FYActual);

                      // restore the alpha channel to the state that before applied mask
                      if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                      begin
                        ReplaceAlphaChannelWithMask(
                          FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                          FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                          BrushArea);
                      end;

                      frmMain.GMEraser.Paint(
                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                        FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                      if FLayerPanelList.SelectedLayerPanel.IsHasMask then
                      begin
                        GetAlphaChannelBitmap(
                          FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                          FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                          BrushArea);
                          
                        ApplyMask(BrushArea);
                      end
                      else
                      begin
                        // from bitmap coordinate space to control coordinate space
                        BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                        BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                        FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                      end;
                    end;
                end;

                FPrevStrokePoint := Point(FXActual, FYActual);
              end;
            end;

          etBackgroundEraser:
            begin
              BackEraser := TgmBackgroundEraser(frmMain.GMEraser);

              if Assigned(FSelection) then
              begin
                // sampling color
                if frmMain.EraserSamplingMode = bsmContiguous then
                begin
                  BackEraser.SamplingColor(FMarqueeX, FMarqueeY);
                end;

                BackEraser.Paint(FSelection.CutOriginal, FMarqueeX, FMarqueeY,
                                 FChannelManager.ChannelSelectedSet);

                // get brush area
                BrushArea := frmMain.AirBrush.GetBrushArea(FMarqueeX, FMarqueeY);
                ShowSelectionAtBrushStroke(BrushArea);
              end
              else
              begin
                BrushArea := frmMain.GMEraser.GetBrushArea(FXActual, FYActual);

                // restore the alpha channel to the state that before applied mask
                if FLayerPanelList.SelectedLayerPanel.IsMaskLinked then
                begin
                  ReplaceAlphaChannelWithMask(
                    FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                    FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                    BrushArea);
                end;

                // sampling Color
                if frmMain.EraserSamplingMode = bsmContiguous then
                begin
                  BackEraser.SamplingColor(FXActual, FYActual);
                end;

                frmMain.GMEraser.Paint(
                  FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                  FXActual, FYActual, FChannelManager.ChannelSelectedSet);

                if FLayerPanelList.SelectedLayerPanel.IsHasMask then
                begin
                  GetAlphaChannelBitmap(
                    FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                    FLayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp,
                    BrushArea);
                    
                  ApplyMask(BrushArea);
                end
                else
                begin
                  // from bitmap coordinate space to control coordinate space
                  BrushArea.TopLeft     := imgDrawingArea.BitmapToControl(BrushArea.TopLeft);
                  BrushArea.BottomRight := imgDrawingArea.BitmapToControl(BrushArea.BottomRight);

                  FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed(BrushArea);
                end;
              end;

              // show the sampled color
              if frmMain.EraserSamplingMode = bsmContiguous then
              begin
                Red   := BackEraser.SampledColor shr 16 and $FF;
                Green := BackEraser.SampledColor shr  8 and $FF;
                Blue  := BackEraser.SampledColor        and $FF;

                frmColor.ChangeColorViaTrackBar(Red, Green, Blue);
              end;
            end;
        end;
      end;
  end;
end;

procedure TfrmChild.tmrMarchingAntsTimer(Sender: TObject);
begin
  // Use SHR 1 for slower moving ants and Use SHR 2 for faster moving.
  MarchingAntsCounterStart := MarchingAntsCounterStart shr 1;

  if MarchingAntsCounterStart = 0 then
  begin
    MarchingAntsCounterStart := 128;
  end;
  
  DrawMarchingAnts;
end; 

procedure TfrmChild.FormResize(Sender: TObject);
begin
  FLayerTopLeft := GetLayerTopLeft;
end;

procedure TfrmChild.ChangeCurveControlPoints(Sender: TObject);
begin
  { If FSelectedFigure is nil, it indicates that there is only one figure is selected,
    otherwise, it indicates that there are more than one figures are selected or
    there is no figure is selected.}
    
  if Assigned(FSelectedFigure) then
  begin
    if Sender = pmnitmCurveControlP1
    then FSelectedFigure.CurveControl := ccpFirst
    else
    if Sender = pmnitmCurveControlP2
    then FSelectedFigure.CurveControl := ccpSecond;

    if Assigned(FHandleLayer) then
    begin
      FHandleLayer.Bitmap.Clear($00FFFFFF);
      FLayerPanelList.DrawSelectedFiguresHandles(FHandleLayer.Bitmap, FHandleLayerOffsetVector);
      FHandleLayer.Bitmap.Changed;
    end;
  end;
end;

procedure TfrmChild.pmnChangeCurveControlPointsPopup(Sender: TObject);
begin
  pmnitmCurveControlP1.Checked := False;
  pmnitmCurveControlP2.Checked := False;

  if Assigned(FSelectedFigure) then
  begin
    case FSelectedFigure.CurveControl of
      ccpFirst:
        begin
          pmnitmCurveControlP1.Checked := True;
        end;

      ccpSecond:
        begin
          pmnitmCurveControlP2.Checked := True;
        end;
    end;
  end;
end;

procedure TfrmChild.FormDeactivate(Sender: TObject);
begin
  FinishPolygonalSelection;
  FinishCurves;
  FinishPolygon;

  PrevChildForm := Self;
end; 

procedure TfrmChild.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case frmMain.MainTool of
    gmtMarquee:
      begin
        TranslateSelectionKeyDown(Key, Shift);
      end;

    gmtCrop:
      begin
        TranslateCropKeyDown(Key, Shift);
      end;
      
    gmtShape:
      begin
        TranslateShapeRegionKeyDown(Key, Shift);
      end;
      
    gmtMeasure:
      begin
        TranslateMeasureKeyDown(Key, Shift);
      end;
      
    gmtTextTool:
      begin
        TranslateTextKeyDown(Key, Shift);
      end;
  end;
end;

procedure TfrmChild.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  FKeyIsDown := False;
  
  case frmMain.MainTool of
    gmtMarquee:
      begin
        TranslateSelectionKeyUp(Key, Shift);
      end;

    gmtShape:
      begin
        TranslateShapeRegionKeyUp(Key, Shift);
      end;
      
    gmtMeasure:
      begin
        TranslateMeasureKeyUp(Key, Shift);
      end;
      
    gmtTextTool:
      begin
        TranslateTextKeyUp(Key, Shift);
      end;
  end;
end;

procedure TfrmChild.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  frmMain.ggbrZoomSlider.Position := frmMain.ggbrZoomSlider.Position + 5;
end; 

procedure TfrmChild.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  frmMain.ggbrZoomSlider.Position := frmMain.ggbrZoomSlider.Position - 5;
end;

procedure TfrmChild.imgDrawingAreaDblClick(Sender: TObject);
begin
  case frmMain.MainTool of
    gmtStandard:
      begin
        if frmMain.StandardTool = gstPolygon then
        begin
          if Assigned(FSelection) then
          begin
            if (FChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue]) and
               (not (FLayerPanelList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent])) then
            begin
              ProcessFigureDoubleClickOnLayer;
            end
            else
            begin
              ProcessFigureDoubleClickOnSelection;
            end;
          end
          else
          begin
            case FChannelManager.CurrentChannelType of
              wctAlpha, wctQuickMask, wctLayerMask:
                begin
                  ProcessFigureDoubleClickOnSpecialChannels;
                end;

              wctRGB, wctRed, wctGreen, wctBlue:
                begin
                  ProcessFigureDoubleClickOnLayer;
                end;
            end;
          end;
        end;
      end;

    gmtMarquee:
      begin
        if frmMain.MarqueeTool = mtPolygonal then
        begin
          if Assigned(FRegion) and (FRegion.RegionStyle = gmrsPolygonal) then
          begin
            TgmPolygonalRegion(FRegion).DblClick(Sender);
          end;
        end;
      end;
  end;

  FMayClick      := False;  // indicate not to execute the OnClick event
  FDoubleClicked := True;
end; 

procedure TfrmChild.imgDrawingAreaPaintStage(Sender: TObject;
  Buffer: TBitmap32; StageNum: Cardinal);
var
  LRect: TRect;
begin
  // draw background
  if (Buffer.Height > 0) and (Buffer.Width > 0) then
  begin
    Buffer.Clear($FFC0C0C0);

    // draw thin border, written by Andre Felix Miertschink
    LRect := imgDrawingArea.GetBitmapRect;
    DrawCheckerboardPattern(Buffer, LRect);

    LRect.Left   := LRect.Left - 1;
    LRect.Top    := LRect.Top - 1;
    LRect.Right  := LRect.Right + 1;
    LRect.Bottom := LRect.Bottom + 1;

    Buffer.FrameRectS(LRect, clBlack32);
  end;
end;

procedure TfrmChild.imgDrawingAreaResize(Sender: TObject);
var
  LBmpRect: TRect;
begin
  FLayerTopLeft := GetLayerTopLeft;
  
  CalcLassoLayerOffsetVector;

  if Assigned(FRegion) then
  begin
    LBmpRect        := imgDrawingArea.GetBitmapRect;
    FRegion.OffsetX := LBmpRect.Left;
    FRegion.OffsetY := LBmpRect.Top;

    imgDrawingArea.Update;
    FRegion.DrawRegionOutline;
  end;
end;

procedure TfrmChild.imgDrawingAreaScroll(Sender: TObject);
begin
  FLayerTopLeft := GetLayerTopLeft;
end;

end.
