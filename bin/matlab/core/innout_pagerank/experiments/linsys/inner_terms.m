%% Evaluate the number of terms in the inner-iteration.
% One experiment shows that preconditioning with the inner iteration works
% for bicgstab.  Here, we want to check on how many terms we need!
%

%% Experiment setups
addpath('../../matlab');
addpath('../../libbvg');

%% 
% Setup figures for eps files

    set(0, 'defaultaxesfontsize', 12);
    set(0, 'defaultaxeslinewidth', .7);
    set(0, 'defaultlinelinewidth', .8);
    set(0, 'defaultpatchlinewidth', .7);
    
%%
% Setup figures for png files

    set(0, 'DefaultAxesFontSize', 20)
    set(0, 'DefaultLineMarkerSize', 12);
    
%% Load data
%graph = 'eu-2005';
%graph = 'harvard500';
%graph = 'ubc';
%graph = 'cnr-2000';
graph = 'in-2004';
G = bvgraph(['../../data/' graph]);
A = sparse(G);
P = normout(A);
d = dangling(A);
n = size(P,1);
Asubx = @(x,a,P) x - a*(P'*x);

%% 
% parameters to check
v = ones(n,1)./n;
terms = [0 2 4 7 25];
%betas = 0.2:0.1:0.8;
betas = [0.25 0.5 0.7 0.85];
alphas = [0.99 0.85 0.999];
tol = 1e-7;

%% Run the experiments!

%%
% 
if ~exist('results','var')
    results =[];
end

%%
rnum = 0;
for ai = 1:length(alphas)
    a = alphas(ai);
    for bj = 1:length(betas)
        b = betas(bj);
        for mk = 1:length(terms)
            m = terms(mk);
            
            rnum=rnum+1; % check if we need to run or not
            if rnum<=length(results),  continue; end
            if m==0 && bj>1, fprintf('skipping m=0 again...\n'); continue; end;
            [x flag relres iter resvec] = bicgstabpr(...
                @(x) Asubx(x,a,P), (1-a)*v,...
                sqrt(1-a)*tol,ceil((log(tol)/log(a))/(m+1)),...
                @(x) innerpreP(x,b,P,m));
            
            xpos = all(x>0);
            xnorm = norm(x,1);
            y = x/csum(x);
            z=a*P'*y; w = 1-norm(z,1); z = z + w*v; delta = norm(z-y,1);
            results(rnum).alpha = a;
            results(rnum).beta = b;
            results(rnum).m = m;
            results(rnum).resvec = resvec;
            results(rnum).flag = flag;
            results(rnum).iter = iter;
            results(rnum).relres = relres;
            results(rnum).xpos = xpos;
            results(rnum).xnorm = xnorm;
            results(rnum).delta = delta;
            results(rnum).w = w;
            
            fprintf('a = %5.3f ; b = %4.2f ; m = %2i -- flag = %i in %7i (%7i) matvecs [%1i %8e %8e %8e]\n', ...
                a, b, m, flag, (1+m)*2*iter, (2+m)*2*iter, xpos, xnorm, w, delta);
            
            save(['inner_terms_results-' graph '.mat'],'rnum','results','terms','betas','alphas');
        end
    end
end

%% Format the results
load 'inner_terms_results.mat'

%%
% results for alpha=0.85
niter = zeros(length(terms),length(betas));
estart=[];
for ri=1:length(results)
    a = results(ri).alpha;
    if a~=0.85, continue; end
    if isempty(estart), estart=ri; end
    
    if results(ri).flag ~= 0, continue; end
    niter(ri-estart+1)=(1+results(ri).m)*2*results(ri).iter;
end
%%
% results for alpha=0.99
niter = zeros(length(terms),length(betas));
estart=[];
for ri=1:length(results)
    a = results(ri).alpha;
    if a~=0.99, continue; end
    if isempty(estart), estart=ri; end
    
    if results(ri).flag ~= 0, continue; end
    niter(ri-estart+1)=(1+results(ri).m)*2*results(ri).iter;
end
%%
% results for alpha=0.999
niter = zeros(length(terms),length(betas));
estart=[];
for ri=1:length(results)
    a = results(ri).alpha;
    if a~=0.999, continue; end
    if isempty(estart), estart=ri; end
    
    if results(ri).flag ~= 0, continue; end
    niter(ri-estart+1)=(1+results(ri).m)*2*results(ri).iter;
end
