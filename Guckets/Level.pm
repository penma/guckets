package Guckets::Level;

use strict;
use warnings;
use 5.010;

use Time::HiRes qw(time);

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
	rp_save($self, "fill $bucket");
	if ($self->{hooks}->{fill}) {
		my $r = $self->{hooks}->{fill}->($self, $bucket);
		if (defined($r)) {
			rp_save($self, "hook executed, replied: $r");
			return $r;
		}
	}
	$self->{spare_bucket}->pour_to($self->{buckets}->[$bucket]);
	rp_save($self, "fill completed");
	return undef;
}

sub bucket_empty {
	my ($self, $bucket) = @_;
	rp_save($self, "empty $bucket");
	if ($self->{hooks}->{empty}) {
		my $r = $self->{hooks}->{empty}->($self, $bucket);
		if (defined($r)) {
			rp_save($self, "hook executed, replied: $r");
			return $r;
		}
	}
	$self->{buckets}->[$bucket]->pour_to($self->{spare_bucket});
	rp_save($self, "empty completed");
	return undef;
}

sub bucket_pour {
	my ($self, $bucket1, $bucket2) = @_;
	rp_save($self, "pour $bucket1 -> $bucket2");
	if ($self->{hooks}->{pour}) {
		my $r = $self->{hooks}->{pour}->($self, $bucket1, $bucket2);
		if (defined($r)) {
			rp_save($self, "hook executed, replied: $r");
			return $r;
		}
	}
	$self->{buckets}->[$bucket1]->pour_to($self->{buckets}->[$bucket2]);
	rp_save($self, "pour completed");
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

	rp_save($self, "goals reached");

	return 1;
}

# log an action to the reply file
sub rp_save {
	my ($level, $action) = @_;
	return if (!defined($ENV{GUCKETS_REPLAY_OUT}));

	# dump the buckets
	my $buckets = sprintf("[%s]%d/%d", "spare",
		$level->{spare_bucket}->{water},
		$level->{spare_bucket}->{water_max},
	);
	for (my $i = 0; $i < scalar(@{$level->{buckets}}); $i++) {
		$buckets .= sprintf("[%d]%d/%d", $i,
			$level->{buckets}->[$i]->{water},
			$level->{buckets}->[$i]->{water_max},
		);
	}

	open(FH, ">>", $ENV{GUCKETS_REPLAY_OUT}) or return;
	print FH sprintf(
		"session=%s, time=%f, title=%d:%s, buckets=%s, action=%s\n",
		$ENV{GUCKETS_REPLAY_INFO} // "(pid $$)",
		time(),
		length($level->{name}), $level->{name},
		$buckets,
		$action
	);
	close(FH);
}

1;
