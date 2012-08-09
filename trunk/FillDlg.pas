{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

unit FillDlg;

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
{ GraphicsMagic Lib }
  gmFill, GR32_Image;

type
  TfrmFill = class(TForm)
    grpbxFillContent: TGroupBox;
    grpbxFillBlend: TGroupBox;
    lblUseFillMode: TLabel;
    cmbbxFillOptions: TComboBox;
    lblCustomPattern: TLabel;
    pnlCustomPattern: TPanel;
    spdbtnSelectPattern: TSpeedButton;
    lblBlendMode: TLabel;
    cmbbxBlendMode: TComboBox;
    lblBlendOpacity: TLabel;
    edtBlendOpacity: TEdit;
    updwnBlendOpacity: TUpDown;
    btbtnOK: TBitBtn;
    btbtnCancel: TBitBtn;
    chckbxPreserveTransparency: TCheckBox;
    Label1: TLabel;
    imgSelectedPattern: TImage32;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cmbbxFillOptionsChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cmbbxBlendModeChange(Sender: TObject);
    procedure edtBlendOpacityChange(Sender: TObject);
    procedure chckbxPreserveTransparencyClick(Sender: TObject);
    procedure btbtnOKClick(Sender: TObject);
    procedure spdbtnSelectPatternClick(Sender: TObject);
  private
    FFillTool: TgmFill;

    procedure UpdateFillDlg;
    function FillOnSelection: Boolean;
    function FillOnAlphaChannel: Boolean;
    function FillOnQuickMask: Boolean;
    function FillOnLayerMask: Boolean;
    function FillOnLayer:Boolean;
    function ExecuteFill: Boolean;
  public
    { Public declarations }
  end;

var
  frmFill: TfrmFill;

implementation

uses
{ Graphics32 }
  GR32,
{ Externals }
  GR32_Add_BlendModes,
{ GraphicsMagic Lib }
  gmTypes,
  gmImageProcessFuncs,
  gmAlphaFuncs,
  gmLayerAndChannel,
  gmCommands,
  gmHistoryManager,
{ GraphicsMagic Data Modules }
  HistoryDataModule,
{ GraphicsMagic Forms/Dialogs }
  MainForm,
  LayerForm,
  PatternsPopFrm,    // frmPatterns
  HistoryForm;

{$R *.DFM}

procedure TfrmFill.UpdateFillDlg;
begin
  lblCustomPattern.Enabled    := FFillTool.FillOptions in [gmfoPattern];
  imgSelectedPattern.Enabled  := lblCustomPattern.Enabled;
  pnlCustomPattern.Enabled    := lblCustomPattern.Enabled;
  spdbtnSelectPattern.Enabled := lblCustomPattern.Enabled;
  edtBlendOpacity.Text        := IntToStr(FFillTool.Opacity);
end;

function TfrmFill.FillOnSelection: Boolean;
var
  LCuttedBmp: TBitmap32;
  LCutRect  : TRect;
begin
  Result := False;

  if FFillTool.FillOptions = gmfoHistory then
  begin
    if ActiveChildForm.ChannelManager.CurrentChannelType in
         [wctAlpha, wctQuickMask, wctLayerMask] then
    begin
      MessageDlg('Could not use the history fill because the' + #10#13 +
                 'history state does not contain a corresponding' + #10#13 +
                 'layer.', mtError, [mbOK], 0);

      Exit;
    end
    else
    begin
      // must be on layer...
      if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
           lfBackground, lfTransparent] then
      begin
        // cut from history bitmap

        LCuttedBmp := TBitmap32.Create;
        try
          LCuttedBmp.DrawMode := dmBlend;

          LCuttedBmp.Width  := Abs(ActiveChildForm.Selection.FMaskBorderEnd.X - ActiveChildForm.Selection.FMaskBorderStart.X) + 1;
          LCuttedBmp.Height := Abs(ActiveChildForm.Selection.FMaskBorderEnd.Y - ActiveChildForm.Selection.FMaskBorderStart.Y) + 1;

          LCutRect := Rect(ActiveChildForm.Selection.FMaskBorderStart.X,
                           ActiveChildForm.Selection.FMaskBorderStart.Y,
                           ActiveChildForm.Selection.FMaskBorderEnd.X + 1,
                           ActiveChildForm.Selection.FMaskBorderEnd.Y + 1);

          CopyRect32WithARGB(LCuttedBmp, ActiveChildForm.HistoryBitmap, LCutRect, clWhite32);
          FFillTool.SetForegroundWithHistory(LCuttedBmp);

          // make the original cropped area of the selection same as the forground of the selection
          ActiveChildForm.Selection.CutOriginal.Assign(ActiveChildForm.Selection.Foreground);
        finally
          LCuttedBmp.Free;
        end;
      end;
    end;
  end
  else
  if FFillTool.FillOptions = gmfoPattern then
  begin
    FFillTool.SetForegroundWithPattern(ActiveChildForm.Selection.Foreground.Width,
                                       ActiveChildForm.Selection.Foreground.Height,
                                       frmPatterns.FillingPattern);

    // make the original cropped area of the selection same as the forground of the selection
    ActiveChildForm.Selection.CutOriginal.Assign(ActiveChildForm.Selection.Foreground);
  end;

  // filling
  FFillTool.DoFill32(ActiveChildForm.Selection.CutOriginal);
  ActiveChildForm.ShowProcessedSelection;

  Result := True;
end;

function TfrmFill.FillOnAlphaChannel: Boolean;
begin
  Result := False;

  if not Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
  begin
    Exit;
  end;

  if FFillTool.FillOptions = gmfoHistory then
  begin
    MessageDlg('Could not use the history fill because the' + #10#13 +
               'history state does not contain a corresponding' + #10#13 +
               'layer.', mtError, [mbOK], 0);

    Exit;
  end
  else
  if FFillTool.FillOptions = gmfoPattern then
  begin
    FFillTool.SetForegroundWithPattern(
      ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Width,
      ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Height,
      frmPatterns.FillingPattern);
  end;

  // filling
  FFillTool.DoFill32(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
  ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;

  Result := True;
end;

function TfrmFill.FillOnQuickMask: Boolean;
begin
  Result := False;

  if not Assigned(ActiveChildForm.ChannelManager.QuickMaskPanel) then
  begin
    Exit;
  end;

  if FFillTool.FillOptions = gmfoHistory then
  begin
    MessageDlg('Could not use the history fill because the' + #10#13 +
               'history state does not contain a corresponding' + #10#13 +
               'layer.', mtError, [mbOK], 0);

    Exit;
  end
  else
  if FFillTool.FillOptions = gmfoPattern then
  begin
    FFillTool.SetForegroundWithPattern(
      ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.Width,
      ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.Height,
      frmPatterns.FillingPattern);
  end;

  // filling
  FFillTool.DoFill32(ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
  ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Changed;
  
  Result := True;
end;

function TfrmFill.FillOnLayerMask: Boolean;
begin
  Result := False;

  with ActiveChildForm do
  begin
    if FFillTool.FillOptions = gmfoHistory then
    begin
      MessageDlg('Could not use the history fill because the' + #10#13 +
                 'history state does not contain a corresponding' + #10#13 +
                 'layer.', mtError, [mbOK], 0);

      Exit;
    end
    else
    if FFillTool.FillOptions = gmfoPattern then
    begin
      FFillTool.SetForegroundWithPattern(
        LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
        LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height,
        frmPatterns.FillingPattern);
    end;

    // filling
    FFillTool.DoFill32(LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);

    if Assigned(ChannelManager.LayerMaskPanel) then
    begin
      ChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(
        0, 0, LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
    end;

    LayerPanelList.SelectedLayerPanel.Update;
  end;

  Result := True;
end; 

function TfrmFill.FillOnLayer: Boolean;
begin
  Result := False;

  with ActiveChildForm do
  begin
    if LayerPanelList.SelectedLayerPanel.LayerFeature in [
         lfBackground, lfTransparent] then
    begin
      if FFillTool.FillOptions = gmfoHistory then
      begin
        if (HistoryBitmap.Width  <> LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width) or
           (HistoryBitmap.Height <> LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height) then
        begin
          MessageDlg('Could not use the history fill, because the current' + #10#13 +
                     'canvas size does not match that of the history state!',
                     mtError, [mbOK], 0);

          Exit;
        end;

        FFillTool.SetForegroundWithHistory(HistoryBitmap);
      end
      else
      if FFillTool.FillOptions = gmfoPattern then
      begin
        FFillTool.SetForegroundWithPattern(
          LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
          LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height,
          frmPatterns.FillingPattern);
      end;

      // Restore the alpha channels of current layer to last state that has not been applied the mask.
      if LayerPanelList.SelectedLayerPanel.IsMaskLinked then
      begin
        ReplaceAlphaChannelWithMask(LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                                    LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
      end;

      // filling
      FFillTool.DoFill32(LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

      if LayerPanelList.SelectedLayerPanel.IsHasMask then
      begin
        // save the new alpha channels for the filled layer
        GetAlphaChannelBitmap(LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                              LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
      end;

      LayerPanelList.SelectedLayerPanel.Update;

      Result := True;
    end;
  end;
end; 

function TfrmFill.ExecuteFill: Boolean;
begin
  Result := False;

  if Assigned(ActiveChildForm.Selection) then
  begin
    Result := FillOnSelection;
  end
  else
  begin
    case ActiveChildForm.ChannelManager.CurrentChannelType of
      wctAlpha:
        begin
          Result := FillOnAlphaChannel;
        end;

      wctQuickMask:
        begin
          Result := FillOnQuickMask;
        end;

      wctLayerMask:
        begin
          Result := FillOnLayerMask;
        end;

      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          Result := FillOnLayer;
        end;
    end;
  end;
end;

procedure TfrmFill.FormCreate(Sender: TObject);
begin
  FFillTool                  := TgmFill.Create;
  FFillTool.FillOptions      := gmfoForeground;
  cmbbxFillOptions.ItemIndex := 0;
  cmbbxBlendMode.Items       := BlendModeList;
  cmbbxBlendMode.ItemIndex   := 0;
  updwnBlendOpacity.Position := 100;
end;

procedure TfrmFill.FormDestroy(Sender: TObject);
begin
  FFillTool.Free;
end; 

procedure TfrmFill.cmbbxFillOptionsChange(Sender: TObject);
begin
  case cmbbxFillOptions.ItemIndex of
    0:
      begin // foreground color filling
        FFillTool.FillMode := gmfmColorFill;

        if ActiveChildForm.ChannelManager.CurrentChannelType in
             [wctAlpha, wctQuickMask, wctLayerMask] then
        begin
          FFillTool.FillColor := Color32(frmMain.ForeGrayColor);
        end
        else
        begin
          FFillTool.FillColor := Color32(frmMain.GlobalForeColor);
        end;
      end;

    1:
      begin // background color filling
        FFillTool.FillMode := gmfmColorFill;

        if ActiveChildForm.ChannelManager.CurrentChannelType in
             [wctAlpha, wctQuickMask, wctLayerMask] then
        begin
          FFillTool.FillColor := Color32(frmMain.BackGrayColor);
        end
        else
        begin
          FFillTool.FillColor := Color32(frmMain.GlobalBackColor);
        end;
      end;

    2, 3:
      begin
        FFillTool.FillMode := gmfmBitmapFill;  // pattern/history filling
      end;

    4:
      begin // black filling
        FFillTool.FillMode  := gmfmColorFill;
        FFillTool.FillColor := clBlack32;
      end;

    5:
      begin // 50% gray filling
        FFillTool.FillMode  := gmfmColorFill;
        FFillTool.FillColor := clGray32;
      end;

    6:
      begin // white filling
        FFillTool.FillMode  := gmfmColorFill;
        FFillTool.FillColor := clWhite32;
      end; 
  end;

  FFillTool.FillOptions := TgmFillOptions(cmbbxFillOptions.ItemIndex);

  UpdateFillDlg;
end;

procedure TfrmFill.FormShow(Sender: TObject);
begin
  with ActiveChildForm do
  begin
    FFillTool.SelectedChannelSet := ChannelManager.ChannelSelectedSet;
    cmbbxFillOptionsChange(Sender);

    // for undo/redo
    if Assigned(Selection) then
    begin
      frmMain.FBeforeProc.Assign(Selection.CutOriginal);
    end
    else
    begin
      case ChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            if Assigned(ChannelManager.SelectedAlphaChannelPanel) then
            begin
              frmMain.FBeforeProc.Assign(ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
            end;
          end;

        wctQuickMask:
          begin
            if Assigned(ChannelManager.QuickMaskPanel) then
            begin
              frmMain.FBeforeProc.Assign(ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
            end;
          end;

        wctLayerMask:
          begin
            frmMain.FBeforeProc.Assign(LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
          end;
          
        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            if LayerPanelList.SelectedLayerPanel.LayerFeature in [
                 lfBackground, lfTransparent] then
            begin
              frmMain.FBeforeProc.Assign(LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

              if LayerPanelList.SelectedLayerPanel.IsMaskLinked then
              begin
                ReplaceAlphaChannelWithMask(
                  frmMain.FBeforeProc, LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
              end;
            end;
          end;
      end;
    end;
  end;
end;

procedure TfrmFill.cmbbxBlendModeChange(Sender: TObject);
begin
  FFillTool.BlendMode := TBlendMode32(cmbbxBlendMode.ItemIndex);
end;

procedure TfrmFill.edtBlendOpacityChange(Sender: TObject);
begin
  try
    updwnBlendOpacity.Position := StrToInt(edtBlendOpacity.Text);
    FFillTool.Opacity          := updwnBlendOpacity.Position;
  except
    edtBlendOpacity.Text := IntToStr(updwnBlendOpacity.Position);
  end;
end; 

procedure TfrmFill.chckbxPreserveTransparencyClick(Sender: TObject);
begin
  FFillTool.IsPreserveTransparency := chckbxPreserveTransparency.Checked;
end;

procedure TfrmFill.btbtnOKClick(Sender: TObject);
var
  LCmdAim           : TCommandAim;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  if not ExecuteFill then
  begin
    ModalResult := mrNone;
    Exit;
  end;

  with ActiveChildForm do
  begin
    if Assigned(Selection) then
    begin
      frmMain.FAfterProc.Assign(Selection.CutOriginal);
    end
    else
    begin
      case ChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            if Assigned(ChannelManager.SelectedAlphaChannelPanel) then
            begin
              frmMain.FAfterProc.Assign(ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
            end;
          end;

        wctQuickMask:
          begin
            if Assigned(ChannelManager.QuickMaskPanel) then
            begin
              frmMain.FAfterProc.Assign(ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
            end;
          end;

        wctLayerMask:
          begin
            frmMain.FAfterProc.Assign(LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
          end;
          
        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            if LayerPanelList.SelectedLayerPanel.LayerFeature in [
                 lfBackground, lfTransparent] then
            begin
              frmMain.FAfterProc.Assign(LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

              if LayerPanelList.SelectedLayerPanel.IsMaskLinked then
              begin
                ReplaceAlphaChannelWithMask(
                  frmMain.FAfterProc, LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
              end;
            end;
          end;
      end;
    end;

    LCmdAim := GetCommandAimByCurrentChannel;

    LHistoryStatePanel := TgmImageManipulatingStatePanel.Create(
      frmHistory.scrlbxHistory,
      dmHistory.bmp32lstHistory.Bitmap[FILL_COMMAND_ICON_INDEX],
      LCmdAim,
      'Fill',
      frmMain.FBeforeProc,
      frmMain.FAfterProc,
      Selection,
      ChannelManager.SelectedAlphaChannelIndex);

    HistoryManager.AddHistoryState(LHistoryStatePanel);
  end;
end;

procedure TfrmFill.spdbtnSelectPatternClick(Sender: TObject);
var
  LShowingPoint: TPoint;
begin
  GetCursorPos(LShowingPoint);
  
  frmPatterns.Left            := LShowingPoint.X;
  frmPatterns.Top             := LShowingPoint.Y;
  frmPatterns.PatternListUser := pluFill;
  frmPatterns.Show;
end; 

end.
