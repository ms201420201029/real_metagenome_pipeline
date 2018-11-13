#!/usr/bin/env python
# -*- coding: utf-8 -*- #

import random
import sys, argparse
from workflow.util.useful import mkdir

def read_params(args):
    parser = argparse.ArgumentParser(description='''分组 | v1.0 at 2018/10/16 by liulf ''')
    parser.add_argument('-g', '--group_file', dest='group_file', metavar='FILE', type=str, required=True,
                        help="set the group file")
    parser.add_argument('-o', '--out_dir', dest='out_dir', metavar='DIR', type=str, required=True,
                        help="set the output dir")
    args = parser.parse_args()
    params = vars(args)
    return params



def read_group(group_file):
    group_dic_t = {}
    with open(group_file) as group:
        for lines in group:
            sample_name, group_name = lines.strip().split()
            if group_name not in group_dic_t:
                group_dic_t[group_name] = []
            group_dic_t[group_name].append(sample_name)
    return group_dic_t


def list_sub_group(group_dic):
    sub_group_dict = {}
    sub_group_list = []

    for i in range(1000):
        list_tmp = random.sample(group_dic, 3)
        sub_random_dic = {}
        for k in list_tmp:
            sub_random_dic[k] = group_dic[k]
        sub_group_dict[i] = sub_random_dic
        for g in sub_group_dict.values():
            if g not in sub_group_list:
                sub_group_list.append(g)
    return sub_group_list


def write_(out_d, sub_group_list):
    for sub in sub_group_list:
        sub_c_dic = "%s/%s" % (out_d, "VS".join(sub.keys()))
        mkdir(sub_c_dic)
        sub_group_name = "%s/sub_group.list" % sub_c_dic
        with open(sub_group_name, 'w+') as sub_w:
            for sub_key in sub:
                for tmp in sub[sub_key]:
                    sub_w.write("%s\t%s\n" % (tmp, sub_key))


if __name__ == "__main__":
    reload(sys)
    sys.setdefaultencoding('utf8')
    params = read_params(sys.argv)
    group = params["group_file"]
    out_d = params["out_dir"]
    group_dic = read_group(group)
    sub_group_lst = list_sub_group(group_dic)
    write_(out_d, sub_group_lst)
