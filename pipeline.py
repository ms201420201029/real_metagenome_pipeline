#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2016-12, The metagenome Project"
__version__ = "1.0.0-dev"

#from future import print_function
import os, re, sys, time, argparse
from workflow.util import configparserself
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
    config_path = params.config_path
    config = configparserself.ConfigParserSelf()
    config.read(config_path)
    option_value = config.read_config()
    work_dir = option_value['work_dir']
    step_names = re.split(',\s*|,\t+|\t|\s+', option_value['step_names_order'])
    step_names_all = step_names_order.split(",")
    steps = []
    for i,name in enumerate(step_names):
        if name in step_names_all:
            print gettime("start create %s step script"%name)
            if name == "html":
                step_dir = "%s/%s_%s_%s/"%(work_dir,option_value['project_num'],\
                                     option_value['project_name'],\
                                     time.strftime("%F"))
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


