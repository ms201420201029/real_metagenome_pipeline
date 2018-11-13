#!/usr/bin/perl 
# by liulf

use strict;
use warnings;
use Getopt::Long;

my ($list,$dir) = ("","");
&GetOptions(
	'l=s'   => \$list,
	'd=s'   => \$dir,
);

unless((-e $list) && $dir){
	usage();
}

mkdir("$dir/shell") unless (-e "$dir/shell");
mkdir("$dir/assembly") unless (-e "$dir/assembly");

my $megahit = "/home/wenpp/sofe/megahit/megahit/megahit";
my $outfile = "$dir/shell/assembly.sh";

open (OUT,">$outfile") or die "NO FILE OF $outfile $!";


open (IN,$list) or die "NO FILE OF $list $!";
while(<IN>){
	chomp;
	s/\r|\n//g;
	my ($sample,$r1,$r2,$r_single) = split("\t");
	# mkdir("$dir/assembly/$sample") unless (-e "$dir/assembly/$sample"); 
	# megahit 不需要生成输出文件
	print OUT "$megahit -1 $r1 -2 $r2 -o "."$dir/assembly/$sample\n";
	
	
}

# perl .pl -l clean_reads.list -d /data_center_12/Project/liulf_test/03.assembly/preprocess_for_assembly/megahit/


sub usage {
	die "
Description: Shell file for megahit assembly method

Usage:  perl $0 [Options]
Options:
	  -l <FILE>  The BAM file path of the sample 
	  -d <DIR>   The location of chromosomes in a specific interval
Example: perl $0 -l clean_reads.list -d ./

Version: 1.0
Contact:	Liulif
Last Update:	2018/06/27
";
}
