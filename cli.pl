#!/usr/bin/env perl

package App;
use strict;
use warnings;
use Getopt::Long 2.39 (); # perl 5.18+
use Pod::Usage 1.33 ();   # perl 5.8.8+

our $VERSION = '0.001';

sub new {
    my ($class, @argv) = @_;
    bless {@argv}, $class;
}

sub run {
    shift->_run(@_) ? 0 : 1;
}

sub _run {
    my ($class, @argv) = @_;
    my $self = $class->new;
    $self->parse_options(@argv) or return;

    my $cmd = shift @{$self->{argv}};
    if (!$cmd) {
        warn "Need subcommand, try `$0 --help`\n";
        return;
    } elsif (my $sub = $self->can("cmd_$cmd")) {
        return $self->$sub(@{$self->{argv}});
    } else {
        warn "Unknown subcommand '$cmd', try `$0 --help`\n";
        return;
    }
}

sub parse_options {
    my ($self, @argv) = @_;
    my $parser = Getopt::Long::Parser->new(
        config => [qw(no_auto_abbrev no_ignore_case bundling)],
    );
    $parser->getoptionsfromarray(\@argv,
        "h|help" => \my $help,
        "v|version" => \my $version,
    ) or return;
    unshift @argv, "help" if $help;
    unshift @argv, "version" if $version;
    $self->{argv} = \@argv;
    return 1;
}

sub cmd_help {
    Pod::Usage::pod2usage(
        exitval  => 'NOEXIT',
        sections => 'SYNOPSIS|OPTIONS|EXAMPLES',
        verbose  =>  99,
    );
    return 1;
}

sub cmd_version {
    my $self = shift;
    my $class = ref $self;
    printf "%s %s\n", $class, $class->VERSION;
    return 1;
}

sub cmd_go {
    my ($self, @argv) = @_;
    for my $i (0 .. $#argv) {
        my $argv = $argv[$i];
        print "arg$i: $argv\n";
    }
    return 1;
}

package main;

exit App->run(@ARGV);

__END__

=head1 NAME

cli - example of cli

=head1 SYNOPSIS

  > cli [OPTIONS] command args...

=head1 OPTIONS

  -v, --version  show version
  -h, --help     show help

=head1 EXAMPLES

  > cli help
  > cli version
  > cli go

=cut
