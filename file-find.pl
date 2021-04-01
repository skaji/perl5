#!/usr/bin/env perl
use strict;
use warnings;
use File::Spec;

sub find {
    my ($topdir, $sub) = @_;
    my @dir = ($topdir);
    while (defined(my $dir = shift @dir)) {
        opendir my $dh, $dir or die "$!: $dir";
        while (defined(my $path = readdir $dh)) {
            next if $path eq "." || $path eq "..";
            $path = File::Spec->catfile($dir, $path);
            local $_ = $path;
            my $ret = $sub->($path);
            return if ref($ret) eq 'SCALAR' && !$$ret;
            push @dir, $path if -d $path && -r _ && !-l $path;
        }
    }
}

my $size = {};
find ".", sub {
    my $path = shift;
    $size->{$path} = -s $path;
    return \0 if $path eq ".git/refs";
};

use D;
d $size;
