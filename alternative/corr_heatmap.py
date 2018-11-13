#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2017, The metagenome Project"
__version__ = "1.0.0-dev"
import sys
import argparse
import os
from jinja2 import Environment, FileSystemLoader
from workflow.util.useful import mkdir, parse_group, get_name, rmdir_my, gettime
from workflow.util.useful import const


def read_params(args):
    parser = argparse.ArgumentParser(description='''corr_heatmap analysis | v1.0 at 2017/1/9 by huangy ''')
    parser.add_argument('-i', '--profile', dest='profile_table', metavar='FILE', type=str, required=True,
                        help="set the table  profile file")
    parser.add_argument('-ik', '--profile_kegg', dest='profile_kegg', metavar='FILE', type=str, required=True,
                        help="set the table of kegg profile file")
    parser.add_argument('-g', '--group_file', dest='group', metavar='FILE', type=str, required=True,
                        help="set the group file")
    parser.add_argument('-o', '--out_dir', dest='out_dir', metavar='DIR', type=str, required=True,
                        help="set the output dir")
    parser.add_argument('-c', '--cutoff', dest='cutoff', metavar='FILE', type=float, default=0.05,
                        help="set the p_value cutoff")
    parser.add_argument('-e', '--estimate', dest='estimate', metavar='FILE', type=float, default=0.7,
                        help="set the estimate cutoff")
    parser.add_argument('-l', '--level', dest='level', metavar='FILE', type=str, default="species",
                        help="set the level kingdom,phylum ,class ,order ,family,genus,species")
    parser.add_argument('--filter', dest='filter', metavar='FILE', type=str, default="pvalue",
                        help="set the filter method pvalue est")
    args = parser.parse_args()
    params = vars(args)
    return params


if __name__ == '__main__':
    reload(sys)
    sys.setdefaultencoding('utf8')
    params = read_params(sys.argv)
    profile_table = params["profile_table"]
    profile_kegg = params["profile_kegg"]
    group_file = params["group"]
    out_dir = params["out_dir"]
    cutoff_p = params["cutoff"]
    cutoff_estimate = params["estimate"]
    level = params["level"]
    filter = params["filter"]
    default_dir = const.pipeline_dir
    pdf_out = "%s/corr_heatmap.pdf"%out_dir
    png_out = "%s/corr_heatmap.png"%out_dir
    mkdir(out_dir)
    env = Environment(loader=FileSystemLoader("%s/../alternative/"%const.bin_default_dir), autoescape=False)
    template = env.get_template("corr_heatmap.R")

    Rtxt = template.render(groupfile=group_file,taxfile=profile_table,keggfile=profile_kegg,\
                          cutoff_p=cutoff_p,cutoff_estimate=cutoff_estimate,\
                           default_dir=default_dir,pdf_out=pdf_out,level=level,\
                           filter=filter)
    with open("%s/corr_heatmap.R"%out_dir, "w") as fqout:
        fqout.write(Rtxt)
    os.system("Rscript %s/corr_heatmap.R"%out_dir)
    os.system("convert -density 300 %s %s"%(pdf_out,png_out))