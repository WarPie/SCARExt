library SCARExt;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 Copyright (c) 2013, Jarl K. Holta || http://github.com/WarPie
 All rights reserved.
 For more info see: Copyright.txt
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

uses
  FastShareMem,
  SysUtils,
  Math,

  XT_Types,
  XT_Standard,
  XT_TPointList,
  XT_Sorting,
  XT_Math,
  XT_Matrix,
  XT_ColorMath,
  XT_HashTable,
  XT_Numeric,
  XT_Imaging,
  XT_Randomize,
  XT_Points,
  XT_Finder,
  XT_SimpleOCR,
  XT_CSpline,
  XT_Morphology,
  XT_DensityMap,
  XT_TPAExtShape;

  
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
  AddCommand(@Modulo,     'function XT_Mod(X,Y:Extended): Extended;'); //Alias^
  AddCommand(@InCircle,   'function XT_InCircle(const Pt, Center: TPoint; Radius: Integer): Boolean;');
  AddCommand(@InEllipse,  'function XT_InEllipse(const Pt,Center:TPoint; YRad, XRad: Integer): Boolean;');
  AddCommand(@InRect,     'function XT_InRect(const Pt:TPoint; const A,B,C,D:TPoint): Boolean;');
  AddCommand(@InPoly,     'function XT_InPoly(x,y:Integer; const Poly:TPointArray): Boolean;');
  AddCommand(@InPolyR,    'function XT_InPolyR(x,y:Integer; const Poly:TPointArray): Boolean;');
  AddCommand(@InPolyW,    'function XT_InPolyW(x,y:Integer; const Poly:TPointArray): Boolean;');
  AddCommand(@DeltaAngle, 'function XT_DeltaAngle(DegA,DegB:Extended): Extended;');
  
  
  //** Numeric.pas **//
  AddCommand(@SumTIA,    'function XT_SumTIA(const Arr: TIntArray): Integer;');
  AddCommand(@SumTEA,    'function XT_SumTEA(const Arr: TExtArray): Extended;');
  AddCommand(@TIACombinations, 'function XT_TIACombinations(const Arr: TIntArray; Seq:Integer): T2DIntArray;');
  AddCommand(@TEACombinations, 'function XT_TEACombinations(const Arr: TExtArray; Seq:Integer): T2DExtArray;');
  AddCommand(@MinMaxTIA, 'procedure XT_MinMaxTIA(const Arr: TIntArray; var Min:Integer; var Max: Integer);');
  AddCommand(@MinMaxTEA, 'procedure XT_MinMaxTEA(const Arr: TExtArray; var Min:Extended; var Max: Extended);');
  AddCommand(@TIAMatches,'function XT_TIAMatches(const Arr1, Arr2:TIntArray; InPercent, Inversed:Boolean): Integer;');

  
  //** Sorting.pas **//
  AddCommand(@SortTIA, 'procedure XT_SortTIA(var Arr: TIntArray);');
  AddCommand(@SortTEA, 'procedure XT_SortTEA(var Arr: TExtArray);');
  AddCommand(@SortTPA, 'procedure XT_SortTPA(var Arr: TPointArray);');
  AddCommand(@SortTPAFrom,     'procedure XT_SortTPAFrom(var Arr: TPointArray; const From:TPoint);');
  AddCommand(@SortTPAByRow,    'procedure XT_SortTPAByRow(var Arr: TPointArray);');
  AddCommand(@SortTPAByColumn, 'procedure XT_SortTPAByColumn(var Arr: TPointArray);');


  //** Finder.pas **//
  AddCommand(@ImFindColorTolEx,    'function XT_ImFindColorTolEx(const ImgArr:T2DIntArray; var TPA:TPointArray; Color, Tol:Integer): Boolean;');
  AddCommand(@ImFindColorTolExLCH, 'function XT_ImFindColorTolExLCH(const ImgArr:T2DIntArray; var TPA:TPointArray; Color, ColorTol, LightTol:Integer): Boolean;');
  AddCommand(@ImFindColorTolExLAB, 'function XT_ImFindColorTolExLAB(const ImgArr:T2DIntArray; var TPA:TPointArray; Color, ColorTol, LightTol:Integer): Boolean;');


  //** SimpleOCR.pas **//
  AddCommand(@ImGetTextEx, 'function XT_ImGetTextEx(ImgArr:T2DIntArray; Font:TChars; MinSpace, TextPixTol: Integer; Range:AnsiString): AnsiString;');

  
  //** DensityMap.pas **//
  AddCommand(@DensityMap,       'function XT_DensityMap(const TPA:TPointArray; Radius, Passes:Integer): T2DExtArray;');
  AddCommand(@DensityMapNormed, 'function XT_DensityMapNormed(const TPA:TPointArray; Radius, Passes, Beta:Integer): T2DIntArray;');
  AddCommand(@TPADensitySort,   'procedure XT_TPADensitySort(var Arr: TPointArray; Radius, Passes:Integer);');
  

  //** Points.pas **//
  AddCommand(@ScalePoint,      'function XT_ScalePoint(const Center, Pt:TPoint; Radius:Integer): TPoint;');
  AddCommand(@SumTPA,          'function XT_SumTPA(Arr: TPointArray): TPoint;');
  AddCommand(@TPASplitAxis,    'procedure XT_TPASplitAxis(const TPA: TPointArray; var X:TIntArray; var Y:TIntArray);');
  AddCommand(@TPAJoinAxis,     'procedure XT_TPAJoinAxis(const X:TIntArray; const Y:TIntArray; var TPA:TPointArray);');
  AddCommand(@TPAFilter,       'procedure XT_TPAFilter(var TPA: TPointArray; const Shape:TPointArray; const TopLeft:TPoint);');
  AddCommand(@TPAFilterBounds, 'procedure XT_TPAFilterBounds(var TPA: TPointArray; x1,y1,x2,y2:Integer);');
  AddCommand(@ATPAFilter,      'procedure XT_ATPAFilter(var ATPA: T2DPointArray; MinLength, MinW, MinH, MaxW, MaxH: Integer; Align:Boolean);');
  AddCommand(@TPAExtremes,     'function XT_TPAExtremes(const TPA:TPointArray): TPointArray;');
  AddCommand(@TPABBox,         'function XT_TPABBox(const TPA:TPointArray): TPointArray;');
  AddCommand(@TPABBox,         'function XT_TPABoundingBox(const TPA:TPointArray): TPointArray;'); //Alias ^
  AddCommand(@TPACenter,       'function XT_TPACenter(const TPA: TPointArray; Method: TCenterMethod; Inside:Boolean): TPoint;');
  AddCommand(@GetAdjacent,     'procedure XT_GetAdjacent(var adj:TPointArray; n:TPoint; EightWay:Boolean);');
  AddCommand(@ReverseTPA,      'procedure XT_ReverseTPA(var TPA: TPointArray);');
  AddCommand(@MoveTPA,         'procedure XT_MoveTPA(var TPA: TPointArray; SX,SY:Integer);');
  AddCommand(@TPARemoveDupes,  'procedure XT_TPARemoveDupes(var TPA: TPointArray);');
  AddCommand(@LongestPolyVector, 'procedure XT_LongestPolyVector(const Poly:TPointArray; var A,B:TPoint);');
  AddCommand(@InvertTPA,       'function XT_InvertTPA(const TPA:TPointArray): TPointArray;');
  AddCommand(@RotateTPAEx,     'function XT_RotateTPAEx(const TPA: TPointArray; const Center:TPoint; Radians: Extended): TPointArray;');
  AddCommand(@TPAPartition,    'function XT_TPAPartition(const TPA:TPointArray; BoxWidth, BoxHeight:Integer): T2DPointArray;');
  AddCommand(@AlignTPA,        'function XT_AlignTPA(const TPA:TPointArray; Method: TAlignMethod; var Angle:Extended): TPointArray;');
  AddCommand(@CleanSortTPA,    'function XT_CleanSortTPA(const TPA: TPointArray): TPointArray;');
  AddCommand(@UniteTPA,        'function XT_UniteTPA(const TPA1, TPA2: TPointArray; RemoveDupes:Boolean): TPointArray;');
  AddCommand(@TPALine,         'procedure XT_TPALine(var TPA:TPointArray; const P1:TPoint; const P2: TPoint);');
  AddCommand(@ConnectTPA,      'function XT_ConnectTPA(const TPA:TPointArray): TPointArray;');
  AddCommand(@ConnectTPAEx,    'function XT_ConnectTPAEx(TPA:TPointArray; Tension:Extended): TPointArray;');
  AddCommand(@XagonPoints,     'function XT_XagonPoints(const Center:TPoint; Sides:Integer; const Dir:TPoint): TPointArray;');
  AddCommand(@TPAEllipse,      'procedure XT_TPAEllipse(var TPA:TPointArray; const Center: TPoint; RadX,RadY:Integer);');
  AddCommand(@TPACircle,       'procedure XT_TPACircle(var TPA:TPointArray; const Center: TPoint; Radius:Integer);');
  AddCommand(@TPASimplePoly,   'procedure XT_TPASimplePoly(var TPA:TPointArray; const Center:TPoint; Sides:Integer; const Dir:TPoint);');
  AddCommand(@ConvexHull,      'function XT_ConvexHull(const TPA:TPointArray): TPointArray;');
  AddCommand(@FloodFillTPAEx,  'function XT_FloodFillTPAEx(const TPA:TPointArray; const Start:TPoint; EightWay, KeepEdges:Boolean): TPointArray;');
  AddCommand(@FloodFillTPA,    'function XT_FloodFillTPA(const TPA:TPointArray; const Start:TPoint; EightWay:Boolean): TPointArray;');
  AddCommand(@TPAOutline,      'function XT_TPAOutline(const TPA:TPointArray): TPointArray;');
  AddCommand(@TPABorder,       'function XT_TPABorder(const TPA:TPointArray): TPointArray;');
  AddCommand(@FloodFillPolygon,'function XT_FloodFillPolygon(const Poly:TPointArray; EightWay:Boolean): TPointArray;');
  AddCommand(@ClusterTPAEx,    'function XT_ClusterTPAEx(const TPA: TPointArray; Distx,Disty: Integer; EightWay:Boolean): T2DPointArray;');
  AddCommand(@ClusterTPA,      'function XT_ClusterTPA(const TPA: TPointArray; Distance: Integer; EightWay:Boolean): T2DPointArray;');
  AddCommand(@TPAEdges,        'function XT_TPAEdges(const TPA: TPointArray): TPointArray;');

  
  //** CSpline.pas **//
  AddCommand(@CSpline, 'function XT_CSpline(const TPA:TPointArray; Tension:Extended; Connect:Boolean): TPointArray;');
  
  
  //** TPAExtShape.pas **//
  AddCommand(@TPAExtractShape, 'function XT_TPAExtractShape(const PTS:TPointArray; Distance, EstimateRad:Integer): TPointArray;');
  
  
  //** Morphology.pas **//
  AddCommand(@TPASkeleton, 'function XT_TPASkeleton(const TPA:TPointArray; FMin,FMax:Integer): TPointArray;');
  AddCommand(@TPAReduce,   'function XT_TPAReduce(const TPA:TPointArray; FMin,FMax, Iterations:Integer): TPointArray;');
  AddCommand(@TPAExpand,   'function XT_TPAExpand(const TPA:TPointArray; Iterations:Integer): TPointArray;');

  
  //** Matrix.pas **//
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
  
  AddCommand(@NormalizeMat,  'function XT_NormalizeMat(const Mat:T2DIntArray; Alpha, Beta:Integer): T2DIntArray;');
  AddCommand(@MatGetValues,  'function XT_MatGetValues(const Mat:T2DIntArray; const Indices:TPointArray): TIntArray;');
  AddCommand(@MatCombine,    'procedure XT_MatCombine(var Mat:T2DIntArray; const Mat2:T2DIntArray; Value:Integer);');
  AddCommand(@MatGetCol,     'function XT_MatGetCol(const Mat:T2DIntArray; Column:Integer): TIntArray;'); 
  AddCommand(@MatGetRow,     'function XT_MatGetRow(const Mat:T2DIntArray; Row:Integer): TIntArray;');
  AddCommand(@MatGetCols,    'function XT_MatGetCols(const Mat:T2DIntArray; FromCol, ToCol:Integer): T2DIntArray;');
  AddCommand(@MatGetRows,    'function XT_MatGetRows(const Mat:T2DIntArray; FromRow, ToRow:Integer): T2DIntArray;');
  AddCommand(@MatGetArea,    'function XT_MatGetArea(const Mat:T2DIntArray; X1,Y1,X2,Y2:Integer): T2DIntArray;');
  AddCommand(@MatFromTIA,    'function XT_MatFromTIA(const Arr:TIntArray; Width,Height:Integer): T2DIntArray;');
  AddCommand(@PadMatrix,     'procedure XT_PadMatrix(var Matrix:T2DIntArray; HPad,WPad:Integer);');

  
  //** Imaging.pas **//
  AddCommand(@ImBlurFilter,   'function XT_ImBlurFilter(ImgArr: T2DIntArray; Block:Integer): T2DIntArray;');
  AddCommand(@ImMedianFilter, 'function XT_ImMedianFilter(ImgArr: T2DIntArray; Block:Integer):T2DIntArray;');
  AddCommand(@ImThreshold,    'function XT_ImThreshold(const ImgArr:T2DIntArray; Threshold, Alpha, Beta:Byte; Invert:Boolean): T2DIntArray;');
  AddCommand(@ImThresholdAdaptive, 'function XT_ImThresholdAdaptive(const ImgArr:T2DIntArray; Alpha, Beta: Byte; Invert:Boolean; Method:TThreshMethod; C:Integer): T2DIntArray;');
  AddCommand(@ImFindContours, 'function XT_ImFindContours(const ImgArr:T2DIntArray; Outlines:Boolean): T2DPointArray;');
  AddCommand(@ImCEdges,       'function XT_ImCEdges(const ImgArr: T2DIntArray; MinDiff: Integer): TPointArray;');
  AddCommand(@ImResize,       'procedure XT_ImResize(var ImgArr:T2DIntArray; NewW, NewH: Integer; Method:TResizeMethod);');

  
  //** Randomize.pas **//
  AddCommand(@RandomTPA,      'function XT_RandomTPA(Amount:Integer; MinX,MinY,MaxX,MaxY:Integer): TPointArray;');
  AddCommand(@RandomCenterTPA,'function XT_RandomCenterTPA(Amount:Integer; CX,CY,RadX,RadY:Integer): TPointArray;');
  AddCommand(@RandomTIA,      'function XT_RandomTIA(Amount:Integer; Low,Hi:Integer): TIntArray;');
  
  
  //** Faster SetLength for PS **//
  AddCommand(@SetLengthTPA,  'procedure SetLengthTPA(var Arr: TPointArray; NewSize:Integer);');
  AddCommand(@SetLengthTIA,  'procedure SetLengthTIA(var Arr: TIntArray; NewSize:Integer);');
  AddCommand(@SetLengthTEA,  'procedure SetLengthTEA(var Arr: TExtArray; NewSize:Integer);');
  AddCommand(@SetLengthTBA,  'procedure SetLengthTBA(var Arr: TByteArray; NewSize:Integer);');
  AddCommand(@SetLengthTBoA,  'procedure SetLengthTBoA(var Arr: TBoolArray; NewSize:Integer);');
  AddCommand(@SetLengthATIA,  'procedure SetLengthATIA(var Arr: T2DIntArray; NewSize:Integer);');
  AddCommand(@SetLengthATEA,  'procedure SetLengthATEA(var Arr: T2DExtArray; NewSize:Integer);');
  AddCommand(@SetLengthATBA,  'procedure SetLengthATBA(var Arr: T2DByteArray; NewSize:Integer);');
  AddCommand(@SetLengthATBoA, 'procedure SetLengthATBoA(var Arr: T2DBoolArray; NewSize:Integer);');

  
  CommandsLoaded := True;
end;


procedure UnsetupCommands;
begin
  SetLength(commands, 0);
  CommandsLoaded := False;
end;


function GetFunctionCount: Integer; StdCall;
begin
  if not commandsLoaded then
    SetupCommands;
  Result := Length(commands);
end;

function GetFunctionInfo(x: Integer; var ProcAddr: Pointer; var ProcDef: PAnsiChar): Integer; StdCall;
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

function GetTypeCount: Integer; StdCall;
begin
  Result := 5;
end;

function GetTypeInfo(x: Integer; var sType, sTypeDef: AnsiString): Integer; StdCall; Export;
begin
  case x of
    0:begin
        sType := 'TAlignMethod';
        sTypeDef := '(AM_Extremes, AM_Convex, AM_BBox);';
      end;
    1:begin
        sType := 'TThreshMethod';
        sTypeDef := '(TM_Mean, TM_MinMax);';
      end;
    2:begin
        sType := 'TCenterMethod';
        sTypeDef := '(CM_Bounds, CM_BBox, CM_Mean, CM_Median);';
      end;
    3:begin
        sType := 'TResizeMethod';
        sTypeDef := '(RM_Nearest, RM_Bilinear, RM_Bicubic);';
      end;
    4:begin
        sType := 'TChars';
        sTypeDef := 'Array of T2DIntArray;';
      end;
  else
    x := -1;
  end;
  Result := x;
end;

exports GetTypeCount;
exports GetTypeInfo;
exports GetFunctionCount;
exports GetFunctionInfo;

end.
