#!/usr/bin/env perl
#
# Usage: usage.pl [options] [args]
#  -h, --help     show help
#  -v, --version  show version
#
# Examples:
#  > usage.pl arg1 arg2
#
use strict;
use warnings;

sub usage {
    open my $fh, "<", $0 or return;
    (undef, my @line) = <$fh>;
    for (@line) {
        s/^#// and print and next;
        return;
    }
}

__PACKAGE__->usage;
