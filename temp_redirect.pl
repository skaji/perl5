#!/usr/bin/env perl
use strict;
use warnings;
use IO::Handle;

{
    package Guard;
    sub new {
        my ($class, $sub) = @_;
        bless { owner => $$, sub => $sub }, $class;
    }
    sub DESTROY {
        my $self = shift;
        return if $$ != $self->{owner};
        $self->{sub}->();
    }
}

{
    package IO::Handle;
    sub temp_redirect {
        my ($self, $mode, $file) = @_;
        CORE::open my $save, ">&", $self or return;
        if (CORE::open $self, $mode, $file) {
            return Guard->new(sub {
                CORE::open $self, ">&", $save;
                CORE::close $save;
            });
        } else {
            my $err = $!;
            CORE::close $save;
            $! = $err;
            return;
        }
    }
}

{
    my $g = STDOUT->temp_redirect(">>", "out.txt");
    print "1\n";
    system "ls";
}
system "pwd";
