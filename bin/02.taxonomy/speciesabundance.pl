#!/usr/bin/perl -w
use strict;
print "usage:\nspeciesabundance <clean_reads_list> <dir>\n" and exit unless @ARGV == 2;
my $fasta_list = $ARGV[0];
my $dir = $ARGV[1];
my @database;
my %db;
open DB,"/data_center_03/USER/zhongwd/CFG/species_database.list" or die;
while (<DB>){
	chomp;
	@_ = split /\t/;
	$db{$_[1]} = $_[0];
	push @database,$_[1];
}
close DB;
my $parse = "/data_center_01/pipeline/real_metagenome/real_metagenome_test/bin/02.taxonomy/alignment_parse.pl";
my $profile = "/data_center_01/pipeline/real_metagenome/real_metagenome_test/bin/02.taxonomy/species_abundance_profiler.pl";
-e "$dir/alignment" or mkdir "$dir/alignment";
-e "$dir/shell"     or mkdir "$dir/shell";
open SHELL1,">shell/match.sh" or die $!;
open SHELL2,">shell/abun.sh" or die $!;
open CLEAN,"$fasta_list" or die;
while (<CLEAN>){
	chomp;
	my ($name,$a,$b) = split /\s/;
	-e $a and -e $b or die "clean data $a $b doesn't exist!";
	$_ = `pwd`;
	chomp;
	my $directory = $_."/alignment/$name";
	-d $directory or `mkdir $directory`;
	open MATCH_LIST,">$directory/match.list" or die $!;
	foreach (@database){
		my $flag = "$directory/$name-$db{$_}";
		print SHELL1 "/data_center_01/soft/soap/Soap2.22/soap2.22 -a $a -b $b -D $_.index -M 4 -o $flag.pm -2 /dev/null -r 2 -p 10 -m 100 -x 1000 -S \n";
		print MATCH_LIST "PE\t$flag.pm\n";
	}
	print SHELL2 "perl $parse $directory/match.list $directory/$name.MATCH\n";
	print SHELL2 "perl $profile $directory/$name.MATCH $directory/$name.root.abundance $directory/$name.MATCH.log\n";
	close MATCH_LIST;
}
close CLEAN;
close SHELL1;
close SHELL2;
