/*
 * David Gleich
 * Copyright, Stanford University, 2008
 * 10 May 2008
 */

/**
 * @file bvgraph_pagerank_trans_mult.hpp
 * Implement multiplication routines for a substochastic bvgraph structure
 * where the matrix is by inedges of the underlying webgraph (the transpose
 * of my default)
 */

/** History
 *  2008-05-11: Initial coding
 */
 
#include "csum.h" 
#include <math.h>

template <
struct csm {
    size_t n;
    
    double *id;
};

/** Size function for a bvgraph pointer.
 * 
 * @param g the bvgraph
 * @return the number of vertices
 */
size_t size(transbvgraph *tg) {
    return (size_t)tg->g->n;
}

/** Compute d'*x for the dangling indicator vector.
 *  
 * This function assumes that id==0 ONLY for dangling nodes and
 * computes the sum using compensated summation.
 */
 
double sum_dtx(transbvgraph *tg, double *x) 
{
    double *id = tg->id, dtxs[2] = {0}, t, y;
    size_t n = size(tg);
    while (n-- > 0) { if (*id==0) { CSUM(*x,dtxs,t,y); } x++; y++; id++; }
    return FCSUM(dtxs);
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
int mult(transbvgraph *tg, double *x, double *y, double alpha, double *sum_aPtx)
{
    using namespace std;
    bvgraph* g = tg->g; double *id = tg->id; bvgraph_iterator git;
    int rval = bvgraph_nonzero_iterator(g, &git);
    if (rval) {
        cerr << "error: cannot get bvgraph iterator " << endl;
        cerr << "bvgraph error: " << bvgraph_error_string(rval) << endl;
        cerr << "halting iteration..." << endl;
        return (-1);
    }
    int *links; unsigned int i, d;
    double sumy[2]={0},t,z;
    for (; bvgraph_iterator_valid(&git); bvgraph_iterator_next(&git)) {
        double yi=0.0;
        bvgraph_iterator_outedges(&git, &links, &d);
        for (i = 0; i < d; i++) {
            yi += x[links[i]]*id[links[i]];    
        }
        yi *= alpha;
        CSUM(yi,sumy,t,z);
        y[git.curr] = yi;
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
 * @param dtx the quantity d'*x
 * @return non-zero on error
 */
int dangling_mult(transbvgraph *tg, 
        double *x, double *y, double *v, double alpha,
        double *dtx)
{
    using namespace std;
    bvgraph* g = tg->g; double *id = tg->id; bvgraph_iterator git;
    int rval = bvgraph_nonzero_iterator(g, &git);
    if (rval) {
        cerr << "error: cannot get bvgraph iterator" << endl;
        cerr << "bvgraph error: " << bvgraph_error_string(rval) << endl;
        cerr << "halting iteration..." << endl;
        return (-1);
    }

    int *links; unsigned int i, d;
    for (; bvgraph_iterator_valid(&git); bvgraph_iterator_next(&git)) {
        double yi=0.0;
        bvgraph_iterator_outedges(&git, &links, &d);
        for (i = 0; i < d; i++) {
            yi += x[links[i]]*id[links[i]];    
        }
        y[git.curr] = alpha*yi;
    }
    bvgraph_iterator_free(&git);
    double alpha_dtx = sum_dtx(tg,x);
    if (dtx) { *dtx = alpha_dtx; }
    alpha_dtx *= alpha;
    if (v==NULL) {
        shift(y, alpha_dtx/(double)g->n, g->n);
    } else {
        xpby(y,v,alpha_dtx,g->n);
    }
    return (0);
}

/** Compute a gauss-seidel sweep with a sub-stochastic bvgraph structure.
 *
 * Based on Sebastiano Vigna's pseudo-code for a multiplication of
 * this type.
 *
 * (I-alpha*(P' + ud') x = gamma*f
 */
int gauss_seidel_sweep(transbvgraph *tg, 
        double *x, double *y, double *f, 
        double alpha, double gamma, double dsum, bool fscalar,
        double *pnormx, double *pnormdiff, double *pdsumn)
{
    using namespace std;
    bvgraph* g = tg->g; 
    size_t n = size(tg);
    double *id = tg->id, dsumns[2]={0}, dsums[2]={0}, nxs[2]={0}, nds[2]={0}, t, z;
    const double dn=(double)n, idn=1.0/(double)n;
    bvgraph_iterator git;
    int rval = bvgraph_nonzero_iterator(g, &git);
    if (rval) {
        cerr << "error: cannot get bvgraph iterator" << endl;
        cerr << "bvgraph error: " << bvgraph_error_string(rval) << endl;
        cerr << "halting iteration..." << endl;
        return (-1);
    }

    if (y != NULL) { copy(x,y,n); }
    CSUM(dsum,dsums,t,z); /* initialize the old sum */

    for (; bvgraph_iterator_valid(&git); bvgraph_iterator_next(&git)) {
        unsigned int i, d; int *links;
        double xn=0.0, pii=0.0, vi=0.0;
        bvgraph_iterator_outedges(&git, &links, &d);
        for (i = 0; i < d; i++) {
            if (links[i]==git.curr) { 
                pii+=id[links[i]]; 
                continue;
            }
            xn += x[links[i]]*id[links[i]];
        }
        xn += (FCSUM(dsumns) + FCSUM(dsums))/dn; /* should be (s)*u[curr] */
        if (id[git.curr]==0) {
            xn -= x[git.curr]/dn;
            pii += idn;        /* should be u[curr] */
        }
        if (f==NULL) {
            vi = idn;
        } else if (fscalar) {
            vi = f[0];
        } else {
            vi = f[git.curr];
        }
        xn = (alpha*xn + gamma*vi)/(1.0-alpha*pii);
        if (id[git.curr]==0) { 
            CSUM(-x[git.curr],dsums,t,z);
            CSUM(xn,dsumns,t,z); 
        }
        CSUM(fabs(xn),nxs,t,z);
        CSUM(fabs(xn-x[git.curr]),nds,t,z);
        x[git.curr] = xn;
    }
    bvgraph_iterator_free(&git);

    if (pnormx) { *pnormx = FCSUM(nxs); }
    if (pnormdiff) { *pnormdiff = FCSUM(nds); }
    if (pdsumn) { *pdsumn = FCSUM(dsumns); }
    
    return (0);
}
