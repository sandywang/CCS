%% Evaluate performance of gauss-seidel

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
A = bvgraph('../../data/wb-cs.stanford'); A=sparse(A); A=A-diag(diag(A));
P = normout(A);
n = size(P,1);

%% First simple test of gspr function (I'm still debugging it now)
