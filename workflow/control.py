#!/usr/bin/env python
# -*- coding: utf-8 -*- #

__author__ = "huangy"
__copyright__ = "Copyright 2016, The metagenome Project"
__version__ = "1.0.0-dev"

import os, sys
#from workflow.util import configparserself
from workflow.src.raw_reads import raw_reads
from workflow.src.clean_reads import clean_reads
from workflow.src.taxon import taxon_pre, taxon
from workflow.src.assembly import assembly_pre, assembly
from workflow.src.gene_predict import gene_predict_pre, gene_predict
from workflow.src.gene_catalog import gene_catalog_pre, gene_catalog
from workflow.src.gene_profile import gene_profile_pre, gene_profile
from workflow.src.kegg import kegg_pre, kegg
from workflow.src.eggnog import eggnog_pre, eggnog
from workflow.src.ardb import ardb_pre, ardb
from workflow.src.mgs import mgs
from workflow.src.cag import cag
from workflow.src.cazy import cazy_pre, cazy
from workflow.src.html import html

def touch_sh_file(config,outpath,name):
    commands=""
    outfilepath,suffix = os.path.splitext(outpath)
    if name=="00.raw_reads":
        commands = raw_reads(config, name)
    elif name=="01.clean_reads":
        commands = clean_reads(config, name)
    elif name == "02.taxon":
        for dir, commands in taxon_pre(config, name):
            with open("%s/taxon_pre.sh"%dir,"w") as fqout:
                for key in commands:
                    fqout.write("%s\n" % key)
        #commands2=taxon(config, name)
        #with open(outpath,"w") as fqout:
        #    for key in commands2:
        #        fqout.write("%s\n" % key)
        taxon(config, name)
        return True
    elif name == "03.assembly":
        for dir, commands in assembly_pre(config, name):
            with open("%s/assembly_pre.sh" % dir, "w") as fqout:
                for key in commands:
                    fqout.write("%s\n" % key)
        for dir2, commands2 in assembly(config, name):
            with open("%s/assembly.sh" % dir2, "w") as fqout:
                for key in commands2:
                    fqout.write("%s\n" % key)
        # commands2=assembly(config, name)
        # with open(outpath,"w") as fqout:
            # for key in commands2:
                # fqout.write("%s\n" % key)
        return True
    elif name == "04.gene_predict":
        commands = gene_predict_pre(config, name)
        with open("%s_pre%s"%(outfilepath,suffix),"w") as fqout:
            for key in commands:
                fqout.write("%s\n" % key)
        commands2=gene_predict(config, name)
        with open(outpath,"w") as fqout:
            for key in commands2:
                fqout.write("%s\n" % key)
        return True
    elif name == "05.gene_catalog":
        commands = gene_catalog_pre(config, name)
        with open("%s_pre%s"%(outfilepath,suffix),"w") as fqout:
            for key in commands:
                fqout.write("%s\n" % key)
        commands2=gene_catalog(config, name)
        with open(outpath,"w") as fqout:
            for key in commands2:
                fqout.write("%s\n" % key)
        return True
    elif name == "06.gene_profile":
        commands = gene_profile_pre(config, name)
        with open("%s_pre%s"%(outfilepath,suffix),"w") as fqout:
            for key in commands:
                fqout.write("%s\n" % key)
        commands2=gene_profile(config, name)
        with open(outpath,"w") as fqout:
            for key in commands2:
                fqout.write("%s\n" % key)
        return True
    elif name == "07.kegg":
        commands = kegg_pre(config, name)
        with open("%s_pre%s"%(outfilepath,suffix),"w") as fqout:
            for key in commands:
                fqout.write("%s\n" % key)
        commands2=kegg(config, name)
        with open(outpath,"w") as fqout:
            for key in commands2:
                fqout.write("%s\n" % key)
        return True
    elif name == "08.eggnog":
        commands = eggnog_pre(config, name)
        with open("%s_pre%s"%(outfilepath,suffix),"w") as fqout:
            for key in commands:
                fqout.write("%s\n" % key)
        commands2=eggnog(config, name)
        with open(outpath,"w") as fqout:
            for key in commands2:
                fqout.write("%s\n" % key)
        return True
    elif name == "09.ardb":
        commands = ardb_pre(config, name)
        with open("%s_pre%s"%(outfilepath,suffix),"w") as fqout:
            for key in commands:
                fqout.write("%s\n" % key)
        commands2=ardb(config, name)
        with open(outpath,"w") as fqout:
            for key in commands2:
                fqout.write("%s\n" % key)
        return True
    elif name == "10.MGS":
        commands = mgs(config, name)
        with open("%s_pre%s"%(outfilepath,suffix),"w") as fqout:
            for key in commands:
                fqout.write("%s\n" % key)
        # commands2=ardb(config, name)
        # with open(outpath,"w") as fqout:
            # for key in commands2:
                # fqout.write("%s\n" % key)
        return True
    elif name == "11.CAG":
        # commands = cag(config, name)
        # with open("%s_pre%s"%(outfilepath,suffix),"w") as fqout:
            # for key in commands:
                # fqout.write("%s\n" % key)
        # return True
        cag(config, name)
    elif name == '12.cazy':
        commands = cazy_pre(config, name)
        with open("%s_pre%s"%(outfilepath,suffix),"w") as fqout:
            for key in commands:
                fqout.write("%s\n" % key)
        commands2=cazy(config, name)
        with open(outpath,"w") as fqout:
            for key in commands2:
                fqout.write("%s\n" % key)
        return True
    elif name == "html":
        commands = html(config, outpath, name)
        with open(outpath, "w") as fqout:
            for key in commands:
                fqout.write("%s\n" % key)
        return True
    else:
        sys.stderr.write("step name is %s not in src" % name)
        return False
    if commands:
        with open(outpath,"w") as fqout:
            for key in commands:
                fqout.write("%s\n" % key)
        return True
    else:
        return False
