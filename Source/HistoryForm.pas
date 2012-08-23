{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang, Ma Xiaoming and GraphicsMagic Team.
  All rights reserved. }

unit HistoryForm;

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
  Dialogs, ComCtrls, ToolWin, GR32,
{ GraphicsMagic Lib }
  gmHistoryManager;

type
  TfrmHistory = class(TForm)
    tlbrHistoryTools: TToolBar;
    ToolButton1: TToolButton;
    tlbtnDeleteCurrentState: TToolButton;
    scrlbxHistory: TScrollBox;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormEndDock(Sender, Target: TObject; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tlbtnDeleteCurrentStateClick(Sender: TObject);
  private
    FShowingUp: Boolean;  // indicating whether the form is currently showing up
    
    procedure SetShowingUp(const AValue: Boolean);
  public
    function CreateSnapshot(const ABitmap: TBitmap32;
      const AName: string): TgmSnapshotPanel;
      
    property IsShowingUp: Boolean read FShowingUp write SetShowingUp;
  end;

var
  frmHistory: TfrmHistory;

implementation

uses
{ GraphicsMagic Data Modules }
  HistoryDataModule,
{ GraphicsMagic Forms/Dialogs }
  MainForm,
  RichTextEditorForm;

{$R *.dfm}

const
  MIN_FORM_WIDTH  = 236;
  MIN_FORM_HEIGHT = 150;

function TfrmHistory.CreateSnapshot(const ABitmap: TBitmap32;
  const AName: string): TgmSnapshotPanel;
begin
  // create Snapshot for history command
  Result := TgmSnapshotPanel.Create(Self.scrlbxHistory, ABitmap, AName);
end;

procedure TfrmHistory.SetShowingUp(const AValue: Boolean);
begin
  FShowingUp := AValue;

  if Assigned(ActiveChildForm) then
  begin
    ActiveChildForm.HistoryManager.IsAllowRefreshPanels := FShowingUp;
  end;
end;

procedure TfrmHistory.FormCreate(Sender: TObject);
begin
  ManualDock(frmMain.pgcntrlDockSite1);
  Show;
  FShowingUp := False;
end;

procedure TfrmHistory.FormShow(Sender: TObject);
begin
  SetShowingUp(True);
end;

procedure TfrmHistory.FormResize(Sender: TObject);
begin
  if  Floating then
  begin
    if Width < MIN_FORM_WIDTH then
    begin
      Width := MIN_FORM_WIDTH;
      Abort;
    end;

    if Height < MIN_FORM_HEIGHT then
    begin
      Height := MIN_FORM_HEIGHT;
      Abort;
    end;
  end;
end;

procedure TfrmHistory.FormEndDock(Sender, Target: TObject; X, Y: Integer);
begin
  SetShowingUp(True);
end;

procedure TfrmHistory.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SetShowingUp(False);
end;

procedure TfrmHistory.tlbtnDeleteCurrentStateClick(Sender: TObject);
begin
  if ActiveChildForm <> nil then
  begin
    if (frmRichTextEditor.Visible) or
       (ActiveChildForm.Crop <> nil) then
    begin
      Exit;
    end;

    if ActiveChildForm.HistoryManager.CurrentStateIndex >= 0 then
    begin
      ActiveChildForm.HistoryManager.RollbackCommand;

      ActiveChildForm.HistoryManager.DeleteHistoryStates(
        ActiveChildForm.HistoryManager.CurrentStateIndex + 1,
        ActiveChildForm.HistoryManager.CommandCount - 1);

      ActiveChildForm.HistoryManager.UpdateAllPanelsState;
    end;
  end;   
end;

end.
