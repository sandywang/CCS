%% Inner-outer and $|\lambda_k|$
% Let's look at the convergence of the inner outer iteration for some
% small matrices and the factor $|\lambda_k|$ that may be important.
%
% Same experiment as lambda_k but with connected components

%% Setup the experiment
addpath('../../matlab');
addpath('../../libbvg');
datadir = '/var/tmp/dgleich/data/';
CSSTAN = sparse(bvgraph([datadir filesep 'wb-cs.stanford']));
CNR2000 = sparse(bvgraph([datadir filesep 'cnr-2000']));
load([datadir filesep 'matrices.mat']);

%%
graphs = struct('name',{'cs-stan', 'cs-ubc', 'ubc', 'cnr-2000', 'stan-berk'},...
                'g',{CSSTAN, CS', UBC', CNR2000, SB'});
%%
% compute the eigenvalues of largest magnitude
results = [];
for i=1:length(graphs)
    G = largest_component(graphs(i).g);
    graphs(i).g = G;
    P = normout(G);
    nevals = 50;
    fprintf('Eigenvalues of %s ... ', graphs(i).name); t0=clock;
    [V D] = eigs(P,nevals,'LM',struct('disp',0));
    dt = etime(clock,t0); 
    d = diag(D); [ignore p]=sort(abs(d),1,'descend'); d=d(p);
    ki = abs((abs(d)-1))>1e4*eps(1); k = find(ki,1,'first');
    fprintf('... took %s secs : k=%i ', dt, k);
    if k<nevals, fprintf(' ; lk=%g ', d(end-k)); end
    fprintf('\n');
    results(i).name = graphs(i).name;
    results(i).evals = d;
    results(i).k = k;
end
%%
% solve pagerank with power and inner outer and alpha > lk
maxit = 3001;
tol = 1e-10;
for i=1:length(results)
    G = graphs(i).g;
    P = normout(G);
    k = results(i).k;
    if k>=nevals, continue; end
    lk = results(i).evals(k);
    a = 1-(1-lk)/2;
    fprintf('Testing %s with alpha=%g ; lk=%g\n', graphs(i).name, a, lk);
    [ignore flag histp] = powerpr(P,a,[],tol,maxit);
    [ignore flag histio] = inoutpr(P,a,[],tol,maxit);
    results(i).lk = lk;
    results(i).alpha_big = a;
    results(i).rho_big_p = histp(end)/histp(end-1);
    results(i).rho_big_io = histio(end)/histio(end-1);
    a = 1-(1-lk)*2;
    fprintf('Testing %s with alpha=%g ; lk=%g\n', graphs(i).name, a, lk);
    [ignore flag histp] = powerpr(P,a,[],tol,maxit);
    [ignore flag histio] = inoutpr(P,a,[],tol,maxit);
    results(i).alpha_small = a;
    results(i).rho_small_p = histp(end)/histp(end-1);
    results(i).rho_small_io = histio(end)/histio(end-1);
end
[results.alpha_big; results.rho_big_p; results.rho_big_io; ...
    results.alpha_small; results.rho_small_p; results.rho_small_io; ...
    results.lk;]'
save 'lk_cc_results.mat' results;



