%% Eigenvalues of the PageRank linear system
% This experiment computes the eigenvalues and eigenvectors of the PageRank
% linear system with and without preconditioning.  Clustering of the
% eigenvalues for the preconditioned case indicates that Krylov subspace
% based iterative methods may work better.

%% Experiment setup
addpath('../../matlab');
addpath('../../libbvg');

%% 
% Setup figures for eps files

    set(0, 'defaultaxesfontsize', 12);
    set(0, 'defaultaxeslinewidth', .7);
    set(0, 'defaultlinelinewidth', .8);
    set(0, 'defaultpatchlinewidth', .7);

%% Load graph
datadir = '../../data';
graphfile = 'wb-cs.stanford';
%graphfile = 'harvard500';
G = bvgraph([datadir filesep graphfile]);
A = sparse(G);
P = normout(A);

%% Compute eigenvalues and save
evals = eig(full(P));
save ([graphfile '-evals.mat'],'evals');

%% Load eigenvalues
load([graphfile '-evals.mat']);
d = evals;

%% plot
a = 0.99;
ms = [0 2 4 7 100];
bs = [0.5 0.7 0.85];
d = evals;
f = @(tt) tt;
g = @(tt,a,b) (1-a*tt)./(1-b*tt);
h = @(tt,a,b,m) innerpre_eval_func(tt,a,b,m);
ncontours = 4;
border = 0.05;

%%
figure(1); clf;
for bi = 1:length(bs)
    b = bs(bi);
    for mi = 1:length(ms)
        m = ms(mi);
        [spa p] = subplot3(length(bs),length(ms),bi,mi,border);
        cla; hold on;
        tt = exp(j*2*pi*(0:0.002:1));
        for ci=ncontours:-1:1
           %gt = g((ci/ncontours)*tt,a,b);
           gt = h((ci/ncontours)*tt,a,b,m);
           plot(real(gt),imag(gt),'-','Color',[0.5 0.5 0.5],'LineWidth',0.7);
        end
        plot(1+real(tt),imag(tt),'k--');
        plot(h(d,a,b,m),'k.','MarkerSize',6);
        xlim([0,2]); ylim([-1,1]); axis square; axis off;
    end
end
axes('position',[0 0 1 1]); axis off;
nl = length(ms);
for mi = 1:nl
    s = sprintf('m = %i', ms(mi));
    if (ms(mi)>99), s=sprintf('m = \\infty'); end
    wf = (1-border*2)/nl;
    w = wf-0.5*wf/nl;
    text(0.05+w/2+(mi-1)*wf,0.02,s,'HorizontalAlignment','center');
end
nl = length(bs);
for bi = 1:nl
    s = sprintf('\\beta = %4.2f', bs(bi));
    wf = (1-border*2)/nl;
    w = wf-0.5*wf/nl;
    th=text(0.02,0.05+w/2+(bi-1)*wf,s,'HorizontalAlignment','center','Rotation',90);
end
print(gcf,['inoutpre-evals-' graphfile '.eps'],'-depsc2');

%%
figure(1); clf;
for bi = 1:length(bs)
    b = bs(bi);
    for mi = 1:length(ms)
        m = ms(mi);
        [spa p] = subplot3(length(bs),length(ms),bi,mi,border);
        cla; hold on;
        tt = exp(j*2*pi*(0:0.002:1));
        for ci=ncontours:-1:1
           %gt = g((ci/ncontours)*tt,a,b);
           %gt = h((1-1e-6)*(ci/ncontours)*tt,a,b,m);
           gt = h((ci/ncontours)*tt,a,b,m);
           plot(real(gt),imag(gt),'-','Color',[0.6 0.6 0.6],'LineWidth',0.7);
        end
        plot(1+real(tt),imag(tt),'k--');
        plot(h(d,a,b,m),'k.','MarkerSize',3);
        xlim([0,2]); ylim([-1,1]); axis square; axis off;
    end
end
axes('position',[0 0 1 1]); axis off;
nl = length(ms);
for mi = 1:nl
    s = sprintf('m = %i', ms(mi));
    if (ms(mi)>99), s=sprintf('m = \\infty'); end
    wf = (1-border*2)/nl;
    w = wf-0.5*wf/nl;
    text(0.05+w/2+(mi-1)*wf,0.02,s,'HorizontalAlignment','center');
end
nl = length(bs);
for bi = 1:nl
    s = sprintf('\\beta = %4.2f', bs(bi));
    wf = (1-border*2)/nl;
    w = wf-0.5*wf/nl;
    th=text(0.02,0.05+w/2+(bi-1)*wf,s,'HorizontalAlignment','center','Rotation',90);
end
print(gcf,['inoutpre-evals-tiny-' graphfile '.eps'],'-depsc2');
