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
  Write(Format('IN[0]  = %5.2f'#13#10'', [X[0]]));
  Write(Format('IN[1]  = %5.2f'#13#10'', [X[1]]));
  Write(Format('Prob(Class=0|IN) = %5.2f'#13#10'', [Y[0]]));
  // Write(Format('Prob(Class=1|IN) = %5.2f'#13#10'', [Y[1]]));
  // Write(Format('Prob(Class=2|IN) = %5.2f'#13#10'', [Y[2]]));
  WriteLn(Format('--- %d ------------', [aIteration]));
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

  lInCount := 2; // ���������� ����� ������ � ����� �������
  lOutCount := 1; // ��������� ����� - �������� ���������� �����������
  lMaxIts := 500; // ���������� �������� �������� (����������)
  lMaxStep := 0.001; // ���������� �������� �������� ���������
  lRestarts := 500; // ���������� �������� �������� ���������
  lDecay := 0.001; // ���������.  ���������� �������� �������� ���������
  lPoints := 400;//40; // ���������� ��������� ������� (� ����� ����� ����� � ��������)

  lNHid1 := lInCount; // ���������� ����� � 1-�� ������� ����
  lNHid2 := lInCount; // ���������� ����� �� 2-�� ������� ����

  // ����� ����� ������������ ����� �� ������� MLPCreate
  MLPCreate2(lInCount, lNHid1, lNHid2, lOutCount, lNetwork);

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

  // ���� �� ������� ��������. ����� ������������ ����� ������
  MLPTrainLBFGS(lNetwork, lXY, lPoints, lDecay, lRestarts, lMaxStep, lMaxIts, lInfo, lReport);
  //MLPTrainLM(lNetwork, lXY, lPoints, lDecay, lRestarts, lInfo, lReport);

  for i := 0 to 20 do
  begin
    Write(Format('Classification task'#13#10'', []));
    DoProcess(1 + i, 2 + i, lNetwork, lX, lY);
    PrintMatrix(lX, lY, i + 1);
  end;

  ReadLn;

end.
