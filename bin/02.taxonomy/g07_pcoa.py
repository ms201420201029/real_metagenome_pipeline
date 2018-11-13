#!/usr/bin/env python
#-*- coding: utf-8 -*-

# Description: 
# Copyright (C) 20170808 Ruiyi Corporation
# Email: lixr@realbio.cn

import os, sys, argparse
from workflow.util.useful import mkdir, Rrun, const
from jinja2 import Environment,FileSystemLoader

def read_params(args):
    parser = argparse.ArgumentParser(description='''pcoa analysis | v1.0 at 2017/1/23 by huangy ''')
    parser.add_argument('-i', '--profile_table', dest='profile_table', metavar='FILE', type=str, required=True,
                        help="set the profile table file")
    parser.add_argument('-g', '--group_file', dest='group_file', metavar='FILE', type=str, required=True,
                        help="set the group file")
    parser.add_argument('-o', '--out_dir', dest='out_dir', metavar='DIR', type=str, required=True,
                        help="set the output dir")
    parser.add_argument('--with_boxplot', dest='with_boxplot', action='store_true',
                        help="set plot boxplot")
    parser.add_argument('--without_boxplot', dest='with_boxplot', action='store_false',
                        help="set plot boxplot")
    parser.add_argument('--two_legend', dest='two_legend', action = 'store_true',default=False,
                        help="set two_legend")
    parser.add_argument('--method',dest="method",metavar='string', type=str,default="bray",
                        help="please set method Dissimilarity index, partial match to manhattan euclidean \
                         canberra bray kulczynski jaccard gower altGower morisita horn\
                          mountford raup binomial chao cao mahalanobis")
    parser.set_defaults(with_boxplot=True)
    args = parser.parse_args()
    return vars(args)

if __name__ == '__main__':
    params = read_params(sys.argv)
    bin_defdir = '%s/02.taxon' % const.bin_defdir
    mkdir(params['out_dir'])
    use_method = params["method"]
    pdf_file = params['out_dir'] +"/"+use_method+ 'pcoa.pdf'
    png_file = params['out_dir'] +"/"+use_method+ 'pcoa.png'

    env = Environment(loader=FileSystemLoader(bin_defdir),autoescape=False)
    if params['two_legend']:
        if params['with_boxplot']:
            template = env.get_template("g07_pcoa_two.R")
        else:
            template = env.get_template("g07_pcoa_two.R")
            #TODO two_legend and with_boxplot
    else:
        if params['with_boxplot']:
            template = env.get_template("g07_pcoa_with_boxplot.R")
        else:
            template = env.get_template("g07_pcoa.R")

    Rtxt = template.render(tool_default_dir=const.tool_defdir,\
                           profile_table=params['profile_table'],\
                           group_file =params['group_file'],\
                           pdf_file = pdf_file,\
                           method = use_method)
    with open("%s/pcoa.R"%(params["out_dir"]),"w") as fqout:
        fqout.write(Rtxt)
    Rrun("%s/pcoa.R" % params["out_dir"])

