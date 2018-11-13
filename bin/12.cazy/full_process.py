#!/usr/bin/env python
#-*- coding: utf-8 -*-

# Description: 
# Copyright (C) 20180412 Ruiyi Corporation
# Email: lixr@realbio.cn

import os, sys, argparse, collections
from utilities import read_file, mkdir
from jinja2 import Environment, FileSystemLoader

def read_params(args):
    parser = argparse.ArgumentParser(description="selected best result from cazy blat analysis")
    parser.add_argument('-i', '--m8file', dest='m8file', metavar='FILE', type=str, required=True,
                        help="set the result of blat m8 format file")
    parser.add_argument('-p', '--profile', dest='gene_profile', metavar='FILE', type=str, required=True,
                        help='set the profile file of gene abundance')
    parser.add_argument('-o', '--outdir', dest='outdir', metavar='DIR', type=str, required=True,
                        help="store all output file")
    parser.add_argument('--minscore', dest='minscore', metavar='NUM', type=int, default=60,
                        help="set min score for filter")
    parser.add_argument('--cazy_db', dest='cazy_db', metavar='FILE', type=str,
                        default="/data_center_09/Project/lixr/00.DATA/CAZY_DB/cazy_annot.tsv",
                        help="get the cazy definition")
    parser.add_argument('--strategy', dest='strategy', metavar='STR', type=str, default='all',
                        help="please select \"all\" or one or more in (\"class\",\"protein\",\"enzyme\")")
    return vars(parser.parse_args())

def handle_blat_file(infile, minscore):      #处理blat处理的结果文件
    minscore = float(minscore)
    queryscore = {}
    #m8out = {}
    m8out = collections.OrderedDict()
    with open(infile, 'r') as inf:      #处理blat结果文件，获得每个基因最好的比对结果
        for row in inf:
            row = row.strip()
            tabs = row.split('\t')
            try:
                if float(tabs[-1]) < float(minscore):
                    continue
                try:
                    if queryscore[tabs[0]] > float(tabs[-1]):      #获得得分最好的一行数据
                        continue
                    if queryscore[tabs[0]] == float(tabs[-1]):      #出现得分相同的行
                        m8out[tabs[0]].append(row)
                except:
                    pass
            except:
                continue
            queryscore[tabs[0]] = float(tabs[-1])
            m8out[tabs[0]] = [row]
    return m8out

def write_cazy_m8(outdir, m8out):      #将blat的处理结果写入cazy.m8文件
    file = '%s/cazy.m8' % outdir
    with open(file, 'w') as outf:
        for value in m8out.values():
            for sub_value in value:
                outf.write('%s\n' % sub_value)

def read_cazy_m8(file):
    m8out = collections.OrderedDict()
    with open(file, 'r') as inf:
        for row in inf:
            row = row.strip()
            geneid = row.split('\t')[0]
            try:
                m8out[geneid].append(row)
            except:
                m8out[geneid] = [row]
    return m8out

def handle_cazy_m8(cazy_db, file_or_m8out):      #处理获得的最好的基因比对结果
    genes, blast_ac, blast_ca, blast_en, cazy_acid2cazy_protein = {}, {}, {}, {}, {}
    if isinstance(file_or_m8out,str):
        m8out = read_cazy_m8(file_or_m8out)
    else:
        m8out = file_or_m8out
    for geneid, value in m8out.items():
        genes[geneid] = 1
        for sub_value in value:
            tabs = sub_value.strip().split('\t')
            sub_tab = tabs[1].split('|')
            acid, cazy_class = sub_tab[:2]
            if len(sub_tab) > 2:
                for enzyme in sub_tab[2:]:
                    try:
                        blast_en[geneid].append([enzyme, acid, tabs[-2], tabs[-1]])
                    except:
                        blast_en[geneid] = [[enzyme, acid, tabs[-2], tabs[-1]]]
            else:
                acid, cazy_class = sub_tab
            try:
                blast_ac[geneid].append([acid, tabs[-2], tabs[-1]])      #一个基因比对到多个ac号
            except:
                blast_ac[geneid] = [[acid, tabs[-2], tabs[-1]]]
            try:
                blast_ca[geneid].append([cazy_class, acid, tabs[-2], tabs[-1]])
            except:
                blast_ca[geneid] = [[cazy_class, acid, tabs[-2], tabs[-1]]]
            cazy_acid2cazy_protein[acid] = set()      #防止ac号下出现相同的蛋白名
    with open(cazy_db, 'r') as inf:      #读取ac号的注释文件，获得比对结果中存在的ac号的蛋白
        for row in inf:
            tabs = row.strip().split('\t')
            protein_name = tabs[0]
            try:
                for id in tabs[3].split(';'):
                    try:
                        cazy_acid2cazy_protein[id].add(protein_name)
                    except:
                        continue
            except:
                continue
    return genes, blast_ac, blast_ca, blast_en, cazy_acid2cazy_protein

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

def write_profile(file, samples, profile):      #写入丰度表
    with open(file, 'w') as outf:
        outf.write('\t%s\n' % '\t'.join(samples))
        for name in profile.keys():
            if len(profile[name]) == 0:
                continue
            outf.write('%s\t%s\n' % (name, '\t'.join([str(profile[name][id]) for id in samples])))

def read_ac2description():      #获得ac号对应的描述信息
    file = '/data_center_09/Project/lixr/00.DATA/CAZY_DB/ac_description.list'
    ac2description = {}
    with open(file, 'r') as inf:
        for row in inf:
            tabs = row.strip().split('\t')
            ac2description[tabs[0]] = tabs[1]
    return ac2description

def get_gene2other_summary(outfile, genes, blast, ac2description, content):      #获得基因对应cazy酶或分类信息及比对结果，并输出到文件
    total, yes = 0, 0
    with open(outfile, 'w') as outf:
        outf.write('#Method:\tBLAST\n')
        outf.write('%s\n' % content)
        for geneid in genes.keys():
            num, logic = 0, 0
            total += 1
            outf.write('%s\t' % geneid)
            try:
                for summary in blast[geneid]:
                    num += 1
                    logic += 1
                    name, acid, evalue, score = summary
                    try:
                        description = ac2description[acid]      #判定ac号是否有描述
                    except:
                        description = 'NULL'
                    yes += 1
                    if logic == 1:
                        outf.write('%s|%s|%s|%s|%s|%s\n' % (name,num,evalue,score,acid,description))
                    else:
                        outf.write('%s\t%s|%s|%s|%s|%s|%s\n' % (geneid,name,num,evalue,score,acid,description))
            except:
                outf.write('\n')
                continue
    os.system('sed -i \'1a#Summary:\t%d succeed, %d fail\' %s\n' % (yes, total-yes, outfile))

def get_gene2cazy_protein_summary(outdir, genes, blast_ac, cazy_acid2cazy_protein, ac2description):      #获得基因对应cazy蛋白的信息及比对结果，并输出到文件
    total, yes, gene2cazy_protein = 0, 0, {}
    outfile = '%s/gene2cazy_protein.summary' % outdir
    with open(outfile, 'w') as outf:
        outf.write('#Method:\tBLAST\n')
        outf.write('#query\tcazy_protein|rank|evalue|score|acid|cazy_protein_description\n')
        for geneid in genes.keys():
            all_pro_name, num = [], 0
            total += 1
            outf.write('%s\t' % geneid)
            for summary in blast_ac[geneid]:
                logic = 0
                num += 1
                acid, evalue, score = summary
                try:
                    if len(cazy_acid2cazy_protein[acid]) == 0:
                        outf.write('\n')
                        continue
                    for protein_name in list(cazy_acid2cazy_protein[acid]):
                        all_pro_name.append(protein_name)
                        logic += 1
                        yes += 1
                        try:
                            description = ac2description[acid]
                        except:
                            description = 'NULL'
                        if logic == 1:
                            outf.write('%s|%s|%s|%s|%s|%s\n' % (protein_name,num,evalue,score,acid,description))
                        else:
                            outf.write('%s\t%s|%s|%s|%s|%s|%s\n' % (geneid,protein_name,num,evalue,score,acid,description))
                except:
                    outf.write('\n')
                    continue
            gene2cazy_protein[geneid] = all_pro_name      #获得每个基因比对到的所有蛋白(n个)，每个蛋白的丰度为该基因丰度的1/n
        os.system('sed -i \'1a#Summary:\t%d succeed, %d fail\' %s' % (yes, total-yes, outfile))
    return gene2cazy_protein

def get_cazy_enzyme_profile(samples, gene_profile, blast_en):      #通过基因丰度表获得cazy酶丰度表
    cazy_enzyme_profile = {}
    for gene in blast_en.keys():
        num = len(blast_en[gene])
        for sub_summary in blast_en[gene]:
            ec = sub_summary[0]
            if ec not in cazy_enzyme_profile:
                cazy_enzyme_profile[ec] = {}
            for id in samples:
                try:
                    gene_profile[gene][id] += 0
                except:
                    break
                try:
                    cazy_enzyme_profile[ec][id] += gene_profile[gene][id] / num
                except:
                    cazy_enzyme_profile[ec][id] = gene_profile[gene][id] / num
    return cazy_enzyme_profile

def get_cazy_class_profile(samples, gene_profile, blast_ca):      #通过基因丰度表获得cazy分类丰度表
    cazy_class_profile = {}
    for gene in blast_ca.keys():
        num = len(blast_ca[gene])
        for sub_summary in blast_ca[gene]:
            clas = sub_summary[0]
            if clas not in cazy_class_profile:
                cazy_class_profile[clas] = {}
            for id in samples:
                try:
                    gene_profile[gene][id] += 0
                except:
                    break
                try:
                    cazy_class_profile[clas][id] += gene_profile[gene][id] / num
                except:
                    cazy_class_profile[clas][id] = gene_profile[gene][id] / num
    return cazy_class_profile

def get_cazy_protein_profile(samples, gene_profile, gene2cazy_protein):      #通过基因丰度表获得cazy蛋白丰度表
    cazy_protein_profile = {}
    for gene, protein_name in gene2cazy_protein.items():
        num = len(protein_name)
        for sub_pro in protein_name:
            if sub_pro not in cazy_protein_profile:
                cazy_protein_profile[sub_pro] = {}
            for name in samples:
                try:
                    gene_profile[gene][name] += 0      #检测某个gene是否有丰度
                except:
                    break
                if name in cazy_protein_profile[sub_pro]:
                    cazy_protein_profile[sub_pro][name] += gene_profile[gene][name] / num
                else:
                    cazy_protein_profile[sub_pro][name] = gene_profile[gene][name] / num
    return cazy_protein_profile

def cazy_class_workflow(dir, samples, gene_profile, blast, genes):
    outfile = '%s/../cazy_class.profile' % dir
    ac2description = read_ac2description()
    cazy_class_profile = get_cazy_class_profile(samples, gene_profile, blast)
    write_profile(outfile, samples, cazy_class_profile)
    outfile = '%s/gene2cazy_class.summary' % dir
    content = '#query\tcazy_class|rank|evalue|score|acid|cazy_class_description'
    get_gene2other_summary(outfile, genes, blast, ac2description, content)
    
def cazy_enzyme_workflow(dir, samples, gene_profile, blast, genes):
    outfile = '%s/../cazy_enzyme.profile' % dir
    ac2description = read_ac2description()
    cazy_enzyme_profile = get_cazy_enzyme_profile(samples, gene_profile, blast)
    write_profile(outfile, samples, cazy_enzyme_profile)
    outfile = '%s/gene2cazy_enzyme.summary' % dir
    content = '#query\tcazy_enzyme|rank|evalue|score|acid|cazy_enzyme_description'
    get_gene2other_summary(outfile, genes, blast, ac2description, content)

def cazy_protein_workflow(dir, samples, gene_profile, blast, genes, cazy):
    outfile = '%s/../cazy_protein.profile' % dir
    ac2description = read_ac2description()
    gene2cazy_protein = get_gene2cazy_protein_summary(dir, genes, blast, cazy, ac2description)
    cazy_protein_profile = get_cazy_protein_profile(samples, gene_profile, gene2cazy_protein)
    write_profile(outfile, samples, cazy_protein_profile)
    
def main(args):
    temp_dir = '%s/temp' % os.path.abspath(args['outdir'])
    file = '%s/cazy.m8' % temp_dir
    if not os.path.isdir(temp_dir):
        os.system('mkdir -p %s' % temp_dir)
    if os.path.exists(file) and os.path.getsize(file):
        genes, blast_ac, blast_ca, blast_en, cazy = handle_cazy_m8(args['cazy_db'], file)
    else:
        m8out = handle_blat_file(args['m8file'], args['minscore'])
        write_cazy_m8(temp_dir, m8out)
        genes, blast_ac, blast_ca, blast_en, cazy = handle_cazy_m8(args['cazy_db'], m8out)
    samples, gene_profile = read_gene_profile(args['gene_profile'])
    if args['strategy'] == 'class':
        cazy_class_workflow(temp_dir, samples, gene_profile, blast_ca, genes)
    elif args['strategy'] == 'protein':
        cazy_protein_workflow(temp_dir, samples, gene_profile, blast_ac, genes, cazy)
    elif args['strategy'] == 'enzyme':
        cazy_enzyme_workflow(temp_dir, samples, gene_profile, blast_en, genes)
    elif args['strategy'] == 'all':
        cazy_class_workflow(temp_dir, samples, gene_profile, blast_ca, genes)
        cazy_protein_workflow(temp_dir, samples, gene_profile, blast_ac, genes, cazy)
        cazy_enzyme_workflow(temp_dir, samples, gene_profile, blast_en, genes)
    else:
        print 'Error:\terror strategy "%s"! please select "all" or one or more in ("class","protein","enzyme").\n' % args['strategy']

if __name__ == '__main__':
    args = read_params(sys.argv)
    main(args)

