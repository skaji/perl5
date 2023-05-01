#!/usr/bin/env perl
use v5.36;
use experimental qw(builtin defer for_list try);

use CPAN::Perl::Releases::MetaCPAN;

my $releases = CPAN::Perl::Releases::MetaCPAN->new->get;

use X;

my @r =
    grep {
        my $v = $_->{version};
        $v =~ /^5\.(\d+)\.(\d+)$/ and $1 % 2 == 0;
    }
    map {
        my $r = $_;
        if (my ($v) = $r->{name} =~ /^perl-(5\.\d+\.\d+)$/) {
            my ($date) = $_->{date} =~ /(\d{4}-\d{2}-\d{2})/;
            { version => $v, date => $date };
        } else {
            ();
        }
    }
    $releases->@*;


say join "\t", "date", "version";
for my $r (@r) {
    say join "\t", $r->{date}, $r->{version};
}
