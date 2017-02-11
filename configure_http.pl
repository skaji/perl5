#!/usr/bin/env perl
use strict;
use warnings;
use HTTP::Tinyish;

# from menlo

sub configure_http {
    my @try = qw(HTTPTiny Curl Wget);
    for my $backend (map "HTTP::Tinyish::$_", @try) {
        next unless HTTP::Tinyish->configure_backend($backend);
        next unless $backend->supports("https");
        return $backend->new(verify_SSL => 1);
    }
    return;
}

my $http = configure_http or die;
