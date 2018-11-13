#!/usr/bin/perl
print "usage:\nlengthfasta <fasta> > <length>\n" and exit unless scalar @ARGV == 1;
open IN,"$ARGV[0]";
$/ = ">";
<IN>;
while (<IN>){
	chomp;
	@_ = split /\n/;
	$id = shift @_;
	@id = split /\s+/,$id;
	$number = 0;
	foreach $base(@_){
		$number += length $base;
	}
	print "$id[0]\t$number\n";
}
close IN;
