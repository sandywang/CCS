/*
 * David Gleich
 * Copyright, Stanford University, 2007
 * 8 May 2008
 */

/**
 * @file ompmultlib.cc
 * Test routines in the libbvg for omp multiplication
 */
 
/**
 * 2008-05-09: Initial version
 */ 

#define BVGRAPH_VERBOSE

extern "C" {
#include "bvgraph.h"
#include "bvgraphfun.h"
#include "bvgraphomp.h"
}

#include <vector>
#include <iostream>
#include <sstream>
#include <string>
#include "../simple_timers.hpp"
#include <omp.h>
#include <math.h>

/** 
 * Compute P'*x where P is stored by rows and we need to apply 
 * the stochastic divide ourselves.
 * 
 * This version uses the atomic directive to avoid duplicate writes
 * 
 * The sets are re-used between multiplies
 */
void omp_mult_1(bvgraph *g, int nrep, double ans) 
{
    using namespace std;
    stime_struct cstart; double ctime;
    
    int rep, rval, si;
    vector<double> xvec(g->n), yvec(g->n);
    double *x = &xvec[0], *y = &yvec[0];
    
    bvgraph_parallel_iterators pits;
    rval = bvgraph_parallel_iterators_create(g,&pits,omp_get_max_threads(),0,1);
    if (rval) { 
        cerr << "error: cannot get parallel iterators " << endl;
        cerr << "bvgraph error: " << bvgraph_error_string(rval) << endl;
        return;
    }
    
    simple_time_clock(&cstart);
    
    for (rep = 0; rep < nrep; rep++)
    {
#pragma omp parallel for
        for (si = 0; si < g->n; si++) { 
            x[si]=1.0/(double)(rep+1); 
        }

        rval = bvgraph_omp_substochastic_transmult(&pits, x, y);
        
        double curans = 0.0;
#pragma omp parallel for reduction(+:curans)
        for (si=0; si<g->n; si++) { curans += y[si]; }
        
        if (fabs(curans-ans/(double)(rep+1))/curans > 1e-13) { 
            cout << "mult 1 " << rep << " curans = " << curans << "; ans = " <<  ans/(double)(rep+1) << endl;
        }
    }
    
    ctime = elapsed_time(&cstart);

    bvgraph_parallel_iterators_free(&pits);
    
    cout << "atomic " << endl; 
    cout << "  compute       : " << ctime << " seconds" << endl;
}

/** 
 * Compute P'*x where P is stored by rows and we need to apply 
 * the stochastic divide ourselves.
 * 
 * This version allocates num_thread vectors and them
 * merges them at the end of the multiply.
 */
void omp_mult_2(bvgraph *g, int nrep, double ans) 
{   
    using namespace std;
    stime_struct cstart; double ctime;
    
    int rep, rval, si, niters=omp_get_max_threads();
    bvgraph_parallel_iterators pits;
    rval = bvgraph_parallel_iterators_create(g,&pits,niters,0,1);
    if (rval) { 
        cerr << "error: cannot get parallel iterators " << endl;
        cerr << "bvgraph error: " << bvgraph_error_string(rval) << endl;
        return;
    }

    vector<double> xvec(g->n), yvec((g->n)*(pits.niters));
    double *x = &xvec[0], *y = &yvec[0];
    
    simple_time_clock(&cstart);
    
    for (rep = 0; rep < nrep; rep++)
    {
#pragma omp parallel for
        for (si = 0; si < g->n; si++) { 
            x[si]=1.0/(double)(rep+1); 
        }

        rval = bvgraph_omp_substochastic_transmult_extra(&pits, x, y, y+g->n);
        
        double curans = 0.0;
#pragma omp parallel for reduction(+:curans)
        for (si=0; si<g->n; si++) { curans += y[si]; }
        
        if (fabs(curans-ans/(double)(rep+1))/curans > 1e-13) { 
            cout << "mult 2 " << rep << " curans = " << curans << "; ans = " <<  ans/(double)(rep+1) << endl;
        }
    }
    
    ctime = elapsed_time(&cstart);

    bvgraph_parallel_iterators_free(&pits);
    
    cout << "full vecs " << endl; 
    cout << "  compute       : " << ctime << " seconds" << endl;
}    

void serial_mult(bvgraph *g, int nrep, double ans)
{
    using namespace std;
    stime_struct cstart; double ctime;
    
    int rep, rval, si;

    vector<double> xvec(g->n), yvec(g->n);
    double *x = &xvec[0], *y = &yvec[0];
    
    simple_time_clock(&cstart);
    
    for (rep = 0; rep < nrep; rep++)
    {
        for (si = 0; si < g->n; si++) { 
            x[si]=1.0/(double)(rep+1); 
        }

        rval = bvgraph_substochastic_transmult(g, x, y);
        
        double curans = 0.0;
        for (si=0; si<g->n; si++) { curans += y[si]; }
        
        if (fabs(curans-ans/(double)(rep+1))/curans > 1e-13) { 
            cout << "mult 2 " << rep << " curans = " << curans << "; ans = " <<  ans/(double)(rep+1) << endl;
        }
    }
    
    ctime = elapsed_time(&cstart);
    
    cout << "serial " << endl; 
    cout << "  compute       : " << ctime << " seconds" << endl;
    
}

int main(int argc, char **argv)
{
    using namespace std;

    if (argc < 2 || argc > 3) {
        cerr << "usage: ompmult graph [nrep=5]" << endl;
        return (-1);
    }

    std::string graphfilename;
    
    int nrep = 5;
    
    graphfilename = argv[1];
    if (argc > 2) {
        string nreparg = argv[2];
        std::stringstream ss(nreparg);
        ss >> nrep;
    }
    
    bvgraph g;
    int rval;

    rval = bvgraph_load(&g, graphfilename.c_str(), (unsigned int)graphfilename.length(), 0);
    if (rval) {
        cerr << "error: " << bvgraph_error_string(rval) << endl;
        return (rval);
    }
      
    // compute the answer to P'*ones(n,1), so we can check each 
    // run
    double ans=0.0;
    {
        bvgraph_iterator git;
        int *links; unsigned int i, d;
    
        vector<double> yvec(g.n, 0); double *y = &yvec[0];

        rval = bvgraph_nonzero_iterator(&g, &git);
        for (; bvgraph_iterator_valid(&git); bvgraph_iterator_next(&git)) {
            double xval = 1.0;
            bvgraph_iterator_outedges(&git, &links, &d);
            if (d > 0) { xval = xval/(double)d; }
            
            for (i = 0; i < d; i++) {
                y[links[i]] += xval;
            }
        }
        bvgraph_iterator_free(&git);
        for (i=0; i<g.n; i++) {
            ans += y[i];
        }
    }
    
    cout << "starting mult 1 " << endl;
    omp_mult_1(&g, nrep, ans);
    cout << "starting mult 2 " << endl;
    omp_mult_2(&g, nrep, ans);
    cout << "serial mult " << endl;
    serial_mult(&g, nrep, ans);

    return (0);
}
