#!/usr/bin/env python

# stringmatch2graph.pl
# Output a graph file for a string matching result from our wikipedia2lcsh
# program
#
# 10 October 2007
# Initial version

import sys;
import string;

def print_usage():
    print >> sys.stderr, "stringmatch2graph.pl matchfile [type] > graphfile.smat"
    print >> sys.stderr, "  type:  1  str|score|id"
    print >> sys.stderr, "         2  str,id"
    sys.exit(-1);
    
def parse_nonzero(nzstr,type):
    if type == 1:
        parts = string.split(nzstr,"|")
        return (parts[2],parts[1])
    elif type == 2:
        parts = string.split(nzstr,",")
        return (parts[1])
    else:
        raise SystemError("Invalid type %s" % type)

def main():
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print_usage()

    matchfilename = sys.argv[1]
    type = 1
    
    if len(sys.argv) == 3:
        type = int(sys.argv[2])

    # try parsing a nonzero with type to throw an error if its wrong
    parse_nonzero("test,help|3|2",type)

    matchfile = open(sys.argv[1],"rt")
    
    maxid1 = 0
    maxid2 = 0
    nzcount = 0
    
    for line in matchfile:
        line.rstrip()
        parts = line.split('\t')
        maxid1 = max(maxid1,int(parts[0]))
        for p in parts[2:]:
            nz = parse_nonzero(p,type)
            maxid2 = max(maxid2,int(nz[0]))
            nzcount += 1

    print >> sys.stdout, "%d %d %d" % (maxid1+1, maxid2+1, nzcount)
    
    print >> sys.stderr, "left size: %d" % (maxid1+1)
    print >> sys.stderr, "right size: %d" % (maxid2+1)
    print >> sys.stderr, "edges: %d" % nzcount
    
    # reset the file pointer
    matchfile.seek(0)
    
    for line in matchfile:
        line.rstrip()
        parts = line.split('\t')
        id1 = int(parts[0])
        for p in parts[2:]:
            nz = parse_nonzero(p,type)
            id2 = int(nz[0])
            if len(nz) > 1:
                print >> sys.stdout, "%d %d %s" % (id1, id2, nz[1])
            else:
                print >> sys.stdout, "%d %d 1" % (id1, id2)
      
# run main
main()