{ Based on:

  ImageProcessingPrimitives.pas  (in ShowImage demo)
  ColorLibrary.pas               (in ShowImage demo)

  from http://www.efg2.com/
  Special thanks to Earl F. Glynn
}

unit gmColorSpace;

{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_CAST OFF}

interface

uses
  GR32;

//-- Color Conversions ---------------------------------------------------------

  // HLS
  function  HLSToRGB32(const A, H, L, S: Integer): TColor32;
  procedure RGBToHLS32(const ARGB: TColor32; var H, L, S: Integer);

  // HSV
  function  HSVToRGB32(const A, H, S, V: Integer): TColor32;
  procedure RGBToHSV32(const ARGB: TColor32; var H, S, V: Integer);

  // CMY
  function  CMYToColor32(const C, M, Y: Integer; const A: Byte = 255): TColor32;
  procedure Color32ToCMY(const AColor: TColor32; var C, M, Y: Integer); // c, m and y IN [0..255]

  // CMYK
  function  CMYKToColor32(const C, M, Y, K: Integer; const A: Byte = 255): TColor32;
  procedure Color32ToCMYK(const AColor: TColor32; var C, M, Y, K: Integer);

//------------------------------------------------------------------------------

  // TColor32 Brightness:  Intensity, Lightness, Value, Y; Saturation
  function RGBToLightness32(const ARGB: TColor32): Integer;

  // idea by Tommi Prami
  procedure ChangeColor(ABitmap: TBitmap32; const ASrcColor, ADestColor: TColor32;
    const AReplaceAlpha: Boolean = False);

implementation

uses
  Windows,
  Math,                        // MaxIntValue(), MaxValue()
  IEEE754,                     // NAN (not a number)
  RealColorLibrary,            // HLStoRGB()
  GR32_LowLevel;               // Clamp()

type
  TReal = Single;

//-- Color Conversions ---------------------------------------------------------

// -- HLS / RGB ----------------------------------------------------------------
//
// Based on C Code in "Computer Graphics -- Principles and Practice,"
// Foley et al, 1996, p. 596.
function  HLSToRGB32(const A, H, L, S: Integer): TColor32;
var
  R, G, B         : TReal;
  NewR, NewG, NewB: Byte;
begin
  HLSToRGB(H, L / 255, S / 255, R, G, B);

  NewR   := Clamp( Round(R * 255), 0, 255 );
  NewG   := Clamp( Round(G * 255), 0, 255 );
  NewB   := Clamp( Round(B * 255), 0, 255 );
  Result := Color32(NewR, NewG, NewB, A);
end;

// RGB to HLS
// H = 0 to 360 (corresponding to 0..360 degrees around hexcone)
// L = 0 (shade of gray) to 255 (pure color)
// S = 0 (black) to 255 {white)
//
// R, G, B each in [0, 255]
procedure RGBToHLS32(const ARGB: TColor32; var H, L, S: Integer);
var
  Hue, Lightness, Saturation: TReal;
  R, G, B                   : Byte;
begin
  R := ARGB shr 16 and $FF;
  G := ARGB shr 8  and $FF;
  B := ARGB        and $FF;

  RGBToHLS(R / 255, G / 255, B / 255, Hue, Lightness, Saturation);

  if IsNan(Hue) then
  begin
    H := 0;
  end
  else
  begin
    H := Round(Hue); // 0..360
  end;

  L := Round(255 * Lightness);    // 0..255
  S := Round(255 * Saturation);   // 0..255
end;

//-- HSV -----------------------------------------------------------------------

// Floating point fractions, 0..1, replaced with integer values, 0..255.
// Use integer conversion ONLY for one-way, or a single final conversions.
// Use floating-point for converting reversibly (see HSVtoRGB above).
//
// H = 0 to 360 (corresponding to 0..360 degrees around hexcone)
//     0 (undefined) for S = 0
// S = 0 (shade of gray) to 255 (pure color)
// V = 0 (black) to 255 (white)
function HSVToRGB32(const A, H, S, V: Integer): TColor32;
const
  Divisor: Integer = 255 * 60;
var
  f, hTemp, p, q, t, VS: Integer;
begin
  if S = 0 then
  begin
    Result := Color32(V, V, V, A)  // achromatic:  shades of gray
  end
  else
  begin                            // chromatic color
    if H = 360 then
    begin
      hTemp := 0;
    end
    else
    begin
      hTemp := H;
    end;

    f     := hTemp mod 60;     // f is IN [0, 59]
    hTemp := hTemp div 60;     // h is now IN [0,6)

    VS := V * S;
    p  := V - VS div 255;                   // p = v * (1 - s)
    q  := V - (VS * f) div Divisor;         // q = v * (1 - s * f)
    t  := V - (VS * (60 - f)) div Divisor;  // t = v * (1 - s * (1 - f))

    case hTemp of
      0:
        begin
          Result := Color32(V, t, p, A);
        end;

      1:
        begin
          Result := Color32(q, V, p, A);
        end;

      2:
        begin
          Result := Color32(p, V, t, A);
        end;
        
      3:
        begin
          Result := Color32(p, q, V, A);
        end;

      4:
        begin
          Result := Color32(t, p, V, A);
        end;

      5:
        begin
          Result := Color32(V, p, q, A);
        end;

    else
      Result := Color32(0, 0, 0, A)        // should never happen;
                                           // avoid compiler warning
    end;
  end;
end;

// RGB, each 0 to 255, to HSV.
// H = 0 to 360 (corresponding to 0..360 degrees around hexcone)
// S = 0 (shade of gray) to 255 (pure color)
// V = 0 (black) to 255 {white)

// Based on C Code in "Computer Graphics -- Principles and Practice,"
// Foley et al, 1996, p. 592.  Floating point fractions, 0..1, replaced with
// integer values, 0..255.

procedure RGBToHSV32(const ARGB: TColor32;    {r, g and b IN [0..255]}
                     var   H, S, V: Integer); {h IN 0..359; s,v IN 0..255}
var
  Delta, Min, R, G, B: Integer;
begin
  R := ARGB shr 16 and $FF;
  G := ARGB shr 8  and $FF;
  B := ARGB        and $FF;

  Min := MinIntValue([R, G, B]);
  V   := MaxIntValue([R, G, B]);

  Delta := V - Min;
  
  // Calculate saturation:  saturation is 0 if r, g and b are all 0
  if V =  0 then
  begin
    S := 0;
  end
  else
  begin
    S := MulDiv(Delta, 255, V);
  end;

  if S  = 0 then
  begin
    H := 0; // Achromatic:  When s = 0, h is undefined but assigned the value 0
  end
  else
  begin    // Chromatic
    if R = V then
    begin
      H := MulDiv(G - B, 60, Delta); // degrees -- between yellow and magenta
    end
    else if G = V then
    begin
      H := 120 + MulDiv(B - R, 60, Delta); // between cyan and yellow
    end
    else if B = V then
    begin
      H := 240 + MulDiv(R - G, 60, Delta); // between magenta and cyan
    end;

    if H < 0 then
    begin
      H := H + 360;
    end;
  end;
end;

//-- CMY / RGB -----------------------------------------------------------------
//
// Based on C Code in "Computer Graphics -- Principles and Practice,"
// Foley et al, 1996, p. 588


// R, G, B, C, M, Y each IN [0..255]
function CMYToColor32(const C, M, Y: Integer; const A: Byte): TColor32;
var
  R, G, B: Byte;
begin
  R := 255 - C;
  G := 255 - M;
  B := 255 - Y;

  Result := (A shl 24) or (R shl 16) or (G shl 8) or B;
end;

// R, G, B, C, M, Y each IN [0..255]
procedure Color32ToCMY(const AColor: TColor32; var C, M, Y: Integer);
var
  R, G, B: Integer;
begin
  R := AColor shr 16 and $FF;
  G := AColor shr  8 and $FF;
  B := AColor        and $FF;

  C := 255 - R;
  M := 255 - G;
  Y := 255 - B;
end;

//-- CMYK / RGB ----------------------------------------------------------------
//
// Based on C Code in "Computer Graphics -- Principles and Practice,"
// Foley et al, 1996, p. 589


// R, G, B, C, M, Y,K each IN [0..255]
function CMYKToColor32(const C, M, Y, K: Integer; const A: Byte = 255): TColor32;
var
  R, G, B   : Byte;
  RR, GG, BB: Integer;
begin
  RR := 255 - (C + K);
  GG := 255 - (M + K);
  BB := 255 - (Y + K);

  R := Clamp(RR, 0, 255);
  G := Clamp(GG, 0, 255);
  B := Clamp(BB, 0, 255);

  Result := (A shl 24) or (R shl 16) or (G shl 8) or B;
end;

// R, G, B, C, M, Y each IN [0..255]
procedure Color32ToCMYK(const AColor: TColor32; var C, M, Y, K: Integer);
begin
  Color32ToCMY(AColor, C, M, Y);

  K := MinIntValue([C, M, Y]);
  C := C - K;
  M := M - K;
  Y := Y - K;

  C := Clamp(C, 0, 255);
  M := Clamp(M, 0, 255);
  Y := Clamp(Y, 0, 255);
end;

//------------------------------------------------------------------------------

// TColor32 Brightness:  Intensity, Lightness, Value, Y; Saturation
// See [Foley96, p. 595]
function RGBToLightness32(const ARGB: TColor32): Integer;
var
  R, G, B: Integer;
begin
  // Use DIV here since histogram looks "odd" when IEEE rounding is used.
  R      := ARGB shr 16 and $FF;
  G      := ARGB shr 8  and $FF;
  B      := ARGB        and $FF;
  Result := ( MinIntValue([R, G, B]) + MaxIntValue([R, G, B]) ) div 2;
end;

// idea by Tommi Prami
procedure ChangeColor(ABitmap: TBitmap32; const ASrcColor, ADestColor: TColor32;
  const AReplaceAlpha: Boolean = False);
var
  i: Integer;
  p: PColor32;
begin
  if Assigned(ABitmap) then
  begin
    if (ABitmap.Width  = 0) or (ABitmap.Height = 0) then
    begin
      Exit;
    end;
    
    p := @ABitmap.Bits[0];

    if AReplaceAlpha then
    begin
      for i := 0 to (ABitmap.Width * ABitmap.Height - 1) do
      begin
        if p^ = ASrcColor then
        begin
          p^ := ADestColor;
        end;
       
        Inc(p);
      end;
    end
    else
    begin
      for i := 0 to (ABitmap.Width * ABitmap.Height - 1) do
      begin
        if (p^ and $00FFFFFF) = (ASrcColor and $00FFFFFF) then
        begin
          p^ := (p^ and $FF000000) or (ADestColor and $00FFFFFF);
        end;
       
        Inc(p);
      end;
    end;
  end;
end; 

end.
