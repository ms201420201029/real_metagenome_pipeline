#!/usr/bin/python3
#-*- coding : utf-8 -*-
##########################################################
#
#       Filename: cp_result_structure.py
#         Author: mas@realbio.cn
#    Description: 复制配置文件中的内容到指定结果目录下
#  Last Modified: 2018-11-12 17:46:00
#
#                 Copyright (C) 20181112 Ruiyi Corporation
##########################################################

import argparse
import os
import sys
import regex as re
import glob


def read_params():
    parser = argparse.ArgumentParser()
    parser.add_argument('-c', '--result_config', metavar='file', dest='result_config', required=True, type=str,
                        help='result_structure检查后的新配置文件')
    parser.add_argument('-so', '--standard_outdir', metavar='dir', dest='standard_outdir', required=True, type=str,
                        help='标准结果的输出文件夹')
    parser.add_argument('-do', '--data_outdir', metavar='dir', dest='data_outdir', required=True, type=str,
                        help='数据结果的输出文件夹')
    args = parser.parse_args()
    params = vars(args)
    return params


def mkdir(*path):
    for sub_path in path:
        if not os.path.isdir(sub_path):
            os.system('mkdir -p %s' % sub_path)


def list_files(find_dir, suffixes):
    files = []
    all_files = glob.glob(find_dir+'/*')
    for file in all_files:
        file = file
        if os.path.isfile(file) and any([file.endswith(suf) for suf in suffixes]):
            files.append(file)
    return files


def list_all_files(find_dir, suffixes, files=[]):
    '''
    列举文件夹中所有需要的文件
    '''
    all_files = os.listdir(find_dir)
    for file in all_files:
        if os.path.isfile(file) and any([file.endswith(suf) for suf in suffixes]):
            files.append(file)
        elif os.path.isdir(file):
            files = list_all_files(file, suffixes, files)
    return files


def check_same_dir(dirs, save_suffix):
    '''
    判断多个文件夹是否一致，文件夹内对应后缀的所有文件名和大小都一致
    若都空，则返回None；若非空但文件内容和大小都一致则返回其一；若不一致，则返回不一致的所有文件夹（不包含空文件夹）
    '''
    # 统计每个文件夹中的符合条件的文件
    dir_dict = {}
    for dir in dirs:
        for suf in save_suffix:
            suf_files = [f for f in glob.glob(dir+'/*.'+suf) if os.path.isfile(f)]
            if suf_files:
                if dir not in dir_dict.keys():
                    dir_dict[dir] = suf_files
                else:
                    dir_dict[dir] += suf_files

    # 若只有一个文件夹，直接返回；若一个都没有，返回与配置路径最相似的文件夹；多个文件夹，判断文件个数和文件大小是否都一致，一致返回其中之一，不一致，返回所有路径
    if len(dir_dict.keys()) == 1:
        return list(dir_dict.keys()), []
    elif len(dir_dict.keys()) == 0:
        # 为了避免路径中存在//还有最后没有/的情况，重新对路径格式进行调整
        dirs = ['/'+'/'.join([d for d in dir.split('/') if d])+'/' for dir in dirs]
        for i in range(-1, -min([len(dir.split('/'))-2 for dir in dirs]), -1):
            similar_dirs = [dir for dir in dirs if os.path.exists('/'.join(dir.split('/')[:i]))]
            if similar_dirs:
                return [], similar_dirs

        return [], similar_dirs
    else:
        files = []
        for dir in dir_dict.keys():
            files += [os.path.basename(f) for f in dir_dict[dir]]
        files = list(set(files))
        if len(set([len(fs) for fs in dir_dict.values()])) == 1 and len(files) == len(list(dir_dict.values())[0]):
            # 文件名称全部一致
            for file in files:
                if len(set([os.path.getsize(d+'/'+file) for d in dir_dict.keys()])) != 1:
                    return list(dir_dict.keys()), []
            return [list(dir_dict.keys())[0]], []
        else:
            return list(dir_dict.keys()), []


if __name__ == '__main__':
    params = read_params()
    new_config      = params['result_config']
    standard_outdir = params['standard_outdir']
    data_outdir     = params['data_outdir']

    if os.path.exists(standard_outdir):
        os.system('rm -rf %s' % standard_outdir)
    if os.path.exists(data_outdir):
        os.system('rm -rf %s' % data_outdir)

    result_info = {}

    with open(new_config, 'r') as new_conf:
        for line in new_conf:
            if line.strip().startswith('#') or not line.strip():
                continue

            tabs = line.strip().split('\t')

            if len(tabs) == 1:
                # 认为是要创建的文件夹
                mkdir(standard_outdir + '/' + tabs[0])

            elif len(tabs) == 2:
                # 认为是项目信息的键值对
                result_info[tabs[0]] = tabs[1]
                if tabs[0] == 'save_suffixes':
                    result_info[tabs[0]] = [i.strip() for i in tabs[1].strip().split(',')]

            elif len(tabs) == 3 and tabs[0] == 'file':
                '''
                文件，并指定文件名，会出现四种情况：
                    1、目标文件不存在（错误）
                    2、目标文件存在且结果文件不存在（复制）
                    3、结果文件已存在，并大小一致（pass）
                    4、结果文件已存在，并大小不一致（给出warning）
                '''
                if not os.path.isdir(standard_outdir+'/'+os.path.dirname(tabs[2])):
                    mkdir(standard_outdir+'/'+os.path.dirname(tabs[2]))

                if os.path.isfile(tabs[1]):
                    # 目标文件存在
                    if not os.path.isfile(tabs[2]):
                        os.system('cp %s %s' % (tabs[1], standard_outdir+'/'+tabs[2]))
                    elif not os.path.getsize(tabs[1]) == os.path.getsize(standard_outdir+'/'+tabs[2]):
                        print('warning : %s 文件已存在，且与 %s 文件大小不一致，未完成对 %s 的复制！' % (standard_outdir+'/'+tabs[2], tabs[1], tabs[1]))

                elif not os.path.isfile(standard_outdir+'/'+tabs[2]):
                    # 目标文件不存在
                    sys.stderr.write('error : %s 文件不存在，可能会导致 %s 结果不存在，请检查配置文件！\n' % (tabs[1], standard_outdir+'/'+tabs[2]))

            elif len(tabs) == 3 and tabs[0] == 'files':
                '''
                文件，有通配符，可以存在一样的文件名
                    1、目标文件不存在（错误）
                    2、结果文件不存在，直接复制
                    3、结果文件已存在，那么在后缀前加上(1)、(2)等
                '''
                if not os.path.isdir(standard_outdir+'/'+tabs[2]):
                    mkdir(standard_outdir+'/'+tabs[2])

                suf = tabs[1].split('*')[-1]
                files = glob.glob(tabs[1])
                if files:
                    for file in files:
                        prefix = os.path.basename(file)[:-len(suf)]
                        match_file = re.compile(prefix+'(\(\w+\))?'+suf)
                        exist_num = len([f for f in glob.glob(standard_outdir+'/'+tabs[2]+'/*'+suf) if match_file.findall(f)])
                        if not exist_num:
                            # 结果文件还不存在
                            os.system('cp %s %s' % (file, standard_outdir+'/'+tabs[2]+'/'))
                        else:
                            os.system('cp %s %s' % (file, standard_outdir+'/'+tabs[2]+'/'+prefix+'\('+str(exist_num)+'\)'+suf))

                else:
                    sys.stderr.write('error : %s 文件不存在，可能会导致 %s 结果为空，请检查配置文件！\n' % (tabs[1], standard_outdir+'/'+tabs[2]))

            elif len(tabs) == 3 and tabs[0] == 'dir':
                '''
                复制对应文件夹下指定文件名（在配置文件中指出）的文件
                存在三种情况：
                    1、目标文件不存在或没有对应后缀的文件（错误）
                    2、目标文件存在且结果文件不存在（复制）
                    3、结果文件存在且大小一致（pass）
                    4、结果文件存在且大小不一致（给出warning）
                '''
                if '*' in tabs[1] and '*' in tabs[2]:
                    '''
                    表明保持原有的目录结构，*这层目录文件夹名不确定，所以用*代替
                    '''
                    cp_dirs = [dir for dir in os.listdir(tabs[1].split('*')[0]) if os.path.isdir(tabs[1].split('*')[0]+dir)]
                    for dir in cp_dirs:
                        cp_dir     = tabs[1].split('*')[0] + dir
                        result_dir = standard_outdir + tabs[2].split('*')[0] + dir

                        if not os.path.isdir(result_dir):
                            mkdir(result_dir)

                        files = list_files(cp_dir, result_info['save_suffixes'])
                        if files:
                            if glob.glob(result_dir+'/*'):
                                # 结果文件中已经有结果了
                                dirs, similar_dirs = check_same_dir([cp_dir, result_dir+'/'], result_info['save_suffixes'])
                                if len(dirs) > 1:
                                    # 说明结果不一致
                                    print('warning : %s 文件非空，且与 %s 文件夹内容或大小不一致，未完成对 %s 的复制！' % (result_dir, cp_dir, cp_dir))
                            else:
                                # 结果文件无结果
                                for file in files:
                                    os.system('cp %s %s' % (file, result_dir+'/'))
                        else:
                            # 目标文件无结果
                            sys.stderr.write('error : %s 文件夹不存在结果文件，可能会导致 %s 结果为空，请检查配置文件！\n' % (cp_dir, result_dir))

                else:
                    if not os.path.isdir(standard_outdir+'/'+tabs[2]):
                        mkdir(standard_outdir+'/'+tabs[2])

                    files = list_files(tabs[1], result_info['save_suffixes'])
                    if files:
                        if glob.glob(standard_outdir+'/'+tabs[2]+'/*'):
                            # 结果文件中已经有结果了
                            dirs, similar_dirs = check_same_dir([tabs[1], standard_outdir+'/'+tabs[2]+'/'], result_info['save_suffixes'])
                            if len(dirs) > 1:
                                # 说明结果不一致
                                print('warning : %s 文件非空，且与 %s 文件夹内容或大小不一致，未完成对 %s 的复制！' % (standard_outdir+'/'+tabs[2], tabs[1], tabs[1]))
                        else:
                            # 结果文件无结果
                            for file in files:
                                os.system('cp %s %s' % (file, standard_outdir+'/'+tabs[2]+'/'))
                    else:
                        # 目标文件无结果
                        sys.stderr.write('error : %s 文件夹不存在结果文件，可能会导致 %s 结果为空，请检查配置文件！\n' % (tabs[1], standard_outdir+'/'+tabs[2]))

            elif len(tabs) == 3 and tabs[0] == 'gnum':
                '''
                目前跟dir一样
                '''
                if not os.path.isdir(standard_outdir+'/'+tabs[2]):
                    mkdir(standard_outdir+'/'+tabs[2])

                files = list_files(tabs[1], result_info['save_suffixes'])
                if files:
                    if glob.glob(standard_outdir+'/'+tabs[2]+'/*'):
                        # 结果文件中已经有结果了
                        dirs, similar_dirs = check_same_dir([tabs[1], standard_outdir+'/'+tabs[2]+'/'], result_info['save_suffixes'])
                        if len(dirs) > 1:
                            # 说明结果不一致
                            print('warning : %s 文件非空，且与 %s 文件夹内容或大小不一致，未完成对 %s 的复制！' % (standard_outdir+'/'+tabs[2], tabs[1], tabs[1]))
                    else:
                        # 结果文件无结果
                        for file in files:
                            os.system('cp %s %s' % (file, standard_outdir+'/'+tabs[2]+'/'))
                else:
                    # 目标文件无结果
                    sys.stderr.write('error : %s 文件夹不存在结果文件，可能会导致 %s 结果为空，请检查配置文件！\n' % (tabs[1], standard_outdir+'/'+tabs[2]))

            elif len(tabs) == 3 and tabs[0] == 'dirs':
                '''

                '''
                print('dirs')


            elif len(tabs) == 3 and tabs[0] == 'sample_not_enough':
                '''
                在文件夹下创建一个sample_not_enough.log文件
                '''
                if not os.path.isdir(standard_outdir+'/'+tabs[2]):
                    mkdir(standard_outdir+'/'+tabs[2])

                os.system('touch %s/sample_not_enough.log' % (standard_outdir+'/'+tabs[2]))

            elif len(tabs) == 3 and tabs[0] == 'group_not_enough':
                '''
                在文件夹下创建一个group_not_enough.log文件
                '''
                if not os.path.isdir(standard_outdir+'/'+tabs[2]):
                    mkdir(standard_outdir+'/'+tabs[2])

                os.system('touch %s/group_not_enough.log' % (standard_outdir+'/'+tabs[2]))

            elif len(tabs) == 3 and tabs[0] == 'data':
                '''
                文件，并指定文件名，会出现四种情况：
                    1、目标文件存在且结果文件不存在（软连接）
                    2、目标文件不存在（错误）
                    3、结果文件已存在，并大小一致（pass）
                '''
                if '*' in tabs[1]:
                    # 创建结果文件夹
                    if not os.path.isdir(data_outdir+'/'+tabs[2]):
                        mkdir(data_outdir+'/'+tabs[2])

                    soft_link_unexist = []
                    unlink = []
                    files = glob.glob(tabs[1])
                    for file in files:
                        if not os.path.exists(data_outdir+'/'+tabs[2]+'/'+os.path.basename(file)):
                            os.system('ln -s %s %s' % (file, data_outdir+'/'+tabs[2]+'/'))
                        else:
                            unlink.append(file)

                        if not os.path.isfile(os.path.realpath(file)):
                            soft_link_unexist.append(file)

                    if soft_link_unexist:
                        sys.stderr.write('error : %s 中的软连接已经生成，但是 %s 的原始文件不存在！\n' % (data_outdir+'/'+tabs[2]+'/', ', '.join(soft_link_unexist)))
                    if unlink:
                        print('warning : %s 中已存在相应链接，未完成对 %s 的软连接！' % (data_outdir+'/'+tabs[2]+'/', ', '.join(unlink)))

                else:
                    # 创建结果文件夹
                    if not os.path.isdir(os.path.dirname(data_outdir+'/'+tabs[2])):
                        mkdir(os.path.dirname(data_outdir+'/'+tabs[2]))

                    if os.path.islink(tabs[1]):
                        file = os.path.realpath(tabs[1])
                    else:
                        file = tabs[1]

                    os.system('ln -s %s %s' % (tabs[1], data_outdir+'/'+tabs[2]))

                    if not os.path.isfile(file):
                        sys.stderr.write('error : %s 软连接已经生成，但是 %s 的原始文件不存在！\n' % (data_outdir+'/'+tabs[2], file))

            elif len(tabs) == 3 and tabs[0] == 'datas':
                '''
                文件，有通配符，可以存在一样的文件名
                    1、目标文件不存在（错误）
                    2、结果文件不存在，直接复制
                    3、结果文件已存在，那么软连接时候在后缀前加上(1)、(2)等
                '''
                if not os.path.isdir(data_outdir+'/'+tabs[2]):
                    mkdir(data_outdir+'/'+tabs[2])

                suf = tabs[1].split('*')[-1]
                files = glob.glob(tabs[1])
                if files:
                    for file in files:
                        prefix = os.path.basename(file)[:-len(suf)]
                        match_file = re.compile(prefix+'(\(\w+\))?'+suf)
                        exist_num = len([f for f in glob.glob(data_outdir+'/'+tabs[2]+'/*'+suf) if match_file.findall(f)])
                        if not exist_num:
                            # 结果文件还不存在
                            os.system('ln -s %s %s' % (file, data_outdir+'/'+tabs[2]+'/'))
                        else:
                            os.system('ln -s %s %s' % (file, data_outdir+'/'+tabs[2]+'/'+prefix+'\('+str(exist_num)+'\)'+suf))

                    soft_link_unexist = []
                    for file in files:
                        if not os.path.isfile(os.path.realpath(file)):
                            soft_link_unexist.append(file)

                    if soft_link_unexist:
                        sys.stderr.write('error : %s 中的软连接已经生成，但是 %s 的原始文件不存在！\n' % (data_outdir+'/'+tabs[2]+'/', ', '.join(soft_link_unexist)))

                else:
                    sys.stderr.write('error : %s 文件不存在，可能会导致 %s 结果为空，请检查配置文件！\n' % (tabs[1], data_outdir+'/'+tabs[2]))

