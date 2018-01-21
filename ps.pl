#!/usr/bin/env perl
use strict;
use warnings;

sub ps {
    my %ps;
    for my $line (`ps axo pid=,command=`) { # XXX "cmd" does not work on macOS
        chomp $line;
        $line =~ s/^\s+//;
        my ($pid, $cmd) = split /\s+/, $line, 2;
        $ps{$pid} = $cmd;
    }
    \%ps;
}

use DDP;
my $ps = ps;
p $ps;
