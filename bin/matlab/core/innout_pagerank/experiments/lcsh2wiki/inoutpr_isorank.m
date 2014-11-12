function [x flag reshist]=inoutpr_isorank(P,Q,a,W,tol,maxit,b,itol,verbose)
% INOUTPR_ISORANK Solve an IsoRank system using inner-outer PageRank
%
% David F. Gleich
% Copyright, Stanford University, 2008

% 2008-12-18: Initial version


m=size(P,1);
n=size(Q,1);
N = n*m;
flag=0; 
if ~exist('a','var') || isempty(a), a=0.85; end
if ~exist('W','var') || isempty(W), w=ones(N,1)./N; else w=W(:); end
if ~exist('tol','var') || isempty(tol), tol=1e-7; end
if ~exist('maxit','var') || isempty(maxit), maxit=10000; end
if ~exist('b','var') || isempty(b), b=0.5*(a>=0.6);  end
if ~exist('itol','var') || isempty(itol), itol=1e-2; end
if ~exist('verbose','var') || isempty(verbose), verbose=true; end
t0 = clock;
x = zeros(N,1); 
if issparse(w), wi=find(w); x(wi)=x(wi)+nonzeros(w); else x=x+w; end
y=x;
x=reshape(x,m,n); 
y=reshape(y,m,n);
for i=1:n, y(:,i) = P'*(x*Q(:,i)); end 
x=reshape(x,N,1); 
y=reshape(y,N,1);
nm=1; 
dlta = norm_axpbypgz(y,w,x,a,(1-a),-1);
reshist=[dlta;zeros(maxit-1,1)];
while nm<maxit && dlta>tol
    f=(a-b)*y; 
    if issparse(w), f(wi)=f(wi)+nonzeros(w)*(1-a); else f=f+(1-a)*w; end
    d=dlta; ii=0; dt= etime(clock, t0);
    if verbose, fprintf('inout (out) : m=%7i d=%8e t=%6.2f\n',nm,dlta,dt); end
    while nm+ii<maxit && d>itol,
        clear x;
        x=y; x=b*x; x=x+f; 
        x=reshape(x,m,n); 
        y=reshape(y,m,n);
        for i=1:n, y(:,i) = P'*(x*Q(:,i)); end
        x=reshape(x,N,1); 
        y=reshape(y,N,1);
        ii=ii+1;
        d=norm_axpbypgz(x,y,f,1,-b,-1);
        if verbose, 
            dt= etime(clock, t0);
            fprintf('inout ( in) : m=%7i d=%8e t=%6.2f\n',nm+ii,d,dt); 
        end
    end
    dlta = norm_axpbypgz(y,w,x,a,(1-a),-1);
    reshist(nm+1:nm+ii)=dlta; nm=nm+ii; dt=etime(clock, t0);
    if verbose, fprintf('inout (out) : m=%7i d=%8e t=%6.2f\n',nm,dlta,dt); end
    if ii<2 || dlta < itol 
        x=y; x=a*x; 
        if issparse(w), x(wi)=x(wi)+nonzeros(w)*(1-a); else x=x+(1-a)*w; end
        break
    end 
end
if verbose, dp=dlta; end
while nm<maxit && dlta>tol
    y=x./csum(x); 
    x=reshape(x,m,n); 
    y=reshape(y,m,n);
    for i=1:n, x(:,i) = a*(P'*(y*Q(:,i))); end 
    x=reshape(x,N,1); 
    y=reshape(y,N,1);
    if issparse(w), x(wi)=x(wi)+nonzeros(w)*(1-a); else x=x+(1-a)*w; end
    dlta=normdiff(y,x); nm=nm+1; dt=etime(clock, t0); reshist(nm)=dlta;
    if verbose, 
        fprintf('inout (pow) : m=%7i d=%8e r=%8e t=%6.2f\n',...
            nm,dlta,dlta/dp, etime(clock, t0)); dp=dlta; 
    end
end
x=x./csum(x); flag=dlta>tol; reshist=reshist(1:nm);
if flag, s='finished'; else s='solved'; end
fprintf('%8s %10s(a=%6.4f) in %5i multiplies to %8e tolerance\n', ...
    s, mfilename, a, nm, dlta);


