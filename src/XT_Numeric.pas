Unit XT_Numeric;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 Copyright (c) 2013, Jarl K. <Slacky> Holta || http://github.com/WarPie
 All rights reserved.
 For more info see: Copyright.txt
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
interface
uses
  XT_Types, Math, SysUtils;

function SumTIA(const Arr: TIntArray): Integer; Inline;
function SumTEA(const Arr: TExtArray): Extended; Inline;
procedure MinMaxTIA(const Arr: TIntArray; var Min:Integer; var Max: Integer); Inline; StdCall;
procedure MinMaxTEA(const Arr: TExtArray; var Min:Extended; var Max: Extended); Inline; StdCall;
procedure TIAsToTPA(const X:TIntArray; const Y:TIntArray; var TPA:TPointArray); StdCall;
function TIAToATIA(const TIA:TIntArray; Width,Height:Integer): T2DIntArray; StdCall;


//--------------------------------------------------
implementation


{*
  Sum of a TIA.
*}
function SumTIA(const Arr: TIntArray): Integer; Inline;
var i:Integer;
begin
  Result := 0;
  for i:=Low(Arr) to High(Arr) do
    Result := Result + Arr[i];
end;


{*
  Sum of a TEA.
*}
function SumTEA(const Arr: TExtArray): Extended; Inline;
var i:Integer;
begin
  Result := 0.0;
  for i:=Low(Arr) to High(Arr) do
    Result := Result + Arr[i];
end;


{*
  Finds the minimum and maximum of a TIA.
*}
procedure MinMaxTIA(const Arr: TIntArray; var Min:Integer; var Max: Integer); Inline; StdCall;
var i:Integer;
begin
  Min := Arr[0];
  Max := Arr[0];
  for i:=Low(Arr) to High(Arr) do
  begin
    if Arr[i] < Min then
      Min := Arr[i]
    else if Arr[i] > Max then
      Max := Arr[i];
  end;
end;


{*
  Finds the minimum and maximum of a TEA.
*}
procedure MinMaxTEA(const Arr: TExtArray; var Min:Extended; var Max: Extended); Inline; StdCall;
var i:Integer;
begin
  Min := Arr[0];
  Max := Arr[0];
  for i:=Low(Arr) to High(Arr) do
  begin
    if Arr[i] < Min then
      Min := Arr[i]
    else if Arr[i] > Max then
      Max := Arr[i];
  end;
end;


{*
  Given two TIAs this function will join them in to one TPA.
*}
procedure TIAsToTPA(const X:TIntArray; const Y:TIntArray; var TPA:TPointArray); StdCall;
var i,H:Integer;
begin
  H := Min(High(X), High(Y));
  SetLength(TPA, H+1);
  for i:=0 to H do
    TPA[i] := Point(X[i], Y[i]);
end;


{*
  ...
*}
function TIAToATIA(const TIA:TIntArray; Width,Height:Integer): T2DIntArray; StdCall;
var x,y,i:Integer;
begin
  SetLength(Result, Height,Width);
  i := 0;
  for y:=0 to Height-1 do
    for x:=0 to Width-1 do
    begin
      Result[y][x] := TIA[i];
      Inc(i);
    end;
end;

{
function TIADistribution(TIA:TIntArray; Percent:Integer): TIntArray; StdCall;
var
  Dst,r,c,i,j,h,d:Integer;
begin
  H := High(TIA);
  Dst := Max(1, Round(H * (Percent/100))); 
  D := (H div Dst)-1;
  SetLength(Result, D+1);
  c := 0;
  for i:=0 to D do
  begin
    R := 0;
    for j:=0 to Dst do
    begin
      R := R + TIA[c+j];
    end;
    c := c + Dst; 
    Result[i] := R; 
  end;
  SetLength(Result, i);
end;

}


end.






