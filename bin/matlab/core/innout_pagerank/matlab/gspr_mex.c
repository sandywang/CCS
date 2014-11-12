/** Gauss Seidel for PageRank implemented as a mex function
 * @file gspr_mex.c
 * @author David Gleich
 */

#include <mex.h>
#include <math.h>

int page_rank_with_gauss_seidel(
        mwSize n, 
        mwIndex *cp, mwIndex *ri, double *ai,
        double *x, double *y, int *d, 
        double a, int vscalar, double *v, double tol, int verbose,
        int *pmaxit, double *hist);

/** Implement the gauss-seidel iterations.
 *
 */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    const mxArray *argP, *arga, *argv, *argtol, *argmaxit, *argverbose, *argx0;
    mxArray *outx, *outflag, *outhist;
    
    mwSize n;
    mwIndex *cp, *ri;
    double *ai, a, tol, *v;
    int i, vscalar=0, maxit, verbose, *d;
    double *y, *x, *hist, flag;
    mwSize x0size;
    
    if (nrhs < 7) {
        mexErrMsgIdAndTxt("MATLAB:nargchk:notEnoughInputs",
            "Not enough input arguments.");
    } else if (nrhs > 7) {
        mexErrMsgIdAndTxt("MATLAB:nargchk:tooManyInputs",
            "Too many input arguments.");
    }
    
    argP = prhs[0];
    arga = prhs[1];
    argv = prhs[2];
    argtol = prhs[3];
    argmaxit = prhs[4];
    argverbose = prhs[5];
    argx0 = prhs[6];
    
    /* validate arguments */
    if (mxGetM(argP) != mxGetN(argP) ||
        !mxIsSparse(argP) || !(mxIsLogical(argP) || mxIsDouble(prhs[0]))) {
        mexErrMsgIdAndTxt("gspr_mex:sparseMatrixRequired",
            "The input P argument must be a "
            "square sparse logical or double matrix.");
    }
    if (!mxIsScalar(arga)) {
        mexErrMsgIdAndTxt("gspr_mex:scalarRequired",
            "The input a argument must be a scalar.");
    }
    if (!mxIsScalar(argv) && (mxGetM(argP)!=mxGetNumberOfElements(argv))) {
        mexErrMsgIdAndTxt("gspr_mex:scalarOrVectorRequired",
            "The input v argument must be a scalar or "
            "a vector of length size(P,1).");
    }
    if (!mxIsScalar(argtol)) {
        mexErrMsgIdAndTxt("gspr_mex:scalarRequired",
            "The input tol argument must be a scalar.");
    }
    if (!mxIsScalar(argmaxit)) {
        mexErrMsgIdAndTxt("gspr_mex:scalarRequired",
            "The input maxit argument must be a scalar.");
    }
    if (!mxIsScalar(argverbose)) {
        mexErrMsgIdAndTxt("gspr_mex:scalarRequired",
            "The input verbose argument must be a scalar.");
    }
    x0size = mxGetNumberOfElements(argx0);
    if (x0size != 0 && x0size != mxGetM(argP)) {
        mexErrMsgIdAndTxt("gspr_mex:nullOrVectorRequired",
            "The input x0 argument must be empty or "
            "a vector of length size(P,1).");
    }
    
    n = mxGetM(argP);
    cp = mxGetJc(argP);
    ri = mxGetIr(argP);
    if (mxIsDouble(argP)) { ai=mxGetPr(argP); }
    else { ai=NULL; }
    
    a = mxGetScalar(arga);
    tol = mxGetScalar(argtol);
    maxit = (int)mxGetScalar(argmaxit);
    verbose = (int)mxGetScalar(argverbose);
    
    vscalar = (int)mxIsScalar(argv);
    v = mxGetPr(argv);
   
    outx = plhs[0] = mxCreateDoubleMatrix(n,1,mxREAL);
    outflag = plhs[1] = mxCreateDoubleMatrix(1,1,mxREAL);
    outhist = plhs[2] = mxCreateDoubleMatrix(maxit,1,mxREAL);
     
    x = mxGetPr(outx);
    hist = mxGetPr(outhist);
    /* init x */
    if (x0size>0) {
        /* init from x0 */
        double *x0 = mxGetPr(argx0);
        for (i=0; i<n; i++) { x[i] = x0[i]; }
    } else {
        /* init from v */
        if (vscalar) { double vi=v[0]; for (i=0; i<n; i++) x[i] = vi; }
        else { for (i=0; i<n; i++) x[i]=v[i]; }
    }
    /* init d */
    d = mxCalloc(n, sizeof(int));
    if (ai==NULL) { for (i=0; i<cp[n]; i++) { d[ri[i]]+=1; } }
    else { for (i=0; i<cp[n]; i++) { d[ri[i]]=1; } }  
    /* init y */
    y = mxMalloc(n*sizeof(double));
    flag = (double)page_rank_with_gauss_seidel(n, cp, ri, ai, 
                    x, y, d, a, vscalar, v, tol, verbose, &maxit, hist);
    mxFree(d); mxFree(y);
    *mxGetPr(outflag) = flag;
    mxSetM(outhist, maxit);
}

int page_rank_with_gauss_seidel(
        mwSize n, 
        mwIndex *cp, mwIndex *ri, double *ai,
        double *x, double *y, int *d, 
        double a, int vscalar, double *v, double tol, int verbose,
        int *pmaxit, double *hist)
{
    mwIndex i, cpi, j;
    int flag=0, iter=0, maxit=*pmaxit;
    double delta=2, dp=delta, rdiff;
    double pii, pji, u, hi, vi, normx, normy, w, dsum=0, dsumn=0, dn=(double)n;
    for (i=0; i<n; i++) { if (d[i]==0) dsum += x[i]; }
    while (iter<maxit && delta>tol) {
        /* copy x to y for residual */
        for (i=0; i<n; i++) { y[i] = x[i]; }
        dsumn = 0.0;
        for (i=0; i<n; i++) {
            u=0.0; pii=0.0;
            for (cpi=cp[i]; cpi<cp[i+1]; cpi++) {
                j=ri[cpi];
                if (ai==NULL) { pji=1.0/(double)d[j]; } else { pji=ai[cpi]; }
                if (i==j) { pii = pji; continue; }
                u += x[j]*pji;
            }
            u += dsumn/dn + dsum/dn;
            if (d[i]==0) {
                u -= x[i]/dn;
                pii += 1.0/dn;
            }
            if (vscalar) { vi=v[0]; } else { vi=v[i]; }
            u = (a*u + (1.0-a)*vi)/(1.0-a*pii);
            if (d[i]==0) { dsum-=x[i]; dsumn += u; }
            x[i] = u;
        }
        dsum = dsumn;
        /* evaluate the residual */
        rdiff = 0.0; normx = 0.0; normy = 0.0;
        for (i=0; i<n; i++) {
            rdiff += fabs(x[i]-y[i]);
            normx += fabs(x[i]);
            u = 0.0;
            for (cpi=cp[i]; cpi<cp[i+1]; cpi++) {
                j=ri[cpi];
                if (ai==NULL) { pji=1.0/(double)d[j]; } else { pji=ai[cpi]; }
                u += x[j]*pji;
            }
            y[i]=a*u; normy += fabs(y[i]);
        }
        delta=0; w = 1.0-normy;
        for (i=0; i<n; i++) {
            if (vscalar) { vi = v[0]; } else { vi = v[i]; }
            delta += fabs(y[i]+w*vi-x[i]);
        }
        hist[iter++] = delta;
        if (verbose) {
            mexPrintf("gs : m=%7i d=%8e r=%8e c=%8e\n", 
                iter, delta, delta/dp, rdiff); 
            dp=delta;
        }
    }
    if (delta > tol) { flag=1; }
    *pmaxit = iter;
    
    return (flag);
}
