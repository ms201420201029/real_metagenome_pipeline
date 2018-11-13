#!usr/bin/perl -w
use strict;
if ( @ARGV != 2 ){
	die "usage: <CANOPY> <GENE> > <OUT>.\n";
}
open (CANOPY,"$ARGV[0]")	or die "can't open file <CANOPY>:$!";
open (GENE,"$ARGV[1]")		or die "can't open file <GENE>:$!";

my @abun;
my $gene;
my %abun;
my @gene;
my $number;
my $i;
my $sample_number;
my @abun_sum;
my @abun_mean;

my $sample = <GENE>;
$sample_number = scalar split ' ',$sample;
while (<GENE>){
	chomp;
	@abun = split ' ', $_;
	$gene = shift @abun;
	$abun{$gene} = $_;
}
close GENE;
while (<CANOPY>){
	chomp;	
	@gene = split ' ', $_;
	$number = shift @gene;
	for ( $i = 0; $i < $sample_number; $i++ ){
                $abun_sum[$i] = 0;
        }
	foreach $gene(@gene){
		@abun = split ' ', $abun{$gene};
		shift @abun;
		for ( $i = 0; $i < $sample_number; $i++ ){
			$abun_sum[$i] += $abun[$i];
		}
	}
	for ( $i = 0; $i < $sample_number; $i++ ){
		$abun_mean[$i] = $abun_sum[$i] / ( $#gene + 1 );
	}
	print "$number";
	for ( $i = 0; $i < $sample_number; $i++ ){
		print " $abun_mean[$i]";
	}
	print "\n";
}
close CANOPY;
