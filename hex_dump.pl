#!/usr/bin/env perl
use strict;
use warnings;

my $x = ord "\cA";
printf "%02x\n", $x; # 01
printf "%02X\n", $x; # 01

sub hex_dump {
    my $binary = shift;
    join " ", map { sprintf "%02X", ord $_ } split //, $binary;
}

open my $fh, "<", "/dev/urandom" or die;
read $fh, my $binary, 16;
print hex_dump $binary;
