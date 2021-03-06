package Guckets::Goals;

use strict;
use warnings;

sub water {
	my ($bucket, $water) = @_;
	return {
		callback => sub {
			my ($level) = @_;
			return $level->{buckets}->[$bucket - 1]->{water} == $water;
		},
		text => '%d liters of water in bucket %d',
		arguments => [ $water, $bucket ]
	};
}

1;
