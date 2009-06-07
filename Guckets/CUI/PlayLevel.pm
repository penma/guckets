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
	"\e[D" => "left",
	"\e[B" => "down",
	"\e[A" => "up",
	"\e[C" => "right",
	"\cJ" => "select",

	"h" => "left",
	"j" => "down",
	"k" => "up",
	"l" => "right",

	"?" => "help",
	"q" => "quit",
);

sub play {
	my ($level) = @_;

	my $key;
	my $current_bucket = 0;
	my $selected_bucket = -1;
	Guckets::CUI::Render::render($level, $current_bucket, $selected_bucket);
	while ($key = myterm::readkey()) {
		$key = $keys{$key};

		if ($key eq "left" and $current_bucket > 0) {
			$current_bucket--;
		}
		if ($key eq "right"
			and $current_bucket < scalar(@{$level->{buckets}}) - 1) {
			$current_bucket++;
		}

		if ($key eq "select") {
			if ($selected_bucket == -1) { # no bucket selected yet
				$selected_bucket = $current_bucket;
			} else { # do some action, we have two buckets now
				$level->bucket_pour($selected_bucket, $current_bucket)
					if ($selected_bucket != $current_bucket);
				$selected_bucket = -1;
			}
		}

		if ($key eq "up") { $level->bucket_fill($current_bucket); }
		if ($key eq "down") { $level->bucket_empty($current_bucket); }

		if ($key eq "quit") { return 4; }
		if ($key eq "help") { Guckets::CUI::Render::help_full(); }

		Guckets::CUI::Render::render($level, $current_bucket, $selected_bucket);

		if ($level->goal_check()) {
			Guckets::CUI::Dialog::dialog("info",
				"Congratulations, you've solved this level!");
			return 0;
		}
	}
}

1;
