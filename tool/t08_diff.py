#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2016, The metagenome Project"
__version__ = "1.0.0-dev"

import sys, argparse
from jinja2 import FileSystemLoader,Environment
from workflow.util.useful import mkdir,Rrun,const

def judge(value):
    value = 'TRUE' if value else 'FALSE'
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
    reload(sys)
    sys.setdefaultencoding('utf8')
    params = read_params(sys.argv)
    tool_default_dir = const.tool_default_dir
    out_dir = params["out_dir"]
    profile_table = params["profile_table"]
    group_file = params["group_file"]
    use_mothed = params["test"]
    mkdir(out_dir)
    env = Environment(loader=FileSystemLoader(tool_default_dir),autoescape=False)
    template = env.get_template("t08_diff.R")
    Rtext = template.render(tool_default_dir = tool_default_dir,\
                            profile_table=profile_table,\
                            group_file=group_file,\
                            out_dir = out_dir,\
                            mothed=use_mothed,\
                            p_cutoff=params["cutoff"],\
                            fdr=params["fdr"],\
                            paired = params['paired'])
    with open("%s/diff.R"%out_dir,"w") as fqw:
        fqw.write(Rtext)
    Rrun("%s/diff.R"%(out_dir))

