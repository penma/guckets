#!/usr/bin/env perl
# Guckets
# Made 2006, 2007, 2008 by Lars Stoltenow <penma@penma.de>
# License: WTFPL <http://sam.zoy.org/wtfpl>

use strict;
use warnings;
use 5.010;
use POSIX;
use Text::Autoformat;
use myterm;

use Guckets::Bucket;
use Guckets::Level;
use Guckets::Goals;

if (scalar(@ARGV) < 1)
{
	print << 'EOT';
Usage: guckets-tui <level>
EOT
	exit(2);
}

# try to load the level
my ($level, $error) = Guckets::Level::load($ARGV[0]);
if (defined($error))
{
	die $!;
}

# ----------------------------- RENDERING FUNCTIONS --------------------------
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
		box($dx, $dy, $dx + $dialogwidth, $dy + $dialogheight - 1);
		
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

sub render_headline
{
	my ($width, $height) = myterm::dimensions();
	
	box(1, 1, $width, 3);
	
	my $title = "G U C K E T S";
	printf("\e[2;%dH\e[1m%s\e[m", int(($width - length($title)) / 2), $title);
	
	box(37, 4, $width, $height);
}

sub render_bucket
{
	my ($level, $bucket, $outline_color, $height) = @_;
	my $off_x = $bucket * 10 + 40;
	my $off_y = $height * 2 + 5;
	
	# outline of the bucket
	for (my $cy = 0; $cy <= $level->{buckets}->[$bucket]->{water_max}; $cy++)
	{
		printf( "\e[%d;%dH  %s│     │\e[m", $off_y - $cy * 2, $off_x, $outline_color)
			if ($cy < $level->{buckets}->[$bucket]->{water_max});
		printf("\e[%d;%dH%2d%s├─    │\e[m", $off_y - $cy * 2 + 1, $off_x, $cy, $outline_color);
	}
	printf("\e[%d;%dH  %s└─────┘\e[m", $off_y + 2, $off_x, $outline_color);
	printf("\e[%d;%dH%d", $off_y + 3, $off_x + 5, $bucket + 1);
	
	# the content
	for (my $cy = 0; $cy < $level->{buckets}->[$bucket]->{water}; $cy++)
	{
		printf("\e[%d;%dH%s│\e[7;22;34m     \e[m%3\$s│\e[m", $off_y - $cy * 2, $off_x + 2, $outline_color);
		printf("\e[%d;%dH%s├\e[7;22;34m─    \e[m%3\$s│\e[m", $off_y - $cy * 2 + 1, $off_x + 2, $outline_color);
	}
}

sub render_levelinfo
{
	my ($level) = @_;
	my $line = 5;
	
	$line += text(3, $line, 32, sprintf("\e[1m%s:\e[m %s", "Name", $level->{name}));
	$line += text(3, $line, 32, sprintf("\e[1m%s:\e[m %s", "Author", $level->{author}));
	if ($level->{description})
	{
		$line += text(3, $line, 32, sprintf("\e[1m%s:\e[m", "Description"));
		$line += text(3, $line, 32, $level->{description});
	}
	
	box(1, 4, 36, $line, "Level Information");
	return $line - 5;
}

sub render_goals
{
	my ($level, $used_height) = @_;
	my $line = 7 + $used_height;
	
	foreach (@{$level->{goals}})
	{
		print "\e[32m" if ($_->{callback}->($level));
		printf("\e[%d;%dH*", $line, 3);
		$line += text(5, $line, 32, sprintf($_->{text}, @{$_->{arguments}}));
		print "\e[m";
	}
	
	box(1, 6 + $used_height, 36, $line, "Goals");
	
	return $line - 5;
}

sub render_help
{
	my ($used_height) = @_;
	my $line = 7 + $used_height;
	
	$line += text(3, $line, 32, sprintf("\e[1m%s:\e[m %s", "Left/Right", "Choose Bucket"));
	$line += text(3, $line, 32, sprintf("\e[1m%s:\e[m %s", "Up/Down", "Fill/Empty"));
	$line += text(3, $line, 32, sprintf("\e[1m%s:\e[m %s", "Enter", "Select for pouring"));
	$line += text(3, $line, 32, sprintf("\e[1m%s:\e[m %s", "h", "Help"));
	$line += text(3, $line, 32, sprintf("\e[1m%s:\e[m %s", "q", "Exit"));
	
	box(1, 6 + $used_height, 36, $line, "Quick Help");
	return $line - 5;
}

sub render_help_full
{
	dialog(<< 'END_OF_HELP');
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
	
	render_headline();
	
	my $used_height = render_levelinfo($level);
	$used_height = render_goals($level, $used_height);
	$used_height = render_help($used_height);
	
	for (my $c = 0; $c < scalar(@{$level->{buckets}}); $c++)
	{
		render_bucket($level, $c,
			$selected_bucket == $c ? "\e[1;31m" : ($current_bucket == $c ? "\e[1;37m" : "\e[1;30m"),
			(sort { $b->{water_max} <=> $a->{water_max} } @{$level->{buckets}})[0]->{water_max});
	}
	
	printf("\e[%d;%dH", myterm::height(), 1);
}

# prepare terminal
$SIG{INT} = $SIG{TERM} = sub
{
	myterm::set(POSIX::ICANON | POSIX::ECHO);
	exit(4);
};

myterm::unset(POSIX::ICANON | POSIX::ECHO);

# my %keys = ( left => "h", down => "j", up => "k", right => "l", select => "\cJ" ); # classic
# my %keys = ( left => "h", down => "d", up => "r", right => "n", select => "\cJ" ); # dvorak2
my %keys = ( left => "\e[D", down => "\e[B", up => "\e[A", right => "\e[C", select => "\cJ", help => "h", quit => "q"); # cursor keys

$| = 1;

my $i;
my $current_bucket = 0;
my $selected_bucket = -1;
render($level, $current_bucket, $selected_bucket);
while ($i = myterm::readkey())
{
	$current_bucket-- if ($i eq $keys{left} and $current_bucket > 0);
	$current_bucket++ if ($i eq $keys{right} and $current_bucket < scalar(@{$level->{buckets}}) - 1);
	
	if ($i eq $keys{select})
	{
		if ($selected_bucket == -1) # no bucket selected yet
		{
			$selected_bucket = $current_bucket;
		}
		else # do some action, we have two buckets now
		{
			$level->bucket_pour($selected_bucket, $current_bucket)
				if ($selected_bucket != $current_bucket);
			$selected_bucket = -1;
		}
	}
	
	$level->bucket_fill($current_bucket) if ($i eq $keys{up});
	$level->bucket_empty($current_bucket) if ($i eq $keys{down});
	
	exit(4) if ($i eq $keys{quit});
	render_help_full() if ($i eq $keys{help});
	
	render($level, $current_bucket, $selected_bucket);
	
	if ($level->goal_check())
	{
		dialog("Congratulations, you've solved this level!");
		print "\e[1000;1H";
		exit(0);
	}
}
