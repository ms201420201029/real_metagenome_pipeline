#!/usr/bin/env python
#-*- coding: utf-8 -*-

# Description: 
# Copyright (C) 20180329 Ruiyi Corporation
# Email: lixr@realbio.cn

import os,  re,  time
from configparser import ConfigParser
from workflow.util.useful import mkdir, parse_group, get_name, gettime,const,samp_num_enough

cazy_bin_dir = "%s/12.cazy" % const.bin_default_dir
tools_dir = const.tool_default_dir

def cazy_pre(config, name):
    print gettime("start 12.cazy_pre")
    commands=[]
    work_dir = '%s/%s' % (os.path.dirname(config), name)
    mkdir(work_dir)
    commands.append("## blat mapping")
    commands.append("perl %s/blatprot.pl /data_center_09/Project/lixr/00.DATA/CAZY_DB/db.list %s/../05.gene_catalog/gene_catalog.split.list %s"\
                    % (tools_dir,  work_dir,  work_dir))
    commands.append("nohup /data_center_03/USER/zhongwd/bin/qsge --queue all.q --memery 6G --jobs 10 --prefix CAZY --lines 1 shell/blat.sh &")
    print gettime("end 12.cazy_pre")
    return commands

def cazy(config, name):
    print gettime("start 12.cazy")
    commands = []
    work_dir = "%s/%s" % (os.path.dirname(config), name)
    material_dir = "%s/material" % os.path.dirname(config)
    commands.append("## whole cazy analysis")
    commands.append("rm %s/blat/all.m8" % work_dir)
    commands.append("cat %s/blat/* > %s/blat/all.m8" % (work_dir, work_dir))
    commands.append(const.command_default + "python %s/01.get_anno_info.py -i %s/blat/all.m8 -o %s"%(cazy_bin_dir, work_dir, work_dir))
    commands.append(const.command_default + "python %s/02.get_profile_and_count.py -a %s/cazy.anno.tsv -p %s/../06.gene_profile/gene.profile -l 5  -c class -o %s"%\
                    (cazy_bin_dir, work_dir, work_dir, work_dir))
    commands.append(const.command_default +"python %s/02.get_profile_and_count.py -a %s/cazy.anno.tsv -p %s/../06.gene_profile/gene.profile -l 6  -c type -o %s"%\
                    (cazy_bin_dir, work_dir, work_dir, work_dir))
    commands.append(const.command_default + "python %s/02.get_profile_and_count.py -a %s/cazy.anno.tsv -p %s/../06.gene_profile/gene.profile -l 9  -c enzyme -o %s"%\
                    (cazy_bin_dir, work_dir, work_dir, work_dir))
    commands.append("## 1212.function_barplot")
    work_dir_12 = "%s/12.functional_barplot" % work_dir
    mkdir(work_dir_12)
    all_levels=["class","type","enzyme"]
    for level in all_levels:
        commands.append(const.command_default + "Rscript %s/710_level1_barplot.R %s/%s.profile %s/%s_barplot.pdf %s"%(cazy_bin_dir, work_dir, level, work_dir_12, level, level))
        commands.append("convert -density 300 %s/%s_barplot.pdf %s/%s_barplot.png"%(work_dir_12, level, work_dir_12, level))
    config_gene = ConfigParser()
    config_gene.read(config)
    group = re.split("\s+|\t|,", config_gene.get("param", "group"))
    group = list(filter(None, group))
    #all_methods = ['cazy_class', 'cazy_protein', 'cazy_enzyme']
    for subgroup in group:
        subgroup = material_dir + "/" + subgroup + "_group.list"
        dirname, subgroup_name, suffix = get_name(subgroup)
        sample_num_in_groups, min_sample_num_in_groups, sample_num_total, group_num=parse_group(dirname + "/" + subgroup_name + suffix)
        sub_work_dir = "%s/group/%s" % (work_dir,  subgroup_name)
        commands.append("## ----------------------------------%s----------------------------------##"%(subgroup_name))
        # heatmap & pca & pcoa
        work_dir_1202 = "%s/02.heatmap/" % sub_work_dir
        mkdir(work_dir_1202)
        work_dir_1203 = "%s/03.pca/" % sub_work_dir
        mkdir(work_dir_1203)
        work_dir_1204 = "%s/04.pcoa/" % sub_work_dir
        mkdir(work_dir_1204)
        if sample_num_total >= 5:
            commands.append("##heatmap")
            commands.append(const.command_default + "python %s/t06_heatmap.py -i %s/type.profile -g %s -o %s" %(tools_dir, work_dir, subgroup, work_dir_1202))
            commands.append("##pca")
            commands.append(const.command_default + "python %s/t01_pca.py -i %s/type.profile -g %s -o %s" %(tools_dir, work_dir, subgroup, work_dir_1203))

            commands.append("##pcoa")
            commands.append(const.command_default + "python %s/t02_pcoa.py -i %s/type.profile -g %s -o %s"%(tools_dir, work_dir, subgroup, work_dir_1204))
        else:
            log = "The minimum sample size (5) is not met."
            samp_num_enough(work_dir_1202,log)
            samp_num_enough(work_dir_1203,log)
            samp_num_enough(work_dir_1204,log)
        
        # nmds & anosim & adonis
        work_dir_1205 = "%s/05.nmds/" % sub_work_dir
        mkdir(work_dir_1205)
        work_dir_1206 = "%s/06.anosim/" % sub_work_dir
        mkdir(work_dir_1206)
        work_dir_1206_1 = "%s/07.adonis/"% sub_work_dir
        mkdir(work_dir_1206_1)
        work_dir_1207 = "%s/08.mrpp/" % sub_work_dir
        mkdir(work_dir_1207)
        if min_sample_num_in_groups >= 5:
            commands.append("##nmds")
            commands.append(const.command_default + "python %s/t03_nmds.py -i %s/type.profile -g %s -o %s" % (tools_dir, work_dir, subgroup, work_dir_1205))
            commands.append("##anosim")
            commands.append(const.command_default + "python %s/t04_anosim.py -i %s/type.profile -g %s -o %s"% (tools_dir, work_dir, subgroup, work_dir_1206))
            commands.append("##adonis")
            commands.append(const.command_default + "python %s/t12_adonis_pca.py -i %s/type.profile -g %s -o %s" % (tools_dir,work_dir,subgroup,work_dir_1206_1))
            commands.append("##mrpp")
            commands.append(const.command_default + "python %s/t05_mrpp.py -i %s/type.profile -g %s -o %s" % (tools_dir, work_dir, subgroup, work_dir_1207))
        else:
            log = "min_sample_num_in_groups >= 5"
            samp_num_enough(work_dir_1205,log)
            samp_num_enough(work_dir_1206,log)
            samp_num_enough(work_dir_1206_1,log)
            samp_num_enough(work_dir_1207,log)       

        if group_num >= 6 and group_num < 30:
            work_dir_1208 = "%s/09.flower/" % sub_work_dir
            mkdir(work_dir_1208)
            commands.append("##flower")
            commands.append(const.command_default + "perl %s/t07_flower.pl %s/type.profile %s %s"%(tools_dir, work_dir, subgroup, work_dir_1208))
        elif group_num >= 2 and group_num < 6:
            work_dir_1208 = "%s/09.venn/" % sub_work_dir
            mkdir(work_dir_1208)
            commands.append("##venn")
            commands.append(const.command_default + "python %s/t07_venn_flower.py -i %s/type.profile -o %s -g %s --with_group"%(tools_dir, work_dir, work_dir_1208, subgroup))

        # ko_wilcoxon & lefse
        work_dir_1209 = "%s/10.ko_wilcoxon/" % sub_work_dir
        mkdir(work_dir_1209)        
        work_dir_1210 = "%s/11.lefse/" % sub_work_dir
        mkdir(work_dir_1210)
        
        if min_sample_num_in_groups >= 5:
            commands.append("##diff")
            commands.append(const.command_default + "%s/t08_diff.py -i %s/type.profile -g %s -o %s"%(tools_dir, work_dir, subgroup, work_dir_1209))
            commands.append("# diff boxplot")
            commands.append(const.command_default + "python %s/t09_diff_boxplot.py -i %s/diff.marker.filter.profile.tsv -p %s/diff.marker.filter.tsv -g %s -o %s/diff_boxplot/"\
                        %(tools_dir, work_dir_1209, work_dir_1209, subgroup, work_dir_1209))
            commands.append("# diff heatmap")
            commands.append(const.command_default + "python %s/t06_heatmap.py -i %s/diff.marker.filter.profile.tsv -g %s -o %s/heatmap/"\
                        %(tools_dir, work_dir_1209, subgroup, work_dir_1209))
            # lefse
            commands.append("## lefse")
            commands.append(const.command_default + "python %s/../06.gene_profile/603_LEfSe.py -i %s/type.profile -l /data_center_03/USER/huangy/soft/LEfSe_lzb -g %s -o %s --LDA 2"\
                            %(cazy_bin_dir, work_dir, subgroup, work_dir_1210))
            commands.append("#lefse heatmap")
            commands.append(const.command_default + "python %s/t06_heatmap.py -i %s/diff.marker.filter.profile.tsv -g %s -o %s/heatmap/"\
                        %(tools_dir, work_dir_1210, subgroup, work_dir_1210))
        
        else:
            log = "min_sample_num_in_groups >= 5"
            samp_num_enough(work_dir_1209,log)
            samp_num_enough(work_dir_1210,log)

        #if group_num == 2 and min_sample_num_in_groups >= 5:
            #work_dir_1211 = "%s/11.metastats/" % sub_work_dir
            #mkdir(work_dir_1211)
            #commands.append("##metastats")
            #commands.append(const.command_default + "python %s/708_sample2profile.py -i %s/type.profile -g %s -o %s -f for_metastats.profile --num 100000"\
            #            %(cazy_bin_dir, work_dir, subgroup, sub_work_dir))
            #commands.append(const.command_default + "Rscript %s/708_metastats.R %s/for_metastats.profile %s %s XX 0.05 TRUE"\
            #            %(cazy_bin_dir, work_dir, subgroup, work_dir_1211))
            #commands.append("convert -density 300 %s/708_metastats_boxplot.pdf %s/708_metastats_boxplot.png"%(work_dir_1211,work_dir_1211))
            #commands.append("# diff heatmap")
            #commands.append(const.command_default + "python %s/6_heatmap.py -i %s/diff.marker.filter.profile.tsv -g %s -o %s/heatmap/"\
            #            %(tools_dir, work_dir_1211, subgroup, work_dir_1211))
            #work_dir_1212 = "%s/12.functional_barplot/" % sub_work_dir
            #mkdir(work_dir_1212)
            #commands.append("##711.function_barplot")
            #commands.append(const.command_default + "Rscript %s/702_level1_barplot_withgroup.R %s/class.profile %s/calss_barplot_withgroup.pdf class %s"\
            #            %(cazy_bin_dir, work_dir, work_dir_1211, subgroup))
            #commands.append("convert -density 300 %s/calss_barplot_withgroup.pdf %s/calss_barplot_withgroup.png"%(work_dir_1211, work_dir_1211))
            #commands.append(const.command_default + "Rscript %s/702_level1_barplot_withgroup.R %s/type.profile %s/type_barplot_withgroup.pdf type %s"\
            #            %(cazy_bin_dir, work_dir, work_dir_1211, subgroup))
            #commands.append("convert -density 300 %s/type_barplot_withgroup.pdf %s/type_barplot_withgroup.png"%(work_dir_1211, work_dir_1211))
            #commands.append(const.command_default + "Rscript %s/702_level1_barplot_withgroup.R %s/enzyme.profile %s/enzyme_barplot_withgroup.pdf enzyme %s"\
            #            %(cazy_bin_dir, work_dir, work_dir_1211, subgroup))
            #commands.append("convert -density 300 %s/enzyme_barplot_withgroup.pdf %s/enzyme_barplot_withgroup.png"%(work_dir_1211, work_dir_1211))
        work_dir_1213 = "%s/12.functional_clust/" % sub_work_dir
        mkdir(work_dir_1213)
        commands.append("##712 sample cluster")
        commands.append(const.command_default + "python %s/t10_sample_clustering.py -i %s/type.profile -g %s -o %s -t \"Type Abundance in Samples\""\
                        %(tools_dir, work_dir, subgroup, work_dir_1213))

    print gettime("end cazy")
    return commands

