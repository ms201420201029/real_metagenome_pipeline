#!usr/bin/perl -w
use strict;
if ( @ARGV != 1 ){
	die "usage: <IN> > <OUT>.\n";
}
open (IN,"$ARGV[0]") 		or die "can't open file <CAGMEAN>:$!";

my $i = 0;

$/ = "<\n";
while (<IN>){
	chomp;
	my %f;
	@_ = split /\n/;
	foreach my $canopy(@_){
		my @gene = split ' ',$canopy;
		shift @gene;
		foreach my $gene(@gene){
			$f{$gene} = 1;
		}
	}
	$i++;
	print "$i";
	foreach my $gene(keys %f){
		print " $gene";
	}
	print "\n";

}
close IN;
$/ = "\n";
