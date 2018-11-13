#!/usr/bin/perl
print "usage:\nblatshell <db.list> <sq.list> <dir>\n" and exit unless scalar @ARGV == 3;
open DB,"$ARGV[0]" or die $!;
while (<DB>){
	chomp;
	push @db,$_;
}
close DB;
open SQ,"$ARGV[1]" or die $!;
while (<SQ>){
	chomp;
	push @sq,$_;
}
close SQ;
$dir = $ARGV[2];
-d "$dir/shell" or `mkdir $dir/shell`;
-d "$dir/blat"  or `mkdir $dir/blat`;
open OUT,">$dir/shell/blat.sh";
foreach $sq(@sq){
	foreach $db(@db){
		@_ = split /\//, $sq;
		$sqn = pop @_;
		@_ = split /\//, $db;
		$dbn = pop @_;
		print OUT "blat $db $sq -prot -minScore=60 -out=blast8 $dir/blat/$sqn-$dbn\n";
	}
}
close OUT;
