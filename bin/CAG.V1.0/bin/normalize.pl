#!usr/bin/perl -w
use strict;
if ( @ARGV != 1 ){
	die "usage: <ABUN> > <OUT>.\n";
}
open (ABUN,"$ARGV[0]")	or die "can't open file <ABUN>:$!";

my @abun;
my $abun_id;
my $i;
my $sum;
my $sum2;
my $ave;
my $var;
my $abun;

while (<ABUN>){
	chomp;
	@abun = split " ",$_;
	$abun_id = shift @abun;
	$sum = $sum2 = 0;
	foreach $i(0 .. $#abun){
		$sum += $abun[$i];
		$sum2 += $abun[$i] * $abun[$i];
	}
	$ave = $sum / scalar @abun;
	$var = sqrt( $sum2 / scalar(@abun) - $ave * $ave );
	print ("$abun_id");
	foreach $i (0 .. $#abun){
		$abun = ( $abun[$i] - $ave ) / $var;
		print " $abun";
	}
	print ("\n");
}
close ABUN;
