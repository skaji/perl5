#!/usr/bin/env perl
use strict;
use warnings;

use Benchmark 'cmpthese';
use POSIX ();

cmpthese -1, {
    posix => sub {
        my $t = POSIX::strftime("%Y-%m-%d %H:%M:%S", localtime);
    },
    sprintf => sub {
        my ($sec, $min, $hour, $day, $mon, $year) = localtime;
        my $t = sprintf "%04d-%02d-%02d %02d:%02d:%02d",
            $year + 1900, $mon + 1, $day, $hour, $min, $sec;
    },
};

__END__

            Rate   posix sprintf
posix   154566/s      --    -71%
sprintf 530962/s    244%      --
