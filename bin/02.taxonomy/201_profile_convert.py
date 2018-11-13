#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2017, The metagenome Project"
__version__ = "1.0.0-dev"
import argparse
import sys

def read_params(args):
    parser = argparse.ArgumentParser(description='convert profile file to qiime otu file')
    parser.add_argument('-i', '--input', dest='input', metavar='input', type=str, required=True,
                        help="input file")
    parser.add_argument('-o', '--output', dest='output', metavar='output', type=str, required=True,
                        help="out put file")
    args = parser.parse_args()
    params = vars(args)
    return params

if __name__ == '__main__':
    params = read_params(sys.argv)
    input = params["input"]
    output = params["output"]
    with open(input,"r") as fqin ,open(output,"w") as fqout:
        fqout.write("# Constructed from biom file\n")
        fqout.write("#OTU ID")
        for line in fqin:
            line = line.replace('\'','')
            fqout.write(line)

