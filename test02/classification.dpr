// {$MODESWITCH RESULT+}
program classification;
{$APPTYPE CONSOLE}

uses
  SysUtils,
  Ap,
  mlpbase,
  mlptrain;

procedure DoProcess(const X0, X1: Double; var Net: MultiLayerPerceptron; X: TReal1DArray; var Y: TReal1DArray);
begin
  X[0] := X0; // RandomReal - 0.5;
  X[1] := X1; // RandomReal - 0.5;
  MLPProcess(Net, X, Y);
end;

procedure PrintMatrix(X: TReal1DArray; Y: TReal1DArray; aIteration: Integer);
begin
  WriteLn(Format('%d: %10.8f -> %10.8f -> %10.8f', [aIteration, X[0], X[1], Y[0]]));
end;

var
  i: Integer;

  zRow, zCol: Integer;
  lNetwork: MultiLayerPerceptron;
  lXY: TReal2DArray;
  lInCount: Integer;
  lOutCount: Integer;
  lMaxIts: Integer;
  lMaxStep: Double;
  lRestarts: Integer;
  lDecay: Double;
  lPoints: Integer;

  lNHid1: Integer;
  lNHid2: Integer;

  lInfo: Integer;
  lReport: MLPReport;

  lX, lY: TReal1DArray;

begin

  lInCount := 2; // количество точек данных в одной выборке
  lOutCount := 1; // кличество точек - заведомо корректных результатов
  lMaxIts := 500; // количество итераций обучения (внутреннее)
  lMaxStep := 0.001; // внутренний параметр обучения нейросети
  lRestarts := 500; // внутренний параметр обучения нейросети
  lDecay := 0.001; // затухание.  внутренний параметр обучения нейросети
  lPoints := 400;//40; // количество обучающих выборок (в нашем лучае можно и поменьше)

  lNHid1 := lInCount; // количество узлов в 1-ом скрытом слое
  lNHid2 := lInCount; // количество узлов во 2-ом скрытом слое

  // здесь можно использовать любую из функций MLPCreate
  MLPCreate0(lInCount, {lNHid1, lNHid2, }lOutCount, lNetwork);

  SetLength(lXY, lPoints, lInCount + lOutCount);
  SetLength(lX, lInCount);
  SetLength(lY, lOutCount);
  APVFillValue(@lX[0], 0, lInCount - 1, 0);
  APVFillValue(@lY[0], 0, lOutCount - 1, 0);

  // заполним линейной прогрессией (для простоты изучения)
  for zRow := 0 to lPoints - 1 do
  begin
    for zCol := 0 to lInCount - 1 do
    begin
      lXY[zRow, zCol] := zCol + zRow;
    end;
    lXY[zRow, lInCount] := lInCount + zRow;
  end;

  // один из методов обучения. Можно использовать любой другой
  //MLPTrainLBFGS_MT_Mod(lNetwork, lXY, lPoints, lRestarts, lMaxStep, 10, lMaxIts, lInfo, lReport);
  MLPTrainLBFGS_MT(lNetwork, lXY, lPoints, lDecay, lRestarts, lMaxStep, lMaxIts, lInfo, lReport);
  //MLPTrainLM(lNetwork, lXY, lPoints, lDecay, lRestarts, lInfo, lReport);
  //MLPTrainMonteCarlo(lNetwork, lXY, lPoints, 10, lRestarts, 0, 10, lInfo, lReport);

  for i := lPoints - 5 to lPoints + 15 do
  begin
    DoProcess(1 + i, 2 + i, lNetwork, lX, lY);
    PrintMatrix(lX, lY, i + 1);
  end;

  ReadLn;

end.
