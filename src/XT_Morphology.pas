Unit XT_Morphology;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 Copyright (c) 2013, Jarl K. <Slacky> Holta || http://github.com/WarPie
 All rights reserved.
 For more info see: Copyright.txt
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
interface

uses //Not all used but for the future i'll leave it.
  XT_Types, XT_Collection, XT_Points, SysUtils; 
 
function TPASkeleton(const TPA:TPointArray; FMin,FMax:Integer): TPointArray; StdCall;
//function TPAExpand(const TPA:TPointArray; ...): TPointArray; StdCall;
//function TPAReduce(const TPA:TPointArray; ...): TPointArray; StdCall;

//--------------------------------------------------
implementation


{*
 @TPASkeleton: 
 Given a set of points, this function should thin the TPA down to it's bare Skeleton.
 It also takes two modifiers which allow you to change the outcome.
 By letting eather FMin, or FMax be -1 then it will be set to it's defaults which are 2 and 6.
*}

{* __PRIVATE__ *}
function __TransitCount(p2,p3,p4,p5,p6,p7,p8,p9:Integer): Integer; Inline;
begin
  Result := 0;
  if ((p2 = 0) and (p3 = 1)) then Inc(Result);
  if ((p3 = 0) and (p4 = 1)) then Inc(Result);
  if ((p4 = 0) and (p5 = 1)) then Inc(Result);
  if ((p5 = 0) and (p6 = 1)) then Inc(Result);
  if ((p6 = 0) and (p7 = 1)) then Inc(Result);
  if ((p7 = 0) and (p8 = 1)) then Inc(Result);
  if ((p8 = 0) and (p9 = 1)) then Inc(Result);
  if ((p9 = 0) and (p2 = 1)) then Inc(Result);
end;

function TPASkeleton(const TPA:TPointArray; FMin,FMax:Integer): TPointArray; StdCall;
var
  j,i,x,y,h,transit,sumn,SwapHigh,hits: Integer;
  p2,p3,p4,p5,p6,p7,p8,p9:Integer;
  Change, PTS: TPointArray;
  Matrix: T2DByteArray;
  iter : Boolean;
  Area: TBox;
begin
  Area := TPABounds(TPA);
  Area.x1 := Area.x1 - 2;
  Area.y1 := Area.y1 - 2;
  Area.x2 := (Area.x2 - Area.x1) + 2;
  Area.y2 := (Area.y2 - Area.y1) + 2;
  SetLength(Matrix, Area.y2, Area.x2);
  H := High(TPA);
  if (FMin = -1) then FMin := 2;
  if (FMax = -1) then FMax := 6;
  
  if (FMin > FMax) then begin
    i := FMax;
    FMax := FMin;
    FMin := i;
  end;

  SetLength(PTS, H + 1);
  for i:=0 to H do
  begin
    x := (TPA[i].x-Area.x1);
    y := (TPA[i].y-Area.y1);
    PTS[i] := Point(x,y);
    Matrix[y][x] := 1;
  end;
  j := 0;
  SwapHigh := H;
  SetLength(Change, H+1);
  repeat
    iter := (J mod 2) = 0;
    Hits := 0;
    i := 0;
    while i < SwapHigh do begin
      x := PTS[i].x;
      y := PTS[i].y;
      p2 := Matrix[y-1][x];
      p4 := Matrix[y][x+1];
      p6 := Matrix[y+1][x];
      p8 := Matrix[y][x-1];

      if (Iter) then begin
        if (((p4 * p6 * p8) <> 0) or ((p2 * p4 * p6) <> 0)) then begin
          Inc(i);
          Continue;
        end;
      end else if ((p2 * p4 * p8) <> 0) or ((p2 * p6 * p8) <> 0) then
      begin
        Inc(i);
        Continue;
      end;

      p3 := Matrix[y-1][x+1];
      p5 := Matrix[y+1][x+1];
      p7 := Matrix[y+1][x-1];
      p9 := Matrix[y-1][x-1];
      Sumn := (p2 + p3 + p4 + p5 + p6 + p7 + p8 + p9);
      if (SumN >= FMin) and (SumN <= FMax) then begin
        Transit := __TransitCount(p2,p3,p4,p5,p6,p7,p8,p9);
        if (Transit = 1) then begin
          Change[Hits] := PTS[i];
          Inc(Hits);
          PTS[i] := PTS[SwapHigh];
          PTS[SwapHigh] := Point(x,y);
          Dec(SwapHigh);
          Continue;
        end;
      end;
      Inc(i);
    end;

    for i:=0 to (Hits-1) do
      Matrix[Change[i].y][Change[i].x] := 0;

    inc(j);
  until ((Hits=0) and (Iter=False));

  SetLength(Result, (SwapHigh + 1));
  for i := 0 to SwapHigh do
    Result[i] := Point(PTS[i].x+Area.x1, PTS[i].y+Area.y1);

  SetLength(PTS, 0);
  SetLength(Change, 0);
  SetLength(Matrix, 0);
end;

end.