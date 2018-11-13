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
                        help="set the database file")
    parser.add_argument('-o', '--out_dir', dest='out_dir', metavar='DIR', type=str, required=True,
                        help="set the output dir")
    args = parser.parse_args()
    params = vars(args)
    return params



def format_taxonomy_name(name,level):
    special = ["[","]","(",")",".","-"," ","+",":","/","'"]
    for i in special:
        name = name.replace('%s'%i,' ')
        name = re.sub(r'^\s+',"",name)
        name = re.sub(r'\s+$',"",name)                                
    name = re.sub("\s+","_",name)
    return "%s__%s"%(level,name)


if __name__ == '__main__':
    reload(sys)
    sys.setdefaultencoding('utf8')
    params = read_params(sys.argv)
    profile_table_file = params["profile_table"]
    database_file = params["database"]
    out_dir = params["out_dir"]
    abun = {}
    top = {}
    with open(profile_table_file,"r") as fqin:
        for line in fqin:
            tabs = line.strip().split("\t")
            abun[tabs[0]] =float(tabs[1])
        abun_sort = sorted(abun.items(), key=lambda d: d[1],reverse=True)
        top = dict(abun_sort[:15])
        #print top
    count ={}
    col = {}
    df = DataFrame()
    with open(database_file) as fqin , open("%s/test.tax"%out_dir,"w") as fqout:
        for line in fqin:
            (_, k, p, c, o, f, g, s,_,_) = line.strip().split("\t")
            #print s
            s_new = format_taxonomy_name(s, 's')
            if top.has_key(s_new):
                # print "test"
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
                if abun.has_key(s_new):
                    df.ix[s_out,"s"]=abun[s_new]
                    abun[k] = abun[s_new] if not abun.has_key(k) else abun[k] +abun[s_new]
                    df.ix[k_out,"k"]=abun[k]
                    abun[p] = abun[s_new] if not abun.has_key(p) else abun[p] +abun[s_new]
                    df.ix[p_out,"p"]=abun[p]
                    abun[c] = abun[s_new] if not abun.has_key(c) else abun[c] +abun[s_new]
                    df.ix[c_out,"c"]=abun[c]
                    abun[o] = abun[s_new] if not abun.has_key(o) else abun[o] +abun[s_new]
                    df.ix[o_out,"o"]=abun[o]
                    abun[f] = abun[s_new] if not abun.has_key(f) else abun[f] +abun[s_new]
                    df.ix[f_out,"f"]=abun[f]
                    abun[g] = abun[s_new] if not abun.has_key(g) else abun[g] +abun[s_new]
                    df.ix[g_out,"g"]=abun[g]
                del top[s_new]
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
