{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

unit gmPathPanels;

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

{$WARN UNSAFE_CAST OFF}

interface

uses
{ Standard }
  Windows, SysUtils, StdCtrls, ExtCtrls, Controls, Graphics, Classes,
{ GraphicsMagic Lib }
  gmPenTools;

type
  TgmPathPanelType = (pptWorkPath, pptNamedPath);

//-- TgmPathPanel --------------------------------------------------------------

  TgmPathPanel = class(TObject)
  private
    FPanel        : TPanel;       // main panel
    FImageHolder  : TPanel;       // panel for holding TImage
    FImage        : TImage;       // used for showing the thumbnail of the path
    FPathNameLabel: TLabel;       // used for showing the name of the path
    FPathName     : string;
    FNamed        : Boolean;
    FSelected     : Boolean;
    FPathBitmap   : TBitmap;      // drawing whole path on this bitmap
    FThumbnail    : TBitmap;
    FPenPathList  : TgmPenPathList;
  public
    constructor Create(const AOwner: TWinControl; const APanelType: TgmPathPanelType);
    destructor Destroy; override;

    procedure ShowPathPanelName;
   
    procedure UpdateThumbnail(const AOriginalWidth, AOriginalHeight: Integer;
      const AOffsetVector: TPoint);

    procedure SaveToStream(const AMemStream: TMemoryStream);

    property MainPanel    : TPanel         read FPanel;
    property ImageHolder  : TPanel         read FImageHolder;
    property PathImage    : TImage         read FImage;
    property PathNameLabel: TLabel         read FPathNameLabel;
    property PathName     : string         read FPathName       write FPathName;
    property IsNamed      : Boolean        read FNamed          write FNamed;
    property IsSelected   : Boolean        read FSelected       write FSelected;
    property PenPathList  : TgmPenPathList read FPenPathList;
  end;

//-- TgmPathPanelList ----------------------------------------------------------

  TgmPathPanelList = class(TList)
  private
    FPathPanelOwner    : TWinControl;   // pointer to a Win control for holding path panels
    FSelectedPanel     : TgmPathPanel;  // current selected path panel
    FSelectedPanelIndex: Integer;       // index of current selected path panel
    FPathPanelNumber   : Integer;

    { Using FEnabled could enable/disable certain functionalies of
      the path panel manager temporarily. }
    FEnabled               : Boolean;
    FAllowRefreshPathPanels: Boolean; // indicating if we could refresh the path panels

    FOnPathPanelClick   : TNotifyEvent;
    FOnPathPanelDblClick: TNotifyEvent;
    FOnUpdatePanelState : TNotifyEvent;

    procedure ConnectEventsToPathPanel(const APathPanel: TgmPathPanel);
    procedure PathPanelClick(ASender: TObject);
    procedure PathPanelDblClick(ASender: TObject);
    function GetCurrentPathPanelIndex(ASender: TObject): Integer;
  public
    constructor Create(const AOwner: TWinControl);
    destructor Destroy; override;

    procedure AddPathPanelToList(const APathPanel: TgmPathPanel);
    procedure AdjustPathPanelsOrder;
    procedure SelectPathPanelByIndex(const AIndex: Integer);
    procedure DeleteSelectedPathPanel;
    procedure DeletePathPanelByIndex(const AIndex: Integer);
    procedure DeleteAllPathPanels;
    procedure DeselectAllPathPanels;
    procedure InsertPathPanelToList(const APathPanel: TgmPathPanel; const AIndex: Integer);
    procedure UpdateAllPanelsState;
    procedure HideAllPathPanels;
    procedure ShowAllPathPanels;
    procedure TranslateAllPathsInPanel(const ATranslateVector: TPoint);
    procedure ScaleAllPathsInPanel(const AOldWidth, AOldHeight, ANewWidth, ANewHeight: Integer);
    procedure UpdateAllThumbnails(const AOriginalWidth, AOriginalHeight: Integer; const AOffsetVector: TPoint);

    function ActivateWorkPath: TgmPathPanel;  // activate and return Work Path
    function IfLastPathPanelNamed: Boolean; // determine whether the last path panel is named

    function LoadPathPanelsFromStream(const AMemoryStream: TMemoryStream;
      const AVersionNum, ALoadCount: Integer): Boolean;

    // save the path panels to memory stream for output them in '*.gmd' file later
    procedure SavePathPanelsToStream(const AMemoryStream: TMemoryStream);

    property PathPanelNumber         : Integer      read FPathPanelNumber        write FPathPanelNumber;
    property SelectedPanelIndex      : Integer      read FSelectedPanelIndex;
    property SelectedPanel           : TgmPathPanel read FSelectedPanel;
    property IsEnabled               : Boolean      read FEnabled                write FEnabled;
    property IsAllowRefreshPathPanels: Boolean      read FAllowRefreshPathPanels write FAllowRefreshPathPanels;
    property OnPathPanelClick        : TNotifyEvent read FOnPathPanelClick       write FOnPathPanelClick;
    property OnPathPanelDblClick     : TNotifyEvent read FOnPathPanelDblClick    write FOnPathPanelDblClick;
    property OnUpdatePanelState      : TNotifyEvent read FOnUpdatePanelState     write FOnUpdatePanelState;
  end;

implementation

uses
  gmImageProcessFuncs,
  gmGUIFuncs;

type
  TgmPathPanelHeaderVer1 = record
    PathPanelType: Cardinal;
    PathPanelName: string[255];
  end;

//-- TgmPathPanelReader --------------------------------------------------------

  TgmPathPanelReader = class(TObject)
  public
    function GetPathPanelFormStream(const AMemoryStream: TMemoryStream;
      const APathPanelHolder: TWinControl): TgmPathPanel; virtual; abstract;
  end;

//-- TgmPathPanelReader1 -------------------------------------------------------

  TgmPathPanelReader1 = class(TgmPathPanelReader)
  public
    function GetPathPanelFormStream(const AMemoryStream: TMemoryStream;
      const APathPanelHolder: TWinControl): TgmPathPanel; override;
  end;

const
  PATH_PANEL_HEIGHT : Integer = 41;
  IMAGE_HOLDER_WIDTH: Integer = 39;
  IMAGE_WIDTH       : Integer = 31;
  IMAGE_HEIGHT      : Integer = 31;

//-- TgmPathPanel --------------------------------------------------------------

constructor TgmPathPanel.Create(const AOwner: TWinControl;
  const APanelType: TgmPathPanelType);
begin
  Inherited Create;

  // create a path panel
  FPanel            := TPanel.Create(AOwner);
  FPanel.Parent     := AOwner;
  FPanel.Align      := alTop;
  FPanel.AutoSize   := False;
  FPanel.Height     := PATH_PANEL_HEIGHT;
  FPanel.BevelInner := bvLowered;
  FPanel.BevelOuter := bvRaised;
  FPanel.BevelWidth := 1;
  FPanel.Color      := clBackground;
  FPanel.Cursor     := crHandPoint;
  FPanel.ShowHint   := False;
  FPanel.Visible    := False;

  // create a panel for holding FImage
  FImageHolder            := TPanel.Create(FPanel);
  FImageHolder.Parent     := FPanel;
  FImageHolder.Align      := alLeft;
  FImageHolder.AutoSize   := False;
  FImageHolder.Width      := IMAGE_HOLDER_WIDTH;
  FImageHolder.BevelInner := bvRaised;
  FImageHolder.BevelOuter := bvLowered;
  FImageHolder.BevelWidth := 1;
  FImageHolder.Cursor     := crHandPoint;
  FImageHolder.Visible    := True;

  // create FImage for holding thumbnail of the path
  FImage                       := TImage.Create(FImageHolder);
  FImage.Parent                := FImageHolder;
  FImage.Width                 := IMAGE_WIDTH;
  FImage.Height                := IMAGE_HEIGHT;
  FImage.Picture.Bitmap.Width  := IMAGE_WIDTH;
  FImage.Picture.Bitmap.Height := IMAGE_HEIGHT;
  FImage.AutoSize              := True;
  FImage.Stretch               := False;
  FImage.Cursor                := crHandPoint;
  FImage.Top                   := 4;
  FImage.Left                  := 4;
  FImage.Visible               := True;

  // create a label for showing the name of the path panel
  FPathNameLabel            := TLabel.Create(FPanel);
  FPathNameLabel.Parent     := FPanel;
  FPathNameLabel.Align      := alNone;
  FPathNameLabel.Left       := FImageHolder.Width + 10;
  FPathNameLabel.Top        := (FPanel.Height - FPathNameLabel.Height) div 2;
  FPathNameLabel.Caption    := 'Work Path';
  FPathNameLabel.Cursor     := crHandPoint;
  FPathNameLabel.Font.Color := clWhite;
  FPathNameLabel.Font.Style := FPathNameLabel.Font.Style + [fsItalic];
  FPathNameLabel.ShowHint   := True;
  FPathNameLabel.Visible    := True;

  // Create FPathBitmap
  FPathBitmap := TBitmap.Create;
  FPathBitmap.PixelFormat := pf24bit;

  // Create FThumbnail
  FThumbnail             := TBitmap.Create;
  FThumbnail.PixelFormat := pf24bit;

  // Create path list
  FPenPathList := TgmPenPathList.Create;

  case APanelType of
    pptWorkPath:
      begin
        FNamed := False;
      end;

    pptNamedPath:
      begin
        FNamed := True;
      end;
  end;
  
  FPathName := '';
  FSelected := True;
end; 

destructor TgmPathPanel.Destroy;
begin
  FImage.Free;
  FImageHolder.Free;
  FPathNameLabel.Free;
  FPanel.Free;
  FPathBitmap.Free;
  FThumbnail.Free;
  FPenPathList.Free;

  inherited Destroy;
end;

procedure TgmPathPanel.ShowPathPanelName;
begin
  FPathNameLabel.Caption    := FPathName;
  FPathNameLabel.Font.Style := FPathNameLabel.Font.Style - [fsItalic];
end;

procedure TgmPathPanel.UpdateThumbnail(
  const AOriginalWidth, AOriginalHeight: Integer; const AOffsetVector: TPoint);
begin
  // filling the background
  FPathBitmap.Width              := AOriginalWidth;
  FPathBitmap.Height             := AOriginalHeight;
  FPathBitmap.Canvas.Brush.Color := clGray;
  FPathBitmap.Canvas.FillRect(FPathBitmap.Canvas.ClipRect);
  
  // drawing the path, filling regions and draing outlines of paths
  FPenPathList.DrawAllPathRegionsForThumbnail(FPathBitmap.Canvas, AOffsetVector);
  FPenPathList.DrawAllPathsForThumbnail(FPathBitmap.Canvas, AOffsetVector);

  // get the thumbnail and display it
  GetScaledBitmap(FPathBitmap, FThumbnail, IMAGE_WIDTH, IMAGE_HEIGHT);
  FImage.Picture.Bitmap.Assign(FThumbnail);
  CenterImageInPanel(FImageHolder, FImage);
end;

procedure TgmPathPanel.SaveToStream(const AMemStream: TMemoryStream);
var
  LPathPanelHeader: TgmPathPanelHeaderVer1;
begin
  if FNamed then
  begin
    LPathPanelHeader.PathPanelType := Ord(pptNamedPath);
  end
  else
  begin
    LPathPanelHeader.PathPanelType := Ord(pptWorkPath);
  end;

  LPathPanelHeader.PathPanelName := FPathNameLabel.Caption;

  // write path panel header to stream
  AMemStream.Write(LPathPanelHeader, SizeOf(TgmPathPanelHeaderVer1));

  // write path info to stream
  FPenPathList.SavePenPathsToStream(AMemStream);
end;  

//-- TgmPathPanelList ----------------------------------------------------------

constructor TgmPathPanelList.Create(const AOwner: TWinControl);
begin
  inherited Create;

  FPathPanelOwner         := AOwner;
  FSelectedPanel          := nil;
  FSelectedPanelIndex     := -1;
  FPathPanelNumber        := 0;
  FEnabled                := True;
  FAllowRefreshPathPanels := True;
  FOnPathPanelClick       := nil;
  FOnPathPanelDblClick    := nil;
  FOnUpdatePanelState     := nil;
end;

destructor TgmPathPanelList.Destroy;
begin
  DeleteAllPathPanels;

  FPathPanelOwner      := nil;
  FOnPathPanelClick    := nil;
  FOnPathPanelDblClick := nil;
  FOnUpdatePanelState  := nil;

  inherited Destroy;
end;

procedure TgmPathPanelList.ConnectEventsToPathPanel(
  const APathPanel: TgmPathPanel);
begin
  with APathPanel do
  begin
    // Click events
    MainPanel.OnClick     := PathPanelClick;
    ImageHolder.OnClick   := PathPanelClick;
    PathImage.OnClick     := PathPanelClick;
    PathNameLabel.OnClick := PathPanelClick;
    
    // Double click events
    MainPanel.OnDblClick     := PathPanelDblClick;
    ImageHolder.OnDblClick   := PathPanelDblClick;
    PathImage.OnDblClick     := PathPanelDblClick;
    PathNameLabel.OnDblClick := PathPanelDblClick;
  end;
end;

procedure TgmPathPanelList.PathPanelClick(ASender: TObject);
var
  i, LIndex : Integer;
  LPathPanel: TgmPathPanel;
begin
  if not FEnabled then
  begin
    Exit;
  end;

  if Self.Count > 0 then
  begin
    LIndex := GetCurrentPathPanelIndex(ASender);

    if (Self.Count = 1) or (LIndex <> FSelectedPanelIndex) then
    begin
      // deselect all path panels if there are at least two path panels in the list
      if Self.Count > 1 then
      begin
        DeselectAllPathPanels;
      end;

      for i := 0 to (Self.Count - 1) do
      begin
        LPathPanel := TgmPathPanel(Self.Items[i]);

        if (ASender = LPathPanel.MainPanel) or
           (ASender = LPathPanel.ImageHolder) or
           (ASender = LPathPanel.PathImage) or
           (ASender = LPathPanel.PathNameLabel) then
        begin
          FSelectedPanelIndex   := i;
          LPathPanel.IsSelected := True;

          FSelectedPanel := LPathPanel;
          Break;
        end;
      end;

      UpdateAllPanelsState;

      // calling callback function
      if Assigned(FOnPathPanelClick) then
      begin
        FOnPathPanelClick(ASender);
      end;
    end;
  end;
end;

procedure TgmPathPanelList.PathPanelDblClick(ASender: TObject);
begin
  if Assigned(FOnPathPanelDblClick) then
  begin
    FOnPathPanelDblClick(ASender);
  end;
end;

function TgmPathPanelList.GetCurrentPathPanelIndex(ASender: TObject): Integer;
var
  i         : Integer;
  LPathPanel: TgmPathPanel;
begin
  Result := -1;

  if Self.Count > 0 then
  begin
    for i := 0 to (Self.Count - 1) do
    begin
      LPathPanel := TgmPathPanel(Self.Items[i]);

      if (ASender = LPathPanel.MainPanel) or
         (ASender = LPathPanel.ImageHolder) or
         (ASender = LPathPanel.PathImage) or
         (ASender = LPathPanel.PathNameLabel) then
      begin
        Result := i;
        Break;
      end;
    end;
  end;
end;

procedure TgmPathPanelList.DeleteAllPathPanels;
var
  i         : Integer;
  LPathPanel: TgmPathPanel;
begin
  if Self.Count > 0 then
  begin
    FSelectedPanel      := nil;
    FSelectedPanelIndex := -1;
    FPathPanelNumber    := 0;

    for i := (Self.Count - 1) downto 0 do
    begin
      LPathPanel := TgmPathPanel(Self.Items[i]);
      LPathPanel.MainPanel.Visible := False;
      LPathPanel.Free;
    end;

    Self.Clear;
  end;
end;

procedure TgmPathPanelList.AddPathPanelToList(const APathPanel: TgmPathPanel);
begin
  DeselectAllPathPanels;
  ConnectEventsToPathPanel(APathPanel);
  Self.Add(APathPanel);

  // give the path panel a default name
  if APathPanel.IsNamed then
  begin
    Inc(FPathPanelNumber);
    APathPanel.PathName := 'Path' + ' ' + IntToStr(FPathPanelNumber);
    APathPanel.ShowPathPanelName;
  end;

  FSelectedPanelIndex := Self.Count - 1;
  FSelectedPanel      := APathPanel;

  UpdateAllPanelsState;
  AdjustPathPanelsOrder;
end;

procedure TgmPathPanelList.AdjustPathPanelsOrder;
var
  i         : Integer;
  LPathPanel: TgmPathPanel;
begin
  if not FAllowRefreshPathPanels then
  begin
    Exit;
  end;

  if Self.Count > 0 then
  begin
    HideAllPathPanels;

    // adjust the position of the path panels
    for i := 0 to (Self.Count - 1) do
    begin
      LPathPanel := TgmPathPanel(Self.Items[i]);
      LPathPanel.MainPanel.Left := 0;
      LPathPanel.MainPanel.Top  := i * PATH_PANEL_HEIGHT;
    end;

    ShowAllPathPanels;
  end;
end;

procedure TgmPathPanelList.SelectPathPanelByIndex(const AIndex: Integer);
begin
  if Self.Count > 0 then
  begin
    if (AIndex >= 0) and (AIndex < Self.Count) then
    begin
      DeselectAllPathPanels;
      FSelectedPanelIndex       := AIndex;
      FSelectedPanel            := TgmPathPanel(Self.Items[AIndex]);
      FSelectedPanel.IsSelected := True;
      UpdateAllPanelsState;
    end;
  end;
end;

procedure TgmPathPanelList.DeleteSelectedPathPanel;
var
  LPathPanel: TgmPathPanel;
begin
  if Self.Count > 0 then
  begin
    if FSelectedPanelIndex > -1 then
    begin
      FSelectedPanel := nil;
      LPathPanel     := TgmPathPanel(Self.Items[FSelectedPanelIndex]);

      LPathPanel.PenPathList.Clear;
      HideAllPathPanels;
      LPathPanel.Free;
      Self.Delete(FSelectedPanelIndex);
      FSelectedPanelIndex := -1;
      AdjustPathPanelsOrder;
    end;
  end;
end;

procedure TgmPathPanelList.DeletePathPanelByIndex(const AIndex: Integer);
var
  LPathPanel: TgmPathPanel;
begin
  if Self.Count > 0 then
  begin
    if (AIndex >= 0) and (AIndex < Self.Count) then
    begin
      DeselectAllPathPanels;
      LPathPanel := TgmPathPanel(Self.Items[AIndex]);
      LPathPanel.MainPanel.Hide;
      LPathPanel.Free;
      Self.Delete(AIndex);
    end;
  end;
end;

procedure TgmPathPanelList.DeselectAllPathPanels;
var
  i        : Integer;
  LPathPanel: TgmPathPanel;
begin
  FSelectedPanelIndex := -1;
  FSelectedPanel      := nil;

  if Self.Count > 0 then
  begin
    for i := 0 to (Self.Count - 1) do
    begin
      LPathPanel := TgmPathPanel(Self.Items[i]);
      
      if LPathPanel.isSelected then
      begin
        LPathPanel.IsSelected                := False;
        LPathPanel.PenPathList.PathListState := plsAddNewPath;
        LPathPanel.PenPathList.DeselectAllPaths;
      end;
    end;
  end;
end;

procedure TgmPathPanelList.InsertPathPanelToList(
  const APathPanel: TgmPathPanel; const AIndex: Integer);
begin
  if Self.Count > 0 then
  begin
    if (AIndex >= 0) and (AIndex < Self.Count) then
    begin
      DeselectAllPathPanels;
      ConnectEventsToPathPanel(APathPanel);
      Self.Insert(AIndex, APathPanel);
      Inc(FPathPanelNumber);

      // naming the inserted path panel
      APathPanel.PathName := 'Path' + ' ' + IntToStr(FPathPanelNumber);
      APathPanel.ShowPathPanelName;

      FSelectedPanelIndex := AIndex;
      UpdateAllPanelsState;
      AdjustPathPanelsOrder;
      FSelectedPanel := APathPanel;
    end;
  end;
end;

procedure TgmPathPanelList.UpdateAllPanelsState;
var
  i         : Integer;
  LPathPanel: TgmPathPanel;
begin
  if Self.Count > 0 then
  begin
    for i := 0 to (Self.Count - 1) do
    begin
      LPathPanel := TgmPathPanel(Self.Items[i]);

      case LPathPanel.IsSelected of
        True:
          begin
            LPathPanel.MainPanel.BevelInner     := bvLowered;
            LPathPanel.MainPanel.Color          := clBackground;
            LPathPanel.PathNameLabel.Font.Color := clWhite;
          end;

        False:
          begin
            LPathPanel.MainPanel.BevelInner     := bvRaised;
            LPathPanel.MainPanel.Color          := clBtnFace;
            LPathPanel.PathNameLabel.Font.Color := clBlack;
          end;
      end
    end;

    if Assigned(FOnUpdatePanelState) then
    begin
      FOnUpdatePanelState(nil);
    end;
  end;
end;

procedure TgmPathPanelList.HideAllPathPanels;
var
  i         : Integer;
  LPathPanel: TgmPathPanel;
begin
  if Self.Count > 0 then
  begin
    for i := 0 to (Self.Count - 1) do
    begin
      LPathPanel := TgmPathPanel(Self.Items[i]);
      LPathPanel.MainPanel.Hide;
    end;
  end;
end;

procedure TgmPathPanelList.ShowAllPathPanels;
var
  i         : Integer;
  LPathPanel: TgmPathPanel;
begin
  if Self.Count > 0 then
  begin
    for i := 0 to (Self.Count - 1) do
    begin
      LPathPanel := TgmPathPanel(Self.Items[i]);
      LPathPanel.MainPanel.Show;
    end;
  end;
end;

procedure TgmPathPanelList.TranslateAllPathsInPanel(
  const ATranslateVector: TPoint);
var
  i         : Integer;
  LPathPanel: TgmPathPanel;
begin
  if Self.Count > 0 then
  begin
    for i := 0 to (Self.Count - 1) do
    begin
      LPathPanel := TgmPathPanel(Self.Items[i]);
      LPathPanel.PenPathList.TranslateAllPaths(ATranslateVector);
    end;
  end;
end;

procedure TgmPathPanelList.ScaleAllPathsInPanel(
  const AOldWidth, AOldHeight, ANewWidth, ANewHeight: Integer);
var
  i         : Integer;
  LPathPanel: TgmPathPanel;
begin
  if Self.Count > 0 then
  begin
    for i := 0 to (Self.Count - 1) do
    begin
      LPathPanel := TgmPathPanel(Self.Items[i]);

      LPathPanel.PenPathList.ScaleAllPaths(AOldWidth, AOldHeight,
                                           ANewWidth, ANewHeight);
    end;
  end;
end;

procedure TgmPathPanelList.UpdateAllThumbnails(
  const AOriginalWidth, AOriginalHeight: Integer; const AOffsetVector: TPoint);
var
  i         : Integer;
  LPathPanel: TgmPathPanel;
begin
  if Self.Count > 0 then
  begin
    for i := 0 to (Self.Count - 1) do
    begin
      LPathPanel := TgmPathPanel(Self.Items[i]);
      LPathPanel.UpdateThumbnail(AOriginalWidth, AOriginalHeight, AOffsetVector);
    end;
  end;
end; 

// activate and return Work Path
function TgmPathPanelList.ActivateWorkPath: TgmPathPanel;
begin
  Result := nil;

  if Self.Count > 0 then
  begin
    FSelectedPanel := TgmPathPanel(Self.Items[Self.Count - 1]);

    FSelectedPanel.PenPathList.Clear;

    FSelectedPanel.PenPathList.PathListState := plsAddNewPath;
    FSelectedPanel.IsSelected                := True;
    FSelectedPanelIndex                      := Self.Count - 1;

    UpdateAllPanelsState;
    
    Result := FSelectedPanel;
  end;
end;

// determine whether the last path panel is named
function TgmPathPanelList.IfLastPathPanelNamed: Boolean;
var
  LPathPanel: TgmPathPanel;
begin
  Result := False;
  
  if Self.Count > 0 then
  begin
    LPathPanel := TgmPathPanel(Self.Items[Self.Count - 1]);
    Result     := LPathPanel.IsNamed;
  end;
end;

function TgmPathPanelList.LoadPathPanelsFromStream(
  const AMemoryStream: TMemoryStream;
  const AVersionNum, ALoadCount: Integer): Boolean;
var
  LPathPanelReader: TgmPathPanelReader;
  LPathPanel      : TgmPathPanel;
  i               : Integer;
begin
  Result := False;

  if not Assigned(AMemoryStream) then
  begin
    Exit;
  end;

  if ALoadCount <= 0 then
  begin
    Exit;
  end;

  case AVersionNum of
    1, 2, 3: // same data in a .gmd file with version 1, 2 and 3
      begin
        Self.DeleteAllPathPanels;

        LPathPanelReader := TgmPathPanelReader1.Create;
        try
          for i := 0 to (ALoadCount - 1) do
          begin
            LPathPanel := LPathPanelReader.GetPathPanelFormStream(AMemoryStream, FPathPanelOwner);

            if Assigned(LPathPanel) then
            begin
              ConnectEventsToPathPanel(LPathPanel);
              Self.Add(LPathPanel);
            end;
          end;

          UpdateAllPanelsState;
          AdjustPathPanelsOrder;
        finally
          LPathPanelReader.Free;
        end;

        Result := True;
      end;
  end;
end;

// save the path panels to memory stream for output them in '*.gmd' file later
procedure TgmPathPanelList.SavePathPanelsToStream(
  const AMemoryStream: TMemoryStream);
var
  i         : Integer;
  LPathPanel: TgmPathPanel;
begin
  if (Self.Count > 0) and Assigned(AMemoryStream) then
  begin
    for i := 0 to Self.Count - 1 do
    begin
      LPathPanel := TgmPathPanel(Self.Items[i]);
      LPathPanel.SaveToStream(AMemoryStream);
    end;
  end;
end; 

//-- TgmPathPanelReader1 -------------------------------------------------------

function TgmPathPanelReader1.GetPathPanelFormStream(
  const AMemoryStream: TMemoryStream;
  const APathPanelHolder: TWinControl): TgmPathPanel;
var
  LPathPanelHeader: TgmPathPanelHeaderVer1;
begin
  Result := nil;

  if Assigned(AMemoryStream) then
  begin
    AMemoryStream.Read(LPathPanelHeader, SizeOf(TgmPathPanelHeaderVer1));

    Result            := TgmPathPanel.Create(APathPanelHolder, TgmPathPanelType(LPathPanelHeader.PathPanelType));
    Result.PathName   := LPathPanelHeader.PathPanelName;
    Result.IsSelected := False;

    Result.ShowPathPanelName;
    Result.PenPathList.LoadPenPathsFromStream(AMemoryStream, 1);
  end;
end;

end.
