#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2016, The metagenome Project"
__version__ = "1.0.0-dev"
import argparse
import sys
import pandas as pd
from collections  import defaultdict
import random

def read_params(args):
    parser = argparse.ArgumentParser(description='group file change')
    parser.add_argument('-i', '--input', dest='input', metavar='input', type=str, required=True,
                        help="input file")
    parser.add_argument('-m', '--max', dest='max', metavar='max', type=int, required=True,
                        help="max")
    parser.add_argument('-b', '--by', dest='by', metavar='by', type=int, required=True,
                        help="by")
    parser.add_argument('-o', '--outputdir', dest='outputdir', metavar='outputdir', type=str, required=True,
                        help="out put dir")
    parser.add_argument('-n', '--names', dest='names', metavar='names', type=str, required=True,
                        help="names")
    args = parser.parse_args()
    params = vars(args)
    return params
if __name__ == '__main__':
    params = read_params(sys.argv)
    input = params["input"]
    maxv = params["max"]
    by = params["by"]
    names = params["names"]
    outputdir = params["outputdir"]
    reads2sp=defaultdict(set)
    j = 0
    with open(input,"r") as f:
        f.next()
        for line in f:
            j = j+1
            if j>maxv:
                break
            tabs = line.strip().split(",")
            readid = tabs[0]
            for spname in tabs[1:]:
                if spname != "":
                    reads2sp[readid].add(spname.split("\t")[0])

    with open("%s/rarefaction.txt"%(outputdir),"w") as fout:
        randomsp=set()
        fout.write("reads\t%s\n"%names)
        for i in range(maxv/by,maxv,maxv/by):
            if i>j:
                i=j-1
            else:
                for spnl in iter(random.sample(reads2sp.values(),i)):
                    for spn in iter(spnl):
                        randomsp.add(spn)
                fout.write("%s\t%s\n"%(i,len(randomsp)))

