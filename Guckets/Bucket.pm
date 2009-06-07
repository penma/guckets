# Guckets
# Made 2006, 2007, 2008 by Lars Stoltenow <penma@penma.de>
# License: WTFPL <http://sam.zoy.org/wtfpl>

package Guckets::Bucket;

use strict;
use warnings;

sub new {
	my ($self, $water, $water_max) = @_;
	return bless({
		water => ($water or 0),
		water_max => ($water_max or 0)
		}, $self);
}

# pour water from self to target bucket.
sub pour_to {
	my ($self, $target) = @_;
	my $sum = $target->{water} + $self->{water};
	$target->{water} = $sum;
	$self->{water} = $sum - $target->{water_max};

	# fix overflows
	$target->{water} = $target->{water_max}
		if ($target->{water} > $target->{water_max});
	$self->{water} = 0 if ($self->{water} < 0);
}

1;
