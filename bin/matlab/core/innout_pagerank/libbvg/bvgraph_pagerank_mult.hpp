/*
 * David Gleich
 * Copyright, Stanford University, 2008
 * 10 May 2008
 */

/**
 * @file bvgraph_pagerank_mult.hpp
 * Implement multiplication routines for a substochastic bvgraph structure
 * where the matrix is by outedges of the underlying webgraph (my default)
 */

/** History
 *  2008-05-10: Initial coding based on previous code.
 *  2008-05-14: Added more outputs to dangling_mult for 
 *              the dtx quantities.
 */

/** Size function for a bvgraph pointer.
 * 
 * @param g the bvgraph
 * @return the number of vertices
 */
size_t size(bvgraph *g) {
    return (size_t)g->n;
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
    set(y, 0.0, g->n); 
    int *links; unsigned int i, d;
    double id=0.0; double sumy[2]={0},t,z;
    for (; bvgraph_iterator_valid(&git); bvgraph_iterator_next(&git)) {
        double xval=x[git.curr];
        bvgraph_iterator_outedges(&git, &links, &d);
        if (d > 0) { xval = alpha*xval/(double)d; } 
        for (i = 0; i < d; i++) {
            y[links[i]] += xval;
            CSUM(xval,sumy,t,z);
        }
    }
    if (sum_aPtx) { *sum_aPtx = FCSUM(sumy); }
    bvgraph_iterator_free(&git);
    return (0);
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
int dangling_mult(bvgraph *g, 
        double *x, double *y, double *v, double alpha,
        double *dtx, double *pkdtx)
{
    using namespace std;
    bvgraph_iterator git;
    int rval = bvgraph_nonzero_iterator(g, &git), n = g->n;
    if (rval) {
        cerr << "error: cannot get bvgraph iterator" << endl;
        cerr << "bvgraph error: " << bvgraph_error_string(rval) << endl;
        cerr << "halting iteration..." << endl;
        return (-1);
    }

    int *links; unsigned int i, d;
    double sum_dtxs[2]={0},t,z;
    set(y, 0.0, n); 
    for (; bvgraph_iterator_valid(&git); bvgraph_iterator_next(&git)) {
        double xval = x[git.curr];
        bvgraph_iterator_outedges(&git, &links, &d);
        if (d > 0) { xval = alpha*xval/(double)d; } 
        else { CSUM(xval, sum_dtxs, t, z); }
        for (i = 0; i < d; i++) {
            y[links[i]] += xval;
        }
    }
    bvgraph_iterator_free(&git);
    double alpha_dtx = FCSUM(sum_dtxs);
    if (dtx) { *dtx = alpha_dtx; }
    if (pkdtx) { alpha_dtx =*pkdtx; }
    alpha_dtx *= alpha;
    if (v==NULL) {
        shift(y, alpha_dtx/(double)g->n, g->n);
    } else {
        xpby(y, v, alpha_dtx, n);
    }
    return (0);
}
