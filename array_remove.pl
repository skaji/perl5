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
    return;
}

sub remove (&\@) {
    my ($block, $array) = @_;
    my @i;
    for my $i (0..$#{$array}) {
        local $_ = $array->[$i];
        if ($block->()) {
            push @i, $i;
        }
    }
    return unless @i;

    for my $i (reverse @i) {
        splice @$array, $i, 1;
    }
    return 1;
}
