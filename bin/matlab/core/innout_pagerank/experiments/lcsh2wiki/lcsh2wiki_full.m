addpath('../../matlab');

%% Small test
load 'lcsh2wiki.mat'
A = A2;
B = B2;
W = readSMAT('strmatching/lcsh2wiki-matches-all.smat');

%%
P = normout(A);
Q = normout(B);

%%
m = size(P,1);
n = size(Q,1);
alpha = 0.95;
W=W./csum(nonzeros(W));

%% 
[x,flag,hist] = inoutpr_isorank(P,Q,alpha,W);
save -v7.3 'lcsh2wiki-full-x-io.mat' x hist;
clear x;
[x2,flag,hist2]= inoutpr_isorank(P,Q,alpha,W,[],[],[],1);
save -v7.3 'lcsh2wiki-full-x-power.mat' x2 hist2;

