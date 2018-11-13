#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2016-12, The metagenome Project"
__version__ = "1.0.0-dev"

#from future import print_function
import os, re, sys, time, argparse
import ConfigParser
#from workflow.util import error
#from workflow.node import Node
from workflow.control import touch_sh_file
from workflow.util.useful import gettime, mkdir, const

def read_params(args):
    parsers = argparse.ArgumentParser(description='''The initial run script of metagene ''')
    parsers.add_argument('--config', dest='config_path', metavar='FILE', type=str, required=True,
                        help="config file for metagenome pipeline")
    args = parsers.parse_args()
    return args

if __name__ == '__main__':
    print gettime("start")
    step_names_order = const.step_names_order
    params = read_params(sys.argv)
    config_path = params.config_path    # 配置文件名称
    # print config_path
    config = ConfigParser.ConfigParser()  # 增加修改配置文件的类
    config.read(config_path)    # 读取配置文件
    # option_value = config.read_config()  # 将配置文件的内容添加字典中
    work_dir = config.get('param', 'work_dir')
    step_names = re.split(',\s*|,\t+|\t|\s+', config.get('step', 'step_names_order'))
    step_names_all = step_names_order.split(",")
    steps = []
    for i,name in enumerate(step_names):
        if name in step_names_all:
            print gettime("start create %s step script"%name)
            if name == "html":
                step_dir = "%s/%s_%s_%s/"%(config.get('html', 'result_dir'), config.get('project', 'project_num'),\
                                     config.get('project', 'project_name'),\
                                     time.strftime("%F"))
                sh_file = '%s/%s.sh' % (step_dir, name)
            else:
                step_dir = "%s/%s/" % (work_dir,name)
                sh_file = '%s/%s.sh' % (step_dir, name)
            mkdir(step_dir)
            config_file = os.path.abspath(config_path)
            touch_sh_file(config_file, sh_file, name)
        else:
            print "no have %s step" % name
            raise IOError
    print gettime("end")

