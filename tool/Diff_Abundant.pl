#!/usr/bin/env perl
=pod
Description: Detect the differential abundant items base on abundant profile
Author: Zhong wendi
Create date: 20151031
=cut
use warnings;
use strict;
use Getopt::Long;
use File::Basename 'dirname';

my ($profile, $group, $help);
GetOptions(
		"profile|p=s" => \$profile,
		"group|g=s"   => \$group,
		"help|h!"     => \$help);
&help unless defined $profile and -e $profile and defined $group and -e $group and not defined $help;
my $src_dir     = dirname($0);
my $Bin_dir     = $src_dir . "/bin";
my $Rscript_dir = $src_dir . "/Rscript";

## shell
open OT, ">$profile.diff.sh";
print OT <<_SHELL_;
Rscript $src_dir/wilcox.test.R $group $profile
extract.pl $profile $profile.p 0.05
extract.pl $profile $profile.p 0.01
extract.pl $profile $profile.p 0.005
extract.pl $profile $profile.p 0.001
extract.pl $profile $profile.p 0.0005
_SHELL_
close OT;

## run
system("sh $profile.diff.sh");
system("convert $profile.p.pdf $profile.p.png");

sub help{
	print STDERR <<"_USAGE_" and exit 1;

description: Detect the differential abundant items base on abundant profile
usage: perl $0 [options]
options:
	-p <string>  profile.
	-g <string>  group table of samples.
	-h <options> print this help infomation.
e.g.:
	perl $0 -p profile -g group.list

_USAGE_
}
