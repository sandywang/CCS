%% Evaluate variants of inner-outer Gauss-Seidel PageRank
% While the inner-outer iteration itself appears to be fairly natural,
% there are quite a few complications that arise when trying to transition
% to a Gauss-Seidel based version.  The key issues are when do we use
% Gauss-Seidel steps and when do we do norms, and are we computing the
% correct answer.  This experiment is designed to evaluate these issues on
% a simple (small) graph.

%% Experiment setup
% This experiment should be run from the innout/experiments/inoutgspr directory
cwd = pwd;
dirtail = 'experiments/inoutgspr'; 
if strcmp(cwd(end-length(dirtail)+1:end),dirtail) == 0
    warning('%s should be executed from innout/%s\n', mfilename, dirtail);
end
addpath('../../libbvg');
addpath('../../matlab');

%% Load the graph and compute an accurate PageRank vector
a = 0.99;

G1 = bvgraph('../../data/wb-cs.stanford');
A1 = sparse(G1); %A1 = A1-diag(diag(A1));
P1 = normout(A1); 
n1 = size(P1,1);
B1 = speye(n1)-a*P1'; b1 = (1-a)*ones(n1,1)./n1;
y = B1\b1;
x1star = y./csum(y);

har500 = load('../../data/harvard500.mat');
G2 = har500.G';
A2 = sparse(G2); A2 = A2-diag(diag(A2));
P2 = normout(A2); 
n2 = size(P2,1);
B2 = speye(n2)-a*P2'; b2 = (1-a)*ones(n2,1)./n2;
y = B2\b2;
x2star = y./csum(y);

%% Compute with Gauss-Seidel
[x1gs flag gshist1] = gspr(P1,a,[],1e-12,1500,true);
[x1gsl flag gslhist1] = gspr_law(P1,a,[],1e-12,1500,true);

[x2gs flag gshist2] = gspr(P2,a,[],1e-12,1500,true);
[x2gsl flag gslhist2] = gspr_law(P2,a,[],1e-12,1500,true);

subplot(2,1,1);
semilogy(1:length(gshist1),gshist1,'.',1:length(gslhist1),gslhist1,'.');
title({'cs-stan',sprintf('converged in %i iterations',length(gslhist1)), ...
       sprintf('error = %8e', norm(x1gs-x1star,1))});
   
subplot(2,1,2);
semilogy(1:length(gshist2),gshist2,'.',1:length(gslhist2),gslhist2,'.');
title({'har500',sprintf('converged in %i iterations',length(gsl2hist)), ...
       sprintf('error = %8e', norm(x2gs-x2star,1))});
   
saveas(gcf,'gspr-csstan-har500-0.99.fig','fig');
print(gcf,'gspr-csstan-har500-0.99.eps','-depsc2');

%% Compute with inner-outer simple variant
[x1igs flag igshist1] = inoutgspr(P1,a,[],1e-7,1500);
[x2igs flag igshist2] = inoutgspr(P2,a,[],1e-7,1500);

subplot(2,1,1);
semilogy(1:length(igshist1),igshist1,'.',1:length(gshist1),gshist1,'.');
title({sprintf('converged in %i iterations',length(igshist1)), ...
       sprintf('error = %8e', norm(x1igs-x1star,1))});
   
subplot(2,1,2);
semilogy(1:length(igshist2),igshist2,'.',1:length(gshist2),gshist2,'.');
title({sprintf('converged in %i iterations',length(igshist2)), ...
       sprintf('error = %8e', norm(x2igs-x2star,1))});

%% Compute with inner-outer simple variant
[x1igs1 flag igs1hist1] = inoutgspr1(P1,a,[],1e-7,1500);
[x2igs1 flag igs1hist2] = inoutgspr1(P2,a,[],1e-7,1500);

subplot(2,1,1);
semilogy(1:length(igs1hist1),igs1hist1,'.',1:length(gshist1),gshist1,'.');
title({sprintf('converged in %i iterations',length(igs1hist1)), ...
       sprintf('error = %8e', norm(x1igs1-x1star,1))});
   
subplot(2,1,2);
semilogy(1:length(igs1hist2),igs1hist2,'.',1:length(gshist2),gshist2,'.');
title({sprintf('converged in %i iterations',length(igs1hist2)), ...
       sprintf('error = %8e', norm(x2igs1-x2star,1))});
   
%% Compute with inner-outer simple variant
[xigs2 flag igs2hist] = inoutgspr2(P,a,[],1e-7,1500);
semilogy(1:length(igs2hist),igs2hist,'.',1:length(gshist),gshist,'.');
title({sprintf('converged in %i iterations',length(igs2hist)), ...
       sprintf('error = %8e', norm(xigs2-xstar,1))});


%% Compute with inner-outer simple variant
[xigs3 flag igs3hist] = inoutgspr3(P,a,[],1e-7,1500);
semilogy(1:length(igs3hist),igs3hist,'.',1:length(gshist),gshist,'.');
title({sprintf('converged in %i iterations',length(igs3hist)), ...
       sprintf('error = %8e', norm(xigs3-xstar,1))});
   
%% Compute with inner-outer simple variant
[xigs4 flag igs4hist] = inoutgspr4(P,a,[],1e-7,1500);
semilogy(1:length(igs4hist),igs4hist,'.',1:length(gshist),gshist,'.');
title({sprintf('converged in %i iterations',length(igs4hist)), ...
       sprintf('error = %8e', norm(xigs4-xstar,1))});
   
%% Compute with inner-outer simple variant
[x1igs5 flag igs5hist1] = inoutgspr5(P1,a,[],1e-7,1500);
[x2igs5 flag igs5hist2] = inoutgspr5(P2,a,[],1e-7,1500);

subplot(2,1,1);
semilogy(1:length(igs5hist1),igs5hist1,'.',1:length(gshist1),gshist1,'.');
title({sprintf('converged in %i iterations',length(igs5hist1)), ...
       sprintf('error = %8e', norm(x1igs5-x1star,1))});
   
subplot(2,1,2);
semilogy(1:length(igs5hist2),igs5hist2,'.',1:length(gshist2),gshist2,'.');
title({sprintf('converged in %i iterations',length(igs5hist2)), ...
       sprintf('error = %8e', norm(x2igs5-x2star,1))});
   
%% Compute with inner-outer simple variant
[x1igs6 flag igs6hist1] = inoutgspr6(P1,a,[],1e-12,1500);
[x2igs6 flag igs6hist2] = inoutgspr6(P2,a,[],1e-12,1500);

subplot(2,1,1);
semilogy(1:length(igs6hist1),igs6hist1,'.',1:length(gshist1),gshist1,'.');
title({sprintf('converged in %i iterations',length(igs6hist1)), ...
       sprintf('error = %8e', norm(x1igs6-x1star,1))});
   
subplot(2,1,2);
semilogy(1:length(igs6hist2),igs6hist2,'.',1:length(gshist2),gshist2,'.');
title({sprintf('converged in %i iterations',length(igs6hist2)), ...
       sprintf('error = %8e', norm(x2igs6-x2star,1))});   
   
%%
% Doesn't work... new ideas?

%% 
   