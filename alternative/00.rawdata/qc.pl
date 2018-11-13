#!/usr/bin/env perl
=pod
Description: Qc for metagenomic data
Arthor: Zhong wendi
Create date: 20150909
Edit date: 20151110
Edit date: 20160819
=cut
use warnings;
use strict;
use Getopt::Long;
use Cwd 'abs_path';
use File::Basename 'dirname';

## import parameter
#### default value
my ($dir, $batch, $sample_list, $host, $type, $help, $adaptor_1, $adaptor_2);
$adaptor_1 = "GATCGGAAGAGCACACGTCTGAACTCCAGTCAC";
$adaptor_2 = "GATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCGTATCATT";
$dir     = "./";
$type    = "33";
my $src_dir   = dirname($0);
#### parameters
GetOptions(
		"list|l=s"  => \$sample_list,
		"batch|b=s" => \$batch,
		"host|h=s"  => \$host,
		"dir|d=s"   => \$dir,
		"type|t=s"  => \$type,
		"help|h!"   => \$help);
&help unless defined $sample_list and -e $sample_list;
&help unless defined $batch and not defined $help;
-e $dir or system("mkdir $dir");
   $dir = abs_path($dir);
my $dir_shell  = "$dir/shell";
my $dir_raw    = "$dir/00.raw_reads";
my $dir_fastqc = "$dir/01.fastqc";
my $dir_adpt   = "$dir/02.rmadaptor";
my $dir_qc     = "$dir/03.qc";
my $dir_raw_batch    = "$dir_raw/$batch";
my $dir_fastqc_batch = "$dir_fastqc/$batch";
my $dir_adpt_batch   = "$dir_adpt/$batch";
my $dir_qc_batch     = "$dir_qc/$batch";
-d $dir_shell  or system("mkdir $dir_shell");
-d $dir_raw    or system("mkdir $dir_raw");
-d $dir_fastqc or system("mkdir $dir_fastqc");
-d $dir_adpt   or system("mkdir $dir_adpt");
-d $dir_qc     or system("mkdir $dir_qc");
-d $dir_raw_batch    or system("mkdir $dir_raw_batch");
-d $dir_qc_batch     or system("mkdir $dir_qc_batch");
-d $dir_fastqc_batch or system("mkdir $dir_fastqc_batch");
-d $dir_adpt_batch   or system("mkdir $dir_adpt_batch");
my $dir_host  = "$dir/04.rmhost";
my $dir_clean = "$dir/05.clean_reads";
my $dir_host_batch  = "$dir_host/$batch";
my $dir_clean_batch = "$dir_clean/$batch";
if (defined $host){
	-d $dir_host  or system("mkdir $dir_host");
	-d $dir_clean or system("mkdir $dir_clean");
	-d $dir_host_batch  or system("mkdir $dir_host_batch");
	-d $dir_clean_batch or system("mkdir $dir_clean_batch");
}
my $para = ($type eq "33") ? "-y" : "";

## main
#### check list and form shell
system("cp -f $sample_list $dir_raw/$batch\_sample.list; perl $src_dir/list2link.pl $sample_list $dir_raw_batch");
open IN,"$sample_list" or die $! ;
open SH,">$dir_shell/QC-$batch.sh" or die $!;
while (<IN>){
	chomp;
	@_ = split /\s+/;
	my ($sample_id,$raw_reads1,$raw_reads2) = @_;
	-e $raw_reads1 and -e $raw_reads2 or die "Raw data in the list doesn't exist!";
#	-e "$dir_fastqc_batch/$sample_id" or mkdir "$dir_fastqc_batch/$sample_id";
	if (defined $host){
		print SH "/data_center_01/pipeline/MetaGenome/v1.0/soft/FastQC/fastqc -q --extract -nogroup -o $dir_fastqc_batch $dir_raw_batch/$sample_id.1.fq.gz\n";
		print SH "/data_center_01/pipeline/MetaGenome/v1.0/soft/FastQC/fastqc -q --extract -nogroup -o $dir_fastqc_batch $dir_raw_batch/$sample_id.2.fq.gz\n";
		print SH "python $src_dir/rmAdaptor_20180110.py --type PE -r1 $dir_raw_batch/$sample_id.1.fq.gz -r2 $dir_raw_batch/$sample_id.2.fq.gz -a1 $adaptor_1 -a2 $adaptor_2 --out_prefix $dir_adpt_batch/$sample_id --out_type 2\n";
		print SH "$src_dir/QC $para -o $dir_adpt_batch/$sample_id.1.fq $dir_adpt_batch/$sample_id.2.fq $dir_qc_batch/$sample_id\n";
		print SH "soap -r 1 -p 10 -m 100 -x 1000 -a $dir_qc_batch/$sample_id.1.fq -b $dir_qc_batch/$sample_id.2.fq -D $host.index -o $dir_host_batch/$sample_id.pm -2 $dir_host_batch/$sample_id.sm\n";
		print SH "soap -r 1 -p 10 -a $dir_qc_batch/$sample_id.single.fq -D $host.index -o $dir_host_batch/$sample_id.single.m\n";
		print SH "$src_dir/rmHost.pl $dir_qc_batch $dir_clean_batch $dir_host_batch $sample_id\n";
	}else {
		print SH "/data_center_01/pipeline/MetaGenome/v1.0/soft/FastQC/fastqc -q --extract -nogroup -o $dir_fastqc_batch $dir_raw_batch/$sample_id.1.fq.gz\n";
		print SH "/data_center_01/pipeline/MetaGenome/v1.0/soft/FastQC/fastqc -q --extract -nogroup -o $dir_fastqc_batch $dir_raw_batch/$sample_id.2.fq.gz\n";
		print SH "python $src_dir/rmAdaptor_20180110.py --type PE -r1 $dir_raw_batch/$sample_id.1.fq.gz -r2 $dir_raw_batch/$sample_id.2.fq.gz -a1 $adaptor_1 -a2 $adaptor_2 --out_prefix $dir_adpt_batch/$sample_id --out_type 2\n";
		print SH "$src_dir/QC $para -o $dir_adpt_batch/$sample_id.1.fq $dir_adpt_batch/$sample_id.2.fq $dir_qc_batch/$sample_id\n";
	}
}
close IN;
close SH;
#### run shell
system("/data_center_03/USER/zhongwd/bin/qsge --queue all.q --memery 500M:500M:500M:500M:5G:5G:500M --jobs 10 --lines 7 --prefix qc $dir_shell/QC-$batch.sh") if defined $host;
system("/data_center_03/USER/zhongwd/bin/qsge --queue all.q --memery 500M:500M:500M:500M --jobs 10 --lines 4 --prefix qc $dir_shell/QC-$batch.sh") unless defined $host;
## subroutine

sub help{
	print STDERR <<"_USAGE_" and exit 1;

description: Qc for metagenomic data
usage: perl $0 [options]
options:
	--list  <string>  the list of samples.
	--batch <string>  prefix of batch.
	--host  <string>  the sequence of host genome, default is no host.
	--dir   <string>  the directory of raw reads and temperory files of qc.
	--type  <string>  the type of quality, default is "33".
	--help  <options> print this help infomation.
note:
	the sample list should be format as "sample id", "fastq file 1", "fastq file 2" with seperater "\\t".
e.g.:
	perl $0 --list sample.list -batch batch --host hg19.fna --dir 00.raw_reads --type 33

_USAGE_
}
