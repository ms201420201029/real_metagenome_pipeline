#!/usr/bin/env python
# -*- coding: utf-8 -*- #
import sys
import argparse
from jinja2 import Environment, FileSystemLoader
from workflow.util.useful import mkdir, image_trans, Rrun
from workflow.util.useful import const
from matplotlib import pylab as plt
import os

def read_params(args):
    parser = argparse.ArgumentParser(description='''pca analysis | v1.0 at 2017/1/23 by huangy ''')
    parser.add_argument('-i', '--profile_table', dest='profile_table', metavar='FILE', type=str, required=True,
                        help="set the profile table file")
    parser.add_argument('-g', '--group_file', dest='group_file', metavar='FILE', type=str, required=True,
                        help="set the group file")
    parser.add_argument('-o', '--out_dir', dest='out_dir', metavar='FILE', type=str, required=True,
                        help="set the out dir")
    parser.add_argument('-f', '--file_name', dest='file_name', metavar='FILE', type=str, required=True,
                        help="set the file name")
    parser.add_argument('--num', dest='num', metavar='NUM', type=int, required=True,
                        help="set the num * profile")
    args = parser.parse_args()
    params = vars(args)
    return params


if __name__ == '__main__':
    reload(sys)
    sys.setdefaultencoding('utf8')
    params = read_params(sys.argv)
    bin_default_dir = const.bin_default_dir
    bin_kegg_default_dir = "%s/07.kegg/"%(bin_default_dir)
    mkdir(params['out_dir'])
    txt_file = "%s/%s"%(params['out_dir'],params["file_name"])
    env = Environment(loader=FileSystemLoader(bin_kegg_default_dir), autoescape=False)
    template = env.get_template("708_sample2profile.R")
    Rtxt = template.render(profile_table=params['profile_table'], \
                           group_file=params['group_file'], \
                           txt_file=txt_file,\
                           num=params["num"])
    with open("%s/708_sample2profile.R" % (params["out_dir"]), "w") as fqout:
        fqout.write(Rtxt)
    Rrun("%s/708_sample2profile.R" % params["out_dir"], )
    os.system("sed -i '1s/^/ko_num\t/g' %s"%txt_file)
