#!/usr/bin/perl -w
# copy from /data_center_06/Project/LiuLin-ascites-stool/03.assembly/bin/scaftigs.pl

use strict;
die "perl $0 <scaffold> <cutoff> <scaftigs> <scaftigs.stat>" unless(@ARGV == 4);
my $cutoff = $ARGV[1];
my $total;
my %length;
my $length;
my $all;

open IN, "$ARGV[0]" or die $!;
$/="\>";
<IN>;
while(<IN>){
	chomp;
	@_ = split /\n/;
	my $scaffold_id = shift @_;
	   $scaffold_id =~ s/ .*//g;
	my $scaffold    = join "", @_;
	my @scaftigs    = split /N+/, $scaffold;
	my @scaftigs_id = map {$scaffold_id . "_" . $_} 1 .. scalar @scaftigs;
	foreach my $i (0 .. $#scaftigs){
		my $scaftigs_id = $scaftigs_id[$i];
		my $scaftigs    = $scaftigs[$i];
		my $length      = length $scaftigs;
		   $scaftigs    = fasta_format($scaftigs, 100);
		if ($length >= $cutoff){
			$total += $length;
			$length{"$scaftigs_id\n$scaftigs"} = $length;
		}
	$all++;
	}
}
$/="\n";
close IN;

open OT,">$ARGV[2]" or die $!;
my @name = sort {$length{$b}<=>$length{$a}} keys %length;
foreach my $seq (@name){
	print OT ">$seq";
}
close OT;

my $maxlength = $length{$name[0]};
my $minlength = $length{$name[-1]};
my $contignum = scalar @name;
my $r = $contignum / $all;
my $average = int($total/$contignum);
my $sum;
my $ratio;
my $N50;
my $N90;

foreach(@name){
	$sum += $length{$_};
	$ratio = $sum / $total;
	if (($ratio >= 0.5 and $N50 = $length{$_}) .. ($ratio >= 0.9 and $N90 = $length{$_} and last)){};
}
open STAT, ">$ARGV[3]" or die $!;
print STAT <<"_END_STAT_";
cutoff\t$cutoff
ratio\t$r
contignum\t$contignum
totallen\t$total
maxlength\t$maxlength
minlength\t$minlength
N50\t$N50
N90\t$N90
average\t$average
_END_STAT_
close STAT;

sub fasta_format {
	my ($seq, $num_in_line) = @_;
	my $nseq;
        while ($seq =~ s/(^.{$num_in_line})//g){
                $nseq .= "$1\n";
                if (length $seq == 0){
                        last;
                }
        }
        $nseq .= "$seq\n" unless (length $seq == 0);
	return $nseq;
}
