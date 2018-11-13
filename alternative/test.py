#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2017, The metagenome Project"
__version__ = "1.0.0-dev"

import os,sys,gzip,argparse
from jinja2 import Environment, FileSystemLoader
from workflow.util.useful import mkdir, parse_group, get_name, rmdir_my, gettime
from workflow.util.useful import const
from Bio import SeqIO

def read_params(args):
    parser = argparse.ArgumentParser(description='''randomForest analysis | v1.0 at 2017/1/9 by huangy ''')
    parser.add_argument('-i', '--fasta', dest='fa', metavar='FILE', type=str, required=True,
                        help="set the fasta  profile file")
    parser.add_argument('-t','--type',dest="type",type=str,required=True,
                        help="set fasta type")
    parser.add_argument('-s', '--sampleName', dest='sampleName', metavar='FILE', type=str, required=True,
                        help="set the sample file")
    parser.add_argument('-o', '--out_dir', dest='out_dir', metavar='DIR', type=str, required=True,
                        help="set the output dir")
    args = parser.parse_args()
    params = vars(args)
    return params

if __name__ == '__main__':
    params = read_params(sys.argv)
    fa_file = params["fa"]
    sampleName = params["sampleName"]
    out_dir = params["out_dir"]
    if params["type"]=="gz":
        handle = gzip.open(fa_file,"r")
    if params["type"]=="fa":
        handle = open(fa_file,'r')
    seq_pool = {}
    i=0
    for recond in SeqIO.parse(handle,"fasta"):
        i = i+1
        sampleName_index = "%s_i"%(sampleName,i)
        if recond.seq in seq_pool.keys():
            seq_pool[recond.seq].count += 1
        else:
            seq_pool[recond.seq] = recond
            seq_pool[recond.seq].count = 1
            seq_pool[recond.seq].sample = sampleName_index
    with open(out_dir+"derep.fa","w") as fqout:
        for k,v in seq_pool.items():
            v.id = "%s;%s;"%(v.sample,v.count)
            v.description = ''
            fqout.write(v.format("fasta"))

