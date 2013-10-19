Unit XT.HashTable;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 CopyLeft Jarl "SLACKY" Holta - Released under Lazy-lisence which states:
 > As soon as it's released publicly, I do no longer OWN the code,
 > I however own my copy of it. I can only ask you to keep my credits.
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

interface

uses
  Classes, SysUtils, Windows;

type
  ColorLAB = Record
    L: Single;
    A: Single;
    B: Single;
  end;

  ColorLABEntry = Record
    Key: Integer;
    Value: ColorLAB;
    Isset: Boolean;
  end;
  
  ColorLABTable = Array of ColorLABEntry;
  
  //----------------------------------\\
  //--------<Integer, ColorLAB>-------\\
  ColorDict = class(TObject)
  private
    Table: ColorLABTable;
    Len: Integer;
  public
    constructor Create(Size:Integer);
    function Get(Key:Integer; var Res:ColorLAB): Boolean;
    function KeyIsset(Key:Integer): Boolean; 
    function Add(Key:Integer; Value:ColorLAB): Boolean;
    Destructor Destroy; override;
  end;
 
//--------------------------------------------------
implementation

uses 
  Math, XT.Math;

constructor ColorDict.Create(Size:Integer);
begin
  inherited Create;
  Size := Trunc(Size*1.2);
  while Not(IsPrime(Size)) do Inc(Size);
  SetLength(Table, Size);
  Len := Size;
end;

destructor ColorDict.Destroy;
begin
  inherited Destroy;
  SetLength(Table, 0);
end;


function ColorDict.Get(Key:Integer; var Res:ColorLAB): Boolean;
var
  Hash,I:Integer;
begin
  Result := False;
  Hash := (Key mod Len);
  for i:=0 to Len-1 do
  begin
    if (Table[Hash].Isset = False) or (Table[Hash].Key = Key) then
      Break;
    Inc(Hash);
    if (Hash = Len) then Hash := 0;
  end;
  if (Table[Hash].Isset = False) then Exit;

  Res := Table[Hash].Value;
  Result := True;
end;

//Checks if a key is set.. (not used)
function ColorDict.KeyIsset(Key:Integer): Boolean;
var
  Hash,i:Integer;
begin
  Hash := (Key mod Len);
  for i:=0 to Len-1 do
  begin
    if (Table[Hash].Isset = False) or (Table[Hash].Key = Key) then
      Break;
    Inc(Hash);
    if (Hash = Len) then Hash := 0;
  end;
  Result := Table[Hash].Isset;
end;

//Adds a color to the fictionary at the given key
function ColorDict.Add(Key:Integer; Value:ColorLAB): Boolean;
var
  Hash,i:Integer;
begin
  Hash := (Key mod Len);
  for i:=0 to Len-1 do
  begin
    if (Table[Hash].Isset <> True) or (Table[Hash].Key = Key) then
      Break;
    Inc(Hash);
    if (Hash = Len) then Hash := 0;
  end;
  
  if ((Table[Hash].Key <> Key) and (Table[Hash].Isset=True)) then 
    Exit(False); //The hashmap is filled... 
  
  Table[Hash].Value := Value;
  if (Table[Hash].Isset=False) then
  begin
    Table[Hash].Key := Key;
    Table[Hash].Isset := True;
  end;
  Result := True;
end;

end.