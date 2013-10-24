Unit XT_Imaging;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 Copyright (c) 2013, Jarl K. <Slacky> Holta || http://github.com/WarPie
 All rights reserved.
 For more info see: Copyright.txt
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
interface
uses
  XT_Types, Math;

procedure ImBlur(var ImgArr:T2DIntArray; Radius:Integer); StdCall;
function ImThreshold(const ImgArr:T2DIntArray; Threshold, Alpha, Beta:Byte): T2DByteArray; StdCall;
function ImThresholdAdaptive(const ImgArr:T2DIntArray; Alpha, Beta: Byte; Method:TThreshMethod; C:Integer): T2DByteArray; StdCall;
function ImFindContours(const ImgArr:T2DByteArray; Outlines:Boolean): T2DPointArray; StdCall;
function ImCEdges(const ImgArr: T2DIntArray; MinDiff: Integer): TPointArray; StdCall;  

//--------------------------------------------------
implementation

uses
  XT_Collection, XT_Points, XT_ColorMath;

{*
 Function should populate a (1x1, 3x3, 5x5, 7x7...) matrix with circular weight corresponding to indice.
 Will be used in functions that does a convolution-process.
 Note that the sum of all elements of this matrix is 1.0.
*}
procedure __CovolveFilter(var Filter:T2DExtArray; BoxSize:Integer); Inline;
begin
  //TBA...
end; 
  
{*
 Appends a blurfilter to the Matrix/Image array. Sadly i've made it so that it requres a litte much memory and is a lil slow.. :E
 Could have used a Gaussian Blur.. But somehow I ended up with this.
*}
procedure ImBlur(var ImgArr:T2DIntArray; Radius:Integer); StdCall;
var
  table,xo: Array of T2DIntArray;
  y0,x0,y1,x1,x,y,w,h: Integer;
  r,g,b:Integer;
  AT,BT,CT,DT:TIntArray;
  LMax: Extended;
begin
  W := High(ImgArr[0]);
  H := High(ImgArr);
  SetLength(Table, H+2, W+2, 3);
  SetLength(XO, H+2, W+2, 3);
  for y:=0 to H do
    for x:=0 to W do
    begin
      R := (ImgArr[y][x] and $FF);
      G := ((ImgArr[y][x] shr 8) and $FF);
      B := ((ImgArr[y][x] shr 16) and $FF);
      Table[y+1][x+1][0] := (Table[y+1][x][0] + Table[y][x+1][0] - Table[y][x][0] + R);
      Table[y+1][x+1][1] := (Table[y+1][x][1] + Table[y][x+1][1] - Table[y][x][1] + G);
      Table[y+1][x+1][2] := (Table[y+1][x][2] + Table[y][x+1][2] - Table[y][x][2] + B);
    end;

  SetLength(AT, 3); SetLength(BT, 3);
  SetLength(CT, 3); SetLength(DT, 3);
  LMax := 0;
  for y:=0 to H do
  begin
    y0 := Max(0, y - radius);
    y1 := Min(h, y + radius + 1);
    for x:=0 to W do
    begin
      x0 := Max(0, x - radius);
      x1 := Min(W, x + radius + 1);
      AT := Table[y0][x0];
      BT := Table[y1][x1];
      CT := Table[y1][x0];
      DT := Table[y0][x1];
      R := (AT[0] + BT[0] - CT[0] - DT[0]);
      G := (AT[1] + BT[1] - CT[1] - DT[1]);
      B := (AT[2] + BT[2] - CT[2] - DT[2]);
      XO[y][x][0] := R; XO[y][x][1] := G; XO[y][x][2] := B;
      R := Max(Max(R,G), B);
      if LMax < R then LMax := R;
    end;
  end;
  SetLength(Table, 0);

  LMax := 255 / LMax;
  for y:=0 to H do
    for x:=0 to W do
      ImgArr[y][x] := (Round(LMax*XO[y][x][0])) or (Round(LMax*XO[y][x][1]) ShL 8) or (Round(LMax*XO[y][x][2]) ShL 16);
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
  Dec(W); Dec(H);
  for x:=0 to W do
    for y:=0 to H do
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
  SetLength(Temp, H+2,W+2);
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
          Temp[y+1][x+1] := Color;
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
          Temp[y+1][x+1] := Color;
          if Color < IMin then
            IMin := Color
          else if Color > IMax then
            IMax := Color;
        end;
      if (C < 0) then Threshold := ((IMax+IMin) div 2) - Abs(C)
      else Threshold := ((IMax+IMin) div 2) + C;
    end;
  end;
  Threshold := Max(0, Min(Threshold, 255)); //In range 0..255.
  
  for i:=0 to (Threshold-1) do Tab[i] := Alpha;
  for i:=Threshold to 255 do Tab[i] := Beta;  
  
  for x:=1 to W do
    for y:=1 to H do
      Result[y-1][x-1] := Tab[Temp[y][x]];
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