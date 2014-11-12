/*
 * David Gleich
 * Copyright, Stanford University, 2007
 * 7 June 2007
 */

/**
 * @file bvpagerank.cc
 * Implement a few simple PageRank algorithms as tests of the library.
 */
 
/**
 * 7 June 2007
 * Initial version
 *
 * 5 February 2008
 * Modified the code to actually write the output
 * Fixed bug with wrong last vector
 * Fixed incorrect tolerance parse
 *
 * 2008-05-01: Modified RAPr version of this code to work for Greif's
 *             inner-outer experiments... 
 */ 

extern "C" {
#include "bvgraph.h"
}

#include <vector>
#include <iostream>
#include <sstream>

#include <math.h>

#define BVALGS_VERBOSE
#include "vecfun.hpp"
#include "bvgraph_pagerank_mult.hpp"
#include "pagerank_power.hpp"
#include "pagerank_inout.hpp"

void updated_richardson_alg(bvgraph *g, double alpha, double tol, int maxit, std::vector<double>& prvec);

void print_usage(std::ostream& cerr)
{
    using namespace std;
    cerr << "usage: bvpagerank graphfile output alg alpha tol maxit [options]" << endl;
    cerr << endl;
    cerr << "Solves the PageRank problem on a boldi-vigna graph" << endl;
    cerr << "with uniform teleportation in the strongly preferential model." << endl;
    cerr << endl;
    cerr << "For any option except graphfile, specify _ to get the default value." << endl;
    cerr << endl;
    cerr << "graphfile: the base filename of a bvgraph file.  (e.g. cnr-2000)" << endl;
    cerr << "output: output filename for pagerank vector, \'none\' means no output" << endl;
    cerr << "alg: the PageRank computation algorithm [\'power\', \'inout\' or \'rich\']" << endl;
    cerr << "alpha: the value of alpha in the PageRank [float from 0 to 1]" << endl;
    cerr << "tol: the stopping tolerance for the 1-norm error [float from (0,Infinity])" << endl;
    cerr << "maxit: the maximum number of iterations [positive integer]" << endl;
    cerr << endl;
    cerr << "to specify the algorithm specific options, you must provide a value" << endl;
    cerr << "(i.e. the default _) for all of the other command line options" << endl;
    cerr << "  -beta %f : specify a float between [0,1] for beta in the inout alg" << endl;
    cerr << "  -itol %f : specify the inner-tolerance for the inout alg" << endl;
    cerr << endl;
    cerr << "defaults: " << endl;
    cerr << "  output = \'none\'; alg = \'inout\'; alpha = 0.85; tol = 1e-8; maxit = 10000" << endl;
    cerr << "  beta = 0.5; itol = 1e-2" << endl;
    cerr << endl;
}

int main(int argc, char **argv)
{
    using namespace std;

    if (argc < 2 || argc > 11) {
        print_usage(std::cerr);
        return (-1);
    }

    std::string graphfilename;
    
    enum alg_tag {
        bvpagerank_alg_power,
        bvpagerank_alg_inout,
        bvpagerank_alg_rich
    };
    enum alg_tag alg = bvpagerank_alg_inout;

    bool output = false;
    std::string outputfilename;
    double alpha = 0.85;
    double tol = 1e-8;
    int maxit = 10000;
    double beta = 0.5;
    double itol = 1e-2;
    
    graphfilename = argv[1];

    if (argc > 2) {
        std::string outputarg = argv[2];
        if (outputarg.compare("none") == 0 || outputarg.compare("_") == 0) {
            // don't change the default
        }
        else {
            output = true;
            outputfilename = outputarg;
        }
    }

    if (argc > 3) {
        std::string algarg = argv[3];
        if (algarg.compare("_") == 0) {
            // don't change the default
        }
        else if (algarg.compare("power") == 0) {
            alg = bvpagerank_alg_power;
        } 
        else if (algarg.compare("inout") == 0) {
            alg = bvpagerank_alg_inout;
        }
        else if (algarg.compare("rich") == 0) {
            alg = bvpagerank_alg_rich;
        }
    }

    if (argc > 4) {
        std::string alphaarg = argv[4];
        if (alphaarg.compare("_") != 0) {
            std::stringstream ss(alphaarg);
            ss >> alpha;
        }
    }

    if (argc > 5) {
        std::string tolarg = argv[5];
        if (tolarg.compare("_") != 0) {
            std::stringstream ss(tolarg);
            ss >> tol;
        }
    }
    
    if (argc > 6) {
        std::string maxitarg = argv[6];
        if (maxitarg.compare("_") != 0) {
            std::stringstream ss(maxitarg);
            ss >> maxit;
        }
    }

    cout << "Parameters: " << endl;
    cout << "   graphfile = " << graphfilename << endl;
    if (output) { cout << "  outputfile = " << outputfilename << endl; }
    else { cout << "      output = none" << endl; }
    cout << "         alg = "; 
    switch (alg) {
        case bvpagerank_alg_power: cout << "power"; break;
        case bvpagerank_alg_inout: cout << "inout"; break;
        case bvpagerank_alg_rich: cout << "rich"; break;
    }
    cout << endl;
    cout << "       alpha = " << alpha << endl;
    cout << "         tol = " << tol << endl;
    cout << "       maxit = " << maxit << endl;
    cout << endl;

    if (argc > 7) {
        // they are specifying optional algorithm specific options
        int argi = 7;
        while (argi < argc-1) {
            std::string arg = argv[argi];
            if (arg.compare("-beta")) {
                std::stringstream ss(argv[argi+1]);
                ss >> beta;
                argi+=2;
            } else if (arg.compare("-itol")) {
                std::stringstream ss(argv[argi+1]);
                ss >> itol;
                argi+=2;
            }
        }
        if (argi != argc) {
            cerr << "partial option " << argv[argi] << " ignored" << endl;
        }
    }

    bvgraph g;
    int rval;

    rval = bvgraph_load(&g, graphfilename.c_str(), (unsigned int)graphfilename.length(), 0);
    if (rval) {
        cerr << "error: " << bvgraph_error_string(rval) << endl;
        return (rval);
    }

    cout << "nodes = " << g.n << endl;
    cout << "edges = " << g.m << endl;

    // initialize the PageRank vector with a value of 1/n;
    std::vector<double> prvec(g.n,1.0/(double)g.n);

    if (alg == bvpagerank_alg_power) {
        power_alg(&g, alpha, tol, maxit, prvec);
    }
    else if (alg == bvpagerank_alg_inout) {
        inner_outer_alg(&g, alpha, tol, maxit, prvec, beta, itol);
    }
    else if (alg == bvpagerank_alg_rich) {
        updated_richardson_alg(&g, alpha, tol, maxit, prvec);
    }
    else {
        cerr << "error: unknown algorithm" << endl;
        return (-1);
    }
    
    printf("output norm: %18.16e\n", norm_1(&prvec[0],g.n));

    if (output) {
        std::string filename = outputfilename + ".pr";
        FILE *f = fopen(filename.c_str(),"w");
        if (f) {
            fwrite(&prvec[0],sizeof(double),g.n,f);
            /*for (int i=0; i<g.n; i++) {
                fprintf(f,"%18.16e\n",prvec[i]);
            }
            fflush(f); fclose(f);*/
        } else {
            cerr << "error: cannot open " << filename << " for writing!" << endl;
        }
    }
    
    bvgraph_close(&g);

    return (0);
}

/**
 * From the computat alpha*P'*x, compute the initial
 * residual for the updated richardson iteration so that 
 * aPx on exit is v - (I - aP')x
 */
void initial_residual(double *aPx, double *x, size_t n) {
    double in = (1./(double)n);
    while (n-- > 0) { *aPx += in - *x++; }
}

double compute_pagerank_residual(double *y, double alpha, double nx, double dtx, size_t n)
{
    double rval=0.0; double in = (1./(double)n); double inx=1.0/nx;
    double avi = (1-alpha+alpha*dtx*inx)*in;
    while (n-- > 0) { rval += fabs((*y++-in)*inx + avi); }
    return (rval);
}

int updated_richardson_iter(bvgraph *g, double *x, double *y, double alpha, size_t n, double *pnx, double *pdtx)
{
    double nx=0.0, dtx=0.0;
    using namespace std;
    bvgraph_iterator git;
    int rval = bvgraph_nonzero_iterator(g, &git);
    if (rval) {
        cerr << "error: cannot get bvgraph iterator" << endl;
        cerr << "bvgraph error: " << bvgraph_error_string(rval) << endl;
        cerr << "halting iteration..." << endl;
        return (-1);
    }

    int *links; unsigned int i, d;
    double id=0.0;

    for (; 
         bvgraph_iterator_valid(&git); 
         bvgraph_iterator_next(&git))
    {
        bvgraph_iterator_outedges(&git, &links, &d);
        double yj = y[git.curr]; x[git.curr] += yj; nx += x[git.curr];
        if (d > 0) { id = 1.0/(double)d; }
        else { dtx += x[git.curr]; }
        for (i = 0; i < d; i++) {
            y[links[i]] += yj*alpha*id;
        }
        y[git.curr] -= yj;
    }
    bvgraph_iterator_free(&git);
    if (pnx) { *pnx = nx; }
    if (pdtx) { *pdtx = dtx; }
    return (0);
}

void updated_richardson_alg(bvgraph *g, double alpha, double tol, int maxit, std::vector<double>& prvec)
{
    using namespace std;

    size_t n = (size_t)g->n;

    std::vector<double> vec2(n);
    double *x = &prvec[0];
    double *y = &vec2[0];
    
    double nx=1.0,dtx=0.0; // norm(x,1) and d'*x
    if (mult(g, x, y, alpha, NULL)) { return; }
    initial_residual(y, x, n);
    double delta = 1.0; int iter=1;
    while (delta > tol && iter++ < maxit) {
        updated_richardson_iter(g,x,y,alpha,n,&nx,&dtx);
        delta = compute_pagerank_residual(y,alpha,nx,dtx,n);
        cout << iter << " " << delta << endl;
    }
    if (x!=&prvec[0]) {
        copy(y,&prvec[0],n);
    }
}

