#!usr/bin/perl -w
use strict;
open (OVERLAP,"$ARGV[0]") or die $!;
open (GENE,"$ARGV[1]") or die $!;
while (<OVERLAP>){
	chomp;
	my $gene=$_;
	while (<GENE>){
		if (/^\b$gene\b/){
			print $_;
			last;
		}
	}
}
close OVERLAP;
close GENE;
