#!/usr/bin/env perl
use strict;
use warnings;

sub _redirect_stdout {
    my ($cmd, $dest) = @_;
    my $tmp = "$dest.$$.tmp";
    open my $fh, ">", $tmp or return;
    my $pid = fork // die;
    if ($pid == 0) {
        open STDOUT, ">&", $fh;
        exec @$cmd;
        exit 255;
    }
    close $fh;
    waitpid $pid, 0;
    if ($? == 0) {
        return rename $tmp, $dest;
    } else {
        unlink $tmp;
        return;
    }
}

sub gzip {
    my ($src, $dest) = @_;
    _redirect_stdout ["gzip", "--stdout", "--no-name", $src], $dest;
}

sub gunzip {
    my ($src, $dest) = @_;
    _redirect_stdout ["gzip", "--decompress", "--stdout", $src], $dest;
}
