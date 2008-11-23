#!/usr/bin/env perl
# Guckets
# Made 2006, 2007, 2008 by Lars Stoltenow <penma@penma.de>
# License: WTFPL <http://sam.zoy.org/wtfpl>

use strict;
use warnings;
use 5.010;
use POSIX;

use Guckets::Bucket;
use Guckets::Level;
use Guckets::Goals;

use Guckets::CUI;

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
Guckets::CUI::Render::render($level, $current_bucket, $selected_bucket);
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
	Guckets::CUI::Render::help_full() if ($i eq $keys{help});
	
	Guckets::CUI::Render::render($level, $current_bucket, $selected_bucket);
	
	if ($level->goal_check())
	{
		Guckets::CUI::Dialog::dialog("Congratulations, you've solved this level!");
		print "\e[1000;1H";
		exit(0);
	}
}
