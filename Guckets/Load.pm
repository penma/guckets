package Guckets::Load;

use strict;
use warnings;
use File::Basename;

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
sub load {
	my ($name) = @_;
	# do something better than 'do'
	our $level = undef;
	our $levelset = undef;
	return (undef, undef, $!) if (!defined(do($name)));
	$levelset->{basepath} = dirname($name) if (defined($levelset));

	return ($level, $levelset, undef);
}

1;
