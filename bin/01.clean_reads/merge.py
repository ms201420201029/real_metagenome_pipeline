#!/usr/bin/env python
#-*- coding: utf-8 -*-

# Description: Compress clean reads file
# Copyright (C) 20170724 Ruiyi Corporation
# Email: lixr@realbio.cn

import os, sys, argparse
from workflow.util.useful import read_file, mkdir

def read_params(args):
    parser = argparse.ArgumentParser(description="Compress clean reads file | 2017/07/26 by lixr")
    parser.add_argument('-l', '--list', dest='list', metavar='FILE', type=str, required=True,
                        help="set the sample list")
    parser.add_argument('-c', '--clean_dir' ,dest='cdir', metavar='DIR', type=str, default='.',
                        help="set the clean reads directory")
    parser.add_argument('--host', dest='host', choices=['T','F','True','False'], metavar='STR', type=str, default='T',
                        help="set the host")
    return vars(parser.parse_args())

def prepare(dir, file, host):
    cdir = os.path.abspath(dir)
    mkdir('%s/shell' % dir)
    rdir3 = '%s/../00.raw_reads/03.qc' % cdir
    rdir5 = '%s/../00.raw_reads/05.clean_reads' % cdir
    if os.path.exists(file):
        sample = [data.split()[1] for data in read_file(file)]
    else:
        sample = set(os.popen('ls %s/*/*.1.fq | while read a; do b=${a##*/}; echo ${b%%.*}; done' % rdir3).read().strip().split('\n'))
    host = 'yes' if host=='T' or host =='True' else ''
    return cdir, rdir3, rdir5, sample, host

def main(cdir, rdir3, rdir5, sample, host):
    with open('%s/shell/GZ.sh' % cdir,'w') as outf1, open('%s/clean_reads.list' % cdir,'w') as outf2:
        for id in sample:
            fastq = list(map(lambda x:'%s/*/%s.'%(rdir5,id)+x+'.fq',['1','2','s'])) if host else list(map(lambda x:'%s/*/%s.'%(rdir3,id)+x+'.fq',['1','2','single']))
            shell = list(map(lambda x,y:'cat '+ x +' | gzip -c >%s/%s.' % (cdir, id)+ y +'.fq.gz', fastq, ['1','2','single']))
            outf1.write('\n'.join(shell) + '\n')
            outf2.write('%s\t%s/%s.1.fq.gz\t%s/%s.2.fq.gz\t%s/%s.single.fq.gz\n' % (id, cdir, id, cdir, id, cdir, id))
    os.system('/data_center_03/USER/zhongwd/bin/qsge --queue all.q --memery 8G --jobs 13 --prefix GZ --lines 1 %s/shell/GZ.sh' % cdir)

if __name__ == '__main__':
    args = read_params(sys.argv)
    cdir, rdir3, rdir5, sample, host = prepare(args['cdir'], args['list'], args['host'])
    main(cdir, rdir3, rdir5, sample, host)
