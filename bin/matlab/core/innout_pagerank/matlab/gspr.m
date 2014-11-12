function [x flag reshist] = gspr(P,a,v,tol,maxit,resid,verbose,u,x0,xstar,normed)
% GSPR Compute PageRank with the Gauss Seidel algorithm
% 
% x=gspr(P,a) computes a PageRank vector for a sub-row stochastic matrix P
% using the a complete teleportation node fix.  
%
% x=gspr(P,a,v,tol,maxit,resid,verbose,u,x0,xstar) specifies all options
% including the teleportation vector - v; the stopping tolerance - tol; 
% residual computations at each step - resid; verbose printing - verbose;
% an initial guess - x0; and an exact solution - xstar.
%

% 2008-05-02: Initial code, added mex call
% 2008-05-04: Added starting x0.
% 2008-05-13: Modified to use gssweeppr function for the actual computation
% 2008-05-14: Modified to use normalized residuals and limited residual
%             computations
% 2008-05-23: Added normed computation as an option
%             Switched to normdiff function
%             Checked iterations, mults, and sweeps counts

n = size(P,1); 

if ~exist('a','var') || isempty(a), a=0.85; end
if ~exist('v','var') || isempty(v), v=1./n; end
if ~exist('tol','var') || isempty(tol), tol=1e-8; end
if ~exist('maxit','var') || isempty(maxit), maxit=10000; end
if ~exist('resid','var') || isempty(resid), resid=true; end
if ~exist('verbose','var') || isempty(verbose), verbose=false; end
if ~exist('x0','var') || isempty(x0), x0=[]; end % set x0 to empty
if ~exist('u','var') || isempty(u), u=1/n; end % set x0 to empty
if ~exist('xstar','var'), xstar=[]; end
if ~exist('normed','var') || isempty(normed), normed=false; end

if ~isempty(x0)
    if any(x0<0), error('gspr:nonNegativeVectorRequired',...
            'the input x0 must be a non-negative vector.');
    end
    sx0=csum(x0);
    if abs(sx0-1)>10*eps(1), 
        warning('gspr:stochasticVectorRequired',...
            ['the input x0 did not sum to 1, altering it''s sum from ', ...
             ' %g to %g'], sx0, 1);
         x0=x0./sx0;
    end
end

Ps=P; 

if ~isempty(x0), x=x0; else x=zeros(n,1)+v; end
cerr = ~isempty(xstar);
nchkit = -1; extra = 0;
flag=0; delta=2; iter=0; reshist=zeros(maxit,1); t=0; z=0; dp=delta;
dsum=[]; 
while iter<maxit && delta>tol
    [x rdiff dsum Ps]=gssweeppr(x,Ps,v,a,(1-a),dsum,u);
    if normed,  nx = csum(x); x=x./nx; dsum = dsum./nx; end
    % evaluate the residual
    if cerr, delta = norm(x-xstar,1); 
    else
        if resid, delta = prresid(x,P,a,v,dsum,u); extra = extra + 1;
        elseif rdiff < tol
            if iter>nchkit, 
                delta = prresid(x,P,a,v,dsum,u); extra = extra + 1;
                nchkit = iter + floor((log(tol)-log(delta))/(2.0*log(a)));
            end
        end     
    end
    if verbose, fprintf('gs : m=%7i nm=%7i d=%8e r=%8e c=%8e\n', ...
            iter,iter+extra, delta, delta/dp, rdiff); dp=delta; 
    end    
    reshist(iter+1)=delta; iter=iter+1;
end
flag=delta>tol; reshist=reshist(1:iter);
if flag, s='finished'; else s='solved'; end
fprintf('%8s %10s(a=%6.4f) in %5i sweeps and %5i mults to %8e tolerance\n', ...
    s, mfilename, a, iter, iter+extra, delta);
end

function delta=prresid(x,P,a,v,dsum,u)
    h = a*(P'*x);
    h = h + a*dsum*u + ((1-a)*csum(x))*v;
    %h = h + a*dsum*u + (1-a)*v;
    delta = normdiff(h,x);
end