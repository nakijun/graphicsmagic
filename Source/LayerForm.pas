{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang, Ma Xiaoming and GraphicsMagic Team.
  All rights reserved. }

unit LayerForm;

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
  Dialogs, ComCtrls, ToolWin, ExtCtrls, StdCtrls, GR32_RangeBars,
{ GraphicsMagic }
  gmLayerAndChannel;

type
  TfrmLayer = class(TForm)
    tlbrLayerTools: TToolBar;
    ToolButton2: TToolButton;
    tlbtnAdjustmentLayer: TToolButton;
    tlbtnAddMask: TToolButton;
    tlbtnNewLayer: TToolButton;
    tlbtnDeleteLayer: TToolButton;
    tlbrLayerBlend: TToolBar;
    ToolButton1: TToolButton;
    cmbbxLayerBlendMode: TComboBox;
    tlbrLayerOpacity: TToolBar;
    ToolButton3: TToolButton;
    ggbrLayerOpacity: TGaugeBar;
    edtLayerOpacityValue: TEdit;
    lblLayerOpacityPercent: TLabel;
    tlbrLayerLockTool: TToolBar;
    ToolButton5: TToolButton;
    lblLockOption: TLabel;
    chckbxLockTransparency: TCheckBox;
    imgLockTransparency: TImage;
    scrlbxLayers: TScrollBox;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormEndDock(Sender, Target: TObject; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure NewLayerClick(Sender: TObject);
    procedure AddMaskClick(Sender: TObject);
    procedure DeleteLayerClick(Sender: TObject);
    procedure AdjustmentLayerClick(Sender: TObject);
    procedure LayerBlendModeChange(Sender: TObject);
    procedure LayerOpacityChange(Sender: TObject);
    procedure ggbrLayerOpacityMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ggbrLayerOpacityMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure chckbxLockTransparencyMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure edtLayerOpacityValueChange(Sender: TObject);
    procedure edtLayerOpacityValueEnter(Sender: TObject);
    procedure edtLayerOpacityValueExit(Sender: TObject);
    procedure edtLayerOpacityValueKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FBarIsChanging: Boolean;
    FRecordCommand: Boolean;  // indicating whether to record commands
    FIsMouseDown  : Boolean;
    FShowingUp    : Boolean;  // indicating whether the form is currently showing up
    FOldOpacity   : Byte;     // For Undo/Redo

    procedure SetShowingUp(const AValue: Boolean);
  public
    // Enable or disable components of layer form.
    procedure UpdateLayerOptionsEnableStatus;
    procedure UpdateLayerOptions(const ALayerPanel: TgmLayerPanel);

    property IsRecordCommand: Boolean read FRecordCommand write FRecordCommand;
    property IsShowingUp    : Boolean read FShowingUp     write SetShowingUp;
  end;

var
  frmLayer: TfrmLayer;

implementation

uses
{ externals }
  GR32_Add_BlendModes,
{ GraphicsMagic Lib }
  gmTypes,
  gmMath,
  gmSelection,
  gmAlphaFuncs,
  gmGUIFuncs,
  gmHistoryManager,
  gmLayerPanelCommands,
{ GraphicsMagic Data Modules }
  MainDataModule,
  LayerDataModule,
  HistoryDataModule,
{ GraphicsMagic Forms/Dialogs }
  MainForm,
  HistoryForm,
  ColorForm,
  RichTextEditorForm;

{$R *.dfm}

const
  MIN_FORM_WIDTH  = 236;
  MIN_FORM_HEIGHT = 160;

//-- Custom Methods ------------------------------------------------------------

procedure TfrmLayer.UpdateLayerOptionsEnableStatus;
var
  LEnabled: Boolean;
begin
  if ActiveChildForm <> nil then
  begin
    LEnabled := True;

    if ActiveChildForm.LayerPanelList.SelectedLayerPanel <> nil then
    begin
      tlbtnAddMask.Enabled := not ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask;
    end
    else
    begin
      tlbtnAddMask.Enabled := False;
    end;
  end
  else
  begin
    LEnabled             := False;
    tlbtnAddMask.Enabled := False;
  end;

  ggbrLayerOpacity.Enabled       := LEnabled;
  lblLayerOpacityPercent.Enabled := LEnabled;
  chckbxLockTransparency.Enabled := LEnabled;
  imgLockTransparency.Enabled    := LEnabled;
  tlbtnNewLayer.Enabled          := LEnabled;
  tlbtnAdjustmentLayer.Enabled   := LEnabled;
  tlbtnDeleteLayer.Enabled       := LEnabled;
  cmbbxLayerBlendMode.Enabled    := LEnabled;

  if cmbbxLayerBlendMode.Enabled then
  begin
    cmbbxLayerBlendMode.Color := clWindow;
  end
  else
  begin
    cmbbxLayerBlendMode.Color := clBtnFace;
  end;
  
  edtLayerOpacityValue.Enabled := LEnabled;
  
  if edtLayerOpacityValue.Enabled then
  begin
    edtLayerOpacityValue.Color := clWindow;
  end
  else
  begin
    edtLayerOpacityValue.Color := clBtnFace;
  end;
end;

procedure TfrmLayer.UpdateLayerOptions(const ALayerPanel: TgmLayerPanel);
begin
  if Assigned(ALayerPanel) then
  begin
    ggbrLayerOpacity.Position      := ALayerPanel.LayerMasterAlpha;
    cmbbxLayerBlendMode.ItemIndex  := ALayerPanel.BlendModeIndex;

    chckbxLockTransparency.Checked := (ALayerPanel.LayerFeature in [lfBackground, lfTransparent]) and
                                      ALayerPanel.IsLockTransparency;

    chckbxLockTransparency.Enabled := (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent]);
    tlbtnAddMask.Enabled           := not ALayerPanel.IsHasMask;
  end;
end;

procedure TfrmLayer.SetShowingUp(const AValue: Boolean);
begin
  FShowingUp := AValue;

  if Assigned(ActiveChildForm) then
  begin
    ActiveChildForm.LayerPanelList.IsAllowRefreshLayerPanels := FShowingUp;
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmLayer.FormCreate(Sender: TObject);
begin
  FBarIsChanging := False;
  FRecordCommand := True;
  FIsMouseDown   := False;
  FOldOpacity    := 255;

{ Layers }
  cmbbxLayerBlendMode.Items     := BlendModeList;
  cmbbxLayerBlendMode.ItemIndex := 0;
  ggbrLayerOpacity.ShowHint     := True;

  ManualDock(frmMain.pgcntrlDockSite3);
  Show;
  frmMain.pgcntrlDockSite3.ActivePageIndex := 0;
  
  FShowingUp := True;
end;

procedure TfrmLayer.FormResize(Sender: TObject);
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

procedure TfrmLayer.FormShow(Sender: TObject);
begin
  SetShowingUp(True);
end;

procedure TfrmLayer.FormEndDock(Sender, Target: TObject; X, Y: Integer);
begin
  SetShowingUp(True);
end;

procedure TfrmLayer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SetShowingUp(False);
end;

procedure TfrmLayer.NewLayerClick(Sender: TObject);
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

  // deselect all movable figures before merging layers
  if High(ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray) > (-1) then
  begin
    ActiveChildForm.LayerPanelList.DeselectAllFiguresOnFigureLayer;

    if ActiveChildForm.FHandleLayer <> nil then
    begin
      FreeAndNil(ActiveChildForm.FHandleLayer);
    end;

    frmMain.UpdateToolsOptions;
  end;

  ActiveChildForm.CreateBlankLayer;
  
  // Create Undo/Redo
  LHistoryStatePanel := TgmStandardLayerStatePanel.Create(
    frmHistory.scrlbxHistory,
    dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
    ActiveChildForm.LayerPanelList.CurrentIndex,
    ActiveChildForm.LayerPanelList.SelectedLayerPanel,
    lctNew);

  ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);
end;

procedure TfrmLayer.AddMaskClick(Sender: TObject);
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

  if Assigned(ActiveChildForm.LayerPanelList.SelectedLayerPanel) then
  begin
    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask = False then
    begin
      // Used for Undo/Redo command.
      if Assigned(ActiveChildForm.Selection) then
      begin
        LOldSelection := TgmSelection.Create;
        LOldSelection.AssignAllSelectionData(ActiveChildForm.Selection);
      end
      else
      begin
        LOldSelection := nil;
      end;

      ActiveChildForm.LayerPanelList.SelectedLayerPanel.AddMask;

      if ActiveChildForm.Selection <> nil then
      begin
        if (frmMain.MainTool = gmtMarquee) and
           (frmMain.MarqueeTool = mtMoveResize) then
        begin
          if ActiveChildForm.SelectionHandleLayer <> nil then
          begin
            ActiveChildForm.SelectionHandleLayer.Visible := True;
            ActiveChildForm.SelectionHandleLayer.Bitmap.Clear($00000000);

            ActiveChildForm.Selection.DrawMarchingAntsBorder(
              ActiveChildForm.SelectionHandleLayer.Bitmap.Canvas,
              ActiveChildForm.SelectionHandleLayerOffsetVector.X,
              ActiveChildForm.SelectionHandleLayerOffsetVector.Y, True);
          end;
        end;
      end;

      if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
      begin
        TgmShapeRegionLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel).SetThumbnailPosition;
      end
      else
      begin
        ActiveChildForm.LayerPanelList.SelectedLayerPanel.ShowThumbnailByRightOrder;
      end;

      ActiveChildForm.LayerPanelList.UpdatePanelsState;

      frmColor.ColorMode   := cmGrayscale;   // update the color form
      tlbtnAddMask.Enabled := False;

      if Sender = tlbtnAddMask then
      begin
        LHistoryStatePanel := TgmLayerMaskStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          mctAddLayerMask,
          LOldSelection);

        ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);

        if Assigned(LOldSelection) then
        begin
          FreeAndNil(LOldSelection);
        end;
      end;
    end;
  end;
end;

procedure TfrmLayer.DeleteLayerClick(Sender: TObject);
var
  LTextLayerPanel   : TgmRichTextLayerPanel;
  LModalResult      : TModalResult;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  LHistoryStatePanel := nil;

  if ActiveChildForm <> nil then
  begin
    if frmRichTextEditor.Visible or
       (ActiveChildForm.SelectionTransformation <> nil) or
       (ActiveChildForm.Crop <> nil) then
    begin
      Exit;
    end;
  end;

  with ActiveChildForm do
  begin
    if LayerPanelList.Count > 0 then
    begin
      case LayerPanelList.SelectedLayerPanel.LayerProcessStage of
        lpsLayer:
          begin
            DeleteCurrentLayer;
            ChannelManager.DeleteLayerMaskPanel;
          end;

        lpsMask:
          begin
            if LayerPanelList.SelectedLayerPanel.LayerFeature in
                 [lfBackground, lfTransparent] then
            begin
              LModalResult := MessageDlg('Apply mask to layer before removing?',
                                          mtConfirmation,
                                          [mbYes, mbNo, mbCancel], 0);

              case LModalResult of
                mrYes:
                  begin
                    // Create Undo/Redo first.
                    LHistoryStatePanel := TgmLayerMaskStatePanel.Create(
                      frmHistory.scrlbxHistory,
                      dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
                      mctApplyLayerMask,
                      Selection);

                    LayerPanelList.SelectedLayerPanel.LayerProcessStage := lpsLayer;

                    if not LayerPanelList.SelectedLayerPanel.IsMaskLinked then
                    begin
                      // set this to True temporarily, otherwise, apply Mask
                      // operation in Update() method will not work
                      LayerPanelList.SelectedLayerPanel.IsMaskLinked := True;
                      LayerPanelList.SelectedLayerPanel.Update;
                      LayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
                      ChannelManager.UpdateColorChannelThumbnails(LayerPanelList);
                    end;

                    LayerPanelList.SelectedLayerPanel.IsHasMask := False;
                    LayerPanelList.SelectedLayerPanel.ShowThumbnailByRightOrder;
                    LayerPanelList.UpdatePanelsState;

                    // save the alpha channel of the layer to a grayscale bitmap
                    GetAlphaChannelBitmap(
                      LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                      LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                  end;

                mrNo:
                  begin
                    // Create Undo/Redo first.
                    LHistoryStatePanel := TgmLayerMaskStatePanel.Create(
                      frmHistory.scrlbxHistory,
                      dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
                      mctDiscardLayerMask,
                      Selection);

                    // Then Discarding the mask.
                    LayerPanelList.SelectedLayerPanel.LayerProcessStage := lpsLayer;
                    LayerPanelList.SelectedLayerPanel.IsHasMask         := False;
                    LayerPanelList.SelectedLayerPanel.ShowThumbnailByRightOrder;

                    ReplaceAlphaChannelWithMask(
                      LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                      LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                                              
                    LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
                    LayerPanelList.UpdatePanelsState;

                    // save current layer for restoring the processed part
                    // by canvas to opaque
                    LayerPanelList.SelectedLayerPanel.LastProcessed.Assign(
                    LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
                    
                    LayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
                  end;
              end;

              if LModalResult <> mrCancel then
              begin
                tlbtnAddMask.Enabled := True;
                ChannelManager.DeleteLayerMaskPanel;
                ChannelManager.UpdateColorChannelThumbnails(LayerPanelList);

                if Selection <> nil then
                begin
                  ChangeSelectionTarget;
                end;
              end;
            end
            else
            begin
              // on special layers...

              if MessageDlg('Discard layer mask?', mtConfirmation,
                            [mbOK, mbCancel], 0) = mrOK then
              begin
                // Create Undo/Redo first.
                LHistoryStatePanel := TgmLayerMaskStatePanel.Create(
                  frmHistory.scrlbxHistory,
                  dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
                  mctDiscardLayerMask,
                  Selection);

                LayerPanelList.SelectedLayerPanel.LayerProcessStage := lpsLayer;
                LayerPanelList.SelectedLayerPanel.IsHasMask         := False;

                ChannelManager.DeleteLayerMaskPanel;
                ChannelManager.UpdateColorChannelThumbnails(LayerPanelList);

                if LayerPanelList.SelectedLayerPanel.LayerFeature in
                     [lfFigure, lfGradientFill, lfPattern] then
                begin
                  ReplaceAlphaChannelWithMask(
                    LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                    LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                                            
                  LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
                end;

                if LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
                begin
                  TgmShapeRegionLayerPanel(
                    LayerPanelList.SelectedLayerPanel).SetThumbnailPosition;

                  ReplaceAlphaChannelWithMask(
                    LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                    LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
                end
                else
                begin
                  LayerPanelList.SelectedLayerPanel.ShowThumbnailByRightOrder;
                end;

                if LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
                begin
                  LTextLayerPanel := TgmRichTextLayerPanel(LayerPanelList.SelectedLayerPanel);

                  if not frmRichTextEditor.Visible then
                  begin
                    LTextLayerPanel.RichTextStream.Position := 0;
                    
                    frmRichTextEditor.rchedtRichTextEditor.Lines.LoadFromStream(
                      LTextLayerPanel.RichTextStream);
                  end;

                  DrawRichTextOnBitmap(
                    LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                    LTextLayerPanel.BorderRect, frmRichTextEditor.rchedtRichTextEditor);

                  LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
                end;

                LayerPanelList.UpdatePanelsState;
                tlbtnAddMask.Enabled := True;

                if ActiveChildForm.Selection <> nil then
                begin
                  if (frmMain.MainTool = gmtMarquee) and
                     (frmMain.MarqueeTool = mtMoveResize) then
                  begin
                    if SelectionHandleLayer <> nil then
                    begin
                      SelectionHandleLayer.Visible := True;
                      SelectionHandleLayer.Bitmap.Clear($00000000);

                      Selection.DrawMarchingAntsBorder(
                        SelectionHandleLayer.Bitmap.Canvas,
                        SelectionHandleLayerOffsetVector.X,
                        SelectionHandleLayerOffsetVector.Y, False);
                    end;
                  end;
                end;

                LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
              end;
            end;
          end;
      end;

      // update color form
      if ChannelManager.CurrentChannelType in
           [wctRGB, wctRed, wctGreen, wctBlue] then
      begin
        frmColor.ColorMode := cmRGB;
      end
      else
      begin
        frmColor.ColorMode := cmGrayscale;
      end;

      if Assigned(LHistoryStatePanel) then
      begin
        HistoryManager.AddHistoryState(LHistoryStatePanel);
      end;
    end;
  end;
end;

procedure TfrmLayer.AdjustmentLayerClick(Sender: TObject);
var
  LPoint: TPoint;
begin
  if ActiveChildForm <> nil then
  begin
    if frmRichTextEditor.Visible or
       (ActiveChildForm.SelectionTransformation <> nil)or
       (ActiveChildForm.Crop <> nil) then
    begin
      Exit;
    end;
  end;

  GetCursorPos(LPoint); // get cursor position on the screen

  // pop up the menu at current position
  dmLayer.pmnAdjustmentLayers.Popup(LPoint.X, LPoint.Y);
end;

procedure TfrmLayer.LayerBlendModeChange(Sender: TObject);
var
  LOldBlendModeIndex: Integer;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  LOldBlendModeIndex := 0;

  // For Undo/Redo
  if FRecordCommand then
  begin
    LOldBlendModeIndex := ActiveChildForm.LayerPanelList.SelectedLayerPanel.BlendModeIndex;
  end;

  ActiveChildForm.LayerPanelList.SelectedLayerPanel.BlendModeIndex := cmbbxLayerBlendMode.ItemIndex;
  ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;

  ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);

  if FRecordCommand then
  begin
    LHistoryStatePanel := TgmBlendingChangeStatePanel.Create(
      frmHistory.scrlbxHistory,
      dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
      ActiveChildForm.LayerPanelList.CurrentIndex,
      LOldBlendModeIndex,
      ActiveChildForm.LayerPanelList.SelectedLayerPanel.BlendModeIndex);

    ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);
  end;
end;

procedure TfrmLayer.LayerOpacityChange(Sender: TObject);
begin
  FBarIsChanging := True;
  try
    ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerMasterAlpha := ggbrLayerOpacity.Position;
    edtLayerOpacityValue.Text := IntToStr( MulDiv(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.MasterAlpha, 100, 255) );
  finally
    FBarIsChanging := False;
  end;
end;

procedure TfrmLayer.ggbrLayerOpacityMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  // For Undo/Redo
  FOldOpacity  := ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerMasterAlpha;
  FIsMouseDown := True;
end;

procedure TfrmLayer.ggbrLayerOpacityMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  if FIsMouseDown then
  begin
    FIsMouseDown := False;

    // update thumbnails
    ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);

    if FOldOpacity <> ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerMasterAlpha then
    begin
      LHistoryStatePanel := TgmOpacityChangeStatePanel.Create(
        frmHistory.scrlbxHistory,
        dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
        ActiveChildForm.LayerPanelList.CurrentIndex,
        FOldOpacity,
        ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerMasterAlpha);

      ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);
    end;
  end;
end;

procedure TfrmLayer.chckbxLockTransparencyMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsLockTransparency := chckbxLockTransparency.Checked;
end;

procedure TfrmLayer.edtLayerOpacityValueChange(Sender: TObject);
var
  LChangedValue: Integer;
begin
  if not FBarIsChanging then
  begin
    try
      LChangedValue := StrToInt(edtLayerOpacityValue.Text);
      EnsureValueInRange(LChangedValue, 0, 100);

      LChangedValue             := MulDiv(LChangedValue, 255, 100);
      ggbrLayerOpacity.Position := LChangedValue;
    except
      edtLayerOpacityValue.Text := IntToStr( MulDiv(ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerMasterAlpha, 100, 255) );
    end;

    // update thumbnails
    ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
  end;
end;

procedure TfrmLayer.edtLayerOpacityValueEnter(Sender: TObject);
begin
  FOldOpacity    := ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerMasterAlpha;
  FRecordCommand := True;
end;

procedure TfrmLayer.edtLayerOpacityValueExit(Sender: TObject);
var
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  if FRecordCommand then
  begin
    LHistoryStatePanel := TgmOpacityChangeStatePanel.Create(
      frmHistory.scrlbxHistory,
      dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
      ActiveChildForm.LayerPanelList.CurrentIndex,
      FOldOpacity,
      ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerMasterAlpha);

    ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);
  end;
end;

procedure TfrmLayer.edtLayerOpacityValueKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  if Key = VK_RETURN then
  begin
    FRecordCommand := False;

    LHistoryStatePanel := TgmOpacityChangeStatePanel.Create(
      frmHistory.scrlbxHistory,
      dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
      ActiveChildForm.LayerPanelList.CurrentIndex,
      FOldOpacity,
      ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerMasterAlpha);

    ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);

    cmbbxLayerBlendMode.SetFocus;
  end;
end;

end.
