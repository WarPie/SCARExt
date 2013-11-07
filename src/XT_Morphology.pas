Unit XT_Morphology;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 Copyright (c) 2013, Jarl K. <Slacky> Holta || http://github.com/WarPie
 All rights reserved.
 For more info see: Copyright.txt
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
interface

uses
  XT_Types,XT_Points, SysUtils;
 
function TPASkeleton(const TPA:TPointArray; FMin,FMax:Integer): TPointArray; StdCall;
function TPAExpand(const TPA:TPointArray; Iterations:Integer): TPointArray; StdCall;
function TPAReduce(const TPA:TPointArray; FMin,FMax, Iterations:Integer): TPointArray; StdCall;


//--------------------------------------------------
implementation
uses XT_TPointStack;


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


{*
 @TPASkeleton: 
 Given a set of points, this function should thin the TPA down to it's bare Skeleton.
 It also takes two modifiers which allow you to change the outcome.
 By letting eather FMin, or FMax be -1 then it will be set to it's defaults which are 2 and 6.
*}
function TPASkeleton(const TPA:TPointArray; FMin,FMax:Integer): TPointArray; StdCall;
var
  j,i,x,y,h,transit,sumn,MarkHigh,hits: Integer;
  p2,p3,p4,p5,p6,p7,p8,p9:Integer;
  Change, PTS: TPointArray;
  Matrix: T2DByteArray;
  iter : Boolean;
  Area: TBox;
begin
  H := High(TPA);
  if (H = -1) then Exit;
  Area := TPABounds(TPA);
  Area.x1 := Area.x1 - 2;
  Area.y1 := Area.y1 - 2;
  Area.x2 := (Area.x2 - Area.x1) + 2;
  Area.y2 := (Area.y2 - Area.y1) + 2;
  SetLength(Matrix, Area.y2, Area.x2);
  if (FMin = -1) then FMin := 2;
  if (FMax = -1) then FMax := 6;

  SetLength(PTS, H + 1);
  for i:=0 to H do
  begin
    x := (TPA[i].x-Area.x1);
    y := (TPA[i].y-Area.y1);
    PTS[i] := Point(x,y);
    Matrix[y][x] := 1;
  end;
  j := 0;
  MarkHigh := H;
  SetLength(Change, H+1);
  repeat
    iter := (J mod 2) = 0;
    Hits := 0;
    i := 0;
    while i < MarkHigh do begin
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
          PTS[i] := PTS[MarkHigh];
          PTS[MarkHigh] := Point(x,y);
          Dec(MarkHigh);
          Continue;
        end;
      end;
      Inc(i);
    end;

    for i:=0 to (Hits-1) do
      Matrix[Change[i].y][Change[i].x] := 0;

    inc(j);
  until ((Hits=0) and (Iter=False));

  SetLength(Result, (MarkHigh + 1));
  for i := 0 to MarkHigh do
    Result[i] := Point(PTS[i].x+Area.x1, PTS[i].y+Area.y1);

  SetLength(PTS, 0);
  SetLength(Change, 0);
  SetLength(Matrix, 0);
end;


{*
 Inversed skeletonizing, it adds a border of points to the given tpa..
 Border-width is desided by the given number of iterations.
*}
function TPAExpand(const TPA:TPointArray; Iterations:Integer): TPointArray; StdCall;
var
  H,i,j: Integer;
  Matrix: T2DBoolArray;
  QueueA, QueueB: TPointStack;
  face:TPointArray;
  pt:TPoint;
  B: TBox;
begin
  H := High(TPA);
  if (H = -1) or (Iterations=0) then Exit;
  B := TPABounds(TPA);
  B.x1 := B.x1 - Iterations - 1;
  B.y1 := B.y1 - Iterations - 1;
  B.x2 := (B.x2 - B.x1) + Iterations + 1;
  B.y2 := (B.y2 - B.y1) + Iterations + 1;
  SetLength(Matrix, B.y2, B.x2);
  for i:=0 to H do
    Matrix[TPA[i].Y - B.Y1][TPA[i].X - B.X1] := True;

  SetLength(face,4);
  QueueA.InitWith(TPAEdges(TPA));
  QueueA.Move(-B.X1,-B.Y1);
  QueueB.Init;
  j := 0;
  repeat
    case (J mod 2) = 0 of
    True:
      while QueueA.NotEmpty do 
      begin
        GetAdjacent(face, QueueA.FastPop, False);
        for i:=0 to 3 do
        begin
          pt := face[i];
          if not(Matrix[pt.y][pt.x]) then
          begin
            Matrix[pt.y][pt.x] := True;
            QueueB.Append(pt);
            Inc(H);
          end;
        end;
      end;
      
    False:
      while QueueB.NotEmpty do 
      begin
        GetAdjacent(face, QueueB.FastPop, False);
        for i:=0 to 3 do
        begin
          pt := face[i];
          if not(Matrix[pt.y][pt.x]) then
          begin
            Matrix[pt.y][pt.x] := True;
            QueueA.Append(pt);
            Inc(H);
          end;
        end;
      end;
    end;
    Inc(j);
  until (j >= Iterations);
  QueueA.Free;
  QueueB.Free;

  SetLength(Result, H+1);
  for I:=0 to B.y2-1 do
    for j:=0 to B.x2-1 do
    begin
      if H<0 then Break;
      if Matrix[i][j] then begin
        Result[H] := Point(j+B.x1,i+B.y1);
        Dec(H);
      end;
    end;

  SetLength(Matrix, 0);
  SetLength(Face, 0);
end;


{*
 //Based on TPASkeleton (might be changed/modified).
 TPAReduce does steps of skeletonizing. So in other words it continiously
 removes the most outer points from tha TPA, that is until it has done the
 given amount of iterations, or the shapes can no longer be thinned.
*}
function TPAReduce(const TPA:TPointArray; FMin,FMax, Iterations:Integer): TPointArray; StdCall;
var
  j,i,x,y,h,transit,sumn,MarkHigh,hits: Integer;
  p2,p3,p4,p5,p6,p7,p8,p9:Integer;
  Change, PTS: TPointArray;
  Matrix: T2DByteArray;
  iter : Boolean;
  Area: TBox;
begin
  H := High(TPA);
  if (H = -1) then Exit;
  Area := TPABounds(TPA);
  Area.x1 := Area.x1 - 2;
  Area.y1 := Area.y1 - 2;
  Area.x2 := (Area.x2 - Area.x1) + 2;
  Area.y2 := (Area.y2 - Area.y1) + 2;
  SetLength(Matrix, Area.y2, Area.x2);

  if (FMin = -1) then FMin := 2;
  if (FMax = -1) then FMax := 6;

  SetLength(PTS, H + 1);
  for i:=0 to H do
  begin
    x := (TPA[i].x-Area.x1);
    y := (TPA[i].y-Area.y1);
    PTS[i] := Point(x,y);
    Matrix[y][x] := 1;
  end;
  j := 0;
  MarkHigh := H;
  SetLength(Change, H+1);
  repeat
    iter := (J mod 2) = 0;
    Hits := 0;
    i := 0;
    while i < MarkHigh do begin
      x := PTS[i].x;
      y := PTS[i].y;
      p2 := Matrix[y-1][x];
      p4 := Matrix[y][x+1];
      p6 := Matrix[y+1][x];
      p8 := Matrix[y][x-1];

      if (Iter) then begin
        if (p4+p6+p8=3) or (p2+p4+p6=3) then 
        begin
          Inc(i);
          Continue;
        end;
      end else if (p2+p4+p8=3) or  (p2+p6+p8=3) then
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
          PTS[i] := PTS[MarkHigh];
          PTS[MarkHigh] := Point(x,y);
          Dec(MarkHigh);
          Continue;
        end;
      end;
      Inc(i);
    end;

    for i:=0 to (Hits-1) do
      Matrix[Change[i].y][Change[i].x] := 0;

    inc(j);
  until ((Hits=0) or (j>=Iterations)) and (Iter=False);

  SetLength(Result, (MarkHigh + 1));
  for i := 0 to MarkHigh do
    Result[i] := Point(PTS[i].x+Area.x1, PTS[i].y+Area.y1);

  SetLength(PTS, 0);
  SetLength(Change, 0);
  SetLength(Matrix, 0);
end;


end.








