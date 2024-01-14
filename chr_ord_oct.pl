#!/usr/bin/env perl
use v5.38;
use experimental qw(builtin class defer for_list try);

# static literal
{
    my $int_by_str2  = 0b10;
    my $int_by_str8  = 0o755;
    my $int_by_str16 = 0x0a;

    # \x01 と \x{01} の違い
    # * 1byteを生成するとき {} はなくてよい。
    # * "文字" を生成したいとき、{}を使う。
    my $byte_by_str16 = "\x01";
    my $char_by_str16 = "\x{01}";
    my $char_by_str16_2 = "\x{3042}";

    my $char_by_unicode_name = "\N{LATIN CAPITAL LETTER I WITH DOT ABOVE}";
    my $char_by_unicode_point = "\N{U+3042}";
    # unicode point 0x3042 で示される文字は
    # "\x{3042}" でも "\N{U+3042}" でも表せる

    # NOTE: \p{...} とかは正規表現で使うもの
}

# str 16 <-> int
{
    my $str = "a00";
    warn hex $str;
    warn oct "0x$str";
    my $int = 0xa00;
    warn sprintf "0x%X", $int;
}

# str 8 <-> int
{
    my $str = "755";
    warn oct "0o$str";
    my $int = 0o755;
    warn sprintf "0o%o", $int;
}

# str 2 <-> int
{
    my $str = "1001";
    warn oct "0b$str";
    my $int = 0b1001;
    warn sprintf "0b%b", $int;
}

# 1byte <-> int,str
{
    my $b = "A";
    warn ord $b;                 # int 65
    warn unpack 'B8', $b;        # str 01000001
    warn sprintf "%08b", ord $b; # こちらも同じ
    warn unpack 'H2', $b;        # str 41
    warn sprintf "%02X", ord $b; # こちらも同じ

    my $int = 0x41;
    warn chr $int;
    my $str_2 = "01000001";
    warn pack 'B8', $str_2;
    warn chr oct "0b$str_2";
    my $str_16 = "41";
    warn pack 'H2', $str_16;
    warn chr oct "0x$str_16";
}

# char <-> unicode code point
{
    use Encode ();
    use utf8;
    my $point = ord 'あ';
    warn sprintf "0x%X", $point;
    my $char = chr $point;
    warn Encode::encode_utf8($char);
}
