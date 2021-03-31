#!/usr/bin/env perl
use 5.32.0;
use warnings;
use experimental 'signatures';

package DNS {
    use Socket ();
    use Carp ();

    sub new ($class) {
        bless {}, $class;
    }

    sub resolve ($self, $host) {
        my @ip;
        for my $info ($self->resolve_addrinfo($host)) {
            my ($family, $addr) = $info->@{"family", "addr"};
            my $sub = $family == Socket::AF_INET ?
                \&Socket::unpack_sockaddr_in : \&Socket::unpack_sockaddr_in6;
            my $ip_binary = $sub->($addr);
            my $ip_string = Socket::inet_ntop $family, $ip_binary;
            push @ip, $ip_string;
        }
        @ip;
    }

    sub resolve_addrinfo ($self, $host) {
        my $service = "0";
        my $hint = {
            flags => Socket::AI_ADDRCONFIG,
            socktype => Socket::SOCK_STREAM,
            protocol => Socket::IPPROTO_TCP,
            # family => Socket::AF_INET,
        };
        my ($err, @info) = Socket::getaddrinfo $host, $service, $hint;
        Carp::croak $err if $err;
        @info;
    }
}

my $dns = DNS->new;
my @ip = $dns->resolve("www.google.com");
warn $_ for @ip;

# my $resolve = sub ($host) { (state $dns = DNS->new)->resolve($host)->[0] };
#
# use HTTP::Tiny;
#
# my $http = HTTP::Tiny->new;
# my $res = $http->get("https://www.google.com", { peer => $resolve });
# print $res->{status};

# echo www.google.co.jp | perl -MSocket=:all -nle 'my ($err, @info) = getaddrinfo $_, "", { protocol => IPPROTO_TCP, socktype => SOCK_STREAM }; if ($err) { warn "$_: $err"; next } for my $info (@info) { my $sub = $info->{family} == AF_INET ? \&unpack_sockaddr_in : \&unpack_sockaddr_in6; my $ip = inet_ntop $info->{family}, scalar $sub->($info->{addr}); print "$_ $ip" }'
