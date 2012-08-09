{ The GraphicsMagic -- an image manipulation program
  CopyRight(C) 2001-, Ma Xiaoguang & Ma Xiaoming < gmbros@hotmail.com >.
  All rights reserved.

  This unit including input/output processing for GraphicsMagic. }

unit gmIO;

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

{$I GraphicsMagicLib.inc}

uses
{$IFDEF USE_GIFImage}
  GIFImage,         // TGIFImage
  {$ENDIF}
  {$IFDEF USE_CG_GIFImg}
  GIFImg,          // CodeGear/Embaracadero GIF Library
  {$ENDIF}
  {$IFDEF USE_GR32_PNG}
  GR32_PNG,
  {$ENDIF}
  {$IFDEF USE_JPEG}
  JPEG,             // TJPEGImage;
  {$ENDIF}
  {$IFDEF USE_KRUG_TIFF}
  ReadTiff, Bmp2Tiff,
  {$ENDIF }
  SysUtils,         // FileExists (Last in Use so the idfef system works
  Graphics,         // TBitmap
  Classes,
{ Graphics32 }
  GR32, GR32_OrdinalMaps,
{ GraphicsMagic Lib }
  gmTypes;

type
  TgmChannelFileHeader = record
    Mark   : string[255];
    Channel: TgmChannelSelector;
    Width  : Integer;
    Height : Integer;
  end;

  function LoadChannelsFromFile(const ABitmap: TBitmap32;
    const AChannel: TgmChannelSelector; const AFileName: string): Boolean;

  function SaveChannelsToFile(const ABitmap: TBitmap32;
    const AChannel: TgmChannelSelector; const AFileName: string): Boolean;

//------------------------------------------------------------------------------

  { The following two routines found from : http://www.efg2.com
    The original code was in GraphicsConversionsLibrary.pas.

    We adapted the two routines for supporting TBitmap32.

    Quote to efg2:
    --------------
    Load various graphics formats (BMP, JPG, WMF, EMF, ICO, GIF) into a
    pf24bit TBitmap.  The use of a pf24bit TBitmap avoids any palette issues.

    For GIF support, Anders Melander's TGIFImage must be installed
    (find it at www.melander.dk/delphi/gifimage) and a "GIF" conditional
    must be defined prior to compilation.

    efg,  Sept 98.
   }
  function LoadGraphicsFile(const AFileName: string): TBitmap32;
  procedure SaveGraphicsFile(const AFileName: string; ABitmap: TBitmap32);


var
  GMIOErrorMsgOutput: string;

implementation

const
  CHANNEL_FILE_MARK  = 'GraphicsMagic Channel File';

// load channels from file and save them to specified channels of a given bitmap
function LoadChannelsFromFile(const ABitmap: TBitmap32;
  const AChannel: TgmChannelSelector; const AFileName: string): Boolean;
var
  LHeader: TgmChannelFileHeader;
  LStream: TMemoryStream;
  p      : PColor32;
  LColor : TColor32;
  i      : Integer;
  b      : Byte;
begin
  Result := False;
  LColor := clBlack32;

  if not Assigned(ABitmap) then
  begin
    Exit;
  end;

  if not FileExists(AFileName) then
  begin
    GMIOErrorMsgOutput := 'The file name is not exists.';
    Exit;
  end;

  LStream := TMemoryStream.Create;
  try
    LStream.LoadFromFile(AFileName);
    LStream.Position := 0;

    // read the header of file
    LStream.Read(LHeader, SizeOf(LHeader));

    if LHeader.Mark <> CHANNEL_FILE_MARK then
    begin
      GMIOErrorMsgOutput := 'GraphicsMagic cannot load this file.';
    end
    else
    begin
      if (ABitmap.Width  <> LHeader.Width) or
         (ABitmap.Height <> LHeader.Height) then
      begin
        GMIOErrorMsgOutput := 'The size of bitmap and channels is not matched';
      end
      else
      begin
        p := @ABitmap.Bits[0];

        for i := 0 to (ABitmap.Width * ABitmap.Height - 1) do
        begin
          LStream.Read(b, 1);

          case AChannel of
            csAlpha:
              begin
                LColor := (b shl 24) or (p^ and $FFFFFF);
              end;

            csRed:
              begin
                LColor := (p^ and $FF00FFFF) or (b shl 16);
              end;

            csGreen:
              begin
                LColor := (p^ and $FFFF00FF) or (b shl 8);
              end;

            csBlue:
              begin
                LColor := (p^ and $FFFFFF00) or b;
              end;

            csGrayscale:
              begin
                LColor := (p^ and $FF000000) or (b shl 16) or (b shl 8) or b;
              end;
          end;

          p^ := LColor;
          Inc(p);
        end;

        Result := True;
      end;
    end;
  finally
    LStream.Free;
  end;
end;

// save the specified channels of given bitmap to file
function SaveChannelsToFile(const ABitmap: TBitmap32;
  const AChannel: TgmChannelSelector; const AFileName: string): Boolean;
var
  LHeader: TgmChannelFileHeader;
  LStream: TMemoryStream;
  i      : Integer;
  b      : Byte;
  p      : PColor32;
begin
  Result := False;

  if not Assigned(ABitmap) then
  begin
    Exit;
  end;

  if (ABitmap.Width = 0) or (ABitmap.Height = 0) then
  begin
    Exit;
  end;

  LHeader.Mark    := CHANNEL_FILE_MARK;
  LHeader.Channel := AChannel;
  LHeader.Width   := ABitmap.Width;
  LHeader.Height  := ABitmap.Height;

  LStream := TMemoryStream.Create;
  try
    LStream.Position := 0;
    LStream.Write(LHeader, SizeOf(LHeader));

    p := @ABitmap.Bits[0];

    for i := 0 to (ABitmap.Width * ABitmap.Height - 1) do
    begin
      case AChannel of
        csAlpha:
          begin
            b := p^ shr 24 and $FF;
          end;

        csRed:
          begin
            b := p^ shr 16 and $FF;
          end;
          
        csGreen:
          begin
            b := p^ shr 8 and $FF;
          end;
          
        csBlue:
          begin
            b := p^ and $FF;
          end;
          
        csGrayscale:
          begin
            b := Intensity(p^);
          end;
      end;

      LStream.Write(b, 1);
      Inc(p);
    end;

    LStream.SaveToFile(AFileName);
    Result := True;
  finally
    LStream.Free;
  end;
end;

//-- Based on GraphicsConversionsLibrary.pas by written by efg2.com ------------

// Create TBitmap32 from BMP, JPG, WMF, EMF or GIF disk file.
// Could be easily extended to other image types.
function LoadGraphicsFile(const AFileName: string): TBitmap32;
var
  LExtension: string;
  {$IFDEF USE_JPEG}
  LJPEGImage: TJPEGImage;
  {$ENDIF}
  {$IFDEF USE_GIFImage}
  LGIFImage : TGIFImage;
  {$ENDIF}
  {$IFDEF USE_GR32_PNG}
  LPNGImage : TPortableNetworkGraphic32;
  {$ENDIF}
  LTempBmp  : TBitmap;
begin
  Result := nil;  // In case anything goes wrong

  if FileExists(AFileName) then
  begin
    LExtension := UpperCase( Copy(AFileName, Length(AFileName) - 2, 3) );

    // Quick and dirty check that file type is OK
    Assert( (LExtension = 'BMP') or
            (LExtension = 'JPG') or
            (LExtension = 'GIF') or
            (LExtension = 'PNG') or
            (LExtension = 'TIF') );

    Result := TBitmap32.Create;
    
    // BMP File -- no additional work to get TBitmap32
    if LExtension = 'BMP' then
    begin
      try
        Result.LoadFromFile(AFileName);
      except
        FreeAndNil(Result);
      end;
    end;

    {$IFDEF USE_JPEG}
    // JPG File
    if LExtension = 'JPG' then
    begin
      LJPEGImage := TJPEGImage.Create;
      LTempBmp   := TBitmap.Create;
      try
        try
          LJPEGImage.LoadFromFile(AFileName);
          LTempBmp.Height      := LJPEGImage.Height;
          LTempBmp.Width       := LJPEGImage.Width;
          LTempBmp.PixelFormat := pf24bit;
          LTempBmp.Canvas.Draw(0, 0, LJPEGImage);
          Result.Assign(LTempBmp);
        except
          FreeAndNil(Result);
        end;
      finally
        LTempBmp.Free;
        LJPEGImage.Free;
      end;
    end;
    {$ENDIF}

    {$IFDEF USE_GIFImage}
    // GIF File
    if LExtension = 'GIF' then
    begin
      LGIFImage := TGIFImage.Create;
      LTempBmp  := TBitmap.Create;
      try
        try
          LGIFImage.LoadFromFile(AFileName);

          if LGIFImage.Images.Count = 1 then
          begin
            LTempBmp.Height      := LGIFImage.Height;
            LTempBmp.Width       := LGIFImage.Width;
            LTempBmp.PixelFormat := pf24bit;
            LTempBmp.Canvas.Draw(0, 0, LGIFImage);
            Result.Assign(LTempBmp);
          end
          else
          begin
            FreeAndNil(Result);
          end;
        except
          FreeAndNil(Result);
        end;
      finally
        LTempBmp.Free;
        LGIFImage.Free;
      end;
    end;
    {$ENDIF}

    // PNG File
    if LExtension = 'PNG' then
    begin
      {$IFDEF USE_GR32_PNG}
      LPNGImage := TPortableNetworkGraphic32.Create;
      try
        try
          LPNGImage.LoadFromFile(AFileName);
          LPNGImage.AssignTo(Result);
        except
          FreeAndNil(Result);
        end;
      finally
        LPNGImage.Free;
      end;
      {$ENDIF}
    end;

    // TIFF File
    if LExtension = 'TIF' then
    begin
      {$IFDEF USE_KRUG_TIFF}
      LTempBmp := TBitmap.Create;
      try
        try
          LoadTiffFromFile(AFileName, LTempBmp);
          Result.Assign(LTempBmp);
        except
          FreeAndNil(Result);
        end;
      finally
        LTempBmp.Free;
      end;
      {$ENDIF}
    end;
  end;
end;

procedure SaveGraphicsFile(const AFileName: string; ABitmap: TBitmap32);
var
  LSaveBitmap: TBitmap;
  LExtension : string;
  {$IFDEF USE_JPEG}
  LJPEGImage : TJPEGImage;
  {$ENDIF}
  {$IFDEF USE_GIFImage}
  LGIFImage  : TGIFImage;
  {$ENDIF}
  {$IFDEF USE_GR32_PNG}
  LPNGImage  : TPortableNetworkGraphic32;
  {$ENDIF}
begin
  if AFilename <> '' then
  begin
    LExtension := UpperCase(  Copy( AFileName, Length(AFileName) - 2, 3 )  );

    // Quick and dirty check that file type is OK
    Assert( (LExtension = 'BMP') or
            (LExtension = 'JPG') or
            (LExtension = 'GIF') or
            (LExtension = 'PNG') or
            (LExtension = 'TIF') );

    // Save BMP Files
    if LExtension = 'BMP' then
    begin
      LSaveBitmap := TBitmap.Create;
      try
        LSaveBitmap.Assign(ABitmap);
        LSaveBitmap.PixelFormat := pf24bit;
        LSaveBitmap.SaveToFile(AFileName);
      finally
        LSaveBitmap.Free;
      end;
    end;

    {$IFDEF USE_JPEG}
    // Save JPG File
    if LExtension = 'JPG' then
    begin
      LJPEGImage  := TJPEGImage.Create;
      LSaveBitmap := TBitmap.Create;
      try
        LSaveBitmap.Assign(ABitmap);
        LSaveBitmap.PixelFormat := pf24bit;

        LJPEGImage.Assign(LSaveBitmap);
        LJPEGImage.SaveToFile(AFileName);
      finally
        LSaveBitmap.Free;
        LJPEGImage.Free;
      end;
    end;
    {$ENDIF}

    {$IFDEF USE_GIFImage}
    // Save GIF File
    if LExtension = 'GIF' then
    begin
      LGIFImage   := TGIFImage.Create;
      LSaveBitmap := TBitmap.Create;
      try
        LSaveBitmap.Assign(ABitmap);
        
        LGIFImage.Assign(LSaveBitmap);
        LGIFImage.SaveToFile(AFileName);
      finally
        LGIFImage.Free;
        LSaveBitmap.Free;
      end;
    end;
    {$ENDIF}

    // Save PNG Files
    if LExtension = 'PNG' then
    begin
      {$IFDEF USE_GR32_PNG}
      LPNGImage  := TPortableNetworkGraphic32.Create;
      try
        LPNGImage.Assign(ABitmap);
        LPNGImage.SaveToFile(AFileName);
      finally
        LPNGImage.Free;
      end;
      {$ENDIF}
    end;

    // Save TIFF Files
    if LExtension = 'TIF' then
    begin
      {$IFDEF USE_KRUG_TIFF}
      LSaveBitmap := TBitmap.Create;
      try
        LSaveBitmap.Assign(ABitmap);
        LSaveBitmap.PixelFormat := pf24bit;

        WriteTiffToFile(AFileName, LSaveBitmap);
      finally
        LSaveBitmap.Free;
      end;
      {$ENDIF}
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure InitGlobalVariables;
begin
  GMIOErrorMsgOutput := '';
end; 

initialization

   InitGlobalVariables;

end.
