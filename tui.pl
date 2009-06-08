#!/usr/bin/env perl
use strict;
use warnings;

use Guckets::TUI;
use Guckets::Load;

if (scalar(@ARGV) < 1) {
	print << "EOT";
Usage: $0 <level>
EOT
	exit(2);
}

# try to load the level
my ($level, $levelset, $error) = Guckets::Load::load($ARGV[0]);
if (defined($error)) {
	print "ERROR: Could not load level: $error\n";
	exit(1);
}

$| = 1;

Guckets::TUI::PlayLevel::play($level) if (defined($level));
Guckets::TUI::PlayLevelset::play($levelset) if (defined($levelset));
