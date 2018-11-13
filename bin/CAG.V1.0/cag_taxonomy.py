#!/usr/bin/env python
# -*- coding: utf-8 -*- #
import sys
import argparse
from jinja2 import Environment, FileSystemLoader
from workflow.util.useful import mkdir, image_trans, Rrun
from workflow.util.useful import const
import os

def read_params(args):
    parser = argparse.ArgumentParser(description='''pca analysis | v1.0 at 2017/1/23 by huangy ''')
    parser.add_argument('-i', '--cag', dest='cag', metavar='FILE', type=str, required=True,
                        help="set the cag file")
    parser.add_argument('-g', '--gene_catalog', dest='gene_catalog', metavar='FILE', type=str, required=True,
                        help="set the gene_catalog.fa file")
    parser.add_argument('-o', '--out_dir', dest='out_dir', metavar='DIR', type=str, required=True,
                        help="set the output dir")
    args = parser.parse_args()
    params = vars(args)
    return params


if __name__ == '__main__':
    reload(sys)
    sys.setdefaultencoding('utf8')
    params = read_params(sys.argv)
    tool_default_dir = const.tool_default_dir
    mkdir(params['out_dir'])
    gene_catalog = params["gene_catalog"]
    cag=params["cag"]
    out_dir = params['out_dir']
    with open("%s/cag_taxonomy.sh"%out_dir,"w") as fqout:
        fqout.write("perl /data_center_03/USER/zhongwd/rd/Finish/08_tax_anno/work01.pl < %s > %s/all.gene.list\n"\
                    %(cag,out_dir))
        fqout.write("/data_center_03/USER/zhongwd/bin/list2fasta %s/all.gene.list %s > %s/all.gene.fna\n"\
                    %(out_dir,gene_catalog,out_dir))
        fqout.write("perl /home/huangy/lib/bin/list %s/all.gene.fna > %s/sq.list\n"%(out_dir,out_dir))
        fqout.write("perl /home/huangy/bin/blatnucl /data_center_03/USER/zhongwd/CFG/strain.list %s/sq.list\n"\
                    %(out_dir))
        fqout.write("perl /home/huangy/lib/bin/qsge --queue all.q --memery 10G --jobs 13 --prefix cag_tax --lines 1 %s/shell_blat/blat.sh\n"%out_dir)
        fqout.write("cat blat/* > all.psl\n")
        fqout.write("/data_center_03/USER/zhongwd/bin/blatfilter all.psl > all.filter.psl\n")
        fqout.write("cut -f 10 all.filter.psl > gene.list\n")
        fqout.write("cut -f 14 all.filter.psl > gi.list\n")
        fqout.write("/data_center_03/USER/zhongwd/bin/search gi.list /data_center_01/DNA_Data/data1/Database/Reference/GENOME.TAX > gi.tax\n")
        fqout.write("paste gene.list gi.tax > gene.tax\n")
        fqout.write("perl /data_center_03/USER/zhongwd/rd/Finish/08_tax_anno/work02.pl %s gene.tax > group.tax.tsv\n"%(cag))
        fqout.write("perl /home/liulf/real_metagenome_test/bin/CAG.V1.0/taxonomy_stat.pl group.tax.tsv > ../outfile/taxonomy_stat.tsv\n")

