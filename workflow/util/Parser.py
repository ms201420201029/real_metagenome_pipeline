from __future__ import division
import os
import re
from string import Template
from collections import OrderedDict


class MyTemplate(Template):
    delimiter = '@#'


class Rparser(object):
    def __init__(self):
        self.template = None
        self.R_script = None
        self.file = None

    def open(self, template):
        fp = open(template)
        template = fp.read()
        fp.close()
        self.template = MyTemplate(template)

    def format(self, var):
        self.R_script = self.template.safe_substitute(var)

    def write(self, outfile):
        fp = open(outfile, 'w')
        fp.write(self.R_script)
        self.file = outfile
        fp.close()

    def run(self):
        os.system('R CMD BATCH --slave %(Rfile)s %(Rfile)sout' % {'Rfile': self.file})


# TODO: rewrite it with pandas
class TableParser(object):
    def __init__(self, profile):
        self.profile = profile
        self.sample_list = []
        self.otu_list = []
        self.samples = {}
        self.samples_sum = {}
        self.OTUs = {}

    def parse_table(self):
        with open(self.profile) as fp:
            head = fp.next().strip()
            if head.startswith('# Constructed from'):
                head = fp.next().strip()
            self.sample_list = head.split('\t')[1:]
            for sample in self.sample_list:
                self.samples[sample] = {}
                self.samples_sum[sample] = 0
            for line in fp:
                tabs = line.strip().split('\t')
                otu_name = tabs.pop(0)
                self.otu_list.append(otu_name)
                self.OTUs[otu_name] = {}
                for ind, sample in enumerate(self.sample_list):
                    profile = float(tabs[ind])
                    self.samples_sum[sample] += profile
                    self.samples[sample][otu_name] = profile
                    self.OTUs[otu_name][sample] = profile

    def get_uniform(self):
        for sample in self.samples:
            if abs(self.samples_sum[sample] - 1) < 0.01:
                continue
            for otu in self.OTUs:
                self.samples[sample][otu] /= self.samples_sum[sample]
                self.OTUs[otu][sample] /= self.samples_sum[sample]

    def write_table(self, outfile):
        with open(outfile, 'w') as fp:
            fp.write('OTU ID\t%s\n' % '\t'.join(self.sample_list))
            for otu in self.otu_list:
                out_str = otu
                for sample in self.sample_list:
                    out_str += '\t%s' % self.OTUs[otu][sample]
                fp.write(out_str.strip() + '\n')


class TaxParser(object):
    def __init__(self, tax_file):
        self.tax_file = tax_file
        self.sorted_level = ['kingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species']
        self.tax_dict = {
            'k': 'kingdom',
            'p': 'phylum',
            'c': 'class',
            'o': 'order',
            'f': 'family',
            'g': 'genus',
            's': 'species',
        }
        self.OTUs = {}

    def init_otu(self, otu_name):
        if otu_name not in self.OTUs:
            self.OTUs[otu_name] = OrderedDict()
        for tax in self.sorted_level:
            self.OTUs[otu_name][tax] = 'Other'

    def parse(self):
        with open(self.tax_file) as fp:
            for line in fp:
                try:
                    otu_name, tax_all, conf = line.strip().split('\t')
                except ValueError, ex:
                    if str(ex) == 'need more than 1 value to unpack':
                        continue
                    else:
                        raise
                if otu_name not in self.OTUs:
                    self.init_otu(otu_name)
                taxes = tax_all.split(';')
                for tax in taxes:
                    try:
                        short_name = re.search('(\w)__', tax).group(1)
                    except AttributeError:
                        continue
                    level = self.tax_dict[short_name]
                    self.OTUs[otu_name][level] = tax

    def remove_other(self):
        for otu, subitem in self.OTUs.iteritems():
            levels = list(subitem.iterkeys())
            for level in levels:
                if self.OTUs[otu][level] == 'Other':
                    del self.OTUs[otu][level]


def parse_stat_file(stat_file, group_file=None):
    group = parse_group_file(group_file)
    with open(stat_file) as fp:
        # line = fp.next()
        # while (line):
        #     line = fp.next().strip()
        fp.next()
        maximum = 0
        minimum = 0xffffff
        for line in fp:
            tabs = line.strip().split('\t')
#            if group and tabs[0] not in group:
#                continue
            if maximum < int(tabs[2]):
                maximum = int(tabs[2])
            if minimum > int(tabs[2]):
                minimum = int(tabs[2])
    return maximum, minimum


def parse_group_file(file):
    if file is None:
        return None
    group = OrderedDict()
    with open(file) as g:
        for line in g:
            tabs = line.strip().split('\t')
            if len(tabs) >= 2:
                group[tabs[0]] = tabs[1]
            else:
                group[tabs[0]] = tabs[0]
    return group
