/*
 * =============================================================
 * sor_iter_mex.c  Compute one iteration of the SOR method.
 *
 * David Gleich
 * Stanford University
 * 28 January 2006
 * =============================================================
 */

/*
 * 19 February 2007
 * Updated to use Matlab 2006b sparse matrix interface
 */

#include "mex.h"

#if MX_API_VER < 0x07030000
typedef int mwIndex;
typedef int mwSize;
#endif // MX_API_VER

/*
 * The mex function just computes one matrix-vector product.
 */
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    int i, j, k;
    int n, mrows, ncols;
    
    /* sparse matrix */
    int A_nz;
    mwIndex *A_row, *A_col;
    double *A_val;
    
    double w;
    
    double *x, *b;
    
    if (nrhs != 4) 
    {
        mexErrMsgTxt("Four inputs required.");
    }
    else if (nlhs > 1) 
    {
        mexErrMsgTxt("Too many output arguments");
    }
    
    mrows = mxGetM(prhs[0]);
    ncols = mxGetN(prhs[0]);
    if (mrows != ncols ||
        !mxIsSparse(prhs[0]) ||
        !mxIsDouble(prhs[0]) || 
        mxIsComplex(prhs[0])) 
    {
        mexErrMsgTxt("Input must be a noncomplex square sparse matrix.");
    }
    
    /* okay, the first input passes */
    n = mrows;
    
    /* The second input must be a vector. */
    if (mxGetM(prhs[1])*mxGetN(prhs[1]) != n ||
        mxIsSparse(prhs[1]) || !mxIsDouble(prhs[1]))
    {
        mexErrMsgTxt("Invalid vector.");
    }
    
    /* The third input must be a vector. */
    if (mxGetM(prhs[2])*mxGetN(prhs[2]) != n ||
        mxIsSparse(prhs[2]) || !mxIsDouble(prhs[2]))
    {
        mexErrMsgTxt("Invalid vector.");
    }
    
    if (mxGetNumberOfElements(prhs[3]) != 1 || !mxIsDouble(prhs[3]))
    {
        mexErrMsgTxt("Invalid scalar.");
    }
    
    /* Get the sparse matrix */
    A_nz = mxGetNzmax(prhs[0]);
    A_val = mxGetPr(prhs[0]);
    A_row = mxGetIr(prhs[0]);
    A_col = mxGetJc(prhs[0]);
    
    /* Get the vector x */
    x = mxGetPr(prhs[1]);
    
    /* Get the vector b */
    b = mxGetPr(prhs[2]);
    
    /* Get the scalar w */
    w = mxGetScalar(prhs[3]);
    
    /* if they request x old, then we need to copy x to xold */
    if (nlhs > 0)
    {
        plhs[0] = mxDuplicateArray(prhs[1]);
    }
            
    /* Update x in place, this means we have to iterate over columns
     * of the matrix A. */
    
    for (i = 0; i < n; i++)
    {
        double ai = 0.0;
        double xnew = (1 - w)*x[i];
        double rest = b[i];
        
        for (j = A_col[i]; j < A_col[i+1]; ++j)
        {
            /* add to aself only if the row = i (the column) */
            ai += A_val[j]*(A_row[j] == i);
            
            /* add to rest only if row != i */
            rest -= A_val[j]*x[A_row[j]]*(A_row[j] != i);
        }
        
        x[i] = w*rest/ai + xnew;
    }
}

