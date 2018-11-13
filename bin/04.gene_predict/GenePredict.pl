#!/usr/bin/env perl
=pod
Description: MetaGeneMark Module 
Author: Zhong wendi
Create date: 20151202
=cut
use warnings;
use strict;
use Getopt::Long;
use File::Basename 'dirname';
use Cwd 'abs_path';

## import parameters
my ($scaftigs_list, $geneLengthCutOff, $dir, $help);
GetOptions(
		"scaftigs|s=s" => \$scaftigs_list,
		"length|l=i"   => \$geneLengthCutOff,
		"dir|d=s"      => \$dir,
		"help|h!"      => \$help);
&help unless defined $scaftigs_list and -e $scaftigs_list and not defined $help;
$dir          = abs_path($dir);
my $dir_shell = "$dir/shell";
my $dir_gff   = "$dir/gff";
my $dir_gene  = "$dir/gene";
-d $dir       or system("mkdir $dir");
-d $dir_shell or system("mkdir $dir_shell");
-d $dir_gff   or system("mkdir $dir_gff");
-d $dir_gene  or system("mkdir $dir_gene");
my $src_dir = dirname(abs_path($0));
my $bin_dir = "/data_center_03/USER/zhongwd/soft/GenePredict/bin/";

## main
#### import list
my %scaftigs;
my $geneList;
my $gffList;
open IN, "$scaftigs_list" or die $!;
while (<IN>){
	chomp;
	my ($sample, $scaftigs) = split /\t/;
	$scaftigs{$sample} = $scaftigs;
}
close IN;
#### export shell
open SH, ">$dir_shell/predict.sh";
foreach my $sample (sort keys %scaftigs){
	print SH <<__SH__;
gmhmmp -k -r -a -d -f G -m $bin_dir/MetaGeneMark_v1.mod -o $dir_gff/$sample.gff $scaftigs{$sample}
perl $bin_dir/gff2gene.pl -i $dir_gff/$sample.gff -o $dir_gene/$sample.gene.fna -l 100 -s $sample
__SH__
    $geneList .= "$sample\t$dir_gene/$sample.gene.fna\n";
    $gffList  .= "$sample\t$dir_gff/$sample.gff\n";
}
close SH;
open  GL, ">$dir/gene.list" or die $!;
print GL $geneList;
close GL;
open  GL, ">$dir/gff.list" or die $!;
print GL $gffList;
close GL;
#### run shell
##system("/data_center_03/USER/zhongwd/bin/qsge --queue all.q --memery 1G --jobs 10 --prefix GP --lines 2 $dir_shell/predict.sh");

## subroutine
sub help{
	print STDERR <<"_USAGE_" and exit 1;

description:
usage: perl $0 [options]
options:
	-s <string>  list of scaftigs with sample names.
    -l <integer> cutoff of gene length.
	-d <string>  directory of gene prediction.
	-h <options> print this help infomation.
e.g.:
	perl $0 -s scaftigs.list -l 100 -d 04.gene_predict

_USAGE_
}
