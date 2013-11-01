unit XT_Sorting;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 Copyright (c) 2013, Jarl K. <Slacky> Holta || http://github.com/WarPie
 All rights reserved.
 For more info see: Copyright.txt
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
(* Pretty fast sorting *)
interface

uses
  XT_Types, XT_Standard, XT_Points;

procedure InsSort(Arr:TIntArray; Left, Right:Integer); Inline;
procedure SortTIA(var Arr: TIntArray); StdCall;
procedure SortTEA(var Arr: TExtArray); StdCall;
procedure SortTPA(var Arr: TPointArray); StdCall;
procedure SortTPAFrom(var Arr: TPointArray; const From:TPoint); StdCall;
procedure SortTPAbyRow(var Arr: TPointArray); StdCall;
procedure SortTPAbyColumn(var Arr: TPointArray); StdCall;

//-----------------------------------------------------------------------
implementation

(*
 Fast integer sorting from sall arrays, or small parts of arrays.
*)
procedure InsSort(Arr:TIntArray; Left, Right:Integer); Inline;
var i, j, tmp:Integer;
begin
  for i := Left+1 to Right do begin
    j := i-1;
    Tmp := arr[i];
    while (j >= Left) and (Arr[j] > Tmp) do begin
      Arr[j+1] := Arr[j];
      j:=j-1;
    end;
    Arr[j+1] := Tmp;
  end;
end;


(*
 Sorting array of integers!
*)
procedure __SortTIA(Arr:TIntArray; Left, Right:Integer);
var i,j,pivot: Integer;
begin
  if Right < Left+15 then
  begin
    for i := Left+1 to Right do begin
      j := i-1;
      pivot := arr[i];
      while (j >= Left) and (arr[j] > pivot) do begin
        Arr[j+1] := Arr[j];
        j:=j-1;
      end;
      arr[j+1] := pivot;
    end;
    Exit;
  end;
  i:=Left;
  j:=Right;
  pivot := Arr[(left+right) shr 1];
  repeat
    while pivot > Arr[i] do i:=i+1;
    while pivot < Arr[j] do j:=j-1;
    if i<=j then begin
      ExchI(Arr[i], Arr[j]);
      j:=j-1;
      i:=i+1;
    end;
  until (i>j);
  if (Left < j) then __SortTIA(Arr, Left,j);
  if (i < Right) then __SortTIA(Arr, i,Right);
end; 

procedure SortTIA(var Arr: TIntArray); StdCall;
begin
  __SortTIA(Arr, Low(Arr), High(Arr));
end;


(*
 Sorting Array of Extended!
*)
procedure __SortTEA(Arr:TExtArray; Left, Right:Integer);
var
  i, j : Integer;
  pivot: Extended;
begin
  if Right < Left+15 then
  begin
    for i := Left+1 to Right do begin
      j := i-1;
      pivot := arr[i];
      while (j >= Left) and (arr[j] > pivot) do begin
        Arr[j+1] := Arr[j];
        j:=j-1;
      end;
      arr[j+1] := pivot;
    end;
    Exit;
  end;
  i:=Left;
  j:=Right;
  pivot := Arr[(left+right) shr 1];
  repeat
    while pivot > Arr[i] do i:=i+1;
    while pivot < Arr[j] do j:=j-1;
    if i<=j then begin
      ExchE(Arr[i], Arr[j]);
      j:=j-1;
      i:=i+1;
    end;
  until (i>j);
  if (Left < j) then __SortTEA(Arr, Left,j);
  if (i < Right) then __SortTEA(Arr, i,Right);
end;

procedure SortTEA(var Arr: TExtArray); StdCall;
begin
  __SortTEA(Arr, Low(Arr), High(Arr));
end;


(*
 Sorting Array of TPoint using an array for weight!
*)
procedure __SortTPA(Arr:TPointArray; Weight:TIntArray; Left, Right:Integer);
var
  i, j : Integer;
  pivot: Integer;
begin
  if Right < Left+15 then
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

//Sort TPA by Distance from a TPoint `From`.
procedure SortTPAFrom(var Arr: TPointArray; const From:TPoint); StdCall;
var
  i,Hi: Integer;
  Weight:TIntArray;
begin
  Hi := High(Arr);
  SetLength(Weight, Hi+1);
  for i := 0 to Hi do
    Weight[i] := Sqr(From.x-Arr[i].x) + Sqr(From.y-Arr[i].y);
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
  Area := TPABounds(Arr);
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
  Area := TPABounds(Arr);
  H := Area.Y2-Area.Y1+1;
  Hi := High(Arr);
  SetLength(Weight, Hi+1);
  for i := 0 to Hi do
    Weight[i] := Arr[i].x * H + Arr[i].y;
  __SortTPA(Arr, Weight, Low(Arr), High(Arr));
  SetLength(Weight, 0);
end;


end.
