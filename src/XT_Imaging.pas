Unit XT_Imaging;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 Copyright (c) 2013, Jarl K. <Slacky> Holta || http://github.com/WarPie
 All rights reserved.
 For more info see: Copyright.txt
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
interface
uses
  XT_Types, XT_Standard, Math;

function ImBlurFilter(ImgArr: T2DIntArray; Block:Integer): T2DIntArray; StdCall;
function ImMedianFilter(ImgArr: T2DIntArray; Block:Integer): T2DIntArray; StdCall;
function ImThreshold(const ImgArr:T2DIntArray; Threshold, Alpha, Beta:Byte): T2DByteArray; StdCall;
function ImThresholdAdaptive(const ImgArr:T2DIntArray; Alpha, Beta: Byte; Method:TThreshMethod; C:Integer): T2DByteArray; StdCall;
function ImFindContours(const ImgArr:T2DByteArray; Outlines:Boolean): T2DPointArray; StdCall;
function ImCEdges(const ImgArr: T2DIntArray; MinDiff: Integer): TPointArray; StdCall;  

//--------------------------------------------------
implementation

uses
  XT_Collection, XT_Points, XT_ColorMath;


{*
 Returns a blurred version of the Matrix/ImgArray.
 Block is the radius of the blur: 3,5,7,9...
*}
function ImBlurFilter(ImgArr: T2DIntArray; Block:Integer): T2DIntArray; StdCall;
var
  W,H,x,y,mid,fx,fy,size:Integer;
  R,G,B,color,lx,ly,hx,hy:Integer;
begin
  Size := (Block*Block);
  if (Size<=1) or (Block mod 2 = 0) then Exit;
  W := High(ImgArr[0]);
  H := High(ImgArr);
  SetLength(Result, H+1,W+1);
  mid := Block div 2;

  
  for y:=0 to H do
  begin
    ly := Max(0,y-mid);
    hy := Min(H,y+mid);
    for x:=0 to W do
    begin
      lx := Max(0,x-mid);
      hx := Min(W,x+mid);
      R := 0; G := 0; B := 0;
      for fy:=ly to hy do
        for fx:=lx to hx do
        begin
          Color := ImgArr[fy][fx];
          R := R + (Color and $FF);
          G := G + ((Color shr 8) and $FF);
          B := B + ((Color shr 16) and $FF);
        end;
      Result[y][x] := (R div size) or
                      ((G div size) shl 8) or
                      ((B div size) shl 16);
    end;
  end;
end;


{*
 Filter a matrix/ImgArr with a Median Filter.
 Block is the radius of the filter, 3,5,7,9...
*}
{** __PRIVATE__ **}
procedure __SortRGB(var Arr, Weight: TIntArray); Inline;
var CurIdx, TmpIdx, Hi: Integer;
begin
  Hi := High(Arr);
  for CurIdx := 1 to Hi do
    for TmpIdx := CurIdx downto 1 do
    begin
      if not (Weight[TmpIdx] < Weight[TmpIdx - 1]) then
        Break;
      ExchI(Arr[TmpIdx], Arr[TmpIdx - 1]);
      ExchI(Weight[TmpIdx], Weight[TmpIdx - 1]);
    end;
end;

function ImMedianFilter(ImgArr: T2DIntArray; Block:Integer):T2DIntArray; StdCall;
var
  W,H,j,x,y,fx,fy,low,mid,size,color:Integer;
  lx,ly,hx,hy:Integer;
  Filter,Colors:TIntArray;
begin
  Size := Block * Block;
  if (Size<=1) or (Block mod 2 = 0) then Exit;
  W := High(ImgArr[0]);
  H := High(ImgArr);
  SetLength(Result, H+1,W+1);
  SetLength(Filter, Size+1);
  SetLength(Colors, Size+1);
  low := Block div 2;
  mid := Size div 2;
  
  for y:=0 to H do
  begin
    ly := Max(0,y-low);
    hy := Min(H,y+low);
    for x:=0 to W do
    begin
      j := 0;
      lx := Max(0,x-low);
      hx := Min(W,x+low);
      for fy:=ly to hy do
        for fx:=lx to hx do
        begin
          Color := ImgArr[fy][fx];
          Filter[j] := ColorToGrayL(Color);
          Colors[j] := Color;
          Inc(j);
        end;
      __SortRGB(Colors, Filter);
      Result[y][x] := Colors[mid];
    end;
  end;
  SetLength(Colors, 0);
  SetLength(Filter, 0);
end;


{*
 Given a threshold this function checks all the colors, and them who goes bellow `Threshold` will be set to `Alpha`
 the colors above or equal to the threshold will be set to `Beta`.
 @params:
    Threshold: Threshold value.
    Alpha: Minvalue for result
    Beta: Maxvalue for result
*}
function ImThreshold(const ImgArr:T2DIntArray; Threshold, Alpha, Beta: Byte): T2DByteArray; StdCall;
var
  W,H,x,y,i:Integer;
  Tab: Array [0..256] of Byte;
begin
  if Alpha >= Beta then Exit;
  if Alpha > Beta then begin
    X := Beta;
    Beta := Alpha;
    Alpha := X;
  end;
  W := Length(ImgArr[0]);
  H := Length(ImgArr);
  SetLength(Result, H,W);
  
  for i:=0 to (Threshold-1) do Tab[i] := Alpha;
  for i:=Threshold to 255 do Tab[i] := Beta;
  Dec(W); 
  Dec(H);
  
  for y:=0 to H do
    for x:=0 to W do
      Result[y][x] := Tab[ColorToGrayL(ImgArr[y][x])];
end;


{*
 This function first finds the Mean of the image, and set the threshold to it. Again: colors bellow the Threshold will be set to `Alpha`
 the colors above or equal to the Mean/Threshold will be set to `Beta`.
 @todo: Test to use a matrix filter to reduce noice of size: 3x3, 5x5, 7x7 etc..
 @params:
    Alpha: Minvalue for result
    Beta: Maxvalue for result
    Method: TM_Mean or TM_MinMax
    C: Substract or add to the mean.
*}
function ImThresholdAdaptive(const ImgArr:T2DIntArray; Alpha, Beta: Byte; Method:TThreshMethod; C:Integer): T2DByteArray; StdCall;
var
  W,H,x,y,i:Integer;
  Color,IMin,IMax: Byte;
  Threshold,Counter: Integer;
  Temp: T2DByteArray;
  Tab: Array [0..256] of Byte;   
begin
  if Alpha >= Beta then Exit;
  if Alpha > Beta then begin
    X := Beta;
    Beta := Alpha;
    Alpha := X;
  end;
  W := Length(ImgArr[0]);
  H := Length(ImgArr);
  SetLength(Result, H,W);
  SetLength(Temp, H,W);
  Dec(W); Dec(H);
  
  //Finding the threshold - While at it convert image to grayscale.
  Threshold := 0;
  Case Method of 
    //Find the Arithmetic Mean / Average.
    TM_Mean:
    begin
      for y:=0 to H do
      begin
        Counter := 0;
        for x:=0 to W do
        begin
          Color := ColorToGrayL(ImgArr[y][x]);
          Temp[y][x] := Color;
          Counter := Counter + Color;
        end;
        Threshold := Threshold + (Counter div W);
      end;
      if (C < 0) then Threshold := (Threshold div H) - Abs(C)
      else Threshold := (Threshold div H) + C;
    end;
    
    //Mean of Min and Max values
    TM_MinMax:
    begin
      IMin := ColorToGrayL(ImgArr[0][0]);
      IMax := IMin;
      for y:=0 to H do
        for x:=0 to W do
        begin
          Color := ColorToGrayL(ImgArr[y][x]);
          Temp[y][x] := Color;
          if Color < IMin then
            IMin := Color
          else if Color > IMax then
            IMax := Color;
        end;
      if (C < 0) then Threshold := ((IMax+IMin) div 2) - Abs(C)
      else Threshold := ((IMax+IMin) div 2) + C;
    end;
  end;
  
  Threshold := Max(0, Min(Threshold, 255)); //In range 0..255
  for i:=0 to (Threshold-1) do Tab[i] := Alpha;
  for i:=Threshold to 255 do Tab[i] := Beta;  
  for y:=0 to H do
    for x:=0 to W do
      Result[y][x] := Tab[Temp[y][x]];
  SetLength(Temp, 0);
end;


{
  ImgArr is treated as a binary array, so 0s will be left alone, and anything above 0 will be checked.
  You can use this with XT_Threshold or XT_ThresholdApdative.
}
function ImFindContours(const ImgArr:T2DByteArray; Outlines:Boolean): T2DPointArray; StdCall;
var
  W,H,j,i,x,y:Integer;
  TPA:TPointArray;
begin
  W := High(ImgArr[0]);
  H := High(ImgArr);
  SetLength(TPA, W*H);
  j := 0;
  for x:=1 to W do
    for y:=1 to H do
      if ImgArr[y][x] > 0 then
      begin
        TPA[j].x := x;
        TPA[j].y := y;
        Inc(j);
      end;
  SetLength(TPA, j);
  Result := ClusterTPA(TPA, 1, True);
  SetLength(TPA,0);
  if Outlines then
  begin
    for i:=0 to High(Result) do
      Result[i] := TPAOutline(Result[i]);
  end;
end;


{
  Given a matrix that represents an image this algorithm extacts the contrast edge points.
  The result is an Array of TPoint (TPointArray).
  Uses RGB and R,G and B are weighted equally.
}
function ImCEdges(const ImgArr: T2DIntArray; MinDiff: Integer): TPointArray; StdCall;
var
  X,Y,Width,Height,Len,QSize: Integer;
  R,G,B,R1,G1,B1:Byte;
  Hit:Boolean;
begin
  Width := High(ImgArr[0]);
  Height := High(ImgArr);
  MinDiff := Sqr(MinDiff) * 3;
  QSize := Min(1000, Width*Height);
  SetLength(Result, QSize+1);
  
  Len := 0;
  for X:=0 to Width do
    for Y:=0 to Height do 
    begin
      Hit := False;
      if ((X+1) < Width) then
      begin
        ColorToRGB(ImgArr[Y][X], R,G,B);
        ColorToRGB(ImgArr[Y][X+1], R1,G1,B1);
        if Sqr(R-R1)+Sqr(G-G1)+Sqr(B-B1) >= MinDiff then Hit := True;
      end;

      if ((Y+1) < Height) and Not(Hit) then 
      begin
        ColorToRGB(ImgArr[Y][X], R,G,B);
        ColorToRGB(ImgArr[Y+1][X], R1,G1,B1);
        if Sqr(R-R1)+Sqr(G-G1)+Sqr(B-B1) >= MinDiff then  Hit := True;
      end;
      
      if Hit then
      begin
        Result[Len] := Point(X,Y);
        Inc(Len);
        if QSize<=Len then
        begin
          QSize := QSize+QSize;
          SetLength(Result, QSize+1);
        end;
        Continue;
      end;
    end;

  SetLength(Result, Len);
end;

end.