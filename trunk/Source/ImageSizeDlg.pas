{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

unit ImageSizeDlg;

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
  StdCtrls, Buttons, GR32, GR32_Image, GR32_Resamplers, GR32_RangeBars,
  gmTypes, gmResamplers;

type
  TfrmImageSize = class(TForm)
    grpbxImageSize: TGroupBox;
    edtImageWidth: TEdit;
    lblImageWidth: TLabel;
    lblImageHeight: TLabel;
    edtImageHeight: TEdit;
    btbtnOK: TBitBtn;
    btbtnCancel: TBitBtn;
    cmbbxWidthUnit: TComboBox;
    cmbbxHeightUnit: TComboBox;
    imgvwChain: TImgView32;
    chckbxConstrainProperties: TCheckBox;
    grpbxResamplingOptions: TGroupBox;
    lblResampler: TLabel;
    cmbbxResampler: TComboBox;
    lblPAM: TLabel;
    lblWrapMode: TLabel;
    cmbbxPAM: TComboBox;
    cmbbxWrapMode: TComboBox;
    grpbxKernelOptions: TGroupBox;
    lblKernel: TLabel;
    lblKernelMode: TLabel;
    lblTableSize: TLabel;
    cmbbxKernel: TComboBox;
    cmbbxKernelMode: TComboBox;
    ggbrTableSize: TGaugeBar;
    procedure FormShow(Sender: TObject);
    procedure cmbbxWidthUnitChange(Sender: TObject);
    procedure cmbbxHeightUnitChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtImageWidthExit(Sender: TObject);
    procedure edtImageHeightExit(Sender: TObject);
    procedure edtImageWidthChange(Sender: TObject);
    procedure edtImageHeightChange(Sender: TObject);
    procedure chckbxConstrainPropertiesClick(Sender: TObject);
    procedure cmbbxResamplerChange(Sender: TObject);
    procedure cmbbxPAMChange(Sender: TObject);
    procedure cmbbxWrapModeChange(Sender: TObject);
    procedure cmbbxKernelChange(Sender: TObject);
    procedure cmbbxKernelModeChange(Sender: TObject);
    procedure ggbrTableSizeChange(Sender: TObject);
    procedure btbtnOKClick(Sender: TObject);
  private
    FCanChange          : Boolean;
    FConstrainProperties: Boolean;
    FOriginalWidth      : Integer;
    FOriginalHeight     : Integer;
    FNewWidth           : Integer;
    FNewHeight          : Integer;
    FWidthUnit          : TgmAppliedUnit;
    FHeightUnit         : TgmAppliedUnit;
    FResamplingOptions  : TgmResamplingOptions;

    function GetWidthByInch: Double;
    function GetWidthByCM: Double;
    function GetWidthByPoint: Double;
    function GetHeightByInch: Double;
    function GetHeightByCM: Double;
    function GetHeightByPoint: Double;

    procedure SetWidthByInch(const AWidth: Double);
    procedure SetWidthByCM(const AWidth: Double);
    procedure SetWidthByPoint(const AWidth: Double);
    procedure SetHeightByInch(const AHeight: Double);
    procedure SetHeightByCM(const AHeight: Double);
    procedure SetHeightByPoint(const AHeight: Double);

    procedure ShowWidth;
    procedure ShowHeight;
    procedure UpdateKernelOptionsDisplay;
  public
    property NewWidth         : Integer              read FNewWidth;
    property NewHeight        : Integer              read FNewHeight;
    property ResamplingOptions: TgmResamplingOptions read FResamplingOptions;
  end;

var
  frmImageSize: TfrmImageSize;

implementation

uses
{ Standard }
  Printers,
{ Graphics32 }
  GR32_Layers,
{ externals -- Preview }
  Preview,
{ GraphicsMagic Lib }
  gmIni,
  gmMath,
{ GraphicsMagic Forms/Dialogs }
  MainForm,
  PrintPreviewDlg;

{$R *.DFM}

{ Custom procedures and functions }

function TfrmImageSize.GetWidthByInch: Double;
begin
  Result := frmPrintPreview.prntprvwPreview.ConvertX(FNewWidth, mmPixel, mmLoEnglish) / 100;
end;

function TfrmImageSize.GetWidthByCM: Double;
begin
  Result := frmPrintPreview.prntprvwPreview.ConvertX(FNewWidth, mmPixel, mmLoMetric) / 100;
end;

function TfrmImageSize.GetWidthByPoint: Double;
var
  Inches: Double;
begin
  Inches := frmPrintPreview.prntprvwPreview.ConvertX(FNewWidth, mmPixel, mmLoEnglish) / 100;
  Result := Inches * 72;
end;

function TfrmImageSize.GetHeightByInch: Double;
begin
  Result := frmPrintPreview.prntprvwPreview.ConvertY(FNewHeight, mmPixel, mmLoEnglish) / 100;
end;

function TfrmImageSize.GetHeightByCM: Double;
begin
  Result := frmPrintPreview.prntprvwPreview.ConvertY(FNewHeight, mmPixel, mmLoMetric) / 100;
end;

function TfrmImageSize.GetHeightByPoint: Double;
var
  Inches: Double;
begin
  Inches := frmPrintPreview.prntprvwPreview.ConvertY(FNewHeight, mmPixel, mmLoEnglish) / 100;
  Result := Inches * 72;
end; 

procedure TfrmImageSize.SetWidthByInch(const AWidth: Double);
var
  w: Integer;
begin
  w         := Round(AWidth * 100); // convert to mmLoEnglish unit
  FNewWidth := frmPrintPreview.prntprvwPreview.ConvertX(w, mmLoEnglish, mmPixel);
end;

procedure TfrmImageSize.SetWidthByCM(const AWidth: Double);
var
  w: Integer;
begin
  w         := Round(AWidth * 100); // convert to mmLoMetric unit
  FNewWidth := frmPrintPreview.prntprvwPreview.ConvertX(w, mmLoMetric, mmPixel);
end;

procedure TfrmImageSize.SetWidthByPoint(const AWidth: Double);
var
  LoEnglishVal: Integer;
begin
  LoEnglishVal := Round(AWidth / 72 * 100); // convert to mmLoEnglish unit
  FNewWidth    := frmPrintPreview.prntprvwPreview.ConvertX(LoEnglishVal, mmLoEnglish, mmPixel);
end;

procedure TfrmImageSize.SetHeightByInch(const AHeight: Double);
var
  h: Integer;
begin
  h          := Round(AHeight * 100); // convert to mmLoEnglish unit
  FNewHeight := frmPrintPreview.prntprvwPreview.ConvertY(h, mmLoEnglish, mmPixel);
end;

procedure TfrmImageSize.SetHeightByCM(const AHeight: Double);
var
  h: Integer;
begin
  h          := Round(AHeight * 100); // convert to mmLoMetric unit
  FNewHeight := frmPrintPreview.prntprvwPreview.ConvertY(h, mmLoMetric, mmPixel);
end;

procedure TfrmImageSize.SetHeightByPoint(const AHeight: Double);
var
  LoEnglishVal: Integer;
begin
  LoEnglishVal := Round(AHeight / 72 * 100); // convert to mmLoEnglish unit
  FNewHeight   := frmPrintPreview.prntprvwPreview.ConvertY(LoEnglishVal, mmLoEnglish, mmPixel);
end;

procedure TfrmImageSize.ShowWidth;
begin
  FCanChange := False;
  try
    case FWidthUnit of
      auInch      : edtImageWidth.Text := FloatToStr(GetWidthByInch);
      auCentimeter: edtImageWidth.Text := FloatToStr(GetWidthByCM);
      auPoint     : edtImageWidth.Text := FloatToStr(GetWidthByPoint);
      auPixel     : edtImageWidth.Text := IntToStr(FNewWidth);
    end;
  finally
    FCanChange := True;
  end;
end;

procedure TfrmImageSize.ShowHeight;
begin
  FCanChange := False;
  try
    case FHeightUnit of
      auInch      : edtImageHeight.Text := FloatToStr(GetHeightByInch);
      auCentimeter: edtImageHeight.Text := FloatToStr(GetHeightByCM);
      auPoint     : edtImageHeight.Text := FloatToStr(GetHeightByPoint);
      auPixel     : edtImageHeight.Text := IntToStr(FNewHeight);
    end;
  finally
    FCanChange := True;
  end;
end;

procedure TfrmImageSize.UpdateKernelOptionsDisplay;
begin
  if FResamplingOptions.Resampler = rsKernel then
  begin
    grpbxKernelOptions.Visible := True;
    frmImageSize.Height        := grpbxKernelOptions.Top + grpbxKernelOptions.Height + 55;
  end
  else
  begin
    grpbxKernelOptions.Visible := False;
    frmImageSize.Height        := grpbxResamplingOptions.Top + grpbxResamplingOptions.Height + 55;
  end;
end;

procedure TfrmImageSize.FormShow(Sender: TObject);
var
  BackgroundLayer: TBitmapLayer;
begin
  Screen.Cursor := crHourGlass;
  try
    UpdateKernelOptionsDisplay;
    BackgroundLayer := TBitmapLayer(ActiveChildForm.imgDrawingArea.Layers[0]);
    FOriginalWidth  := BackgroundLayer.Bitmap.Width;
    FOriginalHeight := BackgroundLayer.Bitmap.Height;
    FNewWidth       := BackgroundLayer.Bitmap.Width;
    FNewHeight      := BackgroundLayer.Bitmap.Height;
    ShowWidth;
    ShowHeight;
    ActiveControl := edtImageWidth;
  finally
    Screen.Cursor := crDefault;
  end;
end; 

procedure TfrmImageSize.cmbbxWidthUnitChange(Sender: TObject);
begin
  FWidthUnit := TgmAppliedUnit(cmbbxWidthUnit.ItemIndex);
  ShowWidth;
end;

procedure TfrmImageSize.cmbbxHeightUnitChange(Sender: TObject);
begin
  FHeightUnit := TgmAppliedUnit(cmbbxHeightUnit.ItemIndex);
  ShowHeight;
end;

procedure TfrmImageSize.FormCreate(Sender: TObject);
begin
  FCanChange           := True;
  FConstrainProperties := Boolean(StrToInt(ReadInfoFromIniFile(SECTION_IMAGE_SIZE_DIALOG, IDENT_IMAGE_SIZE_CONSTRAIN, '1')));
  FNewWidth            := 0;
  FNewHeight           := 0;
  FWidthUnit           := TgmAppliedUnit(StrToInt(ReadInfoFromIniFile(SECTION_IMAGE_SIZE_DIALOG, IDENT_IMAGE_SIZE_WIDTH_UNIT,  '1')));
  FHeightUnit          := TgmAppliedUnit(StrToInt(ReadInfoFromIniFile(SECTION_IMAGE_SIZE_DIALOG, IDENT_IMAGE_SIZE_HEIGHT_UNIT, '1')));

  with FResamplingOptions do
  begin
    Resampler       := TgmResamplerSelector(StrToInt(ReadInfoFromIniFile(SECTION_IMAGE_SIZE_DIALOG, IDENT_IMAGE_SIZE_RESAMPLER, '3')));
    PixelAccessMode := TPixelAccessMode(StrToInt(ReadInfoFromIniFile(SECTION_IMAGE_SIZE_DIALOG, IDENT_IMAGE_SIZE_PIXEL_ACCESS_MODE, '1')));
    WrapMode        := TWrapMode(StrToInt(ReadInfoFromIniFile(SECTION_IMAGE_SIZE_DIALOG, IDENT_IMAGE_SIZE_WRAP_MODE, '0')));
    Kernel          := TgmKernelSelector(StrToInt(ReadInfoFromIniFile(SECTION_IMAGE_SIZE_DIALOG, IDENT_IMAGE_SIZE_KERNEL, '4')));
    KernelMode      := TKernelMode(StrToInt(ReadInfoFromIniFile(SECTION_IMAGE_SIZE_DIALOG, IDENT_IMAGE_SIZE_KERNEL_MODE, '0')));
    TableSize       := StrToInt(ReadInfoFromIniFile(SECTION_IMAGE_SIZE_DIALOG, IDENT_IMAGE_SIZE_TABLE_SIZE, '32'));
  end;

  cmbbxWidthUnit.ItemIndex  := Ord(FWidthUnit);
  cmbbxHeightUnit.ItemIndex := Ord(FHeightUnit);

  cmbbxResampler.Items     := ResamplerNameList;
  cmbbxResampler.ItemIndex := Ord(FResamplingOptions.Resampler);

  cmbbxPAM.Items     := PixelAccessModeList;
  cmbbxPAM.ItemIndex := Ord(FResamplingOptions.PixelAccessMode);

  cmbbxWrapMode.Items     := WrapModeList;
  cmbbxWrapMode.ItemIndex := Ord(FResamplingOptions.WrapMode);

  cmbbxKernel.Items     := KernelNameList;
  cmbbxKernel.ItemIndex := Ord(FResamplingOptions.Kernel);

  cmbbxKernelMode.Items     := KernelModeList;
  cmbbxKernelMode.ItemIndex := Ord(FResamplingOptions.KernelMode);

  imgvwChain.Bitmap.DrawMode := dmBlend;
  imgvwChain.Bitmap.Changed;

  chckbxConstrainProperties.Checked := FConstrainProperties;
  ggbrTableSize.Position            := FResamplingOptions.TableSize;
end;

procedure TfrmImageSize.edtImageWidthExit(Sender: TObject);
begin
  ShowWidth;
end;

procedure TfrmImageSize.edtImageHeightExit(Sender: TObject);
begin
  ShowHeight;
end; 

procedure TfrmImageSize.edtImageWidthChange(Sender: TObject);
var
  RealVal, MinFloatWidth, MaxFloatWidth, Inches, Scale: Double;
  IntVal, MinIntWidth, MaxIntWidth                    : Integer;
begin
  MinFloatWidth := 0.00;
  MaxFloatWidth := 0.00;
  
  if FCanChange then
  begin
    MinIntWidth := 16;
    MaxIntWidth := Printer.PageWidth;

    if FWidthUnit in [auInch, auCentimeter, auPoint] then
    begin
      try
        RealVal := StrToFloat(edtImageWidth.Text);

        with frmPrintPreview.prntprvwPreview do
        begin
          case FWidthUnit of
            auInch:
              begin
                MinFloatWidth := ConvertX(MinIntWidth, mmPixel, mmLoEnglish) / 100;
                MaxFloatWidth := ConvertX(MaxIntWidth, mmPixel, mmLoEnglish) / 100;
              end;

            auCentimeter:
              begin
                MinFloatWidth := ConvertX(MinIntWidth, mmPixel, mmLoMetric) / 100;
                MaxFloatWidth := ConvertX(MaxIntWidth, mmPixel, mmLoMetric) / 100;
              end;

            auPoint:
              begin
                Inches        := ConvertX(MinIntWidth, mmPixel, mmLoEnglish) / 100;
                MinFloatWidth := Inches * 72;
                Inches        := ConvertX(MaxIntWidth, mmPixel, mmLoEnglish) / 100;
                MaxFloatWidth := Inches * 72;
              end;
          end;
        end;

        EnsureValueInRange(RealVal, MinFloatWidth, MaxFloatWidth);
      except
        case FWidthUnit of
          auInch      : RealVal := GetWidthByInch;
          auCentimeter: RealVal := GetWidthByCM;
          auPoint     : RealVal := GetWidthByPoint;
        end;
        ShowWidth;
      end;
    end;

    case FWidthUnit of
      auInch      : SetWidthByInch(RealVal);
      auCentimeter: SetWidthByCM(RealVal);
      auPoint     : SetWidthByPoint(RealVal);
      auPixel:
        begin
          try
            IntVal := StrToInt(edtImageWidth.Text);
            EnsureValueInRange(IntVal, MinIntWidth, MaxIntWidth);
            FNewWidth := IntVal;
          except
            ShowWidth;
          end;
        end;
    end;

    if FConstrainProperties then
    begin
      Scale      := FNewWidth / FOriginalWidth;
      FNewHeight := Round(FOriginalHeight * Scale);
      ShowHeight;
    end;
  end;
end;

procedure TfrmImageSize.edtImageHeightChange(Sender: TObject);
var
  RealVal, MinFloatHeight, MaxFloatHeight, Inches, Scale: Double;
  IntVal, MinIntHeight, MaxIntHeight                    : Integer;
begin
  MinFloatHeight := 0.00;
  MaxFloatHeight := 0.00;

  if FCanChange then
  begin
    MinIntHeight := 16;
    MaxIntHeight := Printer.PageHeight;

    if FHeightUnit in [auInch, auCentimeter, auPoint] then
    begin
      try
        RealVal := StrToFloat(edtImageHeight.Text);

        with frmPrintPreview.prntprvwPreview do
        begin
          case FHeightUnit of
            auInch:
              begin
                MinFloatHeight := ConvertY(MinIntHeight, mmPixel, mmLoEnglish) / 100;
                MaxFloatHeight := ConvertY(MaxIntHeight, mmPixel, mmLoEnglish) / 100;
              end;

            auCentimeter:
              begin
                MinFloatHeight := ConvertY(MinIntHeight, mmPixel, mmLoMetric) / 100;
                MaxFloatHeight := ConvertY(MaxIntHeight, mmPixel, mmLoMetric) / 100;
              end;

            auPoint:
              begin
                Inches         := ConvertY(MinIntHeight, mmPixel, mmLoEnglish) / 100;
                MinFloatHeight := Inches * 72;
                Inches         := ConvertY(MaxIntHeight, mmPixel, mmLoEnglish) / 100;
                MaxFloatHeight := Inches * 72;
              end;
          end;
        end;

        EnsureValueInRange(RealVal, MinFloatHeight, MaxFloatHeight);
      except
        case FHeightUnit of
          auInch      : RealVal := GetHeightByInch;
          auCentimeter: RealVal := GetHeightByCM;
          auPoint     : RealVal := GetHeightByPoint;
        end;
        
        ShowHeight;
      end;
    end;

    case FHeightUnit of
      auInch      : SetHeightByInch(RealVal);
      auCentimeter: SetHeightByCM(RealVal);
      auPoint     : SetHeightByPoint(RealVal);
      auPixel:
        begin
          try
            IntVal := StrToInt(edtImageHeight.Text);
            EnsureValueInRange(IntVal, MinIntHeight, MaxIntHeight);
            FNewHeight := IntVal;
          except
            ShowHeight;
          end;
        end;
    end;

    if FConstrainProperties then
    begin
      Scale     := FNewHeight / FOriginalHeight;
      FNewWidth := Round(FOriginalWidth * Scale);
      ShowWidth;
    end;
  end;
end;

procedure TfrmImageSize.chckbxConstrainPropertiesClick(Sender: TObject);
begin
  FConstrainProperties := chckbxConstrainProperties.Checked;
  imgvwChain.Visible   := FConstrainProperties;

  if chckbxConstrainProperties.Checked then
  begin
    FNewWidth  := FOriginalWidth;
    FNewHeight := FOriginalHeight;
    ShowWidth;
    ShowHeight;
  end;
end;

procedure TfrmImageSize.cmbbxResamplerChange(Sender: TObject);
begin
  FResamplingOptions.Resampler := TgmResamplerSelector(cmbbxResampler.ItemIndex);
  UpdateKernelOptionsDisplay;
end; 

procedure TfrmImageSize.cmbbxPAMChange(Sender: TObject);
begin
  FResamplingOptions.PixelAccessMode := TPixelAccessMode(cmbbxPAM.ItemIndex);
end;

procedure TfrmImageSize.cmbbxWrapModeChange(Sender: TObject);
begin
  FResamplingOptions.WrapMode := TWrapMode(cmbbxWrapMode.ItemIndex);
end; 

procedure TfrmImageSize.cmbbxKernelChange(Sender: TObject);
begin
  FResamplingOptions.Kernel := TgmKernelSelector(cmbbxKernel.ItemIndex);
end; 

procedure TfrmImageSize.cmbbxKernelModeChange(Sender: TObject);
begin
  FResamplingOptions.KernelMode := TKernelMode(cmbbxKernelMode.ItemIndex);
end; 

procedure TfrmImageSize.ggbrTableSizeChange(Sender: TObject);
begin
  FResamplingOptions.TableSize := ggbrTableSize.Position;
  lblTableSize.Caption         := Format('Table Size (%d/100):', [ggbrTableSize.Position]);
end; 

procedure TfrmImageSize.btbtnOKClick(Sender: TObject);
begin
  // save settings to ini file
  WriteInfoToIniFile(SECTION_IMAGE_SIZE_DIALOG, IDENT_IMAGE_SIZE_WIDTH_UNIT, IntToStr(Ord(FWidthUnit)));
  WriteInfoToIniFile(SECTION_IMAGE_SIZE_DIALOG, IDENT_IMAGE_SIZE_HEIGHT_UNIT, IntToStr(Ord(FHeightUnit)));
  WriteInfoToIniFile(SECTION_IMAGE_SIZE_DIALOG, IDENT_IMAGE_SIZE_RESAMPLER, IntToStr(Ord(FResamplingOptions.Resampler)));
  WriteInfoToIniFile(SECTION_IMAGE_SIZE_DIALOG, IDENT_IMAGE_SIZE_PIXEL_ACCESS_MODE, IntToStr(Ord(FResamplingOptions.PixelAccessMode)));
  WriteInfoToIniFile(SECTION_IMAGE_SIZE_DIALOG, IDENT_IMAGE_SIZE_WRAP_MODE, IntToStr(Ord(FResamplingOptions.WrapMode)));
  WriteInfoToIniFile(SECTION_IMAGE_SIZE_DIALOG, IDENT_IMAGE_SIZE_KERNEL, IntToStr(Ord(FResamplingOptions.Kernel)));
  WriteInfoToIniFile(SECTION_IMAGE_SIZE_DIALOG, IDENT_IMAGE_SIZE_KERNEL_MODE, IntToStr(Ord(FResamplingOptions.KernelMode)));
  WriteInfoToIniFile(SECTION_IMAGE_SIZE_DIALOG, IDENT_IMAGE_SIZE_TABLE_SIZE, IntToStr(FResamplingOptions.TableSize));
  WriteInfoToIniFile(SECTION_IMAGE_SIZE_DIALOG, IDENT_IMAGE_SIZE_CONSTRAIN, IntToStr(Integer(FConstrainProperties)));
end; 

end.
