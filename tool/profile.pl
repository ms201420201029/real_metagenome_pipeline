#!/usr/bin/perl -w
use strict;
print "usage:\nprofile <list> > <profile>\n" and exit unless scalar @ARGV == 1;
my %f;
my @sample;
my $sample;
my $name;
my $abun;
open LIST,"$ARGV[0]";
while(<LIST>){
	chomp;
	open IN, "$_" or die $!;
	#s/\.[^\.]*\.abundance$//g;
	s/^.*\///g;
	s/\..*//g;
	#s/-/./g;
	$sample = $_;
	push @sample, $sample;
	while (<IN>){
		chomp;
		@_ = split /\t/;
		$name = $_[0];
		$abun = $_[-1];
		$f{$name}{$sample} = $abun;
	}
}
close LIST;
#@sample =sort byname @sample;
foreach $sample(@sample){
	print "\t$sample";
}
print "\n";
foreach $name(sort keys %f){
	print $name;
	foreach $sample(@sample){
		if (exists $f{$name}{$sample}){
			print "\t$f{$name}{$sample}";
		}else {
			print "\t0";
		}
	}
	print "\n";
}
sub byname{
	$a =~ m/(.*[^0-9])/;
	my $pa = $1;
	$a =~ m/[^0-9]([0-9]*)$/;
	my $fa = $1;
	$b =~ m/(.*[^0-9])/;
	my $pb = $1;
	$b =~ m/[^0-9]([0-9]*)$/;
	my $fb = $1;
	$pb cmp $pa or $fa <=> $fb;
}
