package Guckets::CUI::Dialog;

use strict;
use warnings;
use 5.010;
use Text::Autoformat;
use myterm;

use Guckets::CUI::Primitives;

sub dialog
{
	my ($text) = @_;
	my ($width, $height) = myterm::dimensions();
	# Width: approx. 2/3 of screen
	my $dialogwidth = int($width * 0.6);
	my @wrappedtext = split(/\n/, autoformat($text, { right => $dialogwidth - 4, fill => 0, all => 1 }));
	# Height: Line count + 2l border + 2l additional text
	my $dialogheight = scalar(@wrappedtext) + 4;
	$dialogheight = $height - 2 if ($dialogheight > $height - 2);
	
	# Dialog position: centered on screen
	my $dx = int(($width - $dialogwidth) / 2);
	my $dy = int(($height - $dialogheight) / 2);
	
	my $topline = 0;
	while (1)
	{
		# Clear the area and, while we're at it, draw the text into it
		for (my $cy = $dy; $cy < $dy + $dialogheight; $cy++)
		{
			printf("\e[%d;%dH  %-*s  ", $cy, $dx, $dialogwidth - 4, $wrappedtext[$cy - $dy - 1 + $topline] // "");
		}
		Guckets::CUI::Primitives::box($dx, $dy, $dx + $dialogwidth, $dy + $dialogheight - 1);
		
		# Print a "hit the 'any key' key to continue" message
		printf("\e[%d;%dH%*s", $dy + $dialogheight - 2, $dx + 2, $dialogwidth - 4,
			"Scroll: Up/Down, Return: Close");
		
		# Actions... like scrolling, or exiting.
		my $key = myterm::readkey();
		$topline-- if ($key eq "\e[A" and $topline > 0);
		$topline++ if ($key eq "\e[B" and $topline < scalar(@wrappedtext) - $dialogheight + 4);
		last if ($key eq "\cJ");
	}
}

1;
