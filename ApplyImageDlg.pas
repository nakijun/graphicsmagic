{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

unit ApplyImageDlg;

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
  Dialogs, StdCtrls, Buttons,
{ Graphics32 }
  GR32,
{ GraphicsMagic Lib }
  gmApplyImage,
  gmLayerAndChannel,
{ GraphicsMagic Forms/Dialogs }
  ChildForm;

type
  TgmChannelOptionsStatus = (cosIncludingRGB, cosExcludingRGB);

  TfrmApplyImage = class(TForm)
    grpbxSource: TGroupBox;
    lblSourceImage: TLabel;
    cmbbxSourceImage: TComboBox;
    lblSourceLayer: TLabel;
    cmbbxSourceLayer: TComboBox;
    lblSourceChannel: TLabel;
    cmbbxSourceChannel: TComboBox;
    chckbxSourceChannelInvert: TCheckBox;
    btbtnOK: TBitBtn;
    btbtnCancel: TBitBtn;
    chckbxPreview: TCheckBox;
    lblTarget: TLabel;
    lblTargetString: TLabel;
    grpbxBlending: TGroupBox;
    lblBlendMode: TLabel;
    cmbbxBlendMode: TComboBox;
    lblBlendOpacity: TLabel;
    edtBlendOpacity: TEdit;
    lblOpacityPercent: TLabel;
    chckbxPreserveTransparency: TCheckBox;
    chckbxEnableMask: TCheckBox;
    grpbxMask: TGroupBox;
    lblMaskImage: TLabel;
    cmbbxMaskImage: TComboBox;
    lblMaskLayer: TLabel;
    cmbbxMaskLayer: TComboBox;
    lblMaskChannel: TLabel;
    cmbbxMaskChannel: TComboBox;
    chckbxMaskChannelInvert: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cmbbxSourceImageChange(Sender: TObject);
    procedure cmbbxSourceLayerChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cmbbxSourceChannelChange(Sender: TObject);
    procedure chckbxSourceChannelInvertClick(Sender: TObject);
    procedure cmbbxBlendModeChange(Sender: TObject);
    procedure edtBlendOpacityChange(Sender: TObject);
    procedure chckbxPreserveTransparencyClick(Sender: TObject);
    procedure chckbxEnableMaskClick(Sender: TObject);
    procedure cmbbxMaskImageChange(Sender: TObject);
    procedure cmbbxMaskLayerChange(Sender: TObject);
    procedure cmbbxMaskChannelChange(Sender: TObject);
    procedure chckbxMaskChannelInvertClick(Sender: TObject);
    procedure chckbxPreviewClick(Sender: TObject);
    procedure btbtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FApplyImage                  : TgmApplyImage;
    FEnableChanging              : Boolean;

    FSourceChildForm             : TfrmChild;
    FSourceLayerPanel            : TgmLayerPanel;  // pointer to selected source layer panel
    FSourceBitmap                : TBitmap32;
    FSourceChannelOptionsStatus  : TgmChannelOptionsStatus;
    FSourceAlphaChannelStartIndex: Integer;        // the first index of alpha channel item in cmbbxSourceChannel.Items[]

    FMaskChildForm               : TfrmChild;
    FMaskLayerPanel              : TgmLayerPanel;  // pointer to selected mask layer panel
    FMaskBitmap                  : TBitmap32;
    FMaskChannelOptionsStatus    : TgmChannelOptionsStatus;
    FMaskAlphaChannelStartIndex  : Integer;        // the first index of alpha channel item in cmbbxMaskChannel.Items[]

    function GetTargetString: string;
    function GetLayerNames(const AChildForm: TfrmChild): TStringList;
    function GetSourceFileNameIndex(const AFileName: string): Integer;
    function GetSourceChannelNames: TStringList;
    function GetMaskFileNameIndex(const AFileName: string): Integer;
    function GetMaskChannelNames: TStringList;

    // setting source bitmap
    procedure SetSourceBitmapBySourceLayerSettings;
    procedure SetSourceBitmapBySourceChannelSettings;

    // setting mask bitmap
    procedure SetMaskBitmapByMaskLayerSettings;
    procedure SetMaskBitmapByMaskChannelSettings;

    procedure ApplyImageOnSelection;
    procedure ApplyImageOnAlphaChannel;
    procedure ApplyImageOnLayerMask;
    procedure ApplyImageOnLayer;
    procedure ExecuteApplyImage;
  public
    { Public declarations }
  end;

var
  frmApplyImage: TfrmApplyImage;

implementation

uses
{ Graphics32 }
  GR32_LowLevel,
{ externals }
  GR32_Add_BlendModes,
{ GraphicsMagic Lib }
  gmTypes,
  gmImageProcessFuncs,
  gmAlphaFuncs,
  gmCommands,
  gmHistoryManager,
{ GraphicsMagic Data Modules }
  HistoryDataModule,
{ GraphicsMagic Forms/Dialogs }
  MainForm,
  HistoryForm;

{$R *.dfm}

function TfrmApplyImage.GetTargetString: string;
var
  LTargetFileName: string;
begin
  Result := '';

  if Assigned(ActiveChildForm) then
  begin
    with ActiveChildForm do
    begin
      LTargetFileName := ExtractFileName(FileName);
      Result          := Result + LTargetFileName + ' ( ';

      case ChannelManager.CurrentChannelType of
        wctRGB:
          begin
            Result := Result + LayerPanelList.SelectedLayerPanel.LayerName.Caption + ', RGB';
          end;
          
        wctRed:
          begin
            Result := Result + LayerPanelList.SelectedLayerPanel.LayerName.Caption + ', Red';
          end;
          
        wctGreen:
          begin
            Result := Result + LayerPanelList.SelectedLayerPanel.LayerName.Caption + ', Green';
          end;
          
        wctBlue:
          begin
            Result := Result + LayerPanelList.SelectedLayerPanel.LayerName.Caption + ', Blue';
          end;
          
        wctLayerMask:
          begin
            Result := Result + LayerPanelList.SelectedLayerPanel.LayerName.Caption + ', Layer Mask';
          end;
          
        wctAlpha:
          begin
            Result := Result + ChannelManager.SelectedAlphaChannelPanel.ChannelName;
          end;
      end;
    end;
    
    Result := Result + ' )';
  end;
end;

function TfrmApplyImage.GetLayerNames(const AChildForm: TfrmChild): TStringList;
var
  i              : Integer;
  LTempLayerPanel: TgmLayerPanel;
begin
  Result := nil;

  if Assigned(AChildForm) then
  begin
    Result := TStringList.Create;

    if AChildForm.LayerPanelList.Count > 1 then
    begin
      Result.Add('Merged');
    end;

    for i := (AChildForm.LayerPanelList.Count - 1) downto 0 do
    begin
      LTempLayerPanel := AChildForm.LayerPanelList.GetLayerPanelByIndex(i);

      if LTempLayerPanel.IsHoldMaskInLayerAlpha then
      begin
        if not LTempLayerPanel.IsHasMask then
        begin
          Continue;
        end;
      end;

      Result.Add(LTempLayerPanel.LayerName.Caption);
    end;
  end;
end;

function TfrmApplyImage.GetSourceFileNameIndex(const AFileName: string): Integer;
var
  i: Integer;
begin
  Result := -1;

  if cmbbxSourceImage.Items.Count > 0 then
  begin
    for i := 0 to cmbbxSourceImage.Items.Count - 1 do
    begin
      if AFileName = cmbbxSourceImage.Items[i] then
      begin
        Result := i;
        Break;
      end;
    end;
  end;
end;

function TfrmApplyImage.GetSourceChannelNames: TStringList;
var
  i            : Integer;
  LChannelPanel: TgmChannelPanel;
begin
  Result := TStringList.Create;

  case FSourceChannelOptionsStatus of
    cosIncludingRGB:
      begin
        Result.Add('RGB');
        Result.Add('Red');
        Result.Add('Green');
        Result.Add('Blue');
        Result.Add('Transparency');

        if Assigned(FSourceLayerPanel) then
        begin
          if FSourceLayerPanel.IsHasMask then
          begin
            Result.Add('Layer Mask');
          end;
        end;
      end;

    cosExcludingRGB:
      begin
        Result.Add('Layer Mask');
      end;
  end;

  if Assigned(FSourceChildForm) then
  begin
    FSourceAlphaChannelStartIndex := -1;
    
    if FSourceChildForm.ChannelManager.AlphaChannelPanelList.Count > 0 then
    begin
      FSourceAlphaChannelStartIndex := Result.Count;

      for i := 0 to (FSourceChildForm.ChannelManager.AlphaChannelPanelList.Count - 1) do
      begin
        LChannelPanel := FSourceChildForm.ChannelManager.GetAlphaChannelPanelByIndex(i);

        Result.Add(LChannelPanel.ChannelName);
      end;
    end;

    // selection channel
    if Assigned(FSourceChildForm.Selection) then
    begin
      Result.Add('Selection');
    end;
  end;
end;

function TfrmApplyImage.GetMaskFileNameIndex(const AFileName: string): Integer;
var
  i: Integer;
begin
  Result := -1;

  if cmbbxMaskImage.Items.Count > 0 then
  begin
    for i := 0 to cmbbxMaskImage.Items.Count - 1 do
    begin
      if AFileName = cmbbxMaskImage.Items[i] then
      begin
        Result := i;
        Break;
      end;
    end;
  end;
end;

function TfrmApplyImage.GetMaskChannelNames: TStringList;
var
  i            : Integer;
  LChannelPanel: TgmChannelPanel;
begin
  Result := TStringList.Create;

  case FMaskChannelOptionsStatus of
    cosIncludingRGB:
      begin
        Result.Add('Gray');
        Result.Add('Red');
        Result.Add('Green');
        Result.Add('Blue');
        Result.Add('Transparency');

        if Assigned(FMaskLayerPanel) then
        begin
          if FMaskLayerPanel.IsHasMask then
          begin
            Result.Add('Layer Mask');
          end;
        end;
      end;

    cosExcludingRGB:
      begin
        Result.Add('Layer Mask');
      end;
  end;

  if Assigned(FMaskChildForm) then
  begin
    FMaskAlphaChannelStartIndex := -1;
    
    if FMaskChildForm.ChannelManager.AlphaChannelPanelList.Count > 0 then
    begin
      FMaskAlphaChannelStartIndex := Result.Count;

      for i := 0 to (FMaskChildForm.ChannelManager.AlphaChannelPanelList.Count - 1) do
      begin
        LChannelPanel := FMaskChildForm.ChannelManager.GetAlphaChannelPanelByIndex(i);

        Result.Add(LChannelPanel.ChannelName);
      end;
    end;

    // selection channel
    if Assigned(FMaskChildForm.Selection) then
    begin
      Result.Add('Selection');
    end;
  end;
end;

// setting source bitmap
procedure TfrmApplyImage.SetSourceBitmapBySourceLayerSettings;
var
  LLayerIndex: Integer;
begin
  if Assigned(FSourceChildForm) then
  begin
    if cmbbxSourceLayer.ItemIndex >= 0 then
    begin
      if (FSourceChildForm.LayerPanelList.Count > 1) and
         (cmbbxSourceLayer.ItemIndex = 0) then  // merged image
      begin
        FSourceChildForm.LayerPanelList.FlattenLayersToBitmap(FSourceBitmap, dmBlend);
        FSourceLayerPanel := nil;  // not pointer to any layer panel
      end
      else
      begin
        LLayerIndex       := cmbbxSourceLayer.Items.Count - cmbbxSourceLayer.ItemIndex - 1;
        FSourceLayerPanel := FSourceChildForm.LayerPanelList.GetLayerPanelByIndex(LLayerIndex);

        if Assigned(FSourceLayerPanel) then
        begin
          if FSourceLayerPanel.IsHoldMaskInLayerAlpha then
          begin
            FSourceBitmap.Assign(FSourceLayerPanel.FMaskImage.Bitmap);
          end
          else
          begin
            FSourceBitmap.Assign(FSourceLayerPanel.AssociatedLayer.Bitmap);

            if FSourceLayerPanel.IsMaskLinked then
            begin
              ReplaceAlphaChannelWithMask(FSourceBitmap,
                FSourceLayerPanel.FLastAlphaChannelBmp);
            end;
          end;
        end;
      end;
    end;
  end;
end;

// setting source bitmap
procedure TfrmApplyImage.SetSourceBitmapBySourceChannelSettings;
var
  LAlphaChannelPanel: TgmAlphaChannelPanel;
  LChannelIndex     : Integer;
begin
  if Assigned(FApplyImage) then
  begin
    // if the selection channel is chosen
    if Assigned(FSourceChildForm.Selection) and
       (cmbbxSourceChannel.ItemIndex = (cmbbxSourceChannel.Items.Count - 1)) then
    begin
      FApplyImage.SourceChannel := gmscsAlphaChannel;

      FSourceBitmap.SetSize(FSourceChildForm.Selection.SourceBitmap.Width,
                            FSourceChildForm.Selection.SourceBitmap.Height);

      FSourceBitmap.Clear($FF000000);

      FSourceBitmap.Draw(FSourceChildForm.Selection.FMaskBorderStart.X,
                         FSourceChildForm.Selection.FMaskBorderStart.Y,
                         FSourceChildForm.Selection.ResizedMask);

      Exit;
    end;

    case FSourceChannelOptionsStatus of
      cosIncludingRGB:
        begin
          if (cmbbxSourceChannel.ItemIndex >= 0) and
             (cmbbxSourceChannel.ItemIndex < 5) then
          begin
            FApplyImage.SourceChannel := TgmSourceChannelSelector(cmbbxSourceChannel.ItemIndex);

            SetSourceBitmapBySourceLayerSettings;
          end
          else
          begin
            FApplyImage.SourceChannel := gmscsAlphaChannel;

            if Assigned(FSourceLayerPanel) then
            begin
              // this layer has a mask, see if we select it as source bitmap
              if FSourceLayerPanel.IsHasMask then
              begin
                if cmbbxSourceChannel.ItemIndex = 5 then // layer mask
                begin
                  FSourceBitmap.Assign(FSourceLayerPanel.FMaskImage.Bitmap);
                end
                else
                begin
                  if Assigned(FSourceChildForm) then
                  begin
                    if FSourceAlphaChannelStartIndex >= 0 then
                    begin
                      LChannelIndex      := cmbbxSourceChannel.ItemIndex - FSourceAlphaChannelStartIndex;
                      LAlphaChannelPanel := FSourceChildForm.ChannelManager.GetAlphaChannelPanelByIndex(LChannelIndex);

                      if Assigned(LAlphaChannelPanel) then
                      begin
                        FSourceBitmap.Assign(LAlphaChannelPanel.AlphaLayer.Bitmap);
                      end;
                    end;
                  end;
                end;
              end
              else
              begin
                if Assigned(FSourceChildForm) then
                begin
                  if FSourceAlphaChannelStartIndex >= 0 then
                  begin
                    LChannelIndex      := cmbbxSourceChannel.ItemIndex - FSourceAlphaChannelStartIndex;
                    LAlphaChannelPanel := FSourceChildForm.ChannelManager.GetAlphaChannelPanelByIndex(LChannelIndex);

                    if Assigned(LAlphaChannelPanel) then
                    begin
                      FSourceBitmap.Assign(LAlphaChannelPanel.AlphaLayer.Bitmap);
                    end;
                  end;
                end;
              end;
            end
            else  // if the FSourceLayerPanel = nil
            begin
              if Assigned(FSourceChildForm) then
              begin
                if FSourceAlphaChannelStartIndex >= 0 then
                begin
                  LChannelIndex      := cmbbxSourceChannel.ItemIndex - FSourceAlphaChannelStartIndex;
                  LAlphaChannelPanel := FSourceChildForm.ChannelManager.GetAlphaChannelPanelByIndex(LChannelIndex);

                  if Assigned(LAlphaChannelPanel) then
                  begin
                    FSourceBitmap.Assign(LAlphaChannelPanel.AlphaLayer.Bitmap);
                  end;
                end;
              end;
            end;
          end;
        end;

      cosExcludingRGB:
        begin
          FApplyImage.SourceChannel := gmscsAlphaChannel;

          if cmbbxSourceChannel.ItemIndex = 0 then
          begin
            SetSourceBitmapBySourceLayerSettings;
          end
          else
          begin
            if Assigned(FSourceChildForm) then
            begin
              if FSourceAlphaChannelStartIndex >= 0 then
              begin
                LChannelIndex      := cmbbxSourceChannel.ItemIndex - FSourceAlphaChannelStartIndex;
                LAlphaChannelPanel := FSourceChildForm.ChannelManager.GetAlphaChannelPanelByIndex(LChannelIndex);

                if Assigned(LAlphaChannelPanel) then
                begin
                  FSourceBitmap.Assign(LAlphaChannelPanel.AlphaLayer.Bitmap);
                end;
              end;
            end;
          end;
        end;
    end;
  end;
end;

// setting mask bitmap
procedure TfrmApplyImage.SetMaskBitmapByMaskLayerSettings;
var
  LLayerIndex: Integer;
begin
  if Assigned(FMaskChildForm) then
  begin
    if cmbbxMaskLayer.ItemIndex >= 0 then
    begin
      if (FMaskChildForm.LayerPanelList.Count > 1) and
         (cmbbxMaskLayer.ItemIndex = 0) then  // merged image
      begin
        FMaskChildForm.LayerPanelList.FlattenLayersToBitmap(FMaskBitmap, dmBlend);
        FMaskLayerPanel := nil; // not pointer to any layer panel
      end
      else
      begin
        LLayerIndex     := cmbbxMaskLayer.Items.Count - cmbbxMaskLayer.ItemIndex - 1;
        FMaskLayerPanel := FMaskChildForm.LayerPanelList.GetLayerPanelByIndex(LLayerIndex);

        if Assigned(FMaskLayerPanel) then
        begin
          if FMaskLayerPanel.IsHoldMaskInLayerAlpha then
          begin
            FMaskBitmap.Assign(FMaskLayerPanel.FMaskImage.Bitmap);
          end
          else
          begin
            FMaskBitmap.Assign(FMaskLayerPanel.AssociatedLayer.Bitmap);

            if FMaskLayerPanel.IsMaskLinked then
            begin
              ReplaceAlphaChannelWithMask(FMaskBitmap,
                FMaskLayerPanel.FLastAlphaChannelBmp);
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TfrmApplyImage.SetMaskBitmapByMaskChannelSettings;
var
  LAlphaChannelPanel: TgmAlphaChannelPanel;
  LChannelIndex     : Integer;
begin
  if Assigned(FApplyImage) then
  begin
    // if the selection channel is chosen
    if Assigned(FMaskChildForm.Selection) and
       (cmbbxMaskChannel.ItemIndex = (cmbbxMaskChannel.Items.Count - 1)) then
    begin
      FApplyImage.MaskChannel := gmscsAlphaChannel;

      FMaskBitmap.SetSize(FMaskChildForm.Selection.SourceBitmap.Width,
                          FMaskChildForm.Selection.SourceBitmap.Height);

      FMaskBitmap.Clear($FF000000);
      
      FMaskBitmap.Draw(FMaskChildForm.Selection.FMaskBorderStart.X,
                       FMaskChildForm.Selection.FMaskBorderStart.Y,
                       FMaskChildForm.Selection.ResizedMask);
                         
      Exit;
    end;

    case FMaskChannelOptionsStatus of
      cosIncludingRGB:
        begin
          if (cmbbxMaskChannel.ItemIndex >= 0) and
             (cmbbxMaskChannel.ItemIndex < 5) then
          begin
            FApplyImage.MaskChannel := TgmSourceChannelSelector(cmbbxMaskChannel.ItemIndex);

            SetMaskBitmapByMaskLayerSettings;
          end
          else
          begin
            FApplyImage.MaskChannel := gmscsAlphaChannel;

            if Assigned(FMaskLayerPanel) then
            begin
              // this layer has a mask, see if we select it as mask bitmap
              if FMaskLayerPanel.IsHasMask then
              begin
                if cmbbxMaskChannel.ItemIndex = 5 then  // layer mask
                begin
                  FMaskBitmap.Assign(FMaskLayerPanel.FMaskImage.Bitmap);
                end
                else
                begin
                  if Assigned(FMaskChildForm) then
                  begin
                    if FMaskAlphaChannelStartIndex >= 0 then
                    begin
                      LChannelIndex      := cmbbxMaskChannel.ItemIndex - FMaskAlphaChannelStartIndex;
                      LAlphaChannelPanel := FMaskChildForm.ChannelManager.GetAlphaChannelPanelByIndex(LChannelIndex);

                      if Assigned(LAlphaChannelPanel) then
                      begin
                        FMaskBitmap.Assign(LAlphaChannelPanel.AlphaLayer.Bitmap);
                      end;
                    end;
                  end;
                end;
              end
              else
              begin
                if Assigned(FMaskChildForm) then
                begin
                  if FMaskAlphaChannelStartIndex >= 0 then
                  begin
                    LChannelIndex      := cmbbxMaskChannel.ItemIndex - FMaskAlphaChannelStartIndex;
                    LAlphaChannelPanel := FMaskChildForm.ChannelManager.GetAlphaChannelPanelByIndex(LChannelIndex);

                    if Assigned(LAlphaChannelPanel) then
                    begin
                      FMaskBitmap.Assign(LAlphaChannelPanel.AlphaLayer.Bitmap);
                    end;
                  end;
                end;
              end;
            end
            else  // if the FMaskLayerPanel = nil
            begin
              if Assigned(FMaskChildForm) then
              begin
                if FMaskAlphaChannelStartIndex >= 0 then
                begin
                  LChannelIndex      := cmbbxMaskChannel.ItemIndex - FMaskAlphaChannelStartIndex;
                  LAlphaChannelPanel := FMaskChildForm.ChannelManager.GetAlphaChannelPanelByIndex(LChannelIndex);

                  if Assigned(LAlphaChannelPanel) then
                  begin
                    FMaskBitmap.Assign(LAlphaChannelPanel.AlphaLayer.Bitmap);
                  end;
                end;
              end;
            end;
          end;
        end;

      cosExcludingRGB:
        begin
          FApplyImage.MaskChannel := gmscsAlphaChannel;

          if cmbbxMaskChannel.ItemIndex = 0 then
          begin
            SetMaskBitmapByMaskLayerSettings;
          end
          else
          begin
            if Assigned(FMaskChildForm) then
            begin
              if FMaskAlphaChannelStartIndex >= 0 then
              begin
                LChannelIndex      := cmbbxMaskChannel.ItemIndex - FMaskAlphaChannelStartIndex;
                LAlphaChannelPanel := FMaskChildForm.ChannelManager.GetAlphaChannelPanelByIndex(LChannelIndex);

                if Assigned(LAlphaChannelPanel) then
                begin
                  FMaskBitmap.Assign(LAlphaChannelPanel.AlphaLayer.Bitmap);
                end;
              end;
            end;
          end;
        end;
    end;
  end;
end;

// process on alpha channel
procedure TfrmApplyImage.ApplyImageOnSelection;
var
  LTempSourceBmp: TBitmap32;
  LTempMaskBmp  : TBitmap32;
  LRect         : TRect;
begin
  with ActiveChildForm do
  begin
    if ChannelManager.CurrentChannelType in [wctRGB, wctRed, wctGreen, wctBlue] then
    begin
      // can't process on special layers
      if not (LayerPanelList.SelectedLayerPanel.LayerFeature in [
                lfBackground, lfTransparent]) then
      begin
        Exit;
      end;
    end;

    // retore the destination to original state
    frmMain.FAfterProc.Assign(frmMain.FBeforeProc);

    LTempSourceBmp := TBitmap32.Create;
    try
      LRect.Left   := Selection.FMaskBorderStart.X;
      LRect.Top    := Selection.FMaskBorderStart.Y;
      LRect.Right  := Selection.FMaskBorderEnd.X + 1;
      LRect.Bottom := Selection.FMaskBorderEnd.Y + 1;

      LTempSourceBmp.DrawMode    := dmBlend;
      LTempSourceBmp.MasterAlpha := FSourceBitmap.MasterAlpha;
      CopyRect32WithARGB(LTempSourceBmp, FSourceBitmap, LRect, $00FFFFFF);

      if FApplyImage.SourceChannel in [gmscsTransparency, gmscsAlphaChannel] then
      begin
        ReplaceAlphaChannelWithNewValue(LTempSourceBmp, 255);
      end;
      
      // blending
      if chckbxEnableMask.Checked then
      begin
        LTempMaskBmp := TBitmap32.Create;
        try
          CopyRect32WithARGB(LTempMaskBmp, FMaskBitmap, LRect, $FF000000);

          FApplyImage.Execute(LTempSourceBmp, frmMain.FAfterProc, LTempMaskBmp,
                              ChannelManager.ChannelSelectedSet);
        finally
          LTempMaskBmp.Free;
        end;
      end
      else
      begin
        FApplyImage.Execute(LTempSourceBmp, frmMain.FAfterProc,
                            ChannelManager.ChannelSelectedSet);
      end;
      
    finally
      LTempSourceBmp.Free;
    end;

    if chckbxPreview.Checked then
    begin
      Selection.CutOriginal.Assign(frmMain.FAfterProc);
      ShowProcessedSelection;
    end
    else
    begin
      imgDrawingArea.Update;
      DrawMarchingAnts;
    end;
  end;
end;

// process on alpha channel
procedure TfrmApplyImage.ApplyImageOnAlphaChannel;
begin
  with ActiveChildForm do
  begin
    if Assigned(ChannelManager.SelectedAlphaChannelPanel) then
    begin
      // retore the destination to original state
      frmMain.FAfterProc.Assign(frmMain.FBeforeProc);

      // blending
      if chckbxEnableMask.Checked then
        FApplyImage.Execute(FSourceBitmap, frmMain.FAfterProc, FMaskBitmap,
                            ChannelManager.ChannelSelectedSet)
      else
        FApplyImage.Execute(FSourceBitmap, frmMain.FAfterProc,
                            ChannelManager.ChannelSelectedSet);

      if chckbxPreview.Checked then
      begin
        ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Assign(frmMain.FAfterProc);
        ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
      end;
    end;
  end;
end;

procedure TfrmApplyImage.ApplyImageOnLayerMask;
begin
  // retore the destination to original state
  frmMain.FAfterProc.Assign(frmMain.FBeforeProc);

  with ActiveChildForm do
  begin
    // blending
    if chckbxEnableMask.Checked then
    begin
      FApplyImage.Execute(FSourceBitmap, frmMain.FAfterProc, FMaskBitmap,
                          ChannelManager.ChannelSelectedSet);
    end
    else
    begin
      FApplyImage.Execute(FSourceBitmap, frmMain.FAfterProc,
                          ChannelManager.ChannelSelectedSet);
    end;

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

// process on layer
procedure TfrmApplyImage.ApplyImageOnLayer;
begin
  with ActiveChildForm do
  begin
    if LayerPanelList.SelectedLayerPanel.LayerFeature in [
         lfBackground, lfTransparent] then
    begin
      // retore the destination to original state
      frmMain.FAfterProc.Assign(frmMain.FBeforeProc);

      // blending
      if chckbxEnableMask.Checked then
      begin
        FApplyImage.Execute(FSourceBitmap, frmMain.FAfterProc, FMaskBitmap,
                            ChannelManager.ChannelSelectedSet);
      end
      else
      begin
        FApplyImage.Execute(FSourceBitmap, frmMain.FAfterProc,
                            ChannelManager.ChannelSelectedSet);
      end;


      if chckbxPreview.Checked then
      begin
        LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Assign(frmMain.FAfterProc);
        LayerPanelList.SelectedLayerPanel.Update;
      end;
    end;
  end;
end; 

procedure TfrmApplyImage.ExecuteApplyImage;
begin
  Screen.Cursor := crHourGlass;
  try
    if Assigned(ActiveChildForm) then
    begin
      if Assigned(ActiveChildForm.Selection) then
      begin
        ApplyImageOnSelection;
      end
      else
      begin
        case ActiveChildForm.ChannelManager.CurrentChannelType of
          wctAlpha:
            begin
              ApplyImageOnAlphaChannel;
            end;
            
          wctLayerMask:
            begin
              ApplyImageOnLayerMask;
            end;
            
          wctRGB, wctRed, wctGreen, wctBlue:
            begin
              ApplyImageOnLayer;
            end;
        end;
      end;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfrmApplyImage.FormCreate(Sender: TObject);
begin
  FEnableChanging := True;
  FApplyImage     := TgmApplyImage.Create;

  FSourceChildForm              := nil;
  FSourceLayerPanel             := nil;
  FSourceBitmap                 := TBitmap32.Create;
  FSourceChannelOptionsStatus   := cosIncludingRGB;
  FSourceAlphaChannelStartIndex := -1;

  FMaskChildForm              := nil;
  FMaskLayerPanel             := nil;
  FMaskBitmap                 := TBitmap32.Create;
  FMaskChannelOptionsStatus   := cosIncludingRGB;
  FMaskAlphaChannelStartIndex := -1;
end;

procedure TfrmApplyImage.FormDestroy(Sender: TObject);
begin
  FSourceChildForm  := nil;
  FSourceLayerPanel := nil;
  FMaskChildForm    := nil;
  FMaskLayerPanel   := nil;

  FSourceBitmap.Free;
  FMaskBitmap.Free;
  FApplyImage.Free;
end;

procedure TfrmApplyImage.cmbbxSourceImageChange(Sender: TObject);
begin
  if FEnableChanging then
  begin
    FSourceChildForm := frmMain.GetChildFormPointerByFileName(cmbbxSourceImage.Items[cmbbxSourceImage.ItemIndex]);

    // restore the channel selection to default -- RGB channel
    FSourceChannelOptionsStatus := cosIncludingRGB;
    cmbbxSourceChannel.Items    := GetSourceChannelNames;
    FEnableChanging := False; // avoid execute the OnChange event of this combo box
    try
      if cmbbxSourceChannel.ItemIndex <> 0 then
      begin
        cmbbxSourceChannel.ItemIndex := 0;
        FApplyImage.SourceChannel    := TgmSourceChannelSelector(0);
      end;
    finally
      FEnableChanging := True;
    end;

    // restore the layer selection to default -- merged layer
    cmbbxSourceLayer.Items     := GetLayerNames(FSourceChildForm);
    cmbbxSourceLayer.ItemIndex := 0;
    cmbbxSourceLayerChange(Sender);
  end;
end;

procedure TfrmApplyImage.cmbbxSourceLayerChange(Sender: TObject);
begin
  if FEnableChanging then
  begin
    if Assigned(FSourceChildForm) then
    begin
      { Because of the selected source maybe just the target, and the target
        maybe changed due to preview the process result on target, so we need
        to restore the target before make the target as the source. }
      with ActiveChildForm do
      begin
        if Assigned(Selection) then
        begin
          Selection.CutOriginal.Assign(frmMain.FBeforeProc);
          ShowProcessedSelection(False);
        end
        else
        begin
          case ChannelManager.CurrentChannelType of
            wctAlpha:
              begin
                ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Assign(frmMain.FBeforeProc);
              end;
              
            wctLayerMask:
              begin
                LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Assign(frmMain.FBeforeProc);

                // if on special layers, save the Mask into layer's alpha channels
                if LayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
                begin
                  LayerPanelList.SelectedLayerPanel.UpdateLayerAlphaWithMask;
                end;
              end;

            wctRGB, wctRed, wctGreen, wctBlue:
              begin
                LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Assign(frmMain.FBeforeProc);
              end;
          end;
        end;
      end;

      if cmbbxSourceLayer.ItemIndex >= 0 then
      begin
        // get the proper source bitmap
        SetSourceBitmapBySourceLayerSettings;

        if (FSourceChildForm.LayerPanelList.Count > 1) and
           (cmbbxSourceLayer.ItemIndex = 0) then // merged image
        begin
          FSourceChannelOptionsStatus := cosIncludingRGB;
          FApplyImage.SourceChannel   := gmscsRGB;
        end
        else
        begin
          if Assigned(FSourceLayerPanel) then
          begin
            if FSourceLayerPanel.IsHoldMaskInLayerAlpha then
            begin
              FSourceChannelOptionsStatus := cosExcludingRGB;
              FApplyImage.SourceChannel   := gmscsAlphaChannel;
            end
            else
            begin
              FSourceChannelOptionsStatus := cosIncludingRGB;
              FApplyImage.SourceChannel   := gmscsRGB;
            end;
          end;
        end;

        cmbbxSourceChannel.Items.Clear;
        cmbbxSourceChannel.Items     := GetSourceChannelNames;
        cmbbxSourceChannel.ItemIndex := 0;

        ExecuteApplyImage;
      end;
    end;
  end;
end;

procedure TfrmApplyImage.FormShow(Sender: TObject);
var
  LLayerIndex: Integer;
  LTempBmp   : TBitmap32;
begin
  if Assigned(ActiveChildForm) then
  begin
    with ActiveChildForm do
    begin
      if Assigned(Selection) then
      begin
        // make the CutOriginal same as the foreground of the selection
        Selection.ConfirmForeground;

        frmMain.FBeforeProc.Assign(Selection.CutOriginal);
        frmMain.FAfterProc.Assign(Selection.CutOriginal);

        if Assigned(SelectionHandleLayer) then
        begin
          SelectionHandleLayer.Visible := False;
        end;
      end
      else
      begin
        case ChannelManager.CurrentChannelType of
          wctAlpha:
            begin
              if Assigned(ChannelManager.SelectedAlphaChannelPanel) then
              begin
                frmMain.FBeforeProc.Assign(ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
                frmMain.FAfterProc.Assign(ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap);
              end;
            end;

          wctLayerMask:
            begin
              frmMain.FBeforeProc.Assign(LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
              frmMain.FAfterProc.Assign(LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
            end;

          wctRGB, wctRed, wctGreen, wctBlue:
            begin
              if LayerPanelList.SelectedLayerPanel.LayerFeature in [
                   lfBackground, lfTransparent] then
              begin
                LTempBmp := TBitmap32.Create;
                try
                  LTempBmp.Assign(LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap);

                  if LayerPanelList.SelectedLayerPanel.IsMaskLinked then
                  begin
                    ReplaceAlphaChannelWithMask(LTempBmp,
                      LayerPanelList.SelectedLayerPanel.FLastAlphaChannelBmp);
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
    end;

    // initialize components
    lblTargetString.Caption := GetTargetString;

    // initialize settings
    FEnableChanging := False; // suppress OnChange events occur temporarily
    try
      // source image
      cmbbxSourceImage.Items     := frmMain.GetFileNamesWithSameSizeImage;
      cmbbxSourceImage.ItemIndex := GetSourceFileNameIndex( ExtractFileName(ActiveChildForm.FileName) );
      FSourceChildForm           := frmMain.GetChildFormPointerByFileName(cmbbxSourceImage.Items[cmbbxSourceImage.ItemIndex]);

      // source layer
      cmbbxSourceLayer.Items     := GetLayerNames(FSourceChildForm);
      cmbbxSourceLayer.ItemIndex := 0;

      if FSourceChildForm.LayerPanelList.Count > 1 then // merged image
      begin
        FSourceLayerPanel := nil; // not pointer to any layer panel
        FSourceChildForm.LayerPanelList.FlattenLayersToBitmap(FSourceBitmap, dmBlend);
      end
      else
      begin
        LLayerIndex       := cmbbxSourceLayer.Items.Count - cmbbxSourceLayer.ItemIndex - 1;
        FSourceLayerPanel := FSourceChildForm.LayerPanelList.GetLayerPanelByIndex(LLayerIndex);

        if Assigned(FSourceLayerPanel) then
        begin
          if FSourceLayerPanel.IsHoldMaskInLayerAlpha then
          begin
            FSourceChannelOptionsStatus := cosExcludingRGB;
            FApplyImage.SourceChannel   := gmscsAlphaChannel;
            FSourceBitmap.Assign(FSourceLayerPanel.FMaskImage.Bitmap);
          end
          else
          begin
            FSourceChannelOptionsStatus := cosIncludingRGB;
            FApplyImage.SourceChannel   := gmscsRGB;
            FSourceBitmap.Assign(FSourceLayerPanel.AssociatedLayer.Bitmap);

            if FSourceLayerPanel.IsMaskLinked then
            begin
              ReplaceAlphaChannelWithMask(FSourceBitmap,
                FSourceLayerPanel.FLastAlphaChannelBmp);
            end;
          end;
        end;
      end;

      // source channel
      cmbbxSourceChannel.Items     := GetSourceChannelNames;
      cmbbxSourceChannel.ItemIndex := 0;

      // blend mode
      cmbbxBlendMode.Items       := BlendModeList;
      cmbbxBlendMode.ItemIndex   := 1;
      FApplyImage.BlendModeIndex := 1;

      // mask image
      cmbbxMaskImage.Items     := frmMain.GetFileNamesWithSameSizeImage;
      cmbbxMaskImage.ItemIndex := GetMaskFileNameIndex( ExtractFileName(ActiveChildForm.FileName) );
      FMaskChildForm           := frmMain.GetChildFormPointerByFileName(cmbbxMaskImage.Items[cmbbxMaskImage.ItemIndex]);

      // mask layer
      cmbbxMaskLayer.Items     := GetLayerNames(FMaskChildForm);
      cmbbxMaskLayer.ItemIndex := 0;

      if FMaskChildForm.LayerPanelList.Count > 1 then // merged image
      begin
        FMaskLayerPanel := nil; // not pointer to any layer panel
        FMaskChildForm.LayerPanelList.FlattenLayersToBitmap(FMaskBitmap, dmBlend);
      end
      else
      begin
        LLayerIndex     := cmbbxMaskLayer.Items.Count - cmbbxMaskLayer.ItemIndex - 1;
        FMaskLayerPanel := FMaskChildForm.LayerPanelList.GetLayerPanelByIndex(LLayerIndex);

        if Assigned(FMaskLayerPanel) then
        begin
          if FMaskLayerPanel.IsHoldMaskInLayerAlpha then
          begin
            FMaskChannelOptionsStatus := cosExcludingRGB;
            FApplyImage.MaskChannel   := gmscsAlphaChannel;
            FMaskBitmap.Assign(FMaskLayerPanel.FMaskImage.Bitmap);
          end
          else
          begin
            FMaskChannelOptionsStatus := cosIncludingRGB;
            FApplyImage.MaskChannel   := gmscsRGB;
            FMaskBitmap.Assign(FMaskLayerPanel.AssociatedLayer.Bitmap);

            if FMaskLayerPanel.IsMaskLinked then
            begin
              ReplaceAlphaChannelWithMask(FMaskBitmap,
                FMaskLayerPanel.FLastAlphaChannelBmp);
            end;
          end;
        end;
      end;

      // mask channel
      cmbbxMaskChannel.Items     := GetMaskChannelNames;
      cmbbxMaskChannel.ItemIndex := 0;
    finally
      FEnableChanging := True;
    end;

    ExecuteApplyImage;
  end;

  ActiveControl := btbtnOK;
end;

procedure TfrmApplyImage.cmbbxSourceChannelChange(Sender: TObject);
begin
  if Assigned(FApplyImage) then
  begin
    { Because of the selected source maybe just the target, and the target
      maybe changed due to preview the process result on target, so we need
      to restore the target before make the target as the source. }
    with ActiveChildForm do
    begin
      if Assigned(Selection) then
      begin
        Selection.CutOriginal.Assign(frmMain.FBeforeProc);
        ShowProcessedSelection(False);
      end
      else
      begin
        case ChannelManager.CurrentChannelType of
          wctAlpha:
            begin
              ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Assign(frmMain.FBeforeProc);
            end;
            
          wctLayerMask:
            begin
              LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Assign(frmMain.FBeforeProc);

              // if on special layers, save the Mask into layer's alpha channels
              if LayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
              begin
                LayerPanelList.SelectedLayerPanel.UpdateLayerAlphaWithMask;
              end;
            end;

          wctRGB, wctRed, wctGreen, wctBlue:
            begin
              LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Assign(frmMain.FBeforeProc);
            end;
        end;
      end;
    end;

    // get the proper source bitmap
    SetSourceBitmapBySourceChannelSettings;
    ExecuteApplyImage;
  end;
end;

procedure TfrmApplyImage.chckbxSourceChannelInvertClick(Sender: TObject);
begin
  if Assigned(FApplyImage) then
  begin
    FApplyImage.IsSourceChannelInverse := chckbxSourceChannelInvert.Checked;
    ExecuteApplyImage;
  end;
end;

procedure TfrmApplyImage.cmbbxBlendModeChange(Sender: TObject);
begin
  if Assigned(FApplyImage) then
  begin
    FApplyImage.BlendModeIndex := cmbbxBlendMode.ItemIndex;
    ExecuteApplyImage;
  end;
end; 

procedure TfrmApplyImage.edtBlendOpacityChange(Sender: TObject);
var
  ChangedValue: Integer;
begin
  if Assigned(FApplyImage) then
  begin
    try
      ChangedValue := StrToInt(edtBlendOpacity.Text);

      if (ChangedValue < 0) or (ChangedValue > 100) then
      begin
        ChangedValue := Clamp(ChangedValue, 0, 100);
        edtBlendOpacity.Text := IntToStr(ChangedValue);
      end;
      
      FApplyImage.BlendOpacity := 255 * ChangedValue div 100;
      ExecuteApplyImage;
    except
      edtBlendOpacity.Text := IntToStr(Round(FApplyImage.BlendOpacity / 255 * 100));
    end;
  end;
end;

procedure TfrmApplyImage.chckbxPreserveTransparencyClick(Sender: TObject);
begin
  if Assigned(FApplyImage) then
  begin
    FApplyImage.IsPreserveTransparency := chckbxPreserveTransparency.Checked;
    ExecuteApplyImage;
  end;  
end;

procedure TfrmApplyImage.chckbxEnableMaskClick(Sender: TObject);
begin
  lblMaskImage.Enabled   := chckbxEnableMask.Checked;
  lblMaskLayer.Enabled   := chckbxEnableMask.Checked;
  lblMaskChannel.Enabled := chckbxEnableMask.Checked;

  cmbbxMaskImage.Enabled   := chckbxEnableMask.Checked;
  cmbbxMaskLayer.Enabled   := chckbxEnableMask.Checked;
  cmbbxMaskChannel.Enabled := chckbxEnableMask.Checked;

  chckbxMaskChannelInvert.Enabled := chckbxEnableMask.Checked;
  ExecuteApplyImage;
end;

procedure TfrmApplyImage.cmbbxMaskImageChange(Sender: TObject);
begin
  if FEnableChanging then
  begin
    FMaskChildForm := frmMain.GetChildFormPointerByFileName(cmbbxMaskImage.Items[cmbbxMaskImage.ItemIndex]);

    // restore the channel selection to default -- Gray channel
    FMaskChannelOptionsStatus := cosIncludingRGB;
    cmbbxMaskChannel.Items    := GetMaskChannelNames;
    FEnableChanging := False; // avoid execute the OnChange event of this combo box
    try
      if cmbbxMaskChannel.ItemIndex <> 0 then
      begin
        cmbbxMaskChannel.ItemIndex := 0;
        FApplyImage.MaskChannel    := TgmSourceChannelSelector(0);
      end;
    finally
      FEnableChanging := True;
    end;

    // restore the layer selection to default -- merged layer
    cmbbxMaskLayer.Items     := GetLayerNames(FMaskChildForm);
    cmbbxMaskLayer.ItemIndex := 0;
    cmbbxMaskLayerChange(Sender);
  end;
end;

procedure TfrmApplyImage.cmbbxMaskLayerChange(Sender: TObject);
begin
  if FEnableChanging then
  begin
    if Assigned(FMaskChildForm) then
    begin
      { Because of the selected source maybe just the target, and the target
        maybe changed due to preview the process result on target, so we need
        to restore the target before make the target as the source. }
      with ActiveChildForm do
      begin
        if Assigned(Selection) then
        begin
          Selection.CutOriginal.Assign(frmMain.FBeforeProc);
          ShowProcessedSelection(False);
        end
        else
        begin
          case ChannelManager.CurrentChannelType of
            wctAlpha:
              begin
                ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Assign(frmMain.FBeforeProc);
              end;
              
            wctLayerMask:
              begin
                LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Assign(frmMain.FBeforeProc);

                // if on special layers, save the Mask into layer's alpha channels
                if LayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
                begin
                  LayerPanelList.SelectedLayerPanel.UpdateLayerAlphaWithMask;
                end;
              end;

            wctRGB, wctRed, wctGreen, wctBlue:
              begin
                LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Assign(frmMain.FBeforeProc);
              end;
          end;
        end;
      end;

      if cmbbxMaskLayer.ItemIndex >= 0 then
      begin
        // get the proper mask bitmap
        SetMaskBitmapByMaskLayerSettings;

        if (FMaskChildForm.LayerPanelList.Count > 1) and
           (cmbbxMaskLayer.ItemIndex = 0) then  // merged image
        begin
          FMaskChannelOptionsStatus := cosIncludingRGB;
          FApplyImage.MaskChannel   := gmscsRGB;
        end
        else
        begin
          if Assigned(FMaskLayerPanel) then
          begin
            if FMaskLayerPanel.IsHoldMaskInLayerAlpha then
            begin
              FMaskChannelOptionsStatus := cosExcludingRGB;
              FApplyImage.MaskChannel   := gmscsAlphaChannel;
            end
            else
            begin
              FMaskChannelOptionsStatus := cosIncludingRGB;
              FApplyImage.MaskChannel   := gmscsRGB;
            end;
          end;
        end;
        
        cmbbxMaskChannel.Items.Clear;
        cmbbxMaskChannel.Items     := GetMaskChannelNames;
        cmbbxMaskChannel.ItemIndex := 0;

        ExecuteApplyImage;
      end;
    end;
  end;
end;

procedure TfrmApplyImage.cmbbxMaskChannelChange(Sender: TObject);
begin
  if Assigned(FApplyImage) then
  begin
    { Because of the selected source maybe just the target, and the target
      maybe changed due to preview the process result on target, so we need
      to restore the target before make the target as the source. }
    with ActiveChildForm do
    begin
      if Assigned(Selection) then
      begin
        Selection.CutOriginal.Assign(frmMain.FBeforeProc);
        ShowProcessedSelection(False);
      end
      else
      begin
        case ChannelManager.CurrentChannelType of
          wctAlpha:
            begin
              ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Assign(frmMain.FBeforeProc);
            end;
            
          wctLayerMask:
            begin
              LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Assign(frmMain.FBeforeProc);

              // if on special layers, save the Mask into layer's alpha channels
              if LayerPanelList.SelectedLayerPanel.IsHoldMaskInLayerAlpha then
              begin
                LayerPanelList.SelectedLayerPanel.UpdateLayerAlphaWithMask;
              end;
            end;

          wctRGB, wctRed, wctGreen, wctBlue:
            begin
              LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Assign(frmMain.FBeforeProc);
            end;
        end;
      end;
    end;

    // get the proper mask bitmap
    SetMaskBitmapByMaskChannelSettings;
    ExecuteApplyImage;
  end;
end;

procedure TfrmApplyImage.chckbxMaskChannelInvertClick(Sender: TObject);
begin
  if Assigned(FApplyImage) then
  begin
    FApplyImage.IsMaskChannelInverse := chckbxMaskChannelInvert.Checked;
    ExecuteApplyImage;
  end; 
end;

procedure TfrmApplyImage.chckbxPreviewClick(Sender: TObject);
begin
  if chckbxPreview.Checked then
  begin
    ExecuteApplyImage;
  end
  else
  begin
    with ActiveChildForm do
    begin
      if Assigned(Selection) then
      begin
        Selection.CutOriginal.Assign(frmMain.FBeforeProc);
        ShowProcessedSelection;
      end
      else
      begin
        case ChannelManager.CurrentChannelType of
          wctAlpha:
            begin
              ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Bitmap.Assign(frmMain.FBeforeProc);
              ChannelManager.SelectedAlphaChannelPanel.AlphaLayer.Changed;
            end;

          wctLayerMask:
            begin
              LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap.Assign(frmMain.FBeforeProc);

              // update the layer mask channel
              if Assigned(ChannelManager.LayerMaskPanel) then
              begin
                ChannelManager.LayerMaskPanel.AlphaLayer.Bitmap.Draw(0, 0,
                  LayerPanelList.SelectedLayerPanel.FMaskImage.Bitmap);
              end;

              LayerPanelList.SelectedLayerPanel.Update;
            end;

          wctRGB, wctRed, wctGreen, wctBlue:
            begin
              LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Assign(frmMain.FBeforeProc);
              LayerPanelList.SelectedLayerPanel.Update;
            end;
        end;
      end;
    end;
  end;
end; 

procedure TfrmApplyImage.btbtnOKClick(Sender: TObject);
var
  LCmdAim           : TCommandAim;
  LHistoryStatePanel: TgmHistoryStatePanel;
begin
  with ActiveChildForm do
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
      'Apply Image',
      frmMain.FBeforeProc,
      frmMain.FAfterProc,
      Selection,
      ChannelManager.SelectedAlphaChannelIndex);

    HistoryManager.AddHistoryState(LHistoryStatePanel);
  end;
end; 

end.
