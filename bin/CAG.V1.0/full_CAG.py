#!/usr/bin/env python
# -*- coding: utf-8 -*- #

from workflow.util.useful import const

import sys
import argparse
import os
def read_params(args):
    parser = argparse.ArgumentParser(description='''CAG analysis | v1.0 ato 2017/2/28 by hubh ''')
    parser.add_argument('-p', '--profile', dest='profile', metavar='FILE', type=str, required=True,help="set the profile")
    parser.add_argument('-d', '--dir', dest='dir', metavar='DIR', type=str, required=True,help="set the work dir")
    parser.add_argument('-g', '--group', dest='group', metavar='FILE', type=str, required=True,help="set the group file")
    parser.add_argument('-gn', '--genenumber', dest='genenumber', metavar='NUMBER', type=int,help="set the group file",default = 2)
    args = parser.parse_args()
    params = vars(args)
    return params
if __name__ == '__main__':
    reload(sys)
    sys.setdefaultencoding('utf8')
    params = read_params(sys.argv)
    profile = params["profile"]
    dir = params["dir"]
    group = params["group"]
    genenumber = params["genenumber"]
    bin_dir = '%s/CAG.V1.0' % const.bin_default_dir

if os.path.isdir("%s/00.cag_cluster" % (dir)):
    pass
else:
    os.mkdir("%s/00.cag_cluster" % (dir))
dir1 = ("%s/00.cag_cluster" % (dir))
if os.path.isdir("%s/pathway" % (dir)):
    pass
else:
    os.mkdir("%s/pathway" % (dir))
dir2 = ("%s/pathway" % (dir))
sh = open("%s/s1_work.sh" % (dir1),"w+")
sh.write("/data_center_03/USER/zhongwd/bin/profilefilter %s 10 > %s/gene.filter.profile\n" % (profile,dir1))
sh.write("cd %s;perl %s/cag.pl -i %s/gene.filter.profile -t1 0.95 -t2 0.9 -t 0.97 -p 0.7 -g %s -c 30 -a;cd -\n" % (dir1, bin_dir, dir1, genenumber))
sh.write("cut -f2 %s|uniq|less|while read a ;do grep \"$a\" %s|cut -f1 > %s/$a.list;done" % (group,group,dir2))
sh.close()
sh = open("%s/s2_work.sh" % (dir2),"w+")
sh.write("cut -f1 %s|/data_center_03/USER/zhongwd/bin/sample2profile - %s > %s/cut.profile\n" % (group,profile,dir1))
sh.write("ls %s/*.list|xargs > %s/group.line\n" % (dir2,dir2))
sh.write("perl %s/makefig.pl -in1 %s/cag -in2 %s/cut.profile -in3 %s/group.line -out %s/fig.sh\n" % (bin_dir,dir2,dir1,dir2,dir2))
sh.close()
#os.system('sh %s/work.sh' % (dir))
#os.system('sh %s/work.sh' % (dir2))
#os.system('sh %s/fig.sh' % (dir))
