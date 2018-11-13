#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2017, The metagenome Project"
__version__ = "1.0.0-dev"
import argparse
import sys
import os

def read_params(args):
    parser = argparse.ArgumentParser(description='newname | v1.0 at 2017/1/23 by huangy')
    parser.add_argument('-i', '--input', dest='input', metavar='input', type=str, required=True,
                        help="newname.list file")
    parser.add_argument("-wd,","--workdir",dest="workdir",metavar="workdir",type=str,required=True,
                        help="set project work directory ")
    args = parser.parse_args()
    params = vars(args)
    return params

if __name__ == '__main__':
    params = read_params(sys.argv)
    newname_file = params["input"]
    workdir = params["workdir"]
    with open(newname_file,"r") as fqin:
        for line in fqin:
            tabs = line.strip()
            os.system("ln -s %s/01.clean_reads/%s.1.fq.gz %s/01.clean_reads/%s.1.fq.gz "%\
                     (workdir,tabs[0],workdir,tabs[1]))
            os.system("ln -s %s/01.clean_reads/%s.2.fq.gz %s/01.clean_reads/%s.2.fq.gz "%\
                     (workdir,tabs[0],workdir,tabs[1]))
            os.system("ln -s %s/01.clean_reads/%s.single.fq.gz %s/01.clean_reads/%s.single.fq.gz "%\
                     (workdir,tabs[0],workdir,tabs[1]))
            os.system("mv %s/01.clean_reads/clean_reads.list  %s/01.clean_reads/clean_reads.list_bf"%\
                      (workdir,workdir))
            os.system("mv %s/00.raw_reads/XXX %s/00.raw_reads/XXX"%\
                      (workdir,workdir))