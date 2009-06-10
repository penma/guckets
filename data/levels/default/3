$level = new Guckets::Level();
$level->{author} = "Lars Stoltenow";
$level->{name} = "Level 3";

push(@{$level->{buckets}}, new Guckets::Bucket(0, 4));
push(@{$level->{buckets}}, new Guckets::Bucket(0, 9));

push(@{$level->{goals}}, Guckets::Goals::water(2, 6));

$level->auto_spare_bucket();
