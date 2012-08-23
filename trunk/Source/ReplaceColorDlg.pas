{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

{ NOTE:
  HR  = Hue/Red
  SG  = Saturation/Green
  LVB = Lightness/Value/Blue }

unit ReplaceColorDlg;

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
  ExtCtrls, StdCtrls, ComCtrls, Buttons,
{ Graphics32 Lib }
  GR32, GR32_Image, GR32_Layers, GR32_RangeBars,
{ GraphicsMagic Lib }
  gmColorRange, gmReplaceColor;

type
  TgmThumbnailDisplayMode = (tdmSelection, tdmImage);

  TfrmReplaceColor = class(TForm)
    stsbrColorRange: TStatusBar;
    stsbrCurrentColor: TStatusBar;
    grpbxSelection: TGroupBox;
    lblFuzziness: TLabel;
    edtFuzziness: TEdit;
    pnlThumbnail: TPanel;
    img32Thumbnail: TImage32;
    rdbtnSelection: TRadioButton;
    rdbtnImage: TRadioButton;
    grpbxTransform: TGroupBox;
    lblHR: TLabel;
    edtHR: TEdit;
    lblSG: TLabel;
    edtSG: TEdit;
    lblLVB: TLabel;
    edtLVB: TEdit;
    lblSample: TLabel;
    shpSample: TShape;
    btbtnOK: TBitBtn;
    btbtnCancel: TBitBtn;
    chckbxPreview: TCheckBox;
    grpbxColorMode: TGroupBox;
    rdbtnHLS: TRadioButton;
    rdbtnHSV: TRadioButton;
    rdbtnRGB: TRadioButton;
    ggbrFuzziness: TGaugeBar;
    ggbrHR: TGaugeBar;
    ggbrSG: TGaugeBar;
    ggbrLVB: TGaugeBar;
    lblHRPercent: TLabel;
    lblSGPercent: TLabel;
    lblLVBPercent: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure rdbtnSelectionClick(Sender: TObject);
    procedure rdbtnImageClick(Sender: TObject);
    procedure img32ThumbnailMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);
    procedure ChangeColor(Sender: TObject);
    procedure img32ThumbnailMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer; Layer: TCustomLayer);
    procedure chckbxPreviewClick(Sender: TObject);
    procedure edtFuzzinessChange(Sender: TObject);
    procedure edtHRChange(Sender: TObject);
    procedure edtSGChange(Sender: TObject);
    procedure edtLVBChange(Sender: TObject);
    procedure ChangeColorModeClick(Sender: TObject);
    procedure btbtnOKClick(Sender: TObject);
    procedure ggbrFuzzinessChange(Sender: TObject);
  private
    FReplaceColorTool    : TgmReplaceColorTool;
    FChannelBmp          : TBitmap32;  // used to hold channel bitmap
    FThumbnail           : TBitmap32;
    FThumbnailDisplayMode: TgmThumbnailDisplayMode;
    FBarIsChanging       : Boolean;
    FEditIsChanging      : Boolean;
    FImageW, FImageH     : Integer;

    procedure SetColorMode(const Value: TgmSelectedColorMode);
    procedure UpdateColorModeByChannel;
    procedure UpdateChannelBitmap;
    procedure UpdateFormAppearance;
    procedure UpdateThumbnailDisplay;
    procedure ShowColorRange;

    procedure ReplaceColorOnSelection;
    procedure ReplaceColorOnAlphaChannel;
    procedure ReplaceColorOnQuickMask;
    procedure ReplaceColorOnLayerMask;
    procedure ReplaceColorOnLayer;
    procedure ExecuteColorReplacement;
  public
    { public declaration }
  end;

var
  frmReplaceColor: TfrmReplaceColor;

implementation

uses
{ Graphics32 }
  GR32_LowLevel,
{ GraphicsMagic Lib }
  gmTypes,
  gmIni,
  gmImageProcessFuncs,   // GrayscaleSelection()...
  gmColorSpace,          // RGBToHLS32()...
  gmLayerAndChannel,
  gmMath,
  gmCommands,
  gmHistoryManager,
  gmAlphaFuncs,
  gmGUIFuncs,
{ GraphicsMagic Data Modules }
  HistoryDataModule,
{ GraphicsMagic Forms/Dialogs }
  MainForm,              // frmMain
  HistoryForm;

{$R *.DFM}

const
  MIN_CHANGE_AMOUNT   : Integer = -100;
  MAX_CHANGE_AMOUNT   : Integer = 100;
  MID_VALUE           : Integer = 100;
  MIN_FUZZINESS_AMOUNT: Integer = 0;
  MAX_FUZZINESS_AMOUNT: Integer = 200;
  HUE_MAX_CHANGE_RANGE: Integer = 180;

//-- Custom Procedures and Functions -------------------------------------------

procedure TfrmReplaceColor.UpdateChannelBitmap;
var
  LColorChannelCount: Integer;
begin
  if ActiveChildForm.ChannelManager.CurrentChannelType in
       [wctRGB, wctRed, wctGreen, wctBlue] then
  begin
    LColorChannelCount := ActiveChildForm.ChannelManager.SelectedColorChannelCount;

    if LColorChannelCount = 1 then
    begin
      ExtractSingleChannelBitmap32(frmMain.FBeforeProc, FChannelBmp,
        ActiveChildForm.ChannelManager.ChannelSelectedSet)
    end
    else
    if LColorChannelCount = 3 then
    begin
      FChannelBmp.Assign(frmMain.FBeforeProc);
    end;
  end
  else
  begin
    FChannelBmp.Assign(frmMain.FBeforeProc);
  end;

  FReplaceColorTool.ChannelBitmap := FChannelBmp;
end;

procedure TfrmReplaceColor.UpdateFormAppearance;
begin
  case FReplaceColorTool.ColorMode of
    scmHLS:
      begin
        lblHR.Caption  := 'Hue:';
        lblSG.Caption  := 'Saturation:';
        lblLVB.Caption := 'Lightness:';
      end;

    scmHSV:
      begin
        lblHR.Caption  := 'Hue:';
        lblSG.Caption  := 'Saturation:';
        lblLVB.Caption := 'Value:';
      end;

    scmRGB:
      begin
        lblHR.Caption  := 'Red:';
        lblSG.Caption  := 'Green:';
        lblLVB.Caption := 'Blue:';
      end;
  end;

  if ActiveChildForm.ChannelManager.CurrentChannelType in
       [wctAlpha, wctQuickMask, wctLayerMask] then
  begin
    rdbtnHLS.Checked := True;
    rdbtnHSV.Enabled := False;
    rdbtnRGB.Enabled := False;

    lblHR.Enabled        := False;
    lblHRPercent.Enabled := False;
    edtHR.Enabled        := False;
    ggbrHR.Enabled       := False;
    edtHR.Color          := clBtnFace;

    lblSG.Enabled        := False;
    lblSGPercent.Enabled := False;
    edtSG.Enabled        := False;
    ggbrSG.Enabled       := False;
    edtSG.Color          := clbtnFace;
  end
  else
  begin
    // on layer...

    // if one color channel is selected...
    if ActiveChildForm.ChannelManager.SelectedColorChannelCount = 1 then
    begin
      rdbtnHLS.Checked := True;
      rdbtnHSV.Enabled := False;
      rdbtnRGB.Enabled := False;

      lblHR.Enabled        := False;
      lblHRPercent.Enabled := False;
      edtHR.Enabled        := False;
      ggbrHR.Enabled       := False;
      edtHR.Color          := clBtnFace;

      lblSG.Enabled        := False;
      lblSGPercent.Enabled := False;
      edtSG.Enabled        := False;
      ggbrSG.Enabled       := False;
      edtSG.Color          := clbtnFace;
    end
    else
    begin
      lblHR.Enabled        := True;
      lblHRPercent.Enabled := True;
      edtHR.Enabled        := True;
      ggbrHR.Enabled       := True;
      edtHR.Color          := clWindow;

      lblSG.Enabled        := True;
      lblSGPercent.Enabled := True;
      edtSG.Enabled        := True;
      ggbrSG.Enabled       := True;
      edtSG.Color          := clWindow;

      rdbtnHSV.Enabled := True;
      rdbtnRGB.Enabled := True;

      case FReplaceColorTool.ColorMode of
        scmRGB:
          begin
            rdbtnRGB.Checked := True;
          end;

        scmHLS:
          begin
            rdbtnHLS.Checked := True;
          end;

        scmHSV:
          begin
            rdbtnHSV.Checked := True;
          end;
      end;
    end;
  end;

  case FThumbnailDisplayMode of
    tdmSelection:
      begin
        rdbtnSelection.Checked := True;
      end;

    tdmImage:
      begin
        rdbtnImage.Checked := True;
      end;
  end;

  ggbrFuzziness.Position := FReplaceColorTool.Fuzziness;
  shpSample.Brush.Color  := WinColor(FReplaceColorTool.SelectedColor);
  chckbxPreview.Checked  := Boolean(StrToInt(ReadInfoFromIniFile(SECTION_REPLACE_COLOR_DIALOG, IDENT_REPLACE_COLOR_PREVIEW, '1')));
end;

procedure TfrmReplaceColor.UpdateThumbnailDisplay;
begin
  case FThumbnailDisplayMode of
    tdmSelection:
      begin
        FThumbnail.Assign(FReplaceColorTool.MaskBitmap);
      end;

    tdmImage:
      begin
        FThumbnail.Assign(FChannelBmp);
      end;
  end;

  FThumbnail.DrawMode := dmOpaque;
  img32Thumbnail.Bitmap.Assign(FThumbnail);
end;

procedure TfrmReplaceColor.ReplaceColorOnSelection;
begin
  with ActiveChildForm do
  begin
    // don't process on special layers
    if (ChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue]) and
       (not (LayerPanelList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent])) then
    begin
      Exit;
    end;

    FReplaceColorTool.Execute(frmMain.FBeforeProc, frmMain.FAfterProc,
                              ChannelManager.ChannelSelectedSet);

    if chckbxPreview.Checked then
    begin
      Selection.CutOriginal.Assign(frmMain.FAfterProc);
      ShowProcessedSelection;
    end;
  end;
end; 

procedure TfrmReplaceColor.ReplaceColorOnAlphaChannel;
begin
  with ActiveChildForm do
  begin
    FReplaceColorTool.Execute(frmMain.FBeforeProc, frmMain.FAfterProc,
                              ChannelManager.ChannelSelectedSet);

    if chckbxPreview.Checked then
    begin
      if Assigned(ChannelManager.SelectedAlphaChannelPanel) then
      begin
        ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Assign(frmMain.FAfterProc);
        ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
      end;
    end;
  end;
end;

procedure TfrmReplaceColor.ReplaceColorOnQuickMask;
begin
  with ActiveChildForm do
  begin
    FReplaceColorTool.Execute(frmMain.FBeforeProc, frmMain.FAfterProc,
                              ChannelManager.ChannelSelectedSet);

    if chckbxPreview.Checked then
    begin
      if Assigned(ChannelManager.QuickMaskPanel) then
      begin
        ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.Assign(frmMain.FAfterProc);
        ChannelManager.QuickMaskPanel.AlphaLayer.Changed;
      end;
    end;
  end;
end; 

procedure TfrmReplaceColor.ReplaceColorOnLayerMask;
begin
  with ActiveChildForm do
  begin
    FReplaceColorTool.Execute(frmMain.FBeforeProc, frmMain.FAfterProc,
                              ChannelManager.ChannelSelectedSet);

    if chckbxPreview.Checked then
    begin
      LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Assign(frmMain.FAfterProc);

      // update the layer mask channel
      if Assigned(ChannelManager.LayerMaskPanel) then
      begin
        ChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(0, 0,
          LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
      end;

      LayerPanelList.SelectedLayerPanel.Update;
    end;
  end;
end; 

procedure TfrmReplaceColor.ReplaceColorOnLayer;
begin
  with ActiveChildForm do
  begin
    FReplaceColorTool.Execute(frmMain.FBeforeProc, frmMain.FAfterProc,
                              ChannelManager.ChannelSelectedSet);

    if chckbxPreview.Checked then
    begin
      if LayerPanelList.SelectedLayerPanel.LayerFeature in [
           lfBackground, lfTransparent] then
      begin
        LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Assign(frmMain.FAfterProc);
        LayerPanelList.SelectedLayerPanel.Update;
      end;
    end;
  end;
end; 

procedure TfrmReplaceColor.ExecuteColorReplacement;
begin
  if Assigned(ActiveChildForm.Selection) then
  begin
    ReplaceColorOnSelection;
  end
  else
  begin
    case ActiveChildForm.ChannelManager.CurrentChannelType of
      wctAlpha:
        begin
          ReplaceColorOnAlphaChannel;
        end;

      wctQuickMask:
        begin
          ReplaceColorOnQuickMask;
        end;
        
      wctLayerMask:
        begin
          ReplaceColorOnLayerMask;
        end;
        
      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          ReplaceColorOnLayer;
        end;
    end;
  end;
end;

procedure TfrmReplaceColor.SetColorMode(const Value: TgmSelectedColorMode);
begin
  FReplaceColorTool.ColorMode := Value;
  FReplaceColorTool.Calc;

  // reset to the initial settings by modify the track bars
  ggbrHR.Position  := MID_VALUE;
  ggbrSG.Position  := MID_VALUE;
  ggbrLVB.Position := MID_VALUE;

  ShowColorRange;
  UpdateFormAppearance;
end; 

procedure TfrmReplaceColor.UpdateColorModeByChannel;
var
  LColorMode: TgmSelectedColorMode;
begin
  if ActiveChildForm.ChannelManager.CurrentChannelType in
       [wctAlpha, wctQuickMask, wctLayerMask] then
  begin
    SetColorMode(scmHLS);
  end
  else
  begin
    if ActiveChildForm.ChannelManager.SelectedColorChannelCount = 1 then
    begin
      SetColorMode(scmHLS);
    end
    else
    begin
      LColorMode := TgmSelectedColorMode(
        StrToInt(ReadInfoFromIniFile(SECTION_REPLACE_COLOR_DIALOG,
                                     IDENT_REPLACE_COLOR_SAMPLE_MODE, '0')) );

      SetColorMode(LColorMode);
    end;
  end;
end; 

procedure TfrmReplaceColor.ShowColorRange;
begin
  with FReplaceColorTool do
  begin
    case ColorMode of
      scmHLS:
        begin
          if ActiveChildForm.ChannelManager.CurrentChannelType = wctRGB then
          begin
            stsbrColorRange.Panels[0].Text :=
              Format('Color Range: ( H: %d to %d, L: %d to %d, S: %d to %d )',
                                     [MinHue, MaxHue,
                                      MinLuminosity, MaxLuminosity,
                                      MinSaturation, MaxSaturation]);
          end
          else
          begin
            stsbrColorRange.Panels[0].Text := Format('Lightness Range: ( %d to %d )',
                                                     [MinLuminosity, MaxLuminosity] );
          end;
        end;

      scmHSV:
        begin
          stsbrColorRange.Panels[0].Text :=
            Format('Color Range: ( H: %d to %d, S: %d to %d, V: %d to %d )',
                   [MinHue, MaxHue, MinSaturation, MaxSaturation, MinValue, MaxValue] );
        end;

      scmRGB:
        begin
          stsbrColorRange.Panels[0].Text :=
            Format('Color Range: ( R: %d to %d, G: %d to %d, B: %d to %d )',
                   [MinRed, MaxRed, MinGreen, MaxGreen, MinBlue, MaxBlue] );
        end;
    end;
  end;
end; 

//------------------------------------------------------------------------------

procedure TfrmReplaceColor.FormCreate(Sender: TObject);
begin
  FBarIsChanging        := False;
  FEditIsChanging       := False;
  FChannelBmp           := TBitmap32.Create;
  FThumbnail            := TBitmap32.Create;
  FThumbnailDisplayMode := TgmThumbnailDisplayMode(StrToInt(ReadInfoFromIniFile(SECTION_REPLACE_COLOR_DIALOG, IDENT_REPLACE_COLOR_THUMBNAIL_MODE, '0')));
  FImageW               := pnlThumbnail.Width  - 16;
  FImageH               := pnlThumbnail.Height - 16;

  FReplaceColorTool := TgmReplaceColorTool.Create;
  with FReplaceColorTool do
  begin
    Fuzziness     := StrToInt(ReadInfoFromIniFile(SECTION_REPLACE_COLOR_DIALOG, IDENT_REPLACE_COLOR_FUZZINESS, '10'));
    SelectedColor := Color32(TColor(StrToInt(ReadInfoFromIniFile(SECTION_REPLACE_COLOR_DIALOG, IDENT_REPLACE_COLOR_SAMPLE_COLOR, IntToStr(ColorToRGB(clWhite))))));

    if ActiveChildForm.ChannelManager.CurrentChannelType in
         [wctAlpha, wctQuickMask, wctLayerMask] then
    begin
      SelectedColor   := Gray32( Intensity(SelectedColor) );
      IsSingleChannel := True;
    end
    else
    begin
      if ActiveChildForm.ChannelManager.SelectedColorChannelCount = 1 then
      begin
        if csRed in ActiveChildForm.ChannelManager.ChannelSelectedSet then
        begin
          SelectedColor := Gray32( RedComponent(SelectedColor) );
        end;

        if csGreen in ActiveChildForm.ChannelManager.ChannelSelectedSet then
        begin
          SelectedColor := Gray32( GreenComponent(SelectedColor) );
        end;

        if csBlue in ActiveChildForm.ChannelManager.ChannelSelectedSet then
        begin
          SelectedColor := Gray32( BlueComponent(SelectedColor) );
        end;

        IsSingleChannel := True;
      end;
    end;
  end;
end;

procedure TfrmReplaceColor.FormDestroy(Sender: TObject);
begin
  FChannelBmp.Free;
  FThumbnail.Free;
  FReplaceColorTool.Free;
end; 

procedure TfrmReplaceColor.FormShow(Sender: TObject);
var
  LTempBmp: TBitmap32;
begin
  img32Thumbnail.Width  := 200;
  img32Thumbnail.Height := 200;

  if Assigned(ActiveChildForm.Selection) then
  begin
    frmMain.FBeforeProc.Assign(ActiveChildForm.Selection.CutOriginal);
    frmMain.FAfterProc.Assign(ActiveChildForm.Selection.CutOriginal);

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
            frmMain.FBeforeProc.Assign(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
            frmMain.FAfterProc.Assign(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
          end;
        end;

      wctQuickMask:
        begin
          if Assigned(ActiveChildForm.ChannelManager.QuickMaskPanel) then
          begin
            frmMain.FBeforeProc.Assign(ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
            frmMain.FAfterProc.Assign(ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
          end;
        end;

      wctLayerMask:
        begin
          frmMain.FBeforeProc.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
          frmMain.FAfterProc.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
        end;

      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
               lfBackground, lfTransparent] then
          begin
            LTempBmp := TBitmap32.Create;
            try
              LTempBmp.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

              if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsMaskLinked then
              begin
                ReplaceAlphaChannelWithMask(LTempBmp,
                  ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
              end;

              frmMain.FBeforeProc.Assign(LTempBmp);
              frmMain.FAfterProc.Assign(LTempBmp);
            finally
              LTempBmp.Free;
            end;
          end;
        end;
    end;
  end;

  UpdateChannelBitmap;
  UpdateColorModeByChannel;
  
  UpdateThumbnailDisplay;
  ScaleImage32(FThumbnail, img32Thumbnail, FImageW, FImageH);
  CenterImageInPanel(pnlThumbnail, img32Thumbnail);
end;

procedure TfrmReplaceColor.rdbtnSelectionClick(Sender: TObject);
begin
  FThumbnailDisplayMode := tdmSelection;
  UpdateThumbnailDisplay;
end;

procedure TfrmReplaceColor.rdbtnImageClick(Sender: TObject);
begin
  FThumbnailDisplayMode := tdmImage;
  UpdateThumbnailDisplay;
end; 

procedure TfrmReplaceColor.img32ThumbnailMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  XActual, YActual: Integer;
begin
  XActual := MulDiv(X, frmMain.FBeforeProc.Width, img32Thumbnail.Width);
  YActual := MulDiv(Y, frmMain.FBeforeProc.Height, img32Thumbnail.Height);

  FReplaceColorTool.SelectedColor := FChannelBmp.Pixel[XActual, YActual];
  FReplaceColorTool.Calc;

  shpSample.Brush.Color := WinColor(FReplaceColorTool.SelectedColor);

  UpdateThumbnailDisplay;
  ShowColorRange;

  ExecuteColorReplacement;
end; 

procedure TfrmReplaceColor.ChangeColor(Sender: TObject);
var
  ChangedAmount: Integer;
begin
  FBarIsChanging := True;
  try
    if Sender = ggbrHR then
    begin
      ChangedAmount := ggbrHR.Position - MID_VALUE;

      if FEditIsChanging
      then edtHR.Text := IntToStr(ChangedAmount)
      else
      begin
        if ChangedAmount > 0
        then edtHR.Text := '+' + IntToStr(ChangedAmount)
        else edtHR.Text := IntToStr(ChangedAmount);
      end;

      if FReplaceColorTool.ColorMode = scmRGB
      then FReplaceColorTool.RedChangeAmount := MulDiv(ChangedAmount, 255, 100)
      else FReplaceColorTool.HueChangeAmount := MulDiv(ChangedAmount, HUE_MAX_CHANGE_RANGE, 100);
    end
    else
    if Sender = ggbrSG then
    begin
      ChangedAmount := ggbrSG.Position - MID_VALUE;

      if FEditIsChanging
      then edtSG.Text := IntToStr(ChangedAmount)
      else
      begin
        if ChangedAmount > 0
        then edtSG.Text := '+' + IntToStr(ChangedAmount)
        else edtSG.Text := IntToStr(ChangedAmount);
      end;

      if FReplaceColorTool.ColorMode = scmRGB
      then FReplaceColorTool.GreenChangeAmount      := MulDiv(ChangedAmount, 255, 100)
      else FReplaceColorTool.SaturationChangeAmount := MulDiv(ChangedAmount, 255, 100);
    end
    else
    if Sender = ggbrLVB then
    begin
      ChangedAmount := ggbrLVB.Position - MID_VALUE;

      if FEditIsChanging
      then edtLVB.Text := IntToStr(ChangedAmount)
      else
      begin
        if ChangedAmount > 0
        then edtLVB.Text := '+' + IntToStr(ChangedAmount)
        else edtLVB.Text := IntToStr(ChangedAmount);
      end;

      case FReplaceColorTool.ColorMode of
        scmHLS: FReplaceColorTool.LuminosityChangeAmount := MulDiv(ChangedAmount, 255, 100);
        scmHSV: FReplaceColorTool.ValueChangeAmount      := MulDiv(ChangedAmount, 255, 100);
        scmRGB: FReplaceColorTool.BlueChangeAmount       := MulDiv(ChangedAmount, 255, 100);
      end;
    end;

    FReplaceColorTool.Calc;
    ExecuteColorReplacement;
  finally
    FBarIsChanging := False;
  end;
end;

procedure TfrmReplaceColor.img32ThumbnailMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
var
  LXActual, LYActual    : Integer;
  R, G, B, H, L, S, V, A: Integer;
  LColor                : TColor32;
begin
  LXActual := MulDiv(X, frmMain.FBeforeProc.Width, img32Thumbnail.Width);
  LYActual := MulDiv(Y, frmMain.FBeforeProc.Height, img32Thumbnail.Height);
  LColor   := FChannelBmp.Pixel[LXActual, LYActual];
  A        := LColor shr 24 and $FF;

  case FReplaceColorTool.ColorMode of
    scmHLS:
      begin
        if ActiveChildForm.ChannelManager.CurrentChannelType = wctRGB then
        begin
          RGBToHLS32(LColor, H, L, S);
          S := Clamp(S, 1, 255);

          stsbrCurrentColor.Panels[0].Text := Format('Current Color: ( Alpha: %d, H: %d, L: %d, S: %d )',
                                                     [A, H, L, S] );
        end
        else
        begin
          L := RGBToLightness32(LColor);

          stsbrCurrentColor.Panels[0].Text := 'Current Lightness: ' + IntToStr(L);
        end;
      end;

    scmHSV:
      begin
        RGBToHSV32(LColor, H, S, V);

        stsbrCurrentColor.Panels[0].Text := Format('Current Color: ( Alpha: %d, H: %d, S: %d, V: %d )',
                                                   [A, H, S, V] );
      end;

    scmRGB:
      begin
        R := LColor shr 16 and $FF;
        G := LColor shr 8  and $FF;
        B := LColor        and $FF;

        stsbrCurrentColor.Panels[0].Text := Format('Current Color: ( Alpha: %d, R: %d, G: %d, B: %d )',
                                                   [A, R, G, B] );
      end;
  end;
end;

procedure TfrmReplaceColor.chckbxPreviewClick(Sender: TObject);
begin
  ExecuteColorReplacement;
end; 

procedure TfrmReplaceColor.edtFuzzinessChange(Sender: TObject);
var
  ChangedValue: Integer;
begin
  if not FBarIsChanging then
  begin
    try
      ChangedValue := StrToInt(edtFuzziness.Text);
      EnsureValueInRange(ChangedValue, MIN_FUZZINESS_AMOUNT, MAX_FUZZINESS_AMOUNT);
      ggbrFuzziness.Position := ChangedValue;
    except
      edtFuzziness.Text := IntToStr(FReplaceColorTool.Fuzziness);
    end;
  end;
end; 

procedure TfrmReplaceColor.edtHRChange(Sender: TObject);
var
  ChangedValue: Integer;
begin
  if not FBarIsChanging then
  begin
    FEditIsChanging := True;
    try
    
      try
        ChangedValue := StrToInt(edtHR.Text);

        EnsureValueInRange(ChangedValue, MIN_CHANGE_AMOUNT, MAX_CHANGE_AMOUNT);
        ggbrHR.Position := MID_VALUE + ChangedValue;
      except
        // convert the change amount to bar position
        if FReplaceColorTool.ColorMode = scmRGB
        then edtHR.Text := IntToStr( MulDiv(FReplaceColorTool.RedChangeAmount, 100, 255) )
        else edtHR.Text := IntToStr( MulDiv(FReplaceColorTool.HueChangeAmount, 100, HUE_MAX_CHANGE_RANGE) );
      end;

    finally
      FEditIsChanging := False;
    end;
  end;
end; 

procedure TfrmReplaceColor.edtSGChange(Sender: TObject);
var
  ChangedValue: Integer;
begin
  if not FBarIsChanging then
  begin
    FEditIsChanging := True;
    try

      try
        ChangedValue := StrToInt(edtSG.Text);
        EnsureValueInRange(ChangedValue, MIN_CHANGE_AMOUNT, MAX_CHANGE_AMOUNT);
        ggbrSG.Position := MID_VALUE + ChangedValue;
      except
        // convert the change amount to bar position
        if FReplaceColorTool.ColorMode = scmRGB
        then edtSG.Text := IntToStr( MulDiv(FReplaceColorTool.GreenChangeAmount, 100, 255) )
        else edtSG.Text := IntToStr( MulDiv(FReplaceColorTool.SaturationChangeAmount, 100, 255) );
      end;

    finally
      FEditIsChanging := False;
    end;
  end;
end; 

procedure TfrmReplaceColor.edtLVBChange(Sender: TObject);
var
  ChangedValue: Integer;
begin
  if not FBarIsChanging then
  begin
    FEditIsChanging := True;
    try

      try
        ChangedValue := StrToInt(edtLVB.Text);
        EnsureValueInRange(ChangedValue, MIN_CHANGE_AMOUNT, MAX_CHANGE_AMOUNT);
        ggbrLVB.Position := MID_VALUE + ChangedValue;
      except
        // convert the change amount to bar position
        case FReplaceColorTool.ColorMode of
          scmHLS: edtLVB.Text := IntToStr( MulDiv(FReplaceColorTool.LuminosityChangeAmount, 100, 255) );
          scmHSV: edtLVB.Text := IntToStr( MulDiv(FReplaceColorTool.ValueChangeAmount, 100, 255) );
          scmRGB: edtLVB.Text := IntToStr( MulDiv(FReplaceColorTool.BlueChangeAmount, 100, 255) );
        end;
      end;

    finally
      FEditIsChanging := False;
    end;
  end;
end; 

procedure TfrmReplaceColor.ChangeColorModeClick(Sender: TObject);
var
  SelectedColorMode: TgmSelectedColorMode;
begin
  SelectedColorMode := scmRGB;

  if Sender = rdbtnHLS then
    SelectedColorMode := scmHLS
  else if Sender = rdbtnHSV then
    SelectedColorMode := scmHSV
  else if Sender = rdbtnRGB then
    SelectedColorMode := scmRGB;

  SetColorMode(SelectedColorMode);
  UpdateThumbnailDisplay;
end; 

procedure TfrmReplaceColor.btbtnOKClick(Sender: TObject);
var
  LCmdAim           : TCommandAim;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  // the processed result is stored in frmMain.FAfterProc
  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsMaskLinked then
  begin
    if (ActiveChildForm.LayerPaneLList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent]) and
       (ActiveChildForm.ChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue]) then
    begin
      ReplaceAlphaChannelWithMask(frmMain.FAfterProc,
        ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
    end;
  end;

  LCmdAim := ActiveChildForm.GetCommandAimByCurrentChannel;

  LHistoryStatePanel := TgmImageManipulatingStatePanel.Create(
    frmHistory.scrlbxHistory,
    dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
    LCmdAim,
    'Replace Color',
    frmMain.FBeforeProc,
    frmMain.FAfterProc,
    ActiveChildForm.Selection,
    ActiveChildForm.ChannelManager.SelectedAlphaChannelIndex);

  ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);

  // save settings
  WriteInfoToIniFile(SECTION_REPLACE_COLOR_DIALOG, IDENT_REPLACE_COLOR_THUMBNAIL_MODE, IntToStr(Ord(FThumbnailDisplayMode)));
  WriteInfoToIniFile(SECTION_REPLACE_COLOR_DIALOG, IDENT_REPLACE_COLOR_SAMPLE_MODE, IntToStr(Ord(FReplaceColorTool.ColorMode)));
  WriteInfoToIniFile(SECTION_REPLACE_COLOR_DIALOG, IDENT_REPLACE_COLOR_SAMPLE_COLOR, IntToStr(Integer(WinColor(FReplaceColorTool.SelectedColor))));
  WriteInfoToIniFile(SECTION_REPLACE_COLOR_DIALOG, IDENT_REPLACE_COLOR_FUZZINESS, IntToStr(FReplaceColorTool.Fuzziness));
  WriteInfoToIniFile(SECTION_REPLACE_COLOR_DIALOG, IDENT_REPLACE_COLOR_PREVIEW, IntToStr(Integer(chckbxPreview.Checked)));
end;

procedure TfrmReplaceColor.ggbrFuzzinessChange(Sender: TObject);
var
  ChangedFuzziness: Integer;
begin
  FBarIsChanging := True;
  try
    ChangedFuzziness  := ggbrFuzziness.Position;
    edtFuzziness.Text := IntToStr(ChangedFuzziness);

    if FReplaceColorTool.Fuzziness <> ChangedFuzziness then
    begin
      FReplaceColorTool.Fuzziness := ChangedFuzziness;
      FReplaceColorTool.Calc;
      UpdateThumbnailDisplay;
      ShowColorRange;
      ExecuteColorReplacement;
    end;
  finally
    FBarIsChanging := False;
  end;
end; 

end.
