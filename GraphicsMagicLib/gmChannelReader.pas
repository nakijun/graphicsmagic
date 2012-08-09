{ The GraphicsMagic -- an image manipulation program.
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

unit gmChannelReader;

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

uses
{ Standard }
  Classes, Controls,
{ Graphics32 }
  GR32, GR32_Layers,
{ GraphicsMagic }
  gmLayerAndChannel;

type
  TgmChannelHeaderVer1 = record
    ChannelType       : Cardinal;
    ChannelName       : string[255];
    MaskColor         : TColor32;
    MaskOpacityPercent: Single;
    MaskColorType     : Cardinal;
    MaskColorIndicator: Cardinal;
  end;

//-- TgmChannelLoader ----------------------------------------------------------

  // The channel loader is used to load channels from a given .gmd file.
  // For details of saving various channels to a .gmd file, please check
  // the code out in gmLayerAndChannel.pas.
  
  TgmChannelLoader = class(TObject)
  protected
    FFileStream        : TStream;           // pointer to a stream
    FLayerCollection   : TLayerCollection;  // pointer to a channel layer collection
    FChannelPanelHolder: TWinControl;       // pointer to a channel panel holder
    FChannelWidth      : Cardinal;
    FChannelHeight     : Cardinal;
  public
    constructor Create(const AStream: TStream;
      const ALayerCollection: TLayerCollection;
      const AChannelPanelHolder: TWinControl);

    destructor Destroy; override;

    function GetChannel(const AChannelLayerInsertIndex: Integer): TgmAlphaChannelPanel; virtual; abstract;

    property ChannelWidth : Cardinal read FChannelWidth  write FChannelWidth;
    property ChannelHeight: Cardinal read FChannelHeight write FChannelHeight;
  end;

//-- TgmChannelLoader1 ---------------------------------------------------------

  // channel loader with version 1
  TgmChannelLoader1 = class(TgmChannelLoader)
  public
    function GetChannel(const AChannelLayerInsertIndex: Integer): TgmAlphaChannelPanel; override;
  end;

implementation

uses
{ Graphics32 }
  GR32_OrdinalMaps,
{ GraphicsMagic }
  gmTypes;

//-- TgmChannelLoader ----------------------------------------------------------

constructor TgmChannelLoader.Create(const AStream: TStream;
  const ALayerCollection: TLayerCollection; const AChannelPanelHolder: TWinControl);
begin
  inherited Create;

  FFileStream         := AStream;
  FLayerCollection    := ALayerCollection;
  FChannelPanelHolder := AChannelPanelHolder;
  FChannelWidth       := 0;
  FChannelHeight      := 0;
end; 

destructor TgmChannelLoader.Destroy;
begin
  FFileStream         := nil;
  FLayerCollection    := nil;
  FChannelPanelHolder := nil;

  inherited Destroy;
end;

//-- TgmChannelLoader1 ---------------------------------------------------------

function TgmChannelLoader1.GetChannel(
  const AChannelLayerInsertIndex: Integer): TgmAlphaChannelPanel;
var
  i             : Integer;
  LChannelHeader: TgmChannelHeaderVer1;
  LByteMap      : TByteMap;
  LByteBits     : PByte;
begin
  Result := nil;

  if Assigned(FFileStream) and
     Assigned(FLayerCollection) and
     Assigned(FChannelPanelHolder) then
  begin
    FFileStream.Read(LChannelHeader, SizeOf(TgmChannelHeaderVer1));
    
    case TgmWorkingChannelType(LChannelHeader.ChannelType) of
      wctAlpha:
        begin
          Result := TgmAlphaChannelPanel.Create(FChannelPanelHolder,
                                                FLayerCollection,
                                                AChannelLayerInsertIndex,
                                                FChannelWidth, FChannelHeight,
                                                FloatRect(0, 0, 0, 0),
                                                LChannelHeader.MaskColor);
        end;

      wctQuickMask:
        begin
          Result := TgmQuickMaskPanel.Create(FChannelPanelHolder, FLayerCollection,
                                             AChannelLayerInsertIndex,
                                             FChannelWidth, FChannelHeight,
                                             FloatRect(0, 0, 0, 0),
                                             LChannelHeader.MaskColor);
        end;
    end;

    Result.ChannelName        := LChannelHeader.ChannelName;
    Result.MaskOpacityPercent := LChannelHeader.MaskOpacityPercent;
    Result.MaskColorType      := TgmMaskColorType(LChannelHeader.MaskColorType);
    Result.MaskColorIndicator := TgmMaskColorIndicator(LChannelHeader.MaskColorIndicator);

    // read in the pixels data of the channel from the stream
    LByteMap := TByteMap.Create;
    try
      LByteMap.SetSize(Result.AlphaLayer.Bitmap.Width,
                       Result.AlphaLayer.Bitmap.Height);

      // read in mask data
      LByteBits := @LByteMap.Bits[0];

      for i := 0 to (Result.AlphaLayer.Bitmap.Height - 1) do
      begin
        FFileStream.Read(LByteBits^, Result.AlphaLayer.Bitmap.Width);
        Inc(LByteBits, Result.AlphaLayer.Bitmap.Width);
      end;

      LByteMap.WriteTo(Result.AlphaLayer.Bitmap, ctUniformRGB);
      Result.UpdateThumbnail;
    finally
      LByteMap.Free;
    end;
  end;
end;

end.
