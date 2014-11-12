/*
 * David Gleich
 * Copyright, Stanford University, 2008
 * 4 February 2008
 */

/**
 * @file bvalgs_common.hpp
 * Implement some common routines designed to be included into a single .cc
 * file as a set of "library" like routines.
 */
 
/**
 * 4 February 2008
 * Initial version
 * 
 * 5 February 2008
 * Implemented compensated summation algorithm for correct norms
 *
 * 21 February 2008
 * Corrected a bug in inoutpr and compute_power_start
 * Fixed initialization to powerpr and inoutpr
 * Changed PageRank to get the proper multiplication count (off by one error)
 *
 * 2008-05-01: Modified code to be bvalgs.hpp instead of rapr_common.hpp
 *             Added inner-outer functions that take additional beta, itol 
 *             parameters
 *             Added time to iteration output
 */

#include "simple_timers.hpp"

/**
 * given y[2] (a vector of length 2 of summation values)
 *       x        (the new summand)
 *       t        (a temp variable)
 * CSUM(x,svals,t) "computes y+= x" with compensated summation
 */
// y[0] = sum; y[1] = e 
#define CSUM(x,y,t,z) { t=y[0]; z=(x)+y[1]; y[0]=t+z; y[1]=(t-y[0])+z; }
#define FCSUM(y) (y[0]+y[1])

//#define CSUM(x,y,t) { y[1]=(x)-y[2]; t=y[0]+y[1]; y[2]=(t-y[0])-y[1]; y[0]=t; }
//#define FCSUM(y) (y[0])
/** Compute the sum of an array x of length x
 */ 
double sum(double *x, size_t n)
{
    double s[2]={0},t,z;
    while (n-- > 0) { CSUM(*x++,s,t,z); }
    return (FCSUM(s));
}

/** Compute a shifted array x = x + s, where s is a scalar.
 */
void shift(double *x, double s, size_t n)
{
    while (n-- > 0) {
        *x += s; x++;
    }
}

/** Compute a shifted and scaled array x <- a*(x+s), where a and s are scalars
 */
void shift_and_scale(double *x, double s, double a, size_t n)
{
    while (n-- > 0) {
        *x += s; *x *= a; x++;
    }
}

/** Set an array to a particular value, x = s, where s is a scalar.
 */
void set(double *x, double s, size_t n)
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
 */
double diff_norm_1(double* x, double *y, size_t n)
{
    double s[2]={0},t,z; 
    while (n-- > 0) { CSUM(fabs(*x++ - *y++),s,t,z); }
    return (FCSUM(s));
    /*double s=0.,e=0.,t,z;
    while (n-- > 0) { t=s; z=fabs(*x++ - *y++)+e; s=t+z; e=(t-s); e = e+z; }
    return (s+e);*/
}

double norm_1(double *x, size_t n) {

    double s[2]={0},t,z; 
    while (n-- > 0) { CSUM(fabs(*x++),s,t,z); }
    return (FCSUM(s));
}
        
double make_unit_norm_1(double* x, size_t n)
{
    double n1 = norm_1(x,n);
    while (n-- > 0) { *x/=n1; x++; }
    return (n1);
}

/** Compute a matrix vector product with a substochastic bvgraph structure
 * 
 * y = y + alpha*P'*x where P = D^{-1} A for the adjacency matrix A given
 * by a bvgraph structure.
 * 
 * @param g the bvgraph
 * @param x the right hand vector,
 * @param y the output vector y = y + alpha*P'*x
 * @param alpha the value of alpha to adjust the mutliplication by
 * @param sum_aPtx the value e^T (alpha*P'*x)
 * @return non-zero on error
 */
int mult(bvgraph *g, double *x, double *y, double alpha, double *sum_aPtx)
{
    using namespace std;
    bvgraph_iterator git;
    int rval = bvgraph_nonzero_iterator(g, &git);
    if (rval) {
        cerr << "error: cannot get bvgraph iterator " << endl;
        cerr << "bvgraph error: " << bvgraph_error_string(rval) << endl;
        cerr << "halting iteration..." << endl;
        return (-1);
    }

    int *links; unsigned int i, d;
    double id=0.0; double sumy[2]={0},t,z;
    for (; bvgraph_iterator_valid(&git); bvgraph_iterator_next(&git)) {
        bvgraph_iterator_outedges(&git, &links, &d);
        if (d > 0) { id = 1.0/(double)d; }
        for (i = 0; i < d; i++) {
            y[links[i]] += alpha*x[git.curr]*id;
            CSUM(alpha*x[git.curr]*id,sumy,t,z);
        }
    }
    if (sum_aPtx) { *sum_aPtx = FCSUM(sumy); }
    bvgraph_iterator_free(&git);
    return (0);
} 

/** Compute a matrix vector product with a stochastic bvgraph structure
 * 
 * y = y + alpha*(P+dv')'*x where P = D^{-1} A for the adjacency matrix A 
 * given by a bvgraph structure and d is the dangling node indicator, 
 * and v = 1/n * e, and e is the vector of all ones.  This corresponds 
 * to a matrix vector product with the stochastic matrix in strongly 
 * preferential PageRank with uniform teleportation.
 * 
 * @param g the bvgraph
 * @param x the right hand vector,
 * @param y the output vector y = y + alpha*(P+dv)'*x
 * @param alpha the value to scale the multiplication by
 * @return non-zero on error
 */
int dangling_mult(bvgraph *g, double *x, double *y, double alpha, size_t n)
{
    using namespace std;
    bvgraph_iterator git;
    int rval = bvgraph_nonzero_iterator(g, &git);
    if (rval) {
        cerr << "error: cannot get bvgraph iterator" << endl;
        cerr << "bvgraph error: " << bvgraph_error_string(rval) << endl;
        cerr << "halting iteration..." << endl;
        return (-1);
    }

    int *links; unsigned int i, d;
    double id=0.0, sumPtxs[2]={0},t,z;

    for (; bvgraph_iterator_valid(&git); bvgraph_iterator_next(&git)) {
        bvgraph_iterator_outedges(&git, &links, &d);
        if (d > 0) { id = 1.0/(double)d; }
        for (i = 0; i < d; i++) {
            y[links[i]] += alpha*x[git.curr]*id;
            CSUM(x[git.curr]*id,sumPtxs,t,z);
        }
    }
    bvgraph_iterator_free(&git);
    shift(y, alpha*((sum(x,n) - FCSUM(sumPtxs))/(double)g->n), g->n);
    return (0);
}


/** Solve PageRank using the power method with uniform teleportation
 * 
 * For the strongly preferential model of PageRank with uniform 
 * teleportation, this algorithm computes a vector x such that
 * x \approx alpha (P + dv')'*x + (1-alpha) ve'*x
 * 
 * @param g the bvgraph
 * @param alpha the value of alpha in the computation
 * @param tol the stopping tolerance
 * @param maxiter the maximum number of iterations
 * @param x a vector initialized to 1/g.n in each component
 * @param y a vector initialized to 0 in each component
 * @return the pointer to the vector (x or y) that contains the solution
 */
double* power_alg_vecs(bvgraph* g, double alpha, double tol, int maxit, 
                    double *x, double *y)
{
    size_t n = (size_t)g->n, n1; stime_struct start; 
    int iter = 0; register double delta = 2, sumy, ny, *xi, *yi, t, z;
    simple_time_clock(&start);
    while (delta > tol && iter++ < maxit) {
        if (mult(g, x, y, alpha, &sumy)) { return (NULL); }
        double w = (1.0-sumy)/(double)n,nys[2]={0}; delta=0.0; 
        n1=n;yi=y; while (n1-->0) { (*yi)+=w; CSUM(fabs(*yi++),nys,t,z); }  
        n1=n;yi=y;xi=x;ny=FCSUM(nys);nys[0]=0.;nys[1]=0.;
        while (n1-->0) {(*yi)/=ny; CSUM(fabs(*yi++-*xi++),nys,t,z);} delta=FCSUM(nys);
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
void power_alg(bvgraph* g, double alpha, double tol, int maxiter, 
               std::vector<double>& prvec)
{
    std::vector<double> v2(g->n);
    set(&prvec[0],1./(double)g->n,g->n);
    double *x = power_alg_vecs(g,alpha,tol,maxiter,&prvec[0],&v2[0]);
    if (x!=&prvec[0]) { copy(x,&prvec[0],g->n); }
}    

double compute_outer_residual(double *x, double *y, double alpha, size_t n)
{
    double r[2]={0}, in = (1.0-alpha)/(double)n, t,z;
    while (n-->0) { CSUM(fabs(alpha*(*y++) - *x++ + in),r,t,z); }
    return (FCSUM(r));
}

double compute_inner_residual(double *x, double *y, double *f, double beta, size_t n)
{
    double r[2]={0},t,z;
    while (n-->0) { CSUM(fabs(*f++ + beta*(*y++)-*x++),r,t,z); }
    return (FCSUM(r));
}

void compute_f(double *f, double *y, double alpha, double beta, size_t n)
{
    double amb = alpha-beta; double vi=(1.0 -alpha)/(double)n;
    while (n-->0) { *f++ = amb*(*y++) + vi; }
}

void axpysz(double *z, double *x, double *y, double alpha, size_t n) 
{
    while (n-->0) { *z++ = alpha*(*x++) + (*y++); }
}

void compute_power_start(double *x, double *y, double alpha, size_t n)
{
    double vi=(1.0 -alpha)/(double)n;
    while (n-->0) { *x++ = alpha*(*y++) + vi; }
}

/** The inner-outer iteration with all parameters specified
 *
 * This functin does not check any of its arguments for consistency
 * so please use one of the wrapper functions if you don't know what
 * to pick.
 */
double* inner_outer_alg_vecs(bvgraph* g, double alpha, double tol, int maxit, 
                      double *x, double *y, double *f, double beta, double itol)
{
    double *xi, *yi, t, z; 
    size_t n = (size_t)g->n, n1;
    stime_struct start; simple_time_clock(&start);
    
    printf("inout(%6.4f,%6.4f,%8e) with tol=%8e and maxit=%6i iterations\n", 
            alpha, beta, itol, tol, maxit); fflush(stdout);

    if (dangling_mult(g, x, y, 1.0, n)) { return (NULL); }
    double odelta = compute_outer_residual(x, y, alpha, n), sumy=0.0;
    int iter = 1;
    while (odelta > tol && iter < maxit) {
        int iiter=0; compute_f(f, y, alpha, beta, n);
        while (iter+iiter < maxit && compute_inner_residual(x,y,f,beta,n) > itol) {
            axpysz(x,y,f,beta,n);
            set(y, 0.0, n);
            dangling_mult(g, x, y, 1.0, n); iiter++;
        }
        iter+=iiter; if (iiter == 0) { compute_power_start(x,y,alpha,n); break; }
        odelta = compute_outer_residual(x,y,alpha,n);
#ifdef BVALGS_VERBOSE
        printf("inout (outer) : iter = %6i ; odelta = %10e ; dt = %7.1f\n", 
	                iter, odelta, elapsed_time(&start));
#endif 
    }
    while (odelta > tol && iter++ < maxit) {
        set(y, 0.0, n); if (mult(g, x, y, alpha, &sumy)) { return (NULL); }
        double w = (1.0-sumy)/(double)n,nys[2]={0}, ny; odelta=0.0; 
        n1=n;yi=y; while (n1-->0) { (*yi)+=w; CSUM(fabs(*yi++),nys,t,z); }  
        n1=n;yi=y;xi=x;ny=FCSUM(nys);nys[0]=0.;nys[1]=0.;
        while (n1-->0) {(*yi)/=ny; CSUM(fabs(*yi++-*xi++),nys,t,z);} odelta=FCSUM(nys);  
#ifdef BVALGS_VERBOSE
        printf("inout (power) : iter = %6i ; delta = %10e ; dt = %7.1f\n",
                   iter, odelta, elapsed_time(&start));
#endif         
        { double *temp; temp = x; x = y; y = temp; } 
    }
    if (odelta > tol) { 
        printf("inout(%6.4f,%6.4f,%8e) did not converge to %8e in %6i iterations\n", 
            alpha, beta, itol, tol, maxit); fflush(stdout);
    } else {
        printf("inout(b=%6.4f,it=%7e) : solved pagerank(a=%6.4f) in %5i mults to %8e tol\n",
            beta, itol, alpha, iter, tol); fflush(stdout);
    }
    return x;
}
                
double* inner_outer_alg_vecs(bvgraph* g, double alpha, double tol, int maxit, 
                      double *x, double *y, double *f)
{
    double beta = 0.5*(alpha>0.6), itol = 1.e-2;
    return inner_outer_alg_vecs(g, alpha, tol, maxit, x, y, f, beta, itol);
}

void inner_outer_alg(bvgraph* g, double alpha, double tol, int maxiter, 
                     std::vector<double>& prvec)
{
    double *x;  std::vector<double> vec2(g->n), vec3(g->n);
    set(&prvec[0],1./(double)g->n,g->n);
    x=inner_outer_alg_vecs(g,alpha,tol,maxiter,&prvec[0],&vec2[0],&vec3[0]);
    if (x!=&prvec[0]) { copy(x,&prvec[0],g->n); }
}

void inner_outer_alg(bvgraph* g, double alpha, double tol, int maxiter, 
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

    double *x;  std::vector<double> vec2(g->n), vec3(g->n);
    set(&prvec[0],1./(double)g->n,g->n);
    x=inner_outer_alg_vecs(g,alpha,tol,maxiter,&prvec[0],&vec2[0],&vec3[0],
                            beta, itol);
    if (x!=&prvec[0]) { copy(x,&prvec[0],g->n); }
}
