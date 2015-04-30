#pragma hdrstop
#pragma argsused

#ifdef _WIN32
#include <tchar.h>
#else
typedef char _TCHAR;
#define _tmain main
#endif

#include <stdio.h>
#include <math.h>
#include "ap.h"
#include "alglibmisc.h"
#include "alglibinternal.h"
#include "dataanalysis.h"

// using namespace alglib;
using namespace alglib_impl;

/*************************************************************************
 Network creation

 This function creates network with desired structure. Network  is  created
 using one of the three methods:
 a) straighforward creation using MLPCreate???()
 b) MLPCreate???() for proxy object, which is copied with PassThroughSerializer()
 c) MLPCreate???() for proxy object, which is copied with MLPCopy()
 One of these methods is chosen with probability 1/3.
 *************************************************************************/
static void testmlptrainunit_createnetwork(multilayerperceptron* network,
	ae_int_t nkind, double a1, double a2, ae_int_t nin, ae_int_t nhid1,
	ae_int_t nhid2, ae_int_t nout, ae_state *_state) {
	ae_frame _frame_block;
	ae_int_t mkind;
	multilayerperceptron tmp;

	ae_frame_make(_state, &_frame_block);
	_multilayerperceptron_init(&tmp, _state, ae_true);

	ae_assert(((nin > 0 && nhid1 >= 0) && nhid2 >= 0) && nout > 0,
		"CreateNetwork error", _state);
	ae_assert(nhid1 != 0 || nhid2 == 0, "CreateNetwork error", _state);
	ae_assert(nkind != 1 || nout >= 2, "CreateNetwork error", _state);
	mkind = ae_randominteger(3, _state);
	if (nhid1 == 0) {

		/*
		 * No hidden layers
		 */
		if (nkind == 0) {
			if (mkind == 0) {
				mlpcreate0(nin, nout, network, _state);
			}
			if (mkind == 1) {
				mlpcreate0(nin, nout, &tmp, _state); {
					/*
					 * This code passes data structure through serializers
					 * (serializes it to string and loads back)
					 */
					ae_serializer _local_serializer;
					ae_int_t _local_ssize;
					ae_frame _local_frame_block;
					ae_dyn_block _local_dynamic_block;

					ae_frame_make(_state, &_local_frame_block);

					ae_serializer_init(&_local_serializer);
					ae_serializer_alloc_start(&_local_serializer);
					mlpalloc(&_local_serializer, &tmp, _state);
					_local_ssize =
						ae_serializer_get_alloc_size(&_local_serializer);
					ae_db_malloc(&_local_dynamic_block, _local_ssize + 1,
						_state, ae_true);
					ae_serializer_sstart_str(&_local_serializer,
						(char*)_local_dynamic_block.ptr);
					mlpserialize(&_local_serializer, &tmp, _state);
					ae_serializer_stop(&_local_serializer);
					ae_serializer_clear(&_local_serializer);

					ae_serializer_init(&_local_serializer);
					ae_serializer_ustart_str(&_local_serializer,
						(char*)_local_dynamic_block.ptr);
					mlpunserialize(&_local_serializer, network, _state);
					ae_serializer_stop(&_local_serializer);
					ae_serializer_clear(&_local_serializer);

					ae_frame_leave(_state);
				}
			}
			if (mkind == 2) {
				mlpcreate0(nin, nout, &tmp, _state);
				mlpcopy(&tmp, network, _state);
			}
		}
		else {
			if (nkind == 1) {
				if (mkind == 0) {
					mlpcreatec0(nin, nout, network, _state);
				}
				if (mkind == 1) {
					mlpcreatec0(nin, nout, &tmp, _state); {
						/*
						 * This code passes data structure through serializers
						 * (serializes it to string and loads back)
						 */
						ae_serializer _local_serializer;
						ae_int_t _local_ssize;
						ae_frame _local_frame_block;
						ae_dyn_block _local_dynamic_block;

						ae_frame_make(_state, &_local_frame_block);

						ae_serializer_init(&_local_serializer);
						ae_serializer_alloc_start(&_local_serializer);
						mlpalloc(&_local_serializer, &tmp, _state);
						_local_ssize =
							ae_serializer_get_alloc_size(&_local_serializer);
						ae_db_malloc(&_local_dynamic_block, _local_ssize + 1,
							_state, ae_true);
						ae_serializer_sstart_str(&_local_serializer,
							(char*)_local_dynamic_block.ptr);
						mlpserialize(&_local_serializer, &tmp, _state);
						ae_serializer_stop(&_local_serializer);
						ae_serializer_clear(&_local_serializer);

						ae_serializer_init(&_local_serializer);
						ae_serializer_ustart_str(&_local_serializer,
							(char*)_local_dynamic_block.ptr);
						mlpunserialize(&_local_serializer, network, _state);
						ae_serializer_stop(&_local_serializer);
						ae_serializer_clear(&_local_serializer);

						ae_frame_leave(_state);
					}
				}
				if (mkind == 2) {
					mlpcreatec0(nin, nout, &tmp, _state);
					mlpcopy(&tmp, network, _state);
				}
			}
			else {
				if (nkind == 2) {
					if (mkind == 0) {
						mlpcreateb0(nin, nout, a1, a2, network, _state);
					}
					if (mkind == 1) {
						mlpcreateb0(nin, nout, a1, a2, &tmp, _state); {
							/*
							 * This code passes data structure through serializers
							 * (serializes it to string and loads back)
							 */
							ae_serializer _local_serializer;
							ae_int_t _local_ssize;
							ae_frame _local_frame_block;
							ae_dyn_block _local_dynamic_block;

							ae_frame_make(_state, &_local_frame_block);

							ae_serializer_init(&_local_serializer);
							ae_serializer_alloc_start(&_local_serializer);
							mlpalloc(&_local_serializer, &tmp, _state);
							_local_ssize =
								ae_serializer_get_alloc_size(&
								_local_serializer);
							ae_db_malloc(&_local_dynamic_block,
								_local_ssize + 1, _state, ae_true);
							ae_serializer_sstart_str(&_local_serializer,
								(char*)_local_dynamic_block.ptr);
							mlpserialize(&_local_serializer, &tmp, _state);
							ae_serializer_stop(&_local_serializer);
							ae_serializer_clear(&_local_serializer);

							ae_serializer_init(&_local_serializer);
							ae_serializer_ustart_str(&_local_serializer,
								(char*)_local_dynamic_block.ptr);
							mlpunserialize(&_local_serializer, network, _state);
							ae_serializer_stop(&_local_serializer);
							ae_serializer_clear(&_local_serializer);

							ae_frame_leave(_state);
						}
					}
					if (mkind == 2) {
						mlpcreateb0(nin, nout, a1, a2, &tmp, _state);
						mlpcopy(&tmp, network, _state);
					}
				}
				else {
					if (nkind == 3) {
						if (mkind == 0) {
							mlpcreater0(nin, nout, a1, a2, network, _state);
						}
						if (mkind == 1) {
							mlpcreater0(nin, nout, a1, a2, &tmp, _state); {
								/*
								 * This code passes data structure through serializers
								 * (serializes it to string and loads back)
								 */
								ae_serializer _local_serializer;
								ae_int_t _local_ssize;
								ae_frame _local_frame_block;
								ae_dyn_block _local_dynamic_block;

								ae_frame_make(_state, &_local_frame_block);

								ae_serializer_init(&_local_serializer);
								ae_serializer_alloc_start(&_local_serializer);
								mlpalloc(&_local_serializer, &tmp, _state);
								_local_ssize =
									ae_serializer_get_alloc_size(&
									_local_serializer);
								ae_db_malloc(&_local_dynamic_block,
									_local_ssize + 1, _state, ae_true);
								ae_serializer_sstart_str(&_local_serializer,
									(char*)_local_dynamic_block.ptr);
								mlpserialize(&_local_serializer, &tmp, _state);
								ae_serializer_stop(&_local_serializer);
								ae_serializer_clear(&_local_serializer);

								ae_serializer_init(&_local_serializer);
								ae_serializer_ustart_str(&_local_serializer,
									(char*)_local_dynamic_block.ptr);
								mlpunserialize(&_local_serializer, network,
									_state);
								ae_serializer_stop(&_local_serializer);
								ae_serializer_clear(&_local_serializer);

								ae_frame_leave(_state);
							}
						}
						if (mkind == 2) {
							mlpcreater0(nin, nout, a1, a2, &tmp, _state);
							mlpcopy(&tmp, network, _state);
						}
					}
				}
			}
		}
		mlprandomizefull(network, _state);
		ae_frame_leave(_state);
		return;
	}
	if (nhid2 == 0) {

		/*
		 * One hidden layer
		 */
		if (nkind == 0) {
			if (mkind == 0) {
				mlpcreate1(nin, nhid1, nout, network, _state);
			}
			if (mkind == 1) {
				mlpcreate1(nin, nhid1, nout, &tmp, _state); {
					/*
					 * This code passes data structure through serializers
					 * (serializes it to string and loads back)
					 */
					ae_serializer _local_serializer;
					ae_int_t _local_ssize;
					ae_frame _local_frame_block;
					ae_dyn_block _local_dynamic_block;

					ae_frame_make(_state, &_local_frame_block);

					ae_serializer_init(&_local_serializer);
					ae_serializer_alloc_start(&_local_serializer);
					mlpalloc(&_local_serializer, &tmp, _state);
					_local_ssize =
						ae_serializer_get_alloc_size(&_local_serializer);
					ae_db_malloc(&_local_dynamic_block, _local_ssize + 1,
						_state, ae_true);
					ae_serializer_sstart_str(&_local_serializer,
						(char*)_local_dynamic_block.ptr);
					mlpserialize(&_local_serializer, &tmp, _state);
					ae_serializer_stop(&_local_serializer);
					ae_serializer_clear(&_local_serializer);

					ae_serializer_init(&_local_serializer);
					ae_serializer_ustart_str(&_local_serializer,
						(char*)_local_dynamic_block.ptr);
					mlpunserialize(&_local_serializer, network, _state);
					ae_serializer_stop(&_local_serializer);
					ae_serializer_clear(&_local_serializer);

					ae_frame_leave(_state);
				}
			}
			if (mkind == 2) {
				mlpcreate1(nin, nhid1, nout, &tmp, _state);
				mlpcopy(&tmp, network, _state);
			}
		}
		else {
			if (nkind == 1) {
				if (mkind == 0) {
					mlpcreatec1(nin, nhid1, nout, network, _state);
				}
				if (mkind == 1) {
					mlpcreatec1(nin, nhid1, nout, &tmp, _state); {
						/*
						 * This code passes data structure through serializers
						 * (serializes it to string and loads back)
						 */
						ae_serializer _local_serializer;
						ae_int_t _local_ssize;
						ae_frame _local_frame_block;
						ae_dyn_block _local_dynamic_block;

						ae_frame_make(_state, &_local_frame_block);

						ae_serializer_init(&_local_serializer);
						ae_serializer_alloc_start(&_local_serializer);
						mlpalloc(&_local_serializer, &tmp, _state);
						_local_ssize =
							ae_serializer_get_alloc_size(&_local_serializer);
						ae_db_malloc(&_local_dynamic_block, _local_ssize + 1,
							_state, ae_true);
						ae_serializer_sstart_str(&_local_serializer,
							(char*)_local_dynamic_block.ptr);
						mlpserialize(&_local_serializer, &tmp, _state);
						ae_serializer_stop(&_local_serializer);
						ae_serializer_clear(&_local_serializer);

						ae_serializer_init(&_local_serializer);
						ae_serializer_ustart_str(&_local_serializer,
							(char*)_local_dynamic_block.ptr);
						mlpunserialize(&_local_serializer, network, _state);
						ae_serializer_stop(&_local_serializer);
						ae_serializer_clear(&_local_serializer);

						ae_frame_leave(_state);
					}
				}
				if (mkind == 2) {
					mlpcreatec1(nin, nhid1, nout, &tmp, _state);
					mlpcopy(&tmp, network, _state);
				}
			}
			else {
				if (nkind == 2) {
					if (mkind == 0) {
						mlpcreateb1(nin, nhid1, nout, a1, a2, network, _state);
					}
					if (mkind == 1) {
						mlpcreateb1(nin, nhid1, nout, a1, a2, &tmp, _state); {
							/*
							 * This code passes data structure through serializers
							 * (serializes it to string and loads back)
							 */
							ae_serializer _local_serializer;
							ae_int_t _local_ssize;
							ae_frame _local_frame_block;
							ae_dyn_block _local_dynamic_block;

							ae_frame_make(_state, &_local_frame_block);

							ae_serializer_init(&_local_serializer);
							ae_serializer_alloc_start(&_local_serializer);
							mlpalloc(&_local_serializer, &tmp, _state);
							_local_ssize =
								ae_serializer_get_alloc_size(&
								_local_serializer);
							ae_db_malloc(&_local_dynamic_block,
								_local_ssize + 1, _state, ae_true);
							ae_serializer_sstart_str(&_local_serializer,
								(char*)_local_dynamic_block.ptr);
							mlpserialize(&_local_serializer, &tmp, _state);
							ae_serializer_stop(&_local_serializer);
							ae_serializer_clear(&_local_serializer);

							ae_serializer_init(&_local_serializer);
							ae_serializer_ustart_str(&_local_serializer,
								(char*)_local_dynamic_block.ptr);
							mlpunserialize(&_local_serializer, network, _state);
							ae_serializer_stop(&_local_serializer);
							ae_serializer_clear(&_local_serializer);

							ae_frame_leave(_state);
						}
					}
					if (mkind == 2) {
						mlpcreateb1(nin, nhid1, nout, a1, a2, &tmp, _state);
						mlpcopy(&tmp, network, _state);
					}
				}
				else {
					if (nkind == 3) {
						if (mkind == 0) {
							mlpcreater1(nin, nhid1, nout, a1, a2, network,
								_state);
						}
						if (mkind == 1) {
							mlpcreater1(nin, nhid1, nout, a1, a2, &tmp, _state);
							{
								/*
								 * This code passes data structure through serializers
								 * (serializes it to string and loads back)
								 */
								ae_serializer _local_serializer;
								ae_int_t _local_ssize;
								ae_frame _local_frame_block;
								ae_dyn_block _local_dynamic_block;

								ae_frame_make(_state, &_local_frame_block);

								ae_serializer_init(&_local_serializer);
								ae_serializer_alloc_start(&_local_serializer);
								mlpalloc(&_local_serializer, &tmp, _state);
								_local_ssize =
									ae_serializer_get_alloc_size(&
									_local_serializer);
								ae_db_malloc(&_local_dynamic_block,
									_local_ssize + 1, _state, ae_true);
								ae_serializer_sstart_str(&_local_serializer,
									(char*)_local_dynamic_block.ptr);
								mlpserialize(&_local_serializer, &tmp, _state);
								ae_serializer_stop(&_local_serializer);
								ae_serializer_clear(&_local_serializer);

								ae_serializer_init(&_local_serializer);
								ae_serializer_ustart_str(&_local_serializer,
									(char*)_local_dynamic_block.ptr);
								mlpunserialize(&_local_serializer, network,
									_state);
								ae_serializer_stop(&_local_serializer);
								ae_serializer_clear(&_local_serializer);

								ae_frame_leave(_state);
							}
						}
						if (mkind == 2) {
							mlpcreater1(nin, nhid1, nout, a1, a2, &tmp, _state);
							mlpcopy(&tmp, network, _state);
						}
					}
				}
			}
		}
		mlprandomizefull(network, _state);
		ae_frame_leave(_state);
		return;
	}

	/*
	 * Two hidden layers
	 */
	if (nkind == 0) {
		if (mkind == 0) {
			mlpcreate2(nin, nhid1, nhid2, nout, network, _state);
		}
		if (mkind == 1) {
			mlpcreate2(nin, nhid1, nhid2, nout, &tmp, _state); {
				/*
				 * This code passes data structure through serializers
				 * (serializes it to string and loads back)
				 */
				ae_serializer _local_serializer;
				ae_int_t _local_ssize;
				ae_frame _local_frame_block;
				ae_dyn_block _local_dynamic_block;

				ae_frame_make(_state, &_local_frame_block);

				ae_serializer_init(&_local_serializer);
				ae_serializer_alloc_start(&_local_serializer);
				mlpalloc(&_local_serializer, &tmp, _state);
				_local_ssize = ae_serializer_get_alloc_size(&_local_serializer);
				ae_db_malloc(&_local_dynamic_block, _local_ssize + 1, _state,
					ae_true);
				ae_serializer_sstart_str(&_local_serializer,
					(char*)_local_dynamic_block.ptr);
				mlpserialize(&_local_serializer, &tmp, _state);
				ae_serializer_stop(&_local_serializer);
				ae_serializer_clear(&_local_serializer);

				ae_serializer_init(&_local_serializer);
				ae_serializer_ustart_str(&_local_serializer,
					(char*)_local_dynamic_block.ptr);
				mlpunserialize(&_local_serializer, network, _state);
				ae_serializer_stop(&_local_serializer);
				ae_serializer_clear(&_local_serializer);

				ae_frame_leave(_state);
			}
		}
		if (mkind == 2) {
			mlpcreate2(nin, nhid1, nhid2, nout, &tmp, _state);
			mlpcopy(&tmp, network, _state);
		}
	}
	else {
		if (nkind == 1) {
			if (mkind == 0) {
				mlpcreatec2(nin, nhid1, nhid2, nout, network, _state);
			}
			if (mkind == 1) {
				mlpcreatec2(nin, nhid1, nhid2, nout, &tmp, _state); {
					/*
					 * This code passes data structure through serializers
					 * (serializes it to string and loads back)
					 */
					ae_serializer _local_serializer;
					ae_int_t _local_ssize;
					ae_frame _local_frame_block;
					ae_dyn_block _local_dynamic_block;

					ae_frame_make(_state, &_local_frame_block);

					ae_serializer_init(&_local_serializer);
					ae_serializer_alloc_start(&_local_serializer);
					mlpalloc(&_local_serializer, &tmp, _state);
					_local_ssize =
						ae_serializer_get_alloc_size(&_local_serializer);
					ae_db_malloc(&_local_dynamic_block, _local_ssize + 1,
						_state, ae_true);
					ae_serializer_sstart_str(&_local_serializer,
						(char*)_local_dynamic_block.ptr);
					mlpserialize(&_local_serializer, &tmp, _state);
					ae_serializer_stop(&_local_serializer);
					ae_serializer_clear(&_local_serializer);

					ae_serializer_init(&_local_serializer);
					ae_serializer_ustart_str(&_local_serializer,
						(char*)_local_dynamic_block.ptr);
					mlpunserialize(&_local_serializer, network, _state);
					ae_serializer_stop(&_local_serializer);
					ae_serializer_clear(&_local_serializer);

					ae_frame_leave(_state);
				}
			}
			if (mkind == 2) {
				mlpcreatec2(nin, nhid1, nhid2, nout, &tmp, _state);
				mlpcopy(&tmp, network, _state);
			}
		}
		else {
			if (nkind == 2) {
				if (mkind == 0) {
					mlpcreateb2(nin, nhid1, nhid2, nout, a1, a2, network,
					_state);
				}
				if (mkind == 1) {
					mlpcreateb2(nin, nhid1, nhid2, nout, a1, a2, &tmp, _state);
					{
						/*
						 * This code passes data structure through serializers
						 * (serializes it to string and loads back)
						 */
						ae_serializer _local_serializer;
						ae_int_t _local_ssize;
						ae_frame _local_frame_block;
						ae_dyn_block _local_dynamic_block;

						ae_frame_make(_state, &_local_frame_block);

						ae_serializer_init(&_local_serializer);
						ae_serializer_alloc_start(&_local_serializer);
						mlpalloc(&_local_serializer, &tmp, _state);
						_local_ssize =
							ae_serializer_get_alloc_size(&_local_serializer);
						ae_db_malloc(&_local_dynamic_block, _local_ssize + 1,
							_state, ae_true);
						ae_serializer_sstart_str(&_local_serializer,
							(char*)_local_dynamic_block.ptr);
						mlpserialize(&_local_serializer, &tmp, _state);
						ae_serializer_stop(&_local_serializer);
						ae_serializer_clear(&_local_serializer);

						ae_serializer_init(&_local_serializer);
						ae_serializer_ustart_str(&_local_serializer,
							(char*)_local_dynamic_block.ptr);
						mlpunserialize(&_local_serializer, network, _state);
						ae_serializer_stop(&_local_serializer);
						ae_serializer_clear(&_local_serializer);

						ae_frame_leave(_state);
					}
				}
				if (mkind == 2) {
					mlpcreateb2(nin, nhid1, nhid2, nout, a1, a2, &tmp, _state);
					mlpcopy(&tmp, network, _state);
				}
			}
			else {
				if (nkind == 3) {
					if (mkind == 0) {
						mlpcreater2(nin, nhid1, nhid2, nout, a1, a2, network,
							_state);
					}
					if (mkind == 1) {
						mlpcreater2(nin, nhid1, nhid2, nout, a1, a2, &tmp,
							_state); {
							/*
							 * This code passes data structure through serializers
							 * (serializes it to string and loads back)
							 */
							ae_serializer _local_serializer;
							ae_int_t _local_ssize;
							ae_frame _local_frame_block;
							ae_dyn_block _local_dynamic_block;

							ae_frame_make(_state, &_local_frame_block);

							ae_serializer_init(&_local_serializer);
							ae_serializer_alloc_start(&_local_serializer);
							mlpalloc(&_local_serializer, &tmp, _state);
							_local_ssize =
								ae_serializer_get_alloc_size(&
								_local_serializer);
							ae_db_malloc(&_local_dynamic_block,
								_local_ssize + 1, _state, ae_true);
							ae_serializer_sstart_str(&_local_serializer,
								(char*)_local_dynamic_block.ptr);
							mlpserialize(&_local_serializer, &tmp, _state);
							ae_serializer_stop(&_local_serializer);
							ae_serializer_clear(&_local_serializer);

							ae_serializer_init(&_local_serializer);
							ae_serializer_ustart_str(&_local_serializer,
								(char*)_local_dynamic_block.ptr);
							mlpunserialize(&_local_serializer, network, _state);
							ae_serializer_stop(&_local_serializer);
							ae_serializer_clear(&_local_serializer);

							ae_frame_leave(_state);
						}
					}
					if (mkind == 2) {
						mlpcreater2(nin, nhid1, nhid2, nout, a1, a2, &tmp,
							_state);
						mlpcopy(&tmp, network, _state);
					}
				}
			}
		}
	}
	mlprandomizefull(network, _state);
	ae_frame_leave(_state);
}

/*************************************************************************
 Unsets network (initialize it to smallest network possible
 *************************************************************************/
static void testmlptrainunit_unsetnetwork(multilayerperceptron* network,
	ae_state *_state) {

	mlpcreate0(1, 1, network, _state);
}

/*************************************************************************
 Informational functions test
 *************************************************************************/
static void testmlptrainunit_testinformational(ae_int_t nkind, ae_int_t nin,
	ae_int_t nhid1, ae_int_t nhid2, ae_int_t nout, ae_int_t passcount,
	ae_bool* err, ae_state *_state) {
	ae_frame _frame_block;
	multilayerperceptron network;
	ae_int_t n1;
	ae_int_t n2;
	ae_int_t wcount;
	ae_int_t i;
	ae_int_t j;
	ae_int_t k;
	double threshold;
	ae_int_t nlayers;
	ae_int_t nmax;
	ae_bool issoftmax;
	ae_matrix neurons;
	ae_vector x;
	ae_vector y;
	double mean;
	double sigma;
	ae_int_t fkind;
	double c;
	double f;
	double df;
	double d2f;
	double s;

	ae_frame_make(_state, &_frame_block);
	_multilayerperceptron_init(&network, _state, ae_true);
	ae_matrix_init(&neurons, 0, 0, DT_REAL, _state, ae_true);
	ae_vector_init(&x, 0, DT_REAL, _state, ae_true);
	ae_vector_init(&y, 0, DT_REAL, _state, ae_true);

	threshold = 100000 * ae_machineepsilon;
	testmlptrainunit_createnetwork(&network, nkind, 0.0, 0.0, nin, nhid1, nhid2,
		nout, _state);

	/*
	 * test MLPProperties()
	 */
	mlpproperties(&network, &n1, &n2, &wcount, _state);
	*err = ((*err || n1 != nin) || n2 != nout) || wcount <= 0;

	/*
	 * Test network geometry functions
	 *
	 * In order to do this we calculate neural network output using
	 * informational functions only, and compare results with ones
	 * obtained with MLPProcess():
	 * 1. we allocate 2-dimensional array of neurons and fill it by zeros
	 * 2. we full first layer of neurons by input values
	 * 3. we move through array, calculating values of subsequent layers
	 * 4. if we have classification network, we SOFTMAX-normalize output layer
	 * 5. we apply scaling to the outputs
	 * 6. we compare results with ones obtained by MLPProcess()
	 *
	 * NOTE: it is important to do (4) before (5), because on SOFTMAX network
	 *       MLPGetOutputScaling() must return Mean=0 and Sigma=1. In order
	 *       to test it implicitly, we apply it to the classifier results
	 *       (already normalized). If one of the coefficients deviates from
	 *       expected values, we will get error during (6).
	 */
	nlayers = 2;
	nmax = ae_maxint(nin, nout, _state);
	issoftmax = nkind == 1;
	if (nhid1 != 0) {
		nlayers = 3;
		nmax = ae_maxint(nmax, nhid1, _state);
	}
	if (nhid2 != 0) {
		nlayers = 4;
		nmax = ae_maxint(nmax, nhid2, _state);
	}
	ae_matrix_set_length(&neurons, nlayers, nmax, _state);
	for (i = 0; i <= nlayers - 1; i++) {
		for (j = 0; j <= nmax - 1; j++) {
			neurons.ptr.pp_double[i][j] = 0;
		}
	}
	ae_vector_set_length(&x, nin, _state);
	for (i = 0; i <= nin - 1; i++) {
		x.ptr.p_double[i] = 2 * ae_randomreal(_state) - 1;
	}
	ae_vector_set_length(&y, nout, _state);
	for (i = 0; i <= nout - 1; i++) {
		y.ptr.p_double[i] = 2 * ae_randomreal(_state) - 1;
	}
	for (j = 0; j <= nin - 1; j++) {
		mlpgetinputscaling(&network, j, &mean, &sigma, _state);
		neurons.ptr.pp_double[0][j] = (x.ptr.p_double[j] - mean) / sigma;
	}
	for (i = 1; i <= nlayers - 1; i++) {
		for (j = 0; j <= mlpgetlayersize(&network, i, _state) - 1; j++) {
			for (k = 0; k <= mlpgetlayersize(&network, i - 1, _state) - 1; k++)
			{
				neurons.ptr.pp_double[i][j] = neurons.ptr.pp_double[i][j] +
					mlpgetweight(&network, i - 1, k, i, j, _state)
					* neurons.ptr.pp_double[i - 1][k];
			}
			mlpgetneuroninfo(&network, i, j, &fkind, &c, _state);
			mlpactivationfunction(neurons.ptr.pp_double[i][j] - c, fkind, &f,
				&df, &d2f, _state);
			neurons.ptr.pp_double[i][j] = f;
		}
	}
	if (nkind == 1) {
		s = 0;
		for (j = 0; j <= nout - 1; j++) {
			s = s + ae_exp(neurons.ptr.pp_double[nlayers - 1][j], _state);
		}
		for (j = 0; j <= nout - 1; j++) {
			neurons.ptr.pp_double[nlayers - 1][j] =
				ae_exp(neurons.ptr.pp_double[nlayers - 1][j], _state) / s;
		}
	}
	for (j = 0; j <= nout - 1; j++) {
		mlpgetoutputscaling(&network, j, &mean, &sigma, _state);
		neurons.ptr.pp_double[nlayers - 1][j] =
			neurons.ptr.pp_double[nlayers - 1][j] * sigma + mean;
	}
	mlpprocess(&network, &x, &y, _state);
	for (j = 0; j <= nout - 1; j++) {
		*err = *err || ae_fp_greater
			(ae_fabs(neurons.ptr.pp_double[nlayers - 1][j] - y.ptr.p_double[j],
			_state), threshold);
	}
	ae_frame_leave(_state);
}

/*************************************************************************
 Processing functions test
 *************************************************************************/
static void testmlptrainunit_testprocessing(ae_int_t nkind, ae_int_t nin,
	ae_int_t nhid1, ae_int_t nhid2, ae_int_t nout, ae_int_t passcount,
	ae_bool* err, ae_state *_state) {
	ae_frame _frame_block;
	multilayerperceptron network;
	multilayerperceptron network2;
	ae_int_t n1;
	ae_int_t n2;
	ae_int_t wcount;
	ae_bool zeronet;
	double a1;
	double a2;
	ae_int_t pass;
	ae_int_t i;
	ae_bool allsame;
	ae_vector x1;
	ae_vector x2;
	ae_vector y1;
	ae_vector y2;
	double v;

	ae_frame_make(_state, &_frame_block);
	_multilayerperceptron_init(&network, _state, ae_true);
	_multilayerperceptron_init(&network2, _state, ae_true);
	ae_vector_init(&x1, 0, DT_REAL, _state, ae_true);
	ae_vector_init(&x2, 0, DT_REAL, _state, ae_true);
	ae_vector_init(&y1, 0, DT_REAL, _state, ae_true);
	ae_vector_init(&y2, 0, DT_REAL, _state, ae_true);

	ae_assert(passcount >= 2, "PassCount<2!", _state);

	/*
	 * Prepare network
	 */
	a1 = 0;
	a2 = 0;
	if (nkind == 2) {
		a1 = 1000 * ae_randomreal(_state) - 500;
		a2 = 2 * ae_randomreal(_state) - 1;
	}
	if (nkind == 3) {
		a1 = 1000 * ae_randomreal(_state) - 500;
		a2 = a1 + (2 * ae_randominteger(2, _state) - 1) *
			(0.1 + 0.9 * ae_randomreal(_state));
	}
	testmlptrainunit_createnetwork(&network, nkind, a1, a2, nin, nhid1, nhid2,
		nout, _state);
	mlpproperties(&network, &n1, &n2, &wcount, _state);

	/*
	 * Initialize arrays
	 */
	ae_vector_set_length(&x1, nin - 1 + 1, _state);
	ae_vector_set_length(&x2, nin - 1 + 1, _state);
	ae_vector_set_length(&y1, nout - 1 + 1, _state);
	ae_vector_set_length(&y2, nout - 1 + 1, _state);

	/*
	 * Main cycle
	 */
	for (pass = 1; pass <= passcount; pass++) {

		/*
		 * Last run is made on zero network
		 */
		mlprandomizefull(&network, _state);
		zeronet = ae_false;
		if (pass == passcount) {
			ae_v_muld(&network.weights.ptr.p_double[0], 1,
				ae_v_len(0, wcount - 1), 0);
			zeronet = ae_true;
		}

		/*
		 * Same inputs leads to same outputs
		 */
		for (i = 0; i <= nin - 1; i++) {
			x1.ptr.p_double[i] = 2 * ae_randomreal(_state) - 1;
			x2.ptr.p_double[i] = x1.ptr.p_double[i];
		}
		for (i = 0; i <= nout - 1; i++) {
			y1.ptr.p_double[i] = 2 * ae_randomreal(_state) - 1;
			y2.ptr.p_double[i] = 2 * ae_randomreal(_state) - 1;
		}
		mlpprocess(&network, &x1, &y1, _state);
		mlpprocess(&network, &x2, &y2, _state);
		allsame = ae_true;
		for (i = 0; i <= nout - 1; i++) {
			allsame = allsame && ae_fp_eq(y1.ptr.p_double[i],
				y2.ptr.p_double[i]);
		}
		*err = *err || !allsame;

		/*
		 * Same inputs on original network leads to same outputs
		 * on copy created using MLPCopy
		 */
		testmlptrainunit_unsetnetwork(&network2, _state);
		mlpcopy(&network, &network2, _state);
		for (i = 0; i <= nin - 1; i++) {
			x1.ptr.p_double[i] = 2 * ae_randomreal(_state) - 1;
			x2.ptr.p_double[i] = x1.ptr.p_double[i];
		}
		for (i = 0; i <= nout - 1; i++) {
			y1.ptr.p_double[i] = 2 * ae_randomreal(_state) - 1;
			y2.ptr.p_double[i] = 2 * ae_randomreal(_state) - 1;
		}
		mlpprocess(&network, &x1, &y1, _state);
		mlpprocess(&network2, &x2, &y2, _state);
		allsame = ae_true;
		for (i = 0; i <= nout - 1; i++) {
			allsame = allsame && ae_fp_eq(y1.ptr.p_double[i],
				y2.ptr.p_double[i]);
		}
		*err = *err || !allsame;

		/*
		 * Same inputs on original network leads to same outputs
		 * on copy created using MLPSerialize
		 */
		testmlptrainunit_unsetnetwork(&network2, _state); {
			/*
			 * This code passes data structure through serializers
			 * (serializes it to string and loads back)
			 */
			ae_serializer _local_serializer;
			ae_int_t _local_ssize;
			ae_frame _local_frame_block;
			ae_dyn_block _local_dynamic_block;

			ae_frame_make(_state, &_local_frame_block);

			ae_serializer_init(&_local_serializer);
			ae_serializer_alloc_start(&_local_serializer);
			mlpalloc(&_local_serializer, &network, _state);
			_local_ssize = ae_serializer_get_alloc_size(&_local_serializer);
			ae_db_malloc(&_local_dynamic_block, _local_ssize + 1, _state,
				ae_true);
			ae_serializer_sstart_str(&_local_serializer,
				(char*)_local_dynamic_block.ptr);
			mlpserialize(&_local_serializer, &network, _state);
			ae_serializer_stop(&_local_serializer);
			ae_serializer_clear(&_local_serializer);

			ae_serializer_init(&_local_serializer);
			ae_serializer_ustart_str(&_local_serializer,
				(char*)_local_dynamic_block.ptr);
			mlpunserialize(&_local_serializer, &network2, _state);
			ae_serializer_stop(&_local_serializer);
			ae_serializer_clear(&_local_serializer);

			ae_frame_leave(_state);
		}
		for (i = 0; i <= nin - 1; i++) {
			x1.ptr.p_double[i] = 2 * ae_randomreal(_state) - 1;
			x2.ptr.p_double[i] = x1.ptr.p_double[i];
		}
		for (i = 0; i <= nout - 1; i++) {
			y1.ptr.p_double[i] = 2 * ae_randomreal(_state) - 1;
			y2.ptr.p_double[i] = 2 * ae_randomreal(_state) - 1;
		}
		mlpprocess(&network, &x1, &y1, _state);
		mlpprocess(&network2, &x2, &y2, _state);
		allsame = ae_true;
		for (i = 0; i <= nout - 1; i++) {
			allsame = allsame && ae_fp_eq(y1.ptr.p_double[i],
				y2.ptr.p_double[i]);
		}
		*err = *err || !allsame;

		/*
		 * Different inputs leads to different outputs (non-zero network)
		 */
		if (!zeronet) {
			for (i = 0; i <= nin - 1; i++) {
				x1.ptr.p_double[i] = 2 * ae_randomreal(_state) - 1;
				x2.ptr.p_double[i] = 2 * ae_randomreal(_state) - 1;
			}
			for (i = 0; i <= nout - 1; i++) {
				y1.ptr.p_double[i] = 2 * ae_randomreal(_state) - 1;
				y2.ptr.p_double[i] = y1.ptr.p_double[i];
			}
			mlpprocess(&network, &x1, &y1, _state);
			mlpprocess(&network, &x2, &y2, _state);
			allsame = ae_true;
			for (i = 0; i <= nout - 1; i++) {
				allsame = allsame && ae_fp_eq(y1.ptr.p_double[i],
					y2.ptr.p_double[i]);
			}
			*err = *err || allsame;
		}

		/*
		 * Randomization changes outputs (when inputs are unchanged, non-zero network)
		 */
		if (!zeronet) {
			for (i = 0; i <= nin - 1; i++) {
				x1.ptr.p_double[i] = 2 * ae_randomreal(_state) - 1;
				x2.ptr.p_double[i] = 2 * ae_randomreal(_state) - 1;
			}
			for (i = 0; i <= nout - 1; i++) {
				y1.ptr.p_double[i] = 2 * ae_randomreal(_state) - 1;
				y2.ptr.p_double[i] = y1.ptr.p_double[i];
			}
			mlpcopy(&network, &network2, _state);
			mlprandomize(&network2, _state);
			mlpprocess(&network, &x1, &y1, _state);
			mlpprocess(&network2, &x1, &y2, _state);
			allsame = ae_true;
			for (i = 0; i <= nout - 1; i++) {
				allsame = allsame && ae_fp_eq(y1.ptr.p_double[i],
					y2.ptr.p_double[i]);
			}
			*err = *err || allsame;
		}

		/*
		 * Full randomization changes outputs (when inputs are unchanged, non-zero network)
		 */
		if (!zeronet) {
			for (i = 0; i <= nin - 1; i++) {
				x1.ptr.p_double[i] = 2 * ae_randomreal(_state) - 1;
				x2.ptr.p_double[i] = 2 * ae_randomreal(_state) - 1;
			}
			for (i = 0; i <= nout - 1; i++) {
				y1.ptr.p_double[i] = 2 * ae_randomreal(_state) - 1;
				y2.ptr.p_double[i] = y1.ptr.p_double[i];
			}
			mlpcopy(&network, &network2, _state);
			mlprandomizefull(&network2, _state);
			mlpprocess(&network, &x1, &y1, _state);
			mlpprocess(&network2, &x1, &y2, _state);
			allsame = ae_true;
			for (i = 0; i <= nout - 1; i++) {
				allsame = allsame && ae_fp_eq(y1.ptr.p_double[i],
					y2.ptr.p_double[i]);
			}
			*err = *err || allsame;
		}

		/*
		 * Normalization properties
		 */
		if (nkind == 1) {

			/*
			 * Classifier network outputs are normalized
			 */
			for (i = 0; i <= nin - 1; i++) {
				x1.ptr.p_double[i] = 2 * ae_randomreal(_state) - 1;
			}
			mlpprocess(&network, &x1, &y1, _state);
			v = 0;
			for (i = 0; i <= nout - 1; i++) {
				v = v + y1.ptr.p_double[i];
				*err = *err || ae_fp_less(y1.ptr.p_double[i], 0);
			}
			*err = *err || ae_fp_greater(ae_fabs(v - 1, _state),
				1000 * ae_machineepsilon);
		}
		if (nkind == 2) {

			/*
			 * B-type network outputs are bounded from above/below
			 */
			for (i = 0; i <= nin - 1; i++) {
				x1.ptr.p_double[i] = 2 * ae_randomreal(_state) - 1;
			}
			mlpprocess(&network, &x1, &y1, _state);
			for (i = 0; i <= nout - 1; i++) {
				if (ae_fp_greater_eq(a2, 0)) {
					*err = *err || ae_fp_less(y1.ptr.p_double[i], a1);
				}
				else {
					*err = *err || ae_fp_greater(y1.ptr.p_double[i], a1);
				}
			}
		}
		if (nkind == 3) {

			/*
			 * R-type network outputs are within [A1,A2] (or [A2,A1])
			 */
			for (i = 0; i <= nin - 1; i++) {
				x1.ptr.p_double[i] = 2 * ae_randomreal(_state) - 1;
			}
			mlpprocess(&network, &x1, &y1, _state);
			for (i = 0; i <= nout - 1; i++) {
				*err = (*err || ae_fp_less(y1.ptr.p_double[i],
					ae_minreal(a1, a2, _state))) || ae_fp_greater
					(y1.ptr.p_double[i], ae_maxreal(a1, a2, _state));
			}
		}
	}
	ae_frame_leave(_state);
}

/*************************************************************************
 Gradient functions test
 *************************************************************************/
static void testmlptrainunit_testgradient(ae_int_t nkind, ae_int_t nin,
	ae_int_t nhid1, ae_int_t nhid2, ae_int_t nout, ae_int_t passcount,
	ae_bool* err, ae_state *_state) {
	ae_frame _frame_block;
	multilayerperceptron network;
	ae_int_t n1;
	ae_int_t n2;
	ae_int_t wcount;
	double h;
	double etol;
	double a1;
	double a2;
	ae_int_t pass;
	ae_int_t i;
	ae_int_t j;
	ae_int_t ssize;
	ae_matrix xy;
	ae_vector grad1;
	ae_vector grad2;
	ae_vector x;
	ae_vector y;
	ae_vector x1;
	ae_vector x2;
	ae_vector y1;
	ae_vector y2;
	double v;
	double e;
	double e1;
	double e2;
	double v1;
	double v2;
	double v3;
	double v4;
	double wprev;

	ae_frame_make(_state, &_frame_block);
	_multilayerperceptron_init(&network, _state, ae_true);
	ae_matrix_init(&xy, 0, 0, DT_REAL, _state, ae_true);
	ae_vector_init(&grad1, 0, DT_REAL, _state, ae_true);
	ae_vector_init(&grad2, 0, DT_REAL, _state, ae_true);
	ae_vector_init(&x, 0, DT_REAL, _state, ae_true);
	ae_vector_init(&y, 0, DT_REAL, _state, ae_true);
	ae_vector_init(&x1, 0, DT_REAL, _state, ae_true);
	ae_vector_init(&x2, 0, DT_REAL, _state, ae_true);
	ae_vector_init(&y1, 0, DT_REAL, _state, ae_true);
	ae_vector_init(&y2, 0, DT_REAL, _state, ae_true);

	ae_assert(passcount >= 2, "PassCount<2!", _state);
	a1 = 0;
	a2 = 0;
	if (nkind == 2) {
		a1 = 1000 * ae_randomreal(_state) - 500;
		a2 = 2 * ae_randomreal(_state) - 1;
	}
	if (nkind == 3) {
		a1 = 1000 * ae_randomreal(_state) - 500;
		a2 = a1 + (2 * ae_randominteger(2, _state) - 1) *
			(0.1 + 0.9 * ae_randomreal(_state));
	}
	testmlptrainunit_createnetwork(&network, nkind, a1, a2, nin, nhid1, nhid2,
		nout, _state);
	mlpproperties(&network, &n1, &n2, &wcount, _state);
	h = 0.0001;
	etol = 0.01;

	/*
	 * Initialize
	 */
	ae_vector_set_length(&x, nin - 1 + 1, _state);
	ae_vector_set_length(&x1, nin - 1 + 1, _state);
	ae_vector_set_length(&x2, nin - 1 + 1, _state);
	ae_vector_set_length(&y, nout - 1 + 1, _state);
	ae_vector_set_length(&y1, nout - 1 + 1, _state);
	ae_vector_set_length(&y2, nout - 1 + 1, _state);
	ae_vector_set_length(&grad1, wcount - 1 + 1, _state);
	ae_vector_set_length(&grad2, wcount - 1 + 1, _state);

	/*
	 * Process
	 */
	for (pass = 1; pass <= passcount; pass++) {
		mlprandomizefull(&network, _state);

		/*
		 * Test error/gradient calculation (least squares)
		 */
		ae_matrix_set_length(&xy, 0 + 1, nin + nout - 1 + 1, _state);
		for (i = 0; i <= nin - 1; i++) {
			x.ptr.p_double[i] = 4 * ae_randomreal(_state) - 2;
		}
		ae_v_move(&xy.ptr.pp_double[0][0], 1, &x.ptr.p_double[0], 1,
			ae_v_len(0, nin - 1));
		if (mlpissoftmax(&network, _state)) {
			for (i = 0; i <= nout - 1; i++) {
				y.ptr.p_double[i] = 0;
			}
			xy.ptr.pp_double[0][nin] = ae_randominteger(nout, _state);
			y.ptr.p_double[ae_round(xy.ptr.pp_double[0][nin], _state)] = 1;
		}
		else {
			for (i = 0; i <= nout - 1; i++) {
				y.ptr.p_double[i] = 4 * ae_randomreal(_state) - 2;
			}
			ae_v_move(&xy.ptr.pp_double[0][nin], 1, &y.ptr.p_double[0], 1,
				ae_v_len(nin, nin + nout - 1));
		}
		mlpgrad(&network, &x, &y, &e, &grad2, _state);
		mlpprocess(&network, &x, &y2, _state);
		ae_v_sub(&y2.ptr.p_double[0], 1, &y.ptr.p_double[0], 1,
			ae_v_len(0, nout - 1));
		v = ae_v_dotproduct(&y2.ptr.p_double[0], 1, &y2.ptr.p_double[0], 1,
			ae_v_len(0, nout - 1));
		v = v / 2;
		*err = *err || ae_fp_greater(ae_fabs((v - e) / v, _state), etol);
		*err = *err || ae_fp_greater
			(ae_fabs((mlperror(&network, &xy, 1, _state) - v) / v,
			_state), etol);
		for (i = 0; i <= wcount - 1; i++) {
			wprev = network.weights.ptr.p_double[i];
			network.weights.ptr.p_double[i] = wprev - 2 * h;
			mlpprocess(&network, &x, &y1, _state);
			ae_v_sub(&y1.ptr.p_double[0], 1, &y.ptr.p_double[0], 1,
				ae_v_len(0, nout - 1));
			v1 = ae_v_dotproduct(&y1.ptr.p_double[0], 1, &y1.ptr.p_double[0], 1,
				ae_v_len(0, nout - 1));
			v1 = v1 / 2;
			network.weights.ptr.p_double[i] = wprev - h;
			mlpprocess(&network, &x, &y1, _state);
			ae_v_sub(&y1.ptr.p_double[0], 1, &y.ptr.p_double[0], 1,
				ae_v_len(0, nout - 1));
			v2 = ae_v_dotproduct(&y1.ptr.p_double[0], 1, &y1.ptr.p_double[0], 1,
				ae_v_len(0, nout - 1));
			v2 = v2 / 2;
			network.weights.ptr.p_double[i] = wprev + h;
			mlpprocess(&network, &x, &y1, _state);
			ae_v_sub(&y1.ptr.p_double[0], 1, &y.ptr.p_double[0], 1,
				ae_v_len(0, nout - 1));
			v3 = ae_v_dotproduct(&y1.ptr.p_double[0], 1, &y1.ptr.p_double[0], 1,
				ae_v_len(0, nout - 1));
			v3 = v3 / 2;
			network.weights.ptr.p_double[i] = wprev + 2 * h;
			mlpprocess(&network, &x, &y1, _state);
			ae_v_sub(&y1.ptr.p_double[0], 1, &y.ptr.p_double[0], 1,
				ae_v_len(0, nout - 1));
			v4 = ae_v_dotproduct(&y1.ptr.p_double[0], 1, &y1.ptr.p_double[0], 1,
				ae_v_len(0, nout - 1));
			v4 = v4 / 2;
			network.weights.ptr.p_double[i] = wprev;
			grad1.ptr.p_double[i] = (v1 - 8 * v2 + 8 * v3 - v4) / (12 * h);
			if (ae_fp_greater(ae_fabs(grad1.ptr.p_double[i], _state), 1.0E-3)) {
				*err = *err || ae_fp_greater
					(ae_fabs((grad2.ptr.p_double[i] - grad1.ptr.p_double[i])
					/ grad1.ptr.p_double[i], _state), etol);
			}
			else {
				*err = *err || ae_fp_greater
					(ae_fabs(grad2.ptr.p_double[i] - grad1.ptr.p_double[i],
					_state), etol);
			}
		}

		/*
		 * Test error/gradient calculation (natural).
		 * Testing on non-random structure networks
		 * (because NKind is representative only in that case).
		 */
		ae_matrix_set_length(&xy, 0 + 1, nin + nout - 1 + 1, _state);
		for (i = 0; i <= nin - 1; i++) {
			x.ptr.p_double[i] = 4 * ae_randomreal(_state) - 2;
		}
		ae_v_move(&xy.ptr.pp_double[0][0], 1, &x.ptr.p_double[0], 1,
			ae_v_len(0, nin - 1));
		if (mlpissoftmax(&network, _state)) {
			for (i = 0; i <= nout - 1; i++) {
				y.ptr.p_double[i] = 0;
			}
			xy.ptr.pp_double[0][nin] = ae_randominteger(nout, _state);
			y.ptr.p_double[ae_round(xy.ptr.pp_double[0][nin], _state)] = 1;
		}
		else {
			for (i = 0; i <= nout - 1; i++) {
				y.ptr.p_double[i] = 4 * ae_randomreal(_state) - 2;
			}
			ae_v_move(&xy.ptr.pp_double[0][nin], 1, &y.ptr.p_double[0], 1,
				ae_v_len(nin, nin + nout - 1));
		}
		mlpgradn(&network, &x, &y, &e, &grad2, _state);
		mlpprocess(&network, &x, &y2, _state);
		v = 0;
		if (nkind != 1) {
			for (i = 0; i <= nout - 1; i++) {
				v = v + 0.5 * ae_sqr(y2.ptr.p_double[i] - y.ptr.p_double[i],
					_state);
			}
		}
		else {
			for (i = 0; i <= nout - 1; i++) {
				if (ae_fp_neq(y.ptr.p_double[i], 0)) {
					if (ae_fp_eq(y2.ptr.p_double[i], 0)) {
						v = v + y.ptr.p_double[i] * ae_log(ae_maxrealnumber,
							_state);
					}
					else {
						v = v + y.ptr.p_double[i] * ae_log
							(y.ptr.p_double[i] / y2.ptr.p_double[i], _state);
					}
				}
			}
		}
		*err = *err || ae_fp_greater(ae_fabs((v - e) / v, _state), etol);
		*err = *err || ae_fp_greater
			(ae_fabs((mlperrorn(&network, &xy, 1, _state) - v) / v,
			_state), etol);
		for (i = 0; i <= wcount - 1; i++) {
			wprev = network.weights.ptr.p_double[i];
			network.weights.ptr.p_double[i] = wprev + h;
			mlpprocess(&network, &x, &y2, _state);
			network.weights.ptr.p_double[i] = wprev - h;
			mlpprocess(&network, &x, &y1, _state);
			network.weights.ptr.p_double[i] = wprev;
			v = 0;
			if (nkind != 1) {
				for (j = 0; j <= nout - 1; j++) {
					v = v + 0.5 *
						(ae_sqr(y2.ptr.p_double[j] - y.ptr.p_double[j],
						_state) - ae_sqr(y1.ptr.p_double[j] - y.ptr.p_double[j],
						_state)) / (2 * h);
				}
			}
			else {
				for (j = 0; j <= nout - 1; j++) {
					if (ae_fp_neq(y.ptr.p_double[j], 0)) {
						if (ae_fp_eq(y2.ptr.p_double[j], 0)) {
							v = v + y.ptr.p_double[j] * ae_log(ae_maxrealnumber,
								_state);
						}
						else {
							v = v + y.ptr.p_double[j] * ae_log
								(y.ptr.p_double[j] / y2.ptr.p_double[j],
							_state);
						}
						if (ae_fp_eq(y1.ptr.p_double[j], 0)) {
							v = v - y.ptr.p_double[j] * ae_log(ae_maxrealnumber,
								_state);
						}
						else {
							v = v - y.ptr.p_double[j] * ae_log
								(y.ptr.p_double[j] / y1.ptr.p_double[j],
							_state);
						}
					}
				}
				v = v / (2 * h);
			}
			grad1.ptr.p_double[i] = v;
			if (ae_fp_greater(ae_fabs(grad1.ptr.p_double[i], _state), 1.0E-3)) {
				*err = *err || ae_fp_greater
					(ae_fabs((grad2.ptr.p_double[i] - grad1.ptr.p_double[i])
					/ grad1.ptr.p_double[i], _state), etol);
			}
			else {
				*err = *err || ae_fp_greater
					(ae_fabs(grad2.ptr.p_double[i] - grad1.ptr.p_double[i],
					_state), etol);
			}
		}

		/*
		 * Test gradient calculation: batch (least squares)
		 */
		ssize = 1 + ae_randominteger(10, _state);
		ae_matrix_set_length(&xy, ssize - 1 + 1, nin + nout - 1 + 1, _state);
		for (i = 0; i <= wcount - 1; i++) {
			grad1.ptr.p_double[i] = 0;
		}
		e1 = 0;
		for (i = 0; i <= ssize - 1; i++) {
			for (j = 0; j <= nin - 1; j++) {
				x1.ptr.p_double[j] = 4 * ae_randomreal(_state) - 2;
			}
			ae_v_move(&xy.ptr.pp_double[i][0], 1, &x1.ptr.p_double[0], 1,
				ae_v_len(0, nin - 1));
			if (mlpissoftmax(&network, _state)) {
				for (j = 0; j <= nout - 1; j++) {
					y1.ptr.p_double[j] = 0;
				}
				xy.ptr.pp_double[i][nin] = ae_randominteger(nout, _state);
				y1.ptr.p_double[ae_round(xy.ptr.pp_double[i][nin], _state)] = 1;
			}
			else {
				for (j = 0; j <= nout - 1; j++) {
					y1.ptr.p_double[j] = 4 * ae_randomreal(_state) - 2;
				}
				ae_v_move(&xy.ptr.pp_double[i][nin], 1, &y1.ptr.p_double[0], 1,
					ae_v_len(nin, nin + nout - 1));
			}
			mlpgrad(&network, &x1, &y1, &v, &grad2, _state);
			e1 = e1 + v;
			ae_v_add(&grad1.ptr.p_double[0], 1, &grad2.ptr.p_double[0], 1,
				ae_v_len(0, wcount - 1));
		}
		mlpgradbatch(&network, &xy, ssize, &e2, &grad2, _state);
		*err = *err || ae_fp_greater(ae_fabs(e1 - e2, _state) / e1, 0.01);
		for (i = 0; i <= wcount - 1; i++) {
			if (ae_fp_neq(grad1.ptr.p_double[i], 0)) {
				*err = *err || ae_fp_greater
					(ae_fabs((grad2.ptr.p_double[i] - grad1.ptr.p_double[i])
					/ grad1.ptr.p_double[i], _state), etol);
			}
			else {
				*err = *err || ae_fp_neq(grad2.ptr.p_double[i],
					grad1.ptr.p_double[i]);
			}
		}

		/*
		 * Test gradient calculation: batch (natural error func)
		 */
		ssize = 1 + ae_randominteger(10, _state);
		ae_matrix_set_length(&xy, ssize - 1 + 1, nin + nout - 1 + 1, _state);
		for (i = 0; i <= wcount - 1; i++) {
			grad1.ptr.p_double[i] = 0;
		}
		e1 = 0;
		for (i = 0; i <= ssize - 1; i++) {
			for (j = 0; j <= nin - 1; j++) {
				x1.ptr.p_double[j] = 4 * ae_randomreal(_state) - 2;
			}
			ae_v_move(&xy.ptr.pp_double[i][0], 1, &x1.ptr.p_double[0], 1,
				ae_v_len(0, nin - 1));
			if (mlpissoftmax(&network, _state)) {
				for (j = 0; j <= nout - 1; j++) {
					y1.ptr.p_double[j] = 0;
				}
				xy.ptr.pp_double[i][nin] = ae_randominteger(nout, _state);
				y1.ptr.p_double[ae_round(xy.ptr.pp_double[i][nin], _state)] = 1;
			}
			else {
				for (j = 0; j <= nout - 1; j++) {
					y1.ptr.p_double[j] = 4 * ae_randomreal(_state) - 2;
				}
				ae_v_move(&xy.ptr.pp_double[i][nin], 1, &y1.ptr.p_double[0], 1,
					ae_v_len(nin, nin + nout - 1));
			}
			mlpgradn(&network, &x1, &y1, &v, &grad2, _state);
			e1 = e1 + v;
			ae_v_add(&grad1.ptr.p_double[0], 1, &grad2.ptr.p_double[0], 1,
				ae_v_len(0, wcount - 1));
		}
		mlpgradnbatch(&network, &xy, ssize, &e2, &grad2, _state);
		*err = *err || ae_fp_greater(ae_fabs(e1 - e2, _state) / e1, etol);
		for (i = 0; i <= wcount - 1; i++) {
			if (ae_fp_neq(grad1.ptr.p_double[i], 0)) {
				*err = *err || ae_fp_greater
					(ae_fabs((grad2.ptr.p_double[i] - grad1.ptr.p_double[i])
					/ grad1.ptr.p_double[i], _state), etol);
			}
			else {
				*err = *err || ae_fp_neq(grad2.ptr.p_double[i],
					grad1.ptr.p_double[i]);
			}
		}
	}
	ae_frame_leave(_state);
}

/*************************************************************************
 Hessian functions test
 *************************************************************************/
static void testmlptrainunit_testhessian(ae_int_t nkind, ae_int_t nin,
	ae_int_t nhid1, ae_int_t nhid2, ae_int_t nout, ae_int_t passcount,
	ae_bool* err, ae_state *_state) {
	ae_frame _frame_block;
	multilayerperceptron network;
	ae_int_t hkind;
	ae_int_t n1;
	ae_int_t n2;
	ae_int_t wcount;
	double h;
	double etol;
	ae_int_t pass;
	ae_int_t i;
	ae_int_t j;
	ae_int_t ssize;
	double a1;
	double a2;
	ae_matrix xy;
	ae_matrix h1;
	ae_matrix h2;
	ae_vector grad1;
	ae_vector grad2;
	ae_vector grad3;
	ae_vector x;
	ae_vector y;
	ae_vector x1;
	ae_vector x2;
	ae_vector y1;
	ae_vector y2;
	double v;
	double e1;
	double e2;
	double wprev;

	ae_frame_make(_state, &_frame_block);
	_multilayerperceptron_init(&network, _state, ae_true);
	ae_matrix_init(&xy, 0, 0, DT_REAL, _state, ae_true);
	ae_matrix_init(&h1, 0, 0, DT_REAL, _state, ae_true);
	ae_matrix_init(&h2, 0, 0, DT_REAL, _state, ae_true);
	ae_vector_init(&grad1, 0, DT_REAL, _state, ae_true);
	ae_vector_init(&grad2, 0, DT_REAL, _state, ae_true);
	ae_vector_init(&grad3, 0, DT_REAL, _state, ae_true);
	ae_vector_init(&x, 0, DT_REAL, _state, ae_true);
	ae_vector_init(&y, 0, DT_REAL, _state, ae_true);
	ae_vector_init(&x1, 0, DT_REAL, _state, ae_true);
	ae_vector_init(&x2, 0, DT_REAL, _state, ae_true);
	ae_vector_init(&y1, 0, DT_REAL, _state, ae_true);
	ae_vector_init(&y2, 0, DT_REAL, _state, ae_true);

	ae_assert(passcount >= 2, "PassCount<2!", _state);
	a1 = 0;
	a2 = 0;
	if (nkind == 2) {
		a1 = 1000 * ae_randomreal(_state) - 500;
		a2 = 2 * ae_randomreal(_state) - 1;
	}
	if (nkind == 3) {
		a1 = 1000 * ae_randomreal(_state) - 500;
		a2 = a1 + (2 * ae_randominteger(2, _state) - 1) *
			(0.1 + 0.9 * ae_randomreal(_state));
	}
	testmlptrainunit_createnetwork(&network, nkind, a1, a2, nin, nhid1, nhid2,
		nout, _state);
	mlpproperties(&network, &n1, &n2, &wcount, _state);
	h = 0.0001;
	etol = 0.05;

	/*
	 * Initialize
	 */
	ae_vector_set_length(&x, nin - 1 + 1, _state);
	ae_vector_set_length(&x1, nin - 1 + 1, _state);
	ae_vector_set_length(&x2, nin - 1 + 1, _state);
	ae_vector_set_length(&y, nout - 1 + 1, _state);
	ae_vector_set_length(&y1, nout - 1 + 1, _state);
	ae_vector_set_length(&y2, nout - 1 + 1, _state);
	ae_vector_set_length(&grad1, wcount - 1 + 1, _state);
	ae_vector_set_length(&grad2, wcount - 1 + 1, _state);
	ae_vector_set_length(&grad3, wcount - 1 + 1, _state);
	ae_matrix_set_length(&h1, wcount - 1 + 1, wcount - 1 + 1, _state);
	ae_matrix_set_length(&h2, wcount - 1 + 1, wcount - 1 + 1, _state);

	/*
	 * Process
	 */
	for (pass = 1; pass <= passcount; pass++) {
		mlprandomizefull(&network, _state);

		/*
		 * Test hessian calculation .
		 * E1 contains total error (calculated using MLPGrad/MLPGradN)
		 * Grad1 contains total gradient (calculated using MLPGrad/MLPGradN)
		 * H1 contains Hessian calculated using differences of gradients
		 *
		 * E2, Grad2 and H2 contains corresponing values calculated using MLPHessianBatch/MLPHessianNBatch
		 */
		for (hkind = 0; hkind <= 1; hkind++) {
			ssize = 1 + ae_randominteger(10, _state);
			ae_matrix_set_length(&xy, ssize - 1 + 1, nin + nout - 1 + 1,
				_state);
			for (i = 0; i <= wcount - 1; i++) {
				grad1.ptr.p_double[i] = 0;
			}
			for (i = 0; i <= wcount - 1; i++) {
				for (j = 0; j <= wcount - 1; j++) {
					h1.ptr.pp_double[i][j] = 0;
				}
			}
			e1 = 0;
			for (i = 0; i <= ssize - 1; i++) {

				/*
				 * X, Y
				 */
				for (j = 0; j <= nin - 1; j++) {
					x1.ptr.p_double[j] = 4 * ae_randomreal(_state) - 2;
				}
				ae_v_move(&xy.ptr.pp_double[i][0], 1, &x1.ptr.p_double[0], 1,
					ae_v_len(0, nin - 1));
				if (mlpissoftmax(&network, _state)) {
					for (j = 0; j <= nout - 1; j++) {
						y1.ptr.p_double[j] = 0;
					}
					xy.ptr.pp_double[i][nin] = ae_randominteger(nout, _state);
					y1.ptr.p_double[ae_round(xy.ptr.pp_double[i][nin],
						_state)] = 1;
				}
				else {
					for (j = 0; j <= nout - 1; j++) {
						y1.ptr.p_double[j] = 4 * ae_randomreal(_state) - 2;
					}
					ae_v_move(&xy.ptr.pp_double[i][nin], 1, &y1.ptr.p_double[0],
						1, ae_v_len(nin, nin + nout - 1));
				}

				/*
				 * E1, Grad1
				 */
				if (hkind == 0) {
					mlpgrad(&network, &x1, &y1, &v, &grad2, _state);
				}
				else {
					mlpgradn(&network, &x1, &y1, &v, &grad2, _state);
				}
				e1 = e1 + v;
				ae_v_add(&grad1.ptr.p_double[0], 1, &grad2.ptr.p_double[0], 1,
					ae_v_len(0, wcount - 1));

				/*
				 * H1
				 */
				for (j = 0; j <= wcount - 1; j++) {
					wprev = network.weights.ptr.p_double[j];
					network.weights.ptr.p_double[j] = wprev - 2 * h;
					if (hkind == 0) {
						mlpgrad(&network, &x1, &y1, &v, &grad2, _state);
					}
					else {
						mlpgradn(&network, &x1, &y1, &v, &grad2, _state);
					}
					network.weights.ptr.p_double[j] = wprev - h;
					if (hkind == 0) {
						mlpgrad(&network, &x1, &y1, &v, &grad3, _state);
					}
					else {
						mlpgradn(&network, &x1, &y1, &v, &grad3, _state);
					}
					ae_v_subd(&grad2.ptr.p_double[0], 1, &grad3.ptr.p_double[0],
						1, ae_v_len(0, wcount - 1), 8);
					network.weights.ptr.p_double[j] = wprev + h;
					if (hkind == 0) {
						mlpgrad(&network, &x1, &y1, &v, &grad3, _state);
					}
					else {
						mlpgradn(&network, &x1, &y1, &v, &grad3, _state);
					}
					ae_v_addd(&grad2.ptr.p_double[0], 1, &grad3.ptr.p_double[0],
						1, ae_v_len(0, wcount - 1), 8);
					network.weights.ptr.p_double[j] = wprev + 2 * h;
					if (hkind == 0) {
						mlpgrad(&network, &x1, &y1, &v, &grad3, _state);
					}
					else {
						mlpgradn(&network, &x1, &y1, &v, &grad3, _state);
					}
					ae_v_sub(&grad2.ptr.p_double[0], 1, &grad3.ptr.p_double[0],
						1, ae_v_len(0, wcount - 1));
					v = 1 / (12 * h);
					ae_v_addd(&h1.ptr.pp_double[j][0], 1,
						&grad2.ptr.p_double[0], 1, ae_v_len(0, wcount - 1), v);
					network.weights.ptr.p_double[j] = wprev;
				}
			}
			if (hkind == 0) {
				mlphessianbatch(&network, &xy, ssize, &e2, &grad2, &h2, _state);
			}
			else {
				mlphessiannbatch(&network, &xy, ssize, &e2, &grad2, &h2,
				_state);
			}
			*err = *err || ae_fp_greater(ae_fabs(e1 - e2, _state) / e1, etol);
			for (i = 0; i <= wcount - 1; i++) {
				if (ae_fp_greater(ae_fabs(grad1.ptr.p_double[i], _state),
					1.0E-2)) {
					*err = *err || ae_fp_greater
						(ae_fabs((grad2.ptr.p_double[i] - grad1.ptr.p_double[i])
						/ grad1.ptr.p_double[i], _state), etol);
				}
				else {
					*err = *err || ae_fp_greater
						(ae_fabs(grad2.ptr.p_double[i] - grad1.ptr.p_double[i],
						_state), etol);
				}
			}
			for (i = 0; i <= wcount - 1; i++) {
				for (j = 0; j <= wcount - 1; j++) {
					if (ae_fp_greater(ae_fabs(h1.ptr.pp_double[i][j], _state),
						5.0E-2)) {
						*err = *err || ae_fp_greater
							(ae_fabs((h1.ptr.pp_double[i][j] -
							h2.ptr.pp_double[i][j]) / h1.ptr.pp_double[i][j],
							_state), etol);
					}
					else {
						*err = *err || ae_fp_greater
							(ae_fabs(h2.ptr.pp_double[i][j] -
							h1.ptr.pp_double[i][j], _state), etol);
					}
				}
			}
		}
	}
	ae_frame_leave(_state);
}

ae_bool testmlptrain(ae_bool silent, ae_state *_state) {
	ae_frame _frame_block;
	ae_bool waserrors;
	ae_int_t passcount;
	ae_int_t maxn;
	ae_int_t maxhid;
	ae_int_t info;
	ae_int_t nf;
	ae_int_t nl;
	ae_int_t nhid1;
	ae_int_t nhid2;
	ae_int_t nkind;
	ae_int_t i;
	multilayerperceptron network;
	multilayerperceptron network2;
	mlpreport rep;
	mlpcvreport cvrep;
	ae_int_t ncount;
	ae_matrix xy;
	ae_matrix valxy;
	ae_bool inferrors;
	ae_bool procerrors;
	ae_bool graderrors;
	ae_bool hesserrors;
	ae_bool trnerrors;
	ae_bool result;

	ae_frame_make(_state, &_frame_block);
	_multilayerperceptron_init(&network, _state, ae_true);
	_multilayerperceptron_init(&network2, _state, ae_true);
	_mlpreport_init(&rep, _state, ae_true);
	_mlpcvreport_init(&cvrep, _state, ae_true);
	ae_matrix_init(&xy, 0, 0, DT_REAL, _state, ae_true);
	ae_matrix_init(&valxy, 0, 0, DT_REAL, _state, ae_true);

	waserrors = ae_false;
	inferrors = ae_false;
	procerrors = ae_false;
	graderrors = ae_false;
	hesserrors = ae_false;
	trnerrors = ae_false;
	passcount = 10;
	maxn = 4;
	maxhid = 4;

	/*
	 * General multilayer network tests
	 */
	for (nf = 1; nf <= maxn; nf++) {
		for (nl = 1; nl <= maxn; nl++) {
			for (nhid1 = 0; nhid1 <= maxhid; nhid1++) {
				for (nhid2 = 0; nhid2 <= 0; nhid2++) {
					for (nkind = 0; nkind <= 3; nkind++) {

						/*
						 *  Skip meaningless parameters combinations
						 */
						if (nkind == 1 && nl < 2) {
							continue;
						}
						if (nhid1 == 0 && nhid2 != 0) {
							continue;
						}

						/*
						 * Tests
						 */
						testmlptrainunit_testinformational(nkind, nf, nhid1,
							nhid2, nl, passcount, &inferrors, _state);
						testmlptrainunit_testprocessing(nkind, nf, nhid1, nhid2,
							nl, passcount, &procerrors, _state);
						testmlptrainunit_testgradient(nkind, nf, nhid1, nhid2,
							nl, passcount, &graderrors, _state);
						testmlptrainunit_testhessian(nkind, nf, nhid1, nhid2,
							nl, passcount, &hesserrors, _state);
					}
				}
			}
		}
	}

	/*
	 * Test network training on simple XOR problem
	 */
	ae_matrix_set_length(&xy, 3 + 1, 2 + 1, _state);
	xy.ptr.pp_double[0][0] = -1;
	xy.ptr.pp_double[0][1] = -1;
	xy.ptr.pp_double[0][2] = -1;
	xy.ptr.pp_double[1][0] = 1;
	xy.ptr.pp_double[1][1] = -1;
	xy.ptr.pp_double[1][2] = 1;
	xy.ptr.pp_double[2][0] = -1;
	xy.ptr.pp_double[2][1] = 1;
	xy.ptr.pp_double[2][2] = 1;
	xy.ptr.pp_double[3][0] = 1;
	xy.ptr.pp_double[3][1] = 1;
	xy.ptr.pp_double[3][2] = -1;
	mlpcreate1(2, 2, 1, &network, _state);
	mlptrainlm(&network, &xy, 4, 0.001, 10, &info, &rep, _state);
	trnerrors = trnerrors || ae_fp_greater(mlprmserror(&network, &xy, 4,
		_state), 0.1);

	/*
	 * Test CV on random noisy problem
	 */
	ncount = 100;
	ae_matrix_set_length(&xy, ncount - 1 + 1, 1 + 1, _state);
	for (i = 0; i <= ncount - 1; i++) {
		xy.ptr.pp_double[i][0] = 2 * ae_randomreal(_state) - 1;
		xy.ptr.pp_double[i][1] = ae_randominteger(4, _state);
	}
	mlpcreatec0(1, 4, &network, _state);
	mlpkfoldcvlm(&network, &xy, ncount, 0.001, 5, 10, &info, &rep, &cvrep,
		_state);

	/*
	 * Final report
	 */
	waserrors = (((inferrors || procerrors) || graderrors) || hesserrors) ||
		trnerrors;
	if (!silent) {
		printf("MLP TEST\n");
		printf("INFORMATIONAL FUNCTIONS:                 ");
		if (!inferrors) {
			printf("OK\n");
		}
		else {
			printf("FAILED\n");
		}
		printf("BASIC PROCESSING:                        ");
		if (!procerrors) {
			printf("OK\n");
		}
		else {
			printf("FAILED\n");
		}
		printf("GRADIENT CALCULATION:                    ");
		if (!graderrors) {
			printf("OK\n");
		}
		else {
			printf("FAILED\n");
		}
		printf("HESSIAN CALCULATION:                     ");
		if (!hesserrors) {
			printf("OK\n");
		}
		else {
			printf("FAILED\n");
		}
		printf("TRAINING:                                ");
		if (!trnerrors) {
			printf("OK\n");
		}
		else {
			printf("FAILED\n");
		}
		if (waserrors) {
			printf("TEST SUMMARY: FAILED\n");
		}
		else {
			printf("TEST SUMMARY: PASSED\n");
		}
		printf("\n\n");
	}
	result = !waserrors;
	ae_frame_leave(_state);
	return result;
}

ae_bool call_unittest(unsigned seed, ae_bool(*testfunc)(ae_bool, ae_state*),
	int *psticky) {
#ifndef AE_USE_CPP_ERROR_HANDLING
	ae_state _alglib_env_state;
	ae_frame _frame_block;
	jmp_buf _break_jump;
	ae_bool result;

	ae_state_init(&_alglib_env_state);
	if (setjmp(_break_jump)) {
		*psticky = 1;
		return ae_false;
	}
	ae_state_set_break_jump(&_alglib_env_state, &_break_jump);
	ae_frame_make(&_alglib_env_state, &_frame_block);
	srand(seed);
	result = testfunc(ae_true, &_alglib_env_state);
	ae_state_clear(&_alglib_env_state);
	if (!result)
		* psticky = 1;
	return result;
#else
	try {
		ae_state _alglib_env_state;
		ae_frame _frame_block;
		ae_bool result;

		ae_state_init(&_alglib_env_state);
		ae_frame_make(&_alglib_env_state, &_frame_block);
		srand(seed);
		result = testfunc(ae_true, &_alglib_env_state);
		ae_state_clear(&_alglib_env_state);
		if (!result)
			* psticky = 1;
		return result;
	}
	catch (...) {
		*psticky = 1;
		return ae_false;
	}
#endif
}

int _tmain(int argc, _TCHAR* argv[]) {
	int result = 0;
	unsigned seed;
	if (argc == 2)
		seed = (unsigned)atoi(argv[1]);
	else {
		time_t t;
		seed = (unsigned)time(&t);
	}
	if (call_unittest(seed, testmlptrain, &result))
		printf("%-32s OK\n", "mlptrain");
	else
		printf("%-32s FAILED(seed=%u)\n", "mlptrain", (unsigned int)seed);

	getchar();
	return 0;
}
