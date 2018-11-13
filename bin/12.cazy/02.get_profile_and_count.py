#!/usr/bin/env python
#-*- coding: utf-8 -*-

import os, sys, argparse, collections

def read_params(args):
    parser = argparse.ArgumentParser(description="get the profile of the anno file")
    parser.add_argument('-a', '-anno', dest='anno', metavar="FILE", type=str, required=True,
                        help="set the annotation file")
    parser.add_argument('-p', '--profile', dest='profile', metavar='FILE', type=str, required=True,
                        help='set the profile file of gene abundance')
    parser.add_argument('-l', '-col', dest='col', metavar='NUM', type=int, required=True,
                        help="column in annotation file selected to deal")
    parser.add_argument('-o', '--outdir', dest='outdir', metavar='DIR', type=str, required=True,
                        help="set the output file")
    parser.add_argument('-c', '--class', dest='class', metavar='STR', type=str,required=True,
                        help="set the class to calculate profile")#需要统计丰度的特征名称
    return vars(parser.parse_args())

def read_gene_profile(file):      #读取基因丰度表
    gene_profile = {}
    with open(file, 'r') as inf:
        header = inf.next()
        samples = header.strip().split('\t')
        for row in inf:
            tabs = row.strip().split('\t')
            geneid = tabs[0]
            gene_profile[geneid] = {}
            for sample_name, abun in zip(samples, tabs[1:]):
                gene_profile[geneid][sample_name] = float(abun)
    return samples, gene_profile

def handle_anno_file(file,col,level):#处理注释文件
    anno = {}
    gene = {}
    with open(file,"r") as fa:
        for line in fa:
            if line.startswith("#"):
                continue
            line = line.strip().split('\t')
            if len(line) < col or line[col-1] == '':#该列特征为空时跳过
                continue
            tabs = line[col-1].split('&')
            if level == "functional":
                m_tabs = "".join(tabs)
                tabs = list(m_tabs)
            anno[line[0]] = tabs
    fa.close()
    return anno

def get_profile_and_count(samples,gene_profile,anno):#获取需要统计的特征丰度与数量
    class_profile = {}
    class_count = {}
    for gene in anno.keys():
        num = len(anno[gene])#一个基因可能注释到多个特征，计算丰度时均分
        for class_id in anno[gene]:
            if class_id not in class_profile:
                class_profile[class_id] = {}#记录丰度
            if class_id not in class_count:
                class_count[class_id] = {}#记录数量
            for sample in samples:
                try:
                     gene_profile[gene][sample] += 0
                except:
                     break
                if gene_profile[gene][sample] != 0:#当注释到的基因的物种丰度不为0时加1计数
                    try:
                        class_count[class_id][sample] += 1
                    except:
                        class_count[class_id][sample] = 1
                else:#注释到基因的物种丰度为0时保持不变
                    try:
                        class_count[class_id][sample] = class_count[class_id][sample]
                    except:
                        class_count[class_id][sample] = 0
                try:
                    class_profile[class_id][sample] += gene_profile[gene][sample] / num
                except:
                    class_profile[class_id][sample] = gene_profile[gene][sample] / num
    return class_profile,class_count

def write(file,samples,class_profile):#丰度写入文件
    with open(file,"w") as fout:
        fout.write('\t%s\n' % '\t'.join(samples))
        for class_id in class_profile.keys():
            if len(class_profile[class_id]) == 0:
                continue
            fout.write("%s\t%s\n" %(class_id, '\t'.join(str(class_profile[class_id][sample]) for sample in samples)))
    fout.close()

if __name__ == '__main__':
    params = read_params(sys.argv)
    out_dir = os.path.abspath(params['outdir'])
    if not os.path.isdir(out_dir):
        os.system('mkdir -p %s' % out_dir)
    samples, gene_profile = read_gene_profile(params['profile'])
    anno = handle_anno_file(params['anno'],params['col'],params['class'])
    out_profile = "%s/%s.profile" %(out_dir,params['class'])
    out_count = "%s/%s.count" % (out_dir,params['class'])
    class_profile, class_count = get_profile_and_count(samples,gene_profile,anno)
    write(out_profile,samples,class_profile)
    write(out_count,samples,class_count)
