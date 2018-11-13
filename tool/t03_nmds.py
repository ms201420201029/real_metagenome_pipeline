#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2017, The metagenome Project"
__version__ = "1.0.0-dev"

import os, sys, argparse
from jinja2 import Environment,FileSystemLoader
from workflow.util.useful import mkdir,Rrun,const,image_trans

def read_params(args):
    parser = argparse.ArgumentParser(description='''nmds analysis | v1.0 at 2017/1/23 by huangy ''')
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
    params = vars(args)
    return params


if __name__ == '__main__':
    reload(sys)
    sys.setdefaultencoding('utf8')
    params = read_params(sys.argv)
    tool_default_dir = const.tool_default_dir
    mkdir(params['out_dir'])
    use_method = params["method"]
    pdf_file = params['out_dir'] +"/"+use_method+ 'nmds.pdf'
    png_file = params['out_dir'] +"/"+use_method+ 'nmds.png'

    env = Environment(loader=FileSystemLoader(tool_default_dir),autoescape=False)
    if params['two_legend']:
        if params['with_boxplot']:
            template = env.get_template("t03_nmds_two.R")
        else:
            template = env.get_template("t03_nmds_two.R")
    else:
        if params['with_boxplot']:
            template = env.get_template("t03_nmds_with_boxplot.R")
        else:
            template = env.get_template("t03_nmds.R")
    Rtxt = template.render(tool_default_dir = tool_default_dir,\
                           profile_table=params['profile_table'],\
                           group_file =params['group_file'],\
                           pdf_file = pdf_file,\
                           method = use_method)
    with open("%s/nmds.R"%(params["out_dir"]),"w") as fqout:
        fqout.write(Rtxt)
    Rrun("%s/nmds.R"%params["out_dir"])
    image_trans(pdf_file,png_file)


