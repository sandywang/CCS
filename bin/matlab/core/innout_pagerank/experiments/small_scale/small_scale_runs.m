%% Inner-Outer PageRank experiments on small matrices
% All of the matrices in these experiments are considered small and we use
% our Matlab codes for them.  For all four methods (power, inout, gs,
% inoutgs) we solve PageRank using the method and compute the total
% solution time.  This may include some processing of the matrix, but it
% should be small compared to the total solution time.

%% Experiment setup
% This experiment should be run from the innout/experiments/inoutgspr directory
cwd = pwd;
dirtail = 'experiments/small_scale'; 
if strcmp(cwd(end-length(dirtail)+1:end),dirtail) == 0
    warning('%s should be executed from innout/%s\n', mfilename, dirtail);
end
addpath('../../libbvg');
addpath('../../matlab');

%%
% Parameters
alpha = 0.85; astr = '85';
alpha = 0.99; astr = '99';
alpha = 0.999; astr = '999'; 
%tols = [1e-3, 1e-5, 1e-7];
tols = [1e-3, 1e-7];
graphs = {'ubc-cs', 'ubc', 'in-2004', 'eu-2005', 'wb-edu'};
%graphs = {'ubc-cs', 'ubc'};
datadir = ['..' filesep '..' filesep 'data'];
methods = {'power', 'gs', 'inout', 'inoutgs'};
mfuncs = {@(P, alpha, tol, verbose) powerpr(P,alpha,[],tol,[],verbose), ...
          @(P, alpha, tol, verbose) gspr(P,alpha,[],tol,[],0,verbose), ...
          @(P, alpha, tol, verbose) inoutpr(P,alpha,[],tol,[],[],[],verbose), ...
          @(P, alpha, tol, verbose) inoutgspr(P,alpha,[],tol,[],verbose,[],[],0)};
ntols = length(tols);
ngraphs = length(graphs);
nmethods = length(methods);

%% Checkpointed runs
if exist('restart','var') && restart, load(['small-scale-results-' astr '.mat']);
else
    results = [];
    timeresults = zeros(ngraphs, ntols, nmethods);
    iterresults = zeros(ngraphs, ntols, nmethods);
end

%%
rnum = 0;
for gi=1:ngraphs
    g = graphs{gi};
    G = bvgraph([datadir filesep g]);
    A = sparse(G);
    P = normout(A);
    
    for ti=1:ntols
        t = tols(ti);
        
        for mi=1:nmethods
            rnum=rnum+1;
            if rnum<=length(results), continue; end
            prf = mfuncs{mi};
            t0=clock; [x flag hist] = prf(P,alpha,t,0); dt=etime(clock,t0);
            results(rnum).i = [gi ti mi];
            timeresults(gi,ti,mi) = dt;
            iterresults(gi,ti,mi) = length(hist);
            results(rnum).graph = g;
            results(rnum).mults = length(hist);
            results(rnum).time = dt;
            results(rnum).tol = t;
            results(rnum).alpha = alpha;
            results(rnum).method = methods{mi};
            results(rnum).mfunc = prf;
            results(rnum).resids = hist;
            
            save(['small-scale-results-' astr '.mat'], ...
                'results', 'rnum', 'timeresults', 'iterresults');
        end
    end
end

%% Process results
load(['small-scale-results-' astr '.mat']);


