while (<>){
	chomp;
	@_ = split /\s/;
	$id = shift @_;
	foreach (@_){
		last if ($_ eq "NA");
		print "$_\n";
	}
}
