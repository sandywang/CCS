%% Norms and spectral radius of inner-outer operator
% For $\alpha=1-\varepsilon$, the behavior of the inner-outer iteration
% cannot be explained with the asymptotic analysis that is standard for
% stationary methods.  This experiment looks at all of the true (not
% approximate or upper-bounded) quantities involved in the inner-outer
% iteration to check to see if they explain what is going on with the
% convergence in the $1-\varepsilon$ regeme.

%% Setup the experiment
P=sparse(6,6);P(2,1)=1/2;P(4,2)=1/3;P(2,3)=1/2;
P(4,3)=1/3;P(3,4)=1;P(4,5)=1/3;P(6,5)=1;P(5,6)=1;
n = size(P,1);
P(1,1:n) = 1/n;
P = full(P);
P = P';

%% Look at the norms and spectral radius of the operators
kmax=36;
beta=0.5; alpha=0.99;
Pk = eye(n); Tk=eye(n); rP=[]; rT=[];
for k=1:kmax
    Pk = alpha*Pk*P;
    Tk = (eye(n)-beta*P)\((alpha-beta)*P*Tk);
    rP(k).norm1=norm(Pk,1);
    rP(k).norm2=norm(Pk,2);
    rP(k).normfro=norm(Pk,'fro');
    rP(k).norminf=norm(Pk,'inf');
    rP(k).rho=max(abs(eig(Pk)));
    rT(k).norm1=norm(Tk,1);
    rT(k).norm2=norm(Tk,2);
    rT(k).normfro=norm(Tk,'fro');
    rT(k).norminf=norm(Tk,'inf');
    rT(k).rho=max(abs(eig(Tk)));
end
figure(1); clf;
subplot(3,1,1); cla; semilogy(1:k, [rP.norminf],'.-', 1:k, [rT.norminf],'.-');
subplot(3,1,2); cla; semilogy(1:k, [rP.norm2],'.-', 1:k,  [rT.norm2],'.-');
subplot(3,1,3); cla; semilogy(1:k, [rP.rho],'.-', 1:k, [rT.rho],'.-');
hold on; semilogy(1:k, feval(@(k) ((alpha-beta)/(1-beta)).^k, 1:k), '--');
    