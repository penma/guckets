$level = new Guckets::Level();
$level->{author} = "Vsevolod Kozlov";
$level->{name} = "Level 7";

push(@{$level->{buckets}}, new Guckets::Bucket(0, 2));
push(@{$level->{buckets}}, new Guckets::Bucket(0, 9));
push(@{$level->{buckets}}, new Guckets::Bucket(0, 5));

push(@{$level->{goals}}, Guckets::Goals::water(1, 1));
push(@{$level->{goals}}, Guckets::Goals::water(3, 4));

$level->auto_spare_bucket();
