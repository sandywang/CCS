%% Evaluate preconditioning the linear system
% The previous experiment establishes that the inner-outer viewpoint helps
% stablize iterative methods for the PageRank linear system.
%
% This experiment tries to put the results in context and see which
% iterative methods still work.  The requirement for this test is that the
% iterative method work with only the matrix-vec products and not transpose
% products as well.  
%
% The methods are
%
% * cgs
% * bicgstab
% * gmres 4
%
% We try this on a few graphs, with three values of alpha.
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

%%
% Setup parameters
alphas = [0.85 0.99 0.999];
methods = {'cgs','bicgstab','gmres4'};
nsteps = [0,1,2,7,10,20];
