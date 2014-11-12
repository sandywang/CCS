#!/bin/bash

# David Gleich,
# Copyright, Stanford University, 2008

DATADIR=/var/tmp/dgleich/data
GRAPHS="uk-2007-05 arabic-2005 sk-2005"
TOL=1e-7
ALPHA=0.85
ASTR=85

for g in $GRAPHS; do
  ~/svn/innout/libbvg/bvtranspr $DATADIR/$g _ power $ALPHA $TOL | tee $g-power-$ASTR-1-trans.log
  ~/svn/innout/libbvg/bvtranspr $DATADIR/$g _ inout $ALPHA $TOL | tee $g-inout-$ASTR-1-trans.log
done



