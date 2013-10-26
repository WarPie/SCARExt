unit XT_Standard;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 Copyright (c) 2013, Jarl K. <Slacky> Holta || http://github.com/WarPie
 All rights reserved.
 For more info see: Copyright.txt
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

interface

uses
  XT_Types;

procedure SwapI(var A,B:Integer); Inline;
procedure SwapE(var A,B:Extended); Inline;
procedure SwapS(var A,B:Single); Inline;
procedure SwapBt(var A,B:Byte); Inline;
procedure SwapPt(var A,B:TPoint); Inline;


//-----------------------------------------------------------------------
implementation


procedure SwapI(var A,B:Integer); Inline;
var t:Integer;
begin
  t := A;
  A := B;
  B := t;
end;

procedure SwapE(var A,B:Extended); Inline;
var t:Extended;
begin
  t := A;
  A := B;
  B := t;
end;

procedure SwapS(var A,B:Single); Inline;
var t:Single;
begin
  t := A;
  A := B;
  B := t;
end;

procedure SwapBt(var A,B:Byte); Inline;
var t:Byte;
begin
  t := A;
  A := B;
  B := t;
end;

procedure SwapPt(var A,B:TPoint); Inline;
var t:TPoint;
begin
  t := A;
  A := B;
  B := t;
end;

end.
