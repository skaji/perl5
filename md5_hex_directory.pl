#!/usr/bin/env perl
use strict;
use warnings;

use Cwd ();
use Digest::MD5 ();
use File::Find ();
use File::Spec::Unix ();

sub md5_hex_directory {
    my $dir = shift;
    die "$dir: no such directory" unless -d $dir;
    $dir = Cwd::abs_path($dir);

    my %entry; my $find = sub {
        my $name = File::Spec::Unix->abs2rel($_, $dir);
        $entry{$name} = -f $_ ? $_ : undef;
    };
    File::Find::find({wanted => $find, no_chdir => 1}, $dir);

    my $digest = Digest::MD5->new;
    for my $name (sort keys %entry) {
        $digest->add($name);
        my $file = $entry{$name};
        next unless defined $file;
        open my $fh, "<", $file or die "$file: $!";
        $digest->addfile($fh);
    }

    $digest->hexdigest;
}

print md5_hex_directory("."), "\n";
