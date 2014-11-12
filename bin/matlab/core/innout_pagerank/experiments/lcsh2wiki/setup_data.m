%% Setup data for the LCSH2Wikipedia experiment
% We'll form a small version of the LCSH graph, then a small version of the
% Wikipedia graph.

%% Load in the raw graphs
A = readSMAT('lcsh.smat');
Anames = textread('lcsh.names', '%s', 'delimiter', '\n');
B = readSMAT('wikipedia-200704-categories.smat');
Bnames = textread('wikipedia-200704-categories.pages', '%s', 'delimiter', '\n');

%% Do some graph operations using routines from gaimc
As = A|A';
Bs = B|B';
cnA = corenums(As);
cnB = corenums(Bs);
Af = cnA>1;
Bf = cnB>2;
A2 = As(Af,Af);
B2 = Bs(Bf,Bf);
A2names = Anames(Af);
B2names = Bnames(Bf);

%% 
Afsmall = cnA>3;
Bfsmall = cnB>4;
Asmall = As(Afsmall, Afsmall);
Bsmall = Bs(Bfsmall, Bfsmall);
Asmallnames = Anames(Afsmall);
Bsmallnames = Bnames(Afsmall);

%% Save the data
save 'lcsh2wiki.mat' A2 A2names B2 B2names
%%
save 'lcsh2wiki-small.mat' Asmall Asmallnames Bsmall Bsmallnames

%% Write the lists for text matching
writeList('lcsh2.names', A2names);
writeList('wiki2.names', B2names);

