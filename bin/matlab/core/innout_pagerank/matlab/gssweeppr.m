function [x ndiff dsumn Ps y] = gssweeppr(x,P,v,a,g,dsum,u)

% 2008-05-13: Initial coding
% 2008-05-19: Added compensated summation of all terms

if ~exist('v'), v=[]; end
if ~exist('a') || isempty(a), a=0.85; end
if ~exist('g') || isempty(g), g=1-a; end
if ~exist('dsum'), dsum=[]; end
if ~exist('u'), u=[]; end

if isstruct(P), 
    cp=P.cp; ri=P.ri; Ps=P; vals=false;
    if isfield(P,'ai'), ai=P.ai; vals=true; end
elseif islogical(P), 
    [cp ri] = sparse_to_csc(P); vals=false;
    Ps = struct('ri',ri,'cp',cp);
else
    [cp ri ai] = sparse_to_csc(P); vals=true;
    Ps = struct('cp',cp,'ri',ri,'ai',ai);
end
n = length(cp)-1;

if ~isfield(P,'id')
    if ~vals, % need to compute degrees
        d=zeros(n,1);
        for i=1:length(ri), d(ri(i))=d(ri(i))+1; end
    else % need to compute dangling indicator
        d=false(n,1);
        for i=1:length(ri), d(ri(i))=true; end
    end
    d(d>0)=1./d(d>0);
    Ps.id = d;
end

id=Ps.id;

if isempty(u), u=1/n; end
if isempty(v), v=1/n; end

try
    if vals==false, ai=[]; end
    if nargout>4, y(:)=x(:); end % copy x to y

    [x ndiff dsumn] = gssweeppr_mex(x,n,cp,ri,ai,id,a,g,dsum,v,u);
    
    return
catch
    lasterror
	warning('gssweeppr:mexFailed',...
        'the mex implementation failed, reverting to slow matlab code.');
end
   
if isscalar(u), uscalar=true; else uscalar=false; end
if isscalar(v), vscalar=true; else vscalar=false; end
if isempty(dsum), 
    dsum1=0; dsum2=0; 
    for i=1:n, 
        if id(i)==0, t=dsum1; z=x(i)+dsum2; dsum1=t+z; dsum2=(t-dsum1)+z; end
    end
else
    dsum1=dsum; dsum2=0;
end

if nargout>4, y(:)=x(:); end % copy x to y

% compute the iteration with the matrix P

dsumn1=0; dsumn2=0; ndiff1=0; ndiff2=0;
for i=1:n
    xn=0; pii=0;
    for cpi=cp(i):cp(i+1)-1
        j=ri(cpi);
        if vals, pji = ai(cpi); else pji=id(j); end
        if i==j, pii = pji; continue; end
        xn=xn+x(j)*pji; 
    end
    dsums = (dsumn1+dsumn2+dsum1+dsum2);
    if uscalar, xn=xn+dsums*u; else xn=xn+dsums*u(i); end
    if id(i)==0
        xn = xn - x(i)/n;
        pii = pii + 1/n;
    end
    if vscalar, vi = v; else vi=v(i); end
    xn=(a*xn+g*vi)/(1-a*pii);
    if id(i)==0
        t=dsum1; z=-x(i)+dsum2; dsum1=t+z; dsum2=(t-dsum1)+z;
        t=dsumn1; z=xn+dsumn2; dsumn1=t+z; dsumn2=(t-dsumn1)+z;
    end
    xi=x(i);
    if xn>xi, dxi = xn-xi; else dxi = xi-xn; end
    t=ndiff1; z=dxi+ndiff2; ndiff1=t+z; ndiff2=(t-ndiff1)+z;
    %fprintf('i=%4i; x[i]=%8e; xn=%8e; diff=%8e; dsum=%8e\n', i, x(i), xn, ndiff, dsum);
    x(i)=xn;
end
dsumn = dsumn1+dsumn2;
ndiff = ndiff1+ndiff2;
