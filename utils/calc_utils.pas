unit calc_utils;

interface

uses SysUtils, graphics, Ap, mlpbase, mlptrain;

procedure NewEmptyMatrix(aWidth, aHeight: Integer; out lXY: TReal2DArray);
procedure ConstructMatrixFromLine(lX: TReal1DArray; aSubLineWidth, aStep: Integer; out lXY: TReal2DArray);
procedure CalcNeuroMatrix(aClassificator: boolean; aLevelCount: byte; lInCount, lOutCount: Integer; lXY: TReal2DArray;
  out lNetwork: MultiLayerPerceptron);
procedure GetSubLine(aXSrc: TReal1DArray; aPosition, aSubLineWidth: Integer; var aXDest: TReal1DArray);
procedure PutImageToArrayLine(aImageIdx, aCharIdx: Integer; aCanvas: TCanvas; aWidth, aHeight: Integer;
  var lXY: TReal2DArray);
procedure Get1DArrayFromImage(aCanvas: TCanvas; aWidth, aHeight: Integer; var lX: TReal1DArray);
function NeuroRegression(var lNetwork: MultiLayerPerceptron; lX: TReal1DArray; var lY: TReal1DArray): extended;

implementation

uses Math;

procedure NewEmptyMatrix(aWidth, aHeight: Integer; out lXY: TReal2DArray);
var
  x, y: Integer;
begin
  SetLength(lXY, aHeight, aWidth);
  for y := Low(lXY) to High(lXY) do
    for x := Low(lXY[0]) to High(lXY[0]) do
      lXY[y, x] := 0;
end;

procedure ConstructMatrixFromLine(lX: TReal1DArray; aSubLineWidth, aStep: Integer; out lXY: TReal2DArray);
var
  x, y: Integer;
  zYCount: Integer;
begin
  zYCount := Length(lX) - aSubLineWidth;
  SetLength(lXY, zYCount, aSubLineWidth + 1);
  y := 0;
  while y < zYCount do
  begin
    for x := 0 to aSubLineWidth - 1 do
      lXY[y, x] := lX[y + x];
    inc(y, aStep);
  end;
end;

procedure CalcNeuroMatrix(aClassificator: boolean; aLevelCount: byte; lInCount, lOutCount: Integer; lXY: TReal2DArray;
  out lNetwork: MultiLayerPerceptron);
var
  lMaxIts: Integer;
  lMaxStep: Double;
  lRestarts: Integer;
  lDecay: Double;
  lPoints: Integer;

  lInfo: Integer;
  lReport: MLPReport;
begin
  Randomize;
  lMaxIts := 500; // количество итераций обучения (внутреннее)
  lMaxStep := 0.001; // внутренний параметр обучения нейросети
  lRestarts := 500; // внутренний параметр обучения нейросети
  lDecay := 0.001; // затухание.  внутренний параметр обучения нейросети
  lPoints := Length(lXY); // количество обучающих выборок (в нашем лучае можно и поменьше)

  // здесь можно использовать любую из функций MLPCreate
  case aClassificator of
    false:
      case aLevelCount of
        1:
          MLPCreate0(lInCount, lOutCount, { 0, 50, } lNetwork);
        2:
          MLPCreate1(lInCount, lInCount, lOutCount, { 0, 50, } lNetwork);
      else
        MLPCreate2(lInCount, lInCount, lInCount, lOutCount, { 0, 50, } lNetwork);
      end;
    true:
      case aLevelCount of
        1:
          MLPCreateC0(lInCount, lOutCount, { 0, 50, } lNetwork);
        2:
          MLPCreateC1(lInCount, lInCount, lOutCount, { 0, 50, } lNetwork);
      else
        MLPCreateC2(lInCount, lInCount, lInCount, lOutCount, { 0, 50, } lNetwork);
      end;
  end;

  // один из методов обучения. Можно использовать любой другой
  MLPTrainLBFGS(lNetwork, lXY, lPoints, lDecay, lRestarts, lMaxStep, lMaxIts, lInfo, lReport);
  // MLPTrainLM(lNetwork, lXY, lPoints, lDecay, lRestarts, lInfo, lReport);
end;

// aSubLineWidth - длина строки с конечным обучающим значением
procedure GetSubLine(aXSrc: TReal1DArray; aPosition, aSubLineWidth: Integer; var aXDest: TReal1DArray); inline;
var
  i: Integer;
begin
  for i := 0 to aSubLineWidth - 1 do
    aXDest[i] := aXSrc[i + aPosition];
end;

function NeuroRegression(var lNetwork: MultiLayerPerceptron; lX: TReal1DArray; var lY: TReal1DArray): extended;
begin
  MLPProcess(lNetwork, lX, lY);
  Result := lY[0];
end;

procedure PutImageToArrayLine(aImageIdx, aCharIdx: Integer; aCanvas: TCanvas; aWidth, aHeight: Integer;
  var lXY: TReal2DArray);
var
  x, y, i: Integer;
begin
  aCanvas.Lock;
  try
    i := 0;
    for y := 0 to aHeight - 1 do
      for x := 0 to aWidth - 1 do
      begin
        lXY[aImageIdx, i] := aCanvas.Pixels[x, y];
        inc(i);
      end;

    lXY[aImageIdx, aWidth * aHeight + aCharIdx] := 1;
  finally
    aCanvas.Unlock;
  end;
end;

procedure Get1DArrayFromImage(aCanvas: TCanvas; aWidth, aHeight: Integer; var lX: TReal1DArray);
var
  x, y, i: Integer;
begin
  aCanvas.Lock;
  try
    i := 0;
    for y := 0 to aHeight - 1 do
      for x := 0 to aWidth - 1 do
      begin
        lX[i] := aCanvas.Pixels[x, y];
        inc(i);
      end;
  finally
    aCanvas.Unlock;
  end;
end;

end.
