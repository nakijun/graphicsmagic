unit LayerDataModule;

interface

uses
  SysUtils, Classes, Menus;

type
  TdmLayer = class(TDataModule)
    pmnAdjustmentLayers: TPopupMenu;
    pmnitmSolidColor: TMenuItem;
    pmnitmGradientFill: TMenuItem;
    pmnitmPattern: TMenuItem;
    N2: TMenuItem;
    pmnitmGimpLevels: TMenuItem;
    pmnitmGimpCurves: TMenuItem;
    pmnitmColorBalance: TMenuItem;
    pmnitmBrightnessContrast: TMenuItem;
    N1: TMenuItem;
    pmnitmHueSaturation: TMenuItem;
    pmnitmChannelMixer: TMenuItem;
    pmnitmGradientMap: TMenuItem;
    N3: TMenuItem;
    pmnitmInvert: TMenuItem;
    pmnitmThreshold: TMenuItem;
    pmnitmPosterize: TMenuItem;
    procedure CreateFillOrAdjustmentLayer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmLayer: TdmLayer;

implementation

uses
{ GraphicsMagic Forms/Dialogs }
  MainForm;

{$R *.dfm}

procedure TdmLayer.CreateFillOrAdjustmentLayer(Sender: TObject);
begin
  frmMain.CreateFillOrAdjustmentLayer(Sender);
end;

end.
