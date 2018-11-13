#!/usr/bin/perl -w

=pod
description: generate pathway html files
author: Wu Chunyan
created date: 20140710
=cut

use Getopt::Long;

my ($indir, $help);

GetOptions("indir:s" => \$indir, "help|?" => \$help);

if (!defined $indir || defined $help) {
	print STDERR << "USAGE";
description: generate pathway html files
usage: perl $0 [options]
options:
	-indir *: input directory, containing *.path files
	-help|?: print help information
USAGE
	exit 1;
}

if (!-d "$indir") {
	print STDERR "directory $indir not exists\n";
	exit 1;
}

@files = glob("$indir/*.path");
for $i (0 .. $#files) {
	$name = (split /[\\\/]/, $files[$i])[-1];
	$name =~ s/\.path$//;
	$htmlFile = $files[$i];
	$htmlFile =~ s/path$/htm/;

	$code = <<HTML;
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<title>$name</title>
<style type="text/css">
body {background-color: #fff;}
table {background-color: #000; border-collapse: collapse; border: solid #000 1px; margin: 0 0 50px 0;}
tr {background-color: #fff;}
th, td {border: solid #000 1px;}
</style>
<script type="text/javascript">
<!--
function reSize2() {
	try {
		parent.document.getElementsByTagName("iframe")[0].style.height = document.body.scrollHeight + 10;
		parent.parent.document.getElementsByTagName("iframe")[0].style.height = parent.document.body.scrollHeight;
	} catch(e) {}
}

preRow = null;
preColor = null;
function colorRow(trObj) {
	if (preRow != null) {
		preRow.style.backgroundColor = preColor;
	}
	preRow = trObj;
	preColor = trObj.style.backgroundColor;
	trObj.style.backgroundColor = "#ff0";
}

function diffColor(tables) {
	color = ["#fff", "#bbf"];
	for (i = 0; i < tables.length; i++) {
		trObj = tables[i].getElementsByTagName("tr");
		for (j = 1; j < trObj.length; j++) {
			trObj[j].style.backgroundColor = color[j % color.length];
		}
	}
}

function showPer(tableObj) {
	trObj = tableObj.getElementsByTagName("tr");
	if (trObj.length < 2) {
		return;
	}
	sum1 = trObj[0].cells[2].innerHTML.replace(/^.*\\(([\\d]+)\\).*\$/, "\$1");
	if (trObj[0].cells.length > 6) {
		sum2 = trObj[0].cells[3].innerHTML.replace(/^.*\\(([\\d]+)\\).*\$/, "\$1");
	}
	if (trObj[0].cells.length > 6) {
		trObj[0].cells[2].innerHTML = "DEGs genes with pathway annotation (" + sum1 + ")";
		trObj[0].cells[3].innerHTML = "All genes with pathway annotation (" + sum2 + ")";
	}else{
		trObj[0].cells[2].innerHTML = "All genes with pathway annotation (" + sum1 + ")";
	}
	for (i = 1; i < trObj.length; i++) {
		trObj[i].cells[2].innerHTML += " (" + (Math.round(trObj[i].cells[2].innerHTML * 10000/ sum1) / 100) + "%)";
		if (trObj[0].cells.length > 6) {
			trObj[i].cells[3].innerHTML += " (" + (Math.round(trObj[i].cells[3].innerHTML * 10000/ sum2) / 100) + "%)";
		}
	}
}

window.onload = function() {
	setTimeout("reSize2()", 1);
}
//-->
</script>
HTML
	$code .= "</head><body>";
	open IN, "< $files[$i]" || die $!;
	chomp($content = <IN>);
	@temp = split /\t/, $content;
	$pre = shift @temp;
	pop @temp;
	$gene = pop @temp;
	$code .= "<table><caption style='font-weight: 900;'>" . ($i + 1) . "\. $name</caption><tr><th>#</th><th>" . substr($pre, 1) . "</th><th>" . (join "</th><th>", @temp) . "</th></tr>";
	$table2 = "<table><tr><th>#</th><th>" . substr($pre, 1) . "</th><th>Differentially expressed genes</th></tr>";
	$index = 0;
	while (<IN>) {
		chomp;
		next if (/^$/);
		$index++;
		@temp = split /\t/, $_;
		$pre = shift @temp;
		pop @temp;    ####### add by wuchunyan at 20150529
		pop @temp;
		$gene = pop @temp;
		$gene =~ s/;/, /g;
		$code .= "<tr><td>$index</td><td><a href='#gene$index' title='click to view genes' onclick='javascript: colorRow(document.getElementsByTagName(\"table\")[1].rows[$index]);'>$pre</a></td><td>" . (join "</td><td>", @temp) . "</td></tr>";
		$map = $temp[-3];
		$map =~ s/ko/map/;
		$table2 .= "<tr><td>$index</td><td>";
		if (-f "$indir/$name\_map/$map.html") {
			$table2 .= "<a href='$name\_map/$map.html' title='click to view map' target='_blank'>$pre</a>";
		} else {
			$table2 .= "$pre (no map in kegg database)";
		}
		$table2 .= "</td><td><a name='gene$index'></a>$gene</td></tr>";
	}
	$table2 .= "</table>";
	$code .= "</table>$table2<script type='text/javascript'>showPer(document.getElementsByTagName('table')[0]);\ndiffColor([document.getElementsByTagName('table')[0], document.getElementsByTagName('table')[1]]);</script></body></html>";
	close IN;

	open HTML, "> $htmlFile" || die $!;
	print HTML "$code";
	close HTML;
}

exit 0;
