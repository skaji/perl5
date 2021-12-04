#!/usr/bin/env perl
use strict;
use warnings;

use Getopt::Long ();

use Cwd qw(getcwd abs_path);
use File::Basename qw(basename dirname);
use File::Path qw(mkpath rmtree);
use File::Spec::Functions qw(catfile);

use File::Copy qw(copy move);
use File::Slurper qw(read_text read_binary write_text write_binary); # depends Encode 2.11 (perl v5.8.8+)
use File::Temp ();
use File::Which qw(which);
use FindBin ();
use HTTP::Tinyish;
use IPC::Run3 ();
use JSON::PP ();
use YAML::PP ();

my $HELP = <<'EOF';
Usage: app [options] [argv]

Options:
 -h, --help  show this help

Examples:
 $ app.pl -h
EOF

{
    package App;

    sub new {
        my ($class, %argv) = @_;
        bless {}, $class;
    }

    sub run {
        my ($self, @argv) = @_;

        my $parser = Getopt::Long::Parser->new(
            config => ["no_auto_abbrev", "no_ignore_case", "bundling"],
        );
        $parser->getoptionsfromarray(
            \@argv,
            "h|help" => sub { die $HELP },
        ) or return 1;

        return 0;
    }
}

my $app = App->new;
exit $app->run(@ARGV);
