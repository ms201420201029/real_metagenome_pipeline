#!/usr/bin/env perl
use strict;
use warnings FATAL => 'all';
use SVG;
use Math::Trig;

## usage
die "usage: perl $0 <profile table> <group file> <outdir>" unless @ARGV == 3;
my ($profile_table, $group_file, $outdir) = @ARGV;

## graph parameter
my $sample_name_font = "Monaco";
my $sample_name_size = 25;
my $number_font = "Monaco";
my $number_size = 25;
#my @color_array = qw(red yellow green blue purple orange);
my @color_array = (
    '#00447E', '#F34800', '#64A10E', '#930026', '#464E04', '#049a0b', '#4E0C66', '#D00000', '#FF6C00',
    '#FF00FF', '#c7475b', '#00F5FF', '#BDA500', '#A5CFED', '#f0301c', '#2B8BC3', '#FDA100', '#54adf5',
    '#CDD7E2', '#9295C1'
);
my $color_alpha = 0.5;
my $short_radius = 135;

## read group
my %group;
open IN, $group_file or die $!;
my @sample1;
while(<IN>){
    chomp;
    my @tabs = split /\t/;
    $group{$tabs[0]} = $tabs[1];
    push @sample1, $tabs[0];
}
my %uniq;
@uniq{values %group} = ();
my @groups = sort keys %uniq;
my $group_num = keys %uniq;


## import profile
open IN, $profile_table or die $!;
chomp(my $sample = <IN>);
chomp($sample = <IN>) if $sample =~ /^# Constructed from/;
my @sample = split /\t/, $sample;
shift @sample;
my %count;
while (<IN>){
    chomp;
    my @abun = split /\t/;
    my $id = shift @abun;
    my @count;
    foreach  my $i (0 .. $#abun) {
        push @count, $sample[$i] if $abun[$i] > 0;
    }
    $count{'core'}++ if $#count == $#sample;
    if(exists $group{$count[0]}){
        $count{$group{$count[0]}}++ if $#count == 0;
        }else{
        next;
    }
}
close IN;
foreach my $sample (@sample1) {
    my $group = $group{$sample};
    $count{$group} = 0 unless defined $count{$group};
    $count{$group} =~ s/(?<=[0-9])(?=([0-9]{3})+$)/,/g;
}
$count{'core'} = 0 unless defined $count{'core'};
$count{'core'} =~ s/(?<=[0-9])(?=([0-9]{3})+$)/,/g;

## draw flower graph
my $svg = SVG -> new(width => 1000, height => 1000);
my $flower = $svg -> group(id => "flower");
foreach my $i(0 .. $group_num - 1) {
    my $angle = $i * 360 / ($group_num);
    my $group = $groups[$i];
    $flower -> ellipse(
        'cx'           => 500,
        'cy'           => 350,
        'rx'           => $short_radius,
        'ry'           => 300,
        'stroke'       => &color_array($i),
        'fill'         => &color_array($i),
        'fill-opacity' => $color_alpha,
        'transform'    => "rotate($angle, 500, 500)"
    );
    my ($x, $y) = rotate(500, 50, 500, 500, $angle);
    $flower -> text(
        'id'  => "group$i",
        'x'   => $x,
        'y'   => $y,
        style => {
            'font-size'   => $sample_name_size,
            'text-anchor' => 'middle'
        }
    ) -> cdata($group);
    ($x, $y) = rotate(500, 100, 500, 500, $angle);
    $flower -> text(
        'id'  => "count$i",
        'x'   => $x,
        'y'   => $y,
        style => {
            'font-size'   => $sample_name_size,
            'text-anchor' => 'middle'
        }
    ) -> cdata($count{$group});
}
$flower -> circle(
    'cx'     => 500,
    'cy'     => 500,
    'r'      => 125,
    'fill'   => 'white',
    'stroke' => 'white'
);
$flower -> text(
    'id'    => "core",
    'x'     => 500,
    'y'     => 500,
    'style' => {
        'font-size'   => $sample_name_size,
        'text-anchor' => 'middle'
    }
) -> cdata("Core $count{'core'}");

## output svg
`mkdir -p $outdir`;
open OUT, ">$outdir/flower.svg" or die $!;
print OUT $svg->xmlify;
`convert -density 200 $outdir/flower.svg $outdir/flower.png`;

sub rotate {
    my ($x, $y, $cx, $cy, $angle) = @_;
    my $pi = 2 * atan2(1, 0);
    $angle = $angle / 180 * $pi;
    my $dx = $x - $cx;
    my $dy = $y - $cy;
    my $nx = cos($angle) * $dx - sin($angle) * $dy + $cx;
    my $ny = sin($angle) * $dx + cos($angle) * $dy + $cy;
    return ($nx, $ny);
}

sub color_array {
    my $i = shift;
    return $color_array[$i % scalar @color_array];
}
