#!/usr/bin/env perl
use strict;
use Getopt::Long ();

=pod NOTE

Since Getopt::Long 2.39 (shipt with v5.18.0, 2013-03-12),
it has Getopt::Long::Parser->getoptionsfromarray.

See https://metacpan.org/release/Getopt-Long

=cut

sub new {
    bless {}, shift;
}

sub parse_options {
    my ($self, @argv) = @_;

    my $parser = Getopt::Long::Parser->new(
        config => [qw(no_auto_abbrev no_ignore_case)],
    );
    local @ARGV = @argv;
    $parser->getoptions(
        "f|file=s" => \$self->{file},
    ) or exit 1;
    $self->{argv} = \@ARGV;
}

sub run {
    my $self = shift;
    require Data::Dumper;
    print Data::Dumper::Dumper($self);
}

unless (caller) {
    my $app = __PACKAGE__->new;
    $app->parse_options(@ARGV);
    $app->run;
}
