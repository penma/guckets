package Guckets::CUI::Render;

use strict;
use warnings;
use 5.010;
use myterm;

use Guckets::CUI::Primitives;
use Guckets::CUI::Dialog;

sub headline
{
	my ($width, $height) = myterm::dimensions();
	
	Guckets::CUI::Primitives::box(1, 1, $width, 3);
	
	my $title = "G U C K E T S";
	# centered text
	printf("\e[%d;%dH\e[1m%s\e[m",
		2, int(($width - length($title)) / 2),
		$title);
	
	Guckets::CUI::Primitives::box(37, 4, $width, $height);
}

sub bucket_large
{
	my ($level, $bucket, $outline_color, $height) = @_;
	my $off_x = $bucket * 10 + 40;
	my $off_y = $height * 2 + 4;
	
	# outline of the bucket
	for (my $cy = 0;
	     $cy <= $level->{buckets}->[$bucket]->{water_max};
	     $cy++)
	{
		printf( "\e[%d;%dH  %s│     │\e[m",
			$off_y - $cy * 2, $off_x, $outline_color)
			if ($cy < $level->{buckets}->[$bucket]->{water_max});
		printf("\e[%d;%dH%2d%s├─    │\e[m",
			$off_y - $cy * 2 + 1, $off_x, $cy, $outline_color);
	}
	printf("\e[%d;%dH  %s└─────┘\e[m", $off_y + 2, $off_x, $outline_color);
	printf("\e[%d;%dH%d", $off_y + 3, $off_x + 5, $bucket + 1);
	
	# the content
	for (my $cy = 0; $cy < $level->{buckets}->[$bucket]->{water}; $cy++)
	{
		printf("\e[%d;%dH%s│\e[7;22;34m     \e[m%3\$s│\e[m",
			$off_y - $cy * 2, $off_x + 2, $outline_color);
		printf("\e[%d;%dH%s├\e[7;22;34m─    \e[m%3\$s│\e[m",
			$off_y - $cy * 2 + 1, $off_x + 2, $outline_color);
	}
}

sub bucket_small
{
	my ($level, $bucket, $outline_color, $height) = @_;
	my $off_x = $bucket * 10 + 40;
	my $off_y = $height + 5;
	
	# outline + content of the bucket
	for (my $cy = 0;
	     $cy <= $level->{buckets}->[$bucket]->{water_max};
	     $cy++)
	{
		printf("\e[%d;%dH  %s│%s     \e[m%3\$s│\e[m",
			$off_y - $cy, $off_x, $outline_color,
			$cy < $level->{buckets}->[$bucket]->{water} ? "\e[7;34;22m" : "")
	}
	printf("\e[%d;%dH  %s└─────┘\e[m", $off_y + 1, $off_x, $outline_color);
	printf("\e[%d;%dH%d (%2d/%2d)", $off_y + 2, $off_x, $bucket + 1,
		$level->{buckets}->[$bucket]->{water},
		$level->{buckets}->[$bucket]->{water_max});
}

sub bucket
{
	my ($level, $bucket, $outline_color, $height) = @_;
	
	if ((myterm::height() - 8) / 2 >= $height)
	{
		bucket_large(@_);
	}
	else
	{
		bucket_small(@_);
	}
}

sub levelinfo
{
	my ($level) = @_;
	my $line = 5;
	
	$line += Guckets::CUI::Primitives::text(3, $line, 32,
		sprintf("\e[1m%s:\e[m %s", "Name", $level->{name}));
	$line += Guckets::CUI::Primitives::text(3, $line, 32,
		sprintf("\e[1m%s:\e[m %s", "Author", $level->{author}));
	if ($level->{description})
	{
		$line += Guckets::CUI::Primitives::text(3, $line, 32,
			sprintf("\e[1m%s:\e[m", "Description"));
		$line += Guckets::CUI::Primitives::text(3, $line, 32,
			$level->{description});
	}
	
	Guckets::CUI::Primitives::box(1, 4, 36, $line, "Level Information");
	return $line - 5;
}

sub goals
{
	my ($level, $used_height) = @_;
	my $line = 7 + $used_height;
	
	foreach (@{$level->{goals}})
	{
		print "\e[32m" if ($_->{callback}->($level));
		$line += Guckets::CUI::Primitives::text(3, $line, 34,
			"* " . sprintf($_->{text}, @{$_->{arguments}}));
		print "\e[m";
	}
	
	Guckets::CUI::Primitives::box(1, 6 + $used_height, 36, $line, "Goals");
	
	return $line - 5;
}

sub help
{
	my ($used_height) = @_;
	my $line = 7 + $used_height;
	
	$line += Guckets::CUI::Primitives::text(3, $line, 32,
		sprintf("\e[1m%s:\e[m %s", "Left/Right", "Choose Bucket"));
	$line += Guckets::CUI::Primitives::text(3, $line, 32,
		sprintf("\e[1m%s:\e[m %s", "Up/Down", "Fill/Empty"));
	$line += Guckets::CUI::Primitives::text(3, $line, 32,
		sprintf("\e[1m%s:\e[m %s", "Enter", "Select for pouring"));
	$line += Guckets::CUI::Primitives::text(3, $line, 32,
		sprintf("\e[1m%s:\e[m %s", "h", "Help"));
	$line += Guckets::CUI::Primitives::text(3, $line, 32,
		sprintf("\e[1m%s:\e[m %s", "q", "Exit"));
	
	Guckets::CUI::Primitives::box(1, 6 + $used_height, 36, $line,
		"Quick Help");
	return $line - 5;
}

sub help_full
{
	Guckets::CUI::Dialog::dialog("normal", << 'END_OF_HELP');
Guckets (Console-Based User Interface)
Made 2006, 2007, 2008 by Lars Stoltenow <penma@penma.de>

Game Description
.   In Guckets you must fill buckets with water. You must have a specific amount of water in one or more buckets. Sounds easy, but you are not allowed to measure any water, and you can only fill, empty, and pour your buckets. There is support for own levels.

Keys
.   Left/Right: Choose the bucket
    Up/Down: Fill or empty the current bucket
    Enter: 1. Select a bucket to pour water from, or 2. Select the second bucket to pour water in
    q: Exit Game

END_OF_HELP
}

sub render
{
	my ($level, $current_bucket, $selected_bucket) = @_;
	
	# clear
	print "\e[2J";
	
	headline();
	
	my $used_height = levelinfo($level);
	$used_height = goals($level, $used_height);
	$used_height = help($used_height);
	
	for (my $c = 0; $c < scalar(@{$level->{buckets}}); $c++)
	{
		bucket($level, $c,
			$selected_bucket == $c ? "\e[1;31m" :
			($current_bucket == $c ? "\e[1;37m" : "\e[1;30m"),
			
			(sort { $b->{water_max} <=> $a->{water_max} }
				@{$level->{buckets}}
			)[0]->{water_max});
	}
	
	printf("\e[%d;%dH", myterm::height(), 1);
}

1;
