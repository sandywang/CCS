function ttf = innerpre_eval_func(tt,a,b,m)
ttf = ones(size(tt));
for k=1:m
    ttf = ttf + (b*tt).^k;
end
ttf = ttf.*(1-a*tt);