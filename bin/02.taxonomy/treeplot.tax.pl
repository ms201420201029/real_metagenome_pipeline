use warnings;
require "/data_center_03/USER/zhongwd/lib/math.pm";
@abun = <>;
%abun = map {chomp;split /\t/} @abun;
@sort = sort {$abun{$b} <=> $abun{$a}} keys %abun;
%top = map {($_, 1)} @sort[0 .. 10];
open IN, "/data_center_06/Database/GENOMEall.txt";
while(<IN>){
	chomp;

	s/\(/_/g;
	s/\)//g;

	(undef, $k, $p, $c, $o, $f, $g, $s) = split /\t/;
	next unless defined $abun{$s};
	next if defined $count{$s};

	$p = "phylum_$p" if $p eq $c;

	$count{$s} = 1;
	$abun{$k} += $abun{$s};
	$abun{$p} += $abun{$s};
	$abun{$c} += $abun{$s};
	$abun{$o} += $abun{$s};
	$abun{$f} += $abun{$s};
	$abun{$g} += $abun{$s};
	if (defined $top{$s}){
		$col{$k} = "lightblue";
		$col{$p} = "salmon";
		$col{$c} = "orange";
		$col{$o} = "lightpink";
		$col{$f} = "seagreen";
		$col{$g} = "orchid";
		$col{$s} = "royalblue"; 
		$top{$k} = 1;
		$top{$p} = 1;
		$top{$c} = 1;
		$top{$o} = 1;
		$top{$f} = 1;
		$top{$g} = 1;
		print STDERR "$k\t$p\t$c\t$o\t$f\t$g\t$s\n";
	}
}
close IN;
%sumabun = map {($_, $abun{$_})} keys %top;
$maxabun = sqrt(max(values %sumabun));
#minabun = min(values $sumabun);
%size = map {($_, sqrt($sumabun{$_} / $maxabun) * 50)} keys %sumabun;
foreach (keys %sumabun){
	print "$_\t$col{$_}\t$size{$_}\t$sumabun{$_}\n";
}
