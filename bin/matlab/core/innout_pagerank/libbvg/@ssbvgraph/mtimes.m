function y = mtimes(i1,i2)
% BVGRAPH/MTIMES Implement the matrix-vector multiply for Matlab syntax.
%
% This function implements the G*x, x'*G syntax 
%
% Example:
%   G = bvgraph('data/wb-cs.stanford');
%   x = rand(size(G,1),1);
%   G*x

%
% David Gleich
% 5 February 2008
% Copyright, Stanford University, 2008
%

if (isa(i1,'bvgraph'))
    y = substochastic_mult(i1,i2);
else
    y = substochastic_mult(i2,i1');
    y = y';
end
