#!/usr/bin/env perl
use 5.24.0;
use Time::HiRes ();

sub qps_wrap {
    my ($qps, $code) = @_;

    my $count = 0;
    my $previous = Time::HiRes::time();
    sub {
        $count++;
        my $now = Time::HiRes::time();

        if ($now - $previous > 1) {
            $count = 0;
            $previous = $now;
        } else {
            my $sleep = $count / $qps - $now + $previous;
            select undef, undef, undef, $sleep if $sleep > 0;
        }
        $code->(@_);
    }
}

open my $fh, ">>:unix", "file.log" or die;
my $write = qps_wrap 100, sub { print {$fh} ("x" x 1024) . "\n" };

while (1) {
    # with 100qps
    $write->();
}
