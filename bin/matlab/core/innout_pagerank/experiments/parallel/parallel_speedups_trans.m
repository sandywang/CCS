%% Parallel speedup plots
% Speedup plots generated from the parallel runs and the best serial times.

%% Setup
% This experiment should be run from the innout/experiments/parallel
% directory
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
graphs = {'uk-2007-05', 'sk-2005', 'arabic-2005'};
%graphs = {'uk-2007-05','arabic-2005'};
methods = {'power-trans','inout-trans'};
nprocs = [1 4 6 8];

%% Load data
results = [];
resultindex = [];
for gi = 1:length(graphs)
    graph = graphs{gi};
    for mi = 1:length(methods)
        m = methods{mi};
        for npi = 1:length(nprocs)
            np = nprocs(npi);
            npstr = num2str(np);

            fn = [graph '-' m '-' npstr '.log'];
            if ~isempty(strfind(m, 'trans'))
                mnt = strrep(m,'-trans','');
                fn = [graph '-' mnt '-' npstr '-trans.log'];
            end
            
            [nmults resids dts alpha] = parse_bvpr_log(fn);

            results(end+1).method = m;
            results(end).nmults = nmults;
            results(end).resids = resids;
            results(end).dts = dts;
            results(end).alpha = alpha;
            results(end).graph = graph;
            results(end).np = np;
            resultindex(gi,mi,npi) = length(results);
        end
    end
end

%% Create reference values
tols = [1e-3 1e-5 1e-7];
refdts = zeros(length(graphs), length(methods), length(tols));
extramethods = {'gs','inoutgs'};
extramethodsdir = ['..' filesep 'large_scale'];
astr = '99';
for gi = 1:length(graphs)
    graph = graphs{gi};
    for ti = 1:length(tols)
        tol = tols(ti);
        refdt = Inf;
        for mi = 1:length(methods)
            ri = resultindex(gi,mi,1);
            nmi = find(results(ri).resids<tol, 1, 'first');
            dt = results(ri).dts(nmi);
            if dt<refdt, refdt=dt; end
        end
        for emi = 1:length(extramethods)
            fn = [extramethods{emi} '-' astr '-' graph '.log'];
            fn = [extramethodsdir filesep fn];
            [nmults resids dts alpha] = parse_bvpr_log(fn);
            nmi = find(resids<tol, 1, 'first');
            dt = dts(nmi);
            if dt<refdt, refdt=dt; end
        end
        refdts(gi, :, ti) = refdt;
    end
end      

%% Plot the data
figure(2); clf; hold on; tstys = {'ko', 'kd', 'k*'}; mstys = {'-', '--'}; 
lhs=[]; rlhs=[]; xl = [min(nprocs), max(nprocs)]; e2=[1 1]; e3=[e2 1];
lhs(end+1) = line(xl,xl,'Color',0.5*e3,'LineWidth',0.75);
for gi = 1:length(graphs)
    for ti = 1:length(tols)
        tol = tols(ti);
        for mi = 1:length(methods)
            dts = [];
            for npi = 1:length(nprocs)
                ri = resultindex(gi,mi,npi);
                nmi = find(results(ri).resids<tol, 1, 'first');
                dts(end+1) = results(ri).dts(nmi);
            end
            %dts = refdts(gi, mi, ti)./dts;
            dts = dts(1)./dts;
            rlhs(mi) = plot(nprocs,dts, '-' ,'Color',0.75*[mi-1 1 1],'LineWidth',2); 
        end
    end
end
for gi = 1:length(graphs)
    for ti = 1:length(tols)
        tol = tols(ti);
        for mi = 1:length(methods)
            dts = [];
            for npi = 1:length(nprocs)
                ri = resultindex(gi,mi,npi);
                nmi = find(results(ri).resids<tol, 1, 'first');
                dts(end+1) = results(ri).dts(nmi);
            end
            dts = refdts(gi, mi, ti)./dts;
            lhs(end+1)=plot(nprocs,dts,[tstys{ti} mstys{mi}],'MarkerSize',4);
        end
    end
end

box on; xlim(xl); axis square;
xlabel('Number of processors'); ylabel('Speedup relative to best 1 processor');
legend([lhs(1) rlhs lhs(2:end)], 'linear', ...
    'power relative', 'inout relative', ...
    '1e-3 power', '1e-3 inout', '1e-5 power', '1e-5 inout', ...
    '1e-7 power', '1e-7 inout', 'Location', 'NorthWest'); legend boxoff;

saveas(gcf,['parallel-speedup-trans-ratio.fig'],'fig');
print(gcf,['parallel-speedup-trans-ratio.eps'],'-depsc2','-cmyk');        

%% Plot the data with small axes
figure(3); clf; hold on; tstys = {'ko', 'kd', 'k*'}; mstys = {'-', '--'}; 
lhs=[]; rlhs=[]; xl = [min(nprocs), max(nprocs)]; e2=[1 1]; e3=[e2 1];
lhs(end+1) = line(xl,xl,'Color',0.5*e3,'LineWidth',0.75);
for gi = 1:length(graphs)
    for ti = 1:length(tols)
        tol = tols(ti);
        for mi = 1:length(methods)
            dts = [];
            for npi = 1:length(nprocs)
                ri = resultindex(gi,mi,npi);
                nmi = find(results(ri).resids<tol, 1, 'first');
                dts(end+1) = results(ri).dts(nmi);
            end
            %dts = refdts(gi, mi, ti)./dts;
            dts = dts(1)./dts;
            rlhs(mi) = plot(nprocs,dts, '-' ,'Color',0.75*[mi-1 1 1],'LineWidth',2); 
        end
    end
end
for gi = 1:length(graphs)
    for ti = 1:length(tols)
        tol = tols(ti);
        for mi = 1:length(methods)
            dts = [];
            for npi = 1:length(nprocs)
                ri = resultindex(gi,mi,npi);
                nmi = find(results(ri).resids<tol, 1, 'first');
                dts(end+1) = results(ri).dts(nmi);
            end
            dts = refdts(gi, mi, ti)./dts;
            lhs(end+1)=plot(nprocs,dts,[tstys{ti} mstys{mi}],'MarkerSize',4);
        end
    end
end

box on; xlim(xl); axis square;
xlabel('Number of processors'); ylabel('Speedup relative to best 1 processor');
legend([lhs(1) rlhs lhs(2:end)], 'linear', ...
    'power relative', 'inout relative', ...
    '1e-3 power', '1e-3 inout', '1e-5 power', '1e-5 inout', ...
    '1e-7 power', '1e-7 inout', 'Location', 'NorthWest'); legend boxoff;

axes('position',[.85 .15 .025 .7]); hold on;
xlim([7.8 8]); ylim([2 4]);
for gi = 1:length(graphs)
    for ti = 1:length(tols)
        tol = tols(ti);
        for mi = 1:length(methods)
            dts = [];
            for npi = 1:length(nprocs)
                ri = resultindex(gi,mi,npi);
                nmi = find(results(ri).resids<tol, 1, 'first');
                dts(end+1) = results(ri).dts(nmi);
            end
            %dts = refdts(gi, mi, ti)./dts;
            dts = dts(1)./dts;
            plot(nprocs,dts, '-' ,'Color',0.75*[mi-1 1 1],'LineWidth',2); 
        end
    end
end
for gi = 1:length(graphs)
    for ti = 1:length(tols)
        tol = tols(ti);
        for mi = 1:length(methods)
            dts = [];
            for npi = 1:length(nprocs)
                ri = resultindex(gi,mi,npi);
                nmi = find(results(ri).resids<tol, 1, 'first');
                dts(end+1) = results(ri).dts(nmi);
            end
            dts = refdts(gi, mi, ti)./dts;
            lhs(end+1)=plot(nprocs,dts,[tstys{ti} mstys{mi}],'MarkerSize',4);
        end
    end
end
set(gca,'YTick',[2 3 4]); set(gca,'XTick',8);
saveas(gcf,['parallel-speedup-trans-ratio-fancy.fig'],'fig');
print(gcf,['parallel-speedup-trans-ratio-fancy.eps'],'-depsc2','-cmyk');    
    