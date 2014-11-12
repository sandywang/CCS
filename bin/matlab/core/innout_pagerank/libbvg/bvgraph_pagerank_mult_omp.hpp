/*
 * David Gleich
 * Copyright, Stanford University, 2008
 * 10 May 2008
 */

/**
 * @file bvgraph_pagerank_mult_omp.hpp
 * Implement multiplication routines for a substochastic bvgraph structure
 * where the matrix is by outedges of the underlying webgraph (my default)
 * using parallelize through OpenMP.  The matrix presents itself as a 
 * set of parallel iterators.
 */

/** History
 *  2008-05-10: Initial coding based on previous code.
 *  2008-05-14: Added more outputs to dangling_mult for 
 *              the dtx quantities.
 */

#include <omp.h>

/** Size function for a bvgraph pointer.
 * 
 * @param pits the set of parallel iterators over a graph
 * @return the number of vertices
 */
size_t size(bvgraph_parallel_iterators *pits) {
    return (size_t)pits->g->n;
}

/** Compute a matrix vector product with a substochastic bvgraph structure
 * 
 * y = alpha*P'*x where P = D^{-1} A for the adjacency matrix A given
 * by a bvgraph structure.
 * 
 * @param g the bvgraph
 * @param x the right hand vector,
 * @param y the output vector y = y + alpha*P'*x
 * @param alpha the value of alpha to adjust the mutliplication by
 * @param sum_aPtx the value e^T (alpha*P'*x)
 * @return non-zero on error
 */
int mult(bvgraph_parallel_iterators *pits, 
            double *x, double *y, const double alpha, double *sum_aPtx)
{
    int rval=0, j, n=pits->g->n;
    double sum0=0,sum1=0;
    set(y, 0.0, n); 

#pragma omp parallel shared(x,y,pits,sum0,sum1) \
    reduction(|:rval) num_threads(pits->niters)
    {
        int *links, tid, nsteps; unsigned int i, d; double sumy0, sumy1, t, z;
        bvgraph_iterator iter;
        tid = omp_get_thread_num();
        rval = bvgraph_parallel_iterator(pits, tid, &iter, &nsteps);
        sumy0=0.0; sumy1=0.0;
        if (rval == 0) { 
            for (; bvgraph_iterator_valid(&iter) && nsteps; 
                 bvgraph_iterator_next(&iter), nsteps--)
            {
                double xval=x[iter.curr];
                bvgraph_iterator_outedges(&iter, &links, &d);
                if (d>0) { xval = alpha*xval/(double)d; }
                for (i = 0; i < d; i++) {
                    #pragma omp atomic                   
                    y[links[i]] += xval;
                    CSUM2(xval,sumy0,sumy1,t,z);
                }
            }
            bvgraph_iterator_free(&iter);

            #pragma omp critical
            { CSUM2(FCSUM2(sumy0,sumy1),sum0,sum1,t,z) }
        } else {
            if (BVGRAPH_VERBOSE) { 
                fprintf(stderr,"bvgraph_omp_transmult failed on thread %3i\n",
                    tid);
            }
        }
    }
    if (sum_aPtx) { *sum_aPtx = FCSUM2(sum0,sum1); }
    return (rval);
} 

/** Compute a matrix vector product with a sub-stochastic bvgraph structure
 * 
 * y = y + alpha*(P+dv')'*x where P = D^{-1} A for the adjacency matrix A 
 * given by a bvgraph structure and d is the dangling node indicator, 
 * and if v is NULL, v = 1/n * e, and e is the vector of all ones.  
 * When v is NULL, this corresponds to a matrix vector product with the 
 * stochastic matrix in strongly  preferential PageRank with 
 * uniform teleportation.
 * 
 * @param g the bvgraph
 * @param x the right hand vector,
 * @param y the output vector y = y + alpha*(P+dv)'*x
 * @param v the teleportation distribution vector or preference vector v
 * @param alpha the value to scale the multiplication by
 * @param dtx [output] the quantity d'*x
 * @param pkdtx [input] a KNOWN dtx (that is, don't compute this quantity) 
 * @return non-zero on error
 */
int dangling_mult(bvgraph_parallel_iterators *pits, 
            double *x, double *y, double *v, const double alpha,
            double *dtx, double *pkdtx)
{
    int rval=0, j, n=pits->g->n;
    double sum0=0,sum1=0;
    set(y, 0.0, n); 

#pragma omp parallel shared(x,y,pits,sum0,sum1) \
    reduction(|:rval) num_threads(pits->niters)
    {
        int *links, tid, nsteps; unsigned int i, d; double sumy0, sumy1, t, z;
        bvgraph_iterator iter;
        tid = omp_get_thread_num();
        rval = bvgraph_parallel_iterator(pits, tid, &iter, &nsteps);
        sumy0=0.0; sumy1=0.0;
        if (rval == 0) { 
            for (; bvgraph_iterator_valid(&iter) && nsteps; 
                 bvgraph_iterator_next(&iter), nsteps--)
            {
                double xval=x[iter.curr];
                bvgraph_iterator_outedges(&iter, &links, &d);
                if (d>0) { xval = alpha*xval/(double)d; } 
                else { CSUM2(xval,sumy0,sumy1,t,z); }
                for (i = 0; i < d; i++) {
                    #pragma omp atomic                   
                    y[links[i]] += xval;
                }
            }
            bvgraph_iterator_free(&iter);

            #pragma omp critical
            { CSUM2(FCSUM2(sumy0,sumy1),sum0,sum1,t,z) }
        } else {
            if (BVGRAPH_VERBOSE) { 
                fprintf(stderr,"bvgraph_omp_transmult failed on thread %3i\n",
                    tid);
            }
        }
    }

    double alpha_dtx = FCSUM2(sum0,sum1);
    if (dtx) { *dtx = alpha_dtx; }
    if (pkdtx) { alpha_dtx =*pkdtx; }
    alpha_dtx *= alpha;
    if (v==NULL) {
        shift(y, alpha_dtx/(double)n, n);
    } else {
        xpby(y, v, alpha_dtx, n);
    }
    return (0);
}
