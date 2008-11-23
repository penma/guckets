package Guckets::CUI::PlayLevel;

use strict;
use warnings;
use 5.010;
use POSIX;
use myterm;

use Guckets::Bucket;
use Guckets::Level;
use Guckets::Goals;

use Guckets::CUI;

my %keys = (
	left => "\e[D",
	down => "\e[B",
	up => "\e[A",
	right => "\e[C",
	select => "\cJ",
	help => "h",
	quit => "q"
);

sub play
{
	my ($level) = @_;
	
	my $key;
	my $current_bucket = 0;
	my $selected_bucket = -1;
	Guckets::CUI::Render::render($level, $current_bucket, $selected_bucket);
	while ($key = myterm::readkey())
	{
		$current_bucket-- if ($key eq $keys{left} and $current_bucket > 0);
		$current_bucket++ if ($key eq $keys{right} and $current_bucket < scalar(@{$level->{buckets}}) - 1);
		
		if ($key eq $keys{select})
		{
			if ($selected_bucket == -1) # no bucket selected yet
			{
				$selected_bucket = $current_bucket;
			}
			else # do some action, we have two buckets now
			{
				$level->bucket_pour($selected_bucket, $current_bucket)
					if ($selected_bucket != $current_bucket);
				$selected_bucket = -1;
			}
		}
		
		$level->bucket_fill($current_bucket) if ($key eq $keys{up});
		$level->bucket_empty($current_bucket) if ($key eq $keys{down});
		
		return 4 if ($key eq $keys{quit});
		Guckets::CUI::Render::help_full() if ($key eq $keys{help});
		
		Guckets::CUI::Render::render($level, $current_bucket, $selected_bucket);
		
		if ($level->goal_check())
		{
			Guckets::CUI::Dialog::dialog("normal", "Congratulations, you've solved this level!");
			return 0;
		}
	}
}

1;
