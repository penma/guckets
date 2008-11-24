package Guckets::TUI;

use strict;
use warnings;

use Guckets::TUI::PlayLevel;
use Guckets::TUI::PlayLevelset;

sub help
{
	my ($topic) = @_;
	if (!defined($topic))
	{
		print << 'EOT';
Guckets Text User Interface
Made 2006, 2007, 2008 Lars Stoltenow <penma@penma.de>

Commands:
    help [<optarg>]  - Show help message
EOT
		if (caller() ne "Guckets::TUI::PlayLevelset")
		{
			print << 'EOT';
    show             - Show the bucket state
    fill <n>         - Fill bucket n
    empty <n>        - Empty bucket n
    pour <n1> <n2>   - Pour water from bucket n1 to bucket n2
    exit, quit       - Leave to the main menu
EOT
		}
		else
		{
			print << 'EOT';
    show             - List available levels
    start [<n>]      - Start Level n (or first level, if not specified)
    exit, quit       - Exit the game
EOT
		}
		print << 'EOT';

Optional argument for help:
    description      - Game description
    spare            - What is the spare bucket
EOT
	}
	elsif ($topic eq "description")
	{
		print << 'EOT';
A short description of Guckets

Guckets is a game where you must fill buckets with water. Starting with just
two buckets, you will get more buckets to manage. The goal is to have a
specific amount of water in one (or probably more) bucket. Sounds easy, but
you are not allowed to measure the water you fill into your buckets. Thus,
you can only fill your buckets with water, or you can empty them, or you can
pour all water into another bucket (until it's full). Depending on the level,
you maybe don't have unlimited water, so you must think to reach the goal.
EOT
	}
	elsif ($topic eq "spare")
	{
		print << 'EOT';
What is the spare bucket?

The spare bucket is the internal representation of the amount of water you
can bring into game, in addition to the water that's in the buckets after
loading a level. In most levels, it will not be limited, but there might be
some which place a limit on this for an additional challenge.
EOT
	}
	else
	{
		print "No help for that topic.\n";
	}
}

1;
