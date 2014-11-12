%% Look at PageRank eigenvalues under transformations

%% Generate random points on a plane
n = 500;
X = randn(n,3);
nX=sqrt(sum(X.^2,2));
X = diag(spfun( @(x) 1./x, nX))*X; % project to the sphere
X = X(:,[1 2]); % now drop a coordinate, which puts everything into the plane
x = X(:,1) + j*X(:,2); % convert to complex numbers
plot(x,'.');

%% Look at the transform for different values of alpha
beta = 0.35924;
alphas = [0.6 0.85 0.9, 0.99]
for ai=1:length(alphas)
    a = alphas(ai);
    subplot(2,2,ai); cla; 
    plot(1-a*x,'k.'); axis square; hold on;
    plot(1./(1-beta*x),'r.');
end