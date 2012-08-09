{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

unit gmCommands;

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

{$WARN UNSAFE_TYPE OFF}

interface

uses
{ Standard }
  SysUtils,
{ Graphics32 }
  GR32, GR32_Layers,
{ GraphicsMagic }
  gmTypes,
  gmLayerAndChannel,
  gmSelection;

type
  TCommandAim   = (caNone, caLayer, caLayerMask, caAlphaChannel, caQuickMask);
  TCommandState = (csNone, csUndo, csRedo);

//-- TgmCommand ----------------------------------------------------------------

  TgmCommand = class(TObject)
  protected
    FCommandAim             : TCommandAim;
    FCommandState           : TCommandState;
    FCommandName            : string;
    FOperateName            : string;
    FTargetLayerIndex       : Integer;
    FTargetAlphaChannelIndex: Integer;
    FLayerLockTransparency  : Boolean;
    FLayerBlendModeIndex    : Integer;
    FLayerOpacity           : Byte;
    FOldChannelSet          : TgmChannelSet;

    procedure ProcessAfterCommandDone;
    procedure ProcessAfterSelectionCommandDone;
    procedure ProcessAfterMaskCommandDone;
    procedure ProcessAfterCreateDeleteLayerCommandDone;
    procedure ProcessAfterShapeRegionCommandDone;
    procedure ProcessAfterFigureCommandDone;
    procedure ProcessAfterTextToolCommandDone;
    procedure ProcessAfterPenPathCommandDone;
    procedure ShowSelectionOnAim(const ASelection: TgmSelection);
    procedure ReplaceBackgroundOnAim(const ABackground: TBitmap32);
  public
    constructor Create(const ACmdAim: TCommandAim; const ACmdName: string);

    procedure Rollback; virtual; abstract;
    procedure Execute; virtual; abstract;

    property CommandAim  : TCommandAim   read FCommandAim;
    property CommandState: TCommandState read FCommandState;
    property CommandName : string        read FCommandName;
    property OperateName : string        read FOperateName;
  end;

//-- TgmImageManipulatingCommand -----------------------------------------------

  TgmImageManipulatingCommand = class(TgmCommand)
  private
    FUndoBmpFileName: string;
    FRedoBmpFileName: string;
    FCopiedSelection: TgmSelection;

    procedure ExecuteCommand(const ACommandState: TCommandState);
  public
    constructor Create(const ACmdAim: TCommandAim; const ACmdName: string;
      const AUndoBmp, ARedoBmp: TBitmap32; const ASelection: TgmSelection;
      const ATargetAlphaChannelIndex: Integer);

    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

implementation

uses
{ Standard Lib }
  Windows, Graphics, Classes,
{ GraphicsMagic Lib }
  gmConstants,
  gmAlphaFuncs,
  gmShapes,
{ GraphicsMagic Forms/Dialogs }
  MainForm,
  ColorForm,
  LayerForm;

//-- TgmCommand ----------------------------------------------------------------

constructor TgmCommand.Create(const ACmdAim: TCommandAim;
  const ACmdName: string);
begin
  inherited Create;

  FTargetLayerIndex        := ActiveChildForm.LayerPanelList.CurrentIndex;
  FTargetAlphaChannelIndex := -1;
  FCommandAim              := ACmdAim;
  FCommandState            := csUndo;
  FCommandName             := ACmdName;
  FOperateName             := '';
  FLayerLockTransparency   := False;
  FLayerBlendModeIndex     := 0;
  FLayerOpacity            := 255;
  FOldChannelSet           := ActiveChildForm.ChannelManager.ChannelSelectedSet;
end;

procedure TgmCommand.ProcessAfterCommandDone;
var
  LShapeRegionLayerPanel: TgmShapeRegionLayerPanel;
begin
{ Selection }

  if (frmMain.MainTool = gmtMarquee) and
     (frmMain.MarqueeTool = mtMoveResize) then
  begin
    if Assigned(ActiveChildForm.Selection) then
    begin
      ActiveChildForm.CreateSelectionHandleLayer;
      ActiveChildForm.UpdateSelectionHandleBorder;
    end
    else
    begin
      ActiveChildForm.DeleteSelectionHandleLayer;
    end;
  end
  else
  begin
    ActiveChildForm.DeleteSelectionHandleLayer;
  end;

{ Shape Region Layer }

  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
  begin
    LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

    if ActiveChildForm.ShapeOutlineLayer = nil then
    begin
      ActiveChildForm.CreateShapeOutlineLayer;
    end;
    
    ActiveChildForm.CalcShapeOutlineLayerOffsetVector;
    ActiveChildForm.ShapeOutlineLayer.Bitmap.Clear($00000000);

    if not LShapeRegionLayerPanel.IsDismissed then
    begin
      LShapeRegionLayerPanel.ShapeOutlineList.DrawAllOutlines(
        ActiveChildForm.ShapeOutlineLayer.Bitmap.Canvas,
        ActiveChildForm.OutlineOffsetVector, pmNotXor);
    end;

    if frmMain.MainTool = gmtShape then
    begin
      if frmMain.ShapeRegionTool = srtMove then
      begin
        LShapeRegionLayerPanel.ShapeOutlineList.DrawShapesBoundary(
          ActiveChildForm.ShapeOutlineLayer.Bitmap.Canvas, HANDLE_RADIUS,
          ActiveChildForm.OutlineOffsetVector, pmNotXor);

        LShapeRegionLayerPanel.ShapeOutlineList.DrawShapesBoundaryHandles(
          ActiveChildForm.ShapeOutlineLayer.Bitmap.Canvas, HANDLE_RADIUS,
          ActiveChildForm.OutlineOffsetVector, pmNotXor);
      end;
    end;
  end
  else
  begin
    ActiveChildForm.DeleteShapeOutlineLayer;  // The current layer is not a shape region layer...
  end;

{ Text Tool }

  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
  begin
    if frmMain.MainTool = gmtTextTool then
    begin
      ActiveChildForm.UpdateRichTextHandleLayer;
    end
    else
    begin
      ActiveChildForm.DeleteRichTextHandleLayer;
    end;
  end
  else
  begin
    ActiveChildForm.DeleteRichTextHandleLayer;
  end;
end; 

procedure TgmCommand.ProcessAfterSelectionCommandDone;
begin
  if (frmMain.MainTool = gmtMarquee) and
     (frmMain.MarqueeTool = mtMoveResize) then
  begin
    ActiveChildForm.CreateSelectionHandleLayer;  
    ActiveChildForm.UpdateSelectionHandleBorder;
  end
  else
  begin
    ActiveChildForm.DeleteSelectionHandleLayer;
  end;

  ActiveChildForm.LayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;

  frmLayer.tlbtnAddMask.Enabled := not ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask;

  // showing the scroll bar correctly
  frmLayer.scrlbxLayers.Update;

  // update the appearance of the color form
  case ActiveChildForm.ChannelManager.CurrentChannelType of
    wctAlpha, wctQuickMask, wctLayerMask:
      begin
        frmColor.ColorMode := cmGrayscale;
      end;

    wctRGB, wctRed, wctGreen, wctBlue:
      begin
        frmColor.ColorMode := cmRGB;
      end;
  end;

  frmMain.UpdateMarqueeOptions;

  if not ActiveChildForm.tmrMarchingAnts.Enabled then
  begin
    ActiveChildForm.tmrMarchingAnts.Enabled := True;
  end;
end; 

procedure TgmCommand.ProcessAfterMaskCommandDone;
begin
  with ActiveChildForm do
  begin
    case LayerPanelList.SelectedLayerPanel.LayerProcessStage of
      lpsLayer:
        begin
          LayerPanelList.SelectedLayerPanel.Update;
        end;

      lpsMask:
        begin
          LayerPanelList.SelectedLayerPanel.Update;
        end;
    end;

    LayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;

    // update thumbnails of color channels
    ChannelManager.UpdateColorChannelThumbnails(LayerPanelList);

    if LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
    begin
      CreateShapeOutlineLayer;
      DrawShapeOutline;
    end
    else
    begin
      DeleteShapeOutlineLayer;
    end;

    if LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
    begin
      if frmMain.MainTool = gmtTextTool then
      begin
        UpdateRichTextHandleLayer;
      end
      else
      begin
        DeleteRichTextHandleLayer;
      end;
    end
    else
    begin
      DeleteRichTextHandleLayer;
    end;

    frmLayer.tlbtnAddMask.Enabled := (not LayerPanelList.SelectedLayerPanel.IsHasMask);
    frmLayer.scrlbxLayers.Update; // showing the scroll bar correctly

    if ChannelManager.CurrentChannelType in
         [wctRGB, wctRed, wctGreen, wctBlue] then
    begin
      frmColor.ColorMode := cmRGB;
    end
    else
    begin
      frmColor.ColorMode := cmGrayscale;
    end;
  end;
end;

procedure TgmCommand.ProcessAfterCreateDeleteLayerCommandDone;
begin
  with ActiveChildForm do
  begin
    if Assigned(LayerPanelList.SelectedLayerPanel) then
    begin
      case LayerPanelList.SelectedLayerPanel.LayerProcessStage of
        lpsLayer:
          begin
            LayerPanelList.SelectedLayerPanel.Update;
          end;

        lpsMask:
          begin
            LayerPanelList.SelectedLayerPanel.Update;
          end;
      end;

      // update thumbnails
      LayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;

      ChannelManager.UpdateColorChannelThumbnails(LayerPanelList);

      if LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
      begin
        CreateShapeOutlineLayer;
        DrawShapeOutline;
      end
      else
      begin
        DeleteShapeOutlineLayer;
      end;

      if LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
      begin
        if frmMain.MainTool = gmtTextTool then
        begin
          UpdateRichTextHandleLayer;
        end
        else
        begin
          DeleteRichTextHandleLayer;
        end;
      end
      else
      begin
        DeleteRichTextHandleLayer;
      end;

      frmLayer.tlbtnAddMask.Enabled := not LayerPanelList.SelectedLayerPanel.IsHasMask;
      frmLayer.scrlbxLayers.Update;

      // update color form
      case ChannelManager.CurrentChannelType of
        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            frmColor.ColorMode := cmRGB;
          end;
          
        wctAlpha, wctQuickMask, wctLayerMask:
          begin
            frmColor.ColorMode := cmGrayscale;
          end;
      end;
    end;
  end;
end; 

procedure TgmCommand.ProcessAfterShapeRegionCommandDone;
var
  LShapeRegionLayerPanel: TgmShapeRegionLayerPanel;
begin
  if Assigned(ActiveChildForm.LayerPanelList.SelectedLayerPanel) then
  begin
    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
    begin
      LShapeRegionLayerPanel := TgmShapeRegionLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

      if ActiveChildForm.ShapeOutlineLayer = nil then
      begin
        ActiveChildForm.CreateShapeOutlineLayer;
      end;
      
      ActiveChildForm.CalcShapeOutlineLayerOffsetVector;
      ActiveChildForm.ShapeOutlineLayer.Bitmap.Clear($00000000);

      if not LShapeRegionLayerPanel.IsDismissed then
      begin
        LShapeRegionLayerPanel.ShapeOutlineList.DrawAllOutlines(
          ActiveChildForm.ShapeOutlineLayer.Bitmap.Canvas,
          ActiveChildForm.OutlineOffsetVector, pmNotXor);
      end;

      if frmMain.MainTool = gmtShape then
      begin
        if frmMain.ShapeRegionTool = srtMove then
        begin
          LShapeRegionLayerPanel.ShapeOutlineList.DrawShapesBoundary(
            ActiveChildForm.ShapeOutlineLayer.Bitmap.Canvas, HANDLE_RADIUS,
            ActiveChildForm.OutlineOffsetVector, pmNotXor);

          LShapeRegionLayerPanel.ShapeOutlineList.DrawShapesBoundaryHandles(
            ActiveChildForm.ShapeOutlineLayer.Bitmap.Canvas, HANDLE_RADIUS,
            ActiveChildForm.OutlineOffsetVector, pmNotXor);
        end;
      end;
    end
    else
    begin
      ActiveChildForm.DeleteShapeOutlineLayer;  // The current layer is not a shape region layer...
    end;

    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
    begin
      if frmMain.MainTool = gmtTextTool then
      begin
        ActiveChildForm.UpdateRichTextHandleLayer;
      end
      else
      begin
        ActiveChildForm.DeleteRichTextHandleLayer;
      end;
    end
    else
    begin
      ActiveChildForm.DeleteRichTextHandleLayer;
    end;

    frmMain.UpdateShapeOptions;
  end;
end;

procedure TgmCommand.ProcessAfterFigureCommandDone;
begin
  with ActiveChildForm do
  begin
    if Assigned(LayerPanelList.SelectedLayerPanel) then
    begin
      // Text Layer
      if frmMain.MainTool = gmtTextTool then
      begin
        if LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
        begin
          UpdateRichTextHandleLayer;
        end
        else
        begin
          DeleteRichTextHandleLayer;
        end;
      end
      else
      begin
        DeleteRichTextHandleLayer;
      end;

      // Shape Region Layer
      if LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
      begin
        CreateShapeOutlineLayer;
        DrawShapeOutline;
      end
      else
      begin
        DeleteShapeOutlineLayer;
      end;

      if LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
      begin
        if frmMain.MainTool = gmtTextTool then
        begin
          UpdateRichTextHandleLayer;
        end
        else
        begin
          DeleteRichTextHandleLayer;
        end;
      end
      else
      begin
        DeleteRichTextHandleLayer;
      end;

      // Stander Tool and Figure Layers
      if frmMain.MainTool = gmtStandard then
      begin
        if frmMain.StandardTool in [gstMoveObjects, gstPartiallySelect,
                                    gstTotallySelect] then
        begin
          if FHandleLayer = nil then
          begin
            CreateFigureHandleLayer;
          end;

          FHandleLayer.Bitmap.Clear($00FFFFFF);

          if LayerPanelList.SelectedFigureCountOnFigureLayer > 0 then
          begin
            LayerPanelList.DrawSelectedFiguresHandles(
              FHandleLayer.Bitmap, FHandleLayerOffsetVector);
          end;
        end
        else
        begin
          DeleteFigureHandleLayer;
          LayerPanelList.DeselectAllFiguresOnFigureLayer;
        end;
      end
      else
      begin
        DeleteFigureHandleLayer;
        LayerPanelList.DeselectAllFiguresOnFigureLayer;
      end;

      LayerPanelList.SelectedLayerPanel.Update;

      // update thumbnails
      LayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
      ChannelManager.UpdateColorChannelThumbnails(LayerPanelList);

      frmMain.UpdateStandardOptions;
    end;
  end;
end; 

procedure TgmCommand.ProcessAfterTextToolCommandDone;
begin
  with ActiveChildForm do
  begin
    if Assigned(LayerPanelList.SelectedLayerPanel) then
    begin
      if frmMain.MainTool = gmtTextTool then
      begin
        if LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
        begin
          UpdateRichTextHandleLayer;
        end
        else
        begin
          DeleteRichTextHandleLayer;
        end;
      end
      else
      begin
        DeleteRichTextHandleLayer;
      end;

      if LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
      begin
        CreateShapeOutlineLayer;
        DrawShapeOutline;
      end
      else
      begin
        DeleteShapeOutlineLayer;
      end;

      LayerPanelList.SelectedLayerPanel.Update;
    end;
  end;
end; 

procedure TgmCommand.ProcessAfterPenPathCommandDone;
begin
  with ActiveChildForm do
  begin
    if Assigned(PathPanelList.SelectedPanel) then
    begin
      if PathLayer = nil then
      begin
        CreatePathLayer;
      end;

      CalcPathLayerOffsetVector;

      PathPanelList.SelectedPanel.UpdateThumbnail(
        LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
        LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height,
        PathOffsetVector);

      PathLayer.Bitmap.Clear($00000000);

      PathPanelList.SelectedPanel.PenPathList.DrawAllPaths(
        PathLayer.Bitmap.Canvas, pmNotXor, Point(0, 0));
        
      PathLayer.Bitmap.Changed;
    end
    else
    begin
      DeletePathLayer;
    end;
  end;
end;

procedure TgmCommand.ShowSelectionOnAim(const ASelection: TgmSelection);
var
  LAlphaChannelPanel: TgmAlphaChannelPanel;
  LLayerPanel       : TgmLayerPanel;
  LLayerChannelSet  : TgmChannelSet;
begin
  with ActiveChildForm do
  begin
    if Assigned(ASelection) then
    begin
      // update the foregound of the selection
      ASelection.GetForeground;

      case FCommandAim of
        caAlphaChannel:
          begin
            LAlphaChannelPanel :=
              ChannelManager.GetAlphaChannelPanelByIndex(FTargetAlphaChannelIndex);

            if Assigned(LAlphaChannelPanel) then
            begin
              ASelection.ShowSelection(
                LAlphaChannelPanel.AlphaLayer.Bitmap, [csGrayscale]);

              LAlphaChannelPanel.AlphaLayer.Changed;
              LAlphaChannelPanel.UpdateThumbnail;
            end;
          end;

        caQuickMask:
          begin
            if Assigned(ChannelManager.QuickMaskPanel) then
            begin
              ASelection.ShowSelection(
                ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap, [csGrayscale]);
                
              ChannelManager.QuickMaskPanel.AlphaLayer.Changed;
              ChannelManager.QuickMaskPanel.UpdateThumbnail;
            end;
          end;

        caLayerMask:
          begin
            LLayerPanel := LayerPanelList.GetLayerPanelByIndex(FTargetLayerIndex);

            if Assigned(LLayerPanel) then
            begin
              ASelection.ShowSelection(LLayerPanel.FMaskImage.Bitmap, [csGrayscale]);
              LLayerPanel.UpdateMaskThumbnail;

              // update the mask channel preview layer
              if Assigned(ChannelManager.LayerMaskPanel) then
              begin
                ChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(
                  0, 0, LLayerPanel.FMaskImage.Bitmap);
                  
                ChannelManager.LayerMaskPanel.UpdateThumbnail;
              end;

              if not LLayerPanel.IsHoldMaskInLayerAlpha then
              begin
                ApplyMaskByIndex(FTargetLayerIndex);
              end
              else
              begin
                // on special layers, save Mask into layer's alpha channels
                LLayerPanel.UpdateLayerAlphaWithMask;
                LLayerPanel.AssociatedLayer.Changed;
              end;

              if LLayerPanel.LayerFeature in [
                   lfBackground, lfTransparent, lfFigure] then
              begin
                LLayerPanel.UpdateLayerThumbnail;
              end;

              ChannelManager.UpdateColorChannelThumbnails(LayerPanelList);
            end;
          end;

        caLayer:
          begin
            // if the current channel is on mask, this will keep the selection blending correctly
            LLayerChannelSet := ChannelManager.ChannelSelectedSet + FOldChannelSet - [csGrayscale];

            if LayerPanelList.SelectedLayerPanel.IsMaskLinked then
            begin
              ReplaceAlphaChannelWithMask(
                LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
            end;

            ASelection.ShowSelection(
              LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
              LLayerChannelSet);

            // save the new alpha channels
            GetAlphaChannelBitmap(
              LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
              LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);

            LayerPanelList.SelectedLayerPanel.Update;

            if LayerPanelList.SelectedLayerPanel.LayerFeature in [
                 lfBackground, lfTransparent, lfFigure] then
            begin
              LayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
            end;

            ChannelManager.UpdateColorChannelThumbnails(LayerPanelList);
          end;
      end;

      imgDrawingArea.Update;
    end;
  end;
end;

procedure TgmCommand.ReplaceBackgroundOnAim(const ABackground: TBitmap32);
var
  LAlphaChannelPanel: TgmAlphaChannelPanel;
  LLayerPanel       : TgmLayerPanel;
begin
  if Assigned(ABackground) then
  begin
    with ActiveChildForm do
    begin
      case FCommandAim of
        caAlphaChannel:
          begin
            LAlphaChannelPanel := ChannelManager.GetAlphaChannelPanelByIndex(FTargetAlphaChannelIndex);

            if Assigned(LAlphaChannelPanel) then
            begin
              LAlphaChannelPanel.AlphaLayer.Bitmap.Assign(ABackground);
              LAlphaChannelPanel.AlphaLayer.Changed;
              LAlphaChannelPanel.UpdateThumbnail;
            end;
          end;

        caQuickMask:
          begin
            if Assigned(ChannelManager.QuickMaskPanel) then
            begin
              ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.Assign(ABackground);
              ChannelManager.QuickMaskPanel.AlphaLayer.Changed;
              ChannelManager.QuickMaskPanel.UpdateThumbnail;
            end;
          end;

        caLayerMask:
          begin
            LLayerPanel := LayerPanelList.GetLayerPanelByIndex(FTargetLayerIndex);

            if Assigned(LLayerPanel) then
            begin
              LLayerPanel.FMaskImage.Bitmap.Assign(ABackground);
              LLayerPanel.UpdateMaskThumbnail;

              // update the mask channel preview layer
              if Assigned(ChannelManager.LayerMaskPanel) then
              begin
                ChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(
                  0, 0, LLayerPanel.FMaskImage.Bitmap);
                  
                ChannelManager.LayerMaskPanel.UpdateThumbnail;
              end;

              if not LLayerPanel.IsHoldMaskInLayerAlpha then
              begin
                ApplyMaskByIndex(FTargetLayerIndex);
              end
              else
              begin
                // on special layers, save Mask into layer's alpha channels
                LLayerPanel.UpdateLayerAlphaWithMask;
                LLayerPanel.AssociatedLayer.Changed;
              end;

              if LLayerPanel.LayerFeature in [
                   lfBackground, lfTransparent, lfFigure] then
              begin
                LLayerPanel.UpdateLayerThumbnail;
              end;

              ChannelManager.UpdateColorChannelThumbnails(LayerPanelList);
            end;
          end;

        caLayer:
          begin
            LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Assign(ABackground);

            // save the new alpha channels
            GetAlphaChannelBitmap(LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                                  LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);

            LayerPanelList.SelectedLayerPanel.Update;

            if LayerPanelList.SelectedLayerPanel.LayerFeature in [
                 lfBackground, lfTransparent, lfFigure] then
            begin
              LayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
            end;
            
            ChannelManager.UpdateColorChannelThumbnails(LayerPanelList);
          end;
      end;
    end;
  end;
end; 

//-- TgmImageManipulatingCommand -----------------------------------------------

constructor TgmImageManipulatingCommand.Create(const ACmdAim: TCommandAim;
  const ACmdName: string; const AUndoBmp, ARedoBmp: TBitmap32;
  const ASelection: TgmSelection; const ATargetAlphaChannelIndex: Integer);
var
  BmpStream : TMemoryStream;
  CommandDir: string;
begin
  inherited Create(ACmdAim, ACmdName);

  FOperateName             := 'Undo ' + FCommandName;
  FTargetAlphaChannelIndex := ATargetAlphaChannelIndex;
  FCopiedSelection         := nil;
  
  if Assigned(ASelection) then
  begin
    FCopiedSelection := TgmSelection.Create;
    FCopiedSelection.AssignAllSelectionData(ASelection);
  end;

  { Save the undo/redo bitmap to disk for saving the system memory. We save the
    bitmap to a memory stream first, and save the stream to file with any file name
    we want. }
  BmpStream := TMemoryStream.Create;
  try
    CommandDir := ExtractFileDir(ParamStr(0)) + '\History';

    if not DirectoryExists(CommandDir) then
      CreateDir(CommandDir);

    // process undo bitmap
    FUndoBmpFileName := CommandDir + '\Undo' + IntToStr(GetTickCount);
    AUndoBmp.SaveToStream(BmpStream);
    BmpStream.Position := 0;
    BmpStream.SaveToFile(FUndoBmpFileName);

    BmpStream.Clear;

    // process redo bitmap
    FRedoBmpFileName := CommandDir + '\Redo' + IntToStr(GetTickCount);
    ARedoBmp.SaveToStream(BmpStream);
    BmpStream.Position := 0;
    BmpStream.SaveToFile(FRedoBmpFileName);
  finally
    BmpStream.Clear;
    BmpStream.Free;
  end;
end;

destructor TgmImageManipulatingCommand.Destroy;
begin
  if FileExists(FUndoBmpFileName) then
  begin
    DeleteFile(PChar(FUndoBmpFileName));
  end;

  if FileExists(FRedoBmpFileName) then
  begin
    DeleteFile(PChar(FRedoBmpFileName));
  end;

  if Assigned(FCopiedSelection) then
  begin
    FCopiedSelection.Free;
  end;

  inherited Destroy;
end;

procedure TgmImageManipulatingCommand.ExecuteCommand(
  const ACommandState: TCommandState);
var
  LBmpStream                : TMemoryStream;
  LAlphaChannelPanel        : TgmAlphaChannelPanel;
  LNeedChangeSelectionTarget: Boolean;
begin
  LNeedChangeSelectionTarget := False;

  with ActiveChildForm do
  begin
    if FTargetLayerIndex <> LayerPanelList.CurrentIndex then
    begin
      LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);

      if FCommandAim <> caLayer then
      begin
        LNeedChangeSelectionTarget := True;
      end;
    end;

    case FCommandAim of
      caAlphaChannel:
        begin
          if ChannelManager.CurrentChannelType <> wctAlpha then
          begin
            LNeedChangeSelectionTarget := True;
          end
          else
          begin
            if FTargetAlphaChannelIndex <> ChannelManager.SelectedAlphaChannelIndex then
            begin
              LNeedChangeSelectionTarget := True;
            end;
          end;
        end;

      caQuickMask:
        begin
          if ChannelManager.CurrentChannelType <> wctQuickMask then
          begin
            LNeedChangeSelectionTarget := True;
          end;
        end;

      caLayerMask:
        begin
          if ChannelManager.CurrentChannelType <> wctLayerMask then
          begin
            LNeedChangeSelectionTarget := True;
          end;
        end;

      caLayer:
        begin
          if not (ChannelManager.CurrentChannelType in
                    [wctRGB, wctRed, wctGreen, wctBlue]) then
          begin
            LNeedChangeSelectionTarget := True;
          end;
        end;
    end;

    LBmpStream := TMemoryStream.Create;
    try
      case ACommandState of
        csUndo:
          begin
            LBmpStream.LoadFromFile(FUndoBmpFileName);
          end;

        csRedo:
          begin
            LBmpStream.LoadFromFile(FRedoBmpFileName);
          end;
      end;

      LBmpStream.Position := 0;

      if Assigned(Selection) and Assigned(FCopiedSelection) then
      begin
        FCopiedSelection.CutOriginal.LoadFromStream(LBmpStream);
        ShowSelectionOnAim(FCopiedSelection);

        // update selection to newest state
        Selection.CutOriginal.Assign(FCopiedSelection.CutOriginal);
        Selection.GetForeground;

        if LNeedChangeSelectionTarget then
        begin
          ChangeSelectionTarget;
        end;
      end
      else
      begin
        case FCommandAim of
          caAlphaChannel:
            begin
              LAlphaChannelPanel := ChannelManager.GetAlphaChannelPanelByIndex(FTargetAlphaChannelIndex);

              if Assigned(LAlphaChannelPanel) then
              begin
                LAlphaChannelPanel.AlphaLayer.Bitmap.LoadFromStream(LBmpStream);
                LAlphaChannelPanel.AlphaLayer.Changed;
                LAlphaChannelPanel.UpdateThumbnail;
              end;
            end;

          caQuickMask:
            begin
              if Assigned(ChannelManager.QuickMaskPanel) then
              begin
                ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.LoadFromStream(LBmpStream);
                ChannelManager.QuickMaskPanel.AlphaLayer.Changed;
                ChannelManager.QuickMaskPanel.UpdateThumbnail;
              end;
            end;

          caLayerMask:
            begin
              LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.LoadFromStream(LBmpStream);
              LayerPanelList.SelectedLayerPanel.UpdateMaskThumbnail;

              // update the mask channel preview layer
              if Assigned(ChannelManager.LayerMaskPanel) then
              begin
                ChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(
                  0, 0, LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);

                ChannelManager.LayerMaskPanel.UpdateThumbnail;
              end;

              LayerPanelList.SelectedLayerPanel.Update;

              if LayerPanelList.SelectedLayerPanel.LayerFeature in [
                   lfBackground, lfTransparent, lfFigure] then
              begin
                LayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
              end;

              ChannelManager.UpdateColorChannelThumbnails(LayerPanelList);
            end;

          caLayer:
            begin
              LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.LoadFromStream(LBmpStream);

              // save the new alpha channels
              GetAlphaChannelBitmap(
                LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);

              LayerPanelList.SelectedLayerPanel.Update;

              if LayerPanelList.SelectedLayerPanel.LayerFeature in [
                   lfBackground, lfTransparent, lfFigure] then
              begin
                LayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
              end;

              ChannelManager.UpdateColorChannelThumbnails(LayerPanelList);
            end;
        end;
      end;

    finally
      LBmpStream.Clear;
      LBmpStream.Free;
    end;
  end;
end; 

procedure TgmImageManipulatingCommand.Rollback;
begin
  FOperateName  := 'Redo ' + FCommandName;
  FCommandState := csRedo;

  ExecuteCommand(csUndo);
  ProcessAfterCommandDone;
end;

procedure TgmImageManipulatingCommand.Execute;
begin
  FOperateName  := 'Undo ' + FCommandName;
  FCommandState := csUndo;

  ExecuteCommand(csRedo);
  ProcessAfterCommandDone;
end; 

end.
