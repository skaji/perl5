#!/usr/bin/env perl
use strict;
use warnings;

use File::Find ();
use Cwd ();

# with no chdir
sub remove_tree {
    my $dir = shift;
    return unless -d $dir;
    $dir = Cwd::abs_path($dir);

    my (@file, @dir);
    my $wanted = sub { -d ? push @dir, $_ : push @file, $_ };
    File::Find::find({wanted => $wanted, no_chdir => 1}, $dir);
    @file = sort { length $b <=> length $a } @file;
    @dir  = sort { length $b <=> length $a } @dir;
    for my $file (@file) {
        # warn "unlink $file\n";
        if (!unlink $file) {
            warn "failed to unlink $file: $!";
            return;
        }
    }
    for my $dir (@dir) {
        # warn "rmdir $dir\n";
        if (!rmdir $dir) {
            warn "failed to rmdir $dir: $!";
            return;
        }
    }
    return 1;
}

# remove_tree $ARGV[0];
