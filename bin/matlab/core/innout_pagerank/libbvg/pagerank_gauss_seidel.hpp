/*
 * David Gleich
 * Copyright, Stanford University, 2008
 * 12 May 2008
 */

/**
 * @file pagerank_gauss_seidel.hpp
 * A gauss-seidel iteration for computing the PageRank vector 
 */

/** History
 *  2008-05-12: Initial coding
 *  2008-05-23: Added normed option, modified residual computation
 *              Checked iteration and mult cou
 */
 
#ifndef PAGERANK_GAUSS_SEIDEL_HPP
#define PAGERANK_GAUSS_SEIDEL_HPP

#include "simple_timers.hpp"

template <typename Graph>
double compute_residual(Graph g, double *x, double *y, double *v, 
        const double alpha, const double dtx, const double sumx)
{
    size_t n = (size_t)size(g); double sumy, ny;
    if (mult(g, x, y, alpha, &sumy)) { return (NULL); }
    double w = (alpha*dtx + (1-alpha)*sumx);
    if (v==NULL) {
        ny = shift_and_norm_1(y,w/(double)n,n); 
    } else {
        ny = xpby_and_norm_1(y,v,w,n);
    }
    return (1.0/ny)*norm_diff_1_and_scale(x,y,1.0/ny,n);
}

/** The gauss-seidel iteration with all parameters specified
 *
 * This function does not check any of its arguments for consistency
 * so please use one of the wrapper functions if you don't know what
 * to pick.
 */
template <typename Graph>
double* gauss_seidel_alg_vecs(Graph g, double alpha, double tol, int maxit, 
                      double *v, double *x, double *y, bool resid, bool normed)
{
    size_t n = (size_t)size(g);
    stime_struct start; 
    int nmult = 0, iter = 0, rval, nresit=0, lresit; 
    double delta = 2, nx, ndiff, dsum, dt=0, ltol=log(tol), la=log(alpha);
    printf("gs(%6.4f,%1i,%1i) with tol=%8e and maxit=%6i iterations\n", 
            alpha, (int)resid, (int)normed, tol, maxit); fflush(stdout);
            
    simple_time_clock(&start);
    dsum = sum_dtx(g,x);
    while (delta > tol && iter++ < maxit) {
        rval = gauss_seidel_sweep(g, x, NULL, v, 
                    alpha, (1.0-alpha), dsum, false, &nx, &ndiff, &dsum);
        nmult++;
        if (normed) {
            shift_and_scale(x,0.0,1./nx,n); dsum=dsum/nx; nx=1.0;
        }
        if (rval) { return (NULL); }
        dt += elapsed_time(&start);
        /* compute the residual */
        if (resid) {
            delta = compute_residual(g,x,y,v,alpha,dsum,nx); nmult++;
            simple_time_clock(&start);
        } else {
            simple_time_clock(&start);
            if (ndiff < tol && iter>nresit) {
                delta = compute_residual(g,x,y,v,alpha,dsum,nx); nmult++;
                nresit=iter+(int)((ltol - log(delta))/(2.0*la));
            }
        }
#ifdef BVALGS_VERBOSE
        printf("   gs : iter = %6i ; delta = %10e ; diff = %10e ; dt = %7.1f sec ; nmult = %6i\n", 
            iter, delta, ndiff, dt, nmult );
#endif                       
    }
    if (delta > tol) { 
        printf("gs(%6.4f) did not converge to %8e in %6i sweeps\n", 
            alpha, tol, maxit); fflush(stdout);
    } else {
        printf("gs : solved pagerank(a=%6.4f) in %5i sweeps and %5i mults to %8e tol\n",
            alpha, iter, nmult, tol); fflush(stdout);
    }
    return y;
}

template <typename Graph>
void gauss_seidel_alg(Graph g, double alpha, double tol, int maxiter,
        std::vector<double>& prvec)
{
    std::vector<double> v2(size(g));
    set(&prvec[0],1./(double)size(g),size(g));
    double *x = gauss_seidel_alg_vecs(g,alpha,tol,maxiter,NULL,&prvec[0],&v2[0],true,false);
    if (x!=&prvec[0]) { copy(x,&prvec[0],size(g)); }
}        

template <typename Graph>
void gauss_seidel_alg(Graph g, double alpha, double tol, int maxiter,
        std::vector<double>& prvec, bool resid, bool normed)
{
    std::vector<double> v2(size(g));
    set(&prvec[0],1./(double)size(g),size(g));
    double *x = gauss_seidel_alg_vecs(g,alpha,tol,maxiter,NULL,&prvec[0],&v2[0],resid,normed);
    if (x!=&prvec[0]) { copy(x,&prvec[0],size(g)); }
}        

#endif /* PAGERANK_GAUSS_SEIDEL_HPP */
