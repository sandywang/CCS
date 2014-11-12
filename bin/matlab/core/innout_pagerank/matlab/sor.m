function [x,flag,relres,iter,resvec]=sor(A,b,omega,optionsu)
% SOR SOR Method for solving linear systems iteratively
% x = sor(A,b,w) attemps to solve the system of linear equations Ax=b for X.
% The matrix A must be square and the right hand side must have an
% appropriate length.  The matrix A cannot be singular.  The value omega is
% used in the SOR method, 0 <= omega <= 2.  
%
% [x,flag,relres,iter,resvec]=sor(A,b,w) returns additional data generated
% while solving the method.  If flag=0, then the method converged with
% relative residual relres at iteration iter, resvec is the vector of
% residual norms throughout the computation, divide these by norm(b) to get
% the relative residual.
%
% [...] = sor(A,b,omega,options) sets optional parameters for the method.
% options.tol: the stopping tolerance [double | {1e-8}]
% options.maxiter: maximum number of iterations [integer | {1000}]
% options.verbose: extra output information [{0} | 1]
% options.x0: starting vector [vector | zeros(n,1)]
%
% Example:
%    n = 100; e = ones(n,1); 
%    A = spdiags([e -2*e e], -1:1, n, n);
%    b = zeros(n,1); b(1) = -1; b(n) = 1;
%    x = sor(A,b,1.8,struct('tol', 1e-8));

[m n] = size(A);
if (m ~= n)
    error('sor:invalidParameter','the matrix must be square');
end;

if (length(b) ~= n)
    error('sor:invalidParameter','the size of b must match A');
end;

if (omega > 2 || omega < 0)
    error('sor:invalidParameter','0 <= omega <= 2');
end;

options = struct('tol', 1e-8, 'maxiter', 1000, 'verbose', 0, ...
    'x0', zeros(n,1), 'norm', 2);
if (exist('optionsu','var'))
    %options = merge_structs(optionsu,options);
    if isfield(optionsu,'verbose')
        options.verbose = optionsu.verbose;
    end
    if isfield(optionsu,'tol')
        options.tol = optionsu.tol;
    end
    if isfield(optionsu,'maxiter')
        options.maxiter= optionsu.maxiter;
    end
    if isfield(optionsu,'x0')
        options.x0 = optionsu.x0;
    end
    if isfield(optionsu,'norm')
        options.norm = optionsu.norm;
    end
end;

x = options.x0;
tol = options.tol;
maxiter = options.maxiter;
verbose = options.verbose;
w = omega;

resvec = zeros(maxiter+1,1);
resvec(1) = norm(b - A*x);
iter = 1;
delta = 1;
flag = 1;

% store the norm of b
nb = norm(b,options.norm);

% store some information for slightly faster lookup
d = diag(A);

if (any(abs(d) < eps(1)/10000))
    error('sor:failure','the matrix A cannot have a 0 on the diagonal (try dmperm(A)!)');
end;

% it's always faster to work with A' as SOR proceeds by rows, but Matlab
% stores things by column
At = A';

% making this modification means that we only have to look at dot products
% with columns of A because the diagonals are stored in the vector d.
%At = At - diag(diag(A));

%
% make hard copies of all quantities in SOR
%
x(1) = x(1) + 1;
x(1) = x(1) - 1;

b(1) = b(1) + 1;
b(1) = b(1) - 1;

w = w + 1;
w = w - 1;

if (verbose)
    fprintf(' Iter     RelRes   \n');
    fprintf('------  ---------- \n');
end;
    
while (iter < maxiter)
    
    sor_iter_mex(At,x,b,w);
    
%     for ii=1:n
%         x(ii) = w*(b(ii) - At(:,ii)'*x)/d(ii) + (1 - w)*x(ii);
%     end;
    
    iter = iter+1;
    
    resvec(iter) = norm(b-A*x,options.norm);
    delta = resvec(iter)/nb;
    
    if (verbose)
        fprintf('%6i  %0.3e\n', iter, delta);
    end;
    
    % check for breakdown
    if (any(~isfinite(x)))
        flag = 4;
        break;
    end;
    
    if (delta < tol)
        break;
    end;
end

if (flag == 1 && delta < tol)
    flag = 0;
end

relres = delta;