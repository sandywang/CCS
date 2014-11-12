/*
 * David Gleich
 * Copyright, Stanford University, 2008
 * 10 May 2008
 */

/**
 * @file pagerank_power.hpp
 * The power method implemented for computing PageRank on a generic graph type
 * with double vectors.
 */

/** History
 *  2008-05-10: Initial coding based on previous code.
 *  2008-05-23: Checked iteration count for code
 */

#include "simple_timers.hpp"

/** Solve PageRank using the power method.
 *
 * When the graph implements a sub-stochastic multiplication, then this 
 * method computes PageRank in the strongly preferrential case.  
 *
 * If the personalization vector is NULL, then it implicity uses
 * the uniform teleportation vector v_i = 1/n.
 *
 * The operation depends upon the following routines:
 *   size(g)                         number of vertices in graph g
 *   mult(g, x, y, alpha, &sumy)     y <- a*P'*x; sumy = sum(y)
 *   shift_and_norm_1(y,w,n)         y <- y + omega
 *   xpby_and_norm_1(y,v,w,n)        y <- y + omega*v
 *   scale_and_norm_diff_1(x,y,ny,n) y <- y*ny; return norm(y-x,1)
 * 
 * @param g the bvgraph
 * @param alpha the value of alpha in the computation
 * @param tol the stopping tolerance
 * @param maxiter the maximum number of iterations
 * @param x a vector initialized to 1/size(g) or v_i in each component
 * @param y a vector which can be initialized to anything
 * @param 
 * @return the pointer to the vector (x or y) that contains the solution
 */
template <typename Graph>
double* power_alg_vecs(Graph g, double alpha, double tol, int maxit, 
                    double *v, double *x, double *y)
{
    size_t n = size(g); stime_struct start; 
    int iter = 0; double delta = 2, sumy, ny;
    simple_time_clock(&start);
    while (delta > tol && iter++ < maxit) {
        if (mult(g, x, y, alpha, &sumy)) { return (NULL); }
        double w = (1.0-sumy);
        if (v==NULL) {
            ny = shift_and_norm_1(y,w/(double)n,n); 
        } else {
            ny = xpby_and_norm_1(y,v,w,n);
        }
        delta=scale_and_norm_diff_1(x,y,1.0/ny,n);
#ifdef BVALGS_VERBOSE
        printf("power : iter = %6i ; delta = %10e ; dt = %7.1f sec\n", 
            iter, delta, elapsed_time(&start));
#endif        
        { double *temp; temp = x; x = y; y = temp; } set(y, 0.0, n);
    }
    if (delta > tol) { 
        printf("power(%6.4f) did not converge to %8e in %6i iterations\n", 
            alpha, tol, maxit); fflush(stdout);
    } else {
        printf("power : solved pagerank(a=%6.4f) in %5i mults to %8e tol\n",
            alpha, iter, tol); fflush(stdout);
    }
    return x;
}

/** Solve PageRank using the power method with uniform teleportation
 * 
 * For the strongly preferential model of PageRank with uniform 
 * teleportation, this algorithm computes a vector x such that
 * x \approx alpha (P + dv')'*x + (1-alpha) ve'*x
 * 
 * This method inputs and outputs a PageRank vector in prvec.
 */
template <typename Graph>
void power_alg(Graph g, double alpha, double tol, int maxiter, 
               std::vector<double>& prvec)
{
    std::vector<double> v2(size(g));
    set(&prvec[0],1./(double)size(g),size(g));
    double *x = power_alg_vecs(g,alpha,tol,maxiter, NULL, &prvec[0],&v2[0]);
    if (x!=&prvec[0]) { copy(x,&prvec[0],size(g)); }
}    
