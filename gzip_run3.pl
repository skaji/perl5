#!/usr/bin/env perl
use strict;
use warnings;
use IPC::Run3 ();

sub gunzip_file {
    my ($src, $dest) = @_;
    IPC::Run3::run3(['gzip', '--decompress', '--stdout'], $src, $dest, \my $err);
    my $ok = $? == 0;
    return ($ok, $ok ? undef : $err);
}

sub gzip {
    my $src = shift;
    IPC::Run3::run3(['gzip', '--stdout'], \$src, \my $dest, \my $err);
    my $ok = $? == 0;
    return $ok ? ($dest, undef) : (undef, $err);
}

my $content = do { local (@ARGV, $/) = $0; <> };
my ($dest, $err) = gzip $content;
print $dest;
