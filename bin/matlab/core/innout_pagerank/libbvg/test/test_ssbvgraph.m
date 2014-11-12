
% check that bvgraph correctly implements the stochastic multiplication 
% operation
G = bvgraph('../data/wb-cs.stanford');
P = ssbvgraph(G);
n = size(P,1); alpha = 0.85; v = ones(n,1)./n;
x = bicgstab(@(x) x - alpha*(P'*x), v, 1e-8, 500); x = x./norm(x,1);
help bvgraph
n = size(G,1); alpha = 0.85; v = ones(n,1)./n;
id = G*ones(n,1); id(id ~= 0) = 1./id(id ~= 0);
x2 = bicgstab(@(x) x - alpha*(G'*(id.*x)), v, 1e-8, 500); x2 = x2./norm(x2,1);
if norm(x-x2,1) > 10*eps, error('ssbvgraph:differentOutput', ...
    'ssbvgraph and bvgraph differ on PageRank'); end
