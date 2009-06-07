package Guckets::Levelset;

use strict;
use warnings;

sub new {
	return bless({
		levels => [],

		name => "Unknown",
		author => "Anonymous"
		}, shift);
}

1;
