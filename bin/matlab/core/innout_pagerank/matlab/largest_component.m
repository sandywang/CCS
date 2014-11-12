function [Ac,p]=largest_component(A)
% LARGEST_COMPONENT Largest strongly connected component from a matrix/graph
%
% Ac=largest_component(A) returns a submatrix of A corresponding to the
% largest strongly connected component of the matrix A viewed as the
% adjacency matrix of a graph G.  
%
% [Ac,p]=... returns a logical partition vector indicating the elements
% extracted in the submatrix.

[cc,ccsize]=scomponents(A);
[maxcc,maxccind]=max(ccsize);
p=cc==maxccind;
Ac=A(p,p);
