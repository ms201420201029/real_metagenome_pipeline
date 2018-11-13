#!/usr/bin/env python
# -*- coding: utf-8 -*- #
import sys
import argparse
from jinja2 import Environment, FileSystemLoader
from workflow.util.useful import mkdir, image_trans, Rrun
from workflow.util.useful import const
import pandas as pd


def read_params(args):
    parser = argparse.ArgumentParser(description='''pca analysis | v1.0 at 2017/1/23 by huangy ''')
    parser.add_argument('-i', '--statistics', dest='statistics', metavar='FILE', type=str, required=True,
                        help="set the statistics file; example standard.log")
    parser.add_argument('-s', '--standard', dest='standard', metavar='FILE', type=str, required=True,
                        help="set the standard file ;example raw_reads.stat.tsv ")
    parser.add_argument('-o', '--out_file', dest='out_file', metavar='FILE', type=str, required=True,
                        help="set the output file")
    args = parser.parse_args()
    params = vars(args)
    return params


if __name__ == '__main__':
    reload(sys)
    sys.setdefaultencoding('utf8')
    params = read_params(sys.argv)
    tool_default_dir = const.tool_default_dir
    standard = params["standard"]
    statistics = params["statistics"]
    out_file = params["out_file"]
    df = pd.DataFrame(columns=["totel","Q20","Q30","Q20%","Q30%","GC","GC%"])
    sampleNames = []
    with open(statistics,"r") as fqin:
        for line in fqin:
            
            if line.startswith("name"):
                continue
            tabs = line.strip().split("\t")
            sampleName = tabs[0]
            if sampleName in sampleNames:
                df.ix[sampleName,"totel"] = df.ix[sampleName,"totel"]+float(tabs[1])
                df.ix[sampleName,"Q20"] = df.ix[sampleName,"Q20"]+float(tabs[2])
                df.ix[sampleName,"Q30"] = df.ix[sampleName,"Q30"]+float(tabs[3])
                df.ix[sampleName,"GC"] = df.ix[sampleName,"GC"]+float(tabs[1])*float(tabs[6])/100
            else:
                df.ix[sampleName,"totel"] = float(tabs[1])
                df.ix[sampleName,"Q20"] = float(tabs[2])
                df.ix[sampleName,"Q30"] = float(tabs[3])
                df.ix[sampleName,"GC"] = float(tabs[1])*float(tabs[6])/100
                sampleNames.append(sampleName)
    df.ix[:,"Q20%"] = df.ix[:,"Q20"]/df.ix[:,"totel"]
    df.ix[:,"Q30%"] = df.ix[:,"Q30"]/df.ix[:,"totel"]
    df.ix[:,"GC%"] = df.ix[:,"GC"]/df.ix[:,"totel"]
    with open(standard,"r") as fqin ,open(out_file,"w") as fqout:
        for line in fqin:
            tabs = line.strip().split("\t")
            if tabs[0] in sampleNames:
                fqout.write("%s\t%.2f\t%.2f\t%.2f\n"%("\t".join(tabs),df.ix[tabs[0],"Q20%"],df.ix[tabs[0],"Q30%"],df.ix[tabs[0],"GC%"]))
            else:
                fqout.write("%s\t\t\t\n"%("\t".join(tabs)))



