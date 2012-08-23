{ This library created in 07/09/2006.
  CopyRight(C) 2006, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved.

  Based on the the Gimp 2.2.10 .
  The original source can be found at www.gimp.org.

  Thanks to the authors of GIMP for giving us the opportunity to know how to
  achieve Levels Tool.

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

unit LevelsToolDlg;

interface

uses
{ Standard Lib }
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, ImgList, ComCtrls, ToolWin, 
{ Graphics32 Lib }
  GR32, GR32_Image, GR32_Layers,
{ GraphicsMagic Lib }
  gmLevelsTool,
  gmGimpColorBar,
  gmGimpHistogram;

type
  TfrmLevelsTool = class(TForm)
    GroupBox1: TGroupBox;
    lblChannel: TLabel;
    cmbbxChannel: TComboBox;
    btnResetChannel: TButton;
    spdbtnLinearHistogram: TSpeedButton;
    spdbtnLogarithmicHistogram: TSpeedButton;
    lblInputLevels: TLabel;
    pnlHistogramHolder: TPanel;
    imgHistogram: TImage32;
    ImageList1: TImageList;
    pnlInputArea: TPanel;
    imgInputBar: TImage32;
    edtLevelsLowInput: TEdit;
    updwnLevelsLowInput: TUpDown;
    edtLevelsGamma: TEdit;
    updwnLevelsGamma: TUpDown;
    edtLevelsHighInput: TEdit;
    updwnLevelsHighInput: TUpDown;
    lblOutputLevels: TLabel;
    pnlOutputArea: TPanel;
    imgOutputBar: TImage32;
    edtLevelsLowOutput: TEdit;
    updwnLevelsLowOutput: TUpDown;
    edtLevelsHighOutput: TEdit;
    updwnLevelsHighOutput: TUpDown;
    btbtnOK: TBitBtn;
    btbtnCancel: TBitBtn;
    btnResetLevelsTool: TButton;
    btnAutoAdjustment: TButton;
    chckbxPreview: TCheckBox;
    ToolBar1: TToolBar;
    tlbtnBlackPicker: TToolButton;
    tlbtnGrayPicker: TToolButton;
    tlbtnWhitePicker: TToolButton;
    btnLoadLevels: TButton;
    btnSaveLevels: TButton;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure imgInputBarMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure imgInputBarMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer; Layer: TCustomLayer);
    procedure imgInputBarMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure updwnLevelsGammaClick(Sender: TObject; Button: TUDBtnType);
    procedure updwnLevelsGammaMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure imgOutputBarMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure imgOutputBarMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer; Layer: TCustomLayer);
    procedure imgOutputBarMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure edtLevelsLowInputChange(Sender: TObject);
    procedure edtLevelsHighInputChange(Sender: TObject);
    procedure edtLevelsLowOutputChange(Sender: TObject);
    procedure edtLevelsHighOutputChange(Sender: TObject);
    procedure ChangeLevelsChannel(Sender: TObject);
    procedure ChangeHistogramType(Sender: TObject);
    procedure ResetChannel(Sender: TObject);
    procedure chckbxPreviewClick(Sender: TObject);
    procedure ResetLevelsTool(Sender: TObject);
    procedure updwnLevelsLowInputMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure updwnLevelsHighInputMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure updwnLevelsLowOutputMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure updwnLevelsHighOutputMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure btnAutoAdjustmentClick(Sender: TObject);
    procedure ChangeActivePicker(Sender: TObject);
    procedure btbtnOKClick(Sender: TObject);
    procedure btnLoadLevelsClick(Sender: TObject);
    procedure btnSaveLevelsClick(Sender: TObject);
  private
    FNormalLevelsTool    : TgmLevelsTool;       // Created for normal layer...
    FHistogram           : TgmGimpHistogram;
    FDrawing             : Boolean;
    FInputColorBarBmp    : TBitmap32;
    FOutputColorBarBmp   : TBitmap32;
    FCanChange           : Boolean;
    FLevelsFileName      : string;              // opened levels file name
    FWorkingOnEffectLayer: Boolean;

    procedure UpdateLevelsInput(X: Integer);
    procedure UpdateLevelsOutput(X: Integer);
    procedure ExecuteLevelsOnSelection;
    procedure ExecuteLevelsOnAlphaChannel;
    procedure ExecuteLevelsOnQuickMask;
    procedure ExecuteLevelsOnLayerMask;
    procedure ExecuteLevelsOnLayer;
    procedure ChangeChannelItems; // change the items in the Channel combobox
    procedure UpdateChannelComboBoxHint;
  public
    FLevelsTool: TgmLevelsTool;  // Points to normal or levels layer.
    FColorBar  : TgmGimpColorBar;
    
    procedure LevelsUpdate(const UpdateItems: Integer);
    procedure ExecuteGimpLevels;

    property IsWorkingOnEffectLayer: Boolean read FWorkingOnEffectLayer write FWorkingOnEffectLayer;
  end;

var
  frmLevelsTool: TfrmLevelsTool;

implementation

uses
{ Standard }
  Math, 
{ Graphics32 }
  GR32_Backends,
{ GraphicsMagic Lib }
  gmTypes,
  gmIni,
  gmGimpCommonFuncs,
  gmGimpBaseEnums,
  gmLevels,
  gmLayerAndChannel,
  gmAlphaFuncs,
  gmCommands,
  gmHistoryManager,
{ GraphicsMagic Data Modules }
  HistoryDataModule,
{ GraphicsMagic Forms/Dialogs }
  MainForm,
  HistoryForm,
  ImageColorPickerForm;

{$R *.dfm}

const
  UP_DOWN_GAMMA_MAX  = 100;
  UP_DOWN_GAMMA_MIN  = 1;
  UP_DOWN_GAMMA_INIT = 10;

procedure TfrmLevelsTool.UpdateLevelsInput(X: Integer);
var
  Delta, Mid, Tmp: Double;
  Width          : Integer;
begin
  if FLevelsTool <> nil then
  begin
    Width := imgInputBar.Width - 2 * BORDER;

    if Width < 1 then
    begin
      Exit;
    end;

    case FLevelsTool.ActiveSlider of
      0:  // low input
        begin
          Tmp := (X - BORDER) / Width * 255.0;
          FLevelsTool.LevelsLowInput := CLAMP(Tmp, 0, FLevelsTool.LevelsHighInput);
        end;

      1:  // gamma
        begin
          Delta := (FLevelsTool.SliderPos[2] - FLevelsTool.SliderPos[0]) / 2.0;
          Mid   := FLevelsTool.SliderPos[0] + Delta;

          X   := CLAMP(X, FLevelsTool.SliderPos[0], FLevelsTool.SliderPos[2]);
          Tmp := (X - Mid) / Delta;

          FLevelsTool.LevelsGamma := 1.0 / Power(10, Tmp);
          //  round the gamma value to the nearest 1/100th  */
          FLevelsTool.LevelsGamma := RoundTo(FLevelsTool.LevelsGamma, -2);
        end;

      2:  // high input
        begin
          Tmp := (X - BORDER) / Width * 255.0;
          FLevelsTool.LevelsHighInput := CLAMP(Tmp, FLevelsTool.LevelsLowInput, 255);
        end;
    end;

    LevelsUpdate(INPUT_SLIDERS or INPUT_LEVELS);
  end;
end;

procedure TfrmLevelsTool.UpdateLevelsOutput(X: Integer);
var
  Tmp  : Double;
  Width: Integer;
begin
  if FLevelsTool <> nil then
  begin
    Width := imgOutputBar.Width - 2 * BORDER;

    if Width < 1 then
    begin
      Exit;
    end;

    case FLevelsTool.ActiveSlider of
      3:  // low output
        begin
          Tmp := (X - BORDER) / Width * 255.0;
          FLevelsTool.LevelsLowOutput := CLAMP(Tmp, 0, 255);
        end;

      4:  // high output
        begin
          Tmp := (X - BORDER) / Width * 255.0;
          FLevelsTool.LevelsHighOutput := CLAMP(Tmp, 0, 255);
        end;
    end;

    LevelsUpdate(OUTPUT_SLIDERS);
  end;
end; 

procedure TfrmLevelsTool.ExecuteLevelsOnSelection;
begin
  with ActiveChildForm do
  begin
    if ChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue] then
    begin
      // don't process on special layers
      if not (LayerPanelList.SelectedLayerPanel.LayerFeature in [
                lfBackground, lfTransparent]) then
      begin
        Exit;
      end;
    end;

    FLevelsTool.Map(frmMain.FAfterProc, ChannelManager.ChannelSelectedSet);

    if chckbxPreview.Checked then
    begin
      Selection.CutOriginal.Assign(frmMain.FAfterProc);
      ShowProcessedSelection;
    end;
  end;
end; 

procedure TfrmLevelsTool.ExecuteLevelsOnAlphaChannel;
begin
  if Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
  begin
    FLevelsTool.Map(frmMain.FAfterProc, ActiveChildForm.ChannelManager.ChannelSelectedSet);

    if chckbxPreview.Checked then
    begin
      ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Assign(frmMain.FAfterProc);
      ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
    end;
  end;
end;

procedure TfrmLevelsTool.ExecuteLevelsOnQuickMask;
begin
  if Assigned(ActiveChildForm.ChannelManager.QuickMaskPanel) then
  begin
    FLevelsTool.Map(frmMain.FAfterProc, ActiveChildForm.ChannelManager.ChannelSelectedSet);

    if chckbxPreview.Checked then
    begin
      ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.Assign(frmMain.FAfterProc);
      ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Changed;
    end;
  end;
end; 

// do process on mask
procedure TfrmLevelsTool.ExecuteLevelsOnLayerMask;
begin
  with ActiveChildForm do
  begin
    FLevelsTool.Map(frmMain.FAfterProc, ChannelManager.ChannelSelectedSet);

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

procedure TfrmLevelsTool.ExecuteLevelsOnLayer;
begin
  with ActiveChildForm do
  begin
    if LayerPanelList.SelectedLayerPanel.LayerFeature in [
         lfBackground, lfTransparent] then
    begin
      FLevelsTool.Map(frmMain.FAfterProc, ChannelManager.ChannelSelectedSet);
    end;

    if chckbxPreview.Checked then
    begin
      if (LayerPanelList.SelectedLayerPanel.LayerFeature = lfLevels) and
         FWorkingOnEffectLayer then
      begin
        FLevelsTool.LUTSetup(3);
        LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
      end
      else
      begin
        if not LayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
        begin
          LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Assign(frmMain.FAfterProc);
          LayerPanelList.SelectedLayerPanel.Update;
        end;
      end;
    end;
  end;
end; 

// Change the items in the Channel combobox.
procedure TfrmLevelsTool.ChangeChannelItems;
begin
  cmbbxChannel.Items.Clear;

  if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfLevels) and
     FWorkingOnEffectLayer then
  begin
    cmbbxChannel.Items.Add('Value');
    cmbbxChannel.Items.Add('Red');
    cmbbxChannel.Items.Add('Green');
    cmbbxChannel.Items.Add('Blue');
  end
  else
  begin
    case ActiveChildForm.ChannelManager.CurrentChannelType of
      wctAlpha:
        begin
          if Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
          begin
            cmbbxChannel.Items.Add(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.ChannelName);
          end;
        end;

      wctQuickMask:
        begin
          if Assigned(ActiveChildForm.ChannelManager.QuickMaskPanel) then
          begin
            cmbbxChannel.Items.Add('Quick Mask');
          end;
        end;

      wctLayerMask:
        begin
          if Assigned(ActiveChildForm.ChannelManager.LayerMaskPanel) then
          begin
            cmbbxChannel.Items.Add(ActiveChildForm.ChannelManager.LayerMaskPanel.ChannelName);
          end;
        end;

      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          cmbbxChannel.Items.Add('Value');
          cmbbxChannel.Items.Add('Red');
          cmbbxChannel.Items.Add('Green');
          cmbbxChannel.Items.Add('Blue');
        end;
    end;
  end;

  cmbbxChannel.ItemIndex := FLevelsTool.Channel;

  UpdateChannelComboBoxHint;
end; 

procedure TfrmLevelsTool.UpdateChannelComboBoxHint;
begin
  if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfLevels) and
     FWorkingOnEffectLayer then
  begin
    case cmbbxChannel.ItemIndex of
      0:
        begin
          cmbbxChannel.Hint := 'Value';
        end;
        
      1:
        begin
          cmbbxChannel.Hint := 'Red Channel';
        end;
        
      2:
        begin
          cmbbxChannel.Hint := 'Green Channel';
        end;
        
      3:
        begin
          cmbbxChannel.Hint := 'Blue Channel';
        end;
    end;
  end
  else
  begin
    case ActiveChildForm.ChannelManager.CurrentChannelType of
      wctAlpha:
        begin
          if Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
          begin
            cmbbxChannel.Hint := ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.ChannelName;
          end;
        end;

      wctQuickMask:
        begin
          if Assigned(ActiveChildForm.ChannelManager.QuickMaskPanel) then
          begin
            cmbbxChannel.Hint := 'Quick Mask';
          end;
        end;

      wctLayerMask:
        begin
          if Assigned(ActiveChildForm.ChannelManager.LayerMaskPanel) then
          begin
            cmbbxChannel.Hint := ActiveChildForm.ChannelManager.LayerMaskPanel.ChannelName;
          end;
        end;

      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          case cmbbxChannel.ItemIndex of
            0:
              begin
                cmbbxChannel.Hint := 'Value';
              end;

            1:
              begin
                cmbbxChannel.Hint := 'Red Channel';
              end;

            2:
              begin
                cmbbxChannel.Hint := 'Green Channel';
              end;
              
            3:
              begin
                cmbbxChannel.Hint := 'Blue Channel';
              end;
          end;
        end;
    end;
  end;
end; 

procedure TfrmLevelsTool.LevelsUpdate(const UpdateItems: Integer);
var
  LChannel: Integer;
  LRect  : TRect;
begin
  if FLevelsTool <> nil then
  begin
    if FLevelsTool.IsColored then
    begin
      LChannel := FLevelsTool.Channel;
    end
    else
    begin
      // FIXME: hack
      if FLevelsTool.Channel = 1 then
      begin
        LChannel := GIMP_HISTOGRAM_ALPHA;
      end
      else
      begin
        LChannel := GIMP_HISTOGRAM_VALUE;
      end;
    end;

    // Recalculate the transfer arrays
    FLevelsTool.LevelsCalculateTransfers;

    FCanChange := False; // Don't execute the OnChange event of the following components temporarily.
    try
      if (UpdateItems and LOW_INPUT) <> 0 then
      begin
        updwnLevelsLowInput.Position := FLevelsTool.LevelsLowInput;
      end;

      if (UpdateItems and GAMMA) <> 0 then
      begin
        updwnLevelsGamma.Position := Round( (FLevelsTool.LevelsGamma - 1.0) * 10 ) + UP_DOWN_GAMMA_INIT;
        edtLevelsGamma.Text       := FloatToStr(FLevelsTool.LevelsGamma);
      end;

      if (UpdateItems and HIGH_INPUT) <> 0 then
      begin
        updwnLevelsHighInput.Position := FLevelsTool.LevelsHighInput;
      end;

      if (UpdateItems and LOW_OUTPUT) <> 0 then
      begin
        updwnLevelsLowOutput.Position := FLevelsTool.LevelsLowOutput;
      end;

      if (UpdateItems and HIGH_OUTPUT) <> 0 then
      begin
        updwnLevelsHighOutput.Position := FLevelsTool.LevelsHighOutput;
      end;
    finally
      FCanChange := True;
    end;

    if FColorBar <> nil then
    begin
      FColorBar.Channel := LChannel;
    end;

    if (UpdateItems and INPUT_LEVELS) <> 0 then
    begin
      imgInputBar.Bitmap.Canvas.Brush.Color := clBtnFace;
      imgInputBar.Bitmap.Canvas.FillRect(imgInputBar.Bitmap.Canvas.ClipRect);

      case LChannel of
        GIMP_HISTOGRAM_VALUE, GIMP_HISTOGRAM_ALPHA, GIMP_HISTOGRAM_RGB:
          begin
            FColorBar.gimp_color_bar_set_buffers(
              FLevelsTool.Levels.FInput[FLevelsTool.Channel],
              FLevelsTool.Levels.FInput[FLevelsTool.Channel],
              FLevelsTool.Levels.FInput[FLevelsTool.Channel]);
          end;

        GIMP_HISTOGRAM_RED, GIMP_HISTOGRAM_GREEN, GIMP_HISTOGRAM_BLUE:
          begin
            FColorBar.gimp_color_bar_set_buffers(
              FLevelsTool.Levels.FInput[GIMP_HISTOGRAM_RED],
              FLevelsTool.Levels.FInput[GIMP_HISTOGRAM_GREEN],
              FLevelsTool.Levels.FInput[GIMP_HISTOGRAM_BLUE]);
          end;
      end;
      
      FColorBar.gimp_color_bar_expose(FInputColorBarBmp);
      imgInputBar.Bitmap.Draw(BORDER, 0, FInputColorBarBmp);
    end;

    if (UpdateItems and OUTPUT_LEVELS) <> 0 then
    begin
      imgOutputBar.Bitmap.Canvas.Brush.Color := clBtnFace;
      imgOutputBar.Bitmap.Canvas.FillRect(imgOutputBar.Bitmap.Canvas.ClipRect);

      FColorBar.IsHalfProcess := False;    // Draw all the height of Color Bar
      FColorBar.Channel       := LChannel;

      FColorBar.gimp_color_bar_expose(FOutputColorBarBmp);
      imgOutputBar.Bitmap.Draw(BORDER, 0, FOutputColorBarBmp);
    end;

    if (UpdateItems and INPUT_SLIDERS) <> 0 then
    begin
      LRect.Left   := 0;
      LRect.Top    := GRADIENT_HEIGHT;
      LRect.Right  := imgInputBar.Width;
      LRect.Bottom := imgInputBar.Height;

      // Clear the old slider.
      imgInputBar.Bitmap.Canvas.Brush.Color := clBtnFace;
      imgInPutBar.Bitmap.Canvas.FillRect(LRect);

      // Draw the new one.
      FLevelsTool.LevelsInputAreaExpose(imgInputBar.Bitmap.Canvas, BORDER);
    end;

    if (UpdateItems and OUTPUT_SLIDERS) <> 0 then
    begin
      LRect.Left   := 0;
      LRect.Top    := GRADIENT_HEIGHT;
      LRect.Right  := imgOutputBar.Width;
      LRect.Bottom := imgOutputBar.Height;

      // Clear the old slider.
      imgOutputBar.Bitmap.Canvas.Brush.Color := clBtnFace;
      imgOutPutBar.Bitmap.Canvas.FillRect(LRect);

      // Draw the new one.
      FLevelsTool.LevelsOutputAreaExpose(imgOutputBar.Bitmap.Canvas, BORDER);
    end;
  end;
end; 

procedure TfrmLevelsTool.ExecuteGimpLevels;
begin
  if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfLevels) and
     FWorkingOnEffectLayer then
  begin
    ExecuteLevelsOnLayer;
  end
  else
  begin
    if Assigned(ActiveChildForm.Selection) then
    begin
      ExecuteLevelsOnSelection;
    end
    else
    begin
      case ActiveChildForm.ChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            ExecuteLevelsOnAlphaChannel;
          end;
          
        wctQuickMask:
          begin
            ExecuteLevelsOnQuickMask;
          end;
          
        wctLayerMask:
          begin
            ExecuteLevelsOnLayerMask;
          end;
          
        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            ExecuteLevelsOnLayer;
          end;
      end;
    end;
  end;
end; 

procedure TfrmLevelsTool.FormCreate(Sender: TObject);
begin
  FWorkingOnEffectLayer := False;
  FLevelsFileName       := '';
  FNormalLevelsTool     := nil;
  FLevelsTool           := nil;

  FColorBar            := TgmGimpColorBar.Create;
  FHistogram           := TgmGimpHistogram.Create;
  FHistogram.LineColor := clBlack;
  FHistogram.Scale     := TgmGimpHistogramScale(StrToInt(ReadInfoFromIniFile(SECTION_LEVELS_DIALOG, IDENT_LEVELS_HISTOGRAM, '0')));
  
  FDrawing           := False;
  FCanChange         := True;
  FInputColorBarBmp  := TBitmap32.Create;
  FOutputColorBarBmp := TBitmap32.Create;

  with updwnLevelsGamma do
  begin
    Max      := UP_DOWN_GAMMA_MAX;
    Min      := UP_DOWN_GAMMA_MIN;
    Position := UP_DOWN_GAMMA_INIT;
  end;

  spdbtnLinearHistogram.Down      := (FHistogram.Scale = GIMP_HISTOGRAM_SCALE_LINEAR);
  spdbtnLogarithmicHistogram.Down := (FHistogram.Scale = GIMP_HISTOGRAM_SCALE_LOGARITHMIC);
end;

procedure TfrmLevelsTool.FormDestroy(Sender: TObject);
begin
  if Assigned(FNormalLevelsTool) then
  begin
    FNormalLevelsTool.Free;
  end;

  if Assigned(FColorBar) then
  begin
    FColorBar.Free;
  end;

  if Assigned(FHistogram) then
  begin
    FHistogram.Free;
  end;

  FInputColorBarBmp.Free;
  FOutputColorBarBmp.Free;
end; 

procedure TfrmLevelsTool.FormShow(Sender: TObject);
var
  LLevelsLayerPanel: TgmLevelsLayerPanel;
  LTempBmp         : TBitmap32;
begin
  imgInputBar.Bitmap.Width  := imgInputBar.Width;
  imgInputBar.Bitmap.Height := GRADIENT_HEIGHT  + CONTROL_HEIGHT;
  pnlInputArea.Width        := imgInputBar.Width  + 4;
  pnlInputArea.Height       := imgInputBar.Height + 4;

  imgOutputBar.Bitmap.Width  := imgOutputBar.Width;
  imgOutputBar.Bitmap.Height := GRADIENT_HEIGHT   + CONTROL_HEIGHT;
  pnlOutputArea.Width        := imgOutputBar.Width  + 4;
  pnlOutputArea.Height       := imgOutputBar.Height + 4;

  imgHistogram.Width  := pnlHistogramHolder.Width - 2 * BORDER - 4;
  imgHistogram.Height := pnlHistogramHolder.Height - 8;

  with FInputColorBarBmp do
  begin
    Width  := imgInputBar.Bitmap.Width - 2 * BORDER;
    Height := GRADIENT_HEIGHT;
  end;

  with FOutputColorBarBmp do
  begin
    Width  := imgOutputBar.Bitmap.Width - 2 * BORDER;
    Height := GRADIENT_HEIGHT;
  end;

  // link to the right levels tool
  if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfLevels) and
     FWorkingOnEffectLayer then
  begin
    if Assigned(ActiveChildForm.Selection) then
    begin
      if Assigned(ActiveChildForm.SelectionHandleLayer) then
      begin
        ActiveChildForm.SelectionHandleLayer.Visible := False;
      end;
    end;

    LLevelsLayerPanel := TgmLevelsLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

    // Points to the Levels tool which for Levels layer.
    if LLevelsLayerPanel.LevelsTool <> nil then
    begin
      FLevelsTool := LLevelsLayerPanel.LevelsTool;
    end;
    
    FHistogram.Scale                := LLevelsLayerPanel.HistogramScale;
    chckbxPreview.Checked           := LLevelsLayerPanel.IsPreview;
    spdbtnLinearHistogram.Down      := (LLevelsLayerPanel.HistogramScale = GIMP_HISTOGRAM_SCALE_LINEAR);
    spdbtnLogarithmicHistogram.Down := (LLevelsLayerPanel.HistogramScale = GIMP_HISTOGRAM_SCALE_LOGARITHMIC);
  end
  else
  begin
    if Assigned(ActiveChildForm.Selection) then
    begin
      frmMain.FBeforeProc.Assign(ActiveChildForm.Selection.CutOriginal);
      frmMain.FAfterProc.Assign(ActiveChildForm.Selection.CutOriginal);

      if Assigned(ActiveChildForm.SelectionHandleLayer) then
      begin
        ActiveChildForm.SelectionHandleLayer.Visible := False;
      end;
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

    if FNormalLevelsTool <> nil then
    begin
      FreeAndNil(FNormalLevelsTool);
    end;
    
    // Create Levels Tool for normal layer, layer mask, alpha channel...
    FNormalLevelsTool := TgmLevelsTool.Create(frmMain.FBeforeProc);

    // if work with layers...
    if ActiveChildForm.ChannelManager.CurrentChannelType in [
         wctRGB, wctRed, wctGreen, wctBlue] then
    begin
      if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
           lfBackground, lfTransparent] then
      begin
        FNormalLevelsTool.Channel := StrToInt(ReadInfoFromIniFile(SECTION_LEVELS_DIALOG, IDENT_LEVELS_CHANNEL, '0'));
      end;
    end;

    FLevelsTool := FNormalLevelsTool; // Points to the curves which for normal layer. }

    chckbxPreview.Checked := Boolean(StrToInt(ReadInfoFromIniFile(SECTION_LEVELS_DIALOG, IDENT_LEVELS_PREVIEW, '1')));
  end;

  ChangeChannelItems;  // Change the items in the Channel combobox.

  if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfLevels) and
     FWorkingOnEffectLayer then
  begin
    LLevelsLayerPanel := TgmLevelsLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);
    FHistogram.gimp_histogram_calculate(LLevelsLayerPanel.FlattenedLayer);
  end
  else
  begin
    FHistogram.gimp_histogram_calculate(frmMain.FBeforeProc);
  end;
  
  FHistogram.gimp_histogram_view_expose(FLevelsTool.Channel);
  imgHistogram.Bitmap.Assign(FHistogram.HistogramMap);
  LevelsUpdate(ALL);

  if tlbtnBlackPicker.Down then
  begin
    tlbtnBlackPicker.Down := False;
  end;
  
  if tlbtnGrayPicker.Down then
  begin
    tlbtnGrayPicker.Down  := False;
  end;
  
  if tlbtnWhitePicker.Down then
  begin
    tlbtnWhitePicker.Down := False;
  end;
  
  // Create frmImageColorPicker
  frmImageColorPicker := TfrmImageColorPicker.Create(nil);
end;

procedure TfrmLevelsTool.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if frmImageColorPicker.Visible then
  begin
    frmImageColorPicker.Close;
  end;

  if FNormalLevelsTool <> nil then
  begin
    FreeAndNil(FNormalLevelsTool);
  end;

  // Free frmImageColorPicker
  FreeAndNil(frmImageColorPicker);
end; 

procedure TfrmLevelsTool.imgInputBarMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  i, Distance: Integer;
begin
  Distance := G_MAXINT;

  for i := 0 to 2 do
  begin
    if Abs(X - FLevelsTool.SliderPos[i]) < Distance then
    begin
      FLevelsTool.ActiveSlider := i;
      Distance := Abs(X - FLevelsTool.SliderPos[i]);
    end;
  end;

  UpdateLevelsInput(X);

  FDrawing := True;
end; 

procedure TfrmLevelsTool.imgInputBarMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
begin
  if FDrawing then
  begin
    UpdateLevelsInput(X);
  end;
end;

procedure TfrmLevelsTool.imgInputBarMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
begin
  FDrawing := False;
  
  LevelsUpdate(ALL);
  ExecuteGimpLevels;
end;

procedure TfrmLevelsTool.updwnLevelsGammaClick(Sender: TObject;
  Button: TUDBtnType);
var
  Value: Integer;
begin
  if FCanChange then
  begin
    if FLevelsTool <> nil then
    begin
      Value                   := updwnLevelsGamma.Position - UP_DOWN_GAMMA_INIT;
      FLevelsTool.LevelsGamma := 1.0 + Value / 10;
      edtLevelsGamma.Text     := FloatToStr(FLevelsTool.LevelsGamma);
      
      LevelsUpdate(INPUT_SLIDERS or INPUT_LEVELS);
    end;
  end;
end;

procedure TfrmLevelsTool.updwnLevelsGammaMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ExecuteGimpLevels;
end; 

procedure TfrmLevelsTool.imgOutputBarMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  i, Distance: Integer;
begin
  Distance := G_MAXINT;

  for i := 3 to 4 do
  begin
    if Abs(X - FLevelsTool.SliderPos[i]) < Distance then
    begin
      FLevelsTool.ActiveSlider := i;
      Distance := Abs(X - FLevelsTool.SliderPos[i]);
    end;
  end;

  UpdateLevelsOutput(X);

  FDrawing := True;
end;

procedure TfrmLevelsTool.imgOutputBarMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
begin
  if FDrawing then
  begin
    UpdateLevelsOutput(X);
  end;
end;

procedure TfrmLevelsTool.imgOutputBarMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
begin
  FDrawing := False;

  LevelsUpdate(ALL);
  ExecuteGimpLevels;
end; 

procedure TfrmLevelsTool.edtLevelsLowInputChange(Sender: TObject);
begin
  if FCanChange then
  begin
    if FLevelsTool <> nil then
    begin
      FLevelsTool.LevelsLowInput := updwnLevelsLowInput.Position;
      LevelsUpdate(INPUT_SLIDERS or INPUT_LEVELS);
    end;
  end;
end; 

procedure TfrmLevelsTool.edtLevelsHighInputChange(Sender: TObject);
begin
  if FCanChange then
  begin
    if FLevelsTool <> nil then
    begin
      FLevelsTool.LevelsHighInput := updwnLevelsHighInput.Position;
      LevelsUpdate(INPUT_SLIDERS or INPUT_LEVELS);
    end;
  end;
end; 

procedure TfrmLevelsTool.edtLevelsLowOutputChange(Sender: TObject);
begin
  if FCanChange then
  begin
    if FLevelsTool <> nil then
    begin
      FLevelsTool.LevelsLowOutput := updwnLevelsLowOutput.Position;
      LevelsUpdate(OUTPUT_SLIDERS);
    end;
  end;
end; 

procedure TfrmLevelsTool.edtLevelsHighOutputChange(Sender: TObject);
begin
  if FCanChange then
  begin
    if FLevelsTool <> nil then
    begin
      FLevelsTool.LevelsHighOutput := updwnLevelsHighOutput.Position;
      LevelsUpdate(OUTPUT_SLIDERS);
    end;
  end;
end;

procedure TfrmLevelsTool.ChangeLevelsChannel(Sender: TObject);
begin
  if FLevelsTool <> nil then
  begin
    FLevelsTool.Channel := cmbbxChannel.ItemIndex;
    UpdateChannelComboBoxHint;
    LevelsUpdate(ALL);

    if FHistogram <> nil then
    begin
      FHistogram.gimp_histogram_view_expose(FLevelsTool.Channel);
      imgHistogram.Bitmap.Assign(FHistogram.HistogramMap);
    end;
  end;
end; 

procedure TfrmLevelsTool.ChangeHistogramType(Sender: TObject);
begin
  if FHistogram <> nil then
  begin
    if Sender = spdbtnLinearHistogram then
    begin
      FHistogram.Scale := GIMP_HISTOGRAM_SCALE_LINEAR;
    end
    else if Sender = spdbtnLogarithmicHistogram then
    begin
      FHistogram.Scale := GIMP_HISTOGRAM_SCALE_LOGARITHMIC;
    end;

    FHistogram.gimp_histogram_view_expose(FLevelsTool.Channel);
    imgHistogram.Bitmap.Assign(FHistogram.HistogramMap);
  end;
end;

procedure TfrmLevelsTool.ResetChannel(Sender: TObject);
begin
  if FLevelsTool <> nil then
  begin
    FLevelsTool.LevelsChannelReset;
    LevelsUpdate(ALL);
    ExecuteGimpLevels;
  end;
end; 

procedure TfrmLevelsTool.chckbxPreviewClick(Sender: TObject);
begin
  ExecuteGimpLevels;
end;

procedure TfrmLevelsTool.ResetLevelsTool(Sender: TObject);
begin
  if FLevelsTool <> nil then
  begin
    FLevelsTool.Reset;
    LevelsUpdate(ALL);
    ExecuteGimpLevels;
  end;
end;

procedure TfrmLevelsTool.updwnLevelsLowInputMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ExecuteGimpLevels;
end;

procedure TfrmLevelsTool.updwnLevelsHighInputMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ExecuteGimpLevels;
end;

procedure TfrmLevelsTool.updwnLevelsLowOutputMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ExecuteGimpLevels;
end;

procedure TfrmLevelsTool.updwnLevelsHighOutputMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ExecuteGimpLevels;
end;

procedure TfrmLevelsTool.btnAutoAdjustmentClick(Sender: TObject);
begin
  if (FLevelsTool <> nil) and (FHistogram <> nil) then
  begin
    FLevelsTool.LevelsStretch(FHistogram);
    LevelsUpdate(ALL);
    ExecuteGimpLevels;
  end;
end;

procedure TfrmLevelsTool.ChangeActivePicker(Sender: TObject);
begin
  if FLevelsTool <> nil then
  begin
    if Sender = tlbtnBlackPicker then
    begin
      if tlbtnBlackPicker.Down then
      begin
        FLevelsTool.ActivePicker := lapBlack;

        if not frmImageColorPicker.Visible then
        begin
          frmImageColorPicker.Show;
        end;
      end
      else
      begin
        FLevelsTool.ActivePicker := lapNone;

        if frmImageColorPicker.Visible then
        begin
          frmImageColorPicker.Close;
        end;
      end;
    end
    else
    if Sender = tlbtnGrayPicker then
    begin
      if tlbtnGrayPicker.Down then
      begin
        FLevelsTool.ActivePicker := lapGray;

        if not frmImageColorPicker.Visible then
        begin
          frmImageColorPicker.Show;
        end;
      end
      else
      begin
        FLevelsTool.ActivePicker := lapNone;

        if frmImageColorPicker.Visible then
        begin
          frmImageColorPicker.Close;
        end;
      end;
    end
    else
    if Sender = tlbtnWhitePicker then
    begin
      if tlbtnWhitePicker.Down then
      begin
        FLevelsTool.ActivePicker := lapWhite;

        if not frmImageColorPicker.Visible then
        begin
          frmImageColorPicker.Show;
        end;
      end
      else
      begin
        FLevelsTool.ActivePicker := lapNone;
        
        if frmImageColorPicker.Visible then
        begin
          frmImageColorPicker.Close;
        end;
      end;
    end;

    tlbtnBlackPicker.Down := (FLevelsTool.ActivePicker = lapBlack);
    tlbtnGrayPicker.Down  := (FLevelsTool.ActivePicker = lapGray);
    tlbtnWhitePicker.Down := (FLevelsTool.ActivePicker = lapWhite);
  end;
end;

procedure TfrmLevelsTool.btbtnOKClick(Sender: TObject);
var
  LCmdAim           : TCommandAim;
  LHistoryStatePanel: TgmHistoryStatePanel;
  LLevelsLayerPanel : TgmLevelsLayerPanel;
begin
  with ActiveChildForm do
  begin
    if (LayerPanelList.SelectedLayerPanel.LayerFeature = lfLevels) and
       FWorkingOnEffectLayer then
    begin
      // if this levels tool for levels layer...
      LLevelsLayerPanel := TgmLevelsLayerPanel(LayerPanelList.SelectedLayerPanel);
      LLevelsLayerPanel.HistogramScale := FHistogram.Scale;
      LLevelsLayerPanel.IsPreview      := chckbxPreview.Checked;
    end
    else
    begin
      // the processed result is stored in frmMain.FAfterProc
      if LayerPanelList.SelectedLayerPanel.IsMaskLinked then
      begin
        if (LayerPanelList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent]) and
           (ChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue]) then
        begin
          ReplaceAlphaChannelWithMask(frmMain.FAfterProc,
            LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
        end;
      end;

      // undo/redo
      LCmdAim := GetCommandAimByCurrentChannel;

      LHistoryStatePanel := TgmImageManipulatingStatePanel.Create(
        frmHistory.scrlbxHistory,
        dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
        LCmdAim,
        'Levels',
        frmMain.FBeforeProc, frmMain.FAfterProc,
        Selection,
        ChannelManager.SelectedAlphaChannelIndex);

      HistoryManager.AddHistoryState(LHistoryStatePanel);

      // save settings to INI file
      if FLevelsTool <> nil then
      begin
        if ChannelManager.CurrentChannelType in
             [wctRGB, wctRed, wctGreen, wctBlue] then
        begin
          WriteInfoToIniFile(SECTION_LEVELS_DIALOG, IDENT_LEVELS_CHANNEL,
                             IntToStr(FLevelsTool.Channel));
        end;
      end;

      WriteInfoToIniFile(SECTION_LEVELS_DIALOG, IDENT_LEVELS_HISTOGRAM, IntToStr(Ord(FHistogram.Scale)));
      WriteInfoToIniFile(SECTION_LEVELS_DIALOG, IDENT_LEVELS_PREVIEW,   IntToStr(Integer(chckbxPreview.Checked)));
    end;
  end;
end; 

procedure TfrmLevelsTool.btnLoadLevelsClick(Sender: TObject);
begin
  if Assigned(FLevelsTool) then
  begin
    OpenDialog.InitialDir := ReadInfoFromIniFile(SECTION_LEVELS_DIALOG, IDENT_LEVELS_FILE_DIR, ExtractFilePath( ParamStr(0) ));

    if OpenDialog.Execute then
    begin
      Screen.Cursor := crHourGlass;
      try
        FLevelsFileName := OpenDialog.FileName;
        try
          { The following methold must be called first, otherwise, the
            FLevelsTool.LoadFormFile() will causes an exception. The reason for
            why is not clear, yet. }
          ResetLevelsTool(Sender);

          if FLevelsTool.LoadFromFile(FLevelsFileName) then
          begin
            if cmbbxChannel.Items.Count > 1 then
            begin
              cmbbxChannel.ItemIndex := FLevelsTool.Channel;
            end
            else
            begin
              cmbbxChannel.ItemIndex := 0;
              ChangeLevelsChannel(Sender);
            end;

            LevelsUpdate(ALL);
            ExecuteGimpLevels;

            WriteInfoToIniFile(SECTION_LEVELS_DIALOG, IDENT_LEVELS_FILE_DIR, ExtractFilePath(FLevelsFileName));
          end
          else // loading error
          begin
            MessageDlg(FLevelsTool.OutputMsg, mtError, [mbOK], 0);
          end;

        except
          MessageDlg('Cannot open the file "' + ExtractFileName(OpenDialog.FileName) + '".', mtError, [mbOK], 0)
        end;
      finally
        Screen.Cursor := crDefault;
      end;
    end;
  end;
end; 

procedure TfrmLevelsTool.btnSaveLevelsClick(Sender: TObject);
var
  FileDir       : string;
  FileExt       : string;
  OutputFileName: string;
begin
  if Assigned(FLevelsTool) then
  begin
    if FLevelsFileName = '' then
    begin
      SaveDialog.FileName := 'Untitled' + LEVELS_FILE_EXT;
    end
    else
    begin
      SaveDialog.FileName := ExtractFileName(FLevelsFileName);
    end;

    SaveDialog.InitialDir := ReadInfoFromIniFile(SECTION_LEVELS_DIALOG,
                                                 IDENT_LEVELS_FILE_DIR,
                                                 ExtractFilePath( ParamStr(0) ));

    if SaveDialog.Execute then
    begin
      Screen.Cursor := crHourGlass;
      try
        OutputFileName := SaveDialog.FileName;
        FileDir        := ExtractFileDir(OutputFileName);

        if (FileDir <> '') and DirectoryExists(FileDir) then
        begin
          FileExt := ExtractFileExt(OutputFileName);

          if FileExt = '' then
          begin
            OutputFileName := OutputFileName + LEVELS_FILE_EXT;
          end
          else
          if FileExt <> LEVELS_FILE_EXT then
          begin
            OutputFileName := ChangeFileExt(OutputFileName, LEVELS_FILE_EXT);
          end;

          if FileExists(OutputFileName) then
          begin
            if MessageDlg('The file "' + ExtractFileName(OutputFileName) + '" is already exists.' + #10#13 +
                          'Do you want to replace it?', mtConfirmation, mbOKCancel, 0) <> mrOK then
            begin
              Exit;
            end;
          end;

          FLevelsTool.SaveToFile(SaveDialog.FileName);

          FLevelsFileName := SaveDialog.FileName;
          WriteInfoToIniFile(SECTION_LEVELS_DIALOG, IDENT_LEVELS_FILE_DIR, ExtractFilePath(FLevelsFileName));
        end;
        
      finally
        Screen.Cursor := crDefault;
      end;
    end;
  end;
end; 

end.
