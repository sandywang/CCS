%% A fast test of the bvpr C++ code
% This function just tests the wb-cs.stanford matrix for all the iterative
% methods at one value of alpha.

%% Compute with matlab
G = bvgraph('../data/wb-cs.stanford'); A = sparse(G); P = normout(A); 
n = size(P,1); a = 0.85; B = speye(n)-a*P'; b = ones(n,1)./n;
y = B\b; pr2 = y./csum(y);

%% Check against bvpr
!./bvpr ../data/wb-cs.stanford test 
pr=binload('test.pr'); diff = norm(pr-pr2,1);
if diff>5e-8
    warning('bvpr:incorrect','bvpr(inout) returned x with ||x-x*||_1 = %g',...
        diff); 
end

!./bvpr ../data/wb-cs.stanford test power
pr=binload('test.pr'); diff = norm(pr-pr2,1);
if diff>5e-8
    warning('bvpr:incorrect','bvpr(power) returned x with ||x-x*||_1 = %g',...
        diff); 
end

%% Check against bvmcpr
!./bvmcpr ../data/wb-cs.stanford test 
pr=binload('test.pr'); diff = norm(pr-pr2,1);
if diff>5e-8
    warning('bvpr:incorrect','bvmcpr(inout) returned x with ||x-x*||_1 = %g',...
        diff); 
end

!./bvmcpr ../data/wb-cs.stanford test power
pr=binload('test.pr'); diff = norm(pr-pr2,1);
if diff>5e-8
    warning('bvpr:incorrect','bvmcpr(power) returned x with ||x-x*||_1 = %g',...
        diff); 
end

%% Check against bvtranspr
!./bvtranspr ../data/wb-cs.stanford test 
pr=binload('test.pr'); diff = norm(pr-pr2,1);
if diff>5e-8
    warning('bvpr:incorrect','bvtranspr(inout) returned x with ||x-x*||_1 = %g',...
        diff); 
end

!./bvtranspr ../data/wb-cs.stanford test power
pr=binload('test.pr'); diff = norm(pr-pr2,1);
if diff>5e-8
    warning('bvpr:incorrect','bvtranspr(power) returned x with ||x-x*||_1 = %g',...
        diff); 
end

!./bvtranspr ../data/wb-cs.stanford test gs
pr=binload('test.pr'); diff = norm(pr-pr2,1);
if diff>5e-8
    warning('bvpr:incorrect','bvtranspr(gs) returned x with ||x-x*||_1 = %g',...
        diff); 
end

!./bvtranspr ../data/wb-cs.stanford test inoutgs
pr=binload('test.pr'); diff = norm(pr-pr2,1);
if diff>5e-8
    warning('bvpr:incorrect','bvtranspr(inoutgs) returned x with ||x-x*||_1 = %g',...
        diff); 
end

%% Check against bvmctranspr
!./bvtranspr ../data/wb-cs.stanford test 
pr=binload('test.pr'); diff = norm(pr-pr2,1);
if diff>5e-8
    warning('bvpr:incorrect','bvmctranspr(inout) returned x with ||x-x*||_1 = %g',...
        diff); 
end

!./bvtranspr ../data/wb-cs.stanford test power
pr=binload('test.pr'); diff = norm(pr-pr2,1);
if diff>5e-8
    warning('bvpr:incorrect','bvpr(power) returned x with ||x-x*||_1 = %g',...
        diff); 
end
