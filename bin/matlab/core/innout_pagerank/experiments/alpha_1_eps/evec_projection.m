%% Non-dominant eigenvectors and inner-outer iteration 

%% Setup the experiment
P=sparse(6,6);P(2,1)=1/2;P(4,2)=1/3;P(2,3)=1/2;
P(4,3)=1/3;P(3,4)=1;P(4,5)=1/3;P(6,5)=1;P(5,6)=1;
n = size(P,1);
P(1,1:n) = 1/n;
P = full(P);

%%
<<<<<<< .mine
% Setup figures for eps files
    set(0, 'defaultaxesfontsize', 12);
    set(0, 'defaultaxeslinewidth', .75);
    set(0, 'defaultlinelinewidth', 1);

%%
[x flag hist phist1 ignore D emag1] = inoutpr_proj(P,0.99,[],1e-10,[],[],5); % power
[x flag hist phist2 pstart D emag2] = inoutpr_proj(P,0.99,[],1e-10,[]); % inner-outer

%sty={'-','--'}; color='bgrcmy';
=======
% Setup figures for eps files
    set(0, 'defaultaxesfontsize', 18);
    set(0, 'defaultaxeslinewidth', .75);
    set(0, 'defaultlinelinewidth', 1);

%%
[x flag hist phist1 ignore D emag1] = inoutpr_proj(P,0.99,[],1e-10,[],[],5); % power
[x flag hist phist2 pstart D emag2] = inoutpr_proj(P,0.99,[],1e-10,[]); % inner-outer
>>>>>>> .r776
sty={'-','--'}; color='kkkkkk';
figure(1); clf; 
for i=1:1:6
    subplot(6,1,i);
    semilogx(abs(phist1(i,:)),[color(i) sty{1}]); hold on;
    semilogx(abs(phist2(i,:)),[color(i) sty{2}]);
    set(gca,'YScale','log'); set(gca,'XScale','log'); 
    ylim([1e-10,1]); xlim([1,2500]); 
    ylreal = strtrim(sprintf('\\lambda = %-5.2g', real(D(i,i))));
    if isreal(D(i,i)), ylabel(ylreal);
    else ylabel([strtrim(sprintf('%s\n           + %-5.2f', ylreal, imag(D(i,i)))) ' i']);
    end
    line([pstart,pstart],[1e-10,1]);
    pbaspect([8 1 1]);
    if i==1, legend('power', 'inout'); legend boxoff; 
        text(1.5,1e-5,'values are less than 10^{-10} for all iterations');
    end
end
%line([pstart pstart],[1e-12,1e6],');
set(gca,'XScale','log');
set(gca,'YScale','log');

set(gcf,'PaperPosition',[0.25 0.5 8 10]);
print(gcf, 'evec-projection-ones-1.eps', '-depsc2');
<<<<<<< .mine
%%
=======
saveas(gcf,'evec-projection-ones-1.fig','fig');

>>>>>>> .r776
%% Same graph for a cycle matrix
n=6; P=sparse(1:n-1, 2:n, 1, n, n); P(n,1)=1; P=full(P);
v = rand(n,1); v=v./sum(v);
[x flag hist phist1 ignore D emag1] = inoutpr_proj(P,0.99,v,1e-10,[],[],5); % power
[x flag hist phist2 pstart D emag2] = inoutpr_proj(P,0.99,v,1e-10,[]); % inner-outer
sty={'-','--'}; color='kkkkkk';
figure(1); clf; 
for i=1:1:6
    subplot(6,1,i);
    semilogx(abs(phist1(i,:)),[color(i) sty{1}]); hold on;
    semilogx(abs(phist2(i,:)),[color(i) sty{2}]);
    set(gca,'YScale','log'); set(gca,'XScale','log'); 
    ylim([1e-10,1]); xlim([1,2500]); 
    ylreal = strtrim(sprintf('\\lambda = %-5.2g', real(D(i,i))));
    if isreal(D(i,i)), ylabel(ylreal);
    else ylabel([strtrim(sprintf('%s\n           + %-5.2f', ylreal, imag(D(i,i)))) ' i']);
    end
    line([pstart,pstart],[1e-10,1]);
    pbaspect([8 1 1]);
    if i==1, legend('power', 'inout'); legend boxoff; 
        text(1.5,1e-5,'values are less than 10^{-10} for all iterations');
    end
end
%line([pstart pstart],[1e-12,1e6],');
set(gca,'XScale','log');
set(gca,'YScale','log');

set(gcf,'PaperPosition',[0.25 0.5 8 10]);
print(gcf, 'evec-projection-cycle-loose.eps', '-depsc2');
saveas(gcf,'evec-projection-cycle-loose.fig','fig');

%% Same graph for a cycle matrix
n=6; P=sparse(1:n-1, 2:n, 1, n, n); P(n,1)=1; P=full(P);
v = rand(n,1); v=v./sum(v);
[x flag hist phist1 ignore D emag1] = inoutpr_proj(P,0.99,v,1e-10,[],[],5); % power
[x flag hist phist2 pstart D emag2] = inoutpr_proj(P,0.99,v,1e-10,[]); % inner-outer
sty={'-','--'}; color='kkkkkk';
figure(1); clf; 
for i=1:1:6
    subplot(6,1,i);
    semilogx(abs(phist1(i,:)),[color(i) sty{1}]); hold on;
    semilogx(abs(phist2(i,:)),[color(i) sty{2}]);
    set(gca,'YScale','log'); set(gca,'XScale','log'); 
    ylim([1e-10,1]); xlim([1,2500]); 
    ylreal = strtrim(sprintf('\\lambda = %-5.2g', real(D(i,i))));
    if isreal(D(i,i)), ylabel(ylreal);
    else ylabel([strtrim(sprintf('%s\n           + %-5.2f', ylreal, imag(D(i,i)))) ' i']);
    end
    line([pstart,pstart],[1e-10,1]);
    pbaspect([8 1 1]);
    if i==1, legend('power', 'inout'); legend boxoff; 
        text(1.5,1e-5,'values are less than 10^{-10} for all iterations');
    end
end
%line([pstart pstart],[1e-12,1e6],');
set(gca,'XScale','log');
set(gca,'YScale','log');

set(gcf,'PaperPosition',[0.25 0.5 8 10]);
print(gcf, 'evec-projection-cycle-loose-inner.eps', '-depsc2');
saveas(gcf,'evec-projection-cycle-loose-inner.fig','fig');

%% Same graph for a cycle matrix
n=6; P=sparse(1:n-1, 2:n, 1, n, n); P(n,1)=1; P=full(P);
v = rand(n,1); v=v./sum(v);
[x flag hist phist1 ignore D emag1] = inoutpr_proj(P,0.99,v,1e-10,[],[],5); % power
[x flag hist phist2 pstart D emag2] = inoutpr_proj(P,0.99,v,1e-10,[],1e-5); % inner-outer
sty={'-','--'}; color='kkkkkk';
figure(1); clf; 
for i=1:1:6
    subplot(6,1,i);
    semilogx(abs(phist1(i,:)),[color(i) sty{1}]); hold on;
    semilogx(abs(phist2(i,:)),[color(i) sty{2}]);
    set(gca,'YScale','log'); set(gca,'XScale','log'); 
    ylim([1e-10,1]); xlim([1,2500]); 
    ylreal = strtrim(sprintf('\\lambda = %-5.2g', real(D(i,i))));
    if isreal(D(i,i)), ylabel(ylreal);
    else ylabel([strtrim(sprintf('%s\n           + %-5.2f', ylreal, imag(D(i,i)))) ' i']);
    end
    line([pstart,pstart],[1e-10,1]);
    pbaspect([8 1 1]);
    if i==1, legend('power', 'inout'); legend boxoff; 
        text(1.5,1e-5,'values are less than 10^{-10} for all iterations');
    end
end
%line([pstart pstart],[1e-12,1e6],');
set(gca,'XScale','log');
set(gca,'YScale','log');

set(gcf,'PaperPosition',[0.25 0.5 8 10]);
print(gcf, 'evec-projection-cycle-tight-inner.eps', '-depsc2');
saveas(gcf,'evec-projection-cycle-tight-inner.fig','fig');

%% Test an idea with a random vector v
v = rand(n,1); v=v./sum(v);
[x flag hist phist1 ignore D emag1] = inoutpr_proj(P,0.99,v,1e-10,[],[],5); % power
[x flag hist phist2 pstart D emag2] = inoutpr_proj(P,0.99,v,1e-10); % inner-outer

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
[x flag hist phist1 ignore D emag1] = inoutpr_proj(P,0.995,v,1e-10,[],[],5); % power
[x flag hist phist2 pstart D emag2] = inoutpr_proj(P,0.995,v,1e-10,[],0.7,1e-10); % inner-outer

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