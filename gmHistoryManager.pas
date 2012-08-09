{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

unit gmHistoryManager;

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
  Controls, StdCtrls, ExtCtrls, Graphics, Classes,
{ Graphics32 }
  GR32, GR32_Image,
{ GraphicsMagic }
  gmTypes,
  gmLayerAndChannel,
  gmCommands,
  gmLayerPanelCommands,
  gmSelection,
  gmShapes,
  gmFigures,
  gmPenTools,
  gmSelectionCommands,
  gmCrop,
  gmPenPathCommands,
  gmChannelCommands,
  gmResamplers;

type

//-- TgmSnapshotPanel ----------------------------------------------------------

  TgmSnapshotPanel = class(TObject)
  private
    FPanel            : TPanel;   // Main panel of snapshot.
    FImageHolder      : TPanel;   // Used for holding thumbnail image.
    FSnapshotImage    : TImage32; // Used for displaying snapshot.
    FSnapshotNameLabel: TLabel;
    FSelected         : Boolean;  // Indicating whether the panel is selected.
  public
    constructor Create(AOwner: TWinControl; const ASnapshot: TBitmap32;
      const ASnapshotName: string = '');

    destructor Destroy; override;

    procedure ChangeSnapshot(const ASnapshot: TBitmap32);
    procedure UpdatePanelState;

    property IsSelected       : Boolean  read FSelected write FSelected;
    property MainPanel        : TPanel   read FPanel;
    property ImageHolder      : TPanel   read FImageHolder;
    property SnapshotImage    : TImage32 read FSnapshotImage;
    property SnapshotNameLabel: TLabel   read FSnapshotNameLabel;
  end;

//-- TgmHistoryStatePanel ------------------------------------------------------

  TgmHistoryStatePanel = class(TObject)
  protected
    FPanel           : TPanel;     // main panel of history state
    FCommandImage    : TImage32;   // used for displaying icon of command
    FCommandNameLabel: TLabel;     // used for displaying command name
    FMaskIcon        : TBitmap32;
    FSelected        : Boolean;    // indicating whether if this panel is selected
    FEnabled         : Boolean;    // indicating whether if this panel is enabled
    FCommand         : TGMCommand;

    // image paint stage event
    procedure CommandImagePaintStage(Sender: TObject; Buffer: TBitmap32; StageNum: Cardinal);
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ACommandName: string);

    destructor Destroy; override;

    procedure UpdatePanelState;

    property IsSelected      : Boolean    read FSelected write FSelected;
    property IsEnabled       : Boolean    read FEnabled  write FEnabled;
    property MainPanel       : TPanel     read FPanel;
    property CommandImage    : TImage32   read FCommandImage;
    property CommandNameLabel: TLabel     read FCommandNameLabel;
    property Command         : TGMCommand read FCommand;
  end;

//-- TgmImageManipulatingStatePanel --------------------------------------------

  TgmImageManipulatingStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ACmdAim: TCommandAim; const ACmdName: string;
      const AUndoBmp, ARedoBmp: TBitmap32; const ASelection: TgmSelection;
      const ATargetAlphaChannelIndex: Integer = -1);
  end;

//-- TgmBlendingChangeStatePanel -----------------------------------------------

  TgmBlendingChangeStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ALayerIndex, AOldBlendModeIndex, ANewBlendModeIndex: Integer);
  end;

//-- TgmOpacityChangeStatePanel ------------------------------------------------

  TgmOpacityChangeStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ALayerIndex: Integer; const AOldOpacity, ANewOpacity: Byte);
  end;

//-- TgmSolidColorLayerStatePanel ----------------------------------------------

  TgmSolidColorLayerStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ALayerIndex: Integer; const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType;
      const AModifiedColor: TColor = clBlack);
  end;

//-- TgmGradientFillLayerStatePanel --------------------------------------------

  TgmGradientFillLayerStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ALayerIndex: Integer; const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType);
  end;

//-- TgmPatternLayerStatePanel -------------------------------------------------

  TgmPatternLayerStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ALayerIndex: Integer; const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType);
  end;

//-- TgmLevelsLayerStatePanel --------------------------------------------------

  TgmLevelsLayerStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ALayerIndex: Integer; const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType);
  end;

//-- TgmCurvesLayerStatePanel --------------------------------------------------

  TgmCurvesLayerStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ALayerIndex: Integer; const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType);
  end;

//-- TgmColorBalanceLayerStatePanel --------------------------------------------

  TgmColorBalanceLayerStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ALayerIndex: Integer; const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType);
  end;

//-- TgmBrightContrastLayerStatePanel ------------------------------------------

  TgmBrightContrastLayerStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ALayerIndex: Integer; const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType);
  end;

//-- TgmHLSLayerStatePanel -----------------------------------------------------

  TgmHLSLayerStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ALayerIndex: Integer; const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType);
  end;

//-- TgmChannelMixerLayerStatePanel --------------------------------------------

  TgmChannelMixerLayerStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ALayerIndex: Integer; const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType);
  end;

//-- TgmGradientMapLayerStatePanel ---------------------------------------------

  TgmGradientMapLayerStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ALayerIndex: Integer; const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType);
  end;

//-- TgmInvertLayerStatePanel --------------------------------------------------

  TgmInvertLayerStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ALayerIndex: Integer; const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType);
  end;

//-- TgmThresholdLayerStatePanel -----------------------------------------------

  TgmThresholdLayerStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ALayerIndex: Integer; const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType);
  end;

//-- TgmPosterizeLayerStatePanel -----------------------------------------------

  TgmPosterizeLayerStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ALayerIndex: Integer; const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType);
  end;

//-- TgmStandardLayerStatePanel ------------------------------------------------

  // For background and transparent layer.
  TgmStandardLayerStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ALayerIndex: Integer; const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType);
  end;

//-- TgmDuplicateLayerStatePanel -----------------------------------------------

  TgmDuplicateLayerStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ACurrentIndex, ADuplicatedIndex: Integer; const ALayerName: string);
  end;

//-- TgmLayerPropertiesStatePanel ----------------------------------------------

  TgmLayerPropertiesStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ALayerOldName, ALayerNewName: string);
  end;

//-- TgmArrangeLayerStatePanel -------------------------------------------------

  TgmArrangeLayerStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const AOldIndex, ANewIndex: Integer; const AStyle: TgmLayerArrangementStyle);
  end;

//-- TgmLayerMaskStatePanel ----------------------------------------------------

  TgmLayerMaskStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const AMaskCommandType: TgmMaskCommandType;
      const AOldSelection: TgmSelection);
  end;

//-- TgmLinkMaskStatePanel -----------------------------------------------------

  TgmLinkMaskStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ALayerPanelIndex: Integer);
  end;
  
//-- TgmUnlinkMaskStatePanel ---------------------------------------------------

  TgmUnlinkMaskStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ALayerPanelIndex: Integer);
  end;
  
//-- TgmShapeRegionLayerStatePanel ---------------------------------------------

  TgmShapeRegionLayerStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ALayerIndex: Integer; const ALayerPanel: TgmLayerPanel;
      const ARegionCommandType: TgmRegionCommandType;
      const AOutline: TgmShapeOutline = nil);
  end;

//-- TgmModifyShapeRegionColorStatePanel ---------------------------------------

  TgmModifyShapeRegionColorStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const AOldColor, ANewColor: TColor);
  end;
  
//-- TgmModifyShapeRegionStyleStatePanel ---------------------------------------

  TgmModifyShapeRegionStyleStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const AOldStyle, ANewStyle: TBrushStyle);
  end;

//-- TgmTranslateShapeRegionStatePanel -----------------------------------------

  TgmTranslateShapeRegionStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const AccumTranslatedVector: TPoint);
  end;

//-- TgmScaleShapeRegionStatePanel ---------------------------------------------

  TgmScaleShapeRegionStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const AOldTopLeft, AOldBottomRight, ANewTopLeft, ANewBottomRight: TPoint);
  end;

//-- TgmFigureLayerStatePanel --------------------------------------------------

  TgmFigureLayerStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ALayerIndex: Integer; const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType;
      const AFigureFlag: TgmFigureFlags = ffNone);
  end;

//-- TgmAddFigureStatePanel ----------------------------------------------------

  TgmAddFigureStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const AFigureObj: TgmFigureObject);
  end;

//-- TgmSelectFigureStatePanel -------------------------------------------------

  TgmSelectFigureStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const AOldSelectedFigureInfoArray: array of TgmFigureInfo;
      const ANewSelectedFigureInfoArray: array of TgmFigureInfo;
      const AOldSelectedFigureLayerIndexArray: array of Integer;
      const ANewSelectedFigureLayerIndexArray: array of Integer;
      const AMode: TgmSelectFigureMode);
  end;

//-- TgmDeleteFigureStatePanel -------------------------------------------------

  TgmDeleteFigureStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const AOldSelectedFigureInfoArray: array of TgmFigureInfo;
      const AOldSelectedFigureLayerIndexArray: array of Integer);
  end;

//-- TgmLockFigureStatePanel ---------------------------------------------------

  TgmLockFigureStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ALockMode: TgmLockFigureMode);
  end;

//-- TgmModifyFigureStyleStatePanel --------------------------------------------

  TgmModifyFigureStyleStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const AOldData, ANewData: TgmFigureBasicData);
  end;

//-- TgmStretchFigureStatePanel ------------------------------------------------

  TgmStretchFigureStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const AOldFigure, ANewFigure: TgmFigureObject);
  end;

//-- TgmTranslateFigureStatePanel ----------------------------------------------

  TgmTranslateFigureStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const AAccumTranslateVector: TPoint);
  end;

//-- TgmTypeToolLayerStatePanel ------------------------------------------------

  TgmTypeToolLayerStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ALayerIndex: Integer; const ALayerPanel: TgmLayerPanel;
      const ALayerCommandType: TgmLayerCommandType);
  end;

//-- TgmEditTypeStatePanel -----------------------------------------------------

  TgmEditTypeStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ALayerIndex: Integer; const AOldTextStream: TMemoryStream;
      const ALayerPanel: TgmLayerPanel);
  end;

//-- TgmTranslateTextRegionStatePanel ------------------------------------------

  TgmTranslateTextRegionStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ALayerIndex: Integer; const AAccumTranslateVector: TPoint);
  end;

//-- TgmScaleTextRegionStatePanel ----------------------------------------------

  TgmScaleTextRegionStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl;
      const ACommandMaskIcon: TBitmap32;
      const ALayerIndex: Integer;
      const AOldTopLeft, AOldBottomRight, ANewTopLeft, ANewBottomRight: TPoint);
  end;

//-- TgmSelectionStatePanel ----------------------------------------------------

  TgmSelectionStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl;
      const ACommandMaskIcon: TBitmap32;
      const ACmdAim: TCommandAim;
      const AMarqueeTool: TgmMarqueeTools;
      const ASelectionCommandType: TgmSelectionCommandType;
      const AOldSelection, ANewSelection: TgmSelection;
      const ATargetAlphaChannelIndex: Integer = -1);
  end;

//-- TgmTransformStatePanel ----------------------------------------------------

  TgmTransformStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl;
      const ACommandMaskIcon: TBitmap32;
      const ATransformCommandType: TgmTransformCommandType;
      const ATransformMode: TgmTransformMode;
      const AUndoSelection: TgmSelection;
      const AUndoTransform, ARedoTransform: TgmSelectionTransformation);
  end;

//-- TgmCutPixelsStatePanel ----------------------------------------------------

  TgmCutPixelsStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl;
      const ACommandMaskIcon: TBitmap32;
      const ACmdAim: TCommandAim;
      const AOldSelection, AOldClipboardSelection: TgmSelection;
      const ATargetAlphaChannelIndex: Integer = -1);
  end;

//-- TgmCopyPixelsStatePanel ---------------------------------------------------

  TgmCopyPixelsStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const AOldSelection, AOldClipboardSelection: TgmSelection);
  end;

//-- TgmPastePixelsStatePanel --------------------------------------------------

  TgmPastePixelsStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl;
      const ACommandMaskIcon: TBitmap32;
      const ACmdAim: TCommandAim;
      const APastedLayerName: string;
      const APastedLayerIndex: Integer;
      const ABeforePasteLayerIndex: Integer;
      const ATargetAlphaChannelIndex: Integer;
      const AOldSelection: TgmSelection;
      const AOldBackground: TBitmap32);
  end;

//-- TgmFlipSelectionStatePanel ------------------------------------------------

  TgmFlipSelectionStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl;
      const ACommandMaskIcon: TBitmap32;
      const ACmdAim: TCommandAim;
      const AOldSelection, ANewSelection: TgmSelection;
      const AFlipMode: TgmFlipMode;
      const ATargetAlphaChannelIndex: Integer);
  end;

//-- TgmNewWorkPathStatePanel --------------------------------------------------

  TgmNewWorkPathStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const APathPanelIndex: Integer; const APenPath: TgmPenPath);
  end;

//-- TgmModifyPathStatePanel ---------------------------------------------------

  TgmModifyPathStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl;
      const ACommandMaskIcon: TBitmap32;
      const APathPanelIndex, AOldPathIndex, ANewPathIndex: Integer;
      const AOldPathList, ANewPathList: TgmPenPathList;
      const AModifyMode: TgmModifyPathMode);
  end;

//-- TgmActiveWorkPathStatePanel -----------------------------------------------

  TgmActiveWorkPathStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const APathPanelIndex: Integer; const AOldPenPathList: TgmPenPathList;
      const APenPath: TgmPenPath);
  end;

//-- TgmClosePathStatePanel ----------------------------------------------------

  TgmClosePathStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl;
      const ACommandMaskIcon: TBitmap32;
      const APathPanelIndex, APathIndex: Integer;
      const AOldPathList: TgmPenPathList);
  end;

//-- TgmTranslatePathsStatePanel -----------------------------------------------

  TgmTranslatePathsStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const APathPanelIndex: Integer; const AAccumTranslateVector: TPoint);
  end;

//-- TgmNewPathStatePanel ------------------------------------------------------

  TgmNewPathStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const AOldPathPanelIndex, ANewPathPanelIndex: Integer;
      const AOldPathList: TgmPenPathList);
  end;

//-- TgmDeletePathStatePanel ---------------------------------------------------

  TgmDeletePathStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const APathPanelIndex: Integer);
  end;

//-- TgmPathToSelectionStatePanel ----------------------------------------------

  TgmPathToSelectionStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const AOldSelection: TgmSelection; const APathList: TgmPenPathList);
  end;

//-- TgmAlphaChannelOptionsStatePanel ------------------------------------------

  TgmAlphaChannelOptionsStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl;
      const ACommandMaskIcon: TBitmap32;
      const AChannelIndex: Integer;
      const AOptionsHistoryData: TgmChannelOptionsHistoryData);
  end;

//-- TgmQuickMaskChannelOptionsStatePanel --------------------------------------

  TgmQuickMaskOptionsStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl;
      const ACommandMaskIcon: TBitmap32;
      const AQuickMaskPanel: TgmQuickMaskPanel;
      const AOptionsHistoryData: TgmChannelOptionsHistoryData);
  end;

//-- TgmLoadChannelAsSelectionStatePanel ---------------------------------------

  TgmLoadChannelAsSelectionStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const AOldSelection, ANewSelection: TgmSelection);
  end;

//-- TgmSaveSelectionAsChannelStatePanel ---------------------------------------

  TgmSaveSelectionAsChannelStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ASelectionChannelIndex: Integer);
  end;

//-- TgmNewChannelStatePanel ----------------------------------------------------

  TgmNewChannelStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const AChannelIndex: Integer);
  end;

//-- TgmDeleteChannelStatePanel ------------------------------------------------

  TgmDeleteChannelStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const AOldChannelPanel: TgmAlphaChannelPanel; const AChannelIndex: Integer);
  end;

//-- TgmDuplicateChannelStatePanel ---------------------------------------------

  TgmDuplicateChannelStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ADuplicatedChannelPanel: TgmAlphaChannelPanel);
  end;

//-- TgmEnterQuickMaskStatePanel -----------------------------------------------

  TgmEnterQuickMaskStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const AOldSelection: TgmSelection);
  end;

//-- TgmExitQuickMaskStatePanel ------------------------------------------------

  TgmExitQuickMaskStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const AQuickMaskPanel: TgmQuickMaskPanel; const AOldSelection: TgmSelection);
  end;

//-- TgmFlattenImageStatePanel -------------------------------------------------

  TgmFlattenImageStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32);
  end;

//-- TgmMergeLayerDownStatePanel -----------------------------------------------

  TgmMergeLayerDownStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32);
  end;

//-- TgmMergeVisibleLayersStatePanel -------------------------------------------

  TgmMergeVisibleLayersStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32);
  end;

//-- TgmChangeImageSizeStatePanel ----------------------------------------------

  TgmChangeImageSizeStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl;
      const ACommandMaskIcon: TBitmap32;
      const ANewWidth, ANewHeight: Integer;
      const AResamplingOptions: TgmResamplingOptions);
  end;

//-- TgmChangeCanvasSizeStatePanel ---------------------------------------------

  TgmChangeCanvasSizeStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl;
      const ACommandMaskIcon: TBitmap32;
      const ANewWidth, ANewHeight: Integer;
      const AAnchorDirection: TgmAnchorDirection;
      const ABackgroundColor: TColor32);
  end;

//-- TgmRotateCanvasStatePanel -------------------------------------------------

  TgmRotateCanvasStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ADeg: Integer; const ARotateDirection: TgmRotateDirection);
  end;

//-- TgmCropStatePanel ---------------------------------------------------------

  TgmCropStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
      const ACrop: TgmCrop);
  end;

//-- TgmOptimalCropStatePanel --------------------------------------------------

  TgmOptimalCropStatePanel = class(TgmHistoryStatePanel)
  public
    constructor Create(AOwner: TWinControl; const ACommandMaskIcon: TBitmap32);
  end;

//-- TgmHistoryManager ---------------------------------------------------------

  TgmHistoryManager = class(TObject)
  private
    FSnapshotPanelList    : TList;
    FHistoryStatePanelList: TList;
    FCurrentStateIndex    : Integer;
    FMaxStateCount        : Integer;  // indicating how many states will be preserved in the list
    FOperateName          : string;
    FCommandState         : TCommandState;
    FAllowRefreshPanels   : Boolean; // indicating if we could refresh the panels

    function GetCommandCount: Integer;

    procedure UpdateSnapshotPanelsState;
    procedure UpdateHistoryStatePanelsState;
    procedure SnapshotPanelClick(Sender: TObject);
    procedure HistoryStatePanelClick(ASender: TObject);
    procedure CallRollbacks(const AEndIndex, AStartIndex: Integer);
    procedure CallExecutes(const AStartIndex, AEndIndex: Integer);
    procedure ConnectEventsToSnapshotPanel(const ASnapshotPanel: TgmSnapshotPanel);
    procedure ConnectEventsToHistoryStatePanel(const AHistoryStatePanel: TgmHistoryStatePanel);
    procedure DeleteAllSnapshots;
  public
    constructor Create(const AMaxStateCount: Integer);
    destructor Destroy; override;

    function AddSnapshot(const ASnapshotPanel: TgmSnapshotPanel): Integer;
    function AddHistoryState(const AHistoryStatePanel: TgmHistoryStatePanel): Integer;
    function SelectSnapshotByIndex(const AIndex: Integer): Boolean;
    function SelectHistoryStateByIndex(const AIndex: Integer): Boolean;

    procedure UpdateAllPanelsState;
    procedure DeselectAllSnapshots;
    procedure DeselectAllHistoryStates;
    procedure DeleteHistoryStates(const AStartIndex, AEndIndex: Integer);
    procedure DeleteAllHistoryStates;
    procedure HideAllPanels;
    procedure ShowAllPanelsByRightOrder;
    procedure RollbackCommand;
    procedure ExecuteCommand;

    property CommandCount        : Integer       read GetCommandCount;
    property CurrentStateIndex   : Integer       read FCurrentStateIndex;
    property MaxStateCount       : Integer       read FMaxStateCount      write FMaxStateCount;
    property OperateName         : string        read FOperateName;
    property CommandState        : TCommandState read FCommandState;
    property IsAllowRefreshPanels: Boolean       read FAllowRefreshPanels write FAllowRefreshPanels;
  end;

implementation

{$WARN UNSAFE_CAST OFF}

uses
{ Standard Lib }
  Forms, 
{ GraphicsMagic Lib }
  gmAlphaFuncs,
  gmImageProcessFuncs,
  gmGUIFuncs,
{ GraphicsMagic Forms/Dialogs }
  MainForm,
  HistoryForm,
  RichTextEditorForm;

const
  SNAPSHOT_MAIN_PANEL_HEIGHT      = 41;
  SNAPSHOT_IMAGE_HOLDER_WIDTH     = 39;
  SNAPSHOT_THUMBNAIL_DEFAULT_SIZE = 31;

  HISTORY_STATE_MAIN_PANEL_HEIGHT  = 24;
  HISTORY_STATE_COMMAND_IMAGE_SIZE = 18;

//-- TgmSnapshotPanel ----------------------------------------------------------

constructor TgmSnapshotPanel.Create(AOwner: TWinControl;
  const ASnapshot: TBitmap32; const ASnapshotName: string = '');
begin
  inherited Create;

  FSelected := False;

  // Create a main snapshot panel
  FPanel := TPanel.Create(AOwner);
  with FPanel do
  begin
    Parent     := AOwner;
    Align      := alTop;
    AutoSize   := False;
    Height     := SNAPSHOT_MAIN_PANEL_HEIGHT;
    BevelInner := bvLowered;
    BevelOuter := bvRaised;
    BevelWidth := 1;
    Color      := clBackground;
    ShowHint   := False;
    Cursor     := crHandPoint;
    Visible    := True;
  end;

  // Create a panel for holding FSnapshotImage.
  FImageHolder := TPanel.Create(FPanel);
  with FImageHolder do
  begin
    Parent     := FPanel;
    Align      := alLeft;
    AutoSize   := False;
    Width      := SNAPSHOT_IMAGE_HOLDER_WIDTH;
    BevelInner := bvRaised;
    BevelOuter := bvLowered;
    BevelWidth := 1;
    Cursor     := crHandPoint;
    Visible    := True;
  end;

  // Create an Image32 for displaying snapshot.
  FSnapshotImage := TImage32.Create(FImageHolder);
  with FSnapshotImage do
  begin
    Parent    := FImageHolder;
    Width     := SNAPSHOT_THUMBNAIL_DEFAULT_SIZE;
    Height    := SNAPSHOT_THUMBNAIL_DEFAULT_SIZE;
    AutoSize  := False;
    ScaleMode := smStretch;
    Cursor    := crHandPoint;
    Visible   := True;
  end;
  ChangeSnapshot(ASnapshot);

  // Create a Label for displaying snapshot name.
  FSnapshotNameLabel := TLabel.Create(FPanel);
  with FSnapshotNameLabel do
  begin
    Parent     := FPanel;
    Align      := alNone;
    Left       := FImageHolder.Width + 10;
    Top        := (FPanel.Height - Height) div 2;
    Caption    := ASnapshotName;
    Font.Color := clWhite;
    Cursor     := crHandPoint;
    Visible    := True;
  end;
end;

destructor TgmSnapshotPanel.Destroy;
begin
  FSnapshotImage.Free;
  FImageHolder.Free;
  FPanel.Free;
  
  inherited Destroy;
end;

procedure TgmSnapshotPanel.ChangeSnapshot(const ASnapshot: TBitmap32);
begin
  FSnapShotImage.Bitmap.Assign(ASnapshot);

  ScaleImage32(ASnapshot, FSnapshotImage,
               SNAPSHOT_THUMBNAIL_DEFAULT_SIZE,
               SNAPSHOT_THUMBNAIL_DEFAULT_SIZE);
               
  CenterImageInPanel(FImageHolder, FSnapshotImage);
end; 

procedure TgmSnapshotPanel.UpdatePanelState;
begin
  if FSelected then
  begin
    FPanel.BevelInner             := bvLowered;
    FPanel.Color                  := clBackground;
    FSnapshotNameLabel.Font.Color := clWhite;
  end
  else
  begin
    FPanel.BevelInner             := bvRaised;
    FPanel.Color                  := clBtnFace;
    FSnapshotNameLabel.Font.Color := clBlack;
  end;
end; 

//-- TgmHistoryStatePanel ------------------------------------------------------

constructor TgmHistoryStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ACommandName: string);
begin
  inherited Create;

  FSelected := False;
  FEnabled  := False;
  FCommand  := nil;

  FMaskIcon := TBitmap32.Create;
  FMaskIcon.Assign(ACommandMaskIcon);

  // Create a main history state panel
  FPanel := TPanel.Create(AOwner);
  with FPanel do
  begin
    Parent     := AOwner;
    Align      := alTop;
    AutoSize   := False;
    Height     := HISTORY_STATE_MAIN_PANEL_HEIGHT;
    BevelInner := bvLowered;
    BevelOuter := bvRaised;
    BevelWidth := 1;
    ShowHint   := False;
    Cursor     := crHandPoint;
    Visible    := True;
  end;

  // Create an Image32 for displaying command icon.
  FCommandImage := TImage32.Create(FPanel);
  with FCommandImage do
  begin
    Parent                := FPanel;
    PaintStages[0]^.Stage := PST_CUSTOM;
    OnPaintStage          := CommandImagePaintStage;
    Top                   := 2;
    Left                  := 10;
    AutoSize              := True;
    ScaleMode             := smStretch;
    Cursor                := crHandPoint;
    Visible               := True;
    Bitmap.DrawMode       := dmBlend;
    Bitmap.SetSize(HISTORY_STATE_COMMAND_IMAGE_SIZE, HISTORY_STATE_COMMAND_IMAGE_SIZE);
    Bitmap.Clear(clWhite);
    ReplaceAlphaChannelWithMask(Bitmap, FMaskIcon);
  end;

  // Create a Label for displaying command name.
  FCommandNameLabel := TLabel.Create(FPanel);
  with FCommandNameLabel do
  begin
    Parent  := FPanel;
    Align   := alNone;
    Left    := FCommandImage.Width + 20;
    Top     := (FPanel.Height - Height) div 2;
    Caption := ACommandName;
    Cursor  := crHandPoint;
    Visible := True;
  end;
end;

destructor TgmHistoryStatePanel.Destroy;
begin
  FCommand.Free;
  FMaskIcon.Free;
  FCommandNameLabel.Free;
  FPanel.Free;
  
  inherited Destroy;
end;

// image paint stage event
procedure TgmHistoryStatePanel.CommandImagePaintStage(
  Sender: TObject; Buffer: TBitmap32; StageNum: Cardinal);
var
  PaintColor: TColor32;
begin
  if FSelected then
  begin
    PaintColor := Color32( ColorToRGB(clBackground) );
  end
  else
  begin
    PaintColor := Color32( ColorToRGB(clBtnFace) );
  end;

  Buffer.Clear(PaintColor);
end; 

procedure TgmHistoryStatePanel.UpdatePanelState;
begin
  if FSelected then
  begin
    FPanel.BevelInner            := bvLowered;
    FPanel.Color                 := clBackground;
    FCommandNameLabel.Font.Color := clWhite;
    FCommandImage.Bitmap.Clear(clWhite32);
  end
  else
  begin
    FPanel.Color := clBtnFace;
    if FEnabled then
    begin
      FPanel.BevelInner            := bvLowered;
      FCommandNameLabel.Font.Color := clBlack;
      FCommandImage.Bitmap.Clear(clBlack32);
    end
    else
    begin
      FPanel.BevelInner            := bvRaised;
      FCommandNameLabel.Font.Color := clGray;
      FCommandImage.Bitmap.Clear(clGray32);
    end;
  end;

  ReplaceAlphaChannelWithMask(FCommandImage.Bitmap, FMaskIcon);
  FCommandImage.Bitmap.Changed;
end; 

//-- TgmImageManipulatingStatePanel --------------------------------------------

constructor TgmImageManipulatingStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ACmdAim: TCommandAim;
  const ACmdName: string; const AUndoBmp, ARedoBmp: TBitmap32;
  const ASelection: TgmSelection; const ATargetAlphaChannelIndex: Integer = -1);
begin
  inherited Create(AOwner, ACommandMaskIcon, ACmdName);

  FCommand := TgmImageManipulatingCommand.Create(ACmdAim, ACmdName,
    AUndoBmp, ARedoBmp, ASelection, ATargetAlphaChannelIndex);
end;

//-- TgmBlendingChangeStatePanel -----------------------------------------------

constructor TgmBlendingChangeStatePanel.Create(
  AOwner: TWinControl; const ACommandMaskIcon: TBitmap32;
  const ALayerIndex, AOldBlendModeIndex, ANewBlendModeIndex: Integer);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmBlendingChangeLayerCommand.Create(ALayerIndex,
                                                   AOldBlendModeIndex,
                                                   ANewBlendModeIndex);

  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmOpacityChangeStatePanel ------------------------------------------------

constructor TgmOpacityChangeStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ALayerIndex: Integer;
  const AOldOpacity, ANewOpacity: Byte);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmOpacityChangeLayerCommand.Create(ALayerIndex, AOldOpacity, ANewOpacity);
  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmSolidColorLayerStatePanel ----------------------------------------------

constructor TgmSolidColorLayerStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType;
  const AModifiedColor: TColor = clBlack);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmSolidColorLayerCommand.Create(ALayerIndex, ALayerPanel,
                                               ALayerCommandType, AModifiedColor);

  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmGradientFillLayerStatePanel --------------------------------------------

constructor TgmGradientFillLayerStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmGradientFillLayerCommand.Create(ALayerIndex, ALayerPanel, ALayerCommandType);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmPatternLayerStatePanel -------------------------------------------------

constructor TgmPatternLayerStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmPatternLayerCommand.Create(ALayerIndex, ALayerPanel, ALayerCommandType);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmLevelsLayerStatePanel --------------------------------------------------

constructor TgmLevelsLayerStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmLevelsLayerCommand.Create(ALayerIndex, ALayerPanel, ALayerCommandType);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmCurvesLayerStatePanel --------------------------------------------------

constructor TgmCurvesLayerStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmCurvesLayerCommand.Create(ALayerIndex, ALayerPanel, ALayerCommandType);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmColorBalanceLayerStatePanel --------------------------------------------

constructor TgmColorBalanceLayerStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmColorBalanceLayerCommand.Create(ALayerIndex, ALayerPanel, ALayerCommandType);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmBrightContrastLayerStatePanel ------------------------------------------

constructor TgmBrightContrastLayerStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmBrightContrastLayerCommand.Create(ALayerIndex, ALayerPanel, ALayerCommandType);
  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmHLSLayerStatePanel -----------------------------------------------------

constructor TgmHLSLayerStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmHLSLayerCommand.Create(ALayerIndex, ALayerPanel, ALayerCommandType);
  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmChannelMixerLayerStatePanel --------------------------------------------

constructor TgmChannelMixerLayerStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmChannelMixerLayerCommand.Create(ALayerIndex, ALayerPanel, ALayerCommandType);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmGradientMapLayerStatePanel -----------------------------------------------

constructor TgmGradientMapLayerStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmGradientMapLayerCommand.Create(ALayerIndex, ALayerPanel, ALayerCommandType);
  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmInvertLayerStatePanel --------------------------------------------------

constructor TgmInvertLayerStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmInvertLayerCommand.Create(ALayerIndex, ALayerPanel, ALayerCommandType);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmThresholdLayerStatePanel -----------------------------------------------

constructor TgmThresholdLayerStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmThresholdLayerCommand.Create(ALayerIndex, ALayerPanel, ALayerCommandType);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmPosterizeLayerStatePanel -----------------------------------------------

constructor TgmPosterizeLayerStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmPosterizeLayerCommand.Create(ALayerIndex, ALayerPanel, ALayerCommandType);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmStandardLayerStatePanel ------------------------------------------------

// For background and transparent layer.
constructor TgmStandardLayerStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmStandardLayerCommand.Create(ALayerIndex, ALayerPanel, ALayerCommandType);
  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmDuplicateLayerStatePanel -----------------------------------------------

constructor TgmDuplicateLayerStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32;
  const ACurrentIndex, ADuplicatedIndex: Integer;
  const ALayerName: string);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmDuplicateLayerCommand.Create(ACurrentIndex, ADuplicatedIndex, ALayerName);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmLayerPropertiesStatePanel ----------------------------------------------

constructor TgmLayerPropertiesStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ALayerOldName, ALayerNewName: string);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmLayerPropertiesCommand.Create(ALayerOldName, ALayerNewName);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmArrangeLayerStatePanel -------------------------------------------------

constructor TgmArrangeLayerStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const AOldIndex, ANewIndex: Integer;
  const AStyle: TgmLayerArrangementStyle);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmArrangeLayerCommand.Create(AOldIndex, ANewIndex, AStyle);
  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmLayerMaskStatePanel ------------------------------------------------------

constructor TgmLayerMaskStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const AMaskCommandType: TgmMaskCommandType;
  const AOldSelection: TgmSelection);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmLayerMaskCommand.Create(AMaskCommandType, AOldSelection);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmLinkMaskStatePanel -----------------------------------------------------

constructor TgmLinkMaskStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ALayerPanelIndex: Integer);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmLinkMaskCommand.Create(ALayerPanelIndex);
  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmUnlinkMaskStatePanel ---------------------------------------------------

constructor TgmUnlinkMaskStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ALayerPanelIndex: Integer);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmUnlinkMaskCommand.Create(ALayerPanelIndex);
  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmShapeRegionLayerStatePanel ---------------------------------------------

constructor TgmShapeRegionLayerStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32;
  const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel;
  const ARegionCommandType: TgmRegionCommandType;
  const AOutline: TgmShapeOutline = nil);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmShapeRegionLayerCommand.Create(ALayerIndex, ALayerPanel,
                                                ARegionCommandType, AOutline);
                                              
  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmModifyShapeRegionColorStatePanel ---------------------------------------

constructor TgmModifyShapeRegionColorStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const AOldColor, ANewColor: TColor);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmModifyShapeRegionColorCommand.Create(AOldColor, ANewColor);
  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmModifyShapeRegionStyleStatePanel ---------------------------------------

constructor TgmModifyShapeRegionStyleStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const AOldStyle, ANewStyle: TBrushStyle);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmModifyShapeRegionStyleCommand.Create(AOldStyle, ANewStyle);
  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmTranslateShapeRegionStatePanel -----------------------------------------

constructor TgmTranslateShapeRegionStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const AccumTranslatedVector: TPoint);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmTranslateShapeRegionCommand.Create(AccumTranslatedVector);
  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmScaleShapeRegionStatePanel ---------------------------------------------

constructor TgmScaleShapeRegionStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32;
  const AOldTopLeft, AOldBottomRight, ANewTopLeft, ANewBottomRight: TPoint);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmScaleShapeRegionCommand.Create(AOldTopLeft, AOldBottomRight,
                                                ANewTopLeft, ANewBottomRight);
                                              
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmFigureLayerStatePanel --------------------------------------------------

constructor TgmFigureLayerStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType;
  const AFigureFlag: TgmFigureFlags = ffNone);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmFigureLayerCommand.Create(ALayerIndex, ALayerPanel,
                                           ALayerCommandType, AFigureFlag);
                                         
  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmAddFigureStatePanel ----------------------------------------------------

constructor TgmAddFigureStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const AFigureObj: TgmFigureObject);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmAddFigureCommand.Create(AFigureObj);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmSelectFigureStatePanel -------------------------------------------------

constructor TgmSelectFigureStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32;
  const AOldSelectedFigureInfoArray: array of TgmFigureInfo;
  const ANewSelectedFigureInfoArray: array of TgmFigureInfo;
  const AOldSelectedFigureLayerIndexArray: array of Integer;
  const ANewSelectedFigureLayerIndexArray: array of Integer;
  const AMode: TgmSelectFigureMode);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmSelectFigureCommand.Create(AOldSelectedFigureInfoArray,
                                            ANewSelectedFigureInfoArray,
                                            AOldSelectedFigureLayerIndexArray,
                                            ANewSelectedFigureLayerIndexArray,
                                            AMode);

  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmDeleteFigureStatePanel -------------------------------------------------

constructor TgmDeleteFigureStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32;
  const AOldSelectedFigureInfoArray: array of TgmFigureInfo;
  const AOldSelectedFigureLayerIndexArray: array of Integer);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmDeleteFigureCommand.Create(AOldSelectedFigureInfoArray,
                                            AOldSelectedFigureLayerIndexArray);

  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmLockFigureStatePanel ---------------------------------------------------

constructor TgmLockFigureStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ALockMode: TgmLockFigureMode);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmLockFigureCommand.Create(ALockMode);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmModifyFigureStyleStatePanel --------------------------------------------

constructor TgmModifyFigureStyleStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32;
  const AOldData, ANewData: TgmFigureBasicData);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmModifyFigureStyleCommand.Create(AOldData, ANewData);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmStretchFigureStatePanel ------------------------------------------------

constructor TgmStretchFigureStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32;
  const AOldFigure, ANewFigure: TgmFigureObject);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmStretchFigureCommand.Create(AOldFigure, ANewFigure);
  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmTranslateFigureStatePanel ----------------------------------------------

constructor TgmTranslateFigureStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const AAccumTranslateVector: TPoint);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmTranslateFigureCommand.Create(AAccumTranslateVector);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmTypeToolLayerStatePanel ------------------------------------------------

constructor TgmTypeToolLayerStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ALayerIndex: Integer;
  const ALayerPanel: TgmLayerPanel; const ALayerCommandType: TgmLayerCommandType);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmTypeToolLayerCommand.Create(ALayerIndex, ALayerPanel, ALayerCommandType);
  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmEditTypeStatePanel -----------------------------------------------------

constructor TgmEditTypeStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ALayerIndex: Integer;
  const AOldTextStream: TMemoryStream; const ALayerPanel: TgmLayerPanel);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmEditTypeCommand.Create(ALayerIndex, AOldTextStream, ALayerPanel);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmTranslateTextRegionStatePanel ------------------------------------------

constructor TgmTranslateTextRegionStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ALayerIndex: Integer;
  const AAccumTranslateVector: TPoint);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmTranslateTextRegionCommand.Create(ALayerIndex, AAccumTranslateVector);
  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmScaleTextRegionStatePanel ----------------------------------------------

constructor TgmScaleTextRegionStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ALayerIndex: Integer;
  const AOldTopLeft, AOldBottomRight, ANewTopLeft, ANewBottomRight: TPoint);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmScaleTextRegionCommand.Create(ALayerIndex, AOldTopLeft,
                                               AOldBottomRight,
                                               ANewTopLeft, ANewBottomRight);

  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmSelectionStatePanel ----------------------------------------------------

constructor TgmSelectionStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32;
  const ACmdAim: TCommandAim;
  const AMarqueeTool: TgmMarqueeTools;
  const ASelectionCommandType: TgmSelectionCommandType;
  const AOldSelection, ANewSelection: TgmSelection;
  const ATargetAlphaChannelIndex: Integer = -1);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmSelectionCommand.Create(ACmdAim, AMarqueeTool,
                                         ASelectionCommandType,
                                         AOldSelection, ANewSelection,
                                         ATargetAlphaChannelIndex);

  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmTransformStatePanel ----------------------------------------------------

constructor TgmTransformStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32;
  const ATransformCommandType: TgmTransformCommandType;
  const ATransformMode: TgmTransformMode; const AUndoSelection: TgmSelection;
  const AUndoTransform, ARedoTransform: TgmSelectionTransformation);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmTransformCommand.Create(ATransformCommandType, ATransformMode,
                                         AUndoSelection, AUndoTransform,
                                         ARedoTransform);

  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmCutPixelsStatePanel ----------------------------------------------------

constructor TgmCutPixelsStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ACmdAim: TCommandAim;
  const AOldSelection, AOldClipboardSelection: TgmSelection;
  const ATargetAlphaChannelIndex: Integer = -1);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmCutPixelsCommand.Create(ACmdAim, AOldSelection,
                                         AOldClipboardSelection,
                                         ATargetAlphaChannelIndex);

  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmCopyPixelsStatePanel ---------------------------------------------------

constructor TgmCopyPixelsStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32;
  const AOldSelection, AOldClipboardSelection: TgmSelection);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmCopyPixelsCommand.Create(AOldSelection, AOldClipboardSelection);
  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmPastePixelsStatePanel --------------------------------------------------

constructor TgmPastePixelsStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ACmdAim: TCommandAim;
  const APastedLayerName: string; const APastedLayerIndex: Integer;
  const ABeforePasteLayerIndex: Integer; const ATargetAlphaChannelIndex: Integer;
  const AOldSelection: TgmSelection; const AOldBackground: TBitmap32);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmPastePixelsCommand.Create(ACmdAim, APastedLayerName,
                                           APastedLayerIndex,
                                           ABeforePasteLayerIndex,
                                           ATargetAlphaChannelIndex,
                                           AOldSelection, AOldBackground);

  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmFlipSelectionStatePanel ------------------------------------------------

constructor TgmFlipSelectionStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ACmdAim: TCommandAim;
  const AOldSelection, ANewSelection: TgmSelection;
  const AFlipMode: TgmFlipMode;
  const ATargetAlphaChannelIndex: Integer);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmFlipSelectionCommand.Create(ACmdAim, AOldSelection,
                                             ANewSelection, AFlipMode,
                                             ATargetAlphaChannelIndex);

  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmNewWorkPathStatePanel --------------------------------------------------

constructor TgmNewWorkPathStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const APathPanelIndex: Integer;
  const APenPath: TgmPenPath);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmNewWorkPathCommand.Create(APathPanelIndex, APenPath);
  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmModifyPathStatePanel ---------------------------------------------------

constructor TgmModifyPathStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32;
  const APathPanelIndex, AOldPathIndex, ANewPathIndex: Integer;
  const AOldPathList, ANewPathList: TgmPenPathList;
  const AModifyMode: TgmModifyPathMode);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmModifyPathCommand.Create(APathPanelIndex, AOldPathIndex,
                                          ANewPathIndex, AOldPathList,
                                          ANewPathList, AModifyMode);

  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmActiveWorkPathStatePanel -----------------------------------------------

constructor TgmActiveWorkPathStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const APathPanelIndex: Integer;
  const AOldPenPathList: TgmPenPathList; const APenPath: TgmPenPath);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmActiveWorkPathCommand.Create(APathPanelIndex, AOldPenPathList, APenPath);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmClosePathStatePanel ----------------------------------------------------

constructor TgmClosePathStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const APathPanelIndex, APathIndex: Integer;
  const AOldPathList: TgmPenPathList);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmClosePathCommand.Create(APathPanelIndex, APathIndex, AOldPathList);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmTranslatePathsStatePanel -----------------------------------------------

constructor TgmTranslatePathsStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const APathPanelIndex: Integer;
  const AAccumTranslateVector: TPoint);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmTranslatePathsCommand.Create(APathPanelIndex, AAccumTranslateVector);
  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmNewPathStatePanel ------------------------------------------------------

constructor TgmNewPathStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32;
  const AOldPathPanelIndex, ANewPathPanelIndex: Integer;
  const AOldPathList: TgmPenPathList);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmNewPathCommand.Create(AOldPathPanelIndex, ANewPathPanelIndex, AOldPathList);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmDeletePathStatePanel ---------------------------------------------------

constructor TgmDeletePathStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const APathPanelIndex: Integer);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmDeletePathCommand.Create(APathPanelIndex);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmPathToSelectionStatePanel ----------------------------------------------

constructor TgmPathToSelectionStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const AOldSelection: TgmSelection;
  const APathList: TgmPenPathList);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmPathToSelectionCommand.Create(AOldSelection, APathList);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmAlphaChannelOptionsStatePanel ------------------------------------------

constructor TgmAlphaChannelOptionsStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const AChannelIndex: Integer;
  const AOptionsHistoryData: TgmChannelOptionsHistoryData);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmAlphaChannelOptionsCommand.Create(AChannelIndex, AOptionsHistoryData);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmQuickMaskChannelOptionsStatePanel --------------------------------------

constructor TgmQuickMaskOptionsStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const AQuickMaskPanel: TgmQuickMaskPanel;
  const AOptionsHistoryData: TgmChannelOptionsHistoryData);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmQuickMaskOptionsCommand.Create(AQuickMaskPanel, AOptionsHistoryData);
  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmLoadChannelAsSelectionStatePanel ---------------------------------------

constructor TgmLoadChannelAsSelectionStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32;
  const AOldSelection, ANewSelection: TgmSelection);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmLoadChannelAsSelectionCommand.Create(AOldSelection, ANewSelection);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmSaveSelectionAsChannelStatePanel ---------------------------------------

constructor TgmSaveSelectionAsChannelStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ASelectionChannelIndex: Integer);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmSaveSelectionAsChannelCommand.Create(ASelectionChannelIndex);
  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmNewChannelStatePanel ---------------------------------------------------

constructor TgmNewChannelStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const AChannelIndex: Integer);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmNewChannelCommand.Create(AChannelIndex);
  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmDeleteChannelStatePanel ------------------------------------------------

constructor TgmDeleteChannelStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const AOldChannelPanel: TgmAlphaChannelPanel;
  const AChannelIndex: Integer);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmDeleteChannelCommand.Create(AOldChannelPanel, AChannelIndex);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmDuplicateChannelStatePanel ---------------------------------------------

constructor TgmDuplicateChannelStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32;
  const ADuplicatedChannelPanel: TgmAlphaChannelPanel);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmDuplicateChannelCommand.Create(ADuplicatedChannelPanel);
  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmEnterQuickMaskStatePanel -----------------------------------------------

constructor TgmEnterQuickMaskStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const AOldSelection: TgmSelection);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmEnterQuickMaskCommand.Create(AOldSelection);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmExitQuickMaskStatePanel ------------------------------------------------

constructor TgmExitQuickMaskStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const AQuickMaskPanel: TgmQuickMaskPanel;
  const AOldSelection: TgmSelection);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmExitQuickMaskCommand.Create(AQuickMaskPanel, AOldSelection);
  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmFlattenImageStatePanel -------------------------------------------------

constructor TgmFlattenImageStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmMergeLayersCommand.Create(mlmFlatten);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmMergeLayerDownStatePanel -----------------------------------------------

constructor TgmMergeLayerDownStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmMergeLayersCommand.Create(mlmMergeDown);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmMergeVisibleLayersStatePanel -------------------------------------------

constructor TgmMergeVisibleLayersStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmMergeLayersCommand.Create(mlmMergeVisible);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmChangeImageSizeStatePanel ----------------------------------------------

constructor TgmChangeImageSizeStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ANewWidth, ANewHeight: Integer;
  const AResamplingOptions: TgmResamplingOptions);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmChangeImageSizeCommand.Create(ANewWidth, ANewHeight, AResamplingOptions);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmChangeCanvasSizeStatePanel ---------------------------------------------

constructor TgmChangeCanvasSizeStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ANewWidth, ANewHeight: Integer;
  const AAnchorDirection: TgmAnchorDirection; const ABackgroundColor: TColor32);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmChangeCanvasSizeCommand.Create(ANewWidth, ANewHeight,
                                                AAnchorDirection,
                                                ABackgroundColor);
                                              
  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmRotateCanvasStatePanel -------------------------------------------------

constructor TgmRotateCanvasStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ADeg: Integer;
  const ARotateDirection: TgmRotateDirection);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmRotateCanvasCommand.Create(ADeg, ARotateDirection);
  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmCropStatePanel ---------------------------------------------------------

constructor TgmCropStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32; const ACrop: TgmCrop);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmCropCommand.Create(ACrop);
  FCommandNameLabel.Caption := FCommand.CommandName;
end;

//-- TgmOptimalCropStatePanel --------------------------------------------------

constructor TgmOptimalCropStatePanel.Create(AOwner: TWinControl;
  const ACommandMaskIcon: TBitmap32);
begin
  inherited Create(AOwner, ACommandMaskIcon, '');

  FCommand := TgmOptimalCropCommand.Create;
  FCommandNameLabel.Caption := FCommand.CommandName;
end; 

//-- TgmHistoryManager ---------------------------------------------------------

constructor TgmHistoryManager.Create(const AMaxStateCount: Integer);
begin
  inherited Create;

  FSnapshotPanelList     := TList.Create;
  FHistoryStatePanelList := TList.Create;
  FCurrentStateIndex     := -1;
  FMaxStateCount         := AMaxStateCount;
  FOperateName           := '';
  FCommandState          := csNone;
  FAllowRefreshPanels    := True;
end; 

destructor TgmHistoryManager.Destroy;
begin
  DeleteAllHistoryStates;
  DeleteAllSnapshots;
  
  inherited Destroy;
end; 

function TgmHistoryManager.AddSnapshot(
  const ASnapshotPanel: TgmSnapshotPanel): Integer;
begin
  if Assigned(ASnapshotPanel) then
  begin
    ConnectEventsToSnapshotPanel(ASnapshotPanel);
    FSnapshotPanelList.Add(ASnapshotPanel);
    SelectSnapshotByIndex(FSnapshotPanelList.Count - 1);

    Result := FSnapshotPanelList.Count - 1;
    UpdateAllPanelsState;

    if FAllowRefreshPanels then
    begin
      ShowAllPanelsByRightOrder;
    end;
  end
  else
  begin
    Result := -1;
  end;
end;

function TgmHistoryManager.AddHistoryState(
  const AHistoryStatePanel: TgmHistoryStatePanel): Integer;
var
  Diff: Integer;
begin
  if Assigned(AHistoryStatePanel) then
  begin
    if FCurrentStateIndex < (FHistoryStatePanelList.Count - 1) then
    begin
      DeleteHistoryStates(FCurrentStateIndex + 1, FHistoryStatePanelList.Count - 1);
    end;

    ConnectEventsToHistoryStatePanel(AHistoryStatePanel);
    AHistoryStatePanel.IsEnabled := True;
    FHistoryStatePanelList.Add(AHistoryStatePanel);

    // delete superfluous history states in the list
    Diff := FHistoryStatePanelList.Count - FMaxStateCount;

    if Diff > 0 then
    begin
      DeleteHistoryStates(0, diff - 1);
    end;

    SelectHistoryStateByIndex(FHistoryStatePanelList.Count - 1);
    
    Result             := FHistoryStatePanelList.Count - 1;
    FCurrentStateIndex := FHistoryStatePanelList.Count - 1;
    FOperateName       := AHistoryStatePanel.Command.OperateName;
    FCommandState      := AHistoryStatePanel.Command.CommandState;
    
    UpdateAllPanelsState;

    if FAllowRefreshPanels then
    begin
      ShowAllPanelsByRightOrder;
    end;
    
    frmHistory.scrlbxHistory.VertScrollBar.Position := frmHistory.scrlbxHistory.VertScrollBar.Range;
  end
  else
  begin
    Result := -1;
  end;
end; 

function TgmHistoryManager.SelectSnapshotByIndex(
  const AIndex: Integer): Boolean;
var
  SnapshotPanel: TgmSnapshotPanel;
begin
  Result := False;

  if FSnapshotPanelList.Count > 0 then
  begin
    if (AIndex >= 0) and (AIndex < FSnapshotPanelList.Count) then
    begin
      DeselectAllSnapshots;
      DeselectAllHistoryStates;
      
      SnapshotPanel            := TgmSnapShotPanel(FSnapshotPanelList.Items[AIndex]);
      SnapshotPanel.IsSelected := True;
      Result                   := True;
    end;
  end;
end;

function TgmHistoryManager.SelectHistoryStateByIndex(
  const AIndex: Integer): Boolean;
var
  HistoryStatePanel: TgmHistoryStatePanel;
begin
  Result := False;

  if FHistoryStatePanelList.Count > 0 then
  begin
    if (AIndex >= 0) and (AIndex < FHistoryStatePanelList.Count) then
    begin
      DeselectAllSnapshots;
      DeselectAllHistoryStates;
      
      HistoryStatePanel            := TgmHistoryStatePanel(FHistoryStatePanelList.Items[AIndex]);
      HistoryStatePanel.IsSelected := True;
      FCurrentStateIndex           := AIndex;
      Result                       := True;
    end;
  end;
end;

function TgmHistoryManager.GetCommandCount: Integer;
begin
  Result := FHistoryStatePanelList.Count;
end;

procedure TgmHistoryManager.UpdateSnapshotPanelsState;
var
  i            : Integer;
  SnapshotPanel: TgmSnapshotPanel;
begin
  if FSnapshotPanelList.Count > 0 then
  begin
    for i := 0 to (FSnapshotPanelList.Count - 1) do
    begin
      SnapshotPanel := FSnapshotPanelList.Items[i];
      SnapshotPanel.UpdatePanelState;
    end;
  end;
end;

procedure TgmHistoryManager.UpdateHistoryStatePanelsState;
var
  i                : Integer;
  HistoryStatePanel: TgmHistoryStatePanel;
begin
  if FHistoryStatePanelList.Count > 0 then
  begin
    for i := 0 to (FHistoryStatePanelList.Count - 1) do
    begin
      HistoryStatePanel := TgmHistoryStatePanel(FHistoryStatePanelList.Items[i]);
      HistoryStatePanel.UpdatePanelState;
    end;
  end;
end; 

procedure TgmHistoryManager.HideAllPanels;
var
  i                : Integer;
  HistoryStatePanel: TgmHistoryStatePanel;
  SnapshotPanel    : TgmSnapshotPanel;
begin
  if FHistoryStatePanelList.Count > 0 then
  begin
    for i := (FHistoryStatePanelList.Count - 1) downto 0 do
    begin
      HistoryStatePanel := TgmHistoryStatePanel(FHistoryStatePanelList.Items[i]);
      HistoryStatePanel.MainPanel.Hide;
    end;
  end;

  if FSnapshotPanelList.Count > 0 then
  begin
    for i := (FSnapshotPanelList.Count - 1) downto 0 do
    begin
      SnapshotPanel := TgmSnapshotPanel(FSnapshotPanelList.Items[i]);
      SnapshotPanel.MainPanel.Hide;
    end;
  end;
end;

procedure TgmHistoryManager.SnapshotPanelClick(Sender: TObject);
var
  i            : Integer;
  SnapshotPanel: TgmSnapshotPanel;
begin
  if ActiveChildForm <> nil then
  begin
    if frmRichTextEditor.Visible or
       (ActiveChildForm.Crop <> nil) then
    begin
      Exit;
    end;
  end;

  if FSnapshotPanelList.Count > 0 then
  begin
    for i := 0 to (FSnapshotPanelList.Count - 1) do
    begin
      SnapshotPanel := TgmSnapshotPanel(FSnapshotPanelList.Items[i]);
      
      if (Sender = SnapshotPanel.MainPanel) or
         (Sender = SnapshotPanel.ImageHolder) or
         (Sender = SnapshotPanel.SnapshotImage) then
      begin
        CallRollbacks(FCurrentStateIndex, 0);
        SelectSnapshotByIndex(i);
        UpdateAllPanelsState;
        Break;
      end;
    end;
  end;
end; 

procedure TgmHistoryManager.HistoryStatePanelClick(ASender: TObject);
var
  i                : Integer;
  HistoryStatePanel: TgmHistoryStatePanel;
begin
  if ActiveChildForm <> nil then
  begin
    if frmRichTextEditor.Visible or
       (ActiveChildForm.Crop <> nil) then
    begin
      Exit;
    end;
  end;

  if FHistoryStatePanelList.Count > 0 then
  begin
    for i := 0 to (FHistoryStatePanelList.Count - 1) do
    begin
      HistoryStatePanel := TgmHistoryStatePanel(FHistoryStatePanelList.Items[i]);
      
      if (ASender = HistoryStatePanel.MainPanel) or
         (ASender = HistoryStatePanel.CommandImage) or
         (ASender = HistoryStatePanel.CommandNameLabel) then
      begin
        if i > FCurrentStateIndex then
        begin
          CallExecutes(FCurrentStateIndex + 1, i);
        end
        else if i < FCurrentStateIndex then
        begin
          CallRollbacks(FCurrentStateIndex, i + 1);
        end;

        if i <> FCurrentStateIndex then
        begin
          SelectHistoryStateByIndex(i);
          UpdateAllPanelsState;
        end;

        Break;
      end;
    end;
  end;
end;

procedure TgmHistoryManager.CallRollbacks(const AEndIndex, AStartIndex: Integer);
var
  i                : Integer;
  HistoryStatePanel: TgmHistoryStatePanel;
begin
  HistoryStatePanel := nil;

  if (AStartIndex >= 0) and
     (AStartIndex < FHistoryStatePanelList.Count) and
     (AEndIndex   >= 0) and
     (AEndIndex   < FHistoryStatePanelList.Count) then
  begin
    if AStartIndex <= AEndIndex then
    begin
      Screen.Cursor := crHourGlass;
      try
        for i := AEndIndex downto AStartIndex do
        begin
          HistoryStatePanel           := TgmHistoryStatePanel(FHistoryStatePanelList.Items[i]);
          HistoryStatePanel.IsEnabled := False;
          HistoryStatePanel.Command.Rollback;
        end;
        
        FCommandState := HistoryStatePanel.Command.CommandState;
        FOperateName  := HistoryStatePanel.Command.OperateName;
      finally
        Screen.Cursor := crDefault;
      end;
    end;
  end;
end;

procedure TgmHistoryManager.CallExecutes(const AStartIndex, AEndIndex: Integer);
var
  i                : Integer;
  HistoryStatePanel: TgmHistoryStatePanel;
begin
  HistoryStatePanel := nil;

  if (AStartIndex >= 0) and
     (AStartIndex < FHistoryStatePanelList.Count) and
     (AEndIndex   >= 0) and
     (AEndIndex   < FHistoryStatePanelList.Count) then
  begin
    if AStartIndex <= AEndIndex then
    begin
      Screen.Cursor := crHourGlass;
      try
        for i := AStartIndex to AEndIndex do
        begin
          HistoryStatePanel           := TgmHistoryStatePanel(FHistoryStatePanelList.Items[i]);
          HistoryStatePanel.IsEnabled := True;
          HistoryStatePanel.Command.Execute;
        end;
        
        FCommandState := HistoryStatePanel.Command.CommandState;
        FOperateName  := HistoryStatePanel.Command.OperateName;
      finally
        Screen.Cursor := crDefault;
      end;
    end;
  end;
end; 

procedure TgmHistoryManager.DeleteHistoryStates(
  const AStartIndex, AEndIndex: Integer);
var
  i                : Integer;
  HistoryStatePanel: TgmHistoryStatePanel;
begin
  if FHistoryStatePanelList.Count > 0 then
  begin
    if (AStartIndex >= 0) and
       (AStartIndex < FHistoryStatePanelList.Count) and
       (AEndIndex   >= 0) and
       (AEndIndex   < FHistoryStatePanelList.Count) then
    begin
      if AStartIndex <= AEndIndex then
      begin
        Screen.Cursor := crHourGlass;
        try
          for i := AEndIndex downto AStartIndex do
          begin
            HistoryStatePanel := TgmHistoryStatePanel(FHistoryStatePanelList.Items[i]);
            HistoryStatePanel.MainPanel.Visible := False;
            HistoryStatePanel.Free;
            FHistoryStatePanelList.Delete(i);
          end;
        finally
          Screen.Cursor := crDefault;
        end;
      end;
    end;
  end;
end; 

procedure TgmHistoryManager.ConnectEventsToSnapshotPanel(
  const ASnapshotPanel: TgmSnapshotPanel);
begin
  ASnapshotPanel.MainPanel.OnClick         := SnapshotPanelClick;
  ASnapshotPanel.ImageHolder.OnClick       := SnapshotPanelClick;
  ASnapshotPanel.SnapshotImage.OnClick     := SnapshotPanelClick;
  ASnapshotPanel.SnapshotNameLabel.OnClick := SnapshotPanelClick;
end;

procedure TgmHistoryManager.ConnectEventsToHistoryStatePanel(
  const AHistoryStatePanel: TgmHistoryStatePanel);
begin
  AHistoryStatePanel.MainPanel.OnClick        := HistoryStatePanelClick;
  AHistoryStatePanel.CommandImage.OnClick     := HistoryStatePanelClick;
  AHistoryStatePanel.CommandNameLabel.OnClick := HistoryStatePanelClick;
end;

procedure TgmHistoryManager.DeleteAllSnapshots;
var
  i            : Integer;
  SnapshotPanel: TgmSnapshotPanel;
begin
  if FSnapshotPanelList.Count > 0 then
  begin
    for i := (FSnapshotPanelList.Count - 1) downto 0 do
    begin
      SnapshotPanel := TgmSnapshotPanel(FSnapshotPanelList.Items[i]);
      SnapshotPanel.MainPanel.Visible := False;
      SnapshotPanel.Free;
    end;
    
    FSnapshotPanelList.Clear;
  end;
end;

procedure TgmHistoryManager.DeleteAllHistoryStates;
var
  i                : Integer;
  HistoryStatePanel: TgmHistoryStatePanel;
begin
  if FHistoryStatePanelList.Count > 0 then
  begin
    for i := (FHistoryStatePanelList.Count - 1) downto 0 do
    begin
      HistoryStatePanel := TgmHistoryStatePanel(FHistoryStatePanelList.Items[i]);
      HistoryStatePanel.MainPanel.Visible := False;
      HistoryStatePanel.Free;
    end;
    
    FHistoryStatePanelList.Clear;
    FCurrentStateIndex := -1;
  end;
end;

procedure TgmHistoryManager.UpdateAllPanelsState;
begin
  UpdateSnapshotPanelsState;
  UpdateHistoryStatePanelsState;
  
  frmHistory.tlbtnDeleteCurrentState.Enabled := (FCurrentStateIndex >= 0);
end;

procedure TgmHistoryManager.DeselectAllSnapshots;
var
  i            : Integer;
  SnapshotPanel: TgmSnapshotPanel;
begin
  if FSnapshotPanelList.Count > 0 then
  begin
    for i := 0 to (FSnapshotPanelList.Count - 1) do
    begin
      SnapshotPanel            := TgmSnapshotPanel(FSnapshotPanelList.Items[i]);
      SnapshotPanel.IsSelected := False;
    end;
  end;
end;

procedure TgmHistoryManager.DeselectAllHistoryStates;
var
  i                : Integer;
  HistoryStatePanel: TgmHistoryStatePanel;
begin
  if FHistoryStatePanelList.Count > 0 then
  begin
    for i := 0 to (FHistoryStatePanelList.Count - 1) do
    begin
      HistoryStatePanel            := TgmHistoryStatePanel(FHistoryStatePanelList.Items[i]);
      HistoryStatePanel.IsSelected := False;
      FCurrentStateIndex           := -1;
    end;
  end;
end; 

procedure TgmHistoryManager.ShowAllPanelsByRightOrder;
var
  i                : Integer;
  SnapshotPanel    : TgmSnapshotPanel;
  HistoryStatePanel: TgmHistoryStatePanel;
  HSPStartTop      : Integer;
begin
  HSPStartTop := 0;

  HideAllPanels;

  if FSnapshotPanelList.Count > 0 then
  begin
    for i := 0 to (FSnapshotPanelList.Count - 1) do
    begin
      SnapshotPanel               := TgmSnapshotPanel(FSnapshotPanelList.Items[0]);
      SnapshotPanel.MainPanel.Top := i * SNAPSHOT_MAIN_PANEL_HEIGHT;
      SnapshotPanel.MainPanel.Show;

      if i = (FSnapshotPanelList.Count - 1) then
      begin
        HSPStartTop := SnapshotPanel.MainPanel.Top + SNAPSHOT_MAIN_PANEL_HEIGHT;
      end;
    end;
  end;

  if FHistoryStatePanelList.Count > 0 then
  begin
    for i := 0 to (FHistoryStatePanelList.Count - 1) do
    begin
      HistoryStatePanel               := TgmHistoryStatePanel(FHistoryStatePanelList.Items[i]);
      HistoryStatePanel.MainPanel.Top := i * HISTORY_STATE_MAIN_PANEL_HEIGHT + HSPStartTop;
      HistoryStatePanel.MainPanel.Show;
    end;
  end;
end;

procedure TgmHistoryManager.RollbackCommand;
var
  HistoryStatePanel: TgmHistoryStatePanel;
begin
  if (FCurrentStateIndex >= 0) and (FCurrentStateIndex < FHistoryStatePanelList.Count) then
  begin
    HistoryStatePanel := TgmHistoryStatePanel(FHistoryStatePanelList.Items[FCurrentStateIndex]);
    HistoryStatePanel.Command.Rollback;
    HistoryStatePanel.IsEnabled := False;

    FCommandState := HistoryStatePanel.Command.CommandState;
    FOperateName  := HistoryStatePanel.Command.OperateName;
    
    Dec(FCurrentStateIndex);
  end;

  if FCurrentStateIndex >= 0 then
  begin
    SelectHistoryStateByIndex(FCurrentStateIndex);
  end
  else
  begin
    SelectSnapshotByIndex(FSnapshotPanelList.Count - 1);
  end;

  UpdateAllPanelsState;
end;

procedure TgmHistoryManager.ExecuteCommand;
var
  HistoryStatePanel: TgmHistoryStatePanel;
begin
  Inc(FCurrentStateIndex);

  if (FCurrentStateIndex >= 0) and (FCurrentStateIndex < FHistoryStatePanelList.Count) then
  begin
    HistoryStatePanel := TgmHistoryStatePanel(FHistoryStatePanelList.Items[FCurrentStateIndex]);
    HistoryStatePanel.Command.Execute;
    HistoryStatePanel.IsEnabled := True;
    FCommandState := HistoryStatePanel.Command.CommandState;
    FOperateName  := HistoryStatePanel.Command.OperateName;
  end;

  if FCurrentStateIndex >= FHistoryStatePanelList.Count then
  begin
    FCurrentStateIndex := FHistoryStatePanelList.Count - 1;
  end;

  if FCurrentStateIndex >= 0 then
  begin
    SelectHistoryStateByIndex(FCurrentStateIndex);
  end;

  UpdateAllPanelsState;
end; 

end.
