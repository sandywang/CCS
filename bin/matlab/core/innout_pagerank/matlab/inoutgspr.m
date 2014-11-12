function [x flag reshist]=inoutpr(P,a,v,tol,maxit,verbose,b,itol,resid,normed)
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
% 2008-05-23: Final version based on simple implementation
%             Added normed option
%             Checked iterations, mults, and sweeps counts
% 2008-05-30: Fixed iteration count, added Ps option

Ps=P; 
if isstruct(Ps), P=Ps.P; end
n=size(P,1); flag=0; 

if ~exist('a','var') || isempty(a), a=0.85; end
if ~exist('v','var') || isempty(v), v=1./n; end
if ~exist('tol','var') || isempty(tol), tol=1e-12; end
if ~exist('maxit','var') || isempty(maxit), maxit=10000; end
if ~exist('b','var') || isempty(b), b=0.5*(a>=0.6);  end
if ~exist('itol','var') || isempty(itol), itol=1e-2; end
if ~exist('verbose','var') || isempty(verbose), verbose=false; end
if ~exist('resid','var') || isempty(resid), resid=true; end
if ~exist('normed','var') || isempty(normed), normed=false; end

x=zeros(n,1)+v; y=P'*x;y=y+(csum(x)-csum(y))*v; nm=1; iter=0; dsum=[];
delta = norm_axpbypgz(y,v,x,a,(1-a),-1);
reshist=[delta;zeros(maxit-1,1)];
while nm<maxit && delta>tol
    f=(a-b)*y; f=f+(1-a)*v; d=delta; ii=0; 
    while nm+ii<maxit && d>itol,
        [x rdiff dsum Ps]=gssweeppr(x,Ps,f,b,1,dsum); ii=ii+1; 
        if normed, nx = norm(x,1); x=x./nx; dsum = dsum./nx; end
        d = rdiff;
    end
    y=P'*x;y=y+(csum(x)-csum(y))*v; ii=ii+1;
    delta = norm_axpbypgz(y,v,x,a,(1-a),-1);
    reshist(nm+1:nm+ii)=delta; nm=nm+ii; iter=iter+1;
    if verbose,fprintf('inoutgs (out) : i=%7i m=%7i d=%8e\n',iter,nm,delta);end
    if ii<2 || delta < itol 
        break; 
    end 
end
nchkit = -1; extra = 0;
t=0; z=0; dp=delta;
dsum=[]; 
while iter<maxit && delta>tol
    [x rdiff dsum Ps]=gssweeppr(x,Ps,v,a,(1-a),dsum);
    if normed, nx = csum(x); x=x./nx; dsum = dsum./nx; end
    % evaluate the residual
    if resid, delta = prresid(x,P,a,v,dsum);  extra = extra + 1;
    elseif rdiff < tol
        if iter>nchkit, 
            delta = prresid(x,P,a,v,dsum); extra = extra + 1;
            nchkit = iter + floor((log(tol)-log(delta))/(2.0*log(a)));
        end
    end     
    reshist(nm+1)=delta; iter=iter+1; nm=nm+1;
    if verbose, fprintf('inoutgs ( gs) : i=%7i m=%7i d=%8e r=%8e c=%8e\n', ...
            iter, nm, delta, delta/dp, rdiff); dp=delta; 
    end      
end
flag=delta>tol; reshist=reshist(1:nm);
if flag, s='finished'; else s='solved'; end
fprintf('%8s %10s(a=%6.4f) in %5i its, %5i sweeps, and %5i multiplies to %8e tolerance\n', ...
    s, mfilename, a, iter, nm, nm+extra, delta);
end

function delta=prresid(x,P,a,v,dsum)
    h = a*(P'*x);
    h = h + (a*dsum + (1-a)*csum(x))*v;
    %h = h + (a*dsum + (1-a))*v;
    delta = normdiff(h,x);
end