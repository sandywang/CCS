function [x flag reshist]=inoutpr(P,a,v,tol,maxit,b,itol,verbose)
% INOUTPR Solve a PageRank system using inner-outer iterations
%
% x=inoutpr(P) solve a PageRank system with the row (sub-)stochastic matrix
% P with alpha=0.85 and uniform teleportation (in a strongly preferential
% sense) to an accuracy of 1e-12 with b=0.5*(a>0.6), itol=1e-2.  Experience
% shows this choice of parameters tends to tie or beat the power method.
%
% If d = ones(n,1) - P*ones(n,1), then the output x satisifes 
%   ||x - alpha*(P + dv')'*x + (1-alpha)*v||_1 <= 2*tol
% or (for small tol) 
%   x = alpha*(P + dv')*x + (1-alpha)*v.
%
% [x flag reshist]=inoutpr(P,a,v,tol,maxit,b,itol) provides extra output 
% and options for the value of alpha, the teleportation distribution 
% vector v, the tolerance, the maximum number of iterations.  The values of
% b and itol control the inner solution and inner solution tolerance.
% The output flag is 0 if the system converged and 1 otherwise, and reshist
% is the vector of residuals from each iteration.
%
% Example:
%   load('../data/wb-cs.stanford.mat');
%   x=inoutpr(P);

% David Gleich and Paul Constantine
% Copyright, Stanford University, 2008

% 2008 February 7
% Initial version
%
% 2008 February 21
% Updated for correct residual storage, verbose output
% correct itol parsing

% 2008-05-02: Added delta prev and ratio tracking
% 2008-05-23: Use normdiff for residual, csum normalization
%             Checked iterations, mults, and sweeps counts


n=size(P,1); flag=0; 
if ~exist('a','var') || isempty(a), a=0.85; end
if ~exist('v','var') || isempty(v), v=1./n; end
if ~exist('tol','var') || isempty(tol), tol=1e-12; end
if ~exist('maxit','var') || isempty(maxit), maxit=10000; end
if ~exist('b','var') || isempty(b), b=0.5*(a>=0.6);  end
if ~exist('itol','var') || isempty(itol), itol=1e-2; end
if ~exist('verbose','var') || isempty(verbose), verbose=false; end

x=zeros(n,1)+v; y=P'*x;y=y+(csum(x)-csum(y))*v; nm=1; 
dlta = norm_axpbypgz(y,v,x,a,(1-a),-1);
reshist=[dlta;zeros(maxit-1,1)];
while nm<maxit && dlta>tol
    f=(a-b)*y; f=f+(1-a)*v; d=dlta; ii=0;
    while nm+ii<maxit && d>itol,
        x=b*y; x=x+f; y=P'*x; y=y+(csum(x)-csum(y))*v;ii=ii+1; % x=b*y+f;y=Pd'*x
        d=norm_axpbypgz(x,y,f,1,-b,-1);
    end
    dlta = norm_axpbypgz(y,v,x,a,(1-a),-1);
    reshist(nm+1:nm+ii)=dlta; nm=nm+ii; 
    if verbose, fprintf('inout (out) : m=%7i d=%8e\n',nm,dlta); end
    if ii<2 || dlta < itol 
        x=a*y; x=x+(1-a)*v; break; 
    end 
end
if verbose, dp=dlta; end
while nm<maxit && dlta>tol
    y=x./csum(x); x=a*(P'*y);  w=1-csum(x); x=x+w*v; 
    dlta=normdiff(y,x); nm=nm+1; reshist(nm)=dlta;
    if verbose, fprintf('inout (pow) : m=%7i d=%8e r=%8e\n',nm,dlta,dlta/dp); 
        dp=dlta; end
end
x=x./csum(x); flag=dlta>tol; reshist=reshist(1:nm);
if flag, s='finished'; else s='solved'; end
fprintf('%8s %10s(a=%6.4f) in %5i multiplies to %8e tolerance\n', ...
    s, mfilename, a, nm, dlta);