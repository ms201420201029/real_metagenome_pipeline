#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2016, The metagenome Project"
__version__ = "1.0.0-dev"

import sys, argparse, linecache, pandas as pd

def read_params(args):
    parser = argparse.ArgumentParser(description='统计reads的使用率')
    parser.add_argument('-i', '--input', dest='input', metavar='input', type=str, required=True,
                        help="input list file")
    parser.add_argument('-clean', '--clean_reads', dest='clean_reads', metavar='clean_reads', type=str, required=True,
                        help="input clean_reads statistics file")
    parser.add_argument('-o', '--outputfile', dest='outputfile', metavar='outputfile', type=str, required=True,
                        help="out put file reads use rate")
    args = parser.parse_args()
    params = vars(args)
    return params

if __name__ == '__main__':
    params = read_params(sys.argv)
    inputfile = params["input"]
    outputfile = params["outputfile"]
    clean_reads_file = params["clean_reads"]
    samplesstat = list()
    clean_reads_stat = {}
    with open(clean_reads_file,"r") as fqin:
        fqin.next()
        for line in fqin:
            tabs = line.strip().split("\t")
            clean_reads_stat[tabs[0]] = tabs[4]

    df = pd.DataFrame(columns=["clean_reads","fungi_reads","virus_reads","bacteria_reads","archaea_reads",\
                                                          "totel_align","align_ratio"])
    with open(inputfile,"r") as fqin:
        for line in fqin:
            line = line.strip()
            sampleName = line.split("/")[-2]
            secline = linecache.getline(line, 2)
            tabs = secline.strip().split("\t")
            bac = float(tabs[0])
            arch = float(tabs[1])
            fungi = float(tabs[2])
            virus = float(tabs[3])
            totel_align = float(bac)+float(arch)+float(fungi)+float(virus)
            clean_reads = float(clean_reads_stat[sampleName].replace(",",""))
            df.loc[sampleName,"clean_reads"]=round(clean_reads,2)
            df.loc[sampleName,"bacteria_reads"]=round(bac,2)
            df.loc[sampleName,"archaea_reads"]=round(arch,2)
            df.loc[sampleName,"fungi_reads"]=round(fungi,2)
            df.loc[sampleName,"virus_reads"]=round(virus,2)
            df.loc[sampleName,"totel_align"]=round(totel_align,2)
            df.loc[sampleName,"align_ratio"]=round(totel_align/clean_reads*100,2)
    df.sort_values(by="align_ratio",ascending=False)
    df.to_csv(outputfile,sep="\t")
