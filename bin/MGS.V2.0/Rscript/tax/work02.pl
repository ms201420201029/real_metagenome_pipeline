open IN,"$ARGV[0]";
while (<IN>){
	chomp;
	@_ = split /\s/;
	$id = shift @_;
	$hash{$id} = $id;
	foreach (@_){
		last if ($_ eq "NA");
		$hash{$id} .= "\t$_";
		$count{$id}++;
	}
}
close IN;
open IN,"$ARGV[1]";
while (<IN>){
	chomp;
	@_ = split /\t/;
	$gene = shift @_;
	$hash2{$gene}{$_} = 1;
}
close IN;
%name = (
	"1" => "kingdom",
	"2" => "phylum",
	"3" => "class",
	"4" => "order",
	"5" => "family",
	"6" => "genus",
	"7" => "species",
	"8" => "strain"
);
foreach $id(sort keys %hash){
	@genes = split /\t/,$hash{$id};
	shift @genes;
	my %tax;
	foreach $gene(@genes){
		next unless exists $hash2{$gene};
		foreach $tax(keys %{$hash2{$gene}}){
			@tax = split /\t/,$tax;
			shift @tax;
			foreach $i(1 .. $#tax){
				$tax{$i}{$tax[$i]}{$gene} = 1;
			}
		}
	}
	foreach $i(sort keys %tax){
		my %num;
		foreach $taxs(keys %{$tax{$i}}){
			$num{$taxs} = scalar keys %{$tax{$i}{$taxs}};
		}
		@numtax = sort {$num{$b} <=> $num{$a}} keys %num;
		if ($num{$numtax[0]} > 0.9 * $count{$id} and $num{$numtax[1]} < 0.9 * $count{$id}){
			$ratio = $num{$max} / $count{$id};
			$level{$id} = $name{$i};
			$species{$id} = $numtax[0];
			$numtax{$id} = $num{$numtax[0]};
			$pertax{$id} = $num{$numtax[0]} / $count{$id};
		}
	}
	print "$id\t$count{$id}\t$species{$id}\t$level{$id}\t$numtax{$id}\t$pertax{$id}\n";
}
