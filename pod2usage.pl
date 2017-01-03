#!/usr/bin/env perl
use strict;
use warnings;
use Pod::Usage 1.33 (); # shipt with 5.8.8

Pod::Usage::pod2usage(
    exitval => 'noexit',
    sections => 'SYNOPSIS|OPTIONS|EXAMPLES',
    verbose => 99,
);

=head1 SYNOPSIS

this is synopsis

=head1 OPTIONS

this is options

=head1 EXAMPLES

this is examples

=head1 AUTHOR

Shoichi Kaji

=cut
