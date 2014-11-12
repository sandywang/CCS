/** Gauss Seidel for PageRank implemented as a mex function
 * @file gspr_mex.c
 * @author David Gleich
 */

#include <mex.h>
#include <matrix.h>
#include <math.h>
#include <string.h>

#define SSUM(x,y) { y[0]=x; y[1]=0.0; }
#define CSUM(x,y,t,z) { t=y[0]; z=(x)+y[1]; y[0]=t+z; y[1]=(t-y[0])+z; }
#define FCSUM(y) (y[0]+y[1])

/** History
 *  2008-05-14: Initial coding based on previous Gauss-Seidel iteration
 *  2008-05-19: Finished initial coding
 *              Added compensated summation of terms
 */

double compute_dsum(mwSize n, double *x, double *id, char *lid);

void page_rank_gauss_seidel_sweep(
        mwSize n,
        double *x,
        unsigned int *cp, unsigned int *ri, double *ai, double *id, char *lid,
        double a, double g, double *pdsum, double *pdiff,
        int vscalar, double *v, int uscalar, double *u);

/** Implement a Gauss-Seidel sweep.
 */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    const mxArray *argn, *argcp, *argri, *argai, *argid, *argv, *argu, *argx, 
        *argdsum, *argalpha, *arggamma;
    mxArray *outx, *outdiff, *outdsum, *outy;
    
    mwSize n, nz;
    unsigned int *cp, *ri;
    double *ai, a, g, tol, *v, *id, dsum, diff, *x, *u;
    char *lid;
    int i, vscalar=0, uscalar=0;
    
    if (nrhs < 11) {
        mexErrMsgIdAndTxt("MATLAB:nargchk:notEnoughInputs",
            "Not enough input arguments.");
    } else if (nrhs > 11) {
        mexErrMsgIdAndTxt("MATLAB:nargchk:tooManyInputs",
            "Too many input arguments.");
    }
    
    argx = prhs[0];
    argn = prhs[1];
    argcp = prhs[2];
    argri = prhs[3];
    argai = prhs[4];
    argid = prhs[5];
    argalpha = prhs[6];
    arggamma = prhs[7];
    argdsum = prhs[8];
    argv = prhs[9];
    argu = prhs[10];
    
    /* validate arguments */
    if (!mxIsScalar(argn)) {
        mexErrMsgIdAndTxt("gssweeppr_mex:scalarRequired",
            "The input n argument must be a scalar.");
    }
    n = (mwSize)mxGetScalar(argn);
    
    if (!mxIsClass(argcp,"uint32")) {
        mexErrMsgIdAndTxt("gssweeppr_mex:uint32Required",
            "The input cp must be a uint32 type.");
    }
    if (!mxIsClass(argri,"uint32")) {
        mexErrMsgIdAndTxt("gssweeppr_mex:uint32Required",
            "The input ri must be a uint32 type.");
    }
    if (mxGetNumberOfElements(argcp)!=n+1) {
        mexErrMsgIdAndTxt("gssweeppr_mex:invalidSize",
            "The input cp must be size n+1, not %i.", 
            mxGetNumberOfElements(argcp));
    }
    if (mxGetNumberOfElements(argid)!=n) {
        mexErrMsgIdAndTxt("gssweeppr_mex:invalidSize",
            "The input id must be size %i, not %i.", 
            n, mxGetNumberOfElements(argid));
    }
    
    cp = (unsigned int *)mxGetData(argcp);
    nz = cp[n]-1;
    
    if (mxGetNumberOfElements(argri)<nz) {
        mexErrMsgIdAndTxt("gssweeppr_mex:invalidSize",
            "The input ri must have more than %i elements, not %i.", 
            nz, mxGetNumberOfElements(argri));
    }
    if (mxGetNumberOfElements(argai) != 0 && mxGetNumberOfElements(argai)<nz) {
        mexErrMsgIdAndTxt("gssweeppr_mex:invalidSize",
            "The input ai must have either 0 or more than %i elements, not %i.",
            nz, mxGetNumberOfElements(argai));
    }

    if (!mxIsScalar(argalpha)) {
        mexErrMsgIdAndTxt("gssweeppr_mex:scalarRequired",
            "The input a argument must be a scalar.");
    }
    if (!mxIsScalar(arggamma)) {
        mexErrMsgIdAndTxt("gssweeppr_mex:scalarRequired",
            "The input g argument must be a scalar.");
    }
    if (!mxIsScalar(argv) && (n!=mxGetNumberOfElements(argv))) {
        mexErrMsgIdAndTxt("gssweeppr_mex:scalarOrVectorRequired",
            "The input v argument must be a scalar or "
            "a vector of length n, not %i", mxGetNumberOfElements(argv));
    }

    if (!mxIsScalar(argu) && (n!=mxGetNumberOfElements(argu))) {
        mexErrMsgIdAndTxt("gssweeppr_mex:scalarOrVectorRequired",
            "The input u argument must be a scalar or "
            "a vector of length n, not %i", mxGetNumberOfElements(argu));
    }    
    
    x = mxGetPr(argx);
    ri = mxGetData(argri);
    if (mxIsEmpty(argai)) { ai=NULL; } 
    else { ai = mxGetPr(argai); }
    if (mxIsClass(argid,"logical")) {
        lid = mxGetData(argid); id = NULL;
    } else {
        id = mxGetPr(argid); lid = NULL;
    }
    
    a = mxGetScalar(argalpha);
    g = mxGetScalar(arggamma);
    if (mxIsEmpty(argdsum)) { 
        dsum = compute_dsum(n, x, id, lid);
    } else {
        dsum = mxGetScalar(argdsum);
    }
    
    vscalar = (int)mxIsScalar(argv);
    v = mxGetPr(argv);
    uscalar = (int)mxIsScalar(argu);
    u = mxGetPr(argu);
   
    outx = plhs[0] = mxCreateDoubleMatrix(n,1,mxREAL);
    outdiff = plhs[1] = mxCreateDoubleMatrix(1,1,mxREAL);    
    outdsum = plhs[2] = mxCreateDoubleMatrix(1,1,mxREAL);    
    
    if (nlhs>3) {
        outy = plhs[3] = mxCreateDoubleMatrix(n,1,mxREAL);
        memcpy(mxGetPr(outy),x,sizeof(double)*n);
    } else {
        outy = NULL;
    }
    
    memcpy(mxGetPr(outx),x,sizeof(double)*n);
   
    /* init y */
    
    page_rank_gauss_seidel_sweep(n, mxGetPr(outx),
                    cp, ri, ai, id, lid, a, g, &dsum, &diff, 
                    vscalar, v, uscalar, u);
    
    *mxGetPr(outdiff) = diff;
    *mxGetPr(outdsum) = dsum;
}
    
double compute_dsum(mwSize n, double *x, double *id, char *lid) 
{
    unsigned int i;
    double dsums[2], t, y;
    
    SSUM(0.0,dsums);
    for (i=0; i<n; i++) { 
        if ((lid && lid[i]==0) || (id && id[i]==0)) {
            CSUM(x[i],dsums,t,y);
        }
    }
    
    return FCSUM(dsums);
}

void page_rank_gauss_seidel_sweep(
        mwSize n,
        double *x,
        unsigned int *cp, unsigned int *ri, double *ai, double *id, char *lid,
        double a, double g, double *pdsum, double *pdiff,
        int vscalar, double *v, int uscalar, double *u)
{
    unsigned int i, cpi, j;
    double dsum=*pdsum, dn = (double)n, pji, pii, xn, vi;
    double diffs[2], dsums[2], dsumns[2], t, y; 
    
    SSUM(dsum,dsums);
    SSUM(0.0,diffs);
    SSUM(0.0,dsumns);
    for (i=0; i<n; i++) {
        xn=0.0; pii=0.0;
        for (cpi=cp[i]-1; cpi<cp[i+1]-1; cpi++) {
            j=ri[cpi]-1;
            if (ai==NULL) { pji=id[j]; } else { pji=ai[cpi]; }
            if (i==j) { pii += pji; continue; }
            xn += x[j]*pji;
        }
        if (uscalar) { xn += (FCSUM(dsumns) + FCSUM(dsums))*(u[0]); }
        else { xn += (FCSUM(dsumns) + FCSUM(dsums))*(u[i]); }
        if ((lid && lid[i]==0) || (id && id[i]==0)) {
            xn -= x[i]/dn;
            pii += 1.0/dn;
        }
        if (vscalar) { vi=v[0]; } else { vi=v[i]; }
        xn = (a*xn + g*vi)/(1.0-a*pii);
        if ((lid && lid[i]==0) || (id && id[i]==0)) { 
            CSUM(-x[i],dsums,t,y); CSUM(xn,dsumns,t,y); 
        }
        CSUM(fabs(x[i]-xn),diffs,t,y);
        x[i] = xn;

    }

    *pdsum = FCSUM(dsumns);
    if (pdiff) { *pdiff = FCSUM(diffs); }
    
}

