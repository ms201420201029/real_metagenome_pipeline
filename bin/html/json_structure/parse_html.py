#!/usr/bin/python3
#-*- coding : utf-8 -*-
##########################################################
#
#       Filename: parse_html.py
#         Author: mas@realbio.cn
#    Description: 读取保存的json文件并渲染到templates中
#  Last Modified: 2018-11-02 09:15:29
#
#                 Copyright (C) 20181102 Ruiyi Corporation
##########################################################

import argparse
import datetime
import json
from jinja2 import Environment, FileSystemLoader


def read_params():
    parser = argparse.ArgumentParser()
    parser.add_argument('-j', '--json_file', metavar='json_file', dest='json_file', required=True, type=str,
                        help='输入json文件')
    parser.add_argument('-t', '--templates_dir', metavar='templates_dir', dest='templates_dir', required=True, type=str,
                        help='templates所在的目录')
    parser.add_argument('-o', '--output_dir', metavar='output_dir', dest='output_dir', required=True, type=str,
                        help='输出html的路径')
    args = parser.parse_args()
    params = vars(args)
    return params


if __name__ == '__main__':
    params = read_params()
    json_file = params['json_file']
    temp_dir  = params['templates_dir']
    out_dir   = params['output_dir']

    # 读取json文件
    with open(json_file, 'r') as jf:
        html_dict = json.load(jf)

    # 加入时间
    html_dict['time'] = datetime.datetime.now().strftime('%Y年%m月%d日')

    # 模板所在目录作为模板搜索路径
    env = Environment(loader=FileSystemLoader(temp_dir))

    parse_order = ['navigator.html',
                   '1.project_info.html',
                   '2.1.laboratory_pipeline.html',
                   '2.2.analysis_pipeline.html',
                   '2.3.analysis_content.html',
                   '3.1.1.rawreads_statistic.html',
                   '3.1.2.qc_data_statistic.html',
                   '3.2.1.align_statictic.html',
                   '3.2.2.taxon_pieplot.html',
                   '3.2.3.axon_barplot.html',
                   '3.2.4.taxon_venn_flower.html',
                   '3.2.5.taxon_accum_share.html',
                   '3.2.6.taxon_top_boxplot.html',
                   '3.2.7.taxon_ternaryplot.html',
                   '3.2.8.taxon_treeplot.html',
                   '3.2.9.taxon_top_barplot.html',
                   '3.2.10.taxon_pca.html',
                   '3.2.11.taxon_pcoa.html',
                   '3.2.12.taxon_nmds.html',
                   '3.2.13.taxon_anosim.html',
                   '3.2.14.taxon_adonis.html',
                   '3.2.15.taxon_mrpp.html',
                   '3.2.16.taxon_wilcox.html',
                   '3.2.17.taxon_lefse.html',
                   '3.3.1.assembly.html',
                   '3.3.2.gene_predict.html',
                   '3.3.3.gene_catalog.html',
                   '3.3.4.gene_profile.html',
                   '3.3.5.cag.html',
                   '3.3.6.gene_anosim.html',
                   '3.3.7.gene_alpha_diversity.html',
                   '3.3.8.gene_wilcox.html',
                   '3.3.9.mgs.html',
                   '3.4.1.kegg.html',
                   '3.4.2.ko_profile.html',
                   '3.4.3.ko_heatmap.html',
                   '3.4.4.ko_pca.html',
                   '3.4.5.ko_anosim.html',
                   '3.4.6.ko_wilcox.html',
                   '3.4.7.ko_lefse.html',
                   '3.4.8.ko_roc.html',
                   '3.4.9.ko_functional.html',
                   '3.4.10.ko_functional_clust.html',
                   '3.4.11.eggNOG.html',
                   '3.4.12.CAZy.html',
                   '3.4.13.ARDB.html',
                   'resultsDirectory.html']

    noneed_parse = ['navigator.html', '2.1.laboratory_pipeline.html', '2.2.analysis_pipeline.html', '2.3.analysis_content.html', 'resultsDirectory.html']

    cover_html = ''
    content_temp = env.get_template('cover.html')
    content_html = content_temp.render(html_dict, encode='utf8')
    with open(out_dir+'/cover.html', 'w', encoding='utf8') as c:
        c.write(content_html)

    for group in html_dict['groups']:
        group_html = ''
        for content in parse_order:
            print(content)
            content_temp = env.get_template(content)
            if content in noneed_parse:
                content_html = content_temp.render({}, encode='utf8')
            else:
                content_html = content_temp.render(html_dict[group][content], encode='utf8')
            group_html += content_html

        with open(out_dir+'/'+group+'_result.html', 'w', encoding='utf8') as gh:
            gh.write(group_html)

