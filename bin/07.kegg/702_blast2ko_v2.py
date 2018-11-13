#!/usr/bin/env python
# -*- coding: utf-8 -*- #
import sys
import argparse
import os
import re


def read_params(args):
    parser = argparse.ArgumentParser(
        description='''conver blast m8 format to ko format | v2.0 at 2018/8/7 by huangy ''')
    parser.add_argument('-i', '--blat_m8_file', dest='blat_m8_file', metavar='FILE', type=str, required=True,
                        help="output of blast in format -m 8，example file kegg.m8")
    parser.add_argument('-o', '--out_file', dest='out_file', metavar='FILE', type=str, required=True,
                        help="set the output file")
    parser.add_argument("--kegg_db", dest="kegg_db", metavar="FILE", type=str, \
                        default="/data_center_01/home/xuyh/exercise/gene_ko_definition_v1", \
                        help="get the ko definition")
    parser.add_argument("--subjectId", dest="subjectId", metavar="FILE", type=str, required=True,\
                        help="cut -f 2 kegg.m8 | sort |uniq ，此命令生成的文件，unique的subjectId  list")
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
    subjectIdFile = params["subjectId"]

    # check input files
    if not os.path.isfile(in_file):
        raise Exception("%s 不存在" % in_file)
    if not os.path.isfile(kegg_db):
        raise Exception("%s 不存在" % kegg_db)
    if not os.path.isfile(subjectIdFile):
        raise Exception("%s 不存在" % subjectIdFile)

    # read kegg.m8
    # genes = {}
    queryIdList = {}
    subjectIdList = {}
    kos = {}
    total = 0 #统计总的queryId数量
    yes = 0   #统计kegg数据库中queryId的数量
    content = ""  #输出文件的内容
    ##加载subjectIdList文件
    with open(subjectIdFile,"r") as inputFile:
        for line in inputFile:
            subjectIdList[line.strip()]=1

    #加载kegg数据库Ko描述的文件gene_ko_definition_v1
    with open(kegg_db, "r") as fqin:
        for line in fqin:
            line = line.strip()
            tabs = line.split("\t")
            subjectId = tabs[0]
            koId = tabs[1]
            koDefinition = tabs[2]
            if subjectId in subjectIdList:
                if subjectId in kos:
                    kos[subjectId].append((koId, koDefinition))  # 一键tabs[0]为subjectid的多值字典，字典的每一个value为元组，id就是ko_id，definition就是ko_definition
                else:
                    kos[subjectId] = []
                    kos[subjectId].append((koId,koDefinition))  # 一键tabs[0]为subjectid的多值字典，字典的每一个value为元组，id就是ko_id，definition就是ko_definition

    # 读取文件kegg.m8
    with open(in_file, "r") as fqin , open(out_file, "w") as fqout:
        fqout.write("# Method: BLAST\n")
        fqout.write("# Summary:\t%s succeed, %s fail\n\n" % (yes, total - yes))#有待进一步优化
        fqout.write("# query\tko_id:rank:evalue:score:identity:ko_definition\n")
        for line in fqin:
            total = total + 1  # total表示总共有多少个queryid在kegg.m8文件中
            tabs = line.strip().split("\t")
            queryId = tabs[0] # tabs[0]是就是queryid
            evalue = tabs[-2]
            score = tabs[-1]
            subjectId = tabs[1]
            queryId = queryId.split("\s")[0]
            if queryId in queryIdList:  # 如果是字典中的键
                print "err repeated queryid!"
            else:
                queryIdList[queryId]=1
            #开始拼接输出的结果文件
            content = "%s\t" % (queryId)  # gene是queryid,
            if (subjectId in kos) and (len(kos[subjectId]) > 0):  # result[2]就是subjectid, 如果result[2]在kos字典键中并且该键有值
                if len(kos[subjectId]) > 1:
                    yes = yes + 1  # 用来计数
                    # 下面这一行代码其实就是i = 0
                    content = "%s%s|%s|%s|%s|%s|%s" \
                              % (content, kos[subjectId][0][0], 1, evalue, score, subjectId,kos[subjectId][0][1])  # result[3]就是rank,result[2]就是subjectid，kos[result[2]]就是kos字典中的键subjectid对应的值的列表（值为元组），kos[result[2]][0]就是第一个（ko,definition）元组，kos[result[2]][0][0]也就是第一个ko号
                    num = 0
                    for i in range(1, len(kos[subjectId])):  # 列表中元组的个数，注意：这里的i是从1开始的
                        num += 1
                        content = "%s!%s|%s|%s|%s|%s|%s" % (
                            content, kos[subjectId][i][0], num, evalue, score, subjectId,kos[subjectId][i][1])
                else:
                    yes = yes + 1  # 用来计数
                    # 下面这一行代码其实就是i = 0
                    content = "%s%s|%s|%s|%s|%s|%s" \
                              % (content, kos[subjectId][0][0], 1, evalue, score, subjectId,kos[subjectId][0][1])  # result[3]就是rank,result[2]就是subjectid，kos[result[2]]就是kos字典中的键subjectid对应的值的列表（值为元组），kos[result[2]][0]就是第一个（ko,definition）元组，kos[result[2]][0][0]也就是第一个ko号


            fqout.write("%s\n"%content)  # 将content格式化为字符串并在content字符串的后面加上换行符






