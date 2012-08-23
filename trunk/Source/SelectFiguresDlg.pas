{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

unit SelectFiguresDlg;

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

{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_CAST OFF}

interface

uses
{ Standard Lib }
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ImgList, StdCtrls, ComCtrls, ToolWin, ExtCtrls, Buttons,
{ GraphicsMagic Lib }
  gmFigures;

type
  TfrmSelectFigures = class(TForm)
    pnlFigureList: TPanel;
    pnlButtons: TPanel;
    spltrSelectFigures: TSplitter;
    grpbxFigureProperties: TGroupBox;
    tlbrLayerSelect: TToolBar;
    ToolButton1: TToolButton;
    cmbbxLayerSelect: TComboBox;
    lblLayerName: TLabel;
    lstbxFigureList: TListBox;
    imglstSelectFigure: TImageList;
    lblFigureName: TLabel;
    lblFigureNameValue: TLabel;
    lblStartingCoordinate: TLabel;
    lblStartCoordValue: TLabel;
    lblEndingCoordinate: TLabel;
    lblEndCoordValue: TLabel;
    lblCurveControlPoint1: TLabel;
    lblCurvePoint1Value: TLabel;
    lblCurveControlPoint2: TLabel;
    lblCurvePoint2Value: TLabel;
    lblPenWidth: TLabel;
    lblPenWidthValue: TLabel;
    lblCornerRadius: TLabel;
    lblCornerRadiusValue: TLabel;
    bvlHorizontalLine: TBevel;
    lblPenColor: TLabel;
    shpPenColor: TShape;
    lblBrushColor: TLabel;
    shpBrushColor: TShape;
    imgPenStyle: TImage;
    lblPenStyle: TLabel;
    imgBrushStyle: TImage;
    lblBrushStyle: TLabel;
    tlbrListTools: TToolBar;
    ToolButton2: TToolButton;
    tlbtnMoveUp: TToolButton;
    tlbtnMoveDown: TToolButton;
    tlbtnDeleteSelectedFigures: TToolButton;
    btbtnOK: TBitBtn;
    btbtnCancel: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure cmbbxLayerSelectChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lstbxFigureListMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ChangeSelectedFigureIndex(Sender: TObject);
    procedure DeleteSelectedFigures(Sender: TObject);
    procedure lstbxFigureListKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { 2D interger array FSelectedInfo is used to hold the information of
      selected figures. The first dimension is used to hold the indices for
      indexing the FSelectedFigureLayerIndexArray field of the LayerPanelList
      for getting the index of layers that with selected figures. The second
      dimension is used to hold the indices of the selected figures that on
      certain layers with selected figures.}
      
    FSelectedInfo      : array of array of Integer;
    FAllOriginalFigures: array of array of TgmFigureObject;

    procedure ListAllFiguresOnOneFigureLayer(const Index: Integer);
    procedure GetFigureLayerName;
    procedure GetSelectedInfo; 
    procedure ShowSelectedFigureProperties;
    procedure HideAllFigureProperties;
    procedure BackupAllFigures;
    procedure ChangeButtonsStatus;
  public
    procedure ClearSelectedInfoArray;
    procedure ClearAllOriginalFiguresArray;
    procedure ApplyConfiguration;
    procedure CancelConfiguration;
  end;

var
  frmSelectFigures: TfrmSelectFigures;

implementation

uses
{ Graphics32 }
  GR32_Layers,
{ GraphicsMagic Lib }
  gmLayerAndChannel,
{ GraphicsMagic Forms/Dialogs }
  MainForm;

{$R *.DFM}

//-- Custom Procedures and Functions -------------------------------------------

procedure TfrmSelectFigures.GetFigureLayerName;
var
  i, LLayerIndex: Integer;
  LLayerPanel   : TgmLayerPanel;
begin
  cmbbxLayerSelect.Items.Clear;

  if High(ActiveChildForm.LayerPanelList.FFigureLayerIndexArray) > (-1) then
  begin
    for i := Low(ActiveChildForm.LayerPanelList.FFigureLayerIndexArray) to
             High(ActiveChildForm.LayerPanelList.FFigureLayerIndexArray) do
    begin
      LLayerIndex := ActiveChildForm.LayerPanelList.FFigureLayerIndexArray[i];
      LLayerPanel := TgmLayerPanel(ActiveChildForm.LayerPanelList.Items[LLayerIndex]);

      cmbbxLayerSelect.Items.Add(LLayerPanel.LayerName.Caption);

      { The number of elements in the FSelectedInfo array is same as
        the number of figure layers. }
      SetLength( FSelectedInfo, High(FSelectedInfo) + 2 );
    end;
  end;
end;

procedure TfrmSelectFigures.ListAllFiguresOnOneFigureLayer(const Index: Integer);
var
  i, LLayerIndex       : Integer;
  LLowIndex, LHighIndex: Integer;
  LFigureLayerPanel    : TgmFigureLayerPanel;
  LFigureObj           : TgmFigureObject;
begin
  lstbxFigureList.Items.Clear;
  
  LLowIndex  := Low(ActiveChildForm.LayerPanelList.FFigureLayerIndexArray);
  LHighIndex := High(ActiveChildForm.LayerPanelList.FFigureLayerIndexArray);

  if LHighIndex > (-1) then
  begin
    if (Index >= LLowIndex) and (Index <= LHighIndex) then
    begin
      LLayerIndex       := ActiveChildForm.LayerPanelList.FFigureLayerIndexArray[Index];
      LFigureLayerPanel := TgmFigureLayerPanel(ActiveChildForm.LayerPanelList.Items[LLayerIndex]);

      if LFigureLayerPanel.FigureList.Count > 0 then
      begin
        for i := 0 to (LFigureLayerPanel.FigureList.Count - 1) do
        begin
          LFigureObj := TgmFigureObject(LFigureLayerPanel.FigureList.Items[i]);

          lstbxFigureList.Items.Add(LFigureObj.Name);
        end;
      end;
    end;
  end;

  lstbxFigureList.Update;
end;

procedure TfrmSelectFigures.GetSelectedInfo;
var
  i, j       : Integer;
  LIndex     : Integer;
  LLayerIndex: Integer;
begin
  SetLength(ActiveChildForm.LayerPanelList.FSelectedFigureLayerIndexArray, 0);
  SetLength(ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray, 0);

  if High(FSelectedInfo) > (-1) then
  begin
    LIndex := cmbbxLayerSelect.ItemIndex;
    SetLength(FSelectedInfo[LIndex], 0);

    if lstbxFigureList.Items.Count > 0 then
    begin
      for i := 0 to (lstbxFigureList.Items.Count - 1) do
      begin
        if lstbxFigureList.Selected[i] then
        begin
          SetLength( FSelectedInfo[LIndex], High(FSelectedInfo[LIndex]) + 2 );

          FSelectedInfo[LIndex, High(FSelectedInfo[LIndex])] := i;
        end;
      end;
    end;

    for i := Low(FSelectedInfo) to High(FSelectedInfo) do
    begin
      if High(FSelectedInfo[i]) > (-1) then
      begin
        LLayerIndex := ActiveChildForm.LayerPanelList.FFigureLayerIndexArray[i];

        SetLength( ActiveChildForm.LayerPanelList.FSelectedFigureLayerIndexArray,
                   High(ActiveChildForm.LayerPanelList.FSelectedFigureLayerIndexArray) + 2 );

        LIndex := High(ActiveChildForm.LayerPanelList.FSelectedFigureLayerIndexArray);

        ActiveChildForm.LayerPanelList.FSelectedFigureLayerIndexArray[LIndex] := LLayerIndex;

        for j := Low(FSelectedInfo[i]) to High(FSelectedInfo[i]) do
        begin
          SetLength( ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray,
                     High(ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray) + 2 );

          LIndex := High(ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray);

          ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray[LIndex].LayerIndex  := LLayerIndex;
          ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray[LIndex].FigureIndex := FSelectedInfo[i, j];
        end;
      end;
    end;
  end;
end;

procedure TfrmSelectFigures.ShowSelectedFigureProperties;
var
  LLayerIndex      : Integer;
  LFigureIndex     : Integer;
  i, LX1, LX2      : Integer;
  LFigureObj       : TgmFigureObject;
  LFigureLayerPanel: TgmFigureLayerPanel;
begin
  LFigureIndex := 0;
  
  if lstbxFigureList.Items.Count > 0 then
  begin
    HideAllFigureProperties;

    LLayerIndex := ActiveChildForm.LayerPanelList.FFigureLayerIndexArray[cmbbxLayerSelect.ItemIndex];

    for i := 0 to (lstbxFigureList.Items.Count - 1) do
    begin
      if lstbxFigureList.Selected[i] then
      begin
        LFigureIndex := i;
        Break;
      end;
    end;

    LFigureLayerPanel := TgmFigureLayerPanel(ActiveChildForm.LayerPanelList.Items[LLayerIndex]);
    LFigureObj        := TgmFigureObject(LFigureLayerPanel.FigureList.Items[LFigureIndex]);

    lblFigureNameValue.Caption := LFigureObj.Name;
    lblFigureNameValue.Hint    := LFigureObj.Name;
    lblPenWidthValue.Caption   := IntToStr(LFigureObj.PenWidth) + '  Pixels';
    shpPenColor.Brush.Color    := LFigureObj.PenColor;
    shpBrushColor.Brush.Color  := LFigureObj.BrushColor;

    with imgBrushStyle.Canvas do
    begin
      Pen.Color   := clBlack;
      Pen.Style   := psSolid;
      Brush.Color := clWhite;
      Brush.Style := bsSolid;

      Rectangle(0, 0, imgBrushStyle.Width, imgBrushStyle.Height);

      Brush.Color := LFigureObj.BrushColor;
      Brush.Style := LFigureObj.BrushStyle;

      Rectangle(0, 0, imgBrushStyle.Width, imgBrushStyle.Height);
    end;

    with imgPenStyle.Canvas do
    begin
      Pen.Color   := clBlack;
      Pen.Style   := psSolid;
      Brush.Style := bsSolid;

      Rectangle(0, 0, imgPenStyle.Width, imgPenStyle.Height);

      Pen.Style := LFigureObj.PenStyle;
      LX1       := MulDiv(0 + imgPenStyle.Width, 1, 5);
      LX2       := MulDiv(0 + imgPenStyle.Width, 4, 5);

      MoveTo(LX1, (0 + imgPenStyle.Height) div 2);
      LineTo(LX2, (0 + imgPenStyle.Height) div 2);
    end;

    lblFigureNameValue.Visible := True;
    lblPenWidthValue.Visible   := True;
    shpPenColor.Visible        := True;
    shpBrushColor.Visible      := True;
    imgPenStyle.Visible        := True;
    imgBrushStyle.Visible      := True;

    if LFigureObj.Flag in [ffStraightLine, ffCurve, ffRectangle,
                           ffSquare, ffRoundRectangle, ffRoundSquare,
                           ffEllipse, ffCircle] then
    begin
      lblStartCoordValue.Caption := Format('(%d, %d)', [LFigureObj.FStartPoint.X, LFigureObj.FStartPoint.Y]);
      lblEndCoordValue.Caption   := Format('(%d, %d)', [LFigureObj.FEndPoint.X, LFigureObj.FEndPoint.Y]);
      lblStartCoordValue.Visible := True;
      lblEndCoordValue.Visible   := True;
    end;

    if LFigureObj.Flag = ffCurve then
    begin
      lblCurvePoint1Value.Caption := Format('(%d, %d)', [LFigureObj.FCurvePoint1.X, LFigureObj.FCurvePoint1.Y]);
      lblCurvePoint2Value.Caption := Format('(%d, %d)', [LFigureObj.FCurvePoint2.X, LFigureObj.FCurvePoint2.Y]);
      lblCurvePoint1Value.Visible := True;
      lblCurvePoint2Value.Visible := True;
    end;

    if LFigureObj.Flag in [ffRoundRectangle, ffRoundSquare] then
    begin
      lblCornerRadiusValue.Caption := IntToStr(LFigureObj.RoundCornerRadius);
      lblCornerRadiusValue.Visible := True;
    end;
  end;
end;

procedure TfrmSelectFigures.HideAllFigureProperties;
begin
  lblFigureNameValue.Visible   := False;
  lblStartCoordValue.Visible   := False;
  lblEndCoordValue.Visible     := False;
  lblCurvePoint1Value.Visible  := False;
  lblCurvePoint2Value.Visible  := False;
  lblCornerRadiusValue.Visible := False;
  lblPenWidthValue.Visible     := False;
  shpPenColor.Visible          := False;
  shpBrushColor.Visible        := False;
  imgPenStyle.Visible          := False;
  imgBrushStyle.Visible        := False;
end;

procedure TfrmSelectFigures.BackupAllFigures;
var
  i, j       : Integer;
  LLayerIndex: Integer;
  LLayerPanel: TgmFigureLayerPanel;
  LFigureObj : TgmFigureObject;
begin
  ClearAllOriginalFiguresArray;

  if High(ActiveChildForm.LayerPanelList.FFigureLayerIndexArray) > (-1) then
  begin
    for i := Low(ActiveChildForm.LayerPanelList.FFigureLayerIndexArray)  to
             High(ActiveChildForm.LayerPanelList.FFigureLayerIndexArray) do
    begin
      { The number of elements in the FSelectedInfo array is same as
        the number of figure layers. }
      SetLength( FAllOriginalFigures, High(FAllOriginalFigures) + 2 );

      LLayerIndex := ActiveChildForm.LayerPanelList.FFigureLayerIndexArray[i];
      LLayerPanel := TgmFigureLayerPanel(ActiveChildForm.LayerPanelList.Items[LLayerIndex]);

      if LLayerPanel.FigureList.Count > 0 then
      begin
        for j := 0 to (LLayerPanel.FigureList.Count - 1) do
        begin
          LFigureObj := TgmFigureObject(LLayerPanel.FigureList.Items[j]);
         
          SetLength( FAllOriginalFigures[i], High(FAllOriginalFigures[i]) + 2 );
          FAllOriginalFigures[i, j] := LFigureObj.GetSelfBackup;
        end;
      end;
    end;
  end;
end;

procedure TfrmSelectFigures.ChangeButtonsStatus;
begin
  tlbtnDeleteSelectedFigures.Enabled := (lstbxFigureList.SelCount > 0);
  tlbtnMoveUp.Enabled                := (lstbxFigureList.SelCount = 1) and (lstbxFigureList.ItemIndex > 0);
  tlbtnMoveDown.Enabled              := (lstbxFigureList.SelCount = 1) and (lstbxFigureList.ItemIndex < lstbxFigureList.Items.Count - 1);
end;

procedure TfrmSelectFigures.ClearSelectedInfoArray;
var
  i: Integer;
begin
  if High(FSelectedInfo) > (-1) then
  begin
    for i := Low(FSelectedInfo) to High(FSelectedInfo) do
    begin
      SetLength(FSelectedInfo[i], 0);
    end;

    SetLength(FSelectedInfo, 0);
  end;
end;

procedure TfrmSelectFigures.ClearAllOriginalFiguresArray;
var
  i: Integer;
begin
  if High(FAllOriginalFigures) > (-1) then
  begin
    for i := Low(FAllOriginalFigures) to High(FAllOriginalFigures) do
    begin
      SetLength(FAllOriginalFigures[i], 0);
    end;

    SetLength(FAllOriginalFigures, 0);
  end;
end;

procedure TfrmSelectFigures.ApplyConfiguration;
var
  i, j             : Integer;
  LLayerIndex      : Integer;
  LFigureIndex     : Integer;
  LFigureLayerPanel: TgmFigureLayerPanel;
  LFigureObj       : TgmFigureObject;
begin
  if High(FSelectedInfo) > (-1) then
  begin
    for i := Low(FSelectedInfo) to High(FSelectedInfo) do
    begin
      LLayerIndex := ActiveChildForm.LayerPanelList.FFigureLayerIndexArray[i];

      if High(FSelectedInfo[i]) > (-1) then
      begin
        for j := Low(FSelectedInfo[i]) to High(FSelectedInfo[i]) do
        begin
          LFigureIndex          := FSelectedInfo[i, j];
          LFigureLayerPanel     := TgmFigureLayerPanel(ActiveChildForm.LayerPanelList.Items[LLayerIndex]);
          LFigureObj            := TgmFigureObject(LFigureLayerPanel.FigureList.Items[LFigureIndex]);
          LFigureObj.IsSelected := True;
        end;
      end;
    end;
  end;
end;

procedure TfrmSelectFigures.CancelConfiguration;
var
  i, j             : Integer;
  LLayerIndex      : Integer;
  LFigureLayerPanel: TgmFigureLayerPanel;
  LFigureObj       : TgmFigureObject;
begin
  if High(FAllOriginalFigures) > (-1) then
  begin
    SetLength(ActiveChildForm.LayerPanelList.FSelectedFigureInfoArray, 0);
    SetLength(ActiveChildForm.LayerPanelList.FSelectedFigureLayerIndexArray, 0);

    for i := Low(FAllOriginalFigures) to High(FAllOriginalFigures) do
    begin
      LLayerIndex       := ActiveChildForm.LayerPanelList.FFigureLayerIndexArray[i];
      LFigureLayerPanel := TgmFigureLayerPanel(ActiveChildForm.LayerPanelList.Items[LLayerIndex]);

      LFigureLayerPanel.FigureList.DeleteAllFigures;

      for j := Low(FAllOriginalFigures[i]) to High(FAllOriginalFigures[i]) do
      begin
        LFigureObj := FAllOriginalFigures[i, j].GetSelfBackup;

        LFigureLayerPanel.FigureList.Add(LFigureObj);
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TfrmSelectFigures.FormShow(Sender: TObject);
begin
  GetFigureLayerName;
  BackupAllFigures;
  cmbbxLayerSelect.ItemIndex := 0;
  ListAllFiguresOnOneFigureLayer(0);
  HideAllFigureProperties;
  ChangeButtonsStatus;
end;

procedure TfrmSelectFigures.cmbbxLayerSelectChange(Sender: TObject);
var
  i    : Integer;
  Index: Integer;
begin
  ListAllFiguresOnOneFigureLayer(cmbbxLayerSelect.ItemIndex);

  if lstbxFigureList.Items.Count > 0 then
  begin
    for i := Low(FSelectedInfo[cmbbxLayerSelect.ItemIndex]) to
             High(FSelectedInfo[cmbbxLayerSelect.ItemIndex]) do
    begin
      Index := FSelectedInfo[cmbbxLayerSelect.ItemIndex, i];
      lstbxFigureList.Selected[Index] := True;
    end;

    if lstbxFigureList.SelCount = 1 then
    begin
      ShowSelectedFigureProperties;
    end
    else
    begin
      HideAllFigureProperties;
    end;

    ChangeButtonsStatus;
  end;
end; 

procedure TfrmSelectFigures.FormCreate(Sender: TObject);
begin
  SetLength(FSelectedInfo, 0);
  SetLength(FAllOriginalFigures, 0);
end;

procedure TfrmSelectFigures.FormDestroy(Sender: TObject);
begin
  ClearSelectedInfoArray;
  ClearAllOriginalFiguresArray;
end; 

procedure TfrmSelectFigures.lstbxFigureListMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  GetSelectedInfo;

  if ActiveChildForm.FHandleLayer <> nil then
  begin
    ActiveChildForm.FHandleLayer.Bitmap.Clear($00FFFFFF);

    ActiveChildForm.LayerPanelList.DrawSelectedFiguresHandles(
      ActiveChildForm.FHandleLayer.Bitmap, ActiveChildForm.FHandleLayerOffsetVector);
      
    ActiveChildForm.FHandleLayer.Bitmap.Changed;
  end;

  if lstbxFigureList.SelCount = 1 then
  begin
    ShowSelectedFigureProperties;
  end
  else
  begin
    HideAllFigureProperties;
  end;

  ChangeButtonsStatus;
end;

procedure TfrmSelectFigures.ChangeSelectedFigureIndex(Sender: TObject);
var
  LLayerIndex : Integer;
  LFigureIndex: Integer;
  LTargetIndex: Integer;
  i           : Integer;
  LLayerPanel : TgmFigureLayerPanel;
begin
  LFigureIndex := 0;
  LTargetIndex := 0;
  LLayerIndex := ActiveChildForm.LayerPanelList.FFigureLayerIndexArray[cmbbxLayerSelect.ItemIndex];

  for i := 0 to (lstbxFigureList.Items.Count - 1) do
  begin
    if lstbxFigureList.Selected[i] then
    begin
      LFigureIndex := i;
      Break;
    end;
  end;

  if Sender = tlbtnMoveUp then
  begin
    LTargetIndex := LFigureIndex - 1;
  end
  else if Sender = tlbtnMoveDown then
  begin
    LTargetIndex := LFigureIndex + 1;
  end;

  lstbxFigureList.Items.Move(LFigureIndex, LTargetIndex);

  LLayerPanel := TgmFigureLayerPanel(ActiveChildForm.LayerPanelList.Items[LLayerIndex]);
  LLayerPanel.FigureList.Move(LFigureIndex, LTargetIndex);

  lstbxFigureList.Selected[LTargetIndex] := True;

  GetSelectedInfo;

  ActiveChildForm.LayerPanelList.DrawAllFiguresOnSpecifiedLayer(
    ActiveChildForm.imgDrawingArea.Layers, LLayerIndex);

  if ActiveChildForm.FHandleLayer <> nil then
  begin
    ActiveChildForm.FHandleLayer.Bitmap.Clear($00FFFFFF);

    ActiveChildForm.LayerPanelList.DrawSelectedFiguresHandles(
      ActiveChildForm.FHandleLayer.Bitmap, ActiveChildForm.FHandleLayerOffsetVector);

    ActiveChildForm.FHandleLayer.Bitmap.Changed;
  end;

  ChangeButtonsStatus;
end;

procedure TfrmSelectFigures.DeleteSelectedFigures(Sender: TObject);
var
  i, LLayerIndex: Integer;
  LLayerPanel   : TgmFigureLayerPanel;
begin
  LLayerIndex := ActiveChildForm.LayerPanelList.FFigureLayerIndexArray[cmbbxLayerSelect.ItemIndex];

  // deleting in inverse order, otherwise an index error exception will be raised
  for i := (lstbxFigureList.Items.Count - 1) downto 0 do
  begin
    if lstbxFigureList.Selected[i] then
    begin
      lstbxFigureList.Items.Delete(i);

      LLayerPanel := TgmFigureLayerPanel(ActiveChildForm.LayerPanelList.Items[LLayerIndex]);

      LLayerPanel.FigureList.Delete(i);
    end;
  end;

  GetSelectedInfo;

  ActiveChildForm.LayerPanelList.DrawAllFiguresOnSpecifiedLayer(
    ActiveChildForm.imgDrawingArea.Layers, LLayerIndex);

  if ActiveChildForm.FHandleLayer <> nil then
  begin
    ActiveChildForm.FHandleLayer.Bitmap.Clear($00FFFFFF);

    ActiveChildForm.LayerPanelList.DrawSelectedFiguresHandles(
      ActiveChildForm.FHandleLayer.Bitmap, ActiveChildForm.FHandleLayerOffsetVector);
      
    ActiveChildForm.FHandleLayer.Bitmap.Changed;
  end;

  ChangeButtonsStatus;
end;

procedure TfrmSelectFigures.lstbxFigureListKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key in [VK_UP, VK_DOWN] then
  begin
    if lstbxFigureList.SelCount > 0 then
    begin
      GetSelectedInfo;

      if ActiveChildForm.FHandleLayer <> nil then
      begin
        ActiveChildForm.FHandleLayer.Bitmap.Clear($00FFFFFF);

        ActiveChildForm.LayerPanelList.DrawSelectedFiguresHandles(
          ActiveChildForm.FHandleLayer.Bitmap, ActiveChildForm.FHandleLayerOffsetVector);

        ActiveChildForm.FHandleLayer.Bitmap.Changed;
      end;

      if lstbxFigureList.SelCount = 1 then
      begin
        ShowSelectedFigureProperties;
      end
      else
      begin
        HideAllFigureProperties;
      end;
      
      ChangeButtonsStatus;
    end;
  end;
end; 

end.
