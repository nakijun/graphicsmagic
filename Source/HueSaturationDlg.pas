{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

unit HueSaturationDlg;

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
{ Graphics32 Lib }
  GR32, GR32_RangeBars,
{ GraphicsMagic Lib }
  gmTypes;

type
  TfrmHueSaturation = class(TForm)
    btbtnOK: TBitBtn;
    btbtnCancel: TBitBtn;
    chckbxPreview: TCheckBox;
    grpbxHueSaturation: TGroupBox;
    lblHue: TLabel;
    lblSaturation: TLabel;
    lblLightnessOrValue: TLabel;
    rdbtnHLS: TRadioButton;
    rdbtnHSV: TRadioButton;
    edtLightnessOrValue: TEdit;
    edtSaturation: TEdit;
    edtHue: TEdit;
    ggbrHue: TGaugeBar;
    ggbrSaturation: TGaugeBar;
    ggbrLightnessOrValue: TGaugeBar;
    procedure AdjustHue(Sender: TObject);
    procedure AdjustSaturation(Sender: TObject);
    procedure AdjustLightnessOrValue(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure rdbtnHLSClick(Sender: TObject);
    procedure rdbtnHSVClick(Sender: TObject);
    procedure edtHueChange(Sender: TObject);
    procedure edtSaturationChange(Sender: TObject);
    procedure edtLightnessOrValueChange(Sender: TObject);
    procedure chckbxPreviewClick(Sender: TObject);
    procedure btbtnOKClick(Sender: TObject);
  private
    FChangedH      : Integer;
    FChangedS      : Integer;
    FChangedLV     : Integer;
    FAdjustMode    : TgmHueSaturationAdjustMode;
    FFormShowing   : Boolean;
    FBarIsChanging : Boolean;
    FEditIsChanging: Boolean;

    procedure ExecuteHLS;
    procedure ExecuteHSV;
  public
    { Public declarations }
  end;

var
  frmHueSaturation: TfrmHueSaturation;

implementation

uses
{ GraphicsMagic Lib }
  gmIni,
  gmLayerAndChannel,
  gmMath,               // EnsureValueInRange()
  gmImageProcessFuncs,
  gmCommands,
  gmHistoryManager,
  gmAlphaFuncs,
{ GraphicsMagic Data Modules }
  HistoryDataModule,
{ GraphicsMagic Forms/Dialogs }
  MainForm,             // frmMain
  HistoryForm;

{$R *.DFM}

const
  MEDIAN_S_L_V   : Integer = 128;
  MEDIAN_H       : Integer = 180;
  MIN_RANGE_H    : Integer = -180;
  MAX_RANGE_H    : Integer = 180;
  MIN_RANGE_S_L_V: Integer = -128;
  MAX_RANGE_S_L_V: Integer = 128;

//-- Custom procedures and functions -------------------------------------------

procedure TfrmHueSaturation.ExecuteHLS;
begin
  with ActiveChildForm do
  begin
    if LayerPanelList.SelectedLayerPanel.LayerFeature in [
         lfBackground, lfTransparent] then
    begin
      AdjustImageHLS(frmMain.FBeforeProc, frmMain.FAfterProc,
                     FChangedH, FChangedLV, FChangedS);
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
      if LayerPanelList.SelectedLayerPanel.LayerFeature = lfHLSOrHSV then
      begin
        LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
      end;
    end;
  end;
end; 

procedure TfrmHueSaturation.ExecuteHSV;
begin
  with ActiveChildForm do
  begin
    if LayerPanelList.SelectedLayerPanel.LayerFeature in [
         lfBackground, lfTransparent] then
    begin
      AdjustImageHSV(frmMain.FBeforeProc, frmMain.FAfterProc,
                     FChangedH, FChangedS, FChangedLV);
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
      if LayerPanelList.SelectedLayerPanel.LayerFeature = lfHLSOrHSV then
      begin
        LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
      end;
    end;
  end;
end; 

//------------------------------------------------------------------------------

procedure TfrmHueSaturation.AdjustHue(Sender: TObject);
var
  LChangedH               : Integer;
  LHueSaturationLayerPanel: TgmHueSaturationLayerPanel;
begin
  FBarIsChanging := True;
  try
    LChangedH := ggbrHue.Position - MEDIAN_H;

    if FEditIsChanging then
    begin
      edtHue.Text := IntToStr(LChangedH);
    end
    else
    begin
      if LChangedH > 0 then
      begin
        edtHue.Text := '+' + IntToStr(LChangedH);
      end
      else
      begin
        edtHue.Text := IntToStr(LChangedH);
      end;
    end;

    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
         lfBackground, lfTransparent] then
    begin
      if FChangedH <> LChangedH then
      begin
        FChangedH := LChangedH;

        case FAdjustMode of
          hsamHSL:
            begin
              ExecuteHLS;
            end;

          hsamHSV:
            begin
              ExecuteHSV;
            end;
        end;
      end;
    end
    else
    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfHLSOrHSV then
    begin
      LHueSaturationLayerPanel := TgmHueSaturationLayerPanel(
        ActiveChildForm.LayerPanelList.SelectedLayerPanel);

      if LHueSaturationLayerPanel.ChangedH <> LChangedH then
      begin
        LHueSaturationLayerPanel.ChangedH := LChangedH;

        case FAdjustMode of
          hsamHSL:
            begin
              ExecuteHLS;
            end;

          hsamHSV:
            begin
              ExecuteHSV;
            end;
        end;
      end;
    end;
    
  finally
    FBarIsChanging := False;
  end;
end;

procedure TfrmHueSaturation.AdjustSaturation(Sender: TObject);
var
  LChangedS               : Integer;
  LHueSaturationLayerPanel: TgmHueSaturationLayerPanel;
begin
  FBarIsChanging := True;
  try
    LChangedS := ggbrSaturation.Position - MEDIAN_S_L_V;

    if FEditIsChanging then
    begin
      edtSaturation.Text := IntToStr(LChangedS);
    end
    else
    begin
      if LChangedS > 0 then
      begin
        edtSaturation.Text := '+' + IntToStr(LChangedS);
      end
      else
      begin
        edtSaturation.Text := IntToStr(LChangedS);
      end;
    end;

    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
         lfBackground, lfTransparent] then
    begin
      if FChangedS <> LChangedS then
      begin
        FChangedS := LChangedS;

        case FAdjustMode of
          hsamHSL:
            begin
              ExecuteHLS;
            end;

          hsamHSV:
            begin
              ExecuteHSV;
            end;
        end;
      end;
    end
    else
    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfHLSOrHSV then
    begin
      LHueSaturationLayerPanel := TgmHueSaturationLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

      if LHueSaturationLayerPanel.ChangedS <> LChangedS then
      begin
        LHueSaturationLayerPanel.ChangedS := LChangedS;
        
        case FAdjustMode of
          hsamHSL:
            begin
              ExecuteHLS;
            end;

          hsamHSV:
            begin
              ExecuteHSV;
            end;
        end;
      end;
    end;
  finally
    FBarIsChanging := False;
  end;
end;

procedure TfrmHueSaturation.AdjustLightnessOrValue(Sender: TObject);
var
  LChangedLV              : Integer;
  LHueSaturationLayerPanel: TgmHueSaturationLayerPanel;
begin
  FBarIsChanging := True;
  try
    LChangedLV := ggbrLightnessOrValue.Position - MEDIAN_S_L_V;

    if FEditIsChanging then
    begin
      edtLightnessOrValue.Text := IntToStr(LChangedLV);
    end
    else
    begin
      if LChangedLV > 0 then
      begin
        edtLightnessOrValue.Text := '+' + IntToStr(LChangedLV);
      end
      else
      begin
        edtLightnessOrValue.Text := IntToStr(LChangedLV);
      end;
    end;

    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
         lfBackground, lfTransparent] then
    begin
      if FChangedLV <> LChangedLV then
      begin
        FChangedLV := LChangedLV;

        case FAdjustMode of
          hsamHSL:
           begin
             ExecuteHLS;
           end;

          hsamHSV:
            begin
              ExecuteHSV;
            end;
        end;
      end;
    end
    else
    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfHLSOrHSV then
    begin
      LHueSaturationLayerPanel := TgmHueSaturationLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

      if LHueSaturationLayerPanel.ChangedLOrV <> LChangedLV then
      begin
        LHueSaturationLayerPanel.ChangedLOrV := LChangedLV;
        
        case FAdjustMode of
          hsamHSL:
            begin
              ExecuteHLS;
            end;
            
          hsamHSV:
            begin
              ExecuteHSV;
            end;
        end;
      end;
    end;
  finally
    FBarIsChanging := False;
  end;
end;

procedure TfrmHueSaturation.FormCreate(Sender: TObject);
begin
  FChangedH       := 0;
  FChangedS       := 0;
  FChangedLV      := 0;
  FFormShowing    := False;
  FBarIsChanging  := False;
  FEditIsChanging := False;

  FAdjustMode := TgmHueSaturationAdjustMode(
    StrToInt(ReadInfoFromIniFile(SECTION_HUE_SATURATION_DIALOG, IDENT_HUE_SATURATION_MODE, '0')));
end; 

procedure TfrmHueSaturation.FormShow(Sender: TObject);
var
  LHueSaturationLayerPanel: TgmHueSaturationLayerPanel;
  LTempBmp                : TBitmap32;
begin
  FFormShowing := True;
  try
    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
         lfBackground, lfTransparent] then
    begin
      case FAdjustMode of
        hsamHSL:
          begin
            rdbtnHLS.Checked := True;
          end;
          
        hsamHSV:
          begin
            rdbtnHSV.Checked := True;
          end;
      end;

      chckbxPreview.Checked :=
        Boolean(StrToInt(ReadInfoFromIniFile(SECTION_HUE_SATURATION_DIALOG, IDENT_HUE_SATURATION_PREVIEW, '1')));

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

      case FAdjustMode of
        hsamHSL:
          begin
            rdbtnHLS.Checked := True;
          end;

        hsamHSV:
          begin
            rdbtnHSV.Checked := True;
          end;
      end;

      ggbrHue.Position              := MEDIAN_H;
      ggbrSaturation.Position       := MEDIAN_S_L_V;
      ggbrLightnessOrValue.Position := MEDIAN_S_L_V;
    end
    else
    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfHLSOrHSV then
    begin
      if Assigned(ActiveChildForm.Selection) then
      begin
        if Assigned(ActiveChildForm.SelectionHandleLayer) then
        begin
          ActiveChildForm.SelectionHandleLayer.Visible := False;
        end;
      end;

      LHueSaturationLayerPanel := TgmHueSaturationLayerPanel(
        ActiveChildForm.LayerPanelList.SelectedLayerPanel);

      case LHueSaturationLayerPanel.AdjustMode of
        hsamHSL:
          begin
            rdbtnHLS.Checked := True;
          end;
          
        hsamHSV:
          begin
            rdbtnHSV.Checked := True;
          end;
      end;

      ggbrHue.Position              := LHueSaturationLayerPanel.ChangedH    + MEDIAN_H;
      ggbrSaturation.Position       := LHueSaturationLayerPanel.ChangedS    + MEDIAN_S_L_V;
      ggbrLightnessOrValue.Position := LHueSaturationLayerPanel.ChangedLOrV + MEDIAN_S_L_V;
      chckbxPreview.Checked         := LHueSaturationLayerPanel.IsPreview;
    end;

    if rdbtnHLS.Checked then
    begin
      lblLightnessOrValue.Caption := 'Lightness:'
    end
    else if rdbtnHSV.Checked then
    begin
      lblLightnessOrValue.Caption := 'Value:';
    end;

    ActiveControl := btbtnOK;
  finally
    FFormShowing := False;
  end;
end;

procedure TfrmHueSaturation.rdbtnHLSClick(Sender: TObject);
var
  LHueSaturationLayerPanel: TgmHueSaturationLayerPanel;
begin
  if not FFormShowing then
  begin
    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
         lfBackground, lfTransparent] then
    begin
      FAdjustMode := hsamHSL;
    end
    else
    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfHLSOrHSV then
    begin
      LHueSaturationLayerPanel := TgmHueSaturationLayerPanel(
        ActiveChildForm.LayerPanelList.SelectedLayerPanel);

      LHueSaturationLayerPanel.AdjustMode := hsamHSL;
    end;

    lblLightnessOrValue.Caption   := 'Lightness:';
    ggbrHue.Position              := MEDIAN_H;
    ggbrSaturation.Position       := MEDIAN_S_L_V;
    ggbrLightnessOrValue.Position := MEDIAN_S_L_V;
  end;
end;

procedure TfrmHueSaturation.rdbtnHSVClick(Sender: TObject);
var
  LHueSaturationLayerPanel: TgmHueSaturationLayerPanel;
begin
  if not FFormShowing then
  begin
    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
         lfBackground, lfTransparent] then
    begin
      FAdjustMode := hsamHSV;
    end
    else
    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfHLSOrHSV then
    begin
      LHueSaturationLayerPanel := TgmHueSaturationLayerPanel(
        ActiveChildForm.LayerPanelList.SelectedLayerPanel);
        
      LHueSaturationLayerPanel.AdjustMode := hsamHSV;
    end;

    lblLightnessOrValue.Caption   := 'Value:';
    ggbrHue.Position              := MEDIAN_H;
    ggbrSaturation.Position       := MEDIAN_S_L_V;
    ggbrLightnessOrValue.Position := MEDIAN_S_L_V;
  end;  
end;

procedure TfrmHueSaturation.edtHueChange(Sender: TObject);
var
  LChangedValue           : Integer;
  LHueSaturationLayerPanel: TgmHueSaturationLayerPanel;
begin
  if not FBarIsChanging then
  begin
    FEditIsChanging := True;
    try

      try
        LChangedValue := StrToInt(edtHue.Text);

        EnsureValueInRange(LChangedValue, MIN_RANGE_H, MAX_RANGE_H);

        ggbrHue.Position := MEDIAN_H + LChangedValue;
      except
        if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
             lfBackground, lfTransparent] then
        begin
          edtHue.Text := IntToStr(FChangedH);
        end
        else
        if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfHLSOrHSV then
        begin
          LHueSaturationLayerPanel := TgmHueSaturationLayerPanel(
            ActiveChildForm.LayerPanelList.SelectedLayerPanel);

          edtHue.Text := IntToStr(LHueSaturationLayerPanel.ChangedH);
        end;
      end;

    finally
      FEditIsChanging := False;
    end;
  end;
end;

procedure TfrmHueSaturation.edtSaturationChange(Sender: TObject);
var
  LChangedValue           : Integer;
  LHueSaturationLayerPanel: TgmHueSaturationLayerPanel;
begin
  if not FBarIsChanging then
  begin
    FEditIsChanging := True;
    try

      try
        LChangedValue := StrToInt(edtSaturation.Text);

        EnsureValueInRange(LChangedValue, MIN_RANGE_S_L_V, MAX_RANGE_S_L_V);

        ggbrSaturation.Position := MEDIAN_S_L_V + LChangedValue;
      except
        if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
             lfBackground, lfTransparent] then
        begin
          edtSaturation.Text := IntToStr(FChangedS);
        end
        else
        if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfHLSOrHSV then
        begin
          LHueSaturationLayerPanel := TgmHueSaturationLayerPanel(
            ActiveChildForm.LayerPanelList.SelectedLayerPanel);
            
          edtSaturation.Text := IntToStr(LHueSaturationLayerPanel.ChangedS);
        end;
      end;

    finally
      FEditIsChanging := False;
    end;
  end;
end;

procedure TfrmHueSaturation.edtLightnessOrValueChange(Sender: TObject);
var
  LChangedValue           : Integer;
  LHueSaturationLayerPanel: TgmHueSaturationLayerPanel;
begin
  if not FBarIsChanging then
  begin
    FEditIsChanging := True;
    try

      try
        LChangedValue := StrToInt(edtLightnessOrValue.Text);

        EnsureValueInRange(LChangedValue, MIN_RANGE_S_L_V, MAX_RANGE_S_L_V);

        ggbrLightnessOrValue.Position := MEDIAN_S_L_V + LChangedValue;
      except
        if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
             lfBackground, lfTransparent] then
        begin
          edtLightnessOrValue.Text := IntToStr(FChangedLV);
        end
        else
        if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfHLSOrHSV then
        begin
          LHueSaturationLayerPanel := TgmHueSaturationLayerPanel(
            ActiveChildForm.LayerPanelList.SelectedLayerPanel);
            
          edtLightnessOrValue.Text := IntToStr(LHueSaturationLayerPanel.ChangedLOrV);
        end;
      end;

    finally
      FEditIsChanging := False;
    end;
  end;
end;

procedure TfrmHueSaturation.chckbxPreviewClick(Sender: TObject);
begin
  case FAdjustMode of
    hsamHSL:
      begin
        ExecuteHLS;
      end;

    hsamHSV:
      begin
        ExecuteHSV;
      end;
  end;
end;

procedure TfrmHueSaturation.btbtnOKClick(Sender: TObject);
var
  LCmdAim                 : TCommandAim;
  LHistoryStatePanel      : TgmHistoryStatePanel;
  LHueSaturationLayerPanel: TgmHueSaturationLayerPanel;
begin
  with ActiveChildForm do
  begin
    if LayerPanelList.SelectedLayerPanel.LayerFeature in [
         lfBackground, lfTransparent] then
    begin
      // the processed result is stored in frmMain.FAfterProc
      if LayerPanelList.SelectedLayerPanel.IsMaskLinked then
      begin
        if ChannelManager.CurrentChannelType in [
             wctRGB, wctRed, wctGreen, wctBlue] then
        begin
          ReplaceAlphaChannelWithMask(frmMain.FAfterProc,
            LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
        end;
      end;

      LCmdAim := GetCommandAimByCurrentChannel;

      LHistoryStatePanel := TgmImageManipulatingStatePanel.Create(
        frmHistory.scrlbxHistory,
        dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
        LCmdAim,
        'Hue/Saturation',
        frmMain.FBeforeProc,
        frmMain.FAfterProc,
        Selection);

      HistoryManager.AddHistoryState(LHistoryStatePanel);

      WriteInfoToIniFile(SECTION_HUE_SATURATION_DIALOG, IDENT_HUE_SATURATION_MODE, IntToStr(Ord(FAdjustMode)));
      WriteInfoToIniFile(SECTION_HUE_SATURATION_DIALOG, IDENT_HUE_SATURATION_PREVIEW, IntToStr(Integer(chckbxPreview.Checked)));
    end
    else
    if LayerPanelList.SelectedLayerPanel.LayerFeature = lfHLSOrHSV then
    begin
      LHueSaturationLayerPanel := TgmHueSaturationLayerPanel(LayerPanelList.SelectedLayerPanel);
      LHueSaturationLayerPanel.IsPreview := chckbxPreview.Checked;
    end;
  end;
end; 

end.


