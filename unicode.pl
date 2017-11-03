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
print encode_utf8("\x{10437}");
