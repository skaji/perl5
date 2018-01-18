#!/usr/bin/env perl
use strict;
use warnings;

use Pod::Text ();

sub show_help {
    open my $fh, ">", \my $out;
    Pod::Text->new->parse_from_file($0, $fh);
    $out =~ s/^[ ]{4,6}/  /mg;
    chomp $out;
    print $out;
}

show_help;


__END__

=head1 NAME

usage2.pl - Usage part 2

=head1 SYNOPSIS

  usage2.pl [options] args

=head1 OPTIONS

=over 4

=item -v, --version

Show version

=item -h, --help

Show help

=back

=head1 AUTHOR

Shoichi Kaji

=cut
