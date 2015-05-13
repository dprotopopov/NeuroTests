// {$MODESWITCH RESULT+}
program _demo;
{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils,
  Ap,
  mlpbase,
  mlptrain;
// testmlpeunit in '..\alglib\tests\testmlpeunit.pas';

procedure DoProcess(const X0, X1: Double; var Net: MultiLayerPerceptron; X: TReal1DArray; var Y: TReal1DArray);
begin
  X[0] := X0;
  X[1] := X1;
  MLPProcess(Net, X, Y);
end;

procedure PrintMatrix(X: TReal1DArray; Y: TReal1DArray; aIteration: Integer);
begin
  WriteLn(Format('%f + %f = %10.8f', [X[0], X[1], Y[0]]));
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

  lFreq, lBeginQPC, lEndQPC: int64;

begin

  lInCount := 2; // ���������� ����� ������ � ����� �������
  lOutCount := 1; // ��������� ����� - �������� ���������� �����������
  lMaxIts := 2000; // ���������� �������� �������� (����������)
  lMaxStep := 0.00001; // ���������� �������� �������� ���������
  lRestarts := 500; // ���������� �������� �������� ���������
  lDecay := 0.001; // ���������.  ���������� �������� �������� ���������
  lPoints := 20; // ���������� ��������� �������

  lNHid1 := lInCount; // ���������� ����� � 1-�� ������� ����
  lNHid2 := lInCount; // ���������� ����� �� 2-�� ������� ����

  // ����� ����� ������������ ����� �� ������� MLPCreate
  // MLPCreate0(lInCount, lOutCount, lNetwork);
  MLPCreate2(lInCount, lInCount, lInCount, lOutCount, lNetwork);

  SetLength(lXY, lPoints, lInCount + lOutCount);
  SetLength(lX, lInCount);
  SetLength(lY, lOutCount);

  // �������� �������� ����������� (��� �������� ��������)
  for zRow := 0 to lPoints - 1 do
  begin
    for zCol := 0 to lInCount - 1 do
    begin
      lXY[zRow, zCol] := zCol + zRow;
    end;
    lXY[zRow, lInCount] := lInCount + zRow;
  end;

  QueryPerformanceFrequency(lFreq);
  QueryPerformanceCounter(lBeginQPC);

  // ���� �� ������� ��������. ����� ������������ ����� ������
  MLPTrainLBFGS_MT_Mod(lNetwork, lXY, lPoints, lRestarts, lMaxStep, 10, lMaxIts, lInfo, lReport);
  //MLPTrainLBFGS_MT(lNetwork, lXY, lPoints, lDecay, lRestarts, lMaxStep, lMaxIts, lInfo, lReport);
  //MLPTrainLBFGS(lNetwork, lXY, lPoints, lDecay, lRestarts, lMaxStep, lMaxIts, lInfo, lReport);
  //MLPTrainLM(lNetwork, lXY, lPoints, lDecay, lRestarts, lInfo, lReport);

  QueryPerformanceCounter(lEndQPC);

  for i := 0 to 20 do
  begin
    DoProcess(i, 1 + i, lNetwork, lX, lY);
    // DoProcess(1 + i, 2 + i * 2, lNetwork, lX, lY); - ����� ����������
    PrintMatrix(lX, lY, i + 1);
  end;

  WriteLn(Format('Time: %10.8f sec', [(lEndQPC - lBeginQPC) / lFreq]));
  // testmlpeunit_test;

  ReadLn;

end.
