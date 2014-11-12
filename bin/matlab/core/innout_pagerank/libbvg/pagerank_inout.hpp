/*
 * David Gleich
 * Copyright, Stanford University, 2008
 * 10 May 2008
 */

/**
 * @file pagerank_inout.hpp
 * The inner-outer method for computing PageRank implemented on a generic
 * graph type with double vectors.
 */

/** History
 *  2008-05-10: Initial coding based on previous code.
 *  2008-05-13: Removed unnecessary inner-residual computation at start of 
 *              outer iteration and saved extra outer iteration by 
 *              checking the tolerance at the end always...
 *              Also, I uncompacted the code a bit.
 *  2008-05-15: Added vector normalization step 
 *              Checked iteration and mult count
 */
 
#ifndef PAGERANK_INOUT_HPP
#define PAGERANK_INOUT_HPP 

#include "simple_timers.hpp"

/** Helper functions
 * We first declare a set of helper functions to make the code a bit more
 * more readable.  These functions also make the code easy to parallelize
 * because we just have to parallelize the underlying operations in the
 * shared memory case.
 */

/** Residual of the outer iteration is ||alpha*y-x+(1-a)*v|| */
double compute_outer_residual(double *x, double *y, double *v, double alpha, size_t n)
{
    if (v==NULL) {
        return norm_1_axpbypg(x, y, -1.0, alpha, (1.0-alpha)/(double)n, n);
    } else {
        return norm_1_axpbypgf(x, y, v, -1.0, alpha, (1.0-alpha), n);
    }
}

/** Residual of the inner iteration is ||f + beta*y - x|| */
double compute_inner_residual(double *x, double *y, double *f, double beta, size_t n)
{
    return norm_1_axpbypgf(f,y,x,1.0,beta,-1.0,n);
}

/** Right hand side of the inner iteration is f <- (alpha-beta)*y + (1-a)*v */
void compute_f(double *f, double *y, double *v, double alpha, 
        double beta, size_t n)
{
    if (v == NULL) {
        save_scale_and_shift(f, y, alpha-beta, (1.0-alpha)/(double)n, n);
    } else {
        save_axpby(f, y, v, (alpha-beta), (1.0-alpha), n);
    }
}

/** Starting iterate for the power method is x <- alpha*y + (1-a)*v */
void compute_power_start(double *x, double *y, double *v, 
        double alpha, size_t n)
{
    if (v == NULL) {
        save_scale_and_shift(x, y, alpha, (1.0-alpha)/(double)n, n);
    } else {
        save_axpby(x, y, v, alpha, (1.0-alpha), n);
    }
    make_unit_norm_1(x, n);
}

/** The inner-outer iteration with all parameters specified
 *
 * This functin does not check any of its arguments for consistency
 * so please use one of the wrapper functions if you don't know what
 * to pick.
 */
template <typename Graph>
double* inner_outer_alg_vecs(Graph g, double alpha, double tol, int maxit, 
                      double *v, double *x, double *y, double *f, 
                      double beta, double itol)
{
    size_t n = (size_t)size(g);
    stime_struct start; simple_time_clock(&start);
    
    printf("inout(%6.4f,%6.4f,%8e) with tol=%8e and maxit=%6i iterations\n", 
            alpha, beta, itol, tol, maxit); fflush(stdout);

    if (dangling_mult(g, x, y, v, 1.0, NULL, NULL)) { return (NULL); }
    double odelta = compute_outer_residual(x, y, v, alpha, n), sumy=0.0, nx;
    int iter = 0, nmult = 1;
    while (odelta > tol && iter < maxit) {
        double idelta = odelta;
        int iiter=0; 
        compute_f(f, y, v, alpha, beta, n);
        while (nmult < maxit && idelta > itol) {
            nx = axpysz_and_norm_1(x,y,f,beta,n); 
            shift_and_scale(x, 0.0, 1./nx, n);
            dangling_mult(g, x, y, v, 1.0, NULL, NULL); nmult++; 
            idelta = compute_inner_residual(x,y,f,beta,n); iiter++;
        } 
        odelta = compute_outer_residual(x,y,v,alpha,n); iter++;
#ifdef BVALGS_VERBOSE
        printf("inout (outer) : iter = %6i ; odelta = %10e ; dt = %7.1f; nmult = %6i\n", 
	                iter, odelta, elapsed_time(&start), nmult);
#endif 
        if (iiter < 2 || odelta < itol) { 
            compute_power_start(x,y,v,alpha,n); 
            break; 
        }
    }
    while (odelta > tol && nmult++ < maxit) {
        if (mult(g, x, y, alpha, &sumy)) { return (NULL); }
        double w = (1.0-sumy), ny;
        if (v==NULL) {
            ny = shift_and_norm_1(y,w/(double)n,n); 
        } else {
            ny = xpby_and_norm_1(y,v,w,n);
        }
        odelta=scale_and_norm_diff_1(x,y,1.0/ny,n); iter++;
#ifdef BVALGS_VERBOSE
        printf("inout (power) : iter = %6i ; odelta = %10e ; dt = %7.1f; nmult = %6i\n", 
                    iter, odelta, elapsed_time(&start), nmult);
#endif         
        { double *temp; temp = x; x = y; y = temp; } 
    }
    if (odelta > tol) { 
        printf("inout(%6.4f,%6.4f,%8e) did not converge to %8e in %6i mults\n", 
            alpha, beta, itol, tol, maxit); fflush(stdout);
    } else {
        printf("inout(b=%6.4f,it=%7e) : solved pagerank(a=%6.4f) in %5i mults to %8e tol\n",
            beta, itol, alpha, nmult, tol); fflush(stdout);
    }
    return x;
}

template <typename Graph>    
double* inner_outer_alg_vecs(Graph g, double alpha, double tol, int maxit, 
                      double *x, double *y, double *f)
{
    double beta = 0.5*(alpha>0.6), itol = 1.e-2;
    return inner_outer_alg_vecs(g, alpha, tol, maxit, NULL,
                                x, y, f, beta, itol);
}

template <typename Graph>
void inner_outer_alg(Graph g, double alpha, double tol, int maxiter, 
                     std::vector<double>& prvec)
{
    double *x;  std::vector<double> vec2(size(g)), vec3(size(g));
    set(&prvec[0],1./(double)size(g),size(g));
    x=inner_outer_alg_vecs(g,alpha,tol,maxiter,NULL,
            &prvec[0],&vec2[0],&vec3[0]);
    if (x!=&prvec[0]) { copy(x,&prvec[0],size(g)); }
}

template <typename Graph>
void inner_outer_alg(Graph g, double alpha, double tol, int maxiter, 
                     std::vector<double>& prvec, double beta, double itol)
{
    if (beta < 0 || beta > alpha) {
        fprintf(stderr,"\n");
        fprintf(stderr,
            "** warning: beta=%f is less than 0 or bigger than alpha=%f\n",
            beta, alpha);
        fprintf(stderr,
            "            the iteration may not converge\n");
        fprintf(stderr,"\n");
    }

    if (itol <= 0 || itol < tol) {
        fprintf(stderr,"\n");
        fprintf(stderr,
            "** warning: is your choice of itol=%e < tol=%e correct?\n",
            itol, tol);
        fprintf(stderr,"\n");
    }

    double *x;  std::vector<double> vec2(size(g)), vec3(size(g));
    set(&prvec[0],1./(double)size(g),size(g));
    x=inner_outer_alg_vecs(g,alpha,tol,maxiter,NULL,
                            &prvec[0],&vec2[0],&vec3[0],
                            beta, itol);
    if (x!=&prvec[0]) { copy(x,&prvec[0],size(g)); }
}

#endif /* PAGERANK_INOUT_HPP */
