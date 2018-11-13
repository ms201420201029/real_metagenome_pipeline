#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2016, The metagenome Project"
__version__ = "1.0.0-dev"

import re, sys, argparse
TAXLIST=["/data_center_06/Database/GENOMEall_20160826.txt"]
def read_params(args):
    parser = argparse.ArgumentParser(description='group file change')
    parser.add_argument('-i', '--input', dest='input', metavar='input', type=str, required=True,
                        help="abundance of list file")
    #parser.add_argument('-o', '--outputdir', dest='outputdir', metavar='outputdir', type=str,
    #                    help="out put dir")
    args = parser.parse_args()
    params = vars(args)
    return params

special = ["[","]","(",")",".","-"," ","+",":","/","'"]
def format_taxonomy_name(name,level):
    resub = re.sub
    for i in special:
        name = name.replace('%s'%i,' ')
        name = resub(r'^\s+',"",name)
        name = resub(r'\s+$',"",name)                                
    name = resub("\s+","_",name)
    return "%s__%s"%(level,name)

if __name__ == '__main__':
    params = read_params(sys.argv)
    list_file = params["input"]
    genus_pro={}
    family_pro={}
    order_pro={}
    class_pro={}
    phylum_pro={}
    king_pro = {}
    taxanomy2 = {}
    taxanomy3 = {}
    taxanomy4 = {}
    taxanomy5 = {}
    taxanomy6 = {}
    for val in TAXLIST:
        with open(val,"r") as fq:
            for line in fq:
                tax = line.strip().split("\t")
                tax = tax[:-2]
                species = tax[-1]
                genus_pro[species] = tax[-2]
                family_pro[species] = tax[-3]
                order_pro[species] = tax[-4]
                class_pro[species] = tax[-5]
                phylum_pro[species] = tax[-6]
                king_pro[species] = tax[-7]
                taxanomy2[tax[-2]] = tax[1:]
                taxanomy3[tax[-3]] = tax[1:]
                taxanomy4[tax[-4]] = tax[1:]
                taxanomy5[tax[-5]] = tax[1:]
                taxanomy6[tax[-6]] = tax[1:]
    with open(list_file,"r") as fq:
        for line in fq:
            strinfo = re.compile(".root.abundance")
            name = strinfo.sub("",line.strip())
            genus_abun = {}
            family_abun = {}
            order_abun = {}
            class_abun = {}
            phylum_abun = {}
            king_abun = {}
            with open("%s.all.abundance" % name,"w") as fqall:
                with open(line.strip(),"r") as fq2 , open("%s.species.abundance" % name,"w") as fqs:
                    for line_abu in fq2:
                        species,abun = line_abu.strip().split("\t")
                        abun = float(abun)
                        if abun == 0:
                            continue
                        fqs.write("%s\t%s\n" % (format_taxonomy_name(species,"s"),abun))
                        genus_abun[genus_pro[species]] = genus_abun[genus_pro[species]] + abun if genus_abun.has_key(genus_pro[species]) else abun
                        family_abun[family_pro[species]] = abun + family_abun[family_pro[species]]  if family_abun.has_key(family_pro[species]) else abun
                        order_abun[order_pro[species]] = abun + order_abun[order_pro[species]] if order_abun.has_key(order_pro[species]) else abun
                        class_abun[class_pro[species]] = abun + class_abun[class_pro[species]] if class_abun.has_key(class_pro[species]) else abun
                        phylum_abun[phylum_pro[species]] = abun + phylum_abun[phylum_pro[species]] if phylum_abun.has_key(phylum_pro[species]) else abun
                        king_abun[king_pro[species]] = abun + king_abun[king_pro[species]] if king_abun.has_key(king_pro[species]) else abun

                        #fqall.write("%s|%s|%s|%s|%s|%s|%s\t%s\n" % (format_taxonomy_name(king_pro[species],"k"),\
                        #                                            format_taxonomy_name(phylum_pro[species],"p"),\
                        #                                            format_taxonomy_name(class_pro[species],"c"),\
                        #                                         format_taxonomy_name(order_pro[species],"o"),\
                        #                                            format_taxonomy_name(family_pro[species],"f"),\
                        #                                        format_taxonomy_name(genus_pro[species],"g"),\
                        #                                         format_taxonomy_name(species,"s"),abun))
                with open("%s.king.abundance" % name,"w") as fqw:
                    for key,value in king_abun.items():
                        fqw.write("%s\t%s\n" % (format_taxonomy_name(key,"k"),value))
                        fqall.write("%s\t%s\n" % (format_taxonomy_name(key,"k"),value))
                with open("%s.phylum.abundance" % name,"w") as fqw:
                    for key,value in phylum_abun.items():
                        fqw.write("%s\t%s\n" % (format_taxonomy_name(key,"p"),value))
                        fqall.write("%s|%s\t%s\n" % (format_taxonomy_name(taxanomy6[key][0],"k"),format_taxonomy_name(key,"p"),value))
                with open("%s.class.abundance" % name,"w") as fqw:
                    for key,value in class_abun.items():
                        fqw.write("%s\t%s\n" % (format_taxonomy_name(key,"c"),value))
                        fqall.write("%s|%s|%s\t%s\n" % (format_taxonomy_name(taxanomy5[key][0],"k"),\
                                                        format_taxonomy_name(taxanomy5[key][1],"p"),\
                                                                             format_taxonomy_name(key,"c"),value))
                with open("%s.order.abundance" % name,"w") as fqw:
                    for key,value in order_abun.items():
                        fqw.write("%s\t%s\n" % (format_taxonomy_name(key,"o"),value))
                        fqall.write("%s|%s|%s|%s\t%s\n" % (format_taxonomy_name(taxanomy4[key][0],"k"),format_taxonomy_name(taxanomy4[key][1],"p"),\
                                                           format_taxonomy_name(taxanomy4[key][2],"c"),\
                                                  format_taxonomy_name(key,"o"),value))
                with open("%s.family.abundance" % name,"w") as fqw:
                    for key,value in family_abun.items():
                        fqw.write("%s\t%s\n" % (format_taxonomy_name(key,"f"),value))
                        fqall.write("%s|%s|%s|%s|%s\t%s\n" % (format_taxonomy_name(taxanomy3[key][0],"k"),format_taxonomy_name(taxanomy3[key][1],"p"),\
                                                                format_taxonomy_name(taxanomy3[key][2],"c"),format_taxonomy_name(taxanomy3[key][3],"o"),\
                                                                format_taxonomy_name(key,"f"),value))
                with open("%s.genus.abundance" % name,"w") as fqw:
                    for key,value in genus_abun.items():
                        fqw.write("%s\t%s\n" % (format_taxonomy_name(key,"g"),value))
                        fqall.write("%s|%s|%s|%s|%s|%s\t%s\n" % (format_taxonomy_name(taxanomy2[key][0],"k"),format_taxonomy_name(taxanomy2[key][1],"p"),\
                                                                 format_taxonomy_name(taxanomy2[key][2],"c"),format_taxonomy_name(taxanomy2[key][3],"o"),\
                                                                 format_taxonomy_name(taxanomy2[key][4],"f"),format_taxonomy_name(key,"g"),value))

                with open(line.strip(),"r") as fq2:
                    for line_abu in fq2:
                            species,abun = line_abu.strip().split("\t")
                            abun = float(abun)
                            if abun == 0:
                                continue
                            fqall.write("%s|%s|%s|%s|%s|%s|%s\t%s\n" % (format_taxonomy_name(king_pro[species],"k"),\
                                                                        format_taxonomy_name(phylum_pro[species],"p"),\
                                                                        format_taxonomy_name(class_pro[species],"c"),\
                                                                     format_taxonomy_name(order_pro[species],"o"),\
                                                                        format_taxonomy_name(family_pro[species],"f"),\
                                                                    format_taxonomy_name(genus_pro[species],"g"),\
                                                                     format_taxonomy_name(species,"s"),abun))
