%% Generate table for the runtime and nmult tables

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
graphs = {'arabic-2005', 'sk-2005', 'uk-2007-05'};
methods = {'gs','inoutgs'};
taus = [1e-3, 1e-7];
alpha = 0.85; astr = '85';
alpha = 0.99; astr = '99';

%%
results = []; %zeros(length(graphs), length(methods), length(taus));
for gi=1:length(graphs)
    graph = graphs{gi};
    for mi=1:length(methods)
        m = methods{mi};
        %fn = [graph '-' m '-8.log'];
        fn = [m '-' astr '-' graph '.log'];
    
        [nmults resids dts alpha] = parse_bvpr_log(fn);
        
        for ti=1:length(taus)
            ii=find(resids<taus(ti),1,'first');
            results(gi,mi,ti).nmult = nmults(ii);
            results(gi,mi,ti).dt = dts(ii);
        end
    end
end
%% Print
spd = @(r,s) 100*(r-s)/r;
for ti=1:length(taus)
    for gi=1:length(graphs)
        fprintf('& %22s ', ['\dataname{' graphs{gi} '}']);
        fprintf('& %5i & %8i & %4.1f\\%%  ', ...
            results(gi,1,ti).nmult, results(gi,2,ti).nmult, ...
            spd(results(gi,1,ti).nmult,results(gi,2,ti).nmult));
        fprintf('& %7.1f & %7.1f     & %4.1f\\%% \\\\ \n', ...
            results(gi,1,ti).dt, results(gi,2,ti).dt, ...
            spd(results(gi,1,ti).dt,results(gi,2,ti).dt));
    end
    fprintf('\n\n');
end
