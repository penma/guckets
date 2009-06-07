package Guckets::Level;

use strict;
use warnings;

use Guckets::Bucket;
use Guckets::Goals;

sub new {
	return bless({
		buckets => [],
		spare_bucket => new Guckets::Bucket(),
		goals => [],

		hooks => {},

		name => "Unknown",
		author => "Anonymous",
		}, shift);
}

# Automatically create the spare bucket to contain enough water to fill
# the remaining buckets with water and to empty all buckets.
# Useful for the common type of levels that do not have any actual constraints
# on how much additional water can go in the buckets
sub auto_spare_bucket {
	my ($self) = @_;
	my ($water_avail, $water_max) = (0, 0);

	foreach (@{$self->{buckets}}) {
		$water_avail += $_->{water};
		$water_max   += $_->{water_max};
	}

	$self->{spare_bucket}->{water}     = $water_max - $water_avail;
	$self->{spare_bucket}->{water_max} = $water_max;
}

# convenience functions to manage pouring. these include filling and emptying
# (which are really just the same as pouring from/to the spare bucket).
sub bucket_fill {
	my ($self, $bucket) = @_;
	if ($self->{hooks}->{fill}) {
		my $r = $self->{hooks}->{fill}->($self, $bucket);
		return $r if (defined($r));
	}
	$self->{spare_bucket}->pour_to($self->{buckets}->[$bucket]);
	return undef;
}

sub bucket_empty {
	my ($self, $bucket) = @_;
	if ($self->{hooks}->{empty}) {
		my $r = $self->{hooks}->{empty}->($self, $bucket);
		return $r if (defined($r));
	}
	$self->{buckets}->[$bucket]->pour_to($self->{spare_bucket});
	return undef;
}

sub bucket_pour {
	my ($self, $bucket1, $bucket2) = @_;
	if ($self->{hooks}->{pour}) {
		my $r = $self->{hooks}->{pour}->($self, $bucket1, $bucket2);
		return $r if (defined($r));
	}
	$self->{buckets}->[$bucket1]->pour_to($self->{buckets}->[$bucket2]);
	return undef;
}

# goal checking
# each goal is a subroutine that returns either true or false, depending on
# whether the condition is fulfilled
# obviously, when all conditions are met, the level is won.
sub goal_check {
	my ($self) = @_;

	foreach (@{$self->{goals}}) {
		return 0 unless $_->{callback}->($self);
	}

	return 1;
}

1;
