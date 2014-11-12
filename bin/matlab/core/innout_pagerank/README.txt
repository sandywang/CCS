Codes for Inner-Outer Iteration for PageRank
David F. Gleich, Andrew P. Gray, Chen Greif, and Tracy Lau

These codes reproduce most of the figures from the manuscript.
 
All codes are protected by copyright laws and licensed under
the GNU GPL.  Please contact the authors for other possibilities.

Directories:

data        - a set of BV graphs for experiments (limited for download size)
experiments - many of our experiments and results
matlab      - matlab codes for computing PageRank and associated mex functions
libbvg      - C++ codes for inner-outer PageRank with BV graphs
msvc        - project files for Visual Studio

A more complete collection of all experiments and data is available upon 
request.  This collection contains most of the smaller data files and results.

Algorithms:

matlab/
  inoutpr.m   - Algorithm 2
  inoutgspr.m - Algorithm 3
  powerpr.m   - Power method PageRank
  gspr.m      - Gauss-Seidel PageRank

libbvg/
  bvpr        - power and inner-outer in serial 
  bvmcpr      - power and inner-outer with OpenMP
  bvtranspr   - power, inner-outer, gauss-seidel, and gauss-seidel inner-outer
  bvmctranspr - power, inner-outer with OpenMP on a transposed graph

Data:

ubc-cs-2006: data/ubc-cs.graph
ubc-2006: data/ubc.graph
harvard500: data/harvard500.graph
wb-cs.stanford: data/wb-cs.stanford.graph
cnr-2000: data/cnr-2000.graph
eu-2005: data/eu-2005.graph
in-2004: data/in-2004.graph
lcsh-2: experiments/lcsh2wiki/lcsh2wiki.mat:A2 variable
wiki-3: experiments/lcsh2wiki/lcsh2wiki.mat:B2 variable
lcsh2wiki-v: experiments/lcsh2wiki/strmatching/lcsh2wiki-matches-all.smat

Experiments:

The following list of experiments is not exhaustive.  We included other 
(undocumented) experiments.  

Figure 6.1: parameters/inout_parameters.mFigure 6.2: large_scale/convergence_plots.m
Figure 6.3: parallel/parallel_speedups.m
            parallel/parallel_speedups_trans.mFigure 6.4: linsys/pagerank_evals.m

Table 6.2: large_scale/runtime_tables.m
           parallel/runtime_tables.m
Table 6.3: large_scale/runtime_tables.m
Table 6.4: linsys/inner_terms.m
Table 6.6: lcsh2wiki/lcsh2wiki_full.m 
           lcsh2wiki/screenlog-2009-01-05.txt

Some of the codes need a few lines of editing to produce the exact figures.
Often the graph name was an early parameter of the script.





