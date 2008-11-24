#!/usr/bin/env perl
# Guckets
# Made 2006, 2007, 2008 by Lars Stoltenow <penma@penma.de>
# License: WTFPL <http://sam.zoy.org/wtfpl>

use strict;
use warnings;

use Guckets::TUI;
use Guckets::Load;

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
my ($level, $levelset, $error) = Guckets::Load::load($ARGV[0]);
if (defined($error))
{
	print "ERROR: Could not load level: $error\n";
	exit(1);
}

$| = 1;

Guckets::TUI::PlayLevel::play($level) if (defined($level));
Guckets::TUI::PlayLevelset::play($levelset) if (defined($levelset));
