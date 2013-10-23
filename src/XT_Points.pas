Unit XT_Points;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 CopyLeft Jarl "SLACKY" Holta - Released under Lazy-lisence which states:
 > As soon as it's released publicly, I do no longer OWN the code,
 > I however own my copy of it. I can only ask you to keep my credits.
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
interface

uses
  XT_Types, XT_Math, Math, SysUtils;
  
function SamePoints(P1, P2:TPoint):Boolean; Inline;
function MovePoint(const Center, Pt:TPoint; Radius:Integer): TPoint; Inline;
function SumTPA(Arr: TPointArray): TPoint; Inline; StdCall;
procedure TPASeparateAxis(const TPA: TPointArray; var X:TIntArray; var Y:TIntArray); StdCall;
procedure TPAFilterBounds(var TPA: TPointArray; x1,y1,x2,y2:Integer); StdCall;
function GetTPAMax(const TPA: TPointArray): TPoint;
function GetTPABounds(const TPA: TPointArray): TBox;
function GetTPAMean(const TPA: TPointArray): TPoint;
function GetTPAMiddle(const TPA: TPointArray): TPoint;
function GetTPAExtremes(const TPA:TPointArray): TPointArray; StdCall; 
function GetTPABBox(TPA:TPointArray): TPointArray; StdCall;
procedure GetAdjacent(var adj:TPointArray; n:TPoint; EightWay:Boolean); Inline; StdCall;
procedure RotatingAdjecent(var Adj:TPointArray;const Curr:TPoint; const Prev:TPoint); Inline;
procedure ReverseTPA(var TPA: TPointArray); StdCall;
procedure MoveTPA(var TPA: TPointArray; SX,SY:Integer); StdCall;
procedure TPARemoveDupes(var TPA: TPointArray); StdCall;
procedure LongestPolyVector(const Poly:TPointArray; var A,B:TPoint); StdCall;
function InvertTPA(const TPA:TPointArray): TPointArray; StdCall;
function RotateTPAEx(const TPA: TPointArray; const Center:TPoint; Radians: Extended): TPointArray; StdCall;
function TPAPartition(const TPA:TPointArray; BoxWidth, BoxHeight:Integer): T2DPointArray; StdCall;
function AlignTPA(TPA:TPointArray; Method: TAlignMethod; var Angle:Extended): TPointArray; StdCall;
function CleanSortTPA(const TPA: TPointArray): TPointArray; StdCall;
function UniteTPA(const TPA1, TPA2: TPointArray; RemoveDupes:Boolean): TPointArray; StdCall;
procedure TPALine(var TPA:TPointArray; const P1:TPoint; const P2: TPoint); Inline; StdCall;
function ConnectTPA(const TPA:TPointArray): TPointArray; Inline; StdCall;
function ConnectTPAEx(TPA:TPointArray; Tension:Extended): TPointArray; Inline; StdCall;
function XagonPoints(const Center:TPoint; Sides:Integer; const Dir:TPoint): TPointArray; Inline; StdCall;
procedure TPAEllipse(var TPA:TPointArray; const Center: TPoint; RadX,RadY:Integer); Inline; StdCall;
procedure TPACircle(var TPA:TPointArray; const Center: TPoint; Radius:Integer); Inline; StdCall;
procedure TPASimplePoly(var TPA:TPointArray; const Center:TPoint; Sides:Integer; const Dir:TPoint); inline; StdCall;
function __VectorTurn(const p, q, r: TPoint): Boolean; Inline; StdCall;
function ConvexHull(const TPA:TPointArray): TPointArray; StdCall;
function FloodFillTPAEx(const TPA:TPointArray; const Start:TPoint; EightWay, KeepEdges:Boolean): TPointArray; StdCall;
function FloodFillTPA(const TPA:TPointArray; const Start:TPoint; EightWay:Boolean): TPointArray; StdCall;
function TPAOutline(const TPA:TPointArray): TPointArray; StdCall;
function TPABorder(const TPA:TPointArray): TPointArray; StdCall;
function FloodFillPolygon(const Poly:TPointArray; EightWay:Boolean): TPointArray; StdCall;
function ClusterTPAEx(const TPA: TPointArray; Distx,Disty: Integer; EightWay:Boolean): T2DPointArray; StdCall;
function ClusterTPA(const TPA: TPointArray; Distance: Integer; EightWay:Boolean): T2DPointArray; StdCall;
function __TransitCount(p2,p3,p4,p5,p6,p7,p8,p9:Integer): Integer; Inline;
function TPASkeleton(const TPA:TPointArray; FMin,FMax:Integer): TPointArray; StdCall;


//--------------------------------------------------
implementation

uses 
  XT_CSpline, XT_Collection;

{*
 Compares two TPoints, to se if they are the same or not.
*}
function SamePoints(P1, P2:TPoint):Boolean; Inline;
begin
  Result := ((P1.x = P2.x) and (P1.y = P2.y));
end;


{*
 Return the outer point at the angle of the vector "Center->Pt". 
 The outer point is defined as Center + Radius, and the angle of "Center->Pt".
*}
function MovePoint(const Center, Pt:TPoint; Radius:Integer): TPoint; Inline;
var
  dx,dy: Integer;
  Angle: Single;
begin
  dx := (Center.X - Pt.X);
  dy := (Center.Y - Pt.Y);
  Angle := ArcTan2(dy, dx) + PI;
  Result.x := Round(Radius * Cos(Angle)) + Center.X;
  Result.y := Round(Radius * Sin(Angle)) + Center.Y;
end;


{*
 Calculates the total sum of the TPA.
*}
function SumTPA(Arr: TPointArray): TPoint; Inline; StdCall;
var i:Integer;
begin
  Result := Point(0,0);
  for i:=Low(Arr) to High(Arr) do
  begin
    Result.x := Result.x + Arr[i].x;
    Result.y := Result.y + Arr[i].y;
  end;
end;


{*
  Splits the TPA in to two TIAs: X- and Y-Axis.
*}
procedure TPASeparateAxis(const TPA: TPointArray; var X:TIntArray; var Y:TIntArray); StdCall;
var i,H:Integer;
begin
  H := High(TPA);
  SetLength(X, H+1);
  SetLength(Y, H+1);
  for i:=0 to H do
  begin
    X[i] := TPA[i].x;
    Y[i] := TPA[i].y;
  end;
end;


{*
  Removes the points outside the bound.
*}
procedure TPAFilterBounds(var TPA: TPointArray; x1,y1,x2,y2:Integer); StdCall;
var i,j,H:Integer;
begin
  H := High(TPA);
  j := 0;
  for i:=0 to H do
    if InRange(TPA[i].x, x1,x2) and InRange(TPA[i].y, y1,y2) then 
    begin
      TPA[j] := TPA[i];
      Inc(j);
    end;
  SetLength(TPA, j);
end;


{*
 Return the largest numbers for x, and y-axis in TPA.
*}
function GetTPAMax(const TPA: TPointArray): TPoint;
var
  I,L : Integer;
begin;
  L := High(TPA);
  if (l < 0) then Exit;
  Result.x := TPA[0].x;
  Result.y := TPA[0].y;
  for I:=0 to L do
  begin
    if TPA[i].x > Result.x then
      Result.x := TPA[i].x;
    if TPA[i].y > Result.y then
      Result.y := TPA[i].y;
  end;
end;


{*
 Return the largest and the smallest numbers for x, and y-axis in TPA.
*}
function GetTPABounds(const TPA: TPointArray): TBox;
var
  I,L : Integer;
begin;
  FillChar(Result, SizeOf(TBox), 0);
  L := High(TPA);
  if (l < 0) then Exit;
  Result.x1 := TPA[0].x;
  Result.y1 := TPA[0].y;
  Result.x2 := TPA[0].x;
  Result.y2 := TPA[0].y;
  for I:= 1 to L do
  begin;
    if TPA[i].x > Result.x2 then
      Result.x2 := TPA[i].x
    else if TPA[i].x < Result.x1 then
      Result.x1 := TPA[i].x;
    if TPA[i].y > Result.y2 then
      Result.y2 := TPA[i].y
    else if TPA[i].y < Result.y1 then
      Result.y1 := TPA[i].y;
  end;
end;


{*
 Returns the most outer points in the TPA, requres a tpa of atleast 4 points.
 Similar to GetTPABounds, except it returns the points.
*}
function GetTPAExtremes(const TPA:TPointArray): TPointArray; StdCall;
var
  I,L : Integer;
begin
  L := High(TPA);
  if (l < 3) then Exit; 
  SetLength(Result, 4);
  Result[0] := TPA[0];
  Result[1] := TPA[0];
  Result[2] := TPA[0];
  Result[3] := TPA[0];
  for I:= 1 to L do
  begin
    if TPA[i].x > Result[0].x then
      Result[0] := TPA[i] 
    else if TPA[i].x < Result[2].x then
      Result[2] := TPA[i]; 
    if TPA[i].y > Result[1].y then
      Result[1] := TPA[i]
    else if TPA[i].y < Result[3].y then
      Result[3] := TPA[i]; 
  end;
end;

{*
 Mean as in defined by SumTPA divided by Length.
*}
function GetTPAMean(const TPA: TPointArray): TPoint;
var
  l: Integer;
begin
  l := Length(TPA);
  if (l > 0) then
  begin
    Result := SumTPA(TPA);
    Result := Point((Result.X div l), (Result.Y div l));
  end else
    Result := Point(0, 0);
end;


{*
 Middle as in defined by the center of the shape's outer bounds.
*}
function GetTPAMiddle(const TPA: TPointArray): TPoint;
var
  l: Integer;
  B : Tbox;
begin
  l := Length(TPA);
  if (l > 0) then
  begin
    B := GetTPABounds(TPA);
    Result.X := B.X1 + ((B.X2 - B.X1) div 2);
    Result.Y := B.Y1 + ((B.Y2 - B.Y1) div 2);
  end else
    Result := Point(0, 0);
end;


{*
 Returns the minimum bounding rectangle around the given TPA.
*}
function GetTPABBox(TPA:TPointArray): TPointArray; StdCall;
var
  L,i,j,v,c,edge_x,edge_y,w,h:Integer; 
  halfpi,X,Y,cosA,cosAP,CosAM: Extended;
  xl,yl,xh,yh,Area,Angle:Extended; 
  Shape:TPointArray;
  Angles,BBox:TExtArray;
  added:Boolean;
  pt:TPoint;
begin
  SetLength(Result, 4); 
  if Length(TPA) <= 1 then Exit;
  Shape := ConvexHull(TPA);
  L := Length(Shape) - 1;
  halfpi := (PI/2);
  SetLength(angles, L);
  
  j := 0;    
  for i:=0 to (L-1) do
  begin
    Angles[j] := PI; //Init with number greater then halfpi
    Added := False;
    edge_x := Shape[i+1].x - Shape[i].x;
    edge_y := Shape[i+1].y - Shape[i].y; 
    Angle := Abs(Modulo(ArcTan2(edge_y, edge_x), halfpi));
    for c:=0 to j do
      if (angles[c] = Angle) then Added := True; 
    if not(Added) then begin 
      angles[j] := Angle;
      Inc(j);
    end;     
  end;                    
  SetLength(angles, j); 
  SetLength(BBox, 6);
  BBox[1] := MaxInt;
  for i:=0 to j-1 do
  begin  
    CosA := Cos(angles[i]);
    CosAP := Cos(angles[i]+halfpi);
    CosAM := Cos(angles[i]-halfpi);
    xl := (CosA*shape[0].x) + (CosAM*shape[0].y); 
    yl := (CosAP*shape[0].x) + (CosA*shape[0].y);
    xh := xl;
    yh := yl;
    for v:=0 to L do
    begin
      pt := shape[v];
      x  := (cosA*pt.x) + (cosAM*pt.y); 
      y  := (cosAP*pt.x) + (cosA*pt.y);
      if (x > xh) then xh := x
      else if (x < xl) then xl := x;
      if (y > yh) then yh := y
      else if (y < yl) then yl := y;
    end;
    Area := (xh-xl)*(yh-yl);
    if (Area < bbox[1]) then begin
      BBox[0] := Angles[i];
      BBox[1] := Area;
      BBox[2] := xl;
      BBox[3] := xh;
      BBox[4] := yl;
      BBox[5] := yh;
    end;
  end;
  Angle := bbox[0];   
  cosA  := Cos(Angle);
  cosAP := Cos(Angle+halfpi);
  cosAM := Cos(Angle-halfpi);
  xl := bbox[2];
  xh := bbox[3];
  yl := bbox[4];
  yh := bbox[5];
  Result[0] := Point(Round((cosAP*yl) + (cosA*xh)), Round((cosA*yl) + (cosAM*xh)));
  Result[1] := Point(Round((cosAP*yl) + (cosA*xl)), Round((cosA*yl) + (cosAM*xl)));
  Result[2] := Point(Round((cosAP*yh) + (cosA*xl)), Round((cosA*yh) + (cosAM*xl)));
  Result[3] := Point(Round((cosAP*yh) + (cosA*xh)), Round((cosA*yh) + (cosAM*xh)));
end;


{*
 Return the neighbours of the given TPoint defined by `n`.
*}
procedure GetAdjacent(var adj:TPointArray; n:TPoint; EightWay:Boolean); Inline; StdCall;
begin
  adj[0] := Point(n.x-1,n.y);
  adj[1] := Point(n.x,n.y-1);
  adj[2] := Point(n.x+1,n.y);
  adj[3] := Point(n.x,n.y+1);
  if EightWay then 
  begin
    adj[4] := Point(n.x-1,n.y-1);
    adj[5] := Point(n.x+1,n.y+1);
    adj[6] := Point(n.x-1,n.y+1);
    adj[7] := Point(n.x+1,n.y-1);
  end;
end;


{*
 Walk around current, from previous. It's 8way.
*}    
procedure RotatingAdjecent(var Adj:TPointArray;const Curr:TPoint; const Prev:TPoint); Inline;
var
  i: Integer;
  dx,dy,x,y:Single;
begin
  x := Prev.x; y := Prev.y;
  adj[7] := Prev;
  for i:=0 to 6 do
  begin
    dx := x - Curr.x;
    dy := y - Curr.y;
    x := ((dy * 0.7070) + (dx * 0.7070)) + Curr.x;
    y := ((dy * 0.7070) - (dx * 0.7070)) + Curr.y;
    adj[i] := Point(Round(x),Round(y));
  end;
end;


{*
 Reverses the TPointArray / flips it (Self note: list[::-1]).
*}
procedure ReverseTPA(var TPA: TPointArray); StdCall; //Untested.
var 
  i, Hi, Mid: Integer;
  tmp:TPoint;
begin
  Hi := High(TPA);
  if (Hi < 0) then Exit;
  Mid := Hi div 2;
  for i := 0 to Mid do begin
    tmp := TPA[Hi-i];
    TPA[Hi-i] := TPA[i];
    TPA[i] := tmp;
  end;
end;

{*
 Moves the TPA by SX, and SY points.
*}
procedure MoveTPA(var TPA: TPointArray; SX,SY:Integer); StdCall;
var
  I,L : Integer;
begin;
  L := High(TPA);
  if (L < 0) then Exit;
  for I:=0 to L do begin
    TPA[i].x := TPA[i].x + SX;
    TPA[i].y := TPA[i].y + SY;
  end;
end;


{*
 Removing all duplicates in the TPA.
*}
procedure TPARemoveDupes(var TPA: TPointArray); StdCall;
var
  i, j, H: Integer;
  Matrix: T2DBoolArray;
  b: TBox;
begin;
  H := High(TPA);
  if (H <= 0) then Exit;
  b := GetTPABounds(TPA);
  Matrix := BoolMatrixNil((b.X2 - b.X1) + 1, (b.Y2 - b.Y1) + 1);
  j := 0;
  for i:=0 to H do
    if Matrix[(TPA[i].Y - b.Y1)][(TPA[i].X - b.X1)] <> True then
    begin
      Matrix[(TPA[i].Y - b.Y1)][(TPA[i].X - b.X1)] := True;
      TPA[j] := TPA[i];
      Inc(j);
    end;
  SetLength(TPA, j);
  SetLength(Matrix, 0);
end;


{*
 Given a Polygon defined by atleast two points, this function will find the longest side.
*}
procedure LongestPolyVector(const Poly:TPointArray; var A,B:TPoint); StdCall;
var
  I,j,L: Integer;
  Dist,tmp: Single;
begin
  L := Length(Poly);
  if (l <= 2) then Exit;
  A := Poly[0];
  B := Poly[1];
  Dist := Sqr(A.x - B.x) + Sqr(A.y - B.y);
  for I:= 0 to (L-1) do
  begin    
    j := (i+1) mod L;
    tmp := Sqr(Poly[j].x - Poly[i].x) + Sqr(Poly[j].y - Poly[i].y);
    if Tmp > Dist then
    begin
      A := Poly[i];
      B := Poly[j];
      Dist := tmp;
    end;
  end;
end;


{*
 Returns the points not in the TPA within the bounds of the TPA.
*}
function InvertTPA(const TPA:TPointArray): TPointArray; StdCall;
var
  Matrix: T2DBoolArray;
  i,h,x,y: Integer;
  Area: TBox;
begin
  Area := GetTPABounds(TPA);
  Area.X2 := (Area.X2-Area.X1);
  Area.Y2 := (Area.Y2-Area.Y1);
  Matrix := BoolMatrixNil(Area.X2+1, Area.Y2+1);
  
  H := High(TPA);
  for i:=0 to H do
    Matrix[TPA[i].y-Area.y1][TPA[i].x-Area.x1] := True;

  SetLength(Result, (Area.X2+1)*(Area.Y2+1));
  i := 0;
  for x:=0 to Area.X2 do
    for y:=0 to Area.Y2 do
      if Matrix[y][x] <> True then
      begin
        Result[i] := Point(x+Area.x1,y+Area.y1);
        Inc(i);
      end;
  SetLength(Result, i);
  SetLength(Matrix, 0);
end;


{*
 Unlike RotateTPA found in SCAR-Divi this function tries to keep the TPA filled even after rotation.
 The function is simply adding the surrounding pixels for each point to the result.
 then it will filter out duplicates. The result may then be 1px larger then original in each direction.
 
 //Future: Should look in to rotating the TPA first, then filling all small holes. Will be faster.
*}
function RotateTPAEx(const TPA: TPointArray; const Center:TPoint; Radians: Extended): TPointArray;StdCall;
var
   I, L,cx,cy,h: Integer;
   CosA,SinA,x,y: extended;
begin
  L := High(TPA);
  cx := Center.x;
  cy := Center.y;
  SetLength(Result, (L+1)*3);
  CosA := Cos(Radians);
  SinA := Sin(Radians);
  H := 0;
  for I := 0 to L do
  begin
    H := H+3;
    X := (CosA * (TPA[i].x - cX)) - (SinA * (TPA[i].y - cY)) + cX;
    Y := (SinA * (TPA[i].x - cX)) + (CosA * (TPA[i].y - cY)) + cY;
    Result[h-3] := Point(Trunc(x), Trunc(y));
    Result[h-2] := Point(Trunc(x)-1, Trunc(y));
    Result[h-1] := Point(Round(x), Ceil(y)-1);
  end;
  TPARemoveDupes(Result);
end;


{*
 Partitions a TPA, by splitting it in to boxes of `BoxWidth` and `BoxHeight`
 The result is the ATPA containing all the area TPAs.
*}
function TPAPartition(const TPA:TPointArray; BoxWidth, BoxHeight:Integer): T2DPointArray; StdCall;
var
  i,x,y,id,l,cols,rows,h:Integer;
  Area:TBox;
begin
  H := High(TPA);
  if (H < 0) then Exit;
  Area := GetTPABounds(TPA);
  Area.X2 := (Area.X2 - Area.X1) + 1;  //Width
  Area.Y2 := (Area.Y2 - Area.Y1) + 1;  //Height
  Cols := Ceil(Area.X2 / BoxWidth);
  Rows := Ceil(Area.Y2 / BoxHeight);
  SetLength(Result, (Cols+1)*(Rows+1));
  for i:=0 to H do
  begin
    X := (TPA[i].x-Area.x1) div BoxWidth;
    Y := (TPA[i].y-Area.y1) div BoxHeight;
    ID := (Y*Cols)+X;
    L := Length(Result[ID]);
    SetLength(Result[ID], L+1);
    Result[ID][L] := TPA[i];
  end;
end; 


{*
 This function should align the TPA by the longest side to the X-Axis.
*}
function AlignTPA(TPA:TPointArray; Method: TAlignMethod; var Angle:Extended): TPointArray; StdCall;
var 
  Shape:TPointArray;
  A,B:TPoint;
begin
  case Method of
    AM_Extremes:Shape := GetTPAExtremes(TPA);
    AM_Convex:  Shape := ConvexHull(TPA);
    AM_BBox:    Shape := GetTPABBox(TPA);
  end;
  LongestPolyVector(Shape, A,B);
  Angle := ArcTan2(-(B.y-A.y),(B.x-A.x));
  //if (Angle > 2.95) then Angle := (PI-Angle)
  //else if (Angle < -2.95) then Angle := (Angle-PI);     //Remove if causes problems or confusion.
  Result := RotateTPAEx(TPA, GetTPAMiddle(TPA), Angle);
  SetLength(Shape, 0);
  Angle := Modulo(Degrees(Angle), 360);  //Always in range of 0 and 359 dgr!
end;


{*
 Removes duplicates, and sorts the TPA by Column.
 Uses a Matrix, so it limited, but should be fast for High density TPAs.
 Complexity is around W*H+n*2
*}
function CleanSortTPA(const TPA: TPointArray): TPointArray; StdCall;
var
  Matrix: T2DBoolArray;
  i, C, H, idx, x, y: Integer;
  Area: TBox;
begin
  Area := GetTPABounds(TPA);
  Area.X2 := (Area.X2-Area.X1);
  Area.Y2 := (Area.Y2-Area.Y1);
  H := High(TPA);
  Matrix := BoolMatrixNil(Area.X2+1, Area.Y2+1);

  C := 0;
  for I:=0 to H do
  begin
    if Matrix[(TPA[i].y - Area.Y1)][(TPA[i].x - Area.X1)] = True then
      Continue;
    Matrix[(TPA[i].y - Area.Y1)][(TPA[i].x - Area.X1)] := True;
    Inc(C);
  end;

  SetLength(Result, C);
  idx := 0;
  for x := 0 to Area.X2 do
    for y := 0 to Area.Y2 do
      if Matrix[y][x] = True then
      begin
        Result[idx] := Point((X+Area.X1), (Y+Area.Y1));
        Inc(idx);
        if (idx >= C) then
          Exit;
      end;
  SetLength(Matrix, 0);
end;


{*
 Unite two TPAs into one
 ... While also removing all duplicates if `RemoveDupes` is set, so it wont be any overlapping.
*}
function UniteTPA(const TPA1, TPA2: TPointArray; RemoveDupes:Boolean): TPointArray; StdCall;
var
  Matrix: T2DBoolArray;
  i, j: Integer;
  Area: TBox;
begin
  SetLength(Result, High(TPA1) + High(TPA2) + 2);
  Move(TPA1[Low(TPA1)], Result[Low(Result)], Length(TPA1)*SizeOf(TPA1[0]));
  Move(TPA2[Low(TPA2)], Result[High(TPA1)+1], Length(TPA2)*SizeOf(TPA2[0]));

  if RemoveDupes then
  begin
    Area := GetTPABounds(Result);
    Matrix := BoolMatrixNil((Area.X2-Area.X1)+1, (Area.Y2-Area.Y1)+1);
    j := 0;
    for I:=Low(Result) to High(Result) do
    begin
      if Matrix[(Result[i].y - Area.Y1)][(Result[i].x - Area.X1)] = True then
        Continue;
      Matrix[(Result[i].y - Area.Y1)][(Result[i].x - Area.X1)] := True;
      Result[j] := Result[i];
      Inc(j);
    end;
    SetLength(Result, j);
  end;
  SetLength(Matrix, 0);
end; 


{*
 Quickly creates a line from P1 to P2. 
 Algorithm is based on Bresenham's line algorithm.
 
 @note: it extends `var TPA` with the line.
*}
procedure TPALine(var TPA:TPointArray; const P1:TPoint; const P2: TPoint); Inline; StdCall;
var 
  dx,dy,step,I,H: Integer;
  rx,ry,x,y: Extended;
begin
  H := Length(TPA);
  if SamePoints(p1, p2) then
  begin
    SetLength(TPA, H+1);
    TPA[H] := P1; 
    Exit;
  end;
  
  dx := (P2.x - P1.x);
  dy := (P2.y - P1.y);
  if (Abs(dx) > Abs(dy)) then step := Abs(dx)
  else step := Abs(dy);
  SetLength(TPA, (H+step+1));
  
  rx := dx / step; 
  ry := dy / step;
  x := P1.x;
  y := P1.y;
  
  TPA[H] := Point(P1.x, P1.y); 
  for I:=1 to step do
  begin
    x := x + rx;
    y := y + ry;
    TPA[(H+i)] := Point(Round(x),Round(y));
  end;
end;


{*
 Quickly creates a line from from each point in the TPA, to the next point.
 Uses TPALine, found above.
*}
function ConnectTPA(const TPA:TPointArray): TPointArray; Inline; StdCall;
var
  i,j,h: Integer;
  f,t:TPoint;
begin
  H := High(TPA);
  for i:=0 to H do
  begin
    j := i+1;
    if i=h then
      j:=0;
    f := TPA[i];
    t := TPA[j]; 
    if (SamePoints(f, t) = False) then
      TPALine(Result, f, t)
    else
    begin
      SetLength(Result, Length(Result)+1);
      Result[High(Result)] := f;
    end;
  end;
end;


{*
 ConnectTPAEx is the same as ConnectTPA (above function) except that it uses
 Spline so the result is more "curvy", and it's not as fast..
*}
function ConnectTPAEx(TPA:TPointArray; Tension:Extended): TPointArray; Inline; StdCall;
var
  FPts: TFPointArray;
  TMP: TPointArray;
  i,j,h: Integer;
  f,t:TPoint;
begin
  TPARemoveDupes(TPA);
  FPts := CSplineTFPA(TPAToTFPA(TPA), Tension);
  TMP := TFPAToTPA(FPts);
  H := High(TMP);
  for i:=0 to H do
  begin
    j := i+1;
    if i=h then
      j:=0;
    f := TMP[i];
    t := TMP[j]; 
    if (SamePoints(f, t) = False) then
      TPALine(Result, f, t)
    else
    begin
      SetLength(Result, Length(Result)+1);
      Result[High(Result)] := f;
    end;
  end;
  SetLength(TMP, 0);
  SetLength(FPts, 0); 
end;


{*
 Creates all the points needed to define a simple polygon.
*}
function XagonPoints(const Center:TPoint; Sides:Integer; const Dir:TPoint): TPointArray; Inline; StdCall;
var
  i,j: Integer;
  dx,dy,ptx,pty,SinR,CosR:Extended;  
  pt : TPoint;
begin
  SetLength(Result,Sides);
  ptx := Dir.x;
  pty := Dir.y;
  SinR := Sin(Radians(360.0/Sides));
  CosR := Cos(Radians(360.0/Sides)); 
  j := 1;
  Result[0] := Point(Round(ptx),Round(pty));
  for i:=1 to Sides-1 do
  begin
    dx := ptx - Center.x;
    dy := pty - Center.y;
    ptx := (dy * SinR) + (dx * CosR) + Center.x;
    pty := (dy * CosR) - (dx * SinR) + Center.y;
    pt := Point(Round(ptx),Round(pty));
    if SamePoints(Result[j-1], pt) = False then 
    begin
      Result[j] := pt; 
      Inc(j);
    end;
  end;
  SetLength(result, j);
end;


{*
 Creates all the points needed to define a Ellipse.
 Algorithm is based on Bresenham's circle algorithm, tho might be more similr to MidPoint-Circle.
*}
procedure TPAEllipse(var TPA:TPointArray; const Center: TPoint; RadX,RadY:Integer); Inline; StdCall;
var
  RadXSQ,RadYSQ,TwoSQX,TwoSQY,p,x,y,px,py,H:Integer;
begin
  RadXSQ := RadX * RadX;
  RadYSQ := RadY * RadY;
  twoSQX := 2 * RadXSQ;
  twoSQY := 2 * RadYSQ;
  x := 0;
  y := RadY;
  px := 0;
  py := twoSQX * y;

  { Plot the initial point in each quadrant }
  H := 4;
  SetLength(TPA, H);
  TPA[0] := Point(Center.x + x, Center.y + y);
  TPA[1] := Point(Center.x - x, Center.y + y);
  TPA[2] := Point(Center.x + x, Center.y - y);
  TPA[3] := Point(Center.x - x, Center.y - y);

  {* Region 1 *}
  p := Round(RadYSQ - (RadXSQ * RadY) + (0.25 * RadXSQ));
  while (px < py) do
  begin
    Inc(x);
    px := px + twoSQY;
    if (p < 0) then
      p := p + (RadYSQ + px)
    else begin
      Dec(y);
      py := py - twoSQX;
      p := p + (RadYSQ + px - py);
    end;
    H := H + 4;
    SetLength(TPA, H);
    TPA[H-1] := Point(Center.x + x, Center.y + y);
    TPA[H-2] := Point(Center.x - x, Center.y + y);
    TPA[H-3] := Point(Center.x + x, Center.y - y);
    TPA[H-4] := Point(Center.x - x, Center.y - y);
  end;

  {* Region 2 *}
  P := Round(RadYSQ * (x+0.5) * (x+0.5) + RadXSQ * (y-1) * (y-1) - RadXSQ * RadYSQ);
  while (y > 0) do
  begin
    Dec(y);
    py := py - twoSQX;
    if (p > 0) then
      p := p + (RadXSQ - py)
    else begin
      Inc(x);
      px := px + twoSQY;
      p := p + (RadXSQ - py + px);
    end;
    H := H + 4;
    SetLength(TPA, H);
    TPA[H-1] := Point(Center.x + x, Center.y + y);
    TPA[H-2] := Point(Center.x - x, Center.y + y);
    TPA[H-3] := Point(Center.x + x, Center.y - y);
    TPA[H-4] := Point(Center.x - x, Center.y - y);
  end;
end;


{*
 Creates all the points needed to define a Circle.
 Algorithm is based on Bresenham's circle algorithm, tho might be more similr to MidPoint-Circle.
*}
procedure TPACircle(var TPA:TPointArray; const Center: TPoint; Radius:Integer); Inline; StdCall;
begin
  TPAEllipse(TPA, Center, Radius, Radius);
end;


{*
 Uses `SimplePolyPoints` combined with ConnectTPA to draw a line trough each
 point given by `SimplePolyPoints`. So we get a "proper polygon".
*}
procedure TPASimplePoly(var TPA:TPointArray; const Center:TPoint; Sides:Integer; const Dir:TPoint); inline; StdCall;
begin
  TPA := ConnectTPA(XagonPoints(Center, Sides, Dir));
end;


{*
 A 2D-implementation of ConvexHull. ConvexHull can be explained with simple words:
 |> Given a Array of Points, imagine that you where to put a rubber band around am...
 |> The points which strech the rubber band are the points returned by this algorithm.

 Time complexity: O(mn) (M as in Width, and N as in Height) before sorting the points..
 Once sorted and cleaned it's close to O(n).

 @note: It can be made O(n log n) with the use of QuickSort-algorithm over `CleanSortTPA(TPA)`.
*}

{*__PRIVATE__
  Given a triangle (3 points): Q, P and R. We check if QP -> QR forms a right turn. 
  If the result is less then 0 then it forms a right turn, greater then 0 then it forms a left turn.
  @note: This is mainly just used in ConvexHull, but it can be used for more.
*}
function __VectorTurn(const p, q, r: TPoint): Boolean; Inline; StdCall;
begin
  Result := (((q.x*r.y + p.x*q.y + r.x*p.y) - (q.x*p.y + r.x*q.y + p.x*r.y)) < 0);
end; 
function ConvexHull(const TPA:TPointArray): TPointArray; StdCall;
var
  Pts, Lower: TPointArray;
  LH,H,I,UH:Integer;
begin
  if High(TPA) < 0 then Exit;
  // Get a local list copy of the points, and remove dupes.
  Pts := CleanSortTPA(TPA);
  H := High(Pts);
  if H <= 2 then
  begin
    Result := Pts;
    Exit;
  end;

  // Upper half..
  UH := 2;
  SetLength(Result, H+1);
  Result[0] := Pts[0];
  Result[1] := Pts[1];
  for i:=2 to H do
  begin
    Result[UH] := Pts[i];
    Inc(UH);
    while (UH > 2) do
    begin
      if __VectorTurn(Result[UH-3], Result[UH-2], Result[UH-1]) then Break;
      Dec(UH);
      Result[UH-1] := Result[UH];
    end;
  end;

  // Lower half..
  LH := 2;
  SetLength(Lower, H+1);
  Lower[0] := Pts[H];
  Lower[1] := Pts[H-1];
  for i:=2 to H do
  begin
    Lower[LH] := Pts[H-i];
    Inc(LH);
    while (LH > 2) do
    begin
      if __VectorTurn(Lower[LH-3], Lower[LH-2], Lower[LH-1]) then Break;
      Dec(LH);
      Lower[LH-1] := Lower[LH];
    end;
  end;

  Dec(LH);
  SetLength(Result, UH+LH);
  for i:=UH to (UH+LH)-1 do
    Result[i] := Lower[i-UH];

  SetLength(Lower, 0);
  SetLength(Pts, 0);
end;


{*
 Fills the resulting TPA with the given shape (TPA), and all the points within it.
 It requires you to give starting point, which is from where the floodfill is going to start.

 It's also recomended that you start within the shape.
*}
function FloodFillTPAEx(const TPA:TPointArray; const Start:TPoint; EightWay, KeepEdges:Boolean): TPointArray; StdCall;
var
  I,S,j,qsize,x,y,H,fj:Integer;
  queue,face:TPointArray;
  Matrix:T2DBoolArray;
  Area: TBox;
begin
  Area := GetTPABounds(TPA);
  Area.x2 := (Area.x2 - Area.x1) + 1;
  Area.y2 := (Area.y2 - Area.y1) + 1;
  Matrix := BoolMatrixNil(Area.x2+1, Area.y2+1);
  H := High(TPA);
  SetLength(Result, ((Area.x2+1)*(Area.y2+1))+H+1);

  for I:=0 to H do
  begin
    Matrix[(TPA[i].y - Area.y1)][(TPA[i].x - Area.x1)] := True;
    if KeepEdges then
      Result[i] := TPA[i];
  end;

  I := 0;
  if KeepEdges then I := H+1;
  qsize := Min(1000, (Area.x2)*(Area.y2));
  SetLength(queue, qsize+1);
  queue[0] := Point((Start.x - Area.x1), (Start.y - Area.y1));
  fj := 3;
  if EightWay then
    fj := 7;
  SetLength(Face, fj+1);
  S := 1;
  while (S > 0) do begin
    Dec(S);
    GetAdjacent(Face, queue[S], EightWay);
    for j:=0 to fj do begin
      x := face[j].x;
      y := face[j].y;
      if ((x >= 0) and (y >= 0) and (x <= Area.x2) and (y <= Area.y2)) then
      begin
        if Matrix[y][x] <> True then
        begin
          Matrix[y][x] := True;
          if (QSize <= S) then begin
            QSize := QSize+QSize;
            SetLength(queue, QSize);
          end;
          queue[S] := face[j];
          Inc(S);
          Result[i] := Point((x + Area.x1), (y + Area.y1));
          Inc(I);
        end;
      end;
    end;
  end;

  SetLength(Face, 0);
  SetLength(queue, 0);
  SetLength(Matrix, 0);
  SetLength(Result, I);
end;

function FloodFillTPA(const TPA:TPointArray; const Start:TPoint; EightWay:Boolean): TPointArray; StdCall;
begin
  if High(TPA) < 0 then Exit;
  Result := FloodFillTPAEx(TPA,Start,EightWay,False);
end;


{*
 Returns the outer points/contours of a shape with no gaps.
 If a shape has gaps then I suggest using TPAExtractShape and maybe Combined with ClusterTPA..
*}
function TPAOutline(const TPA:TPointArray): TPointArray; StdCall;
var
  i,j,h,x,y,l,hit,qsize:Integer;
  Matrix: T2DIntArray;
  adj: TPointArray;
  start,prev,endpt:TPoint;
  Area: TBox;
begin
  H := High(TPA);
  Area := GetTPABounds(TPA);
  Area.X2 := (Area.X2 - Area.X1) + 1;  //Width
  Area.Y2 := (Area.Y2 - Area.Y1) + 1;  //Height

  Matrix := IntMatrixNil(Area.X2+1, Area.Y2+1);

  start := Point(Area.X2, Area.Y2);
  for i:=0 to H do
  begin
    x := (TPA[i].x-Area.X1);
    y := (TPA[i].y-Area.Y1);
    Matrix[y][x] := 1;
    if y < Start.y then
      Start := Point(x,y);
  end;

  H := H*4;
  endpt := start;
  prev := Point(start.x, start.y-1);
  hit := 0;
  qsize := 1;
  SetLength(Result, qsize);
  Result[0] := Point((Start.x+Area.x1), (Start.y+Area.y1));
  SetLength(adj, 8);
  L := 0;
  for i:=0 to H do
  begin
    if ((endpt.x = prev.x) and (endpt.y = prev.y) and (i>1)) then begin
      if hit = 1 then Break;
      Inc(hit);
    end;
    RotatingAdjecent(adj, start, prev);
    for j:=0 to 7 do begin
      x := adj[j].x;
      y := adj[j].y;
      if (x >= 0) and (x < Area.X2) and
         (y >= 0) and (y < Area.Y2) then
        if Matrix[y][x] >= 1 then
        begin
          prev := start;
          start := adj[j];
          if Matrix[y][x]=1 then
          begin
            Inc(L);
            if (QSize <= L) then begin
              QSize := QSize+QSize;
              SetLength(Result, QSize);
            end;
            Result[L-1] := Point((Start.x+Area.x1), (Start.y+Area.y1));
            Matrix[y][x] := 2;
          end;
          break;
        end;
    end;
  end;
  if L = 0 then Inc(L);
  SetLength(Result, L);
  SetLength(Adj, 0);
  SetLength(Matrix, 0);
end;


{*
 Returns the border outside your shape.
 For multiple shapes, I would suggest ClusterTPA(Dist = 1, 8way=False) first..
 then grab borders of the shapes you want.
*}
function TPABorder(const TPA:TPointArray): TPointArray; StdCall;
var
  i,j,h,x,y,l,hit,qsize:Integer;
  Matrix: T2DIntArray;
  adj: TPointArray;
  start,prev,endpt:TPoint;
  Area: TBox;
  isset:Boolean;
begin
  H := High(TPA);
  Area := GetTPABounds(TPA);
  Area.X2 := (Area.X2 - Area.X1) + 3;  //Width
  Area.Y2 := (Area.Y2 - Area.Y1) + 3;  //Height
  Area.X1 := Area.X1 - 1;
  Area.Y1 := Area.Y1 - 1;

  Matrix := IntMatrixNil(Area.X2+1, Area.Y2+1);

  start := Point(Area.X2, Area.Y2);
  for i:=0 to H do
    Matrix[(TPA[i].y-Area.Y1)][(TPA[i].x-Area.X1)] := 1;

  //find FIRST starting y coord.
  Isset := False;
  Start := Point(Area.X2, Area.Y2);
  for y:=0 to Area.Y2-1 do begin
    for x:=0 to Area.X2-1 do
      if Matrix[y][x] <> 0 then
      begin
        Start := Point(x,y);
        Isset := True;
        Break;
      end;
    if Isset then Break;
  end;

  H := H*4;
  endpt := Start;
  prev := Point(start.x, start.y-1);
  hit := 0;
  qsize := 1;
  SetLength(Result, qsize);
  SetLength(adj, 8);
  L := 0;
  for i:=0 to H do
  begin
    if ((endpt.x = start.x) and (endpt.y = start.y) and (i>1)) then begin
      if hit = 1 then Break;
      Inc(hit);
    end;
    RotatingAdjecent(adj, start, prev);
    for j:=0 to 7 do begin
      x := adj[j].x;
      y := adj[j].y;
      if (x >= 0) and (x < Area.X2) and
         (y >= 0) and (y < Area.Y2) then
        if Matrix[y][x] <= 0 then
        begin
          if Matrix[y][x] = 0 then
          begin
            Inc(L);
            if (QSize <= L) then begin
              QSize := QSize+QSize;
              SetLength(Result, QSize);
            end;
            Result[L-1] := Point((adj[j].x+Area.x1), (adj[j].y+Area.y1));
            Dec(Matrix[y][x]);
          end;
        end else if Matrix[y][x] >= 1 then
        begin
          prev := start;
          start := adj[j];
          Break;
        end;
    end;
  end;
  SetLength(Result, L);
  SetLength(Adj, 0);
  SetLength(Matrix, 0);
end;


{*
 FloodFills a _Polygon_, the result in other words are all the points on and in the edges of the polygon.
 Should be stable.
*}
function FloodFillPolygon(const Poly:TPointArray; EightWay:Boolean): TPointArray; StdCall;
begin
  if High(Poly) < 0 then Exit;
  Result := FloodFillTPAEx(TPABorder(ConnectTPA(Poly)), Poly[0], EightWay, False);
end;


{*
 ClusterTPA is a `complex` function, it's action is the same as SplitTPA(Ex) seen in
 Simba, and SCAR (Macro-programs), but unlike those, this one performce in O(n)-time, while
 SplitTPA(ex) has a time-complexity of O(n^2).
 
 In short this algorithm uses a 2D-Matrix to cluster together the points that are 
 within a given distance (Distx,Disty) from each other. It then returns 2D TPoint Array (T2DPointArray).
*}
function ClusterTPAEx(const TPA: TPointArray; Distx,Disty: Integer; EightWay:Boolean): T2DPointArray; StdCall;
var
  W,H,i,x,y,rw,rh,x1,y1:Integer;
  R,qsize,fsize,Count,S,j,L:Integer;
  Area:TBox;
  Matrix,Table:T2DIntArray;
  queue, face:TPointArray;
  pt,adj:TPoint;
begin
  Area := GetTPABounds(TPA);
  Area.x1 := Area.x1 - 3;
  Area.y1 := Area.y1 - 3;
  W := (Area.x2 - Area.x1) + 1;
  H := (Area.y2 - Area.y1) + 1;
  if Distx > W then Distx := W;
  if Disty > H then Disty := H;
  RH := H-1;
  RW := W-1;
  Count := 0;
  L := High(TPA);
  SetLength(Matrix, H+2, W+2);

  //-----------
  //Method depends on a lot of things, tho I just estimate it..
  case (((RW*RH)*8) < (L*(Distx+Disty))) of
   False:
    begin
      for i:=0 to L do
      begin
        pt.x := (TPA[i].x - Area.X1);
        pt.y := (TPA[i].y - Area.Y1);
        x1 := Min(RW, pt.x + DistX - 1);
        y1 := Min(RH, pt.y + DistY - 1);
        for x:=pt.x to x1 do begin
          Matrix[pt.y][x] := -2;
          Matrix[y1][x] := -2;
        end;
        for y:=pt.y to y1 do begin
          Matrix[y][pt.x] := -2;
          Matrix[y][x1] := -2;
        end;
      end;
    end;

   True:
    begin
      SetLength(Table, (H+2), (W+2));
      for i:=0 to L do
      begin
        x := (TPA[i].x - Area.X1);
        y := (TPA[i].y - Area.Y1);
        Matrix[y][x] := 1;
        Table[y][x+1] := 1;
      end;
      for y:=0 to RH do
        for x:=0 to RW do
          Table[y+1][x+1] := (Table[y+1][x] + Table[y][x+1] - Table[y][x] + Matrix[y][x]);
      for y:=1 to RH do begin
        y1 := Min(H, y + DistY);
        for x:=1 to RW do begin
          x1 := Min(W, x + DistX);
          R := (Table[y][x] + Table[y1][x1] - Table[y1][x] - Table[y][x1]);
          if R > 0 then begin
            Matrix[y][x] := -2;
          end else
            Matrix[y][x] := -99;
        end;
      end;
      SetLength(Table, 0);
    end;
  end;


  //--------------
  //Simply floodfill the resulting boxes.
  qsize := L;
  SetLength(queue, qsize+1);

  fsize := 7;
  if EightWay = False then fsize := 3;
  SetLength(Face, fsize+1);

  for i:=0 to L do
  begin
    pt.x := (TPA[i].x - Area.X1);
    pt.y := (TPA[i].y - Area.Y1);
    if Matrix[pt.y][pt.x] = -2 then
    begin
      Matrix[pt.y][pt.x] := Count;
      queue[0] := pt;
      S := 1;
      while (s > 0) do
      begin
        Dec(S);
        GetAdjacent(Face, queue[S], EightWay);
        for j:=0 to fsize do
        begin
          adj := face[j];
          if Matrix[adj.y][adj.x] = -2 then
          begin
            Matrix[adj.y][adj.x] := Count;
            if QSize <= S then
            begin
              QSize := QSize+QSize;
              SetLength(queue, QSize);
            end;
            queue[S] := adj;
            Inc(S);
          end;
        end;
      end;
      Count := Count + 1;
    end;
  end;
  SetLength(Face, 0);
  SetLength(queue, 0);
  
  //-----------
  // Creating the result.
  SetLength(Result, Count);
  SetLength(Table, Count, 2);
  for i:=0 to L do
  begin
    pt := TPA[i];
    J := Matrix[(pt.y-Area.Y1)][(pt.x-Area.X1)];
    if J >= 0 then
    begin
      S := Table[J][0];
      Inc(Table[J][1]);
      R := Table[J][1];
      if S <= R then
      begin
        Table[J][0] := R+R;
        SetLength(Result[J], R+R+1);
      end;
      Result[J][R-1] := PT;
    end;
  end;
  for i:=0 to Count-1 do
    SetLength(Result[I], Table[i][1]);

  SetLength(Table, 0);
  SetLength(Matrix, 0);
end;


//-------------------------------------
function ClusterTPA(const TPA: TPointArray; Distance: Integer; EightWay:Boolean): T2DPointArray; StdCall;
begin
  Result := ClusterTPAEx(TPA, Distance,Distance, EightWay);
end;



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
  Area := GetTPABounds(TPA);
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
