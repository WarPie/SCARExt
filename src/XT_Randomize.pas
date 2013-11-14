Unit XT_Randomize;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 Copyright (c) 2013, Jarl K. <Slacky> Holta || http://github.com/WarPie
 All rights reserved.
 For more info see: Copyright.txt
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
interface
uses
  XT_Types, Math, SysUtils;
  
function RandomTPA(Amount:Integer; MinX,MinY,MaxX,MaxY:Integer): TPointArray; StdCall;  
function RandomCenterTPA(Amount:Integer; CX,CY,RadX,RadY:Integer): TPointArray; StdCall;
function RandomTIA(Amount:Integer; Low,Hi:Integer): TIntArray; StdCall;
function GaussPt(MeanPt:TPoint; Stddev:Extended): TPoint; StdCall;
function GaussPtEx(MeanPt:TPoint; StdDev, MaxDev:Extended): TPoint; StdCall;


//--------------------------------------------------
implementation


(*
  Simple random tpa, with some extra parameters compared to what SCAR offers.
*)
function RandomTPA(Amount:Integer; MinX,MinY,MaxX,MaxY:Integer): TPointArray; StdCall;
var i:Integer;
begin
  SetLength(Result, Amount);
  for i:=0 to Amount-1 do
    Result[i] := Point(RandomRange(MinX, MaxX), RandomRange(MinY, MaxY));
end; 


(*
  TPA with a "gravity" that goes towards the mean (center). 
  Similar to gaussian distribution of the TPoints.
*)
function RandomCenterTPA(Amount:Integer; CX,CY,RadX,RadY:Integer): TPointArray; StdCall;
var
  i:Integer;
  x,y,xstep,ystep: Single;
begin
  SetLength(Result, Amount);
  xstep := RadX / Amount;
  ystep := RadY / Amount;
  x:=0; y:=0;
  for i:=0 to Amount-1 do begin
    x := x + xstep;
    y := y + ystep;
    Result[i].x := RandomRange(Round(CX-x), Round(CX+x));
    Result[i].y := RandomRange(Round(CY-y), Round(CY+y));
  end;
end;


(*
  Simple random TIA, with some extra parameters compared to what SCAR offers.
*)
function RandomTIA(Amount:Integer; Low,Hi:Integer): TIntArray; StdCall;
var i:Integer;
begin
  SetLength(Result, Amount);
  for i:=0 to Amount-1 do
    Result[i] := RandomRange(Low,Hi);
end; 


(*
  Generates a "gaussian" (normally distributed) TPoint using Box�Muller transform. 
*)
function GaussPt(MeanPt:TPoint; Stddev:Extended): TPoint; StdCall;
var Theta,Scale:Extended;
begin
  Scale := Stddev * Sqrt(-2 * Ln(1 - Random));
  Theta := 2 * PI * Random;
  Result.x := Round(MeanPt.x + Scale * Cos(theta));
  Result.y := Round(MeanPt.y + Scale * Sin(theta));
end;


(*
  Generates a "gaussian" (normally distributed) TPoint using Box�Muller transform.
  Takes an extra parameter to keep points within a given range (maxDev) / "Removes peaks".
*)
function GaussPtEx(MeanPt:TPoint; StdDev, MaxDev:Extended): TPoint; StdCall;
var Theta,Scale:Extended;
begin 
  if MaxDev < 1 then MaxDev := 1;
  Scale := Stddev * Sqrt(-2 * Ln(1 - Random));
  while Scale > MaxDev do
    Scale := Stddev * Sqrt(-2 * Ln(1 - Random));
  Theta := 2 * PI * Random;
  Result.x := Round(MeanPt.x + Scale * Cos(theta));
  Result.y := Round(MeanPt.y + Scale * Sin(theta));
end;


end.
