#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2016, The metagenome Project"
__version__ = "1.0.0-dev"

import os, re
from configparser import ConfigParser
from workflow.util.useful import mkdir,parse_group,rmdir_my,gettime,const

bin_gene_catalog_default_dir = "%s/05.gene_catalog/" % const.bin_default_dir
tool_default_dir = const.tool_default_dir
command_default = const.command_default

def gene_catalog_pre(config, name):
    commands = []
    print gettime("start 05.gene_catalog_pre")

    work_dir = '%s/%s' % (os.path.dirname(config), name)
    mkdir(work_dir)
    commands.append("## build gene catalog")
    commands.append("cat %s/../04.gene_predict/gene/*.fna > %s/redundant.gene_catalog.fna"\
                    %(work_dir,work_dir))
    commands.append("perl %s/cd-hit.pl %s/redundant.gene_catalog.fna %s/gene_catalog.fna 20"\
                    %(bin_gene_catalog_default_dir,work_dir,work_dir))
    print gettime("end 05.gene_catalog_pre")
    return commands

def gene_catalog(config, name):
    commands = []
    print gettime("start 05.gene_catalog")
    work_dir = '%s/%s' % (os.path.dirname(config), name)
    commands.append(command_default + "perl %s/cds2pep.pl %s/gene_catalog.fna %s/gene_catalog.faa"\
                    %(tool_default_dir,work_dir,work_dir))
    commands.append("gzip -c %s/redundant.gene_catalog.fna > %s/redundant.gene_catalog.fna.gz"\
                    %(work_dir,work_dir))
    commands.append("gzip -c %s/gene_catalog.fna > %s/gene_catalog.fna.gz"\
                    %(work_dir,work_dir))
    commands.append("gzip -c %s/gene_catalog.faa > %s/gene_catalog.faa.gz"\
                    %(work_dir,work_dir))
    commands.append("## info of gene catalog")
    commands.append(command_default + "perl %s/gene_catalog.stat.pl < %s/gene_catalog.fna > %s/gene_catalog.stat.tsv"\
                    %(bin_gene_catalog_default_dir,work_dir,work_dir))
    commands.append("perl %s/lengthfasta.pl %s/gene_catalog.fna > %s/gene_catalog.length"\
                    %(tool_default_dir,work_dir,work_dir))
    commands.append("Rscript %s/../04.gene_predict/gene.histogram.R %s/gene_catalog.length %s/gene_catalog.length.histogram.pdf"%(bin_gene_catalog_default_dir,work_dir,work_dir))
    commands.append("convert -density 300 %s/gene_catalog.length.histogram.pdf %s/gene_catalog.length.histogram.png"\
                    %(work_dir,work_dir))
    commands.append("## split gene catalog")
    commands.append("perl %s/cutfasta.pl %s/gene_catalog.faa 10 > %s/gene_catalog.split.list"\
                    %(tool_default_dir,work_dir,work_dir))
    print gettime("end 05.gene_catalog")
    return commands
