#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2016, The metagenome Project"
__version__ = "1.0.0-dev"

import os, re
from configparser import ConfigParser
from workflow.util.useful import mkdir,parse_group,rmdir_my,gettime,const

bin_gene_predict_default_dir = "%s/04.gene_predict/" % const.bin_default_dir
tool_default_dir = const.tool_default_dir

def gene_predict_pre(config, name):
    print gettime("start 04.gene_predict_pre")
    commands = []
    work_dir = '%s/%s' % (os.path.dirname(config), name)
    config_gene = ConfigParser()
    config_gene.read(config)
    ins_list = config_gene.get("param","ins_list")
    mkdir(work_dir)
    commands.append("## gene_predict")
    commands.append("perl %s/GenePredict.pl -s %s/../03.assembly/scaftigs.list -l 100 -d %s"\
                    %(bin_gene_predict_default_dir,work_dir,work_dir))
    commands.append("nohup /data_center_03/USER/zhongwd/bin/qsge --queue all.q --memery 1G --jobs 10 --prefix GP --lines 2 %s/shell/predict.sh &"\
                    %work_dir)
    print gettime("end 04.gene_predict_pre")
    return commands
def gene_predict(config, name):
    print gettime("start 04.gene_predict")
    commands = []
    work_dir = '%s/%s' % (os.path.dirname(config), name)
    config_gene = ConfigParser()
    config_gene.read(config)
    ins_list = config_gene.get("param","ins_list")
    mkdir(work_dir)
    commands.append("ls gene/*fna | perl %s/stat.pl > orf.stat.tsv" % bin_gene_predict_default_dir)
    commands.append("ls gff/*gff | sed 's/.gff//g' | while read a ; do gzip -c $a.gff > $a.gff.gz;done")
    commands.append("ls gene/*fna | sed 's/.fna//g' | while read a ; do perl %s/cds2pep.pl $a.fna $a.faa; gzip -c $a.fna > $a.fna.gz; gzip -c $a.faa > $a.faa.gz; done"\
                    %tool_default_dir)
    commands.append("## histogram")
    mkdir("%s/histogram/"%work_dir)
    commands.append("cut -f 1 gene.list | while read a; do /data_center_03/USER/zhongwd/bin/lengthfasta gene/$a.gene.fna > histogram/$a.gene.length; done")
    commands.append("cut -f 1 gene.list | while read a; do Rscript %s/gene.histogram.R histogram/$a.gene.length histogram/$a.gene.histogram.pdf; done"\
                    %bin_gene_predict_default_dir)
    commands.append("cut -f 1 gene.list | while read a; do convert -density 300 histogram/$a.gene.histogram.pdf histogram/$a.gene.histogram.png; done")
    print gettime("end 04.gene_predict")
    return commands
