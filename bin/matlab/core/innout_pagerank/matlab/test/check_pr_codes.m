function nfailed = check_pr_codes(a, graphs,datadir,codes,verbose)

nfailed = 0;
if ~exist('graphs','var') || isempty(graphs)
    graphs={'example-small','harvard500','wb-cs.stanford'}; 
end
if ~exist('datadir','var') || isempty(datadir)
    p = mfilename('fullpath');
    p = fileparts(p); % get the path
    datadir = [p filesep '..' filesep '..' filesep 'data'];
end
if ~exist('codes','var') || isempty(codes)
    codes = {'powerpr','gspr','inoutpr','inoutgspr'};
    %codes = {'gspr','inoutgspr'};
end
if ~exist('verbose','var') || isempty(verbose), verbose=true; end
if ~exist('a','var') || isempty(a), a=0.85; end

tol=1e-10; 
gnl=max(cellfun('length',graphs));

for gi=1:length(graphs)
    gn = graphs{gi};
    G = bvgraph([datadir filesep gn]);
    A = sparse(G);
    P = normout(A);
    n = size(P,1);

    B = speye(n)-a*P'; b = ones(n,1)./n; y = B\b; xstar = y/csum(y);
    for ci=1:length(codes)
        c = codes{ci};
        x = feval(c,P,a,[],tol);
        d = normdiff(x,xstar);
        if d>(1/(1-a))*tol,
            nfailed = nfailed+1;
            warning('check_pr_codes:largeError',...
                '%10s on %*s gave x with ||x-xstar|| = %8e\n', ...
                c, gnl, gn, d);
        end
        if verbose,
            fprintf('%10s on %*s gave x with ||x-xstar|| = %8e\n', ...
                c, gnl, gn, d);
        end
    end 
end