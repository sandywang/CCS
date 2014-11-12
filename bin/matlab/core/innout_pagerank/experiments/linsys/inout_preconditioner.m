%% Examine the inner-outer scheme for preconditioning
% Krylov methods for PageRank can be fast, but they suffer from a few
% breakdown conditions.  The Sparse Linear System PageRank guys (ask.com, I
% think) and Debora Donato show that ilu works well as a preconditioner.
% But ilu requires mucking with the matrix structure and that is something
% we like to avoid for large problems.
%
% Here, we investigate using the inner-outer iteration as a preconditioner
% instead.

%% Summary
% The consensus from this experiment is that the system 
%
% $$ (I - \alpha P) x = (1-a) v $$
% 
% diverges with the bicgstab iteration.  The matrix $P$ is fully
% column stochastic.  If we use the real PageRank linear system 
%
% $$ (I - \alpha \bar{P}) x = (1-a) v $$
%
% for a substoachastic $\bar{P}$ then the bicgstab iteration still
% diverges.  
%
% However, preconditioning the second system with the Neumann series 
%
% $$ (I - \beta \bar{P})^{-1} \approx I + \beta \bar{P} + \cdots + (\beta
% \bar{P})^m $$
%
% works, even with $m=1$!
%
% This idea does not appear to work for the first iteration.
%
% Although the following code only demonstrates this idea for the cnr-2000
% matrix, we verified it by using wb-stanford and wb-cs.stanford as well.

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

%     set(0, 'DefaultAxesFontSize', 20)
%     set(0, 'DefaultLineMarkerSize', 12);

%% Load data
G = bvgraph('../../data/cnr-2000');
A = sparse(G);
P = normout(A);
d = dangling(A);
n = size(P,1);
Px = @(x,P,d,v) P'*x + (d'*x)*v;

%% Solve the exact system
a = 0.99;
v = ones(n,1)./n;
B = speye(n)-a*P';
y = B\v;
xtrue = y/csum(y);

%% Test the bicgstab algorithm
Ax = @(x,a,P,d,v) x - a*(P'*x) - a*(d'*x)*v;
[x flag relres iter resvec] = bicgstab(@(x) Ax(x,a,P,d,v),(1-a)*v,1e-8,1500);
semilogy(resvec);
% This didn't converge

%%
Asubx = @(x,a,P) x - a*(P'*x);
[x flag relres iter resvecsub] = bicgstab(@(x) Asubx(x,a,P),(1-a)*v,1e-8,1500);
semilogy(resvecsub); title(sprintf('Asub bicgstab, a = %4f', a));
% This didn't converge either

%% Test the preconditioned bicgstab algorithm

%% 
% First test, one step of preconditioning, use 
%
% $$I + \beta P$$
% 
% as the preconditioner...
[x flag relres iter resvec1] = bicgstab(@(x) Ax(x,a,P,d,v), (1-a)*v,1e-8,750,...
    @(x) innerpre(x,0.5,@(x) Px(x,P,d,v),1));
semilogy(1:length(resvec1),resvec1,'.-',1:length(resvec),resvec,'.-'); 
title(sprintf('bicgstab on A with 1-step preconditioner, a = %4f', a));
legend('1-terms','no preconditioning');

%% 
% Second test, two steps of preconditioning, use 
%
% $$I + \beta P + (\beta  P)^2$$
% 
% as the preconditioner...
[x flag relres iter resvec2] = bicgstab(@(x) Ax(x,a,P,d,v), (1-a)*v,1e-8,500,...
    @(x) innerpre(x,0.5,@(x) Px(x,P,d,v),2));
semilogy(1:length(resvec2),resvec2,'.-',1:length(resvec),resvec,'.-'); 
title(sprintf('bicgstab on A with 2-step preconditioner, a = %4f', a));
legend('2-terms','no preconditioning');

%%
% Third test, many steps of preconditioning, use 
%
% $$ I + \beta P + ... + (\beta P)^20 $$
%
% as the preconditioner...
[x flag relres iter resvec20] = bicgstab(@(x) Ax(x,a,P,d,v), (1-a)*v,1e-8,150,...
    @(x) innerpre(x,0.5,@(x) Px(x,P,d,v),20));
semilogy(1:length(resvec20),resvec20,'.-',1:length(resvec),resvec,'.-'); 
title(sprintf('bicgstab on A with 20-step preconditioner, a = %4f', a));
legend('20-terms','no preconditioning');

%%
% Summarize in one plot!
semilogy(1:length(resvec),resvec,'.-', ...
         1:length(resvec1),resvec1,'.-', ...
         1:length(resvec2),resvec2,'.-', ...
         1:length(resvec20),resvec20,'.-'); 
title(sprintf('bicgstab on A with and without preconditioner, a = %4f', a));
legend('no preconditioning','1-term','2-terms','20-terms');


%% Test the preconditioned alg on the sub-stochastic matrix
% Well, none of the previous tests work.  Let's try the substochastic
% matrix $\bar{P}$ instead.

%% 
% First test, one step of preconditioning, use 
%
% $$I + \beta \bar{P}$$
% 
% as the preconditioner...
[x flag relres iter resvecsub1] = bicgstab(@(x) Asubx(x,a,P), (1-a)*v,1e-8,750,...
    @(x) innerpre(x,0.5,P',1));
semilogy(1:length(resvecsub1),resvecsub1,'.-',1:length(resvecsub),resvecsub,'.-'); 
title(sprintf('bicgstab on Asub with 1-step preconditioner, a = %4f', a));
legend('1-terms','no preconditioning');

%% 
% Second test, two steps of preconditioning, use 
%
% $$I + \beta \bar{P} + (\beta  \bar{P})^2$$
% 
% as the preconditioner...
[x flag relres iter resvecsub2] = bicgstab(@(x) Asubx(x,a,P), (1-a)*v,1e-8,500,...
    @(x) innerpre(x,0.5,P',2));
semilogy(1:length(resvecsub2),resvecsub2,'.-',1:length(resvecsub),resvecsub,'.-'); 
title(sprintf('bicgstab on Asub with 2-step preconditioner, a = %4f', a));
legend('2-terms','no preconditioning');

%%
% Third test, many steps of preconditioning, use 
%
% $$ I + \beta \bar{P} + ... + (\beta \bar{P})^20 $$
%
% as the preconditioner...
[x flag relres iter resvecsub20] = bicgstab(@(x) Asubx(x,a,P), (1-a)*v,1e-8,150,...
    @(x) innerpre(x,0.5,P',20));
semilogy(1:length(resvecsub20),resvecsub20,'.-',1:length(resvecsub),resvecsub,'.-'); 
title(sprintf('bicgstab on Asub with 20-step preconditioner, a = %4f', a));
legend('20-terms','no preconditioning');

%%
% Summarize in one plot!
semilogy(1:length(resvecsub),resvecsub,'.-', ...
         1:length(resvecsub1),resvecsub1,'.-', ...
         1:length(resvecsub2),resvecsub2,'.-', ...
         1:length(resvecsub20),resvecsub20,'.-'); 
title(sprintf('bicgstab on Asub with and without preconditioner, a = %4f', a));
legend('no preconditioning','1-term','2-terms','20-terms');
