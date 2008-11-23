#!/usr/bin/env perl
# Guckets
# Made 2006, 2007, 2008 by Lars Stoltenow <penma@penma.de>
# License: WTFPL <http://sam.zoy.org/wtfpl>

use strict;
use warnings;
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
	
	foreach (split(/\n/, autoformat($text, { right => $width })))
	{
		printf("\e[%d;%dH%s", $line, $x1, $_);
		$line++;
	}
	
	return $line - $y1;
}

sub render_headline
{
	my $width = myterm::width();
	my $height = myterm::height();
	
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
	my ($level, $levelinfoheight) = @_;
	my $line = 7 + $levelinfoheight;
	my $height = myterm::height();
	
	foreach (@{$level->{goals}})
	{
		print "\e[32m" if ($_->{callback}->($level));
		printf("\e[%d;%dH*", $line, 3);
		$line += text(5, $line, 32, sprintf($_->{text}, @{$_->{arguments}}));
		print "\e[m";
	}
	
	box(1, 6 + $levelinfoheight, 36, $line, "Goals");
}

sub render
{
	my ($level, $current_bucket, $selected_bucket) = @_;
	
	# clear
	print "\e[2J";
	
	render_headline();
	
	my $levelinfoheight = render_levelinfo($level);
	
	for (my $c = 0; $c < scalar(@{$level->{buckets}}); $c++)
	{
		render_bucket($level, $c,
			$selected_bucket == $c ? "\e[1;31m" : ($current_bucket == $c ? "\e[1;37m" : "\e[1;30m"),
			(sort { $b->{water_max} <=> $a->{water_max} } @{$level->{buckets}})[0]->{water_max});
	}
	
	render_goals($level, $levelinfoheight);
}




# prepare terminal
$SIG{INT} = $SIG{TERM} = sub
{
	myterm::set(POSIX::ICANON | POSIX::ECHO);
	exit(0);
};

myterm::unset(POSIX::ICANON | POSIX::ECHO);







# my %keys = ( left => "h", down => "j", up => "k", right => "l", select => "\cJ" ); # classic
# my %keys = ( left => "h", down => "d", up => "r", right => "n", select => "\cJ" ); # dvorak2
my %keys = ( left => "\e[D", down => "\e[B", up => "\e[A", right => "\e[C", select => "\cJ"); # cursor keys

$| = 1;

my $i;
my $current_bucket = 0;
my $selected_bucket = -1;
render($level, $current_bucket, $selected_bucket);
while ($i = myterm::readkey())
{
	$current_bucket-- if ($i eq $keys{left});
	$current_bucket++ if ($i eq $keys{right});
	
	if ($i eq $keys{select})
	{
		if ($selected_bucket == -1) # no bucket selected yet
		{
			$selected_bucket = $current_bucket;
		}
		else # do some action, we have two buckets now
		{
			$level->bucket_pour($selected_bucket, $current_bucket);
			$selected_bucket = -1;
		}
	}
	
	$level->bucket_fill($current_bucket) if ($i eq $keys{up});
	$level->bucket_empty($current_bucket) if ($i eq $keys{down});
	
	render($level, $current_bucket, $selected_bucket);
	
	if ($level->goal_check())
	{
		print "Congratulations, you've solved this level!\n";
		exit(0);
	}
}
