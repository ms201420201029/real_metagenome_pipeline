#!/usr/bin/env python
# -*- coding: utf-8 -*- #
import sys
import argparse
from jinja2 import Environment, FileSystemLoader
from workflow.util.useful import mkdir, image_trans, Rrun,get_name
from workflow.util.useful import const
import os


def read_params(args):
    parser = argparse.ArgumentParser(description='''pca analysis | v1.0 at 2017/1/23 by huangy ''')
    parser.add_argument('-i', '--profile_table', dest='profile_table', metavar='FILE', type=str, required=True,
                        help="set the profile table file")
    parser.add_argument('-ko', '--catalog_ko', dest='catalog_ko', metavar='FILE', type=str, required=True,
                        help="set the gene_catalog.ko  file")
    parser.add_argument('-g', '--group_file', dest='group_file', metavar='FILE', type=str, required=True,
                        help="set the group file")
    #parser.add_argument('-w', '--work_dir', dest='work_dir', metavar='DIR', type=str, required=True,
    #                    help="set the work dir example /data_center_02/Project/biyjmeta/07.kegg/")
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
    profile_table = params["profile_table"]
    group_file = params["group_file"]
#    work_dir = params["work_dir"]
    catalog_ko = params["catalog_ko"]
    dirname,subgroup_name,_ = get_name(group_file)
    group_names = os.popen("cut -f2 %s|sort|uniq"%group_file).read().strip().split("\n")
    if len(group_names)>2:
        raise Exception("group number only 2")
    diff_ko = {}
    with open(profile_table,"r") as fqin:
        for line in fqin:
            if line.startswith("taxonname"):
                continue
            tabs = line.strip().split("\t")
            if tabs[5] == group_names[0] or tabs[5] =="1":
                diff_ko[tabs[0]]=1
            if tabs[5]== group_names[1] or tabs[5] =="-1":
                diff_ko[tabs[0]]=-1
            
    with open(catalog_ko,"r") as fqko,\
            open("%s/%s.ko"%(params["out_dir"],subgroup_name),"w") as fqoutko,\
            open("%s/%s.glist"%(params["out_dir"],subgroup_name),"w") as fqoutglist:
        for line in fqko:
            if line.startswith("#"):
                continue
            if line.strip() == "":
                continue
            tabs = line.strip().split("\t")
            if len(tabs)<2:
                continue
            konum_temp = tabs[1].split("|")
            konum = konum_temp[0]
            if diff_ko.has_key(konum):
                fqoutko.write(line)
                fqoutglist.write("%s\t\t\t\t\t%s\n"%(tabs[0],diff_ko[konum]))

    with open("%s/diff.sh"%(params["out_dir"]),"w") as fqout:
        fqout.write("path=/data_center_01/pipeline/RNA_RNAseq/RNA_RNAseq_version3.0/functional\n")
        fqout.write("bg=%s\n"%(catalog_ko))
        fqout.write("workdir=%s/\n"%(params["out_dir"]))
        fqout.write("keyname=%s\n"%subgroup_name)
        fqout.write("komap=/data_center_02/Database/KEGG/20141209/komap/ko_map.tab\n")
        fqout.write("perl $path/pathfind.pl -fg $workdir/$keyname.ko -komap $komap -bg $bg -output $workdir/$keyname.path\n")
        fqout.write("perl $path/keggMap.pl -ko $workdir/$keyname.ko -komap $komap -diff $workdir/$keyname.glist -outdir $workdir/$keyname\_map\n")
    os.system("sh %s/diff.sh"%(params["out_dir"]))
