unit be_stream;
//generic stream helper utility for BigEndian byte representation.
//migrate to be used in Delphi 7.0 by x2nie at yahoo dot com
//some portion uses GpStreams.pas for delphi.net

(*:TStream descendants, TStream compatible classes and TStream helpers.
   @author Primoz Gabrijelcic
   @desc <pre>

This software is distributed under the BSD license.

Copyright (c) 2011, Primoz Gabrijelcic
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:
- Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.
- The name of the Primoz Gabrijelcic may not be used to endorse or promote
  products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

   Author            : Primoz Gabrijelcic
   Creation date     : 2006-09-21
   Last modification : 2011-03-17
   Version           : 1.37
</pre>*)
interface
uses Classes,Types,SysUtils;
type
  PDouble = ^Double;
  String4 = string[4];

  
  //http://edn.embarcadero.com/article/28964
  //enumeration used in variant record
  BytePos = (EndVal, ByteVal);
  PEndianCnvRec = ^EndianCnvRec;
  EndianCnvRec = packed record
    case pos: BytePos of
       //The value we are trying to convert
      EndVal: (EndianVal: double);           
       //Overlapping bytes of the double
      //ByteVal: (Bytes: array[0..SizeOf(Double)-1] of byte);
      ByteVal: (Bytes: array[0..7] of byte);
  end;




    function  BE_Read24bits: DWORD; overload;                   {$IFDEF GpStreams_Inline}inline;{$ENDIF}
    function  BE_Read24bits(var w24: DWORD): boolean; overload; {$IFDEF GpStreams_Inline}inline;{$ENDIF}
    function  BE_ReadByte: byte; overload;                      {$IFDEF GpStreams_Inline}inline;{$ENDIF}
    function  BE_ReadByte(var b: byte): boolean; overload;      {$IFDEF GpStreams_Inline}inline;{$ENDIF}
    function  BE_ReadDWord: DWORD; overload;                    {$IFDEF GpStreams_Inline}inline;{$ENDIF}
    function  BE_ReadDWord(var dw: DWORD): boolean; overload;   {$IFDEF GpStreams_Inline}inline;{$ENDIF}
    //function  BE_ReadGUID: TGUID; overload;                     {$IFDEF GpStreams_Inline}inline;{$ENDIF}
    //function  BE_ReadGUID(var guid: TGUID): boolean; overload;  {$IFDEF GpStreams_Inline}inline;{$ENDIF}
    //function  BE_ReadHuge: int64;  overload;                    {$IFDEF GpStreams_Inline}inline;{$ENDIF}
    //function  BE_ReadHuge(var h: int64): boolean;  overload;    {$IFDEF GpStreams_Inline}inline;{$ENDIF}
    function  BE_ReadWord: word; overload;                      {$IFDEF GpStreams_Inline}inline;{$ENDIF}
    function  BE_ReadWord(var w: word): boolean; overload;      {$IFDEF GpStreams_Inline}inline;{$ENDIF}

    function BE_ReadInteger : Integer;
    function BE_ReadSmallInt : SmallInt;
    function BE_ReadHuge(var h: int64): boolean; overload;
    function BE_ReadHuge: int64; overload;


    //x2nie
    //procedure SwapBytes( A, B: PEndianCnvRec );
    
    function BE_ReadWideString: WideString;
    function BE_ReadDouble : Double;
    function BE_ReadFlag: String4; overload;
    function BE_ReadFlag(var s : String4):boolean; overload;


    function SwapEndian(Value: integer): integer; register; overload;
    function SwapEndian(Value: smallint): smallint; register; overload;

var FStream : TStream;
implementation




function BE_ReadDouble : Double;
var 
    q : ^Double;//PEndianCnvRec;//
    w1,w2 : DWORD;
    m : TMemoryStream;
begin
//  GetMem(w,SizeOf(dword));
  GetMem(q,SizeOf(Double));
  result := 0;
  //FStream.ReadBuffer(w^,8);
  w1 := be_readdword;
  w2 := be_readdword;

  m := TMemoryStream.Create;
  m.WriteBuffer(w2,4);
  m.WriteBuffer(w1,4);
  m.Seek(0,soFromBeginning);
  m.ReadBuffer(q^,8);
  m.Free;
  Result := q^;

  FreeMem(q,SizeOf(Double));
end;

//http://edn.embarcadero.com/article/28964
//A gets B's values swapped
{procedure SwapBytes( A, B: PEndianCnvRec );
var
  i: integer;
begin
  for i := high(A.Bytes) downto low(A.Bytes) do
    A.Bytes[i] := B.Bytes[High(A.Bytes) - i];
end;}

function BE_ReadWideString: WideString;
var
  nChars: LongInt;
  i : integer;
begin
  //fstream.ReadBuffer(nChars, SizeOf(nChars));

  //nChars := SwapEndian(nChars);
  nChars := BE_ReadInteger; //exclude last #0

  SetLength(Result, nChars);
  if nChars > 0 then
    //fstream.ReadBuffer(Result[1], nChars * SizeOf(Result[1]));
    for i := 1 to nChars do
    begin
      Result[i] := WideChar(BE_ReadWord);
    end;

  if Result[nChars] = #0 then
    SetLength(Result, nChars-1);

end;

function BE_ReadFlag: String4;
var
  nChars: LongInt;
  i : integer;
begin
  //nChars := BE_ReadInteger;

  SetLength(Result, 4);
  //if nChars > 0 then
    //fstream.ReadBuffer(Result[1], nChars * SizeOf(Result[1]));
    for i := 1 to 4 do
    begin
      Result[i] := chr(BE_readByte);
    end;

end;

function BE_ReadFlag(var s : String4):boolean;
var
  w : DWORD;
  i : integer;

begin
  result := be_readdword(w);

  if result then
  begin

    SetLength(s, 4);
    for i := 1 to 4 do
    begin
      s[i] := chr(longrec(w).Bytes[4-i]);
    end;
  end;

end;


function BE_ReadInteger : Integer;
begin
  //FStream.Read(Result,SizeOf(Result));
  //Result := SwapEndian(Result);
  Result := Integer(be_readDword);
end;


function BE_ReadSmallInt : SmallInt;
begin
  FStream.Read(Result,SizeOf(Result));
  Result := SwapEndian(Result);
end;

function SwapEndian(Value: integer): integer; //register; overload;
asm
  bswap eax
end;

function SwapEndian(Value: smallint): smallint; //register; overload;
asm
  xchg  al, ah
end;



{ TGpStreamEnhancer }

///<summary>Appends full contents of the source stream to the end of Self.
///   <para>Uses CopyStream instead of CopyFrom to support TGpScatteredStream.</para></summary>
///<since>2007-10-17</since>
{procedure Append(source: TStream);
begin
  FStream.Position := Size;
  CopyStream(source, Self, 0);
end;} { Append }


function BE_ReadHuge(var h: int64): boolean;
var
  hi: DWORD;
  lo: DWORD;
begin
  Result := BE_ReadDWord(hi);
  if Result then
    Result := BE_ReadDWord(lo);
  if Result then begin
    Int64Rec(h).Hi := hi;
    Int64Rec(h).Lo := lo;
  end;
end; { TGpStreamEnhancer.BE_ReadHuge }

function BE_ReadHuge: int64;
begin
  Int64Rec(Result).Hi := BE_ReadDWord;
  Int64Rec(Result).Lo := BE_ReadDWord;
end; { TGpStreamEnhancer.BE_ReadHuge }

function BE_ReadByte(var b: byte): boolean;
begin
  Result := (FStream.Read(b, 1) = 1);
end; { BE_ReadByte }

function BE_ReadByte: byte;
begin
  FStream.ReadBuffer(Result, 1);
end; { BE_ReadByte }         

function BE_ReadWord(var w: word): boolean;
var
  lo: byte;
  hi: byte;
begin
  Result := BE_ReadByte(hi);
  if Result then
    Result := BE_ReadByte(lo);
  if Result then begin
    WordRec(w).Hi := hi;
    WordRec(w).Lo := lo;
  end;
end; { BE_ReadWord }

function BE_ReadWord: word;
begin
  WordRec(Result).Hi := BE_ReadByte;
  WordRec(Result).Lo := BE_ReadByte;
end; { BE_ReadWord }

function BE_Read24bits(var w24: DWORD): boolean;
var
  hi: byte;
  lo: word;
begin
  Result := BE_ReadByte(hi);
  if Result then
    Result := BE_ReadWord(lo);
  if Result then begin
    LongRec(w24).Hi := hi;
    LongRec(w24).Lo := lo;
  end;
end; { BE_Read24bits }

function BE_Read24bits: DWORD;
begin
  LongRec(Result).Hi := BE_ReadByte;
  LongRec(Result).Lo := BE_ReadWord;
end; { BE_Read24bits }


function BE_ReadDWord(var dw: DWORD): boolean;
var
  hi: word;
  lo: word;
begin
  Result := BE_ReadWord(hi);
  if Result then
    Result := BE_ReadWord(lo);
  if Result then begin
    LongRec(dw).Hi := hi;
    LongRec(dw).Lo := lo;
  end;
end; { BE_ReadDWord }

function BE_ReadDWord: DWORD;
begin
  LongRec(Result).Hi := BE_ReadWord;
  LongRec(Result).Lo := BE_ReadWord;
end; { BE_ReadDWord }

end.
