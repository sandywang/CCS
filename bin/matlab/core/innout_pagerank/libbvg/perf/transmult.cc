/*
 * David Gleich
 * Copyright, Stanford University, 2007
 * 8 May 2008
 */

/**
 * @file transmult.cc
 * Test various versions of a stochastic transpose matrix vector multiplication
 */
 
/**
 * 2008-05-08: Initial version
 */ 

extern "C" {
#include "bvgraph.h"
}

#include <vector>
#include <iostream>
#include <sstream>
#include <string>
#include "../simple_timers.hpp"

/** Transpose matrix vector multiplies with int degrees 
 */
void trans_mult_1(bvgraph *g, int nrep) 
{
    using namespace std;
    vector<int> degrees(g->n,0);
    int *dvec = &degrees[0];
    stime_struct ppstart, cstart; 
    double pptime, ctime;
    
    int rep;
    
    int rval;
    bvgraph_iterator git;
    int *links; unsigned int i, d;
    double id, yi;
    
    vector<double> xvec(g->n,1.), yvec(g->n);
    double *x = &xvec[0], *y=&yvec[0];
    
    simple_time_clock(&ppstart);
    rval = bvgraph_nonzero_iterator(g, &git);
    if (rval) {
        cerr << "error: cannot get bvgraph iterator " << endl;
        cerr << "bvgraph error: " << bvgraph_error_string(rval) << endl;
        cerr << "halting iteration..." << endl;
        return;
    }
    for (; bvgraph_iterator_valid(&git); bvgraph_iterator_next(&git)) {
        bvgraph_iterator_outedges(&git, &links, &d);
        for (i = 0; i < d; i++) {
            dvec[links[i]]++;
        }
    }
    bvgraph_iterator_free(&git);  
    
    pptime = elapsed_time(&ppstart);
    
    simple_time_clock(&cstart);
    
    for (rep = 0; rep < nrep; rep++)
    {
        for (i = 0; i < g->n; i++) { x[i]=1.0/(double)(nrep+1); }
        
        rval = bvgraph_nonzero_iterator(g, &git);
        if (rval) {
            cerr << "error: cannot get bvgraph iterator " << endl;
            cerr << "bvgraph error: " << bvgraph_error_string(rval) << endl;
            cerr << "halting iteration..." << endl;
            return;
        }
        for (; bvgraph_iterator_valid(&git); bvgraph_iterator_next(&git)) {
            bvgraph_iterator_outedges(&git, &links, &d);
            yi = 0.0;
            for (i = 0; i < d; i++) {
                id = 1.0/(double)dvec[links[i]];
                yi += x[links[i]]*id;
            }
            y[git.curr] = yi;
        }
    }
    
    
    ctime = elapsed_time(&cstart);
    
    cout << "integer degrees " << endl;
    cout << "  preprocess    : " << pptime << " seconds" << endl; 
    cout << "  compute       : " << ctime << " seconds" << endl; 
}

/** Transpose matrix vector multiplies with double degrees 
 */
void trans_mult_2(bvgraph *g, int nrep) 
{   
    using namespace std;
    vector<double> degrees(g->n,0.);
    double *dvec = &degrees[0];
    stime_struct ppstart, cstart; 
    double pptime, ctime;
    
    int rep;
    
    int rval;
    bvgraph_iterator git;
    int *links; unsigned int i, d;
    
    vector<double> xvec(g->n,1.), yvec(g->n);
    double *x = &xvec[0], *y=&yvec[0];
    double yi;
    
    simple_time_clock(&ppstart);
    
    rval = bvgraph_nonzero_iterator(g, &git);
    if (rval) {
        cerr << "error: cannot get bvgraph iterator " << endl;
        cerr << "bvgraph error: " << bvgraph_error_string(rval) << endl;
        cerr << "halting iteration..." << endl;
        return;
    }
    for (; bvgraph_iterator_valid(&git); bvgraph_iterator_next(&git)) {
        bvgraph_iterator_outedges(&git, &links, &d);
        for (i = 0; i < d; i++) {
            dvec[links[i]]++;
        }
    }
    bvgraph_iterator_free(&git);  
    for (i=0; i<g->n; i++) { if (dvec[i]>0) dvec[i]=1./dvec[i]; }
    
    pptime = elapsed_time(&ppstart);
    
    simple_time_clock(&cstart);
    
    for (rep = 0; rep < nrep; rep++)
    {
        for (i = 0; i < g->n; i++) { x[i]=1.0/(double)(nrep+1); }
        
        rval = bvgraph_nonzero_iterator(g, &git);
        if (rval) {
            cerr << "error: cannot get bvgraph iterator " << endl;
            cerr << "bvgraph error: " << bvgraph_error_string(rval) << endl;
            cerr << "halting iteration..." << endl;
            return;
        }
        for (; bvgraph_iterator_valid(&git); bvgraph_iterator_next(&git)) {
            bvgraph_iterator_outedges(&git, &links, &d);
            yi = 0.0;
            for (i = 0; i < d; i++) {
                yi += x[links[i]]*dvec[links[i]];
            }
            y[git.curr] = yi;
        }
    }
    
    ctime = elapsed_time(&cstart);
    
    cout << "double degrees " << endl;
    cout << "  preprocess    : " << pptime << " seconds" << endl; 
    cout << "  compute       : " << ctime << " seconds" << endl; 
}    

int main(int argc, char **argv)
{
    using namespace std;

    if (argc < 2 || argc > 3) {
        cerr << "usage: transmult graph [nrep=5]" << endl;
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
    
    trans_mult_1(&g, nrep);
    trans_mult_2(&g, nrep);

    return (0);
}
