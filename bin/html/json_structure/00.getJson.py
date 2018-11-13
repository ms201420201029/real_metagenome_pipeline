#!/usr/bin/python3
#-*- coding : utf-8 -*-
##########################################################
#
#       Filename: 00.getJson.py
#         Author: mas@realbio.cn
#    Description: 将结果文件转化成json文件，以便后续渲染
#  Last Modified: 2018-10-31 11:26:30
#
#                 Copyright (C) 20181031 Ruiyi Corporation
##########################################################

import argparse
import os
import random
import math
import pandas as pd
import numpy as np
from configparser import ConfigParser
import regex as re
import glob
import json


def read_params():
    parser = argparse.ArgumentParser()
    parser.add_argument('-p', '--project_config', metavar='project_config', dest='project_config', required=True, type=str,
                        help='项目流程的配置文件，从中获取分组信息，项目相关的信息')
    parser.add_argument('-c', '--html_config', metavar='html_config', dest='html_config', required=True, type=str,
                        help='html的配置文件')
    parser.add_argument('-g', '--group_path', dest='group_path', metavar='dir', type=str, required=True,
                        help='分组文件所在文件夹')
    parser.add_argument('-r', '--html_result_dir', dest='html_result_dir', metavar='html_result_dir', type=str, required=True,
                        help='html结果文件文件夹')
    parser.add_argument('-o', '--output_json', metavar='output_json', dest='output_json', required=True, type=str,
                        help='输出json文件')
    args = parser.parse_args()
    params = vars(args)
    return params


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


def check_if_sample_enough(dirs):
    '''
    通过这层或者下一层是否存在样品不足的日志文件来判断此分析是否是样品不足
    足返回True，不足返回False
    '''
    for dir in dirs:
        if glob.glob(dir+'/sample_not_enough.log') or glob.glob(dir+'/*/sample_not_enough.log'):
            return False
    return True


def change_type(l):
    '''
    因为int64和float64格式的无法用json转化
    '''
    for i in range(len(l)):
        if type(l[i]) == np.int64:
            l[i] = int(l[i])
        elif type(l[i]) == np.float64:
            l[i] = float(l[i])

        if isinstance(l[i], float):
            if math.isnan(l[i]):
                l[i] = ''
            elif l[i] == 0:
                l[i] = 0
            elif l[i] >= 0.01 or l[i] <= -0.01:
                l[i] = ('%.2f' % l[i])
            elif l[i] < 0.01 or l[i] > -0.01:
                l[i] = ('%.2e' % l[i])
    return l


if __name__ == '__main__':
    params = read_params()
    h_config         = params['html_config']
    output           = params['output_json']
    group_path       = params['group_path']
    html_result_path = params['html_result_dir']

    project_config = ConfigParser()
    project_config.read(params['project_config'])

    # 获取一个或多个工作路径的名称
    work_dirs = re.split('\s+|\t+|,', project_config.get('html','work_dir'))
    # 对dir格式进行规范，统一改成/aaa/bbb/ccc格式
    work_dirs = ['/'+'/'.join([d for d in dir.split('/') if d]) for dir in work_dirs if dir]

    # 获取分组名称
    groups = re.split('\s+|\t+|,', project_config.get('html','group'))
    groups = [os.path.splitext(g)[0] for g in groups if g]  # 需要确定是写分组名称还是文件，这里是写分组名称
    check_groups_exists(group_path, groups)

    # html的字典，最后输出到json文件
    html_dict = {}
    html_dict['groups'] = groups
    # 将项目信息增加到dict中
    html_dict['project'] = {}
    # 客户信息
    html_dict['project']['customer_name'] = project_config.get('project', 'customer_name')
    # 项目相关信息
    html_dict['project']['project_name'] = project_config.get('project', 'project_name')
    html_dict['project']['project_number'] = project_config.get('project', 'project_num')
    html_dict['project']['sample_source'] = project_config.get('project', 'sample_source')
    html_dict['project']['sample_type'] = project_config.get('project', 'sample_type')
    html_dict['project']['note_information'] = project_config.get('project', 'note_information')
    # 客户信息
    html_dict['project']['project_contacts'] = project_config.get('project', 'project_contacts')
    html_dict['project']['phone'] = project_config.get('project', 'phone')
    html_dict['project']['email'] = project_config.get('project', 'email')
    html_dict['project']['enterprise_name'] = project_config.get('project', 'enterprise_name')
    html_dict['project']['enterprise_address'] = project_config.get('project', 'enterprise_address')
    # 销售信息
    html_dict['project']['salesman'] = project_config.get('project', 'salesman')
    html_dict['project']['sale_phone'] = project_config.get('project', 'sale_phone')
    html_dict['project']['sale_email'] = project_config.get('project', 'sale_email')

    for group in groups:
        html_dict[group] = {}

        # 从group文件获取samples信息，取三个样本名称，若不到三个，则选择全部
        group_info = pd.read_csv(group_path+'/'+group+'_group.list', index_col=0, header=None, sep='\t')
        html_dict[group]['samples'] = list(group_info.index)[:3] if group_info.shape[0] > 2 else list(group_info.index)

        html_dict[group]['1.project_info.html'] = html_dict['project']

        # html中文件及图片信息
        with open(h_config, 'r') as h_conf:
            for line in h_conf:
                if line.strip().startswith('#') or not line.strip():
                    continue

                tabs = line.strip().split('\t')

                if len(tabs) == 1:
                    key = tabs[0]
                    html_dict[group][key] = {}

                # elif not check_if_sample_enough([html_result_path+'/'+group+'/'+os.path.dirname(tabs[2])]):
                elif not check_if_sample_enough(['result/html/html_material/images/'+group+'/'+os.path.dirname(tabs[2])]):
                    print(tabs[2], 'sample_not_enough')
                    html_dict[group][key]['sample_not_enough'] = True

                elif tabs[0] == 'fig':
                    if '#@group' in tabs[1]:
                        tabs[1] = re.sub('#@group', group, tabs[1])

                    html_dict[group][key]['path'] = tabs[1]
                    html_dict[group][key]['path_real'] = '../result/result/'+tabs[1]
                    html_dict[group][key][tabs[3]] = 'result/html/html_material/images/'+group+'/'+tabs[2]

                elif tabs[0] == 'figs':
                    if '#@group' in tabs[1]:
                        tabs[1] = re.sub('#@group', group, tabs[1])

                    html_dict[group][key]['path'] = tabs[1]
                    html_dict[group][key]['path_real'] = '../result/result/'+tabs[1]
                    html_dict[group][key]['figs'] = sorted(['result/html/html_material/images/'+group+'/'+os.path.dirname(tabs[2])+'/'+os.path.basename(fig) for fig in glob.glob('result/html/html_material/images/'+group+'/'+tabs[2])])

                elif tabs[0] == 'table_sample':
                    # 涉及到sample的表格，需要对表格中的样品进行统一
                    if '#@group' in tabs[1]:
                        tabs[1] = re.sub('#@group', group, tabs[1])

                    html_dict[group][key]['samples'] = html_dict[group]['samples']

                    html_dict[group][key]['path_table_sample'] = tabs[1]
                    html_dict[group][key]['path_table_sample_real'] = '../result/result/'+tabs[1]
                    fields = [field.strip() for field in tabs[4].strip().split(',')]
                    table_sample = pd.read_csv('result/html/html_material/images/'+group+'/'+tabs[2], index_col=0, header=0, sep='\t')[fields].loc[html_dict[group]['samples']]

                    html_dict[group][key]['table_sample'] = []
                    for sample in table_sample.index:
                        html_dict[group][key]['table_sample'].append(change_type([sample] + list(table_sample.loc[sample])))

                elif tabs[0] == 'table':
                    # 不涉及到sample的就取前三行内容
                    if '#@group' in tabs[1]:
                        tabs[1] = re.sub('#@group', group, tabs[1])

                    html_dict[group][key]['path_table'] = tabs[1]
                    html_dict[group][key]['path_table_real'] = '../result/result/'+tabs[1]
                    fields = [field.strip() for field in tabs[4].strip().split(',')]
                    # print('images/'+group+'/'+tabs[2])
                    table = pd.read_csv('result/html/html_material/images/'+group+'/'+tabs[2], index_col=None, header=0, sep='\t')[fields]

                    html_dict[group][key]['table'] = []
                    for i in list(table.index)[:3 if table.shape[0] > 2 else table.shape[0]]:
                        html_dict[group][key]['table'].append(change_type(list(table.loc[i])))

                elif tabs[0] == 'otu':
                    # 这个跟table_sample区别就是这个样本是列名
                    if '#@group' in tabs[1]:
                        tabs[1] = re.sub('#@group', group, tabs[1])

                    html_dict[group][key]['samples'] = html_dict[group]['samples']

                    html_dict[group][key]['path_otu'] = tabs[1]
                    html_dict[group][key]['path_otu_real'] = '../result/result/'+tabs[1]

                    otu = pd.read_csv('result/html/html_material/images/'+group+'/'+tabs[2], index_col=None, header=0, sep='\t')
                    otu = otu[[otu.keys()[0]]+html_dict[group]['samples']]

                    html_dict[group][key]['otu'] = []
                    for i in list(otu.index)[:3 if otu.shape[0] > 2 else otu.shape[0]]:
                        html_dict[group][key]['otu'].append(change_type(list(otu.loc[i])))

                else:
                    print('Nothing to do with : ', line)

    html_str = json.dumps(html_dict, indent=4)
    with open(output, 'w') as out:
        out.write(html_str)

