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
 * 2008-05-23: Added normed option for gs and iogs
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
#include "bvgraph_pagerank_trans_mult.hpp"
#include "pagerank_power.hpp"
#include "pagerank_inout.hpp"
#include "pagerank_gauss_seidel.hpp"
#include "pagerank_inoutgs.hpp"

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
    cerr << "alg: the PageRank computation algorithm [\'power\', \'inout\', \'gs\', or \'inoutgs\']" << endl;
    cerr << "alpha: the value of alpha in the PageRank [float from 0 to 1]" << endl;
    cerr << "tol: the stopping tolerance for the 1-norm error [float from (0,Infinity])" << endl;
    cerr << "maxit: the maximum number of iterations [positive integer]" << endl;
    cerr << endl;
    cerr << "to specify the algorithm specific options, you must provide a value" << endl;
    cerr << "(i.e. the default _) for all of the other command line options" << endl;
    cerr << "  -beta %f   : specify a float between [0,1] for beta in the inout alg" << endl;
    cerr << "  -itol %f   : specify the inner-tolerance for the inout alg" << endl;
    cerr << "  -normed %i : used normalized iterates for gs, inoutgs" << endl;
    cerr << "  -resid %i  : compute all residuals for gs, inoutgs" << endl;
    cerr << endl;
    cerr << "defaults: " << endl;
    cerr << "  output = \'none\'; alg = \'inout\'; alpha = 0.85; tol = 1e-8; maxit = 10000" << endl;
    cerr << "  beta = 0.5; itol = 1e-2; resid = 1; normed = 0" << endl;
    cerr << endl;
}

int main(int argc, char **argv)
{
    using namespace std;

    if (argc < 2 || argc > 15) {
        print_usage(std::cerr);
        return (-1);
    }

    std::string graphfilename;
    
    enum alg_tag {
        bvpagerank_alg_power,
        bvpagerank_alg_inout,
        bvpagerank_alg_gs,
        bvpagerank_alg_inoutgs,
    };
    enum alg_tag alg = bvpagerank_alg_inout;

    bool output = false;
    std::string outputfilename;
    double alpha = 0.85;
    double tol = 1e-8;
    int maxit = 10000;
    double beta = 0.5;
    double itol = 1e-2;
    int resid = 1;
    int normed = 0;
    
    graphfilename = string(argv[1])+"-trans";

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
        } else if (algarg.compare("power") == 0) {
            alg = bvpagerank_alg_power;
        } else if (algarg.compare("inout") == 0) {
            alg = bvpagerank_alg_inout;
        } else if (algarg.compare("gs") == 0) {
            alg = bvpagerank_alg_gs;
        } else if (algarg.compare("inoutgs") == 0) {
            alg = bvpagerank_alg_inoutgs;
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
        case bvpagerank_alg_gs:    cout << "gs"; break;
        case bvpagerank_alg_inoutgs: cout << "inoutgs"; break;
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
            if (arg.compare("-beta")==0) {
                std::stringstream ss(argv[argi+1]);
                ss >> beta;
                argi+=2;
            } else if (arg.compare("-itol")==0) {
                std::stringstream ss(argv[argi+1]);
                ss >> itol;
                argi+=2;
            } else if (arg.compare("-resid")==0) {
                std::stringstream ss(argv[argi+1]);
                ss >> resid;
                argi+=2;
            } else if (arg.compare("-normed")==0) {
                std::stringstream ss(argv[argi+1]);
                ss >> normed;
                argi+=2;
            } else {
                cerr << "unknown option" << argv[argi] << " ignored" << endl;
                argi++;
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
    
    transbvgraph tg;
    std::vector<double> idmem(g.n,0);
    tg.g = &g;
    tg.id = &idmem[0];
    {
        // build indegree vector
        vector<double> degrees(g.n,0.);
        bvgraph_iterator git;
        int *links; unsigned int i, d;
        rval = bvgraph_nonzero_iterator(&g, &git);
        if (rval) {
            cerr << "error: cannot get bvgraph iterator " << endl;
            cerr << "bvgraph error: " << bvgraph_error_string(rval) << endl;
            return(-1);
        }
        for (; bvgraph_iterator_valid(&git); bvgraph_iterator_next(&git)) {
            bvgraph_iterator_outedges(&git, &links, &d);
            for (i = 0; i < d; i++) {
                idmem[links[i]]++;
            }
        }
        bvgraph_iterator_free(&git);  
        for (i=0; i<g.n; i++) { if (idmem[i]>0) idmem[i]=1./idmem[i]; }
    }

    cout << "nodes = " << g.n << endl;
    cout << "edges = " << g.m << endl;

    // initialize the PageRank vector with a value of 1/n;
    std::vector<double> prvec(g.n,1.0/(double)g.n);

    if (alg == bvpagerank_alg_power) {
        power_alg(&tg, alpha, tol, maxit, prvec);
    } else if (alg == bvpagerank_alg_inout) {
        inner_outer_alg(&tg, alpha, tol, maxit, prvec, beta, itol);
    } else if (alg == bvpagerank_alg_gs) {
        gauss_seidel_alg(&tg, alpha, tol, maxit, prvec, resid, normed);
    } else if (alg == bvpagerank_alg_inoutgs) {
        inner_outer_gauss_seidel_alg(&tg, alpha, tol, maxit, prvec, beta, itol, resid, normed);
    } else {
        cerr << "error: unknown algorithm" << endl;
        return (-1);
    }
    
    printf("output norm: %18.16e\n", norm_1(&prvec[0],g.n));

    if (output) {
        std::string filename = outputfilename + ".pr";
        FILE *f = fopen(filename.c_str(),"w");
        if (f) {
            fwrite(&prvec[0],sizeof(double),g.n,f);
        } else {
            cerr << "error: cannot open " << filename << " for writing!" << endl;
        }
    }
    
    bvgraph_close(&g);

    return (0);
}
