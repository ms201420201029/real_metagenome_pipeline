import sys
import os
import re
import math 
import argparse
from workflow.util.useful import const

bin_mgs_default_dir = "%s/MGS.V2.0" % const.bin_default_dir

def read_params(args):
    parser = argparse.ArgumentParser(description='''MGS analysis | v2.0 ato 2017/2/28 by hubh ''')
    parser.add_argument('-p', '--profile', dest='profile', metavar='FILE', type=str, required=True,help="set the profile")
    parser.add_argument('-d', '--dir', dest='dir', metavar='DIR', type=str, required=True,help="set the work dir")
    parser.add_argument('-g', '--group', dest='group', metavar='FILE', type=str, required=True,help="set the group file")
    parser.add_argument('-t', '--threshold', dest='threshold', metavar='NUMBER', type=str, required=False,default = "0",help="set the threshold value")
    args = parser.parse_args()
    params = vars(args)
    return params

def groupline(filename, splitregex = '\t'):
    with open(filename,'rt')as handle:
        for ln in handle:
            items = re.split(splitregex,ln)
            yield items[1]

if __name__ == '__main__':
    reload(sys)
    sys.setdefaultencoding('utf8')
    params = read_params(sys.argv)
    profile = params["profile"]
    dir = params["dir"]
    group = params["group"]
    threshold = params["threshold"]

if os.path.isdir("%s/pathway" % (dir)):
    pass
else:
    os.mkdir("%s/pathway" % (dir))
dir1 = ("%s/pathway" % (dir))
if os.path.isdir("%s/fig" % (dir)):
    pass
else:
    os.mkdir("%s/fig" % (dir))
dir2 = ("%s/fig" % (dir))

line = []
for groupname in groupline(group,splitregex='\t'):
    line.append(groupname)

grouplist = list(set(line))
grp1 = grouplist[0].strip()
grp2 = grouplist[1].strip()

sh = open("%s/work.sh" % (dir),"w+")
sh.write("cut -f1 group.list|/data_center_03/USER/zhongwd/bin/sample2profile - %s > pathway/gene.cut.profile\n" % profile)
sh.write("/data_center_01/pipeline/real_metagenome/real_metagenome_v1.0.0/tool/profilefilter.pl pathway/gene.cut.profile %s group.list  > pathway/gene.filter.profile\n\n" % threshold)

sh.write('touch first_r.sh\n')
sh.write('echo "cd pathway;Rscript /data_center_03/USER/zhongwd/rd/Finish/12_diff_gene/Diff_gene/Rscript/wilcox.test.R ../group.list gene.filter.profile;cd -" > first_r.sh\n')
sh.write('qsub -cwd -l vf=10G -q SJQ first_r.sh\n\n')
sh.write("awk '$2<0.05' pathway/gene.filter.profile.p > pathway/gene.filter.profile.diff.p\n")
#    sh.write("egrep \"\\b%s\\b\" %s/gene.filter.profile.p|cut -f1 > %s/diffgene.%s.list\n" % (line[i],dir1,dir1,line[i]))
#    sh.write("/data_center_03/USER/zhongwd/bin/list2profile %s/diffgene.%s.list %s/gene.filter.profile > %s/%s.profile\n" % (dir1,line[i],dir1,dir1,line[i]))
#    sh.write("egrep \"\\b%s\\b\" %s |cut -f1 > %s/%s.list\n" % (line[i],group,dir1,line[i]))

sh.write("egrep \"\\b%s\\b\" pathway/gene.filter.profile.diff.p|cut -f1 > pathway/diffgene.%s.list\n" % (grp2, grp2))
sh.write("egrep \"\\b%s\\b\" pathway/gene.filter.profile.diff.p|cut -f1 > pathway/diffgene.%s.list\n" % (grp1, grp1))
sh.write("/data_center_03/USER/zhongwd/bin/list2profile pathway/diffgene.%s.list pathway/gene.filter.profile > pathway/%s.profile\n" % (grp1,grp1))
sh.write("/data_center_03/USER/zhongwd/bin/list2profile pathway/diffgene.%s.list pathway/gene.filter.profile > pathway/%s.profile\n" % (grp2,grp2))
sh.write("egrep \"\\b%s\\b\" group.list |cut -f1 > pathway/%s.list\n" % (grp1,grp1))
sh.write("egrep \"\\b%s\\b\" group.list |cut -f1 > pathway/%s.list\n\n" % (grp2,grp2))
sh.write("# cd pathway;perl /data_center_01/pipeline/real_metagenome/real_metagenome_v1.0.0/bin/MGS.V2.0/mgs.pl -p1 %s.profile -p2 %s.profile -l1 %s.list -l2 %s.list -n 25 -r;cd -\n" % (grp1,grp2,grp1,grp2))
sh.write("cd pathway;perl %s/mgs.pl -p1 %s.profile -p2 %s.profile -l1 %s.list -l2 %s.list -n 25 -r;cd -\n" % (bin_mgs_default_dir, grp1,grp2,grp1,grp2))
sh.write("cd pathway;Rscript %s/Rscript/corr/corr.R final_group_mean_%s.profile final_group_mean_%s.profile corr.pdf;cd -\n\n" % (bin_mgs_default_dir,grp1,grp2))
sh.write("mv pathway/mgs.pdf fig\n")
sh.write("mv pathway/new_mgs.pdf fig\n")
sh.write("mv pathway/corr.pdf fig\n")
sh.write("convert -density 300 fig/mgs.pdf fig/mgs.png\n")
sh.write("convert -density 300 fig/new_mgs.pdf fig/new_mgs.png\n")
sh.write("convert -density 300 fig/corr.pdf fig/corr.png\n")
sh.close()

#os.system('sh %s/work.sh' % (dir))
