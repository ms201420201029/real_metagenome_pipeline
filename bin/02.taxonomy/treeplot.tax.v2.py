#!/usr/bin/env python
# -*- coding: utf-8 -*- #
import sys
import argparse
from jinja2 import Environment, FileSystemLoader
from workflow.util.useful import mkdir, image_trans, Rrun
from workflow.util.useful import const
from pandas import DataFrame
import numpy
import re

def read_params(args):
    parser = argparse.ArgumentParser(description='''pca analysis | v1.0 at 2017/2/27 by huangy ''')
    parser.add_argument('-i', '--profile_table', dest='profile_table', metavar='FILE', type=str, required=True,
                        help="set the profile table file")
    parser.add_argument('-d', '--database', dest='database', metavar='FILE', type=str, default="/data_center_06/Database/GENOMEall.txt",
                        help="set the database file，这里可以用/data_center_04/Projects/test_Q30/test_20180802/real_metagenome_test/bin/02.taxonomy/treeplot_database.txt文件来代替")
    parser.add_argument('-o', '--out_dir', dest='out_dir', metavar='DIR', type=str, required=True,
                        help="set the output dir")
    args = parser.parse_args()
    params = vars(args)
    return params


if __name__ == '__main__':
    reload(sys)
    sys.setdefaultencoding('utf8')
    params = read_params(sys.argv)
    profile_table_file = params["profile_table"]
    database_file = params["database"]
    out_dir = params["out_dir"]
    abun = {}
    with open(profile_table_file,"r") as fqin:
        for line in fqin:
            tabs = line.strip().split("\t")
            try:
                abun[tabs[0]] =float(tabs[1])
            except Exception as err:
                print tabs[1]
        abun_sort = sorted(abun.items(), key=lambda d: d[1],reverse=True)
        top = dict(abun_sort[:15])
    count ={}
    col = {}
    df = DataFrame()
    with open(database_file) as fqin , open("%s/test.tax"%out_dir,"w") as fqout:
        for line in fqin:
            (_, k, p, c, o, f, g, s,_,_) = line.strip().split("\t")
            if top.has_key(s):
                s_out = re.sub(":","",s)
                s_out = re.sub("\.","",s_out)
                g_out = re.sub("--","--g",g)
                f_out = re.sub("--","--f",f)
                o_out = re.sub("--","--o",o)
                c_out = re.sub("--","--c",c)
                c_out = re.sub("Actinobacteria","Actinobacteria--c",c_out)
                p_out = re.sub("--","--p",p)
                k_out = re.sub("--","--k",k)
                col[k_out] = "lightblue"
                col[p_out] = "salmon"
                col[c_out] = "orange"
                col[o_out] = "lightpink"
                col[f_out] = "seagreen"
                col[g_out] = "orchid"
                col[s_out]= "royalblue"
                fqout.write("%s\t%s\t%s\t%s\t%s\t%s\t%s\n"%(k_out,p_out,c_out,o_out,f_out,g_out,s_out))
                if abun.has_key(s):
                    df.ix[s_out,"s"]=abun[s]
                    abun[k] = abun[s] if not abun.has_key(k) else abun[k] +abun[s]
                    df.ix[k_out,"k"]=abun[k]
                    abun[p] = abun[s] if not abun.has_key(p) else abun[p] +abun[s]
                    df.ix[p_out,"p"]=abun[p]
                    abun[c] = abun[s] if not abun.has_key(c) else abun[c] +abun[s]
                    df.ix[c_out,"c"]=abun[c]
                    abun[o] = abun[s] if not abun.has_key(o) else abun[o] +abun[s]
                    df.ix[o_out,"o"]=abun[o]
                    abun[f] = abun[s] if not abun.has_key(f) else abun[f] +abun[s]
                    df.ix[f_out,"f"]=abun[f]
                    abun[g] = abun[s] if not abun.has_key(g) else abun[g] +abun[s]
                    df.ix[g_out,"g"]=abun[g]
                del top[s]
                if not top:
                    break

    df2 = df/df.sum(axis=0)
    df3 = numpy.sqrt(df)*50
    with open("%s/test.info"%out_dir,"w") as fqout:
        for index, row in df.iterrows():
            index_out = re.sub(":","",index)
            index_out = re.sub("\.","",index_out)
            for col_name in df.columns:
                if not numpy.isnan(df2.ix[index_out,col_name]):
                    fqout.write("%s\t%s\t%s\t%s\n"%(index_out,col[index],df3.ix[index_out,col_name],df2.ix[index_out,col_name]))
