#!/usr/bin/env python
# -*- coding: utf-8 -*- #

import sys
import argparse
from workflow.util.useful import parse_group_file

def read_params(args):
    parser = argparse.ArgumentParser(description=''' selected best result from kegg blat analysis | v1.0 at 2018/10/25 by huangy ''')
    parser.add_argument('-i', '--all_gene_alpha_div', dest='all_gene_alpha_div', metavar='FILE', type=str, required=True,
                        help="set the result of all gene alpha divt file")
    parser.add_argument('-g',"--group",dest="group",metavar="FILE",type=str, required=True,\
                        help="set group infomation")
    parser.add_argument('-o', '--out_file', dest='out_file', metavar='FILE', type=str, required=True,
                        help="set the output file")
    args = parser.parse_args()
    params = vars(args)
    return params

def opt_group(file, group):
    alphas = {}
    with open (file) as fqin:
        first_line = fqin.readline()
        for lines in fqin:
            tab = lines.strip().split()
            if tab[0] in group:
                group_name = group[tab[0]]
                tab[1] = tab[1].replace(',','')
                if group_name not in alphas:
                    alphas[group_name] = []
                    alphas[group_name].append(tab[1])
                else:
                    alphas[group_name].append(tab[1])
    return alphas

def write_f(alphas,out_file):
    with open(out_file,"w") as out:
        for group_name in alphas:
            num_gene = "\t".join(alphas[group_name])
            out.write('%s\t%s\n' % (group_name, num_gene))

if __name__ == "__main__":
    reload(sys)
    sys.setdefaultencoding('utf8')
    params = read_params(sys.argv)
    
    in_file = params["all_gene_alpha_div"]
    out_file = params["out_file"]
    group = parse_group_file(params["group"])
    alphas = opt_group(in_file, group)
    write_f(alphas, out_file)
