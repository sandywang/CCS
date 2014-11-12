/*
 * David Gleich
 * Copyright, Stanford University, 2008
 * 10 May 2008
 */

/**
 * @file vecfun.h
 * Prototype definitions for vector functions.
 */

/** History
 *  2008-05-10: Initial coding based on previous code.
 */

#ifndef VECFUN_H
#define VECFUN_H

#include <math.h>

double sum(double *x, size_t n);
void shift(double *x, const double s, size_t n);
void shift_and_scale(double *x, const double s, const double a, size_t n);
void set(double *x, const double s, size_t n);
void copy(double *x, double *y, size_t n);
double diff_norm_1(double* x, double *y, size_t n);
double norm_1(double *x, size_t n);
double make_unit_norm_1(double* x, size_t n);
void xpby(double *x, double *y, const double beta, size_t n);
void axpysz(double *z, double *x, double *y, const double alpha, size_t n); 
double shift_and_norm_1(double *x, const double w, size_t n);
double xpby_and_norm_1(double *x, double *y, const double beta, size_t n);
double scale_and_norm_diff_1(double *x, double *y, const double ny, size_t n);
void save_scale_and_shift(double *z, double *x, 
        const double alpha, const double beta, size_t n);
void save_axpby(double *z, double *x, double *y,
        const double alpha, const double beta, size_t n);

/** Computes ||alpha*x+beta*y+gamma*f||
 */
double norm_1_axpbypgf(double *x, double *y, double *f,
        const double alpha, const double beta, const double gamma, size_t n);
double norm_1_axpbypg(double *x, double *y, 
        const double alpha, const double beta, const double gamma, size_t n);
#endif /* VECFUN_H */

