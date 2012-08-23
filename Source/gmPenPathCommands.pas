{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

unit gmPenPathCommands;

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
  Windows,
{ GraphicsMagic Lib }
  gmCommands, gmPenTools, gmSelection;

type
  TgmModifyPathMode = (mpmNone,
                       mpmNewAnchorPoint,
                       mpmPickupPath,
                       mpmAddAnchorPoint,
                       mpmDeleteAnchorPoint,
                       mpmNewPathComponent,
                       mpmChangeAnchorPoint,
                       mpmCornerDrag,
                       mpmDragAnchorPoint,
                       mpmDragControlPoint);

//-- TgmNewWorkPathCommand -----------------------------------------------------

  TgmNewWorkPathCommand = class(TgmCommand)
  private
    FOldPenPath    : TgmPenPath;
    FPathPanelIndex: Integer;
  public
    constructor Create(const APathPanelIndex: Integer; const APenPath: TgmPenPath);
    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmModifyPathCommand ------------------------------------------------------

  TgmModifyPathCommand = class(TgmCommand)
  private
    FModifyMode    : TgmModifyPathMode;
    FPathPanelIndex: Integer;
    FOldPathIndex  : Integer;
    FNewPathIndex  : Integer;
    FOldPathList   : TgmPenPathList;
    FNewPathList   : TgmPenPathList;

    function GetCommandName: string;
  public
    constructor Create(
      const APathPanelIndex, AOldPathIndex, ANewPathIndex: Integer;
      const AOldPathList, ANewPathList: TgmPenPathList;
      const AModifyMode: TgmModifyPathMode);

    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmActiveWorkPathCommand --------------------------------------------------

  TgmActiveWorkPathCommand = class(TgmCommand)
  private
    FOldPenPathList: TgmPenPathList;
    FNewPenPath    : TgmPenPath;
    FPathPanelIndex: Integer;
  public
    constructor Create(const APathPanelIndex: Integer;
      const AOldPenPathList: TgmPenPathList; const APenPath: TgmPenPath);

    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmClosePathCommand -------------------------------------------------------

  TgmClosePathCommand = class(TgmCommand)
  private
    FPathPanelIndex: Integer;
    FPathIndex     : Integer;
    FOldPathList   : TgmPenPathList;
  public
    constructor Create(const APathPanelIndex, APathIndex: Integer;
      const AOldPathList: TgmPenPathList);

    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmTranslatePathsCommand --------------------------------------------------

  TgmTranslatePathsCommand = class(TgmCommand)
  private
    FAccumTranslateVector       : TPoint;
    FPathPanelIndex             : Integer;
    FWholeSelectedPathIndexArray: array of Integer;
  public
    constructor Create(const APathPanelIndex: Integer;
      const AAccumTranslateVector: TPoint);

    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmNewPathCommand ---------------------------------------------------------

  TgmNewPathCommand = class(TgmCommand)
  private
    FNewPathPanelIndex: Integer;
    FUndoIndex        : Integer;
    FOldPathList      : TgmPenPathList;
  public
    constructor Create(const AOldPathPanelIndex, ANewPathPanelIndex: Integer;
                       const AOldPathList: TgmPenPathList);

    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmDeletePathCommand ------------------------------------------------------

  TgmDeletePathCommand = class(TgmCommand)
  private
    FPathPanelIndex: Integer;
    FRedoIndex     : Integer;
    FOldPathList   : TgmPenPathList;
    FPathPanelName : string;
  public
    constructor Create(const APathPanelIndex: Integer);
    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

//-- TgmPathToSelectionCommand -------------------------------------------------

  TgmPathToSelectionCommand = class(TgmCommand)
  private
    FUndoSelection : TgmSelection;
    FRedoPathList  : TgmPenPathList;
    FPathPanelIndex: Integer;
  public
    constructor Create(const AOldSelection: TgmSelection;
      const APathList: TgmPenPathList);

    destructor Destroy; override;

    procedure Rollback; override;
    procedure Execute; override;
  end;

implementation

uses
{ Standard }
  SysUtils,
{ Graphics32 }
  GR32,
{ GraphicsMagic Lib }
  gmPathPanels,
  gmLayerAndChannel,
{ GraphicsMaigc Forms/Dialogs }
  MainForm,
  LayerForm,
  PathForm;

//-- TgmNewWorkPathCommand -----------------------------------------------------

constructor TgmNewWorkPathCommand.Create(const APathPanelIndex: Integer;
  const APenPath: TgmPenPath);
begin
  inherited Create(caNone, 'New Work Path');

  FOperateName    := 'Undo ' + FCommandName;
  FPathPanelIndex := APathPanelIndex;

  if Assigned(APenPath) then
  begin
    FOldPenPath := TgmPenPath.Create;
    FOldPenPath := APenPath.GetSelfBackup;
  end
  else
  begin
    FOldPenPath := nil;
  end;
end;

destructor TgmNewWorkPathCommand.Destroy;
begin
  FOldPenPath.Free;

  inherited Destroy;
end;

procedure TgmNewWorkPathCommand.Rollback;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  ActiveChildForm.PathPanelList.DeletePathPanelByIndex(FPathPanelIndex);
  ActiveChildForm.PathPanelList.UpdateAllPanelsState;

  ActiveChildForm.FPenPath := nil;

  ProcessAfterPenPathCommandDone;
end;

procedure TgmNewWorkPathCommand.Execute;
var
  LPathPanel: TgmPathPanel;
  LPenPath  : TgmPenPath;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  if Assigned(FOldPenPath) then
  begin
    LPathPanel := TgmPathPanel.Create(frmPath.scrlbxPathPanelContainer, pptWorkPath);
    LPenPath   := FOldPenPath.GetSelfBackup;

    LPathPanel.PenPathList.AddNewPathToList(LPenPath);
    ActiveChildForm.PathPanelList.AddPathPanelToList(LPathPanel);

    ActiveChildForm.FPenPath := LPenPath;
  end;

  ProcessAfterPenPathCommandDone;
end;

//-- TgmModifyPathCommand ------------------------------------------------------

constructor TgmModifyPathCommand.Create(
  const APathPanelIndex, AOldPathIndex, ANewPathIndex: Integer;
  const AOldPathList, ANewPathList: TgmPenPathList;
  const AModifyMode: TgmModifyPathMode);
begin
  inherited Create(caNone, '');

  FModifyMode     := AModifyMode;
  FCommandName    := GetCommandName;
  FOperateName    := 'Undo ' + FCommandName;
  FPathPanelIndex := APathPanelIndex;
  FOldPathIndex   := AOldPathIndex;
  FNewPathIndex   := ANewPathIndex;

  if Assigned(AOldPathList) then
  begin
    FOldPathList := TgmPenPathList.Create;
    FOldPathList.AssignPenPathListData(AOldPathList);
  end
  else
  begin
    FOldPathList := nil;
  end;

  if Assigned(ANewPathList) then
  begin
    FNewPathList := TgmPenPathList.Create;
    FNewPathList.AssignPenPathListData(ANewPathList);
  end
  else
  begin
    FNewPathList := nil;
  end;
end;

destructor TgmModifyPathCommand.Destroy;
begin
  FOldPathList.Free;
  FNewPathList.Free;
  
  inherited Destroy;
end;

function TgmModifyPathCommand.GetCommandName: string;
begin
  case FModifyMode of
    mpmNewAnchorPoint   : Result := 'New Anchor Point';
    mpmPickupPath       : Result := 'Pick-up Path';
    mpmAddAnchorPoint   : Result := 'Add Anchor Point';
    mpmDeleteAnchorPoint: Result := 'Delete Anchor Point';
    mpmNewPathComponent : Result := 'New Path Component';
    mpmChangeAnchorPoint: Result := 'Change Anchor Point';
    mpmCornerDrag       : Result := 'Corner Drag';
    mpmDragAnchorPoint  : Result := 'Drag Anchor Point';
    mpmDragControlPoint : Result := 'Drag Control Point';
  end;
end; 

procedure TgmModifyPathCommand.Rollback;
var
  LPathPanel: TgmPathPanel;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  if Assigned(FOldPathList) then
  begin
    // update the paths
    LPathPanel := TgmPathPanel(ActiveChildForm.PathPanelList.Items[FPathPanelIndex]);
    LPathPanel.PenPathList.AssignPenPathListData(FOldPathList);

    // Select correct path panel and path.
    ActiveChildForm.PathPanelList.SelectPathPanelByIndex(FPathPanelIndex);
    ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.SelectPathByIndex(FOldPathIndex);
    
    ActiveChildForm.FPenPath := ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.SelectedPath;

    if (frmMain.MainTool = gmtPenTools) and
       (frmMain.PenTool = ptPenTool) then
    begin
      if Assigned(ActiveChildForm.FPenPath) then
      begin
        if ActiveChildForm.FPenPath.CurveSegmentsList.IsClosed = False then
        begin
          ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.PathListState := plsAddNextAnchorPoint;
        end;
      end;
    end;
  end;

  ProcessAfterPenPathCommandDone;
end;

procedure TgmModifyPathCommand.Execute;
var
  LPathPanel: TgmPathPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  if Assigned(FNewPathList) then
  begin
    // update the paths
    LPathPanel := TgmPathPanel(ActiveChildForm.PathPanelList.Items[FPathPanelIndex]);
    LPathPanel.PenPathList.AssignPenPathListData(FNewPathList);
    
    // select correct path panel and path
    ActiveChildForm.PathPanelList.SelectPathPanelByIndex(FPathPanelIndex);
    ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.SelectPathByIndex(FNewPathIndex);

    ActiveChildForm.FPenPath := ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.SelectedPath;

    if (frmMain.MainTool = gmtPenTools) and
       (frmMain.PenTool = ptPenTool) then
    begin
      if ActiveChildForm.FPenPath.CurveSegmentsList.IsClosed = False then
      begin
        ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.PathListState := plsAddNextAnchorPoint;
      end;
    end;
  end;

  ProcessAfterPenPathCommandDone;
end;

//-- TgmActiveWorkPathCommand --------------------------------------------------

constructor TgmActiveWorkPathCommand.Create(const APathPanelIndex: Integer;
  const AOldPenPathList: TgmPenPathList; const APenPath: TgmPenPath);
begin
  inherited Create(caNone, 'New Work Path');

  FOperateName    := 'Undo ' + FCommandName;;
  FPathPanelIndex := APathPanelIndex;

  if Assigned(APenPath) then
  begin
    FNewPenPath := TgmPenPath.Create;
    FNewPenPath := APenPath.GetSelfBackup;
  end
  else
  begin
    FNewPenPath := nil;
  end;

  if Assigned(AOldPenPathList) then
  begin
    FOldPenPathList := TgmPenPathList.Create;
    FOldPenPathList.AssignPenPathListData(AOldPenPathList);
  end
  else
  begin
    FOldPenPathList := nil;
  end;
end;

destructor TgmActiveWorkPathCommand.Destroy;
begin
  FOldPenPathList.Free;
  FNewPenPath.Free;
  
  inherited Destroy;
end;

procedure TgmActiveWorkPathCommand.Rollback;
var
  LPathPanel: TgmPathPanel;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  if ActiveChildForm.PathPanelList.Count > 0 then
  begin
    ActiveChildForm.PathPanelList.DeselectAllPathPanels;
    LPathPanel := TgmPathPanel(ActiveChildForm.PathPanelList.Items[ActiveChildForm.PathPanelList.Count - 1]);

    // not named indicate that it was a Work Path
    if LPathPanel.IsNamed = False then  
    begin
      LPathPanel.PenPathList.AssignPenPathListData(FOldPenPathList);

      LPathPanel.UpdateThumbnail(
        ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Width,
        ActiveChildForm.LayerPanelList.SelectedLayerPanel.AssociatedLayer.Bitmap.Height,
        ActiveChildForm.PathOffsetVector);

      LPathPanel.IsSelected := False;
      ActiveChildForm.PathPanelList.UpdateAllPanelsState;

      ActiveChildForm.FPenPath := nil;
    end;
  end;

  ProcessAfterPenPathCommandDone;
end;

procedure TgmActiveWorkPathCommand.Execute;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  ActiveChildForm.PathPanelList.DeselectAllPathPanels;
  ActiveChildForm.PathPanelList.ActivateWorkPath;
  
  if Assigned(ActiveChildForm.PathPanelList.SelectedPanel) then
  begin
    ActiveChildForm.FPenPath := FNewPenPath.GetSelfBackup;
    
    ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.AddNewPathToList(ActiveChildForm.FPenPath);
    ActiveChildForm.PathPanelList.UpdateAllPanelsState;
    
    ActiveChildForm.FPenPath := ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.SelectedPath;
  end;

  ProcessAfterPenPathCommandDone;
end;

//-- TgmClosePathCommand -------------------------------------------------------

constructor TgmClosePathCommand.Create(
  const APathPanelIndex, APathIndex: Integer;
  const AOldPathList: TgmPenPathList);
begin
  inherited Create(caNone, 'Close Path');

  FOperateName    := 'Undo ' + FCommandName;
  FPathPanelIndex := APathPanelIndex;
  FPathIndex      := APathIndex;

  if Assigned(AOldPathList) then
  begin
    FOldPathList := TgmPenPathList.Create;
    FOldPathList.AssignPenPathListData(AOldPathList);
  end
  else
  begin
    FOldPathList := nil;
  end;
end;

destructor TgmClosePathCommand.Destroy;
begin
  FOldPathList.Free;

  inherited Destroy;
end;

procedure TgmClosePathCommand.Rollback;
var
  LPathPanel: TgmPathPanel;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  if Assigned(FOldPathList) then
  begin
    // update the paths
    LPathPanel := TgmPathPanel(ActiveChildForm.PathPanelList.Items[FPathPanelIndex]);
    LPathPanel.PenPathList.AssignPenPathListData(FOldPathList);

    // select correct path panel and path
    ActiveChildForm.PathPanelList.SelectPathPanelByIndex(FPathPanelIndex);
    ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.SelectPathByIndex(FPathIndex);
    
    ActiveChildForm.FPenPath := ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.SelectedPath;

    if (frmMain.MainTool = gmtPenTools) and
       (frmMain.PenTool = ptPenTool) then
    begin
      if ActiveChildForm.FPenPath.CurveSegmentsList.IsClosed = False then
      begin
        ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.PathListState := plsAddNextAnchorPoint;
      end;
    end;
  end;

  ProcessAfterPenPathCommandDone;
end;

procedure TgmClosePathCommand.Execute;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  if ActiveChildForm.PathPanelList.SelectedPanelIndex <> FPathPanelIndex then
  begin
    ActiveChildForm.PathPanelList.SelectPathPanelByIndex(FPathPanelIndex);
  end;

  if Assigned(ActiveChildForm.PathPanelList.SelectedPanel) then
  begin
    if ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.SelectedPathIndex <> FPathIndex then
    begin
      ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.SelectPathByIndex(FPathIndex);
      ActiveChildForm.FPenPath := ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.SelectedPath;
    end;

    if Assigned(ActiveChildForm.FPenPath) then
    begin
      ActiveChildForm.FPenPath.CurveSegmentsList.ClosePath;
      ActiveChildForm.FPenPath := nil;
    end;

    ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.PathListState := plsAddNewPath;
  end;

  ProcessAfterPenPathCommandDone;
end;

//-- TgmTranslatePathsCommand --------------------------------------------------

constructor TgmTranslatePathsCommand.Create(const APathPanelIndex: Integer;
  const AAccumTranslateVector: TPoint);
var
  i       : Integer;
  LPenPath: TgmPenPath;
begin
  inherited Create(caNone, 'Drag Paths');

  FOperateName          := 'Undo ' + FCommandName;
  FPathPanelIndex       := APathPanelIndex;
  FAccumTranslateVector := AAccumTranslateVector;

  if ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.GetWholeSelectedPathsCount > 0 then
  begin
    for i := 0 to (ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.Count - 1) do
    begin
      LPenPath := TgmPenPath(ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.Items[i]);
      
      if LPenPath.CurveSegmentsList.IsSelectedAll then
      begin
        SetLength( FWholeSelectedPathIndexArray, High(FWholeSelectedPathIndexArray) + 2 );
        FWholeSelectedPathIndexArray[High(FWholeSelectedPathIndexArray)] := i;
      end;
    end;
  end
  else
  begin
    FWholeSelectedPathIndexArray := nil;
  end;
end;

destructor TgmTranslatePathsCommand.Destroy;
begin
  SetLength(FWholeSelectedPathIndexArray, 0);
  FWholeSelectedPathIndexArray := nil;

  inherited Destroy;
end;

procedure TgmTranslatePathsCommand.Rollback;
var
  i, LPathIndex       : Integer;
  LUndoTranslateVector: TPoint;
begin
  FCommandState          := csRedo;
  FOperateName           := 'Redo ' + FCommandName;
  LUndoTranslateVector.X := -FAccumTranslateVector.X;
  LUndoTranslateVector.Y := -FAccumTranslateVector.Y;

  if ActiveChildForm.PathPanelList.SelectedPanelIndex <> FPathPanelIndex then
  begin
    ActiveChildForm.PathPanelList.SelectPathPanelByIndex(FPathPanelIndex);
  end;

  if Assigned(ActiveChildForm.PathPanelList.SelectedPanel) then
  begin
    if High(FWholeSelectedPathIndexArray) >= 0 then
    begin
      for i := 0 to High(FWholeSelectedPathIndexArray) do
      begin
        LPathIndex := FWholeSelectedPathIndexArray[i];
        
        ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.SelectWholePathByIndex(LPathIndex);
      end;

      if ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.GetWholeSelectedPathsCount > 0 then
      begin
        ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.TranslateAllSelectedPaths(LUndoTranslateVector);
      end;
    end;
  end;

  ProcessAfterPenPathCommandDone;
end;

procedure TgmTranslatePathsCommand.Execute;
var
  i, LPathIndex: Integer;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  if ActiveChildForm.PathPanelList.SelectedPanelIndex <> FPathPanelIndex then
  begin
    ActiveChildForm.PathPanelList.SelectPathPanelByIndex(FPathPanelIndex);
  end;

  if Assigned(ActiveChildForm.PathPanelList.SelectedPanel) then
  begin
    if High(FWholeSelectedPathIndexArray) >= 0 then
    begin
      for i := 0 to High(FWholeSelectedPathIndexArray) do
      begin
        LPathIndex := FWholeSelectedPathIndexArray[i];
        
        ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.SelectWholePathByIndex(LPathIndex);
      end;

      if ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.GetWholeSelectedPathsCount > 0 then
      begin
        ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.TranslateAllSelectedPaths(FAccumTranslateVector);
      end;
    end;
  end;

  ProcessAfterPenPathCommandDone;
end;

//-- TgmNewPathCommand ---------------------------------------------------------

constructor TgmNewPathCommand.Create(
  const AOldPathPanelIndex, ANewPathPanelIndex: Integer;
  const AOldPathList: TgmPenPathList);
begin
  inherited Create(caNone, 'New Path');

  FOperateName       := 'Undo ' + FCommandName;
  FNewPathPanelIndex := ANewPathPanelIndex;
  FUndoIndex         := AOldPathPanelIndex;

  if Assigned(AOldPathList) then
  begin
    FOldPathList := TgmPenPathList.Create;
    FOldPathList.AssignPenPathListData(AOldPathList);
  end
  else
  begin
    FOldPathList := nil;
  end;
end;

destructor TgmNewPathCommand.Destroy;
begin
  FOldPathList.Free;

  inherited Destroy;
end;

procedure TgmNewPathCommand.Rollback;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  ActiveChildForm.PathPanelList.DeletePathPanelByIndex(FNewPathPanelIndex);
  ActiveChildForm.PathPanelList.PathPanelNumber := ActiveChildForm.PathPanelList.PathPanelNumber - 1;

  if FUndoIndex >= 0 then
  begin
    // select correct path panel and path
    ActiveChildForm.PathPanelList.SelectPathPanelByIndex(FUndoIndex);

    if Assigned(FOldPathList) then
    begin
      // update the paths
      ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.AssignPenPathListData(FOldPathList);
      ActiveChildForm.FPenPath := ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.SelectedPath;
    end;
  end;

  ProcessAfterPenPathCommandDone;
end;

procedure TgmNewPathCommand.Execute;
var
  LPathPanel: TgmPathPanel;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;
  FUndoIndex    := ActiveChildForm.PathPanelList.SelectedPanelIndex;

  if FUndoIndex >= 0 then
  begin
    if FOldPathList = nil then
    begin
      FOldPathList := TgmPenPathList.Create;
    end;

    FOldPathList.AssignPenPathListData(ActiveChildForm.PathPanelList.SelectedPanel.PenPathList);
  end;

  LPathPanel := TgmPathPanel.Create(frmPath.scrlbxPathPanelContainer, pptNamedPath);
  
  if FNewPathPanelIndex >= ActiveChildForm.PathPanelList.Count then
  begin
    ActiveChildForm.PathPanelList.AddPathPanelToList(LPathPanel);
  end
  else
  begin
    ActiveChildForm.PathPanelList.InsertPathPanelToList( LPathPanel, FNewPathPanelIndex);
  end;

  ActiveChildForm.FPenPath := nil;

  ProcessAfterPenPathCommandDone;
end;

//-- TgmDeletePathCommand ------------------------------------------------------

constructor TgmDeletePathCommand.Create(const APathPanelIndex: Integer);
var
  LPathPanel: TgmPathPanel;
begin
  inherited Create(caNone, 'Delete Path');

  FOperateName    := 'Undo ' + FCommandName;
  FPathPanelIndex := APathPanelIndex;
  FRedoIndex      := -1;

  LPathPanel     := TgmPathPanel(ActiveChildForm.PathPanelList.Items[APathPanelIndex]);
  FPathPanelName := LPathPanel.PathName;

  FOldPathList := TgmPenPathList.Create;
  FOldPathList.AssignPenPathListData(LPathPanel.PenPathList);
end;

destructor TgmDeletePathCommand.Destroy;
begin
  FOldPathList.Free;

  inherited Destroy;
end;

procedure TgmDeletePathCommand.Rollback;
var
  LPathPanel: TgmPathPanel;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;
  FRedoIndex    := ActiveChildForm.PathPanelList.SelectedPanelIndex;

  if FPathPanelName <> '' then
  begin
    LPathPanel := TgmPathPanel.Create(frmPath.scrlbxPathPanelContainer, pptNamedPath);
  end
  else
  begin
    LPathPanel := TgmPathPanel.Create(frmPath.scrlbxPathPanelContainer, pptWorkPath);
  end;

  if FPathPanelIndex >= ActiveChildForm.PathPanelList.Count then
  begin
    ActiveChildForm.PathPanelList.AddPathPanelToList(LPathPanel);
  end
  else
  begin
    ActiveChildForm.PathPanelList.InsertPathPanelToList(LPathPanel, FPathPanelIndex);
  end;

  ActiveChildForm.PathPanelList.PathPanelNumber := ActiveChildForm.PathPanelList.PathPanelNumber - 1;

  if ActiveChildForm.PathPanelList.PathPanelNumber < 0 then
  begin
    ActiveChildForm.PathPanelList.PathPanelNumber := 0;
  end;

  if FPathPanelName <> '' then
  begin
    LPathPanel.PathName := FPathPanelName;
    LPathPanel.ShowPathPanelName;
  end;

  if Assigned(FOldPathList) then
  begin
    // update the paths
    ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.AssignPenPathListData(FOldPathList);
    ActiveChildForm.FPenPath := ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.SelectedPath;
  end;

  ProcessAfterPenPathCommandDone;
end;

procedure TgmDeletePathCommand.Execute;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  if FRedoIndex >= 0 then
  begin
    if FRedoIndex > FPathPanelIndex then
    begin
      Dec(FRedoIndex);
    end;
  end;

  ActiveChildForm.PathPanelList.DeletePathPanelByIndex(FPathPanelIndex);
  ActiveChildForm.PathPanelList.UpdateAllPanelsState;

  if (FRedoIndex >= 0) and (FRedoIndex < ActiveChildForm.PathPanelList.Count) then
  begin
    ActiveChildForm.PathPanelList.SelectPathPanelByIndex(FRedoIndex);
    ActiveChildForm.FPenPath := nil;
  end;

  if (ActiveChildForm.PathPanelList.Count = 0) or
     (ActiveChildForm.PathPanelList.SelectedPanelIndex < 0) then
  begin
    ActiveChildForm.FPenPath := nil;
    ActiveChildForm.DeletePathLayer;
  end;

  ProcessAfterPenPathCommandDone;
end;

//-- TgmPathToSelectionCommand -------------------------------------------------

constructor TgmPathToSelectionCommand.Create(const AOldSelection: TgmSelection;
  const APathList: TgmPenPathList);
begin
  inherited Create(caNone, 'Selection Change');

  FOperateName    := 'Undo ' + FCommandName;
  FPathPanelIndex := ActiveChildForm.PathPanelList.SelectedPanelIndex;

  if Assigned(AOldSelection) then
  begin
    FUndoSelection := TgmSelection.Create;
    FUndoSelection.AssignAllSelectionData(AOldSelection);
  end
  else
  begin
    FUndoSelection := nil;
  end;

  if Assigned(APathList) then
  begin
    FRedoPathList := TgmPenPathList.Create;
    FRedoPathList.AssignPenPathListData(APathList);
  end
  else
  begin
    FRedoPathList := nil;
  end;
end;

destructor TgmPathToSelectionCommand.Destroy;
begin
  FUndoSelection.Free;
  FRedoPathList.Free;
  
  inherited Destroy;
end;

procedure TgmPathToSelectionCommand.Rollback;
begin
  FCommandState := csRedo;
  FOperateName  := 'Redo ' + FCommandName;

  with ActiveChildForm do
  begin
    if Assigned(Selection) then
    begin
      tmrMarchingAnts.Enabled := False;

      FreeSelection;  // don't call DeleteSelection() at here
      DeleteSelectionHandleLayer;
    end;

    if Assigned(FUndoSelection) then
    begin
      CreateNewSelection;
      Selection.AssignAllSelectionData(FUndoSelection);
      ChangeSelectionTarget;
      
      tmrMarchingAnts.Enabled := True;

      if frmMain.MainTool = gmtMarquee then
      begin
        if frmMain.MarqueeTool = mtMoveResize then
        begin
          CreateSelectionHandleLayer;
          UpdateSelectionHandleBorder;
        end;
      end;
    end
    else
    begin
      LayerPanelList.SelectedLayerPanel.AssociatedLayer.Changed;
    end;
  end;

  frmMain.UpdateMarqueeOptions;
end;

procedure TgmPathToSelectionCommand.Execute;
var
  LCurrentPathList      : TgmPenPathList;
  LCurrentPathPanelIndex: Integer;
begin
  FCommandState := csUndo;
  FOperateName  := 'Undo ' + FCommandName;

  // Path to Selection.
  LCurrentPathPanelIndex := ActiveChildForm.PathPanelList.SelectedPanelIndex;

  if (LCurrentPathPanelIndex >= 0) and
     (LCurrentPathPanelIndex <> FPathPanelIndex) then
  begin
    LCurrentPathList := TgmPenPathList.Create;
    LCurrentPathList.AssignPenPathListData(ActiveChildForm.PathPanelList.SelectedPanel.PenPathList);
  end
  else
  begin
    LCurrentPathList := nil;
  end;

  if LCurrentPathPanelIndex <> FPathPanelIndex then
  begin
    ActiveChildForm.PathPanelList.SelectPathPanelByIndex(FPathPanelIndex);

    if Assigned(FRedoPathList) then
    begin
      ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.AssignPenPathListData(FRedoPathList);
    end;

    ActiveChildForm.FPenPath := ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.SelectedPath;
  end;

  ActiveChildForm.LoadPathAsSelection;

  if LCurrentPathPanelIndex < 0 then
  begin
    ActiveChildForm.PathPanelList.DeselectAllPathPanels;
    ActiveChildForm.FPenPath := nil;
  end
  else
  if Assigned(LCurrentPathList) then
  begin
    ActiveChildForm.PathPanelList.SelectPathPanelByIndex(LCurrentPathPanelIndex);
    ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.AssignPenPathListData(LCurrentPathList);

    ActiveChildForm.FPenPath := ActiveChildForm.PathPanelList.SelectedPanel.PenPathList.SelectedPath;
    
    FreeAndNil(LCurrentPathList);
  end;

  frmMain.UpdateMarqueeOptions;
end; 

end.
