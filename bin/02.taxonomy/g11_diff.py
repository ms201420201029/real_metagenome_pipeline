#!/usr/bin/env python
#-*- coding: utf-8 -*-

# Description: 
# Copyright (C) 20170808 Ruiyi Corporation
# Email: lixr@realbio.cn

import os, sys, argparse
from utilities import mkdir, Rrun, const
from jinja2 import FileSystemLoader,Environment

def judge(value):
    if value:
        value = 'TRUE'
    else:
        value = 'FALSE'
    return value

def read_params(args):
    parser = argparse.ArgumentParser(description=''' diff analysis| v1.0 at 2016/12/23 by huangy ''')
    parser.add_argument('-i', '--profile_table', dest='profile_table', metavar='FILE', type=str, required=True,
                        help="set the profile table file")
    parser.add_argument('-o', '--out_dir', dest='out_dir', metavar='DIR', type=str, required=True,
                        help="set the out work dir")
    parser.add_argument('-g', '--group_file', dest='group_file', metavar='FILE', type=str, required=True,
                        help="set the group file")
    parser.add_argument('-c', '--cutoff', dest='cutoff', metavar='FILE', type=float, default=0.05,
                        help="set the p_value cutoff")
    parser.add_argument('-q', '--fdr', dest='fdr', metavar='FILE', type=float, default=1.1,
                        help="set the fdr cutoff")
    parser.add_argument('--paired', dest='paired', action='store_true',
                        help="paired compare")
    parser.add_argument('--test', dest='test', metavar='method',type=str,default="wilcox",
                        help="set method wilcox,t,default[wilcox]")
    parser.set_defaults(paired=False)
    args = parser.parse_args()
    params = vars(args)
    params['paired'] = judge(params['paired'])
    return params

if __name__ == '__main__':
    params = read_params(sys.argv)
    bin_defdir = '%s/02.taxon' % const.bin_defdir
    out_dir = params["out_dir"]
    profile_table = params["profile_table"]
    group_file = params["group_file"]
    use_mothed = params["test"]
    mkdir(out_dir)
    env = Environment(loader=FileSystemLoader(bin_defdir),autoescape=False)
    template = env.get_template("g11_diff.R")
    Rtext = template.render(tool_default_dir = const.tool_defdir,\
                            profile_table=profile_table,\
                            group_file=group_file,\
                            out_dir = out_dir,\
                            mothed=use_mothed,\
                            p_cutoff=params["cutoff"],\
                            fdr=params["fdr"],\
                            paired = params['paired'])
    with open("%s/diff.R" % out_dir,"w") as fqw:
        fqw.write(Rtext)
    Rrun("%s/diff.R" % out_dir)

