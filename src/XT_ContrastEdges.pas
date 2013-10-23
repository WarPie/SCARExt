Unit XT_ContrastEdges;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 CopyLeft Jarl "SLACKY" Holta - Released under Lazy-lisence which states:
 > As soon as it's released publicly, I do no longer OWN the code,
 > I however own my copy of it. I can only ask you to keep my credits.
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
interface
uses
  XT_Types, Math, SysUtils;

function ContrastEdges(const ImgArr: T2DIntArray; MinDiff: Integer): TPointArray; StdCall;  
function ContrastEdgesGray(const ImgArr: T2DIntArray; MinDiff: Integer): TPointArray; StdCall; 

//--------------------------------------------------
implementation

{
  Given a matrix that represents an image this algorithm extacts the contrast edge points.
  The result is an Array of TPoint (TPointArray).
  Uses RGB and R,G and B are weighted equally.
}
function ContrastEdges(const ImgArr: T2DIntArray; MinDiff: Integer): TPointArray; StdCall;
var
  X,Y,Width,Height,Len,QSize: Integer;
  R,G,B,R1,G1,B1,temp:Integer;
begin
  Width := High(ImgArr[0]);
  Height := High(ImgArr);
  MinDiff := Ceil(Sqr(MinDiff)) * 3;
  QSize := Min(1000, Width*Height);
  SetLength(Result, QSize+1);
  
  Len := 0;
  for X:=0 to Width do
    for Y:=0 to Height do 
    begin
      if ((X+1) < Width) then
      begin
        temp := ImgArr[Y][X];
        
        R := temp and $FF; G := (temp shr 8) and $FF; B := (temp shr 16) and $FF;
        temp := ImgArr[Y][X+1];
        R1 := temp and $FF; G1 := (temp shr 8) and $FF; B1 := (temp shr 16) and $FF;
        
        if (Sqr(R-R1)+Sqr(G-G1)+Sqr(B-B1)) >= MinDiff then 
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

      if ((Y+1) < Height) then 
      begin
        temp := ImgArr[Y][X];
        R := temp and $FF; G := (temp shr 8) and $FF; B := (temp shr 16) and $FF;
        temp := ImgArr[Y+1][X];
        R1 := temp and $FF; G1 := (temp shr 8) and $FF; B1 := (temp shr 16) and $FF;
        if Sqr(R-R1)+Sqr(G-G1)+Sqr(B-B1) >= MinDiff then 
        begin
          Result[Len] := Point(X,Y);
          Inc(Len);
          if QSize<=Len then
          begin
            QSize := QSize+QSize;
            SetLength(Result, QSize+1);
          end;
        end;
      end;
    end;

  SetLength(Result, Len);
end;


{
  Given a matrix that represent's a image this algorithm extacts the contrast edge points.
  The result is an Array of TPoint (TPointArray).
  Uses GrayScale and the colors R,G and B are not weighted equally.
}
function ContrastEdgesGray(const ImgArr: T2DIntArray; MinDiff: Integer): TPointArray; StdCall;
var
  X,Y,Width,Height,Len,QSize: Integer;
  R,G,B,R1,G1,B1,temp:Integer;
begin
  Width := High(ImgArr[0]);
  Height := High(ImgArr);
  QSize := Min(1000, Width*Height);
  SetLength(Result, QSize+1);
  
  Len := 0;
  for X:=0 to Width do
    for Y:=0 to Height do 
    begin
      if ((X+1) < Width) then
      begin
        temp := ImgArr[Y][X];
        R := temp and $FF; G := (temp shr 8) and $FF; B := (temp shr 16) and $FF;
        temp := ImgArr[Y][X+1];
        R1 := temp and $FF; G1 := (temp shr 8) and $FF; B1 := (temp shr 16) and $FF;
        if Abs(((0.2126*R) + (0.7152*G) + (0.0722*B)) - ((0.2126*R1) + (0.7152*G1) + (0.0722*B1))) >= MinDiff  then 
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

      if ((Y+1) < Height) then 
      begin
        temp := ImgArr[Y][X];
        R := temp and $FF; G := (temp shr 8) and $FF; B := (temp shr 16) and $FF;
        temp := ImgArr[Y+1][X];
        R1 := temp and $FF; G1 := (temp shr 8) and $FF; B1 := (temp shr 16) and $FF;
        if Abs(((0.2126*R) + (0.7152*G) + (0.0722*B)) - ((0.2126*R1) + (0.7152*G1) + (0.0722*B1))) >= MinDiff then 
        begin
          Result[Len] := Point(X,Y);
          Inc(Len);
          if QSize<=Len then
          begin
            QSize := QSize+QSize;
            SetLength(Result, QSize+1);
          end;
        end;
      end;
    end;

  SetLength(Result, Len);
end;

end.