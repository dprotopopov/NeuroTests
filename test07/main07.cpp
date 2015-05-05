// ---------------------------------------------------------------------------

#include <vcl.h>
#include <math.h>
#include "ap.h"
#include "alglibmisc.h"
#include "alglibinternal.h"
#include "dataanalysis.h"

#pragma hdrstop

#include "main07.h"
// ---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm1 *Form1;

using namespace alglib_impl;
// ---------------------------------------------------------------------------

void DrawDataOnChart(TChart * aChart, TLineSeries * aSerie, ae_vector * lX) {
	aChart->DelphiCanvas->Lock();
	aSerie->BeginUpdate();
	aSerie->Clear();
	for (int i = 0; i < lX->cnt; i++) {
		aSerie->Add(lX->ptr.p_double[i]);
	}
	aSerie->EndUpdate();
	aChart->DelphiCanvas->Unlock();
	aChart->Refresh();
}

void GetSubLine(ae_vector * aXSrc, int aPosition, int aSubLineWidth, ae_vector * aXDest) {
	for (int i = 0; i < aSubLineWidth; i++) {
		aXDest->ptr.p_double[i] = aXSrc->ptr.p_double[i + aPosition];
	}
}

void ConstructMatrixFromLine(ae_vector * lX, int aSubLineWidth, int aStep, int aCount, ae_matrix * lXY) {
	ae_state _state;
	// zYCount := Length(lX) - aSubLineWidth;
	int zYCount = aCount;
	ae_matrix_init(lXY, zYCount, aSubLineWidth + 1, DT_REAL, &_state, ae_true);
	int y = 0;
	while (y < zYCount) {
		for (int x = 0; x < aSubLineWidth; x++) {
			lXY->ptr.pp_double[y][x] = lX->ptr.p_double[y + x];
		}
		y += aStep;
	}
}

void CalcNeuroMatrix(bool aClassificator, char aLevelCount, int lInCount, int lOutCount, ae_matrix * lXY,
	multilayerperceptron * lNetwork) {

	ae_frame _frame_block;
	ae_state _state;
	ae_int_t info;
	mlpreport rep;

	ae_state_init(&_state);
	ae_frame_make(&_state, &_frame_block);

	randomize();
	int lMaxIts = 500; // количество итераций обучения (внутреннее)
	double lMaxStep = 0.001; // внутренний параметр обучения нейросети
	int lRestarts = 500; // внутренний параметр обучения нейросети
	double lDecay = 0.0001; // затухание.  внутренний параметр обучения нейросети
	int lPoints = lXY->rows; // количество обучающих выборок (в нашем лучае можно и поменьше)

	// здесь можно использовать любую из функций MLPCreate
	switch (aClassificator) {
	case false:
		switch (aLevelCount) {
		case 1:
			mlpcreate0(lInCount, lOutCount, lNetwork, &_state);
			break;
		case 2:
			mlpcreate1(lInCount, lInCount, lOutCount, lNetwork, &_state);
			break;
		default:
			mlpcreate2(lInCount, lInCount, lInCount, lOutCount, lNetwork, &_state);
			break;
		}
		break;
	case true:
		switch (aLevelCount) {
		case 1:
			mlpcreatec0(lInCount, lOutCount, lNetwork, &_state);
			break;
		case 2:
			mlpcreatec1(lInCount, lInCount, lOutCount, lNetwork, &_state);
			break;
		default:
			mlpcreatec2(lInCount, lInCount, lInCount, lOutCount, lNetwork, &_state);
			break;
		}
		break;
	}
	// один из методов обучения. Можно использовать любой другой
	mlptrainlbfgs(lNetwork, lXY, lPoints, lDecay, lRestarts, lMaxStep, lMaxIts, &info, &rep, &_state);
	// MLPTrainLM(lNetwork, lXY, lPoints, lDecay, lRestarts, lInfo, lReport);
	// MLPTrainES(lNetwork, lXY, lPoints, lXY, lPoints, lDecay, lRestarts, lInfo, lReport);

}

double NeuroRegression(multilayerperceptron * lNetwork, ae_vector * lX, ae_vector * lY, ae_state * _state) {
	mlpprocess(lNetwork, lX, lY, _state);
	return lY->ptr.p_double[0];
}

__fastcall TForm1::TForm1(TComponent* Owner) : TForm(Owner) {

	ae_frame _frame_block;
	ae_vector lX;
	ae_matrix xy;
	ae_state _state;
	multilayerperceptron network;

	ae_vector_init(&lX, 1000, DT_REAL, &_state, ae_true);
	for (int i = 0; i < 1000; i++) {
		lX.ptr.p_double[i] = sin(2 * M_PI * 0.01 * i) * 0.5 + 0.5;
	}
	DrawDataOnChart(Chart1, SeriesSrc, &lX);

	int CSubLineWidth = 25;

	ae_state_init(&_state);
	ae_frame_make(&_state, &_frame_block);
	_multilayerperceptron_init(&network, &_state, ae_true);

	ConstructMatrixFromLine(&lX, CSubLineWidth, 1, 50, &xy);
	CalcNeuroMatrix(false, 1, CSubLineWidth, 1, &xy, &network);

	ae_vector lXsub;
	ae_vector lXfiltered;
	ae_vector lY;

	ae_vector_init(&lXsub, CSubLineWidth, DT_REAL, &_state, ae_true);
	ae_vector_init(&lXfiltered, lX.cnt, DT_REAL, &_state, ae_true);
	ae_vector_init(&lY, 1, DT_REAL, &_state, ae_true);

	for (int i = 0; i < CSubLineWidth; i++) {
		lXfiltered.ptr.p_double[i] = 0;
	}
	for (int i = 0; i < lX.cnt - (CSubLineWidth + 1); i++) {
		GetSubLine(&lX, i, CSubLineWidth, &lXsub);
		lXfiltered.ptr.p_double[i + CSubLineWidth] = NeuroRegression(&network, &lXsub, &lY, &_state);
	}
	DrawDataOnChart(Chart2, SeriesFiltered, &lXfiltered);

	_multilayerperceptron_clear(&network);
	ae_vector_clear(&lX);
}
// ---------------------------------------------------------------------------
