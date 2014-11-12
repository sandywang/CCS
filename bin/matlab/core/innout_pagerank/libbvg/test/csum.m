function s=csum(x)
% CSUM Compensated sum
s=0; e=0;
for i=1:numel(x)
    temp=s; y=x(i)+e; s=temp+y; e=(temp-s)+y;
end
