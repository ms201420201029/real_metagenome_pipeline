#!usr/bin/perl -w
die "perl $0 <A.blast4.anno> <fun.txt><A.genelist> <output.blast.table>" unless(@ARGV==4);

my ($blast,$fun,$list,$out)=@ARGV;

my %CLASS;
my %list;
my %gene;
open IN1,$fun || die "can not open $fun\n";
my $class;
while(<IN1>){
        chomp;
        if($_!~/^\s*\[/){$class=$_;$class=~s/^\s*//;}
        else{
                if($_=~/^\s*\[(\w+)\]\s*(.*)/){
                        my $nog=$1;
                        my $name=$2;
                        $CLASS{$nog}{name}=$name;
                        $CLASS{$nog}{class}=$class;
                }
        }
}
close IN1;

open IN,$list || die "can not open $list\n";
while(<IN>){
        chomp;
        my @tab=split/\t/;
        $list{$tab[0]}=1;        
}
close IN;

open IN2,$blast || die "can not open $blast\n";
open OUT,">$out" || die "can not open $out\n";
while(<IN2>){
	chomp;
	my @tab=split/\t/; 
	next if ($tab[14]=~m/NA/);
        if (exists $list{$tab[0]}){
	    my @class=split(/&/,$tab[14]);
            my @class1=split(//,join("",@class));
            foreach my $nog(@class1){$gene{$nog}.="$tab[0],";}
        }  
}
my %count;
my %genelist;
my $sum;
foreach my $nog( keys %gene){
    my %gene_nodup;
    my @gene=split(/,/,$gene{$nog});foreach my $gene(@gene){$gene_nodup{$gene}=1;}
    foreach my $gene(keys %gene_nodup){$genelist{$nog}.="$gene,";}
    chop $genelist{$nog};
    my @genelist_nog=split/,/,$genelist{$nog};
    $count{$nog}=scalar(@genelist_nog);
    $sum+=$count{$nog};
}   
foreach my $nog(sort{$CLASS{$a}{class} cmp $CLASS{$b}{class}} keys %gene){
    my $radio=$count{$nog}/$sum;
    print OUT "$CLASS{$nog}{class}\t $CLASS{$nog}{name}\t$nog\t $count{$nog}\t$radio\n"; 
}
close IN2;
close OUT;
