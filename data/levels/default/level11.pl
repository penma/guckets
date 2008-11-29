$level = new Guckets::Level();
$level->{author} = "Dominic Laumer";
$level->{name} = "Level 11";

push(@{$level->{buckets}}, new Guckets::Bucket(0, 6));
push(@{$level->{buckets}}, new Guckets::Bucket(0, 5));
push(@{$level->{buckets}}, new Guckets::Bucket(0, 4));
push(@{$level->{buckets}}, new Guckets::Bucket(0, 3));

push(@{$level->{goals}}, Guckets::Goals::water(1, 4));
push(@{$level->{goals}}, Guckets::Goals::water(3, 3));
push(@{$level->{goals}}, Guckets::Goals::water(4, 1));

$level->auto_spare_bucket();
