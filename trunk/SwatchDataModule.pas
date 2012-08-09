unit SwatchDataModule;

interface

uses
  SysUtils, Classes, Menus, Dialogs, ImgList, Controls;

type
  TdmSwatches = class(TDataModule)
    imglstSwatches: TImageList;
    opndlgOpenSwatches: TOpenDialog;
    svdlgSaveSwatches: TSaveDialog;
    pmnSwatches: TPopupMenu;
    pmnitmResetSwatches: TMenuItem;
    pmnitmReplaceSwatches: TMenuItem;
    pmnitmSaveChanges: TMenuItem;
    pmnitmSaveSwatchesAs: TMenuItem;
    pmnitmSeparator1: TMenuItem;
    pmnitmNewSwatch: TMenuItem;
    pmnitmRenameSwatch: TMenuItem;
    pmnitmDeleteSwatch: TMenuItem;
    procedure pmnitmDeleteSwatchClick(Sender: TObject);
    procedure pmnitmNewSwatchClick(Sender: TObject);
    procedure pmnitmRenameSwatchClick(Sender: TObject);
    procedure pmnSwatchesPopup(Sender: TObject);
    procedure pmnitmResetSwatchesClick(Sender: TObject);
    procedure pmnitmSaveChangesClick(Sender: TObject);
    procedure pmnitmSaveSwatchesAsClick(Sender: TObject);
    procedure pmnitmReplaceSwatchesClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmSwatches: TdmSwatches;

implementation

uses
{ Standards }
  Windows,
{ GraphicsMagic Lib }
  gmIni,
  gmTypes,    
  gmSwatches,
{ GraphicsMagic Forms/Dialogs }
  SwatchForm,
  ColorForm,
  ColorSwatchNameDlg;

{$R *.dfm}

procedure TdmSwatches.pmnitmDeleteSwatchClick(Sender: TObject);
begin
  frmSwatch.SwatchList.DeleteSelectedSwatch;
  frmSwatch.SwatchList.ShowSwatches(frmSwatch.imgSwatches);
  
  frmSwatch.edtSwatchCount.Text := IntToStr(frmSwatch.SwatchList.Count);
end;

procedure TdmSwatches.pmnitmNewSwatchClick(Sender: TObject);
var
  r, g, b   : Byte;
  LNewSwatch: TgmSwatch;
begin
  frmColorSwatchName := TfrmColorSwatchName.Create(nil);
  try
    case frmColor.CurrColorSelector of
      csForeColor:
        begin
          frmColorSwatchName.shpColorSwatch.Brush.Color := frmColor.shpForegroundColor.Brush.Color;
        end;

      csBackColor:
        begin
          frmColorSwatchName.shpColorSwatch.Brush.Color := frmColor.shpBackgroundColor.Brush.Color;
        end;
    end;

    frmColorSwatchName.edtColorSwatchName.Text := 'Swatch' + IntToStr(frmSwatch.SwatchList.NewColorSwatchCount + 1);

    if frmColorSwatchName.ShowModal = idOK then
    begin
      r := GetRValue(frmColorSwatchName.shpColorSwatch.Brush.Color);
      g := GetGValue(frmColorSwatchName.shpColorSwatch.Brush.Color);
      b := GetBValue(frmColorSwatchName.shpColorSwatch.Brush.Color);

      LNewSwatch := TgmSwatch.Create(r, g, b, frmColorSwatchName.edtColorSwatchName.Text);

      frmSwatch.SwatchList.AddSwatch(LNewSwatch);
      frmSwatch.SwatchList.ShowSwatches(frmSwatch.imgSwatches);

      frmSwatch.edtSwatchCount.Text := IntToStr(frmSwatch.SwatchList.Count);
    end;
  finally
    FreeAndNil(frmColorSwatchName);
  end;
end;

procedure TdmSwatches.pmnitmRenameSwatchClick(Sender: TObject);
var
  r, g, b: Byte;
begin
  r := frmSwatch.SwatchList.SelectedSwatch.Red;
  g := frmSwatch.SwatchList.SelectedSwatch.Green;
  b := frmSwatch.SwatchList.SelectedSwatch.Blue;

  frmColorSwatchName := TfrmColorSwatchName.Create(nil);
  try
    frmColorSwatchName.shpColorSwatch.Brush.Color := RGB(r, g, b);
    frmColorSwatchName.edtColorSwatchName.Text    := frmSwatch.SwatchList.SelectedSwatch.Name;

    if frmColorSwatchName.ShowModal = idOK then
    begin
      r := GetRValue(frmColorSwatchName.shpColorSwatch.Brush.Color);
      g := GetGValue(frmColorSwatchName.shpColorSwatch.Brush.Color);
      b := GetBValue(frmColorSwatchName.shpColorSwatch.Brush.Color);

      with frmSwatch.SwatchList do
      begin
        SelectedSwatch.Red   := r;
        SelectedSwatch.Green := g;
        SelectedSwatch.Blue  := b;
        SelectedSwatch.Name  := frmColorSwatchName.edtColorSwatchName.Text;

        ShowSwatches(frmSwatch.imgSwatches);

        IsModified := True;
      end;
    end;
  finally
    FreeAndNil(frmColorSwatchName);
  end;
end;

procedure TdmSwatches.pmnSwatchesPopup(Sender: TObject);
begin
  pmnitmResetSwatches.Enabled := (not frmSwatch.SwatchList.IsUsingInternal) or
                                 frmSwatch.SwatchList.IsModified;

  pmnitmSaveChanges.Enabled   := frmSwatch.SwatchList.IsModified;
  pmnitmNewSwatch.Enabled     := (frmSwatch.SwatchList.Count < MAX_SWATCH_COUNT);
  pmnitmDeleteSwatch.Enabled  := (frmSwatch.SwatchList.Count > 1);
end;

procedure TdmSwatches.pmnitmResetSwatchesClick(Sender: TObject);
begin
  if MessageDlg('Replace current color swatches with the default colors?',
                mtConfirmation, [mbOK, mbCancel], 0) = idOK then
  begin
    if frmSwatch.SwatchList.IsModified then
    begin
      case MessageDlg('The color swatches has been changed. Do you want to save these changes?',
                     mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
        mrYes:
          begin
            pmnitmSaveChangesClick(Sender);
          end;

        mrCancel:
          begin
            Exit;
          end;
      end;
    end;

    frmSwatch.SwatchList.LoadInternalSwatchesToList;
    frmSwatch.SwatchList.ShowSwatches(frmSwatch.imgSwatches);
    WriteInfoToIniFile(SECTION_SWATCH, IDENT_USE_INTERNAL_SWATCHES, '1');

    frmSwatch.edtSwatchCount.Text := IntToStr(frmSwatch.SwatchList.Count);

    frmSwatch.PutSwatchImageAtTopLeft;
  end;
end;

procedure TdmSwatches.pmnitmSaveChangesClick(Sender: TObject);
begin
  if frmSwatch.SwatchList.Count > 0 then
  begin
    if frmSwatch.SwatchList.IsUsingInternal then
    begin
      pmnitmSaveSwatchesAsClick(Sender);
    end
    else
    begin
      frmSwatch.SwatchList.SaveSwatchesToFile(frmSwatch.SwatchList.FileName);
    end;
  end;
end;

procedure TdmSwatches.pmnitmSaveSwatchesAsClick(Sender: TObject);
var
  LFileName, LFileExt: string;
begin
  if svdlgSaveSwatches.Execute then
  begin
    LFileName := svdlgSaveSwatches.FileName;
    LFileExt  := LowerCase( ExtractFileExt(LFileName) );

    if LFileExt = '' then
    begin
      LFileName := LFileName + '.swa';
    end
    else
    begin
      if LFileExt <> '.swa' then
      begin
        LFileName := ChangeFileExt(LFileName, '.swa');
      end;
    end;

    if FileExists(LFileName) then
    begin
      if MessageDlg('The file is already existed. Do you want to replace it?',
                    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      begin
        frmSwatch.SwatchList.SaveSwatchesToFile(LFileName);
        WriteInfoToIniFile(SECTION_SWATCH, IDENT_OPEN_SWATCHES_FILE, LFileName);
      end;
    end
    else
    begin
      frmSwatch.SwatchList.SaveSwatchesToFile(LFileName);
      WriteInfoToIniFile(SECTION_SWATCH, IDENT_OPEN_SWATCHES_FILE, LFileName);
    end;
  end;
end;

procedure TdmSwatches.pmnitmReplaceSwatchesClick(Sender: TObject);
var
  LFileName, LOpenDir: string;
begin
  if frmSwatch.SwatchList.IsModified then
  begin
    case MessageDlg('The color swathces has been changed. Do you want to save these changes?',
                     mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
      mrYes:
        begin
          pmnitmSaveChangesClick(Sender);
        end;
        
      mrCancel:
        begin
          Exit;
        end;
    end;
  end;

  LFileName := ReadInfoFromIniFile(SECTION_SWATCH, IDENT_OPEN_SWATCHES_FILE, '');

  if LFileName <> '' then
  begin
    LOpenDir := ExtractFilePath(LFileName);
  end
  else
  begin
    LOpenDir := ExtractFilePath( ParamStr(0) );
  end;

  opndlgOpenSwatches.InitialDir := LOpenDir;

  if opndlgOpenSwatches.Execute then
  begin
    LFileName := opndlgOpenSwatches.FileName;

    if frmSwatch.SwatchList.LoadSwatchesToList(LFileName) = True then
    begin
      // update the ini file for next time use
      WriteInfoToIniFile(SECTION_SWATCH, IDENT_OPEN_SWATCHES_FILE, LFileName);
    end
    else
    begin
      MessageDlg(frmSwatch.SwatchList.OutputMsg, mtError, [mbOK], 0);
    end;

    frmSwatch.SwatchList.ShowSwatches(frmSwatch.imgSwatches);

    // if failure in loading external Swathes, then loading internal Swatches
    if frmSwatch.SwatchList.IsUsingInternal then
    begin
      WriteInfoToIniFile(SECTION_SWATCH, IDENT_USE_INTERNAL_SWATCHES, '1');
    end
    else
    begin
      WriteInfoToIniFile(SECTION_SWATCH, IDENT_USE_INTERNAL_SWATCHES, '0');
    end;
    
    frmSwatch.edtSwatchCount.Text := IntToStr(frmSwatch.SwatchList.Count);
    
    frmSwatch.PutSwatchImageAtTopLeft;
  end;
end;

end.
