Unit XT_TPAStack;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 Copyright (c) 2013, Jarl K. <Slacky> Holta || http://github.com/WarPie
 All rights reserved.
 For more info see: Copyright.txt
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
interface

uses
  XT_Types;

const
  STACKMINSIZE = 128;

type
  TPAStack = record
  private
    _Arr: TPointArray;
    _High: Integer;
    _Length: Integer;
  public
    (*
     Initalize
    *)
    procedure Init;

    (*
     Initalize with your own TPA
    *)
    procedure InitWith(var TPA:TPointArray);

    (*
     Release the array
    *)
    procedure Free;


    (*
     Same as initlaize, tho the pourpose is not the same.
    *)
    procedure Reset; Inline;


    (*
     Check if we can give it a new size.. It's manly used internally, but can be used elsewere..
     Note: NewSize = The highest index. (Not same as the normal SetLength).
    *)
    procedure CheckResize(NewSize:Integer); Inline;


    (*
     Check if it's time to give it a new upper size.. Faster then calling CheckResize.
    *)
    procedure CheckResizeHigh(NewSize:Integer); Inline;


    (*
     Check if it's time to give it a new lower size.. Faster then calling CheckResize.
    *)
    procedure CheckResizeLow(NewSize:Integer); Inline;

    (*
     Returns the TPA/Array.
    *)
    function GetData: TPointArray; Inline;


    (*
     Remove the last item, and return what it was. It also downsizes the array if
     possible.
    *)
    function Pop: TPoint; Inline;


    (*
     Remove the last item, and return what it was.
    *)
    function FastPop: TPoint; Inline;


    (*
     Insert a item at the given position. It resizes the array if needed.
    *)
    procedure Insert(const Item: TPoint; Pos:Integer); Inline;


    (*
     Appends the item to the last position in the array. Resizes if needed.
    *)
    procedure Append(const Item: TPoint); Inline;


    (*
     Extend the current array with the given TPA.
    *)
    procedure Extend(const TPA: TPointArray); Inline;

    (*
     Remove the first item from the stack whose value is `Value`.
    *)
    procedure Remove(const Item: TPoint); Inline;

    (*
     Remove the given index from the array.
    *)
    procedure Delete(const Index: Integer); Inline;
    
    
    (*
     Remove the given indices from the array.
    *)
    procedure DeleteEx(const Indices: TIntArray); Inline;
    
    
    (*
     Remove the first item from the stack whose value is `Value`.
    *)
    procedure Move(MoveX, MoveY:Integer); Inline;

    
    
    (*
     Get the value of the given Index.
    *)
    function Get(Index:Integer): TPoint; Inline;

    (*
     Check if the array is empty or not.
    *)
    function IsEmpty: Boolean; Inline;


    (*
     Check if the array has items or not.
    *)
    function NotEmpty: Boolean; Inline;


    (*
     Returns the length of the array including the overhead.
    *)
    function GetLength: Integer; Inline;


    (*
     Returns the size, in a way it's the same as `Length(Arr)`.
    *)
    function GetSize: Integer; Inline;


    (*
     Returns the highest index, in a way it's the same as `High(Arr)`.
    *)
    function GetHigh: Integer; Inline;


    (*
     It sets the overhead length down to the highest index + 1.
     Mainly used in combination with `GetData` to decrese the array size to the "correct size".
    *)
    procedure Fit; Inline;
  end;


//--------------------------------------------------
implementation

uses 
  XT_Math;

procedure TPAStack.Init;
begin
  _High := -1;
  _Length := STACKMINSIZE;
  SetLength(_Arr, _Length);
end;


procedure TPAStack.InitWith(var TPA:TPointArray);
begin
  _Arr := TPA;
  _High := High(_Arr);
  _Length := Length(_Arr);
  if _Length < STACKMINSIZE then
  begin
    _Length := STACKMINSIZE;
    SetLength(_Arr, _Length);
  end;
end;


procedure TPAStack.Free;
begin
  SetLength(_Arr, 0);
end;


procedure TPAStack.Reset;
begin
  _High := -1;
  _Length := STACKMINSIZE;
  SetLength(_Arr, _Length);
end;


procedure TPAStack.CheckResize(NewSize:Integer);
begin
  if NewSize <= 64 then
  begin
    _Length := STACKMINSIZE;
    _High := NewSize;
    Exit;
  end;
  _High := NewSize;
  case (_High >= _Length) of
  False:
    if ((_Length div 2) > _High) then
    begin
      _Length := _Length div 2;
      SetLength(_Arr, _Length);
    end;
  True:
    begin
      _Length := _Length + _Length;
      SetLength(_Arr, _Length);
    end;
  end;
end;


procedure TPAStack.CheckResizeHigh(NewSize:Integer);
begin
  _High := NewSize;
  if (_High >= _Length) then
  begin
    _Length := _Length + _Length;
    SetLength(_Arr, _Length);
  end;
end;


procedure TPAStack.CheckResizeLow(NewSize:Integer);
begin
  if NewSize < 64 then
  begin
    _Length := STACKMINSIZE;
    _High := NewSize;
    Exit;
  end;
  _High := NewSize;
  if ((_Length div 2) > _High) then
  begin
    _Length := _Length div 2;
    SetLength(_Arr, _Length);
  end;
end;


function TPAStack.GetData: TPointArray;
begin
  Result := _Arr;
end;


function TPAStack.FastPop: TPoint;
begin
  if (_High = -1) then Exit(Point(-1,-1));
  Result := _Arr[_High];
  Dec(_High);
end;


function TPAStack.Pop: TPoint;
begin
  if (_High = -1) then Exit(Point(-1,-1));
  Result := _Arr[_High];
  Dec(_High);
  CheckResizeLow(_High);
end;


procedure TPAStack.Insert(const Item: TPoint; Pos:Integer);
begin
  if Pos > _High then
  begin
    _High := Pos;
    CheckResizeHigh(_High)
  end;
  _Arr[Pos] := Item;
end;


procedure TPAStack.Append(const Item: TPoint);
begin
  Inc(_High);
  CheckResizeHigh(_High);
  _Arr[_High] := Item;
end;


procedure TPAStack.Extend(const TPA: TPointArray);
var
 i,_h,h:Integer;
begin
  H := Length(TPA);
  if (H = 0) then Exit;
  _h := _High + 1;
  _High := H + _h;
  CheckResizeHigh(_High);
  for i := 0 to H-1 do
    _Arr[i+_h] := TPA[i];
end;


procedure TPAStack.Remove(const Item: TPoint);
var
 i,j:Integer;
 hit:Boolean;
begin
  if (_High = -1) then Exit;

  hit := False;
  j := 0;
  for i := 0 to _High do
  begin
    if Not(hit) and (_Arr[i].X = Item.X) and (_Arr[i].Y = Item.Y) then
    begin
      hit := True;
      j := i;
    end else if (hit) then
    begin
      _Arr[j] := _Arr[i];
      Inc(j);
    end;
  end;

  if (hit) then
  begin
    Dec(_High);
    CheckResizeLow(_High);
  end;
end;


procedure TPAStack.Delete(const Index: Integer);
var
 i,j:Integer;
begin
  if (_High = -1) then Exit;
  if (Index > _High) or (Index < 0) then Exit;
  j := 0;
  
  for i:=Index to _High do
  begin
    if (i=Index) then
    begin
      j := i;
    end else
    begin
      _Arr[j] := _Arr[i];
      Inc(j);
    end;
  end; 

  Dec(_High);
  CheckResizeLow(_High);
end;


procedure TPAStack.DeleteEx(const Indices: TIntArray);
var
 i,j,lo:Integer;
 Del:TBoolArray;
begin
  if (_High = -1) then Exit;
  Lo := _High;
  SetLength(Del, _High+1);
  for i := 0 to High(Indices) do
    if ((Indices[i] > -1) and (Indices[i] <= _High)) then
    begin
      Del[Indices[i]] := True;
      if (Indices[i] < Lo) then Lo := Indices[i];
    end;

  j := 0;
  for i:=Lo to _high do
    if not(Del[i]) then
    begin
      _Arr[j] := _Arr[i];
      Inc(j);
    end;

  _High := _High - (High(Indices)-j);
  SetLength(Del, 0);
  CheckResizeLow(_High);
end;


procedure TPAStack.Move(MoveX, MoveY:Integer);
var i: Integer;
begin
  if (_High = -1) then Exit;
  for i:=0 to _High do begin
    _Arr[i].x := _Arr[i].x + MoveX;
    _Arr[i].y := _Arr[i].y + MoveY;
  end;
end;


function TPAStack.Get(Index:Integer): TPoint;
begin
  Result := _Arr[Index];
end;


function TPAStack.IsEmpty: Boolean;
begin
  Result := _High < 0;
end;


function TPAStack.NotEmpty: Boolean;
begin
  Result := _High > -1;
end;


function TPAStack.GetLength: Integer;
begin
  Result := _Length;
end;


function TPAStack.GetHigh: Integer;
begin
  Result := _High;
end;


function TPAStack.GetSize: Integer;
begin
  Result := _High + 1;
end;


procedure TPAStack.Fit;
begin
  _Length := _High + 1;
  SetLength(_Arr, _Length);
end;


end.