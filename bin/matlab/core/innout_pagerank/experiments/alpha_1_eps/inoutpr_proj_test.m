function [x flag reshist phist]=inoutpr(P,a,v,tol,maxit,b,itol,verbose)
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

% 2008-05-03: Added projection onto eigenspace tracking

n=size(P,1); flag=0; 
if ~exist('a','var') || isempty(a), a=0.85; end
if ~exist('v','var') || isempty(v), v=1./n; end
if ~exist('tol','var') || isempty(tol), tol=1e-12; end
if ~exist('maxit','var') || isempty(maxit), maxit=10000; end
if ~exist('b','var') || isempty(b), b=0.5*(a>=0.6);  end
if ~exist('itol','var') || isempty(itol), itol=1e-2; end
if ~exist('verbose','var') || isempty(verbose), verbose=false; end

[V D] = eig(P'); [ignore pd]=sort(-abs(diag(D))); V=V(:,pd); 
phist = zeros(n,maxit);

x=zeros(n,1)+v; y=P'*x;y=y+(sum(x)-sum(y))*v; nm=1; f=a*y;f=f+(1-a)*v;f=f-x; 
dlta=norm(f,1);x=x-b*y;reshist=[dlta;zeros(maxit-1,1)];
u = V\x; phist(:,nm) = u; 
nouter=0;
while nm<maxit && dlta>tol && nouter<1
    f=(a-b)*y; f=f+(1-a)*v; x=x-f; % f=(a-b)*y+vt;x=x-b*y-f;
    d = norm(x,1); ii=0; 
    while nm+ii<maxit && d>itol,
        x=b*y; x=x+f; y=P'*x; y=y+(sum(x)-sum(y))*v;ii=ii+1; % x=b*y+f;y=Pd'*x
        x=x-b*y; x=x-f; d=norm(x,1);   % x=x-b*y-f;
        u = V\(a*y + (1-a)*v); phist(:,nm+ii) = u;
    end
    if ii<2, x=a*y; x=x+(1-a)*v; break; end % no mult => no hist updte
    x=x+f; f=a*y; f=f+(1-a)*v; f=f-x; f=f-b*y; dlta=norm(f,1); % ||a*y+(1-a)*v-x||_1
    reshist(nm+1:nm+ii)=dlta; nm=nm+ii; 
    if verbose, fprintf('inout (out) : m=%7i d=%8e\n',nm,dlta); end
    nouter=nouter+1;
end
if verbose, dp=dlta; end
while nm<maxit && dlta>tol
    y=x./norm(x,1); x=a*(P'*y);  w=1-sum(x); x=x+w*v; 
    y=y-x; dlta=norm(y,1); nm=nm+1; reshist(nm)=dlta; u = V\(x./norm(x,1)); phist(:,nm)=u;
    if verbose, fprintf('inout (pow) : m=%7i d=%8e r=%8e\n',nm,dlta,dlta/dp); 
        dp=dlta; end
end
x=x./norm(x,1); flag=dlta>tol; reshist=reshist(1:nm); phist=phist(:,1:nm);
fprintf('solved pagerank(a=%6.4f) in %5i multiplies to %8e tolerance\n', a, nm, dlta);