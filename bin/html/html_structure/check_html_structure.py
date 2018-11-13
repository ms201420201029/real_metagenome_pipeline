#!/usr/bin/python3
#-*- coding : utf-8 -*-
##########################################################
#
#       Filename: check_html_structure.py
#         Author: mas@realbio.cn
#    Description: 检查默认的配置文件，形成几个新的配置文件，几个分组就有几个配置文件
#  Last Modified: 2018-10-25 15:31:25
#
#                 Copyright (C) 20181016 Ruiyi Corporation
##########################################################

import os
import glob
import regex as re
import sys
import argparse
from configparser import ConfigParser



def read_params(args):
    parser = argparse.ArgumentParser(description='''整理结果文件，1.0版本''')
    parser.add_argument('-c', '--config', dest='config', metavar='file', type=str, required=True,
                        help='标准复制文件的配置文档')
    parser.add_argument('-p', '--project_config', dest='project_config', metavar='file', type=str, required=True,
                        help='项目的配置文件，为了获取项目路径和分组名称')
    parser.add_argument('-g', '--group_path', dest='group_path', metavar='dir', type=str, required=True,
                        help='项目的配置文件，为了获取项目路径和分组名称')
    parser.add_argument('-o', '--output_dir', dest='output_dir', metavar='output_dir', type=str, required=True,
                        help='结果文件的输出路径（因为项目路径可能有多个，因此不能根据项目路径确定）')
    parser.add_argument('-os', '--out_suffix', dest='out_suffix', metavar='out_suffix', type=str, required=True,
                        help='设置新配置文件的后缀，输出文件为：分组名_后缀')
    args = parser.parse_args()
    params = vars(args)
    return params


def mkdir(*path):
    for sub_path in path:
        if not os.path.isdir(sub_path):
            os.system('mkdir -p %s' % sub_path)


def get_name(path):
    '''
    默认以.作为分隔符，最后一个点之前的为名称，最后一个点之后的为后缀
    '''
    basename = os.path.basename(path)
    dirname  = os.path.split(path)[0]
    filename = os.path.splitext(basename)[0]
    suffix   = os.path.splitext(basename)[1]
    return dirname,filename,suffix


def check_groups_exists(path, groups):
    '''
    检查文件夹下是否存在这几个分组文件
    '''
    unexist_groups = []
    for group in groups:
        if not glob.glob(path+'/'+group+'_group.list'):
            unexist_groups.append(group)

    if unexist_groups:
        raise Exception('%s 中缺少分组文件： %s' % (path, ', '.join(unexist_groups)))


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
        if set([len(files) for files in dir_dict.values()]) == 1 and len(files) == len(list(dir_dict.values())[0]):
            for file in files:
                if set([os.path.getsize(d+'/'+file) for d in dir_dict.keys()]) != 1:
                    return list(dir_dict.keys()), []
            return [list(dir_dict.keys())[0]], []
        else:
            return list(dir_dict.keys()), []


def check_if_sample_enough(dirs):
    '''
    通过这层或者上一层是否存在样品不足的日志文件来判断此分析是否是样品不足
    足返回True，不足返回False
    '''
    for dir in dirs:
        if glob.glob(dir+'/Sample_not_enough.log') or glob.glob('/'+'/'.join([d for d in dir.split('/') if d][:-1])+'/Sample_not_enough.log') or glob.glob('/'+'/'.join([d for d in dir.split('/') if d][:-2])+'/Sample_not_enough.log'):
            return False
    return True


def is_file_exists(dirs, file):
    '''
    判断多个文件中是否含有该文件（文件为含通配符的名称或者固定文件名）
    若不存在，则返回与配置路径最相近的文件夹名称
    '''
    if '*' in file:
        file_dirs = []
        for dir in dirs:
            for f in glob.glob(dir+'/'+file):
                if os.path.isfile(f):
                    file_dirs.append(dir+'/'+file)
                    break
    else:
        file_dirs = [dir+'/'+file for dir in dirs if glob.glob(dir+'/'+file) if os.path.isfile(dir+'/'+file)]
    if file_dirs:
        return file_dirs, []
    else:
        # 为了避免路径中存在//还有最后没有/的情况，重新对路径格式进行调整
        dirs = ['/'+'/'.join([d for d in (dir+'/'+file).split('/') if d][:-1])+'/' for dir in dirs]
        for i in range(-1, -min([len(dir.split('/'))-2 for dir in dirs]), -1):
            similar_dirs = [dir for dir in dirs if os.path.exists('/'.join(dir.split('/')[:i]))]
            if similar_dirs:
                return [], similar_dirs


def check_same_file(dirs, file):
    '''
    检查多个文件夹中是否含有一样名称的文件，若有，检查大小是否一致，若一致，则认为一样名称的两个文件是同一个文件
    例如：file为*.txt时找到aaa/b.txt bbb/b.txt ccc/b.txt aaa/a.txt，对于b.txt，若大小一致，则认为是一个文件，若不一致则认为存在多个文件
    return 多个一致文件的全路径
    '''
    files = []
    for dir in dirs:
        files += [f for f in glob.glob(dir + '/' + file) if os.path.isfile(f)]

    files_dict = {}
    for file in files:
        basename = os.path.basename(file)
        if basename not in files_dict.keys():
            files_dict[basename] = [file]
        else:
            files_dict[basename].append(file)

    same_files = {}
    for file in files_dict.keys():
        if len(files_dict[file]) > 1 and len(set([os.path.getsize(f) for f in files_dict[file]])) != 1:
            same_files[file] = files_dict[file]
    return same_files


def list_all_files(dir, standard_dirs, suffixes, files=[]):
    '''
    列举文件夹中所有需要的文件
    '''
    all_files = os.listdir(dir)
    # standard_dirs为了去除第一层的文件夹，第二层以后的迭代就不需要判断了
    all_files = [dir+'/'+file for file in all_files if file not in standard_dirs]
    for file in all_files:
        if os.path.isfile(file) and any([file.endswith(suf) for suf in suffixes]):
            files.append(file)
        elif os.path.isdir(file):
            files = list_all_files(file, [], suffixes, files)
    return files


if __name__ == '__main__':
    params = read_params(sys.argv)

    config_file  = params['config']
    group_path   = params['group_path']
    output_dir   = params['output_dir']
    out_suffix = params['out_suffix']

    project_config = ConfigParser()
    project_config.read(params['project_config'])
    # 获取一个或多个工作路径的名称
    work_dirs = re.split('\s+|\t+|,', project_config.get('html','work_dir'))
    # 对dir格式进行规范，统一改成/aaa/bbb/ccc格式
    work_dirs = ['/'+'/'.join([d for d in dir.split('/') if d]) for dir in work_dirs if dir]

    # 获取分组名称
    groups = re.split('\s+|\t+|,', project_config.get('html','group'))
    groups = [os.path.splitext(g)[0] for g in groups if g]  # 需要确定是写分组名称还是文件
    check_groups_exists(group_path, groups)

    # 获取组装方法
    assembly_method = project_config.get('param','assembly_method')

    # 获取project信息
    project_num = project_config.get('project','project_num')
    project_name = project_config.get('project','project_name')

    # 获取batch最后一次的名称，用来复制最后一次raw data和qc的统计结果
    batch_list = re.split('\s+|\t+|,', project_config.get('html','batch_list'))
    batch_list = [b for b in batch_list if b]
    if len(batch_list) > 1:
        sys.stderr.write('发现多个batch_list文件：%s，请按照时间顺序合并成一个文件并重新配置%s文件！\n' % ('、'.join(batch_list), params['project_config']))
        sys.exit()

    with open(batch_list[0], 'r') as batch:
        for line in batch:
            tabs = line.strip().split('\t')
            tabs = [t.strip() for t in tabs if t]
            if len(tabs) > 1:
                batch_name = tabs[0]
    print('     final batch name is ： %s' % batch_name)

    for group in groups:
        with open(group_path+'/'+group+'_group.list', 'r') as gf:
            example_sample = gf.readline().split('\t')[0]

        with open(config_file, 'r') as conf, open(output_dir+'/'+group+'_'+out_suffix, 'w') as new_conf:
            # 在新的配置文件前先输出项目名称和项目编号，可以根据这个得到创建的文件夹的名称。
            new_conf.write('# 结果文件的输出路径\n')
            new_conf.write('%s\t%s\n' % ('output_dir', output_dir))
            new_conf.write('# 项目编号\n')
            new_conf.write('%s\t%s\n' % ('project_num', project_num))
            new_conf.write('# 项目名称\n')
            new_conf.write('%s\t%s\n' % ('project_name', project_name))
            new_conf.write('# 参考的分组文件\n')
            new_conf.write('%s\t%s\n' % ('group', group))

            for line in conf:
                if line.strip().startswith('#') or not line.strip():
                    new_conf.write(line)
                    continue

                tabs = line.strip().split('\t')

                if '#@' in tabs[1]:
                    for i, j in zip(['#@batch', '#@sample', '#@assembly', '#@group'], [batch_name, example_sample, assembly_method, group]):
                        tabs[1] = re.sub(i, j, tabs[1])

                # 判断样品够不够，其实只有涉及group的时候才会存在样品够不够，但是其他基本上也不会存在sample_not_enough.log文件，因此我们可以简单的对所有的情况统一判断
                if check_if_sample_enough([dir+'/'+os.path.dirname(tabs[1]) for dir in work_dirs]):
                    # 样品足：
                    #    1、文件是否存在 （1）不存在 （2）存在一个 （3）存在多个
                    file_dirs, similar_dirs = is_file_exists(work_dirs, tabs[1])
                    if file_dirs:
                        # 文件存在
                        if len(file_dirs) == 1 or len(set([os.path.getsize(f) for f in file_dirs])) == 1:
                            # 文件只有一个，或多个文件大小一致，选取其中之一
                            new_conf.write('%s\t%s\t%s\n' % (tabs[0], file_dirs[0], tabs[2]))
                        else:
                            new_conf.write('\n#################################################################################################################################################\n')
                            new_conf.write('# warning : %s文件有%d个，且大小不一，请检查原因并修改下面配置！（默认选择第一个）\n' % (re.sub('#@batch', batch_name, tabs[1]), len(file_dirs)))
                            for f in file_dirs:
                                new_conf.write('%s\t%s\t%s\n' % (tabs[0], f, tabs[2]))
                            new_conf.write('#################################################################################################################################################\n\n')
                    else:
                        print(tabs)
                        # 文件不存在
                        new_conf.write('\n#################################################################################################################################################\n')
                        new_conf.write('# warning : %s文件不存在，请检查原因并修改下面配置！\n' % tabs[1])
                        for f in similar_dirs:
                            new_conf.write('%s\t%s\t%s\n' % (tabs[0], f+'/'+os.path.basename(tabs[1]), tabs[2]))
                        new_conf.write('#################################################################################################################################################\n\n')

                else:
                    # 样品不足
                    new_conf.write('%s\t%s\tsample_not_enough.log\n' % (tabs[0], tabs[1]))

