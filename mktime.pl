#!/usr/bin/env perl
use strict;
use warnings;
use Time::Local ();

sub mktime {
    my %args = @_;
    Time::Local::timelocal(
        ($args{second} || 0),
        ($args{minute} || 0),
        ($args{hour}   || 0),
        ($args{day}    || die),
        ($args{month}  || die) - 1,
        ($args{year}   || die) - 1900,
    );
}

my $time = mktime year => 2017, month => 2, day => 1;

print $time, "\n";
