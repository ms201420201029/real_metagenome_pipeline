#!/usr/bin/env python
# -*- coding: utf-8 -*- #
import sys
import argparse
import re
import pandas as pd
from pandas import DataFrame

def read_params(args):
    parser = argparse.ArgumentParser(description='''add description and drop two columns | v1.0 at 2017/5/11 by xuyh ''')
    parser.add_argument('-i', '--input.tsv', dest='input', metavar='FILE', type=str, required=True, help="set the input tsv file")
    parser.add_argument('-o', '--output.tsv', dest='output', metavar='FILE', type=str, required=True, help="set the output tsv file")
    parser.add_argument("--ko_def",dest="table",metavar="FILE",type=str, default="/data_center_09/Project/lixr/00.DATA/KEGG_DB/ko_description.tab",help="secarch the ko for it's definition")
    args = parser.parse_args()
    params = vars(args)
    return params

if __name__ == '__main__':
    reload(sys)
    sys.setdefaultencoding('utf8')
    params = read_params(sys.argv)
    in_file = params["input"]
    out_file = params["output"]
    kode = params["table"]	
#to do
    fkd = open(kode,'r')
    ftsv = open(in_file,'r')
    defi = []
    d = {}
    #make a dictionary of ko to definition
    for line in fkd:
        line = line.rstrip()
        tabs = line.split('\t')
        d[tabs[0]] = tabs[1]
    #consult the dictionary
    for line2 in ftsv:
        line2 = line2.strip()
        tabs2 = line2.split('\t')
        if tabs2[0] == "taxonname":
            continue
        if tabs2[0] in d:
            defi.append(d[tabs2[0]])
        else:
            defi.append("no description")
    f = pd.read_csv(in_file, sep = '\t')
    f.columns = ["KO ID","1","2","P-value","Q-value","Group"]
    f = f.drop(["1","2"],axis = 1)
    f["Description"] = defi
    f.to_csv(out_file,index = False,sep = '\t')
fkd.close()
ftsv.close()
