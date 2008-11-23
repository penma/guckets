# Guckets
# Made 2006, 2007, 2008 by Lars Stoltenow <penma@penma.de>
# License: WTFPL <http://sam.zoy.org/wtfpl>

package Guckets::Levelset;

use strict;
use warnings;

sub new
{
	return bless({
		levels => [],
		
		name => "Unknown",
		author => "Anonymous"
		}, shift);
}

1;
