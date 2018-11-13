# copy from /data_center_07/Project/RY2015K16A01-1/03.assembly/bin/stat.pl

print "Sample name\tKmer\tNumber of contigs (#)\tN50 length (bp)\tN90 length (bp)\tTotal length (bp)\tMaximal length (bp)\tAverage length(bp)\n";
while (<>) {
	chomp;
	open IN, "$_" or die $!;
	#($sample) = $_ =~ m/.*\/(.*?)\.Kmer/;
	if ($_ =~ /Kmer/){
		($sample) = $_ =~ m/.*\/(.*?)\.Kmer/;
	}else{
		($sample) = $_ =~ m/.*\/(.*?)\.scaftigs/;
	}
	@_ = <IN>;
	my %stat = map {chomp;split /\t/} @_;
	@stat = ($sample,
		 $stat{'Kmer'},
		 &format_num($stat{'contignum'}, 'longint'),
		 &format_num($stat{'N50'}, 'longint'),
		 &format_num($stat{'N90'}, 'longint'),
		 &format_num($stat{'totallen'}, 'longint'),
		 &format_num($stat{'maxlength'}, 'longint'),
		 &format_num($stat{'average'}, 'longint'));
	print ((join "\t", @stat) . "\n");
}

sub format_num{
        my ($num, $format) = @_;
        if     ($format eq "longint"){
                $num =~ s/(\d+?)(?=(\d{3})+$)/$1,/g;
        }elsif ($format eq "ratio"){
                $num = sprintf ("%.2f", $num * 100) . "%";
        }
        return $num;
}
