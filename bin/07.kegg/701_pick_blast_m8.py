#!/usr/bin/env python
# -*- coding: utf-8 -*- #
import sys
import argparse
from jinja2 import Environment, FileSystemLoader
from workflow.util.useful import mkdir, image_trans, Rrun
from workflow.util.useful import const
import collections

def read_params(args):
    parser = argparse.ArgumentParser(description=''' selected best result from kegg blat analysis | v1.0 at 2017/1/23 by huangy ''')
    parser.add_argument('-i', '--blat_m8_file', dest='blat_m8_file', metavar='FILE', type=str, required=True,
                        help="set the result of blat m8 format file")
    #TODO : the best hit = 1
    parser.add_argument('-o', '--out_file', dest='out_file', metavar='FILE', type=str, required=True,
                        help="set the output file")
    parser.add_argument("--minScore",dest="minScore",metavar="NUM",type=int,default=60,\
                        help="set min score for filter")
    args = parser.parse_args()
    params = vars(args)
    return params

if __name__ == '__main__':
    reload(sys)
    sys.setdefaultencoding('utf8')
    params = read_params(sys.argv)
    in_file = params["blat_m8_file"]
    out_file = params["out_file"]
    minScore = params["minScore"]
    minScore = float(minScore)
    queryScore = {}
    m8out = collections.OrderedDict()
    with open(in_file,"r") as fqin:
        for line in fqin:
            tabs = line.strip().split("\t")
            #origin is \s+
            if float(tabs[-1])<float(minScore):
                continue
            if tabs[0] in queryScore:
                if queryScore[tabs[0]]<float(tabs[-1]):
                    queryScore[tabs[0]] = float(tabs[-1])
                    m8out[tabs[0]] = line
            else:
                queryScore[tabs[0]] = float(tabs[-1])
                m8out[tabs[0]] = line
    with open(out_file,"w") as fqout:
        for key,value in m8out.items():
            fqout.write(value)
