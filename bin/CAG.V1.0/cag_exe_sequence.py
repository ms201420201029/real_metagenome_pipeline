#!/usr/bin/env python
# -*- coding: utf-8 -*- #

import sys
import argparse

def read_params(args):
    parser = argparse.ArgumentParser(description='''CAG analysis | v1.0 ato 2017/2/28 by hubh ''')
    parser.add_argument('-d', '--dir', dest='dir', metavar='DIR', type=str, required=True,help="set the work dir")
    args = parser.parse_args()
    params = vars(args)
    return params

if __name__ == '__main__':
    reload(sys)
    sys.setdefaultencoding('utf8')
    params = read_params(sys.argv)
    dir = params["dir"]

sh = open("%s/cag.sh" % dir, "w")
sh.write("sh %s/00.cag_cluster/s1_work.sh\n" % dir)
sh.write("sh %s/pathway/s2_work.sh\n" % dir)
sh.write("sh %s/pathway/fig.sh\n" % dir)
sh.write("cd %s/taxonomy/\n" % dir)
sh.write("sh cag_taxonomy.sh\n")
sh.write("cd -\n")
sh.close()


