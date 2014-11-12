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
%   x=inoutgspr(P);

% David Gleich
% Copyright, Stanford University, 2008

% 2008-05-04: Initial coding

n=size(P,1); flag=0; 
if ~exist('a','var') || isempty(a), a=0.85; end
if ~exist('v','var') || isempty(v), v=1./n; end
if ~exist('tol','var') || isempty(tol), tol=1e-12; end
if ~exist('maxit','var') || isempty(maxit), maxit=10000; end
if ~exist('b','var') || isempty(b), b=0.85;  end
if ~exist('itol','var') || isempty(itol), itol=1e-2; end
if ~exist('verbose','var') || isempty(verbose), verbose=false; end

x=zeros(n,1)+v; reshist=zeros(maxit,1); dlta=2; nm=0;
nsteps=10;
for ns=1:nsteps
    x=gssweeppr(x,P,v,b,1-a); 
end
nm=nm+nsteps;
[x flag histgs]=gspr(P,a,v,tol,maxit,true,verbose,[],x./csum(x));
ii=length(histgs);
reshist(nm+1:nm+ii) = histgs; nm=nm+ii; reshist=reshist(1:nm);
% if verbose, dp=dlta; end
% while nm<maxit && dlta>tol
%     y=x./norm(x,1); x=a*(P'*y);  w=1-sum(x); x=x+w*v; 
%     y=y-x; dlta=norm(y,1); nm=nm+1; reshist(nm)=dlta;
%     if verbose, fprintf('inout (pow) : m=%7i d=%8e r=%8e\n',nm,dlta,dlta/dp); 
%         dp=dlta; end
% end
% x=x./norm(x,1); flag=dlta>tol; reshist=reshist(1:nm);
% fprintf('solved pagerank(a=%6.4f) in %5i multiplies to %8e tolerance\n', a, nm, dlta);