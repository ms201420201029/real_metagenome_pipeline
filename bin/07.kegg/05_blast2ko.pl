#!/usr/bin/perl -w

=pod
description: blast2ko
author: Zhang Fangxian, zhangfx@genomics.cn
create date: 20090706
modify date: 20100326, 20091120, 20091119, 20091111, 20091024, 20091009, 20090916, 20090915, 20090914, 20090911, 20090906, 20090903, 20090821, 20090820, 20090804, 20090730, 20090717, 20090710
=cut

use Getopt::Long;
use File::Basename 'dirname';
use FindBin '$Bin';
use lib $Bin;
use SeqType;

our ($blast_out,$kegg,$output, $help);

GetOptions(
	"blastout:s" => \$blast_out,
	"kegg:s" => \$kegg,
	"output:s" => \$output,
	"help|?" => \$help,
);

our ($idPath);

$kegg0 = $kegg if (defined $kegg);
do "$Bin/keggConf.pl" || die $!;
$kegg2 = $kegg;
$kegg = $kegg0 if (defined $kegg0);

sub usage {
	print STDERR << "USAGE";
description: blast2ko
usage: perl $0 [options]
options:
	-blastout: output of blast in format -m 8
	-blast: blastall program, determined automatically if not specified
	-kegg: kegg database, default is "$kegg2"
	-output: output file, default is "./[input].ko"
	-help|?: help information
e.g.:
	perl $0 -blastout blastoutFile -output ./out.ko
USAGE
	exit 1;
}

if (defined $help || !defined $blast_out || !defined $output) {
	&usage();
}


# check input files
push @inputs, $blast_out ;
push @inputs, $kegg;
$exit = 0;
for $file (@inputs) {
	if (!-f $file) {
		print STDERR "file $file not exists\n";
		$exit = 1;
	}
}

if ($exit == 1) {
	exit 1;
}

# main
%gene=();
open BLAST, "< $blast_out" || die $!;
$num=0;
while (<BLAST>) {
	chomp;
	@tabs = split /\t/, $_;
	$genes{$tabs[0]}=1;
	$tabs[0] = (split /\s/, $tabs[0])[0];
	if (exists $blast_r{$tabs[0]}) {
	        $num++;
        } else {
                $num = 1;
        }
	$tabs[-1] = &trim($tabs[-1]);
	push @{$blast_r{$tabs[0]}}, [$tabs[-2], $tabs[-1], $tabs[1], $num];
	@{$kos{$tabs[1]}} = ();
}
close BLAST;

# get kegg-ko relations
open KO, "< $kegg" || die $!;
while (<KO>) {
	chomp;
	next unless (/^>.*[\s;]\sK\d+/);
	$_ =~ s/^>//;
	@tabs = split /\s/, $_, 2;
	next if (not exists $kos{$tabs[0]});
	$tabs[1] = " $tabs[1]";
	$tabs[1] =~ s/([ ;]) [^K][^;]*\s;/$1/g;
	$tabs[1] =~ s/; (K[\d]+)/\|$1/g;
	$tabs[1] =~ s/^ *//;
	for (split /\|/, $tabs[1]) {
		$_ = &trim($_);
		@tabs2 = split / /, $_, 2;
		$id = $tabs2[0];
		next if ($id !~ /^K\d+/);
		$def = $tabs2[1] || "";
		push @{$kos{$tabs[0]}}, [$id, $def];
	}
}
close KO;

for $gene (sort keys %genes) {
	$total++;
	$content .= "$gene\t";
	$first = 1;
	@koids = ();
	if (exists $blast_r{$gene}) {
		for $result (@{$blast_r{$gene}}) {
			if (exists $kos{$result->[2]} && $#{$kos{$result->[2]}} > -1) {
				if ($first == 1) {
					$yes++;
					$content .= "$kos{$result->[2]}->[0]->[0]|$result->[3]|$result->[0]|$result->[1]|$result->[2]|$kos{$result->[2]}->[0]->[1]";
					push @koids, $kos{$result->[2]}->[0]->[0];
					for $i (1 .. $#{$kos{$result->[2]}}) {
						$content .= "!$kos{$result->[2]}->[$i]->[0]|$result->[3]|$result->[0]|$result->[1]|$result->[2]|$kos{$result->[2]}->[$i]->[1]";
						push @koids, $kos{$result->[2]}->[$i]->[0];
					}
					$first = 0;
				} else {
					for $i (0 .. $#{$kos{$result->[2]}}) {
						if (index("," . join(",", @koids) . ",", "," . $kos{$result->[2]}->[$i]->[0] . ",") < 0) {
							$content .= "!$kos{$result->[2]}->[$i]->[0]|$result->[3]|$result->[0]|$result->[1]|$result->[2]|$kos{$result->[2]}->[$i]->[1]";
							push @koids, $kos{$result->[2]}->[$i]->[0];
						}
					}
				}
			}
		}
	}
	$content .= "\n";
}

open OUT, "> $output" || die $!;
print OUT "# Method: BLAST\n";
print OUT "# Summary:\t$yes succeed, " . ($total - $yes) . " fail\n\n";
print OUT "# query\tko_id:rank:evalue:score:identity:ko_definition\n";
print OUT $content;
close OUT;

exit 0;

sub getFileName {
	my ($file_name) = @_;
	$file_name = (split /[\/\\]/, $file_name)[-1];
	$file_name =~ s/\.[^\.]*$//;
	return $file_name;
}

sub trim {
	my ($string) = @_;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}
