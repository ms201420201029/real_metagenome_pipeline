#!/usr/bin/env python
#-*- coding: utf-8 -*-

# Description: 
# Copyright (C) 20170808 Ruiyi Corporation
# Email: lixr@realbio.cn

import os, sys, argparse
from workflow.util.useful import parse_group_file, mkdir, cutcol_dataFrame

def read_params(args):
    parser = argparse.ArgumentParser(description='a wrapper for LEfSe | v1.0 at 2017/1/23 by huangy')
    parser.add_argument('-i', '--summarize_all', dest='infile', metavar='FILE', type=str, required=True,
                        help="set hte otu_table_all.txt produced by 02_summarize_trans.py")
    parser.add_argument('-l', '--LEfSe_path', dest='LEfSe_path', metavar='DIR', type=str, default=None,
                        help="set the LEfSe path, default find in env")
    parser.add_argument('-g', '--group_file', dest='group', metavar='FILE', type=str, required=True,
                        help="set the group file")
    parser.add_argument('-o', '--out_dir', dest='out_dir', metavar='DIR', type=str, required=True,
                        help="set the output dir")
    parser.add_argument('--LDA', dest='LDA', metavar='FLOAT', type=float, default=2,
                        help="set the LDA cutoff, [default is 2]")
    parser.add_argument('--class_row', dest='c', metavar='INT', type=int, default=1,
                        help="set the class row, [default is 1]")
    parser.add_argument('--subject_row', dest='u', metavar='INT', type=int, default=2,
                        help="set the subject row, [default is 2]")
    parser.add_argument('--quantile',dest="quantile",metavar='FLOAT',type=float,default=0)
    parser.add_argument('--cut_off',dest='cut_off',metavar='FLOAT',type=float,default=1e-20)
    args = parser.parse_args()
    params = vars(args)
    params['groupDir'] = params['group']
    params['group'] = parse_group_file(params['group'])
    if params['LEfSe_path'] is None:
        params['LEfSe_path'] = ''
    else:
        params['LEfSe_path'] += '/'
    return params

def do_format(infile, outfile, groupDir,quantile,cut_off):
    data,group = cutcol_dataFrame(infile,groupDir)
    groups=group.values()
    samples = group.keys()

    data.index=[i.replace('[','') for i in data.index.tolist()]
    data.index=[i.replace(']','') for i in data.index.tolist()]
    for temp in data.index:
        if temp.endswith('Other'):
            data.drop(temp)
        if temp.endswith('norank'):
            data.drop(temp)
        if temp.endswith('unclassfied'):
            data.drop(temp)
    sample_num = len(data.columns)
    data["sum"] = data.sum(axis=1)
    data = data.sort_values(by="sum",ascending=False)
    quantile_value = float(data["sum"].quantile(quantile))
    dd = data[data>cut_off]
    data["num_True"] = dd.count(axis=1)
    index_list = []
    for i in range(len(data.index)):
        if data.ix[i,sample_num] < quantile_value:
            if data.ix[i,sample_num+1] <2:
                index_list.append(i)
    data = data.drop(data.index[index_list])
    del data["sum"]
    del data["num_True"]
    with open(outfile, 'w') as out_fp:
        out_fp.write('class\t%s\n' % '\t'.join(groups))
        out_fp.write('Taxon\t%s\n' % '\t'.join(samples))
        data.to_csv(out_fp,header=False,sep="\t")

def get_commands(infile, LEfSe_path, out_dir, LDA, c, u):
    python_version = '/data_center_03/USER/huangy/soft/MAIN/anaconda2/bin/python2.7'
    commands = []
    command = '%s %sformat_input.py %s %s/LDA.in -c %s -u %s -o 1000000' % (python_version, LEfSe_path, infile, out_dir, c, u)
    commands.append(command)
    command = '%s %srun_lefse.py %s/LDA.in %s/LDA.res -l %s' % (python_version, LEfSe_path, out_dir, out_dir, LDA)
    commands.append(command)
    command = '%s %splot_res.py %s/LDA.res %s/LDA.pdf --format pdf --dpi 150' % (python_version, LEfSe_path, out_dir, out_dir)
    commands.append(command)
    command = '%s %splot_res.py %s/LDA.res %s/LDA.png --format png --dpi 150' % (python_version, LEfSe_path, out_dir, out_dir)
    commands.append(command)
#    command = '%splot_cladogram.py %s/LDA.res %s/LDA.cladogram.pdf --format pdf --dpi 150' % (
 #       LEfSe_path, out_dir, out_dir)
 #   commands.append(command)
 #   command = '%splot_cladogram.py %s/LDA.res %s/LDA.cladogram.png --format png --dpi 150' % (
     #   LEfSe_path, out_dir, out_dir)
   # commands.append(command)
  #  if not os.path.isdir('%s/biomarkers_raw_images' % out_dir):
   #     os.mkdir('%s/biomarkers_raw_images' % out_dir)
   # command = '%(LEfSe_path)splot_features.py %(out_dir)s/LDA.in %(out_dir)s/LDA.res %(out_dir)s/biomarkers_raw_images/ --format pdf --dpi 200' % {
    #    'LEfSe_path': LEfSe_path, 'out_dir': out_dir}
    #commands.append(command)
    return commands

if __name__ == '__main__':
    params = read_params(sys.argv)
    mkdir(params['out_dir'])
    for_analysis = '%s/otu_table_for_lefse.txt' % params['out_dir']
    do_format(params['infile'], for_analysis, params['groupDir'],params['quantile'],params['cut_off'])
    commands = get_commands(for_analysis, params['LEfSe_path'], params['out_dir'],
                            params['LDA'], params['c'], params['u'])
    with open(params['out_dir'] + '/commands.sh', 'w') as fp:
        fp.write('\n'.join(commands))
    for command in commands:
        os.system(command)
    os.system("awk '$4>%s' %s/LDA.res >%s/diff.marker.filter.txt"%(params['LDA'],params['out_dir'],params['out_dir']))
    os.system("cut -f 1 %s/diff.marker.filter.txt > %s/rows.txt"%(params['out_dir'],params['out_dir']))
    os.system("Rscript /data_center_01/pipeline/real_metagenome/real_metagenome_v1.0.0/tool/cut_rows_cols.R %s %s/rows.txt %s %s/diff.marker.filter.profile.txt"%(params['infile'],params['out_dir'],params['groupDir'],params['out_dir']))
    #os.system("cut -f 1 %s/diff.marker.filter.txt |while read line;do echo \"grep \'$line\t\' %s >> %s/diff.marker.filter.profile.txt\";done>%s/do.sh"%(params['out_dir'],params['infile'],params['out_dir'],params['out_dir']))
    #os.system("head -1 %s > %s/diff.marker.filter.profile.txt"%(params['infile'],params['out_dir']))
    #os.system("sh %s/do.sh"%params['out_dir'])
    os.system("rm %s/rows.txt"%params['out_dir'])
        
