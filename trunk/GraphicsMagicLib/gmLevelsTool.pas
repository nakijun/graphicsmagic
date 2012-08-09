{ This library created in 07/09/2006,
  CopyRight(C) 2006, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved.

  Based on "gimplevelstool.h" and "gimplevelstool.c" from GIMP 2.2.10 .
  The original source can be found at www.gimp.org.

  Many thanks to authors of GIMP -- Spencer Kimball and Peter Mattis,
  for giving us the opportunity to know how to achieve Levels Tool.

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Library General Public
  License as published by the Free Software Foundation; either
  version 2 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Library General Public License for more details.

  You should have received a copy of the GNU Library General Public
  License along with this library; if not, write to the
  Free Software Foundation, Inc., 59 Temple Place - Suite 330,
  Boston, MA 02111-1307, USA. }

unit gmLevelsTool;

interface

uses
{ Standard }
  Classes, Graphics,
{ Graphics32 }
  GR32,
{ GraphicsMagic Lib }
  gmTypes,
  gmGimpLut,
  gmLevels,
  gmGimpHistogram;

type
  TgmLevelsFileHeader = record
    Mark   : string[255];
    Version: Integer;
  end;

//-- TgmLevelsTool -------------------------------------------------------------

  TgmLevelsTool = class(TObject)
  private
    FLUT         : TgmGimpLut;
    FColored     : Boolean;
    FChannel     : Integer;
    FSourceBmp   : TBitmap32;
    FActiveSlider: Integer;
    FActivePicker: TgmLevelsActivePicker;
    FLevels      : TgmLevels;
    FSliderPos   : array [0..4] of Integer;
    FOutputMsg   : string; // output imformation, such as errors, etc.

    procedure Init;
    procedure FreeLUT; // Added by ourselves.
    procedure LevelsDrawSlider(ACanvas: TCanvas; const AFillColor: TColor32; const XPos: Integer);

    function GetSliderPos(AIndex: Integer): Integer;
    function GetLevelsGamma: Double;
    function GetLevelsLowInput: Integer;
    function GetLevelsHighInput: Integer;
    function GetLevelsLowOutput: Integer;
    function GetLevelsHighOutput: Integer;

    procedure SetSliderPos(AIndex, AValue: Integer);
    procedure SetLevelsGamma(const AValue: Double);
    procedure SetLevelsLowInput(const AValue: Integer);
    procedure SetLevelsHighInput(const AValue: Integer);
    procedure SetLevelsLowOutput(const AValue: Integer);
    procedure SetLevelsHighOutput(const AValue: Integer);
  public
    constructor Create(const ASourceBmp: TBitmap32);
    destructor Destroy; override;

    procedure LUTSetup(const NChannels: Integer);
    procedure Map(ADestBmp: TBitmap32; const AChannelSet: TgmChannelSet);
    procedure Reset;
    procedure LevelsCalculateTransfers;
    procedure LevelsChannelReset;
    procedure LevelsStretch(const AHist: TgmGimpHistogram);
    procedure ColorPicked(const AColor: TColor32);
    procedure LevelsInputAreaExpose(ACanvas: TCanvas; const ABorderSize: Integer);
    procedure LevelsOutputAreaExpose(ACanvas: TCanvas; const ABorderSize: Integer);

    function LoadFromStream(const AStream: TStream): Boolean;  // load Levels settings from a stream
    procedure SaveToStream(const AStream: TStream);            // save Levels settings to a stream

    function LoadFromFile(const AFileName: string): Boolean;  // load Levels settings from file
    procedure SaveToFile(const AFileName: string);            // save Levels settings to file

    property LUT                      : TgmGimpLut            read FLUT                write FLUT;
    property SourceBitmap             : TBitmap32             read FSourceBmp;
    property Channel                  : Integer               read FChannel            write FChannel;
    property IsColored                : Boolean               read FColored;
    property ActiveSlider             : Integer               read FActiveSlider       write FActiveSlider;
    property ActivePicker             : TgmLevelsActivePicker read FActivePicker       write FActivePicker;
    property Levels                   : TgmLevels             read FLevels             write FLevels;
    property SliderPos[index: Integer]: Integer               read GetSliderPos        write SetSliderPos;
    property LevelsGamma              : Double                read GetLevelsGamma      write SetLevelsGamma;
    property LevelsLowInput           : Integer               read GetLevelsLowInput   write SetLevelsLowInput;
    property LevelsHighInput          : Integer               read GetLevelsHighInput  write SetLevelsHighInput;
    property LevelsLowOutput          : Integer               read GetLevelsLowOutput  write SetLevelsLowOutput;
    property LevelsHighOutput         : Integer               read GetLevelsHighOutput write SetLevelsHighOutput;
    property OutputMsg                : string                read FOutputMsg;
  end;

const
  LOW_INPUT      = (1 shl 0);
  GAMMA          = (1 shl 1);
  HIGH_INPUT     = (1 shl 2);
  LOW_OUTPUT     = (1 shl 3);
  HIGH_OUTPUT    = (1 shl 4);
  INPUT_LEVELS   = (1 shl 5);
  OUTPUT_LEVELS  = (1 shl 6);
  INPUT_SLIDERS  = (1 shl 7);
  OUTPUT_SLIDERS = (1 shl 8);
  ALL_CHANNELS   = (1 shl 9);
  ALL            = $FFF;

  HISTOGRAM_WIDTH = 256;
  GRADIENT_HEIGHT = 12;
  CONTROL_HEIGHT  = 8;
  BORDER          = (CONTROL_HEIGHT - 1) div 2; // add by ourselves

  LEVELS_FILE_EXT     = '.glv';  // glv stands for 'GraphicsMagic Levels'
  LEVELS_FILE_MARK    = 'GraphicsMagic Levels';
  LEVELS_FILE_VERSION = 1;

implementation

uses
{ Standard }
  SysUtils, Math,
{ GraphicsMagic Lib }
  gmGimpBaseEnums, gmGimpCommonFuncs;
  

//-- TgmLevelsTool -------------------------------------------------------------

constructor TgmLevelsTool.Create(const ASourceBmp: TBitmap32);
begin
  inherited Create;

  FSourceBmp := TBitmap32.Create;
  FSourceBmp.Assign(ASourceBmp);

  FOutputMsg := '';

  Init;
end; 

destructor TgmLevelsTool.Destroy;
begin
  FSourceBmp.Free;
  FLevels.Free;
  FreeLUT;
  
  inherited Destroy;
end; 

procedure TgmLevelsTool.Init;
begin
  FLUT          := gimp_lut_new;
  FLevels       := TgmLevels.Create;
  FChannel      := GIMP_HISTOGRAM_VALUE;
  FActivePicker := lapNone;
  FActiveSlider := 0;
  FColored      := True;
end; 

procedure TgmLevelsTool.Map(ADestBmp: TBitmap32;
  const AChannelSet: TgmChannelSet);
begin
  LUTSetup(3);
  gimp_lut_process(FLUT, FSourceBmp, ADestBmp, AChannelSet);
end;

procedure TgmLevelsTool.Reset;
begin
  FLevels.Init;
end;

procedure TgmLevelsTool.LevelsStretch(const AHist: TgmGimpHistogram);
begin
  FLevels.Stretch(AHist, FColored);
end; 

procedure TgmLevelsTool.ColorPicked(const AColor: TColor32);
var
  LChannel: Integer;
begin
  // first reset the value channel
  case FActivePicker of
    lapBlack:
      begin
        FLevels.lowInput[GIMP_HISTOGRAM_VALUE] := 0;
      end;
      
    lapGray:
      begin
        FLevels.Gamma[GIMP_HISTOGRAM_VALUE] := 1.0;
      end;
      
    lapWhite:
      begin
        FLevels.HighInput[GIMP_HISTOGRAM_VALUE] := 255;
      end;
  end;

  // then adjust all color channels
  for LChannel := GIMP_HISTOGRAM_RED to GIMP_HISTOGRAM_BLUE do
  begin
    FLevels.AdjustByColors(LChannel, FActivePicker, AColor);
  end;
end;

procedure TgmLevelsTool.LevelsCalculateTransfers;
begin
  FLevels.CalculateTransfers;
end;

procedure TgmLevelsTool.LevelsChannelReset;
begin
  FLevels.ChannelReset(FChannel);
end;

procedure TgmLevelsTool.LUTSetup(const NChannels: Integer);
var
  i, v: Cardinal;
  LVal: Double;
begin
  if High(FLUT.luts) > (-1) then
  begin
    for i := 0 to (FLUT.nchannels - 1) do
    begin
      SetLength(FLUT.luts[i], 0);
    end;
    
    SetLength(FLUT.luts, 0);
  end;

  FLUT.nchannels := NChannels;
  SetLength(FLUT.luts, FLUT.nchannels);

  for i := 0 to (FLUT.nchannels - 1) do
  begin
    SetLength(FLUT.luts[i], 256);

    for v := 0 to 255 do
    begin
      { to add gamma correction use func(v ^ g) ^ 1/g instead. }
      LVal := 255.0 * FLevels.LUTFunc(FLUT.nchannels, i, v / 255.0) + 0.5;

      if LVal < 0.0 then
      begin
        LVal := 0.0;
      end
      else if LVal > 255.0 then
      begin
        LVal := 255.0;
      end;

      FLUT.luts[i, v] := Round(LVal);
    end;
  end;
end;

procedure TgmLevelsTool.FreeLUT;
var
  i: Integer;
begin
  if High(FLUT.luts) > (-1) then
  begin
    for i := Low(FLUT.luts) to High(FLUT.luts) do
    begin
      if High(FLUT.luts[i]) > (-1) then
      begin
        SetLength(FLUT.luts[i], 0);
        FLUT.luts[i] := nil;
      end;
    end;

    SetLength(FLUT.luts, 0);
    FLUT.luts := nil;
  end;
end;

procedure TgmLevelsTool.LevelsDrawSlider(ACanvas: TCanvas;
  const AFillColor: TColor32; const XPos: Integer);
var
  Y: Integer;
begin
  with ACanvas do
  begin
    Pen.Color := AFillColor;

    for Y := 0 to (CONTROL_HEIGHT - 1) do
    begin
      MoveTo(XPos - Y div 2, GRADIENT_HEIGHT + Y);
      LineTo(XPos + Y div 2, GRADIENT_HEIGHT + Y);
    end;

    Pen.Color := clBlack;

    MoveTo(XPos, GRADIENT_HEIGHT);
    LineTo( XPos - (CONTROL_HEIGHT - 1) div 2, GRADIENT_HEIGHT + CONTROL_HEIGHT - 1);

    MoveTo(XPos, GRADIENT_HEIGHT);
    LineTo( XPos + (CONTROL_HEIGHT - 1) div 2, GRADIENT_HEIGHT + CONTROL_HEIGHT - 1 );

    MoveTo( XPos - (CONTROL_HEIGHT - 1) div 2, GRADIENT_HEIGHT + CONTROL_HEIGHT - 1 );
    LineTo( XPos + (CONTROL_HEIGHT) div 2, GRADIENT_HEIGHT + CONTROL_HEIGHT - 1 );
  end;
end;

function TgmLevelsTool.GetSliderPos(AIndex: Integer): Integer;
begin
  if AIndex in [0..4] then
  begin
    Result := FSliderPos[AIndex];
  end
  else
  begin
    Result := 0;
  end;
end;

function TgmLevelsTool.GetLevelsGamma: Double;
begin
  Result := FLevels.Gamma[FChannel];
end; 

function TgmLevelsTool.GetLevelsLowInput: Integer;
begin
  Result := FLevels.LowInput[FChannel];
end; 

function TgmLevelsTool.GetLevelsHighInput: Integer;
begin
  Result := FLevels.HighInput[FChannel];
end; 

function TgmLevelsTool.GetLevelsLowOutput: Integer;
begin
  Result := FLevels.LowOutput[FChannel];
end; 

function TgmLevelsTool.GetLevelsHighOutput: Integer;
begin
  Result := FLevels.HighOutput[FChannel];
end;

procedure TgmLevelsTool.SetSliderPos(AIndex, AValue: Integer);
begin
  if AIndex in [0..4] then
  begin
    if FSliderPos[AIndex] <> AValue then
    begin
      FSliderPos[AIndex] := AValue;
    end;
  end;
end;

procedure TgmLevelsTool.SetLevelsGamma(const AValue: Double);
begin
  FLevels.Gamma[FChannel] := AValue;
end; 

procedure TgmLevelsTool.SetLevelsLowInput(const AValue: Integer);
begin
  FLevels.LowInput[FChannel] := AValue;
end;

procedure TgmLevelsTool.SetLevelsHighInput(const AValue: Integer);
begin
  FLevels.HighInput[FChannel] := AValue;
end;

procedure TgmLevelsTool.SetLevelsLowOutput(const AValue: Integer);
begin
  FLevels.LowOutput[FChannel] := AValue;
end;

procedure TgmLevelsTool.SetLevelsHighOutput(const AValue: Integer);
begin
  FLevels.HighOutput[FChannel] := AValue;
end;

procedure TgmLevelsTool.LevelsInputAreaExpose(ACanvas: TCanvas;
  const ABorderSize: Integer);
var
  LWidth      : Integer;
  LDelta, LMid: Double;
  LTmp        : Extended;
begin
  LWidth := ACanvas.ClipRect.Right - ACanvas.ClipRect.Left;
  LWidth := LWidth - 2 * ABorderSize;

  FSliderPos[0] := Round(LWidth * FLevels.LowInput[FChannel]  / 256.0) + ABorderSize;
  FSliderPos[2] := Round(LWidth * FLevels.HighInput[FChannel] / 256.0) + ABorderSize;

  LDelta := (FSliderPos[2] - FSliderPos[0]) / 2.0;
  LMid   := FSliderPos[0] + LDelta;

  if FLevels.Gamma[FChannel] > 0 then
  begin
    LTmp := Log10(1.0 / FLevels.Gamma[FChannel]);
  end
  else
  begin
    LTmp := 1.0;
  end;

  FSliderPos[1] := Round(LMid + LDelta * LTmp); // eliminate the original code + BorderSize;

  LevelsDrawSlider(ACanvas, clBlack, FSliderPos[0]);
  LevelsDrawSlider(ACanvas, clGray,  FSliderPos[1]);
  LevelsDrawSlider(ACanvas, clwhite, FSliderPos[2]);
end;

procedure TgmLevelsTool.LevelsOutputAreaExpose(ACanvas: TCanvas;
  const ABorderSize: Integer);
var
  LWidth: Integer;
begin
  LWidth := ACanvas.ClipRect.Right - ACanvas.ClipRect.Left;
  LWidth := LWidth - 2 * ABorderSize;

  FSliderPos[3] := Round(LWidth * FLevels.LowOutput[FChannel]  / 256.0) + ABorderSize;
  FSliderPos[4] := Round(LWidth * FLevels.HighOutput[FChannel] / 256.0) + ABorderSize;

  LevelsDrawSlider(ACanvas, clBlack, FSliderPos[3]);
  LevelsDrawSlider(ACanvas, clwhite, FSliderPos[4]);
end; 

// load Levels settings from a stream
function TgmLevelsTool.LoadFromStream(const AStream: TStream): Boolean;
var
  i, j, LIntValue: Integer;
  LDoubleValue   : Double;
begin
  Result := False;

  if Assigned(AStream) then
  begin
    for j := Low(FLUT.luts) to High(FLUT.luts) do
    begin
      for i := Low(FLUT.luts[j]) to High(LUT.luts[j]) do
      begin
        AStream.Read(FLUT.luts[j, i], 1);
      end;
    end;

    for i := 0 to 4 do
    begin
      AStream.Read(FSliderPos[i], 4);
    end;

    for i := 0 to 4 do
    begin
      AStream.Read(LDoubleValue, SizeOf(Double));
      FLevels.Gamma[i] := LDoubleValue;
    end;

    for i := 0 to 4 do
    begin
      AStream.Read(LIntValue, 4);
      FLevels.LowInput[i] := LIntValue;
    end;

    for i := 0 to 4 do
    begin
      AStream.Read(LIntValue, 4);
      FLevels.HighInput[i] := LIntValue;
    end;

    for i := 0 to 4 do
    begin
      AStream.Read(LIntValue, 4);
      FLevels.LowOutput[i] := LIntValue;
    end;

    for i := 0 to 4 do
    begin
      AStream.Read(LIntValue, 4);
      FLevels.HighOutput[i] := LIntValue;
    end;

    for i := 0 to 4 do
    begin
      for j := 0 to 255 do
      begin
        AStream.Read(FLevels.FInput[i, j], 1);
      end;
    end;

    AStream.Read(FChannel, 4);

    Result := True;
  end;
end;

// save Levels settings to a stream
procedure TgmLevelsTool.SaveToStream(const AStream: TStream);
var
  i, j, LIntValue: Integer;
  LDoubleValue   : Double;
begin
  if Assigned(AStream) then
  begin
    for j := Low(FLUT.luts) to High(FLUT.luts) do
    begin
      for i := Low(FLUT.luts[j]) to High(LUT.luts[j]) do
      begin
        AStream.Write(FLUT.luts[j, i], 1);
      end;
    end;

    for i := 0 to 4 do
    begin
      AStream.Write(FSliderPos[i], 4);
    end;

    for i := 0 to 4 do
    begin
      LDoubleValue := FLevels.Gamma[i];
      AStream.Write(LDoubleValue, SizeOf(Double));
    end;

    for i := 0 to 4 do
    begin
      LIntValue := FLevels.LowInput[i];
      AStream.Write(LIntValue, 4);
    end;

    for i := 0 to 4 do
    begin
      LIntValue := FLevels.HighInput[i];
      AStream.Write(LIntValue, 4);
    end;

    for i := 0 to 4 do
    begin
      LIntValue := FLevels.LowOutput[i];
      AStream.Write(LIntValue,  4);
    end;

    for i := 0 to 4 do
    begin
      LIntValue := FLevels.HighOutput[i];
      AStream.Write(LIntValue, 4);
    end;

    for i := 0 to 4 do
    begin
      for j := 0 to 255 do
      begin
        AStream.Write(FLevels.FInput[i, j], 1);
      end;
    end;

    AStream.Write(FChannel, 4);
  end;
end;

// load Levels settings from file
function TgmLevelsTool.LoadFromFile(const AFileName: string): Boolean;
var
  LFileHeader : TgmLevelsFileHeader;
  LInputStream: TMemoryStream;
begin
  Result := False;

  if FileExists(AFileName) then
  begin
    LInputStream := TMemoryStream.Create;
    try
      LInputStream.LoadFromFile(AFileName);
      LInputStream.Position := 0;
      LInputStream.Read(LFileHeader, SizeOf(LFileHeader));

      if LFileHeader.Mark <> LEVELS_FILE_MARK then
      begin
        FOutputMsg := 'Cannot open the file "' + ExtractFileName(AFileName) + '",' + #10#13 +
                      'because the file header data is not correct.';
      end
      else
      begin
        if LFileHeader.Version > LEVELS_FILE_VERSION then
        begin
          FOutputMsg := 'Cannot open the file "' + ExtractFileName(AFileName) + '",' + #10#13 +
                        'because the file version is higher than this program supports.';
        end
        else
        begin
          Result := Self.LoadFromStream(LInputStream);
        end;
      end;
      
    finally
      LInputStream.Free;
    end;
  end;
end;

// save Levels settings to file
procedure TgmLevelsTool.SaveToFile(const AFileName: string);
var
  LFileHeader    : TgmLevelsFileHeader;
  LFileDir       : string;
  LFileExt       : string;
  LOutputFileName: string;
  LOutputStream  : TMemoryStream;
begin
  LOutputFileName := AFileName;
  LFileDir        := ExtractFileDir(LOutputFileName);

  if (LFileDir <> '') and DirectoryExists(LFileDir) then
  begin
    LFileExt := ExtractFileExt(LOutputFileName);

    if LFileExt = '' then
    begin
      LOutputFileName := LOutputFileName + LEVELS_FILE_EXT;
    end
    else if LFileExt <> LEVELS_FILE_EXT then
    begin
      LOutputFileName := ChangeFileExt(LOutputFileName, LEVELS_FILE_EXT);
    end;

    // filling the file header
    LFileHeader.Mark    := LEVELS_FILE_MARK;
    LFileHeader.Version := LEVELS_FILE_VERSION;

    LOutputStream := TMemoryStream.Create;
    try
      LOutputStream.Write(LFileHeader, SizeOf(LFileHeader));  // write in header data
      Self.SaveToStream(LOutputStream);                       // write in levels settings

      // save to file
      LOutputStream.Position := 0;
      LOutputStream.SaveToFile(LOutputFileName);
    finally
      LOutputStream.Free;
    end;
  end;
end;

end.
