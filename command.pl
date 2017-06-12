#!/usr/bin/env perl
use 5.14.0;
use warnings;

=head1 SEE ALSO

L<System::Command>

=cut

package LineBuffer {
    sub new {
        my $class = shift;
        bless { buffer => "" }, $class;
    }
    sub append {
        my ($self, $buffer) = @_;
        $self->{buffer} .= $buffer;
        $self;
    }
    sub get {
        my ($self, $drain) = @_;
        if ($drain) {
            if (length $self->{buffer}) {
                my @line = $self->get;
                if (length $self->{buffer}) {
                    push @line, $self->{buffer};
                    $self->{buffer} = "";
                }
                return @line;
            } else {
                return;
            }
        }
        my @line;
        while ($self->{buffer} =~ s/\A(.*?\n)//sm) {
            push @line, $1;
        }
        return @line;
    }
}

package Command {
    use IO::Select;
    use POSIX ();
    use Time::HiRes ();
    use Config ();

    sub new {
        my ($class, @command) = @_;
        bless {
            buffer   => {},
            command  => \@command,
            on       => {},
            redirect => undef,
            tick     => 0.05,
        }, $class;
    }
    sub on {
        my ($self, $type, $sub) = @_;
        my %valid = map { $_ => 1 } qw(stdout stderr timeout);
        if (!$valid{$type}) {
            die "unknown type '$type' passes to on() method";
        }
        $self->{on}{$type} = $sub;
        $self;
    }
    sub timeout {
        my ($self, $sec) = @_;
        $self->{timeout} = $sec;
        $self;
    }
    sub redirect {
        my ($self, $bool) = @_;
        $self->{redirect} = $bool;
        $self;
    }
    sub tick {
        my ($self, $tick) = @_;
        $self->{tick} = $tick;
        $self;
    }
    sub exec {
        my $self = shift;
        pipe my $stdout_read, my $stdout_write;
        my ($stderr_read, $stderr_write);
        pipe $stderr_read, $stderr_write unless $self->{redirect};
        my $pid = fork // die "fork: $!";
        if ($pid == 0) {
            close $_ for grep $_, $stdout_read, $stderr_read;
            open STDOUT, ">&", $stdout_write;
            if ($self->{redirect}) {
                open STDERR, ">&", \*STDOUT;
            } else {
                open STDERR, ">&", $stderr_write;
            }
            if ($Config::Config{d_setpgrp}) {
                POSIX::setpgid(0, 0) or die "setpgid: $!";
            }
            exec @{$self->{command}};
            exit 255;
        }
        close $_ for grep $_, $stdout_write, $stderr_write;

        my $INT; local $SIG{INT} = sub { $INT++ };
        my $is_timeout;
        my $timeout_at = $self->{timeout} ? Time::HiRes::time() + $self->{timeout} : undef;
        my $select = IO::Select->new(grep $_, $stdout_read, $stderr_read);
        while (1) {
            last if $INT;
            last if $select->count == 0;
            for my $ready ($select->can_read($self->{tick})) {
                my $type = $ready == $stdout_read ? "stdout" : "stderr";
                my $len = sysread $ready, my $buf, 64*1024;
                if (!defined $len) {
                    warn "sysread pipe failed: $!";
                    last;
                } elsif ($len == 0) {
                    $select->remove($ready);
                    close $ready;
                } else {
                    my $buffer = $self->{buffer}{$type} ||= LineBuffer->new;
                    $buffer->append($buf);
                    my @line = $buffer->get;
                    next unless @line;
                    my $sub = $self->{on}{$type} ||= sub {};
                    $sub->(@line);
                }
            }
            if ($timeout_at) {
                my $now = Time::HiRes::time();
                if ($now > $timeout_at) {
                    $is_timeout++;
                    last;
                }
            }
        }
        for my $type (qw(stdout stderr)) {
            my $buffer = $self->{buffer}{$type} or next;
            my @line = $buffer->get(1) or next;
            my $sub = $self->{on}{$type} || sub {};
            $sub->(@line);
        }
        close $_ for $select->handles;
        if ($INT && kill 0 => $pid) {
            my $target = $Config::Config{d_setpgrp} ? -$pid : $pid;
            kill INT => $target;
        }
        if ($is_timeout && kill 0 => $pid) {
            if (my $on_timeout = $self->{on}{timeout}) {
                $on_timeout->($pid);
            }
            my $target = $Config::Config{d_setpgrp} ? -$pid : $pid;
            kill TERM => $target;
        }
        waitpid $pid, 0;
        return $?;
    }
}

my $status = Command
    ->new("perl", "-E", 'BEGIN { $|++ } for (1..10) { say $_; warn $_; sleep 1}')
    ->timeout(3)
    ->on(stdout  => sub { print "-> out: $_" for @_ })
    ->on(stderr  => sub { print "-> err: $_" for @_ })
    ->on(timeout => sub { warn "-> timeout!\n" })
    ->exec;

print $status, "\n";
