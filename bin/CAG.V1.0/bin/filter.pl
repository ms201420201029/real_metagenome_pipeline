open IN,"$ARGV[0]";
while (<IN>){
	@_ = split ' ';
	scalar @_ >= $ARGV[1]+1 and print;
}
close IN;
