function s=norm_axpbypgz(x,y,z,a,b,g)
% normdiff Compute the 1-norm of the difference between two vectors.
%
% For large vectors, the native sum command in Matlab does not appear to
% use a compensated summation algorithm which can cause significant round
% off errors.
%
% This code implements a variant of Kahan's compensated summation algorithm
% which often takes about twice as long, but produces more accurate sums 
% when the number of elements is large.
%
% See also NORM
%
% Example:
%   x=rand(1e7,1); y=rand(1e7,1);
%   sum1 = normdiff(x,y);
%   sum2 = norm(x-y,1);
%   fprintf('sum1 = %18.16e\nsum2 = %18.16e\n', sum1, sum2);

% David Gleich
% Copyright, Stanford University, 2008

% 2008-05-23: Initial version based on other codes.
%             Optimzied with abs() based on test/normdiff_perf.m

if isscalar(y)
    b=b*y;
    s=0; e=0; temp=0; t=0;
    for i=1:numel(x)
        temp=s; 
        t = abs(a*x(i)+b+g*z(i))+e;
        s=temp+t; 
        e=(temp-s)+t;
    end
    s=s+e;
else
    s=0; e=0; temp=0; t=0;
    for i=1:numel(x)
        temp=s; 
        t = abs(a*x(i)+b*y(i)+g*z(i))+e;
        s=temp+t; 
        e=(temp-s)+t;
    end
    s=s+e;
end
