#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2016, The metagenome Project"
__version__ = "1.0.0-dev"

import argparse
import sys
from workflow.util.useful import const
from workflow.util.useful import parse_group_file,mkdir,Rparser,get_name,image_trans,Rrun
from jinja2 import Environment, FileSystemLoader
import os
def read_params(args):
    parser = argparse.ArgumentParser(description='''top analysis | v1.0 at 2017/1/23 by huangy ''')
    parser.add_argument('-i', '--profile_table', dest='profile_table', metavar='inputfile', type=str, required=True,
                        help="set profile table file")
    parser.add_argument('-o', '--out_dir', dest='out_dir', metavar='out_dir', type=str, required=True,
                        help="set out put dir")
    parser.add_argument('-g','--group_file',dest='group_file',metavar='group',type=str,required=True,
                        help='set group file')
    args = parser.parse_args()
    params = vars(args)
    return params
if __name__ == '__main__':
    params = read_params(sys.argv)
    bin_default_dir  = const.bin_default_dir
    out_dir = params['out_dir']
    profile_table = params['profile_table']
    pdf_file = out_dir+"top.pdf"
    png_file = out_dir+"top.png"
    group_file = params['group_file']
    vars = {'group_file': group_file,
            'pdf_file':pdf_file,
            "profile_table":profile_table
            }
    env = Environment(loader=FileSystemLoader("%s/02.taxonomy/"%bin_default_dir),autoescape=False)
    template = env.get_template("207_top.R")
    Rtext = template.render(tool_default_dir=const.tool_default_dir,\
                            group_file=group_file,\
                            pdf_file = pdf_file,\
                            profile_table = profile_table)
    with open(out_dir + '207_top.R', 'w') as fp:
        fp.write(Rtext)
    Rrun("%s/207_top.R"%out_dir)
    # os.system("convert -density 300 %s %s"%(pdfoutput,pngoutput))
