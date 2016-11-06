#!/usr/bin/env perl
use strict;
use warnings;

sub _redirect_stdout {
    my ($cmd, $dest) = @_;
    my $temp = "$dest.$$.tmp";
    my $clean = sub { local ($!, $?); unlink $temp if -e $temp };
    $clean->();

    open my $out, ">", $temp or return;
    my $pid = open my $in, "-|", @$cmd;
    if (!$pid) {
        $clean->();
        return;
    }
    while (1) {
        my $len = read $in, my $data, 64*1024;
        if (!defined $len) {
            $clean->();
            return;
        } elsif ($len) {
            print {$out} $data;
        } else {
            last;
        }
    }
    close $out;
    close $in;
    if ($? != 0) {
        $clean->();
        $! = 0;
        # check $? yourself
        return;
    }
    rename $temp, $dest or return;
    return 1;
}

sub gzip {
    my ($src, $dest) = @_;
    _redirect_stdout ["gzip", "--stdout", "--no-name", $src], $dest;
}

sub gunzip {
    my ($src, $dest) = @_;
    _redirect_stdout ["gzip", "--decompress", "--stdout", $src], $dest;
}
