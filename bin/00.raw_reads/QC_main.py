#!/usr/bin/env python
#-*- coding: utf-8 -*-

# Description:  QC
# Copyright (C) 20170719 Ruiyi Corporation
# Email: lixr@realbio.cn

import os, re, sys, argparse
from workflow.util.useful import read_file, mkdir

def read_params(args):
    parser = argparse.ArgumentParser(description = "QC 2017/07/19 by lixr")
    parser.add_argument('-b','--batch',dest='batchfile',metavar='FILE',type=str,required=True,
                        help="please set the batch file")
    parser.add_argument('-c','--config',dest='config',metavar='FILE',type=str,required=True,
                        help="please set the config file")
    parser.add_argument('-p', '--pipeline', dest='pipeline', metavar='FILE', type=str, required=True,
                        help="set the pipeline file")
    return vars(parser.parse_args())

def read_batch(file):
    sample, batchs, rep_batch = {}, [], []
    for data in read_file(file):
        if re.match('#',data):
            continue
        batch, sample_list = data.split()[:2]
        sample[batch] = sample_list
        condition = data.split()[2] if len(data.split()) > 2 else ''
        if condition == 'Run':
            sys.stdout.write('Batch: %s is still running! If not, please check whether it ends with error!\n' % batch)
            continue
        elif condition == 'End':
            sys.stdout.write('Batch: %s has been done! Please check the batch file.\n' % batch)
            continue
        if batch not in batchs:
            if condition == '':
                batchs.append(batch)
        else:
            rep_batch.append(batch)
            sys.stdout.write('Batch: %s exists! Please check!\n' % batch)
            continue
    batchs = [x for x in batchs if x not in rep_batch]
    return batchs, sample

def refresh(batchfile, batch, condition):
    with open(batchfile,'r') as outf:
        with open(batchfile+'.bak','w') as inf:
            for data in outf.readlines():
                id = data.strip().split()[0]
                if id == batch:
                    inf.write('\t'.join(data.strip().split()[:2])+'\t'+condition+'\n')
                else:
                    inf.write(data)
    os.system('mv -f %s %s' % (batchfile+'.bak', batchfile))

def getpara(configfile):
    para = {}
    for data in read_file(configfile):
        key, value = data.split()
        if re.match('#',key):
            continue
        para[key] = '--%s %s' % (key, value)
    return para

def qc_prepare(batch, sample_list, dir, host, type):
    sub_dir = []
    dir = dir.split()[1]
    host = host.split()[1]
    if not sample_list and not os.path.exists(sample_list):
        return 
    scr_dir = os.path.dirname(os.path.abspath(__file__))
    if host:
        selects = ['00.raw_reads','01.fastqc','02.rmadaptor','03.qc','04.rmhost','05.clean_reads']
    else:
        selects = ['00.raw_reads','01.fastqc','02.rmadaptor','03.qc']
    for name in selects:
        mkdir('%s/%s/%s' % (dir, name, batch))
        sub_dir.append('%s/%s/%s' % (dir, name, batch))
    mkdir('%s/shell' % dir)
    type = '-y' if type == '--type 33' else ''
    os.system('cp -f %s %s/%s_sample.list' % (sample_list, sub_dir[0], batch))
    return sample_list, sub_dir, type, scr_dir, dir, type, host

def write_qc_sh(sample_list, dir, batch, sub_dir, host, type, scr_dir):
    adaptor_1 = 'GATCGGAAGAGCACACGTCTGAACTCCAGTCAC'
    adaptor_2 = 'GATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT'
    with open('%s/shell/QC_%s.sh' % (dir, batch), 'w') as inf:
        for data in read_file(sample_list):
            sample_id, raw_reads1, raw_reads2 = data.split()
            if os.path.exists(raw_reads1) and os.path.exists(raw_reads2):
                os.system('ln -s %s %s/%s.1.fq.gz' % (raw_reads1, sub_dir[0], sample_id))
                os.system('ln -s %s %s/%s.2.fq.gz' % (raw_reads2, sub_dir[0], sample_id))
            else:
                sys.stdout.write('%s or %s in the %s doesn\'t exists!' % (raw_reads1, raw_reads2, sample_list))
                continue
            if host:
                inf.write('/data_center_01/pipeline/MetaGenome/v1.0/soft/FastQC/fastqc -q --extract -nogroup -o %s %s/%s.1.fq.gz\n'%(sub_dir[1], sub_dir[0], sample_id))
                inf.write('/data_center_01/pipeline/MetaGenome/v1.0/soft/FastQC/fastqc -q --extract -nogroup -o %s %s/%s.2.fq.gz\n'%(sub_dir[1], sub_dir[0], sample_id))
                #inf.write('python %s/rmAdaptor.py --type PE -r1 %s/%s.1.fq.gz -r2 %s/%s.2.fq.gz -a1 %s -a2 %s --out_prefix %s/%s --out_type 2\n' % (scr_dir, sub_dir[0], sample_id, sub_dir[0], sample_id, adaptor_1, adaptor_2, sub_dir[2], sample_id))
                inf.write('python %s/rmAdaptor_20180110.py --type PE -r1 %s/%s.1.fq.gz -r2 %s/%s.2.fq.gz -a1 %s -a2 %s --out_prefix %s/%s --out_type 2\n' % (scr_dir, sub_dir[0], sample_id, sub_dir[0], sample_id, adaptor_1, adaptor_2, sub_dir[2], sample_id))
                inf.write('%s/QC %s -o %s/%s.1.fq %s/%s.2.fq %s/%s\n' % (scr_dir, type, sub_dir[2], sample_id, sub_dir[2], sample_id, sub_dir[3], sample_id))
                inf.write('soap -r 1 -p 10 -m 100 -x 1000 -a %s/%s.1.fq -b %s/%s.2.fq -D %s.index -o %s/%s.pm -2 %s/%s.sm\n' % (sub_dir[3], sample_id, sub_dir[3], sample_id, host, sub_dir[4], sample_id, sub_dir[4], sample_id))
                inf.write('soap -r 1 -p 10 -a %s/%s.single.fq -D %s.index -o %s/%s.single.m\n' % (sub_dir[3], sample_id, host, sub_dir[4], sample_id))
                inf.write('%s/rmHost.pl %s %s %s %s\n' % (scr_dir, sub_dir[3], sub_dir[5], sub_dir[4], sample_id))
            else:
                inf.write('/data_center_01/pipeline/MetaGenome/v1.0/soft/FastQC/fastqc -q --extract -nogroup -o %s %s/%s.1.fq.gz\n'%(sub_dir[1], sub_dir[1], sample_id))
                inf.write('/data_center_01/pipeline/MetaGenome/v1.0/soft/FastQC/fastqc -q --extract -nogroup -o %s %s/%s.2.fq.gz\n'%(sub_dir[1], sub_dir[1], sample_id))
                inf.write('python %s/rmAdaptor.py --type PE -r1 %s/%s.1.fq.gz -r2 %s/%s.2.fq.gz -a1 %s -a2 %s --out_prefix %s/%s --out_type 2\n' % (scr_dir, sub_dir[0], sample_id, sub_dir[0], sample_id, adaptor_1, adaptor_2, sub_dir[2], sample_id))
                inf.write('%s/QC %s -o %s/%s.1.fq %s/%s.2.fq %s/%s\n' % (scr_dir, type, sub_dir[2], sample_id, sub_dir[2], sample_id, sub_dir[3], sample_id))

def write_qc2030_sh(dir, batch, batchfile, pipeline, scr_dir):
    with open('%s/shell/QC_2030_%s.sh' % (dir, batch), 'w') as inf:
        inf.write("python %s/Q20_Q30_stat_python2_new.py -b %s -c %s -o %s -n 10" % (scr_dir, batchfile, pipeline, dir))
        
def qc_run(dir, batch, host):
    if host:
        #os.system('/data_center_03/USER/zhongwd/bin/qsge --queue all.q --memery 500M:500M:500M:500M:5G:5G:500M --jobs 10 --lines 7 --prefix qc %s/shell/QC_%s.sh' % (dir, batch))
        #os.system('/data_center_03/USER/zhongwd/bin/qsge --queue all.q --memery 1G:1G:5G:1G:8G:8G:1G --jobs 10 --lines 7 --prefix qc %s/shell/QC_%s.sh' % (dir, batch))
        os.system('/data_center_03/USER/zhongwd/bin/qsge --queue all.q --memery 10G --jobs 4 --lines 1 --prefix qc2030 %s/shell/QC_2030_%s.sh' % (dir, batch))
    else:
        #os.system('/data_center_03/USER/zhongwd/bin/qsge --queue all.q --memery 1G:1G:5G:1G --jobs 10 --lines 4 --prefix qc %s/shell/QC_%s.sh' % (dir, batch))
        os.system('/data_center_03/USER/zhongwd/bin/qsge --queue all.q --memery 10G --jobs 1 --lines 1 --prefix qc2030 %s/shell/QC_2030_%s.sh' % (dir, batch))

def main(args, para):
    for batch in args['batchs']:
        refresh(args['batchfile'], batch, 'Run')
        sample_list, sub_dir, type, scr_dir, dir, type, host = qc_prepare(batch, args['sample'][batch], para['dir'], para['host'], para['type'])
        write_qc_sh(sample_list, dir, batch, sub_dir, host, type, scr_dir)
        write_qc2030_sh(dir, batch, args['batchfile'], args['pipeline'], scr_dir)
        qc_run(dir, batch, host)
        os.system('%s/stat.pl --batch %s %s %s' % (scr_dir, batch, para['dir'], para['inser']))
        refresh(args['batchfile'], batch, 'End')

if __name__ == '__main__':
    args = read_params(sys.argv)
    para = getpara(args['config'])
    args['batchs'], args['sample'] = read_batch(args['batchfile'])
    main(args, para)

#oooooooooo
#ooo
