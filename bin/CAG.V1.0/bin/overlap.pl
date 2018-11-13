#!usr/bin/perl -w
use strict;
if ( @ARGV != 4 ){
	die "usage: <CAG> <GENE> <ZERO> <OVERLAP>.\n";
}
open (CAG,"$ARGV[0]") 			or die "can't open file <CAG>:$!";
open (GENE,"$ARGV[1]") 			or die "can't open file <GENE>:$!";
open (ZERO,">$ARGV[2]") 		or die "can't open file <ZERO>:$!";
open (OVERLAP,">$ARGV[3]") 		or die "can't open file <OVERLAP>:$!";

my @gene;
my %gene;
my $line;

while (<CAG>){
	chomp;
	@gene = split ' ', $_;
	$line = shift @gene;
	foreach (@gene){
		if ( defined $gene{$_} ){
			$gene{$_} .= " $line";
		} else {
			$gene{$_} = "$line";
		}
	}
}
close CAG;
while (<GENE>){
	chomp;
	if ( ! defined $gene{$_} ){
		print ZERO "$_\n";
	} elsif ( $gene{$_} =~ / / ){
		print OVERLAP "$_ $gene{$_}\n";
	}
}
close GENE;
close ZERO;
close OVERLAP;
