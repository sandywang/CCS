#!/bin/bash

# David Gleich,
# Copyright, Stanford University, 2008

DATADIR=/var/tmp/dgleich/data
#GRAPHS="arabic-2005 uk-2005 sk-2005 uk-2006-05 uk-2007-05"
#GRAPHS="wb-stanford"
GRAPHS="arabic-2005 sk-2005 uk-2007-05"
#GRAPHS="wb-stanford"
TOL=1e-7
ALPHA=0.99
#PROCS="1 2 3 4 6 8"
PROCS="8 6 4 3 2 1"
for p in $PROCS; do
export OMP_NUM_THREADS=$p
for g in $GRAPHS; do
  echo   ~/innout/libbvg/bvpr $DATADIR/$g _ inout $ALPHA $TOL
  time ~/svn/innout/libbvg/bvmcpr $DATADIR/$g _ inout $ALPHA $TOL | tee $g-inout-$p.log
  time ~/svn/innout/libbvg/bvmcpr $DATADIR/$g _ power $ALPHA $TOL | tee $g-power-$p.log
  time ~/svn/innout/libbvg/bvmctranspr $DATADIR/$g _ inout $ALPHA $TOL | tee $g-inout-$p-trans.log
  time ~/svn/innout/libbvg/bvmctranspr $DATADIR/$g _ power $ALPHA $TOL | tee $g-power-$p-trans.log
done
done
