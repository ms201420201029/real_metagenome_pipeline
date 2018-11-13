import sys
import os
import re
import math 
import argparse

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
sh.write("cut -f1 %s|/data_center_03/USER/zhongwd/bin/sample2profile - %s > %s/gene.cut.profile\n" % (group,profile,dir1))
sh.write("/data_center_01/pipeline/real_metagenome/real_metagenome_v1.0.0/tool/profilefilter.pl %s/gene.cut.profile %s %s  > %s/gene.filter.profile\n" % (dir1,threshold,group,dir1))
sh.write("cd %s;Rscript /data_center_03/USER/zhongwd/rd/Finish/12_diff_gene/Diff_gene/Rscript/wilcox.test.R %s/../group.list gene.filter.profile;cd -\n" % (dir1,dir1))
sh.write("awk '$2<0.05' %s/pathway/gene.filter.profile.p > %s/pathway/gene.filter.profile.diff.p\n"%(dir,dir))
#    sh.write("egrep \"\\b%s\\b\" %s/gene.filter.profile.p|cut -f1 > %s/diffgene.%s.list\n" % (line[i],dir1,dir1,line[i]))
#    sh.write("/data_center_03/USER/zhongwd/bin/list2profile %s/diffgene.%s.list %s/gene.filter.profile > %s/%s.profile\n" % (dir1,line[i],dir1,dir1,line[i]))
#    sh.write("egrep \"\\b%s\\b\" %s |cut -f1 > %s/%s.list\n" % (line[i],group,dir1,line[i]))

sh.write("egrep \"\\b%s\\b\" %s/gene.filter.profile.diff.p|cut -f1 > %s/diffgene.%s.list\n" % (grp2,dir1,dir1,grp2))
sh.write("egrep \"\\b%s\\b\" %s/gene.filter.profile.diff.p|cut -f1 > %s/diffgene.%s.list\n" % (grp1,dir1,dir1,grp1))
sh.write("/data_center_03/USER/zhongwd/bin/list2profile %s/diffgene.%s.list %s/gene.filter.profile > %s/%s.profile\n" % (dir1,grp1,dir1,dir1,grp1))
sh.write("/data_center_03/USER/zhongwd/bin/list2profile %s/diffgene.%s.list %s/gene.filter.profile > %s/%s.profile\n" % (dir1,grp2,dir1,dir1,grp2))
sh.write("egrep \"\\b%s\\b\" %s |cut -f1 > %s/%s.list\n" % (grp1,group,dir1,grp1))
sh.write("egrep \"\\b%s\\b\" %s |cut -f1 > %s/%s.list\n" % (grp2,group,dir1,grp2))
sh.write("cd %s;perl /data_center_01/pipeline/real_metagenome/real_metagenome_v1.0.0/bin/MGS.V2.0/mgs.pl -p1 %s.profile -p2 %s.profile -l1 %s.list -l2 %s.list -n 25 -r;cd -\n" % (dir1,grp1,grp2,grp1,grp2))
sh.write("cd %s;Rscript /data_center_01/pipeline/real_metagenome/real_metagenome_v1.0.0/bin/MGS.V2.0/Rscript/corr/corr.R final_group_mean_%s.profile final_group_mean_%s.profile corr.pdf;cd -\n" % (dir1,grp1,grp2))
sh.write("mv %s/mgs.pdf %s\n" % (dir1,dir2))
sh.write("mv %s/corr.pdf %s\n" % (dir1,dir2))
sh.write("convert -density 300 %s/mgs.pdf %s/mgs.png\n" %(dir2,dir2))
sh.write("convert -density 300 %s/corr.pdf %s/corr.png\n" %(dir2,dir2))
sh.close()

# os.system('sh %s/work.sh' % (dir))
