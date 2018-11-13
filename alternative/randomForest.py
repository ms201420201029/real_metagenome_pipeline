#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2017, The metagenome Project"
__version__ = "1.0.0-dev"
import sys
import argparse
import os
from jinja2 import Environment,FileSystemLoader
from workflow.util.useful import mkdir,parse_group,get_name,rmdir_my,gettime
from workflow.util.useful import const
def read_params(args):
    parser = argparse.ArgumentParser(description='''randomForest analysis | v1.0 at 2017/1/9 by huangy ''')
    parser.add_argument('-i', '--profile', dest='profile_table', metavar='FILE', type=str, required=True,
                        help="set the table  profile file")
    parser.add_argument('-g', '--group_file', dest='group', metavar='FILE', type=str, required=True,
                        help="set the group file")
    parser.add_argument('-y', '--independent_variable', dest='independent_variable', metavar='FILE', type=str, required=True,
                        help="set the independent variable file")
    parser.add_argument('-o', '--out_dir', dest='out_dir', metavar='DIR', type=str, required=True,
                        help="set the output dir")
    args = parser.parse_args()
    params = vars(args)
    return params


if __name__ == '__main__':
    params = read_params(sys.argv)
    profile_table = params["profile_table"]
    group_file = params["group_file"]
    out_dir = params["out_dir"]
    independent_variable = params["independent_variable"]
    env = Environment(loader=FileSystemLoader(),autoescape=False)
    template = env.get_template()
    Rtxt = template.render()
    with open("","w") as fqout:
        fqout.write(Rtxt)


