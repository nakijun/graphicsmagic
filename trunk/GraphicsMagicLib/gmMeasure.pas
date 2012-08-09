{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved. }

unit gmMeasure;

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
  Windows, Classes, Graphics;

type
  // indicating which point of the measure line you want to modify
  TgmMeasurePointSelector = (mpsNone, mpsFirst, mpsSecond, mpsThird);
  
  // Measure Unit
  TgmMeasureUnit = (muPixel, muInch, muCM);

  TgmMeasureLine = class(TObject)
  private
    FMeasurePoints: array of TPoint; // measure points for measure line

    { Calculation }
    FOriginalIntX  : Integer;
    FOriginalIntY  : Integer;
    FIntWidth      : Integer;
    FIntHeight     : Integer;
    FIntDistance1  : Integer;
    FIntDistance2  : Integer;

    FOriginalFloatX: Extended;
    FOriginalFloatY: Extended;
    FFloatWidth    : Extended;
    FFloatHeight   : Extended;
    FFloatDistance1: Extended;
    FFloatDistance2: Extended;

    FMeasureAngle  : Extended;
    FOffsetVector  : TPoint;

    function GetMeasurePointCount: Integer;
    procedure DrawHandles(const ACanvas: TCanvas; const APenMode: TPenMode);
  public
    constructor Create(const AOffsetVector: TPoint);
    destructor Destroy; override;

    // change coordnate for the selected Measure point
    procedure SetMeasurePoint(const AX, AY: Integer;
      const AMeasurePointSelector: TgmMeasurePointSelector);

    // add third Measure point for measure line
    procedure AddThirdMeasurePoint(const AX, AY: Integer);
    procedure Translate(const ATranslateVector: TPoint);
    procedure SwapFirstAndSecondMeasurePoint;

    // check whether the mouse is over one of the Measure points
    function GetHandleAtPoint(const AX, AY: Integer): TgmMeasurePointSelector;

    // check whether the mouse is over the Measure line
    function ContainsPoint(const AX, AY: Integer):  Boolean;
    procedure Draw(const ACanvas: TCanvas; const APenMode: TPenMode);

    // calculate the measure result
    procedure Calculate(const AUnit: TgmMeasureUnit; const APixelsPerInch: Integer);

    property LineCount     : Integer  read GetMeasurePointCount;
    property OriginalIntX  : Integer  read FOriginalIntX;
    property OriginalIntY  : Integer  read FOriginalIntY;
    property IntWidth      : Integer  read FIntWidth;
    property IntHeight     : Integer  read FIntWidth;
    property IntDistance1  : Integer  read FIntDistance1;
    property IntDistance2  : Integer  read FIntDistance2;
    property OriginalFloatX: Extended read FOriginalFloatX;
    property OriginalFloatY: Extended read FOriginalFloatY;
    property FloatWidth    : Extended read FFloatWidth;
    property FloatHeight   : Extended read FFloatWidth;
    property FloatDistance1: Extended read FFloatDistance1;
    property FloatDistance2: Extended read FFloatDistance2;
    property MeasureAngle  : Extended read FMeasureAngle;
  end;

implementation

uses
{ Standard }
  Math,
{ externals }
  LineLibrary,
{ GraphicsMagic Lib }
  gmConstants,
  gmCommonFuncs;


procedure DrawSpider(const ACanvas: TCanvas; const APoint: TPoint;
  const ARadius: Integer; const AColor: TColor; const APenMode: TPenMode);
var
  LTempPenColor: TColor;
  LTempPenMode : TPenMode;
begin
  with ACanvas do
  begin
    LTempPenColor := Pen.Color;
    LTempPenMode  := Pen.Mode;

    Pen.Color := AColor;
    Pen.Mode  := APenMode;

    MoveTo(APoint.X - ARadius + 1, APoint.Y);
    LineTo(APoint.X + ARadius, APoint.Y);
    MoveTo(APoint.X, APoint.Y - ARadius + 1);
    LineTo(APoint.X, APoint.Y + ARadius);

    Pen.Color := LTempPenColor;
    Pen.Mode  := LTempPenMode;
  end;
end;

{ Measure }

procedure CalculateMeasureByPixels(const MeasurePolygon: array of TPoint;
  var OriginalX, OriginalY, AWidth, AHeight, D1, D2: Integer;
  var Angle: Extended; const OffsetVector: TPoint);
var
  TempW, TempH            : Integer;
  Radians1, Radians2      : Extended;
  Hypotenuse1, Hypotenuse2: Extended;
  Angle1, Angle2          : Extended;
  MaxAngle, MinAngle      : Extended;
begin
  if ( High(MeasurePolygon) > 0 ) then
  begin
    OriginalX := MeasurePolygon[0].X + OffsetVector.X;
    OriginalY := MeasurePolygon[0].Y + OffsetVector.Y;

    if ( High(MeasurePolygon) = 1 ) then
    begin
      AWidth      := MeasurePolygon[1].X - MeasurePolygon[0].X;
      AHeight     := MeasurePolygon[1].Y - MeasurePolygon[0].Y;
      D1          := Round( Sqrt( AWidth * AWidth + AHeight * AHeight) );
      Hypotenuse1 := Sqrt( AWidth * AWidth + AHeight * AHeight);

      if  (MeasurePolygon[1].X >= MeasurePolygon[0].X)
      and (MeasurePolygon[1].Y <= MeasurePolygon[0].Y) then
      begin
        // the second point is in the first quadrant
        if Hypotenuse1 <> 0.0 then
        begin
          Radians1 := ArcSin( Abs(AHeight) / Hypotenuse1 );
          Angle    := RadToDeg(Radians1);
        end
        else Angle := 0.0;
      end
      else
      // the second point is in the second quadrant
      if  (MeasurePolygon[1].X <= MeasurePolygon[0].X)
      and (MeasurePolygon[1].Y <= MeasurePolygon[0].Y) then
      begin
        if Hypotenuse1 <> 0.0 then
        begin
          Radians1 := ArcSin( Abs(AHeight) / Hypotenuse1 );
          Angle    := 180 - RadToDeg(Radians1);
        end
        else Angle := 0.0;
      end
      else
      // the second point is in the third quadrant
      if  (MeasurePolygon[1].X <= MeasurePolygon[0].X)
      and (MeasurePolygon[1].Y >= MeasurePolygon[0].Y) then
      begin
        if Hypotenuse1 <> 0.0 then
        begin
          Radians1 := ArcSin( Abs(AHeight) / Hypotenuse1 );
          Angle    := 0 - ( 180 - RadToDeg(Radians1) );
        end
        else Angle := 0.0;
      end
      else
      // the second point is in the forth quadrant
      if  (MeasurePolygon[1].X >= MeasurePolygon[0].X)
      and (MeasurePolygon[1].Y >= MeasurePolygon[0].Y) then
      begin
        if Hypotenuse1 <> 0.0 then
        begin
          Radians1 := ArcSin( Abs(AHeight) / Hypotenuse1 );
          Angle    := 0 - RadToDeg(Radians1);
        end
        else Angle := 0.0;
      end;
    end
    else
    if ( High(MeasurePolygon) = 2 ) then
    begin
      AWidth      := MeasurePolygon[1].X - MeasurePolygon[0].X;
      AHeight     := MeasurePolygon[1].Y - MeasurePolygon[0].Y;
      D1          := Round( Sqrt( AWidth * AWidth + AHeight * AHeight) );
      Hypotenuse1 := Sqrt( AWidth * AWidth + AHeight * AHeight);
      TempW       := MeasurePolygon[2].X - MeasurePolygon[1].X;
      TempH       := MeasurePolygon[2].Y - MeasurePolygon[1].Y;
      D2          := Round( Sqrt( TempW * TempW + TempH * TempH) );
      Hypotenuse2 := Sqrt( TempW * TempW + TempH * TempH);

      if Hypotenuse1 <> 0.0 then
      begin
        Radians1 := ArcSin( Abs(AHeight) / Hypotenuse1 );
        Angle1   := RadToDeg(Radians1);
      end
      else Angle1 := 0.0;

      if Hypotenuse2 <> 0.0 then
      begin
        Radians2 := ArcSin( Abs(TempH) / Hypotenuse2 );
        Angle2   := RadToDeg(Radians2);
      end
      else Angle2 := 0.0;
      
      // The two points are both in the first, second, third or forth quadrant.
      if ( (MeasurePolygon[0].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y <= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y <= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y <= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y <= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y >= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y >= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y >= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y >= MeasurePolygon[1].Y) )
      then Angle := Abs(Angle1 - Angle2)
      else
      { One point is in the first quadrant, and another is in the second quadrant,
        or, one point is in the third quadrant and another is in the forth quadrant. }
      if ( (MeasurePolygon[0].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y <= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y <= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y <= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y <= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y >= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y >= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y >= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y >= MeasurePolygon[1].Y) )
      then Angle := 180 - Angle1 - Angle2
      else
      { One point is in the second quadrant, and another is in the third quadrant,
        or, one point is in the first quadrant and another is in the forth quadrant. }
      if ( (MeasurePolygon[0].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y <= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y >= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y >= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y <= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y <= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y >= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y >= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y <= MeasurePolygon[1].Y) )
      then Angle := Angle2 + Angle1
      else
      { One point is in the first quadrant, and another is in the third quadrant,
        or, one point is in the second quadrant and another is in the forth quadrant. }
      if ( (MeasurePolygon[0].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y <= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y >= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y >= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y <= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y <= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y >= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y >= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y <= MeasurePolygon[1].Y) ) then
      begin
        MaxAngle := Max(Angle1, Angle2);
        MinAngle := Min(Angle1, Angle2);
        Angle    := 180 - MaxAngle + MinAngle;
      end;
    end;
  end;
end; 

procedure CalculateMeasureByInches(const MeasurePolygon: array of TPoint;
  const PixelsPerInch: Integer;
  var OriginalX, OriginalY, AWidth, AHeight, D1, D2, Angle: Extended;
  const OffsetVector: TPoint);
var
  TempW, TempH      : Extended;
  Radians1, Radians2: Extended;
  Angle1, Angle2    : Extended;
  MaxAngle, MinAngle: Extended;
begin
  if ( High(MeasurePolygon) > 0 ) then
  begin
    OriginalX := (MeasurePolygon[0].X + OffsetVector.X) / PixelsPerInch;
    OriginalY := (MeasurePolygon[0].Y + OffsetVector.Y) / PixelsPerInch;

    if ( High(MeasurePolygon) = 1 ) then
    begin
      AWidth  := (MeasurePolygon[1].X - MeasurePolygon[0].X) / PixelsPerInch;
      AHeight := (MeasurePolygon[1].Y - MeasurePolygon[0].Y) / PixelsPerInch;
      D1      := Sqrt(AWidth * AWidth + AHeight * AHeight);

      // The second point is in the first quadrant.
      if  (MeasurePolygon[1].X >= MeasurePolygon[0].X)
      and (MeasurePolygon[1].Y <= MeasurePolygon[0].Y) then
      begin
        if D1 <> 0.0 then
        begin
          Radians1 := ArcSin( Abs(AHeight) / D1 );
          Angle    := RadToDeg(Radians1);
        end
        else Angle := 0.0;
      end
      else
      // The second point is in the second quadrant.
      if  (MeasurePolygon[1].X <= MeasurePolygon[0].X)
      and (MeasurePolygon[1].Y <= MeasurePolygon[0].Y) then
      begin
        if D1 <> 0.0 then
        begin
          Radians1 := ArcSin( Abs(AHeight) / D1 );
          Angle    := 180 - RadToDeg(Radians1);
        end
        else Angle := 0.0;
      end
      else
      // The second point is in the third quadrant.
      if  (MeasurePolygon[1].X <= MeasurePolygon[0].X)
      and (MeasurePolygon[1].Y >= MeasurePolygon[0].Y) then
      begin
        if D1 <> 0.0 then
        begin
          Radians1 := ArcSin( Abs(AHeight) / D1 );
          Angle    := 0 - ( 180 - RadToDeg(Radians1) );
        end
        else Angle := 0.0;
      end
      else
      // The second point is in the forth quadrant.
      if  (MeasurePolygon[1].X >= MeasurePolygon[0].X)
      and (MeasurePolygon[1].Y >= MeasurePolygon[0].Y) then
      begin
        if D1 <> 0.0 then
        begin
          Radians1 := ArcSin( Abs(AHeight) / D1 );
          Angle    := 0 - RadToDeg(Radians1);
        end
        else Angle := 0.0;
      end;
    end
    else
    if ( High(MeasurePolygon) = 2 ) then
    begin
      AWidth  := (MeasurePolygon[1].X - MeasurePolygon[0].X) / PixelsPerInch;
      AHeight := (MeasurePolygon[1].Y - MeasurePolygon[0].Y) / PixelsPerInch;
      D1      := Sqrt(AWidth * AWidth + AHeight * AHeight);
      TempW   := (MeasurePolygon[2].X - MeasurePolygon[1].X) / PixelsPerInch;
      TempH   := (MeasurePolygon[2].Y - MeasurePolygon[1].Y) / PixelsPerInch;
      D2      := Sqrt(TempW * TempW + TempH * TempH);

      if D1 <> 0.0 then
      begin
        Radians1 := ArcSin( Abs(AHeight) / D1 );
        Angle1   := RadToDeg(Radians1);
      end
      else Angle1 := 0.0;

      if D2 <> 0.0 then
      begin
        Radians2 := ArcSin( Abs(TempH) / D2 );
        Angle2   := RadToDeg(Radians2);
      end
      else Angle2 := 0.0;
      
      // The two points are both in the first, second, third or forth quadrant.
      if ( (MeasurePolygon[0].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y <= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y <= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y <= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y <= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y >= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y >= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y >= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y >= MeasurePolygon[1].Y) )
      then Angle := Abs(Angle1 - Angle2)
      else
      { One point is in the first quadrant, and another is in the second quadrant,
        or, one point is in the third quadrant and another is in the forth quadrant. }
      if ( (MeasurePolygon[0].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y <= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y <= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y <= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y <= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y >= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y >= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y >= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y >= MeasurePolygon[1].Y) )
      then Angle := 180 - Angle1 - Angle2
      else
      { One point is in the second quadrant, and another is in the third quadrant,
        or, one point is in the first quadrant and another is in the forth quadrant. }
      if ( (MeasurePolygon[0].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y <= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y >= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y >= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y <= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y <= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y >= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y >= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y <= MeasurePolygon[1].Y) )
      then Angle := Angle2 + Angle1
      else
      { One point is in the first quadrant, and another is in the third quadrant,
        or, one point is in the second quadrant and another is in the forth quadrant. }
      if ( (MeasurePolygon[0].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y <= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y >= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y >= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y <= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y <= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y >= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y >= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y <= MeasurePolygon[1].Y) ) then
      begin
        MaxAngle := Max(Angle1, Angle2);
        MinAngle := Min(Angle1, Angle2);
        Angle    := 180 - MaxAngle + MinAngle;
      end;
    end;
  end;
end; 

procedure CalculateMeasureByCM(const MeasurePolygon: array of TPoint;
  const PixelsPerInch: Integer;
  var OriginalX, OriginalY, AWidth, AHeight, D1, D2, Angle: Extended;
  const OffsetVector: TPoint);
var
  TempW, TempH      : Extended;
  Radians1, Radians2: Extended;
  Angle1, Angle2    : Extended;
  MaxAngle, MinAngle: Extended;
begin
  if ( High(MeasurePolygon) > 0 ) then
  begin
    OriginalX := (MeasurePolygon[0].X + OffsetVector.X) / PixelsPerInch * 2.54;
    OriginalY := (MeasurePolygon[0].Y + OffsetVector.Y) / PixelsPerInch * 2.54;

    if ( High(MeasurePolygon) = 1 ) then
    begin
      AWidth  := (MeasurePolygon[1].X - MeasurePolygon[0].X) / PixelsPerInch * 2.54;
      AHeight := (MeasurePolygon[1].Y - MeasurePolygon[0].Y) / PixelsPerInch * 2.54;
      D1      := Sqrt(AWidth * AWidth + AHeight * AHeight);

      // The second point is in the first quadrant.
      if  (MeasurePolygon[1].X >= MeasurePolygon[0].X)
      and (MeasurePolygon[1].Y <= MeasurePolygon[0].Y) then
      begin
        if D1 <> 0.0 then
        begin
          Radians1 := ArcSin( Abs(AHeight) / D1 );
          Angle    := RadToDeg(Radians1);
        end
        else Angle := 0.0;
      end
      else
      // The second point is in the second quadrant.
      if  (MeasurePolygon[1].X <= MeasurePolygon[0].X)
      and (MeasurePolygon[1].Y <= MeasurePolygon[0].Y) then
      begin
        if D1 <> 0.0 then
        begin
          Radians1 := ArcSin( Abs(AHeight) / D1 );
          Angle    := 180 - RadToDeg(Radians1);
        end
        else Angle := 0.0;
      end
      else
      // The second point is in the third quadrant.
      if  (MeasurePolygon[1].X <= MeasurePolygon[0].X)
      and (MeasurePolygon[1].Y >= MeasurePolygon[0].Y) then
      begin
        if D1 <> 0.0 then
        begin
          Radians1 := ArcSin( Abs(AHeight) / D1 );
          Angle    := 0 - ( 180 - RadToDeg(Radians1) );
        end
        else Angle := 0.0;
      end
      else
      // The second point is in the forth quadrant.
      if  (MeasurePolygon[1].X >= MeasurePolygon[0].X)
      and (MeasurePolygon[1].Y >= MeasurePolygon[0].Y) then
      begin
        if D1 <> 0.0 then
        begin
          Radians1 := ArcSin( Abs(AHeight) / D1 );
          Angle    := 0 - RadToDeg(Radians1);
        end
        else Angle := 0.0;
      end;
    end
    else
    if ( High(MeasurePolygon) = 2 ) then
    begin
      AWidth  := (MeasurePolygon[1].X - MeasurePolygon[0].X) / PixelsPerInch * 2.54;
      AHeight := (MeasurePolygon[1].Y - MeasurePolygon[0].Y) / PixelsPerInch * 2.54;
      D1      := Sqrt(AWidth * AWidth + AHeight * AHeight);
      TempW   := (MeasurePolygon[2].X - MeasurePolygon[1].X) / PixelsPerInch * 2.54;
      TempH   := (MeasurePolygon[2].Y - MeasurePolygon[1].Y) / PixelsPerInch * 2.54;
      D2      := Sqrt(TempW * TempW + TempH * TempH);

      if D1 <> 0.0 then
      begin
        Radians1 := ArcSin( Abs(AHeight) / D1 );
        Angle1   := RadToDeg(Radians1);
      end
      else Angle1 := 0.0;

      if D2 <> 0.0 then
      begin
        Radians2 := ArcSin( Abs(TempH) / D2 );
        Angle2   := RadToDeg(Radians2);
      end
      else Angle2 := 0.0;
      
      // The two points are both in the first, second, third or forth quadrant.
      if ( (MeasurePolygon[0].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y <= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y <= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y <= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y <= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y >= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y >= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y >= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y >= MeasurePolygon[1].Y) )
      then Angle := Abs(Angle1 - Angle2)
      else
      { One point is in the first quadrant, and another is in the second quadrant,
        or, one point is in the third quadrant and another is in the forth quadrant. }
      if ( (MeasurePolygon[0].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y <= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y <= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y <= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y <= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y >= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y >= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y >= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y >= MeasurePolygon[1].Y) )
      then Angle := 180 - Angle1 - Angle2
      else
      { One point is in the second quadrant, and another is in the third quadrant,
        or, one point is in the first quadrant and another is in the forth quadrant. }
      if ( (MeasurePolygon[0].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y <= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y >= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y >= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y <= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y <= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y >= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y >= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y <= MeasurePolygon[1].Y) )
      then Angle := Angle2 + Angle1
      else
      { One point is in the first quadrant, and another is in the third quadrant,
        or, one point is in the second quadrant and another is in the forth quadrant. }
      if ( (MeasurePolygon[0].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y <= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y >= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y >= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y <= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y <= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y >= MeasurePolygon[1].Y) )
      or ( (MeasurePolygon[0].X >= MeasurePolygon[1].X) and
           (MeasurePolygon[0].Y >= MeasurePolygon[1].Y) and
           (MeasurePolygon[2].X <= MeasurePolygon[1].X) and
           (MeasurePolygon[2].Y <= MeasurePolygon[1].Y) ) then
      begin
        MaxAngle := Max(Angle1, Angle2);
        MinAngle := Min(Angle1, Angle2);
        Angle    := 180 - MaxAngle + MinAngle;
      end;
    end;
  end;
end;

//-- TgmMeasureLine ------------------------------------------------------------

function TgmMeasureLine.GetMeasurePointCount: Integer;
begin
  Result := High(FMeasurePoints) + 1;
end;

procedure TgmMeasureLine.DrawHandles(const ACanvas: TCanvas;
  const APenMode: TPenMode);
var
  LTempPenColor             : TColor;
  LTempBrushColor           : TColor;
  LTempPenWidth             : Integer;
  LTempPenStyle             : TPenStyle;
  LTempPenMode              : TPenMode;
  LTempBrushStyle           : TBrushStyle;
  LSpiderPt1, LSpiderPt2    : TPoint;
  LEllipseStart, LEllipseEnd: TPoint;
  LMeasurePointCount        : Integer;
begin
  with ACanvas do
  begin
    GetCanvasProperties(ACanvas, LTempPenColor, LTempBrushColor, LTempPenWidth,
                        LTempPenStyle, LTempPenMode, LTempBrushStyle);

    Pen.Style   := psSolid;
    Pen.Width   := 1;
    Pen.Mode    := APenMode;
    Brush.Style := bsClear;

    LMeasurePointCount := High(FMeasurePoints) + 1;
    
    if LMeasurePointCount = 2 then
    begin
      LSpiderPt1 := FMeasurePoints[0];
      LSpiderPt2 := FMeasurePoints[1];

      DrawSpider(ACanvas, LSpiderPt1, HANDLE_RADIUS, clRed, pmNotXor);    // draw first handle
      DrawSpider(ACanvas, LSpiderPt2, HANDLE_RADIUS, clGreen, pmNotXor);  // draw second handle
    end
    else
    if LMeasurePointCount = 3 then
    begin
      LSpiderPt1 := FMeasurePoints[0];
      LSpiderPt2 := FMeasurePoints[2];

      LEllipseStart.X := FMeasurePoints[1].X - HANDLE_RADIUS + 1;
      LEllipseStart.Y := FMeasurePoints[1].Y - HANDLE_RADIUS + 1;
      LEllipseEnd.X   := FMeasurePoints[1].X + HANDLE_RADIUS;
      LEllipseEnd.Y   := FMeasurePoints[1].Y + HANDLE_RADIUS;

      // draw first handle
      DrawSpider(ACanvas, LSpiderPt1, HANDLE_RADIUS, clRed, pmNotXor);

      // draw second handle
      Pen.Color := clBlue;
      Ellipse(LEllipseStart.X, LEllipseStart.Y, LEllipseEnd.X, LEllipseEnd.Y);

      // draw third handle
      DrawSpider(ACanvas, LSpiderPt2, HANDLE_RADIUS, clGreen, pmNotXor);
    end;

    SetCanvasProperties(ACanvas, LTempPenColor, LTempBrushColor, LTempPenWidth,
                        LTempPenStyle, LTempPenMode, LTempBrushStyle);
  end;
end; 

constructor TgmMeasureLine.Create(const AOffsetVector: TPoint);
begin
  inherited Create;

  // Create two measure points in initialization.
  SetLength(FMeasurePoints, 2);

{ Calculation }
  FOriginalIntX := 0;
  FOriginalIntY := 0;
  FIntWidth     := 0;
  FIntHeight    := 0;
  FIntDistance1 := 0;
  FIntDistance2 := 0;

  FOriginalFloatX := 0;
  FOriginalFloatY := 0;
  FFloatWidth     := 0;
  FFloatHeight    := 0;
  FFloatDistance1 := 0;
  FFloatDistance2 := 0;

  FMeasureAngle := 0;
  FOffsetVector := AOffsetVector;
end; 

destructor TgmMeasureLine.Destroy;
begin
  SetLength(FMeasurePoints, 0);
  inherited Destroy;
end;

procedure TgmMeasureLine.SetMeasurePoint(const AX, AY: Integer;
  const AMeasurePointSelector: TgmMeasurePointSelector);
begin
  case AMeasurePointSelector of
    mpsFirst:
      begin
        if High(FMeasurePoints) > -1 then
        begin
          FMeasurePoints[0] := Point(AX, AY);
        end;
      end;

    mpsSecond:
      begin
        if High(FMeasurePoints) > 0 then
        begin
          FMeasurePoints[1] := Point(AX, AY);
        end;
      end;
      
    mpsThird:
      begin
        if High(FMeasurePoints) = 2 then
        begin
          FMeasurePoints[2] := Point(AX, AY);
        end;
      end;
  end;
end;

procedure TgmMeasureLine.AddThirdMeasurePoint(const AX, AY: Integer);
begin
  if High(FMeasurePoints) = 1 then
  begin
    SetLength(FMeasurePoints, 3);
    FMeasurePoints[2] := Point(AX, AY);
  end;
end; 

procedure TgmMeasureLine.Translate(const ATranslateVector: TPoint);
var
  i: Integer;
begin
  if High(FMeasurePoints) >= 1 then
  begin
    for i := Low(FMeasurePoints) to High(FMeasurePoints) do
    begin
      FMeasurePoints[i] := AddPoints(FMeasurePoints[i], ATranslateVector);
    end;
  end;
end;

procedure TgmMeasureLine.SwapFirstAndSecondMeasurePoint;
var
  LSwapPoint: TPoint;
begin
  if High(FMeasurePoints) = 1 then
  begin
    LSwapPoint        := FMeasurePoints[0];
    FMeasurePoints[0] := FMeasurePoints[1];
    FMeasurePoints[1] := LSwapPoint;
  end;
end; 

// Check whether the mouse is over one of the Measure points.
function TgmMeasureLine.GetHandleAtPoint(
  const AX, AY: Integer): TgmMeasurePointSelector;
var
  LMeasurePointCount: Integer;
begin
  Result             := mpsNone;
  LMeasurePointCount := High(FMeasurePoints) + 1;

  if LMeasurePointCount >= 2 then
  begin
    if SquareContainsPoint( FMeasurePoints[0], HANDLE_RADIUS, Point(AX, AY) ) then
    begin
      Result := mpsFirst;
    end
    else
    if SquareContainsPoint( FMeasurePoints[1], HANDLE_RADIUS, Point(AX, AY) ) then
    begin
      Result := mpsSecond;
    end
    else
    begin
      if LMeasurePointCount = 3 then
      begin
        if SquareContainsPoint( FMeasurePoints[2], HANDLE_RADIUS, Point(AX, AY) ) then
        begin
          Result := mpsThird;
        end;
      end;
    end;
  end;
end; 

// Check whether the mouse is over the Measure line.
function TgmMeasureLine.ContainsPoint(const AX, AY: Integer):  Boolean;
var
  I: Integer;
begin
  Result := False;

  if High(FMeasurePoints) > -1 then
  begin
    for I := Low(FMeasurePoints) to High(FMeasurePoints) - 1 do
    begin
      if NearLine( Point(AX, AY), FMeasurePoints[I], FMeasurePoints[I + 1]) then
      begin
        Result := True;
        Break;
      end;
    end;
  end;
end;

procedure TgmMeasureLine.Draw(const ACanvas: TCanvas; const APenMode: TPenMode);
const
  LINE_COLOR1: TColor = $323232; // RGB: 50, 50, 50    -- The color of measure line 1.
  LINE_COLOR2: TColor = $969696; // RGB: 150, 150, 150 -- The color of measure line 2.
var
  LTempPenColor         : TColor;
  LTempPenWidth         : Integer;
  LTempPenStyle         : TPenStyle;
  LTempPenMode          : TPenMode;
  LLineStartP, LLineEndP: TPoint;
  LMeasurePointCount    : Integer;
begin
  with ACanvas do
  begin
    // Copy the original properties of the Canvas.Pen .
    LTempPenColor := Pen.Color;
    LTempPenWidth := Pen.Width;
    LTempPenStyle := Pen.Style;
    LTempPenMode  := Pen.Mode;

    // Change the propertis of the Canvas.Pen .
    Pen.Style := psSolid;
    Pen.Width := 1;
    Pen.Mode  := APenMode;

    LMeasurePointCount := High(FMeasurePoints) + 1;

    // Draw measure lines.
    if LMeasurePointCount >= 2 then
    begin
      // Draw first measure line.
      Pen.Color   := LINE_COLOR1;
      LLineStartP := FMeasurePoints[0];
      LLineEndP   := FMeasurePoints[1];

      MoveTo(LLineStartP.X, LLineStartP.Y);
      LineTo(LLineEndP.X, LLineEndP.Y);

      // Draw second measure line.
      if LMeasurePointCount = 3 then
      begin
        Pen.Color   := LINE_COLOR2;
        LLineStartP := FMeasurePoints[1];
        LLineEndP   := FMeasurePoints[2];
        
        MoveTo(LLineStartP.X, LLineStartP.Y);
        LineTo(LLineEndP.X,   LLineEndP.Y);
      end;
    end;

    // Restore the properties of the Canvas.Pen .
    Pen.Color := LTempPenColor;
    Pen.Width := LTempPenWidth;
    Pen.Style := LTempPenStyle;
    Pen.Mode  := LTempPenMode;
  end;
  
  // Draw handles
  DrawHandles(ACanvas, APenMode);
end; 

// Calculate the measure result.
procedure TgmMeasureLine.Calculate(const AUnit: TgmMeasureUnit;
  const APixelsPerInch: Integer);
begin
  case AUnit of
    muPixel:
      begin
        CalculateMeasureByPixels(FMeasurePoints, FOriginalIntX, FOriginalIntY,
                                 FIntWidth, FIntHeight, FIntDistance1,
                                 FIntDistance2, FMeasureAngle, FOffsetVector);
      end;

    muInch:
      begin
        CalculateMeasureByInches(FMeasurePoints, APixelsPerInch,
                                 FOriginalFloatX, FOriginalFloatY, FFloatWidth,
                                 FFloatHeight, FFloatDistance1, FFloatDistance2,
                                 FMeasureAngle, FOffsetVector);
      end;
                                      
    muCM:
      begin
        CalculateMeasureByCM(FMeasurePoints, APixelsPerInch,
                             FOriginalFloatX, FOriginalFloatY, FFloatWidth,
                             FFloatHeight, FFloatDistance1, FFloatDistance2,
                             FMeasureAngle, FOffsetVector);
      end;
  end;
end; 

end.
