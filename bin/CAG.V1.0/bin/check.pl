#!usr/bin/perl -w
use strict;
if ( @ARGV != 1 ){
	die "usage: <IN> .\n";
}
open (IN,"$ARGV[0]")		or die "can't open file <IN>:$!";

my @sample_list;
my $sample_number;
my @data;
my $id;
my $line = 1;
my $i;

local $SIG{__WARN__} = sub {
	my $msg = shift;
	die "The format of data isn't numeric in No.$line!\n" if $msg =~ /isn't numeric/;
};

sub check_number {
	my $item = $_;
	$item += 0;
}

$_ = <IN>;
chomp;
@sample_list = split ' ', $_;
$sample_number = $#sample_list + 1;
while (<IN>){
	chomp;
	@data = split ' ', $_;
	$id = shift @data;
	if ( ($#data + 1) != $sample_number ){
		die "The number of abundance data doesn't match the number of sample in No.$line!\n";
	}
	foreach (@data){ 	
		&check_number($_);
	}
	$line++;
}
close IN;
