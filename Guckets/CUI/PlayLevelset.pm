package Guckets::CUI::PlayLevelset;

use strict;
use warnings;
use 5.010;
use POSIX;
use myterm;

use Guckets::CUI;
use Guckets::CUI::PlayLevelset;

sub render {
	my ($levelset, $current_level_index, $menu_selected) = @_;
	my ($width, $height) = myterm::dimensions();

	# clear and init line chars
	print "\e[2J\e[2J\e(B\e)0";

	# title
	Guckets::CUI::Primitives::box(1, 1, $width, 3);
	my $title = "G U C K E T S";
	printf("\e[2;%dH\e[1m%s\e[m",
		int(($width - length($title)) / 2),
		$title);

	# help area
	Guckets::CUI::Primitives::text(3, 5, 30, << 'END_OF_HELP');
Guckets
Console-Based User Interface

Use the cursor keys to choose a level to play. Use Enter to start a level.

Keys:
.   Cursor keys: Choose level
    Enter: Play
    q: Quit
END_OF_HELP
	Guckets::CUI::Primitives::box(1, 4, 34, $height, "Quick Help");

	# for the level list: find out where to scroll
	my $list_inside_height = $height - 5;
	my $scroll;
	# first step: put the selected level into the middle
	$scroll = $menu_selected - int($list_inside_height / 2);
	# second step: should this now be negative (we're at the top),
	# change it to null
	$scroll = 0 if ($scroll < 0);
	# third step: check if there's lotsa empty space now and if yes, shift
	# it again
	$scroll = scalar(@{$levelset->{levels}}) - $list_inside_height
		if ($scroll != 0
		and $scroll > scalar(@{$levelset->{levels}}) - $list_inside_height);

	# now list the levels
	for (my $c = 0;
	     $c < $list_inside_height
	         and $c < scalar(@{$levelset->{levels}}) - $scroll;
	     $c++) {
		my $C = $c + $scroll;
		if ($C == $menu_selected) { print "\e[7m"; }
		if ($C == $current_level_index) { print "\e[1m"; }
		printf("\e[%d;%dH%4d %s\e[m",
			5 + $c, 37,
			$C + 1,
			$levelset->{level_names}->[$C]
		);
	}
	Guckets::CUI::Primitives::box(35, 4, $width, $height, "Levels");
}

sub play {
	my ($levelset) = @_;
	my $current_level;
	my $current_level_index = -1;
	my $menu_selected = 0;

	# preload the level names
	$levelset->{level_names} = [];
	foreach (@{$levelset->{levels}}) {
		my ($level, undef, $error) =
			Guckets::Load::load($levelset->{basepath} . "/" . $_);
		if (defined($error)) {
			push(@{$levelset->{level_names}}, "(Level load error: $error)");
		} else {
			push(@{$levelset->{level_names}}, $level->{name} // "Unknown");
		}
		undef($level);
	}

	render($levelset, $current_level_index, $menu_selected);

	my $key;
	while ($key = myterm::readkey()) {
		# start the selected level
		if ($key eq "\cJ") {
			# do we have a different level loaded?
			if (defined($current_level)
				and $current_level_index != $menu_selected) {
				if (!Guckets::CUI::Dialog::dialog("question",
					"You have a level loaded! Do you want to load another one anyway?")) {
					goto prepare_next;
				}
			}

			# should we continue the current level or restart it?
			if ($current_level_index == $menu_selected) {
				if (Guckets::CUI::Dialog::dialog("question",
					"You have this level already open."
					. "Do you want to continue the current game instead of reloading it?")) {
					goto play;
				}
			}

			# not skipped this code - this means we should restart it
			# or just load it - so do.
			($current_level, undef, my $error) = Guckets::Load::load(
				$levelset->{basepath} . "/"
				. $levelset->{levels}->[$menu_selected]);
			if (defined($error)) {
				Guckets::CUI::Dialog::dialog("info",
					sprintf("Error loading this level: %s", $error));
				goto prepare_next;
			} elsif (!defined($current_level)) {
				Guckets::CUI::Dialog::dialog("info",
					sprintf("Error loading this level: %s",
					"The level did not provide a level (maybe it's a levelset?)"));
				goto prepare_next;
			}

			play:

			$current_level_index = $menu_selected;
			my $status = Guckets::CUI::PlayLevel::play($current_level);
			# decide what to do by whether the level was solved
			# if it was exited (!= 0), just go back to the menu.
			goto prepare_next if ($status != 0);

			# if it was solved (== 0), choose the next level and load it
			$current_level = undef;
			$menu_selected++;

			# when everything's finished, give cookie to player
			if ($menu_selected == scalar(@{$levelset->{levels}})) {
				Guckets::CUI::Dialog::dialog("info",
					"Congratulations! You mastered the whole levelset!");
				$menu_selected--;
				$current_level_index = -1;
				goto prepare_next;
			} else {
				# load next level.
				redo;
			}
		}

		if ($key eq "q") {
			if (defined($current_level)) {
				if (Guckets::CUI::Dialog::dialog("question",
					"You have a level loaded! Do you still want to exit?")) {
					return 0;
				}
			} else {
				return 0;
			}
		}

		if (($key eq "\e[A" or $key eq "k") and $menu_selected > 0) {
			$menu_selected--;
		}
		if (($key eq "\e[B" or $key eq "j") and $menu_selected < scalar(@{$levelset->{levels}}) - 1) {
			$menu_selected++;
		}

		prepare_next:

		render($levelset, $current_level_index, $menu_selected);
	}
}

1;
