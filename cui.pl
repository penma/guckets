#!/usr/bin/env perl
# Guckets
# Made 2006, 2007, 2008 by Lars Stoltenow <penma@penma.de>
# License: WTFPL <http://sam.zoy.org/wtfpl>

use strict;
use warnings;
use 5.010;
use POSIX;
use myterm;

use Guckets::Level;
use Guckets::CUI;

# prepare terminal
$SIG{INT} = $SIG{TERM} = sub
{
	myterm::set(POSIX::ICANON | POSIX::ECHO);
	exit(4);
};

myterm::unset(POSIX::ICANON | POSIX::ECHO);

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

$| = 1;

Guckets::CUI::PlayLevel::play($level);

print "\e[1000;1H";

print "Properly exited.\n";
