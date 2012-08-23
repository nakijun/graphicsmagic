{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved.

  Based on efg's HistoStretchGrays project.

  You could find the original code from:
    http://www.efg2.com/Lab/ImageProcessing/HistoStretchGrays.htm
 }

unit HistogramDlg;

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
{ Standard Lib }
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
{ Graphics32 Lib }
  GR32,
{ GraphicsMagic Lib }
  HistogramLibrary;

type
  TColorChannel = (ccLuminosity, ccRed, ccGreen, ccBlue, ccIntensity);

  TfrmHistogram = class(TForm)
    btbtnOK: TBitBtn;
    grpbxStatistics: TGroupBox;
    lblMinimum: TLabel;
    lblMaximum: TLabel;
    lblMode: TLabel;
    lblMedian: TLabel;
    lblMean: TLabel;
    lblStandardDeviation: TLabel;
    lblExcessKurtosis: TLabel;
    lblColors: TLabel;
    lblPixels: TLabel;
    lblMinimumValue: TLabel;
    lblMaximumValue: TLabel;
    lblModeValue: TLabel;
    lblMedianValue: TLabel;
    lblMeanValue: TLabel;
    lblStandardDeviationValue: TLabel;
    lblExcessKurtosisValue: TLabel;
    lblColorsValue: TLabel;
    lblPixelsValue: TLabel;
    grpbxHistogram: TGroupBox;
    lblChannel: TLabel;
    cmbbxChannel: TComboBox;
    imgHistogram: TImage;
    imgColorBar: TImage;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cmbbxChannelChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btbtnOKClick(Sender: TObject);
  private
    FSourceBitmap: TBitmap32;
    FColorChannel: TColorChannel;

    procedure UpdateDisplay(const ASourceBmp: TBitmap32;
      const AColorChannel: TColorChannel);

    procedure DrawColorBar(const AColorChannel: TColorChannel);

    procedure ShowHistogram(const AHistogram: THistogram; const ABitmap: TBitmap;
      const AImage: TImage; const AMinimumValue, AMaximumValue: TLabel;
      const AModeValue, AMedianValue, AMeanValue, AStdDevValue: TLabel;
      const AKurtosisValue, AColorsValue, APixelsValue: TLabel);
  public
    { Public declarations }
  end;

var
  frmHistogram: TfrmHistogram;

implementation

uses
{ Externals }
  ImageProcessingPrimitives,  // CountColors
{ GraphicsMagic Lib }
  gmTypes,
  gmIni,
  gmImageProcessFuncs,
  gmLayerAndChannel,
{ GraphicsMagic Forms/Dialogs }
  MainForm;                   // ActiveChildForm defined in this unit


{$R *.DFM}

const
  HISTOGRAM_WIDTH  = 256;
  HISTOGRAM_HEIGHT = 84;
  COLOR_BAR_HEIGHT = 16;

//-- Custom Procedures and Functions -------------------------------------------

procedure TfrmHistogram.UpdateDisplay(const ASourceBmp: TBitmap32;
  const AColorChannel: TColorChannel);
var
  LHistogram     : THistogram;
  LStandardBitmap: TBitmap;
begin
  Screen.Cursor := crHourGlass;
  try
    // Update Display of Histograms.  Some work will be redone below to create
    // optimal Histostretch parameters.
    LHistogram := THistogram.Create;
    try
      // Ask for cpRed, but cpGreen or cpBlue will give identical results
      // since R = G = B for shades of gray

      // get histogram according to different color channel
      case AColorChannel of
        ccLuminosity : GetHistogram(cpValue,     ASourceBmp, LHistogram);
        ccRed        : GetHistogram(cpRed,       ASourceBmp, LHistogram);
        ccGreen      : GetHistogram(cpGreen,     ASourceBmp, LHistogram);
        ccBlue       : GetHistogram(cpBlue,      ASourceBmp, LHistogram);
        ccIntensity  : GetHistogram(cpIntensity, ASourceBmp, LHistogram);
      end;

      LStandardBitmap := TBitmap.Create;
      try
        LStandardBitmap.Assign(ASourceBmp);
        LStandardBitmap.PixelFormat := pf24bit;

        // Show Original Histogram
        ShowHistogram(LHistogram, LStandardBitmap, imgHistogram,
                      lblMinimumValue, lblMaximumValue, lblModeValue,
                      lblMedianValue, lblMeanValue, lblStandardDeviationValue,
                      lblExcessKurtosisValue, lblColorsValue, lblPixelsValue);
      finally
        LStandardBitmap.Free;
      end;

    finally
      LHistogram.Free
    end;

  finally
    Screen.Cursor := crDefault
  end;
  
  DrawColorBar(AColorChannel);
end;

procedure TfrmHistogram.DrawColorBar(const AColorChannel: TColorChannel);
type
  pRGBTripleArray = ^TRGBTripleArray;
  TRGBTipleArray  = array [0..65535] of TRGBTriple;
var
  i, j: Integer;
  Row : pRGBTripleArray;
  bmp : TBitmap;
begin
  bmp := TBitmap.Create;
  try
    bmp.PixelFormat := pf24bit;
    bmp.Width       := HISTOGRAM_WIDTH;
    bmp.Height      := COLOR_BAR_HEIGHT;

    for j := 0 to (bmp.Height - 1) do
    begin
      Row := bmp.Scanline[j];

      for i := 0 to (bmp.Width - 1) do
      begin
        case AColorChannel of
          ccLuminosity,
          ccIntensity:
            begin
              Row[i].rgbtRed   := i;
              Row[i].rgbtGreen := i;
              Row[i].rgbtBlue  := i;
            end;

          ccRed:
            begin
              Row[i].rgbtRed   := i;
              Row[i].rgbtGreen := 0;
              Row[i].rgbtBlue  := 0;
            end;

          ccGreen:
            begin
              Row[i].rgbtRed   := 0;
              Row[i].rgbtGreen := i;
              Row[i].rgbtBlue  := 0;
            end;
            
          ccBlue:
            begin
              Row[i].rgbtRed   := 0;
              Row[i].rgbtGreen := 0;
              Row[i].rgbtBlue  := i;
            end;
        end;
      end;
    end;
    imgColorBar.Picture.Bitmap.Assign(bmp);
  finally
    bmp.Free;
  end;
end;

procedure TfrmHistogram.ShowHistogram(const AHistogram: THistogram;
  const ABitmap: TBitmap; const AImage: TImage;
  const AMinimumValue, AMaximumValue: TLabel;
  const AModeValue, AMedianValue, AMeanValue, AStdDevValue: TLabel;
  const AKurtosisValue, AColorsValue, APixelsValue: TLabel);
const
  clSkyBlue = TColor($F0CAA6);   // RGB:  166 202 240
var
  Kurtosis, Mean, Skewness, StandardDeviation: Double;
  Maximum, Median, Minimum, Mode             : Byte;
  n, ColorCount                              : Integer;
begin
  AImage.Canvas.Brush.Color := clSkyBlue;
  AImage.Canvas.FillRect( Rect(0, 0, AImage.Width, AImage.Height) );

  AHistogram.Draw(AImage.Canvas);
  AHistogram.GetStatistics(n, Minimum, Maximum, Mode, Median, Mean,
                           StandardDeviation, Skewness, Kurtosis);

  ColorCount := CountColors(ABitmap);

  AMinimumValue.Caption  := Format('%d',   [Minimum]);
  AMaximumValue.Caption  := Format('%d',   [Maximum]);
  AModeValue.Caption     := Format('%d',   [Mode]);
  AMedianValue.Caption   := Format('%d',   [Median]);
  AMeanValue.Caption     := Format('%.1f', [Mean]);
  AStdDevValue.Caption   := Format('%.1f', [StandardDeviation]);
  AKurtosisValue.Caption := Format('%.1f', [Kurtosis - 3.0]);
  AColorsValue.Caption   := Format('%d',   [ColorCount]);
  APixelsValue.Caption   := FormatFloat(',##0', n);
end;

//------------------------------------------------------------------------------

procedure TfrmHistogram.FormShow(Sender: TObject);
var
  LChannelName: string;
begin
  if FSourceBitmap = nil then
  begin
    FSourceBitmap := TBitmap32.Create;
  end;
  
  cmbbxChannel.Items.Clear;
  cmbbxChannel.ItemIndex := -1;

  with ActiveChildForm do
  begin
    // determine the name of channel
    case ChannelManager.CurrentChannelType of
      wctAlpha:
        begin
          if Assigned(ChannelManager.SelectedAlphaChannelPanel) then
          begin
            LChannelName := ChannelManager.SelectedAlphaChannelPanel.ChannelName;
          end;
        end;

      wctQuickMask:
        begin
          if Assigned(ChannelManager.QuickMaskPanel) then
          begin
            LChannelName := ChannelManager.QuickMaskPanel.ChannelName;
          end;
        end;

      wctLayerMask:
        begin
          if Assigned(ChannelManager.LayerMaskPanel) then
          begin
            LChannelName := ChannelManager.LayerMaskPanel.ChannelName;
          end;
        end;

    else
      LChannelName := '';
    end;

    // update Channel Combobox
    case ChannelManager.CurrentChannelType of
      wctAlpha, wctQuickMask, wctLayerMask:
        begin
          cmbbxChannel.Items.Add(LChannelName);

          cmbbxChannel.Hint      := LChannelName;
          cmbbxChannel.ItemIndex := 0;
        end;

      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          cmbbxChannel.Items.Add('Luminosity');
          cmbbxChannel.Items.Add('Red');
          cmbbxChannel.Items.Add('Green');
          cmbbxChannel.Items.Add('Blue');
          cmbbxChannel.Items.Add('Intensity');

          cmbbxChannel.Hint      := '';
          cmbbxChannel.ItemIndex := Integer(FColorChannel);
        end;
    end;

    // determine the source of histogram
    if Assigned(Selection) then
    begin
      tmrMarchingAnts.Enabled := False;
      FSourceBitmap.Assign(Selection.CutOriginal);
    end
    else
    begin
      case ChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            if Assigned(ChannelManager.SelectedAlphaChannelPanel) then
            begin
              FSourceBitmap.Assign(ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
            end;
          end;

        wctQuickMask:
          begin
            if Assigned(ChannelManager.QuickMaskPanel) then
            begin
              FSourceBitmap.Assign(ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
            end;
          end;

        wctLayerMask:
          begin
            if Assigned(ChannelManager.LayerMaskPanel) then
            begin
              FSourceBitmap.Assign(ChannelManager.LayerMaskPanel.AlphaLayer.Bitmap);
            end;
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            if LayerPanelList.Count > 1 then
            begin
              LayerPanelList.FlattenLayersToBitmap(FSourceBitmap, dmBlend);
            end
            else
            begin
              FSourceBitmap.Assign(LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
            end;
          end;
      end;
    end;

    // update the histogram
    case ChannelManager.CurrentChannelType of
      wctAlpha, wctQuickMask, wctLayerMask:
        begin
          UpdateDisplay(FSourceBitmap, ccIntensity);
        end;
        
      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          UpdateDisplay(FSourceBitmap, FColorChannel);
        end;
    end;
  end;

  ActiveControl := btbtnOK;
end;

procedure TfrmHistogram.FormCreate(Sender: TObject);
begin
  FSourceBitmap                      := TBitmap32.Create;
  FColorChannel                      := TColorChannel(StrToInt(ReadInfoFromIniFile(SECTION_HISTOGRAM_DIALOG, IDENT_HISTOGRAM_COLOR_CHANNEL, '0')));
  cmbbxChannel.ItemIndex             := 0;
  imgHistogram.Picture.Bitmap.Width  := HISTOGRAM_WIDTH;
  imgHistogram.Picture.Bitmap.Height := HISTOGRAM_HEIGHT;
  imgColorBar.Picture.Bitmap.Width   := HISTOGRAM_WIDTH;
  imgColorBar.Picture.Bitmap.Height  := COLOR_BAR_HEIGHT;
end; 

procedure TfrmHistogram.FormDestroy(Sender: TObject);
begin
  FSourceBitmap.Free;
end;

procedure TfrmHistogram.cmbbxChannelChange(Sender: TObject);
begin
  case cmbbxChannel.ItemIndex of
    0: FColorChannel := ccLuminosity;
    1: FColorChannel := ccRed;
    2: FColorChannel := ccGreen;
    3: FColorChannel := ccBlue;
    4: FColorChannel := ccIntensity;
  end;

  // update the histogram
  case ActiveChildForm.ChannelManager.CurrentChannelType of
    wctAlpha,
    wctQuickMask,
    wctLayerMask:
      begin
        UpdateDisplay(FSourceBitmap, ccIntensity);
      end;
      
    wctRGB, wctRed, wctGreen, wctBlue:
      begin
        UpdateDisplay(FSourceBitmap, FColorChannel);
      end;
  end;
end;

procedure TfrmHistogram.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if FSourceBitmap <> nil then
  begin
    FreeAndNil(FSourceBitmap);
  end;
end;

procedure TfrmHistogram.btbtnOKClick(Sender: TObject);
begin
  WriteInfoToIniFile(SECTION_HISTOGRAM_DIALOG, IDENT_HISTOGRAM_COLOR_CHANNEL,
                     IntToStr(Ord(FColorChannel)));
end; 

end.
