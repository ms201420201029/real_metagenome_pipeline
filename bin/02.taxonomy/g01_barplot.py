#!/usr/bin/env python
# -*- coding: utf-8 -*- #

from __future__ import division
import os, sys, argparse
this_script_path = os.path.dirname(__file__)
#sys.path.insert(1, this_script_path + '/../src')
import workflow.util.Parser as rp
from workflow.util.useful import mkdir, image_trans
from workflow.util.Parser import parse_group_file
from workflow.util.ForBarPlot import Subject

def read_params(args):
    parser = argparse.ArgumentParser(description='tax bar plot | v1.0 at 2015/11/06 by liangzb')
    parser.add_argument('-t', '--wf_tax_dir', dest='wf_tax_dir', metavar='DIR', type=str, required=True,
                        help="set the wf_taxa_summary dir produced by summarize_taxa.py")
    parser.add_argument('-g', '--group', dest='group', metavar='FILE', type=str, default=None,
                        help="set the group_file")
    parser.add_argument('-o', '--out_dir', dest='out_dir', metavar='DIR', type=str, required=True,
                        help="set the output dir")
    parser.add_argument('-l', '--level', dest='level_list', metavar='INTs', nargs='+', type=int,
                        default=[2, 3, 4, 5, 6],
                        help="set the tax level, 1..7 stands for kingdom..species, [default is 2 3 4 5 6]")
    parser.add_argument('--with_group', dest='with_group', action='store_true',
                        help="plot group bar plot, if group is not set, this param will not be used")
    parser.add_argument('--without_group', dest="with_group", action='store_false',
                        help="plot sample bar plot, if this params is set, group file will only for order")
    parser.add_argument('--contains_other', dest="contains_other", action='store_true',
                        help="totel abundance contains other abundance ; totel aundance is 1")
    parser.add_argument('--top', dest="top",metavar="INT",type=int,default=20,
                        help='set the top num, [default is 20]')
    parser.set_defaults(with_group=False)
    args = parser.parse_args()
    params = vars(args)
    params['group'] = parse_group_file(params['group'])
    return params

TAX_LEVEL = ['root', 'kingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species','tstrain']

def work(level, params):
    work_dir = '%s/%s' % (params['out_dir'], TAX_LEVEL[level])
    if level==8:
	work_dir = '%s/%s' % (params['out_dir'],"strain")
    if not os.path.isdir(work_dir):
        os.mkdir(work_dir)
    profile = '%s/otu_table_L%d.txt' % (params['wf_tax_dir'], level)
    outfile = '%s/for_plot.txt' % work_dir
    top = params['top']
    subject = Subject(TAX_LEVEL[level], profile, outfile,top)
    if params['contains_other']:
        if params['group'] is not None:
            if params['with_group']:
                subject.run_with_group_contains_other(params['group'])
            else:
                subject.run_contains_other(params['group'])
        else:
            subject.run()
    else:
        if params['group'] is not None:
            if params['with_group']:
                subject.run_with_group(params['group'])
            else:
                subject.run(params['group'])
        else:
            subject.run()


if __name__ == '__main__':
    params = read_params(sys.argv)
    mkdir(params['out_dir'])
    top = params['top']
    outfile_list = []
    for level in params['level_list']:
        outfile_list.append(work(level, params))

    r_job = rp.Rparser()
    r_job.open(this_script_path + '/g01_barplot.R')
    for level in params['level_list']:
        work_dir = '%s/%s' % (params['out_dir'], TAX_LEVEL[level])
	if level==8:
		work_dir = '%s/%s' % (params['out_dir'], "strain")
        infile = '%s/for_plot.txt' % work_dir
        Rscript = '%s/barplot.R' % work_dir
        pdf_file = '%s/barplot.pdf' % work_dir
        png_file = '%s/barplot.png' % work_dir
        vars = {"top":top,
                "infile": infile,
                "pdf_file": pdf_file,
                "title": '%s Level Barplot' % TAX_LEVEL[level].capitalize()}
	if level == 8:
		vars = {"top":top,
                	"infile": infile,
                	"pdf_file": pdf_file,
                	"title": '%s Level Barplot' % "strain".capitalize()}
        r_job.format(vars)
        r_job.write(Rscript)
        r_job.run()
        image_trans(pdf_file, png_file)
