{ The GraphicsMagic -- an image manipulation program.
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

unit gmLayerAndChannel;

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

{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_CAST OFF}
{$WARN UNSAFE_TYPE OFF}

interface

uses
{ Standard }
  Windows, ExtCtrls, Controls, StdCtrls, SysUtils, Classes, Graphics, ComCtrls,
{ Graphics32 }
  GR32, GR32_Image, GR32_Layers,
{ externals }
  GR32_Add_BlendModes,
{ GraphicsMagic Package Lib }
  gmGradient,
  gmGradientRender,
{ GraphicsMagic Lib}
  gmTypes,
  gmColorBalance,
  gmSelection,
  gmFigures,
  gmCurvesTool,
  gmLevelsTool,
  gmGimpHistogram,
  gmGradientMap,
  gmShapes,
  gmCrop,
  gmResamplers,
  gmChannelMixer;

/////////////////////// Layer Part Begin ///////////////////////////////////////

type
  // mark the layer as Background or Transparent etc
  TgmLayerFeature = (lfNone,
                     lfBackground,
                     lfTransparent,
                     lfSolidColor,
                     lfBrightContrast,
                     lfCurves,
                     lfLevels,
                     lfColorBalance,
                     lfHLSOrHSV,
                     lfInvert,
                     lfThreshold,
                     lfPosterize,
                     lfPattern,
                     lfFigure,
                     lfGradientMap,
                     lfGradientFill,
                     lfShapeRegion,
                     lfRichText,
                     lfChannelMixer);

  // mark process stage -- on the layer or on the mask
  TgmLayerProcessStage = (lpsNone, lpsLayer, lpsMask);

  // indicate the text layer state.
  TgmTextLayerState = (tlsNew, tlsModify);

  TgmFigureInfo = record
    LayerIndex : Integer;  // indicating which layer the figure is on
    FigureIndex: Integer;  // indicating figure index in the figure list
  end;

  // for gradient fill layer
  TgmGradientFillSettings = record
    Style         : TgmGradientRenderMode;
    Angle         : Integer;
    Scale         : Double;
    TranslateX    : Integer;
    TranslateY    : Integer;
    Reversed      : Boolean;

    StartPoint    : TPoint;
    EndPoint      : TPoint;
    CenterPoint   : TPoint;

    OriginalCenter: TPoint;
    OriginalStart : TPoint;
    OriginalEnd   : TPoint;
  end;

  TgmChainImageClickEvent = procedure (Sender: TObject; const ALayerPanelIndex: Integer) of object;

  // Forward Declarations
  TgmLayerPanelList = class;
  TgmChannelManager = class;

//-- TgmLayerPanel -------------------------------------------------------------

  TgmLayerPanel = class(TObject)
  private
    FPanelList: TgmLayerPanelList;  // pointer to the panel list that holding this panel
    FMerged   : Boolean;            // indicating the layer is merged

    // draw layer image stage
    procedure ImagePaintStage(ASender: TObject; ABuffer: TBitmap32; AStageNum: Cardinal);
    procedure MaskPaintStage(ASender: TObject; ABuffer: TBitmap32; AStageNum: Cardinal);
    procedure ChainImagePaintStage(ASender: TObject; ABuffer: TBitmap32; AStageNum: Cardinal);
    procedure SetLayerMasterAlpha(const AValue: Byte);
    procedure SetBlendModeIndex(const AIndex: Integer);
  protected
    FLayerImage           : TImage32;
    FChainImage           : TImage32;
    FWorkStageImage       : TImage;
    FEyeImage             : TImage;     // showing an eye icon in this image for indicating whether this layer is visible
    FPanel                : TPanel;
    FLayerImageHolder     : TPanel;
    FMaskImageHolder      : TPanel;
    FWorkStageImageHolder : TPanel;
    FEyeImageHolder       : TPanel;
    FChainImageHolder     : TPanel;
    FProcessedPart        : TBitmap32;  // remember the pixels that processed by a Canvas, for restore these pixels
    FLastProcessed        : TBitmap32;  // remember the last processed layer
    FLayerName            : TLabel;
    FSelected             : Boolean;
    FLayerVisible         : Boolean;
    FDuplicated           : Boolean;
    FHasMask              : Boolean;    // indicate whether this layer has a mask
    FMaskLinked           : Boolean;    // indicate whether this layer is linked to a mask
    FLockTransparency     : Boolean;
    FRenamed              : Boolean;    // indicate whether the layer panel is renamed
    FHoldMaskInLayerAlpha : Boolean;    // indicate whether the mask is saved to alpha channel of the layer
    FBlendModeIndex       : Integer;
    FBlendModeEvent       : TPixelCombineEvent;
    FLayerProcessStage    : TgmLayerProcessStage;
    FPrevProcessStage     : TgmLayerProcessStage; // remember the last process stage (layer or mask)
    FLayerFeature         : TgmLayerFeature;      // the feature of the layer
    FLayerMasterAlpha     : Byte;
    FAssociatedLayer      : TBitmapLayer;         // a layer that associated with this panel

    FOnLayerThumbnailDblClick : TNotifyEvent;     // OnDblClick event for layer thumbnail

    procedure ResizeMask(const ANewWidth, ANewHeight: Integer;
      const AOptions: TgmResamplingOptions);

    procedure ResizeEffectLayer(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AOptions: TgmResamplingOptions);

    procedure ChangeMaskCanvasSize(const ANewWidth, ANewHeight: Integer;
      const AAnchor: TgmAnchorDirection);

    procedure ChangeEffectLayerCanvasSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AAnchor: TgmAnchorDirection);

    procedure RotateMaskCanvas(const ADeg: Integer;
       const ADirection: TgmRotateDirection);
    
    procedure RotateEffectLayerCanvas(const AImageControl: TCustomImage32;
      const ADeg: Integer; const ADirection: TgmRotateDirection;
      const AResizeBackground: Boolean);

    procedure CropEffectLayer(const AImageControl: TCustomImage32;
      const ACrop: TgmCrop);

    // property methods
    procedure SetLayerVisible(const AValue: Boolean);
    procedure SetHasMask(const AValue: Boolean);
    procedure SetMaskLinked(const AValue: Boolean);

    // callbacks
    procedure LayerThumbnailDblClick(ASender: TObject); virtual;
  public
    FMaskImage           : TImage32;
    FLastAlphaChannelBmp : TBitmap32;  // remember the last alpha channel of a layer

    constructor Create(const AOwner: TWinControl; const ALayer: TBitmapLayer);
    destructor Destroy; override;

    procedure Update; virtual;
    procedure DrawPhotoshopStyleColorThumbnail(const AColor: TColor);
    procedure SetLayerName(const AName: string);
    procedure UpdateLayerThumbnail;
    procedure UpdateMaskThumbnail;
    procedure UpdateLayerPanelState;
    procedure ShowThumbnailByRightOrder;
    procedure AddMask;        // create and connect to a mask
    procedure UpdateLayerAlphaWithMask; overload;
    procedure UpdateLayerAlphaWithMask(const ARect: TRect); overload;

    procedure AssociateLayerToPanel(const ALayerCollection: TLayerCollection;
      const AIndex: Integer);

    procedure SynchronizeProcessStage;

    function IsEmptyLayer: Boolean;
    function PointOnLayerPanel(const ASender: TObject): Boolean;
    function PointOnChainImage(const ASender: TObject): Boolean;

    procedure LayerPixelBlend(F: TColor32; var B: TColor32; M: TColor32); virtual; abstract;

    procedure ChangeImageSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AOptions: TgmResamplingOptions); virtual; abstract;

    procedure ChangeCanvasSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AAnchor: TgmAnchorDirection;
      const ABackgroundColor: TColor32); virtual; abstract;

    procedure RotateCanvas(const AImageControl: TCustomImage32;
      const ADeg: Integer; const ADirection: TgmRotateDirection;
      const AResizeBackground: Boolean; const ABackColor: TColor32); virtual; abstract;

    procedure CropImage(const AImageControl: TCustomImage32;
      const ACrop: TgmCrop; const ABackColor: TColor32); virtual; abstract;

    procedure CropMask(const ACrop: TgmCrop); overload;
    procedure CropMask(const ACropArea: TRect); overload;

    function DuplicateCurrentLayerPanel(const AOwner: TWinControl;
      const ALayers: TLayerCollection; const ALayerIndex: Integer;
      const ALayerName: string): TgmLayerPanel; virtual; abstract;

    // save the layer to a stream for output it to a '*gmd' file later
    procedure SaveToStream(const AStream: TStream); virtual; abstract;

    property AssociatedLayer          : TBitmapLayer         read FAssociatedLayer;
    property LayerImage               : TImage32             read FLayerImage;
    property ChainImage               : TImage32             read FChainImage;
    property WorkStageImage           : TImage               read FWorkStageImage;
    property EyeImage                 : TImage               read FEyeImage;
    property Panel                    : TPanel               read FPanel;
    property LayerImageHolder         : TPanel               read FLayerImageHolder;
    property MaskImageHolder          : TPanel               read FMaskImageHolder;
    property WorkStageImageHolder     : TPanel               read FWorkStageImageHolder;
    property ChainImageHolder         : TPanel               read FChainImageHolder;
    property EyeImageHolder           : TPanel               read FEyeImageHolder;
    property ProcessedPart            : TBitmap32            read FProcessedPart;
    property LastProcessed            : TBitmap32            read FLastProcessed;
    property LayerName                : TLabel               read FLayerName;
    property IsSelected               : Boolean              read FSelected                 write FSelected;
    property IsLayerVisible           : Boolean              read FLayerVisible             write SetLayerVisible;
    property IsDuplicated             : Boolean              read FDuplicated               write FDuplicated;
    property IsMerged                 : Boolean              read FMerged                   write FMerged;
    property IsHasMask                : Boolean              read FHasMask                  write SetHasMask;
    property IsMaskLinked             : Boolean              read FMaskLinked               write SetMaskLinked;
    property IsLockTransparency       : Boolean              read FLockTransparency         write FLockTransparency;
    property IsRenamed                : Boolean              read FRenamed                  write FRenamed;
    property IsHoldMaskInLayerAlpha   : Boolean              read FHoldMaskInLayerAlpha;
    property BlendModeIndex           : Integer              read FBlendModeIndex           write SetBlendModeIndex;
    property BlendModeEvent           : TPixelCombineEvent   read FBlendModeEvent           write FBlendModeEvent;
    property LayerProcessStage        : TgmLayerProcessStage read FLayerProcessStage        write FLayerProcessStage;
    property PrevProcessStage         : TgmLayerProcessStage read FPrevProcessStage         write FPrevProcessStage;
    property LayerFeature             : TgmLayerFeature      read FLayerFeature             write FLayerFeature;
    property LayerMasterAlpha         : Byte                 read FLayerMasterAlpha         write SetLayerMasterAlpha;
    property OnLayerThumbnailDblClick : TNotifyEvent         read FOnLayerThumbnailDblClick write FOnLayerThumbnailDblClick;
  end;

//-- TgmBackgroundLayerPanel ---------------------------------------------------

  TgmBackgroundLayerPanel = class(TgmLayerPanel)
  public
    constructor Create(const AOwner: TWinControl; const ALayer: TBitmapLayer); 

    procedure LayerPixelBlend(F: TColor32; var B: TColor32; M: TColor32); override;

    procedure ChangeImageSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AOptions: TgmResamplingOptions); override;

    procedure ChangeCanvasSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AAnchor: TgmAnchorDirection;
      const ABackgroundColor: TColor32); override;

    procedure RotateCanvas(const AImageControl: TCustomImage32;
      const ADeg: Integer; const ADirection: TgmRotateDirection;
      const AResizeBackground: Boolean; const ABackColor: TColor32); override;

    procedure CropImage(const AImageControl: TCustomImage32;
      const ACrop: TgmCrop; const ABackColor: TColor32); override;

    function DuplicateCurrentLayerPanel(const AOwner: TWinControl;
      const ALayers: TLayerCollection; const ALayerIndex: Integer;
      const ALayerName: string): TgmLayerPanel; override;

    // save the layer to a stream for output it to a '*gmd' file later
    procedure SaveToStream(const AStream: TStream); override;
  end;

//-- TgmTransparentLayerPanel --------------------------------------------------

  TgmTransparentLayerPanel = class(TgmLayerPanel)
  public
    constructor Create(const AOwner: TWinControl; const ALayer: TBitmapLayer); 

    procedure LayerPixelBlend(F: TColor32; var B: TColor32; M: TColor32); override;

    procedure ChangeImageSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AOptions: TgmResamplingOptions); override;

    procedure ChangeCanvasSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AAnchor: TgmAnchorDirection;
      const ABackgroundColor: TColor32); override;

    procedure RotateCanvas(const AImageControl: TCustomImage32;
      const ADeg: Integer; const ADirection: TgmRotateDirection;
      const AResizeBackground: Boolean; const ABackColor: TColor32); override;

    procedure CropImage(const AImageControl: TCustomImage32;
      const ACrop: TgmCrop; const ABackColor: TColor32); override;

    function DuplicateCurrentLayerPanel(const AOwner: TWinControl;
      const ALayers: TLayerCollection; const ALayerIndex: Integer;
      const ALayerName: string): TgmLayerPanel; override;

    // save the layer to a stream for output it to a '*gmd' file later
    procedure SaveToStream(const AStream: TStream); override;
  end;

//-- TgmSolidColorLayerPanel ---------------------------------------------------

  TgmSolidColorLayerPanel = class(TgmLayerPanel)
  private
    FSolidColor: TColor;
    FThumbnailW: Integer;
    FThumbnailH: Integer;

    procedure DrawSolidColorLayerThumbnail;
    procedure SetSolidColor(const AColor: TColor);
  public
    constructor Create(const AOwner: TWinControl; const ALayer: TBitmapLayer); 

    procedure LayerPixelBlend(F: TColor32; var B: TColor32; M: TColor32); override;

    procedure ChangeImageSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AOptions: TgmResamplingOptions); override;

    procedure ChangeCanvasSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AAnchor: TgmAnchorDirection;
      const ABackgroundColor: TColor32); override;

    procedure RotateCanvas(const AImageControl: TCustomImage32;
      const ADeg: Integer; const ADirection: TgmRotateDirection;
      const AResizeBackground: Boolean; const ABackColor: TColor32); override;

    procedure CropImage(const AImageControl: TCustomImage32;
      const ACrop: TgmCrop; const ABackColor: TColor32); override;

    function DuplicateCurrentLayerPanel(const AOwner: TWinControl;
      const ALayers: TLayerCollection; const ALayerIndex: Integer;
      const ALayerName: string): TgmLayerPanel; override;

    // save the layer to a stream for output it to a '*gmd' file later
    procedure SaveToStream(const AStream: TStream); override;

    property SolidColor: TColor read FSolidColor write SetSolidColor;
  end;

//-- TgmGradientFillLayerPanel -------------------------------------------------

  TgmGradientFillLayerPanel = class(TgmLayerPanel)
  private
    FGradientThumbnail: TBitmap32;
    FGradient         : TgmGradientItem;
    FStyle            : TgmGradientRenderMode;
    FAngle            : Integer;
    FScale            : Double;
    FTranslateX       : Integer;
    FTranslateY       : Integer;
    FReversed         : Boolean;

    FStartPoint       : TPoint;
    FEndPoint         : TPoint;
    FCenterPoint      : TPoint;

    FOriginalCenter   : TPoint;
    FOriginalStart    : TPoint;
    FOriginalEnd      : TPoint;

    { Copy options }
    FLastGradient     : TgmGradientItem;
    FLastStyle        : TgmGradientRenderMode;
    FLastAngle        : Integer;
    FLastScale        : Double;
    FLastTranslateX   : Integer;
    FLastTranslateY   : Integer;
    FLastReversed     : Boolean;
    FLastStartPoint   : TPoint;
    FLastEndPoint     : TPoint;
    FLastCenterPoint  : TPoint;
    FLastOriginalStart: TPoint;
    FLastOriginalEnd  : TPoint;

    procedure SetGradient(const AGradient: TgmGradientItem);
    procedure SetStyle(const AStyle: TgmGradientRenderMode);
    procedure SetAngle(const AAngle: Integer);
    procedure SetScale(const AScale: Double);
    procedure SetTranslateX(const AValue: Integer);
    procedure SetTranslateY(const AValue: Integer);
    procedure SetReverse(const AReverse: Boolean);
  public
    constructor Create(const AOwner: TWinControl; const ALayer: TBitmapLayer;
      const AGradient: TgmGradientItem);
       
    destructor Destroy; override;

    procedure CalculateGradientCoord;
    procedure DrawGradientOnLayer;
    procedure DrawGradientFillLayerThumbnail;
    procedure LayerPixelBlend(F: TColor32; var B: TColor32; M: TColor32); override;

    procedure ChangeImageSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AOptions: TgmResamplingOptions); override;

    procedure ChangeCanvasSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AAnchor: TgmAnchorDirection;
      const ABackgroundColor: TColor32); override;

    procedure RotateCanvas(const AImageControl: TCustomImage32;
      const ADeg: Integer; const ADirection: TgmRotateDirection;
      const AResizeBackground: Boolean; const ABackColor: TColor32); override;

    procedure CropImage(const AImageControl: TCustomImage32;
      const ACrop: TgmCrop; const ABackColor: TColor32); override;

    function DuplicateCurrentLayerPanel(const AOwner: TWinControl;
      const ALayers: TLayerCollection; const ALayerIndex: Integer;
      const ALayerName: string): TgmLayerPanel; override;

    procedure SaveLastAdjustment;
    procedure RestoreLastAdjustment;

    // set up several properties with just one call
    procedure Setup(const ASettings: TgmGradientFillSettings);

    // save the layer to a stream for output it to a '*gmd' file later
    procedure SaveToStream(const AStream: TStream); override;

    property GradientThumbnail: TBitmap32             read FGradientThumbnail;
    property Gradient         : TgmGradientItem       read FGradient       write SetGradient;
    property Style            : TgmGradientRenderMode read FStyle          write SetStyle;
    property Scale            : Double                read FScale          write SetScale;
    property IsReversed       : Boolean               read FReversed       write SetReverse;
    property Angle            : Integer               read FAngle          write SetAngle;
    property TranslateX       : Integer               read FTranslateX     write SetTranslateX;
    property TranslateY       : Integer               read FTranslateY     write SetTranslateY;
    property StartPoint       : TPoint                read FStartPoint     write FStartPoint;
    property EndPoint         : TPoint                read FEndPoint       write FEndPoint;
    property CenterPoint      : TPoint                read FCenterPoint    write FCenterPoint;
    property OriginalCenter   : TPoint                read FOriginalCenter write FOriginalCenter;
    property OriginalStart    : TPoint                read FOriginalStart  write FOriginalStart;
    property OriginalEnd      : TPoint                read FOriginalEnd    write FOriginalEnd;

    property LastGradient     : TgmGradientItem       read FLastGradient;
    property LastStyle        : TgmGradientRenderMode read FLastStyle;
    property LastScale        : Double                read FLastScale;
    property IsLastReversed   : Boolean               read FLastReversed;
    property LastAngle        : Integer               read FLastAngle;
    property LastTranslateX   : Integer               read FLastTranslateX;
    property LastTranslateY   : Integer               read FLastTranslateY;
    property LastStartPoint   : TPoint                read FLastStartPoint;
    property LastEndPoint     : TPoint                read FLastEndPoint;
    property LastCenterPoint  : TPoint                read FLastCenterPoint;
    property LastOriginalStart: TPoint                read FLastOriginalStart;
    property LastOriginalEnd  : TPoint                read FLastOriginalEnd;
  end;

//-- TgmBrightContrastLayerPanel -----------------------------------------------

  TgmBrightContrastLayerPanel = class(TgmLayerPanel)
  private
    FAdjustBrightness: Integer;
    FAdjustContrast  : Integer;
    FLastBrightness  : Integer;
    FLastContrast    : Integer;
    FPreview         : Boolean;  // indicating whether preview the result in the Brightness/Contrast dialog
  public
    constructor Create(const AOwner: TWinControl; const ALayer: TBitmapLayer); 

    procedure LayerPixelBlend(F: TColor32; var B: TColor32; M: TColor32); override;

    procedure ChangeImageSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AOptions: TgmResamplingOptions); override;

    procedure ChangeCanvasSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AAnchor: TgmAnchorDirection;
      const ABackgroundColor: TColor32); override;

    procedure RotateCanvas(const AImageControl: TCustomImage32;
      const ADeg: Integer; const ADirection: TgmRotateDirection;
      const AResizeBackground: Boolean; const ABackColor: TColor32); override;

    procedure CropImage(const AImageControl: TCustomImage32;
      const ACrop: TgmCrop; const ABackColor: TColor32); override;

    function DuplicateCurrentLayerPanel(const AOwner: TWinControl;
      const ALayers: TLayerCollection; const ALayerIndex: Integer;
      const ALayerName: string): TgmLayerPanel; override;

    procedure SaveLastAdjustment;
    procedure RestoreLastAdjustment;

    // save the layer to a stream for output it to a '*gmd' file later
    procedure SaveToStream(const AStream: TStream); override;

    property AdjustBrightness: Integer read FAdjustBrightness write FAdjustBrightness;
    property LastBrightness  : Integer read FLastBrightness   write FLastBrightness;
    property AdjustContrast  : Integer read FAdjustContrast   write FAdjustContrast;
    property LastContrast    : Integer read FLastContrast     write FLastContrast;
    property IsPreview       : Boolean read FPreview          write FPreview;
  end;

//-- TgmCurvesLayerPanel -------------------------------------------------------

  TgmCurvesLayerPanel = class(TgmLayerPanel)
  private
    FFlattenedLayer: TBitmap32;
    FCurvesTool    : TgmCurvesTool;
    FLastCurvesTool: TgmCurvesTool;
    FPreview       : Boolean;  // indicating whether preview the result in Curves dialog
  public
    constructor Create(const AOwner: TWinControl; const ALayer: TBitmapLayer);
    destructor Destroy; override;

    procedure SetFlattenedLayer(const ABitmap: TBitmap32);
    procedure LayerPixelBlend(F: TColor32; var B: TColor32; M: TColor32); override;

    procedure ChangeImageSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AOptions: TgmResamplingOptions); override;

    procedure ChangeCanvasSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AAnchor: TgmAnchorDirection;
      const ABackgroundColor: TColor32); override;

    procedure RotateCanvas(const AImageControl: TCustomImage32;
      const ADeg: Integer; const ADirection: TgmRotateDirection;
      const AResizeBackground: Boolean; const ABackColor: TColor32); override;

    procedure CropImage(const AImageControl: TCustomImage32;
      const ACrop: TgmCrop; const ABackColor: TColor32); override;

    function DuplicateCurrentLayerPanel(const AOwner: TWinControl;
      const ALayers: TLayerCollection; const ALayerIndex: Integer;
      const ALayerName: string): TgmLayerPanel; override;

    procedure SaveLastAdjustment;
    procedure RestoreLastAdjustment;

    // save the layer to a stream for output it to a '*gmd' file later
    procedure SaveToStream(const AStream: TStream); override;

    property FlattenedLayer: TBitmap32     read FFlattenedLayer write SetFlattenedLayer;
    property CurvesTool    : TgmCurvesTool read FCurvesTool     write FCurvesTool;
    property LastCurvesTool: TgmCurvesTool read FLastCurvesTool;
    property IsPreview     : Boolean       read FPreview        write FPreview;
  end;

//-- TgmLevelsLayerPanel -------------------------------------------------------

  TgmLevelsLayerPanel = class(TgmLayerPanel)
  private
    FFlattenedLayer: TBitmap32;
    FLevelsTool    : TgmLevelsTool;
    FLastLevelsTool: TgmLevelsTool;
    FHistogramScale: TgmGimpHistogramScale;
    FPreview       : Boolean;  // whether preview the result in Levels dialog
  public
    constructor Create(const AOwner: TWinControl; const ALayer: TBitmapLayer); 
    destructor Destroy; override;

    procedure SetFlattenedLayer(const ABitmap: TBitmap32);
    procedure LayerPixelBlend(F: TColor32; var B: TColor32; M: TColor32); override;

    procedure ChangeImageSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AOptions: TgmResamplingOptions); override;

    procedure ChangeCanvasSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AAnchor: TgmAnchorDirection;
      const ABackgroundColor: TColor32); override;

    procedure RotateCanvas(const AImageControl: TCustomImage32;
      const ADeg: Integer; const ADirection: TgmRotateDirection;
      const AResizeBackground: Boolean; const ABackColor: TColor32); override;

    procedure CropImage(const AImageControl: TCustomImage32;
      const ACrop: TgmCrop; const ABackColor: TColor32); override;

    function DuplicateCurrentLayerPanel(const AOwner: TWinControl;
      const ALayers: TLayerCollection; const ALayerIndex: Integer;
      const ALayerName: string): TgmLayerPanel; override;

    procedure SaveLastAdjustment;
    procedure RestoreLastAdjustment;

    // save the layer to a stream for output it to a '*gmd' file later
    procedure SaveToStream(const AStream: TStream); override;

    property FlattenedLayer: TBitmap32             read FFlattenedLayer  write SetFlattenedLayer;
    property LevelsTool    : TgmLevelsTool         read FLevelsTool      write FLevelsTool;
    property LastLevelsTool: TgmLevelsTool         read FLastLevelsTool;
    property HistogramScale: TgmGimpHistogramScale read FHistogramScale  write FHistogramScale;
    property IsPreview     : Boolean               read FPreview         write FPreview;
  end;

//-- TgmColorBalanceLayerPanel -------------------------------------------------

  TgmColorBalanceLayerPanel = class(TgmLayerPanel)
  private
    FColorBalance    : TgmColorBalance;
    FLastColorBalance: TgmColorBalance;
    FPreview         : Boolean;  // whether preview the result in Color Balance dialog

    // Adjust color balance for single color.
    function SingleColorBalance(const AColor: TColor32): TColor32;
  public
    constructor Create(const AOwner: TWinControl; const ALayer: TBitmapLayer); 
    destructor Destroy; override;

    procedure LayerPixelBlend(F: TColor32; var B: TColor32; M: TColor32); override;

    procedure ChangeImageSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AOptions: TgmResamplingOptions); override;

    procedure ChangeCanvasSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AAnchor: TgmAnchorDirection;
      const ABackgroundColor: TColor32); override;

    procedure RotateCanvas(const AImageControl: TCustomImage32;
      const ADeg: Integer; const ADirection: TgmRotateDirection;
      const AResizeBackground: Boolean; const ABackColor: TColor32); override;

    procedure CropImage(const AImageControl: TCustomImage32;
      const ACrop: TgmCrop; const ABackColor: TColor32); override;

    function DuplicateCurrentLayerPanel(const AOwner: TWinControl;
      const ALayers: TLayerCollection; const ALayerIndex: Integer;
      const ALayerName: string): TgmLayerPanel; override;

    procedure SaveLastAdjustment;
    procedure RestoreLastAdjustment;

    // save the layer to a stream for output it to a '*gmd' file later
    procedure SaveToStream(const AStream: TStream); override;

    property ColorBalance    : TgmColorBalance read FColorBalance     write FColorBalance;
    property LastColorBalance: TgmColorBalance read FLastColorBalance write FLastColorBalance;
    property IsPreview       : Boolean         read FPreview          write FPreview;
  end;

//-- TgmHueSaturationLayerPanel ------------------------------------------------

  TgmHueSaturationLayerPanel = class(TgmLayerPanel)
  private
    FChangedH       : Integer;
    FChangedLOrV    : Integer;
    FChangedS       : Integer;
    FAdjustMode     : TgmHueSaturationAdjustMode;

    FLastChangedH   : Integer;
    FLastChangedLOrV: Integer;
    FLastChangedS   : Integer;
    FLastAdjustMode : TgmHueSaturationAdjustMode;

    FPreview        : Boolean;  // whether preview the result in Hue/Saturation dialog
  public
    constructor Create(const AOwner: TWinControl; const ALayer: TBitmapLayer); 

    procedure LayerPixelBlend(F: TColor32; var B: TColor32; M: TColor32); override;

    procedure ChangeImageSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AOptions: TgmResamplingOptions); override;

    procedure ChangeCanvasSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AAnchor: TgmAnchorDirection;
      const ABackgroundColor: TColor32); override;

    procedure RotateCanvas(const AImageControl: TCustomImage32;
      const ADeg: Integer; const ADirection: TgmRotateDirection;
      const AResizeBackground: Boolean; const ABackColor: TColor32); override;

    procedure CropImage(const AImageControl: TCustomImage32;
      const ACrop: TgmCrop; const ABackColor: TColor32); override;

    function DuplicateCurrentLayerPanel(const AOwner: TWinControl;
      const ALayers: TLayerCollection; const ALayerIndex: Integer;
      const ALayerName: string): TgmLayerPanel; override;

    procedure SaveLastAdjustment;
    procedure RestoreLastAdjustment;

    // save the layer to a stream for output it to a '*gmd' file later
    procedure SaveToStream(const AStream: TStream); override;

    property ChangedH       : Integer                    read FChangedH    write FChangedH;
    property ChangedLOrV    : Integer                    read FChangedLOrV write FChangedLOrV;
    property ChangedS       : Integer                    read FChangedS    write FChangedS;
    property AdjustMode     : TgmHueSaturationAdjustMode read FAdjustMode  write FAdjustMode;
    property IsPreview      : Boolean                    read FPreview     write FPreview;
    property LastChangedH   : Integer                    read FLastChangedH;
    property LastChangedLOrV: Integer                    read FLastChangedLOrV;
    property LastChangedS   : Integer                    read FLastChangedS;
    property LastAdjustMode : TgmHueSaturationAdjustMode read FLastAdjustMode;
  end;

//-- TgmChannelMixerLayerPanel -------------------------------------------------

  TgmChannelMixerLayerPanel = class(TgmLayerPanel)
  private
    FChannelMixer    : TgmChannelMixer;
    FLastChannelMixer: TgmChannelMixer;
    FPreview         : Boolean;
    FLastPreview     : Boolean;
  public
    constructor Create(const AOwner: TWinControl; const ALayer: TBitmapLayer);
    destructor Destroy; override;

    procedure LayerPixelBlend(F: TColor32; var B: TColor32; M: TColor32); override;
    procedure SaveLastAdjustment;
    procedure RestoreLastAdjustment;

    procedure ChangeImageSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AOptions: TgmResamplingOptions); override;

    procedure ChangeCanvasSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AAnchor: TgmAnchorDirection;
      const ABackgroundColor: TColor32); override;

    procedure RotateCanvas(const AImageControl: TCustomImage32;
      const ADeg: Integer; const ADirection: TgmRotateDirection;
      const AResizeBackground: Boolean; const ABackColor: TColor32); override;

    procedure CropImage(const AImageControl: TCustomImage32;
      const ACrop: TgmCrop; const ABackColor: TColor32); override;

    function DuplicateCurrentLayerPanel(const AOwner: TWinControl;
      const ALayers: TLayerCollection; const ALayerIndex: Integer;
      const ALayerName: string): TgmLayerPanel; override;

    // save the layer to a stream for output it to a '*gmd' file later
    procedure SaveToStream(const AStream: TStream); override;

    property ChannelMixer    : TgmChannelMixer read FChannelMixer;
    property LastChannelMixer: TgmChannelMixer read FLastChannelMixer;
    property IsPreview       : Boolean         read FPreview write FPreview;
    property IsLastPreview   : Boolean         read FLastPreview;
  end;

//-- TgmGradientMapLayerPanel --------------------------------------------------

  TgmGradientMapLayerPanel = class(TgmLayerPanel)
  private
    FGradient    : TgmGradientItem;
    FLastGradient: TgmGradientItem;
    FReversed    : Boolean;
    FLastReversed: Boolean;
    FPreview     : Boolean;

    procedure SetGradient(const AGradient: TgmGradientItem);
    procedure SetLastGradient(const AGradient: TgmGradientItem);
  public
    constructor Create(const AOwner: TWinControl; const ALayer: TBitmapLayer;
      const AGradient: TgmGradientItem);
      
    destructor Destroy; override;

    procedure LayerPixelBlend(F: TColor32; var B: TColor32; M: TColor32); override;

    procedure ChangeImageSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AOptions: TgmResamplingOptions); override;

    procedure ChangeCanvasSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AAnchor: TgmAnchorDirection;
      const ABackgroundColor: TColor32); override;

    procedure RotateCanvas(const AImageControl: TCustomImage32;
      const ADeg: Integer; const ADirection: TgmRotateDirection;
      const AResizeBackground: Boolean; const ABackColor: TColor32); override;

    procedure CropImage(const AImageControl: TCustomImage32;
      const ACrop: TgmCrop; const ABackColor: TColor32); override;

    function DuplicateCurrentLayerPanel(const AOwner: TWinControl;
      const ALayers: TLayerCollection; const ALayerIndex: Integer;
      const ALayerName: string): TgmLayerPanel; override;

    procedure SaveLastAdjustment;
    procedure RestoreLastAdjustment;

    // save the layer to a stream for output it to a '*gmd' file later
    procedure SaveToStream(const AStream: TStream); override;

    property Gradient      : TgmGradientItem read FGradient      write SetGradient;
    property LastGradient  : TgmGradientItem read FLastGradient  write SetLastGradient;
    property IsReversed    : Boolean         read FReversed      write FReversed;
    property IsLastReversed: Boolean         read FLastReversed  write FLastReversed;
    property IsPreview     : Boolean         read FPreview       write FPreview;
  end;

//-- TgmInvertLayerPanel -------------------------------------------------------

  TgmInvertLayerPanel = class(TgmLayerPanel)
  public
    constructor Create(const AOwner: TWinControl; const ALayer: TBitmapLayer); 

    procedure LayerPixelBlend(F: TColor32; var B: TColor32; M: TColor32); override;

    procedure ChangeImageSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AOptions: TgmResamplingOptions); override;

    procedure ChangeCanvasSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AAnchor: TgmAnchorDirection;
      const ABackgroundColor: TColor32); override;

    procedure RotateCanvas(const AImageControl: TCustomImage32;
      const ADeg: Integer; const ADirection: TgmRotateDirection;
      const AResizeBackground: Boolean; const ABackColor: TColor32); override;

    procedure CropImage(const AImageControl: TCustomImage32;
      const ACrop: TgmCrop; const ABackColor: TColor32); override;

    function DuplicateCurrentLayerPanel(const AOwner: TWinControl;
      const ALayers: TLayerCollection; const ALayerIndex: Integer;
      const ALayerName: string): TgmLayerPanel; override;

    // save the layer to a stream for output it to a '*gmd' file later
    procedure SaveToStream(const AStream: TStream); override;
  end;

//-- TgmThresholdLayerPanel ----------------------------------------------------

  TgmThresholdLayerPanel = class(TgmLayerPanel)
  private
    FLevel    : Byte;
    FLastLevel: Byte;
    FPreview  : Boolean;  // whether preview the result in Threshold dialog
  public
    constructor Create(const AOwner: TWinControl; const ALayer: TBitmapLayer); 

    procedure LayerPixelBlend(F: TColor32; var B: TColor32; M: TColor32); override;

    procedure ChangeImageSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AOptions: TgmResamplingOptions); override;

    procedure ChangeCanvasSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AAnchor: TgmAnchorDirection;
      const ABackgroundColor: TColor32); override;

    procedure RotateCanvas(const AImageControl: TCustomImage32;
      const ADeg: Integer; const ADirection: TgmRotateDirection;
      const AResizeBackground: Boolean; const ABackColor: TColor32); override;

    procedure CropImage(const AImageControl: TCustomImage32;
      const ACrop: TgmCrop; const ABackColor: TColor32); override;

    function DuplicateCurrentLayerPanel(const AOwner: TWinControl;
      const ALayers: TLayerCollection; const ALayerIndex: Integer;
      const ALayerName: string): TgmLayerPanel; override;

    procedure SaveLastAdjustment;
    procedure RestoreLastAdjustment;

    // save the layer to a stream for output it to a '*gmd' file later
    procedure SaveToStream(const AStream: TStream); override;

    property Level    : Byte    read FLevel     write FLevel;
    property LastLevel: Byte    read FLastLevel write FLastLevel;
    property IsPreview: Boolean read FPreview   write FPreview;
  end;

//-- TgmPosterizeLayerPanel ----------------------------------------------------

  TgmPosterizeLayerPanel = class(TgmLayerPanel)
  private
    FLevel    : Byte;
    FLastLevel: Byte;
    FPreview  : Boolean;  // whether preview the result in Posterize dialog
  public
    constructor Create(const AOwner: TWinControl; const ALayer: TBitmapLayer); 

    procedure LayerPixelBlend(F: TColor32; var B: TColor32; M: TColor32); override;

    procedure ChangeImageSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AOptions: TgmResamplingOptions); override;

    procedure ChangeCanvasSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AAnchor: TgmAnchorDirection;
      const ABackgroundColor: TColor32); override;

    procedure RotateCanvas(const AImageControl: TCustomImage32;
      const ADeg: Integer; const ADirection: TgmRotateDirection;
      const AResizeBackground: Boolean; const ABackColor: TColor32); override;

    procedure CropImage(const AImageControl: TCustomImage32;
      const ACrop: TgmCrop; const ABackColor: TColor32); override;

    function DuplicateCurrentLayerPanel(const AOwner: TWinControl;
      const ALayers: TLayerCollection; const ALayerIndex: Integer;
      const ALayerName: string): TgmLayerPanel; override;

    procedure SaveLastAdjustment;
    procedure RestoreLastAdjustment;

    // save the layer to a stream for output it to a '*gmd' file later
    procedure SaveToStream(const AStream: TStream); override;

    property Level    : Byte    read FLevel     write FLevel;
    property LastLevel: Byte    read FLastLevel write FLastLevel;
    property IsPreview: Boolean read FPreview   write FPreview;
  end;

//-- TgmPatternLayerPanel ------------------------------------------------------

  TgmPatternLayerPanel = class(TgmLayerPanel)
  private
    FPatternBitmap      : TBitmap32;
    FPatternMark        : TBitmap32;
    FLastPatternBitmap  : TBitmap32;
    FScaledPatternBitmap: TBitmap32;
    FScale              : Double;
    FLastScale          : Double;

    procedure SetScale(const AScale: Double);
  public
    constructor Create(const AOwner: TWinControl; const ALayer: TBitmapLayer;
      const APatternBmp: TBitmap32);
       
    destructor Destroy; override;

    procedure SetPatternBitmap(const APatternBmp: TBitmap32);
    procedure FillPatternOnLayer;
    procedure DrawPatternLayerThumbnail;
    procedure LayerPixelBlend(F: TColor32; var B: TColor32; M: TColor32); override;

    procedure ChangeImageSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AOptions: TgmResamplingOptions); override;

    procedure ChangeCanvasSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AAnchor: TgmAnchorDirection;
      const ABackgroundColor: TColor32); override;

    procedure RotateCanvas(const AImageControl: TCustomImage32;
      const ADeg: Integer; const ADirection: TgmRotateDirection;
      const AResizeBackground: Boolean; const ABackColor: TColor32); override;

    procedure CropImage(const AImageControl: TCustomImage32;
      const ACrop: TgmCrop; const ABackColor: TColor32); override;

    function DuplicateCurrentLayerPanel(const AOwner: TWinControl;
      const ALayers: TLayerCollection; const ALayerIndex: Integer;
      const ALayerName: string): TgmLayerPanel; override;

    procedure SaveLastAdjustment;
    procedure RestoreLastAdjustment;

    // save the layer to a stream for output it to a '*gmd' file later
    procedure SaveToStream(const AStream: TStream); override;

    property PatternBitmap    : TBitmap32 read FPatternBitmap write SetPatternBitmap;
    property PatternMark      : TBitmap32 read FPatternMark;
    property LastPatternBitmap: TBitmap32 read FLastPatternBitmap;
    property Scale            : Double    read FScale         write SetScale;
    property LastScale        : Double    read FLastScale;
  end;

//-- TgmFigureLayerPanel -------------------------------------------------------

  TgmFigureLayerPanel = class(TgmLayerPanel)
  private
    FFigureList   : TgmFigureList;
    FLockFigureBMP: TBitmap32; // save a bitmap that contains locked figures, used for updating a figure layer
  public
    constructor Create(const AOwner: TWinControl; const ALayer: TBitmapLayer); 
    destructor Destroy; override;

    // draw all figures on a specified bitmap
    procedure DrawAllFigures(const ADestBmp: TBitmap32;
      const ABackColor: TColor32; const APenMode: TPenMode;
      const AFigureDrawMode: TgmFigureDrawMode);

    procedure LayerPixelBlend(F: TColor32; var B: TColor32; M: TColor32); override;

    procedure ChangeImageSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AOptions: TgmResamplingOptions); override;

    procedure ChangeCanvasSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AAnchor: TgmAnchorDirection;
      const ABackgroundColor: TColor32); override;

    procedure RotateCanvas(const AImageControl: TCustomImage32;
      const ADeg: Integer; const ADirection: TgmRotateDirection;
      const AResizeBackground: Boolean; const ABackColor: TColor32); override;

    procedure CropImage(const AImageControl: TCustomImage32;
      const ACrop: TgmCrop; const ABackColor: TColor32); override;

    function DuplicateCurrentLayerPanel(const AOwner: TWinControl;
      const ALayers: TLayerCollection; const ALayerIndex: Integer;
      const ALayerName: string): TgmLayerPanel; override;

    // save the layer to a stream for output it to a '*gmd' file later
    procedure SaveToStream(const AStream: TStream); override;

    property FigureList   : TgmFigureList read FFigureList;
    property LockFigureBmp: TBitmap32     read FLockFigureBmp;
  end;

//-- TgmShapeRegionLayerPanel --------------------------------------------------

  TgmShapeRegionLayerPanel = class(TgmLayerPanel)
  private
    FRegionImageHolder: TPanel;
    FRegionImage      : TImage32;
    FRegionColor      : TColor;
    FBrushStyle       : TBrushStyle;
    FDismissed        : Boolean;  // indicating whether the region is already dissmissed (editing is complete)
    FShapeRegion      : TgmShapeRegion;
    FShapeOutlineList : TgmOutlineList;

    procedure DrawShapeRegionColorThumbnail;
    procedure SetRegionColor(const AColor: TColor);
    procedure SetBrushStyle(const AStyle: TBrushStyle);

    procedure RegionThumbnailPaintStage(ASender: TObject; ABuffer: TBitmap32;
      AStageNum: Cardinal);
  public
    constructor Create(const AOwner: TWinControl; const ALayer: TBitmapLayer); 
    destructor Destroy; override;

    procedure LayerPixelBlend(F: TColor32; var B: TColor32; M: TColor32); override;

    procedure ChangeImageSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AOptions: TgmResamplingOptions); override;

    procedure ChangeCanvasSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AAnchor: TgmAnchorDirection;
      const ABackgroundColor: TColor32); override;

    procedure RotateCanvas(const AImageControl: TCustomImage32;
      const ADeg: Integer; const ADirection: TgmRotateDirection;
      const AResizeBackground: Boolean; const ABackColor: TColor32); override;

    procedure CropImage(const AImageControl: TCustomImage32;
      const ACrop: TgmCrop; const ABackColor: TColor32); override;

    function DuplicateCurrentLayerPanel(const AOwner: TWinControl;
      const ALayers: TLayerCollection; const ALayerIndex: Integer;
      const ALayerName: string): TgmLayerPanel; override;

    procedure SetThumbnailPosition;
    procedure UpdateRegionThumbnial;

    // save the layer to a stream for output it to a '*gmd' file later
    procedure SaveToStream(const AStream: TStream); override;

    property RegionColor     : TColor         read FRegionColor write SetRegionColor;
    property BrushStyle      : TBrushStyle    read FBrushStyle  write SetBrushStyle;
    property IsDismissed     : Boolean        read FDismissed   write FDismissed;
    property ShapeRegion     : TgmShapeRegion read FShapeRegion;
    property ShapeOutlineList: TgmOutlineList read FShapeOutlineList;
  end;

//-- TgmRichTextLayerPanel -----------------------------------------------------

  TgmRichTextLayerPanel = class(TgmLayerPanel)
  private
    FAssociatedTextEditor: TRichEdit;
    FTextFileName        : string;
    FEditState           : Boolean; // Indicate whether this layer is on edit state.
    FTextChanged         : Boolean;
    FTextLayerState      : TgmTextLayerState;
    FRichTextStream      : TMemoryStream;
    FCopyStream          : TMemoryStream;
    FBorderStart         : TPoint;
    FBorderEnd           : TPoint;

    function GetBorderWidth : Integer;
    function GetBorderHeight: Integer;
    function GetBorderRect  : TRect;
  public
    constructor Create(const AOwner: TWinControl; const ALayer: TBitmapLayer;
      const ATextEditor: TRichEdit);
      
    destructor Destroy; override;

    procedure LayerPixelBlend(F: TColor32; var B: TColor32; M: TColor32); override;

    procedure ChangeImageSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AOptions: TgmResamplingOptions); override;

    procedure ChangeCanvasSize(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AAnchor: TgmAnchorDirection;
      const ABackgroundColor: TColor32); override;

    procedure RotateCanvas(const AImageControl: TCustomImage32;
      const ADeg: Integer; const ADirection: TgmRotateDirection;
      const AResizeBackground: Boolean; const ABackColor: TColor32); override;

    procedure CropImage(const AImageControl: TCustomImage32;
      const ACrop: TgmCrop; const ABackColor: TColor32); override;

    function DuplicateCurrentLayerPanel(const AOwner: TWinControl;
      const ALayers: TLayerCollection; const ALayerIndex: Integer;
      const ALayerName: string): TgmLayerPanel; override;
      
    procedure SetRichTextBorder(const AStartPoint, AEndPoint: TPoint);
    procedure DrawRichTextBorder(const ACanvas: TCanvas; const AOffsetVector: TPoint);
    procedure DrawRichTextBorderHandles(const ACanvas: TCanvas; const AOffsetVector: TPoint);

    // determine whether the mouse pointer is over a handle of the control border
    function GetHandleAtPoint(const AX, AY: Integer): TgmDrawingHandle;

    // determine whether the mouse pointer is within the text area
    function ContainsPoint(const ATestPoint: TPoint):  Boolean;

    procedure Translate(const ATranslateVector: TPoint);

    // make sure the start point of the text area is always at top left
    procedure StandardizeOrder;
    procedure SaveEdits;
    procedure RestoreEdits;

    // save the layer to a stream for output it to a '*gmd' file later
    procedure SaveToStream(const AStream: TStream); override;

    property RichTextStream  : TMemoryStream     read FRichTextStream;
    property CopyStream      : TMemoryStream     read FCopyStream;
    property BorderWidth     : Integer           read GetBorderWidth;
    property BorderHeight    : Integer           read GetBorderHeight;
    property BorderRect      : TRect             read GetBorderRect;
    property TextLayerState  : TgmTextLayerState read FTextLayerState write FTextLayerState;
    property TextFileName    : string            read FTextFileName   write FTextFileName;
    property IsEditState     : Boolean           read FEditState      write FEditState;
    property IsTextChanged   : Boolean           read FTextChanged    write FTextChanged;
    property BorderStart     : TPoint            read FBorderStart    write FBorderStart;
    property BorderEnd       : TPoint            read FBorderEnd      write FBorderEnd;
  end;

//-- TgmLayerPanelList ---------------------------------------------------------

  TgmLayerPanelList = class(TList)
  private
    FTransparentLayerNumber   : Integer;
    FSolidColorLayerNumber    : Integer;
    FColorBalanceLayerNumber  : Integer;
    FBrightContrastLayerNumber: Integer;
    FHLSOrHSVLayerNumber      : Integer;
    FInvertLayerNumber        : Integer;
    FThresholdLayerNumber     : Integer;
    FPosterizeLayerNumber     : Integer;
    FLevelsLayerNumber        : Integer;
    FCurvesLayerNumber        : Integer;
    FChannelMixerLayerNumber  : Integer;
    FGradientMapLayerNumber   : Integer;
    FGradientFillLayerNumber  : Integer;
    FPatternLayerNumber       : Integer;
    FFigureLayerNumber        : Integer;
    FShapeRegionLayerNumber   : Integer;
    FCurrentIndex             : Integer;
    FPrevIndex                : Integer;

    FAllowRefreshLayerPanels  : Boolean; // indicating if we could refresh the layer panels

    // pointer to currently selected layer panel in the list
    FSelectedLayerPanel       : TgmLayerPanel;

    // pointer to a channel manager
    FAssociatedChannelManager : TgmChannelManager;

    // pointer to a layer collection
    FAssociatedLayerCollection: TLayerCollection;

    { Pointer to a win control that holding layer panels.
      This pointer is used by layer loader. }
    FLayerPanelOwner: TWinControl;

    // pointer to an external text editor
    FAssociatedTextEditor: TRichEdit;

    { Note: the following double click event will link to every layer panel in
      the list when they were added or inserted into the list. So, the code
      for this event have to processes various types of layers. For example,
      the code may be like the following:

      if Sender is TBrightContrastLayerPanel then
      begin
        ...
      end
      else
      if Sender is TGradientFillLayerPanel then
      begin
        ...
      end;  }
    FOnLayerThumbnailDblClick: TNotifyEvent;

    FOnLayerPanelClick         : TNotifyEvent;
    FOnLayerThumbnailClick     : TNotifyEvent;
    FOnMaskThumbnailClick      : TNotifyEvent;
    FOnAddLayerPanelToList     : TNotifyEvent;
    FOnActiveLayerPanelInList  : TNotifyEvent;
    FOnDeleteSelectedLayerPanel: TNotifyEvent;
    FOnChainImageClick         : TgmChainImageClickEvent;

    procedure SetLayerPanelInitialName(const ALayerPanel: TgmLayerPanel);
    procedure ConnectEventsToLayerPanel(const ALayerPanel: TgmLayerPanel);
    procedure MergeVisibleLayersToBitmap(const ADestBmp: TBitmap32);
    
    procedure MergeLayersToBitmapByIndex(const ADestBmp: TBitmap32;
      const AIndexArray: array of Integer);

    procedure DeleteMergedLayers;
    procedure DeselectAllLayerPanels;

    // property writters
    procedure SetCurrentIndex(const AValue: Integer);

    function GetFirstVisibleLayerIndex: Integer;
    function GetSelectedFigureCount: Integer;

    // events
    procedure LayerPanelClick(ASender: TObject);
    procedure LayerThumbnailClick(ASender: TObject);
    procedure MaskThumbnailClick(ASender: TObject);
    procedure LayerVisibleClick(ASender: TObject);
    procedure ChainImageClick(ASender: TObject);
  public
    FFigureLayerIndexArray        : array of Integer;
    FSelectedFigureInfoArray      : array of TgmFigureInfo;
    FSelectedFigureLayerIndexArray: array of Integer;

    constructor Create(const ALayerCollection: TLayerCollection;
      const ALayerPanelOwner: TWinControl; const ATextEditor: TRichEdit);
      
    destructor Destroy; override;

    procedure UpdatePanelsState;
    procedure AddLayerPanelToList(const ALayerPanel: TgmLayerPanel);

    procedure InsertLayerPanelToList(const AIndex: Integer;
      const ALayerPanel: TgmLayerPanel);

    procedure DeleteSelectedLayerPanel;
    procedure DeleteLayerPanelByIndex(const AIndex: Integer);
    procedure DeleteAllLayerPanels;
    procedure InitializeLayerNumbers;

    procedure DecreaseSpecialLayerPanelNumber(const AFeature: TgmLayerFeature;
      const AAmount: Integer = 1);
      
    procedure ShowAllLayerPanels;
    procedure HideAllLayerPanels;
    procedure ActiveLayerPanel(const AIndex: Integer);
    procedure SynchronizeIndex;
    procedure AssociateToChannelManager(const AChannelManager: TgmChannelManager);

    procedure ChangeImageSizeForAllLayers(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AOptions: TgmResamplingOptions);

    procedure ChangeCanvasSizeForAllLayers(const AImageControl: TCustomImage32;
      const ANewWidth, ANewHeight: Integer; const AAnchor: TgmAnchorDirection;
      const ABackgroundColor: TColor32);

    procedure RotateCanvasForAllLayers(const AImageControl: TCustomImage32;
      const ADeg: Integer; const ADirection: TgmRotateDirection;
      const ABackColor: TColor32);

    procedure CropImageForAllLayers(const AImageControl: TCustomImage32;
      const ACrop: TgmCrop; const ABackColor: TColor32);
      
    procedure SetLocationForAllLayers(const ALocation: TFloatRect);
    
    function GetLayerPanelByIndex(const AIndex:Integer): TgmLayerPanel;
    function GetLayerPanelByName(const ALayerName: string): TgmLayerPanel;
    function GetFirstSelectedLayerPanelIndex: Integer;
    function GetBackgroundLayerPanelIndex: Integer;
    function GetClickedLayerPanelIndex(const ASender: TObject): Integer;

    { Merge layers }
    function GetVisibleLayerCount: Integer;
    procedure MergeVisble;
    procedure MergeDown;
    procedure FlattenLayers;

    { Get layers flattened outputs }
    procedure FlattenLayersToBitmap(const ADestBmp: TBitmap); overload;
    
    procedure FlattenLayersToBitmap(const ADestBmp: TBitmap32;
      const ADrawMode: TDrawMode); overload;

    procedure FlattenLayersToBitmap(const ADestBmp: TBitmap32;
      const ADrawMode: TDrawMode; const AStartIndex, AEndIndex: Integer);  overload;

    procedure FlattenLayersToBitmapWithoutMask(const ADestBmp: TBitmap32;
      const ADrawMode: TDrawMode);

    { FigureLayer methods }

    function IfPointOnFigureOnFigureLayer(const AX, AY: Integer): Boolean;
    function IfPointOnSelectedFigureOnFigureLayer(const AX, AY: Integer): Boolean;
    procedure SelectAllFiguresOnFigureLayer;

    procedure SelectFiguresOnFigureLayer(const AShift: TShiftState;
      const AX, AY: Integer);

    procedure SelectRectOnFigureLayer(
      const AIncludeMode: TgmFigureSelectIncludeMode;
      const ARegionStart, ARegionEnd: TPoint);

    procedure DeselectAllFiguresOnFigureLayer;
    function SelectedFigureCountOnFigureLayer: Integer;

    procedure DrawSelectedFiguresHandles(const AStage: TBitmap32;
      const AOffsetVector: TPoint);
      
    procedure TranslateSelectedFigures(const ATranslateVector: TPoint);
    procedure UpdateSelectedFigureLayerThumbnail(const ALayers: TLayerCollection);

    function GetSelectedHandleAtPointOnFigureLayer(const AX, AY: Integer): TgmDrawingHandle;
      
    function GetFirstSelectedFigure: TgmFigureObject;
    procedure GetFigureLayerIndex;
    procedure GetSelectedFigureInfo;

    // draw the deselected figures on figure layers that have selected figures
    procedure DrawDeselectedFiguresOnSelectedFigureLayer(const ALayers: TLayerCollection);

    // draw all figures on figure layers that have selected figures
    procedure DrawAllFiguresOnSelectedFigureLayer(const ALayers: TLayerCollection);

    // draw all figures on a specified figure layer
    procedure DrawAllFiguresOnSpecifiedLayer(const ALayers: TLayerCollection;
      const ALayerIndex: Integer);

    procedure DrawAllFiguresOnFigureLayer(const ALayers: TLayerCollection);

    procedure DrawSelectedFiguresOnCanvas(const ACanvas: TCanvas;
      const APenMode: TPenMode; const AOffset: TPoint; const AFactor: Integer;
      const AFigureDrawMode: TgmFigureDrawMode);

    procedure ApplyMaskOnSelectedFigureLayer;
    procedure ApplyMaskOnAllFigureLayers;
    procedure DeleteSelectedFiguresOnFigureLayer;
    function HasFiguresOnFigureLayer: Boolean;

    // determine whether there are locked figures on figure layers that have selected figures
    function HasLockedFiguresOnSelectedFigureLayer: Boolean;

    // Determine whether there are unlocked figures on figure layers that have selected figures
    function HasUnlockedFiguresOnSelectedFigureLayer: Boolean;

    procedure LockSelectedFiguresOnSelectedFigureLayer;
    procedure UnlockSelectedFiguresOnSelectedFigureLayer;

    procedure SelectFiguresByFigureInfoArray;

    // load layers from a '*.gmd' file that is already loaded in a stream
    function LoadLayersFromStream(const AStream: TStream;
      const AFileVersion, ALoadLayerCount, ALoadLayerWidth, ALoadLayerHeight: Cardinal): Boolean;

    // save the layers to stream for output them in '*.gmd' file later
    procedure SaveLayersToStream(const AStream: TStream);

    property SelectedLayerPanel         : TgmLayerPanel           read FSelectedLayerPanel;
    property SelectedFigureCount        : Integer                 read GetSelectedFigureCount;
    property CurrentIndex               : Integer                 read FCurrentIndex               write SetCurrentIndex;
    property TransparentLayerNumber     : Integer                 read FTransparentLayerNumber     write FTransparentLayerNumber;
    property SolidColorLayerNumber      : Integer                 read FSolidColorLayerNumber      write FSolidColorLayerNumber;
    property ColorBalanceLayerNumber    : Integer                 read FColorBalanceLayerNumber    write FColorBalanceLayerNumber;
    property BrightContrastLayerNumber  : Integer                 read FBrightContrastLayerNumber  write FBrightContrastLayerNumber;
    property HLSLayerNumber             : Integer                 read FHLSOrHSVLayerNumber        write FHLSOrHSVLayerNumber;
    property InvertLayerNumber          : Integer                 read FInvertLayerNumber          write FInvertLayerNumber;
    property ThresholdLayerNumber       : Integer                 read FThresholdLayerNumber       write FThresholdLayerNumber;
    property PosterizeLayerNumber       : Integer                 read FPosterizeLayerNumber       write FPosterizeLayerNumber;
    property LevelsLayerNumber          : Integer                 read FLevelsLayerNumber          write FLevelsLayerNumber;
    property CurvesLayerNumber          : Integer                 read FCurvesLayerNumber          write FCurvesLayerNumber;
    property ChannelMixerLayerNumber    : Integer                 read FChannelMixerLayerNumber    write FChannelMixerLayerNumber;
    property GradientMapLayerNumber     : Integer                 read FGradientMapLayerNumber     write FGradientMapLayerNumber;
    property GradientFillLayerNumber    : Integer                 read FGradientFillLayerNumber    write FGradientFillLayerNumber;
    property PatternLayerNumber         : Integer                 read FPatternLayerNumber         write FPatternLayerNumber;
    property FigureLayerNumber          : Integer                 read FFigureLayerNumber          write FFigureLayerNumber;
    property ShapeRegionLayerNumber     : Integer                 read FShapeRegionLayerNumber     write FShapeRegionLayerNumber;
    property IsAllowRefreshLayerPanels  : Boolean                 read FAllowRefreshLayerPanels    write FAllowRefreshLayerPanels;
    property OnLayerThumbnailDblClick   : TNotifyEvent            read FOnLayerThumbnailDblClick   write FOnLayerThumbnailDblClick;
    property OnLayerPanelClick          : TNotifyEvent            read FOnLayerPanelClick          write FOnLayerPanelClick;
    property OnLayerThumbnailClick      : TNotifyEvent            read FOnLayerThumbnailClick      write FOnLayerThumbnailClick;
    property OnMaskThumbnailClick       : TNotifyEvent            read FOnMaskThumbnailClick       write FOnMaskThumbnailClick;
    property OnAddLayerPanelToList      : TNotifyEvent            read FOnAddLayerPanelToList      write FOnAddLayerPanelToList;
    property OnActiveLayerPanelInList   : TNotifyEvent            read FOnActiveLayerPanelInList   write FOnActiveLayerPanelInList;
    property OnDeleteSelectedLayerPanel : TNotifyEvent            read FOnDeleteSelectedLayerPanel write FOnDeleteSelectedLayerPanel;
    property OnChainImageClick          : TgmChainImageClickEvent read FOnChainImageClick          write FOnChainImageClick;
  end;

//////////////////////////// Channel Part Begin ////////////////////////////////

  TgmMaskColorType      = (mctColor, mctGrayscale);
  TgmMaskColorIndicator = (mciMaskedArea, mciSelectedArea);

  TgmChannelChangeEvent = procedure (const AIsChangeSelectionTartget: Boolean) of object;

//-- TgmChannelPanel -----------------------------------------------------------

  TgmChannelPanel = class(TObject)
  private
    // Draw image stage
    procedure ImagePaintStage(ASender: TObject; ABuffer: TBitmap32;
      AStageNum: Cardinal);
  protected
    FSelected          : Boolean;   // indicate whether the channel is selected
    FChannelVisible    : Boolean;   // indicate whether the channel is visible
    FChannelType       : TgmWorkingChannelType;

    FMainPanel         : TPanel;    // main channel panels
    FChannelImageHolder: TPanel;    // panel for holding TImage32
    FChannelEyeHolder  : TPanel;    // panel for holding the eye image
    FChannelImage      : TImage32;  // used for showing the thumbnail of the channel
    FEyeImage          : TImage32;  // Image32 for holding the eye icon
    FChannelName       : TLabel;    // channel name label

    function GetPanelTop: Integer;
    function GetChannelName: string;

    procedure SetSelected(const AValue: Boolean);
    procedure SetChannelVisibility(const AValue: Boolean);
    procedure SetPanelTop(const AValue: Integer);
    procedure SetChannelName(const AValue: string);
    
    procedure ScaleChannelThumbnail;
  public
    constructor Create(const AOwner: TWinControl);
    destructor Destroy; override;

    procedure ShowThumbnailByRightOrder;

    procedure ConnectChannelEyeClickEvent(const AClickEvent: TNotifyEvent);
    procedure ConnectChannelPanelDblClickEvent(const ADblClickEvent: TNotifyEvent);
    procedure ConnectChannelPanelMouseDownEvent(const AMouseDownEvent: TMouseEvent);
    procedure ConnectChannelImageMouseDownEvent(const AMouseDownEvent: TImgMouseEvent);

    procedure Show;
    procedure Hide;

    function IfClickOnEye(const ASender: TObject): Boolean;
    function IfClickOnPanel(const ASender: TObject): Boolean;

    procedure SaveToStream(const AStream: TStream); virtual;

    property IsSelected      : Boolean               read FSelected       write SetSelected;
    property IsChannelVisible: Boolean               read FChannelVisible write SetChannelVisibility;
    property Top             : Integer               read GetPanelTop     write SetPanelTop;
    property ChannelName     : string                read GetChannelName  write SetChannelName;
    property ChannelType     : TgmWorkingChannelType read FChannelType;
    property ChannelImage    : TImage32              read FChannelImage;
    property EyeImage        : TImage32              read FEyeImage;

  end;

//-- TgmAlphaChannelPanel ------------------------------------------------------

  TgmAlphaChannelPanel = class(TgmChannelPanel)
  private
    FAlphaLayer        : TBitmapLayer;
    FMaskColor         : TColor32;
    FMaskOpacity       : Byte;
    FMaskColorType     : TgmMaskColorType;
    FMaskColorIndicator: TgmMaskColorIndicator;

    function GetMaskOpacityPercent: Single;

    procedure SetChannelVisibility(const AValue: Boolean);
    procedure SetChannelMaskColor(const AValue: TColor32);
    procedure SetMaskOpacityPercent(const AValue: Single);
    procedure SetMaskColorIndicator(const AValue: TgmMaskColorIndicator);
    
    // Events
    procedure AlphaLayerBlend(F: TColor32; var B: TColor32; M: TColor32);
  public
    constructor Create(const AOwner: TWinControl;
      const ALayerCollection: TLayerCollection;
      const ALayerIndex, ALayerWidth, ALayerHeight: Integer;
      const ALayerLocation: TFloatRect; const AMaskColor: TColor32);

    destructor Destroy; override;

    procedure UpdateThumbnail;
    procedure Crop(const ACrop: TgmCrop; const ALayerLocation: TFloatRect); overload;
    procedure Crop(const ACropArea: TRect; const ALayerLocation: TFloatRect); overload;

    procedure ChangeChannelSize(const ANewWidth, ANewHeight: Integer;
      const ALayerLocation: TFloatRect);

    procedure ChangeChannelCanvasSize(const ANewWidth, ANewHeight: Integer;
      const ALayerLocation: TFloatRect; const AAnchor: TgmAnchorDirection;
      const ABackColor: TColor32);

    procedure Rotate(const ADeg: Integer; const ADirection: TgmRotateDirection;
      const ALayerLocation: TFloatRect; const ABackColor: TColor32);

    procedure SaveToStream(const AStream: TStream); override;

    property IsChannelVisible     : Boolean               read FChannelVisible       write SetChannelVisibility;
    property MaskColorType        : TgmMaskColorType      read FMaskColorType        write FMaskColorType;
    property MaskColorIndicator   : TgmMaskColorIndicator read FMaskColorIndicator   write SetMaskColorIndicator;
    property MaskColor            : TColor32              read FMaskColor            write SetChannelMaskColor;
    property MaskOpacityPercent   : Single                read GetMaskOpacityPercent write SetMaskOpacityPercent;
    property AlphaLayer           : TBitmapLayer          read FAlphaLayer;
  end;

//-- TgmQuickMaskPanel ---------------------------------------------------------

  TgmQuickMaskPanel = class(TgmAlphaChannelPanel)
  public
    constructor Create(const AOwner: TWinControl;
      const ALayerCollection: TLayerCollection;
      const ALayerIndex, ALayerWidth, ALayerHeight: Integer;
      const ALayerLocation: TFloatRect;
      const AMaskColor: TColor32);
  end;

//-- TgmLayerMaskPanel ---------------------------------------------------------

  TgmLayerMaskPanel = class(TgmAlphaChannelPanel)
  public
    constructor Create(const AOwner: TWinControl;
      const ALayerCollection: TLayerCollection;
      const ALayerIndex, ALayerWidth, ALayerHeight: Integer;
      const ALayerLocation: TFloatRect;
      const AMaskColor: TColor32;
      const ALayerName: string);
  end;

//-- TgmChannelMannager --------------------------------------------------------

  TgmChannelManager = class(TObject)
  private
    FChannelPanelOwner       : TWinControl;            // pointer to a Win control for holding channel panels
    FLayerCollection         : TLayerCollection;       // pointer to a layer collection for holding alpha channel layer
    FAssociatedLayerPanelList: TgmLayerPanelList;      // pointer to a layer panel list
    FAssociatedLayerPanel    : TgmLayerPanel;
    FClickSender             : TObject;                // remember the mouse right click sender
    FCurrentChannelType      : TgmWorkingChannelType;  // indicate the channel type of current selected channel
                                                       // the TgmChannelType is declared in gmTypes.pas

    { Using FEnabled could enable/disable certain functionalies of
      the manager temporarily. }
    FEnabled                  : Boolean;
    FAllowRefreshChannelPanels: Boolean; // indicating if we could refresh the channel panels

    FChannelPreviewLayer: TBitmapLayer;
    FChannelPreviewSet  : TgmChannelSet;  // the TgmChannelSet is declared in gmTypes.pas
    FChannelSelectedSet : TgmChannelSet;

    // alpha channel panels
    FAlphaChannelPanelList    : TList;
    FSelectedAlphaChannelPanel: TgmAlphaChannelPanel;
    FSelectedAlphaChannelIndex: Integer;
    FAlphaChannelNumber       : Integer; // accumulated number
    FGlobalMaskColor          : TColor32;

    // quick mask panel
    FQuickMaskPanel         : TgmQuickMaskPanel;
    FQuickMaskColor         : TColor32;              // for external modification
    FQuickMaskOpacityPercent: Single;                // for external modification
    FQuickMaskColorIndicator: TgmMaskColorIndicator; // for external modification

    // layer mask
    FLayerMaskPanel         : TgmLayerMaskPanel;
    FLayerMaskColor         : TColor32;
    FLayerMaskOpacityPercent: Single;

    // color channel panels
    FRGBChannelPanel  : TgmChannelPanel;
    FRedChannelPanel  : TgmChannelPanel;
    FGreenChannelPanel: TgmChannelPanel;
    FBlueChannelPanel : TgmChannelPanel;

    FOnColorModeChanged         : TgmColorModeChangedFunc;
    FOnAlphaChannelPanelDblClick: TNotifyEvent;
    FOnQuickMaskPanelDblClick   : TNotifyEvent;
    FOnLayerMaskPanelDblClick   : TNotifyEvent;
    FOnChannelPanelRightClick   : TNotifyEvent;
    FOnQuickMaskPanelRightClick : TNotifyEvent;
    FOnLayerMaskPanelRightClick : TNotifyEvent;
    FOnChannelChanged           : TgmChannelChangeEvent;

    procedure ChannelPreviewLayerBlend(F: TColor32; var B: TColor32; M: TColor32);
    procedure ConnectEventsToColorChannelPanels;

    procedure SelectRedChannel;
    procedure SelectGreenChannel;
    procedure SelectBlueChannel;

    procedure DeselectRedChannel(const AHideChannel: Boolean);
    procedure DeselectGreenChannel(const AHideChannel: Boolean);
    procedure DeselectBlueChannel(const AHideChannel: Boolean);
    procedure DeselectAllAlphaChannels(const AHideChannel: Boolean);
    procedure DeselectQuickMask(const AHideChannel: Boolean);
    procedure DeselectLayerMask(const AHideChannel: Boolean);
    procedure DeselectAllColorChannels(const AHideChannel: Boolean);

    procedure PreviewAllColorChannels;
//    procedure HideAllColorChannels;
    procedure ShowChannelThumbnailsByRightOrder;

    procedure ChangeMaskColorTypeForVisibleAlphaChannels(
      const AMaskColorType: TgmMaskColorType);

    procedure CropChannelPreviewLayer(const ACrop: TgmCrop;
      const ALayerLocation: TFloatRect); overload;

    procedure CropChannelPreviewLayer(const ACropArea: TRect;
      const ALayerLocation: TFloatRect); overload;

    procedure ChangeChannelPreviewLayerSize(const ANewWidth, ANewHeight: Integer;
      const ALayerLocation: TFloatRect);

    // property read/write methods
    procedure SetQuickMaskColor(const AValue: TColor32);
    procedure SetQuickMaskOpacityPercent(const AValue: Single);
    procedure SetQuickMaskColorIndicator(const AValue: TgmMaskColorIndicator);

    function GetVisibleColorChannelCount: Integer;
    function GetVisibleAlphaChannelCount: Integer;
    function GetSelectedColorChannelCount: Integer;
    function GetSelectedAlphaChannelCount: Integer;

    // events
    procedure ChannelEyeClick(ASender: TObject);    // click event for eye icons
    procedure AlphaChannelPanelDblClick(ASender: TObject);
    procedure QuickMaskDblClick(ASender: TObject);
    procedure LayerMaskDblClick(ASender: TObject);

    procedure ChannelPanelMouseDown(ASender: TObject; AButton: TMouseButton;
      AShift: TShiftState; AX, AY: Integer);

    procedure ChannelImageMouseDown(ASender: TObject;
      AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer;
      ALayer: TCustomLayer);

    procedure QuickMaskPanelMouseDown(ASender: TObject; AButton: TMouseButton;
      AShift: TShiftState; AX, AY: Integer);

    procedure QuickMaskImageMouseDown(ASender: TObject;
      AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer;
      ALayer: TCustomLayer);

    procedure LayerMaskPanelMouseDown(ASender: TObject; AButton: TMouseButton;
      AShift: TShiftState; AX, AY: Integer);

    procedure LayerMaskImageMouseDown(ASender: TObject;
      AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer;
      ALayer: TCustomLayer);
  public
    constructor Create(const AOwner: TWinControl;
      const ALayerCollection: TLayerCollection;
      const ALayerPanelList: TgmLayerPanelList);

    destructor Destroy; override;

    // this will affects the name of alpha channel
    procedure DecrementAlphaChannelNumber(const Amount: Integer);

    procedure CreateChannelPreviewLayer(const ALayerCollection: TLayerCollection;
      const ALayerPanelList: TgmLayerPanelList;
      const ALayerWidth, ALayerHeight: Integer;
      const ALayerLocation: TFloatRect);

    procedure ShowAllChannelPanels;
    procedure HideAllChannelPanels;

    procedure UpdateColorChannelThumbnails(ALayerPanelList: TgmLayerPanelList);

    // associate to a layer panel
    procedure AssociateToLayerPanel(const ALayerPanel: TgmLayerPanel);

    procedure AddNewAlphaChannel(const AOwner: TWinControl;
      const ALayerCollection: TLayerCollection;
      const ALayerPanelList: TgmLayerPanelList);

    // add a new alpha channel but don't active it
    procedure AddInativeAlphaChannel(const AOwner: TWinControl;
      const ALayerCollection: TLayerCollection;
      const ALayerPanelList: TgmLayerPanelList);

    procedure InsertNewAlphaChannel(const AOwner: TWinControl;
      const ALayerCollection: TLayerCollection;
      const ALayerPanelList: TgmLayerPanelList;
      const AIndex: Integer);

    procedure SaveSelectionAsChannel(const AOwner: TWinControl;
      const ALayerCollection: TLayerCollection;
      const ALayerPanelList: TgmLayerPanelList;
      const ASelection: TgmSelection);

    procedure CreateQuickMask(const AOwner: TWinControl;
      const ALayerCollection: TLayerCollection;
      const ALayerPanelList: TgmLayerPanelList;
      const ASelection: TgmSelection);

    procedure CreateLayerMaskPanel(const AOwner: TWinControl;
      const ALayerCollection: TLayerCollection;
      const ALayerPanelList: TgmLayerPanelList);

    procedure DeleteChannelPreviewLayer;
    procedure DeleteSelectedAlphaChannels;
    procedure DeleteAlphaChannelByIndex(const AIndex: Integer);
    procedure DeleteAllAlphaChannelPanels;
    procedure DeleteRightClickAlphaChannel;
    procedure DeleteQuickMask;
    procedure DeleteLayerMaskPanel;

    procedure SelectLayerMask;
    procedure SelectQuickMask;
    procedure SelectAllColorChannels;
    procedure SelectAlphaChannelByIndex(const AIndex: Integer);

    procedure DeselectAllChannels(const AIfHideChannel: Boolean);

    procedure DuplicateRightClickChannel(const AOwner: TWinControl;
      const ALayerCollection: TLayerCollection;
      const ALayerPanelList: TgmLayerPanelList;
      const AChannelName: string;
      const AIsInverseChannel: Boolean);

    procedure CropChannels(const ACrop: TgmCrop; const ALayerLocation: TFloatRect); overload;
    procedure CropChannels(const ACropArea: TRect; const ALayerLocation: TFloatRect); overload;

    procedure ChangeChannelsSize(const ANewWidth, ANewHeight: Integer;
      const ALayerLocation: TFloatRect);

    procedure ChangeChannelsCanvasSize(const ANewWidth, ANewHeight: Integer;
      const ALayerLocation: TFloatRect; const AAnchor: TgmAnchorDirection);

    procedure RotateChannels(const ANewWidth, ANewHeight, ADeg: Integer;
      const ADirection: TgmRotateDirection; const ALayerLocation: TFloatRect);

    function GetChannelCompositeBitmap: TBitmap32;
    function GetQuickMaskBitmap: TBitmap32;
    function GetLayerMaskBitmap: TBitmap32;
    function GetAlphaChannelBitmap: TBitmap32;
    function GetAlphaChannelPanelByIndex(const AIndex: Integer): TgmAlphaChannelPanel;
    function GetAlphaChannelPanelByName(const AName: string): TgmAlphaChannelPanel;
    function GetRightClickedChannelName: string;
    function IsSelectedAllColorChannels: Boolean;
    procedure SetLocationForAllChannelLayers(const ALocation: TFloatRect);

    // load channels from a '*.gmd' file that is already loaded in a stream
    function LoadChannelsFromStream(const AStream: TStream;
      const AFileVersion, ALoadChannelCount, ALoadChannelWidth, ALoadChannelHeight: Cardinal): Boolean;

    // save the channels to stream for output them in '*.gmd' file later
    procedure SaveChannelsToStream(const AStream: TStream);

    property IsEnabled                  : Boolean                 read FEnabled                     write FEnabled;
    property IsAllowRefreshChannelPanels: Boolean                 read FAllowRefreshChannelPanels   write FAllowRefreshChannelPanels;
    property ChannelPreviewLayer        : TBitmapLayer            read FChannelPreviewLayer;
    property AlphaChannelPanelList      : TList                   read FAlphaChannelPanelList;
    property AlphaChannelNumber         : Integer                 read FAlphaChannelNumber          write FAlphaChannelNumber;
    property SelectedColorChannelCount  : Integer                 read GetSelectedColorChannelCount;
    property SelectedAlphaChannelCount  : Integer                 read GetSelectedAlphaChannelCount;
    property CurrentChannelType         : TgmWorkingChannelType   read FCurrentChannelType;
    property SelectedAlphaChannelPanel  : TgmAlphaChannelPanel    read FSelectedAlphaChannelPanel;
    property SelectedAlphaChannelIndex  : Integer                 read FSelectedAlphaChannelIndex;
    property ChannelSelectedSet         : TgmChannelSet           read FChannelSelectedSet;
    property GlobalMaskColor            : TColor32                read FGlobalMaskColor             write FGlobalMaskColor;
    property RedChannelPanel            : TgmChannelPanel         read FRedChannelPanel;
    property GreenChannelPanel          : TgmChannelPanel         read FGreenChannelPanel;
    property BlueChannelPanel           : TgmChannelPanel         read FBlueChannelPanel;
    property QuickMaskPanel             : TgmQuickMaskPanel       read FQuickMaskPanel;
    property QuickMaskColor             : TColor32                read FQuickMaskColor              write SetQuickMaskColor;
    property QuickMaskOpacityPercent    : Single                  read FQuickMaskOpacityPercent     write SetQuickMaskOpacityPercent;
    property QuickMaskColorIndicator    : TgmMaskColorIndicator   read FQuickMaskColorIndicator     write SetQuickMaskColorIndicator;
    property LayerMaskPanel             : TgmLayerMaskPanel       read FLayerMaskPanel;
    property LayerMaskColor             : TColor32                read FLayerMaskColor              write FLayerMaskColor;
    property LayerMaskOpacityPercent    : Single                  read FLayerMaskOpacityPercent     write FLayerMaskOpacityPercent;
    property OnColorModeChanged         : TgmColorModeChangedFunc read FOnColorModeChanged          write FOnColorModeChanged;
    property OnAlphaChannelPanelDblClick: TNotifyEvent            read FOnAlphaChannelPanelDblClick write FOnAlphaChannelPanelDblClick;
    property OnQuickMaskPanelDblClick   : TNotifyEvent            read FOnQuickMaskPanelDblClick    write FOnQuickMaskPanelDblClick;
    property OnLayerMaskPanelDblClick   : TNotifyEvent            read FOnLayerMaskPanelDblClick    write FOnLayerMaskPanelDblClick;
    property OnChannelPanelRightClick   : TNotifyEvent            read FOnChannelPanelRightClick    write FOnChannelPanelRightClick;
    property OnQuickMaskPanelRightClick : TNotifyEvent            read FOnQuickMaskPanelRightClick  write FOnQuickMaskPanelRightClick;
    property OnLayerMaskPanelRightClick : TNotifyEvent            read FOnLayerMaskPanelRightClick  write FOnLayerMaskPanelRightClick;
    property OnChannelChanged           : TgmChannelChangeEvent   read FOnChannelChanged            write FOnChannelChanged;
  end;

const
  MAX_ALPHA_CHANNEL_COUNT: Integer = 10;
  HIDE_CHANNEL           : Boolean = True;
  DONT_HIDE_CHANNEL      : Boolean = False;

implementation

uses
{ Standard }
  Math,
{ Graphics32 }
  GR32_OrdinalMaps,
  GR32_LowLevel,
{ externals }
  LineLibrary,
{ GraphicsMagic Package Lib }
  gmGradient_rwVer1,      // used to save gradient data to disk
{ GraphicsMagic Lib }
  CommonDataModule,
  gmConstants,
  gmMath,
  gmImageProcessFuncs,
  gmPaintFuncs,           // DrawCheckerboardPattern()
  gmColorSpace,           // RGBToHLS32, HLSToRGB32
  gmAlphaFuncs,
  gmGUIFuncs,
  gmCommonFuncs,
  gmLayerReader,
  gmChannelReader;

///////////////////////////// Layer Part Begin /////////////////////////////////

const
  MAIN_PANEL_HEIGHT      : Integer = 41;
  IMAGE_HOLDER_WIDTH     : Integer = 39;
  IMAGE_WIDTH            : Integer = 31;
  IMAGE_HEIGHT           : Integer = 31;
  PANEL_WORK_STAGE_WIDTH : Integer = 24;
  IMAGE_WORK_STAGE_WIDTH : Integer = 16;
  IMAGE_WORK_STAGE_HEIGHT: Integer = 16;
  CHAIN_PANEL_WIDTH      : Integer = 13;

  LAYER_NAME_BACKGROUND      = 'Background';
  LAYER_NAME_TRANSPARENT     = 'Layer ';
  LAYER_NAME_SOLID_COLOR     = 'Color Fill ';
  LAYER_NAME_GIMP_CURVES     = 'Curves ';
  LAYER_NAME_GIMP_LEVELS     = 'Levels ';
  LAYER_NAME_COLOR_BALANCE   = 'Color Balance ';
  LAYER_NAME_BRIGHT_CONTRAST = 'Brightness/Contrast ';
  LAYER_NAME_HLS_HSV         = 'Hue/Saturation ';
  LAYER_NAME_INVERT          = 'Invert ';
  LAYER_NAME_THRESHOLD       = 'Threshold ';
  LAYER_NAME_POSTERIZE       = 'Posterize ';
  LAYER_NAME_PATTERN         = 'Pattern Fill ';
  LAYER_NAME_FIGURE          = 'Figure ';
  LAYER_NAME_CHANNEL_MIXER   = 'Channel Mixer ';
  LAYER_NAME_GRADIENT_MAP    = 'Gradient Map ';
  LAYER_NAME_GRADIENT_FILL   = 'Gradient Fill ';
  LAYER_NAME_SHAPE_REGION    = 'Shape Region ';

  LAYER_PANEL_COLOR_WITH_ALPHA_CHANNEL_SELECTED = $DFDFDF;

  CURRENT_LAYER_HEADER_VER = 1;  

//-- Private procedures and functions ------------------------------------------

function LayerBrightness(const AColor: TColor32;
  const AAmount: Integer): TColor32;
var
  r, g, b: Byte;
begin
  r      := AColor shr 16 and $FF;
  g      := AColor shr  8 and $FF;
  b      := AColor        and $FF;
  r      := Clamp(r + AAmount, 0, 255);
  g      := Clamp(g + AAmount, 0, 255);
  b      := Clamp(b + AAmount, 0, 255);
  Result := $FF000000 or (r shl 16) or (g shl 8) or b;
end;

function LayerContrast(const AColor: TColor32;
  const AAmount: Integer): TColor32;
var
  ir, ig, ib: Integer;
  r, g, b   : Byte;
begin
  r  := AColor shr 16 and $FF;
  g  := AColor shr  8 and $FF;
  b  := AColor        and $FF;

  ir := ( Abs(127 - r) * AAmount ) div 255;
  ig := ( Abs(127 - g) * AAmount ) div 255;
  ib := ( Abs(127 - b) * AAmount ) div 255;

  if r > 127 then
  begin
    r := Clamp(r + ir, 0, 255);
  end
  else
  begin
    r := Clamp(r - ir, 0, 255);
  end;

  if g > 127 then
  begin
    g := Clamp(g + ig, 0, 255);
  end
  else
  begin
    g := Clamp(g - ig, 0, 255);
  end;

  if b > 127 then
  begin
    b := Clamp(b + ib, 0, 255);
  end
  else
  begin
    b := Clamp(b - ib, 0, 255);
  end;

  Result := $FF000000 or (r shl 16) or (g shl 8) or b;
end; 

function LayerHLS(const AColor: TColor32;
  const AHueAmount, ALightnessAmount, ASaturationAmount: Integer): TColor32;
var
  A      : Cardinal;
  H, L, S: Integer;
begin
  A := AColor shr 24 and $FF;
  RGBToHLS32(AColor, H, L, S);
  
  H      := Clamp(H + AHueAmount, 0, 360);
  L      := Clamp(L + ALightnessAmount, 0, 255);
  S      := Clamp(S + ASaturationAmount, 1, 255);
  Result := HLSToRGB32(A, H, L, S);
end; 

function LayerHSV(const AColor: TColor32;
  const AHueAmount, ASaturationAmount, AValueAmount: Integer): TColor32;
var
  a      : Cardinal;
  h, s, v: Integer;
begin
  a := AColor shr 24 and $FF;
  RGBToHSV32(AColor, h, s, v);
  
  h      := Clamp(h + AHueAmount, 0, 360);
  s      := Clamp(s + ASaturationAmount, 0, 255);
  v      := Clamp(v + AValueAmount, 0, 255);
  Result := HSVToRGB32(a, h, s, v);
end; 

//-- TgmLayerPanel -------------------------------------------------------------

constructor TgmLayerPanel.Create(const AOwner: TWinControl;
  const ALayer: TBitmapLayer);
var
  LTempBmp : TBitmap32;
begin
  inherited Create;

  FPanelList            := nil;
  FSelected             := True;
  FLayerVisible         := True;
  FDuplicated           := False;
  FMerged               := False;
  FBlendModeIndex       := 0;
  FBlendModeEvent       := BlendMode.NormalBlend;
  FLayerProcessStage    := lpsLayer;
  FPrevProcessStage     := lpsLayer; // remember the last process stage of a layer (on layer or on mask)
  FHasMask              := False;    // indicate whether this layer has a mask
  FMaskLinked           := False;    // indicate whether this layer is connected to a mask
  FLockTransparency     := False;
  FRenamed              := False;
  FHoldMaskInLayerAlpha := False;
  FLayerFeature         := lfNone;
  FLayerMasterAlpha     := 255;

  FOnLayerThumbnailDblClick := nil;

  // create a layer panel
  FPanel := TPanel.Create(AOwner);
  with FPanel do
  begin
    Parent     := AOwner;
    Align      := alTop;
    AutoSize   := False;
    Height     := MAIN_PANEL_HEIGHT;
    BevelInner := bvLowered;
    BevelOuter := bvRaised;
    BevelWidth := 1;
    Cursor     := crHandPoint;
    Color      := clBackground;
    ShowHint   := False;
    Visible    := False;
  end;

  // create a panel for holding FLayerImage
  FLayerImageHolder := TPanel.Create(FPanel);
  with FLayerImageHolder do
  begin
    Parent     := FPanel;
    Align      := alLeft;
    AutoSize   := False;
    Width      := IMAGE_HOLDER_WIDTH;
    Height     := FPanel.Height - 2;
    BevelInner := bvRaised;
    BevelOuter := bvLowered;
    BevelWidth := 1;
    Cursor     := crHandPoint;
    Visible    := True;
  end;

  // create a TImage32 for displaying the thumbnail of the layer
  FLayerImage := TImage32.Create(FLayerImageHolder);
  with FLayerImage do
  begin
    Parent          := FLayerImageHolder;
    Width           := FLayerImageHolder.Width  - 2;
    Height          := FLayerImageHolder.Height - 2;
    Bitmap.DrawMode := dmBlend;
    BitmapAlign     := baCenter;
    AutoSize        := False;
    ScaleMode       := smScale;
    Cursor          := crHandPoint;
    Hint            := 'Layer thumbnail';
    ShowHint        := True;
    Left            := 1;
    Top             := 1;
    Visible         := True;

    { Force TImage32 to call the OnPaintStage event instead of performming
      default action. }
    if PaintStages[0]^.Stage = PST_CLEAR_BACKGND then
    begin
      PaintStages[0]^.Stage := PST_CUSTOM;
    end;

    OnPaintStage := ImagePaintStage;
  end;

  // create a panel for holding FMaskImage
  FMaskImageHolder := TPanel.Create(FPanel);
  with FMaskImageHolder do
  begin
    Parent     := FPanel;
    Align      := alLeft;
    AutoSize   := False;
    Width      := IMAGE_HOLDER_WIDTH;
    BevelInner := bvRaised;
    BevelOuter := bvLowered;
    BevelWidth := 1;
    Cursor     := crHandPoint;
    Visible    := False;
  end;

  // create FMaskImage
  FMaskImage := TImage32.Create(FMaskImageHolder);
  with FMaskImage do
  begin
    Parent          := FMaskImageHolder;
    Width           := FMaskImageHolder.Width  - 2;
    Height          := FMaskImageHolder.Height - 2;
    AutoSize        := False;
    ScaleMode       := smScale;
    BitmapAlign     := baCenter;
    Bitmap.DrawMode := dmOpaque;
    Scale           := 1;
    Cursor          := crHandPoint;
    Hint            := 'Layer mask thumbnail';
    ShowHint        := True;
    Visible         := True;

    Bitmap.SetSize(ALayer.Bitmap.Width, ALayer.Bitmap.Height);
    Bitmap.Clear(clWhite32);

    { Force TImage32 to call the OnPaintStage event instead of performming
      default action. }
    if PaintStages[0]^.Stage = PST_CLEAR_BACKGND then
    begin
      PaintStages[0]^.Stage := PST_CUSTOM;
    end;

    OnPaintStage := MaskPaintStage;
  end;

  { Create a panel to hold a TImage for displaying a image to indicate whether
    we are processing a layer or a mask. }
  FWorkStageImageHolder := TPanel.Create(FPanel);
  with FWorkStageImageHolder do
  begin
    Parent     := FPanel;
    Align      := alLeft;
    AutoSize   := False;
    Width      := PANEL_WORK_STAGE_WIDTH;
    BevelInner := bvRaised;
    BevelOuter := bvLowered;
    BevelWidth := 1;
    Left       := 0;
    Top        := 0;
    Visible    := True;
  end;

  // create a TImage for displaying the stage state
  FWorkStageImage := TImage.Create(FWorkStageImageHolder);
  with FWorkStageImage do
  begin
    Parent   := FWorkStageImageHolder;
    AutoSize := False;
    Stretch  := True;
    Width    := IMAGE_WORK_STAGE_WIDTH;
    Height   := IMAGE_WORK_STAGE_HEIGHT;
    Top      := (FWorkStageImageHolder.Height - FWorkStageImage.Height) div 2;
    Left     := (FWorkStageImageHolder.Width  - FWorkStageImage.Width)  div 2;

    GMDataModule := TGMDataModule.Create(nil);
    try
      // indicating the process stage is on layer
      Picture.Bitmap.Assign(GMDataModule.bmp32lstLayers.Bitmap[0]);
    finally
      FreeAndNil(GMDataModule)
    end;
    
    Visible := True;
  end;
  
  // create a panel to hold a TImage to indicate whether the layer is visible
  FEyeImageHolder := TPanel.Create(FPanel);
  with FEyeImageHolder do
  begin
    Parent     := FPanel;
    Align      := alLeft;
    AutoSize   := False;
    Cursor     := crHandPoint;
    Width      := PANEL_WORK_STAGE_WIDTH;
    BevelInner := bvRaised;
    BevelOuter := bvLowered;
    BevelWidth := 1;
    Visible    := True;
  end;

  // create a TImage to show an eye icon in it for indicating whether this layer is visible
  FEyeImage := TImage.Create(FEyeImageHolder);
  with FEyeImage do
  begin
    Parent   := FEyeImageHolder;
    AutoSize := False;
    Stretch  := True;
    Cursor   := crHandPoint;
    Width    := IMAGE_WORK_STAGE_WIDTH;
    Height   := IMAGE_WORK_STAGE_HEIGHT;
    Top      := (FEyeImageHolder.Height - Height) div 2;
    Left     := (FEyeImageHolder.Width  - Width)  div 2;

    GMDataModule := TGMDataModule.Create(nil);
    try
      // indicating the layer is visible
      Picture.Bitmap.Assign(GMDataModule.bmp32lstLayers.Bitmap[11]);
    finally
      FreeAndNil(GMDataModule)
    end;
    
    Visible := True;
  end;

  { create a panel to hold a TImage32 to show an image that indicate
    whether the layer is connected to a layer }
  FChainImageHolder := TPanel.Create(FPanel);
  with FChainImageHolder do
  begin
    Parent     := FPanel;
    Align      := alLeft;
    AutoSize   := False;
    Cursor     := crHandPoint;
    Width      := CHAIN_PANEL_WIDTH;
    BevelInner := bvRaised;
    BevelOuter := bvLowered;
    BevelWidth := 1;
    Visible    := False;
  end;

  // create a TImage32 for indicating whether the layer is connected to a mask
  FChainImage := TImage32.Create(FChainImageHolder);
  with FChainImage do
  begin
    Parent                := FChainImageHolder;
    Align                 := alClient;
    BitmapAlign           := baCenter;
    Bitmap.DrawMode       := dmBlend;
    PaintStages[0]^.Stage := PST_CUSTOM;
    OnPaintStage          := ChainImagePaintStage;
    AutoSize              := False;
    ScaleMode             := smNormal;
    Cursor                := crHandPoint;
    Visible               := True;

    LTempBmp := TBitmap32.Create;
    try
      GMDataModule := TGMDataModule.Create(nil);
      try
        LTempBmp.Assign(GMDataModule.bmp32lstLayers.Bitmap[LAYER_MASK_CHAIN_BMP_INDEX]);
      finally
        FreeAndNil(GMDataModule)
      end;
      
      Bitmap.SetSize(LTempBmp.Width, LTempBmp.Height);
      Bitmap.Clear(clBlack32);
      ReplaceAlphaChannelWithMask(Bitmap, LTempBmp);
    finally
      LTempBmp.Free;
    end;
  end;

  // create FLayerName label for displaying the name of the layer
  FLayerName := TLabel.Create(FPanel);
  with FLayerName do
  begin
    Parent     := FPanel;
    Align      := alNone;

    Left       := FEyeImageHolder.Width   + FWorkStageImageHolder.Width +
                  FLayerImageHolder.Width + FChainImageHolder.Width     +
                  FMaskImageHolder.Width  + 10;

    Top        := (FPanel.Height - Height) div 2;
    Caption    := '';
    Font.Color := clWhite;
    Cursor     := crHandPoint;
    ShowHint   := True;
    Visible    := True;
  end;

  { Remember processed part of current layer by canvas, in order to
    restore the opacity of the processed pixel. The idea is as follows:

    Make the dimension of FProcessedPart same as the layer and then fill it with
    black. When the layer is processing with canvas, draw the pixels at the same
    positions on FProcessedPart to white, and call a method to get coordinates of
    white pixels on FProcessedPart, and make pixels at the corresponding coordinates
    on the layer to opaque. }
    
  FProcessedPart := TBitmap32.Create;
  FProcessedPart.SetSize(ALayer.Bitmap.Width, ALayer.Bitmap.Height);
  FProcessedPart.Clear(clBlack32);

  // remember the last state of the layer
  FLastProcessed          := TBitmap32.Create;
  FLastProcessed.DrawMode := dmBlend;
  FLastProcessed.Assign(ALayer.Bitmap);

  // remember the alpha channels of the layer
  FLastAlphaChannelBmp := TBitmap32.Create;
  GetAlphaChannelBitmap(ALayer.Bitmap, FLastAlphaChannelBmp);

  // associate the panel to a layer, the following routines are necessary
  FAssociatedLayer                 := ALayer;
  FAssociatedLayer.Bitmap.DrawMode := dmCustom;

  // connect events
  FLayerImage.OnDblClick := LayerThumbnailDblClick;
end;

destructor TgmLayerPanel.Destroy;
begin
  // free the component with reverse order of the creating
  FLayerImage.Free;
  FLayerImageHolder.Free;
  FMaskImage.Free;
  FMaskImageHolder.Free;
  FWorkStageImage.Free;
  FWorkStageImageHolder.Free;
  FLayerName.Free;
  FChainImage.Free;
  FChainImageHolder.Free;
  FPanel.Free;
  FProcessedPart.Free;
  FLastProcessed.Free;
  FLastAlphaChannelBmp.Free;

  FPanelList                := nil;
  FAssociatedLayer          := nil;
  FOnLayerThumbnailDblClick := nil;
  
  inherited Destroy;
end;

procedure TgmLayerPanel.SetLayerVisible(const AValue: Boolean);
begin
  if FLayerVisible <> AValue then
  begin
    FLayerVisible := AValue;

    if Assigned(FAssociatedLayer) then
    begin
      FAssociatedLayer.Visible := FLayerVisible;
    end;

    if FLayerVisible then
    begin
      GMDataModule := TGMDataModule.Create(nil);
      try
        FEyeImage.Picture.Bitmap.Assign(GMDataModule.bmp32lstLayers.Bitmap[11]);
      finally
        FreeAndNil(GMDataModule)
      end;
    end
    else
    begin
      FEyeImage.Picture.Bitmap := nil;
    end;
  end;
end;

procedure TgmLayerPanel.SetHasMask(const AValue: Boolean);
begin
  FHasMask := AValue;

  if not FHasMask then
  begin
    FMaskLinked         := False;
    FChainImage.Visible := False;
  end;
end;

procedure TgmLayerPanel.SetMaskLinked(const AValue: Boolean);
begin
  FMaskLinked         := AValue;
  FChainImage.Visible := FMaskLinked;
end;

// callbacks
procedure TgmLayerPanel.LayerThumbnailDblClick(ASender: TObject);
begin
  if Assigned(FOnLayerThumbnailDblClick) then
  begin
    FOnLayerThumbnailDblClick(Self);
  end;
end;

procedure TgmLayerPanel.ImagePaintStage(ASender: TObject; ABuffer: TBitmap32;
  AStageNum: Cardinal);
var
  LRect: TRect;
begin
  // draw background
  if (ABuffer.Height > 0) and (ABuffer.Width > 0) then
  begin
    ABuffer.Clear( Color32(ColorToRGB(clBtnFace)) );

    // draw thin border, written by Andre Felix Miertschink
    LRect := FLayerImage.GetBitmapRect;

    DrawCheckerboardPattern(ABuffer, LRect, True);

    if not (FLayerFeature in [lfGradientFill, lfPattern]) then
    begin
      LRect.Left   := LRect.Left   - 1;
      LRect.Top    := LRect.Top    - 1;
      LRect.Right  := LRect.Right  + 1;
      LRect.Bottom := LRect.Bottom + 1;

      ABuffer.FrameRectS(LRect, clBlack32);
    end;
  end;
end;

procedure TgmLayerPanel.MaskPaintStage(ASender: TObject; ABuffer: TBitmap32;
  AStageNum: Cardinal);
var
  LRect: TRect;
begin
  // draw background
  if (ABuffer.Height > 0) and (ABuffer.Width > 0) then
  begin
    ABuffer.Clear( Color32(ColorToRGB(clBtnFace)) );

    // draw thin border, written by Andre Felix Miertschink
    LRect := FMaskImage.GetBitmapRect;

    LRect.Left   := LRect.Left   - 1;
    LRect.Top    := LRect.Top    - 1;
    LRect.Right  := LRect.Right  + 1;
    LRect.Bottom := LRect.Bottom + 1;

    ABuffer.FrameRectS(LRect, clBlack32);
  end;
end;

procedure TgmLayerPanel.ChainImagePaintStage(ASender: TObject; ABuffer: TBitmap32;
  AStageNum: Cardinal);
var
  LFillColor: TColor32;
begin
  LFillColor := Color32( ColorToRGB(clBtnFace) );
  ABuffer.Clear(LFillColor);
end;

procedure TgmLayerPanel.SetLayerMasterAlpha(const AValue: Byte);
begin
  if FLayerVisible then
  begin
    if FLayerMasterAlpha <> AValue then
    begin
      FLayerMasterAlpha                   := AValue;
      FAssociatedLayer.Bitmap.MasterAlpha := AValue;
      FAssociatedLayer.Changed;
    end;
  end;
end;

procedure TgmLayerPanel.SetBlendModeIndex(const AIndex: Integer);
begin
  if FBlendModeIndex <> AIndex then
  begin
    FBlendModeIndex := AIndex;
    FBlendModeEvent := GetBlendMode(FBlendModeIndex);
  end;
end;

procedure TgmLayerPanel.Update;
begin
  if FHasMask and FMaskLinked then
  begin
    if FHoldMaskInLayerAlpha then
    begin
      UpdateLayerAlphaWithMask;
    end
    else
    begin
      ChangeAlphaChannelBySubMask(FAssociatedLayer.Bitmap,
                                  FLastAlphaChannelBmp,
                                  FMaskImage.Bitmap);
    end;
  end;

  FAssociatedLayer.Changed;
end;

// draw Photoshop style thumbnail for solid color layer
procedure TgmLayerPanel.DrawPhotoshopStyleColorThumbnail(const AColor: TColor);
begin
  // drawing this thumbnail with hard-coded
  with FLayerImage.Bitmap do
  begin
    SetSize(IMAGE_WIDTH, IMAGE_HEIGHT);
    FillRect(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT, clWhite32);
    PenColor := clBlack32;
    FillRect( 0, 0, 31, 22, Color32(AColor) );
    HorzLine(0, 22, 31, clBlack32);
    FrameRectS(Canvas.ClipRect, clBlack32);
    HorzLine(4, 25, 26, clBlack32);
    MoveTo(17, 26);
    LineToS(15, 28);
    MoveTo(17, 26);
    LineToS(19, 28);
    HorzLine(15, 28, 19, clBlack32);
  end;
end;

procedure TgmLayerPanel.ResizeMask(const ANewWidth, ANewHeight: Integer;
  const AOptions: TgmResamplingOptions);
begin
  ExecuteResample(FMaskImage.Bitmap, ANewWidth, ANewHeight, AOptions);
  UpdateMaskThumbnail;

  // on special layers, save Mask into layer's alpha channels
  if FHoldMaskInLayerAlpha then
  begin
    UpdateLayerAlphaWithMask;
  end;
end; 

procedure TgmLayerPanel.ResizeEffectLayer(const AImageControl: TCustomImage32;
  const ANewWidth, ANewHeight: Integer; const AOptions: TgmResamplingOptions);
var
  LTopLeft: TPoint;
begin
  if (FAssociatedLayer.Bitmap.Width  <> ANewWidth) or
     (FAssociatedLayer.Bitmap.Height <> ANewHeight) then
  begin
    // change the dimension of the associated layer
    FAssociatedLayer.Bitmap.SetSize(ANewWidth, ANewHeight);
    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);

    ResizeMask(ANewWidth, ANewHeight, AOptions);
  end;
end;

procedure TgmLayerPanel.ChangeMaskCanvasSize(const ANewWidth, ANewHeight: Integer;
  const AAnchor: TgmAnchorDirection);
var
  LCutBitmap: TBitmap32;
begin
  if (FMaskImage.Bitmap.Width  <> ANewWidth) or
     (FMaskImage.Bitmap.Height <> ANewHeight) then
  begin
    LCutBitmap := TBitmap32.Create;
    try
      CutBitmap32ByAnchorDirection(FMaskImage.Bitmap, LCutBitmap,
                                   ANewWidth, ANewHeight, AAnchor, clWhite32);

      FMaskImage.Bitmap.SetSize(ANewWidth, ANewHeight);
      FMaskImage.Bitmap.Clear(clWhite32);
      DrawBitmap32ByAnchorDirection(LCutBitmap, FMaskImage.Bitmap, AAnchor);
      UpdateMaskThumbnail;

      // on special layers, save Mask into layer's alpha channels
      if FHoldMaskInLayerAlpha then
      begin
        UpdateLayerAlphaWithMask;
      end;
    finally
      LCutBitmap.Free;
    end;
  end;
end;

procedure TgmLayerPanel.ChangeEffectLayerCanvasSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AAnchor: TgmAnchorDirection);
var
  LTopLeft: TPoint;
begin
  if (FAssociatedLayer.Bitmap.Width  <> ANewWidth) or
     (FAssociatedLayer.Bitmap.Height <> ANewHeight) then
  begin
    FAssociatedLayer.Bitmap.SetSize(ANewWidth, ANewHeight);
    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);
    
    ChangeMaskCanvasSize(ANewWidth, ANewHeight, AAnchor);
  end;
end;

procedure TgmLayerPanel.RotateMaskCanvas(const ADeg: Integer;
  const ADirection: TgmRotateDirection);
var
  LSourceBitmap: TBitmap32;
begin
  LSourceBitmap := TBitmap32.Create;
  try
    LSourceBitmap.Assign(FMaskImage.Bitmap);
    RotateBitmap32(LSourceBitmap, FMaskImage.Bitmap, ADirection, ADeg, 0, clWhite32);
    UpdateMaskThumbnail;

    // on special layers, save Mask into layer's alpha channels
    if Self.FHoldMaskInLayerAlpha then
    begin
      UpdateLayerAlphaWithMask;
    end;
  finally
    LSourceBitmap.Free;
  end;
end; 

procedure TgmLayerPanel.RotateEffectLayerCanvas(
  const AImageControl: TCustomImage32; const ADeg: Integer;
  const ADirection: TgmRotateDirection; const AResizeBackground: Boolean);
var
  LSrcBmp              : TBitmap32;
  LTopLeft             : TPoint;
  LNewWidth, LNewHeight: Integer;
begin
  LSrcBmp := TBitmap32.Create;
  try
    LSrcBmp.SetSize(FAssociatedLayer.Bitmap.Width, FAssociatedLayer.Bitmap.Height);
    RotateBitmap32(LSrcBmp, FAssociatedLayer.Bitmap, ADirection, ADeg, 0, clBlack32);

    LNewWidth  := FAssociatedLayer.Bitmap.Width;
    LNewHeight := FAssociatedLayer.Bitmap.Height;

    if AResizeBackground then
    begin
      AImageControl.Bitmap.SetSize(LNewWidth, LNewHeight);
    end;

    // retrieve the top left position of a layer
    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);

    RotateMaskCanvas(ADeg, ADirection);
  finally
    LSrcBmp.Free;
  end;
end; 

procedure TgmLayerPanel.CropMask(const ACrop: TgmCrop);
var
  LCropRect  : TRect;
  LCropBitmap: TBitmap32;
begin
  LCropBitmap := TBitmap32.Create;
  try
    LCropBitmap.DrawMode := dmOpaque;

    LCropRect := Rect(ACrop.FCropStart.X, ACrop.FCropStart.Y,
                      ACrop.FCropEnd.X, ACrop.FCropEnd.Y);

    CopyRect32WithARGB(LCropBitmap, FMaskImage.Bitmap, LCropRect, clWhite32);

    if ACrop.IsResized then
    begin
      if (LCropBitmap.Width  <> ACrop.ResizeW) or
         (LCropBitmap.Height <> ACrop.ResizeH) then
      begin
        SmoothResize32(LCropBitmap, ACrop.ResizeW, ACrop.ResizeH);
      end;
    end;

    FMaskImage.Bitmap.Assign(LCropBitmap);
    UpdateMaskThumbnail;

    // on special layers, save Mask into layer's alpha channels
    if FHoldMaskInLayerAlpha then
    begin
      UpdateLayerAlphaWithMask;
    end;
  finally
    LCropBitmap.Free;
  end;
end; 

procedure TgmLayerPanel.CropMask(const ACropArea: TRect);
var
  LCropBitmap: TBitmap32;
begin
  if (ACropArea.Left   <  0) or
     (ACropArea.Top    <  0) or
     (ACropArea.Right  >  FMaskImage.Bitmap.Width) or
     (ACropArea.Bottom >  FMaskImage.Bitmap.Height) or
     (ACropArea.Right  <= ACropArea.Left) or
     (ACropArea.Bottom <= ACropArea.Top) then
  begin
    Exit;
  end;

  LCropBitmap := TBitmap32.Create;
  try
    LCropBitmap.DrawMode := dmOpaque;

    if (FLastAlphaChannelBmp.Width  = FMaskImage.Bitmap.Width) and
       (FLastAlphaChannelBmp.Height = FMaskImage.Bitmap.Height) then
    begin
      CopyRect32WithARGB(LCropBitmap, FLastAlphaChannelBmp, ACropArea, clWhite32);
      FLastAlphaChannelBmp.Assign(LCropBitmap);
    end;

    CopyRect32WithARGB(LCropBitmap, FMaskImage.Bitmap, ACropArea, clWhite32);

    FMaskImage.Bitmap.Assign(LCropBitmap);
    UpdateMaskThumbnail;

    // on special layers, save Mask into layer's alpha channels
    if FHoldMaskInLayerAlpha then
    begin
      UpdateLayerAlphaWithMask;
    end;
  finally
    LCropBitmap.Free;
  end;
end; 

procedure TgmLayerPanel.CropEffectLayer(const AImageControl: TCustomImage32;
  const ACrop: TgmCrop);
var
  LNewWidth, LNewHeight: Integer;
  LTopLeft             : TPoint;
begin
  if ACrop.IsResized then
  begin
    LNewWidth  := ACrop.ResizeW;
    LNewHeight := ACrop.ResizeH;
  end
  else
  begin
    LNewWidth  := ACrop.FCropEnd.X - ACrop.FCropStart.X;
    LNewHeight := ACrop.FCropEnd.Y - ACrop.FCropStart.Y;
  end;

  FAssociatedLayer.Bitmap.SetSize(LNewWidth, LNewHeight);
  FAssociatedLayer.Bitmap.Clear(clBlack32);

  // retrieve the top left position of a layer
  LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

  FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                         AImageControl.Bitmap.Width,
                                         AImageControl.Bitmap.Height);

  CropMask(ACrop);
end;

procedure TgmLayerPanel.SetLayerName(const AName: string);
begin
  FLayerName.Caption := AName;
  FLayerName.Hint    := AName;
end;

procedure TgmLayerPanel.UpdateLayerThumbnail;
var
  i, w, h: Integer;
  p1, p2 : PColor32;
  ws, hs : Single;
begin
  if FLayerFeature in [lfBackground, lfTransparent, lfFigure] then
  begin
    FLayerImage.Bitmap.SetSize(FAssociatedLayer.Bitmap.Width,
                               FAssociatedLayer.Bitmap.Height);

    p1 := @FAssociatedLayer.Bitmap.Bits[0];
    p2 := @FLayerImage.Bitmap.Bits[0];

    for i := 0 to FAssociatedLayer.Bitmap.Width * FAssociatedLayer.Bitmap.Height - 1 do
    begin
      p2^ := p1^;
      Inc(p1);
      Inc(p2);
    end;

    if FLayerImage.Bitmap.DrawMode <> dmBlend then
    begin
      FLayerImage.Bitmap.DrawMode := dmBlend;
    end;

    // scale and center thumbnail

    w := FLayerImage.Width  - 6;
    h := FLayerImage.Height - 6;

    if (FAssociatedLayer.Bitmap.Width  > w) or
       (FAssociatedLayer.Bitmap.Height > h) then
    begin
      ws := w / FAssociatedLayer.Bitmap.Width;
      hs := h / FAssociatedLayer.Bitmap.Height;

      if ws < hs then
      begin
        FLayerImage.Scale := ws;
      end
      else
      begin
        FLayerImage.Scale := hs;
      end;
    end
    else
    begin
      FLayerImage.Scale := 1;
    end;

    FLayerImage.Bitmap.Changed;
  end;
end;

procedure TgmLayerPanel.UpdateMaskThumbnail;
var
  w, h  : Integer;
  ws, hs: Single;
begin
  if FMaskImage.Bitmap.DrawMode <> dmOpaque then
  begin
    FMaskImage.Bitmap.DrawMode := dmOpaque
  end;

  // scale and center thumbnail

  w := FMaskImage.Width  - 6;
  h := FMaskImage.Height - 6;

  if (FMaskImage.Bitmap.Width  > w) or
     (FMaskImage.Bitmap.Height > h) then
  begin
    ws := w / FMaskImage.Bitmap.Width;
    hs := h / FMaskImage.Bitmap.Height;

    if ws < hs then
    begin
      FMaskImage.Scale := ws;
    end
    else
    begin
      FMaskImage.Scale := hs;
    end;
  end
  else
  begin
    FMaskImage.Scale := 1;
  end;

  FMaskImage.Bitmap.Changed;
end; 

procedure TgmLayerPanel.UpdateLayerPanelState;
begin
  case FSelected of
    True:
      begin
        if Assigned(FPanelList) and
           Assigned(FPanelList.FAssociatedChannelManager) then
        begin
          if (csRed   in FPanelList.FAssociatedChannelManager.ChannelSelectedSet) or
             (csGreen in FPanelList.FAssociatedChannelManager.ChannelSelectedSet) or
             (csBlue  in FPanelList.FAssociatedChannelManager.ChannelSelectedSet) or
             (FPanelList.FAssociatedChannelManager.CurrentChannelType = wctLayerMask) then
          begin
            FPanel.BevelInner     := bvLowered;
            FPanel.Color          := clBackground;
            FLayerName.Font.Color := clWhite;
          end
          else
          begin
            FPanel.BevelInner     := bvRaised;
            FPanel.Color          := LAYER_PANEL_COLOR_WITH_ALPHA_CHANNEL_SELECTED;
            FLayerName.Font.Color := clBlack;
          end;
        end;

        if not FWorkStageImage.Visible then
        begin
          FWorkStageImage.Visible := True;
        end;
      end;

    False:
      begin
        FPanel.BevelInner     := bvRaised;
        FPanel.Color          := clBtnFace;
        FLayerName.Font.Color := clBlack;

        if FWorkStageImage.Visible then
        begin
          FWorkStageImage.Visible := False;
        end;
      end;
  end;

  if Assigned(FPanelList) and
     Assigned(FPanelList.FAssociatedChannelManager) then
  begin
    // show/hide the work stage icon
    case FPanelList.FAssociatedChannelManager.CurrentChannelType of
      wctAlpha, wctQuickMask:
        begin
          FWorkStageImage.Picture.Bitmap := nil;
        end;

      wctLayerMask:
        begin
          FWorkStageImage.Picture.Bitmap := nil;

          GMDataModule := TGMDataModule.Create(nil);
          try
            // indicate the process stage is mask
            FWorkStageImage.Picture.Bitmap.Assign(GMDataModule.bmp32lstLayers.Bitmap[1]);
          finally
            FreeAndNil(GMDataModule)
          end;
        end;

      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          FWorkStageImage.Picture.Bitmap := nil;

          GMDataModule := TGMDataModule.Create(nil);
          try
            // indicate the process stage is layer
            FWorkStageImage.Picture.Bitmap.Assign(GMDataModule.bmp32lstLayers.Bitmap[0]);
          finally
            FreeAndNil(GMDataModule)
          end;
        end;
    end;
  end;
end;

procedure TgmLayerPanel.ShowThumbnailByRightOrder;
begin
  FEyeImageHolder.Left          := 1;
  FWorkStageImageHolder.Left    := FEyeImageHolder.Left       + FEyeImageHolder.Width;
  FLayerImageHolder.Left        := FWorkStageImageHolder.Left + FWorkStageImageHolder.Width;
  FChainImageHolder.Left        := FLayerImageHolder.Left     + FLayerImageHolder.Width;
  FMaskImageHolder.Left         := FChainImageHolder.Left     + FChainImageHolder.Width;
  FEyeImageHolder.Visible       := True;
  FWorkStageImageHolder.Visible := True;
  FLayerImageHolder.Visible     := True;
  FChainImageHolder.Visible     := FHasMask;
  FMaskImageHolder.Visible      := FHasMask;
end; 

// create and connect to a mask
procedure TgmLayerPanel.AddMask;
begin
  GetAlphaChannelBitmap(FAssociatedLayer.Bitmap, FLastAlphaChannelBmp);
  FMaskImage.Bitmap.Clear(clWhite32);
  UpdateMaskThumbnail;
  
  LayerProcessStage := lpsMask;
  PrevProcessStage  := lpsMask;
  FHasMask          := True;
  IsMaskLinked      := True;

  // save mask info into alpha channels of special layers
  UpdateLayerAlphaWithMask;

  if Assigned(FPanelList) and
     Assigned(FPanelList.FAssociatedChannelManager) and
     Assigned(FPanelList.FAssociatedLayerCollection) then
  begin
    FPanelList.FAssociatedChannelManager.CreateLayerMaskPanel(
      FPanelList.FAssociatedChannelManager.FChannelPanelOwner,
      FPanelList.FAssociatedLayerCollection, FPanelList);

    FPanelList.FAssociatedChannelManager.SelectLayerMask;
  end;
end; 

procedure TgmLayerPanel.UpdateLayerAlphaWithMask;
begin
  if FHasMask then
  begin
    // save mask in the alpha channels of special layers
    if FHoldMaskInLayerAlpha then
    begin
      ReplaceAlphaChannelWithMask(FAssociatedLayer.Bitmap, FMaskImage.Bitmap);
    end;
  end;
end; 

procedure TgmLayerPanel.UpdateLayerAlphaWithMask(const ARect: TRect);
begin
  if FHasMask then
  begin
    // save mask in the alpha channels of special layers
    if Self.FHoldMaskInLayerAlpha then
    begin
      ReplaceAlphaChannelWithMask(FAssociatedLayer.Bitmap, FMaskImage.Bitmap, ARect);
    end;
  end;
end; 

procedure TgmLayerPanel.AssociateLayerToPanel(
  const ALayerCollection: TLayerCollection; const AIndex: Integer);
begin
  if (AIndex >= 0) and (AIndex <= ALayerCollection.Count - 1) then
  begin
    FAssociatedLayer := TBitmapLayer(ALayerCollection.Items[AIndex]);
  end;
end; 

procedure TgmLayerPanel.SynchronizeProcessStage;
begin
  FPrevProcessStage := FLayerProcessStage;
end; 

{ Determine whether the layer is an empty layer by checking
  if the FLastAlphaChannel is full black.

  True  = full black (Empty);
  False = not full black (Non-empty) }
function TgmLayerPanel.IsEmptyLayer: Boolean;
var
  i: Integer;
  a: Byte;
  p: PColor32;
begin
  Result := True;
  p      := @FLayerImage.Bitmap.Bits[0];

  for i := 0 to FLayerImage.Bitmap.Width * FLayerImage.Bitmap.Height - 1 do
  begin
    a := p^ shr 24 and $FF;

    if a > 0 then
    begin
      Result := False;
      Break;
    end;

    Inc(p);
  end;
end;

function TgmLayerPanel.PointOnLayerPanel(const ASender: TObject): Boolean;
begin
  Result := ( (ASender = FPanel) or
              (ASender = FLayerName) or
              (ASender = FLayerImage) or
              (ASender = FLayerImageHolder) or
              (ASender = FMaskImage) or
              (ASender = FMaskImageHolder) );
end;

function TgmLayerPanel.PointOnChainImage(const ASender: TObject): Boolean;
begin
  Result := ((ASender = FChainImage) or (ASender = FChainImageHolder));
end; 

//-- TgmBackgroundLayerPanel ---------------------------------------------------

constructor TgmBackgroundLayerPanel.Create(const AOwner: TWinControl;
  const ALayer: TBitmapLayer);
begin
  inherited Create(AOwner, ALayer);

  FLayerFeature := lfBackground;

  if FAssociatedLayer <> nil then
  begin
    FAssociatedLayer.Bitmap.OnPixelCombine := LayerPixelBlend;
  end;

  UpdateLayerThumbnail;
end;

procedure TgmBackgroundLayerPanel.LayerPixelBlend(F: TColor32;
  var B: TColor32; M: TColor32);
begin
  FBlendModeEvent(F, B, M);
end; 

procedure TgmBackgroundLayerPanel.ChangeImageSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AOptions: TgmResamplingOptions);
var
  LTopLeft: TPoint;
begin
  if (FAssociatedLayer.Bitmap.Width  <> ANewWidth) or
     (FAssociatedLayer.Bitmap.Height <> ANewHeight) then
  begin
    // change the dimension of the associated layer

    ExecuteResample(FAssociatedLayer.Bitmap, ANewWidth, ANewHeight, AOptions);
    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);

    // process layer thumbnail
    UpdateLayerThumbnail;

    // process mask thumbnail
    ResizeMask(ANewWidth, ANewHeight, AOptions);
    
    // process last alpha channel bitmap
    SmoothResize32(FLastAlphaChannelBmp, ANewWidth, ANewHeight);
  end;
end;

procedure TgmBackgroundLayerPanel.ChangeCanvasSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AAnchor: TgmAnchorDirection; const ABackgroundColor: TColor32);
var
  LTopLeft  : TPoint;
  LCutBitmap: TBitmap32;
begin
  if (FAssociatedLayer.Bitmap.Width  <> ANewWidth) or
     (FAssociatedLayer.Bitmap.Height <> ANewHeight) then
  begin
    LCutBitmap := TBitmap32.Create;
    try
      LCutBitmap.DrawMode := dmBlend;

      CutBitmap32ByAnchorDirection(FAssociatedLayer.Bitmap, LCutBitmap,
                                   ANewWidth, ANewHeight, AAnchor,
                                   ABackgroundColor);

      FAssociatedLayer.Bitmap.SetSize(ANewWidth, ANewHeight);
      FAssociatedLayer.Bitmap.Clear(ABackgroundColor);
      DrawBitmap32ByAnchorDirection(LCutBitmap, FAssociatedLayer.Bitmap, AAnchor);

      LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

      FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                             AImageControl.Bitmap.Width,
                                             AImageControl.Bitmap.Height);
      // process layer thumbnail
      UpdateLayerThumbnail;

      // process mask thumbnail
      ChangeMaskCanvasSize(ANewWidth, ANewHeight, AAnchor);

      // process last alpha channel bitmap
      LCutBitmap.DrawMode := dmOpaque;

      CutBitmap32ByAnchorDirection(FLastAlphaChannelBmp, LCutBitmap,
                                   ANewWidth, ANewHeight, AAnchor, clBlack32);

      FLastAlphaChannelBmp.SetSize(ANewWidth, ANewHeight);
      FLastAlphaChannelBmp.Clear(clBlack32);
      DrawBitmap32ByAnchorDirection(LCutBitmap, FLastAlphaChannelBmp, AAnchor);
    finally
      LCutBitmap.Free;
    end;
  end;
end;

procedure TgmBackgroundLayerPanel.RotateCanvas(
  const AImageControl: TCustomImage32; const ADeg: Integer;
  const ADirection: TgmRotateDirection; const AResizeBackground: Boolean;
  const ABackColor: TColor32);
var
  LSourceBitmap        : TBitmap32;
  LTopLeft             : TPoint;
  LNewWidth, LNewHeight: Integer;
begin
  LSourceBitmap := TBitmap32.Create;
  try
    LSourceBitmap.Assign(FAssociatedLayer.Bitmap);

    RotateBitmap32(LSourceBitmap, FAssociatedLayer.Bitmap, ADirection, ADeg, 0,
                   ABackColor);

    LNewWidth  := FAssociatedLayer.Bitmap.Width;
    LNewHeight := FAssociatedLayer.Bitmap.Height;

    if AResizeBackground then
    begin
      AImageControl.Bitmap.SetSize(LNewWidth, LNewHeight);
    end;

    // retrieve the top left position of a layer
    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);

    // process layer thumbnail
    UpdateLayerThumbnail;

    // process mask thumbnail
    RotateMaskCanvas(ADeg, ADirection);

    // process last alpha channel bitmap
    LSourceBitmap.DrawMode := dmOpaque;
    LSourceBitmap.Assign(FLastAlphaChannelBmp);
    RotateBitmap32(LSourceBitmap, FLastAlphaChannelBmp, ADirection, ADeg, 0, clWhite32);
  finally
    LSourceBitmap.Free;
  end;
end;

procedure TgmBackgroundLayerPanel.CropImage(const AImageControl: TCustomImage32;
  const ACrop: TgmCrop; const ABackColor: TColor32);
var
  LCropRect  : TRect;
  LCropBitmap: TBitmap32;
  LTopLeft   : TPoint;
begin
  LCropBitmap := TBitmap32.Create;
  try
    LCropBitmap.DrawMode := dmBlend;
    
    LCropRect := Rect(ACrop.FCropStart.X, ACrop.FCropStart.Y,
                      ACrop.FCropEnd.X, ACrop.FCropEnd.Y);

    CopyRect32WithARGB(LCropBitmap, FAssociatedLayer.Bitmap, LCropRect, ABackColor);

    FAssociatedLayer.Bitmap.SetSize(LCropBitmap.Width, LCropBitmap.Height);
    CopyBitmap32(FAssociatedLayer.Bitmap, LCropBitmap);

    // process last alpha channel bitmap
    LCropBitmap.DrawMode := dmOpaque;
    CopyRect32WithARGB(LCropBitmap, FLastAlphaChannelBmp, LCropRect, clWhite32);
    FLastAlphaChannelBmp.Assign(LCropBitmap);

    if ACrop.IsResized then
    begin
      if (FAssociatedLayer.Bitmap.Width  <> ACrop.ResizeW) or
         (FAssociatedLayer.Bitmap.Height <> ACrop.ResizeH) then
      begin
        SmoothResize32(FAssociatedLayer.Bitmap, ACrop.ResizeW, ACrop.ResizeH);
        SmoothResize32(FLastAlphaChannelBmp,    ACrop.ResizeW, ACrop.ResizeH);
      end;
    end;

    // retrieve the top left position of a layer
    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);

    // process layer thumbnail.
    UpdateLayerThumbnail;

    // process mask
    CropMask(ACrop);
  finally
    LCropBitmap.Free;
  end;
end;

function TgmBackgroundLayerPanel.DuplicateCurrentLayerPanel(
  const AOwner: TWinControl; const ALayers: TLayerCollection;
  const ALayerIndex: Integer; const ALayerName: string): TgmLayerPanel;
var
  LLayer: TBitmapLayer;
begin
  ALayers.Insert(ALayerIndex, TBitmapLayer);

  LLayer          := TBitmapLayer(ALayers.Items[ALayerIndex]);
  LLayer.Location := FAssociatedLayer.Location;
  LLayer.Scaled   := True;
  
  LLayer.Bitmap.Assign(FAssociatedLayer.Bitmap);
  LLayer.Bitmap.MasterAlpha := 255;
  LLayer.Bitmap.DrawMode    := dmCustom;

  Result                    := TgmBackgroundLayerPanel.Create(AOwner, LLayer);
  Result.IsDuplicated       := True;
  Result.BlendModeIndex     := Self.FBlendModeIndex;
  Result.LayerMasterAlpha   := Self.FLayerMasterAlpha;
  Result.IsLockTransparency := Self.FLockTransparency;
  Result.SetLayerName(ALayerName);

{ Duplicate mask }
  Result.IsHasMask         := Self.FHasMask;
  Result.IsMaskLinked      := Self.FMaskLinked;
  Result.LayerProcessStage := Self.FLayerProcessStage;
  Result.PrevProcessStage  := Self.FPrevProcessStage;

  if Result.IsHasMask then
  begin
    Result.FLastAlphaChannelBmp.Assign(Self.FLastAlphaChannelBmp);
    Result.FMaskImage.Bitmap.Assign(Self.FMaskImage.Bitmap);
    Result.UpdateMaskThumbnail;
    Result.ShowThumbnailByRightOrder;
  end;
end;

{ Save the layer to a stream for output it to a '*gmd' file later.
  Parameter AStream must be valid. We don't check for this for
  performance. }
procedure TgmBackgroundLayerPanel.SaveToStream(const AStream: TStream);
var
  LLayerHeader: TgmLayerHeaderVer1;
  i           : Integer;
  LPixelBits  : PColor32;
  LRowStride  : Cardinal; // in bytes
  LByteMap    : TByteMap;
  LByteBits   : PByte;
begin
  LLayerHeader.LayerName        := FLayerName.Caption;
  LLayerHeader.LayerFeature     := Ord(lfBackground);
  LLayerHeader.BlendModeIndex   := FBlendModeIndex;
  LLayerHeader.MasterAlpha      := FLayerMasterAlpha;
  LLayerHeader.Selected         := FSelected;
  LLayerHeader.Visible          := FLayerVisible;
  LLayerHeader.LockTransparency := FLockTransparency;
  LLayerHeader.Duplicated       := FDuplicated;
  LLayerHeader.HasMask          := FHasMask;
  LLayerHeader.MaskLinked       := FMaskLinked;

  // write the layer header to stream
  AStream.Write(LLayerHeader, SizeOf(TgmLayerHeaderVer1));

  // write the pixels of the layer to stream
  LRowStride := FAssociatedLayer.Bitmap.Width * SizeOf(TColor32);
  LPixelBits := @FAssociatedLayer.Bitmap.Bits[0];

  for i := 0 to (FAssociatedLayer.Bitmap.Height - 1) do
  begin
    AStream.Write(LPixelBits^, LRowStride);
    Inc(LPixelBits, FAssociatedLayer.Bitmap.Width);
  end;

  // write the mask data to stream, if any
  if FHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      // write the mask data to stream
      LByteMap.SetSize(FMaskImage.Bitmap.Width, FMaskImage.Bitmap.Height);
      LByteMap.ReadFrom(FMaskImage.Bitmap, ctUniformRGB);

      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (FMaskImage.Bitmap.Height - 1) do
      begin
        AStream.Write(LByteBits^, FMaskImage.Bitmap.Width);
        Inc(LByteBits, FMaskImage.Bitmap.Width);
      end;

      // write the last alpha data of the layer to stream
      LByteMap.ReadFrom(FLastAlphaChannelBmp, ctUniformRGB);

      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (FLastAlphaChannelBmp.Height - 1) do
      begin
        AStream.Write(LByteBits^, FLastAlphaChannelBmp.Width);
        Inc(LByteBits, FLastAlphaChannelBmp.Width);
      end;
    finally
      LByteMap.Free;
    end;
  end;
end; 

//-- TgmTransparentLayerPanel --------------------------------------------------

constructor TgmTransparentLayerPanel.Create(const AOwner: TWinControl;
  const ALayer: TBitmapLayer);
begin
  inherited Create(AOwner, ALayer);

  FLayerFeature := lfTransparent;

  if FAssociatedLayer <> nil then
  begin
    FAssociatedLayer.Bitmap.OnPixelCombine := LayerPixelBlend;
  end;

  UpdateLayerThumbnail;
end;

procedure TgmTransparentLayerPanel.LayerPixelBlend(F: TColor32; var B: TColor32;
  M: TColor32);
begin
  FBlendModeEvent(F, B, M);
end;

procedure TgmTransparentLayerPanel.ChangeImageSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AOptions: TgmResamplingOptions);
var
  LTopLeft: TPoint;
begin
  if (FAssociatedLayer.Bitmap.Width  <> ANewWidth) or
     (FAssociatedLayer.Bitmap.Height <> ANewHeight) then
  begin
    // change the dimension of the associated layer

    ExecuteResample(FAssociatedLayer.Bitmap, ANewWidth, ANewHeight, AOptions);
    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);

    // process layer thumbnail
    UpdateLayerThumbnail;

    // process mask thumbnail
    ResizeMask(ANewWidth, ANewHeight, AOptions);

    // process last alpha channel bitmap
    SmoothResize32(FLastAlphaChannelBmp, ANewWidth, ANewHeight);
  end;
end;

procedure TgmTransparentLayerPanel.ChangeCanvasSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AAnchor: TgmAnchorDirection; const ABackgroundColor: TColor32);
var
  LTopLeft  : TPoint;
  LCutBitmap: TBitmap32;
begin
  if (FAssociatedLayer.Bitmap.Width  <> ANewWidth) or
     (FAssociatedLayer.Bitmap.Height <> ANewHeight) then
  begin
    LCutBitmap := TBitmap32.Create;
    try
      LCutBitmap.DrawMode := dmBlend;

      CutBitmap32ByAnchorDirection(FAssociatedLayer.Bitmap, LCutBitmap,
                                   ANewWidth, ANewHeight, AAnchor, $00FFFFFF);

      FAssociatedLayer.Bitmap.SetSize(ANewWidth, ANewHeight);
      FAssociatedLayer.Bitmap.Clear($00FFFFFF);
      DrawBitmap32ByAnchorDirection(LCutBitmap, FAssociatedLayer.Bitmap, AAnchor);

      LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

      FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                             AImageControl.Bitmap.Width,
                                             AImageControl.Bitmap.Height);

      // process layer thumbnail
      UpdateLayerThumbnail;

      // process mask thumbnail.
      ChangeMaskCanvasSize(ANewWidth, ANewHeight, AAnchor);

      // process last alpha channel bitmap
      LCutBitmap.DrawMode := dmOpaque;
      CutBitmap32ByAnchorDirection(FLastAlphaChannelBmp, LCutBitmap,
                                   ANewWidth, ANewHeight, AAnchor, clBlack32);

      FLastAlphaChannelBmp.SetSize(ANewWidth, ANewHeight);
      FLastAlphaChannelBmp.Clear(clBlack32);
      DrawBitmap32ByAnchorDirection(LCutBitmap, FLastAlphaChannelBmp, AAnchor);
    finally
      LCutBitmap.Free;
    end;
  end;
end;

procedure TgmTransparentLayerPanel.RotateCanvas(
  const AImageControl: TCustomImage32; const ADeg: Integer;
  const ADirection: TgmRotateDirection; const AResizeBackground: Boolean;
  const ABackColor: TColor32);
var
  LSourceBitmap        : TBitmap32;
  LTopLeft             : TPoint;
  LNewWidth, LNewHeight: Integer;
begin
  LSourceBitmap := TBitmap32.Create;
  try
    LSourceBitmap.Assign(FAssociatedLayer.Bitmap);

    RotateBitmap32(LSourceBitmap, FAssociatedLayer.Bitmap, ADirection, ADeg, 0,
                   $00FFFFFF);

    LNewWidth  := FAssociatedLayer.Bitmap.Width;
    LNewHeight := FAssociatedLayer.Bitmap.Height;

    if AResizeBackground then
    begin
      AImageControl.Bitmap.SetSize(LNewWidth, LNewHeight);
    end;

    // retrieve the top left position of a layer
    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);

    // process layer thumbnail
    UpdateLayerThumbnail;

    // process mask thumbnail
    RotateMaskCanvas(ADeg, ADirection);

    // process last alpha channel bitmap
    LSourceBitmap.DrawMode := dmOpaque;
    LSourceBitmap.Assign(FLastAlphaChannelBmp);
    RotateBitmap32(LSourceBitmap, FLastAlphaChannelBmp, ADirection, ADeg, 0, clWhite32);
  finally
    LSourceBitmap.Free;
  end;
end;

procedure TgmTransparentLayerPanel.CropImage(
  const AImageControl: TCustomImage32; const ACrop: TgmCrop;
  const ABackColor: TColor32);
var
  LCropRect  : TRect;
  LCropBitmap: TBitmap32;
  LTopLeft   : TPoint;
begin
  LCropBitmap := TBitmap32.Create;
  try
    LCropBitmap.DrawMode := dmBlend;

    LCropRect := Rect(ACrop.FCropStart.X, ACrop.FCropStart.Y,
                      ACrop.FCropEnd.X,   ACrop.FCropEnd.Y);

    CopyRect32WithARGB(LCropBitmap, FAssociatedLayer.Bitmap, LCropRect, $00FFFFFF);

    FAssociatedLayer.Bitmap.SetSize(LCropBitmap.Width, LCropBitmap.Height);
    CopyBitmap32(FAssociatedLayer.Bitmap, LCropBitmap);

    // Process last alpha channel bitmap
    LCropBitmap.DrawMode := dmOpaque;
    CopyRect32WithARGB(LCropBitmap, FLastAlphaChannelBmp, LCropRect, clWhite32);
    FLastAlphaChannelBmp.Assign(LCropBitmap);

    if ACrop.IsResized then
    begin
      if (FAssociatedLayer.Bitmap.Width  <> ACrop.ResizeW) or
         (FAssociatedLayer.Bitmap.Height <> ACrop.ResizeH) then
      begin
        SmoothResize32(FAssociatedLayer.Bitmap, ACrop.ResizeW, ACrop.ResizeH);
        SmoothResize32(FLastAlphaChannelBmp,    ACrop.ResizeW, ACrop.ResizeH);
      end;
    end;

    // retrieve the top left position of a layer
    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);

    // process layer thumbnail
    UpdateLayerThumbnail;
    
    // process Mask
    CropMask(ACrop);
  finally
    LCropBitmap.Free;
  end;
end;

function TgmTransparentLayerPanel.DuplicateCurrentLayerPanel(
  const AOwner: TWinControl; const ALayers: TLayerCollection;
  const ALayerIndex: Integer; const ALayerName: string): TgmLayerPanel;
var
  LLayer: TBitmapLayer;
begin
  ALayers.Insert(ALayerIndex, TBitmapLayer);

  LLayer          := TBitmapLayer(ALayers.Items[ALayerIndex]);
  LLayer.Location := FAssociatedLayer.Location;
  LLayer.Scaled   := True;

  LLayer.Bitmap.Assign(FAssociatedLayer.Bitmap);
  LLayer.Bitmap.MasterAlpha := 255;
  LLayer.Bitmap.DrawMode    := dmCustom;

  Result := TgmTransparentLayerPanel.Create(AOwner, LLayer);
  Result.IsDuplicated       := True;
  Result.BlendModeIndex     := Self.FBlendModeIndex;
  Result.LayerMasterAlpha   := Self.FLayerMasterAlpha;
  Result.IsLockTransparency := Self.FLockTransparency;
  Result.SetLayerName(ALayerName);

{ Duplicate mask }
  Result.IsHasMask         := Self.FHasMask;
  Result.IsMaskLinked      := Self.FMaskLinked;
  Result.LayerProcessStage := Self.FLayerProcessStage;
  Result.PrevProcessStage  := Self.FPrevProcessStage;

  if Result.IsHasMask then
  begin
    Result.FLastAlphaChannelBmp.Assign(Self.FLastAlphaChannelBmp);
    Result.FMaskImage.Bitmap.Assign(Self.FMaskImage.Bitmap);
    Result.UpdateMaskThumbnail;
    Result.ShowThumbnailByRightOrder;
  end;
end;

// save the layer to a stream for output it to a '*gmd' file later
procedure TgmTransparentLayerPanel.SaveToStream(const AStream: TStream);
var
  LLayerHeader: TgmLayerHeaderVer1;
  i           : Integer;
  LPixelBits  : PColor32;
  LRowStride  : Cardinal; // in bytes
  LByteMap    : TByteMap;
  LByteBits   : PByte;
begin
  LLayerHeader.LayerName        := FLayerName.Caption;
  LLayerHeader.LayerFeature     := Ord(lfTransparent);
  LLayerHeader.BlendModeIndex   := FBlendModeIndex;
  LLayerHeader.MasterAlpha      := FLayerMasterAlpha;
  LLayerHeader.Selected         := FSelected;
  LLayerHeader.Visible          := FLayerVisible;
  LLayerHeader.LockTransparency := FLockTransparency;
  LLayerHeader.Duplicated       := FDuplicated;
  LLayerHeader.HasMask          := FHasMask;
  LLayerHeader.MaskLinked       := FMaskLinked;

  // write the layer header to stream
  AStream.Write(LLayerHeader, SizeOf(TgmLayerHeaderVer1));

  // write the pixels of the layer to stream
  LRowStride := FAssociatedLayer.Bitmap.Width * SizeOf(TColor32);
  LPixelBits := @FAssociatedLayer.Bitmap.Bits[0];

  for i := 0 to (FAssociatedLayer.Bitmap.Height - 1) do
  begin
    AStream.Write(LPixelBits^, LRowStride);
    Inc(LPixelBits, FAssociatedLayer.Bitmap.Width);
  end;

  // write the mask data to stream, if any
  if FHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      // write the mask data to stream
      LByteMap.SetSize(FMaskImage.Bitmap.Width, FMaskImage.Bitmap.Height);
      LByteMap.ReadFrom(FMaskImage.Bitmap, ctUniformRGB);

      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (FMaskImage.Bitmap.Height - 1) do
      begin
        AStream.Write(LByteBits^, FMaskImage.Bitmap.Width);
        Inc(LByteBits, FMaskImage.Bitmap.Width);
      end;

      // write the last alpha data of the layer to stream
      LByteMap.ReadFrom(FLastAlphaChannelBmp, ctUniformRGB);

      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (FLastAlphaChannelBmp.Height - 1) do
      begin
        AStream.Write(LByteBits^, FLastAlphaChannelBmp.Width);
        Inc(LByteBits, FLastAlphaChannelBmp.Width);
      end;
    finally
      LByteMap.Free;
    end;
  end;
end;

//-- TgmSolidColorLayerPanel ---------------------------------------------------

constructor TgmSolidColorLayerPanel.Create(const AOwner: TWinControl;
  const ALayer: TBitmapLayer);
var
  LFillColor: TColor32;
begin
  inherited Create(AOwner, ALayer);

  FLayerImage.PaintStages[0].Stage := PST_CLEAR_BACKGND;

  FLayerFeature         := lfSolidColor;
  FHoldMaskInLayerAlpha := True;
  FThumbnailW           := IMAGE_WIDTH;
  FThumbnailH           := IMAGE_HEIGHT;
  FSolidColor           := clBlack;

  if FAssociatedLayer <> nil then
  begin
    FAssociatedLayer.Bitmap.OnPixelCombine := LayerPixelBlend;
    LFillColor                             := Color32(FSolidColor);
    
    FAssociatedLayer.Bitmap.FillRectS(FAssociatedLayer.Bitmap.Canvas.ClipRect, LFillColor);
  end;

  DrawSolidColorLayerThumbnail;
end; 

procedure TgmSolidColorLayerPanel.DrawSolidColorLayerThumbnail;
begin
  DrawPhotoshopStyleColorThumbnail(FSolidColor);
end;

procedure TgmSolidColorLayerPanel.SetSolidColor(const AColor: TColor);
var
  LFillColor: TColor32;
begin
  if FSolidColor <> AColor then
  begin
    FSolidColor := AColor;
    LFillColor  := Color32(FSolidColor);

    if Assigned(FAssociatedLayer) then
    begin
      FAssociatedLayer.Bitmap.FillRectS(FAssociatedLayer.Bitmap.ClipRect, LFillColor);

      // save the mask to the alpha channels of this layer
      UpdateLayerAlphaWithMask;
      FAssociatedLayer.Bitmap.Changed;
    end;

    DrawSolidColorLayerThumbnail;
  end;  
end;

procedure TgmSolidColorLayerPanel.LayerPixelBlend(F: TColor32; var B: TColor32;
  M: TColor32);
var
  a, LIntensity: Byte;
  LForeColor   : TColor32;
begin
  if FMaskLinked then
  begin
    LForeColor := F and $FFFFFF;  // only need RGB components

    { We already saved the mask info of this special layer into the alpha
      channel of each pixels on the layer. So we get the mask value for this
      pixel from its alpha channel.

      Important: Never change the alpha channel of F at here. }

    // Calculating alpha value for applying mask.
    LIntensity := F shr 24 and $FF; // extract mask value from alpha
    a          := 255 - (255 - LIntensity);
    LForeColor := (a shl 24) or LForeColor;
  end
  else
  begin
    LForeColor := $FF000000 or F;
  end;

  FBlendModeEvent(LForeColor, B, M);
end;

procedure TgmSolidColorLayerPanel.ChangeImageSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AOptions: TgmResamplingOptions);
var
  LTopLeft: TPoint;
begin
  if (FAssociatedLayer.Bitmap.Width  <> ANewWidth) or
     (FAssociatedLayer.Bitmap.Height <> ANewHeight) then
  begin
    // Change the dimension of the associated layer.
    FAssociatedLayer.Bitmap.SetSize(ANewWidth, ANewHeight);
    FAssociatedLayer.Bitmap.Clear( Color32(FSolidColor) );

    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);
                                           
    // Process mask thumbnail.
    ResizeMask(ANewWidth, ANewHeight, AOptions);
  end;
end;

procedure TgmSolidColorLayerPanel.ChangeCanvasSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AAnchor: TgmAnchorDirection; const ABackgroundColor: TColor32);
var
  LTopLeft: TPoint;
begin
  if (FAssociatedLayer.Bitmap.Width  <> ANewWidth) or
     (FAssociatedLayer.Bitmap.Height <> ANewHeight) then
  begin
    // change the dimension of the associated layer
    FAssociatedLayer.Bitmap.SetSize(ANewWidth, ANewHeight);
    FAssociatedLayer.Bitmap.Clear( Color32(FSolidColor) );

    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);
                                           
    // process mask thumbnail
    ChangeMaskCanvasSize(ANewWidth, ANewHeight, AAnchor);
  end;
end;

procedure TgmSolidColorLayerPanel.RotateCanvas(
  const AImageControl: TCustomImage32; const ADeg: Integer;
  const ADirection: TgmRotateDirection; const AResizeBackground: Boolean;
  const ABackColor: TColor32);
var
  LSrcBmp              : TBitmap32;
  LTopLeft             : TPoint;
  LNewWidth, LNewHeight: Integer;
begin
  LSrcBmp := TBitmap32.Create;
  try
    LSrcBmp.SetSize(FAssociatedLayer.Bitmap.Width, FAssociatedLayer.Bitmap.Height);
    RotateBitmap32(LSrcBmp, FAssociatedLayer.Bitmap, ADirection, ADeg, 0, clBlack32);
    FAssociatedLayer.Bitmap.Clear( Color32(FSolidColor) );

    LNewWidth  := FAssociatedLayer.Bitmap.Width;
    LNewHeight := FAssociatedLayer.Bitmap.Height;

    if AResizeBackground then
    begin
      AImageControl.Bitmap.SetSize(LNewWidth, LNewHeight);
    end;

    // retrieve the top left position of a layer
    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);

    // process mask thumbnail.
    RotateMaskCanvas(ADeg, ADirection);
  finally
    LSrcBmp.Free;
  end;
end;

procedure TgmSolidColorLayerPanel.CropImage(const AImageControl: TCustomImage32;
  const ACrop: TgmCrop; const ABackColor: TColor32);
var
  LNewWidth, LNewHeight: Integer;
  LTopLeft             : TPoint;
begin
  if ACrop.IsResized then
  begin
    LNewWidth  := ACrop.ResizeW;
    LNewHeight := ACrop.ResizeH;
  end
  else
  begin
    LNewWidth  := ACrop.FCropEnd.X - ACrop.FCropStart.X;
    LNewHeight := ACrop.FCropEnd.Y - ACrop.FCropStart.Y;
  end;

  FAssociatedLayer.Bitmap.SetSize(LNewWidth, LNewHeight);
  FAssociatedLayer.Bitmap.Clear( Color32(FSolidColor) );

  // retrieve the top left position of a layer
  LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

  FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                         AImageControl.Bitmap.Width,
                                         AImageControl.Bitmap.Height);

  // Process mask thumbnail.
  CropMask(ACrop);
end;

function TgmSolidColorLayerPanel.DuplicateCurrentLayerPanel(
  const AOwner: TWinControl; const ALayers: TLayerCollection;
  const ALayerIndex: Integer; const ALayerName: string): TgmLayerPanel;
var
  LLayer         : TBitmapLayer;
  LColorLayerPanel: TgmSolidColorLayerPanel;
begin
  ALayers.Insert(ALayerIndex, TBitmapLayer);

  LLayer          := TBitmapLayer(ALayers.Items[ALayerIndex]);
  LLayer.Location := FAssociatedLayer.Location;
  LLayer.Scaled   := True;
  
  LLayer.Bitmap.Assign(FAssociatedLayer.Bitmap);
  LLayer.Bitmap.MasterAlpha := 255;
  LLayer.Bitmap.DrawMode    := dmCustom;

  LColorLayerPanel                    := TgmSolidColorLayerPanel.Create(AOwner, LLayer);
  LColorLayerPanel.IsDuplicated       := True;
  LColorLayerPanel.SolidColor         := Self.FSolidColor;
  LColorLayerPanel.BlendModeIndex     := Self.FBlendModeIndex;
  LColorLayerPanel.LayerMasterAlpha   := Self.FLayerMasterAlpha;
  LColorLayerPanel.IsLockTransparency := Self.FLockTransparency;
  LColorLayerPanel.SetLayerName(ALayerName);

{ Duplicate mask }
  LColorLayerPanel.IsHasMask         := Self.FHasMask;
  LColorLayerPanel.IsMaskLinked      := Self.FMaskLinked;
  LColorLayerPanel.LayerProcessStage := Self.FLayerProcessStage;
  LColorLayerPanel.PrevProcessStage  := Self.FPrevProcessStage;

  if LColorLayerPanel.IsHasMask then
  begin
    LColorLayerPanel.FMaskImage.Bitmap.Assign(Self.FMaskImage.Bitmap);
    LColorLayerPanel.UpdateMaskThumbnail;

    // save Mask into layer's alpha channels
    LColorLayerPanel.UpdateLayerAlphaWithMask;

    LColorLayerPanel.ShowThumbnailByRightOrder;
  end;
  
  Result := LColorLayerPanel;
end;

// save the layer to a stream for output it to a '*gmd' file later
procedure TgmSolidColorLayerPanel.SaveToStream(
  const AStream: TStream);
var
  LLayerHeader: TgmLayerHeaderVer1;
  i           : Integer;
  LByteMap    : TByteMap;
  LByteBits   : PByte;
begin
  LLayerHeader.LayerName        := FLayerName.Caption;
  LLayerHeader.LayerFeature     := Ord(lfSolidColor);
  LLayerHeader.BlendModeIndex   := FBlendModeIndex;
  LLayerHeader.MasterAlpha      := FLayerMasterAlpha;
  LLayerHeader.Selected         := FSelected;
  LLayerHeader.Visible          := FLayerVisible;
  LLayerHeader.LockTransparency := FLockTransparency;
  LLayerHeader.Duplicated       := FDuplicated;
  LLayerHeader.HasMask          := FHasMask;
  LLayerHeader.MaskLinked       := FMaskLinked;

  // write the layer header to stream
  AStream.Write(LLayerHeader, SizeOf(TgmLayerHeaderVer1));

  // write the filling color to stream
  AStream.Write(FSolidColor, SizeOf(TColor));

  // write the mask data to stream, if any
  if FHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      // write the mask data to stream
      LByteMap.SetSize(FMaskImage.Bitmap.Width, FMaskImage.Bitmap.Height);
      LByteMap.ReadFrom(FMaskImage.Bitmap, ctUniformRGB);

      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (FMaskImage.Bitmap.Height - 1) do
      begin
        AStream.Write(LByteBits^, FMaskImage.Bitmap.Width);
        Inc(LByteBits, FMaskImage.Bitmap.Width);
      end;
    finally
      LByteMap.Free;
    end;
  end;
end;

//-- TgmGradientFillLayerPanel -------------------------------------------------

constructor TgmGradientFillLayerPanel.Create(const AOwner: TWinControl;
  const ALayer: TBitmapLayer; const AGradient: TgmGradientItem);
begin
  inherited Create(AOwner, ALayer);

  FLayerFeature := lfGradientFill;  // indicating Gradient Fill layer

  if FAssociatedLayer <> nil then
  begin
    FAssociatedLayer.Bitmap.OnPixelCombine := LayerPixelBlend;
  end;

  FGradient     := TgmGradientItem.Create(nil);
  FLastGradient := TgmGradientItem.Create(nil);
  if Assigned(AGradient) then
  begin
    FGradient.Assign(AGradient);
  end;

  FGradientThumbnail          := TBitmap32.Create;
  FGradientThumbnail.DrawMode := dmBlend;
  FGradientThumbnail.SetSize(IMAGE_WIDTH, IMAGE_HEIGHT);
  
  FLayerImage.Bitmap.SetSize(IMAGE_WIDTH, IMAGE_HEIGHT);
  DrawGradientFillLayerThumbnail;

  FStyle       := grmLinear;
  FAngle       := 0 - 90;
  FScale       := 1.0;
  FCenterPoint := Point(FMaskImage.Bitmap.Width div 2, FMaskImage.Bitmap.Height div 2);
  FTranslateX  := 0;
  FTranslateY  := 0;
  FReversed    := False;

  CalculateGradientCoord;

  FOriginalCenter := FCenterPoint;
  FOriginalStart  := FStartPoint;
  FOriginalEnd    := FEndPoint;

  SaveLastAdjustment;  // save last settings 
end; 

destructor TgmGradientFillLayerPanel.Destroy;
begin
  FGradientThumbnail.Free;
  FGradient.Free;
  FLastGradient.Free;
  
  inherited Destroy;
end;

procedure TgmGradientFillLayerPanel.DrawGradientFillLayerThumbnail;
var
  LGradientBmp: TBitmap32;
begin
  if not Assigned(FGradient) then
  begin
    Exit;
  end;

  // draw the Photoshop-style thumbnail for the gradient fill layer
  FGradientThumbnail.FillRectS(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT, clWhite32);
  LGradientBmp := TBitmap32.Create;
  try
    LGradientBmp.Assign( FGradient.CachedBitmap(IMAGE_WIDTH, 22) );
    LGradientBmp.DrawMode := dmBlend;

    FGradientThumbnail.Draw(0, 0, LGradientBmp);

    FGradientThumbnail.PenColor := clBlack32;
    FGradientThumbnail.HorzLine(0, 22, 31, clBlack32);
    FGradientThumbnail.FrameRectS(FLayerImage.Bitmap.Canvas.ClipRect, clBlack32);
    FGradientThumbnail.HorzLine(4, 25, 26, clBlack32);
    FGradientThumbnail.MoveTo(17, 26);
    FGradientThumbnail.LineToS(15, 28);
    FGradientThumbnail.MoveTo(17, 26);
    FGradientThumbnail.LineToS(19, 28);
    FGradientThumbnail.HorzLine(15, 28, 19, clBlack32);

    FLayerImage.Bitmap.Assign(FGradientThumbnail);
    FLayerImage.Bitmap.Changed;
  finally
    LGradientBmp.Free;
  end;
end; 

procedure TgmGradientFillLayerPanel.CalculateGradientCoord;
var
  LRadius, LRadians: Double;
  LWidth, LHeight  : Integer;
begin
  LWidth  := FAssociatedLayer.Bitmap.Width;
  LHeight := FAssociatedLayer.Bitmap.Height;
  LRadius := MinValue([LWidth / 2, LHeight / 2]);
  LRadius := LRadius * FScale;

  LRadians       := DegToRad(FAngle);
  FStartPoint    := CalcOffsetPointByRadian(FCenterPoint, LRadians, LRadius);
  FEndPoint      := CalcOffsetPointByRadian(FCenterPoint, LRadians + PI, LRadius);
  FOriginalStart := CalcOffsetPointByRadian(FOriginalCenter, LRadians, LRadius);
  FOriginalEnd   := CalcOffsetPointByRadian(FOriginalCenter, LRadians + PI, LRadius);
end;

procedure TgmGradientFillLayerPanel.DrawGradientOnLayer;
begin
  case FStyle of
    grmLinear:
      begin
        DrawLinearGradient(FAssociatedLayer.Bitmap, FEndPoint, FStartPoint,
                           FGradient, FReversed);
      end;

    grmRadial:
      begin
        DrawRadialGradient(FAssociatedLayer.Bitmap, FCenterPoint, FStartPoint,
                           FGradient, FReversed);
      end;

    grmAngle:
      begin
        DrawAngleGradient(FAssociatedLayer.Bitmap, FCenterPoint, FStartPoint,
                          FGradient, FReversed);
      end;

    grmReflected:
      begin
        DrawReflectedGradient(FAssociatedLayer.Bitmap, FStartPoint, FEndPoint,
                              FGradient, FReversed);
      end;

    grmDiamond:
      begin
        DrawDiamondGradient(FAssociatedLayer.Bitmap, FCenterPoint, FStartPoint,
                            FGradient, FReversed);
      end;
  end;

  if FHasMask then
  begin
    GetAlphaChannelBitmap(FAssociatedLayer.Bitmap, FLastAlphaChannelBmp);
  end;

  FAssociatedLayer.Bitmap.Changed;
end; 

procedure TgmGradientFillLayerPanel.SetGradient(
  const AGradient: TgmGradientItem);
begin
  if Assigned(AGradient) then
  begin
    FGradient.Assign(AGradient);
    DrawGradientOnLayer;
  end;
end; 

procedure TgmGradientFillLayerPanel.SetStyle(
  const AStyle: TgmGradientRenderMode);
begin
  if FStyle <> AStyle then
  begin
    FStyle := AStyle;
    DrawGradientOnLayer;
  end;
end;

procedure TgmGradientFillLayerPanel.SetAngle(const AAngle: Integer);
begin
  if FAngle <> AAngle then
  begin
    FAngle := AAngle;
    CalculateGradientCoord;
    DrawGradientOnLayer;
  end;
end;

procedure TgmGradientFillLayerPanel.SetScale(const AScale: Double);
begin
  if FScale <> AScale then
  begin
    FScale := AScale;
    
    CalculateGradientCoord;
    DrawGradientOnLayer;
  end;
end;

procedure TgmGradientFillLayerPanel.SetTranslateX(const AValue: Integer);
begin
  if FTranslateX <> AValue then
  begin
    FTranslateX    := AValue;
    FCenterPoint.X := FOriginalCenter.X + AValue;
    FStartPoint.X  := FOriginalStart.X  + AValue;
    FEndPoint.X    := FOriginalEnd.X    + AValue;

    DrawGradientOnLayer;
  end;
end;

procedure TgmGradientFillLayerPanel.SetTranslateY(const AValue: Integer);
begin
  if FTranslateY <> AValue then
  begin
    FTranslateY    := AValue;
    FCenterPoint.Y := FOriginalCenter.Y + AValue;
    FStartPoint.Y  := FOriginalStart.Y  + AValue;
    FEndPoint.Y    := FOriginalEnd.Y    + AValue;

    DrawGradientOnLayer;
  end;
end;

procedure TgmGradientFillLayerPanel.SetReverse(const AReverse: Boolean);
begin
  if FReversed <> AReverse then
  begin
    FReversed := AReverse;
    
    DrawGradientOnLayer;
  end;
end;

procedure TgmGradientFillLayerPanel.LayerPixelBlend(
  F: TColor32; var B: TColor32; M: TColor32);
begin
  FBlendModeEvent(F, B, M);
end;

procedure TgmGradientFillLayerPanel.ChangeImageSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AOptions: TgmResamplingOptions);
var
  LTopLeft             : TPoint;
  LOldWidth, LOldHeight: Integer;
begin
  LOldWidth  := FAssociatedLayer.Bitmap.Width;
  LOldHeight := FAssociatedLayer.Bitmap.Height;

  if (LOldWidth <> ANewWidth) or (LOldHeight <> ANewHeight) then
  begin
    // Change the dimension of the associated layer.
    FAssociatedLayer.Bitmap.SetSize(ANewWidth, ANewHeight);

    FCenterPoint    := ScalePoint(FCenterPoint, LOldWidth, LOldHeight, ANewWidth, ANewHeight);
    FOriginalCenter := Point(ANewWidth div 2, ANewHeight div 2);
    FTranslateX     := MulDiv(FTranslateX, ANewWidth,  LOldWidth);
    FTranslateY     := MulDiv(FTranslateY, ANewHeight, LOldHeight);

    CalculateGradientCoord;
    SaveLastAdjustment;
    DrawGradientOnLayer;

    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);

    // Process mask thumbnail.
    ResizeMask(ANewWidth, ANewHeight, AOptions);

    if FHasMask and FMaskLinked then
    begin
      ChangeAlphaChannelBySubMask(FAssociatedLayer.Bitmap,
                                  FLastAlphaChannelBmp,
                                  FMaskImage.Bitmap);
    end;
  end;
end;

procedure TgmGradientFillLayerPanel.ChangeCanvasSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AAnchor: TgmAnchorDirection; const ABackgroundColor: TColor32);
var
  LTopLeft, LOffsetVector: TPoint;
  LOldWidth, LOldHeight  : Integer;
begin
  LOldWidth  := FAssociatedLayer.Bitmap.Width;
  LOldHeight := FAssociatedLayer.Bitmap.Height;

  if (LOldWidth <> ANewWidth) or (LOldHeight <> ANewHeight) then
  begin
    // change the dimension of the associated layer
    FAssociatedLayer.Bitmap.SetSize(ANewWidth, ANewHeight);
    
    LOffsetVector := CalcOffsetCoordinateByAnchorDirection(
      LOldWidth, LOldHeight, ANewWidth, ANewHeight, AAnchor);

    FCenterPoint    := AddPoints(FCenterPoint, LOffsetVector);
    FOriginalCenter := Point(ANewWidth div 2, ANewHeight div 2);
    FTranslateX     := FTranslateX + LOffsetVector.X;
    FTranslateY     := FTranslateY + LOffsetVector.Y;

    CalculateGradientCoord;
    SaveLastAdjustment;
    DrawGradientOnLayer;

    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);

    // process mask thumbnail
    ChangeMaskCanvasSize(ANewWidth, ANewHeight, AAnchor);

    if FHasMask and FMaskLinked then
    begin
      ChangeAlphaChannelBySubMask(FAssociatedLayer.Bitmap,
                                  FLastAlphaChannelBmp,
                                  FMaskImage.Bitmap);
    end;
  end;
end;

procedure TgmGradientFillLayerPanel.RotateCanvas(
  const AImageControl: TCustomImage32; const ADeg: Integer;
  const ADirection: TgmRotateDirection; const AResizeBackground: Boolean;
  const ABackColor: TColor32);
var
  LSrcBmp              : TBitmap32;
  LTopLeft             : TPoint;
  LNewWidth, LNewHeight: Integer;
  LOldWidth, LOldHeight: Integer;
begin
  LOldWidth  := FAssociatedLayer.Bitmap.Width;
  LOldHeight := FAssociatedLayer.Bitmap.Height;
  
  LSrcBmp := TBitmap32.Create;
  try
    LSrcBmp.Assign(FAssociatedLayer.Bitmap);
    RotateBitmap32(LSrcBmp, FAssociatedLayer.Bitmap, ADirection, ADeg, 0, ABackColor);

    LNewWidth  := FAssociatedLayer.Bitmap.Width;
    LNewHeight := FAssociatedLayer.Bitmap.Height;

    FCenterPoint    := ScalePoint(FCenterPoint, LOldWidth, LOldHeight, LNewWidth, LNewHeight);
    FOriginalCenter := Point(LNewWidth div 2, LNewHeight div 2);
    FTranslateX     := MulDiv(FTranslateX, LNewWidth,  LOldWidth);
    FTranslateY     := MulDiv(FTranslateY, LNewHeight, LOldHeight);

    CalculateGradientCoord;
    SaveLastAdjustment;
    DrawGradientOnLayer;

    if AResizeBackground then
    begin
      AImageControl.Bitmap.SetSize(LNewWidth, LNewHeight);
    end;

    // retrieve the top left position of a layer
    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);

    // process mask thumbnail
    RotateMaskCanvas(ADeg, ADirection);

    if FHasMask and FMaskLinked then
    begin
      ChangeAlphaChannelBySubMask(FAssociatedLayer.Bitmap,
                                  FLastAlphaChannelBmp,
                                  FMaskImage.Bitmap);
    end;
    
  finally
    LSrcBmp.Free;
  end;
end; 

procedure TgmGradientFillLayerPanel.CropImage(
  const AImageControl: TCustomImage32; const ACrop: TgmCrop;
  const ABackColor: TColor32);
var
  LNewWidth, LNewHeight: Integer;
  LOldWidth, LOldHeight: Integer;
  LTopLeft             : TPoint;
begin
  LOldWidth  := FAssociatedLayer.Bitmap.Width;
  LOldHeight := FAssociatedLayer.Bitmap.Height;

  if ACrop.IsResized then
  begin
    LNewWidth  := ACrop.ResizeW;
    LNewHeight := ACrop.ResizeH;
  end
  else
  begin
    LNewWidth  := ACrop.FCropEnd.X - ACrop.FCropStart.X;
    LNewHeight := ACrop.FCropEnd.Y - ACrop.FCropStart.Y;
  end;

  FAssociatedLayer.Bitmap.SetSize(LNewWidth, LNewHeight);

  FCenterPoint    := ScalePoint(FCenterPoint, LOldWidth, LOldHeight, LNewWidth, LNewHeight);
  FOriginalCenter := Point(LNewWidth div 2, LNewHeight div 2);
  FTranslateX     := MulDiv(FTranslateX, LNewWidth,  LOldWidth);
  FTranslateY     := MulDiv(FTranslateY, LNewHeight, LOldHeight);

  CalculateGradientCoord;
  SaveLastAdjustment;
  DrawGradientOnLayer;

  // retrieve the top left position of a layer
  LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

  FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                         AImageControl.Bitmap.Width,
                                         AImageControl.Bitmap.Height);
                                         
  // Process mask thumbnail.
  CropMask(ACrop);

  if FHasMask and FMaskLinked then
  begin
    ChangeAlphaChannelBySubMask(FAssociatedLayer.Bitmap,
                                FLastAlphaChannelBmp,
                                FMaskImage.Bitmap);
  end;
end;

function TgmGradientFillLayerPanel.DuplicateCurrentLayerPanel(
  const AOwner: TWinControl; const ALayers: TLayerCollection;
  const ALayerIndex: Integer; const ALayerName: string): TgmLayerPanel;
var
  LLayer                 : TBitmapLayer;
  LGradientFillLayerPanel: TgmGradientFillLayerPanel;
begin
  ALayers.Insert(ALayerIndex, TBitmapLayer);

  LLayer          := TBitmapLayer(ALayers.Items[ALayerIndex]);
  LLayer.Location := FAssociatedLayer.Location;
  LLayer.Scaled   := True;
  
  LLayer.Bitmap.Assign(FAssociatedLayer.Bitmap);
  LLayer.Bitmap.DrawMode := dmCustom;

  LGradientFillLayerPanel := TgmGradientFillLayerPanel.Create(AOwner, LLayer, nil);
  LGradientFillLayerPanel.IsDuplicated := True;

  LGradientFillLayerPanel.GradientThumbnail.Assign(Self.FGradientThumbnail);
  LGradientFillLayerPanel.Gradient.Assign(Self.FGradient);

  LGradientFillLayerPanel.Style          := Self.FStyle;
  LGradientFillLayerPanel.Angle          := Self.FAngle;
  LGradientFillLayerPanel.Scale          := Self.FScale;
  LGradientFillLayerPanel.TranslateX     := Self.FTranslateX;
  LGradientFillLayerPanel.TranslateY     := Self.FTranslateY;
  LGradientFillLayerPanel.IsReversed     := Self.FReversed;
  LGradientFillLayerPanel.StartPoint     := Self.FStartPoint;
  LGradientFillLayerPanel.EndPoint       := Self.FEndPoint;
  LGradientFillLayerPanel.CenterPoint    := Self.FCenterPoint;
  LGradientFillLayerPanel.OriginalCenter := Self.FOriginalCenter;
  LGradientFillLayerPanel.OriginalStart  := Self.FOriginalStart;
  LGradientFillLayerPanel.OriginalEnd    := Self.FOriginalEnd;

  LGradientFillLayerPanel.SaveLastAdjustment;

  LGradientFillLayerPanel.BlendModeIndex   := Self.FBlendModeIndex;
  LGradientFillLayerPanel.LayerMasterAlpha := Self.FLayerMasterAlpha;

  LGradientFillLayerPanel.SetLayerName(ALayerName);

{ Duplicate mask }
  LGradientFillLayerPanel.IsHasMask         := Self.FHasMask;
  LGradientFillLayerPanel.IsMaskLinked      := Self.FMaskLinked;
  LGradientFillLayerPanel.LayerProcessStage := Self.FLayerProcessStage;
  LGradientFillLayerPanel.PrevProcessStage  := Self.FPrevProcessStage;

  if LGradientFillLayerPanel.IsHasMask then
  begin
    LGradientFillLayerPanel.FMaskImage.Bitmap.Assign(Self.FMaskImage.Bitmap);
    LGradientFillLayerPanel.UpdateMaskThumbnail;

    // save Mask into layer's alpha channels
    LGradientFillLayerPanel.UpdateLayerAlphaWithMask;

    LGradientFillLayerPanel.ShowThumbnailByRightOrder;
  end;
  
  Result := LGradientFillLayerPanel;
end;

procedure TgmGradientFillLayerPanel.SaveLastAdjustment;
begin
  FLastGradient.Assign(FGradient);

  FLastStyle         := FStyle;
  FLastAngle         := FAngle;
  FLastScale         := FScale;
  FLastTranslateX    := FTranslateX;
  FLastTranslateY    := FTranslateY;
  FLastReversed      := FReversed;
  FLastStartPoint    := FStartPoint;
  FLastEndPoint      := FEndPoint;
  FLastCenterPoint   := FCenterPoint;
  FLastOriginalStart := FOriginalStart;
  FLastOriginalEnd   := FOriginalEnd;

  DrawGradientFillLayerThumbnail;
end; 

procedure TgmGradientFillLayerPanel.RestoreLastAdjustment;
begin
  FGradient.Assign(FLastGradient);

  FStyle         := FLastStyle;
  FAngle         := FLastAngle;
  FScale         := FLastScale;
  FTranslateX    := FLastTranslateX;
  FTranslateY    := FLastTranslateY;
  FReversed      := FLastReversed;
  FStartPoint    := FLastStartPoint;
  FEndPoint      := FLastEndPoint;
  FCenterPoint   := FLastCenterPoint;
  FOriginalStart := FLastOriginalStart;
  FOriginalEnd   := FLastOriginalEnd;
  
  DrawGradientOnLayer;
end;

// set up several properties with just one call
procedure TgmGradientFillLayerPanel.Setup(
  const ASettings: TgmGradientFillSettings);
begin
  FStyle          := ASettings.Style;
  FAngle          := ASettings.Angle;
  FScale          := ASettings.Scale;
  FTranslateX     := ASettings.TranslateX;
  FTranslateY     := ASettings.TranslateY;
  FReversed       := ASettings.Reversed;
  FStartPoint     := ASettings.StartPoint;
  FEndPoint       := ASettings.EndPoint;
  FCenterPoint    := ASettings.CenterPoint;
  FOriginalCenter := ASettings.OriginalCenter;
  FOriginalStart  := ASettings.OriginalStart;
  FOriginalEnd    := ASettings.OriginalEnd;
end;

// save the layer to a stream for output it to a '*gmd' file later
procedure TgmGradientFillLayerPanel.SaveToStream(const AStream: TStream);
var
  LLayerHeader   : TgmLayerHeaderVer1;
  i, LIntValue   : Integer;
  LByteMap       : TByteMap;
  LByteBits      : PByte;
  LGradientWriter: TgmGrdVer1_Writer;
  LColorValue    : TColor;
begin
  LLayerHeader.LayerName        := FLayerName.Caption;
  LLayerHeader.LayerFeature     := Ord(lfGradientFill);
  LLayerHeader.BlendModeIndex   := FBlendModeIndex;
  LLayerHeader.MasterAlpha      := FLayerMasterAlpha;
  LLayerHeader.Selected         := FSelected;
  LLayerHeader.Visible          := FLayerVisible;
  LLayerHeader.LockTransparency := FLockTransparency;
  LLayerHeader.Duplicated       := FDuplicated;
  LLayerHeader.HasMask          := FHasMask;
  LLayerHeader.MaskLinked       := FMaskLinked;

  // write the layer header to stream
  AStream.Write(LLayerHeader, SizeOf(TgmLayerHeaderVer1));

  // write the GradientFill data to stream
  LGradientWriter := TgmGrdVer1_Writer.Create;
  try
    LGradientWriter.SaveItemToStream(AStream, FGradient);
  finally
    LGradientWriter.Free;
  end;

  // save forground/background color of gradient
  LColorValue := FGradient.ForegroundColor;
  AStream.Write( LColorValue, SizeOf(TColor) );

  LColorValue := FGradient.BackgroundColor;
  AStream.Write( LColorValue, SizeOf(TColor) );

  LIntValue := Ord(FStyle);
  AStream.Write(LIntValue, 4);

  AStream.Write(FAngle, 4);
  AStream.Write(FScale, SizeOf(FScale));
  AStream.Write(FTranslateX, 4);
  AStream.Write(FTranslateY, 4);
  AStream.Write(FReversed, 1);

  AStream.Write(FStartPoint.X, 4);
  AStream.Write(FStartPoint.Y, 4);
  AStream.Write(FEndPoint.X, 4);
  AStream.Write(FEndPoint.Y, 4);
  AStream.Write(FCenterPoint.X, 4);
  AStream.Write(FCenterPoint.Y, 4);

  AStream.Write(FOriginalCenter.X, 4);
  AStream.Write(FOriginalCenter.Y, 4);
  AStream.Write(FOriginalStart.X, 4);
  AStream.Write(FOriginalStart.Y, 4);
  AStream.Write(FOriginalEnd.X, 4);
  AStream.Write(FOriginalEnd.Y, 4);

  // write the mask data to stream, if any
  if FHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      // write the mask data to stream
      LByteMap.SetSize(FMaskImage.Bitmap.Width, FMaskImage.Bitmap.Height);
      LByteMap.ReadFrom(FMaskImage.Bitmap, ctUniformRGB);

      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (FMaskImage.Bitmap.Height - 1) do
      begin
        AStream.Write(LByteBits^, FMaskImage.Bitmap.Width);
        Inc(LByteBits, FMaskImage.Bitmap.Width);
      end;
    finally
      LByteMap.Free;
    end;
  end;
end; 

//-- TgmBrightContrastLayerPanel -----------------------------------------------

constructor TgmBrightContrastLayerPanel.Create(const AOwner: TWinControl;
  const ALayer: TBitmapLayer);
begin
  inherited Create(AOwner, ALayer);

  FLayerImage.PaintStages[0].Stage := PST_CLEAR_BACKGND;
  FLayerFeature                    := lfBrightContrast;
  FHoldMaskInLayerAlpha            := True;

  if Assigned(FAssociatedLayer) then
  begin
    FAssociatedLayer.Bitmap.OnPixelCombine := LayerPixelBlend;
  end;

  FAdjustBrightness := 0;
  FAdjustContrast   := 0;
  FLastBrightness   := 0;
  FLastContrast     := 0;
  FPreview          := True;

  GMDataModule := TGMDataModule.Create(nil);
  try
    // get thumbnail for the Brightness/Contrast layer
    FLayerImage.Bitmap.Assign(GMDataModule.bmp32lstLayers.Bitmap[BRIGHT_CONTRAST_LAYER_ICON_INDEX]);
  finally
    FreeAndNil(GMDataModule)
  end;
end; 

procedure TgmBrightContrastLayerPanel.LayerPixelBlend(F: TColor32;
  var B: TColor32; M: TColor32);
var
  LForeColor: TColor32;
  LIntensity: Byte;
  LTemp     : Integer;
  LAlpha    : Byte;
begin
  { Preserve the alpha of the background, only change the RGB channels of it.
    In this case, we could create mask for the special layer correctly. }
  LAlpha := B shr 24 and $FF;

  if LAlpha > 0 then
  begin
    // adjust brightness first
    LForeColor := LayerBrightness(B, FAdjustBrightness);

    // adjust contrast after the brightness ajustment
    LForeColor := LayerContrast(LForeColor, FAdjustContrast);
    LForeColor := LForeColor and $FFFFFF;  // only need RGB components

    if FMaskLinked then
    begin
      { We already saved the mask info of this special layer into the alpha
        channel of each pixels on the layer. So we get the mask value for this
        pixel from its alpha channel.

        Important: Never change the alpha channel of F at here. }

      LIntensity := F shr 24 and $FF;
      LTemp      := LAlpha - (255 - LIntensity);

      if LTemp < 0 then
      begin
        LAlpha := 0;
      end
      else
      begin
        LAlpha := LTemp;
      end;
    end;

    LForeColor := (LAlpha shl 24) or LForeColor;
    
    // blending
    FBlendModeEvent(LForeColor, B, M);
  end;
end;

procedure TgmBrightContrastLayerPanel.ChangeImageSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AOptions: TgmResamplingOptions);
begin
  ResizeEffectLayer(AImageControl, ANewWidth, ANewHeight, AOptions);
end;

procedure TgmBrightContrastLayerPanel.ChangeCanvasSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AAnchor: TgmAnchorDirection; const ABackgroundColor: TColor32);
begin
  ChangeEffectLayerCanvasSize(AImageControl, ANewWidth, ANewHeight, AAnchor);
end;

procedure TgmBrightContrastLayerPanel.RotateCanvas(
  const AImageControl: TCustomImage32; const ADeg: Integer;
  const ADirection: TgmRotateDirection; const AResizeBackground: Boolean;
  const ABackColor: TColor32);
begin
  RotateEffectLayerCanvas(AImageControl, ADeg, ADirection, AResizeBackground);
end;

procedure TgmBrightContrastLayerPanel.CropImage(
  const AImageControl: TCustomImage32; const ACrop: TgmCrop;
  const ABackColor: TColor32);
begin
  CropEffectLayer(AImageControl, ACrop);
end;

function TgmBrightContrastLayerPanel.DuplicateCurrentLayerPanel(
  const AOwner: TWinControl; const ALayers: TLayerCollection;
  const ALayerIndex: Integer; const ALayerName: string): TgmLayerPanel;
var
  LLayer                   : TBitmapLayer;
  LBrightContrastLayerPanel: TgmBrightContrastLayerPanel;
begin
  ALayers.Insert(ALayerIndex, TBitmapLayer);

  LLayer          := TBitmapLayer(ALayers.Items[ALayerIndex]);
  LLayer.Location := FAssociatedLayer.Location;
  LLayer.Scaled   := True;
  
  LLayer.Bitmap.SetSize(FAssociatedLayer.Bitmap.Width,
                        FAssociatedLayer.Bitmap.Height);
                        
  LLayer.Bitmap.DrawMode := dmCustom;

  LBrightContrastLayerPanel                  := TgmBrightContrastLayerPanel.Create(AOwner, LLayer);
  LBrightContrastLayerPanel.IsDuplicated     := True;
  LBrightContrastLayerPanel.AdjustBrightness := Self.FAdjustBrightness;
  LBrightContrastLayerPanel.LastBrightness   := Self.FLastBrightness;
  LBrightContrastLayerPanel.AdjustContrast   := Self.FAdjustContrast;
  LBrightContrastLayerPanel.LastContrast     := Self.FLastContrast;
  LBrightContrastLayerPanel.BlendModeIndex   := Self.FBlendModeIndex;
  LBrightContrastLayerPanel.LayerMasterAlpha := Self.FLayerMasterAlpha;
  LBrightContrastLayerPanel.SetLayerName(ALayerName);

{ Duplicate mask }
  LBrightContrastLayerPanel.IsHasMask         := Self.FHasMask;
  LBrightContrastLayerPanel.IsMaskLinked      := Self.FMaskLinked;
  LBrightContrastLayerPanel.LayerProcessStage := Self.FLayerProcessStage;
  LBrightContrastLayerPanel.PrevProcessStage  := Self.FPrevProcessStage;

  if LBrightContrastLayerPanel.IsHasMask then
  begin
    LBrightContrastLayerPanel.FMaskImage.Bitmap.Assign(Self.FMaskImage.Bitmap);
    LBrightContrastLayerPanel.UpdateMaskThumbnail;

    // save Mask into layer's alpha channels
    LBrightContrastLayerPanel.UpdateLayerAlphaWithMask;

    LBrightContrastLayerPanel.ShowThumbnailByRightOrder;
  end;
  
  Result := LBrightContrastLayerPanel;
end;

procedure TgmBrightContrastLayerPanel.SaveLastAdjustment;
begin
  FLastBrightness := FAdjustBrightness;
  FLastContrast   := FAdjustContrast;
end;

procedure TgmBrightContrastLayerPanel.RestoreLastAdjustment;
begin
  FAdjustBrightness := FLastBrightness;
  FAdjustContrast   := FLastContrast;
end; 

// save the layer to a stream for output it to a '*gmd' file later
procedure TgmBrightContrastLayerPanel.SaveToStream(
  const AStream: TStream);
var
  LLayerHeader: TgmLayerHeaderVer1;
  i           : Integer;
  LByteMap    : TByteMap;
  LByteBits   : PByte;
begin
  LLayerHeader.LayerName        := FLayerName.Caption;
  LLayerHeader.LayerFeature     := Ord(lfBrightContrast);
  LLayerHeader.BlendModeIndex   := FBlendModeIndex;
  LLayerHeader.MasterAlpha      := FLayerMasterAlpha;
  LLayerHeader.Selected         := FSelected;
  LLayerHeader.Visible          := FLayerVisible;
  LLayerHeader.LockTransparency := FLockTransparency;
  LLayerHeader.Duplicated       := FDuplicated;
  LLayerHeader.HasMask          := FHasMask;
  LLayerHeader.MaskLinked       := FMaskLinked;

  // write the layer header to stream
  AStream.Write(LLayerHeader, SizeOf(TgmLayerHeaderVer1));

  // write the brightness/contrast data to stream
  AStream.Write(FAdjustBrightness, 4);
  AStream.Write(FAdjustContrast, 4);
  AStream.Write(FPreview, 1);

  // write the mask data to stream, if any
  if FHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      // write the mask data to stream
      LByteMap.SetSize(FMaskImage.Bitmap.Width, FMaskImage.Bitmap.Height);
      LByteMap.ReadFrom(FMaskImage.Bitmap, ctUniformRGB);

      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (FMaskImage.Bitmap.Height - 1) do
      begin
        AStream.Write(LByteBits^, FMaskImage.Bitmap.Width);
        Inc(LByteBits, FMaskImage.Bitmap.Width);
      end;
    finally
      LByteMap.Free;
    end;
  end;
end;

//-- TgmCurvesLayerPanel -----------------------------------------------------

constructor TgmCurvesLayerPanel.Create(const AOwner: TWinControl;
  const ALayer: TBitmapLayer);
begin
  inherited Create(AOwner, ALayer);

  FLayerImage.PaintStages[0].Stage := PST_CLEAR_BACKGND;
  FLayerFeature                    := lfCurves;
  FHoldMaskInLayerAlpha            := True;
  FPreview                         := True;

  if FAssociatedLayer <> nil then
  begin
    FAssociatedLayer.Bitmap.OnPixelCombine := LayerPixelBlend;
  end;

  GMDataModule := TGMDataModule.Create(nil);
  try
    // get thumbnail for the curves layer
    FLayerImage.Bitmap.Assign(GMDataModule.bmp32lstLayers.Bitmap[CURVES_LAYER_ICON_INDEX]);
  finally
    FreeAndNil(GMDataModule)
  end;

  FCurvesTool := TgmCurvesTool.Create(ALayer.Bitmap);
  FCurvesTool.LUTSetup(3);
  
  FLastCurvesTool := TgmCurvesTool.Create(ALayer.Bitmap);
  FLastCurvesTool.LUTSetup(3);

  FFlattenedLayer := TBitmap32.Create;
end;

destructor TgmCurvesLayerPanel.Destroy;
begin
  if FCurvesTool <> nil then
  begin
    FCurvesTool.Free;
  end;

  if FLastCurvesTool <> nil then
  begin
    FLastCurvesTool.Free;
  end;
  
  FFlattenedLayer.Free;
  
  inherited Destroy;
end;

procedure TgmCurvesLayerPanel.SetFlattenedLayer(const ABitmap: TBitmap32);
begin
  if FCurvesTool <> nil then
  begin
    FFlattenedLayer.Assign(ABitmap);
    FFlattenedLayer.DrawMode := dmBlend;
    FCurvesTool.Hist.gimp_histogram_calculate(FFlattenedLayer);
    FCurvesTool.Hist.gimp_histogram_view_expose(FCurvesTool.Channel);
  end;
end;

procedure TgmCurvesLayerPanel.LayerPixelBlend(F: TColor32; var B: TColor32;
  M: TColor32);
var
  LTemp     : Integer;
  LIntensity: Byte;
  LAlpha    : Byte;
  rr, gg, bb: Byte;
  LForeColor: TColor32;
begin
  { Preserve the alpha of the background, only change the RGB channels of it.
    In this case, we could create mask for the special layer correctly. }
  LAlpha := B shr 24 and $FF;

  if LAlpha > 0 then
  begin
    rr := B shr 16 and $FF;
    gg := B shr  8 and $FF;
    bb := B        and $FF;

    rr := FCurvesTool.LUT.luts[0, rr];
    gg := FCurvesTool.LUT.luts[1, gg];
    bb := FCurvesTool.LUT.luts[2, bb];

    if FMaskLinked then
    begin
      { We already saved the mask info of this special layer into the alpha
        channel of each pixels on the layer. So we get the mask value for this
        pixel from its alpha channel.

        Important: Never change the alpha channel of F at here. }

      LIntensity := F shr 24 and $FF;
      LTemp      := LAlpha - (255 - LIntensity);

      if LTemp < 0 then
      begin
        LAlpha := 0;
      end
      else
      begin
        LAlpha := LTemp;
      end;
    end;

    LForeColor := (LAlpha shl 24) or (rr shl 16) or (gg shl 8) or bb;

    // blending
    FBlendModeEvent(LForeColor, B, M);
  end;
end; 

procedure TgmCurvesLayerPanel.ChangeImageSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AOptions: TgmResamplingOptions);
begin
  ResizeEffectLayer(AImageControl, ANewWidth, ANewHeight, AOptions);
end;

procedure TgmCurvesLayerPanel.ChangeCanvasSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AAnchor: TgmAnchorDirection; const ABackgroundColor: TColor32);
begin
  ChangeEffectLayerCanvasSize(AImageControl, ANewWidth, ANewHeight, AAnchor);
end;

procedure TgmCurvesLayerPanel.RotateCanvas(
  const AImageControl: TCustomImage32; const ADeg: Integer;
  const ADirection: TgmRotateDirection; const AResizeBackground: Boolean;
  const ABackColor: TColor32);
begin
  RotateEffectLayerCanvas(AImageControl, ADeg, ADirection, AResizeBackground);
end;

procedure TgmCurvesLayerPanel.CropImage(const AImageControl: TCustomImage32;
  const ACrop: TgmCrop; const ABackColor: TColor32);
begin
  CropEffectLayer(AImageControl, ACrop);
end;

function TgmCurvesLayerPanel.DuplicateCurrentLayerPanel(
  const AOwner: TWinControl; const ALayers: TLayerCollection;
  const ALayerIndex: Integer; const ALayerName: string): TgmLayerPanel;
var
  i, j, k          : Integer;
  LLayer           : TBitmapLayer;
  LFlattenedBmp    : TBitmap32;
  LCurvesLayerPanel: TgmCurvesLayerPanel;
begin
  ALayers.Insert(ALayerIndex, TBitmapLayer);

  LLayer          := TBitmapLayer(ALayers.Items[ALayerIndex]);
  LLayer.Location := FAssociatedLayer.Location;
  LLayer.Scaled   := True;
  
  LLayer.Bitmap.SetSize(FAssociatedLayer.Bitmap.Width,
                        FAssociatedLayer.Bitmap.Height);

  LLayer.Bitmap.DrawMode         := dmCustom;
  LCurvesLayerPanel              := TgmCurvesLayerPanel.Create(AOwner, LLayer);
  LCurvesLayerPanel.IsDuplicated := True;

  LFlattenedBmp := TBitmap32.Create;
  try
    LFlattenedBmp.SetSize(FAssociatedLayer.Bitmap.Width,
                          FAssociatedLayer.Bitmap.Height);

    if ALayers.Count = 1 then
    begin
      LFlattenedBmp.Assign( TBitmapLayer(ALayers[0]) );
    end
    else
    if ALayers.Count > 1 then
    begin
      if Assigned(FPanelList) then
      begin
        FPanelList.FlattenLayersToBitmap(LFlattenedBmp, dmBlend, 0,
                                         FPanelList.CurrentIndex);
      end;
    end;

    LCurvesLayerPanel.FlattenedLayer := LFlattenedBmp;
  finally
    LFlattenedBmp.Free;
  end;

  for j := Low(FCurvesTool.LUT.luts) to High(FCurvesTool.LUT.luts) do
  begin
    for i := Low(FCurvesTool.LUT.luts[j]) to High(FCurvesTool.LUT.luts[j]) do
    begin
      LCurvesLayerPanel.CurvesTool.LUT.luts[j, i] := Self.FCurvesTool.LUT.luts[j, i];
    end;
  end;

  for i := 0 to 4 do
  begin
    LCurvesLayerPanel.CurvesTool.Curves.CurveType[i] := Self.FCurvesTool.Curves.CurveType[i];
  end;

  for i := 0 to 4 do
  begin
    for j := 0 to 16 do
    begin
      for k := 0 to 1 do
      begin
        LCurvesLayerPanel.CurvesTool.Curves.Points[i, j, k] := Self.FCurvesTool.Curves.Points[i, j, k];
      end;
    end;
  end;

  for i := 0 to 4 do
  begin
    for j := 0 to 255 do
    begin
      LCurvesLayerPanel.CurvesTool.Curves.FCurve[i, j] := Self.FCurvesTool.Curves.FCurve[i, j];
    end;
  end;

  LCurvesLayerPanel.CurvesTool.Channel   := Self.FCurvesTool.Channel;
  LCurvesLayerPanel.CurvesTool.Scale     := Self.FCurvesTool.Scale;
  LCurvesLayerPanel.CurvesTool.CurveType := Self.FCurvesTool.CurveType;

  LCurvesLayerPanel.SaveLastAdjustment;
  LCurvesLayerPanel.BlendModeIndex   := Self.FBlendModeIndex;
  LCurvesLayerPanel.LayerMasterAlpha := Self.FLayerMasterAlpha;
  LCurvesLayerPanel.SetLayerName(ALayerName);

{ Duplicate Mask }
  LCurvesLayerPanel.IsHasMask         := Self.FHasMask;
  LCurvesLayerPanel.IsMaskLinked      := Self.FMaskLinked;
  LCurvesLayerPanel.LayerProcessStage := Self.FLayerProcessStage;
  LCurvesLayerPanel.PrevProcessStage  := Self.FPrevProcessStage;

  if LCurvesLayerPanel.IsHasMask then
  begin
    LCurvesLayerPanel.FMaskImage.Bitmap.Assign(Self.FMaskImage.Bitmap);
    LCurvesLayerPanel.UpdateMaskThumbnail;

    // save Mask into layer's alpha channels
    LCurvesLayerPanel.UpdateLayerAlphaWithMask;

    LCurvesLayerPanel.ShowThumbnailByRightOrder;
  end;
  
  Result := LCurvesLayerPanel;
end;

procedure TgmCurvesLayerPanel.SaveLastAdjustment;
var
  i, j, k: Integer;
begin
  for j := Low(FCurvesTool.LUT.luts) to High(FCurvesTool.LUT.luts) do
  begin
    for i := Low(FCurvesTool.LUT.luts[j]) to High(FCurvesTool.LUT.luts[j]) do
    begin
      FLastCurvesTool.LUT.luts[j, i] := FCurvesTool.LUT.luts[j, i];
    end;
  end;

  for i := 0 to 4 do
  begin
    FLastCurvesTool.Curves.CurveType[i] := FCurvesTool.Curves.CurveType[i];
  end;

  for i := 0 to 4 do
  begin
    for j := 0 to 16 do
    begin
      for k := 0 to 1 do
      begin
        FLastCurvesTool.Curves.Points[i, j, k] := FCurvesTool.Curves.Points[i, j, k];
      end;
    end;
  end;

  for i := 0 to 4 do
  begin
    for j := 0 to 255 do
    begin
      FLastCurvesTool.Curves.FCurve[i, j] := FCurvesTool.Curves.FCurve[i, j];
    end;
  end;

  FLastCurvesTool.Channel   := FCurvesTool.Channel;
  FLastCurvesTool.Scale     := FCurvesTool.Scale;
  FLastCurvesTool.CurveType := FCurvesTool.CurveType;
end;

procedure TgmCurvesLayerPanel.RestoreLastAdjustment;
var
  i, j, k: Integer;
begin
  for j := Low(FLastCurvesTool.LUT.luts) to High(FLastCurvesTool.LUT.luts) do
  begin
    for i := Low(FLastCurvesTool.LUT.luts[j]) to High(FLastCurvesTool.LUT.luts[j]) do
    begin
      FCurvesTool.LUT.luts[j, i] := FLastCurvesTool.LUT.luts[j, i];
    end;
  end;
    
  for i := 0 to 4 do
  begin
    FCurvesTool.Curves.CurveType[i] := FLastCurvesTool.Curves.CurveType[i];
  end;

  for i := 0 to 4 do
  begin
    for j := 0 to 16 do
    begin
      for k := 0 to 1 do
      begin
        FCurvesTool.Curves.Points[i, j, k] := FLastCurvesTool.Curves.Points[i, j, k];
      end;
    end;
  end;

  for i := 0 to 4 do
  begin
    for j := 0 to 255 do
    begin
      FCurvesTool.Curves.FCurve[i, j] := FLastCurvesTool.Curves.FCurve[i, j];
    end;
  end;
    
  FCurvesTool.Channel   := FLastCurvesTool.Channel;
  FCurvesTool.Scale     := FLastCurvesTool.Scale;
  FCurvesTool.CurveType := FLastCurvesTool.CurveType;
end;

// save the layer to a stream for output it to a '*gmd' file later
procedure TgmCurvesLayerPanel.SaveToStream(const AStream: TStream);
var
  LLayerHeader: TgmLayerHeaderVer1;
  i           : Integer;
  LByteMap    : TByteMap;
  LByteBits   : PByte;
begin
  LLayerHeader.LayerName        := FLayerName.Caption;
  LLayerHeader.LayerFeature     := Ord(lfCurves);
  LLayerHeader.BlendModeIndex   := FBlendModeIndex;
  LLayerHeader.MasterAlpha      := FLayerMasterAlpha;
  LLayerHeader.Selected         := FSelected;
  LLayerHeader.Visible          := FLayerVisible;
  LLayerHeader.LockTransparency := FLockTransparency;
  LLayerHeader.Duplicated       := FDuplicated;
  LLayerHeader.HasMask          := FHasMask;
  LLayerHeader.MaskLinked       := FMaskLinked;

  // write the layer header to stream
  AStream.Write(LLayerHeader, SizeOf(TgmLayerHeaderVer1));

  // write the Curves data to stream
  FCurvesTool.SaveToStream(AStream);
  AStream.Write(FPreview, 1);

  // write the mask data to stream, if any
  if FHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      // write the mask data to stream
      LByteMap.SetSize(FMaskImage.Bitmap.Width, FMaskImage.Bitmap.Height);
      LByteMap.ReadFrom(FMaskImage.Bitmap, ctUniformRGB);

      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (FMaskImage.Bitmap.Height - 1) do
      begin
        AStream.Write(LByteBits^, FMaskImage.Bitmap.Width);
        Inc(LByteBits, FMaskImage.Bitmap.Width);
      end;
    finally
      LByteMap.Free;
    end;
  end;
end; 

//-- TgmLevelsLayerPanel -------------------------------------------------------

constructor TgmLevelsLayerPanel.Create(const AOwner: TWinControl;
  const ALayer: TBitmapLayer);
begin
  inherited Create(AOwner, ALayer);

  FLayerImage.PaintStages[0].Stage := PST_CLEAR_BACKGND;
  FLayerFeature                    := lfLevels;
  FHoldMaskInLayerAlpha            := True;

  if FAssociatedLayer <> nil then
  begin
    FAssociatedLayer.Bitmap.OnPixelCombine := LayerPixelBlend;
  end;

  GMDataModule := TGMDataModule.Create(nil);
  try
    // get thumbnail for the Levels layer
    FLayerImage.Bitmap.Assign(GMDataModule.bmp32lstLayers.Bitmap[LEVELS_LAYER_ICON_INDEX]);
  finally
    FreeAndNil(GMDataModule)
  end;

  FLevelsTool := TgmLevelsTool.Create(ALayer.Bitmap);
  FLevelsTool.LUTSetup(3);
  
  FLastLevelsTool := TgmLevelsTool.Create(ALayer.Bitmap);
  FLastLevelsTool.LUTSetup(3);

  FFlattenedLayer := TBitmap32.Create;
  FHistogramScale := GIMP_HISTOGRAM_SCALE_LINEAR;
  FPreview        := True;
end;

destructor TgmLevelsLayerPanel.Destroy;
begin
  if FLevelsTool <> nil then
  begin
    FLevelsTool.Free;
  end;

  if FLastLevelsTool <> nil then
  begin
    FLastLevelsTool.Free;
  end;
  
  FFlattenedLayer.Free;
  
  inherited Destroy;
end;

procedure TgmLevelsLayerPanel.SetFlattenedLayer(const ABitmap: TBitmap32);
begin
  FFlattenedLayer.Assign(ABitmap);
  FFlattenedLayer.DrawMode := dmBlend;
end; 

procedure TgmLevelsLayerPanel.LayerPixelBlend(F: TColor32; var B: TColor32;
  M: TColor32);
var
  LTemp     : Integer;
  LIntensity: Byte;
  LAlpha    : Byte;
  rr, gg, bb: Byte;
  LForeColor: TColor32;
begin
  { Preserve the alpha of the background, only change the RGB channels of it.
    In this case, we could create mask for the special layer correctly. }
  LAlpha := B shr 24 and $FF;

  if LAlpha > 0 then
  begin
    rr := B shr 16 and $FF;
    gg := B shr  8 and $FF;
    bb := B        and $FF;

    rr := FLevelsTool.LUT.luts[0, rr];
    gg := FLevelsTool.LUT.luts[1, gg];
    bb := FLevelsTool.LUT.luts[2, bb];

    if FMaskLinked then
    begin
      { We already saved the mask info of this special layer into the alpha
        channel of each pixels on the layer. So we get the mask value for this
        pixel from its alpha channel.

        Important: Never change the alpha channel of F at here. }

      LIntensity := F shr 24 and $FF;
      LTemp      := LAlpha - (255 - LIntensity);

      if LTemp < 0 then
      begin
        LAlpha := 0;
      end
      else
      begin
        LAlpha := LTemp;
      end;
    end;

    LForeColor := (LAlpha shl 24) or (rr shl 16) or (gg shl 8) or bb;

    // blending
    FBlendModeEvent(LForeColor, B, M);
  end;
end;

procedure TgmLevelsLayerPanel.ChangeImageSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AOptions: TgmResamplingOptions);
begin
  ResizeEffectLayer(AImageControl, ANewWidth, ANewHeight, AOptions);
end;

procedure TgmLevelsLayerPanel.ChangeCanvasSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AAnchor: TgmAnchorDirection; const ABackgroundColor: TColor32);
begin
  ChangeEffectLayerCanvasSize(AImageControl, ANewWidth, ANewHeight, AAnchor);
end; 

procedure TgmLevelsLayerPanel.RotateCanvas(const AImageControl: TCustomImage32;
  const ADeg: Integer; const ADirection: TgmRotateDirection;
  const AResizeBackground: Boolean; const ABackColor: TColor32);
begin
  RotateEffectLayerCanvas(AImageControl, ADeg, ADirection, AResizeBackground);
end;

procedure TgmLevelsLayerPanel.CropImage(const AImageControl: TCustomImage32;
  const ACrop: TgmCrop; const ABackColor: TColor32);
begin
  CropEffectLayer(AImageControl, ACrop);
end;

function TgmLevelsLayerPanel.DuplicateCurrentLayerPanel(
  const AOwner: TWinControl; const ALayers: TLayerCollection;
  const ALayerIndex: Integer; const ALayerName: string): TgmLayerPanel;
var
  i, j             : Integer;
  LLayer           : TBitmapLayer;
  LFlattenedBmp    : TBitmap32;
  LLevelsLayerPanel: TgmLevelsLayerPanel;
begin
  ALayers.Insert(ALayerIndex, TBitmapLayer);

  LLayer          := TBitmapLayer(ALayers.Items[ALayerIndex]);
  LLayer.Location := FAssociatedLayer.Location;
  LLayer.Scaled   := True;

  LLayer.Bitmap.SetSize(FAssociatedLayer.Bitmap.Width,
                        FAssociatedLayer.Bitmap.Height);

  LLayer.Bitmap.DrawMode         := dmCustom;
  LLevelsLayerPanel              := TgmLevelsLayerPanel.Create(AOwner, LLayer);
  LLevelsLayerPanel.IsDuplicated := True;

  LFlattenedBmp := TBitmap32.Create;
  try
    LFlattenedBmp.SetSize(FAssociatedLayer.Bitmap.Width,
                          FAssociatedLayer.Bitmap.Height);

    if ALayers.Count = 1 then
    begin
      LFlattenedBmp.Assign( TBitmapLayer(ALayers[0]) );
    end
    else
    if ALayers.Count > 1 then
    begin
      if Assigned(FPanelList) then
      begin
        FPanelList.FlattenLayersToBitmap(LFlattenedBmp, dmBlend, 0,
                                         FPanelList.CurrentIndex);
      end;
    end;

    LLevelsLayerPanel.FlattenedLayer := LFlattenedBmp;
  finally
    LFlattenedBmp.Free;
  end;

  for j := Low(FLevelsTool.LUT.luts) to High(FLevelsTool.LUT.luts) do
  begin
    for i := Low(FLevelsTool.LUT.luts[j]) to High(FLevelsTool.LUT.luts[j]) do
    begin
      LLevelsLayerPanel.LevelsTool.LUT.luts[j, i] := Self.FLevelsTool.LUT.luts[j, i];
    end;
  end;

  for i := 0 to 4 do
  begin
    LLevelsLayerPanel.LevelsTool.SliderPos[i]         := Self.FLevelsTool.SliderPos[i];
    LLevelsLayerPanel.LevelsTool.Levels.Gamma[i]      := Self.FLevelsTool.Levels.Gamma[i];
    LLevelsLayerPanel.LevelsTool.Levels.LowInput[i]   := Self.FLevelsTool.Levels.LowInput[i];
    LLevelsLayerPanel.LevelsTool.Levels.HighInput[i]  := Self.FLevelsTool.Levels.HighInput[i];
    LLevelsLayerPanel.LevelsTool.Levels.LowOutput[i]  := Self.FLevelsTool.Levels.LowOutput[i];
    LLevelsLayerPanel.LevelsTool.Levels.HighOutput[i] := Self.FLevelsTool.Levels.HighOutput[i];

    for j := 0 to 255 do
    begin
      LLevelsLayerPanel.LevelsTool.Levels.FInput[i, j] := Self.FLevelsTool.Levels.FInput[i, j];
    end;
  end;

  LLevelsLayerPanel.LevelsTool.Channel := Self.FLevelsTool.Channel;
  LLevelsLayerPanel.SaveLastAdjustment;

  LLevelsLayerPanel.BlendModeIndex   := Self.FBlendModeIndex;
  LLevelsLayerPanel.LayerMasterAlpha := Self.FLayerMasterAlpha;
  LLevelsLayerPanel.SetLayerName(ALayerName);

{ Duplicate Mask }
  LLevelsLayerPanel.IsHasMask         := Self.FHasMask;
  LLevelsLayerPanel.IsMaskLinked      := Self.FMaskLinked;
  LLevelsLayerPanel.LayerProcessStage := Self.FLayerProcessStage;
  LLevelsLayerPanel.PrevProcessStage  := Self.FPrevProcessStage;

  if LLevelsLayerPanel.IsHasMask then
  begin
    LLevelsLayerPanel.FMaskImage.Bitmap.Assign(Self.FMaskImage.Bitmap);
    LLevelsLayerPanel.UpdateMaskThumbnail;

    // save Mask into layer's alpha channels
    LLevelsLayerPanel.UpdateLayerAlphaWithMask;

    LLevelsLayerPanel.ShowThumbnailByRightOrder;
  end;
  
  Result := LLevelsLayerPanel;
end;

procedure TgmLevelsLayerPanel.SaveLastAdjustment;
var
  i, j: Integer;
begin
  for j := Low(FLevelsTool.LUT.luts) to High(FLevelsTool.LUT.luts) do
  begin
    for i := Low(FLevelsTool.LUT.luts[j]) to High(FLevelsTool.LUT.luts[j]) do
    begin
      FLastLevelsTool.LUT.luts[j, i] := FLevelsTool.LUT.luts[j, i];
    end;
  end;
    
  for i := 0 to 4 do
  begin
    FLastLevelsTool.SliderPos[i]         := FLevelsTool.SliderPos[i];
    FLastLevelsTool.Levels.Gamma[i]      := FLevelsTool.Levels.Gamma[i];
    FLastLevelsTool.Levels.LowInput[i]   := FLevelsTool.Levels.LowInput[i];
    FLastLevelsTool.Levels.HighInput[i]  := FLevelsTool.Levels.HighInput[i];
    FLastLevelsTool.Levels.LowOutput[i]  := FLevelsTool.Levels.LowOutput[i];
    FLastLevelsTool.Levels.HighOutput[i] := FLevelsTool.Levels.HighOutput[i];

    for j := 0 to 255 do
    begin
      FLastLevelsTool.Levels.FInput[i, j] := FLevelsTool.Levels.FInput[i, j];
    end;
  end;

  FLastLevelsTool.Channel := FLevelsTool.Channel;
end; 

procedure TgmLevelsLayerPanel.RestoreLastAdjustment;
var
  i, j: Integer;
begin
  for j := Low(FLevelsTool.LUT.luts) to High(FLevelsTool.LUT.luts) do
  begin
    for i := Low(FLevelsTool.LUT.luts[j]) to High(FLevelsTool.LUT.luts[j]) do
    begin
      FLevelsTool.LUT.luts[j, i] := FLastLevelsTool.LUT.luts[j, i];
    end;
  end;
    
  for i := 0 to 4 do
  begin
    FLevelsTool.SliderPos[i]         := FLastLevelsTool.SliderPos[i];
    FLevelsTool.Levels.Gamma[i]      := FLastLevelsTool.Levels.Gamma[i];
    FLevelsTool.Levels.LowInput[i]   := FLastLevelsTool.Levels.LowInput[i];
    FLevelsTool.Levels.HighInput[i]  := FLastLevelsTool.Levels.HighInput[i];
    FLevelsTool.Levels.LowOutput[i]  := FLastLevelsTool.Levels.LowOutput[i];
    FLevelsTool.Levels.HighOutput[i] := FLastLevelsTool.Levels.HighOutput[i];

    for j := 0 to 255 do
    begin
      FLevelsTool.Levels.FInput[i, j] := FLastLevelsTool.Levels.FInput[i, j];
    end;
  end;

  FLevelsTool.Channel := FLastLevelsTool.Channel;
end;

// save the layer to a stream for output it to a '*gmd' file later
procedure TgmLevelsLayerPanel.SaveToStream(const AStream: TStream);
var
  LLayerHeader: TgmLayerHeaderVer1;
  i, LScale   : Integer;
  LByteMap    : TByteMap;
  LByteBits   : PByte;
begin
  LLayerHeader.LayerName        := FLayerName.Caption;
  LLayerHeader.LayerFeature     := Ord(lfLevels);
  LLayerHeader.BlendModeIndex   := FBlendModeIndex;
  LLayerHeader.MasterAlpha      := FLayerMasterAlpha;
  LLayerHeader.Selected         := FSelected;
  LLayerHeader.Visible          := FLayerVisible;
  LLayerHeader.LockTransparency := FLockTransparency;
  LLayerHeader.Duplicated       := FDuplicated;
  LLayerHeader.HasMask          := FHasMask;
  LLayerHeader.MaskLinked       := FMaskLinked;

  // write the layer header to stream
  AStream.Write(LLayerHeader, SizeOf(TgmLayerHeaderVer1));

  // write the Levels data to stream
  FLevelsTool.SaveToStream(AStream);

  LScale := Ord(FHistogramScale);
  AStream.Write(LScale, 4);
  AStream.Write(FPreview, 1);

  // write the mask data to stream, if any
  if FHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      // write the mask data to stream
      LByteMap.SetSize(FMaskImage.Bitmap.Width, FMaskImage.Bitmap.Height);
      LByteMap.ReadFrom(FMaskImage.Bitmap, ctUniformRGB);

      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (FMaskImage.Bitmap.Height - 1) do
      begin
        AStream.Write(LByteBits^, FMaskImage.Bitmap.Width);
        Inc(LByteBits, FMaskImage.Bitmap.Width);
      end;
    finally
      LByteMap.Free;
    end;
  end;
end;

//-- TgmColorBalanceLayerPanel -------------------------------------------------

constructor TgmColorBalanceLayerPanel.Create(const AOwner: TWinControl;
  const ALayer: TBitmapLayer);
begin
  inherited Create(AOwner, ALayer);

  FLayerImage.PaintStages[0].Stage := PST_CLEAR_BACKGND;
  FLayerFeature                    := lfColorBalance;
  FHoldMaskInLayerAlpha            := True;

  if FAssociatedLayer <> nil then
  begin
    FAssociatedLayer.Bitmap.OnPixelCombine := LayerPixelBlend;
  end;

  FColorBalance     := TgmColorBalance.Create(ALayer.Bitmap);
  FLastColorBalance := TgmColorBalance.Create(ALayer.Bitmap);
  FPreview          := True;

  GMDataModule := TGMDataModule.Create(nil);
  try
    // get thumbnail for the Color Balance layer
    FLayerImage.Bitmap.Assign(GMDataModule.bmp32lstLayers.Bitmap[COLOR_BALANCE_LAYER_ICON_INDEX]);
  finally
    FreeAndNil(GMDataModule)
  end;
end;

destructor TgmColorBalanceLayerPanel.Destroy;
begin
  FColorBalance.Free;
  FLastColorBalance.Free;
end;

// Adjust color balance for single color.
function TgmColorBalanceLayerPanel.SingleColorBalance(
  const AColor: TColor32): TColor32;
var
  A         : Cardinal;
  H, L, S   : Integer;
  R, G, B   : Byte;
  rn, gn, bn: Byte;
begin
  // Reserve the Alpha channel of AColor.
  A := AColor shr 24 and $FF;

  // Extract the RGB values from AColor.
  R := AColor shr 16 and $FF;
  G := AColor shr  8 and $FF;
  B := AColor        and $FF;

  // Get the new RGB values.
  rn := FColorBalance.RedLookup[R];
  gn := FColorBalance.GreenLookup[G];
  bn := FColorBalance.BlueLookup[B];

  // Modify the RGB values of AColor.
  Result := (A shl 24) or (rn shl 16) or (gn shl 8) or bn;

  // If preserve the original alpha channel of AColor...
  if FColorBalance.PreserveLuminosity then
  begin
    RGBToHLS32(Result, H, L, S);
    S      := Clamp(S, 1, 255);
    L      := Clamp( RGBToLightness32(AColor), 0, 255 );
    Result := HLSToRGB32(A, H, L, S);
  end;
end;

procedure TgmColorBalanceLayerPanel.LayerPixelBlend(F: TColor32;
  var B: TColor32; M: TColor32);
var
  LForeColor: TColor32;
  LTemp     : Integer;
  LIntensity: Byte;
  LAlpha    : Byte;
begin
  { Preserve the alpha of the background, only change the RGB channels of it.
    In this case, we could create mask for the special layer correctly. }
  LAlpha := B shr 24 and $FF;

  if LAlpha > 0 then
  begin
    LForeColor := SingleColorBalance(B);
    LForeColor := LForeColor and $FFFFFF;  // only need RGB components

    if FMaskLinked then
    begin
      { We already saved the mask info of this special layer into the alpha
        channel of each pixels on the layer. So we get the mask value for this
        pixel from its alpha channel.

        Important: Never change the alpha channel of F at here. }

      LIntensity := F shr 24 and $FF;
      LTemp      := LAlpha - (255 - LIntensity);

      if LTemp < 0 then
      begin
        LAlpha := 0;
      end
      else
      begin
        LAlpha := LTemp;
      end;
    end;

    LForeColor := (LAlpha shl 24) or LForeColor;

    // blending
    FBlendModeEvent(LForeColor, B, M);
  end;
end;

procedure TgmColorBalanceLayerPanel.ChangeImageSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AOptions: TgmResamplingOptions);
begin
  ResizeEffectLayer(AImageControl, ANewWidth, ANewHeight, AOptions);
end;

procedure TgmColorBalanceLayerPanel.ChangeCanvasSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AAnchor: TgmAnchorDirection; const ABackgroundColor: TColor32);
begin
  ChangeEffectLayerCanvasSize(AImageControl, ANewWidth, ANewHeight, AAnchor);
end;

procedure TgmColorBalanceLayerPanel.RotateCanvas(
  const AImageControl: TCustomImage32; const ADeg: Integer;
  const ADirection: TgmRotateDirection; const AResizeBackground: Boolean;
  const ABackColor: TColor32);
begin
  RotateEffectLayerCanvas(AImageControl, ADeg, ADirection, AResizeBackground);
end;

procedure TgmColorBalanceLayerPanel.CropImage(
  const AImageControl: TCustomImage32; const ACrop: TgmCrop;
  const ABackColor: TColor32);
begin
  CropEffectLayer(AImageControl, ACrop);
end;

function TgmColorBalanceLayerPanel.DuplicateCurrentLayerPanel(
  const AOwner: TWinControl; const ALayers: TLayerCollection;
  const ALayerIndex: Integer; const ALayerName: string): TgmLayerPanel;
var
  i                      : Integer;
  LLayer                 : TBitmapLayer;
  LColorBalanceLayerPanel: TgmColorBalanceLayerPanel;
begin
  ALayers.Insert(ALayerIndex, TBitmapLayer);

  LLayer          := TBitmapLayer(ALayers.Items[ALayerIndex]);
  LLayer.Location := FAssociatedLayer.Location;
  LLayer.Scaled   := True;

  LLayer.Bitmap.SetSize(FAssociatedLayer.Bitmap.Width,
                        FAssociatedLayer.Bitmap.Height);
                        
  LLayer.Bitmap.DrawMode := dmCustom;

  LColorBalanceLayerPanel := TgmColorBalanceLayerPanel.Create(AOwner, LLayer);
  LColorBalanceLayerPanel.IsDuplicated := True;

  for i := 0 to 255 do
  begin
    LColorBalanceLayerPanel.ColorBalance.RedLookup[i]   := Self.FColorBalance.RedLookup[i];
    LColorBalanceLayerPanel.ColorBalance.GreenLookup[i] := Self.FColorBalance.GreenLookup[i];
    LColorBalanceLayerPanel.ColorBalance.BlueLookup[i]  := Self.FColorBalance.BlueLookup[i];

    LColorBalanceLayerPanel.LastColorBalance.RedLookup[i]   := Self.FLastColorBalance.RedLookup[i];
    LColorBalanceLayerPanel.LastColorBalance.GreenLookup[i] := Self.FLastColorBalance.GreenLookup[i];
    LColorBalanceLayerPanel.LastColorBalance.BlueLookup[i]  := Self.FLastColorBalance.BlueLookup[i];
  end;

  for i := 0 to 2 do
  begin
    LColorBalanceLayerPanel.ColorBalance.CyanRedArray[i]      := Self.FColorBalance.CyanRedArray[i];
    LColorBalanceLayerPanel.ColorBalance.MagentaGreenArray[i] := Self.FColorBalance.MagentaGreenArray[i];
    LColorBalanceLayerPanel.ColorBalance.YellowBlueArray[i]   := Self.FColorBalance.YellowBlueArray[i];

    LColorBalanceLayerPanel.LastColorBalance.CyanRedArray[i]      := Self.LastColorBalance.CyanRedArray[i];
    LColorBalanceLayerPanel.LastColorBalance.MagentaGreenArray[i] := Self.LastColorBalance.MagentaGreenArray[i];
    LColorBalanceLayerPanel.LastColorBalance.YellowBlueArray[i]   := Self.LastColorBalance.YellowBlueArray[i];
  end;

  LColorBalanceLayerPanel.ColorBalance.PreserveLuminosity     := Self.FColorBalance.PreserveLuminosity;
  LColorBalanceLayerPanel.LastColorBalance.PreserveLuminosity := Self.FLastColorBalance.PreserveLuminosity;
  LColorBalanceLayerPanel.ColorBalance.TransferMode           := Self.FColorBalance.TransferMode;
  LColorBalanceLayerPanel.LastColorBalance.TransferMode       := Self.FLastColorBalance.TransferMode;

  LColorBalanceLayerPanel.BlendModeIndex     := Self.FBlendModeIndex;
  LColorBalanceLayerPanel.LayerMasterAlpha   := Self.FLayerMasterAlpha;
  LColorBalanceLayerPanel.SetLayerName(ALayerName);

{ Duplicate mask }
  LColorBalanceLayerPanel.IsHasMask         := Self.FHasMask;
  LColorBalanceLayerPanel.IsMaskLinked      := Self.FMaskLinked;
  LColorBalanceLayerPanel.LayerProcessStage := Self.FLayerProcessStage;
  LColorBalanceLayerPanel.PrevProcessStage  := Self.FPrevProcessStage;

  if LColorBalanceLayerPanel.IsHasMask then
  begin
    LColorBalanceLayerPanel.FMaskImage.Bitmap.Assign(Self.FMaskImage.Bitmap);
    LColorBalanceLayerPanel.UpdateMaskThumbnail;

    // save Mask into layer's alpha channels
    LColorBalanceLayerPanel.UpdateLayerAlphaWithMask;

    LColorBalanceLayerPanel.ShowThumbnailByRightOrder;
  end;
  
  Result := LColorBalanceLayerPanel;
end; 

procedure TgmColorBalanceLayerPanel.SaveLastAdjustment;
var
  i: Integer;
begin
  for i := 0 to 2 do
  begin
    FLastColorBalance.CyanRedArray[i]      := FColorBalance.CyanRedArray[i];
    FLastColorBalance.MagentaGreenArray[i] := FColorBalance.MagentaGreenArray[i];
    FLastColorBalance.YellowBlueArray[i]   := FColorBalance.YellowBlueArray[i];
  end;

  for i := 0 to 255 do
  begin
    FLastColorBalance.RedLookup[i]   := FColorBalance.RedLookup[i];
    FLastColorBalance.GreenLookup[i] := FColorBalance.GreenLookup[i];
    FLastColorBalance.BlueLookup[i]  := FColorBalance.BlueLookup[i];
  end;
  
  FLastColorBalance.PreserveLuminosity := FColorBalance.PreserveLuminosity;
  FLastColorBalance.TransferMode       := FColorBalance.TransferMode;
end; 

procedure TgmColorBalanceLayerPanel.RestoreLastAdjustment;
var
  i: Integer;
begin
  for i := 0 to 2 do
  begin
    FColorBalance.CyanRedArray[i]      := FLastColorBalance.CyanRedArray[i];
    FColorBalance.MagentaGreenArray[i] := FLastColorBalance.MagentaGreenArray[i];
    FColorBalance.YellowBlueArray[i]   := FLastColorBalance.YellowBlueArray[i];
  end;

  for i := 0 to 255 do
  begin
    FColorBalance.RedLookup[i]   := FLastColorBalance.RedLookup[i];
    FColorBalance.GreenLookup[i] := FLastColorBalance.GreenLookup[i];
    FColorBalance.BlueLookup[i]  := FLastColorBalance.BlueLookup[i];
  end;
  
  FColorBalance.PreserveLuminosity := FLastColorBalance.PreserveLuminosity;
  FColorBalance.TransferMode       := FLastColorBalance.TransferMode;
end;

// save the layer to a stream for output it to a '*gmd' file later
procedure TgmColorBalanceLayerPanel.SaveToStream(const AStream: TStream);
var
  LLayerHeader: TgmLayerHeaderVer1;
  i           : Integer;
  LByteMap    : TByteMap;
  LByteBits   : PByte;
begin
  LLayerHeader.LayerName        := FLayerName.Caption;
  LLayerHeader.LayerFeature     := Ord(lfColorBalance);
  LLayerHeader.BlendModeIndex   := FBlendModeIndex;
  LLayerHeader.MasterAlpha      := FLayerMasterAlpha;
  LLayerHeader.Selected         := FSelected;
  LLayerHeader.Visible          := FLayerVisible;
  LLayerHeader.LockTransparency := FLockTransparency;
  LLayerHeader.Duplicated       := FDuplicated;
  LLayerHeader.HasMask          := FHasMask;
  LLayerHeader.MaskLinked       := FMaskLinked;

  // write the layer header to stream
  AStream.Write(LLayerHeader, SizeOf(TgmLayerHeaderVer1));

  // write the color balance data to stream
  FColorBalance.SaveToStream(AStream);
  AStream.Write(FPreview, 1);

  // write the mask data to stream, if any
  if FHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      // write the mask data to stream
      LByteMap.SetSize(FMaskImage.Bitmap.Width, FMaskImage.Bitmap.Height);
      LByteMap.ReadFrom(FMaskImage.Bitmap, ctUniformRGB);

      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (FMaskImage.Bitmap.Height - 1) do
      begin
        AStream.Write(LByteBits^, FMaskImage.Bitmap.Width);
        Inc(LByteBits, FMaskImage.Bitmap.Width);
      end;
    finally
      LByteMap.Free;
    end;
  end;
end; 

//-- TgmHueSaturationLayerPanel ------------------------------------------------

constructor TgmHueSaturationLayerPanel.Create(const AOwner: TWinControl;
  const ALayer: TBitmapLayer);
begin
  inherited Create(AOwner, ALayer);

  FLayerImage.PaintStages[0].Stage := PST_CLEAR_BACKGND;
  FLayerFeature                    := lfHLSOrHSV;
  FHoldMaskInLayerAlpha            := True;

  if FAssociatedLayer <> nil then
  begin
    FAssociatedLayer.Bitmap.OnPixelCombine := LayerPixelBlend;
  end;

  FChangedH        := 0;
  FChangedLOrV     := 0;
  FChangedS        := 0;
  FAdjustMode      := hsamHSL;
  FPreview         := True;
  FLastAdjustMode  := FAdjustMode;
  FLastChangedH    := 0;
  FLastChangedLOrV := 0;
  FLastChangedS    := 0;

  GMDataModule := TGMDataModule.Create(nil);
  try
    // get thumbnail for the Hue/Saturation layer
    FLayerImage.Bitmap.Assign(GMDataModule.bmp32lstLayers.Bitmap[HLS_LAYER_ICON_INDEX]);
  finally
    FreeAndNil(GMDataModule)
  end;
end;

procedure TgmHueSaturationLayerPanel.LayerPixelBlend(F: TColor32;
  var B: TColor32; M: TColor32);
var
  LTemp     : Integer;
  LForeColor: TColor32;
  LIntensity: Byte;
  LAlpha    : Byte;
begin
  LForeColor := $0;

  { Preserve the alpha of the background, only change the RGB channels of it.
    In this case, we could create mask for the special layer correctly. }
  LAlpha := B shr 24 and $FF;

  if LAlpha > 0 then
  begin
    case FAdjustMode of
      hsamHSL:
        begin
          LForeColor := LayerHLS(B, FChangedH, FChangedLOrV, FChangedS);
        end;
        
      hsamHSV:
        begin
          LForeColor := LayerHSV(B, FChangedH, FChangedS,    FChangedLOrV);
        end;
    end;

    LForeColor := LForeColor and $FFFFFF;  // only need RGB components

    if FMaskLinked then
    begin
      { We already saved the mask info of this special layer into the alpha
        channel of each pixels on the layer. So we get the mask value for this
        pixel from its alpha channel.

        Important: Never change the alpha channel of F at here. }

      LIntensity := F shr 24 and $FF;
      LTemp      := LAlpha - (255 - LIntensity);

      if LTemp < 0 then
      begin
        LAlpha := 0;
      end
      else
      begin
        LAlpha := LTemp;
      end;
    end;

    LForeColor := (LAlpha shl 24) or LForeColor;

    // blending
    FBlendModeEvent(LForeColor, B, M);
  end;
end;

procedure TgmHueSaturationLayerPanel.ChangeImageSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AOptions: TgmResamplingOptions);
begin
  ResizeEffectLayer(AImageControl, ANewWidth, ANewHeight, AOptions);
end;

procedure TgmHueSaturationLayerPanel.ChangeCanvasSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AAnchor: TgmAnchorDirection; const ABackgroundColor: TColor32);
begin
  ChangeEffectLayerCanvasSize(AImageControl, ANewWidth, ANewHeight, AAnchor);
end;

procedure TgmHueSaturationLayerPanel.RotateCanvas(
  const AImageControl: TCustomImage32; const ADeg: Integer;
  const ADirection: TgmRotateDirection; const AResizeBackground: Boolean;
  const ABackColor: TColor32);
begin
  RotateEffectLayerCanvas(AImageControl, ADeg, ADirection, AResizeBackground);
end; 

procedure TgmHueSaturationLayerPanel.CropImage(
  const AImageControl: TCustomImage32; const ACrop: TgmCrop;
  const ABackColor: TColor32);
begin
  CropEffectLayer(AImageControl, ACrop);
end;

function TgmHueSaturationLayerPanel.DuplicateCurrentLayerPanel(
  const AOwner: TWinControl; const ALayers: TLayerCollection;
  const ALayerIndex: Integer; const ALayerName: string): TgmLayerPanel;
var
  LLayer                  : TBitmapLayer;
  LHueSaturationLayerPanel: TgmHueSaturationLayerPanel;
begin
  ALayers.Insert(ALayerIndex, TBitmapLayer);

  LLayer          := TBitmapLayer(ALayers.Items[ALayerIndex]);
  LLayer.Location := FAssociatedLayer.Location;
  LLayer.Scaled   := True;

  LLayer.Bitmap.SetSize(FAssociatedLayer.Bitmap.Width,
                        FAssociatedLayer.Bitmap.Height);
                        
  LLayer.Bitmap.DrawMode := dmCustom;

  LHueSaturationLayerPanel := TgmHueSaturationLayerPanel.Create(AOwner, LLayer);
  LHueSaturationLayerPanel.IsDuplicated := True;
  LHueSaturationLayerPanel.ChangedH     := Self.FLastChangedH;
  LHueSaturationLayerPanel.ChangedLOrV  := Self.FLastChangedLOrV;
  LHueSaturationLayerPanel.ChangedS     := Self.FLastChangedS;
  LHueSaturationLayerPanel.AdjustMode   := Self.FAdjustMode;
  LHueSaturationLayerPanel.SaveLastAdjustment;

  LHueSaturationLayerPanel.BlendModeIndex   := Self.FBlendModeIndex;
  LHueSaturationLayerPanel.LayerMasterAlpha := Self.FLayerMasterAlpha;
  LHueSaturationLayerPanel.SetLayerName(ALayerName);

{ Duplicate mask }
  LHueSaturationLayerPanel.IsHasMask         := Self.FHasMask;
  LHueSaturationLayerPanel.IsMaskLinked      := Self.FMaskLinked;
  LHueSaturationLayerPanel.LayerProcessStage := Self.FLayerProcessStage;
  LHueSaturationLayerPanel.PrevProcessStage  := Self.FPrevProcessStage;

  if LHueSaturationLayerPanel.IsHasMask then
  begin
    LHueSaturationLayerPanel.FMaskImage.Bitmap.Assign(Self.FMaskImage.Bitmap);
    LHueSaturationLayerPanel.UpdateMaskThumbnail;

    // save Mask into layer's alpha channels
    LHueSaturationLayerPanel.UpdateLayerAlphaWithMask;

    LHueSaturationLayerPanel.ShowThumbnailByRightOrder;
  end;
  
  Result := LHueSaturationLayerPanel;
end; 

procedure TgmHueSaturationLayerPanel.SaveLastAdjustment;
begin
  FLastChangedH    := FChangedH;
  FLastChangedLOrV := FChangedLOrV;
  FLastChangedS    := FChangedS;
  FLastAdjustMode  := FAdjustMode;
end;

procedure TgmHueSaturationLayerPanel.RestoreLastAdjustment;
begin
  FChangedH    := FLastChangedH;
  FChangedLOrV := FLastChangedLOrV;
  FChangedS    := FLastChangedS;
  FAdjustMode  := FLastAdjustMode;
end;

// save the layer to a stream for output it to a '*gmd' file later
procedure TgmHueSaturationLayerPanel.SaveToStream(const AStream: TStream);
var
  LLayerHeader: TgmLayerHeaderVer1;
  i, LMode    : Integer;
  LByteMap    : TByteMap;
  LByteBits   : PByte;
begin
  LLayerHeader.LayerName        := FLayerName.Caption;
  LLayerHeader.LayerFeature     := Ord(lfHLSOrHSV);
  LLayerHeader.BlendModeIndex   := FBlendModeIndex;
  LLayerHeader.MasterAlpha      := FLayerMasterAlpha;
  LLayerHeader.Selected         := FSelected;
  LLayerHeader.Visible          := FLayerVisible;
  LLayerHeader.LockTransparency := FLockTransparency;
  LLayerHeader.Duplicated       := FDuplicated;
  LLayerHeader.HasMask          := FHasMask;
  LLayerHeader.MaskLinked       := FMaskLinked;

  // write the layer header to stream
  AStream.Write(LLayerHeader, SizeOf(TgmLayerHeaderVer1));

  // write the HLS/HSV data to stream
  AStream.Write(FChangedH,    4);
  AStream.Write(FChangedLOrV, 4);
  AStream.Write(FChangedS,    4);

  LMode := Ord(FAdjustMode);

  AStream.Write(LMode, 4);
  AStream.Write(FPreview, 1);

  // write the mask data to stream, if any
  if FHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      // write the mask data to stream
      LByteMap.SetSize(FMaskImage.Bitmap.Width, FMaskImage.Bitmap.Height);
      LByteMap.ReadFrom(FMaskImage.Bitmap, ctUniformRGB);

      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (FMaskImage.Bitmap.Height - 1) do
      begin
        AStream.Write(LByteBits^, FMaskImage.Bitmap.Width);
        Inc(LByteBits, FMaskImage.Bitmap.Width);
      end;
    finally
      LByteMap.Free;
    end;
  end;
end; 

//-- TgmChannelMixerLayerPanel -------------------------------------------------

constructor TgmChannelMixerLayerPanel.Create(const AOwner: TWinControl;
  const ALayer: TBitmapLayer);
begin
  inherited Create(AOwner, ALayer);

  FLayerFeature                    := lfChannelMixer;
  FHoldMaskInLayerAlpha            := True;
  FLayerImage.PaintStages[0].Stage := PST_CLEAR_BACKGND;

  if FAssociatedLayer <> nil then
  begin
    FAssociatedLayer.Bitmap.OnPixelCombine := LayerPixelBlend;
  end;

  GMDataModule := TGMDataModule.Create(nil);
  try
    // get thumbnail for the Channel Mixer layer
    FLayerImage.Bitmap.Assign(GMDataModule.bmp32lstLayers.Bitmap[CHANNEL_MIXER_LAYER_ICON_INDEX]);
  finally
    FreeAndNil(GMDataModule)
  end;
  
  FChannelMixer     := TgmChannelMixer.Create;
  FLastChannelMixer := TgmChannelMixer.Create;
  FPreview          := True;
  FLastPreview      := True;
end;

destructor TgmChannelMixerLayerPanel.Destroy;
begin
  FChannelMixer.Free;
  FLastChannelMixer.Free;
  
  inherited Destroy;
end;

procedure TgmChannelMixerLayerPanel.LayerPixelBlend(F: TColor32;
  var B: TColor32; M: TColor32);
var
  LTemp     : Integer;
  LAlpha    : Byte;
  LIntensity: Byte;
  LForeColor: TColor32;
begin
  { Preserve the alpha of the background, only change the RGB channels of it.
    In this case, we could create mask for the special layer correctly. }
  LAlpha := B shr 24 and $FF;

  if LAlpha > 0 then
  begin
    FChannelMixer.InputColor := B;
    LForeColor               := FChannelMixer.OutputColor;
    LForeColor               := LForeColor and $FFFFFF;  // only need RGB components

    if FMaskLinked then
    begin
      { We already saved the mask info of this special layer into the alpha
        channel of each pixels on the layer. So we get the mask value for this
        pixel from its alpha channel.

        Important: Never change the alpha channel of F at here. }

      LIntensity := F shr 24 and $FF;
      LTemp      := LAlpha - (255 - LIntensity);

      if LTemp < 0 then
      begin
        LAlpha := 0;
      end
      else
      begin
        LAlpha := LTemp;
      end;
    end;

    LForeColor := (LAlpha shl 24) or LForeColor;

    // blending
    FBlendModeEvent(LForeColor, B, M);
  end;
end;

procedure TgmChannelMixerLayerPanel.SaveLastAdjustment;
begin
  FLastChannelMixer.AssignData(FChannelMixer);
  FLastPreview := FPreview;
end;

procedure TgmChannelMixerLayerPanel.RestoreLastAdjustment;
begin
  FChannelMixer.AssignData(FLastChannelMixer);
  FPreview := FLastPreview;
end;

procedure TgmChannelMixerLayerPanel.ChangeImageSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AOptions: TgmResamplingOptions);
begin
  ResizeEffectLayer(AImageControl, ANewWidth, ANewHeight, AOptions);
end;

procedure TgmChannelMixerLayerPanel.ChangeCanvasSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AAnchor: TgmAnchorDirection; const ABackgroundColor: TColor32);
begin
  ChangeEffectLayerCanvasSize(AImageControl, ANewWidth, ANewHeight, AAnchor);
end;

procedure TgmChannelMixerLayerPanel.RotateCanvas(
  const AImageControl: TCustomImage32; const ADeg: Integer;
  const ADirection: TgmRotateDirection; const AResizeBackground: Boolean;
  const ABackColor: TColor32);
begin
  RotateEffectLayerCanvas(AImageControl, ADeg, ADirection, AResizeBackground);
end;

procedure TgmChannelMixerLayerPanel.CropImage(
  const AImageControl: TCustomImage32; const ACrop: TgmCrop;
  const ABackColor: TColor32);
begin
  CropEffectLayer(AImageControl, ACrop);
end; 

function TgmChannelMixerLayerPanel.DuplicateCurrentLayerPanel(
  const AOwner: TWinControl; const ALayers: TLayerCollection;
  const ALayerIndex: Integer; const ALayerName: string): TgmLayerPanel;
var
  LLayer                 : TBitmapLayer;
  LChannelMixerLayerPanel: TgmChannelMixerLayerPanel;
begin
  ALayers.Insert(ALayerIndex, TBitmapLayer);

  LLayer          := TBitmapLayer(ALayers.Items[ALayerIndex]);
  LLayer.Location := FAssociatedLayer.Location;
  LLayer.Scaled   := True;
  
  LLayer.Bitmap.SetSize(FAssociatedLayer.Bitmap.Width,
                        FAssociatedLayer.Bitmap.Height);
                        
  LLayer.Bitmap.DrawMode := dmCustom;

  LChannelMixerLayerPanel := TgmChannelMixerLayerPanel.Create(AOwner, LLayer);
  LChannelMixerLayerPanel.IsDuplicated     := True;
  LChannelMixerLayerPanel.BlendModeIndex   := Self.FBlendModeIndex;
  LChannelMixerLayerPanel.LayerMasterAlpha := Self.FLayerMasterAlpha;
  LChannelMixerLayerPanel.FPreview         := Self.FPreview;
  LChannelMixerLayerPanel.FLastPreview     := Self.FLastPreview;

  LChannelMixerLayerPanel.SetLayerName(ALayerName);
  LChannelMixerLayerPanel.ChannelMixer.AssignData(Self.FChannelMixer);
  LChannelMixerLayerPanel.LastChannelMixer.AssignData(Self.FLastChannelMixer);

{ Duplicate mask }
  LChannelMixerLayerPanel.IsHasMask         := Self.FHasMask;
  LChannelMixerLayerPanel.IsMaskLinked      := Self.FMaskLinked;
  LChannelMixerLayerPanel.LayerProcessStage := Self.FLayerProcessStage;
  LChannelMixerLayerPanel.PrevProcessStage  := Self.FPrevProcessStage;

  if LChannelMixerLayerPanel.IsHasMask then
  begin
    LChannelMixerLayerPanel.FMaskImage.Bitmap.Assign(Self.FMaskImage.Bitmap);
    LChannelMixerLayerPanel.UpdateMaskThumbnail;

    // save Mask into layer's alpha channels
    LChannelMixerLayerPanel.UpdateLayerAlphaWithMask;

    LChannelMixerLayerPanel.ShowThumbnailByRightOrder;
  end;
  
  Result := LChannelMixerLayerPanel;
end; 

// save the layer to a stream for output it to a '*gmd' file later
procedure TgmChannelMixerLayerPanel.SaveToStream(const AStream: TStream);
var
  LLayerHeader: TgmLayerHeaderVer1;
  i           : Integer;
  LByteMap    : TByteMap;
  LByteBits   : PByte;
begin
  LLayerHeader.LayerName        := FLayerName.Caption;
  LLayerHeader.LayerFeature     := Ord(lfChannelMixer);
  LLayerHeader.BlendModeIndex   := FBlendModeIndex;
  LLayerHeader.MasterAlpha      := FLayerMasterAlpha;
  LLayerHeader.Selected         := FSelected;
  LLayerHeader.Visible          := FLayerVisible;
  LLayerHeader.LockTransparency := FLockTransparency;
  LLayerHeader.Duplicated       := FDuplicated;
  LLayerHeader.HasMask          := FHasMask;
  LLayerHeader.MaskLinked       := FMaskLinked;

  // write the layer header to stream
  AStream.Write(LLayerHeader, SizeOf(TgmLayerHeaderVer1));

  // write the channel mixer data to stream
  FChannelMixer.SaveToStream(AStream);
  AStream.Write(FPreview, 1);

  // write the mask data to stream, if any
  if FHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      // write the mask data to stream
      LByteMap.SetSize(FMaskImage.Bitmap.Width, FMaskImage.Bitmap.Height);
      LByteMap.ReadFrom(FMaskImage.Bitmap, ctUniformRGB);

      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (FMaskImage.Bitmap.Height - 1) do
      begin
        AStream.Write(LByteBits^, FMaskImage.Bitmap.Width);
        Inc(LByteBits, FMaskImage.Bitmap.Width);
      end;
    finally
      LByteMap.Free;
    end;
  end;
end;

//-- TgmGradientMapLayerPanel --------------------------------------------------

constructor TgmGradientMapLayerPanel.Create(const AOwner: TWinControl;
  const ALayer: TBitmapLayer; const AGradient: TgmGradientItem);
begin
  inherited Create(AOwner, ALayer);

  FLayerImage.PaintStages[0].Stage := PST_CLEAR_BACKGND;
  FLayerFeature                    := lfGradientMap;
  FHoldMaskInLayerAlpha            := True;

  if FAssociatedLayer <> nil then
  begin
    FAssociatedLayer.Bitmap.OnPixelCombine := LayerPixelBlend;
  end;

  GMDataModule := TGMDataModule.Create(nil);
  try
    // get thumbnail for the Gradient Map layer
    FLayerImage.Bitmap.Assign(GMDataModule.bmp32lstLayers.Bitmap[GRADIENT_MAP_LAYER_ICON_INDEX]);
  finally
    FreeAndNil(GMDataModule)
  end;

  FGradient := TgmGradientItem.Create(nil);
  if Assigned(AGradient) then
  begin
    FGradient.Assign(AGradient);
  end;
  
  FGradient.GradientLength := 256;
  FGradient.RefreshColorArray;

  FLastGradient := TgmGradientItem.Create(nil);
  FLastGradient.Assign(FGradient);
  
  FReversed     := False;
  FLastReversed := FReversed;
  FPreview      := True;
end; 

destructor TgmGradientMapLayerPanel.Destroy;
begin
  FGradient.Free;
  FLastGradient.Free;
  
  inherited Destroy;
end; 

procedure TgmGradientMapLayerPanel.SetGradient(
  const AGradient: TgmGradientItem);
begin
  if Assigned(AGradient) then
  begin
    FGradient.Assign(AGradient);
    FGradient.GradientLength := 256;
    FGradient.RefreshColorArray;
  end;
end; 

procedure TgmGradientMapLayerPanel.SetLastGradient(
  const AGradient: TgmGradientItem);
begin
  if Assigned(AGradient) then
  begin
    FLastGradient.Assign(AGradient);
  end;
end;

procedure TgmGradientMapLayerPanel.LayerPixelBlend(F: TColor32; var B: TColor32;
  M: TColor32);
var
  LTemp             : Integer;
  LIntensity, LAlpha: Byte;
  LGrayscale        : Byte;
  rr, gg, bb, LIndex: Byte;
  LForeColor        : TColor32;
begin
  { Preserve the alpha of the background, only change the RGB channels of it.
    In this case, we could create mask for the special layer correctly. }
  LAlpha := B shr 24 and $FF;

  if LAlpha > 0 then
  begin
    rr := B shr 16 and $FF;
    gg := B shr  8 and $FF;
    bb := B        and $FF;

    LGrayscale := (rr + gg + bb) div 3;

    if FReversed then
    begin
      LIndex := 255 - LGrayscale;
    end
    else
    begin
      LIndex := LGrayscale;
    end;

    LForeColor := FGradient.OutputColors[LIndex];
    LForeColor := LForeColor and $FFFFFF;  // only need RGB components

    if FMaskLinked then
    begin
      { We already saved the mask info of this special layer into the alpha
        channel of each pixels on the layer. So we get the mask value for this
        pixel from its alpha channel.

        Important: Never change the alpha channel of F at here. }

      LIntensity := F shr 24 and $FF;
      LTemp      := LAlpha - (255 - LIntensity);

      if LTemp < 0 then
      begin
        LAlpha := 0;
      end
      else
      begin
        LAlpha := LTemp;
      end;
    end;

    LForeColor := (LAlpha shl 24) or LForeColor;

    // blending
    FBlendModeEvent(LForeColor, B, M);
  end;
end;

procedure TgmGradientMapLayerPanel.ChangeImageSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AOptions: TgmResamplingOptions);
begin
  ResizeEffectLayer(AImageControl, ANewWidth, ANewHeight, AOptions);
end;

procedure TgmGradientMapLayerPanel.ChangeCanvasSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AAnchor: TgmAnchorDirection; const ABackgroundColor: TColor32);
begin
  ChangeEffectLayerCanvasSize(AImageControl, ANewWidth, ANewHeight, AAnchor);
end;

procedure TgmGradientMapLayerPanel.RotateCanvas(
  const AImageControl: TCustomImage32; const ADeg: Integer;
  const ADirection: TgmRotateDirection; const AResizeBackground: Boolean;
  const ABackColor: TColor32);
begin
  RotateEffectLayerCanvas(AImageControl, ADeg, ADirection, AResizeBackground);
end;

procedure TgmGradientMapLayerPanel.CropImage(
  const AImageControl: TCustomImage32; const ACrop: TgmCrop;
  const ABackColor: TColor32);
begin
  CropEffectLayer(AImageControl, ACrop);
end;

function TgmGradientMapLayerPanel.DuplicateCurrentLayerPanel(
  const AOwner: TWinControl; const ALayers: TLayerCollection;
  const ALayerIndex: Integer; const ALayerName: string): TgmLayerPanel;
var
  LLayer                : TBitmapLayer;
  LGradientMapLayerPanel: TgmGradientMapLayerPanel;
begin
  ALayers.Insert(ALayerIndex, TBitmapLayer);

  LLayer          := TBitmapLayer(ALayers.Items[ALayerIndex]);
  LLayer.Location := FAssociatedLayer.Location;
  LLayer.Scaled   := True;

  LLayer.Bitmap.SetSize(FAssociatedLayer.Bitmap.Width,
                        FAssociatedLayer.Bitmap.Height);
                        
  LLayer.Bitmap.DrawMode := dmCustom;

  LGradientMapLayerPanel := TgmGradientMapLayerPanel.Create(AOwner, LLayer, nil);
  LGradientMapLayerPanel.IsDuplicated := True;
  LGradientMapLayerPanel.Gradient     := Self.FGradient;
  LGradientMapLayerPanel.IsReversed   := Self.FReversed;
  LGradientMapLayerPanel.SaveLastAdjustment;

  LGradientMapLayerPanel.BlendModeIndex   := Self.FBlendModeIndex;
  LGradientMapLayerPanel.LayerMasterAlpha := Self.FLayerMasterAlpha;
  LGradientMapLayerPanel.SetLayerName(ALayerName);

{ Duplicate mask }
  LGradientMapLayerPanel.IsHasMask         := Self.FHasMask;
  LGradientMapLayerPanel.IsMaskLinked      := Self.FMaskLinked;
  LGradientMapLayerPanel.LayerProcessStage := Self.FLayerProcessStage;
  LGradientMapLayerPanel.PrevProcessStage  := Self.FPrevProcessStage;

  if LGradientMapLayerPanel.IsHasMask then
  begin
    LGradientMapLayerPanel.FMaskImage.Bitmap.Assign(Self.FMaskImage.Bitmap);
    LGradientMapLayerPanel.UpdateMaskThumbnail;

    // save Mask into layer's alpha channels
    LGradientMapLayerPanel.UpdateLayerAlphaWithMask;

    LGradientMapLayerPanel.ShowThumbnailByRightOrder;
  end;
  
  Result := LGradientMapLayerPanel;
end;

procedure TgmGradientMapLayerPanel.SaveLastAdjustment;
begin
  FLastGradient.Assign(FGradient);
  FLastReversed := FReversed;
end; 

procedure TgmGradientMapLayerPanel.RestoreLastAdjustment;
begin
  FGradient.Assign(FLastGradient);
  FGradient.GradientLength := 256;
  FGradient.RefreshColorArray;
  FReversed := FLastReversed;
end; 

// save the layer to a stream for output it to a '*gmd' file later
procedure TgmGradientMapLayerPanel.SaveToStream(const AStream: TStream);
var
  LLayerHeader   : TgmLayerHeaderVer1;
  i              : Integer;
  LByteMap       : TByteMap;
  LByteBits      : PByte;
  LGradientWriter: TgmGrdVer1_Writer;
  LColorValue    : TColor;
begin
  LLayerHeader.LayerName        := FLayerName.Caption;
  LLayerHeader.LayerFeature     := Ord(lfGradientMap);
  LLayerHeader.BlendModeIndex   := FBlendModeIndex;
  LLayerHeader.MasterAlpha      := FLayerMasterAlpha;
  LLayerHeader.Selected         := FSelected;
  LLayerHeader.Visible          := FLayerVisible;
  LLayerHeader.LockTransparency := FLockTransparency;
  LLayerHeader.Duplicated       := FDuplicated;
  LLayerHeader.HasMask          := FHasMask;
  LLayerHeader.MaskLinked       := FMaskLinked;

  // write the layer header to stream
  AStream.Write(LLayerHeader, SizeOf(TgmLayerHeaderVer1));

  // write the GradientMap data to stream
  LGradientWriter := TgmGrdVer1_Writer.Create;
  try
    LGradientWriter.SaveItemToStream(AStream, FGradient);
  finally
    LGradientWriter.Free;
  end;

  // save forground/background color of gradient
  LColorValue := FGradient.ForegroundColor;
  AStream.Write( LColorValue, SizeOf(TColor) );

  LColorValue := FGradient.BackgroundColor;
  AStream.Write( LColorValue, SizeOf(TColor) );

  AStream.Write(FReversed, 1);
  AStream.Write(FPreview, 1);

  // write the mask data to stream, if any
  if FHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      // write the mask data to stream
      LByteMap.SetSize(FMaskImage.Bitmap.Width, FMaskImage.Bitmap.Height);
      LByteMap.ReadFrom(FMaskImage.Bitmap, ctUniformRGB);

      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (FMaskImage.Bitmap.Height - 1) do
      begin
        AStream.Write(LByteBits^, FMaskImage.Bitmap.Width);
        Inc(LByteBits, FMaskImage.Bitmap.Width);
      end;
    finally
      LByteMap.Free;
    end;
  end;
end; 

//-- TgmInvertLayerPanel -------------------------------------------------------

constructor TgmInvertLayerPanel.Create(const AOwner: TWinControl;
  const ALayer: TBitmapLayer);
begin
  inherited Create(AOwner, ALayer);
  
  FLayerFeature                    := lfInvert;
  FHoldMaskInLayerAlpha            := True;
  FLayerImage.PaintStages[0].Stage := PST_CLEAR_BACKGND;

  if FAssociatedLayer <> nil then
  begin
    FAssociatedLayer.Bitmap.OnPixelCombine := LayerPixelBlend;
  end;

  GMDataModule := TGMDataModule.Create(nil);
  try
    // get thumbnail for the Invert layer
    FLayerImage.Bitmap.Assign(GMDataModule.bmp32lstLayers.Bitmap[INVERT_LAYER_ICON_INDEX]);
  finally
    FreeAndNil(GMDataModule)
  end;
end;

procedure TgmInvertLayerPanel.LayerPixelBlend(F: TColor32; var B: TColor32;
  M: TColor32);
var
  LTemp     : Integer;
  LIntensity: Byte;
  LAlpha    : Byte;
  rr, gg, bb: Byte;
  LForeColor: TColor32;
begin
  { Preserve the alpha of the background, only change the RGB channels of it.
    In this case, we could create mask for the special layer correctly. }
  LAlpha := B shr 24 and $FF;

  if LAlpha > 0 then
  begin
    rr := 255 - (B shr 16 and $FF);
    gg := 255 - (B shr  8 and $FF);
    bb := 255 - (B        and $FF);

    if FMaskLinked then
    begin
      { We already saved the mask info of this special layer into the alpha
        channel of each pixels on the layer. So we get the mask value for this
        pixel from its alpha channel.

        Important: Never change the alpha channel of F at here. }

      LIntensity := F shr 24 and $FF;
      LTemp      := LAlpha - (255 - LIntensity);

      if LTemp < 0 then
      begin
        LAlpha := 0;
      end
      else
      begin
        LAlpha := LTemp;
      end;
    end;

    LForeColor := (LAlpha shl 24) or (rr shl 16) or (gg shl 8) or bb;

    // blending
    FBlendModeEvent(LForeColor, B, M);
  end;
end;

procedure TgmInvertLayerPanel.ChangeImageSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AOptions: TgmResamplingOptions);
begin
  ResizeEffectLayer(AImageControl, ANewWidth, ANewHeight, AOptions);
end; 

procedure TgmInvertLayerPanel.ChangeCanvasSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AAnchor: TgmAnchorDirection; const ABackgroundColor: TColor32);
begin
  ChangeEffectLayerCanvasSize(AImageControl, ANewWidth, ANewHeight, AAnchor);
end;

procedure TgmInvertLayerPanel.RotateCanvas(const AImageControl: TCustomImage32;
  const ADeg: Integer; const ADirection: TgmRotateDirection;
  const AResizeBackground: Boolean; const ABackColor: TColor32);
begin
  RotateEffectLayerCanvas(AImageControl, ADeg, ADirection, AResizeBackground);
end;

procedure TgmInvertLayerPanel.CropImage(const AImageControl: TCustomImage32;
  const ACrop: TgmCrop; const ABackColor: TColor32);
begin
  CropEffectLayer(AImageControl, ACrop);
end;

function TgmInvertLayerPanel.DuplicateCurrentLayerPanel(
  const AOwner: TWinControl; const ALayers: TLayerCollection;
  const ALayerIndex: Integer; const ALayerName: string): TgmLayerPanel;
var
  LLayer: TBitmapLayer;
begin
  ALayers.Insert(ALayerIndex, TBitmapLayer);

  LLayer          := TBitmapLayer(ALayers.Items[ALayerIndex]);
  LLayer.Location := FAssociatedLayer.Location;
  LLayer.Scaled   := True;
  
  LLayer.Bitmap.SetSize(FAssociatedLayer.Bitmap.Width,
                        FAssociatedLayer.Bitmap.Height);
                        
  LLayer.Bitmap.DrawMode := dmCustom;

  Result                  := TgmInvertLayerPanel.Create(AOwner, LLayer);
  Result.IsDuplicated     := True;
  Result.BlendModeIndex   := Self.FBlendModeIndex;
  Result.LayerMasterAlpha := Self.FLayerMasterAlpha;
  Result.SetLayerName(ALayerName);

{ Duplicate mask }
  Result.IsHasMask         := Self.FHasMask;
  Result.IsMaskLinked      := Self.FMaskLinked;
  Result.LayerProcessStage := Self.FLayerProcessStage;
  Result.PrevProcessStage  := Self.FPrevProcessStage;
  
  if Result.IsHasMask then
  begin
    Result.FMaskImage.Bitmap.Assign(Self.FMaskImage.Bitmap);
    Result.UpdateMaskThumbnail;

    // save Mask into layer's alpha channels
    Result.UpdateLayerAlphaWithMask;

    Result.ShowThumbnailByRightOrder;
  end;
end; 

// save the layer to a stream for output it to a '*gmd' file later
procedure TgmInvertLayerPanel.SaveToStream(const AStream: TStream);
var
  LLayerHeader: TgmLayerHeaderVer1;
  i           : Integer;
  LByteMap    : TByteMap;
  LByteBits   : PByte;
begin
  LLayerHeader.LayerName        := FLayerName.Caption;
  LLayerHeader.LayerFeature     := Ord(lfInvert);
  LLayerHeader.BlendModeIndex   := FBlendModeIndex;
  LLayerHeader.MasterAlpha      := FLayerMasterAlpha;
  LLayerHeader.Selected         := FSelected;
  LLayerHeader.Visible          := FLayerVisible;
  LLayerHeader.LockTransparency := FLockTransparency;
  LLayerHeader.Duplicated       := FDuplicated;
  LLayerHeader.HasMask          := FHasMask;
  LLayerHeader.MaskLinked       := FMaskLinked;

  // write the layer header to stream
  AStream.Write(LLayerHeader, SizeOf(TgmLayerHeaderVer1));

  // write the mask data to stream, if any
  if FHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      // write the mask data to stream
      LByteMap.SetSize(FMaskImage.Bitmap.Width, FMaskImage.Bitmap.Height);
      LByteMap.ReadFrom(FMaskImage.Bitmap, ctUniformRGB);

      LByteBits := @LByteMap.Bits[0];
      for i := 0 to FMaskImage.Bitmap.Height - 1 do
      begin
        AStream.Write(LByteBits^, FMaskImage.Bitmap.Width);
        Inc(LByteBits, FMaskImage.Bitmap.Width);
      end;
    finally
      LByteMap.Free;
    end;
  end;
end;

//-- TgmThresholdLayerPanel ----------------------------------------------------

constructor TgmThresholdLayerPanel.Create(const AOwner: TWinControl;
  const ALayer: TBitmapLayer);
begin
  inherited Create(AOwner, ALayer);

  FLayerImage.PaintStages[0].Stage := PST_CLEAR_BACKGND;
  FLayerFeature                    := lfThreshold;
  FHoldMaskInLayerAlpha            := True;

  if FAssociatedLayer <> nil then
  begin
    FAssociatedLayer.Bitmap.OnPixelCombine := LayerPixelBlend;
  end;

  FLevel     := 127;
  FLastLevel := 127;
  FPreview   := True;

  GMDataModule := TGMDataModule.Create(nil);
  try
    // get thumbnail for the Threshold layer
    FLayerImage.Bitmap.Assign(GMDataModule.bmp32lstLayers.Bitmap[THRESHOLD_LAYER_ICON_INDEX]);
  finally
    FreeAndNil(GMDataModule)
  end;
end;

procedure TgmThresholdLayerPanel.LayerPixelBlend(F: TColor32; var B: TColor32;
  M: TColor32);
var
  LTemp             : Integer;
  LIntensity, LAlpha: Byte;
  rr, gg, bb, bw    : Byte;
  LForeColor        : TColor32;
begin
  { Preserve the alpha of the background, only change the RGB channels of it.
    In this case, we could create mask for the special layer correctly. }
  LAlpha := B shr 24 and $FF;

  if LAlpha > 0 then
  begin
    rr := B shr 16 and $FF;
    gg := B shr  8 and $FF;
    bb := B        and $FF;
    bw := (rr + gg + bb) div 3;

    if bw > FLevel then
    begin
      bw := 255
    end
    else
    begin
      bw := 0;
    end;

    if FMaskLinked then
    begin
      { We already saved the mask info of this special layer into the alpha
        channel of each pixels on the layer. So we get the mask value for this
        pixel from its alpha channel.

        Important: Never change the alpha channel of F at here. }

      LIntensity := F shr 24 and $FF;
      LTemp      := LAlpha - (255 - LIntensity);

      if LTemp < 0 then
      begin
        LAlpha := 0;
      end
      else
      begin
        LAlpha := LTemp
      end;
    end;

    LForeColor := (LAlpha shl 24) or (bw shl 16) or (bw shl 8) or bw;

    // blending
    FBlendModeEvent(LForeColor, B, M);
  end;
end;

procedure TgmThresholdLayerPanel.ChangeImageSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AOptions: TgmResamplingOptions);
begin
  ResizeEffectLayer(AImageControl, ANewWidth, ANewHeight, AOptions);
end;

procedure TgmThresholdLayerPanel.ChangeCanvasSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AAnchor: TgmAnchorDirection; const ABackgroundColor: TColor32);
begin
  ChangeEffectLayerCanvasSize(AImageControl, ANewWidth, ANewHeight, AAnchor);
end;

procedure TgmThresholdLayerPanel.RotateCanvas(
  const AImageControl: TCustomImage32; const ADeg: Integer;
  const ADirection: TgmRotateDirection; const AResizeBackground: Boolean;
  const ABackColor: TColor32);
begin
  RotateEffectLayerCanvas(AImageControl, ADeg, ADirection, AResizeBackground);
end; 

procedure TgmThresholdLayerPanel.CropImage(const AImageControl: TCustomImage32;
  const ACrop: TgmCrop; const ABackColor: TColor32);
begin
  CropEffectLayer(AImageControl, ACrop);
end; 

function TgmThresholdLayerPanel.DuplicateCurrentLayerPanel(
  const AOwner: TWinControl; const ALayers: TLayerCollection;
  const ALayerIndex: Integer; const ALayerName: string): TgmLayerPanel;
var
  LLayer              : TBitmapLayer;
  LThresholdLayerPanel: TgmThresholdLayerPanel;
begin
  ALayers.Insert(ALayerIndex, TBitmapLayer);

  LLayer          := TBitmapLayer(ALayers.Items[ALayerIndex]);
  LLayer.Location := FAssociatedLayer.Location;
  LLayer.Scaled   := True;
  
  LLayer.Bitmap.SetSize(FAssociatedLayer.Bitmap.Width,
                        FAssociatedLayer.Bitmap.Height);
                        
  LLayer.Bitmap.DrawMode := dmCustom;

  LThresholdLayerPanel := TgmThresholdLayerPanel.Create(AOwner, LLayer);
  LThresholdLayerPanel.IsDuplicated     := True;
  LThresholdLayerPanel.Level            := Self.FLevel;
  LThresholdLayerPanel.LastLevel        := Self.FLastLevel;
  LThresholdLayerPanel.BlendModeIndex   := Self.FBlendModeIndex;
  LThresholdLayerPanel.LayerMasterAlpha := Self.FLayerMasterAlpha;
  LThresholdLayerPanel.SetLayerName(ALayerName);

{ Duplicate mask }
  LThresholdLayerPanel.IsHasMask         := Self.FHasMask;
  LThresholdLayerPanel.IsMaskLinked      := Self.FMaskLinked;
  LThresholdLayerPanel.LayerProcessStage := Self.FLayerProcessStage;
  LThresholdLayerPanel.PrevProcessStage  := Self.FPrevProcessStage;

  if LThresholdLayerPanel.IsHasMask then
  begin
    LThresholdLayerPanel.FMaskImage.Bitmap.Assign(Self.FMaskImage.Bitmap);
    LThresholdLayerPanel.UpdateMaskThumbnail;

    // save Mask into layer's alpha channels
    LThresholdLayerPanel.UpdateLayerAlphaWithMask;

    LThresholdLayerPanel.ShowThumbnailByRightOrder;
  end;
  
  Result := LThresholdLayerPanel;
end;

procedure TgmThresholdLayerPanel.SaveLastAdjustment;
begin
  FLastLevel := FLevel;
end;

procedure TgmThresholdLayerPanel.RestoreLastAdjustment;
begin
  FLevel := FLastLevel;
end; 

// save the layer to a stream for output it to a '*gmd' file later
procedure TgmThresholdLayerPanel.SaveToStream(const AStream: TStream);
var
  LLayerHeader: TgmLayerHeaderVer1;
  i           : Integer;
  LByteMap    : TByteMap;
  LByteBits   : PByte;
begin
  LLayerHeader.LayerName        := FLayerName.Caption;
  LLayerHeader.LayerFeature     := Ord(lfThreshold);
  LLayerHeader.BlendModeIndex   := FBlendModeIndex;
  LLayerHeader.MasterAlpha      := FLayerMasterAlpha;
  LLayerHeader.Selected         := FSelected;
  LLayerHeader.Visible          := FLayerVisible;
  LLayerHeader.LockTransparency := FLockTransparency;
  LLayerHeader.Duplicated       := FDuplicated;
  LLayerHeader.HasMask          := FHasMask;
  LLayerHeader.MaskLinked       := FMaskLinked;

  // write the layer header to stream
  AStream.Write(LLayerHeader, SizeOf(TgmLayerHeaderVer1));

  // write the threshold data to stream
  AStream.Write(FLevel, 1);
  AStream.Write(FPreview, 1);

  // write the mask data to stream, if any
  if FHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      // write the mask data to stream
      LByteMap.SetSize(FMaskImage.Bitmap.Width, FMaskImage.Bitmap.Height);
      LByteMap.ReadFrom(FMaskImage.Bitmap, ctUniformRGB);

      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (FMaskImage.Bitmap.Height - 1) do
      begin
        AStream.Write(LByteBits^, FMaskImage.Bitmap.Width);
        Inc(LByteBits, FMaskImage.Bitmap.Width);
      end;
    finally
      LByteMap.Free;
    end;
  end;
end; 

//-- TgmPosterizeLayerPanel ----------------------------------------------------

constructor TgmPosterizeLayerPanel.Create(const AOwner: TWinControl;
  const ALayer: TBitmapLayer);
begin
  inherited Create(AOwner, ALayer);

  FLayerImage.PaintStages[0].Stage := PST_CLEAR_BACKGND;
  FLayerFeature                    := lfPosterize;
  FHoldMaskInLayerAlpha            := True;

  if FAssociatedLayer <> nil then
  begin
    FAssociatedLayer.Bitmap.OnPixelCombine := LayerPixelBlend;
  end;

  FLevel     := 2;
  FLastLevel := 2;
  FPreview   := True;

  GMDataModule := TGMDataModule.Create(nil);
  try
    // get thumbnail for the Posterize layer
    FLayerImage.Bitmap.Assign(GMDataModule.bmp32lstLayers.Bitmap[POSTERIZE_LAYER_ICON_INDEX]);
  finally
    FreeAndNil(GMDataModule)
  end;
end;

procedure TgmPosterizeLayerPanel.LayerPixelBlend(F: TColor32; var B: TColor32;
  M: TColor32);
var
  LTemp         : Integer;
  LIntensity    : Byte;
  LLevel, LAlpha: Byte;
  rr, gg, bb    : Cardinal;
  LForeColor    : TColor32;
begin
  LLevel := 255 - FLevel;

  if LLevel < 2 then
  begin
    Exit;
  end;
  
  { Preserve the alpha of the background, only change the RGB channels of it.
    In this case, we could create mask for the special layer correctly. }
  LAlpha := B shr 24 and $FF;

  if LAlpha > 0 then
  begin
    if FMaskLinked then
    begin
      { We already saved the mask info of this special layer into the alpha
        channel of each pixels on the layer. So we get the mask value for this
        pixel from its alpha channel.

        Important: Never change the alpha channel of F at here. }

      LIntensity := F shr 24 and $FF;
      LTemp      := LAlpha - (255 - LIntensity);

      if LTemp < 0 then
      begin
        LAlpha := 0;
      end
      else
      begin
        LAlpha := LTemp;
      end;
    end;

    // Channel Separation.
    rr := B shr 16 and $FF;
    gg := B shr  8 and $FF;
    bb := B        and $FF;

    // Changing Color.
    rr := Round(rr / LLevel) * LLevel;
    rr := Clamp(rr, 0, 255);

    gg := Round(gg / LLevel) * LLevel;
    gg := Clamp(gg, 0, 255);

    bb := Round(bb / LLevel) * LLevel;
    bb := Clamp(bb, 0, 255);

    LForeColor := (LAlpha shl 24) or (rr shl 16) or (gg shl 8) or bb;

    // blending
    FBlendModeEvent(LForeColor, B, M);
  end;
end;

procedure TgmPosterizeLayerPanel.ChangeImageSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AOptions: TgmResamplingOptions);
begin
  ResizeEffectLayer(AImageControl, ANewWidth, ANewHeight, AOptions);
end;

procedure TgmPosterizeLayerPanel.ChangeCanvasSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AAnchor: TgmAnchorDirection; const ABackgroundColor: TColor32);
begin
  ChangeEffectLayerCanvasSize(AImageControl, ANewWidth, ANewHeight, AAnchor);
end;

procedure TgmPosterizeLayerPanel.RotateCanvas(
  const AImageControl: TCustomImage32; const ADeg: Integer;
  const ADirection: TgmRotateDirection; const AResizeBackground: Boolean;
  const ABackColor: TColor32);
begin
  RotateEffectLayerCanvas(AImageControl, ADeg, ADirection, AResizeBackground);
end;

procedure TgmPosterizeLayerPanel.CropImage(const AImageControl: TCustomImage32;
  const ACrop: TgmCrop; const ABackColor: TColor32);
begin
  CropEffectLayer(AImageControl, ACrop);
end;

function TgmPosterizeLayerPanel.DuplicateCurrentLayerPanel(
  const AOwner: TWinControl; const ALayers: TLayerCollection;
  const ALayerIndex: Integer; const ALayerName: string): TgmLayerPanel;
var
  LLayer              : TBitmapLayer;
  LPosterizeLayerPanel: TgmPosterizeLayerPanel;
begin
  ALayers.Insert(ALayerIndex, TBitmapLayer);

  LLayer          := TBitmapLayer(ALayers.Items[ALayerIndex]);
  LLayer.Location := FAssociatedLayer.Location;
  LLayer.Scaled   := True;
  
  LLayer.Bitmap.SetSize(FAssociatedLayer.Bitmap.Width,
                        FAssociatedLayer.Bitmap.Height);
                        
  LLayer.Bitmap.DrawMode := dmCustom;

  LPosterizeLayerPanel := TgmPosterizeLayerPanel.Create(AOwner, LLayer);
  LPosterizeLayerPanel.IsDuplicated     := True;
  LPosterizeLayerPanel.Level            := Self.FLevel;
  LPosterizeLayerPanel.LastLevel        := Self.FLastLevel;
  LPosterizeLayerPanel.BlendModeIndex   := Self.FBlendModeIndex;
  LPosterizeLayerPanel.LayerMasterAlpha := Self.FLayerMasterAlpha;
  LPosterizeLayerPanel.SetLayerName(ALayerName);

{ Duplicate mask }
  LPosterizeLayerPanel.IsHasMask         := Self.FHasMask;
  LPosterizeLayerPanel.IsMaskLinked      := Self.FMaskLinked;
  LPosterizeLayerPanel.LayerProcessStage := Self.FLayerProcessStage;
  LPosterizeLayerPanel.PrevProcessStage  := Self.FPrevProcessStage;

  if LPosterizeLayerPanel.IsHasMask then
  begin
    LPosterizeLayerPanel.FMaskImage.Bitmap.Assign(Self.FMaskImage.Bitmap);
    LPosterizeLayerPanel.UpdateMaskThumbnail;

    // save Mask into layer's alpha channels
    LPosterizeLayerPanel.UpdateLayerAlphaWithMask;

    LPosterizeLayerPanel.ShowThumbnailByRightOrder;
  end;
  
  Result := LPosterizeLayerPanel;
end;

procedure TgmPosterizeLayerPanel.SaveLastAdjustment;
begin
  FLastLevel := FLevel;
end;

procedure TgmPosterizeLayerPanel.RestoreLastAdjustment;
begin
  FLevel := FLastLevel;
end;

// save the layer to a stream for output it to a '*gmd' file later
procedure TgmPosterizeLayerPanel.SaveToStream(const AStream: TStream);
var
  LLayerHeader: TgmLayerHeaderVer1;
  i           : Integer;
  LByteMap    : TByteMap;
  LByteBits   : PByte;
begin
  LLayerHeader.LayerName        := FLayerName.Caption;
  LLayerHeader.LayerFeature     := Ord(lfPosterize);
  LLayerHeader.BlendModeIndex   := FBlendModeIndex;
  LLayerHeader.MasterAlpha      := FLayerMasterAlpha;
  LLayerHeader.Selected         := FSelected;
  LLayerHeader.Visible          := FLayerVisible;
  LLayerHeader.LockTransparency := FLockTransparency;
  LLayerHeader.Duplicated       := FDuplicated;
  LLayerHeader.HasMask          := FHasMask;
  LLayerHeader.MaskLinked       := FMaskLinked;

  // write the layer header to stream
  AStream.Write(LLayerHeader, SizeOf(TgmLayerHeaderVer1));

  // write the threshold data to stream
  AStream.Write(FLevel, 1);
  AStream.Write(FPreview, 1);

  // write the mask data to stream, if any
  if FHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      // write the mask data to stream
      LByteMap.SetSize(FMaskImage.Bitmap.Width, FMaskImage.Bitmap.Height);
      LByteMap.ReadFrom(FMaskImage.Bitmap, ctUniformRGB);

      LByteBits := @LByteMap.Bits[0];
      for i := 0 to FMaskImage.Bitmap.Height - 1 do
      begin
        AStream.Write(LByteBits^, FMaskImage.Bitmap.Width);
        Inc(LByteBits, FMaskImage.Bitmap.Width);
      end;
    finally
      LByteMap.Free;
    end;
  end;
end;

//-- TgmPatternLayerPanel ------------------------------------------------------

constructor TgmPatternLayerPanel.Create(const AOwner: TWinControl;
  const ALayer: TBitmapLayer; const APatternBmp: TBitmap32);
begin
  inherited Create(AOwner, ALayer);

  FLayerFeature := lfPattern;

  if FAssociatedLayer <> nil then
  begin
    FAssociatedLayer.Bitmap.OnPixelCombine := LayerPixelBlend;
  end;

  FPatternBitmap := TBitmap32.Create;
  if Assigned(APatternBmp) then
  begin
    FPatternBitmap.Assign(APatternBmp);
  end;

  if FPatternBitmap.DrawMode <> dmBlend then
  begin
    FPatternBitmap.DrawMode := dmBlend;
  end;

  // little thumbnail that indicating the selected pattern
  FPatternMark := TBitmap32.Create;

  FLastPatternBitmap := TBitmap32.Create;
  FLastPatternBitmap.Assign(FPatternBitmap);

  FScaledPatternBitmap          := TBitmap32.Create;
  FScaledPatternBitmap.DrawMode := dmBlend;
  SetScale(1.0);

  FScale     := 1.0;
  FLastScale := 1.0;
  
  DrawPatternLayerThumbnail;
end;

destructor TgmPatternLayerPanel.Destroy;
begin
  FPatternBitmap.Free;
  FPatternMark.Free;
  FLastPatternBitmap.Free;
  FScaledPatternBitmap.Free;
  
  inherited Destroy;
end;

procedure TgmPatternLayerPanel.FillPatternOnLayer;
begin
  if Assigned(FAssociatedLayer) then
  begin
    FAssociatedLayer.Bitmap.Clear($00000000);
    DrawPattern(FAssociatedLayer.Bitmap, FScaledPatternBitmap);
    GetAlphaChannelBitmap(FAssociatedLayer.Bitmap, FLastAlphaChannelBmp);
    Update;
  end;
end; 

procedure TgmPatternLayerPanel.DrawPatternLayerThumbnail;
var
  LLeft, LTop: Integer;
begin
  // draw Photoshop-Style thumbnail for the pattern layer
  with FLayerImage.Bitmap do
  begin
    SetSize(IMAGE_WIDTH, IMAGE_HEIGHT);
    FillRect(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT, clWhite32);

    PenColor := clBlack32;

    HorzLine(0, 22, 31, clBlack32);
    FrameRectS(Canvas.ClipRect, clBlack32);
    HorzLine(4, 25, 26, clBlack32);

    MoveTo(17, 26);
    LineToS(15, 28);
    MoveTo(17, 26);
    LineToS(19, 28);
    
    HorzLine(15, 28, 19, clBlack32);
  end;

  GetScaledBitmap(FPatternBitmap, FPatternMark, 18, 18);

  LLeft := 15 - FPatternMark.Width  div 2;
  LTop  := 12 - FPatternMark.Height div 2;
  
  FLayerImage.Bitmap.Draw(LLeft, LTop, FPatternMark);
  FLayerImage.Bitmap.Changed;
end;

procedure TgmPatternLayerPanel.SetPatternBitmap(const APatternBmp: TBitmap32);
var
  sw, sh: Integer;
begin
  FPatternBitmap.Assign(APatternBmp);
  if FPatternBitmap.DrawMode <> dmBlend then
  begin
    FPatternBitmap.DrawMode := dmBlend;
  end;

  sw := Round(FPatternBitmap.Width  * FScale);
  sh := Round(FPatternBitmap.Height * FScale);

  FScaledPatternBitmap.Assign(FPatternBitmap);
  FScaledPatternBitmap.DrawMode := dmBlend;
  SmoothResize32(FScaledPatternBitmap, sw, sh);

  FillPatternOnLayer;
end;

procedure TgmPatternLayerPanel.SetScale(const AScale: Double);
var
  sw, sh: Integer;
begin
  FScale := AScale;
  sw     := Round(FPatternBitmap.Width  * FScale);
  sh     := Round(FPatternBitmap.Height * FScale);

  FScaledPatternBitmap.Assign(FPatternBitmap);
  SmoothResize32(FScaledPatternBitmap, sw, sh);
  FillPatternOnLayer;
end;

procedure TgmPatternLayerPanel.LayerPixelBlend(F: TColor32; var B: TColor32;
  M: TColor32);
begin
  FBlendModeEvent(F, B, M);
end;

procedure TgmPatternLayerPanel.ChangeImageSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AOptions: TgmResamplingOptions);
var
  LTopLeft: TPoint;
begin
  if (FAssociatedLayer.Bitmap.Width  <> ANewWidth) or
     (FAssociatedLayer.Bitmap.Height <> ANewHeight) then
  begin
    // Change the dimension of the associated layer.
    FAssociatedLayer.Bitmap.SetSize(ANewWidth, ANewHeight);
    FillPatternOnLayer;

    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);

    // Process mask thumbnail.
    ResizeMask(ANewWidth, ANewHeight, AOptions);

    if FHasMask and FMaskLinked then
    begin
      ChangeAlphaChannelBySubMask(FAssociatedLayer.Bitmap,
                                  FLastAlphaChannelBmp,
                                  FMaskImage.Bitmap);
    end;
  end;
end;

procedure TgmPatternLayerPanel.ChangeCanvasSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AAnchor: TgmAnchorDirection; const ABackgroundColor: TColor32);
var
  LTopLeft: TPoint;
begin
  if (FAssociatedLayer.Bitmap.Width  <> ANewWidth) or
     (FAssociatedLayer.Bitmap.Height <> ANewHeight) then
  begin
    // change the dimension of the associated layer
    FAssociatedLayer.Bitmap.SetSize(ANewWidth, ANewHeight);
    FillPatternOnLayer;

    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);

    // process mask thumbnail
    ChangeMaskCanvasSize(ANewWidth, ANewHeight, AAnchor);

    if FHasMask and FMaskLinked then
    begin
      ChangeAlphaChannelBySubMask(FAssociatedLayer.Bitmap,
                                  FLastAlphaChannelBmp,
                                  FMaskImage.Bitmap);
    end;
  end;
end; 

procedure TgmPatternLayerPanel.RotateCanvas(const AImageControl: TCustomImage32;
  const ADeg: Integer; const ADirection: TgmRotateDirection;
  const AResizeBackground: Boolean; const ABackColor: TColor32);
var
  LSrcBmp              : TBitmap32;
  LTopLeft             : TPoint;
  LNewWidth, LNewHeight: Integer;
begin
  LSrcBmp := TBitmap32.Create;
  try
    LSrcBmp.SetSize(FAssociatedLayer.Bitmap.Width, FAssociatedLayer.Bitmap.Height);
    RotateBitmap32(LSrcBmp, FAssociatedLayer.Bitmap, ADirection, ADeg, 0, clBlack32);

    FillPatternOnLayer;

    LNewWidth  := FAssociatedLayer.Bitmap.Width;
    LNewHeight := FAssociatedLayer.Bitmap.Height;

    if AResizeBackground then
    begin
      AImageControl.Bitmap.SetSize(LNewWidth, LNewHeight);
    end;

    // retrieve the top left position of a layer
    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);
                                           
    // process mask thumbnail.
    RotateMaskCanvas(ADeg, ADirection);

    if FHasMask and FMaskLinked then
    begin
      ChangeAlphaChannelBySubMask(FAssociatedLayer.Bitmap,
                                  FLastAlphaChannelBmp,
                                  FMaskImage.Bitmap);
    end;
    
  finally
    LSrcBmp.Free;
  end;
end;

procedure TgmPatternLayerPanel.CropImage(const AImageControl: TCustomImage32;
  const ACrop: TgmCrop; const ABackColor: TColor32);
var
  LNewWidth, LNewHeight: Integer;
  LTopLeft             : TPoint;
begin
  if ACrop.IsResized then
  begin
    LNewWidth  := ACrop.ResizeW;
    LNewHeight := ACrop.ResizeH;
  end
  else
  begin
    LNewWidth  := ACrop.FCropEnd.X - ACrop.FCropStart.X;
    LNewHeight := ACrop.FCropEnd.Y - ACrop.FCropStart.Y;
  end;

  FAssociatedLayer.Bitmap.SetSize(LNewWidth, LNewHeight);
  FillPatternOnLayer;

  // retrieve the top left position of a layer
  LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

  FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                         AImageControl.Bitmap.Width,
                                         AImageControl.Bitmap.Height);
                                         
  // Process mask thumbnail.
  CropMask(ACrop);

  if FHasMask and FMaskLinked then
  begin
    ChangeAlphaChannelBySubMask(FAssociatedLayer.Bitmap,
                                FLastAlphaChannelBmp,
                                FMaskImage.Bitmap);
  end;
end;

function TgmPatternLayerPanel.DuplicateCurrentLayerPanel(
  const AOwner: TWinControl; const ALayers: TLayerCollection;
  const ALayerIndex: Integer; const ALayerName: string): TgmLayerPanel;
var
  LLayer            : TBitmapLayer;
  LPatternLayerPanel: TgmPatternLayerPanel;
begin
  ALayers.Insert(ALayerIndex, TBitmapLayer);

  LLayer          := TBitmapLayer(ALayers.Items[ALayerIndex]);
  LLayer.Location := FAssociatedLayer.Location;
  LLayer.Scaled   := True;
  
  LLayer.Bitmap.SetSize(FAssociatedLayer.Bitmap.Width,
                        FAssociatedLayer.Bitmap.Height);
                        
  LLayer.Bitmap.MasterAlpha := 255;
  LLayer.Bitmap.DrawMode    := dmCustom;

  LPatternLayerPanel := TgmPatternLayerPanel.Create(AOwner, LLayer, nil);
  LPatternLayerPanel.IsDuplicated := True;

  LPatternLayerPanel.PatternBitmap.Assign(Self.FPatternBitmap);
  LPatternLayerPanel.PatternMark.Assign(Self.FPatternMark);

  LPatternLayerPanel.Scale := Self.FScale;
  LPatternLayerPanel.SaveLastAdjustment;

  LPatternLayerPanel.BlendModeIndex     := Self.FBlendModeIndex;
  LPatternLayerPanel.LayerMasterAlpha   := Self.FLayerMasterAlpha;
  LPatternLayerPanel.IsLockTransparency := Self.FLockTransparency;
  LPatternLayerPanel.SetLayerName(ALayerName);

{ Duplicate mask }
  LPatternLayerPanel.IsHasMask         := Self.FHasMask;
  LPatternLayerPanel.IsMaskLinked      := Self.FMaskLinked;
  LPatternLayerPanel.LayerProcessStage := Self.FLayerProcessStage;
  LPatternLayerPanel.PrevProcessStage  := Self.FPrevProcessStage;

  if LPatternLayerPanel.IsHasMask then
  begin
    LPatternLayerPanel.FMaskImage.Bitmap.Assign(Self.FMaskImage.Bitmap);
    LPatternLayerPanel.UpdateMaskThumbnail;

    // save Mask into layer's alpha channels
    LPatternLayerPanel.UpdateLayerAlphaWithMask;

    LPatternLayerPanel.ShowThumbnailByRightOrder;
  end;
  
  Result := LPatternLayerPanel;
end;

procedure TgmPatternLayerPanel.SaveLastAdjustment;
begin
  FLastScale := FScale;
  FLastPatternBitmap.Assign(FPatternBitmap);

  DrawPatternLayerThumbnail;
end;

procedure TgmPatternLayerPanel.RestoreLastAdjustment;
var
  sw, sh: Integer;
begin
  FScale := FLastScale;
  FPatternBitmap.Assign(FLastPatternBitmap);

  sw := Round(FPatternBitmap.Width  * FScale);
  sh := Round(FPatternBitmap.Height * FScale);

  FScaledPatternBitmap.Assign(FPatternBitmap);
  SmoothResize32(FScaledPatternBitmap, sw, sh);
  FillPatternOnLayer;
end;

// save the layer to a stream for output it to a '*gmd' file later
procedure TgmPatternLayerPanel.SaveToStream(const AStream: TStream);
var
  LLayerHeader : TgmLayerHeaderVer1;
  i, LRowStride: Integer;
  LPixelBits   : PColor32;
  LByteMap     : TByteMap;
  LByteBits    : PByte;
begin
  LLayerHeader.LayerName        := FLayerName.Caption;
  LLayerHeader.LayerFeature     := Ord(lfPattern);
  LLayerHeader.BlendModeIndex   := FBlendModeIndex;
  LLayerHeader.MasterAlpha      := FLayerMasterAlpha;
  LLayerHeader.Selected         := FSelected;
  LLayerHeader.Visible          := FLayerVisible;
  LLayerHeader.LockTransparency := FLockTransparency;
  LLayerHeader.Duplicated       := FDuplicated;
  LLayerHeader.HasMask          := FHasMask;
  LLayerHeader.MaskLinked       := FMaskLinked;

  // write the layer header to stream
  AStream.Write(LLayerHeader, SizeOf(TgmLayerHeaderVer1));

  // write the Pattern layer data to stream
  AStream.Write(FScale, SizeOf(FScale));
  AStream.Write(FPatternBitmap.Width,  4);
  AStream.Write(FPatternBitmap.Height, 4);

  LRowStride := FPatternBitmap.Width * SizeOf(TColor32);
  LPixelBits := @FPatternBitmap.Bits[0];

  for i := 0 to (FPatternBitmap.Height - 1) do
  begin
    AStream.Write(LPixelBits^, LRowStride);
    Inc(LPixelBits, FPatternBitmap.Width);
  end;

  // write the mask data to stream, if any
  if FHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      // write the mask data to stream
      LByteMap.SetSize(FMaskImage.Bitmap.Width, FMaskImage.Bitmap.Height);
      LByteMap.ReadFrom(FMaskImage.Bitmap, ctUniformRGB);

      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (FMaskImage.Bitmap.Height - 1) do
      begin
        AStream.Write(LByteBits^, FMaskImage.Bitmap.Width);
        Inc(LByteBits, FMaskImage.Bitmap.Width);
      end;
    finally
      LByteMap.Free;
    end;
  end;
end; 

//-- TgmFigureLayerPanel -------------------------------------------------------

constructor TgmFigureLayerPanel.Create(const AOwner: TWinControl;
  const ALayer: TBitmapLayer);
begin
  inherited Create(AOwner, ALayer);

  FLayerFeature := lfFigure;

  if FAssociatedLayer <> nil then
  begin
    FAssociatedLayer.Bitmap.OnPixelCombine := LayerPixelBlend;
  end;

  FFigureList    := TgmFigureList.Create;
  FLockFigureBMP := TBitmap32.Create;
  
  FLockFigureBMP.Assign(ALayer.Bitmap);
  FLockFigureBMP.DrawMode       := ALayer.Bitmap.DrawMode;
  FLockFigureBMP.OnPixelCombine := LayerPixelBlend;

  UpdateLayerThumbnail;
end;

destructor TgmFigureLayerPanel.Destroy;
begin
  FFigureList.Free;
  FLockFigureBMP.Free;
  
  inherited Destroy;
end;

procedure TgmFigureLayerPanel.DrawAllFigures(const ADestBmp: TBitmap32;
  const ABackColor: TColor32; const APenMode: TPenMode;
  const AFigureDrawMode: TgmFigureDrawMode);
begin
  ADestBmp.Clear(ABackColor);
  FFigureList.DrawAllFigures(ADestBmp.Canvas, APenMode, AFigureDrawMode);
end;

procedure TgmFigureLayerPanel.LayerPixelBlend(F: TColor32; var B: TColor32;
  M: TColor32);
begin
  FBlendModeEvent(F, B, M);
end;

procedure TgmFigureLayerPanel.ChangeImageSize(const AImageControl: TCustomImage32;
  const ANewWidth, ANewHeight: Integer; const AOptions: TgmResamplingOptions);
var
  LTopLeft     : TPoint;
  LOriginalRect: TRect;
  LCurrentRect : TRect;
  i, j         : Integer;
  LOldWidth    : Integer;
  LOldHeight   : Integer;
  LFigureObj   : TgmFigureObject;
  LMaskBitmap  : TBitmap32;
begin
  LOldWidth  := FAssociatedLayer.Bitmap.Width;
  LOldHeight := FAssociatedLayer.Bitmap.Height;

  if (LOldWidth  <> ANewWidth) or (LOldHeight <> ANewHeight) then
  begin
    // change the dimension of the associated layer
    FAssociatedLayer.Bitmap.SetSize(ANewWidth, ANewHeight);
    FAssociatedLayer.Bitmap.Clear($00FFFFFF);

    if FFigureList.Count > 0 then
    begin
      LOriginalRect := Rect(0, 0, LOldWidth, LOldHeight);
      LCurrentRect  := Rect(0, 0, ANewWidth, ANewHeight);

      for i := 0 to (FFigureList.Count - 1) do
      begin
        LFigureObj := TgmFigureObject(FFigureList.Items[i]);

        case LFigureObj.Flag of
          ffStraightLine,
          ffRectangle,
          ffSquare,
          ffRoundRectangle,
          ffRoundSquare,
          ffEllipse,
          ffCircle:
            begin
              LFigureObj.FStartPoint := ScalePoint(LFigureObj.FStartPoint,
                                                   LOldWidth, LOldHeight,
                                                   ANewWidth, ANewHeight);

              LFigureObj.FEndPoint := ScalePoint(LFigureObj.FEndPoint,
                                                 LOldWidth, LOldHeight,
                                                 ANewWidth, ANewHeight);
            end;

          ffCurve:
            begin
              LFigureObj.FStartPoint := ScalePoint(LFigureObj.FStartPoint,
                                                   LOldWidth, LOldHeight,
                                                   ANewWidth, ANewHeight);
                                                   
              LFigureObj.FEndPoint := ScalePoint(LFigureObj.FEndPoint,
                                                 LOldWidth, LOldHeight,
                                                 ANewWidth, ANewHeight);
                                                 
              LFigureObj.FCurvePoint1 := ScalePoint(LFigureObj.FCurvePoint1,
                                                    LOldWidth, LOldHeight,
                                                    ANewWidth, ANewHeight);

              LFigureObj.FCurvePoint2 := ScalePoint(LFigureObj.FCurvePoint2,
                                                    LOldWidth, LOldHeight,
                                                    ANewWidth, ANewHeight);
            end;

          ffPolygon, ffRegularPolygon:
            begin
              for j := Low(LFigureObj.FPolygonPoints) to High(LFigureObj.FPolygonPoints) do
              begin
                LFigureObj.FPolygonPoints[j] := ScalePoint(LFigureObj.FPolygonPoints[j],
                                                           LOldWidth, LOldHeight,
                                                           ANewWidth, ANewHeight);
              end;
            end;
        end;
      end;

      LMaskBitmap := TBitmap32.Create;
      try
        LMaskBitmap.SetSize(ANewWidth, ANewHeight);
        LMaskBitmap.Clear(clBlack32);
        FFigureList.DrawAllFigures(LMaskBitmap.Canvas, pmCopy, fdmMask);
        FFigureList.DrawAllFigures(FAssociatedLayer.Bitmap.Canvas, pmCopy, fdmRGB);
        MakeCanvasProcessedOpaque(FAssociatedLayer.Bitmap, LMaskBitmap);
      finally
        LMaskBitmap.Free;
      end;
    end;

    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);

    // process layer thumbnail
    UpdateLayerThumbnail;

    // process mask thumbnail
    ResizeMask(ANewWidth, ANewHeight, AOptions);
    
    // process last alpha channel bitmap
    SmoothResize32(FLastAlphaChannelBmp, ANewWidth, ANewHeight);
    SmoothResize32(FProcessedPart, ANewWidth, ANewHeight);
  end;
end;

procedure TgmFigureLayerPanel.ChangeCanvasSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AAnchor: TgmAnchorDirection; const ABackgroundColor: TColor32);
var
  LTopLeft     : TPoint;
  LOffsetVector: TPoint;
  i, j         : Integer;
  LOldWidth    : Integer;
  LOldHeight   : Integer;
  LFigureObj   : TgmFigureObject;
  LMaskBitmap  : TBitmap32;
  LCutBitmap   : TBitmap32;
begin
  LOldWidth  := FAssociatedLayer.Bitmap.Width;
  LOldHeight := FAssociatedLayer.Bitmap.Height;

  if (LOldWidth  <> ANewWidth) or (LOldHeight <> ANewHeight) then
  begin
    // change the dimension of the associated layer
    FAssociatedLayer.Bitmap.SetSize(ANewWidth, ANewHeight);
    FAssociatedLayer.Bitmap.Clear($00FFFFFF);

    LOffsetVector := CalcOffsetCoordinateByAnchorDirection(LOldWidth, LOldHeight,
                                                           ANewWidth, ANewHeight,
                                                           AAnchor);

    if FFigureList.Count > 0 then
    begin
      for i := 0 to (FFigureList.Count - 1) do
      begin
        LFigureObj := TgmFigureObject(FFigureList.Items[i]);

        case LFigureObj.Flag of
          ffStraightLine,
          ffRectangle,
          ffSquare,
          ffRoundRectangle,
          ffRoundSquare,
          ffEllipse,
          ffCircle:
            begin
              LFigureObj.FStartPoint := AddPoints(LFigureObj.FStartPoint, LOffsetVector);
              LFigureObj.FEndPoint   := AddPoints(LFigureObj.FEndPoint,   LOffsetVector);
            end;

          ffCurve:
            begin
              LFigureObj.FStartPoint  := AddPoints(LFigureObj.FStartPoint,  LOffsetVector);
              LFigureObj.FEndPoint    := AddPoints(LFigureObj.FEndPoint,    LOffsetVector);
              LFigureObj.FCurvePoint1 := AddPoints(LFigureObj.FCurvePoint1, LOffsetVector);
              LFigureObj.FCurvePoint2 := AddPoints(LFigureObj.FCurvePoint2, LOffsetVector);
            end;

          ffPolygon,
          ffRegularPolygon:
            begin
              for j := Low(LFigureObj.FPolygonPoints) to High(LFigureObj.FPolygonPoints) do
              begin
                LFigureObj.FPolygonPoints[j] := AddPoints(LFigureObj.FPolygonPoints[j], LOffsetVector);
              end;
            end;
        end;
      end;

      LMaskBitmap := TBitmap32.Create;
      try
        LMaskBitmap.SetSize(ANewWidth, ANewHeight);
        LMaskBitmap.Clear(clWhite32);
        FFigureList.DrawAllFigures(LMaskBitmap.Canvas, pmCopy, fdmMask);
        FFigureList.DrawAllFigures(FAssociatedLayer.Bitmap.Canvas, pmCopy, fdmRGB);
        MakeCanvasProcessedOpaque(FAssociatedLayer.Bitmap, LMaskBitmap);
      finally
        LMaskBitmap.Free;
      end;
    end;

    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);

    // process layer thumbnail
    UpdateLayerThumbnail;

    // process mask thumbnail
    ChangeMaskCanvasSize(ANewWidth, ANewHeight, AAnchor);

    // process last alpha channel bitmap
    LCutBitmap := TBitmap32.Create;
    try
      LCutBitmap.DrawMode := dmOpaque;

      CutBitmap32ByAnchorDirection(FLastAlphaChannelBmp, LCutBitmap,
                                   ANewWidth, ANewHeight, AAnchor, clBlack32);

      FLastAlphaChannelBmp.SetSize(ANewWidth, ANewHeight);
      FLastAlphaChannelBmp.Clear(clBlack32);
      DrawBitmap32ByAnchorDirection(LCutBitmap, FLastAlphaChannelBmp, AAnchor);
    finally
      LCutBitmap.Free;
    end;

    // process processed part
    FProcessedPart.SetSize(ANewWidth, ANewHeight);
    FProcessedPart.Clear(clBlack32);
  end;
end;

procedure TgmFigureLayerPanel.RotateCanvas(const AImageControl: TCustomImage32;
  const ADeg: Integer; const ADirection: TgmRotateDirection;
  const AResizeBackground: Boolean; const ABackColor: TColor32);
var
  LSourceBitmap: TBitmap32;
  LMaskBitmap  : TBitmap32;
  LTopLeft     : TPoint;
  LNewWidth    : Integer;
  LNewHeight   : Integer;
begin
  LSourceBitmap := TBitmap32.Create;
  try
    LSourceBitmap.Assign(FAssociatedLayer.Bitmap);
    RotateBitmap32(LSourceBitmap, FAssociatedLayer.Bitmap, ADirection, ADeg, 0, $00FFFFFF);
    FAssociatedLayer.Bitmap.Clear($00FFFFFF);

    LNewWidth  := FAssociatedLayer.Bitmap.Width;
    LNewHeight := FAssociatedLayer.Bitmap.Height;

    LMaskBitmap := TBitmap32.Create;
    try
      LMaskBitmap.SetSize(LNewWidth, LNewHeight);
      LMaskBitmap.Clear(clWhite32);
      FFigureList.DrawAllFigures(LMaskBitmap.Canvas, pmCopy, fdmMask);
      FFigureList.DrawAllFigures(FAssociatedLayer.Bitmap.Canvas, pmCopy, fdmRGB);
      MakeCanvasProcessedOpaque(FAssociatedLayer.Bitmap, LMaskBitmap);
    finally
      LMaskBitmap.Free;
    end;

    if AResizeBackground then
    begin
      AImageControl.Bitmap.SetSize(LNewWidth, LNewHeight);
    end;

    // retrieve the top left position of a layer
    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);

    // process region thumbnail
    UpdateLayerThumbnail;

    // process mask thumbnail.
    RotateMaskCanvas(ADeg, ADirection);

    // process last alpha channel bitmap
    LSourceBitmap.DrawMode := dmOpaque;
    LSourceBitmap.Assign(FLastAlphaChannelBmp);
    
    FLastAlphaChannelBmp.SetSize(LNewWidth, LNewHeight);
    FLastAlphaChannelBmp.Clear(clBlack32);
    FLastAlphaChannelBmp.Draw(0, 0, LSourceBitmap);

    // used to track processed part
    FProcessedPart.SetSize(LNewWidth, LNewHeight);
    FProcessedPart.Clear(clBlack32);
  finally
    LSourceBitmap.Free;
  end;
end;

procedure TgmFigureLayerPanel.CropImage(const AImageControl: TCustomImage32;
  const ACrop: TgmCrop; const ABackColor: TColor32);
var
  LCropRect    : TRect;
  LCropBitmap  : TBitmap32;
  LMaskBitmap  : TBitmap32;
  LTopLeft     : TPoint;
  LOffsetVector: TPoint;
  LFigureObj   : TgmFigureObject;
  i, j         : Integer;
  LNewWidth    : Integer;
  LNewHeight   : Integer;
  LOldWidth    : Integer;
  LOldHeight   : Integer;
begin
  LCropBitmap := TBitmap32.Create;
  try
    LCropRect := Rect(ACrop.FCropStart.X, ACrop.FCropStart.Y,
                      ACrop.FCropEnd.X,   ACrop.FCropEnd.Y);

    // Process last alpha channel bitmap
    CopyRect32WithARGB(LCropBitmap, FLastAlphaChannelBmp, LCropRect, clWhite32);
    FLastAlphaChannelBmp.Assign(LCropBitmap);

    if ACrop.IsResized then
    begin
      if (FLastAlphaChannelBmp.Width  <> ACrop.ResizeW) or
         (FLastAlphaChannelBmp.Height <> ACrop.ResizeH) then
      begin
        SmoothResize32(FLastAlphaChannelBmp, ACrop.ResizeW, ACrop.ResizeH);
      end;

      LNewWidth  := ACrop.ResizeW;
      LNewHeight := ACrop.ResizeH;
    end
    else
    begin
      LNewWidth  := ACrop.FCropEnd.X - ACrop.FCropStart.X;
      LNewHeight := ACrop.FCropEnd.Y - ACrop.FCropStart.Y;
    end;

    FAssociatedLayer.Bitmap.SetSize(LNewWidth, LNewHeight);

    LOldWidth  := ACrop.FCropEnd.X - ACrop.FCropStart.X;
    LOldHeight := ACrop.FCropEnd.Y - ACrop.FCropStart.Y;

    LTopLeft      := FFigureList.GetTopLeftFromAllFigures;
    LOffsetVector := SubtractPoints(LTopLeft, ACrop.FCropStart);

    if FFigureList.Count > 0 then
    begin
      for i := 0 to (FFigureList.Count - 1) do
      begin
        LFigureObj := TgmFigureObject(FFigureList.Items[i]);

        case LFigureObj.Flag of
          ffStraightLine,
          ffRectangle,
          ffSquare,
          ffRoundRectangle,
          ffRoundSquare,
          ffEllipse,
          ffCircle:
            begin
              // calculating the offset
              LFigureObj.FStartPoint := SubtractPoints(LFigureObj.FStartPoint, LTopLeft);
              LFigureObj.FStartPoint := AddPoints(LFigureObj.FStartPoint, LOffsetVector);

              LFigureObj.FEndPoint   := SubtractPoints(LFigureObj.FEndPoint, LTopLeft);
              LFigureObj.FEndPoint   := AddPoints(LFigureObj.FEndPoint, LOffsetVector);

              // scaling
              if ACrop.IsResized then
              begin
                LFigureObj.FStartPoint := ScalePoint(LFigureObj.FStartPoint, LOldWidth, LOldHeight, LNewWidth, LNewHeight);
                LFigureObj.FEndPoint   := ScalePoint(LFigureObj.FEndPoint,   LOldWidth, LOldHeight, LNewWidth, LNewHeight);
              end;
            end;

          ffCurve:
            begin
              // calculating the offset
              LFigureObj.FStartPoint  := SubtractPoints(LFigureObj.FStartPoint, LTopLeft);
              LFigureObj.FStartPoint  := AddPoints(LFigureObj.FStartPoint, LOffsetVector);

              LFigureObj.FEndPoint    := SubtractPoints(LFigureObj.FEndPoint, LTopLeft);
              LFigureObj.FEndPoint    := AddPoints(LFigureObj.FEndPoint, LOffsetVector);

              LFigureObj.FCurvePoint1 := SubtractPoints(LFigureObj.FCurvePoint1, LTopLeft);
              LFigureObj.FCurvePoint1 := AddPoints(LFigureObj.FCurvePoint1, LOffsetVector);

              LFigureObj.FCurvePoint2 := SubtractPoints(LFigureObj.FCurvePoint2, LTopLeft);
              LFigureObj.FCurvePoint2 := AddPoints(LFigureObj.FCurvePoint2, LOffsetVector);

              // scaling
              if ACrop.IsResized then
              begin
                LFigureObj.FStartPoint  := ScalePoint(LFigureObj.FStartPoint,  LOldWidth, LOldHeight, LNewWidth, LNewHeight);
                LFigureObj.FEndPoint    := ScalePoint(LFigureObj.FEndPoint,    LOldWidth, LOldHeight, LNewWidth, LNewHeight);
                LFigureObj.FCurvePoint1 := ScalePoint(LFigureObj.FCurvePoint1, LOldWidth, LOldHeight, LNewWidth, LNewHeight);
                LFigureObj.FCurvePoint2 := ScalePoint(LFigureObj.FCurvePoint2, LOldWidth, LOldHeight, LNewWidth, LNewHeight);
              end;
            end;

          ffPolygon,
          ffRegularPolygon:
            begin
              for j := Low(LFigureObj.FPolygonPoints) to High(LFigureObj.FPolygonPoints) do
              begin
                // calculating the offset
                LFigureObj.FPolygonPoints[j] := SubtractPoints(LFigureObj.FPolygonPoints[j], LTopLeft);
                LFigureObj.FPolygonPoints[j] := AddPoints(LFigureObj.FPolygonPoints[j], LOffsetVector);

                // scaling
                if ACrop.IsResized then
                begin
                  LFigureObj.FPolygonPoints[j] :=
                    ScalePoint(LFigureObj.FPolygonPoints[j],
                               LOldWidth, LOldHeight, LNewWidth, LNewHeight);
                end;
              end;
            end;
        end;
      end;

      LMaskBitmap := TBitmap32.Create;
      try
        LMaskBitmap.SetSize(LNewWidth, LNewHeight);
        LMaskBitmap.Clear(clWhite32);
        FFigureList.DrawAllFigures(LMaskBitmap.Canvas, pmCopy, fdmMask);
        FFigureList.DrawAllFigures(FAssociatedLayer.Bitmap.Canvas, pmCopy, fdmRGB);
        MakeCanvasProcessedOpaque(FAssociatedLayer.Bitmap, LMaskBitmap);
      finally
        LMaskBitmap.Free;
      end;
    end;

    // retrieve the top left position of a layer
    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);

    // process region thumbnail
    UpdateLayerThumbnail;

    // process Mask
    CropMask(ACrop);
    
    // process processed part
    FProcessedPart.SetSize(LNewWidth, LNewHeight);
    FProcessedPart.Clear(clBlack32);
  finally
    LCropBitmap.Free;
  end;
end;

function TgmFigureLayerPanel.DuplicateCurrentLayerPanel(
  const AOwner: TWinControl; const ALayers: TLayerCollection;
  const ALayerIndex: Integer; const ALayerName: string): TgmLayerPanel;
var
  i, LPenWidth           : Integer;
  LPenStyle              : TPenStyle;
  LPenColor, LBrushColor : TColor;
  LBrushStyle            : TBrushStyle;
  LLayer                 : TBitmapLayer;
  LFigureLayerPanel      : TgmFigureLayerPanel;
  LFigureObj, LTempFigure: TgmFigureObject;
begin
  ALayers.Insert(ALayerIndex, TBitmapLayer);

  LLayer          := TBitmapLayer(ALayers.Items[ALayerIndex]);
  LLayer.Location := FAssociatedLayer.Location;
  LLayer.Scaled   := True;
  
  LLayer.Bitmap.Assign(FAssociatedLayer.Bitmap);
  LLayer.Bitmap.MasterAlpha := 255;
  LLayer.Bitmap.DrawMode    := dmCustom;

  LFigureLayerPanel              := TgmFigureLayerPanel.Create(AOwner, LLayer);
  LFigureLayerPanel.IsDuplicated := True;

  if Self.FFigureList.Count > 0 then
  begin
    for i := 0 to (Self.FFigureList.Count - 1) do
    begin
      LFigureObj  := nil;
      LTempFigure := TgmFigureObject(Self.FFigureList.Items[i]);
      LPenWidth   := LTempFigure.PenWidth;
      LPenStyle   := LTempFigure.PenStyle;
      LPenColor   := LTempFigure.PenColor;
      LBrushStyle := LTempFigure.BrushStyle;
      LBrushColor := LTempFigure.BrushColor;

      case LTempFigure.Flag of
        ffStraightLine:
          begin
            LFigureObj := TgmLineObject.Create(LPenColor, LBrushColor, LPenStyle,
              LBrushStyle, LPenWidth, LTempFigure.FStartPoint,
              LTempFigure.FEndPoint);
          end;

        ffCurve:
          begin
             LFigureObj := TgmCurveObject.Create(LPenColor, LBrushColor,
               LPenStyle, LBrushStyle, LPenWidth, LTempFigure.FStartPoint,
               LTempFigure.FCurvePoint1, LTempFigure.FCurvePoint2,
               LTempFigure.FEndPoint);

             LFigureObj.CurveControl := LTempFigure.CurveControl;
          end;

        ffPolygon:
          begin
            LFigureObj := TgmPolygonObject.Create(LPenColor, LBrushColor,
              LPenStyle, LBrushStyle, LPenWidth, LTempFigure.FPolygonPoints);
          end;

        ffRegularPolygon:
          begin
            LFigureObj := TgmRegularPolygonObject.Create(LPenColor, LBrushColor,
              LPenStyle, LBrushStyle, LPenWidth, LTempFigure.Sides,
              LTempFigure.FStartPoint, LTempFigure.FEndPoint);
          end;

        ffRectangle,
        ffSquare:
          begin
            LFigureObj := TgmRectangleObject.Create(LPenColor, LBrushColor,
              LPenStyle, LBrushStyle, LPenWidth, LTempFigure.FStartPoint,
              LTempFigure.FEndPoint, LTempFigure.IsRegular);
          end;

        ffRoundRectangle,
        ffRoundSquare:
          begin
            LFigureObj := TgmRoundRectangleObject.Create(LPenColor, LBrushColor,
              LPenStyle, LBrushStyle, LPenWidth, LTempFigure.FStartPoint,
              LTempFigure.FEndPoint, LTempFigure.RoundCornerRadius,
              LTempFigure.IsRegular);
          end;

        ffEllipse,
        ffCircle:
          begin
            LFigureObj := TgmEllipseObject.Create(LPenColor, LBrushColor,
              LPenStyle, LBrushStyle, LPenWidth, LTempFigure.FStartPoint,
              LTempFigure.FEndPoint, LTempFigure.IsRegular);
          end;
      end;

      LFigureObj.IsSelected := LTempFigure.IsSelected;
      LFigureObj.IsLocked   := LTempFigure.IsLocked;
      LFigureObj.Name       := LTempFigure.Name;
      
      LFigureLayerPanel.FFigureList.Add(LFigureObj);
    end;
  end;

  LFigureLayerPanel.FigureList.SelectedIndex        := Self.FFigureList.SelectedIndex;
  LFigureLayerPanel.FigureList.LineNumber           := Self.FFigureList.LineNumber;
  LFigureLayerPanel.FigureList.CurveNumber          := Self.FFigureList.CurveNumber;
  LFigureLayerPanel.FigureList.PolygonNumber        := Self.FFigureList.PolygonNumber;
  LFigureLayerPanel.FigureList.RegularPolygonNumber := Self.FFigureList.RegularPolygonNumber;
  LFigureLayerPanel.FigureList.RectangleNumber      := Self.FFigureList.RectangleNumber;
  LFigureLayerPanel.FigureList.SquareNumber         := Self.FFigureList.SquareNumber;
  LFigureLayerPanel.FigureList.RoundRectangleNumber := Self.FFigureList.RoundRectangleNumber;
  LFigureLayerPanel.FigureList.RoundSquareNumber    := Self.FFigureList.RoundSquareNumber;
  LFigureLayerPanel.FigureList.EllipseNumber        := Self.FFigureList.EllipseNumber;
  LFigureLayerPanel.FigureList.CircleNumber         := Self.FFigureList.CircleNumber;
  LFigureLayerPanel.SetLayerName(ALayerName);

{ Duplicate mask }
  LFigureLayerPanel.IsHasMask         := Self.FHasMask;
  LFigureLayerPanel.IsMaskLinked      := Self.FMaskLinked;
  LFigureLayerPanel.LayerProcessStage := Self.FLayerProcessStage;
  LFigureLayerPanel.PrevProcessStage  := Self.FPrevProcessStage;

  if LFigureLayerPanel.IsHasMask then
  begin
    LFigureLayerPanel.FLastAlphaChannelBmp.Assign(Self.FLastAlphaChannelBmp);
    LFigureLayerPanel.FMaskImage.Bitmap.Assign(Self.FMaskImage.Bitmap);

    LFigureLayerPanel.UpdateMaskThumbnail;
    LFigureLayerPanel.ShowThumbnailByRightOrder;
  end;
  
  Result := LFigureLayerPanel;
end;

// save the layer to a stream for output it to a '*gmd' file later
procedure TgmFigureLayerPanel.SaveToStream(const AStream: TStream);
var
  LLayerHeader : TgmLayerHeaderVer1;
  i, LRowStride: Integer;
  LPixelBits   : PColor32;
  LByteMap     : TByteMap;
  LByteBits    : PByte;
begin
  LLayerHeader.LayerName        := FLayerName.Caption;
  LLayerHeader.LayerFeature     := Ord(lfFigure);
  LLayerHeader.BlendModeIndex   := FBlendModeIndex;
  LLayerHeader.MasterAlpha      := FLayerMasterAlpha;
  LLayerHeader.Selected         := FSelected;
  LLayerHeader.Visible          := FLayerVisible;
  LLayerHeader.LockTransparency := FLockTransparency;
  LLayerHeader.Duplicated       := FDuplicated;
  LLayerHeader.HasMask          := FHasMask;
  LLayerHeader.MaskLinked       := FMaskLinked;

  // write the layer header to stream
  AStream.Write(LLayerHeader, SizeOf(TgmLayerHeaderVer1));

  // write the pixels of the layer to stream
  LRowStride := FAssociatedLayer.Bitmap.Width * SizeOf(TColor32);

  LPixelBits := @FAssociatedLayer.Bitmap.Bits[0];
  for i := 0 to (FAssociatedLayer.Bitmap.Height - 1) do
  begin
    AStream.Write(LPixelBits^, LRowStride);
    Inc(LPixelBits, FAssociatedLayer.Bitmap.Width);
  end;

  // write the figures data to stream
  FFigureList.SaveToStream(AStream);

  // write the pixels of the bitmap with locked figures to stream
  if FFigureList.LockedFigureCount > 0 then
  begin
    LPixelBits := @FLockFigureBMP.Bits[0];

    for i := 0 to (FLockFigureBMP.Height - 1) do
    begin
      AStream.Write(LPixelBits^, LRowStride);
      Inc(LPixelBits, FLockFigureBMP.Width);
    end;
  end;

  // write the mask data to stream, if any
  if FHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      // write the mask data to stream
      LByteMap.SetSize(FMaskImage.Bitmap.Width, FMaskImage.Bitmap.Height);
      LByteMap.ReadFrom(FMaskImage.Bitmap, ctUniformRGB);

      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (FMaskImage.Bitmap.Height - 1) do
      begin
        AStream.Write(LByteBits^, FMaskImage.Bitmap.Width);
        Inc(LByteBits, FMaskImage.Bitmap.Width);
      end;

      // write the last alpha data of the layer to stream
      LByteMap.ReadFrom(FLastAlphaChannelBmp, ctUniformRGB);

      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (FLastAlphaChannelBmp.Height - 1) do
      begin
        AStream.Write(LByteBits^, FLastAlphaChannelBmp.Width);
        Inc(LByteBits, FLastAlphaChannelBmp.Width);
      end;
    finally
      LByteMap.Free;
    end;
  end;
end; 

//-- TgmShapeRegionLayerPanel --------------------------------------------------

constructor TgmShapeRegionLayerPanel.Create(const AOwner: TWinControl;
  const ALayer: TBitmapLayer);
begin
  inherited Create(AOwner, ALayer);

  FLayerFeature                    := lfShapeRegion;
  FLayerImage.PaintStages[0].Stage := PST_CLEAR_BACKGND;

  if FAssociatedLayer <> nil then
  begin
    FAssociatedLayer.Bitmap.OnPixelCombine := LayerPixelBlend;
  end;

  // create a panel for holding FRegionImage
  FRegionImageHolder := TPanel.Create(FPanel);
  with FRegionImageHolder do
  begin
    Parent     := FPanel;
    Align      := alLeft;
    AutoSize   := False;
    Width      := IMAGE_HOLDER_WIDTH;
    BevelInner := bvRaised;
    BevelOuter := bvLowered;
    BevelWidth := 1;
    Cursor     := crHandPoint;
    Left       := FLayerImageHolder.Left + FLayerImageHolder.Width;
    Visible    := True;
  end;

  // Create FRegionImage
  FRegionImage := TImage32.Create(FRegionImageHolder);
  with FRegionImage do
  begin
    Parent          := FRegionImageHolder;
    Width           := FRegionImageHolder.Width  - 2;
    Height          := FRegionImageHolder.Height - 2;
    AutoSize        := False;
    ScaleMode       := smScale;
    BitmapAlign     := baCenter;
    Cursor          := crHandPoint;
    Hint            := 'Layer clipping path thumbnail';
    ShowHint        := True;
    Left            := 1;
    Top             := 1;
    Visible         := True;
    Bitmap.DrawMode := dmOpaque;
    Bitmap.Width    := ALayer.Bitmap.Width;
    Bitmap.Height   := ALayer.Bitmap.Height;
    
    Bitmap.Clear(clGray32);

    { Force TImage32 to call the OnPaintStage event instead of performming
      default action. }
    if PaintStages[0]^.Stage = PST_CLEAR_BACKGND then
    begin
      PaintStages[0]^.Stage := PST_CUSTOM;
    end;

    OnPaintStage := RegionThumbnailPaintStage;  
  end;

  FRegionColor             := clBlack;
  FBrushStyle              := bsSolid;
  FShapeRegion             := TgmShapeRegion.Create;
  FShapeRegion.RegionColor := FRegionColor;
  FShapeRegion.BrushStyle  := FBrushStyle;

  FShapeOutlineList := TgmOutlineList.Create;

  DrawShapeRegionColorThumbnail;
end;

destructor TgmShapeRegionLayerPanel.Destroy;
begin
  FRegionImage.Free;
  FRegionImageHolder.Free;
  FShapeRegion.Free;
  FShapeOutlineList.Free;
  
  inherited Destroy;
end;

procedure TgmShapeRegionLayerPanel.SetRegionColor(const AColor: TColor);
begin
  if FRegionColor <> AColor then
  begin
    FRegionColor := AColor;
    DrawPhotoshopStyleColorThumbnail(FRegionColor);

    if FShapeRegion <> nil then
    begin
      FShapeRegion.RegionColor := FRegionColor;
      FShapeRegion.ShowRegion(FAssociatedLayer.Bitmap);
      Self.Update;
    end;
  end;
end; 

procedure TgmShapeRegionLayerPanel.SetBrushStyle(const AStyle: TBrushStyle);
begin
  if FBrushStyle <> AStyle then
  begin
    FBrushStyle := AStyle;

    if FShapeRegion <> nil then
    begin
      FShapeRegion.BrushStyle := FBrushStyle;
      FShapeRegion.ShowRegion(FAssociatedLayer.Bitmap);
      UpdateRegionThumbnial;

      if FHasMask then
      begin
        GetAlphaChannelBitmap(FAssociatedLayer.Bitmap, FLastAlphaChannelBmp);
      end;

      Self.Update;
    end;
  end;
end; 

procedure TgmShapeRegionLayerPanel.RegionThumbnailPaintStage(ASender: TObject;
  ABuffer: TBitmap32; AStageNum: Cardinal);
var
  LRect: TRect;
begin
  // draw background
  if (ABuffer.Height > 0) and (ABuffer.Width > 0) then
  begin
    ABuffer.Clear( Color32(ColorToRGB(clBtnFace)) );

    // draw thin border, written by Andre Felix Miertschink
    LRect := FRegionImage.GetBitmapRect;

    LRect.Left   := LRect.Left   - 1;
    LRect.Top    := LRect.Top    - 1;
    LRect.Right  := LRect.Right  + 1;
    LRect.Bottom := LRect.Bottom + 1;

    ABuffer.FrameRectS(LRect, clBlack32);
  end;
end;

procedure TgmShapeRegionLayerPanel.DrawShapeRegionColorThumbnail;
begin
  DrawPhotoshopStyleColorThumbnail(FRegionColor);
end;

procedure TgmShapeRegionLayerPanel.LayerPixelBlend(F: TColor32; var B: TColor32;
  M: TColor32);
begin
  FBlendModeEvent(F, B, M);
end;

procedure TgmShapeRegionLayerPanel.ChangeImageSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AOptions: TgmResamplingOptions);
var
  LTopLeft     : TPoint;
  LOriginalRect: TRect;
  LCurrentRect : TRect;
  i, j         : Integer;
  LOldWidth    : Integer;
  LOldHeight   : Integer;
  LOutline     : TgmShapeOutline;
begin
  LOldWidth  := FAssociatedLayer.Bitmap.Width;
  LOldHeight := FAssociatedLayer.Bitmap.Height;

  if (LOldWidth <> ANewWidth) or (LOldHeight <> ANewHeight) then
  begin
    // change the dimension of the associated layer
    FAssociatedLayer.Bitmap.SetSize(ANewWidth, ANewHeight);

    if FShapeOutlineList.Count > 0 then
    begin
      LOriginalRect := Rect(0, 0, LOldWidth, LOldHeight);
      LCurrentRect  := Rect(0, 0, ANewWidth, ANewHeight);

      for i := 0 to (FShapeOutlineList.Count - 1) do
      begin
        LOutline := FShapeOutlineList.Items[i];

        case LOutline.ShapeRegionTool of
          srtRectangle,
          srtRoundedRect,
          srtEllipse:
            begin
              LOutline.StartPoint := ScalePoint(LOutline.StartPoint,
                                                LOldWidth, LOldHeight,
                                                ANewWidth, ANewHeight);

              LOutline.EndPoint := ScalePoint(LOutline.EndPoint,
                                              LOldWidth, LOldHeight,
                                              ANewWidth, ANewHeight);
            end;

          srtPolygon,
          srtLine:
            begin
              for j := Low(LOutline.FPolygon) to High(LOutline.FPolygon) do
              begin
                LOutline.FPolygon[j] := ScalePoint(LOutline.FPolygon[j],
                                                   LOldWidth, LOldHeight,
                                                   ANewWidth, ANewHeight);
              end;
            end;
        end;

        LOutline.BackupCoordinates;
      end;

      FShapeOutlineList.GetShapesBoundary;
      FShapeOutlineList.BackupCoordinates;
    end;

    FShapeRegion.AccumRGN := FShapeOutlineList.GetScaledShapesRegion;
    FShapeRegion.ShowRegion(FAssociatedLayer.Bitmap);

    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);

    // process region thumbnail
    SmoothResize32(FRegionImage.Bitmap, ANewWidth, ANewHeight);
    UpdateRegionThumbnial;

    // process mask thumbnail
    ResizeMask(ANewWidth, ANewHeight, AOptions);
    
    // process last alpha channel bitmap
    SmoothResize32(FLastAlphaChannelBmp, ANewWidth, ANewHeight);
  end;
end;

procedure TgmShapeRegionLayerPanel.ChangeCanvasSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AAnchor: TgmAnchorDirection; const ABackgroundColor: TColor32);
var
  LTopLeft     : TPoint;
  LOffsetVector: TPoint;
  i, j         : Integer;
  LOldWidth    : Integer;
  LOldHeight   : Integer;
  LOutline     : TgmShapeOutline;
  LCutBitmap   : TBitmap32;
begin
  LOldWidth  := FAssociatedLayer.Bitmap.Width;
  LOldHeight := FAssociatedLayer.Bitmap.Height;

  if (LOldWidth <> ANewWidth) or (LOldHeight <> ANewHeight) then
  begin
    // change the dimension of the associated layer
    FAssociatedLayer.Bitmap.SetSize(ANewWidth, ANewHeight);

    LOffsetVector := CalcOffsetCoordinateByAnchorDirection(LOldWidth, LOldHeight,
                                                           ANewWidth, ANewHeight,
                                                           AAnchor);

    if FShapeOutlineList.Count > 0 then
    begin
      for i := 0 to (FShapeOutlineList.Count - 1) do
      begin
        LOutline := FShapeOutlineList.Items[i];

        case LOutline.ShapeRegionTool of
          srtRectangle,
          srtRoundedRect,
          srtEllipse:
            begin
              LOutline.StartPoint := AddPoints(LOutline.StartPoint, LOffsetVector);
              LOutline.EndPoint   := AddPoints(LOutline.EndPoint,   LOffsetVector);
            end;

          srtPolygon,
          srtLine:
            begin
              for j := Low(LOutline.FPolygon) to High(LOutline.FPolygon) do
              begin
                LOutline.FPolygon[j] := AddPoints(LOutline.FPolygon[j], LOffsetVector);
              end;
            end;
        end;

        LOutline.BackupCoordinates;
      end;

      FShapeOutlineList.FBoundaryTL := AddPoints(FShapeOutlineList.FBoundaryTL, LOffsetVector);
      FShapeOutlineList.FBoundaryBR := AddPoints(FShapeOutlineList.FBoundaryBR, LOffsetVector);
      
      FShapeOutlineList.BackupCoordinates;
    end;

    FShapeRegion.AccumRGN := FShapeOutlineList.GetScaledShapesRegion;
    FShapeRegion.ShowRegion(FAssociatedLayer.Bitmap);
    
    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);

    // process region thumbnail
    FRegionImage.Bitmap.SetSize(ANewWidth, ANewHeight);
    UpdateRegionThumbnial;

    // process mask thumbnail
    ChangeMaskCanvasSize(ANewWidth, ANewHeight, AAnchor);
    
    // process last alpha channel bitmap
    LCutBitmap := TBitmap32.Create;
    try
      LCutBitmap.DrawMode := dmOpaque;

      CutBitmap32ByAnchorDirection(FLastAlphaChannelBmp, LCutBitmap,
                                   ANewWidth, ANewHeight, AAnchor, clBlack32);

      FLastAlphaChannelBmp.SetSize(ANewWidth, ANewHeight);
      FLastAlphaChannelBmp.Clear(clBlack32);
      DrawBitmap32ByAnchorDirection(LCutBitmap, FLastAlphaChannelBmp, AAnchor);
    finally
      LCutBitmap.Free;
    end;
  end;
end;

procedure TgmShapeRegionLayerPanel.RotateCanvas(
  const AImageControl: TCustomImage32; const ADeg: Integer;
  const ADirection: TgmRotateDirection; const AResizeBackground: Boolean;
  const ABackColor: TColor32);
var
  LSrcBmp   : TBitmap32;
  LTopLeft  : TPoint;
  LNewWidth : Integer;
  LNewHeight: Integer;
begin
  LSrcBmp := TBitmap32.Create;
  try
    LSrcBmp.Assign(FAssociatedLayer.Bitmap);
    RotateBitmap32(LSrcBmp, FAssociatedLayer.Bitmap, ADirection, ADeg, 0, $00FFFFFF);
    FShapeRegion.ShowRegion(FAssociatedLayer.Bitmap);

    LNewWidth  := FAssociatedLayer.Bitmap.Width;
    LNewHeight := FAssociatedLayer.Bitmap.Height;

    if AResizeBackground then
    begin
      AImageControl.Bitmap.SetSize(LNewWidth, LNewHeight);
    end;

    // retrieve the top left position of a layer
    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);

    // process region thumbnail
    FRegionImage.Bitmap.SetSize(LNewWidth, LNewHeight);
    UpdateRegionThumbnial;

    // process mask thumbnail
    RotateMaskCanvas(ADeg, ADirection);

    // process last alpha channel bitmap
    LSrcBmp.DrawMode := dmOpaque;
    LSrcBmp.Assign(FLastAlphaChannelBmp);
    
    FLastAlphaChannelBmp.SetSize(LNewWidth, LNewHeight);
    FLastAlphaChannelBmp.Clear(clBlack32);
    FLastAlphaChannelBmp.Draw(0, 0, LSrcBmp);
  finally
    LSrcBmp.Free;
  end;
end; 

procedure TgmShapeRegionLayerPanel.CropImage(const AImageControl: TCustomImage32;
  const ACrop: TgmCrop; const ABackColor: TColor32);
var
  LCropRect    : TRect;
  LCropBitmap  : TBitmap32;
  LTopLeft     : TPoint;
  LOffsetVector: TPoint;
  LOutline     : TgmShapeOutline;
  i, j         : Integer;
  LNewWidth    : Integer;
  LNewHeight   : Integer;
  LOldWidth    : Integer;
  LOldHeight   : Integer;
begin
  LCropBitmap := TBitmap32.Create;
  try
    LCropRect := Rect(ACrop.FCropStart.X, ACrop.FCropStart.Y,
                      ACrop.FCropEnd.X,   ACrop.FCropEnd.Y);

    // process last alpha channel bitmap
    CopyRect32WithARGB(LCropBitmap, FLastAlphaChannelBmp, LCropRect, clWhite32);
    FLastAlphaChannelBmp.Assign(LCropBitmap);

    if ACrop.IsResized then
    begin
      if (FLastAlphaChannelBmp.Width  <> ACrop.ResizeW) or
         (FLastAlphaChannelBmp.Height <> ACrop.ResizeH) then
      begin
        SmoothResize32(FLastAlphaChannelBmp, ACrop.ResizeW, ACrop.ResizeH);
      end;

      LNewWidth  := ACrop.ResizeW;
      LNewHeight := ACrop.ResizeH;
    end
    else
    begin
      LNewWidth  := ACrop.FCropEnd.X - ACrop.FCropStart.X;
      LNewHeight := ACrop.FCropEnd.Y - ACrop.FCropStart.Y;
    end;

    FAssociatedLayer.Bitmap.SetSize(LNewWidth, LNewHeight);

    LOldWidth  := ACrop.FCropEnd.X - ACrop.FCropStart.X;
    LOldHeight := ACrop.FCropEnd.Y - ACrop.FCropStart.Y;

    LOffsetVector := SubtractPoints(FShapeOutlineList.FBoundaryTL, ACrop.FCropStart);

    if FShapeOutlineList.Count > 0 then
    begin
      for i := 0 to (FShapeOutlineList.Count - 1) do
      begin
        LOutline := FShapeOutlineList.Items[i];

        case LOutline.ShapeRegionTool of
          srtRectangle,
          srtRoundedRect,
          srtEllipse:
            begin
              // calculating the offset
              LOutline.StartPoint := SubtractPoints(LOutline.StartPoint, FShapeOutlineList.FBoundaryTL);
              LOutline.StartPoint := AddPoints(LOutline.StartPoint, LOffsetVector);

              LOutline.EndPoint   := SubtractPoints(LOutline.EndPoint, FShapeOutlineList.FBoundaryTL);
              LOutline.EndPoint   := AddPoints(LOutline.EndPoint, LOffsetVector);

              // scaling
              if ACrop.IsResized then
              begin
                LOutline.StartPoint := ScalePoint(LOutline.StartPoint, LOldWidth, LOldHeight, LNewWidth, LNewHeight);
                LOutline.EndPoint   := ScalePoint(LOutline.EndPoint,   LOldWidth, LOldHeight, LNewWidth, LNewHeight);
              end;
            end;

          srtPolygon,
          srtLine:
            begin
              for j := Low(LOutline.FPolygon) to High(LOutline.FPolygon) do
              begin
                // calculating the offset
                LOutline.FPolygon[j] := SubtractPoints(LOutline.FPolygon[j], FShapeOutlineList.FBoundaryTL);
                LOutline.FPolygon[j] := AddPoints(LOutline.FPolygon[j], LOffsetVector);

                // scaling
                if ACrop.IsResized then
                begin
                  LOutline.FPolygon[j] := ScalePoint(LOutline.FPolygon[j],
                    LOldWidth, LOldHeight, LNewWidth, LNewHeight);
                end;
              end;
            end;
        end;

        LOutline.BackupCoordinates;
      end;

      FShapeOutlineList.GetShapesBoundary;
      FShapeOutlineList.BackupCoordinates;
    end;

    FShapeRegion.AccumRGN := FShapeOutlineList.GetScaledShapesRegion;
    FShapeRegion.ShowRegion(FAssociatedLayer.Bitmap);

    // retrieve the top left position of a layer
    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);

    // process region thumbnail
    FRegionImage.Bitmap.SetSize(LNewWidth, LNewHeight);
    UpdateRegionThumbnial;
    
    // process Mask
    CropMask(ACrop);
  finally
    LCropBitmap.Free;
  end;
end; 

function TgmShapeRegionLayerPanel.DuplicateCurrentLayerPanel(
  const AOwner: TWinControl; const ALayers: TLayerCollection;
  const ALayerIndex: Integer; const ALayerName: string): TgmLayerPanel;
var
  i, j                  : Integer;
  LShapeOutline         : TgmShapeOutline;
  LTempOutline          : TgmShapeOutline;
  LLayer                : TBitmapLayer;
  LShapeRegionLayerPanel: TgmShapeRegionLayerPanel;
begin
  ALayers.Insert(ALayerIndex, TBitmapLayer);

  LLayer          := TBitmapLayer(ALayers.Items[ALayerIndex]);
  LLayer.Location := FAssociatedLayer.Location;
  LLayer.Scaled   := True;

  LLayer.Bitmap.SetSize(FAssociatedLayer.Bitmap.Width,
                        FAssociatedLayer.Bitmap.Height);
                        
  LLayer.Bitmap.DrawMode := dmCustom;

  LShapeRegionLayerPanel := TgmShapeRegionLayerPanel.Create(AOwner, LLayer);
  LShapeRegionLayerPanel.IsDuplicated := True;

  if Self.FShapeOutlineList.Count > 0 then
  begin
    LShapeRegionLayerPanel.ShapeOutlineList.FBoundaryTL := Self.FShapeOutlineList.FBoundaryTL;
    LShapeRegionLayerPanel.ShapeOutlineList.FBoundaryBR := Self.FShapeOutlineList.FBoundaryBR;
    LShapeRegionLayerPanel.ShapeOutlineList.TLBackup    := Self.FShapeOutlineList.TLBackup;
    LShapeRegionLayerPanel.ShapeOutlineList.BRBackup    := Self.FShapeOutlineList.BRBackup;
    LShapeRegionLayerPanel.ShapeOutlineList.IsStretched := Self.FShapeOutlineList.IsStretched;

    for i := 0 to (Self.FShapeOutlineList.Count - 1) do
    begin
      LShapeOutline := nil;
      LTempOutline  := Self.FShapeOutlineList.Items[i];

      case LTempOutline.ShapeRegionTool of
        srtRectangle:
          begin
            LShapeOutline := TgmRectangleOutLine.Create;
          end;

        srtRoundedRect:
          begin
            LShapeOutline := TgmRoundRectOutline.Create;
          end;
          
        srtEllipse:
          begin
            LShapeOutline := TgmEllipseOutline.Create;
          end;

        srtPolygon:
          begin
            LShapeOutline := TgmRegularPolygonOutline.Create;
          end;
          
        srtLine:
          begin
            LShapeOutline := TgmLineOutline.Create;
          end;
      end;

      LShapeOutline.StartPoint := LTempOutline.StartPoint;
      LShapeOutline.EndPoint   := LTempOutline.EndPoint;

      case LShapeOutline.ShapeRegionTool of
        srtRoundedRect:
          begin
            TgmRoundRectOutline(LShapeOutline).CornerRadius := TgmRoundRectOutline(LTempOutline).CornerRadius;
          end;
          
        srtPolygon:
          begin
            TgmRegularPolygonOutline(LShapeOutline).Sides := TgmRegularPolygonOutline(LTempOutline).Sides;
            
            SetLength( LShapeOutline.FPolygon, High(LTempOutline.FPolygon) + 1 );
            SetLength( LShapeOutline.FPolygonBackup, High(LTempOutline.FPolygonBackup) + 1 );

            for j := Low(LTempOutline.FPolygon) to High(LTempOutline.FPolygon) do
            begin
              LShapeOutline.FPolygon[j]       := LTempOutline.FPolygon[j];
              LShapeOutline.FPolygonBackup[j] := LTempOutline.FPolygonBackup[j];
            end;
          end;

        srtLine:
          begin
            TgmLineOutline(LShapeOutline).Weight := TgmLineOutline(LTempOutline).Weight;
            
            SetLength( LShapeOutline.FPolygon, High(LTempOutline.FPolygon) + 1 );
            SetLength( LShapeOutline.FPolygonBackup, High(LTempOutline.FPolygonBackup) + 1 );

            for j := Low(LTempOutline.FPolygon) to High(LTempOutline.FPolygon) do
            begin
              LShapeOutline.FPolygon[j]       := LTempOutline.FPolygon[j];
              LShapeOutline.FPolygonBackup[j] := LTempOutline.FPolygonBackup[j];
            end;
          end;
      end;

      LShapeOutline.StartPointBackup := LTempOutline.StartPointBackup;
      LShapeOutline.EndPointBackup   := LTempOutline.EndPointBackup;
      LShapeOutline.CombineMode      := LTempOutline.CombineMode;
      
      LShapeRegionLayerPanel.ShapeOutlineList.Add(LShapeOutline);
    end;

    LShapeRegionLayerPanel.BrushStyle             := Self.FBrushStyle;
    LShapeRegionLayerPanel.ShapeRegion.BrushStyle := Self.FShapeRegion.BrushStyle;
    LShapeRegionLayerPanel.RegionColor            := Self.FRegionColor;
    LShapeRegionLayerPanel.IsDismissed            := Self.FDismissed;
    
    LShapeRegionLayerPanel.FRegionImage.Bitmap.Assign(Self.FRegionImage.Bitmap);
    
    LShapeRegionLayerPanel.ShapeRegion.AccumRGN := LShapeRegionLayerPanel.ShapeOutlineList.GetScaledShapesRegion;
    LShapeRegionLayerPanel.ShapeRegion.ShowRegion(LLayer.Bitmap);
  end;

  LShapeRegionLayerPanel.BlendModeIndex   := Self.FBlendModeIndex;
  LShapeRegionLayerPanel.LayerMasterAlpha := Self.FLayerMasterAlpha;
  LShapeRegionLayerPanel.SetLayerName(ALayerName);
  LShapeRegionLayerPanel.UpdateRegionThumbnial;

{ Duplicate mask }
  LShapeRegionLayerPanel.IsHasMask         := Self.FHasMask;
  LShapeRegionLayerPanel.IsMaskLinked      := Self.FMaskLinked;
  LShapeRegionLayerPanel.LayerProcessStage := Self.FLayerProcessStage;
  LShapeRegionLayerPanel.PrevProcessStage  := Self.FPrevProcessStage;

  if LShapeRegionLayerPanel.IsHasMask then
  begin
    LShapeRegionLayerPanel.FLastAlphaChannelBmp.Assign(Self.FLastAlphaChannelBmp);
    LShapeRegionLayerPanel.FMaskImage.Bitmap.Assign(Self.FMaskImage.Bitmap);
    LShapeRegionLayerPanel.UpdateMaskThumbnail;

    LShapeRegionLayerPanel.SetThumbnailPosition;
    LShapeRegionLayerPanel.Update;
  end;

  Result := LShapeRegionLayerPanel;
end;

procedure TgmShapeRegionLayerPanel.SetThumbnailPosition;
begin
  FRegionImageHolder.Visible := False;
  ShowThumbnailByRightOrder;

  if FHasMask then
  begin
    FRegionImageHolder.Left := FMaskImageHolder.Left + FMaskImageHolder.Width;
  end
  else
  begin
    FRegionImageHolder.Left := FLayerImageHolder.Left + FLayerImageHolder.Width;
  end;

  FRegionImageHolder.Visible := True;
  FLayerName.Left            := FRegionImageHolder.Left + FRegionImageHolder.Width + 10;
end;

procedure TgmShapeRegionLayerPanel.UpdateRegionThumbnial;
var
  w, h  : Integer;
  ws, hs: Single;
begin
  FRegionImage.Bitmap.Clear(clGray32);
  FRegionImage.Bitmap.Canvas.Brush.Style := FBrushStyle;
  FRegionImage.Bitmap.Canvas.Brush.Color := clWhite;
  PaintRGN(FRegionImage.Bitmap.Canvas.Handle, FShapeRegion.AccumRGN);
  FShapeOutlineList.DrawAllOutlines( FRegionImage.Bitmap.Canvas, Point(0, 0), pmCopy );

  if FRegionImage.Bitmap.DrawMode <> dmOpaque then
  begin
    FRegionImage.Bitmap.DrawMode := dmOpaque
  end;

  // scale and center thumbnail

  w := FRegionImage.Width  - 6;
  h := FRegionImage.Height - 6;

  if (FRegionImage.Bitmap.Width  > w) or
     (FRegionImage.Bitmap.Height > h) then
  begin
    ws := w / FRegionImage.Bitmap.Width;
    hs := h / FRegionImage.Bitmap.Height;

    if ws < hs then
    begin
      FRegionImage.Scale := ws;
    end
    else
    begin
      FRegionImage.Scale := hs;
    end;
  end
  else
  begin
    FRegionImage.Scale := 1;
  end;

  FRegionImage.Bitmap.Changed;
end;

// save the layer to a stream for output it to a '*gmd' file later
procedure TgmShapeRegionLayerPanel.SaveToStream(const AStream: TStream);
var
  LLayerHeader: TgmLayerHeaderVer1;
  i, LIntValue: Integer;
  LByteMap    : TByteMap;
  LByteBits   : PByte;
begin
  LLayerHeader.LayerName        := FLayerName.Caption;
  LLayerHeader.LayerFeature     := Ord(lfShapeRegion);
  LLayerHeader.BlendModeIndex   := FBlendModeIndex;
  LLayerHeader.MasterAlpha      := FLayerMasterAlpha;
  LLayerHeader.Selected         := FSelected;
  LLayerHeader.Visible          := FLayerVisible;
  LLayerHeader.LockTransparency := FLockTransparency;
  LLayerHeader.Duplicated       := FDuplicated;
  LLayerHeader.HasMask          := FHasMask;
  LLayerHeader.MaskLinked       := FMaskLinked;

  // write the layer header to stream
  AStream.Write(LLayerHeader, SizeOf(TgmLayerHeaderVer1));

  // write the shape region data to stream
  AStream.Write(FRegionColor, 4);

  LIntValue := Ord(FBrushStyle);
  AStream.Write(LIntValue, 4);

  AStream.Write(FDismissed, 1);

  FShapeOutlineList.SaveToStream(AStream);

  // write the mask data to stream, if any
  if FHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      // write the mask data to stream
      LByteMap.SetSize(FMaskImage.Bitmap.Width, FMaskImage.Bitmap.Height);
      LByteMap.ReadFrom(FMaskImage.Bitmap, ctUniformRGB);

      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (FMaskImage.Bitmap.Height - 1) do
      begin
        AStream.Write(LByteBits^, FMaskImage.Bitmap.Width);
        Inc(LByteBits, FMaskImage.Bitmap.Width);
      end;
    finally
      LByteMap.Free;
    end;
  end;
end; 

//-- TgmRichTextLayerPanel -----------------------------------------------------

constructor TgmRichTextLayerPanel.Create(const AOwner: TWinControl;
  const ALayer: TBitmapLayer; const ATextEditor: TRichEdit);
begin
  inherited Create(AOwner, ALayer);

  FLayerImage.PaintStages[0].Stage := PST_CLEAR_BACKGND;
  FLayerFeature                    := lfRichText;

  if FAssociatedLayer <> nil then
  begin
    FAssociatedLayer.Bitmap.OnPixelCombine := LayerPixelBlend;
  end;

  FBorderStart    := Point(0, 0);
  FBorderEnd      := Point(0, 0);
  FRichTextStream := TMemoryStream.Create;
  FCopyStream     := TMemoryStream.Create;
  FTextFileName   := '';
  FTextChanged    := False;
  FEditState      := False;
  FTextLayerState := tlsNew;

  FAssociatedTextEditor := ATextEditor;

  GMDataModule := TGMDataModule.Create(nil);
  try
    // get thumbnail for the Text layer
    FLayerImage.Bitmap.Assign(GMDataModule.bmp32lstLayers.Bitmap[TEXT_LAYER_INCON_INDEX]);
  finally
    FreeAndNil(GMDataModule)
  end;
end;

destructor TgmRichTextLayerPanel.Destroy;
begin
  FRichTextStream.Free;
  FCopyStream.Free;
  
  inherited Destroy;
end;

function TgmRichTextLayerPanel.GetBorderWidth: Integer;
begin
  Result := Abs(FBorderEnd.X - FBorderStart.X);
end;

function TgmRichTextLayerPanel.GetBorderHeight: Integer;
begin
  Result := Abs(FBorderEnd.Y - FBorderStart.Y);
end;

function TgmRichTextLayerPanel.GetBorderRect: TRect;
begin
  Result := Rect(FBorderStart.X, FBorderStart.Y, FBorderEnd.X, FBorderEnd.Y);
end;

procedure TgmRichTextLayerPanel.LayerPixelBlend(F: TColor32; var B: TColor32;
  M: TColor32);
begin
  FBlendModeEvent(F, B, M);
end; 

procedure TgmRichTextLayerPanel.ChangeImageSize(const AImageControl: TCustomImage32;
  const ANewWidth, ANewHeight: Integer; const AOptions: TgmResamplingOptions);
var
  LTopLeft   : TPoint;
  LBorderRect: TRect;
  LOldWidth  : Integer;
  LOldHeight : Integer;
  LSrcBmp    : TBitmap32;
begin
  LOldWidth  := FAssociatedLayer.Bitmap.Width;
  LOldHeight := FAssociatedLayer.Bitmap.Height;

  if (LOldWidth <> ANewWidth) or (LOldHeight <> ANewHeight) then
  begin
    // Change the dimension of the associated layer.
    FAssociatedLayer.Bitmap.SetSize(ANewWidth, ANewHeight);
    FAssociatedLayer.Bitmap.Clear($00FFFFFF);

    LBorderRect := Self.GetBorderRect;
    
    Self.FRichTextStream.Position := 0;

    FAssociatedTextEditor.Lines.LoadFromStream(Self.FRichTextStream);
    DrawRichTextOnBitmap(FAssociatedLayer.Bitmap, LBorderRect, FAssociatedTextEditor);

    Self.FRichTextStream.Position := 0;
    
    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);

    // Process mask thumbnail.
    ResizeMask(ANewWidth, ANewHeight, AOptions);
    
    // Process last alpha channel bitmap
    LSrcBmp := TBitmap32.Create;
    try
      LSrcBmp.DrawMode := dmOpaque;
      
      LSrcBmp.Assign(FLastAlphaChannelBmp);
      FLastAlphaChannelBmp.SetSize(ANewWidth, ANewHeight);
      FLastAlphaChannelBmp.Clear(clBlack32);
      FLastAlphaChannelBmp.Draw(0, 0, LSrcBmp);
    finally
      LSrcBmp.Free;
    end;
  end;
end;

procedure TgmRichTextLayerPanel.ChangeCanvasSize(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AAnchor: TgmAnchorDirection; const ABackgroundColor: TColor32);
var
  LTopLeft, LOffsetVector: TPoint;
  LOldWidth, LOldHeight  : Integer;
  LBorderRect            : TRect;
  LCutBitmap             : TBitmap32;
begin
  LOldWidth  := FAssociatedLayer.Bitmap.Width;
  LOldHeight := FAssociatedLayer.Bitmap.Height;

  if (LOldWidth <> ANewWidth) or (LOldHeight <> ANewHeight) then
  begin
    // change the dimension of the associated layer
    FAssociatedLayer.Bitmap.SetSize(ANewWidth, ANewHeight);
    FAssociatedLayer.Bitmap.Clear($00FFFFFF);

    LOffsetVector := CalcOffsetCoordinateByAnchorDirection(LOldWidth, LOldHeight,
                                                           ANewWidth, ANewHeight,
                                                           AAnchor);

    Self.Translate(LOffsetVector);

    LBorderRect := Self.GetBorderRect;

    Self.FRichTextStream.Position := 0;

    FAssociatedTextEditor.Lines.LoadFromStream(Self.FRichTextStream);
    DrawRichTextOnBitmap(FAssociatedLayer.Bitmap, LBorderRect, FAssociatedTextEditor);

    Self.FRichTextStream.Position := 0;

    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);

    // process mask thumbnail
    ChangeMaskCanvasSize(ANewWidth, ANewHeight, AAnchor);
    
    // process last alpha channel bitmap
    LCutBitmap := TBitmap32.Create;
    try
      LCutBitmap.DrawMode := dmOpaque;

      CutBitmap32ByAnchorDirection(FLastAlphaChannelBmp, LCutBitmap,
                                   ANewWidth, ANewHeight, AAnchor, clBlack32);

      FLastAlphaChannelBmp.SetSize(ANewWidth, ANewHeight);
      FLastAlphaChannelBmp.Clear(clBlack32);
      DrawBitmap32ByAnchorDirection(LCutBitmap, FLastAlphaChannelBmp, AAnchor);
    finally
      LCutBitmap.Free;
    end;
  end;
end;

procedure TgmRichTextLayerPanel.RotateCanvas(const AImageControl: TCustomImage32;
  const ADeg: Integer; const ADirection: TgmRotateDirection;
  const AResizeBackground: Boolean; const ABackColor: TColor32);
var
  LSrcBmp    : TBitmap32;
  LTopLeft   : TPoint;
  LNewWidth  : Integer;
  LNewHeight : Integer;
  LBorderRect: TRect;
begin
  LSrcBmp := TBitmap32.Create;
  try
    LSrcBmp.Assign(FAssociatedLayer.Bitmap);
    RotateBitmap32(LSrcBmp, FAssociatedLayer.Bitmap, ADirection, ADeg, 0, $00FFFFFF);
    FAssociatedLayer.Bitmap.Clear($00FFFFFF);

    LNewWidth  := FAssociatedLayer.Bitmap.Width;
    LNewHeight := FAssociatedLayer.Bitmap.Height;

    if AResizeBackground then
    begin
      AImageControl.Bitmap.SetSize(LNewWidth, LNewHeight);
    end;

    LBorderRect := Self.GetBorderRect;

    Self.FRichTextStream.Position := 0;

    FAssociatedTextEditor.Lines.LoadFromStream(Self.FRichTextStream);
    DrawRichTextOnBitmap(FAssociatedLayer.Bitmap, LBorderRect, FAssociatedTextEditor);

    Self.FRichTextStream.Position := 0;

    // retrieve the top left position of a layer
    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);

    // process mask thumbnail
    RotateMaskCanvas(ADeg, ADirection);

    // process last alpha channel bitmap
    LSrcBmp.DrawMode := dmOpaque;
    LSrcBmp.Assign(FLastAlphaChannelBmp);

    FLastAlphaChannelBmp.SetSize(LNewWidth, LNewHeight);
    FLastAlphaChannelBmp.Clear(clBlack32);
    FLastAlphaChannelBmp.Draw(0, 0, LSrcBmp);
  finally
    LSrcBmp.Free;
  end;
end;

procedure TgmRichTextLayerPanel.CropImage(const AImageControl: TCustomImage32;
  const ACrop: TgmCrop; const ABackColor: TColor32);
var
  LCropRect, LBorderRect : TRect;
  LCropBitmap            : TBitmap32;
  LTopLeft, LOffsetVector: TPoint;
  LNewWidth, LNewHeight  : Integer;
begin
  LCropBitmap := TBitmap32.Create;
  try
    LCropRect := Rect(ACrop.FCropStart.X, ACrop.FCropStart.Y,
                      ACrop.FCropEnd.X,   ACrop.FCropEnd.Y);

    // Process last alpha channel bitmap
    CopyRect32WithARGB(LCropBitmap, FLastAlphaChannelBmp, LCropRect, clWhite32);
    FLastAlphaChannelBmp.Assign(LCropBitmap);

    if ACrop.IsResized then
    begin
      if (FLastAlphaChannelBmp.Width  <> ACrop.ResizeW) or
         (FLastAlphaChannelBmp.Height <> ACrop.ResizeH) then
      begin
        SmoothResize32(FLastAlphaChannelBmp, ACrop.ResizeW, ACrop.ResizeH);
      end;

      LNewWidth  := ACrop.ResizeW;
      LNewHeight := ACrop.ResizeH;
    end
    else
    begin
      LNewWidth  := ACrop.FCropEnd.X - ACrop.FCropStart.X;
      LNewHeight := ACrop.FCropEnd.Y - ACrop.FCropStart.Y;
    end;

    FAssociatedLayer.Bitmap.SetSize(LNewWidth, LNewHeight);

    LOffsetVector := SubtractPoints( Point(0, 0), ACrop.FCropStart );
    Self.Translate(LOffsetVector);

    LBorderRect := Self.GetBorderRect;

    Self.FRichTextStream.Position := 0;

    FAssociatedTextEditor.Lines.LoadFromStream(Self.FRichTextStream);
    DrawRichTextOnBitmap(FAssociatedLayer.Bitmap, LBorderRect, FAssociatedTextEditor);

    Self.FRichTextStream.Position := 0;

    // retrieve the top left position of a layer
    LTopLeft := GetBitmapTopLeftInImage32(AImageControl);

    FAssociatedLayer.Location := FloatRect(LTopLeft.X, LTopLeft.Y,
                                           AImageControl.Bitmap.Width,
                                           AImageControl.Bitmap.Height);
                                           
    // Process Mask
    CropMask(ACrop);
  finally
    LCropBitmap.Free;
  end;
end;

function TgmRichTextLayerPanel.DuplicateCurrentLayerPanel(
  const AOwner: TWinControl; const ALayers: TLayerCollection;
  const ALayerIndex: Integer; const ALayerName: string): TgmLayerPanel;
var
  LLayer             : TBitmapLayer;
  LRichTextLayerPanel: TgmRichTextLayerPanel;
begin
  ALayers.Insert(ALayerIndex, TBitmapLayer);

  LLayer          := TBitmapLayer(ALayers.Items[ALayerIndex]);
  LLayer.Location := FAssociatedLayer.Location;
  LLayer.Scaled   := True;

  LLayer.Bitmap.Assign(FAssociatedLayer.Bitmap);
  
  LLayer.Bitmap.MasterAlpha := 255;
  LLayer.Bitmap.DrawMode    := dmCustom;

  LRichTextLayerPanel := TgmRichTextLayerPanel.Create(AOwner, LLayer, Self.FAssociatedTextEditor);
  
  LRichTextLayerPanel.IsDuplicated  := True;
  LRichTextLayerPanel.TextFileName  := Self.FTextFileName;
  LRichTextLayerPanel.FBorderStart  := Self.FBorderStart;
  LRichTextLayerPanel.FBorderEnd    := Self.FBorderEnd;
  LRichTextLayerPanel.IsTextChanged := Self.FTextChanged;
  LRichTextLayerPanel.IsRenamed     := Self.FRenamed;

  Self.FCopyStream.Position     := 0;
  Self.FRichTextStream.Position := 0;
  try
    LRichTextLayerPanel.FCopyStream.LoadFromStream(Self.FCopyStream);
    LRichTextLayerPanel.FRichTextStream.LoadFromStream(Self.FRichTextStream);
  finally
    Self.FCopyStream.Position     := 0;
    Self.FRichTextStream.Position := 0;
    
    LRichTextLayerPanel.FCopyStream.Position     := 0;
    LRichTextLayerPanel.FRichTextStream.Position := 0;
  end;

  LRichTextLayerPanel.BlendModeIndex   := Self.FBlendModeIndex;
  LRichTextLayerPanel.LayerMasterAlpha := Self.FLayerMasterAlpha;
  LRichTextLayerPanel.SetLayerName(ALayerName);

{ Duplicate mask }
  LRichTextLayerPanel.IsHasMask         := Self.FHasMask;
  LRichTextLayerPanel.IsMaskLinked      := Self.FMaskLinked;
  LRichTextLayerPanel.LayerProcessStage := Self.FLayerProcessStage;
  LRichTextLayerPanel.PrevProcessStage  := Self.FPrevProcessStage;

  if LRichTextLayerPanel.IsHasMask then
  begin
    LRichTextLayerPanel.FLastAlphaChannelBmp.Assign(Self.FLastAlphaChannelBmp);
    LRichTextLayerPanel.FMaskImage.Bitmap.Assign(Self.FMaskImage.Bitmap);
    LRichTextLayerPanel.UpdateMaskThumbnail;

    LRichTextLayerPanel.ShowThumbnailByRightOrder;
  end;
  
  Result := LRichTextLayerPanel;
end;

procedure TgmRichTextLayerPanel.SetRichTextBorder(
  const AStartPoint, AEndPoint: TPoint);
begin
  FBorderStart := AStartPoint;
  FBorderEnd   := AEndPoint;
end;

procedure TgmRichTextLayerPanel.DrawRichTextBorder(const ACanvas: TCanvas;
  const AOffsetVector: TPoint);
var
  LTempPenColor   : TColor;
  LTempBrushColor : TColor;
  LTempPenWidth   : Integer;
  LTempPenStyle   : TPenStyle;
  LTempPenMode    : TPenMode;
  LTempBrushStyle : TBrushStyle;
  LStartPt, LEndPt: TPoint;
begin
  GetCanvasProperties(ACanvas, LTempPenColor, LTempBrushColor, LTempPenWidth,
                      LTempPenStyle, LTempPenMode, LTempBrushStyle);

  with ACanvas do
  begin
    Pen.Color   := clBlack;
    Pen.Style   := psDot;
    Pen.Width   := 1;
    Pen.Mode    := pmNotXor;
    Brush.Color := clWhite;
    Brush.Style := bsClear;

    LStartPt := AddPoints(FBorderStart, AOffsetVector);
    LEndPt   := AddPoints(FBorderEnd, AOffsetVector);
    
    Rectangle(LStartPt.X, LStartPt.Y, LEndPt.X, LEndPt.Y);
  end;

  SetCanvasProperties(ACanvas, LTempPenColor, LTempBrushColor, LTempPenWidth,
                      LTempPenStyle, LTempPenMode, LTempBrushStyle);
end;

procedure TgmRichTextLayerPanel.DrawRichTextBorderHandles(const ACanvas: TCanvas;
  const AOffsetVector: TPoint);
var
  i          : Integer;
  LCenterX   : Integer;
  LCenterY   : Integer;
  LStartPoint: TPoint;
  LEndPoint  : TPoint;
  LPoint     : TPoint;
begin
  LStartPoint := AddPoints(FBorderStart, AOffsetVector);
  LEndPoint   := AddPoints(FBorderEnd, AOffsetVector);
  LCenterX    := (LEndPoint.X + LStartPoint.X) div 2;
  LCenterY    := (LEndPoint.Y + LStartPoint.Y) div 2;

  for i := 0 to 7 do
  begin
    if i = 0 then
    begin
      LPoint := LStartPoint;
    end
    else if i = 1 then
    begin
      LPoint := LEndPoint;
    end
    else if i = 2 then
    begin
      LPoint := Point(LStartPoint.X, LEndPoint.Y);
    end
    else if i = 3 then
    begin
      LPoint := Point(LEndPoint.X, LStartPoint.Y);
    end
    else if i = 4 then
    begin
      LPoint := Point(LStartPoint.X, LCenterY);
    end
    else if i = 5 then
    begin
      LPoint := Point(LEndPoint.X, LCenterY);
    end
    else if i = 6 then
    begin
      LPoint := Point(LCenterX, LStartPoint.Y);
    end
    else if i = 7 then
    begin
      LPoint := Point(LCenterX, LEndPoint.Y);
    end;
    
    DrawHandle(ACanvas, LPoint, clBlack, clWhite, bsClear, pmNotXor, HANDLE_RADIUS);
  end;
end;

// determine whether the mouse pointer is over any of the handles of the text control border
function TgmRichTextLayerPanel.GetHandleAtPoint(
  const AX, AY: Integer): TgmDrawingHandle;
begin
  Result := dhNone;

  if (FBorderStart.X = FBorderEnd.X) and (FBorderStart.Y = FBorderEnd.Y) then
  begin
    Exit;
  end;

  if SquareContainsPoint( FBorderStart, HANDLE_RADIUS, Point(AX, AY) ) then
  begin
    Result := dhAxAy;
  end
  else
  if SquareContainsPoint( FBorderEnd, HANDLE_RADIUS, Point(AX, AY) ) then
  begin
    Result := dhBxBy;
  end
  else
  if SquareContainsPoint( Point(FBorderStart.X, FBorderEnd.Y), HANDLE_RADIUS, Point(AX, AY) ) then
  begin
    Result := dhAxBy;
  end
  else
  if SquareContainsPoint( Point(FBorderEnd.X, FBorderStart.Y), HANDLE_RADIUS, Point(AX, AY) ) then
  begin
    Result := dhBxAy;
  end
  else
  if SquareContainsPoint(  Point( FBorderStart.X, (FBorderEnd.Y - FBorderStart.Y) div 2 + FBorderStart.Y ),
                           HANDLE_RADIUS, Point(AX, AY)  ) then
  begin
    Result := dhLeftHalfAYBY;
  end
  else
  if SquareContainsPoint(  Point( FBorderEnd.X, (FBorderEnd.Y - FBorderStart.Y) div 2 + FBorderStart.Y ),
                           HANDLE_RADIUS, Point(AX, AY)  ) then
  begin
    Result := dhRightHalfAYBY;
  end
  else
  if SquareContainsPoint(  Point( (FBorderEnd.X - FBorderStart.X) div 2 + FBorderStart.X, FBorderStart.Y ),
                           HANDLE_RADIUS, Point(AX, AY)  ) then
  begin
    Result := dhTopHalfAXBX;
  end
  else
  if SquareContainsPoint(  Point( (FBorderEnd.X - FBorderStart.X) div 2 + FBorderStart.X, FBorderEnd.Y ),
                           HANDLE_RADIUS, Point(AX, AY) ) then
  begin
    Result := dhBottomHalfAXBX;
  end;
end;

// determine whether the mouse pointer is within the text area
function TgmRichTextLayerPanel.ContainsPoint(const ATestPoint: TPoint):  Boolean;
begin
  Result := Windows.PtInRect( Rect(FBorderStart.X, FBorderStart.Y,
                                   FBorderEnd.X, FBorderEnd.Y), ATestPoint );
end;

procedure TgmRichTextLayerPanel.Translate(const ATranslateVector: TPoint);
begin
  FBorderStart := AddPoints(FBorderStart, ATranslateVector);
  FBorderEnd   := AddPoints(FBorderEnd,   ATranslateVector);
end;

// ensure the start point of the text area is always at top left
procedure TgmRichTextLayerPanel.StandardizeOrder;
var
  LTempA, LTempB: TPoint;
begin
  LTempA := FBorderStart;
  LTempB := FBorderEnd;

  // FBorderStart is at the upper left.
  FBorderStart.X := MinIntValue([LTempA.X, LTempB.X]);
  FBorderStart.Y := MinIntValue([LTempA.Y, LTempB.Y]);
  
  // FBorderEnd is at the lower right.
  FBorderEnd.X := MaxIntValue([LTempA.X, LTempB.X]);
  FBorderEnd.Y := MaxIntValue([LTempA.Y, LTempB.Y]);
end;

procedure TgmRichTextLayerPanel.SaveEdits;
begin
  FRichTextStream.Position := 0;

  FCopyStream.LoadFromStream(FRichTextStream);

  FRichTextStream.Position := 0;
  FCopyStream.Position     := 0;
  FTextChanged             := False;
end;

procedure TgmRichTextLayerPanel.RestoreEdits;
begin
  FCopyStream.Position := 0;

  FRichTextStream.LoadFromStream(FCopyStream);
  
  FRichTextStream.Position := 0;
  FCopyStream.Position     := 0;
  FTextChanged             := False;
end;

// save the layer to a stream for output it to a '*gmd' file later
procedure TgmRichTextLayerPanel.SaveToStream(const AStream: TStream);
var
  LLayerHeader: TgmLayerHeaderVer1;
  i, LIntValue: Integer;
  LStreamSize : Int64;
  LStrValue   : string[255];
  LByteMap    : TByteMap;
  LByteBits   : PByte;
begin
  LLayerHeader.LayerName        := FLayerName.Caption;
  LLayerHeader.LayerFeature     := Ord(lfRichText);
  LLayerHeader.BlendModeIndex   := FBlendModeIndex;
  LLayerHeader.MasterAlpha      := FLayerMasterAlpha;
  LLayerHeader.Selected         := FSelected;
  LLayerHeader.Visible          := FLayerVisible;
  LLayerHeader.LockTransparency := FLockTransparency;
  LLayerHeader.Duplicated       := FDuplicated;
  LLayerHeader.HasMask          := FHasMask;
  LLayerHeader.MaskLinked       := FMaskLinked;

  // write the layer header to stream
  AStream.Write(LLayerHeader, SizeOf(TgmLayerHeaderVer1));

  // write the text layer data to stream
  LStrValue := FTextFileName;
  AStream.Write(LStrValue, SizeOf(LStrValue));

  AStream.Write(FBorderStart.X, 4);
  AStream.Write(FBorderStart.Y, 4);
  AStream.Write(FBorderEnd.X,   4);
  AStream.Write(FBorderEnd.Y,   4);

  LIntValue := Ord(FTextLayerState);
  AStream.Write(LIntValue, 4);

  AStream.Write(FEditState,   1);
  AStream.Write(FTextChanged, 1);

  // write the rich text stream to output stream
  LStreamSize := FRichTextStream.Size;
  AStream.Write(LStreamSize, SizeOf(Int64));

  if FRichTextStream.Size > 0 then
  begin
    FRichTextStream.Position := 0;
    FRichTextStream.SaveToStream(AStream);
  end;

  // write the mask data to stream, if any
  if FHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      // write the mask data to stream
      LByteMap.SetSize(FMaskImage.Bitmap.Width, FMaskImage.Bitmap.Height);
      LByteMap.ReadFrom(FMaskImage.Bitmap, ctUniformRGB);

      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (FMaskImage.Bitmap.Height - 1) do
      begin
        AStream.Write(LByteBits^, FMaskImage.Bitmap.Width);
        Inc(LByteBits, FMaskImage.Bitmap.Width);
      end;
    finally
      LByteMap.Free;
    end;
  end;
end; 

//-- TgmLayerPanelList ---------------------------------------------------------

constructor TgmLayerPanelList.Create(const ALayerCollection: TLayerCollection;
  const ALayerPanelOwner: TWinControl; const ATextEditor: TRichEdit);
begin
  inherited Create;

  FSelectedLayerPanel         := nil;
  FAssociatedChannelManager   := nil;
  FAssociatedLayerCollection  := ALayerCollection;
  FLayerPanelOwner            := ALayerPanelOwner;
  FAssociatedTextEditor       := ATextEditor;

  FOnLayerThumbnailDblClick   := nil;
  FOnLayerPanelClick          := nil;
  FOnLayerThumbnailClick      := nil;
  FOnMaskThumbnailClick       := nil;
  FOnChainImageClick          := nil;
  FOnAddLayerPanelToList      := nil;
  FOnActiveLayerPanelInList   := nil;
  FOnDeleteSelectedLayerPanel := nil;

  FCurrentIndex               := -1;
  FPrevIndex                  := -1;
  FAllowRefreshLayerPanels    := True;

  InitializeLayerNumbers;
  SetLength(FFigureLayerIndexArray, 0);
  SetLength(FSelectedFigureInfoArray, 0);
  SetLength(FSelectedFigureLayerIndexArray, 0);
end;

destructor TgmLayerPanelList.Destroy;
begin
  FSelectedLayerPanel         := nil;
  FAssociatedChannelManager   := nil;
  FAssociatedLayerCollection  := nil;
  FLayerPanelOwner            := nil;
  
  FOnLayerThumbnailDblClick   := nil;
  FOnLayerPanelClick          := nil;
  FOnLayerThumbnailClick      := nil;
  FOnMaskThumbnailClick       := nil;
  FOnChainImageClick          := nil;
  FOnAddLayerPanelToList      := nil;
  FOnActiveLayerPanelInList   := nil;
  FOnDeleteSelectedLayerPanel := nil;

  DeleteAllLayerPanels;
  
  inherited Destroy;
end;

procedure TgmLayerPanelList.SetLayerPanelInitialName(
  const ALayerPanel: TgmLayerPanel);
begin
  case ALayerPanel.LayerFeature of
    lfBackground:
      begin
        ALayerPanel.SetLayerName(LAYER_NAME_BACKGROUND);
      end;

    lfTransparent, lfRichText:
      begin
        Inc(FTransparentLayerNumber);
        ALayerPanel.SetLayerName( LAYER_NAME_TRANSPARENT + IntToStr(FTransparentLayerNumber) );
      end;

    lfSolidColor:
      begin
        Inc(FSolidColorLayerNumber);
        ALayerPanel.SetLayerName( LAYER_NAME_SOLID_COLOR + IntToStr(FSolidColorLayerNumber) );
      end;

    lfGradientFill:
      begin
        Inc(FGradientFillLayerNumber);
        ALayerPanel.SetLayerName( LAYER_NAME_GRADIENT_FILL + IntToStr(FGradientFillLayerNumber) );
      end;

    lfCurves:
      begin
        Inc(FCurvesLayerNumber);
        ALayerPanel.SetLayerName( LAYER_NAME_GIMP_CURVES + IntToStr(FCurvesLayerNumber) );
      end;

    lfLevels:
      begin
        Inc(FLevelsLayerNumber);
        ALayerPanel.SetLayerName( LAYER_NAME_GIMP_LEVELS + IntToStr(FLevelsLayerNumber) );
      end;

    lfColorBalance:
      begin
        Inc(FColorBalanceLayerNumber);
        ALayerPanel.SetLayerName( LAYER_NAME_COLOR_BALANCE + IntToStr(FColorBalanceLayerNumber) );
      end;

    lfBrightContrast:
      begin
        Inc(FBrightContrastLayerNumber);
        ALayerPanel.SetLayerName( LAYER_NAME_BRIGHT_CONTRAST + IntToStr(FBrightContrastLayerNumber) );
      end;

    lfHLSOrHSV:
      begin
        Inc(FHLSOrHSVLayerNumber);
        ALayerPanel.SetLayerName( LAYER_NAME_HLS_HSV + IntToStr(FHLSOrHSVLayerNumber) );
      end;

    lfChannelMixer:
      begin
        Inc(FChannelMixerLayerNumber);
        ALayerPanel.SetLayerName( LAYER_NAME_CHANNEL_MIXER + IntToStr(FChannelMixerLayerNumber) );
      end;

    lfGradientMap:
      begin
        Inc(FGradientMapLayerNumber);
        ALayerPanel.SetLayerName( LAYER_NAME_GRADIENT_MAP + IntToStr(FGradientMapLayerNumber) );
      end;

    lfInvert:
      begin
        Inc(FInvertLayerNumber);
        ALayerPanel.SetLayerName( LAYER_NAME_INVERT + IntToStr(FInvertLayerNumber) );
      end;

    lfThreshold:
      begin
        Inc(FThresholdLayerNumber);
        ALayerPanel.SetLayerName( LAYER_NAME_THRESHOLD + IntToStr(FThresholdLayerNumber) );
      end;

    lfPosterize:
      begin
        Inc(FPosterizeLayerNumber);
        ALayerPanel.SetLayerName( LAYER_NAME_POSTERIZE + IntToStr(FPosterizeLayerNumber) );
      end;

    lfPattern:
      begin
        Inc(FPatternLayerNumber);
        ALayerPanel.SetLayerName( LAYER_NAME_PATTERN + IntToStr(FPatternLayerNumber) );
      end;

    lfFigure:
      begin
        Inc(FFigureLayerNumber);
        ALayerPanel.SetLayerName( LAYER_NAME_FIGURE + IntToStr(FFigureLayerNumber) );
      end;
      
    lfShapeRegion:
      begin
        Inc(FShapeRegionLayerNumber);
        ALayerPanel.SetLayerName( LAYER_NAME_SHAPE_REGION + IntToStr(FShapeRegionLayerNumber) );
      end;
  end;
end;

procedure TgmLayerPanelList.MergeVisibleLayersToBitmap(
  const ADestBmp: TBitmap32);
var
  i, j        : Integer;
  LForeBit    : PColor32;
  LBackBit    : PColor32;
  LMasterAlpha: TColor32;
  LLayerPanel : TgmLayerPanel;
begin
  if Self.Count > 0 then
  begin
    for i := 0 to (Self.Count - 1) do
    begin
      LLayerPanel := TgmLayerPanel(Self.Items[i]);

      if LLayerPanel.IsLayerVisible then
      begin
        LLayerPanel.IsMerged := True;

        LMasterAlpha := TColor32(LLayerPanel.FAssociatedLayer.Bitmap.MasterAlpha);
        LBackBit     := @ADestBmp.Bits[0];
        LForeBit     := @LLayerPanel.FAssociatedLayer.Bitmap.Bits[0];

        for j := 0 to (ADestBmp.Width * ADestBmp.Height - 1) do
        begin
          // merge layers with the blending mathod of themselves
          LLayerPanel.LayerPixelBlend(LForeBit^, LBackBit^, LMasterAlpha);
          Inc(LBackBit);
          Inc(LForeBit);
        end;
      end;
    end;
  end;
end;

procedure TgmLayerPanelList.MergeLayersToBitmapByIndex(
  const ADestBmp: TBitmap32; const AIndexArray: array of Integer);
var
  i, j, LIndex      : Integer;
  LBackBit, LForeBit: PColor32;
  LMasterAlpha      : TColor32;
  LLayerPanel       : TgmLayerPanel;
begin
  if Self.Count > 1 then
  begin
    for i := 0 to High(AIndexArray) do
    begin
      LIndex := AIndexArray[i];

      if (LIndex >= 0) and (LIndex < Self.Count) then
      begin
        LLayerPanel  := TgmLayerPanel(Self.Items[LIndex]);
        LMasterAlpha := TColor32(LLayerPanel.FAssociatedLayer.Bitmap.MasterAlpha);
        LBackBit     := @ADestBmp.Bits[0];
        LForeBit     := @LLayerPanel.FAssociatedLayer.Bitmap.Bits[0];

        for j := 0 to (ADestBmp.Width * ADestBmp.Height - 1) do
        begin
          // merge layers with the blending mathod of themselves
          LLayerPanel.LayerPixelBlend(LForeBit^, LBackBit^, LMasterAlpha);
          Inc(LBackBit);
          Inc(LForeBit);
        end;
      end;
    end;
  end;
end;

procedure TgmLayerPanelList.DeleteMergedLayers;
var
  i          : Integer;
  LLayerPanel: TgmLayerPanel;
begin
  if Self.Count > 0 then
  begin
    for i := (Self.Count - 1) downto 0 do
    begin
      LLayerPanel := TgmLayerPanel(Self.Items[i]);
      
      if LLayerPanel.IsMerged then
      begin
        if Assigned(FAssociatedLayerCollection) then
        begin
          FAssociatedLayerCollection.Delete(i);
        end;
        
        LLayerPanel.Panel.Visible := False;
        LLayerPanel.Free;
        Self.Delete(i);
      end;
    end;
  end;
end;

procedure TgmLayerPanelList.DeleteAllLayerPanels;
var
  i          : Integer;
  LLayerPanel: TgmLayerPanel;
begin
  if Self.Count > 0 then
  begin
    for i := (Self.Count - 1) downto 0 do
    begin
      LLayerPanel := TgmLayerPanel(Self.Items[i]);
      LLayerPanel.Panel.Visible := False;
      LLayerPanel.Free;
    end;
    
    Self.Clear;
  end;
end;

procedure TgmLayerPanelList.DeselectAllLayerPanels;
var
  i          : Integer;
  LLayerPanel: TgmLayerPanel;
begin
  if Self.Count > 0 then
  begin
    for i := 0 to (Self.Count - 1) do
    begin
      LLayerPanel := TgmLayerPanel(Self.Items[i]);

      if LLayerPanel.IsSelected <> False then
      begin
        LLayerPanel.IsSelected := False;
      end;
    end;
  end;
end;

procedure TgmLayerPanelList.SynchronizeIndex;
begin
  FPrevIndex := FCurrentIndex;
end;

procedure TgmLayerPanelList.AssociateToChannelManager(
  const AChannelManager: TgmChannelManager);
begin
  FAssociatedChannelManager := AChannelManager;
end;

procedure TgmLayerPanelList.SetCurrentIndex(const AValue: Integer);
begin
  if Self.Count > 0 then
  begin
    if (AValue >= 0) and (AValue < Self.Count) then
    begin
      FCurrentIndex       := AValue;
      FSelectedLayerPanel := TgmLayerPanel(Self.Items[FCurrentIndex]);
    end;
  end;
end;

function TgmLayerPanelList.GetFirstVisibleLayerIndex: Integer;
var
  i          : Integer;
  LLayerPanel: TgmLayerPanel;
begin
  Result := -1;
  
  if Self.Count > 0 then
  begin
    for i := 0 to (Self.Count - 1) do
    begin
      LLayerPanel := TgmLayerPanel(Self.Items[i]);
      
      if LLayerPanel.IsLayerVisible then
      begin
        Result := i;
        Break;
      end;
    end;
  end;
end;

function TgmLayerPanelList.GetSelectedFigureCount: Integer;
begin
  Result := High(FSelectedFigureInfoArray) + 1;
end;

function TgmLayerPanelList.GetClickedLayerPanelIndex(
  const ASender: TObject): Integer;
var
  i          : Integer;
  LLayerPanel: TgmLayerPanel;
begin
  Result := -1;

  if Self.Count > 0 then
  begin
    for i := 0 to (Self.Count - 1) do
    begin
      LLayerPanel := TgmLayerPanel(Self.Items[i]);

      if LLayerPanel.PointOnLayerPanel(ASender) then
      begin
        Result := i;
        Break;
      end;
    end;
  end;
end;

procedure TgmLayerPanelList.ChainImageClick(ASender: TObject);
var
  i          : Integer;
  LLayerPanel: TgmLayerPanel;
begin
  if Self.Count > 0 then
  begin
    for i := 0 to (Self.Count - 1) do
    begin
      LLayerPanel := TgmLayerPanel(Self.Items[i]);

      if LLayerPanel.PointOnChainImage(ASender) then
      begin
        LLayerPanel.IsMaskLinked := not LLayerPanel.IsMaskLinked;

        if LLayerPanel.IsMaskLinked then
        begin
          if not LLayerPanel.IsHoldMaskInLayerAlpha then
          begin
            ChangeAlphaChannelBySubMask(LLayerPanel.AssociatedLayer.Bitmap,
                                        LLayerPanel.FLastAlphaChannelBmp,
                                        LLayerPanel.FMaskImage.Bitmap);
          end;
        end
        else
        begin
          if not LLayerPanel.IsHoldMaskInLayerAlpha then
          begin
            ReplaceAlphaChannelWithMask(LLayerPanel.AssociatedLayer.Bitmap,
                                        LLayerPanel.FLastAlphaChannelBmp);
          end;
        end;

        LLayerPanel.AssociatedLayer.Changed;
        LLayerPanel.UpdateLayerThumbnail;

        if Assigned(FAssociatedChannelManager) then
        begin
          FAssociatedChannelManager.UpdateColorChannelThumbnails(Self);
        end;

        if Assigned(FOnChainImageClick) then
        begin
          FOnChainImageClick(nil, i);
        end;

        Break;
      end;
    end;
  end;
end;

procedure TgmLayerPanelList.UpdatePanelsState;
var
  i          : Integer;
  LLayerPanel: TgmLayerPanel;
begin
  if Self.Count > 0 then
  begin
    for i := 0 to (Self.Count - 1) do
    begin
      LLayerPanel := Self.Items[i];
      LLayerPanel.UpdateLayerPanelState;
    end;
  end;
end;

procedure TgmLayerPanelList.LayerPanelClick(ASender: TObject);
begin
  if Assigned(FOnLayerPanelClick) then
  begin
    FOnLayerPanelClick(ASender);
  end;
end;

procedure TgmLayerPanelList.LayerVisibleClick(ASender: TObject);
var
  i          : Integer;
  LLayerPanel: TgmLayerPanel;
begin
  if Self.Count > 0 then
  begin
    for i := 0 to (Self.Count - 1) do
    begin
      LLayerPanel := Self.Items[i];

      if (ASender = LLayerPanel.FEyeImage) or
         (ASender = LLayerPanel.FEyeImageHolder) then
      begin
        LLayerPanel.IsLayerVisible := (not LLayerPanel.IsLayerVisible);

        // update channel thumbnails
        if Assigned(FAssociatedChannelManager) then
        begin
          FAssociatedChannelManager.UpdateColorChannelThumbnails(Self);
        end;
        
        Break;
      end;
    end;
  end;
end;

procedure TgmLayerPanelList.LayerThumbnailClick(ASender: TObject);
begin
  if Assigned(FOnLayerThumbnailClick) then
  begin
    FOnLayerThumbnailClick(ASender);
  end;
end;

procedure TgmLayerPanelList.MaskThumbnailClick(ASender: TObject);
begin
  if Assigned(FOnMaskThumbnailClick) then
  begin
    FOnMaskThumbnailClick(ASender);
  end;
end;

procedure TgmLayerPanelList.ConnectEventsToLayerPanel(
  const ALayerPanel: TgmLayerPanel);
begin
  ALayerPanel.Panel.OnClick            := LayerPanelClick;
  ALayerPanel.LayerName.OnClick        := LayerPanelClick;
  ALayerPanel.EyeImage.OnClick         := LayerVisibleClick;
  ALayerPanel.EyeImageHolder.OnClick   := LayerVisibleClick;
  ALayerPanel.LayerImage.OnClick       := LayerThumbnailClick;
  ALayerPanel.LayerImageHolder.OnClick := LayerThumbnailClick;
  ALayerPanel.FMaskImage.OnClick       := MaskThumbnailClick;
  ALayerPanel.MaskImageHolder.OnClick  := MaskThumbnailClick;
  ALayerPanel.ChainImage.OnClick       := ChainImageClick;
  ALayerPanel.ChainImageHolder.OnClick := ChainImageClick;
  ALayerPanel.OnLayerThumbnailDblClick := Self.FOnLayerThumbnailDblClick;
end; 

procedure TgmLayerPanelList.AddLayerPanelToList(const ALayerPanel: TgmLayerPanel);
begin
  DeselectAllLayerPanels;

  // and a new layer panel and connect events to it
  ALayerPanel.FPanelList := Self;  // make the list be accessible to the layer panel
  Self.Add(ALayerPanel);

  FCurrentIndex       := Self.Count - 1;
  FPrevIndex          := FCurrentIndex;  // synchronize index for comparison
  FSelectedLayerPanel := TgmLayerPanel(Self.Items[Self.Count - 1]);

  if not FSelectedLayerPanel.IsDuplicated then
  begin
    SetLayerPanelInitialName(FSelectedLayerPanel);
  end;

  ConnectEventsToLayerPanel(FSelectedLayerPanel);

  if Assigned(FOnAddLayerPanelToList) then
  begin
    FOnAddLayerPanelToList(Self);
  end;
end;

procedure TgmLayerPanelList.InsertLayerPanelToList(const AIndex: Integer;
  const ALayerPanel: TgmLayerPanel);
begin
  DeselectAllLayerPanels;

  // and a new layer panel and connect events to it
  ALayerPanel.FPanelList := Self; // make the list be accessible to the layer panel
  Self.Insert(AIndex, ALayerPanel);
  
  FCurrentIndex       := AIndex;
  FPrevIndex          := FCurrentIndex;  // synchronize index for comparison
  FSelectedLayerPanel := Self.Items[AIndex];

  if not FSelectedLayerPanel.IsDuplicated then
  begin
    SetLayerPanelInitialName(FSelectedLayerPanel);
  end;

  ConnectEventsToLayerPanel(FSelectedLayerPanel);

  if Assigned(FOnAddLayerPanelToList) then
  begin
    FOnAddLayerPanelToList(Self);
  end;
end;

procedure TgmLayerPanelList.DeleteSelectedLayerPanel;
var
  i, LNextSelectIndex: Integer;
  LLayerPanel        : TgmLayerPanel;
begin
  { Search for the selected layer panel, delete it from the layer panel list,
    and simultaneously, the layers will be removed and freed from the
    imgDrawingArea.Layers in the child form. }
  if Self.Count > 0 then
  begin
    for i := (Self.Count - 1) downto 0 do
    begin
      LLayerPanel := TgmLayerPanel(Self.Items[i]);

      if LLayerPanel.IsSelected then
      begin
        LLayerPanel.Panel.Visible := False;
        LLayerPanel.Free;
        Self.Delete(i);

        if Assigned(FAssociatedLayerCollection) then
        begin
          FAssociatedLayerCollection.Delete(i);
        end;
        
        Break;
      end;
    end;
  end;

  FSelectedLayerPanel := nil;

  // select the previous layer if there is any
  if Self.Count > 0 then
  begin
    LNextSelectIndex := FCurrentIndex - 1;

    if LNextSelectIndex < 0 then
    begin
      LNextSelectIndex := 0;
    end;

    FCurrentIndex                  := LNextSelectIndex;
    FSelectedLayerPanel            := TgmLayerPanel(Self.Items[FCurrentIndex]);
    FSelectedLayerPanel.IsSelected := True;
    UpdatePanelsState;
  end;

  if Assigned(FOnDeleteSelectedLayerPanel) then
  begin
    FOnDeleteSelectedLayerPanel(Self);
  end;
end;

procedure TgmLayerPanelList.DeleteLayerPanelByIndex(const AIndex: Integer);
var
  LNextSelectIndex: Integer;
  LLayerPanel     : TgmLayerPanel;
begin
  if Self.Count > 0 then
  begin
    if (Self.Count > 1) and (AIndex >= 0) and (AIndex < Self.Count) then
    begin
      LLayerPanel               := TgmLayerPanel(Self.Items[AIndex]);
      LLayerPanel.Panel.Visible := False;
      
      LLayerPanel.Free;
      Self.Delete(AIndex);

      if Assigned(FAssociatedLayerCollection) then
      begin
        FAssociatedLayerCollection.Delete(AIndex);
      end;
    end
    else
    begin
      Exit;
    end;
  end;

  // select the previous layer if there is any
  if Self.Count > 0 then
  begin
    LNextSelectIndex := FCurrentIndex - 1;

    if LNextSelectIndex < 0 then
    begin
      LNextSelectIndex := 0;
    end;

    // deselect all the layer panels first
    DeselectAllLayerPanels;
    ActiveLayerPanel(LNextSelectIndex);

    // update the thumbnails of RGB channels in channel manager
    if Assigned(FAssociatedChannelManager) then
    begin
      FAssociatedChannelManager.UpdateColorChannelThumbnails(Self);
    end;
  end;
end;

procedure TgmLayerPanelList.DecreaseSpecialLayerPanelNumber(
  const AFeature: TgmLayerFeature; const AAmount: Integer = 1);
begin
  if AAmount > 0 then
  begin
    case AFeature of
      lfSolidColor:
        begin
          Dec(FSolidColorLayerNumber, AAmount);
        end;
        
      lfBrightContrast:
        begin
          Dec(FBrightContrastLayerNumber, AAmount);
        end;
        
      lfCurves:
        begin
          Dec(FCurvesLayerNumber, AAmount);
        end;
        
      lfLevels:
        begin
          Dec(FLevelsLayerNumber, AAmount);
        end;
        
      lfColorBalance:
        begin
          Dec(FColorBalanceLayerNumber, AAmount);
        end;
        
      lfHLSOrHSV:
        begin
          Dec(FHLSOrHSVLayerNumber, AAmount);
        end;
        
      lfInvert:
        begin
          Dec(FInvertLayerNumber, AAmount);
        end;
        
      lfThreshold:
        begin
          Dec(FThresholdLayerNumber, AAmount);
        end;
        
      lfPosterize:
        begin
          Dec(FPosterizeLayerNumber, AAmount);
        end;
        
      lfPattern:
        begin
          Dec(FPatternLayerNumber, AAmount);
        end;
        
      lfChannelMixer:
        begin
          Dec(FChannelMixerLayerNumber, AAmount);
        end;
        
      lfGradientMap:
        begin
          Dec(FGradientMapLayerNumber, AAmount);
        end;
        
      lfGradientFill:
        begin
          Dec(FGradientFillLayerNumber, AAmount);
        end;
    end;
  end;
end;

procedure TgmLayerPanelList.ShowAllLayerPanels;
var
  i          : Integer;
  LLayerPanel: TgmLayerPanel;
begin
  // recalculating the top property of the Panel for display them in right order
  if Self.Count > 0 then
  begin
    for i := (Self.Count - 1) downto 0 do
    begin
      LLayerPanel            := TgmLayerPanel(Self.Items[i]);
      LLayerPanel.Panel.Left := 0;
      LLayerPanel.Panel.Top  := (Self.Count - 1 - i) * LLayerPanel.Panel.Height;

      if LLayerPanel.LayerFeature = lfShapeRegion then
      begin
        TgmShapeRegionLayerPanel(LLayerPanel).SetThumbnailPosition;
      end
      else
      begin
        LLayerPanel.ShowThumbnailByRightOrder;
      end;

      LLayerPanel.Panel.Show;
    end;
  end;
end;

procedure TgmLayerPanelList.HideAllLayerPanels;
var
  i          : Integer;
  LLayerPanel: TgmLayerPanel;
begin
  if Self.Count > 0 then
  begin
    for i := (Self.Count - 1) downto 0 do
    begin
      LLayerPanel := TgmLayerPanel(Self.Items[i]);
      LLayerPanel.Panel.Hide;
    end;
  end;
end;

procedure TgmLayerPanelList.InitializeLayerNumbers;
begin
  FTransparentLayerNumber    := 0;
  FSolidColorLayerNumber     := 0;
  FCurvesLayerNumber         := 0;
  FLevelsLayerNumber         := 0;
  FColorBalanceLayerNumber   := 0;
  FBrightContrastLayerNumber := 0;
  FHLSOrHSVLayerNumber       := 0;
  FInvertLayerNumber         := 0;
  FThresholdLayerNumber      := 0;
  FPosterizeLayerNumber      := 0;
  FPatternLayerNumber        := 0;
  FFigureLayerNumber         := 0;
  FChannelMixerLayerNumber   := 0;
  FGradientMapLayerNumber    := 0;
  FGradientFillLayerNumber   := 0;
  FShapeRegionLayerNumber    := 0;
end;

procedure TgmLayerPanelList.ActiveLayerPanel(const AIndex: Integer);
begin
  if (AIndex < 0) or
     (AIndex > Self.Count - 1) or
     (AIndex = FCurrentIndex) then
  begin
    Exit;
  end;

  FCurrentIndex := AIndex;
  FPrevIndex    := FCurrentIndex;  // synchronize index for comparison

  DeselectAllLayerPanels;

  // select the specified one...
  FSelectedLayerPanel                   := TgmLayerPanel(Self.Items[AIndex]);
  FSelectedLayerPanel.IsSelected        := True;
  FSelectedLayerPanel.LayerProcessStage := lpsLayer;
  FSelectedLayerPanel.PrevProcessStage  := lpsLayer;

  UpdatePanelsState;

  if Assigned(FOnActiveLayerPanelInList) then
  begin
    FOnActiveLayerPanelInList(Self);
  end;
end; 

procedure TgmLayerPanelList.ChangeImageSizeForAllLayers(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AOptions: TgmResamplingOptions);
var
  i          : Integer;
  LLayerPanel: TgmLayerPanel;
begin
  if Self.Count > 0 then
  begin
    for i := 0 to (Self.Count - 1) do
    begin
      LLayerPanel := TgmLayerPanel(Self.Items[i]);
      LLayerPanel.ChangeImageSize(AImageControl, ANewWidth, ANewHeight, AOptions);
    end;
  end;
end; 

procedure TgmLayerPanelList.ChangeCanvasSizeForAllLayers(
  const AImageControl: TCustomImage32; const ANewWidth, ANewHeight: Integer;
  const AAnchor: TgmAnchorDirection; const ABackgroundColor: TColor32);
var
  i          : Integer;
  LLayerPanel: TgmLayerPanel;
begin
  if Self.Count > 0 then
  begin
    for i := 0 to (Self.Count - 1) do
    begin
      LLayerPanel := TgmLayerPanel(Self.Items[i]);

      LLayerPanel.ChangeCanvasSize(AImageControl, ANewWidth, ANewHeight,
                                   AAnchor, ABackgroundColor);
    end;
  end;
end;

procedure TgmLayerPanelList.RotateCanvasForAllLayers(
  const AImageControl: TCustomImage32; const ADeg: Integer;
  const ADirection: TgmRotateDirection; const ABackColor: TColor32);
var
  i                : Integer;
  LLayerPanel      : TgmLayerPanel;
  LResizeBackground: Boolean;
begin
  if Self.Count > 0 then
  begin
    for i := 0 to (Self.Count - 1) do
    begin
      LResizeBackground := (i = 0);
      LLayerPanel       := TgmLayerPanel(Self.Items[i]);
      
      LLayerPanel.RotateCanvas(AImageControl, ADeg, ADirection, LResizeBackground,
                               ABackColor);
    end;
  end;
end;

procedure TgmLayerPanelList.CropImageForAllLayers(const AImageControl: TCustomImage32;
  const ACrop: TgmCrop; const ABackColor: TColor32);
var
  i          : Integer;
  LLayerPanel: TgmLayerPanel;
begin
  if Self.Count > 0 then
  begin
    for i := 0 to (Self.Count - 1) do
    begin
      LLayerPanel := TgmLayerPanel(Self.Items[i]);
      LLayerPanel.CropImage(AImageControl, ACrop, ABackColor);
    end;
  end;
end;

procedure TgmLayerPanelList.SetLocationForAllLayers(const ALocation: TFloatRect);
var
  i          : Integer;
  LLayerPanel: TgmLayerPanel;
begin
  if Self.Count > 0 then
  begin
    for i := 0 to (Self.Count - 1) do
    begin
      LLayerPanel := TgmLayerPanel(Self.Items[i]);
      LLayerPanel.AssociatedLayer.Location := ALocation;
    end;
  end;
end;

function TgmLayerPanelList.GetLayerPanelByIndex(
  const AIndex:Integer): TgmLayerPanel;
begin
  Result := nil;

  if Self.Count > 0 then
  begin
    if (AIndex >= 0) and (AIndex < Self.Count) then
    begin
      Result := TgmLayerPanel(Self.Items[AIndex]);
    end;
  end;
end;

function TgmLayerPanelList.GetLayerPanelByName(
  const ALayerName: string): TgmLayerPanel;
var
  i          : Integer;
  LLayerPanel: TgmLayerPanel;
begin
  Result := nil;

  if (Self.Count > 0) and (ALayerName <> '') then
  begin
    for i := 0 to (Self.Count - 1) do
    begin
      LLayerPanel := TgmLayerPanel(Self.Items[i]);

      if ALayerName = LLayerPanel.LayerName.Caption then
      begin
        Result := LLayerPanel;
        Break;
      end;
    end;
  end;
end;

function TgmLayerPanelList.GetFirstSelectedLayerPanelIndex: Integer;
var
  i          : Integer;
  LLayerPanel: TgmLayerPanel;
begin
  Result := -1;

  if Self.Count > 0 then
  begin
    for i := 0 to (Self.Count - 1) do
    begin
      LLayerPanel := TgmLayerPanel(Self.Items[i]);

      if LLayerPanel.IsSelected then
      begin
        Result := i;
        Break;
      end;
    end;
  end;
end;

function TgmLayerPanelList.GetBackgroundLayerPanelIndex: Integer;
var
  i          : Integer;
  LLayerPanel: TgmLayerPanel;
begin
  Result := -1;

  if Self.Count > 0 then
  begin
    Result := 0; // return the first index by default

    for i := 0 to (Self.Count - 1) do
    begin
      LLayerPanel := TgmLayerPanel(Self.Items[i]);

      if LLayerPanel.LayerFeature = lfBackground then
      begin
        Result := i;
        Break;
      end;
    end;
  end;
end; 

{ Merge layers }

function TgmLayerPanelList.GetVisibleLayerCount: Integer;
var
  i          : Integer;
  LLayerPanel: TgmLayerPanel;
begin
  Result := 0;

  if Self.Count > 0 then
  begin
    for i := 0 to (Self.Count - 1) do
    begin
      LLayerPanel := TgmLayerPanel(Self.Items[i]);
      
      if LLayerPanel.IsLayerVisible then
      begin
        Inc(Result);
      end;
    end;
  end;
end; 

procedure TgmLayerPanelList.MergeVisble;
var
  LVisibleCount: Integer;
  LLayerPanel  : TgmLayerPanel;
  LMergedBitmap: TBitmap32;
  LNewLayer    : TBitmapLayer;
  LTempLayer   : TBitmapLayer;
  LLocation    : TFloatRect;
begin
  if ( not Assigned(FAssociatedLayerCollection) ) or
     ( not Assigned(FLayerPanelOwner) ) then
  begin
    Exit;
  end;

  if Self.Count > 1 then
  begin
    LVisibleCount := GetVisibleLayerCount;

    if LVisibleCount > 1 then
    begin
      LTempLayer  := TBitmapLayer(FAssociatedLayerCollection[0]);
      LLocation   := LTempLayer.Location;
      LLayerPanel := TgmLayerPanel(Self.Items[FCurrentIndex]);
      
      if LLayerPanel.IsLayerVisible then
      begin
        if FAllowRefreshLayerPanels then
        begin
          HideAllLayerPanels;
        end;

        LMergedBitmap := TBitmap32.Create;
        try
          LMergedBitmap.DrawMode := dmCustom;
          LMergedBitmap.OnPixelCombine := BlendMode.NormalBlend;
          LMergedBitmap.SetSize(LTempLayer.Bitmap.Width, LTempLayer.Bitmap.Height);
          MergeVisibleLayersToBitmap(LMergedBitmap);

          // create a new layer
          FAssociatedLayerCollection.Insert(FCurrentIndex, TBitmapLayer);

          LNewLayer          := TBitmapLayer(FAssociatedLayerCollection[FCurrentIndex]);
          LNewLayer.Scaled   := True;
          LNewLayer.Location := LLocation;
          LNewLayer.Bitmap.Assign(LMergedBitmap);
          LNewLayer.Bitmap.DrawMode := dmCustom;

          // create a new panel.
          LLayerPanel := TgmTransparentLayerPanel.Create(FLayerPanelOwner, LNewLayer);
          Self.InsertLayerPanelToList(FCurrentIndex, LLayerPanel);

          // Delete all merged layers.
          DeleteMergedLayers;

          FCurrentIndex := GetFirstVisibleLayerIndex;
          UpdatePanelsState;
        finally
          LMergedBitmap.Free;
        end;

        if FAllowRefreshLayerPanels then
        begin
          ShowAllLayerPanels;
        end;
      end;
    end;
  end;
end;

procedure TgmLayerPanelList.MergeDown;
var
  LLayerPanel: TgmLayerPanel;
  LDestPanel : TgmLayerPanel;
begin
  if Self.Count > 1 then
  begin
    if FCurrentIndex > 0 then
    begin
      LLayerPanel := TgmLayerPanel(Self.Items[FCurrentIndex]);

      if LLayerPanel.IsLayerVisible then
      begin
        LDestPanel := TgmLayerPanel(Self.Items[FCurrentIndex - 1]);

        if LDestPanel.IsLayerVisible and
           (LDestPanel.LayerFeature in [lfBackground, lfTransparent]) then
        begin
          if FAllowRefreshLayerPanels then
          begin
            HideAllLayerPanels;
          end;

          // remove the mask of destination layer, first
          if LDestPanel.IsHasMask then
          begin
            if LDestPanel.IsMaskLinked then
            begin
              ReplaceAlphaChannelWithMask(LDestPanel.AssociatedLayer.Bitmap,
                                          LDestPanel.FLastAlphaChannelBmp);
            end;
          end;

          MergeLayersToBitmapByIndex(LDestPanel.AssociatedLayer.Bitmap,
                                     [FCurrentIndex - 1, FCurrentIndex]);

          // apply mask again
          if LDestPanel.IsHasMask then
          begin
            if LDestPanel.IsMaskLinked then
            begin
              ChangeAlphaChannelBySubMask(LDestPanel.AssociatedLayer.Bitmap,
                                          LDestPanel.FLastAlphaChannelBmp,
                                          LDestPanel.FMaskImage.Bitmap);
            end;
          end;

          DeleteSelectedLayerPanel;
          LDestPanel.UpdateLayerThumbnail;

          if FAllowRefreshLayerPanels then
          begin
            ShowAllLayerPanels;
          end;
        end;
      end;
    end;
  end;
end;

procedure TgmLayerPanelList.FlattenLayers;
var
  LBackBitmap : TBitmap32;
  LForeBitmap : TBitmap32;
  i, j, k     : Integer;
  LBackBit    : PColor32;
  LForeBit    : PColor32;
  LMasterAlpha: TColor32;
  LLayerPanel : TgmLayerPanel;
begin
  if Self.Count > 1 then
  begin
    LBackBitmap := TBitmap32.Create;
    try
      LLayerPanel := TgmLayerPanel(Self.Items[0]);

      LBackBitmap.Assign(LLayerPanel.AssociatedLayer.Bitmap);
      LBackBitmap.Clear($FFFFFFFF);

      for i := 0 to (Self.Count - 1) do
      begin
        LLayerPanel := TgmLayerPanel(Self.Items[i]);

        if LLayerPanel.IsLayerVisible then
        begin
          LForeBitmap  := LLayerPanel.AssociatedLayer.Bitmap;
          LMasterAlpha := TColor32(LForeBitmap.MasterAlpha);
          LBackBit     := @LBackBitmap.Bits[0];
          LForeBit     := @LForeBitmap.Bits[0];

          for j := 0 to (LBackBitmap.Width * LBackBitmap.Height - 1) do
          begin
            // Blend pixels with the blend method that the layer owned.
            LLayerPanel.LayerPixelBlend(LForeBit^, LBackBit^, LMasterAlpha);
            Inc(LBackBit);
            Inc(LForeBit);
          end;
        end;
      end;

      for k := (Self.Count - 1) downto 1 do
      begin
        // This method will delete the corresponding layers, too.
        Self.DeleteLayerPanelByIndex(k);
      end;

      if FCurrentIndex <> 0 then
      begin
        ActiveLayerPanel(0);
      end;

      FSelectedLayerPanel.AssociatedLayer.Bitmap.Assign(LBackBitmap);

      if not FSelectedLayerPanel.IsSelected then
      begin
        FSelectedLayerPanel.IsSelected := True;
      end;

      FSelectedLayerPanel.BlendModeIndex   := 0;
      FSelectedLayerPanel.LayerMasterAlpha := 255;
      FSelectedLayerPanel.IsHasMask        := False;

      FSelectedLayerPanel.UpdateLayerThumbnail;
      FSelectedLayerPanel.ShowThumbnailByRightOrder;
      FSelectedLayerPanel.UpdateLayerPanelState;

      GMDataModule := TGMDataModule.Create(nil);
      try
        FSelectedLayerPanel.FWorkStageImage.Picture.Bitmap.Assign(GMDataModule.bmp32lstLayers.Bitmap[0]);
      finally
        FreeAndNil(GMDataModule)
      end;

      // reset different layer number to zero
      Self.InitializeLayerNumbers;
    finally
      LBackBitmap.Free;
    end;
  end;
end;

procedure TgmLayerPanelList.FlattenLayersToBitmap(const ADestBmp: TBitmap);
var
  i, j              : Integer;
  LBackBmp, LForeBmp: TBitmap32;
  LBackBit, LForeBit: PColor32;
  LMasterAlpha      : TColor32;
  LLayerPanel       : TgmLayerPanel;
begin
  if Self.Count > 1 then
  begin
    LBackBmp := TBitmap32.Create;
    try
      LBackBmp.SetSize(FSelectedLayerPanel.AssociatedLayer.Bitmap.Width,
                       FSelectedlayerPanel.AssociatedLayer.Bitmap.Height);
                      
      LBackBmp.DrawMode := dmOpaque;
      LBackBmp.Clear(clWhite32);

      for i := 0 to (Self.Count - 1) do
      begin
        LLayerPanel := TgmLayerPanel(Self.Items[i]);

        if LLayerPanel.IsLayerVisible then
        begin
          LForeBmp     := LLayerPanel.AssociatedLayer.Bitmap;
          LMasterAlpha := TColor32(LForeBmp.MasterAlpha);
          LBackBit     := @LBackBmp.Bits[0];
          LForeBit     := @LForeBmp.Bits[0];

          for j := 0 to (LBackBmp.Width * LBackBmp.Height - 1) do
          begin
            // Blend pixels with the blend method that the layer owned.
            LLayerPanel.LayerPixelBlend(LForeBit^, LBackBit^, LMasterAlpha);
            Inc(LBackBit);
            Inc(LForeBit);
          end;
        end;
      end;
      
      ADestBmp.Assign(LBackBmp);
      ADestBmp.PixelFormat := pf24bit;
    finally
      LBackBmp.Free;
    end;
  end;
end; 

procedure TgmLayerPanelList.FlattenLayersToBitmap(const ADestBmp: TBitmap32;
  const ADrawMode: TDrawMode);
var
  i, j              : Integer;
  LBackBmp, LForeBmp: TBitmap32;
  LBackBit, LForeBit: PColor32;
  LMasterAlpha      : TColor32;
  LLayerPanel       : TgmLayerPanel;
begin
  if Self.Count > 0 then
  begin
    LBackBmp := TBitmap32.Create;
    try
      LBackBmp.SetSize(FSelectedLayerPanel.AssociatedLayer.Bitmap.Width,
                       FSelectedlayerPanel.AssociatedLayer.Bitmap.Height);
      
      case ADrawMode of
        dmOpaque:
          begin
            LBackBmp.DrawMode := dmOpaque;
            LBackBmp.Clear(clWhite32);
          end;
          
        dmBlend:
          begin
            LBackBmp.DrawMode := dmBlend;
            LBackBmp.Clear($00FFFFFF);
          end;
      end;

      for i := 0 to (Self.Count - 1) do
      begin
        LLayerPanel := TgmLayerPanel(Self.Items[i]);

        if LLayerPanel.IsLayerVisible then
        begin
          LForeBmp     := LLayerPanel.AssociatedLayer.Bitmap;
          LMasterAlpha := TColor32(LForeBmp.MasterAlpha);
          LBackBit     := @LBackBmp.Bits[0];
          LForeBit     := @LForeBmp.Bits[0];
          
          for j := 0 to (LBackBmp.Width * LBackBmp.Height - 1) do
          begin
            // Blend pixels with the blend method that the layer owned.
            LLayerPanel.LayerPixelBlend(LForeBit^, LBackBit^, LMasterAlpha);
            Inc(LBackBit);
            Inc(LForeBit);
          end;
        end;
      end;

      ADestBmp.Assign(LBackBmp);
    finally
      LBackBmp.Free;
    end;
  end;
end;

procedure TgmLayerPanelList.FlattenLayersToBitmap(const ADestBmp: TBitmap32;
  const ADrawMode: TDrawMode; const AStartIndex, AEndIndex: Integer);
var
  i, j              : Integer;
  LBackBmp, LForeBmp: TBitmap32;
  LBackBit, LForeBit: PColor32;
  LMasterAlpha      : TColor32;
  LLayerPanel       : TgmLayerPanel;
begin
  if Self.Count > 0 then
  begin
    if (AStartIndex <  0) or
       (AEndIndex   >= Self.Count) or
       (AStartIndex >  AEndIndex) then
    begin
      Exit;
    end;

    if AStartIndex = AEndIndex then
    begin
      LLayerPanel := TgmLayerPanel(Self.Items[0]);

      ADestBmp.Assign(LLayerPanel.AssociatedLayer.Bitmap);
      Exit;
    end;

    LBackBmp := TBitmap32.Create;
    try
      LBackBmp.SetSize(FSelectedLayerPanel.AssociatedLayer.Bitmap.Width,
                       FSelectedlayerPanel.AssociatedLayer.Bitmap.Height);

      case ADrawMode of
        dmOpaque:
          begin
            LBackBmp.DrawMode := dmOpaque;
            LBackBmp.Clear(clWhite32);
          end;
          
        dmBlend:
          begin
            LBackBmp.DrawMode := dmBlend;
            LBackBmp.Clear($00FFFFFF);
          end;
      end;

      for i := AStartIndex to AEndIndex do
      begin
        LLayerPanel := TgmLayerPanel(Self.Items[i]);

        if LLayerPanel.IsLayerVisible then
        begin
          LForeBmp     := LLayerPanel.AssociatedLayer.Bitmap;
          LMasterAlpha := TColor32(LForeBmp.MasterAlpha);
          LBackBit     := @LBackBmp.Bits[0];
          LForeBit     := @LForeBmp.Bits[0];

          for j := 0 to (LBackBmp.Width * LBackBmp.Height - 1) do
          begin
            // Blend pixels with the blend method that the layer owned.
            LLayerPanel.LayerPixelBlend(LForeBit^, LBackBit^, LMasterAlpha);
            Inc(LBackBit);
            Inc(LForeBit);
          end;
        end;
      end;
      
      ADestBmp.Assign(LBackBmp);
    finally
      LBackBmp.Free;
    end;
  end;
end; 

procedure TgmLayerPanelList.FlattenLayersToBitmapWithoutMask(
  const ADestBmp: TBitmap32; const ADrawMode: TDrawMode);
var
  i, j        : Integer;
  LBackBmp    : TBitmap32;
  LForeBmp    : TBitmap32;
  LBackBit    : PColor32;
  LForeBit    : PColor32;
  LAlphaBit   : PColor32;
  LAlpha      : Byte;
  LMasterAlpha: TColor32;
  LForeColor  : TColor32;
  LLayerPanel : TgmLayerPanel;
begin
  if Self.Count > 0 then
  begin
    LBackBmp := TBitmap32.Create;
    try
      LBackBmp.SetSize(FSelectedLayerPanel.AssociatedLayer.Bitmap.Width,
                       FSelectedlayerPanel.AssociatedLayer.Bitmap.Height);

      case ADrawMode of
        dmOpaque:
          begin
            LBackBmp.DrawMode := dmOpaque;
            LBackBmp.Clear(clWhite32);
          end;
          
        dmBlend:
          begin
            LBackBmp.DrawMode := dmBlend;
            LBackBmp.Clear($00FFFFFF);
          end;
      end;

      for i := 0 to (Self.Count - 1) do
      begin
        LLayerPanel := TgmLayerPanel(Self.Items[i]);

        if LLayerPanel.IsLayerVisible then
        begin
          LForeBmp     := LLayerPanel.AssociatedLayer.Bitmap;
          LMasterAlpha := TColor32(LForeBmp.MasterAlpha);
          LBackBit     := @LBackBmp.Bits[0];
          LForeBit     := @LForeBmp.Bits[0];
          LAlphaBit    := nil;

          if not LLayerPanel.IsHoldMaskInLayerAlpha then
          begin
            if LLayerPanel.IsMaskLinked then
            begin
              LAlphaBit := @LLayerPanel.FLastAlphaChannelBmp.Bits[0];
            end;
          end;

          for j := 0 to (LBackBmp.Width * LBackBmp.Height - 1) do
          begin
            LForeColor := LForeBit^;

            if Assigned(LAlphaBit) then
            begin
              LAlpha     := LAlphaBit^ and $FF;
              LForeColor := (LAlpha shl 24) or (LForeColor and $FFFFFF);
            end;

            // Blend pixels with the blend method that the layer owned.
            LLayerPanel.LayerPixelBlend(LForeColor, LBackBit^, LMasterAlpha);

            Inc(LBackBit);
            Inc(LForeBit);

            if Assigned(LAlphaBit) then
            begin
              Inc(LAlphaBit);
            end;
          end;
        end;
      end;

      ADestBmp.Assign(LBackBmp);
    finally
      LBackBmp.Free;
    end;
  end;
end; 

function TgmLayerPanelList.IfPointOnFigureOnFigureLayer(
  const AX, AY: Integer): Boolean;
var
  i           : Integer;
  LLayerPanel : TgmLayerPanel;
  LFigurePanel: TgmFigureLayerPanel;
begin
  Result := False;

  if Self.Count > 0 then
  begin
    for i := (Self.Count - 1) downto 0 do
    begin
      LLayerPanel := TgmLayerPanel(Self.Items[i]);

      if LLayerPanel.LayerFeature = lfFigure then
      begin
        LFigurePanel := TgmFigureLayerPanel(Self.Items[i]);
        
        if LFigurePanel.FigureList.IfPointOnFigure(AX, AY) then
        begin
          Result := True;
          Break;
        end;
      end;
    end;
  end;
end; 

function TgmLayerPanelList.IfPointOnSelectedFigureOnFigureLayer(
  const AX, AY: Integer): Boolean;
var
  i           : Integer;
  LLayerPanel : TgmLayerPanel;
  LFigurePanel: TgmFigureLayerPanel;
begin
  Result := False;
  
  if Self.Count > 0 then
  begin
    for i := (Self.Count - 1) downto 0 do
    begin
      LLayerPanel := TgmLayerPanel(Self.Items[i]);

      if LLayerPanel.LayerFeature = lfFigure then
      begin
        LFigurePanel := TgmFigureLayerPanel(Self.Items[i]);
        
        if LFigurePanel.FigureList.SelectedContainsPoint( Point(AX, AY) ) then
        begin
          Result := True;
          Break;
        end;
      end;
    end;
  end;
end;

procedure TgmLayerPanelList.SelectAllFiguresOnFigureLayer;
var
  i           : Integer;
  LLayerPanel : TgmLayerPanel;
  LFigurePanel: TgmFigureLayerPanel;
begin
  if Self.Count > 0 then
  begin
    for i := 0 to (Self.Count - 1) do
    begin
      LLayerPanel := TgmLayerPanel(Self.Items[i]);

      if LLayerPanel.LayerFeature = lfFigure then
      begin
        LFigurePanel := TgmFigureLayerPanel(Self.Items[i]);
        LFigurePanel.FigureList.SelectAllFigures;
      end;
    end;
    
    GetSelectedFigureInfo;
  end;
end; 

procedure TgmLayerPanelList.SelectFiguresOnFigureLayer(
  const AShift: TShiftState; const AX, AY: Integer);
var
  i, j        : Integer;
  LLayerPanel : TgmLayerPanel;
  LFigurePanel: TgmFigureLayerPanel;
  LFigureObj  : TgmFigureObject;
begin
  SetLength(FSelectedFigureInfoArray, 0);
  SetLength(FSelectedFigureLayerIndexArray, 0);

  if Self.Count > 0 then
  begin
    for i := (Self.Count - 1) downto 0 do
    begin
      LLayerPanel := Self.Items[i];

      if LLayerPanel.LayerFeature = lfFigure then
      begin
        LFigurePanel := TgmFigureLayerPanel(Self.Items[i]);
        LFigurePanel.FigureList.SelectFigures(AShift, AX, AY);

        for j := 0 to (LFigurePanel.FFigureList.Count - 1) do
        begin
          LFigureObj := TgmFigureObject(LFigurePanel.FigureList.Items[j]);

          if LFigureObj.IsSelected then
          begin
            SetLength( FSelectedFigureInfoArray, High(FSelectedFigureInfoArray) + 2 );
            FSelectedFigureInfoArray[High(FSelectedFigureInfoArray)].LayerIndex  := i;
            FSelectedFigureInfoArray[High(FSelectedFigureInfoArray)].FigureIndex := j;
          end;
        end;

        if LFigurePanel.FigureList.SelectedFigureCount > 0 then
        begin
          SetLength( FSelectedFigureLayerIndexArray, High(FSelectedFigureLayerIndexArray) + 2 );
          FSelectedFigureLayerIndexArray[High(FSelectedFigureLayerIndexArray)] := i;
        end;

        if not (ssShift in AShift) then
        begin
          if High(FSelectedFigureInfoArray) > -1 then
          begin
            Exit;
          end;
        end;
      end;
    end;
  end;
end;

procedure TgmLayerPanelList.SelectRectOnFigureLayer(
  const AIncludeMode: TgmFigureSelectIncludeMode;
  const ARegionStart, ARegionEnd: TPoint);
var
  i                : Integer;
  LLayerPanel      : TgmLayerPanel;
  LFigureLayerPanel: TgmFigureLayerPanel;
begin
  if Self.Count > 0 then
  begin
    for i := (Self.Count - 1) downto 0 do
    begin
      LLayerPanel := TgmLayerPanel(Self.Items[i]);

      if LLayerPanel.FLayerFeature = lfFigure then
      begin
        LFigureLayerPanel := TgmFigureLayerPanel(Self.Items[i]);
        LFigureLayerPanel.FigureList.SelectRect(AIncludeMode, ARegionStart, ARegionEnd);
      end;
    end;
  end;
  
  GetSelectedFigureInfo;
end;

procedure TgmLayerPanelList.DeselectAllFiguresOnFigureLayer;
var
  i           : Integer;
  LLayerIndex : Integer;
  LFigureIndex: Integer;
  LLayerPanel : TgmFigureLayerPanel;
  LFigureObj  : TgmFigureObject;
begin
  if High(FSelectedFigureInfoArray) > -1 then
  begin
    for i := Low(FSelectedFigureInfoArray) to High(FSelectedFigureInfoArray) do
    begin
      LLayerIndex           := FSelectedFigureInfoArray[i].LayerIndex;
      LFigureIndex          := FSelectedFigureInfoArray[i].FigureIndex;
      LLayerPanel           := TgmFigureLayerPanel(Self.Items[LLayerIndex]);
      LFigureObj            := TgmFigureObject(LLayerPanel.FigureList.Items[LFigureIndex]);
      LFigureObj.IsSelected := False;
    end;
  end;
  
  SetLength(FSelectedFigureInfoArray, 0);
  SetLength(FSelectedFigureLayerIndexArray, 0);
end; 

function TgmLayerPanelList.SelectedFigureCountOnFigureLayer: Integer;
var
  i, LFigureCount: Integer;
  LLayerPanel    : TgmLayerPanel;
  LFigurePanel   : TgmFigureLayerPanel;
begin
  LFigureCount := 0;

  if Self.Count > 0 then
  begin
    for i := (Self.Count - 1) downto 0 do
    begin
      LLayerPanel := TgmLayerPanel(Self.Items[i]);

      if LLayerPanel.LayerFeature = lfFigure then
      begin
        LFigurePanel := TgmFigureLayerPanel(Self.Items[i]);
        LFigureCount := LFigureCount + LFigurePanel.FigureList.SelectedFigureCount;
      end;
    end;
  end;
  
  Result := LFigureCount;
end; 

procedure TgmLayerPanelList.DrawSelectedFiguresHandles(const AStage: TBitmap32;
  const AOffsetVector: TPoint);
var
  i, j, k           : Integer;
  LFigurePanel      : TgmFigureLayerPanel;
  LLayerIndex       : Integer;
  LFigureIndex      : Integer;
  LSelectedCount    : Integer;
  LFigureObj        : TgmFigureObject;
  LHandleColor      : TColor32;
  LCurveHandleColor1: TColor32;
  LCurveHandleColor2: TColor32;
  LHandlePoint      : TPoint;
begin
  AStage.Clear($00FFFFFF);

  LSelectedCount := Length(FSelectedFigureInfoArray);

  if LSelectedCount > 0 then
  begin
    for i := Low(FSelectedFigureInfoArray) to High(FSelectedFigureInfoArray) do
    begin
      LLayerIndex  := FSelectedFigureInfoArray[i].LayerIndex;
      LFigurePanel := TgmFigureLayerPanel(Self.Items[LLayerIndex]);
      LFigureIndex := FSelectedFigureInfoArray[i].FigureIndex;
      LFigureObj   := TgmFigureObject(LFigurePanel.FigureList.Items[LFigureIndex]);

      if LFigureObj.IsLocked then
      begin
        LHandleColor       := clRed32;
        LCurveHandleColor1 := clRed32;
        LCurveHandleColor2 := clRed32;
      end
      else
      begin
        if LSelectedCount > 1 then
        begin
          LHandleColor       := clAqua32;
          LCurveHandleColor1 := clAqua32;
          LCurveHandleColor2 := clAqua32;
        end
        else
        begin
          LHandleColor       := clLime32;
          LCurveHandleColor1 := clYellow32;
          LCurveHandleColor2 := clBlue32;
        end;
      end;

      case LFigureObj.Flag of
        ffStraightLine:
          begin
            DrawHandleOnBitmap32(AStage, LFigureObj.FStartPoint, AOffsetVector,
                                 HANDLE_RADIUS, LHandleColor);

            DrawHandleOnBitmap32(AStage, LFigureObj.FEndPoint, AOffsetVector,
                                 HANDLE_RADIUS, LHandleColor);
          end;

        ffCurve:
          begin
            AStage.SetStipple([$FF000000, $FF000000, $FF000000,
                               $00FFFFFF, $00FFFFFF, $00FFFFFF]);

            AStage.StippleStep := 1.0;
            
            AStage.LineFSP(LFigureObj.FStartPoint.X,  LFigureObj.FStartPoint.Y,
                           LFigureObj.FCurvePoint1.X, LFigureObj.FCurvePoint1.Y);
                          
            AStage.LineFSP(LFigureObj.FCurvePoint1.X, LFigureObj.FCurvePoint1.Y,
                           LFigureObj.FCurvePoint2.X, LFigureObj.FCurvePoint2.Y);
                          
            AStage.LineFSP(LFigureObj.FCurvePoint2.X, LFigureObj.FCurvePoint2.Y,
                           LFigureObj.FEndPoint.X,    LFigureObj.FEndPoint.Y);

            DrawHandleOnBitmap32(AStage, LFigureObj.FStartPoint, AOffsetVector,
                                 HANDLE_RADIUS, LHandleColor);

            DrawHandleOnBitmap32(AStage, LFigureObj.FEndPoint, AOffsetVector,
                                 HANDLE_RADIUS, LHandleColor);

            if (LFigureObj.FCurvePoint1.X = LFigureObj.FCurvePoint2.X) and
               (LFigureObj.FCurvePoint1.Y = LFigureObj.FCurvePoint2.Y) then
            begin
              case LFigureObj.CurveControl of
                ccpFirst:
                  begin
                    DrawHandleOnBitmap32(AStage, LFigureObj.FCurvePoint1,
                                         AOffsetVector, HANDLE_RADIUS,
                                         LCurveHandleColor1);
                  end;

                ccpSecond:
                  begin
                    DrawHandleOnBitmap32(AStage, LFigureObj.FCurvePoint2,
                                         AOffsetVector, HANDLE_RADIUS,
                                         LCurveHandleColor2);
                  end;
              end;
            end
            else
            begin
              DrawHandleOnBitmap32(AStage, LFigureObj.FCurvePoint1, AOffsetVector,
                                   HANDLE_RADIUS, LCurveHandleColor1);

              DrawHandleOnBitmap32(AStage, LFigureObj.FCurvePoint2, AOffsetVector,
                                   HANDLE_RADIUS, LCurveHandleColor2);
            end;
          end;

        ffPolygon, ffRegularPolygon:
          begin
            if High(LFigureObj.FPolygonPoints) > -1 then
            begin
              for k := Low(LFigureObj.FPolygonPoints) to
                       ( High(LFigureObj.FPolygonPoints) - 1 ) do
              begin
                DrawHandleOnBitmap32(AStage, LFigureObj.FPolygonPoints[k],
                                     AOffsetVector, HANDLE_RADIUS, LHandleColor);
              end;
            end;
          end;

        ffRectangle, ffRoundRectangle, ffEllipse:
          begin
            for j := 0 to 7 do
            begin
              case j of
                0:
                  begin
                    LHandlePoint := LFigureObj.FStartPoint;
                  end;

                1:
                  begin
                    LHandlePoint := LFigureObj.FEndPoint;
                  end;

                2:
                  begin
                    LHandlePoint := Point(LFigureObj.FStartPoint.X,
                                          LFigureObj.FEndPoint.Y);
                  end;
                  
                3:
                  begin
                    LHandlePoint := Point(LFigureObj.FEndPoint.X,
                                          LFigureObj.FStartPoint.Y);
                  end;

                4: begin
                     LHandlePoint.X := (LFigureObj.FStartPoint.X +
                                        LFigureObj.FEndPoint.X) div 2;
                                       
                     LHandlePoint.Y := LFigureObj.FStartPoint.Y;
                   end;

                5: begin
                     LHandlePoint.X := (LFigureObj.FStartPoint.X +
                                        LFigureObj.FEndPoint.X) div 2;
                                       
                     LHandlePoint.Y := LFigureObj.FEndPoint.Y;
                   end;

                6: begin
                     LHandlePoint.X := LFigureObj.FStartPoint.X;
                     
                     LHandlePoint.Y := (LFigureObj.FStartPoint.Y +
                                        LFigureObj.FEndPoint.Y) div 2;
                   end;

                7: begin
                     LHandlePoint.X := LFigureObj.FEndPoint.X;

                     LHandlePoint.Y := (LFigureObj.FStartPoint.Y +
                                        LFigureObj.FEndPoint.Y) div 2;
                   end;
              end;

              DrawHandleOnBitmap32(AStage, LHandlePoint, AOffsetVector,
                                   HANDLE_RADIUS, LHandleColor);
            end;
          end;

        ffSquare, ffRoundSquare, ffCircle:
          begin
            for j := 0 to 7 do
            begin
              case j of
                0:
                  begin
                    LHandlePoint := LFigureObj.FStartPoint;
                  end;
                  
                1:
                  begin
                    LHandlePoint := LFigureObj.FEndPoint;
                  end;
                  
                2:
                  begin
                    LHandlePoint := Point(LFigureObj.FStartPoint.X,
                                          LFigureObj.FEndPoint.Y);
                  end;
                  
                3:
                  begin
                    LHandlePoint := Point(LFigureObj.FEndPoint.X,
                                          LFigureObj.FStartPoint.Y);
                  end;
              end;

              DrawHandleOnBitmap32(AStage, LHandlePoint, AOffsetVector,
                                   HANDLE_RADIUS, LHandleColor);
            end;
          end;
      end;
    end;
  end;
end;

procedure TgmLayerPanelList.TranslateSelectedFigures(
  const ATranslateVector: TPoint);
var
  i           : Integer;
  LLayerPanel : TgmLayerPanel;
  LFigurePanel: TgmFigureLayerPanel;
begin
  if Self.Count > 0 then
  begin
    for i := (Self.Count - 1) downto 0 do
    begin
      LLayerPanel := TgmLayerPanel(Self.Items[i]);

      if LLayerPanel.LayerFeature = lfFigure then
      begin
        LFigurePanel := TgmFigureLayerPanel(Self.Items[i]);
        
        if LFigurePanel.FigureList.Count > 0 then
        begin
          LFigurePanel.FigureList.TranslateSelectedFigures(ATranslateVector);
        end;
      end;
    end;
  end;
end;

procedure TgmLayerPanelList.UpdateSelectedFigureLayerThumbnail(
  const ALayers: TLayerCollection);
var
  i              : Integer;
  LLastLayerIndex: Integer;
  LFigurePanel   : TgmFigureLayerPanel;
begin
  LLastLayerIndex := -1;
  
  if Length(FSelectedFigureInfoArray) > 0 then
  begin
    for i := High(FSelectedFigureInfoArray) downto
             Low(FSelectedFigureInfoArray) do
    begin
      if FSelectedFigureInfoArray[i].LayerIndex <> LLastLayerIndex then
      begin
        LLastLayerIndex := FSelectedFigureInfoArray[i].LayerIndex;
        LFigurePanel    := TgmFigureLayerPanel(Self.Items[LLastLayerIndex]);

        LFigurePanel.UpdateLayerThumbnail;
      end;
    end;
  end;
end; 

function TgmLayerPanelList.GetSelectedHandleAtPointOnFigureLayer(
  const AX, AY: Integer): TgmDrawingHandle;
var
  LLayerIndex : Integer;
  LFigureIndex: Integer;
  LLayerPanel : TgmFigureLayerPanel;
  LFigureObj  : TgmFigureObject;
begin
  Result := dhNone;
  
  if High(FSelectedFigureInfoArray) = 0 then
  begin
    LLayerIndex  := FSelectedFigureInfoArray[0].LayerIndex;
    LLayerPanel  := TgmFigureLayerPanel(Self.Items[LLayerIndex]);
    LFigureIndex := FSelectedFigureInfoArray[0].FigureIndex;
    LFigureObj   := TgmFigureObject(LLayerPanel.FigureList.Items[LFigureIndex]);
    Result       := LFigureObj.GetHandleAtPoint(AX, AY, FIGURE_HANDLE_RADIUS);
  end;
end; 

function TgmLayerPanelList.GetFirstSelectedFigure: TgmFigureObject;
var
  LLayerIndex : Integer;
  LFigureIndex: Integer;
  LLayerPanel : TgmFigureLayerPanel;
begin
  Result := nil;
  
  if High(FSelectedFigureInfoArray) = 0 then
  begin
    LLayerIndex  := FSelectedFigureInfoArray[0].LayerIndex;
    LLayerPanel  := TgmFigureLayerPanel(Self.Items[LLayerIndex]);
    LFigureIndex := FSelectedFigureInfoArray[0].FigureIndex;
    Result       := TgmFigureObject(LLayerPanel.FigureList.Items[LFigureIndex]);
  end;
end; 

procedure TgmLayerPanelList.GetFigureLayerIndex;
var
  i          : Integer;
  LLayerPanel: TgmLayerPanel;
begin
  SetLength(FFigureLayerIndexArray, 0);
  
  for i := 0 to (Self.Count - 1) do
  begin
    LLayerPanel := Self.Items[i];
    
    if LLayerPanel.LayerFeature = lfFigure then
    begin
      SetLength(FFigureLayerIndexArray, High(FFigureLayerIndexArray) + 2);
      FFigureLayerIndexArray[High(FFigureLayerIndexArray)] := i;
    end;
  end;
end;

procedure TgmLayerPanelList.GetSelectedFigureInfo;
var
  i, j             : Integer;
  LLayerPanel      : TgmLayerPanel;
  LFigureLayerPanel: TgmFigureLayerPanel;
  LSelectedCount   : Integer;
  LFigureObj       : TgmFigureObject;
begin
  SetLength(FSelectedFigureInfoArray, 0);
  SetLength(FSelectedFigureLayerIndexArray, 0);

  if Self.Count > 0 then
  begin
    for i := 0 to (Self.Count - 1) do
    begin
      LLayerPanel := Self.Items[i];

      if LLayerPanel.LayerFeature = lfFigure then
      begin
        LFigureLayerPanel := TgmFigureLayerPanel(Self.Items[i]);

        if LFigureLayerPanel.FigureList.Count > 0 then
        begin
          LSelectedCount := 0;

          for j := 0 to (LFigureLayerPanel.FigureList.Count - 1) do
          begin
            LFigureObj := TgmFigureObject(LFigureLayerPanel.FigureList.Items[j]);
            
            if LFigureObj.IsSelected then
            begin
              Inc(LSelectedCount);
              SetLength( FSelectedFigureInfoArray, High(FSelectedFigureInfoArray) + 2 );
              FSelectedFigureInfoArray[High(FSelectedFigureInfoArray)].LayerIndex  := i;
              FSelectedFigureInfoArray[High(FSelectedFigureInfoArray)].FigureIndex := j;
            end;
          end;

          if LSelectedCount > 0 then
          begin
            SetLength( FSelectedFigureLayerIndexArray, High(FSelectedFigureLayerIndexArray) + 2 );
            FSelectedFigureLayerIndexArray[High(FSelectedFigureLayerIndexArray)] := i;
          end;
        end;
      end;
    end;
  end;
end; 

procedure TgmLayerPanelList.DrawDeselectedFiguresOnSelectedFigureLayer(
  const ALayers: TLayerCollection);
var
  i, j, LLayerIndex: Integer;
  LFigureLayerPanel: TgmFigureLayerPanel;
  LBitmapLayer     : TBitmapLayer;
  LFigureObj       : TgmFigureObject;
begin
  if Length(FSelectedFigureLayerIndexArray) > 0 then
  begin
    for i := Low(FSelectedFigureLayerIndexArray) to
             High(FSelectedFigureLayerIndexArray) do
    begin
      LLayerIndex  := FSelectedFigureLayerIndexArray[i];
      LBitmapLayer := TBitmapLayer(ALayers.Items[LLayerIndex]);
      LBitmapLayer.Bitmap.Clear($00FFFFFF);

      LFigureLayerPanel := TgmFigureLayerPanel(Self.Items[LLayerIndex]);
      LFigureLayerPanel.ProcessedPart.Clear(clBlack32);

      for j := 0 to (LFigureLayerPanel.FigureList.Count - 1) do
      begin
        LFigureObj := TgmFigureObject(LFigureLayerPanel.FigureList.Items[j]);
        
        if LFigureObj.IsLocked or (LFigureObj.IsSelected = False) then
        begin
          LFigureObj.DrawFigure( LBitmapLayer.Bitmap.Canvas, pmCopy,
                                 Point(0, 0), 100, fdmRGB );

          LFigureObj.DrawFigure( LFigureLayerPanel.ProcessedPart.Canvas, pmCopy,
                                 Point(0, 0), 100, fdmMask );

          MakeCanvasProcessedOpaque(LBitmapLayer.Bitmap,
                                    LFigureLayerPanel.ProcessedPart);
        end;
      end;
    end;
  end;
end; 

procedure TgmLayerPanelList.DrawAllFiguresOnSelectedFigureLayer(
  const ALayers: TLayerCollection);
var
  i, j, LLayerIndex: Integer;
  LFigureLayerPanel: TgmFigureLayerPanel;
  LBitmapLayer     : TBitmapLayer;
  LFigureObj       : TgmFigureObject;
begin
  if Length(FSelectedFigureLayerIndexArray) > 0 then
  begin
    for i := Low(FSelectedFigureLayerIndexArray) to
             High(FSelectedFigureLayerIndexArray) do
    begin
      LLayerIndex  := FSelectedFigureLayerIndexArray[i];
      LBitmapLayer := TBitmapLayer(ALayers.Items[LLayerIndex]);
      LBitmapLayer.Bitmap.Clear($00FFFFFF);

      LFigureLayerPanel := TgmFigureLayerPanel(Self.Items[LLayerIndex]);
      LFigureLayerPanel.ProcessedPart.Clear(clBlack32);

      for j := 0 to (LFigureLayerPanel.FigureList.Count - 1) do
      begin
        LFigureObj := TgmFigureObject(LFigureLayerPanel.FigureList.Items[j]);
        
        LFigureObj.DrawFigure( LBitmapLayer.Bitmap.Canvas, pmCopy,
                               Point(0, 0), 100, fdmRGB );
                               
        LFigureObj.DrawFigure( LFigureLayerPanel.ProcessedPart.Canvas, pmCopy,
                               Point(0, 0), 100, fdmMask );
                               
        MakeCanvasProcessedOpaque(LBitmapLayer.Bitmap,
                                  LFigureLayerPanel.ProcessedPart);
      end;
    end;
  end;
end;

procedure TgmLayerPanelList.DrawAllFiguresOnSpecifiedLayer(
  const ALayers: TLayerCollection; const ALayerIndex: Integer);
var
  i                : Integer;
  LLayerPanel      : TgmLayerPanel;
  LFigureLayerPanel: TgmFigureLayerPanel;
  LBitmapLayer     : TBitmapLayer;
  LFigureObj       : TgmFigureObject;
begin
  if (ALayerIndex >= 0) and (ALayerIndex < ALayers.Count) then
  begin
    LLayerPanel := TgmLayerPanel(Self.Items[ALayerIndex]);

    if LLayerPanel.LayerFeature = lfFigure then
    begin
      LFigureLayerPanel := TgmFigureLayerPanel(Self.Items[ALayerIndex]);
      LBitmapLayer      := TBitmapLayer(ALayers.Items[ALayerIndex]);
      
      LBitmapLayer.Bitmap.Clear($00FFFFFF);
      LFigureLayerPanel.ProcessedPart.Clear(clBlack32);
      
      for i := 0 to (LFigureLayerPanel.FigureList.Count - 1) do
      begin
        LFigureObj := TgmFigureObject(LFigureLayerPanel.FigureList.Items[i]);
        
        LFigureObj.DrawFigure( LBitmapLayer.Bitmap.Canvas, pmCopy,
                               Point(0, 0), 100, fdmRGB );

        LFigureObj.DrawFigure( LFigureLayerPanel.ProcessedPart.Canvas, pmCopy,
                               Point(0, 0), 100, fdmMask );
                              
        MakeCanvasProcessedOpaque(LBitmapLayer.Bitmap,
                                  LFigureLayerPanel.ProcessedPart);
      end;
    end;
  end;
end;

procedure TgmLayerPanelList.DrawAllFiguresOnFigureLayer(
  const ALayers: TLayerCollection);
var
  i, j             : Integer;
  LLayerPanel      : TgmLayerPanel;
  LFigureLayerPanel: TgmFigureLayerPanel;
  LBitmapLayer     : TBitmapLayer;
  LFigureObj       : TgmFigureObject;
begin
  if Self.Count > 0 then
  begin
    for i := 0 to (Self.Count - 1) do
    begin
      LLayerPanel := TgmLayerPanel(Self.Items[i]);

      if LLayerPanel.LayerFeature = lfFigure then
      begin
        LFigureLayerPanel := TgmFigureLayerPanel(LLayerPanel);
        LBitmapLayer      := TBitmapLayer(ALayers.Items[i]);
        
        LBitmapLayer.Bitmap.Clear($00FFFFFF);
        LFigureLayerPanel.ProcessedPart.Clear(clBlack32);
        
        for j := 0 to (LFigureLayerPanel.FigureList.Count - 1) do
        begin
          LFigureObj := TgmFigureObject(LFigureLayerPanel.FigureList.Items[j]);
          
          LFigureObj.DrawFigure( LBitmapLayer.Bitmap.Canvas, pmCopy,
                                 Point(0, 0), 100, fdmRGB );
                                
          LFigureObj.DrawFigure( LFigureLayerPanel.ProcessedPart.Canvas, pmCopy,
                                 Point(0, 0), 100, fdmMask );

          MakeCanvasProcessedOpaque(LBitmapLayer.Bitmap,
                                    LFigureLayerPanel.ProcessedPart);
        end;
      end;
    end;
  end;
end;

procedure TgmLayerPanelList.DrawSelectedFiguresOnCanvas(const ACanvas: TCanvas;
  const APenMode: TPenMode; const AOffset: TPoint; const AFactor: Integer;
  const AFigureDrawMode: TgmFigureDrawMode);
var
  i                : Integer;
  LLayerIndex      : Integer;
  LFigureIndex     : Integer;
  LFigureLayerPanel: TgmFigureLayerPanel;
  LFigureObj       : TgmFigureObject;
begin
  if Length(FSelectedFigureInfoArray) > 0 then
  begin
    for i := Low(FSelectedFigureInfoArray) to
             High(FSelectedFigureInfoArray) do
    begin
      LLayerIndex       := FSelectedFigureInfoArray[i].LayerIndex;
      LFigureIndex      := FSelectedFigureInfoArray[i].FigureIndex;
      LFigureLayerPanel := TgmFigureLayerPanel(Self.Items[LLayerIndex]);
      LFigureObj        := TgmFigureObject(LFigureLayerPanel.FigureList.Items[LFigureIndex]);
      
      if not LFigureObj.IsLocked then
      begin
        LFigureObj.DrawFigure(ACanvas, APenMode, AOffset, AFactor, AFigureDrawMode);
      end;
    end;
  end;
end;

procedure TgmLayerPanelList.ApplyMaskOnSelectedFigureLayer;
var
  i, LLayerIndex: Integer;
  LLayerPanel   : TgmLayerPanel;
begin
  LLayerPanel := nil;
  
  if High(FSelectedFigureLayerIndexArray) > -1 then
  begin
    for i := Low(FSelectedFigureLayerIndexArray) to
             High(FSelectedFigureLayerIndexArray) do
    begin
      LLayerIndex := FSelectedFigureLayerIndexArray[i];
      LLayerPanel := TgmLayerPanel(Self.Items[LLayerIndex]);

      if LLayerPanel.IsHasMask then
      begin
        GetAlphaChannelBitmap(LLayerPanel.AssociatedLayer.Bitmap,
                              LLayerPanel.FLastAlphaChannelBmp);

        if LLayerPanel.IsMaskLinked then
        begin
          ChangeAlphaChannelBySubMask(LLayerPanel.AssociatedLayer.Bitmap,
                                      LLayerPanel.FLastAlphaChannelBmp,
                                      LLayerPanel.FMaskImage.Bitmap);
        end;
      end;
    end;

    // update display once
    if Assigned(LLayerPanel) then
    begin
      LLayerPanel.AssociatedLayer.Changed;
    end;
  end;
end;

procedure TgmLayerPanelList.ApplyMaskOnAllFigureLayers;
var
  i          : Integer;
  LLayerPanel: TgmLayerPanel;
begin
  LLayerPanel := nil;

  if Self.Count > 0 then
  begin
    for i := 0 to (Self.Count - 1) do
    begin
      LLayerPanel := TgmLayerPanel(Self.Items[i]);

      if LLayerPanel.LayerFeature = lfFigure then
      begin
        if LLayerPanel.IsHasMask then
        begin
          GetAlphaChannelBitmap(LLayerPanel.AssociatedLayer.Bitmap,
                                LLayerPanel.FLastAlphaChannelBmp);

          if LLayerPanel.IsMaskLinked then
          begin
            ChangeAlphaChannelBySubMask(LLayerPanel.AssociatedLayer.Bitmap,
                                        LLayerPanel.FLastAlphaChannelBmp,
                                        LLayerPanel.FMaskImage.Bitmap);
          end;
        end;
      end;
    end;

    // update display once
    if Assigned(LLayerPanel) then
    begin
      LLayerPanel.AssociatedLayer.Changed;
    end;
  end;
end;

procedure TgmLayerPanelList.DeleteSelectedFiguresOnFigureLayer;
var
  i                : Integer;
  LLayerIndex      : Integer;
  LFigureIndex     : Integer;
  LFigureLayerPanel: TgmFigureLayerPanel;
begin
  if Self.Count > 0 then
  begin
    if High(FSelectedFigureInfoArray) > (-1) then
    begin
      // must delete the figure in inverse order, otherwise an exception will occur
      for i := High(FSelectedFigureInfoArray) downto
               Low(FSelectedFigureInfoArray) do
      begin
        LLayerIndex       := FSelectedFigureInfoArray[i].LayerIndex;
        LFigureIndex      := FSelectedFigureInfoArray[i].FigureIndex;
        LFigureLayerPanel := TgmFigureLayerPanel(Self.Items[LLayerIndex]);

        LFigureLayerPanel.FFigureList.Delete(LFigureIndex);
      end;
    end;
  end;
end; 

function TgmLayerPanelList.HasFiguresOnFigureLayer: Boolean;
var
  i                : Integer;
  LLayerPanel      : TgmLayerPanel;
  LFigureLayerPanel: TgmFigureLayerPanel;
begin
  Result := False;

  if Self.Count > 0 then
  begin
    for i := 0 to (Self.Count - 1) do
    begin
      LLayerPanel := TgmLayerPanel(Self.Items[i]);

      if LLayerPanel.LayerFeature = lfFigure then
      begin
        LFigureLayerPanel := TgmFigureLayerPanel(Self.Items[i]);
        
        if LFigureLayerPanel.FigureList.Count > 0 then
        begin
          Result := True;
          Break;
        end;
      end;
    end;
  end;
end;

// determine whether there are locked figures on the selected figure layer
function TgmLayerPanelList.HasLockedFiguresOnSelectedFigureLayer: Boolean;
var
  i                : Integer;
  LLayerIndex      : Integer;
  LFigureIndex     : Integer;
  LFigureLayerPanel: TgmFigureLayerPanel;
  LFigureObj       : TgmFigureObject;
begin
  Result := False;

  if High(FSelectedFigureInfoArray) > (-1) then
  begin
    for i := Low(FSelectedFigureInfoArray) to High(FSelectedFigureInfoArray) do
    begin
      LLayerIndex       := FSelectedFigureInfoArray[i].LayerIndex;
      LFigureIndex      := FSelectedFigureInfoArray[i].FigureIndex;
      LFigureLayerPanel := TgmFigureLayerPanel(Self.Items[LLayerIndex]);
      LFigureObj        := TgmFigureObject(LFigureLayerPanel.FigureList.Items[LFigureIndex]);
      
      if LFigureObj.IsLocked then
      begin
        Result := True;
        Break;
      end;
    end;
  end;
end;

// determine whether there are unlocked figures on the selected figure layer
function TgmLayerPanelList.HasUnlockedFiguresOnSelectedFigureLayer: Boolean;
var
  i                : Integer;
  LLayerIndex      : Integer;
  LFigureIndex     : Integer;
  LFigureLayerPanel: TgmFigureLayerPanel;
  LFigureObj       : TgmFigureObject;
begin
  Result := False;

  if High(FSelectedFigureInfoArray) > (-1) then
  begin
    for i := Low(FSelectedFigureInfoArray) to High(FSelectedFigureInfoArray) do
    begin
      LLayerIndex       := FSelectedFigureInfoArray[i].LayerIndex;
      LFigureIndex      := FSelectedFigureInfoArray[i].FigureIndex;
      LFigureLayerPanel := TgmFigureLayerPanel(Self.Items[LLayerIndex]);
      LFigureObj        := TgmFigureObject(LFigureLayerPanel.FigureList.Items[LFigureIndex]);
      
      if not LFigureObj.IsLocked then
      begin
        Result := True;
        Break;
      end;
    end;
  end;
end;

procedure TgmLayerPanelList.LockSelectedFiguresOnSelectedFigureLayer;
var
  i                : Integer;
  LLayerIndex      : Integer;
  LFigureIndex     : Integer;
  LFigureLayerPanel: TgmFigureLayerPanel;
  LFigureObj       : TgmFigureObject;
begin
  if High(FSelectedFigureInfoArray) > (-1) then
  begin
    for i := Low(FSelectedFigureInfoArray) to High(FSelectedFigureInfoArray) do
    begin
      LLayerIndex         := FSelectedFigureInfoArray[i].LayerIndex;
      LFigureIndex        := FSelectedFigureInfoArray[i].FigureIndex;
      LFigureLayerPanel   := TgmFigureLayerPanel(Self.Items[LLayerIndex]);
      LFigureObj          := TgmFigureObject(LFigureLayerPanel.FigureList.Items[LFigureIndex]);
      LFigureObj.IsLocked := True;
    end;
  end;
end;

procedure TgmLayerPanelList.UnlockSelectedFiguresOnSelectedFigureLayer;
var
  i                : Integer;
  LLayerIndex      : Integer;
  LFigureIndex     : Integer;
  LFigureLayerPanel: TgmFigureLayerPanel;
  LFigureObj       : TgmFigureObject;
begin
  if High(FSelectedFigureInfoArray) > (-1) then
  begin
    for i := Low(FSelectedFigureInfoArray) to High(FSelectedFigureInfoArray) do
    begin
      LLayerIndex         := FSelectedFigureInfoArray[i].LayerIndex;
      LFigureIndex        := FSelectedFigureInfoArray[i].FigureIndex;
      LFigureLayerPanel   := TgmFigureLayerPanel(Self.Items[LLayerIndex]);
      LFigureObj          := TgmFigureObject(LFigureLayerPanel.FigureList.Items[LFigureIndex]);
      LFigureObj.IsLocked := False;
    end;
  end;
end;

procedure TgmLayerPanelList.SelectFiguresByFigureInfoArray;
var
  i           : Integer;
  LLayerIndex : Integer;
  LFigureIndex: Integer;
  LLayerPanel : TgmFigureLayerPanel;
  LFigureObj  : TgmFigureObject;
begin
  if Self.Count > 0 then
  begin
    if High(FSelectedFigureInfoArray) >= 0 then
    begin
      for i := 0 to High(FSelectedFigureInfoArray) do
      begin
        LLayerIndex           := FSelectedFigureInfoArray[i].LayerIndex;
        LFigureIndex          := FSelectedFigureInfoArray[i].FigureIndex;
        LLayerPanel           := TgmFigureLayerPanel(Self.Items[LLayerIndex]);
        LFigureObj            := TgmFigureObject(LLayerPanel.FFigureList.Items[LFigureIndex]);
        LFigureObj.IsSelected := True;
      end;
    end;
  end;
end;

// load layers from a '*.gmd' file that is already loaded in a stream
function TgmLayerPanelList.LoadLayersFromStream(const AStream: TStream;
  const AFileVersion, ALoadLayerCount, ALoadLayerWidth, ALoadLayerHeight: Cardinal): Boolean;
var
  i           : Integer;
  LLayerPanel : TgmLayerPanel;
  LLayerLoader: TgmLayerLoader;
begin
  Result       := True;
  LLayerLoader := nil;

  if (AFileVersion     = 0) or
     (ALoadLayerCount  = 0) or
     (ALoadLayerWidth  = 0) or
     (ALoadLayerHeight = 0) or
     ( not Assigned(FAssociatedLayerCollection) ) or
     ( not Assigned(FLayerPanelOwner) ) then
  begin
    Result := False;
    Exit;
  end;

  DeleteAllLayerPanels;

  case AFileVersion of
    1:
      begin
        LLayerLoader := TgmLayerLoader1.Create(AStream,
          FAssociatedLayerCollection, FLayerPanelOwner, FAssociatedTextEditor);
      end;
      
    2:
      begin
        LLayerLoader := TgmLayerLoader2.Create(AStream,
          FAssociatedLayerCollection, FLayerPanelOwner, FAssociatedTextEditor);
      end;

    3:
      begin
        LLayerLoader := TgmLayerLoader3.Create(AStream,
          FAssociatedLayerCollection, FLayerPanelOwner, FAssociatedTextEditor);
      end;
  end;

  if Assigned(LLayerLoader) then
  begin
    try
      LLayerLoader.LayerWidth  := ALoadLayerWidth;
      LLayerLoader.LayerHeight := ALoadLayerHeight;

      for i := 0 to (ALoadLayerCount - 1) do
      begin
        LLayerPanel := LLayerLoader.GetLayer;

        { Add layer panel to list, note that, we don't use the
          AddLayerPaneToList() method for doing this. }
        if Assigned(LLayerPanel) then
        begin
          // make the list be accessible to the layer panel
          LLayerPanel.FPanelList := Self;

          Self.Add(LLayerPanel);
          ConnectEventsToLayerPanel(LLayerPanel);

          // make FSelectedLayerPanel points to the selected layer panel
          if LLayerPanel.IsSelected then
          begin
            FSelectedLayerPanel := LLayerPanel;
          end;
        end;
      end;

      if Self.Count > 0 then
      begin
        UpdatePanelsState;
      end;

      if FAllowRefreshLayerPanels then
      begin
        HideAllLayerPanels;
        ShowAllLayerPanels;
      end;
    finally
      LLayerLoader.Free;
    end;
  end
  else
  begin
    Result := False;
  end;
end;

// save the layers to stream for output them in '*.gmd' file later
procedure TgmLayerPanelList.SaveLayersToStream(const AStream: TStream);
var
  i          : Integer;
  LLayerPanel: TgmLayerPanel;
begin
  if Self.Count > 0 then
  begin
    if Assigned(AStream) then
    begin
      for i := 0 to (Self.Count - 1) do
      begin
        LLayerPanel := TgmLayerPanel(Self.Items[i]);
        LLayerPanel.SaveToStream(AStream);
      end;
    end;
  end;
end; 

//////////////////////// Channel Part Begin ////////////////////////////////////

const
  CHANNEL_PANEL_HEIGHT: Integer = 41;
  EYE_HOLDER_WIDTH    : Integer = 24;
  EYE_WIDTH           : Integer = 16;
  EYE_HEIGHT          : Integer = 16;

//-- TgmChannelPanel -----------------------------------------------------------

constructor TgmChannelPanel.Create(const AOwner: TWinControl);
begin
  inherited Create;

  FSelected       := True;
  FChannelVisible := True;
  FChannelType    := wctRGB;

  // main panel
  FMainPanel := TPanel.Create(AOwner);
  with FMainPanel do
  begin
    Parent     := AOwner;
    Align      := alTop;
    AutoSize   := False;
    Height     := CHANNEL_PANEL_HEIGHT;
    BevelInner := bvLowered;
    BevelOuter := bvRaised;
    BevelWidth := 1;
    Color      := clBackground;
    Cursor     := crHandPoint;
    ShowHint   := False;
    Visible    := False;
  end;

  // create a panel to hold a Eye image to indicate whether the channel is visible
  FChannelEyeHolder := TPanel.Create(FMainPanel);
  with FChannelEyeHolder do
  begin
    Parent     := FMainPanel;
    Align      := alLeft;
    AutoSize   := False;
    Cursor     := crHandPoint;
    Width      := EYE_HOLDER_WIDTH;
    BevelInner := bvRaised;
    BevelOuter := bvLowered;
    BevelWidth := 1;
    Visible    := True;
  end;

  // create panel to hold the channel image
  FChannelImageHolder := TPanel.Create(FMainPanel);
  with FChannelImageHolder do
  begin
    Parent     := FMainPanel;
    Align      := alLeft;
    AutoSize   := False;
    Width      := IMAGE_HOLDER_WIDTH;
    Height     := CHANNEL_PANEL_HEIGHT - 2;
    BevelInner := bvRaised;
    BevelOuter := bvLowered;
    BevelWidth := 1;
    Cursor     := crHandPoint;
    Visible    := True;
  end;

  // create Image32 for holding thumbnail of the channel
  FChannelImage := TImage32.Create(FChannelImageHolder);
  with FChannelImage do
  begin
    Parent          := FChannelImageHolder;
    Width           := FChannelImageHolder.Width   - 2;
    Height          := FChannelImageHolder.Height  - 2;
    Bitmap.DrawMode := dmBlend;
    BitmapAlign     := baCenter;
    AutoSize        := False;
    ScaleMode       := smScale;
    Cursor          := crHandPoint;
    Left            := 1;
    Top             := 1;
    Visible         := True;

    { Force TImage32 to call the OnPaintStage event instead of performming
      default action. }
    if PaintStages[0]^.Stage = PST_CLEAR_BACKGND then
    begin
      PaintStages[0]^.Stage := PST_CUSTOM;
    end;

    OnPaintStage := ImagePaintStage;
  end;

  // create Image32 for holding eye icon for the channel

  FEyeImage := TImage32.Create(FChannelEyeHolder);
  with FEyeImage do
  begin
    Parent    := FChannelEyeHolder;
    AutoSize  := False;
    ScaleMode := smStretch;
    Cursor    := crHandPoint;
    Width     := EYE_WIDTH;
    Height    := EYE_HEIGHT;
    Top       := (FChannelEyeHolder.Height - Height) div 2;
    Left      := (FChannelEyeHolder.Width  - Width)  div 2;
    Visible   := True;

    GMDataModule := TGMDataModule.Create(nil);
    try
      Bitmap.Assign(GMDataModule.bmp32lstLayers.Bitmap[11]);
    finally
      FreeAndNil(GMDataModule)
    end;
  end;

  // create label for displaying the name of the channel
  FChannelName := TLabel.Create(FMainPanel);
  with FChannelName do
  begin
    Parent     := FMainPanel;
    Align      := alNone;
    Left       := FChannelEyeHolder.Width + FChannelImageHolder.Width + 10;
    Top        := (FMainPanel.Height - Height) div 2;
    Caption    := '';
    Font.Color := clWhite;
    ShowHint   := True;
    Visible    := True;
  end;
end;

destructor TgmChannelPanel.Destroy;
begin
  // free in the opposite order of create order
  FEyeImage.Free;
  FChannelImage.Free;
  FChannelImageHolder.Free;
  FChannelEyeHolder.Free;
  FChannelName.Free;
  FMainPanel.Free;

  inherited Destroy;
end;

// drawing image stage callback function
procedure TgmChannelPanel.ImagePaintStage(ASender: TObject; ABuffer: TBitmap32;
  AStageNum: Cardinal);
var
  LRect: TRect;
begin
  // draw background
  if (ABuffer.Height > 0) and (ABuffer.Width > 0) then
  begin
    ABuffer.Clear( Color32(ColorToRGB(clBtnFace)) );

    // draw thin border, written by Andre Felix Miertschink
    LRect := FChannelImage.GetBitmapRect;

    DrawCheckerboardPattern(ABuffer, LRect, True);

    LRect.Left   := LRect.Left   - 1;
    LRect.Top    := LRect.Top    - 1;
    LRect.Right  := LRect.Right  + 1;
    LRect.Bottom := LRect.Bottom + 1;

    ABuffer.FrameRectS(LRect, clBlack32);
  end;
end;

function TgmChannelPanel.GetPanelTop: Integer;
begin
  Result := FMainPanel.Top;
end;

function TgmChannelPanel.GetChannelName: string;
begin
  Result := FChannelName.Caption;
end;

procedure TgmChannelPanel.SetSelected(const AValue: Boolean);
begin
  if FSelected <> AValue then
  begin
    FSelected := AValue;

    if FSelected then
    begin
      FMainPanel.BevelInner   := bvLowered;
      FMainPanel.Color        := clBackground;
      FChannelName.Font.Color := clWhite;
    end
    else
    begin
      FMainPanel.BevelInner   := bvRaised;
      FMainPanel.Color        := clBtnFace;
      FChannelName.Font.Color := clBlack;
    end;
  end;
end;

procedure TgmChannelPanel.SetChannelVisibility(const AValue: Boolean);
begin
  if FChannelVisible <> AValue then
  begin
    FChannelVisible := AValue;

    if FChannelVisible then
    begin
      GMDataModule := TGMDataModule.Create(nil);
      try
        FEyeImage.Bitmap.Assign(GMDataModule.bmp32lstLayers.Bitmap[11]);
      finally
        FreeAndNil(GMDataModule)
      end;
    end
    else
    begin
      FEyeImage.Bitmap.Clear(Color32(ColorToRGB(clBtnFace)));
    end;
  end;
end; 

procedure TgmChannelPanel.SetPanelTop(const AValue: Integer);
begin
  if FMainPanel.Top <> AValue then
  begin
    FMainPanel.Top := AValue;
  end;
end;

procedure TgmChannelPanel.SetChannelName(const AValue: string);
begin
  if FChannelName.Caption <> AValue then
  begin
    FChannelName.Caption := AValue;
  end;
end;

procedure TgmChannelPanel.ScaleChannelThumbnail;
var
  w, h  : Integer;
  ws, hs: Single;
begin
  if FChannelImage.Bitmap.DrawMode <> dmBlend then
  begin
    FChannelImage.Bitmap.DrawMode := dmBlend;
  end;

  // scale and center thumbnail

  w := FChannelImage.Width  - 6;
  h := FChannelImage.Height - 6;

  if (FChannelImage.Bitmap.Width  > w) or
     (FChannelImage.Bitmap.Height > h) then
  begin
    ws := w / FChannelImage.Bitmap.Width;
    hs := h / FChannelImage.Bitmap.Height;

    if ws < hs then
    begin
      FChannelImage.Scale := ws;
    end
    else
    begin
      FChannelImage.Scale := hs;
    end;
  end
  else
  begin
    FChannelImage.Scale := 1;
  end;
end;

procedure TgmChannelPanel.ShowThumbnailByRightOrder;
begin
  FChannelEyeHolder.Left   := 1;
  FChannelImageHolder.Left := EYE_HOLDER_WIDTH + 1;
end;

procedure TgmChannelPanel.ConnectChannelEyeClickEvent(
  const AClickEvent: TNotifyEvent);
begin
  if Assigned(AClickEvent) then
  begin
    FEyeImage.OnClick         := AClickEvent;
    FChannelEyeHolder.OnClick := AClickEvent;
  end;
end;

procedure TgmChannelPanel.ConnectChannelPanelDblClickEvent(
  const ADblClickEvent: TNotifyEvent);
begin
  if Assigned(ADblClickEvent) then
  begin
    FMainPanel.OnDblClick          := ADblClickEvent;
    FChannelImageHolder.OnDblClick := ADblClickEvent;
    FChannelImage.OnDblClick       := ADblClickEvent;
    FChannelName.OnDblClick        := ADblClickEvent;
  end;
end;

procedure TgmChannelPanel.ConnectChannelPanelMouseDownEvent(
  const AMouseDownEvent: TMouseEvent);
begin
  if Assigned(AMouseDownEvent) then
  begin
    FMainPanel.OnMouseDown          := AMouseDownEvent;
    FChannelImageHolder.OnMouseDown := AMouseDownEvent;
    FChannelName.OnMouseDown        := AMouseDownEvent;
  end;
end;

procedure TgmChannelPanel.ConnectChannelImageMouseDownEvent(
  const AMouseDownEvent: TImgMouseEvent);
begin
  if Assigned(AMouseDownEvent) then
  begin
    FChannelImage.OnMouseDown := AMouseDownEvent;
  end;
end;

procedure TgmChannelPanel.Show;
begin
  FMainPanel.Show;
end;

procedure TgmChannelPanel.Hide;
begin
  FMainPanel.Hide;
end;

function TgmChannelPanel.IfClickOnEye(const ASender: TObject): Boolean;
begin
  if (ASender = FEyeImage) or (ASender = FChannelEyeHolder) then
  begin
    Result := True;
  end
  else
  begin
    Result := False;
  end;
end; 

function TgmChannelPanel.IfClickOnPanel(const ASender: TObject): Boolean;
begin
  if (ASender = FMainPanel) or
     (ASender = FChannelImageHolder) or
     (ASender = FChannelImage) or
     (ASender = FChannelName) then
  begin
    Result := True;
  end
  else
  begin
    Result := False;
  end;
end;

procedure TgmChannelPanel.SaveToStream(const AStream: TStream);
begin
  { Empty Method --

    We want this method to be a abstract method, but compiler told us that
    we have construct the instance of TChannelPanel which contains abstract
    method. So, for avoiding this warnings/hints, we made this method to be
    a virtual empty method. }
end;

//-- TgmAlphaChannelPanel ------------------------------------------------------

constructor TgmAlphaChannelPanel.Create(const AOwner: TWinControl;
  const ALayerCollection: TLayerCollection;
  const ALayerIndex, ALayerWidth, ALayerHeight: Integer;
  const ALayerLocation: TFloatRect; const AMaskColor: TColor32);
begin
  inherited Create(AOwner);

  FChannelType        := wctAlpha;
  FMaskColor          := AMaskColor;
  FMaskColorType      := mctGrayscale;
  FMaskColorIndicator := mciMaskedArea;
  FMaskOpacity        := 128;

  // create alpha channel layer
  FAlphaLayer := TBitmapLayer(ALayerCollection.Insert(ALayerIndex, TBitmapLayer));

  FAlphaLayer.Bitmap.DrawMode       := dmCustom;
  FAlphaLayer.Bitmap.OnPixelCombine := AlphaLayerBlend;
  FAlphaLayer.Bitmap.MasterAlpha    := FMaskOpacity;

  FAlphaLayer.Bitmap.SetSize(ALayerWidth, ALayerHeight);
  FAlphaLayer.Bitmap.Clear(clBlack32);
  
  FAlphaLayer.Location := ALayerLocation;
  FAlphaLayer.Scaled   := True;

  UpdateThumbnail;
end;

destructor TgmAlphaChannelPanel.Destroy;
begin
  FAlphaLayer.Free;
  
  inherited Destroy;
end;

procedure TgmAlphaChannelPanel.SetChannelVisibility(const AValue: Boolean);
begin
  if FChannelVisible <> AValue then
  begin
    FChannelVisible     := AValue;
    FAlphaLayer.Visible := FChannelVisible;

    if FChannelVisible then
    begin
      GMDataModule := TGMDataModule.Create(nil);
      try
        FEyeImage.Bitmap.Assign(GMDataModule.bmp32lstLayers.Bitmap[11]);
      finally
        FreeAndNil(GMDataModule)
      end;
    end
    else
    begin
      FEyeImage.Bitmap.Clear(Color32(ColorToRGB(clBtnFace)));
    end;
  end;
end;

function TgmAlphaChannelPanel.GetMaskOpacityPercent: Single;
begin
  Result := FMaskOpacity / 255;
end; 

procedure TgmAlphaChannelPanel.SetChannelMaskColor(const AValue: TColor32);
begin
  if FMaskColor <> AValue then
  begin
    FMaskColor := AValue;
  end;
end;

procedure TgmAlphaChannelPanel.SetMaskOpacityPercent(const AValue: Single);
begin
  FMaskOpacity                   := Round(255 * AValue);
  FAlphaLayer.Bitmap.MasterAlpha := FMaskOpacity;
end;

procedure TgmAlphaChannelPanel.SetMaskColorIndicator(
  const AValue: TgmMaskColorIndicator);
begin
  if FMaskColorIndicator <> AValue then
  begin
    FMaskColorIndicator := AValue;
    
    InvertBitmap32(FAlphaLayer.Bitmap, [csGrayscale]);
    FAlphaLayer.Changed;
    UpdateThumbnail;
  end;
end;

procedure TgmAlphaChannelPanel.UpdateThumbnail;
begin
  FChannelImage.Bitmap.Assign(FAlphaLayer.Bitmap);
  FChannelImage.Bitmap.MasterAlpha := 255;

  // scale thumbail
  ScaleChannelThumbnail;

  FChannelImage.Bitmap.DrawMode := dmOpaque;
  FChannelImage.Bitmap.Changed;
end;

procedure TgmAlphaChannelPanel.Crop(const ACrop: TgmCrop;
  const ALayerLocation: TFloatRect);
var
  LCropRect  : TRect;
  LCropBitmap: TBitmap32;
begin
  LCropBitmap := TBitmap32.Create;
  try
    LCropBitmap.DrawMode := dmBlend;

    LCropRect := Rect(ACrop.FCropStart.X, ACrop.FCropStart.Y,
                      ACrop.FCropEnd.X, ACrop.FCropEnd.Y);
                      
    CopyRect32WithARGB(LCropBitmap, FAlphaLayer.Bitmap, LCropRect, $00FFFFFF);

    FAlphaLayer.Bitmap.SetSize(LCropBitmap.Width, LCropBitmap.Height);
    CopyBitmap32(FAlphaLayer.Bitmap, LCropBitmap);

    if ACrop.IsResized then
    begin
      if (FAlphaLayer.Bitmap.Width  <> ACrop.ResizeW) or
         (FAlphaLayer.Bitmap.Height <> ACrop.ResizeH) then
      begin
        SmoothResize32(FAlphaLayer.Bitmap, ACrop.ResizeW, ACrop.ResizeH);
      end;
    end;

    FAlphaLayer.Location := ALayerLocation;

    // update thumbnail
    FChannelImage.Bitmap.SetSize(FAlphaLayer.Bitmap.Width,
                                 FAlphaLayer.Bitmap.Height);
                                 
    UpdateThumbnail;
  finally
    LCropBitmap.Free;
  end;
end;

procedure TgmAlphaChannelPanel.Crop(const ACropArea: TRect;
  const ALayerLocation: TFloatRect);
var
  LCropBitmap: TBitmap32;
begin
  LCropBitmap := TBitmap32.Create;
  try
    LCropBitmap.DrawMode := dmBlend;
    CopyRect32WithARGB(LCropBitmap, FAlphaLayer.Bitmap, ACropArea, $00FFFFFF);

    FAlphaLayer.Bitmap.SetSize(LCropBitmap.Width, LCropBitmap.Height);
    CopyBitmap32(FAlphaLayer.Bitmap, LCropBitmap);

    FAlphaLayer.Location := ALayerLocation;

    // update thumbnail
    FChannelImage.Bitmap.SetSize(FAlphaLayer.Bitmap.Width,
                                 FAlphaLayer.Bitmap.Height);
                                 
    UpdateThumbnail;
  finally
    LCropBitmap.Free;
  end;
end;

procedure TgmAlphaChannelPanel.ChangeChannelSize(
  const ANewWidth, ANewHeight: Integer; const ALayerLocation: TFloatRect);
begin
  if (ANewWidth  <> FAlphaLayer.Bitmap.Width) or
     (ANewHeight <> FAlphaLayer.Bitmap.Height) then
  begin
    SmoothResize32(FAlphaLayer.Bitmap, ANewWidth, ANewHeight);
    FAlphaLayer.Location := ALayerLocation;

    // update thumbnail
    FChannelImage.Bitmap.SetSize(FAlphaLayer.Bitmap.Width,
                                 FAlphaLayer.Bitmap.Height);
                                 
    UpdateThumbnail;
  end;
end;

procedure TgmAlphaChannelPanel.ChangeChannelCanvasSize(
  const ANewWidth, ANewHeight: Integer; const ALayerLocation: TFloatRect;
  const AAnchor: TgmAnchorDirection; const ABackColor: TColor32);
var
  LCutBitmap: TBitmap32;
begin
  if (FAlphaLayer.Bitmap.Width  <> ANewWidth) or
     (FAlphaLayer.Bitmap.Height <> ANewHeight) then
  begin
    LCutBitmap := TBitmap32.Create;
    try
      LCutBitmap.DrawMode := dmBlend;

      CutBitmap32ByAnchorDirection(FAlphaLayer.Bitmap, LCutBitmap,
                                   ANewWidth, ANewHeight, AAnchor, ABackColor);

      FAlphaLayer.Bitmap.SetSize(ANewWidth, ANewHeight);
      FAlphaLayer.Bitmap.Clear(ABackColor);

      DrawBitmap32ByAnchorDirection(LCutBitmap, FAlphaLayer.Bitmap, AAnchor);

      FAlphaLayer.Location := ALayerLocation;

      // update thumbnail
      FChannelImage.Bitmap.SetSize(FAlphaLayer.Bitmap.Width,
                                   FAlphaLayer.Bitmap.Height);
                                   
      UpdateThumbnail;
    finally
      LCutBitmap.Free;
    end;
  end;
end;

procedure TgmAlphaChannelPanel.Rotate(const ADeg: Integer;
  const ADirection: TgmRotateDirection; const ALayerLocation: TFloatRect;
  const ABackColor: TColor32);
var
  LSrcBmp: TBitmap32;
begin
  LSrcBmp := TBitmap32.Create;
  try
    LSrcBmp.Assign(FAlphaLayer.Bitmap);
    RotateBitmap32(LSrcBmp, FAlphaLayer.Bitmap, ADirection, ADeg, 0, ABackColor);

    FAlphaLayer.Location := ALayerLocation;

    // update thumbnail
    FChannelImage.Bitmap.SetSize(FAlphaLayer.Bitmap.Width,
                                 FAlphaLayer.Bitmap.Height);
                                 
    UpdateThumbnail;
  finally
    LSrcBmp.Free;
  end;
end;

procedure TgmAlphaChannelPanel.AlphaLayerBlend(F: TColor32; var B: TColor32;
  M: TColor32);
var
  LAlpha  : Cardinal;
  LForeRGB: TColor32;
begin
  LAlpha := ( 255 - (F and $FF) ) shl 24;

  case FMaskColorType of
    mctColor:
      begin
        LForeRGB := LAlpha or (FMaskColor and $FFFFFF);
        
        Blendmode.NormalBlend(LForeRGB, B, M);
      end;

    mctGrayscale:
      begin
        B := F;
      end;
  end;
end;

procedure TgmAlphaChannelPanel.SaveToStream(const AStream: TStream);
var
  LChannelHeader: TgmChannelHeaderVer1;
  i             : Integer;
  LByteMap      : TByteMap;
  LByteBits     : PByte;
begin
  LChannelHeader.ChannelType        := Ord(FChannelType);
  LChannelHeader.ChannelName        := FChannelName.Caption;
  LChannelHeader.MaskColor          := FMaskColor;
  LChannelHeader.MaskOpacityPercent := Self.MaskOpacityPercent;
  LChannelHeader.MaskColorType      := Ord(FMaskColorType);
  LChannelHeader.MaskColorIndicator := Ord(FMaskColorIndicator);

  // write the channel header to stream
  AStream.Write(LChannelHeader, SizeOf(TgmChannelHeaderVer1));

  // write the pixels of channel layer to stream
  LByteMap := TByteMap.Create;
  try
    { Write the mask data to stream.
      Note that, this time we output the thumbnail of the channel layer,
      because it contains the correct channel information. }

    LByteMap.SetSize(FAlphaLayer.Bitmap.Width, FAlphaLayer.Bitmap.Height);
    LByteMap.ReadFrom(FAlphaLayer.Bitmap, ctBlue);

    LByteBits := @LByteMap.Bits[0];
    
    for i := 0 to (FAlphaLayer.Bitmap.Height - 1) do
    begin
      AStream.Write(LByteBits^, FAlphaLayer.Bitmap.Width);
      Inc(LByteBits, FAlphaLayer.Bitmap.Width);
    end;
  finally
    LByteMap.Free;
  end;
end; 

//-- TgmQuickMaskPanel ---------------------------------------------------------

constructor TgmQuickMaskPanel.Create(const AOwner: TWinControl;
  const ALayerCollection: TLayerCollection;
  const ALayerIndex, ALayerWidth, ALayerHeight: Integer;
  const ALayerLocation: TFloatRect; const AMaskColor: TColor32);
begin
  inherited Create(AOwner, ALayerCollection, ALayerIndex,
                   ALayerWidth, ALayerHeight, ALayerLocation, AMaskColor);

  FChannelType            := wctQuickMask;
  FChannelName.Caption    := 'Quick Mask';
  FChannelName.Font.Style := FChannelName.Font.Style + [fsItalic];
end;

//-- TgmLayerMaskPanel ---------------------------------------------------------

constructor TgmLayerMaskPanel.Create(const AOwner: TWinControl;
  const ALayerCollection: TLayerCollection;
  const ALayerIndex, ALayerWidth, ALayerHeight: Integer;
  const ALayerLocation: TFloatRect; const AMaskColor: TColor32;
  const ALayerName: string);
begin
  inherited Create(AOwner, ALayerCollection, ALayerIndex,
                   ALayerWidth, ALayerHeight, ALayerLocation, AMaskColor);

  FChannelType            := wctLayerMask;
  FChannelName.Caption    := ALayerName + ' Mask';
  FChannelName.Font.Style := FChannelName.Font.Style + [fsItalic];
end;

//-- TgmChannelManager ---------------------------------------------------------

constructor TgmChannelManager.Create(const AOwner: TWinControl;
  const ALayerCollection: TLayerCollection;
  const ALayerPanelList: TgmLayerPanelList);
begin
  inherited Create;

  if not Assigned(AOwner) then
  begin
    Exception.Create('TChannelManager constructor -- parameter AOwner must be valid TWinControl.');
  end;

  if not Assigned(ALayerCollection) then
  begin
    Exception.Create('TChannelManager constructor -- parameter ALayerCollection must be valid.');
  end;

  if not Assigned(ALayerPanelList) then
  begin
    Exception.Create('TChannelManager constructor -- parameter ALayerPanelList must be valid.');
  end;

  // pointer to a TWinControl for holding channel panels
  FChannelPanelOwner := AOwner;

  // pointer to a layer collection for holding alpha channel layers, ect.
  FLayerCollection := ALayerCollection;

  // pointer to a layer panel list
  FAssociatedLayerPanelList  := ALayerPanelList;

  FAssociatedLayerPanel      := nil;
  FClickSender               := nil; // remember the mouse right click sender
  FCurrentChannelType        := wctRGB;
  FEnabled                   := True;
  FAllowRefreshChannelPanels := True;

  FChannelPreviewSet   := [csRed, csGreen, csBlue];
  FChannelSelectedSet  := [csRed, csGreen, csBlue];
  FChannelPreviewLayer := nil;
  
  FOnColorModeChanged          := nil;
  FOnAlphaChannelPanelDblClick := nil;
  FOnQuickMaskPanelDblClick    := nil;
  FOnLayerMaskPanelDblClick    := nil;
  FOnChannelPanelRightClick    := nil;
  FOnQuickMaskPanelRightClick  := nil;
  FOnLayerMaskPanelRightClick  := nil;
  FOnChannelChanged            := nil;

  // alpha channel panels
  FAlphaChannelPanelList     := TList.Create;
  FSelectedAlphaChannelPanel := nil;
  FSelectedAlphaChannelIndex := -1;
  FAlphaChannelNumber        := 0;
  FGlobalMaskColor           := clRed32;

  // quick mask
  FQuickMaskPanel          := nil;
  FQuickMaskColor          := clRed32;          // for external modification
  FQuickMaskColorIndicator := mciMaskedArea;    // for external modification
  FQuickMaskOpacityPercent := 0.5;              // for external modification

  // layer mask
  FLayerMaskPanel          := nil;
  FLayerMaskColor          := clRed32;
  FLayerMaskOpacityPercent := 0.5;

{ color channels }

  FRGBChannelPanel              := TgmChannelPanel.Create(AOwner);
  FRGBChannelPanel.ChannelName  := 'RGB';
  FRGBChannelPanel.FChannelType := wctRGB;

  FRedChannelPanel              := TgmChannelPanel.Create(AOwner);
  FRedChannelPanel.ChannelName  := 'Red';
  FRedChannelPanel.FChannelType := wctRed;

  FGreenChannelPanel              := TgmChannelPanel.Create(AOwner);
  FGreenChannelPanel.ChannelName  := 'Green';
  FGreenChannelPanel.FChannelType := wctGreen;

  FBlueChannelPanel              := TgmChannelPanel.Create(AOwner);
  FBlueChannelPanel.ChannelName  := 'Blue';
  FBlueChannelPanel.FChannelType := wctBlue;

  ConnectEventsToColorChannelPanels;
end;

destructor TgmChannelManager.Destroy;
begin
  FChannelPanelOwner           := nil;
  FLayerCollection             := nil;
  FAssociatedLayerPanelList    := nil;
  FAssociatedLayerPanel        := nil;
  FClickSender                 := nil;
  FOnColorModeChanged          := nil;
  FOnAlphaChannelPanelDblClick := nil;
  FOnQuickMaskPanelDblClick    := nil;
  FOnLayerMaskPanelDblClick    := nil;
  FOnChannelPanelRightClick    := nil;
  FOnQuickMaskPanelRightClick  := nil;
  FOnLayerMaskPanelRightClick  := nil;
  FOnChannelChanged            := nil;

  FChannelPreviewLayer.Free;
  FSelectedAlphaChannelPanel := nil;
  DeleteAllAlphaChannelPanels;
  FAlphaChannelPanelList.Free;

  FQuickMaskPanel.Free;
  FLayerMaskPanel.Free;
  
  FRGBChannelPanel.Free;
  FRedChannelPanel.Free;
  FGreenChannelPanel.Free;
  FBlueChannelPanel.Free;

  inherited Destroy;
end;

// this will affects the name of alpha channel
procedure TgmChannelManager.DecrementAlphaChannelNumber(const Amount: Integer);
begin
  if Amount <= 0 then
  begin
    Exit;
  end;

  FAlphaChannelNumber := FAlphaChannelNumber - Amount;

  if FAlphaChannelNumber < 0 then
  begin
    FAlphaChannelNumber := 0;
  end;
end;

procedure TgmChannelManager.ChannelPreviewLayerBlend(F: TColor32;
  var B: TColor32; M: TColor32);
var
  r1, g1, b1  : Cardinal;
  ChannelCount: Integer;
  ResultColor : TColor32;
begin
  r1 := 0;
  g1 := 0;
  b1 := 0;

  ChannelCount := 0;

  if csRed in FChannelPreviewSet then
  begin
    r1 := B shr 16 and $FF;
    Inc(ChannelCount);
  end;

  if csGreen in FChannelPreviewSet then
  begin
    g1 := B shr 8 and $FF;
    Inc(ChannelCount);
  end;

  if csBlue in FChannelPreviewSet then
  begin
    b1 := B and $FF;
    Inc(ChannelCount);
  end;

  ResultColor := $00000000;

  if ChannelCount = 0 then
  begin
    B := $FFFFFFFF;
  end
  else
  begin
    if ChannelCount = 1 then
    begin
      if (B and $FF000000) = $0 then
      begin
        Exit;
      end;

      ResultColor := ResultColor or (r1 shl 16) or (r1 shl 8) or r1;
      ResultColor := ResultColor or (g1 shl 16) or (g1 shl 8) or g1;
      ResultColor := ResultColor or (b1 shl 16) or (b1 shl 8) or b1;
    end
    else
    begin
      ResultColor := (r1 shl 16) or (g1 shl 8) or b1;
    end;

    B := (B and $FF000000) or ResultColor;
  end;
end; 

// click event for eye icons
procedure TgmChannelManager.ChannelEyeClick(ASender: TObject);
var
  i, LVisibleAlphaCount: Integer;
  LAlphaPanel          : TgmAlphaChannelPanel;
  LQuickMaskIsVisible  : Boolean;
  LLayerMaskIsVisible  : Boolean;
begin
  // if the manager is currently diabled, do nothing
  if not FEnabled then
  begin
    Exit;
  end;

  LVisibleAlphaCount  := GetVisibleAlphaChannelCount;
  LQuickMaskIsVisible := ( Assigned(FQuickMaskPanel) and FQuickMaskPanel.IsChannelVisible );
  LLayerMaskIsVisible := ( Assigned(FLayerMaskPanel) and FLayerMaskPanel.IsChannelVisible );

  // RGB channel
  if FRGBChannelPanel.IfClickOnEye(ASender) then
  begin
    FChannelPreviewSet := [csRed, csGreen, csBlue];
  end
  else // red
  if FRedChannelPanel.IfClickOnEye(ASender) then
  begin
    if csRed in FChannelPreviewSet then
    begin
      if (csGreen in FChannelPreviewSet) or
         (csBlue  in FChannelPreviewSet) or
         (LVisibleAlphaCount > 0) or
         LQuickMaskIsVisible or
         LLayerMaskIsVisible then
      begin
        FChannelPreviewSet := FChannelPreviewSet - [csRed];
      end;
    end
    else
    begin
      FChannelPreviewSet := FChannelPreviewSet + [csRed];
    end;
  end
  else // green
  if FGreenChannelPanel.IfClickOnEye(ASender) then
  begin
    if csGreen in FChannelPreviewSet then
    begin
      if (csRed  in FChannelPreviewSet) or
         (csBlue in FChannelPreviewSet) or
         (LVisibleAlphaCount > 0) or
         LQuickMaskIsVisible or
         LLayerMaskIsVisible then
      begin
        FChannelPreviewSet := FChannelPreviewSet - [csGreen];
      end;
    end
    else
    begin
      FChannelPreviewSet := FChannelPreviewSet + [csGreen];
    end;
  end
  else // blue
  if FBlueChannelPanel.IfClickOnEye(ASender) then
  begin
    if csBlue in FChannelPreviewSet then
    begin
      if (csRed   in FChannelPreviewSet) or
         (csGreen in FChannelPreviewSet) or
         (LVisibleAlphaCount > 0) or
         LQuickMaskIsVisible or
         LLayerMaskIsVisible then
      begin
        FChannelPreviewSet := FChannelPreviewSet - [csBlue];
      end;
    end
    else
    begin
      FChannelPreviewSet := FChannelPreviewSet + [csBlue];
    end;
  end
  else
  if Assigned(FQuickMaskPanel) and
     ( FQuickMaskPanel.IfClickOnEye(ASender) ) then
  begin
    if FQuickMaskPanel.IsChannelVisible then
    begin
      if (FChannelPreviewSet <> []) or
         (LVisibleAlphaCount > 0) or
         LLayerMaskIsVisible then
      begin
        FQuickMaskPanel.IsChannelVisible := False;
      end;
    end
    else
    begin
      FQuickMaskPanel.IsChannelVisible := True;
    end;

    // get the visibility of quick mask once again
    LQuickMaskIsVisible := FQuickMaskPanel.IsChannelVisible;
  end
  else
  if Assigned(FLayerMaskPanel) and
     ( FLayerMaskPanel.IfClickOnEye(ASender) ) then
  begin
    if FLayerMaskPanel.IsChannelVisible then
    begin
      if (FChannelPreviewSet <> []) or
         (LVisibleAlphaCount > 0) or
         LQuickMaskIsVisible then
      begin
        FLayerMaskPanel.IsChannelVisible := False;
      end;
    end
    else
    begin
      FLayerMaskPanel.IsChannelVisible := True;
    end;

    // get the visibility of layer mask once again
    LLayerMaskIsVisible := FLayerMaskPanel.IsChannelVisible;
  end
  else // alpha channel panels
  begin
    if FAlphaChannelPanelList.Count > 0 then
    begin
      for i := 0 to (FAlphaChannelPanelList.Count - 1) do
      begin
        LAlphaPanel := TgmAlphaChannelPanel(FAlphaChannelPanelList.Items[i]);

        if LAlphaPanel.IfClickOnEye(ASender) then
        begin
          if LAlphaPanel.IsChannelVisible then
          begin
            if (FChannelPreviewSet <> []) or
               (LVisibleAlphaCount > 1) or
               LQuickMaskIsVisible or
               LLayerMaskIsVisible then
            begin
              LAlphaPanel.IsChannelVisible := False;
            end;
          end
          else
          begin
            LAlphaPanel.IsChannelVisible := True;
          end;

          Break;
        end;
      end;
    end;
  end;

  FRGBChannelPanel.IsChannelVisible   := (FChannelPreviewSet = [csRed, csGreen, csBlue]);
  FRedChannelPanel.IsChannelVisible   := (csRed   in FChannelPreviewSet);
  FGreenChannelPanel.IsChannelVisible := (csGreen in FChannelPreviewSet);
  FBlueChannelPanel.IsChannelVisible  := (csBlue  in FChannelPreviewSet);

  // change mask color type for visible alpha channels
  if (FChannelPreviewSet = []) and
     (GetVisibleAlphaChannelCount = 1) and
     (LQuickMaskIsVisible = False) and
     (LLayerMaskIsVisible = False) then
  begin
    ChangeMaskColorTypeForVisibleAlphaChannels(mctGrayscale);
  end
  else
  begin
    ChangeMaskColorTypeForVisibleAlphaChannels(mctColor);
  end;

  // change mask color type for quick mask
  if LQuickMaskIsVisible then
  begin
    if (FChannelPreviewSet = []) and
       (GetVisibleAlphaChannelCount = 0) and
       (LLayerMaskIsVisible = False) then
    begin
      FQuickMaskPanel.MaskColorType := mctGrayscale;
    end
    else
    begin
      FQuickMaskPanel.MaskColorType := mctColor;
    end;
  end;

  // change mask color type for layer mask
  if LLayerMaskIsVisible then
  begin
    if (FChannelPreviewSet = []) and
       (GetVisibleAlphaChannelCount = 0) and
       (LQuickMaskIsVisible = False) then
    begin
      FLayerMaskPanel.MaskColorType := mctGrayscale;
    end
    else
    begin
      FLayerMaskPanel.MaskColorType := mctColor;
    end;
  end;

  FChannelPreviewLayer.Changed;
end;

procedure TgmChannelManager.AlphaChannelPanelDblClick(ASender: TObject);
begin
  // if the manager is currently diabled, do nothing
  if not FEnabled then
  begin
    Exit;
  end;

  if Assigned(FOnAlphaChannelPanelDblClick) then
  begin
    FOnAlphaChannelPanelDblClick(ASender);
  end;
end;

procedure TgmChannelManager.QuickMaskDblClick(ASender: TObject);
begin
  // if the manager is currently diabled, do nothing
  if not FEnabled then
  begin
    Exit;
  end;

  if Assigned(FOnQuickMaskPanelDblClick) then
  begin
    FOnQuickMaskPanelDblClick(ASender);
  end;
end;

procedure TgmChannelManager.LayerMaskDblClick(ASender: TObject);
begin
  // if the manager is currently diabled, do nothing
  if not FEnabled then
  begin
    Exit;
  end;

  if Assigned(FOnLayerMaskPanelDblClick) then
  begin
    FOnLayerMaskPanelDblClick(ASender);
  end;
end;

procedure TgmChannelManager.ChannelPanelMouseDown(ASender: TObject;
  AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer);
var
  i          : Integer;
  LAlphaPanel: TgmAlphaChannelPanel;
begin
  // if the manager is currently diabled, do nothing
  if not FEnabled then
  begin
    Exit;
  end;

  if not (ssShift in AShift) then
  begin
    DeselectAllChannels(HIDE_CHANNEL);
  end;

  // RGB composite
  if FRGBChannelPanel.IfClickOnPanel(ASender) then
  begin
    if not FRGBChannelPanel.IsSelected then
    begin
      // deselect all alpha channels and quick mask even if the user pressed the Shift key
      if ssShift in AShift then
      begin
        DeselectAllAlphaChannels(DONT_HIDE_CHANNEL);
        DeselectQuickMask(DONT_HIDE_CHANNEL);
        DeselectLayerMask(DONT_HIDE_CHANNEL);
      end;

      SelectAllColorChannels;
    end;
  end
  else  // red
  if FRedChannelPanel.IfClickOnPanel(ASender) then
  begin
    if ssShift in AShift then
    begin
      // deselect all alpha channels and quick mask even if the user pressed the Shift key
      DeselectAllAlphaChannels(DONT_HIDE_CHANNEL);
      DeselectQuickMask(DONT_HIDE_CHANNEL);
      DeselectLayerMask(DONT_HIDE_CHANNEL);

      if csRed in FChannelSelectedSet then
      begin
        if (csGreen in FChannelSelectedSet) or
           (csBlue  in FChannelSelectedSet) then
        begin
          DeselectRedChannel(HIDE_CHANNEL);
        end
        else
        begin
          SelectAllColorChannels;
        end;
      end
      else
      begin
        SelectRedChannel;
      end;
    end
    else
    begin
      SelectRedChannel;
    end;
  end
  else  // green
  if FGreenChannelPanel.IfClickOnPanel(ASender) then
  begin
    if ssShift in AShift then
    begin
      // deselect all alpha channels and quick mask even if the user pressed the Shift key
      DeselectAllAlphaChannels(DONT_HIDE_CHANNEL);
      DeselectQuickMask(DONT_HIDE_CHANNEL);
      DeselectLayerMask(DONT_HIDE_CHANNEL);

      if csGreen in FChannelSelectedSet then
      begin
        if (csRed  in FChannelSelectedSet) or
           (csBlue in FChannelSelectedSet) then
        begin
          DeselectGreenChannel(HIDE_CHANNEL);
        end
        else
        begin
          SelectAllColorChannels;
        end;
      end
      else
      begin
        SelectGreenChannel;
      end;
    end
    else
    begin
      SelectGreenChannel;
    end;
  end
  else  // blue
  if FBlueChannelPanel.IfClickOnPanel(ASender) then
  begin
    if ssShift in AShift then
    begin
      // deselect all alpha channels and quick mask even if the user pressed the Shift key
      DeselectAllAlphaChannels(DONT_HIDE_CHANNEL);
      DeselectQuickMask(DONT_HIDE_CHANNEL);
      DeselectLayerMask(DONT_HIDE_CHANNEL);

      if csBlue in FChannelSelectedSet then
      begin
        if (csRed   in FChannelSelectedSet) or
           (csGreen in FChannelSelectedSet) then
        begin
          DeselectBlueChannel(HIDE_CHANNEL);
        end
        else
        begin
          SelectAllColorChannels;
        end;
      end
      else
      begin
        SelectBlueChannel;
      end;
    end
    else
    begin
      SelectBlueChannel;
    end;
  end
  else  // alpha channels
  begin
    if FAlphaChannelPanelList.Count > 0 then
    begin
      { We couldn't process more than one alpha channels at a time temporarily,
        if we could do that in the future, delete the following line. }
      DeselectAllChannels(HIDE_CHANNEL);

      for i := 0 to (FAlphaChannelPanelList.Count - 1) do
      begin
        LAlphaPanel := TgmAlphaChannelPanel(FAlphaChannelPanelList.Items[i]);

        if LAlphaPanel.IfClickOnPanel(ASender) then
        begin
          FCurrentChannelType := wctAlpha;

          // calling callback function to do some further processes after color mode is changed
          if Assigned(FOnColorModeChanged) then
          begin
            FOnColorModeChanged(cmGrayscale);
          end;

          { We couldn't process more than one alpha channels at a time temporarily,
            if we could do that in the future, enable the following lines. }
//          if ssShift in Shift then
//          begin
//            DeselectAllColorChannels(DONT_HIDE_CHANNEL);
//            DeselectQuickMask(DONT_HIDE_CHANNEL);
//            DeselectLayerMask(DONT_HIDE_CHANNEL);
//
//            if AlphaPanel.IsSelected then
//            begin
//              if GetSelectedAlphaChannelCount > 1
//              then AlphaPanel.IsSelected  := False;
//            end
//            else AlphaPanel.IsSelected := True;
//          end
//          else
          LAlphaPanel.IsSelected       := True;
          LAlphaPanel.IsChannelVisible := LAlphaPanel.IsSelected;

          if GetSelectedAlphaChannelCount = 1 then
          begin
            FSelectedAlphaChannelPanel := LAlphaPanel;
            FSelectedAlphaChannelIndex := i;
            FChannelSelectedSet        := FChannelSelectedSet + [csGrayscale];
          end
          else
          begin
            FSelectedAlphaChannelPanel := nil; // which to select?
            FSelectedAlphaChannelIndex := -1;
            FChannelSelectedSet        := FChannelSelectedSet - [csGrayscale];
          end;

          Break;
        end;
      end;
    end;
  end;

  // change mask color type for visible alpha channels
  if (FChannelPreviewSet = []) and (GetVisibleAlphaChannelCount = 1) then
  begin
    ChangeMaskColorTypeForVisibleAlphaChannels(mctGrayscale);
  end
  else
  begin
    ChangeMaskColorTypeForVisibleAlphaChannels(mctColor);
  end;

  FChannelPreviewLayer.Changed;

  FAssociatedLayerPanel.UpdateLayerPanelState;

  if Assigned(FOnChannelChanged) then
  begin
    FOnChannelChanged(True);
  end;

{ mouse right click }
  if AButton = mbRight then
  begin
    FClickSender := ASender;  // remember the mouse right click sender

    if Assigned(FOnChannelPanelRightClick) then
    begin
      FOnChannelPanelRightClick(ASender);
    end;
  end;
end;

procedure TgmChannelManager.QuickMaskPanelMouseDown(ASender: TObject;
  AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer);
begin
  // if the manager is currently diabled, do nothing
  if not FEnabled then
  begin
    Exit;
  end;

  if Assigned(FQuickMaskPanel) then
  begin
    if FQuickMaskPanel.IfClickOnPanel(ASender) then
    begin
      DeselectAllChannels(DONT_HIDE_CHANNEL);
      ChangeMaskColorTypeForVisibleAlphaChannels(mctColor);

      FCurrentChannelType := wctQuickMask;
      FChannelSelectedSet := FChannelSelectedSet + [csGrayscale];

      // calling callback function to do some further processes after color mode is changed
      if Assigned(FOnColorModeChanged) then
      begin
        FOnColorModeChanged(cmGrayscale);
      end;

      FQuickMaskPanel.IsSelected       := True;
      FQuickMaskPanel.IsChannelVisible := True;

      FQuickMaskPanel.AlphaLayer.Changed;

      FAssociatedLayerPanel.UpdateLayerPanelState;

      if Assigned(FOnChannelChanged) then
      begin
        FOnChannelChanged(True);
      end;

      // mouse right click
      if AButton = mbRight then
      begin
        FClickSender := ASender;

        if Assigned(FOnQuickMaskPanelRightClick) then
        begin
          FOnQuickMaskPanelRightClick(ASender);
        end;
      end;
    end;
  end;
end;

procedure TgmChannelManager.QuickMaskImageMouseDown(ASender: TObject;
  AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer;
  ALayer: TCustomLayer);
begin
  QuickMaskPanelMouseDown(ASender, AButton, AShift, AX, AY);
end;

procedure TgmChannelManager.ChannelImageMouseDown(ASender: TObject;
  AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer;
  ALayer: TCustomLayer);
begin
  ChannelPanelMouseDown(ASender, AButton, AShift, AX, AY);
end;

procedure TgmChannelManager.LayerMaskPanelMouseDown(ASender: TObject;
  AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer);
begin
  // if the manager is currently diabled, do nothing
  if not FEnabled then
  begin
    Exit;
  end;

  if Assigned(FLayerMaskPanel) then
  begin
    if FLayerMaskPanel.IfClickOnPanel(ASender) then
    begin
      SelectLayerMask;

      // mouse right click
      if AButton = mbRight then
      begin
        FClickSender := ASender;

        if Assigned(FOnLayerMaskPanelRightClick) then
        begin
          FOnLayerMaskPanelRightClick(ASender);
        end;
      end;
    end;
  end;
end; 

procedure TgmChannelManager.LayerMaskImageMouseDown(ASender: TObject;
  AButton: TMouseButton; AShift: TShiftState; AX, AY: Integer;
  ALayer: TCustomLayer);
begin
  LayerMaskPanelMouseDown(ASender, AButton, AShift, AX, AY);
end;

procedure TgmChannelManager.ConnectEventsToColorChannelPanels;
begin
  // eye icons
  FRGBChannelPanel.ConnectChannelEyeClickEvent(ChannelEyeClick);
  FRedChannelPanel.ConnectChannelEyeClickEvent(ChannelEyeClick);
  FGreenChannelPanel.ConnectChannelEyeClickEvent(ChannelEyeClick);
  FBlueChannelPanel.ConnectChannelEyeClickEvent(ChannelEyeClick);
  
  // panels
  FRGBChannelPanel.ConnectChannelPanelMouseDownEvent(ChannelPanelMouseDown);
  FRedChannelPanel.ConnectChannelPanelMouseDownEvent(ChannelPanelMouseDown);
  FGreenChannelPanel.ConnectChannelPanelMouseDownEvent(ChannelPanelMouseDown);
  FBlueChannelPanel.ConnectChannelPanelMouseDownEvent(ChannelPanelMouseDown);

  FRGBChannelPanel.ConnectChannelImageMouseDownEvent(ChannelImageMouseDown);
  FRedChannelPanel.ConnectChannelImageMouseDownEvent(ChannelImageMouseDown);
  FGreenChannelPanel.ConnectChannelImageMouseDownEvent(ChannelImageMouseDown);
  FBlueChannelPanel.ConnectChannelImageMouseDownEvent(ChannelImageMouseDown);
end;

procedure TgmChannelManager.SelectRedChannel;
begin
  FChannelSelectedSet := FChannelSelectedSet + [csRed];
  FChannelPreviewSet  := FChannelPreviewSet + [csRed];
  FCurrentChannelType := wctRed;

  FRedChannelPanel.IsSelected       := True;
  FRedChannelPanel.IsChannelVisible := True;
  
  FAssociatedLayerPanel.LayerProcessStage := lpsLayer;

  if (csRed   in FChannelSelectedSet) and
     (csGreen in FChannelSelectedSet) and
     (csBlue  in FChannelSelectedSet) then
  begin
    FRGBChannelPanel.IsSelected       := True;
    FRGBChannelPanel.IsChannelVisible := True;
  end;

  // calling callback function to do some further processes after color mode is changed
  if Assigned(FOnColorModeChanged) then
  begin
    FOnColorModeChanged(cmRGB);
  end;
end;

procedure TgmChannelManager.SelectGreenChannel;
begin
  FChannelSelectedSet := FChannelSelectedSet + [csGreen];
  FChannelPreviewSet  := FChannelPreviewSet + [csGreen];
  FCurrentChannelType := wctGreen;

  FGreenChannelPanel.IsSelected       := True;
  FGreenChannelPanel.IsChannelVisible := True;
  
  FAssociatedLayerPanel.LayerProcessStage := lpsLayer;

  if (csRed   in FChannelSelectedSet) and
     (csGreen in FChannelSelectedSet) and
     (csBlue  in FChannelSelectedSet) then
  begin
    FRGBChannelPanel.IsSelected       := True;
    FRGBChannelPanel.IsChannelVisible := True;
  end;

  // calling callback function to do some further processes after color mode is changed
  if Assigned(FOnColorModeChanged) then
  begin
    FOnColorModeChanged(cmRGB);
  end;
end;

procedure TgmChannelManager.SelectBlueChannel;
begin
  FChannelSelectedSet := FChannelSelectedSet + [csBlue];
  FChannelPreviewSet  := FChannelPreviewSet + [csBlue];
  FCurrentChannelType := wctBlue;

  FBlueChannelPanel.IsSelected       := True;
  FBlueChannelPanel.IsChannelVisible := True;

  FAssociatedLayerPanel.LayerProcessStage := lpsLayer;

  if (csRed   in FChannelSelectedSet) and
     (csGreen in FChannelSelectedSet) and
     (csBlue  in FChannelSelectedSet) then
  begin
    FRGBChannelPanel.IsSelected       := True;
    FRGBChannelPanel.IsChannelVisible := True;
  end;

  // calling callback function to do some further processes after color mode is changed
  if Assigned(FOnColorModeChanged) then
  begin
    FOnColorModeChanged(cmRGB);
  end;
end;

procedure TgmChannelManager.SelectQuickMask;
begin
  if Assigned(FQuickMaskPanel) then
  begin
    DeselectAllColorChannels(DONT_HIDE_CHANNEL);
    DeselectAllAlphaChannels(HIDE_CHANNEL);
    DeselectLayerMask(HIDE_CHANNEL);

    PreviewAllColorChannels;

    FCurrentChannelType           := wctQuickMask;
    FChannelSelectedSet           := FChannelSelectedSet + [csGrayscale];
    FQuickMaskPanel.IsSelected    := True;
    FQuickMaskPanel.MaskColorType := mctColor;

    FQuickMaskPanel.AlphaLayer.Changed;

    FAssociatedLayerPanel.UpdateLayerPanelState;

    if Assigned(FOnChannelChanged) then
    begin
      FOnChannelChanged(True);
    end;

    // calling callback function to do some further processes after color mode is changed
    if Assigned(FOnColorModeChanged) then
    begin
      FOnColorModeChanged(cmGrayscale);
    end;
  end;
end;

procedure TgmChannelManager.SelectAllColorChannels;
begin
  FChannelSelectedSet := [csRed, csGreen, csBlue];
  FChannelPreviewSet  := [csRed, csGreen, csBlue];
  FCurrentChannelType := wctRGB;

  FRGBChannelPanel.IsSelected   := True;
  FRedChannelPanel.IsSelected   := True;
  FGreenChannelPanel.IsSelected := True;
  FBlueChannelPanel.IsSelected  := True;

  FRGBChannelPanel.IsChannelVisible   := True;
  FRedChannelPanel.IsChannelVisible   := True;
  FGreenChannelPanel.IsChannelVisible := True;
  FBlueChannelPanel.IsChannelVisible  := True;

  FAssociatedLayerPanel.LayerProcessStage := lpsLayer;

  // calling callback function to do some further processes after color mode is changed
  if Assigned(FOnColorModeChanged) then
  begin
    FOnColorModeChanged(cmRGB);
  end;
end;

procedure TgmChannelManager.SelectAlphaChannelByIndex(const AIndex: Integer);
begin
  if (AIndex >= 0) and (AIndex < FAlphaChannelPanelList.Count) then
  begin
    DeselectAllAlphaChannels(HIDE_CHANNEL);
    DeselectQuickMask(HIDE_CHANNEL);
    DeselectAllColorChannels(DONT_HIDE_CHANNEL);
    PreviewAllColorChannels;

    FCurrentChannelType                         := wctAlpha;
    FSelectedAlphaChannelPanel                  := TgmAlphaChannelPanel(FAlphaChannelPanelList.Items[AIndex]);
    FSelectedAlphaChannelIndex                  := AIndex;
    FSelectedAlphaChannelPanel.IsSelected       := True;
    FSelectedAlphaChannelPanel.IsChannelVisible := FSelectedAlphaChannelPanel.IsSelected;
    FChannelSelectedSet                         := FChannelSelectedSet + [csGrayscale];
  end;
end;

procedure TgmChannelManager.DeselectRedChannel(const AHideChannel: Boolean);
begin
  FChannelSelectedSet         := FChannelSelectedSet - [csRed];
  FRedChannelPanel.IsSelected := False;

  FRGBChannelPanel.IsSelected       := False;
  FRGBChannelPanel.IsChannelVisible := False;

  if AHideChannel then
  begin
    FChannelPreviewSet                := FChannelPreviewSet - [csRed];
    FRedChannelPanel.IsChannelVisible := False;
  end;
end;

procedure TgmChannelManager.DeselectGreenChannel(const AHideChannel: Boolean);
begin
  FChannelSelectedSet           := FChannelSelectedSet - [csGreen];
  FGreenChannelPanel.IsSelected := False;

  FRGBChannelPanel.IsSelected       := False;
  FRGBChannelPanel.IsChannelVisible := False;

  if AHideChannel then
  begin
    FChannelPreviewSet                  := FChannelPreviewSet - [csGreen];
    FGreenChannelPanel.IsChannelVisible := False;
  end;
end;

procedure TgmChannelManager.DeselectBlueChannel(const AHideChannel: Boolean);
begin
  FChannelSelectedSet          := FChannelSelectedSet - [csBlue];
  FBlueChannelPanel.IsSelected := False;

  FRGBChannelPanel.IsSelected       := False;
  FRGBChannelPanel.IsChannelVisible := False;

  if AHideChannel then
  begin
    FChannelPreviewSet                 := FChannelPreviewSet - [csBlue];
    FBlueChannelPanel.IsChannelVisible := False;
  end;
end;

procedure TgmChannelManager.DeselectAllAlphaChannels(
  const AHideChannel: Boolean);
var
  i          : Integer;
  LAlphaPanel: TgmAlphaChannelPanel;
begin
  if FAlphaChannelPanelList.Count > 0 then
  begin
    for i := 0 to (FAlphaChannelPanelList.Count - 1) do
    begin
      LAlphaPanel := TgmAlphaChannelPanel(FAlphaChannelPanelList.Items[i]);
      LAlphaPanel.IsSelected := False;

      if AHideChannel then
      begin
        LAlphaPanel.IsChannelVisible := False;
      end;
    end;
  end;

  FSelectedAlphaChannelPanel := nil;
  FSelectedAlphaChannelIndex := -1;
end; 

procedure TgmChannelManager.DeselectQuickMask(const AHideChannel: Boolean);
begin
  if Assigned(FQuickMaskPanel) then
  begin
    FQuickMaskPanel.IsSelected := False;

    if AHideChannel then
    begin
      FQuickMaskPanel.IsChannelVisible := False;
    end;
  end;
end;

procedure TgmChannelManager.DeselectLayerMask(const AHideChannel: Boolean);
begin
  if Assigned(FLayerMaskPanel) then
  begin
    FLayerMaskPanel.IsSelected := False;

    if AHideChannel then
    begin
      FLayerMaskPanel.IsChannelVisible := False;
    end;
  end;
end;

procedure TgmChannelManager.DeselectAllColorChannels(
  const AHideChannel: Boolean);
begin
  DeselectRedChannel(AHideChannel);
  DeselectGreenChannel(AHideChannel);
  DeselectBlueChannel(AHideChannel);

  FChannelSelectedSet := [];
  
  FRGBChannelPanel.IsChannelVisible := (csRed   in FChannelPreviewSet) and
                                       (csGreen in FChannelPreviewSet) and
                                       (csBlue  in FChannelPreviewSet);
end; 

procedure TgmChannelManager.DeselectAllChannels(const AIfHideChannel: Boolean);
begin
  DeselectRedChannel(AIfHideChannel);
  DeselectGreenChannel(AIfHideChannel);
  DeselectBlueChannel(AIfHideChannel);
  DeselectAllAlphaChannels(AIfHideChannel);
  DeselectQuickMask(AIfHideChannel);
  DeselectLayerMask(AIfHideChannel);

  if AIfHideChannel then
  begin
    FRGBChannelPanel.IsChannelVisible := False;
  end
  else
  begin
    FRGBChannelPanel.IsChannelVisible := (csRed   in FChannelPreviewSet) and
                                         (csGreen in FChannelPreviewSet) and
                                         (csBlue  in FChannelPreviewSet);
  end;

  FChannelSelectedSet := [];
end;

procedure TgmChannelManager.PreviewAllColorChannels;
begin
  FChannelPreviewSet                  := [csRed, csGreen, csBlue];
  FRGBChannelPanel.IsChannelVisible   := True;
  FRedChannelPanel.IsChannelVisible   := True;
  FGreenChannelPanel.IsChannelVisible := True;
  FBlueChannelPanel.IsChannelVisible  := True;
end;

{procedure TgmChannelManager.HideAllColorChannels;
begin
  FChannelPreviewSet := [];
end; }

procedure TgmChannelManager.CreateChannelPreviewLayer(
  const ALayerCollection: TLayerCollection; const ALayerPanelList: TgmLayerPanelList;
  const ALayerWidth, ALayerHeight: Integer; const ALayerLocation: TFloatRect);
begin
  FRGBChannelPanel.ChannelImage.Bitmap.SetSize(ALayerWidth, ALayerHeight);
  FRedChannelPanel.ChannelImage.Bitmap.SetSize(ALayerWidth, ALayerHeight);
  FGreenChannelPanel.ChannelImage.Bitmap.SetSize(ALayerWidth, ALayerHeight);
  FBlueChannelPanel.ChannelImage.Bitmap.SetSize(ALayerWidth, ALayerHeight);

  FChannelPreviewLayer := TBitmapLayer.Create(ALayerCollection);
  with FChannelPreviewLayer do
  begin
    Bitmap.SetSize(ALayerWidth, ALayerHeight);
    
    Bitmap.DrawMode       := dmCustom;
    Bitmap.OnPixelCombine := ChannelPreviewLayerBlend;
    Location              := ALayerLocation;
    Scaled                := True;
    Visible               := True;
  end;

  FChannelPreviewLayer.Changed;
  UpdateColorChannelThumbnails(ALayerPanelList);
end;

procedure TgmChannelManager.ShowAllChannelPanels;
var
  i, LAccumHeight: Integer;
  LAlphaPanel    : TgmAlphaChannelPanel;
begin
  // recalculating the top property of the Panel for display them in right order
  ShowChannelThumbnailsByRightOrder;

  FRGBChannelPanel.Top := 0;
  FRGBChannelPanel.Show;

  FRedChannelPanel.Top := CHANNEL_PANEL_HEIGHT;
  FRedChannelPanel.Show;

  FGreenChannelPanel.Top := FRedChannelPanel.Top + CHANNEL_PANEL_HEIGHT;
  FGreenChannelPanel.Show;

  FBlueChannelPanel.Top := FGreenChannelPanel.Top + CHANNEL_PANEL_HEIGHT;
  FBlueChannelPanel.Show;

  LAccumHeight := FBlueChannelPanel.Top + CHANNEL_PANEL_HEIGHT;

  if Assigned(FLayerMaskPanel) then
  begin
    FLayerMaskPanel.Top := FBlueChannelPanel.Top + CHANNEL_PANEL_HEIGHT;
    FLayerMaskPanel.Show;

    LAccumHeight := FLayerMaskPanel.Top + CHANNEL_PANEL_HEIGHT
  end;

  if FAlphaChannelPanelList.Count > 0 then
  begin
    for i := 0 to (FAlphaChannelPanelList.Count - 1) do
    begin
      LAlphaPanel     := TgmAlphaChannelPanel(FAlphaChannelPanelList.Items[i]);
      LAlphaPanel.Top := LAccumHeight;

      LAlphaPanel.Show;
      LAccumHeight := LAccumHeight + CHANNEL_PANEL_HEIGHT;
    end;
  end;

  if Assigned(FQuickMaskPanel) then
  begin
    FQuickMaskPanel.Top := LAccumHeight;
    FQuickMaskPanel.Show;
  end;
end;

procedure TgmChannelManager.HideAllChannelPanels;
var
  i          : Integer;
  LAlphaPanel: TgmAlphaChannelPanel;
begin
  FRGBChannelPanel.Hide;
  FRedChannelPanel.Hide;
  FGreenChannelPanel.Hide;
  FBlueChannelPanel.Hide;

  if FAlphaChannelPanelList.Count > 0 then
  begin
    for i := 0 to (FAlphaChannelPanelList.Count - 1) do
    begin
      LAlphaPanel := TgmAlphaChannelPanel(FAlphaChannelPanelList.Items[i]);
      LAlphaPanel.Hide;
    end;
  end;

  if Assigned(FQuickMaskPanel) then
  begin
    FQuickMaskPanel.Hide;
  end;

  if Assigned(FLayerMaskPanel) then
  begin
    FLayerMaskPanel.Hide;
  end;
end; 

procedure TgmChannelManager.ShowChannelThumbnailsByRightOrder;
var
  i          : Integer;
  LAlphaPanel: TgmAlphaChannelPanel;
begin
  FRGBChannelPanel.ShowThumbnailByRightOrder;
  FRedChannelPanel.ShowThumbnailByRightOrder;
  FGreenChannelPanel.ShowThumbnailByRightOrder;
  FBlueChannelPanel.ShowThumbnailByRightOrder;

  if FAlphaChannelPanelList.Count > 0 then
  begin
    for i := 0 to (FAlphaChannelPanelList.Count - 1) do
    begin
      LAlphaPanel := TgmAlphaChannelPanel(FAlphaChannelPanelList.Items[i]);
      LAlphaPanel.ShowThumbnailByRightOrder;
    end;
  end;

  if Assigned(FQuickMaskPanel) then
  begin
    FQuickMaskPanel.ShowThumbnailByRightOrder;
  end;

  if Assigned(FLayerMaskPanel) then
  begin
    FLayerMaskPanel.ShowThumbnailByRightOrder;
  end;
end;

procedure TgmChannelManager.UpdateColorChannelThumbnails(
  ALayerPanelList: TgmLayerPanelList);
var
  LBackLayer        : TBitmapLayer;
  LLayerCompositeBmp: TBitmap32;
  a, r, g, b        : Cardinal;
  i                 : Integer;
  LCompositeBit     : PColor32;
  LRedChannelBit    : PColor32;
  LGreenChannelBit  : PColor32;
  LBlueChannelBit   : PColor32;
begin
  LLayerCompositeBmp := TBitmap32.Create;
  try
    LBackLayer := TgmLayerPanel(ALayerPanelList.Items[0]).AssociatedLayer;

    LLayerCompositeBmp.DrawMode := dmBlend;
    LLayerCompositeBmp.SetSize(LBackLayer.Bitmap.Width, LBackLayer.Bitmap.Height);

    ALayerPanelList.FlattenLayersToBitmap(LLayerCompositeBmp, dmBlend);

    FRGBChannelPanel.ChannelImage.Bitmap.Assign(LLayerCompositeBmp);
    FRGBChannelPanel.ChannelImage.Bitmap.Changed;

    LCompositeBit    := @LLayerCompositeBmp.Bits[0];
    LRedChannelBit   := @FRedChannelPanel.ChannelImage.Bitmap.Bits[0];
    LGreenChannelBit := @FGreenChannelPanel.ChannelImage.Bitmap.Bits[0];
    LBlueChannelBit  := @FBlueChannelPanel.ChannelImage.Bitmap.Bits[0];

    for i := 0 to (LLayerCompositeBmp.Width * LLayerCompositeBmp.Height - 1) do
    begin
      a := LCompositeBit^        and $FF000000;
      r := LCompositeBit^ shr 16 and $FF;
      g := LCompositeBit^ shr  8 and $FF;
      b := LCompositeBit^        and $FF;

      LRedChannelBit^   := a or (r shl 16) or (r shl 8) or r;
      LGreenChannelBit^ := a or (g shl 16) or (g shl 8) or g;
      LBlueChannelBit^  := a or (b shl 16) or (b shl 8) or b;

      Inc(LCompositeBit);
      Inc(LRedChannelBit);
      Inc(LGreenChannelBit);
      Inc(LBlueChannelBit);
    end;

    FRGBChannelPanel.ScaleChannelThumbnail;
    FRGBChannelPanel.ChannelImage.Bitmap.Changed;

    FRedChannelPanel.ScaleChannelThumbnail;
    FRedChannelPanel.ChannelImage.Bitmap.Changed;

    FGreenChannelPanel.ScaleChannelThumbnail;
    FGreenChannelPanel.ChannelImage.Bitmap.Changed;

    FBlueChannelPanel.ScaleChannelThumbnail;
    FBlueChannelPanel.ChannelImage.Bitmap.Changed;
  finally
    LLayerCompositeBmp.Free;
  end;
end;

// associate to a layer panel
procedure TgmChannelManager.AssociateToLayerPanel(const ALayerPanel: TgmLayerPanel);
begin
  FAssociatedLayerPanel := ALayerPanel;

  if FAssociatedLayerPanel.IsHasMask then
  begin
    CreateLayerMaskPanel(FChannelPanelOwner, FLayerCollection,
                         FAssociatedLayerPanelList);
  end
  else
  begin
    if Assigned(FLayerMaskPanel) then
    begin
      FreeAndNil(FLayerMaskPanel);
    end;
  end;

  if Assigned(FQuickMaskPanel) then
  begin
    SelectQuickMask;
  end
  else
  begin
    // only select color channels whenever switch layer panels
    DeselectAllChannels(HIDE_CHANNEL);
    SelectAllColorChannels;
  end;
end;

procedure TgmChannelManager.AddNewAlphaChannel(const AOwner: TWinControl;
  const ALayerCollection: TLayerCollection;
  const ALayerPanelList: TgmLayerPanelList);
var
  LIndex: Integer;
begin
  DeselectAllChannels(HIDE_CHANNEL);

  LIndex := ALayerPanelList.Count + FAlphaChannelPanelList.Count + 1;

  FSelectedAlphaChannelPanel := TgmAlphaChannelPanel.Create(
    AOwner,
    ALayerCollection,
    LIndex,
    FChannelPreviewLayer.Bitmap.Width,
    FChannelPreviewLayer.Bitmap.Height,
    FChannelPreviewLayer.Location,
    FGlobalMaskColor);

  FAlphaChannelPanelList.Add(FSelectedAlphaChannelPanel);
  Inc(FAlphaChannelNumber);

  FSelectedAlphaChannelIndex := FAlphaChannelPanelList.Count - 1;
  FChannelSelectedSet        := FChannelSelectedSet + [csGrayscale];
  FCurrentChannelType        := wctAlpha;

  with FSelectedAlphaChannelPanel do
  begin
    ChannelName := 'Alpha ' + IntToStr(FAlphaChannelNumber);

    // connect events
    ConnectChannelEyeClickEvent(ChannelEyeClick);
    ConnectChannelPanelMouseDownEvent(ChannelPanelMouseDown);
    ConnectChannelImageMouseDownEvent(ChannelImageMouseDown);
    ConnectChannelPanelDblClickEvent(AlphaChannelPanelDblClick);
  end;

  if FAllowRefreshChannelPanels then
  begin
    HideAllChannelPanels;
    ShowAllChannelPanels;
  end;

  if Assigned(FAssociatedLayerPanel) then
  begin
    FAssociatedLayerPanel.UpdateLayerPanelState;
  end;

  if Assigned(OnChannelChanged) then
  begin
    OnChannelChanged(True);
  end;
end;

// add a new alpha channel but don't active it
procedure TgmChannelManager.AddInativeAlphaChannel(const AOwner: TWinControl;
  const ALayerCollection: TLayerCollection;
  const ALayerPanelList: TgmLayerPanelList);
var
  LIndex            : Integer;
  LAlphaChannelPanel: TgmAlphaChannelPanel;
begin
  LIndex := ALayerPanelList.Count + FAlphaChannelPanelList.Count + 1;

  LAlphaChannelPanel := TgmAlphaChannelPanel.Create(
    AOwner,
    ALayerCollection,
    LIndex,
    FChannelPreviewLayer.Bitmap.Width,
    FChannelPreviewLayer.Bitmap.Height,
    FChannelPreviewLayer.Location,
    FGlobalMaskColor);


  LAlphaChannelPanel.IsSelected       := False;
  LAlphaChannelPanel.IsChannelVisible := False;
  
  FAlphaChannelPanelList.Add(LAlphaChannelPanel);
  Inc(FAlphaChannelNumber);

  with LAlphaChannelPanel do
  begin
    ChannelName := 'Alpha ' + IntToStr(FAlphaChannelNumber);

    // connect events
    ConnectChannelEyeClickEvent(ChannelEyeClick);
    ConnectChannelPanelMouseDownEvent(ChannelPanelMouseDown);
    ConnectChannelImageMouseDownEvent(ChannelImageMouseDown);
    ConnectChannelPanelDblClickEvent(AlphaChannelPanelDblClick);
  end;

  if FAllowRefreshChannelPanels then
  begin
    HideAllChannelPanels;
    ShowAllChannelPanels;
  end;
end;

procedure TgmChannelManager.InsertNewAlphaChannel(const AOwner: TWinControl;
  const ALayerCollection: TLayerCollection; const ALayerPanelList: TgmLayerPanelList;
  const AIndex: Integer);
var
  LIndex: Integer;
begin
  if AIndex < 0 then
  begin
    Exit;
  end;

  if AIndex > (ALayerPanelList.Count + FAlphaChannelPanelList.Count + 1) then
  begin
    LIndex := ALayerPanelList.Count + FAlphaChannelPanelList.Count + 1;
  end
  else
  begin
    LIndex := ALayerPanelList.Count + AIndex + 1;
  end;

  DeselectAllChannels(HIDE_CHANNEL);

  FSelectedAlphaChannelPanel := TgmAlphaChannelPanel.Create(
    AOwner,
    ALayerCollection,
    LIndex,
    FChannelPreviewLayer.Bitmap.Width,
    FChannelPreviewLayer.Bitmap.Height,
    FChannelPreviewLayer.Location,
    FGlobalMaskColor);

  FAlphaChannelPanelList.Insert(AIndex, FSelectedAlphaChannelPanel);
  Inc(FAlphaChannelNumber);

  FSelectedAlphaChannelIndex := AIndex;
  FChannelSelectedSet        := FChannelSelectedSet + [csGrayscale];
  FCurrentChannelType        := wctAlpha;

  with FSelectedAlphaChannelPanel do
  begin
    ChannelName := 'Alpha ' + IntToStr(FAlphaChannelNumber);

    // connect events
    ConnectChannelEyeClickEvent(ChannelEyeClick);
    ConnectChannelPanelMouseDownEvent(ChannelPanelMouseDown);
    ConnectChannelImageMouseDownEvent(ChannelImageMouseDown);
    ConnectChannelPanelDblClickEvent(AlphaChannelPanelDblClick);
  end;

  if FAllowRefreshChannelPanels then
  begin
    HideAllChannelPanels;
    ShowAllChannelPanels;
  end;

  if Assigned(FAssociatedLayerPanel) then
  begin
    FAssociatedLayerPanel.UpdateLayerPanelState;
  end;

  if Assigned(FOnChannelChanged) then
  begin
    FOnChannelChanged(True);
  end;
end; 

procedure TgmChannelManager.SaveSelectionAsChannel(const AOwner: TWinControl;
  const ALayerCollection: TLayerCollection; const ALayerPanelList: TgmLayerPanelList;
  const ASelection: TgmSelection);
var
  LIndex: Integer;
begin
  if Assigned(ASelection) then
  begin
    DeselectAllChannels(HIDE_CHANNEL);

    LIndex := ALayerPanelList.Count + FAlphaChannelPanelList.Count + 1;

    FSelectedAlphaChannelPanel := TgmAlphaChannelPanel.Create(
      AOwner,
      ALayerCollection,
      LIndex,
      FChannelPreviewLayer.Bitmap.Width,
      FChannelPreviewLayer.Bitmap.Height,
      FChannelPreviewLayer.Location,
      FGlobalMaskColor);

    FSelectedAlphaChannelPanel.AlphaLayer.Bitmap.Draw(0, 0, ASelection.OriginalMask);

    { Don't know why the above function call will change the transparency of the
      caller, so we need the following routine to restore it to opaque. }
    ReplaceAlphaChannelWithNewValue(FSelectedAlphaChannelPanel.AlphaLayer.Bitmap, 255);

    FSelectedAlphaChannelPanel.AlphaLayer.Changed;
    FSelectedAlphaChannelPanel.UpdateThumbnail;

    FAlphaChannelPanelList.Add(FSelectedAlphaChannelPanel);
    Inc(FAlphaChannelNumber);

    FSelectedAlphaChannelIndex := FAlphaChannelPanelList.Count - 1;
    FChannelSelectedSet        := FChannelSelectedSet + [csGrayscale];
    FCurrentChannelType        := wctAlpha;

    with FSelectedAlphaChannelPanel do
    begin
      ChannelName := 'Alpha ' + IntToStr(FAlphaChannelNumber);

      // connect events
      ConnectChannelEyeClickEvent(ChannelEyeClick);
      ConnectChannelPanelMouseDownEvent(ChannelPanelMouseDown);
      ConnectChannelImageMouseDownEvent(ChannelImageMouseDown);
      ConnectChannelPanelDblClickEvent(AlphaChannelPanelDblClick);
    end;

    if FAllowRefreshChannelPanels then
    begin
      HideAllChannelPanels;
      ShowAllChannelPanels;
    end;

    if Assigned(FAssociatedLayerPanel) then
    begin
      FAssociatedLayerPanel.UpdateLayerPanelState;
    end;
  end;
end; 

procedure TgmChannelManager.CreateQuickMask(const AOwner: TWinControl;
  const ALayerCollection: TLayerCollection; const ALayerPanelList: TgmLayerPanelList;
  const ASelection: TgmSelection);
var
  LIndex: Integer;
begin
  DeselectAllChannels(DONT_HIDE_CHANNEL);

  LIndex := ALayerPanelList.Count + FAlphaChannelPanelList.Count + 1;

  FQuickMaskPanel := TgmQuickMaskPanel.Create(AOwner,
                                              ALayerCollection,
                                              LIndex,
                                              FChannelPreviewLayer.Bitmap.Width,
                                              FChannelPreviewLayer.Bitmap.Height,
                                              FChannelPreviewLayer.Location,
                                              FQuickMaskColor);

  with FQuickMaskPanel do
  begin
    MaskColorType := mctColor;

    if Assigned(FLayerMaskPanel) and (FLayerMaskPanel.IsChannelVisible) then
    begin
      FLayerMaskPanel.MaskColorType := mctColor;
    end;

    ChangeMaskColorTypeForVisibleAlphaChannels(mctColor);

    if Assigned(ASelection) then
    begin
      AlphaLayer.Bitmap.Draw(0, 0, ASelection.OriginalMask);
    end
    else
    begin
      AlphaLayer.Bitmap.Clear(clWhite32);
    end;

    MaskColorIndicator := FQuickMaskColorIndicator;
    MaskOpacityPercent := FQuickMaskOpacityPercent;
    AlphaLayer.Changed;
    UpdateThumbnail;

    // connect events
    ConnectChannelEyeClickEvent(ChannelEyeClick);
    ConnectChannelPanelMouseDownEvent(QuickMaskPanelMouseDown);
    ConnectChannelImageMouseDownEvent(QuickMaskImageMouseDown);
    ConnectChannelPanelDblClickEvent(QuickMaskDblClick);
  end;

  FCurrentChannelType := wctQuickMask;
  FChannelSelectedSet := FChannelSelectedSet + [csGrayscale];

  if FAllowRefreshChannelPanels then
  begin
    HideAllChannelPanels;
    ShowAllChannelPanels;
  end;

  if Assigned(FAssociatedLayerPanel) then
  begin
    FAssociatedLayerPanel.UpdateLayerPanelState;
  end;
end;

procedure TgmChannelManager.CreateLayerMaskPanel(const AOwner: TWinControl;
  const ALayerCollection: TLayerCollection; const ALayerPanelList: TgmLayerPanelList);
var
  LLayerPanel: TgmLayerPanel;
  LIndex     : Integer;
begin
  LLayerPanel := TgmLayerPanel(ALayerPanelList.Items[ALayerPanelList.CurrentIndex]);

  LIndex := ALayerPanelList.Count + 1;

  if Assigned(FLayerMaskPanel) then
  begin
    FreeAndNil(FLayerMaskPanel);
  end;

  FLayerMaskPanel := TgmLayerMaskPanel.Create(AOwner,
                                              ALayerCollection,
                                              LIndex,
                                              FChannelPreviewLayer.Bitmap.Width,
                                              FChannelPreviewLayer.Bitmap.Height,
                                              FChannelPreviewLayer.Location,
                                              FLayerMaskColor,
                                              LLayerPanel.LayerName.Caption);

  with FLayerMaskPanel do
  begin
    if (GetVisibleColorChannelCount > 0) or
       (GetVisibleAlphaChannelCount > 0) or
       (Assigned(FQuickMaskPanel) and
       (FQuickMaskPanel.IsChannelVisible)) then
    begin
      MaskColorType := mctColor;
    end
    else
    begin
      MaskColorType := mctGrayscale;
    end;

    if not Assigned(FQuickMaskPanel) then
    begin
      case LLayerPanel.LayerProcessStage of
        lpsLayer:
          begin
            DeselectAllChannels(HIDE_CHANNEL);
            SelectAllColorChannels;
          end;

        lpsMask:
          begin
            DeselectAllChannels(DONT_HIDE_CHANNEL);
            IsSelected := True;
          end;
      end;
    end;

    FLayerMaskPanel.IsChannelVisible := False;
    MaskColorType                    := mctColor;

    AlphaLayer.Bitmap.Draw(0, 0, LLayerPanel.FMaskImage.Bitmap);
    MaskOpacityPercent := FLayerMaskOpacityPercent;
    AlphaLayer.Changed;
    UpdateThumbnail;

    // connect events
    ConnectChannelEyeClickEvent(ChannelEyeClick);
    ConnectChannelPanelMouseDownEvent(LayerMaskPanelMouseDown);
    ConnectChannelImageMouseDownEvent(LayerMaskImageMouseDown);
    ConnectChannelPanelDblClickEvent(LayerMaskDblClick);
  end;

  FCurrentChannelType := wctLayerMask;
  FChannelSelectedSet := FChannelSelectedSet + [csGrayscale];

  if FAllowRefreshChannelPanels then
  begin
    HideAllChannelPanels;
    ShowAllChannelPanels;
  end;

  if Assigned(FAssociatedLayerPanel) then
  begin
    FAssociatedLayerPanel.UpdateLayerPanelState;
  end;

  if Assigned(FOnChannelChanged) then
  begin
    FOnChannelChanged(False);
  end;
end; 

procedure TgmChannelManager.DeleteChannelPreviewLayer;
begin
  if Assigned(FChannelPreviewLayer) then
  begin
    FreeAndNil(FChannelPreviewLayer);
  end;
end;

procedure TgmChannelManager.DeleteSelectedAlphaChannels;
var
  i          : Integer;
  LAlphaPanel: TgmAlphaChannelPanel;
begin
  if FAlphaChannelPanelList.Count > 0 then
  begin
    HideAllChannelPanels;

    for i := (FAlphaChannelPanelList.Count - 1) downto 0 do
    begin
      LAlphaPanel := TgmAlphaChannelPanel(FAlphaChannelPanelList.Items[i]);

      if LAlphaPanel.IsSelected then
      begin
        FreeAndNil(LAlphaPanel);
        FAlphaChannelPanelList.Delete(i);
      end;
    end;

    if Self.FAllowRefreshChannelPanels then
    begin
      SelectAllColorChannels;
      ShowAllChannelPanels;
    end;

    FChannelPreviewLayer.Changed;

    if Assigned(FAssociatedLayerPanel) then
    begin
      FAssociatedLayerPanel.UpdateLayerPanelState;
    end;
  end;
end;

procedure TgmChannelManager.DeleteAllAlphaChannelPanels;
var
  i          : Integer;
  LAlphaPanel: TgmAlphaChannelPanel;
begin
  if FAlphaChannelPanelList.Count > 0 then
  begin
    for i := (FAlphaChannelPanelList.Count - 1) downto 0 do
    begin
      LAlphaPanel := TgmAlphaChannelPanel(FAlphaChannelPanelList.Items[i]);
      LAlphaPanel.Free;
    end;

    FAlphaChannelPanelList.Clear;
  end;
end; 

procedure TgmChannelManager.DeleteAlphaChannelByIndex(const AIndex: Integer);
var
  LAlphaPanel: TgmAlphaChannelPanel;
begin
  if FAlphaChannelPanelList.Count > 0 then
  begin
    if (AIndex >= 0) and (AIndex < FAlphaChannelPanelList.Count) then
    begin
      LAlphaPanel := TgmAlphaChannelPanel(FAlphaChannelPanelList.Items[AIndex]);

      FreeAndNil(LAlphaPanel);
      FAlphaChannelPanelList.Delete(AIndex);
    end;
  end;
end;

procedure TgmChannelManager.DeleteRightClickAlphaChannel;
var
  i          : Integer;
  LAlphaPanel: TgmAlphaChannelPanel;
begin
  if (FAlphaChannelPanelList.Count > 0) and Assigned(FClickSender) then
  begin
    for i := 0 to (FAlphaChannelPanelList.Count - 1) do
    begin
      LAlphaPanel := TgmAlphaChannelPanel(FAlphaChannelPanelList.Items[i]);

      if LAlphaPanel.IfClickOnPanel(FClickSender) then
      begin
        DeleteAlphaChannelByIndex(i);

        if Assigned(FQuickMaskPanel) then
        begin
          SelectQuickMask;
        end
        else
        begin
          DeselectAllAlphaChannels(HIDE_CHANNEL);
          SelectAllColorChannels;
          FAssociatedLayerPanel.UpdateLayerPanelState;
        end;

        Break;
      end;
    end;
  end;
end; 

procedure TgmChannelManager.DeleteQuickMask;
begin
  if Assigned(FQuickMaskPanel) then
  begin
    HideAllChannelPanels;
    FreeAndNil(FQuickMaskPanel);

    if FCurrentChannelType = wctQuickMask then
    begin
      DeselectAllChannels(HIDE_CHANNEL);

      if FAssociatedLayerPanel.LayerFeature in [
           lfBackground, lfTransparent, lfFigure, lfShapeRegion,
           lfRichText] then
      begin
        SelectAllColorChannels;
      end
      else
      begin
        if FAssociatedLayerPanel.IsHasMask then
        begin
          SelectLayerMask;
        end
        else
        begin
          SelectAllColorChannels;
        end;
      end;
    end;

    if FAllowRefreshChannelPanels then
    begin
      ShowAllChannelPanels;
    end;

    FChannelPreviewLayer.Changed;

    if Assigned(FAssociatedLayerPanel) then
    begin
      FAssociatedLayerPanel.UpdateLayerPanelState;
    end;
  end;
end;

procedure TgmChannelManager.DeleteLayerMaskPanel;
begin
  if Assigned(FLayerMaskPanel) then
  begin
    HideAllChannelPanels;

    FreeAndNil(FLayerMaskPanel);

    DeselectAllAlphaChannels(DONT_HIDE_CHANNEL);

    if Assigned(FQuickMaskPanel) and (FQuickMaskPanel.IsSelected) then
    begin
      DeselectAllColorChannels(DONT_HIDE_CHANNEL);
      DeselectAllAlphaChannels(DONT_HIDE_CHANNEL);
    end
    else
    begin
      DeselectAllAlphaChannels(DONT_HIDE_CHANNEL);
      SelectAllColorChannels;
    end;

    if FAllowRefreshChannelPanels then
    begin
      ShowAllChannelPanels;
    end;

    FChannelPreviewLayer.Changed;

    if Assigned(FAssociatedLayerPanel) then
    begin
      FAssociatedLayerPanel.UpdateLayerPanelState;
    end;
  end;
end;

procedure TgmChannelManager.SelectLayerMask;
begin
  if Assigned(FLayerMaskPanel) then
  begin
    DeselectAllAlphaChannels(HIDE_CHANNEL);
    DeselectQuickMask(HIDE_CHANNEL);
    DeselectAllColorChannels(DONT_HIDE_CHANNEL);
    PreviewAllColorChannels;

    FCurrentChannelType        := wctLayerMask;
    FChannelSelectedSet        := FChannelSelectedSet + [csGrayscale];
    FLayerMaskPanel.IsSelected := True;

    FLayerMaskPanel.AlphaLayer.Changed;

    if FAssociatedLayerPanel.LayerProcessStage <> lpsMask then
    begin
      FAssociatedLayerPanel.LayerProcessStage := lpsMask;
    end;

    FAssociatedLayerPanel.UpdateLayerPanelState;

    if Assigned(FOnChannelChanged) then
    begin
      FOnChannelChanged(True);
    end;

    // calling callback function to do some further processes after color mode is changed
    if Assigned(FOnColorModeChanged) then
    begin
      FOnColorModeChanged(cmGrayscale);
    end;
  end;
end;

procedure TgmChannelManager.DuplicateRightClickChannel(const AOwner: TWinControl;
  const ALayerCollection: TLayerCollection; const ALayerPanelList: TgmLayerPanelList;
  const AChannelName: string; const AIsInverseChannel: Boolean);
var
  LIndex               : Integer;
  LChannelBmp          : TBitmap32;
  LAlphaPanel          : TgmAlphaChannelPanel;
  LIsDuplicateQuickMask: Boolean;
begin
  if Assigned(FClickSender) then
  begin
    LIsDuplicateQuickMask := ( Assigned(FQuickMaskPanel) and
                               FQuickMaskPanel.IfClickOnPanel(FClickSender) );

    LChannelBmp := TBitmap32.Create;
    try
      if not LIsDuplicateQuickMask then
      begin
        DeselectAllChannels(HIDE_CHANNEL);
      end;

      LIndex := ALayerPanelList.Count + FAlphaChannelPanelList.Count + 1;

      FSelectedAlphaChannelPanel := TgmAlphaChannelPanel.Create(
        AOwner, ALayerCollection, LIndex, FChannelPreviewLayer.Bitmap.Width,
        FChannelPreviewLayer.Bitmap.Height, FChannelPreviewLayer.Location,
        FGlobalMaskColor);

      FAlphaChannelPanelList.Add(FSelectedAlphaChannelPanel);
      Inc(FAlphaChannelNumber);

      FSelectedAlphaChannelIndex := FAlphaChannelNumber - 1;

      // red channel
      if FRedChannelPanel.IfClickOnPanel(FClickSender) then
      begin
        LChannelBmp.Assign(FRedChannelPanel.ChannelImage.Bitmap);
        LChannelBmp.ResetAlpha; // prevent the transparent pixels
      end
      else // green channel
      if FGreenChannelPanel.IfClickOnPanel(FClickSender) then
      begin
        LChannelBmp.Assign(FGreenChannelPanel.ChannelImage.Bitmap);
        LChannelBmp.ResetAlpha; // prevent the transparent pixels
      end
      else // blue channel
      if FBlueChannelPanel.IfClickOnPanel(FClickSender) then
      begin
        LChannelBmp.Assign(FBlueChannelPanel.ChannelImage.Bitmap);
        LChannelBmp.ResetAlpha; // prevent the transparent pixels
      end
      else // quick mask
      if ( Assigned(FQuickMaskPanel) and
           FQuickMaskPanel.IfClickOnPanel(FClickSender) ) then
      begin
        LChannelBmp.Assign(FQuickMaskPanel.FAlphaLayer.Bitmap);
      end
      else // layer mask
      if ( Assigned(FLayerMaskPanel) and
           FLayerMaskPanel.IfClickOnPanel(FClickSender) ) then
      begin
        LChannelBmp.Assign(FLayerMaskPanel.FAlphaLayer.Bitmap);
      end
      else // alpha channel
      begin
        if FAlphaChannelPanelList.Count > 0 then
        begin
          for LIndex := 0 to (FAlphaChannelPanelList.Count - 1) do
          begin
            LAlphaPanel := TgmAlphaChannelPanel(FAlphaChannelPanelList.Items[LIndex]);

            if LAlphaPanel.IfClickOnPanel(FClickSender) then
            begin
              LChannelBmp.Assign(LAlphaPanel.AlphaLayer.Bitmap);
              FSelectedAlphaChannelPanel.MaskColorIndicator := LAlphaPanel.MaskColorIndicator;
              FSelectedAlphaChannelPanel.MaskOpacityPercent := LAlphaPanel.MaskOpacityPercent;
              Break;
            end;
          end;
        end;
      end;

      if AIsInverseChannel then
      begin
        InvertBitmap32(LChannelBmp, [csGrayscale]);
      end;

      with FSelectedAlphaChannelPanel do
      begin
        if LIsDuplicateQuickMask then
        begin
          IsSelected       := False;
          IsChannelVisible := False;
        end
        else
        begin
          FChannelSelectedSet := FChannelSelectedSet + [csGrayscale];
          FCurrentChannelType := wctAlpha;
        end;

        AlphaLayer.Bitmap.Draw(0, 0, LChannelBmp);
        AlphaLayer.Changed;
        UpdateThumbnail;

        ChannelName := AChannelName;

        // connect events
        ConnectChannelEyeClickEvent(ChannelEyeClick);
        ConnectChannelPanelMouseDownEvent(ChannelPanelMouseDown);
        ConnectChannelImageMouseDownEvent(ChannelImageMouseDown);
        ConnectChannelPanelDblClickEvent(AlphaChannelPanelDblClick);
      end;

      if FAllowRefreshChannelPanels then
      begin
        HideAllChannelPanels;
        ShowAllChannelPanels;
      end;

      if Assigned(FAssociatedLayerPanel) then
      begin
        FAssociatedLayerPanel.UpdateLayerPanelState;
      end;

      if Assigned(FOnChannelChanged) then
      begin
        FOnChannelChanged(False);
      end;

    finally
      LChannelBmp.Free;
    end;
  end;
end;

procedure TgmChannelManager.CropChannels(const ACrop: TgmCrop;
  const ALayerLocation: TFloatRect);
var
  i                 : Integer;
  LAlphaChannelPanel: TgmAlphaChannelPanel;
begin
  if Assigned(ACrop) then
  begin
    CropChannelPreviewLayer(ACrop, ALayerLocation);

    if Assigned(FLayerMaskPanel) then
    begin
      FLayerMaskPanel.Crop(ACrop, ALayerLocation);
    end;
    
    if Assigned(FQuickMaskPanel) then
    begin
      FQuickMaskPanel.Crop(ACrop, ALayerLocation);
    end;
    
    if FAlphaChannelPanelList.Count > 0 then
    begin
      for i := 0 to (FAlphaChannelPanelList.Count - 1) do
      begin
        LAlphaChannelPanel := TgmAlphaChannelPanel(FAlphaChannelPanelList.Items[i]);
        LAlphaChannelPanel.Crop(ACrop, ALayerLocation);
      end;
    end;
  end;
end;

procedure TgmChannelManager.CropChannels(const ACropArea: TRect;
  const ALayerLocation: TFloatRect);
var
  i                 : Integer;
  LAlphaChannelPanel: TgmAlphaChannelPanel;
begin
  if (ACropArea.Left < 0) or
     (ACropArea.Top  < 0) or
     (ACropArea.Right  > FChannelPreviewLayer.Bitmap.Width) or
     (ACropArea.Bottom > FChannelPreviewLayer.Bitmap.Height) or
     (ACropArea.Right  <= ACropArea.Left) or
     (ACropArea.Bottom <= ACropArea.Top) then
  begin
    Exit;
  end;

  CropChannelPreviewLayer(ACropArea, ALayerLocation);

  if Assigned(FLayerMaskPanel) then
  begin
    FLayerMaskPanel.Crop(ACropArea, ALayerLocation);
  end;

  if Assigned(FQuickMaskPanel) then
  begin
    FQuickMaskPanel.Crop(ACropArea, ALayerLocation);
  end;

  if FAlphaChannelPanelList.Count > 0 then
  begin
    for i := 0 to (FAlphaChannelPanelList.Count - 1) do
    begin
      LAlphaChannelPanel := TgmAlphaChannelPanel(FAlphaChannelPanelList.Items[i]);
      LAlphaChannelPanel.Crop(ACropArea, ALayerLocation);
    end;
  end;
end;

procedure TgmChannelManager.ChangeChannelsSize(
  const ANewWidth, ANewHeight: Integer; const ALayerLocation: TFloatRect);
var
  i                 : Integer;
  LAlphaChannelPanel: TgmAlphaChannelPanel;
begin
  ChangeChannelPreviewLayerSize(ANewWidth, ANewHeight, ALayerLocation);

  if Assigned(FLayerMaskPanel) then
  begin
    FLayerMaskPanel.ChangeChannelSize(ANewWidth, ANewHeight, ALayerLocation);
  end;

  if Assigned(FQuickMaskPanel) then
  begin
    FQuickMaskPanel.ChangeChannelSize(ANewWidth, ANewHeight, ALayerLocation);
  end;

  if FAlphaChannelPanelList.Count > 0 then
  begin
    for i := 0 to (FAlphaChannelPanelList.Count - 1) do
    begin
      LAlphaChannelPanel := TgmAlphaChannelPanel(FAlphaChannelPanelList.Items[i]);
      LAlphaChannelPanel.ChangeChannelSize(ANewWidth, ANewHeight, ALayerLocation);
    end;
  end;
end;

procedure TgmChannelManager.ChangeChannelsCanvasSize(
  const ANewWidth, ANewHeight: Integer; const ALayerLocation: TFloatRect;
  const AAnchor: TgmAnchorDirection);
var
  i                 : Integer;
  LAlphaChannelPanel: TgmAlphaChannelPanel;
begin
  // for preview layer, change layer size and canvas size by the same method
  ChangeChannelPreviewLayerSize(ANewWidth, ANewHeight, ALayerLocation);

  if Assigned(FLayerMaskPanel) then
  begin
    FLayerMaskPanel.ChangeChannelCanvasSize(ANewWidth, ANewHeight,
      ALayerLocation, AAnchor, clWhite32);
  end;

  if Assigned(FQuickMaskPanel) then
  begin
    FQuickMaskPanel.ChangeChannelCanvasSize(ANewWidth, ANewHeight,
      ALayerLocation, AAnchor, clBlack32);
  end;

  if FAlphaChannelPanelList.Count > 0 then
  begin
    for i := 0 to (FAlphaChannelPanelList.Count - 1) do
    begin
      LAlphaChannelPanel := TgmAlphaChannelPanel(FAlphaChannelPanelList.Items[i]);
      
      LAlphaChannelPanel.ChangeChannelCanvasSize(ANewWidth, ANewHeight,
        ALayerLocation, AAnchor, clBlack32);
    end;
  end;
end;

procedure TgmChannelManager.RotateChannels(
  const ANewWidth, ANewHeight, ADeg: Integer;
  const ADirection: TgmRotateDirection;
  const ALayerLocation: TFloatRect);
var
  i                 : Integer;
  LAlphaChannelPanel: TgmAlphaChannelPanel;
begin
  // for preview layer, rotate it by the same method
  ChangeChannelPreviewLayerSize(ANewWidth, ANewHeight, ALayerLocation);

  if Assigned(FLayerMaskPanel) then
  begin
    FLayerMaskPanel.Rotate(ADeg, ADirection, ALayerLocation, clWhite32);
  end;

  if Assigned(FQuickMaskPanel) then
  begin
    FQuickMaskPanel.Rotate(ADeg, ADirection, ALayerLocation, clBlack32);
  end;

  if FAlphaChannelPanelList.Count > 0 then
  begin
    for i := 0 to (FAlphaChannelPanelList.Count - 1) do
    begin
      LAlphaChannelPanel := TgmAlphaChannelPanel(FAlphaChannelPanelList.Items[i]);
      
      LAlphaChannelPanel.Rotate(ADeg, ADirection, ALayerLocation, clBlack32);
    end;
  end;
end;

procedure TgmChannelManager.ChangeMaskColorTypeForVisibleAlphaChannels(
  const AMaskColorType: TgmMaskColorType);
var
  i          : Integer;
  LAlphaPanel: TgmAlphaChannelPanel;
begin
  if FAlphaChannelPanelList.Count > 0 then
  begin
    for i := 0 to (FAlphaChannelPanelList.Count - 1) do
    begin
      LAlphaPanel := TgmAlphaChannelPanel(FAlphaChannelPanelList.Items[i]);

      if LAlphaPanel.IsChannelVisible then
      begin
        if LAlphaPanel.MaskColorType <> AMaskColorType then
        begin
          LAlphaPanel.MaskColorType := AMaskColorType;
        end;
      end;
    end;
  end;
end; 

procedure TgmChannelManager.CropChannelPreviewLayer(const ACrop: TgmCrop;
  const ALayerLocation: TFloatRect);
var
  LNewWidth, LNewHeight: Integer;
begin
  if ACrop.IsResized then
  begin
    LNewWidth  := ACrop.ResizeW;
    LNewHeight := ACrop.ResizeH;
  end
  else
  begin
    LNewWidth  := ACrop.FCropEnd.X - ACrop.FCropStart.X;
    LNewHeight := ACrop.FCropEnd.Y - ACrop.FCropStart.Y;
  end;

  // crop the channel preview layer
  FChannelPreviewLayer.Location := ALayerLocation;
  FChannelPreviewLayer.Bitmap.SetSize(LNewWidth, LNewHeight);
  FChannelPreviewLayer.Bitmap.Clear;

  // update color channel thumbnails
  FRGBChannelPanel.ChannelImage.Bitmap.SetSize(LNewWidth, LNewHeight);
  FRedChannelPanel.ChannelImage.Bitmap.SetSize(LNewWidth, LNewHeight);
  FGreenChannelPanel.ChannelImage.Bitmap.SetSize(LNewWidth, LNewHeight);
  FBlueChannelPanel.ChannelImage.Bitmap.SetSize(LNewWidth, LNewHeight);

  // the layers must be cropped beforehand, otherwise, we couldn't get right thumbnails
  UpdateColorChannelThumbnails(FAssociatedLayerPanelList);
end;

procedure TgmChannelManager.CropChannelPreviewLayer(const ACropArea: TRect;
  const ALayerLocation: TFloatRect);
var
  LNewWidth, LNewHeight: Integer;
begin
  LNewWidth  := ACropArea.Right  - ACropArea.Left;
  LNewHeight := ACropArea.Bottom - ACropArea.Top;

  // crop the channel preview layer
  FChannelPreviewLayer.Location := ALayerLocation;
  FChannelPreviewLayer.Bitmap.SetSize(LNewWidth, LNewHeight);
  FChannelPreviewLayer.Bitmap.Clear;

  // update color channel thumbnails
  FRGBChannelPanel.ChannelImage.Bitmap.SetSize(LNewWidth, LNewHeight);
  FRedChannelPanel.ChannelImage.Bitmap.SetSize(LNewWidth, LNewHeight);
  FGreenChannelPanel.ChannelImage.Bitmap.SetSize(LNewWidth, LNewHeight);
  FBlueChannelPanel.ChannelImage.Bitmap.SetSize(LNewWidth, LNewHeight);

  // the layers must be cropped beforehand, otherwise, we couldn't get right thumbnails
  UpdateColorChannelThumbnails(FAssociatedLayerPanelList);
end; 

procedure TgmChannelManager.ChangeChannelPreviewLayerSize(
  const ANewWidth, ANewHeight: Integer; const ALayerLocation: TFloatRect);
begin
  if (ANewWidth  <> FChannelPreviewLayer.Bitmap.Width) or
     (ANewHeight <> FChannelPreviewLayer.Bitmap.Height) then
  begin
    FChannelPreviewLayer.Location := ALayerLocation;
    FChannelPreviewLayer.Bitmap.SetSize(ANewWidth, ANewHeight);
    FChannelPreviewLayer.Bitmap.Clear;

    // update color channel thumbnails
    FRGBChannelPanel.ChannelImage.Bitmap.SetSize(ANewWidth, ANewHeight);
    FRedChannelPanel.ChannelImage.Bitmap.SetSize(ANewWidth, ANewHeight);
    FGreenChannelPanel.ChannelImage.Bitmap.SetSize(ANewWidth, ANewHeight);
    FBlueChannelPanel.ChannelImage.Bitmap.SetSize(ANewWidth, ANewHeight);

    // the layers must be cropped beforehand, otherwise, we couldn't get right thumbnails
    UpdateColorChannelThumbnails(FAssociatedLayerPanelList);
  end;
end;

procedure TgmChannelManager.SetQuickMaskColor(const AValue: TColor32);
begin
  if FQuickMaskColor <> AValue then
  begin
    FQuickMaskColor := AValue;

    if Assigned(FQuickMaskPanel) then
    begin
      FQuickMaskPanel.MaskColor := FQuickMaskColor;
    end;
  end;
end;

procedure TgmChannelManager.SetQuickMaskOpacityPercent(const AValue: Single);
begin
  if FQuickMaskOpacityPercent <> AValue then
  begin
    FQuickMaskOpacityPercent := AValue;

    if Assigned(FQuickMaskPanel) then
    begin
      FQuickMaskPanel.MaskOpacityPercent := FQuickMaskOpacityPercent;
    end;
  end;
end; 

procedure TgmChannelManager.SetQuickMaskColorIndicator(
  const AValue: TgmMaskColorIndicator);
begin
  if FQuickMaskColorIndicator <> AValue then
  begin
    FQuickMaskColorIndicator := AValue;

    if Assigned(FQuickMaskPanel) then
    begin
      FQuickMaskPanel.MaskColorIndicator := FQuickMaskColorIndicator;
    end;
  end;
end;

function TgmChannelManager.GetVisibleColorChannelCount: Integer;
begin
  Result := 0;

  if FRedChannelPanel.IsChannelVisible then
  begin
    Inc(Result);
  end;

  if FGreenChannelPanel.IsChannelVisible then
  begin
    Inc(Result);
  end;

  if FBlueChannelPanel.IsChannelVisible then
  begin
    Inc(Result);
  end;
end; 

function TgmChannelManager.GetVisibleAlphaChannelCount: Integer;
var
  i          : Integer;
  LAlphaPanel: TgmAlphaChannelPanel;
begin
  Result := 0;

  if FAlphaChannelPanelList.Count > 0 then
  begin
    for i := 0 to (FAlphaChannelPanelList.Count - 1) do
    begin
      LAlphaPanel := TgmAlphaChannelPanel(FAlphaChannelPanelList.Items[i]);

      if LAlphaPanel.IsChannelVisible then
      begin
        Inc(Result);
      end;
    end;
  end;
end;

function TgmChannelManager.GetSelectedColorChannelCount: Integer;
begin
  Result := 0;

  if FRedChannelPanel.IsSelected then
  begin
    Inc(Result);
  end;

  if FGreenChannelPanel.IsSelected then
  begin
    Inc(Result);
  end;

  if FBlueChannelPanel.IsSelected then
  begin
    Inc(Result);
  end;
end;

function TgmChannelManager.GetSelectedAlphaChannelCount: Integer;
var
  i          : Integer;
  LAlphaPanel: TgmAlphaChannelPanel;
begin
  Result := 0;

  if FAlphaChannelPanelList.Count > 0 then
  begin
    for i := 0 to (FAlphaChannelPanelList.Count - 1) do
    begin
      LAlphaPanel := TgmAlphaChannelPanel(FAlphaChannelPanelList.Items[i]);

      if LAlphaPanel.IsSelected then
      begin
        Inc(Result);
      end;
    end;
  end;
end;

function TgmChannelManager.GetRightClickedChannelName: string;
var
  i          : Integer;
  LAlphaPanel: TgmAlphaChannelPanel;
begin
  Result := '';
  
  if Assigned(FClickSender) then
  begin
    // red channel
    if FRedChannelPanel.IfClickOnPanel(FClickSender) then
    begin
      Result := FRedChannelPanel.ChannelName;
    end
    else
    if FGreenChannelPanel.IfClickOnPanel(FClickSender) then  // green channel
    begin
      Result := FGreenChannelPanel.ChannelName;
    end
    else
    if FBlueChannelPanel.IfClickOnPanel(FClickSender) then  // blue channel
    begin
      Result := FBlueChannelPanel.ChannelName;
    end
    else
    if ( Assigned(FQuickMaskPanel) and FQuickMaskPanel.IfClickOnPanel(FClickSender) ) then
    begin
      Result := FQuickMaskPanel.ChannelName;
    end
    else
    if( Assigned(FLayerMaskPanel) and FLayerMaskPanel.IfClickOnPanel(FClickSender) ) then
    begin
      Result := FLayerMaskPanel.ChannelName;
    end
    else // alpha channel
    begin
      if FAlphaChannelPanelList.Count > 0 then
      begin
        for i := 0 to (FAlphaChannelPanelList.Count - 1) do
        begin
          LAlphaPanel := TgmAlphaChannelPanel(FAlphaChannelPanelList.Items[i]);

          if LAlphaPanel.IfClickOnPanel(FClickSender) then
          begin
            Result := LAlphaPanel.ChannelName;
            Break;
          end;
        end;
      end;
    end;
  end;
end; 

function TgmChannelManager.GetChannelCompositeBitmap: TBitmap32;
var
  i, j, LPixelIndex: Integer;
  LAlphaPanel      : TgmAlphaChannelPanel;
  LRBit            : PColor32Entry;
  LGBit            : PColor32Entry;
  LBBit            : PColor32Entry;
  LABit            : PColor32Entry;
  LCompositeBit    : PColor32Entry;
begin
{$RANGECHECKS OFF}

  Result := TBitmap32.Create;

  Result.SetSize(FChannelPreviewLayer.Bitmap.Width,
                 FChannelPreviewLayer.Bitmap.Height);
                 
  Result.Clear(clBlack32);

  LCompositeBit := @Result.Bits[0];
  LPixelIndex   := 0;

  for i := 0 to (Result.Width * Result.Height - 1) do
  begin
    // red channel
    if csRed in FChannelSelectedSet then
    begin
      LRBit := @FRedChannelPanel.ChannelImage.Bitmap.Bits[LPixelIndex];

      if LRBit.B > LCompositeBit.B then
      begin
        LCompositeBit.ARGB := LRBit.ARGB;
      end;
    end;

    // green channel
    if csGreen in FChannelSelectedSet then
    begin
      LGBit := @FGreenChannelPanel.ChannelImage.Bitmap.Bits[LPixelIndex];

      if LGBit.B > LCompositeBit.B then
      begin
        LCompositeBit.ARGB := LGBit.ARGB;
      end;
    end;

    // blue channel
    if csBlue in FChannelSelectedSet then
    begin
      LBBit := @FBlueChannelPanel.ChannelImage.Bitmap.Bits[LPixelIndex];

      if LBBit.B > LCompositeBit.B then
      begin
        LCompositeBit.ARGB := LBBit.ARGB;
      end;
    end;

    // alpha channels
    if FAlphaChannelPanelList.Count > 0 then
    begin
      for j := 0 to (FAlphaChannelPanelList.Count - 1) do
      begin
        LAlphaPanel := TgmAlphaChannelPanel(FAlphaChannelPanelList.Items[j]);

        if LAlphaPanel.IsSelected then
        begin
          LABit := PColor32Entry(@LAlphaPanel.AlphaLayer.Bitmap.Bits[LPixelIndex]);

          if LABit.B > LCompositeBit.B then
          begin
            LCompositeBit.ARGB := LABit.ARGB;
          end;
        end;
      end;
    end;

    Inc(LCompositeBit);
    Inc(LPixelIndex);
  end;

{$RANGECHECKS ON}
end;

function TgmChannelManager.GetQuickMaskBitmap: TBitmap32;
begin
  Result := nil;

  if Assigned(FQuickMaskPanel) then
  begin
    Result := TBitmap32.Create;
    Result.Assign(FQuickMaskPanel.AlphaLayer.Bitmap);
  end;
end;

function TgmChannelManager.GetLayerMaskBitmap: TBitmap32;
begin
  Result := nil;

  if Assigned(FLayerMaskPanel) then
  begin
    Result := TBitmap32.Create;
    Result.Assign(FLayerMaskPanel.AlphaLayer.Bitmap);
  end;
end;

function TgmChannelManager.GetAlphaChannelBitmap: TBitmap32;
begin
  Result := nil;

  if Assigned(FSelectedAlphaChannelPanel) then
  begin
    Result := TBitmap32.Create;
    Result.Assign(FSelectedAlphaChannelPanel.FAlphaLayer.Bitmap);
  end;
end;

function TgmChannelManager.GetAlphaChannelPanelByIndex(
  const AIndex: Integer): TgmAlphaChannelPanel;
begin
  Result := nil;

  if FAlphaChannelPanelList.Count > 0 then
  begin
    if (AIndex >= 0) and (AIndex < FAlphaChannelPanelList.Count) then
    begin
      Result := TgmAlphaChannelPanel(FAlphaChannelPanelList.Items[AIndex]);
    end;
  end;
end;

function TgmChannelManager.GetAlphaChannelPanelByName(
  const AName: string): TgmAlphaChannelPanel;
var
  i          : Integer;
  LAlphaPanel: TgmAlphaChannelPanel;
begin
  Result := nil;

  if (FAlphaChannelPanelList.Count > 0) and (AName <> '') then
  begin
    for i := 0 to (FAlphaChannelPanelList.Count - 1) do
    begin
      LAlphaPanel := TgmAlphaChannelPanel(FAlphaChannelPanelList.Items[i]);

      if AName = LAlphaPanel.ChannelName then
      begin
        Result := LAlphaPanel;
        Break;
      end;
    end;
  end;
end;

function TgmChannelManager.IsSelectedAllColorChannels: Boolean;
begin
  Result := (csRed   in FChannelSelectedSet) and
            (csGreen in FChannelSelectedSet) and
            (csBlue  in FChannelSelectedSet);
end;

procedure TgmChannelManager.SetLocationForAllChannelLayers(
  const ALocation: TFloatRect);
var
  i          : Integer;
  LAlphaPanel: TgmAlphaChannelPanel;
begin
  if Assigned(FChannelPreviewLayer) then
  begin
    FChannelPreviewLayer.Location := ALocation;
  end;

  if Assigned(FQuickMaskPanel) then
  begin
    FQuickMaskPanel.AlphaLayer.Location := ALocation;
  end;

  if Assigned(FLayerMaskPanel) then
  begin
    FLayerMaskPanel.AlphaLayer.Location := ALocation;
  end;

  if FAlphaChannelPanelList.Count > 0 then
  begin
    for i := 0 to (FAlphaChannelPanelList.Count - 1) do
    begin
      LAlphaPanel := TgmAlphaChannelPanel(FAlphaChannelPanelList.Items[i]);
      LAlphaPanel.AlphaLayer.Location := ALocation;
    end;
  end;
end; 

// load channels from a '*.gmd' file that is already loaded in a stream
function TgmChannelManager.LoadChannelsFromStream(const AStream: TStream;
  const AFileVersion, ALoadChannelCount, ALoadChannelWidth, ALoadChannelHeight: Cardinal): Boolean;
var
  i, LChannelLayerIndex: Integer;
  LChannelPanel        : TgmAlphaChannelPanel;
  LChannelLoader       : TgmChannelLoader1;
begin
  Result := True;

  if (AFileVersion       = 0) or
     (ALoadChannelCount  = 0) or
     (ALoadChannelWidth  = 0) or
     (ALoadChannelHeight = 0) then
  begin
    Result := False;
    Exit;
  end;

  case AFileVersion of
    1, 2, 3: // same data in a .gmd file with version 1, 2, 3
      begin
        Self.DeleteAllAlphaChannelPanels;

        // load the alpha channels and quick mask (if any)
        LChannelLoader := TgmChannelLoader1.Create(AStream,
                                                   FLayerCollection,
                                                   FChannelPanelOwner);

        try
          LChannelLoader.ChannelWidth  := ALoadChannelWidth;
          LChannelLoader.ChannelHeight := ALoadChannelHeight;

          LChannelLayerIndex := FAssociatedLayerPanelList.Count + FAlphaChannelPanelList.Count + 1;

          for i := 0 to (ALoadChannelCount - 1) do
          begin
            LChannelPanel := LChannelLoader.GetChannel(LChannelLayerIndex);

            if Assigned(LChannelPanel) then
            begin
              case LChannelPanel.ChannelType of
                wctAlpha:
                  begin
                    FAlphaChannelPanelList.Add(LChannelPanel);

                    // connect events
                    with LChannelPanel do
                    begin
                      ConnectChannelEyeClickEvent(ChannelEyeClick);
                      ConnectChannelPanelMouseDownEvent(ChannelPanelMouseDown);
                      ConnectChannelImageMouseDownEvent(ChannelImageMouseDown);
                      ConnectChannelPanelDblClickEvent(AlphaChannelPanelDblClick);
                    end;
                  end;

                wctQuickMask:
                  begin
                    if Assigned(FQuickMaskPanel) then
                    begin
                      FreeAndNil(FQuickMaskPanel);
                    end;

                    FQuickMaskPanel := TgmQuickMaskPanel(LChannelPanel);

                    // connect events
                    with FQuickMaskPanel do
                    begin
                      ConnectChannelEyeClickEvent(ChannelEyeClick);
                      ConnectChannelPanelMouseDownEvent(QuickMaskPanelMouseDown);
                      ConnectChannelImageMouseDownEvent(QuickMaskImageMouseDown);
                      ConnectChannelPanelDblClickEvent(QuickMaskDblClick);
                    end;
                  end;
              end;
            end;

            Inc(LChannelLayerIndex);
          end;

        finally
          LChannelLoader.Free;
        end;
      end;

  else // not supported versions
    Result := False;
  end;
end;

// save the channels to stream for output them in '*.gmd' file later
procedure TgmChannelManager.SaveChannelsToStream(const AStream: TStream);
var
  i          : Integer;
  LAlphaPanel: TgmAlphaChannelPanel;
begin
  if Assigned(AStream) then
  begin
    // save alpha channel to stream, first
    if FAlphaChannelPanelList.Count > 0 then
    begin
      for i := 0 to (FAlphaChannelPanelList.Count - 1) do
      begin
        LAlphaPanel := TgmAlphaChannelPanel(FAlphaChannelPanelList.Items[i]);
        LAlphaPanel.SaveToStream(AStream);
      end;
    end;

    if Assigned(FQuickMaskPanel) then
    begin
      FQuickMaskPanel.SaveToStream(AStream);
    end;
  end;
end; 

end.
