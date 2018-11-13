#!/usr/bin/perl -w
use strict;
use Cwd 'abs_path';
use Getopt::Long;
my $autorun	= 0;
my $threshold_1	= 0;
my $threshold_2	= 0;
my $threshold	= 0;
my $percentage	= 0;
my $gene_number	= 0;
my $input	= 0;
my $thread	= 0;
my $help	= 0;
GetOptions(
	'autorun!'		=>\$autorun,
	'threshold_1|t1=f'	=>\$threshold_1,
	'threshold_2|t2=f'	=>\$threshold_2,
	'threshold|t=f'		=>\$threshold,
	'percentage=f'		=>\$percentage,
	'gene_number=i'		=>\$gene_number,
	'input=s'		=>\$input,
	'thread|c=i'		=>\$thread,
	'help!'			=>\$help,
);
#scalar @ARGV or $help = 1;
if ( $help == 1 ){
	print	"\t-a  --autorun\n";
	print	"\t-i  --in\t<Input reads file>\n";
	print	"\t-t1 --threshole_1\n";
	print	"\t-t2 --threshold_2\n";
	print	"\t-t  --threshold\n";
	print	"\t-p  --percentage\n";
	print	"\t-g  --gene_number\n";
	print 	"\t-c  --thread\n";
	print	"\t-h  --help\n";
	exit;
}
my $WorkDir = abs_path(`dirname $input`);chomp $WorkDir;
my $SoftDir = abs_path(`dirname $0`);chomp $SoftDir;
my $sample_number = `head -1 $input |wc -w`;chomp $sample_number;
open SHELL,">$WorkDir/cag.sh" or die $!;
print SHELL <<_SHELL_;
sed -e 's/^\\s\\+//g' -e 's/\\s\\+/ /g' $input >input.profile
perl $SoftDir/bin/check.pl input.profile
$SoftDir/bin/canopy -i input.profile -T $threshold_1 -t $threshold_2 -s $sample_number -p $thread > canopy.out
perl $SoftDir/bin/filter.pl canopy.out $gene_number > canopy_filter.out
perl $SoftDir/bin/mean.pl  canopy_filter.out input.profile  >canopy_filter_mean.out
$SoftDir/bin/canopy_merge -i canopy_filter_mean.out -o canopy_merge.out -t $threshold -p $percentage -s $sample_number
perl $SoftDir/bin/merge.pl canopy_merge.out canopy_filter.out >uncleaned_cag.out
perl $SoftDir/bin/clean.pl uncleaned_cag.out >CAG.out
sed -i -e 's/^\\s+//g' -e 's/\\s+/ /g' CAG.out
perl $SoftDir/bin/mean.pl  CAG.out input.profile >cag_mean.out
perl $SoftDir/bin/normalize.pl cag_mean.out >cag_mean_normal_abun
cut -d ' ' -f 1 input.profile >gene.list
sed -i '1d' gene.list
perl $SoftDir/bin/overlap.pl CAG.out gene.list nonused.list overlap.info
cut -d ' ' -f 1 overlap.info > overlap.list 
perl $SoftDir/bin/search.pl overlap.list input.profile > overlap_abun
perl $SoftDir/bin/normalize.pl overlap_abun > overlap_gene_normal_abun
perl $SoftDir/bin/separate.pl overlap_gene_normal_abun overlap.info cag_mean_normal_abun >overlap_cag_info
perl $SoftDir/bin/cut.pl overlap_cag_info CAG.out >cag
perl /data_center_03/USER/zhongwd/soft/cag/cag_V1.3_beta/bin/filter.pl cag 700 > mgs
cp mgs ../pathway/cag
_SHELL_
close SHELL;

system("sh $WorkDir/cag.sh")
