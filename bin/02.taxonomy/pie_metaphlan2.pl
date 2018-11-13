use SVG;
use Math::Trig;
sub pie_chart {
	($bottom, $left, $top, $right, $abun_p) = @_;
	## plot params
	$pie_radius = 400;
	$ticks_length = 15;
	$font_size = 20;
	## ticks name
	my %tick_name_pos = ();
	my $rad;
	my $svg = SVG -> new('width' => ($right - $left) + 10, 'height' => ($top - $bottom) + 10);
	my $centre_x = -$left + 5;
	my $centre_y = $top + 5;
	my $count_ticks = 0;
	my $abun_other = 1;
	foreach $tick_name (sort {$abun_p->{$b} <=> $abun_p->{$a}} keys %$abun_p){
		$abun = $abun_p->{$tick_name};
		$rad += $abun * pi;
		$ang = $rad * 360 / 2 / pi;
		@rad_range = ($rad - $abun * pi, $rad + $abun * pi);
		@fan_range = ($centre_x + cos($rad_range[0]) * $pie_radius, $centre_y - sin($rad_range[0]) * $pie_radius, $centre_x + cos($rad_range[1]) * $pie_radius, $centre_y - sin($rad_range[1]) * $pie_radius);
		$is_big_arc = ($abun > 0.5) ? 1 : 0;
		$svg -> path('d' => "M$centre_x $centre_y
				     L$fan_range[0] $fan_range[1]
				     A$pie_radius $pie_radius 0 $is_big_arc 0 $fan_range[2] $fan_range[3]",
			     'fill' => &colors($count_ticks), 'stroke' => 'black', 'stroke-width' => 0.5);
		$svg -> line('id' => "$tick_name\_tick",
			     'x1' => ($centre_x + $pie_radius),                 'y1' => $centre_y,
			     'x2' => ($centre_x + $pie_radius + $ticks_length), 'y2' => $centre_y,
			     'style' =>{'stroke' => 'black', 'stroke-width' => 0.5},
			     'transform' => "rotate(-$ang, $centre_x, $centre_y)") if $count_ticks < $ticks_num;
		$direction = ($rad > pi / 2 and $rad < 3 * pi / 2) ? 'end' : 'start';
		my $tick_name_height = $font_size * 0.625;
		$svg -> text('id' => "$tick_name\_tick_name",
			     'x' => $centre_x + cos($rad) * ($pie_radius + 1.1 * $ticks_length),
			     'y' => $centre_y - sin($rad) * ($pie_radius + 1.1 * $ticks_length) + $tick_name_height / 2,
			     'style' => {'font-family' => 'Arial', 'font-size' => $font_size, 'text-anchor' => $direction}) -> cdata($tick_name) if $count_ticks < $ticks_num;
		$rad += $abun * pi;
		$count_ticks ++;
		$abun_other -= $abun;
	}
	## Others
#	$tick_name = "Other";
	$abun = $abun_other;
	$rad += $abun * pi;
	$ang = $rad * 360 / 2 / pi;
	@rad_range = ($rad - $abun * pi, $rad + $abun * pi);
	@fan_range = ($centre_x + cos($rad_range[0]) * $pie_radius, $centre_y - sin($rad_range[0]) * $pie_radius, $centre_x + cos($rad_range[1]) * $pie_radius, $centre_y - sin($rad_range[1]) * $pie_radius);
	$is_big_arc = ($abun_other > 0.5) ? 1 : 0;
	$svg -> path('d' => "M$centre_x $centre_y
			     L$fan_range[0] $fan_range[1]
			     A$pie_radius $pie_radius 0 $is_big_arc 0 $fan_range[2] $fan_range[3]",
		     'fill' => 'black', 'stroke' => 'black', 'stroke-width' => 0.5);
	$svg -> line('id' => "other_tick",
			     'x1' => ($centre_x + $pie_radius),                 'y1' => $centre_y,
			     'x2' => ($centre_x + $pie_radius + $ticks_length), 'y2' => $centre_y,
			     'style' =>{'stroke' => 'black', 'stroke-width' => 0.5},
			     'transform' => "rotate(-$ang, $centre_x, $centre_y)");
	$direction = ($rad > pi / 2 and $rad < 3 * pi / 2) ? 'end' : 'start';
	my $tick_name_height = $font_size * 0.625;
	$svg -> text('id' => "$tick_name\_other",
		     'x' => $centre_x + cos($rad) * ($pie_radius + 1.1 * $ticks_length),
		     'y' => $centre_y - sin($rad) * ($pie_radius + 1.1 * $ticks_length) + $tick_name_height / 2,
		     'style' => {'font-family' => 'Arial', 'font-size' => $font_size, 'text-anchor' => $direction}) -> cdata("Other");

	return $svg -> xmlify; 
}
sub pre_pie_chart {
	$abun_p = shift;
	## plot params
	$pie_radius = 500;
	$ticks_length = 20;
	$font_size = 20;
	## ticks name
	my %tick_name_pos = ();
	my $tick_name_height = $font_size * 0.625;
	my $rad;
	foreach $tick_name (sort {$abun_p->{$b} <=> $abun_p->{$a}} keys %$abun_p){
		$abun = $abun_p->{$tick_name};
		$rad += $abun * pi;
		$direction = ($rad > pi / 2 and $rad < 3 * pi / 2) ? 'left' : 'right';
		$tick_name_width = length($tick_name) * $font_size * 0.625;
		if ($direction eq 'left'){
			$tick_name_right = cos($rad) * ($pie_radius + 1.1 * $ticks_length);
			$tick_name_left = $tick_name_right - length($tick_name) * $font_size * 0.625;
		}else {
			$tick_name_left = cos($rad) * ($pie_radius + 1.1 * $ticks_length);
			$tick_name_right = $tick_name_left + length($tick_name) * $font_size * 0.625;
		}
		$tick_name_bottom = sin($rad) * ($pie_radius + 1.1 * $ticks_length) - $tick_name_height / 2;
		last if &is_overlap($tick_name_left, $tick_name_right, $tick_name_bottom, $tick_name_height, \%tick_name_pos);
		$tick_name_pos{$tick_name} = "$tick_name_left,$tick_name_right,$tick_name_bottom";
		$rad += $abun * pi;
	}
	$left = -$pie_radius;
	$right = $pie_radius;
	$top = $pie_radius;
	$bottom = -$pie_radius;
	foreach $tick_name_pos(values %tick_name_pos){
		($tick_name_left, $tick_name_right, $tick_name_bottom) = split /,/, $tick_name_pos;
		$left = ($left < $tick_name_left) ? $left : $tick_name_left;
		$right = ($right > $tick_name_right) ? $right : $tick_name_right;
		$top = ($top > $tick_name_bottom) ? $top : $tick_name_bottom;
		$bottom = ($bottom < $tick_name_bottom) ? $bottom : $tick_name_bottom;
	}
	$top += $tick_name_height;
	return ($bottom, $left, $top, $right, scalar keys %tick_name_pos);
}
sub is_overlap {
	my ($tick1_left, $tick1_right, $tick1_bottom, $tick_height, $tick_name_pos_p) = @_;
	my $isoverlap = 0;
	foreach $tick2_pos (values %$tick_name_pos_p){
		($tick2_left, $tick2_right, $tick2_bottom) = split /,/, $tick2_pos;
		next if ($tick1_left > $tick2_right or $tick1_right < $tick2_left);
		next if (abs($tick1_bottom - $tick2_bottom) > $tick_height);
		$isoverlap = 1;
	}
	return $isoverlap;
}
sub colors {
	@palette = ("#FF0000", "#BEBEBE", "#6495ED", "#66CD00",
		    "#FFFF00", "#838B83", "#8B3A3A", "#F0E68C",
		    "#BFEFFF", "#20B2AA", "#8470FF", "#FF00FF",
		    "#0000FF", "#FFA500", "#A020F0");
	my $i = shift;
	return $palette[$i % scalar @palette];
}

my $cutoff = 0.5;
## plot params
my %abun;
while (<>){
	chomp;
	($item, $abun) = split /\t/;
	$abun{$item} = $abun/100 if $abun > $cutoff;
}
($bottom, $left, $top, $right, $ticks_num) = &pre_pie_chart(\%abun);
#die "$bottom, $left, $top, $right, $ticks_num";
#print $ticks_num;
print &pie_chart($bottom, $left, $top, $right, \%abun);
