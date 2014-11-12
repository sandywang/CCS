%% Create the small graph
P=sparse(6,6);P(2,1)=1/2;P(4,2)=1/3;P(2,3)=1/2;
P(4,3)=1/3;P(3,4)=1;P(4,5)=1/3;P(6,5)=1;P(5,6)=1;
n = size(P,1);
P(1,1:n) = 1/n;
P = full(P);

%% Run inner-outer at alpha = 0.85 and 0.99
diary 'small-graph-85.log'
[x flag hist] = inoutpr(P,0.85,[],[],[],[],[],1);
diary off;

diary 'small-graph-99.log'
[x flag hist] = inoutpr(P,0.99,[],1e-13,[],[],[],1);
diary off;



