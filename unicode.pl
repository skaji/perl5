#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Encode 'encode_utf8';

# ア U+30A2 (16進法)
my $A1 = "\N{U+30A2}";
my $A2 = "\x{30A2}";

print encode_utf8($_), "\n" for $A1, $A2;

# 𐐷
print encode_utf8("\x{10437}"), "\n";

{
    my $A1 = chr hex "30A2";
    my $A2 = chr hex "30A2";
    print encode_utf8($_), "\n" for $A1, $A2;
    print encode_utf8(chr hex "10437"), "\n";

    my $X = ord $A1;
    printf "%X\n", $X; # 30A2
    printf "%X\n", ord("ア");
}
{
    my $o = oct '777';
    print $o, "\n"; # 511 = 7 * (8**2) + 7 * 8 + 7
    printf "0%o\n", $o; # 0777
}
