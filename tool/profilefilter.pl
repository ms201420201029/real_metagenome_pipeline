#!/usr/bin/perl
unless (scalar @ARGV == 3 and $ARGV[1] < 1 ) {
	print "usage:\n$0 <profile> <cutoff> <group.list> > <profile>\n" and exit;
}
$cutoff = $ARGV[1];
require "/data_center_03/USER/zhongwd/lib/math.pm";
open IN,"$ARGV[2]" or die $!;
@_ = <IN>;
%group = map {chomp; split /\t/} @_;
#%group_pool = reverse %group;
close IN;
open IN, "$ARGV[0]" or die $!;
$_ = <IN>;
print;
chomp;
@sample = split /\t/;
shift @sample if $sample[0] eq "";
foreach $i (0 .. $#sample) {
	push @{$belong{"$group{$sample[$i]}"}}, $i;
}
while (<IN>){
	chomp;
	@_ = split /\t/;
	shift @_;
	foreach $group (keys %belong) {
		$median = median(@_[@{$belong{$group}}]);
		print "$_\n" and last if $median > $cutoff;
	}
}
close IN;
