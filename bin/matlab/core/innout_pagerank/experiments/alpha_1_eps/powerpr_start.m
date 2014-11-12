function [x flag reshist]=powerpr(P,a,v,tol,maxit,verbose,x0)
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
%   x=powerpr(P);

% David Gleich and Paul Constantine
% Copyright, Stanford University, 2008

% 2008 February 1
% Initial version

% 2008-05-01: Added csum command for compensated summation
% 2008-05-02: Added verbose

n=size(P,1); 
if ~exist('a','var') || isempty(a), a=0.85; end
if ~exist('v','var') || isempty(v), v=1./n; end
if ~exist('tol','var') || isempty(tol), tol=1e-12; end
if ~exist('maxit','var') || isempty(maxit), maxit=10000; end
if ~exist('verbose','var') || isempty(verbose), verbose=0; end
if ~exist('x0','var') || isempty(x0), x=zeros(n,1)+v; end

flag=0; delta=2; iter=0; reshist=zeros(maxit,1);
if verbose, dp=delta; end
while iter<maxit && delta>tol
    y=a*(P'*x); w = 1-csum(y); y = y + w*v; x = x-y; 
    delta=norm(x,1); reshist(iter+1)=delta; iter=iter+1; x=y./norm(y,1);
    if verbose, fprintf('power : m=%7i d=%8e r=%8e\n',iter,delta,delta/dp); dp=delta; 
    end
end
flag=delta>tol; reshist=reshist(1:iter);
fprintf('solved pagerank(a=%6.4f) in %5i multiplies to %8e tolerance\n', a, iter, delta);
