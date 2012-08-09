{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

unit ThresholdDlg;

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
  StdCtrls, Buttons, ComCtrls, ExtCtrls,
{ Graphics32 Lib }
  GR32_RangeBars,
{ GraphicsMagic Lib }
  gmTypes;

type
  TfrmThreshold = class(TForm)
    grpbxThreshold: TGroupBox;
    lblThresholdLevels: TLabel;
    edtThresholdValue: TEdit;
    btbtnOK: TBitBtn;
    btbtnCancel: TBitBtn;
    chckbxPreview: TCheckBox;
    imgThresholdHistogram: TImage;
    ggbrThresholdLevel: TGaugeBar;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtThresholdValueChange(Sender: TObject);
    procedure chckbxPreviewClick(Sender: TObject);
    procedure btbtnOKClick(Sender: TObject);
    procedure ggbrThresholdLevelChange(Sender: TObject);
  private
    FLevel               : Integer;
    FBarIsChanging       : Boolean;
    FWorkingOnEffectLayer: Boolean;

    procedure DrawHistogram;
    procedure ThresholdOnSelection;
    procedure ThresholdOnAlphaChannel;
    procedure ThresholdOnQuickMask;
    procedure ThresholdOnLayerMask;
    procedure ThresholdOnLayer;
    procedure ExecuteThreshold;
  public
    property IsWorkingOnEffectLayer: Boolean read FWorkingOnEffectLayer write FWorkingOnEffectLayer;
  end;

var
  frmThreshold: TfrmThreshold;

implementation

uses
{ Graphics32 }
  GR32, GR32_Layers,
{ Externals }
  HistogramLibrary,         // THistogram
{ GraphicsMagic Lib }
  gmIni,
  gmImageProcessFuncs,
  gmLayerAndChannel,
  gmMath,
  gmCommands,
  gmHistoryManager,
  gmAlphaFuncs,
{ GraphicsMagic Data Modules }
  HistoryDataModule,
{ GraphicsMagic Forms/Dialogs }
  MainForm,
  HistoryForm;

{$R *.DFM}

//-- Custom Procedures And Functions -------------------------------------------

procedure TfrmThreshold.DrawHistogram;
const
  clSkyBlue = TColor($F0CAA6);   // RGB: 166 202 240
var
  LHistogram        : THistogram;
  LFlattenedBmp     : TBitmap32;
  LColorChannelCount: Integer;
begin
  LHistogram := THistogram.Create;
  try
    if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfThreshold) and
       FWorkingOnEffectLayer then
    begin
      LFlattenedBmp := TBitmap32.Create;
      try
        LFlattenedBmp.DrawMode := dmBlend;

        { If the current layer is the first layer in the list, then we just use
          it to calculate histogram. Otherwise, we need to blend it with the
          layers that under it, and use the combined layer to calculate the
          histogram. }

        if ActiveChildForm.LayerPanelList.CurrentIndex = 1 then
        begin
          LFlattenedBmp.Assign( TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[0]).Bitmap );
        end
        else
        begin
          LFlattenedBmp.Width  := ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width;
          LFlattenedBmp.Height := ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height;

          ActiveChildForm.LayerPanelList.FlattenLayersToBitmap(LFlattenedBmp,
            dmBlend, 0, ActiveChildForm.LayerPanelList.CurrentIndex - 1);
        end;

        GetHistogram(cpIntensity, LFlattenedBmp, LHistogram);
      finally
        LFlattenedBmp.Free;
      end;
    end
    else
    begin
      case ActiveChildForm.ChannelManager.CurrentChannelType of
        wctAlpha, wctQuickMask, wctLayerMask:
          begin
            GetHistogram(cpValue, frmMain.FBeforeProc, LHistogram);
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
                 lfBackground, lfTransparent] then
            begin
              LColorChannelCount := ActiveChildForm.ChannelManager.SelectedColorChannelCount;

              if LColorChannelCount = 1 then
              begin
                if csRed in ActiveChildForm.ChannelManager.ChannelSelectedSet then
                begin
                  GetHistogram(cpRed, frmMain.FBeforeProc, LHistogram);
                end
                else
                if csGreen in ActiveChildForm.ChannelManager.ChannelSelectedSet then
                begin
                  GetHistogram(cpGreen, frmMain.FBeforeProc, LHistogram);
                end
                else
                if csBlue in ActiveChildForm.ChannelManager.ChannelSelectedSet then
                begin
                  GetHistogram(cpBlue, frmMain.FBeforeProc, LHistogram);
                end;
              end
              else
              if LColorChannelCount = 2 then
              begin
                if (csRed   in ActiveChildForm.ChannelManager.ChannelSelectedSet) and
                   (csGreen in ActiveChildForm.ChannelManager.ChannelSelectedSet) then
                begin
                  GetHistogram(cpYellow, frmMain.FBeforeProc, LHistogram);
                end
                else
                if (csRed  in ActiveChildForm.ChannelManager.ChannelSelectedSet) and
                   (csBlue in ActiveChildForm.ChannelManager.ChannelSelectedSet) then
                begin
                  GetHistogram(cpMagenta, frmMain.FBeforeProc, LHistogram);
                end
                else
                if (csGreen in ActiveChildForm.ChannelManager.ChannelSelectedSet) and
                   (csBlue  in ActiveChildForm.ChannelManager.ChannelSelectedSet) then
                begin
                  GetHistogram(cpCyan, frmMain.FBeforeProc, LHistogram);
                end;
              end
              else
              if LColorChannelCount = 3 then
              begin
                GetHistogram(cpIntensity, frmMain.FBeforeProc, LHistogram);
              end;
            end;
          end;
      end;
    end;

    imgThresholdHistogram.Canvas.Brush.Color := clSkyBlue;
    imgThresholdHistogram.Canvas.FillRect(imgThresholdHistogram.Canvas.ClipRect);
    LHistogram.Draw(imgThresholdHistogram.Canvas);
  finally
    LHistogram.Free;
  end;
end;

procedure TfrmThreshold.ThresholdOnSelection;
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

    ThresholdBitmap32(frmMain.FBeforeProc, frmMain.FAfterProc, FLevel,
                      ChannelManager.ChannelSelectedSet);

    if chckbxPreview.Checked then
    begin
      Selection.CutOriginal.Assign(frmMain.FAfterProc);
      ShowProcessedSelection;
    end;
  end;
end;

procedure TfrmThreshold.ThresholdOnAlphaChannel;
begin
  if Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
  begin
    ThresholdBitmap32(frmMain.FBeforeProc, frmMain.FAfterProc, FLevel,
                      ActiveChildForm.ChannelManager.ChannelSelectedSet);

    if chckbxPreview.Checked then
    begin
      ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Assign(frmMain.FAfterProc);
      ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
    end;
  end;
end;

procedure TfrmThreshold.ThresholdOnQuickMask;
begin
  if Assigned(ActiveChildForm.ChannelManager.QuickMaskPanel) then
  begin
    ThresholdBitmap32(frmMain.FBeforeProc, frmMain.FAfterProc, FLevel,
                      ActiveChildForm.ChannelManager.ChannelSelectedSet);

    if chckbxPreview.Checked then
    begin
      ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.Assign(frmMain.FAfterProc);
      ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Changed;
    end;
  end;
end;

procedure TfrmThreshold.ThresholdOnLayerMask;
begin
  with ActiveChildForm do
  begin
    ThresholdBitmap32(frmMain.FBeforeProc, frmMain.FAfterProc, FLevel,
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

procedure TfrmThreshold.ThresholdOnLayer;
begin
  with ActiveChildForm do
  begin
    if LayerPanelList.SelectedLayerPanel.LayerFeature in [
         lfBackground, lfTransparent] then
    begin
      ThresholdBitmap32(frmMain.FBeforeProc, frmMain.FAfterProc, FLevel,
                        ChannelManager.ChannelSelectedSet);
    end;

    if chckbxPreview.Checked then
    begin
      if (LayerPanelList.SelectedLayerPanel.LayerFeature = lfThreshold) and
         FWorkingOnEffectLayer then
      begin
        LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
      end
      else
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
end; 

procedure TfrmThreshold.ExecuteThreshold;
begin
  if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfThreshold) and
     FWorkingOnEffectLayer then
  begin
    ThresholdOnLayer;
  end
  else
  begin
    if Assigned(ActiveChildForm.Selection) then
    begin
      ThresholdOnSelection;
    end
    else
    begin
      case ActiveChildForm.ChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            ThresholdOnAlphaChannel;
          end;

        wctQuickMask:
          begin
            ThresholdOnQuickMask;
          end;
          
        wctLayerMask:
          begin
            ThresholdOnLayerMask;
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            ThresholdOnLayer;
          end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmThreshold.FormCreate(Sender: TObject);
begin
  FLevel                := 127;
  FBarIsChanging        := False;
  FWorkingOnEffectLayer := False;
end;

procedure TfrmThreshold.FormShow(Sender: TObject);
var
  LLevel              : Byte;
  LThresholdLayerPanel: TgmThresholdLayerPanel;
begin
  // on Threshold Layer...
  if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfThreshold) and
     FWorkingOnEffectLayer then
  begin
    if Assigned(ActiveChildForm.Selection) then
    begin
      if Assigned(ActiveChildForm.SelectionHandleLayer) then
      begin
        ActiveChildForm.SelectionHandleLayer.Visible := False;
      end;
    end;

    LThresholdLayerPanel := TgmThresholdLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);
    LLevel               := LThresholdLayerPanel.Level;

    chckbxPreview.Checked := LThresholdLayerPanel.IsPreview;

    if ggbrThresholdLevel.Position = LLevel then
    begin
      ExecuteThreshold;
    end
    else
    begin
      ggbrThresholdLevel.Position := LLevel;
    end;
  end
  else
  begin
    if Assigned(ActiveChildForm.Selection) then
    begin
      frmMain.FBeforeProc.Assign(ActiveChildForm.Selection.CutOriginal);

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
            end;
          end;

        wctQuickMask:
          begin
            if Assigned(ActiveChildForm.ChannelManager.QuickMaskPanel) then
            begin
              frmMain.FBeforeProc.Assign(ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
            end;
          end;

        wctLayerMask:
          begin
            frmMain.FBeforeProc.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
                 lfBackground, lfTransparent] then
            begin
              frmMain.FBeforeProc.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

              if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsMaskLinked then
              begin
                ReplaceAlphaChannelWithMask(frmMain.FBeforeProc,
                  ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
              end;
            end;
          end;
      end;
    end;

    chckbxPreview.Checked := Boolean(StrToInt(ReadInfoFromIniFile(SECTION_THRESHOLD_DIALOG, IDENT_THRESHOLD_PREVIEW, '1')));

    if ggbrThresholdLevel.Position = FLevel then
    begin
      ExecuteThreshold;
    end
    else
    begin
      ggbrThresholdLevel.Position := FLevel;
    end;
  end;

  DrawHistogram;
  ActiveControl := btbtnOK;
end; 

procedure TfrmThreshold.edtThresholdValueChange(Sender: TObject);
var
  LChangedValue       : Integer;
  LLevel              : Byte;
  LThresholdLayerPanel: TgmThresholdLayerPanel;
begin
  if not FBarIsChanging then
  begin
    try
      LChangedValue := StrToInt(edtThresholdValue.Text);

      EnsureValueInRange(LChangedValue, ggbrThresholdLevel.Min, ggbrThresholdLevel.Max);
      
      ggbrThresholdLevel.Position := LChangedValue;
    except
      if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfThreshold) and
         FWorkingOnEffectLayer then
      begin
        LThresholdLayerPanel := TgmThresholdLayerPanel(
          ActiveChildForm.LayerPanelList.SelectedLayerPanel);
          
        LLevel                 := LThresholdLayerPanel.Level;
        edtThresholdValue.Text := IntToStr(LLevel);
      end
      else
      begin
        edtThresholdValue.Text := IntToStr(FLevel);
      end;
    end;
  end;
end;

procedure TfrmThreshold.chckbxPreviewClick(Sender: TObject);
begin
  ExecuteThreshold;
end;

procedure TfrmThreshold.btbtnOKClick(Sender: TObject);
var
  LCmdAim             : TCommandAim;
  LHistoryStatePanel  : TgmHistoryStatePanel;
  LThresholdLayerPanel: TgmThresholdLayerPanel;
begin
  // on Threshold layer...
  if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfThreshold) and
     FWorkingOnEffectLayer then
  begin
    LThresholdLayerPanel := TgmThresholdLayerPanel(
      ActiveChildForm.LayerPanelList.SelectedLayerPanel);
      
    LThresholdLayerPanel.IsPreview := chckbxPreview.Checked;
  end
  else
  begin
    // the processed result is stored in frmMain.FAfterProc
    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsMaskLinked then
    begin
      if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent]) and
         (ActiveChildForm.ChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue]) then
      begin
        ReplaceAlphaChannelWithMask(frmMain.FAfterProc,
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
      end;
    end;

    // undo/redo
    LCmdAim := ActiveChildForm.GetCommandAimByCurrentChannel;

    LHistoryStatePanel := TgmImageManipulatingStatePanel.Create(
      frmHistory.scrlbxHistory,
      dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
      LCmdAim,
      'Threshold',
      frmMain.FBeforeProc,
      frmMain.FAfterProc,
      ActiveChildForm.Selection,
      ActiveChildForm.ChannelManager.SelectedAlphaChannelIndex);

    ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);

    WriteInfoToIniFile( SECTION_THRESHOLD_DIALOG, IDENT_THRESHOLD_PREVIEW,
                        IntToStr(Integer(chckbxPreview.Checked)) );
  end;
end;

procedure TfrmThreshold.ggbrThresholdLevelChange(Sender: TObject);
var
  LThresholdLayerPanel: TgmThresholdLayerPanel;
begin
  FBarIsChanging := True;
  try
    edtThresholdValue.Text := IntToStr(ggbrThresholdLevel.Position);

    if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfThreshold) and
       FWorkingOnEffectLayer then
    begin
      LThresholdLayerPanel := TgmThresholdLayerPanel(
        ActiveChildForm.LayerPanelList.SelectedLayerPanel);
        
      LThresholdLayerPanel.Level := ggbrThresholdLevel.Position;
    end
    else
    begin
      FLevel := ggbrThresholdLevel.Position;
    end;

    ExecuteThreshold;
  finally
    FBarIsChanging := False;
  end;
end; 

end.
