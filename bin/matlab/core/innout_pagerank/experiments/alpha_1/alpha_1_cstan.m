%% Experiment with $\alpha=1$ on the cs-stanford matrix.
% The inner outer algorithm should work well when $\alpha=1$. Let's see ...
%
% This experiment copies alpha_1_har500 but with the cs-stanford matrix
% instead

%% Setup
addpath('../../matlab');
addpath('../../libbvg32'); % use this for the Zeus computer, use
%addpath('../../libbvg'); % this line for Euler instead
% If you get lots of errors, try running
% >> mex -setup
% select the GNU compilers
% then edit the mexopts.sh file that comes out, e.g.
% edit /ubc/cs/home/d/dgleich/.matlab/R2007a/mexopts.sh
% and remove the -ansi flag everywhere.

%%
% Load the data and extract the largest strong component of the graph G
% before converting it to a random walk transition matrix.  The outlinks in
% the harvard500.mat file are stored in the columns, not the rows, so we
% first transpose before the other computations.
A = bvgraph('../../data/wb-cs.stanford'); A=sparse(A);
A=largest_component(A); P=normout(A);

%% Get the exact answer.
% The exact answer is the eigenvector corresponding to eigenvalue 1 as a
% probability distribution.
[V D] = eig(full(P')); d=diag(D);
[maxev maxevind]=max(d);
x=V(:,maxevind); x=x*sign(x(1)); x=x./norm(x,1); % convert to probability
xtrue=x;

%%
% This time, let's look at the gap to start with...
ds = sort(d,1,'descend');
gap=ds(2)/ds(1)


%% Now try inner/outer
[x flag hist]=inoutpr(P,1,[],1e-12,[],0.5,[],1);

norm(x-xtrue,1)

