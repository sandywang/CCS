%% Convergence plots for parallel runs
% Based on the parallel runs, we generate convergence plots in terms of
% iterations for the large graphs.

%% Setup
% This experiment should be run from the innout/experiments/inoutgspr directory
cwd = pwd;
dirtail = 'experiments/parallel'; 
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
graph = 'sk-2005';
methods = {'power','inout','gs','inoutgs'};
alpha = 0.99; astr = '99'; xl=[1,1200]; xl2 = [1,50];
alpha = 0.85; astr = '85'; xl=[1,80]; xl2 = [1 20];

%% Load data
results = [];
for mi=1:length(methods)
    m = methods{mi};
    %fn = [graph '-' m '-8.log'];
    if strfind(m, 'gs')
        fn = [m '-' astr '-' graph '.log'];
    else
        fn = [m '-' graph '-' astr '.log'];
    end
    
    [nmults resids dts alpha] = parse_bvpr_log(fn);

    results(end+1).method = m;
    results(end).nmults = nmults;
    results(end).resids = resids;
    results(end).dts = dts;
    results(end).alpha = alpha;
    results(end).graph = graph;
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
