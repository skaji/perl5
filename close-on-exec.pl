#!/usr/bin/env perl
use 5.22.1;
use warnings;
use experimental qw/ postderef signatures /;
use Fcntl ();

# 1
open my $fh, ">", "file.log";
fcntl $fh, Fcntl::F_SETFD, 0;

# 2
my $fh2;
{
    local $^F = 10;
    open $fh2, ">", "file.log";
}


=pod NOTE

The following does NOT work

    my ($read, $write);
    {
        local $^F = 10;
        pipe $read, $write;
    }

You should use C<fcntl> if you use C<pipe>

=cut
