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


//--------------------------------------------------
implementation

function RandomTPA(Amount:Integer; MinX,MinY,MaxX,MaxY:Integer): TPointArray; StdCall;
var i:Integer;
begin
  SetLength(Result, Amount);
  for i:=0 to Amount-1 do
    Result[i] := Point(RandomRange(MinX, MaxX), RandomRange(MinY, MaxY));
end; 


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

end.
