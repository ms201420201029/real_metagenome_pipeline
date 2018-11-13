#!/usr/bin/perl
use strict;
die "perl $0 <IN> <OT>" unless @ARGV == 2;


open OT,">$ARGV[1]" or die;
print OT "Sample name\tNumber of genes(#)\tShannon-wiener index\tSimpson index\n";
open IN,"$ARGV[0]" or die;
my $head = <IN>; chomp $head;
my @sample = split /\t/, $head;
shift @sample if $sample[0] == "";

my @gene_num;
my @shannon;
my @simpson;
while (<IN>){
	chomp;
	my @abun = split /\t/;
	shift @abun;
	foreach my $i (0 .. $#abun){
		my $abun = $abun[$i];
		if ($abun > 0){
			$shannon[$i] += -$abun * log($abun);
			$simpson[$i] += -$abun ** 2;
			$gene_num[$i] ++;
		}else{
			$shannon[$i] += 0;
			$simpson[$i] += 0;
			$gene_num[$i] += 0;
		}
	}
}
close IN;

foreach my $i (0 .. $#sample){
	$simpson[$i] = 1 + $simpson[$i];
	$gene_num[$i] =~ s/(\d+?)(?=(\d{3})+$)/$1,/g;
	print OT "$sample[$i]\t$gene_num[$i]\t$shannon[$i]\t$simpson[$i]\n";
}
