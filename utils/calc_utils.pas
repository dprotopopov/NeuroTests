unit calc_utils;

interface

uses Windows, SysUtils, graphics, Ap, mlpbase, mlptrain;

procedure NewEmptyMatrix(aWidth, aHeight: Integer; out lXY: TReal2DArray);
procedure ConstructMatrixFromLine(lX: TReal1DArray; aSubLineWidth, aStep, aCount: Integer; out lXY: TReal2DArray);
procedure CalcNeuroMatrix(aClassificator: boolean; aLevelCount: byte; lInCount, lOutCount: Integer; lXY: TReal2DArray;
  out lNetwork: MultiLayerPerceptron);
procedure GetSubLine(aXSrc: TReal1DArray; aPosition, aSubLineWidth: Integer; var aXDest: TReal1DArray);
procedure PutImageToArrayLine(aImageIdx, aCharIdx: Integer; aCanvas: TCanvas; aWidth, aHeight: Integer;
  var lXY: TReal2DArray);
procedure Get1DArrayFromImage(aCanvas: TCanvas; aWidth, aHeight: Integer; var lX: TReal1DArray);
function NeuroRegression(var lNetwork: MultiLayerPerceptron; lX: TReal1DArray; var lY: TReal1DArray): AlglibFloat;

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

procedure ConstructMatrixFromLine(lX: TReal1DArray; aSubLineWidth, aStep, aCount: Integer; out lXY: TReal2DArray);
var
  x, y: Integer;
  zYCount: Integer;
begin
  //zYCount := Length(lX) - aSubLineWidth;
  zYCount := aCount;
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
  x, y:Integer;
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
  lMaxStep := 0.001; // коэффициент при векторе градиента (влияет на шаг смещения)
  lRestarts := 50000; // внутренний параметр обучения нейросети
  lDecay := 0.01; // добавление к градиенту веса с указанным затуханием
  lPoints := Length(lXY); // количество обучающих выборок (в нашем лучае можно и поменьше)

  // здесь можно использовать любую из функций MLPCreate
  case aClassificator of
    false:
      case aLevelCount of
        1:
          MLPCreate0(lInCount, lOutCount,  {0, 1,}  lNetwork);
        2:
          MLPCreate1(lInCount, lInCount, lOutCount, {0, 1,} lNetwork);
      else
        MLPCreate2(lInCount, lInCount, lInCount, lOutCount, {0, 1,} lNetwork);
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
  MLPTrainLBFGS_MT_Mod(lNetwork, lXY, lPoints, lDecay, lRestarts, lMaxStep, 50, lMaxIts, lInfo, lReport);
  //MLPTrainMonteCarlo(lNetwork, lXY, lPoints, 10, lRestarts, 0, lMaxIts, lInfo, lReport);
  //MLPTrainLM(lNetwork, lXY, lPoints, lDecay, lRestarts, lInfo, lReport);
  //MLPTrainES(lNetwork, lXY, lPoints, lXY, lPoints, lDecay, lRestarts, lInfo, lReport);

end;

// aSubLineWidth - длина строки с конечным обучающим значением
procedure GetSubLine(aXSrc: TReal1DArray; aPosition, aSubLineWidth: Integer; var aXDest: TReal1DArray); inline;
var
  i: Integer;
begin
  for i := 0 to aSubLineWidth - 1 do
    aXDest[i] := aXSrc[i + aPosition];
end;

function NeuroRegression(var lNetwork: MultiLayerPerceptron; lX: TReal1DArray; var lY: TReal1DArray): AlglibFloat;
begin
  MLPProcess(lNetwork, lX, lY);
  Result := lY[0];
end;

function RgbToGray(RGBColor: TColor): AlglibFloat;
begin
  Result := (0.299 * GetRValue(RGBColor)) +
  (0.587 * GetGValue(RGBColor)) +
  (0.114 * GetBValue(RGBColor )) * (1 / 255);
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
        lXY[aImageIdx, i] := RgbToGray(aCanvas.Pixels[x, y]);
        inc(i);
      end;

    // не указываем зарезервированные параметры
    if (aCharIdx <> -1) then
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
        lX[i] := RgbToGray(aCanvas.Pixels[x, y]);
        inc(i);
      end;
  finally
    aCanvas.Unlock;
  end;
end;

end.
