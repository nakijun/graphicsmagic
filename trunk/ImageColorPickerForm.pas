{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

unit ImageColorPickerForm;

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
  Dialogs,
{ Graphics32 }
  GR32_Image, GR32_Layers;

type
  TfrmImageColorPicker = class(TForm)
    imgvwPickArea: TImgView32;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure imgvwPickAreaMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure imgvwPickAreaMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer; Layer: TCustomLayer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmImageColorPicker: TfrmImageColorPicker;

implementation

uses
{ GraphicsMagic Lib }
  gmGUIFuncs,
  gmLayerAndChannel,
  gmLevels,
  gmLevelsTool,
{ GraphicsMagic Forms/Dialogs }
  MainForm,
  InfoForm,
  LevelsToolDlg;


{$R *.dfm}

procedure TfrmImageColorPicker.FormShow(Sender: TObject);
var
  LGimpLevelsLayerPanel: TgmLevelsLayerPanel;
begin
  if frmLevelsTool.FLevelsTool <> nil then
  begin
    if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfLevels then
    begin
      LGimpLevelsLayerPanel := TgmLevelsLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);
      imgvwPickArea.Bitmap.Assign(LGimpLevelsLayerPanel.FlattenedLayer);
    end
    else
    begin
      imgvwPickArea.Bitmap.Assign(frmLevelsTool.FLevelsTool.SourceBitmap);
    end;
  end;
end; 

procedure TfrmImageColorPicker.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if Assigned(frmLevelsTool.FLevelsTool) then
  begin
    frmLevelsTool.FLevelsTool.ActivePicker := lapNone;
  end;
  
  if frmLevelsTool.tlbtnBlackPicker.Down then
  begin
    frmLevelsTool.tlbtnBlackPicker.Down := False;
  end;
  
  if frmLevelsTool.tlbtnGrayPicker.Down then
  begin
    frmLevelsTool.tlbtnGrayPicker.Down := False;
  end;
  
  if frmLevelsTool.tlbtnWhitePicker.Down then
  begin
    frmLevelsTool.tlbtnWhitePicker.Down := False;
  end;
end; 

procedure TfrmImageColorPicker.imgvwPickAreaMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  LPoint: TPoint;
begin
  if frmLevelsTool.FLevelsTool <> nil then
  begin
    if frmLevelsTool.FLevelsTool.ActivePicker <> lapNone then
    begin
      LPoint := imgvwPickArea.ControlToBitmap( Point(X, Y) );

      if (LPoint.X >= 0) and
         (LPoint.Y >= 0) and
         (LPoint.X < imgvwPickArea.Bitmap.Width) and
         (LPoint.Y < imgvwPickArea.Bitmap.Height) then
      begin
        frmLevelsTool.FLevelsTool.ColorPicked(imgvwPickArea.Bitmap.PixelS[LPoint.X, LPoint.Y]);
        frmLevelsTool.LevelsUpdate(ALL);
        frmLevelsTool.ExecuteGimpLevels;
      end;
    end;
  end;
end; 

procedure TfrmImageColorPicker.imgvwPickAreaMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
var
  LPoint: TPoint;
  LColor: TColor;
begin
  LPoint := imgvwPickArea.ControlToBitmap( Point(X, Y) );
  
  frmInfo.lblCurrentX.Caption := 'X: ' + IntToStr(LPoint.X);
  frmInfo.lblCurrentY.Caption := 'Y: ' + IntToStr(LPoint.Y);

  if (LPoint.X >= 0) and
     (LPoint.Y >= 0) and
     (LPoint.X < imgvwPickArea.Bitmap.Width) and
     (LPoint.Y < imgvwPickArea.Bitmap.Height) then
  begin
    if frmLevelsTool.FLevelsTool <> nil then
    begin
      case frmLevelsTool.FLevelsTool.ActivePicker of
        lapNone : imgvwPickArea.Cursor := crNo;
        lapBlack: imgvwPickArea.Cursor := crBlackPicker;
        lapGray : imgvwPickArea.Cursor := crGrayPicker;
        lapWhite: imgvwPickArea.Cursor := crWhitePicker;
      end;
    end;
    
    LColor := imgvwPickArea.Bitmap.Canvas.Pixels[LPoint.X, LPoint.Y];
    
    frmMain.ShowColorRGBInfoOnInfoViewer(LColor);
    frmMain.ShowColorCMYKInfoOnInfoViewer(LColor);
  end
  else
  begin
    imgvwPickArea.Cursor := crNo;
  end;
end; 

end.
