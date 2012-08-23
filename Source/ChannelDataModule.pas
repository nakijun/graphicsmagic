unit ChannelDataModule;

interface

uses
  SysUtils, Classes, Menus;

type
  TdmChannel = class(TDataModule)
    pmnChannelOptions: TPopupMenu;
    mnitmDuplicateChannel: TMenuItem;
    mnitmDeleteChannel: TMenuItem;
    procedure DuplicateRightClickedChannel(Sender: TObject);
    procedure DeleteRightClickedAlphaChannel(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmChannel: TdmChannel;

implementation

uses
{ Standard }
  Controls,
  Dialogs,
{ GraphicsMagic Lib }
  gmHistoryManager,
  gmTypes,
{ GraphicsMagic Data Modules }
  HistoryDataModule,
{ GraphicsMagic Forms/Dialogs }
  MainForm,
  HistoryForm,
  ColorForm,
  LayerForm,
  ChannelForm,
  DuplicateChannelDlg;

{$R *.dfm}

procedure TdmChannel.DuplicateRightClickedChannel(Sender: TObject);
var
  LHistoryStatePanel: TgmHistoryStatePanel;
  LChannelName      : string;
begin
  if Assigned(ActiveChildForm) then
  begin
    frmDuplicateChannel := TfrmDuplicateChannel.Create(nil);
    try
      LChannelName := ActiveChildForm.ChannelManager.GetRightClickedChannelName;

      if LChannelName <> '' then
      begin
        frmDuplicateChannel.ChannelName := LChannelName;

        if frmDuplicateChannel.ShowModal = mrOK then
        begin
          ActiveChildForm.ChannelManager.DuplicateRightClickChannel(
            frmChannel.scrlbxChannelPanelContainer,
            ActiveChildForm.imgDrawingArea.Layers,
            ActiveChildForm.LayerPanelList,
            frmDuplicateChannel.edtDuplicateChannelAs.Text,
            frmDuplicateChannel.chckbxInvertChannel.Checked);

          frmColor.ColorMode := cmGrayscale;  // update the appearance of the color form

          // Undo/Redo
          LHistoryStatePanel := TgmDuplicateChannelStatePanel.Create(
            frmHistory.scrlbxHistory,
            dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
            ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel);

          ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);
        end;
      end;
    finally
      FreeAndNil(frmDuplicateChannel);
    end;
  end;
end;

procedure TdmChannel.DeleteRightClickedAlphaChannel(Sender: TObject);
var
  LChannelName      : string;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  if Assigned(ActiveChildForm) then
  begin
    with ActiveChildForm do
    begin
      case ChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            // create Undo/Redo, first
            LHistoryStatePanel := TgmDeleteChannelStatePanel.Create(
              frmHistory.scrlbxHistory,
              dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
              ChannelManager.SelectedAlphaChannelPanel,
              ChannelManager.SelectedAlphaChannelIndex);

            HistoryManager.AddHistoryState(LHistoryStatePanel);

            // then, delete it
            ChannelManager.DeleteRightClickAlphaChannel;
            UpdateChannelFormButtonsEnableState;

            if Assigned(Selection) then
            begin
              ChangeSelectionTarget;
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

            { delete the quick mask by this property assignment,
              see Child Form property section for details }
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

end.
