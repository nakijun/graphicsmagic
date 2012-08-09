{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

unit gmGMDFile;

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

uses
{ Standard }
  Classes,
{ GraphicsMagic }
  gmLayerAndChannel,
  gmPathPanels;

type
  TgmGMDManager = class(TObject)
  private
    FMemoryStream  : TMemoryStream;
    FOutputMsg     : string;            // output info, such as errors, etc.

    FLayerPanelList: TgmLayerPanelList; // pointer to a layer panel list for loading/saving layer data from/to a .gmd file
    FChannelManager: TgmChannelManager; // pointer to a channel manager for loading/saving channel data from/to a .gmd file
    FPathPanelList : TgmPathPanelList;  // pointer to a path panel list for loading/saving path data from/to a .gmd file
  public
    constructor Create;
    destructor Destroy; override;

    function CheckFileValidity(const AFileName: string): Boolean;

    function LoadFromFile(const AFileName: string): Boolean;
    procedure SaveToFile(const AFileName: string);

    property OuputMsg      : string            read FOutputMsg;
    property LayerPanelList: TgmLayerPanelList read FLayerPanelList write FLayerPanelList;
    property ChannelManager: TgmChannelManager read FChannelManager write FChannelManager;
    property PathPanelList : TgmPathPanelList  read FPathPanelList  write FPathPanelList;
  end;

implementation

uses
{ Standard Lib }
  SysUtils,
{ Graphics32 Lib }
  GR32;

type
  // main file header (version 1)
  TgmGMDFileHeaderVer1 = record
    FileID                       : Cardinal; // must be $474D4446
    FileVersion                  : Cardinal; // version of the file format

    { Layer Part }
    LayerCount                   : Cardinal; // indicating how many layers in the file
    TransparentLayerNumber       : Cardinal; // accumulated transparent layer number
    ColorFillLayerNumber         : Cardinal;
    ColorBalanceLayerNumber      : Cardinal;
    BrightContrastLayerNumber    : Cardinal;
    HLSLayerNumber               : Cardinal;
    InvertLayerNumber            : Cardinal;
    ThresholdLayerNumber         : Cardinal;
    PosterizeLayerNumber         : Cardinal;
    LevelsLayerNumber            : Cardinal;
    CurvesLayerNumber            : Cardinal;
    GradientMapLayerNumber       : Cardinal;
    GradientFillLayerNumber      : Cardinal;
    PatternLayerNumber           : Cardinal;
    FigureLayerNumber            : Cardinal;
    ShapeRegionLayerNumber       : Cardinal;
    LayerWidth                   : Cardinal;
    LayerHeight                  : Cardinal;

    { Channel Part }
    ChannelCount                 : Cardinal; // indicating how many alpha channels (including Quick Mask channel) in the file
    AlphaChannelNumber           : Cardinal; // accumulated alpha channel number
    GlobalChannelMaskColor       : TColor32;
    GlobalQuickMaskColor         : TColor32;
    GlobalQuickMaskOpacityPercent: Single;
    GlobalQuickMaskColorIndicator: Cardinal;
    GlobalLayerMaskColor         : TColor32;
    GlobalLayerMaskOpacityPercent: Single;

    { Path Part }
    PathPanelCount               : Cardinal; // indicating how many path panels in the file
    PathPanelNumber              : Cardinal; // accumulated path panel number
  end;

  // main file header (version 2)
  TgmGMDFileHeaderVer2 = record
    FileID                       : Cardinal; // must be $474D4446
    FileVersion                  : Cardinal; // version of the file format

    { Layer Part }
    LayerCount                   : Cardinal; // indicating how many layers in the file
    TransparentLayerNumber       : Cardinal; // accumulated transparent layer number
    ColorFillLayerNumber         : Cardinal;
    ColorBalanceLayerNumber      : Cardinal;
    BrightContrastLayerNumber    : Cardinal;
    HLSLayerNumber               : Cardinal;
    InvertLayerNumber            : Cardinal;
    ThresholdLayerNumber         : Cardinal;
    PosterizeLayerNumber         : Cardinal;
    LevelsLayerNumber            : Cardinal;
    CurvesLayerNumber            : Cardinal;
    GradientMapLayerNumber       : Cardinal;
    GradientFillLayerNumber      : Cardinal;
    PatternLayerNumber           : Cardinal;
    FigureLayerNumber            : Cardinal;
    ShapeRegionLayerNumber       : Cardinal;
    ChannelMixerLayerNumber      : Cardinal; // new
    LayerWidth                   : Cardinal;
    LayerHeight                  : Cardinal;

    { Channel Part }
    ChannelCount                 : Cardinal; // indicating how many alpha channels (including Quick Mask channel) in the file
    AlphaChannelNumber           : Cardinal; // accumulated alpha channel number
    GlobalChannelMaskColor       : TColor32;
    GlobalQuickMaskColor         : TColor32;
    GlobalQuickMaskOpacityPercent: Single;
    GlobalQuickMaskColorIndicator: Cardinal;
    GlobalLayerMaskColor         : TColor32;
    GlobalLayerMaskOpacityPercent: Single;

    { Path Part }
    PathPanelCount               : Cardinal; // indicating how many path panels in the file
    PathPanelNumber              : Cardinal; // accumulated path panel number
  end;

//-- GMD Reader ----------------------------------------------------------------

  TgmGMDReader = class(TObject)
  protected
    FFileFormatVersion: Cardinal;
    FLayerPanelList   : TgmLayerPanelList; // pointer to a layer panel list for loading/saving layer data from/to a .gmd file
    FChannelManager   : TgmChannelManager; // pointer to a channel manager for loading/saving channel data from/to a .gmd file
    FPathPanelList    : TgmPathPanelList;  // pointer to a path panel list for loading/saving path data from/to a .gmd file
  public
    constructor Create(const ALayerPanelList: TgmLayerPanelList;
                       const AChannelManager: TgmChannelManager;
                       const APathPanelList: TgmPathPanelList);

    destructor Destroy; override;

    function LoadFromStream(const AMemoryStream: TMemoryStream): Boolean; virtual; abstract ;
  end;

//-- GMD Reader 1 --------------------------------------------------------------

  // a gmd reader for loading the .gmd file with file format is version 1
  TgmGMDReader1 = class(TgmGMDReader)
  private
    FFileHeader: TgmGMDFileHeaderVer1;
  public
    constructor Create(const ALayerPanelList: TgmLayerPanelList;
                       const AChannelManager: TgmChannelManager;
                       const APathPanelList: TgmPathPanelList);

    function LoadFromStream(const AMemoryStream: TMemoryStream): Boolean; override;

    property FileHeader: TgmGMDFileHeaderVer1 read FFileHeader write FFileHeader;
  end;

//-- GMD Reader 2 --------------------------------------------------------------

  // a gmd reader for loading the .gmd file with file format is version 2
  TgmGMDReader2 = class(TgmGMDReader)
  private
    FFileHeader: TgmGMDFileHeaderVer2;
  public
    constructor Create(const ALayerPanelList: TgmLayerPanelList;
                       const AChannelManager: TgmChannelManager;
                       const APathPanelList: TgmPathPanelList);

    function LoadFromStream(const AMemoryStream: TMemoryStream): Boolean; override;

    property FileHeader: TgmGMDFileHeaderVer2 read FFileHeader write FFileHeader;
  end;

//-- GMD Reader 3 --------------------------------------------------------------
  
  // a gmd reader for loading the .gmd file with file format is version 3
  TgmGMDReader3 = class(TgmGMDReader2)
  public
    constructor Create(const ALayerPanelList: TgmLayerPanelList;
                       const AChannelManager: TgmChannelManager;
                       const APathPanelList: TgmPathPanelList);
  end;


const
  FILE_ID      = $474D4446; // i.e. GMDF - GraphicsMagic Document File
  FILE_VERSION = 3;         // the file version we could process so far

//-- TgmGMDReader --------------------------------------------------------------

constructor TgmGMDReader.Create(const ALayerPanelList: TgmLayerPanelList;
  const AChannelManager: TgmChannelManager;
  const APathPanelList: TgmPathPanelList);
begin
  inherited Create;

  FFileFormatVersion := 0;
  FLayerPanelList    := ALayerPanelList;
  FChannelManager    := AChannelManager;   
  FPathPanelList     := APathPanelList;
end; 

destructor TgmGMDReader.Destroy;
begin
  FLayerPanelList := nil;
  FChannelManager := nil;
  FPathPanelList  := nil;
  inherited;
end; 

//-- TgmGMDReader1 -------------------------------------------------------------

constructor TgmGMDReader1.Create(const ALayerPanelList: TgmLayerPanelList;
  const AChannelManager: TgmChannelManager;
  const APathPanelList: TgmPathPanelList);
begin
  inherited Create(ALayerPanelList, AChannelManager, APathPanelList);

  FFileFormatVersion := 1;
end; 

function TgmGMDReader1.LoadFromStream(
  const AMemoryStream: TMemoryStream): Boolean;
begin
  Result := False;

  if not Assigned(AMemoryStream) then
  begin
    Exit;
  end;

  if Assigned(FLayerPanelList) then
  begin
    // load layers
    if FFileHeader.LayerCount > 0 then
    begin
      FLayerPanelList.TransparentLayerNumber    := FFileHeader.TransparentLayerNumber;
      FLayerPanelList.SolidColorLayerNumber     := FFileHeader.ColorFillLayerNumber;
      FLayerPanelList.ColorBalanceLayerNumber   := FFileHeader.ColorBalanceLayerNumber;
      FLayerPanelList.BrightContrastLayerNumber := FFileHeader.BrightContrastLayerNumber;
      FLayerPanelList.HLSLayerNumber            := FFileHeader.HLSLayerNumber;
      FLayerPanelList.InvertLayerNumber         := FFileHeader.InvertLayerNumber;
      FLayerPanelList.ThresholdLayerNumber      := FFileHeader.ThresholdLayerNumber;
      FLayerPanelList.PosterizeLayerNumber      := FFileHeader.PosterizeLayerNumber;
      FLayerPanelList.LevelsLayerNumber         := FFileHeader.LevelsLayerNumber;
      FLayerPanelList.CurvesLayerNumber         := FFileHeader.CurvesLayerNumber;
      FLayerPanelList.GradientMapLayerNumber    := FFileHeader.GradientMapLayerNumber;
      FLayerPanelList.GradientFillLayerNumber   := FFileHeader.GradientFillLayerNumber;
      FLayerPanelList.PatternLayerNumber        := FFileHeader.PatternLayerNumber;
      FLayerPanelList.FigureLayerNumber         := FFileHeader.FigureLayerNumber;
      FLayerPanelList.ShapeRegionLayerNumber    := FFileHeader.ShapeRegionLayerNumber;

      if not FLayerPanelList.LoadLayersFromStream(AMemoryStream,
               FFileFormatVersion, FFileHeader.LayerCount,
               FFileHeader.LayerWidth, FFileHeader.LayerHeight) then
      begin
        Exit;
      end;
    end;
  end;

  if Assigned(FChannelManager) then
  begin
    // load channels
    FChannelManager.AlphaChannelNumber      := FileHeader.AlphaChannelNumber;
    FChannelManager.GlobalMaskColor         := FileHeader.GlobalChannelMaskColor;
    FChannelManager.QuickMaskColor          := FileHeader.GlobalQuickMaskColor;
    FChannelManager.QuickMaskOpacityPercent := FileHeader.GlobalQuickMaskOpacityPercent;
    FChannelManager.QuickMaskColorIndicator := TgmMaskColorIndicator(FileHeader.GlobalQuickMaskColorIndicator);
    FChannelManager.LayerMaskColor          := FileHeader.GlobalLayerMaskColor;
    FChannelManager.LayerMaskOpacityPercent := FileHeader.GlobalLayerMaskOpacityPercent;

    if FFileHeader.ChannelCount > 0 then
    begin
      if not FChannelManager.LoadChannelsFromStream(AMemoryStream,
               FFileFormatVersion, FFileHeader.ChannelCount,
               FFileHeader.LayerWidth, FFileHeader.LayerHeight) then
      begin
        Exit;
      end
      else
      begin
        if FChannelManager.IsAllowRefreshChannelPanels then
        begin
          FChannelManager.HideAllChannelPanels;
          FChannelManager.ShowAllChannelPanels;
        end;
      end;
    end;
  end;

  if Assigned(FPathPanelList) then
  begin
    // load Pen Paths
    FPathPanelList.PathPanelNumber := FileHeader.PathPanelNumber;

    if FFileHeader.PathPanelCount > 0 then
    begin
      if not FPathPanelList.LoadPathPanelsFromStream(AMemoryStream,
               FFileFormatVersion, FFileHeader.PathPanelCount) then
      begin
        Exit;
      end;
    end;
  end;

  Result := True;
end;

//-- GMD Reader 2 --------------------------------------------------------------

constructor TgmGMDReader2.Create;
begin
  inherited Create(ALayerPanelList, AChannelManager, APathPanelList);
  
  FFileFormatVersion := 2;
end; 

function TgmGMDReader2.LoadFromStream(
  const AMemoryStream: TMemoryStream): Boolean;
begin
  Result := False;

  if not Assigned(AMemoryStream) then
  begin
    Exit;
  end;

  if Assigned(FLayerPanelList) then
  begin
    // load layers
    if FFileHeader.LayerCount > 0 then
    begin
      FLayerPanelList.TransparentLayerNumber    := FFileHeader.TransparentLayerNumber;
      FLayerPanelList.SolidColorLayerNumber     := FFileHeader.ColorFillLayerNumber;
      FLayerPanelList.ColorBalanceLayerNumber   := FFileHeader.ColorBalanceLayerNumber;
      FLayerPanelList.BrightContrastLayerNumber := FFileHeader.BrightContrastLayerNumber;
      FLayerPanelList.HLSLayerNumber            := FFileHeader.HLSLayerNumber;
      FLayerPanelList.InvertLayerNumber         := FFileHeader.InvertLayerNumber;
      FLayerPanelList.ThresholdLayerNumber      := FFileHeader.ThresholdLayerNumber;
      FLayerPanelList.PosterizeLayerNumber      := FFileHeader.PosterizeLayerNumber;
      FLayerPanelList.LevelsLayerNumber         := FFileHeader.LevelsLayerNumber;
      FLayerPanelList.CurvesLayerNumber         := FFileHeader.CurvesLayerNumber;
      FLayerPanelList.GradientMapLayerNumber    := FFileHeader.GradientMapLayerNumber;
      FLayerPanelList.GradientFillLayerNumber   := FFileHeader.GradientFillLayerNumber;
      FLayerPanelList.PatternLayerNumber        := FFileHeader.PatternLayerNumber;
      FLayerPanelList.FigureLayerNumber         := FFileHeader.FigureLayerNumber;
      FLayerPanelList.ShapeRegionLayerNumber    := FFileHeader.ShapeRegionLayerNumber;
      FLayerPanelList.ChannelMixerLayerNumber   := FFileHeader.ChannelMixerLayerNumber;  // new

      if not FLayerPanelList.LoadLayersFromStream(AMemoryStream,
               FFileFormatVersion, FFileHeader.LayerCount,
               FFileHeader.LayerWidth, FFileHeader.LayerHeight) then
      begin
        Exit;
      end;
    end;
  end;

  if Assigned(FChannelManager) then
  begin
    // load channels
    FChannelManager.AlphaChannelNumber      := FileHeader.AlphaChannelNumber;
    FChannelManager.GlobalMaskColor         := FileHeader.GlobalChannelMaskColor;
    FChannelManager.QuickMaskColor          := FileHeader.GlobalQuickMaskColor;
    FChannelManager.QuickMaskOpacityPercent := FileHeader.GlobalQuickMaskOpacityPercent;
    FChannelManager.QuickMaskColorIndicator := TgmMaskColorIndicator(FileHeader.GlobalQuickMaskColorIndicator);
    FChannelManager.LayerMaskColor          := FileHeader.GlobalLayerMaskColor;
    FChannelManager.LayerMaskOpacityPercent := FileHeader.GlobalLayerMaskOpacityPercent;

    if FFileHeader.ChannelCount > 0 then
    begin
      if not FChannelManager.LoadChannelsFromStream(AMemoryStream,
               FFileFormatVersion, FFileHeader.ChannelCount,
               FFileHeader.LayerWidth, FFileHeader.LayerHeight) then
      begin
        Exit;
      end
      else
      begin
        if FChannelManager.IsAllowRefreshChannelPanels then
        begin
          FChannelManager.HideAllChannelPanels;
          FChannelManager.ShowAllChannelPanels;
        end;
      end;
    end;
  end;

  if Assigned(FPathPanelList) then
  begin
    // load Pen Paths
    FPathPanelList.PathPanelNumber := FileHeader.PathPanelNumber;

    if FFileHeader.PathPanelCount > 0 then
    begin
      if not FPathPanelList.LoadPathPanelsFromStream(AMemoryStream,
               FFileFormatVersion, FFileHeader.PathPanelCount) then
      begin
        Exit;
      end;
    end;
  end;

  Result := True;
end; 

//-- GMD Reader 3 --------------------------------------------------------------

constructor TgmGMDReader3.Create(const ALayerPanelList: TgmLayerPanelList;
  const AChannelManager: TgmChannelManager;
  const APathPanelList: TgmPathPanelList);
begin
  inherited Create(ALayerPanelList, AChannelManager, APathPanelList);
  
  FFileFormatVersion := 3;
end;

//-- TgmGMDManager -------------------------------------------------------------

constructor TgmGMDManager.Create;
begin
  inherited Create;

  FMemoryStream := TMemoryStream.Create;
  FOutputMsg    := '';

  FLayerPanelList := nil;
  FChannelManager := nil;
  FPathPanelList  := nil;
end; 

destructor TgmGMDManager.Destroy;
begin
  FMemoryStream.Clear;
  FMemoryStream.Free;

  FLayerPanelList := nil;
  FChannelManager := nil;
  FPathPanelList  := nil; 
  
  inherited Destroy;
end; 

// use this function to determine whether or not we could open a .gmd file
function TgmGMDManager.CheckFileValidity(const AFileName: string): Boolean;
var
  LMemStream: TMemoryStream;
  LFileID   : Cardinal;
  LFileVer  : Cardinal;
begin
  Result := False;

  if not FileExists(AFileName) then
  begin
    FOutputMsg := 'The file "' + ExtractFileName(AFileName) + '" is not exists.';
    Exit;
  end;

  LMemStream := TMemoryStream.Create;
  try
    LMemStream.LoadFromFile(AFileName);
    LMemStream.Position := 0;

    // check the file ID
    LMemStream.Read(LFileID, 4);

    if LFileID <> FILE_ID then
    begin
      FOutputMsg := 'The file is not a valid GraphicsMagic document.';
      Exit;
    end;

    // check the file version
    LMemStream.Read(LFileVer, 4);

    if LFileVer > FILE_VERSION then
    begin
      FOutputMsg := 'Cannot open the file because the file version is high.';
      Exit;
    end;

    Result := True;
  finally
    LMemStream.Free;
  end;
end; 

{ The file name must be valid and the file must be exist.
  Check these before this function call, please. }
function TgmGMDManager.LoadFromFile(const AFileName: string): Boolean;
var
  LFileID        : Cardinal;
  LFileVersion   : Cardinal;
  LFileHeaderVer1: TgmGMDFileHeaderVer1;
  LFileHeaderVer2: TgmGMDFileHeaderVer2;
  LFileReader    : TgmGMDReader;
begin
  Result := False;

  FMemoryStream.Clear;
  FMemoryStream.LoadFromFile(AFileName);
  FMemoryStream.Position := 0;

  // check the file ID
  FMemoryStream.Read(LFileID, 4);

  if LFileID <> FILE_ID then
  begin
    FOutputMsg := 'The file is not a valid GraphicsMagic document.';
    Exit;
  end;

  // check the file version
  FMemoryStream.Read(LFileVersion, 4);

  if LFileVersion > FILE_VERSION then
  begin
    FOutputMsg := 'Cannot open the file because the file version is high.';
    Exit;
  end;

  FMemoryStream.Position := 0;

  // read in data, according to different file version
  case LFileVersion of
    1:
      begin
        FMemoryStream.Read(LFileHeaderVer1, SizeOf(TgmGMDFileHeaderVer1));

        LFileReader := TgmGMDReader1.Create(FLayerPanelList, FChannelManager, FPathPanelList);
        try
          TgmGMDReader1(LFileReader).FileHeader := LFileHeaderVer1;

          if LFileReader.LoadFromStream(FMemoryStream) then
          begin
            Result := True;
          end;
        finally
          LFileReader.Free;
        end;
      end;

    2:
      begin
        FMemoryStream.Read(LFileHeaderVer2, SizeOf(TgmGMDFileHeaderVer2));

        LFileReader := TgmGMDReader2.Create(FLayerPanelList, FChannelManager, FPathPanelList);
        try
          TgmGMDReader2(LFileReader).FileHeader := LFileHeaderVer2;

          if LFileReader.LoadFromStream(FMemoryStream) then
          begin
            Result := True;
          end;
        finally
          LFileReader.Free;
        end;
      end;

    3:
      begin
        // the file header format is same as version 2
        FMemoryStream.Read(LFileHeaderVer2, SizeOf(TgmGMDFileHeaderVer2));

        LFileReader := TgmGMDReader3.Create(FLayerPanelList, FChannelManager, FPathPanelList);
        try
          TgmGMDReader3(LFileReader).FileHeader := LFileHeaderVer2;

          if LFileReader.LoadFromStream(FMemoryStream) then
          begin
            Result := True;
          end;
        finally
          LFileReader.Free;
        end;
      end;
  end;
end;

{ The file name must be full, that is, with valid path and file extension.
  Check these before this function call, please.}
procedure TgmGMDManager.SaveToFile(const AFileName: string);
var
  LFileHeader: TgmGMDFileHeaderVer2;
begin
  if Assigned(FLayerPanelList) and
     Assigned(FChannelManager) and
     Assigned(FPathPanelList) then
  begin
    LFileHeader.FileID      := FILE_ID;
    LFileHeader.FileVersion := FILE_VERSION;

    { Layer Part }
    LFileHeader.LayerCount                := FLayerPanelList.Count;
    LFileHeader.TransparentLayerNumber    := FLayerPanelList.TransparentLayerNumber;
    LFileHeader.ColorFillLayerNumber      := FLayerPanelList.SolidColorLayerNumber;
    LFileHeader.ColorBalanceLayerNumber   := FLayerPanelList.ColorBalanceLayerNumber;
    LFileHeader.BrightContrastLayerNumber := FLayerPanelList.BrightContrastLayerNumber;
    LFileHeader.HLSLayerNumber            := FLayerPanelList.HLSLayerNumber;
    LFileHeader.InvertLayerNumber         := FLayerPanelList.InvertLayerNumber;
    LFileHeader.ThresholdLayerNumber      := FLayerPanelList.ThresholdLayerNumber;
    LFileHeader.PosterizeLayerNumber      := FLayerPanelList.PosterizeLayerNumber;
    LFileHeader.LevelsLayerNumber         := FLayerPanelList.LevelsLayerNumber;
    LFileHeader.CurvesLayerNumber         := FLayerPanelList.CurvesLayerNumber;
    LFileHeader.GradientMapLayerNumber    := FLayerPanelList.GradientMapLayerNumber;
    LFileHeader.GradientFillLayerNumber   := FLayerPanelList.GradientFillLayerNumber;
    LFileHeader.PatternLayerNumber        := FLayerPanelList.PatternLayerNumber;
    LFileHeader.FigureLayerNumber         := FLayerPanelList.FigureLayerNumber;
    LFileHeader.ShapeRegionLayerNumber    := FLayerPanelList.ShapeRegionLayerNumber;
    LFileHeader.ChannelMixerLayerNumber   := FLayerPanelList.ChannelMixerLayerNumber;
    LFileHeader.LayerWidth                := FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width;
    LFileHeader.LayerHeight               := FLayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height;

    { Channel Part }

    // channel count, including the Quick Mask channel
    LFileHeader.ChannelCount := FChannelManager.AlphaChannelPanelList.Count;

    if Assigned(FChannelManager.QuickMaskPanel) then
    begin
      Inc(LFileHeader.ChannelCount);
    end;

    LFileHeader.AlphaChannelNumber            := FChannelManager.AlphaChannelNumber;
    LFileHeader.GlobalChannelMaskColor        := FChannelManager.GlobalMaskColor;
    LFileHeader.GlobalQuickMaskColor          := FChannelManager.QuickMaskColor;
    LFileHeader.GlobalQuickMaskOpacityPercent := FChannelManager.QuickMaskOpacityPercent;
    LFileHeader.GlobalQuickMaskColorIndicator := Ord(FChannelManager.QuickMaskColorIndicator);
    LFileHeader.GlobalLayerMaskColor          := FChannelManager.LayerMaskColor;
    LFileHeader.GlobalLayerMaskOpacityPercent := FChannelManager.LayerMaskOpacityPercent;

    { Path Part }
    LFileHeader.PathPanelCount  := FPathPanelList.Count;
    LFileHeader.PathPanelNumber := FPathPanelList.PathPanelNumber;

    FMemoryStream.Clear;

    // write the file header to the stream
    FMemoryStream.Write(LFileHeader, SizeOf(TgmGMDFileHeaderVer2));

    // write the layer info to the stream
    if LFileHeader.LayerCount > 0 then
    begin
      FLayerPanelList.SaveLayersToStream(FMemoryStream);
    end;

    // write the channel info to the stream
    if LFileHeader.ChannelCount > 0 then
    begin
      FChannelManager.SaveChannelsToStream(FMemoryStream);
    end;

    // write the path info to the stream
    if LFileHeader.PathPanelCount > 0 then
    begin
      FPathPanelList.SavePathPanelsToStream(FMemoryStream);
    end;

    FMemoryStream.Position := 0;
    FMemoryStream.SaveToFile(AFileName);
  end;
end; 


end.
