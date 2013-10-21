unit XT.Types;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 CopyLeft Jarl "SLACKY" Holta - Released under Lazy-lisence which states:
 > As soon as it's released publicly, I do no longer OWN the code, 
 > I however only own my personal copy of it.
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

interface

uses
  System.Types, System.SysUtils;

type
  TPoint = Packed record X,Y: LongInt; end;
  TPointArray = array of TPoint;
  T2DPointArray = array of TPointArray;
  T3DPointArray = array of T2DPointArray;
  
  TFPoint = Packed record X,Y:Extended; end;
  TFPointArray = Array of TFPoint;
  
  TIntArray = array of Integer;
  T2DIntArray = array of TIntArray;
  T3DIntArray = array of T2DIntArray;

  TByteArray = array of Byte;
  T2DByteArray = array of TByteArray;
  T3DByteArray = array of T2DByteArray;  
  
  TBoolArray = array of Boolean;
  T2DBoolArray = array of TBoolArray;
  T3DBoolArray = array of T2DBoolArray;
  
  TExtArray = array of Extended;
  T2DExtArray = array of TExtArray;
  T3DExtArray = array of T2DExtArray;
  
  (* Not SCAR compatible - Don't export*)
  TBox = Packed record
    X1: LongInt;
    Y1: LongInt;
    X2: LongInt;
    Y2: LongInt;
  end;
  TBoxArray = Array of TBox;


function Box(const x1,y1,x2,y2:Integer): TBox; Inline;
function Point(const x,y:Integer): TPoint; Inline;
function FPoint(const x,y:Extended):TFPoint; Inline;
function TFPAToTPA(TFPA:TFPointArray): TPointArray; 
function TPAToTFPA(TPA:TPointArray): TFPointArray;


//-----------------------------------------------------------------------
implementation

uses
  System.Math;

function Box(const X1,Y1,X2,Y2:Integer): TBox; Inline;
begin
  Result.x1 := x1;
  Result.y1 := y1;
  Result.x2 := x2;
  Result.y2 := y2;
end;    
  
function Point(const X, Y: Integer): TPoint; Inline;
begin
  Result.X := X;
  Result.Y := Y;
end;  
  
function FPoint(const X,Y:Extended):TFPoint; Inline;
begin
  Result.X := X;
  Result.Y := Y;
end; 
 
function TFPAToTPA(TFPA:TFPointArray): TPointArray;
var i:Integer;
begin
  SetLength(Result, Length(TFPA));
  for i:=0 to High(TFPA) do
    Result[i] := Point(Round(TFPA[i].x), Round(TFPA[i].y));
end;

function TPAToTFPA(TPA:TPointArray): TFPointArray;
var i:Integer;
begin
  SetLength(Result, Length(TPA));
  for i:=0 to High(TPA) do
  begin
    Result[i].x := TPA[i].x;
    Result[i].y := TPA[i].y;
  end;
end;

end.
