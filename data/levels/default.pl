$levelset = new Guckets::Levelset();
$levelset->{author} = "Various";
$levelset->{name} = "Default Levelset";

push(@{$levelset->{levels}}, "default/$_") for (1..15);
