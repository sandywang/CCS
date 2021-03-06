function [x flag reshist]=inoutgspr2(P,a,v,tol,maxit,b,itol,verbose)
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
if ~exist('v','var') || isempty(v), v=1/n; end
if ~exist('tol','var') || isempty(tol), tol=1e-12; end
if ~exist('maxit','var') || isempty(maxit), maxit=10000; end
if ~exist('b','var') || isempty(b), b=0.85*(a>=0.6);  end
if ~exist('itol','var') || isempty(itol), itol=1e-1; end
if ~exist('verbose','var') || isempty(verbose), verbose=true; end

u = 1/n;

Ps=P;

x=zeros(n,1)+v; y=P'*x;y=y+(sum(x)-sum(y))*v; nm=1; 
f=a*y;f=f+(1-a)*v;f=f-x; dsum=[];
dlta=norm(f,1);reshist=[dlta;zeros(maxit-1,1)];
if verbose, fprintf('inoutgs (out) : m=%7i d=%8e\n',nm,dlta); end
while nm<maxit && dlta>tol
    f=(a-b)*y; f=f+(1-a)*v; d=dlta; 
    ii=1; dsum=[]; d=2;
    %f=gssweeppr(x,Ps,v,(a-b),(1-a)); ii=ii+1;
    while d>itol&&nm+ii<maxit,
        [x rdiff dsum Ps]=gssweeppr(x,Ps,f,b,1.,dsum);ii=ii+1;
        d = rdiff; 
        nx = norm(x,1);
        x = x./nx; dsum=dsum./nx;
        if verbose, fprintf('inoutgs (in) : m=%7i d=%8e\n',nm,d); end
    end
    y=P'*x;y=y+dsum*v;f=a*y; f=f+(1-a)*v; f=f-x; dlta=norm(f,1); % ||a*y+(1-a)*v-x||_1
    reshist(nm+1:nm+ii+1)=dlta; nm=nm+ii+1; 
    if verbose, fprintf('inoutgs (out) : m=%7i d=%8e\n',nm,dlta); end
    if ii<2 || dlta < itol 
        %x=a*y; x=x+(1-a)*v; 
        break; 
    end 
end
dsum=[]; dp=dlta; %nm=0;
while nm<maxit && dlta>tol
    [x rdiff dsum Ps]=gssweeppr(x,Ps,v,a,(1-a),dsum,u);
    nx = norm(x,1);
    x=x./nx; dsum = dsum./nx;
    % evaluate the residual
    dlta = prresid(x,P,a,v,dsum,u);
    if verbose, fprintf('inoutgs ( gs) : m=%7i d=%8e r=%8e c=%8e\n', ...
            nm, dlta,dlta/dp, rdiff); dp=dlta; 
    end    
    reshist(nm+1)=dlta; nm=nm+1;
end
fprintf('solved pagerank(a=%6.4f) in %5i multiplies to %8e tolerance\n', a, nm, dlta);
 reshist=reshist(1:nm);
end

function delta=prresid(x,P,a,v,dsum,u)
    % because we ensure that ||x||=1, we compute the residual of the
    % eigensystem
    h = a*(P'*x);
    %w=a*dsum + (1-a);
    %h=h+w*v; 
    h = h + a*dsum*u + (1-a)*v;
    h = h - x;
    delta = norm(h,1);
end
        
