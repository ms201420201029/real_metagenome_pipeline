#!usr/bin/perl -w
use strict;
if ( @ARGV != 2 ){
	die "usage: <LINE> <CANOPY> > <OUT>.\n";
}
open (LINE,"$ARGV[0]") 			or die "can't open file <LINE>:$!";
open (CANOPY,"$ARGV[1]") 		or die "can't open file <CANOPY>:$!";

my @canopy;
my $line;
my @line;

while (<CANOPY>){
	@_ = split ' ', $_;
	$line = shift @_;
	$canopy[$line] = $_;
}
close CANOPY;
while (<LINE>){
	chomp;
	@line = split ' ', $_;
	foreach (@line){
		print "$canopy[$_]";
	}
	print "<\n";
}
close LINE;
