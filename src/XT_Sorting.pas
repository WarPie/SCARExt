unit XT_Sorting;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 Copyright (c) 2013, Jarl K. <Slacky> Holta || http://github.com/WarPie
 All rights reserved.
 For more info see: Copyright.txt
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
(*
 My own (fast) sorting algorithm implmentation (QuickInsertSortW\Fallback2Shell). *funny*
 > The closer the array is to beeing already sorted, the faster it gets.
 > Does not matter much if the array is reversed or not.
 > Fallback to ShellSort: Ensure O(n^3/2).

 How does it work?
 First of all it uses a sliglty modified Quicksort as a base.
 Quicksort has a strong property of weighting reversed sorted array equal to a already
 sorted array. So no matter direction it uses about the same time to sort.

 If the partition Left to Right is less then a cirtain criteria InsertionSort is used.

 If all items from "Left up to pivot" is sorted and "Right down to pivot" is sorted
 then we run InsertionSort on the "partition", and exit. If not then we continue
 doing a regular quicksort. This check is then continued ~6 times in each partioning.
 
 If the recursion depth goes bellow a given limit then we fall back to ShellSort to avoid
 worst-case scenario in Quicksort: O(n^2).
 
 My testes show that it can be ~35x faster then QuickSort.
*)
interface

uses
  XT_Types, XT_Standard, XT_Points;

procedure InsSortTIA(var Arr:TIntArray; Left, Right:Integer); Inline;
procedure InsSortTEA(var Arr:TExtArray; Left, Right:Integer); Inline;
procedure InsSortTPA(var Arr:TPointArray; Weight:TIntArray; Left, Right:Integer); Inline;
procedure ShellSortTIA(var Arr: TIntArray);
procedure ShellSortTEA(var Arr: TExtArray);
procedure ShellSortTPA(var Arr: TPointArray; Weight:TIntArray);
procedure SortTIA(var Arr: TIntArray); StdCall;
procedure SortTEA(var Arr: TExtArray); StdCall;
procedure SortTPA(var Arr: TPointArray); StdCall;
procedure SortTPAFrom(var Arr: TPointArray; const From:TPoint); StdCall;
procedure SortTPAbyRow(var Arr: TPointArray); StdCall;
procedure SortTPAbyColumn(var Arr: TPointArray); StdCall;


//-----------------------------------------------------------------------
implementation


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//Insertion sort bellow

(*
 Fast integer sorting from small arrays, or small parts of arrays.
*)
procedure InsSortTIA(var Arr:TIntArray; Left, Right:Integer); Inline;
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
 Fast extended sorting from small arrays, or small parts of arrays.
*)
procedure InsSortTEA(var Arr:TExtArray; Left, Right:Integer); Inline;
var i, j:Integer; tmp:Extended;
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
 Fast TPoint sorting from small arrays, or small parts of arrays.
*)
procedure InsSortTPA(var Arr:TPointArray; Weight:TIntArray; Left, Right:Integer); Inline;
var i, j:Integer;
begin
  for i := Left to Right do
    for j := i downto Left + 1 do begin
      if not (Weight[j] < Weight[j - 1]) then Break;
      ExchPt(Arr[j-1], Arr[j]);
      ExchI(Weight[j-1], Weight[j]);
    end;
end;


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//ShellSort bellow (only used to ensure O(n^3/2)) in the "main" sorting algorithm.

procedure ShellSortTIA(var Arr: TIntArray);
var
  Gap, i, j, H: Integer;
begin
  H := High(Arr);
  Gap := 0;
  while (Gap < (H+1) div 3) do Gap := Gap * 3 + 1;
  while Gap >= 1 do begin
    for i := Gap to H do begin
      j := i;
      while (j >= Gap) and (Arr[j] < Arr[j - Gap]) do
      begin
        ExchI(Arr[j], Arr[j - Gap]);
        j := j - Gap;
      end;
    end;
    Gap := Gap div 3;
  end;
end;


procedure ShellSortTEA(var Arr: TExtArray);
var
  Gap, i, j, H: Integer;
begin
  H := High(Arr);
  Gap := 0;
  while (Gap < (H+1) div 3) do Gap := Gap * 3 + 1;
  while Gap >= 1 do begin
    for i := Gap to H do begin
      j := i;
      while (j >= Gap) and (Arr[j] < Arr[j - Gap]) do
      begin
        ExchE(Arr[j], Arr[j - Gap]);
        j := j - Gap;
      end;
    end;
    Gap := Gap div 3;
  end;
end;


procedure ShellSortTPA(var Arr: TPointArray; Weight:TIntArray);
var
  Gap, i, j, H: Integer;
begin
  H := High(Arr);
  Gap := 0;
  while (Gap < (H+1) div 3) do Gap := Gap * 3 + 1;
  while Gap >= 1 do begin
    for i := Gap to H do begin
      j := i;
      while (j >= Gap) and (Weight[j] < Weight[j - Gap]) do
      begin
        ExchPt(Arr[j], Arr[j - Gap]);
        ExchI(Weight[j], Weight[j - Gap]);
        j := j - Gap;
      end;
    end;
    Gap := Gap div 3;
  end;
end;
       


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//The main sorting algorithms are bellow.


(*
 Sorting array of integers!
*)
procedure __SortTIA(var Arr:TIntArray; Left, Right, Depth:Integer);
var
  i,j,l,f: Integer;
  pivot:Integer;
  Ins:Boolean;
begin
  if Right < Left+15 then
  begin
    InsSortTIA(Arr, Left, Right);
    Exit;
  end;
  if Depth < 0 then begin
    ShellSortTIA(Arr);
    Exit;
  end;
  f:=0;
  Ins:=False;
  i:=Left;
  j:=Right;
  pivot := Arr[(left+right) shr 1];
  repeat
    while pivot > Arr[i] do i:=i+1;
    while pivot < Arr[j] do j:=j-1;
    if (Arr[j] = Arr[i])  and (f<=5) then begin
      l := i;
      while (Arr[l] = Arr[j]) and (l<j) do l:=l+1;
      if (l=j) then begin
        ins := True;
        break;
      end;
    end;
    if i<=j then begin
      ExchI(Arr[i], Arr[j]);
      j:=j-1;
      i:=i+1;
      f:=f+1;
    end;
  until (i>j);
  if not(Ins) then
  begin
    if (Left < j) then __SortTIA(Arr, Left,j, depth-1);
    if (i < Right) then __SortTIA(Arr, i,Right, depth-1);
  end else
    InsSortTIA(Arr, Left, Right);
end; 

procedure SortTIA(var Arr: TIntArray); StdCall;
var limit: Integer;
begin
  Limit := Round(2.5*ln(Length(Arr))/ln(2));
  __SortTIA(Arr, Low(Arr), High(Arr), Limit);
end;


(*
 Sorting Array of Extended!
*)
procedure __SortTEA(var Arr:TExtArray; Left, Right, Depth:Integer);
var
  i,j,l,f: Integer;
  pivot: Extended;
  Ins: Boolean;
begin
  if Right < Left+15 then
  begin
    InsSortTEA(Arr, Left, Right);
    Exit;
  end;
  if Depth < 0 then begin
    ShellSortTEA(Arr);
    Exit;
  end;
  f:=0;
  Ins:=False;
  i:=Left;
  j:=Right;
  pivot := Arr[(left+right) shr 1];
  repeat
    while pivot > Arr[i] do i:=i+1;
    while pivot < Arr[j] do j:=j-1;
    if (Arr[j] = Arr[i]) and (f<=5) then begin
      l := i;
      while (Arr[l] = Arr[j]) and (l<j) do l:=l+1;
      if (l=j) then begin
        ins := True;
        break;
      end;
    end;
    if i<=j then begin
      ExchE(Arr[i], Arr[j]);
      j:=j-1;
      i:=i+1;
      f:=f+1;
    end;
  until (i>j);
  if not(Ins) then
  begin
    if (Left < j) then __SortTEA(Arr, Left,j, Depth-1);
    if (i < Right) then __SortTEA(Arr, i,Right, Depth-1);
  end else
    InsSortTEA(Arr, Left, Right);
end;

procedure SortTEA(var Arr: TExtArray); StdCall;
var limit: Integer;
begin
  Limit := Round(2.5*ln(Length(Arr))/ln(2));
  __SortTEA(Arr, Low(Arr), High(Arr), Limit);
end;


(*
 Sorting Array of TPoint using an array for weight!
*)
procedure __SortTPA(var Arr:TPointArray; Weight:TIntArray; Left, Right, Depth:Integer);
var
  i,j,l,f: Integer;
  pivot: Integer;
  Ins:Boolean;
begin
  if Right < Left+15 then
  begin
    for i := Left to Right do
      for j := i downto Left + 1 do begin
        if not (Weight[j] < Weight[j - 1]) then Break;
        ExchPt(Arr[j-1], Arr[j]);
        ExchI(Weight[j-1], Weight[j]);
      end;
    Exit;
  end;
  if Depth < 0 then begin
    ShellSortTPA(Arr, Weight);
    Exit;
  end;
  f:=0;
  Ins:=False;
  i:=Left;
  j:=Right;
  pivot := Weight[(Left + Right) shr 1];
  repeat
    while pivot > Weight[i] do i:=i+1;
    while pivot < Weight[j] do j:=j-1;
    if (Weight[j] = Weight[i]) and (f<=5) then begin
      l := i;
      while (Weight[l] = Weight[j]) and (l<j) do l:=l+1;
      if (l=j) then begin
        ins := True;
        break;
      end;
    end;
    if i<=j then begin
      ExchPt(Arr[i], Arr[j]);
      ExchI(Weight[i], Weight[j]);
      j:=j-1;
      i:=i+1;
      f:=f+1;
    end;
  until (i>j);
  if not(Ins) then
  begin
    if Left<j then __SortTPA(Arr, Weight, Left,j, Depth-1);
    if i<Right then __SortTPA(Arr, Weight, i,Right, Depth-1);
  end else
    InsSortTPA(Arr, Weight, Left, Right);
end;

//Sort TPA by Distance from 0,0;
procedure SortTPA(var Arr: TPointArray); StdCall;
var
  i,Hi: Integer;
  Weight:TIntArray;
  limit: Integer;
begin
  Limit := Round(2.5*ln(Length(Arr))/ln(2));
  Hi := High(Arr);
  SetLength(Weight, Hi+1);
  for i := 0 to Hi do
    Weight[i] := Sqr(Arr[i].x) + Sqr(Arr[i].y);
  __SortTPA(Arr, Weight, Low(Arr), High(Arr), Limit);
  SetLength(Weight, 0);
end;

//Sort TPA by Distance from a TPoint `From`.
procedure SortTPAFrom(var Arr: TPointArray; const From:TPoint); StdCall;
var
  i,Hi: Integer;
  Weight:TIntArray;
  limit: Integer;
begin
  Limit := Round(2.5*ln(Length(Arr))/ln(2));
  Hi := High(Arr);
  SetLength(Weight, Hi+1);
  for i := 0 to Hi do
    Weight[i] := Sqr(From.x-Arr[i].x) + Sqr(From.y-Arr[i].y);
  __SortTPA(Arr, Weight, Low(Arr), High(Arr), Limit);
  SetLength(Weight, 0);
end;

//Sort TPA by Row.
procedure SortTPAbyRow(var Arr: TPointArray); StdCall;
var
  i,Hi,W: Integer;
  Weight:TIntArray;
  Area : TBox;
  limit: Integer;
begin
  Limit := Round(2.5*ln(Length(Arr))/ln(2));
  Area := TPABounds(Arr);
  W := Area.X2-Area.X1+1;
  Hi := High(Arr);
  SetLength(Weight, Hi+1);
  for i := 0 to Hi do
    Weight[i] := Arr[i].y * W + Arr[i].x;
  __SortTPA(Arr, Weight, Low(Arr), High(Arr), Limit);
  SetLength(Weight, 0);
end;

//Sort TPA by Column.
procedure SortTPAbyColumn(var Arr: TPointArray); StdCall;
var
  i,Hi,H: Integer;
  Weight:TIntArray;
  Area : TBox;
  limit: Integer;
begin
  Limit := Round(2.5*ln(Length(Arr))/ln(2));
  Area := TPABounds(Arr);
  H := Area.Y2-Area.Y1+1;
  Hi := High(Arr);
  SetLength(Weight, Hi+1);
  for i := 0 to Hi do
    Weight[i] := Arr[i].x * H + Arr[i].y;
  __SortTPA(Arr, Weight, Low(Arr), High(Arr), Limit);
  SetLength(Weight, 0);
end;


end.
