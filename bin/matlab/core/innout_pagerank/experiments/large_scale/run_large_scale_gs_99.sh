#!/bin/bash

# David Gleich,
# Copyright, Stanford University, 2008

DATADIR=/var/tmp/dgleich/data
GRAPHS="arabic-2005 sk-2005 uk-2007-05"
#GRAPHS="wb-cs.stanford wb-stanford cnr-2000"
TOL=1e-7
ALPHA=0.99
ASTR=99

for g in $GRAPHS; do
  echo   ~/svn/innout/libbvg/bvtranspr $DATADIR/$g _ gs $ALPHA $TOL
  ~/svn/innout/libbvg/bvtranspr $DATADIR/$g _ gs $ALPHA $TOL _ -resid 0 > gs-$ASTR-$g.log 
done
