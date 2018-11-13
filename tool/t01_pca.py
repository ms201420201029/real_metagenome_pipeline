#!/usr/bin/env python
# -*- coding: utf-8 -*- #

import sys, argparse
from jinja2 import Environment,FileSystemLoader
from workflow.util.useful import mkdir,Rrun,const,image_trans

def read_params(args):
    parser = argparse.ArgumentParser(description='''pca analysis | v1.0 at 2017/1/23 by huangy ''')
    parser.add_argument('-i', '--profile_table', dest='profile_table', metavar='FILE', type=str, required=True,
                        help="set the profile table file")
    parser.add_argument('-g', '--group_file', dest='group_file', metavar='FILE', type=str, required=True,
                        help="set the group file")
    parser.add_argument('-o', '--out_dir', dest='out_dir', metavar='DIR', type=str, required=True,
                        help="set the output dir")
    parser.add_argument('--with_boxplot', dest='with_boxplot', action='store_true',
                        help="set plot boxplot")
    parser.add_argument('--without_boxplot', dest='without_boxplot', action='store_false',
                        help="not set plot boxplot")
    parser.add_argument('--two_legend', dest='two_legend', action = 'store_true',default=False,
                        help="set two_legend")
    #TODO : in Kmeans_cluster and two_legend
    parser.add_argument('--Kmeans_cluster', dest='Kmeans_cluster', action = 'store_true',default=False,
                        help="set Kmeans cluster")
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
    pdf_file = params['out_dir'] + '/pca.pdf'
    png_file = params['out_dir'] + '/pca.png'
    env = Environment(loader=FileSystemLoader(tool_default_dir),autoescape=False)
    if params["Kmeans_cluster"]:
        if params["with_boxplot"]:
            template = env.get_template("t01_pca_kmeans_withbox.R")
        else:
            template = env.get_template("t01_pca_kmeans.R")
    else:
        if params['two_legend']:
            if params['with_boxplot']:
                template = env.get_template("t01_pca_two.R")
            else:
                template = env.get_template("t01_pca_two.R")
        else:
            if params['with_boxplot']:
                template = env.get_template("t01_pca_with_boxplot.R")
            else:
                template = env.get_template("t01_pca.R")

    Rtxt = template.render(tool_default_dir = tool_default_dir,\
                           profile_table=params['profile_table'],\
                           group_file =params['group_file'],\
                           pdf_file = pdf_file)
    with open("%s/pca.R"%(params["out_dir"]),"w") as fqout:
        fqout.write(Rtxt)
    Rrun("%s/pca.R"%params["out_dir"],)
    image_trans(pdf_file,png_file)

