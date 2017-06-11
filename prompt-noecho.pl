#!/usr/bin/env perl
use strict;
use warnings;
use IO::Handle;
use Term::ReadKey 'ReadMode';

# cf https://github.com/skaji/App-RemoteCommand/blob/master/lib/App/RemoteCommand.pm

sub prompt {
    my $msg = shift;
    chomp $msg;
    local $| = 1;

    print $msg;
    ReadMode 'noecho', \*STDIN;

    my $SIGNAL = "catch signal INT\n";
    my $answer = eval {
        local $SIG{INT} = sub { die $SIGNAL };
        <STDIN>;
    };
    my $error = $@;

    ReadMode 'restore', \*STDIN;
    print "\n";

    die $error if $error;
    chomp $answer;
    $answer;
}


my $pass = prompt "pass: ";
print "Your pass is [$pass]\n";
