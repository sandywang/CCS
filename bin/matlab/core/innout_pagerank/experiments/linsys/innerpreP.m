function y = innerpre(x,b,Px,m)
% INNERPRE Compute the result of an inner-preconditioning step on a vector
%
% y = innerpre(x,b,P,m) applies m+1 terms from the polynomial of inv(I-b*P')
% to the vector x.

y = x; z = x;
for k=1:m
    z = b*(Px'*z);
    y = y + z;
end
