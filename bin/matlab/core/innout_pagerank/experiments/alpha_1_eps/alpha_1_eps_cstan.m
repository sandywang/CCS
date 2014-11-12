%% Experiment with $\alpha=1-\eps$ on the cs-stanford matrix.
% Does the inner outer algorithm should work well when $\alpha=1-\eps$? 
% Let's see ...
%
% Our idea is to evaluate the standard inner outer algorithm with a few
% choices of the inner tolerance for a wide range of betas between 0.5 and
% alpha.  

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
P = normout(A);
n = size(P,1);

%% Setup parameters
as = [0.99 0.9999 0.999999 0.99999999];
itols = [1e-2 1e-3 1e-5];
tol = 1e-7;
betasfun = @(a) chebpts(12,[0.5,a],'rising');
maxit = 1e6;

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
    betas = betasfun(a);
    for ti=1:length(itols)
        t = itols(ti);
        for bi=1:length(betas)
            b = betas(bi);
            fprintf('[%6.0e %6.4f %6.0e] ', 1-a, b, t);
            [x flag hist] = inoutpr(P,a,[],tol,maxit,b,t);
            results(ai,ti,bi).niter = length(hist);
            results(ai,ti,bi).err = norm(x-xtrues(:,i),1);
        end
    end
end
save 'a1eps-csstan.mat' results as betasfun itols maxit tol;

%% Do some plotting

