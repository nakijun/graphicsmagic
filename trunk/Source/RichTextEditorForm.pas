{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

unit RichTextEditorForm;

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
  Dialogs, StdCtrls, ComCtrls,
{ Graphics32 Lib }
  GR32;

type
  TfrmRichTextEditor = class(TForm)
    rchedtRichTextEditor: TRichEdit;
    stsbrTextInfo: TStatusBar;
    procedure rchedtRichTextEditorChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure rchedtRichTextEditorMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormActivate(Sender: TObject);
  private
    FCanChange: Boolean;
  public
    property CanChange: Boolean read FCanChange write FCanChange;
  end;

var
  frmRichTextEditor: TfrmRichTextEditor;

implementation

uses
{ Standard }
  Menus,
{ GraphicsMagic Lib }
  gmLayerAndChannel,
  gmAlphaFuncs,
  gmGUIFuncs,           // DrawRTFToCanvas()
{ GraphicsMagic Forms/Dialogs }
  MainForm;


{$R *.dfm}

procedure TfrmRichTextEditor.rchedtRichTextEditorChange(Sender: TObject);
var
  LTextLayerPanel : TgmRichTextLayerPanel;
  LRect           : TRect;
begin
  if FCanChange then
  begin
    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
    begin
      LTextLayerPanel := TgmRichTextLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);
      LRect           := LTextLayerPanel.BorderRect;

      DrawRichTextOnBitmap(
        ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
        LRect, rchedtRichTextEditor);

      if ActiveChildForm.LayerPanelList.SelectedLayerPanel.IsHasMask then
      begin
        GetAlphaChannelBitmap(
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap,
          ActiveChildForm.LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
      end;

      ActiveChildForm.LayerPanelList.SelectedLayerPanel.Update;

      if not LTextLayerPanel.IsTextChanged then
      begin
        LTextLayerPanel.IsTextChanged := True;
      end;
    end;
  end;
end; 

procedure TfrmRichTextEditor.FormCreate(Sender: TObject);
begin
  FCanChange := False;
end;

procedure TfrmRichTextEditor.FormShow(Sender: TObject);
var
  LRichTextLayerPanel: TgmRichTextLayerPanel;
begin
  FCanChange := True;
  rchedtRichTextEditor.SetFocus;
  
  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
  begin
    LRichTextLayerPanel := TgmRichTextLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);
    LRichTextLayerPanel.IsEditState := True; // change to edit state when open the text editor

    if LRichTextLayerPanel.TextFileName = '' then
    begin
      stsbrTextInfo.Panels[0].Text := 'Untitled';
    end
    else
    begin
      stsbrTextInfo.Panels[0].Text := 'File Name: ' + ExtractFileName(LRichTextLayerPanel.TextFileName);
    end;
  end;

  // disable channel manager and path panel manager
  ActiveChildForm.ChannelManager.IsEnabled := False;
  ActiveChildForm.PathPanelList.IsEnabled  := False;
end;

procedure TfrmRichTextEditor.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  LRichTextLayerPanel: TgmRichTextLayerPanel;
begin
  FCanChange := False;
  
  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfRichText then
  begin
    LRichTextLayerPanel := TgmRichTextLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);
    LRichTextLayerPanel.IsEditState := False; // change to non edit state when close the text editor
  end;

  // Restore the Short Cut key for Undo/Redo menu.
  frmMain.mnitmUndoRedo.ShortCut := ShortCut( Word('Z'), [ssCtrl]);

  // enable channel manager and path panel manager
  ActiveChildForm.ChannelManager.IsEnabled := True;
  ActiveChildForm.PathPanelList.IsEnabled  := True;
end; 

procedure TfrmRichTextEditor.rchedtRichTextEditorMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  with frmMain, rchedtRichTextEditor do
  begin
    ChangeIndexByFontName(SelAttributes.Name);
    ChangeIndexByFontSize(SelAttributes.Size);

    shpFontColor.Brush.Color   := SelAttributes.Color;
    tlbtnBold.Down             := (fsBold in SelAttributes.Style);
    tlbtnItalic.Down           := (fsItalic in SelAttributes.Style);
    tlbtnUnderline.Down        := (fsUnderline in SelAttributes.Style);
    spdbtnLeftAlignText.Down   := (Paragraph.Alignment = taLeftJustify);
    spdbtnCenterText.Down      := (Paragraph.Alignment = taCenter);
    spdbtnRightAlignText.Down  := (Paragraph.Alignment = taRightJustify);
  end;
end;

procedure TfrmRichTextEditor.FormActivate(Sender: TObject);
begin
  frmMain.mnitmUndoRedo.ShortCut := 0;  // Clear the short cut key for Undo/Redo menu.
end; 

end.
