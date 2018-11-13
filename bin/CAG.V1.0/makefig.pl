#!/usr/bin/perl/ -w

use strict;
use warnings;
use Getopt::Long;
use Cwd 'abs_path';
#========================================
#Get Options
#========================================
my ($in1,$in2,$in3,$out);

GetOptions(
	"help|?"=>\&USAGE,
	"in1:s"=>\$in1,
	"in2:s"=>\$in2,
	"in3:s"=>\$in3,
	"out:s"=>\$out,
	) or &USAGE;
&USAGE unless ($out);
&USAGE unless ($in1);
&USAGE unless ($in2);
&USAGE unless ($in3);
#========================================
#Global value
#========================================
open IN,"$in1" or die $!;
open (OUT,">$out") or die $!;
my $num = 0;
my $WorkDir = abs_path(`dirname $in1`);chomp $WorkDir;
while (<IN>){
	chomp;
	$num += 1;
	my $dir = "$WorkDir/$num";
	mkdir $dir;
	my $cut = "$num"."p";
	print OUT "sed -n \"$cut\" $in1|sed 's/ /\\n/g' |sed '1d' >$dir/gene.cag\n";
	print OUT "/data_center_03/USER/zhongwd/bin/list2profile $dir/gene.cag $in2 > $dir/CAG.gene.profile\n";
	print OUT "Rscript /home/liulf/real_metagenome_test/bin/CAG.V1.0/heatmap.R $in3 $dir/CAG.gene.profile $dir/$num.CAG.pdf\n";
	print OUT "convert -density 300 $dir/$num.CAG.pdf $dir/$num.CAG.png\n";
}
close IN;
print OUT "mkdir $WorkDir/../fig\n";
print OUT "mkdir $WorkDir/../outfile/\n";
print OUT "mv $WorkDir/*/*.pdf $WorkDir/../fig\n";
print OUT "mv $WorkDir/*/*.png $WorkDir/../fig\n";
print OUT "cp $in1 $WorkDir/../outfile\n";
print OUT "cd $WorkDir/../fig\n";
print OUT "cp 1.CAG.pdf ../outfile/\n";
print OUT "cp 1.CAG.png ../outfile/\n";
print OUT "zip -qr fig.zip *\n";
print OUT "mv fig.zip ../outfile\n";
print OUT "cd ../\n";
print OUT "# rm -rf $WorkDir/../fig/ $WorkDir\n";
close OUT;
#========================================
#sub function
#========================================
sub USAGE {
	my $usage=<<"USAGE";
Usage:
	Options:
	-in1	<file>	cag file;
	-in2	<file>	cut profile;
	-out 	<file>	shell file;
	-h	Help;
USAGE
	print $usage;
	exit;
}
