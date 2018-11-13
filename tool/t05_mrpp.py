#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2017, The metagenome Project"
__version__ = "1.0.0-dev"

import sys, argparse
from jinja2 import Environment,FileSystemLoader
from workflow.util.useful import mkdir,Rrun,const

def read_params(args):
    parser = argparse.ArgumentParser(description='''mrpp analysis | v1.0 at 2017/1/23 by huangy''')
    parser.add_argument('-i', '--profile_table', dest='profile_table', metavar='FILE', type=str, required=True,
                        help="set the profile table file")
    parser.add_argument('-g', '--group_file', dest='group_file', metavar='FILE', type=str, required=True,
                        help="set the group file")
    parser.add_argument('-o', '--out_dir', dest='out_dir', metavar='DIR', type=str, required=True,
                        help="set the output dir")
    args = parser.parse_args()
    params = vars(args)
    return params

if __name__ == '__main__':
    reload(sys)
    sys.setdefaultencoding('utf8')
    params = read_params(sys.argv)
    tool_default_dir = const.tool_default_dir
    mkdir(params['out_dir'])
    txt_file = params['out_dir'] +"/mrpp.txt"
    env = Environment(loader=FileSystemLoader(tool_default_dir),autoescape=False)
    template = env.get_template("t05_beta_mrpp.R")
    Rtxt = template.render(tool_default_dir=tool_default_dir,\
                           profile_table=params['profile_table'],\
                           group_file =params['group_file'],\
                           txt_file=txt_file)
    with open("%s/mrpp.R"%params["out_dir"],"w") as fqout:
        fqout.write(Rtxt)
    Rrun("%s/mrpp.R"%params["out_dir"])

