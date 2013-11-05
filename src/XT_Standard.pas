unit XT_Standard;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 Copyright (c) 2013, Jarl K. <Slacky> Holta || http://github.com/WarPie
 All rights reserved.
 For more info see: Copyright.txt
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

interface

uses
  XT_Types;

procedure ExchI(var A,B:Integer); Inline;
procedure ExchE(var A,B:Extended); Inline;
procedure ExchS(var A,B:Single); Inline;
procedure ExchBt(var A,B:Byte); Inline;
procedure ExchPt(var A,B:TPoint); Inline;
procedure SetLengthTPA(var Arr: TPointArray; Size:Integer); StdCall;
procedure SetLengthTIA(var Arr: TIntArray; Size:Integer); StdCall;
procedure SetLengthTEA(var Arr: TExtArray; Size:Integer); StdCall;
procedure SetLengthTBA(var Arr: TByteArray; Size:Integer); StdCall;
procedure SetLengthTBoA(var Arr: TBoolArray; Size:Integer); StdCall;
procedure SetLengthATIA(var Arr: T2DIntArray; Size:Integer); StdCall;
procedure SetLengthATEA(var Arr: T2DExtArray; Size:Integer); StdCall;
procedure SetLengthATBA(var Arr: T2DByteArray; Size:Integer); StdCall;
procedure SetLengthATBoA(var Arr: T2DBoolArray; Size:Integer); StdCall;

//-----------------------------------------------------------------------
implementation


procedure ExchI(var A,B:Integer); Inline;
var t:Integer;
begin t := A;  A := B;  B := t; end;

procedure ExchE(var A,B:Extended); Inline;
var t:Extended;
begin t := A;  A := B;  B := t; end;

procedure ExchS(var A,B:Single); Inline;
var t:Single;
begin t := A;  A := B;  B := t; end;

procedure ExchBt(var A,B:Byte); Inline;
var t:Byte;
begin t := A;  A := B;  B := t; end;

procedure ExchPt(var A,B:TPoint); Inline;
var t:TPoint;
begin t := A;  A := B;  B := t; end;


//SetLength in PS is really slow, so I will export delphi-versions.
procedure SetLengthTPA(var Arr: TPointArray; Size:Integer); StdCall;
begin SetLength(Arr, Size); end;

procedure SetLengthTIA(var Arr: TIntArray; Size:Integer); StdCall;
begin SetLength(Arr, Size); end;

procedure SetLengthTEA(var Arr: TExtArray; Size:Integer); StdCall;
begin SetLength(Arr, Size); end;

procedure SetLengthTBA(var Arr: TByteArray; Size:Integer); StdCall;
begin SetLength(Arr, Size); end;

procedure SetLengthTBoA(var Arr: TBoolArray; Size:Integer); StdCall;
begin SetLength(Arr, Size); end;

procedure SetLengthATIA(var Arr: T2DIntArray; Size:Integer); StdCall;
begin SetLength(Arr, Size); end;

procedure SetLengthATEA(var Arr: T2DExtArray; Size:Integer); StdCall;
begin SetLength(Arr, Size); end;

procedure SetLengthATBA(var Arr: T2DByteArray; Size:Integer); StdCall;
begin SetLength(Arr, Size); end;

procedure SetLengthATBoA(var Arr: T2DBoolArray; Size:Integer); StdCall;
begin SetLength(Arr, Size); end;

end.
