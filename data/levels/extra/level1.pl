$level = new Guckets::Level();
$level->{author} = "Lars Stoltenow";
$level->{name} = "Extra Level 1";

push(@{$level->{buckets}}, new Guckets::Bucket(24, 24));
push(@{$level->{buckets}}, new Guckets::Bucket(0, 5));
push(@{$level->{buckets}}, new Guckets::Bucket(0, 11));
push(@{$level->{buckets}}, new Guckets::Bucket(0, 13));

push(@{$level->{goals}}, Guckets::Goals::water(2, 8));
push(@{$level->{goals}}, Guckets::Goals::water(3, 8));
push(@{$level->{goals}}, Guckets::Goals::water(4, 8));

$level->{spare_bucket}->{water} = 0;
$level->{spare_bucket}->{water_max} = 0;
