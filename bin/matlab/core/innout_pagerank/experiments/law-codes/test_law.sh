#!/bin/sh

# David Gleich
# Copyright, Stanford University

# History
# 2008-05-15: Initial coding
#
#             ** My Gauss Seidel and the law-1.3.1 Gauss Seidel produce identical
#             per-iteration vector changes.  (Identical was equivalent to 
#             about 4 decimal places on a visual inspection.)

JAVA=/usr/java/jdk1.6.0_02/bin/java
#JAVA=java
JARDIR=../../jars
JARS=\
$JARDIR/fastutil5-5.1.1.jar:\
$JARDIR/colt-1.2.0.jar:\
$JARDIR/log4j-1.2.12.jar:\
$JARDIR/webgraph-2.1.jar:\
$JARDIR/dsiutils-1.0.jar:\
$JARDIR/jsap-2.0.jar:\
$JARDIR/mg4j-2.0.jar:\
$JARDIR/law-1.3.1.jar:\
$JARDIR/jakarta-commons-configuration-1.2.jar:\
$JARDIR/jakarta-commons-lang-2.3.jar

$JAVA -cp $JARS it.unimi.dsi.law.rank.PageRankGaussSeidel \
  ../../data/wb-cs.stanford-trans test -a 0.99 -t 1e-7
rm test.ranks


