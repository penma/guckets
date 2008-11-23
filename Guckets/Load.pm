# Guckets
# Made 2006, 2007, 2008 by Lars Stoltenow <penma@penma.de>
# License: WTFPL <http://sam.zoy.org/wtfpl>

package Guckets::Load;

use strict;
use warnings;

use Guckets::Bucket;
use Guckets::Goals;
use Guckets::Level;
use Guckets::Levelset;

# load a level or a levelset from a file
# depending on which variable in the returned list is set, the frontend knows
# what type of interface to invoke.
# it does not need to expect both fields to be set. files featuring this are
# ambiguous by definition.
# however, it is required that the third field (error message) always be
# handled, if present, as it might happen that levels get loaded partially (so
# $level is not undef anymore) but it fails in the middle.
# the purpose of this function is to provide at least simple measures
# against accidental changes to global data. it might not be a real sandbox
# at all. (however, levels must not depend on this.)
sub load
{
	my ($name) = @_;
	# do something better than 'do'
	our $level;
	our $levelset;
	undef $level;
	undef $levelset;
	do($name) or return (undef, undef, $!);
	return ($level, $levelset, undef);
}

1;
