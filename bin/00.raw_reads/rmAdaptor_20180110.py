#!/usr/bin/env python
# -*- coding: utf-8 -*- #
import argparse
import os
import sys
import gzip
from Bio import SeqIO
from multiprocessing import Pool
from multiprocessing import cpu_count
from time import time
import math

def read_params(args):
    parser = argparse.ArgumentParser(description='plot alpha rare | v1.0 at 2015/09/28 by liangzb')
    parser.add_argument('--out_prefix',dest='out_prefix',metavar="DIR",type=str,required=True,
                        help="out file prefix")
    parser.add_argument('-r1', '--read1', dest='read1', metavar='DIR', type=str, required=True,
                        help="read1.fastq")
    parser.add_argument('-r2', '--read2', dest='read2', metavar='DIR', type=str, required=True,
                        help="read2.fastq")
    parser.add_argument('-a1', '--read1Adaptor', dest='read1Adaptor', metavar='string', type=str, required=True,
                        help="AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC")
    parser.add_argument('-a2', '--read2Adaptor', dest='read2Adaptor', metavar='string', type=str, required=True,
                        help="AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT")
    parser.add_argument('--type',dest="type",metavar='string',type=str,required=True,
                        help="PE or SE")
    parser.add_argument('--mistaken_ratio',dest="mistaken_ratio",metavar="float",type=float,default=0.2,
                        help="mistaken_ratio defult[0.2]")
    parser.add_argument('--mistaken_num', dest="mistaken_num", metavar="int", type=int, default=3,
                        help="mistaken_ratio defult[3]")
    parser.add_argument('--out_type',dest="out_type",metavar="STRING",type=int,default=4,
                        help="2 : two file out ;  4 : four file out.")
    parser.add_argument('--min_len',dest="min_len",metavar="min_len",type=int,default=99,
                        help="min_len[100]")
    #parser.add_argument('--process',dest='process',metavar="INT",type=int,default=10,
    #                    help = "set process num")
    args = parser.parse_args()
    params = vars(args)
    return params



def get_mistaken_count_max(seq_len,find_pos,adaptor_len,mistaken_ratio,mistaken_num):
    if seq_len - find_pos > adaptor_len:
        mistaken_count_max = adaptor_len * mistaken_ratio
    else:
        mistaken_count_max = (seq_len - find_pos) * mistaken_ratio
    if mistaken_count_max<float(mistaken_num):
        mistaken_count_max=mistaken_num
    return math.ceil(mistaken_count_max)

def match_adaptor(seq,seed):
#seed_first
    index=-1
    indexs = []
    while True:
        index = seq.find(seed,index+1)#从index+1位置开始找，如果找到返回索引，没找到则返回-1
        if index==-1:#没找到 跳出
            break
        indexs.append(index)
    return indexs
def situation_1(read1,read2,adaptor1,adaptor2,min_len):#adaptor1 30个碱基匹配到read1，adaptor2 20个碱基匹配到read2
    seq1 =read1.seq
    seq2 =read2.seq
    if len(adaptor1)>30:
        pos = seq1.find(adaptor1[0:30]) #截取30个碱基的adaptor1
    else:
        pos = seq1.find(adaptor1)
    if pos > min_len:  #控制长度大于50
        return True,read1[:pos],read2[:pos] # del seq1\seq2
    if len(adaptor2) > 30:
        pos2 = seq2.find(adaptor2[0:30])
    else:
        pos2 = seq2.find(adaptor2)
    if pos2 > min_len: #控制长度大于50
        return True,read1[:pos2],read2[:pos2]
    if pos==-1 and pos2==-1:
        return False,read1,read2
    return True,None,None
def situation_2(read1,read2,adaptor1,adaptor2): #四次匹配中只有0、1、2次匹配上的
    seq1 = read1.seq
    seq2 = read2.seq
    true_num = 0
    adaptor_read1_pos_1 = match_adaptor(seq1,adaptor1[0:7]) #考虑接头自连情况没有写【0:7】
    adaptor_read1_pos_2 = match_adaptor(seq1,adaptor1[7:14])
    adaptor_read2_pos_1 = match_adaptor(seq2,adaptor2[0:7])
    adaptor_read2_pos_2 = match_adaptor(seq2,adaptor2[7:14])
    if adaptor_read1_pos_1:
        true_num += 1
    if adaptor_read1_pos_2:
        true_num += 1
    if adaptor_read2_pos_1:
        true_num += 1
    if adaptor_read2_pos_2:
        true_num += 1
    if true_num == 0: #更严格是 true_num=1 删除了
        return True,read1,read2 #clean reads
    else:
        return False,None,None
def rmPE(read1,read2,adaptor1,adaptor2,mistaken_ratio,min_len,mistaken_num):
    result = situation_1(read1,read2,adaptor1,adaptor2,min_len)
    if result[0]:
        return False,result[1],result[2] #del seq1 and seq2

    result = situation_2(read1,read2,adaptor1,adaptor2)
    if result[0]:
        return True,result[1],result[2]  #clean seq1 and seq2

    res_1 = rmSE(read1,adaptor1,mistaken_ratio,min_len,mistaken_num)
    if res_1[1] is None:
        return False,None,None
    res_2 = rmSE(read2,adaptor2,mistaken_ratio,min_len,mistaken_num)
    if res_1[0] and res_2[0]:
        return True,res_1[1],res_2[1]
    else:
        if res_2[1] is  None:
            return False, None, None
        if res_1[2]>res_2[2]:
            return False,res_1[1][:res_2[2]],res_2[1]
        elif res_1[2]==res_2[2]:
            return False,res_1[1],res_2[1]
        else:
            return False,res_1[1],res_2[1][:res_1[2]]


def rmSE(read,adaptor,mistaken_ratio,min_len,mistaken_num):
    seq = read.seq
    seed_len = 6
    adaptor_len = len(adaptor)
    seq_len = len(seq)
    for i in [0,6,12]:#之前是【0,6,12】
        seed = adaptor[i:i+seed_len]
        seed_count = seq.count(seed)
        if seed_count==0:
            continue
        pos = 0
        for j in range(seed_count):
            find_pos = seq.find(seed,pos)
            mistaken_count_max =get_mistaken_count_max(seq_len, (find_pos-i), adaptor_len, mistaken_ratio, mistaken_num)
            mistaken_count = 0
            _b = find_pos
            _e = find_pos + seed_len
            while(_b >= 0 and i >= find_pos - _b):
                if adaptor[i - find_pos + _b] != seq[_b]:
                    mistaken_count += 1
                if mistaken_count > mistaken_count_max:
                    break
                _b -= 1
            else :
                while(_e < seq_len and i - find_pos + _e < adaptor_len):
                    if adaptor[ i - find_pos + _e ] != seq[_e]:
                        mistaken_count += 1
                    if mistaken_count > mistaken_count_max:
                        break
                    _e += 1
                else:
                    if _b+1 > min_len:
                        return False,read[:_b+1],_b+1
                    if (_b+1 >= 0)  and (_b+1 <= min_len):
                        return False,None,0
            pos = find_pos + 1
    return True,read,seq_len


def rmAdaptor(type,read1_file,read2_file,adaptor1,adaptor2,out_prefix,out_type,mistaken_ratio,min_len,mistaken_num):
    total_read_num = 0
    clean_read_num = 0
    adaptor_read_num = 0
    remaining_read_num = 0
    if type=='PE':
        read2_records = SeqIO.parse(gzip.open(read2_file),'fastq')
        read1_out = open( '%s.1.fq'%out_prefix,'w' )
        read2_out = open( '%s.2.fq'%out_prefix,'w' )
        if out_type==4:
            read1_rm_out = open( '%s.1_rm.fq'%out_prefix,'w' )
            read2_rm_out = open( '%s.2_rm.fq'%out_prefix,'w' )
            for read1 in SeqIO.parse(gzip.open(read1_file),'fastq'):
                total_read_num += 2
                read2 = read2_records.next()
                #p = Pool(process_num-(process_num/3))
                #for i in range(process_num):
                    #rmPE_res= p.apply_async(rmPE,args=(read1,read2,adaptor1,adaptor2,mistaken_ratio,min_len))
                #p.close()
                #p.join()

                rmPE_res = rmPE(read1,read2,adaptor1,adaptor2,mistaken_ratio,min_len,mistaken_num)
                if rmPE_res[0]:
                    clean_read_num += 2
                    read1_out.write(rmPE_res[1].format('fastq'))#clean read
                    read2_out.write(rmPE_res[2].format('fastq'))#clean read
                else:
                    adaptor_read_num += 2
                    if (rmPE_res[1] is None) or (rmPE_res[2] is None):
                        remaining_read_num += 2
                        continue
                    read1_rm_out.write(rmPE_res[1].format('fastq'))#adaptor read
                    read2_rm_out.write(rmPE_res[2].format('fastq'))#adaptor read
            read1_rm_out.close()
            read2_rm_out.close()
        else:
            for read1 in SeqIO.parse(gzip.open(read1_file),'fastq'):
                total_read_num += 2
                read2 = read2_records.next()
                rmPE_res = rmPE(read1,read2,adaptor1,adaptor2,mistaken_ratio,min_len,mistaken_num)
                #p = Pool(process_num-(process_num/3))
                #for i in range(process_num):
                    #rmPE_res= p.apply_async(rmPE,args=(read1,read2,adaptor1,adaptor2,mistaken_ratio,min_len))
                #p.close()
                #p.join()
                if rmPE_res[0]:
                    clean_read_num += 2
                    read1_out.write(rmPE_res[1].format('fastq'))#clean read
                    read2_out.write(rmPE_res[2].format('fastq'))#clean read
                else:
                    adaptor_read_num += 2
                    if (rmPE_res[1] is None) or (rmPE_res[2] is None):
                        remaining_read_num += 2
                        continue
                    read1_out.write(rmPE_res[1].format('fastq'))#adaptor read
                    read2_out.write(rmPE_res[2].format('fastq'))#adaptor read
        read1_out.close()
        read2_out.close()
        return total_read_num,clean_read_num,adaptor_read_num,remaining_read_num







if __name__ == '__main__':

    # "python 01.rmAdaptor.py --type PE --out_prefix zwd_5 -r1 1.fq -r2 2.fq -a1 GATCGGAAGAGCACACGTCTGAACTCCAGTCAC -a2 GATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT --out_type 2"
    #params = read_params(tt)
    #read1_file = "1.fq"
    #read2_file = "2.fq"
    #adaptor1 = "GATCGGAAGAGCACACGTCTGAACTCCAGTCAC"[:30]
    #adaptor2 = "GATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT"[:30]
    #type = "PE"
    #out_prefix = "zwd_5"
    #mistaken_ratio = 0.2
    #out_type = 2
    #min_len = 50
    #mistaken_num = "3"
    #process_num = params["process"]
    #sys.stdout.write("you have the number of cpu is %s ,you set process is %s"%(cpu_count(),process_num))
    params = read_params(sys.argv)
    read1_file = params["read1"]
    read2_file = params["read2"]
    adaptor1 = params["read1Adaptor"][:30]
    adaptor2 = params["read2Adaptor"][:30]
    type = params["type"]
    out_prefix = params["out_prefix"]
    mistaken_ratio = params["mistaken_ratio"]
    out_type = params["out_type"]
    min_len = params["min_len"]
    mistaken_num = params["mistaken_num"]
    starttime = time()
    # type ="PE"
    # read1_file="D:\\Workspaces\\metagenome\\test.1.fq"
    # read2_file="D:\\Workspaces\\metagenome\\test.2.fq"
    # adaptor1="AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC"
    # adaptor2="AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT"
    # out_prefix = "D:\\Workspaces\\metagenome\\test2_"
    # out_type = 2
    # mistaken_ratio= 0.2
    # min_len = 40
    total_read_num,clean_read_num,adaptor_read_num,remaining_read_num = rmAdaptor(type,read1_file,read2_file,adaptor1,adaptor2,out_prefix,out_type,mistaken_ratio,min_len,mistaken_num)
    with open("%s_adaptor_statistical.tsv" % out_prefix,mode="w") as fqout:
        fqout.write("sampleName\ttotal_reads\tno_adaptor_reads\tadaptor_reads\tremaining_reads_num\n")
        fqout.write("%s\t%s\t%s\t%s\t%s\n" % (os.path.basename(out_prefix),total_read_num,clean_read_num,adaptor_read_num,(clean_read_num+adaptor_read_num-remaining_read_num)))
    endtime = time()
    sys.stdout.write("use time %s second"%(endtime-starttime))

