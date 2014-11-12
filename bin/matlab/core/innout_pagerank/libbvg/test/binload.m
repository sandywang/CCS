function x=binload(filename)
% BINLOAD Load a binary file of doubles
%
% x = binload(filename) loads filename as a list of binary doubles.
%

% David Gleich
% Copyright, Stanford University, 2008

fid=fopen(filename); x=fread(fid,inf,'double'); fclose(fid);