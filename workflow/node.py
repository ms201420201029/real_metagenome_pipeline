#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2016, The metagenome Project"
__version__ = "1.0.0-dev"


import os
import sys
from workflow.util.useful import const
from ConfigParser import ConfigParser
from workflow.control import touch_sh_file


config_file_suffix = const.config_file_suffix
shell_file_suffix = const.shell_file_suffix
config_default_dir = const.config_default_dir
sh_default_dir = const.sh_default_dir


class Node(object):
    def __init__(self,name,path,shell=None,config=None,commads=None):
        self.name = name
        self.configName = "%s.%s" % (name,config_file_suffix)
        self.shellName = "%s.%s" % (name,shell_file_suffix)
        self.path = path
        if config is None:
            self.config = "%s/%s" % (path,self.configName)
        else:
            self.config = config
        if shell is None:
            self.shell = "%s/%s" % (path,self.shellName)
        else:
            self.config = shell
        if commads is not None:
            self.commands = commads
        else:
            self.commands = []
    def cp_config_node(self):
        if not os.path.exists(self.path):
            os.mkdir(self.path)
        config_default_file = "%s/%s" % (config_default_dir,self.configName)
        if os.path.exists(config_default_file):
            os.popen("cp %s %s" % (config_default_file, self.config))
            config = ConfigParser()
            config.read(self.config)
            config.set("param","work_dir", )
            config.set("param","output_dir",self.path)
            config.write(open(self.config,mode="w"))
        else:
            sys.stderr.write("the %s step no add default config : %s \n" % (self.name,config_default_file))
    def cp_sh_node(self):
        sh_default_file = "%s/%s" % (sh_default_dir,self.shellName)
        if os.path.exists(sh_default_file):
            os.popen("cp %s %s" % (sh_default_file,self.shell))
        else:
            sys.stderr.write("the %s step no add default sh : %s \n" % (self.name,sh_default_file))
    def create_shell(self):
        if os.path.exists(self.shell ):
            sys.stderr.write("Covered the file before:%s\n" % self.shell)
        with open(self.shell,"w") as fqout:
            for command in self.commands:
                fqout.write(command)

    def setconfig(self,opts,option_value):
        config_default_file = "%s/%s" % (config_default_dir,self.configName)
        config_def = ConfigParser()
        config_def.read(config_default_file)
        config2 = ConfigParser()
        config2.read(self.config)
        secs = config_def.sections()
        secs_have = config2.sections()
        for sec in secs:
            kvs = config_def.items(sec)
            if sec not in secs_have:
                config2.add_section(sec)
                secs_have.append(sec)
            for value in kvs:
                config2.set(sec,value[0],value[1])
        if opts:
            if "input" not in secs_have:
                config2.add_section("input")
                secs_have.append("input")
            for value in opts:
                if value[0] != "output_dir":
                    config2.set("input",value[0],value[1])
                else:
                    config2.set("input","input_dir",value[1])
        for key,value in option_value.items():
            if "param" not in secs_have:
                config2.add_section("param")
                secs_have.append("param")
            config2.set("param",key,value)
        if "output" not in secs_have:
            config2.add_section("output")
            secs_have.append("output")
            config2.set("output","output_dir",self.path)

        config2.write(open(self.config,mode="w"))

    def getconfig(self,path,name):
        opts = []
        configName = "%s.%s" % (name,config_file_suffix)
        configpath = "%s/%s/%s" % (path,name,configName)
        if os.path.exists(configpath):
            config = ConfigParser()
            config.read(configpath)
            secs = config.sections()
            if "output" in secs:
                opts = config.items("output")
            else:
                sys.stderr.write("%s havn't output sections" % configpath)
        else:
            sys.stderr.write("There is no config file: %s \n" % (configpath))
        return opts
    def setshell(self):
        if os.path.exists(self.shell):
            sys.stderr.write("cover the file %s\n" % self.shell)

        config = self.config
        sh_default_file = "%s/%s" % (sh_default_dir,self.shellName)
        complete = touch_sh_file(config,sh_default_file,self.shell,self.name)
        return complete

    def mkdir(self):
        if not os.path.exists(self.path):
            os.mkdir(self.path)




