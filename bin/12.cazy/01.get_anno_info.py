#!/usr/bin/env python
#-*- coding: utf-8 -*-

import os, sys, argparse, collections,re

def read_params(args):
    parser = argparse.ArgumentParser(description="selected best result from cazy blat analysis")
    parser.add_argument('-i', '--m8file', dest='m8file', metavar='FILE', type=str, required=True,
                        help="set the result of blat m8 format file")
    parser.add_argument('-o', '--outdir', dest='outdir', metavar='DIR', type=str, required=True,
                        help="store all output file")
    parser.add_argument('--minscore', dest='minscore', metavar='NUM', type=int, default=60,
                        help="set min score for filter")
    parser.add_argument('--cazy_db', dest='cazy_db', metavar='FILE', type=str,
                        default="/data_center_09/Project/lixr/00.DATA/CAZY_DB/cazy_annot.tsv",
                        help="get the cazy definition")
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
    blast, cazy_acid2cazy_protein = {},{}
    if isinstance(file_or_m8out,str):
        m8out = read_cazy_m8(file_or_m8out)
    else:
        m8out = file_or_m8out
    with open(cazy_db, 'r') as inf:      #读取ac号的注释文件，获得比对结果中存在的ac号的蛋白
        for row in inf:
            tabs = row.strip().split('\t')
            protein_name = tabs[0]
            try:
                for id in tabs[3].split(';'):
                    try:
                        cazy_acid2cazy_protein[id].add(protein_name)
                    except:
                        cazy_acid2cazy_protein[id] = set()#防止ac号下出现相同的蛋白名
            except:
                continue
    for geneid, value in m8out.items():
        blast[geneid] = {}
        for sub_value in value:
            tabs = sub_value.strip().split('\t')
            sub_tab = tabs[1].split('|')
            acid = sub_tab[0]
            cazy = sub_tab[1]
            if re.match(r'(.*)_(\d*)',sub_tab[1]):#cazy第二层级分类
                cazy_class = re.match(r'(.*)_(\d+)',cazy).group(1)
            else:
                cazy_class = sub_tab[1]
            cazy_type = re.match(r'([A-Z]+)\d+',cazy_class).group(1)#cazy大类
            if cazy_acid2cazy_protein.has_key(acid):
                cazy_protein = "&".join(cazy_acid2cazy_protein[acid])
            if len(sub_tab) > 2:
                enzyme = "&".join(sub_tab[2:])
                blast[geneid][acid] = [tabs[-2],tabs[-1],cazy_type,cazy_class,cazy,cazy_protein,enzyme]
            else:
                blast[geneid][acid] = [tabs[-2],tabs[-1],cazy_type,cazy_class,cazy,cazy_protein,'']
    return blast

def read_ac2description():      #获得ac号对应的描述信息
    file = '/data_center_09/Project/lixr/00.DATA/CAZY_DB/ac_description.list'
    ac2description = {}
    with open(file, 'r') as inf:
        for row in inf:
            tabs = row.strip().split('\t')
            ac2description[tabs[0]] = tabs[1]
    return ac2description

def main(args):
    outdir = os.path.abspath(args['outdir'])
    file = '%s/cazy.m8' % outdir
    if not os.path.isdir(outdir):
        os.system('mkdir -p %s' % outdir)
    m8out = handle_blat_file(args['m8file'], args['minscore'])
    write_cazy_m8(outdir, m8out)
    blast = handle_cazy_m8(args['cazy_db'], 'cazy.m8')
    ac2description = read_ac2description()
    with open("cazy.anno.tsv","w") as outf:
        outf.write("#Gene id\tQuery id\tE-value\tbit score\tCazy type\tCazy class\tCazy\tProtein name\tEnzyme\tDescription\n")
        for geneid,anno in blast.items():
            for queryid in anno.keys():
                 if ac2description.has_key(queryid):
                     outf.write("%s\t%s\t%s\t%s\n" %(geneid,queryid,'\t'.join(anno[queryid]),ac2description[queryid]))
                 else:
                     outf.write("%s\t%s\t%s\t\n" %(geneid,queryid,'\t'.join(anno[queryid])))
    outf.close()

if __name__ == '__main__':
    args = read_params(sys.argv)
    main(args)
