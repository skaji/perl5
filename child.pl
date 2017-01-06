#!/usr/bin/env perl
use strict;
use warnings;

package Child {
    use POSIX ();
    sub new {
        my ($class, $pid) = @_;
        bless { status => undef, pid => $pid }, $class;
    }
    sub DESTROY {
        my $self = shift;
        $self->wait;
    }
    sub wait {
        my $self = shift;
        return 1 if defined $self->{status};
        my $got = waitpid $self->{pid}, 0;
        if ($got == $self->{pid}) {
            $self->{status} = $?;
            return 1;
        } else {
            die "waitpid returns $got";
        }
    }
    sub is_finished {
        my $self = shift;
        return 1 if defined $self->{status};
        my $got = waitpid $self->{pid}, POSIX::WNOHANG();
        if ($got == -1) {
            die "waitpid returns $got";
        } elsif ($got == 0) {
            return 0;
        } elsif ($got == $self->{pid}) {
            $self->{status} = $?;
            return 1;
        }
    }
    sub kill {
        my ($self, $sig) = @_;
        $sig //= 'TERM';
        kill $sig => $self->{pid};
    }
}

sub child (&) {
    my $code = shift;
    my $pid = fork // die;
    if ($pid == 0) {
        $code->();
        exit;
    }
    Child->new($pid);
}

{
    my $child = child { sleep 10 };
    $child->kill('HUP');
}
