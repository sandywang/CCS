'll b/*
 * David Gleich
 * Copyright, Stanford University, 2007
 * 8 May 2008
 */

/**
 * @file ompmult.cc
 * Test various versions of a openmp multiplication for the column-stochastic
 * matrix that we access by columns.  The issue here is that   
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
#include <omp.h>
#include <math.h>


//#include <google/dense_hash_map>
//typedef google::dense_hash_map<int,double> int_double_hash_map;

//#define GOOGLE_SPARSE_HASH
//#define GOOGLE_DENSE_HASH

#if defined GOOGLE_DENSE_HASH
#include <google/dense_hash_map>
typedef google::dense_hash_map<int,double> int_double_hash_map;
#elif defined GOOGLE_SPARSE_HASH
#include <google/sparse_hash_map>
typedef google::sparse_hash_map<int,double> int_double_hash_map;
#elif defined(__INTEL_COMPILER) || defined(__ICL) || defined(__ICC) || defined(__ECC)
#include <ext/hash_map>
typedef __gnu_cxx::hash_map<int,double> int_double_hash_map;
#elif defined __GNUC__ 
#include <tr1/unordered_map>
typedef std::tr1::unordered_map<int,double> int_double_hash_map;
#elif defined _MSC_VER 
#include <hash_map>
typedef stdext::hash_map<int,double> int_double_hash_map;
#endif

struct bvgraph_omp_mult {
    bvgraph *g;
    //bvgraph_iterator *its;
    //long long *nsteps;
    std::vector<bvgraph_iterator> its;
    std::vector<long long> nsteps;
    int nthreads;
};

void setup_omp_mult(bvgraph *g, bvgraph_omp_mult *m)
{ 
    using namespace std;  
    int rval;
    bvgraph_iterator git;
    long long balance, avgbalance;
    long long nsteps;
    int thread;
    unsigned int d;
    
    memset(m, 0, sizeof(bvgraph_omp_mult));
    m->g = g;
    
    m->nthreads = omp_get_max_threads();
    /*m->its = (bvgraph_iterator*)malloc(sizeof(bvgraph_iterator)*m->nthreads);
    cerr << "found " << m->nthreads << " threads" << endl; 
    if (m->its == NULL) {
        cerr << "error allocating memory for omp iterators" << endl;
        exit(-1);
    }*/

    /*m->nsteps = (long long*)malloc(sizeof(long long)*m->nthreads);

    if (m->nsteps == NULL) {
        cerr << "error allocating memory for omp iterators" << endl;
        exit(-1);
    }*/

    m->its.resize(m->nthreads);
    m->nsteps.resize(m->nthreads);
    
    // run through the graph once to cache some info
    
    rval = bvgraph_nonzero_iterator(g, &git);
    if (rval) {
        cerr << "error: cannot get bvgraph iterator " << endl;
        cerr << "bvgraph error: " << bvgraph_error_string(rval) << endl;
        cerr << "halting iteration..." << endl;
        return;
    }

    avgbalance = 0;
    for (; bvgraph_iterator_valid(&git); bvgraph_iterator_next(&git)) {
        bvgraph_iterator_outedges(&git, NULL, &d);
        avgbalance += d; 
    }
    bvgraph_iterator_free(&git);
    
    avgbalance = (avgbalance + m->nthreads - 1)/m->nthreads; // get ceil rounding
    cerr << "avg balanace " << avgbalance << endl;
    // now get all the important information
    rval = bvgraph_nonzero_iterator(g, &git);
    if (rval) {
        cerr << "error: cannot get bvgraph iterator " << endl;
        cerr << "bvgraph error: " << bvgraph_error_string(rval) << endl;
        cerr << "halting iteration..." << endl;
        return;
    }
    
    balance = 0; thread = 0; nsteps = 0;
    rval = bvgraph_iterator_copy(&m->its[thread], &git);
    if (rval) {
        cerr << "error copying bvgraph iterator" << endl;
        cerr << "bvgraph error: " << bvgraph_error_string(rval) << endl;
        
        exit(-1);
    }
    
    while (bvgraph_iterator_valid(&git)) {
        if (balance >= avgbalance) {
            m->nsteps[thread]=nsteps;
            cerr << "balance on thread " << thread << " is " << balance << " with " << nsteps << " steps" << endl; 
            balance = 0; nsteps=0;
            thread++;
            rval = bvgraph_iterator_copy(&m->its[thread], &git);
            if (rval) {
                cerr << "error copying bvgraph iterator" << endl;
                cerr << "bvgraph error: " << bvgraph_error_string(rval) << endl;
                exit(-1);
            }
        }
        bvgraph_iterator_outedges(&git, NULL, &d);
        balance += d;
        bvgraph_iterator_next(&git);
        nsteps++;
    }
    bvgraph_iterator_free(&git);
    
    if (thread < m->nthreads) {
        m->nsteps[thread]=nsteps;
        // we can't get as many threads as requested
        m->nthreads = thread+1;
    }
    cerr << "balance on thread " << thread << " is " << balance << " with " << nsteps << " steps" << endl;
    cout << "using " << m->nthreads << " threads" << endl;  
}

/** 
 * Compute P'*x where P is stored by rows and we need to apply 
 * the stochastic divide ourselves.
 * 
 * This version allocates std::hash_sets and then
 * merges them at the end of the multiply.
 * 
 * The sets are re-used between multiplies
 */
void omp_mult_1(bvgraph_omp_mult *m, int nrep, double ans) 
{
    using namespace std;
    double mtime=0, ctime=0;
    stime_struct mstart, cstart;
    bvgraph *g = m->g;
    
    int rep;
    
    int rval;
    int *links; unsigned int i, d; int si, k;
    int nthreads = m->nthreads;

    vector<double> xvec(g->n,1.), yvec(g->n);
    double *x = &xvec[0], *y;
    
#if defined GOOGLE_DENSE_HASH    
    std::vector<int_double_hash_map> yvecs(0);
    for (k=0; k<m->nthreads; k++) { 
        int_double_hash_map m; m.set_empty_key(g->n); yvecs.push_back(m); }
#else
    std::vector<int_double_hash_map> yvecs(m->nthreads);    
#endif     
    double id;
    
    simple_time_clock(&cstart);
    
    for (rep = 0; rep < nrep; rep++)
    {
#pragma omp parallel for
        for (si = 0; si < g->n; si++) { 
            x[si]=1.0/(double)(rep+1); 
        }
        
        //cerr << "starting region with " << m->nthreads << " threads" << endl; 

//        for (int tnum=0; tnum<m->nthreads; tnum++)
#pragma omp parallel private(links, i, d, y, id) shared(x, g, m) num_threads(m->nthreads)
        {      
            int tnum = omp_get_thread_num();
            long long nsteps = m->nsteps[tnum];
            bvgraph_iterator git;
            int_double_hash_map &partialy=yvecs[tnum];
            
            // reset the hash_map
            {
                int_double_hash_map::iterator yit, yitend;
                yit = partialy.begin();
                yitend = partialy.end();
                while (yit!=yitend) {
                    yit->second = 0;
                    ++yit;
                }
            }

            rval = bvgraph_iterator_copy(&git, &m->its[tnum]);
            
            if (rval) {
                cerr << "error: cannot get bvgraph iterator " << endl;
                cerr << "bvgraph error: " << bvgraph_error_string(rval) << endl;
                cerr << "halting iteration..." << endl;
            }
            else {
                //cout << "got bvgraph_iter on " << tnum << " with curr = " << git.curr << endl;
            for (; bvgraph_iterator_valid(&git) && nsteps; bvgraph_iterator_next(&git), nsteps--) {
                double xval = x[git.curr];
                bvgraph_iterator_outedges(&git, &links, &d);
                if (d > 0) { xval = xval/(double)d; }
                for (i = 0; i < d; i++) {
                    //cout << tnum << " - " << git.curr << " to " << links[i] << endl;
                    partialy[links[i]] += xval;
                }
            }
                bvgraph_iterator_free(&git);
            }
        }


        simple_time_clock(&mstart);
        y = &yvec[0];
#pragma omp parallel for
        for (si=0; si<g->n; si++) { y[si]=0; }

        for (k=0; k<m->nthreads; k++) {
            int_double_hash_map::const_iterator yit, yitend;
            yit = yvecs[k].begin();
            yitend = yvecs[k].end();
            while (yit!=yitend) {
                y[yit->first] += yit->second;
                ++yit;
            }
        }
        
        mtime += elapsed_time(&mstart);
        
        double curans = 0.0;
//#pragma omp parallel for reduction(+:curans)
        for (si=0; si<g->n; si++) { curans += y[si]; }
        
        if (fabs(curans-ans/(double)(rep+1))>1e-6 ) { // large sums, so only rel accuracy
            cout << "mult 1 " << rep << " curans = " << curans << "; ans = " <<  ans/(double)(rep+1) << endl;
        }
    }
    
    ctime = elapsed_time(&cstart);
    
    cout << "sparse vecs " << endl; 
    cout << "  compute       : " << ctime << " seconds" << endl;
    cout << "  merge         : " << mtime << " seconds" << endl; 
}

/** 
 * Compute P'*x where P is stored by rows and we need to apply 
 * the stochastic divide ourselves.
 * 
 * This version allocates num_thread vectors and them
 * merges them at the end of the multiply.
 */
void omp_mult_2(bvgraph_omp_mult *m, int nrep, double ans) 
{   
    using namespace std;
    double mtime=0, ctime=0;
    stime_struct mstart, cstart;
    bvgraph *g = m->g;
    
    int rep;
    
    int rval;
    int *links; unsigned int i, d; int si;
    int nthreads = m->nthreads;

    vector<double> xvec(g->n,1.), yvec(nthreads*g->n);
    double *x = &xvec[0], *y=&yvec[0];
    double id;
    
    simple_time_clock(&cstart);
    
    for (rep = 0; rep < nrep; rep++)
    {
#pragma omp parallel for
        for (si = 0; si < g->n; si++) { 
            x[si]=1.0/(double)(rep+1); 
        }
        
#pragma omp parallel for
        for (si=0; si<g->n; si++) { y[si]=0; } 

//        for (int tnum=0; tnum<m->nthreads; tnum++)
#pragma omp parallel private(links, i, d, y, id) shared(x, g, m) num_threads(m->nthreads)
        {      
            int tnum = omp_get_thread_num();
            long long nsteps = m->nsteps[tnum];
            bvgraph_iterator git;
            y = &yvec[g->n*tnum];
            for (i=0; i<g->n; i++) { y[i] = 0.0; }
            rval = bvgraph_iterator_copy(&git, &m->its[tnum]);           

            if (rval) {
                cerr << "error: cannot get bvgraph iterator " << endl;
                cerr << "bvgraph error: " << bvgraph_error_string(rval) << endl;
                cerr << "halting iteration..." << endl;
            }
            else {
                //cout << "got bvgraph_iter on " << tnum << " with curr = " << git.curr << endl;
            for (; bvgraph_iterator_valid(&git) && nsteps; bvgraph_iterator_next(&git), nsteps--) {
                double xval = x[git.curr];
                bvgraph_iterator_outedges(&git, &links, &d);
                if (d > 0) { xval = xval/(double)d; }
                for (i = 0; i < d; i++) {
                    //cout << tnum << " - " << git.curr << " to " << links[i] << endl;
                    y[links[i]] += xval;
                }
            }
                bvgraph_iterator_free(&git);
            }
        }
        
        simple_time_clock(&mstart);
        y = &yvec[0];
        
#pragma omp parallel for if(m->nthreads>1)
        for (si=0; si<g->n; si++) {
            int k; double yi=0.; size_t n=g->n;
            for (k=0; k<m->nthreads; k++) {
                yi += y[si+k*n];
            }
            y[si] = yi;
        } 
        
        mtime += elapsed_time(&mstart);
        
        double curans = 0.0;
//#pragma omp parallel for reduction(+:curans)
        for (si=0; si<g->n; si++) { curans += y[si]; }
        
        if (fabs(curans-ans/(double)(rep+1))>1e-6 ) { // large sums, so only rel accuracy
            cout << "mult 2 " << rep << " curans = " << curans << "; ans = " <<  ans/(double)(rep+1) << endl;
        }
    }
    
    ctime = elapsed_time(&cstart);
    
    cout << "full vecs " << endl; 
    cout << "  compute       : " << ctime << " seconds" << endl;
    cout << "  merge         : " << mtime << " seconds" << endl; 
}    

/** 
 * Compute P'*x where P is stored by rows and we need to apply 
 * the stochastic divide ourselves.
 * 
 * This version uses OMP atomic to avoid multiple vectors
 */
void omp_mult_3(bvgraph_omp_mult *m, int nrep, double ans) 
{
    using namespace std;
    double ctime=0;
    stime_struct cstart;
    bvgraph *g = m->g;
    
    int rep;
    
    int rval;
    int *links; unsigned int i, d; int si, k;
    int nthreads = m->nthreads;

    vector<double> xvec(g->n,1.), yvec(g->n);
    double *x = &xvec[0], *y = &yvec[0];
    
    double id;
    
    simple_time_clock(&cstart);
    
    for (rep = 0; rep < nrep; rep++)
    {
#pragma omp parallel for
        for (si = 0; si < g->n; si++) { 
            x[si]=1.0/(double)(rep+1); 
        }
        
#pragma omp parallel for
        for (si=0; si<g->n; si++) { y[si]=0; } 

//        for (int tnum=0; tnum<m->nthreads; tnum++)
#pragma omp parallel private(links, i, d, id) shared(x, y, g, m) num_threads(m->nthreads)
        {      
            int tnum = omp_get_thread_num();
            long long nsteps = m->nsteps[tnum];
            bvgraph_iterator git;

            rval = bvgraph_iterator_copy(&git, &m->its[tnum]);           

            if (rval) {
                cerr << "error: cannot get bvgraph iterator " << endl;
                cerr << "bvgraph error: " << bvgraph_error_string(rval) << endl;
                cerr << "halting iteration..." << endl;
            }
            else {
                //cout << "got bvgraph_iter on " << tnum << " with curr = " << git.curr << endl;
            for (; bvgraph_iterator_valid(&git) && nsteps; bvgraph_iterator_next(&git), nsteps--) {
                double xval = x[git.curr];
                bvgraph_iterator_outedges(&git, &links, &d);
                if (d > 0) { xval = xval/(double)d; }
                
                for (i = 0; i < d; i++) {
#pragma omp atomic
                    y[links[i]] += xval;
                }
            }
                bvgraph_iterator_free(&git);
            }
        }

        double curans = 0.0;
//#pragma omp parallel for reduction(+:curans)
        for (si=0; si<g->n; si++) { curans += y[si]; }
        
        if (fabs(curans-ans/(double)(rep+1))>1e-6 ) { // large sums, so only rel accuracy
            cout << "mult 3 " << rep << " curans = " << curans << "; ans = " <<  ans/(double)(rep+1) << endl;
        }
    }
    
    ctime = elapsed_time(&cstart);
    
    cout << "atomic vec " << endl; 
    cout << "  compute       : " << ctime << " seconds" << endl; 
}


void serial_mult(bvgraph *g, int nrep, double ans)
{
    using namespace std;
    double ctime=0;
    stime_struct cstart;
    
    bvgraph_iterator git;
    
    int rep, si, rval;
    int *links; unsigned int i, d; double id;
    
    vector<double> xvec(g->n,1.), yvec(g->n);
    double *x = &xvec[0], *y = &yvec[0];
    
    simple_time_clock(&cstart);
    
    for (rep=0; rep<nrep; rep++) 
    {
        for (si = 0; si < g->n; si++) { 
            x[si]=1.0/(double)(rep+1); 
        }
        
        for (si = 0; si < g->n; si++) {
            y[si] = 0.0;
        }
        
        rval = bvgraph_nonzero_iterator(g, &git);
        if (rval) {
            cerr << "error: cannot get bvgraph iterator " << endl;
            cerr << "bvgraph error: " << bvgraph_error_string(rval) << endl;
            cerr << "halting iteration..." << endl;
            return;
        }
        for (; bvgraph_iterator_valid(&git); bvgraph_iterator_next(&git)) {
            double xval = x[git.curr];
            bvgraph_iterator_outedges(&git, &links, &d);
            if (d > 0) { xval = xval/(double)d; }
            
            for (i = 0; i < d; i++) {
                y[links[i]] += xval;
            }
        }
        bvgraph_iterator_free(&git);
        
        double curans = 0.0;
        for (si=0; si<g->n; si++) { curans += y[si]; }
        
        if (fabs(curans-ans/(double)(rep+1))>1e-6 ) { // large sums, so only rel accuracy
            cout << "s mult " << rep << " curans = " << curans << "; ans = " <<  ans/(double)(rep+1) << endl;
        }
    }   
    
    ctime = elapsed_time(&cstart);
    cout << "serial" << endl; 
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
    
    bvgraph_omp_mult m;
    
    setup_omp_mult(&g, &m);
    
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
    omp_mult_1(&m, nrep, ans);
    cout << "starting mult 2 " << endl;
    omp_mult_2(&m, nrep, ans);
    cout << "starting mult 3 " << endl;
    omp_mult_3(&m, nrep, ans);
    cout << "serial mult " << endl;
    serial_mult(&g, nrep, ans);

    return (0);
}
