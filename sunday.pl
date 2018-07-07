#!/usr/bin/env perl
use strict;
use warnings;

use Time::Local ();
use Time::Piece;
use Time::Seconds 'ONE_DAY';

{
    my (undef, undef, undef, $mday, $mon, $year, $wday) = CORE::localtime;
    my $sunday = Time::Piece->new(
        Time::Local::timelocal(0, 0, 0, $mday, $mon, $year) - $wday * ONE_DAY
    );
    print $sunday, "\n";
}

# Time::Piece 1.32+ (shipt with perl 5.28.0) has truncate() method.
if (eval { Time::Piece->VERSION('1.32') }) {
    my $now = Time::Piece->new->truncate(to => 'day');
    my $sunday = $now - $now->_wday * ONE_DAY;
    print $sunday, "\n";
} else {
    printf "Time::Piece %s does not have truncate() method.\n", Time::Piece->VERSION;
}
