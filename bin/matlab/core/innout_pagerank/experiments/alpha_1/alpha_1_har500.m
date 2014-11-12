%% Experiment with $\alpha=1$ on the harvard500 matrix.
% The inner outer algorithm should work well when $\alpha=1$. Let's see ...

%% Setup
addpath('../../matlab');

%%
% Load the data and extract the largest strong component of the graph G
% before converting it to a random walk transition matrix.  The outlinks in
% the harvard500.mat file are stored in the columns, not the rows, so we
% first transpose before the other computations.
load('../../data/harvard500.mat');
G = G'; G=largest_component(G); P=normout(G);

%% Get the exact answer.
% The exact answer is the eigenvector corresponding to eigenvalue 1 as a
% probability distribution.
[V D] = eig(full(P')); d=diag(D);
[maxev maxevind]=max(d);
x=V(:,maxevind); x=x*sign(x(1)); x=x./norm(x,1); % convert to probability
xtrue=x;

%% Now try inner/outer
[x flag hist]=inoutpr(P,1,[],1e-12,[],0.5,[],1);

norm(x-xtrue,1)

%%
% Okay, that works, but it's pretty trivial in this case
ds = sort(d,1,'descend');
gap=ds(2)/d(1)

%%
% The gap says that the power method converges rapidly already.

