#!usr/bin/perl -w
use strict;
if ( @ARGV != 2 ){
	die "usage: <OVERLAPINFO> <CAG> > <OUT>.\n";
}
open (OVERLAPINFO,"$ARGV[0]")		or die "can't open file <OVERLAPINFO>:$!";
open (CAG,"$ARGV[1]")			or die "can't open file <CAG>:$!";

my $gene;
my $line;
my %line;
my @gene;

while (<OVERLAPINFO>){
	chomp;
	( $gene, $line ) = split ' ', $_;
	$line{$gene} = $line;
}
close OVERLAPINFO;
while (<CAG>){
	chomp;
	@gene = split ' ', $_;
	$line = shift @gene;
	print "$line";
	foreach (@gene){
		if ( ! defined $line{$_} ){
			print " $_";
		} elsif ( $line == $line{$_} ){
			print " $_";
		}
	}
	print "\n";
}
close CAG;
