#!/usr/bin/env perl
use strict;
use warnings;
use Time::Piece ();
use POSIX ();

my $is_local = sub { $_[0]->[Time::Piece::c_islocal] ? 1 : 0 };
my $print = sub { printf "%-10s %-10s %-30s %-10s\n", @_ };
my $strftime = sub { POSIX::strftime("%Y-%m-%d %H:%M:%S %z", localtime $_[0]) };

my %case = (
    'with_%z' => {
        string => "2018-01-01 01:00:00 +1000",
        format => "%Y-%m-%d %H:%M:%S %z",
    },
    'without_%z' => {
        string => "2018-01-01 00:00:00",
        format => "%Y-%m-%d %H:%M:%S",
    },
);

print "perl $^V, Time::Piece @{[ Time::Piece->VERSION ]}\n\n";

$print->("name", "method", "epoch", "local");
for my $name (sort keys %case) {
    my $string = $case{$name}{string};
    my $format = $case{$name}{format};

    for my $method (qw(localtime gmtime)) {
        my $t = Time::Piece->$method->strptime($string, $format);
        $print->($name, $method, $strftime->($t->epoch), $t->$is_local);
    }
}
__END__


* perl v5.10.1, Time::Piece 1.20
name       method     epoch                          local
with_%z    localtime  2017-12-31 15:00:00 +0900      1
with_%z    gmtime     2018-01-01 00:00:00 +0900      0
without_%z localtime  2018-01-01 00:00:00 +0900      1
without_%z gmtime     2018-01-01 09:00:00 +0900      0


* perl v5.10.1, Time::Piece 1.15
name       method     epoch                          local
with_%z    localtime  2018-01-01 10:00:00 +0900      0
with_%z    gmtime     2018-01-01 10:00:00 +0900      0
without_%z localtime  2018-01-01 09:00:00 +0900      0
without_%z gmtime     2018-01-01 09:00:00 +0900      0
