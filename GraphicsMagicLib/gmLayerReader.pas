{ The GraphicsMagic -- an image manipulation program.
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

unit gmLayerReader;

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

interface

{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_TYPE OFF}

uses
{ Standard }
  Classes, Controls, ComCtrls,
{ Graphics32 }
  GR32_Layers,
{ GraphicsMagic }
  gmLayerAndChannel;

type
  // used to save the layers info to '.gmd' file
  TgmLayerHeaderVer1 = record
    LayerName       : string[255];
    LayerFeature    : Cardinal;  // the type of the layer
    BlendModeIndex  : Cardinal;  
    MasterAlpha     : Byte;
    Selected        : Boolean;   // if the layer is currently selected
    Visible         : Boolean;   // if the layer is visible
    LockTransparency: Boolean;   // if protected the alpha channel of each pixel on a layer
    Duplicated      : Boolean;   // if the layer is a copy of an another
    HasMask         : Boolean;   // if the layer has a mask
    MaskLinked      : Boolean;   // if the layer is linked to it's mask
  end;

//-- TgmLayerLoader ------------------------------------------------------------

  // The layer loader is used to load layers from a given .gmd file.
  // For details of saving various layers to a .gmd file, please check
  // the code out in gmLayerAndChannel.pas.

  TgmLayerLoader = class(TObject)
  protected
    FTextEditor      : TRichEdit;         // pointer to an external text editor for Rich Text Layer
    FFileStream      : TStream;           // pointer to a stream
    FLayerCollection : TLayerCollection;  // pointer to a layer collection
    FLayerPanelHolder: TWinControl;       // pointer to a layer panel holder
    FLayerWidth      : Cardinal;
    FLayerHeight     : Cardinal;
  public
    constructor Create(const AStream: TStream;
      const ALayerCollection: TLayerCollection;
      const ALayerPanelHolder: TWinControl;
      const ATextEditor: TRichEdit);

    destructor Destroy; override;

    function GetLayer: TgmLayerPanel; virtual; abstract;

    property LayerWidth : Cardinal read FLayerWidth  write FLayerWidth;
    property LayerHeight: Cardinal read FLayerHeight write FLayerHeight;
  end;

  // layer loader with version 1
  TgmLayerLoader1 = class(TgmLayerLoader)
  protected
    function GetBackgroundLayer(const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel; virtual;
    function GetTransparentLayer(const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel; virtual;
    function GetSolidColorLayer(const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel; virtual;
    function GetColorBalanceLayer(const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel; virtual;
    function GetBrightContrastLayer(const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel; virtual;
    function GetHLSLayer(const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel; virtual;
    function GetInvertLayer(const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel; virtual;
    function GetThresholdLayer(const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel; virtual;
    function GetPosterizeLayer(const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel; virtual;
    function GetLevelsLayer(const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel; virtual;
    function GetCurvesLayer(const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel; virtual;
    function GetGradientMapLayer(const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel; virtual;
    function GetGradientFillLayer(const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel; virtual;
    function GetPatternLayer(const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel; virtual;
    function GetFigureLayer(const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel; virtual;
    function GetShapeRegionLayer(const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel; virtual;
    function GetTextLayer(const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel; virtual;
  public
    function GetLayer: TgmLayerPanel; override;
  end;

  // layer loader with version 2
  TgmLayerLoader2 = class(TgmLayerLoader1)
  protected
    function GetChannelMixerLayer(const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel; virtual;
  public
    function GetLayer: TgmLayerPanel; override;
  end;

  // layer loader with version 3
  TgmLayerLoader3 = class(TgmLayerLoader2)
  protected
    function GetGradientFillLayer(const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel; override;
    function GetGradientMapLayer(const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel; override;
  public
  end;

implementation

uses
{ Standard }
  Graphics,
{ Graphics32 }
  GR32, GR32_OrdinalMaps,
{ GraphicsMagic Package Lib }
  gmGradient,
  gmGradient_rwUnversioned,  // for loading old gradient data in
  gmGradient_rwVer1,         // for loading new gradient data in
  gmGradientRender,
{ GraphicsMagic Lib }
  gmTypes,
  gmGimpHistogram,
  gmFigures,
  gmShapes,
  gmAlphaFuncs,
  gmGUIFuncs;

//-- TgmLayerLoader ------------------------------------------------------------

constructor TgmLayerLoader.Create(const AStream: TStream;
  const ALayerCollection: TLayerCollection;
  const ALayerPanelHolder: TWinControl;
  const ATextEditor: TRichEdit);
begin
  inherited Create;

  FFileStream       := AStream;
  FLayerCollection  := ALayerCollection;
  FLayerPanelHolder := ALayerPanelHolder;
  FTextEditor       := ATextEditor; // pointer to an external text editor for Rich Text Layer);
  FLayerWidth       := 0;
  FLayerHeight      := 0;
end;

destructor TgmLayerLoader.Destroy;
begin
  FFileStream       := nil;
  FLayerCollection  := nil;
  FLayerPanelHolder := nil;
  FTextEditor       := nil;

  inherited Destroy;
end;

//-- TgmLayerLoader1 -----------------------------------------------------------

function TgmLayerLoader1.GetBackgroundLayer(
  const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel;
var
  LNewLayer    : TBitmapLayer;
  i, LRowStride: Cardinal;
  LPixelBits   : PColor32;
  LByteMap     : TByteMap;
  LByteBits    : PByte;
begin
  // create image layer
  LNewLayer := TBitmapLayer.Create(FLayerCollection);

  LNewLayer.Bitmap.Width  := FLayerWidth;
  LNewLayer.Bitmap.Height := FLayerHeight;

  LPixelBits := @LNewLayer.Bitmap.Bits[0];
  LRowStride := LNewLayer.Bitmap.Width * SizeOf(TColor32);

  // load image data from stream
  for i := 0 to (FLayerHeight - 1) do
  begin
    FFileStream.Read(LPixelBits^, LRowStride);
    Inc(LPixelBits, LNewLayer.Bitmap.Width);
  end;

  LNewLayer.Scaled := True;

  Result := TgmBackgroundLayerPanel.Create(FLayerPanelHolder, LNewLayer);

  Result.LayerName.Caption  := ALayerHeader.LayerName;
  Result.BlendModeIndex     := ALayerHeader.BlendModeIndex;
  Result.LayerMasterAlpha   := ALayerHeader.MasterAlpha;
  Result.IsSelected         := ALayerHeader.Selected;
  Result.IsLayerVisible     := ALayerHeader.Visible;
  Result.IsLockTransparency := ALayerHeader.LockTransparency;
  Result.IsDuplicated       := ALayerHeader.Duplicated;
  Result.IsHasMask          := ALayerHeader.HasMask;
  Result.IsMaskLinked       := ALayerHeader.MaskLinked;

  // read in the mask data from the stream
  if Result.IsHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      LByteMap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);

      // read in mask data
      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (LNewLayer.Bitmap.Height - 1) do
      begin
        FFileStream.Read(LByteBits^, LNewLayer.Bitmap.Width);
        Inc(LByteBits, LNewLayer.Bitmap.Width);
      end;

      Result.FMaskImage.Bitmap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);
      LByteMap.WriteTo(Result.FMaskImage.Bitmap, ctUniformRGB);
      Result.UpdateMaskThumbnail;

      // read in the last alpha data of the layer
      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (LNewLayer.Bitmap.Height - 1) do
      begin
        FFileStream.Read(LByteBits^, LNewLayer.Bitmap.Width);
        Inc(LByteBits, LNewLayer.Bitmap.Width);
      end;

      Result.FLastAlphaChannelBmp.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);
      LByteMap.WriteTo(Result.FLastAlphaChannelBmp, ctUniformRGB);
    finally
      LByteMap.Free;
    end;
  end;
end;

function TgmLayerLoader1.GetTransparentLayer(
  const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel;
var
  LNewLayer    : TBitmapLayer;
  i, LRowStride: Cardinal;
  LPixelBits   : PColor32;
  LByteMap     : TByteMap;
  LByteBits    : PByte;
begin
  // create image layer
  LNewLayer := TBitmapLayer.Create(FLayerCollection);
  LNewLayer.Bitmap.SetSize(FLayerWidth, FLayerHeight);

  LPixelBits := @LNewLayer.Bitmap.Bits[0];
  LRowStride := LNewLayer.Bitmap.Width * SizeOf(TColor32);

  // load image data from stream
  for i := 0 to (FLayerHeight - 1) do
  begin
    FFileStream.Read(LPixelBits^, LRowStride);
    Inc(LPixelBits, LNewLayer.Bitmap.Width);
  end;

  LNewLayer.Scaled := True;

  Result := TgmTransparentLayerPanel.Create(FLayerPanelHolder, LNewLayer);

  Result.LayerName.Caption  := ALayerHeader.LayerName;
  Result.BlendModeIndex     := ALayerHeader.BlendModeIndex;
  Result.LayerMasterAlpha   := ALayerHeader.MasterAlpha;
  Result.IsSelected         := ALayerHeader.Selected;
  Result.IsLayerVisible     := ALayerHeader.Visible;
  Result.IsLockTransparency := ALayerHeader.LockTransparency;
  Result.IsDuplicated       := ALayerHeader.Duplicated;
  Result.IsHasMask          := ALayerHeader.HasMask;
  Result.IsMaskLinked       := ALayerHeader.MaskLinked;

  // read in the mask data from the stream
  if Result.IsHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      LByteMap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);

      // read in mask data
      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (LNewLayer.Bitmap.Height - 1) do
      begin
        FFileStream.Read(LByteBits^, LNewLayer.Bitmap.Width);
        Inc(LByteBits, LNewLayer.Bitmap.Width);
      end;

      Result.FMaskImage.Bitmap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);
      LByteMap.WriteTo(Result.FMaskImage.Bitmap, ctUniformRGB);
      Result.UpdateMaskThumbnail;

      // read in the last alpha data of the layer
      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (LNewLayer.Bitmap.Height - 1) do
      begin
        FFileStream.Read(LByteBits^, LNewLayer.Bitmap.Width);
        Inc(LByteBits, LNewLayer.Bitmap.Width);
      end;

      Result.FLastAlphaChannelBmp.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);
      LByteMap.WriteTo(Result.FLastAlphaChannelBmp, ctUniformRGB);
    finally
      LByteMap.Free;
    end;
  end;
end;

function TgmLayerLoader1.GetSolidColorLayer(
  const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel;
var
  LNewLayer    : TBitmapLayer;
  i            : Cardinal;
  LFillingColor: TColor;
  LByteMap     : TByteMap;
  LByteBits    : PByte;
begin
  // create image layer
  LNewLayer := TBitmapLayer.Create(FLayerCollection);
  LNewLayer.Bitmap.SetSize(FLayerWidth, FLayerHeight);
  LNewLayer.Scaled := True;

  // load the filling color from stream
  FFileStream.Read(LFillingColor, SizeOf(TColor));

  Result := TgmSolidColorLayerPanel.Create(FLayerPanelHolder, LNewLayer);

  Result.LayerName.Caption  := ALayerHeader.LayerName;
  Result.BlendModeIndex     := ALayerHeader.BlendModeIndex;
  Result.LayerMasterAlpha   := ALayerHeader.MasterAlpha;
  Result.IsSelected         := ALayerHeader.Selected;
  Result.IsLayerVisible     := ALayerHeader.Visible;
  Result.IsLockTransparency := ALayerHeader.LockTransparency;
  Result.IsDuplicated       := ALayerHeader.Duplicated;
  Result.IsHasMask          := ALayerHeader.HasMask;
  Result.IsMaskLinked       := ALayerHeader.MaskLinked;

  TgmSolidColorLayerPanel(Result).SolidColor := LFillingColor;

  // read in the mask data from the stream
  if Result.IsHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      LByteMap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);

      // read in mask data
      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (LNewLayer.Bitmap.Height - 1) do
      begin
        FFileStream.Read(LByteBits^, LNewLayer.Bitmap.Width);
        Inc(LByteBits, LNewLayer.Bitmap.Width);
      end;

      Result.FMaskImage.Bitmap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);
      LByteMap.WriteTo(Result.FMaskImage.Bitmap, ctUniformRGB);
      Result.UpdateMaskThumbnail;
    finally
      LByteMap.Free;
    end;

    // save the mask into the layer's alpha channel
    Result.UpdateLayerAlphaWithMask;
  end;
end;

function TgmLayerLoader1.GetColorBalanceLayer(
  const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel;
var
  LNewLayer    : TBitmapLayer;
  i            : Cardinal;
  LCBLayerPanel: TgmColorBalanceLayerPanel;
  LByteMap     : TByteMap;
  LByteBits    : PByte;
  LBooleanValue: Boolean;
begin
  // create image layer
  LNewLayer := TBitmapLayer.Create(FLayerCollection);
  LNewLayer.Bitmap.SetSize(FLayerWidth, FLayerHeight);
  LNewLayer.Scaled := True;

  Result := TgmColorBalanceLayerPanel.Create(FLayerPanelHolder, LNewLayer);

  Result.LayerName.Caption  := ALayerHeader.LayerName;
  Result.BlendModeIndex     := ALayerHeader.BlendModeIndex;
  Result.LayerMasterAlpha   := ALayerHeader.MasterAlpha;
  Result.IsSelected         := ALayerHeader.Selected;
  Result.IsLayerVisible     := ALayerHeader.Visible;
  Result.IsLockTransparency := ALayerHeader.LockTransparency;
  Result.IsDuplicated       := ALayerHeader.Duplicated;
  Result.IsHasMask          := ALayerHeader.HasMask;
  Result.IsMaskLinked       := ALayerHeader.MaskLinked;

  // set up the color balance layer, load settings from stream
  LCBLayerPanel := TgmColorBalanceLayerPanel(Result);
  LCBLayerPanel.ColorBalance.LoadFromStream(FFileStream);

  FFileStream.Read(LBooleanValue, 1);
  LCBLayerPanel.IsPreview := LBooleanValue;
  
  LCBLayerPanel.SaveLastAdjustment;

  // read in the mask data from the stream
  if Result.IsHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      LByteMap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);

      // read in mask data
      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (LNewLayer.Bitmap.Height - 1) do
      begin
        FFileStream.Read(LByteBits^, LNewLayer.Bitmap.Width);
        Inc(LByteBits, LNewLayer.Bitmap.Width);
      end;

      Result.FMaskImage.Bitmap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);
      LByteMap.WriteTo(Result.FMaskImage.Bitmap, ctUniformRGB);
      Result.UpdateMaskThumbnail;
    finally
      LByteMap.Free;
    end;

    // save the mask into the layer's alpha channel
    Result.UpdateLayerAlphaWithMask;
  end;
end; 

function TgmLayerLoader1.GetBrightContrastLayer(
  const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel;
var
  LNewLayer    : TBitmapLayer;
  i            : Cardinal;
  LBCLayerPanel: TgmBrightContrastLayerPanel;
  LByteMap     : TByteMap;
  LByteBits    : PByte;
  LIntegerValue: Integer;
  LBooleanValue: Boolean;
begin
  // create image layer
  LNewLayer := TBitmapLayer.Create(FLayerCollection);
  LNewLayer.Bitmap.SetSize(FLayerWidth, FLayerHeight);
  LNewLayer.Scaled := True;

  Result := TgmBrightContrastLayerPanel.Create(FLayerPanelHolder, LNewLayer);

  Result.LayerName.Caption  := ALayerHeader.LayerName;
  Result.BlendModeIndex     := ALayerHeader.BlendModeIndex;
  Result.LayerMasterAlpha   := ALayerHeader.MasterAlpha;
  Result.IsSelected         := ALayerHeader.Selected;
  Result.IsLayerVisible     := ALayerHeader.Visible;
  Result.IsLockTransparency := ALayerHeader.LockTransparency;
  Result.IsDuplicated       := ALayerHeader.Duplicated;
  Result.IsHasMask          := ALayerHeader.HasMask;
  Result.IsMaskLinked       := ALayerHeader.MaskLinked;

  // set up the bright/contrast layer, load settings from stream
  LBCLayerPanel := TgmBrightContrastLayerPanel(Result);

  FFileStream.Read(LIntegerValue, 4);
  LBCLayerPanel.AdjustBrightness := LIntegerValue;

  FFileStream.Read(LIntegerValue, 4);
  LBCLayerPanel.AdjustContrast := LIntegerValue;

  FFileStream.Read(LBooleanValue, 1);
  LBCLayerPanel.IsPreview := LBooleanValue;

  LBCLayerPanel.SaveLastAdjustment;

  // read in the mask data from the stream
  if Result.IsHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      LByteMap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);

      // read in mask data
      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (LNewLayer.Bitmap.Height - 1) do
      begin
        FFileStream.Read(LByteBits^, LNewLayer.Bitmap.Width);
        Inc(LByteBits, LNewLayer.Bitmap.Width);
      end;

      Result.FMaskImage.Bitmap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);
      LByteMap.WriteTo(Result.FMaskImage.Bitmap, ctUniformRGB);
      Result.UpdateMaskThumbnail;
    finally
      LByteMap.Free;
    end;

    // save the mask into the layer's alpha channel
    Result.UpdateLayerAlphaWithMask;
  end;
end;

function TgmLayerLoader1.GetHLSLayer(
  const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel;
var
  LNewLayer               : TBitmapLayer;
  i, LMode                : Cardinal;
  LHueSaturationLayerPanel: TgmHueSaturationLayerPanel;
  LByteMap                : TByteMap;
  LByteBits               : PByte;
  LIntegerValue           : Integer;
  LBooleanValue           : Boolean;
begin
  // create image layer
  LNewLayer := TBitmapLayer.Create(FLayerCollection);
  LNewLayer.Bitmap.SetSize(FLayerWidth, FLayerHeight);
  LNewLayer.Scaled := True;

  Result := TgmHueSaturationLayerPanel.Create(FLayerPanelHolder, LNewLayer);

  Result.LayerName.Caption  := ALayerHeader.LayerName;
  Result.BlendModeIndex     := ALayerHeader.BlendModeIndex;
  Result.LayerMasterAlpha   := ALayerHeader.MasterAlpha;
  Result.IsSelected         := ALayerHeader.Selected;
  Result.IsLayerVisible     := ALayerHeader.Visible;
  Result.IsLockTransparency := ALayerHeader.LockTransparency;
  Result.IsDuplicated       := ALayerHeader.Duplicated;
  Result.IsHasMask          := ALayerHeader.HasMask;
  Result.IsMaskLinked       := ALayerHeader.MaskLinked;

  // set up the Hue Saturation layer, load settings from stream
  LHueSaturationLayerPanel := TgmHueSaturationLayerPanel(Result);

  FFileStream.Read(LIntegerValue, 4);
  LHueSaturationLayerPanel.ChangedH := LIntegerValue;

  FFileStream.Read(LIntegerValue, 4);
  LHueSaturationLayerPanel.ChangedLOrV := LIntegerValue;

  FFileStream.Read(LIntegerValue, 4);
  LHueSaturationLayerPanel.ChangedS := LIntegerValue;

  FFileStream.Read(LMode, 4);
  LHueSaturationLayerPanel.AdjustMode := TgmHueSaturationAdjustMode(LMode);

  FFileStream.Read(LBooleanValue, 1);
  LHueSaturationLayerPanel.IsPreview := LBooleanValue;

  LHueSaturationLayerPanel.SaveLastAdjustment;

  // read in the mask data from the stream
  if Result.IsHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      LByteMap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);

      // read in mask data
      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (LNewLayer.Bitmap.Height - 1) do
      begin
        FFileStream.Read(LByteBits^, LNewLayer.Bitmap.Width);
        Inc(LByteBits, LNewLayer.Bitmap.Width);
      end;

      Result.FMaskImage.Bitmap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);
      LByteMap.WriteTo(Result.FMaskImage.Bitmap, ctUniformRGB);
      Result.UpdateMaskThumbnail;
    finally
      LByteMap.Free;
    end;

    // save the mask into the layer's alpha channel
    Result.UpdateLayerAlphaWithMask;
  end;
end;

function TgmLayerLoader1.GetInvertLayer(
  const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel;
var
  LNewLayer: TBitmapLayer;
  i        : Cardinal;
  LByteMap : TByteMap;
  LByteBits: PByte;
begin
  // create image layer
  LNewLayer := TBitmapLayer.Create(FLayerCollection);
  LNewLayer.Bitmap.SetSize(FLayerWidth, FLayerHeight);
  LNewLayer.Scaled := True;

  Result := TgmInvertLayerPanel.Create(FLayerPanelHolder, LNewLayer);

  Result.LayerName.Caption  := ALayerHeader.LayerName;
  Result.BlendModeIndex     := ALayerHeader.BlendModeIndex;
  Result.LayerMasterAlpha   := ALayerHeader.MasterAlpha;
  Result.IsSelected         := ALayerHeader.Selected;
  Result.IsLayerVisible     := ALayerHeader.Visible;
  Result.IsLockTransparency := ALayerHeader.LockTransparency;
  Result.IsDuplicated       := ALayerHeader.Duplicated;
  Result.IsHasMask          := ALayerHeader.HasMask;
  Result.IsMaskLinked       := ALayerHeader.MaskLinked;

  // read in the mask data from the stream
  if Result.IsHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      LByteMap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);

      // read in mask data
      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (LNewLayer.Bitmap.Height - 1) do
      begin
        FFileStream.Read(LByteBits^, LNewLayer.Bitmap.Width);
        Inc(LByteBits, LNewLayer.Bitmap.Width);
      end;

      Result.FMaskImage.Bitmap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);
      LByteMap.WriteTo(Result.FMaskImage.Bitmap, ctUniformRGB);
      Result.UpdateMaskThumbnail;
    finally
      LByteMap.Free;
    end;

    // save the mask into the layer's alpha channel
    Result.UpdateLayerAlphaWithMask;
  end;
end;

function TgmLayerLoader1.GetThresholdLayer(
  const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel;
var
  LNewLayer           : TBitmapLayer;
  i                   : Cardinal;
  LThresholdLayerPanel: TgmThresholdLayerPanel;
  LByteMap            : TByteMap;
  LByteBits           : PByte;
  LByteValue          : Byte;
  LBooleanValue       : Boolean;
begin
  // create image layer
  LNewLayer := TBitmapLayer.Create(FLayerCollection);
  LNewLayer.Bitmap.SetSize(FLayerWidth, FLayerHeight);
  LNewLayer.Scaled := True;

  Result := TgmThresholdLayerPanel.Create(FLayerPanelHolder, LNewLayer);

  Result.LayerName.Caption  := ALayerHeader.LayerName;
  Result.BlendModeIndex     := ALayerHeader.BlendModeIndex;
  Result.LayerMasterAlpha   := ALayerHeader.MasterAlpha;
  Result.IsSelected         := ALayerHeader.Selected;
  Result.IsLayerVisible     := ALayerHeader.Visible;
  Result.IsLockTransparency := ALayerHeader.LockTransparency;
  Result.IsDuplicated       := ALayerHeader.Duplicated;
  Result.IsHasMask          := ALayerHeader.HasMask;
  Result.IsMaskLinked       := ALayerHeader.MaskLinked;

  // set up the Threshold layer, load settings from stream
  LThresholdLayerPanel := TgmThresholdLayerPanel(Result);

  FFileStream.Read(LByteValue, 1);
  LThresholdLayerPanel.Level := LByteValue;

  FFileStream.Read(LBooleanValue, 1);
  LThresholdLayerPanel.IsPreview := LBooleanValue;

  LThresholdLayerPanel.SaveLastAdjustment;

  // read in the mask data from the stream
  if Result.IsHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      LByteMap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);

      // read in mask data
      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (LNewLayer.Bitmap.Height - 1) do
      begin
        FFileStream.Read(LByteBits^, LNewLayer.Bitmap.Width);
        Inc(LByteBits, LNewLayer.Bitmap.Width);
      end;

      Result.FMaskImage.Bitmap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);
      LByteMap.WriteTo(Result.FMaskImage.Bitmap, ctUniformRGB);
      Result.UpdateMaskThumbnail;
    finally
      LByteMap.Free;
    end;

    // save the mask into the layer's alpha channel
    Result.UpdateLayerAlphaWithMask;
  end;
end;

function TgmLayerLoader1.GetPosterizeLayer(
  const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel;
var
  LNewLayer           : TBitmapLayer;
  i                   : Cardinal;
  LPosterizeLayerPanel: TgmPosterizeLayerPanel;
  LByteMap            : TByteMap;
  LByteBits           : PByte;
  LByteValue          : Byte;
  LBooleanValue       : Boolean;
begin
  // create image layer
  LNewLayer := TBitmapLayer.Create(FLayerCollection);
  LNewLayer.Bitmap.SetSize(FLayerWidth, FLayerHeight);
  LNewLayer.Scaled := True;

  Result := TgmPosterizeLayerPanel.Create(FLayerPanelHolder, LNewLayer);

  Result.LayerName.Caption  := ALayerHeader.LayerName;
  Result.BlendModeIndex     := ALayerHeader.BlendModeIndex;
  Result.LayerMasterAlpha   := ALayerHeader.MasterAlpha;
  Result.IsSelected         := ALayerHeader.Selected;
  Result.IsLayerVisible     := ALayerHeader.Visible;
  Result.IsLockTransparency := ALayerHeader.LockTransparency;
  Result.IsDuplicated       := ALayerHeader.Duplicated;
  Result.IsHasMask          := ALayerHeader.HasMask;
  Result.IsMaskLinked       := ALayerHeader.MaskLinked;

  // set up the Posterize layer, load settings from stream
  LPosterizeLayerPanel := TgmPosterizeLayerPanel(Result);

  FFileStream.Read(LByteValue, 1);
  LPosterizeLayerPanel.Level := LByteValue;

  FFileStream.Read(LBooleanValue, 1);
  LPosterizeLayerPanel.IsPreview := LBooleanValue;

  LPosterizeLayerPanel.SaveLastAdjustment;

  // read in the mask data from the stream
  if Result.IsHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      LByteMap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);

      // read in mask data
      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (LNewLayer.Bitmap.Height - 1) do
      begin
        FFileStream.Read(LByteBits^, LNewLayer.Bitmap.Width);
        Inc(LByteBits, LNewLayer.Bitmap.Width);
      end;

      Result.FMaskImage.Bitmap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);
      LByteMap.WriteTo(Result.FMaskImage.Bitmap, ctUniformRGB);
      Result.UpdateMaskThumbnail;
    finally
      LByteMap.Free;
    end;

    // save the mask into the layer's alpha channel
    Result.UpdateLayerAlphaWithMask;
  end;
end;

function TgmLayerLoader1.GetLevelsLayer(
  const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel;
var
  LNewLayer        : TBitmapLayer;
  LLevelsLayerPanel: TgmLevelsLayerPanel;
  i, LScale        : Cardinal;
  LByteMap         : TByteMap;
  LByteBits        : PByte;
  LBooleanValue    : Boolean;
begin
  // create image layer
  LNewLayer := TBitmapLayer.Create(FLayerCollection);
  LNewLayer.Bitmap.SetSize(FLayerWidth, FLayerHeight);
  LNewLayer.Scaled := True;

  Result := TgmLevelsLayerPanel.Create(FLayerPanelHolder, LNewLayer);

  Result.LayerName.Caption  := ALayerHeader.LayerName;
  Result.BlendModeIndex     := ALayerHeader.BlendModeIndex;
  Result.LayerMasterAlpha   := ALayerHeader.MasterAlpha;
  Result.IsSelected         := ALayerHeader.Selected;
  Result.IsLayerVisible     := ALayerHeader.Visible;
  Result.IsLockTransparency := ALayerHeader.LockTransparency;
  Result.IsDuplicated       := ALayerHeader.Duplicated;
  Result.IsHasMask          := ALayerHeader.HasMask;
  Result.IsMaskLinked       := ALayerHeader.MaskLinked;

  // set up the levels layer, load settings from stream
  LLevelsLayerPanel := TgmLevelsLayerPanel(Result);

  // load the Levels data from stream
  LLevelsLayerPanel.LevelsTool.LoadFromStream(FFileStream);

  FFileStream.Read(LScale, 4);
  LLevelsLayerPanel.HistogramScale := TgmGimpHistogramScale(LScale);
  
  FFileStream.Read(LBooleanValue, 1);
  LLevelsLayerPanel.IsPreview := LBooleanValue;

  LLevelsLayerPanel.SaveLastAdjustment;

  // read in the mask data from the stream
  if Result.IsHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      LByteMap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);

      // read in mask data
      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (LNewLayer.Bitmap.Height - 1) do
      begin
        FFileStream.Read(LByteBits^, LNewLayer.Bitmap.Width);
        Inc(LByteBits, LNewLayer.Bitmap.Width);
      end;

      Result.FMaskImage.Bitmap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);
      LByteMap.WriteTo(Result.FMaskImage.Bitmap, ctUniformRGB);
      Result.UpdateMaskThumbnail;
    finally
      LByteMap.Free;
    end;

    // save the mask into the layer's alpha channel
    Result.UpdateLayerAlphaWithMask;
  end;
end;

function TgmLayerLoader1.GetCurvesLayer(
  const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel;
var
  LNewLayer        : TBitmapLayer;
  LCurvesLayerPanel: TgmCurvesLayerPanel;
  i                : Cardinal;
  LByteMap         : TByteMap;
  LByteBits        : PByte;
  LBooleanValue    : Boolean;
begin
  // create image layer
  LNewLayer := TBitmapLayer.Create(FLayerCollection);
  LNewLayer.Bitmap.SetSize(FLayerWidth, FLayerHeight);
  LNewLayer.Scaled := True;

  Result := TgmCurvesLayerPanel.Create(FLayerPanelHolder, LNewLayer);

  Result.LayerName.Caption  := ALayerHeader.LayerName;
  Result.BlendModeIndex     := ALayerHeader.BlendModeIndex;
  Result.LayerMasterAlpha   := ALayerHeader.MasterAlpha;
  Result.IsSelected         := ALayerHeader.Selected;
  Result.IsLayerVisible     := ALayerHeader.Visible;
  Result.IsLockTransparency := ALayerHeader.LockTransparency;
  Result.IsDuplicated       := ALayerHeader.Duplicated;
  Result.IsHasMask          := ALayerHeader.HasMask;
  Result.IsMaskLinked       := ALayerHeader.MaskLinked;

  // set up the Curves layer, load settings from stream
  LCurvesLayerPanel := TgmCurvesLayerPanel(Result);

  // load the Curves data from stream
  LCurvesLayerPanel.CurvesTool.LoadFromStream(FFileStream);

  FFileStream.Read(LBooleanValue, 1);
  LCurvesLayerPanel.IsPreview := LBooleanValue;

  LCurvesLayerPanel.SaveLastAdjustment;

  // read in the mask data from the stream
  if Result.IsHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      LByteMap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);

      // read in mask data
      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (LNewLayer.Bitmap.Height - 1) do
      begin
        FFileStream.Read(LByteBits^, LNewLayer.Bitmap.Width);
        Inc(LByteBits, LNewLayer.Bitmap.Width);
      end;

      Result.FMaskImage.Bitmap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);
      LByteMap.WriteTo(Result.FMaskImage.Bitmap, ctUniformRGB);
      Result.UpdateMaskThumbnail;
    finally
      LByteMap.Free;
    end;

    // save the mask into the layer's alpha channel
    Result.UpdateLayerAlphaWithMask;
  end;
end;

function TgmLayerLoader1.GetGradientMapLayer(
  const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel;
var
  LNewLayer             : TBitmapLayer;
  LGradientMapLayerPanel: TgmGradientMapLayerPanel;
  LLoadedGradient       : TgmGradientItem;
  i                     : Cardinal;
  LByteMap              : TByteMap;
  LByteBits             : PByte;
  LBooleanValue         : Boolean;
  LGradientReader       : TgmOldReader;
begin
  // create image layer
  LNewLayer := TBitmapLayer.Create(FLayerCollection);
  LNewLayer.Bitmap.SetSize(FLayerWidth, FLayerHeight);
  LNewLayer.Scaled := True;

  Result := TgmGradientMapLayerPanel.Create(FLayerPanelHolder, LNewLayer, nil);

  Result.LayerName.Caption  := ALayerHeader.LayerName;
  Result.BlendModeIndex     := ALayerHeader.BlendModeIndex;
  Result.LayerMasterAlpha   := ALayerHeader.MasterAlpha;
  Result.IsSelected         := ALayerHeader.Selected;
  Result.IsLayerVisible     := ALayerHeader.Visible;
  Result.IsLockTransparency := ALayerHeader.LockTransparency;
  Result.IsDuplicated       := ALayerHeader.Duplicated;
  Result.IsHasMask          := ALayerHeader.HasMask;
  Result.IsMaskLinked       := ALayerHeader.MaskLinked;

  // set up the GradientMap layer, load settings from stream
  LGradientReader := TgmOldReader.Create;
  LLoadedGradient := TgmGradientItem.Create(nil);
  try
    LGradientReader.LoadItemFromStream(FFileStream, LLoadedGradient);

    LGradientMapLayerPanel          := TgmGradientMapLayerPanel(Result);
    LGradientMapLayerPanel.Gradient := LLoadedGradient;
  finally
    LLoadedGradient.Free;
    LGradientReader.Free;
  end;

  FFileStream.Read(LBooleanValue, 1);
  LGradientMapLayerPanel.IsReversed := LBooleanValue;

  FFileStream.Read(LBooleanValue, 1);
  LGradientMapLayerPanel.IsPreview := LBooleanValue;

  LGradientMapLayerPanel.SaveLastAdjustment;

  // read in the mask data from the stream
  if Result.IsHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      LByteMap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);

      // read in mask data
      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (LNewLayer.Bitmap.Height - 1) do
      begin
        FFileStream.Read(LByteBits^, LNewLayer.Bitmap.Width);
        Inc(LByteBits, LNewLayer.Bitmap.Width);
      end;

      Result.FMaskImage.Bitmap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);
      LByteMap.WriteTo(Result.FMaskImage.Bitmap, ctUniformRGB);
      Result.UpdateMaskThumbnail;
    finally
      LByteMap.Free;
    end;

    // save the mask into the layer's alpha channel
    Result.UpdateLayerAlphaWithMask;
  end;
end; 

function TgmLayerLoader1.GetGradientFillLayer(
  const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel;
var
  LNewLayer              : TBitmapLayer;
  LGradientFillLayerPanel: TgmGradientFillLayerPanel;
  LLoadedGradient        : TgmGradientItem;
  i, LIntValue           : Integer;
  LByteMap               : TByteMap;
  LByteBits              : PByte;
  LSettings              : TgmGradientFillSettings;
  LGradientReader        : TgmOldReader;
begin
  // create image layer
  LNewLayer := TBitmapLayer.Create(FLayerCollection);
  LNewLayer.Bitmap.SetSize(FLayerWidth, FLayerHeight);
  LNewLayer.Scaled := True;

  Result := TgmGradientFillLayerPanel.Create(FLayerPanelHolder, LNewLayer, nil);

  Result.LayerName.Caption  := ALayerHeader.LayerName;
  Result.BlendModeIndex     := ALayerHeader.BlendModeIndex;
  Result.LayerMasterAlpha   := ALayerHeader.MasterAlpha;
  Result.IsSelected         := ALayerHeader.Selected;
  Result.IsLayerVisible     := ALayerHeader.Visible;
  Result.IsLockTransparency := ALayerHeader.LockTransparency;
  Result.IsDuplicated       := ALayerHeader.Duplicated;
  Result.IsHasMask          := ALayerHeader.HasMask;
  Result.IsMaskLinked       := ALayerHeader.MaskLinked;

  // set up the GradientFill layer, load settings from stream
  LGradientReader := TgmOldReader.Create;
  LLoadedGradient := TgmGradientItem.Create(nil);
  try
    LGradientReader.LoadItemFromStream(FFileStream, LLoadedGradient);

    LGradientFillLayerPanel          := TgmGradientFillLayerPanel(Result);
    LGradientFillLayerPanel.Gradient := LLoadedGradient;
  finally
    LLoadedGradient.Free;
    LGradientReader.Free;
  end;

  FFileStream.Read(LIntValue, 4);
  LSettings.Style := TgmGradientRenderMode(LIntValue);

  FFileStream.Read(LSettings.Angle, 4);
  FFileStream.Read(LSettings.Scale, SizeOf(LSettings.Scale));
  FFileStream.Read(LSettings.TranslateX, 4);
  FFileStream.Read(LSettings.TranslateY, 4);
  FFileStream.Read(LSettings.Reversed, 1);

  FFileStream.Read(LSettings.StartPoint.X, 4);
  FFileStream.Read(LSettings.StartPoint.Y, 4);
  FFileStream.Read(LSettings.EndPoint.X, 4);
  FFileStream.Read(LSettings.EndPoint.Y, 4);
  FFileStream.Read(LSettings.CenterPoint.X, 4);
  FFileStream.Read(LSettings.CenterPoint.Y, 4);

  FFileStream.Read(LSettings.OriginalCenter.X, 4);
  FFileStream.Read(LSettings.OriginalCenter.Y, 4);
  FFileStream.Read(LSettings.OriginalStart.X, 4);
  FFileStream.Read(LSettings.OriginalStart.Y, 4);
  FFileStream.Read(LSettings.OriginalEnd.X, 4);
  FFileStream.Read(LSettings.OriginalEnd.Y, 4);

  LGradientFillLayerPanel.Setup(LSettings);
  LGradientFillLayerPanel.CalculateGradientCoord;
  LGradientFillLayerPanel.DrawGradientOnLayer;

  LGradientFillLayerPanel.SaveLastAdjustment;

  // read in the mask data from the stream
  if Result.IsHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      LByteMap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);

      // read in mask data
      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (LNewLayer.Bitmap.Height - 1) do
      begin
        FFileStream.Read(LByteBits^, LNewLayer.Bitmap.Width);
        Inc(LByteBits, LNewLayer.Bitmap.Width);
      end;

      Result.FMaskImage.Bitmap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);
      LByteMap.WriteTo(Result.FMaskImage.Bitmap, ctUniformRGB);
      Result.UpdateMaskThumbnail;
    finally
      LByteMap.Free;
    end;
  end;

  LGradientFillLayerPanel.Update;
end; 

function TgmLayerLoader1.GetPatternLayer(
  const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel;
var
  LNewLayer          : TBitmapLayer;
  LPatternLayerPanel : TgmPatternLayerPanel;
  i, w, h, LRowStride: Integer;
  LLoadedPattern     : TBitmap32;
  LPixelBits         : PColor32;
  LByteMap           : TByteMap;
  LByteBits          : PByte;
  LDoubleValue       : Double;
begin
  // create image layer
  LNewLayer := TBitmapLayer.Create(FLayerCollection);
  LNewLayer.Bitmap.SetSize(FLayerWidth, FLayerHeight);
  LNewLayer.Scaled := True;

  Result := TgmPatternLayerPanel.Create(FLayerPanelHolder, LNewLayer, nil);

  Result.LayerName.Caption  := ALayerHeader.LayerName;
  Result.BlendModeIndex     := ALayerHeader.BlendModeIndex;
  Result.LayerMasterAlpha   := ALayerHeader.MasterAlpha;
  Result.IsSelected         := ALayerHeader.Selected;
  Result.IsLayerVisible     := ALayerHeader.Visible;
  Result.IsLockTransparency := ALayerHeader.LockTransparency;
  Result.IsDuplicated       := ALayerHeader.Duplicated;
  Result.IsHasMask          := ALayerHeader.HasMask;
  Result.IsMaskLinked       := ALayerHeader.MaskLinked;

  // set up the Pattern layer, load settings from stream
  LPatternLayerPanel := TgmPatternLayerPanel(Result);

  FFileStream.Read(LDoubleValue, SizeOf(LDoubleValue));
  LPatternLayerPanel.Scale := LDoubleValue;

  FFileStream.Read(w, 4);
  FFileStream.Read(h, 4);

  LLoadedPattern := TBitmap32.Create;
  try
    LLoadedPattern.SetSize(w, h);

    LRowStride := w * SizeOf(TColor32);
    LPixelBits := @LLoadedPattern.Bits[0];

    for i := 0 to (h - 1) do
    begin
      FFileStream.Read(LPixelBits^, LRowStride);
      Inc(LPixelBits, w);
    end;

    LPatternLayerPanel.SetPatternBitmap(LLoadedPattern);
  finally
    LLoadedPattern.Free;
  end;

  LPatternLayerPanel.DrawPatternLayerThumbnail;
  LPatternLayerPanel.SaveLastAdjustment;

  // read in the mask data from the stream
  if Result.IsHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      LByteMap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);

      // read in mask data
      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (LNewLayer.Bitmap.Height - 1) do
      begin
        FFileStream.Read(LByteBits^, LNewLayer.Bitmap.Width);
        Inc(LByteBits, LNewLayer.Bitmap.Width);
      end;

      Result.FMaskImage.Bitmap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);
      LByteMap.WriteTo(Result.FMaskImage.Bitmap, ctUniformRGB);
      Result.UpdateMaskThumbnail;
    finally
      LByteMap.Free;
    end;
  end;

  LPatternLayerPanel.FillPatternOnLayer;
end;

function TgmLayerLoader1.GetFigureLayer(
  const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel;
var
  LNewLayer        : TBitmapLayer;
  LFigureLayerPanel: TgmFigureLayerPanel;
  LFigureListReader: TgmFigureListReader;
  i, LRowStride    : Cardinal;
  LPixelBits       : PColor32;
  LByteMap         : TByteMap;
  LByteBits        : PByte;
begin
  // create image layer
  LNewLayer := TBitmapLayer.Create(FLayerCollection);

  LNewLayer.Bitmap.Width  := FLayerWidth;
  LNewLayer.Bitmap.Height := FLayerHeight;

  LPixelBits := @LNewLayer.Bitmap.Bits[0];
  LRowStride := LNewLayer.Bitmap.Width * SizeOf(TColor32);

  // load image data from stream
  for i := 0 to (FLayerHeight - 1) do
  begin
    FFileStream.Read(LPixelBits^, LRowStride);
    Inc(LPixelBits, LNewLayer.Bitmap.Width);
  end;

  LNewLayer.Scaled := True;

  Result := TgmFigureLayerPanel.Create(FLayerPanelHolder, LNewLayer);

  Result.LayerName.Caption  := ALayerHeader.LayerName;
  Result.BlendModeIndex     := ALayerHeader.BlendModeIndex;
  Result.LayerMasterAlpha   := ALayerHeader.MasterAlpha;
  Result.IsSelected         := ALayerHeader.Selected;
  Result.IsLayerVisible     := ALayerHeader.Visible;
  Result.IsLockTransparency := ALayerHeader.LockTransparency;
  Result.IsDuplicated       := ALayerHeader.Duplicated;
  Result.IsHasMask          := ALayerHeader.HasMask;
  Result.IsMaskLinked       := ALayerHeader.MaskLinked;

  LFigureLayerPanel := TgmFigureLayerPanel(Result);

  // read in the figure list data from stream
  LFigureListReader := TgmFigureListReader1.Create(LFigureLayerPanel.FigureList);
  try
    LFigureListReader.LoadFromStream(FFileStream);
  finally
    LFigureListReader.Free;
  end;

  // read in the pixels data of bitmap with locked figures from the stream
  if LFigureLayerPanel.FigureList.LockedFigureCount > 0 then
  begin
    LPixelBits := @LFigureLayerPanel.LockFigureBMP.Bits[0];

    for i := 0 to (LFigureLayerPanel.LockFigureBMP.Height - 1) do
    begin
      FFileStream.Read(LPixelBits^, LRowStride);
      Inc(LPixelBits, LFigureLayerPanel.LockFigureBMP.Width);
    end;
  end;

  // read in the mask data from the stream
  if Result.IsHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      LByteMap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);

      // read in mask data
      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (LNewLayer.Bitmap.Height - 1) do
      begin
        FFileStream.Read(LByteBits^, LNewLayer.Bitmap.Width);
        Inc(LByteBits, LNewLayer.Bitmap.Width);
      end;

      Result.FMaskImage.Bitmap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);
      LByteMap.WriteTo(Result.FMaskImage.Bitmap, ctUniformRGB);
      Result.UpdateMaskThumbnail;

      // read in the last alpha data of the layer
      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (LNewLayer.Bitmap.Height - 1) do
      begin
        FFileStream.Read(LByteBits^, LNewLayer.Bitmap.Width);
        Inc(LByteBits, LNewLayer.Bitmap.Width);
      end;

      Result.FLastAlphaChannelBmp.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);
      LByteMap.WriteTo(Result.FLastAlphaChannelBmp, ctUniformRGB);
    finally
      LByteMap.Free;
    end;
  end;
end;

function TgmLayerLoader1.GetShapeRegionLayer(
  const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel;
var
  LNewLayer         : TBitmapLayer;
  i, LIntValue      : Integer;
  LRegionLayerPanel : TgmShapeRegionLayerPanel;
  LOutlineListReader: TgmOutlineListReader;
  LByteMap          : TByteMap;
  LByteBits         : PByte;
  LColorValue       : TColor;
  LBooleanValue     : Boolean;
begin
  // create image layer
  LNewLayer := TBitmapLayer.Create(FLayerCollection);
  LNewLayer.Bitmap.SetSize(FLayerWidth, FLayerHeight);
  LNewLayer.Scaled := True;

  Result := TgmShapeRegionLayerPanel.Create(FLayerPanelHolder, LNewLayer);

  Result.LayerName.Caption  := ALayerHeader.LayerName;
  Result.BlendModeIndex     := ALayerHeader.BlendModeIndex;
  Result.LayerMasterAlpha   := ALayerHeader.MasterAlpha;
  Result.IsSelected         := ALayerHeader.Selected;
  Result.IsLayerVisible     := ALayerHeader.Visible;
  Result.IsLockTransparency := ALayerHeader.LockTransparency;
  Result.IsDuplicated       := ALayerHeader.Duplicated;
  Result.IsHasMask          := ALayerHeader.HasMask;
  Result.IsMaskLinked       := ALayerHeader.MaskLinked;

  // set up the shape region layer, load settings from stream
  LRegionLayerPanel := TgmShapeRegionLayerPanel(Result);

  // read color
  FFileStream.Read(LColorValue, 4);
  LRegionLayerPanel.RegionColor := LColorValue;
  
  LRegionLayerPanel.DrawPhotoshopStyleColorThumbnail(LRegionLayerPanel.RegionColor);
  LRegionLayerPanel.ShapeRegion.RegionColor := LRegionLayerPanel.RegionColor;

  // read brush style
  FFileStream.Read(LIntValue, 4);
  LRegionLayerPanel.BrushStyle             := TBrushStyle(LIntValue);
  LRegionLayerPanel.ShapeRegion.BrushStyle := LRegionLayerPanel.BrushStyle;

  FFileStream.Read(LBooleanValue, 1);
  LRegionLayerPanel.IsDismissed := LBooleanValue;

  // read the outlines
  LOutlineListReader := TgmOutlineListReader1.Create(LRegionLayerPanel.ShapeOutlineList);
  try
    LOutlineListReader.LoadFromStream(FFileStream);
  finally
    LOutlineListReader.Free;
  end;

  LRegionLayerPanel.ShapeRegion.AccumRGN := LRegionLayerPanel.ShapeOutlineList.GetScaledShapesRegion;

  // read in the mask data from the stream
  if Result.IsHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      LByteMap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);

      // read in mask data
      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (LNewLayer.Bitmap.Height - 1) do
      begin
        FFileStream.Read(LByteBits^, LNewLayer.Bitmap.Width);
        Inc(LByteBits, LNewLayer.Bitmap.Width);
      end;

      Result.FMaskImage.Bitmap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);
      LByteMap.WriteTo(Result.FMaskImage.Bitmap, ctUniformRGB);
      Result.UpdateMaskThumbnail;
    finally
      LByteMap.Free;
    end;
  end;

  LRegionLayerPanel.ShapeRegion.ShowRegion(LRegionLayerPanel.AssociatedLayer.Bitmap);

  GetAlphaChannelBitmap(LRegionLayerPanel.AssociatedLayer.Bitmap,
                        LRegionLayerPanel.FLastAlphaChannelBmp);

  if (LRegionLayerPanel.IsHasMask) and (LRegionLayerPanel.IsMaskLinked) then
  begin
    ChangeAlphaChannelBySubMask(LRegionLayerPanel.AssociatedLayer.Bitmap,
                                LRegionLayerPanel.FLastAlphaChannelBmp,
                                LRegionLayerPanel.FMaskImage.Bitmap);
  end;
                                   
  LRegionLayerPanel.UpdateRegionThumbnial;
end;

function TgmLayerLoader1.GetTextLayer(
  const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel;
var
  LNewLayer      : TBitmapLayer;
  i, LIntValue   : Integer;
  X, Y           : Integer;
  LStreamSize    : Int64;
  LStrValue      : string[255];
  LTextLayerPanel: TgmRichTextLayerPanel;
  LByteMap       : TByteMap;
  LByteBits      : PByte;
  LBooleanValue  : Boolean;
begin
  // create image layer
  LNewLayer := TBitmapLayer.Create(FLayerCollection);
  LNewLayer.Bitmap.SetSize(FLayerWidth, FLayerHeight);
  LNewLayer.Scaled := True;

  Result := TgmRichTextLayerPanel.Create(FLayerPanelHolder, LNewLayer, FTextEditor);

  Result.LayerName.Caption  := ALayerHeader.LayerName;
  Result.BlendModeIndex     := ALayerHeader.BlendModeIndex;
  Result.LayerMasterAlpha   := ALayerHeader.MasterAlpha;
  Result.IsSelected         := ALayerHeader.Selected;
  Result.IsLayerVisible     := ALayerHeader.Visible;
  Result.IsLockTransparency := ALayerHeader.LockTransparency;
  Result.IsDuplicated       := ALayerHeader.Duplicated;
  Result.IsHasMask          := ALayerHeader.HasMask;
  Result.IsMaskLinked       := ALayerHeader.MaskLinked;

  // set up the Text layer, load settings from stream
  LTextLayerPanel := TgmRichTextLayerPanel(Result);

  // write the text layer data to stream
  FFileStream.Read(LStrValue, SizeOf(LStrValue));
  LTextLayerPanel.TextFileName := LStrValue;

  FFileStream.Read(X, 4);
  FFileStream.Read(Y, 4);
  LTextLayerPanel.BorderStart := Point(X, Y);

  FFileStream.Read(X, 4);
  FFileStream.Read(Y, 4);
  LTextLayerPanel.BorderEnd := Point(X, Y);

  FFileStream.Read(LIntValue, 4);
  LTextLayerPanel.TextLayerState := TgmTextLayerState(LIntValue);

  FFileStream.Read(LBooleanValue, 1);
  LTextLayerPanel.IsEditState := LBooleanValue;

  FFileStream.Read(LBooleanValue, 1);
  LTextLayerPanel.IsTextChanged := LBooleanValue;

  // read in the rich text stream
  FFileStream.Read(LStreamSize, SizeOf(Int64));
  LTextLayerPanel.RichTextStream.Size := LStreamSize;

  if LStreamSize > 0 then
  begin
    LTextLayerPanel.RichTextStream.Position := 0;
    FFileStream.Read(LTextLayerPanel.RichTextStream.Memory^, LStreamSize);

    LTextLayerPanel.RichTextStream.Position := 0;
    LTextLayerPanel.SaveEdits;
  end;

  FTextEditor.Lines.LoadFromStream(LTextLayerPanel.RichTextStream);
  LTextLayerPanel.AssociatedLayer.Bitmap.Clear($00FFFFFF);

  DrawRichTextOnBitmap(LTextLayerPanel.AssociatedLayer.Bitmap,
                       LTextLayerPanel.BorderRect, FTextEditor);

  // read in the mask data from the stream
  if Result.IsHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      LByteMap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);

      // read in mask data
      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (LNewLayer.Bitmap.Height - 1) do
      begin
        FFileStream.Read(LByteBits^, LNewLayer.Bitmap.Width);
        Inc(LByteBits, LNewLayer.Bitmap.Width);
      end;

      Result.FMaskImage.Bitmap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);
      LByteMap.WriteTo(Result.FMaskImage.Bitmap, ctUniformRGB);
      Result.UpdateMaskThumbnail;
    finally
      LByteMap.Free;
    end;

    if LTextLayerPanel.IsHasMask then
    begin
      GetAlphaChannelBitmap(LTextLayerPanel.AssociatedLayer.Bitmap,
                            LTextLayerPanel.FLastAlphaChannelBmp);

      if LTextLayerPanel.IsMaskLinked then
      begin
        ChangeAlphaChannelBySubMask(LTextLayerPanel.AssociatedLayer.Bitmap,
                                    LTextLayerPanel.FLastAlphaChannelBmp,
                                    LTextLayerPanel.FMaskImage.Bitmap);
      end;
    end;
  end;
end;

function TgmLayerLoader1.GetLayer: TgmLayerPanel;
var
  LLayerHeader: TgmLayerHeaderVer1;
begin
  Result := nil;

  if Assigned(FFileStream) and
     Assigned(FLayerCollection) and
     Assigned(FLayerPanelHolder) then
  begin
    FFileStream.Read(LLayerHeader, SizeOf(TgmLayerHeaderVer1));

    case TgmLayerFeature(LLayerHeader.LayerFeature) of
      lfBackground:
        begin
          Result := GetBackgroundLayer(LLayerHeader);
        end;
        
      lfTransparent:
        begin
          Result := GetTransparentLayer(LLayerHeader);
        end;
        
      lfSolidColor:
        begin
          Result := GetSolidColorLayer(LLayerHeader);
        end;
        
      lfBrightContrast:
        begin
          Result := GetBrightContrastLayer(LLayerHeader);
        end;

      lfCurves:
        begin
          Result := GetCurvesLayer(LLayerHeader);
        end;
        
      lfLevels:
        begin
          Result := GetLevelsLayer(LLayerHeader);
        end;
        
      lfColorBalance:
        begin
          Result := GetColorBalanceLayer(LLayerHeader);
        end;
        
      lfHLSOrHSV:
        begin
          Result := GetHLSLayer(LLayerHeader);
        end;
        
      lfInvert:
        begin
          Result := GetInvertLayer(LLayerHeader);
        end;
        
      lfThreshold:
        begin
          Result := GetThresholdLayer(LLayerHeader);
        end;
        
      lfPosterize:
        begin
          Result := GetPosterizeLayer(LLayerHeader);
        end;
        
      lfPattern:
        begin
          Result := GetPatternLayer(LLayerHeader);
        end;
        
      lfFigure:
        begin
          Result := GetFigureLayer(LLayerHeader);
        end;
        
      lfGradientMap:
        begin
          Result := GetGradientMapLayer(LLayerHeader);
        end;
        
      lfGradientFill:
        begin
          Result := GetGradientFillLayer(LLayerHeader);
        end;
        
      lfShapeRegion:
        begin
          Result := GetShapeRegionLayer(LLayerHeader);
        end;
        
      lfRichText:
        begin
          Result := GetTextLayer(LLayerHeader);
        end;
    end;
  end;
end;

//-- TgmLayerLoader2 -----------------------------------------------------------

function TgmLayerLoader2.GetChannelMixerLayer(
  const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel;
var
  LNewLayer              : TBitmapLayer;
  i                      : Cardinal;
  LChannelMixerLayerPanel: TgmChannelMixerLayerPanel;
  LByteMap               : TByteMap;
  LByteBits              : PByte;
  LBooleanValue          : Boolean;
begin
  // create image layer
  LNewLayer := TBitmapLayer.Create(FLayerCollection);
  LNewLayer.Bitmap.SetSize(FLayerWidth, FLayerHeight);
  LNewLayer.Scaled := True;

  Result := TgmChannelMixerLayerPanel.Create(FLayerPanelHolder, LNewLayer);

  Result.LayerName.Caption  := ALayerHeader.LayerName;
  Result.BlendModeIndex     := ALayerHeader.BlendModeIndex;
  Result.LayerMasterAlpha   := ALayerHeader.MasterAlpha;
  Result.IsSelected         := ALayerHeader.Selected;
  Result.IsLayerVisible     := ALayerHeader.Visible;
  Result.IsLockTransparency := ALayerHeader.LockTransparency;
  Result.IsDuplicated       := ALayerHeader.Duplicated;
  Result.IsHasMask          := ALayerHeader.HasMask;
  Result.IsMaskLinked       := ALayerHeader.MaskLinked;

  // set up the channel mixer layer, load settings from stream
  LChannelMixerLayerPanel := TgmChannelMixerLayerPanel(Result);

  LChannelMixerLayerPanel.ChannelMixer.LoadFromStream(FFileStream);

  FFileStream.Read(LBooleanValue, 1);
  LChannelMixerLayerPanel.IsPreview := LBooleanValue;

  LChannelMixerLayerPanel.SaveLastAdjustment;

  // read in the mask data from the stream
  if Result.IsHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      LByteMap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);

      // read in mask data
      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (LNewLayer.Bitmap.Height - 1) do
      begin
        FFileStream.Read(LByteBits^, LNewLayer.Bitmap.Width);
        Inc(LByteBits, LNewLayer.Bitmap.Width);
      end;

      Result.FMaskImage.Bitmap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);
      LByteMap.WriteTo(Result.FMaskImage.Bitmap, ctUniformRGB);
      Result.UpdateMaskThumbnail;
    finally
      LByteMap.Free;
    end;

    // save the mask into the layer's alpha channel
    Result.UpdateLayerAlphaWithMask;
  end;
end;

function TgmLayerLoader2.GetLayer: TgmLayerPanel;
var
  LLayerHeader: TgmLayerHeaderVer1;
begin
  Result := nil;

  if Assigned(FFileStream) and
     Assigned(FLayerCollection) and
     Assigned(FLayerPanelHolder) then
  begin
    FFileStream.Read(LLayerHeader, SizeOf(TgmLayerHeaderVer1));

    case TgmLayerFeature(LLayerHeader.LayerFeature) of
      lfBackground:
        begin
          Result := GetBackgroundLayer(LLayerHeader);
        end;
        
      lfTransparent:
        begin
          Result := GetTransparentLayer(LLayerHeader);
        end;
        
      lfSolidColor:
        begin
          Result := GetSolidColorLayer(LLayerHeader);
        end;
        
      lfBrightContrast:
        begin
          Result := GetBrightContrastLayer(LLayerHeader);
        end;
        
      lfCurves:
        begin
          Result := GetCurvesLayer(LLayerHeader);
        end;
        
      lfLevels:
        begin
          Result := GetLevelsLayer(LLayerHeader);
        end;
        
      lfColorBalance:
        begin
          Result := GetColorBalanceLayer(LLayerHeader);
        end;
        
      lfHLSOrHSV:
        begin
          Result := GetHLSLayer(LLayerHeader);
        end;
        
      lfInvert:
        begin
          Result := GetInvertLayer(LLayerHeader);
        end;
        
      lfThreshold:
        begin
          Result := GetThresholdLayer(LLayerHeader);
        end;
        
      lfPosterize:
        begin
          Result := GetPosterizeLayer(LLayerHeader);
        end;
        
      lfPattern:
        begin
          Result := GetPatternLayer(LLayerHeader);
        end;
        
      lfFigure:
        begin
          Result := GetFigureLayer(LLayerHeader);
        end;
        
      lfGradientMap:
        begin
          Result := GetGradientMapLayer(LLayerHeader);
        end;
        
      lfGradientFill:
        begin
          Result := GetGradientFillLayer(LLayerHeader);
        end;
        
      lfShapeRegion:
        begin
          Result := GetShapeRegionLayer(LLayerHeader);
        end;
        
      lfRichText:
        begin
          Result := GetTextLayer(LLayerHeader);
        end;
        
      lfChannelMixer:
        begin
          Result := GetChannelMixerLayer(LLayerHeader);
        end;
    end;
  end;
end; 

{ TgmLayerLoader3 }

function TgmLayerLoader3.GetGradientFillLayer(
  const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel;
var
  LNewLayer              : TBitmapLayer;
  LGradientFillLayerPanel: TgmGradientFillLayerPanel;
  LLoadedGradient        : TgmGradientItem;
  i, LIntValue           : Integer;
  LColorValue            : TColor;
  LByteMap               : TByteMap;
  LByteBits              : PByte;
  LSettings              : TgmGradientFillSettings;
  LGradientReader        : TgmGrdVer1_Reader;
begin
  // create image layer
  LNewLayer := TBitmapLayer.Create(FLayerCollection);
  LNewLayer.Bitmap.SetSize(FLayerWidth, FLayerHeight);
  LNewLayer.Scaled := True;

  Result := TgmGradientFillLayerPanel.Create(FLayerPanelHolder, LNewLayer, nil);

  Result.LayerName.Caption  := ALayerHeader.LayerName;
  Result.BlendModeIndex     := ALayerHeader.BlendModeIndex;
  Result.LayerMasterAlpha   := ALayerHeader.MasterAlpha;
  Result.IsSelected         := ALayerHeader.Selected;
  Result.IsLayerVisible     := ALayerHeader.Visible;
  Result.IsLockTransparency := ALayerHeader.LockTransparency;
  Result.IsDuplicated       := ALayerHeader.Duplicated;
  Result.IsHasMask          := ALayerHeader.HasMask;
  Result.IsMaskLinked       := ALayerHeader.MaskLinked;

  // set up the GradientFill layer, load settings from stream
  LGradientReader := TgmGrdVer1_Reader.Create;
  LLoadedGradient := TgmGradientItem.Create(nil);
  try
    LGradientReader.LoadItemFromStream(FFileStream, LLoadedGradient);

    LGradientFillLayerPanel := TgmGradientFillLayerPanel(Result);
    LGradientFillLayerPanel.Gradient.Assign(LLoadedGradient);
  finally
    LLoadedGradient.Free;
    LGradientReader.Free;
  end;

  // read Forground/Background color for gradient
  FFileStream.Read( LColorValue, SizeOf(TColor) );
  LGradientFillLayerPanel.Gradient.ForegroundColor := LColorValue;

  FFileStream.Read( LColorValue, SizeOf(TColor) );
  LGradientFillLayerPanel.Gradient.BackgroundColor := LColorValue;

  FFileStream.Read(LIntValue, 4);
  LSettings.Style := TgmGradientRenderMode(LIntValue);

  FFileStream.Read(LSettings.Angle, 4);
  FFileStream.Read(LSettings.Scale, SizeOf(LSettings.Scale));
  FFileStream.Read(LSettings.TranslateX, 4);
  FFileStream.Read(LSettings.TranslateY, 4);
  FFileStream.Read(LSettings.Reversed, 1);

  FFileStream.Read(LSettings.StartPoint.X, 4);
  FFileStream.Read(LSettings.StartPoint.Y, 4);
  FFileStream.Read(LSettings.EndPoint.X, 4);
  FFileStream.Read(LSettings.EndPoint.Y, 4);
  FFileStream.Read(LSettings.CenterPoint.X, 4);
  FFileStream.Read(LSettings.CenterPoint.Y, 4);

  FFileStream.Read(LSettings.OriginalCenter.X, 4);
  FFileStream.Read(LSettings.OriginalCenter.Y, 4);
  FFileStream.Read(LSettings.OriginalStart.X, 4);
  FFileStream.Read(LSettings.OriginalStart.Y, 4);
  FFileStream.Read(LSettings.OriginalEnd.X, 4);
  FFileStream.Read(LSettings.OriginalEnd.Y, 4);

  LGradientFillLayerPanel.Setup(LSettings);
  LGradientFillLayerPanel.CalculateGradientCoord;
  LGradientFillLayerPanel.DrawGradientOnLayer;
  LGradientFillLayerPanel.DrawGradientFillLayerThumbnail;
  
  LGradientFillLayerPanel.SaveLastAdjustment;

  // read in the mask data from the stream
  if Result.IsHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      LByteMap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);

      // read in mask data
      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (LNewLayer.Bitmap.Height - 1) do
      begin
        FFileStream.Read(LByteBits^, LNewLayer.Bitmap.Width);
        Inc(LByteBits, LNewLayer.Bitmap.Width);
      end;

      Result.FMaskImage.Bitmap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);
      LByteMap.WriteTo(Result.FMaskImage.Bitmap, ctUniformRGB);
      Result.UpdateMaskThumbnail;
    finally
      LByteMap.Free;
    end;
  end;

  LGradientFillLayerPanel.Update;
end;

function TgmLayerLoader3.GetGradientMapLayer(
  const ALayerHeader: TgmLayerHeaderVer1): TgmLayerPanel;
var
  LNewLayer             : TBitmapLayer;
  LGradientMapLayerPanel: TgmGradientMapLayerPanel;
  LLoadedGradient       : TgmGradientItem;
  i                     : Cardinal;
  LByteMap              : TByteMap;
  LByteBits             : PByte;
  LBooleanValue         : Boolean;
  LColorValue           : TColor;
  LGradientReader       : TgmGrdVer1_Reader;
begin
  // create image layer
  LNewLayer := TBitmapLayer.Create(FLayerCollection);
  LNewLayer.Bitmap.SetSize(FLayerWidth, FLayerHeight);
  LNewLayer.Scaled := True;

  Result := TgmGradientMapLayerPanel.Create(FLayerPanelHolder, LNewLayer, nil);

  Result.LayerName.Caption  := ALayerHeader.LayerName;
  Result.BlendModeIndex     := ALayerHeader.BlendModeIndex;
  Result.LayerMasterAlpha   := ALayerHeader.MasterAlpha;
  Result.IsSelected         := ALayerHeader.Selected;
  Result.IsLayerVisible     := ALayerHeader.Visible;
  Result.IsLockTransparency := ALayerHeader.LockTransparency;
  Result.IsDuplicated       := ALayerHeader.Duplicated;
  Result.IsHasMask          := ALayerHeader.HasMask;
  Result.IsMaskLinked       := ALayerHeader.MaskLinked;

  // set up the GradientMap layer, load settings from stream
  LGradientReader := TgmGrdVer1_Reader.Create;
  LLoadedGradient := TgmGradientItem.Create(nil);
  try
    LGradientReader.LoadItemFromStream(FFileStream, LLoadedGradient);

    LGradientMapLayerPanel := TgmGradientMapLayerPanel(Result);
    LGradientMapLayerPanel.Gradient.Assign(LLoadedGradient);
  finally
    LLoadedGradient.Free;
    LGradientReader.Free;
  end;

  // read Forground/Background color for gradient
  FFileStream.Read( LColorValue, SizeOf(TColor) );
  LGradientMapLayerPanel.Gradient.ForegroundColor := LColorValue;

  FFileStream.Read( LColorValue, SizeOf(TColor) );
  LGradientMapLayerPanel.Gradient.BackgroundColor := LColorValue;

  FFileStream.Read(LBooleanValue, 1);
  LGradientMapLayerPanel.IsReversed := LBooleanValue;

  FFileStream.Read(LBooleanValue, 1);
  LGradientMapLayerPanel.IsPreview := LBooleanValue;

  LGradientMapLayerPanel.SaveLastAdjustment;

  // read in the mask data from the stream
  if Result.IsHasMask then
  begin
    LByteMap := TByteMap.Create;
    try
      LByteMap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);

      // read in mask data
      LByteBits := @LByteMap.Bits[0];
      for i := 0 to (LNewLayer.Bitmap.Height - 1) do
      begin
        FFileStream.Read(LByteBits^, LNewLayer.Bitmap.Width);
        Inc(LByteBits, LNewLayer.Bitmap.Width);
      end;

      Result.FMaskImage.Bitmap.SetSize(LNewLayer.Bitmap.Width, LNewLayer.Bitmap.Height);
      LByteMap.WriteTo(Result.FMaskImage.Bitmap, ctUniformRGB);
      Result.UpdateMaskThumbnail;
    finally
      LByteMap.Free;
    end;

    // save the mask into the layer's alpha channel
    Result.UpdateLayerAlphaWithMask;
  end;
end; 


end.
