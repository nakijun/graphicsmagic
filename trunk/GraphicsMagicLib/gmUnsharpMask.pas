{
  Original authors:
    Ma Xiaoguang, Ma Xiaoming

  CopyRight(C) Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved.
  
  Reference materials:
    http://www.dougkerr.net/pumpkin/articles/Unsharp_Mask.pdf

  Date:
    2010-12-22 }

unit gmUnsharpMask;

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
  GR32, GR32_LowLevel;

type
  TgmUnsharpMask = class(TObject)
  private
    FSourceBitmap : TBitmap32;  // pointer to a bitmap
    FBlurredBitmap: TBitmap32;
    FAmount       : Double;
    FRadius       : Double;
    FThreshold    : Integer;

    procedure SetAmount(const AValue: Double);
    procedure SetRadius(const AValue: Double);
    procedure SetThreshold(const AValue: Integer);
  public
    constructor Create(const ASourceBmp: TBitmap32);
    destructor Destroy; override;

    procedure SetSourceBitmap(const ASourceBmp: TBitmap32);
    procedure Execute(const ADestBmp: TBitmap32);

    property Amount   : Double  read FAmount    write SetAmount;
    property Radius   : Double  read FRadius    write SetRadius;
    property Threshold: Integer read FThreshold write SetThreshold;
  end;

  procedure UnsharpMask(const ADestBmp: TBitmap32;
    const AAmount, ARadius: Double; const AThreshold: Cardinal);

    
implementation

uses
  Math, gmGaussianBlur;

const
  MIN_AMOUNT = 0.01;
  MAX_AMOUNT = 5.00;
  MIN_RADIUS = 0.1;
  MAX_RADIUS = 250.0;

procedure UnsharpMask(const ADestBmp: TBitmap32; const AAmount, ARadius: Double;
  const AThreshold: Cardinal);
var
  LBlurredBmp : TBitmap32;
  LAmount     : Double;
  LRadius     : Double;
  LThreshold  : Integer;
  i           : Integer;
  mr, mg, mb  : Integer;
  br, bg, bb  : Byte;
  dr, dg, db  : Byte;
  LMaskLight  : Integer;
  LDestBit    : PColor32;
  LBlurBit    : PColor32;
begin
  if not Assigned(ADestBmp) then
  begin
    Exit;
  end;

  if (ADestBmp.Width = 0) or (ADestBmp.Height = 0) then
  begin
    Exit;
  end;

  LAmount     := AAmount;
  LRadius     := ARadius;
  LThreshold  := Clamp(AThreshold);

  if LAmount < MIN_AMOUNT then
  begin
    LAmount := MIN_AMOUNT;
  end
  else if LAmount > MAX_AMOUNT then
  begin
    LAmount := MAX_AMOUNT;
  end;

  if LRadius < MIN_RADIUS then
  begin
    LRadius := MIN_RADIUS;
  end
  else if LRadius > MAX_RADIUS then
  begin
    LRadius := MAX_RADIUS;
  end;

  LBlurredBmp := TBitmap32.Create;
  try
    LBlurredBmp.Assign(ADestBmp);
    GBlur32(LBlurredBmp, LRadius);

    LDestBit := @ADestBmp.Bits[0];
    LBlurBit := @LBlurredBmp.Bits[0];
    for i := 0 to ADestBmp.Width * ADestBmp.Height - 1 do
    begin
      br := LBlurBit^ shr 16 and $FF;
      bg := LBlurBit^ shr  8 and $FF;
      bb := LBlurBit^        and $FF;

      dr := LDestBit^ shr 16 and $FF;
      dg := LDestBit^ shr  8 and $FF;
      db := LDestBit^        and $FF;

      mr := dr - br;
      mg := dg - bg;
      mb := db - bb;

      mr := Round(mr * LAmount);
      mg := Round(mg * LAmount);
      mb := Round(mb * LAmount);

      LMaskLight := ( Abs(mr) + Abs(mg) + Abs(mb) ) div 3;

      if LMaskLight >= LThreshold then
      begin
        if mr > 0 then
        begin
          mr := mr - LThreshold;

          if mr < 0 then
          begin
            mr := 0;
          end;
        end
        else
        if mr < 0 then
        begin
          mr := mr + LThreshold;

          if mr > 0 then
          begin
            mr := 0;
          end;
        end;

        if mg > 0 then
        begin
          mg := mg - LThreshold;

          if mg < 0 then
          begin
            mg := 0;
          end;
        end
        else
        if mg < 0 then
        begin
          mg := mg + LThreshold;

          if mg > 0 then
          begin
            mg := 0;
          end;
        end;

        if mb > 0 then
        begin
          mb := mb - LThreshold;

          if mb < 0 then
          begin
            mb := 0;
          end;
        end
        else
        if mb < 0 then
        begin
          mb := mb + LThreshold;
          
          if mb > 0 then
          begin
            mb := 0;
          end;
        end;

        mr := dr + mr;
        mg := dg + mg;
        mb := db + mb;

        dr := Clamp(mr, 0, 255);
        dg := Clamp(mg, 0, 255);
        db := Clamp(mb, 0, 255);

        LDestBit^ := (LDestBit^ and $FF000000) or (dr shl 16) or (dg shl 8) or db;
      end;

      Inc(LDestBit);
      Inc(LBlurBit);
    end;
  finally
    LBlurredBmp.Free;
  end;
end; 

//-- TgmUnsharpMask ------------------------------------------------------------
{ TgmUnsharpMask }

constructor TgmUnsharpMask.Create(const ASourceBmp: TBitmap32);
begin
  inherited Create;

  FSourceBitmap  := ASourceBmp;
  FBlurredBitmap := nil;

  FAmount    := 50.0;
  FRadius    := 1.0;
  FThreshold := 0;

  if Assigned(FSourceBitmap) then
  begin
    FBlurredBitmap := TBitmap32.Create;
    FBlurredBitmap.Assign(FSourceBitmap);
    
    GBlur32(FBlurredBitmap, FRadius);
  end;
end;

destructor TgmUnsharpMask.Destroy;
begin
  FSourceBitmap := nil;
  FBlurredBitmap.Free;
  
  inherited Destroy;
end;

procedure TgmUnsharpMask.SetAmount(const AValue: Double);
begin
  if AValue < MIN_AMOUNT then
  begin
    FAmount := MIN_AMOUNT;
  end
  else if AValue > MAX_AMOUNT then
  begin
    FAmount := MAX_AMOUNT;
  end
  else
  begin
    FAmount := AValue;
  end;
end;

procedure TgmUnsharpMask.SetRadius(const AValue: Double);
begin
  if AValue < MIN_RADIUS then
  begin
    FRadius := MIN_RADIUS;
  end
  else if AValue > MAX_RADIUS then
  begin
    FRadius := MAX_RADIUS;
  end
  else
  begin
    FRadius := AValue;
  end;

  if Assigned(FSourceBitmap) and Assigned(FBlurredBitmap) then
  begin
    FBlurredBitmap.Assign(FSourceBitmap);
    GBlur32(FBlurredBitmap, FRadius);
  end;
end;

procedure TgmUnsharpMask.SetSourceBitmap(const ASourceBmp: TBitmap32);
begin
  if Assigned(ASourceBmp) then
  begin
    FSourceBitmap := ASourceBmp;

    if Assigned(FSourceBitmap) then
    begin
      if not Assigned(FBlurredBitmap) then
      begin
        FBlurredBitmap := TBitmap32.Create;
      end;

      FBlurredBitmap.Assign(FSourceBitmap);
      GBlur32(FBlurredBitmap, FRadius);
    end;
  end;
end;

procedure TgmUnsharpMask.Execute(const ADestBmp: TBitmap32);
var
  i         : Integer;
  mr, mg, mb: Integer;
  br, bg, bb: Byte;
  dr, dg, db: Byte;
  LMaskLight: Integer;
  LDestBit  : PColor32;
  LBlurBit  : PColor32;
begin
  if not Assigned(ADestBmp) then
  begin
    Exit;
  end;

  if not Assigned(FSourceBitmap) then
  begin
    Exit;
  end;

  if not Assigned(FBlurredBitmap) then
  begin
    Exit;
  end;

  ADestBmp.Assign(FSourceBitmap);

  LDestBit := @ADestBmp.Bits[0];
  LBlurBit := @FBlurredBitmap.Bits[0];

  for i := 0 to (ADestBmp.Width * ADestBmp.Height - 1) do
  begin
    br := LBlurBit^ shr 16 and $FF;
    bg := LBlurBit^ shr  8 and $FF;
    bb := LBlurBit^        and $FF;

    dr := LDestBit^ shr 16 and $FF;
    dg := LDestBit^ shr  8 and $FF;
    db := LDestBit^        and $FF;

    mr := dr - br;
    mg := dg - bg;
    mb := db - bb;

    LMaskLight := ( Abs(mr) + Abs(mg) + Abs(mb) ) div 3;

    if LMaskLight >= FThreshold then
    begin
      if mr > 0 then
      begin
        mr := mr - FThreshold;

        if mr < 0 then
        begin
          mr := 0;
        end;
      end
      else
      if mr < 0 then
      begin
        mr := mr + FThreshold;

        if mr > 0 then
        begin
          mr := 0;
        end;
      end;

      if mg > 0 then
      begin
        mg := mg - FThreshold;

        if mg < 0 then
        begin
          mg := 0;
        end;
      end
      else
      if mg < 0 then
      begin
        mg := mg + FThreshold;

        if mg > 0 then
        begin
          mg := 0;
        end;
      end;

      if mb > 0 then
      begin
        mb := mb - FThreshold;

        if mb < 0 then
        begin
          mb := 0;
        end;
      end
      else
      if mb < 0 then
      begin
        mb := mb + FThreshold;
        
        if mb > 0 then
        begin
          mb := 0;
        end;
      end;

      mr := dr + mr;
      mg := dg + mg;
      mb := db + mb;

      dr := Clamp(mr, 0, 255);
      dg := Clamp(mg, 0, 255);
      db := Clamp(mb, 0, 255);

      LDestBit^ := (LDestBit^ and $FF000000) or (dr shl 16) or (dg shl 8) or db;
    end;

    Inc(LDestBit);
    Inc(LBlurBit);
  end;
end;

procedure TgmUnsharpMask.SetThreshold(const AValue: Integer);
begin
  FThreshold := Clamp(AValue);
end;    

end.
