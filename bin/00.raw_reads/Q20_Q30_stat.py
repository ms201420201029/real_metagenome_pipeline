#!/usr/bin/env python
#-*- coding: utf-8 -*-

# Description:  Q20, Q30
# Copyright (C) 20170724 Ruiyi Corporation
# Email: lixr@realbio.cn

import os, sys, argparse, gzip, numpy as np
from configparser import ConfigParser
from Bio import SeqIO
from utilities import parallel, mkdir

def read_params(args):
    parser = argparse.ArgumentParser(description="q20 and q30 analysis | v1.0 2017/07/24 by lixr ")
    parser.add_argument('-b', '--batch', dest='batch', metavar='FILE', type=str, required=True,
                        help="set the batch file")
    parser.add_argument('-c', '--config', dest='config', metavar='FILE', type=str, required=True,
                        help="set the config file")
    parser.add_argument('-o', '--out_dir', dest='odir', metavar='DIR', type=str, required=True,
                        help="set the output dir")
    parser.add_argument('-n', '--number', dest='num', metavar='NUMBER', type=int, default=6,
                        help="set the number of threads ")
    args = parser.parse_args()
    return vars(args)

def prepare():
    args = read_params(sys.argv)
    conf = ConfigParser()
    conf.read(args['config'])
    args['wdir'] = conf.get('param','work_dir')
    args['rdir'] = conf.get('param','raw_dir_name')
    args['rdir'] = '%s/%s' % (args['wdir'], args['rdir'])
    mkdir('%s/temp' % args['rdir'])
    return args

def statistics(args, batch_name, id):
    q20, q30, total, gc_num = 0, 0, 0, 0
    for i in [1,2]:
        file = '%s/00.raw_reads/%s/%s.%s.fq.gz' % (args['rdir'], batch_name, id, i)
        for seq_recond in SeqIO.parse(gzip.open(file,'rt'),'fastq'):
            quality_list = seq_recond.letter_annotations['phred_quality']
            quality_mean = np.mean(quality_list)
            if quality_mean >= 20 and quality_mean < 30:
                q20 += 1
            elif quality_mean >= 30:
                q20 += 1
                q30 += 1
            total += 1
        gc_num += int(os.popen('sed -n \'10p\' %s/01.fastqc/%s/%s.%s_fastqc/fastqc_data.txt | cut -f2' % (args['rdir'], batch_name, id, i)).read().strip())
    with open('%s/temp/%s_stat.log' % (args['odir'], id),'w') as outf:
        outf.write('\t'.join(map(str,[id, total, q20, q30, float(q20)/float(total)*100, float(q30)/float(total)*100, gc_num/2]))+'\n')

def main(args):
    parameter = []
    with open(args['batch'],'r') as inf:
        for line in inf:
            batch_name, filepath = line.strip().split()[:2]
            sample_name = os.popen('cut -f1 %s' % filepath).read().strip().split('\n')
            for id in sample_name:
                parameter.append({'args':args, 'batch_name':batch_name, 'id':id})
    parallel(statistics, parameter, args['num'])
    os.system('echo "Name\tTotal\tQ20\tQ30\tQ20(%%)\tQ30(%%)\tGC(%%)" | cat - %s/temp/*.log >%s/statistics.log' % (args['rdir'], args['rdir']))
    os.system('rm -rf %s/temp' % args['rdir'])

if __name__ == '__main__':
    hash = {}
    args = prepare()
    main(args)
