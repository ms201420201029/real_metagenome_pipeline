#!/usr/bin/env perl
=pod
Description: SOAP denovo for metagenomic data
Author: Zhong wendi
Create date: 20151118
=cut
use warnings;
use strict;
use Getopt::Long;
use File::Basename 'dirname';
use Cwd 'abs_path';
require "/data_center_03/USER/zhongwd/lib/math.pm";

## import parameters
my ($version, $sample_list, $ins_size_list, $kmer, $minkmer, $maxkmer, $step, $thread, $dir, $help);
#### default parameters
$version = "63";
$thread  = "10";
$dir     = "./";
GetOptions(
		"version|v=i" => \$version,
		"list|l=s"    => \$sample_list,
		"insert|i=s"  => \$ins_size_list,
		"kmer|k=i"    => \$kmer,
		"minkmer=i"   => \$minkmer,
		"maxkmer=i"   => \$maxkmer,
		"bystep|b=i"  => \$step,
		"thread|p=i"  => \$thread,
		"dir|d=s"     => \$dir,
		"help|h!"     => \$help);
&help unless defined $sample_list and -e $sample_list;
&help unless defined $ins_size_list and -e $ins_size_list;
&help unless defined $maxkmer and defined $minkmer and defined $step xor defined $kmer;
&help unless defined $dir and not defined $help;
#### src dir
my $src_dir = dirname($0);
my $bin_dir = $src_dir . "/bin";
#### assembly dir
-d $dir or system("mkdir $dir");
   $dir       = abs_path($dir);
my $dir_shell = "$dir/shell";
my $dir_cfg   = "$dir/config";
my $dir_ass   = "$dir/assembly";
-e $dir_shell or system("mkdir $dir_shell");
-e $dir_cfg   or system("mkdir $dir_cfg");
-e $dir_ass   or system("mkdir $dir_ass");
#### soft
my $soap_denovo = "SOAPdenovo-${version}mer";

## main
#### kmers array
my @kmer_arr;
if (defined $kmer){
	@kmer_arr = ($kmer);
}else {
	for ($kmer = $minkmer; $kmer <= $maxkmer; $kmer += $step){
		push @kmer_arr, $kmer;
	}
}
#### import sample list
my %config;
open IN, "$sample_list" or die $!;
while (<IN>){
	chomp;
	my ($sample, $fq1, $fq2, $fqs) = split /\t/;
	die "clean reads file does not exist!\n" unless -e $fq1 and -e $fq2 and -e $fqs;
	$config{$sample}{"fq1"} = $fq1;
	$config{$sample}{"fq2"} = $fq2;
	$config{$sample}{"fqs"} = $fqs;
}
close IN;
#### import insert size list
open IN, "$ins_size_list" or die $!;
while (<IN>){
	chomp;
	my ($sample, $ins) = split /\t/;
	$config{$sample}{"insert"} = $ins;
}
close IN;
#### import data stat
#my %stat;
#open IN, "$stat" or die $!;
#<IN>;
#while (<IN>){
#	chomp;
#	my ($sample, $length_pool, $raw_reads, $raw_bases, $quality, $host, $clean_reads, $clean_bases, $use) = split /\t/;
#	my @length = split /,/, $length_pool;
#	my $length = max(@length);
#	if(defined  $config{$sample}){
#		$config{$sample}{"length"} = $length;
#		$stat{$sample}{"clean_reads"} = $clean_reads;
#		$stat{$sample}{"clean_bases"} = $clean_bases;
#	}
#}
#close IN;
#### form config file
foreach my $sample (sort keys %config){
	next unless defined $config{$sample}{'fq1'};
	open  CFG, ">$dir_cfg/$sample.cfg" or die $!;
	print CFG <<__CFG__;
max_rd_len=150
[LIB]
avg_ins=$config{$sample}{"insert"}
asm_flags=3
rank=1
q1=$config{$sample}{"fq1"}
q2=$config{$sample}{"fq2"}
[LIB]
asm_flags=1
q=$config{$sample}{"fqs"}
__CFG__
	close CFG;
}
#### form shell
open  SH,">$dir_shell/assembly.sh" or die;
foreach my $sample (sort keys %config){
	next unless defined $config{$sample}{'fq1'};
	-d "$dir_ass/$sample" or system("mkdir $dir_ass/$sample");
	foreach $kmer (@kmer_arr){
		my $dir_result = "$dir_ass/$sample/Kmer$kmer";
		-d $dir_result or system("mkdir $dir_result");
		print SH <<__SHELL__;
$soap_denovo pregraph -o $dir_result/$sample -s $dir_cfg/$sample.cfg -p $thread -d 1 -K $kmer
$soap_denovo contig   -g $dir_result/$sample -M 3
$soap_denovo map      -g $dir_result/$sample -s $dir_cfg/$sample.cfg -p $thread
$soap_denovo scaff    -g $dir_result/$sample -p $thread -F -u
__SHELL__
	}
}
close SH;
#### calculate memery and run
#system("nohup /data_center_03/USER/zhongwd/bin/qsge --queue big.q:all.q:all.q:all.q --resource vf=70G:5G:3G:11G --maxjob 5 --lines 4 --jobprefix AS -getmem $dir_shell/assembly.sh &");
## subroutine
sub help{
	print STDERR <<"_USAGE_" and exit 1;

description: SOAP denovo for metagenomic data
usage: perl $0 [options]
options:
	-v  <string>  version of SOAP denovo, default is 63.
	-l  <string>  sample list of clean reads, which contains the single end reads.
	-i  <string>  insert size list of samples.
	-k  <integer> kmer used in SOAP denovo.
	-minkmer <integer> minimum kmer.
	-maxkmer <integer> maximum kmer.
	-b  <integer> step of kmers.
	-p  <integer> number of threads in SOAP denovo.
	-d  <string>  directory of assembly.
	-h  <options> print this help infomation.
note:
	
	if kmer is bigger than 63, the version of SOAP denovo will choose "127mer".
e.g.:
	perl $0 --list sample.list --insert insert.list --minkmer 51 --maxkmer 63 --bystep 4

_USAGE_
}
