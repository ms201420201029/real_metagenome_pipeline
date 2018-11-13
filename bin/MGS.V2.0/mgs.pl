#!/usr/bin/env perl
=pod
Description: MGS analysis
Author: Wu huan, Zhong wendi
Create date: 20151021
=cut
use warnings;
use strict;
use Getopt::Long;
use File::Basename 'dirname';

my ($grp1_profile,$grp2_profile,$grp1_list,$grp2_list,$gene_num,$run,$help);
GetOptions(
		"grp1_profile|p1=s" => \$grp1_profile,
		"grp2_profile|p2=s" => \$grp2_profile,
		"grp1_list|l1=s"    => \$grp1_list,
		"grp2_list|l2=s"    => \$grp2_list,
		"gene_num|n=i"      => \$gene_num,
		"run|r!"            => \$run,
		"help|h!"           => \$help);
&help unless defined $grp1_profile and -e $grp1_profile and defined $grp2_profile and -e $grp2_profile and defined $gene_num and defined $grp1_list and -e $grp1_list and defined $grp2_list and -e $grp2_list and not defined $help;
my $src_dir = dirname($0);
my $Rscript_dir = $src_dir . "/Rscript";
my $prefix_grp1 = $grp1_list;
$prefix_grp1 =~ s/.list//g;
my $prefix_grp2 = $grp2_list;
$prefix_grp2 =~ s/.list//g;

## shell
#`ln -s $grp1_profile A.profile`;
#`ln -s $grp2_profile H.profile`;
open ASH, ">$grp1_profile.mgs.sh" or die $!;
print ASH <<_SHELL_;
Rscript $Rscript_dir/2.0_4.0_fast_2_markers_groups.r $grp1_profile 0.8 complete
Rscript $Rscript_dir/3.0_get_average_groups.r group_$grp1_profile $grp1_profile 100 $gene_num
Rscript $Rscript_dir/2.0_4.0_fast_2_markers_groups.r group_mean_$grp1_profile 0.9 complete
Rscript $Rscript_dir/5.0_second_groups.r group_$grp1_profile group_group_mean_$grp1_profile
Rscript $Rscript_dir/6.0_second_best.r second_groups_$grp1_profile $grp1_profile $gene_num
_SHELL_
close ASH;
open HSH, ">$grp2_profile.mgs.sh" or die $!;
print HSH <<_SHELL_;
Rscript $Rscript_dir/2.0_4.0_fast_2_markers_groups.r $grp2_profile 0.8 complete
Rscript $Rscript_dir/3.0_get_average_groups.r group_$grp2_profile $grp2_profile 100 $gene_num
Rscript $Rscript_dir/2.0_4.0_fast_2_markers_groups.r group_mean_$grp2_profile 0.9 complete
Rscript $Rscript_dir/5.0_second_groups.r group_$grp2_profile group_group_mean_$grp2_profile
Rscript $Rscript_dir/6.0_second_best.r second_groups_$grp2_profile $grp2_profile $gene_num
_SHELL_
close HSH;
open ALSH, ">all.mgs.sh" or die $!;
print ALSH <<_SHELL_;
Rscript $Rscript_dir/8.0_image.r final_group_members_profile_$grp1_profile final_group_members_profile_$grp2_profile final_group_mean_$grp1_profile final_group_mean_$grp2_profile $gene_num $prefix_grp1 $prefix_grp2
Rscript $Rscript_dir/9.0_image.r final_group_members_profile_$grp1_profile final_group_members_profile_$grp2_profile final_group_mean_$grp1_profile final_group_mean_$grp2_profile $gene_num $prefix_grp1 $prefix_grp2
_SHELL_
close ALSH;

# run
if (defined $run){
	open RUN, ">run_wrok.sh" or die $!;
	print RUN "qsub -cwd -l vf=100g -q big.q -sync y $grp1_profile.mgs.sh &\n";
	print RUN "qsub -cwd -l vf=100g -q SJQ -sync y $grp2_profile.mgs.sh &\n";
	print RUN "sh all.mgs.sh &\n";
	close RUN;
	
	system("qsub -cwd -q big.q -l vf=100g -sync y $grp1_profile.mgs.sh");
	system("qsub -cwd -q SJQ -l vf=100g -sync y $grp2_profile.mgs.sh");
	system("qsub -cwd -q all.q -l vf=1g -sync y all.mgs.sh");
}else{
	open RUN, ">run_wrok.sh" or die $!;
	print RUN "qsub -cwd -l vf=100g -q big.q -sync y $grp1_profile.mgs.sh &\n";
	print RUN "qsub -cwd -l vf=100g -q SJQ -sync y $grp2_profile.mgs.sh &\n";
	print RUN "sh all.mgs.sh &\n";
	close RUN;
}

sub help{
	print STDERR <<"_USAGE_" and exit 1;

description: MGS analysis
usage: perl $0 [options]
options:
	-p1 <string>  profile of group 1.
	-p2 <string>  profile of group 2.
	-l1 <string>  sample list of group 1.
	-l2 <string>  sample list of group 2.
	-n  <integer> number of genes in each MGS cluster.
	-r  <options> autorun.
	-h  <options> print this help infomation.
note:
	Number of genes in each profile should not be greater than 40k, otherwise it may lead to Out-of-Memery Exception.
	Running with nohup in login node is strongly recommanded if -r is used.
e.g.:
	perl $0 -p1 grp1.profile -p2 grp2.profile -n 50 -r

_USAGE_
}
