{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang, Ma Xiaoming and GraphicsMagic Team.
  All rights reserved. }

unit ChannelForm;

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
  TfrmChannel = class(TForm)
    tlbrChannelTools: TToolBar;
    ToolButton6: TToolButton;
    tlbtnLoadChannelAsSelection: TToolButton;
    tlbtnSaveSelectionAsChannel: TToolButton;
    tlbtnCreateNewChannel: TToolButton;
    tlbtnDeleteCurrentChannel: TToolButton;
    scrlbxChannelPanelContainer: TScrollBox;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormEndDock(Sender, Target: TObject; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CreateNewChannelClick(Sender: TObject);
    procedure SaveSelectionAsChannelClick(Sender: TObject);
    procedure DeleteCurrentChannelClick(Sender: TObject);
    procedure LoadChannelAsSelectionClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    FShowingUp: Boolean;  // indicating whether the form is currently showing up

    procedure SetShowingUp(const AValue: Boolean);
  public
    property IsShowingUp: Boolean read FShowingUp write SetShowingUp;
  end;

var
  frmChannel: TfrmChannel;

implementation

uses
{ GraphicsMagic Lib }
  gmHistoryManager,
  gmLayerAndChannel,
  gmTypes,
  gmSelection,
{ GraphicsMagic Data Modules }
  MainDataModule,
  HistoryDataModule,
{ GraphicsMagic Forms/Dialogs }
  MainForm,
  HistoryForm,
  ColorForm,
  LayerForm,
  RichTextEditorForm;

{$R *.dfm}

const
  MIN_FORM_WIDTH  = 236;
  MIN_FORM_HEIGHT = 160;

procedure TfrmChannel.SetShowingUp(const AValue: Boolean);
begin
  FShowingUp := AValue;

  if Assigned(ActiveChildForm) then
  begin
    ActiveChildForm.ChannelManager.IsAllowRefreshChannelPanels := FShowingUp;
  end;
end;

procedure TfrmChannel.FormCreate(Sender: TObject);
begin
  ManualDock(frmMain.pgcntrlDockSite3);
  Show;
  FShowingUp := False;
end;

procedure TfrmChannel.FormShow(Sender: TObject);
begin
  SetShowingUp(True);
end;

procedure TfrmChannel.FormResize(Sender: TObject);
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

procedure TfrmChannel.FormEndDock(Sender, Target: TObject; X, Y: Integer);
begin
  SetShowingUp(True);
end;

procedure TfrmChannel.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SetShowingUp(False);
end;

procedure TfrmChannel.CreateNewChannelClick(Sender: TObject);
var
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  if Assigned(ActiveChildForm) then
  begin
    if frmRichTextEditor.Visible or
       (ActiveChildForm.SelectionTransformation <> nil) or
       (ActiveChildForm.Crop <> nil) then
    begin
      Exit;
    end;

    with ActiveChildForm do
    begin
      ChannelManager.AddNewAlphaChannel(scrlbxChannelPanelContainer,
                                        imgDrawingArea.Layers, LayerPanelList);

      ActiveChildForm.UpdateChannelFormButtonsEnableState;

      frmColor.ColorMode := cmGrayscale;  // update the appearance of the color form

      // Undo/Redo
      LHistoryStatePanel := TgmNewChannelStatePanel.Create(
        frmHistory.scrlbxHistory,
        dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
        ChannelManager.SelectedAlphaChannelIndex);

      HistoryManager.AddHistoryState(LHistoryStatePanel);
    end;
  end;
end;

procedure TfrmChannel.SaveSelectionAsChannelClick(Sender: TObject);
var
  LLastChannelType  : TgmWorkingChannelType;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  if Assigned(ActiveChildForm) then
  begin
    if frmRichTextEditor.Visible or
       (ActiveChildForm.SelectionTransformation <> nil) or
       (ActiveChildForm.Crop <> nil) then
    begin
      Exit;
    end;

    with ActiveChildForm do
    begin
      if ChannelManager.AlphaChannelPanelList.Count = MAX_ALPHA_CHANNEL_COUNT then
      begin
        MessageDlg('The maximum amount of alpha channels is up to limitation.', mtError, [mbOK], 0);
        Exit;
      end;

      if not Assigned(Selection) then
      begin
        MessageDlg('There is no existed selection.', mtError, [mbOK], 0);
        Exit;
      end;

      LLastChannelType := ChannelManager.CurrentChannelType;

      ChannelManager.SaveSelectionAsChannel(scrlbxChannelPanelContainer,
                                            imgDrawingArea.Layers, LayerPanelList,
                                            Selection);

      if LLastChannelType in [wctRGB, wctRed, wctGreen, wctBlue] then
      begin
        ChannelManager.DeselectAllChannels(True);
        ChannelManager.SelectAllColorChannels;
        ChangeSelectionTarget;
      end
      else
      begin
        ChangeSelectionTarget;
        ActiveChildForm.UpdateChannelFormButtonsEnableState;
        frmColor.ColorMode := cmGrayscale;  // update the appearance of the color form
      end;

      // Undo/Redo
      LHistoryStatePanel := TgmSaveSelectionAsChannelStatePanel.Create(
        frmHistory.scrlbxHistory,
        dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
        ChannelManager.AlphaChannelPanelList.Count - 1);

      HistoryManager.AddHistoryState(LHistoryStatePanel);
    end;
  end;
end;

procedure TfrmChannel.DeleteCurrentChannelClick(Sender: TObject);
var
  LChannelName      : string;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  if Assigned(ActiveChildForm) then
  begin
    if frmRichTextEditor.Visible or
       (ActiveChildForm.SelectionTransformation <> nil) or
       (ActiveChildForm.Crop <> nil) then
    begin
      Exit;
    end;

    with ActiveChildForm do
    begin
      case ChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            if Assigned(ChannelManager.SelectedAlphaChannelPanel) then
            begin
              // create Undo/Redo, first
              LHistoryStatePanel := TgmDeleteChannelStatePanel.Create(
                frmHistory.scrlbxHistory,
                dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
                ChannelManager.SelectedAlphaChannelPanel,
                ChannelManager.SelectedAlphaChannelIndex);

              HistoryManager.AddHistoryState(LHistoryStatePanel);
              
              // then, delete it
              ChannelManager.DeleteSelectedAlphaChannels;
              UpdateChannelFormButtonsEnableState;

              if Assigned(Selection) then
              begin
                ChangeSelectionTarget;
              end;
            end;
          end;

        wctQuickMask:
          begin
            // create Undo/Redo, first
            LHistoryStatePanel := TgmExitQuickMaskStatePanel.Create(
              frmHistory.scrlbxHistory,
              dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
              ChannelManager.QuickMaskPanel,
              Selection);

            HistoryManager.AddHistoryState(LHistoryStatePanel);

            { Delete the quick mask by this property assignment,
              see Child form property section for details. }
            EditMode := emStandardMode;

            frmMain.spdbtnStandardMode.Down  := True;
            frmMain.spdbtnQuickMaskMode.Down := False;
          end;

        wctLayerMask:
          begin
            if Assigned(ChannelManager.LayerMaskPanel) then
            begin
              LChannelName := '''' + ChannelManager.LayerMaskPanel.ChannelName + '''';

              if MessageDlg('Delete the channel ' + LChannelName + '?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
              begin
                frmLayer.DeleteLayerClick(Sender);
              end;
            end;
          end;
      end;

      frmColor.ColorMode := cmRGB;  // update the appearance of the color form
    end;
  end;
end;

procedure TfrmChannel.LoadChannelAsSelectionClick(Sender: TObject);
var
  LOldSelection     : TgmSelection;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  if Assigned(ActiveChildForm) then
  begin
    if frmRichTextEditor.Visible or
       (ActiveChildForm.SelectionTransformation <> nil) or
       (ActiveChildForm.Crop <> nil) then
    begin
      Exit;
    end;

    // save the old selection (if any) for undo command
    if Assigned(ActiveChildForm.Selection) then
    begin
      LOldSelection := TgmSelection.Create;
      LOldSelection.AssignAllSelectionData(ActiveChildForm.Selection);
    end
    else
    begin
      LOldSelection := nil;
    end;

    ActiveChildForm.LoadChannelAsSelection;

    // Undo/Redo
    LHistoryStatePanel := TgmLoadChannelAsSelectionStatePanel.Create(
      frmHistory.scrlbxHistory,
      dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
      LOldSelection,
      ActiveChildForm.Selection);

    ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);

    if Assigned(LOldSelection) then
    begin
      FreeAndNil(LOldSelection);
    end;
  end;
end;

end.
