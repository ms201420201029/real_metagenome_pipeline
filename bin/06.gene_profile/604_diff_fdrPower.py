#!/usr/bin/env python
# -*- coding: utf-8 -*- #
import sys
import argparse
from jinja2 import Environment, FileSystemLoader
from workflow.util.useful import mkdir, image_trans, Rrun
from workflow.util.useful import const


def read_params(args):
    parser = argparse.ArgumentParser(description='''pca analysis | v1.0 at 2017/1/23 by huangy ''')
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
    pdf_file = params['out_dir'] + '/pca.pdf'
    png_file = params['out_dir'] + '/pca.png'
    env = Environment(loader=FileSystemLoader(tool_default_dir), autoescape=False)
    if params["Kmeans_cluster"]:
        if params["with_boxplot"]:
            template = env.get_template("1_pca_kmeans_withbox.R")
        else:
            template = env.get_template("1_pca_kmeans.R")
    else:
        if params['two_legend']:
            if params['with_boxplot']:
                template = env.get_template("1_pca_two.R")
            else:
                template = env.get_template("1_pca_two.R")
        else:
            if params['with_boxplot']:
                template = env.get_template("1_pca_with_boxplot.R")
            else:
                template = env.get_template("1_pca.R")

    Rtxt = template.render(tool_default_dir=tool_default_dir, \
                           profile_table=params['profile_table'], \
                           group_file=params['group_file'], \
                           pdf_file=pdf_file)
    with open("%s/pca.R" % (params["out_dir"]), "w") as fqout:
        fqout.write(Rtxt)
    Rrun("%s/pca.R" % params["out_dir"], )
    image_trans(300, pdf_file, png_file)



