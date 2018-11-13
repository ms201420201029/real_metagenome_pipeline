#!/usr/bin/env python
# -*- coding: utf-8 -*- #

import sys, argparse
from jinja2 import Environment, FileSystemLoader
from workflow.util.useful import mkdir, image_trans, Rrun,const

def read_params(args):
    parser = argparse.ArgumentParser(description='''pca analysis | v1.0 at 2017/1/23 by huangy ''')
    parser.add_argument('-i', '--profile_table', dest='profile_table', metavar='FILE', type=str, required=True,
                        help="set the profile table file")
    parser.add_argument('-g', '--group_file', dest='group_file', metavar='FILE', type=str, required=True,
                        help="set the group file")
    parser.add_argument('-p', '--p_file', dest='p_file', metavar='FILE', type=str, required=True,
                        help="set the p value file")
    parser.add_argument('-t', '--top', dest='top', metavar='NUM', type=int,default=10,
                        help="set the top number")
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
    p_file = params["p_file"]
    mkdir(params['out_dir'])
    pdf_file = params['out_dir'] + '/diff_boxplot.pdf'
    png_file = params['out_dir'] + '/diff_boxplot.png'
    env = Environment(loader=FileSystemLoader(tool_default_dir), autoescape=False)
    template = env.get_template("t09_diff_boxplot.R")

    Rtxt = template.render(tool_default_dir=tool_default_dir, \
                           profile_table=params['profile_table'], \
                           group_file=params['group_file'], \
                           p_file=p_file,\
                           pdf_file = pdf_file,\
                           top = params["top"])
    with open("%s/diff_boxplot.R" % (params["out_dir"]), "w") as fqout:
        fqout.write(Rtxt)
    Rrun("%s/diff_boxplot.R" % params["out_dir"], )
    image_trans( pdf_file, png_file)

