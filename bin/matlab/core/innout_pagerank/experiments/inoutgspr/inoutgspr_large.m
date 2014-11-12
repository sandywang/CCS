%% Large scale tests of inoutgspr

%% Experiment setup
% This experiment should be run from the innout/experiments/inoutgspr directory
cwd = pwd;
dirtail = 'experiments/inoutgspr'; 
if strcmp(cwd(end-length(dirtail)+1:end),dirtail) == 0
    warning('%s should be executed from innout/%s\n', mfilename, dirtail);
end
addpath('../../libbvg');
addpath('../../matlab');

%% Load data
G1 = bvgraph('../../data/wb-stanford');
G2 = bvgraph('../../data/cnr-2000');

P1 = normout(sparse(G1));
P2 = normout(sparse(G2));

%% Setup parameters
a = 0.99;
tol = 1e-8;

%% Compute with gauss-seidel
[x1gs flag gshist1] = gspr(P1,a,[],tol,1500,true);
[x2gs flag gshist2] = gspr(P2,a,[],tol,1500,true);

%% Compute with inner-outer
[x1io flag iohist1] = inoutpr(P1,a,[],tol,1500,[],[],true);
[x2io flag iohist2] = inoutpr(P2,a,[],tol,1500,[],[],true);

%% Compute with iogs
[x1iogs flag iogshist1] = inoutgspr(P1,a,[],tol,1500,[],[],true);
[x2iogs flag iogshist2] = inoutgspr(P2,a,[],tol,1500,[],[],true);

%% Compute with iogs
[x1iogs6 flag iogs6hist1] = inoutgspr6(P1,a,[],tol,1500,[],[],true);
[x2iogs6 flag iogs6hist2] = inoutgspr6(P2,a,[],tol,1500,[],[],true);

