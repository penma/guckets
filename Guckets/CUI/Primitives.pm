package Guckets::CUI::Primitives;

use strict;
use warnings;
use 5.010;
use Text::Autoformat;
use myterm;

sub box
{
	my ($x1, $y1, $x2, $y2, $text) = @_;
	printf("\e[%d;%dH┌%s┐", $y1, $x1, "─" x ($x2 - $x1 - 1));
	for (my $line = $y1 + 1; $line < $y2; $line++)
	{
		printf("\e[%d;%dH│\e[%1\$d;%3\$dH│", $line, $x1, $x2);
	}
	printf("\e[%d;%dH└%s┘", $y2, $x1, "─" x ($x2 - $x1 - 1));
	
	if (defined($text))
	{
		printf("\e[%d;%dH %s ", $y1, $x1 + 2, $text);
	}
}

sub text
{
	my ($x1, $y1, $width, $text) = @_;
	my $line = $y1;
	
	foreach (split(/\n/, autoformat($text, { right => $width, fill => 0, all => 1 })))
	{
		printf("\e[%d;%dH%s", $line, $x1, $_);
		$line++;
	}
	
	return $line - $y1;
}

1;
