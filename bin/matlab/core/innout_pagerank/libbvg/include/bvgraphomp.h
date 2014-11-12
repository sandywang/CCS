#ifndef LIBBVG_BVGRAPHOMP_H
#define LIBBVG_BVGRAPHOMP_H

/*
 * David Gleich
 * Copyright, Stanford University, 2008
 * 9 May 2008
 */

/**
 * @file bvgraphomp.h
 * Functions to work with a bvgraph accelerated through OpenMP.
 */

#include "bvgraph.h"

int bvgraph_omp_mult(bvgraph_parallel_iterators *pits, double *x, double *y);
int bvgraph_omp_transmult(bvgraph_parallel_iterators *pits, 
                            double *x, double *y);
int bvgraph_omp_transmult_extra(bvgraph_parallel_iterators *pits, 
                            double *x, double *y, double *work);                            
int bvgraph_omp_diag(bvgraph_parallel_iterators *pits, double *x);
int bvgraph_omp_sum_row(bvgraph_parallel_iterators *pits, double *x);
int bvgraph_omp_sum_col(bvgraph_parallel_iterators *pits, double *x);

int bvgraph_omp_substochastic_mult(bvgraph_parallel_iterators *pits,
        double* x, double *y);
int bvgraph_omp_substochastic_transmult(bvgraph_parallel_iterators *pits, 
        double* x, double *y);
int bvgraph_omp_substochastic_transmult_extra(
        bvgraph_parallel_iterators *pits, double* x, double *y, double* work);

#endif /* LIBBVG_BVGRAPHOMP_H */
