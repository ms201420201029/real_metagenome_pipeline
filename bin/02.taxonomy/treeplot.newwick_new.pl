open IN, $ARGV[0] or die $!;
open (OUT,">$ARGV[2]") or die $!;

while (<IN>){
	chomp;
	@arr = split /\t/;
	$arr[0] =~ s/[\(|\)|\:]/_/g;
	$d{$arr[0]} = $arr[2];
	$_ = join("\t",@arr);
	print OUT "$_\n";
	
}
close IN;
close OUT;

open IN, $ARGV[1] or die $!;
while (<IN>){
	chomp;
	@tax = ();
	@tax_tmp = split /\t/;
	for $i (@tax_tmp){
		$i =~ s/[\(|\)|\:]/_/g;
		push @tax,$i;
	}
	my $parent = "root";
	foreach $i (0 .. $#tax){
		$name = $tax[$i];
		#print "$name\n";
		$name_pool{$name} = 1;
		$child{$parent}{$name} = 1;
		$level{$i}{$name} = 1;
		$len[$i] = ($len[$i] > (length $name) * 6 + $d{$name} ) ? $len[$i] : ((length $name) * 6 + $d{$name});
		$parent = $name;
	}
}
close IN;
foreach $i (-$#tax .. 0){
	$i = -$i;
	foreach $name (keys %{$level{$i}}){
		$len = $len[$i] - $d{$name};
		if (defined $child{$name}){
			$subtree{$name} = "\(" . (join ",", (map {$subtree{$_}} (keys %{$child{$name}}))) . "\)" . "$name:$len";
		}else {
			$subtree{$name} = "$name:$len";
		}
	}
}
$subtree{'root'} = "(" . (join ",", (map {$_ = $subtree{$_}} (keys %{$child{"root"}}))) . ")" . "root:0;\n";
#
print $subtree{'root'};
