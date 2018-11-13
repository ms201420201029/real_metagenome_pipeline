#!/usr/bin/perl -w
my ($inputfile,$name)=@ARGV;
open IN,$inputfile or die $!;
my $i=0;
while(<IN>){
	chomp;
	my @tab=split /\t/,$_;
	my $id=shift @tab;
	my $final_tab=join("\t",@tab);
	$i++;
	print "$name\_$i\t$final_tab\n"; 
}
close IN;
