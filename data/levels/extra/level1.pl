$level = new Guckets::Level();
$level->{author} = "Lars Stoltenow";
$level->{name} = "Extra Level 1";

push(@{$level->{buckets}}, new Guckets::Bucket(0, 11));
push(@{$level->{buckets}}, new Guckets::Bucket(0, 5));
push(@{$level->{buckets}}, new Guckets::Bucket(0, 13));

push(@{$level->{goals}}, Guckets::Goals::water(1, 8));
push(@{$level->{goals}}, Guckets::Goals::water(2, 0));
push(@{$level->{goals}}, Guckets::Goals::water(3, 8));
# implicit: spare bucket has 8

sub max { return $_[0] > $_[1] ? $_[0] : $_[1]; }
sub min { return $_[0] < $_[1] ? $_[0] : $_[1]; }
$level->{hooks}->{pour} = sub {
	my ($self, $bucket1, $bucket2) = @_;
	my ($max1, $max2, $wat1, $wat2) = (
		$self->{buckets}->[$bucket1]->{water_max},
		$self->{buckets}->[$bucket2]->{water_max},
		$self->{buckets}->[$bucket1]->{water},
		$self->{buckets}->[$bucket2]->{water}
	);

	my $transfer = min($wat1, $max2 - $wat2);
	return ($transfer >= 5);
};

$level->{spare_bucket}->{water} = 24;
$level->{spare_bucket}->{water_max} = 24;
