Unit XT_Collection;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 CopyLeft Jarl "SLACKY" Holta - Released under Lazy-lisence which states:
 > As soon as it's released publicly, I do no longer OWN the code,
 > I however own my copy of it. I can only ask you to keep my credits.
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

interface
uses
  XT_Types, Math;


function IntMatrix(W,H,Init:Integer): T2DIntArray; StdCall;
function IntMatrixNil(W,H:Integer): T2DIntArray; StdCall;
function TPAToIntMatrix(const TPA:TPointArray; Init, Value:Integer; Align:Boolean): T2DIntArray; StdCall;
function TPAToIntMatrixNil(const TPA:TPointArray; Value:Integer; Align:Boolean): T2DIntArray; StdCall;
procedure IntMatrixSetPts(var Matrix:T2DIntArray; const Pts:TPointArray; Value:Integer; const Align:TPoint); StdCall;
function BoolMatrix(W,H:Integer;Init:Boolean): T2DBoolArray; StdCall;
function BoolMatrixNil(W,H:Integer): T2DBoolArray; StdCall;
function TPAToBoolMatrix(const TPA:TPointArray; Init, Value:Boolean; Align:Boolean): T2DBoolArray; StdCall;
function TPAToBoolMatrixNil(const TPA:TPointArray; Value:Boolean; Align:Boolean): T2DBoolArray; StdCall;
//Other----------->
procedure BoolMatrixSetPts(var Matrix:T2DBoolArray; const Pts:TPointArray; Value:Boolean; const Align:TPoint); StdCall;
function NormalizeATIA(const ATIA:T2DIntArray; Alpha, Beta:Integer): T2DIntArray; StdCall;
function ATIAGetIndices(const ATIA:T2DIntArray; const Indices:TPointArray): TIntArray; StdCall;
procedure DrawMatrixLine(var Mat:T2DIntArray; P1, P2: TPoint; Val:Integer); Inline;


//--------------------------------------------------
implementation

uses 
  XT_Points;


{*
 Quickly create a integer matrix of the size given my W,H, and initalize it with `init`.
*}
function IntMatrix(W,H,Init:Integer): T2DIntArray; StdCall;
var X,Y:Integer;
begin
  SetLength(Result, H, W);
  for Y:=0 to H-1 do
    for X:=0 to W-1 do
      Result[Y][X] := Init;
end;

{*
 Quickly create a integer matrix of the size given my W,H.
*}
function IntMatrixNil(W,H:Integer): T2DIntArray; StdCall;
begin
  SetLength(Result, H, W);
end;

{*
 Quickly create a integer matrix filled with the points given by TPA, align the points to [0][0] if needed.
 Initalizes it with the given initalizer.
*}
function TPAToIntMatrix(const TPA:TPointArray; Init, Value:Integer; Align:Boolean): T2DIntArray; StdCall;
var
  X,Y,Width,Height,H,i:Integer;
  Area:TBox;
begin
  H := High(TPA);
  Area := GetTPABounds(TPA);
  Width := (Area.X2 - Area.X1) + 1;  //Width
  Height := (Area.Y2 - Area.Y1) + 1;  //Height

  case Align of
    True:
      begin
        SetLength(Result, Height, Width);
        for Y:=0 to Height-1 do
          for X:=0 to Width-1 do
            Result[Y][X] := Init;
        for i:=0 to H do
          Result[TPA[i].y-Area.y1][TPA[i].x-Area.x1] := Value;
      end;
    False:
      begin
        SetLength(Result, Area.Y2+1);
        for Y:=0 to Area.Y2 do
        begin
          SetLength(Result[Y], Area.X2+1);
          for X:=0 to Area.X2 do
            Result[Y][X] := Init;
        end;
        for i:=0 to H do
          Result[TPA[i].y][TPA[i].x] := Value;
      end;
  end;
end;

{*
 Quickly create a integer matrix filled with the points given by TPA, align the points to [0][0] if needed.
 Initalizes it with "nil".
*}
function TPAToIntMatrixNil(const TPA:TPointArray; Value:Integer; Align:Boolean): T2DIntArray; StdCall;
var
  Y,Width,Height,H,i:Integer;
  Area:TBox;
begin
  H := High(TPA);
  Area := GetTPABounds(TPA);
  Width := (Area.X2 - Area.X1) + 1;  //Width
  Height := (Area.Y2 - Area.Y1) + 1;  //Height

  case Align of
    True:
      begin
        SetLength(Result, Height, Width);
        for i:=0 to H do
          Result[TPA[i].y-Area.y1][TPA[i].x-Area.x1] := Value;
      end;
    False:
      begin
        SetLength(Result, Area.Y2+1);
        for Y:=0 to Area.Y2 do
          SetLength(Result[Y], Area.X2+1);
        for i:=0 to H do
          Result[TPA[i].y][TPA[i].x] := Value;
      end;
  end;
end;

{*
 Set the matrix coords that match the given TPoints (minus `Align`) to `Value`...
*}
procedure IntMatrixSetPts(var Matrix:T2DIntArray; const Pts:TPointArray; Value:Integer; const Align:TPoint); StdCall;
var i: Integer;
begin
  for i := 0 to High(Pts) do
    Matrix[(Pts[i].y-Align.y)][(Pts[i].x-Align.x)] := Value;
end;



{*
 Quickly create a boolean matrix of the size given my W,H, and initalize it with `init`.
*}
function BoolMatrix(W,H:Integer;Init:Boolean): T2DBoolArray; StdCall;
var X,Y:Integer;
begin
  SetLength(Result, H, W);
  for Y:=0 to H-1 do
    for X:=0 to W-1 do
      Result[Y][X] := Init;
end;


{*
 Quickly create a boolean matrix of the size given my W,H.
*}
function BoolMatrixNil(W,H:Integer): T2DBoolArray; StdCall;
begin
  SetLength(Result, H, W);
end;


{*
 Quickly create a boolean matrix filled with the points given by TPA, align the points to [0][0] if needed.
 Initalizes it with the given initalizer.
*}
function TPAToBoolMatrix(const TPA:TPointArray; Init, Value:Boolean; Align:Boolean): T2DBoolArray; StdCall;
var 
  X,Y,Width,Height,H,i:Integer;
  Area:TBox;
begin
  H := High(TPA);
  Area := GetTPABounds(TPA);
  Width := (Area.X2 - Area.X1) + 1;  //Width
  Height := (Area.Y2 - Area.Y1) + 1;  //Height
  
  case Align of
    True:
      begin
        SetLength(Result, Height, Width);
        for Y:=0 to Height-1 do
          for X:=0 to Width-1 do
            Result[Y][X] := Init;
        for i:=0 to H do
          Result[TPA[i].y-Area.y1][TPA[i].x-Area.x1] := Value;
      end;
    False:
      begin
        SetLength(Result, Area.Y2+1);
        for Y:=0 to Area.Y2 do
        begin
          SetLength(Result[Y], Area.X2+1);
          for X:=0 to Area.X2 do
            Result[Y][X] := Init;
        end;
        for i:=0 to H do
          Result[TPA[i].y][TPA[i].x] := Value;
      end;
  end;
end;


{*
 Quickly create a boolean matrix filled with the points given by TPA, align the points to [0][0] if needed.
 Initalizes it with "nil".
*}
function TPAToBoolMatrixNil(const TPA:TPointArray; Value:Boolean; Align:Boolean): T2DBoolArray; StdCall;
var 
  Y,Width,Height,H,i:Integer;
  Area:TBox;
begin
  H := High(TPA);
  Area := GetTPABounds(TPA);
  Width := (Area.X2 - Area.X1) + 1;  //Width
  Height := (Area.Y2 - Area.Y1) + 1;  //Height
  
  case Align of
    True:
      begin
        SetLength(Result, Height, Width);
        for i:=0 to H do
          Result[TPA[i].y-Area.y1][TPA[i].x-Area.x1] := Value;
      end;
    False:
      begin
        SetLength(Result, Area.Y2+1);
        for Y:=0 to Area.Y2 do
          SetLength(Result[Y], Area.X2+1);
        for i:=0 to H do
          Result[TPA[i].y][TPA[i].x] := Value;
      end;
  end;
end;


{*
 Set the matrix coords that match the given TPoints (minus `Align`) to `Value`...
*}
procedure BoolMatrixSetPts(var Matrix:T2DBoolArray; const Pts:TPointArray; Value:Boolean; const Align:TPoint); StdCall;
var i: Integer;
begin
  for i := 0 to High(Pts) do
    Matrix[(Pts[i].y-Align.y)][(Pts[i].x-Align.x)] := Value;
end;



//---------------- OTHER -----------------
function NormalizeATIA(const ATIA:T2DIntArray; Alpha, Beta:Integer): T2DIntArray; StdCall;
var
  x,y,H,W: Integer;
  k,mx: Extended;
begin
  W := High(ATIA[0]);
  H := High(ATIA);
  mx := 0;
  for y:=0 to H do
    for x:=0 to W do
      if (ATIA[y][x] > mx) then
        mx := ATIA[y][x];

  Beta := Beta - Alpha;
  k := 0.0;
  if (mx > 0) then
    k := (Beta / mx);
  
  SetLength(Result, H+1,W+1);
  for y:=0 to H do
    for x:=0 to W do
      Result[y][x] := Alpha + Round(ATIA[y][x]*k);
end;


{*
  Returns the values at each given point (TPA), in the ATIA.
*}
function ATIAGetIndices(const ATIA:T2DIntArray; const Indices:TPointArray): TIntArray; StdCall;
var
  i,W,H,c,L:Integer;
begin
  L := High(Indices);
  W := High(ATIA[0]); 
  H := High(ATIA);
  SetLength(Result, L+1);
  c := 0;
  for i:=0 to L do
  begin 
    if (Indices[i].x >= 0) and (Indices[i].y >= 0) then
      if (Indices[i].x <= W) and (Indices[i].y <= H) then
      begin
        Result[c] := ATIA[Indices[i].y][Indices[i].x];
        Inc(c);
      end;
  end;
  SetLength(Result, c);
end;


{*
 Creates a line from P1 to P2. 
 Algorithm is based on Bresenham's line algorithm.
 @note, it draws the line to a 2D Integer Matrix. Used internally.
*}
procedure DrawMatrixLine(var Mat:T2DIntArray; P1, P2: TPoint; Val:Integer); Inline;
var
  dx,dy,step,I: Integer;
  rx,ry,x,y: Extended;
begin
  Mat[P1.y][P1.x] := Val;
  if (p1.x = p2.x) and (p2.y = p1.y) then
    Exit;

  dx := (P2.x - P1.x);
  dy := (P2.y - P1.y);
  if (Abs(dx) > Abs(dy)) then step := Abs(dx)
  else step := Abs(dy);

  rx := dx / step;
  ry := dy / step;
  x := P1.x;
  y := P1.y;
  for I:=1 to step do
  begin
    x := x + rx;
    y := y + ry;
    Mat[Round(y)][Round(x)] := Val;
  end;
end; 


end.





