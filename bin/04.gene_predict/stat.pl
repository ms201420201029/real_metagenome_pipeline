# copy from /data_center_07/Project/RY2015K16A01-1/04.gene_predict/bin/stat.pl

print "Sample name\tNumber of ORFs(#)\tRatio of complete ORFs\tTotal length(bp)\tMaximal length(bp)\tAverage length(bp)\n";
while (<>) {
	chomp;
	&stat($_);
}

sub stat {
	$file = shift;
	open IN, "$file" or die $!;
$/ = ">";
<IN>;
my $length = 0;
my $complete = 0;
my $number = 0;
my $max = 0;
while (<IN>){
	chomp;
	@sq = split /\n/;
	$id = shift @sq;
	$id =~ m/^(.*)_GI/;
	$sample = $1;
	$sq = join "", @sq;
	$number   ++;
	$length   += length $sq;
	$complete += ($sq =~ m/^[ATG]TG/i and $sq =~ m/T(AA|AG|GA)$/i) ? 1 : 0;
	$max       = ($max > length $sq) ? $max : length $sq;
}
$/ = "\n";
close IN;
#$num_sample =  scalar keys %sample;
$complete   =  sprintf("%.1f", $complete / $number * 100) . "%";
$aver       =  sprintf("%.1f", $length / $number);
$number     =~ s/(\d+?)(?=(\d{3})+$)/$1,/g;
$length     =~ s/(\d+?)(?=(\d{3})+$)/$1,/g;
$max        =~ s/(\d+?)(?=(\d{3})+$)/$1,/g;
$aver       =~ s/(\d+?)(?=(\d{3})+\.)/$1,/g;
print "$sample\t$number\t$complete\t$length\t$max\t$aver\n";
}
