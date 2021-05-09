#!/usr/bin/env perl
use strict;
use warnings;
use File::Temp ();
use IPC::Run3 ();

sub run {
    my ($cmd, $outfile) = @_;
    my $out;
    IPC::Run3::run3 $cmd, undef, ($outfile ? $outfile : \$out), \my $err, { return_if_system_error => 1 };
    $err ||= "$!" if $? == -1;
    return ($out, $err, $?);
}

sub run_pipe {
    my ($cmd1, $cmd2, $outfile) = @_;
    my ($out, $err);
    my $temp = File::Temp->new(EXLOCK => 0);
    IPC::Run3::run3 $cmd1, undef, $temp->filename, \$err, { return_if_system_error => 1 };
    if ($? == 0) {
        undef $err;
        IPC::Run3::run3 $cmd2, $temp->filename, ($outfile ? $outfile : \$out), \$err, { return_if_system_error => 1 };
    }
    $err ||= "$!" if $? == -1;
    return ($out, $err, $?);
}
