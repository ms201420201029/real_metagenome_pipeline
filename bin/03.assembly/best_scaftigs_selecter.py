#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2017, The metagenome Project"
__version__ = "1.0.0-dev"
import sys
import argparse
import os
from jinja2 import Environment, FileSystemLoader
from workflow.util.useful import mkdir, parse_group, get_name, rmdir_my, gettime
from workflow.util.useful import const
import linecache


def read_params(args):
    parser = argparse.ArgumentParser(description='''best scaftigs select analysis | v1.0 at 2017/1/9 by huangy ''')
    parser.add_argument('-i', '--in_dir', dest='in_dir', metavar='FILE', type=str, required=True,
                        help="set the input dir")
    parser.add_argument('-o', '--out_dir', dest='out_dir', metavar='DIR', type=str, required=True,
                        help="set the output dir")

    args = parser.parse_args()
    params = vars(args)
    return params


if __name__ == '__main__':
    params = read_params(sys.argv)
    profile_table = params["in_dir"]
    dir = params["out_dir"]
    mkdir(dir)
    N50={}
    with open(profile_table,"r") as fqin:
        for line in fqin:
            line = line.strip()
            tabs = line.split("/")
            kmer = tabs.pop()
            sample = tabs.pop()
            prefix = "/".join(tabs)
            if os.path.isdir(line):
                tobs=linecache.getline("%s/%s.scaftigs.stat"%(line,sample), 7).strip().split("\t")
                if sample in N50.keys():
                    title,N50[sample][kmer] = tobs[0],int(tobs[1])
                else:
                    N50[sample] = {}
                    title,N50[sample][kmer] = tobs[0],int(tobs[1])
            else:
                sys.stderr("%s is not exists"%line)
    with open("%s/../scaftigs.list"%prefix,"w")as fqout:
        for sample,subN50 in N50.items():
            print sample
            subN50 = sorted(subN50.items(),key=lambda d:d[1],reverse = True)
            print subN50
            best_kmer,_ = subN50[0]
            print best_kmer
            #best_kmer = best_kmer.keys()[0]
            tempfile1 = "%s/%s.%s.scaftigs.fna"%(dir,sample,best_kmer)
            prefixfile1 = "%s/%s/%s/%s.scaftigs.fna"%(prefix,sample,best_kmer,sample)
            tempfile2 = "%s/%s.%s.scaffold.fna"%(dir,sample,best_kmer)
            prefixfile2 = "%s/%s/%s/%s.scafSeq"%(prefix,sample,best_kmer,sample)
            template3 = "%s/%s.%s.scaftigs.stat"%(dir,sample,best_kmer)
            prefixfile3 = "%s/%s/%s/%s.scaftigs.stat"%(prefix,sample,best_kmer,sample)
            if os.path.exists(tempfile1):
                os.system("rm %s"%tempfile1)
                os.system("ln -s %s %s"%(prefixfile1,tempfile1))
            else:
                os.system("ln -s %s %s"%(prefixfile1,tempfile1))
            if os.path.exists(tempfile2):
                os.system("rm %s"%tempfile2)
                os.system("ln -s %s %s"%(prefixfile2,tempfile2))
            else:
                os.system("ln -s %s %s"%(prefixfile2,tempfile2))
            if os.path.exists(template3):
                os.system("rm %s"%template3)
                os.system("cp -f %s %s"%(prefixfile3,template3))
                os.system("echo 'Kmer\t%s'>>%s"%(best_kmer,template3))
            else:
                os.system("cp -f %s %s"%(prefixfile3,template3))
                os.system("echo 'Kmer\t%s'>>%s"%(best_kmer,template3))
            fqout.write("%s\t%s/%s.%s.scaftigs.fna\n"%(sample,dir,sample,best_kmer))
