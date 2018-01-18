#!/usr/bin/env perl
use strict;
use warnings;
use File::Basename ();
use File::Temp ();

sub tempfile_for {
    my $file = shift;
    my ($base, $dir, $suffix) = File::Basename::fileparse($file, qr/\.[^.]*/);
    my ($fh, $name) = File::Temp::tempfile(
        "$base-XXXXX",
        DIR    => $dir,
        EXLOCK => 0,
        SUFFIX => $suffix,
        UNLINK => 0,
    );
    my $mode = 0666 & ~umask;
    chmod $mode, $fh;
    return ($fh, $name);
}

my ($fh, $name) = tempfile_for "/tmp/foo.txt.foo";

