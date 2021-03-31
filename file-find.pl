#!/usr/bin/env perl
use strict;
use warnings;
use File::Spec;

sub find {
    my ($topdir, $sub) = @_;
    my @dir = ($topdir);
    my $state = {};
    DIRLOOP: while (defined(my $dir = shift @dir)) {
        opendir my $dh, $dir or die "$!: $dir";
        while (defined(my $path = readdir $dh)) {
            next if $path eq "." || $path eq "..";
            $path = File::Spec->catfile($dir, $path);
            local $_ = $path;
            my $ret = $sub->($path, $state);
            last DIRLOOP if ref($ret) eq 'SCALAR' && !$$ret;
            push @dir, $path if -d $path && -r _ && !-l $path;
        }
    }
    return $state;
}

my $size = find ".", sub {
    my ($path, $size) = @_;
    $size->{$path} = -s $path;
    if ($path eq ".git/refs") {
        return \0;
    }
};

use D;
d $size;
