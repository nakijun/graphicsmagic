{ This library created in 01/27/2006.
  CopyRight(C) 2006, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved.

  Based on the Gimp 2.2.10 .
  The original source can be found at www.gimp.org.

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Library General Public
  License as published by the Free Software Foundation; either
  version 2 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Library General Public License for more details.

  You should have received a copy of the GNU Library General Public
  License along with this library; if not, write to the
  Free Software Foundation, Inc., 59 Temple Place - Suite 330,
  Boston, MA 02111-1307, USA.

  Thanks to the authors of GIMP for giving us the opportunity to know how to
  achieve Curves Tool. }

unit CurvesDlg;

interface

uses
{ Standard Lib }
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, 
{ Graphics32 }
  GR32_Image, GR32_Layers,
{ GraphicsMagic Lib }
  gmCurvesTool;

type
  TfrmCurves = class(TForm)
    Panel1: TPanel;
    img32Graph: TImage32;
    img32YRange: TImage32;
    img32XRange: TImage32;
    lblCurvesChannel: TLabel;
    cmbbxCurvesChannel: TComboBox;
    grpbxCurvesType: TGroupBox;
    spdbtnSmoothCurve: TSpeedButton;
    spdbtnFreeCurve: TSpeedButton;
    grpbxHistogramType: TGroupBox;
    spdbtnLinearHistogram: TSpeedButton;
    spdbtnLogHistogram: TSpeedButton;
    GroupBox1: TGroupBox;
    lblCurvesCoord: TLabel;
    btnCurvesResetAllChannels: TButton;
    btnCurveChannelRest: TButton;
    btbtnCancel: TBitBtn;
    btbtnOK: TBitBtn;
    chckbxPreview: TCheckBox;
    btnLoadCurves: TButton;
    btnSaveCurves: TButton;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ChangeCurvesChannel(Sender: TObject);
    procedure ChangneCurvesType(Sender: TObject);
    procedure ChangeHistogramType(Sender: TObject);
    procedure btnCurvesResetAllChannelsClick(Sender: TObject);
    procedure btnCurveChannelRestClick(Sender: TObject);
    procedure chckbxPreviewClick(Sender: TObject);
    procedure btbtnOKClick(Sender: TObject);
    procedure btnLoadCurvesClick(Sender: TObject);
    procedure btnSaveCurvesClick(Sender: TObject);
  private
    { Private declarations }
    FNormalCurvesTool    : TgmCurvesTool; // Created for normal layer...
    FCurvesTool          : TgmCurvesTool; // Points to normal or curves layer.
    FCurvesDrawing       : Boolean;
    FCurvesFileName      : string;        // opened curves file name
    FWorkingOnEffectLayer: Boolean;

    procedure ExecuteCurvesOnSelection;
    procedure ExecuteCurvesOnAlphaChannel;
    procedure ExecuteCurvesOnQuickMask;
    procedure ExecuteCurvesOnLayerMask;
    procedure ExecuteCurvesOnLayer;
    procedure ExecuteCurves;

    procedure ChangeChannelItems; // Change the items in the Channel combobox.
    procedure UpdateChannelComboBoxHint;

    { Mouse events for normal layers, transparent layers and mask. }
    procedure GimpCurvesToolMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);

    procedure GimpCurvesToolMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);

    procedure GimpCurvesToolMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
      Layer: TCustomLayer);
  public
    property IsWorkingOnEffectLayer: Boolean read FWorkingOnEffectLayer write FWorkingOnEffectLayer;
  end;

var
  frmCurves: TfrmCurves;

implementation

uses
{ Graphics32 }
  GR32, 
{ GraphicsMagic Lib }
  gmTypes,
  gmIni,
  gmLayerAndChannel,
  gmGimpBaseCurves,
  gmGimpHistogram,
  gmGimpColorBar,
  gmGimpBaseEnums,
  gmGimpCommonFuncs,
  gmGtkEnums,
  gmAlphaFuncs,
  gmCommands,
  gmHistoryManager,
{ GraphicsMagic Data Modules }
  HistoryDataModule,
{ GraphicsMagic Forms/Dialogs }
  MainForm,
  HistoryForm;

{$R *.dfm}

{ Custom Methods }

procedure TfrmCurves.ExecuteCurvesOnSelection;
begin
  with ActiveChildForm do
  begin
    // don't process on special layers
    if ChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue] then
    begin
      if not (LayerPanelList.SelectedLayerPanel.LayerFeature in [
                lfBackground, lfTransparent]) then
      begin
        Exit;
      end;
    end;

    FCurvesTool.Map(frmMain.FAfterProc, ChannelManager.ChannelSelectedSet);

    if chckbxPreview.Checked then
    begin
      Selection.CutOriginal.Assign(frmMain.FAfterProc);
      ShowProcessedSelection;
    end;
  end;
end;

procedure TfrmCurves.ExecuteCurvesOnAlphaChannel;
begin
  FCurvesTool.Map(frmMain.FAfterProc, ActiveChildForm.ChannelManager.ChannelSelectedSet);

  if chckbxPreview.Checked then
  begin
    if Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
    begin
      ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Assign(frmMain.FAfterProc);
      ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
    end;
  end;
end;

procedure TfrmCurves.ExecuteCurvesOnQuickMask;
begin
  FCurvesTool.Map(frmMain.FAfterProc, ActiveChildForm.ChannelManager.ChannelSelectedSet);

  if chckbxPreview.Checked then
  begin
    if Assigned(ActiveChildForm.ChannelManager.QuickMaskPanel) then
    begin
      ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap.Assign(frmMain.FAfterProc);
      ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Changed;
    end;
  end;
end;

procedure TfrmCurves.ExecuteCurvesOnLayerMask;
begin
  with ActiveChildForm do
  begin
    FCurvesTool.Map(frmMain.FAfterProc, ChannelManager.ChannelSelectedSet);

    if chckbxPreview.Checked then
    begin
      LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Assign(frmMain.FAfterProc);

      // update the layer mask channel
      if Assigned(ChannelManager.LayerMaskPanel) then
      begin
        ChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(0, 0,
          LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
      end;

      LayerPanelList.SelectedLayerPanel.Update;
    end;
  end;
end;

procedure TfrmCurves.ExecuteCurvesOnLayer;
begin
  with ActiveChildForm do
  begin
    if LayerPanelList.SelectedLayerPanel.LayerFeature in [
         lfBackground, lfTransparent] then
    begin
      FCurvesTool.Map(frmMain.FAfterProc, ChannelManager.ChannelSelectedSet);
    end;

    if chckbxPreview.Checked then
    begin
      if (LayerPanelList.SelectedLayerPanel.LayerFeature = lfCurves) and
         FWorkingOnEffectLayer then
      begin
        FCurvesTool.LUTSetup(3);
        LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
      end
      else
      begin
        if not LayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
        begin
          LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Assign(frmMain.FAfterProc);
          LayerPanelList.SelectedLayerPanel.Update;
        end;
      end;
    end;
  end;
end; 

procedure TfrmCurves.ExecuteCurves;
begin
  if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfCurves) and
     FWorkingOnEffectLayer then
  begin
    ExecuteCurvesOnLayer;
  end
  else
  begin
    if Assigned(ActiveChildForm.Selection) then
    begin
      ExecuteCurvesOnSelection;
    end
    else
    begin
      case ActiveChildForm.ChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            ExecuteCurvesOnAlphaChannel;
          end;

        wctQuickMask:
          begin
            ExecuteCurvesOnQuickMask;
          end;
          
        wctLayerMask:
          begin
            ExecuteCurvesOnLayerMask;
          end;
          
        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            ExecuteCurvesOnLayer;
          end;
      end;
    end;
  end;
end;

// Change the items in the Channel combobox.
procedure TfrmCurves.ChangeChannelItems;
begin
  cmbbxCurvesChannel.Items.Clear;

  if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfCurves) and
     FWorkingOnEffectLayer then
  begin
    cmbbxCurvesChannel.Items.Add('Value');
    cmbbxCurvesChannel.Items.Add('Red');
    cmbbxCurvesChannel.Items.Add('Green');
    cmbbxCurvesChannel.Items.Add('Blue');
  end
  else
  begin
    case ActiveChildForm.ChannelManager.CurrentChannelType of
      wctAlpha:
        begin
          if Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
          begin
            cmbbxCurvesChannel.Items.Add(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.ChannelName);
          end;
        end;

      wctQuickMask:
        begin
          if Assigned(ActiveChildForm.ChannelManager.QuickMaskPanel) then
          begin
            cmbbxCurvesChannel.Items.Add('Quick Mask');
          end;
        end;

      wctLayerMask:
        begin
          if Assigned(ActiveChildForm.ChannelManager.LayerMaskPanel) then
          begin
            cmbbxCurvesChannel.Items.Add(ActiveChildForm.ChannelManager.LayerMaskPanel.ChannelName);
          end;
        end;

      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          cmbbxCurvesChannel.Items.Add('Value');
          cmbbxCurvesChannel.Items.Add('Red');
          cmbbxCurvesChannel.Items.Add('Green');
          cmbbxCurvesChannel.Items.Add('Blue');
        end;
    end;
  end;

  cmbbxCurvesChannel.ItemIndex := FCurvesTool.Channel;

  UpdateChannelComboBoxHint;
end;

procedure TfrmCurves.UpdateChannelComboBoxHint;
begin
  if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfCurves) and
     FWorkingOnEffectLayer then
  begin
    case cmbbxCurvesChannel.ItemIndex of
      0:
        begin
          cmbbxCurvesChannel.Hint := 'Value';
        end;

      1:
        begin
          cmbbxCurvesChannel.Hint := 'Red Channel';
        end;
        
      2:
        begin
          cmbbxCurvesChannel.Hint := 'Green Channel';
        end;
        
      3:
        begin
          cmbbxCurvesChannel.Hint := 'Blue Channel';
        end;
    end;
  end
  else
  begin
    case ActiveChildForm.ChannelManager.CurrentChannelType of
      wctAlpha:
        begin
          if Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
          begin
            cmbbxCurvesChannel.Hint := ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.ChannelName;
          end;
        end;

      wctQuickMask:
        begin
          if Assigned(ActiveChildForm.ChannelManager.QuickMaskPanel) then
          begin
            cmbbxCurvesChannel.Hint := 'Quick Mask';
          end;
        end;

      wctLayerMask:
        begin
          if Assigned(ActiveChildForm.ChannelManager.LayerMaskPanel) then
          begin
            cmbbxCurvesChannel.Hint := ActiveChildForm.ChannelManager.LayerMaskPanel.ChannelName;
          end;
        end;

      wctRGB, wctRed, wctGreen, wctBlue:
        begin
          case cmbbxCurvesChannel.ItemIndex of
            0:
              begin
                cmbbxCurvesChannel.Hint := 'Value';
              end;

            1:
              begin
                cmbbxCurvesChannel.Hint := 'Red Channel';
              end;

            2:
              begin
                cmbbxCurvesChannel.Hint := 'Green Channel';
              end;

            3:
              begin
                cmbbxCurvesChannel.Hint := 'Blue Channel';
              end;
          end;
        end;
    end;
  end;
end;

{ Mouse events for normal layers, transparent layers and mask. }
procedure TfrmCurves.GimpCurvesToolMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  i            : Integer;
  tx, ty       : Integer;
  xx, yy       : Integer;
  Width, Height: Integer;
  ClosestPoint : Integer;
  Distance     : Integer;
begin
  if FCurvesTool <> nil then
  begin
    Width  := img32Graph.Bitmap.Width  - 2 * RADIUS;
    Height := img32Graph.Bitmap.Height - 2 * RADIUS;

    {  get the pointer position  }
    tx := X;
    ty := Y;

    xx := Round( (tx - RADIUS) / Width  * 255.0);
    yy := Round( (ty - RADIUS) / Height * 255.0);

    xx := CLAMP0255(xx);
    yy := CLAMP0255(yy);

    Distance     := G_MAXINT;
    ClosestPoint := 0;
    
    for i := 0 to (CURVES_NUM_POINTS - 1) do
    begin
      if FCurvesTool.Curves.Points[FCurvesTool.Channel, i, 0] <> (-1) then
      begin
        if Abs(xx - FCurvesTool.Curves.Points[FCurvesTool.Channel, i, 0]) < Distance then
        begin
          Distance     := Abs(xx - FCurvesTool.Curves.Points[FCurvesTool.Channel, i, 0]);
          ClosestPoint := i;
        end;
      end;
    end;

    if Distance > MIN_DISTANCE then
    begin
      ClosestPoint := (xx + 8) div 16;
    end;

    case FCurvesTool.Curves.CurveType[FCurvesTool.Channel] of
      GIMP_CURVE_SMOOTH:
        begin
          {  determine the leftmost and rightmost points  }
          FCurvesTool.Leftmost := -1;

          for i := (ClosestPoint - 1) downto 0 do
          begin
            if FCurvesTool.Curves.Points[FCurvesTool.Channel, i, 0] <> (-1) then
            begin
              FCurvesTool.Leftmost := FCurvesTool.Curves.Points[FCurvesTool.Channel, i, 0];
              Break;
            end;
          end;

          FCurvesTool.Rightmost := 256;

          for i := (ClosestPoint + 1) to (CURVES_NUM_POINTS - 1) do
          begin
            if FCurvesTool.Curves.Points[FCurvesTool.Channel, i, 0] <> (-1) then
            begin
              FCurvesTool.Rightmost := FCurvesTool.Curves.Points[FCurvesTool.Channel, i, 0];
              Break;
            end;
          end;

          FCurvesTool.GrabPoint := ClosestPoint;
          FCurvesTool.Curves.Points[FCurvesTool.Channel, FCurvesTool.GrabPoint, 0] := xx;
          FCurvesTool.Curves.Points[FCurvesTool.Channel, FCurvesTool.GrabPoint, 1] := 255 - yy;
        end;

      GIMP_CURVE_FREE:
        begin
          FCurvesTool.Curves.FCurve[FCurvesTool.Channel, xx] := 255 - yy;
          FCurvesTool.GrabPoint := xx;
          FCurvesTool.Last      := yy;
        end;
    end;

    FCurvesTool.Curves.CalculateCurve(FCurvesTool.Channel);

    FCurvesTool.CurvesUpdate(DRAW_X_RANGE or DRAW_GRAPH,
      img32Graph.Bitmap, img32XRange.Bitmap, img32YRange.Bitmap);

    FCurvesDrawing := True;
  end;
end;

procedure TfrmCurves.GimpCurvesToolMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
var
  i             : Integer;
  tx, ty        : Integer;
  xx, yy        : Integer;
  Width, Height : Integer;
  ClosestPoint  : Integer;
  Distance      : Integer;
  x1, x2, y1, y2: Integer;
begin
  if FCurvesTool <> nil then
  begin
    Width  := img32Graph.Bitmap.Width  - 2 * RADIUS;
    Height := img32Graph.Bitmap.Height - 2 * RADIUS;

    {  get the pointer position  }
    tx := X;
    ty := Y;

    xx := Round( (tx - RADIUS) / Width  * 255.0);
    yy := Round( (ty - RADIUS) / Height * 255.0);

    xx := CLAMP0255(xx);
    yy := CLAMP0255(yy);

    Distance     := G_MAXINT;
    ClosestPoint := 0;

    for i := 0 to (CURVES_NUM_POINTS - 1) do
    begin
      if FCurvesTool.Curves.Points[FCurvesTool.Channel, i, 0] <> (-1) then
      begin
        if Abs(xx - FCurvesTool.Curves.Points[FCurvesTool.Channel, i, 0]) < Distance then
        begin
          Distance     := Abs(xx - FCurvesTool.Curves.Points[FCurvesTool.Channel, i, 0]);
          ClosestPoint := i;
        end;
      end;
    end;

    if Distance > MIN_DISTANCE then
    begin
      ClosestPoint := (xx + 8) div 16;
    end;

    if FCurvesDrawing then  // if mouse left button is pressed...
    begin
      case FCurvesTool.Curves.CurveType[FCurvesTool.Channel] of
        GIMP_CURVE_SMOOTH:
          begin
            { If no point is grabbed...  }
            if FCurvesTool.GrabPoint = (-1) then
            begin
              if FCurvesTool.Curves.Points[FCurvesTool.Channel, ClosestPoint, 0] <> (-1) then
              begin
                Screen.Cursor := crDefault;
              end
              else
              begin
                Screen.Cursor := crSizeAll;
              end;
            end
            {  Else, drag the grabbed point  }
            else
            begin
              Screen.Cursor := crDefault;

              FCurvesTool.Curves.Points[FCurvesTool.Channel, FCurvesTool.GrabPoint, 0] := -1;

              if (xx > FCurvesTool.Leftmost) and (xx < FCurvesTool.Rightmost) then
              begin
                ClosestPoint := (xx + 8) div 16;
                
                if FCurvesTool.Curves.Points[FCurvesTool.Channel, ClosestPoint, 0] = (-1) then
                begin
                  FCurvesTool.GrabPoint := ClosestPoint;
                end;

                FCurvesTool.Curves.Points[FCurvesTool.Channel, FCurvesTool.GrabPoint, 0] := xx;
                FCurvesTool.Curves.Points[FCurvesTool.Channel, FCurvesTool.GrabPoint, 1] := 255 - yy;
              end;

              FCurvesTool.Curves.CalculateCurve(FCurvesTool.Channel);
            end;
          end;

        GIMP_CURVE_FREE:
          begin
            if FCurvesTool.GrabPoint <> (-1) then
            begin
              if FCurvesTool.GrabPoint > xx then
              begin
                x1 := xx;
                x2 := FCurvesTool.GrabPoint;
                y1 := yy;
                y2 := FCurvesTool.Last;
              end
              else
              begin
                x1 := FCurvesTool.GrabPoint;
                x2 := xx;
                y1 := FCurvesTool.Last;
                y2 := yy;
              end;

              if x2 <> x1 then
              begin
                for i := x1 to x2 do
                begin
                  FCurvesTool.Curves.FCurve[FCurvesTool.Channel, i] :=
                    Round(  255 - ( y1 + (y2 - y1) * (i - x1) / (x2 - x1) )  );
                end;
              end
              else
              begin
                FCurvesTool.Curves.FCurve[FCurvesTool.Channel, xx] := 255 - yy;
              end;

              FCurvesTool.GrabPoint := xx;
              FCurvesTool.Last      := yy;
            end;
          end;
      end;

      FCurvesTool.CurvesUpdate(DRAW_X_RANGE or DRAW_GRAPH,
        img32Graph.Bitmap, img32XRange.Bitmap, img32YRange.Bitmap);
    end
    else
    begin  // if mouse left button is released...
      case FCurvesTool.Curves.CurveType[FCurvesTool.Channel] of
        GIMP_CURVE_SMOOTH:
          begin
            { If no point is grabbed...  }
            if FCurvesTool.GrabPoint = (-1) then
            begin
              if FCurvesTool.Curves.Points[FCurvesTool.Channel, ClosestPoint, 0] <> (-1) then
              begin
                Screen.Cursor := crDefault;
              end
              else
              begin
                Screen.Cursor := crSizeAll;
              end;
            end;
          end;

        GIMP_CURVE_FREE:
          begin
            // Do nothing.
          end;
      end;
    end;
    lblCurvesCoord.Caption := Format('X: %d,  Y: %d', [xx, yy]);
  end;
end;

procedure TfrmCurves.GimpCurvesToolMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  i             : Integer;
  tx            : Integer;
  xx            : Integer;
  Width         : Integer;
  Distance      : Integer;
begin
  if FCurvesTool <> nil then
  begin
    FCurvesDrawing := False;

    Width  := img32Graph.Bitmap.Width  - 2 * RADIUS;

    {  get the pointer position  }
    tx := X;
    xx := Round( (tx - RADIUS) / Width  * 255.0);
    xx := CLAMP0255(xx);

    Distance := G_MAXINT;

    for i := 0 to (CURVES_NUM_POINTS - 1) do
    begin
      if FCurvesTool.Curves.Points[FCurvesTool.Channel, i, 0] <> -1 then
      begin
        if Abs(xx - FCurvesTool.Curves.Points[FCurvesTool.Channel, i, 0]) < Distance then
        begin
          Distance := Abs(xx - FCurvesTool.Curves.Points[FCurvesTool.Channel, i, 0]);
        end;
      end;
    end;

    Screen.Cursor         := crDefault;
    FCurvesTool.GrabPoint := -1;

    ExecuteCurves;
  end;  
end;

procedure TfrmCurves.FormCreate(Sender: TObject);
begin
  img32Graph.Bitmap.SetSize(GRAPH_SIZE, GRAPH_SIZE);
  img32XRange.Bitmap.SetSize(GRAPH_SIZE, BAR_SIZE);
  img32YRange.Bitmap.SetSize(BAR_SIZE, GRAPH_SIZE);

  FNormalCurvesTool     := nil;
  FCurvesTool           := nil;
  FCurvesDrawing        := False;
  FCurvesFileName       := '';
  FWorkingOnEffectLayer := False;
end;

procedure TfrmCurves.FormDestroy(Sender: TObject);
begin
  if Assigned(FNormalCurvesTool) then
  begin
    FNormalCurvesTool.Free;
  end;
end;

procedure TfrmCurves.FormShow(Sender: TObject);
var
  LCurvesLayerPanel: TgmCurvesLayerPanel;
  LTempBmp         : TBitmap32;
begin
  // link to the right curves tool
  if (ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfCurves) and
     FWorkingOnEffectLayer then
  begin
    if Assigned(ActiveChildForm.Selection) then
    begin
      if Assigned(ActiveChildForm.SelectionHandleLayer) then
      begin
        ActiveChildForm.SelectionHandleLayer.Visible := False;
      end;
    end;

    LCurvesLayerPanel := TgmCurvesLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

    if LCurvesLayerPanel.CurvesTool <> nil then
    begin
      // Points to the curves which for curves layer.
      FCurvesTool := LCurvesLayerPanel.CurvesTool;

      FCurvesTool.CurvesUpdate(DRAW_ALL, img32Graph.Bitmap,
                               img32XRange.Bitmap, img32YRange.Bitmap);
    end;

    chckbxPreview.Checked := LCurvesLayerPanel.IsPreview;
  end
  else
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
      case ActiveChildForm.ChannelManager.CurrentChannelType of
        wctAlpha:
          begin
            if Assigned(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel) then
            begin
              frmMain.FBeforeProc.Assign(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
              frmMain.FAfterProc.Assign(ActiveChildForm.ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
            end;
          end;

        wctQuickMask:
          begin
            if Assigned(ActiveChildForm.ChannelManager.QuickMaskPanel) then
            begin
              frmMain.FBeforeProc.Assign(ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
              frmMain.FAfterProc.Assign(ActiveChildForm.ChannelManager.QuickMaskPanel.AlphaLayer.Bitmap);
            end;
          end;

        wctLayerMask:
          begin
            frmMain.FBeforeProc.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
            frmMain.FAfterProc.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
          end;

        wctRGB, wctRed, wctGreen, wctBlue:
          begin
            if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
                 lfBackground, lfTransparent] then
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
          end;
      end;
    end;

    if FNormalCurvesTool <> nil then
    begin
      FreeAndNil(FNormalCurvesTool);
    end;

    // Create Curves Tool for normal layer, layer mask, alpha channel...
    FNormalCurvesTool := TgmCurvesTool.Create(frmMain.FBeforeProc);

    // if work with layers...
    if ActiveChildForm.ChannelManager.CurrentChannelType in [
         wctRGB, wctRed, wctGreen, wctBlue] then
    begin
      if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature in [
           lfBackground, lfTransparent] then
      begin
        FNormalCurvesTool.Channel := StrToInt(ReadInfoFromIniFile(SECTION_CURVES_DIALOG, IDENT_CURVES_CHANNEL, '0'));
      end;
    end;

    FNormalCurvesTool.Scale     := TgmGimpHistogramScale(StrToInt(ReadInfoFromIniFile(SECTION_CURVES_DIALOG, IDENT_CURVES_HISTOGRAM, '0')));
    FNormalCurvesTool.CurveType := StrToInt(ReadInfoFromIniFile(SECTION_CURVES_DIALOG, IDENT_CURVES_TYPE, '0'));

    FCurvesTool := FNormalCurvesTool; // Points to the curves which for normal layer, layer mask, alpha channel...

    FCurvesTool.CurvesUpdate(DRAW_ALL, img32Graph.Bitmap, img32XRange.Bitmap,
                             img32YRange.Bitmap);

    chckbxPreview.Checked := Boolean(StrToInt(ReadInfoFromIniFile(SECTION_CURVES_DIALOG, IDENT_CURVES_PREVIEW, '1')));
  end;

  lblCurvesCoord.Caption := '';

  // Change the items in the Channel combobox.
  ChangeChannelItems;

  if Assigned(FCurvesTool) then
  begin
    spdbtnLinearHistogram.Down := (FCurvesTool.Scale = GIMP_HISTOGRAM_SCALE_LINEAR);
    spdbtnLogHistogram.Down    := (FCurvesTool.Scale = GIMP_HISTOGRAM_SCALE_LOGARITHMIC);
    spdbtnSmoothCurve.Down     := (FCurvesTool.CurveType = GIMP_CURVE_SMOOTH);
    spdbtnFreeCurve.Down       := (FCurvesTool.CurveType = GIMP_CURVE_FREE);
  end;

  // Connect mouse events.
  img32Graph.OnMouseDown := GimpCurvesToolMouseDown;
  img32Graph.OnMouseMove := GimpCurvesToolMouseMove;
  img32Graph.OnMouseUp   := GimpCurvesToolMouseUp;

  ActiveControl := btbtnOK;
end;

procedure TfrmCurves.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if FNormalCurvesTool <> nil then
  begin
    FreeAndNil(FNormalCurvesTool);
  end;

  // Disconnect mouse events.
  img32Graph.OnMouseDown := nil;
  img32Graph.OnMouseMove := nil;
  img32Graph.OnMouseUp   := nil;
end; 

procedure TfrmCurves.ChangeCurvesChannel(Sender: TObject);
begin
  if FCurvesTool <> nil then
  begin
    FCurvesTool.Channel := cmbbxCurvesChannel.ItemIndex;

    FCurvesTool.CurvesUpdate(DRAW_X_RANGE or DRAW_Y_RANGE or DRAW_GRAPH,
      img32Graph.Bitmap, img32XRange.Bitmap, img32YRange.Bitmap);
  end;
end; 

procedure TfrmCurves.ChangneCurvesType(Sender: TObject);
var
  CurveType: Integer;
begin
  CurveType := 0;

  if Sender = spdbtnSmoothCurve then
  begin
    CurveType := GIMP_CURVE_SMOOTH;
  end
  else if Sender = spdbtnFreeCurve then
  begin
    CurveType := GIMP_CURVE_FREE;
  end;

  if FCurvesTool <> nil then
  begin
    FCurvesTool.CurveType := CurveType;
    
    FCurvesTool.CurvesUpdate(DRAW_X_RANGE or DRAW_GRAPH,
      img32Graph.Bitmap, img32XRange.Bitmap, img32YRange.Bitmap);
  end;
end;

procedure TfrmCurves.ChangeHistogramType(Sender: TObject);
begin
  if FCurvesTool <> nil then
  begin
    if Sender = spdbtnLinearHistogram then
    begin
      FCurvesTool.Scale := GIMP_HISTOGRAM_SCALE_LINEAR;
    end
    else if Sender = spdbtnLogHistogram then
    begin
      FCurvesTool.Scale := GIMP_HISTOGRAM_SCALE_LOGARITHMIC;
    end;

    FCurvesTool.CurvesUpdate(DRAW_GRAPH, img32Graph.Bitmap,
                             img32XRange.Bitmap, img32YRange.Bitmap);
  end;
end; 

procedure TfrmCurves.btnCurvesResetAllChannelsClick(Sender: TObject);
begin
  if FCurvesTool <> nil then
  begin
    FCurvesTool.CurvesAllChannelReset;

    FCurvesTool.CurvesUpdate(DRAW_X_RANGE or DRAW_GRAPH, img32Graph.Bitmap,
                             img32XRange.Bitmap, img32YRange.Bitmap);

    ExecuteCurves;
  end;
end;

procedure TfrmCurves.btnCurveChannelRestClick(Sender: TObject);
begin
  if FCurvesTool <> nil then
  begin
    FCurvesTool.CurvesCurrentChannelReset;

    FCurvesTool.CurvesUpdate(DRAW_X_RANGE or DRAW_GRAPH, img32Graph.Bitmap,
                             img32XRange.Bitmap, img32YRange.Bitmap);

    ExecuteCurves;
  end;
end;

procedure TfrmCurves.chckbxPreviewClick(Sender: TObject);
begin
  ExecuteCurves;
end; 

procedure TfrmCurves.btbtnOKClick(Sender: TObject);
var
  LCmdAim           : TCommandAim;
  LHistoryStatePanel: TgmHistoryStatePanel;
  LCurvesLayerPanel : TgmCurvesLayerPanel;
begin
  with ActiveChildForm do
  begin
    if (LayerPanelList.SelectedLayerPanel.LayerFeature = lfCurves) and
       FWorkingOnEffectLayer then
    begin
      // if this curves tool for curves layer...
      LCurvesLayerPanel := TgmCurvesLayerPanel(LayerPanelList.SelectedLayerPanel);
      LCurvesLayerPanel.IsPreview := chckbxPreview.Checked;
    end
    else
    begin
      // the processed result is stored in frmMain.FAfterProc
      if LayerPanelList.SelectedLayerPanel.IsMaskLinked then
      begin
        if (LayerPanelList.SelectedLayerPanel.LayerFeature in [lfBackground, lfTransparent]) and
           (ChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue]) then
        begin
          ReplaceAlphaChannelWithMask(frmMain.FAfterProc,
            LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
        end;
      end;

      // undo/redo
      LCmdAim := GetCommandAimByCurrentChannel;

      LHistoryStatePanel := TgmImageManipulatingStatePanel.Create(
        frmHistory.scrlbxHistory,
        dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
        LCmdAim,
        'Curves',
        frmMain.FBeforeProc,
        frmMain.FAfterProc,
        Selection,
        ChannelManager.SelectedAlphaChannelIndex);

      HistoryManager.AddHistoryState(LHistoryStatePanel);

      // save settings to INI file
      if Assigned(FCurvesTool) then
      begin
        if ChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue] then
        begin
          WriteInfoToIniFile(SECTION_CURVES_DIALOG, IDENT_CURVES_CHANNEL, IntToStr(FCurvesTool.Channel));
        end;

        WriteInfoToIniFile(SECTION_CURVES_DIALOG, IDENT_CURVES_HISTOGRAM, IntToStr(Ord(FCurvesTool.Scale)));
        WriteInfoToIniFile(SECTION_CURVES_DIALOG, IDENT_CURVES_TYPE,      IntToStr(FCurvesTool.CurveType));
      end;

      WriteInfoToIniFile(SECTION_CURVES_DIALOG, IDENT_CURVES_PREVIEW, IntToStr(Integer(chckbxPreview.Checked)));
    end;
  end;
end;

procedure TfrmCurves.btnLoadCurvesClick(Sender: TObject);
begin
  if Assigned(FCurvesTool) then
  begin
    OpenDialog.InitialDir := ReadInfoFromIniFile(SECTION_CURVES_DIALOG, IDENT_CURVES_FILE_DIR, ExtractFilePath( ParamStr(0) ));

    if OpenDialog.Execute then
    begin
      Screen.Cursor   := crHourGlass;
      try
        FCurvesFileName := OpenDialog.FileName;
        try
          { The following methold must be called first, otherwise, the
            FCurvesTool.LoadFormFile() will causes an exception. The reason for
            why is not clear, yet. }
          btnCurvesResetAllChannelsClick(Sender);

          if FCurvesTool.LoadFromFile(FCurvesFileName) then
          begin
            if cmbbxCurvesChannel.Items.Count > 1 then
            begin
              cmbbxCurvesChannel.ItemIndex := FCurvesTool.Channel;
            end
            else
            begin
              cmbbxCurvesChannel.ItemIndex := 0;
              ChangeCurvesChannel(Sender);
            end;

            FCurvesTool.CurvesUpdate(DRAW_ALL, img32Graph.Bitmap,
                                     img32XRange.Bitmap, img32YRange.Bitmap);

            spdbtnLinearHistogram.Down := (FCurvesTool.Scale = GIMP_HISTOGRAM_SCALE_LINEAR);
            spdbtnLogHistogram.Down    := (FCurvesTool.Scale = GIMP_HISTOGRAM_SCALE_LOGARITHMIC);
            spdbtnSmoothCurve.Down     := (FCurvesTool.CurveType = GIMP_CURVE_SMOOTH);
            spdbtnFreeCurve.Down       := (FCurvesTool.CurveType = GIMP_CURVE_FREE);

            ExecuteCurves;

            WriteInfoToIniFile(SECTION_CURVES_DIALOG, IDENT_CURVES_FILE_DIR,
                               ExtractFilePath(FCurvesFileName));
          end
          else // loadding error
          begin
            MessageDlg(FCurvesTool.OutputMsg, mtError, [mbOK], 0);
          end;

        except
          MessageDlg('Cannot open the file "' + ExtractFileName(OpenDialog.FileName) + '".', mtError, [mbOK], 0)
        end;
        
      finally
        Screen.Cursor := crDefault;
      end;
    end;
  end;
end;

procedure TfrmCurves.btnSaveCurvesClick(Sender: TObject);
var
  FileDir       : string;
  FileExt       : string;
  OutputFileName: string;
begin
  if Assigned(FCurvesTool) then
  begin
    if FCurvesFileName = '' then
    begin
      SaveDialog.FileName := 'Untitled' + CURVES_FILE_EXT;
    end
    else
    begin
      SaveDialog.FileName := ExtractFileName(FCurvesFileName);
    end;

    SaveDialog.InitialDir := ReadInfoFromIniFile(SECTION_CURVES_DIALOG, IDENT_CURVES_FILE_DIR, ExtractFilePath( ParamStr(0) ));
    if SaveDialog.Execute then
    begin
      Screen.Cursor := crHourGlass;
      try
        OutputFileName := SaveDialog.FileName;
        FileDir        := ExtractFileDir(OutputFileName);

        if (FileDir <> '') and DirectoryExists(FileDir) then
        begin
          FileExt := ExtractFileExt(OutputFileName);

          if FileExt = '' then
          begin
            OutputFileName := OutputFileName + CURVES_FILE_EXT;
          end
          else
          if FileExt <> CURVES_FILE_EXT then
          begin
            OutputFileName := ChangeFileExt(OutputFileName, CURVES_FILE_EXT);
          end;

          if FileExists(OutputFileName) then
          begin
            if MessageDlg('The file "' + ExtractFileName(OutputFileName) + '" is already exists.' + #10#13 +
                          'Do you want to replace it?', mtConfirmation, mbOKCancel, 0) <> mrOK then
            begin
              Exit;
            end;
          end;

          FCurvesTool.SaveToFile(SaveDialog.FileName);

          FCurvesFileName := SaveDialog.FileName;
          WriteInfoToIniFile(SECTION_CURVES_DIALOG, IDENT_CURVES_FILE_DIR, ExtractFilePath(FCurvesFileName));
        end;
        
      finally
        Screen.Cursor := crDefault;
      end;
    end;
  end;
end; 

end.
