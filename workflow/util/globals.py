#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2016, The metagenome Project"
__version__ = "1.0.0-dev"

from . import const
const.pipeline_dir = "/data_center_01/pipeline/real_metagenome/real_metagenome_v1.0.0/"
const.config_default_dir = "%s/config/" % const.pipeline_dir
const.sh_default_dir = "%s/sh/" % const.pipeline_dir
const.bin_default_dir = "%s/bin/"%const.pipeline_dir
const.tool_default_dir = "%s/tool/"%const.pipeline_dir

# const.bin_ass_default_dir = "%s/bin/03.assembly/"%const.pipeline_dir
# const.bin_gene_predict_default_dir = "%s/bin/04.gene_predict/"%const.pipeline_dir
# const.bin_gene_catalog_default_dir = "%s/bin/05.gene_catalog/"%const.pipeline_dir
# const.bin_gene_profile_default_dir = "%s/bin/06.gene_profile/"%const.pipeline_dir
# const.bin_kegg_default_dir = "%s/bin/07.kegg/"%const.pipeline_dir




const.config_file_suffix = "config"
const.shell_file_suffix = "sh"
const.step_names_order = "00.raw_reads,01.clean_reads,02.taxon,03.assembly,04.gene_predict,05.gene_catalog,06.gene_profile,07.kegg,08.eggnog,09.ardb,12.cazy,html"
# const.Rscript = "%s/Rscript/"%const.pipeline_dir
# const.PYscript = "%s/pyscript/"%const.pipeline_dir
const.snakemake = "%s/workflow/rule/Snakefile"%const.pipeline_dir
const.config_yaml = "%s/workflow/rule/config.yaml"%const.pipeline_dir
const.cluster_yaml = "%s/workflow/rule/cluster.yaml"%const.pipeline_dir

const.command_default = "/usr/bin/time --format 'real time: %e ;user time: %U ;system time%S ;%C' "

const.result_structure = "%s/bin/html/result_structure"%const.pipeline_dir
const.html_structure = "%s/bin/html/html_structure"%const.pipeline_dir
