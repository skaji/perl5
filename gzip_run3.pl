#!/usr/bin/env perl
use strict;
use warnings;
use IPC::Run3 ();

sub gzip {
    my ($src, $dest) = @_;
    IPC::Run3::run3(["gzip", "--stdout", $src], \undef, $dest, \my $err);
    if ($? == 0) {
        return undef;
    } else {
        $err ||= "Failed to `gzip --stdout $src`, \$? = $?";
        return $err;
    }
}

sub gunzip {
    my ($src, $dest) = @_;
    IPC::Run3::run3(["gzip", "--decompress", "--stdout", $src], \undef, $dest, \my $err);
    if ($? == 0) {
        return undef;
    } else {
        $err ||= "Failed to `gzip --decompress --stdout $src`, \$? = $?";
        return $err;
    }
}

my $err = gzip $0, "$0.gz";
die $err if $err;

