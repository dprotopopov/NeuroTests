#pragma hdrstop
#pragma argsused

#ifdef _WIN32
#include <tchar.h>
#else
typedef char _TCHAR;
#define _tmain main
#endif

#include <stdio.h>
#include <vcl.h>
#include <winnt.h>
#include <winioctl.h>
#include <winbase.h>
#include <math.h>
#include "ap.h"
#include "alglibmisc.h"
#include "alglibinternal.h"
#include "dataanalysis.h"

using namespace alglib_impl;

int _tmain(int argc, _TCHAR* argv[]) {
	ae_frame _frame_block;
	ae_int_t info;
	mlpreport rep;
	ae_state _state;
	ae_matrix xy;
	multilayerperceptron network;

	int lInCount = 2; // количество точек данных в одной выборке
	int lOutCount = 1; // кличество точек - заведомо корректных результатов
	int lPoints = 20; // количество обучающих выборок

	ae_state_init(&_state);
	ae_frame_make(&_state, &_frame_block);
	_multilayerperceptron_init(&network, &_state, ae_true);
	ae_matrix_init(&xy, 0, 0, DT_REAL, &_state, ae_true);
	ae_matrix_set_length(&xy, lPoints, lInCount + lOutCount, &_state);

	// заполним линейной прогрессией (для простоты изучения)
	for (int zRow = 0; zRow < lPoints; zRow++) {
		for (int zCol = 0; zCol < lInCount; zCol++) {
			xy.ptr.pp_double[zRow][zCol] = zCol + zRow;
		};
		xy.ptr.pp_double[zRow][lInCount] = lInCount + zRow;
	};

	// mlpcreate0(lInCount, lOutCount, &network, &_state);
	mlpcreate2(lInCount, lInCount, lInCount, lOutCount, &network, &_state);

	LARGE_INTEGER lFreq;
	LARGE_INTEGER lBeginQPC;
	LARGE_INTEGER lEndQPC;
	QueryPerformanceFrequency(&lFreq);
	QueryPerformanceCounter(&lBeginQPC);

	//mlptrainlbfgs(&network, &xy, lInCount, 0.001, 500, 0.001, 500, &info, &rep,
	//	&_state);
	mlptrainlm(&network, &xy, lPoints, 0.001, 500, &info, &rep, &_state);
	QueryPerformanceCounter(&lEndQPC);

	ae_vector workx;
	ae_vector y;
	ae_vector_init(&workx, 2, DT_REAL, &_state, ae_true);
	ae_vector_init(&y, 1, DT_REAL, &_state, ae_true);
	for (int a = 0; a < 21; a++) {
		workx.ptr.p_double[0] = a;
		workx.ptr.p_double[1] = a + 1;
		mlpprocess(&network, &workx, &y, &_state);
		printf("%d + %d = %f\r\n", a, a + 1, y.ptr.p_double[0]);
	}
	printf("Time: %f sec\r\n",
		((float)lEndQPC.QuadPart - (float)lBeginQPC.QuadPart) / (float)
		lFreq.QuadPart);

	_multilayerperceptron_clear(&network);

	getchar();

	return 0;
}
