/*
 * David Gleich
 * Copyright, Stanford University, 2008
 * 10 May 2008
 */

/**
 * @file vecfunomp.hpp
 * Full definitions of multi-core vector functions for simple inclusion.
 */

/** History
 *  2008-05-10: Initial coding based on previous code.
 *  2008-05-15: Added axpysz_and_norm_1 computation
 *  2008-05-21: Added comments
 */

#include "vecfun.h"
#include "csum.h"

#ifdef VECFUN_HPP
#error "Do not include both vecfun.hpp and vecfunomp.hpp"
#endif /* VECFUN_HPP */

#ifndef VECFUNOMP_HPP
#define VECFUNOMP_HPP

/** Compute the sum of an array x of length n.
 * 
 * The sum is computed with compensated summation.
 * 
 * @return the sum of all elements in the vector
 */ 
double sum(double *x, size_t n)
{
    ptrdiff_t i, sn=(ptrdiff_t)n;
    double s0,s1,rv0=0,rv1=0,t,z;
#pragma omp parallel shared(sn,rv0,rv1,x) private(s0,s1,t,z)
    {
        s0=0; s1=0;   
#pragma omp for private(i)
        for (i=0; i<sn; i++) { 
            CSUM2(x[i],s0,s1,t,z);
        }
#pragma omp critical
        { CSUM2(FCSUM2(s0,s1),rv0,rv1,t,z); }
    }
    return (FCSUM2(rv0,rv1));
}

/** Compute a shifted array x <- x + s, where s is a scalar.
 */
void shift(double *x, const double s, size_t n)
{
    ptrdiff_t i, sn=(ptrdiff_t)n; 
#pragma omp parallel for 
    for (i=0; i<sn; i++) { x[i] += s; }
}



/** Compute a shifted and scaled array x <- a*(x+s), where a and s are scalars
 */
void shift_and_scale(double *x, const double s, const double a, size_t n)
{
    ptrdiff_t i, sn=(ptrdiff_t)n; 
#pragma omp parallel for 
    for (i=0; i<sn; i++) { x[i] += s; x[i]*=a; }
}

/** Set an array to a particular value, x = s, where s is a scalar.
 */
void set(double *x, const double s, size_t n)
{
    ptrdiff_t i, sn=(ptrdiff_t)n; 
#pragma omp parallel for 
    for (i=0; i<sn; i++) { x[i] = s; }
}

/** Copy an array to another, y <- x 
 */
void copy(double *x, double *y, size_t n)
{
    ptrdiff_t i, sn=(ptrdiff_t)n; 
#pragma omp parallel for 
    for (i=0; i<sn; i++) { y[i] = x[i]; }
}

/** Compute the norm-1 difference between two vectors of length n, ||x-y||_1 
 * @return ||x-y||_1
 */
double diff_norm_1(double* x, double *y, size_t n)
{
    ptrdiff_t i, sn=(ptrdiff_t)n;
    double s0,s1,rv0=0,rv1=0,t,z;
#pragma omp parallel shared(sn,rv0,rv1,x,y) private(s0,s1,t,z)
    {
        s0=0; s1=0;   
#pragma omp for private(i)
        for (i=0; i<sn; i++) { 
            CSUM2(fabs(y[i]-x[i]),s0,s1,t,z);
        }
#pragma omp critical
        { CSUM2(FCSUM2(s0,s1),rv0,rv1,t,z); }
    }
    return (FCSUM2(rv0,rv1));
}

/** Compute the norm-1 of a vector x, ||x||_1 
 */
double norm_1(double *x, size_t n) 
{
    ptrdiff_t i, sn=(ptrdiff_t)n;
    double s0,s1,rv0=0,rv1=0,t,z;
#pragma omp parallel shared(sn,rv0,rv1,x) private(s0,s1,t,z)
    {
        s0=0; s1=0;   
#pragma omp for private(i)
        for (i=0; i<sn; i++) { 
            CSUM2(fabs(x[i]),s0,s1,t,z);
        }
#pragma omp critical
        { CSUM2(FCSUM2(s0,s1),rv0,rv1,t,z); }
    }
    return (FCSUM2(rv0,rv1));
}

/** Normalize a vector in the 1-norm, x <- x/||x||_1
 * @return ||x||_1
 */
double make_unit_norm_1(double* x, size_t n)
{
    double n1 = norm_1(x,n);
    shift_and_scale(x, 0, 1.0/n1, n);
    return (n1);
}

/** Compute x <- x+beta*y
 */
void xpby(double *x, double *y, const double beta, size_t n)
{
    ptrdiff_t i, sn=(ptrdiff_t)n; 
#pragma omp parallel for 
    for (i=0; i<sn; i++) { x[i] += beta*y[i]; }
}

/** Compute z<-alpha*x+y
 */
void axpysz(double *z, double *x, double *y, const double alpha, size_t n) 
{
    ptrdiff_t i, sn=(ptrdiff_t)n; 
#pragma omp parallel for 
    for (i=0; i<sn; i++) { z[i] = alpha*x[i]+y[i]; }
}

/** Compute z <- alpha*x+y and then ||z||
 * @return ||z||
 */
double axpysz_and_norm_1(double *f, double *x, double *y, 
    const double alpha, size_t n)
{
    ptrdiff_t i, sn=(ptrdiff_t)n;
    double s0,s1,rv0=0,rv1=0,t,z;
#pragma omp parallel shared(sn,rv0,rv1,x,y) private(s0,s1,t,z)
    {
        s0=0; s1=0;   
#pragma omp for private(i)
        for (i=0; i<sn; i++) { 
            f[i]=alpha*x[i] + y[i]; CSUM2(fabs(f[i]),s0,s1,t,z);
        }
#pragma omp critical
        { CSUM2(FCSUM2(s0,s1),rv0,rv1,t,z); }
    }
    return (FCSUM2(rv0,rv1));
}



/** Compute x <- x + w for a scalar w and then ||x||_1
 * @return ||x||_1 after the operation
 */
double shift_and_norm_1(double *x, const double w, size_t n) 
{
    ptrdiff_t i, sn=(ptrdiff_t)n;
    double s0,s1,rv0=0,rv1=0,t,z;
#pragma omp parallel shared(sn,rv0,rv1,x) private(s0,s1,t,z)
    {
        s0=0; s1=0;   
#pragma omp for private(i)
        for (i=0; i<sn; i++) { 
            x[i]+=w; CSUM2(fabs(x[i]),s0,s1,t,z);
        }
#pragma omp critical
        { CSUM2(FCSUM2(s0,s1),rv0,rv1,t,z); }
    }
    return (FCSUM2(rv0,rv1));
}

/** Compute x <- x + beta*y, and then ||x||_1
 * @return ||x||_1
 */
double xpby_and_norm_1(double *x, double *y, const double beta, size_t n) 
{
    ptrdiff_t i, sn=(ptrdiff_t)n;
    double s0,s1,rv0=0,rv1=0,t,z;
#pragma omp parallel shared(sn,rv0,rv1,x,y) private(s0,s1,t,z)
    {
        s0=0; s1=0;   
#pragma omp for private(i)
        for (i=0; i<sn; i++) { 
            x[i]+=beta*y[i]; CSUM2(fabs(x[i]),s0,s1,t,z);
        }
#pragma omp critical
        { CSUM2(FCSUM2(s0,s1),rv0,rv1,t,z); }
    }
    return (FCSUM2(rv0,rv1));
}

/** Compute y <- beta*y, and ||x-y||_1 after the scaling
 * @return ||x-y||_1
 */
double scale_and_norm_diff_1(double *x, double *y, const double ny, size_t n)
{
    ptrdiff_t i, sn=(ptrdiff_t)n;
    double s0,s1,rv0=0,rv1=0,t,z;
#pragma omp parallel shared(sn,rv0,rv1,x,y) private(s0,s1,t,z)
    {
        s0=0; s1=0;   
#pragma omp for private(i)
        for (i=0; i<sn; i++) { 
            y[i]*=ny; CSUM2(fabs(y[i]-x[i]),s0,s1,t,z);
        }
#pragma omp critical
        { CSUM2(FCSUM2(s0,s1),rv0,rv1,t,z); }
    }
    return (FCSUM2(rv0,rv1));
}

/** Compute ||x-y||_1 and scale y <- beta*y after computing the norm
 * @return ||x-y||_1
 */
double norm_diff_1_and_scale(double *x, double *y, const double beta, size_t n)
{
    ptrdiff_t i, sn=(ptrdiff_t)n;
    double s0,s1,rv0=0,rv1=0,t,z;
#pragma omp parallel shared(sn,rv0,rv1,x,y) private(s0,s1,t,z)
    {
        s0=0; s1=0;   
#pragma omp for private(i)
        for (i=0; i<sn; i++) { 
            CSUM2(fabs(y[i]-x[i]),s0,s1,t,z); y[i]*=beta;
        }
#pragma omp critical
        { CSUM2(FCSUM2(s0,s1),rv0,rv1,t,z); }
    }
    return (FCSUM2(rv0,rv1));
}

/** Computes z <- alpha*x+beta 
 */
void save_scale_and_shift(double *z, double *x, 
        const double alpha, const double beta, size_t n)
{
    ptrdiff_t i, sn=(ptrdiff_t)n; 
#pragma omp parallel for 
    for (i=0; i<sn; i++) { z[i] = alpha*x[i]+beta; }
}

/** Computes z <- alpha*x+beta*y  
 */
void save_axpby(double *z, double *x, double *y,
        const double alpha, const double beta, size_t n)
{
    ptrdiff_t i, sn=(ptrdiff_t)n; 
#pragma omp parallel for 
    for (i=0; i<sn; i++) { z[i] = alpha*x[i]+beta*y[i]; }
}

/** Computes ||alpha*x+beta*y+gamma*f||_1
 * This operation uses all vectors in place.
 * @return ||alpha*x+beta*y+gamma*f||_1
 */
double norm_1_axpbypgf(double *x, double *y, double *f,
        const double alpha, const double beta, const double gamma, size_t n) 
{
    ptrdiff_t i, sn=(ptrdiff_t)n;
    double s0,s1,rv0=0,rv1=0,t,z;
#pragma omp parallel shared(sn,rv0,rv1,x,y,f) private(s0,s1,t,z)
    {
        s0=0; s1=0;   
#pragma omp for private(i)
        for (i=0; i<sn; i++) { 
            CSUM2(fabs(alpha*x[i] + beta*y[i] + gamma*f[i]),s0,s1,t,z);
        }
#pragma omp critical
        { CSUM2(FCSUM2(s0,s1),rv0,rv1,t,z); }
    }
    return (FCSUM2(rv0,rv1));
}

/** Computes ||alpha*x+beta*y+gamma||_1
 * This operation uses all vectors in place.
 * @return ||alpha*x+beta*y+gamma||_1
 */
double norm_1_axpbypg(double *x, double *y, 
        const double alpha, const double beta, const double gamma, size_t n) 
{
    ptrdiff_t i, sn=(ptrdiff_t)n;
    double s0,s1,rv0=0,rv1=0,t,z;
#pragma omp parallel shared(sn,rv0,rv1,x,y) private(s0,s1,t,z)
    {
        s0=0; s1=0;   
#pragma omp for private(i)
        for (i=0; i<sn; i++) { 
            CSUM2(fabs(alpha*x[i] + beta*y[i] + gamma),s0,s1,t,z);
        }
#pragma omp critical
        { CSUM2(FCSUM2(s0,s1),rv0,rv1,t,z); }
    }
    return (FCSUM2(rv0,rv1));

}

#endif /* VECFUNOMP_HPP */

