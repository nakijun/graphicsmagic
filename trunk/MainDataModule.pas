unit MainDataModule;

interface

uses
  SysUtils, Classes, Dialogs, ImgList, Controls, Menus, GR32_Image;

type
  TdmMain = class(TDataModule)
    clrdlgRGB: TColorDialog;
    imglstTools: TImageList;
    svdlgSaveText: TSaveDialog;
    opndlgOpenText: TOpenDialog;
    pmnBrushStyle: TPopupMenu;
    pmnitmClearBrush: TMenuItem;
    pmnitmSolidBrush: TMenuItem;
    pmnitmHorizontalBrush: TMenuItem;
    pmnitmVerticalBrush: TMenuItem;
    pmnitmFDiagonalBrush: TMenuItem;
    pmnitmBDiagonalBrush: TMenuItem;
    pmnitmCrossBrush: TMenuItem;
    pmnitmDiagonalCrossBrush: TMenuItem;
    pmnShapeBrushStyle: TPopupMenu;
    pmnitmShapeSolidBrush: TMenuItem;
    pmnitmShapeHorizontalBrush: TMenuItem;
    pmnitmShapeVerticalBrush: TMenuItem;
    pmnitmShapeFDiagonalBrush: TMenuItem;
    pmnitmShapeBDiagonalBrush: TMenuItem;
    pmnitmShapeCrossBrush: TMenuItem;
    pmnitmShapeDCrossBrush: TMenuItem;
    imglstCommon: TImageList;
    bmp32lstMainTools: TBitmap32List;
    procedure ChangeGlobalBrushStyle(Sender: TObject);
    procedure ChangeShapeBrushStyle(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmMain: TdmMain;

const
  IMG_LEFT_TRIPLE_ARROW_INDEX  = 0;
  IMG_RIGHT_TRIPLE_ARROW_INDEX = 1;

implementation

uses
{ Standard }
  Graphics,
{ GraphicsMagic Lib }
  gmLayerAndChannel,
  gmHistoryManager,
{ GraphicsMagic Data Modules }
  HistoryDataModule,
{ GraphicsMagic Forms/Dialogs }
  MainForm,
  HistoryForm;

{$R *.dfm}

procedure TdmMain.ChangeGlobalBrushStyle(Sender: TObject);
var
  LBmp: TBitmap;
begin
  LBmp := TBitmap.Create;
  try
    if Sender = pmnitmClearBrush then
    begin
      frmMain.GlobalBrushStyle         := bsClear;
      frmMain.imgBrushStyleViewer.Hint := pmnitmClearBrush.Hint;
      
      imglstCommon.GetBitmap(0, LBmp);
    end
    else
    if Sender = pmnitmSolidBrush then
    begin
      frmMain.GlobalBrushStyle         := bsSolid;
      frmMain.imgBrushStyleViewer.Hint := pmnitmSolidBrush.Hint;
      
      imglstCommon.GetBitmap(1, LBmp);
    end
    else
    if Sender = pmnitmHorizontalBrush then
    begin
      frmMain.GlobalBrushStyle         := bsHorizontal;
      frmMain.imgBrushStyleViewer.Hint := pmnitmHorizontalBrush.Hint;
      
      imglstCommon.GetBitmap(2, LBmp);
    end
    else
    if Sender = pmnitmVerticalBrush then
    begin
      frmMain.GlobalBrushStyle         := bsVertical;
      frmMain.imgBrushStyleViewer.Hint := pmnitmVerticalBrush.Hint;
      
      imglstCommon.GetBitmap(3, LBmp);
    end
    else
    if Sender = pmnitmFDiagonalBrush then
    begin
      frmMain.GlobalBrushStyle         := bsFDiagonal;
      frmMain.imgBrushStyleViewer.Hint := pmnitmFDiagonalBrush.Hint;
      
      imglstCommon.GetBitmap(4, LBmp);
    end
    else
    if Sender = pmnitmBDiagonalBrush then
    begin
      frmMain.GlobalBrushStyle         := bsBDiagonal;
      frmMain.imgBrushStyleViewer.Hint := pmnitmBDiagonalBrush.Hint;

      imglstCommon.GetBitmap(5, LBmp);
    end
    else
    if Sender = pmnitmCrossBrush then
    begin
      frmMain.GlobalBrushStyle         := bsCross;
      frmMain.imgBrushStyleViewer.Hint := pmnitmCrossBrush.Hint;
      
      imglstCommon.GetBitmap(6, LBmp);
    end
    else
    if Sender = pmnitmDiagonalCrossBrush then
    begin
      frmMain.GlobalBrushStyle         := bsDiagCross;
      frmMain.imgBrushStyleViewer.Hint := pmnitmDiagonalCrossBrush.Hint;

      imglstCommon.GetBitmap(7, LBmp);
    end;

    frmMain.imgBrushStyleViewer.Picture.Bitmap.Assign(LBmp);
  finally
    LBmp.Free;
  end;
end;

procedure TdmMain.ChangeShapeBrushStyle(Sender: TObject);
var
  LBmp                  : TBitmap;
  LShapeRegionLayerPanel: TgmShapeRegionLayerPanel;
  LOldBrushStyle        : TBrushStyle;
  LHistoryStatePanel    : TgmHistoryStatePanel;
begin
  LBmp := TBitmap.Create;
  try
    if Sender = pmnitmShapeSolidBrush then
    begin
      frmMain.ShapeBrushStyle         := bsSolid;
      frmMain.imgShapeBrushStyle.Hint := pmnitmShapeSolidBrush.Hint;

      imglstCommon.GetBitmap(1, LBmp);
    end
    else
    if Sender = pmnitmShapeHorizontalBrush then
    begin
      frmMain.ShapeBrushStyle         := bsHorizontal;
      frmMain.imgShapeBrushStyle.Hint := pmnitmShapeHorizontalBrush.Hint;
      
      imglstCommon.GetBitmap(2, LBmp);
    end
    else
    if Sender = pmnitmShapeVerticalBrush then
    begin
      frmMain.ShapeBrushStyle         := bsVertical;
      frmMain.imgShapeBrushStyle.Hint := pmnitmShapeVerticalBrush.Hint;
      
      imglstCommon.GetBitmap(3, LBmp);
    end
    else
    if Sender = pmnitmShapeFDiagonalBrush then
    begin
      frmMain.ShapeBrushStyle         := bsFDiagonal;
      frmMain.imgShapeBrushStyle.Hint := pmnitmShapeFDiagonalBrush.Hint;
      
      imglstCommon.GetBitmap(4, LBmp);
    end
    else
    if Sender = pmnitmShapeBDiagonalBrush then
    begin
      frmMain.ShapeBrushStyle         := bsBDiagonal;
      frmMain.imgShapeBrushStyle.Hint := pmnitmShapeBDiagonalBrush.Hint;
      
      imglstCommon.GetBitmap(5, LBmp);
    end
    else
    if Sender = pmnitmShapeCrossBrush then
    begin
      frmMain.ShapeBrushStyle         := bsCross;
      frmMain.imgShapeBrushStyle.Hint := pmnitmShapeCrossBrush.Hint;

      imglstCommon.GetBitmap(6, LBmp);
    end
    else
    if Sender = pmnitmShapeDCrossBrush then
    begin
      frmMain.ShapeBrushStyle         := bsDiagCross;
      frmMain.imgShapeBrushStyle.Hint := pmnitmShapeDCrossBrush.Hint;

      imglstCommon.GetBitmap(7, LBmp);
    end;

    frmMain.imgShapeBrushStyle.Picture.Bitmap.Assign(LBmp);

    if ActiveChildForm <> nil then
    begin
      if ActiveChildForm.LayerPanelList.SelectedLayerPanel.LayerFeature = lfShapeRegion then
      begin
        LShapeRegionLayerPanel :=
          TgmShapeRegionLayerPanel(ActiveChildForm.LayerPanelList.SelectedLayerPanel);

        LOldBrushStyle                    := LShapeRegionLayerPanel.BrushStyle;
        LShapeRegionLayerPanel.BrushStyle := frmMain.ShapeBrushStyle;

        // Undo/Redo
        LHistoryStatePanel := TgmModifyShapeRegionStyleStatePanel.Create(
          frmHistory.scrlbxHistory,
          dmHistory.bmp32lstHistory.Bitmap[DEFAULT_COMMAND_ICON_INDEX],
          LOldBrushStyle,
          frmMain.ShapeBrushStyle);

        ActiveChildForm.HistoryManager.AddHistoryState(LHistoryStatePanel);
      end;
    end;
  finally
    LBmp.Free;
  end;
end;

end.
