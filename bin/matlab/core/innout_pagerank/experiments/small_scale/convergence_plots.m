%% Convergence plots for parallel runs
% Based on the parallel runs, we generate convergence plots in terms of
% iterations for the large graphs.

%% Setup
% This experiment should be run from the innout/experiments/inoutgspr directory
cwd = pwd;
dirtail = 'experiments/small_scale'; 
if strcmp(cwd(end-length(dirtail)+1:end),dirtail) == 0
    warning('innout:wrongExperimentDir',...
        '%s should be executed from innout/%s\n', mfilename, dirtail);
end
addpath('../tools');

%% 
% Setup figures for eps files
    set(0, 'defaultaxesfontsize', 12);
    set(0, 'defaultaxeslinewidth', .75);
    set(0, 'defaultlinelinewidth', 1);
    
%%
%graph = 'uk-2007-05';
%graph = 'arabic-2005';
%graph = 'sk-2005';
tol = 1e-7;
graph = 'wb-edu';
methods = {'power','inout'}
%,'gs','inoutgs'};
alpha = 0.99; astr = '99'; xl=[1,1200]; xl2 = [1,50];
%alpha = 0.85; astr = '85'; xl=[1,80]; xl2 = [1 20];

%% Load data
load(['small-scale-results-' astr '.mat']);
allresults = results;
results = [];
for ri=1:length(allresults)
    r = allresults(ri);
    if r.tol ~= tol, continue; end
    if strcmp(r.graph,graph)
        for mi=1:length(methods)
            m = methods(mi);
            if strcmp(r.method,m)
                results(mi).method = m;
                results(mi).nmults = 1:length(r.resids);
                results(mi).resids = r.resids;
                results(mi).alpha = r.alpha;
                results(mi).graph = graph;
            end
        end
    end 
end

%% Plot data
figure(1); clf; hold on; set(gca,'yscale','log'); stys={'k-','k--','g-','g--'};
yl=[1e-7, 1]; xlim(xl); ylim(yl); box on; axis square;
e2=[1 1]; e3=[1 1 1]; line(xl,1e-3*e2,'Color',0.5*e3,'LineWidth',0.75);
line(xl,1e-5*e2,'Color',0.5*e3,'LineWidth',0.75);
hs=[];
for i=1:length(results)
	r=results(i); hs(end+1)=plot(r.nmults, r.resids, stys{i});
end
legend(gca,hs,methods{:}, 'Location', 'SouthWest'); legend boxoff;
ylabel('Residual'); xlabel('Multiplication'); 
title(sprintf('%s, \\alpha = %4.2f\n', r(1).graph, r(1).alpha));
    
axes('position',[.6 .65 .15 .15]); set(gca,'yscale','log'); hold on;
yl=[5e-3, 1]; xlim(xl2); ylim(yl);
for i=1:length(results)
	r=results(i); semilogy(r.nmults, r.resids, stys{i});
end

print(gcf,[graph '-' astr '-conv.eps'],'-depsc2','-cmyk');
saveas(gcf,[graph '-' astr '-conv.fig'],'fig');
