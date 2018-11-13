#!/usr/bin/env perl
=pod
Description: Metagenomic work flow part I
Author: Zhong wendi
Create date: 20151112
=cut
use warnings;
use strict;
use Getopt::Long;
use File::Basename 'dirname';

## import parameters
my ($batch_list, $config, $help);
GetOptions(
		"batch|b=s"  => \$batch_list,
		"config|c=s" => \$config,
		"help|h!"    => \$help);
&help unless defined $config and -e $config and not defined $help;
#### get config
open BTCH, "$batch_list" or die $!;
###### batch infomation
my @batch;
my %sample;
while (<BTCH>){
	chomp;
	next if (m/^#/);
	my ($batch, $sample_list, $condition) = split /\t/;
	$condition ||= "";
	die "Batch: $batch is still running! If not, please check whether it ends with error." if $condition eq "Run";
	die "Batch: $batch exists! Please check." if defined $sample{$batch};
	$sample{$batch} = $sample_list;
	unless ($condition eq "End"){
		push @batch, $batch;
	}
}
close BTCH;
###### soft parameters#
my %para;
&getpara($config, \%para);

## main
foreach my $batch (@batch){
	&refresh($batch_list, $batch, "Run");
	if(exists $para{'host'}){
		system("/data_center_01/pipeline/MetaGenome/v1.0/soft/QC_v1.0/bin/qc.pl --batch $batch $para{'dir'} --list $sample{$batch} $para{'host'} $para{'type'}");
	}else{
		print "/data_center_01/pipeline/MetaGenome/v1.0/soft/QC_v1.0/bin/qc.pl --batch $batch $para{'dir'} --list $sample{$batch} $para{'type'}"; 
		system("/data_center_01/pipeline/MetaGenome/v1.0/soft/QC_v1.0/bin/qc.pl --batch $batch $para{'dir'} --list $sample{$batch} $para{'type'}");
	}
	system("/data_center_01/pipeline/MetaGenome/v1.0/soft/QC_v1.0/bin/stat.pl --batch $batch $para{'dir'} $para{'insert'}");
	&refresh($batch_list, $batch, "End");
}

## subroutine
sub help{
	print STDERR <<"_USAGE_" and exit 1;

description: Metagenomic work flow part I
usage: perl $0 [options]
options:
	-b <string>  the batch file.
	-c <string>  the config file.
	-h <options> print this help infomation.
e.g.:
	perl $0 -b batch.tab -c config.tab -d test

_USAGE_
}

sub getpara{
	my $config = shift;
	my $para_p = shift;
	open CFG, "$config" or die $!;
	while (<CFG>){
		chomp;
		my ($key, $value) = split /\t/;
		if ($key =~ m/^#(.*)/){
			$para_p -> {$1} = "";
		}else {
			$para_p -> {$key} = "--$key $value";
		}
	}
	close CFG;
}

sub refresh{
	my $batch_file    = shift;
	my $tar_batch     = shift;
	my $new_condition = shift;
	open BTCH,   "$batch_file"     or die $!;
	open NBTCH, ">$batch_file.bak" or die $!;
	while (<BTCH>){
		chomp;
		print NBTCH "$_\n" and next if m/^#/;
		my ($batch, $sample_list, $condition) = split /\t/;
		print NBTCH "$_\n" and next unless $batch eq $tar_batch;
		print NBTCH "$batch\t$sample_list\t$new_condition\n";
	}
	system("mv -f $batch_file.bak $batch_file");
}
