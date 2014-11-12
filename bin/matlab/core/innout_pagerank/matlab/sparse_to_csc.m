function [cp ri ai]=sparse_to_csr(A,varargin)
% SPARSE_TO_CSR Convert a sparse matrix into compressed column storage arrays
% 
% [cp ri ai] = sparse_to_csc(A) returns the column pointer (cp), row index
% (ri) and value index (ai) arrays of a compressed sparse column 
% representation of the matrix A.
%
% [rp ci ai] = sparse_to_csc(i,j,v,n) returns a csc representation of the
% index sets i,j,v with n rows.
%
% Example:
%   A=sparse(6,6); A(1,1)=5; A(1,5)=2; A(2,3)=-1; A(4,1)=1; A(5,6)=1; 
%   [rp ci ai]=sparse_to_csc(A)
%
% See also SPARSE_TO_CSR

% David Gleich
% Copyright, Stanford University, 2008

% History
% 2008-05-01: Initial version

error(nargchk(1, 4, nargin, 'struct'))
retc = nargout>1; reta = nargout>2;

if nargin>1
    n = varargin{end};
    nzi = A; nzj = varargin{1};
    if reta && length(varargin) > 2, nzv = varargin{2}; end    
    nz = length(A);
    if length(nzi) ~= length(nzj), error('gaimc:invalidInput',...
            'length of nzi (%i) not equal to length of nzj (%i)', nz, ...
            length(nzj)); end
    if reta && length(varargin) < 3, error('gaimc:invalidInput',...
            'no value array passed for triplet input, see usage'); end
    if ~isscalar(n), error('gaimc:invalidInput',...
            ['the final input to sparse_to_csc with triple input was not ' ...
             'a scalar']); end
    [cp ri ai]=sparse_to_csr(varargin{1},A,varargin{2:end});
else
    [cp ri ai]=sparse_to_csr(A');
end