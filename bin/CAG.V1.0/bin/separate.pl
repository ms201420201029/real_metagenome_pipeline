#!usr/bin/perl -w
use strict;
if ( @ARGV != 3 ){
	die "usage: <OVERLAPMEAN> <OVERLAPINFO> <CAGMEAN> > <OUT>.\n";
}
open (OVERLAPMEAN,"$ARGV[0]")		or die "can't open file <OVERLAPMEAN>:$!";
open (OVERLAPINFO,"$ARGV[1]")		or die "can't open file <OVERLAPINFO>:$!";
open (CAGMEAN,"$ARGV[2]")		or die "can't open file <CAGMEAN>:$!";

sub pcc {
	my @a = @{$_[0]};
	my @b = @{$_[1]};
	my $j;
	my $sample_number = scalar @a;
	my $sum = 0;
	for ( $j = 0; $j < $sample_number; $j++ ){
		$sum += $a[$j] * $b[$j];
	}
	return $sum / $sample_number;
}

my @cag_abun;
my $line;
my @cag_list;
my @gene_abun;
my $gene_id;
my @line;
my $maxpcc;
my $marker;
my $pcc;

while (<CAGMEAN>){
	chomp;
	@cag_abun = split ' ', $_;
	$line = shift @cag_abun;
	$cag_list[$line] = $_;
}
close CAGMEAN;
while (<OVERLAPMEAN>){
	@gene_abun = split ' ', $_;
	$gene_id = shift @gene_abun;
	$_ = <OVERLAPINFO>;
	@line = split ' ', $_;
	shift @line;
	$maxpcc = -1;
	$marker = 0;
	foreach $line(@line){
		@cag_abun = split ' ',$cag_list[$line];
		shift @cag_abun;
		if ( ( $pcc = &pcc ( \@cag_abun, \@gene_abun ) ) > $maxpcc ){
			$maxpcc = $pcc;
			$marker = $line;
		}
	}
	print ("$gene_id $marker\n");
}
close OVERLAPMEAN;
close OVERLAPINFO;
