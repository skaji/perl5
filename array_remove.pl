#!/usr/bin/env perl
use strict;
use warnings;

sub remove_first (&\@) {
    my ($block, $array) = @_;
    for my $i (0..$#{$array}) {
        local $_ = $array->[$i];
        if ($block->()) {
            splice @$array, $i, 1;
            return 1;
        }
    }
    return undef;
}

sub remove (&\@) {
    my ($block, $array) = @_;
    my $removed;
    for my $i (reverse 0..$#{$array}) {
        local $_ = $array->[$i];
        if ($block->()) {
            splice @$array, $i, 1;
            $removed++;
        }
    }
    return $removed;
}

my @a = (undef, 1, undef, 2, 3, undef, 4, undef);
remove { !defined } @a;
print "@a\n";
