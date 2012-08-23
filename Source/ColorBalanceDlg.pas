{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

unit ColorBalanceDlg;

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
  StdCtrls, Buttons, ComCtrls,
{ Graphics32 Lib }
  GR32_RangeBars,
{ GraphicsMagic Lib }
  gmColorBalance;

type
  TfrmColorBalance = class(TForm)
    grpbxColorBalance: TGroupBox;
    lblColorLevels: TLabel;
    edtCyanToRed: TEdit;
    edtMagentaToGreen: TEdit;
    edtYellowToBlue: TEdit;
    lblCyan: TLabel;
    lblRed: TLabel;
    lblMagenta: TLabel;
    lblYellow: TLabel;
    lblGreen: TLabel;
    lblBlue: TLabel;
    grpbxToneBalance: TGroupBox;
    rdbtnShadows: TRadioButton;
    rdbtnMidtones: TRadioButton;
    rdbtnHighlights: TRadioButton;
    chckbxPreserveLuminosity: TCheckBox;
    btbtnOK: TBitBtn;
    btbtnCancel: TBitBtn;
    btnReset: TButton;
    chckbxPreview: TCheckBox;
    ggbrYellowToBlue: TGaugeBar;
    ggbrCyanToRed: TGaugeBar;
    ggbrMagentaToGreen: TGaugeBar;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure AdjustColorBalance(Sender: TObject);
    procedure chckbxPreviewClick(Sender: TObject);
    procedure edtCyanToRedChange(Sender: TObject);
    procedure edtMagentaToGreenChange(Sender: TObject);
    procedure edtYellowToBlueChange(Sender: TObject);
    procedure ChangeTransferMode(Sender: TObject);
    procedure chckbxPreserveLuminosityClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btbtnOKClick(Sender: TObject);
    procedure ColorBalanceBarMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ColorBalanceBarMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    FPreserveLuminosity: Boolean;
    FNormalColorBalance: TgmColorBalance;  // used for menu command
    FColorBalance      : TgmColorBalance;  // pointer to FNormalColorBalance or a Color Balance in a Color Balance layer
    FTransferMode      : TgmTransferMode;

    FBarIsChanging     : Boolean;
    FEditIsChanging    : Boolean;
    FAllowChange       : Boolean;

    procedure ExecuteColorBalance;
  public
    { Public declarations }
  end;

var
  frmColorBalance: TfrmColorBalance;

implementation

uses
{ Graphics32 }
  GR32,
{ GraphicsMagic Lib }
  gmTypes,
  gmIni,
  gmAlphaFuncs,
  gmLayerAndChannel,
  gmMath,               // EnsureValueInRange()
  gmCommands,
  gmHistoryManager,
{ GraphicsMagic Data Modules }
  HistoryDataModule,
{ GraphicsMagic Forma/Dialogs }
  MainForm,             // global variable ActiveChildForm defined in this unit
  HistoryForm;

{$R *.DFM}

const
  MEDIAN_VALUE : Integer = 100;
  MIN_VALUE    : Integer = -100;
  MAX_VALUE    : Integer = 100;

//-- Custom procedures and functions -------------------------------------------

procedure TfrmColorBalance.ExecuteColorBalance;
begin
  Screen.Cursor := crHourGlass;
  try
    if Assigned(FColorBalance) then
    begin
      with ActiveChildForm do
      begin
        if LayerPanelList.SelectedLayerPanel.LayerFeature in [
             lfBackground, lfTransparent] then
        begin
          FColorBalance.Execute(frmMain.FAfterProc);
        end;

        if chckbxPreview.Checked then
        begin
          if LayerPanelList.SelectedLayerPanel.LayerFeature in [
               lfBackground, lfTransparent] then
          begin
            if Assigned(Selection) then
            begin
              Selection.CutOriginal.Assign(frmMain.FAfterProc);
              ShowProcessedSelection;
            end
            else
            begin
              LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Assign(frmMain.FAfterProc);
              LayerPanelList.SelectedLayerPanel.Update;
            end;
          end
          else
          if LayerPanelList.SelectedLayerPanel.LayerFeature = lfColorBalance then
          begin
            LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
          end;
        end;
      end;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmColorBalance.FormShow(Sender: TObject);
var
  LColorBalanceLayerPanel: TgmColorBalanceLayerPanel;
  LTempBmp               : TBitmap32;
begin
  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in
       [lfBackground, lfTransparent] then
  begin
    chckbxPreview.Checked := Boolean(StrToInt(ReadInfoFromIniFile(SECTION_COLOR_BALANCE_DIALOG, IDENT_COLOR_BALANCE_PREVIEW, '1')));
    FPreserveLuminosity   := Boolean(StrToInt(ReadInfoFromIniFile(SECTION_COLOR_BALANCE_DIALOG, IDENT_COLOR_BALANCE_PRESERVE_LUMINOSITY, '1')));
    
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

    if FNormalColorBalance <> nil then
    begin
      FreeAndNil(FNormalColorBalance);
    end;

    // Create Color Balance for normal layer.
    FNormalColorBalance              := TgmColorBalance.Create(frmMain.FBeforeProc);
    FColorBalance                    := FNormalColorBalance;  // Points to the Color Balance which for normal layer.
    FColorBalance.TransferMode       := FTransferMode;
    FColorBalance.PreserveLuminosity := FPreserveLuminosity;

    ggbrCyanToRed.Position           := MEDIAN_VALUE;
    ggbrMagentaToGreen.Position      := MEDIAN_VALUE;
    ggbrYellowToBlue.Position        := MEDIAN_VALUE;
    chckbxPreserveLuminosity.Checked := FPreserveLuminosity;
  end
  else
  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfColorBalance then
  begin
    if Assigned(ActiveChildForm.Selection) then
    begin
      if Assigned(ActiveChildForm.SelectionHandleLayer) then
      begin
        ActiveChildForm.SelectionHandleLayer.Visible := False;
      end;
    end;

    LColorBalanceLayerPanel := TgmColorBalanceLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

    // Points to the Color Balance which for color balance layer.
    if Assigned(LColorBalanceLayerPanel.ColorBalance) then
    begin
      FColorBalance := LColorBalanceLayerPanel.ColorBalance;
    end;

    ggbrCyanToRed.Position           := MEDIAN_VALUE + FColorBalance.CyanRed;
    ggbrMagentaToGreen.Position      := MEDIAN_VALUE + FColorBalance.MagentaGreen;
    ggbrYellowToBlue.Position        := MEDIAN_VALUE + FColorBalance.YellowBlue;
    chckbxPreserveLuminosity.Checked := FColorBalance.PreserveLuminosity;
    chckbxPreview.Checked            := LColorBalanceLayerPanel.IsPreview;

    rdbtnShadows.Checked    := (LColorBalanceLayerPanel.ColorBalance.TransferMode = tmShadows);
    rdbtnMidtones.Checked   := (LColorBalanceLayerPanel.ColorBalance.TransferMode = tmMidtones);
    rdbtnHighlights.Checked := (LColorBalanceLayerPanel.ColorBalance.TransferMode = tmHighlights);
  end;
  
  ActiveControl := btbtnOK;
end;

procedure TfrmColorBalance.FormCreate(Sender: TObject);
begin
  FBarIsChanging      := False;
  FEditIsChanging     := False;
  FAllowChange        := True;
  FTransferMode       := tmMidtones;
  FPreserveLuminosity := True;
  FNormalColorBalance := nil;
  FColorBalance       := nil;
end;

procedure TfrmColorBalance.AdjustColorBalance(Sender: TObject);
var
  ChangedAmount: Integer;
begin
  FBarIsChanging := True;
  try
    if Sender = ggbrCyanToRed then
    begin
      ChangedAmount := ggbrCyanToRed.Position - MEDIAN_VALUE;

      if FEditIsChanging then
      begin
        edtCyanToRed.Text := IntToStr(ChangedAmount);
      end
      else
      begin
        if ChangedAmount > 0 then
        begin
          edtCyanToRed.Text := '+' + IntToStr(ChangedAmount);
        end
        else
        begin
          edtCyanToRed.Text := IntToStr(ChangedAmount);
        end;
      end;

      if Assigned(FColorBalance) then
      begin
        FColorBalance.CyanRed := ChangedAmount;
      end;
    end
    else
    if Sender = ggbrMagentaToGreen then
    begin
      ChangedAmount := ggbrMagentaToGreen.Position - MEDIAN_VALUE;

      if FEditIsChanging then
      begin
        edtMagentaToGreen.Text := IntToStr(ChangedAmount);
      end
      else
      begin
        if ChangedAmount > 0 then
        begin
          edtMagentaToGreen.Text := '+' + IntToStr(ChangedAmount);
        end
        else
        begin
          edtMagentaToGreen.Text := IntToStr(ChangedAmount);
        end;
      end;

      if Assigned(FColorBalance) then
      begin
        FColorBalance.MagentaGreen := ChangedAmount;
      end;
    end
    else
    if Sender = ggbrYellowToBlue then
    begin
      ChangedAmount := ggbrYellowToBlue.Position - MEDIAN_VALUE;

      if FEditIsChanging then
      begin
        edtYellowToBlue.Text := IntToStr(ChangedAmount);
      end
      else
      begin
        if ChangedAmount > 0 then
        begin
          edtYellowToBlue.Text := '+' + IntToStr(ChangedAmount);
        end
        else
        begin
          edtYellowToBlue.Text := IntToStr(ChangedAmount);
        end;
      end;

      if Assigned(FColorBalance) then
      begin
        FColorBalance.YellowBlue := ChangedAmount;
      end;
    end;
  finally
    FBarIsChanging := False;
  end;
end; 

procedure TfrmColorBalance.chckbxPreviewClick(Sender: TObject);
begin
  ExecuteColorBalance;
end;

procedure TfrmColorBalance.edtCyanToRedChange(Sender: TObject);
var
  ChangedValue: Integer;
begin
  if not FBarIsChanging then
  begin
    FEditIsChanging := True;
    try

      try
        ChangedValue := StrToInt(edtCyanToRed.Text);
        EnsureValueInRange(ChangedValue, MIN_VALUE, MAX_VALUE);
        ggbrCyanToRed.Position := MEDIAN_VALUE + ChangedValue;

        if FAllowChange then
        begin
          ExecuteColorBalance;
        end;
      except
        if Assigned(FColorBalance) then
        begin
          edtCyanToRed.Text := IntToStr(FColorBalance.CyanRed);
        end;
      end;

    finally
      FEditIsChanging := False;
    end;
  end;
end; 

procedure TfrmColorBalance.edtMagentaToGreenChange(Sender: TObject);
var
  ChangedValue: Integer;
begin
  if not FBarIsChanging then
  begin
    FEditIsChanging := True;
    try

      try
        ChangedValue := StrToInt(edtMagentaToGreen.Text);
        EnsureValueInRange(ChangedValue, MIN_VALUE, MAX_VALUE);
        ggbrMagentaToGreen.Position := MEDIAN_VALUE + ChangedValue;

        if FAllowChange then
        begin
          ExecuteColorBalance;
        end;
      except
        if Assigned(FColorBalance) then
        begin
          edtMagentaToGreen.Text := IntToStr(FColorBalance.MagentaGreen);
        end;
      end;

    finally
      FEditIsChanging := False;
    end;
  end;
end; 

procedure TfrmColorBalance.edtYellowToBlueChange(Sender: TObject);
var
  ChangedValue: Integer;
begin
  if not FBarIsChanging then
  begin
    FEditIsChanging := True;
    try

      try
        ChangedValue := StrToInt(edtYellowToBlue.Text);
        EnsureValueInRange(ChangedValue, MIN_VALUE, MAX_VALUE);
        ggbrYellowToBlue.Position := MEDIAN_VALUE + ChangedValue;

        if FAllowChange then
        begin
          ExecuteColorBalance;
        end;
      except
        if Assigned(FColorBalance) then
        begin
          edtYellowToBlue.Text := IntToStr(FColorBalance.YellowBlue);
        end;
      end;

    finally
      FEditIsChanging := False;
    end;
  end;
end; 

procedure TfrmColorBalance.ChangeTransferMode(Sender: TObject);
begin
  if Sender = rdbtnShadows then
  begin
    FTransferMode := tmShadows;
  end
  else if Sender = rdbtnMidtones then
  begin
    FTransferMode := tmMidtones;
  end
  else if Sender = rdbtnHighlights then
  begin
    FTransferMode := tmHighlights;
  end;

  if Assigned(FColorBalance) then
  begin
    FColorBalance.TransferMode  := FTransferMode;
    ggbrCyanToRed.Position      := FColorBalance.CyanRed      + MEDIAN_VALUE;
    ggbrMagentaToGreen.Position := FColorBalance.MagentaGreen + MEDIAN_VALUE;
    ggbrYellowToBlue.Position   := FColorBalance.YellowBlue   + MEDIAN_VALUE;
  end;
end; 

procedure TfrmColorBalance.chckbxPreserveLuminosityClick(Sender: TObject);
begin
  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
       lfBackground, lfTransparent] then
  begin
    FPreserveLuminosity := chckbxPreserveLuminosity.Checked;

    if Assigned(FColorBalance) then
    begin
      FColorBalance.PreserveLuminosity := FPreserveLuminosity;
    end;
  end
  else
  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfColorBalance then
  begin
    if Assigned(FColorBalance) then
    begin
      FColorBalance.PreserveLuminosity := chckbxPreserveLuminosity.Checked;
    end;
  end;
  
  ExecuteColorBalance;
end; 

procedure TfrmColorBalance.btnResetClick(Sender: TObject);
begin
  if Assigned(FColorBalance) then
  begin
    FColorBalance.Reset;
    ExecuteColorBalance;
  end;

  ggbrCyanToRed.Position      := MEDIAN_VALUE;
  ggbrMagentaToGreen.Position := MEDIAN_VALUE;
  ggbrYellowToBlue.Position   := MEDIAN_VALUE;
end; 

procedure TfrmColorBalance.FormDestroy(Sender: TObject);
begin
  if FNormalColorBalance <> nil then
  begin
    FNormalColorBalance.Free;
  end;
end; 

procedure TfrmColorBalance.btbtnOKClick(Sender: TObject);
var
  LCmdAim                : TCommandAim;
  LHistoryStatePanel     : TgmHistoryStatePanel;
  LColorBalanceLayerPanel: TgmColorBalanceLayerPanel;
begin
  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
       lfBackground, lfTransparent] then
  begin
    // the processed result is stored in frmMain.FAfterProc
    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsMaskLinked then
    begin
      if (ActiveChildForm.ChannelManager.CurrentChannelType in [
            wctRGB, wctRed, wctGreen, wctBlue]) then
      begin
        ReplaceAlphaChannelWithMask(frmMain.FAfterProc,
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
      end;
    end;

    LCmdAim := ActiveChildForm.GetCommandAimByCurrentChannel;

    LHistoryStatePanel := TgmImageManipulatingStatePanel.Create(
      frmHistory.scrlbxHistory,
      dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
      LCmdAim, 'Color Balance',
      frmMain.FBeforeProc,
      frmMain.FAfterProc,
      ActiveChildForm.Selection);

    ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);

    WriteInfoToIniFile(SECTION_COLOR_BALANCE_DIALOG, IDENT_COLOR_BALANCE_PREVIEW, IntToStr(Integer(chckbxPreview.Checked)));
    WriteInfoToIniFile(SECTION_COLOR_BALANCE_DIALOG, IDENT_COLOR_BALANCE_PRESERVE_LUMINOSITY, IntToStr(Integer(FPreserveLuminosity)));
  end
  else
  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfColorBalance then
  begin
    LColorBalanceLayerPanel := TgmColorBalanceLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);
    LColorBalanceLayerPanel.IsPreview := chckbxPreview.Checked;
  end;
end; 

procedure TfrmColorBalance.ColorBalanceBarMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ExecuteColorBalance;
  FAllowChange := True;
end;

procedure TfrmColorBalance.ColorBalanceBarMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FAllowChange := False;
end; 

end.
