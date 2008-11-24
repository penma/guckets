package Guckets::TUI::PlayLevelset;

use strict;
use warnings;

use Guckets::TUI;

sub print_levels
{
	my ($levelset) = @_;
	for (my $c = 0; $c < scalar(@{$levelset->{levels}}); $c++)
	{
		printf("%4d %s (%s)\n", $c + 1, $levelset->{level_names}->[$c], $levelset->{level_authors}->[$c]);
	}
}

sub play
{
	my ($levelset) = @_;
	
	Guckets::TUI::help();
	print "\n";
	
	# preload the level names
	$levelset->{level_names} = [];
	$levelset->{level_authors} = [];
	foreach (@{$levelset->{levels}})
	{
		my ($level, undef, $error) = Guckets::Load::load($levelset->{basepath} . "/" . $_);
		if (defined($error))
		{
			push(@{$levelset->{level_names}}, "(Level load error: $error)");
			push(@{$levelset->{level_authors}}, "(Error)");
		}
		else
		{
			push(@{$levelset->{level_names}}, $level->{name} // "Unknown");
			push(@{$levelset->{level_authors}}, $level->{author} // "Anonymous");
		}
		undef($level);
	}
	
	print_levels($levelset);
	
	print "> ";
	while (<STDIN>)
	{
		# split line into words
		chomp;
		@_ = split;
		
		if (!defined($_[0])) { goto prepare_next; }; # no-op
		
		if ($_[0] eq "start")
		{
			my $num = int($_[1] // 1) - 1;
			if ($num < 0 or $num > scalar(@{$levelset->{levels}}))
			{
				print "ERROR: No such level.\n";
				goto prepare_next;
			}
			else
			{
				my ($current_level, undef, $error) = Guckets::Load::load(
					$levelset->{basepath} . "/"
					. $levelset->{levels}->[$num]);
				if (defined($error))
				{
					printf("Error loading this level: %s", $error);
					print "\n";
					goto prepare_next;
				}
				elsif (!defined($current_level))
				{
					print "Error playing this level: The level did not provide a level (maybe it's a levelset?)" . "\n";
					goto prepare_next;
				}
				
				my $status = Guckets::TUI::PlayLevel::play($current_level);
				# decide what to do by whether the level was solved
				# if it was exited (!= 0), just go back to the menu.
				goto prepare_next if ($status != 0);
				
				# if it was solved (== 0), choose the next level and load it
				$num++;
				if ($num == scalar(@{$levelset->{levels}})) # all levels done
				{
					print "Congratulations! You mastered the whole levelset!" . "\n";
					return 0;
				}
				else
				{
					# load next level.
					$num++;
					$_ = "start $num";
					redo;
				}
			}
		}
		
		# help and various
		if ($_[0] eq "help") { Guckets::TUI::help($_[1]); }
		elsif ($_[0] eq "show") { print_levels($levelset); }
		elsif ($_[0] eq "exit" or $_[0] eq "quit") { return 4; }
		else { print "No such command.\n"; }
		
		prepare_next:
		
		print "> ";
	}
}

1;
