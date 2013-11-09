Unit XT_Numeric;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 Copyright (c) 2013, Jarl K. <Slacky> Holta || http://github.com/WarPie
 All rights reserved.
 For more info see: Copyright.txt
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
interface
uses
  XT_Types, Math, SysUtils;

function SumTIA(const Arr: TIntArray): Integer; Inline; StdCall;
function SumTEA(const Arr: TExtArray): Extended; Inline; StdCall;
function TIACombinations(const Arr: TIntArray; Seq:Integer): T2DIntArray; StdCall;
function TEACombinations(const Arr: TExtArray; Seq:Integer): T2DExtArray; StdCall;
procedure MinMaxTIA(const Arr: TIntArray; var Min:Integer; var Max: Integer); Inline; StdCall;
procedure MinMaxTEA(const Arr: TExtArray; var Min:Extended; var Max: Extended); Inline; StdCall;
function TIAToMat(const TIA:TIntArray; Width,Height:Integer): T2DIntArray; StdCall;


//--------------------------------------------------
implementation


{*
  Sum of a TIA.
*}
function SumTIA(const Arr: TIntArray): Integer; Inline; StdCall;
var i:Integer;
begin
  Result := 0;
  for i:=Low(Arr) to High(Arr) do
    Result := Result + Arr[i];
end;


{*
  Sum of a TEA.
*}
function SumTEA(const Arr: TExtArray): Extended; Inline; StdCall;
var i:Integer;
begin
  Result := 0.0;
  for i:=Low(Arr) to High(Arr) do
    Result := Result + Arr[i];
end;


{*
  Combinations of size `seq` from given TIA `arr`.
*}
function TIACombinations(const Arr:TIntArray; Seq:Integer): T2DIntArray; StdCall;
var
  n,h,i,j: Integer;
  indices: TIntArray;
  breakout: Boolean;
begin
  n := Length(arr);
  if seq > n then Exit;
  SetLength(indices, seq);
  for i:=0 to (seq-1) do indices[i] := i;
  SetLength(Result, 1, Seq);
  for i:=0 to (seq-1) do Result[0][i] := arr[i];
  while True do
  begin
    breakout := True;
    for i:=(Seq-1) downto 0 do
      if (indices[i] <> (i + n - Seq)) then begin
        breakout := False;
        Break;
      end;
    if breakout then Exit;
    Indices[i] := Indices[i]+1;
    for j:=i+1 to Seq-1 do
      Indices[j] := (Indices[j-1] + 1);
    h := Length(Result);
    SetLength(Result, h+1);
    SetLength(Result[h], Seq);
    for i:=0 to Seq-1 do
      Result[h][i] := Arr[Indices[i]];
  end;
  SetLength(Indices, 0);
end;


{*
  Combinations of size `seq` from given TEA `arr`.
*}
function TEACombinations(const Arr: TExtArray; Seq:Integer): T2DExtArray; StdCall;
var
  n,h,i,j: Integer;
  indices: TIntArray;
  breakout: Boolean;
begin
  n := Length(arr);
  if seq > n then Exit;
  SetLength(Indices, seq);
  for i:=0 to (seq-1) do Indices[i] := i;
  SetLength(Result, 1, Seq);
  for i:=0 to (seq-1) do Result[0][i] := Arr[i];
  while True do
  begin
    breakout := True;
    for i:=(Seq-1) downto 0 do
      if (Indices[i] <> (i + n - Seq)) then begin
        Breakout := False;
        Break;
      end;
    if Breakout then Exit;
    Indices[i] := Indices[i]+1;
    for j:=i+1 to Seq-1 do
      Indices[j] := (Indices[j-1] + 1);
    h := Length(Result);
    SetLength(Result, h+1);
    SetLength(Result[h], Seq);
    for i:=0 to Seq-1 do
      Result[h][i] := Arr[Indices[i]];
  end;
  SetLength(Indices, 0);
end;

{*
  Finds the minimum and maximum of a TIA.
*}
procedure MinMaxTIA(const Arr: TIntArray; var Min:Integer; var Max: Integer); Inline; StdCall;
var i:Integer;
begin
  Min := Arr[0];
  Max := Arr[0];
  for i:=Low(Arr) to High(Arr) do
  begin
    if Arr[i] < Min then
      Min := Arr[i]
    else if Arr[i] > Max then
      Max := Arr[i];
  end;
end;


{*
  Finds the minimum and maximum of a TEA.
*}
procedure MinMaxTEA(const Arr: TExtArray; var Min:Extended; var Max: Extended); Inline; StdCall;
var i:Integer;
begin
  Min := Arr[0];
  Max := Arr[0];
  for i:=Low(Arr) to High(Arr) do
  begin
    if Arr[i] < Min then
      Min := Arr[i]
    else if Arr[i] > Max then
      Max := Arr[i];
  end;
end;


{*
  ...
*}
function TIAToMat(const TIA:TIntArray; Width,Height:Integer): T2DIntArray; StdCall;
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

{
function TIADistribution(TIA:TIntArray; Percent:Integer): TIntArray; StdCall;
var
  Dst,r,c,i,j,h,d:Integer;
begin
  H := High(TIA);
  Dst := Max(1, Round(H * (Percent/100))); 
  D := (H div Dst)-1;
  SetLength(Result, D+1);
  c := 0;
  for i:=0 to D do
  begin
    R := 0;
    for j:=0 to Dst do
    begin
      R := R + TIA[c+j];
    end;
    c := c + Dst; 
    Result[i] := R; 
  end;
  SetLength(Result, i);
end;

}


end.






