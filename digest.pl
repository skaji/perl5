#!/usr/bin/env perl
use strict;
use warnings;
use Digest::MD5 ();

=head1 HINTS

One liner:

  echo foo | perl -MDigest::MD5=md5 -nle 'my $num = hex unpack "H4", md5 $_; print $num'

=cut

# returns 0 <= value < 16**4 (= 65536)
sub digest {
    my $data = shift;
    my $md5 = Digest::MD5::md5 $data;
    # convert leading **2 (not 4)** bytes to hex_string
    # eg:
    #  md5 = "\x01\x02\x03....";
    #  hex_string = "0102"
    #  numeric = 0 * (16**3) + 1 * (16**2) + 0 * (16**1) + 2 * (16**0) = 258
    my $hex_string = unpack 'H4', $md5;
    my $numeric = hex $hex_string;
    return $numeric;
}


for my $str (map { "foo$_" } 1..100) {
    printf "%s %d\n", $str, digest $str;
}

