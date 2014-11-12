%% PageRank with Gauss-Seidel vs. Inner-Outer
% Informally, many have touted the Gauss-Seidel iteration as the preferred
% way of computing PageRank.  For a few graphs, the performance of
% Gauss-Seidel is warranted in a serial environment.  But, as we'll show,
% Gauss-Seidel is not as good as the inner-outer iteration for large values
% of $\alpha$.  The inner-outer iteration is easy to implement and trivial
% to parallelize, unlike Gauss-Seidel.

%% Setup the experiment
addpath('../../matlab');
load ('/var/tmp/dgleich/data/matrices.mat');

%% Run for a few values of $\alpha$
alphas = [0.99 0.999 0.9999];
graphs = struct('name',{'cs-ubc','ubc','stan-berk'},'G',{CS',UBC',SB'});

%% Compute xtrues
xtrues = cell(length(graphs),length(alphas));
for gi=1:length(graphs)
    G = graphs(gi).G; 
    P = normout(G);
    n = size(P,1);
    for ai=1:length(alphas)
        a = alphas(ai);
        A = speye(n)-a*P'; b = (1-a)*ones(n,1)/n;
        xtrue = A\b; xtrue=xtrue./norm(xtrue,1);
        xtrues{gi,ai}=xtrue;
    end
end
%% Compute with gspr
results = [];
tol=1e-7; maxit=100000;
for gi=1:length(graphs)
    G = graphs(gi).G; 
    P = normout(G);
    n = size(P,1);
    for ai=1:length(alphas)
        a = alphas(ai);
        xtrue = xtrues{gi,ai};
        [xgs flag histgs] = gspr(P,a,[],tol,maxit);
        [xio flag histio] = inoutpr(P,a,[],tol,maxit);
        results(end+1).name = graphs(gi).name;
        results(end).alpha = a;
        results(end).err_gs = norm(xgs-xtrue,1);
        results(end).err_io = norm(xio-xtrue,1);
        results(end).iter_gs = length(histgs);
        results(end).mult_io = length(histio);
    end
end
%%
squeeze(struct2cell(results))'
save 'gspr_comp_results.mat' results;
    
