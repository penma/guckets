$levelset = new Guckets::Levelset();
$levelset->{author} = "Various";
$levelset->{name} = "Default Levelset";

push(@{$levelset->{levels}}, "default/level$_.pl") for (1..12);
