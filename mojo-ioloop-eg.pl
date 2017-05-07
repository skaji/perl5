#!/usr/bin/env perl
use 5.10.1;
use strict;
use warnings;
use Mojo::IOLoop::Signal;
use Mojo::IOLoop::Stream;
use Mojo::IOLoop;

package Notifier {
    sub new {
        my ($class, %argv) = @_;
        bless \%argv, $class;
    }
    sub next {
        my ($self, @argv) = @_;
        $self->{next}->(@argv);
    }
    sub last {
        my ($self, @argv) = @_;
        $self->{last}->(@argv);
    }
    sub broadcast {
        my ($self, @argv) = @_;
        # TODO
    }
}

package Seq {
    sub new {
        my $class = shift;
        my $self = bless { subs => [], }, $class;
        $self->put($_) for @_;
        $self;
    }
    sub put {
        my ($self, $sub) = @_;
        push @{$self->{subs}}, $sub;
    }
    sub start {
        my ($self, @argv) = @_;
        $self->_next(@argv);
    }
    sub _next {
        my ($self, @argv) = @_;
        my $sub = shift @{$self->{subs}};
        return unless $sub;
        my $notifier = Notifier->new(
            next => sub { $self->_next(@_) },
            last => sub { @{$self->{subs}} = () },
        );
        $sub->($notifier, @argv);
    }
}

sub info { warn "---> @_\n" }

# our seq
my $seq = Seq->new;
for my $i (1..100) {
    $seq->put(sub {
        my ($notifier, @argv) = @_;
        Mojo::IOLoop->timer(1 => sub {
            info "seq $i (@argv)";
            if ($i > 10) {
                $notifier->last;
            } else {
                $notifier->next($i);
            }
        });
    });
}
$seq->start("start");

# io
my $io = Mojo::IOLoop::Stream->new(\*STDIN)->timeout(0);
$io->on(read => sub {
    my ($io, $buf) = @_;
    chomp $buf;
    info "stdin $buf";
});
$io->start;

# signal
Mojo::IOLoop::Signal->on(INT => sub {
    state $count = 0;
    my ($self, $name) = @_;
    $count += 1;
    info "INT count = $count";
    if ($count >= 3) {
        info "INT unsubscribe";
        $self->unsubscribe('INT');
    }
});

Mojo::IOLoop->start;
