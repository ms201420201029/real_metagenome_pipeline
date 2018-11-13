#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2016, The metagenome Project"
__version__ = "1.0.0-dev"

import os, re, time
from configparser import ConfigParser
from workflow.util.useful import mkdir,parse_group,rmdir_my,gettime,const

bin_mgs_default_dir = "%s/MGS.V2.0/"%const.bin_default_dir
tool_default_dir = const.tool_default_dir

def mgs(config, name):
    print gettime("stat 10.mgs")
    commands=[]
    work_dir = '%s/%s' % (os.path.dirname(config), name)
    material_dir = '%s/material' % os.path.dirname(config)
    if os.path.isdir(work_dir):
        pass
    else:
        mkdir(work_dir)
    
    config_group = ConfigParser()
    config_group.read(config)
    group = re.split('\s+|,\s*|\t+|,\t*|', config_group.get('param','group'))

    for (i,subgroup_name) in enumerate(group):
        #subgroup_filename = '0' + str((i+1)) + '.' + subgroup_name
        subgroup_filename = subgroup_name
        mkdir("%s/%s" % (work_dir, subgroup_filename))
        
        sample_num_in_groups, min_sample_num_in_groups, sample_num_total, group_num = parse_group("%s/%s_group.list" % (material_dir, subgroup_name))
        if min_sample_num_in_groups >= 5 and sample_num_total >= 20 and group_num == 2:
            os.system("cp %s/%s_group.list %s/%s/group.list" % (material_dir, subgroup_name, work_dir, subgroup_filename))
            commands.append("## mgs start")
            commands.append('ls | while read a; do if [ -f "$a/group.list" ];then python %s/full_MGS_llf.py -p ../../06.gene_profile/gene.profile -g $a/group.list -d $a/; fi; done' % (bin_mgs_default_dir))
            commands.append('ls | while read a; do if [ -f "$a/group.list" ];then cd $a;sh work.sh;cd -; fi; done')
            commands.append('ls | while read a; do if [ -f "$a/group.list" ];then python %s/mgs_taxonomy.py -i $a/pathway/ -g ../05.gene_catalog/gene_catalog.fna -o $a/taxonomy/ --group $a/group.list; fi; done' % (bin_mgs_default_dir))
            commands.append('ls | while read a; do if [ -f "$a/group.list" ];then cd $a/taxonomy/;sh mgs_taxonomy.sh;cd -; fi; done')

        else:
            log = open("%s/%s/Sample_not_enough.log" % (work_dir, subgroup_filename),"w+")
            log.write("min_sample_num_in_groups >= 5 and sample_num_total >= 20 and group_num == 2")
            log.close
    return commands
