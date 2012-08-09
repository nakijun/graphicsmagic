{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

unit ChannelOptionsDlg;

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
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons;

type
  TgmChannelProcessType = (cptAlphaChannel, cptQuickMask, cptLayerMask);

  TfrmChannelOptions = class(TForm)
    lblChannelName: TLabel;
    edtChannelName: TEdit;
    rdgrpColorIndicator: TRadioGroup;
    grpbxColor: TGroupBox;
    shpMaskColor: TShape;
    lblMaskOpacity: TLabel;
    edtMaskOpacity: TEdit;
    Label1: TLabel;
    btbtnOK: TBitBtn;
    btbtnCancel: TBitBtn;
    clrdlgMaskColorSelector: TColorDialog;
    procedure shpMaskColorMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtMaskOpacityChange(Sender: TObject);
  private
    FMaskOpacityPercent: Double;

    procedure SetMaskOpacityPercent(const AValue: Double);
    procedure SetChannelProcessType(const AValue: TgmChannelProcessType);
  public
    property MaskOpacityPercent: Double read FMaskOpacityPercent write SetMaskOpacityPercent;
    property ChannelProcessType: TgmChannelProcessType write SetChannelProcessType;
  end;

var
  frmChannelOptions: TfrmChannelOptions;

implementation

uses
  GR32_LowLevel;

{$R *.dfm}

procedure TfrmChannelOptions.SetMaskOpacityPercent(const AValue: Double);
begin
  FMaskOpacityPercent := AValue;
  edtMaskOpacity.Text := IntToStr(Round(FMaskOpacityPercent * 100));
end;

procedure TfrmChannelOptions.SetChannelProcessType(
  const AValue: TgmChannelProcessType);
begin
  case AValue of
    cptQuickMask:
      begin
        Caption                := 'Quick Mask Options';
        edtChannelName.Visible := False;
        lblChannelName.Caption := 'Name: Quick Mask';
      end;

    cptLayerMask:
      begin
        Caption                     := 'Layer Mask Options';
        grpbxColor.Caption          := 'Overlay';
        rdgrpColorIndicator.Enabled := False;
        edtChannelName.Visible      := False;

        { Note, this TEdit component contains the layer mask name. See the
          LayerMaskDblClick() event handler in gmLayerAndChannel.pas
          for details. }
        lblChannelName.Caption := 'Name: ' + edtChannelName.Text;
      end;
  end;
end; 

procedure TfrmChannelOptions.shpMaskColorMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  clrdlgMaskColorSelector.Color := shpMaskColor.Brush.Color;

  if clrdlgMaskColorSelector.Execute then
  begin
    shpMaskColor.Brush.Color := clrdlgMaskColorSelector.Color;
  end;
end;

procedure TfrmChannelOptions.edtMaskOpacityChange(Sender: TObject);
var
  LChangedValue: Integer;
begin
  try
    LChangedValue := StrToInt(edtMaskOpacity.Text);
    LChangedValue := Clamp(LChangedValue, 0, 100);

    FMaskOpacityPercent := LChangedValue / 100;
    edtMaskOpacity.Text := IntToStr(Round(FMaskOpacityPercent * 100));
  except
    edtMaskOpacity.Text := IntToStr(Round(FMaskOpacityPercent * 100));
  end; 
end; 

end.
