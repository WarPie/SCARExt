Unit XT_Matrix;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 Copyright (c) 2013, Jarl K. <Slacky> Holta || http://github.com/WarPie
 All rights reserved.
 For more info see: Copyright.txt
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

interface
uses
  XT_Types, Math;

//General ----------->
function NewMatrix(W,H:Integer): T2DIntArray; StdCall;
function NewMatrixEx(W,H,Init:Integer): T2DIntArray; StdCall;
function TPAToMatrix(const TPA:TPointArray; Value:Integer; Align:Boolean): T2DIntArray; StdCall;
function TPAToMatrixEx(const TPA:TPointArray; Init, Value:Integer; Align:Boolean): T2DIntArray; StdCall;
procedure MatrixSetTPA(var Matrix:T2DIntArray; const TPA:TPointArray; Value:Integer; const Offset:TPoint); StdCall;
function NormalizeMat(const Mat:T2DIntArray; Alpha, Beta:Integer): T2DIntArray; StdCall;
procedure MatCombine(var Mat:T2DIntArray; const Mat2:T2DIntArray; Value:Integer); StdCall;
function MatGetValues(const Mat:T2DIntArray; const Indices:TPointArray): TIntArray; StdCall;
function MatGetCol(const Mat:T2DIntArray; Column:Integer): TIntArray; StdCall;
function MatGetRow(const Mat:T2DIntArray; Row:Integer): TIntArray; StdCall;
function MatGetCols(const Mat:T2DIntArray; FromCol, ToCol:Integer): T2DIntArray; StdCall;
function MatGetRows(const Mat:T2DIntArray; FromRow, ToRow:Integer): T2DIntArray; StdCall;
function MatGetArea(const Mat:T2DIntArray; x1,y1,x2,y2:Integer): T2DIntArray; StdCall;
function MatFromTIA(const TIA:TIntArray; Width,Height:Integer): T2DIntArray; StdCall;
procedure PadMatrix(var Matrix:T2DIntArray; HPad, WPad:Integer); StdCall;
function FloodFillMatrixEx(ImgArr:T2DIntArray; const Start:TPoint; EightWay:Boolean): TPointArray; StdCall;
procedure DrawMatrixLine(var Mat:T2DIntArray; P1, P2: TPoint; Val:Integer); Inline;


//--------------------------------------------------
implementation

uses 
  XT_Points, XT_TPointList;


{*
 Quickly create a integer matrix of the size given my W,H.
*}
function NewMatrix(W,H:Integer): T2DIntArray; StdCall;
begin
  SetLength(Result, H, W);
end;

  
{*
 Quickly create a integer matrix of the size given my W,H, and initalize it with `init`.
*}
function NewMatrixEx(W,H,Init:Integer): T2DIntArray; StdCall;
var X,Y:Integer;
begin
  SetLength(Result, H, W);
  for Y:=0 to H-1 do
    for X:=0 to W-1 do
      Result[Y][X] := Init;
end;


{*
 Quickly create a integer matrix filled with the points given by TPA, align the points to [0][0] if needed.
 Initalizes it with the given initalizer.
*}
function TPAToMatrixEx(const TPA:TPointArray; Init, Value:Integer; Align:Boolean): T2DIntArray; StdCall;
var
  X,Y,Width,Height,H,i:Integer;
  Area:TBox;
begin
  H := High(TPA);
  Area := TPABounds(TPA);
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
function TPAToMatrix(const TPA:TPointArray; Value:Integer; Align:Boolean): T2DIntArray; StdCall;
var
  Y,Width,Height,H,i:Integer;
  Area:TBox;
begin
  H := High(TPA);
  Area := TPABounds(TPA);
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
procedure MatrixSetTPA(var Matrix:T2DIntArray; const TPA:TPointArray; Value:Integer; const Offset:TPoint); StdCall;
var i: Integer;
begin
  for i := 0 to High(TPA) do
    Matrix[(TPA[i].y-Offset.y)][(TPA[i].x-Offset.x)] := Value;
end;



{*
 ...
*}
function NormalizeMat(const Mat:T2DIntArray; Alpha, Beta:Integer): T2DIntArray; StdCall;
var
  x,y,H,W: Integer;
  k,mx: Extended;
begin
  W := High(Mat[0]);
  H := High(Mat);
  mx := 0;
  for y:=0 to H do
    for x:=0 to W do
      if (Mat[y][x] > mx) then
        mx := Mat[y][x];

  Beta := Beta - Alpha;
  k := 0.0;
  if (mx > 0) then
    k := (Beta / mx);
  
  SetLength(Result, H+1,W+1);
  for y:=0 to H do
    for x:=0 to W do
      Result[y][x] := Alpha + Round(Mat[y][x]*k);
end;


{*
 ...
*}
procedure MatCombine(var Mat:T2DIntArray; const Mat2:T2DIntArray; Value:Integer); StdCall;
var x,y,W,H:Integer;
begin
  W := Min(High(Mat[0]), High(Mat2[0])); 
  H := Min(High(Mat), High(Mat2)); 
  for y:=0 to H do
    for x:=0 to W do
      if (Mat[y][x] = Value) then
        Mat[y][x] := Mat2[y][x];
end;


{*
  Returns the values at each given point (TPA), in the Matrix.
*}
function MatGetValues(const Mat:T2DIntArray; const Indices:TPointArray): TIntArray; StdCall;
var
  i,W,H,c,L:Integer;
begin
  L := High(Indices);
  W := High(Mat[0]); 
  H := High(Mat);
  SetLength(Result, L+1);
  c := 0;
  for i:=0 to L do
  begin 
    if (Indices[i].x >= 0) and (Indices[i].y >= 0) then
      if (Indices[i].x <= W) and (Indices[i].y <= H) then
      begin
        Result[c] := Mat[Indices[i].y][Indices[i].x];
        Inc(c);
      end;
  end;
  SetLength(Result, c);
end;


{*
  Returns the TIA containing all the values in the given column.
*}
function MatGetCol(const Mat:T2DIntArray; Column:Integer): TIntArray; StdCall;
var
  y,H:Integer;
begin
  H := High(Mat);
  SetLength(Result, H+1);
  for y:=0 to H do
    Result[y] := Mat[y][Column];
end;


{*
  Returns the TIA containing all the values in the given row.
*}
function MatGetRow(const Mat:T2DIntArray; Row:Integer): TIntArray; StdCall;
var
  x,W:Integer;
begin
  W := High(Mat[0]);
  SetLength(Result, W+1);
  for x:=0 to W do
    Result[x] := Mat[Row][x];
end;


{*
  Returns the Matrix containing all the values in the given columns.
*}
function MatGetCols(const Mat:T2DIntArray; FromCol, ToCol:Integer): T2DIntArray; StdCall;
var
  x,y,H:Integer;
begin
  ToCol := Min(ToCol, High(Mat[0]));
  H := High(Mat);
  SetLength(Result, H+1, ToCol-FromCol+1);
  for y:=0 to H do
    for x:=FromCol to ToCol do
      Result[y][x] := Mat[y][x];
end;


{*
  Returns the Mat containing all the values in the given rows.
*}
function MatGetRows(const Mat:T2DIntArray; FromRow, ToRow:Integer): T2DIntArray; StdCall;
var
  x,y,W:Integer;
begin
  W := High(Mat[0]);
  ToRow := Min(ToRow, High(Mat));
  SetLength(Result, ToRow-FromRow+1, W+1);
  for y:=FromRow to ToRow do
    for x:=0 to W do
      Result[y][x] := Mat[y][x];
end;


{*
  Returns the matrix containing all the values in the given box.
*}
function MatGetArea(const Mat:T2DIntArray; x1,y1,x2,y2:Integer): T2DIntArray; StdCall;
var
  x,y,W,H:Integer;
begin
  W := High(Mat[0]);
  H := High(Mat);
  x2 := Min(x2, W);
  y2 := Min(y2, H);
  SetLength(Result, y2-y1+1, x2-x1+1);
  for y:=y1 to y2 do
    for x:=x1 to x2 do
      Result[y][x] := Mat[y][x];
end;


{*
  ...
*}
function MatFromTIA(const TIA:TIntArray; Width,Height:Integer): T2DIntArray; StdCall;
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


{*
  Pads the matrix with zeroes from all sides.
*}
procedure PadMatrix(var Matrix:T2DIntArray; HPad, WPad:Integer); StdCall;
var 
  x,y,oldw,oldh,w,h:Integer;
  Temp:T2DIntArray;
begin
  OldW := Length(Matrix[0]);
  OldH := Length(Matrix);
  H := HPad+OldH+HPad;
  W := WPad+OldW+WPad;
  SetLength(Temp, H, W);  
  for y:=0 to OldH-1 do
    for x:=0 to OldW-1 do
      Temp[y+HPad][x+WPad] := Matrix[y][x];
  
  SetLength(Matrix, 0);
  Matrix := Temp;
end;


{*
 FloodFills the ImgArr, and returns the floodfilled points.
*}
function FloodFillMatrixEx(ImgArr:T2DIntArray; const Start:TPoint; EightWay:Boolean): TPointArray; StdCall;
var
  color,i,x,y,W,H,fj:Integer;
  face:TPointArray;
  Queue,Res: TPointList;
begin
  W := High(ImgArr[0]);
  H := High(ImgArr);

  fj := 3;
  if EightWay then fj := 7;
  SetLength(Face, fj+1);

  Queue.Init;
  Res.Init;
  Color := ImgArr[Start.y][Start.x];
  Queue.Append(Start);
  Res.Append(Start);
  while Queue.NotEmpty do
  begin
    GetAdjacent(Face, Queue.FastPop, EightWay);
    for i:=0 to fj do
    begin
      x := face[i].x;
      y := face[i].y;
      if ((x >= 0) and (y >= 0) and (x <= W) and (y <= H)) then
      begin
        if ImgArr[y][x] = color then
        begin
          ImgArr[y][x] := -1;
          Queue.Append(face[i]);
          Res.Append(face[i]);
        end;
      end;
    end;
  end;
  Queue.Free;
  SetLength(Face, 0);
  Result := Res.Clone;
  Res.Free;
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





