Unit XT_SimpleOCR;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 Copyright (c) 2013, Jarl K. <Slacky> Holta || http://github.com/WarPie
 All rights reserved.
 For more info see: Copyright.txt
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
//SCARs GetTextAtEx was running to slow, and missing tolerance for pixel error.
//This is just something I wrote very fast, so it's very prototype-ish.
//Might be expanded on over time.
interface
uses
  XT_Types, Math, SysUtils;

function ImGetText(ImgArr:T2DIntArray; Font:TChars; MinCharSpace, MinSpace, TextPixTol: Integer; Range:AnsiString): AnsiString; StdCall;
function ImGetTextEx(ImgArr:T2DIntArray; Fonts:TCharsArray; MinCharSpace, MinSpace, TextPixTol: Integer; Range:AnsiString): AnsiString; StdCall;


//--------------------------------------------------
implementation
uses 
  XT_Matrix, XT_Points, XT_Imaging, XT_Finder;

var
  SpacePositions: TBoolArray;
  

function ExtractChars(ImgArr:T2DIntArray; MinCharSpace, MinSpace:Integer): TChars;
var
  i,j,H:Integer;
  TPA: TPointArray;
  ATPA: T2DPointArray;
  B,PB: TBox;
begin
  ImgArr := ImThresholdAdaptive(ImgArr, 0, 255, False, TM_Mean, 0);
  ImFindColorTolEx(ImgArr, TPA, 255, 1);
  ATPA := ClusterTPAEx(TPA, MinCharSpace,40, True);
  H := High(ATPA); 
  SetLength(SpacePositions, H+1);
  SetLength(Result, H+1);   
  for i:=0 to H do 
  begin
    B := TPABounds(ATPA[i]); 
    if (i>0) then
      if (Abs(B.x1 - PB.x2)-2) > MinSpace then
        SpacePositions[i] := True;
    PB := B; 

    SetLength(Result[i], (B.y2 - B.y1)+1, (B.x2 - B.x1)+1);
    for j:=0 to High(ATPA[i]) do
      Result[i][ATPA[i][j].y - B.y1][ATPA[i][j].x - B.x1] := 255; 
  end;
  SetLength(ATPA, 0);
end;


function CompareChars(CharA,CharB: T2DIntArray): Integer; Inline;
var x,y,W,H,hits:Integer;
begin
  H := Min(High(CharA), High(CharB));
  W := Min(High(CharA[0]), High(CharB[0])); 
  
  hits := 0;
  for y:=0 to H do 
    for x:=0 to W do     
      if ((CharA[y][x] - CharB[y][x]) <> 0) then
        Inc(hits); 

  hits := hits + Abs(High(CharA) - High(CharB));
  hits := hits + Abs(High(CharA[0]) - High(CharB[0])); 
  Result := hits;
end;


function ImGetText(ImgArr:T2DIntArray; Font:TChars; MinCharSpace, MinSpace, TextPixTol: Integer; Range:AnsiString): AnsiString; StdCall;
var
  i,j:Integer;
  PixHits,char,hit:Integer; 
  Chars: TChars; 
begin
  Chars := ExtractChars(ImgArr, MinCharSpace, MinSpace);

  Result := '';  
  for i:=0 to High(Chars) do
  begin
    Char := 0;
    PixHits := 10000000;   
    
    for j:=0 to High(Font) do
    begin          
      if High(font[j]) < 0 then Continue;
      hit := CompareChars(chars[i], font[j]); 
      if hit < PixHits then 
      begin 
        PixHits := hit;
        Char := j;
      end;
    end;
    
    if SpacePositions[i] then 
      Result := Result + ' ';
    if (PixHits < TextPixTol) then    
      Result := Result + Chr(Char)
    else
      Result := Result + ''; //Unkown char  
  end;
  
  SetLength(SpacePositions, 0);
end;  


(* 
 Taking multple fonts and using that to try to read some text.
*) 
function ImGetTextEx(ImgArr:T2DIntArray; Fonts:TCharsArray; MinCharSpace, MinSpace, TextPixTol: Integer; Range:AnsiString): AnsiString; StdCall;
var
  i,j,k,highFonts:Integer;
  PixHits,char,hit:Integer; 
  Chars: TChars; 
begin
  Chars := ExtractChars(ImgArr, MinCharSpace, MinSpace);
  HighFonts := High(Fonts);
  Result := '';  
  for i:=0 to High(Chars) do
  begin
    Char := 0;
    PixHits := 10000000;   
    
    for k:=0 to HighFonts do
    begin
      for j:=0 to high(Fonts[k]) do
      begin          
        if High(fonts[k][j]) < 0 then Continue;
        hit := CompareChars(chars[i], Fonts[k][j]); 
        if (hit < PixHits) then 
        begin 
          PixHits := hit;
          Char := j;
        end;
      end;
    end;  
    
    if SpacePositions[i] then 
      Result := Result + ' ';

    if (PixHits < TextPixTol) then
      Result := Result + Chr(Char)
    else
      Result := Result + ''; //Unkown char  
  end;
  
  SetLength(SpacePositions, 0);
end; 

end.