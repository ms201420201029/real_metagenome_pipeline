#!/usr/bin/perl -w
use strict;
print "usage:\ngeneabundance <clean_reads_list> <db_fasta_list> <gene_length> <dir>\n" and exit unless (@ARGV == 4);
my $fasta_list = $ARGV[1];
my $length_file = $ARGV[2];
my $dir  = $ARGV[3];
my @database;
my %db;
my $dir_tmp = `pwd`;
chomp $dir_tmp;
$fasta_list = $dir_tmp . "/" . $fasta_list;
$fasta_list =~ m/\/([^\/]*)$/;
$db{$fasta_list} = $1;
@database = ($fasta_list);
my $main	= "/data_center_03/USER/zhongwd/bin/gene_abundance/alignment_parse.pl";
my $parse	= "/data_center_03/USER/zhongwd/bin/gene_abundance/gene_abundance_profiler.pl";
   $dir = `readlink -f $dir`;
chomp $dir;
-e "$dir/alignment" or `mkdir $dir/alignment`;
-e "$dir/shell"     or `mkdir $dir/shell`;
open CLEAN,"$ARGV[0]" or die;
open SHELL1,">$dir/shell/match.sh" or die $!;
open SHELL2,">$dir/shell/abun.sh"  or die $!;
while (<CLEAN>){
	chomp;
	my ($name,$a,$b) = split /\s+/;
	-e $a and -e $b or die "clean data $a $b doesn't exist!";
	my $directory = "$dir/alignment/$name";
	if (! -d $directory) {`mkdir $directory`};
	open MATCH_LIST,">$directory/match.list" or die $!;
	foreach (@database){
		my $flag = "$directory/$name-$db{$_}";
		print SHELL1 "soap -a $a -b $b -D $_.index -M 4 -o $flag.pm -2 $flag.sm -r 2 -p 10 -m 100 -x 1000\n";
		print MATCH_LIST "PE\t$flag.pm\nSE\t$flag.sm\n";
	}
	print SHELL2 "perl $main $directory/match.list $directory/$name.MATCH\n";
	print SHELL2 "perl $parse $length_file $directory/$name.MATCH $directory/$name.gene.abundance $directory/$name.MATCH.log Dusko\n";
	close MATCH_LIST;
}
close CLEAN;
close SHELL1;
close SHELL2;
