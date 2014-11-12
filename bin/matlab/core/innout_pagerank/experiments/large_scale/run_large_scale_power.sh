#!/bin/bash

# David Gleich,
# Copyright, Stanford University, 2008

DATADIR=/var/tmp/dgleich/data
GRAPHS="arabic-2005 sk-2005 uk-2007-05"
TOL=1e-7
ALPHA=0.99
ASTR=99

for g in $GRAPHS; do
  echo   ~/svn/innout/libbvg/bvpr $DATADIR/$g _ power $ALPHA $TOL
  ~/svn/innout/libbvg/bvpr $DATADIR/$g _ power $ALPHA $TOL | tee power-$g-$ASTR.log
done

ALPHA=0.85
ASTR=85

for g in $GRAPHS; do
  echo   ~/svn/innout/libbvg/bvpr $DATADIR/$g _ power $ALPHA $TOL
  ~/svn/innout/libbvg/bvpr $DATADIR/$g _ power $ALPHA $TOL | tee power-$g-$ASTR.log
done

