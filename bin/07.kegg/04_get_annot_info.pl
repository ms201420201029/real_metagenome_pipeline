#! /usr/bin/perl -w
die "perl $0 [A.best.blat.out][KEGG.pep.description][output (e.g. A.KEGG.xls)" unless(@ARGV==3);

my ($blat,$description,$out)=@ARGV;
my %description;

open IN,$description || die "can not open $description\n";
while(<IN>){
	chomp;
	my @tab=split/\t/,$_;
	$description{$tab[0]}=$tab[1];
}
close IN;

open IN,$blat || die "can not open $blat\n";
open OUT,">$out" || die "can not open $out\n";
print OUT "Query_id\tSubject_id\tIdentity\tAlign_length\tMiss_match\tGap\tQuery_start\tQuery_end\tSubject_start\tSubject_end\tE_value\tScore\tSubject_annotation\n";
while(<IN>){
	chomp;
	my @tab=split/\t/,$_;
	print OUT "$_\t$description{$tab[1]}\n";
}
close IN;
close OUT;
