#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2017, The metagenome Project"
__version__ = "1.0.0-dev"
import argparse
import sys
from workflow.util.useful import mkdir,parse_group,Rrun,image_trans,const
from jinja2 import Environment, FileSystemLoader

def read_params(args):
    parser = argparse.ArgumentParser(description='''flower analysis | v1.0 at 2017/1/23 by huangy''')
    parser.add_argument('-i', '--profile_table', dest='profile_table', metavar='input', type=str, required=True,
                        help="set profile table file")
    parser.add_argument('-l', '--level', dest='level', metavar='level', type=str, default="",
                       help="set level is genus species or none")
    parser.add_argument('-g', '--group_file', dest='group_file', metavar='group', type=str, required=True,
                        help="set group file")
    parser.add_argument('-o', '--out_dir', dest='out_dir', metavar='out_dir', type=str, required=True,
                        help="set out put dir")
    parser.add_argument('--with_group', dest='with_group', action = 'store_true',default=False,
                        help="set with_group")
    args = parser.parse_args()
    params = vars(args)
    return params

if __name__ == '__main__':
    reload(sys) 
    sys.setdefaultencoding('utf8')
    params = read_params(sys.argv)
    tool_default_dir = const.tool_default_dir
    profile_table = params["profile_table"]
    out_dir = params["out_dir"]
    out_dir = "%s/%s/"%(out_dir,params["level"])
    mkdir(out_dir)
    group_file = params["group_file"]
    _,_,_,group_num = parse_group(group_file)
    pdf_file = "%s/venn.png"%out_dir
    png_file = "%s/venn.png"%out_dir
    if group_num<6 and group_num>=2:
        env = Environment(loader=FileSystemLoader(tool_default_dir),autoescape=False)
        template = env.get_template("t07_venn_flower.R")
        Rtext = template.render(tool_default_dir = tool_default_dir,\
                                png_file=png_file,\
                                group_file = group_file,\
                                profile_table = profile_table)
        with open(out_dir + 'venn_flower.R', 'w') as fp:
            fp.write(Rtext)
        Rrun("%s/venn_flower.R"%out_dir)
        # image_trans(300,pdf_file,png_file)
    else:
        pass

