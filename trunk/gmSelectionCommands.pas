{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

unit gmSelectionCommands;

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
{ Standard }
  Windows, SysUtils,
{ Graphics32 }
  GR32,
{ GraphicsMagic }
  gmTypes,
  gmCommands,
  gmSelection,
  gmLayerAndChannel;

type
  TgmSelectionCommandType = (sctNew,
                             sctTranslate,
                             sctStretchCorner,
                             sctSelectCanvas,
                             sctColorRangeSelection,
                             sctFeatherSelection,
                             sctSelectInverse,
                             sctCommitSelection,
                             sctDeselect,
                             sctDeleteSelection,
                             sctNudgeSelectionOutline);

  TgmTransformCommandType = (tctCreate, tctAdjust, tctApply, tctCancel);

//-- TgmSelectionCommand -------------------------------------------------------

  // Undo/Redo for selections
  TgmSelectionCommand = class(TgmCommand)
  private
    FOldSourceBitmap     : TBitmap32;
    FUndoSelection       : TgmSelection;
    FRedoSelection       : TgmSelection;
    FSelectionCommandType: TgmSelectionCommandType;
    FMarqueeTool         : TgmMarqueeTools;

    function GetCommandName: string;

    procedure CreateSelectionWithCommandState(const AState: TCommandState;
      const AShowingSelection: Boolean);
  public
    constructor Create(const ACmdAim: TCommandAim;
      const AMarqueeTool: TgmMarqueeTools;
      const ASelectionCommandType: TgmSelectionCommandType;
      const AOldSelection, ANewSelection: TgmSelection;
      const ATargetAlphaChannelIndex: Integer);

    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmTransformCommand -------------------------------------------------------

  TgmTransformCommand = class(TgmCommand)
  private
    FTransformCommandType: TgmTransformCommandType;
    FTransformMode       : TgmTransformMode;
    FUndoTransform       : TgmSelectionTransformation;
    FRedoTransform       : TgmSelectionTransformation;
    FUndoSelection       : TgmSelection;
    FTransforming        : Boolean;

    function GetCommandName: string;
    procedure ProcessAfterCommandDone;
  public
    constructor Create(const ATransformCommandType: TgmTransformCommandType;
      const ATransformMode: TgmTransformMode; const AUndoSelection: TgmSelection;
      const AUndoTransform, ARedoTransform: TgmSelectionTransformation);

    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmCutPixelsCommand -------------------------------------------------------

  TgmCutPixelsCommand = class(TgmCommand)
  private
    FOldClipboardSelection: TgmSelection;  // Cutted Selection
    FOldSelection         : TgmSelection;  // Original Selection
  public
    constructor Create(const ACmdAim: TCommandAim;
      const AOldSelection, AOldClipboardSelection: TgmSelection;
      const ATargetAlphaChannelIndex: Integer);

    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmCopyPixelsCommand ------------------------------------------------------

  TgmCopyPixelsCommand = class(TgmCommand)
  private
    FOldClipboardSelection: TgmSelection;  // Cutted Selection
    FOldSelection         : TgmSelection;  // Original Selection
  public
    constructor Create(const AOldSelection, AOldClipboardSelection: TgmSelection);
    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmPastePixelsCommand -----------------------------------------------------

  TgmPastePixelsCommand = class(TgmCommand)
  private
    FOldSelection    : TgmSelection;  // Original Selection
    FOldBackground   : TBitmap32;
    FPastedLayerIndex: Integer;          // Index of pasted layer.
    FLayerName       : string;

    procedure PasteSelectionOnAim;
  public
    constructor Create(const ACmdAim: TCommandAim;
      const APastedLayerName: string;
      const APastedLayerIndex: Integer;
      const ABeforePasteLayerIndex: Integer;
      const ATargetAlphaChannelIndex: Integer;
      const AOldSelection: TgmSelection;
      const AOldBackground: TBitmap32);

    destructor Destroy; override;

    procedure RollBack; override;
    procedure Execute; override;
  end;

//-- TgmFlipSelectionCommand ---------------------------------------------------

  TgmFlipSelectionCommand = class(TgmCommand)
  private
    FUndoSelection : TgmSelection;
    FRedoSelection : TgmSelection;
    FFlipMode      : TgmFlipMode;

    procedure ExecuteFlipCommand(const ACommandState: TCommandState);
  public
    constructor Create(const ACmdAim: TCommandAim;
      const AOldSelection, ANewSelection: TgmSelection;
      const AFlipMode: TgmFlipMode; const ATargetAlphaChannelIndex: Integer);

    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

implementation

uses
{ Standard Lib }
  Graphics,
{ GraphicsMagic Lib }
  gmAlphaFuncs, gmImageProcessFuncs,
{ GraphicsMagic Forms/Dialogs }
  MainForm;

const
  SHOW_SELECTION       : Boolean = True;
  DO_NOT_SHOW_SELECTION: Boolean = False;

//-- TgmSelectionCommand -------------------------------------------------------

constructor TgmSelectionCommand.Create(const ACmdAim: TCommandAim;
  const AMarqueeTool: TgmMarqueeTools;
  const ASelectionCommandType: TgmSelectionCommandType;
  const AOldSelection, ANewSelection: TgmSelection;
  const ATargetAlphaChannelIndex: Integer);
begin
  inherited Create(ACmdAim, '');

  FMarqueeTool             := AMarqueeTool;
  FSelectionCommandType    := ASelectionCommandType;
  FTargetLayerIndex        := ActiveChildForm.LayerPanelList.CurrentIndex;
  FTargetAlphaChannelIndex := ATargetAlphaChannelIndex;
  FOldSourceBitmap         := nil;

  FCommandName := GetCommandName;
  FOperateName := 'Undo ' + FCommandName;

  if Assigned(AOldSelection) then
  begin
    FUndoSelection := TgmSelection.Create;
    FUndoSelection.AssignAllSelectionData(AOldSelection);
  end
  else
  begin
    FUndoSelection := nil;
  end;

  if Assigned(ANewSelection) then
  begin
    FRedoSelection := TgmSelection.Create;
    FRedoSelection.AssignAllSelectionData(ANewSelection);

    if AOldSelection = nil then
    begin
      FOldSourceBitmap := TBitmap32.Create;
      FOldSourceBitmap.Assign(ANewSelection.SourceBitmap);
    end;
  end
  else
  begin
    FRedoSelection := nil;
  end;
end;

destructor TgmSelectionCommand.Destroy;
begin
  FUndoSelection.Free;
  FRedoSelection.Free;
  FOldSourceBitmap.Free;

  inherited Destroy;
end;

function TgmSelectionCommand.GetCommandName: string;
begin
  Result := '';
  
  case FSelectionCommandType of
    sctNew:
      begin
        case FMarqueeTool of
          mtSingleRow:
            begin
              Result := 'Single Row Marquee';
            end;
            
          mtSingleColumn:
            begin
              Result := 'Single Column Marquee';
            end;
            
          mtRectangular:
            begin
              Result := 'Rectangular Marquee';
            end;

          mtRoundRectangular:
            begin
              Result := 'Round Rectangular Marquee';
            end;
            
          mtElliptical:
            begin
              Result := 'Elliptical Marquee';
            end;

          mtPolygonal:
            begin
              Result := 'Polyonal Lasso';
            end;
            
          mtRegularPolygon:
            begin
              Result := 'Regular Polygonal Lasso';
            end;
            
          mtLasso:
            begin
              Result := 'Lasso';
            end;
            
          mtMagicWand:
            begin
              Result := 'Magic Wand';
            end;
            
          mtMagneticLasso:
            begin
              Result := 'Magnetic Lasso';
            end;
        end;
      end;

    sctTranslate:
      begin
        Result := 'Move Selection';
      end;
      
    sctStretchCorner:
      begin
        Result := 'Resize Selection';
      end;
      
    sctSelectCanvas:
      begin
        Result := 'Select Canvas';
      end;
      
    sctColorRangeSelection:
      begin
        Result := 'Color Range';
      end;
      
    sctFeatherSelection:
      begin
        Result := 'Feather';
      end;
      
    sctSelectInverse:
      begin
        Result := 'Select Inverse';
      end;
      
    sctCommitSelection:
      begin
        Result := 'Commit Selection';
      end;
      
    sctDeselect:
      begin
        Result := 'Deselect';
      end;
      
    sctDeleteSelection:
      begin
        Result := 'Delete Selection';
      end;
      
    sctNudgeSelectionOutline:
      begin
        Result := 'Nudge Outline';
      end;
  end;
end;

procedure TgmSelectionCommand.CreateSelectionWithCommandState(
  const AState: TCommandState; const AShowingSelection: Boolean);
var
  LTempBmp: TBitmap32;
begin
  if Assigned(ActiveChildForm.Selection) then
  begin
    ActiveChildForm.tmrMarchingAnts.Enabled := False;
    ActiveChildForm.RemoveMarchingAnts;
    ActiveChildForm.FreeSelection;  // don't call DeleteSelection() here
  end;

  ActiveChildForm.CreateNewSelection;

  // Get Accumulative RGN before GetMarchingAntsLines function call.
  case AState of
    csUndo:
      begin
        if Assigned(FUndoSelection) then
        begin
          ActiveChildForm.Selection.OriginalMask.Assign(FUndoSelection.OriginalMask);
          ActiveChildForm.Selection.GetAccumRGN(FUndoSelection.OriginalMask);
        end;
      end;

    csRedo:
      begin
        if Assigned(FRedoSelection) then
        begin
          ActiveChildForm.Selection.OriginalMask.Assign(FRedoSelection.OriginalMask);
          ActiveChildForm.Selection.GetAccumRGN(FRedoSelection.OriginalMask);
        end;
      end;
  end;

  case ActiveChildForm.ChannelManager.CurrentChannelType of
    wctAlpha:
      begin
        if Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
        begin
          ActiveChildForm.Selection.SourceBitmap.Assign(
            ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);

          ActiveChildForm.Selection.Background.Assign(
            ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
        end;
      end;

    wctQuickMask:
      begin
        if Assigned(ActiveChildForm.ChannelManager.QuickMaskPanel) then
        begin
          ActiveChildForm.Selection.SourceBitmap.Assign(
            ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
            
          ActiveChildForm.Selection.Background.Assign(
            ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
        end;
      end;

    wctLayerMask:
      begin
        ActiveChildForm.Selection.SourceBitmap.Assign(
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);

        ActiveChildForm.Selection.Background.Assign(
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
      end;

    wctRGB, wctRed, wctGreen, wctBlue:
      begin
        LTempBmp := TBitmap32.Create;
        try
          LTempBmp.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

          if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsMaskLinked then
          begin
            ReplaceAlphaChannelWithMask(LTempBmp,
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
          end;

          ActiveChildForm.Selection.SourceBitmap.Assign(LTempBmp);
          ActiveChildForm.Selection.Background.Assign(LTempBmp);
        finally
          LTempBmp.Free;
        end;
      end;
  end;

  if Assigned(ActiveChildForm.Selection) then
  begin
    ActiveChildForm.Selection.GetActualMaskBorder;  // Get boundary of the selection.

    // if there is a "shadow", process it
    if ActiveChildForm.Selection.HasShadow then
    begin
      ActiveChildForm.Selection.Background.Assign(ActiveChildForm.Selection.SourceBitmap);
      ActiveChildForm.Selection.CutRegionFromOriginal; // Cut regions for the original image and mask.
      ActiveChildForm.Selection.GetForeground;         // Get scaleable foreground image.
      ActiveChildForm.Selection.GetMarchingAntsLines;  // Get Marching-Ants lines from the FResizeMask.

      // Filling the background for making it to region-cutted style.
      case ActiveChildForm.ChannelManager.CurrentChannelType of
        wctAlpha, wctQuickMask, wctLayerMask:
          begin
            ActiveChildForm.Selection.GetBackgroundWithFilledColor(
              Color32(frmMain.BackGrayColor),
              ActiveChildForm.ChannelManager.ChannelSelectedSet );
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            case ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature of
              lfBackground:
                begin
                  ActiveChildForm.Selection.GetBackgroundWithFilledColor(
                    Color32(frmMain.GlobalBackColor),
                    ActiveChildForm.ChannelManager.ChannelSelectedSet );
                end;

              lfTransparent:
                begin
                  if (csRed   in ActiveChildForm.ChannelManager.ChannelSelectedSet) and
                     (csGreen in ActiveChildForm.ChannelManager.ChannelSelectedSet) and
                     (csBlue  in ActiveChildForm.ChannelManager.ChannelSelectedSet) then
                  begin
                    ActiveChildForm.Selection.GetBackgroundWithTransparent;
                  end
                  else
                  begin
                    ActiveChildForm.Selection.GetBackgroundWithFilledColor(
                      Color32(frmMain.GlobalBackColor),
                      ActiveChildForm.ChannelManager.ChannelSelectedSet );
                  end;
                end;
            end;
          end;
      end;

      if AShowingSelection then
      begin
        // Show selection only when we are not processing special layers.
        case ActiveChildForm.ChannelManager.CurrentChannelType of
          wctAlpha, wctQuickMask, wctLayerMask:
            begin
              ActiveChildForm.ShowProcessedSelection;
            end;

          wctRGB, wctRed, wctGreen, wctBlue:
            begin
              if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
                   lfBackground, lfTransparent] then
              begin
                ActiveChildForm.ShowProcessedSelection;
              end;
            end;
        end;
      end;

      ActiveChildForm.RemoveMarchingAnts;
      ActiveChildForm.tmrMarchingAnts.Enabled := True;
    end
    else
    begin
      // if the selection has no "shadow", we just need to delete the selection
      with ActiveChildForm do
      begin
        tmrMarchingAnts.Enabled := False;
        
        RemoveMarchingAnts;
        FreeSelection;  // don't call DeleteSelection() at here
        DeleteSelectionHandleLayer;
        LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
        ChangeImageCursorByMarqueeTools;
      end;
    end;
  end;
end;

procedure TgmSelectionCommand.Rollback;
var
  LNeedChangeSelectionTarget: Boolean;
begin
  FCommandState   := csRedo;
  FOperateName    := 'Redo ' + FCommandName;

  LNeedChangeSelectionTarget := False;

  if FSelectionCommandType in [sctTranslate, sctStretchCorner,
                               sctCommitSelection, sctDeselect,
                               sctDeleteSelection, sctFeatherSelection,
                               sctNudgeSelectionOutline] then
  begin
    if FTargetLayerIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
    begin
      ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);

      if FCommandAim <> caLayer then
      begin
        LNeedChangeSelectionTarget := True;
      end;
    end;

    case FCommandAim of
      caAlphaChannel:
        begin
          if ActiveChildForm.ChannelManager.CurrentChannelType <> wctAlpha then
          begin
            LNeedChangeSelectionTarget := True;
          end
          else
          begin
            if FTargetAlphaChannelIndex <> ActiveChildForm.ChannelManager.SelectedAlphaChannelIndex then
            begin
              LNeedChangeSelectionTarget := True;
            end;
          end;
        end;

      caQuickMask:
        begin
          if ActiveChildForm.ChannelManager.CurrentChannelType <> wctQuickMask then
          begin
            LNeedChangeSelectionTarget := True;
          end;
        end;

      caLayerMask:
        begin
          if ActiveChildForm.ChannelManager.CurrentChannelType <> wctLayerMask then
          begin
            LNeedChangeSelectionTarget := True;
          end;
        end;

      caLayer:
        begin
          if not (ActiveChildForm.ChannelManager.CurrentChannelType in
                    [wctRGB, wctRed, wctGreen, wctBlue]) then
          begin
            LNeedChangeSelectionTarget := True;
          end;
        end;
    end;
  end;

  case FSelectionCommandType of
    sctNew,
    sctSelectCanvas,
    sctColorRangeSelection,
    sctSelectInverse:
      begin
        if Assigned(FUndoSelection) then
        begin
          CreateSelectionWithCommandState(csUndo, SHOW_SELECTION);
        end
        else
        begin
          // we just need to delete the selection
          with ActiveChildForm do
          begin
            tmrMarchingAnts.Enabled := False;

            RemoveMarchingAnts;
            FreeSelection;  // don't call DeleteSelection() at here
            DeleteSelectionHandleLayer;
            LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
            ChangeImageCursorByMarqueeTools;
          end;
        end;
      end;

    sctFeatherSelection:
      begin
        if Assigned(FUndoSelection) then
        begin
          ActiveChildForm.Selection.AssignAllSelectionData(FUndoSelection);

          if LNeedChangeSelectionTarget then
          begin
            ActiveChildForm.ChangeSelectionTarget;
          end;
        end;
      end;

    sctCommitSelection,
    sctDeselect,
    sctDeleteSelection:
      begin
        if Assigned(FUndoSelection) then
        begin
          CreateSelectionWithCommandState(csUndo, DO_NOT_SHOW_SELECTION);
          ActiveChildForm.Selection.AssignAllSelectionData(FUndoSelection);
          ShowSelectionOnAim(FUndoSelection);

          if LNeedChangeSelectionTarget then
          begin
            ActiveChildForm.ChangeSelectionTarget;
          end;
        end;
      end;

    sctTranslate,
    sctStretchCorner,
    sctNudgeSelectionOutline:
      begin
        // Change selection to Undo state.
        if Assigned(FUndoSelection) then
        begin
          ActiveChildForm.Selection.AssignAllSelectionData(FUndoSelection);
        end;

        case FCommandAim of
          caAlphaChannel, caQuickMask, caLayerMask:
            begin
              ShowSelectionOnAim(FUndoSelection);
            end;

          caLayer:
            begin
              if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
                   lfBackground, lfTransparent] then
              begin
                ShowSelectionOnAim(FUndoSelection);
              end;
            end;
        end;

        if LNeedChangeSelectionTarget then
        begin
          ActiveChildForm.ChangeSelectionTarget;
        end;
      end;
  end;

  // process the needed updates
  ProcessAfterSelectionCommandDone;
end; 

procedure TgmSelectionCommand.Execute;
var
  LNeedChangeSelectionTarget: Boolean;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  LNeedChangeSelectionTarget := False;

  if FSelectionCommandType in [sctTranslate, sctStretchCorner,
                               sctCommitSelection, sctDeselect,
                               sctDeleteSelection, sctFeatherSelection,
                               sctNudgeSelectionOutline] then
  begin
    if FTargetLayerIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
    begin
      ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
      
      if FCommandAim <> caLayer then
      begin
        LNeedChangeSelectionTarget := True;
      end;
    end;

    case FCommandAim of
      caAlphaChannel:
        begin
          if ActiveChildForm.ChannelManager.CurrentChannelType <> wctAlpha then
          begin
            LNeedChangeSelectionTarget := True;
          end
          else
          begin
            if FTargetAlphaChannelIndex <> ActiveChildForm.ChannelManager.SelectedAlphaChannelIndex then
            begin
              LNeedChangeSelectionTarget := True;
            end;
          end;
        end;

      caQuickMask:
        begin
          if ActiveChildForm.ChannelManager.CurrentChannelType <> wctQuickMask then
          begin
            LNeedChangeSelectionTarget := True;
          end;
        end;

      caLayerMask:
        begin
          if ActiveChildForm.ChannelManager.CurrentChannelType <> wctLayerMask then
          begin
            LNeedChangeSelectionTarget := True;
          end;
        end;

      caLayer:
        begin
          if not (ActiveChildForm.ChannelManager.CurrentChannelType in
                    [wctRGB, wctRed, wctGreen, wctBlue]) then
          begin
            LNeedChangeSelectionTarget := True;
          end;
        end;
    end;
  end;

  case FSelectionCommandType of
    sctNew,
    sctSelectCanvas,
    sctColorRangeSelection,
    sctSelectInverse:
      begin
        CreateSelectionWithCommandState(csRedo, SHOW_SELECTION);
      end;

    sctFeatherSelection:
      begin
        if Assigned(FUndoSelection) and Assigned(FRedoSelection) then
        begin
          // Using the undo selection to rebuild the selection, and add feather to it.
          
          ActiveChildForm.Selection.AssignAllSelectionData(FUndoSelection);

          ActiveChildForm.Selection.FeatherRadius := FRedoSelection.FeatherRadius;
          ActiveChildForm.Selection.IsFeathered   := FRedoSelection.IsFeathered;

          if LNeedChangeSelectionTarget then
          begin
            ActiveChildForm.ChangeSelectionTarget;
          end;

          ActiveChildForm.MakeSelectionFeather;
        end;
      end;

    sctCommitSelection:
      begin
        // we just need to delete the selection
        with ActiveChildForm do
        begin
          tmrMarchingAnts.Enabled := False;
          
          RemoveMarchingAnts;
          FreeSelection;  // don't call DeleteSelection() at here
          DeleteSelectionHandleLayer;
          LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
          ChangeImageCursorByMarqueeTools;
        end;
      end;

    sctDeselect:
      begin
        if Assigned(FUndoSelection) then
        begin
          // restore background and delete the selection
          ReplaceBackgroundOnAim(FUndoSelection.SourceBitmap);

          with ActiveChildForm do
          begin
            tmrMarchingAnts.Enabled := False;
            
            RemoveMarchingAnts;
            FreeSelection;  // don't call DeleteSelection() at here
            DeleteSelectionHandleLayer;
            LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
            ChangeImageCursorByMarqueeTools;
          end;
        end;
      end;

    sctDeleteSelection:
      begin
        if Assigned(FUndoSelection) then
        begin
          // restore background and delete the selection
          ReplaceBackgroundOnAim(FUndoSelection.Background);

          with ActiveChildForm do
          begin
            tmrMarchingAnts.Enabled := False;

            RemoveMarchingAnts;
            FreeSelection; // don't call DeleteSelection() at here
            DeleteSelectionHandleLayer;
            LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
            ChangeImageCursorByMarqueeTools;
          end;
        end;
      end;

    sctTranslate,
    sctStretchCorner,
    sctNudgeSelectionOutline:
      begin
        // Change selection to Redo state.
        if Assigned(FRedoSelection) then
        begin
          ActiveChildForm.Selection.AssignAllSelectionData(FRedoSelection);
        end;

        case FCommandAim of
          caAlphaChannel, caQuickMask, caLayerMask:
            begin
              ShowSelectionOnAim(FRedoSelection);
            end;

          caLayer:
            begin
              if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
                   lfBackground, lfTransparent] then
              begin
                ShowSelectionOnAim(FRedoSelection);
              end;
            end;
        end;

        if LNeedChangeSelectionTarget then
        begin
          ActiveChildForm.ChangeSelectionTarget;
        end;
      end;
  end;

  // process the needed updates.
  ProcessAfterSelectionCommandDone;
end; 

//-- TgmTransformCommand -------------------------------------------------------

constructor TgmTransformCommand.Create(
  const ATransformCommandType: TgmTransformCommandType;
  const ATransformMode: TgmTransformMode;
  const AUndoSelection: TgmSelection;
  const AUndoTransform, ARedoTransform: TgmSelectionTransformation);
begin
  inherited Create(caNone, '');

  FTransformMode        := ATransformMode;
  FTransformCommandType := ATransformCommandType;
  FCommandName          := GetCommandName;
  FOperateName          := 'Undo ' + FCommandName;
  FTransforming         := False;

  if Assigned(AUndoSelection) then
  begin
    FUndoSelection := TgmSelection.Create;
    FUndoSelection.AssignAllSelectionData(AUndoSelection);
  end
  else
  begin
    FUndoSelection := nil;
  end;

  if Assigned(AUndoTransform) then
  begin
    FUndoTransform := TgmSelectionTransformation.Create(FUndoSelection);
    FUndoTransform.AssignTransformData(AUndoTransform);
  end
  else
  begin
    FUndoTransform := nil;
  end;

  if Assigned(ARedoTransform) then
  begin
    FRedoTransform := TgmSelectionTransformation.Create(FUndoSelection);
    FRedoTransform.AssignTransformData(ARedoTransform);
  end
  else
  begin
    FRedoTransform := nil;
  end;
end;

destructor TgmTransformCommand.Destroy;
begin
  FUndoSelection.Free;
  FUndoTransform.Free;
  FRedoTransform.Free;

  inherited Destroy;
end;

function TgmTransformCommand.GetCommandName: string;
begin
  case FTransformCommandType of
    tctCreate:
      begin
        Result := 'Transform';
      end;

    tctAdjust:
      begin
        case FTransformMode of
          tmDistort:
            begin
              Result := 'Distort Transform';
            end;

          tmRotate:
            begin
              Result := 'Rotate Transform';
            end;
            
          tmScale:
            begin
              Result := 'Scale Transform';
            end;

          tmTranslate:
            begin
              Result := 'Translate Transform';
            end;
        end;
      end;

    tctApply:
      begin
        Result := 'Apply Transform';
      end;
      
    tctCancel:
      begin
        Result := 'Cencel Transform';
      end;
  end;
end;

procedure TgmTransformCommand.ProcessAfterCommandDone;
begin
  ActiveChildForm.ChangeImageCursorByToolTemplets;

  if Assigned(ActiveChildForm.LayerPanelList.SelectedLayerPanel) and
     Assigned(ActiveChildForm.Selection) then
  begin
    case ActiveChildForm.ChannelManager.CurrentChannelType of
      wctAlpha:
        begin
          if Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
          begin
            if FTransforming then
            begin
              if Assigned(ActiveChildForm.SelectionTransformation) then
              begin
                ActiveChildForm.SelectionTransformation.ShowTransformedSelection(
                  ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                  ActiveChildForm.ChannelManager.ChannelSelectedSet);
              end;
            end
            else
            begin
              ActiveChildForm.Selection.ShowSelection(
                ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap,
                ActiveChildForm.ChannelManager.ChannelSelectedSet);
            end;
          end;
        end;

      wctQuickMask:
        begin
          if FTransforming then
          begin
            if Assigned(ActiveChildForm.SelectionTransformation) then
            begin
              ActiveChildForm.SelectionTransformation.ShowTransformedSelection(
                ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                ActiveChildForm.ChannelManager.ChannelSelectedSet);
            end;
          end
          else
          begin
            ActiveChildForm.Selection.ShowSelection(
              ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
              ActiveChildForm.ChannelManager.ChannelSelectedSet);
          end;
        end;

      wctLayerMask:
        begin
          if FTransforming then
          begin
            if Assigned(ActiveChildForm.SelectionTransformation) then
            begin
              ActiveChildForm.SelectionTransformation.ShowTransformedSelection(
                ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
                ActiveChildForm.ChannelManager.ChannelSelectedSet);
            end;
          end
          else
          begin
            ActiveChildForm.Selection.ShowSelection(
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap,
              ActiveChildForm.ChannelManager.ChannelSelectedSet);
          end;
        end;

      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          if FTransforming then
          begin
            if Assigned(ActiveChildForm.SelectionTransformation) then
            begin
              ActiveChildForm.SelectionTransformation.ShowTransformedSelection(
                ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
                ActiveChildForm.ChannelManager.ChannelSelectedSet);
            end;
          end
          else
          begin
            ActiveChildForm.Selection.ShowSelection(
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
              ActiveChildForm.ChannelManager.ChannelSelectedSet);
          end;
        end;
    end;

    if Assigned(ActiveChildForm.SelectionTransformation) then
    begin
      if Assigned(ActiveChildForm.SelectionHandleLayer) then
      begin
        ActiveChildForm.DeleteSelectionHandleLayer;
      end;

      if ActiveChildForm.TransformLayer = nil then
      begin
        ActiveChildForm.CreateTransformLayer;
      end;

      ActiveChildForm.TransformLayer.Bitmap.Clear($00000000);

      ActiveChildForm.SelectionTransformation.DrawOutline(
        ActiveChildForm.TransformLayer.Bitmap.Canvas,
        ActiveChildForm.TransformOffsetVector, pmNotXor);

      ActiveChildForm.ConnectTransformMouseEvents;
    end
    else
    begin
      ActiveChildForm.DeleteTransformLayer;

      if (frmMain.MainTool = gmtMarquee) and
         (frmMain.MarqueeTool = mtMoveResize) then
      begin
        if ActiveChildForm.SelectionHandleLayer = nil then
        begin
          ActiveChildForm.CreateSelectionHandleLayer;
        end;

        ActiveChildForm.Selection.DrawMarchingAntsBorder(
          ActiveChildForm.SelectionHandleLayer.Bitmap.Canvas,
          ActiveChildForm.SelectionHandleLayerOffsetVector.X,
          ActiveChildForm.SelectionHandleLayerOffsetVector.Y, True);
      end
      else
      begin
        ActiveChildForm.DeleteSelectionHandleLayer;
      end;

      ActiveChildForm.ConnectMouseEventsToImage;
    end;

    // showing the transform result
    case ActiveChildForm.ChannelManager.CurrentChannelType of
      wctAlpha:
        begin
          if Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
          begin
            ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
            ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.UpdateThumbnail;
          end;
        end;

      wctQuickMask:
        begin
          ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Changed;
          ActiveChildForm.ChannelManager.QuickMaskPanel.UpdateThumbnail;
        end;

      wctLayerMask:
        begin
          // update the channel of the layer mask
          if Assigned(ActiveChildForm.ChannelManager.LayerMaskPanel) then
          begin
            ActiveChildForm.ChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(
              0, 0, ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);

            ActiveChildForm.ChannelManager.LayerMaskPanel.UpdateThumbnail;
          end;

          ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
          ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
        end;

      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
          ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
        end;
    end;
    
    if Assigned(ActiveChildForm.Selection) then
    begin
      ActiveChildForm.tmrMarchingAnts.Enabled := True;
    end;
  end;
end; 

procedure TgmTransformCommand.Rollback;
var
  LVertexArray: array [0..3] of TPoint;
  i           : Integer;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  if ActiveChildForm.tmrMarchingAnts.Enabled then
  begin
    ActiveChildForm.tmrMarchingAnts.Enabled := False;
  end;

  case FTransformCommandType of
    tctCreate:
      begin
        if Assigned(ActiveChildForm.SelectionTransformation) then
        begin
          ActiveChildForm.SelectionTransformation.CancelTransform;
          ActiveChildForm.FreeSelectionTransformation;
        end;
      end;

    tctAdjust:
      begin
        if Assigned(FUndoTransform) then
        begin
          for i := 0 to 3 do
          begin
            LVertexArray[i] := FUndoTransform.Vertices[i];
          end;

          ActiveChildForm.SelectionTransformation.ChangeVertices(LVertexArray);
          ActiveChildForm.SelectionTransformation.ExecuteTransform;
        end;
      end;

    tctApply, tctCancel:
      begin
        if Assigned(FUndoSelection) and Assigned(FUndoTransform) then
        begin
          ActiveChildForm.FreeSelectionTransformation;

          // restore the selection first
          ActiveChildForm.Selection.AssignAllSelectionData(FUndoSelection);

          // create the Selection Transformation
          ActiveChildForm.CreateSelectionTransformation(FTransformMode);

          // restore the transformation
          ActiveChildForm.SelectionTransformation.AssignTransformData(FUndoTransform);

          // disable channel manager and path panel manager
          ActiveChildForm.ChannelManager.IsEnabled := False;
          ActiveChildForm.PathPanelList.IsEnabled  := False;
        end;
      end;
  end;

  if Assigned(FUndoTransform) then
  begin
    FTransforming := FUndoTransform.IsTransforming;
  end
  else
  begin
    FTransforming := False;
  end;

  ProcessAfterCommandDone;
end;

procedure TgmTransformCommand.Execute;
var
  LVertexArray: array [0..3] of TPoint;
  i           : Integer;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + GetCommandName;

  if ActiveChildForm.tmrMarchingAnts.Enabled then
  begin
    ActiveChildForm.tmrMarchingAnts.Enabled := False;
  end;

  case FTransformCommandType of
    tctCreate:
      begin
        if Assigned(ActiveChildForm.SelectionHandleLayer) then
        begin
          ActiveChildForm.DeleteSelectionHandleLayer;
        end;

        ActiveChildForm.FreeSelectionTransformation;

        if Assigned(ActiveChildForm.Selection) then
        begin
          ActiveChildForm.CreateSelectionTransformation(FTransformMode);

          if Assigned(ActiveChildForm.SelectionTransformation) then
          begin
            // disable channel manager and path panel manager
            ActiveChildForm.ChannelManager.IsEnabled := False;
            ActiveChildForm.PathPanelList.IsEnabled  := False;
          end;
        end;
      end;

    tctAdjust:
      begin
        if Assigned(FRedoTransform) then
        begin
          for i := 0 to 3 do
          begin
            LVertexArray[i] := FRedoTransform.Vertices[i];
          end;

          ActiveChildForm.SelectionTransformation.ChangeVertices(LVertexArray);
          ActiveChildForm.SelectionTransformation.ExecuteTransform;
        end;
      end;

    tctApply, tctCancel:
      begin
        if FTransformCommandType = tctApply then
        begin
          ActiveChildForm.SelectionTransformation.AcceptTransform;
        end
        else
        if FTransformCommandType = tctCancel then
        begin
          ActiveChildForm.SelectionTransformation.CancelTransform;
        end;

        ActiveChildForm.FreeSelectionTransformation;

        // enable channel manager and path panel manager
        ActiveChildForm.ChannelManager.IsEnabled := True;
        ActiveChildForm.PathPanelList.IsEnabled  := True;
      end;
  end;

  if Assigned(FRedoTransform) then
  begin
    FTransforming := FRedoTransform.IsTransforming;
  end;

  ProcessAfterCommandDone;
end;

//-- TgmCutPixelsCommand -------------------------------------------------------

constructor TgmCutPixelsCommand.Create(const ACmdAim: TCommandAim;
  const AOldSelection, AOldClipboardSelection: TgmSelection;
  const ATargetAlphaChannelIndex: Integer);
begin
  inherited Create(ACmdAim, 'Cut Pixels');

  FOperateName             := 'Undo ' + FCommandName;
  FTargetLayerIndex        := ActiveChildForm.LayerPanelList.CurrentIndex;
  FTargetAlphaChannelIndex := ATargetAlphaChannelIndex;

  if Assigned(AOldClipboardSelection) then
  begin
    FOldClipboardSelection := TgmSelection.Create;
    FOldClipboardSelection.AssignSelectionData(AOldClipboardSelection);
  end
  else
  begin
    FOldClipboardSelection := nil;
  end;

  if Assigned(AOldSelection) then
  begin
    FOldSelection := TgmSelection.Create;
    FOldSelection.AssignAllSelectionData(AOldSelection);
  end
  else
  begin
    FOldSelection := nil;
  end;
end;

destructor TgmCutPixelsCommand.Destroy;
begin
  FOldClipboardSelection.Free;
  FOldSelection.Free;
  
  inherited Destroy;
end;

procedure TgmCutPixelsCommand.Rollback;
var
  LNeedChangeSelectionTarget: Boolean;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  LNeedChangeSelectionTarget := False;

  if Assigned(FOldClipboardSelection) then
  begin
    frmMain.FSelectionClipboard.AssignSelectionData(FOldClipboardSelection);
  end
  else
  begin
    FreeAndNil(frmMain.FSelectionClipboard);
  end;
  
  if FTargetLayerIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
    LNeedChangeSelectionTarget := True;
  end;

  case FCommandAim of
    caAlphaChannel:
      begin
        if ActiveChildForm.ChannelManager.CurrentChannelType <> wctAlpha then
        begin
          LNeedChangeSelectionTarget := True;
        end
        else
        begin
          if FTargetAlphaChannelIndex <> ActiveChildForm.ChannelManager.SelectedAlphaChannelIndex then
          begin
            LNeedChangeSelectionTarget := True;
          end;
        end;
      end;

    caQuickMask:
      begin
        if ActiveChildForm.ChannelManager.CurrentChannelType <> wctQuickMask then
        begin
          LNeedChangeSelectionTarget := True;
        end;
      end;

    caLayerMask:
      begin
        if ActiveChildForm.ChannelManager.CurrentChannelType <> wctLayerMask then
        begin
          LNeedChangeSelectionTarget := True;
        end;
      end;

    caLayer:
      begin
        if not (ActiveChildForm.ChannelManager.CurrentChannelType in
                  [wctRGB, wctRed, wctGreen, wctBlue]) then
        begin
          LNeedChangeSelectionTarget := True;
        end;
      end;
  end;

  if Assigned(FOldSelection) then
  begin
    if Assigned(ActiveChildForm.Selection) then
    begin
      ActiveChildForm.FreeSelection;  // don't call DeleteSelection() at here
    end;

    ActiveChildForm.CreateNewSelection;
    ActiveChildForm.Selection.AssignAllSelectionData(FOldSelection);
    
    case FCommandAim of
      caAlphaChannel, caQuickMask, caLayerMask:
        begin
          ShowSelectionOnAim(FOldSelection);
        end;

      caLayer:
        begin
          if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
               lfBackground, lfTransparent] then
          begin
            ShowSelectionOnAim(FOldSelection);
          end;
        end;
    end;

    if LNeedChangeSelectionTarget then
    begin
      ActiveChildForm.ChangeSelectionTarget;
    end;
  end;

  ProcessAfterSelectionCommandDone;
end; 

procedure TgmCutPixelsCommand.Execute;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  if FTargetLayerIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
  end;

  // Cut selection again.
  if Assigned(FOldSelection) then
  begin
    if not Assigned(frmMain.FSelectionClipboard) then
    begin
      frmMain.FSelectionClipboard := TgmSelection.Create;
    end;

    frmMain.FSelectionClipboard.AssignSelectionData(FOldSelection);
    ReplaceBackgroundOnAim(FOldSelection.Background);

    // we just need to delete the selection
    with ActiveChildForm do
    begin
      tmrMarchingAnts.Enabled := False;
      RemoveMarchingAnts;
      FreeSelection;  // dont' call DeleteSelection() at here
      DeleteSelectionHandleLayer;
      LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
      ChangeImageCursorByMarqueeTools;
    end;
  end;

  ProcessAfterSelectionCommandDone;
end;

//-- TgmCopyPixelsCommand ------------------------------------------------------

constructor TgmCopyPixelsCommand.Create(
  const AOldSelection, AOldClipboardSelection: TgmSelection);
begin
  inherited Create(caNone, 'Copy Pixels');

  FOperateName := 'Undo ' + FCommandName;

  if Assigned(AOldClipboardSelection) then
  begin
    FOldClipboardSelection := TgmSelection.Create;
    FOldClipboardSelection.AssignSelectionData(AOldClipboardSelection);
  end
  else
  begin
    FOldClipboardSelection := nil;
  end;

  if Assigned(AOldSelection) then
  begin
    FOldSelection := TgmSelection.Create;
    FOldSelection.AssignAllSelectionData(AOldSelection);
  end
  else
  begin
    FOldSelection := nil;
  end;
end;

destructor TgmCopyPixelsCommand.Destroy;
begin
  FOldClipboardSelection.Free;
  FOldSelection.Free;
  
  inherited Destroy;
end;

procedure TgmCopyPixelsCommand.Rollback;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  if Assigned(FOldClipboardSelection) then
  begin
    frmMain.FSelectionClipboard.AssignSelectionData(FOldClipboardSelection);
  end
  else
  begin
    FreeAndNil(frmMain.FSelectionClipboard);
  end;
end;

procedure TgmCopyPixelsCommand.Execute;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  if Assigned(FOldSelection) then
  begin
    if frmMain.FSelectionClipboard = nil then
    begin
      frmMain.FSelectionClipboard := TgmSelection.Create;
    end;
    
    frmMain.FSelectionClipboard.AssignSelectionData(FOldSelection);
  end;
end;

//-- TgmPastePixelsCommand -----------------------------------------------------

constructor TgmPastePixelsCommand.Create(const ACmdAim: TCommandAim;
  const APastedLayerName: string;
  const APastedLayerIndex: Integer;
  const ABeforePasteLayerIndex: Integer;
  const ATargetAlphaChannelIndex: Integer;
  const AOldSelection: TgmSelection;
  const AOldBackground: TBitmap32);
begin
  inherited Create(ACmdAim, 'Paste Pixels');
  
  FOperateName             := 'Undo ' + FCommandName;
  FLayerName               := APastedLayerName;
  FPastedLayerIndex        := APastedLayerIndex;
  FTargetLayerIndex        := ABeforePasteLayerIndex;
  FTargetAlphaChannelIndex := ATargetAlphaChannelIndex;

  if Assigned(AOldSelection) then
  begin
    FOldSelection := TgmSelection.Create;
    FOldSelection.AssignAllSelectionData(AOldSelection);
  end
  else
  begin
    FOldSelection := nil;
  end;

  FOldBackground := TBitmap32.Create;
  FOldBackground.Assign(AOldBackground);
end;

destructor TgmPastePixelsCommand.Destroy;
begin
  FOldSelection.Free;

  inherited Destroy;
end;

procedure TgmPastePixelsCommand.PasteSelectionOnAim;
var
  LAlphaChannelPanel: TgmAlphaChannelPanel;
  LLayerPanel       : TgmLayerPanel;
begin
  if Assigned(frmMain.FSelectionClipboard) then
  begin
    if ActiveChildForm.Selection = nil then
    begin
      ActiveChildForm.CreateNewSelection;
    end;

    if Assigned(ActiveChildForm.Selection) then
    begin
      ActiveChildForm.tmrMarchingAnts.Enabled := False;
      ActiveChildForm.Selection.AssignSelectionData(frmMain.FSelectionClipboard);

      { The CenterAlignSelection() method culculates the position of the
        selection according to the background size of the selection, so we
        need to specify the background size beforehand. }

      ActiveChildForm.Selection.Background.SetSize(
        ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
        ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height);

      ActiveChildForm.Selection.CenterAlignSelection;

      if frmMain.MarqueeTool = mtMoveResize then
      begin
        if ActiveChildForm.SelectionHandleLayer = nil then
        begin
          ActiveChildForm.CreateSelectionHandleLayer;
        end;

        ActiveChildForm.SelectionHandleLayer.Bitmap.Clear($00000000);

        ActiveChildForm.Selection.DrawMarchingAntsBorder(
          ActiveChildForm.SelectionHandleLayer.Bitmap.Canvas,
          ActiveChildForm.SelectionHandleLayerOffsetVector.X,
          ActiveChildForm.SelectionHandleLayerOffsetVector.Y, True);
      end;

      if CommandAim in [caAlphaChannel, caQuickMask, caLayerMask] then
      begin
        Desaturate32(ActiveChildForm.Selection.CutOriginal);
        ActiveChildForm.Selection.GetForeground;
      end;

      case FCommandAim of
        caAlphaChannel:
          begin
            LAlphaChannelPanel := ActiveChildForm.ChannelManager.GetAlphaChannelPanelByIndex(FTargetAlphaChannelIndex);

            if Assigned(LAlphaChannelPanel) then
            begin
              ActiveChildForm.Selection.SourceBitmap.Assign(LAlphaChannelPanel.AlphaLayer.Bitmap);
              ActiveChildForm.Selection.Background.Assign(LAlphaChannelPanel.AlphaLayer.Bitmap);

              ActiveChildForm.Selection.ShowSelection(
                LAlphaChannelPanel.AlphaLayer.Bitmap,
                ActiveChildForm.ChannelManager.ChannelSelectedSet);

              LAlphaChannelPanel.AlphaLayer.Changed;
              LAlphaChannelPanel.UpdateThumbnail;
            end;
          end;

        caQuickMask:
          begin
            if Assigned(ActiveChildForm.ChannelManager.QuickMaskPanel) then
            begin
              ActiveChildForm.Selection.SourceBitmap.Assign(ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
              ActiveChildForm.Selection.Background.Assign(ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);

              ActiveChildForm.Selection.ShowSelection(
                ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                ActiveChildForm.ChannelManager.ChannelSelectedSet);

              ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Changed;
              ActiveChildForm.ChannelManager.QuickMaskPanel.UpdateThumbnail;
            end;
          end;

        caLayerMask:
          begin
            LLayerPanel := ActiveChildForm.LayerPanelList.GetLayerPanelByIndex(FTargetLayerIndex);

            if Assigned(LLayerPanel) then
            begin
              ActiveChildForm.Selection.SourceBitmap.Assign(LLayerPanel.FMaskImage.Bitmap);
              ActiveChildForm.Selection.Background.Assign(LLayerPanel.FMaskImage.Bitmap);

              ActiveChildForm.Selection.ShowSelection(
                LLayerPanel.FMaskImage.Bitmap,
                ActiveChildForm.ChannelManager.ChannelSelectedSet);

              ActiveChildForm.LayerPanelList.SelectedLayerPanel.UpdateMaskThumbnail;

              // update the mask channel preview layer
              if Assigned(ActiveChildForm.ChannelManager.LayerMaskPanel) then
              begin
                ActiveChildForm.ChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(
                  0, 0, LLayerPanel.FMaskImage.Bitmap);
                  
                ActiveChildForm.ChannelManager.LayerMaskPanel.UpdateThumbnail;
              end;

              if not ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
              begin
                ActiveChildForm.ApplyMaskByIndex(FTargetLayerIndex);
              end
              else
              begin
                // on special layers, save Mask into layer's alpha channels
                LLayerPanel.UpdateLayerAlphaWithMask;
                LLayerPanel.AssociatedLayer.Changed;
              end;

              ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
            end;
          end;

        caLayer:
          begin
            ActiveChildForm.Selection.SourceBitmap.Assign(
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

            ActiveChildForm.Selection.Background.Assign(
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

            ActiveChildForm.Selection.ShowSelection(
              ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
              ActiveChildForm.ChannelManager.ChannelSelectedSet);

            ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
            ActiveChildForm.LayerPanelList.SelectedLayerPanel.UpdateLayerThumbnail;
            ActiveChildForm.ChannelManager.UpdateColorChannelThumbnails(ActiveChildForm.LayerPanelList);
          end;
      end;

      ActiveChildForm.tmrMarchingAnts.Enabled := True;
    end;
  end;
end;

procedure TgmPastePixelsCommand.Rollback;
var
  LNeedChangeSelectionTarget: Boolean;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;
  
  LNeedChangeSelectionTarget := False;

  // delete the pasted selection
  if Assigned(ActiveChildForm.Selection) then
  begin
    ActiveChildForm.FreeSelection; // don't call DeleteSelection() at here
  end;

  // Delete the layer that the pasted selection on, and active the previous layer.
  if FPastedLayerIndex <> FTargetLayerIndex then
  begin
    ActiveChildForm.LayerPanelList.DeleteLayerPanelByIndex(FPastedLayerIndex);
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);

    // without this line, the compiler will give an error
    ActiveChildForm.ChannelManager.AssociateToLayerPanel(
      ActiveChildForm.LayerPanelList.SelectedLayerPanel);

    ActiveChildForm.LayerPanelList.SelectedLayerPanel.UpdateLayerPanelState;

    ActiveChildForm.LayerPanelList.TransparentLayerNumber := ActiveChildForm.LayerPanelList.TransparentLayerNumber - 1;
    LNeedChangeSelectionTarget := True;
  end;

  case FCommandAim of
    caAlphaChannel:
      begin
        if ActiveChildForm.ChannelManager.CurrentChannelType <> wctAlpha then
        begin
          LNeedChangeSelectionTarget := True;
        end
        else
        begin
          if FTargetAlphaChannelIndex <> ActiveChildForm.ChannelManager.SelectedAlphaChannelIndex then
          begin
            LNeedChangeSelectionTarget := True;
          end;
        end;
      end;

    caQuickMask:
      begin
        if ActiveChildForm.ChannelManager.CurrentChannelType <> wctQuickMask then
        begin
          LNeedChangeSelectionTarget := True;
        end;
      end;

    caLayerMask:
      begin
        if ActiveChildForm.ChannelManager.CurrentChannelType <> wctLayerMask then
        begin
          LNeedChangeSelectionTarget := True;
        end;
      end;

    caLayer:
      begin
        if not (ActiveChildForm.ChannelManager.CurrentChannelType in
                  [wctRGB, wctRed, wctGreen, wctBlue]) then
        begin
          LNeedChangeSelectionTarget := True;
        end;
      end;
  end;

  if Assigned(FOldSelection) then
  begin
    ActiveChildForm.CreateNewSelection;

    // Get Accumulative RGN before GetMarchingAntsLines call.
    ActiveChildForm.Selection.OriginalMask.Assign(FOldSelection.OriginalMask);
    ActiveChildForm.Selection.GetAccumRGN(FOldSelection.OriginalMask);

    ActiveChildForm.Selection.AssignAllSelectionData(FOldSelection);

    // Show selection only when we are not processing special layers.
    case FCommandAim of
      caAlphaChannel, caQuickMask, caLayerMask:
        begin
          ShowSelectionOnAim(FOldSelection);
        end;

      caLayer:
        begin
          if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
               lfBackground, lfTransparent] then
          begin
            ShowSelectionOnAim(FOldSelection);
          end;
        end;
    end;

    if LNeedChangeSelectionTarget then
    begin
      ActiveChildForm.ChangeSelectionTarget;
    end;
  end
  else
  begin
    if Assigned(FOldBackground) then
    begin
      ReplaceBackgroundOnAim(FOldBackground);
    end;
  end;

  ProcessAfterSelectionCommandDone;
end;

procedure TgmPastePixelsCommand.Execute;
var
  LNeedChangeSelectionTarget: Boolean;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  LNeedChangeSelectionTarget := False;

  if Assigned(frmMain.FSelectionClipboard) then
  begin
    ActiveChildForm.CommitSelection;

    if FPastedLayerIndex <> FTargetLayerIndex then
    begin
      ActiveChildForm.CreateBlankLayerWithIndex(FPastedLayerIndex);
    end
    else
    begin
      ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);
    end;

    case FCommandAim of
      caAlphaChannel:
        begin
          if ActiveChildForm.ChannelManager.CurrentChannelType <> wctAlpha then
          begin
            LNeedChangeSelectionTarget := True;
          end
          else
          begin
            if FTargetAlphaChannelIndex <> ActiveChildForm.ChannelManager.SelectedAlphaChannelIndex then
            begin
              LNeedChangeSelectionTarget := True;
            end;
          end;
        end;

      caQuickMask:
        begin
          if ActiveChildForm.ChannelManager.CurrentChannelType <> wctQuickMask then
          begin
            LNeedChangeSelectionTarget := True;
          end;
        end;

      caLayerMask:
        begin
          if ActiveChildForm.ChannelManager.CurrentChannelType <> wctLayerMask then
          begin
            LNeedChangeSelectionTarget := True;
          end;
        end;

      caLayer:
        begin
          if not (ActiveChildForm.ChannelManager.CurrentChannelType in
                    [wctRGB, wctRed, wctGreen, wctBlue]) then
          begin
            LNeedChangeSelectionTarget := True;
          end;
        end;
    end;

    PasteSelectionOnAim;

    if LNeedChangeSelectionTarget then
    begin
      ActiveChildForm.ChangeSelectionTarget;
    end;
  end;

  ProcessAfterSelectionCommandDone;
end; 

//-- TgmFlipSelectionCommand ---------------------------------------------------

constructor TgmFlipSelectionCommand.Create(const ACmdAim: TCommandAim;
  const AOldSelection, ANewSelection: TgmSelection;
  const AFlipMode: TgmFlipMode;
  const ATargetAlphaChannelIndex: Integer);
begin
  inherited Create(ACmdAim, '');

  FTargetLayerIndex        := ActiveChildForm.LayerPanelList.CurrentIndex;
  FTargetAlphaChannelIndex := ATargetAlphaChannelIndex;
  FFlipMode                := AFlipMode;

  case FFlipMode of
    fmHorizontal:
      begin
        FCommandName := 'Flip Horizontal';
      end;
      
    fmVertical:
      begin
        FCommandName := 'Flip Vertical';
      end;
  end;

  FOperateName := 'Undo ' + FCommandName;

  if Assigned(AOldSelection) then
  begin
    FUndoSelection := TgmSelection.Create;
    FUndoSelection.AssignAllSelectionData(AOldSelection);
  end
  else
  begin
    FUndoSelection := nil;
  end;

  if Assigned(ANewSelection) then
  begin
    FRedoSelection := TgmSelection.Create;
    FRedoSelection.AssignAllSelectionData(ANewSelection);
  end
  else
  begin
    FRedoSelection := nil;
  end;
end; 

destructor TgmFlipSelectionCommand.Destroy;
begin
  FUndoSelection.Free;
  FRedoSelection.Free;

  inherited Destroy;
end;

procedure TgmFlipSelectionCommand.ExecuteFlipCommand(
  const ACommandState: TCommandState);
var
  LNeedChangeSelectionTarget: Boolean;
  LTargetSelection          : TgmSelection;
begin
  LNeedChangeSelectionTarget := False;
  LTargetSelection           := nil;

  if FTargetLayerIndex <> ActiveChildForm.LayerPanelList.CurrentIndex then
  begin
    ActiveChildForm.LayerPanelList.ActiveLayerPanel(FTargetLayerIndex);

    if FCommandAim <> caLayer then
    begin
      LNeedChangeSelectionTarget := True;
    end;
  end;

  case FCommandAim of
    caAlphaChannel:
      begin
        if ActiveChildForm.ChannelManager.CurrentChannelType <> wctAlpha then
        begin
          LNeedChangeSelectionTarget := True;
        end
        else
        begin
          if FTargetAlphaChannelIndex <> ActiveChildForm.ChannelManager.SelectedAlphaChannelIndex then
          begin
            LNeedChangeSelectionTarget := True;
          end;
        end;
      end;

    caQuickMask:
      begin
        if ActiveChildForm.ChannelManager.CurrentChannelType <> wctQuickMask then
        begin
          LNeedChangeSelectionTarget := True;
        end;
      end;

    caLayerMask:
      begin
        if ActiveChildForm.ChannelManager.CurrentChannelType <> wctLayerMask then
        begin
          LNeedChangeSelectionTarget := True;
        end;
      end;

    caLayer:
      begin
        if not (ActiveChildForm.ChannelManager.CurrentChannelType in
                  [wctRGB, wctRed, wctGreen, wctBlue]) then
        begin
          LNeedChangeSelectionTarget := True;
        end;
      end;
  end;

  // change selection to undo/redo state
  case ACommandState of
    csUndo:
      begin
        if Assigned(FUndoSelection) then
        begin
          ActiveChildForm.Selection.AssignAllSelectionData(FUndoSelection);
          LTargetSelection := FUndoSelection;
        end;
      end;

    csRedo:
      begin
        if Assigned(FRedoSelection) then
        begin
          ActiveChildForm.Selection.AssignAllSelectionData(FRedoSelection);
          LTargetSelection := FRedoSelection;
        end;
      end;
  end;

  // showing the selection
  case FCommandAim of
    caAlphaChannel, caQuickMask, caLayerMask:
      begin
        ShowSelectionOnAim(LTargetSelection);
      end;

    caLayer:
      begin
        if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
             lfBackground, lfTransparent] then
        begin
          ShowSelectionOnAim(LTargetSelection);
        end;
      end;
  end;

  // change target of the selection if needed 
  if LNeedChangeSelectionTarget then
  begin
    ActiveChildForm.ChangeSelectionTarget;
  end;
end; 

procedure TgmFlipSelectionCommand.Rollback;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  ExecuteFlipCommand(csUndo);
  ProcessAfterSelectionCommandDone; // process the needed updates
end;

procedure TgmFlipSelectionCommand.Execute;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  ExecuteFlipCommand(csRedo);
  ProcessAfterSelectionCommandDone; // process the needed updates
end; 

end.
