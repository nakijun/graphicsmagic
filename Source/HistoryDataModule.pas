unit HistoryDataModule;

interface

uses
  SysUtils, Classes, GR32_Image, ImgList, Controls;

type
  TdmHistory = class(TDataModule)
    imglstCommand: TImageList;
    bmp32lstHistory: TBitmap32List;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmHistory: TdmHistory;

const
  DEFAULT_COMMAND_ICON_INDEX = 0;

{ Brush }
  PAINTBRUSH_COMMAND_ICON_INDEX            = 1;
  HISTORY_BRUSH_COMMAND_ICON_INDEX         = 2;
  AIR_BRUSH_COMMAND_ICON_INDEX             = 3;
  JET_GUN_COMMAND_ICON_INDEX               = 4;
  CLONE_STAMP_COMMAND_ICON_INDEX           = 5;
  PATTERN_STAMP_COMMAND_ICON_INDEX         = 6;
  BLUR_BRUSH_COMMAND_ICON_INDEX            = 7;
  SHARPEN_BRUSH_COMMAND_ICON_INDEX         = 8;
  SMUDGE_BRUSH_COMMAND_ICON_INDEX          = 9;
  DODGE_BRUSH_COMMAND_ICON_INDEX           = 10;
  BURN_BRUSH_COMMAND_ICON_INDEX            = 11;
  HIGH_HUE_BRUSH_COMMAND_ICON_INDEX        = 12;
  LOW_HUE_BRUSH_COMMAND_ICON_INDEX         = 13;
  HIGH_SATURATION_BRUSH_COMMAND_ICON_INDEX = 14;
  LOW_SATURATION_BRUSH_COMMAND_ICON_INDEX  = 15;
  HIGH_LUMINOSITY_BRUSH_COMMAND_ICON_INDEX = 16;
  LOW_LUMINOSITY_BRUSH_COMMAND_ICON_INDEX  = 17;
  BRIGHT_BRUSH_COMMAND_ICON_INDEX          = 18;
  DARK_BRUSH_COMMAND_ICON_INDEX            = 19;
  HIGH_CONTRAST_BRUSH_COMMAND_ICON_INDEX   = 20;
  LOW_CONTRAST_BRUSH_COMMAND_ICON_INDEX    = 21;

{ standard tools }
  PENCIL_COMMAND_ICON_INDEX        = 22;
  STRAIGHT_LINE_COMMAND_ICON_INDEX = 23;
  RECTANGLE_COMMAND_ICON_INDEX     = 24;
  ROUND_RECT_COMMAND_ICON_INDEX    = 25;
  ELLIPSE_COMMAND_ICON_INDEX       = 26;
  REGULAR_POLY_COMMAND_ICON_INDEX  = 27;
  BEZIER_CURVE_COMMAND_ICON_INDEX  = 28;
  POLYGON_COMMAND_ICON_INDEX       = 29;

  GRADIENT_COMMAND_ICON_INDEX      = 30;
  PAINT_BUCKET_COMMAND_ICON_INDEX  = 31;
  ERASER_COMMAND_ICON_INDEX        = 32;
  BACK_ERASER_COMMAND_ICON_INDEX   = 33;
  MAGIC_ERASER_COMMAND_ICON_INDEX  = 34;
  FILL_COMMAND_ICON_INDEX          = 35;
  MOVE_OBJECTS_COMMAND_ICON_INDEX  = 36;
  LOCK_COMMAND_ICON_INDEX          = 37;
  UNLOCK_COMMAND_ICON_INDEX        = 38;
  TYPE_TOOL_COMMAND_ICON_INDEX     = 39;

{ Selection }
  RECT_MARQUEE_COMMAND_ICON_INDEX           = 40;
  SINGLE_ROW_MARQUEE_COMMAND_ICON_INDEX     = 41;
  SINGLE_COLUMN_MARQUEE_COMMAND_ICON_INDEX  = 42;
  ROUND_RECT_MARQUEE_COMMAND_ICON_INDEX     = 43;
  ELLIPTICAL_MARQUEE_COMMAND_ICON_INDEX     = 44;
  POLY_MARQUEE_COMMAND_ICON_INDEX           = 45;
  LASSO_MARQUEE_COMMAND_ICON_INDEX          = 46;
  MAGIC_WAND_MARQUEE_COMMAND_ICON_INDEX     = 47;
  MAGNETIC_LASSO_MARQUEE_COMMAND_ICON_INDEX = 48;

{ Path Tools }
  WORK_PATH_COMMAND_ICON_INDEX = 49;

{ Crop }
  CROP_COMMAND_ICON_INDEX = 50;

implementation

{$R *.dfm}

end.
