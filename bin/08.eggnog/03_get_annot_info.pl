#!/usr/bin/perl -w
die "perl $0 <A.blast.best.out> <NOG.members> <NOG.description> <NOG.funccat> <output.blast.table>" unless(@ARGV==5);
#my ($blast,$mename,$description,$class,$out)=@ARGV;nnot_info.pl4_get_annot_info.pl:
my %name;
my %description;
my %class;

open IN,$ARGV[1] || die "can not open $ARGV[1]\n";
while(<IN>){
        chomp;
        my @tab=split/\t/,$_;
        if(exists $name{$tab[1]}){$name{$tab[1]}.="&$tab[0]";}else{$name{$tab[1]}=$tab[0];}
}
close IN;

open IN,$ARGV[2] || die "can not open $ARGV[2]\n";
while(<IN>){
        chomp;
        my @tab=split/\t/,$_;
        if($tab[1]){$description{$tab[0]}=$tab[1];}else{ $description{$tab[0]}="NA";}
}
close IN;

open IN,$ARGV[3]|| die "can not open $ARGV[3]\n";
while(<IN>){
        chomp;
        my @tab=split/\t/,$_;
        if($tab[1]){$class{$tab[0]}=$tab[1];}else{ $class{$tab[0]}="NA";}
}
close IN;

open IN,$ARGV[0] || die "can not open $ARGV[0]\n";
open OUT,">$ARGV[4]" || die "can not open $ARGV[4]\n";
#print OUT "Query_id\tSubject_id\tIdentity\tAlign_length\tMiss_match\tGap\tQuery_start\tQuery_end\tSubject_start\tSubject_end\tE_value\tScore\tNOG_name\tNOG_annotation\tNOG_class\n";
while(<IN>){
        chomp;
        my @tab=split/\t/,$_;
        my ($descriptions,$classes);
        if (!$name{$tab[1]}){$name{$tab[1]}="NA";$description{$name{$tab[1]}}="NA";$class{$name{$tab[1]}}="NA";}
	my @names=split/&/,$name{$tab[1]};
	foreach my $name(@names){
		$descriptions.="$description{$name}&";
                #if ($class{$name}!~"NA" && length($class{$name})>1){my @name=split(//,$class{$name});$class{$name}=join("&",@name);}
                $classes.="$class{$name}&";
}
        chop $descriptions;chop $classes;
        print OUT "$_\t$name{$tab[1]}\t$descriptions\t$classes\n";
}
close IN;
close OUT;
