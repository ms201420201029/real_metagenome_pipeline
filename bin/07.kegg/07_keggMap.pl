#!/usr/bin/perl -w

=pod
description: draw KEGG Map, referenced from kegg_parser.pl
author: Zhang Fangxian, zhangfx@genomics.cn
created date: 20090728
modified date: 20131216(wuchunyan),20100824, 20100406, 20100205, 20091224, 20091204, 20091127, 20091124, 20091123, 20091119, 20091010, 20090918, 20090825, 20090806, 20090731
=cut

use Getopt::Long;
use File::Basename 'dirname';
use File::Path 'mkpath';
use FindBin '$Bin';
use GD;


my ($ko, $komap, $diff, $outdir, $help, $mapdir, $species);

GetOptions("species:s" => \$species, "mapdir:s" => \$mapdir, "ko:s" => \$ko, "komap:s" => \$komap, "diff:s" => \$diff, "outdir:s" => \$outdir, "help|?" => \$help);
$outdir ||= ".";
our ($koMap, $mapDir);
do "$Bin/keggConf.pl";
$koMap2=$koMap;
$koMap = $komap if (defined $komap);
$mapDir = $mapdir if(defined $mapdir);
print $mapDir."\n";

sub usage {
	print STDERR << "USAGE";
description: draw KEGG Map, referenced from kegg_parser.pl
usage: perl $0 [options]
options:
	-ko *: result of blast2ko.pl
	-komap: ko_map.tab file, default is "$koMap2";
        -mapdir <path>  map derectory;
        -diff <file> *  *.DiffGeneExpFilter.xls
        -outdir <path>  output directory, default is current directory "."
        -help|?         help information
e.g.:
        perl $0 -ko ko -diff A.DiffGeneExpFiltr.xls -outdir . -species sce -komap /ifs2/BC_MG/PROJECT/RNA/Database/Saccharomyces_cerevisiae_S288C/ko_go_sgd/sce.ko_map.tab  -mapdir /ifs2/BC_MG/PROJECT/RNA/Database/Saccharomyces_cerevisiae_S288C/ko_go_sgd/map/

USAGE
}


if (!defined $ko || !defined $diff || defined $help) {
	&usage();
	exit 1;
}

# check input files
my $exit = 0;
for ($ko, $diff, $koMap) {
	if (! -f $_) {
		print STDERR "file $_ not exists\n";
		$exit = 1;
	}
}
exit 1 if ($exit == 1);

if (!-d $mapDir) {
	print STDERR "KEGG map directory $mapDir not exists\n";
	exit 1;
}

system("mkdir -p $outdir") if (!-d $outdir);

# main
local($/);
open KOMAP, "< $koMap" || die $!;
$all_in = <KOMAP>;
$all_in =~ s/\n+$//;
close KOMAP;
@all_ins = split /\n/, $all_in;
for $line (@all_ins) {
	@temp = split /\t/, $line;
	@{$maps{$temp[0]}} = split /\s/, $temp[1];
}
undef($all_in);
undef(@all_ins);
local($/) = "\n";

# get ratio
open DIFF, "< $diff" || die $!;
<DIFF>;
while (<DIFF>) {
	chomp;
	@temp = split /\t/, $_;
	$ratios{$temp[0]} = sprintf("%.1f", $temp[5]);
}
close DIFF;

# get image data
if(defined $species){$pre=$species;}else{$pre="map";} ##### wuchunyan at 2013-08-05

open KO, "< $ko" || die $!;
while (<KO>) {
	chomp;
	next if ($_ eq "" or index($_, "#") == 0);
	@temp = split /\t/, $_;
	next if (@temp < 2 || $temp[1] =~ /^\s*$/);
	$color = "red";
	for $ko (split /!+/, $temp[1]) {
		$ko = (split /\|+/, $ko)[0];
		if (exists $maps{$ko} && exists $ratios{$temp[0]}) {
			$color = "green" if ($ratios{$temp[0]} < 0);
			for $mapId (@{$maps{$ko}}) {
				$mapImg = "$pre$mapId.png";
				next if (! -f "$mapDir/$mapImg");
				open CONF, "< $mapDir/$pre$mapId.html" || die $!;
				while (<CONF>) {
                                        if(defined $species){$Temp=$temp[0];}else{$Temp=$ko;} ##### wuchunyan at 20131014
=pod
					if (/rect\s\(([\d]+),([\d]+)\)\s\(([\d]+),([\d]+)\)\t.*$ko\+.*\+([^\+]+)\+[^\+]*$/) {
						push @{$data{$mapFile}}, [$temp[0], $1, $2, $3, $4, $5, $color]; # map => [[gene, x1, y1, x2, y2, EC, color], ...]
					}
=cut
					if (/rect\s[^\d]*([\d]+),([\d]+)[^\d]*([\d]+),([\d]+).*$Temp(\+.*)*/) {  ##### wuchunyan at 20131014
						push @{$data{$mapImg}}, [$temp[0], $1, $2, $3, $4, $color, "rect"]; # map => [[gene, x1, y1, x2, y2, color], ...]
						$htmlData{"$pre$mapId"}{"$1,$2,$3,$4"}{$color}{$ko}{$temp[0]} = $ratios{$temp[0]};  ##### wuchunyan at 20131014
					}
					elsif (/poly\s[^\d]*([\d]+),([\d]+)[^\d]*([\d]+),([\d]+),([\d]+),([\d]+),([\d]+),([\d]+).*$Temp(\+.*)*/){ ##### wuchunyan at 20131014
						push @{$data{$mapImg}}, [$temp[0], $1, $2, $3, $4, $5, $6, $7, $8, $color, "poly"];
						$htmlData{"$pre$mapId"}{"$1,$2,$3,$4,$5,$6,$7,$8"}{$color}{$ko}{$temp[0]} = $ratios{$temp[0]}; ##### wuchunyan at 20131014
					}
					elsif (/poly\s[^\d]*([\d]+),([\d]+)[^\d]*([\d]+),([\d]+),([\d]+),([\d]+).*$Temp(\+.*)*/){    ##### wuchunyan at 20131014
						push @{$data{$mapImg}}, [$temp[0], $1, $2, $3, $4, $5, $6, $color, "poly"];
						$htmlData{"$pre$mapId"}{"$1,$2,$3,$4,$5,$6"}{$color}{$ko}{$temp[0]} = $ratios{$temp[0]};  ##### wuchunyan at 20131014
					}
				}
				close CONF;
			}
		}
	}
}
close KO;

# get other points
my %map_points;
my $map_dir = $mapDir;
#$map_dir =~ s/^(\S+)\/(komap\S+)$/$1/g;
#$map_dir .= "\/map";
my $map_htmls = `ls $map_dir/*.html`;
my @maps_arr = split(/\n/, $map_htmls);
my ($shape, $coords, $href);
for my $html_files(@maps_arr){
        open HTML_FILE,"$html_files";
        my $map_name = $html_files;
        $map_name =~ s/.*($pre\d\d\d\d\d).html/$1/g;  ##### wuchunyan at 20131014
#       print "$map_name\:\n";
        while(<HTML_FILE>){
                chomp;
                if($_ =~ /<area\s+shape=(\S+)\s+coords=(\S+)\s+href=\"(.*)\"\s+title=\".*\".*\/>/){
                        ($shape, $coords, $href) = ($1, $2, $3);
                        $href =~ s/\s+//g;
                        if($href =~ /show_pathway\?($pre\d\d\d\d\d)$/){  ##### wuchunyan at 20131014
                                $href =~ s/.*($pre\d\d\d\d\d)$/$1/g;  ##### wuchunyan at 20131014
                                $href .= ".html";
                        }
                        else{
                                $href = "http://www.genome.jp$href";
                        }
                        $map_points{$map_name}{$coords} = "area shape=\'$shape\' coords=\'$coords\' href=\'$href\'";
#                       print "$coords\t";
                }
        }
        close HTML_FILE;
}

my ($polyline1, $polyline2, $poly1_x1, $poly1_x2, $poly1_y1, $poly1_y2, $poly1_x3, $poly1_x4, $poly1_y3, $poly1_y4, $disx, $disy);
my (@tmp_arrx, @tmp_arry);
# draw image, twice
for $map (sort keys %data) {
	if ($map eq "map01100" || $map eq "map01110"){
		next;
	}
	open PNG, "< $mapDir/$map" || die $!;
	$im = GD::Image->new(*PNG);
	open RES, "> $outdir/$map" || die $!;
	binmode RES;
	print RES $im->png;
	close PNG;
	close RES;

	open PNG, "< $outdir/$map" || die $!;
	$im = GD::Image->new(*PNG);
	$red = $im->colorAllocate(255, 0, 0);
	$green = $im->colorAllocate(0, 255, 0);
	#$black = $im->colorAllocate(0, 0, 0);
	%drawed = ();
	for $b (@{$data{$map}}) {
		#$col = ($b->[6] eq "red")? $red : $green;
		#$im->filledRectangle($b->[1], $b->[2], $b->[3], $b->[4], $col);
		#$im->string(gdSmallFont, $b->[1], $b->[2] + 2, $b->[5], $black);
		my $b_size = scalar @{$b};
		if($b_size == 7){
			$col = ($b->[5] eq "red")? $red : $green;
			if (!exists $drawed{"$b->[1], $b->[2], $b->[3], $b->[4]"}) {
				$drawed{"$b->[1], $b->[2], $b->[3], $b->[4]"} = 1;
				$im->rectangle($b->[1], $b->[2], $b->[3], $b->[4], $col);
				$im->rectangle($b->[1] + 1, $b->[2] + 1, $b->[3] - 1, $b->[4] - 1, $col);
			} else {
				@points = ();
				$points[0] = [$b->[1], ($b->[2] + $b->[4]) / 2];
				$points[3] = [$b->[3],$points[0]->[1]];
				if ($b->[5] eq "red") {
					$flag = 1;
					$points[1] = [$b->[1], $b->[2]];
					$points[2] = [$b->[3], $b->[2]];
				} else {
					$flag = -1;
					$points[1] = [$b->[1], $b->[4]];
					$points[2] = [$b->[3], $b->[4]];
				}
				for $i (1 .. $#points) {
					$im->line($points[$i - 1]->[0], $points[$i - 1]->[1], $points[$i]->[0], $points[$i]->[1], $col);
				}
				$points[0]->[0]++;
				$points[1]->[0]++;
				$points[1]->[1] += $flag;
				$points[2]->[0]--;
				$points[2]->[1] += $flag;
				$points[3]->[0]--;
				for $i (1 .. $#points) {
					$im->line($points[$i - 1]->[0], $points[$i - 1]->[1], $points[$i]->[0], $points[$i]->[1], $col);
				}
			}
		}
		elsif($b_size == 11){
			$col = ($b->[9] eq "red") ? $red : $green;
			if(!exists $drawed{"$b->[1],$b->[2],$b->[3],$b->[4],$b->[5],$b->[6],$b->[7],$b->[8]"}){
				$drawed{"$b->[1],$b->[2],$b->[3],$b->[4],$b->[5],$b->[6],$b->[7],$b->[8]"} = $b->[9];
				$polyline1 = new GD::Polygon;
				@tmp_arrx = sort{$a<=>$b}($b->[1], $b->[3], $b->[5], $b->[7]);
				@tmp_arry = sort{$a<=>$b}($b->[2], $b->[4], $b->[6], $b->[8]);
				if($b->[1] == $b->[3] || $b->[2] == $b->[4]){
					$disx = $tmp_arrx[@tmp_arrx-1] - $tmp_arrx[0];
					$disy = $tmp_arry[@tmp_arry-1] - $tmp_arry[0];
					if($disx > $disy){
						$poly1_x1 = $b->[1];
						$poly1_x2 = $b->[3];
						$poly1_x3 = $b->[1];
						$poly1_x4 = $b->[3];
						$poly1_y1 = ($b->[2] + $b->[4] + $b->[6] + $b->[8]) / 4 - 0.5;
						$poly1_y2 = ($b->[2] + $b->[4] + $b->[6] + $b->[8]) / 4 - 0.5;
						$poly1_y3 = ($b->[2] + $b->[4] + $b->[6] + $b->[8]) / 4 + 0.5;
						$poly1_y4 = ($b->[2] + $b->[4] + $b->[6] + $b->[8]) / 4 + 0.5;
					}
					else{
						$poly1_y1 = $b->[2];
						$poly1_y2 = $b->[4];
						$poly1_y3 = $b->[2];
						$poly1_y4 = $b->[4];
						$poly1_x1 = ($b->[1] + $b->[3] + $b->[5] + $b->[7]) / 4 - 0.5;
						$poly1_x2 = ($b->[1] + $b->[3] + $b->[5] + $b->[7]) / 4 - 0.5;
						$poly1_x3 = ($b->[1] + $b->[3] + $b->[5] + $b->[7]) / 4 + 0.5;
						$poly1_x4 = ($b->[1] + $b->[3] + $b->[5] + $b->[7]) / 4 + 0.5;
					}
					$polyline1->addPt($poly1_x1, $poly1_y1);
					$polyline1->addPt($poly1_x2, $poly1_y2);
					$polyline1->addPt($poly1_x3, $poly1_y3);
					$polyline1->addPt($poly1_x4, $poly1_y4);
					$im->openPolygon($polyline1, $col);
				}
				else{
					$poly1_x1 = ($b->[1] + $b->[7]) / 2 - 0.5;
					$poly1_y1 = ($b->[2] + $b->[8]) / 2;
					$poly1_x2 = ($b->[1] + $b->[7]) / 2 + 0.5;
					$poly1_y2 = ($b->[2] + $b->[8]) / 2;
					$poly1_x3 = ($b->[3] + $b->[5]) / 2 - 0.5;
					$poly1_y3 = ($b->[4] + $b->[6]) / 2;
					$poly1_x4 = ($b->[3] + $b->[5]) / 2 + 0.5;
					$poly1_y4 = ($b->[4] + $b->[6]) / 2;
					$polyline1->addPt($poly1_x1, $poly1_y1);
					$polyline1->addPt($poly1_x2, $poly1_y2);
					$polyline1->addPt($poly1_x3, $poly1_y3);
					$polyline1->addPt($poly1_x4, $poly1_y4);
					$im->openPolygon($polyline1, $col);
				}
			}
			else{
				unless($drawed{"$b->[1],$b->[2],$b->[3],$b->[4],$b->[5],$b->[6],$b->[7],$b->[8]"} =~ /$b->[9]/){
					$drawed{"$b->[1],$b->[2],$b->[3],$b->[4],$b->[5],$b->[6],$b->[7],$b->[8]"} .= $b->[9];
					$polyline1 = new GD::Polygon;
					@tmp_arrx = sort{$a<=>$b}($b->[1], $b->[3], $b->[5], $b->[7]);
					@tmp_arry = sort{$a<=>$b}($b->[2], $b->[4], $b->[6], $b->[8]);
					if($b->[1] == $b->[3] || $b->[2] == $b->[4]){
						$disx = $tmp_arrx[@tmp_arrx-1] - $tmp_arrx[0];
						$disy = $tmp_arry[@tmp_arry-1] - $tmp_arry[0];
						if($disx > $disy){
							$poly1_x1 = $b->[1];
							$poly1_x2 = $b->[3];
							$poly1_y1 = ($b->[2] + $b->[4] + $b->[6] + $b->[8]) / 4 - 0.5;
							$poly1_y2 = ($b->[2] + $b->[4] + $b->[6] + $b->[8]) / 4 - 0.5;
						}
						else{
							$poly1_y1 = $b->[2];
							$poly1_y2 = $b->[4];
							$poly1_x1 = ($b->[1] + $b->[3] + $b->[5] + $b->[7]) / 4 - 0.5;
							$poly1_x2 = ($b->[1] + $b->[3] + $b->[5] + $b->[7]) / 4 - 0.5;
						}
						$polyline1->addPt($poly1_x1, $poly1_y1);
						$polyline1->addPt($poly1_x2, $poly1_y2);
						$im->openPolygon($polyline1, $col);
					}
					else{
						$poly1_x1 = ($b->[1] + $b->[7]) / 2 + 0.5;
						$poly1_y1 = ($b->[2] + $b->[8]) / 2;
						$poly1_x2 = ($b->[3] + $b->[5]) / 2 + 0.5;
						$poly1_y2 = ($b->[4] + $b->[6]) / 2;
						$polyline1->addPt($poly1_x1, $poly1_y1);
						$polyline1->addPt($poly1_x2, $poly1_y2);
						$im->openPolygon($polyline1, $col);
					}
				}
			}
		}
		elsif($b_size == 9){
			$col = ($b->[7] eq "red") ? $red : $green;
			if (!exists $drawed{"$b->[1],$b->[2],$b->[3],$b->[4],$b->[5],$b->[6]"}){
				$drawed{"$b->[1],$b->[2],$b->[3],$b->[4],$b->[5],$b->[6]"} = $b->[7];
				$polyline2 = new GD::Polygon;
				for(my $p = 1; $p <= 6; $p++){
					for(my $q = 2; $q <= 6; $q++){
						if($p < $q && $b->[$p] == $b->[$q]){
							if($p =~ /1|3|5/){
								if($b->[$p+1] < $b->[$q+1]){
									$b->[$p+1] -= 1;
									$b->[$q+1] += 1;
								}
								else{
									$b->[$p+1] += 1;
									$b->[$q+1] -= 1;
								}
							}
							else{
								if($b->[$p-1] < $b->[$q-1]){
									$b->[$p-1] -= 1;
									$b->[$q-1] += 1;
								}
								else{
									$b->[$p-1] += 1;
									$b->[$q-1] -= 1;
								}
							}
						}
					}
				}
				$polyline2->addPt($b->[1], $b->[2]);
				$polyline2->addPt($b->[3], $b->[4]);
				$polyline2->addPt($b->[5], $b->[6]);
				$im->filledPolygon($polyline2, $col);
			}
			else{
				unless($drawed{"$b->[1],$b->[2],$b->[3],$b->[4],$b->[5],$b->[6]"} =~ /$b->[7]/){
					$drawed{"$b->[1],$b->[2],$b->[3],$b->[4],$b->[5],$b->[6]"} .= $b->[7];
					($b->[1], $b->[2], $b->[3], $b->[4], $b->[5], $b->[6]) = &trianble_coord($b->[1], $b->[2], $b->[3], $b->[4], $b->[5], $b->[6]);
					$polyline2 = new GD::Polygon;
					$polyline2->addPt($b->[1], $b->[2]);
					$polyline2->addPt($b->[3], $b->[4]);
					$polyline2->addPt($b->[5], $b->[6]);
					$im->filledPolygon($polyline2, $col);
				}
			}
		}
	}
	open RES, "> $outdir/$map" || die $!;
	binmode RES;
	print RES $im->png;
	close PNG;
	close RES;
}

# generate html
for $map (keys %htmlData) {
	if ($map eq "map01100" || $map eq "map01110"){
		next;
	}
	open HTML, "> $outdir/$map.html" || die $!;
	print HTML << "HTMLCODE";
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<title>$map</title>
<style type="text/css">
<!--
area {cursor: pointer;}
-->
</style>
<script type="text/javascript">
<!--
function showInfo(info) {
	obj = document.getElementById("result");
	obj.innerHTML = "<div style='cursor: pointer; position: absolute; right: 5px; color: #000;' onclick='javascript: document.getElementById(\\\"result\\\").style.display = \\\"none\\\";' title='close'>X</div>" + info;
	obj.style.top = document.body.scrollTop;
	obj.style.left = document.body.scrollLeft;
	obj.style.display = "";
}
//-->
</script>
</head>
<body>
<map name="$map">
HTMLCODE
        my $hash2 = $map_points{$map};
        foreach my $html_coords(keys %$hash2){
                unless(exists $htmlData{$map}{$html_coords}{"red"} || exists $htmlData{$map}{$html_coords}{"green"}){
                        print HTML "<$map_points{$map}{$html_coords} />\n";
                }
        }

	for $rect (keys %{$htmlData{$map}}) {
		if (exists $htmlData{$map}{$rect}{"red"} || exists $htmlData{$map}{$rect}{"green"}){
			$temp = "<ul>";
			if (exists $htmlData{$map}{$rect}{"red"}) {
				$temp .= "<li style=\\\"color: #f00;\\\">Up regulated<ul>";
				for $ko (sort {&max(\%{$htmlData{$map}{$rect}{"red"}{$b}}) <=> &max(\%{$htmlData{$map}{$rect}{"red"}{$a}})} keys %{$htmlData{$map}{$rect}{"red"}}) {
					$temp .= "<li>$ko: ";
					for $gene (sort {abs($htmlData{$map}{$rect}{"red"}{$ko}{$b}) <=> abs($htmlData{$map}{$rect}{"red"}{$ko}{$a})} keys %{$htmlData{$map}{$rect}{"red"}{$ko}}) {
						$temp .= "$gene ($htmlData{$map}{$rect}{'red'}{$ko}{$gene}), ";
					}
					$temp =~ s/, $/<\/li>/;
				}
				$temp .= "</ul></li>";
			}
			if (exists $htmlData{$map}{$rect}{"green"}) {
				$temp .= "<li style=\\\"color: #0f0;\\\">Down regulated<ul>";
				for $ko (sort {&max(\%{$htmlData{$map}{$rect}{"green"}{$b}}) <=> &max(\%{$htmlData{$map}{$rect}{"green"}{$a}})} keys %{$htmlData{$map}{$rect}{"green"}}) {
					$temp .= "<li>$ko: ";
					for $gene (sort {abs($htmlData{$map}{$rect}{"green"}{$ko}{$b}) <=> abs($htmlData{$map}{$rect}{"green"}{$ko}{$a})} keys %{$htmlData{$map}{$rect}{"green"}{$ko}}) {
						$temp .= "$gene ($htmlData{$map}{$rect}{'green'}{$ko}{$gene}), ";
					}
					$temp =~ s/, $/<\/li>/;
				}
				$temp .= "</ul></li>";
			}
			$temp .= "</ul>";
			if(exists $map_points{$map}{$rect}){
				print HTML "<$map_points{$map}{$rect} onmouseover=\'javascript: showInfo(\"$temp\");\' />\n";
			}
		}
	}
	print HTML "</map>\n<img src='./$map.png' usemap='#$map' />\n<div id='result' style='position: absolute; width: 50%; border: 1px solid #000; background-color: #fff; filter: alpha(opacity=95); opacity: 0.95; font-size: 12px; padding-right: 20px; display: none;' onmouseover=\"javascript: this.style.filter = 'alpha(opacity=100)'; this.style.opacity = 1;\" onmouseout=\"javascript: this.style.filter = 'alpha(opacity=95)'; this.style.opacity = 0.95;\"></div>\n</body></html>";

#	open HTML, "> $outdir/$map.html" || die $!;
#	print HTML $html;
	close HTML;
}

exit 0;

sub max {
	my ($genes) = @_;
	for my $gene (sort {abs($genes->{$b}) <=> abs($genes->{$a})} keys %{$genes}) {
		return abs($genes->{$gene});
	}
}

sub trianble_coord{
	my ($trx1, $try1, $trx2, $try2, $trx3, $try3) = @_;
	if($trx1 == $trx2){
		$try1 = ($try2 > $try1) ? ($try1 - 1) : ($try2 - 1);
		$try2 = $try3 - 1;
	}
	elsif($trx1 == $trx3){
		$try1 = ($try3 > $try1) ? ($try1 - 1) : ($try3 - 1);
		$try3 = $try2 - 1;
	}
	elsif($trx2 == $trx3){
		$try2 = ($try3 > $try2) ? ($try2 - 1) : ($try3 - 1);
		$try3 = $try1 - 1;
	}
	elsif($try1 == $try2){
		$trx1 = ($trx2 > $trx1) ? ($trx2 - 1) : ($trx1 - 1);
		$trx2 = $trx3 - 1;
	}
	elsif($try1 == $try3){
		$trx1 = ($trx3 > $trx1) ? ($trx3 - 1) : ($trx1 - 1);
		$trx3 = $trx2 - 1;
	}
	elsif($try2 == $try3){
		$trx2 = ($trx3 > $trx2) ? ($trx3 - 1) : ($trx2 - 1);
		$trx3 = $trx1 - 1;
	}
	return ($trx1, $try1, $trx2, $try2, $trx3, $try3);
}
