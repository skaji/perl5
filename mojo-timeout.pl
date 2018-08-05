#!/usr/bin/env perl
use strict;
use warnings;

package Mojo::IOLoop::ReadWriteFork::Timeout {
    use Mojo::Base 'Mojo::IOLoop::ReadWriteFork';

    has 'timeout';
    has 'tick' => 0.1;

    has '_inactive' => 0;
    has '_killer';

    sub new {
        my $self = shift->SUPER::new(@_);
        $self->on(close => sub { $self->_stop_killer });
        $self;
    }

    sub _read {
        my $self = shift;
        $self->_inactive(0);
        $self->SUPER::_read(@_);
    }

    sub start {
        my $self = shift;
        my $ret = $self->SUPER::start(@_);
        $self->{_killer} = Mojo::IOLoop->recurring($self->tick => sub {
            $self->_inactive($self->tick + $self->_inactive);
            return if $self->_inactive < $self->timeout;
            $self->kill;
            $self->_stop_killer;
        });
        $ret;
    }

    sub _stop_killer {
        my $self = shift;
        if ($self->_killer) {
            Mojo::IOLoop->remove($self->_killer);
            $self->_killer(undef);
        }
    }

    sub DESTROY {
        my $self = shift;
        $self->_stop_killer;
        $self->SUPER::DESTROY;
    }
}

my $fork = Mojo::IOLoop::ReadWriteFork::Timeout->new(timeout => 5);
$fork->on(read => sub { my ($self, $data) = @_; warn "[$data]\n" });
$fork->on(close => sub { warn 1; undef $fork });
$fork->run("perl", "-le", '$|++; sleep 6; for (1..10) { print $_; sleep 1 }');
Mojo::IOLoop->start;
