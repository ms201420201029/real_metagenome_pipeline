#!/usr/bin/env python
# -*- coding: utf-8 -*- #
__author__ = "huangy"
__copyright__ = "Copyright 2016, The metagenome Project"
__version__ = "1.0.0-dev"

class ConfigObj(object):
    def __init__(self,section,option,value):
        self.section = section
        self.option = option
        self.value = value