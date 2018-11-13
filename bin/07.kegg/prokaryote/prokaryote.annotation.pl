open ANNO, "/data_center_01/pipeline/real_metagenome/real_metagenome_v1.0.0/bin/07.kegg/prokaryote/prokaryote.annotation.tsv" or die $!;
my $entry;
my %anno;
while (<ANNO>) {
	$anno{$entry} .= $_ and next if $_ =~ m/^\t/;
	my $anno = $_;
	($entry) = split /\t/;
	$anno{$entry} = $anno;
}
close ANNO;

print "Gene ID\tEntry\tGene name\tDefinition\tKo\tKo definition\n";
while (<>) {
	chomp;
	my ($gene_id, $entry_name) = split /\t/;
	$anno = $anno{$entry_name};
	$anno =~ s/\n/\n\t/g;
	$anno =~ s/\t$//g;
	print "$gene_id\t$anno";
}
