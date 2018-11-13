#! /usr/bin/perl -w
die "perl $0 [*.path,split by \",\"][prefix]\n" unless(@ARGV==2);

=pod
 description: generate pathway statistics
 author: Wu Chunyan
 created date: 20140710
=cut

my ($in,$prefix)=@ARGV;
my @path=split/,/,$in;

 
my %path;
my %genenum;
my @keys;
foreach my $path(@path){
	$path=~/^([^\.]+)/;
	my $key=$1;
	push @keys,$key;
	open IN,$path ||die $!;
	<IN>;
	while(<IN>){
		chomp;
		my @t=split/\t/,$_;
		my @genes=split/;/,$t[5];
#		next if($t[3] eq "Human Diseases");
		foreach my $gene(@genes){
			$path{$t[3]}{$t[4]}=1;
			$genenum{$key}{$t[4]}{$gene}=1;
		}
	}
	close IN;
}

open OUT,">$prefix.class" ||die $!;
print OUT "CLASS\tPathway";
foreach my $key(@keys){print OUT "\t$key";}
print OUT "\n";

my $totalnum;
#foreach my $level1(sort{$a cmp $b} keys %path){
#	foreach my $level2(sort{$a cmp $b} keys %{$path{$level1}}){
#		foreach my $gene (keys %{$path{$level1}{$level2}}){
#			$totalnum++;
#		}
#	}
#}
foreach my $level1(sort{$a cmp $b} keys %path){
	foreach my $level2(sort{$a cmp $b} keys %{$path{$level1}}){
		next if($level2 eq "Global and overview maps");
                print OUT "$level1\t$level2";
		foreach my $key(@keys){
			my $num=0;
			foreach my $gene (keys %{$genenum{$key}{$level2}}){
				$num++;
			}
			print OUT "\t$num";
		}
		print OUT "\n";
	}
}

#open R,">$prefix.R";
#print R<<RTXT;
#install.packages("/data_center_01/home/NEOLINE/wuchunyan/software/R/ggplot2_1.0.0.tar.gz")
#library(ggplot2)
#counts <- read.delim("$prefix.class",header=TRUE)
#counts\$Pathway <- factor(counts\$Pathway, levels=unique(counts\$Pathway))
#pdf("$prefix.class.pdf",width=9, height=5) 
#qplot(Pathway,precent,data = counts, geom = 'bar')+coord_flip()+geom_bar(aes(fill=CLASS),stat="identity")+labs(title="KEGG Classification",y="Percent of Genes (%)",x="")+theme(axis.text=element_text(colour="black"))+geom_text(label=counts\$num,size=3,hjust=0, vjust=0)+ylim(0,16)
#dev.off()
#RTXT

#system("/usr/local/bin/R CMD BATCH $prefix.R $prefix.R.Rout");
#system("/usr/bin/convert -density 300 $prefix.class.pdf $prefix.class.png");

