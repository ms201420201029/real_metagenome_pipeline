#!/usr/bin/python3
#-*- coding : utf-8 -*-
##########################################################
#
#       Filename: cp_html_structure.py
#         Author: mas@realbio.cn
#    Description: ---
#  Last Modified: 2018-10-29 12:08:37
#
#                 Copyright (C) 20181029 Ruiyi Corporation
##########################################################

import argparse
import os
import sys
import glob


def read_params():
    parser = argparse.ArgumentParser()
    parser.add_argument('-c', '--config_file', metavar='config_file', dest='config_file', required=True, type=str,
                        help='输入检查后的配置文件')
    parser.add_argument('-o', '--output_dir', metavar='output_dir', dest='output_dir', required=True, type=str,
                        help='输出文件夹')
    args = parser.parse_args()
    params = vars(args)
    return params


def mkdir(*path):
    for sub_path in path:
        if not os.path.isdir(sub_path):
            os.system('mkdir -p %s' % sub_path)


if __name__ == '__main__':
    params = read_params()
    config = params['config_file']
    output = params['output_dir']

    if not os.path.isdir(output):
        mkdir(output)
    else:
        os.system('rm -rf %s/*' % output)

    project_info = {}

    with open(config, 'r') as new_config:
        for line in new_config:
            if line.strip().startswith('#') or not line.strip():
                # 跳过注释信息和空行
                continue

            tabs = line.strip().split('\t')
            tabs = [tab.strip() for tab in tabs]

            if len(tabs) == 2:
                project_info[tabs[0]] = tabs[1]
            elif len(tabs) == 3:
                if not os.path.isdir(tabs[0]):
                    # 创建文件夹
                    mkdir(output+'/'+tabs[0])

                if tabs[2] == 'sample_not_enough.log':
                    os.system('touch %s/sample_not_enough.log' % (output+'/'+tabs[0]))
                elif tabs[2] == 'group_not_enough.log':
                    os.system('touch %s/group_not_enough.log' % (output+'/'+tabs[0]))
                elif '*' in tabs[1] and '*' not in tabs[2]:
                    if not glob.glob(output+'/'+tabs[2]):
                        files = glob.glob(tabs[1])
                        if not files:
                            sys.stderr.write('error : %s 文件不存在，请分析完成后重新运行此脚本！\n' % tabs[1])
                        else:
                            os.system('cp %s %s' % (files[0], output+'/'+tabs[2]))
                else:
                    if not glob.glob(output+'/'+tabs[2]):
                        # 结果文件不存在
                        files = glob.glob(tabs[1])
                        if not files:
                            # 分析文件不存在
                            sys.stderr.write('error : %s 文件不存在，请分析完成后重新运行此脚本！\n' % tabs[1])
                        elif len(files) == 1:
                            os.system('cp %s %s' % (files[0], output+'/'+tabs[2]))
                        else:
                            for f in files:
                                os.system('cp %s %s' % (f, output+'/'+tabs[0]))
                    else:
                        # 结果文件存在
                        files = glob.glob(tabs[1])
                        if files:
                            sys.stderr.write('warning : 未复制 %s 文件，请检查 %s 文件，若有问题则修改，没有则忽略。\n' % (tabs[1], config))

