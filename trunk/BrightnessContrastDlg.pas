{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

unit BrightnessContrastDlg;

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
  GR32, GR32_RangeBars;

type
  TfrmBrightnessContrast = class(TForm)
    btbtnOK: TBitBtn;
    btbtnCancel: TBitBtn;
    chckbxPreview: TCheckBox;
    grpbxBrightnessContrast: TGroupBox;
    lblBrightness: TLabel;
    edtBrightness: TEdit;
    lblContrast: TLabel;
    edtContrast: TEdit;
    ggbrBrightness: TGaugeBar;
    ggbrContrast: TGaugeBar;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure AdjustBrightness(Sender: TObject);
    procedure AdjustContrast(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure chckbxPreviewClick(Sender: TObject);
    procedure edtBrightnessChange(Sender: TObject);
    procedure edtContrastChange(Sender: TObject);
    procedure btbtnOKClick(Sender: TObject);
  private
    FTempBitmap          : TBitmap32;
    FBrightnessAmount    : Integer;
    FContrastAmount      : Integer;
    FBarIsChanging       : Boolean;
    FEditIsChanging      : Boolean;
    FWorkingOnEffectLayer: Boolean;

    procedure ExecuteBCOnSelection;
    procedure ExecuteBCOnAlphaChannel;
    procedure ExecuteBCOnQuickMask;
    procedure ExecuteBCOnLayerMask;
    procedure ExecuteBCOnLayer;
    procedure ExecuteBrightnessContrast;
  public
    property IsWorkingOnEffectLayer: Boolean read FWorkingOnEffectLayer write FWorkingOnEffectLayer;
  end;

var
  frmBrightnessContrast: TfrmBrightnessContrast;

implementation

uses
{ GraphicsMagic Lib }
  gmTypes,
  gmIni,
  gmLayerAndChannel,
  gmMath,                  // EnsureIntegerInRange()
  gmImageProcessFuncs,
  gmAlphaFuncs,
  gmCommands,
  gmHistoryManager,
{ GraphicsMagic Data Modules }
  HistoryDataModule,
{ GraphicsMagic Forms/Dialogs }
  MainForm,                // frmMain
  HistoryForm;

{$R *.DFM}

const
  MEDIAN_VALUE: Integer = 100;
  MIN_VALUE   : Integer = -100;
  MAX_VALUE   : Integer = 100;

//-- Custom procedures and functions -------------------------------------------

// process on selection
procedure TfrmBrightnessContrast.ExecuteBCOnSelection;
begin
  with ActiveChildForm do
  begin
    if ChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue] then
    begin
      // can't process on special layers
      if not (LayerPanelList.SelectedLayerPanel.LayerFeature in [
                lfBackground, lfTransparent]) then
      begin
        Exit;
      end;
    end;

    // change brightness first
    Brightness32(frmMain.FBeforeProc, frmMain.FAfterProc, FBrightnessAmount,
                 ChannelManager.ChannelSelectedSet);

    { After brightness adjustment, change contrast. Note,
      the parameter is FContrast * 3, which is for getting more obvious effect. }

    FTempBitmap.Assign(frmMain.FAfterProc);
    
    Contrast32(FTempBitmap, frmMain.FAfterProc, FContrastAmount * 3,
               ChannelManager.ChannelSelectedSet);

    if chckbxPreview.Checked then
    begin
      Selection.CutOriginal.Assign(frmMain.FAfterProc);
      ShowProcessedSelection;
    end;
  end;
end;

// process on alpha layer
procedure TfrmBrightnessContrast.ExecuteBCOnAlphaChannel;
begin
  if Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
  begin
    // change brightness first
    Brightness32(frmMain.FBeforeProc, frmMain.FAfterProc, FBrightnessAmount,
                 ActiveChildForm.ChannelManager.ChannelSelectedSet);

    { After brightness adjustment, change contrast. Note,
      the parameter is FContrast * 3, which is for getting more obvious effect. }

    FTempBitmap.Assign(frmMain.FAfterProc);
    Contrast32(FTempBitmap, frmMain.FAfterProc, FContrastAmount * 3,
               ActiveChildForm.ChannelManager.ChannelSelectedSet);

    if chckbxPreview.Checked then
    begin
      ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Assign(frmMain.FAfterProc);
      ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
    end;
  end;
end;

procedure TfrmBrightnessContrast.ExecuteBCOnQuickMask;
begin
  if Assigned(ActiveChildForm.ChannelManager.QuickMaskPanel) then
  begin
    // change brightness first
    Brightness32(frmMain.FBeforeProc, frmMain.FAfterProc, FBrightnessAmount,
                 ActiveChildForm.ChannelManager.ChannelSelectedSet);

    { After brightness adjustment, change contrast. Note,
      the parameter is FContrast * 3, which is for getting more obvious effect. }

    FTempBitmap.Assign(frmMain.FAfterProc);
    Contrast32(FTempBitmap, frmMain.FAfterProc, FContrastAmount * 3,
               ActiveChildForm.ChannelManager.ChannelSelectedSet);

    if chckbxPreview.Checked then
    begin
      ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.Assign(frmMain.FAfterProc);
      ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Changed;
    end;
  end;
end;

// process on layer mask
procedure TfrmBrightnessContrast.ExecuteBCOnLayerMask;
begin
  with ActiveChildForm do
  begin
    // change brightness first
    Brightness32(frmMain.FBeforeProc, frmMain.FAfterProc, FBrightnessAmount,
                 ChannelManager.ChannelSelectedSet);

    { After brightness adjustment, change contrast. Note,
      the parameter is FContrast * 3, which is for getting more obvious effect. }

    FTempBitmap.Assign(frmMain.FAfterProc);

    Contrast32(FTempBitmap, frmMain.FAfterProc, FContrastAmount * 3,
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

// process on layer
procedure TfrmBrightnessContrast.ExecuteBCOnLayer;
begin
  with ActiveChildForm do
  begin
    if LayerPanelList.SelectedLayerPanel.LayerFeature in [
         lfBackground, lfTransparent] then
    begin
      // change brightness first
      Brightness32(frmMain.FBeforeProc, frmMain.FAfterProc, FBrightnessAmount,
                   ChannelManager.ChannelSelectedSet);

      { After brightness adjustment, change contrast. Note,
        the parameter is FContrast * 3, which is for getting more
        obvious effect. }

      FTempBitmap.Assign(frmMain.FAfterProc);

      Contrast32(FTempBitmap, frmMain.FAfterProc, FContrastAmount * 3,
                 ChannelManager.ChannelSelectedSet);
    end;

    if chckbxPreview.Checked then
    begin
      if (LayerPanelList.SelectedLayerPanel.LayerFeature = lfBrightContrast) and
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

procedure TfrmBrightnessContrast.ExecuteBrightnessContrast;
begin
  with ActiveChildForm do
  begin
    if (LayerPanelList.SelectedLayerPanel.LayerFeature = lfBrightContrast) and
       FWorkingOnEffectLayer then
    begin
      ExecuteBCOnLayer;
    end
    else
    begin
      if Assigned(Selection) then
      begin
        ExecuteBCOnSelection;
      end
      else
      begin
        case ChannelManager.CurrentChannelType of
          wctAlpha:
            begin
              ExecuteBCOnAlphaChannel;
            end;

          wctQuickMask:
            begin
              ExecuteBCOnQuickMask;
            end;
            
          wctLayerMask:
            begin
              ExecuteBCOnLayerMask;
            end;

          wctRGB, wctRed, wctGreen, wctBlue:
            begin
              ExecuteBCOnLayer;
            end;
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmBrightnessContrast.FormCreate(Sender: TObject);
begin
  FTempBitmap           := TBitmap32.Create;
  FTempBitmap.DrawMode  := dmBlend;
  FBrightnessAmount     := 0;
  FContrastAmount       := 0;
  FBarIsChanging        := False;
  FEditIsChanging       := False;
  FWorkingOnEffectLayer := False;
end;

procedure TfrmBrightnessContrast.FormShow(Sender: TObject);
var
  LBrightContrastLayerPanel: TgmBrightContrastLayerPanel;
  LTempBmp                 : TBitmap32;
  LChangedValue            : Integer;
begin
  with ActiveChildForm do
  begin
    // if on brightness/contrast layer...
    if (LayerPanelList.SelectedLayerPanel.LayerFeature = lfBrightContrast) and
       FWorkingOnEffectLayer then
    begin
      if Assigned(Selection) then
      begin
        if Assigned(SelectionHandleLayer) then
        begin
          SelectionHandleLayer.Visible := False;
        end;
      end;

      LBrightContrastLayerPanel := TgmBrightContrastLayerPanel(LayerPanelList.SelectedLayerPanel);
      ggbrBrightness.Position   := MEDIAN_VALUE + LBrightContrastLayerPanel.AdjustBrightness;
      ggbrContrast.Position     := MEDIAN_VALUE + LBrightContrastLayerPanel.AdjustContrast;
      chckbxPreview.Checked     := LBrightContrastLayerPanel.IsPreview;
    end
    else
    begin
      if Assigned(Selection) then
      begin
        frmMain.FBeforeProc.Assign(Selection.CutOriginal);
        frmMain.FAfterProc.Assign(Selection.CutOriginal);

        if Assigned(SelectionHandleLayer) then
        begin
          SelectionHandleLayer.Visible := False;
        end;
      end
      else
      begin
        case ChannelManager.CurrentChannelType of
          wctAlpha:
            begin
              if Assigned(ChannelManager.SelectedAlphaChannelPanel) then
              begin
                frmMain.FBeforeProc.Assign(ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
                frmMain.FAfterProc.Assign(ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
              end;
            end;

          wctQuickMask:
            begin
              if Assigned(ChannelManager.QuickMaskPanel) then
              begin
                frmMain.FBeforeProc.Assign(ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
                frmMain.FAfterProc.Assign(ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
              end;
            end;

          wctLayerMask:
            begin
              frmMain.FBeforeProc.Assign(LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
              frmMain.FAfterProc.Assign(LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
            end;

          wctRGB, wctRed, wctGreen, wctBlue:
            begin
              if LayerPanelList.SelectedLayerPanel.LayerFeature in [
                   lfBackground, lfTransparent] then
              begin
                LTempBmp := TBitmap32.Create;
                try
                  LTempBmp.Assign(LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

                  if LayerPanelList.SelectedLayerPanel.IsMaskLinked then
                  begin
                    ReplaceAlphaChannelWithMask(LTempBmp,
                      LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
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

      ggbrBrightness.Position := MEDIAN_VALUE;
      ggbrContrast.Position   := MEDIAN_VALUE;
      chckbxPreview.Checked   := Boolean(StrToInt(ReadInfoFromIniFile(SECTION_BRIGHT_CONTRAST_DIALOG, IDENT_BRIGHT_CONTRAST_PREVIEW, '1')));
    end;
  end;

  // display bar positions in edit boxes
  FBarIsChanging := True;
  try
    LChangedValue := ggbrBrightness.Position - MEDIAN_VALUE;

    if LChangedValue > 0 then
    begin
      edtBrightness.Text := '+' + IntToStr(LChangedValue);
    end
    else
    begin
      edtBrightness.Text := IntToStr(LChangedValue);
    end;

    LChangedValue := ggbrContrast.Position - MEDIAN_VALUE;

    if LChangedValue > 0 then
    begin
      edtContrast.Text := '+' + IntToStr(LChangedValue);
    end
    else
    begin
      edtContrast.Text := IntToStr(LChangedValue);
    end;
  finally
    FBarIsChanging := False;
  end;
  
  ActiveControl := btbtnOK;
end;

procedure TfrmBrightnessContrast.AdjustBrightness(
  Sender: TObject);
var
  LChangedValue            : Integer;
  LBrightContrastLayerPanel: TgmBrightContrastLayerPanel;
begin
  FBarIsChanging := True;
  try
    LChangedValue := ggbrBrightness.Position - MEDIAN_VALUE;

    if FEditIsChanging then
    begin
      edtBrightness.Text := IntToStr(LChangedValue);
    end
    else
    begin
      if LChangedValue > 0 then
      begin
        edtBrightness.Text := '+' + IntToStr(LChangedValue);
      end
      else
      begin
        edtBrightness.Text := IntToStr(LChangedValue);
      end;
    end;

    // if on brightness/contrast layer...
    if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfBrightContrast) and
       FWorkingOnEffectLayer then
    begin
      LBrightContrastLayerPanel := TgmBrightContrastLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

      if LBrightContrastLayerPanel.AdjustBrightness <> LChangedValue then
      begin
        LBrightContrastLayerPanel.AdjustBrightness := LChangedValue;
      end;
    end
    else
    begin
      if ActiveChildForm.ChannelManager.CurrentChannelType in
           [wctAlpha, wctQuickMask, wctLayerMask] then
      begin
        if FBrightnessAmount <> LChangedValue then
        begin
          FBrightnessAmount := LChangedValue;
        end;
      end
      else
      begin
        // must be on layer...
        if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
             lfBackground, lfTransparent] then
        begin
          if FBrightnessAmount <> LChangedValue then
          begin
            FBrightnessAmount := LChangedValue;
          end;
        end;
      end;
    end;

    ExecuteBrightnessContrast;
  finally
    FBarIsChanging := False;
  end;
end;

procedure TfrmBrightnessContrast.AdjustContrast(Sender: TObject);
var
  LChangedValue            : Integer;
  LBrightContrastLayerPanel: TgmBrightContrastLayerPanel;
begin
  FBarIsChanging := True;
  try
    LChangedValue := ggbrContrast.Position - MEDIAN_VALUE;

    if FEditIsChanging then
    begin
      edtContrast.Text := IntToStr(LChangedValue);
    end
    else
    begin
      if LChangedValue > 0 then
      begin
        edtContrast.Text := '+' + IntToStr(LChangedValue);
      end
      else
      begin
        edtContrast.Text := IntToStr(LChangedValue);
      end;
    end;

    // if on brightness/contrast layer...
    if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfBrightContrast) and
       FWorkingOnEffectLayer then
    begin
      LBrightContrastLayerPanel := TgmBrightContrastLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

      if LBrightContrastLayerPanel.AdjustContrast <> LChangedValue then
      begin
        LBrightContrastLayerPanel.AdjustContrast := LChangedValue;
      end;
    end
    else
    begin
      if ActiveChildForm.ChannelManager.CurrentChannelType in
           [wctAlpha, wctQuickMask, wctLayerMask] then
      begin
        if FContrastAmount <> LChangedValue then
        begin
          FContrastAmount := LChangedValue;
        end;
      end
      else
      begin
        // must be on layer...
        if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
             lfBackground, lfTransparent] then
        begin
          if FContrastAmount <> LChangedValue then
          begin
            FContrastAmount := LChangedValue;
          end;
        end;
      end;
    end;

    ExecuteBrightnessContrast;
  finally
    FBarIsChanging := False;
  end;
end;

procedure TfrmBrightnessContrast.FormDestroy(Sender: TObject);
begin
  FTempBitmap.Free;
end;

procedure TfrmBrightnessContrast.chckbxPreviewClick(Sender: TObject);
begin
  ExecuteBrightnessContrast;
end;

procedure TfrmBrightnessContrast.edtBrightnessChange(Sender: TObject);
var
  LChangedValue, LRightValue: Integer;
  LBrightContrastLayerPanel : TgmBrightContrastLayerPanel;
begin
  if not FBarIsChanging then
  begin
    FEditIsChanging := True;
    try

      try
        LChangedValue := StrToInt(edtBrightness.Text);
        EnsureValueInRange(LChangedValue, MIN_VALUE, MAX_VALUE);
        ggbrBrightness.Position := MEDIAN_VALUE + LChangedValue;
      except
        if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfBrightContrast) and
           FWorkingOnEffectLayer then
        begin
          LBrightContrastLayerPanel := TgmBrightContrastLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);
          LRightValue               := LBrightContrastLayerPanel.AdjustBrightness;
        end
        else
        begin
          LRightValue := FBrightnessAmount;
        end;

        edtBrightness.Text := IntToStr(LRightValue);
      end;

    finally
      FEditIsChanging := False;
    end;
  end;
end;

procedure TfrmBrightnessContrast.edtContrastChange(Sender: TObject);
var
  LChangedValue, LRightValue: Integer;
  LBrightContrastLayerPanel : TgmBrightContrastLayerPanel;
begin
  if not FBarIsChanging then
  begin
    FEditIsChanging := True;
    try

      try
        LChangedValue := StrToInt(edtContrast.Text);
        EnsureValueInRange(LChangedValue, MIN_VALUE, MAX_VALUE);
        ggbrContrast.Position := MEDIAN_VALUE + LChangedValue;
      except
        if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfBrightContrast) and
           FWorkingOnEffectLayer then
        begin
          LBrightContrastLayerPanel := TgmBrightContrastLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);
          LRightValue               := LBrightContrastLayerPanel.AdjustContrast;
        end
        else
        begin
          LRightValue := FContrastAmount;
        end;

        edtBrightness.Text := IntToStr(LRightValue);
      end;

    finally
      FEditIsChanging := False;
    end;
  end;
end;

procedure TfrmBrightnessContrast.btbtnOKClick(Sender: TObject);
var
  LCmdAim                  : TCommandAim;
  LHistoryStatePanel       : TgmHistoryStatePanel;
  LBrightContrastLayerPanel: TgmBrightContrastLayerPanel;
begin
  with ActiveChildForm do
  begin
    if (LayerPanelList.SelectedLayerPanel.LayerFeature = lfBrightContrast) and
       FWorkingOnEffectLayer then
    begin
      // if on brightness/contrast layer...
      LBrightContrastLayerPanel           := TgmBrightContrastLayerPanel(LayerPanelList.SelectedLayerPanel);
      LBrightContrastLayerPanel.IsPreview := chckbxPreview.Checked;
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
        'Brightness/Contrast',
        frmMain.FBeforeProc,
        frmMain.FAfterProc,
        Selection,
        ChannelManager.SelectedAlphaChannelIndex);

      HistoryManager.AddHistoryState(LHistoryStatePanel);

      WriteInfoToIniFile(SECTION_BRIGHT_CONTRAST_DIALOG,
                         IDENT_BRIGHT_CONTRAST_PREVIEW,
                         IntToStr(Integer(chckbxPreview.Checked)));
    end;
  end;
end; 

end.
