#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2016, The metagenome Project"
__version__ = "1.0.0-dev"

import os, re, time
from configparser import ConfigParser
from workflow.util.useful import mkdir,parse_group,rmdir_my,gettime,const

bin_cag_default_dir = "%s/CAG.V1.0/"%const.bin_default_dir
tool_default_dir = const.tool_default_dir

def cag(config, name):
    print gettime("stat 11.cag")
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
        if sample_num_total < 20:
            log = open("%s/%s/Sample_not_enough.log" % (work_dir, subgroup_filename),"w+")
            log.write("The minimum sample size (20) is not met.")
            log.close
        else:
            grp_sh = []

            os.system("cp %s/%s_group.list %s/%s/group.list" % (material_dir, subgroup_name, work_dir, subgroup_filename))
            grp_sh.append("python %s/full_CAG.py -p %s/../06.gene_profile/gene.profile -d %s/%s -g %s/%s/group.list" % (bin_cag_default_dir, work_dir, work_dir, subgroup_filename, work_dir, subgroup_filename))
            grp_sh.append("python %s/cag_taxonomy.py -i %s/%s/outfile/cag -g %s/../05.gene_catalog/gene_catalog.fna -o %s/%s/taxonomy/" % (bin_cag_default_dir, work_dir, subgroup_filename, work_dir, work_dir, subgroup_filename))
            grp_sh.append("python %s/cag_exe_sequence.py -d %s/%s" % (bin_cag_default_dir, work_dir, subgroup_filename))
            grp_sh.append("\n")

            with open('%s/%s/cag_pre.sh' % (work_dir, subgroup_filename), 'w') as outf:
                outf.write('\n'.join(grp_sh))
    print gettime("end 11.cag")
    