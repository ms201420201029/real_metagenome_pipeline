#!/usr/bin/env python
#-*- coding: utf-8 -*-

# Description: 
# Copyright (C) 20170706 Ruiyi Corporation
# Email: lixr@realbio.cn

import os
from workflow.util.useful import mkdir, gettime, const

bin_defdir = '%s/01.clean_reads' % const.bin_default_dir
tool_defdir = const.tool_default_dir

def clean_reads(config, name):
    print gettime("start raw_reads")
    commands=[]
    main_dir = os.path.dirname(config)
    work_dir = '%s/%s' % (main_dir, name)
    mkdir(work_dir)
    commands.append('nohup python %s/merge.py -l %s/material/sample.list -c %s/ &' %\
                    (bin_defdir, main_dir, work_dir))
    commands.append('awk -F "\\t" \'{print $1"\\t"$2"\\t"$3"\\t"$4"\\t"$5"\\t"$6"\\t"$7}\' %s/00.raw_reads/qc_*.stat.tsv > %s/qc_stat.tsv' %\
                    (main_dir, work_dir))
    print gettime("end raw_reads")
    return commands

