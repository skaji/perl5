#!/usr/bin/env perl
use strict;
use warnings;
use Pod::Usage 1.33 (); # shipt with 5.8.8

sub show_help {
    open my $fh, '>', \my $out;
    Pod::Usage::pod2usage
        exitval => 'noexit',
        input => $0,
        output => $fh,
        sections => 'SYNOPSIS|COMMANDS|OPTIONS|EXAMPLES',
        verbose => 99,
    ;
    $out =~ s/^[ ]{4,6}/  /mg;
    $out =~ s/\n$//;
    print $out;
}

show_help;

=head1 SYNOPSIS

this is synopsis

=head1 OPTIONS

this is options

=head1 EXAMPLES

this is examples

=head1 AUTHOR

Shoichi Kaji

=cut
