{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

unit PrintOptionsDlg;

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
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Buttons, GR32_Image, gmTypes, gmPrintOptions;

type
  TfrmPrintOptions = class(TForm)
    pnlPrintOptionsPreview: TPanel;
    grpbxPrintPosition: TGroupBox;
    lblTopPos: TLabel;
    lblLeftPos: TLabel;
    edtTopPos: TEdit;
    edtLeftPos: TEdit;
    cmbbxTopPosUnit: TComboBox;
    cmbbxLeftPosUnit: TComboBox;
    chckbxCenterImage: TCheckBox;
    grpbxPrintScaled: TGroupBox;
    lblPrintScale: TLabel;
    lblPrintHeight: TLabel;
    lblPrintWidth: TLabel;
    edtPrintScale: TEdit;
    edtPrintHeight: TEdit;
    edtPrintWidth: TEdit;
    cmbbxPrintWidthUnit: TComboBox;
    cmbbxPrintHeightUnit: TComboBox;
    btbtnOK: TBitBtn;
    btbtnCancel: TBitBtn;
    chckbxFitMedia: TCheckBox;
    lblScalePercent: TLabel;
    imgPrintOptionsPreview: TImage32;
    btnPageSetup: TButton;
    btnPrintImage: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure chckbxCenterImageClick(Sender: TObject);
    procedure edtLeftPosChange(Sender: TObject);
    procedure edtTopPosChange(Sender: TObject);
    procedure edtPrintHeightChange(Sender: TObject);
    procedure edtPrintWidthChange(Sender: TObject);
    procedure edtPrintScaleChange(Sender: TObject);
    procedure cmbbxTopPosUnitChange(Sender: TObject);
    procedure cmbbxLeftPosUnitChange(Sender: TObject);
    procedure cmbbxPrintHeightUnitChange(Sender: TObject);
    procedure cmbbxPrintWidthUnitChange(Sender: TObject);
    procedure chckbxFitMediaClick(Sender: TObject);
    procedure btnPageSetupClick(Sender: TObject);
    procedure btnPrintImageClick(Sender: TObject);
    procedure edtTopPosExit(Sender: TObject);
    procedure edtLeftPosExit(Sender: TObject);
    procedure edtPrintHeightExit(Sender: TObject);
    procedure edtPrintWidthExit(Sender: TObject);
    procedure btbtnOKClick(Sender: TObject);
  private
    FCanSetLeft  : Boolean;
    FCanSetTop   : Boolean;
    FCanSetWidth : Boolean;
    FCanSetHeight: Boolean;
    FCanSetScale : Boolean;
    FTopUnit     : TgmAppliedUnit;
    FLeftUnit    : TgmAppliedUnit;
    FWidthUnit   : TgmAppliedUnit;
    FHeightUnit  : TgmAppliedUnit;
    FPrintOptions: TgmPrintOptions;

    procedure ChangeEditBackgroundColor;
    procedure ShowLeftValue;
    procedure ShowTopValue;
    procedure ShowWidthValue;
    procedure ShowHeightValue;
    procedure ShowScaleValue;
  public
    procedure ShowPrintThumbnial;

    property PrintOptions: TgmPrintOptions read FPrintOptions;
  end;

var
  frmPrintOptions: TfrmPrintOptions;

implementation

uses
{ Graphics32 }
  GR32,
{ externals }
  Preview,
{ GraphicsMagic Lib }
  gmIni,
  gmImageProcessFuncs,
  gmMath,
  gmGUIFuncs,
{ GraphicsMagic Forms/Dialogs }
  MainForm,
  PrintPreviewDlg;

const
  PREVIEW_WIDTH  = 192;
  PREVIEW_HEIGHT = 256;

{$R *.DFM}

procedure TfrmPrintOptions.ChangeEditBackgroundColor;
begin
  if edtTopPos.Enabled then
  begin
    edtTopPos.Color := clWhite;
  end
  else
  begin
    edtTopPos.Color := clBtnFace;
  end;

  if edtLeftPos.Enabled then
  begin
    edtLeftPos.Color := clWhite;
  end
  else
  begin
    edtLeftPos.Color := clBtnFace;
  end;

  if edtPrintScale.Enabled then
  begin
    edtPrintScale.Color := clWhite;
  end
  else
  begin
    edtPrintScale.Color := clBtnFace;
  end;

  if edtPrintHeight.Enabled then
  begin
    edtPrintHeight.Color := clWhite;
  end
  else
  begin
    edtPrintHeight.Color := clBtnFace;
  end;

  if edtPrintWidth.Enabled then
  begin
    edtPrintWidth.Color := clWhite;
  end
  else
  begin
    edtPrintWidth.Color := clBtnFace;
  end;
end; 

procedure TfrmPrintOptions.ShowLeftValue;
begin
  FCanSetLeft := False;
  try
    case FLeftUnit of
      auInch      : edtLeftPos.Text := FloatToStr(FPrintOptions.LeftInch);
      auCentimeter: edtLeftPos.Text := FloatToStr(FPrintOptions.LeftCM);
      auPoint     : edtLeftPos.Text := FloatToStr(FPrintOptions.LeftPoint);
      auPixel     : edtLeftPos.Text := IntToStr(FPrintOptions.LeftPixel);
    end;
  finally
    FCanSetLeft := True;
  end;
end; 

procedure TfrmPrintOptions.ShowTopValue;
begin
  FCanSetTop := False;
  try
    case FTopUnit of
      auInch      : edtTopPos.Text := FloatToStr(FPrintOptions.TopInch);
      auCentimeter: edtTopPos.Text := FloatToStr(FPrintOptions.TopCM);
      auPoint     : edtTopPos.Text := FloatToStr(FPrintOptions.TopPoint);
      auPixel     : edtTopPos.Text := IntToStr(FPrintOptions.TopPixel);
    end;
  finally
    FCanSetTop := True;
  end;
end; 

procedure TfrmPrintOptions.ShowWidthValue;
begin
  FCanSetWidth := False;
  try
    case FWidthUnit of
      auInch      : edtPrintWidth.Text := FloatToStr(FPrintOptions.WidthInch);
      auCentimeter: edtPrintWidth.Text := FloatToStr(FPrintOptions.WidthCM);
      auPoint     : edtPrintWidth.Text := FloatToStr(FPrintOptions.WidthPoint);
      auPixel     : edtPrintWidth.Text := IntToStr(FPrintOptions.WidthPixel);
    end;
  finally
    FCanSetWidth := True;
  end;
end; 

procedure TfrmPrintOptions.ShowHeightValue;
begin
  FCanSetHeight := False;
  try
    case FHeightUnit of
      auInch      : edtPrintHeight.Text := FloatToStr(FPrintOptions.HeightInch);
      auCentimeter: edtPrintHeight.Text := FloatToStr(FPrintOptions.HeightCM);
      auPoint     : edtPrintHeight.Text := FloatToStr(FPrintOptions.HeightPoint);
      auPixel     : edtPrintHeight.Text := IntToStr(FPrintOptions.HeightPixel);
    end;
  finally
    FCanSetHeight := True;
  end;
end;

procedure TfrmPrintOptions.ShowScaleValue;
begin
  FCanSetScale := False;
  try
    edtPrintScale.Text := FloatToStr(FPrintOptions.Scale);
  finally
    FCanSetScale := True;
  end;
end; 

procedure TfrmPrintOptions.ShowPrintThumbnial;
var
  LTempBitmap: TBitmap32;
begin
  if ActiveChildForm.LayerPanelList.Count > 1 then
  begin
    ActiveChildForm.LayerPanelList.FlattenLayersToBitmap(FPrintOptions.SourceBitmap);
  end
  else
  begin
    LTempBitmap := TBitmap32.Create;
    try
      LTempBitmap.Assign(ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);
      LTempBitmap.DrawMode := dmBlend;

      // convert the transparent area to white
      MergeBitmapToColoredBackground(LTempBitmap, clWhite32);
      FPrintOptions.SourceBitmap.Assign(LTempBitmap);
      FPrintOptions.SourceBitmap.PixelFormat := pf24bit;
    finally
      LTempBitmap.Free;
    end;
  end;

  FPrintOptions.SetPaperSize(frmPrintPreview.prntprvwPreview.PaperWidth,
                             frmPrintPreview.prntprvwPreview.PaperHeight);
                             
  imgPrintOptionsPreview.Bitmap.Assign(FPrintOptions.Paper);

  ScaleImage32(imgPrintOptionsPreview.Bitmap, imgPrintOptionsPreview,
               PREVIEW_WIDTH, PREVIEW_HEIGHT);
               
  CenterImageInPanel(pnlPrintOptionsPreview, imgPrintOptionsPreview);

  if FPrintOptions.IsFitToMedia then
  begin
    FPrintOptions.SetFitToMedia(True);
  end;
  
  FPrintOptions.DrawPrintBitmap(imgPrintOptionsPreview.Bitmap);
end; 

procedure TfrmPrintOptions.FormCreate(Sender: TObject);
begin
  FPrintOptions := TgmPrintOptions.Create;

  FCanSetLeft   := True;
  FCanSetTop    := True;
  FCanSetWidth  := True;
  FCanSetHeight := True;
  FCanSetScale  := True;

  FTopUnit    := TgmAppliedUnit(StrToInt(ReadInfoFromIniFile(SECTION_PRINT_OPTIONS_DIALOG, IDENT_PRINT_OPTIONS_TOP_UNIT,    '1')));
  FLeftUnit   := TgmAppliedUnit(StrToInt(ReadInfoFromIniFile(SECTION_PRINT_OPTIONS_DIALOG, IDENT_PRINT_OPTIONS_LEFT_UNIT,   '1')));
  FWidthUnit  := TgmAppliedUnit(StrToInt(ReadInfoFromIniFile(SECTION_PRINT_OPTIONS_DIALOG, IDENT_PRINT_OPTIONS_WIDTH_UNIT,  '1')));
  FHeightUnit := TgmAppliedUnit(StrToInt(ReadInfoFromIniFile(SECTION_PRINT_OPTIONS_DIALOG, IDENT_PRINT_OPTIONS_HEIGHT_UNIT, '1')));

  cmbbxTopPosUnit.ItemIndex      := Ord(FTopUnit);
  cmbbxLeftPosUnit.ItemIndex     := Ord(FLeftUnit);
  cmbbxPrintWidthUnit.ItemIndex  := Ord(FWidthUnit);
  cmbbxPrintHeightUnit.ItemIndex := Ord(FHeightUnit);
  edtTopPos.Enabled              := not chckbxCenterImage.Checked;
  edtLeftPos.Enabled             := not chckbxCenterImage.Checked;
  chckbxCenterImage.Enabled      := not chckbxFitMedia.Checked;

  ChangeEditBackgroundColor;
end;

procedure TfrmPrintOptions.FormDestroy(Sender: TObject);
begin
  FPrintOptions.Free;
end; 

procedure TfrmPrintOptions.FormShow(Sender: TObject);
begin
  ShowPrintThumbnial;
  ShowTopValue;
  ShowLeftValue;
  ShowScaleValue;
  ShowWidthValue;
  ShowHeightValue;

  chckbxCenterImage.Checked := FPrintOptions.IsCenterImage;
end; 

procedure TfrmPrintOptions.chckbxCenterImageClick(Sender: TObject);
begin
  FPrintOptions.IsCenterImage := chckbxCenterImage.Checked;
  edtTopPos.Enabled           := not chckbxCenterImage.Checked;
  edtLeftPos.Enabled          := not chckbxCenterImage.Checked;

  ChangeEditBackgroundColor;

  if chckbxCenterImage.Checked then
  begin
    FPrintOptions.DrawPrintBitmap(imgPrintOptionsPreview.Bitmap);
    ShowLeftValue;
    ShowTopValue;
  end;
end; 

procedure TfrmPrintOptions.edtLeftPosChange(Sender: TObject);
var
  RealVal: Double;
begin
  RealVal := 0.00;
  
  if FCanSetLeft then
  begin
    if FLeftUnit in [auInch, auCentimeter, auPoint] then
    begin
      try
        RealVal := StrToFloat(edtLeftPos.Text);
      except
        case FTopUnit of
          auInch      : RealVal := FPrintOptions.LeftInch;
          auCentimeter: RealVal := FPrintOptions.LeftCM;
          auPoint     : RealVal := FPrintOptions.LeftPoint;
        end;

        ShowLeftValue;
      end;
    end;

    case FLeftUnit of
      auInch      : FPrintOptions.LeftInch  := RealVal;
      auCentimeter: FPrintOptions.LeftCM    := RealVal;
      auPoint     : FPrintOptions.LeftPoint := RealVal;
      auPixel:
        begin
          try
            FPrintOptions.LeftPixel := StrToInt(edtLeftPos.Text);
          except
            ShowLeftValue;
          end;
        end;
    end;
    
    FPrintOptions.DrawPrintBitmap(imgPrintOptionsPreview.Bitmap);
  end;
end; 

procedure TfrmPrintOptions.edtTopPosChange(Sender: TObject);
var
  RealVal: Double;
begin
  RealVal := 0.00;
  
  if FCanSetTop then
  begin
    if FTopUnit in [auInch, auCentimeter, auPoint] then
    begin
      try
        RealVal := StrToFloat(edtTopPos.Text);
      except
        case FTopUnit of
          auInch      : RealVal := FPrintOptions.TopInch;
          auCentimeter: RealVal := FPrintOptions.TopCM;
          auPoint     : RealVal := FPrintOptions.TopPoint;
        end;
        
        ShowTopValue;
      end;
    end;

    case FTopUnit of
      auInch      : FPrintOptions.TopInch  := RealVal;
      auCentimeter: FPrintOptions.TopCM    := RealVal;
      auPoint     : FPrintOptions.TopPoint := RealVal;
      auPixel:
        begin
          try
            FPrintOptions.TopPixel := StrToInt(edtTopPos.Text);
          except
            ShowTopValue;
          end;
        end;
    end;
    
    FPrintOptions.DrawPrintBitmap(imgPrintOptionsPreview.Bitmap);
  end;
end; 

procedure TfrmPrintOptions.edtPrintHeightChange(Sender: TObject);
var
  RealVal: Double;
begin
  RealVal := 0.00;
    
  if FCanSetHeight then
  begin
    if FHeightUnit in [auInch, auCentimeter, auPoint] then
    begin
      try
        RealVal := StrToFloat(edtPrintHeight.Text);
      except
        case FTopUnit of
          auInch      : RealVal := FPrintOptions.HeightInch;
          auCentimeter: RealVal := FPrintOptions.HeightCM;
          auPoint     : RealVal := FPrintOptions.HeightPoint;
        end;
        
        ShowHeightValue;
      end;
    end;

    case FHeightUnit of
      auInch      : FPrintOptions.HeightInch  := RealVal;
      auCentimeter: FPrintOptions.HeightCM    := RealVal;
      auPoint     : FPrintOptions.HeightPoint := RealVal;
      auPixel:
        begin
          try
            FPrintOptions.HeightPixel := StrToInt(edtPrintHeight.Text);
          except
            ShowHeightValue;
          end;
        end;
    end;

    FPrintOptions.DrawPrintBitmap(imgPrintOptionsPreview.Bitmap);

    { We calculated the new coordinates when drawing bitmap, so we need to
      show respective information after drawing. }
    if chckbxCenterImage.Checked then
    begin
      ShowTopValue;
    end;

    ShowWidthValue;
    ShowScaleValue;
  end;
end; 

procedure TfrmPrintOptions.edtPrintWidthChange(Sender: TObject);
var
  RealVal: Double;
begin
  RealVal := 0.00;
  
  if FCanSetWidth then
  begin
    if FWidthUnit in [auInch, auCentimeter, auPoint] then
    begin
      try
        RealVal := StrToFloat(edtPrintWidth.Text);
      except
        case FTopUnit of
          auInch      : RealVal := FPrintOptions.WidthInch;
          auCentimeter: RealVal := FPrintOptions.WidthCM;
          auPoint     : RealVal := FPrintOptions.WidthPoint;
        end;

        ShowWidthValue;
      end;
    end;

    case FWidthUnit of
      auInch      : FPrintOptions.WidthInch  := RealVal;
      auCentimeter: FPrintOptions.WidthCM    := RealVal;
      auPoint     : FPrintOptions.WidthPoint := RealVal;
      auPixel:
        begin
          try
            FPrintOptions.WidthPixel := StrToInt(edtPrintWidth.Text);
          except
            ShowWidthValue;
          end;
        end;
    end;

    FPrintOptions.DrawPrintBitmap(imgPrintOptionsPreview.Bitmap);

    { We calculated the new coordinates when drawing bitmap, so we need to
      show respective information after drawing. }
    if chckbxCenterImage.Checked then
    begin
      ShowLeftValue;
    end;

    ShowHeightValue;
    ShowScaleValue;
  end;
end; 

procedure TfrmPrintOptions.edtPrintScaleChange(Sender: TObject);
var
  Scale: Double;
begin
  if FCanSetScale then
  begin
    try
      Scale := StrToFloat(edtPrintScale.Text);
      EnsureValueInRange(Scale, 1.0, 1000.0);
      FPrintOptions.Scale := Scale;
      FPrintOptions.DrawPrintBitmap(imgPrintOptionsPreview.Bitmap);
      ShowScaleValue;
    except
      ShowScaleValue;
    end;
    
    if chckbxCenterImage.Checked then
    begin
      ShowTopValue;
      ShowLeftValue;
    end;

    ShowHeightValue;
    ShowWidthValue;
  end;
end;

procedure TfrmPrintOptions.cmbbxTopPosUnitChange(Sender: TObject);
begin
  FTopUnit := TgmAppliedUnit(cmbbxTopPosUnit.ItemIndex);
  ShowTopValue;
end; 

procedure TfrmPrintOptions.cmbbxLeftPosUnitChange(Sender: TObject);
begin
  FLeftUnit := TgmAppliedUnit(cmbbxLeftPosUnit.ItemIndex);
  ShowLeftValue;
end;

procedure TfrmPrintOptions.cmbbxPrintHeightUnitChange(Sender: TObject);
begin
  FHeightUnit := TgmAppliedUnit(cmbbxPrintHeightUnit.ItemIndex);
  ShowHeightValue;
end;

procedure TfrmPrintOptions.cmbbxPrintWidthUnitChange(Sender: TObject);
begin
  FWidthUnit := TgmAppliedUnit(cmbbxPrintWidthUnit.ItemIndex);
  ShowWidthValue;
end;

procedure TfrmPrintOptions.chckbxFitMediaClick(Sender: TObject);
begin
  FPrintOptions.IsFitToMedia  := chckbxFitMedia.Checked;
  chckbxCenterImage.Checked   := True;
  chckbxCenterImage.Enabled   := not chckbxFitMedia.Checked;
  FPrintOptions.IsCenterImage := chckbxCenterImage.Checked;
  edtTopPos.Enabled           := not chckbxCenterImage.Checked;
  edtLeftPos.Enabled          := not chckbxCenterImage.Checked;
  edtPrintHeight.Enabled      := not chckbxFitMedia.Checked;
  edtPrintWidth.Enabled       := not chckbxFitMedia.Checked;
  edtPrintScale.Enabled       := not chckbxFitMedia.Checked;

  ChangeEditBackgroundColor;

  if chckbxFitMedia.Checked then
  begin
    FPrintOptions.DrawPrintBitmap(imgPrintOptionsPreview.Bitmap);
    ShowTopValue;
    ShowLeftValue;
    ShowHeightValue;
    ShowWidthValue;
    ShowScaleValue;
  end;
end; 

procedure TfrmPrintOptions.btnPageSetupClick(Sender: TObject);
begin
  if frmMain.PrinterSetupDialog.Execute then
  begin
    { The following routines must be called after the printer is set properly,
      and these routines could make the print preview take effect. }
    frmPrintPreview.prntprvwPreview.BeginDoc;
    frmPrintPreview.prntprvwPreview.EndDoc;

    ShowPrintThumbnial;
    ShowTopValue;
    ShowLeftValue;
    ShowScaleValue;
    ShowWidthValue;
    ShowHeightValue;
  end;
end; 

procedure TfrmPrintOptions.btnPrintImageClick(Sender: TObject);
begin
  frmPrintPreview.DrawBitmapOnPreview;
  
  if frmPrintPreview.prntprvwPreview.State = psReady then
  begin
    if frmMain.PrintDialog.Execute then
    begin
      frmPrintPreview.prntprvwPreview.Print;
    end;
  end;
end;

procedure TfrmPrintOptions.edtTopPosExit(Sender: TObject);
begin
  ShowTopValue;
end;

procedure TfrmPrintOptions.edtLeftPosExit(Sender: TObject);
begin
  ShowLeftValue;
end;

procedure TfrmPrintOptions.edtPrintHeightExit(Sender: TObject);
begin
  ShowHeightValue;
end;

procedure TfrmPrintOptions.edtPrintWidthExit(Sender: TObject);
begin
  ShowWidthValue;
end;

procedure TfrmPrintOptions.btbtnOKClick(Sender: TObject);
begin
  WriteInfoToIniFile(SECTION_PRINT_OPTIONS_DIALOG, IDENT_PRINT_OPTIONS_TOP_UNIT,    IntToStr(Ord(FTopUnit)));
  WriteInfoToIniFile(SECTION_PRINT_OPTIONS_DIALOG, IDENT_PRINT_OPTIONS_LEFT_UNIT,   IntToStr(Ord(FLeftUnit)));
  WriteInfoToIniFile(SECTION_PRINT_OPTIONS_DIALOG, IDENT_PRINT_OPTIONS_WIDTH_UNIT,  IntToStr(Ord(FWidthUnit)));
  WriteInfoToIniFile(SECTION_PRINT_OPTIONS_DIALOG, IDENT_PRINT_OPTIONS_HEIGHT_UNIT, IntToStr(Ord(FHeightUnit)));
end;

end.
