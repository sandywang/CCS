/* 
 * David Gleich
 * Copyright, Stanford University, 2008
 * 9 May 2008
 */

/**
 * @file bvgraphomp.c
 * OpenMP matrix routines for a bvgraph
 */

/** History
 *  2008-05-09: Initial coding
 */

#include "bvgraph.h"
#include "bvgraphomp.h"
#include "bvgraphfun.h"

#include <string.h>
#ifdef _OPENMP
#include <omp.h>
#endif /* _OPENMP */

/**
 * Computes a matrix vector product y = A*x, 
 * 
 * the number of threads used for the computation is equal to the
 * number of parallel iterators in pits  
 *
 * @param pits the parallel iterator structure which determines 
 * the number of threads
 * @param x the vector x
 * @param y the output vector y
 * @return 0 if successful
 */
int bvgraph_omp_mult(bvgraph_parallel_iterators *pits, double *x, double *y)
{
    int rval=0;
#ifdef _OPENMP    
#pragma omp parallel shared(x,y,pits) \
    reduction(|:rval) num_threads(pits->niters)
    {
        int *links, tid, nsteps; unsigned int i, d; 
        bvgraph_iterator iter;
        tid = omp_get_thread_num();
        rval = bvgraph_parallel_iterator(pits, tid, &iter, &nsteps);
        y+=iter.curr;
        if (rval == 0) { 
            for (; bvgraph_iterator_valid(&iter) && nsteps; 
                 bvgraph_iterator_next(&iter), nsteps--)
            {
                double v = 0;
                bvgraph_iterator_outedges(&iter, &links, &d);
                for (i = 0; i < d; i++) {
                    v += x[links[i]];
                }
                *(y++) = v;
            }
            bvgraph_iterator_free(&iter);
        } else {
            if (BVGRAPH_VERBOSE) { 
                fprintf(stderr,"bvgraph_omp_mult failed on thread %3i\n",tid);
            }
        }
    }
    return (rval);
#else
    /* TODO Fix this to use the parallel iterator */
    return bvgraph_mult(pits->g, x, y);
#endif /* _OPENMP */
}

/**
 * Matrix vector product y = A'*x using a bvgraph with atomic writes.
 *
 * @param pits the parallel iterator structure which determines 
 * the number of threads
 * @param x the vector x
 * @param y the output vector y
 * @return 0 if successful
 */
int bvgraph_omp_transmult(bvgraph_parallel_iterators *pits, 
                          double *x, double *y)
{
    int rval=0, j, n=pits->g->n;
#ifdef _OPENMP

#pragma omp parallel for
    for (j=0; j<n; j++) { y[j] = 0.0; }
    
#pragma omp parallel shared(x,y,pits) \
    reduction(|:rval) num_threads(pits->niters)
    {
        int *links, tid, nsteps; unsigned int i, d; 
        bvgraph_iterator iter;
        tid = omp_get_thread_num();
        rval = bvgraph_parallel_iterator(pits, tid, &iter, &nsteps);
        if (rval == 0) { 
            for (; bvgraph_iterator_valid(&iter) && nsteps; 
                 bvgraph_iterator_next(&iter), nsteps--)
            {
                double xval = x[iter.curr];
                bvgraph_iterator_outedges(&iter, &links, &d);
                for (i = 0; i < d; i++) {
#pragma omp atomic                    
                    y[links[i]] += xval;
                }
            }
            bvgraph_iterator_free(&iter);
        } else {
            if (BVGRAPH_VERBOSE) { 
                fprintf(stderr,"bvgraph_omp_transmult failed on thread %3i\n",
                    tid);
            }
        }
    }
    return (rval);
#else
    /* TODO Fix this to use the parallel iterator */
    return bvgraph_transmult(pits->g, x, y);
#endif /* _OPENMP */
}

/**
 * Matrix vector product y = A'*x using a bvgraph with extra memory.
 * 
 * Sometimes, this operation is faster than the atomic write version.  
 * However, it requires a large amount of extra memory. 
 * 
 * @param pits the parallel iterator structure which determines 
 * the number of threads
 * @param x the vector x
 * @param y the output vector y
 * @param work must be an array of (pits->niters-1)*length(x) 
 * @return 0 if successful
 */
int bvgraph_omp_transmult_extra(bvgraph_parallel_iterators *pits, 
                            double *x, double *y, double *work)
{ 
    int rval=0, j, k, n=pits->g->n;
#ifdef _OPENMP    
#pragma omp parallel shared(x,y,work,pits)  private(j) \
    reduction(|:rval) num_threads(pits->niters)
    {
        int *links, tid, nsteps; unsigned int i, d; double *yl;
        bvgraph_iterator iter;
        tid = omp_get_thread_num();
        rval = bvgraph_parallel_iterator(pits, tid, &iter, &nsteps);
        if (tid==0) {yl = y;} else {yl = &work[(tid-1)*n]; }
        for (j=0; j<n; j++) { yl[j] = 0.0; }
        if (rval == 0) { 
            for (; bvgraph_iterator_valid(&iter) && nsteps; 
                 bvgraph_iterator_next(&iter), nsteps--)
            {
                double xval = x[iter.curr];
                bvgraph_iterator_outedges(&iter, &links, &d);
                for (i = 0; i < d; i++) {
                    yl[links[i]] += xval;
                }
            }
            bvgraph_iterator_free(&iter);
        } else {
            if (BVGRAPH_VERBOSE) { 
                fprintf(stderr,"bvgraph_omp_transmult failed on thread %3i\n",
                    tid);
            }
        }
    }
    /* aggregate all the vectors together */
#pragma omp parallel for shared(work, y) private(k)
    for (j=0; j<n; j++) {
        double yj=0.0;
        for (k=1; k<pits->niters; k++) {
            yj += work[(k-1)*n];
        }
        y[j]+=yj;
    }
    return (rval);
#else
    /* TODO Fix this to use the parallel iterator */
    return bvgraph_transmult(pits->g, x, y);
#endif /* _OPENMP */
}

/**
 * Extract the entries along the diagonal of the matrix. 
 *
 * @param pits the parallel iterator structure which determines 
 * the number of threads
 * @param x the vector of diagonal elements (size g.n)
 * @return 0 if successful
 */
int bvgraph_omp_diag(bvgraph_parallel_iterators *pits, double *x)
{
    int rval=0;
#ifdef _OPENMP    
#pragma omp parallel shared(x,pits) reduction(|:rval) num_threads(pits->niters)
    {
        int *links, tid, nsteps; unsigned int i, d; 
        bvgraph_iterator iter;
        tid = omp_get_thread_num();
        rval = bvgraph_parallel_iterator(pits, tid, &iter, &nsteps);
        x+=iter.curr;
        if (rval == 0) { 
            for (; bvgraph_iterator_valid(&iter) && nsteps; 
                 bvgraph_iterator_next(&iter), nsteps--)
            {
                double v = 0;
                bvgraph_iterator_outedges(&iter, &links, &d);
                for (i = 0; i < d; i++) {
                    if (iter.curr == links[i]) {
                        v = 1.0;
                    }
                }
                *(x++) = v;
            }
            bvgraph_iterator_free(&iter);
        } else {
            if (BVGRAPH_VERBOSE) { 
                fprintf(stderr,"bvgraph_omp_mult failed on thread %3i\n", tid);
            }
        }
    }
    return (rval);
#else
    /* TODO Fix this to use the parallel iterator */
    return bvgraph_diag(pits->g, x);
#endif /* _OPENMP */
}

/**
 * Compute the sum along rows of the matrix, i.e. x = A*ones(g.n,1), 
 * but efficiently.
 *
 * @param pits the parallel iterator structure which determines 
 * the number of threads
 * @param x the vector of row sums
 * @return 0 if successful 
 */
int bvgraph_omp_sum_row(bvgraph_parallel_iterators *pits, double *x)
{
    int rval=0;
#ifdef _OPENMP    
#pragma omp parallel shared(x,pits) reduction(|:rval) num_threads(pits->niters)
    {
        int *links, tid, nsteps; unsigned int d; 
        bvgraph_iterator iter;
        tid = omp_get_thread_num();
        rval = bvgraph_parallel_iterator(pits, tid, &iter, &nsteps);
        x+=iter.curr;
        if (rval == 0) { 
            for (; bvgraph_iterator_valid(&iter) && nsteps; 
                 bvgraph_iterator_next(&iter), nsteps--)
            {
                bvgraph_iterator_outedges(&iter, &links, &d);
                *(x++) = (double)d;
            }
            bvgraph_iterator_free(&iter);
        } else {
            if (BVGRAPH_VERBOSE) { 
                fprintf(stderr,"bvgraph_omp_mult failed on thread %3i\n", tid);
            }
        }
    }
    return (rval);
#else
    /* TODO Fix this to use the parallel iterator */
    return bvgraph_sum_row(pits->g, x);
#endif /* _OPENMP */
}

/**
 * Compute the sum along columns of the matrix, i.e. x = ones(g.n,1)'*A, 
 * but efficiently.
 *
 * @param pits the parallel iterator structure which determines 
 * the number of threads
 * @param x the vector of column sums
 * @return 0 if successful
 */
int bvgraph_omp_sum_col(bvgraph_parallel_iterators *pits, double *y)
{
    int rval=0, j, n=pits->g->n;
#ifdef _OPENMP
#pragma omp parallel for
    for (j=0; j<n; j++) { y[j] = 0.0; }
    
#pragma omp parallel shared(y,pits) reduction(|:rval) num_threads(pits->niters)
    {
        int *links, tid, nsteps; unsigned int i, d; 
        bvgraph_iterator iter;
        tid = omp_get_thread_num();
        rval = bvgraph_parallel_iterator(pits, tid, &iter, &nsteps);
        if (rval == 0) { 
            for (; bvgraph_iterator_valid(&iter) && nsteps; 
                 bvgraph_iterator_next(&iter), nsteps--)
            {
                bvgraph_iterator_outedges(&iter, &links, &d);
                for (i = 0; i < d; i++) {
#pragma omp atomic                    
                    y[links[i]] += 1;
                }
            }
            bvgraph_iterator_free(&iter);
        } else {
            if (BVGRAPH_VERBOSE) { 
                fprintf(stderr,"bvgraph_omp_transmult failed on thread %3i\n",
                    tid);
            }
        }
    }
    return (rval);
#else
    /* TODO Fix this to use the parallel iterator */
    return bvgraph_sum_col(pits->g, y);
#endif /* _OPENMP */
}

/**
 * Computes a substochastic matrix vector product
 * y = (D^+ A) x 
 * efficiently without storing a vector of out-degrees.
 *
 * @param pits the parallel iterator structure which determines 
 * the number of threads
 * @param x the vector x
 * @param y the output vector y
 * @return 0 if successful
 */
int bvgraph_omp_substochastic_mult(
        bvgraph_parallel_iterators *pits, double *x, double *y)
{
    int rval=0;
#ifdef _OPENMP    
#pragma omp parallel shared(x,y,pits) \
    reduction(|:rval) num_threads(pits->niters)
    {
        int *links, tid, nsteps; unsigned int i, d; 
        bvgraph_iterator iter;
        tid = omp_get_thread_num();
        rval = bvgraph_parallel_iterator(pits, tid, &iter, &nsteps);
        y+=iter.curr;
        if (rval == 0) { 
            for (; bvgraph_iterator_valid(&iter) && nsteps; 
                 bvgraph_iterator_next(&iter), nsteps--)
            {
                double v = 0;
                bvgraph_iterator_outedges(&iter, &links, &d);
                for (i = 0; i < d; i++) {
                    v += x[links[i]]/(double)d;
                }
                *(y++) = v;
            }
            bvgraph_iterator_free(&iter);
        } else {
            if (BVGRAPH_VERBOSE) { 
                fprintf(stderr,"bvgraph_omp_mult failed on thread %3i\n",tid);
            }
        }
    }
    return (rval);
#else
    /* TODO Fix this to use the parallel iterator */
    return bvgraph_substochastic_mult(pits->g, x, y);
#endif /* _OPENMP */
}

/**
 * Computes a substochastic tranpose matrix vector product with atomic writes
 * y = (D^+ A)^T x 
 * efficiently without storing a vector of out-degrees.
 *
 * @param pits the parallel iterator structure which determines 
 * the number of threads
 * @param x the vector x
 * @param y the output vector y
 * @return 0 if successful
 */
int bvgraph_omp_substochastic_transmult(
        bvgraph_parallel_iterators *pits, double *x, double *y)
{
    int rval=0, j, n=pits->g->n;
#ifdef _OPENMP

#pragma omp parallel for
    for (j=0; j<n; j++) { y[j] = 0.0; }
    
#pragma omp parallel shared(x,y,pits) \
    reduction(|:rval) num_threads(pits->niters)
    {
        int *links, tid, nsteps; unsigned int i, d; 
        bvgraph_iterator iter;
        tid = omp_get_thread_num();
        rval = bvgraph_parallel_iterator(pits, tid, &iter, &nsteps);
        if (rval == 0) { 
            for (; bvgraph_iterator_valid(&iter) && nsteps; 
                 bvgraph_iterator_next(&iter), nsteps--)
            {
                double xval;
                bvgraph_iterator_outedges(&iter, &links, &d);
                xval = x[iter.curr]/(double)d;
                for (i = 0; i < d; i++) {
#pragma omp atomic                   
                    y[links[i]] += xval;
                }
            }
            bvgraph_iterator_free(&iter);
        } else {
            if (BVGRAPH_VERBOSE) { 
                fprintf(stderr,"bvgraph_omp_transmult failed on thread %3i\n",
                    tid);
            }
        }
    }
    return (rval);
#else
    /* TODO Fix this to use the parallel iterator */
    return bvgraph_substochastic_transmult(pits->g, x, y);
#endif /* _OPENMP */
}

/**
 * Computes a substochastic tranpose matrix vector product with extra memory
 * y = (D^+ A)^T x 
 * without storing a vector of out-degrees.
 * 
 * Sometimes, this operation is faster than the atomic write version.  
 * However, it requires a large amount of extra memory. 
 * 
 * @param pits the parallel iterator structure which determines 
 * the number of threads
 * @param x the vector x
 * @param y the output vector y
 * @param work must be an array of (pits->niters-1)*length(x) 
 * @return 0 if successful
 */
int bvgraph_omp_substochastic_transmult_extra(
                            bvgraph_parallel_iterators *pits, 
                            double *x, double *y, double *work)
{ 
    int rval=0, j, k, n=pits->g->n;
#ifdef _OPENMP    
#pragma omp parallel shared(x,y,work,pits) private(j) \
    reduction(|:rval) num_threads(pits->niters)
    {
        int *links, tid, nsteps; unsigned int i, d;  double *yl;
        bvgraph_iterator iter;
        tid = omp_get_thread_num();
        rval = bvgraph_parallel_iterator(pits, tid, &iter, &nsteps);
        if (tid==0) {yl = y;} else {yl = &work[(tid-1)*n]; }
        for (j=0; j<n; j++) { yl[j] = 0.0; }
        if (rval == 0) { 
            for (; bvgraph_iterator_valid(&iter) && nsteps; 
                 bvgraph_iterator_next(&iter), nsteps--)
            {
                double xval = x[iter.curr];
                bvgraph_iterator_outedges(&iter, &links, &d);
                if (d>0) { xval = xval/(double)d;}
                for (i = 0; i < d; i++) {
                    yl[links[i]] += xval;
                }
            }
            bvgraph_iterator_free(&iter);
        } else {
            if (BVGRAPH_VERBOSE) { 
                fprintf(stderr,"bvgraph_omp_transmult failed on thread %3i\n",
                    tid);
            }
        }
    }
    /* aggregate all the vectors together */
#pragma omp parallel for shared(work,y) private(k) if (pits->niters>1)
    for (j=0; j<n; j++) {
        double yj=0.0;
        for (k=1; k<pits->niters; k++) {
            yj += work[j+(k-1)*n];
        }
        y[j]+=yj;
    }
    return (rval);
#else
    /* TODO Fix this to use the parallel iterator */
    return bvgraph_substochastic_transmult(pits->g, x, y);
#endif /* _OPENMP */
}
