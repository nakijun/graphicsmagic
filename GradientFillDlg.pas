{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

unit GradientFillDlg;

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
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Buttons, ExtCtrls,
{ Graphics32 }
  GR32, GR32_Image, GR32_Layers, GR32_RangeBars,
{ GraphicsMagic }
  gmLayerAndChannel;

type
  TfrmGradientFill = class(TForm)
    lblGradient: TLabel;
    pnlGradientHolder: TPanel;
    imgSelectedGradient: TImage32;
    spdbtnOpenGradientPicker: TSpeedButton;
    lblGradientStyle: TLabel;
    cmbbxGradientStyle: TComboBox;
    lblGradientAngle: TLabel;
    pnlGradientAngleHolder: TPanel;
    imgGradientAngle: TImage32;
    edtGradientAngle: TEdit;
    pnlDegreesHolder: TPanel;
    imgDegrees: TImage;
    lblGradientScale: TLabel;
    edtGradientScale: TEdit;
    lblScale: TLabel;
    grpbxTranslate: TGroupBox;
    lblTranslateX: TLabel;
    edtTranslateX: TEdit;
    lblTranslateY: TLabel;
    edtTranslateY: TEdit;
    btbtnOK: TBitBtn;
    btbtnCancel: TBitBtn;
    chckbxReverse: TCheckBox;
    ggbrGradientScale: TGaugeBar;
    ggbrTranslateX: TGaugeBar;
    ggbrTranslateY: TGaugeBar;
    procedure FormCreate(Sender: TObject);
    procedure imgGradientAngleMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);
    procedure imgGradientAngleMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure imgGradientAngleMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);
    procedure FormShow(Sender: TObject);
    procedure spdbtnOpenGradientPickerMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure spdbtnOpenGradientPickerClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edtGradientAngleChange(Sender: TObject);
    procedure ChangeGradientScale(Sender: TObject);
    procedure ChangeTranslateX(Sender: TObject);
    procedure ChangeTranslateY(Sender: TObject);
    procedure cmbbxGradientStyleChange(Sender: TObject);
    procedure chckbxReverseClick(Sender: TObject);
    procedure imgSelectedGradientClick(Sender: TObject);
    procedure edtTranslateXChange(Sender: TObject);
    procedure edtTranslateYChange(Sender: TObject);
    procedure edtGradientScaleChange(Sender: TObject);
    procedure imgSelectedGradientPaintStage(Sender: TObject;
      Buffer: TBitmap32; StageNum: Cardinal);
  private
    FDrawing               : Boolean;
    FCenterPoint           : TPoint;
    FCirclePoint           : TPoint;
    FRadius                : Double;
    FRadians               : Double;
    FMidXPos, FMidYPos     : Integer;
    FButtonX, FButtonY     : Integer;
    FGradientFillLayerPanel: TgmGradientFillLayerPanel;
    FBarIsChanging         : Boolean;

    procedure ChangeBitmapColor;
    procedure UpdateOptions;
  public
    { Public declarations }
  end;

var
  frmGradientFill: TfrmGradientFill;

implementation

uses
{ Standard Lib }
  Math,
{ externals }
  LineLibrary,
{ GraphicsMagic Package Lib }
  gmGradientRender,
{ GraphicsMagic Lib }
  gmMath,
  gmPaintFuncs,
{ GraphicsMagic Forms/Dialogs }
  MainForm,
  GradientPickerPopFrm,
  GradientEditorDlg;

{$R *.dfm}

//-- Custom Methods ------------------------------------------------------------

procedure TfrmGradientFill.ChangeBitmapColor;
var
  x, y: Integer;
begin
  with imgDegrees.Picture do
  begin
    Bitmap.PixelFormat := pf24bit;

    for y := 0 to (Bitmap.Height - 1) do
    begin
      for x := 0 to (Bitmap.Width - 1) do
      begin
        if Bitmap.Canvas.Pixels[x, y] = clWhite then
        begin
          Bitmap.Canvas.Pixels[x, y] := clBtnFace;
        end;
      end;
    end;
  end;
end;

procedure TfrmGradientFill.UpdateOptions;
begin
  if Assigned(FGradientFillLayerPanel) then
  begin
    FGradientFillLayerPanel.Gradient.GradientLength := imgSelectedGradient.Bitmap.Width;
    FGradientFillLayerPanel.Gradient.RefreshColorArray; 

    FGradientFillLayerPanel.Gradient.DrawColorGradients(
      imgSelectedGradient.Bitmap, FGradientFillLayerPanel.IsReversed);

    imgSelectedGradient.Bitmap.Changed;

    cmbbxGradientStyle.ItemIndex := Integer(FGradientFillLayerPanel.Style);
    edtGradientAngle.Text        := IntToStr(0 - FGradientFillLayerPanel.Angle);
    ggbrGradientScale.Position   := Round(FGradientFillLayerPanel.Scale * 100);
    FMidXPos                     := ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width;
    FMidYPos                     := ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height;
    ggbrTranslateX.Max           := FMidXPos * 2;
    ggbrTranslateY.Max           := FMidYPos * 2;
    ggbrTranslateX.Position      := FMidXPos + FGradientFillLayerPanel.TranslateX;
    ggbrTranslateY.Position      := FMidYPos + FGradientFillLayerPanel.TranslateY;
    chckbxReverse.Checked        := FGradientFillLayerPanel.IsReversed;
  end;
end; 

procedure TfrmGradientFill.FormCreate(Sender: TObject);
var
  Width, Height, HalfWidth, HalfHeight: Integer;
begin
  ChangeBitmapColor;
  
  Width      := imgGradientAngle.Width;
  Height     := imgGradientAngle.Height;
  HalfWidth  := Width  div 2;
  HalfHeight := Height div 2;

  imgGradientAngle.Bitmap.SetSize(Width, Height);
  imgSelectedGradient.Bitmap.SetSize(imgSelectedGradient.Width, imgSelectedGradient.Height);
  imgSelectedGradient.Bitmap.DrawMode := dmBlend;

  with imgSelectedGradient.PaintStages[0]^ do
  begin
    if Stage = PST_CLEAR_BACKGND then
    begin
      Stage := PST_CUSTOM;
    end;
  end;

  FRadius                 := MinIntValue([HalfWidth, HalfHeight]);
  FRadians                := -PI / 2;
  FCenterPoint            := Point(HalfWidth,  HalfHeight);
  FCirclePoint            := CalcOffsetPointByRadian(FCenterPoint, FRadians, FRadius);
  FDrawing                := False;
  FGradientFillLayerPanel := nil;
  FBarIsChanging          := False;
end;

procedure TfrmGradientFill.imgGradientAngleMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
begin
  FDrawing := NearLine( Point(X, Y), FCenterPoint, FCirclePoint);
end;

procedure TfrmGradientFill.imgGradientAngleMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
var
  Angle: Integer;
begin
  if NearLine( Point(X, Y), FCenterPoint, FCirclePoint) then
  begin
    Screen.Cursor := crHandPoint;
  end
  else
  begin
    Screen.Cursor := crDefault;
  end;

  if FDrawing then
  begin
    FRadians              := CalcRadianByTwoPoints( FCenterPoint, Point(X, Y) );
    Angle                 := Round( RadToDeg(0 - FRadians) );
    edtGradientAngle.Text := IntToStr(Angle);
  end;
end;

procedure TfrmGradientFill.imgGradientAngleMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
begin
  if FDrawing then
  begin
    FDrawing     := False;
    FCirclePoint := CalcOffsetPointByRadian(FCenterPoint, FRadians, FRadius);
  end;
end;

procedure TfrmGradientFill.FormShow(Sender: TObject);
begin
  DrawDirectionCircle(imgGradientAngle.Bitmap.Canvas, FCenterPoint,
                      FRadius, FRadians, False);

  frmGradientPicker.ShowFillLayerSelectedGradient;

  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfGradientFill then
  begin
    FGradientFillLayerPanel := TgmGradientFillLayerPanel(
      ActiveChildForm.LayerPanelList.SelectedLayerPanel);
      
    FGradientFillLayerPanel.DrawGradientOnLayer;
    UpdateOptions;
  end;
end; 

procedure TfrmGradientFill.spdbtnOpenGradientPickerMouseDown(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  FButtonX := X;
  FButtonY := Y;
end;

procedure TfrmGradientFill.spdbtnOpenGradientPickerClick(Sender: TObject);
var
  p: TPoint;
begin
  GetCursorPos(p);
  frmGradientPicker.Left := p.X - frmGradientPicker.Width - FButtonX;
  frmGradientPicker.Top  := p.Y + (spdbtnOpenGradientPicker.Height - FButtonY);

  if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfGradientFill then
  begin
    frmGradientPicker.GradientUser := guGradientFillLayer;
  end;

  frmGradientPicker.Show;
end;

procedure TfrmGradientFill.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FGradientFillLayerPanel := nil;
end;

procedure TfrmGradientFill.edtGradientAngleChange(Sender: TObject);
var
  Angle: Integer;
begin
  if FGradientFillLayerPanel <> nil then
  begin
    try
      Angle := StrToInt(edtGradientAngle.Text);
      EnsureValueInRange(Angle, -180, 180);
      edtGradientAngle.Text := IntToStr(Angle);
      FGradientFillLayerPanel.Angle := 0 - Angle;
      FRadians     := DegToRad(0 - Angle);
      FCirclePoint := CalcOffsetPointByRadian(FCenterPoint, FRadians, FRadius);
      DrawDirectionCircle(imgGradientAngle.Bitmap.Canvas, FCenterPoint, FRadius, FRadians, False);
    except
      edtGradientAngle.Text := IntToStr(90);
    end;
  end;
end;

procedure TfrmGradientFill.ChangeGradientScale(Sender: TObject);
var
  Value: Integer;
begin
  FBarIsChanging := True;
  try
    Value                 := ggbrGradientScale.Position;
    edtGradientScale.Text := IntToStr(Value);

    if Assigned(FGradientFillLayerPanel) then
    begin
      FGradientFillLayerPanel.Scale := Value / 100;
    end;
  finally
    FBarIsChanging := False;
  end;
end; 

procedure TfrmGradientFill.ChangeTranslateX(Sender: TObject);
var
  Value: Integer;
begin
  FBarIsChanging := True;
  try
    Value              := ggbrTranslateX.Position - FMidXPos;
    edtTranslateX.Text := IntToStr(Value);

    if Assigned(FGradientFillLayerPanel) then
    begin
      FGradientFillLayerPanel.TranslateX := Value;
    end;
  finally
    FBarIsChanging := False;
  end;
end; 

procedure TfrmGradientFill.ChangeTranslateY(Sender: TObject);
var
  Value: Integer;
begin
  FBarIsChanging := True;
  try
    Value              := ggbrTranslateY.Position - FMidYPos;
    edtTranslateY.Text := IntToStr(Value);

    if Assigned(FGradientFillLayerPanel) then
    begin
      FGradientFillLayerPanel.TranslateY := Value;
    end;
  finally
    FBarIsChanging := False;
  end;
end;

procedure TfrmGradientFill.cmbbxGradientStyleChange(Sender: TObject);
begin
  if Assigned(FGradientFillLayerPanel) then
  begin
    FGradientFillLayerPanel.Style := TgmGradientRenderMode(cmbbxGradientStyle.ItemIndex);
  end;
end;

procedure TfrmGradientFill.chckbxReverseClick(Sender: TObject);
begin
  if Assigned(FGradientFillLayerPanel) then
  begin
    FGradientFillLayerPanel.IsReversed := chckbxReverse.Checked;
  end;
  
  frmGradientPicker.ShowFillLayerSelectedGradient;
end;

procedure TfrmGradientFill.imgSelectedGradientClick(Sender: TObject);
begin
  frmGradientEditor := TfrmGradientEditor.Create(nil);
  try
    frmGradientEditor.GradientUser := guGradientFillLayer;
    frmGradientEditor.ShowModal;
  finally
    FreeAndNil(frmGradientEditor);
  end;
end; 

procedure TfrmGradientFill.edtTranslateXChange(Sender: TObject);
var
  ChangedValue, MinVal, MaxVal: Integer;
begin
  if not FBarIsChanging then
  begin
    MinVal := ggbrTranslateX.Min - FMidXPos;
    MaxVal := ggbrTranslateX.Max - FMidXPos;

    try
      ChangedValue := StrToInt(edtTranslateX.Text);
      EnsureValueInRange(ChangedValue, MinVal, MaxVal);
      edtTranslateX.Text      := IntToStr(ChangedValue);
      ggbrTranslateX.Position := FMidXPos + ChangedValue;
    except
      ggbrTranslateX.Position := FMidXPos;
    end;
  end;
end;

procedure TfrmGradientFill.edtTranslateYChange(Sender: TObject);
var
  ChangedValue, MinVal, MaxVal: Integer;
begin
  if not FBarIsChanging then
  begin
    MinVal := ggbrTranslateY.Min - FMidYPos;
    MaxVal := ggbrTranslateY.Max - FMidYPos;
    
    try
      ChangedValue := StrToInt(edtTranslateY.Text);
      EnsureValueInRange(ChangedValue, MinVal, MaxVal);
      edtTranslateY.Text      := IntToStr(ChangedValue);
      ggbrTranslateY.Position := FMidYPos + ChangedValue;
    except
      ggbrTranslateY.Position := FMidYPos;
    end;
  end;
end; 

procedure TfrmGradientFill.edtGradientScaleChange(Sender: TObject);
var
  ChangedValue: Integer;
begin
  if not FBarIsChanging then
  begin
    try
      ChangedValue := StrToInt(edtGradientScale.Text);
      EnsureValueInRange(ChangedValue, ggbrGradientScale.Min, ggbrGradientScale.Max);
      edtGradientScale.Text      := IntToStr(ChangedValue);
      ggbrGradientScale.Position := ChangedValue;
    except
      ggbrTranslateX.Position := 100;
    end;
  end;
end; 

procedure TfrmGradientFill.imgSelectedGradientPaintStage(Sender: TObject;
  Buffer: TBitmap32; StageNum: Cardinal);
begin
  DrawCheckerboardPattern(Buffer, True);
end;

end.
