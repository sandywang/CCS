%% Experiment with $\alpha=1-\eps$ on the stanford matrix.
% Does the inner outer algorithm should work well when $\alpha=1-\eps$? 
% Let's see ...
%
% Our idea is to evaluate the standard inner outer algorithm with a few
% choices of the inner tolerance for a wide range of betas between 0.5 and
% alpha.  
%
% This experiment is a copy of alpha_1_eps_csstan with fewer parameter
% choices.

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
A = bvgraph('../../data/wb-stanford'); A=sparse(A);
P = normout(A);
n = size(P,1);

%% Setup parameters
as = [0.999999 0.99999999];
tol=1e-7;
maxit=1e4;

%% Get the exact answer.
% Thankfully, we can just use Tim Davis, err... UMFPACK, to solve the
% linear systems.  The problem we are considering isn't yet large enough
% that we need fancy techniques.  
xtrues = zeros(n,length(as));
for i=1:length(as)
    a = as(i);
    y = (speye(n)-a*P')\((1-a)*ones(n,1));
    y = y./norm(y,1);
    xtrues(:,i)=y;
end

%% Try the inner outer 
results=[];
for ai=1:length(as)
    a = as(ai);
    [xio flagio histio] = inoutpr(P,a,[],tol,maxit,[],[],1);
    [xp flagp histp] = powerpr(P,a,[],tol,maxit,1);
    results(ai).a = a;
    results(ai).pow_err = norm(xp-xtrues(:,ai),1);
    results(ai).io_err = norm(xio-xtrues(:,ai),1);
    results(ai).io_hist = histio;
    results(ai).pow_hist = histp;
end
%% Do some plotting

