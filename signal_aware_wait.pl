#!/usr/bin/env perl
use strict;
use warnings;

# http://blog.kazuhooku.com/2015/02/writing-signal-aware-waitpid-in-perl.html

my %pid;

$SIG{TERM} = sub { die "GOT_SIGNAL\n" };
while (%pid) {
    my $pid = eval { wait };
    if (my $err = $@) {
        if ($err eq "GOT_SIGNAL\n") {
            kill TERM => keys %pid;
        } else {
            chomp $err;
            die $err;
        }
    } else {
        delete $pid{$pid};
    }
}
