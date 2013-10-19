Unit XT.Randomize;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 CopyLeft Jarl "SLACKY" Holta - Released under Lazy-lisence which states:
 > As soon as it's released publicly, I do no longer OWN the code,
 > I however own my copy of it. I can only ask you to keep my credits.
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
interface
uses
  XT.Types, System.Math, System.SysUtils;
  
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