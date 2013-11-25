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
function ImBrighten(ImgArr:T2DIntArray; Amount:Extended): T2DIntArray; StdCall;
function ImEnhance(ImgArr:T2DIntArray; Enhancement:Byte; C:Extended): T2DIntArray; StdCall;
function ImThreshold(const ImgArr:T2DIntArray; Threshold, Alpha, Beta:Byte; Invert:Boolean): T2DIntArray; StdCall;
function ImThresholdAdaptive(const ImgArr:T2DIntArray; Alpha, Beta: Byte; Invert:Boolean; Method:TThreshMethod; C:Integer): T2DIntArray; StdCall;
function ImFindContours(const ImgArr:T2DIntArray; Outlines:Boolean): T2DPointArray; StdCall;
function ImCEdges(const ImgArr: T2DIntArray; MinDiff: Integer): TPointArray; StdCall;
procedure ImResize(var ImgArr:T2DIntArray; NewW, NewH: Integer; Method:TResizeMethod); StdCall;


//--------------------------------------------------
implementation

uses
  XT_Matrix, XT_Points, XT_ColorMath;


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
 Brightens the image or darkens if negative "amount" is given.
*}
function ImBrighten(ImgArr:T2DIntArray; Amount:Extended): T2DIntArray; StdCall;
var
  W,H,x,y,R,G,B:Integer;
  cH,cS,cV:Extended;
begin
  W := Length(ImgArr[0]);
  H := Length(ImgArr);
  SetLength(Result, H,W);

  Dec(W); 
  Dec(H);
  for y:=0 to H do
    for x:=0 to W do
    begin
      ColorToHSV(ImgArr[y][x], cH,cS,cV);
      cV := cV+Amount;
      if (cV < 0.0) then cV := 0
      else if (cV > 1.0) then cV := 1.0;
      HSVToRGB(cH,cS,cV, R,G,B);
      Result[y][x] := (R) or (G shl 8) or (B shl 16);
    end;
end;


{*
 Enhances colors in the image by a given value.
 @params:
   Enhancement: How much to substraact or add to the color.
   C: Based on the "mid"-value (127), if color is bellow then it gets weakened,
      if it's above then it gets enhanced.
*}
function ImEnhance(ImgArr:T2DIntArray; Enhancement:Byte; C:Extended): T2DIntArray; StdCall;
var
  W,H,x,y,R,G,B:Integer;
  mid: Single;
begin
  W := Length(ImgArr[0]);
  H := Length(ImgArr);
  SetLength(Result, H,W);

  Mid := 127 * C;
  Dec(W);
  Dec(H);
  for y:=0 to H do
    for x:=0 to W do
    begin
      ColorToRGB2(ImgArr[y][x], R,G,B);

      if R > mid then begin
        R := R + Enhancement;
        if (R > 255) then R:=255;
      end else begin
        R := R - Enhancement;
        if (R < 0) then R:=0;
      end;
      
      if G > mid then begin 
        G := G + Enhancement;
        if (G > 255) then G:=255;
      end else begin
        G := G - Enhancement;
        if (G < 0) then G:=0;
      end;
      
      if B > mid then begin
        B := B + Enhancement;
        if (B > 255) then B:=255;
      end else begin
        B := B - Enhancement;
        if (B < 0) then B:=0;
      end;
      
      Result[y][x] := (R) or (G shl 8) or (B shl 16);
    end;
end;


{*
 Given a threshold this function checks all the colors, and them who goes bellow `Threshold` will be set to `Alpha`
 the colors above or equal to the threshold will be set to `Beta`.
 @params:
    Threshold: Threshold value.
    Alpha: Minvalue for result
    Beta: Maxvalue for result
    Invert: Bellow Mean is set to Beta, rather then Alpha.
*}
function ImThreshold(const ImgArr:T2DIntArray; Threshold, Alpha, Beta: Byte; Invert:Boolean): T2DIntArray; StdCall;
var
  W,H,x,y,i:Integer;
  Tab: Array [0..256] of Byte;
begin
  if Alpha >= Beta then Exit;
  if Alpha > Beta then ExchBt(Alpha, Beta); 

  W := Length(ImgArr[0]);
  H := Length(ImgArr);
  SetLength(Result, H,W);
  
  if Invert then ExchBt(Alpha, Beta); 
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
    Invert: Bellow Mean is set to Beta, rather then Alpha.
    Method: TM_Mean or TM_MinMax
    C: Substract or add to the mean.
*}
function ImThresholdAdaptive(const ImgArr:T2DIntArray; Alpha, Beta: Byte; Invert:Boolean; Method:TThreshMethod; C:Integer): T2DIntArray; StdCall;
var
  W,H,x,y,i:Integer;
  Color,IMin,IMax: Byte;
  Threshold,Counter: Integer;
  Temp: T2DByteArray;
  Tab: Array [0..256] of Byte;   
begin
  if Alpha >= Beta then Exit;
  if Alpha > Beta then ExchBt(Alpha, Beta); 
  
  W := Length(ImgArr[0]);
  H := Length(ImgArr);
  SetLength(Result, H,W);
  SetLength(Temp, H,W);
  Dec(W); 
  Dec(H);
  
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
          Color := ColorToGray(ImgArr[y][x]);
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
  if Invert then ExchBt(Alpha, Beta);
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
  
  This will probably be changed to something more "proper".
}
function ImFindContours(const ImgArr:T2DIntArray; Outlines:Boolean): T2DPointArray; StdCall;
var
  W,H,j,i,x,y:Integer;
  TPA:TPointArray;
begin
  W := High(ImgArr[0]);
  H := High(ImgArr);
  SetLength(TPA, W*H);
  j := 0;
  for y:=1 to H do
    for x:=1 to W do
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
  for Y:=0 to Height do 
    for X:=0 to Width do
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



//-- Image resizing ----------------------------------------------------------||

(*
 NEAREST NEIGHBOR
*)
function ResizeMat_NEAREST(ImgArr:T2DIntArray; NewW, NewH: Integer): T2DIntArray;
var
  W,H,x,y,i,j: Integer;
  ratioX,ratioY: Single;
begin
  W := Length(ImgArr[0]);
  H := Length(ImgArr);
  ratioX := (W-1) / NewW;
  ratioY := (H-1) / NewH;
  SetLength(Result, NewH, NewW);
  Dec(NewW);
  for i:=0 to NewH-1 do 
  for j:=0 to NewW do
  begin
    x := Trunc(ratioX * j);
    y := Trunc(ratioY * i);
    Result[i][j] := ImgArr[y][x];
  end;
end;




(*
 BILINEAR: I guess one could call the result decent.. But honestly, for
           upscaling, I almost rather see my self scaling with NN + Blur..
*)
function ResizeMat_BILINEAR(ImgArr:T2DIntArray; NewW, NewH: Integer): T2DIntArray;
var
  W,H,x,y,p0,p1,p2,p3,i,j: Integer;
  ratioX,ratioY,dx,dy: Single;
  R,G,B: Single;
begin
  W := Length(ImgArr[0]);
  H := Length(ImgArr);
  ratioX := (W-1) / NewW;
  ratioY := (H-1) / NewH;
  SetLength(Result, NewH, NewW);
  Dec(NewW);
  for i:=0 to NewH-1 do 
  for j:=0 to NewW do
  begin
    x := Trunc(ratioX * j);
    y := Trunc(ratioY * i);
    dX := ratioX * j - x;
    dY := ratioY * i - y;

    p0 := ImgArr[y][x];
    p1 := ImgArr[y][x+1];
    p2 := ImgArr[y+1][x];
    p3 := ImgArr[y+1][x+1];

    R := (p0 and $FF) * (1-dX) * (1-dY) +
         (p1 and $FF) * (dX * (1-dY)) +
         (p2 and $FF) * (dY * (1-dX)) +
         (p3 and $FF) * (dX * dY);

    G := ((p0 shr 8) and $FF) * (1-dX) * (1-dY) +
         ((p1 shr 8) and $FF) * (dX * (1-dY)) +
         ((p2 shr 8) and $FF) * (dY * (1-dX)) +
         ((p3 shr 8) and $FF) * (dX * dY); 
         
    B := ((p0 shr 16) and $FF) * (1-dX) * (1-dY) +
         ((p1 shr 16) and $FF) * (dX * (1-dY)) +
         ((p2 shr 16) and $FF) * (dY * (1-dX)) +
         ((p3 shr 16) and $FF) * (dX * dY);

    Result[i][j] := Trunc(R) or Trunc(G) shl 8 or Trunc(B) shl 16;
  end;
end;




//Used in bicubic interpolation.
//I could reqrite it to function without this, and gain some speed, but...
function _ImGetColor(ImgArr:T2DIntArray; W,H, X,Y, C:Integer): Byte; Inline;
begin
  Result := 0;
  if (x > -1) and (x < W) and (y > -1) and (y < H) then
    case C of
      0: Result := ImgArr[y][x] and $FF;
      1: Result := (ImgArr[y][x] shr 8) and $FF;
      2: Result := (ImgArr[y][x] shr 16) and $FF;  
    end; 
end; 

(*
 BICUBIC: This got slower then expected, also worse result then expected...
          Kinda get that it's not faster, no "deep" optimizations are used.
          
          It would probably be better if I converted the image to CIE-LAB first..
          That would requires some changes to the formula tho..
*)
function ResizeMat_BICUBIC(ImgArr:T2DIntArray; NewW, NewH: Integer): T2DIntArray;
var
  W,H,x,y,i,j,k,jj,yy,col: Integer;
  a0,a1,a2,a3,d0,d2,d3:Single;
  ratioX,ratioY,dx,dy: Single;
  C: Array of Single;
  Chan:TByteArray;
begin
  W := Length(ImgArr[0]);
  H := Length(ImgArr);
  ratioX := (W-1) / NewW;
  ratioY := (H-1) / NewH;

  SetLength(Result, NewH, NewW);
  SetLength(C, 4);
  SetLength(Chan, 3);
  Dec(NewH);
  Dec(NewW);
  
  for i:=0 to NewH do 
  for j:=0 to NewW do
  begin
    x := Trunc(ratioX * j);
    y := Trunc(ratioY * i);
    dX := ratioX * j - x;
    dY := ratioY * i - y;
    for k := 0 to 2 do
    for jj:= 0 to 3 do
    begin
      yy := y - 1 + jj;
      a0 := _ImGetColor(ImgArr, W, H, x+0, yy, k);
      d0 := _ImGetColor(ImgArr, W, H, x-1, yy, k) - a0;
      d2 := _ImGetColor(ImgArr, W, H, x+1, yy, k) - a0;
      d3 := _ImGetColor(ImgArr, W, H, x+2, yy, k) - a0;
      a1 := (-1.0 / 3 * d0 + d2 - 1.0 / 6 * d3);
      a2 := (1.0 / 2 * d0 + 1.0 / 2 * d2);
      a3 := (-1.0 / 6 * d0 - 1.0 / 2 * d2 + 1.0 / 6 * d3);
      C[jj] := (a0 + a1 * dx + a2 * dx * dx + a3 * dx * dx * dx);

      d0 := C[0] - C[1];
      d2 := C[2] - C[1];
      d3 := C[3] - C[1];
      a1 := (-1.0 / 3 * d0 + d2 -1.0 / 6 * d3);
      a2 := (1.0 / 2 * d0 + 1.0 / 2 * d2);
      a3 := (-1.0 / 6 * d0 - 1.0 / 2 * d2 + 1.0 / 6 * d3);
      Col := Trunc(C[1] + a1 * dy + a2 * dy * dy + a3 * dy * dy * dy);
      if (Col>255) then Col := 255
      else if (Col<0) then Col := 0;
      Chan[k] := Col;
    end;
    
    Result[i][j] := (Chan[0]) or (Chan[1] shl 8) or (Chan[2] shl 16);
  end;
end;


(*
 Resize a matrix/ImArray
 @Methods: RM_NEAREST, RM_BILINEAR and RM_BICUBIC.
*)
procedure ImResize(var ImgArr:T2DIntArray; NewW, NewH: Integer; Method:TResizeMethod); StdCall;
begin
  case Method of
    RM_NEAREST: ImgArr := ResizeMat_NEAREST(ImgArr, NewW, NewH);
    RM_BILINEAR:ImgArr := ResizeMat_BILINEAR(ImgArr, NewW, NewH);
    RM_BICUBIC: ImgArr := ResizeMat_BICUBIC(ImgArr, NewW, NewH);
  end;
end;

end.