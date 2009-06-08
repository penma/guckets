package myterm;
use strict;
use warnings;

use Term::ReadLine;
use Term::Size;
use POSIX;

sub set {
	my $termios = new POSIX::Termios;
	$termios->getattr(0);
	$termios->setlflag($termios->getlflag | $_[0]);
	$termios->setattr(0, POSIX::TCSANOW);
}

sub unset {
	my $termios = new POSIX::Termios;
	$termios->getattr(0);
	$termios->setlflag($termios->getlflag & ~$_[0]);
	$termios->setattr(0, POSIX::TCSANOW);
}

sub readkey {
	my ($stream, $current);
	sysread(STDIN, $current, 1) or return undef;
	$stream .= $current;

	# translate some crap into something that sucks less
	$stream =~ y/\cM/\cJ/;

	# fully resolve an escape sequence
	if ($current eq "\e") {
		sysread(STDIN, $current, 1);
		$current =~ y/O/\[/;
		$stream .= $current;

		if ($current eq "[") { # application/cursor keys
			sysread(STDIN, $current, 1);
			$stream .= $current;

			if ($current !~ /[ABCD]/) { # probably one of home delete..
				sysread(STDIN, $current, 1);
				$stream .= $current;
				# don't bother sanitizing further
			}
		}
	}

	return $stream;
}

sub readline {
	my $term = Term::ReadLine->new('Screenedit');
	term_set(POSIX::ECHO);
	my $line = $term->readline($_[0]);
	term_unset(POSIX::ECHO);
	return $line;
}

sub dimensions {
	my ($w, $h) = Term::Size::chars *STDOUT{IO};
	($w, $h) = (80, 24) if (!defined($w) or $w == 0);
	return ($w, $h);
}

sub width {
	return (dimensions())[0];
}

sub height {
	return (dimensions())[1];
}

1;
