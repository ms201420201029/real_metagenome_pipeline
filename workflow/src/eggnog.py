#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2016, The metagenome Project"
__version__ = "1.0.0-dev"

import os, re, time
from configparser import ConfigParser
from workflow.util.useful import mkdir,parse_group,rmdir_my,gettime,const

bin_eggnog_default_dir = "%s/08.eggnog" % const.bin_default_dir
tool_default_dir = const.tool_default_dir
bin_kegg_default_dir = "%s/07.kegg" % const.bin_default_dir
command_default = const.command_default
def eggnog_pre(config, name):
    print gettime("end 08.eggnog_pre")
    commands=[]
    work_dir = '%s/%s' % (os.path.dirname(config), name)
    mkdir(work_dir)
    commands.append("## blat mapping")
    commands.append("perl %s/blatprot.pl /data_center_06/Project/pracrice/yehaocheng_20160120/08.eggnog/db.list %s/../05.gene_catalog/gene_catalog.split.list %s"%(tool_default_dir,work_dir,work_dir))
    commands.append("nohup /data_center_03/USER/zhongwd/bin/qsge --queue all.q --memery 6G --jobs 10 --prefix NOG --lines 1 %s/shell/blat.sh &"\
                    %work_dir)
    print gettime("end 08.eggnog_pre")
    return commands

def eggnog(config, name):
    print gettime("end 08.eggnog")
    commands=[]
    work_dir = '%s/%s' % (os.path.dirname(config), name)
    mkdir(work_dir)
    commands.append("rm %s/blat/all.m8"%work_dir)
    commands.append("cat %s/blat/* > %s/blat/all.m8"%(work_dir,work_dir))
    commands.append(command_default + "python %s/701_pick_blast_m8.py -i %s/blat/all.m8 -o %s/eggnog.m8"%\
                    (bin_kegg_default_dir,work_dir,work_dir))
    commands.append(command_default + "perl %s/03_get_annot_info.pl %s/eggnog.m8 /data_center_02/Database/eggNOGv4.0/all.members.txt /data_center_02/Database/eggNOGv4.0/all.description.txt /data_center_02/Database/eggNOGv4.0/all.funccat.txt %s/eggnog.m8.tab"%\
                    (bin_eggnog_default_dir,work_dir,work_dir))
    commands.append("perl %s/04_get_count.pl %s/eggnog.m8.tab /data_center_02/Database/eggNOGv4.0/eggnogv4.funccats.txt %s/eggnog.tab"%\
                    (bin_eggnog_default_dir,work_dir,work_dir))
    commands.append(command_default + "perl /data_center_07/Project/RY2015K16A01-1/08.eggnog/bin/eggnog.annotation.pl < %s/eggnog.m8.tab > %s/eggnog.anno.tsv"%\
                    (work_dir,work_dir))
#获取分组名称
    config_gene = ConfigParser()
    config_gene.read(config)
    group = re.split("\s+|\t|,\s*|,\t+",config_gene.get("param","group"))
    sample_names = config_gene.get("param","sample_name")
    sample_num_in_groups,min_sample_num_in_groups,sample_num_total,group_num=parse_group(sample_names)
    if sample_num_total<=10:
        mkdir("%s/samples"%work_dir)
        commands.append("cut -f 1 %s/../01.clean_reads/clean_reads.list | while read a ; do cut -f 1 %s/../06.gene_profile/alignment/$a/$a.gene.abundance > %s/samples/$a.gene.list; done"%\
                        (work_dir,work_dir,work_dir))
        commands.append("ls %s/samples/*gene.list | sed 's/.gene.list//g'|while read a; do perl %s/04_get_countlist.pl %s/eggnog.m8.tab /data_center_02/Database/eggNOGv4.0/eggnogv4.funccats.txt $a.gene.list $a.eggnog.tab;done"%\
                        (work_dir,bin_eggnog_default_dir,work_dir))
        commands.append("ls %s/samples/*.eggnog.tab | sed 's/.eggnog.tab//g' | while read a;do cut -f 3,4 $a.eggnog.tab > $a.eggnog.count.tab; done"%\
                        (work_dir))
        commands.append("ls %s/samples/*.eggnog.count.tab | /data_center_03/USER/zhongwd/bin/profile - > %s/eggnog.count.tab"%\
                        (work_dir,work_dir))
        commands.append("Rscript /data_center_04/Projects/pichongbingdu/pair_reads/08.eggnog/NOG.R %s/eggnog.count.tab"%\
                        work_dir)

    for subgroup_name in group:
        subgroup = '%s/material/%s_group.list' % (os.path.dirname(config), subgroup_name)
        work_dir_01 = "%s/group/%s/"%(work_dir,subgroup_name)
        mkdir(work_dir_01)
        commands.append("## ----------------------------------%s----------------------"%(subgroup_name))
        commands.append("cd %s; perl /data_center_06/Project/pracrice/yehaocheng_20160120/08.eggnog/bin/profile2list.pl %s %s/../06.gene_profile/gene.profile; cd -"%\
                        (work_dir_01,subgroup,work_dir))
        commands.append("ls %s/*gene.list | sed 's/.gene.list//g'|while read a; do perl %s/04_get_countlist.pl %s/eggnog.m8.tab /data_center_02/Database/eggNOGv4.0/eggnogv4.funccats.txt $a.gene.list $a.eggnog.tab;done"%\
                        (work_dir_01,bin_eggnog_default_dir,work_dir))
        commands.append("ls %s/*.eggnog.tab | sed 's/.eggnog.tab//g' | while read a;do cut -f 3,4 $a.eggnog.tab > $a.eggnog.count.tab; done"%\
                        (work_dir_01))
        commands.append("ls %s/*.eggnog.count.tab | /data_center_03/USER/zhongwd/bin/profile - > %s/eggnog.count.tab"%\
                        (work_dir_01,work_dir_01))
        commands.append("cd %s;Rscript /data_center_04/Projects/pichongbingdu/pair_reads/08.eggnog/NOG.R eggnog.count.tab;cd -"%\
                        (work_dir_01))
        commands.append("convert -density 300 %s/NOG.pdf %s/NOG.png" % (work_dir_01, work_dir_01))
    print gettime("end 08.eggnog")
    return commands
