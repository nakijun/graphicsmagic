{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang, Ma Xiaoming and GraphicsMagic Team.
  All rights reserved. }

unit PathForm;

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
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin;

type
  TfrmPath = class(TForm)
    tlbrPathTools: TToolBar;
    tlbtnVertLine: TToolButton;
    tlbtnFillPath: TToolButton;
    tlbtnStrokePath: TToolButton;
    tlbtnLoadPathAsSelection: TToolButton;
    tlbtnCreateNewPath: TToolButton;
    tlbtnDeleteCurrentPath: TToolButton;
    scrlbxPathPanelContainer: TScrollBox;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormEndDock(Sender, Target: TObject; X, Y: Integer);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CreateNewPathClick(Sender: TObject);
    procedure DeleteCurrentPathClick(Sender: TObject);
    procedure FillPathClick(Sender: TObject);
    procedure PathPanelContainerClick(Sender: TObject);
    procedure StrokePathClick(Sender: TObject);
    procedure LoadPathAsSelectionClick(Sender: TObject);
  private
    FShowingUp: Boolean;  // indicating whether the form is currently showing up

    procedure SetShowingUp(const AValue: Boolean);
  public
    procedure UpdatePathOptions;

    property IsShowingUp: Boolean read FShowingUp write SetShowingUp;
  end;

var
  frmPath: TfrmPath;

implementation

uses
{ Graphics32 }
  GR32,
{ GraphicsMagic Lib }
  gmAlphaFuncs,
  gmCommands,
  gmGUIFuncs,
  gmHistoryManager,
  gmImageProcessFuncs,
  gmLayerAndChannel,
  gmPathPanels,
  gmPenTools,
  gmSelection,
  gmTypes,
{ GraphicsMagic Data Modules }
  MainDataModule,
  HistoryDataModule,
{ GraphicsMagic Forms/Dialogs }
  MainForm,
  HistoryForm,
  RichTextEditorForm;

{$R *.dfm}

const
  MIN_FORM_WIDTH  = 236;
  MIN_FORM_HEIGHT = 160;

procedure TfrmPath.UpdatePathOptions;
begin
  if ActiveChildForm <> nil then
  begin
    tlbtnCreateNewPath.Enabled     := True;
    tlbtnDeleteCurrentPath.Enabled := Assigned(ActiveChildForm.PathPanelList.SelectedPanel);

    tlbtnStrokePath.Enabled := Assigned(ActiveChildForm.PathPanelList.SelectedPanel) and
                               (ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.GetSelectedPathsCount > 0) and
                               ((ActiveChildForm.ChannelManager.CurrentChannelType in [wctLayerMask, wctQuickMask, wctAlpha])
                                or (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent]));

    tlbtnFillPath.Enabled := tlbtnStrokePath.Enabled;

    tlbtnLoadPathAsSelection.Enabled := Assigned(ActiveChildForm.PathPanelList.SelectedPanel) and
                                        (ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.GetSelectedPathsCount > 0);
  end
  else
  begin
    tlbtnCreateNewPath.Enabled       := False;
    tlbtnDeleteCurrentPath.Enabled   := False;
    tlbtnStrokePath.Enabled          := False;
    tlbtnFillPath.Enabled            := False;
    tlbtnLoadPathAsSelection.Enabled := False;
  end;
end;

procedure TfrmPath.SetShowingUp(const AValue: Boolean);
begin
  FShowingUp := AValue;

  if Assigned(ActiveChildForm) then
  begin
    ActiveChildForm.PathPanelList.IsAllowRefreshPathPanels := FShowingUp;
  end;
end;

procedure TfrmPath.FormCreate(Sender: TObject);
begin
  tlbtnFillPath.Enabled            := False;
  tlbtnStrokePath.Enabled          := False;
  tlbtnDeleteCurrentPath.Enabled   := False;
  tlbtnLoadPathAsSelection.Enabled := False;

  ManualDock(frmMain.pgcntrlDockSite3);
  Show;
  FShowingUp := False;
end;

procedure TfrmPath.FormShow(Sender: TObject);
begin
  UpdatePathOptions;
  SetShowingUp(True);
end;

procedure TfrmPath.FormEndDock(Sender, Target: TObject; X, Y: Integer);
begin
  SetShowingUp(True);
end;

procedure TfrmPath.FormResize(Sender: TObject);
begin
  if Self.Floating then
  begin
    if Width < MIN_FORM_WIDTH then
    begin
      Width := MIN_FORM_WIDTH;
      Abort;
    end;

    if Height < MIN_FORM_HEIGHT then
    begin
      Height := MIN_FORM_HEIGHT;
      Abort;
    end;
  end;
end;

procedure TfrmPath.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SetShowingUp(False);
end;

procedure TfrmPath.CreateNewPathClick(Sender: TObject);
var
  LOldPenPathList   : TgmPenPathList;
  LOldPathPanelIndex: Integer;
  LHistoryStatePanel: TgmHistoryStatePanel;
  LPathPanel        : TgmPathPanel;
begin
  if ActiveChildForm <> nil then
  begin
    if frmRichTextEditor.Visible or
       (ActiveChildForm.SelectionTransformation <> nil) or
       (ActiveChildForm.Crop <> nil) then
    begin
      Exit;
    end
  end;

  // For Undo/Redo
  if Assigned(ActiveChildForm.PathPanelList.SelectedPanel) then
  begin
    LOldPenPathList := TgmPenPathList.Create;
    LOldPenPathList.AssignPenPathListData(ActiveChildForm.PathPanelList.SelectedPanel.PenPathList);
  end
  else
  begin
    LOldPenPathList := nil;
  end;

  LOldPathPanelIndex := ActiveChildForm.PathPanelList.SelectedPanelIndex;

  // create new path panel
  if Assigned(ActiveChildForm.PathLayer) then
  begin
    ActiveChildForm.PathLayer.Bitmap.FillRect(0, 0,
      ActiveChildForm.PathLayer.Bitmap.Width,
      ActiveChildForm.PathLayer.Bitmap.Height, $00000000);
  end
  else
  begin
    ActiveChildForm.CreatePathLayer;
  end;

  ActiveChildForm.PathLayer.Bitmap.Changed;

  LPathPanel := TgmPathPanel.Create(scrlbxPathPanelContainer, pptNamedPath);

  LPathPanel.UpdateThumbnail(
    ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
    ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height,
    ActiveChildForm.PathOffsetVector);

  with ActiveChildForm.PathPanelList do
  begin
    if (Count = 0) or IfLastPathPanelNamed then
    begin
      AddPathPanelToList(LPathPanel);
    end
    else
    if (Count > 0) and (not IfLastPathPanelNamed) then
    begin
      InsertPathPanelToList(LPathPanel, Count - 1);
    end;
  end;

  // Undo/Redo
  LHistoryStatePanel := TgmNewPathStatePanel.Create(frmHistory.scrlbxHistory,
    dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
    LOldPathPanelIndex,
    ActiveChildForm.PathPanelList.SelectedPanelIndex,
    LOldPenPathList);

  ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);

  if Assigned(LOldPenPathList) then
  begin
    LOldPenPathList.Free;
  end;
end;

procedure TfrmPath.DeleteCurrentPathClick(Sender: TObject);
var
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  if ActiveChildForm <> nil then
  begin
    if frmRichTextEditor.Visible or
       (ActiveChildForm.SelectionTransformation <> nil) or
       (ActiveChildForm.Crop <> nil) then
    begin
      Exit;
    end;
  end;

  if ActiveChildForm.PathPanelList.Count > 0 then
  begin
    if Assigned(ActiveChildForm.PathPanelList.SelectedPanel) then
    begin
      if MessageDlg('Delete the path "' +
                    ActiveChildForm.PathPanelList.SelectedPanel.PathNameLabel.Caption + '"?',
                    mtConfirmation, [mbYes,mbNo], 0) = mrYes then
      begin
        // create Undo/Redo first
        LHistoryStatePanel := TgmDeletePathStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          ActiveChildForm.PathPanelList.SelectedPanelIndex);

        ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);

        // delete path panel
        ActiveChildForm.FPenPath := nil;
        ActiveChildForm.PathPanelList.DeleteSelectedPathPanel;
        ActiveChildForm.DeletePathLayer;

        tlbtnDeleteCurrentPath.Enabled := False;
        tlbtnStrokePath.Enabled        := False;
        tlbtnFillPath.Enabled          := False;
      end;
    end;
  end;
end;

procedure TfrmPath.FillPathClick(Sender: TObject);
var
  LOffsetVector     : TPoint;
  LProcessedPartBmp : TBitmap32;
  LFillColor        : TColor32;
  LCmdAim           : TCommandAim;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  LFillColor := $0;

  if ActiveChildForm <> nil then
  begin
    if (frmRichTextEditor.Visible) or
       (ActiveChildForm.SelectionTransformation <> nil) or
       (ActiveChildForm.Crop <> nil) then
    begin
      Exit;
    end;
  end;

  if ActiveChildForm.ChannelManager.CurrentChannelType = wctAlpha then
  begin
    if not Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
    begin
      MessageDlg('Could not process more than one alpha channels at a time.', mtError, [mbOK], 0);
      Exit;
    end;
  end;

  if Assigned(ActiveChildForm.PathPanelList.SelectedPanel) then
  begin
    // remember bitmap for creating Undo/Redo command
    if Assigned(ActiveChildForm.Selection) then
    begin
      frmMain.FBeforeProc.Assign(ActiveChildForm.Selection.CutOriginal);
    end
    else
    begin
      case ActiveChildForm.ChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            frmMain.FBeforeProc.Assign(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
          end;
          
        wctQuickMask:
          begin
            frmMain.FBeforeProc.Assign(ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
          end;
          
        wctLayerMask:
          begin
            frmMain.FBeforeProc.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsMaskLinked then
            begin
              ReplaceAlphaChannelWithMask(
                ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
            end;

            frmMain.FBeforeProc.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
          end;
      end;
    end;

    // filling the path
    if Assigned(ActiveChildForm.Selection) then
    begin
      case ActiveChildForm.ChannelManager.CurrentChannelType of
        wctAlpha, wctQuickMask, wctLayerMask:
          begin
            LFillColor := frmMain.ForeGrayColor;
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            LFillColor := frmMain.GlobalForeColor;
          end;
      end;

      if ActiveChildForm.Selection.IsCornerStretched then
      begin
        MessageDlg('Could not fill the selected paths on the selection,' + #10#13 +
                   'because the current selection was resized.', mtInformation, [mbOK], 0);
        Exit;
      end
      else
      begin
        ActiveChildForm.tmrMarchingAnts.Enabled := False;

        // calculating the offset of the path layer relative to the selection
        LOffsetVector.X := ActiveChildForm.PathOffsetVector.X - ActiveChildForm.Selection.FMaskBorderStart.X;
        LOffsetVector.Y := ActiveChildForm.PathOffsetVector.Y - ActiveChildForm.Selection.FMaskBorderStart.Y;

        // remember old transparency if we need
        if ActiveChildForm.ChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue] then
        begin
          if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsLockTransparency) or
             (ActiveChildForm.ChannelManager.SelectedColorChannelCount < 3) then
          begin
            CopyBitmap32(ActiveChildForm.LayerPanelList.SelectedLayerPanel.LastProcessed,
                         ActiveChildForm.Selection.CutOriginal);
          end;
        end;

        // create mask bitmap
        LProcessedPartBmp := TBitmap32.Create;
        try
          LProcessedPartBmp.SetSize(ActiveChildForm.Selection.CutOriginal.Width,
                                    ActiveChildForm.Selection.CutOriginal.Height);

          LProcessedPartBmp.Clear(clBlack32);

          // fill the path on the selection
          ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.FillSelectedPaths(
            ActiveChildForm.Selection.CutOriginal.Canvas, LFillColor,
            frmMain.GlobalBrushStyle, LOffsetVector);

          // filling on mask
          ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.FillSelectedPaths(
            LProcessedPartBmp.Canvas, clWhite, frmMain.GlobalBrushStyle,
            LOffsetVector);

          // restore the alpha channels
          if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsLockTransparency then
          begin
            case ActiveChildForm.ChannelManager.CurrentChannelType of
              wctRGB, wctRed, wctGreen, wctBlue:
                begin
                  ReplaceAlphaChannelWithSource(ActiveChildForm.Selection.CutOriginal,
                    ActiveChildForm.LayerPanelList.SelectedLayerPanel.LastProcessed);
                end;
          
              wctAlpha, wctQuickMask, wctLayerMask:
                begin
                  ReplaceAlphaChannelWithNewValue(ActiveChildForm.Selection.CutOriginal, 255);
                end;
            end;
          end
          else
          begin
            if (ActiveChildForm.ChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue]) and
               (ActiveChildForm.ChannelManager.SelectedColorChannelCount < 3) then
            begin
              ReplaceAlphaChannelWithSource(ActiveChildForm.Selection.CutOriginal,
                ActiveChildForm.LayerPanelList.SelectedLayerPanel.LastProcessed);
            end
            else
            begin
              // restore Alpha channel on processed part
              MakeCanvasProcessedOpaque(ActiveChildForm.Selection.CutOriginal, LProcessedPartBmp);
            end;
          end;

          // channel replacement
          if ActiveChildForm.ChannelManager.CurrentChannelType in
               [wctRGB, wctRed, wctGreen, wctBlue] then
          begin
            ReplaceRGBChannels(frmMain.FBeforeProc, ActiveChildForm.Selection.CutOriginal,
                               LProcessedPartBmp, ActiveChildForm.ChannelManager.ChannelSelectedSet,
                               crsRemainDest);
          end;

        finally
          LProcessedPartBmp.Free;
        end;

        ActiveChildForm.ShowProcessedSelection;
        ActiveChildForm.tmrMarchingAnts.Enabled := True;
      end;

      // for Undo/Redo
      frmMain.FAfterProc.Assign(ActiveChildForm.Selection.CutOriginal);
    end
    else
    begin
      case ActiveChildForm.ChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.FillSelectedPaths(
              ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Canvas,
              frmMain.ForeGrayColor, frmMain.GlobalBrushStyle,
              ActiveChildForm.PathOffsetVector);

            ReplaceAlphaChannelWithNewValue(
              ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap, 255);

            ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;

            // for Undo/Redo
            frmMain.FAfterProc.Assign(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
          end;

        wctQuickMask:
          begin
            ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.FillSelectedPaths(
              ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.Canvas,
              frmMain.ForeGrayColor, frmMain.GlobalBrushStyle,
              ActiveChildForm.PathOffsetVector);

            ReplaceAlphaChannelWithNewValue(
              ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap, 255);

            ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Changed;

            // for Undo/Redo
            frmMain.FAfterProc.Assign(ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
          end;

        wctLayerMask:
          begin
            ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.FillSelectedPaths(
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Canvas,
              frmMain.ForeGrayColor, frmMain.GlobalBrushStyle,
              ActiveChildForm.PathOffsetVector);

            ReplaceAlphaChannelWithNewValue(ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap, 255);

            if Assigned(ActiveChildForm.ChannelManager.LayerMaskPanel) then
            begin
              ActiveChildForm.ChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(
                0, 0, ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
            end;

            ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;

            // for Undo/Redo
            frmMain.FAfterProc.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            // remember old transparency if we need
            if ActiveChildForm.ChannelManager.CurrentChannelType in
                 [wctRGB, wctRed, wctGreen, wctBlue] then
            begin
              if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsLockTransparency) or
                 (ActiveChildForm.ChannelManager.SelectedColorChannelCount < 3) then
              begin
                CopyBitmap32(ActiveChildForm.LayerPanelList.SelectedLayerPanel.LastProcessed,
                             ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
              end;
            end;

            ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.FillSelectedPaths(
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Canvas,
              frmMain.GlobalForeColor, frmMain.GlobalBrushStyle,
              ActiveChildForm.PathOffsetVector);

            ActiveChildForm.LayerPanelList.SelectedLayerPanel.ProcessedPart.SetSize(
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height);

            ActiveChildForm.LayerPanelList.SelectedLayerPanel.ProcessedPart.Clear(clBlack);

            ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.FillSelectedPaths(
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.ProcessedPart.Canvas, clWhite,
              frmMain.GlobalBrushStyle, ActiveChildForm.PathOffsetVector);

            // restore the alpha channels
            if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsLockTransparency) or
               (ActiveChildForm.ChannelManager.SelectedColorChannelCount < 3) then
            begin
              ReplaceAlphaChannelWithSource(
                ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                ActiveChildForm.LayerPanelList.SelectedLayerPanel.LastProcessed);
            end
            else
            begin
              // restore Alpha channel on processed part
              MakeCanvasProcessedOpaque(
                ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                ActiveChildForm.LayerPanelList.SelectedLayerPanel.ProcessedPart);
            end;

            // channel replacement
            ReplaceRGBChannels(frmMain.FBeforeProc,
                               ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                               ActiveChildForm.LayerPanelList.SelectedLayerPanel.ProcessedPart,
                               ActiveChildForm.ChannelManager.ChannelSelectedSet,
                               crsRemainDest);

            // for Undo/Redo
            frmMain.FAfterProc.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

            ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;
          end;
      end;
    end;

    // update thumbnails
    ActiveChildForm.UpdateThumbnailsBySelectedChannel;

{ Create Undo/Redo }

    LCmdAim := ActiveChildForm.GetCommandAimByCurrentChannel;

    LHistoryStatePanel := TgmImageManipulatingStatePanel.Create(
      frmHistory.scrlbxHistory,
      dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
      LCmdAim,
      'Fill Path',
      frmMain.FBeforeProc,
      frmMain.FAfterProc,
      ActiveChildForm.Selection,
      ActiveChildForm.ChannelManager.SelectedAlphaChannelIndex);

    if Assigned(LHistoryStatePanel) then
    begin
      ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);
    end;
  end;
end;

procedure TfrmPath.PathPanelContainerClick(Sender: TObject);
begin
  if ActiveChildForm <> nil then
  begin
    if frmRichTextEditor.Visible or
       (ActiveChildForm.SelectionTransformation <> nil) or
       (ActiveChildForm.Crop <> nil) then
    begin
      Exit;
    end;
  end;

  if Assigned(ActiveChildForm.PathPanelList.SelectedPanel) then
  begin
    ActiveChildForm.FPenPath := nil;

    ActiveChildForm.PathPanelList.DeselectAllPathPanels;
    ActiveChildForm.PathPanelList.UpdateAllPanelsState;
    ActiveChildForm.DeletePathLayer;
    
    ActiveChildForm.imgDrawingArea.Cursor := crPenToolDeselected;
    Screen.Cursor                         := crDefault;
  end;
end;

procedure TfrmPath.StrokePathClick(Sender: TObject);
var
  LOffsetVector         : TPoint;
  LProcessedPartBmp     : TBitmap32;
  LPenColor, LBrushColor: TColor32;
  LCmdAim               : TCommandAim;
  LHistoryStatePanel    : TgmHistoryStatePanel;
begin
  LPenColor   := $0;
  LBrushColor := $0;

  if ActiveChildForm <> nil then
  begin
    if (frmRichTextEditor.Visible) or
       (ActiveChildForm.SelectionTransformation <> nil) or
       (ActiveChildForm.Crop <> nil) then
    begin
      Exit;
    end;
  end;

  if ActiveChildForm.ChannelManager.CurrentChannelType = wctAlpha then
  begin
    if not Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
    begin
      MessageDlg('Could not process more than one alpha channels at a time.', mtError, [mbOK], 0);
      Exit;
    end;
  end;

  if Assigned(ActiveChildForm.PathPanelList.SelectedPanel) then
  begin
    // remember bitmap for creating Undo/Redo command
    if Assigned(ActiveChildForm.Selection) then
    begin
      frmMain.FBeforeProc.Assign(ActiveChildForm.Selection.CutOriginal);
    end
    else
    begin
      case ActiveChildForm.ChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            frmMain.FBeforeProc.Assign(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
          end;
          
        wctQuickMask:
          begin
            frmMain.FBeforeProc.Assign(ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
          end;
          
        wctLayerMask:
          begin
            frmMain.FBeforeProc.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
          end;
          
        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsMaskLinked then
            begin
              ReplaceAlphaChannelWithMask(
                ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
            end;

            frmMain.FBeforeProc.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
          end;
      end;
    end;

    // stroke path
    if Assigned(ActiveChildForm.Selection) then
    begin
      if ActiveChildForm.Selection.IsCornerStretched then
      begin
        MessageDlg('Could not stroke the selected paths on the selection,' + #10#13 +
                   'because the current selection was resized.', mtInformation, [mbOK], 0);
        Exit;
      end
      else
      begin
        // setting the pen and brush
        case ActiveChildForm.ChannelManager.CurrentChannelType of
          wctAlpha, wctQuickMask, wctLayerMask:
            begin
              LPenColor   := frmMain.ForeGrayColor;
              LBrushColor := frmMain.BackGrayColor;
            end;

          wctRGB, wctRed, wctGreen, wctBlue:
            begin
              LPenColor   := frmMain.GlobalForeColor;
              LBrushColor := frmMain.GlobalBackColor;
            end;
        end;

        ActiveChildForm.tmrMarchingAnts.Enabled := False;

        // calculating the offset of the path layer relative to the selection
        LOffsetVector.X := ActiveChildForm.PathOffsetVector.X - ActiveChildForm.Selection.FMaskBorderStart.X;
        LOffsetVector.Y := ActiveChildForm.PathOffsetVector.Y - ActiveChildForm.Selection.FMaskBorderStart.Y;

        // remember old transparency if we need
        if ActiveChildForm.ChannelManager.CurrentChannelType in
             [wctRGB, wctRed, wctGreen, wctBlue] then
        begin
          if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsLockTransparency) or
             (ActiveChildForm.ChannelManager.SelectedColorChannelCount < 3) then
          begin
            CopyBitmap32(ActiveChildForm.LayerPanelList.SelectedLayerPanel.LastProcessed,
                         ActiveChildForm.Selection.CutOriginal);
          end;
        end;

        // create mask bitmap
        LProcessedPartBmp := TBitmap32.Create;
        try
          LProcessedPartBmp.SetSize(ActiveChildForm.Selection.CutOriginal.Width,
                                    ActiveChildForm.Selection.CutOriginal.Height);

          LProcessedPartBmp.Clear(clBlack32);

          // stroke the path on selection
          ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.StrokeSelectedPaths(
            ActiveChildForm.Selection.CutOriginal.Canvas, frmMain.GlobalPenWidth,
            LPenColor, LBrushColor, frmMain.GlobalPenStyle,
            frmMain.GlobalBrushStyle, LOffsetVector);

          // stroke on mask
          ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.StrokeSelectedPaths(
            LProcessedPartBmp.Canvas, frmMain.GlobalPenWidth, clWhite, clWhite,
            frmMain.GlobalPenStyle, frmMain.GlobalBrushStyle, LOffsetVector);

          // restore the alpha channels
          if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsLockTransparency then
          begin
            case ActiveChildForm.ChannelManager.CurrentChannelType of
              wctRGB, wctRed, wctGreen, wctBlue:
                begin
                  ReplaceAlphaChannelWithSource(ActiveChildForm.Selection.CutOriginal,
                    ActiveChildForm.LayerPanelList.SelectedLayerPanel.LastProcessed);
                end;
          
              wctAlpha, wctQuickMask, wctLayerMask:
                begin
                  ReplaceAlphaChannelWithNewValue(ActiveChildForm.Selection.CutOriginal, 255);
                end;
            end;
          end
          else
          begin
            if (ActiveChildForm.ChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue]) and
               (ActiveChildForm.ChannelManager.SelectedColorChannelCount < 3) then
            begin
              ReplaceAlphaChannelWithSource(ActiveChildForm.Selection.CutOriginal,
                ActiveChildForm.LayerPanelList.SelectedLayerPanel.LastProcessed);
            end
            else
            begin
              // restore Alpha channel on processed part
              MakeCanvasProcessedOpaque(ActiveChildForm.Selection.CutOriginal, LProcessedPartBmp);
            end;
          end;

          // channel replacement
          if ActiveChildForm.ChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue] then
          begin
            ReplaceRGBChannels(frmMain.FBeforeProc, ActiveChildForm.Selection.CutOriginal,
                               LProcessedPartBmp, ActiveChildForm.ChannelManager.ChannelSelectedSet,
                               crsRemainDest);
          end;
        finally
          LProcessedPartBmp.Free;
        end;

        ActiveChildForm.ShowProcessedSelection;
        ActiveChildForm.tmrMarchingAnts.Enabled := True;

        // for Undo/Redo
        frmMain.FAfterProc.Assign(ActiveChildForm.Selection.CutOriginal);
      end;
    end
    else
    begin
      case ActiveChildForm.ChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.StrokeSelectedPaths(
              ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Canvas,
              frmMain.GlobalPenWidth, frmMain.ForeGrayColor, frmMain.BackGrayColor,
              frmMain.GlobalPenStyle, frmMain.GlobalBrushStyle,
              ActiveChildForm.PathOffsetVector);

            ReplaceAlphaChannelWithNewValue(
              ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap, 255);

            ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;

            // for Undo/Redo
            frmMain.FAfterProc.Assign(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
          end;

        wctQuickMask:
          begin
            ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.StrokeSelectedPaths(
              ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.Canvas,
              frmMain.GlobalPenWidth, frmMain.ForeGrayColor, frmMain.BackGrayColor,
              frmMain.GlobalPenStyle, frmMain.GlobalBrushStyle,
              ActiveChildForm.PathOffsetVector);

            ReplaceAlphaChannelWithNewValue(
              ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap, 255);

            ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Changed;

            // for Undo/Redo
            frmMain.FAfterProc.Assign(ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
          end;

        wctLayerMask:
          begin
            ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.StrokeSelectedPaths(
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Canvas,
              frmMain.GlobalPenWidth, frmMain.ForeGrayColor, frmMain.BackGrayColor,
              frmMain.GlobalPenStyle, frmMain.GlobalBrushStyle,
              ActiveChildForm.PathOffsetVector);

            ReplaceAlphaChannelWithNewValue(
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap, 255);

            if Assigned(ActiveChildForm.ChannelManager.LayerMaskPanel) then
            begin
              ActiveChildForm.ChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(
                0, 0, ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
            end;

            ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;

            // for Undo/Redo
            frmMain.FAfterProc.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            // remember old transparency if we need
            if ActiveChildForm.ChannelManager.CurrentChannelType in
                 [wctRGB, wctRed, wctGreen, wctBlue] then
            begin
              if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsLockTransparency) or
                 (ActiveChildForm.ChannelManager.SelectedColorChannelCount < 3) then
              begin
                CopyBitmap32(ActiveChildForm.LayerPanelList.SelectedLayerPanel.LastProcessed,
                             ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
              end;
            end;

            ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.StrokeSelectedPaths(
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Canvas,
              frmMain.GlobalPenWidth, frmMain.GlobalForeColor, frmMain.GlobalBackColor,
              frmMain.GlobalPenStyle, frmMain.GlobalBrushStyle,
              ActiveChildForm.PathOffsetVector);

            ActiveChildForm.LayerPanelList.SelectedLayerPanel.ProcessedPart.SetSize(
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height);

            ActiveChildForm.LayerPanelList.SelectedLayerPanel.ProcessedPart.Clear(clBlack);

            ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.StrokeSelectedPaths(
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.ProcessedPart.Canvas,
              frmMain.GlobalPenWidth, clWhite, clWhite, frmMain.GlobalPenStyle,
              frmMain.GlobalBrushStyle, ActiveChildForm.PathOffsetVector);

            // restore the alpha channels
            if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsLockTransparency) or
               (ActiveChildForm.ChannelManager.SelectedColorChannelCount < 3) then
            begin
              ReplaceAlphaChannelWithSource(
                ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                ActiveChildForm.LayerPanelList.SelectedLayerPanel.LastProcessed);
            end
            else
            begin
              // restore Alpha channel on processed part
              MakeCanvasProcessedOpaque(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                                        ActiveChildForm.LayerPanelList.SelectedLayerPanel.ProcessedPart);
            end;

            // channel replacement
            ReplaceRGBChannels(frmMain.FBeforeProc,
                               ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                               ActiveChildForm.LayerPanelList.SelectedLayerPanel.ProcessedPart,
                               ActiveChildForm.ChannelManager.ChannelSelectedSet,
                               crsRemainDest);

            // for Undo/Redo
            frmMain.FAfterProc.Assign(
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

            ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;
          end;
      end;
    end;

    // update thumbnails
    ActiveChildForm.UpdateThumbnailsBySelectedChannel;

{ Create Undo/Redo }

    LCmdAim := ActiveChildForm.GetCommandAimByCurrentChannel;

    LHistoryStatePanel := TgmImageManipulatingStatePanel.Create(
      frmHistory.scrlbxHistory,
      dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
      LCmdAim,
      'Stroke Path',
      frmMain.FBeforeProc,
      frmMain.FAfterProc,
      ActiveChildForm.Selection,
      ActiveChildForm.ChannelManager.SelectedAlphaChannelIndex);

    if Assigned(LHistoryStatePanel) then
    begin
      ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);
    end;
  end;
end;

procedure TfrmPath.LoadPathAsSelectionClick(Sender: TObject);
var
  LOldSelection     : TgmSelection;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  if ActiveChildForm <> nil then
  begin
    if frmRichTextEditor.Visible or
       (ActiveChildForm.SelectionTransformation <> nil) or
       (ActiveChildForm.Crop <> nil) then
    begin
      Exit;
    end;
  end;

  if ActiveChildForm.ChannelManager.CurrentChannelType = wctAlpha then
  begin
    if not Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
    begin
      MessageDlg('Could not process more than one alpha channels at a time.', mtError, [mbOK], 0);
      Exit;
    end;
  end;

  // Record selection data for Undo/Redo.
  if Assigned(ActiveChildForm.Selection) then
  begin
    LOldSelection := TgmSelection.Create;
    LOldSelection.AssignAllSelectionData(ActiveChildForm.Selection);
  end
  else
  begin
    LOldSelection := nil;
  end;

  ActiveChildForm.LoadPathAsSelection;

  // Undo/Redo
  LHistoryStatePanel := TgmPathToSelectionStatePanel.Create(
    frmHistory.scrlbxHistory,
    dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX], LOldSelection,
    ActiveChildForm.PathPanelList.SelectedPanel.PenPathList);

  ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);

  if Assigned(LOldSelection) then
  begin
    FreeAndNil(LOldSelection);
  end;
end;

end.
 