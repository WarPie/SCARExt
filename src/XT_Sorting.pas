unit XT_Sorting;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 Copyright (c) 2013, Jarl K. <Slacky> Holta || http://github.com/WarPie
 All rights reserved.
 For more info see: Copyright.txt
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

interface

uses
  XT_Types, XT_Standard, XT_Points;

procedure SortTIA(var Arr: TIntArray); StdCall;
procedure SortTEA(var Arr: TExtArray); StdCall;
procedure SortTPA(var Arr: TPointArray); StdCall;
procedure SortTPAbyRow(var Arr: TPointArray); StdCall;
procedure SortTPAbyColumn(var Arr: TPointArray); StdCall;

//-----------------------------------------------------------------------
implementation


(*
 Sorting array of integers!
 It uses a combination of Insertion- And Quick-Sort.
*)
procedure __SortTIA(Arr:TIntArray; Left, Right:Integer);
var
  i, j : Integer;
  pivot: Integer;
begin
  if Right <= Left+11 then
  begin
    for i := Left to Right do
      for j := i downto 1 do begin
        if not (Arr[j] < Arr[j - 1]) then Break;
        ExchI(Arr[j - 1], Arr[j]);
      end;
    Exit;
  end;
  i:=Left;
  j:=Right;
  pivot := Arr[(Left + Right) shr 1];
  repeat
    while pivot > Arr[i] do i:=i+1;
    while pivot < Arr[j] do j:=j-1;
    if i<=j then begin
      ExchI(Arr[i], Arr[j]);
      j:=j-1;
      i:=i+1;
    end;
  until (i>j);
  if Left<j then __SortTIA(Arr, Left,j);
  if i<Right then __SortTIA(Arr, i,Right);
end;

procedure SortTIA(var Arr: TIntArray); StdCall;
begin
  __SortTIA(Arr, Low(Arr), High(Arr));
end;


(*
 Sorting Array of Extended!
 It uses a combination of Insertion- And Quick-Sort.
*)
procedure __SortTEA(Arr:TExtArray; Left, Right:Integer);
var
  i, j : Integer;
  pivot: Extended;
begin
  if Right <= Left+11 then
  begin
    for i := Left to Right do
      for j := i downto 1 do begin
        if not (Arr[j] < Arr[j - 1]) then Break;
        ExchE(Arr[j - 1], Arr[j]);
      end;
    Exit;
  end;
  i:=Left;
  j:=Right;
  pivot := Arr[(Left + Right) shr 1];
  repeat
    while pivot > Arr[i] do i:=i+1;
    while pivot < Arr[j] do j:=j-1;
    if i<=j then begin
      ExchE(Arr[i], Arr[j]);
      j:=j-1;
      i:=i+1;
    end;
  until (i>j);
  if Left<j then __SortTEA(Arr, Left,j);
  if i<Right then __SortTEA(Arr, i,Right);
end;

procedure SortTEA(var Arr: TExtArray); StdCall;
begin
  __SortTEA(Arr, Low(Arr), High(Arr));
end;


(*
 Sorting Array of TPoint!
 It uses a combination of Insertion- And Quick-Sort.
*)
procedure __SortTPA(Arr:TPointArray; Weight:TIntArray; Left, Right:Integer);
var
  i, j : Integer;
  pivot: Integer;
begin
  if Right <= Left+11 then
  begin
    for i := Left to Right do
      for j := i downto 1 do begin
        if not (Weight[j] < Weight[j - 1]) then Break;
        ExchPt(Arr[j-1], Arr[j]);
        ExchI(Weight[j-1], Weight[j]);
      end;
    Exit;
  end;
  i:=Left;
  j:=Right;
  pivot := Weight[(Left + Right) shr 1];
  repeat
    while pivot > Weight[i] do i:=i+1;
    while pivot < Weight[j] do j:=j-1;
    if i<=j then begin
      ExchPt(Arr[i], Arr[j]);
      ExchI(Weight[i], Weight[j]);
      j:=j-1;
      i:=i+1;
    end;
  until (i>j);
  if Left<j then __SortTPA(Arr, Weight, Left,j);
  if i<Right then __SortTPA(Arr, Weight, i,Right);
end;

//Sort TPA by Distance from 0,0;
procedure SortTPA(var Arr: TPointArray); StdCall;
var
  i,Hi: Integer;
  Weight:TIntArray;
begin
  Hi := High(Arr);
  SetLength(Weight, Hi+1);
  for i := 0 to Hi do
    Weight[i] := Sqr(Arr[i].x) + Sqr(Arr[i].y);
  __SortTPA(Arr, Weight, Low(Arr), High(Arr));
  SetLength(Weight, 0);
end;

//Sort TPA by Row.
procedure SortTPAbyRow(var Arr: TPointArray); StdCall;
var
  i,Hi,W: Integer;
  Weight:TIntArray;
  Area : TBox;
begin
  Area := GetTPABounds(Arr);
  W := Area.X2-Area.X1+1;
  Hi := High(Arr);
  SetLength(Weight, Hi+1);
  for i := 0 to Hi do
    Weight[i] := Arr[i].y * W + Arr[i].x;
  __SortTPA(Arr, Weight, Low(Arr), High(Arr));
  SetLength(Weight, 0);
end;

//Sort TPA by Column.
procedure SortTPAbyColumn(var Arr: TPointArray); StdCall;
var
  i,Hi,H: Integer;
  Weight:TIntArray;
  Area : TBox;
begin
  Area := GetTPABounds(Arr);
  H := Area.Y2-Area.Y1+1;
  Hi := High(Arr);
  SetLength(Weight, Hi+1);
  for i := 0 to Hi do
    Weight[i] := Arr[i].x * H + Arr[i].y;
  __SortTPA(Arr, Weight, Low(Arr), High(Arr));
  SetLength(Weight, 0);
end;


end.
