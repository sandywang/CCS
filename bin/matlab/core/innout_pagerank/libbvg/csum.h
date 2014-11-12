/*
 * David Gleich
 * Copyright, Stanford University, 2008
 * 10 May 2008
 */

/**
 * @file csum.h
 * Define macros to add compensated summation computations
 */

/** History
 *  2008-05-10: Initial coding based on previous macros.
 */

#ifndef CSUM_H
#define CSUM_H

/**
 * given y[2] (a vector of length 2 of summation values)
 *       x        (the new summand)
 *       t        (a temp variable)
 * CSUM(x,svals,t,z) "computes y+= x" with compensated summation
 */
/* y[0] = sum; y[1] = e */
#define CSUM(x,y,t,z) { t=y[0]; z=(x)+y[1]; y[0]=t+z; y[1]=(t-y[0])+z; }
#define FCSUM(y) (y[0]+y[1])
#define CSUM2(x,y0,y1,t,z) { t=y0; z=(x)+y1; y0=t+z; y1=(t-y0)+z; }
#define FCSUM2(y0,y1) (y0+y1)

#endif /* CSUM_H */
