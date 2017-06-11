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
        my ($self, $all) = @_;
        if ($all) {
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
    use Process::Status;
    use Time::HiRes ();
    use constant TICK => 0.05;

    sub new {
        my ($class, @command) = @_;
        bless {
            buffer   => {},
            command  => \@command,
            on       => {},
            redirect => undef,
        }, $class;
    }
    sub on {
        my ($self, $type, $sub) = @_;
        if ($type ne 'stdout' && $type ne 'stderr') {
            die "unknown type '$type'";
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
            POSIX::setpgid(0, 0) or die;
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
            for my $ready ($select->can_read(TICK)) {
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
                    $sub->($_) for @line;
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
            my @line = $buffer->get("all");
            my $sub = $self->{on}{$type} || sub {};
            $sub->($_) for @line;
        }
        close $_ for $select->handles;
        if ($INT && kill 0 => $pid) {
            kill INT => -$pid;
        }
        if ($is_timeout && kill 0 => $pid) {
            kill TERM => -$pid;
        }
        waitpid $pid, 0;
        return Process::Status->new($?);
    }
}

my $status = Command
    ->new("perl", "-E", 'BEGIN { $|++ } for (1..10) { say $_; warn $_; sleep 1}')
    ->timeout(3)
    ->on(stdout => sub { my $buf = shift; print "-> out: $buf" })
    ->on(stderr => sub { my $buf = shift; print "-> err: $buf" })
    ->exec;

print $status->as_string, "\n";
