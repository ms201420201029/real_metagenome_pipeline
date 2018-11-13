#!/usr/bin/env perl
=pod
Description: Accumulated curve and shared curve of profile
Author: Zhong wendi
Create date: 20151030
=cut
use warnings;
use strict;
use Getopt::Long;
use File::Basename 'dirname';
use List::Util qw(shuffle);

my ($profile, $class, $times, $step, $run, $help);
GetOptions(
		"profile|p=s" => \$profile,
		"class|c=s"   => \$class,
		"times|t=i"   => \$times,
		"step|s=i"    => \$step,
		"help|h!"     => \$help);
&help unless defined $profile and -e $profile and defined $class and not defined $help;
my $src_dir     = dirname($0);
# my $Rscript_dir = $src_dir . "/Rscript";
my $Rscript_dir = $src_dir;

## subsets of samples
open PRF, "$profile" or die $!;
my $samples = <PRF>;
chomp $samples;
my @samples = split /\t/, $samples;
shift @samples if $samples[0] eq "";
$step = self_adjust(scalar @samples) unless defined $step;
my @size_pool = sizepool($step, scalar @samples);
my @allset = 1 .. scalar @samples;
my %subset_pool;
open SIZE, ">$profile.subset.tab" or die $!;
foreach my $size (@size_pool){
	foreach my $time (1 .. $times){
		my @subset = subset(\@allset, $size);
		$subset_pool{$size}[$time] = \@subset;
		print SIZE "$size\_$time\t" . (join "\t", @subset) . "\n";
	}
}
close SIZE;

## accumulate and share
my %accum;
my %share;
while (<PRF>){
	chomp;
	my @abun = split /\t/;
	foreach my $size (@size_pool){
		foreach my $time (1 .. $times){
			my @accum_share =  accum_share(@abun[@{$subset_pool{$size}[$time]}]);
			$accum{$size}[$time] += $accum_share[0];
			$share{$size}[$time] += $accum_share[1];
		}
	}
}
close PRF;
open ACUMM, ">$profile.accum.tab" or die $!;
foreach my $size (@size_pool){
	print ACUMM "\t$size";
}
print ACUMM "\n";
foreach my $time (1 .. $times){
	print ACUMM $time;
	foreach my $size (@size_pool){
		print ACUMM "\t$accum{$size}[$time]";
	}
	print ACUMM "\n";
}
close ACUMM;
open SHARE, ">$profile.share.tab" or die $!;
foreach my $size (@size_pool){
	print SHARE "\t$size";

}
print SHARE "\n";
foreach my $time (1 .. $times){
	print SHARE $time;
	foreach my $size (@size_pool){
		print SHARE "\t$share{$size}[$time]";
	}
	print SHARE "\n";
}
close SHARE;

## draw accumulated curve and shared curve
system("Rscript $Rscript_dir/Accumulated_Shared_Curve.R $profile $class");
system("convert $profile.accum_share.pdf $profile.accum_share.png");

sub self_adjust{
	my $number = shift;
	my @step_pool = (1, 2, 3, 5, 10, 20, 30, 50, 100, 200);
	my $step_final;
	foreach my $step (@step_pool){
		$step_final = $step;
		last if $number / $step <= 15;
	}
	return $step_final;
}

sub sizepool{
	my $step = shift;
	my $number = shift;
	my $size = $step;
	my @size_pool = ();
	while ($size <= $number){
		push @size_pool, $size;
		$size += $step;
	}
	unshift @size_pool, 1 unless $step == 1;
	return @size_pool;
}

sub subset{
	my $samples_p = shift;
	my $size      = shift;
	my @reorder = shuffle(@{$samples_p});
	return sort {$a <=> $b} @reorder[0 .. $size - 1];
}

sub accum_share{
	my $accum = 0;
	my $share = 1;
	foreach my $abun(@_){
		if ($abun == 0){
			$share = 0;
			last if $accum == 1;
		}else {
			$accum = 1;
			last if $share == 0;
		}
	}
	return ($accum, $share);
}

sub help{
	print STDERR <<"_USAGE_" and exit 1;

description: Accumulated curve and shared curve of profile
usage: perl $0 [options]
options:
	-p <string>  profile.
	-c <string>  class of profile, it will be shown on the picture.
	-t <integer> times of sampling the subset of samples for each samples size.
	-s <integer> step of samples size, default is slef-adjusted to make sure that number of gradients is smaller than 16.
	-h <options> print this help infomation.
e.g.:
	perl $0 -p profile -c gene -t 100 -s 1

_USAGE_
}
