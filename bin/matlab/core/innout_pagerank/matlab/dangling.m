function dmask = dangling(A)
% DANGLING  Compute the indicator vector for dangling links for webgraph A
% 
%  d = dangling(A)
%

d = full(sum(A,2));
dmask = d == 0;