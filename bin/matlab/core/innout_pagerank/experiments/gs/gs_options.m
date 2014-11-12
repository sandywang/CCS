%% Options for the Gauss-Seidel iteration
% We have quite a few options when using the Gauss-Seidel iteration.  For
% example, we can normalize each iterate of the method.  We can look at the
% iterations with and without diagonal terms.  We can look at the error of
% the iteration instead of the norm of the residual (at least, for some
% intuition about what happens).
%
% This experiment tries a few of these ideas on a small graph.

%% Setup the experiment
addpath('../../matlab');
addpath('../../libbvg');
G = bvgraph('../../wb-cs.stanford');
A = sparse(G);
P = normout(A);
n = size(P,1);
maxit = 500; 

%% Look at the full graph with alpha = 0.85
a = 0.85;
B = speye(n)-a*P';
b = (1-a)*ones(n,1)./n;
y = B\b;
xstar = y ./ norm(y,1); % this is the exact solution

[xgs flag ehist1] = gspr(P,a,[],[],[],[],[],[],xstar);
[xgs flag ehist2] = gspr_norm(P,a,[],[],[],[],[],[],xstar);
[xgs flag rhist1] = gspr(P,a);
[xgs flag rhist2] = gspr_norm(P,a);

semilogy(1:length(ehist1),ehist1,'.', ...
         1:length(ehist2),ehist2,'.', ...
         1:length(rhist1),rhist1,'.', ...
         1:length(rhist2),rhist2,'.')
legend('error hist no-norm', 'error hist norm', 'resid hist no-norm', 'resid hist norm');

%% Look at the full graph with alpha = 0.99
a = 0.99;
B = speye(n)-a*P';
b = (1-a)*ones(n,1)./n;
y = B\b;
xstar = y ./ norm(y,1); % this is the exact solution

[xgs flag ehist1] = gspr(P,a,[],[],[],[],[],[],xstar);
[xgs flag ehist2] = gspr_norm(P,a,[],[],[],[],[],[],xstar);
[xgs flag rhist1] = gspr(P,a);
[xgs flag rhist2] = gspr_norm(P,a);

semilogy(1:length(ehist1),ehist1,'.', ...
         1:length(ehist2),ehist2,'.', ...
         1:length(rhist1),rhist1,'.', ...
         1:length(rhist2),rhist2,'.')
legend('error hist no-norm', 'error hist norm', 'resid hist no-norm', 'resid hist norm');
