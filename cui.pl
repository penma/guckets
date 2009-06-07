#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;
use POSIX;
use myterm;

use Guckets::Load;
use Guckets::CUI;

# prepare terminal
$SIG{INT} = $SIG{TERM} = sub {
	myterm::set(POSIX::ICANON | POSIX::ECHO);
	exit(4);
};

myterm::unset(POSIX::ICANON | POSIX::ECHO);

if (scalar(@ARGV) < 1) {
	print << 'EOT';
Usage: guckets-tui <level>
EOT
	exit(2);
}

# try to load the level
my ($level, $levelset, $error) = Guckets::Load::load($ARGV[0]);
die $! if (defined($error));

$| = 1;

Guckets::CUI::PlayLevel::play($level) if (defined($level));
Guckets::CUI::PlayLevelset::play($levelset) if (defined($levelset));

print "\e[1000;1H";
