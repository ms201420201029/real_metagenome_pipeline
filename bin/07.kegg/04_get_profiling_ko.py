#!/usr/bin/env python
# -*- coding: utf-8 -*- #
import sys
import argparse
import os
import re

def read_params(args):
    parser = argparse.ArgumentParser(description='''make ko.profile | v2.0 at 2017/5/16 revised by xuyh ''')
    parser.add_argument('-i', '--gene_catalog_ko', dest='gene_catalog_ko', metavar='FILE', type=str, required=True,\
                        help="input gene_catalog_ko file")
    parser.add_argument("--gene_profile",dest="gene_profile",metavar="FILE",type=str,\
                        default="/data_center_04/Projects/test_Q30/real_metagenome_test20161209//07.kegg/../06.gene_profile/gene.profile",\
                        help="used as gene profile database for searching")					
    parser.add_argument('-o', '--ko_profile', dest='ko_profile_file', metavar='FILE', type=str, required=True,\
                        help="set the output file")
    
    args = parser.parse_args()
    params = vars(args)
    return params


if __name__ == '__main__':
    reload(sys)
    sys.setdefaultencoding('utf8')
    params = read_params(sys.argv)
    in_file = params["gene_catalog_ko"]
    out_file = params["ko_profile_file"]
    gene_profile = params["gene_profile"]

    # check input files
    if not os.path.isfile(in_file):
        raise Exception("%s 不存在"%in_file)
    if not os.path.isfile(gene_profile):
        raise Exception("%s 不存在"%gene_profile)

    abun = {}
    KOprofiling = {}
	#制作字典，key为queryid， value为一个字符串，也就是该行的字符串）
    with open(gene_profile,"r")	as IN:
        header = IN.readline()
	p = re.compile(r'^\s+')
	header = re.sub(p,'',header)
	samples = header.split('\t')
	sample_number = len(samples)
        for line1 in IN:
            if not re.match(r'^\t',line1):
	        tabs1 = line1.split('\t')
	        abun[tabs1[0]] = line1
			
	#进行ko丰度统计		
	with open(in_file,"r") as KO:
	    for line in KO:
	        line = line.strip()
		if re.match(r"^#",line):
		    continue
		pt = re.compile(r'^\S+\s+(\S+)') #SAM10_GI_0052018        K03671|1|2.7e-47|186.0|pdi:BDI_3483|thioredoxin 1 (A)
		if re.match(pt,line):
		    catalog = line.split('\t')[1]
                    gene = line.split('\t')[0]
                    if not abun.has_key(gene):
                        with open("./gene_no_profile",'a') as nogene:
                            nogene.write("%s\t"%gene)
                        continue
	            if re.match("!", catalog):
		        rawlist = line.split("!")[1:]
		 	for koraw in rawlist:
			    ko = koraw.split('|')[0]
		            abundata = abun[gene].split('\t')[1:]
			    if ko in KOprofiling:
				for i in range(0, sample_number):
				    KOprofiling[ko][i] = float(KOprofiling[ko][i]) + float(abundata[i])
                            else:
				KOprofiling[ko] = []
			        for i in range(0, sample_number):
				    KOprofiling[ko].append(float(abundata[i]))
		    else:
			ko = line.split('\t')[1].split("|")[0]
			abun[gene] = abun[gene].strip()
			abundata = abun[gene].split('\t')[1:]
                        if ko in KOprofiling:
                            for i in range(0, sample_number):
                                KOprofiling[ko][i] = float(KOprofiling[ko][i]) + float(abundata[i])
                        else:
                            KOprofiling[ko] = []
                            for i in range(0, sample_number):
                                KOprofiling[ko].append(float(abundata[i])) 
                else:
                     continue
    with open(out_file,'w+') as out:
	out.write("\t%s"%(header))
	for ko in KOprofiling.keys():
	    out.write("%s"%(ko))
            abun_ko = ""
            for num in KOprofiling[ko]:
		abun_ko += "\t%s"%num
	    out.write("%s\n"%(abun_ko))
