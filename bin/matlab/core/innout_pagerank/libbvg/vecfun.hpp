/*
 * David Gleich
 * Copyright, Stanford University, 2008
 * 10 May 2008
 */

/**
 * @file vecfun.hpp
 * Full definitions for vector functions suitable for simple inclusion.
 */

/** History
 *  2008-05-10: Initial coding based on previous code.
 *  2008-05-15: Added axpysz_and_norm_1 computation
 *  2008-05-21: Added comments
 */

#include "vecfun.h"
#include "csum.h"

#ifdef VECFUNOMP_HPP
#error "Do not include both vecfun.hpp and vecfunomp.hpp"
#endif /* VECFUNOMP_HPP */

#ifndef VECFUN_HPP
#define VECFUN_HPP

/** Compute the sum of an array x of length n.
 * 
 * The sum is computed with compensated summation.
 * 
 * @return the sum of all elements in the vector
 */ 
double sum(double *x, size_t n)
{
    double s[2]={0},t,z;
    while (n-- > 0) { CSUM(*x,s,t,z); x++; }
    return (FCSUM(s));
}

/** Compute a shifted array x <- x + s, where s is a scalar.
 */
void shift(double *x, const double s, size_t n)
{
    while (n-- > 0) {
        *x += s; x++;
    }
}

/** Compute a shifted and scaled array x <- a*(x+s), where a and s are scalars
 */
void shift_and_scale(double *x, const double s, const double a, size_t n)
{
    while (n-- > 0) {
        *x += s; *x *= a; x++;
    }
}

/** Set an array to a particular value, x[i] <- s, where s is a scalar.
 */
void set(double *x, const double s, size_t n)
{
    while (n-- > 0) {
        *x = s; x++;
    }
}

/** Copy an array to another, y <- x 
 */
void copy(double *x, double *y, size_t n)
{
    while (n-- > 0) {
        *y = *x; x++; y++;
    }
}

/** Compute the norm-1 difference between two vectors of length n, ||x-y||_1 
 * @return ||x-y||_1
 */
double diff_norm_1(double* x, double *y, size_t n)
{
    double s[2]={0},t,z; 
    while (n-- > 0) { CSUM(fabs(*x - *y),s,t,z); x++; y++; }
    return (FCSUM(s));
}

/** Compute the norm-1 of a vector x, ||x||_1 
 */
double norm_1(double *x, size_t n) 
{
    double s[2]={0},t,z; 
    while (n-- > 0) { CSUM(fabs(*x),s,t,z); x++; }
    return (FCSUM(s));
}

/** Normalize a vector in the 1-norm, x <- x/||x||_1
 * @return ||x||_1
 */
double make_unit_norm_1(double* x, size_t n)
{
    double n1 = norm_1(x,n);
    shift_and_scale(x, 0.0, 1.0/n1, n);
    return (n1);
}

/** Compute x <- x+beta*y
 */
void xpby(double *x, double *y, const double beta, size_t n) 
{
    while (n-->0) { *x++ += beta*(*y++); }
}

/** Compute z<-alpha*x+y
 */
void axpysz(double *z, double *x, double *y, const double alpha, size_t n) 
{
    while (n-->0) { *z++ = alpha*(*x++) + (*y++); }
}

/** Compute z <- alpha*x+y and then ||z||
 * @return ||z||
 */
double axpysz_and_norm_1(double *f, double *x, double *y, const double alpha, size_t n) 
{
    double s[2]={0}, t, z;
    while (n-->0) { *f = alpha*(*x++) + (*y++); CSUM(fabs(*f),s,t,z); f++; }
    return FCSUM(s);
}

/** Compute x <- x + w for a scalar w and then ||x||_1
 * @return ||x||_1 after the operation
 */
double shift_and_norm_1(double *x, const double w, size_t n) 
{
    double s[2]={0}, t, z;
    while (n-->0) { *x+=w; CSUM(fabs(*x),s,t,z); x++; }
    return FCSUM(s);
}

/** Compute x <- x + beta*y, and then ||x||_1
 * @return ||x||_1
 */
double xpby_and_norm_1(double *x, double *y, const double beta, size_t n)
{
    double s[2]={0}, t, z;
    while (n-->0) { *x+=beta*(*y); CSUM(fabs(*x),s,t,z); x++; y++; }
    return FCSUM(s);
}

/** Compute y <- beta*y, and ||x-y||_1 after the scaling
 * @return ||x-y||_1
 */
double scale_and_norm_diff_1(double *x, double *y, const double beta, size_t n)
{
    double nd[2]={0}, t, z;
    while (n-->0) { *y *=beta; CSUM(fabs(*y-*x),nd,t,z); y++; x++; }
    return FCSUM(nd);
}

/** Compute ||x-y||_1 and scale y <- beta*y after computing the norm
 * @return ||x-y||_1
 */
double norm_diff_1_and_scale(double *x, double *y, const double beta, size_t n)
{
    double nd[2]={0}, t, z;
    while (n-->0) { CSUM(fabs(*y-*x),nd,t,z); *y *=beta; y++; x++; }
    return FCSUM(nd);
}

/** Computes z <- alpha*x+beta 
 */
void save_scale_and_shift(double *z, double *x, 
        const double alpha, const double beta, size_t n)
{
    while (n-->0) { *z++ = alpha*(*x++) + beta; }
}

/** Computes z <- alpha*x+beta*y  
 */
void save_axpby(double *z, double *x, double *y,
        const double alpha, const double beta, size_t n)
{
    while (n-->0) { *z++ = alpha*(*x++) + beta*(*y++); }
}

/** Computes ||alpha*x+beta*y+gamma*f||_1
 * This operation uses all vectors in place.
 * @return ||alpha*x+beta*y+gamma*f||_1
 */
double norm_1_axpbypgf(double *x, double *y, double *f,
        const double alpha, const double beta, const double gamma, size_t n) 
{
    double r[2]={0},t,z;
    while (n-->0) { 
        CSUM(fabs(alpha*(*x)+beta*(*y)+gamma*(*f)),r,t,z); 
        x++; y++; f++;
    }
    return (FCSUM(r));
}

/** Computes ||alpha*x+beta*y+gamma||_1
 * This operation uses all vectors in place.
 * @return ||alpha*x+beta*y+gamma||_1
 */
double norm_1_axpbypg(double *x, double *y, 
        const double alpha, const double beta, const double gamma, size_t n) 
{
    double r[2]={0}, t,z;
    while (n-->0) { CSUM(fabs(alpha*(*x)+beta*(*y)+gamma),r,t,z); x++; y++; }
    return (FCSUM(r));
}

#endif /* VECFUN_HPP */

