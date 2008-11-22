#!/usr/bin/env perl
# Guckets
# Made 2006, 2007, 2008 by Lars Stoltenow <penma@penma.de>
# License: WTFPL <http://sam.zoy.org/wtfpl>

use strict;
use warnings;

use Guckets::Bucket;
use Guckets::Level;
use Guckets::Goals;

if (scalar(@ARGV) < 1)
{
	print << 'EOT';
Guckets Text User Interface
Made 2006, 2007, 2008 Lars Stoltenow <penma@penma.de>

Usage: guckets-tui <level>
EOT
	exit(2);
}

# try to load the level
my $level = Guckets::Level::load($ARGV[0]);

$| = 1;

# ------------------------------- ONLINE HELP --------------------------------
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
    show             - Show the bucket state
    fill <n>         - Fill bucket n
    empty <n>        - Empty bucket n
    pour <n1> <n2>   - Pour water from bucket n1 to bucket n2
    exit, quit       - Exit

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

# ------------------------------ STATE DUMPER --------------------------------
sub print_state
{
	my ($level) = @_;
	print "Buckets:\n";
	my $id = 1;
	foreach (@{$level->{buckets}})
	{
		my $visu = "|";
		$visu .= "****|" for (1 .. $_->{water});
		$visu .= "....|" for ($_->{water} + 1 .. $_->{water_max});
		
		printf("     %5d: %2d / %2d %s\n", $id, $_->{water}, $_->{water_max}, $visu);
		$id++;
	}
	printf("     Spare: %2d / %2d\n", $level->{spare_bucket}->{water}, $level->{spare_bucket}->{water_max});
	
	print "Goals to reach:\n";
	foreach (@{$level->{goals}})
	{
		print ($_->{callback}->($level) ? "[OK] " : "     ");
		printf($_->{text}, @{$_->{arguments}});
		print "\n";
	}
}

# -------------------------------- MAIN LOOP ---------------------------------

help();
print_state($level);
my $changed = 0;

print "> ";
while (<STDIN>)
{
	# split line into words
	chomp;
	@_ = split;
	
	if (!defined($_[0])) { } # no-op
	# bucket operations
	elsif ($_[0] eq "fill" or $_[0] eq "empty")
	{
		my $n = int($_[1]);
		if ($n == 0 or $n > scalar(@{$level->{buckets}}))
		{
			print "ERROR: No such bucket.\n";
		}
		else
		{
			if ($_[0] eq "fill")
			{
				print "Filling bucket $n\n";
				$level->bucket_fill($n - 1);
			}
			else
			{
				print "Emptying bucket $n\n";
				$level->bucket_empty($n - 1);
			}
			$changed = 1;
		}
	}
	elsif ($_[0] eq "pour")
	{
		my ($n1, $n2) = (int($_[1]), int($_[2]));
		if ($n1 == 0 or $n2 == 0 or $n1 > scalar(@{$level->{buckets}}) or $n2 > scalar(@{$level->{buckets}}))
		{
			print "ERROR: No such bucket.\n";
		}
		else
		{
			if ($n1 == $n2)
			{
				print "ERROR: Source and destination bucket are the same!\n";
			}
			else
			{
				print "Pouring water from bucket $n1 to bucket $n2\n";
				$level->bucket_pour($n1 - 1, $n2 - 1);
				$changed = 1;
			}
		}
	}
	# help and various
	elsif ($_[0] eq "help") { help($_[1]); }
	elsif ($_[0] eq "show") { $changed = 1; }
	elsif ($_[0] eq "exit" or $_[0] eq "quit") { exit(0); }
	else { print "No such command.\n"; }
	
	if ($changed)
	{
		print_state($level);
		$changed = 0;
	}
	
	if ($level->goal_check())
	{
		print "Congratulations, you've solved this level!\n";
		exit(0)
	}
	
	print "> ";
}
