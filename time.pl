#!/usr/bin/env perl
use 5.10.1;
use strict;
use warnings;
use Time::Local ();

sub time_ {
    my %arg = @_;
    Time::Local::timelocal(
        ($arg{second} // 0),
        ($arg{minute} // 0),
        ($arg{hour}   // 0),
        ($arg{day}    // die),
        ($arg{month}  // die) - 1,
        ($arg{year}   // die) - 1900,
    );
}

my $t  = time_ year => 2017, month => 2, day => 1;

say $t;

