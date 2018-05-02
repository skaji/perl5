#!/usr/bin/env perl
use strict;
use warnings;
use Digest::MD5 ();

=head1 HINTS

One liner:

  echo foo | perl -MDigest::MD5=md5 -nle 'my $num = hex unpack "H8", md5 $_; print $num'

=cut

my $original_digest_func = \&Digest::MD5::md5;

# returns 0 <= value < 2**32 (= 4294967296)
sub digest32 {
    my $data = shift;
    my $original = $original_digest_func->($data);
    # convert leading 4 bytes (= 32bit) to hex_string
    # eg:
    #  original = "\x01\x02\x03\x04\x05...";
    #  hex_string = "01020304"
    #  numeric = 1*16^6 + 2*16^4 + 3*16^2 + 4*16^0
    my $hex_string = unpack 'H8', $original;
    my $numeric = hex $hex_string;
    return $numeric;
}


for my $str (map { "foo$_" } 1..100) {
    printf "%s %d\n", $str, digest32 $str;
}

