#!/usr/bin/perl -w
use strict;
require "/data_center_03/USER/zhongwd/lib/math.pm";

@ARGV == 4 or die "usage: perl $0 <raw_dir> <clean_dir> <rm_dir> <sample_id>";
my $raw_dir    = $ARGV[0];
my $clean_dir  = $ARGV[1];
my $rm_dir     = $ARGV[2];
my $sample_id  = $ARGV[3];
my $qcfile1    = "$raw_dir/$sample_id.1.fq";
my $qcfile2    = "$raw_dir/$sample_id.2.fq";
my $qcfile3    = "$raw_dir/$sample_id.single.fq";
my $rmfile1    = "$rm_dir/$sample_id.pm";
my $rmfile2    = "$rm_dir/$sample_id.sm";
my $rmfile3    = "$rm_dir/$sample_id.single.m";
my $cleanfile1 = "$clean_dir/$sample_id.1.fq";
my $cleanfile2 = "$clean_dir/$sample_id.2.fq";
my $cleanfile3 = "$clean_dir/$sample_id.s.fq";

my %rminfo;
my %seq_stat;
my %qual_stat;
&get_in_mem($rmfile1,\%rminfo);
&get_in_mem($rmfile2,\%rminfo);
&get_in_mem($rmfile3,\%rminfo);
my ($host_1,$reads_num_1,$bases_num_1) = &rm_host($qcfile1,$cleanfile1,\%rminfo,\%seq_stat,\%qual_stat);
my ($host_2,$reads_num_2,$bases_num_2) = &rm_host($qcfile2,$cleanfile2,\%rminfo,\%seq_stat,\%qual_stat);
my ($host_3,$reads_num_3,$bases_num_3) = &rm_host($qcfile3,$cleanfile3,\%rminfo,\%seq_stat,\%qual_stat);
#my $seq_stat = &stat(\%seq_stat);
#my $qual_stat = &stat(\%qual_stat);
die "Error occured!\n" unless $host_1 == $host_2 or $reads_num_1 == $reads_num_2;
open LOG,">$clean_dir/$sample_id.log";
print LOG <<_LOG_;
host_in_pair-end_reads\t$host_1
host_in_single_end-reads\t$host_3
pair-end_clean_reads_number\t$reads_num_1
single-end_clean_reads_number\t$reads_num_3
pair-end_clean_bases_number_in_reads1\t$bases_num_1
pair-end_clean_bases_number_in_reads2\t$bases_num_2
single-end_clean_bases_number\t$bases_num_3
_LOG_
close LOG;
=pod
open LOG,">$clean_dir/$sample_id.seq.log";
print LOG $seq_stat;
close LOG;
open LOG,">$clean_dir/$sample_id.qual.log";
print LOG $qual_stat;
close LOG;
=cut

sub get_in_mem{
	my $match_file = shift;
	my $rminfo_p = shift;
	open IN,"$match_file" or die $!;
	while(<IN>){
		chomp;
		@_ = split /\s+/;
		shift;
		s/\/.*?$//;
		s/#.*?$//;
		s/^.*?://;
		$rminfo_p->{$_}=1;
	}
	close IN;
}

sub rm_host{
	my $raw_reads = shift;
	my $clean_reads = shift;
	my $rminfo_p = shift;
	my $seq_stat_p = shift;
	my $qual_stat_p = shift;
	my $id;
	my $seq;
	my $qual;
	my $host = 0;
	my $reads_num = 0;
	my $bases_num = 0;
	open RAW, "$raw_reads" or die $!;
	open CLN, ">$clean_reads" or die $!;
	while(<RAW>){
		chomp;
		$id = $_;
		s/\/.*?$//;
		s/#.*?$//;
		s/^.*?://;
		if( exists $rminfo_p->{$_} ){
			<RAW>;<RAW>;<RAW>;
			$host++;
		} else {
			print CLN "$id\n";
			$seq  = <RAW>;
				<RAW>;
			$qual = <RAW>;
#			&count(&splitbysemicolon($seq),$seq_stat_p);
#			&count(&char2ord($qual),$qual_stat_p);
			print CLN $seq;
			print CLN "+\n";
			print CLN $qual;
			$reads_num++;
			$bases_num += length($seq);
		}
	}
	close RAW;
	close CLN;
	return ($host,$reads_num,$bases_num);
}

sub count{
	my $seq = shift;
	chomp $seq;
	my @seq = split /,/,$seq;
	my $stat_p = shift;
	foreach my $i(0 .. $#seq){
		$stat_p->{$seq[$i]}{$i}++;
	}
}

sub stat{
	my $stat_p = shift;
	my %pos_pool;
	my $stat;
	foreach my $char(keys %$stat_p){
		foreach my $pos(keys %{$stat_p->{$char}}){
			$pos_pool{$pos} = 1;
		}
	}
	my @pos_pool = sort {$a <=> $b} keys %pos_pool;
	foreach my $pos(@pos_pool){
		$stat .= "\t$pos";
	}
	$stat .= "\n";
	my @char_pool = (exists $stat_p->{"A"})? sort bymethod keys %$stat_p : min(keys %$stat_p) .. max(keys %$stat_p);
	foreach my $char(@char_pool){
		$stat .= "$char";
		foreach my $pos(@pos_pool){
			my $num = 0;
			$num = $stat_p->{$char}{$pos} if exists $stat_p->{$char}{$pos};
			$stat .= "\t$num";
		}
		$stat .= "\n";
	}
	return $stat;
}

sub bymethod{
	my %order = (
		"A" => 1,
		"T" => 2,
		"C" => 3,
		"G" => 4,
		"N" => 5);
	return $order{$a} <=> $order{$b};
}

sub char2ord{
	my $seq = shift;
	chomp $seq;
	my @seq = split //,$seq;
	foreach my $char(@seq){
		$char = sprintf("%02d",ord($char)-33);
	}
	$seq = join ",",@seq;
	return $seq;
}

sub splitbysemicolon{
	my $seq = shift;
	chomp;
	my @seq = split //,$seq;
	$seq = join ",",@seq;
	return $seq;
}
