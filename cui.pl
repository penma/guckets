#!/usr/bin/env perl
# Guckets
# Made 2006, 2007, 2008 by Lars Stoltenow <penma@penma.de>
# License: WTFPL <http://sam.zoy.org/wtfpl>

use strict;
use warnings;
use POSIX;
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
sub render_headline
{
	print "\e[1;1H";
	print "\e[1;4m";
	my $title = "G U C K E T S";
	my $width = myterm::width();
	# centered text
	print
		" " x int(($width - length($title)) / 2)
		. $title
		. " " x int($width - length($title) - ($width - length($title)) / 2);
	print "\e[m";
	#print "\n\n\n";
}

sub render_bucket
{
	my ($level, $bucket, $outline_color) = @_;
	my $off_x = $bucket * 10 + 30;
	my $off_y = 23; # magic constant
	
	# outline
	for (my $cy = 0; $cy <= $level->{buckets}->[$bucket]->{water_max}; $cy++)
	{
		printf("\e[%d;%dH  %s│     │\e[m", $off_y - $cy * 2, $off_x, $outline_color) if ($cy < $level->{buckets}->[$bucket]->{water_max});
		printf("\e[%d;%dH%2d%s├─    │\e[m", $off_y - $cy * 2 + 1, $off_x, $cy, $outline_color);
	}
	printf("\e[%d;%dH  %s└─────┘\e[m", $off_y + 2, $off_x, $outline_color);
	
	# fill
	for (my $cy = 0; $cy < $level->{buckets}->[$bucket]->{water}; $cy++)
	{
		printf("\e[%d;%dH%s│\e[7;22;34m     \e[m%3\$s│\e[m", $off_y - $cy * 2, $off_x + 2, $outline_color);
		printf("\e[%d;%dH%s├\e[7;22;34m─    \e[m%3\$s│\e[m", $off_y - $cy * 2 + 1, $off_x + 2, $outline_color);
	}
}

render_headline;

sub render
{
	my ($level, $current_bucket, $selected_bucket) = @_;
	
	# clear
	print "\e[2J";
	
	render_headline();
	for (my $c = 0; $c < scalar(@{$level->{buckets}}); $c++)
	{
		render_bucket($level, $c, $selected_bucket == $c ? "\e[1;31m" : ($current_bucket == $c ? "\e[1;37m" : "\e[1;30m"));
	}
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
