{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

unit GradientMapDlg;

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
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls,
{ Graphics32 Lib }
  GR32_Image,
{ GraphicsMagic Lib }
  gmGradientMap;

type
  TfrmGradientMap = class(TForm)
    grpbxGradientMapHolder: TGroupBox;
    pnlGradientMapHolder: TPanel;
    imgSelectedGradient: TImage32;
    spdbtnOpenGradientPicker: TSpeedButton;
    grpbxGradientOptions: TGroupBox;
    chckbxReverse: TCheckBox;
    btbtnOK: TBitBtn;
    btbtnCancel: TBitBtn;
    chckbxPreview: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure spdbtnOpenGradientPickerClick(Sender: TObject);
    procedure spdbtnOpenGradientPickerMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure chckbxReverseClick(Sender: TObject);
    procedure chckbxPreviewClick(Sender: TObject);
    procedure imgSelectedGradientClick(Sender: TObject);
    procedure btbtnOKClick(Sender: TObject);
  private
    FGradientMap      : TgmGradientMap;  // for Gradient Map Command 
    FButtonX, FButtonY: Integer;

    procedure ShowMapLayerGradients;
  public
    procedure ExecuteGradientMap;
  end;

var
  frmGradientMap: TfrmGradientMap;

implementation

uses
{ Graphics32 }
  GR32,
{ GraphicsMagic Package Lib }
  gmGradient,
{ GraphicsMagic Lib }
  gmTypes,
  gmLayerAndChannel,
  gmAlphaFuncs,
  gmCommands,
  gmIni,
  gmHistoryManager,
{ GraphicsMagic Data Modules }
  HistoryDataModule,
{ GraphicsMagic Forms/Dialogs }
  MainForm,
  HistoryForm,
  GradientPickerPopFrm,
  GradientEditorDlg;

{$R *.dfm}

//-- Custom Methods ------------------------------------------------------------

procedure TfrmGradientMap.ShowMapLayerGradients;
var
  LGradientMapLayerPanel: TgmGradientMapLayerPanel;
  LTempGradient         : TgmGradientItem;
begin
  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfGradientMap then
  begin
    // show gradients in this form
    LTempGradient := TgmGradientItem.Create(nil);
    try
      LGradientMapLayerPanel := TgmGradientMapLayerPanel(
        ActiveChildForm.LayerPanelList.SelectedLayerPanel);
      
      LTempGradient.Assign(LGradientMapLayerPanel.Gradient);
      LTempGradient.GradientLength := imgSelectedGradient.Bitmap.Width;
      LTempGradient.RefreshColorArray;

      LTempGradient.DrawColorGradients(imgSelectedGradient.Bitmap,
                                       chckbxReverse.Checked);

      imgSelectedGradient.Bitmap.Changed;
    finally
      LTempGradient.Free;
    end;
  end;
end;

procedure TfrmGradientMap.ExecuteGradientMap;
var
  LGradient: TgmGradientItem;
begin
  with ActiveChildForm do
  begin
    if LayerPanelList.SelectedLayerPanel.LayerFeature in [
         lfBackground, lfTransparent] then
    begin
      if Assigned(FGradientMap) then
      begin
        LGradient := frmGradientPicker.glMapCommandGradients.Items[frmGradientPicker.MapCommandGradientListState.SelectedIndex];
        FGradientMap.Draw(frmMain.FAfterProc, LGradient, chckbxReverse.Checked);
      end;
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
      if LayerPanelList.SelectedLayerPanel.LayerFeature = lfGradientMap then
      begin
        LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmGradientMap.FormCreate(Sender: TObject);
begin
  imgSelectedGradient.SetupBitmap;
  FGradientMap := nil;
end;

procedure TfrmGradientMap.FormDestroy(Sender: TObject);
begin
  if Assigned(FGradientMap) then
  begin
    FGradientMap.Free;
  end;
end; 

procedure TfrmGradientMap.FormShow(Sender: TObject);
var
  LGradientMapLayerPanel: TgmGradientMapLayerPanel;
  LTempBmp              : TBitmap32;
begin
  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
       lfBackground, lfTransparent] then
  begin
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

    if Assigned(FGradientMap) then
    begin
      FreeAndNil(FGradientMap);
    end;

    // Create Gradient Map for normal layer, mask...
    FGradientMap := TgmGradientMap.Create(frmMain.FBeforeProc);

    chckbxReverse.Checked := Boolean(StrToInt(ReadInfoFromIniFile(SECTION_GRADIENT_MAP_DIALOG, IDENT_GRADIENT_MAP_DIALOG_REVERSE, '1')));
    chckbxPreview.Checked := Boolean(StrToInt(ReadInfoFromIniFile(SECTION_GRADIENT_MAP_DIALOG, IDENT_GRADIENT_MAP_DIALOG_PREVIEW, '1')));

    frmGradientPicker.ShowMapCommandSelectedGradient;
  end
  else
  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfGradientMap then
  begin
    if Assigned(ActiveChildForm.Selection) then
    begin
      if Assigned(ActiveChildForm.SelectionHandleLayer) then
      begin
        ActiveChildForm.SelectionHandleLayer.Visible := False;
      end;
    end;

    LGradientMapLayerPanel := TgmGradientMapLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);
    chckbxReverse.Checked  := LGradientMapLayerPanel.IsReversed;
    chckbxPreview.Checked  := LGradientMapLayerPanel.IsPreview;

    // show gradients in this form
    ShowMapLayerGradients;
  end;

  ExecuteGradientMap;
  ActiveControl := btbtnOK;
end; 

procedure TfrmGradientMap.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if Assigned(FGradientMap) then
  begin
    FreeAndNil(FGradientMap);
  end;
end; 

procedure TfrmGradientMap.spdbtnOpenGradientPickerClick(Sender: TObject);
var
  p: TPoint;
begin
  GetCursorPos(p);
  frmGradientPicker.Left := p.X - frmGradientPicker.Width - FButtonX;
  frmGradientPicker.Top  := p.Y + (spdbtnOpenGradientPicker.Height - FButtonY);

  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
       lfBackground, lfTransparent] then
  begin
    frmGradientPicker.GradientUser := guGradientMapCommand;
  end
  else
  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfGradientMap then
  begin
    frmGradientPicker.GradientUser := guGradientMapLayer;
  end;

  frmGradientPicker.Show;
end; 

procedure TfrmGradientMap.spdbtnOpenGradientPickerMouseDown(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  FButtonX := X;
  FButtonY := Y;
end; 

procedure TfrmGradientMap.chckbxReverseClick(Sender: TObject);
var
  LGradientMapLayerPanel: TgmGradientMapLayerPanel;
begin
  with ActiveChildForm do
  begin
    if LayerPanelList.SelectedLayerPanel.LayerFeature in [
         lfBackground, lfTransparent] then
    begin
      frmGradientPicker.ShowMapCommandSelectedGradient;
    end
    else
    if LayerPanelList.SelectedLayerPanel.LayerFeature = lfGradientMap then
    begin
      LGradientMapLayerPanel := TgmGradientMapLayerPanel(LayerPanelList.SelectedLayerPanel);
      LGradientMapLayerPanel.IsReversed := chckbxReverse.Checked;

      ShowMapLayerGradients;
    end;

    ExecuteGradientMap;
  end;
end; 

procedure TfrmGradientMap.chckbxPreviewClick(Sender: TObject);
begin
  ExecuteGradientMap;
end;

procedure TfrmGradientMap.imgSelectedGradientClick(Sender: TObject);
begin
  frmGradientEditor := TfrmGradientEditor.Create(nil);
  try
    case ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature of
      lfBackground,
      lfTransparent:
        begin
          frmGradientEditor.GradientUser := guGradientMapCommand;
        end;

      lfGradientMap:
        begin
          frmGradientEditor.GradientUser := guGradientMapLayer;
        end;
    end;

    frmGradientEditor.ShowModal;
  finally
    FreeAndNil(frmGradientEditor);
  end;
end;

procedure TfrmGradientMap.btbtnOKClick(Sender: TObject);
var
  LGradientMapLayerPanel: TgmGradientMapLayerPanel;
  LCmdAim               : TCommandAim;
  LHistoryStatePanel    : TgmHistoryStatePanel;
begin
  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
       lfBackground, lfTransparent] then
  begin
    // the processed result is stored in frmMain.FAfterProc
    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsMaskLinked then
    begin
      if ActiveChildForm.ChannelManager.CurrentChannelType in [
           wctRGB, wctRed, wctGreen, wctBlue] then
      begin
        ReplaceAlphaChannelWithMask(frmMain.FAfterProc,
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
      end;
    end;

    LCmdAim := ActiveChildForm.GetCommandAimByCurrentChannel;

    LHistoryStatePanel := TgmImageManipulatingStatePanel.Create(
      frmHistory.scrlbxHistory,
      dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
      LCmdAim,
      'Gradient Map',
      frmMain.FBeforeProc,
      frmMain.FAfterProc,
      ActiveChildForm.Selection);

    ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);

    WriteInfoToIniFile(SECTION_GRADIENT_MAP_DIALOG, IDENT_GRADIENT_MAP_DIALOG_Reverse, IntToStr(Integer(chckbxReverse.Checked)));
    WriteInfoToIniFile(SECTION_GRADIENT_MAP_DIALOG, IDENT_GRADIENT_MAP_DIALOG_PREVIEW, IntToStr(Integer(chckbxPreview.Checked)));
  end
  else
  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfGradientMap then
  begin
    LGradientMapLayerPanel := TgmGradientMapLayerPanel(
      ActiveChildForm.LayerPanelList.SelectedLayerPanel);
      
    LGradientMapLayerPanel.IsReversed := chckbxReverse.Checked;
    LGradientMapLayerPanel.IsPreview  := chckbxPreview.Checked;
  end;
end; 

end.
