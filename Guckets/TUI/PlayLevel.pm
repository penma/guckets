package Guckets::TUI::PlayLevel;

use strict;
use warnings;

use Guckets::TUI;

sub print_state
{
	my ($level) = @_;
	print "Buckets:\n";
	my $id = 1;
	foreach (@{$level->{buckets}})
	{
		my $visu = "|";
		$visu .= "****|" for (1 .. $_->{water});
		$visu .= "....|" for ($_->{water} + 1 .. $_->{water_max});
		
		printf("     %5d: %2d / %2d %s\n",
			$id, $_->{water}, $_->{water_max},
			$visu);
		$id++;
	}
	printf("     Spare: %2d / %2d\n",
		$level->{spare_bucket}->{water},
		$level->{spare_bucket}->{water_max});
	
	print "Goals to reach:\n";
	foreach (@{$level->{goals}})
	{
		print ($_->{callback}->($level) ? "[OK] " : "     ");
		printf($_->{text}, @{$_->{arguments}});
		print "\n";
	}
}

sub play
{
	my ($level) = @_;
	
	Guckets::TUI::help() if (caller() ne "Guckets::TUI::PlayLevelset");
	print "\n";
	
	print_state($level);
	my $changed = 0;
	
	print "> ";
	while (<STDIN>)
	{
		# split line into words
		chomp;
		@_ = split;
		
		if (!defined($_[0])) { } # no-op
		# bucket operations
		elsif ($_[0] eq "fill" or $_[0] eq "empty")
		{
			my $n = int($_[1]);
			if ($n == 0 or $n > scalar(@{$level->{buckets}}))
			{
				print "ERROR: No such bucket.\n";
			}
			else
			{
				if ($_[0] eq "fill")
				{
					print "Filling bucket $n\n";
					$level->bucket_fill($n - 1);
				}
				else
				{
					print "Emptying bucket $n\n";
					$level->bucket_empty($n - 1);
				}
				$changed = 1;
			}
		}
		elsif ($_[0] eq "pour")
		{
			my ($n1, $n2) = (int($_[1]), int($_[2]));
			if ($n1 == 0 or $n2 == 0
			    or $n1 > scalar(@{$level->{buckets}})
			    or $n2 > scalar(@{$level->{buckets}}))
			{
				print "ERROR: No such bucket.\n";
			}
			else
			{
				if ($n1 == $n2)
				{
					print "ERROR: Source and destination bucket are the same!\n";
				}
				else
				{
					print "Pouring water from bucket $n1 to bucket $n2\n";
					$level->bucket_pour($n1 - 1, $n2 - 1);
					$changed = 1;
				}
			}
		}
		# help and various
		elsif ($_[0] eq "help") { Guckets::TUI::help($_[1]); }
		elsif ($_[0] eq "show") { $changed = 1; }
		elsif ($_[0] eq "exit" or $_[0] eq "quit") { return 4; }
		else { print "No such command.\n"; }
		
		if ($changed)
		{
			print_state($level);
			$changed = 0;
		}
		
		if ($level->goal_check())
		{
			print "Congratulations, you've solved this level!\n";
			return 0;
		}
		
		print "> ";
	}
	
	return 1;
}

1;
