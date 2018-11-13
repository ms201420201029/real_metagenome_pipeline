#!/usr/bin/env python
#-*- coding: utf-8 -*-

# Description: 
# Copyright (C) 20170808 Ruiyi Corporation
# Email: lixr@realbio.cn

import os, sys, argparse
from workflow.util.useful import mkdir, const
from jinja2 import Environment,FileSystemLoader

def read_params(args):
    parser = argparse.ArgumentParser(description='''sample_clustering analysis | v1.0  ''')
    parser.add_argument('-i', '--profile_table', dest='profile_table', metavar='FILE', type=str, required=True,
                        help="set the profile table file")
    parser.add_argument('-o', '--out_dir', dest='out_dir', metavar='DIR', type=str, required=True,
                        help="set the out work dir")
    parser.add_argument('-g', '--group_file', dest='group_file', metavar='FILE', type=str, required=True,
                        help="set the group file")
    parser.add_argument('-t', '--title', dest='title', metavar='STR', type=str, required=True,
                        help="set the title of plot")
    args = parser.parse_args()
    return vars(args)

def judge(title):
    if title in ["species","genus","phylum","order","family","class","all"]:
        title = "Top 10 main %s in all samples" % title
    elif title == "kegg":
        title = "%s Level1 Abundance in Samples" % title.upper()
    else:
        print('please set the true title, like species, genus or kegg')
    return title

if __name__ == '__main__':
    params = read_params(sys.argv)
    bin_defdir = '%s/02.taxonomy' % const.bin_default_dir
    out_dir = params["out_dir"]
    profile_table = params["profile_table"]
    group_file = params["group_file"]
    title = judge(params["title"])
    mkdir(out_dir)
    outfilepdf = out_dir+"/sample_cluster.pdf"
    env = Environment(loader=FileSystemLoader(bin_defdir),autoescape=False)
    template = env.get_template("g05_sample_clustering.R")
    Rtxt = template.render(profile_table=profile_table,\
                           group_file=group_file,\
                           outfilepdf=outfilepdf,\
                           tool_default_dir = const.tool_default_dir,\
                           title = title)
    with open("%s/sample_clustering.R"%out_dir,"w") as fqout:
        fqout.write(Rtxt)
    os.system("Rscript %s/sample_clustering.R"%out_dir)
