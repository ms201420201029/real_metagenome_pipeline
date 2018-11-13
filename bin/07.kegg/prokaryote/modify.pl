while (<>) {
	chomp;
	my ($gene, $info, $gene_name, $ko, $ko_func);
	($gene, $info) = split /\t/;
	if ($info =~ s/^(\w+); //g){
		$gene_name = $1;
	}
	if ($info =~ s/(K[0-9]{5}) (.*)//g) {
		$ko = $1;
		$ko_func = $2;
	}
	print "$gene\t$gene_name\t$info\t$ko\t";
	while ($ko_func =~ s/(K[0-9]{5}) (.*)//g) {
		print "$ko_func\n";
		$ko = $1;
		$ko_func = $2;
		print "\t\t\t$ko\t";
	}
	print "$ko_func\n";
}
