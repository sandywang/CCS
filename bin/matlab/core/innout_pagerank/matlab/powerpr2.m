function [x flag reshist]=powerpr(P,a,v,tol,maxit)
% POWERPR Solve a PageRank system using the power method
%
% x=powerpr(P) solve a PageRank system with the row (sub-)stochastic matrix
% P with alpha=0.85 and uniform teleportation (in a strongly preferential
% sense) to an accuracy of 1e-12.
%
% If d = ones(n,1) - P*ones(n,1), then the output x satisifes 
%   ||x - alpha*(P + dv')'*x + (1-alpha)*v||_1 <= 2*tol
% or (for small tol) 
%   x = alpha*(P + dv')*x + (1-alpha)*v.
%
% [x flag reshist]=powerpr(P,a,v,tol,maxit) provides extra output and options
% for the value of alpha, the teleportation distribution vector v, the
% tolerance, and the maximum number of iterations.  The output flag is 0 if
% the system converged and 1 otherwise.  reshist is the vector of
% residuals from each iteration.
%
% Example:
%   load('../data/wb-cs.stanford.mat');
%   x=powerpr2(P);

% David Gleich
% Copyright, Stanford University, 2008

% 2008 February 1
% Initial version

% 2008-05-01: Added csum command for compensated summation

if isstruct(P), rp=P.rp; ci=P.ci; ai=P.ai; vals=true;
else islogical(P), [rp cp] = sparse_to_csr(P); vals=false;
else [rp cp ai] = sparse_to_csr(P); vals=true;
end
n = length(rp)-1;

if ~exist('a','var') || isempty(a), a=0.85; end
if ~exist('v','var') || isempty(v), v=1./n; end
if ~exist('tol','var') || isempty(tol), tol=1e-12; end
if ~exist('maxit','var') || isempty(maxit), maxit=10000; end





x=zeros(n,1)+v; flag=0; delta=2; iter=0; reshist=zeros(maxit,1);
t=0; z=0; % temp variables for compensated summation

while iter<maxit && delta>tol
    sumy = 0;
    % y = a*P'*x
    
    w = (1-sumy);

    reshist(iter+1)=delta; iter=iter+1;

end
flag=delta>tol; reshist=reshist(1:iter);
fprintf('solved pagerank(a=%6.4f) in %5i multiplies to %8e tolerance\n', a, iter, delta);

size_t n = (size_t)g->n, n1; 
    int iter = 0; register double delta = 2, sumy, ny, *xi, *yi, t, z;
    while (delta > tol && iter++ < maxit) {
        if (mult(g, x, y, alpha, &sumy)) { return (NULL); }
        double w = (1.0-sumy)/(double)n,nys[2]={0}; delta=0.0; 
        n1=n;yi=y; while (n1-->0) { (*yi)+=w; CSUM(fabs(*yi++),nys,t,z); }  
        n1=n;yi=y;xi=x;ny=FCSUM(nys);nys[0]=0.;nys[1]=0.;
        while (n1-->0) {(*yi)/=ny; CSUM(fabs(*yi++-*xi++),nys,t,z);} delta=FCSUM(nys);
#ifdef BVALGS_VERBOSE
        printf("power : iter = %6i ; delta = %10e\n", iter, delta);
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
