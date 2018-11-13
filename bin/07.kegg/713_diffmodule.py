#!/usr/bin/env python
# -*- coding: utf-8 -*- #
import sys
import argparse
import random
from jinja2 import Environment, FileSystemLoader
from workflow.util.useful import mkdir, image_trans, Rrun
from workflow.util.useful import const
import os
from scipy.special import erfinv
import numpy
from collections import defaultdict

def read_params(args):
    parser = argparse.ArgumentParser(description='''pca analysis | v1.0 at 2017/1/23 by huangy \n%s'''
                                                 %("usage:\ndiffmodule ko.profile group1.txt module2ko.list\n"))
    parser.add_argument('-i', '--profile_table', dest='profile_table', metavar='FILE', type=str, required=True,
                        help="set the profile table file")
    parser.add_argument('-g', '--group_file', dest='group_file', metavar='FILE', type=str, required=True,
                        help="set the group file")
    parser.add_argument('-o', '--out_dir', dest='out_dir', metavar='DIR', type=str, required=True,
                        help="set the output dir")
    parser.add_argument("--tab",dest="tab",metavar="FILE",type=str,required=True,
                        help="/data_center_03/USER/zhongwd/rd/Finish/07_enrich_module_and_pathway/module2KO.list")
    args = parser.parse_args()
    params = vars(args)
    return params


if __name__ == '__main__':
    reload(sys)
    sys.setdefaultencoding('utf8')
    params = read_params(sys.argv)
    bin_default_dir = const.bin_default_dir
    bin_kegg_default_dir = "%s/07.kegg/"%bin_default_dir
    out_dir = params['out_dir']
    mkdir(out_dir)
    group_file = params["group_file"]
    profile_table = params["profile_table"]
    module2ko = params["tab"]
    env = Environment(loader=FileSystemLoader(bin_kegg_default_dir), autoescape=False)
    template = env.get_template("713_diffmodule.R")
    Rtxt = template.render(profile_table=profile_table, \
                           group_file=group_file, \
                           out_dir=out_dir)
    with open("%s/diffmodule.R" % (params["out_dir"]), "w") as fqout:
        fqout.write(Rtxt)
    print os.popen("Rscript %s/diffmodule.R"%out_dir).read()
    group1name,group2name = os.popen("Rscript %s/diffmodule.R"%out_dir).read().split("@@@")

    K2M = {}
    with open(module2ko,"r") as fqin:
        for line in fqin:
            tabs = line.strip().split("\t")
            module_name = tabs.pop(0)
            for ks in tabs:
                K2M[ks]=module_name
    ##group1_zscore
    zscore = defaultdict(list)
    with open("%s/%s_group1.ko.zscore"%(out_dir,group1name)) as fqin:
        for line in fqin:
            tabs = line.strip().split("\t")
            if tabs[0] in K2M:
                zscore[K2M[tabs[0]]].append(1-float(tabs[1]))
            else:
                print "error %s"%tabs[0]

    mean_random = {}
    std_random = {}
    for key,value in zscore.items():
        zscore_tmp = []
        for i in range(10):
            k = len(zscore[key])-1 if len(zscore[key])-1 >0 else 1
            zscore_tmp.append(numpy.sum(random.sample(zscore[key],k))/numpy.sqrt(k))
        mean_random[key] = numpy.mean(zscore_tmp)
        std_random[key] = numpy.std(zscore_tmp)

    final_zscore = {}
    with open("%s/%s_group1.module.zscore"%(out_dir,group1name),"w") as fqout:
        for key,value in zscore.items():
            inv=[]
            for v in value:
                inv.append(erfinv(float(v)))
            final_zscore[key] = numpy.sum(inv)/numpy.sqrt(len(inv))
        for key,value in final_zscore.items():
   #         fqout.write("%s\t%s\n"%(key,(value-mean_random[key])/std_random[key]))
            fqout.write("%s\t%s\n"%(key,value))


    ##group2_zscore
    zscore = defaultdict(list)
    with open("%s/%s_group2.ko.zscore"%(out_dir,group2name)) as fqin:
        for line in fqin:
            tabs = line.strip().split("\t")
            if tabs[0] in K2M:
                zscore[K2M[tabs[0]]].append(1-float(tabs[1]))
            else:
                print "error %s"%tabs[0]

    mean_random = {}
    std_random = {}
    for key,value in zscore.items():
        zscore_tmp = []
        for i in range(10):
            k = len(zscore[key])-1 if len(zscore[key])-1 >0 else 1
            zscore_tmp.append(numpy.sum(random.sample(zscore[key],k))/numpy.sqrt(k))
        mean_random[key] = numpy.mean(zscore_tmp)
        std_random[key] = numpy.std(zscore_tmp)
    
    final_zscore = {}
    with open("%s/%s_group2.module.zscore"%(out_dir,group2name),"w") as fqout:
        for key,value in zscore.items():
            inv=[]
            for v in value:
                inv.append(erfinv(float(v)))
            final_zscore[key] = numpy.sum(inv)/numpy.sqrt(len(inv))
        for key,value in final_zscore.items():
#            fqout.write("%s\t%s\n"%(key,(value-mean_random[key])/std_random[key]))
            fqout.write("%s\t%s\n"%(key,value))


