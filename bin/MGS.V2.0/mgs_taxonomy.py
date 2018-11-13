#!/usr/bin/env python
# -*- coding: utf-8 -*- #
import sys
import argparse
from jinja2 import Environment, FileSystemLoader
from workflow.util.useful import mkdir, image_trans, Rrun
from workflow.util.useful import const


def read_params(args):
    parser = argparse.ArgumentParser(description='''pca analysis | v1.0 at 2017/1/23 by huangy ''')
    parser.add_argument('-i', '--mgs', dest='mgs', metavar='FILE', type=str, required=True,
                        help="set the mgs file")
    parser.add_argument('-g', '--gene_catalog', dest='gene_catalog', metavar='FILE', type=str, required=True,
                        help="set the gene_catalog.fa file")
    parser.add_argument('--group', dest='group', metavar='FILE', type=str, required=True,
                        help="set the group file")
    parser.add_argument('-o', '--out_dir', dest='out_dir', metavar='DIR', type=str, required=True,
                        help="set the output dir")
    args = parser.parse_args()
    params = vars(args)
    return params


if __name__ == '__main__':
    reload(sys)
    sys.setdefaultencoding('utf8')
    params = read_params(sys.argv)
    bin_default_dir = const.bin_default_dir
    mkdir(params['out_dir'])
    gene_catalog = params["gene_catalog"]
    mgs=params["mgs"]
    groupfile = params["group"]
    out_dir = params['out_dir']
    with open("%s/mgs_taxonomy.sh"%out_dir,"w") as fqout:
        fqout.write("ls ../pathway/second_groups_*.profile | while read a; do b=${a##*_};\
perl /data_center_01/pipeline/real_metagenome/real_metagenome_v1.0.0/bin//MGS.V2.0/Rscript/tax/add.pl $a ${b%.*} >${b%.*}_group.list;\
perl /data_center_03/USER/zhongwd/rd/Finish/08_tax_anno/work01.pl <$a >${b%.*}_all.gene.list;\
/data_center_03/USER/zhongwd/bin/list2fasta ${b%.*}_all.gene.list /data_center_02/Database/GENESET/LC/GENESET/merged_gene_set.fna >${b%.*}_all.gene.fna;\
perl /home/huangy/lib/bin/list ${b%.*}_all.gene.fna >${b%.*}_sq.list; done\n")

        fqout.write("ls ../pathway/second_groups_*.profile | while read a; do b=${a##*_};\
perl /home/huangy/bin/blatnucl /data_center_03/USER/zhongwd/CFG/strain.list ${b%.*}_sq.list;\
/data_center_03/USER/zhongwd/bin/qsge --queue new.q --memery 8G --jobs 13 --prefix ${b%.*} --lines 1 shell_blat/blat.sh;done\n")
        fqout.write('''ls blat/*_all.gene.fna-HMP_Contig.fna |while read a; do b=${a%%_*};\
cat ${b}_* >${b}_all.psl; blatfilter ${b}_all.psl >${b#*/}_all.filter.psl;\
cut -f10 ${b#*/}_all.filter.psl >${b#*/}_gene.list;\
cut -f14 ${b#*/}_all.filter.psl >${b#*/}_gi.list;\
search ${b#*/}_gi.list /data_center_01/DNA_Data/data1/Database/Reference/GENOME.TAX >${b#*/}_gi.tax;\
paste ${b#*/}_gene.list ${b#*/}_gi.tax >${b#*/}_gene.tax;\
perl /data_center_03/USER/zhongwd/rd/Finish/08_tax_anno/work02.pl ${b#*/}_group.list ${b#*/}_gene.tax >${b#*/}_group.tax.tsv;\
awk '{if(NF>2)print $0}' ${b#*/}_group.tax.tsv >${b#*/}_final.tsv; done\n''')
        fqout.write("cat *_group.tax.tsv |sort -rn -k5 > final.stat.tsv")

