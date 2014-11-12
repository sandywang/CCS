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
 
#ifndef PAGERANK_INOUTGS_HPP
#define PAGERANK_INOUTGS_HPP 
 
#include "simple_timers.hpp"

#include "pagerank_gauss_seidel.hpp"
#include "pagerank_inout.hpp"

/** The inner-outer iteration applied to the gauss-seidel iteration
 *
 * This functin does not check any of its arguments for consistency
 * so please use one of the wrapper functions if you don't know what
 * to pick.
 */
template <typename Graph>
double* inner_outer_gauss_seidel_alg_vecs(
                      Graph g, double alpha, double tol, int maxit, 
                      double *v, double *x, double *y, double *f, 
                      double beta, double itol, bool resid, bool normed)
{
    size_t n = (size_t)size(g);
    stime_struct start; simple_time_clock(&start);
    
    printf("inoutgs(%6.4f,%6.4f,%8e,%1i) with tol=%8e and maxit=%6i iterations\n", 
            alpha, beta, itol, resid, tol, maxit); fflush(stdout);

    double odelta, sumy=0.0, dtx, nx, ndiff, ltol=log(tol), la=log(alpha), dt;
    if (dangling_mult(g, x, y, v, 1.0, &dtx, NULL)) { return (NULL); }
    odelta = compute_outer_residual(x, y, v, alpha, n);
    int iter = 0, rval, nresit = 0, nmult = 1, nresids = 0;
#ifdef BVALGS_VERBOSE
        printf(" iogs (outer) : iter = %6i ; odelta = %10e ; dt = %7.1f\n", 
                    iter, odelta, elapsed_time(&start));
#endif     
    while (odelta > tol && nmult < maxit) {
        int iiter=0; 
        double idelta = odelta;
        compute_f(f, y, v, alpha, beta, n); 
        while (iter+iiter < maxit && idelta > itol) {
            gauss_seidel_sweep(g, x, NULL, f, 
                    beta, 1.0, dtx, false, &nx, &idelta, &dtx); nmult++;
            if (normed) {
                shift_and_scale(x,0.0,1./nx,n); dtx=dtx/nx; nx=1.0;
            }
            idelta = idelta; iiter++; // adjust for diff and not residual
        }
        if (dangling_mult(g, x, y, v, 1.0, &dtx, &dtx)) { return (NULL); }
        iter++; nmult++;
        odelta = compute_outer_residual(x,y,v,alpha,n);
#ifdef BVALGS_VERBOSE
        printf(" iogs (outer) : iter = %6i ; odelta = %10e ; dt = %7.1f ; nmult = %9i\n", 
                    iter, odelta, elapsed_time(&start), nmult);
#endif 
        if (iiter < 2 || odelta < itol) {
            break; 
        }
    }
    dtx = sum_dtx(g,x); dt = elapsed_time(&start);
    simple_time_clock(&start);
    while (odelta > tol && nmult-nresids < maxit) {
        rval = gauss_seidel_sweep(g, x, NULL, v, 
                    alpha, (1.0-alpha), dtx, false, &nx, &ndiff, &dtx);
        nmult++; iter++;
        if (normed) {
            shift_and_scale(x,0.0,1./nx,n); dtx=dtx/nx; nx=1.0;
        }
        if (rval) { return (NULL); }
        dt += elapsed_time(&start);
        
        /* compute the residual */
        if (resid) {
            odelta = compute_residual(g,x,y,v,alpha,dtx,nx); nmult++; nresids++;
            simple_time_clock(&start);
        } else {
            simple_time_clock(&start);
            if (ndiff < tol && iter>nresit) {
                odelta = compute_residual(g,x,y,v,alpha,dtx,nx); nmult++; nresids++;
                nresit=iter+(int)((ltol - log(odelta))/(2.0*la));
            }
        }
#ifdef BVALGS_VERBOSE
        printf(" iogs (   gs) : iter = %6i ; delta = %10e ; diff = %10e ; dt = %7.1f sec ; nmult = %6i\n", 
            iter, odelta, ndiff, dt, nmult );
#endif                
    }
    if (odelta > tol) { 
        printf("iogs(%6.4f) did not converge to %8e in %6i sweeps\n", 
            alpha, tol, maxit); fflush(stdout);
    } else {
        printf("iogs : solved pagerank(a=%6.4f) in %5i its, %5i sweeps, and %5i mults to %8e tol\n",
            alpha, iter, nmult-nresids, nmult, tol); fflush(stdout);
    }
    return y;
}

template <typename Graph>
void inner_outer_gauss_seidel_alg(Graph g, double alpha, double tol, int maxiter,
        std::vector<double>& prvec)
{
    std::vector<double> v2(size(g));
    set(&prvec[0],1./(double)size(g),size(g));
    double *x = gauss_seidel_alg_vecs(g,alpha,tol,maxiter,NULL,&prvec[0],&v2[0],true);
    if (x!=&prvec[0]) { copy(x,&prvec[0],size(g)); }
}        

template <typename Graph>
void inner_outer_gauss_seidel_alg(Graph g, double alpha, double tol, int maxiter,
        std::vector<double>& prvec, double beta, double itol, bool resid, bool normed)
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
    x=inner_outer_gauss_seidel_alg_vecs(g,alpha,tol,maxiter,NULL,
                            &prvec[0],&vec2[0],&vec3[0],
                            beta, itol, resid, normed);
    if (x!=&prvec[0]) { copy(x,&prvec[0],size(g)); }
}     


#endif /* PAGERANK_INOUTGS_HPP */
