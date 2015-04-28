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
  lInCount := Length(lXY[0]) - 1; // ���������� ����� ������ � ����� �������
  lOutCount := 1; // ��������� ����� - �������� ���������� �����������
  lMaxIts := 500; // ���������� �������� �������� (����������)
  lMaxStep := 0.001; // ���������� �������� �������� ���������
  lRestarts := 500; // ���������� �������� �������� ���������
  lDecay := 0.001; // ���������.  ���������� �������� �������� ���������
  lPoints := Length(lXY); // ���������� ��������� ������� (� ����� ����� ����� � ��������)

  // ����� ����� ������������ ����� �� ������� MLPCreate
  case aLevelCount of
    1: MLPCreate0(lInCount, lOutCount, {0, 50,} lNetwork);
    2: MLPCreate1(lInCount, lInCount, lOutCount, {0, 50,} lNetwork);
    else MLPCreate2(lInCount, lInCount, lInCount, lOutCount, {0, 50,} lNetwork);
  end;  

  // ���� �� ������� ��������. ����� ������������ ����� ������
  MLPTrainLBFGS(lNetwork, lXY, lPoints, lDecay, lRestarts, lMaxStep, lMaxIts, lInfo, lReport);
  //MLPTrainLM(lNetwork, lXY, lPoints, lDecay, lRestarts, lInfo, lReport);
end;

// aSubLineWidth - ����� ������ � �������� ��������� ���������
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
