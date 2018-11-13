#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2016, The metagenome Project"
__version__ = "1.0.0-dev"
import argparse
import sys
import pandas as pd
import numpy

def read_params(args):
    parser = argparse.ArgumentParser(description='level profile statistical')
    parser.add_argument('-i', '--input', dest='input', metavar='input', type=str, required=True,
                        help="input file")
    parser.add_argument('-k','--ko_profile',dest="ko_profile",metavar="ko_profile",type=str,required=True,
                        help="ko profile file")
    parser.add_argument('-o', '--outputdir', dest='outputdir', metavar='outputdir', type=str, required=True,
                        help="out put dir")
    args = parser.parse_args()
    params = vars(args)
    return params
if __name__ == '__main__':
    params=read_params(sys.argv)
    inputfile = params["input"]
    ko_profile_file = params["ko_profile"]
    outputdir = params["outputdir"]
    ko_profile = pd.DataFrame.from_csv(ko_profile_file,sep="\t")
    level1_ko = {}
    level2_ko = {}
    level3_ko = {}

    with open(inputfile,"r") as fq1:
        for line in fq1:
            if line.strip().startswith("#"):
                continue
            tabs=line.strip().split("\t")
            level1name = tabs[3]
            kos = tabs[6].split("+")
            if level1name in level1_ko.keys():
                level1_ko[level1name].extend(kos)
            else:
                level1_ko[level1name]=kos
    with open(inputfile,"r") as fq1:
        for line in fq1:
            if line.strip().startswith("#"):
                continue
            tabs=line.strip().split("\t")
            level2name = tabs[4]
            kos = tabs[6].split("+")
            if level2name in level2_ko.keys():
                level2_ko[level2name].extend(kos)
            else:
                level2_ko[level2name]=kos
    with open(inputfile,"r") as fq1:
        for line in fq1:
            if line.strip().startswith("#"):
                continue
            tabs=line.strip().split("\t")
            level3name = tabs[0]
            kos = tabs[6].split("+")
            if level3name in level3_ko.keys():
                level3_ko[level3name].extend(kos)
            else:
                level3_ko[level3name]=kos
    temp_df=[]
    for key,value in level1_ko.items():
        temp_df.append(pd.DataFrame(ko_profile.loc[value].apply(numpy.sum,axis=0),columns=[key]).T)
        result = pd.concat(temp_df)
    result.sort_index(axis=0,ascending=False)
    result.to_csv("%s/kegg_level1_profile.txt"%outputdir,sep="\t")
    temp_df2=[]
    for key,value in level2_ko.items():
        temp_df2.append(pd.DataFrame(ko_profile.loc[value].apply(numpy.sum,axis=0),columns=[key]).T)
        result = pd.concat(temp_df2)
    result.sort_index(axis=0,ascending=False)
    result.to_csv("%s/kegg_level2_profile.txt"%outputdir,sep="\t")
    temp_df3=[]
    for key,value in level3_ko.items():
        temp_df3.append(pd.DataFrame(ko_profile.loc[value].apply(numpy.sum,axis=0),columns=[key]).T)
        result = pd.concat(temp_df3)
    result.sort_index(axis=0,ascending=False)
    result.to_csv("%s/kegg_level3_profile.txt"%outputdir,sep="\t")

