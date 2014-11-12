%% A full test-suite of the bvpr codes
% This includes tests for multiple graphs with different values of alpha
% and all algorithms.  It can take a LONG time.

%%
datadir = '../data'
%graphs = {'example-small','harvard500','wb-cs.stanford','wb-stanford','cnr-2000'};
graphs = {'example-small','harvard500','wb-cs.stanford',};
alphas = [0.6 0.7 0.85 0.99];

%%
for gi = 1:length(graphs)
    gn = graphs{gi}; gf = [datadir filesep gn];
    G = bvgraph(gf);
    A = sparse(G);
    P = normout(A);
    n = size(P,1);
    for ai = 1:length(alphas)
        a = alphas(ai);
        B = speye(n) - a*P'; b = ones(n,1)./n;
        y = B\b; y = y./csum(y);
        nfailed = check_bvpr_codes(gf,a,y);
        if nfailed
            fprintf('%79s\n', repmat('*',1,79));
            fprintf('FAILED on %s(%4.2f)\n', gn, a);
            fprintf('%79s\n', repmat('*',1,79));
            pause;
        end
    end
end
