#!/usr/bin/perl
print "usage:\ncutfasta <fasta> <pieces> > <list>\n" and exit unless scalar @ARGV == 2;
use warnings;
use strict;
my $file = $ARGV[0];
my $pieces = $ARGV[1];
my $number = `wc -l $file|cut -d ' ' -f 1`;
@_ = split /\./,$file;
my $suffix = pop @_;
my $prefix = join '.', @_;
$/ = ">";
my $id = 0;
my $fid;
$fid = sprintf "%02d", $id if ($pieces <= 100);
$fid = sprintf "%03d", $id if ($pieces > 100);
open IN,"$file";
$file =~ m/([^\/]*)$/;
my $name = $1;
`mkdir $prefix.split`;
open OUT,">$prefix.split/$name$fid";
$file = `list $prefix.split/$name$fid`;
print "$file";
<IN>;
my $count = 0;
while (<IN>){
	chomp;
	@_ = split /\n/;
	$count += scalar @_;
	if ($count * $pieces > $number){
		$id++;
		$fid = sprintf "%02d", $id if ($pieces <= 100);
		$fid = sprintf "%03d", $id if ($pieces > 100);
		close OUT;
		open OUT,">$prefix.split/$name$fid";
		$file = `list $prefix.split/$name$fid`;
		print "$file";
		$count = 0;
	}
	print OUT ">$_";
}
close OUT;
close IN;
