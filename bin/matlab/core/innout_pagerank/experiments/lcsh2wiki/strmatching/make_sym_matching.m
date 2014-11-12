function make_sym_matching(file1,file2,outfile)

addpath('/home/dgleich/dev/matlab');
A = readSMAT(file1);
B = readSMAT(file2);
A(size(A,1),size(B,1)) = 0;
B(size(B,1),size(A,1)) = 0;
AorB = max(A,B');
writeSMAT(outfile,AorB);


