#!/usr/bin/env python
#-*- coding: utf-8 -*-

# Description: utilities
# Copyright (C) 20170621 Ruiyi Corporation
# Email: lixr@realbio.cn

import os, re, sys, time, const, shutil, pandas as pd
from string import Template
from collections import OrderedDict

const.main_dir = '/data_center_01/pipeline/real_metagenome/develop_real_metagenome_v3.0.0/mas/real_metagenome_pipeline/'
#const.main_dir = '%s/../..' % os.path.dirname(os.path.abspath(__file__))
#const.config_default_dir = '%s/config' % const.main_dir
#const.sh_default_dir = '%s/sh' % const.main_dir
const.bin_default_dir = '%s/bin' % const.main_dir
const.tool_default_dir = '%s/tool' % const.main_dir
#const.config_file_suffix = 'config'
#const.shell_file_suffix = 'sh'
const.step_names_order = '00.raw_reads,01.clean_reads,02.taxon,03.assembly,04.gene_predict,05.gene_catalog,06.gene_profile,07.kegg,08.eggnog,09.ardb,10.MGS,11.CAG,12.cazy,html'
const.snakemake = '%s/workflow/rule/Snakefile' % const.main_dir
const.config_yaml = '%s/workflow/rule/config.yaml' % const.main_dir
const.cluster_yaml = '%s/workflow/rule/cluster.yaml' % const.main_dir
const.result_structure = '%s/bin/html/result_structure/result_structure' % const.main_dir
const.html_structure = '%s/bin/html/html_structure/html_structure' % const.main_dir
const.json_structure = '%s/bin/html/json_structure/json_structure' % const.main_dir
const.command_default = "/usr/bin/time --format 'real time: %e ;user time: %U ;system time%S ;%C' "

def read_file(file):
    with open(file, 'r') as inf:
        while True:
            if sys.version[:1] == 3:
                data = inf.__next__()
            else:
                data = inf.next()
            if not data:
                break
            yield data.strip()

def format_number(number):
    re_sub = lambda x:re.sub(r'(\d+?)(?=(\d{3})+$)',r'\1,',re.sub(r'(\d+?)(?=(\d{3})+\.)',r'\1,',x))
    fl_oat = lambda x:'%.2f%%' % (float(x)*100)
    if isinstance(number, list):
        return [re_sub(x) if float(x) > 1.0 else fl_oat(x) for x in map(str,number)]
    elif isinstance(number, str) or isinstance(number, int) or isinstance(number, float):
        return re_sub(str(number)) if float(number) >1.0 else fl_oat(str(number))
    else:
        sys.exit('TypeError: The type of %s is not right!' % number)

def parallel(function, list, threads):
    """ Run function using multiple threads """
    from multiprocessing import Process
    from time import sleep
    processes = []
    for pargs in list: # run function for each set of args in args_list
        p = Process(target=function, kwargs=pargs)
        processes.append(p)
        p.start()
        while len(processes) >= threads: # control number of active processes
            sleep(1)
            indexes = []
            for index, process in enumerate(processes): # keep alive processes
                if process.is_alive(): indexes.append(index)
            processes = [processes[i] for i in indexes]
    while len(processes) > 0: # wait until no active processes
        sleep(1)
        indexes = []
        for index, process in enumerate(processes):
            if process.is_alive(): indexes.append(index)
        processes = [processes[i] for i in indexes]

def mkdir(*path):
    for sub_path in path:
        if not os.path.isdir(sub_path):
            os.system('mkdir -p %s' % sub_path)

def gettime(strings):
    return ("%s:%s s"%(strings,time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(time.time()))))

def cutcol_dataFrame(data,group):
    data = pd.DataFrame.from_csv(data,sep="\t")
    samples = parse_group_file(group).keys()
    data.to_csv()
    return data.loc[:,samples],parse_group_file(group)

def rmdir_my(*path):
    for sub_dir in path:
        if os.path.isdir(sub_dir):
            shutil.rmtree(sub_dir)

def parse_group(group_file):
    sample_set = set()
    group_set = {}
    with open(group_file) as group:
        for line in group:
            sample_name,group_name = line.strip().split('\t')
            if group_name not in group_set:
                group_set[group_name] = set()
            group_set[group_name].add(sample_name)
            sample_set.add(sample_name)
    sample_num_in_groups = map(lambda s: len(s), group_set.itervalues())
    min_sample_num_in_groups = min(sample_num_in_groups)
    sample_num_total = len(sample_set)
    group_num = len(group_set)
    return sample_num_in_groups, min_sample_num_in_groups, sample_num_total, group_num

def get_name(path):
    basename = os.path.basename(path)
    dirname = os.path.split(path)[0]
    filename = os.path.splitext(basename)[0]
    suffix = os.path.splitext(basename)[1]
    return dirname,filename,suffix

def parse_group_file(file):
    if file is None:
        return None
    group = OrderedDict()
    with open(file) as g:
        for line in g:
            tabs = line.strip().split('\t')
            if len(tabs) >= 2:
                group[tabs[0]] = tabs[1]
            else:
                group[tabs[0]] = tabs[0]
    return group

class MyTemplate(Template):
    delimiter = '@#'

class Rparser(object):
    def __init__(self):
        self.template = None
        self.R_script = None
        self.file = None

    def open(self, template):
        fp = open(template)
        template = fp.read()
        fp.close()
        self.template = MyTemplate(template)

    def format(self, var):
        self.R_script = self.template.safe_substitute(var)

    def write(self, outfile):
        fp = open(outfile, 'w')
        fp.write(self.R_script)
        self.file = outfile
        fp.close()

    def run(self):
        os.system('R CMD BATCH --slave %(Rfile)s %(Rfile)sout' % {'Rfile': self.file})

def image_trans(input,output):
    os.system('convert -density 300 %s %s' % (input,output))

def Rrun(Rtxt):
    os.system("R CMD BATCH --slave %s %sout"%(Rtxt,Rtxt))

def share_mothod(tool_default_dir,work_dir,profile,subgroup,subgroup_name,numlist=None,level=None):
    if numlist==None:
        numlist=["01","02","03","04","05","06","07","08"]
    if level==None:
        work_dir_1 = "%s/group/%s/%s.pca/"%(work_dir,subgroup_name,numlist[0])
        work_dir_2 = "%s/group/%s/%s.pcoa/"%(work_dir,subgroup_name,numlist[1])
        work_dir_3 = "%s/group/%s/%s.nmds/"%(work_dir,subgroup_name,numlist[2])
        work_dir_4 = "%s/group/%s/%s.anosim/"%(work_dir,subgroup_name,numlist[3])
        work_dir_5 = "%s/group/%s/%s.mrpp/"%(work_dir,subgroup_name,numlist[4])
        work_dir_6 = "%s/group/%s/%s.heatmap/"%(work_dir,subgroup_name,numlist[5])
        work_dir_7_1 = "%s/group/%s/%s.flower/"%(work_dir,subgroup_name,numlist[6])
        work_dir_7_2 = "%s/group/%s/%s.venn/"%(work_dir,subgroup_name,numlist[6])
        work_dir_8 = "%s/group/%s/%s.wilcoxon_diff/"%(work_dir,subgroup_name,numlist[7])
    else:
        work_dir_1 = "%s/group/%s/%s.pca/%s/"%(work_dir,subgroup_name,numlist[0],level)
        work_dir_2 = "%s/group/%s/%s.pcoa/%s/"%(work_dir,subgroup_name,numlist[1],level)
        work_dir_3 = "%s/group/%s/%s.nmds/%s/"%(work_dir,subgroup_name,numlist[2],level)
        work_dir_4 = "%s/group/%s/%s.anosim/%s/"%(work_dir,subgroup_name,numlist[3],level)
        work_dir_5 = "%s/group/%s/%s.mrpp/%s/"%(work_dir,subgroup_name,numlist[4],level)
        work_dir_6 = "%s/group/%s/%s.heatmap/%s/"%(work_dir,subgroup_name,numlist[5],level)
        work_dir_7_1 = "%s/group/%s/%s.flower/%s/"%(work_dir,subgroup_name,numlist[6],level)
        work_dir_7_2 = "%s/group/%s/%s.venn/%s/"%(work_dir,subgroup_name,numlist[6],level)
        work_dir_8 = "%s/group/%s/%s.wilcoxon_diff/%s/"%(work_dir,subgroup_name,numlist[7],level)
    commands = []
    sample_num_in_groups,min_sample_num_in_groups,sample_num_total,group_num=parse_group(subgroup)
    if sample_num_total>=5:
        mkdir(work_dir_1)
        commands.append("##pca")
        commands.append("python %s/1_pca.py -i %s/%s -g %s -o %s "\
                            %(tool_default_dir,work_dir,profile,subgroup,work_dir_1))
        mkdir(work_dir_2)
        commands.append("##pcoa")
        commands.append("python %s/2_pcoa.py -i %s/%s -g %s -o %s"\
                            %(tool_default_dir,work_dir,profile,subgroup,work_dir_2))
    if min_sample_num_in_groups>=5:
        mkdir(work_dir_3)
        commands.append("##nmds")
        commands.append("python %s/3_nmds.py -i %s/%s -g %s -o %s"\
                            %(tool_default_dir,work_dir,profile,subgroup,work_dir_3))
        mkdir(work_dir_4)
        commands.append("##anosim")
        commands.append("python %s/4_anosim.py -i %s/%s -g %s -o %s"\
                            %(tool_default_dir,work_dir,profile,subgroup,work_dir_4))
        mkdir(work_dir_5)
        commands.append("##mrpp")
        commands.append("python %s/5_mrpp.py -i %s/%s -g %s -o %s"\
                        %(tool_default_dir,work_dir,profile,subgroup,work_dir_5))
    mkdir(work_dir_6)
    commands.append("##heatmap")
    commands.append("python %s/6_heatmap.py -i %s/%s -g %s -o %s"\
                        %(tool_default_dir,work_dir,profile,subgroup,work_dir_5))
    if group_num>=6 and group_num<30:
        mkdir(work_dir_7_1)
        commands.append("##flower")
        commands.append("perl %s/7_flower.pl %s/%s %s %s"\
                        %(tool_default_dir,work_dir,profile,subgroup,work_dir_7_1))
    elif group_num>=2 and group_num<6:
        mkdir(work_dir_7_2)
        commands.append("##venn")
        commands.append("python %s/7_venn_flower.py -i %s/%s -o %s -g %s --with_group "%\
                    (tool_default_dir,work_dir,profile,work_dir_7_2,subgroup))
    if min_sample_num_in_groups>=5:
        mkdir(work_dir_8)
        commands.append("##diff")
        commands.append("python %s/8_diff.py -i %s/%s -g %s -o %s"\
                        %(tool_default_dir,work_dir,profile,subgroup,work_dir_8))
    return commands

def samp_num_enough(dir,log_str = "The minimum sample size is not met."):
    log = open("%s/Sample_not_enough.log" % dir, "w+")
    log.write(log_str)
    log.close

