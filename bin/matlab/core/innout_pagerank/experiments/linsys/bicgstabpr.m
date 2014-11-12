function [x,flag,relres,iter,resvec] = bicgstab(A,b,tol,maxit,M1,M2,x0,varargin)
%BICGSTAB   BiConjugate Gradients Stabilized Method.
%   X = BICGSTAB(A,B) attempts to solve the system of linear equations
%   A*X=B for X. The N-by-N coefficient matrix A must be square and the
%   right hand side column vector B must have length N.%
%
% NOTE: This version was modified by David Gleich to compute 1-norm
% residuals and keep track of the total number of matrix vector products
% explicitly.
%
%   X = BICGSTAB(AFUN,B) accepts a function handle AFUN instead of the
%   matrix A. AFUN(X) accepts a vector input X and returns the
%   matrix-vector product A*X. In all of the following syntaxes, you can
%   replace A by AFUN.
%
%   X = BICGSTAB(A,B,TOL) specifies the tolerance of the method. If TOL is
%   [] then BICGSTAB uses the default, 1e-6.
%
%   X = BICGSTAB(A,B,TOL,MAXIT) specifies the maximum number of iterations.
%   If MAXIT is [] then BICGSTAB uses the default, min(N,20).
%
%   X = BICGSTAB(A,B,TOL,MAXIT,M) and X = BICGSTAB(A,B,TOL,MAXIT,M1,M2) use
%   preconditioner M or M=M1*M2 and effectively solve the system
%   inv(M)*A*X = inv(M)*B for X. If M is [] then a preconditioner is not
%   applied. M may be a function handle returning M\X.
%
%   X = BICGSTAB(A,B,TOL,MAXIT,M1,M2,X0) specifies the initial guess.  If
%   X0 is [] then BICGSTAB uses the default, an all zero vector.
%
%   [X,FLAG] = BICGSTAB(A,B,...) also returns a convergence FLAG:
%    0 BICGSTAB converged to the desired tolerance TOL within MAXIT iterations.
%    1 BICGSTAB iterated MAXIT times but did not converge.
%    2 preconditioner M was ill-conditioned.
%    3 BICGSTAB stagnated (two consecutive iterates were the same).
%    4 one of the scalar quantities calculated during BICGSTAB became
%      too small or too large to continue computing.
%
%   [X,FLAG,RELRES] = BICGSTAB(A,B,...) also returns the relative residual
%   NORM(B-A*X)/NORM(B). If FLAG is 0, then RELRES <= TOL.
%
%   [X,FLAG,RELRES,ITER] = BICGSTAB(A,B,...) also returns the iteration
%   number at which X was computed: 0 <= ITER <= MAXIT. ITER may be an
%   integer + 0.5, indicating convergence half way through an iteration.
%
%   [X,FLAG,RELRES,ITER,RESVEC] = BICGSTAB(A,B,...) also returns a vector
%   of the residual norms at each half iteration, including NORM(B-A*X0).
%
% NOTE: For entry 1 in resvec, it takes 1 matvec product (just a residual),
% for entry 2, it takes one solve with M1 and M2, and then 1 matvec with A
% for the iteration and 1 matvec for the residual computation. 
% For entry 3, it takes another solve with M1 and M2, then another 1 matvec
% for the iteration and another matvec for the residual.  Consequently, the
% total number of matvecs (including residual) are
% 1:2+m:(2+m)*length(resvec)+1
% and excluding residual are
% 1:1+m:(1+m)*length(resvec)+1
% where m is the number of effective matvecs to do the solve with M1 and
% M2.
%
%   Example:
%      n = 21; A = gallery('wilk',n);  b = sum(A,2);
%      tol = 1e-12;  maxit = 15; M = diag([10:-1:1 1 1:10]);
%      x = bicgstab(A,b,tol,maxit,M);
%   Or, use this matrix-vector product function
%      %-----------------------------------------------------------------%
%      function y = afun(x,n)
%      y = [0; x(1:n-1)] + [((n-1)/2:-1:0)'; (1:(n-1)/2)'].*x+[x(2:n); 0];
%      %-----------------------------------------------------------------%
%   and this preconditioner backsolve function
%      %------------------------------------------%
%      function y = mfun(r,n)
%      y = r ./ [((n-1)/2:-1:1)'; 1; (1:(n-1)/2)'];
%      %------------------------------------------%
%   as inputs to BICGSTAB:
%      x1 = bicgstab(@(x)afun(x,n),b,tol,maxit,@(x)mfun(x,n));
%
%   Class support for inputs A,B,M1,M2,X0 and the output of AFUN:
%      float: double
%
%   See also BICG, CGS, GMRES, LSQR, MINRES, PCG, QMR, SYMMLQ, LUINC,
%   FUNCTION_HANDLE.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.19.4.2 $ $Date: 2004/12/06 16:35:17 $

% Check for an acceptable number of input arguments
if nargin < 2
   error('MATLAB:bicgstab:NotEnoughInputs', 'Not enough input arguments.');
end

% Determine whether A is a matrix or a function.
[atype,afun,afcnstr] = iterchk(A);
if strcmp(atype,'matrix')
   % Check matrix and right hand side vector inputs have appropriate sizes
   [m,n] = size(A);
   if (m ~= n)
      error('MATLAB:bicgstab:NonSquareMatrix','Matrix must be square.');
   end
   if ~isequal(size(b),[m,1])
      error('MATLAB:bicgstab:RSHsizeMatchCoeffMatrix', ...
         ['Right hand side must be a column vector of' ...
         ' length %d to match the coefficient matrix.'],m);
   end
else
   m = size(b,1);
   n = m;
   if ~isvector(b) || (size(b,2) ~= 1) % if ~isvector(b,'column')
      error('MATLAB:bicgstab:RSHnotColumn',...
         'Right hand side must be a column vector.');
   end
end

% Assign default values to unspecified parameters
if nargin < 3 || isempty(tol)
   tol = 1e-6;
end
if nargin < 4 || isempty(maxit)
   maxit = min(n,20);
end

% Check for all zero right hand side vector => all zero solution
n2b = norm(b);                      % Norm of rhs vector, b
if (n2b == 0)                       % if    rhs vector is all zeros
   x = zeros(n,1);                  % then  solution is all zeros
   flag = 0;                        % a valid solution has been obtained
   relres = 0;                      % the relative residual is actually 0/0
   iter = 0;                        % no iterations need be performed
   resvec = 0;                      % resvec(1) = norm(b-A*x) = norm(0)
   if (nargout < 2)
      itermsg('bicgstab',tol,maxit,0,flag,iter,NaN);
   end
   return
end

n1b = norm(b,1);

if ((nargin >= 5) && ~isempty(M1))
   existM1 = 1;
   [m1type,m1fun,m1fcnstr] = iterchk(M1);
   if strcmp(m1type,'matrix')
      if ~isequal(size(M1),[m,m])
         error('MATLAB:bicgstab:WrongPrecondSize', ...
            ['Preconditioner must be a square matrix' ...
            ' of size %d to match the problem size.'],m);
      end
   end
else
   existM1 = 0;
   m1type = 'matrix';
end

if ((nargin >= 6) && ~isempty(M2))
   existM2 = 1;
   [m2type,m2fun,m2fcnstr] = iterchk(M2);
   if strcmp(m2type,'matrix')
      if ~isequal(size(M2),[m,m])
         error('MATLAB:bicgstab:WrongPrecondSize', ...
            ['Preconditioner must be a square matrix' ...
            ' of size %d to match the problem size.'],m);
      end
   end
else
   existM2 = 0;
   m2type = 'matrix';
end

if ((nargin >= 7) && ~isempty(x0))
   if ~isequal(size(x0),[n,1])
      error('MATLAB:bicgstab:WrongInitGuessSize', ...
         ['Initial guess must be a column vector of' ...
         ' length %d to match the problem size.'],n);
   else
      x = x0;
   end
else
   x = zeros(n,1);
end

if ((nargin > 7) && strcmp(atype,'matrix') && ...
      strcmp(m1type,'matrix') && strcmp(m2type,'matrix'))
   error('MATLAB:bicgstab:TooManyInputs', 'Too many input arguments.');
end

% Set up for the method
flag = 1;
xmin = x;                          % Iterate which has minimal residual so far
imin = 0;                          % Iteration at which xmin was computed
tolb = tol;                        % CHANGE TO ABSOLUTE TOLERANCE
%tolb = tol * n2b;                  % Relative tolerance
r = b - iterapp('mtimes',afun,atype,afcnstr,x,varargin{:});
normr = norm(r);                   % Norm of residual
normr1 = norm(r,1);

if (normr1 <= tolb)                 % Initial guess is a good enough solution
   flag = 0;
   relres = normr1;
   iter = 0;
   resvec = normr1;
   if (nargout < 2)
      itermsg('bicgstab',tol,maxit,0,flag,iter,relres);
   end
   return
end

rt = r;                            % Shadow residual
resvec = zeros(2*maxit+1,1);       % Preallocate vector for norm of residuals
resvec(1) = normr1;                 % resvec(1) = norm(b-A*x0)
normrmin = normr1;                  % Norm of residual from xmin
rho = 1;
omega = 1;
stag = 0;                          % stagnation of the method
alpha = [];                        % overshadow any functions named alpha

% loop over maxit iterations (unless convergence or failure)

for i = 1 : maxit
   rho1 = rho;
   rho = rt' * r;
   if (rho == 0.0) || isinf(rho)
      flag = 4;
      resvec = resvec(1:2*i-1);
      break
   end
   if i == 1
      p = r;
   else
      beta = (rho/rho1)*(alpha/omega);
      if (beta == 0) || ~isfinite(beta)
         flag = 4;
         break
      end
      p = r + beta * (p - omega * v);
   end
   if existM1
      ph1 = iterapp('mldivide',m1fun,m1type,m1fcnstr,p,varargin{:});
      if any(~isfinite(ph1))
         flag = 2;
         resvec = resvec(1:2*i-1);
         break
      end
   else
      ph1 = p;
   end
   if existM2
      ph = iterapp('mldivide',m2fun,m2type,m2fcnstr,ph1,varargin{:});
      if any(~isfinite(ph))
         flag = 2;
         resvec = resvec(1:2*i-1);
         break
      end
   else
      ph = ph1;
   end
   v = iterapp('mtimes',afun,atype,afcnstr,ph,varargin{:});
   rtv = rt' * v;
   if (rtv == 0) || isinf(rtv)
      flag = 4;
      resvec = resvec(1:2*i-1);
      break
   end
   alpha = rho / rtv;
   if isinf(alpha)
      flag = 4;
      resvec = resvec(1:2*i-1);
      break
   end
   if alpha == 0                    % stagnation of the method
      stag = 1;
   end

   % Check for stagnation of the method
   if stag == 0
      stagtest = zeros(n,1);
      ind = (x ~= 0);
      stagtest(ind) = ph(ind) ./ x(ind);
      stagtest(~ind & ph ~= 0) = Inf;
      if abs(alpha)*norm(stagtest,inf) < eps
         stag = 1;
      end
   end

   xhalf = x + alpha * ph;          % form the "half" iterate
   rhalf = b - iterapp('mtimes',afun,atype,afcnstr,xhalf,varargin{:});
   normr = norm(rhalf);
   normr1 = norm(rhalf,1);
   resvec(2*i) = normr1;

   if normr1 <= tolb                 % check for convergence
      x = xhalf;
      flag = 0;
      iter = i - 0.5;
      resvec = resvec(1:2*i);
      break
   end

   if stag == 1
      flag = 3;
      resvec = resvec(1:2*i);
      break
   end

   if normr1 < normrmin              % update minimal norm quantities
      normrmin = normr1;
      xmin = xhalf;
      imin = i - 0.5;
   end

   s = r - alpha * v;               % residual associated with xhalf
   if existM1
      sh1 = iterapp('mldivide',m1fun,m1type,m1fcnstr,s,varargin{:});
      if any(~isfinite(sh1))
         flag = 2;
         resvec = resvec(1:2*i);
         break
      end
   else
      sh1 = s;
   end
   if existM2
      sh = iterapp('mldivide',m2fun,m2type,m2fcnstr,sh1,varargin{:});
      if any(~isfinite(sh))
         flag = 2;
         resvec = resvec(1:2*i);
         break
      end
   else
      sh = sh1;
   end
   t = iterapp('mtimes',afun,atype,afcnstr,sh,varargin{:});
   tt = t' * t;
   if (tt == 0) || isinf(tt)
      flag = 4;
      resvec = resvec(1:2*i);
      break
   end
   omega = (t' * s) / tt;
   if isinf(omega)
      flag = 4;
      resvec = resvec(1:2*i);
      break
   end
   if omega == 0                    % stagnation of the method
      stag = 1;
   end

   % Check for stagnation of the method
   if stag == 0
      stagtest = zeros(n,1);
      ind = (xhalf ~= 0);
      stagtest(ind) = sh(ind) ./ xhalf(ind);
      stagtest(~ind & sh ~= 0) = Inf;
      if abs(omega)*norm(stagtest,inf) < eps
         stag = 1;
      end
   end

   x = xhalf + omega * sh;          % x = (x + alpha * ph) + omega * sh
   rfull = b - iterapp('mtimes',afun,atype,afcnstr,x,varargin{:});
   normr = norm(rfull);
   normr1 = norm(rfull,1);
   resvec(2*i+1) = normr1;

   if normr1 <= tolb                 % check for convergence
      flag = 0;
      iter = i;
      resvec = resvec(1:2*i+1);
      break
   end

   if stag == 1
      flag = 3;
      resvec = resvec(1:2*i+1);
      break
   end

   if normr1 < normrmin              % update minimal norm quantities
      normrmin = normr1;
      xmin = x;
      imin = i;
   end

   r = s - omega * t;

end                                % for i = 1 : maxit

% returned solution is first with minimal residual
if flag == 0
   relres = normr1 / n1b;
else
   x = xmin;
   iter = imin;
   relres = normrmin / n1b;
end

% only display a message if the output flag is not used
if nargout < 2
   itermsg('bicgstab',tol,maxit,i,flag,iter,relres);
end
