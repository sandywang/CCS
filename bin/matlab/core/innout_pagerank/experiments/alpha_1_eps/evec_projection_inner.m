%% Non-dominant eigenvectors and inner-outer iteration 

%% Setup the experiment
P=sparse(6,6);P(2,1)=1/2;P(4,2)=1/3;P(2,3)=1/2;
P(4,3)=1/3;P(3,4)=1;P(4,5)=1/3;P(6,5)=1;P(5,6)=1;
n = size(P,1);
P(1,1:n) = 1/n;
P = full(P);
v = 1./n;

%%
[x flag hist phist1 pstart D emag1] = inoutpr_proj_inner(P,0.99,v,1e-10,[],[],1e-5); % inner-outer
[x flag hist phist2 ignore D emag2] = inoutpr_proj(P,0.99,v,1e-10,[],[],5); % power
%sty={'-','--'}; color='bgrcmy';
sty={'-','--'}; color='kkkkkk';
figure(1); clf; 
for i=1:1:6
    subplot(6,1,i);
    semilogx(abs(phist1(i,:)),[color(i) sty{1}]); hold on;
    semilogx(abs(phist2(i,:)),[color(i) sty{2}]);
    set(gca,'XScale','log'); set(gca,'YScale','log');
    ylim([1e-10,1]); xlim([1,2500]); ylabel(sprintf('\\lambda = %g', D(i,i)));
    line([pstart,pstart],[1e-10,1]);
    pbaspect([12 2 1]);
end
%line([pstart pstart],[1e-12,1e6],');
set(gca,'XScale','log');
set(gca,'YScale','log');

print(gcf, 'evec-projection-ones-1.eps', '-depsc2');

sty={'-','--'}; color='kkkkkk';
figure(2); clf; 
for i=1:1:6
    subplot(6,1,i);
    plot(abs(emag1(i,:)),[color(i) sty{1}]); hold on;
    plot(abs(emag2(i,:)),[color(i) sty{2}]);
    set(gca,'XScale','log');
    xlim([1,2500]); ylabel(sprintf('\\lambda = %g', D(i,i)));
    line([pstart,pstart],[1e-10,1]);
end
%line([pstart pstart],[1e-12,1e6],');



%% Test an idea with a random vector v
v = rand(n,1); v=v./sum(v);
[x flag hist phist1 pstart D emag1] = inoutpr_proj(P,0.99,v,1e-10); % inner-outer
[x flag hist phist2 ignore D emag2] = inoutpr_proj(P,0.99,v,1e-10,[],[],5); % power
%sty={'-','--'}; color='bgrcmy';
sty={'-','--'}; color='kkkkkk';
figure(1); clf; 
for i=1:1:6
    subplot(6,1,i);
    semilogx(abs(phist1(i,:)),[color(i) sty{1}]); hold on;
    semilogx(abs(phist2(i,:)),[color(i) sty{2}]);
    set(gca,'XScale','log'); set(gca,'YScale','log');
    ylim([1e-10,1]); xlim([1,2500]); ylabel(sprintf('\\lambda = %g', D(i,i)));
    line([pstart,pstart],[1e-10,1]);
end
%line([pstart pstart],[1e-12,1e6],');
set(gca,'XScale','log');
set(gca,'YScale','log');

sty={'-','--'}; color='kkkkkk';
figure(2); clf; 
for i=1:1:6
    subplot(6,1,i);
    plot(abs(emag1(i,:)),[color(i) sty{1}]); hold on;
    plot(abs(emag2(i,:)),[color(i) sty{2}]);
    set(gca,'XScale','log');
    xlim([1,2500]); ylabel(sprintf('\\lambda = %g', D(i,i)));
    line([pstart,pstart],[1e-10,1]);
end

%% Test a different matrix P
n = 6; e= ones(n,1);
A = spdiags(e, 1, n,n); A(6,1) = 1;
P = full(A);
v = rand(n,1); v=v./sum(v);
%%
[x flag hist phist1 pstart D emag1] = inoutpr_proj(P,0.995,v,1e-10,[],0.7,1e-10); % inner-outer
[x flag hist phist2 ignore D emag2] = inoutpr_proj(P,0.995,v,1e-10,[],[],5); % power
%sty={'-','--'}; color='bgrcmy';
sty={'-','--'}; color='kkkkkk';
figure(1); clf; 
for i=1:1:6
    subplot(6,1,i);
    semilogx(abs(phist1(i,:)),[color(i) sty{1}]); hold on;
    semilogx(abs(phist2(i,:)),[color(i) sty{2}]);
    set(gca,'XScale','log'); set(gca,'YScale','log');
    ylim([1e-10,1]); xlim([1,2500]); ylabel(sprintf('\\lambda = %g', D(i,i)));
    line([pstart,pstart],[1e-10,1]);
end
%line([pstart pstart],[1e-12,1e6],');
set(gca,'XScale','log');
set(gca,'YScale','log');

sty={'-','--'}; color='kkkkkk';
figure(2); clf; 
for i=1:1:6
    subplot(6,1,i);
    plot(abs(emag1(i,:)),[color(i) sty{1}]); hold on;
    plot(abs(emag2(i,:)),[color(i) sty{2}]);
    set(gca,'XScale','log');
    xlim([1,2500]); ylabel(sprintf('\\lambda = %g', D(i,i)));
    line([pstart,pstart],[1e-10,1]);
end

%% Try a starting vector for the power iteration
x0 = powerpr(P,0.5,v,1e-10);
[x flag hist phist2 ignore D emag2] = powerpr_start(P,0.99,v,1e-10,0,x0); % power
%sty={'-','--'}; color='bgrcmy';
sty={'-','--'}; color='kkkkkk';
figure(1); clf; 
for i=1:1:6
    subplot(6,1,i);
    semilogx(abs(phist1(i,:)),[color(i) sty{1}]); hold on;
    semilogx(abs(phist2(i,:)),[color(i) sty{2}]);
    set(gca,'XScale','log'); set(gca,'YScale','log');
    ylim([1e-10,1]); xlim([1,2500]); ylabel(sprintf('\\lambda = %g', D(i,i)));
    line([pstart,pstart],[1e-10,1]);
end
%line([pstart pstart],[1e-12,1e6],');
set(gca,'XScale','log');
set(gca,'YScale','log');

sty={'-','--'}; color='kkkkkk';
figure(2); clf; 
for i=1:1:6
    subplot(6,1,i);
    plot(abs(emag1(i,:)),[color(i) sty{1}]); hold on;
    plot(abs(emag2(i,:)),[color(i) sty{2}]);
    set(gca,'XScale','log');
    xlim([1,2500]); ylabel(sprintf('\\lambda = %g', D(i,i)));
    line([pstart,pstart],[1e-10,1]);
end