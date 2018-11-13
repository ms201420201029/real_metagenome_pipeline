#!/usr/bin/perl -w
use strict;

=pod
 description: generate pathway level statistics
 author: Wu Chunyan
 created date: 20140710
=cut

die $! unless @ARGV == 3;
my ($path, $column, $outdir) = @ARGV;

my %hash;
open PATH,"$path";
<PATH>;
while(<PATH>){
	chomp;
	my @tmp = split(/\t/, $_);
	$tmp[$column-1] =~ s/, /,/g;
	$tmp[$column-1] =~ s/ /\_/g;
	$hash{$tmp[$column-1]}{$tmp[0]} = $tmp[1];
}
close PATH;

my $max = 0;
system("mkdir -p $outdir");
foreach my $key(sort keys %hash){

	$max = 0;
	open SRC,">$outdir/kegg.src";
	my $hash2 = $hash{$key};
	foreach my $key2(sort {$hash{$key}{$b}<=>$hash{$key}{$a}} keys %$hash2){
		print SRC "$key2\t$hash{$key}{$key2}\n";
		$max = ($max < $hash{$key}{$key2}) ? $hash{$key}{$key2} : $max;
	}
	close SRC;
	my ($xlim, $sep) = &xlim_sep($max);
	my $height = keys %$hash2;
	$height = 0.4 * $height + 1.5;
	open R,">$outdir/kegg.R";
	print R<<RTEXT;
a<-read.table("$outdir/kegg.src", sep="\t")
pdf("$outdir/$key.pdf", width=10, height=$height)
par(mar=c(5,20,2,2), mgp=c(3,0.5,0))
bar=barplot(a[ ,2], names.arg=a[ ,1], horiz=T, col="#1874CD", xlab="Number of unigenes", cex.name=0.8, cex.lab=1.2, cex.main=1.2, main="$key", las=1, border="NA", xlim=c(0, $xlim))
text(a[,2], bar, labels=a[,2], adj=c(0,0), cex=0.7, font=1, pos=4, col="black")
dev.off()
RTEXT
	close R;

	system("/usr/bin/Rscript $outdir/kegg.R");
	system("/usr/bin/convert -density 300 $outdir/$key.pdf $outdir/$key.png");
	system("rm $outdir/kegg.R $outdir/kegg.src");
}

sub xlim_sep{
        my ($num) = @_;
        $num = int(1.05 * $num);
        my $len = (length $num) - 2;
        my $sep = substr($num, 0, 1);
        $sep += 1;
        $sep = (10 ** $len) * $sep;
        my $xlim;
        for(my $i = 1; $i < 100; $i++){
                $xlim = $sep * $i;
                if($xlim > $num){
                        last;
                }
        }
        return ($xlim, $sep);
}
