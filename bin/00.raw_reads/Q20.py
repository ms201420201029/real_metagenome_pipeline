#!/usr/bin/env python
# -*- coding: utf-8 -*- #
import sys
import argparse
from Bio import SeqIO
import numpy as np
import gzip
import ConfigParser
import os
import re

def read_params(args):
    parser = argparse.ArgumentParser(description='''pca analysis | v1.0 ato 2017/1/23 by huangy ''')
    parser.add_argument('-b', '--batch', dest='batch', metavar='FILE', type=str, required=True,
                        help="set the batch file")
    parser.add_argument('-c', '--config', dest='config', metavar='FILE', type=str, required=True,
                        help="set the config file")
    parser.add_argument('-o', '--out_dir', dest='out_dir', metavar='DIR', type=str, required=True,
                        help="set the output dir")
    args = parser.parse_args()
    params = vars(args)
    return params


if __name__ == '__main__':
    reload(sys)
    sys.setdefaultencoding('utf8')
    params = read_params(sys.argv)
    batch = params["batch"]
    config = params['config']
    out_dir = params["out_dir"]
    conf = ConfigParser.ConfigParser()
    conf.read(config)
    work_dir = conf.get("param","work_dir")
    raw_dir = conf.get("param","raw_dir_name")
    
    
    
    statistics = {}
    with open(batch,"r") as fqin , open(out_dir+"statistics.log","w") as outfq:
        outfq.write("name\ttotel\tQ20\tQ30\tQ20(%)\tQ30(%)\tGC(%)\n")
        for line in fqin:
            tabs = line.strip().split("\t")
            batch_name = tabs[0]
            samples_fq = os.popen("ls %s/%s/00.raw_reads/%s"%(work_dir,raw_dir,batch_name)).read().strip().split("\n")
            for sample_fq in samples_fq:
                Q20 = 0
                Q30 = 0
                totel = 0
                sample_name = re.match("(.+)\.[12]\.fq\.gz",sample_fq).group(1)
                sample_name_t = re.match("(.+\.[12])\.fq\.gz",sample_fq).group(1)
                for recond in SeqIO.parse(gzip.open("%s/%s/00.raw_reads/%s/%s"%\
                                                            (work_dir,raw_dir,batch_name,sample_fq),"r"),"fastq"):
                    quality_list = recond.letter_annotations['phred_quality']
                    quality_mean = np.mean(quality_list)
                    if quality_mean < 20:
                        totel +=1
                    elif quality_mean >= 20 and quality_mean < 30:
                        totel +=1
                        Q20 +=1
                    elif quality_mean >= 30:
                        totel +=1
                        Q30 +=1
                    else:
                        totel +=1
                        print "err"
                GC_num = os.popen("grep "+"'%GC'"+ " %s/%s/01.fastqc/%s/%s_fastqc/fastqc_data.txt"%(work_dir,raw_dir,batch_name,sample_name_t)).read().strip().split("\t")[1]
                outfq.write("%s\t%s\t%s\t%s\t%s\t%s\t%s\n"%(sample_name,totel,\
                                                        float(Q20)+float(Q30),Q30,\
                                                        (float(Q20)+float(Q30))/float(totel),\
                                                        float(Q30)/float(totel),GC_num))

