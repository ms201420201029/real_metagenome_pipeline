#!/usr/bin/python3
#-*- coding : utf-8 -*-
##########################################################
#
#       Filename: html_structure.py
#         Author: mas@realbio.cn
#    Description: 检查默认的配置文件，形成两个新的配置文件，一个是在原有基础上加入log文件的配置文件，另一个是格外多出内容的配置文件
#  Last Modified: 2018-10-16 11:43:29
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
    parser.add_argument('-c', '--config', dest='config', metavar='FILE', type=str, required=True,
                        help='标准复制文件的配置文档')
    parser.add_argument('-g', '--project_config', dest='project_config', metavar='file', type=str, required=True,
                        help='项目的配置文件，为了获取项目路径和分组名称')
    parser.add_argument('-o', '--output_dir', dest='output_dir', metavar='output_dir', type=str, required=True,
                        help='结果文件的输出路径（因为项目路径可能有多个，因此不能根据项目路径确定）')
    parser.add_argument('-so', '--standard_out', dest='standard_out', metavar='standard_out', type=str, required=True,
                        help='设置标准文件的新配置文件')
    parser.add_argument('-eo', '--extra_out', dest='extra_out', metavar='extra_out', type=str, required=False, default='no',
                        help='设置额外文件的配置文件。由于其他文件夹文件过多等问题，因此，默认情况下（no），不创建此配置文件')
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
            similar_dirs = [dir+os.path.basename(file) for dir in dirs if os.path.exists('/'.join(dir.split('/')[:i]))]
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
    output_dir   = params['output_dir']
    standard_out = params['standard_out']
    extra_out    = params['extra_out']

    project_config = ConfigParser()
    project_config.read(params['project_config'])
    # 获取一个或多个工作路径的名称
    work_dirs = re.split('\s+|\t+|,', project_config.get('html','work_dir'))
    # 对dir格式进行规范，统一改成/aaa/bbb/ccc格式
    work_dirs = ['/'+'/'.join([d for d in dir.split('/') if d]) for dir in work_dirs if dir]

    #获取分组名称
    groups = re.split('\s+|\t+|,', project_config.get('html','group'))
    groups = [os.path.splitext(g)[0] for g in groups if g]

    # 获取project信息
    project_num = project_config.get('project','project_num')
    project_name = project_config.get('project','project_name')

    # 或许组装方法信息
    assembly_method = project_config.get('param','assembly_method')

    # 获取batch最后一次的名称，用来复制最后一次raw data和qc的统计结果
    batch_list = re.split('\s+|\t+|,', project_config.get('html','batch_list'))
    batch_list = [b for b in batch_list if b]
    if len(batch_list) > 1:
        raise Exception('发现多个batch_list文件：%s，请按照时间顺序合并成一个文件并重新配置%s文件！\n' % ('、'.join(batch_list), params['project_config']))

    with open(batch_list[0], 'r') as batch:
        for line in batch:
            tabs = line.strip().split('\t')
            tabs = [t.strip() for t in tabs if t]
            if len(tabs) > 1:
                batch_name = tabs[0]
    print('     final batch name is ： %s' % batch_name)

    # 记录配置文件中的文件夹（00.raw_reads/，01.clean_reads/，02.taxonomy/等），以识别哪些是标准目录以外的文件夹
    standard_dirs = ['material']
    # 匹配report结果文件标准格式，如：RY2015J2703_ABC_2018-10-12，这些文件排除在复制内容之外
    result_dir_rule = re.compile('%s_%s_\w{4}-\w{2}-\w{2}' % (project_num, project_name))
    for dir in work_dirs:
        standard_dirs += [d for d in os.listdir(dir) if result_dir_rule.match(d)]
    # 保存以下为后缀名的文件
    save_suffix = ['pdf', 'png', 'tsv', 'tab', 'csv', 'gz', 'list', 'in', 'xls', 'm8', 'txt', 'profile', 'res', 'length', 'svg']
    with open(config_file, 'r') as conf, open(standard_out, 'w') as new_conf:
        # 在新的配置文件前先输出项目名称和项目编号，可以根据这个得到创建的文件夹的名称。在后续的额外文件夹复制中也可以根据这个来得到删除的符合条件的文件夹
        new_conf.write('# 结果文件的输出路径\n')
        new_conf.write('%s\t%s\n' % ('output_dir', output_dir))
        new_conf.write('# 项目编号\n')
        new_conf.write('%s\t%s\n' % ('project_num', project_num))
        new_conf.write('# 项目名称\n')
        new_conf.write('%s\t%s\n' % ('project_name', project_name))
        new_conf.write('# 保留下面这些后缀名的文件\n')
        new_conf.write('%s\t%s\n' % ('save_suffixes', ', '.join(save_suffix)))
        new_conf.write('# 是否需要复制标准目录以外的的文件夹\n')
        new_conf.write('if_cp_extra_dir\t%s\n\n' % extra_out)

        for line in conf:
            if line.strip().startswith('#') or not line.strip():
                new_conf.write(line)
                continue

            tabs = line.strip().split('\t')

            if len(tabs) == 1:
                print('          正在处理文件夹 ： %s' % tabs[0])
                # 代表是文件夹
                standard_dirs.append(tabs[0].rstrip('/'))
                new_conf.write(line)
            elif len(tabs) > 1:
                if re.search('#@assembly', tabs[1]):
                    tabs[1] = re.sub('#@assembly', assembly_method, tabs[1])

            if len(tabs) == 3 and tabs[0] == 'file':
                '''
                按道理，只能是一个符合要求的文件，若：
                    1、没有文件，则在配置文件给提示，标明可能存在的目录
                    2、多个文件，则在配置文件给提示，复制的时候只保留第一个结果
                '''
                if re.search('#@group', tabs[1]):
                    for group in groups:
                        if_enough = check_if_sample_enough([dir+'/'+os.path.dirname(re.sub('#@group', group, tabs[1])) for dir in work_dirs])
                        if not if_enough:
                            # 样本数量不足则将第一列改为sample_not_enough
                            new_conf.write('sample_not_enough\tsample_not_enpugh.log\t%s\n' % (re.sub('#@group', group, os.path.dirname(tabs[2])+'/')))
                        else:
                            file_dirs, similar_dirs = is_file_exists(work_dirs, re.sub('#@group', group, tabs[1]))
                            if len(file_dirs) == 1 or len(set([os.path.getsize(f) for f in file_dirs])) == 1:
                                new_conf.write('%s\t%s\t%s\n' % (tabs[0], file_dirs[0], re.sub('#@group', group, tabs[2])))
                            else:
                                new_conf.write('\n#################################################################################################################################################\n')
                                if not file_dirs:
                                    new_conf.write('# warning : %s文件不存在，请检查原因并修改下面配置！\n' % re.sub('#@group', group, tabs[1]))
                                    for f in similar_dirs:
                                        new_conf.write('%s\t%s\t%s\n' % (tabs[0], f, re.sub('#@group', group, tabs[2])))
                                elif len(file_dirs) != 1:
                                    new_conf.write('# warning : %s文件有%d个，请检查原因并修改下面配置！（默认选择第一个）\n' % (re.sub('#@group', group, tabs[1]), len(file_dirs)))
                                    for f in file_dirs:
                                        new_conf.write('%s\t%s\t%s\n' % (tabs[0], f, re.sub('#@group', group, tabs[2])))
                                new_conf.write('#################################################################################################################################################\n\n')

                else:
                    if re.search('#@batch', tabs[1]):
                        tabs[1] = re.sub('#@batch', batch_name, tabs[1])

                    if_enough = check_if_sample_enough([dir+'/'+os.path.dirname(tabs[1]) for dir in work_dirs])
                    if not if_enough:
                        # 样本数量不足则将第一列改为sample_not_enough
                        new_conf.write('sample_not_enough\tsample_not_enpugh.log\t%s\n' % os.path.dirname(tabs[2])+'/')
                    else:
                        file_dirs, similar_dirs = is_file_exists(work_dirs, tabs[1])

                        if len(file_dirs) == 1 or len(set([os.path.getsize(f) for f in file_dirs])) == 1:
                            new_conf.write('%s\t%s\t%s\n' % (tabs[0], file_dirs[0], tabs[2]))
                        else:
                            new_conf.write('\n#################################################################################################################################################\n')
                            if not file_dirs:
                                new_conf.write('# warning : %s文件不存在，请检查原因并修改下面配置！\n' % re.sub('#@batch', batch_name, tabs[1]))
                                for f in similar_dirs:
                                    new_conf.write('%s\t%s\t%s\n' % (tabs[0], f, tabs[2]))
                            elif len(file_dirs) != 1:
                                new_conf.write('# warning : %s文件有%d个，请检查原因并修改下面配置！（默认选择第一个）\n' % (re.sub('#@batch', batch_name, tabs[1]), len(file_dirs)))
                                for f in file_dirs:
                                    new_conf.write('%s\t%s\t%s\n' % (tabs[0], f, tabs[2]))
                            new_conf.write('#################################################################################################################################################\n\n')

            elif len(tabs) == 3 and tabs[0] == 'files':
                # 在不存在压缩文件时给出提示
                file_dirs, similar_dirs = is_file_exists(work_dirs, tabs[1])
                if not file_dirs:
                    new_conf.write('\n#################################################################################################################################################\n')
                    new_conf.write('# warning : %s文件不存在，请检查原因并修改下面配置！\n' % tabs[1])
                    for f in similar_dirs:
                        new_conf.write('%s\t%s\t%s\n' % (tabs[0], f, tabs[2]))
                    new_conf.write('#################################################################################################################################################\n\n')
                else:
                    for f in file_dirs:
                        new_conf.write('%s\t%s\t%s\n' % (tabs[0], f, tabs[2]))

            elif len(tabs) == 3 and tabs[0] == 'data':
                # 在不存在压缩文件时给出提示
                file_dirs, similar_dirs = is_file_exists(work_dirs, tabs[1])
                if not file_dirs:
                    new_conf.write('\n#################################################################################################################################################\n')
                    new_conf.write('# warning : %s文件不存在，请检查原因并修改下面配置！\n' % tabs[1])
                    for dir in similar_dirs:
                        new_conf.write('%s\t%s\t%s\n' % (tabs[0], dir, tabs[2]))
                    new_conf.write('#################################################################################################################################################\n\n')
                else:
                    same_files = check_same_file(work_dirs, tabs[1])
                    if same_files:
                        new_conf.write('\n#################################################################################################################################################\n')
                        for file in same_files.keys():
                            new_conf.write('# warning : 存在多个%s文件：%s ！\n' % (file, ', '.join(same_files[file])))
                        for f in file_dirs:
                            new_conf.write('%s\t%s\t%s\n' % (tabs[0], f, tabs[2]))
                        new_conf.write('#################################################################################################################################################\n\n')
                    else:
                        for f in file_dirs:
                            new_conf.write('%s\t%s\t%s\n' % (tabs[0], f, tabs[2]))

            elif len(tabs) == 3 and tabs[0] == 'datas':
                # 在不存在压缩文件时给出提示，这里可以是存在多个一样的文件
                file_dirs, similar_dirs = is_file_exists(work_dirs, tabs[1])
                if not file_dirs:
                    new_conf.write('\n#################################################################################################################################################\n')
                    new_conf.write('# warning : %s文件不存在，请检查原因并修改下面配置！\n' % tabs[1])
                    for dir in similar_dirs:
                        new_conf.write('%s\t%s\t%s\n' % (tabs[0], dir, tabs[2]))
                    new_conf.write('#################################################################################################################################################\n\n')
                else:
                    for dir in file_dirs:
                        new_conf.write('%s\t%s\t%s\n' % (tabs[0], dir, tabs[2]))

            elif len(tabs) == 3 and tabs[0] == 'dir':
                # 文件夹只检查文件夹内有无对应后缀的文件
                if re.search('#@group', tabs[1]):
                    for group in groups:
                        if_enough = check_if_sample_enough([dir+'/'+re.sub('#@group', group, tabs[1]) for dir in work_dirs])
                        if not if_enough:
                            # 样本数量不足则将第一列改为sample_not_enough
                            new_conf.write('sample_not_enough\tsample_not_enpugh.log\t%s\n' % (re.sub('#@group', group, tabs[2])))
                        else:
                            dirs, similar_dirs = check_same_dir([dir+'/'+re.sub('#@group', group, tabs[1]) for dir in work_dirs], save_suffix)
                            if not dirs:
                                # 没有对应路径
                                new_conf.write('\n#################################################################################################################################################\n')
                                new_conf.write('# warning : %s中没找到%s这个分组的内容！请完成分析后修改下面的配置！\n' % (', '.join(work_dirs), group))
                                for dir in similar_dirs:
                                    new_conf.write('%s\t%s\t%s\n' % (tabs[0], dir, re.sub('#@group', group, tabs[2])))
                                new_conf.write('#################################################################################################################################################\n\n')
                            elif len(dirs) == 1:
                                # 有唯一一个路径
                                new_conf.write('%s\t%s\t%s\n' % (tabs[0], dirs[0], re.sub('#@group', group, tabs[2])))
                            else:
                                print('1', dirs)
                                # 有多个不同结果的路径
                                new_conf.write('\n#################################################################################################################################################\n')
                                new_conf.write('# warning : 在多个文件夹%s中找到多个%s分组的内容，并结果不一致！请检查后修改下面的配置！\n' % (', '.join(work_dirs), group))
                                for dir in dirs:
                                    new_conf.write('%s\t%s\t%s\n' % (tabs[0], dir, re.sub('#@group', group, tabs[2])))
                                new_conf.write('#################################################################################################################################################\n\n')

                else:
                    if_enough = check_if_sample_enough([dir+'/'+tabs[1] for dir in work_dirs])
                    if not if_enough:
                        # 样本数量不足则将第一列改为sample_not_enough
                        new_conf.write('sample_not_enough\tsample_not_enpugh.log\t%s\n' % (re.sub('#@group', group, tabs[2])))
                    else:
                        dirs, similar_dirs = check_same_dir([dir+'/'+tabs[1] for dir in work_dirs], save_suffix)

                        if not dirs:
                            # 没有这文件夹或文件夹为空
                            new_conf.write('\n#################################################################################################################################################\n')
                            new_conf.write('# warning : %s中没找到%s文件夹或者该文件夹为空！请完成分析后修改下面的配置！\n' % (', '.join(work_dirs), tabs[1]))
                            for f in similar_dirs:
                                new_conf.write('%s\t%s\t%s\n' % (tabs[0], f, tabs[2]))
                            new_conf.write('#################################################################################################################################################\n\n')
                        elif len(dirs) == 1:
                            # 有唯一一个路径
                            new_conf.write('%s\t%s\t%s\n' % (tabs[0], dirs[0], tabs[2]))
                        else:
                            print('2', dirs)
                            # 有多个不同结果的路径
                            new_conf.write('\n#################################################################################################################################################\n')
                            new_conf.write('# warning : 在多个文件夹%s中找到多个%s文件夹的内容，并结果不一致！请检查后修改下面的配置！\n' % (', '.join(work_dirs), tabs[1]))
                            for dir in dirs:
                                new_conf.write('%s\t%s\t%s\n' % (tabs[0], dir, tabs[2]))
                            new_conf.write('#################################################################################################################################################\n\n')

    print('      新的配置文件已生成 ： %s\n' % standard_out)


    '''
    现有的方案是：配置文件中的文件夹（00.raw_reads/，01.clean_reads/，02.taxonomy/等）保持不变，除了已存在的结果文件夹（认为的结果文件夹的命名规则为projectNum_projectName_XXXX-XX-XX），其余文件夹根据指定的文件后缀进行保留
    注意：若有多个工作目录，无法很好完成：
        1、在多个工作目录下，相同目录结构中一样名称文件的取舍
        2、不知如何修改文件的后缀名，例如：csv修改后缀为xls前还需要把文件内的逗号分隔符改为制表符。所以暂时先不对这块进行改动
    '''
    if not extra_out == 'no':
        result_dir_rule = re.compile('%s_%s_\w{4}-\w{2}-\w{2}' % (project_num, project_name))

        extra_dir_dict = {}
        for dir in work_dirs:
            dir_files = list_all_files(dir, standard_dirs, save_suffix)
            extra_dir_dict[dir] = [file[len(dir):] for file in dir_files]

        extra_files_dict = {}
        for dir in extra_dir_dict.keys():
            for f in extra_dir_dict[dir]:
                # 去除掉以标准结果开头的文件
                if f not in extra_files_dict.keys() and not result_dir_rule.match(f):
                    extra_files_dict[f] = [dir]
                elif f in extra_files_dict.keys():
                    extra_files_dict[f].append(dir)
                else:
                    # 文件名能匹配到标准结果，保留不以标准结果开头的文件
                    if not result_dir_rule.match(f).span()[0] == 0:
                        extra_files_dict[f] = [dir]

        # 计算最大的文件夹深度
        max_depth = 1
        for f in extra_files_dict.keys():
            if f.count('/') > max_depth:
                max_depth = f.count('/')

        # standard_dirs = list(set([f.split('/')[0] for dir in extra_files_dict.keys for f in extra_files_dict[dir] if '/' in f]))


        with open(extra_out, 'w') as extra_conf:
            # 先写一些注释信息
            extra_conf.write('# 这是除配置文件中的文件夹（00.raw_reads/，01.clean_reads/，02.taxonomy/等）还有已存在的结果文件夹之外的文件夹，其余文件夹根据指定的文件后缀进行保留\n')
            extra_conf.write('# 注意：若有多个工作目录，无法很好完成：\n')
            extra_conf.write('#   1、在多个工作目录下，相同目录结构中一样名称文件的取舍\n')
            extra_conf.write('#   2、不知如何修改文件的后缀名，例如：csv修改后缀为xls前还需要把文件内的逗号分隔符改为制表符。所以暂时先不对这块就行改动\n\n\n')

            extra_conf.write('# 结果文件的输出路径\n')
            extra_conf.write('%s\t%s\n' % ('output_dir', output_dir))
            extra_conf.write('# 项目编号\n')
            extra_conf.write('%s\t%s\n' % ('project_num', project_num))
            extra_conf.write('# 项目名称\n')
            extra_conf.write('%s\t%s\n' % ('project_name', project_name))
            extra_conf.write('# 保留下面这些后缀名的文件\n')
            extra_conf.write('%s\t%s\n\n' % ('save_suffixes', ', '.join(save_suffix)))

            # 最外层的作为file，其余的所有都当做是dir
            # 统计最外层的文件
            depth_files = [f for f in extra_files_dict.keys() if f.count('/') == 1]
            for f in depth_files:
                if len(extra_files_dict[f]) == 1:
                    extra_conf.write('file\t%s\t.' % (extra_files_dict[f][0]+'/'+f))
                else:
                    same_file = check_same_file(extra_files_dict[f], f)
                    if same_file:
                        extra_conf.write('\n#################################################################################################################################################\n')
                        extra_conf.write('# warning : %s文件有%d个，请检查原因并修改下面配置！（默认选择第一个）\n' % (f, len(same_file[f])))
                        for dir in same_file[f]:
                            extra_conf.write('file\t%s\t.' % (dir+'/'+f))
                        extra_conf.write('#################################################################################################################################################\n\n')
                    else:
                        extra_conf.write('file\t%s\t.' % (extra_files_dict[f][0]+'/'+f))

            # 统计其他深度的文件夹，统一认为是文件夹
            for i in range(2, max_depth+1):
                depth_dirs = list(set([os.path.dirname(f) for f in extra_files_dict.keys() if f.count('/') == i]))
                for d in depth_dirs:
                    dirs, similar_dirs = check_same_dir([dir+'/'+d for dir in work_dirs], save_suffix)

                    if len(dirs) == 1:
                        # 有唯一一个路径
                        extra_conf.write('dir\t%s\t%s\n' % (dirs[0], d))
                    elif len(dirs) > 1:
                        # 有多个不同结果的路径
                        extra_conf.write('\n#################################################################################################################################################\n')
                        extra_conf.write('# warning : 在多个文件夹%s中找到多个%s的内容，并结果不一致！请检查后修改下面的配置！\n' % (', '.join(dirs), d))
                        for dir in dirs:
                            extra_conf.write('dir\t%s\t%s\n' % (dir, d))
                        extra_conf.write('#################################################################################################################################################\n\n')
                    else:
                        print('肯定是哪里错了！')
        print('额外文件的配置文件已生成 ： %s\n' % extra_out)
