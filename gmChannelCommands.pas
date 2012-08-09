{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

unit gmChannelCommands;

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
  Windows, SysUtils, Classes,
{ Graphics32 }
  GR32,
{ GraphicsMagic }
  gmCommands, gmLayerAndChannel, gmSelection;

type
  TgmChannelOptionsHistoryData = record
    OldChannelName   : string;
    NewChannelName   : string;
    
    OldMaskColor     : TColor32;
    NewMaskColor     : TColor32;

    OldOpacityPercent: Double;
    NewOpacityPercent: Double;
    
    OldColorIndicator: TgmMaskColorIndicator;
    NewColorIndicator: TgmMaskColorIndicator;
  end;

//-- TgmChannelCommand----------------------------------------------------------

  TgmChannelCommand = class(TGMCommand)
  protected
    procedure ProcessAfterChannelCommandDone;
  end;

//-- TgmAlphaChannelOptionsCommand ---------------------------------------------

  TgmAlphaChannelOptionsCommand = class(TgmCommand)
  private
    FChannelIndex      : Integer;
    FOptionsHistoryData: TgmChannelOptionsHistoryData;
  public
    constructor Create(const AChannelIndex: Integer;
      const AOptionsHistoryData: TgmChannelOptionsHistoryData);

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmQuickMaskOptionsCommand ------------------------------------------------

  TgmQuickMaskOptionsCommand = class(TgmCommand)
  private
    FQuickMaskPanel    : TgmQuickMaskPanel;
    FOptionsHistoryData: TgmChannelOptionsHistoryData;
  public
    constructor Create(const AQuickMaskPanel: TgmQuickMaskPanel;
      const AOptionsHistoryData: TgmChannelOptionsHistoryData);

    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmLoadChannelAsSelectionCommand ------------------------------------------

  TgmLoadChannelAsSelectionCommand = class(TgmCommand)
  private
    FOldSelection: TgmSelection;
    FNewSelection: TgmSelection;
  public
    constructor Create(const AOldSelection, ANewSelection: TgmSelection);
    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmNewChannelCommand ------------------------------------------------------

  TgmNewChannelCommand = class(TgmChannelCommand)
  private
    FAlphaChannelIndex: Integer;
  public
    constructor Create(const AChannelIndex: Integer);

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmDeleteChannelCommand ---------------------------------------------------

   TgmDeleteChannelCommand = class(TgmChannelCommand)
   private
     FMaskColor         : TColor32;
     FMaskOpacityPercent: Double;
     FMaskColorIndicator: TgmMaskColorIndicator;
     FChannelIndex      : Integer;
     FChannelName       : string;
     FChannelFileName   : string;  // use this name to save the alpha channel to disk
   public
     constructor Create(const AOldChannelPanel: TgmAlphaChannelPanel;
       const AChannelIndex: Integer);

     destructor Destroy; override;

     procedure Rollback; override;
     procedure Execute; override;
   end;

//-- TgmDuplicateChannelCommand ------------------------------------------------

   TgmDuplicateChannelCommand = class(TgmChannelCommand)
   private
     FMaskColor         : TColor32;
     FMaskOpacityPercent: Double;
     FMaskColorIndicator: TgmMaskColorIndicator;
     FChannelName       : string;
     FChannelFileName   : string;  // use this name to save the alpha channel to disk
   public
     constructor Create(const ADuplicatedChannelPanel: TgmAlphaChannelPanel);
     destructor Destroy; override;

     procedure Rollback; override;
     procedure Execute; override;
   end;

//-- TgmEnterQuickMaskCommand --------------------------------------------------

   TgmEnterQuickMaskCommand = class(TgmChannelCommand)
   private
     FOldSelection: TgmSelection;
   public
     constructor Create(const AOldSelection: TgmSelection);
     destructor Destroy; override;

     procedure Rollback; override;
     procedure Execute; override;
   end;

//-- TgmExitQuickMaskCommand ---------------------------------------------------

   TgmExitQuickMaskCommand = class(TgmChannelCommand)
   private
     FChannelFileName   : string;
     FOldSelection      : TgmSelection;
     FMaskColor         : TColor32;
     FMaskOpacityPercent: Double;
     FMaskColorIndicator: TgmMaskColorIndicator;
   public
     constructor Create(const AQuickMaskPanel: TgmQuickMaskPanel;
       const AOldSelection: TgmSelection);

     destructor Destroy; override;

     procedure Rollback; override;
     procedure Execute; override;
   end;

//-- TgmSaveSelectionAsChannelCommand ------------------------------------------

  TgmSaveSelectionAsChannelCommand = class(TgmChannelCommand)
  private
    FSelectionChannelIndex: Integer;
    FChannelFileName      : string;
  public
    constructor Create(const ASelectionChannelIndex: Integer);
    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

implementation

uses
{ Standard Lib }
  Dialogs,
{ GraphicsMagic Lib }
  gmTypes, gmIO,
{ GraphicsMagic Forms/Dialogs }
  MainForm,
  ColorForm,
  LayerForm,
  ChannelForm;

//-- TgmChannelCommand ---------------------------------------------------------

procedure TgmChannelCommand.ProcessAfterChannelCommandDone;
begin
  with ActiveChildForm do
  begin
    ActiveChildForm.UpdateChannelFormButtonsEnableState;

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

//-- TgmAlphaChannelOptionsCommand ---------------------------------------------

constructor TgmAlphaChannelOptionsCommand.Create(const AChannelIndex: Integer;
  const AOptionsHistoryData: TgmChannelOptionsHistoryData);
begin
  inherited Create(caNone, 'Channel Options');

  FOperateName  := 'Undo ' + FCommandName;
  FChannelIndex := AChannelIndex;

  with FOptionsHistoryData do
  begin
    OldChannelName    := AOptionsHistoryData.OldChannelName;
    NewChannelName    := AOptionsHistoryData.NewChannelName;

    OldMaskColor      := AOptionsHistoryData.OldMaskColor;
    NewMaskColor      := AOptionsHistoryData.NewMaskColor;

    OldOpacityPercent := AOptionsHistoryData.OldOpacityPercent;
    NewOpacityPercent := AOptionsHistoryData.NewOpacityPercent;
    
    OldColorIndicator := AOptionsHistoryData.OldColorIndicator;
    NewColorIndicator := AOptionsHistoryData.NewColorIndicator;
  end;
end;

procedure TgmAlphaChannelOptionsCommand.Rollback;
var
  LAlphaChannelPanel: TgmAlphaChannelPanel;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  LAlphaChannelPanel := ActiveChildForm.ChannelManager.GetAlphaChannelPanelByIndex(FChannelIndex);

  if Assigned(LAlphaChannelPanel) then
  begin
    LAlphaChannelPanel.ChannelName        := FOptionsHistoryData.OldChannelName;
    LAlphaChannelPanel.MaskColor          := FOptionsHistoryData.OldMaskColor;
    LAlphaChannelPanel.MaskOpacityPercent := FOptionsHistoryData.OldOpacityPercent;
    LAlphaChannelPanel.MaskColorIndicator := FOptionsHistoryData.OldColorIndicator;

    LAlphaChannelPanel.AlphaLayer.Changed;
  end;
end; 

procedure TgmAlphaChannelOptionsCommand.Execute;
var
  LAlphaChannelPanel: TgmAlphaChannelPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  LAlphaChannelPanel := ActiveChildForm.ChannelManager.GetAlphaChannelPanelByIndex(FChannelIndex);

  if Assigned(LAlphaChannelPanel) then
  begin
    LAlphaChannelPanel.ChannelName        := FOptionsHistoryData.NewChannelName;
    LAlphaChannelPanel.MaskColor          := FOptionsHistoryData.NewMaskColor;
    LAlphaChannelPanel.MaskOpacityPercent := FOptionsHistoryData.NewOpacityPercent;
    LAlphaChannelPanel.MaskColorIndicator := FOptionsHistoryData.NewColorIndicator;

    LAlphaChannelPanel.AlphaLayer.Changed;
  end;
end;

//-- TgmQuickMaskOptionsCommand ------------------------------------------------

constructor TgmQuickMaskOptionsCommand.Create(
  const AQuickMaskPanel: TgmQuickMaskPanel;
  const AOptionsHistoryData: TgmChannelOptionsHistoryData);
begin
  inherited Create(caNone, 'Channel Options');

  FOperateName    := 'Undo ' + FCommandName;
  FQuickMaskPanel := AQuickMaskPanel;

  if Assigned(FQuickMaskPanel) then
  begin
    with FOptionsHistoryData do
    begin
      OldMaskColor      := AOptionsHistoryData.OldMaskColor;
      NewMaskColor      := AOptionsHistoryData.NewMaskColor;

      OldOpacityPercent := AOptionsHistoryData.OldOpacityPercent;
      NewOpacityPercent := AOptionsHistoryData.NewOpacityPercent;
      
      OldColorIndicator := AOptionsHistoryData.OldColorIndicator;
      NewColorIndicator := AOptionsHistoryData.NewColorIndicator;
    end;
  end;
end;

destructor TgmQuickMaskOptionsCommand.Destroy;
begin
  FQuickMaskPanel := nil;
  inherited Destroy;
end;

procedure TgmQuickMaskOptionsCommand.Rollback;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  if Assigned(FQuickMaskPanel) then
  begin
    FQuickMaskPanel.MaskColor          := FOptionsHistoryData.OldMaskColor;
    FQuickMaskPanel.MaskOpacityPercent := FOptionsHistoryData.OldOpacityPercent;
    FQuickMaskPanel.MaskColorIndicator := FOptionsHistoryData.OldColorIndicator;

    FQuickMaskPanel.AlphaLayer.Changed;
  end;
end;

procedure TgmQuickMaskOptionsCommand.Execute;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  if Assigned(FQuickMaskPanel) then
  begin
    FQuickMaskPanel.MaskColor          := FOptionsHistoryData.NewMaskColor;
    FQuickMaskPanel.MaskOpacityPercent := FOptionsHistoryData.NewOpacityPercent;
    FQuickMaskPanel.MaskColorIndicator := FOptionsHistoryData.NewColorIndicator;

    FQuickMaskPanel.AlphaLayer.Changed;
  end;
end;

//-- TgmLoadChannelAsSelectionCommand ------------------------------------------

constructor TgmLoadChannelAsSelectionCommand.Create(
  const AOldSelection, ANewSelection: TgmSelection);
begin
  inherited Create(caNone, 'Load Selection');

  FOperateName := 'Undo ' + FCommandName;

  if Assigned(AOldSelection) then
  begin
    FOldSelection := TgmSelection.Create;
    FOldSelection.AssignAllSelectionData(AOldSelection);
  end
  else
  begin
    FOldSelection := nil;
  end;

  if Assigned(ANewSelection) then
  begin
    FNewSelection := TgmSelection.Create;
    FNewSelection.AssignAllSelectionData(ANewSelection);
  end
  else
  begin
    FNewSelection := nil;
  end;
end;

destructor TgmLoadChannelAsSelectionCommand.Destroy;
begin
  FOldSelection.Free;
  FNewSelection.Free;
  
  inherited Destroy;
end;

procedure TgmLoadChannelAsSelectionCommand.Rollback;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  with ActiveChildForm do
  begin
    if Assigned(Selection) then
    begin
      tmrMarchingAnts.Enabled := False;

      FreeSelection;  // note that, don't call DeleteSelection() at here
      DeleteSelectionHandleLayer;
    end;

    if Assigned(FOldSelection) then
    begin
      CreateNewSelection;
      Selection.AssignAllSelectionData(FOldSelection);

      ChangeSelectionTarget;
      tmrMarchingAnts.Enabled := True;

      if frmMain.MainTool = gmtMarquee then
      begin
        if frmMain.MarqueeTool = mtMoveResize then
        begin
          CreateSelectionHandleLayer;
          UpdateSelectionHandleBorder;
        end;
      end;
    end
    else
    begin
      LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
    end;
  end;

  frmMain.UpdateMarqueeOptions;
end;

procedure TgmLoadChannelAsSelectionCommand.Execute;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  with ActiveChildForm do
  begin
    if Assigned(Selection) then
    begin
      tmrMarchingAnts.Enabled := False;

      FreeSelection;   // don't call DeleteSelection() at here
      DeleteSelectionHandleLayer;
    end;

    if Assigned(FNewSelection) then
    begin
      CreateNewSelection;
      Selection.AssignAllSelectionData(FNewSelection);

      ChangeSelectionTarget;
      tmrMarchingAnts.Enabled := True;

      if frmMain.MainTool = gmtMarquee then
      begin
        if frmMain.MarqueeTool = mtMoveResize then
        begin
          CreateSelectionHandleLayer;
          UpdateSelectionHandleBorder;
        end;
      end;
    end
    else
    begin
      LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
    end;
  end;

  frmMain.UpdateMarqueeOptions;
end;

//-- TgmNewChannelCommand ------------------------------------------------------

constructor TgmNewChannelCommand.Create(const AChannelIndex: Integer);
begin
  inherited Create(caNone, 'New Channel');

  FAlphaChannelIndex := AChannelIndex;
  FOperateName       := 'Undo ' + FCommandName;
end;

procedure TgmNewChannelCommand.Rollback;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  with ActiveChildForm do
  begin
    ChannelManager.DeleteAlphaChannelByIndex(FAlphaChannelIndex);
    ChannelManager.DecrementAlphaChannelNumber(1);
    ChannelManager.DeselectAllChannels(False);
    ChannelManager.SelectAllColorChannels;
    LayerPanelList.SelectedLayerPanel.UpdateLayerPanelState;

    if Assigned(Selection) then
    begin
      ChangeSelectionTarget;
    end;
  end;

  ProcessAfterChannelCommandDone;
end;

procedure TgmNewChannelCommand.Execute;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  with ActiveChildForm do
  begin
    ChannelManager.AddNewAlphaChannel(frmChannel.scrlbxChannelPanelContainer,
                                      imgDrawingArea.Layers, LayerPanelList);
  end;

  ProcessAfterChannelCommandDone;
end;

//-- TgmDeleteChannelCommand ---------------------------------------------------

constructor TgmDeleteChannelCommand.Create(
  const AOldChannelPanel: TgmAlphaChannelPanel; const AChannelIndex: Integer);
var
  LCommandDir: string;
begin
  inherited Create(caNone, 'Delete Channel');

  FChannelIndex := AChannelIndex;
  FOperateName  := 'Undo ' + FCommandName;

  if Assigned(AOldChannelPanel) then
  begin
    FMaskColor          := AOldChannelPanel.MaskColor;
    FMaskOpacityPercent := AOldChannelPanel.MaskOpacityPercent;
    FMaskColorIndicator := AOldChannelPanel.MaskColorIndicator;
    FChannelName        := AOldChannelPanel.ChannelName;

    LCommandDir := ExtractFileDir(ParamStr(0)) + '\History';

    if not DirectoryExists(LCommandDir) then
    begin
      CreateDir(LCommandDir);
    end;

    FChannelFileName := LCommandDir + '\AlphaChannel' + IntToStr(GetTickCount);

    { Note that, if the bitmap is already a grayscale bitmap, we just need
      to save the blue channels to disk, because it is fatest.

      When we load them back, we should load them with csGrayscale mode to
      get the original grayscale bitmap. }

    SaveChannelsToFile(AOldChannelPanel.AlphaLayer.Bitmap, csBlue,
                       FChannelFileName);
  end
  else
  begin
    FChannelFileName := '';
  end;
end;

destructor TgmDeleteChannelCommand.Destroy;
begin
  if FChannelFileName <> '' then
  begin
    if FileExists(FChannelFileName) then
    begin
      DeleteFile(FChannelFileName);
    end;
  end;

  inherited Destroy;
end; 

procedure TgmDeleteChannelCommand.Rollback;
var
  LAlphaChannelPanel: TgmAlphaChannelPanel;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  with ActiveChildForm do
  begin
    if FChannelFileName <> '' then
    begin
      // insert a new alpha channel
      ChannelManager.InsertNewAlphaChannel(frmChannel.scrlbxChannelPanelContainer,
                                           imgDrawingArea.Layers, LayerPanelList,
                                           FChannelIndex);

      // restore the alpha channel count number
      ChannelManager.DecrementAlphaChannelNumber(1);

      LAlphaChannelPanel := ChannelManager.GetAlphaChannelPanelByIndex(FChannelIndex);

      if Assigned(LAlphaChannelPanel) then
      begin
        // change the alpha channel info to the state that before deletion
        LAlphaChannelPanel.MaskColor          := FMaskColor;
        LAlphaChannelPanel.MaskOpacityPercent := FMaskOpacityPercent;
        LAlphaChannelPanel.MaskColorIndicator := FMaskColorIndicator;
        LAlphaChannelPanel.ChannelName        := FChannelName;

        if LoadChannelsFromFile(LAlphaChannelPanel.AlphaLayer.Bitmap, csGrayscale, FChannelFileName) = False then
        begin
          MessageDlg(gmIO.GMIOErrorMsgOutput, mtError, [mbOK], 0);
        end;
        
        LAlphaChannelPanel.UpdateThumbnail;
      end;

      // switch channels
      if Assigned(ChannelManager.QuickMaskPanel) then
      begin
        ChannelManager.SelectQuickMask;
      end
      else
      begin
        ChannelManager.DeselectAllChannels(True);
        ChannelManager.SelectAllColorChannels;
        LayerPanelList.SelectedLayerPanel.UpdateLayerPanelState;

        // change selection target, if any
        if Assigned(Selection) then
        begin
          ChangeSelectionTarget;
        end;
      end;

      LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
    end;
  end;

  ProcessAfterChannelCommandDone;
end;

procedure TgmDeleteChannelCommand.Execute;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  with ActiveChildForm do
  begin
    ChannelManager.DeleteAlphaChannelByIndex(FChannelIndex);

    if Assigned(ChannelManager.QuickMaskPanel) then
    begin
      ChannelManager.SelectQuickMask;
    end
    else
    begin
      ChannelManager.DeselectAllChannels(False);
      ChannelManager.SelectAllColorChannels;
      LayerPanelList.SelectedLayerPanel.UpdateLayerPanelState;

      if Assigned(Selection) then
      begin
        ChangeSelectionTarget;
      end;
    end;
  end;

  ProcessAfterChannelCommandDone;
end;

//-- TgmDuplicateChannelCommand ------------------------------------------------

constructor TgmDuplicateChannelCommand.Create(
  const ADuplicatedChannelPanel: TgmAlphaChannelPanel);
var
  LCommandDir: string;
begin
  inherited Create(caNone, 'Duplicate Channel');

  FOperateName  := 'Undo ' + FCommandName;

  if Assigned(ADuplicatedChannelPanel) then
  begin
    FMaskColor          := ADuplicatedChannelPanel.MaskColor;
    FMaskOpacityPercent := ADuplicatedChannelPanel.MaskOpacityPercent;
    FMaskColorIndicator := ADuplicatedChannelPanel.MaskColorIndicator;
    FChannelName        := ADuplicatedChannelPanel.ChannelName;

    LCommandDir := ExtractFileDir(ParamStr(0)) + '\History';

    if not DirectoryExists(LCommandDir) then
    begin
      CreateDir(LCommandDir);
    end;

    FChannelFileName := LCommandDir + '\AlphaChannel' + IntToStr(GetTickCount);

    { Note that, if the bitmap is already a grayscale bitmap, we just need
      to save the blue channels to disk, because it is fatest.

      When we load them back, we should load them with csGrayscale mode to
      get the original grayscale bitmap. }

    SaveChannelsToFile(ADuplicatedChannelPanel.AlphaLayer.Bitmap, csBlue,
                       FChannelFileName);
  end
  else
  begin
    FChannelFileName := '';
  end;
end;

destructor TgmDuplicateChannelCommand.Destroy;
begin
  if FChannelFileName <> '' then
  begin
    if FileExists(FChannelFileName) then
    begin
      DeleteFile(FChannelFileName);
    end;
  end;

  inherited Destroy;
end;

procedure TgmDuplicateChannelCommand.Rollback;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  with ActiveChildForm do
  begin
    ChannelManager.DeleteAlphaChannelByIndex(ChannelManager.AlphaChannelPanelList.Count - 1);

    // restore the alpha channel count number
    ChannelManager.DecrementAlphaChannelNumber(1);

    // switch to a proper channel
    if ChannelManager.AlphaChannelPanelList.Count > 0 then
    begin
      ChannelManager.SelectAlphaChannelByIndex(ChannelManager.AlphaChannelPanelList.Count - 1);
      LayerPanelList.SelectedLayerPanel.UpdateLayerPanelState;

      if Assigned(Selection) then
      begin
        ChangeSelectionTarget;
      end;
    end
    else
    begin
      if Assigned(ChannelManager.LayerMaskPanel) then
      begin
        ChannelManager.SelectLayerMask;
      end
      else
      if Assigned(ChannelManager.QuickMaskPanel) then
      begin
        ChannelManager.SelectQuickMask;
      end
      else
      begin
        ChannelManager.DeselectAllChannels(False);
        ChannelManager.SelectAllColorChannels;
        LayerPanelList.SelectedLayerPanel.UpdateLayerPanelState;

        if Assigned(Selection) then
        begin
          ChangeSelectionTarget;
        end;
      end;
    end;
  end;

  ProcessAfterChannelCommandDone;
end;

procedure TgmDuplicateChannelCommand.Execute;
var
  LAlphaChannelPanel: TgmAlphaChannelPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  with ActiveChildForm do
  begin
    if FChannelFileName <> '' then
    begin
      // add a new alpha channel
      ChannelManager.AddNewAlphaChannel(frmChannel.scrlbxChannelPanelContainer,
                                        imgDrawingArea.Layers, LayerPanelList);

      LAlphaChannelPanel := ChannelManager.GetAlphaChannelPanelByIndex(
        ChannelManager.AlphaChannelPanelList.Count - 1);

      if Assigned(LAlphaChannelPanel) then
      begin
        // change the alpha channel info to the state that before deletion
        LAlphaChannelPanel.MaskColor          := FMaskColor;
        LAlphaChannelPanel.MaskOpacityPercent := FMaskOpacityPercent;
        LAlphaChannelPanel.MaskColorIndicator := FMaskColorIndicator;
        LAlphaChannelPanel.ChannelName        := FChannelName;

        if LoadChannelsFromFile(LAlphaChannelPanel.AlphaLayer.Bitmap, csGrayscale, FChannelFileName) = False then
        begin
          MessageDlg(gmIO.GMIOErrorMsgOutput, mtError, [mbOK], 0);
        end;
        
        LAlphaChannelPanel.UpdateThumbnail;
      end;
      
      // change selection target, if any
      if Assigned(Selection) then
      begin
        ChangeSelectionTarget;
      end;

      LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
    end;
  end;

  ProcessAfterChannelCommandDone;
end; 

//-- TgmEnterQuickMaskCommand --------------------------------------------------

constructor TgmEnterQuickMaskCommand.Create(const AOldSelection: TgmSelection);
begin
  inherited Create(caNone, 'Enter Quick Mask');

  FOperateName  := 'Undo ' + FCommandName;

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

destructor TgmEnterQuickMaskCommand.Destroy;
begin
  FOldSelection.Free;
  inherited Destroy;
end;

procedure TgmEnterQuickMaskCommand.Rollback;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  with ActiveChildForm do
  begin
    EditMode := emStandardMode;
    frmMain.spdbtnStandardMode.Down := True;

    // delete the selection created by switching back to standard edit mode
    if Assigned(Selection) then
    begin
      tmrMarchingAnts.Enabled := False;

      FreeSelection;  // don't call DeleteSelection() at here
      DeleteSelectionHandleLayer;
    end;

    if Assigned(FOldSelection) then
    begin
      if not Assigned(Selection) then
      begin
        CreateNewSelection;
      end;
      
      Selection.AssignAllSelectionData(FOldSelection);
      ChangeSelectionTarget;

      if frmMain.MainTool = gmtMarquee then
      begin
        if frmMain.MarqueeTool = mtMoveResize then
        begin
          CreateSelectionHandleLayer;
          UpdateSelectionHandleBorder;
        end;
      end;

      tmrMarchingAnts.Enabled := True;
    end;
  end;

  ProcessAfterChannelCommandDone;
end;

procedure TgmEnterQuickMaskCommand.Execute;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  ActiveChildForm.EditMode         := emQuickMaskMode;
  frmMain.spdbtnQuickMaskMode.Down := True;

  ProcessAfterChannelCommandDone;
end;

//-- TgmExitQuickMaskCommand ---------------------------------------------------

constructor TgmExitQuickMaskCommand.Create(
  const AQuickMaskPanel: TgmQuickMaskPanel; const AOldSelection: TgmSelection);
var
  LCommandDir: string;
begin
  inherited Create(caNone, 'Exit Quick Mask');

  FOperateName  := 'Undo ' + FCommandName;

  if Assigned(AOldSelection) then
  begin
    FOldSelection := TgmSelection.Create;
    FOldSelection.AssignAllSelectionData(AOldSelection);
  end
  else
  begin
    FOldSelection := nil;
  end;

  if Assigned(AQuickMaskPanel) then
  begin
    FMaskColor          := AQuickMaskPanel.MaskColor;
    FMaskOpacityPercent := AQuickMaskPanel.MaskOpacityPercent;
    FMaskColorIndicator := AQuickMaskPanel.MaskColorIndicator;

    LCommandDir := ExtractFileDir(ParamStr(0)) + '\History';

    if not DirectoryExists(LCommandDir) then
    begin
      CreateDir(LCommandDir);
    end;

    FChannelFileName := LCommandDir + '\QuickMask' + IntToStr(GetTickCount);

    { Note that, if the bitmap is already a grayscale bitmap, we just need
      to save the blue channels to disk, because it is fatest.

      When we load them back, we should load them with csGrayscale mode to
      get the original grayscale bitmap. }

    SaveChannelsToFile(AQuickMaskPanel.AlphaLayer.Bitmap, csBlue, FChannelFileName);
  end
  else
  begin
    FChannelFileName := '';
  end;
end;

destructor TgmExitQuickMaskCommand.Destroy;
begin
  FOldSelection.Free;

  if FChannelFileName <> '' then
  begin
    if FileExists(FChannelFileName) then
    begin
      DeleteFile(FChannelFileName);
    end;
  end;

  inherited Destroy;
end;

procedure TgmExitQuickMaskCommand.Rollback;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  with ActiveChildForm do
  begin
    if Assigned(Selection) then
    begin
      tmrMarchingAnts.Enabled := False;

      FreeSelection;   // don't call DeleteSelection() at here
      DeleteSelectionHandleLayer;
    end;

    EditMode := emQuickMaskMode;
    frmMain.spdbtnQuickMaskMode.Down := True;

    if FChannelFileName <> '' then
    begin
      if FileExists(FChannelFileName) and
         Assigned(ChannelManager.QuickMaskPanel) then
      begin
        ChannelManager.QuickMaskPanel.MaskColor          := FMaskColor;
        ChannelManager.QuickMaskPanel.MaskOpacityPercent := FMaskOpacityPercent;
        ChannelManager.QuickMaskPanel.MaskColorIndicator := FMaskColorIndicator;

        if LoadChannelsFromFile(ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap,
                                csGrayscale, FChannelFileName) = False then
        begin
          MessageDlg(gmIO.GMIOErrorMsgOutput, mtError, [mbOK], 0);
        end;

        ChannelManager.QuickMaskPanel.AlphaLayer.Changed;
        ChannelManager.QuickMaskPanel.UpdateThumbnail;
      end;
    end;

    if Assigned(FOldSelection) then
    begin
      if not Assigned(Selection) then
      begin
        CreateNewSelection;
      end;

      Selection.AssignAllSelectionData(FOldSelection);
      ChangeSelectionTarget;

      if frmMain.MainTool = gmtMarquee then
      begin
        if frmMain.MarqueeTool = mtMoveResize then
        begin
          CreateSelectionHandleLayer;
          UpdateSelectionHandleBorder;
        end;
      end;

      tmrMarchingAnts.Enabled := True;
    end;
  end;

  ProcessAfterChannelCommandDone;
end;

procedure TgmExitQuickMaskCommand.Execute;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  ActiveChildForm.EditMode        := emStandardMode;
  frmMain.spdbtnStandardMode.Down := True;

  ProcessAfterChannelCommandDone;
end;

//-- TgmSaveSelectionAsChannelCommand ------------------------------------------

constructor TgmSaveSelectionAsChannelCommand.Create(
  const ASelectionChannelIndex: Integer);
var
  LAlphaChannelPanel: TgmAlphaChannelPanel;
  LCommandDir       : string;
begin
  inherited Create(caNone, 'Save Selection');

  FOperateName           := 'Undo ' + FCommandName;
  FSelectionChannelIndex := ASelectionChannelIndex;

  LAlphaChannelPanel := ActiveChildForm.ChannelManager.GetAlphaChannelPanelByIndex(FSelectionChannelIndex);

  if Assigned(LAlphaChannelPanel) then
  begin
    LCommandDir := ExtractFileDir(ParamStr(0)) + '\History';

    if not DirectoryExists(LCommandDir) then
    begin
      CreateDir(LCommandDir);
    end;

    FChannelFileName := LCommandDir + '\AlphaChannel' + IntToStr(GetTickCount);

    { Note that, if the bitmap is already a grayscale bitmap, we just need
      to save the blue channels to disk, because it is fatest.

      When we load them back, we should load them with csGrayscale mode to
      get the original grayscale bitmap. }

    SaveChannelsToFile(LAlphaChannelPanel.AlphaLayer.Bitmap, csBlue,
                       FChannelFileName);
  end
  else
  begin
    FChannelFileName := '';
  end;
end;

destructor TgmSaveSelectionAsChannelCommand.Destroy;
begin
  if FChannelFileName <> '' then
  begin
    if FileExists(FChannelFileName) then
    begin
      DeleteFile(FChannelFileName);
    end;
  end;

  inherited Destroy;
end;

procedure TgmSaveSelectionAsChannelCommand.Rollback;
var
  LNeedSwitchChannel: Boolean;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  with ActiveChildForm do
  begin
    if (ChannelManager.CurrentChannelType = wctAlpha) and
       (ChannelManager.SelectedAlphaChannelIndex = (ChannelManager.AlphaChannelPanelList.Count - 1)) then
    begin
      LNeedSwitchChannel := True;
    end
    else
    begin
      LNeedSwitchChannel := False;
    end;

    ChannelManager.DeleteAlphaChannelByIndex(ChannelManager.AlphaChannelPanelList.Count - 1);
    ChannelManager.DecrementAlphaChannelNumber(1);

    if LNeedSwitchChannel then
    begin
      // switch to a proper channel
      if Assigned(ChannelManager.LayerMaskPanel) then
      begin
        ChannelManager.SelectLayerMask;
      end
      else
      if Assigned(ChannelManager.QuickMaskPanel) then
      begin
        ChannelManager.SelectQuickMask;
      end
      else
      begin
        ChannelManager.DeselectAllChannels(DONT_HIDE_CHANNEL);
        ChannelManager.SelectAllColorChannels;
        LayerPanelList.SelectedLayerPanel.UpdateLayerPanelState;

        if Assigned(Selection) then
        begin
          ChangeSelectionTarget;
        end;
      end;
    end;
  end;

  ProcessAfterChannelCommandDone;
end;

procedure TgmSaveSelectionAsChannelCommand.Execute;
var
  LAlphaChannelPanel: TgmAlphaChannelPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  with ActiveChildForm do
  begin
    if FChannelFileName <> '' then
    begin
      if FileExists(FChannelFileName) then
      begin
        ChannelManager.AddInativeAlphaChannel(frmChannel.scrlbxChannelPanelContainer,
                                              imgDrawingArea.Layers, LayerPanelList);

        LAlphaChannelPanel := ChannelManager.GetAlphaChannelPanelByIndex(FSelectionChannelIndex);

        if Assigned(LAlphaChannelPanel) then
        begin
          if LoadChannelsFromFile(LAlphaChannelPanel.AlphaLayer.Bitmap, csGrayscale, FChannelFileName) = False then
          begin
            MessageDlg(gmIO.GMIOErrorMsgOutput, mtError, [mbOK], 0);
          end;
          
          LAlphaChannelPanel.AlphaLayer.Changed;
          LAlphaChannelPanel.UpdateThumbnail;
        end;
      end;
    end;
  end;

  ProcessAfterChannelCommandDone;
end; 

end.
