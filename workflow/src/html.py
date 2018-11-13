#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2016, The metagenome Project"
__version__ = "1.0.0-dev"
import os, re
from configparser import ConfigParser
from workflow.util.useful import mkdir, gettime,const
import glob


bin_html_default_dir = "%s/html" % const.bin_default_dir
tool_default_dir = const.tool_default_dir
command_default = const.command_default

def html(config, sh_file, name):
    print gettime("start html")
    commands = []
    work_dir = '%s/' % (os.path.dirname(sh_file))

    if glob.glob(work_dir+'/*'):
        os.system('rm -rf %s/*' % work_dir)

    #获取分组名称
    config_gene = ConfigParser()
    config_gene.read(config)
    groups = re.split("\s+|\t|,\t+|,\s*", config_gene.get("html","group"))
    group_dir = config_gene.get("param","group_dir").strip()

    #准备配置文件
    os.system("mkdir -p %s/result/result/" % work_dir)
    os.system("mkdir -p %s/result/html/" % work_dir)
    os.system("cp -r %s/json_structure/html_material/ %s/result/html/" % (bin_html_default_dir, work_dir))
    os.system("mkdir %s/data/" % work_dir)
    os.system("mkdir %s/result_structure/" % work_dir)
    os.system("mkdir %s/html_structure/" % work_dir)
    os.system("mkdir %s/json_structure/" % work_dir)

    os.system("cp %s %s/result_structure/" % (const.result_structure, work_dir))
    os.system("cp %s %s/html_structure/" % (const.html_structure, work_dir))
    os.system("cp %s %s/json_structure/" % (const.json_structure, work_dir))

    commands.append("/data_center_01/home/mas/python3.6/bin/python3 %s/result_structure/check_result_structure.py -g %s -c %s/result_structure/result_structure -o %s/ -so %s/result_structure/result_structure.new"\
                    % (bin_html_default_dir, config, work_dir, work_dir, work_dir))
    commands.append("# 复制标准结果额外的文件夹\n# /data_center_01/home/mas/python3.6/bin/python3 %s/result_structure/check_result_structure.py -g %s -c %s/result_structure/result_structure -o %s/ -so %s/result_structure/result_structure.new -eo %s/result_structure/result_structure.extra"\
                    % (bin_html_default_dir, config, work_dir, work_dir, work_dir, work_dir))

    commands.append("/data_center_01/home/mas/python3.6/bin/python3 %s/result_structure/cp_result_structure.py -c %s/result_structure/result_structure.new -so %s/result/result/ -do %s/data/"\
                    % (bin_html_default_dir, work_dir, work_dir, work_dir))

    commands.append("/data_center_01/home/mas/python3.6/bin/python3 %s/html_structure/check_html_structure.py -c %s/html_structure/html_structure -p %s -o %s/html_structure/html_config/ -os html_structure -g %s"\
                    % (bin_html_default_dir, work_dir, config, work_dir, group_dir))
    for group in groups:
        commands.append("/data_center_01/home/mas/python3.6/bin/python3 %s/html_structure/cp_html_structure.py -c %s/html_structure/html_config/%s_html_structure -o %s/result/html/html_material/images/%s/"\
                        % (bin_html_default_dir, work_dir, group, work_dir, group))

    commands.append("/data_center_01/home/mas/python3.6/bin/python3 %s/json_structure/00.getJson.py -p %s -c %s/json_structure/json_structure -g %s -o %s/json_structure/json_structure.json -r %s/result/html/html_material/images/"\
                    % (bin_html_default_dir, config, work_dir, group_dir, work_dir, work_dir))
    commands.append("/data_center_01/home/mas/python3.6/bin/python3 %s/json_structure/parse_html.py -j %s/json_structure/json_structure.json -t %s/json_structure/html_templates/ -o %s/result/html/"\
                    % (bin_html_default_dir, work_dir, bin_html_default_dir, work_dir))

    print gettime("end html")
    return commands

