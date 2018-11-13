$sample_list = $ARGV[0];
$spe_profile = $ARGV[1];
open IN, "$sample_list" or die $!;
@_ = <IN>;
%group = map {chomp; split /\t/} @_;
%group_pool = reverse map {chomp; split /\t/} @_;
close IN;
@group = keys %group_pool;
open IN, "$spe_profile" or die $!;
$_ = <IN>;
chomp $_;
@sample = split /\t/;
shift @sample;
print("\t" . (join "\t", @group) . "\n");
while (<IN>){
	chomp;
	@_ = split /\t/;
	$id = shift @_;
	my %abun;
	foreach $i (0 .. $#_) {
		$abun{$group{$sample[$i]}} += $_[$i];
	}
	print "$id";
	foreach $group (@group){
		print "\t$abun{$group}";
	}
	print "\n";
}
close IN;
