#!/usr/bin/env perl
use strict;
use warnings;

use Benchmark 'cmpthese';
use Scalar::Util 'blessed';

my $eval          = sub { my ($v, $class) = @_; local $@; eval { $v->isa($class) } };
my $eval_no_local = sub { my ($v, $class) = @_; eval { $v->isa($class) } };
my $blessed       = sub { my ($v, $class) = @_; blessed $v && $v->isa($class) };
my $universal     = sub { my ($v, $class) = @_; UNIVERSAL::isa $v, $class };

my $x = bless {}, 'A';
my $y = 10;

cmpthese -1, {
    eval => sub {
        $eval->($x, 'A');
        $eval->($x, 'B');
        $eval->($y, 'A');
    },
    eval_no_local => sub {
        $eval_no_local->($x, 'A');
        $eval_no_local->($x, 'B');
        $eval_no_local->($y, 'A');
    },
    blessed => sub {
        $blessed->($x, 'A');
        $blessed->($x, 'B');
        $blessed->($y, 'A');
    },
    universal => sub {
        $universal->($x, 'A');
        $universal->($x, 'B');
        $universal->($y, 'A');
    },
};

__END__
                   Rate          eval eval_no_local       blessed     universal
eval           303675/s            --          -24%          -64%          -70%
eval_no_local  398221/s           31%            --          -53%          -61%
blessed        851644/s          180%          114%            --          -16%
universal     1008246/s          232%          153%           18%            --

Note:
UNIVERSAL::isa does not care about overridden `isa` method
UNIVERSAL::isa \%hash, 'HASH' is true
