#!/usr/bin/env perl
use 5.32.0;
use warnings;
use experimental 'signatures';

package DNS {
    use Socket ();

    sub new ($class, %hint) {
        $hint{socktype} //= Socket::SOCK_STREAM;
        bless { hint => \%hint }, $class;
    }

    sub resolve ($self, $host, %hint) {
        my @ip_string;
        for my $info ($self->resolve_addrinfo($host, %hint)) {
            my ($family, $addr) = $info->@{"family", "addr"};
            my $unpack = $family == Socket::AF_INET ?
                \&Socket::unpack_sockaddr_in : \&Socket::unpack_sockaddr_in6;
            my $ip_binary = $unpack->($addr);
            my $ip_string = Socket::inet_ntop $family, $ip_binary;
            push @ip_string, $ip_string;
        }
        @ip_string;
    }

    sub resolve_addrinfo ($self, $host, %hint) {
        my $service = "0";
        my $hint = {
            flags => Socket::AI_ADDRCONFIG,
            $self->{hint}->%*,
            %hint,
        };
        my ($err, @info) = Socket::getaddrinfo $host, $service, $hint;
        return if $err;
        @info;
    }

    my $REGEXP_IPv4_DECIMAL = qr/25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2}/;
    my $REGEXP_IPv4_DOTTEDQUAD = qr/$REGEXP_IPv4_DECIMAL\.$REGEXP_IPv4_DECIMAL\.$REGEXP_IPv4_DECIMAL\.$REGEXP_IPv4_DECIMAL/;

    sub reverse_resolve ($self, $ip_string, %hint) {
        %hint = ($self->{hint}->%*, %hint);
        my $family = $ip_string =~ m/^$REGEXP_IPv4_DOTTEDQUAD$/ ?
            Socket::AF_INET : Socket::AF_INET6;
        my $port = 0;
        my $ip_binary = Socket::inet_pton $family, $ip_string;
        my $pack = $family == Socket::AF_INET ?
            \&Socket::pack_sockaddr_in : \&Socket::pack_sockaddr_in6;
        my $addr = $pack->($port, $ip_binary);
        my $flags = $hint{socktype} == Socket::SOCK_DGRAM ? Socket::NI_DGRAM : 0;
        my $xflags = Socket::NIx_NOSERV; # not interested in "service"
        my ($err, $host, $service) = Socket::getnameinfo $addr, $flags, $xflags;
        $host = undef if $err || (defined $host && $host eq $ip_string);
        $host;
    }
}

my $dns = DNS->new;
my @ip = $dns->resolve("www.google.com");
say $_ for @ip;

my $host = $dns->reverse_resolve("2404:6800:4004:80f::2004");
say $host;

# my $resolve = sub ($host) { (state $dns = DNS->new)->resolve($host)->[0] };
#
# use HTTP::Tiny;
#
# my $http = HTTP::Tiny->new;
# my $res = $http->get("https://www.google.com", { peer => $resolve });
# print $res->{status};

# echo www.google.co.jp | perl -MSocket=:all -nle 'my ($err, @info) = getaddrinfo $_, "", { protocol => IPPROTO_TCP, socktype => SOCK_STREAM }; if ($err) { warn "$_: $err"; next } for my $info (@info) { my $sub = $info->{family} == AF_INET ? \&unpack_sockaddr_in : \&unpack_sockaddr_in6; my $ip = inet_ntop $info->{family}, scalar $sub->($info->{addr}); print "$_ $ip" }'
