#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2016, The metagenome Project"
__version__ = "1.0.0-dev"

import os, re, time
from configparser import ConfigParser
from workflow.util.useful import mkdir,parse_group,rmdir_my,gettime,const

bin_ardb_default_dir = "%s/09.ardb/"%const.bin_default_dir
tool_default_dir = const.tool_default_dir
command_default = const.command_default
def ardb_pre(config, name):
    print gettime("start 09.ardb_pre")
    commands=[]
    work_dir = '%s/%s' % (os.path.dirname(config), name)
    mkdir(work_dir)
    commands.append("## blat mapping")
    commands.append("cp /data_center_03/Project/AS/16_ARDB/db.list ./")
    commands.append("perl %s/blatprot.pl db.list %s/../05.gene_catalog/gene_catalog.split.list %s/"%(tool_default_dir,work_dir,work_dir))
    commands.append("nohup /data_center_03/USER/zhongwd/bin/qsge --queue all.q --memery 5G --jobs 10 --prefix AR --lines 1 --getmem shell/blat.sh &")
    print gettime("end 09.ardb_pre")
    return commands

def ardb(config, name):
    print gettime("start 09.ardb")
    commands=[]
    work_dir = '%s/%s' % (os.path.dirname(config), name)
    mkdir(work_dir)
    commands.append("## blat mapping")
    commands.append("cat blat/* > all.m8")
    commands.append("pick_blast_m8 all.m8 > ardb.m8")
    commands.append("cut -f 2 ardb.m8 | search - /data_center_03/Project/AS/16_ARDB/old/ardbAnno1.0_modify_db07/tabs/ardb.tab | paste ardb.m8 - | cut -f 1,13-  > gene2ardb.tsv")
    commands.append("classprofile -i gene2ardb.tsv -p ../06.gene_profile/gene.profile -f 3 > ardb.type.profile")
    commands.append("classprofile -i gene2ardb.tsv -p ../06.gene_profile/gene.profile -f 4 > ardb.class.profile")
    commands.append("Rscript /data_center_07/Project/RY2015K16A01-1/09.ardb/bin/ardb.barplot.r\n")
    commands.append("(echo -e 'Gene ID\tProtein name\tType\tClass\tDescription'; cat gene2ardb.tsv) > ardb.anno.tsv")
    
    # groups
    config_gene = ConfigParser()
    config_gene.read(config)
    group = re.split("\s+|\t|,\s*|,\t+",config_gene.get("param","group"))
    for subgroup_name in group:
        subgroup = '%s/material/%s_group.list' % (os.path.dirname(config), subgroup_name)
        sample_num_in_groups,min_sample_num_in_groups,sample_num_total,group_num=parse_group(subgroup)
        commands.append("## ----------------------------------%s----------------------"%(subgroup_name))
        # diff 
        work_dir_901 = "%s/group/%s/01.class_diff/" % (work_dir,subgroup_name)
        mkdir(work_dir_901)
        work_dir_902 = "%s/group/%s/02.type_diff/" % (work_dir,subgroup_name)
        mkdir(work_dir_902)
        commands.append("#01 diff class")
        commands.append(command_default + "python %s/t08_diff.py -i %s/ardb.class.profile -g %s -o %s" % (tool_default_dir, work_dir,subgroup, work_dir_901))
        commands.append(command_default + "python %s/t09_diff_boxplot.py -i %s/diff.marker.filter.profile.tsv -p %s/diff.marker.filter.tsv -g %s -o %s/diff_boxplot/"\
                        %(tool_default_dir,work_dir_901,work_dir_901,subgroup,work_dir_901))
        commands.append("#02 diff type")
        commands.append(command_default + "python %s/t08_diff.py -i %s/ardb.class.profile -g %s -o %s" % (tool_default_dir, work_dir,subgroup, work_dir_902))
        commands.append(command_default + "python %s/t09_diff_boxplot.py -i %s/diff.marker.filter.profile.tsv -p %s/diff.marker.filter.tsv -g %s -o %s/diff_boxplot/"\
                        %(tool_default_dir,work_dir_902,work_dir_902,subgroup,work_dir_902))

        commands.append("#03 function_barplot")
        commands.append(command_default + "Rscript %s/710_level1_barplot.R %s/ardb.class.profile %s/group/%s/ardb.class.pdf Class %s"\
                        % (bin_ardb_default_dir, work_dir, work_dir, subgroup_name, subgroup))
        commands.append("convert -density 300 %s/group/%s/ardb.class.pdf %s/group/%s/ardb.class.png" % (work_dir, subgroup_name, work_dir, subgroup_name))            
        commands.append(command_default + "Rscript %s/710_level1_barplot.R %s/ardb.type.profile %s/group/%s/ardb.type.pdf Type %s"\
                        % (bin_ardb_default_dir, work_dir, work_dir, subgroup_name, subgroup))
        commands.append("convert -density 300 %s/group/%s/ardb.type.pdf %s/group/%s/ardb.type.png" % (work_dir, subgroup_name, work_dir, subgroup_name))
        
        if group_num==2:
            commands.append("#04 dimond swarm")
            commands.append(command_default + "Rscript %s/dimond_swarm.R %s/ardb.type.profile %s %s/group/%s/dimond_swarm.pdf"\
                        % (bin_ardb_default_dir, work_dir, subgroup, work_dir, subgroup_name))
            commands.append("convert -density 300 %s/group/%s/dimond_swarm.pdf %s/group/%s/dimond_swarm.png" % (work_dir, subgroup_name, work_dir, subgroup_name))
            commands.append("#05 top ardb")
            commands.append(command_default + "Rscript %s/top_ardb.R %s/ardb.type.profile %s %s/group/%s/top_ardb.pdf"\
                        % (bin_ardb_default_dir, work_dir, subgroup, work_dir, subgroup_name))
            commands.append("convert -density 300 %s/group/%s/top_ardb.pdf %s/group/%s/top_ardb.png" % (work_dir, subgroup_name, work_dir, subgroup_name))
        
    print gettime("end 009.ardb")
    return commands
