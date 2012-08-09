{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

unit PosterizeDlg;

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
  StdCtrls, Buttons
{ GraphicsMagic Lib }
  ;

type
  TfrmPosterize = class(TForm)
    lblLevel: TLabel;
    edtLevel: TEdit;
    btbtnOK: TBitBtn;
    btbtnCancel: TBitBtn;
    chckbxPreview: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtLevelChange(Sender: TObject);
    procedure btbtnOKClick(Sender: TObject);
    procedure chckbxPreviewClick(Sender: TObject);
  private
    FLevel               : Byte;
    FWorkingOnEffectLayer: Boolean;

    procedure PosterizeOnSelection;
    procedure PosterizeOnAlphaChannel;
    procedure PosterizeOnQuickMask;
    procedure PosterizeOnLayerMask;
    procedure PosterizeOnLayer;
    procedure ExecutePosterize;
  public
    property IsWorkingOnEffectLayer: Boolean read FWorkingOnEffectLayer write FWorkingOnEffectLayer;
  end;

var
  frmPosterize: TfrmPosterize;

implementation

uses
{ Graphics32 }
  GR32,
{ GraphicsMagic Lib }
  gmTypes,
  gmIni,
  gmLayerAndChannel,
  gmImageProcessFuncs,
  gmMath,
  gmAlphaFuncs,
  gmCommands,
  gmHistoryManager,
{ GraphicsMagic Data Modules }
  HistoryDataModule,
{ GraphicsMagic Forms/Dialogs }
  MainForm,
  HistoryForm;

{$R *.DFM}

//-- Custom procedures and functions -------------------------------------------

procedure TfrmPosterize.PosterizeOnSelection;
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

    Posterize32(frmMain.FBeforeProc, frmMain.FAfterProc, 255 - FLevel,
                ChannelManager.ChannelSelectedSet);

    if chckbxPreview.Checked then
    begin
      Selection.CutOriginal.Assign(frmMain.FAfterProc);
      ShowProcessedSelection;
    end;
  end;
end;

procedure TfrmPosterize.PosterizeOnAlphaChannel;
begin
  with ActiveChildForm do
  begin
    if Assigned(ChannelManager.SelectedAlphaChannelPanel) then
    begin
      Posterize32(frmMain.FBeforeProc, frmMain.FAfterProc, 255 - FLevel,
                  ChannelManager.ChannelSelectedSet);

      if chckbxPreview.Checked then
      begin
        ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Assign(frmMain.FAfterProc);
        ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
      end;
    end;
  end;
end;

procedure TfrmPosterize.PosterizeOnQuickMask;
begin
  with ActiveChildForm do
  begin
    if Assigned(ChannelManager.QuickMaskPanel) then
    begin
      Posterize32(frmMain.FBeforeProc, frmMain.FAfterProc, 255 - FLevel,
                  ChannelManager.ChannelSelectedSet);

      if chckbxPreview.Checked then
      begin
        ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.Assign(frmMain.FAfterProc);
        ChannelManager.QuickMaskPanel.AlphaLayer.Changed;
      end;
    end;
  end;
end;

procedure TfrmPosterize.PosterizeOnLayerMask;
begin
  with ActiveChildForm do
  begin
    Posterize32(frmMain.FBeforeProc, frmMain.FAfterProc, 255 - FLevel,
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

procedure TfrmPosterize.PosterizeOnLayer;
begin
  with ActiveChildForm do
  begin
    if LayerPanelList.SelectedLayerPanel.LayerFeature in [
         lfBackground, lfTransparent] then
    begin
      Posterize32(frmMain.FBeforeProc, frmMain.FAfterProc, 255 - FLevel,
                  ChannelManager.ChannelSelectedSet);
    end;

    if chckbxPreview.Checked then
    begin
      if (LayerPanelList.SelectedLayerPanel.LayerFeature = lfPosterize) and
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

procedure TfrmPosterize.ExecutePosterize;
begin
  if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfPosterize) and
     FWorkingOnEffectLayer then
  begin
    PosterizeOnLayer;
  end
  else
  begin
    if Assigned(ActiveChildForm.Selection) then
    begin
      PosterizeOnSelection;
    end
    else
    begin
      case ActiveChildForm.ChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            PosterizeOnAlphaChannel;
          end;

        wctQuickMask:
          begin
            PosterizeOnQuickMask;
          end;
          
        wctLayerMask:
          begin
            PosterizeOnLayerMask;
          end;
          
        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            PosterizeOnLayer;
          end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmPosterize.FormCreate(Sender: TObject);
begin
  FLevel                := StrToInt(ReadInfoFromIniFile(SECTION_POSTERIZE_DIALOG, IDENT_POSTERIZE_LEVELS, '2'));
  FWorkingOnEffectLayer := False;
end;

procedure TfrmPosterize.FormShow(Sender: TObject);
var
  LPosterizeLayerPanel: TgmPosterizeLayerPanel;
  LTempBmp            : TBitmap32;
begin
  // on Posterize layer
  if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfPosterize) and
     FWorkingOnEffectLayer then
  begin
    if Assigned(ActiveChildForm.Selection) then
    begin
      if Assigned(ActiveChildForm.SelectionHandleLayer) then
      begin
        ActiveChildForm.SelectionHandleLayer.Visible := False;
      end;
    end;

    LPosterizeLayerPanel := TgmPosterizeLayerPanel(
      ActiveChildForm.LayerPanelList.SelectedLayerPanel);
      
    chckbxPreview.Checked := LPosterizeLayerPanel.IsPreview;

    if edtLevel.Text = IntToStr(LPosterizeLayerPanel.Level) then
    begin
      ExecutePosterize;
    end
    else
    begin
      edtLevel.Text := IntToStr(LPosterizeLayerPanel.Level);
    end;
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

    chckbxPreview.Checked := Boolean(StrToInt(ReadInfoFromIniFile(SECTION_POSTERIZE_DIALOG, IDENT_POSTERIZE_PREVIEW, '1')));

    if edtLevel.Text = IntToStr(FLevel) then
    begin
      ExecutePosterize;
    end
    else
    begin
      edtLevel.Text := IntToStr(FLevel);
    end;
  end;
  
  ActiveControl := btbtnOK;
end; 

procedure TfrmPosterize.edtLevelChange(Sender: TObject);
var
  LChangedValue       : Integer;
  LRightValue         : Byte;
  LPosterizeLayerPanel: TgmPosterizeLayerPanel;
begin
  LPosterizeLayerPanel := nil;
  
  try
    LChangedValue := StrToInt(edtLevel.Text);

    EnsureValueInRange(LChangedValue, 0, 255);

    edtLevel.Text := IntToStr(LChangedValue);

    // on Posterize layer
    if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfPosterize) and
       FWorkingOnEffectLayer then
    begin
      LPosterizeLayerPanel := TgmPosterizeLayerPanel(
        ActiveChildForm.LayerPanelList.SelectedLayerPanel);
        
      LPosterizeLayerPanel.Level := LChangedValue;
    end
    else
    begin
      FLevel := LChangedValue;
    end;

    ExecutePosterize;

  except
    // on Posterize layer
    if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfPosterize) and
       FWorkingOnEffectLayer then
    begin
      LRightValue := LPosterizeLayerPanel.Level;
    end
    else
    begin
      LRightValue := FLevel;
    end;
       
    edtLevel.Text := IntToStr(LRightValue);
  end;
end;

procedure TfrmPosterize.btbtnOKClick(Sender: TObject);
var
  LCmdAim             : TCommandAim;
  LHistoryStatePanel  : TgmHistoryStatePanel;
  LPosterizeLayerPanel: TgmPosterizeLayerPanel;
begin
  if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfPosterize) and
     FWorkingOnEffectLayer then
  begin
    LPosterizeLayerPanel := TgmPosterizeLayerPanel(
      ActiveChildForm.LayerPanelList.SelectedLayerPanel);
      
    LPosterizeLayerPanel.IsPreview := chckbxPreview.Checked;
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
      'Posterize',
      frmMain.FBeforeProc,
      frmMain.FAfterProc,
      ActiveChildForm.Selection,
      ActiveChildForm.ChannelManager.SelectedAlphaChannelIndex);

    ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);

    WriteInfoToIniFile(SECTION_POSTERIZE_DIALOG, IDENT_POSTERIZE_LEVELS, IntToStr(FLevel));
    WriteInfoToIniFile(SECTION_POSTERIZE_DIALOG, IDENT_POSTERIZE_PREVIEW, IntToStr(Integer(chckbxPreview.Checked)));
  end;
end;

procedure TfrmPosterize.chckbxPreviewClick(Sender: TObject);
begin
  ExecutePosterize;
end;

end.
