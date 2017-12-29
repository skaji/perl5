#!/usr/bin/env perl
use strict;
use warnings;
use Socket qw(
    inet_ntoa inet_aton
    inet_ntop inet_pton
    getaddrinfo getnameinfo
    pack_sockaddr_in unpack_sockaddr_in
    AF_INET IPPROTO_TCP
    NIx_NOSERV
);

=head2 inet_XtoY

inet_XtoY は単に address を

  * d.d.d.d形式 (human readble string)
  * packed ip (packed binary address structure)

に変える役割のみ

旧inet_ntoa == 新inet_ntop: packed ip -> d.d.d.d形式

旧inet_aton == 新inet_pton: d.d.d.d形式 -> packed ip

=head2 名前解決

旧gethostbyname == 新getaddrinfo

  host -> packed ip

=head2 逆名前解決

旧gethostbyaddr == 新getnameinfo

  packed ip -> host

=cut

# 変数の意味
# $host      = "www.google.com"
# $ip        = "8.8.8.8"
# $inet_addr = packされたIPv4
# $addr      = portと$inet_addrをpackしたもの
# $service   = "http"
# $port      = 80

# (1) 古いやりたか (特にIPv6の考慮がないのがよろしくない)

## (1-1) 名前解決
{
    my $host      = "www.google.com";
    my $inet_addr = gethostbyname $host; # 注: リストコンテキストだといろいろ返す
    my $ip        = inet_ntoa $inet_addr;
    print "$host -> $ip\n";
}
# XXX gethostbynameがIPv6を返すこともあったきがする

## (1-2) 逆名前解決
{
    my $ip        = "8.8.8.8";
    my $inet_addr = inet_aton $ip;
    my $host      = gethostbyaddr $inet_addr, AF_INET; # 注: リストコンテキストだといろいろ返す
    print "$ip -> $host\n";
}


# (2) 新しいやり方 (Socket v2.000+, perl v5.16+ でしか使えないと思った方がよさそう)

# service, portに興味なし
my $service = "";
my $port    = 0;

## (2-1) 名前解決
{
    my $host = "www.google.com";
    my $hints = { family => AF_INET, protocol => IPPROTO_TCP };
    my ($err, @res) = getaddrinfo $host, $service, $hints;
    die $err if $err;
    my $addr = $res[0]{addr};
    my ($port, $inet_addr) = unpack_sockaddr_in $addr;
    my $ip = inet_ntop AF_INET, $inet_addr;
    print "$host -> $ip\n";
}

## (2-2) 逆名前解決
{
    my $ip = "8.8.8.8";
    my $inet_addr = inet_pton AF_INET, $ip;
    my $addr = pack_sockaddr_in $port, $inet_addr;
    my $flags  = 0;
    my $xflags = NIx_NOSERV; # serviceに興味なしを示すNIx_NOSERVを使っている
    my ($err, $host, $service) = getnameinfo $addr, $flags, $xflags;
    die $err if $err;
    print "$ip -> $host\n";
}

=pod

# (3) one liner

## (3-1) 名前解決

 echo www.google.com | \
    perl -MSocket -nle 'my $host = inet_ntoa scalar gethostbyname $_; print "$_ -> $host"'

## (3-2) 逆名前解決

 echo 8.8.8.8 | \
    perl -MSocket -nle 'my $ip = gethostbyaddr inet_aton($_), AF_INET; print "$_ -> $ip"'

=cut
