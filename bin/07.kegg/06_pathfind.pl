#!/usr/bin/perl -w

=pod
description: pathfind
author: Wu Chunyan 
created date: 20140710
=cut

use Getopt::Long;
use FindBin '$Bin';
use File::Basename 'dirname';

our ($fg, $bg, $koMap, $output, $cutoff, $help);

GetOptions(
	"fg:s" => \$fg,
	"bg:s" => \$bg,
	"komap:s" => \$koMap,
	"output:s" => \$output,
	"cutoff:s" => \$cutoff,
	"help|?" => \$help,
);
$output ||= "./out.path";
$cutoff ||= 0.3;
##############added by dushuo 2010-11-3
my $name;
$name = (split /[\\\/]/, $output)[-1];
$name =~ s/\.path$//;
######
if (defined $koMap) {
	$koMap0 = $koMap;
}

our ($kegg, $mapTitle);
do "$Bin/keggConf.pl" || die $!;
$koMap2 = $koMap;

if (defined $koMap0) {
	$koMap = $koMap0;
}

sub usage {
	print STDERR << "USAGE";
description: pathfind
usage: perl $0 [options]
options:
	-fg <string>: foreground ko file
	-bg <string>: background ko file, or 3 small-caption letters for species
	-komap <string>: ko_map.tab file, default is $koMap2
	-output <string>: output file, default is out.path
	-cutoff <float>: minimum precent of enzymes annotated, default is 0.3 
	-help: help information
e.g.:
	perl $0 -fg ko -output out.path
	perl $0 -fg 1.ko -bg 2.ko -output out.path
	perl $0 -fg 1.ko -bg hsa -output out.path
USAGE
}

if (defined $help || !defined $fg) {
	&usage();
	exit 1;
}
print "cutoff is $cutoff\n";
my %ECnum;
open LIST,$mapTitle||die "can not open $mapTitle";
while(<LIST>){chomp;my @t=split/\t/,$_;$ECnum{$t[0]}=$t[-1];}
close LIST;

if (defined $bg && !-f $bg && length($bg) == 3) {
	$bg =~ tr/[A-Z]/[a-z]/;
	open KO, "< $kegg" || die $!;
	open BG, "> $bg.ko" || die $!;
	while (<KO>) {
		chomp;
		next unless (/^>$bg.*[\s;]\sK\d+/);
		$_ =~ s/^>$bg://;
		@tabs = split /\s/, $_, 2;
		$tabs[1] = " $tabs[1]";
		$tabs[1] =~ s/([ ;]) [^K][^;]*\s;/$1/g;
		$tabs[1] =~ s/; (K[\d]+)/\|$1/g;
		$tabs[1] =~ s/^ *//;
		@ids = ();
		for (split /\|/, $tabs[1]) {
			$_ =~ s/^\s*//;
			@tabs2 = split / /, $_, 2;
			$id = $tabs2[0];
			push @ids, $id if ($id =~ /^K\d+/);
		}
		Print BG "$tabs[0]\t" . (join "!", @ids) . "\n";
	}
	close BG;
	close KO;

	if (!defined $koMap0 || !-f $koMap0) {
		$koMap = "$bg\_ko_map.tab";
		system("perl $Bin/genKOMap.pl -species $bg -output $koMap");
	}

	$bg .= ".ko";
	$koMap = $koMap2 if (-s $koMap == 0);
}

# check input files
push @inputs, $fg;
push @inputs, $bg if (defined $bg);
$koMap = $koMap2 if (!defined $koMap || !-f $koMap);

my $exit = 0;
for $file (@inputs, $koMap, $mapTitle) {
	if (!-f $file) {
		print STDERR "file $file not exists\n";
		$exit = 1;
	}
}

exit 1 if ($exit == 1);

# main
local($/);

open IN, "< $koMap" || die $!;
$all_in = <IN>;
$all_in =~ s/\n+$//;
close IN;
@all_ins = split /\n/, $all_in;
for $line (@all_ins) {
	@temp = split /\t/, $line;
	@{$kos{$temp[0]}} = split /\s/, $temp[1];
}

open IN, "< $mapTitle" || die $!;
$all_in = <IN>;
$all_in =~ s/\n+$//;
close IN;
@all_ins = split /\n/, $all_in;
for $line (@all_ins) {
	@temp = split /\t/, $line;
	$titles{$temp[0]}{level3} = $temp[1];
	$titles{$temp[0]}{level1} = $temp[2];
	$titles{$temp[0]}{level2} = $temp[3];
}

undef($all_in);
undef(@all_ins);
local($/) = "\n";

open FG, "< $fg" || die $!;
%genes1 = ();
%genes2 = ();
$sum1 = 0;
$sum2 = 0;
while (<FG>) {
	chomp;
	next if ($_ eq "" or index($_, "#") == 0);
	@temp = split /\t/, $_;
	next if ($#temp == 0);
	$temp[1] =~ s/\|[^!]*!*/!/g;
	$temp[1] =~ s/!$//;
	@temp2 = split /!/, $temp[1];
	if (!exists $genes1{$temp[0]}) {
		$sum1++;
		$genes1{$temp[0]} = 1;
	}
	for $KO (@temp2) {
		if (exists $kos{$KO}) {
			for $ko (@{$kos{$KO}}) {
				if (exists $titles{$ko}) {
					if (!exists $stats{$ko}) {
						$stats{$ko}{"pathway"} = $titles{$ko}{level3};
						$stats{$ko}{"genes"} = [];
						$stats{$ko}{"kos"} = [];
						if (defined $bg) {
							$stats{$ko}{"genes2"} = [];
							$stats{$ko}{"kos2"} = [];
						}
					}
					push @{$stats{$ko}{"genes"}}, $temp[0] if (index("," . (join ",", @{$stats{$ko}{"genes"}}) . ",", "," . $temp[0] . ",") == -1);
					push @{$stats{$ko}{"kos"}}, $KO if (index("," . (join ",", @{$stats{$ko}{"kos"}}) . ",", "," . $KO . ",") == -1);
				}
			}
		}
	}
}
close FG;

if (!defined $bg) { # case 1: without background
	$num = 0;
	$content = "";
	for $pwID (sort {$#{$stats{$b}{"genes"}} <=> $#{$stats{$a}{"genes"}}} keys %stats) {
		#####add by wuchunyan at 20140624####
		open IN,"<$mapDir/map$pwID.html" ||die "can not open $mapDir/map$pwID.html";
		my $ECnum=0;
		while(<IN>){
			$tmp=$_;
	                foreach my $ko (@{$stats{$pwID}{"kos"}}) {if ($tmp=~/href="\/dbget-bin\/www_bget\?\+*$ko/) {$ECnum++;last;}}
		}
		#####################################
		$num = @{$stats{$pwID}{"genes"}};
		my $percent=sprintf("%.2f",$ECnum/$ECnum{$pwID});
		$content .= "$stats{$pwID}{'pathway'}\t" . $num . "\tko$pwID\t$titles{$pwID}{level1}\t$titles{$pwID}{level2}\t"  . (join ";", @{$stats{$pwID}{"genes"}}) . "\t" . (join "+", @{$stats{$pwID}{"kos"}}) . "\t". $percent . "\n" if($percent >=$cutoff);  ##### by wuchunyan at 20140624
	}
	open OUT, "> $output" || die $!;
#	print OUT "#Pathway\tCount (" . $sum1 . ")\tPathway ID\tGenes\tKOs\n";
	print OUT "#Pathway\tCount (" . $sum1 . ")\tPathway ID\tLevel 1\tLevel 2\tGenes\tKOs\tPercent\n";
	print OUT $content;
	close OUT;
} else { # case 2: with background
	open BG, "< $bg" || die $!;
	while (<BG>) {
		chomp;
		next if ($_ eq "" or index($_, "#") == 0);
		@temp = split /\t/, $_;
		next if ($#temp < 1);
		$temp[1] =~ s/\|[^!]*!*/!/g;
		$temp[1] =~ s/!$//;
		@temp2 = split /!/, $temp[1];
		if (!exists $genes2{$temp[0]}) {
			$sum2++;
			$genes2{$temp[0]} = 1;
		}
		for $KO (@temp2) {
			if (exists $kos{$KO}) {
				for $ko (@{$kos{$KO}}) {
					if (exists $titles{$ko}) {
						next if (!exists $stats{$ko});
						push @{$stats{$ko}{"genes2"}}, $temp[0] if (index("," . (join ",", @{$stats{$ko}{"genes2"}}) . ",", "," . $temp[0] . ",") == -1);
						push @{$stats{$ko}{"kos2"}}, $ko if (index("," . (join ",", @{$stats{$ko}{"kos2"}}) . ",", "," . $ko . ",") == -1);
					}
				}
			}
		}
	}
	close BG;

	$num1 = 0;
	$num2 = 0;
	$content = "";

	open PT, "> ptemp.R" || die $!;
	for $pwID (sort keys %stats) {
		$num1 = @{$stats{$pwID}{"genes"}};
		$num2 = @{$stats{$pwID}{"genes2"}};
		print PT "phyper($num1 - 1, $num2, $sum2 - $num2, $sum1, lower.tail=F)\n";
	}
	close PT;
	@pValues = split /\n/, `/usr/local/bin/Rscript ptemp.R | awk '{print \$2}' 2> /dev/null`;

	$p = join(", ", @pValues);
	open QT, "> qtemp.R" || die $!;
	print QT <<QT;
library(qvalue)
p <- c($p)
q <- qvalue(p, lambda = 0)
q[3]
QT
	close QT;
	$Rscript = "Rscript";
	$Rscript = "/usr/local/bin/Rscript" if (-x "/usr/local/bin/Rscript");
	@qValues = split /\n/, `$Rscript qtemp.R 2> /dev/null | awk 'NR > 1 {for (x = 2; x <= NF; x++) print \$x}'`;
	unlink "ptemp.R", "qtemp.R";

	$i = 0;
	for $pwID (sort keys %stats) {
		$stats{$pwID}{"pvalue"} = $pValues[$i];
		$stats{$pwID}{"qvalue"} = $qValues[$i];
		$i++;
	}

	for $pwID (sort {$stats{$a}{"pvalue"} <=> $stats{$b}{"pvalue"}} keys (%stats)) {
		$num1 = @{$stats{$pwID}{"genes"}};
		$num2 = @{$stats{$pwID}{"genes2"}};
		$content .= "$stats{$pwID}{'pathway'}\t" . $num1 . "\t" . $num2 . "\t$stats{$pwID}{'pvalue'}\t$stats{$pwID}{'qvalue'}\tko$pwID\t$titles{$pwID}{level1}\t$titles{$pwID}{level2}\t" . (join ";", @{$stats{$pwID}{"genes"}}) . "\t" . (join "+", @{$stats{$pwID}{"kos"}}) . "\n";
	}
	open OUT, "> $output" || die $!;
#	print OUT "#Pathway\tSample1 (" . $sum1 . ")\tSample2 (" . $sum2 . ")\tPvalue\tQvalue\tPathway ID\tGenes\tKOs\n";
	print OUT "#Pathway\t$name (" . $sum1 . ")\tAll-Unigene (" . $sum2 . ")\tPvalue\tQvalue\tPathway ID\tLevel 1\tLevel 2\tGenes\tKOs\n";
	print OUT $content;
	close OUT;
}

exit 0;
