#!/usr/bin/env perl
use strict;
use warnings;
use Time::Piece ();

sub strptime {
    my ($string, $format) = @_;
    die "Cannot parse %z/%Z correctly" if $format =~ /%[zZ]/;

    my $gmtime = Time::Piece->strptime($string, $format);
    my $tzoffset = Time::Piece->localtime->tzoffset->seconds;
    $gmtime->epoch - $tzoffset;
}

my $t = strptime("2018-01-01", "%Y-%m-%d");

print $t, "\n";
