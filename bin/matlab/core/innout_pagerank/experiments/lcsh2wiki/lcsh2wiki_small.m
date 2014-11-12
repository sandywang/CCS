addpath('../../matlab');

%% Small test
load 'lcsh2wiki-small.mat'
A = Asmall;
B = Bsmall;

%%
P = normout(A);
Q = normout(B);

%%
m = size(P,1);
n = size(Q,1);
alpha = 0.95;
W = rand(m,n);
W(W<1e-4)=0;
W=sparse(W);
W=W./csum(nonzeros(W));

%% 
[x,flag,hist] = inoutpr_isorank(P,Q,0.95,W);
save 'lcsh2wiki-small-x-io.mat' x hist;
clear x;
[x2,flag,hist2]= inoutpr_isorank(P,Q,0.95,W,[],[],[],1);
save 'lcsh2wiki-small-x-power.mat' x2 hist2;

