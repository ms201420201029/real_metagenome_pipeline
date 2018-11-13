#! /usr/bin/perl -w
die "perl $0 [*.path][prefix]\n" unless(@ARGV==2);

=pod
 description: generate pathway statistics
 author: Wu Chunyan
 created date: 20140710
=cut

my ($path,$prefix)=@ARGV;

my $totalnum;
my %path;
open IN,$path ||die $!;
my $head=<IN>;
$head=~/#Pathway\s+Count\s+\((\d+)\)/;
$totalnum=$1;
while(<IN>){
	chomp;
	my @t=split/\t/,$_;
	my @genes=split/;/,$t[5];
#	next if($t[3] eq "Human Diseases");
	foreach my $gene(@genes){
		$path{$t[3]}{$t[4]}{$gene}=1;
	}
}
close IN;

open OUT,">$prefix.class" ||die $!;
print OUT "CLASS\tPathway\tnum\tprecent\n";

=pod
foreach my $level1(sort{$a cmp $b} keys %path){
	foreach my $level2(sort{$a cmp $b} keys %{$path{$level1}}){
		foreach my $gene (keys %{$path{$level1}{$level2}}){
			$totalnum++;
		}
	}
}
=cut

foreach my $level1(sort{$a cmp $b} keys %path){
	foreach my $level2(sort{$a cmp $b} keys %{$path{$level1}}){
#		next if($level2 eq "Global and overview maps");
		my $num;
		foreach my $gene (keys %{$path{$level1}{$level2}}){
			$num++;
		}
		printf OUT "$level1\t$level2\t$num\t%.2f\n",$num/$totalnum*100;
	}
}

open R,">$prefix.R";
print R<<RTXT;
#install.packages("/data_center_01/home/NEOLINE/wuchunyan/software/R/ggplot2_1.0.0.tar.gz")
library(ggplot2)
counts <- read.delim("$prefix.class",header=TRUE)
counts\$Pathway <- factor(counts\$Pathway, levels=unique(counts\$Pathway))
pdf("$prefix.class.pdf",width=9, height=5) 
qplot(Pathway,precent,data = counts, geom = 'bar')+coord_flip()+geom_bar(aes(fill=CLASS),stat="identity")+labs(title="KEGG Classification",y="Percent of Genes (%)",x="")+theme(axis.text=element_text(colour="black"))+geom_text(label=counts\$num,size=3,hjust=0, vjust=0)+ylim(0,16)
dev.off()
RTXT

system("/usr/bin/R CMD BATCH $prefix.R $prefix.R.Rout");
system("/usr/bin/convert -density 300 $prefix.class.pdf $prefix.class.png");

