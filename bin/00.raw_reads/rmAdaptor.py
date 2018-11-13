#!/usr/bin/env python
#-*- coding: utf-8 -*-

# Description: Remove adapter
# Copyright (C) 20170721 Ruiyi Corporation
# Email: lixr@realbio.cn

import os, re, sys, argparse, gzip, math
from time import time

def read_params(args):
    parser = argparse.ArgumentParser(description="2017/07/21 by lixr")
    parser.add_argument('--prefix',dest='prefix',metavar="DIR",type=str,required=True,
                        help="out file prefix")
    parser.add_argument('-r1', '--read1', dest='read1', metavar='DIR', type=str, required=True,
                        help="read1.fastq")
    parser.add_argument('-r2', '--read2', dest='read2', metavar='DIR', type=str, required=True,
                        help="read2.fastq")
    parser.add_argument('-a1', '--read1Adaptor', dest='read1Adaptor', metavar='string', type=str, required=True,
                        help="AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC")
    parser.add_argument('-a2', '--read2Adaptor', dest='read2Adaptor', metavar='string', type=str, required=True,
                        help="AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT")
    parser.add_argument('--seq_type',dest="seq_type",metavar='string',type=str,required=True,
                        help="PE or SE")
    parser.add_argument('--mis_ratio',dest="mis_ratio",metavar="float",type=float,default=0.2,
                        help="mis_ratio defult[0.2]")
    parser.add_argument('--mis_num', dest="mis_num", metavar="int", type=int, default=3,
                        help="mis_ratio defult[3]")
    parser.add_argument('--out_type',dest="out_type",metavar="STRING",type=int,default=4,
                        help="2 : two file out ;  4 : four file out.")
    parser.add_argument('--min_len',dest="min_len",metavar="min_len",type=int,default=99,
                        help="min_len[100]")
    return vars(parser.parse_args())

def read_gzipfile(file):
    bytes_decode = bytes.decode
    all_data = gzip.open(file,'rb')
    for line in all_data:
        line = bytes_decode(line)
        yield line.strip()

def get_mis_count_max(seq_len, find_pos, adaptor_len, mis_ratio, mis_num):
    mis_count_max = adaptor_len * mis_ratio if seq_len - find_pos > adaptor_len else (seq_len - find_pos) * mis_ratio
    if mis_count_max < float(mis_num):
        mis_count_max = mis_num
    return math.ceil(mis_count_max)

def match_adaptor(read,seed):
    index = read.find(seed)
    if index == -1:
        return False
    else:
        return True

def situation_1(read1,read2,adaptor1,adaptor2,min_len):
    pos1 = read1.find(adaptor1[0:30]) if len(adaptor1) > 30 else read1.find(adaptor1)
    pos2 = read2.find(adaptor2[0:30]) if len(adaptor2) > 30 else read2.find(adaptor2)
    if pos1 == -1 and pos2 == -1:
        return False, read1, read2
    elif pos1 > pos2 > min_len:
        return True,read1[:pos2],read2[:pos2]
    elif pos2 > pos1 > min_len:
        return True,read1[:pos1],read2[:pos1]
    return True, None, None

def situation_2(read1,read2,adaptor1,adaptor2):
    adaptor_read1_pos_1 = match_adaptor(read1,adaptor1[0:7])
    adaptor_read1_pos_2 = match_adaptor(read1,adaptor1[7:14])
    adaptor_read2_pos_1 = match_adaptor(read2,adaptor2[0:7])
    adaptor_read2_pos_2 = match_adaptor(read2,adaptor2[7:14])
    if adaptor_read1_pos_1 or adaptor_read1_pos_2 or adaptor_read2_pos_1 or adaptor_read2_pos_2:
        return False,None,None
    else:
        return True,read1,read2                 #clean reads

def rmPE(read1,read2,adaptor1,adaptor2,mis_ratio,min_len,mis_num):
    result = situation_1(read1,read2,adaptor1,adaptor2,min_len)
    if result[0]:
        return False,result[1],result[2]
    result = situation_2(read1,read2,adaptor1,adaptor2)
    if result[0]:
        return True,result[1],result[2]

    res_1 = rmSE(read1,adaptor1,mis_ratio,min_len,mis_num)
    if res_1[1] is None:
        return False,None,None
    res_2 = rmSE(read2,adaptor2,mis_ratio,min_len,mis_num)
    if res_1[0] and res_2[0]:
        return True,res_1[1],res_2[1]
    else:
        if res_2[1] is  None:
            return False, None, None
        if res_1[2] > res_2[2]:
            return False,res_1[1][:res_2[2]],res_2[1]
        elif res_1[2] == res_2[2]:
            return False,res_1[1],res_2[1]
        else:
            return False,res_1[1],res_2[1][:res_1[2]]

def rmSE(read,adaptor,mis_ratio,min_len,mis_num):
    adaptor_len = len(adaptor)
    seq_len = len(read)
    for i in [0,6,12]:                                    #adaptor分段匹配，允许最多三个错配
        seed = adaptor[i:i+6]
        seed_count = read.count(seed)
        if seed_count==0:
            continue
        pos = 0
        for j in range(seed_count):
            find_pos = read.find(seed,pos)
            mis_count_max =get_mis_count_max(seq_len, (find_pos-i), adaptor_len, mis_ratio, mis_num)
            mistaken_count = 0
            _b = find_pos
            _e = find_pos + 6
            while(_b >= 0 and i >= find_pos - _b):
                if adaptor[i - find_pos + _b] != read[_b]:
                    mistaken_count += 1
                if mistaken_count > mis_count_max:
                    break
                _b -= 1
            else :
                while(_e < seq_len and i - find_pos + _e < adaptor_len):
                    if adaptor[ i - find_pos + _e ] != read[_e]:
                        mistaken_count += 1
                    if mistaken_count > mis_count_max:
                        break
                    _e += 1
                else:
                    if _b+1 > min_len:
                        return False,read[:_b+1],_b+1
                    if (_b+1 >= 0)  and (_b+1 <= min_len):
                        return False,None,0
            pos = find_pos + 1
    return True,read,seq_len

def rmAdaptor(seq_type,read1_file,read2_file,adaptor1,adaptor2,prefix,out_type,mis_ratio,min_len,mis_num):
    total_read_num ,clean_read_num, adaptor_read_num, length_true = 0, 0, 0, 0
    if seq_type=='PE':
        read1_out = open( '%s.1.fq'%prefix,'w' )
        read2_out = open( '%s.2.fq'%prefix,'w' )
        if out_type==4:
            read1_rm_out = open( '%s.1_rm.fq'%prefix,'w' )
            read2_rm_out = open( '%s.2_rm.fq'%prefix,'w' )
            for read1,read2 in zip(read_gzipfile(read1_file),read_gzipfile(read2_file)):
                if re.match(r'@',read1):
                    logic, read1_list, read2_list = 0, [], []
                logic += 1
                if logic == 2:
                    total_read_num += 2
                    rmPE_res = rmPE(read1,read2,adaptor1,adaptor2,mis_ratio,min_len,mis_num)
                    if rmPE_res[0]:
                        clean_read_num += 2
                        read1_list.append(rmPE_res[1])              #clean read
                        read2_list.append(rmPE_res[2])              #clean read
                        write_true = 1                              #判定read写入什么文件
                    else:
                        adaptor_read_num += 2
                        if (rmPE_res[1] is None) or (rmPE_res[2] is None):
                            write_true = 0
                            continue
                        read1_list.append(rmPE_res[1])              #adaptor read
                        read2_list.append(rmPE_res[2])              #adaptor read
                        length = len(rmPE_res[1])
                        length_true, write_true = 1, 2              
                    continue
                if logic == 4 and length_true:                      #质量值长度需要与adaptor read长度一致
                    read1_list.append(read1[:length])
                    read2_list.append(read2[:length])
                    length_true = 0
                else:
                    read1_list.append(read1)
                    read2_list.append(read2)
                if logic == 4 and write_true == 1:
                    read1_out.write('%s\n' % '\n'.join(read1_list))
                    read2_out.write('%s\n' % '\n'.join(read2_list))
                elif logic == 4 and write_true == 2:
                    read1_rm_out.write('%s\n' % '\n'.join(read1_list))
                    read2_rm_out.write('%s\n' % '\n'.join(read2_list))
            read1_rm_out.close()
            read2_rm_out.close()
        else:
            for read1,read2 in zip(read_gzipfile(read1_file),read_gzipfile(read2_file)):
                if re.match(r'@',read1):
                    logic, write_true, read1_list, read2_list = 0, 0, [], []
                logic += 1
                if logic == 2:
                    total_read_num += 2
                    rmPE_res = rmPE(read1,read2,adaptor1,adaptor2,mis_ratio,min_len,mis_num)
                    if rmPE_res[0]:
                        clean_read_num += 2
                        read1_list.append(rmPE_res[1])              #clean read
                        read2_list.append(rmPE_res[2])              #clean read
                        write_true = 1                              #判定是否写入read
                    else:
                        adaptor_read_num += 2
                        if rmPE_res[1] is None or rmPE_res[2] is None:
                            write_true = 0
                            continue
                        read1_list.append(rmPE_res[1])              #adaptor read
                        read2_list.append(rmPE_res[2])              #adaptor read
                        length = len(rmPE_res[1])
                        length_true, write_true = 1, 1
                    continue
                if logic == 4 and length_true:
                    read1_list.append(read1[:length])
                    read2_list.append(read2[:length])
                    length_true = 0
                else:
                    read1_list.append(read1)
                    read2_list.append(read2)
                if logic == 4 and write_true:
                    read1_out.write('%s\n' % '\n'.join(read1_list))
                    read2_out.write('%s\n' % '\n'.join(read2_list))
        read1_out.close()
        read2_out.close()
        return total_read_num,clean_read_num,adaptor_read_num

if __name__ == '__main__':
    params = read_params(sys.argv)
    read1_file = params["read1"]
    read2_file = params["read2"]
    adaptor1 = params["read1Adaptor"][:30]
    adaptor2 = params["read2Adaptor"][:30]
    seq_type = params["seq_type"]
    prefix = params["prefix"]
    mis_ratio = params["mis_ratio"]
    out_type = params["out_type"]
    min_len = params["min_len"]
    mis_num = params["mis_num"]
    starttime = time()
    total_read_num,clean_read_num,adaptor_read_num = rmAdaptor(seq_type,read1_file,read2_file,adaptor1,adaptor2,prefix,out_type,mis_ratio,min_len,mis_num)
    with open("%s_adaptor_statistical.tsv" % prefix,'w') as fqout:
        fqout.write("sampleName\ttotal_reads\tremain_reads\tadaptor_reads\n")
        fqout.write("%s\t%s\t%s\t%s\n" % (os.path.basename(prefix),total_read_num,clean_read_num,adaptor_read_num))
    endtime = time()
    sys.stdout.write("use time %s second\n"%(endtime-starttime))

