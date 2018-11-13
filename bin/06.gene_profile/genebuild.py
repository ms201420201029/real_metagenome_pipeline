#!/usr/bin/env python
# -*- coding: utf-8 -*- #

import sys, os
import argparse
from workflow.util.useful import mkdir

def read_params(args):
    parser = argparse.ArgumentParser(description=''' 2bwt-builder steps into clusters | v1.0 at 2018/11/7 by liulf ''')
    parser.add_argument('-d', '--dir', dest='dir', metavar='DIR', type=str, required=True,
                        help= "working directory ./06.gene_profile")
    args = parser.parse_args()
    params = vars(args)
    return params
                        
if __name__ == "__main__":
    reload(sys)
    sys.setdefaultencoding('utf8')
    params = read_params(sys.argv)
    
    work_dir = params["dir"]
    shell_dir = "%s/shell" % os.path.abspath(work_dir)
    index_file = "%s/database/gene_catalog.fna" % work_dir
    
    if not os.path.exists(index_file):
        os.system('ln -s %s/../05.gene_catalog/gene_catalog.fna %s/database/' % (work_dir, work_dir))
        
    mkdir(shell_dir)
    with open("%s/2bwt_builder.sh" % shell_dir, "w") as inf:
        inf.write("/usr/bin/2bwt-builder %s" % index_file)