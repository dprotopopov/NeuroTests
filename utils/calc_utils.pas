unit calc_utils;

interface

uses SysUtils, Ap, mlpbase, mlptrain;

procedure ConstructMatrixFromLine(lX: TReal1DArray; aSubLineWidth, aStep: Integer; out lXY: TReal2DArray);
procedure CalcNeuroMatrix(aLevelCount:byte; lXY: TReal2DArray; out lNetwork: MultiLayerPerceptron);
procedure GetSubLine(aXSrc: TReal1DArray; aPosition, aSubLineWidth: Integer; var aXDest: TReal1DArray); inline;
function NeuroRegression(var lNetwork: MultiLayerPerceptron; lX: TReal1DArray; var lY: TReal1DArray): extended;

implementation
uses Math;

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

procedure CalcNeuroMatrix(aLevelCount:byte; lXY: TReal2DArray; out lNetwork: MultiLayerPerceptron);
var
  lInCount: Integer;
  lOutCount: Integer;
  lMaxIts: Integer;
  lMaxStep: Double;
  lRestarts: Integer;
  lDecay: Double;
  lPoints: Integer;

  lInfo: Integer;
  lReport: MLPReport;
begin
  Randomize;
  lInCount := Length(lXY[0]) - 1; // количество точек данных в одной выборке
  lOutCount := 1; // кличество точек - заведомо корректных результатов
  lMaxIts := 500; // количество итераций обучения (внутреннее)
  lMaxStep := 0.001; // внутренний параметр обучения нейросети
  lRestarts := 500; // внутренний параметр обучения нейросети
  lDecay := 0.001; // затухание.  внутренний параметр обучения нейросети
  lPoints := Length(lXY); // количество обучающих выборок (в нашем лучае можно и поменьше)

  // здесь можно использовать любую из функций MLPCreate
  case aLevelCount of
    1: MLPCreate0(lInCount, lOutCount, {0, 50,} lNetwork);
    2: MLPCreate1(lInCount, lInCount, lOutCount, {0, 50,} lNetwork);
    else MLPCreate2(lInCount, lInCount, lInCount, lOutCount, {0, 50,} lNetwork);
  end;  

  // один из методов обучения. Можно использовать любой другой
  MLPTrainLBFGS(lNetwork, lXY, lPoints, lDecay, lRestarts, lMaxStep, lMaxIts, lInfo, lReport);
  //MLPTrainLM(lNetwork, lXY, lPoints, lDecay, lRestarts, lInfo, lReport);
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

end.
