unit mainform03;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VclTee.TeEngine,
  VclTee.Series, VclTee.TeeProcs, VclTee.Chart, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    GridPanel1: TGridPanel;
    Chart1: TChart;
    SeriesSrc: TLineSeries;
    Chart2: TChart;
    SeriesFiltered: TLineSeries;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses Ap, mlpbase, calc_utils;

{$R *.dfm}

procedure DrawDataOnChart(aChart: TChart; aSerie: TLineSeries; lX: TReal1DArray);
var
  i: Integer;
begin
  aChart.DelphiCanvas.Lock;
  aSerie.BeginUpdate;
  aSerie.Clear;
  for i := Low(lX) to High(lX) do
    aSerie.Add(lX[i]);
  aSerie.EndUpdate;
  aChart.DelphiCanvas.Unlock;
  aChart.Refresh;
end;

const
  CSubLineWidth = 25;

procedure TForm1.FormShow(Sender: TObject);
var
  i: Integer;
  lX, lXsub, lXfiltered: TReal1DArray;
  lY: TReal1DArray;
  lXY: TReal2DArray;
  lNetwork: MultiLayerPerceptron;
begin
  Screen.Cursor := crHourGlass;
  Application.ProcessMessages;
  SetLength(lX, 1000);
  try
    for i := Low(lX) to High(lX) do
      lX[i] := sin(2 * Pi * 0.01 * i) * 0.5 + 0.5;
      // lX[i] := round(sin(2 * Pi * 0.01 * i) * 20);
      //lX[i] := (i mod 50);
    DrawDataOnChart(Chart1, SeriesSrc, lX);

    ConstructMatrixFromLine(lX, CSubLineWidth, 1, 50, lXY);
    CalcNeuroMatrix(false, 1, CSubLineWidth, 1, lXY, lNetwork);

    SetLength(lXsub, CSubLineWidth);
    SetLength(lXfiltered, Length(lX));
    SetLength(lY, 2);
    for i := 0 to CSubLineWidth - 1 do
      lXfiltered[i] := 0;
    for i := Low(lX) to High(lX) - (CSubLineWidth + 1) do
    begin
      GetSubLine(lX, i, CSubLineWidth, lXsub);
      lXfiltered[i + CSubLineWidth] := NeuroRegression(lNetwork, lXsub, lY);
    end;
    DrawDataOnChart(Chart2, SeriesFiltered, lXfiltered);
    
  finally
    Screen.Cursor := crDefault;
    SetLength(lX, 0);
    SetLength(lXY, 0);
    MLPFree(lNetwork);
    Winapi.Windows.Beep(500, 200);
  end;
end;

end.
