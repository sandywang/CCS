%% Generate table for the runtime and nmult tables

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
alpha = 0.99; astr = '85';
load(['small-scale-results-' astr '.mat']);
methods = {'power','inout'}; mref = 1; mtest = 3;
taus = [1e-3, 1e-5, 1e-7];
graphs = {'ubc-cs', 'ubc', 'in-2004', 'eu-2005', 'wb-edu'};

%% Print
spd = @(r,s) 100*(r-s)/r;
for ti=1:length(taus)
    for gi=1:length(graphs)
        fprintf('& %22s ', ['\dataname{' graphs{gi} '}']);
        fprintf('& %5i & %8i & %4.1f\\%%  ', ...
            iterresults(gi,ti,mref), iterresults(gi,ti,mtest), ...
            spd(iterresults(gi,ti,mref), iterresults(gi,ti,mtest)));
        fprintf('& %7.1f & %7.1f     & %4.1f\\%% \\\\ \n', ...
            timeresults(gi,ti,mref), timeresults(gi,ti,3), ...
            spd(timeresults(gi,ti,mref), timeresults(gi,ti,mtest)));
    end
    fprintf('\n\n');
end
