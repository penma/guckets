$level = new Guckets::Level();
$level->{author} = "Lars Stoltenow";
$level->{name} = "Level 10";

push(@{$level->{buckets}}, new Guckets::Bucket(7, 7));
push(@{$level->{buckets}}, new Guckets::Bucket(0, 4));
push(@{$level->{buckets}}, new Guckets::Bucket(0, 3));

push(@{$level->{goals}}, Guckets::Goals::water(1, 2));
push(@{$level->{goals}}, Guckets::Goals::water(2, 2));
push(@{$level->{goals}}, Guckets::Goals::water(3, 3));

$level->{spare_bucket}->{water} = 0;
$level->{spare_bucket}->{water_max} = 0;
