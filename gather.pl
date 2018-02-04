#!/usr/bin/env perl
use strict;
use warnings;

# SEE https://metacpan.org/source/GAAL/Perl6-Take-0.04/lib/Perl6/Take.pm

our @TAKEN;

sub gather (&) {
    my $sub = shift;
    local @TAKEN = (@TAKEN, []);
    $sub->();
    @{$TAKEN[-1]};
}

sub take {
    die "Cannot call take() outside gather block" unless @TAKEN;
    push @{$TAKEN[-1]}, @_;
}

sub gathered {
    die "Cannot call gathered() outside gather block" unless @TAKEN;
    scalar @{$TAKEN[-1]};
}

my @all = gather {
    for (1..10) {
        take $_ if $_ % 2 == 1;
    }
    take "oops" unless gathered;
};

print "@all\n";
