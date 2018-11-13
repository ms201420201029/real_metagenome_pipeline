#/usr/bin/perl

use strict;
use warnings;
use Cwd 'abs_path';

my $in = "/data_center_12/Project/liulf_test/11.CAG/03.all/taxonomy/group.tax.tsv";
my $WorkDir = abs_path(`dirname $in`);chomp $WorkDir;
my @arr_no = ();

print "CAG ID\tNumber of genes(#)\tTaxonomy	Level\tNumber of genes on DataBase(#)\n";


open (IN,$in) or die $!;
while(<IN>){
	s/\n|\r//g;
	chomp;
	my ($cag_id,$num_gene,$taxonomy,$level,$on_db_gene,$roate) = split("\t");
	if ($on_db_gene eq ""){
		$on_db_gene = "0";$taxonomy = "\\";$level = "\\";
		$_ = "$cag_id\t$num_gene\t$taxonomy\t$level\t$on_db_gene\n";
		push @arr_no, $_;
		
	}else{
		print "$cag_id\t$num_gene\t$taxonomy\t$level\t$on_db_gene\n";
	}
}
close IN;

foreach my $id (@arr_no){
	print "$id";	
}
