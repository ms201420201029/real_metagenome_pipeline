#!/usr/bin/env python
#-*- coding: utf-8 -*-

# Description: 
# Copyright (C) 20170808 Ruiyi Corporation
# Email: lixr@realbio.cn

import os, sys, argparse
from workflow.util.useful import mkdir, Rrun, const
from jinja2 import Environment,FileSystemLoader

def read_params(args):
    parser = argparse.ArgumentParser(description='''mrpp analysis | v1.0 at 2017/1/23 by huangy''')
    parser.add_argument('-i', '--profile_table', dest='profile_table', metavar='FILE', type=str, required=True,
                        help="set the profile table file")
    parser.add_argument('-g', '--group_file', dest='group_file', metavar='FILE', type=str, required=True,
                        help="set the group file")
    parser.add_argument('-o', '--out_dir', dest='out_dir', metavar='DIR', type=str, required=True,
                        help="set the output dir")
    args = parser.parse_args()
    return vars(args)

if __name__ == '__main__':
    params = read_params(sys.argv)
    bin_defdir = '%s/02.taxon' % const.bin_defdir
    mkdir(params['out_dir'])
    txt_file = params['out_dir'] +"/mrpp.txt"
    env = Environment(loader=FileSystemLoader(bin_defdir),autoescape=False)
    template = env.get_template("g10_mrpp.R")
    Rtxt = template.render(tool_default_dir=const.tool_defdir,\
                           profile_table=params['profile_table'],\
                           group_file =params['group_file'],\
                           txt_file=txt_file)
    with open("%s/mrpp.R" % params["out_dir"],"w") as fqout:
        fqout.write(Rtxt)
    Rrun("%s/mrpp.R"% params ["out_dir"])

