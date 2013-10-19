Unit XT.Finder;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 CopyLeft Jarl "SLACKY" Holta - Released under Lazy-lisence which states:
 > As soon as it's released publicly, I do no longer OWN the code,
 > I however own my copy of it. I can only ask you to keep my credits.
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
interface
uses
  XT.Types, System.Math, System.SysUtils;



function FindColorTolExLCH(const ImgArr:T2DIntArray; var TPA:TPointArray; Color, ColorTol, LightTol:Integer): Boolean; Stdcall;
function FindColorTolExLAB(const ImgArr:T2DIntArray; var TPA:TPointArray; Color, ColorTol,LightTol:Integer): Boolean; Stdcall;


//--------------------------------------------------
implementation

uses
  XT.HashTable, XT.ColorMath, XT.Numeric, XT.Math;


// Find multiple matches of specified color.
function FindColorTolExLCH(const ImgArr:T2DIntArray; var TPA:TPointArray; Color, ColorTol, LightTol:Integer): Boolean; Stdcall;
var
  W,H,X,Y,S,step:Integer;
  L,C,HH, C1,H1, DeltaHue,FF,EE,DD:Single;
  LAB: ColorLAB;
  LABDict: ColorDict;
begin
  Result := True;

  W := High(ImgArr[0]);
  H := High(ImgArr);
  LABDict := ColorDict.Create((W+1)*(H+1));

  Step := W*2;
  SetLength(TPA, step);

  ColorToLCH(Color, L,C,HH);
  LightTol := Sqr(LightTol);

  S := 0;
  for X:=0 to W do
    for Y:=0 to H do
    begin
      if not(LABDict.Get(ImgArr[Y][X], LAB)) then
      begin
        ColorToLAB(ImgArr[Y][X], FF,EE,DD);
        LAB.L := FF;
        LAB.A := EE;
        LAB.B := DD;
        LABDict.Add(ImgArr[Y][X], LAB);
      end;
      C1 := Sqrt(Sqr(LAB.A) + Sqr(LAB.B));

      //Within Lightness and Chroma? (142 = tolmax)
      if ((Sqr(LAB.L - L) + Sqr(C1 - C)) <= LightTol) then
      begin
        H1 := ArcTan2(LAB.B,LAB.A);
        if (H1 > 0) then H1 := (H1 / 3.1415926536) * 180
        else H1 := 360 - (-H1 / 3.1415926536) * 180;
        DeltaHue := Modulo((H1 - HH + 180), 360) - 180;

        //Within Hue tolerance? (180 = tolmax)
        if (Abs(DeltaHue) <= ColorTol) then
        begin
          if S>=step then
          begin
            step := step+step;  //for regualar widescreen this maxes at 10 SetLengths.
            SetLength(TPA, step);
          end;
          TPA[S].X := X;
          TPA[S].Y := Y;
          Inc(S);
        end;
      end;
    end;

  LABDict.Destroy;
  SetLength(TPA,S);
  if Length(TPA)=0 then Result := False;
end;


// Find multiple matches of specified color.
function FindColorTolExLAB(const ImgArr:T2DIntArray; var TPA:TPointArray; Color, ColorTol,LightTol:Integer): Boolean; Stdcall;
var
  W,H,X,Y,S,step:Integer;
  L,A,B,FF,EE,DD:Single;
  LAB: ColorLAB;
  LABDict: ColorDict;
begin
  Result := True;

  W := High(ImgArr[0]);
  H := High(ImgArr);
  LABDict := ColorDict.Create((W+1)*(H+1));

  Step := W*2;
  SetLength(TPA, step);

  ColorToLAB(Color, L,A,B);
  ColorTol := Sqr(ColorTol);

  S := 0;
  for X:=0 to W do
    for Y:=0 to H do
    begin
      if not(LABDict.Get(ImgArr[Y][X], LAB)) then
      begin
        ColorToLAB(ImgArr[Y][X], FF,EE,DD);
        LAB.L := FF;
        LAB.A := EE;
        LAB.B := DD;
        LABDict.Add(ImgArr[Y][X], LAB);
      end;

      //Within chroma and hue-levels? (142 = tolmax)
      if ((Sqr(LAB.A - A) + Sqr(LAB.B - B)) <= ColorTol) then
      begin

        //Within Lightness tolerance? (100 = tolmax)
        if (Abs(L-LAB.L) <= LightTol) then
        begin
          if S>=step then
          begin
            step := step+step;
            SetLength(TPA, step);
          end;
          TPA[S].X := X;
          TPA[S].Y := Y;
          Inc(S);
        end;
      end;
    end;

  LABDict.Destroy;
  SetLength(TPA,S);
  if Length(TPA)=0 then Result := False;
end;

end.