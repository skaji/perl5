#!/usr/bin/env perl
use strict;
use warnings;
use IO::Handle;
use Term::ReadKey 'ReadMode';

# cf https://github.com/skaji/App-RemoteCommand/blob/master/lib/App/RemoteCommand.pm

sub prompt {
    my $msg = shift;
    chomp $msg;
    STDOUT->printflush($msg);
    local $SIG{INT} = sub { ReadMode 'restore', \*STDIN; STDOUT->printflush("\n"); exit };
    ReadMode 'noecho', \*STDIN;
    my $answer = <STDIN>;
    ReadMode 'restore', \*STDIN;
    STDOUT->printflush("\n");
    chomp $answer;
    $answer;
}


my $pass = prompt "pass: ";
print "Your pass is [$pass]\n";
