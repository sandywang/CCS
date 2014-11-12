#!/bin/bash

# David Gleich,
# Copyright, Stanford University, 2008

DATADIR=/var/tmp/dgleich/data
GRAPHS="arabic-2005 sk-2005 uk-2007-05"
TOL=1e-7
ALPHA=0.99
ASTR=99

for g in $GRAPHS; do
  ~/svn/innout/libbvg/bvtranspr $DATADIR/$g _ power $ALPHA $TOL | tee $g-power-1-trans.log
  ~/svn/innout/libbvg/bvtranspr $DATADIR/$g _ inout $ALPHA $TOL | tee $g-inout-1-trans.log
done



