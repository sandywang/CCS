%% Parameter search for inner-outer iterations
% The inner-outer iteration introduces two additional parameters

%% Experiment setup
% This experiment should be run from the innout/experiments/parameters directory
cwd = pwd;
dirtail = 'experiments/parameters'; 
if strcmp(cwd(end-length(dirtail)+1:end),dirtail) == 0
    warning('%s should be executed from innout/%s\n', mfilename, dirtail);
end
addpath('../../libbvg');
addpath('../../matlab');

%%
% Setup figures for eps files
    set(0, 'defaultaxesfontsize', 12);
    set(0, 'defaultaxeslinewidth', .75);
    set(0, 'defaultlinelinewidth', 1);

%%
tol = 1e-7; 
maxit = 1500;
alpha = 0.99; astr='99';
etas = [1e-1,1e-2,1e-3,1e-4,1e-5];
betas = linspace(0,0.85,18);

%%
graph = 'in-2004';
datadir = '../../data';
G = bvgraph([datadir filesep graph]);
A = sparse(G);
P = normout(A);
n = size(P,1);

%% Checkpointed experiment run
results = []; 
mresults = [];

%%
rnum = 0;
for bi=1:length(betas)
    beta = betas(bi);
    for ei=1:length(etas)
        eta = etas(ei);
        rnum = rnum+1;
        if rnum<=length(results), continue; end
        fprintf('%25s a=%6.4f b=%6.4f itol=%6e ... ', graph, alpha, beta, eta);
        [x flag hist] = inoutpr(P,alpha,[],tol,maxit,beta,eta);
        
        results(rnum).graph = graph;
        results(rnum).ind = [bi ei];
        results(rnum).beta = beta;
        results(rnum).eta = eta;
        results(rnum).alpha = alpha;
        results(rnum).hist = hist;
        results(rnum).niter = length(hist);
        results(rnum).flag = flag;
        mresults(bi,ei)=length(hist);
        
        save([graph '-' astr '.mat'],'results','mresults','rnum');
    end
end

%% load data

%%
graph = 'eu-2005';
alpha = 0.99; astr = '99';
load([graph '-' astr '.mat']);
%%
graph = 'eu-2005';
alpha = 0.85; astr = '85';
load([graph '-' astr '.mat']);
%%
graph = 'in-2004';
alpha = 0.85; astr = '85';
load([graph '-' astr '.mat']);
%%
graph = 'in-2004';
alpha = 0.99; astr = '99';
load([graph '-' astr '.mat']);

%% Plot
figure(1); clf; hold on;
e2=[1 1]; e3=[e2 1]; xl=[min(betas),max(betas)];
line(xl, e2*mresults(1,1), 'Color', 0.7*e3, 'LineWidth', 0.75);
stys={'kd:','ko--','ks-','kv-','k^-'};
for i=1:length(etas)
    plot(betas,mresults(:,i),stys{i},'MarkerSize',4);
end
xlim(xl); axis square; box on; etasstr=cellstr(num2str(etas','%4.0e'));
etasstr = cellfun(@(x) ['\eta = ' x], etasstr,'UniformOutput',false);
legend('power',etasstr{:},'Location','NorthEast'); 
xlabel('\beta'); ylabel('Multiplications');
title(sprintf('%s, \\alpha=%4.2f', graph, alpha));
saveas(gcf,[graph '-' astr '-betas.fig'],'fig');
print(gcf,[graph '-' astr '-betas.eps'],'-depsc2','-cmyk');

%%
bsubset=[3 7 11 15];
figure(2); clf; hold on;
e2=[1 1]; e3=[e2 1]; xl=[min(etas),max(etas)];
line(xl, e2*mresults(1,1), 'Color', 0.7*e3, 'LineWidth', 0.75);
stys={'kd:','ks-','ko--','kv-'};
for i=1:length(bsubset)
    plot(etas,mresults(bsubset(i),:),stys{i},'MarkerSize',4);
end
xlim(xl); set(gca,'xscale','log'); axis square; box on; 
betasstr = cellstr(num2str(betas(bsubset)','%4.2f'));
betasstr = cellfun(@(x) ['\beta = ' x], betasstr,'UniformOutput',false); 
legend('power',betasstr{:},'Location','NorthEast'); 
xlabel('\eta'); ylabel('Multiplications'); 
title(sprintf('%s, \\alpha=%4.2f', graph, alpha));
saveas(gcf,[graph '-' astr '-etas.fig'],'fig');
print(gcf,[graph '-' astr '-etas.eps'],'-depsc2','-cmyk');