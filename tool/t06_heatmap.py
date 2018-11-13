#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2017, The metagenome Project"
__version__ = "1.0.0-dev"
import sys
import argparse
from jinja2 import Environment, FileSystemLoader
from workflow.util.useful import mkdir,Rrun,image_trans,const

def read_params(args):
    parser = argparse.ArgumentParser(description='''heatmap analysis | v1.0 at 2017/1/9 by huangy ''')
    parser.add_argument('-i', '--profile_table', dest='profile_table', metavar='FILE', type=str, required=True,
                        help="set the profile table file")
    parser.add_argument('-g', '--group_file', dest='group_file', metavar='FILE', type=str, required=True,
                        help="set the group file")
    parser.add_argument('-o', '--out_dir', dest='out_dir', metavar='DIR', type=str, required=True,
                        help="set the output dir")
    parser.add_argument('--top', dest='top', metavar='INT', type=int, default=30,
                        help="set top number")
    args = parser.parse_args()
    params = vars(args)
    return params


if __name__ == '__main__':
    reload(sys)
    sys.setdefaultencoding('utf8')
    params = read_params(sys.argv)
    tool_default_dir = const.tool_default_dir
    profile_table = params["profile_table"]
    group_file = params["group_file"]
    out_dir = params["out_dir"]
    top = params["top"]
    pdf_file = "%s/heatmap.pdf"%out_dir
    png_file = "%s/heatmap.png"%out_dir
    mkdir(out_dir)

    env = Environment(loader=FileSystemLoader(tool_default_dir), autoescape=False)
    template = env.get_template("t06_heatmap.R")
    Rtxt = template.render(tool_default_dir = tool_default_dir,\
                           out_dir = out_dir,\
                           profile_table = profile_table,\
                           group_file=group_file,\
                           pdf_file = pdf_file,\
                           top=top)
    with open("%s/heatmap.R"%(params["out_dir"]),"w") as fqout:
        fqout.write(Rtxt)
    Rrun("%s/heatmap.R"%(params["out_dir"]))
    image_trans(pdf_file,png_file)
