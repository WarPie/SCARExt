library SCARExt;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 CopyLeft Jarl "SLACKY" Holta - Released under Lazy-lisence which states:
 > As soon as it's released publicly, I do no longer OWN the code,
 > I however own my copy of it. I can only ask you to keep my credits.
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

uses
  FastShareMem,
  SysUtils,
  Classes,
  Windows,
  Math,

  XT.Types in 'src\XT.Types.pas',
  XT.HashTable in 'src\XT.HashTable.pas',
  XT.ColorMath in 'src\XT.ColorMath.pas',
  XT.Math in 'src\XT.Math.pas',
  XT.Collection in 'src\XT.Collection.pas',
  XT.Numeric in 'src\XT.Numeric.pas',
  XT.Randomize in 'src\XT.Randomize.pas',
  XT.Points in 'src\XT.Points.pas',
  XT.Finder in 'src\XT.Finder.pas',
  XT.CSpline in 'src\XT.CSpline.pas',
  XT.DensityMap in 'src\XT.DensityMap.pas',
  XT.ContrastEdges in 'src\XT.ContrastEdges.pas',
  XT.TPAExtShape in 'src\XT.TPAExtShape.pas';

  
type
  TCommand = record
    procAddr: Pointer;
    procDef: AnsiString;
  end;

var
  commands: array of TCommand;
  commandsLoaded: Boolean;

{$R *.res}


procedure AddCommand(procAddr: Pointer; procDef: AnsiString);
var
  l: Integer;
begin
  l := Length(commands);
  SetLength(commands, (l + 1));
  commands[l].procAddr := procAddr;
  commands[l].procDef := procDef;
end;


{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
[=-=-=-=-=-=-=-=-=-=-=-=  THIS GOES OUT OF OUR PLUGIN  =-=-=-=-=-=-=-=-=-=-=-=]
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
procedure SetupCommands;
begin
  //** Math.pas **//
  AddCommand(@DistManhattan, 'function XT_DistManhattan(pt1,pt2: TPoint): Extended;');
  AddCommand(@DistEuclidean, 'function XT_DistEuclidean(pt1,pt2: TPoint): Extended;');
  AddCommand(@DistChebyshev, 'function XT_DistChebyshev(pt1,pt2: TPoint): Extended;');
  AddCommand(@DistOctagonal, 'function XT_DistOctagonal(pt1,pt2: TPoint): Extended;');
  AddCommand(@Modulo,     'function XT_Modulo(X,Y:Extended): Extended;');
  AddCommand(@InCircle,   'function XT_InCircle(const Pt, Center: TPoint; Radius: Integer): Boolean;');
  AddCommand(@InPoly,     'function XT_InPoly(x,y:Integer; const Poly:TPointArray): Boolean;');
  AddCommand(@InPolyR,   'function XT_InPolyR(x,y:Integer; const Poly:TPointArray): Boolean;');
  AddCommand(@InPolyW,   'function XT_InPolyW(x,y:Integer; const Poly:TPointArray): Boolean;');
  AddCommand(@InEllipse,  'function XT_InEllipse(const Pt, Center:TPoint; YRad, XRad: Integer): Boolean;');
  AddCommand(@InRectange, 'function XT_InRectange(Pt:TPoint; X1,Y1, X2,Y2: Integer): Boolean;');

  
  //** Numeric.pas **//
  AddCommand(@MinMaxTIA, 'procedure XT_MinMaxTIA(const Arr: TIntArray; var Min:Integer; var Max: Integer);');
  AddCommand(@MinMaxTEA, 'procedure XT_MinMaxTEA(const Arr: TExtArray; var Min:Extended; var Max: Extended);');
  AddCommand(@SumTIA,    'function XT_SumTIA(const Arr: TIntArray): Integer;');
  AddCommand(@SumTEA,    'function XT_SumTEA(const Arr: TExtArray): Extended;');
  AddCommand(@TIAsToTPA, 'procedure XT_TIAsToTPA(const X:TIntArray; const Y:TIntArray; var TPA:TPointArray);');
  AddCommand(@TIAToATIA, 'function XTCore_TIAToATIA(const Arr:TIntArray; Width,Height:Integer): T2DIntArray;');
  
  
  //** Finder.pas **//
  AddCommand(@FindColorTolExLCH, 'function XTCore_FindColorTolExLCH(const ImgArr:T2DIntArray; var TPA:TPointArray; Color, ColorTol, LightTol:Integer): Boolean;');
  AddCommand(@FindColorTolExLAB, 'function XTCore_FindColorTolExLAB(const ImgArr:T2DIntArray; var TPA:TPointArray; Color, ColorTol, LightTol:Integer): Boolean;');


  //** ContrastEdges.pas **//
  AddCommand(@ContrastEdges,     'function XT_ContrastEdges(const ImgArr: T2DIntArray; MinDiff: Integer): TPointArray;');
  AddCommand(@ContrastEdgesGray, 'function XT_ContrastEdgesGray(const ImgArr: T2DIntArray; MinDiff: Integer): TPointArray;');
  
  
  //** DensityMap.pas **//
  AddCommand(@DensityMap,       'function XT_DensityMap(const TPA:TPointArray; Radius, Passes:Integer): T2DExtArray;');
  AddCommand(@DensityMapNormed, 'function XT_DensityMapNormed(const TPA:TPointArray; Radius, Passes, Beta:Integer): T2DIntArray;');
  AddCommand(@TPADensitySort,   'procedure XT_TPADensitySort(var Arr: TPointArray; Radius, Passes:Integer);');
  
  
  //** Points.pas **//
  AddCommand(@ClusterTPAEx,    'function XT_ClusterTPAEx(const TPA: TPointArray; Distx,Disty:Integer; EightWay:Boolean): T2DPointArray;');
  AddCommand(@ClusterTPA,      'function XT_ClusterTPA(const TPA: TPointArray; Distance:Integer; EightWay:Boolean): T2DPointArray;');
  AddCommand(@MoveTPA,         'procedure XT_MoveTPA(var TPA: TPointArray; SX,SY:Integer);');
  AddCommand(@SumTPA,          'function XT_SumTPA(const Arr: TPointArray): TPoint;');
  AddCommand(@ReverseTPA,      'procedure XT_ReverseTPA(var TPA: TPointArray);');
  AddCommand(@UniteTPA,        'function XT_UniteTPA(const TPA1, TPA2: TPointArray; RemoveDupes:Boolean): TPointArray;');
  AddCommand(@InvertTPA,       'function XT_InvertTPA(const TPA:TPointArray): TPointArray;');
  AddCommand(@GetAdjacent,     'procedure XT_GetAdjacent(var adj:TPointArray; n:TPoint; EightWay:boolean);');
  AddCommand(@TPALine,         'procedure XT_TPALine(var TPA:TPointArray; P1, P2: TPoint);');
  AddCommand(@ConnectTPA,      'function XT_ConnectTPA(const TPA:TPointArray): TPointArray;');
  AddCommand(@ConnectTPAEx,    'function XT_ConnectTPAEx(TPA:TPointArray; Tension:Extended): TPointArray;');
  AddCommand(@TPALine,         'procedure XT_TPALine(var TPA:TPointArray; const P1:TPoint; const P2: TPoint)');
  AddCommand(@TPACircle,       'procedure XT_TPACircle(var TPA:TPointArray; const Center: TPoint; Radius:Integer);');
  AddCommand(@TPAEllipse,      'procedure XT_TPAEllipse(var TPA:TPointArray; const Center: TPoint; RadX,RadY:Integer);');
  AddCommand(@TPASimplePoly,   'procedure XT_TPASimplePoly(var TPA:TPointArray; const Center: TPoint; Sides:Integer; const Dir:TPoint);');
  AddCommand(@XagonPoints,     'function XT_XagonPoints(const Center:TPoint; Sides:Integer; const Dir:TPoint): TPointArray;');
  AddCommand(@ConvexHull,      'function XT_ConvexHull(const TPA:TPointArray): TPointArray;');
  AddCommand(@CleanSortTPA,    'function XT_CleanSortTPA(const TPA: TPointArray): TPointArray;');
  AddCommand(@TPAOutline,      'function XT_TPAOutline(const TPA:TPointArray): TPointArray;');
  AddCommand(@TPABorder,       'function XT_TPABorder(const TPA:TPointArray): TPointArray;');
  AddCommand(@TPAPartition,    'function XT_TPAPartition(const TPA:TPointArray; BoxWidth, BoxHeight:Integer): T2DPointArray;');
  AddCommand(@FloodFillTPA,    'function XT_FloodFillTPA(const TPA:TPointArray; const Start:TPoint; EightWay:Boolean): TPointArray;');
  AddCommand(@FloodFillTPAEx,  'function XT_FloodFillTPAEx(const TPA:TPointArray; const Start:TPoint; EightWay, KeepEdges:Boolean): TPointArray;');
  AddCommand(@FloodFillPolygon,'function XT_FloodFillPolygon(const Poly:TPointArray; EightWay:Boolean): TPointArray;');
  AddCommand(@TPASeparateAxis, 'procedure XT_TPASeparateAxis(const TPA: TPointArray; var X:TIntArray; var Y:TIntArray);');
  AddCommand(@TPAFilterBounds, 'procedure XT_TPAFilterBounds(var TPA: TPointArray; x1,y1,x2,y2:Integer);');
  AddCommand(@TPASkeleton,     'function XT_TPASkeleton(const TPA:TPointArray; FMin,FMax:Integer): TPointArray;');

  //** CSpline.pas **//
  AddCommand(@CSpline, 'function XT_CSpline(const TPA:TPointArray; Tension:Extended; Connect:Boolean): TPointArray;');

  //** TPAExtShape.pas **//
  AddCommand(@TPAExtractShape, 'function XT_TPAExtractShape(const PTS:TPointArray; Distance, EstimateRad:Integer): TPointArray;');


  //** Collection.pas **//
  AddCommand(@IntMatrix,       'function XT_IntMatrix(W,H, Init:Integer): T2DIntArray;');
  AddCommand(@IntMatrixNil,    'function XT_IntMatrixNil(W,H:Integer): T2DIntArray;');
  AddCommand(@IntMatrixSetPts, 'procedure XT_IntMatrixSetPts(var Matrix:T2DIntArray; const Pts:TPointArray; Value:Integer; const Align:TPoint);');
  AddCommand(@BoolMatrix,      'function XT_BoolMatrix(W,H:Integer; Init:Boolean): T2DBoolArray;');
  AddCommand(@BoolMatrixNil,   'function XT_BoolMatrixNil(W,H:Integer): T2DBoolArray;');
  AddCommand(@BoolMatrixSetPts,'procedure XT_BoolMatrixSetPts(var Matrix:T2DBoolArray; const Pts:TPointArray; Value:Boolean; const Align:TPoint);');

  AddCommand(@TPAToIntMatrix,     'function XT_TPAToIntMatrix(const TPA:TPointArray; Init, Value:Integer; Align:Boolean): T2DIntArray;');
  AddCommand(@TPAToIntMatrixNil,  'function XT_TPAToIntMatrixNil(const TPA:TPointArray; Value:Integer; Align:Boolean): T2DIntArray;');
  AddCommand(@TPAToBoolMatrix,    'function XT_TPAToBoolMatrix(const TPA:TPointArray; Init, Value:Boolean; Align:Boolean): T2DBoolArray;');
  AddCommand(@TPAToBoolMatrixNil, 'function XT_TPAToBoolMatrixNil(const TPA:TPointArray; Value:Boolean; Align:Boolean): T2DIntArray;');

  AddCommand(@BlurImageArr,   'procedure XT_BlurImageArr(var ImgArr:T2DIntArray; Radius:Integer);');
  AddCommand(@NormalizeATIA,  'function XT_NormalizeATIA(const ATIA:T2DIntArray; Alpha, Beta:Integer): T2DIntArray;');
  AddCommand(@ATIAGetIndices, 'function XT_ATIAGetIndices(const ATIA:T2DIntArray; const Indices:TPointArray): TIntArray;');
  
  
  //** Randomize.pas **//
  AddCommand(@RandomTPA,      'function XT_RandomTPA(Amount:Integer; MinX,MinY,MaxX,MaxY:Integer): TPointArray;');
  AddCommand(@RandomCenterTPA,'function XT_RandomCenterTPA(Amount:Integer; CX,CY,RadX,RadY:Integer): TPointArray;');
  
  CommandsLoaded := True;
end;


procedure UnsetupCommands;
begin
  SetLength(commands, 0);
  CommandsLoaded := False;
end;

function GetFunctionCount(): Integer; stdcall;
begin
  if not commandsLoaded then
    SetupCommands;
  Result := Length(commands);
end;

function GetFunctionInfo(x: Integer; var ProcAddr: Pointer; var ProcDef: PAnsiChar): Integer; stdcall;
begin
  if ((x > -1) and InRange(x, Low(commands), High(commands))) then
  begin
    ProcAddr := commands[x].procAddr;
    StrPCopy(ProcDef, commands[x].procDef);
    if (x = High(commands)) then UnsetupCommands;
    Exit(x);
  end;
  Exit(-1);
end;

exports GetFunctionCount;
exports GetFunctionInfo;

end.
