#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper ();

# See Dist::Zilla
sub dump_as {
    my ($data, $name) = @_;
    my $dumper = Data::Dumper->new([$data], [$name]);
    $dumper->Sortkeys(1);
    $dumper->Indent(1);
    $dumper->{xpad} = " " x 4; # hack
    $dumper->Useqq(1);
    return $dumper->Dump;
}

my $data = { foo => "1\n", bar => [1..5] };
my $str = dump_as $data, "*Foo";

print "my $str";

__END__

my %Foo = (
    "bar" => [
        1,
        2,
        3,
        4,
        5
    ],
    "foo" => "1\n"
);
