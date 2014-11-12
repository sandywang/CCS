/*
 * David Gleich
 * Copyright, Stanford University, 2008
 * 10 May 2008
 */

/**
 * @file bvgraph_pagerank_trans_mult_omp.hpp
 * Implement multiplication routines for a substochastic bvgraph structure
 * where the matrix is by inedges of the underlying webgraph (the transpose
 * of my default)
 */

/** History
 *  2008-05-11: Initial coding
 *  2008-05-14: Added more outputs to dangling_mult for 
 *              the dtx quantities.
 */
 
#include "csum.h" 
#include <omp.h>

struct omptransbvgraph {
    bvgraph_parallel_iterators *pits;
    double *id;
};

/** Size function for a omptransbvgraph pointer.
 * 
 * @param g the bvgraph
 * @return the number of vertices
 */
size_t size(omptransbvgraph *tg) {
    return (size_t)tg->pits->g->n;
}

/** Compute d'*x for the dangling indicator vector.
 *  
 * This function assumes that id==0 ONLY for dangling nodes and
 * computes the sum using compensated summation.
 */
 
double sum_dtx(omptransbvgraph *tg, double *x) 
{
    ptrdiff_t i, sn=(ptrdiff_t)size(tg);
    double s0,s1,rv0=0,rv1=0,t,z,*id=tg->id;
#pragma omp parallel shared(sn,rv0,rv1,x,id) private(s0,s1,t,z)
    {
        s0=0; s1=0;   
#pragma omp for private(i)
        for (i=0; i<sn; i++) { 
            if (id[i]==0) { CSUM2(x[i],s0,s1,t,z); }
        }
#pragma omp critical
        { CSUM2(FCSUM2(s0,s1),rv0,rv1,t,z); }
    }
    return (FCSUM2(rv0,rv1));
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
int mult(omptransbvgraph *tg, double *x, double *y, const double alpha, double *sum_aPtx)
{
    bvgraph_parallel_iterators *pits = tg->pits;
    int rval=0, j, n=pits->g->n;
    double sum0=0, sum1=0, *id=tg->id;
    
#pragma omp parallel shared(x,y,pits,sum0,sum1,id) \
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
                double yi=0.0;
                bvgraph_iterator_outedges(&iter, &links, &d);
                for (i = 0; i < d; i++) {              
                    yi += x[links[i]]*id[links[i]];
                }
                yi *= alpha;
                CSUM2(yi,sumy0,sumy1,t,z);
                y[iter.curr]=yi;
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
 * @param tg the bvgraph
 * @param x the right hand vector,
 * @param y the output vector y = y + alpha*(P+dv)'*x
 * @param v the teleportation distribution vector or preference vector v
 * @param alpha the value to scale the multiplication by
 * @param dtx [output] the quantity d'*x
 * @param pkdtx [input] a KNOWN dtx (that is, don't compute this quantity) 
 * @return non-zero on error
 */
int dangling_mult(omptransbvgraph *tg, 
            double *x, double *y, double *v, double alpha,
            double *dtx, double *pkdtx)
{
    bvgraph_parallel_iterators *pits = tg->pits;
    int rval=0, j, n = tg->pits->g->n;
    double *id=tg->id;
    
#pragma omp parallel shared(x,y,pits,id) \
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
                double yi=0.0;
                bvgraph_iterator_outedges(&iter, &links, &d);
                for (i = 0; i < d; i++) {              
                    yi += x[links[i]]*id[links[i]];
                }
                yi *= alpha;
                y[iter.curr]=yi;
            }
            bvgraph_iterator_free(&iter);
        } else {
            if (BVGRAPH_VERBOSE) { 
                fprintf(stderr,"bvgraph_omp_transmult failed on thread %3i\n",
                    tid);
            }
        }
    }
    double alpha_dtx;
    if (pkdtx) { alpha_dtx = *pkdtx; }
    else { alpha_dtx = sum_dtx(tg,x); }
    if (dtx) { *dtx = alpha_dtx; }
    alpha_dtx *= alpha;
    if (v==NULL) {
        shift(y, alpha_dtx/(double)n, n);
    } else {
        xpby(y, v, alpha_dtx, n);
    }
    return (0);
}
