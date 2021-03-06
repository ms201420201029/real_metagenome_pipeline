#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2016, The metagenome Project"
__version__ = "1.0.0-dev"

import os, time
from workflow.util.useful import mkdir, gettime, const

bin_default_dir = '%s/00.raw_reads' % const.bin_default_dir
tool_default_dir = const.tool_default_dir

def raw_reads(config,name):
    print gettime("start raw_reads")
    commands=[]
    main_dir = os.path.dirname(config)
    work_dir = '%s/%s' % (main_dir, name)
    mkdir(work_dir)
    commands.append('python %s/QC_main.py -b %s/material/batch.list -c %s/material/config.list -p %s' %\
                    (bin_default_dir, main_dir, main_dir, config))
    # commands.append("## Q20 Q30")
    # commands.append('cp %s/pipeline.cfg %s/pipeline.cfg' % (main_dir,work_dir))
    # commands.append('# nohup python %s/Q20_Q30_stat.py -b %s/material/batch.list -c %s/pipeline.cfg  -o . &' %\
                    # (bin_default_dir, main_dir, work_dir))
    # commands.append('python %s/Q20_Q30_stat_python2_new.py -b %s/material/batch.list -c %s/pipeline.cfg  -o . ' %\
                    # (bin_default_dir, main_dir, main_dir))
    print gettime("end raw_reads")
    return commands
