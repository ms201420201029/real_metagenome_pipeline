#! /usr/bin/perl -w
die "perl $0 [*.path][prefix]\n" unless(@ARGV==2);

=pod
 description: generate pathway statistics
 author: Wu Chunyan
 created date: 20140710
=cut
$ENV{'R_LIBS'}= "/data_center_01/home/NEOLINE/liangzebin/soft/R/R-3.1.3/lib64/R/library";

my ($path,$prefix)=@ARGV;

my %path_genenum;
my %path;
open IN,$path ||die $!;
<IN>;
while(<IN>){
	chomp;
	my @t=split/\t/,$_;
	my @genes=split/;/,$t[5];
#	next if($t[3] eq "Human Diseases");
	$path_genenum{$t[3]}{$t[4]}{$t[0]}=$t[1];
	foreach my $gene(@genes){
		$path{$t[3]}{$t[4]}{$gene}=1;
	}
	
}
close IN;

open OUT,">$prefix.class" ||die $!;
print OUT "CLASS\tLevel2\tLevel3\tnum\tprecent\n";
my $totalnum;
foreach my $level1(sort{$a cmp $b} keys %path){
	foreach my $level2(sort{$a cmp $b} keys %{$path{$level1}}){
		next if($level2 eq "Global and overview maps");
		foreach my $gene (keys %{$path{$level1}{$level2}}){
			$totalnum++;
		}
	}
}
foreach my $level1(sort{$a cmp $b} keys %path_genenum){
	foreach my $level2(sort{$a cmp $b} keys %{$path_genenum{$level1}}){
		next if($level2 eq "Global and overview maps");
		foreach my $level3 (keys %{$path_genenum{$level1}{$level2}}){
			my $num=$path_genenum{$level1}{$level2}{$level3};
			printf OUT "$level1\t$level2\t$level3\t$num\t%.2f\n",$num/$totalnum*100;
		}
	}
}

=pos
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
=cut
