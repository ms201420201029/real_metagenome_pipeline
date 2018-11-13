$/ = ">";
<>;
my $max = 0;
while (<>){
	chomp;
	@sq = split /\n/;
	$id = shift @sq;
	$id =~ m/^(.*)_GI/;
	$sample{$1} = 1;
	$sq = join "", @sq;
	$number   ++;
	$length   += length $sq;
	$complete += ($sq =~ m/^[ATG]TG/i and $sq =~ m/T(AA|AG|GA)$/i) ? 1 : 0;
	$max       = ($max > length $sq) ? $max : length $sq;
}
$/ = "\n";
$num_sample =  scalar keys %sample;
$complete   =  sprintf("%.1f", $complete / $number * 100) . "%";
$aver       =  sprintf("%.1f", $length / $number);
$number     =~ s/(\d+?)(?=(\d{3})+$)/$1,/g;
$length     =~ s/(\d+?)(?=(\d{3})+$)/$1,/g;
$max        =~ s/(\d+?)(?=(\d{3})+$)/$1,/g;
$aver       =~ s/(\d+?)(?=(\d{3})+\.)/$1,/g;
print "Number of samples(#)\tNumber of ORFs(#)\tRatio of complete ORFs\tTotal length(bp)\tMaximal length(bp)\tAverage length(bp)\n";
print "$num_sample\t$number\t$complete\t$length\t$max\t$aver\n";
