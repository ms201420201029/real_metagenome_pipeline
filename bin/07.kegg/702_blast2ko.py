#!/usr/bin/env python
# -*- coding: utf-8 -*- #
import sys
import argparse
import os
import re


def read_params(args):
    parser = argparse.ArgumentParser(description='''conver blast m8 format to ko format | v1.0 at 2017/1/23 by huangy ''')
    parser.add_argument('-i', '--blat_m8_file', dest='blat_m8_file', metavar='FILE', type=str, required=True,
                        help="output of blast in format -m 8")
    parser.add_argument('-o', '--out_file', dest='out_file', metavar='FILE', type=str, required=True,
                        help="set the output file")
    parser.add_argument("--kegg_db",dest="kegg_db",metavar="FILE",type=str,\
                        default="/data_center_01/home/xuyh/exercise/gene_ko_definition_v1",\
                        help="get the ko definition")
    args = parser.parse_args()
    params = vars(args)
    return params


if __name__ == '__main__':
    reload(sys)
    sys.setdefaultencoding('utf8')
    params = read_params(sys.argv)
    in_file = params["blat_m8_file"]
    out_file = params["out_file"]
    kegg_db = params["kegg_db"]

    # check input files
    if not os.path.isfile(in_file):
        raise Exception("%s 不存在"%in_file)
    if not os.path.isfile(kegg_db):
        raise Exception("%s 不存在"%kegg_db)

    # read kegg.m8
    genes = {}
    blast_r = {}
    kos = {}
    with open(in_file,"r") as fqin:
        for line in fqin:
            tabs = line.strip().split("\t")
            genes[tabs[0]] = 1 #key即queryid对应的value为1
            tabs[0] = tabs[0].split("\s")[0]
            if tabs[0] in blast_r: #如果是字典中的键
                print "err repeated queryid!"
            else:
                blast_r[tabs[0]]=[] #tabs[0]是就是queryid
		blast_r[tabs[0]].append([tabs[-2],tabs[-1],tabs[1]]) #(evalue, score, subjectid)，是不是rank呢？是的。但是名为字典中键的列表只有一个元素，这个元素就是4元素列表。这是个字典，字典中key=subjectid对应的值为列表[[evalue, score, subjectid]]。
            kos[tabs[1]] = [] #tabs[1]是subjectid
			
			
	# read gene_ko_definition_v1
    with open(kegg_db,"r") as fqin:
        for line in fqin:
            line = line.strip()
            tabs = line.split("\t")
	    id = tabs[1]
	    definition = tabs[2]
            if tabs[0] in kos:
	        kos[tabs[0]].append((id,definition)) #一键tabs[0]为subjectid的多值字典，字典的每一个value为元组，id就是ko_id，definition就是ko_definition
			
			
    total = 0
    yes = 0
    genes = sorted(genes.iteritems(), key=lambda d:d[1], reverse = True) #降序排列,按照value
    content = ""
    for (gene,value) in genes: #这是Python2.0版本的写法
        total = total+1  #total表示总共有多少个queryid在kegg.m8文件中
        content = "%s%s\t"%(content,gene)# gene是queryid, 
        koids = []
        if gene in blast_r: #gene = queryid
            for result in blast_r[gene]: #result应为列表[evalue, score, subjectid]
                if (result[2] in kos) and (len(kos[result[2]])>0): #result[2]就是subjectid, 如果result[2]在kos字典键中并且该键有值
                    if len(kos[result[2]]) == 1:
                        yes =yes+ 1 #用来计数
						#下面这一行代码其实就是i = 0
                        content = "%s%s|%s|%s|%s|%s|%s"\
                                          %(content,kos[result[2]][0][0],1,result[0],result[1],result[2],kos[result[2]][0][1]) #result[3]就是rank,result[2]就是subjectid，kos[result[2]]就是kos字典中的键subjectid对应的值的列表（值为元组），kos[result[2]][0]就是第一个（ko,definition）元组，kos[result[2]][0][0]也就是第一个ko号
                        koids.append(kos[result[2]][0][0])
                        for i in range(1,len(kos[result[2]])): #列表中元组的个数，注意：这里的i是从1开始的
                            content = "%s!%s|%s|%s|%s|%s|%s"%(content,kos[result[2]][i][0],result[3],result[0],result[1],result[2],kos[result[2]][i][1])
                            koids.append(kos[result[2]][i][0]) #将列表中每一个元组的ko写进koids列表中
                    else: 
                        num = 0
                        for i in range(0,len(kos[result[2]])):
                            num += 1
                            if ",%s,"%(",".join(koids)).find(","+kos[result[2]][i][0]+","):
                                content = "%s!%s|%s|%s|%s|%s|%s"\
                                          %(content,kos[result[2]][i][0],num,result[0],result[1],result[2],kos[result[2]][i][1])
                                koids.append(kos[result[2]][i][0]) #构建ko_id的列表
                content = "%s\n"%content #将content格式化为字符串并在content字符串的后面加上换行符
        else:
            print "err gene"

with open(out_file,"w") as fqout:
    fqout.write("# Method: BLAST\n")
    fqout.write("# Summary:\t%s succeed, %s fail\n\n"%(yes,total-yes))
    fqout.write("# query\tko_id:rank:evalue:score:identity:ko_definition\n")
    fqout.write(content)


