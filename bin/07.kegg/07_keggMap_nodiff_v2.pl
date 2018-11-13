#!/usr/bin/perl -w

=pod
description: draw KEGG Map, referenced from kegg_parser.pl
author: Wu Chunyan
created date: 20140710
=cut

use Getopt::Long;
use File::Basename 'dirname';
use GD;


my ($ko, $path, $komap, $outdir, $help);

GetOptions("ko:s" => \$ko, "path:s" => \$path,"komap:s" => \$komap, "outdir:s" => \$outdir, "help|?" => \$help);
$outdir ||= ".";

$Bin = dirname($0);
our ($koMap, $mapDir);
do "$Bin/keggConf.pl" || die $!;

sub usage {
	print STDERR << "USAGE";
description: draw KEGG Map, referenced from kegg_parser.pl
usage: perl $0 [options]
options:
	-ko *: result of blast2ko.pl
	-path *: result of pathfind
	-komap: ko_map.tab file, default is "$koMap"
	-outdir: output directory, default is current directory "."
	-help|?: help information
e.g.:
	perl $0 -ko ko -outdir .
USAGE
}

$koMap = $komap if (defined $komap);

if (!defined $ko || !defined $path || defined $help) {
	&usage();
	exit 1;
}

# check input files
$exit = 0;
for ($ko, $path, $koMap) {
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
open PATH, "< $path" || die $!;
<PATH>;
while(<PATH>){
	@temp = split /\t/, $_;
	$mapid=$temp[2];
	$mapid=~s/^ko//;
	@kos=split /\+/,$temp[6];
	foreach $ko (@kos){
		push @{$maps{$ko}},$mapid;
	}	
}
close PATH;

my %poly;
# get image data
open KO, "< $ko" || die $!;
while (<KO>) {
	chomp;
	next if ($_ eq "" or index($_, "#") == 0);
	@temp = split /\t/, $_;
	next if (@temp < 2 || $temp[1] =~ /^\s*$/);
	$color = "red";
	for $ko (split /!+/, $temp[1]) {
		$ko = (split /\|+/, $ko)[0];
		if (exists $maps{$ko}) {
			for $mapId (@{$maps{$ko}}) {
				$mapImg = "map$mapId.png";
				next if (!-f "$mapDir/$mapImg");
				open CONF, "< $mapDir/map$mapId.html" || die $!;
				while (<CONF>) {
					if (/rect\s[^\d]*([\d]+),([\d]+)[^\d]*([\d]+),([\d]+).*$ko(\+.*)*/) {
						push @{$data{$mapImg}}, [$temp[0], $1, $2, $3, $4, $color, "rect"]; # map => [[gene, x1, y1, x2, y2, color], ...]
						push @{$htmlData{"map$mapId"}{"$1,$2,$3,$4"}{$color}{$ko}}, "$temp[0]" if (!exists $htmlData{"map$mapId"}{"$1,$2,$3,$4"}{$color}{$ko} || index("," . join(",", @{$htmlData{"map$mapId"}{"$1,$2,$3,$4"}{$color}{$ko}}) . ",", ",$temp[0],") < 0);
					}
					elsif (/poly\s[^\d]*([\d]+),([\d]+)[^\d]*([\d]+),([\d]+),([\d]+),([\d]+),([\d]+),([\d]+).*$ko(\+.*)*/){
						push @{$data{$mapImg}}, [$temp[0], $1, $2, $3, $4, $5, $6, $7, $8, $color, "poly"];
						push @{$htmlData{"map$mapId"}{"$1,$2,$3,$4,$5,$6,$7,$8"}{$color}{$ko}}, "$temp[0]" if (!exists $htmlData{"map$mapId"}{$color}{$ko} || index("," . join(",", @{$htmlData{"map$mapId"}{"$1,$2,$3,$4,$5,$6,$7,$8"}{$color}{$ko}}) . ",", ",$temp[0],") < 0);
					}
					elsif (/poly\s[^\d]*([\d]+),([\d]+)[^\d]*([\d]+),([\d]+),([\d]+),([\d]+).*$ko(\+.*)*/){
						push @{$data{$mapImg}}, [$temp[0], $1, $2, $3, $4, $5, $6, $color, "poly"];
						push @{$htmlData{"map$mapId"}{"$1,$2,$3,$4,$5,$6"}{$color}{$ko}}, "$temp[0]" if (!exists $htmlData{"map$mapId"}{$color}{$ko} || index("," . join(",", @{$htmlData{"map$mapId"}{"$1,$2,$3,$4,$5,$6"}{$color}{$ko}}) . ",", ",$temp[0],") < 0);
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
#my $map_dir = $koMap;
#$map_dir =~ s/^(\S+)\/(komap\S+)$/$1/g;
#$map_dir .= "\/map";
my $map_htmls = `ls $mapDir/*.html`;
my @maps_arr = split(/\n/, $map_htmls);
my ($shape, $coords, $href);
for my $html_files(@maps_arr){
	open HTML_FILE,"$html_files";
	my $map_name = $html_files;
	$map_name =~ s/.*(map\d\d\d\d\d).html/$1/g;
#	print "$map_name\:\n";
	while(<HTML_FILE>){
		chomp;
		if($_ =~ /<area\s+shape=(\S+)\s+coords=(\S+)\s+href=\"(.*)\"\s+title=\".*\".*\/>/){
			($shape, $coords, $href) = ($1, $2, $3);
			$href =~ s/\s+//g;
			if($href =~ /show_pathway\?(map\d\d\d\d\d)$/){
				$href =~ s/.*(map\d\d\d\d\d)$/$1/g;
				$href .= ".html";
			}
			else{
				$href = "http://www.genome.jp$href";
			}
			$map_points{$map_name}{$coords} = "area shape=\'$shape\' coords=\'$coords\' href=\'$href\'";
#			print "$coords\t";
		}
	}
	close HTML_FILE;
}

# draw image, twice, rect
my ($polyline1, $polyline2, $poly1_x1, $poly1_x2, $poly1_y1, $poly1_y2, $disx, $disy);
my (@tmp_arrx, @tmp_arry);
for $map (sort keys %data) {
#	if ($map eq "map01100" || $map eq "map01110"){
#		next;
#	}
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
	%drawed = ();
	for $b (@{$data{$map}}) {
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
			$col = ($b->[9] eq "red")? $red : $green;
			$polyline1 = new GD::Polygon;
			@tmp_arrx = sort{$a<=>$b}($b->[1], $b->[3], $b->[5], $b->[7]);
			@tmp_arry = sort{$a<=>$b}($b->[2], $b->[4], $b->[6], $b->[8]);
			if($b->[1] == $b->[3] || $b->[2] == $b->[4]){
				$disx = $tmp_arrx[@tmp_arrx-1] - $tmp_arrx[0];
				$disy = $tmp_arry[@tmp_arry-1] - $tmp_arry[0];
				if($disx > $disy){
					$poly1_x1 = $b->[1];
					$poly1_x2 = $b->[3];
					$poly1_y1 = ($b->[2] + $b->[4] + $b->[6] + $b->[8]) / 4;
					$poly1_y2 = ($b->[2] + $b->[4] + $b->[6] + $b->[8]) / 4;
				}
				else{
					$poly1_y1 = $b->[2];
					$poly1_y2 = $b->[4];
					$poly1_x1 = ($b->[1] + $b->[3] + $b->[5] + $b->[7]) / 4;
					$poly1_x2 = ($b->[1] + $b->[3] + $b->[5] + $b->[7]) / 4;
				}
				$polyline1->addPt($poly1_x1, $poly1_y1);
				$polyline1->addPt($poly1_x2, $poly1_y2);
				$im->openPolygon($polyline1, $col);
			}
			else{
				$poly1_x1 = ($b->[1] + $b->[7]) / 2;
				$poly1_y1 = ($b->[2] + $b->[8]) / 2;
				$poly1_x2 = ($b->[3] + $b->[5]) / 2;
				$poly1_y2 = ($b->[4] + $b->[6]) / 2;
				$polyline1->addPt($poly1_x1, $poly1_y1);
				$polyline1->addPt($poly1_x2, $poly1_y2);
				$im->openPolygon($polyline1, $col);
			}
		}
		elsif($b_size == 9){
			$col = ($b->[7] eq "red")? $red : $green;
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
								$b->[$q-1] += 1;
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
	}
	open RES, "> $outdir/$map" || die $!;
	binmode RES;
	print RES $im->png;
	close PNG;
	close RES;
}

# generate html
for $map (keys %htmlData) {
#	if ($map eq "map01100" || $map eq "map01110"){
#		next;
#	}
	open HTML, "> $outdir/$map.html" || die $!;
print HTML<< "HTMLCODE";
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
//->
</script>
</head>
<body>
<map name="$map">
HTMLCODE
	my $hash2 = $map_points{$map};
	foreach my $html_coords(keys %$hash2){
		unless(exists $htmlData{$map}{$html_coords}{"red"}){
			print HTML "<$map_points{$map}{$html_coords} />\n";
		}
	}
	for $rect (keys %{$htmlData{$map}}) {
		if (exists $htmlData{$map}{$rect}{"red"}) {
			$temp = "<ul>";
			$temp .= "<li style=\\\"color: #f00;\\\">Gene<ul>";
			for $ko (keys %{$htmlData{$map}{$rect}{"red"}}) {
				$temp .= "<li>$ko: " . join(", ", @{$htmlData{$map}{$rect}{"red"}{$ko}}) . "</li>";
			}
			$temp .= "</ul></li></ul>";
			if(exists $map_points{$map}{$rect}){
				print HTML "<$map_points{$map}{$rect} onmouseover=\'javascript: showInfo(\"$temp\");\' />\n";
			}
			else{
				print "$map\t$rect\n";
			}
		}
	}
	print HTML "</map>\n<img src='./$map.png' usemap='#$map' />\n<div id='result' style='position: absolute; width: 50%; border: 1px solid #000; background-color: #fff; filter: alpha(opacity=95); opacity: 0.95; font-size: 12px; padding-right: 20px; display: none;' onmouseover=\"javascript: this.style.filter = 'alpha(opacity=100)'; this.style.opacity = 1;\" onmouseout=\"javascript: this.style.filter = 'alpha(opacity=95)'; this.style.opacity = 0.95;\"></div>\n</body></html>";
	close HTML;
}

exit 0;

