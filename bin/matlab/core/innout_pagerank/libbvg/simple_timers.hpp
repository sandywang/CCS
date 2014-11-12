/*
 * David Gleich
 * Copyright, Stanford University, 2008
 * 1 May 2008
 */

/**
 * @file simple_timers.hpp
 * A few simple timing routines
 */

#ifndef SIMPLE_TIMERS_HPP
#define SIMPLE_TIMERS_HPP

#ifdef WIN32
/* Win32 code copied from 
   http://www.mail-archive.com/bug-gnulib@gnu.org/msg00823.html */
#include <time.h>
#include <sys/timeb.h>
typedef int suseconds_t;
struct timeval 
{
    time_t tv_sec;
    suseconds_t tv_usec;
};
int gettimeofday(struct timeval *tp, void *tzp)
{
    struct _timeb timebuffer;
    
    _ftime_s(&timebuffer);
    tp->tv_sec = timebuffer.time;
    tp->tv_usec = timebuffer.millitm * 1000;
    
    return 0;
}
#else

#include <sys/time.h>

#endif

typedef struct timeval stime_struct;



void simple_time_clock(stime_struct *t)
{
    gettimeofday(t,NULL);
}
double elapsed_time(stime_struct *t)
{
    stime_struct curtime;
    simple_time_clock(&curtime);
    time_t nsecs = curtime.tv_sec - t->tv_sec;
    time_t nusecs = curtime.tv_usec - t->tv_usec;
    double rval = nsecs + (1.e-6)*nusecs;
    return rval;
}




#endif // SIMPLE_TIMERS_HPP
