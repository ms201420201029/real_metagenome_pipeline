#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2016, The metagenome Project"
__version__ = "1.0.0-dev"

import os, re, time
from configparser import ConfigParser
from workflow.util.useful import mkdir,parse_group,rmdir_my,gettime,const,get_name,samp_num_enough

bin_kegg_default_dir = "%s/07.kegg" % const.bin_default_dir
tool_default_dir = const.tool_default_dir
command_default = const.command_default

def kegg_pre(config, name):
    print gettime("start 07.kegg_pre")
    commands=[]
    work_dir = '%s/%s' % (os.path.dirname(config), name)
    mkdir(work_dir)
    commands.append("## blat mapping")
    commands.append("perl %s/blatprot.pl /data_center_01/home/NEOLINE/zwd/project/PMO/LiuLin-ascites-stool/07.kegg/db.list %s/../05.gene_catalog/gene_catalog.split.list %s/"\
                    %(tool_default_dir,work_dir,work_dir))
    commands.append("nohup /data_center_03/USER/zhongwd/bin/qsge --queue all.q --memery 6G --jobs 10 --prefix KEGG --lines 1 shell/blat.sh &")
    print gettime("end 07.kegg_pre")
    return commands

def kegg(config, name):
    print gettime("start 07.kegg")
    commands = []
    work_dir = '%s/%s' % (os.path.dirname(config), name)
    commands.append("## whole kegg analysis")
    commands.append("rm %s/blat/all.m8"%work_dir)
    commands.append("cat %s/blat/* > %s/blat/all.m8"%(work_dir,work_dir))
    commands.append(command_default + "python %s/701_pick_blast_m8.py -i %s/blat/all.m8 -o %s/kegg.m8"%\
                    (bin_kegg_default_dir,work_dir,work_dir))
    commands.append(command_default + "perl %s/prokaryote.annotation.pl < %s/kegg.m8 > %s/kegg.anno.tsv"%\
                    (bin_kegg_default_dir,work_dir,work_dir))
    commands.append(command_default + "cut -f2 %s/kegg.m8|sort|uniq >%s/sort_uniq_m8.list"%\
                    (work_dir,work_dir))
    commands.append(command_default + "python %s/702_blast2ko_v2.py -i %s/kegg.m8 -o %s/gene_catalog.ko --subjectId %s/sort_uniq_m8.list"%\
                    (bin_kegg_default_dir,work_dir,work_dir,work_dir))
    commands.append(command_default + "perl /data_center_02/Database/KEGG/bin/07_keggMap_nodiff.pl -ko %s/gene_catalog.ko -outdir %s/gene_catalog.map"%\
                    (work_dir,work_dir))
    commands.append(command_default + "perl /data_center_02/Database/KEGG/bin/06_pathfind.pl -fg %s/gene_catalog.ko -output %s/gene_catalog.path -cutoff 0.0"%\
                    (work_dir,work_dir))
    commands.append(command_default + "perl %s/10_KEGG_class.pl %s/gene_catalog.path gene_catalog.path"%\
                    (bin_kegg_default_dir,work_dir))

    # commands.append("## group analysis")
    # commands.append("mkdir 07.kegg/")
    # commands.append("perl core.pl group.list 06.gene_profile/species.profile > 06.gene_profile/core.profile")
    #
    # commands.append("## diff analysis")
    # commands.append("mkdir 07.kegg/diff_gene")
    #

    commands.append("## ko profile")
    commands.append(command_default + "python %s/04_get_profiling_ko.py -i %s/gene_catalog.ko --gene_profile %s/../06.gene_profile/gene.profile -o %s/ko.profile"%\
                    (bin_kegg_default_dir,work_dir,work_dir,work_dir))

    # commands.append("## diff ko")
    #
    # commands.append("## diff module(pathway)")
    #
    commands.append("## 701 kegg功能统计")
    work_dir_701 = "%s/01.kegg_class/"%work_dir
    mkdir(work_dir_701)
    commands.append(command_default + "Rscript %s/701_KEGG_class.R %s/gene_catalog.path.class %s/701_KEGG_class.pdf"\
                    %(bin_kegg_default_dir,work_dir,work_dir_701))
    commands.append("convert -density 300 %s/701_KEGG_class.pdf %s/701_KEGG_class.png"\
                    %(work_dir_701,work_dir_701))

    ##function
    commands.append("## 712.function_barplot")
    work_dir_712 = "%s/12.functional_barplot"%work_dir
    mkdir(work_dir_712)
    commands.append(command_default + "python %s/04_get_profiling_level1.py -i %s/gene_catalog.path -k %s/ko.profile -o %s"\
                    %(bin_kegg_default_dir,work_dir,work_dir,work_dir_712))
    commands.append("Rscript %s/710_level1_barplot.R %s/kegg_level1_profile.txt %s/level1_barplot.pdf 1"\
                    %(bin_kegg_default_dir,work_dir_712,work_dir_712))
    commands.append("convert -density 300 %s/level1_barplot.pdf %s/level1_barplot.png"\
                    %(work_dir_712,work_dir_712))
    commands.append("Rscript %s/710_level1_barplot.R %s/kegg_level2_profile.txt %s/level2_barplot.pdf 2"\
                    %(bin_kegg_default_dir,work_dir_712,work_dir_712))
    commands.append("convert -density 300 %s/level2_barplot.pdf %s/level2_barplot.png"\
                    %(work_dir_712,work_dir_712))

    ##diff
    config_gene = ConfigParser()
    config_gene.read(config)
    group = re.split("\s+|\t|,\s*|,\t+",config_gene.get("param","group"))
    for subgroup_name in group:
        subgroup = '%s/material/%s_group.list' % (os.path.dirname(config), subgroup_name)
        sample_num_in_groups,min_sample_num_in_groups,sample_num_total,group_num=parse_group(subgroup)
        commands.append("## ----------------------------------%s----------------------"%(subgroup_name))
        # heatmap & pca & pcoa
        work_dir_702 = "%s/group/%s/02.heatmap/"%(work_dir,subgroup_name)
        mkdir(work_dir_702)
        work_dir_703 = "%s/group/%s/03.pca/"%(work_dir,subgroup_name)
        mkdir(work_dir_703)
        work_dir_704 = "%s/group/%s/04.pcoa/"%(work_dir,subgroup_name)
        mkdir(work_dir_704)
        if sample_num_total>=5:
            commands.append("##heatmap")
            commands.append(command_default + "python %s/t06_heatmap.py -i %s/ko.profile -g %s -o %s"\
                                %(tool_default_dir,work_dir,subgroup,work_dir_702))
            commands.append("##pca")
            commands.append(command_default + "python %s/t01_pca.py -i %s/ko.profile -g %s -o %s --with_boxplot "\
                                %(tool_default_dir,work_dir,subgroup,work_dir_703))
            commands.append("##pcoa")
            commands.append(command_default + "python %s/t02_pcoa.py -i %s/ko.profile -g %s -o %s"\
                                %(tool_default_dir,work_dir,subgroup,work_dir_704))
        else:
            log = "The minimum sample size (5) is not met."
            samp_num_enough(work_dir_702,log)
            samp_num_enough(work_dir_703,log)
            samp_num_enough(work_dir_704,log)
        # nmds & anosim & adonis & mrpp
        work_dir_705 = "%s/group/%s/05.nmds/"%(work_dir,subgroup_name)
        mkdir(work_dir_705)
        work_dir_706 = "%s/group/%s/06.anosim/"%(work_dir,subgroup_name)
        mkdir(work_dir_706)
        work_dir_706_1 = "%s/group/%s/07.adonis/"%(work_dir,subgroup_name)
        mkdir(work_dir_706_1)
        work_dir_707 = "%s/group/%s/08.mrpp/"%(work_dir,subgroup_name)
        mkdir(work_dir_707)
        if min_sample_num_in_groups>=5:
            commands.append("##nmds")
            commands.append(command_default + "python %s/t03_nmds.py -i %s/ko.profile -g %s -o %s"\
                                %(tool_default_dir,work_dir,subgroup,work_dir_705))
            commands.append("##anosim")
            commands.append(command_default + "python %s/t04_anosim.py -i %s/ko.profile -g %s -o %s"\
                                %(tool_default_dir,work_dir,subgroup,work_dir_706))
            commands.append("##adonis")
            commands.append(command_default + "python %s/t12_adonis_pca.py -i %s/ko.profile -g %s -o %s"\
                                %(tool_default_dir,work_dir,subgroup,work_dir_706_1))
            commands.append(command_default + "python %s/t12_adonis_pcoa.py -i %s/ko.profile -g %s -o %s"\
                                %(tool_default_dir,work_dir,subgroup,work_dir_706_1))
            commands.append("##mrpp")
            commands.append(command_default + "python %s/t05_mrpp.py -i %s/ko.profile -g %s -o %s"\
                            %(tool_default_dir,work_dir,subgroup,work_dir_707))
        else:
            log = "min_sample_num_in_groups >= 5"
            samp_num_enough(work_dir_705,log)
            samp_num_enough(work_dir_706,log)
            samp_num_enough(work_dir_706_1,log)
            samp_num_enough(work_dir_707,log)
        # flower|venn
        if group_num>=6 and group_num<30:
            work_dir_708_1 = "%s/group/%s/09.flower/"%(work_dir,subgroup_name)
            mkdir(work_dir_708_1)
            commands.append("##flower")
            commands.append(command_default + "perl %s/t07_flower.pl %s/ko.profile %s %s"\
                            %(tool_default_dir,work_dir,subgroup,work_dir_708_1))
        elif group_num>=2 and group_num<6:
            work_dir_708_2 = "%s/group/%s/09.venn/"%(work_dir,subgroup_name)
            mkdir(work_dir_708_2)
            commands.append("##venn")
            commands.append(command_default + "python %s/t07_venn_flower.py -i %s/ko.profile -o %s -g %s --with_group "%\
                        (tool_default_dir,work_dir,work_dir_708_2,subgroup))
        # ko_wilcoxon & ko_lefse
        work_dir_709 = "%s/group/%s/10.ko_wilcoxon/"%(work_dir,subgroup_name)
        mkdir(work_dir_709)
        work_dir_710 = "%s/group/%s/11.ko_lefse"%(work_dir,subgroup_name)
        mkdir(work_dir_710)
        if min_sample_num_in_groups>=5:
            # work_dir_709 = "%s/group/%s/09.ko_wilcoxon/"%(work_dir,subgroup_name)
            # mkdir(work_dir_709)
            commands.append("##09.0 diff")
            commands.append(command_default + "python %s/t08_diff.py -i %s/ko.profile -g %s -o %s"\
                            %(tool_default_dir,work_dir,subgroup,work_dir_709))
            commands.append(command_default + "python %s/ko_description.py -i %s/diff.marker.filter.tsv -o %s/diff.marker.filter.definition.tsv --ko_def /data_center_09/Project/lixr/00.DATA/KEGG_DB/ko_description.tab"%(bin_kegg_default_dir,work_dir_709,work_dir_709))
            commands.append("#09.1 diff boxplot")
            commands.append(command_default + "python %s/t09_diff_boxplot.py -i %s/diff.marker.filter.profile.tsv -p %s/diff.marker.filter.tsv -g %s -o %s/diff_boxplot/"\
                        %(tool_default_dir,work_dir_709,work_dir_709,subgroup,work_dir_709))
            commands.append("#09.2 diff heatmap")
            commands.append(command_default + "python %s/t06_heatmap.py -i %s/diff.marker.filter.profile.tsv -g %s -o %s/heatmap/"\
                                %(tool_default_dir,work_dir_709,subgroup,work_dir_709))
            commands.append("#09.3 diff pathway")
            mkdir("%s/pathway/"%work_dir_709)
            commands.append("Rscript %s/707_compare_pathway.R %s/diff.marker.filter.profile.tsv %s %s/pathway/707_compare.txt"\
                            %(bin_kegg_default_dir,work_dir_709,subgroup,work_dir_709))


            commands.append("#09.4 diff detail pathway")
            work_dir_709_2 = "%s/detail_pathway/"%work_dir_709
            mkdir(work_dir_709_2)
            commands.append("python %s/709_diff_map.py -i %s/diff.marker.filter.tsv -ko %s/gene_catalog.ko -g %s -o %s "\
                            %(bin_kegg_default_dir,work_dir_709,work_dir,subgroup,work_dir_709_2))

            commands.append("#09.5 diff barplot")
            #commands.append("cut -f2 %s|uniq|less|while read a ;do grep \"$a\" %s|cut -f1 > %s/$a.list;done" % (subgroup,subgroup,work_dir_709))
            commands.append("cut -f 1 %s/diff.marker.filter.tsv |sed -n '2,$p' |while read line;do grep \"$line\" %s/gene_catalog.path >>%s/diff_gene_catalog.path;done"\
                            %(work_dir_709,work_dir,work_dir_709))
            commands.append("sort %s/diff_gene_catalog.path |uniq > %s/diff_gene_catalog2.path"%(work_dir_709,work_dir_709))
            commands.append("rm %s/diff_gene_catalog.path"%work_dir_709)
            mkdir("%s/path_barplot/"%work_dir_709)
            commands.append("python %s/712_ko2path_bar.py -i %s/diff_gene_catalog2.path -g %s/diff.marker.filter.tsv -o %s/path_barplot/ -l 2"\
                            %(bin_kegg_default_dir,work_dir_709,work_dir_709,work_dir_709))
            ## ko_lefse

            commands.append("## lefse")
            commands.append(command_default + "python %s/../06.gene_profile/603_LEfSe.py -i %s/ko.profile -l /data_center_03/USER/huangy/soft/LEfSe_lzb -g %s -o %s --LDA 2"\
                            %(bin_kegg_default_dir,work_dir,subgroup,work_dir_710))
            commands.append("#lefse heatmap")
            mkdir("%s/heatmap/"%work_dir_710)
            commands.append(command_default + "python %s/t06_heatmap.py -i %s/diff.marker.filter.profile.tsv -g %s -o %s/heatmap/"\
                                %(tool_default_dir,work_dir_710,subgroup,work_dir_710))
            commands.append("#lefse pathway")
            mkdir("%s/pathway/"%work_dir_710)
            commands.append("Rscript %s/707_compare_pathway.R %s/diff.marker.filter.profile.tsv %s %s/pathway/707_compare.txt"\
                            %(bin_kegg_default_dir,work_dir_710,subgroup,work_dir_710))
            commands.append("#lefse barplot")
            commands.append("cut -f 1 %s/diff.marker.filter.tsv |while read line;do grep \"$line\" %s/gene_catalog.path >>%s/diff_gene_catalog.path;done"\
                            %(work_dir_710,work_dir,work_dir_710))
            commands.append("sort %s/diff_gene_catalog.path |uniq > %s/diff_gene_catalog2.path"%(work_dir_710,work_dir_710))
            commands.append("rm %s/diff_gene_catalog.path"%work_dir_710)
            mkdir("%s/path_barplot/"%work_dir_710)
            commands.append("python %s/712_ko2path_bar.py -i %s/diff_gene_catalog2.path -g %s/diff.marker.filter.tsv -o %s/path_barplot/ -l 2"\
                            %(bin_kegg_default_dir,work_dir_710,work_dir_710,work_dir_710))
            
            # lefse detail pathway
            work_dir_710_2 = "%s/detail_pathway/"%work_dir_710
            mkdir(work_dir_710_2)
            if group_num==2:
                commands.append("#lefse detail pathway")
                commands.append("python %s/709_diff_map.py -i %s/diff.marker.filter.tsv -ko %s/gene_catalog.ko -g %s -o %s "\
                                %(bin_kegg_default_dir,work_dir_710,work_dir,subgroup,work_dir_710_2))
            else:
                log = "The number of groups must be 2."
                samp_num_enough(work_dir_710_2,log)
        else:
            log = "min_sample_num_in_groups >= 5"
            samp_num_enough(work_dir_709,log)
            samp_num_enough(work_dir_710,log)

        # ko_metastats
        # if group_num==2 and min_sample_num_in_groups>=5:
            # work_dir_711 = "%s/group/%s/11.ko_metastats/"%(work_dir,subgroup_name)
            # mkdir(work_dir_711)
            # commands.append("##metastats")
            # commands.append("python %s/708_sample2profile.py -i %s/ko.profile -g %s -o %s -f for_metastats.profile --num 1"\
                            # %(bin_kegg_default_dir,work_dir,subgroup,work_dir_711))
            # commands.append(command_default + "Rscript %s/708_metastats.R %s/for_metastats.profile %s %s/ XX 0.05 TRUE"\
                            # %(bin_kegg_default_dir,work_dir_711,subgroup,work_dir_711))
            # commands.append("convert -density 300 %s/708_metastats_boxplot.pdf %s/708_metastats_boxplot.png"\
                            # %(work_dir_711,work_dir_711))
            # commands.append("# diff heatmap")
            # mkdir("%s/heatmap/"%work_dir_711)
            # commands.append(command_default + "python %s/t06_heatmap.py -i %s/diff.marker.filter.profile.tsv -g %s -o %s/heatmap/"\
                                # %(tool_default_dir,work_dir_711,subgroup,work_dir_711))
            # commands.append("#diff pathway")
            # mkdir("%s/pathway/"%work_dir_711)
            # commands.append("Rscript %s/707_compare_pathway.R %s/diff.marker.filter.profile.tsv %s %s/pathway/707_compare.txt"\
                            # %(bin_kegg_default_dir,work_dir_711,subgroup,work_dir_711))
            # commands.append("#diff detail pathway")
            # work_dir_711_2 = "%s/detail_pathway/"%work_dir_711
            # mkdir(work_dir_711_2)
            # commands.append("python %s/709_diff_map.py -i %s/diff.marker.filter.tsv -ko %s/gene_catalog.ko -g %s -o %s "\
                            # %(bin_kegg_default_dir,work_dir_711,work_dir,subgroup,work_dir_711_2))
            # commands.append("# diff barplot")
            # commands.append("cut -f 1 %s/diff.marker.filter.tsv |while read line;do grep \"$line\" %s/gene_catalog.path >>%s/diff_gene_catalog.path;done"\
                            # %(work_dir_711,work_dir,work_dir_711))
            # commands.append("sort %s/diff_gene_catalog.path |uniq > %s/diff_gene_catalog2.path"%(work_dir_711,work_dir_711))
            # commands.append("rm %s/diff_gene_catalog.path"%work_dir_711)
            # mkdir("%s/path_barplot/"%work_dir_711)
            # commands.append("python %s/712_ko2path_bar.py -i %s/diff_gene_catalog2.path -g %s/diff.marker.filter.tsv -o %s/path_barplot/ -l 2"\
                            # %(bin_kegg_default_dir,work_dir_711,work_dir_711,work_dir_711))
        ##function
        work_dir_712_2 = "%s/group/%s/12.functional_barplot"%(work_dir,subgroup_name)
        mkdir(work_dir_712_2)
        commands.append("##712.function_barplot")
        commands.append("Rscript %s/702_level1_barplot_withgroup.R %s/kegg_level1_profile.txt %s/level1_barplot_withgroup.pdf 1 %s"\
                        %(bin_kegg_default_dir,work_dir_712,work_dir_712_2,subgroup))
        commands.append("convert -density 300 %s/level1_barplot_withgroup.pdf %s/level1_barplot_withgroup.png"\
                        %(work_dir_712_2,work_dir_712_2))
        commands.append("Rscript %s/702_level1_barplot_withgroup.R %s/kegg_level2_profile.txt %s/level2_barplot_withgroup.pdf 2 %s"\
                        %(bin_kegg_default_dir,work_dir_712,work_dir_712_2,subgroup))
        commands.append("convert -density 300 %s/level2_barplot_withgroup.pdf %s/level2_barplot_withgroup.png"\
                        %(work_dir_712_2,work_dir_712_2))
        work_dir_713 = "%s/group/%s/13.functional_clust"%(work_dir,subgroup_name)
        mkdir(work_dir_713)
        commands.append("##713 sample cluster")
        commands.append(command_default + "python %s/t10_sample_clustering.py -i %s/kegg_level1_profile.txt -g %s -o %s/ -t \"KEGG Level1 Abundance in Samples\" "\
                            %(tool_default_dir,work_dir_712,subgroup,work_dir_713))
        # roc
        work_dir_714 = "%s/group/%s/14.ROC"%(work_dir,subgroup_name)
        mkdir(work_dir_714)
        commands.append("##714 ROC")
        if sample_num_total >= 50 and min_sample_num_in_groups >=20:
            commands.append("cut -f1 %s/diff.marker.filter.tsv >%s/diff.list;Rscript %s/710_roc.R %s/diff.marker.filter.profile.tsv %s/diff.list %s %s/710_roc.pdf"\
                        %(work_dir_710,work_dir_710,bin_kegg_default_dir,work_dir_710,work_dir_710,subgroup,work_dir_714))
        else:
            log = "sample_num_total >= 50 and min_sample_num_in_groups >=20"
            samp_num_enough(work_dir_714,log)

    print gettime("end kegg")
    return commands

