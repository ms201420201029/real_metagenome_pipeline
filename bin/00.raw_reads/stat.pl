#!/usr/bin/env perl
=pod
Description: Stat after qc
Author: Zhong wendi
Create date: 20151105
Edit date: 20160819
=cut
use warnings;
use strict;
use Getopt::Long;
use Cwd 'abs_path';
use File::Basename 'dirname';

## import parameters
my ($batch, $dir_raw, $insert_size, $help);
#### default value
$dir_raw     = "./";
#### parameters
GetOptions(
		"batch|b=s"   => \$batch,
		"dir_raw|d=s" => \$dir_raw,
		"insert|i=s"  => \$insert_size,
		"help|h!"     => \$help);
&help unless defined $batch and not defined $help;
&help unless defined $dir_raw and -d $dir_raw;
   $dir_raw     = abs_path($dir_raw);
my $dir_project = dirname(abs_path($dir_raw));
#my $dir_clean   = "$dir_project/01.clean_reads";
#-d $dir_clean or system("mkdir $dir_clean");


## check fastqc
-d "$dir_raw/fastqc_result" or mkdir "$dir_raw/fastqc_result";
-d "$dir_raw/fastqc_result/per_base_sequence_content" or mkdir "$dir_raw/fastqc_result/per_base_sequence_content";
-d "$dir_raw/fastqc_result/per_base_quality" or mkdir "$dir_raw/fastqc_result/per_base_quality";
-d "$dir_raw/fastqc_result/WARN" or mkdir "$dir_raw/fastqc_result/WARN";
-d "$dir_raw/fastqc_result/FAIL" or mkdir "$dir_raw/fastqc_result/FAIL";
#### copy result
my %fastqc_entry = ("Per base sequence quality"    => "per_base_n_content.png",
		    "Per tile sequence quality"    => "per_tile_quality.png",
		    "Per sequence quality scores"  => "per_sequence_quality.png",
		    "Per base sequence content"    => "per_base_sequence_content.png",
		    "Per sequence GC content"      => "per_sequence_gc_content.png",
		    "Per base N content"           => "per_base_n_content.png",
		    "Sequence Length Distribution" => "sequence_length_distribution.png",
		    "Sequence Duplication Levels"  => "duplication_levels.png",
		    "Overrepresented sequences"    => "duplication_levels.png",
		    "Adapter Content"              => "adapter_content.png",
		    "Kmer Content"                 => "kmer_profiles.png");
open IN, "$dir_raw/00.raw_reads/$batch/$batch\_sample.list" or die $!;
while (<IN>) {
	chomp;
	my ($sample, $fq1, $fq2) = split /\t/;
	if ($fq1 =~ /\_R1\.*/){
		system("cp $dir_raw/01.fastqc/$batch/$sample.1_fastqc/Images/per_base_sequence_content.png $dir_raw/fastqc_result/per_base_sequence_content/$sample.1.fq_per_base_sequence_content.png");
		system("cp $dir_raw/01.fastqc/$batch/$sample.1_fastqc/Images/per_base_quality.png $dir_raw/fastqc_result/per_base_quality/$sample.1.fq_per_base_quality.png");
		system("cp $dir_raw/01.fastqc/$batch/$sample.2_fastqc/Images/per_base_sequence_content.png $dir_raw/fastqc_result/per_base_sequence_content/$sample.2.fq_per_base_sequence_content.png");
		system("cp $dir_raw/01.fastqc/$batch/$sample.2_fastqc/Images/per_base_quality.png $dir_raw/fastqc_result/per_base_quality/$sample.2.fq_per_base_quality.png");
	}else{
		$fq1 =~ s/.*\/(.*?).gz$/$1/g;
		$fq2 =~ s/.*\/(.*?).gz$/$1/g;
		system("cp $dir_raw/01.fastqc/$batch/$sample.1_fastqc/Images/per_base_sequence_content.png $dir_raw/fastqc_result/per_base_sequence_content/$fq1\_per_base_sequence_content.png");
		system("cp $dir_raw/01.fastqc/$batch/$sample.1_fastqc/Images/per_base_quality.png $dir_raw/fastqc_result/per_base_quality/$fq1\_per_base_quality.png");
		system("cp $dir_raw/01.fastqc/$batch/$sample.2_fastqc/Images/per_base_sequence_content.png $dir_raw/fastqc_result/per_base_sequence_content/$fq2\_per_base_sequence_content.png");
		system("cp $dir_raw/01.fastqc/$batch/$sample.2_fastqc/Images/per_base_quality.png $dir_raw/fastqc_result/per_base_quality/$fq2\_per_base_quality.png");
	}
	for my $i (1 .. 2) {
		open SU, "$dir_raw/01.fastqc/$batch/$sample.$i\_fastqc/summary.txt" or die $!;
		while (<SU>) {
			chomp;
			my ($res, $entry) = split /\t/;
			if ($res eq "WARN" or $res eq "FAIL"){
				system("cp $dir_raw/01.fastqc/$batch/$sample.$i\_fastqc/summary.txt $dir_raw/fastqc_result/$res/$sample\_$batch\_$i\_summary.txt -f");
				system("cp $dir_raw/01.fastqc/$batch/$sample.$i\_fastqc/fastqc_data.txt $dir_raw/fastqc_result/$res/$sample\_$batch\_$i\_fastqc_data.txt -f");
				system("cp $dir_raw/01.fastqc/$batch/$sample.$i\_fastqc/Images/$fastqc_entry{$entry} $dir_raw/fastqc_result/$res/$sample\_$batch\_$i\_$fastqc_entry{$entry} -f");
			}
		}
	}
}
## get stat
#### insert size
my @stat_file = map {m/(.*)\n$/} readpipe("cat $insert_size");
print "tttttttttttttttttttt\n";
print "@stat_file\n";

my %ins = map {split /\t/} @stat_file;
#### raw stat
my %info;
my %batch_pool;
@stat_file = map {m/(.*)\n$/} readpipe("ls $dir_raw/01.fastqc/*/*.1_fastqc/fastqc_data.txt");
foreach my $stat (@stat_file){
	my ($batch, $sample) = $stat =~ m/01.fastqc\/(.*)\/(.*).1_fastqc\/fastqc_data.txt$/;
	my ($raw_reads, $reads_len) = map {m/(.*)\n$/} readpipe("sed -n '7p;9p;10q' $stat|cut -f 2");
	$info{$sample}{$batch}{'raw_reads'} = $raw_reads;
	$info{$sample}{$batch}{'reads_len'} = $reads_len;
	$info{$sample}{$batch}{'raw_bases'} = 2 * $raw_reads * $reads_len;
	$batch_pool{$batch} = 1;
}
#### rmadpt stat
#@stat_file = map {m/(.*)\n$/} readpipe("ls $dir_raw/02.rmadaptor/*/*_adaptor_statistical.tsv");
#foreach my $stat (@stat_file){
#	my ($batch) = $stat =~ m/02.rmadaptor\/(.*)\/.*_adaptor_statistical.tsv$/;
#	my ($sample, undef, $rmadpt_reads) = map {chomp; split /\t/} readpipe("tail -1 $stat");
#	$info{$sample}{$batch}{'rmadpt_reads'} = $rmadpt_reads;
#}
#### qc stat
@stat_file = map {m/(.*)\n$/} readpipe("ls $dir_raw/03.qc/*/*.stat");
foreach my $stat (@stat_file){
	my ($batch, $sample) = $stat =~ m/03.qc\/(.*)\/(.*).stat$/;
	my ($rmadpt_reads, $qc_pe_reads, $qc_pe_bases) = map {m/(.*)\n$/} readpipe("sed -n '1p;4,5p' $stat|cut -f 2");
	$info{$sample}{$batch}{'rmadpt_reads'} = $rmadpt_reads;
	$info{$sample}{$batch}{'qc_pe_reads'}  = $qc_pe_reads;
	$info{$sample}{$batch}{'qc_pe_bases'}  = $qc_pe_bases;
}
#### host stat
if (-e "$dir_raw/05.clean_reads/"){
	my @stat_file = map {m/(.*)\n$/} readpipe("ls $dir_raw/05.clean_reads/*/*.log");
	foreach my $stat (@stat_file) {
		my ($batch, $sample) = $stat =~ m/05.clean_reads\/(.*)\/(.*).log$/;
		my ($clean_reads, $clean_bases1, $clean_bases2) = map {m/(.*)\n$/} readpipe("sed -n '3p;5p;6p' $stat|cut -f 2");
		$info{$sample}{$batch}{'clean_reads'} = $clean_reads;
		$info{$sample}{$batch}{'clean_bases'} = $clean_bases1 + $clean_bases2;
	}
}else {
	foreach my $sample (keys %info){
		foreach my $batch (keys %{$info{$sample}}){
			$info{$sample}{$batch}{'clean_reads'} = $info{$sample}{$batch}{'qc_pe_reads'};
			$info{$sample}{$batch}{'clean_bases'} = $info{$sample}{$batch}{'qc_pe_bases'};
		}
	}
}

## form table
#### batch table
my %gzip;
my @batch_arr = sort keys %batch_pool;
open TAB, ">$dir_raw/batch_$batch.tsv" or die $!;
foreach my $batch (@batch_arr){
	print TAB "\t$batch";
}
print TAB "\ttotal size(bp)\n";
foreach my $sample (sort keys %info){
	print TAB $sample;
	my $sum;
	foreach my $batch (@batch_arr){
		if (exists $info{$sample}{$batch}){
			$sum += $info{$sample}{$batch}{'qc_pe_bases'};
			my $size = &format_num($info{$sample}{$batch}{'qc_pe_bases'}, "longint");
			print TAB "\t$size";
		}else {
			print TAB "\t";
		}
	}
#	my $remain = ($sum / 1E9 < $target_size) ? sprintf("%.1f", $target_size - $sum / 1E9) : "";
#	$gzip{$sample} = 1 if $sum / 1E9 > $target_size;
	$sum = &format_num($sum, "longint");
	print TAB "\t$sum\n";
}
close TAB;
#### qc stat table
my %batch_seq;
open LOG, ">$dir_raw/qc_$batch.stat.tsv" or die $!;
print LOG "Sample id\tAdaptor(%)\tLow quality(%)\tHost(%)\tClean reads(#)\tClean bases(bp)\tData use rate(%)\n";
foreach my $sample (sort keys %info){
	my ($raw_reads, $rmadpt_reads, $qc_pe_reads, $clean_reads, $clean_bases, @batch_pool);
	foreach my $batch (sort {$info{$sample}{$b}{'clean_bases'} <=> $info{$sample}{$a}{'clean_bases'}} keys %{$info{$sample}}){
		$raw_reads    += $info{$sample}{$batch}{'raw_reads'};
		$rmadpt_reads += $info{$sample}{$batch}{'rmadpt_reads'};
		$qc_pe_reads  += $info{$sample}{$batch}{'qc_pe_reads'};
		$clean_reads  += $info{$sample}{$batch}{'clean_reads'};
		$clean_bases  += $info{$sample}{$batch}{'clean_bases'};
		push @batch_pool, $batch;
#		last if ($abandon eq "y" and $clean_bases > $target_size);
	}
	my $adaptor  = ($raw_reads - $rmadpt_reads) / $raw_reads;
	my $low_qual = ($rmadpt_reads - $qc_pe_reads) / $raw_reads;
	my $host     = ($qc_pe_reads - $clean_reads) / $raw_reads;
	my $use_rate = $clean_reads / $raw_reads;
	$batch_seq{$sample} = join ",", @batch_pool;
	my @stat = ($sample,					## Sample id
		    &format_num($adaptor, "ratio"),		## Adaptor
		    &format_num($low_qual, "ratio"),		## Low quality
		    &format_num($host, "ratio"),		## Host
		    &format_num($clean_reads, "longint"),	## Clean reads
		    &format_num($clean_bases, "longint"),	## Clean bases
		    &format_num($use_rate, "ratio"),		## Data use rate
		    $batch_seq{$sample});
	print LOG (join "\t", @stat) . "\n";
}
close LOG;
#### raw reads table
open TAB, ">$dir_raw/raw_reads_$batch.stat.tsv" or die $!;
print TAB "Sample id\tReads length(bp)\tInsert size(bp)\tRaw reads(#)\tRaw bases(bp)\n";
foreach my $sample (sort keys %info){
	my ($reads_len, $raw_reads, $raw_bases);
	my @batch = split /,/, $batch_seq{$sample};
	foreach my $batch (@batch){
		$reads_len  = $info{$sample}{$batch}{'reads_len'};
		$raw_reads += $info{$sample}{$batch}{'raw_reads'};
		$raw_bases += $info{$sample}{$batch}{'raw_bases'};
	}
	my @stat = ($sample,
		    $reads_len,
		    $ins{$sample},
		    &format_num($raw_reads, "longint"),
		    &format_num($raw_bases, "longint"));
	print TAB (join "\t", @stat) . "\n";
}
close TAB;

## subroutine
sub help{
	print STDERR <<"_USAGE_" and exit 1;

description: Stat after qc
usage: perl $0 [options]
options:
	--batch   -b <string>  prefix of batch.
	--dir_raw -d <string>  the directory of raw reads and temperory files of qc.
	--insert  -i <string>  the insert data size of samples.
	--help    -h <options> print this help infomation.
e.g.:
	perl $0 --batch test --dir_raw 00.raw_reads --insert ins.list

_USAGE_
}

sub format_num{
	my ($num, $format) = @_;
	if     ($format eq "longint"){
		$num =~ s/(\d+?)(?=(\d{3})+$)/$1,/g;
	}elsif ($format eq "ratio"){
		$num = sprintf ("%.2f", $num * 100) . "%";
	}
	return $num;
}
